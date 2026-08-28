#!/usr/bin/env bash
# lib/vm.sh — lo de scripts/lib.sh que SOLO sirve en la VM Ubuntu.
# No se ejecuta directamente; lo carga scripts/lib.sh, y carga antes lib/salida.sh.
#
# Es la segunda capa de la particion de la tarea 3 (tareas/refactorizacion.md):
# lib/salida.sh es el vocabulario y los contadores, portatiles; esto es el
# resto -- la raiz del repositorio, los requisitos de la VM constructora,
# resolver un .desktop preguntandole a GIO, el vigilante de AutoFirma --, que
# o no existe en macOS o no tiene sentido fuera de una maquina Ubuntu. La
# frontera no se invento: de los 17 guiones que cargaban scripts/lib.sh
# ninguno estaba en imagen/, y de los 10 de imagen/ ninguno lo cargaba
# (organizacion-comparada.md §5, tarea 3). Se parte por donde ya estaba
# partido.
#
# Todo lo que sigue es el texto de scripts/lib.sh del 2026-08-28, movido
# verbatim: los comentarios largos son el registro del porque y no se tocan.

# Donde vive ESTE fichero, resuelto una sola vez al hacer source. De aqui sale la
# raiz del repositorio, y por eso no depende del directorio actual ni de $HOME.
# Hasta la tarea 3 era scripts/, y raiz_repo() le quitaba el ultimo tramo; ahora
# es lib/ y le quita el mismo tramo: la raiz sale igual.
ENCINA_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# el vocabulario y los contadores, que son la otra capa
# shellcheck source=lib/salida.sh
. "$ENCINA_LIB_DIR/salida.sh"

# ------------------------------------------------------------- auxiliares ---
requiere_cmd() {
    local falta=()
    for c in "$@"; do command -v "$c" >/dev/null 2>&1 || falta+=("$c"); done
    if (( ${#falta[@]} > 0 )); then
        echo "${C_MAL}Faltan herramientas:${C_FIN} ${falta[*]}"
        echo "Ejecuta primero:  ./scripts/preparar-entorno.sh"
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
#   - 2026-08-14: construir-branding.sh dijo [OK] sobre un .deb 0.1.7 con el changelog
#     en 0.1.9. Se invoco sin ENCINA_REPO y construyo OTRO clon, de cuatro dias
#     antes, entero y sin una queja (ver el bloque de las dos comprobaciones en
#     construir-branding.sh). Se le puso un detector A ESE GUION, no se arreglo esto.
#   - 2026-08-23 (§4.67 h): al ejecutarse colocar-esqueleto.sh sin querer, FABRICO UN
#     REPOSITORIO ENTERO en ~/encina y le hizo dos commits.
#
# Un valor por defecto que apunta a un sitio PLAUSIBLE Y DISTINTO es peor que no
# tener valor por defecto: el guion no falla, acierta en otro sitio. Y el arreglo
# no es un detector mas —construir-branding.sh ya escribio por que: cuando la raiz se
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
