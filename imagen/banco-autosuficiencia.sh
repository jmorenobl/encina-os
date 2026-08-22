#!/usr/bin/env bash
# Encina OS - Bloque 0. EL MEDIO ES AUTOSUFICIENTE? Se contesta con apt, no leyendo.
#
#     ./banco-autosuficiencia.sh --repo <dir> --constructor usuario@vm-linux
#
# LA PREGUNTA, Y ES UNA SOLA: al instalar SIN RED -- que es lo normal, porque en
# el chroot de curtin NO HAY DNS y el propio seed lo mide en su paso 7 --, todo
# lo que 'apt install encina-meta' necesita, ?sale del medio?
#
# LA RESPUESTA ES UNA LINEA DE apt: de la simulacion 'apt-get -s install
# encina-meta', TODA linea 'Inst' tiene que nombrar 'localhost'. Una que no lo
# nombre es un .deb que habria que traer de internet, y un solo .deb que no se
# puede traer ABORTA LA TRANSACCION ENTERA: no entra ninguno de los otros.
#
# POR QUE EXISTE, Y ES LA CASILLA QUE HABRIA AHORRADO UNA INSTALACION ENTERA
# (MEDICIONES.md §4.61, §4.62): el 2026-08-22 una maquina se entrego SIN NINGUNO
# de los cuatro paquetes de Encina porque faltaba UN .deb -- libnss3 -- en los 28
# del medio. Y la simulacion YA LO CANTABA en el seed.log de aquella noche, en el
# paso 9, veintiuna lineas diciendo 'localhost' y una no. Nadie la miraba. Esto
# es esa mirada, hecha guion, y corre en segundos sin arrancar nada.
#
# LAS DOS COSAS QUE HAY QUE CLAVAR PARA QUE ESTO NO SEA CIEGO, y las dos se
# midieron equivocandose primero (§4.62 (h)):
#
#  1. EL 'dpkg status' NO ES EL DE LA MAQUINA DONDE CORRE apt. Si se deja el del
#     constructor, el constructor YA TIENE medio escritorio instalado, la
#     simulacion no pide casi nada y esto da verde sobre un repo roto. El status
#     que vale es EL DE LA BASE QUE SE INSTALA, y se saca del squashfs de la ISO
#     OFICIAL -- minimal.es.squashfs, porque 'source.id' es ubuntu-desktop-minimal
#     y el locale es es_ES (casper/install-sources.yaml del propio medio).
#
#  2. LAS LISTAS DE apt TIENEN QUE SER LAS DE HOY, NO LAS DEL SQUASHFS. Con las
#     cacheadas dentro de la ISO, apt dice "0 not upgraded" y NO PIDE libnss3:
#     ciego. La instalacion de verdad decia "356 not upgraded", porque el
#     instalador refresca las listas por la red de la SESION VIVA (que si tiene
#     red; el que no la tiene es el chroot). O sea que la respuesta DEPENDE DEL
#     DIA, y eso no es un defecto de este banco: es exactamente la deriva del
#     archivo de Ubuntu que causo el fallo. Por eso se refrescan contra el
#     archivo de verdad en cada pasada.
#
# LO QUE ESTE GUION NO DICE: que el medio arranque, ni que la instalacion
# termine, ni que los .deb esten bien construidos. Dice UNA cosa.
#
# POR QUE CRUZA A UNA VM: no hay 'apt' en macOS. Y no se imita el resolutor de
# apt a mano a proposito -- un resolutor casero se equivoca DANDO VERDES, que es
# justo el fallo que este guion existe para no repetir.

set -uo pipefail
export LC_ALL=C   # trampa 2

AQUI=$(cd "$(dirname "$0")" && pwd)
REPO=""; CONSTRUCTOR=""; PAQUETE=""
ISO_OFICIAL=""; CAPA="minimal.es.squashfs"; CONTROL_PKG="simple-scan"; CACHE=""

uso() { sed -n '3,4p' "$0"; exit 2; }
while [ $# -gt 0 ]; do
    case "$1" in
        --repo)            REPO="$2";         shift 2 ;;
        --constructor)     CONSTRUCTOR="$2";  shift 2 ;;
        --paquete)         PAQUETE="$2";      shift 2 ;;
        --iso-oficial)     ISO_OFICIAL="$2";  shift 2 ;;
        --capa)            CAPA="$2";         shift 2 ;;
        --control-paquete) CONTROL_PKG="$2";  shift 2 ;;
        --cache)           CACHE="$2";        shift 2 ;;
        -h|--help)         sed -n '1,45p' "$0"; exit 0 ;;
        *) echo "[FALLO] argumento desconocido: $1"; uso ;;
    esac
done
[ -n "$REPO" ] && [ -n "$CONSTRUCTOR" ] || uso
[ -z "$ISO_OFICIAL" ] && ISO_OFICIAL=$(ls -1 "$AQUI/../medios"/ubuntu-*-desktop-arm64.iso 2>/dev/null | head -1)
[ -z "$CACHE" ] && CACHE="$REPO/.base"

FALLOS=0
fallo() { echo "[FALLO] $*"; FALLOS=$((FALLOS+1)); }
ok()    { echo "[OK]    $*"; }
aviso() { echo "[AVISO] $*"; }

[ -d "$REPO" ]        || { echo "[FALLO] no existe el repo: $REPO"; exit 1; }
[ -f "$REPO/Packages" ] || { echo "[FALLO] el repo no tiene indice Packages: $REPO/Packages
        Lo genera dpkg-scanpackages en el constructor (no existe en macOS)."; exit 1; }
[ -f "$ISO_OFICIAL" ] || { echo "[FALLO] no encuentro la ISO oficial: $ISO_OFICIAL
        La trae imagen/traer-iso-oficial.sh"; exit 1; }
for c in xorriso unsquashfs ssh; do
    command -v "$c" >/dev/null || { echo "[FALLO] falta la herramienta: $c"; exit 1; }
done

SSH_OPTS=(-o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=no)
R() { ssh "${SSH_OPTS[@]}" "$CONSTRUCTOR" "$@"; }

echo "== 1. la referencia: el dpkg status de la base que se instala"
# Se saca UNA VEZ y se cachea; son 8 MB de squashfs y no cambian mientras no
# cambie la ISO oficial. La cache se ata a la huella de la ISO, no a su nombre.
HUELLA_ISO=$(shasum -a 256 "$ISO_OFICIAL" | cut -d' ' -f1)
mkdir -p "$CACHE"
if [ -f "$CACHE/status" ] && [ "$(cat "$CACHE/de-la-iso" 2>/dev/null)" = "$HUELLA_ISO" ]; then
    echo "        cache: $CACHE/status (de la ISO ${HUELLA_ISO:0:12}…)"
else
    rm -rf "$CACHE"; mkdir -p "$CACHE"
    TMPQ=$(mktemp -d) || exit 1
    trap 'rm -rf "$TMPQ"' EXIT
    xorriso -osirrox on -indev "$ISO_OFICIAL" -extract "/casper/$CAPA" "$TMPQ/capa.squashfs" \
        >/dev/null 2>&1 || { echo "[FALLO] no pude sacar /casper/$CAPA de la ISO oficial"; exit 1; }
    unsquashfs -q -d "$TMPQ/x" -no-xattrs "$TMPQ/capa.squashfs" var/lib/dpkg/status \
        >/dev/null 2>&1 || { echo "[FALLO] esa capa no lleva var/lib/dpkg/status"; exit 1; }
    cp "$TMPQ/x/var/lib/dpkg/status" "$CACHE/status" || exit 1
    echo "$HUELLA_ISO" > "$CACHE/de-la-iso"
    rm -rf "$TMPQ"; trap - EXIT
    echo "        sacado de /casper/$CAPA de $(basename "$ISO_OFICIAL")"
fi
N_BASE=$(grep -c '^Package: ' "$CACHE/status")
[ "$N_BASE" -gt 1000 ] || fallo "el status de la base dice $N_BASE paquetes: eso no es una base de escritorio"
ok "la base instalada son $N_BASE paquetes"
# CONTROL de que ese status es de la BASE y no de otra cosa: tiene que decir que
# libnss3 esta instalado -- porque lo esta, y porque es EL paquete de §4.61 --, y
# NO puede decir que encina-meta lo este, que es lo que vamos a pedir.
grep -q '^Package: libnss3$' "$CACHE/status" \
    || fallo "CONTROL ROTO: el status de la base no nombra libnss3"
if grep -q "^Package: encina-meta\$" "$CACHE/status"; then
    fallo "CONTROL ROTO: la base ya trae encina-meta instalado; la simulacion no pediria nada"
else
    ok "control: la base trae libnss3 y NO trae encina-meta, que es lo que se va a pedir"
fi

# LO QUE SE LE PIDE A apt, SI NO SE DICE OTRA COSA: las TRES transacciones que
# el seed hace de verdad contra el repo del medio, y no solo la primera --
#   paso 9     apt install encina-meta
#   paso 11bis apt install firefox=<la version que ofrece el repo local>
#   paso 12    apt install firefox-l10n-es-es
# Van en UNA transaccion porque asi apt las resuelve todas contra la MISMA base,
# que es lo que hace el chroot.
#
# LA QUE NO ESTA, Y NO ES UN OLVIDO: 'full-upgrade' del paso 11. Esa NO puede ser
# autosuficiente y no se pretende que lo sea -- querria actualizar los ~360
# paquetes que el archivo de Ubuntu ha movido desde que se corto la ISO, y el
# medio no los lleva ni debe--. Falla con rc=100 sin red, esta MEDIDO que falla
# (seed.log de §4.61, linea 67803) y el bloque 11bis existe justo para eso. Si
# algun dia se le exige a full-upgrade, esto dira que no con 300 lineas.
#
# Y EL 'firefox' VA CON VERSION EXACTA por el mismo motivo que en 11bis: pedirlo
# por nombre a secas hace que apt elija el .deb de transicion al Snap del archivo
# -- que gana por EPOCH (1:) -- y esto denunciaria una fuente de fuera que el
# producto no usa. Seria una alarma falsa, y una alarma falsa gasta la guarda.
if [ -z "$PAQUETE" ]; then
    VFF=$(sed -n '/^Package: firefox$/,/^$/p' "$REPO/Packages" | sed -n 's/^Version: //p' | head -1)
    if [ -n "$VFF" ]; then
        PAQUETE="encina-meta firefox=$VFF firefox-l10n-es-es"
    else
        PAQUETE="encina-meta firefox-l10n-es-es"
        aviso "el repo no trae firefox en su indice: se valida sin el"
    fi
    echo "        se le pide a apt: $PAQUETE"
fi

echo "== 2. el repo que se va a validar"
NDEB=$(ls -1 "$REPO"/*.deb 2>/dev/null | wc -l | tr -d ' ')
NIDX=$(grep -c '^Filename: ' "$REPO/Packages")
[ "$NIDX" -eq "$NDEB" ] || fallo "Packages describe $NIDX y en el repo hay $NDEB .deb"
ok "$NDEB .deb, y el indice describe $NIDX"

echo "== 3. apt de verdad, en las condiciones del chroot ($CONSTRUCTOR)"
R true 2>/dev/null || { echo "[FALLO] el constructor $CONSTRUCTOR no contesta por ssh"; exit 1; }
R "command -v apt-get >/dev/null" || { echo "[FALLO] el constructor no tiene apt-get"; exit 1; }

REMOTO=".encina-autosuf"
R "rm -rf ~/$REMOTO && mkdir -p ~/$REMOTO/repo ~/$REMOTO/estado/lists/partial ~/$REMOTO/partes ~/$REMOTO/cache" \
    || { echo "[FALLO] no pude preparar el sitio en el constructor"; exit 1; }
# viaja el INDICE, no los 28 .deb: 'apt-get -s' no descarga nada, y son 40 KB
# contra 170 MB. Tambien viaja el status de la base y el sources.list del
# escritorio de Ubuntu, que es el que tendra la maquina instalada.
COPYFILE_DISABLE=1 tar -cf - -C "$REPO" Packages | R "cd ~/$REMOTO/repo && tar -xf -" || { echo "[FALLO] no pude enviar Packages"; exit 1; }
COPYFILE_DISABLE=1 tar -cf - -C "$CACHE" status  | R "cd ~/$REMOTO/estado && tar -xf -" || { echo "[FALLO] no pude enviar el status"; exit 1; }
# el cotejo a los dos lados, que es lo unico que protege de verdad (trampa 24)
HA=$(shasum -a 256 "$REPO/Packages" | cut -d' ' -f1)
HB=$(R "sha256sum ~/$REMOTO/repo/Packages | cut -d' ' -f1")
[ "$HA" = "$HB" ] || fallo "el Packages no llego igual: aqui ${HA:0:16}… alli ${HB:0:16}…"
ok "el indice llego igual (${HA:0:16}…)"

# LAS FUENTES: el repo local del medio, mas las de Ubuntu que lleva la base.
# El repo local va SIN Release a proposito, igual que en el medio: por eso apt lo
# rotula 'localhost', y por eso 'localhost' es la palabra que distingue.
R "cat > ~/$REMOTO/sources.list" <<'FIN'
deb [trusted=yes] file:REMOTO_REPO ./
FIN
R "sed -i \"s|REMOTO_REPO|\$HOME/$REMOTO/repo|\" ~/$REMOTO/sources.list"
R "cat > ~/$REMOTO/partes/ubuntu.sources" <<'FIN'
Types: deb
URIs: http://ports.ubuntu.com/ubuntu-ports/
Suites: noble noble-updates noble-backports
Components: main universe restricted multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

Types: deb
URIs: http://ports.ubuntu.com/ubuntu-ports/
Suites: noble-security
Components: main universe restricted multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
FIN

APTOPS="-o Dir::State=\$HOME/$REMOTO/estado \
        -o Dir::State::status=\$HOME/$REMOTO/estado/status \
        -o Dir::State::lists=\$HOME/$REMOTO/estado/lists \
        -o Dir::Etc::SourceList=\$HOME/$REMOTO/sources.list \
        -o Dir::Etc::SourceParts=\$HOME/$REMOTO/partes \
        -o Dir::Cache=\$HOME/$REMOTO/cache \
        -o APT::Architecture=arm64"

R "LC_ALL=C apt-get update $APTOPS" >/tmp/.autosuf-update 2>&1 \
    || { echo "[FALLO] apt-get update no paso en el constructor"; tail -5 /tmp/.autosuf-update; exit 1; }
NLISTAS=$(R "ls ~/$REMOTO/estado/lists/*_Packages 2>/dev/null | wc -l")
ok "listas refrescadas contra el archivo de hoy: $NLISTAS indices (incluido el del medio)"

simular() {   # imprime las lineas Inst de 'apt-get -s install <lo que se le pase>'
    R "LC_ALL=C apt-get -s install $1 $APTOPS" 2>&1
}
SAL=$(simular "$PAQUETE")
printf '%s\n' "$SAL" | grep -qE '^Inst ' \
    || { echo "[FALLO] la simulacion no produjo ni una linea Inst:"; printf '%s\n' "$SAL" | tail -12; exit 1; }

echo "== 4. LA PREGUNTA: toda linea Inst nombra 'localhost'?"
INST=$(printf '%s\n' "$SAL" | grep -E '^Inst ')
N_INST=$(printf '%s\n' "$INST" | grep -c .)
FUERA=$(printf '%s\n' "$INST" | grep -v 'localhost')
N_FUERA=$(printf '%s\n' "$FUERA" | grep -c . || true)
echo "        $N_INST lineas Inst; $((N_INST - N_FUERA)) nombran localhost"
if [ "$N_FUERA" -eq 0 ]; then
    ok "EL MEDIO ES AUTOSUFICIENTE para '$PAQUETE': ninguna linea sale de fuera"
else
    echo
    echo "        estas NO salen del medio, y una sola de ellas aborta la"
    echo "        transaccion ENTERA cuando no hay red en el chroot:"
    printf '%s\n' "$FUERA" | sed 's/^/          /'
    echo
    echo "        lo que hay que hacer: meterlas en imagen/repo-manifiesto.tsv"
    echo "        con su version y su huella, y rehacer la cosecha."
    fallo "$N_FUERA de $N_INST lineas Inst no salen del medio"
fi

echo "== 5. EL CONTROL, que va DELANTE de creerse el paso 4"
# Una comprobacion que no puede dar sus dos respuestas no es una comprobacion.
# Se le quita al indice UN paquete que SI esta en el archivo de Ubuntu -- asi el
# fallo tiene la misma forma que el de §4.61: apt lo encuentra fuera -- y el
# paso 4 tiene que verlo. Se toca una COPIA del indice, nunca el del repo.
if ! grep -q "^Package: $CONTROL_PKG\$" "$REPO/Packages"; then
    fallo "CONTROL ROTO: $CONTROL_PKG no esta en el repo, no sirve para sabotear
        (se elige otro con --control-paquete)"
else
    R "cd ~/$REMOTO/repo && awk 'BEGIN{RS=\"\";ORS=\"\n\n\"} \$0 !~ /(^|\n)Package: $CONTROL_PKG\n/' Packages > P.sab && mv P.sab Packages"
    Q=$(R "grep -c '^Package: ' ~/$REMOTO/repo/Packages")
    P=$(grep -c '^Package: ' "$REPO/Packages")
    if [ "$Q" -ne $((P - 1)) ]; then
        fallo "CONTROL ROTO: el sabotaje no saboteo ($P -> $Q, se esperaba $((P-1)))"
    else
        R "LC_ALL=C apt-get update $APTOPS" >/dev/null 2>&1
        SAB=$(simular "$PAQUETE" | grep -E '^Inst ' | grep -v localhost)
        if printf '%s\n' "$SAB" | grep -q "^Inst $CONTROL_PKG "; then
            ok "control: quitado $CONTROL_PKG del indice, el paso 4 lo senala"
            printf '%s\n' "$SAB" | grep "^Inst $CONTROL_PKG " | sed 's/^/          /'
        else
            fallo "CONTROL ROTO: sin $CONTROL_PKG en el indice, el paso 4 NO lo senala.
        Entonces su [OK] de arriba no demuestra nada."
        fi
    fi
fi
R "rm -rf ~/$REMOTO" >/dev/null 2>&1

echo
if [ "$FALLOS" -eq 0 ]; then
    ok "banco de autosuficiencia: $N_INST paquetes, todos del medio"
    exit 0
fi
echo "[FALLO] el banco de autosuficiencia NO pasa: $FALLOS fallos"
exit 1
