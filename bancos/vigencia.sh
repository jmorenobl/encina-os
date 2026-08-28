#!/usr/bin/env bash
# Encina OS - BANCO DE LA TABLA DE VIGENCIA: que ninguna seccion se quede sin fila.
#
#     ./bancos/vigencia.sh [--mediciones <dir>] [--solo-control] [--solo-medicion]
#
# QUE COMPRUEBA: que la tabla «Estado de vigencia» de mediciones/LEEME.md tiene
# EXACTAMENTE una fila por cada seccion que existe en mediciones/ -- ni una
# seccion sin fila, ni una fila de una seccion que no existe, ni una seccion con
# dos filas --.
#
# POR QUE EXISTE (tarea 5 de tareas/refactorizacion.md): la tabla de vigencia
# es lo mejor que tiene el registro -- resuelve el problema que hunde a todos
# los cuadernos de laboratorio, que es no saber que de lo escrito hace un mes
# sigue en pie -- y el 2026-08-23 cubria 33 secciones de 65: estaba al dia hasta
# el 2026-08-15 y PARADA desde entonces. Desde fuera «vigente» y «nadie lo ha
# revisado» se leian igual. Con el registro partido en un fichero por seccion
# (tarea 4) esto es un ls contra un grep, y por eso se puede exigir en la CI.
#
# DE DONDE SALE CADA LADO, y no se adivina:
#   - las secciones que EXISTEN: la primera linea de cada mediciones/*.md, que
#     desde la tarea 4 es «# 4.NN …», «# 9. …» o «# A3 — …». NO el nombre del
#     fichero: el nombre lleva el numero, pero lo que se cita es el titulo.
#   - las filas que HAY: las lineas «| §4.NN |», «| §9 |» y «| A3 |» de la
#     tabla de LEEME.md, y solo de la tabla (entre su cabecera y la primera
#     linea que no empiece por «|»).
#
# EL CONTROL VA DELANTE, y son sus dos respuestas: sobre una copia de la tabla
# a la que se le QUITA una fila tiene que salir [FALLO] nombrando esa seccion;
# sobre una copia a la que se le ANADE una fila de una seccion inventada
# (§4.999) tiene que salir [FALLO] nombrandola. Si el control no da las dos, no
# se mide nada: un comparador que no ve una fila de menos daria el mismo verde
# sobre la tabla parada de antes.

# MODELO DE SALIDA: CONTAR Y SEGUIR (tarea 2, MEDICIONES.md §4.67). fallo()
# apunta y SIGUE; morir() aborta; el codigo de salida lo fija el final.
set -uo pipefail
export LC_ALL=C

AQUI=$(cd "$(dirname "$0")" && pwd)
RAIZ=$(cd "$AQUI/.." && pwd)
MEDICIONES="$RAIZ/mediciones"
HACER_CONTROL=1; HACER_MEDICION=1
while [ $# -gt 0 ]; do
    case "$1" in
        --mediciones)    MEDICIONES=$(cd "$2" && pwd); shift 2 ;;
        --solo-control)  HACER_MEDICION=0; shift ;;
        --solo-medicion) HACER_CONTROL=0;  shift ;;
        -h|--help)       sed -n '2,4p' "$0"; exit 0 ;;
        *) echo "[FALLO] argumento desconocido: $1"; exit 2 ;;
    esac
done

# EL VOCABULARIO VIENE DE lib/salida.sh (tarea 3)
. "$RAIZ/lib/salida.sh"

TMP=$(mktemp -d "${TMPDIR:-/tmp}/vigencia.XXXXXX") || morir "mktemp"
trap 'rm -rf "$TMP"' EXIT

# secciones <dir> -> una por linea, «4.37», «9», «A3», ordenadas
secciones() {
    local f
    for f in "$1"/*.md; do
        [ "$(basename "$f")" = LEEME.md ] && continue
        head -1 "$f" | sed -n -E 's/^# +(A[0-9]+) — .*/\1/p; s/^# +([0-9]+(\.[0-9]+)?)\.? .*/\1/p'
    done | LC_ALL=C sort -u
}
# filas <LEEME.md> -> una por linea, con el mismo formato, SIN deduplicar (una
# seccion con dos filas tiene que verse)
filas() {
    awk '
        /^\| *Sección *\| *Qué mide *\|/ { en=1; next }
        en && /^\|---/ { next }
        en && !/^\|/ { en=0 }
        en { print }
    ' "$1" | sed -n -E 's/^\| *(§)?(A[0-9]+|[0-9]+(\.[0-9]+)?) *\|.*/\2/p' | LC_ALL=C sort
}
# OJO con el «(§)?» de arriba: bajo LC_ALL=C el signo son DOS bytes, y «§?»
# solo hace opcional el segundo, asi que «| A3 |» no casaba y la fila de A3
# salia como inexistente. Se vio al estrenar el guion: la primera pasada dijo
# «§A3 existe y NO tiene fila» con la fila delante.

# comparar <dir> <LEEME.md> <rotulo> -> imprime y cuenta
comparar() {
    local dir="$1" leeme="$2" rot="$3"
    secciones "$dir" > "$TMP/secciones"
    filas "$leeme"    > "$TMP/filas"
    local ns nf
    ns=$(/usr/bin/grep -c . "$TMP/secciones"); nf=$(/usr/bin/grep -c . "$TMP/filas")
    [ "$ns" -gt 0 ] || { fallo "$rot: no se ha leido ni una seccion en $dir"; return 1; }
    [ "$nf" -gt 0 ] || { fallo "$rot: no se ha leido ni una fila en $leeme"; return 1; }
    echo "   $rot: $ns secciones en $dir, $nf filas en $(basename "$leeme")"
    local r=0 s
    # sin fila
    while read -r s; do
        [ -n "$s" ] || continue
        fallo "$rot: la seccion §$s existe y NO tiene fila en la tabla de vigencia"; r=1
    done < <(LC_ALL=C comm -23 "$TMP/secciones" <(LC_ALL=C sort -u "$TMP/filas"))
    # sin seccion
    while read -r s; do
        [ -n "$s" ] || continue
        fallo "$rot: la tabla tiene una fila de §$s y esa seccion NO existe"; r=1
    done < <(LC_ALL=C comm -13 "$TMP/secciones" <(LC_ALL=C sort -u "$TMP/filas"))
    # repetidas
    while read -r s; do
        [ -n "$s" ] || continue
        fallo "$rot: la seccion §$s tiene MAS DE UNA fila"; r=1
    done < <(LC_ALL=C uniq -d "$TMP/filas")
    [ "$r" -eq 0 ] && ok "$rot: las $ns secciones tienen exactamente una fila, y las $nf filas tienen seccion"
    return $r
}

RC=0
if [ "$HACER_CONTROL" = 1 ]; then
    titulo "EL CONTROL, antes de medir: una fila de menos y una fila de mas"
    [ -f "$MEDICIONES/LEEME.md" ] || morir "no esta $MEDICIONES/LEEME.md"
    # la fila que se quita: la de la primera seccion que exista (no se elige a mano)
    VICTIMA=$(secciones "$MEDICIONES" | head -1)
    [ -n "$VICTIMA" ] || morir "CONTROL ROTO: no hay secciones en $MEDICIONES"
    /usr/bin/grep -v "^| §$VICTIMA |" "$MEDICIONES/LEEME.md" > "$TMP/menos.md"
    cmp -s "$MEDICIONES/LEEME.md" "$TMP/menos.md" && morir "CONTROL ROTO: quitar la fila de §$VICTIMA no cambio la tabla (¿no tenia fila?)"
    # el comparador corre en un SUBSHELL: lo que cuente ahi son respuestas del
    # control, no de la medicion, y no tienen que sumar a los contadores de aqui
    if ( comparar "$MEDICIONES" "$TMP/menos.md" "control 1/2 (sin la fila de §$VICTIMA)" ) >"$TMP/c1" 2>&1; then
        fallo "CONTROL ROTO: con la fila de §$VICTIMA quitada, el comparador dice que todo cuadra" "$(cat "$TMP/c1")"; RC=1
    elif /usr/bin/grep -q "§$VICTIMA existe y NO tiene fila" "$TMP/c1"; then
        ok "control 1/2: sin la fila de §$VICTIMA, el comparador la nombra"
    else
        fallo "CONTROL ROTO: fallo, pero no por la fila quitada" "$(cat "$TMP/c1")"; RC=1
    fi
    { cat "$MEDICIONES/LEEME.md"; } > "$TMP/mas.md"
    # la fila inventada se cuela DENTRO de la tabla, justo detras de la cabecera
    awk 'BEGIN{OFS=""} {print} /^\|---\|---\|---\|/ && !hecho { print "| §4.999 | una seccion que no existe | (control) |"; hecho=1 }' "$MEDICIONES/LEEME.md" > "$TMP/mas.md"
    cmp -s "$MEDICIONES/LEEME.md" "$TMP/mas.md" && morir "CONTROL ROTO: la fila inventada no entro en la tabla"
    if ( comparar "$MEDICIONES" "$TMP/mas.md" "control 2/2 (con una fila de §4.999)" ) >"$TMP/c2" 2>&1; then
        fallo "CONTROL ROTO: con una fila de §4.999, el comparador dice que todo cuadra" "$(cat "$TMP/c2")"; RC=1
    elif /usr/bin/grep -q "fila de §4.999 y esa seccion NO existe" "$TMP/c2"; then
        ok "control 2/2: con una fila de §4.999, el comparador la nombra"
    else
        fallo "CONTROL ROTO: fallo, pero no por la fila inventada" "$(cat "$TMP/c2")"; RC=1
    fi
    if [ "$RC" -ne 0 ]; then
        echo; echo "EL CONTROL NO PASA. No se mide nada."; exit 1
    fi
fi

if [ "$HACER_MEDICION" = 1 ]; then
    titulo "LA MEDICION, sobre $MEDICIONES"
    comparar "$MEDICIONES" "$MEDICIONES/LEEME.md" "vigencia" || RC=1
fi

echo
echo "=== RESUMEN ==="
echo "   correctas: $N_OK   fallos: $N_MAL"
[ "$RC" = 0 ] && echo "   ninguna seccion sin fila, ninguna fila sin seccion."
exit $RC
