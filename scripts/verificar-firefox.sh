#!/usr/bin/env bash
# verificar-firefox.sh — La prueba que separa "parece que funciona" de
# "funciona": dos apt full-upgrade seguidos.
#
# Uso:  ./scripts/verificar-firefox.sh [--sin-purga]
#
# Por qué dos y no uno: el primero puede no mover Firefox por pura casualidad
# (no había nada nuevo que traer). El segundo corre con el estado que dejó el
# primero, que es donde aparecen los cambios de origen que apt aplaza.
#
# Este es el fallo característico de este paquete y su forma es traicionera:
# todo va bien el día de la instalación, y semanas después un apt upgrade
# rutinario sustituye Firefox nativo por el Snap sin decir nada.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
# MODELO DE SALIDA: CONTAR Y SEGUIR (tarea 2, MEDICIONES.md §4.67). fallo()
# apunta, incrementa N_MAL y SIGUE midiendo; morir() aborta; quien fija el
# código de salida es resumen(). El 'set' lo pone lib.sh:5 al hacer source: se
# REAFIRMA aquí para que las opciones de shell de este guion no dependan de a
# quién llame. Reafirmarlo no cambia ni una opción — control en §4.67.
set -euo pipefail
requiere_no_root

PAQUETE="encina-firefox-native"
SALIDA_DIR="$(raiz_repo)/debian-packages"
DEB=$(ls -t "$SALIDA_DIR"/${PAQUETE}_*.deb 2>/dev/null | head -1 || true)
[[ -n "$DEB" ]] || { echo "No hay ningún .deb. Ejecuta antes ./scripts/construir-firefox.sh"; exit 1; }

EST_PKG=$(dpkg-query -W -f='${Status}' "$PAQUETE" 2>/dev/null || true)
[[ "$EST_PKG" == "install ok installed" ]] \
    || { echo "$PAQUETE no está instalado. Ejecuta antes ./scripts/instalar-firefox.sh"; exit 1; }

SIN_PURGA=0
for arg in "$@"; do
    case "$arg" in
        --sin-purga) SIN_PURGA=1 ;;
        *) echo "Opción desconocida: $arg"; exit 1 ;;
    esac
done

# Retrato del estado que importa. Se compara literalmente antes y después.
# De qué repositorio sale el candidato de firefox.
#
# NO vale hacer  apt-cache policy firefox | grep -A1 'Candidate:'  y quedarse
# con la línea siguiente: esa línea es "Version table:", no el origen. Esa
# version daba FALLO con el anclaje funcionando perfectamente, y la prueba de
# que mentía estaba en su propia salida de diagnóstico.
#
# El origen vive en la tabla de versiones: la línea de la versión lleva su
# prioridad, y la línea inmediatamente posterior lleva el repositorio.
origen_candidato() {
    local pol cand
    pol=$(LC_ALL=C apt-cache policy firefox 2>/dev/null || true)
    cand=$(awk '/Candidate:/ {print $2}' <<<"$pol")
    if [[ -z "$cand" || "$cand" == "(none)" ]]; then
        echo "(sin candidato)"
        return
    fi
    grep -A1 -F " $cand " <<<"$pol" | sed -n '2p' | sed 's/^ *//'
}

retrato_firefox() {
    echo "deb-version: $(dpkg-query -W -f='${Version}' firefox 2>/dev/null || echo '(no instalado)')"
    echo "binario:     $(readlink -f /usr/bin/firefox 2>/dev/null || echo '(ninguno)')"
    echo "candidato:   $(LC_ALL=C apt-cache policy firefox 2>/dev/null | awk '/Candidate:/ {print $2}')"
    echo "origen:      $(origen_candidato)"
    echo "snap:        $(snap list firefox 2>/dev/null | tail -n +2 | awk '{print $1, $2, $3}' || echo '(sin snap)')"
}

# ============================================================================
titulo "1. LA prueba crítica: dos apt full-upgrade seguidos"

echo "  Aviso: full-upgrade actualiza todo el sistema y puede tardar y traer"
echo "  un kernel nuevo. Es lo que pide AGENTS.md §5.5 y no se salta."
echo

ANTES=$(retrato_firefox)
echo "  Antes:"
echo "$ANTES" | sed 's/^/    /'

sudo apt-get update >/dev/null 2>&1 || true

# Informa de lo que ha movido esa vuelta y deja el número en N_MOVIDOS.
# Sin el recuento, un full-upgrade que no toca nada y uno que reordena medio
# sistema imprimen exactamente el mismo [OK].
N_MOVIDOS=0
informar_vuelta() {
    local salida="$1" recuento mencion
    recuento=$(grep -E '^[0-9]+ upgraded' <<<"$salida" | head -1 || true)
    echo "    ${recuento:-(apt no ha dado recuento)}"
    # Cualquier mención a firefox en la salida merece leerse entera.
    mencion=$(grep -iE "firefox|snapd?\b" <<<"$salida" || true)
    if [[ -n "$mencion" ]]; then
        echo "    apt ha tocado algo relacionado con Firefox o Snap:"
        echo "$mencion" | sed 's/^/      /'
    else
        echo "    (apt no ha mencionado firefox ni snap)"
    fi
    N_MOVIDOS=$(awk '{print $1+0}' <<<"${recuento:-0}")
}

MOVIDOS=0
for vuelta in 1 2; do
    paso "sudo apt full-upgrade  (vuelta $vuelta de 2)"
    if SAL=$(LC_ALL=C sudo -E apt-get full-upgrade -y 2>&1); then
        ok "full-upgrade $vuelta/2 termina sin error"
    else
        fallo "full-upgrade $vuelta/2 ha fallado" "$(echo "$SAL" | tail -25)"
    fi
    informar_vuelta "$SAL"
    MOVIDOS=$(( MOVIDOS + N_MOVIDOS ))
done

# Si las dos vueltas no han movido nada, la prueba no ha probado nada: en un
# sistema recién actualizado apt no tiene ninguna decisión que tomar y el [OK]
# sale exactamente igual que si el anclaje funcionara. Ubuntu retiene por
# defecto las actualizaciones por fases (phased updates), que es justo lo que
# suele dejar el sistema en ese estado, así que se fuerza una vuelta más que sí
# las incluya. Una prueba vacía que imprime [OK] es peor que no tenerla.
if (( MOVIDOS == 0 )); then
    aviso "Las dos vueltas no han movido ningún paquete: no habia nada que actualizar"
    echo "         Ubuntu retiene las actualizaciones por fases. Se fuerza una"
    echo "         vuelta mas incluyendolas, para que apt tenga algo que decidir."
    paso "sudo apt full-upgrade  (vuelta extra, con actualizaciones por fases)"
    if SAL=$(LC_ALL=C sudo -E apt-get full-upgrade -y \
             -o APT::Get::Always-Include-Phased-Updates=true 2>&1); then
        ok "full-upgrade con fases termina sin error"
    else
        fallo "El full-upgrade con fases ha fallado" "$(echo "$SAL" | tail -25)"
    fi
    informar_vuelta "$SAL"
    MOVIDOS=$(( MOVIDOS + N_MOVIDOS ))
    if (( MOVIDOS > 0 )); then
        ok "La prueba no queda vacía: apt ha movido $MOVIDOS paquete(s) y aun así no ha tocado Firefox"
    else
        aviso "Ni forzando las fases hay nada que actualizar: la prueba del anclaje se apoya solo en el A/B de la purga"
    fi
else
    ok "Las dos vueltas han movido $MOVIDOS paquete(s): la prueba no está vacía"
fi

DESPUES=$(retrato_firefox)
echo
echo "  Después:"
echo "$DESPUES" | sed 's/^/    /'

# --- ¿sigue siendo el de Mozilla? ------------------------------------------
FF_VER=$(dpkg-query -W -f='${Version}' firefox 2>/dev/null || echo "")
if [[ -z "$FF_VER" ]]; then
    fallo "Tras los dos full-upgrade, firefox ya no está instalado como deb" \
"$(dpkg -l firefox 2>&1 | tail -3)
apt lo ha desinstalado. El anclaje no ha aguantado."
elif [[ "$FF_VER" == 1:* ]]; then
    fallo "Firefox ha sido degradado al deb de transición de Ubuntu" \
"versión ahora: $FF_VER
Ese paquete existe solo para instalar el Snap. ESTE es el fallo que la
prueba busca: la instalación parecía correcta y la primera actualización
la ha deshecho."
else
    ok "Firefox sigue siendo el paquete nativo de Mozilla ($FF_VER)"
fi

DESTINO_FF=$(readlink -f /usr/bin/firefox 2>/dev/null || true)
if [[ "$DESTINO_FF" == /snap/* ]]; then
    fallo "/usr/bin/firefox apunta ahora al Snap" "$DESTINO_FF"
else
    ok "/usr/bin/firefox sigue sin apuntar al Snap"
fi

ORIGEN_AHORA=$(origen_candidato)
if grep -q "packages.mozilla.org" <<<"$ORIGEN_AHORA"; then
    ok "El candidato de firefox sigue saliendo de packages.mozilla.org"
else
    fallo "El candidato de firefox ya no sale de Mozilla" \
"$(LC_ALL=C apt-cache policy firefox)"
fi

# --- ¿ha aparecido un Snap que no estaba? ----------------------------------
SNAP_ANTES=$(echo "$ANTES"   | grep '^snap:' | sed 's/^snap: *//')
SNAP_AHORA=$(echo "$DESPUES" | grep '^snap:' | sed 's/^snap: *//')
if [[ "$SNAP_ANTES" == "$SNAP_AHORA" ]]; then
    if [[ "$SNAP_AHORA" == "(sin snap)" || -z "$SNAP_AHORA" ]]; then
        ok "No ha aparecido ningún Snap de Firefox"
    else
        ok "El Snap preexistente sigue igual, ni reinstalado ni actualizado por apt"
        echo "         $SNAP_AHORA"
        echo "         (sigue ahí a propósito: eliminarlo es cosa de la receta de imagen, R4)"
    fi
else
    fallo "El Snap de Firefox ha cambiado durante los full-upgrade" \
"antes:   $SNAP_ANTES
después: $SNAP_AHORA
Es exactamente lo que el anclaje debe impedir."
fi

# ============================================================================
titulo "2. Idempotencia: cinco instalaciones seguidas (R9)"

instantanea() {
    md5sum /etc/apt/sources.list.d/mozilla.sources \
           /etc/apt/preferences.d/encina-mozilla \
           /usr/share/keyrings/packages.mozilla.org.asc \
           /usr/share/applications/firefox_firefox.desktop \
           /usr/share/glib-2.0/schemas/99-encina-firefox-native.gschema.override 2>&1
    dpkg -l "$PAQUETE" 2>/dev/null | tail -1
    ls -1 /etc/apt/sources.list.d/ /etc/apt/preferences.d/ 2>&1
    XDG_CURRENT_DESKTOP=ubuntu:GNOME gsettings get org.gnome.shell favorite-apps 2>/dev/null || true
}

IDEM_ANTES=$(instantanea)
CICLOS_OK=1
for i in 1 2 3 4 5; do
    if salida=$(sudo apt-get install -y --reinstall "$DEB" 2>&1); then
        printf "  ciclo %d/5 ok\n" "$i"
    else
        fallo "La reinstalación número $i ha fallado" "$(echo "$salida" | tail -20)"
        CICLOS_OK=0
        break
    fi
done
(( CICLOS_OK )) && ok "Cinco reinstalaciones sin error"

IDEM_DESPUES=$(instantanea)
if [[ "$IDEM_ANTES" == "$IDEM_DESPUES" ]]; then
    ok "La configuración de repositorios es idéntica antes y después"
else
    fallo "El estado ha cambiado tras cinco reinstalaciones" \
"$(diff <(echo "$IDEM_ANTES") <(echo "$IDEM_DESPUES") || true)"
fi

# Ni ficheros duplicados ni sobrantes: es la forma que tendría aquí el fallo
# de idempotencia clásico.
mapfile -t FUENTES_MOZ < <(find /etc/apt/sources.list.d/ -maxdepth 1 -name '*mozilla*' -printf '%f\n' 2>/dev/null)
N_FUENTES=${#FUENTES_MOZ[@]}
if [[ "$N_FUENTES" == "1" ]]; then
    ok "Hay exactamente un fichero de fuentes de Mozilla"
else
    fallo "Hay $N_FUENTES ficheros de fuentes de Mozilla" "$(ls -1 /etc/apt/sources.list.d/)"
fi

comprobar "Integridad de los ficheros instalados (dpkg -V)" sudo dpkg -V "$PAQUETE"

# ============================================================================
if (( SIN_PURGA )); then
    titulo "3. Purga — OMITIDA por --sin-purga"
    omitido "apt purge devuelve la configuración de repositorios original"
else
titulo "3. Purga: el sistema vuelve a su configuración de repositorios original"

paso "sudo apt purge $PAQUETE"
if salida=$(sudo apt-get purge -y "$PAQUETE" 2>&1); then
    ok "Purga ejecutada sin error"
else
    fallo "La purga ha fallado" "$(echo "$salida" | tail -20)"
fi

for f in /etc/apt/sources.list.d/mozilla.sources \
         /etc/apt/preferences.d/encina-mozilla \
         /usr/share/keyrings/packages.mozilla.org.asc \
         /usr/share/applications/firefox_firefox.desktop \
         /usr/share/glib-2.0/schemas/99-encina-firefox-native.gschema.override; do
    if [[ -e "$f" ]]; then
        fallo "Tras purgar sigue existiendo $f" "$(ls -l "$f")"
    else
        ok "Eliminado: $f"
    fi
done

# El Snap tiene que RECUPERAR su lanzador. Es lo que sostiene que ocultarlo no
# sea eliminarlo: si tras purgar el identificador vuelve a resolver al Snap,
# nunca se destruyó nada, solo se tapó mientras el paquete estaba puesto.
if [[ -f /var/lib/snapd/desktop/applications/firefox_firefox.desktop ]]; then
    # resolver_desktop usa el XDG_DATA_DIRS de la sesión gráfica. Sin eso, esta
    # comprobación daba «?» y acusaba al paquete de no ser reversible: una
    # sesión ssh no tiene esa variable, y el valor por defecto de la
    # especificación ni siquiera incluye /var/lib/snapd/desktop, de modo que el
    # fichero del Snap no estaba en el camino.
    VUELVE=$(resolver_desktop firefox_firefox.desktop)
    if [[ "$VUELVE" == *snap* ]]; then
        ok "Tras purgar, el lanzador del Snap vuelve a resolver a: $VUELVE"
        echo "         Es la prueba de que ocultarlo no era eliminarlo (R4): nada se"
        echo "         destruyó, solo quedó tapado mientras el paquete estaba puesto."
    else
        fallo "Tras purgar, el lanzador del Snap no ha vuelto" \
"resuelve a: $VUELVE
Debería volver a apuntar al Snap. Si no vuelve, la operación no era
reversible y el argumento de que no viola R4 se cae."
    fi
    # Y el Snap en sí, que nunca se tocó.
    if snap list firefox >/dev/null 2>&1; then
        ok "El Snap sigue instalado tras toda la prueba (nunca se tocó)"
    else
        fallo "El Snap ya no está instalado" "$(snap list 2>&1 | grep -i firefox || echo 'no aparece')"
    fi
else
    omitido "No hay Snap de Firefox en esta máquina: no se puede probar la reversibilidad"
fi

sudo apt-get update >/dev/null 2>&1 || true
POL_PURGA=$(LC_ALL=C apt-cache policy firefox 2>&1)
if grep -q "packages.mozilla.org" <<<"$POL_PURGA"; then
    fallo "Tras purgar, apt sigue ofreciendo el repositorio de Mozilla" "$POL_PURGA"
else
    ok "apt ya no ofrece nada de packages.mozilla.org"
fi

# Esta es la prueba A/B del anclaje, y es la mas concluyente de todo el script.
# Con el paquete puesto, el candidato de firefox es el de Mozilla. Sin el, apt
# vuelve solo al deb de transicion de Ubuntu, que es el que instala el Snap.
# La diferencia entre las dos situaciones es exactamente este paquete, asi que
# demuestra que el anclaje esta haciendo el trabajo, y no que haya coincidido.
CAND_PURGA=$(awk '/Candidate:/ {print $2}' <<<"$POL_PURGA")
if [[ "$CAND_PURGA" == 1:* ]]; then
    ok "Sin el paquete, el candidato vuelve a ser el deb de transición de Ubuntu ($CAND_PURGA)"
    echo "         Es la prueba A/B: la única diferencia entre las dos situaciones"
    echo "         es este paquete, así que el anclaje es lo que sostiene Firefox nativo."
else
    aviso "Tras purgar, el candidato es $CAND_PURGA y no el deb de transición de Ubuntu; revisa por qué"
fi
echo "$POL_PURGA" | sed 's/^/    /'
echo "    (firefox sigue instalado: purgar la configuración del repositorio no"
echo "     desinstala lo que ya se instaló desde él, y así debe ser)"

paso "Reinstalando para dejar el sistema como estaba"
if sudo apt-get install -y "$DEB" >/dev/null 2>&1 && sudo apt-get update >/dev/null 2>&1; then
    ok "Paquete reinstalado y apt update rehecho"
else
    fallo "No se ha podido reinstalar tras la purga" ""
fi
fi

# ============================================================================
resumen
RES=$?

echo
titulo "Pendiente de tus ojos (no lo doy por bueno yo)"
pendiente_visual "Haz clic en el icono de Firefox del dock, como un usuario cualquiera"
pendiente_visual "En about:support, confirma DOS filas antes de mirar el idioma:"
echo "            · 'Binario de la aplicación' -> /usr/lib/firefox/firefox-bin"
echo "              (si pone /snap/firefox/... es el Snap: no vale)"
echo "            · 'ID de distribución' -> mozilla-deb, nunca canonical-*"
pendiente_visual "Y entonces sí, que la interfaz esté EN ESPAÑOL"
echo "            En ese orden: el Snap también está en español, así que ver"
echo "            español antes de confirmar el binario no demuestra nada."
echo
VER_ACTUAL=$(dpkg-query -W -f='${Version}' "$PAQUETE" 2>/dev/null || echo "?")
echo "Cuando eso pase:"
echo "    ./scripts/diario.sh \"A2 verificado: $PAQUETE $VER_ACTUAL\""
exit $RES
