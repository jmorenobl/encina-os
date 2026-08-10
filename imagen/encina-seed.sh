#!/bin/sh
# Encina OS - E2. Todo el trabajo del seed, en UNA SOLA late-command.
#
# COMO CORRE ESTO, que condiciona cada linea:
#
#   - Corre en el ENTORNO DEL INSTALADOR (fuera del chroot), con el sistema
#     instalado montado en /target. Lo que toque el objetivo va por
#     'curtin in-target', y lo que mire el objetivo mira /target DESDE FUERA.
#   - NUNCA sale distinto de 0. Una late-command que aborta se lleva la
#     instalacion por delante y deja la medicion sin datos (§4.16).
#   - Deja su propio registro dentro de /target, porque cada intento cuesta una
#     instalacion entera y no se puede depurar a medias.
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
#   §4.13     - Los .deb se comparan POR HUELLA, nunca por nombre: hay .deb con
#               la misma version y bytes distintos.
#
# EL ORDEN NO ES ARBITRARIO. Es el de MEDICIONES.md §4.16g y §4.17c-f, que se
# midio a mano en ese orden sobre una maquina sin Snap:
#   1) purgar snapd     2) apt update      3) apt install encina-meta
#   4) apt update (ya con el repo de Mozilla que pone encina-firefox-native)
#   5) apt full-upgrade 6) apt install firefox-l10n-es-es
# El paso 6 NO es "el idioma": en una maquina sin Snap es el navegador entero
# (§4.17f). Quitarlo deja la maquina sin ningun Firefox.

L=/target/var/log/encina-seed.log
RC=0

say() { echo "$*" >>"$L"; }
run() { say "\$ $*"; "$@" >>"$L" 2>&1; RC=$?; say "  rc=$RC"; }

# --- las huellas de §4.15, que son la autoridad -----------------------------
# Si un .deb no coincide, se dice y se sigue: el registro tiene que contarlo,
# no taparlo.
H_AUTOFIRMA=d5a0ebe11a45a738f5d406e60ba2226d6e7c8d03df2eebb07b50843e92c79d03
H_BRANDING=d4205134392abd5c345b13d9977f27034fbcd9f083e941a1795fa2dd1ab21a10
H_FFNATIVE=972ec9323140d9aa7522be8a3608ff751b042725a3111154321ea1f304b999f2
H_META=e15ce56f1e7a43f1eb37daa1a6454e837ca2d54e7423cd1adfaaa4a065b13327

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
    # control del inventario: tiene que saber decir AUSENTE
    f=/target/var/lib/snapd/snaps/fichero-que-no-existe-jamas
    if existe "$f"; then say "[PRESENTE] $f  <- CONTROL ROTO"; else say "[AUSENTE ] $f  <- control"; fi
    # y tiene que saber decir PRESENTE, si no, no vale nada
    f=/target/usr/bin/gnome-shell
    if existe "$f"; then say "[PRESENTE] $f  <- control"; else say "[AUSENTE ] $f  <- CONTROL ROTO"; fi
}

mkdir -p /target/var/log
: >"$L"

say "=== Encina OS - E2 - seed completo ==="
say ""
say "=== 0. ENTORNO DEL INSTALADOR (fuera del chroot) ==="
run date -u +%Y-%m-%dT%H:%M:%SZ
run uname -m
run id -u
run which curtin

say ""
say "=== 1. EL VOLUMEN DEL SEED, localizado POR ETIQUETA (no por /dev/vdX) ==="
run blkid
DEV=$(blkid -t LABEL=CIDATA -o device 2>/dev/null | head -1)
say "  CIDATA -> ${DEV:-<no encontrado>}"
mkdir -p /mnt/encina-seed
run mount -o ro -t auto "$DEV" /mnt/encina-seed
run ls -la /mnt/encina-seed/
run ls -la /mnt/encina-seed/encina-repo/

say ""
say "=== 2. EL REPO LOCAL SIN FIRMAR, del volumen al objetivo ==="
mkdir -p /target/srv/encina-repo
run sh -c 'cp /mnt/encina-seed/encina-repo/* /target/srv/encina-repo/'
run chmod 0755 /target/srv/encina-repo
run sh -c 'chmod 0644 /target/srv/encina-repo/*'
run ls -la /target/srv/encina-repo/
say "-- huellas de §4.15, comparadas una a una:"
huella /target/srv/encina-repo/autofirma_1.9.1+encina2_all.deb      "$H_AUTOFIRMA"
huella /target/srv/encina-repo/encina-branding_0.1.7_all.deb        "$H_BRANDING"
huella /target/srv/encina-repo/encina-firefox-native_0.2.1_all.deb  "$H_FFNATIVE"
huella /target/srv/encina-repo/encina-meta_0.1.1_all.deb            "$H_META"
say "-- los dos controles del comparador de huellas, que tiene que saber decir MALA:"
huella /target/srv/encina-repo/encina-meta_0.1.1_all.deb \
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
say "=== 5. QUITAR EL SNAP (la orden medida en §4.16g, literal) ==="
run curtin in-target -- env DEBIAN_FRONTEND=noninteractive LC_ALL=C apt-get -y purge snapd

say ""
say "=== 6. INVENTARIO DEL SNAP, DESPUES DEL PURGADO ==="
inventario_snap
say "-- que queda de snapd en el objetivo:"
run ls -la /target/var/lib/snapd
run ls -la /target/snap
run sh -c "ls /target/etc/systemd/system/ | grep -i snap"
say "-- estado dpkg (lo que decide, no el grep de §4.16h):"
run curtin in-target -- dpkg -l snapd firefox
say "-- y el escritorio sigue declarado?"
run curtin in-target -- dpkg -l ubuntu-desktop-minimal gnome-shell

say ""
say "=== 7. HAY RED DESDE EL CHROOT? (esto NO estaba medido) ==="
run curtin in-target -- getent hosts ports.ubuntu.com
run curtin in-target -- getent hosts packages.mozilla.org
say "-- control: un nombre que no existe tiene que fallar"
run curtin in-target -- getent hosts nombre-que-no-existe.encina.invalid
run curtin in-target -- cat /etc/resolv.conf

say ""
say "=== 8. PASO 1 EN LA FORMA DE E2: apt update con el repo local ==="
run curtin in-target -- env DEBIAN_FRONTEND=noninteractive LC_ALL=C apt-get update
say "-- el candidato sale del repo local:"
run curtin in-target -- env LC_ALL=C apt-cache policy encina-meta
say "-- control: un paquete que no existe tiene que salir vacio"
run curtin in-target -- env LC_ALL=C apt-cache policy encina-paquete-que-no-existe

say ""
say "=== 9. UN SOLO NOMBRE: apt install encina-meta ==="
run curtin in-target -- env DEBIAN_FRONTEND=noninteractive LC_ALL=C apt-get -y install encina-meta
say "-- los cuatro, por estado dpkg:"
run curtin in-target -- dpkg-query -W -f='${Package} ${Version} ${Status}\n' \
    encina-meta encina-branding encina-firefox-native autofirma
say "-- las marcas, que son lo que decide la casilla:"
run curtin in-target -- sh -c "apt-mark showauto   | grep -E '^(encina-|autofirma)'"
run curtin in-target -- sh -c "apt-mark showmanual | grep -E '^(encina-|autofirma)'"

say ""
say "=== 10. PASO 2 DE §6.4: apt update, ya con el repo de Mozilla ==="
run curtin in-target -- ls -la /etc/apt/sources.list.d/
run curtin in-target -- sh -c "cat /etc/apt/preferences.d/*"
run curtin in-target -- env DEBIAN_FRONTEND=noninteractive LC_ALL=C apt-get update
say "-- el anclaje manda? candidato 153.0.3~build1 a 1000, no el 1:1snap1 a 500:"
run curtin in-target -- env LC_ALL=C apt-cache policy firefox

say ""
say "=== 11. PASO 3 DE §6.4: full-upgrade (sin Snap NO trae Firefox, §4.17e) ==="
say "-- primero la simulacion, para que quede escrito lo que propone:"
run curtin in-target -- env LC_ALL=C apt-get -s full-upgrade
run curtin in-target -- env DEBIAN_FRONTEND=noninteractive LC_ALL=C apt-get -y \
    -o Dpkg::Options::=--force-confold -o Dpkg::Options::=--force-confdef full-upgrade
run curtin in-target -- env LC_ALL=C apt-cache policy firefox

say ""
say "=== 12. PASO 4 DE §6.4: firefox-l10n-es-es, QUE AQUI ES EL NAVEGADOR ==="
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
inventario_snap

say ""
say "=== 14. FIN ==="
run date -u +%Y-%m-%dT%H:%M:%SZ

umount /mnt/encina-seed 2>/dev/null

# copia a un sitio obvio, y testigo de que este guion llego al final
cp "$L" /target/etc/encina-seed.log 2>/dev/null
echo "encina-seed llego al final $(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    >/target/etc/encina-e2-testigo-seed

exit 0
