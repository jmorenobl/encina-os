#!/usr/bin/env bash
# lib/salida.sh — EL VOCABULARIO DE SALIDA de Encina OS, y nada mas.
# No se ejecuta directamente; se carga con:  . "$RAIZ/lib/salida.sh"
#
# Es la capa PORTATIL de lo que hasta el 2026-08-28 era scripts/lib.sh entero
# (tarea 3 de tareas/refactorizacion.md): lo que aqui hay corre igual en macOS
# y en Ubuntu, y por eso lo pueden cargar los guiones de imagen/ y de bancos/,
# que hasta hoy reimplementaban cada uno su ok/fallo/aviso/omitido con su
# propio relleno de espacios -- diez guiones con funcion propia y tres bancos
# con 'echo "[OK]"' a pelo --, asi que la salida del proyecto no estaba
# alineada consigo misma. Lo que depende de Ubuntu -- resolver un .desktop,
# la raiz del repositorio, el vigilante de AutoFirma -- vive en lib/vm.sh.
#
# ESTE FICHERO NO TOCA LAS OPCIONES DEL SHELL. Los guiones de imagen/ corren
# con 'set -uo pipefail' (sin -e) y los de scripts/ con 'set -euo pipefail';
# un 'set' aqui cambiaria el flujo de control de quien lo carga sin que se
# viera. Cada guion declara el suyo en su cabecera (tarea 2, MEDICIONES.md
# §4.67).
#
# EL VOCABULARIO, que es el de CLAUDE.md y se respeta al escribir guiones:
#   [OK]     comprobado y correcto
#   [FALLO]  comprobado e incorrecto, CON LA SALIDA LITERAL (segundo argumento)
#   [AVISO]  mirar, no bloquea
#   [OMIT]   no comprobado: NO darlo por bueno
#   [OJOS]   solo lo puede verificar una persona mirando la pantalla, y es de
#            Jorge: se lista y no se cuenta como aprobado
# Las etiquetas van rellenadas a OCHO caracteres para que el texto de detras
# quede en la misma columna en todos los guiones.
#
# DOS PALABRAS PARA DOS COSAS OPUESTAS (tarea 2, §4.67):
#   fallo()  apunta, incrementa N_MAL y SIGUE midiendo. El codigo de salida lo
#            decide resumen(), o el bloque de cierre del guion.
#   morir()  NO cuenta y NO vuelve: «no se puede continuar». Escribe por
#            stderr y sale con 1. El nombre lo voto el arbol antes de que
#            existiera aqui (imagen/capa-marca.sh y scripts/contar-arranques.sh).

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
# un dato que no es ni bueno ni malo: se imprime para que quede escrito
dato()    { echo "  [DATO]  $*"; }

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

# Marca algo que solo puede verificar un humano con los ojos. No cuenta.
pendiente_visual() {
    echo "  ${C_AVI}[OJOS]${C_FIN}  $*"
}
ojos() { pendiente_visual "$@"; }

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
