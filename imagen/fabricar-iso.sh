#!/usr/bin/env bash
# Encina OS - E3. Fabrica la ISO que se entrega, EN MACOS.
#
#     ./fabricar-iso.sh [--iso <oficial.iso>] --repo <dir> --salida <encina.iso>
#                       [--capa <minimal.standard.live.encina.squashfs>]
#                       [--sin-capa] [--sin-volid] [--sin-info] [--sin-menu]
#                       [--info-crudo <fichero>]   <- MEDIO DE DIAGNOSTICO
#     ./fabricar-iso.sh --leer-mecanismos <alguna.iso>   <- solo lee, no fabrica
#
# LAS CUATRO BANDERAS «--sin-*» SON PARA BISECAR, NO PARA EL PRODUCTO. Cada una
# quita UNO de los cuatro mecanismos de marca del medio (D23) y deja los otros
# tres. Existen porque el 2026-08-17 no se pudo hacer justo eso: el instalador
# grafico se cae con los cuatro puestos y ARRANCA sin ninguno -- medido en tres
# ISOs y bundles identicos, MEDICIONES.md §4.54i --, o sea que la regresion esta
# dentro de este grupo, y sin poder quitarlos de uno en uno no hay forma de
# saber cual. El paso 13 LEE DEL MEDIO CONSTRUIDO que mecanismos lleva y lo
# coteja con lo que se pidio, con su control sobre la ISO oficial: sin eso, una
# bandera que no hiciera nada daria un bisecado entero equivocado.
#
# El «locale=es_ES.UTF-8» del grub.cfg NO tiene bandera y no es un descuido: ya
# viajaba en 1224b5b1…, que es una de las dos ISOs cuyo instalador arranca, asi
# que no esta bajo sospecha.
#
# --iso vale por defecto medios/ubuntu-24.04.4-desktop-arm64.iso, que es donde
# la deja imagen/traer-iso-oficial.sh. Ese directorio esta en .gitignore: la ISO
# oficial son 3,3 GiB y no viaja en el clon, pero la ORDEN de traerla si.
#
# QUE HACE: coge la ISO oficial de Ubuntu, le ANADE lo de Encina y MODIFICA TRES
# ficheros, ni uno mas. Los sitios estan nombrados aqui uno a uno porque la
# definicion de terminado de E3 se comprueba contra esta lista, y porque desde
# hoy esta lista es tambien la de la marca del medio (D22 y D23).
#
# ANADE:
#     /autoinstall.yaml   <- imagen/autoinstall.yaml, que es donde el
#                            instalador lo busca: /cdrom/autoinstall.yaml, el
#                            QUINTO sitio de select_autoinstall (MEDICIONES.md
#                            §4.21c), leido en el codigo que viaja en la ISO
#     /encina-repo/       <- los cuatro .deb de Encina, TODO lo que hasta E3
#                            bajaba de internet (el nivel 3 de MEDICIONES.md
#                            §4.27: el JRE de autofirma, libnss3-tools,
#                            hunspell-es, el navegador de Mozilla y su idioma,
#                            la tienda y el escaner) y su indice Packages
#     /casper/minimal.standard.live.encina.squashfs <- LA CAPA DE MARCA, que la
#                            hace capa-marca.sh y que es lo que hace que la
#                            SESION VIVA y el INSTALADOR digan Encina (D23,
#                            casilla 3 de tareas/marca-del-medio.md).
#                            EL NOMBRE NO ES TIPOGRAFIA, ES LA CADENA: casper
#                            entra por su rama de multi-capa -- el initrd trae
#                            LAYERFS_PATH puesto -- y construye la lista QUITANDO
#                            PUNTOS del nombre, exigiendo que CADA ESLABON exista
#                            como fichero o hace 'panic'. Por eso cuelga de
#                            'minimal.standard.live' y no se puede llamar de otra
#                            forma. Leido en el casper de este medio, §4.58b.
#                            Y NO BASTA CON QUE VIAJE: hay que nombrarla en la
#                            linea del nucleo (mas abajo, layerfs-path=) o el
#                            medio la lleva y NO LA MONTA -- que es exactamente
#                            lo que paso del 2026-08-15 al 20 (§4.54e).
#                            Hasta el 2026-08-20 se llamaba 'zz-encina.squashfs',
#                            y se deja escrito al lado lo que se creia: «casper
#                            monta todos los *.squashfs de /casper y el ULTIMO
#                            alfabeticamente manda» (§4.52b). Era falso.
#
# MODIFICA, y hasta el 2026-08-10 no modificaba nada:
#     /boot/grub/grub.cfg <- 'layerfs-path=<la capa>' en la linea del nucleo, que
#                            es LO UNICO que hace que la capa de marca se monte
#                            (§4.58): el /init lee conf.d en su paso 94 y
#                            casper reexporta la variable en parse_cmdline
#                            (casper:909), asi que LA LINEA DEL NUCLEO PISA al
#                            valor del initrd y no hay que tocar el initrd.
#                            El nombre sale del fichero de la capa, no se
#                            escribe aqui: una sola fuente.
#                       y <- 'locale=es_ES.UTF-8' en la linea del nucleo, que es
#                            lo que pone EL INSTALADOR en espanol. Sin esto la
#                            ISO recibe en ingles a quien la instala, aunque la
#                            maquina que sale quede en espanol: es la NOVENA
#                            casilla de AGENTS.md §6ter.3, anadida despues de
#                            marcar las ocho porque las ocho la dejaban pasar.
#                            El mecanismo esta LEIDO, no supuesto, en el
#                            casper de esta misma ISO: scripts/casper-bottom/
#                            14locales recorre TODOS los tokens de /proc/cmdline
#                            y con 'locale=*' escribe LANG en el
#                            /etc/default/locale de la SESION VIVA y corre
#                            locale-gen dentro de ella.
#                            Y DESDE EL 2026-08-15 el titulo del menu tambien:
#                            'Try or Install Ubuntu' -> 'Probar o instalar
#                            Encina OS'. Es la PRIMERISIMA pantalla del
#                            arranque y es pila A de D22.
#     /.disk/info         <- el fichero mas barato del medio -- 60 bytes el de
#                            Ubuntu, 43 el de Encina -- y vale TRES cosas, las
#                            tres
#                            LEIDAS en el casper de este medio (§4.51c, §4.52a):
#                            casper-bottom/25adduser saca de aqui el RELEASE que
#                            sustituye en 'Name=Install RELEASE', o sea EL
#                            ROTULO DEL ICONO DEL INSTALADOR; scripts/casper
#                            saca de la primera palabra el FLAVOUR, que es el
#                            usuario y el nombre de maquina de la sesion viva
#                            (pasa de 'ubuntu' a 'encina'); y
#                            casper-bottom/57pollinate saca de los parentesis
#                            del final el numero de serie -- por eso el fichero
#                            de Encina conserva esa forma.
#     /md5sum.txt         <- EL PRECIO, y hay que pagarlo entero (§4.21d):
#                            md5sum.txt CUBRE ./boot/grub/grub.cfg y
#                            ./.disk/info, asi que editarlos y no rehacerlo deja
#                            una ISO que arranca bien y FALLA la comprobacion de
#                            integridad de su propio medio. Se reescriben esas
#                            DOS lineas y se ANADE una tercera, la de la capa de
#                            marca, para que el propio medio la verifique.
#
# Y CAMBIA UNA COSA QUE NO ES UN FICHERO, desde el 2026-08-17:
#     el Volume id      <- 'Ubuntu 24.04.4 LTS arm64' -> 'Encina OS 0.2.1 arm64'.
#                          Es LO UNICO que un gestor de discos ensena al conectar
#                          el USB, en cualquier sistema operativo y ANTES de
#                          arrancar nada: la tabla de particiones de este medio
#                          es MBR y no lleva nombres (§4.51b), y la unica otra
#                          etiqueta del medio es la FAT de la ESP, que dice 'ESP'
#                          y no es de Canonical (§4.53a). Es pila A de D22.
#                          NO SE ESCRIBE A MANO: se DERIVA de marca/disk-info,
#                          que ya es el nombre del producto, para que los dos
#                          sitios no puedan separarse (paso 5e).
#
# EL VOLUME ID NO ES UN FICHERO, Y ESO TIENE UN PRECIO PARA ESTE GUION: vive en
# el Descriptor Primario de Volumen -- y en sus CUATRO copias, sectores 16, 32,
# 64 y 80 --, no en el arbol de ficheros. O sea que el paso 10, que es la
# comprobacion mas fuerte que tiene esta receta, es CIEGO a este cambio: compara
# fichero a fichero y lo dejaria pasar en silencio. Por eso el paso 11 lo
# comprueba aparte y POR BYTES, contando las apariciones del nombre viejo y del
# nuevo en la imagen entera, con su control.
#
# CONSECUENCIA PARA LA DEFINICION DE TERMINADO: E3 ya no es «solo anadir
# ficheros», y la casilla de integridad pasa a comprobar el md5sum.txt NUEVO en
# vez del oficial. Por eso este guion no se cree a si mismo: al final compara la
# ISO nueva contra la oficial FICHERO A FICHERO -- las 300 y pico entradas del
# medio, no solo las 266 de md5sum.txt -- y se niega si cambio algo que no sean
# LOS TRES DECLARADOS, o si aparecio algo que no sea el seed, el contenido de
# --repo y la capa de marca. La lista de anadidos se DERIVA del directorio de
# origen, porque desde E4 ya no son seis ficheros: son el seed, el indice y
# todos los .deb del repo offline.
#
# LO QUE NO TOCA NUNCA, Y NO ES PRUDENCIA SINO UNA MEDICION: los tres binarios
# firmados de la cadena de arranque -- bootaa64.efi (shim), grubaa64.efi y
# mmaa64.efi --. El banco de UTM NO aplica Secure Boot (§4.21b), asi que si se
# rompieran AQUI NO LO NOTARIA NADIE. Por eso sus huellas se comparan antes y
# despues y este guion se niega si cambia una.
#
# COMO SE RECONSTRUYE LA ISO SIN ROMPER EL ARRANQUE: no se inventa. Se le
# pregunta a la propia imagen con
#     xorriso -indev <iso> -report_el_torito as_mkisofs
# y se usa 'xorriso -boot_image any replay', que reproduce la ESP anadida por
# intervalo de bytes, El Torito y la tabla MBR hibrida tal cual estaban.

set -uo pipefail
# EL LOCALE, FIJADO AQUI Y NO HEREDADO (trampa 2). Hasta el 2026-08-19 este guion
# no lo fijaba y SOLO FUNCIONABA LLAMADO DESDE construir-todo.sh, que si lo
# exporta: ejecutado a mano moria en «MENU_ENCINA»: unbound variable», porque sin
# LC_ALL=C bash se comia el « » » pegado al nombre de la variable. Un guion que
# depende del entorno de quien lo llama no es reproducible.
export LC_ALL=C

AQUI=$(cd "$(dirname "$0")" && pwd)
GUION="$AQUI/encina-seed.sh"
YAML="$AQUI/autoinstall.yaml"

ISO=""; REPO=""; SALIDA=""; CAPA=""
# los cuatro mecanismos de D23. Todos puestos por defecto: el producto los lleva,
# y una bandera de bisecado que se olvide tiene que dar el PRODUCTO, no un medio
# a medias.
CON_CAPA=1; CON_VOLID=1; CON_INFO=1; CON_MENU=1
LEER=""   # --leer-mecanismos <iso>: solo lee y sale, no fabrica nada
# --info-crudo <fichero>: un .disk/info ARBITRARIO, para MEDIOS DE DIAGNOSTICO.
# NO es para el producto y no relaja ninguna guarda del producto: lo que hace es
# dejar de PARAR con las dos que protegen la marca -- «el rotulo no puede decir
# Ubuntu» (5b) y «el Volume id no puede decir Ubuntu» / «32 bytes» (5e) --, que
# se siguen EVALUANDO y dicen en voz alta que habrian hecho. Existe porque los
# medios que hacen falta para bisecar DENTRO de .disk/info (§4.56s) son
# justamente cadenas que el producto tiene que rechazar: sin esto, la eleccion
# entre las hipotesis de §4.56j y §4.56m no se puede medir.
INFO_CRUDO=""
# LAS ISOS OFICIALES QUE ESTE GUION ACEPTA. Una fila por arquitectura, y la
# arquitectura NO SE DECLARA CON UNA BANDERA: se DEDUCE de cual de estas huellas
# tiene la ISO que se le da -- igual que traer-iso-oficial.sh deduce el NOMBRE
# buscando la huella dentro del SHA256SUMS firmado. Una bandera se puede poner
# mal; una huella, no.
#
# EL SERVIDOR VA EN LA TABLA, y no es un adorno: §4.64 P1 se escribio prediciendo
# que amd64 estaria en el mismo sitio que arm64 y ESO ES FALSO --
# cdimage.ubuntu.com/ubuntu/releases sirve arm64, ppc64el, riscv64 y s390x, y
# amd64 vive en releases.ubuntu.com--. Son dos servidores distintos con la MISMA
# firma (Ubuntu CD Image Automatic Signing Key (2012), comprobada con su control
# negativo en §4.64), asi que lo que cambia es la direccion y no la confianza.
#
#   arq    huella de la ISO oficial 24.04.4 de escritorio    donde vive
ISOS_OFICIALES="\
arm64 c2610520bf582976839a1724c669e1cfed0547427be5a0ad12d457b92b46ffbe https://cdimage.ubuntu.com/ubuntu/releases/24.04/release
amd64 3a4c9877b483ab46d7c3fbe165a0db275e1ae3cfe56a5657e5a47c2f99a99d1e https://releases.ubuntu.com/24.04"
# EL TITULO DEL MENU DE ARRANQUE. Lo oficial es 'Try or Install Ubuntu', y es
# pila A de D22: presenta el producto ante el usuario, en la primera pantalla.
MENU_ENCINA="Probar o instalar Encina OS"
# LA ISO amd64 TRAE UNA ENTRADA DE MENU QUE LA arm64 NO TIENE: «Ubuntu (safe
# graphics)», con SU PROPIA linea de nucleo. Medido el 2026-08-22 (§4.64), y no
# es un detalle cosmetico: sale en la PRIMERA pantalla del medio, o sea pila A de
# D22. Asi que los titulos van en una tabla -- oficial <TAB> nuestro -- y la
# regla es «no se adivina»: si el grub.cfg oficial trae un menuentry que dice
# «Ubuntu» y NO esta en esta tabla, la fabricacion PARA.
TAB_T=$(printf '\t')
MENUS_ENCINA="Try or Install Ubuntu${TAB_T}${MENU_ENCINA}
Ubuntu (safe graphics)${TAB_T}Encina OS (modo seguro)"
# el idioma del producto, que NO se pregunta (AGENTS.md §6ter.0). Va en el seed
# como 'locale:' para la maquina que sale, y aqui en el grub.cfg para que el
# INSTALADOR se vea en el mismo idioma. Los dos sitios dicen lo mismo a proposito.
LOCALE=es_ES.UTF-8

uso() { sed -n '2,10p' "$0"; exit 2; }
while [ $# -gt 0 ]; do
    case "$1" in
        --iso)    ISO="$2";    shift 2 ;;
        --repo)   REPO="$2";   shift 2 ;;
        --salida) SALIDA="$2"; shift 2 ;;
        --capa)   CAPA="$2";   shift 2 ;;
        --yaml)   YAML="$2";   shift 2 ;;
        --leer-mecanismos) LEER="$2"; shift 2 ;;
        --info-crudo) INFO_CRUDO="$2"; shift 2 ;;
        --sin-capa)  CON_CAPA=0;  shift ;;
        --sin-volid) CON_VOLID=0; shift ;;
        --sin-info)  CON_INFO=0;  shift ;;
        --sin-menu)  CON_MENU=0;  shift ;;
        -h|--help) sed -n '1,40p' "$0"; exit 0 ;;
        *) echo "[FALLO] argumento desconocido: $1"; uso ;;
    esac
done
[ -n "$ISO" ] || ISO="$AQUI/../medios/ubuntu-24.04.4-desktop-arm64.iso"
if [ -n "$LEER" ]; then
    :                                   # solo leer: no hace falta ni --repo ni --salida
else
    [ -n "$REPO" ] && [ -n "$SALIDA" ] || uso
fi

fallo() { echo "[FALLO] $*"; exit 1; }
ok()    { echo "[OK]    $*"; }

# QUE MECANISMOS DE MARCA LLEVA UNA ISO, LEIDOS DE ELLA Y NO DE NINGUNA VARIABLE.
# Vive aqui arriba, y no dentro del paso 13 que la usa, porque «--leer-mecanismos
# <iso>» la deja disponible sobre CUALQUIER medio: asi el lector se puede
# ejercitar en segundos contra las ISOs que ya estan en el disco -- cuya
# composicion esta escrita en MEDICIONES.md -- en vez de solo dentro de una
# construccion de 20 minutos. Imprime cuatro cifras: capa volid info menu.
# NO BUSCA NOMBRES NUESTROS a proposito: cuenta squashfs, compara ficheros con
# los de la ISO oficial y busca el titulo OFICIAL del menu. Un lector que
# buscara «Encina» estaria de acuerdo con el guion por construccion, que es
# justo lo que este bloque existe para no hacer.
mecanismos() {   # imprime "capa volid info menu" con 1 o 0, leyendo la ISO
    local iso="$1" c v i m n_s n_o vol
    # LA CAPA SON DOS COSAS Y SE LEEN LAS DOS: el fichero de mas en /casper y el
    # layerfs-path= que lo monta. Con una sola, el mecanismo NO esta -- que es
    # justo lo que paso del 2026-08-15 al 20 y este lector no habria cazado.
    n_s=$(tar -tf "$iso" 2>/dev/null | /usr/bin/grep -c '^casper/.*\.squashfs$')
    n_o=$(tar -tf "$ISO" 2>/dev/null | /usr/bin/grep -c '^casper/.*\.squashfs$')
    if [ "$n_s" -gt "$n_o" ] && tar -xOf "$iso" boot/grub/grub.cfg 2>/dev/null | grep -q 'layerfs-path='
        then c=1; else c=0; fi
    vol=$(xorriso -indev "$iso" -pvd_info 2>/dev/null | sed -n 's/^Volume Id    : //p' | head -1)
    [ "$vol" = "$VOLID_OFICIAL" ] && v=0 || v=1
    if tar -xOf "$iso" .disk/info 2>/dev/null | diff -q - "$TMP/info.oficial" >/dev/null 2>&1
        then i=0; else i=1; fi
    if tar -xOf "$iso" boot/grub/grub.cfg 2>/dev/null \
       | grep -q '^menuentry "Try or Install Ubuntu" {$'
        then m=0; else m=1; fi
    echo "$c $v $i $m"
}

command -v xorriso >/dev/null || fallo "no hay xorriso (brew install xorriso)"
[ -f "$ISO" ]  || fallo "no esta la ISO oficial: $ISO
        Traela y comprueba su firma con:  ./imagen/traer-iso-oficial.sh
        (medios/ esta en .gitignore a proposito: ver medios/LEEME.md)"
[ -f "$YAML" ] || fallo "no existe el seed: $YAML"

# --- modo lectura: --leer-mecanismos <iso>, y no se fabrica nada -------------
if [ -n "$LEER" ]; then
    [ -f "$LEER" ] || fallo "no esta la ISO que hay que leer: $LEER"
    TMP=$(mktemp -d) || fallo "mktemp"
    trap 'rm -rf "$TMP"' EXIT
    tar -xOf "$ISO" .disk/info > "$TMP/info.oficial" \
        || fallo "no pude leer .disk/info de la ISO oficial (referencia)"
    VOLID_OFICIAL=$(xorriso -indev "$ISO" -pvd_info 2>/dev/null | sed -n 's/^Volume Id    : //p' | head -1)
    [ -n "$VOLID_OFICIAL" ] || fallo "no pude leer el Volume id de la ISO oficial"
    echo "$(mecanismos "$LEER")   capa volid info menu   $(basename "$LEER")"
    exit 0
fi

# --- 0. QUE MECANISMOS DE MARCA LLEVA ESTE MEDIO ----------------------------
# Va DELANTE de todo lo demas a proposito: una construccion son ~20 minutos y
# hay que poder ver en la primera linea del registro que se esta fabricando.
# OJO CON EL printf: 'printf -- ' se come los dos guiones como «fin de
# opciones» y no imprime NADA, asi que la linea que dice que mecanismos lleva el
# medio omitia justo el que falta -- «capa=» en vez de «capa=--». Salio al
# EJECUTARLO, no al leerlo, en la primera construccion de bisecado.
mec() { [ "$1" = 1 ] && printf '%s' 'SI' || printf '%s' '--'; }
echo "== 0. los cuatro mecanismos de marca del medio (D23)"
echo "        $(mec $CON_CAPA) la capa /casper/zz-encina.squashfs"
echo "        $(mec $CON_VOLID) el Volume id propio"
echo "        $(mec $CON_INFO) el /.disk/info propio"
echo "        $(mec $CON_MENU) el menuentry del grub.cfg"
N_SIN=$(( (1-CON_CAPA) + (1-CON_VOLID) + (1-CON_INFO) + (1-CON_MENU) ))
if [ "$N_SIN" -gt 0 ]; then
    echo "        [AVISO] faltan $N_SIN de los 4: esto es un MEDIO DE BISECADO, no el producto"
fi

# --- 1. la ISO de partida es la medida, no otra, Y DE ELLA SALE LA ARQUITECTURA
echo "== 1. la ISO oficial, por huella -- y la arquitectura, DEDUCIDA de ella"
real=$(shasum -a 256 "$ISO" | cut -d' ' -f1)
ARQ_ISO=$(printf '%s\n' "$ISOS_OFICIALES" | awk -v h="$real" '$2==h {print $1}')
if [ -z "$ARQ_ISO" ]; then
    fallo "esta ISO no es ninguna de las medidas en §4.14/§4.21/§4.64
        real     $real
        aceptadas:
$(printf '%s\n' "$ISOS_OFICIALES" | awk '{printf "          %-6s %s\n", $1, $2}')"
fi
ok "ISO oficial de escritorio $ARQ_ISO  ${real:0:16}…  (arquitectura DEDUCIDA de la huella)"

# LOS TRES BINARIOS FIRMADOS SE LLAMAN DISTINTO EN CADA ARQUITECTURA, y el
# sufijo no se adivina: sale del mismo ARQ_ISO que acaba de deducirse.
case "$ARQ_ISO" in
    arm64) SUF_EFI=aa64 ;;
    amd64) SUF_EFI=x64  ;;
    *) fallo "no se que binarios EFI lleva la arquitectura «$ARQ_ISO»" ;;
esac

# --- 2. los cuatro .deb, con las huellas del guion que las comprueba dentro --
echo "== 2. los cuatro .deb, por huella (§4.13: misma version != mismos bytes)"
huella_de() { grep -E "^$1=" "$GUION" | head -1 | cut -d= -f2; }
declare -a FICHEROS HUELLAS
FICHEROS=(autofirma_1.9.1+encina4_all.deb
          encina-branding_0.1.16_all.deb
          encina-firefox-native_0.2.1_all.deb
          encina-meta_0.2.1_all.deb)
HUELLAS=("$(huella_de H_AUTOFIRMA)" "$(huella_de H_BRANDING)"
         "$(huella_de H_FFNATIVE)"  "$(huella_de H_META)")
for i in 0 1 2 3; do
    f="$REPO/${FICHEROS[$i]}"
    [ -f "$f" ] || fallo "no esta: $f"
    r=$(shasum -a 256 "$f" | cut -d' ' -f1)
    [ "$r" = "${HUELLAS[$i]}" ] || fallo "huella distinta en ${FICHEROS[$i]}"
    ok "${FICHEROS[$i]}  ${r:0:8}…"
done
[ -f "$REPO/Packages" ] || fallo "no esta $REPO/Packages"
for i in 0 1 2 3; do
    grep -q "^SHA256: ${HUELLAS[$i]}$" "$REPO/Packages" \
        || fallo "Packages no describe ${FICHEROS[$i]}"
done
# EL RESTO DEL MEDIO ES NUEVO EN E4: el nivel 3 de §4.27 mete en /encina-repo
# todo lo que hasta hoy bajaba de internet. No tiene huellas escritas a mano en
# ningun sitio -- de el responde Packages, que es lo que apt verifica -- asi que
# aqui se comprueba el indice ENTERO contra los bytes, en las dos direcciones.
NIDX=$(grep -cE '^Filename: \./' "$REPO/Packages")
NDEB=$(ls -1 "$REPO"/*.deb 2>/dev/null | wc -l | tr -d ' ')
[ "$NIDX" -eq "$NDEB" ] || fallo "Packages describe $NIDX ficheros y en el repo hay $NDEB .deb"
MALAS=0
while read -r f h; do
    [ -f "$REPO/$f" ] || { echo "        no viaja: $f"; MALAS=$((MALAS+1)); continue; }
    r=$(shasum -a 256 "$REPO/$f" | cut -d' ' -f1)
    [ "$r" = "$h" ] || { echo "        huella mala: $f"; MALAS=$((MALAS+1)); }
done < <(paste -d' ' <(sed -n 's|^Filename: \./||p' "$REPO/Packages") \
                    <(sed -n 's|^SHA256: ||p'      "$REPO/Packages"))
[ "$MALAS" -eq 0 ] || fallo "$MALAS entradas de Packages no cuadran con los bytes del repo"
ok "Packages describe $NIDX ficheros, viajan $NDEB, y las $NIDX huellas cuadran"

# --- 3. el seed y el guion no se han separado -------------------------------
echo "== 3. la late-command del seed == encina-seed.sh"
B64=$(base64 -i "$GUION" | tr -d '\n')
# LA LINEA ENTERA, Y NO SOLO EL TROZO DEL BASE64. Hasta el 2026-08-22 esto era
#     grep -q "echo $B64 | base64 -d" "$YAML"
# o sea que comprobaba el GUION que se invoca y no COMO se invoca: la cola de la
# linea podia decir cualquier cosa -- y decia «; true», que se tragaba el codigo
# de salida del seed (§4.61, §4.62). Un medio con esa cola pasaba este paso con
# un [OK] y entregaba maquinas rotas diciendo «listo para usarse». Ahora se
# compara la linea COMPLETA, y es la MISMA cadena que construye fabricar-seed.sh,
# escrita igual a proposito: si las dos se separan, esto lo dice.
LINEA="    - sh -c 'echo $B64 | base64 -d > /tmp/encina-seed.sh; sh /tmp/encina-seed.sh'"
grep -qxF "$LINEA" "$YAML" \
    || fallo "$(basename "$YAML") y encina-seed.sh se han separado, o la cola de la
        late-command no es la que este guion espera. La linea del yaml es:
$(grep -n "^    - sh -c 'echo " "$YAML" | sed 's/\(.\{110\}\).*/\1…/' | sed 's/^/            /')
        Rehazlo con: ./fabricar-seed.sh --yaml $YAML --actualizar-yaml ..."
ok "coinciden LINEA ENTERA ($(wc -c <"$GUION" | tr -d ' ') bytes de guion, sin «; true»)"
# CONTROL de esa comparacion, que es lo que la convierte en comprobacion: tiene
# que saber decir que NO. Se le enfrenta la misma linea con la cola de antes --
# el «; true» que causo §4.61 -- y no debe reconocerla.
if grep -qxF "    - sh -c 'echo $B64 | base64 -d > /tmp/encina-seed.sh; sh /tmp/encina-seed.sh; true'" "$YAML"; then
    fallo "CONTROL: el yaml lleva la cola «; true», que se traga el exit 1 del seed"
fi
ok "control: la cola «; true» de §4.61 no esta, y esta comparacion sabria verla"
# y que el seed de la entrega NO lleve credenciales, que es una casilla
if grep -qE '^\s*(identity|ssh):|password|ssh-ed25519' "$YAML"; then
    fallo "el seed de la entrega lleva credenciales dentro"
fi
ok "el seed no lleva identidad, ni contrasena, ni clave ssh"
# CONTROL de esa busqueda: tiene que encontrarlas en el seed de laboratorio
if grep -qE 'password|ssh-ed25519' "$AQUI/autoinstall-unattended.yaml"; then
    ok "control: la misma busqueda SI las encuentra en el seed de laboratorio"
else
    fallo "CONTROL ROTO: no sabe encontrar credenciales ni donde las hay"
fi

# --- 4. las huellas de la cadena firmada, ANTES ------------------------------
# EL DIRECTORIO NO SE ESCRIBE: SE LEE DEL MEDIO, y esto costo un verde falso el
# 2026-08-22 (§4.64). La ISO arm64 lo llama «efi/boot/» EN MINUSCULAS y la amd64
# «EFI/boot/» EN MAYUSCULAS. Con la ruta escrita a mano, 'tar -xOf' no sacaba
# NADA y las tres huellas salian e3b0c44298fc1c14… -- que es la huella de la
# CADENA VACIA -- y el guion decia [OK] tres veces. Peor: el paso 12 comparaba
# vacio contra vacio y tambien daba [OK], asi que un medio con la cadena de
# arranque destrozada habria pasado las dos comprobaciones.
echo "== 4. los tres binarios firmados, antes"
declare -a EFI ANTES
EFI=("boot${SUF_EFI}.efi" "grub${SUF_EFI}.efi" "mm${SUF_EFI}.efi")
DIR_EFI=$(tar -tf "$ISO" 2>/dev/null | grep -iE "^efi/boot/${EFI[0]}$" | head -1)
DIR_EFI="${DIR_EFI%/*}"
[ -n "$DIR_EFI" ] || fallo "no encuentro ${EFI[0]} en la ISO: no es un medio $ARQ_ISO arrancable por UEFI"
ok "la cadena firmada vive en «$DIR_EFI/» (leido del medio, no escrito aqui)"
# LA HUELLA DE LA CADENA VACIA, para poder RECHAZARLA. Es el control de que lo
# que viene son bytes de verdad y no un fichero que no se pudo leer.
VACIO=$(printf '' | shasum -a 256 | cut -d' ' -f1)
for i in 0 1 2; do
    ANTES[$i]=$(tar -xOf "$ISO" "$DIR_EFI/${EFI[$i]}" | shasum -a 256 | cut -d' ' -f1)
    [ "${ANTES[$i]}" != "$VACIO" ] \
        || fallo "$DIR_EFI/${EFI[$i]} sale VACIO de la ISO: no lo he podido leer, y una huella de nada no es una huella"
    ok "${EFI[$i]}  ${ANTES[$i]:0:16}…"
done

# --- 5. los ficheros que si se modifican, y la capa de marca ----------------
# CUANTOS son depende de las banderas «--sin-*»: el grub.cfg y el md5sum.txt van
# siempre, el .disk/info y la capa solo si su mecanismo esta puesto.
echo "== 5. el grub.cfg, el .disk/info, la capa de marca y el md5sum.txt que los cubre"
TMP=$(mktemp -d) || fallo "mktemp"
trap 'rm -rf "$TMP"' EXIT

# --- 5a. grub.cfg: el idioma del instalador y el titulo del menu ------------
tar -xOf "$ISO" boot/grub/grub.cfg > "$TMP/grub.cfg.oficial" \
    || fallo "no pude leer boot/grub/grub.cfg de la ISO"
# §4.21d: en todo el medio hay UN solo grub.cfg. LINEAS DE NUCLEO puede haber
# mas de una -- la amd64 trae dos, §4.64 --, asi que se CUENTAN y el locale va en
# TODAS: una entrada de menu sin locale arranca el instalador en ingles, que es
# justo lo que este bloque existe para evitar.
N_VMLINUZ=$(grep -c '/casper/vmlinuz' "$TMP/grub.cfg.oficial")
[ "$N_VMLINUZ" -ge 1 ] || fallo "no hay ni una linea con /casper/vmlinuz en el grub.cfg oficial"
grep -q 'locale=' "$TMP/grub.cfg.oficial" \
    && fallo "el grub.cfg oficial ya trae un locale=: parar y mirar por que"
# LOS TITULOS QUE DICEN «Ubuntu» TIENEN QUE ESTAR TODOS EN LA TABLA. Lo que se
# comprueba no es que sean los de siempre, sino que NINGUNO se quede sin
# renombrar por no haberlo previsto -- que es como se cuela una marca ajena en la
# primera pantalla.
TITULOS=$(sed -n 's/^menuentry "\(.*\)" {$/\1/p' "$TMP/grub.cfg.oficial" | grep Ubuntu || true)
[ -n "$TITULOS" ] || fallo "el grub.cfg oficial no tiene ni un menuentry que diga Ubuntu: parar y mirar que ISO es esta"
N_MENUS=0
while IFS= read -r t; do
    [ -n "$t" ] || continue
    printf '%s\n' "$MENUS_ENCINA" | cut -f1 | grep -qxF "$t" \
        || fallo "el grub.cfg oficial trae el menuentry «$t» y no esta en la tabla MENUS_ENCINA: no se adivina como se llama en Encina OS"
    N_MENUS=$((N_MENUS+1))
done <<EOF
$TITULOS
EOF
ok "grub.cfg oficial: $N_VMLINUZ lineas de nucleo y $N_MENUS menuentry que dicen Ubuntu, los $N_MENUS en la tabla"
# la palabra va ANTES del '---', que es la ranura de casper. El locale va SIEMPRE
# (no es marca y ya viajaba en una ISO que arranca); el titulo del menu si es
# marca, y por eso tiene bandera.
sed -e "s|/casper/vmlinuz|/casper/vmlinuz locale=$LOCALE|" \
    "$TMP/grub.cfg.oficial" > "$TMP/grub.cfg"
if [ "$CON_MENU" = 1 ]; then
    while IFS="$TAB_T" read -r oficial nuestro; do
        [ -n "$oficial" ] || continue
        printf '%s\n' "$TITULOS" | grep -qxF "$oficial" || continue
        sed -e "s|^menuentry \"$oficial\" {\$|menuentry \"$nuestro\" {|" \
            "$TMP/grub.cfg" > "$TMP/grub.cfg.paso" || fallo "sed del menuentry «$oficial»"
        mv "$TMP/grub.cfg.paso" "$TMP/grub.cfg"
    done <<EOF
$MENUS_ENCINA
EOF
fi
n=$(grep -c "linux[[:space:]]*/casper/vmlinuz locale=$LOCALE .*---" "$TMP/grub.cfg")
[ "$n" -eq "$N_VMLINUZ" ] \
    || fallo "la palabra quedo en $n lineas de nucleo y hay $N_VMLINUZ"
if [ "$CON_MENU" = 1 ]; then
    D_GRUB=$(( 2 * N_VMLINUZ + 2 * N_MENUS ))
    grep -q "^menuentry \"$MENU_ENCINA\" {\$" "$TMP/grub.cfg" \
        || fallo "el titulo del menu no quedo puesto"
    grep -q "Ubuntu" "$TMP/grub.cfg" \
        && fallo "el grub.cfg de Encina todavia dice Ubuntu en alguna linea"
else
    # --sin-menu: la comprobacion NO se omite, SE INVIERTE. Que el titulo oficial
    # siga ahi es lo unico que separa «lo he quitado» de «el sed no ha aplicado»,
    # y en un bisecado esa diferencia es la respuesta entera.
    D_GRUB=$(( 2 * N_VMLINUZ ))
    grep -q "^menuentry \"Try or Install Ubuntu\" {\$" "$TMP/grub.cfg" \
        || fallo "--sin-menu, pero el menuentry OFICIAL ya no esta en el grub.cfg"
    grep -q "$MENU_ENCINA" "$TMP/grub.cfg" \
        && fallo "--sin-menu, y sin embargo el grub.cfg dice «${MENU_ENCINA}»"
fi
d=$(diff "$TMP/grub.cfg.oficial" "$TMP/grub.cfg" | grep -c '^[<>]')
[ "$d" -eq "$D_GRUB" ] || fallo "grub.cfg cambia en $d lineas y esperaba $D_GRUB"
if [ "$CON_MENU" = 1 ]; then
    ok "grub.cfg: locale=$LOCALE en $N_VMLINUZ lineas de nucleo y $N_MENUS menuentry renombrados, y no cambia nada mas"
else
    ok "grub.cfg: locale=$LOCALE y NADA MAS (--sin-menu: el menuentry sigue siendo «Try or Install Ubuntu»)"
fi

# --- 5b. .disk/info: 60 bytes que rotulan el icono del instalador ------------
tar -xOf "$ISO" .disk/info > "$TMP/info.oficial" \
    || fallo "no pude leer .disk/info de la ISO"
[ -s "$AQUI/marca/disk-info" ] || fallo "no esta imagen/marca/disk-info"
# EL FICHERO NUESTRO SE COMPRUEBA SIEMPRE, viaje o no al medio: de el sale
# tambien el Volume id (paso 5e), asi que --sin-info no puede dejarlo sin mirar.
# Lo que la bandera decide es CUAL DE LOS DOS VIAJA, al final de este bloque.
if [ -n "$INFO_CRUDO" ]; then
    [ -s "$INFO_CRUDO" ] || fallo "no existe o esta vacio el --info-crudo: $INFO_CRUDO"
    cp "$INFO_CRUDO" "$TMP/info.encina" || fallo "cp del --info-crudo"
    echo "        ####################################################################"
    echo "        # MEDIO DE DIAGNOSTICO, NO PRODUCTO: --info-crudo $INFO_CRUDO"
    echo "        # $(head -1 "$TMP/info.encina")"
    echo "        # Las guardas de marca NO paran, pero SI se evaluan y se dicen."
    echo "        ####################################################################"
else
    # LA ARQUITECTURA NO SE ESCRIBE A MANO EN LA MARCA. marca/disk-info lleva
    # «@ARQ@» y aqui se sustituye por la que el paso 1 DEDUJO de la huella de la
    # ISO oficial. Antes de §4.64 ese fichero decia «arm64» literal, y un medio
    # amd64 habria salido INCOHERENTE CONSIGO MISMO -- Volume id «… amd64»,
    # .disk/info «… Release arm64» -- sin que nada parase: la prediccion P4 de
    # §4.64 se escribio diciendo justo eso y quedo medida.
    grep -q '@ARQ@' "$AQUI/marca/disk-info" \
        || fallo "imagen/marca/disk-info ya no lleva la ranura «@ARQ@»: mira si alguien escribio una arquitectura a mano"
    sed "s/@ARQ@/$ARQ_ISO/" "$AQUI/marca/disk-info" > "$TMP/info.encina" \
        || fallo "sustitucion de @ARQ@ en .disk/info"
    grep -q '@ARQ@' "$TMP/info.encina" \
        && fallo "la sustitucion de @ARQ@ no se hizo (trampa 13: se verifica la mutacion)"
fi

# --- 5b-bis. LAS TRES ARQUITECTURAS TIENEN QUE SER LA MISMA (§4.64 P4) -------
# Hay TRES fuentes independientes que dicen de que arquitectura es este medio, y
# hasta hoy NINGUNA se comparaba con las otras:
#   1. la HUELLA de la ISO oficial          -> $ARQ_ISO      (paso 1)
#   2. el .disk/info OFICIAL                -> «- Release <arq> (fecha)»
#   3. el .disk/info NUESTRO, el que viaja  -> lo mismo, ya sustituido
# La cuarta -- la ultima palabra del Volume id oficial -- se coteja en 5e.
arq_de_info() { sed -n 's/.* - Release \([a-z0-9]*\) .*/\1/p' "$1" | head -1; }
ARQ_INFO_OFICIAL=$(arq_de_info "$TMP/info.oficial")
ARQ_INFO_NUESTRO=$(arq_de_info "$TMP/info.encina")
# EL CONTROL VA DELANTE: la extraccion tiene que saber decir que NO.
printf 'Bellota 9.9 LTS "Prueba" - Release inventada64 (20260815)\n' > "$TMP/.arq-control"
[ "$(arq_de_info "$TMP/.arq-control")" = inventada64 ] \
    || fallo "CONTROL ROTO: la extraccion no saca la arquitectura de un .disk/info que SI la tiene"
printf 'esto no es un .disk/info\n' > "$TMP/.arq-control2"
[ -z "$(arq_de_info "$TMP/.arq-control2")" ] \
    || fallo "CONTROL ROTO: la extraccion saca arquitectura de donde no la hay"
[ -n "$ARQ_INFO_OFICIAL" ] \
    || fallo "no pude leer la arquitectura del .disk/info OFICIAL: «$(head -1 "$TMP/info.oficial")»"
[ "$ARQ_INFO_OFICIAL" = "$ARQ_ISO" ] \
    || fallo "la huella de la ISO dice «$ARQ_ISO» y su propio .disk/info dice «$ARQ_INFO_OFICIAL»: parar y mirar que ISO es esta"
if [ "$ARQ_INFO_NUESTRO" != "$ARQ_ISO" ]; then
    if [ -n "$INFO_CRUDO" ]; then
        echo "[AVISO] DIAGNOSTICO: el .disk/info dice «$ARQ_INFO_NUESTRO» y la ISO es «$ARQ_ISO». En el producto esto pararia la fabricacion."
    else
        fallo "el .disk/info que viajaria dice «$ARQ_INFO_NUESTRO» y la ISO oficial es «$ARQ_ISO»"
    fi
else
    ok "arquitectura, y las TRES fuentes dicen lo mismo: huella=$ARQ_ISO  info oficial=$ARQ_INFO_OFICIAL  info nuestro=$ARQ_INFO_NUESTRO"
fi
# EL CONTROL, y es el calculo de casper-bottom/25adduser tal cual viaja en el
# medio: no se comprueba que el fichero cambie, se comprueba QUE ROTULO SALE.
release_de() {
    local f="$1" lts rel
    lts=$(cut -d' ' -f3 "$f" 2>/dev/null)
    rel=$(cut -d' ' -f1-2 "$f" 2>/dev/null | sed 's/-/ /')
    [ "$lts" = "LTS" ] && [ -n "$rel" ] && rel="$rel LTS"
    echo "$rel"
}
R_OFICIAL=$(release_de "$TMP/info.oficial"); R_NUESTRO=$(release_de "$TMP/info.encina")
# NO se compara contra el nombre del producto escrito aqui: eso seria guardar el
# nombre en un sitio mas, y este guion ya tiene la lista de sitios que lo dicen.
# Se comprueba LA PROPIEDAD -- pila A de D22: el rotulo no puede decir Ubuntu --,
# con su control de que la busqueda encuentra «Ubuntu» donde SI lo hay.
if printf '%s' "$R_NUESTRO" | grep -qi ubuntu; then
    if [ -n "$INFO_CRUDO" ]; then
        echo "[AVISO] DIAGNOSTICO: el rotulo diria «Install ${R_NUESTRO}». En el producto esto pararia la fabricacion."
    else
        fallo "el rotulo del icono seguiria diciendo Ubuntu: «Install ${R_NUESTRO}»"
    fi
fi
# EL CONTROL DE LA GUARDA, y solo hace falta cuando se le ha quitado la parada:
# la MISMA regla, sobre el .disk/info DEL PRODUCTO, tiene que seguir diciendo que
# ese pasa. Si dijera que no, la guarda estaria rota y el [AVISO] de arriba no
# significaria nada -- que es como se cuela un verde falso.
if [ -n "$INFO_CRUDO" ]; then
    R_PRODUCTO=$(release_de "$AQUI/marca/disk-info")
    if printf '%s' "$R_PRODUCTO" | grep -qi ubuntu; then
        fallo "CONTROL ROTO: el .disk/info DEL PRODUCTO tampoco pasaria la guarda: «${R_PRODUCTO}»"
    fi
    ok "CONTROL: la guarda de marca sigue viva -- rechazaria «${R_OFICIAL}» y acepta el producto «${R_PRODUCTO}»"
fi
printf '%s' "$R_OFICIAL" | grep -qi ubuntu \
    || fallo "CONTROL ROTO: la busqueda no encuentra «Ubuntu» ni en «${R_OFICIAL}»"
[ "$R_OFICIAL" != "$R_NUESTRO" ] \
    || fallo "CONTROL ROTO: el calculo da lo mismo con los dos .disk/info"
# LA SEGUNDA PALABRA TIENE QUE SER UNA VERSION, Y ESTO NO ES ESTILO: es lo que
# costo una vuelta entera el 2026-08-17 (MEDICIONES.md §4.54h).
# subiquity/server/controllers/refresh.py hace
#     release = info.split()[1]
#     return ("stable/ubuntu-" + release, SnapChannelSource.DISK_INFO_FILE)
# o sea que la segunda palabra es EL CANAL DE SNAP DEL PROPIO INSTALADOR. Con
# «Encina OS 0.2.1 …» valia «OS», el medio pedia «stable/ubuntu-OS» y el
# instalador SE CAIA EN SILENCIO: sin volcado, sin error en el journal y sin
# Traceback. Esta comprobacion es la que lo habria cazado sin gastar un arranque.
V2_NUESTRO=$(cut -d' ' -f2 "$TMP/info.encina"); V2_OFICIAL=$(cut -d' ' -f2 "$TMP/info.oficial")
printf '%s' "$V2_NUESTRO" | grep -qE '^[0-9]+(\.[0-9]+)*$' \
    || fallo "la 2a palabra de .disk/info es «${V2_NUESTRO}» y tiene que ser un NUMERO DE VERSION.
        refresh.py la usa como canal: pediria «stable/ubuntu-${V2_NUESTRO}» y el
        instalador se caeria en silencio (§4.54h). Escribe el producto en UNA palabra."
printf '%s' "$V2_OFICIAL" | grep -qE '^[0-9]+(\.[0-9]+)*$' \
    || fallo "CONTROL ROTO: la 2a palabra del .disk/info OFICIAL es «${V2_OFICIAL}» y tampoco pasa la regla"
# ...Y TIENE QUE SER LA DE LA BASE, que es lo que a la regla de arriba le
# FALTABA y por eso no cazo nada: «0.2.1» ES un numero de version y la pasaba
# tan campante, pero «stable/ubuntu-0.2.1» no existe igual que no existia
# «stable/ubuntu-OS». Ese es el agujero de §4.55e: el descarte de §4.54i creyo
# exonerar el fichero cambiando OS por 0.2.1, o sea COMPARO DOS CANALES QUE NO
# EXISTEN NINGUNO DE LOS DOS, y por eso aquel descarte no valia. Los unicos
# «stable/ubuntu-*» que existen son los de las releases de Ubuntu, o sea el de
# LA BASE: la ISO oficial que este mismo guion tiene abierta dos lineas arriba.
#
# LO MEDIDO Y LO DEDUCIDO, separados, porque hoy no es lo mismo:
#   MEDIDO   -- refresh.py construye el canal con esta palabra (leido en el
#               fuente) y §4.55f probo POR EXPERIMENTO que quitar .disk/info
#               hace arrancar el instalador que se caia.
#   HIPOTESIS-- que sea el canal invalido LO QUE lo tumba. Sin cotejar aun.
# La comprobacion vale por lo primero y no depende de lo segundo: pedir un
# canal que no existe es un defecto se caiga lo que se caiga.
canal_de() { printf 'stable/ubuntu-%s' "$1"; }
regla_canal() { [ "$1" = "$V2_OFICIAL" ]; }
# EL CONTROL VA ANTES QUE LA MEDICION, y gastado con el caso que de verdad
# fallo: una regla que no sabe dar sus DOS respuestas no es una comprobacion.
regla_canal "$V2_OFICIAL" \
    || fallo "CONTROL ROTO: la regla rechaza la palabra de la propia base «${V2_OFICIAL}»"
if regla_canal "0.2.1"; then
    fallo "CONTROL ROTO: la regla ACEPTA «0.2.1», que es la del medio que se cae (§4.55f)"
fi
if regla_canal "OS"; then
    fallo "CONTROL ROTO: la regla ACEPTA «OS», que es la de §4.54h"
fi
ok "CONTROL: la regla del canal acepta «${V2_OFICIAL}» y rechaza «0.2.1» y «OS»"
regla_canal "$V2_NUESTRO" \
    || fallo "la 2a palabra de .disk/info es «${V2_NUESTRO}» y la de la BASE es «${V2_OFICIAL}».
        refresh.py pediria «$(canal_de "$V2_NUESTRO")», que NO EXISTE: los unicos
        canales son los de las releases de Ubuntu. Tiene que decir «${V2_OFICIAL}».
        Y ojo: ser un numero de version NO BASTA, que es justo lo que dejo pasar
        «0.2.1» hasta §4.55 (el nombre del producto va en la 1a palabra)."
ok "la 2a palabra es una version: «${V2_NUESTRO}» -> canal stable/ubuntu-$V2_NUESTRO (la oficial: «${V2_OFICIAL}»)"
# y la forma que necesitan los otros dos que lo leen: la primera palabra es el
# usuario y el nombre de maquina de la sesion viva, y el parentesis del final es
# el numero de serie de 57pollinate.
grep -qE '^[A-Za-z]+ .*\([0-9]+\)$' "$TMP/info.encina" \
    || fallo "el .disk/info de Encina no conserva la forma «Palabra … (numero)»"
# y ahora si: cual de los dos viaja en el medio
if [ "$CON_INFO" = 1 ]; then
    cp "$TMP/info.encina" "$TMP/info" || fallo "cp del .disk/info al medio"
    ok ".disk/info: Name=Install $R_NUESTRO (el oficial daba: Install $R_OFICIAL), FLAVOUR=$(cut -d' ' -f1 "$TMP/info.encina" | tr 'A-Z' 'a-z')"
else
    # --sin-info: el fichero NO se toca, asi que ni se mapea ni entra en
    # md5sum.txt. Se deja copiado para que el resto del guion pueda compararlo.
    cp "$TMP/info.oficial" "$TMP/info" || fallo "cp del .disk/info oficial"
    ok ".disk/info: --sin-info, viaja el OFICIAL intacto (rotulo: Install $R_OFICIAL)"
fi

# --- 5c. la capa de marca ----------------------------------------------------
if [ "$CON_CAPA" = 0 ]; then
    # --sin-capa: ni se fabrica (capa-marca.sh son minutos) ni se anade nada a
    # /casper. Es el primer sospechoso del bisecado: es lo UNICO que mete un
    # fichero nuevo en el directorio que casper e install-sources.yaml enumeran,
    # y su contenido da igual porque NO SE MONTA NUNCA (§4.54e) -- o sea que lo
    # que se prueba quitandola es su PRESENCIA.
    CAPA=""; CAPA_N=""
    ok "capa de marca: NO (--sin-capa), /casper queda como en la ISO oficial"
else
if [ -z "$CAPA" ]; then
    echo "   (no se dio --capa: se fabrica con capa-marca.sh, que lee la ISO oficial)"
    "$AQUI/capa-marca.sh" "$ISO" --salida "$TMP/capa" --trabajo "$TMP/capa-trabajo" \
        | sed 's/^/        /' || fallo "capa-marca.sh no paso"
    CAPA="$TMP/capa/minimal.standard.live.encina.squashfs"
fi
[ -f "$CAPA" ] || fallo "no esta la capa de marca: $CAPA"
CAPA_N=$(basename "$CAPA")
# EL NOMBRE TIENE QUE ENCADENAR, Y ESTO NO ES COSMETICA: casper construye la
# lista de capas quitando puntos del nombre y hace 'panic' si UN eslabon no
# existe como fichero (§4.58b, leido en casper:609-628). Un nombre mal puesto no
# da una capa que no tapa: da un medio QUE NO ARRANCA. Se comprueba aqui ademas
# de en capa-marca.sh porque con --capa aquel guion no ha corrido.
# Lo que esto sustituye, y se deja escrito al lado (§4.52b, falso desde §4.54e):
# «casper monta todos los *.squashfs de /casper en orden alfabetico y el ultimo
# manda», de donde salia el «zz-». El orden alfabetico no pinta nada en la rama
# que corre.
ESL="${CAPA_N%.*}"; EXT="${CAPA_N##*.}"; FALTAN=""; N_ESL=0
while :; do
    N_ESL=$((N_ESL+1))
    if [ "$ESL.$EXT" != "$CAPA_N" ] && ! tar -tf "$ISO" "casper/$ESL.$EXT" >/dev/null 2>&1; then
        FALTAN="$FALTAN $ESL.$EXT"
    fi
    P="${ESL%.*}"; [ "$P" = "$ESL" ] && break; ESL="$P"
done
[ -z "$FALTAN" ] || fallo "la cadena de '$CAPA_N' nombra eslabones que NO estan en /casper de la ISO oficial: casper haria PANIC
        faltan:$FALTAN"
[ "$N_ESL" -ge 2 ] || fallo "la cadena de '$CAPA_N' tiene $N_ESL eslabon: no cuelga de nada y el medio quedaria sin sistema"
# CONTROL de que la cuenta sabe decir que no: el nombre viejo no tiene ni un
# punto que quitar, asi que su cadena es de UNO.
N_NO=0; E2="zz-encina"; while :; do N_NO=$((N_NO+1)); P="${E2%.*}"; [ "$P" = "$E2" ] && break; E2="$P"; done
[ "$N_NO" -eq 1 ] || fallo "CONTROL ROTO: 'zz-encina' tenia que dar una cadena de 1 y da $N_NO"
tar -tf "$ISO" "casper/$CAPA_N" >/dev/null 2>&1 \
    && fallo "la ISO oficial ya trae un casper/$CAPA_N: parar y mirar por que"
ok "capa de marca: $CAPA_N, $(stat -f %z "$CAPA") bytes  $(shasum -a 256 "$CAPA" | cut -c1-16)…"
ok "la cadena de la capa son $N_ESL eslabones y los $((N_ESL-1)) de debajo estan en /casper (control: «zz-encina» daria $N_NO)"
fi

# --- 5c-bis. layerfs-path=: lo UNICO que hace que la capa se MONTE -----------
# ESTE BLOQUE ES LA CASILLA 3. Del 2026-08-15 al 20 el medio llevo la capa dentro
# y NO LA MONTO NUNCA (§4.54e): el initrd trae LAYERFS_PATH=minimal.standard.live
# .squashfs en /conf/conf.d/default-layer.conf, casper entra por su rama de
# multi-capa y NO ENUMERA el directorio, asi que un fichero de mas en /casper no
# lo mira nadie. Nombrarla en la linea del nucleo es lo que la mete en la cadena.
#
# EL NOMBRE NO SE ESCRIBE AQUI: sale de "$CAPA_N", que sale del fichero. Tenerlo
# en dos sitios es exactamente como se pierden estas cosas en silencio.
if [ "$CON_CAPA" = 1 ]; then
    grep -q 'layerfs-path=' "$TMP/grub.cfg.oficial" \
        && fallo "el grub.cfg oficial ya trae un layerfs-path=: parar y mirar por que"
    sed -e "s|/casper/vmlinuz locale=$LOCALE|/casper/vmlinuz locale=$LOCALE layerfs-path=$CAPA_N|" \
        "$TMP/grub.cfg" > "$TMP/grub.cfg.paso" || fallo "sed del layerfs-path"
    mv "$TMP/grub.cfg.paso" "$TMP/grub.cfg"
    # trampa 13: la mutacion se verifica DESPUES de pedirla, y en su sitio -- antes
    # del '---', que es la ranura que casper lee.
    # UNO POR LINEA DE NUCLEO, no uno a secas: la ISO amd64 trae DOS entradas de
    # arranque (§4.64) y la capa tiene que montarse en las dos. Una entrada sin
    # layerfs-path= arranca un medio SIN la marca de Encina, que es justo el
    # fallo del 2026-08-15 al 20 pero solo en la mitad de las veces -- o sea el
    # peor de los dos.
    n=$(grep -c "linux[[:space:]]*/casper/vmlinuz locale=$LOCALE layerfs-path=$CAPA_N .*---" "$TMP/grub.cfg")
    [ "$n" -eq "$N_VMLINUZ" ] \
        || fallo "layerfs-path=$CAPA_N quedo en $n lineas de nucleo antes del --- y hay $N_VMLINUZ"
    n=$(grep -c 'layerfs-path=' "$TMP/grub.cfg")
    [ "$n" -eq "$N_VMLINUZ" ] || fallo "hay $n layerfs-path= en el grub.cfg y hay $N_VMLINUZ lineas de nucleo"
    ok "grub.cfg: layerfs-path=$CAPA_N en las $N_VMLINUZ lineas de nucleo (sin esto la capa viaja y NO se monta)"
else
    # --sin-capa: la comprobacion NO se omite, SE INVIERTE. Y aqui importa mas que
    # en las otras banderas: un layerfs-path= apuntando a una capa que no viaja
    # hace que casper haga PANIC, o sea un medio que no arranca por culpa del
    # bisecado y no de lo que se bisecaba.
    grep -q 'layerfs-path=' "$TMP/grub.cfg" \
        && fallo "--sin-capa, y el grub.cfg nombra un layerfs-path=: casper haria PANIC"
    ok "grub.cfg: SIN layerfs-path= (--sin-capa), que es lo que evita el panic de casper"
fi
# El numero de lineas cambiadas NO sube: layerfs-path= cae en la MISMA linea del
# nucleo que ya cambio el locale. Que siga siendo $D_GRUB es lo que prueba que
# el sed cayo donde tenia y no en otro sitio.
d=$(diff "$TMP/grub.cfg.oficial" "$TMP/grub.cfg" | grep -c '^[<>]')
[ "$d" -eq "$D_GRUB" ] || fallo "con layerfs-path= el grub.cfg cambia en $d lineas y esperaba $D_GRUB (tenia que caer en la linea del nucleo, que ya estaba contada)"

# --- 5d. md5sum.txt: dos lineas rehechas y una anadida ----------------------
tar -xOf "$ISO" md5sum.txt > "$TMP/md5sum.oficial" \
    || fallo "no pude leer md5sum.txt de la ISO"
cp "$TMP/md5sum.oficial" "$TMP/md5sum.txt"
# CONTROL de que cada linea habla de ESE fichero y no de otro (§4.21d, medido a
# mano entonces; aqui se vuelve a medir en cada construccion)
rehacer_md5() {   # ruta-en-el-medio  fichero-oficial  fichero-nuestro
    local ruta="$1" ofi="$2" nue="$3" viejo nuevo n
    n=$(grep -c "  \.$ruta\$" "$TMP/md5sum.txt")
    [ "$n" -eq 1 ] || fallo "md5sum.txt tiene $n lineas de $ruta y esperaba una"
    viejo=$(grep "  \.$ruta\$" "$TMP/md5sum.txt" | cut -d' ' -f1)
    [ "$(md5 -q "$ofi")" = "$viejo" ] \
        || fallo "la linea de md5sum.txt no describe el $ruta de esta ISO"
    nuevo=$(md5 -q "$nue")
    [ "$nuevo" != "$viejo" ] || fallo "el $ruta modificado tiene el mismo md5"
    sed "s|^$viejo  \.$ruta\$|$nuevo  .$ruta|" "$TMP/md5sum.txt" > "$TMP/md5sum.paso"
    mv "$TMP/md5sum.paso" "$TMP/md5sum.txt"
}
# LAS DOS LISTAS QUE MANDAN EN EL RESTO DEL GUION, y salen de las banderas en un
# solo sitio: que ficheros del medio se MODIFICAN y cuales se ANADEN. Los pasos
# 6, 10 y 12 leen de aqui en vez de llevar la lista clavada, que es lo que haria
# que una bandera nueva pasara sus comprobaciones sin cambiar el producto.
MODIFICADOS=(/boot/grub/grub.cfg)
rehacer_md5 /boot/grub/grub.cfg "$TMP/grub.cfg.oficial" "$TMP/grub.cfg"
if [ "$CON_INFO" = 1 ]; then
    rehacer_md5 /.disk/info "$TMP/info.oficial" "$TMP/info"
    MODIFICADOS=("${MODIFICADOS[@]}" /.disk/info)
fi
# y la capa NUEVA se anade a la lista, para que la comprobacion de integridad
# del propio medio la cubra en vez de ignorarla
ANADIDOS_MEDIO=(/autoinstall.yaml)
if [ "$CON_CAPA" = 1 ]; then
    printf '%s  ./casper/%s\n' "$(md5 -q "$CAPA")" "$CAPA_N" >> "$TMP/md5sum.txt"
    ANADIDOS_MEDIO=("${ANADIDOS_MEDIO[@]}" "/casper/$CAPA_N")
fi
N_MOD=${#MODIFICADOS[@]}
N_NUEVOS=$((CON_CAPA))
# el diff cuenta DOS lineas por cada rehecha -- la vieja y la nueva -- y una por
# cada anadida, asi que el numero esperado se calcula, no se clava.
D_MD5=$(( N_MOD * 2 + N_NUEVOS ))
d=$(diff "$TMP/md5sum.oficial" "$TMP/md5sum.txt" | grep -c '^[<>]')
[ "$d" -eq "$D_MD5" ] || fallo "md5sum.txt cambia en $d lineas y esperaba $D_MD5 ($N_MOD rehechas, $N_NUEVOS anadidas)"
L=$(wc -l < "$TMP/md5sum.oficial" | tr -d ' ')
[ "$(wc -l < "$TMP/md5sum.txt" | tr -d ' ')" = "$((L+N_NUEVOS))" ] \
    || fallo "md5sum.txt no crecio en $N_NUEVOS lineas"
ok "md5sum.txt: $N_MOD lineas rehechas (${MODIFICADOS[*]}), $N_NUEVOS anadidas, las otras $((L-N_MOD)) intactas"

# --- 5e. el nombre del volumen ----------------------------------------------
# NO SE ESCRIBE A MANO. El nombre del producto ya esta en marca/disk-info -- de
# ahi salen el rotulo del icono del instalador y el usuario de la sesion viva --,
# asi que el Volume id se DERIVA de ese mismo fichero y de la arquitectura que
# declara el medio oficial. Escribirlo dos veces seria dejar que se separaran.
#
#   marca/disk-info : «EncinaOS 0.2.1 - Release arm64 (20260210)»
#                      \____________/                     -> lo de ANTES del « - »
#   volid oficial   : «Ubuntu 24.04.4 LTS arm64»
#                                        \___/            -> la arquitectura
#   Volume id       : «EncinaOS 0.2.1 arm64»
#
# Y OJO CON LA SEGUNDA PALABRA DE ESE FICHERO, QUE NO ES PARTE DEL NOMBRE: es un
# NUMERO DE VERSION, y no por gusto. subiquity/server/controllers/refresh.py hace
#     release = info.split()[1]
#     return ("stable/ubuntu-" + release, SnapChannelSource.DISK_INFO_FILE)
# o sea que construye con ella el CANAL DE SNAP DEL PROPIO INSTALADOR. Con
# «Encina OS 0.2.1 …» la segunda palabra era «OS», el medio pedia el canal
# «stable/ubuntu-OS» y EL INSTALADOR SE CAIA EN SILENCIO -- sin volcado en
# /var/crash, sin error en el journal y sin Traceback en el servidor (§4.54h).
# Por eso el producto se escribe aqui en UNA palabra. Ese campo lo usan TRES
# cosas a la vez: el canal, el rotulo del icono (25adduser toma las dos primeras
# palabras) y este Volume id.
#
# EL CORTE ES POR EL SEPARADOR « - », NO POR NUMERO DE PALABRAS, y eso no es
# gusto: la primera version de este bloque cortaba las TRES primeras palabras y
# un nombre de producto mas largo salia TRUNCADO EN SILENCIO -- «Encina OS
# Distribucion arm64» -- en vez de tropezar con el limite de 32 bytes. Lo saco
# el banco de pruebas del bloque, ejecutandolo con su control.
echo "== 5e. el nombre del volumen, que es lo que se ve al conectar el USB"
VOLID_OFICIAL=$(xorriso -indev "$ISO" -pvd_info 2>/dev/null | sed -n 's/^Volume Id    : //p' | head -1)
[ -n "$VOLID_OFICIAL" ] || fallo "no pude leer el Volume id de la ISO oficial"
ARQ="${VOLID_OFICIAL##* }"
case "$ARQ" in
    arm64|amd64) : ;;
    *) fallo "la ultima palabra del Volume id oficial es «${ARQ}» y esperaba una arquitectura" ;;
esac
# LA CUARTA FUENTE, cotejada con la que dedujo el paso 1 (§4.64 P4). Si el
# Volume id oficial y la huella de la ISO no dicen la misma arquitectura, el
# medio saldria rotulado de una y arrancando de la otra.
[ "$ARQ" = "$ARQ_ISO" ] \
    || fallo "el Volume id oficial dice «${ARQ}» y la huella de la ISO dice «${ARQ_ISO}»"
INFO_L=$(head -1 "$TMP/info.encina")   # el NUESTRO, lo lleve el medio o no
# EL SEPARADOR SIGUE COMPROBANDOSE, pero YA NO ES LO QUE DELIMITA EL VOLUME ID:
# es una comprobacion de la FORMA del fichero, que casper y 57pollinate esperan.
case "$INFO_L" in
    *" - "*) : ;;
    *) fallo "el .disk/info no tiene el separador « - »: «${INFO_L}»" ;;
esac
# --- DE DONDE SALE AHORA EL VOLUME ID, y por que cambio (§4.57e) --------------
# HASTA EL 2026-08-19 era «todo lo de antes del " - "» + la arquitectura, y §4.53
# lo unio a proposito para que el nombre no se escribiera en dos sitios. Se rompe
# porque quedo MEDIDO que no cabe: el instalador exige un nombre en clave
# ENTRECOMILLADO en .disk/info (§4.57e, probado quitandolo y poniendolo) y
# «<nombre> <version> LTS "<codename>" arm64» se pasa de los 32 bytes del PVD con
# cualquier codename de verdad -- §4.56q midio que con el de Ubuntu no cabe NI LA
# CADENA VACIA de nombre.
#
# Y NO SE REINTRODUCE «EL NOMBRE EN DOS SITIOS», que es lo que §4.53 evitaba: las
# dos piezas salen de fuentes que YA EXISTEN Y YA ESTAN VERIFICADAS.
#   nombre  <- la 1a palabra de .disk/info, que sigue siendo la unica fuente
#   version <- la del encina-meta que el paso 2 acaba de cotejar POR HUELLA,
#              o sea NUESTRA version y no la de Ubuntu -- que es lo que §4.53
#              obligaba a ceder y ahora se recupera
#   arq     <- la ultima palabra del Volume id OFICIAL, como siempre
NOMBRE_PRODUCTO=$(cut -d' ' -f1 "$TMP/info.encina")
printf '%s' "$NOMBRE_PRODUCTO" | grep -qE '^[A-Za-z][A-Za-z0-9]*$' \
    || fallo "la 1a palabra de .disk/info es «${NOMBRE_PRODUCTO}» y tiene que ser el nombre del producto en UNA palabra"
extraer_version() {   # extraer_version <encina-meta_X_all.deb> -> X
    printf '%s' "$1" | sed -n 's/^encina-meta_\(.*\)_all\.deb$/\1/p'
}
# EL CONTROL DE ESA EXTRACCION VA DELANTE: un sed que no case da CADENA VACIA sin
# quejarse, y un Volume id con un hueco en medio pasaria los 32 bytes sin
# problema. Tiene que saber dar sus dos respuestas.
[ -n "$(extraer_version "encina-meta_9.9.9_all.deb")" ] \
    || fallo "CONTROL ROTO: la extraccion no saca la version de un nombre que SI la tiene"
[ -z "$(extraer_version "otra-cosa_9.9.9_all.deb")" ] \
    || fallo "CONTROL ROTO: la extraccion saca version de un nombre que NO es encina-meta"
VER_NUESTRA=$(extraer_version "${FICHEROS[3]}")
[ -n "$VER_NUESTRA" ] \
    || fallo "no pude sacar nuestra version de «${FICHEROS[3]}» (el paso 2 la coteja por huella)"
printf '%s' "$VER_NUESTRA" | grep -qE '^[0-9]+(\.[0-9]+)*$' \
    || fallo "nuestra version sale «${VER_NUESTRA}» y no es un numero de version"
ok "el Volume id se compone: nombre «${NOMBRE_PRODUCTO}» (.disk/info) + version «${VER_NUESTRA}» (encina-meta, cotejado por huella) + «${ARQ}»"
VOLID_ENCINA="$NOMBRE_PRODUCTO $VER_NUESTRA $ARQ"
# El limite del campo del PVD son 32 BYTES, y no se trunca en silencio. Se miden
# bytes y no caracteres a proposito: ${#var} contaria una «ñ» como uno y en el
# fichero ocupa dos.
N_VOLID=$(printf '%s' "$VOLID_ENCINA" | wc -c | tr -d ' ')
if [ "$N_VOLID" -gt 32 ]; then
    if [ -n "$INFO_CRUDO" ]; then
        # no se trunca en silencio JAMAS: si no cabe, el medio de diagnostico se
        # fabrica con el Volume id OFICIAL y se dice. §4.55f dejo medido que el
        # Volume id no determina si el instalador arranca.
        echo "[AVISO] DIAGNOSTICO: «${VOLID_ENCINA}» son $N_VOLID bytes y caben 32."
        echo "        Este medio viaja con el Volume id OFICIAL (como --sin-volid). NO se trunca."
        CON_VOLID=0
    else
        fallo "«${VOLID_ENCINA}» son $N_VOLID bytes y el campo del PVD admite 32.
        SI ESTO SALE CON EL .disk/info DEL PRODUCTO, NO ES UN DEFECTO NUEVO: es el
        bloqueo conocido de MEDICIONES.md §4.56dd. El fichero que hace ARRANCAR al
        instalador necesita «LTS \"Noble Numbat\"» (§4.56cc) y ese trozo se come los
        32 bytes el solo, asi que el Volume id NO PUEDE seguir derivandose de aqui:
        hay que romper la derivacion de §4.53 y escribirlo por su cuenta."
    fi
fi
# pila A de D22: lo que presenta el producto ante el usuario NO puede decir Ubuntu
if printf '%s' "$VOLID_ENCINA" | grep -qi ubuntu; then
    if [ -n "$INFO_CRUDO" ]; then
        echo "[AVISO] DIAGNOSTICO: el Volume id diria «${VOLID_ENCINA}». En el producto esto pararia la fabricacion."
    else
        fallo "el Volume id de Encina todavia dice Ubuntu: «${VOLID_ENCINA}»"
    fi
fi
# CONTROL de esa busqueda, que es la misma trampa del paso 5a: tiene que
# encontrarlo donde SI lo hay, o «no dice Ubuntu» significa «no he mirado».
printf '%s' "$VOLID_OFICIAL" | grep -qi ubuntu \
    || fallo "CONTROL ROTO: la busqueda no encuentra «Ubuntu» ni en «${VOLID_OFICIAL}»"
[ "$VOLID_ENCINA" != "$VOLID_OFICIAL" ] || fallo "el Volume id no cambia"
# QUE NOMBRE SE ESCRIBE DE VERDAD. Con --sin-volid se le pasa a xorriso el
# nombre OFICIAL, en vez de no pasarle nada: el resultado es el mismo -- §4.53c
# midio que los avisos de xorriso salen igual con -volid y sin el, porque se
# queja del nombre que ya trae el medio -- y asi el guion escribe siempre lo que
# ha decidido en vez de heredar en silencio.
if [ "$CON_VOLID" = 1 ]; then
    VOLID="$VOLID_ENCINA"
    ok "Volume id: «${VOLID_OFICIAL}» -> «${VOLID_ENCINA}» ($N_VOLID bytes de 32)"
else
    VOLID="$VOLID_OFICIAL"
    ok "Volume id: --sin-volid, se conserva el OFICIAL «${VOLID_OFICIAL}» (el nuestro habria sido «${VOLID_ENCINA}»)"
fi

# --- 6. construir ------------------------------------------------------------
echo "== 6. xorriso: anadir el seed, el repo y la capa de marca, y reemplazar tres"
mkdir -p "$TMP/encina-repo"
cp "$YAML" "$TMP/autoinstall.yaml" || fallo "cp seed"
cp "$REPO"/*.deb "$REPO"/Packages "$TMP/encina-repo/" || fallo "cp repo"

# EL MODO DE LO QUE SE ANADE, FIJADO A PROPOSITO, POR EL MISMO MOTIVO QUE LA
# FECHA DE ABAJO Y CON LA MISMA FORMA. 'cp' conserva el modo que el fichero
# tuviera en el disco del Mac, y ese modo VIAJA DENTRO DE LA ISO: es el campo
# PX de Rock Ridge, en sus dos copias -little-endian y big-endian- y en los dos
# arboles de directorio. Medido (MEDICIONES.md §4.36k): la ISO vigente
# ac0a5721… se diferenciaba de la fabricada desde el repositorio cosechado en
# 2 sectores de 1 814 144, y esos 4 bytes eran un solo campo -- el modo de
# encina-firefox-native_0.2.1_all.deb, 0700 en el medio vigente porque ese dia
# el fichero estaba en 0700 en 'debian-packages/', y 0644 al dia siguiente
# porque ya no lo estaba. O sea que la ISO NO LA REPRODUCIA NI SU PROPIO
# DIRECTORIO DE ORIGEN. Hoy en 'debian-packages/' siguen conviviendo ficheros
# en 0600 y en 0644, asi que esto no es hipotetico.
#
# 0644 para los ficheros y 0755 para el directorio: es lo que ya llevan los 29
# ficheros del medio, asi que fijarlo no cambia el producto -- solo deja de
# depender de un dato que no esta versionado.
MODO_F=644
MODO_D=755
MODO_F=644
MODO_D=755
# la capa se copia a TMP antes de tocarle el modo: puede venir de --capa, o sea
# de un directorio que no es nuestro.
# LA LISTA DE FICHEROS QUE VIAJAN, derivada de las banderas: es la misma para el
# chmod, para el -map de xorriso y para la fecha, asi que se escribe UNA vez.
#   MAPAS  : los pares «-map <local> <ruta en el medio>» que se le pasan a xorriso
#   RUTAS  : esas mismas rutas, para -alter_date_r
#   LOCALES: los ficheros del Mac, para el chmod y su comprobacion
MAPAS=(-map "$TMP/autoinstall.yaml" /autoinstall.yaml
       -map "$TMP/encina-repo"      /encina-repo
       -map "$TMP/grub.cfg"         /boot/grub/grub.cfg
       -map "$TMP/md5sum.txt"       /md5sum.txt)
RUTAS=(/autoinstall.yaml /encina-repo /boot/grub/grub.cfg /md5sum.txt)
LOCALES=("$TMP/autoinstall.yaml" "$TMP/grub.cfg" "$TMP/md5sum.txt")
if [ "$CON_INFO" = 1 ]; then
    MAPAS=("${MAPAS[@]}" -map "$TMP/info" /.disk/info)
    RUTAS=("${RUTAS[@]}" /.disk/info)
    LOCALES=("${LOCALES[@]}" "$TMP/info")
fi
if [ "$CON_CAPA" = 1 ]; then
    cp "$CAPA" "$TMP/$CAPA_N" || fallo "cp de la capa de marca"
    MAPAS=("${MAPAS[@]}" -map "$TMP/$CAPA_N" "/casper/$CAPA_N")
    RUTAS=("${RUTAS[@]}" "/casper/$CAPA_N")
    LOCALES=("${LOCALES[@]}" "$TMP/$CAPA_N")
fi
chmod "$MODO_D" "$TMP/encina-repo"                  || fallo "chmod dir repo"
chmod "$MODO_F" "$TMP/encina-repo"/* "${LOCALES[@]}" || fallo "chmod ficheros"
# Y SE COMPRUEBA QUE SE APLICO, que es la trampa 13: una mutacion se verifica
# ANTES de leer su resultado. Sin esto, un chmod que fallara en silencio daria
# exactamente la ISO que este bloque existe para evitar, y nadie lo notaria.
n=$(find "$TMP/encina-repo" "${LOCALES[@]}" -type f ! -perm "$MODO_F" | wc -l | tr -d ' ')
[ "$n" -eq 0 ] || fallo "$n ficheros no quedaron en $MODO_F pese al chmod"
d=$(find "$TMP/encina-repo" -type d ! -perm "$MODO_D" | wc -l | tr -d ' ')
[ "$d" -eq 0 ] || fallo "el directorio del repo no quedo en $MODO_D"
t=$(find "$TMP/encina-repo" -type f | wc -l | tr -d ' ')
ok "modo fijado: $((t+${#LOCALES[@]})) ficheros en $MODO_F y el directorio del repo en $MODO_D"

rm -f "$SALIDA"
# LA FECHA DE LO QUE SE ANADE, FIJADA A PROPOSITO: sin esto, la misma orden
# ejecutada dos veces produce dos ISOs distintas -- 192 bytes en 4 sectores, que
# son las marcas de tiempo de los ficheros nuevos en sus registros de directorio
# (medido: 20:08:38 contra 21:35:45). Se les pone la fecha de modificacion de la
# ISO OFICIAL, que la propia imagen declara en su receta
# (--modification-date='2026021001455100'), asi que lo anadido hereda la fecha
# del medio y la construccion es REPRODUCIBLE: misma entrada, misma huella.
FECHA='2026021001455100'
#
# OJO CON LOS AVISOS DE xorriso, QUE NO SON NUESTROS: al escribir la imagen dice
# «-volid text does not comply to ISO 9660 / ECMA 119 rules» y «problematic as
# automatic mount point name». Salen IGUAL sin pasar -volid (medido, §4.53c):
# se queja del nombre que ya trae el medio oficial, porque «Ubuntu 24.04.4 LTS
# arm64» tampoco cumple la norma -- minusculas y espacios. Lo nuestro hereda
# exactamente la misma infraccion, ni una mas.
xorriso -indev "$ISO" -outdev "$SALIDA" \
        -boot_image any replay \
        -overwrite on \
        -volid "$VOLID" \
        "${MAPAS[@]}" \
        -alter_date_r b "$FECHA" "${RUTAS[@]}" -- \
        -alter_date_r c "$FECHA" "${RUTAS[@]}" -- \
        -commit -end 2>&1 | grep -iE "^xorriso : (FAILURE|SORRY|WARNING)" | head -20
[ -f "$SALIDA" ] || fallo "xorriso no produjo $SALIDA"
ok "escrita: $(stat -f %z "$SALIDA") bytes"

# --- 7. y ahora la parte que importa: comprobar que solo se anadio ----------
echo "== 7. la cadena firmada, DESPUES (si cambia una, este banco no lo notaria)"
for i in 0 1 2; do
    d=$(tar -xOf "$SALIDA" "$DIR_EFI/${EFI[$i]}" | shasum -a 256 | cut -d' ' -f1)
    [ "$d" != "$VACIO" ] \
        || fallo "$DIR_EFI/${EFI[$i]} sale VACIO del medio fabricado: comparar nada con nada no es comparar"
    [ "$d" = "${ANTES[$i]}" ] || fallo "CAMBIO ${EFI[$i]}
        antes   ${ANTES[$i]}
        despues $d"
    ok "${EFI[$i]} intacto"
done

echo "== 8. lo anadido esta, y con las huellas de siempre"
tar -xOf "$SALIDA" autoinstall.yaml | diff -q - "$YAML" >/dev/null \
    || fallo "el seed dentro de la ISO no coincide con $YAML"
ok "/autoinstall.yaml == $(basename "$YAML")"
for i in 0 1 2 3; do
    d=$(tar -xOf "$SALIDA" "encina-repo/${FICHEROS[$i]}" | shasum -a 256 | cut -d' ' -f1)
    [ "$d" = "${HUELLAS[$i]}" ] || fallo "${FICHEROS[$i]} no sobrevivio a la ISO"
done
ok "los cuatro .deb sobreviven a la ISO, huella a huella"
if [ "$CON_CAPA" = 1 ]; then
    d=$(tar -xOf "$SALIDA" "casper/$CAPA_N" | shasum -a 256 | cut -d' ' -f1)
    [ "$d" = "$(shasum -a 256 "$CAPA" | cut -d' ' -f1)" ] \
        || fallo "la capa de marca no sobrevivio a la ISO"
    ok "casper/$CAPA_N sobrevive a la ISO, huella a huella"
else
    # --sin-capa: se comprueba la AUSENCIA, y contando, no preguntando por un
    # nombre. Si algun dia la capa se llamara de otro modo, «no esta zz-encina»
    # seria un verde falso; «/casper tiene los mismos squashfs que la oficial»
    # no lo es.
    n_n=$(tar -tf "$SALIDA" 2>/dev/null | /usr/bin/grep -c '^casper/.*\.squashfs$')
    n_o=$(tar -tf "$ISO"    2>/dev/null | /usr/bin/grep -c '^casper/.*\.squashfs$')
    [ "$n_o" -gt 0 ] || fallo "CONTROL ROTO: no encuentro ni un squashfs en /casper de la ISO oficial"
    [ "$n_n" -eq "$n_o" ] \
        || fallo "--sin-capa y sin embargo /casper tiene $n_n squashfs contra los $n_o de la oficial"
    ok "--sin-capa: /casper tiene los mismos $n_n squashfs que la oficial, ni uno mas"
fi
# CONTROL: la ISO no puede contener algo que no se metio
if tar -tf "$SALIDA" 2>/dev/null | grep -q "^encina-repo/fichero-que-no-existe"; then
    fallo "CONTROL ROTO: aparece un fichero que nadie metio"
fi
ok "control: un fichero que no se metio no aparece"

echo "== 9. el arranque: la FORMA y el CONTENIDO de la ESP, contra la oficial"
# OJO: los desplazamientos y el tamano de la ESP CAMBIAN por fuerza al anadir
# ficheros -- la ISO crece y la particion anadida se mueve al final, y xorriso
# la alinea rellenando con ceros (-partition_cyl_align all). Comparar LBAs seria
# una comprobacion que falla siempre y no dice nada. Lo que tiene que ser igual
# es la FORMA -- tipos de particion, El Torito, plataforma -- y el CONTENIDO de
# la ESP, que es donde viven los tres binarios firmados.
forma() {
    python3 - "$1" <<'PY2'
import sys, struct
f=open(sys.argv[1],'rb'); mbr=f.read(512); out=[]
for i in range(4):
    e=mbr[446+16*i:446+16*i+16]
    if any(e): out.append("mbr_tipo:0x%02x" % e[4])
f.seek(17*2048); b=f.read(2048)
out.append("brvd:"+b[7:30].decode(errors='replace').strip('\0'))
cat=struct.unpack('<I', b[0x47:0x4b])[0]; f.seek(cat*2048); c=f.read(64)
out.append("plataforma:%d" % c[1])
out.append("arrancable:0x%02x" % c[32])
print(" | ".join(out))
PY2
}
A=$(forma "$ISO"); B=$(forma "$SALIDA")
echo "  oficial: $A"
echo "  nuestra: $B"
[ "$A" = "$B" ] || fallo "la FORMA de arranque no es la misma"
ok "MBR hibrido, El Torito y plataforma UEFI, iguales"

# EL CONTENIDO DE LA ESP: se localiza en cada imagen por su propia tabla, y LAS
# DOS ARQUITECTURAS NO USAN LA MISMA (§4.64, y esto costo una fabricacion):
#
#   arm64: MBR de verdad, con una entrada de tipo 0xef -> ahi esta la ESP
#   amd64: MBR PROTECTOR (una sola entrada 0xee que cubre el disco) + GPT, y la
#          ESP es una particion de la GPT con el tipo C12A7328-F81F-11D2-BA4B-
#          00A0C93EC93B. Buscando 0xef en el MBR no se encuentra NADA.
#
# Se miran las dos, en ese orden, y si no aparece por ninguna se PARA -- que es
# lo que hizo la version vieja, y por eso el fallo se vio en vez de colarse.
esp() {  # imprime "inicio sectores" de la ESP, o nada
    python3 - "$1" <<'PY2'
import sys, struct
f=open(sys.argv[1],'rb')
mbr=f.read(512)
for i in range(4):                       # 1. el MBR, como siempre (arm64)
    e=mbr[446+16*i:446+16*i+16]
    if any(e) and e[4]==0xef:
        print(struct.unpack('<I',e[8:12])[0], struct.unpack('<I',e[12:16])[0]); sys.exit()
cab=f.read(512)                          # 2. la GPT (amd64)
if cab[:8]!=b'EFI PART': sys.exit()
lba_ent=struct.unpack('<Q',cab[72:80])[0]
n_ent  =struct.unpack('<I',cab[80:84])[0]
t_ent  =struct.unpack('<I',cab[84:88])[0]
TIPO_ESP=bytes.fromhex('28732ac11ff8d211ba4b00a0c93ec93b')
f.seek(lba_ent*512)
for _ in range(n_ent):
    e=f.read(t_ent)
    if len(e)<t_ent: break
    if e[:16]==TIPO_ESP:
        ini=struct.unpack('<Q',e[32:40])[0]; fin=struct.unpack('<Q',e[40:48])[0]
        print(ini, fin-ini+1); sys.exit()
PY2
}
read -r AI AN <<<"$(esp "$ISO")"
read -r BI BN <<<"$(esp "$SALIDA")"
[ -n "$AI" ] && [ -n "$BI" ] || fallo "no encuentro la ESP en alguna de las dos"
[ "$BN" -ge "$AN" ] || fallo "la ESP de nuestra ISO es MAS PEQUENA que la oficial"
HA=$(dd if="$ISO"    bs=512 skip="$AI" count="$AN" 2>/dev/null | shasum -a 256 | cut -d' ' -f1)
HB=$(dd if="$SALIDA" bs=512 skip="$BI" count="$AN" 2>/dev/null | shasum -a 256 | cut -d' ' -f1)
[ "$HA" = "$HB" ] || fallo "el CONTENIDO de la ESP ha cambiado
        oficial ${HA:0:32}
        nuestra ${HB:0:32}"
ok "la ESP es byte a byte la oficial en sus $AN sectores  (${HA:0:16}…)"
# y lo que xorriso anade al final tiene que ser relleno, no datos
SOBRA=$((BN - AN))
if [ "$SOBRA" -gt 0 ]; then
    NOCERO=$(dd if="$SALIDA" bs=512 skip=$((BI + AN)) count="$SOBRA" 2>/dev/null | tr -d '\000' | wc -c | tr -d ' ')
    [ "$NOCERO" = 0 ] || fallo "los $SOBRA sectores que xorriso anade a la ESP NO son ceros ($NOCERO bytes)"
    ok "los $SOBRA sectores de mas son relleno de alineacion: 0 bytes distintos de cero"
fi

# --- 10. el medio entero, fichero a fichero ----------------------------------
# Mientras E3 solo anadia ficheros, «no se modifico nada» se podia argumentar.
# Desde que toca grub.cfg y md5sum.txt hay que ENSENARLO, y sobre TODAS las
# entradas del medio, no solo sobre las 266 que md5sum.txt cubre. Se lee cada
# imagen UNA sola vez: xorriso da el LBA y el tamano de cada fichero y el md5 se
# calcula buscando dentro de la propia imagen, sin extraer 3,4 GB a disco.
echo "== 10. el medio entero, fichero a fichero, contra la oficial"
cat > "$TMP/mapa.py" <<'PY3'
import sys, hashlib
f = open(sys.argv[1], "rb")
for linea in sys.stdin:
    if not linea.startswith("File data lba:"):
        continue
    p = linea.split(",", 4)
    lba, tam, ruta = int(p[1]), int(p[3]), p[4].strip().strip("'")
    h = hashlib.md5()
    f.seek(lba * 2048)
    leidos = 0
    while leidos < tam:
        t = f.read(min(1 << 20, tam - leidos))
        if not t:
            break
        h.update(t)
        leidos += len(t)
    if leidos != tam:
        sys.exit("no pude leer entera: " + ruta)
    print(h.hexdigest(), ruta)
PY3
mapa() {
    xorriso -indev "$1" -find / -type f -exec report_lba -- 2>/dev/null \
        | python3 "$TMP/mapa.py" "$1" | LC_ALL=C sort -k2
}
mapa "$ISO"    > "$TMP/mapa.oficial" || fallo "no pude mapear la ISO oficial"
mapa "$SALIDA" > "$TMP/mapa.nuestra" || fallo "no pude mapear la ISO construida"
# guarda: si alguna ruta llevara espacios, el resto de este bloque mentiria
awk 'NF!=2 {exit 1}' "$TMP/mapa.oficial" \
    || fallo "hay rutas con espacios en el medio: esta comprobacion no vale"
ok "leidas $(wc -l < "$TMP/mapa.oficial" | tr -d ' ') entradas de la oficial y $(wc -l < "$TMP/mapa.nuestra" | tr -d ' ') de la nuestra"

awk '{print $2}' "$TMP/mapa.oficial" | LC_ALL=C sort > "$TMP/rutas.oficial"
awk '{print $2}' "$TMP/mapa.nuestra" | LC_ALL=C sort > "$TMP/rutas.nuestra"
# LOS ANADIDOS YA NO SON SEIS: con el nivel 3 de §4.27 el repo lleva dentro
# todo lo que bajaba de internet, asi que la lista esperada se DERIVA del
# directorio de origen. Lo que no cambia es la exigencia: ni uno mas, ni uno
# menos, y ninguno perdido.
{ for a in "${ANADIDOS_MEDIO[@]}"; do echo "$a"; done
  for f in "$REPO"/*; do echo "/encina-repo/$(basename "$f")"; done
} | LC_ALL=C sort > "$TMP/anadidos.esperados"
N_ESPERADOS=$(wc -l < "$TMP/anadidos.esperados" | tr -d ' ')
LC_ALL=C comm -13 "$TMP/rutas.oficial" "$TMP/rutas.nuestra" > "$TMP/anadidos"
LC_ALL=C comm -23 "$TMP/rutas.oficial" "$TMP/rutas.nuestra" > "$TMP/quitados"
[ ! -s "$TMP/quitados" ] || fallo "la ISO nuestra ha PERDIDO ficheros:
$(cat "$TMP/quitados")"
diff -q "$TMP/anadidos.esperados" "$TMP/anadidos" >/dev/null \
    || fallo "los ficheros anadidos no son los esperados:
$(diff "$TMP/anadidos.esperados" "$TMP/anadidos")"
ok "$N_ESPERADOS ficheros anadidos, ni uno mas, y ninguno perdido"

LC_ALL=C join -1 2 -2 2 "$TMP/mapa.oficial" "$TMP/mapa.nuestra" \
    | awk '$2!=$3 {print $1}' | LC_ALL=C sort > "$TMP/cambiados"
# --- 10bis. EL FICHERO QUE CAMBIA Y NO LO CAMBIAMOS NOSOTROS -----------------
# En amd64 -- y solo en amd64, porque arm64 no arranca por BIOS -- el medio lleva
# /boot/grub/i386-pc/eltorito.img, el arranque BIOS heredado, Y CAMBIA. No es
# nuestro: lo reescribe xorriso al recolocar el fichero dentro de la imagen.
#
# ESO NO SE DECLARA COMO EXCEPCION MUDA, que seria taparlo. Se declara CON LA
# LISTA DE LO QUE PUEDE CAMBIAR DENTRO, y esta medido (§4.64, 2026-08-22):
#
#   offsets 8..23  la 'boot-info-table' que xorriso parchea: LBA del PVD, LBA
#                  del propio fichero, tamano y suma de control
#   offsets 2548..2549  el puntero de bloques de grub2-boot-info
#
# Y EL CONTROL ESTA PAGADO: un medio amd64 fabricado con los CUATRO mecanismos
# de marca APAGADOS da un eltorito.img IDENTICO BYTE A BYTE al del producto, o
# sea que de esos siete bytes no hay ni uno de Encina. Ademas md5sum.txt NO lo
# lista -- ni en la ISO oficial ni en la nuestra --, asi que la comprobacion de
# integridad del propio medio no se ve afectada.
ELTORITO=/boot/grub/i386-pc/eltorito.img
declare -a MOD_XORRISO
MOD_XORRISO=()
if LC_ALL=C grep -qx "$ELTORITO" "$TMP/rutas.oficial"; then
    tar -xOf "$ISO"    "${ELTORITO#/}" > "$TMP/elt.ofi" 2>/dev/null
    tar -xOf "$SALIDA" "${ELTORITO#/}" > "$TMP/elt.nue" 2>/dev/null
    [ -s "$TMP/elt.ofi" ] && [ -s "$TMP/elt.nue" ] \
        || fallo "no pude leer $ELTORITO de alguna de las dos ISOs"
    # que los bytes que difieren caigan SOLO en las dos ventanas conocidas
    FUERA=$(cmp -l "$TMP/elt.ofi" "$TMP/elt.nue" 2>/dev/null | awk '{o=$1-1} o<8 || (o>=24 && o<2548) || o>=2550 {print o}')
    [ -z "$FUERA" ] \
        || fallo "$ELTORITO cambia FUERA de la boot-info-table y del puntero de grub, en los offsets:
$(printf '%s\n' "$FUERA" | head -20)"
    # y que el LBA escrito sea el que El Torito dice de NUESTRA imagen
    LBA_TAB=$(python3 -c 'import struct,sys;print(struct.unpack("<I",open(sys.argv[1],"rb").read(16)[12:16])[0])' "$TMP/elt.nue")
    LBA_CAT=$(xorriso -indev "$SALIDA" -report_el_torito plain 2>/dev/null \
              | awk '/El Torito boot img/ && /BIOS/ {print $NF}')
    [ -n "$LBA_CAT" ] && [ "$LBA_TAB" = "$LBA_CAT" ] \
        || fallo "la boot-info-table dice que el arranque BIOS esta en el LBA $LBA_TAB y El Torito dice $LBA_CAT"
    tar -xOf "$SALIDA" md5sum.txt 2>/dev/null | grep -q eltorito \
        && fallo "md5sum.txt lista el eltorito.img: entonces SI afectaria a la comprobacion de integridad del medio"
    MOD_XORRISO=("$ELTORITO")
    ok "$ELTORITO: cambia, y solo en la boot-info-table (LBA $LBA_CAT, que es donde El Torito dice) y el puntero de grub. No es nuestro: lo reescribe xorriso"
fi

printf '%s\n' /md5sum.txt "${MODIFICADOS[@]}" "${MOD_XORRISO[@]}" | LC_ALL=C sort > "$TMP/cambiados.esperados"
N_CAMB=$(( N_MOD + 1 + ${#MOD_XORRISO[@]} ))
diff -q "$TMP/cambiados.esperados" "$TMP/cambiados" >/dev/null \
    || fallo "los ficheros modificados no son los $N_CAMB declarados:
$(diff "$TMP/cambiados.esperados" "$TMP/cambiados")"
ok "modificados exactamente $N_CAMB: /md5sum.txt ${MODIFICADOS[*]} ${MOD_XORRISO[*]}"
# CONTROL de la comparacion entera: tiene que saber ver un cambio donde lo hay.
# Se compara la oficial consigo misma cambiandole una huella a mano.
awk 'NR==1{$1="ffffffffffffffffffffffffffffffff"}1' "$TMP/mapa.oficial" \
    | LC_ALL=C sort -k2 > "$TMP/mapa.saboteada"
c=$(LC_ALL=C join -1 2 -2 2 "$TMP/mapa.oficial" "$TMP/mapa.saboteada" | awk '$2!=$3' | wc -l | tr -d ' ')
[ "$c" -eq 1 ] || fallo "CONTROL ROTO: la comparacion no ve una huella cambiada"
ok "control: con una huella saboteada, la comparacion la senala"

# --- 11. el nombre del volumen, que NO es un fichero --------------------------
# EXISTE PORQUE EL PASO 10 ES CIEGO A ESTO. El paso 10 es la comprobacion mas
# fuerte de esta receta -- las 500 y pico entradas del medio, huella a huella --
# y aun asi dejaria pasar el cambio del Volume id sin decir nada, porque el
# Volume id NO ES UN FICHERO: vive en los descriptores de volumen, en el sector
# 16 y siguientes, que el arbol de ficheros no cubre.
#
# Y NO HAY UNO: HAY VARIOS, Y NO SIEMPRE LOS MISMOS. Medido (§4.53c):
#     ISO oficial de Canonical      2 primarios (16, 32) + 2 Joliet (18, 33)
#     ISO que sale de este guion    4 primarios (16, 32, 64, 80) + 0 Joliet
# O sea que remasterizar CAMBIA cuantas copias hay y ADEMAS se lleva por delante
# el Joliet -- y eso ya pasaba desde E3, sin que nadie lo hubiera medido. Por
# eso este bloque NO cuenta apariciones esperando un numero: LEE TODOS los
# descriptores que haya en la imagen construida y exige que TODOS digan lo
# nuestro. Un numero fijo se habria roto solo, y calibrarlo contra la oficial
# -- que fue el primer intento -- comparaba 4 contra 2 y fallaba siempre.
echo "== 11. el nombre del volumen: no es un fichero, asi que el paso 10 no lo ve"
# lo primero es lo que pide la casilla con esas palabras -- «xorriso -indev da
# un Volume id propio» --, y lo segundo es lo que esa lectura NO cubre: xorriso
# contesta con el PRIMER descriptor y hay mas de uno.
V=$(xorriso -indev "$SALIDA" -pvd_info 2>/dev/null | sed -n 's/^Volume Id    : //p' | head -1)
[ "$V" = "$VOLID" ] || fallo "xorriso -indev lee «${V}» y esperaba «${VOLID}»"
ok "xorriso -indev lee «${V}»"
# lee cada descriptor de volumen: "<tipo> <sector> <nombre>"
descriptores() {
    python3 - "$1" <<'PY4'
import sys
f = open(sys.argv[1], 'rb')
for s in range(16, 1024):
    f.seek(s * 2048)
    d = f.read(2048)
    if len(d) < 2048 or d[1:6] != b'CD001':
        continue
    if d[0] == 1:      # primario: el nombre va en ASCII
        print(1, s, d[40:72].decode('latin1').rstrip())
    elif d[0] == 2:    # suplementario (Joliet): el nombre va en UCS-2BE
        print(2, s, d[40:72].decode('utf-16-be', 'replace').rstrip())
PY4
}
descriptores "$SALIDA" > "$TMP/vd.nuestra"
descriptores "$ISO"    > "$TMP/vd.oficial"
# OJO: aqui, y solo aqui, va /usr/bin/grep y no 'grep' a secas. El resto de este
# guion usa 'grep' porque solo mira su codigo de salida; estas cuatro lineas
# CUENTAN, y el hook de rtk resume la salida de grep (§4.9d), asi que un numero
# sacado del grep filtrado seria un numero inventado.
# CONTROL, y va delante: si el lector no sabe leer los descriptores DE LA
# OFICIAL -- donde el nombre de Ubuntu esta y el nuestro no puede estar --, sus
# respuestas de abajo no significan «esta bien», significan «no he mirado».
NP_O=$(awk '$1==1' "$TMP/vd.oficial" | wc -l | tr -d ' ')
MAL_O=$(cut -d' ' -f3- "$TMP/vd.oficial" | /usr/bin/grep -ci ubuntu)
TOT_O=$(wc -l < "$TMP/vd.oficial" | tr -d ' ')
{ [ "$NP_O" -ge 1 ] && [ "$MAL_O" -eq "$TOT_O" ]; } \
    || fallo "CONTROL ROTO: en la ISO oficial esperaba $TOT_O descriptores diciendo Ubuntu y hay $MAL_O
$(cat "$TMP/vd.oficial")"
ok "control: el lector encuentra $TOT_O descriptores en la ISO oficial ($NP_O primarios) y los $TOT_O dicen Ubuntu"
# y ahora la nuestra: TODOS los primarios tienen que decir exactamente lo nuestro
NP=$(awk '$1==1' "$TMP/vd.nuestra" | wc -l | tr -d ' ')
[ "$NP" -ge 1 ] || fallo "la ISO construida no tiene ni un descriptor primario"
BUENOS=$(awk '$1==1' "$TMP/vd.nuestra" | cut -d' ' -f3- | /usr/bin/grep -cxF "$VOLID")
[ "$BUENOS" -eq "$NP" ] \
    || fallo "solo $BUENOS de los $NP descriptores primarios dicen «${VOLID}»:
$(cat "$TMP/vd.nuestra")"
if [ "$CON_VOLID" = 1 ]; then
    # ni un descriptor, del tipo que sea, puede seguir diciendo Ubuntu. Esto cubre
    # el Joliet si algun dia volviera: su nombre va TRUNCADO a 16 caracteres
    # («Ubuntu 24.04.4 L» en la oficial), asi que buscar la cadena entera no lo veria.
    SUCIOS=$(cut -d' ' -f3- "$TMP/vd.nuestra" | /usr/bin/grep -ci ubuntu)
    if [ "$SUCIOS" -ne 0 ]; then
        # LA TERCERA guarda de marca, y esta NO se encontro leyendo el guion sino
        # EJECUTANDOLO: las dos de §4.56t miran la CADENA antes de fabricar, y
        # esta mira el MEDIO YA CONSTRUIDO, asi que no salio en la misma busqueda.
        if [ -n "$INFO_CRUDO" ]; then
            echo "[AVISO] DIAGNOSTICO: $SUCIOS descriptores del medio dicen Ubuntu. En el producto esto pararia la fabricacion."
        else
            fallo "$SUCIOS descriptores de volumen de la ISO construida siguen diciendo Ubuntu:
$(cat "$TMP/vd.nuestra")"
        fi
    fi
    if [ -n "$INFO_CRUDO" ] && [ "$SUCIOS" -ne 0 ]; then
        # NO se puede decir «ninguno dice Ubuntu» cuando SUCIOS no es 0: seria un
        # [OK] que describe lo que el guion QUERIA y no lo que hay en el medio,
        # que es la trampa 13 escrita en la salida.
        ok "los $NP descriptores primarios dicen «${VOLID_ENCINA}» -- y $SUCIOS de $(wc -l < "$TMP/vd.nuestra" | tr -d ' ') dicen Ubuntu, porque es un medio de DIAGNOSTICO"
    else
        ok "los $NP descriptores primarios dicen «${VOLID_ENCINA}», y ninguno de los $(wc -l < "$TMP/vd.nuestra" | tr -d ' ') dice Ubuntu"
    fi
else
    # --sin-volid: aqui la exigencia se INVIERTE. Este medio TIENE que seguir
    # diciendo Ubuntu en el nombre del volumen -- es justo lo que se esta
    # probando --, y comprobarlo es lo que separa «no se lo he puesto» de «se me
    # ha olvidado ponerselo».
    SUCIOS=$(cut -d' ' -f3- "$TMP/vd.nuestra" | /usr/bin/grep -ci ubuntu)
    [ "$SUCIOS" -eq "$(wc -l < "$TMP/vd.nuestra" | tr -d ' ')" ] \
        || fallo "--sin-volid: esperaba que TODOS los descriptores dijeran lo oficial y solo $SUCIOS lo dicen:
$(cat "$TMP/vd.nuestra")"
    ok "--sin-volid: los $NP descriptores primarios conservan «${VOLID_OFICIAL}» (D22: este medio NO se publica)"
fi

echo "== 12. la integridad del propio medio, contra el md5sum.txt NUEVO"
tar -xOf "$SALIDA" md5sum.txt | sed 's|  \./|  /|' | LC_ALL=C sort -k2 > "$TMP/md5.declarado"
d=$(wc -l < "$TMP/md5.declarado" | tr -d ' ')
c=$(LC_ALL=C join -1 2 -2 2 "$TMP/md5.declarado" "$TMP/mapa.nuestra" | wc -l | tr -d ' ')
[ "$c" -eq "$d" ] || fallo "solo se pudieron comparar $c de $d lineas de md5sum.txt"
m=$(LC_ALL=C join -1 2 -2 2 "$TMP/md5.declarado" "$TMP/mapa.nuestra" | awk '$2!=$3' | wc -l | tr -d ' ')
[ "$m" -eq 0 ] || fallo "$m de las $d lineas de md5sum.txt NO cuadran con el medio"
ok "las $d lineas de md5sum.txt cuadran con la ISO construida, la del grub.cfg, la del .disk/info y la de la capa incluidas"
# CONTROL: con el md5sum.txt OFICIAL tienen que fallar DOS lineas -- la del
# grub.cfg y la del .disk/info --, que es exactamente la ISO que se entregaria
# si alguien se saltara el precio de §4.21d. La de la capa no cuenta: no esta en
# el fichero oficial, asi que el 'join' ni la mira.
sed 's|  \./|  /|' "$TMP/md5sum.oficial" | LC_ALL=C sort -k2 > "$TMP/md5.oficial.rutas"
m=$(LC_ALL=C join -1 2 -2 2 "$TMP/md5.oficial.rutas" "$TMP/mapa.nuestra" | awk '$2!=$3' | wc -l | tr -d ' ')
[ "$m" -eq "$N_MOD" ] || fallo "CONTROL ROTO: con el md5sum.txt oficial esperaba $N_MOD fallos y hay $m"
ok "control: con el md5sum.txt OFICIAL fallan exactamente $N_MOD lineas: ${MODIFICADOS[*]}"

# --- 13. los mecanismos, LEIDOS DEL MEDIO CONSTRUIDO --------------------------
# ESTE BLOQUE ES LO QUE HACE FIABLE UN BISECADO. Todo lo de arriba comprueba que
# el guion hizo lo que EL creia; esto abre la ISO terminada y pregunta que lleva,
# sin mirar ninguna variable intermedia. Una bandera que no hiciera nada pasaria
# todos los pasos anteriores -- porque sus expectativas salen de la misma
# bandera -- y aqui no pasa. Y no lee nombres nuestros: cuenta squashfs, compara
# ficheros con los de la oficial y busca el titulo OFICIAL del menu, que es lo
# unico que no puede estar de acuerdo con el guion por casualidad.
echo "== 13. los cuatro mecanismos, leidos del medio terminado"
# CONTROL, y va delante: sobre la ISO OFICIAL el lector tiene que decir que no
# lleva NINGUNO. Si dijera que si, sus respuestas de abajo no significarian «lo
# lleva», significarian «este lector dice que si a todo».
LEIDO_O=$(mecanismos "$ISO")
[ "$LEIDO_O" = "0 0 0 0" ] \
    || fallo "CONTROL ROTO: el lector dice «${LEIDO_O}» sobre la ISO OFICIAL y tenia que decir «0 0 0 0»"
ok "control: sobre la ISO oficial el lector no encuentra ninguno de los cuatro"
LEIDO=$(mecanismos "$SALIDA")
PEDIDO="$CON_CAPA $CON_VOLID $CON_INFO $CON_MENU"
[ "$LEIDO" = "$PEDIDO" ] || fallo "EL MEDIO NO LLEVA LO QUE SE PIDIO
        pedido (capa volid info menu): $PEDIDO
        leido  en la ISO terminada   : $LEIDO"
ok "el medio lleva exactamente lo pedido (capa volid info menu): $LEIDO"

echo
echo "iso:    $SALIDA"
echo "sha256: $(shasum -a 256 "$SALIDA" | cut -d' ' -f1)"
echo "tam:    $(stat -f %z "$SALIDA") bytes"
echo "volid:  $VOLID   (lo que se ve al conectar el USB)"
echo "marca:  capa=$(mec $CON_CAPA) volid=$(mec $CON_VOLID) info=$(mec $CON_INFO) menu=$(mec $CON_MENU)   (SI = lo lleva, -- = quitado para bisecar)"
echo
echo "LO QUE ESTE GUION NO PUEDE DECIR: que arranque. Eso se mide en una VM"
echo "creada desde cero, contestando las cinco pantallas (AGENTS.md §6ter.3)."
