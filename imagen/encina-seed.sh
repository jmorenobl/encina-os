#!/bin/sh
# Encina OS - E4. Todo el trabajo del seed, en UNA SOLA late-command.
#
# COMO CORRE ESTO, que condiciona cada linea:
#
#   - Corre en el ENTORNO DEL INSTALADOR (fuera del chroot), con el sistema
#     instalado montado en /target. Lo que toque el objetivo va por
#     'curtin in-target', y lo que mire el objetivo mira /target DESDE FUERA.
#   - Deja su propio registro dentro de /target, porque cada intento cuesta una
#     instalacion entera y no se puede depurar a medias.
#   - COMPRUEBA LO QUE HA DEJADO Y LO DICE, en /etc/encina-estado (§4.27): sin
#     red no entraba ni uno de los cuatro .deb y hasta el 2026-08-11 la
#     instalacion terminaba diciendo que fue bien.
#   - Y DESDE EL 2026-08-12 (§4.31) FALLA A LA VISTA si la maquina no ha
#     quedado entera. Ver el bloque 15: la regla "nunca sale distinto de 0" era
#     una regla del INSTRUMENTO -se escribio para no quedarse sin datos
#     midiendo- que se habia colado dentro de la ISO que se entrega.
#
# LO QUE CAMBIA EN E4, Y ES LO QUE MAS FACIL SALE MAL (D16, la convivencia (c)):
#
#   ESTE GUION YA NO PURGA snapd. Encina OS es un escritorio que crece, la
#   tienda que lo permite arrastra snapd de todas formas (§4.26d), y quitar el
#   Snap NUNCA fue condicion de que la firma funcione: la condicion es que el
#   Firefox que el usuario puede abrir sea el nativo (§4.26h, §4.13). Lo que
#   rompe es un Firefox de Snap que alguien ABRE -B3 y B4-, y eso es el estado
#   (d), no el (c).
#
#   Y DE AHI SALE LA MINA, que cuesta la vuelta entera si se pisa (AGENTS.md
#   §6.2): al no purgar, el .deb de transicion 'firefox 1:1snap1-...' SIGUE
#   INSTALADO, asi que el reparto de §4.17 se invierte otra vez ->
#
#     paso 11 (full-upgrade)  SUSTITUYE el deb de transicion por el de Mozilla
#     paso 12 (l10n-es-es)    vuelve a ser SOLO el idioma
#
#   Ese cambio es un *downgrade* FORMAL, porque el deb de transicion lleva el
#   epoch '1:' (§4.10c, medido). Con -y y sin --allow-downgrades, apt se niega.
#   Y si alguien quitara el argumento, el paso NO falla ruidosamente: deja la
#   maquina con el deb de transicion, o sea abriendo el Snap, o sea el estado
#   (d), el que no firma. Por eso el bloque 11bis existe y por eso el veredicto
#   del bloque 14 mira la version instalada y no el rc.
#
# TRAMPAS QUE ESTAN APLICADAS AQUI, y no son decorativas:
#
#   trampa 10 - Bajo /target, [ -e ] sigue los enlaces ABSOLUTOS hacia la raiz
#               DEL INSTALADOR. Por eso 'existe()' pregunta tambien por -L.
#               Corolario: un rc=0 de una late-command no dice NADA del
#               objetivo; lo unico que lo dice es el inventario de /target
#               antes y despues.
#   trampa  9 - Cada comprobacion lleva su control, y el control lleva su senal
#               de que llego a ejecutarse.
#   trampa  2 - Todo lo que consulte a apt va con LC_ALL=C.
#   trampa  8 - No se filtra a nadie por numero de UID.
#   §4.16e    - NADA de 'snap' desde aqui: curtin bind-monta /run, asi que el
#               cliente del chroot le habla al demonio del entorno VIVO y le
#               contesta por otra maquina. El Snap del objetivo se mira POR
#               FICHEROS bajo /target, nunca preguntandole a snapd.
#   §4.13     - Los .deb se comparan POR HUELLA, nunca por nombre: hay .deb con
#               la misma version y bytes distintos, y en salida/ de
#               encina-autofirma hay TRES candidatos.
#
# EL ORDEN, que es el de §4.17c-f y §4.31 con el paso 5 cambiado de signo:
#   1) el Snap se QUEDA   2) apt update      3) apt install encina-meta
#   4) apt update (ya con el repo de Mozilla que pone encina-firefox-native)
#   5) full-upgrade --allow-downgrades       6) apt install firefox-l10n-es-es

L=/target/var/log/encina-seed.log
RC=0

say() { echo "$*" >>"$L"; }
run() { say "\$ $*"; "$@" >>"$L" 2>&1; RC=$?; say "  rc=$RC"; }

# --- las huellas, que son la autoridad ---------------------------------------
# Si un .deb no coincide, se dice y se sigue: el registro tiene que contarlo,
# no taparlo. fabricar-seed.sh y fabricar-iso.sh las leen DE AQUI, para que el
# guion que las comprueba dentro y el que fabrica el medio no puedan separarse.
#
# LAS TRES DE ENCINA CAMBIARON EL 2026-08-13, Y EL CONTENIDO DE LOS PAQUETES NO
# (MEDICIONES.md §4.37). Son las que salen de construir desde el clon, y las
# anteriores -51b6603c…, 972ec932… y 86da3cc9…- eran de una construccion hecha
# en un arbol de trabajo, no de un paquete: 'dpkg-deb' RECORTA los mtimes
# posteriores a SOURCE_DATE_EPOCH y DEJA PASAR los anteriores, asi que las
# fechas que los ficheros tuvieran en el disco se colaban dentro del .deb. Ese
# dato no esta en git y no se puede reproducir desde un clon. Medido: mismo
# contenido huella a huella, mismos modos, duenos, tamanos y rutas; lo unico
# que cambia son las fechas, y por eso los tres .deb son ahora MAS PEQUENOS.
#
# Y LA MISMA TRAMPA VOLVIO A MORDER EL 2026-08-15, con encina-branding 0.1.13.
# La huella que se apunto aqui y en el manifiesto -bf821ee6…, 6943792 bytes- era
# otra vez de una construccion sobre el arbol de trabajo de encina-dev, y la CI
# lo canto: cinco ejecuciones en rojo desde 932bc5c. Medido: contenido identico
# -md5sums byte a byte igual, 'diff -r' del data.tar extraido en verde- y 22
# fechas distintas dentro del .deb de encina-dev contra UNA sola en el del
# runner. Reconstruido desde 'git archive HEAD' en encina-dev sale 4df508cd…,
# que es EXACTAMENTE la del runner amd64: la construccion si es reproducible
# entre arquitecturas; lo que no lo es es el arbol de trabajo.
#
# LA LECCION, que no es la huella sino el procedimiento: una huella que se
# apunte aqui tiene que salir de 'git archive HEAD', nunca de haber lanzado
# 03-construir.sh sobre el repositorio donde se estaba trabajando.
#
# ENMIENDA DEL 2026-08-15 (la de la tarde): H_BRANDING pasa a 0.1.14 -D21, el
# icono del Centro de aplicaciones- y esta vez la huella se saco siguiendo esa
# leccion, no despues de saltarsela. Salio de 'git archive HEAD' sobre un
# directorio nuevo de encina-dev, y con dos controles al lado: el data.tar
# lleva UNA sola fecha dentro -si llevara varias, vendria del arbol de
# trabajo- y dos pasadas desde dos commits distintos dan la misma huella
# 131c464e…, que es lo que hay que exigirle. El aviso escrito no evito nada
# las dos veces anteriores; lo que sirve es la comprobacion.
#
# SEGUNDA ENMIENDA DEL MISMO DIA: 0.1.14 duro tres cuartos de hora. Su icono
# NO SE PINTABA -en el dock habia un hueco- y el ritual hubo que pagarlo otra
# vez con 0.1.15, 6d9fcd64…, que es la que esta arriba. La causa no era el
# .deb ni la huella: gdk-pixbuf no reconoce un SVG cuyo '<svg' caiga mas alla
# del byte 256, y el comentario de cabecera lo empujaba al 2090 (§4.49).
# Se apunta aqui porque es el mismo sitio donde se apunta lo otro que cuesta
# una vuelta entera.
H_AUTOFIRMA=faeca3a9f0cf7a6e01a8d6ab28ae9fe6f56f6aa326287675701bd3962064cd6d
# TERCERA, 2026-08-23 (noche): 0.1.16, a8fcb1b9…, el drop-in de gdm.service que
# hace esperar a udev (MEDICIONES.md §4.70f, §4.71, §4.72, §4.73). Es el remedio
# del negro en hierro AMD y lo lleva el paquete; el medio con 0.1.15 necesitaba
# ponerlo a mano.
# CUARTA, 2026-08-24: 0.1.17, 6929df0e…, el desvio de la bellota (MEDICIONES.md
# §4.70c, §4.75, §4.76): el SVG de Encina servido tambien en la ruta de Yaru
# sobre un dpkg-divert del preinst, para que el modo oscuro -que escribe
# icon-theme='Yaru-<acento>' en el perfil del usuario y le gana al override-
# no se lleve la bellota del dock.
H_BRANDING=6929df0e69ac1c31c12a661a0ba35a038636983693fa3a00720afe742583ccd2
H_FFNATIVE=640f508e3802a2513a5be33ecab192e637f5c09f659d6273966458fe1fcc9925
H_META=204081f0ff3c5dc33481bbe4e3febccf3d289615f174270ca9b0d067e085f9b6

# existe(): -e para lo normal, -L para el enlace roto o absoluto (trampa 10)
existe() { [ -e "$1" ] || [ -L "$1" ]; }
mirar()  { if existe "$1"; then say "[PRESENTE] $1"; else say "[AUSENTE ] $1"; fi; }

huella() {  # $1 fichero  $2 huella esperada
    real=$(sha256sum "$1" 2>/dev/null | cut -d' ' -f1)
    if [ "$real" = "$2" ]; then
        say "[HUELLA  OK ] $1"
    else
        say "[HUELLA MALA] $1  esperada=$2  real=${real:-<no se pudo leer>}"
    fi
}

# EL INVENTARIO DEL SNAP, que en E4 cambia de signo: hasta E3 servia para
# ensenar que el purgado se lo habia llevado todo; ahora sirve para ensenar que
# NADIE lo ha tocado, que es la mitad de la convivencia (c) que se puede medir
# desde aqui. La otra mitad -que no exista ningun perfil de Mozilla bajo
# ~/snap/- no se puede mirar aqui, porque nadie ha abierto sesion todavia: es
# del verificador.
inventario_snap() {
    for f in /target/var/lib/snapd/snaps/firefox_7764.snap \
             /target/var/lib/snapd/seed/snaps/firefox_7764.snap \
             /target/var/lib/snapd/desktop/applications/firefox_firefox.desktop \
             /target/etc/systemd/system/snap-firefox-7764.mount \
             /target/etc/systemd/system/multi-user.target.wants/snap-firefox-7764.mount \
             /target/snap/firefox/current \
             /target/var/lib/snapd/state.json \
             /target/usr/bin/snap \
             /target/usr/bin/firefox
    do
        mirar "$f"
    done
    # la revision 7764 esta escrita arriba porque es la que trae ESTA ISO, pero
    # una revision distinta no puede hacer que el inventario mienta: se cuenta
    # tambien por comodin
    n=$(ls /target/var/lib/snapd/snaps/firefox_*.snap 2>/dev/null | wc -l)
    say "  snaps de firefox en el objetivo (por comodin): $n"
    # control del inventario: tiene que saber decir AUSENTE
    f=/target/var/lib/snapd/snaps/fichero-que-no-existe-jamas
    if existe "$f"; then say "[PRESENTE] $f  <- CONTROL ROTO"; else say "[AUSENTE ] $f  <- control"; fi
    # y tiene que saber decir PRESENTE, si no, no vale nada
    f=/target/usr/bin/gnome-shell
    if existe "$f"; then say "[PRESENTE] $f  <- control"; else say "[AUSENTE ] $f  <- CONTROL ROTO"; fi
    # LA TIENDA, desde el 2026-08-12 (D18 reescrita): es el snap snap-store, que
    # viaja PRE-SEMBRADO en el medio (MEDICIONES.md 4.16d) y NO es un .deb, asi
    # que no puede ir en un Depends ni comprobarse con dpkg-query. Se mira donde
    # de verdad esta: el .snap sembrado y su lanzador.
    for f in /target/var/lib/snapd/seed/snaps/snap-store_1271.snap \
             /target/var/lib/snapd/desktop/applications/snap-store_snap-store.desktop
    do
        mirar "$f"
    done
    n=$(ls /target/var/lib/snapd/seed/snaps/snap-store_*.snap 2>/dev/null | wc -l)
    say "  snaps de snap-store en el objetivo (por comodin): $n"
    # y la que YA NO tiene que estar, que es la otra mitad de la decision
    n=$(ls /target/usr/share/applications/org.gnome.Software.desktop 2>/dev/null | wc -l)
    say "  lanzadores de gnome-software (tiene que ser 0): $n"
}

# EL MANEJADOR DEL PDF, que es una medicion de DOS MITADES y no un fichero
# suelto (D17): se pregunta lo mismo antes y despues de instalar.
#
# Y SE PREGUNTA EN LAS DOS COLUMNAS, con y sin XDG_CURRENT_DESKTOP, porque la
# medicion de apertura (§4.26c) se hizo por ssh -- sin escritorio -- y eso
# CAMBIA la respuesta: los ficheros con nombre de escritorio delante
# (gnome-mimeapps.list) solo se leen si el escritorio se llama asi. Sin las dos
# columnas, este bloque diria "arreglado" o "no hacia falta" segun como se
# preguntara, que es la trampa 5 dentro del instrumento.
pdf_por_defecto() {  # $1 = etiqueta
    con=$(curtin in-target -- env LC_ALL=C XDG_CURRENT_DESKTOP=ubuntu:GNOME \
            xdg-mime query default application/pdf 2>/dev/null)
    sin=$(curtin in-target -- env -u XDG_CURRENT_DESKTOP LC_ALL=C \
            xdg-mime query default application/pdf 2>/dev/null)
    c=$(curtin in-target -- env LC_ALL=C XDG_CURRENT_DESKTOP=ubuntu:GNOME \
            xdg-mime query default application/x-tipo-que-no-existe-jamas 2>/dev/null)
    z=$(curtin in-target -- env LC_ALL=C XDG_CURRENT_DESKTOP=ubuntu:GNOME \
            xdg-mime query default application/zip 2>/dev/null)
    say "  [$1] application/pdf  con ubuntu:GNOME -> ${con:-<NINGUNO>}"
    say "  [$1] application/pdf  SIN escritorio   -> ${sin:-<NINGUNO>}"
    if [ -z "$c" ]; then
        say "  [$1] control: un tipo inventado -> <NINGUNO>  (sabe decir que no)"
    else
        say "  [$1] CONTROL ROTO: un tipo inventado contesta '$c'"
    fi
    if [ -n "$z" ]; then
        say "  [$1] control: application/zip -> $z  (sabe decir que si)"
    else
        say "  [$1] CONTROL ROTO: xdg-mime no contesta ni de application/zip"
    fi
    # el veredicto se queda con la peor de las dos columnas: si alguna de las
    # dos formas de preguntar da el navegador, el defecto no esta atado
    case "$con:$sin" in
        *firefox*) PDF_DEFECTO="$con|$sin|HAY-FIREFOX" ;;
        *)         PDF_DEFECTO="$con|$sin" ;;
    esac
}

mkdir -p /target/var/log
: >"$L"

say "=== Encina OS - E4 - seed completo (la convivencia (c) de D16) ==="
say ""
say "=== 0. ENTORNO DEL INSTALADOR (fuera del chroot) ==="
run date -u +%Y-%m-%dT%H:%M:%SZ
run uname -m
run id -u
run which curtin

say ""
say "=== 1. DONDE ESTA EL REPO: las dos vias, y se dice cual se uso ==="
# E2: el repo viaja en un volumen aparte etiquetado CIDATA, y se busca POR
#     ETIQUETA, nunca por /dev/vdX (§4.18g).
# E3: el repo viaja DENTRO de la ISO, y casper monta el medio en /cdrom, que
#     esta LEIDO en el casper de la propia ISO (§4.21c), no supuesto.
# Se prueban en ese orden a proposito: si alguien conecta un CIDATA a la ISO de
# E3, manda el CIDATA -- que es exactamente la precedencia que aplica el
# instalador con el seed (§4.21c), asi que las dos cosas se comportan igual.
run blkid
DEV=$(blkid -t LABEL=CIDATA -o device 2>/dev/null | head -1)
say "  CIDATA -> ${DEV:-<no encontrado>}"
REPO=
if [ -n "$DEV" ]; then
    mkdir -p /mnt/encina-seed
    run mount -o ro -t auto "$DEV" /mnt/encina-seed
    run ls -la /mnt/encina-seed/
    [ -d /mnt/encina-seed/encina-repo ] && REPO=/mnt/encina-seed/encina-repo
fi
if [ -z "$REPO" ] && [ -d /cdrom/encina-repo ]; then
    REPO=/cdrom/encina-repo
fi
say "  REPO ELEGIDO -> ${REPO:-<NINGUNO>}"
if [ -z "$REPO" ]; then
    say "  !! no hay repo por ninguna de las dos vias. Las huellas de mas abajo"
    say "  !! van a salir MALAS, que es como se vera esto sin tener que creerme."
    REPO=/repo-que-no-existe
fi
run ls -la "$REPO/"

say ""
say "=== 2. EL REPO LOCAL SIN FIRMAR, del volumen al objetivo ==="
# DESDE E4 ESTE REPO NO SON CUATRO .deb: lleva ademas todo lo que hasta hoy
# bajaba de internet -el JRE de autofirma, libnss3-tools, hunspell-es, el
# navegador y su idioma, la tienda y el escaner-, que es el nivel 3 de §4.27.
# Los cuatro de Encina se comprueban por huella uno a uno; de los demas
# responde el indice Packages, que apt verifica por SHA256 al instalarlos.
mkdir -p /target/srv/encina-repo
# OJO: el glob '*' es del interprete y NO casa con los ficheros que empiezan
# por punto, que es lo que deja fuera los AppleDouble '._x' que escribe macOS
# (§4.18m). Un 'cp -a' o un 'rsync' SI los meteria en el repositorio de apt.
run sh -c "cp $REPO/* /target/srv/encina-repo/"
run chmod 0755 /target/srv/encina-repo
run sh -c 'chmod 0644 /target/srv/encina-repo/*'
run sh -c "ls /target/srv/encina-repo/ | wc -l"
run sh -c "du -sh /target/srv/encina-repo"
say "-- las cuatro huellas de Encina, comparadas una a una:"
huella /target/srv/encina-repo/autofirma_1.9.1+encina4_all.deb      "$H_AUTOFIRMA"
huella /target/srv/encina-repo/encina-branding_0.1.17_all.deb       "$H_BRANDING"
huella /target/srv/encina-repo/encina-firefox-native_0.2.1_all.deb  "$H_FFNATIVE"
huella /target/srv/encina-repo/encina-meta_0.2.1_all.deb            "$H_META"
say "-- los dos controles del comparador de huellas, que tiene que saber decir MALA:"
huella /target/srv/encina-repo/encina-meta_0.2.1_all.deb \
       0000000000000000000000000000000000000000000000000000000000000000
huella /target/srv/encina-repo/fichero-que-no-existe-jamas "$H_META"

say ""
say "=== 3. LA FUENTE DE APT, en el objetivo ==="
echo 'deb [trusted=yes] file:/srv/encina-repo ./' >/target/etc/apt/sources.list.d/encina-local.list
run cat /target/etc/apt/sources.list.d/encina-local.list
run ls -la /target/etc/apt/sources.list.d/

say ""
say "=== 4. INVENTARIO DEL SNAP EN EL OBJETIVO, ANTES DE TOCAR NADA ==="
inventario_snap

say ""
say "=== 4bis. EL MANEJADOR DEL PDF, PRIMERA MITAD (antes de instalar nada) ==="
pdf_por_defecto ANTES
PDF_ANTES="$PDF_DEFECTO"
run curtin in-target -- sh -c "ls -la /etc/xdg/*mimeapps.list /etc/xdg/xdg-ubuntu/*mimeapps.list /usr/share/applications/*mimeapps.list 2>&1"

say ""
say "=== 5. EL SNAP SE QUEDA (D16, la convivencia (c)) ==="
# AQUI HABIA UN 'apt-get -y purge snapd' HASTA EL 2026-08-12, y no se ha
# aflojado: se ha cambiado de signo con su motivo (D16 de ENCINA-OS.md).
#   - Quitar el Snap nunca fue condicion de que la firma funcione: la maquina
#     donde salio la firma de §4.13 tenia el Snap dentro.
#   - La tienda que exige "un escritorio que crece" arrastra snapd de todas
#     formas (§4.26d), asi que la eleccion real no era tenerlo o no, sino
#     tenerlo DECLARADO o tenerlo por la puerta de atras.
#   - Lo que rompe es un Firefox de Snap que alguien ABRE: eso es el estado (d).
#     La defensa entera es que el unico icono que el usuario ve abre el nativo,
#     y de eso se ocupa encina-firefox-native con su sombra NoDisplay=true,
#     medida en los dos mundos (§4.19).
# NO se ejecuta ninguna orden 'snap' desde aqui, y no es prudencia: curtin
# bind-monta /run, asi que le hablaria al snapd del entorno VIVO (§4.16e).
say "  no se purga snapd: es la forma (c) de D16, decidida el 2026-08-11"
say "-- estado dpkg de lo que ANTES se purgaba, para que quede escrito:"
run curtin in-target -- dpkg -l snapd firefox
say "-- y el escritorio, que es lo que aquel purgado podia haberse llevado:"
run curtin in-target -- dpkg -l ubuntu-desktop-minimal gnome-shell

say ""
say "=== 6. INVENTARIO DEL SNAP, DESPUES DEL PASO 5 (tiene que ser IGUAL) ==="
inventario_snap
say "-- que hay de snapd en el objetivo:"
run ls -la /target/var/lib/snapd
run ls -la /target/snap
run sh -c "ls /target/etc/systemd/system/ | grep -i snap"

say ""
say "=== 7. HAY RED DESDE EL CHROOT? ==="
# Esto decide como se lee todo lo de abajo. Sin red, el nivel 3 de §4.27 es lo
# unico que sostiene la instalacion: los .deb tienen que salir del medio.
run curtin in-target -- getent hosts ports.ubuntu.com
run curtin in-target -- getent hosts packages.mozilla.org
say "-- control: un nombre que no existe tiene que fallar"
run curtin in-target -- getent hosts nombre-que-no-existe.encina.invalid
run curtin in-target -- cat /etc/resolv.conf

say ""
say "=== 8. PASO 1: apt update con el repo local ==="
run curtin in-target -- env DEBIAN_FRONTEND=noninteractive LC_ALL=C apt-get update
say "-- el candidato sale del repo local:"
run curtin in-target -- env LC_ALL=C apt-cache policy encina-meta
say "-- control: un paquete que no existe tiene que salir vacio"
run curtin in-target -- env LC_ALL=C apt-cache policy encina-paquete-que-no-existe
say "-- y lo que el nivel 3 tiene que haber puesto al alcance de apt:"
for p in openjdk-17-jre-headless libnss3-tools hunspell-es firefox firefox-l10n-es-es \
         simple-scan
do
    run curtin in-target -- env LC_ALL=C apt-cache policy "$p"
done

say ""
say "=== 9. UN SOLO NOMBRE: apt install encina-meta ==="
say "-- primero la simulacion, que es lo que ensena de donde sale cada cosa:"
run curtin in-target -- env LC_ALL=C apt-get -s install encina-meta
run curtin in-target -- env DEBIAN_FRONTEND=noninteractive LC_ALL=C apt-get -y install encina-meta
say "-- los cuatro de Encina, por estado dpkg:"
run curtin in-target -- dpkg-query -W -f='${Package} ${Version} ${Status}\n' \
    encina-meta encina-branding encina-firefox-native autofirma
say "-- y las aplicaciones de D17/D18. La tienda NO esta en esta lista y no es
-- un olvido: desde el 2026-08-12 es el snap snap-store, que viaja pre-sembrado
-- en el medio y no es un .deb. Se comprueba en el bloque 12, con snap list."
run curtin in-target -- dpkg-query -W -f='${Package} ${Version} ${Status}\n' \
    simple-scan sane-airscan
say "-- las marcas, que son lo que decide la casilla del autoremove:"
run curtin in-target -- sh -c "apt-mark showauto   | grep -E '^(encina-|autofirma)'"
run curtin in-target -- sh -c "apt-mark showmanual | grep -E '^(encina-|autofirma)'"

say ""
say "=== 10. PASO 2: apt update, ya con el repo de Mozilla ==="
run curtin in-target -- ls -la /etc/apt/sources.list.d/
run curtin in-target -- sh -c "cat /etc/apt/preferences.d/*"
run curtin in-target -- env DEBIAN_FRONTEND=noninteractive LC_ALL=C apt-get update
say "-- el anclaje manda? candidato 153.0.3~build1 a 1000, no el 1:1snap1 a 500:"
run curtin in-target -- env LC_ALL=C apt-cache policy firefox

say ""
say "=== 11. PASO 3: full-upgrade, Y AQUI ESTA LA MINA (--allow-downgrades) ==="
# CON SNAP (que desde D16 son todas) este paso es EL paso: sustituye el .deb de
# transicion 'firefox 1:1snap1-...' por el de Mozilla, y eso es un downgrade
# FORMAL por el epoch '1:' (§4.10c). Sin --allow-downgrades, apt -y se niega.
# Sin Snap el argumento sobra y no estorba: no hay nada que degradar.
say "-- primero la simulacion, para que quede escrito lo que propone:"
run curtin in-target -- env LC_ALL=C apt-get -s full-upgrade --allow-downgrades
run curtin in-target -- env DEBIAN_FRONTEND=noninteractive LC_ALL=C apt-get -y \
    --allow-downgrades \
    -o Dpkg::Options::=--force-confold -o Dpkg::Options::=--force-confdef full-upgrade
run curtin in-target -- env LC_ALL=C apt-cache policy firefox

say ""
say "=== 11bis. RED DE SEGURIDAD: si el navegador sigue siendo el del Snap ==="
# POR QUE EXISTE ESTE BLOQUE, y no es cinturon y tirantes: SIN RED el repo de
# Mozilla no se puede leer, asi que su anclaje de prioridad 1000 no aplica a
# nada, y entre el 1:1snap1 de los indices viejos de ports (500) y el
# 153.0.3~build1 de nuestro repo local (500) gana el epoch, o sea el del Snap.
# Con red este bloque no hace nada y lo dice. Sin el, una instalacion sin red
# acabaria en el estado (d) -el que no firma- por una razon de prioridades que
# no se ve en ningun rc.
V=$(curtin in-target -- dpkg-query -W -f='${Version}' firefox 2>/dev/null)
say "  firefox instalado tras el full-upgrade: ${V:-<ninguno>}"
case "$V" in
    1:*|"")
        say "  !! sigue siendo el deb de transicion (o no hay ninguno): se coge del repo local"
        VL=$(sed -n '/^Package: firefox$/,/^$/p' /target/srv/encina-repo/Packages 2>/dev/null \
             | sed -n 's/^Version: //p' | head -1)
        say "  version que ofrece el repo local: ${VL:-<no esta en el indice>}"
        if [ -n "$VL" ]; then
            run curtin in-target -- env DEBIAN_FRONTEND=noninteractive LC_ALL=C apt-get -y \
                --allow-downgrades \
                -o Dpkg::Options::=--force-confold -o Dpkg::Options::=--force-confdef \
                install "firefox=$VL"
        else
            say "  !! el repo local no trae firefox: el nivel 3 de §4.27 esta incompleto"
        fi
        ;;
    *)  say "  el navegador ya es el de Mozilla (sin epoch): este bloque no hace nada" ;;
esac

say ""
say "=== 12. PASO 4: firefox-l10n-es-es (CON Snap esto SI es solo el idioma) ==="
# OJO AL LEER ESTO DENTRO DE SEIS MESES: en E2/E3, SIN Snap, este paso era el
# NAVEGADOR ENTERO (§4.17f). Con la convivencia (c) vuelve a ser solo el
# idioma, porque el navegador lo trae el paso 11. Quitarlo sigue sin ser
# gratis: deja el navegador en ingles.
run curtin in-target -- env LC_ALL=C apt-cache show firefox-l10n-es-es
run curtin in-target -- env DEBIAN_FRONTEND=noninteractive LC_ALL=C apt-get -y \
    -o Dpkg::Options::=--force-confold -o Dpkg::Options::=--force-confdef \
    install firefox-l10n-es-es

say ""
say "=== 13. ESTADO FINAL DEL OBJETIVO ==="
run curtin in-target -- dpkg-query -W -f='${Package} ${Version}\n' firefox firefox-l10n-es-es
say "-- version SIN epoch = es el de Mozilla; con 1: = sigue el deb de transicion"
run curtin in-target -- sh -c "ls -l /usr/bin/firefox; readlink -f /usr/bin/firefox"
run curtin in-target -- dpkg -S /usr/bin/firefox
say "-- control de dpkg -S, que tiene que saber contestar de otro fichero:"
run curtin in-target -- dpkg -S /usr/bin/gnome-shell
run curtin in-target -- sh -c "dpkg -L firefox-l10n-es-es | grep xpi"
say "-- los dos lanzadores de Firefox que van a competir en la rejilla:"
run curtin in-target -- sh -c "ls -la /usr/share/applications/firefox*.desktop /var/lib/snapd/desktop/applications/firefox*.desktop 2>&1"
run curtin in-target -- sh -c "grep -H '^NoDisplay' /usr/share/applications/firefox_firefox.desktop 2>&1"
inventario_snap

say ""
say "=== 13bis. EL MANEJADOR DEL PDF, SEGUNDA MITAD ==="
run curtin in-target -- sh -c "ls -la /etc/xdg/*mimeapps.list /etc/xdg/xdg-ubuntu/*mimeapps.list /usr/share/applications/*mimeapps.list 2>&1"
run curtin in-target -- sh -c "dpkg -S /etc/xdg/mimeapps.list 2>&1"
say "-- control de dpkg -S: tiene que saber decir de quien es otro fichero"
run curtin in-target -- sh -c "dpkg -S /usr/share/applications/gnome-mimeapps.list 2>&1"
pdf_por_defecto DESPUES
PDF_DESPUES="$PDF_DEFECTO"
say "  ANTES='${PDF_ANTES:-<NINGUNO>}'   DESPUES='${PDF_DESPUES:-<NINGUNO>}'"

say ""
say "=== 14. EL VEREDICTO: el seed comprueba lo que ha dejado, y lo dice ==="
# POR QUE EXISTE ESTE BLOQUE (MEDICIONES.md §4.27):
#
# Hasta el 2026-08-11 este guion hacia seis pasos, apuntaba seis 'rc' en un
# fichero que nadie lee, y escribia el testigo de "llegue al final" aunque no
# hubiera llegado nada mas. SIN RED no entraba NI UNO de los cuatro .deb -- apt
# es todo o nada -- y la instalacion terminaba diciendo que fue bien. Es la
# trampa 5: la misma respuesta en un sistema sano y en uno roto.
#
# UN rc=0 NO DICE NADA DEL OBJETIVO (trampa 10). Lo que lo dice es el objetivo,
# preguntado por dpkg, que es exactamente lo que hace esto. Y lleva su control,
# porque un comprobador que dijera "lo tiene" a todo valdria lo mismo que nada.
FALTA=""
tiene() {  # $1 = paquete. Anota en FALTA lo que no este instalado.
    est=$(curtin in-target -- dpkg-query -W -f='${Status}' "$1" 2>/dev/null)
    case "$est" in
        *"install ok installed"*) say "[TIENE   ] $1" ;;
        *) say "[NO TIENE] $1  estado=${est:-<no instalado>}"; FALTA="$FALTA $1" ;;
    esac
}
for p in encina-meta encina-branding encina-firefox-native autofirma \
         firefox firefox-l10n-es-es \
         simple-scan sane-airscan \
         snapd
do
    tiene "$p"
done
say "-- control: un paquete inventado tiene que salir NO TIENE"
ANTES="$FALTA"
tiene encina-paquete-que-no-existe-jamas
if [ "$FALTA" = "$ANTES" ]; then
    say "[CONTROL ROTO] dice TENER un paquete que no existe: el veredicto no vale"
    FALTA="$FALTA comprobador-roto"
else
    say "[control  OK ] sabe decir que no"
    FALTA="$ANTES"
fi

say "-- y que navegador queda, que es lo que se lleva el usuario:"
V=$(curtin in-target -- dpkg-query -W -f='${Version}' firefox 2>/dev/null)
D=$(curtin in-target -- readlink -f /usr/bin/firefox 2>/dev/null)
say "  firefox version=${V:-<ninguno>}   /usr/bin/firefox -> ${D:-<no existe>}"
# version con epoch '1:' = sigue siendo el deb de transicion al Snap (§4.10);
# destino bajo /snap/ = el navegador que se abre es el confinado, que es B3 y B4
case "$V" in
    1:*) say "  !! es el deb de transicion al Snap, no el de Mozilla"
         FALTA="$FALTA firefox-de-transicion" ;;
esac
case "$D" in
    /snap/*) say "  !! el navegador cae dentro de /snap/"
             FALTA="$FALTA firefox-dentro-de-snap" ;;
esac

say "-- la forma (c) de D16: el Snap de Firefox tiene que SEGUIR ahi"
NSNAP=$(ls /target/var/lib/snapd/snaps/firefox_*.snap 2>/dev/null | wc -l)
say "  snaps de firefox en el objetivo: $NSNAP"
if [ "$NSNAP" -lt 1 ]; then
    say "  !! no queda ningun Snap de Firefox: esto NO es la forma (c) de D16"
    FALTA="$FALTA snap-de-firefox-ausente"
fi

say "-- el manejador del PDF, que es lo que D17 ata (las DOS columnas)"
case "$PDF_DESPUES" in
    ""|"|")      say "  !! application/pdf no resuelve a nada"
                 FALTA="$FALTA pdf-sin-manejador" ;;
    *HAY-FIREFOX*) say "  !! application/pdf resuelve al navegador por alguna de las dos vias"
                 FALTA="$FALTA pdf-a-firefox" ;;
    *)           say "  application/pdf -> $PDF_DESPUES" ;;
esac

if [ -z "$FALTA" ]; then ESTADO=COMPLETO; else ESTADO=INCOMPLETO; fi
say "  ESTADO -> $ESTADO   FALTA ->${FALTA:- nada}"

{
    echo "# Encina OS. Lo escribe imagen/encina-seed.sh al terminar la instalacion."
    echo "#"
    echo "# COMPLETO   = esta el conjunto entero: los cuatro paquetes de Encina, un"
    echo "#              Firefox NATIVO, el Snap de Firefox instalado y sin abrir"
    echo "#              (la forma (c) de D16), la tienda, el escaner y el PDF atado."
    echo "# INCOMPLETO = a esta maquina le falta algo, y esta escrito cual."
    echo "#              Desde el 2026-08-12 esto ademas HACE FALLAR la instalacion:"
    echo "#              ver /etc/encina-seed.log y MEDICIONES.md §4.31."
    echo "#"
    echo "# El detalle, paso a paso, esta en /etc/encina-seed.log."
    echo "ENCINA_ESTADO=$ESTADO"
    echo "ENCINA_FALTA=${FALTA# }"
    echo "ENCINA_PDF_ANTES=${PDF_ANTES:-<NINGUNO>}"
    echo "ENCINA_PDF_DESPUES=${PDF_DESPUES:-<NINGUNO>}"
    echo "ENCINA_FECHA=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
} >/target/etc/encina-estado
run cat /target/etc/encina-estado

say ""
say "=== 15. FIN ==="
run date -u +%Y-%m-%dT%H:%M:%SZ

umount /mnt/encina-seed 2>/dev/null

# copia a un sitio obvio, y testigo de que este guion llego al final. El testigo
# dice ADEMAS con que estado llego: "llegue al final" era verdad y aun asi no
# significaba que la maquina estuviera entera.
cp "$L" /target/etc/encina-seed.log 2>/dev/null
echo "encina-seed llego al final $(date -u +%Y-%m-%dT%H:%M:%SZ) estado=$ESTADO" \
    >/target/etc/encina-e2-testigo-seed

# EL NIVEL 2 DE §4.27, PUESTO EL 2026-08-12 Y NO ANTES.
#
# Este guion llevaba escrito en su cabecera "NUNCA sale distinto de 0" desde
# §4.16, y esa era una regla DEL INSTRUMENTO: se escribio para no quedarse sin
# datos midiendo -una late-command que aborta se lleva la instalacion por
# delante- y acabo dentro de la ISO que se entrega. Tercera vez que este
# proyecto encuentra un criterio de validacion disfrazado de producto.
#
# LO QUE FALTABA PARA PONERLO ERA SABER QUE HACE SUBIQUITY, Y AHORA ESTA LEIDO
# -- en el codigo que viaja dentro de esta misma ISO, como se leyo lo del clic
# en §4.16a, y no supuesto:
#
#   cmdlist.py:50-61   CmdListController.cmd_check = True, y LateController NO
#                      lo cambia (ErrorController si: cmd_check = False). Asi
#                      que arun_command(..., check=True) LANZA si salimos != 0.
#   install.py:628-639 el Late.run() va DESPUES de curtin_install() y de
#                      postinstall(); la excepcion se recoge, se escribe un
#                      apport de tipo INSTALL_FAIL con el texto "install
#                      failed", y se relanza.
#   server.py:487,513  el manejador de ultimo nivel pone
#                      ApplicationState.ERROR, en las dos formas: interactiva
#                      (E3, que lleva interactive-sections) y no interactiva.
#   installprogress.py:189  el estado ERROR se ve como "An error occurred
#                      during installation", con "Reboot Now" habilitado.
#
# Las tres consecuencias, y son las que hacen que esto se pueda poner:
#   1. SE VE. Es exactamente lo que pedia el nivel 2.
#   2. LA MAQUINA SIGUE AHI Y ARRANCA: el fallo ocurre despues de instalar y de
#      postinstall, o sea que el disco esta hecho y el GRUB puesto.
#   3. ESTE REGISTRO SOBREVIVE DENTRO. Por eso el orden de arriba no es
#      casual: el log, /etc/encina-estado y el testigo se escriben ANTES de
#      esta linea, para que quien arranque la maquina pueda leer QUE falta.
#
# Lo que sigue sin estar medido, y se dice: no se ha visto esta pantalla con
# los ojos. Lo leido es el codigo de ESTA ISO, no una captura.
[ "$ESTADO" = COMPLETO ] || exit 1
exit 0
