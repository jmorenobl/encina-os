#!/usr/bin/env bash
# Encina OS - Bloque 0. Reconstruye /encina-repo DESDE CERO, EN MACOS.
#
#     ./cosechar-repo.sh --salida <dir> [--arq arm64|amd64] [--propios <dir>]
#                        [--manifiesto <tsv>] [--cosecha <dir|tar|URL>]
#                        [--archivo <URL>] [--mozilla <URL>] [--launchpad <URL>]
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
# HAY UN MANIFIESTO POR ARQUITECTURA, y no es duplicar por gusto: el manifiesto
# guarda NOMBRE DE FICHERO Y HUELLA, y esos son distintos en cada arquitectura.
# Lo que NO puede ser distinto es LA LISTA -- que paquetes y en que version --,
# porque un hueco en una lista es exactamente lo que costo la instalacion del
# 2026-08-22 (libnss3, §4.61). Por eso el paso 1bis coteja los dos manifiestos
# entre si y PARA si dejan de decir lo mismo.
#
# Y EL ARCHIVO NO ES EL MISMO SERVIDOR, que es donde se equivoco la prediccion
# §4.64 P1: arm64 vive en ports.ubuntu.com/ubuntu-ports (que es donde Ubuntu
# pone TODO lo que no es x86) y amd64 en archive.ubuntu.com/ubuntu.
#
# LOS CUATRO DE ORIGEN 'PROPIO' NO SE COSECHAN, y no es un olvido:
#     encina-branding        scripts/construir-branding.sh
#     encina-firefox-native  scripts/construir-firefox.sh
#     encina-meta            scripts/construir-meta.sh
#     autofirma              github.com/jmorenobl/encina-autofirma (publico),
#                            procedimiento en su README; OJO al paso 3, que saca
#                            el .deb del volumen 'encina-work'. Alli conviven
#                            TRES casi homonimos -- +encina2, +encina3 y
#                            +encina4 -- y el que viaja es +encina4. Se elige por
#                            RUTA ENTERA Y POR HUELLA, nunca con 'ls -t|head -1'.
# Con --propios <dir> se copian de ahi, y tambien POR HUELLA: un fichero con el
# nombre bueno y otros bytes se rechaza (es la trampa de MEDICIONES.md §4.13).
#
# DESDE LA COSECHA PUBLICADA, --cosecha <dir|tar|URL> (2026-08-29, MEDICIONES.md
# §4.82, tareas/publicar.md): los de ARCHIVO se cogen de ahi POR HUELLA en vez
# de pedirlos al archivo, y el archivo, Mozilla y Launchpad NO SE CONSULTAN.
# Existe porque ninguna de esas tres fuentes es permanente para todo: el
# archivo retira (trampa 68), Launchpad solo conserva lo de Ubuntu, y Firefox
# viene de packages.mozilla.org, que retira y no esta en Launchpad. La cosecha
# es el /encina-repo que viaja en la ISO --los 29 .deb con su Packages--,
# empaquetado con imagen/empaquetar-cosecha.py y publicado JUNTO A la ISO. Si
# es una URL se baja a --cache; si es un .tar se extrae ahi; si es un
# directorio se lee tal cual. Cada .deb entra con EL MISMO cotejo que lo del
# archivo (huella y tamano del manifiesto, o no entra) y el mismo control, y
# se dice con su palabra, [COSECHA]. Los PROPIO siguen viniendo de --propios:
# los tres de Encina los construye construir-todo.sh desde el arbol, y
# autofirma se puede senalar a la cosecha extraida, que --propios ya busca
# por huella.
#
# --archivo, --mozilla y --launchpad cambian de donde se baja (un espejo, o
# una URL CORTADA para demostrar que con --cosecha no se toca la red del
# archivo: es el control de §4.82). Sin ellas, los de siempre.
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
#     [LAUNCHPAD] el archivo la ha retirado pero Launchpad la conserva, y los
#                bytes son los del manifiesto (2026-08-28, trampa 68): entra
#     [OTROS BYTES] el archivo ofrece esa version pero con otra huella, o sea
#                que el paquete se reempaqueto y el manifiesto se ha quedado atras
#
# LO QUE NO HACE: el indice 'Packages'. Lo genera dpkg-scanpackages, que NO
# existe en macOS; se hace en encina-dev (SCRIPTS.md, 'Ubicacion del
# repositorio') y al transferir va con COPYFILE_DISABLE=1, porque las entradas
# AppleDouble que inventa 'tar' TERMINAN EN .deb y dpkg-scanpackages las
# indexaria (trampa 24).

# MODELO DE SALIDA: ABORTAR (tarea 2, MEDICIONES.md §4.67). Este guion no
# cuenta ni resume: el primer problema lo para, y la palabra es morir(), que
# escribe [FALLO] por stderr y sale con 1. Hasta el 2026-08-28 esa misma
# funcion se llamaba fallo(), igual que la que en lib.sh APUNTA Y SIGUE; la
# misma palabra para dos flujos de control opuestos es lo que la tarea 2 quita.
# El 'set' de abajo es el que este guion ya tenia y no se ha unificado con el
# de lib.sh: cambiar las opciones de shell de un guion sin ejecutarlo entero
# seria una mutacion sin verificar.
set -uo pipefail
export LC_ALL=C   # trampa 2: la salida de las herramientas, sin traducir

AQUI=$(cd "$(dirname "$0")" && pwd)
MANIFIESTO=""
SALIDA=""; PROPIOS=""; CACHE=""; ARQ=arm64
COSECHA=""; ARCHIVO_URL=""; MOZILLA_URL=""; LAUNCHPAD_URL=""

MOZILLA=https://packages.mozilla.org/apt
# LAUNCHPAD CONSERVA LO QUE EL ARCHIVO RETIRA (trampa 68, §4.81c): por nombre de fichero, sin epoch
LAUNCHPAD=https://launchpad.net/ubuntu/+archive/primary/+files
SUITES="noble noble-updates noble-security"
COMPONENTES="main universe"

uso() { sed -n '2,4p' "$0"; exit 2; }
while [ $# -gt 0 ]; do
    case "$1" in
        --salida)     SALIDA="$2";     shift 2 ;;
        --arq)        ARQ="$2";        shift 2 ;;
        --propios)    PROPIOS="$2";    shift 2 ;;
        --manifiesto) MANIFIESTO="$2"; shift 2 ;;
        --cache)      CACHE="$2";      shift 2 ;;
        --cosecha)    COSECHA="$2";    shift 2 ;;
        --archivo)    ARCHIVO_URL="$2";   shift 2 ;;
        --mozilla)    MOZILLA_URL="$2";   shift 2 ;;
        --launchpad)  LAUNCHPAD_URL="$2"; shift 2 ;;
        -h|--help)    sed -n '1,45p' "$0"; exit 0 ;;
        *) echo "[FALLO] argumento desconocido: $1"; uso ;;
    esac
done
[ -n "$SALIDA" ] || uso
# el archivo de donde se baja depende de la arquitectura, y el manifiesto tambien
case "$ARQ" in
    arm64) UBUNTU=http://ports.ubuntu.com/ubuntu-ports; PORDEF="$AQUI/repo-manifiesto.tsv" ;;
    amd64) UBUNTU=http://archive.ubuntu.com/ubuntu;     PORDEF="$AQUI/repo-manifiesto-amd64.tsv" ;;
    *) echo "[FALLO] arquitectura desconocida: $ARQ (arm64 o amd64)"; exit 2 ;;
esac
# un espejo, o una URL cortada a proposito (el control de --cosecha, §4.82)
[ -n "$ARCHIVO_URL" ]   && UBUNTU="$ARCHIVO_URL"
[ -n "$MOZILLA_URL" ]   && MOZILLA="$MOZILLA_URL"
[ -n "$LAUNCHPAD_URL" ] && LAUNCHPAD="$LAUNCHPAD_URL"
[ -n "$MANIFIESTO" ] || MANIFIESTO="$PORDEF"
[ -f "$MANIFIESTO" ] || { echo "[FALLO] no existe el manifiesto: $MANIFIESTO"; exit 1; }
[ -n "$CACHE" ] || CACHE="$SALIDA/.indices"

# EL VOCABULARIO VIENE DE lib/salida.sh (tarea 3): ok/fallo/aviso/omitido, los
# contadores N_OK/N_MAL/N_AVI/N_OMI y morir(). Este guion ya no define ninguno.
. "$AQUI/../lib/salida.sh"

command -v curl >/dev/null || morir "no hay curl"
mkdir -p "$SALIDA" "$CACHE" || morir "no puedo crear $SALIDA"

# --- 1. el manifiesto, leido y contado --------------------------------------
echo "== 1. el manifiesto"
TAB=$(printf '\t')
DATOS=$(grep -vE '^(#|origen'"$TAB"'|$)' "$MANIFIESTO")
N_TOTAL=$(printf '%s\n' "$DATOS" | grep -c .)
N_ARCH=$(printf  '%s\n' "$DATOS" | grep -c "^ARCHIVO$TAB")
N_PROP=$(printf  '%s\n' "$DATOS" | grep -c "^PROPIO$TAB")
[ "$N_TOTAL" -gt 0 ] || morir "el manifiesto no tiene ni una linea de datos"
[ $((N_ARCH + N_PROP)) -eq "$N_TOTAL" ] \
    || morir "hay lineas con un origen que no es ARCHIVO ni PROPIO"
ok "$N_TOTAL paquetes: $N_ARCH de ARCHIVO (se bajan) y $N_PROP PROPIO (se construyen)"

# --- 1bis. LOS DOS MANIFIESTOS DICEN LA MISMA LISTA (§4.64) ------------------
# Un manifiesto por arquitectura significa DOS listas que pueden separarse, y una
# lista con un hueco es lo que costo la instalacion del 2026-08-22. Asi que se
# cotejan: mismos paquetes, mismas versiones, mismos origenes. Lo que SI tiene
# que ser distinto -- fichero y huella de los que no son _all -- no se compara.
HERMANO="$AQUI/repo-manifiesto.tsv"
[ "$ARQ" = arm64 ] && HERMANO="$AQUI/repo-manifiesto-amd64.tsv"
if [ -f "$HERMANO" ]; then
    echo "== 1bis. los dos manifiestos, cotejados entre si"
    lista_de() { grep -vE '^(#|origen'"$TAB"'|$)' "$1" | cut -f1,2,3 | sort; }
    A=$(lista_de "$MANIFIESTO"); B=$(lista_de "$HERMANO")
    # EL CONTROL VA DELANTE: el cotejo tiene que saber decir que NO.
    if [ "$(printf '%s\n' "$A" | sed '1s/$/-SABOTAJE/')" = "$B" ]; then
        morir "CONTROL ROTO: el cotejo no distingue una lista alterada"
    fi
    if [ "$A" = "$B" ]; then
        ok "$(printf '%s\n' "$A" | grep -c .) paquetes, y los dos manifiestos dicen la misma lista"
    else
        echo "        estas lineas NO estan en los dos, o no a la misma version:"
        diff <(printf '%s\n' "$A") <(printf '%s\n' "$B") | grep -E '^[<>]' | sed 's/^/          /'
        morir "repo-manifiesto.tsv y repo-manifiesto-amd64.tsv se han separado"
    fi
else
    echo "        [AVISO] no existe $HERMANO: no hay con que cotejar la lista"
fi

# --- 2bis. la cosecha publicada, si se ha pedido: entonces NO hay paso 2 ni 3 --
COSECHA_DIR=""; COSECHA_TAR=""
if [ -n "$COSECHA" ]; then
    echo "== 2. la cosecha publicada, en vez de los indices del archivo"
    case "$COSECHA" in
        http://*|https://*)
            COSECHA_TAR="$CACHE/cosecha-$ARQ.tar"
            if [ -s "$COSECHA_TAR" ]; then
                echo "        cache  $(basename "$COSECHA_TAR")"
            else
                curl -fsSL -o "$COSECHA_TAR.parcial" "$COSECHA" || morir "no pude bajar la cosecha de $COSECHA"
                mv "$COSECHA_TAR.parcial" "$COSECHA_TAR"
                echo "        bajada $COSECHA -> $(basename "$COSECHA_TAR")"
            fi ;;
        *)  [ -e "$COSECHA" ] || morir "no existe la cosecha: $COSECHA"
            if [ -d "$COSECHA" ]; then COSECHA_DIR="$COSECHA"; else COSECHA_TAR="$COSECHA"; fi ;;
    esac
    if [ -z "$COSECHA_DIR" ]; then
        echo "        tar    $(shasum -a 256 "$COSECHA_TAR" | cut -d' ' -f1)  $(wc -c <"$COSECHA_TAR" | tr -d ' ') bytes  $COSECHA_TAR"
        COSECHA_DIR="$CACHE/cosecha-$ARQ"
        rm -rf "$COSECHA_DIR"; mkdir -p "$COSECHA_DIR" || morir "mkdir $COSECHA_DIR"
        tar -xf "$COSECHA_TAR" -C "$COSECHA_DIR" || morir "no pude extraer $COSECHA_TAR"
    fi
    N_COS=$(find "$COSECHA_DIR" -name '*.deb' -type f | wc -l | tr -d ' ')
    ok "cosecha en $COSECHA_DIR: $N_COS .deb; los de ARCHIVO se cogen de ahi POR HUELLA, y el archivo, Mozilla y Launchpad no se consultan"
fi

# --- 2. los indices del archivo ---------------------------------------------
# Se guardan en cache: son 33 MB y no cambian entre dos vueltas del mismo dia.
TABLA="$CACHE/.tabla.tsv"
if [ -z "$COSECHA" ]; then
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
    d="$CACHE/ubuntu-$s-$c-$ARQ.Packages"
    traer_indice "$d" "$UBUNTU/dists/$s/$c/binary-$ARQ/Packages.gz" si \
        || morir "no pude traer el indice $s/$c"
    IDX_FICHERO+=("$d"); IDX_BASE+=("$UBUNTU")
done; done
for a in "$ARQ" all; do
    d="$CACHE/mozilla-$a.Packages"
    traer_indice "$d" "$MOZILLA/dists/mozilla/main/binary-$a/Packages" no \
        || morir "no pude traer el indice de Mozilla ($a)"
    IDX_FICHERO+=("$d"); IDX_BASE+=("$MOZILLA")
done
ok "${#IDX_FICHERO[@]} indices"

# --- 3. la tabla paquete+version+arq -> huella, tamano, url ------------------
# Una sola pasada por cada indice. Se emite TODO lo que el archivo ofrece; el
# cotejo contra el manifiesto se hace despues, para poder distinguir 'no esta
# esa version' de 'esta con otros bytes'.
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
fi   # sin --cosecha

# --- 4. los 24 de ARCHIVO, bajados y comprobados POR HUELLA -----------------
echo "== 4. los $N_ARCH de ARCHIVO"
RETIRADOS=""; OTROSBYTES=""; MALAS=0; BAJADOS=0; YAESTABAN=0; DE_LAUNCHPAD=0; DE_COSECHA=0
while IFS="$TAB" read -r origen paquete version fichero tamano sha; do
    [ "$origen" = ARCHIVO ] || continue
    # la arquitectura sale del nombre del fichero, y de paso lo valida
    # LA ARQUITECTURA SALE DEL NOMBRE, Y NO SIEMPRE ES EL ULTIMO CAMPO: Mozilla le
    # pega a veces un sufijo de huella DESPUES de la arquitectura. Y no lo hace
    # igual en las dos -- hoy firefox_153.0.4~build1_arm64.deb va limpio y
    # firefox_153.0.4~build1_amd64_53a2b3a7….deb no --, asi que un patron que
    # solo mire el final funciona en arm64 y deja el paquete mas gordo del repo
    # fuera en amd64. Medido el 2026-08-22: 28 de 29 (§4.64).
    case "$fichero" in
        *_all.deb)      arq=all    ;;
        *_"$ARQ".deb)   arq="$ARQ" ;;
        *_"$ARQ"_*.deb) arq="$ARQ" ;;
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

    # DE LA COSECHA PUBLICADA, POR HUELLA (2026-08-29, §4.82): primero por
    # nombre --en la raiz o en el directorio con que viaja el tar--, y si el
    # nombre no esta, por huella en todo el arbol. Entra con EL MISMO cotejo
    # que lo del archivo y con el mismo control; el archivo no se toca.
    if [ -n "$COSECHA" ]; then
        cand=""
        for c in "$COSECHA_DIR/$fichero" "$COSECHA_DIR"/*/"$fichero"; do
            [ -f "$c" ] && { cand="$c"; break; }
        done
        if [ -z "$cand" ]; then
            while IFS= read -r c; do
                [ "$(shasum -a 256 "$c" | cut -d' ' -f1)" = "$sha" ] && { cand="$c"; break; }
            done < <(find "$COSECHA_DIR" -name '*.deb' -type f)
        fi
        if [ -z "$cand" ]; then
            echo "        [FALLO] no esta en la cosecha: $fichero  ${sha:0:8}…"
            MALAS=$((MALAS+1)); continue
        fi
        r=$(shasum -a 256 "$cand" | cut -d' ' -f1)
        t=$(wc -c <"$cand" | tr -d ' ')
        if [ "$r" != "$sha" ] || [ "$t" != "$tamano" ]; then
            echo "        [FALLO] la cosecha trae $fichero con OTROS BYTES: no entra"
            echo "                esperada $sha  ($tamano bytes)"
            echo "                real     $r  ($t bytes)"
            MALAS=$((MALAS+1)); continue
        fi
        # CONTROL, y va antes de aceptar nada (el mismo que el de Launchpad)
        case "$sha" in f*) sab="0${sha:1}" ;; *) sab="f${sha:1}" ;; esac
        [ "$sab" != "$sha" ] || morir "CONTROL ROTO: el sabotaje de la huella no saboteo"
        [ "$r" != "$sab" ] || morir "CONTROL ROTO: la comparacion acepta una huella cambiada"
        cp "$cand" "$destino" || morir "cp $cand"
        echo "        [COSECHA]  $fichero  ${sha:0:8}…  los bytes del manifiesto"
        DE_COSECHA=$((DE_COSECHA+1)); continue
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
        # EL ARCHIVO RETIRA, LAUNCHPAD NO (2026-08-28, MEDICIONES.md §4.81c, trampa
        # 68): el 2026-08-28 openjdk-17-jre 17.0.19+10-1~24.04.2 dejo de estar en
        # los indices y en el pool (404) de las DOS arquitecturas, y 'make
        # dos-veces' no podia terminar. Launchpad conserva cada compilacion que
        # publico y la sirve por nombre de fichero -- SIN el epoch, que el pool
        # tampoco lleva: hunspell-es_24.2.1-1_all.deb y no hunspell-es_1%3a… --.
        # Se le pide, Y SE COTEJA IGUAL QUE LO QUE VIENE DEL ARCHIVO: los bytes
        # tienen que ser los del manifiesto, o no entran. Lo que no es de Ubuntu
        # (Mozilla) no esta en Launchpad y se queda [RETIRADO] como antes: no hay
        # fuente permanente para eso, y es lo que hace falta publicar con la ISO.
        lp_fichero="${paquete}_${version#*:}_${arq}.deb"
        lp_url="$LAUNCHPAD/$lp_fichero"
        echo "                   se pide a Launchpad: $lp_url"
        if curl -fsSL -o "$destino.parcial" "$lp_url" 2>/dev/null; then
            r=$(shasum -a 256 "$destino.parcial" | cut -d' ' -f1)
            t=$(wc -c <"$destino.parcial" | tr -d ' ')
            if [ "$r" = "$sha" ] && [ "$t" = "$tamano" ]; then
                # CONTROL, y va antes de aceptar nada: la misma comparacion con la
                # huella esperada cambiada en UN caracter tiene que decir que no.
                # Un sabotaje que no sabotea deja el control en decoracion
                # (§4.37c: 'sed 1s/^./f/' sobre una huella que ya empezaba por f).
                case "$sha" in f*) sab="0${sha:1}" ;; *) sab="f${sha:1}" ;; esac
                [ "$sab" != "$sha" ] || morir "CONTROL ROTO: el sabotaje de la huella no saboteo"
                [ "$r" != "$sab" ] || morir "CONTROL ROTO: la comparacion acepta una huella cambiada"
                mv "$destino.parcial" "$destino"
                echo "        [LAUNCHPAD] $fichero  ${sha:0:8}…  los bytes del manifiesto, y el control con la huella cambiada dice que no"
                DE_LAUNCHPAD=$((DE_LAUNCHPAD+1))
                continue
            fi
            echo "        [FALLO] Launchpad da $lp_fichero con OTROS BYTES: no entra"
            echo "                esperada $sha  ($tamano bytes)"
            echo "                real     $r  ($t bytes)"
            rm -f "$destino.parcial"; MALAS=$((MALAS+1)); continue
        fi
        rm -f "$destino.parcial"
        echo "                   Launchpad tampoco lo tiene (no es de Ubuntu, o el nombre no es ese)"
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
            cp "$origen_f" "$destino" || morir "cp $origen_f"
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
echo "        bajados: $BAJADOS   ya estaban: $YAESTABAN   de Launchpad (retirados del archivo, por huella): $DE_LAUNCHPAD${COSECHA:+   de la cosecha publicada (por huella): $DE_COSECHA}   fallos de descarga: $MALAS"
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
morir "el repositorio NO esta completo: $NOCUADRAN no cuadran, $AUSENTES ausentes"
