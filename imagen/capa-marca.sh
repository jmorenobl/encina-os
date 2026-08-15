#!/usr/bin/env bash
# Encina OS - Fabrica LA CAPA DE MARCA del medio, EN MACOS.
#
#     ./imagen/capa-marca.sh <iso> --salida <dir> [--trabajo DIR] [--conservar]
#
# QUE PRODUCE: un solo fichero, <dir>/zz-encina.squashfs, que fabricar-iso.sh
# mete en /casper/ de la ISO. Dentro va TODO lo que la sesion viva del medio
# tiene que decir en Encina: el os-release, el lsb-release, /etc/issue, el nombre
# de la sesion Wayland, el tema de texto de Plymouth, los activos graficos de
# Canonical sustituidos por los nuestros, y el directorio
# /usr/share/desktop-provision/ con el que se le pone marca al INSTALADOR sin
# tocar su snap.
#
# POR QUE UNA CAPA Y NO REHACER minimal.squashfs, que es lo que parecia:
# TODOS esos ficheros viven en /casper/minimal.squashfs -- 1 692 274 688 bytes --
# y rehacerlo para cambiar nueve ficheros de texto y quince dibujos es pagar
# 1,69 GB por 200 KB. La capa cuesta lo que pesa.
#
# Y POR QUE SE PUEDE, que es lo que hubo que medir y no suponer (§4.52b). Leido
# en el 'scripts/casper' que viaja en el initrd de ESTE medio:
#   - el medio NO lleva 'layerfs-path=' en la linea del nucleo -- se ha buscado
#     en el grub.cfg, en la ESP y en el resto del medio --, asi que casper entra
#     por su rama de «no multi-capa»: monta TODOS los *.squashfs de /casper.
#   - los monta en orden de glob (ascendente, ASCII) y va PONIENDO CADA UNO
#     DELANTE en la lista, asi que el ULTIMO por orden alfabetico acaba el
#     primero de 'lowerdir=' -- y en overlayfs el primero de lowerdir es EL QUE
#     MANDA.
#   - de ahi el nombre: 'zz-encina' va detras de los veintiun 'minimal.*'.
#     No es un capricho tipografico: es la unica razon por la que la capa tapa
#     y no queda tapada. El control (a) de este guion lo comprueba, y sabe decir
#     que NO con un nombre que empiece por 'aa-'.
#
# LO QUE ESTA CAPA NO PUEDE HACER, dicho aqui para que no se busque despues:
#   - el fondo NO se cambia por el ajuste: 10_ubuntu-settings.gschema.override
#     esta compilado dentro de gschemas.compiled y reescribir el .override no
#     sirve de nada sin volver a compilar los esquemas, que exige un Linux. Lo
#     que se cambia es EL FICHERO al que el ajuste apunta.
#   - las diapositivas del instalador no se parchean: «{{ DISTRO }}» no sale de
#     ningun fichero del medio, sale de una constante compilada en el binario
#     del snap (§4.52c). Se sustituyen enteras.
#   - el splash del arranque no esta aqui: vive en el initrd, antes de que exista
#     ninguna capa. Va aparte y sigue pendiente.
#
# EL PRECIO: ~3,2 GB de disco temporal, porque los controles (c) y (d) leen las
# capas del medio de verdad. Con --trabajo la segunda vuelta es barata, y el
# directorio es el mismo que usa inventario-marca.sh.

set -uo pipefail
export LC_ALL=C

AQUI=$(cd "$(dirname "$0")" && pwd)
FUENTE="$AQUI/marca"
BRANDING="$AQUI/../debian-packages/encina-branding/src"

ISO=""; SALIDA=""; TRABAJO=""; CONSERVAR=0
uso() { sed -n '4p' "$0"; exit 2; }
while [ $# -gt 0 ]; do
    case "$1" in
        --salida)    SALIDA="$2";  shift 2 ;;
        --trabajo)   TRABAJO="$2"; shift 2 ;;
        --conservar) CONSERVAR=1;  shift ;;
        -h|--help)   sed -n '1,50p' "$0"; exit 0 ;;
        -*)          echo "opcion desconocida: $1" >&2; uso ;;
        *)           [ -z "$ISO" ] || uso; ISO="$1"; shift ;;
    esac
done
[ -n "$ISO" ] && [ -n "$SALIDA" ] || uso
[ -f "$ISO" ] || { echo "[FALLO] no existe la ISO: $ISO" >&2; exit 1; }

N_OK=0; N_MAL=0; N_OMI=0; FALLOS=()
titulo() { echo; echo "=== $* ==="; }
paso()   { echo "--- $* "; }
ok()     { N_OK=$((N_OK+1)); echo "  [OK]    $*"; }
omitido(){ N_OMI=$((N_OMI+1)); echo "  [OMIT]  $*"; }
fallo()  { N_MAL=$((N_MAL+1)); echo "  [FALLO] $1"; [ -n "${2:-}" ] && echo "$2" | sed 's/^/          | /'; FALLOS+=("$1"); }
morir()  { echo "[FALLO] $*" >&2; exit 1; }

for h in xorriso osirrox unsquashfs mksquashfs shasum sips python3; do
    command -v "$h" >/dev/null || morir "falta la herramienta: $h"
done
[ -d "$FUENTE" ]   || morir "no esta el arbol de marca: $FUENTE"
[ -d "$BRANDING" ] || morir "no esta el arbol de encina-branding: $BRANDING"

if [ -n "$TRABAJO" ]; then
    mkdir -p "$TRABAJO"; T=$(cd "$TRABAJO" && pwd)
else
    T=$(mktemp -d /tmp/capa-marca.XXXXXX)
    trap '[ "$CONSERVAR" -eq 1 ] || rm -rf "$T"' EXIT
fi
mkdir -p "$T/capas" "$T/sel"
ARBOL="$T/arbol-capa"          # el arbol que se va a empaquetar
VERIF="$T/verif-capa"          # y el que se desempaqueta para comprobarlo
rm -rf "$ARBOL" "$VERIF"

mkdir -p "$SALIDA"; SALIDA=$(cd "$SALIDA" && pwd)
CAPA="$SALIDA/zz-encina.squashfs"

titulo "0. EL MEDIO QUE SE LEE, por huella y no por nombre"
echo "  fichero : $ISO"
echo "  huella  : $(shasum -a 256 "$ISO" | cut -d' ' -f1)"
echo "  trabajo : $T"
echo "  salida  : $CAPA"

# --------------------------------------------------------------------------
titulo "1. LOS CONTROLES, ANTES DE FABRICAR NADA"

# (a) EL ORDEN DE MONTAJE. Esto es 'setup_unionfs' de scripts/casper escrito
#     otra vez, a proposito: no se resume, se reproduce, porque lo que decide
#     que esta capa sirva de algo es ese bucle y no una intuicion.
lowerdir_de() {   # recibe nombres de capa; imprime el 'lowerdir=' que saldria
    local rofslist="" img
    for img in $(printf '%s\n' "$@" | LC_ALL=C sort); do
        rofslist="/$img $rofslist"          # casper pone cada nueva DELANTE
    done
    local mounts=""
    for m in $rofslist; do mounts="$mounts:$m"; done
    echo "${mounts#:}"
}
paso "(a) el orden de montaje de casper deja la capa de Encina la primera"
CAPAS_MEDIO=$(xorriso -indev "$ISO" -find /casper -name '*.squashfs' -- 2>/dev/null \
              | tr -d "'" | sed 's|.*/||')
N_CAPAS=$(printf '%s\n' "$CAPAS_MEDIO" | /usr/bin/grep -c . )
if [ "$N_CAPAS" -lt 3 ]; then
    fallo "el medio declara $N_CAPAS capas squashfs: no se ha leido nada"
else
    PRIM_SI=$(lowerdir_de $CAPAS_MEDIO zz-encina.squashfs | cut -d: -f1)
    PRIM_NO=$(lowerdir_de $CAPAS_MEDIO aa-encina.squashfs | cut -d: -f1)
    if [ "$PRIM_SI" = "/zz-encina.squashfs" ] && [ "$PRIM_NO" != "/aa-encina.squashfs" ]; then
        ok "sobre las $N_CAPAS capas del medio: 'zz-' queda la primera de lowerdir y 'aa-' NO (queda $PRIM_NO)"
    else
        fallo "el orden de montaje no deja la capa de Encina la primera" \
              "con zz-: $PRIM_SI    con aa-: $PRIM_NO"
    fi
fi

# (b) EL ROTULO DEL ICONO DEL INSTALADOR. Es el calculo de
#     casper-bottom/25adduser, tal cual esta escrito en el medio.
release_de() {
    local f="$1" lts rel
    lts=$(cut -d' ' -f3 "$f" 2>/dev/null)
    rel=$(cut -d' ' -f1-2 "$f" 2>/dev/null | sed 's/-/ /')
    [ "$lts" = "LTS" ] && [ -n "$rel" ] && rel="$rel LTS"
    echo "$rel"
}
paso "(b) el .disk/info de Encina da «Install Encina OS» y el del medio no"
xorriso -indev "$ISO" -osirrox on -cpx /.disk/info "$T/" -- >/dev/null 2>&1
DISKINFO_ENCINA="$FUENTE/disk-info"
if [ -f "$T/info" ] && [ -f "$DISKINFO_ENCINA" ]; then
    R_MEDIO=$(release_de "$T/info"); R_NUESTRO=$(release_de "$DISKINFO_ENCINA")
    if [ "$R_NUESTRO" = "Encina OS" ] && [ "$R_MEDIO" != "$R_NUESTRO" ]; then
        ok "Name=Install $R_NUESTRO  (el del medio da: Install $R_MEDIO)"
    else
        fallo "el .disk/info de Encina no da «Install Encina OS»" \
              "nuestro=$R_NUESTRO  medio=$R_MEDIO"
    fi
else
    fallo "falta el .disk/info del medio o el de $FUENTE"
fi

# (c) EL MECANISMO DE MARCA BLANCA, EN EL BINARIO DE ESTE MEDIO. Que este en el
#     codigo de Canonical no dice que este en el snap que viaja aqui.
paso "(c) el instalador de ESTE medio lleva dentro el mecanismo de marca blanca"
if [ ! -s "$T/capas/minimal.standard.live.squashfs" ]; then
    xorriso -indev "$ISO" -osirrox on -cpx /casper/minimal.standard.live.squashfs "$T/capas" -- >/dev/null 2>&1
fi
if [ ! -s "$T/viva.ll" ]; then
    unsquashfs -ll "$T/capas/minimal.standard.live.squashfs" > "$T/viva.ll" 2>/dev/null
fi
SNAP_V=$(awk '{print $6}' "$T/viva.ll" | /usr/bin/grep "seed/snaps/ubuntu-desktop-bootstrap" | head -1 | sed 's|.*/||')
if [ -z "$SNAP_V" ]; then
    fallo "no encuentro el snap del instalador en la capa viva del medio"
else
    if [ ! -s "$T/sel/var/lib/snapd/seed/snaps/$SNAP_V" ]; then
        unsquashfs -d "$T/sel" -f "$T/capas/minimal.standard.live.squashfs" \
            "/var/lib/snapd/seed/snaps/$SNAP_V" >/dev/null 2>&1
    fi
    if [ ! -s "$T/snap/bin/lib/libapp.so" ]; then
        unsquashfs -d "$T/snap" -f "$T/sel/var/lib/snapd/seed/snaps/$SNAP_V" \
            /bin/lib/libapp.so /meta/snap.yaml >/dev/null 2>&1
    fi
    LIB="$T/snap/bin/lib/libapp.so"
    if [ ! -f "$LIB" ]; then
        fallo "no se pudo sacar libapp.so de $SNAP_V"
    else
        FALTAN=""
        for c in "/usr/share/desktop-provision/" "DESKTOP_PROVISION_PATH" "app-name" "whitelabel"; do
            /usr/bin/grep -q -a -F "$c" "$LIB" || FALTAN="$FALTAN $c"
        done
        INVENTADA=0
        /usr/bin/grep -q -a -F "/usr/share/bellota-provision/" "$LIB" && INVENTADA=1
        CONF=$(/usr/bin/grep '^confinement:' "$T/snap/meta/snap.yaml" | awk '{print $2}')
        if [ -z "$FALTAN" ] && [ "$INVENTADA" -eq 0 ] && [ "$CONF" = "classic" ]; then
            ok "$SNAP_V: estan las cuatro cadenas, una inventada NO esta, y es 'confinement: classic' (o sea que ve el /usr/share de la sesion viva)"
        else
            fallo "el snap de este medio no sirve para marca blanca" \
                  "faltan:$FALTAN  inventada=$INVENTADA  confinamiento=$CONF"
        fi
    fi
fi

# (d) LO QUE SE VA A TAPAR, ¿EXISTE? Una sustitucion que no tapa nada es un
#     fichero de mas en el medio y un «hecho» que no ha pasado.
paso "(d) cada sustitucion tapa un fichero que EXISTE en las capas del medio"
if [ ! -s "$T/capas/minimal.squashfs" ]; then
    xorriso -indev "$ISO" -osirrox on -cpx /casper/minimal.squashfs "$T/capas" -- >/dev/null 2>&1
fi
if [ ! -s "$T/base.ll" ]; then
    unsquashfs -ll "$T/capas/minimal.squashfs" > "$T/base.ll" 2>/dev/null
fi
# el nombre es el campo 6, NO el ultimo: en un enlace la linea acaba en el
# destino y se esconderia justo view-app-grid-ubuntu-symbolic.svg (§4.51a).
awk '{print $6}' "$T/base.ll" "$T/viva.ll" | sed 's|^squashfs-root||' \
    | LC_ALL=C sort -u > "$T/rutas-medio"
N_RUTAS=$(wc -l < "$T/rutas-medio" | tr -d ' ')
TSV="$FUENTE/sustituciones.tsv"
[ -f "$TSV" ] || morir "no esta $TSV"
SIN=0; N_SUST=0; N_NUEVOS=0
while IFS=$'\t' read -r destino origen como porque; do
    case "$destino" in ''|'#'*) continue ;; esac
    case "$destino" in
        '+'*) N_NUEVOS=$((N_NUEVOS+1)); continue ;;
    esac
    N_SUST=$((N_SUST+1))
    /usr/bin/grep -qx -- "$destino" "$T/rutas-medio" || { echo "        no existe en el medio: $destino"; SIN=$((SIN+1)); }
done < "$TSV"
INVENTADA_OK=1
/usr/bin/grep -qx -- "/usr/share/backgrounds/warty-final-bellota.png" "$T/rutas-medio" && INVENTADA_OK=0
if [ "$SIN" -eq 0 ] && [ "$INVENTADA_OK" -eq 1 ] && [ "$N_SUST" -gt 0 ]; then
    ok "las $N_SUST sustituciones tapan ficheros que estan entre las $N_RUTAS rutas del medio, y una ruta inventada no aparece"
else
    fallo "$SIN sustituciones de $N_SUST no tapan nada" "control de la ruta inventada: $INVENTADA_OK"
fi

if [ "$N_MAL" -gt 0 ]; then
    echo
    echo "NO SE FABRICA NADA. Han fallado controles:"
    for f in "${FALLOS[@]}"; do echo "  - $f"; done
    exit 1
fi

# --------------------------------------------------------------------------
titulo "2. EL ARBOL DE LA CAPA"

mkdir -p "$ARBOL"
# (1) los ficheros de texto que presentan el producto
cp -R "$FUENTE/sistema/." "$ARBOL/" || morir "cp del arbol sistema/"
N_TEXTO=$(find "$FUENTE/sistema" -type f | wc -l | tr -d ' ')
echo "  $N_TEXTO ficheros de presentacion (os-release, lsb-release, issue, sesion, plymouth-text)"

# (2) la marca del instalador, que va toda bajo /usr/share/desktop-provision/
DP="$ARBOL/usr/share/desktop-provision"
mkdir -p "$DP/images"
cp "$FUENTE/whitelabel.yml" "$DP/whitelabel.yml" || morir "cp whitelabel.yml"
cp -R "$FUENTE/slides" "$DP/slides"              || morir "cp slides"
cp "$BRANDING/usr/share/icons/hicolor/scalable/apps/encina-logo.svg" "$DP/images/" || morir "cp logo"
N_SLIDES=$(find "$DP/slides" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')
echo "  whitelabel.yml, $N_SLIDES diapositivas propias y su dibujo"

# (3) los activos graficos, sustituidos por bytes en su misma ruta
while IFS=$'\t' read -r destino origen como porque; do
    case "$destino" in ''|'#'*) continue ;; esac
    d=${destino#+}
    [ -f "$BRANDING/$origen" ] || morir "no esta el origen: $BRANDING/$origen"
    mkdir -p "$ARBOL$(dirname "$d")"
    case "$como" in
        copia)  cp "$BRANDING/$origen" "$ARBOL$d" || morir "cp $origen" ;;
        png:*)  lado=${como#png:}
                cp "$BRANDING/$origen" "$T/conv-origen"
                sips -s format png -Z "$lado" "$T/conv-origen" --out "$ARBOL$d" >/dev/null 2>&1 \
                    || morir "sips no pudo convertir $origen a $lado px" ;;
        *)      morir "transformacion desconocida en sustituciones.tsv: $como" ;;
    esac
done < "$TSV"
echo "  $N_SUST activos sustituidos y $N_NUEVOS anadidos"

N_ARBOL=$(find "$ARBOL" -type f | wc -l | tr -d ' ')
echo "  total: $N_ARBOL ficheros"

# --------------------------------------------------------------------------
titulo "3. LA CAPA"
# LA FECHA, FIJADA A PROPOSITO Y POR EL MISMO MOTIVO QUE EN fabricar-iso.sh: la
# de modificacion de la ISO OFICIAL (2026-02-10 01:45:51Z, que la propia imagen
# declara en su receta). Sin esto la capa NO ES REPRODUCIBLE -- medido: dos
# pasadas seguidas dieron a4947f30… y 63218c57… -- porque mksquashfs guarda la
# hora de creacion del sistema de ficheros y la de cada inodo, y las de los
# inodos las pone 'cp' al copiarlos. Y una capa no reproducible se lleva por
# delante la definicion de terminado de la ISO entera, que no es «sale una ISO»
# sino que DOS PASADAS DEN LA MISMA HUELLA.
FECHA=1770687951
# -all-root porque en el Mac los ficheros son de 'jorge' y dentro de la sesion
# viva tienen que ser de root; -no-xattrs porque macOS cuelga atributos
# extendidos de todo lo que toca y no pintan nada en un medio de Linux;
# -noappend porque si no, un segundo pase ANADIRIA al fichero anterior en vez de
# rehacerlo, y la capa iria creciendo sin que nadie lo viera.
hacer_capa() {
    rm -f "$1"
    mksquashfs "$ARBOL" "$1" -all-root -no-xattrs -noappend -comp xz -b 131072 \
        -mkfs-time "$FECHA" -inode-time "$FECHA" -root-time "$FECHA" \
        >/dev/null 2>&1 || morir "mksquashfs fallo"
    [ -f "$1" ] || morir "mksquashfs no produjo $1"
}
hacer_capa "$CAPA"
echo "  $(basename "$CAPA"): $(stat -f %z "$CAPA") bytes  sha256 $(shasum -a 256 "$CAPA" | cut -c1-16)…"

# --------------------------------------------------------------------------
titulo "4. LA COMPROBACION DE LO QUE SE HIZO, no de lo que se pidio (trampa 13)"
unsquashfs -d "$VERIF" "$CAPA" >/dev/null 2>&1 || morir "no se puede desempaquetar la capa recien hecha"

paso "los mismos ficheros, y los mismos bytes"
( cd "$ARBOL" && find . -type f | LC_ALL=C sort ) > "$T/lista-pedida"
( cd "$VERIF" && find . -type f | LC_ALL=C sort ) > "$T/lista-real"
if diff -q "$T/lista-pedida" "$T/lista-real" >/dev/null; then
    MALAS=0
    while IFS= read -r f; do
        a=$(shasum -a 256 "$ARBOL/$f" | cut -d' ' -f1)
        b=$(shasum -a 256 "$VERIF/$f" | cut -d' ' -f1)
        [ "$a" = "$b" ] || { echo "        bytes distintos: $f"; MALAS=$((MALAS+1)); }
    done < "$T/lista-pedida"
    if [ "$MALAS" -eq 0 ]; then
        ok "$(wc -l < "$T/lista-pedida" | tr -d ' ') ficheros, ni uno mas ni uno menos, y las $(wc -l < "$T/lista-pedida" | tr -d ' ') huellas cuadran"
    else
        fallo "$MALAS ficheros de la capa no tienen los bytes que se metieron"
    fi
else
    fallo "la capa no contiene lo que se le metio" "$(diff "$T/lista-pedida" "$T/lista-real" | head -10)"
fi

paso "control: la comprobacion sabe ver un fichero que falta"
if [ -s "$T/lista-pedida" ]; then
    sed '1d' "$T/lista-pedida" > "$T/lista-saboteada"
    if diff -q "$T/lista-pedida" "$T/lista-saboteada" >/dev/null; then
        fallo "CONTROL ROTO: la comparacion no ve una lista a la que le falta una linea"
    else
        ok "quitando una linea, la comparacion lo dice"
    fi
fi

paso "dentro de la capa todo es de root"
# -lln y no -ll: en macOS el gid 0 se llama «wheel», asi que 'root/wheel' seria
# un falso rojo. Los numeros no se traducen.
NOROOT=$(unsquashfs -lln "$CAPA" 2>/dev/null | awk '$2!="" && $2 ~ /\// && $2!="0/0" {print $2}' | sort -u | tr '\n' ' ')
if [ -z "$NOROOT" ]; then
    ok "ni un fichero con dueno distinto de 0/0"
else
    fallo "hay ficheros que no son de root en la capa" "$NOROOT"
fi

paso "dos pasadas dan la misma huella"
# La definicion de terminado de la ISO no es «sale una ISO»: es que dos pasadas
# den la misma huella. Si la capa no fuera reproducible, la ISO tampoco, y el
# fallo aparecerian tres pasos mas abajo sin decir de donde viene.
hacer_capa "$T/capa-segunda.squashfs"
H1=$(shasum -a 256 "$CAPA" | cut -d' ' -f1)
H2=$(shasum -a 256 "$T/capa-segunda.squashfs" | cut -d' ' -f1)
if [ "$H1" = "$H2" ]; then
    ok "${H1:0:16}… las dos veces"
else
    fallo "la capa NO es reproducible" "1a $H1
2a $H2"
fi
rm -f "$T/capa-segunda.squashfs"

paso "el nombre de la capa es el que la pone la ultima"
case "$(basename "$CAPA")" in
    zz-*) ok "$(basename "$CAPA"): va detras de los «minimal.*» del medio" ;;
    *)    fallo "la capa no se llama zz-*: quedaria TAPADA por las de Ubuntu" ;;
esac

# --------------------------------------------------------------------------
echo
echo "=== RESUMEN ==="
echo "  correctas: $N_OK   fallos: $N_MAL   omitidas: $N_OMI"
if [ "$N_MAL" -gt 0 ]; then
    echo
    echo "NO VALE:"
    for f in "${FALLOS[@]}"; do echo "  - $f"; done
    rm -f "$CAPA"
    exit 1
fi
echo
echo "capa:   $CAPA"
echo "sha256: $(shasum -a 256 "$CAPA" | cut -d' ' -f1)"
echo "tam:    $(stat -f %z "$CAPA") bytes"
[ "$CONSERVAR" -eq 1 ] && echo "  el trabajo se conserva en: $T"
echo
echo "LO QUE ESTE GUION NO PUEDE DECIR: que en pantalla se vea. Eso lo dice"
echo "arrancar la ISO y mirarla, y eso es [OJOS] de Jorge."
exit 0
