#!/usr/bin/env bash
# Encina OS - Fabrica LA CAPA DE MARCA del medio, EN MACOS.
#
#     ./imagen/capa-marca.sh <iso> --salida <dir> [--trabajo DIR] [--conservar]
#
# QUE PRODUCE: un solo fichero, <dir>/minimal.standard.live.encina.squashfs, que
# fabricar-iso.sh mete en /casper/ de la ISO. Dentro va TODO lo que la sesion viva del medio
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
# EL NOMBRE NO ES TIPOGRAFIA, ES LA CADENA -- y esto ES lo que hay que entender
# antes de tocarlo. Lo que sigue esta leido en 'scripts/casper' (setup_overlay,
# linea 545) del initrd de ESTE medio, no deducido:
#
#   - EL MEDIO SI LLEVA MULTI-CAPA. 'LAYERFS_PATH' NO esta vacio: vale
#     'minimal.standard.live.squashfs', puesto en /conf/conf.d/default-layer.conf
#     DENTRO DEL INITRD. Asi que casper entra por su rama de arriba y NO ENUMERA
#     el directorio: no hay glob, y el orden alfabetico NO PINTA NADA.
#   - la lista de capas se construye QUITANDO PUNTOS del nombre, un eslabon cada
#     vez, hasta que no quedan. Y CADA ESLABON TIENE QUE EXISTIR COMO FICHERO:
#     si falta uno, casper hace 'panic' y el arranque se acaba ahi.
#   - las monta de la corta a la larga ANTEPONIENDO cada una, asi que en
#     'lowerdir=' acaba PRIMERA LA MAS LARGA -- y en overlayfs la primera manda.
#   - de ahi el nombre: 'minimal.standard.live.encina.squashfs' cuelga de la
#     cadena que el medio ya tiene y le anade UN eslabon por encima. Es el UNICO
#     nombre posible: cualquier otro prefijo o hace 'panic' o deja la capa sola
#     sin sistema debajo. El control (a) de este guion lo comprueba reproduciendo
#     el bucle de casper, y sabe decir que NO con 'zz-encina.squashfs'.
#   - Y NO SE MONTA SOLA: hace falta 'layerfs-path=' en la linea del nucleo del
#     grub.cfg, que lo pone fabricar-iso.sh. El 'conf.d' se lee en /init:94 y
#     'parse_cmdline' reexporta en casper:909, asi que LA LINEA DEL NUCLEO PISA.
#     Sin esa bandera esta capa viaja en el medio y NO SE MONTA NUNCA (§4.54e).
#
# LO QUE SE CREIA HASTA EL 2026-08-17, Y SE DEJA ESCRITO AL LADO porque es lo que
# manda el metodo: «el medio NO lleva layerfs-path=, casper monta TODOS los
# *.squashfs de /casper y el ULTIMO por orden alfabetico manda; de ahi zz-». Era
# falso, y el cero que lo sostenia era verdadero: se busco 'layerfs-path' -- la
# grafia de la linea de ordenes -- y la variable de dentro se llama
# 'LAYERFS_PATH' y vive en un cpio comprimido. El 'zz-' no servia de nada.
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
CAPA="$SALIDA/minimal.standard.live.encina.squashfs"

titulo "0. EL MEDIO QUE SE LEE, por huella y no por nombre"
echo "  fichero : $ISO"
echo "  huella  : $(shasum -a 256 "$ISO" | cut -d' ' -f1)"
echo "  trabajo : $T"
echo "  salida  : $CAPA"

# --------------------------------------------------------------------------
titulo "1. LOS CONTROLES, ANTES DE FABRICAR NADA"

# (a) LA CADENA DE CAPAS. Esto es el bucle de 'setup_overlay' de scripts/casper
#     -- lineas 609-628 del initrd de este medio -- escrito otra vez, a
#     proposito: no se resume, se REPRODUCE, porque lo que decide que esta capa
#     sirva de algo es ese bucle y no una intuicion. La rama que corre es la de
#     MULTI-CAPA (el medio trae LAYERFS_PATH puesto en el initrd), asi que aqui
#     no se mira el orden alfabetico de nada: se mira que el nombre ENCADENE.
cadena_de() {     # nombre de capa -> sus eslabones, de la CORTA a la LARGA
    local ext="${1##*.}" ln="${1%.*}" padre layers=""
    while :; do
        layers="$ln.$ext${layers:+ }$layers"     # casper ANTEPONE cada eslabon
        padre="${ln%.*}"
        [ "$padre" = "$ln" ] && break
        ln="$padre"
    done
    echo "$layers"
}
lowerdir_de() {   # eslabones corta->larga -> el 'lowerdir=' que saldria
    local rofslist="" img mounts=""
    for img in $1; do rofslist="/$img $rofslist"; done   # y ANTEPONE otra vez
    for m in $rofslist; do mounts="$mounts:$m"; done
    echo "${mounts#:}"
}
paso "(a) el nombre de la capa ENCADENA, y la deja la primera de lowerdir"
CAPAS_MEDIO=$(xorriso -indev "$ISO" -find /casper -name '*.squashfs' -- 2>/dev/null \
              | tr -d "'" | sed 's|.*/||')
N_CAPAS=$(printf '%s\n' "$CAPAS_MEDIO" | /usr/bin/grep -c . )
NUESTRA=$(basename "$CAPA")
if [ "$N_CAPAS" -lt 3 ]; then
    fallo "el medio declara $N_CAPAS capas squashfs: no se ha leido nada"
else
    # cada eslabon que NO sea el nuestro tiene que existir en el medio, o casper
    # hace panic y el arranque se acaba ahi. No es un aviso: es el arranque.
    CADENA=$(cadena_de "$NUESTRA"); N_ESL=$(printf '%s\n' $CADENA | /usr/bin/grep -c .)
    FALTAN=""
    for e in $CADENA; do
        [ "$e" = "$NUESTRA" ] && continue
        printf '%s\n' $CAPAS_MEDIO | /usr/bin/grep -qx "$e" || FALTAN="$FALTAN $e"
    done
    PRIM_SI=$(lowerdir_de "$CADENA" | cut -d: -f1)
    # EL CONTROL, con el nombre que se usaba hasta hoy: 'zz-encina.squashfs' no
    # tiene ni un punto que quitar, asi que su cadena es UN eslabon -- el suyo --
    # y debajo no queda sistema ninguno. Tiene que salir MAL.
    CAD_NO=$(cadena_de "zz-encina.squashfs"); N_NO=$(printf '%s\n' $CAD_NO | /usr/bin/grep -c .)
    if [ -n "$FALTAN" ]; then
        fallo "la cadena de '$NUESTRA' nombra eslabones que NO estan en el medio: casper haria panic" \
              "faltan:$FALTAN
cadena: $CADENA"
    elif [ "$PRIM_SI" != "/$NUESTRA" ]; then
        fallo "la capa de Encina no queda la primera de lowerdir" "queda $PRIM_SI de: $(lowerdir_de "$CADENA")"
    elif [ "$N_ESL" -lt 2 ]; then
        fallo "la cadena de '$NUESTRA' tiene $N_ESL eslabon: no cuelga de nada" "$CADENA"
    elif [ "$N_NO" -ne 1 ]; then
        fallo "CONTROL ROTO: 'zz-encina.squashfs' tenia que dar UNA cadena de 1 eslabon y da $N_NO" "$CAD_NO"
    else
        ok "'$NUESTRA': cadena de $N_ESL eslabones, los $((N_ESL-1)) de debajo estan en el medio, y queda la 1a de lowerdir"
        ok "control: 'zz-encina.squashfs' da una cadena de $N_NO eslabon ($CAD_NO) y dejaria al medio sin sistema"
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
# NO se compara contra el nombre del producto escrito aqui: eso lo guardaria en
# un sitio mas. Se comprueban LAS PROPIEDADES, las mismas que el paso 5b de
# fabricar-iso.sh -- que el rotulo no diga Ubuntu, que sea distinto del medio, y
# que la 2a palabra sea un NUMERO DE VERSION, porque refresh.py la usa como canal
# de snap del instalador y con «OS» ahi el instalador se cae EN SILENCIO
# (MEDICIONES.md §4.54h).
paso "(b) el rotulo del icono deja de decir Ubuntu, y la 2a palabra es una version"
xorriso -indev "$ISO" -osirrox on -cpx /.disk/info "$T/" -- >/dev/null 2>&1
DISKINFO_ENCINA="$FUENTE/disk-info"
if [ -f "$T/info" ] && [ -f "$DISKINFO_ENCINA" ]; then
    R_MEDIO=$(release_de "$T/info"); R_NUESTRO=$(release_de "$DISKINFO_ENCINA")
    V2_NUESTRO=$(cut -d' ' -f2 "$DISKINFO_ENCINA"); V2_MEDIO=$(cut -d' ' -f2 "$T/info")
    if printf '%s' "$R_NUESTRO" | grep -qi ubuntu; then
        fallo "el rotulo del icono seguiria diciendo Ubuntu" "nuestro=$R_NUESTRO"
    elif ! printf '%s' "$R_MEDIO" | grep -qi ubuntu; then
        fallo "CONTROL ROTO: la busqueda no encuentra «Ubuntu» ni en el del medio" "medio=$R_MEDIO"
    elif [ "$R_MEDIO" = "$R_NUESTRO" ]; then
        fallo "CONTROL ROTO: el calculo da lo mismo con los dos .disk/info" "$R_NUESTRO"
    elif ! printf '%s' "$V2_NUESTRO" | grep -qE '^[0-9]+(\.[0-9]+)*$'; then
        fallo "la 2a palabra de .disk/info es «$V2_NUESTRO» y tiene que ser un NUMERO DE VERSION" \
              "refresh.py la usa como canal: pediria stable/ubuntu-$V2_NUESTRO y el instalador se caeria en silencio (4.54h)"
    elif ! printf '%s' "$V2_MEDIO" | grep -qE '^[0-9]+(\.[0-9]+)*$'; then
        fallo "CONTROL ROTO: la 2a palabra del .disk/info DEL MEDIO tampoco pasa la regla" "medio=$V2_MEDIO"
    else
        ok "Name=Install $R_NUESTRO  (el del medio da: Install $R_MEDIO) · 2a palabra «$V2_NUESTRO» -> canal stable/ubuntu-$V2_NUESTRO"
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

paso "el nombre de la capa la deja la primera de lowerdir, con su control"
NUESTRA=$(basename "$CAPA")
CADENA=$(cadena_de "$NUESTRA")
if [ "$(lowerdir_de "$CADENA" | cut -d: -f1)" != "/$NUESTRA" ]; then
    fallo "'$NUESTRA' no queda la primera de lowerdir: quedaria TAPADA por las de Ubuntu" \
          "$(lowerdir_de "$CADENA")"
elif [ "$(lowerdir_de "$(cadena_de zz-encina.squashfs)")" = "$(lowerdir_de "$CADENA")" ]; then
    fallo "CONTROL ROTO: el calculo da lo mismo con 'zz-encina.squashfs'" "$(lowerdir_de "$CADENA")"
else
    ok "$NUESTRA: lowerdir=$(lowerdir_de "$CADENA")"
fi

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
