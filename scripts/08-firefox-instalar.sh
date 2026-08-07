#!/usr/bin/env bash
# 08-firefox-instalar.sh — Instala encina-firefox-native, instala Firefox nativo
# y comprueba todo lo verificable sin mirar la pantalla.
#
# Uso:  ./scripts/08-firefox-instalar.sh [--si-ya-cloné] [--sin-firefox]
#
#   --si-ya-cloné   sáltate la pregunta del respaldo
#   --sin-firefox   instala solo el .deb de configuración, no Firefox
#
# ANTES de ejecutarlo por primera vez: clona la VM en UTM. Este paquete toca
# la configuración de repositorios APT y pone un anclaje de prioridad 1000; si
# algo sale torcido, no se deshace con un apt purge.
#
# Toda la salida de apt se pide con LC_ALL=C: en una VM en español, "Candidate"
# se llama "Candidato" y cualquier comprobación que busque la palabra en inglés
# daría un falso negativo.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
requiere_no_root

PAQUETE="encina-firefox-native"
SALIDA_DIR="$(raiz_repo)/debian-packages"
DEB=$(ls -t "$SALIDA_DIR"/${PAQUETE}_*.deb 2>/dev/null | head -1 || true)
[[ -n "$DEB" ]] || { echo "No hay ningún .deb. Ejecuta antes ./scripts/07-firefox-construir.sh"; exit 1; }

CON_FIREFOX=1
CLONADO=0
for arg in "$@"; do
    case "$arg" in
        --si-ya-cloné|--si-ya-clone) CLONADO=1 ;;
        --sin-firefox)               CON_FIREFOX=0 ;;
        *) echo "Opción desconocida: $arg"; exit 1 ;;
    esac
done

if (( ! CLONADO )); then
    echo
    echo "${C_AVI}Antes de seguir:${C_FIN} ¿has clonado la VM en UTM?"
    echo "  El clon de A1 (encina-limpia-respaldo) es anterior a encina-branding."
    echo "  Este paquete cambia la configuración de repositorios de todo el sistema."
    echo
    read -r -p "Escribe 'si' para continuar: " resp
    [[ "$resp" == "si" ]] || { echo "Clónala y vuelve. Tarda dos minutos."; exit 1; }
fi

# ============================================================================
titulo "0. Estado de partida (para poder comparar después)"
SNAP_ANTES=$(snap list firefox 2>/dev/null | tail -n +2 || echo "(sin snap de firefox)")
echo "  Snap de Firefox:  $SNAP_ANTES"
FF_DEB_ANTES=$(dpkg-query -W -f='${Version}' firefox 2>/dev/null || echo "(no instalado)")
echo "  Paquete deb firefox: $FF_DEB_ANTES"

# ============================================================================
titulo "1. Instalación del paquete de configuración"
echo "  Paquete: $(basename "$DEB")"
paso "sudo apt install (hace falta sudo)"
if sudo apt-get install -y "$DEB"; then
    ok "encina-firefox-native instalado"
else
    fallo "La instalación ha fallado" "revisa la salida de apt de arriba"
    resumen; exit 1
fi

comprobar_fichero "Definición del repositorio en su sitio" /etc/apt/sources.list.d/mozilla.sources
comprobar_fichero "Anclaje de prioridad en su sitio"       /etc/apt/preferences.d/encina-mozilla
comprobar_fichero "Clave de firma en su sitio"             /usr/share/keyrings/packages.mozilla.org.asc

# La clave la lee el usuario _apt, no root: si no es legible por todos, apt
# update falla con un error que habla de permisos y no de la clave.
MODO=$(stat -c '%a' /usr/share/keyrings/packages.mozilla.org.asc 2>/dev/null || echo "?")
if [[ "$MODO" == "644" ]]; then
    ok "La clave es legible por el usuario _apt (modo $MODO)"
else
    aviso "La clave tiene modo $MODO; apt la lee como usuario _apt y necesita poder leerla"
fi

# La huella otra vez, ahora sobre el fichero YA INSTALADO en el sistema. No es
# redundante: 07 comprueba lo que hay en el repositorio, esto comprueba lo que
# ha acabado en el disco.
HUELLA_MOZILLA="35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3"
HUELLA_INST=$(gpg --show-keys --with-colons /usr/share/keyrings/packages.mozilla.org.asc 2>/dev/null \
              | awk -F: '/^fpr:/ {print $10; exit}')
if [[ "$HUELLA_INST" == "$HUELLA_MOZILLA" ]]; then
    ok "La clave instalada tiene la huella correcta"
else
    fallo "La clave INSTALADA no tiene la huella esperada" \
"esperada: $HUELLA_MOZILLA
obtenida: ${HUELLA_INST:-<ilegible>}
DETENTE Y AVISA."
    resumen; exit 1
fi

# ============================================================================
titulo "2. apt update — el repositorio se descarga y la firma se verifica"
echo "  El paquete no puede hacer esto por sí mismo: llamar a apt desde un"
echo "  script de mantenedor provoca un interbloqueo (R3). Lo lanza quien"
echo "  instala, y por eso el README documenta el orden."
echo
paso "sudo apt update"
if UPD=$(sudo apt-get update 2>&1); then
    ok "apt update termina sin error"
else
    fallo "apt update ha fallado" "$UPD"
fi
echo "$UPD" | grep -i "mozilla" | sed 's/^/    /' || true

if grep -qiE "NO_PUBKEY|not signed|no está firmado|GPG error|firma no válida|InRelease.*no.*verif" <<<"$UPD"; then
    fallo "apt no puede verificar la firma del repositorio de Mozilla" \
"$(echo "$UPD" | grep -iE 'NO_PUBKEY|GPG|firma|signed' || true)
Signed-By apunta a la clave equivocada, o la clave no es legible."
else
    ok "Ninguna queja de firma: la clave verifica el repositorio"
fi

if grep -q "packages.mozilla.org" <<<"$UPD"; then
    ok "apt ha descargado los índices de packages.mozilla.org"
else
    aviso "apt no menciona packages.mozilla.org (puede ser que ya estuvieran al día)"
fi

# ============================================================================
titulo "3. El anclaje de prioridad"
POL_GEN=$(LC_ALL=C apt-cache policy 2>&1)
MOZ_GEN=$(grep -B1 -A1 "packages.mozilla.org" <<<"$POL_GEN" || true)
if grep -q "1000" <<<"$MOZ_GEN"; then
    ok "El origen packages.mozilla.org aparece con prioridad 1000"
else
    fallo "El origen de Mozilla no tiene prioridad 1000" \
"${MOZ_GEN:-$POL_GEN}
Sin esto apt reinstalará el Snap de Ubuntu en la primera actualización, y
no te enterarás hasta que pase."
fi
echo "$POL_GEN" | grep -B1 -A1 "mozilla" | sed 's/^/    /' || true

paso "apt policy firefox"
POL_FF=$(LC_ALL=C apt-cache policy firefox 2>&1)
echo "$POL_FF" | sed 's/^/    /'
CAND=$(echo "$POL_FF" | awk '/Candidate:/ {print $2}')
if [[ -z "$CAND" || "$CAND" == "(none)" ]]; then
    fallo "apt no encuentra ningún candidato para firefox" "$POL_FF"
else
    # En la tabla de versiones, la línea de la versión lleva su prioridad y la
    # línea siguiente el origen del que sale.
    BLOQUE=$(echo "$POL_FF" | grep -A1 -F " $CAND " | head -2)
    if grep -q "packages.mozilla.org" <<<"$BLOQUE"; then
        ok "El candidato $CAND sale de packages.mozilla.org"
    else
        fallo "El candidato de firefox NO sale de Mozilla" \
"$POL_FF
El anclaje no está haciendo efecto. Ojo: el deb de transición de Ubuntu
lleva epoch (1:...), lo que lo hace versión más alta; solo una prioridad
>= 1000 le gana."
    fi
    if grep -qE '(^|[[:space:]])1000([[:space:]]|$)' <<<"$BLOQUE"; then
        ok "El candidato tiene prioridad 1000"
    else
        fallo "El candidato de firefox no tiene prioridad 1000" "$BLOQUE"
    fi
fi

# ============================================================================
titulo "4. Nombre real del paquete de idioma (AGENTS.md §5.3)"
echo "  AGENTS.md dice que el nombre previsible es firefox-l10n-es-es y que hay"
echo "  que CONFIRMARLO, no darlo por bueno."
echo
BUSQUEDA=$(LC_ALL=C apt-cache search firefox-l10n 2>/dev/null | grep -iE 'es-es|es_ES|spanish' || true)
if [[ -n "$BUSQUEDA" ]]; then
    echo "  apt-cache search firefox-l10n | grep -i 'es-es|spanish':"
    echo "$BUSQUEDA" | sed 's/^/    /'
else
    echo "  (la búsqueda no ha devuelto nada)"
fi

# Ojo con la forma de esta comprobación. La primera versión era
#     apt-cache policy firefox-l10n-es-es | grep -qE 'Candidate: [^(]'
# y daba FALLO con el paquete delante de las narices: 'grep -q' termina en
# cuanto encuentra la coincidencia, apt-cache muere con SIGPIPE al escribir en
# una tubería cerrada, y el 'set -o pipefail' de lib.sh convierte eso en fallo
# de toda la tubería. Se captura primero y se examina después.
L10N=""
POL_L10N=$(LC_ALL=C apt-cache policy firefox-l10n-es-es 2>/dev/null || true)
CAND_L10N=$(echo "$POL_L10N" | awk '/Candidate:/ {print $2}')
if [[ -n "$CAND_L10N" && "$CAND_L10N" != "(none)" ]]; then
    L10N="firefox-l10n-es-es"
    ok "Confirmado: el paquete se llama $L10N (candidato $CAND_L10N)"
else
    ALTERNATIVAS=$(LC_ALL=C apt-cache search firefox-l10n 2>/dev/null | awk '{print $1}' | grep -iE '^firefox-l10n-es' || true)
    if [[ -n "$ALTERNATIVAS" ]]; then
        L10N=$(echo "$ALTERNATIVAS" | grep -ix 'firefox-l10n-es-es' || echo "$ALTERNATIVAS" | head -1)
        fallo "El paquete de idioma NO se llama firefox-l10n-es-es" \
"candidatos encontrados:
$ALTERNATIVAS
Usa el nombre real y anótalo en el README (AGENTS.md §5.3)."
    else
        fallo "No aparece ningún paquete de idioma español" \
"$(LC_ALL=C apt-cache search firefox-l10n 2>&1 | head -20)"
    fi
fi

# ============================================================================
if (( ! CON_FIREFOX )); then
    titulo "5. Instalación de Firefox — OMITIDA por --sin-firefox"
    omitido "apt install firefox $L10N"
    resumen; exit $?
fi

titulo "5. Instalación de Firefox nativo y del idioma"
[[ -n "$L10N" ]] || { fallo "Sin nombre de paquete de idioma no sigo" ""; resumen; exit 1; }
# --allow-downgrades no es un parche: es consecuencia directa de por qué existe
# este paquete. El deb 'firefox' de Ubuntu es un paquete de transición cuya
# única función es instalar el Snap, y lleva epoch (1:1snap1-0ubuntu5). Frente
# a él, la versión real de Mozilla (153.0.3~build1) es MENOR, así que pasar de
# uno a otro es formalmente una desactualización. El anclaje de prioridad 1000
# hace que apt lo ELIJA, pero 'apt-get -y' se niega igualmente a desactualizar
# sin este permiso explícito.
#
# Una persona ejecutando la orden documentada en el README no necesita nada de
# esto: apt le enseña el plan, le pregunta y basta con responder que sí.
# Comprobado en la VM: la desactualización se aplica y dpkg solo avisa con
# "desactualizando firefox de 1:1snap1-0ubuntu5 a 153.0.3~build1".
paso "sudo apt install firefox $L10N   (con --allow-downgrades, ver comentario)"
if INS=$(sudo apt-get install -y --allow-downgrades firefox "$L10N" 2>&1); then
    ok "firefox y $L10N instalados"
else
    fallo "La instalación de Firefox ha fallado" "$(echo "$INS" | tail -25)"
    resumen; exit 1
fi

FF_VER=$(dpkg-query -W -f='${Version}' firefox 2>/dev/null || echo "")
if [[ -n "$FF_VER" ]]; then
    ok "Firefox instalado como paquete deb, versión $FF_VER"
else
    fallo "firefox no figura como paquete deb instalado" "$(dpkg -l firefox 2>&1 || true)"
fi

# El deb de transición de Ubuntu lleva epoch y su única función es instalar el
# Snap. Si es el que ha quedado instalado, el paquete no sirve para nada.
if [[ "$FF_VER" == 1:* ]]; then
    fallo "El firefox instalado es el deb de transición de Ubuntu, no el de Mozilla" \
"versión instalada: $FF_VER
Ese paquete solo sirve para instalar el Snap. El anclaje no ha funcionado."
else
    ok "No es el deb de transición de Ubuntu (no lleva epoch)"
fi

if [[ -x /usr/bin/firefox ]]; then
    ok "Binario nativo en /usr/bin/firefox: $(readlink -f /usr/bin/firefox)"
else
    fallo "No hay binario en /usr/bin/firefox" "$(ls -l /usr/bin/firefox 2>&1 || true)"
fi
# La ruta delata el origen: el Snap deja un envoltorio en /snap/bin.
DESTINO_FF=$(readlink -f /usr/bin/firefox 2>/dev/null || true)
if [[ "$DESTINO_FF" == /snap/* ]]; then
    fallo "/usr/bin/firefox apunta al Snap" "$DESTINO_FF"
else
    ok "/usr/bin/firefox no apunta al Snap"
fi

comprobar_salida "firefox --version responde" "Firefox" firefox --version

# ============================================================================
titulo "6. El idioma"
EST_L10N=$(dpkg-query -W -f='${Status}' "$L10N" 2>/dev/null || true)
if [[ "$EST_L10N" == "install ok installed" ]]; then
    ok "$L10N está instalado"
    XPI=$(dpkg -L "$L10N" 2>/dev/null | grep -i "\.xpi$" || true)
    if [[ -n "$XPI" ]]; then
        ok "Paquete de idioma desplegado: $(echo "$XPI" | head -1)"
    else
        aviso "El paquete de idioma no instala ningún .xpi; mira dpkg -L $L10N"
    fi
else
    fallo "$L10N no está instalado" "$(dpkg -l "$L10N" 2>&1 | tail -3)"
fi

# Firefox elige el idioma a partir del locale de la sesión. Con el langpack
# puesto pero el sistema en inglés, arrancaría en inglés igualmente.
LOCALE_SIS=$(LC_ALL=C localectl status 2>/dev/null | grep -i "System Locale" || echo "LANG=${LANG:-?}")
if grep -q "es_" <<<"$LOCALE_SIS"; then
    ok "El locale del sistema es español: ${LOCALE_SIS# *}"
else
    aviso "El locale del sistema no parece español (${LOCALE_SIS# *}); Firefox arrancaría en inglés aunque el langpack esté puesto"
fi

# ============================================================================
titulo "7. Qué Firefox se abre de verdad al hacer clic"
#
# Esta sección existe por un fallo real: con TODO lo anterior en verde, el
# icono del escritorio seguía abriendo el Snap. about:support lo delataba con
#     Binario de la aplicación: /snap/firefox/8735/usr/lib/firefox/firefox
#     ID de distribución: canonical-002
# y encima en español, así que parecía correcto.
#
# El motivo es que hay DOS lanzadores llamados «Firefox» y ninguno pisa al
# otro: el del deb en /usr/share/applications/firefox.desktop, y el del Snap
# en /var/lib/snapd/desktop/applications/firefox_firefox.desktop. Instalar el
# deb no reemplaza el segundo ni cambia lo que el usuario tiene anclado.
#
# No se arregla desde este paquete: tocar los favoritos del escritorio no es
# configurar un repositorio APT, y borrar el Snap está prohibido (R4). Se
# detecta y se avisa.

DESK_DEB="/usr/share/applications/firefox.desktop"
DESK_SNAP="/var/lib/snapd/desktop/applications/firefox_firefox.desktop"

DESK_SOMBRA="/usr/share/applications/firefox_firefox.desktop"

if [[ -f "$DESK_DEB" ]]; then
    DUENO=$(dpkg -S "$DESK_DEB" 2>/dev/null | cut -d: -f1 || echo "?")
    if [[ "$DUENO" == "firefox" ]]; then
        ok "El lanzador visible $DESK_DEB lo instala el deb de Mozilla"
    else
        aviso "El lanzador $DESK_DEB pertenece a '$DUENO', no al deb de firefox"
    fi
else
    fallo "El deb no ha instalado ningún lanzador de escritorio" "falta $DESK_DEB"
fi

# --- La sombra: ¿gana de verdad, o solo sobre el papel? ---------------------
# Esto no se deduce leyendo los ficheros, se resuelve por precedencia de
# XDG_DATA_DIRS en la sesión. Se le pregunta a la biblioteca que lo resuelve.
if [[ -f "$DESK_SOMBRA" ]]; then
    ok "La sombra está instalada en $DESK_SOMBRA"
    if [[ -f "$DESK_SNAP" ]]; then
        echo "    XDG_DATA_DIRS usado: $(xdg_data_dirs_sesion)"
        GANADOR=$(resolver_desktop firefox_firefox.desktop)
        case "$GANADOR" in
            /usr/bin/firefox*)
                ok "El identificador firefox_firefox.desktop resuelve a: $GANADOR"
                echo "         La sombra gana al del Snap por precedencia de XDG_DATA_DIRS."
                ;;
            *snap*)
                fallo "El identificador del Snap sigue resolviendo al Snap" \
"resuelve a: $GANADOR
La sombra no está ganando. Comprueba el orden de XDG_DATA_DIRS de la sesión:
/usr/share/ debe ir ANTES que /var/lib/snapd/desktop."
                ;;
            NINGUNA)
                aviso "El identificador no resuelve a nada: TryExec está descartando la entrada"
                echo "         Es lo previsto si Firefox nativo todavía no está instalado."
                ;;
            *)
                omitido "No se ha podido resolver firefox_firefox.desktop (¿falta python3-gi?)"
                ;;
        esac

        # Que el icono anclado siga VIVO importa tanto como a dónde apunta.
        # Con NoDisplay=true apuntaba bien y desaparecía del dock igualmente.
        VISIBLE=$(XDG_DATA_DIRS="$(xdg_data_dirs_sesion)" XDG_CURRENT_DESKTOP=ubuntu:GNOME \
                  python3 - firefox_firefox.desktop <<'PY' 2>/dev/null || echo "?"
import sys, gi
gi.require_version("Gio", "2.0")
from gi.repository import Gio
a = Gio.DesktopAppInfo.new(sys.argv[1])
print(a.should_show() if a else "NINGUNA")
PY
)
        if [[ "$VISIBLE" == "True" ]]; then
            ok "La entrada se sigue mostrando: el icono anclado no desaparece"
        else
            fallo "La entrada no se muestra (should_show=$VISIBLE)" \
"Quien instale el paquete con la sesión abierta se queda SIN icono de Firefox
hasta que cierre sesión: GNOME Shell retira el icono al instante por inotify,
pero no relee los favoritos por defecto hasta el siguiente inicio de sesión.
Quita NoDisplay de la sombra."
        fi
    else
        ok "No hay lanzador del Snap que sombrear (sistema sin el Snap)"
    fi
else
    fallo "No se ha instalado la sombra del lanzador del Snap" "falta $DESK_SOMBRA"
fi

# Los valores por defecto del sistema.
NAV=$(xdg-settings get default-web-browser 2>/dev/null || echo "?")
if [[ "$NAV" == "firefox.desktop" ]]; then
    ok "El navegador por defecto del sistema es el nativo ($NAV)"
else
    aviso "El navegador por defecto es '$NAV'; si acaba en _firefox.desktop, es el Snap"
fi
ALT_NAV=$(update-alternatives --query x-www-browser 2>/dev/null | awk '/^Value:/ {print $2}' || true)
if [[ "$ALT_NAV" == "/usr/bin/firefox" ]]; then
    ok "La alternativa x-www-browser apunta al nativo ($ALT_NAV)"
else
    aviso "x-www-browser apunta a '${ALT_NAV:-?}'"
fi

# --- El icono anclado -------------------------------------------------------
# LA comprobación tiene que llevar XDG_CURRENT_DESKTOP. Sin ella se lee la
# sección genérica del override y no la [org.gnome.shell:ubuntu], que es la que
# aplica de verdad en la sesión. Es el fallo que costó cuatro versiones en A1,
# y aquí se leen las dos para que la diferencia quede a la vista.
FAVS_GEN=$(gsettings get org.gnome.shell favorite-apps 2>/dev/null || echo "")
FAVS=$(XDG_CURRENT_DESKTOP=ubuntu:GNOME gsettings get org.gnome.shell favorite-apps 2>/dev/null || echo "")

if [[ -z "$FAVS" ]]; then
    omitido "No se han podido leer los favoritos del escritorio"
else
    if [[ "$FAVS" != "$FAVS_GEN" ]]; then
        echo "    (las dos secciones difieren, como es de esperar en Ubuntu:)"
        echo "      sin XDG_CURRENT_DESKTOP: $FAVS_GEN"
        echo "      con XDG_CURRENT_DESKTOP: $FAVS"
    fi
    if grep -q "'firefox_firefox\.desktop'" <<<"$FAVS"; then
        fallo "El icono anclado al dock sigue siendo el del SNAP" \
"$FAVS
El gschema.override no está haciendo efecto en la sección que manda. Si sin
XDG_CURRENT_DESKTOP sí sale bien, es que falta la sección
[org.gnome.shell:ubuntu] en el override: esa gana sea cual sea el número del
fichero."
    elif grep -q "'firefox\.desktop'" <<<"$FAVS"; then
        ok "El icono anclado al dock es el del deb nativo (comprobado con XDG_CURRENT_DESKTOP)"
    else
        aviso "No hay ningún Firefox anclado al dock: $FAVS"
    fi
fi

# ============================================================================
titulo "8. El Snap (R4)"
SNAP_AHORA=$(snap list firefox 2>/dev/null | tail -n +2 || echo "")
if [[ -z "$SNAP_AHORA" ]]; then
    ok "snap list no devuelve ningún firefox"
else
    aviso "El Snap de Firefox sigue instalado, y es lo correcto:"
    echo "$SNAP_AHORA" | sed 's/^/         /'
    echo "         Este paquete NO lo elimina a propósito (R4): borrarlo se lleva"
    echo "         por delante marcadores y sesiones. Corresponde a la receta de"
    echo "         imagen, no a la paquetería."
    if [[ "$SNAP_AHORA" == "$SNAP_ANTES" ]]; then
        ok "El Snap está exactamente igual que antes de instalar (no se ha tocado)"
    else
        fallo "El Snap ha cambiado durante la instalación" \
"antes:   $SNAP_ANTES
después: $SNAP_AHORA"
    fi
fi

comprobar "Integridad de los ficheros instalados (dpkg -V)" sudo dpkg -V "$PAQUETE"

resumen
RES=$?

echo
titulo "Lo que solo pueden verificar tus ojos"
pendiente_visual "CIERRA LA SESIÓN Y VUELVE A ENTRAR antes de mirar nada"
echo "            GNOME Shell lee los favoritos al arrancar la sesión. Hasta que"
echo "            no reinicies sesión seguirás viendo el icono anterior, y no"
echo "            será un fallo del paquete sino que aún no se ha releído."
pendiente_visual "Después, haz clic en el icono de Firefox del dock, como un usuario"
echo "            Es lo que de verdad hay que probar. Si quieres comprobarlo"
echo "            sin depender del icono, ejecuta /usr/bin/firefox en una terminal."
pendiente_visual "Con él abierto, ve a  about:support  y comprueba DOS filas:"
echo "            · 'Binario de la aplicación' -> /usr/lib/firefox/firefox"
echo "              (si pone /snap/firefox/... es el Snap: no vale)"
echo "            · 'ID de distribución' -> vacío o de Mozilla, nunca canonical-*"
pendiente_visual "Y que la interfaz salga EN ESPAÑOL: menús, preferencias, inicio"
echo "            Ojo: el Snap también está en español, así que ver español no"
echo "            demuestra nada si no has confirmado antes el binario."
echo
(( RES == 0 )) && echo "Siguiente, y es la prueba que de verdad importa:  ./scripts/09-firefox-verificar.sh"
exit $RES
