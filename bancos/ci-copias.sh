#!/usr/bin/env bash
# Encina OS - BANCO DE LAS DOS COPIAS DE LA CI: el heredoc de 06-ci.sh == build.yml.
#
#     ./bancos/ci-copias.sh
#
# QUE COMPRUEBA: que el flujo de GitHub Actions que scripts/06-ci.sh escribe
# (su heredoc, entre «cat > "$FLUJO" << 'EOF'» y «EOF») es BYTE A BYTE
# .github/workflows/build.yml.
#
# POR QUE EXISTE: 06-ci.sh lo avisa en su cabecera desde el 2026-08-13 --«es
# una SEGUNDA COPIA … Si tocas una, toca la otra»-- y el 2026-08-28, al
# escribir este banco (tarea 6), las dos copias llevaban CINCO DIAS separadas:
# la tarea 13 (§4.69) puso la matriz de dos arquitecturas en build.yml y el
# heredoc seguia con «runs-on: ubuntu-latest», 33 lineas de diff. Un aviso en
# un comentario no es una comprobacion; esto si.
#
# EL CONTROL VA DELANTE: sobre una copia del flujo con UN byte cambiado el
# comparador tiene que decir que no.

# MODELO DE SALIDA: CONTAR Y SEGUIR (tarea 2, MEDICIONES.md §4.67).
set -uo pipefail
export LC_ALL=C

AQUI=$(cd "$(dirname "$0")" && pwd)
RAIZ=$(cd "$AQUI/.." && pwd)
. "$RAIZ/lib/salida.sh"

GUION="$RAIZ/scripts/06-ci.sh"
FLUJO="$RAIZ/.github/workflows/build.yml"
[ -f "$GUION" ] || morir "no esta $GUION"
[ -f "$FLUJO" ] || morir "no esta $FLUJO"

TMP=$(mktemp -d "${TMPDIR:-/tmp}/ci-copias.XXXXXX") || morir "mktemp"
trap 'rm -rf "$TMP"' EXIT

awk '/^cat > "\$FLUJO" << .EOF.$/ {en=1; next} /^EOF$/ {en=0} en' "$GUION" > "$TMP/heredoc.yml"
N=$(/usr/bin/grep -c . "$TMP/heredoc.yml")
[ "$N" -ge 20 ] || morir "la extraccion del heredoc sale con $N lineas: no se mide sobre nada"

titulo "EL CONTROL: un byte cambiado en el flujo se tiene que ver"
sed '1s/^./X/' "$FLUJO" > "$TMP/sab.yml"
cmp -s "$FLUJO" "$TMP/sab.yml" && morir "CONTROL ROTO: el sabotaje no cambio nada"
if cmp -s "$TMP/heredoc.yml" "$TMP/sab.yml"; then
    fallo "CONTROL ROTO: el comparador da por iguales dos ficheros que difieren en un byte"
else
    ok "control: el comparador ve un byte cambiado"
fi

titulo "LA MEDICION: el heredoc de 06-ci.sh contra build.yml"
if cmp -s "$TMP/heredoc.yml" "$FLUJO"; then
    ok "las dos copias son identicas byte a byte ($N lineas)"
else
    D=$(/usr/bin/diff "$TMP/heredoc.yml" "$FLUJO" | /usr/bin/grep -c '^[<>]')
    fallo "el heredoc de 06-ci.sh y build.yml difieren en $D lineas. Copia el flujo DENTRO del guion, no lo transcribas:" \
"$(/usr/bin/diff "$TMP/heredoc.yml" "$FLUJO" | head -12)"
fi

echo
echo "=== RESUMEN ==="
echo "   correctas: $N_OK   fallos: $N_MAL"
[ "$N_MAL" -eq 0 ] || exit 1
exit 0
