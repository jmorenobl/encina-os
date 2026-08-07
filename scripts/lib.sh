#!/usr/bin/env bash
# lib.sh — utilidades comunes de los scripts de Encina OS.
# No se ejecuta directamente; se carga con:  source "$(dirname "$0")/lib.sh"

set -euo pipefail

# ---------------------------------------------------------------- colores ---
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1 && [[ $(tput colors 2>/dev/null || echo 0) -ge 8 ]]; then
    C_OK=$(tput setaf 2);  C_MAL=$(tput setaf 1); C_AVI=$(tput setaf 3)
    C_TIT=$(tput bold);    C_TEN=$(tput setaf 8); C_FIN=$(tput sgr0)
else
    C_OK=""; C_MAL=""; C_AVI=""; C_TIT=""; C_TEN=""; C_FIN=""
fi

# ------------------------------------------------------------- contadores ---
N_OK=0; N_MAL=0; N_AVI=0; N_OMI=0
FALLOS_DETALLE=()

titulo() {
    echo
    echo "${C_TIT}=== $* ===${C_FIN}"
}

paso() { echo "${C_TEN}--- $* ${C_FIN}"; }

ok()      { N_OK=$((N_OK+1));   echo "  ${C_OK}[OK]${C_FIN}    $*"; }
aviso()   { N_AVI=$((N_AVI+1)); echo "  ${C_AVI}[AVISO]${C_FIN} $*"; }
omitido() { N_OMI=$((N_OMI+1)); echo "  ${C_TEN}[OMIT]${C_FIN}  $*"; }

# fallo "descripción" "salida literal del comando"
fallo() {
    N_MAL=$((N_MAL+1))
    echo "  ${C_MAL}[FALLO]${C_FIN} $1"
    if [[ -n "${2:-}" ]]; then
        echo "${2}" | sed 's/^/          | /'
    fi
    FALLOS_DETALLE+=("$1")
}

# comprobar "descripción" comando args...
# Ejecuta el comando; OK si sale 0, FALLO con la salida literal si no.
comprobar() {
    local desc="$1"; shift
    local salida
    if salida=$("$@" 2>&1); then
        ok "$desc"
        return 0
    else
        fallo "$desc" "$salida"
        return 1
    fi
}

# comprobar_salida "descripción" "patrón egrep" comando args...
# OK solo si el comando sale 0 Y su salida casa con el patrón.
comprobar_salida() {
    local desc="$1" patron="$2"; shift 2
    local salida
    if ! salida=$("$@" 2>&1); then
        fallo "$desc" "$salida"
        return 1
    fi
    if echo "$salida" | grep -Eq "$patron"; then
        ok "$desc"
        return 0
    else
        fallo "$desc (no aparece el patrón: $patron)" "$salida"
        return 1
    fi
}

# comprobar_fichero "descripción" ruta
comprobar_fichero() {
    if [[ -f "$2" ]]; then
        ok "$1"
    else
        fallo "$1" "no existe: $2"
    fi
}

# Marca algo que solo puede verificar un humano con los ojos.
pendiente_visual() {
    echo "  ${C_AVI}[OJOS]${C_FIN}  $*"
}

# --------------------------------------------------------------- resumen ----
resumen() {
    echo
    echo "${C_TIT}=== RESUMEN ===${C_FIN}"
    echo "  correctas: $N_OK   fallos: $N_MAL   avisos: $N_AVI   omitidas: $N_OMI"
    if (( N_MAL > 0 )); then
        echo
        echo "${C_MAL}NO TERMINADO.${C_FIN} Han fallado:"
        for f in "${FALLOS_DETALLE[@]}"; do echo "  - $f"; done
        echo
        echo "No marques nada como hecho en ENCINA-OS.md. Anota el fallo tal cual"
        echo "en el diario y déjalo para mañana:"
        echo "    ./scripts/diario.sh \"falló: ${FALLOS_DETALLE[0]}\""
        return 1
    fi
    echo
    echo "${C_OK}Todas las comprobaciones automáticas pasan.${C_FIN}"
    return 0
}

# ------------------------------------------------------------- auxiliares ---
requiere_cmd() {
    local falta=()
    for c in "$@"; do command -v "$c" >/dev/null 2>&1 || falta+=("$c"); done
    if (( ${#falta[@]} > 0 )); then
        echo "${C_MAL}Faltan herramientas:${C_FIN} ${falta[*]}"
        echo "Ejecuta primero:  ./scripts/00-entorno.sh"
        exit 1
    fi
}

requiere_no_root() {
    if [[ $EUID -eq 0 ]]; then
        echo "${C_MAL}No ejecutes este script con sudo.${C_FIN}"
        echo "Pide sudo por dentro cuando lo necesita. Si lo lanzas como root,"
        echo "los ficheros del repositorio acaban siendo propiedad de root."
        exit 1
    fi
}

# Raíz del repositorio, se calcule desde donde se calcule.
raiz_repo() {
    local d="${ENCINA_REPO:-$HOME/encina}"
    echo "$d"
}

# XDG_DATA_DIRS tal como lo ve la sesión gráfica.
#
# Hace falta para resolver identificadores .desktop, y no es un detalle: una
# sesión ssh NO tiene esa variable, y el valor por defecto de la especificación
# —/usr/local/share:/usr/share— NO incluye /var/lib/snapd/desktop. Resolver un
# identificador sin ella da un resultado que parece correcto y no demuestra
# nada, porque el fichero del Snap ni siquiera está en el camino.
#
# Se lee del proceso gnome-shell que esté corriendo. Si no hay sesión gráfica,
# se usa el orden documentado de Ubuntu 24.04 y quien llama debe decirlo.
xdg_data_dirs_sesion() {
    local pid dirs=""
    pid=$(pgrep -u "$(id -un)" -x gnome-shell 2>/dev/null | head -1 || true)
    if [[ -n "$pid" && -r "/proc/$pid/environ" ]]; then
        dirs=$(tr '\0' '\n' < "/proc/$pid/environ" \
               | grep -m1 '^XDG_DATA_DIRS=' | cut -d= -f2- || true)
    fi
    echo "${dirs:-/usr/share/ubuntu:/usr/share/gnome:/usr/local/share/:/usr/share/:/var/lib/snapd/desktop}"
}

# resolver_desktop <identificador.desktop>
# Imprime la orden Exec a la que resuelve ese identificador, o NINGUNA si no
# resuelve a nada (ocultado, o descartado por TryExec), o ? si no se ha podido
# averiguar. Se le pregunta a la misma biblioteca que usa el escritorio, en vez
# de deducirlo leyendo ficheros: la precedencia la resuelve GIO, no nosotros.
resolver_desktop() {
    XDG_DATA_DIRS="$(xdg_data_dirs_sesion)" XDG_CURRENT_DESKTOP=ubuntu:GNOME \
    python3 - "$1" <<'PY' 2>/dev/null || echo "?"
import sys, gi
gi.require_version("Gio", "2.0")
from gi.repository import Gio
a = Gio.DesktopAppInfo.new(sys.argv[1])
print(a.get_commandline() if a else "NINGUNA")
PY
}

# PKG_DIR [nombre-del-paquete]
# Sin argumento devuelve encina-branding, que es lo que esperan 03, 04 y 05:
# así el flujo de A1 sigue funcionando exactamente igual sin tocar esos tres
# scripts. Los de A2 (07, 08, 09) pasan su nombre.
PKG_DIR() { echo "$(raiz_repo)/debian-packages/${1:-encina-branding}"; }
