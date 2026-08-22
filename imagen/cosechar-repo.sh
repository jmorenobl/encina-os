#!/usr/bin/env bash
# Encina OS - Bloque 0. Reconstruye /encina-repo DESDE CERO, EN MACOS.
#
#     ./cosechar-repo.sh --salida <dir> [--propios <dir>] [--manifiesto <tsv>]
#
# POR QUE EXISTE: hasta hoy los .deb del repositorio offline SOLO vivian
# dentro de la ISO, y para fabricar la ISO hacia falta la ISO anterior. Este
# guion corta esa circularidad por el lado de los que vienen de fuera: los
# baja del archivo publico y comprueba CADA UNO POR HUELLA al llegar.
# CUANTOS SON lo dice el manifiesto y no este comentario: hoy 29 (eran 28 hasta
# el 2026-08-22, que entro libnss3 -- §4.61).
#
# LA FUENTE ES imagen/repo-manifiesto.tsv, Y NUNCA UNA ISO. Si algun dia hay que
# volver a sacar la lista de un medio, la circularidad ha vuelto.
#
# LOS CUATRO DE ORIGEN 'PROPIO' NO SE COSECHAN, y no es un olvido:
#     encina-branding        scripts/03-construir.sh
#     encina-firefox-native  scripts/07-firefox-construir.sh
#     encina-meta            scripts/10-meta-construir.sh
#     autofirma              github.com/jmorenobl/encina-autofirma (publico),
#                            procedimiento en su README; OJO al paso 3, que saca
#                            el .deb del volumen 'encina-work'. Alli conviven
#                            TRES casi homonimos -- +encina2, +encina3 y
#                            +encina4 -- y el que viaja es +encina4. Se elige por
#                            RUTA ENTERA Y POR HUELLA, nunca con 'ls -t|head -1'.
# Con --propios <dir> se copian de ahi, y tambien POR HUELLA: un fichero con el
# nombre bueno y otros bytes se rechaza (es la trampa de MEDICIONES.md §4.13).
#
# COMO SE ENCUENTRA CADA .deb, y por que no se construye la ruta a mano: los
# nombres del 'pool' no son deducibles del nombre del paquete -- Mozilla les
# pega un sufijo de huella (firefox_153.0.4~build1_arm64_af3daf36….deb) y en
# Ubuntu el directorio depende del paquete FUENTE, que no es el binario. Asi que
# se descargan los INDICES del archivo y se busca en ellos. Eso ademas es lo que
# permite distinguir las tres respuestas que este guion tiene que saber dar:
#
#     [OK]       esta, y sus bytes cuadran con el manifiesto
#     [RETIRADO] el archivo ya no ofrece ESA version -- es un HALLAZGO, no un
#                contratiempo, y este guion NO coge la version nueva por su
#                cuenta: eso cambiaria lo que el producto lleva
#     [OTROS BYTES] el archivo ofrece esa version pero con otra huella, o sea
#                que el paquete se reempaqueto y el manifiesto se ha quedado atras
#
# LO QUE NO HACE: el indice 'Packages'. Lo genera dpkg-scanpackages, que NO
# existe en macOS; se hace en encina-dev (SCRIPTS.md, 'Ubicacion del
# repositorio') y al transferir va con COPYFILE_DISABLE=1, porque las entradas
# AppleDouble que inventa 'tar' TERMINAN EN .deb y dpkg-scanpackages las
# indexaria (trampa 24).

set -uo pipefail
export LC_ALL=C   # trampa 2: la salida de las herramientas, sin traducir

AQUI=$(cd "$(dirname "$0")" && pwd)
MANIFIESTO="$AQUI/repo-manifiesto.tsv"
SALIDA=""; PROPIOS=""; CACHE=""

UBUNTU=http://ports.ubuntu.com/ubuntu-ports
MOZILLA=https://packages.mozilla.org/apt
SUITES="noble noble-updates noble-security"
COMPONENTES="main universe"

uso() { sed -n '2,4p' "$0"; exit 2; }
while [ $# -gt 0 ]; do
    case "$1" in
        --salida)     SALIDA="$2";     shift 2 ;;
        --propios)    PROPIOS="$2";    shift 2 ;;
        --manifiesto) MANIFIESTO="$2"; shift 2 ;;
        --cache)      CACHE="$2";      shift 2 ;;
        -h|--help)    sed -n '1,45p' "$0"; exit 0 ;;
        *) echo "[FALLO] argumento desconocido: $1"; uso ;;
    esac
done
[ -n "$SALIDA" ] || uso
[ -f "$MANIFIESTO" ] || { echo "[FALLO] no existe el manifiesto: $MANIFIESTO"; exit 1; }
[ -n "$CACHE" ] || CACHE="$SALIDA/.indices"

fallo() { echo "[FALLO] $*"; exit 1; }
ok()    { echo "[OK]    $*"; }

command -v curl >/dev/null || fallo "no hay curl"
mkdir -p "$SALIDA" "$CACHE" || fallo "no puedo crear $SALIDA"

# --- 1. el manifiesto, leido y contado --------------------------------------
echo "== 1. el manifiesto"
TAB=$(printf '\t')
DATOS=$(grep -vE '^(#|origen'"$TAB"'|$)' "$MANIFIESTO")
N_TOTAL=$(printf '%s\n' "$DATOS" | grep -c .)
N_ARCH=$(printf  '%s\n' "$DATOS" | grep -c "^ARCHIVO$TAB")
N_PROP=$(printf  '%s\n' "$DATOS" | grep -c "^PROPIO$TAB")
[ "$N_TOTAL" -gt 0 ] || fallo "el manifiesto no tiene ni una linea de datos"
[ $((N_ARCH + N_PROP)) -eq "$N_TOTAL" ] \
    || fallo "hay lineas con un origen que no es ARCHIVO ni PROPIO"
ok "$N_TOTAL paquetes: $N_ARCH de ARCHIVO (se bajan) y $N_PROP PROPIO (se construyen)"

# --- 2. los indices del archivo ---------------------------------------------
# Se guardan en cache: son 33 MB y no cambian entre dos vueltas del mismo dia.
echo "== 2. los indices del archivo (en cache: $CACHE)"
traer_indice() {   # <destino> <url> <comprimido si|no>
    local dst="$1" url="$2" gz="$3"
    if [ -s "$dst" ]; then echo "        cache  $(basename "$dst")"; return 0; fi
    if [ "$gz" = si ]; then
        curl -fsS -o "$dst.gz" "$url" || return 1
        gunzip -f "$dst.gz" || return 1
    else
        curl -fsS -o "$dst" "$url" || return 1
    fi
    echo "        bajado $(basename "$dst")  $(wc -c <"$dst" | tr -d ' ') bytes"
}
declare -a IDX_FICHERO IDX_BASE
for s in $SUITES; do for c in $COMPONENTES; do
    d="$CACHE/ubuntu-$s-$c-arm64.Packages"
    traer_indice "$d" "$UBUNTU/dists/$s/$c/binary-arm64/Packages.gz" si \
        || fallo "no pude traer el indice $s/$c"
    IDX_FICHERO+=("$d"); IDX_BASE+=("$UBUNTU")
done; done
for a in arm64 all; do
    d="$CACHE/mozilla-$a.Packages"
    traer_indice "$d" "$MOZILLA/dists/mozilla/main/binary-$a/Packages" no \
        || fallo "no pude traer el indice de Mozilla ($a)"
    IDX_FICHERO+=("$d"); IDX_BASE+=("$MOZILLA")
done
ok "${#IDX_FICHERO[@]} indices"

# --- 3. la tabla paquete+version+arq -> huella, tamano, url ------------------
# Una sola pasada por cada indice. Se emite TODO lo que el archivo ofrece; el
# cotejo contra el manifiesto se hace despues, para poder distinguir 'no esta
# esa version' de 'esta con otros bytes'.
TABLA="$CACHE/.tabla.tsv"
: > "$TABLA"
for i in "${!IDX_FICHERO[@]}"; do
    awk -v base="${IDX_BASE[$i]}" '
        function volcar() {
            if (p != "" && v != "" && f != "")
                printf "%s\t%s\t%s\t%s\t%s\t%s/%s\n", p, v, a, s, z, base, f
            p=""; v=""; a=""; s=""; z=""; f=""
        }
        /^Package: /      { volcar(); p=substr($0,10) }
        /^Version: /      { v=substr($0,10) }
        /^Architecture: / { a=substr($0,15) }
        /^SHA256: /       { s=substr($0,9)  }
        /^Size: /         { z=substr($0,7)  }
        /^Filename: /     { f=substr($0,11) }
        END { volcar() }
    ' "${IDX_FICHERO[$i]}" >> "$TABLA"
done
N_TABLA=$(wc -l <"$TABLA" | tr -d ' ')
ok "$N_TABLA entradas en los indices"

# --- 4. los 24 de ARCHIVO, bajados y comprobados POR HUELLA -----------------
echo "== 4. los $N_ARCH de ARCHIVO"
RETIRADOS=""; OTROSBYTES=""; MALAS=0; BAJADOS=0; YAESTABAN=0
while IFS="$TAB" read -r origen paquete version fichero tamano sha; do
    [ "$origen" = ARCHIVO ] || continue
    # la arquitectura sale del nombre del fichero, y de paso lo valida
    case "$fichero" in
        *_all.deb)   arq=all   ;;
        *_arm64.deb) arq=arm64 ;;
        *) echo "        [FALLO] no se de que arquitectura es: $fichero"; MALAS=$((MALAS+1)); continue ;;
    esac
    destino="$SALIDA/$fichero"

    # ya esta y cuadra -> no se vuelve a bajar (y se dice, para no confundir
    # 'no lo baje' con 'lo baje bien')
    if [ -f "$destino" ]; then
        r=$(shasum -a 256 "$destino" | cut -d' ' -f1)
        if [ "$r" = "$sha" ]; then
            echo "        ya estaba  $fichero  ${sha:0:8}…"
            YAESTABAN=$((YAESTABAN+1)); continue
        fi
        echo "        estaba con otros bytes, se rehace: $fichero"
        rm -f "$destino"
    fi

    # que ofrece el archivo para ESE paquete, ESA version y ESA arquitectura
    linea=$(awk -F"$TAB" -v p="$paquete" -v v="$version" -v a="$arq" \
                '$1==p && $2==v && $3==a {print; exit}' "$TABLA")
    if [ -z "$linea" ]; then
        # distingue 'retirada esa version' de 'no existe el paquete'
        otras=$(awk -F"$TAB" -v p="$paquete" -v a="$arq" '$1==p && $3==a {print $2}' "$TABLA" \
                | sort -u | tr '\n' ' ')
        echo "        [RETIRADO] $paquete $version ($arq) no esta en el archivo"
        [ -n "$otras" ] && echo "                   lo que hay hoy: $otras"
        RETIRADOS="$RETIRADOS$paquete $version${TAB}${otras:-ninguna}
"
        continue
    fi
    idx_sha=$(printf '%s' "$linea" | cut -f4)
    idx_url=$(printf '%s' "$linea" | cut -f6)
    if [ "$idx_sha" != "$sha" ]; then
        # enteras y no recortadas: dos huellas que solo se diferencian en el
        # ultimo caracter se leerian IGUALES recortadas, y entonces este
        # mensaje no distingue nada
        echo "        [OTROS BYTES] $paquete $version"
        echo "                      el archivo da   $idx_sha"
        echo "                      el manifiesto   $sha"
        OTROSBYTES="$OTROSBYTES$paquete $version
"
        continue
    fi

    curl -fsS -o "$destino.parcial" "$idx_url" || {
        echo "        [FALLO] no se pudo bajar $fichero de $idx_url"
        MALAS=$((MALAS+1)); rm -f "$destino.parcial"; continue; }
    # LA COMPROBACION AL LLEGAR, que es el motivo de este guion
    r=$(shasum -a 256 "$destino.parcial" | cut -d' ' -f1)
    t=$(wc -c <"$destino.parcial" | tr -d ' ')
    if [ "$r" != "$sha" ] || [ "$t" != "$tamano" ]; then
        echo "        [FALLO] los bytes que llegaron no son los del manifiesto: $fichero"
        echo "                esperada $sha  ($tamano bytes)"
        echo "                real     $r  ($t bytes)"
        rm -f "$destino.parcial"; MALAS=$((MALAS+1)); continue
    fi
    mv "$destino.parcial" "$destino"
    echo "        bajado     $fichero  ${sha:0:8}…"
    BAJADOS=$((BAJADOS+1))
done <<EOF
$DATOS
EOF

# --- 5. los cuatro PROPIO ----------------------------------------------------
echo "== 5. los $N_PROP de origen PROPIO (no se cosechan: se construyen)"
FALTAN_PROPIOS=0
while IFS="$TAB" read -r origen paquete version fichero tamano sha; do
    [ "$origen" = PROPIO ] || continue
    destino="$SALIDA/$fichero"
    if [ -f "$destino" ] && [ "$(shasum -a 256 "$destino" | cut -d' ' -f1)" = "$sha" ]; then
        echo "        ya estaba  $fichero  ${sha:0:8}…"; continue
    fi
    if [ -n "$PROPIOS" ]; then
        # se busca POR HUELLA en todo el arbol, no por nombre ni por fecha
        origen_f=""
        while IFS= read -r cand; do
            [ "$(shasum -a 256 "$cand" | cut -d' ' -f1)" = "$sha" ] && { origen_f="$cand"; break; }
        done < <(find "$PROPIOS" -name '*.deb' -type f 2>/dev/null)
        if [ -n "$origen_f" ]; then
            cp "$origen_f" "$destino" || fallo "cp $origen_f"
            echo "        copiado    $fichero  ${sha:0:8}…  <- $origen_f"
            continue
        fi
    fi
    echo "        [FALTA]    $fichero  ${sha:0:8}…"
    FALTAN_PROPIOS=$((FALTAN_PROPIOS+1))
done <<EOF
$DATOS
EOF

# --- 6. el veredicto, con las tres respuestas separadas ----------------------
echo "== 6. el veredicto"
echo "        bajados: $BAJADOS   ya estaban: $YAESTABAN   fallos de descarga: $MALAS"
if [ -n "$RETIRADOS" ]; then
    echo
    echo "[HALLAZGO] el archivo de Ubuntu retira las versiones superadas, y esto"
    echo "           ya no se puede bajar en la version que el manifiesto pide:"
    printf '%s' "$RETIRADOS" | while IFS="$TAB" read -r q hay; do
        [ -n "$q" ] && echo "             $q   (hoy hay: $hay)"
    done
    echo "           NO se coge la version nueva: eso cambiaria lo que el producto"
    echo "           lleva, y es una decision de producto, no de este guion."
fi
[ -n "$OTROSBYTES" ] && { echo; echo "[HALLAZGO] misma version, otros bytes:"; printf '%s' "$OTROSBYTES"; }

# la comprobacion final es sobre LOS BYTES QUE HAY EN EL DIRECTORIO, no sobre lo
# que este guion cree haber hecho
echo "== 7. el directorio contra el manifiesto, entero"
CUADRAN=0; NOCUADRAN=0; AUSENTES=0
while IFS="$TAB" read -r origen paquete version fichero tamano sha; do
    f="$SALIDA/$fichero"
    if [ ! -f "$f" ]; then echo "        ausente     $fichero"; AUSENTES=$((AUSENTES+1)); continue; fi
    r=$(shasum -a 256 "$f" | cut -d' ' -f1)
    t=$(wc -c <"$f" | tr -d ' ')
    if [ "$r" = "$sha" ] && [ "$t" = "$tamano" ]; then CUADRAN=$((CUADRAN+1))
    else echo "        NO CUADRA   $fichero  esperada ${sha:0:12}… real ${r:0:12}…"; NOCUADRAN=$((NOCUADRAN+1)); fi
done <<EOF
$DATOS
EOF
SOBRAN=$(find "$SALIDA" -maxdepth 1 -name '*.deb' -type f | wc -l | tr -d ' ')
echo "        cuadran $CUADRAN de $N_TOTAL   no cuadran $NOCUADRAN   ausentes $AUSENTES"
echo "        .deb en el directorio: $SOBRAN"
[ "$SOBRAN" -eq "$CUADRAN" ] || echo "        [AVISO] hay .deb en el directorio que el manifiesto no nombra"

if [ "$CUADRAN" -eq "$N_TOTAL" ] && [ "$SOBRAN" -eq "$N_TOTAL" ]; then
    ok "los $N_TOTAL .deb estan y sus huellas cuadran con el manifiesto"
    echo
    echo "FALTA EL INDICE, y no se puede hacer aqui:"
    echo "    dpkg-scanpackages . /dev/null > Packages     <- en encina-dev"
    echo "    y al transferir, COPYFILE_DISABLE=1 (trampa 24)"
    exit 0
fi
fallo "el repositorio NO esta completo: $NOCUADRAN no cuadran, $AUSENTES ausentes"
