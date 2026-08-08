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

# ------------------------------------------ el vigilante de AutoFirma -------
#
# 'autofirma 1.9.1+encina2' trae dos unidades de systemd DE USUARIO que meten
# la CA de su socket en el perfil de Mozilla cuando el perfil aparece. Antes de
# eso hacía falta un cuarto paso manual (MEDICIONES.md §4.12a y su enmienda).
#
# vigilante_estado imprime uno de cuatro estados, y los cuatro están MEDIDOS
# por ssh sobre encina-E1-vigilante el 2026-08-09, usuario jorge, UID 501:
#
#   estado    cuándo                                    is-active   rc
#   armado    paquete +encina2, sesión sana             active       0
#   dormido   unidad presente, pero la sesión se abrió  inactive     3
#             ANTES de instalar el paquete (encina-autofirma M15, A y B)
#   ausente   la unidad no está: autofirma es viejo     inactive     4
#   sin-bus   sin systemd de usuario alcanzable    (a stderr: "Failed
#             to connect to bus"), salida vacía                      1
#
# Decide con DOS señales independientes y NO con el código de retorno: que el
# fichero de la unidad exista —lo instala el paquete nuevo, y solo él— y que
# is-active diga literalmente 'active'. Los rc 3 y 4 se midieron y se dejan
# escritos arriba, pero no entran en la decisión: distinguir «no armada» de
# «no existe» por un número de retorno es más frágil que mirar el fichero.
#
# La ruta sale de una variable para poder sabotearla en las pruebas: apuntarla
# a algo que no existe es exactamente el caso 'ausente'.
UNIDAD_VIGILANTE=${UNIDAD_VIGILANTE:-/usr/lib/systemd/user/autofirma-ca-mozilla.path}

vigilante_estado() {
    [[ -f "$UNIDAD_VIGILANTE" ]]           || { echo ausente; return; }
    command -v systemctl >/dev/null 2>&1   || { echo sin-bus; return; }
    local salida rc=0
    salida=$(systemctl --user is-active autofirma-ca-mozilla.path 2>/dev/null) || rc=$?
    if [[ "$salida" == "active" ]]; then
        echo armado
    elif [[ -z "$salida" ]] && (( rc != 0 )); then
        echo sin-bus
    else
        echo dormido
    fi
}

# vigilante_consejo <estado>
# Escribe, indentado para ir debajo de un [OMIT] o un [AVISO], lo que hay que
# hacer en ese estado. EL CONSEJO MANUAL NO DESAPARECE: sigue habiendo máquinas
# con 'autofirma 1.9.1+encina1' o sin systemd de usuario, y en ésas la CA no
# llega sola. Decirles que basta con abrir Firefox sería mentirles.
vigilante_consejo() {
    local manual="             abre Firefox una vez, ciérralo, y ejecuta:
             ${C_AVI}sudo dpkg-reconfigure autofirma${C_FIN}"
    case "$1" in
        armado)
            echo "         Basta con abrir Firefox una vez: la CA se instala sola en cuanto"
            echo "         el navegador crea su almacén NSS (encina-autofirma, M16 y M18)."
            ;;
        dormido)
            echo "         El paquete trae el vigilante, pero NO está armado en esta sesión."
            echo "         Es lo que pasa cuando se instaló con la sesión ya abierta"
            echo "         (encina-autofirma M15, A y B). Cierra la sesión y vuelve a entrar,"
            echo "         o hazlo a mano:"
            echo
            echo "$manual"
            ;;
        ausente)
            echo "         Esta máquina NO trae el vigilante: su 'autofirma' es anterior a"
            echo "         1.9.1+encina2, y aquí la CA no se instala sola."
            echo
            echo "$manual"
            ;;
        sin-bus)
            echo "         No se ha podido preguntar a systemd de usuario, así que no se"
            echo "         sabe si el vigilante está armado. Por si acaso, a mano:"
            echo
            echo "$manual"
            ;;
    esac
}
