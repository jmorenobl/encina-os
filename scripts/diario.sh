#!/usr/bin/env bash
# diario.sh — El ritual de cierre en un comando.
#
# Uso:  ./scripts/diario.sh "lo que has hecho y qué toca mañana"
#
# Añade una línea fechada a DIARIO.md y hace commit de todo. Tres minutos que
# valen media hora dentro de nueve días, cuando vuelvas sin acordarte de dónde
# lo dejaste.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
requiere_no_root

REPO="$(raiz_repo)"
DIARIO="$REPO/DIARIO.md"
TEXTO="${*:-}"

if [[ -z "$TEXTO" ]]; then
    echo "Uso: ./scripts/diario.sh \"sesión 4 hecha, lintian limpio. Mañana: instalar\""
    echo
    if [[ -f "$DIARIO" ]]; then
        echo "Últimas entradas:"
        tail -5 "$DIARIO" | sed 's/^/  /'
    fi
    exit 1
fi

[[ -f "$DIARIO" ]] || printf '# Diario de Encina OS\n\n' > "$DIARIO"
printf -- '- **%s** — %s\n' "$(date +%Y-%m-%d)" "$TEXTO" >> "$DIARIO"

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
