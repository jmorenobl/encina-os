#!/usr/bin/env bash
# Encina OS - E2. Verifica la maquina que produce imagen/autoinstall.yaml.
#
# Se ejecuta EN LA MAQUINA INSTALADA, arrancada de su disco, y COMO ROOT:
#
#     sudo ./verificar-e2.sh
#
# Root no es capricho: /var/log/installer/telemetry es 0600 de root, y es la
# comprobacion que distingue una instalacion gobernada por un seed de una
# contestada a mano (§4.14g). Lo demas funciona igual sin privilegios.
#
# Cada comprobacion trae escrito que da en un sistema sano y que en uno roto, y
# las que pueden mentir traen su CONTROL, que es una comprobacion hermana cuya
# respuesta conocemos de antemano. Sin el control, un [OK] no dice nada
# (SCRIPTS.md, trampas 5, 8, 9 y 11).
#
# LO QUE ESTE SCRIPT NO PUEDE DECIR, y no lo finge: si alguien pulso algo
# durante la instalacion. 'telemetry' no detecta el clic de confirmacion
# (§4.14g). Eso se demuestra desde fuera, con la maquina apagandose sola.

set -uo pipefail

N_OK=0; N_MAL=0; N_AVI=0; N_OMI=0
titulo()  { echo; echo "=== $* ==="; }
ok()      { N_OK=$((N_OK+1));   echo "  [OK]     $*"; }
aviso()   { N_AVI=$((N_AVI+1)); echo "  [AVISO]  $*"; }
omitido() { N_OMI=$((N_OMI+1)); echo "  [OMIT]   $*"; }
fallo()   { N_MAL=$((N_MAL+1)); echo "  [FALLO]  $1"; [ -n "${2:-}" ] && echo "$2" | sed 's/^/           | /'; }

# igual "que se comprueba" "esperado" "obtenido"
igual() { if [ "$2" = "$3" ]; then ok "$1 ($3)"; else fallo "$1" "esperado: $2
obtenido: $3"; fi; }

# resolver_desktop: la precedencia REAL de un lanzador, preguntandosela a la
# misma biblioteca que dibuja la rejilla. El 'except TypeError' costo una
# casilla: sin el, NINGUNA no se puede imprimir jamas (§4.16i, trampa 11).
# XDG_DATA_DIRS por defecto incluye el directorio del Snap, o sea que es el
# valor MAS FAVORABLE al Snap: un NINGUNA aqui es mas fuerte, no mas debil.
resolver_desktop() {
    XDG_DATA_DIRS=/usr/share/ubuntu:/usr/share/gnome:/usr/local/share/:/usr/share/:/var/lib/snapd/desktop \
    XDG_CURRENT_DESKTOP=ubuntu:GNOME \
    python3 - "$1" <<'PY' 2>/dev/null || echo "?"
import sys, gi
gi.require_version("Gio", "2.0")
from gi.repository import Gio
try:
    a = Gio.DesktopAppInfo.new(sys.argv[1])
except TypeError:
    a = None
print(a.get_commandline() if a else "NINGUNA")
PY
}

# esta() usa -e y tambien -L: un enlace roto o absoluto tiene que contar como
# presente, que es la trampa 10 llevada a la maquina ya arrancada
esta() { [ -e "$1" ] || [ -L "$1" ]; }

titulo "0. Quien contesta (por huella, que el nombre no distingue nada)"
echo "  hostname: $(hostname)     kernel: $(uname -m)     $(lsb_release -ds 2>/dev/null)"
if [ "$(id -u)" = 0 ]; then ok "corriendo como root, se puede leer telemetry"
else aviso "no eres root: la casilla de telemetry saldra [OMIT]"; fi

titulo "1. La instalacion la goberno un seed"
# sano: dos entradas, 'loading' y 'done'. roto: aparecen identity, storage o
# confirm, que son las pantallas que contesta un humano (§4.14g).
T=/var/log/installer/telemetry
if [ -r "$T" ]; then
    ETAPAS=$(python3 -c 'import json,sys;print(",".join(sorted(json.load(open(sys.argv[1]))["Stages"].values())))' "$T" 2>/dev/null)
    igual "las etapas por las que paso el instalador" "done,loading" "$ETAPAS"
    if grep -qE '"(identity|storage|confirm|keyboard)"' "$T"; then
        fallo "hay pantallas de instalacion a mano en telemetry" "$(cat "$T")"
    else
        ok "no aparece ninguna pantalla contestada a mano"
    fi
else
    omitido "no se puede leer $T (hace falta root)"
fi
for t in /etc/encina-e2-testigo-instalador /etc/encina-e2-testigo-in-target /etc/encina-e2-testigo-seed; do
    if esta "$t"; then ok "testigo $(basename "$t"): $(cat "$t")"; else fallo "falta el testigo $t"; fi
done
# CONTROL: la comprobacion de testigos tiene que saber decir que no
if esta /etc/encina-e2-testigo-que-no-existe; then
    fallo "CONTROL ROTO: existe un testigo que nadie escribio"
else
    ok "control: un testigo que no se escribio nunca sale ausente"
fi

titulo "2. Sin Snap (tres cosas, no dos; §6bis.3)"
# sano: no hay orden snap, no hay lanzador, y el identificador del Snap no
# resuelve a nada. roto: cualquiera de las tres presente.
if command -v snap >/dev/null 2>&1; then
    fallo "existe la orden snap" "$(command -v snap)"
else
    ok "no existe la orden snap"
fi
# CONTROL del command -v, que si no responde 'ausente' a todo
if command -v bash >/dev/null 2>&1; then ok "control: command -v bash -> $(command -v bash)"
else fallo "CONTROL ROTO: no encuentra ni bash"; fi
for d in /var/lib/snapd/desktop/applications/firefox_firefox.desktop /var/lib/snapd /snap; do
    if esta "$d"; then fallo "sigue estando $d"; else ok "no existe $d"; fi
done
R=$(resolver_desktop firefox_firefox.desktop)
igual "a que resuelve firefox_firefox.desktop" "NINGUNA" "$R"
# CONTROL: el resolvedor tiene que saber resolver algo, o el NINGUNA no vale
RC_CTL=$(resolver_desktop org.gnome.Nautilus.desktop)
case "$RC_CTL" in
    NINGUNA|\?) fallo "CONTROL ROTO: el resolvedor no resuelve ni Nautilus" "$RC_CTL" ;;
    *)          ok "control: org.gnome.Nautilus.desktop -> $RC_CTL" ;;
esac
# y el estado dpkg, que es lo que decide: 'dpkg -l | grep -i snap' da falsa
# alarma con libsnapd-glib, gir1.2-snapd-2, xdg-desktop-portal y una extension
# de GNOME que ordena ventanas (§4.16h)
igual "estado dpkg de snapd" "un" "$(dpkg-query -W -f='${db:Status-Abbrev}' snapd 2>/dev/null | tr -d ' ')"

titulo "3. Firefox es el nativo y esta en espanol"
# sano: version SIN epoch y /usr/bin/firefox fuera de /snap/.
# roto: version 1:... = sigue siendo el deb de transicion, y entonces todo lo
# demas de esta lista puede estar verde igualmente.
V=$(dpkg-query -W -f='${Version}' firefox 2>/dev/null)
case "$V" in
    "")  fallo "no hay ningun paquete firefox instalado" ;;
    1:*) fallo "firefox es el deb de transicion al Snap" "Version: $V" ;;
    *)   ok "firefox $V (sin epoch: es el de Mozilla)" ;;
esac
DESTINO=$(readlink -f /usr/bin/firefox 2>/dev/null)
case "$DESTINO" in
    /snap/*) fallo "/usr/bin/firefox cae dentro de /snap/" "$DESTINO" ;;
    "")      fallo "no existe /usr/bin/firefox" ;;
    *)       ok "/usr/bin/firefox -> $DESTINO" ;;
esac
XPI=/usr/lib/firefox/distribution/extensions/langpack-es-ES@firefox.mozilla.org.xpi
if esta "$XPI"; then ok "el idioma esta puesto: $(basename "$XPI")"; else fallo "falta el paquete de idioma" "$XPI"; fi
# el anclaje, que es lo que impide que un apt upgrade futuro devuelva el Snap
POL=$(LC_ALL=C apt-cache policy firefox 2>/dev/null)
if grep -qE '^\s+1000 https://packages\.mozilla\.org' <<<"$POL"; then
    ok "el anclaje de Mozilla sigue a prioridad 1000"
else
    fallo "el anclaje de Mozilla no manda" "$POL"
fi

titulo "4. El repo local sin firmar y los cuatro paquetes"
LISTA=/etc/apt/sources.list.d/encina-local.list
if esta "$LISTA"; then ok "$LISTA: $(cat "$LISTA")"; else fallo "no esta $LISTA"; fi
for p in encina-meta encina-branding encina-firefox-native autofirma; do
    E=$(dpkg-query -W -f='${Version} ${Status}' "$p" 2>/dev/null)
    case "$E" in
        *"install ok installed") ok "$p $E" ;;
        *)                       fallo "$p no esta instalado" "${E:-<no se ha encontrado el paquete>}" ;;
    esac
done
# las marcas: solo encina-meta manual, los otros tres automaticos. Es lo que
# hace que 'apt purge encina-meta' + 'autoremove' se lleve a los tres (§4.15).
AUTO=$(apt-mark showauto   | grep -cE '^(autofirma|encina-branding|encina-firefox-native)$')
MAN=$(apt-mark  showmanual | grep -cE '^encina-meta$')
igual "dependientes marcados automaticos" "3" "$AUTO"
igual "encina-meta marcado manual"        "1" "$MAN"
# CONTROL: las marcas se leen de verdad y no salen 0 siempre
igual "control: encina-meta NO esta en showauto" "0" "$(apt-mark showauto | grep -cE '^encina-meta$')"

titulo "5. La maquina llega entera"
igual "systemctl is-system-running" "running" "$(systemctl is-system-running 2>/dev/null)"
FALLIDAS=$(systemctl list-units --state=failed --no-legend 2>/dev/null)
if [ -z "$FALLIDAS" ]; then ok "ninguna unidad fallida"; else fallo "hay unidades fallidas" "$FALLIDAS"; fi
igual "graphical.target" "active"   "$(systemctl is-active graphical.target 2>/dev/null)"
# CONTROL: si 'is-active' dijera 'active' a todo, lo de arriba no valdria
igual "control: rescue.target" "inactive" "$(systemctl is-active rescue.target 2>/dev/null)"
# el saludador de GDM, demostrado por loginctl y no por una foto
SES=$(loginctl list-sessions --no-legend 2>/dev/null | awk '{print $1}')
GREETER=no
for s in $SES; do
    if loginctl show-session "$s" -p Class 2>/dev/null | grep -q '^Class=greeter$'; then
        GREETER=si
        echo "           $(loginctl show-session "$s" -p Name -p Type -p Class -p State -p Seat | tr '\n' ' ')"
    fi
done
igual "hay un saludador grafico vivo" "si" "$GREETER"

titulo "Resumen"
echo "  [OK] $N_OK   [FALLO] $N_MAL   [AVISO] $N_AVI   [OMIT] $N_OMI"
if [ "$N_MAL" -gt 0 ]; then
    echo "  NO marques ninguna casilla de la definicion de terminado."
    exit 1
fi
echo "  Falta la casilla [OJOS]: la firma en valide.redsara.es, que va en un"
echo "  clon efimero que se destruye (ENCINA-OS.md §9.1)."
exit 0
