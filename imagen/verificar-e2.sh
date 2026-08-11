#!/usr/bin/env bash
# Encina OS - E2. Verifica la maquina que produce imagen/autoinstall.yaml.
#
# Se ejecuta EN LA MAQUINA INSTALADA, arrancada de su disco, y COMO ROOT:
#
#     sudo ./verificar-e2.sh                # forma E2: desatendida, nadie la toca
#     sudo ./verificar-e2.sh --forma e3     # forma E3: la ISO pregunta cinco cosas
#
# EL NOMBRE ES HISTORICO y se conserva a proposito: este guion verifica LA
# MAQUINA, y las dos formas producen la misma maquina. Lo unico que cambia entre
# ellas es COMO se goberno la instalacion, que es el bloque 1.
#
# POR QUE HAY DOS FORMAS, y no es que la de E3 sea mas floja (MEDICIONES.md
# §4.22g): el bloque 1 codificaba el criterio de E2 -"esto lo goberno un seed y
# nadie toco nada"- y en E3 eso TIENE que fallar, porque el producto pregunta.
# La de E3 es de hecho MAS exigente: E2 solo podia pedir que no hubiera
# pantallas; E3 pide EXACTAMENTE cuales y falla si sobra una.
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

FORMA=e2
while [ $# -gt 0 ]; do
    case "$1" in
        --forma) FORMA="${2:-}"; shift 2 ;;
        -h|--help) sed -n '1,30p' "$0"; exit 0 ;;
        *) echo "[FALLO] argumento desconocido: $1"; exit 2 ;;
    esac
done
case "$FORMA" in
    e2|e3) ;;
    *) echo "[FALLO] --forma solo acepta e2 o e3 (recibido: '$FORMA')"; exit 2 ;;
esac

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

if [ "$FORMA" = e2 ]; then
    titulo "1. La instalacion la goberno un seed, y nadie contesto nada (forma E2)"
else
    titulo "1. El seed lo goberno todo menos las cinco pantallas de E3 (forma E3)"
fi
# E2 -- sano: dos entradas, 'loading' y 'done'. roto: aparecen identity, storage
# o confirm, que son las pantallas que contesta un humano (§4.14g).
# E3 -- sano: EXACTAMENTE las cinco de interactive-sections mas confirm, install
# y done, medidas en §4.22f. roto: falta una, sobra una, o aparecen 'locale' o
# 'source', que serian que el seed dejo de fijarlas y las pregunta.
T=/var/log/installer/telemetry
if [ -r "$T" ]; then
    ETAPAS=$(python3 -c 'import json,sys;print(",".join(sorted(json.load(open(sys.argv[1]))["Stages"].values())))' "$T" 2>/dev/null)
    if [ "$FORMA" = e2 ]; then
        igual "las etapas por las que paso el instalador" "done,loading" "$ETAPAS"
        if grep -qE '"(identity|storage|confirm|keyboard)"' "$T"; then
            fallo "hay pantallas de instalacion a mano en telemetry" "$(cat "$T")"
        else
            ok "no aparece ninguna pantalla contestada a mano"
        fi
    else
        igual "las etapas por las que paso el instalador" \
              "confirm,done,identity,install,keyboard,network,storage,timezone" "$ETAPAS"
        # LO QUE E2 NO PODIA PREGUNTAR: que las dos que fija el seed NO se hayan
        # preguntado. Si alguna aparece, el producto dejo de ser el mismo en dos
        # maquinas distintas, que es justo lo que 'source' y 'locale' evitan.
        if grep -qE '"(locale|source)"' "$T"; then
            fallo "se pregunto algo que el seed tiene que fijar" "$(cat "$T")"
        else
            ok "ni el idioma ni el tipo de instalacion se preguntaron"
        fi
        # CONTROL: que ese grep sepa encontrar una etapa que SI esta
        if grep -q '"keyboard"' "$T"; then
            ok "control: el mismo grep si encuentra 'keyboard' en telemetry"
        else
            fallo "CONTROL ROTO: no encuentra 'keyboard', que tiene que estar"
        fi
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
# LA TERCERA COSA. Esta comprobacion pedia NINGUNA hasta el 2026-08-10 y ESTABA
# MAL ESCRITA, no aflojada: se redacto con §4.16i, medido sobre una maquina SIN
# NINGUN PAQUETE DE ENCINA, donde NINGUNA era correcto porque no habia ni Snap
# ni sombra. En una maquina de Encina OS el identificador lo resuelve la sombra
# de encina-firefox-native, asi que responde /usr/bin/firefox %u.
#
# Y lo que decidio corregirla en vez de bajar el liston: NINGUNA solo se alcanza
# quitando la sombra, y quitarla, medido en encina-E1-meta el 2026-08-10 (§4.19),
# hace que en una maquina CON Snap el mismo identificador vuelva a resolver a
# /snap/bin/firefox %u. O sea que la casilla, tal como estaba, exigia un estado
# que solo se consigue REABRIENDO A2. Lo que queria preguntar de verdad es que
# no resuelva a nada bajo /snap/, y eso es lo que pregunta ahora.
R=$(resolver_desktop firefox_firefox.desktop)
case "$R" in
    \?)       fallo "no se ha podido resolver firefox_firefox.desktop" "$R" ;;
    *snap*)   fallo "firefox_firefox.desktop resuelve al Snap" "obtenido: $R" ;;
    NINGUNA)  fallo "firefox_firefox.desktop no resuelve a nada" \
"obtenido: NINGUNA
En una maquina de Encina OS ese identificador lo tiene que resolver la sombra
de encina-firefox-native. Si no resuelve, el icono anclado del dock de Ubuntu
de fabrica no abre nada (§4.19)." ;;
    *)        ok "firefox_firefox.desktop no resuelve a nada bajo /snap/ ($R)" ;;
esac
# CONTROL: el resolvedor tiene que saber resolver algo, o el NINGUNA no vale
RC_CTL=$(resolver_desktop org.gnome.Nautilus.desktop)
case "$RC_CTL" in
    NINGUNA|\?) fallo "CONTROL ROTO: el resolvedor no resuelve ni Nautilus" "$RC_CTL" ;;
    *)          ok "control: org.gnome.Nautilus.desktop -> $RC_CTL" ;;
esac
# CONTROL de que el resolvedor sabe decir NINGUNA, que es la trampa 11: sin el,
# «no resuelve» y «no lo se» se leen igual
RC_NIN=$(resolver_desktop encina-lanzador-que-no-existe.desktop)
igual "control: un identificador que no existe" "NINGUNA" "$RC_NIN"

# LA CUARTA COSA, y es nueva: CUANTOS ICONOS DE FIREFOX VE EL USUARIO.
# Ninguna casilla lo preguntaba —todas preguntaban a que resuelve el
# identificador—, y por eso el duplicado de §4.17h paso desapercibido hasta que
# se miro por casualidad. sano: 1. roto: 2, que es lo que se veia hasta la
# 0.2.1 de encina-firefox-native.
N_FF=$(XDG_DATA_DIRS=/usr/share/ubuntu:/usr/share/gnome:/usr/local/share/:/usr/share/:/var/lib/snapd/desktop \
       XDG_CURRENT_DESKTOP=ubuntu:GNOME python3 - <<'PY' 2>/dev/null || echo "?"
import gi
gi.require_version("Gio", "2.0")
from gi.repository import Gio
todas = Gio.AppInfo.get_all()
ff  = [a for a in todas if "firefox" in a.get_id().lower() and a.should_show()]
vis = [a for a in todas if a.should_show()]
# el control va en la misma linea: si el total de visibles fuera 0, un 0 de
# Firefox no significaria nada
print(f"{len(ff)} {len(vis)}")
PY
)
set -- $N_FF
igual "iconos de Firefox que ve el usuario" "1" "${1:-?}"
if [ "${2:-0}" -gt 5 ] 2>/dev/null; then
    ok "control: ${2} aplicaciones visibles en total (el inventario no esta mudo)"
else
    fallo "CONTROL ROTO: el inventario de aplicaciones visibles sale en ${2:-?}"
fi
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

titulo "6. El veredicto que dejo el seed (§4.27)"
# POR QUE ESTA CASILLA EXISTE, y es la que faltaba desde el primer dia: hasta el
# 2026-08-11 nadie preguntaba AL FINAL si la maquina habia quedado entera. Sin
# red no entra ni uno de los cuatro .deb -apt es todo o nada, y el JRE de
# autofirma, libnss3-tools y hunspell-es no viajan en el medio (§4.27c)- y la
# instalacion terminaba diciendo que fue bien. Trampa 5.
#
# sano: ENCINA_ESTADO=COMPLETO y ENCINA_FALTA vacio.
# roto: INCOMPLETO, y entonces ENCINA_FALTA nombra lo que falta.
#
# Y OJO CON LA AUSENCIA DEL FICHERO, que son dos cosas distintas y no se pueden
# leer igual: una maquina instalada por un seed anterior a §4.27 NO PUEDE
# contestar -y eso es [OMIT], no [OK]-, mientras que una instalada por el seed
# de hoy y sin el fichero es un [FALLO] de verdad. Lo que las separa es lo que
# la propia maquina dejo escrito: el testigo del seed nuevo termina en 'estado='.
E=/etc/encina-estado
T_SEED=/etc/encina-e2-testigo-seed
if esta "$E"; then
    ESTADO=$(sed -n 's/^ENCINA_ESTADO=//p' "$E")
    QUE=$(sed -n 's/^ENCINA_FALTA=//p' "$E")
    igual "el veredicto que dejo el seed" "COMPLETO" "${ESTADO:-<vacio>}"
    if [ -z "$QUE" ]; then
        ok "el seed no echo nada en falta"
    else
        fallo "el seed dice que a esta maquina le falta algo" "ENCINA_FALTA=$QUE"
    fi
    # CONTROL: que este bloque lee el fichero de verdad y no da vacio a todo
    if [ -n "$(sed -n 's/^ENCINA_FECHA=//p' "$E")" ]; then
        ok "control: se leen las claves de $E ($(sed -n 's/^ENCINA_FECHA=//p' "$E"))"
    else
        fallo "CONTROL ROTO: no se lee ninguna clave de $E"
    fi
elif grep -q 'estado=' "$T_SEED" 2>/dev/null; then
    fallo "no existe $E y esta maquina la instalo un seed que lo escribe" \
"El testigo dice: $(cat "$T_SEED")"
else
    omitido "esta maquina la instalo un seed anterior a §4.27: no sabe contestar"
fi

titulo "Resumen"
echo "  [OK] $N_OK   [FALLO] $N_MAL   [AVISO] $N_AVI   [OMIT] $N_OMI"
if [ "$N_MAL" -gt 0 ]; then
    echo "  NO marques ninguna casilla de la definicion de terminado."
    exit 1
fi
echo "  Falta la casilla [OJOS]: la firma en valide.redsara.es, que va en un"
echo "  clon efimero que se destruye (ENCINA-OS.md §9.1)."
exit 0
