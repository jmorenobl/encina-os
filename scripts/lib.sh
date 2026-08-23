#!/usr/bin/env bash
# lib.sh — utilidades comunes de los scripts de Encina OS.
# No se ejecuta directamente; se carga con:  source "$(dirname "$0")/lib.sh"

# MODELO DE SALIDA: CONTAR Y SEGUIR — es la biblioteca que lo define (tarea 2,
# MEDICIONES.md §4.67). Los 17 guiones que hacen source heredan de aquí estas
# opciones, y desde la tarea 2 TODOS las reafirman en su cabecera: se deja
# esta línea porque es la que ellos reafirman, no porque nadie dependa de ella.
set -euo pipefail

# ---------------------------------------------------------------- colores ---
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1 && [[ $(tput colors 2>/dev/null || echo 0) -ge 8 ]]; then
    C_OK=$(tput setaf 2);  C_MAL=$(tput setaf 1); C_AVI=$(tput setaf 3)
    C_TIT=$(tput bold);    C_TEN=$(tput setaf 8); C_FIN=$(tput sgr0)
else
    C_OK=""; C_MAL=""; C_AVI=""; C_TIT=""; C_TEN=""; C_FIN=""
fi

# Donde vive ESTE fichero, resuelto una sola vez al hacer source. De aqui sale la
# raiz del repositorio, y por eso no depende del directorio actual ni de $HOME.
ENCINA_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

# morir "por qué no se puede continuar"
#
# EL SEGUNDO NOMBRE, Y ES LO CONTRARIO QUE fallo() (§4.67). fallo() apunta,
# incrementa N_MAL y SIGUE midiendo: es el modelo de este fichero y de los 19
# guiones que lo usan, y quien decide el código de salida es resumen(). morir()
# NO cuenta y NO vuelve: es «no se puede continuar», y por eso escribe a stderr.
#
# El nombre no se inventó aquí: 'imagen/capa-marca.sh' ya lo había inventado por
# su cuenta, y 'scripts/contar-arranques.sh:43' ya escribía este cuerpo entero a
# mano. Se elige el que el árbol ya votó, no 'abortar()', que era la propuesta de
# la casilla: un nombre con dos usos en el árbol es un precedente, y uno sin
# ninguno es una preferencia.
morir() {
    echo "  ${C_MAL}[FALLO]${C_FIN} $*" >&2
    exit 1
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
# LA RAIZ NO SE INVENTA: O LA DICES TU, O ES EL ARBOL DONDE VIVE ESTE FICHERO.
#
# Hasta el 2026-08-23 esto era  "${ENCINA_REPO:-$HOME/encina}"  y ese
# "$HOME/encina" de reserva ha mordido DOS VECES, las dos en silencio:
#
#   - 2026-08-14: 03-construir.sh dijo [OK] sobre un .deb 0.1.7 con el changelog
#     en 0.1.9. Se invoco sin ENCINA_REPO y construyo OTRO clon, de cuatro dias
#     antes, entero y sin una queja (ver el bloque de las dos comprobaciones en
#     03-construir.sh). Se le puso un detector A ESE GUION, no se arreglo esto.
#   - 2026-08-23 (§4.67 h): al ejecutarse 01-repo.sh sin querer, FABRICO UN
#     REPOSITORIO ENTERO en ~/encina y le hizo dos commits.
#
# Un valor por defecto que apunta a un sitio PLAUSIBLE Y DISTINTO es peor que no
# tener valor por defecto: el guion no falla, acierta en otro sitio. Y el arreglo
# no es un detector mas —03-construir.sh ya escribio por que: cuando la raiz se
# desvia se lleva TODO al mismo sitio equivocado y las comprobaciones internas
# cuadran—. Lo que separa los dos casos es cual es el arbol, y eso se sabe sin
# preguntarle a nadie: ES EL ARBOL DONDE ESTA ESTE lib.sh.
#
# ENCINA_REPO sigue mandando, porque apuntar a otro arbol A PROPOSITO es legitimo
# y asi lo invocan la CI ("$PWD") y la VM constructora (/mnt/encina). Lo que ya no
# se puede es acabar en otro arbol SIN HABERLO PEDIDO.
raiz_repo() {
    if [[ -n "${ENCINA_REPO:-}" ]]; then
        echo "$ENCINA_REPO"
        return 0
    fi
    local raiz="${ENCINA_LIB_DIR%/*}"
    # El centinela tiene que viajar con el arbol: AGENTS.md entra en
    # 'git archive HEAD', asi que esta tambien en el constructor.
    [[ -f "$raiz/AGENTS.md" ]] || morir \
        "no encuentro la raiz del repositorio: '$raiz' no tiene AGENTS.md.
          Este lib.sh vive en $ENCINA_LIB_DIR. Si querias otro arbol, dilo:
              ENCINA_REPO=\"\$PWD\" $0"
    echo "$raiz"
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
# resuelve a nada (ausente, ocultado, o descartado por TryExec), o ? si no se ha
# podido averiguar. Se le pregunta a la misma biblioteca que usa el escritorio,
# en vez de deducirlo leyendo ficheros: la precedencia la resuelve GIO, no
# nosotros.
#
# El `except TypeError` no es adorno y costó una casilla (MEDICIONES.md §4.16i):
# cuando el identificador no resuelve, `g_desktop_app_info_new()` devuelve NULL,
# y PyGObject convierte eso en `TypeError: constructor returned NULL` en vez de
# en un None. Sin capturarlo, el intérprete moría, se disparaba el `|| echo "?"`
# y esta función NO PODÍA IMPRIMIR NUNCA «NINGUNA»: el caso «el lanzador del
# Snap ya no está» y el caso «no he podido averiguarlo» daban la misma respuesta,
# que es justo la casilla «Sin Snap» de AGENTS.md §6bis.3. Las tres salidas están
# medidas sobre `encina-E2-sinsnap`.
resolver_desktop() {
    XDG_DATA_DIRS="$(xdg_data_dirs_sesion)" XDG_CURRENT_DESKTOP=ubuntu:GNOME \
    python3 - "$1" <<'PY' 2>/dev/null || echo "?"
import sys, gi
gi.require_version("Gio", "2.0")
from gi.repository import Gio
try:
    a = Gio.DesktopAppInfo.new(sys.argv[1])
except TypeError:      # el constructor devolvió NULL: no resuelve a nada
    a = None
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
