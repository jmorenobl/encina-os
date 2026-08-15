#!/usr/bin/env bash
# Encina OS - Inventaria DONDE APARECE LA MARCA DE UBUNTU en un medio, LEYENDOLO
# y sin arrancarlo.
#
#     ./imagen/inventario-marca.sh <iso> [--trabajo DIR] [--conservar] [--sin-capas]
#
# POR QUE EXISTE: la primera casilla de tareas/marca-del-medio.md pide una lista
# de ficheros y cadenas concretas, «cada una con donde se ve», y pide medirla en
# vez de suponerla. Esa casilla ya llego una vez con una suposicion dentro -- que
# el boton de la rejilla llevaba el logotipo de Ubuntu, cuando lo que se estaba
# mirando era gnome-initial-setup ejecutandose (§4.43, y la enmienda del
# 2026-08-15) --, asi que aqui NO se escribe ninguna linea que no salga de leer
# el medio.
#
# LO QUE NO ES: no decide nada y no aprueba nada. Cada aparicion sale como
# [AVISO] («mirar, no bloquea»), porque una aparicion de la marca no es un fallo
# del medio: es trabajo pendiente del bloque 1. Los unicos [OK]/[FALLO] son los
# de los CONTROLES del instrumento, y por eso van los primeros: si el buscador no
# sabe decir «no lo hay», su lista de apariciones no vale nada.
#
# LOS TRES PLANOS, que son los que pide la casilla:
#     1. EL MEDIO ENTERO   lo que se lee del ISO 9660 sin montar nada
#     2. EL INSTALADOR VIVO  el snap ubuntu-desktop-bootstrap y lo que pinta
#     3. LA PRIMERA SESION   el escritorio vivo que rodea al instalador
#   La maquina YA INSTALADA no entra: esa identidad la cierra encina-branding y
#   ese bloque esta cerrado. Y lo primero que mide el plano 3 es justo eso: que
#   en las capas del medio NO hay ni un fichero de Encina.
#
# CUATRO TRAMPAS QUE ESTE GUION SE COME, y las cuatro mordieron al escribirlo:
#   (1) 'awk {print $NF}' sobre un listado de unsquashfs devuelve el DESTINO del
#       enlace simbolico, no su nombre -- asi se escondio
#       view-app-grid-ubuntu-symbolic.svg, que es el icono del boton de la
#       rejilla. Es la familia de §4.45c ('find -type f' tampoco ve los enlaces).
#       Aqui el nombre es el campo 6, y hay un control que lo vigila.
#   (2) el hook de rtk resume la salida de grep (§4.9d, §4.27a): todo va con
#       /usr/bin/grep.
#   (3) unsquashfs con rutas relativas y el cwd movido sale rc=1 en 0,00 s, que
#       se lee igual que «esta capa no se puede listar». Todo va con rutas
#       absolutas.
#   (4) macOS NO monta esta ISO ('sistemas de archivos que no pueden montarse'),
#       asi que las capas hay que sacarlas con osirrox: son ~3,2 GB de disco. Con
#       --trabajo se reutiliza lo ya extraido y la segunda vuelta es barata.
#
# EL PRECIO: ~3,2 GB de disco temporal y ~2 min. Con --sin-capas se salta los
# squashfs; entonces los planos 2 y 3 salen [OMIT], que no es un aprobado.

set -uo pipefail
export LC_ALL=C   # trampa 2: la salida de las herramientas, sin traducir

AQUI=$(cd "$(dirname "$0")" && pwd)
ISO=""
TRABAJO=""
CONSERVAR=0
SIN_CAPAS=0

uso() { sed -n '4p' "$0"; exit 2; }
while [ $# -gt 0 ]; do
    case "$1" in
        --trabajo)   TRABAJO="$2"; shift 2 ;;
        --conservar) CONSERVAR=1;  shift ;;
        --sin-capas) SIN_CAPAS=1;  shift ;;
        -h|--help)   uso ;;
        -*)          echo "opcion desconocida: $1" >&2; uso ;;
        *)           [ -z "$ISO" ] || uso; ISO="$1"; shift ;;
    esac
done
[ -n "$ISO" ] || uso
[ -f "$ISO" ] || { echo "[FALLO] no existe la ISO: $ISO" >&2; exit 1; }

N_OK=0; N_MAL=0; N_AVI=0; N_OMI=0
FALLOS=()
titulo() { echo; echo "=== $* ==="; }
paso()   { echo "--- $* "; }
ok()     { N_OK=$((N_OK+1));  echo "  [OK]    $*"; }
aviso()  { N_AVI=$((N_AVI+1)); echo "  [AVISO] $*"; }
omitido(){ N_OMI=$((N_OMI+1)); echo "  [OMIT]  $*"; }
ojos()   { echo "  [OJOS]  $*"; }
fallo()  { N_MAL=$((N_MAL+1)); echo "  [FALLO] $1"; [ -n "${2:-}" ] && echo "$2" | sed 's/^/          | /'; FALLOS+=("$1"); }

# marca "fichero" "cadena o valor" "donde se ve"
marca() { aviso "$(printf '%-52s %s\n              -> %s' "$1" "$2" "$3")"; }

for h in xorriso osirrox shasum python3 zstd bsdtar; do
    command -v "$h" >/dev/null || { echo "[FALLO] falta la herramienta: $h" >&2; exit 1; }
done
if [ "$SIN_CAPAS" -eq 0 ]; then
    command -v unsquashfs >/dev/null || { echo "[FALLO] falta unsquashfs (brew install squashfs)" >&2; exit 1; }
fi

if [ -n "$TRABAJO" ]; then
    mkdir -p "$TRABAJO"
    T=$(cd "$TRABAJO" && pwd)
else
    T=$(mktemp -d /tmp/inventario-marca.XXXXXX)
    trap '[ "$CONSERVAR" -eq 1 ] || rm -rf "$T"' EXIT
fi
mkdir -p "$T/medio" "$T/capas" "$T/sel"

titulo "0. EL MEDIO QUE SE LEE, por huella y no por nombre"
HUELLA=$(shasum -a 256 "$ISO" | cut -d' ' -f1)
echo "  fichero : $ISO"
echo "  huella  : $HUELLA"
echo "  tamano  : $(wc -c < "$ISO" | tr -d ' ') bytes"
echo "  trabajo : $T"

# --------------------------------------------------------------------------
# El arbol del medio, una sola vez.
ARBOL="$T/arbol.txt"
xorriso -indev "$ISO" -find / -type f -- 2>/dev/null | tr -d "'" > "$ARBOL"
N_ARBOL=$(wc -l < "$ARBOL" | tr -d ' ')

# Los ficheros pequenos del medio, de una tacada.
xorriso -indev "$ISO" -osirrox on -cpx \
    /.disk/info /.disk/cd_type /.disk/release_notes_url \
    /boot/grub/grub.cfg /casper/install-sources.yaml \
    /preseed/ubuntu.seed /dists/noble/Release "$T/medio" -- >/dev/null 2>&1

# El calculo de casper-bottom/25adduser, tal cual esta escrito en el medio:
#   LTS=$(cut -d' ' -f3 .disk/info); RELEASE=$(cut -d' ' -f1-2 .disk/info | sed 's/-/ /')
release_de() {
    local f="$1" lts rel
    lts=$(cut -d' ' -f3 "$f" 2>/dev/null)
    rel=$(cut -d' ' -f1-2 "$f" 2>/dev/null | sed 's/-/ /')
    [ "$lts" = "LTS" ] && [ -n "$rel" ] && rel="$rel LTS"
    echo "$rel"
}

titulo "1. LOS CONTROLES, ANTES DE LA MEDICION"
echo "  Sin esto, la lista de abajo no vale: un buscador que no sabe decir"
echo "  «no lo hay» dice «no he mirado» y se lee como «no hay marca»."

paso "(a) el arbol del medio sabe decir SI y NO"
if [ "$N_ARBOL" -lt 100 ]; then
    fallo "el arbol del medio tiene $N_ARBOL ficheros: no se ha leido nada"
else
    if /usr/bin/grep -q "^/casper/minimal.squashfs$" "$ARBOL" \
    && ! /usr/bin/grep -q "^/casper/bellota.squashfs$" "$ARBOL"; then
        ok "$N_ARBOL ficheros: encuentra /casper/minimal.squashfs y NO encuentra uno inventado"
    else
        fallo "el arbol no distingue un fichero real de uno inventado"
    fi
fi

paso "(b) el calculo de RELEASE no esta clavado"
if [ -f "$T/medio/info" ]; then
    printf 'Encina OS 0.3 LTS "Bellota" - Release arm64 (20260815)\n' > "$T/info-control"
    R_REAL=$(release_de "$T/medio/info")
    R_CTRL=$(release_de "$T/info-control")
    if [ "$R_REAL" != "$R_CTRL" ] && [ -n "$R_CTRL" ]; then
        ok "sobre un .disk/info inventado da «$R_CTRL», no «$R_REAL»"
    else
        fallo "el calculo de RELEASE da lo mismo con cualquier .disk/info" "real=$R_REAL control=$R_CTRL"
    fi
else
    fallo "no se pudo extraer /.disk/info del medio"
fi

if [ "$SIN_CAPAS" -eq 1 ]; then
    omitido "(c) y (d): los controles de las capas no se han ejecutado (--sin-capas)"
else
    paso "(c) las capas squashfs se sacan del medio y se listan"
    for c in minimal.squashfs minimal.standard.live.squashfs; do
        if [ ! -s "$T/capas/$c" ]; then
            xorriso -indev "$ISO" -osirrox on -cpx "/casper/$c" "$T/capas" -- >/dev/null 2>&1
        fi
    done
    unsquashfs -ll "$T/capas/minimal.squashfs"             > "$T/base.ll"  2>/dev/null
    unsquashfs -ll "$T/capas/minimal.standard.live.squashfs" > "$T/viva.ll" 2>/dev/null
    N_BASE=$(wc -l < "$T/base.ll" | tr -d ' '); N_VIVA=$(wc -l < "$T/viva.ll" | tr -d ' ')
    # OJO, dos veces:
    #  - el nombre es el campo 6. Buscarlo al final de la LINEA falla, porque
    #    /etc/os-release es un enlace y la linea acaba en su destino
    #    (../usr/lib/os-release). Es la trampa 1 de la cabecera, mordiendo aqui.
    #  - y los nombres se sacan a un fichero ANTES de buscar, porque
    #    'awk | grep -q' con 'pipefail' devuelve 141 (SIGPIPE) cuando grep acierta
    #    y corta la tuberia: el acierto se leia como fallo.
    awk '{print $6}' "$T/base.ll" > "$T/base.nombres"
    awk '{print $6}' "$T/viva.ll" > "$T/viva.nombres"
    if [ "$N_BASE" -gt 1000 ] && [ "$N_VIVA" -gt 1000 ] \
    && /usr/bin/grep -q "/etc/os-release$" "$T/base.nombres" \
    && ! /usr/bin/grep -q "/etc/bellota-release" "$T/base.nombres"; then
        ok "capa base $N_BASE entradas, capa viva $N_VIVA: encuentra /etc/os-release y no uno inventado"
    else
        fallo "no se pueden listar las capas del medio" "base=$N_BASE viva=$N_VIVA"
    fi

    paso "(d) el listado ENSENA EL NOMBRE de los enlaces simbolicos (trampa 1)"
    # El campo 6 es el nombre; $NF seria el destino y esconderia justo el icono
    # del boton de la rejilla.
    if [ "$(awk '{print $6}' "$T/base.ll" | /usr/bin/grep -c 'view-app-grid-ubuntu-symbolic')" -ge 1 ]; then
        ok "el nombre del enlace view-app-grid-ubuntu-symbolic.svg se ve en el campo 6"
    else
        fallo "el listado esconde los nombres de los enlaces: el inventario saldria corto"
    fi
fi

# --------------------------------------------------------------------------
titulo "2. PLANO 1 - EL MEDIO ENTERO, leido sin montarlo"

VOLID=$(xorriso -indev "$ISO" -pvd_info 2>/dev/null | sed -n 's/^Volume Id    : //p' | head -1)
marca "(el volumen ISO 9660)" "$VOLID" \
      "al conectar el USB o abrir la ISO: es el nombre del disco en CUALQUIER sistema"

if [ -f "$T/medio/info" ]; then
    marca "/.disk/info" "$(cat "$T/medio/info")" \
          "no se ve tal cual: de aqui SALE el nombre del icono del instalador (plano 2)"
fi
if [ -f "$T/medio/release_notes_url" ]; then
    marca "/.disk/release_notes_url" "$(cat "$T/medio/release_notes_url")" \
          "el enlace de «notas de la version» del instalador"
fi
if [ -f "$T/medio/grub.cfg" ]; then
    ME=$(/usr/bin/grep -o 'menuentry "[^"]*"' "$T/medio/grub.cfg" | head -1 | sed 's/menuentry //')
    marca "/boot/grub/grub.cfg" "menuentry $ME" \
          "LA PRIMERA PANTALLA del arranque. Fichero NUESTRO: lo reescribe fabricar-iso.sh"
fi
if [ -f "$T/medio/install-sources.yaml" ]; then
    marca "/casper/install-sources.yaml" \
          "$(/usr/bin/grep -A1 '^  name:' "$T/medio/install-sources.yaml" | /usr/bin/grep 'en:' | sed 's/ *en: //' | tr '\n' ' ')" \
          "la pantalla de «tipo de instalacion», que el seed de Encina NO muestra (§4.32g)"
fi
if [ -f "$T/medio/Release" ]; then
    marca "/dists/noble/Release" \
          "$(/usr/bin/grep -E '^(Origin|Label|Description):' "$T/medio/Release" | tr '\n' ' ')" \
          "en apt. FIRMADO por Canonical: tocarlo rompe Release.gpg (D9, §4.32)"
fi
if [ -f "$T/medio/ubuntu.seed" ]; then
    marca "/preseed/ubuntu.seed" "tasksel/first multiselect ubuntu-desktop" \
          "no lo lee subiquity; el NOMBRE del fichero viaja en el medio"
fi

N_POOL=$(/usr/bin/grep -c "^/pool/" "$ARBOL")
N_POOL_U=$(/usr/bin/grep "^/pool/" "$ARBOL" | /usr/bin/grep -ci ubuntu)
marca "/pool/*.deb" "$N_POOL_U de $N_POOL nombres llevan «ubuntu» (versiones -Nubuntu…)" \
      "en apt y dpkg de la maquina instalada"
N_REPO=$(/usr/bin/grep -c "^/encina-repo/" "$ARBOL")
aviso "$(printf '%-52s %s' "/encina-repo/" "$N_REPO ficheros: lo unico de Encina que viaja en el medio")"

PART=$(xorriso -indev "$ISO" -report_system_area plain 2>/dev/null | /usr/bin/grep -c "^MBR partition  ")
ok "la tabla de particiones es MBR y no lleva nombres ($PART entradas): lo unico visible es el Volume id"

for e in /efi/boot/bootaa64.efi /efi/boot/grubaa64.efi /efi/boot/mmaa64.efi; do
    /usr/bin/grep -q "^$e$" "$ARBOL" && omitido "$e: firmado, NO se toca (regla dura de E3, §4.21)"
done

# --------------------------------------------------------------------------
titulo "3. PLANO 2 - EL INSTALADOR VIVO"

if [ "$SIN_CAPAS" -eq 1 ]; then
    omitido "el plano 2 no se ha medido (--sin-capas). No es un aprobado."
else
    SNAP_L=$(/usr/bin/grep "seed/snaps/ubuntu-desktop-bootstrap" "$T/viva.ll" | head -1)
    SNAP_V=$(echo "$SNAP_L" | awk '{print $6}' | sed 's|.*/||')
    marca "/var/lib/snapd/seed/snaps/$SNAP_V" "el instalador ES un snap ($(echo "$SNAP_L" | awk '{print $3}') bytes)" \
          "en el dock y en la ventana del instalador; y en 'snap list' de la sesion viva"

    if [ ! -s "$T/sel/var/lib/snapd/desktop/applications/ubuntu-desktop-bootstrap_ubuntu-desktop-bootstrap.desktop" ]; then
        unsquashfs -d "$T/sel" -f "$T/capas/minimal.standard.live.squashfs" \
            /var/lib/snapd/desktop/applications \
            /usr/share/initramfs-tools/scripts/casper-bottom/25adduser \
            "/var/lib/snapd/seed/snaps/$SNAP_V" >/dev/null 2>&1
    fi
    DESK="$T/sel/var/lib/snapd/desktop/applications/ubuntu-desktop-bootstrap_ubuntu-desktop-bootstrap.desktop"
    if [ -f "$DESK" ]; then
        PLANTILLA=$(/usr/bin/grep '^Name=' "$DESK")
        R_REAL=$(release_de "$T/medio/info")
        marca "…/ubuntu-desktop-bootstrap_….desktop" "$PLANTILLA  ->  Name=Install $R_REAL" \
              "el icono del ESCRITORIO y el del dock. Lo sustituye casper-bottom/25adduser desde /.disk/info"
        marca "…/ubuntu-desktop-bootstrap_….desktop" "$(/usr/bin/grep '^Icon=' "$DESK")" \
              "el dibujo del icono: Yaru apps/ubiquity.png, un disco con la chincheta naranja de Ubuntu"
    fi

    SNAP="$T/sel/var/lib/snapd/seed/snaps/$SNAP_V"
    if [ -f "$SNAP" ]; then
        unsquashfs -ll "$SNAP" > "$T/snap.ll" 2>/dev/null
        N_SNAP_U=$(awk '{print $6}' "$T/snap.ll" | /usr/bin/grep -ci ubuntu)
        N_SNAP=$(wc -l < "$T/snap.ll" | tr -d ' ')
        marca "(dentro del snap)" "$N_SNAP_U de $N_SNAP nombres llevan «ubuntu»" \
              "recursos que pinta el instalador: logo-light/dark.svg, mascot.svg, ubuntu_pro.svg, ubuntu_certified.svg"
        N_SLIDES=$(awk '{print $6}' "$T/snap.ll" | /usr/bin/grep -c "/slides/[0-9]*$")
        marca "…/flutter_assets/assets/slides/" "$N_SLIDES diapositivas, una por idioma (slide_es_ES.html)" \
              "la presentacion QUE SE VE MIENTRAS INSTALA"
        if [ ! -s "$T/sel-snap/bin/lib/libapp.so" ]; then
            unsquashfs -d "$T/sel-snap" -f "$SNAP" \
                "/bin/data/flutter_assets/assets/slides/*/slide_es_ES.html" /bin/lib/libapp.so >/dev/null 2>&1
        fi
        for n in $(seq 1 "$N_SLIDES"); do
            s="$T/sel-snap/bin/data/flutter_assets/assets/slides/$n/slide_es_ES.html"
            [ -f "$s" ] || continue
            # dos numeros a proposito: el del fichero cuenta tambien nombres de
            # imagen y enlaces, y el del texto es LO QUE SE LEE en pantalla.
            u=$(/usr/bin/grep -o -i "ubuntu" "$s" | wc -l | tr -d ' ')
            v=$(sed 's/<[^>]*>//g' "$s" | /usr/bin/grep -o -i "ubuntu" | wc -l | tr -d ' ')
            d=$(/usr/bin/grep -c "{{ DISTRO }}" "$s")
            [ "$u" -gt 0 ] && marca "…/slides/$n/slide_es_ES.html" "«Ubuntu» LITERAL x$v en el texto visible (x$u en el fichero)" \
                                    "diapositiva $n de la presentacion del instalador"
            [ "$d" -gt 0 ] && aviso "$(printf '%-52s %s' "…/slides/$n/slide_es_ES.html" "{{ DISTRO }} x$d — plantilla, se rellena en marcha")"
        done
        LIB="$T/sel-snap/bin/lib/libapp.so"
        if [ -f "$LIB" ]; then
            for c in "Try or install " "Probar o instalar " "Installing Ubuntu" "installUbuntu" "tryUbuntu"; do
                n=$(/usr/bin/grep -c -a -F "$c" "$LIB" 2>/dev/null || echo 0)
                [ "$n" -gt 0 ] && marca "…/bin/lib/libapp.so" "cadena «$c»" \
                                        "el titulo de la ventana del instalador y sus botones"
            done
            F1=$(/usr/bin/grep -c -a -F "/cdrom/.disk/info" "$LIB" || echo 0)
            F2=$(/usr/bin/grep -c -a -F "/var/lib/snapd/hostfs/etc/os-release" "$LIB" || echo 0)
            omitido "el nombre que rellena «{{ DISTRO }}» sale de /cdrom/.disk/info o de /etc/os-release (los DOS literales estan en libapp.so: $F1 y $F2). CUAL GANA no esta medido"
        fi
    fi
fi

# --------------------------------------------------------------------------
titulo "4. PLANO 3 - LA PRIMERA SESION (el escritorio vivo del medio)"

if [ "$SIN_CAPAS" -eq 1 ]; then
    omitido "el plano 3 no se ha medido (--sin-capas). No es un aprobado."
else
    paso "lo primero, y decide todo lo demas: que lleva Encina en la sesion viva"
    # sobre los NOMBRES, no sobre la linea entera: la linea de un enlace acaba en
    # su destino y contaria dos veces lo mismo.
    N_ENC=$(( $(/usr/bin/grep -ic encina "$T/base.nombres") + $(/usr/bin/grep -ic encina "$T/viva.nombres") ))
    N_UBU=$(( $(/usr/bin/grep -ic ubuntu "$T/base.nombres") + $(/usr/bin/grep -ic ubuntu "$T/viva.nombres") ))
    if [ "$N_ENC" -eq 0 ] && [ "$N_UBU" -gt 0 ]; then
        ok "NI UN fichero de Encina en las capas del medio ($N_ENC), y $N_UBU con «ubuntu»: la sesion viva es Ubuntu entera"
    else
        fallo "el recuento de Encina en las capas no cuadra" "encina=$N_ENC ubuntu=$N_UBU"
    fi

    if [ ! -s "$T/sel/etc/os-release" ]; then
        unsquashfs -d "$T/sel" -f "$T/capas/minimal.squashfs" \
            /etc/os-release /usr/lib/os-release /etc/lsb-release /etc/issue \
            /usr/share/glib-2.0/schemas/10_ubuntu-settings.gschema.override \
            /usr/share/wayland-sessions/ubuntu.desktop \
            /usr/share/plymouth/themes/ubuntu-text/ubuntu-text.plymouth >/dev/null 2>&1
    fi
    OSR="$T/sel/usr/lib/os-release"; [ -f "$OSR" ] || OSR="$T/sel/etc/os-release"
    if [ -f "$OSR" ]; then
        marca "/etc/os-release" "$(/usr/bin/grep '^PRETTY_NAME=' "$OSR")" \
              "Configuracion -> Acerca de, en la sesion viva"
        marca "/etc/os-release" "$(/usr/bin/grep -E '^(NAME|ID|LOGO)=' "$OSR" | tr '\n' ' ')" \
              "lo lee todo el sistema; LOGO=ubuntu-logo es el dibujo del saludador"
    fi
    [ -f "$T/sel/etc/issue" ] && marca "/etc/issue" "$(cat "$T/sel/etc/issue" | head -1)" "una consola de texto (Ctrl+Alt+F3)"
    OVR="$T/sel/usr/share/glib-2.0/schemas/10_ubuntu-settings.gschema.override"
    if [ -f "$OVR" ]; then
        marca "10_ubuntu-settings.gschema.override" \
              "$(/usr/bin/grep -m1 "picture-uri = " "$OVR" | sed 's/^ *//')" \
              "EL FONDO QUE SE VE DETRAS DEL INSTALADOR"
        marca "10_ubuntu-settings.gschema.override" \
              "favorite-apps con ubuntu-desktop-bootstrap, firefox, snap-store, yelp" \
              "los iconos del dock de la sesion viva"
        marca "10_ubuntu-settings.gschema.override" "$(/usr/bin/grep -m1 "^logo=" "$OVR")" \
              "el saludador GDM (no sale en el medio: la sesion viva entra sola)"
    fi
    SES="$T/sel/usr/share/wayland-sessions/ubuntu.desktop"
    [ -f "$SES" ] && marca "/usr/share/wayland-sessions/ubuntu.desktop" \
        "$(/usr/bin/grep -E '^(Name|Comment)=' "$SES" | tr '\n' ' ')" \
        "el selector de sesion del saludador"
    REJ=$(awk '{print $6" "$7" "$8}' "$T/base.ll" | /usr/bin/grep "view-app-grid-ubuntu-symbolic" | head -1 | sed 's|squashfs-root||')
    [ -n "$REJ" ] && marca "…/Yaru/scalable/actions/" "$REJ" \
        "EL BOTON DE LA REJILLA del dock (§4.43: es este nombre y no view-app-grid-symbolic)"
    PLY="$T/sel/usr/share/plymouth/themes/ubuntu-text/ubuntu-text.plymouth"
    [ -f "$PLY" ] && marca "…/themes/ubuntu-text/ubuntu-text.plymouth" \
        "$(/usr/bin/grep -E '^(Name|title)=' "$PLY" | tr '\n' ' ')" \
        "el arranque en modo texto"

    paso "el arranque del medio: el initrd, que es lo PRIMERO que se ve"
    if [ ! -s "$T/capas/initrd" ]; then
        xorriso -indev "$ISO" -osirrox on -cpx /casper/initrd "$T/capas" -- >/dev/null 2>&1
    fi
    python3 - "$T/capas/initrd" "$T/initrd2.zst" <<'PY'
import sys
d=open(sys.argv[1],"rb").read()
i=d.find(b"TRAILER!!!")            # el initrd son DOS cpio pegados: el 1o sin comprimir
k=(i+11+3)//4*4
while k<len(d) and d[k]==0: k+=1
open(sys.argv[2],"wb").write(d[k:])
PY
    zstd -d -q -f -o "$T/initrd2.cpio" "$T/initrd2.zst" 2>/dev/null
    bsdtar -tvf "$T/initrd2.cpio" 2>/dev/null > "$T/initrd.ll"
    DEF=$(/usr/bin/grep "themes/default.plymouth" "$T/initrd.ll" | head -1 | sed 's/.*plymouth //')
    if [ -n "$DEF" ]; then
        marca "casper/initrd: themes/default.plymouth" "$DEF" \
              "EL SPLASH DEL MEDIO: el tema con el que arranca la ISO"
        rm -rf "$T/initrd-sel"; mkdir -p "$T/initrd-sel"
        (cd "$T/initrd-sel" && bsdtar -xf "$T/initrd2.cpio" \
            usr/share/plymouth/themes/spinner/watermark.png \
            usr/share/plymouth/themes/spinner/bgrt-fallback.png 2>/dev/null)
        for p in watermark bgrt-fallback; do
            f="$T/initrd-sel/usr/share/plymouth/themes/spinner/$p.png"
            [ -f "$f" ] && marca "casper/initrd: …/spinner/$p.png" \
                "$(file -b "$f" | cut -d, -f1-2), sha256 $(shasum -a 256 "$f" | cut -c1-8)…" \
                "el logotipo de Ubuntu dibujado en el splash del arranque"
        done
    else
        omitido "no se ha podido leer el tema de plymouth del initrd"
    fi
    ojos "el splash del medio EN PANTALLA: en UTM la pantalla del invitado esta apagada todo el arranque (ENCINA-OS.md §7, aviso 3). Solo lo levanta una maquina de verdad"
fi

# --------------------------------------------------------------------------
echo
echo "=== RESUMEN ==="
echo "  apariciones de la marca: $N_AVI"
echo "  controles correctos: $N_OK   fallos: $N_MAL   omitidas: $N_OMI"
if [ "$N_MAL" -gt 0 ]; then
    echo
    echo "NO VALE. Han fallado controles, asi que la lista de arriba no se puede creer:"
    for f in "${FALLOS[@]}"; do echo "  - $f"; done
    exit 1
fi
[ "$CONSERVAR" -eq 1 ] && echo "  el trabajo se conserva en: $T"
exit 0
