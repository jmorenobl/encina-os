#!/usr/bin/env bash
# diario.sh — El ritual de cierre en un comando.
#
# Uso:  ./scripts/diario.sh "lo que has hecho y qué toca mañana"
#
# Añade una línea fechada a DIARIO.md y hace commit de todo. Tres minutos que
# valen media hora dentro de nueve días, cuando vuelvas sin acordarte de dónde
# lo dejaste.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
# MODELO DE SALIDA: CONTAR Y SEGUIR (tarea 2, MEDICIONES.md §4.67). fallo()
# apunta, incrementa N_MAL y SIGUE midiendo; morir() aborta; quien fija el
# código de salida es resumen(). El 'set' lo pone lib.sh:5 al hacer source: se
# REAFIRMA aquí para que las opciones de shell de este guion no dependan de a
# quién llame. Reafirmarlo no cambia ni una opción — control en §4.67.
set -euo pipefail
requiere_no_root

REPO="$(raiz_repo)"
DIARIO="$REPO/DIARIO.md"

# LOS TRES BLOQUES (tarea 8 de tareas/refactorizacion.md, 2026-08-28). Hasta
# hoy una entrada era UNA linea, y las habia de 6 518 caracteres: el contenido
# era bueno y ya traia estas tres cosas mezcladas, pero no se podia localizar
# nada dentro ni ver en un diff que parte cambio. Desde hoy cada entrada sale
# partida en tres, que es lo que de verdad se quiere leer dentro de nueve dias:
#
#     ./scripts/diario.sh "qué se midió" "qué salió mal" "qué toca mañana"
#
# Las entradas viejas NO se reescriben: son el registro de aquel dia. Con un
# solo argumento sigue funcionando -- una linea, como antes -- para no romper a
# quien lo llame asi, pero avisa de que asi no se parte.
MEDIDO="${1:-}"; MAL="${2:-}"; MANANA="${3:-}"

if [[ -z "$MEDIDO" ]]; then
    echo "Uso: ./scripts/diario.sh \"qué se midió\" \"qué salió mal\" \"qué toca mañana\""
    echo "     (tres argumentos, uno por bloque; con uno solo sale como antes, en una línea)"
    echo
    if [[ -f "$DIARIO" ]]; then
        echo "Últimas entradas:"
        tail -5 "$DIARIO" | sed 's/^/  /'
    fi
    exit 1
fi
if [[ $# -gt 3 ]]; then
    morir "sobran argumentos: son tres bloques como mucho (qué se midió · qué salió mal · qué toca mañana)"
fi

[[ -f "$DIARIO" ]] || printf '# Diario de Encina OS\n\n' > "$DIARIO"
if [[ -n "$MAL" || -n "$MANANA" ]]; then
    {
        printf -- '- **%s**\n' "$(date +%Y-%m-%d)"
        printf -- '  - **Qué se midió:** %s\n' "$MEDIDO"
        printf -- '  - **Qué salió mal:** %s\n' "${MAL:-nada que apuntar}"
        printf -- '  - **Qué toca mañana:** %s\n' "${MANANA:-(sin decir)}"
    } >> "$DIARIO"
    # trampa 13: la mutacion se verifica antes de leer su resultado
    tail -4 "$DIARIO" | grep -q '^  - \*\*Qué toca mañana:\*\*' \
        || morir "la entrada no quedo escrita con sus tres bloques en $DIARIO"
    TEXTO="$MEDIDO — mal: ${MAL:-nada} — mañana: ${MANANA:-(sin decir)}"
else
    echo "  [AVISO] un solo argumento: la entrada sale en UNA linea, sin los tres bloques"
    printf -- '- **%s** — %s\n' "$(date +%Y-%m-%d)" "$MEDIDO" >> "$DIARIO"
    TEXTO="$MEDIDO"
fi

cd "$REPO"
git add -A
if git commit -q -m "diario: $TEXTO" 2>/dev/null; then
    echo "Anotado y committeado."
else
    echo "Anotado (no había nada nuevo que committear)."
fi
echo
tail -3 "$DIARIO" | sed 's/^/  /'
echo
echo "Cierra el portátil."
