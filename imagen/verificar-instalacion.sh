#!/usr/bin/env bash
# Encina OS. Verifica la maquina que produce imagen/autoinstall-unattended.yaml.
#
# Se ejecuta EN LA MAQUINA INSTALADA, arrancada de su disco, y COMO ROOT:
#
#     sudo ./verificar-instalacion.sh                # forma E2: desatendida, nadie la toca
#     sudo ./verificar-instalacion.sh --forma e3     # forma E3: la ISO pregunta cinco pantallas
#     sudo ./verificar-instalacion.sh --visibles 28  # cuantas aplicaciones se ESPERAN (ver abajo)
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
# LO QUE CAMBIA EN E4, y son dos cosas (§4.31):
#
#   1. LA CASILLA "SIN SNAP" SE SUSTITUYE, NO SE AFLOJA. D16 devuelve el Snap a
#      la maquina -la tienda lo arrastra de todas formas, §4.26d- y lo que
#      importa nunca fue snapd: es que el Firefox que el usuario PUEDE ABRIR sea
#      el nativo. La casilla nueva es MAS exigente que la vieja y la cumplen las
#      maquinas con Snap y sin el:
#         a) UN SOLO icono de Firefox visible
#         b) ese icono resuelve FUERA de /snap/, y el paquete no es el de
#            transicion (sin epoch '1:')
#         c) NO EXISTE ningun perfil de Mozilla bajo ~/snap/
#      La (c) es la que separa el estado (c) -Snap instalado y NUNCA abierto- del
#      (d) -alguien lo abrio-, que es el unico que rompe: B3 sin arreglo posible
#      (§4.28) y B4 de vuelta (§4.29f).
#
#   2. EL CONTROL DE LAS APLICACIONES VISIBLES DEJA DE VALER 25. El numero
#      cambia porque cambia el producto, asi que el numero se DECLARA por
#      adelantado con --visibles y se contrasta; lo que decide la casilla NO es
#      acertarlo, es que el inventario SEPA CONTAR (§4.19c): si el total fuera 0,
#      un 1 de Firefox no significaria nada.
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
VISIBLES_ESPERADAS=28
while [ $# -gt 0 ]; do
    case "$1" in
        --forma) FORMA="${2:-}"; shift 2 ;;
        --visibles) VISIBLES_ESPERADAS="${2:-}"; shift 2 ;;
        -h|--help) sed -n '1,45p' "$0"; exit 0 ;;
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
dato()    { echo "  [DATO]   $*"; }
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
# CORREGIDO EL 2026-08-12 (§4.32): a la lista le faltaba 'loading', que TODA
# instalacion escribe -- la rama E2 de aqui al lado ya la esperaba. Este fallo
# no se vio antes porque desde que se reescribio el verificador en la vuelta de
# E4 no se habia medido ninguna maquina de forma E3. No se afloja: la lista
# sigue siendo exacta, solo gana la etapa que siempre esta.
#
# Y ESA CORRECCION ESTABA MAL, CORREGIDA A SU VEZ EL 2026-08-14 (§4.40c bis).
# «Toda instalacion la escribe» era una generalizacion sobre UNA medicion. En la
# ISO 95758c9e NO SE REGISTRA NUNCA, y eso esta medido en dos arranques
# independientes -uno instalando y otro sin instalar nada- con la palabra
# ausente del registro del cliente y el control de que el mismo grep encuentra
# 'keyboard' catorce veces. El primer volcado del telemetry, 0,742 s ANTES de
# dibujarse ninguna pantalla, ya decia {"0":"keyboard"}: no hubo ningun instante
# que colisionar.
#
# POR QUE SACARLA DE LA LISTA NO ES AFLOJARLA, y hay que leerlo antes de tocar
# esto otra vez: la casilla existe para saber UNA cosa -que una persona contesto
# lo que Ubuntu pregunta y nada mas-. Las ocho que quedan dicen exactamente eso;
# 'loading' no dice quien contesto que, dice como arranco el cliente del
# instalador. Meterla en una lista exacta no la hizo mas estricta: le metio una
# etapa que puede faltar sin que nada este mal, y una casilla que falla cuando
# todo esta bien enseña a saltarse los fallos (§4.39j). Sigue fallando si falta
# cualquiera de las OCHO, si sobra una, o si aparecen 'locale' o 'source'.
# Y no se ignora: se DICE si estaba, que es mas informativo que exigirla.
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
        # 'loading' se aparta ANTES de comparar, y se dice aparte. Los tres sed
        # cubren las tres posiciones posibles y no se pisan entre ellos.
        ETAPAS_OCHO=$(echo "$ETAPAS" | sed -e 's/,loading,/,/' -e 's/^loading,//' -e 's/,loading$//')
        igual "las etapas por las que paso el instalador (las OCHO que deciden)" \
              "confirm,done,identity,install,keyboard,network,storage,timezone" "$ETAPAS_OCHO"
        # 'loading' es DATO y no casilla, con su motivo escrito arriba
        case ",$ETAPAS," in
            *,loading,*) dato "'loading' SI aparece (no decide: mide como arranco el cliente)" ;;
            *)           dato "'loading' NO aparece, que es lo normal en esta ISO (§4.40c bis)" ;;
        esac
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

titulo "2. EL FIREFOX QUE EL USUARIO PUEDE ABRIR ES EL NATIVO (D16, sustituye a «Sin Snap»)"
# ESTA CASILLA SUSTITUYE A LA DE «Sin Snap» DE AGENTS.md §6bis.3, y es MAS
# exigente que ella: la vieja se cumplia quitando snapd, y quitar snapd nunca
# fue lo que hacia que la firma funcionara (§4.26h). Son TRES condiciones y las
# cumplen las maquinas con Snap y sin el.
#
# Lo que hay debajo, medido: dentro del Snap, Firefox no ve afirma.desktop ni
# /usr/bin/autofirma, y NO FALLA -- no hace nada (B3), y no tiene arreglo
# posible por nuestra parte (§4.28). Y quien abra ese Firefox una vez se lleva
# ademas B4 de vuelta, porque AutoFirma busca el certificado en el perfil que se
# uso el ultimo (§4.29f). Por eso «un solo icono, y abre el nativo» no es
# cosmetica: es la defensa entera.

# (a) UN SOLO ICONO, y de paso el inventario entero, que es el control
LEIDO=$(XDG_DATA_DIRS=/usr/share/ubuntu:/usr/share/gnome:/usr/local/share/:/usr/share/:/var/lib/snapd/desktop \
       XDG_CURRENT_DESKTOP=ubuntu:GNOME python3 - <<'PY' 2>/dev/null
import gi
gi.require_version("Gio", "2.0")
from gi.repository import Gio
todas = Gio.AppInfo.get_all()
vis = [a for a in todas if a.should_show()]
ff  = [a for a in vis if "firefox" in a.get_id().lower()]
print(f"{len(ff)} {len(vis)} {len(todas)}")
for a in sorted(vis, key=lambda x: x.get_name().lower()):
    print("APP\t%s\t%s" % (a.get_id(), a.get_name()))
PY
)
read -r N_FF N_VIS N_TOT <<<"$(echo "$LEIDO" | head -1)"
igual "iconos de Firefox que ve el usuario" "1" "${N_FF:-?}"
# EL CONTROL, que es lo que decide y no el numero: si el inventario saliera en 0
# el "1 de Firefox" no significaria nada (§4.19c)
if [ "${N_VIS:-0}" -gt 5 ] 2>/dev/null; then
    ok "control: ${N_VIS} aplicaciones visibles de ${N_TOT} totales (el inventario no esta mudo)"
else
    fallo "CONTROL ROTO: el inventario de aplicaciones visibles sale en ${N_VIS:-?}"
fi
# EL NUMERO DECLARADO POR ADELANTADO, que se CONTRASTA y no decide. Un numero
# distinto no es un fallo automatico: es algo que hay que saber nombrar.
if [ "${N_VIS:-0}" = "$VISIBLES_ESPERADAS" ]; then
    ok "coincide con las $VISIBLES_ESPERADAS declaradas antes de instalar"
else
    aviso "se declararon $VISIBLES_ESPERADAS visibles y hay ${N_VIS:-?}: nombra cual sobra o cual falta"
fi
echo "  --- las aplicaciones que ve el usuario, por nombre ---"
echo "$LEIDO" | sed -n 's/^APP\t/  /p' | sed 's/\t/  |  /'

# (b) EL ICONO ABRE EL NATIVO: tres formas de preguntar lo mismo
# ESTA COMPROBACION PEDIA «NINGUNA» HASTA EL 2026-08-10 Y ESTABA MAL ESCRITA, no
# aflojada (§4.19d): NINGUNA solo se alcanza quitando la sombra, y quitarla hace
# que en una maquina CON Snap el identificador vuelva a resolver a
# /snap/bin/firefox %u. La casilla exigia un estado que solo se consigue
# REABRIENDO A2. Lo que quiere preguntar es que no resuelva a nada bajo /snap/.
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

# y el paquete: version SIN epoch y destino fuera de /snap/
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

# (c) NINGUN PERFIL DE MOZILLA BAJO ~/snap/ -- la que dice si el Snap se abrio
# Es la que separa el estado (c) del (d). Se busca en TODOS los homes, no en uno
# (trampa 8: no se filtra a nadie por UID), y con los dos controles de §4.26i:
# el buscador tiene que saber encontrar algo y saber decir cero.
PERFILES_SNAP=$(find /home /root -maxdepth 8 \
    \( -path '*/snap/firefox/*/.mozilla/firefox/profiles.ini' \
    -o -path '*/snap/firefox/*/.mozilla/firefox/*/cert9.db' \
    -o -path '*/snap/*/.mozilla/firefox/profiles.ini' \) 2>/dev/null | wc -l)
igual "perfiles de Mozilla bajo ~/snap/ (0 = el Snap nunca se abrio)" "0" "$PERFILES_SNAP"
CTL_SI=$(find /home /root -maxdepth 3 -name '.bashrc' 2>/dev/null | wc -l)
if [ "$CTL_SI" -ge 1 ]; then
    ok "control: el buscador sabe encontrar algo (.bashrc -> $CTL_SI)"
else
    fallo "CONTROL ROTO: el buscador no encuentra ni un .bashrc"
fi
CTL_NO=$(find /home /root -maxdepth 3 -name 'fichero-que-no-existe-jamas' 2>/dev/null | wc -l)
igual "control: el buscador sabe decir cero" "0" "$CTL_NO"

# Y LA FOTO DEL SNAP, que es DATO y no casilla: la casilla de arriba la cumplen
# las maquinas con Snap y sin el, a proposito. Esto solo dice en cual estamos.
EST_SNAPD=$(dpkg-query -W -f='${db:Status-Abbrev}' snapd 2>/dev/null | tr -d ' ')
NSNAP=$(ls -d /snap/firefox/* 2>/dev/null | grep -cv current)
case "$EST_SNAPD:$NSNAP:$PERFILES_SNAP" in
    ii:0*:*)  dato "forma (b): snapd instalado y SIN Snap de Firefox" ;;
    ii:*:0)   dato "forma (c): snapd + Snap de Firefox instalado y NUNCA abierto  <- la de D16" ;;
    ii:*:*)   dato "forma (d): el Snap de Firefox TIENE perfil -- es la que rompe" ;;
    *)        dato "forma (a): sin snapd (estado snapd='$EST_SNAPD')" ;;
esac
dato "snapd='$EST_SNAPD'  revisiones de firefox en /snap: $NSNAP  perfiles bajo ~/snap: $PERFILES_SNAP"
# y no vale 'dpkg -l | grep -i snap': da falsa alarma con libsnapd-glib,
# gir1.2-snapd-2, xdg-desktop-portal y una extension de GNOME que ordena
# ventanas (§4.16h). Por eso se pregunta por el estado dpkg exacto.

titulo "3. Firefox esta en espanol, y el anclaje sigue mandando"
XPI=/usr/lib/firefox/distribution/extensions/langpack-es-ES@firefox.mozilla.org.xpi
if esta "$XPI"; then ok "el idioma esta puesto: $(basename "$XPI")"; else fallo "falta el paquete de idioma" "$XPI"; fi
# el anclaje, que es lo que impide que un apt upgrade futuro devuelva el Snap
POL=$(LC_ALL=C apt-cache policy firefox 2>/dev/null)
if grep -qE '^\s+1000 https://packages\.mozilla\.org' <<<"$POL"; then
    ok "el anclaje de Mozilla sigue a prioridad 1000"
else
    fallo "el anclaje de Mozilla no manda" "$POL"
fi

titulo "4. El repo local sin firmar, los cuatro paquetes y las tres aplicaciones de D17/D18"
LISTA=/etc/apt/sources.list.d/encina-local.list
if esta "$LISTA"; then ok "$LISTA: $(cat "$LISTA")"; else fallo "no esta $LISTA"; fi
for p in encina-meta encina-branding encina-firefox-native autofirma; do
    E=$(dpkg-query -W -f='${Version} ${Status}' "$p" 2>/dev/null)
    case "$E" in
        *"install ok installed") ok "$p $E" ;;
        *)                       fallo "$p no esta instalado" "${E:-<no se ha encontrado el paquete>}" ;;
    esac
done
# LA VERSION DE autofirma NO ES UN DETALLE: §4.29b encontro una maquina que el
# banco declaraba capaz de contestar una pregunta sobre un paquete que no tenia.
VA=$(dpkg-query -W -f='${Version}' autofirma 2>/dev/null)
case "$VA" in
    *+encina4) ok "autofirma es la +encina4, que es la que espera por raiz (M20)" ;;
    *)         fallo "autofirma no es la +encina4" "obtenido: ${VA:-<ninguna>}
La espera del vigilante por raiz (M20) es lo que cierra §4.29e. Con +encina2 o
+encina3, un perfil de Snap delante desactiva la espera de 90 s." ;;
esac
# LAS APLICACIONES QUE E4 ANADE (D17 y D18), y evince, que es a quien apunta el
# manejador del PDF: si faltara, el defecto del bloque 6bis apuntaria a nada
for p in simple-scan sane-airscan evince; do
    E=$(dpkg-query -W -f='${Version} ${Status}' "$p" 2>/dev/null)
    case "$E" in
        *"install ok installed") ok "$p $E" ;;
        *)                       fallo "$p no esta instalado" "${E:-<no se ha encontrado el paquete>}" ;;
    esac
done
# LA TIENDA, desde el 2026-08-12 (D18 reescrita): NO es un .deb y por eso no
# esta en el bucle de arriba. Es el snap snap-store, pre-sembrado en el medio
# (§4.16d), asi que se pregunta a snap y no a dpkg.
if snap list snap-store >/dev/null 2>&1; then
    ok "la tienda: snap-store $(snap list snap-store 2>/dev/null | awk 'NR==2{print $2" rev "$3}')"
else
    fallo "la tienda no esta" "snap list snap-store no la encuentra, y sin tienda D17 se queda sin sustento"
fi
# control: el mismo comando tiene que saber decir que NO de un snap inventado
if snap list encina-snap-que-no-existe-jamas >/dev/null 2>&1; then
    fallo "CONTROL ROTO: snap list dice tener un snap inventado" ""
else
    ok "control: un snap inventado -> snap list dice que no"
fi
# Y LA OTRA MITAD DE LA DECISION: gnome-software NO tiene que estar. Sin esto,
# la casilla no sabria distinguir «una tienda» de «dos».
E=$(dpkg-query -W -f='${Status}' gnome-software 2>/dev/null)
case "$E" in
    *"install ok installed") fallo "gnome-software SIGUE instalado" "D18 (reescrita) dice que sale: el usuario veria DOS tiendas" ;;
    *)                       ok "gnome-software fuera (${E:-<no se ha encontrado el paquete>})" ;;
esac
# CONTROL de todo el bloque: el mismo comando tiene que saber decir que no
E=$(dpkg-query -W -f='${Status}' encina-paquete-que-no-existe-jamas 2>/dev/null)
if [ -z "$E" ]; then ok "control: un paquete inventado -> no se ha encontrado"
else fallo "CONTROL ROTO: dice tener un paquete inventado" "$E"; fi
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
# el escritorio arranca, demostrado por loginctl y no por una foto.
# CORREGIDO EL 2026-08-12 (§4.32), y no es aflojarla: tal como estaba escrita
# NO PODIA dar una de sus dos respuestas en el unico sitio donde hay que usarla.
# Una maquina de forma E3 no lleva ssh (§6ter.0), asi que se mide DESDE DENTRO
# de una sesion grafica (§4.25e) -- y mientras hay alguien dentro, GDM no tiene
# saludador vivo: tiene una sesion de usuario. Preguntaba por el mecanismo
# ('hay saludador') en vez de por lo que se quiere saber ('el escritorio
# arranca'), que es la familia de las trampas 5 y 11. Ahora vale cualquiera de
# los dos y se dice CUAL se vio, que es mas informativo que el si/no de antes.
SES=$(loginctl list-sessions --no-legend 2>/dev/null | awk '{print $1}')
GREETER=no
SESION_GRAFICA=no
for s in $SES; do
    INFO=$(loginctl show-session "$s" -p Name -p Type -p Class -p State -p Seat 2>/dev/null | tr '\n' ' ')
    case "$INFO" in
        *Class=greeter*)                             GREETER=si;        echo "           $INFO" ;;
        *Type=wayland*Class=user*|*Type=x11*Class=user*) SESION_GRAFICA=si; echo "           $INFO" ;;
    esac
done
if [ "$GREETER" = si ]; then
    ok "el escritorio arranca: hay un saludador grafico vivo (GDM)"
elif [ "$SESION_GRAFICA" = si ]; then
    ok "el escritorio arranca: hay una sesion grafica de usuario abierta (por eso GDM no tiene saludador)"
else
    fallo "el escritorio arranca" "esperado: un saludador de GDM o una sesion grafica de usuario
obtenido: ninguno de los dos"
fi
# CONTROL, sin el cual un 'no hay ninguno' no significaria nada: que loginctl
# sepa listar algo. Si esta mudo, su silencio no es una respuesta.
if [ -n "$SES" ]; then
    ok "control: loginctl lista $(echo $SES | wc -w) sesion(es), o sea que no esta mudo"
else
    fallo "control: loginctl no lista ninguna sesion" "el instrumento esta mudo: lo de arriba no vale"
fi

titulo "6. El veredicto que dejo el seed (§4.27)"
# POR QUE ESTA CASILLA EXISTE, y es la que faltaba desde el primer dia: hasta el
# 2026-08-11 nadie preguntaba AL FINAL si la maquina habia quedado entera. Sin
# red no entraba ni uno de los cuatro .deb -apt es todo o nada- y la instalacion
# terminaba diciendo que fue bien. Trampa 5.
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
    # las dos mitades del manejador del PDF, tal como las vio el seed
    dato "el seed vio  application/pdf: ANTES=$(sed -n 's/^ENCINA_PDF_ANTES=//p' "$E")  DESPUES=$(sed -n 's/^ENCINA_PDF_DESPUES=//p' "$E")"
elif grep -q 'estado=' "$T_SEED" 2>/dev/null; then
    fallo "no existe $E y esta maquina la instalo un seed que lo escribe" \
"El testigo dice: $(cat "$T_SEED")"
else
    omitido "esta maquina la instalo un seed anterior a §4.27: no sabe contestar"
fi

titulo "6bis. EL MANEJADOR DEL PDF, ATADO (D17)"
# LA MEDICION TIENE DOS MITADES y la primera esta en §4.26c: sobre la maquina de
# la entrega, 'application/pdf' resolvia a firefox.desktop CON Evince instalado.
# O sea que el producto traia un visor que nunca se abria. Esta es la segunda.
#
# Y TIENE TRAMPA CONOCIDA: compiten varios ficheros y no gana el que uno cree.
# Por eso se ENSENAN todos los que existen y quien los puso, en vez de suponer.
# Y SE PREGUNTA EN LAS DOS COLUMNAS, con y sin XDG_CURRENT_DESKTOP. §4.26c se
# midio por ssh, o sea SIN escritorio, y eso cambia la respuesta: los ficheros
# con nombre de escritorio delante (gnome-mimeapps.list) solo se leen si el
# escritorio se llama asi. Con una sola columna, esta casilla diria "arreglado"
# o "no hacia falta" segun como se preguntara.
PDF_CON=$(XDG_CURRENT_DESKTOP=ubuntu:GNOME xdg-mime query default application/pdf 2>/dev/null)
PDF_SIN=$(env -u XDG_CURRENT_DESKTOP xdg-mime query default application/pdf 2>/dev/null)
for par in "con ubuntu:GNOME|$PDF_CON" "SIN escritorio|$PDF_SIN"; do
    COMO="${par%%|*}"; QUE="${par#*|}"
    case "$QUE" in
        "")        fallo "application/pdf ($COMO) no resuelve a nada" ;;
        *firefox*) fallo "application/pdf ($COMO) resuelve al navegador" "obtenido: $QUE
Es §4.26c sin atar: el producto trae un visor que no se abre nunca." ;;
        *)         ok "application/pdf ($COMO) -> $QUE" ;;
    esac
done
# CONTROL: si xdg-mime contestara vacio a todo, los [OK] de arriba no valdrian
PDF_CTL=$(XDG_CURRENT_DESKTOP=ubuntu:GNOME xdg-mime query default application/x-tipo-que-no-existe-jamas 2>/dev/null)
igual "control: un tipo inventado no resuelve a nada" "" "$PDF_CTL"
# CONTROL 2: y tiene que saber contestar de otro tipo, que ademas este fichero
# NO toca -- un mimeapps.list solo manda sobre los tipos que nombra
PDF_ZIP=$(XDG_CURRENT_DESKTOP=ubuntu:GNOME xdg-mime query default application/zip 2>/dev/null)
if [ -n "$PDF_ZIP" ]; then ok "control: application/zip -> $PDF_ZIP (xdg-mime no esta mudo, y el zip no se ha tocado)"
else fallo "CONTROL ROTO: xdg-mime no sabe contestar de application/zip"; fi
# QUIEN GANA, ensenado y no supuesto: todos los ficheros que compiten, con su dueno
echo "  --- los ficheros que compiten, de mas fuerte a mas debil ---"
for f in "$HOME/.config/ubuntu-mimeapps.list" "$HOME/.config/mimeapps.list" \
         /etc/xdg/xdg-ubuntu/ubuntu-mimeapps.list /etc/xdg/xdg-ubuntu/mimeapps.list \
         /etc/xdg/ubuntu-mimeapps.list /etc/xdg/gnome-mimeapps.list /etc/xdg/mimeapps.list \
         /usr/share/applications/ubuntu-mimeapps.list \
         /usr/share/applications/gnome-mimeapps.list /usr/share/applications/mimeapps.list; do
    if esta "$f"; then
        D=$(dpkg -S "$f" 2>/dev/null | cut -d: -f1); [ -n "$D" ] || D="sin dueno"
        echo "    $f  [$D]  pdf=$(sed -n 's/^application\/pdf=//p' "$f" | head -1)"
    fi
done
# Y QUE EL QUE MANDA SEA NUESTRO: R5 prohibe sobrescribir el conffile de otro
MIO=/etc/xdg/mimeapps.list
if esta "$MIO"; then
    DUENO=$(dpkg -S "$MIO" 2>/dev/null | cut -d: -f1)
    igual "el fichero que ata el PDF es NUESTRO (R5)" "encina-branding" "${DUENO:-<sin dueno>}"
else
    fallo "no esta $MIO: el manejador del PDF no lo pone ningun paquete de Encina"
fi
# CONTROL de ese dpkg -S: tiene que saber decir de quien es un fichero ajeno
DA=$(dpkg -S /usr/share/applications/gnome-mimeapps.list 2>/dev/null | cut -d: -f1)
if [ -n "$DA" ]; then ok "control: gnome-mimeapps.list es de '$DA' (dpkg -S no esta mudo)"
else fallo "CONTROL ROTO: dpkg -S no sabe de quien es gnome-mimeapps.list"; fi

# ============================================================================
titulo "8. EL ICONO DE LA REJILLA (bloque 1, la mitad del sistema instalado)"
#
# QUE SE MIDE Y POR QUE ASI. La casilla es «el boton de aplicaciones lleva la
# encina, y el resto del escritorio no ha cambiado». Lo que decide no es que
# el fichero exista: es A QUE FICHERO RESUELVE EL NOMBRE que pide el dock.
#
# Y EL NOMBRE NO ES EL QUE PARECE. ubuntu-dock pide (appIcons.js:1371)
#     view-app-grid-${Main.sessionMode.currentMode}-symbolic
# y el modo de la sesion de escritorio es 'ubuntu'. Un paquete que enviara
# solo 'view-app-grid-symbolic' se instalaria sin un solo error y no cambiaria
# nada, asi que aqui se pregunta POR EL NOMBRE DE VERDAD.
#
# EL CONTROL QUE ESTA COMPROBACION NECESITA, y es el que la hace valer: el
# mismo comparador, preguntado con tema='Yaru', TIENE QUE CONTESTAR QUE EL
# FICHERO ES EL DE YARU. Si dijera «Encina» en los dos casos -o «Yaru» en los
# dos- no estaria distinguiendo nada, solo diciendo que hay un icono.
#
# SANO:  tema efectivo 'Encina'; el nombre resuelve a /usr/share/icons/Encina;
#        con tema='Yaru' el mismo nombre resuelve a /usr/share/icons/Yaru;
#        y los iconos ajenos siguen saliendo de Yaru y de hicolor.
# ROTO:  resuelve a Yaru con el tema puesto (el tema propio no gana), o los
#        ajenos dejan de resolver (la herencia esta rota y el escritorio se
#        queda sin iconos).

# 8.1 el tema esta, y es NUESTRO -- no encima del de nadie (R5)
TEMA_ENC=/usr/share/icons/Encina/index.theme
if esta "$TEMA_ENC"; then
    DUENO_T=$(dpkg -S "$TEMA_ENC" 2>/dev/null | cut -d: -f1)
    igual "el tema de iconos es NUESTRO (R5)" "encina-branding" "${DUENO_T:-<sin dueno>}"
else
    fallo "no esta $TEMA_ENC: el tema de iconos de Encina no lo instala nadie"
fi
# 8.2 y el de Yaru NO SE HA PISADO: se ha DESVIADO, que es el mecanismo que
#     R5 prescribe (0.1.17, MEDICIONES.md 4.76; el porque entero, en el
#     preinst de encina-branding). Hasta 0.1.16 esta comprobacion exigia que
#     la ruta siguiera siendo de yaru-theme-icon, y con 0.1.17 eso dio el
#     [FALLO] esperable en el primer Acer instalado del medio nuevo (4.78):
#     el panel de Apariencia escribe icon-theme='Yaru-<acento>' al tocar el
#     modo oscuro y un valor de usuario gana al override, asi que la bellota
#     no puede depender de icon-theme. Lo que R5 protege sigue protegido: el
#     fichero de yaru-theme-icon no se destruye ni se pisa, espera INTACTO
#     en .distrib y la purga lo devuelve.
Y_GRID=/usr/share/icons/Yaru/scalable/actions/view-app-grid-ubuntu-symbolic.svg
DIV_Y=$(dpkg-divert --listpackage "$Y_GRID" 2>/dev/null)
igual "el icono de Yaru esta DESVIADO por nosotros (R5 via dpkg-divert, 0.1.17)" \
      "encina-branding" "${DIV_Y:-<sin desvio>}"
H_YG=$(md5sum "$Y_GRID" 2>/dev/null | cut -d" " -f1)
H_EG=$(md5sum /usr/share/icons/Encina/scalable/actions/view-app-grid-ubuntu-symbolic.svg 2>/dev/null | cut -d" " -f1)
if [ -n "$H_YG" ] && [ "$H_YG" = "$H_EG" ]; then
    ok "el fichero servido en la ruta de Yaru es el nuestro (md5 $H_YG)"
else
    fallo "el fichero en la ruta de Yaru NO es el nuestro" \
"Yaru:   ${H_YG:-<no legible>}
Encina: ${H_EG:-<no legible>}"
fi
DESTINO_D=$(readlink "$Y_GRID.distrib" 2>/dev/null)
case "$DESTINO_D" in
    *start-here-symbolic.svg)
        ok "el original de Yaru sigue entero en .distrib -> $DESTINO_D" ;;
    *)
        fallo "el original de Yaru no espera en .distrib como enlace a start-here" \
"$(ls -l "$Y_GRID.distrib" 2>&1)" ;;
esac

# 8.3 el valor por defecto del sistema, que es lo que heredaria un usuario
#     nuevo. Se pregunta CON XDG_CURRENT_DESKTOP puesto porque Ubuntu fija
#     icon-theme SOLO en la seccion ':ubuntu' y sin la variable se lee otra
#     cosa -- es la trampa de 0.1.2, y aqui se cae por el mismo sitio.
ICO_T=$(XDG_CURRENT_DESKTOP=ubuntu:GNOME gsettings get org.gnome.desktop.interface icon-theme 2>/dev/null | tr -d "'")
igual "el tema de iconos por defecto del sistema" "Encina" "${ICO_T:-<vacio>}"
# CONTROL: el mismo gsettings tiene que saber contestar otra cosa distinta
GTK_T=$(XDG_CURRENT_DESKTOP=ubuntu:GNOME gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null | tr -d "'")
if [ -n "$GTK_T" ] && [ "$GTK_T" != "Encina" ]; then
    ok "control: gtk-theme sigue siendo '$GTK_T' (gsettings no contesta 'Encina' a todo)"
else
    fallo "CONTROL ROTO: gtk-theme contesta '$GTK_T'" \
"Si gsettings devolviera lo mismo para todo, la comprobacion de arriba no
diria nada."
fi

# 8.4 LA QUE DECIDE: a que fichero resuelve el nombre, con su control por tema
RESOLVEDOR=$(cat <<'PY'
import sys
NOMBRES = ["view-app-grid-ubuntu-symbolic", "view-app-grid-symbolic",
           "folder", "system-run-symbolic", "icono-que-no-existe-jamas"]
RUTAS = ["/usr/local/share/icons", "/usr/share/icons", "/usr/share/pixmaps"]
import gi
gi.require_version("Gtk", "4.0")
from gi.repository import Gtk
for tema in ["Encina", "Yaru"]:
    t = Gtk.IconTheme.new()
    t.set_search_path(RUTAS)
    t.set_theme_name(tema)
    for n in NOMBRES:
        p = t.lookup_icon(n, None, 16, 1, Gtk.TextDirection.NONE, 0)
        # OJO: en GTK 4 'lookup_icon' NUNCA falla. Ante un nombre que no
        # existe devuelve el icono de reserva, cuyo GFile NO TIENE RUTA, asi
        # que get_path() vale None. La primera version de esto solo miraba si
        # el lookup era nulo y comparaba contra la cadena "NO-RESUELVE": el
        # control salio [FALLO] con «obtenido: None» sobre un sistema sano.
        # Era mi guion preguntando mal, no el producto (§4.42f otra vez).
        f = p.get_file() if p else None
        ruta = f.get_path() if f else None
        print("%s\t%s\t%s" % (tema, n, ruta if ruta else "NO-RESUELVE"))
PY
)
if RES=$(python3 -c "$RESOLVEDOR" 2>/dev/null) && [ -n "$RES" ]; then
    lee() { echo "$RES" | awk -F'\t' -v t="$1" -v n="$2" '$1==t && $2==n {print $3}'; }
    for n in view-app-grid-ubuntu-symbolic view-app-grid-symbolic; do
        CON=$(lee Encina "$n")
        case "$CON" in
            /usr/share/icons/Encina/*) ok "'$n' resuelve a Encina ($CON)" ;;
            *) fallo "'$n' NO resuelve al icono de Encina" \
"obtenido: ${CON:-<nada>}
El tema propio no esta ganando. NO lo arregles pisando el de Yaru (R5)." ;;
        esac
        # EL CONTROL DE VERDAD: preguntado por Yaru tiene que decir OTRO
        SIN=$(lee Yaru "$n")
        if [ -n "$SIN" ] && [ "$SIN" != "$CON" ] && [ "${SIN#/usr/share/icons/Yaru/}" != "$SIN" ]; then
            ok "control: con tema='Yaru' el mismo nombre da OTRO fichero ($SIN)"
        else
            fallo "CONTROL ROTO: el comparador no distingue de que tema sale '$n'" \
"con Encina: ${CON:-<nada>}
con Yaru:   ${SIN:-<nada>}
Si contesta lo mismo en los dos casos, el [OK] de arriba solo dice que HAY un
icono, no que sea el nuestro."
        fi
    done
    # 8.5 la herencia no rompe el resto del escritorio
    #
    # LA FAMILIA ES 'Yaru*', NO 'Yaru' A SECAS, Y ESTO SE CORRIGIO EL 2026-08-22
    # CON LA MAQUINA DELANTE (MEDICIONES.md 4.63p). Esta linea aceptaba solo
    # /usr/share/icons/Yaru/ y /usr/share/icons/hicolor/, y dio [FALLO] con
    #     folder=/usr/share/icons/Yaru-sage/16x16/places/folder.png
    # que es EXACTAMENTE lo que pide nuestro propio paquete: el index.theme de
    # encina-branding dice 'Inherits=Yaru-sage,Yaru,hicolor', con Yaru-sage EL
    # PRIMERO, y el gtk-theme del sistema es Yaru-sage -- lo dice el control de
    # tres lineas mas arriba. La comprobacion y el Inherits se escribieron EL
    # MISMO DIA (1d24ac2 y c675c5d, 2026-08-14) y se contradecian; nadie lo vio
    # porque esta comprobacion NUNCA se habia ejecutado sobre una maquina con el
    # tema instalado. El defecto era del INSTRUMENTO, no del producto.
    familia_yaru() {   # 0 si el icono sale de la familia Yaru o de hicolor
        case "$1" in
            /usr/share/icons/Yaru/*|/usr/share/icons/Yaru-*/*|/usr/share/icons/hicolor/*) return 0 ;;
            *) return 1 ;;
        esac
    }
    ROTOS=""
    for n in folder system-run-symbolic; do
        R=$(lee Encina "$n")
        familia_yaru "$R" || ROTOS="$ROTOS $n=${R:-<nada>}"
    done
    if [ -z "$ROTOS" ]; then
        ok "con el tema puesto, los iconos ajenos siguen saliendo de la familia Yaru (Inherits funciona)"
    else
        fallo "el tema propio ha roto la herencia" "$ROTOS"
    fi
    # CONTROL DE ESE COMPARADOR, que es lo que lo convierte en comprobacion:
    # ensanchar una lista blanca es facil de ensanchar DE MAS, asi que aqui se
    # comprueba que sigue sabiendo decir que NO -- con un icono de otro tema y
    # con la respuesta vacia, que son las dos formas de romperse la herencia.
    if familia_yaru "/usr/share/icons/Adwaita/16x16/places/folder.png" \
       || familia_yaru "" || familia_yaru "/usr/share/icons/YaruSuplantado/x.png"; then
        fallo "CONTROL ROTO: el comparador de la familia Yaru dice que si a cualquier cosa"
    else
        ok "control: el comparador rechaza Adwaita, la respuesta vacia y un nombre que solo EMPIEZA por Yaru"
    fi
    # CONTROL de que el resolvedor sabe decir que NO
    igual "control: un icono inventado no resuelve" "NO-RESUELVE" "$(lee Encina icono-que-no-existe-jamas)"
else
    aviso "no hay resolvedor de iconos (python3-gi con Gtk 4.0): lo que decide
           el icono NO se ha comprobado, solo que los ficheros estan"
fi

titulo "Resumen"
echo "  [OK] $N_OK   [FALLO] $N_MAL   [AVISO] $N_AVI   [OMIT] $N_OMI"
if [ "$N_MAL" -gt 0 ]; then
    echo "  NO marques ninguna casilla de la definicion de terminado."
    exit 1
fi
echo "  Faltan las casillas [OJOS]: la firma en valide.redsara.es -que va en un"
echo "  clon efimero que se destruye (ENCINA-OS.md §9.1)- y si los nombres de las"
echo "  aplicaciones de arriba se ven en espanol en una sesion de escritorio."
exit 0
