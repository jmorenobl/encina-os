#!/usr/bin/env bash
# Encina OS - BANCO DE shellcheck: los guiones versionados, sin avisos de nivel warning.
#
#     ./bancos/shellcheck.sh [--solo-control] [--solo-medicion]
#
# QUE COMPRUEBA: que shellcheck no tiene nada que decir de nivel «error» ni
# «warning» sobre NINGUNO de los guiones .sh versionados (git ls-files, no
# find: medios/verificar-instalacion.sh es una copia que .gitignore tapa). Los
# de nivel «note»/«style» se CUENTAN y se dicen, y no bloquean: hoy son ~116 y
# convertirlos en bloqueo obligaria a reescribir guiones de VM que este Mac no
# ejecuta, que es justo lo que la tarea 2 se nego a hacer sin verificarlo.
#
# POR QUE EXISTE (tarea 6 de tareas/refactorizacion.md): desde la tarea 1
# todas las mediciones decian «[OMIT] shellcheck: no esta en este Mac». Sigue
# sin estar, y no hace falta: si no hay binario se usa la imagen oficial
# koalaman/shellcheck por docker, y en la CI esta el paquete de Ubuntu. Los
# seis avisos que habia el 2026-08-28 se JUSTIFICARON en su sitio con una
# directiva «# shellcheck disable=SCxxxx  # motivo», no se taparon aqui: una
# excepcion sin motivo escrito al lado es lo que construir-firefox.sh
# prohibe a lintian, y aqui se aplica la misma regla.
#
# EL CONTROL VA DELANTE: un guion de mentira con un «ls | grep» (SC2010, nivel
# warning) TIENE que salir rojo, y otro limpio TIENE que salir verde. Si el
# binario no existiera, o la imagen no arrancara, «command not found» daria la
# misma salida vacia que un arbol limpio (leccion del 2026-08-17).

# MODELO DE SALIDA: CONTAR Y SEGUIR (tarea 2, MEDICIONES.md §4.67).
set -uo pipefail
export LC_ALL=C

AQUI=$(cd "$(dirname "$0")" && pwd)
RAIZ=$(cd "$AQUI/.." && pwd)
HACER_CONTROL=1; HACER_MEDICION=1
while [ $# -gt 0 ]; do
    case "$1" in
        --solo-control)  HACER_MEDICION=0; shift ;;
        --solo-medicion) HACER_CONTROL=0;  shift ;;
        -h|--help)       sed -n '2,4p' "$0"; exit 0 ;;
        *) echo "[FALLO] argumento desconocido: $1"; exit 2 ;;
    esac
done
. "$RAIZ/lib/salida.sh"

TMP=$(mktemp -d "${TMPDIR:-/tmp}/shellcheck.XXXXXX") || morir "mktemp"
trap 'rm -rf "$TMP"' EXIT

# sc <args...>  -> shellcheck, con el binario si lo hay y si no por docker.
# Las rutas que se le pasan son RELATIVAS a $RAIZ, para que las dos vias vean
# el mismo arbol (docker monta $RAIZ en /mnt).
IMAGEN=koalaman/shellcheck:stable
if command -v shellcheck >/dev/null 2>&1; then
    VIA="binario $(shellcheck --version | sed -n 's/^version: //p')"
    sc() { (cd "$RAIZ" && shellcheck "$@"); }
elif command -v docker >/dev/null 2>&1 && docker image inspect "$IMAGEN" >/dev/null 2>&1; then
    VIA="docker $IMAGEN $(docker run --rm "$IMAGEN" --version | sed -n 's/^version: //p')"
    sc() { docker run --rm -v "$RAIZ":/mnt -w /mnt "$IMAGEN" "$@"; }
else
    morir "no hay shellcheck ni la imagen $IMAGEN en docker (docker pull $IMAGEN)"
fi
echo "   shellcheck por $VIA"

RC=0
if [ "$HACER_CONTROL" = 1 ]; then
    titulo "EL CONTROL, antes de medir: un guion con un warning conocido y uno limpio"
    mkdir -p "$RAIZ/.bancos-control"
    printf '#!/bin/bash\nls /tmp | grep x\n' > "$RAIZ/.bancos-control/malo.sh"
    printf '#!/bin/bash\necho "hola"\n' > "$RAIZ/.bancos-control/bueno.sh"
    if sc -S warning -f gcc .bancos-control/malo.sh > "$TMP/c1" 2>&1; then
        fallo "CONTROL ROTO: el guion con «ls | grep» pasa a nivel warning" "$(cat "$TMP/c1")"; RC=1
    elif /usr/bin/grep -q 'SC2010' "$TMP/c1"; then
        ok "rojo: el «ls | grep» de mentira sale SC2010 a nivel warning"
    else
        fallo "CONTROL ROTO: el guion malo falla, pero no por SC2010" "$(cat "$TMP/c1")"; RC=1
    fi
    if sc -S warning -f gcc .bancos-control/bueno.sh > "$TMP/c2" 2>&1; then
        ok "verde: el guion limpio pasa"
    else
        fallo "CONTROL ROTO: el guion limpio NO pasa" "$(cat "$TMP/c2")"; RC=1
    fi
    rm -rf "$RAIZ/.bancos-control"
    if [ "$RC" -ne 0 ]; then echo; echo "EL CONTROL NO PASA. No se mide nada."; exit 1; fi
fi

if [ "$HACER_MEDICION" = 1 ]; then
    titulo "LA MEDICION: los guiones versionados"
    (cd "$RAIZ" && /usr/bin/git ls-files '*.sh') > "$TMP/guiones"
    N=$(/usr/bin/grep -c . "$TMP/guiones")
    [ "$N" -gt 0 ] || morir "git ls-files no da ni un .sh"
    # todo lo que diga, a cualquier nivel, para contarlo
    # shellcheck disable=SC2046  # un guion por linea, sin espacios (git ls-files)
    sc -S style -f gcc $(cat "$TMP/guiones") > "$TMP/todo" 2>&1 || true
    N_ERR=$(/usr/bin/grep -c ': error:' "$TMP/todo"); N_WARN=$(/usr/bin/grep -c ': warning:' "$TMP/todo")
    N_NOTE=$(/usr/bin/grep -c ': note:' "$TMP/todo"); N_STYLE=$(/usr/bin/grep -c ': style:' "$TMP/todo")
    echo "   $N guiones: $N_ERR error, $N_WARN warning, $N_NOTE note, $N_STYLE style"
    if [ "$N_ERR" -eq 0 ] && [ "$N_WARN" -eq 0 ]; then
        ok "ningun guion tiene avisos de nivel error ni warning"
    else
        fallo "$N_ERR errores y $N_WARN warnings" "$(/usr/bin/grep -E ': (error|warning):' "$TMP/todo")"; RC=1
    fi
    if [ "$((N_NOTE + N_STYLE))" -gt 0 ]; then
        aviso "$((N_NOTE + N_STYLE)) avisos de nivel note/style, que no bloquean. Los mas repetidos:"
        /usr/bin/grep -oE '\[SC[0-9]+\]' "$TMP/todo" | sort | uniq -c | sort -rn | head -5 | sed 's/^/            /'
    fi
    # las directivas «disable» tienen que llevar motivo: una excepcion muda no vale.
    # Solo cuentan las LINEAS QUE SON DIRECTIVA (empiezan por «# shellcheck»): la
    # primera version buscaba la cadena en cualquier sitio y se denuncio a si
    # misma dos veces, por su prosa y por su propio mensaje de [OK] (CI simulada
    # en ubuntu:24.04, 2026-08-28).
    # shellcheck disable=SC2046  # un guion por linea, sin espacios (git ls-files)
    MUDAS=$(cd "$RAIZ" && /usr/bin/grep -nHE '^[[:space:]]*# shellcheck disable=' $(cat "$TMP/guiones") | /usr/bin/grep -vE 'disable=SC[0-9,]+ +#' || true)
    if [ -z "$MUDAS" ]; then
        ok "toda directiva «shellcheck disable=» lleva su motivo al lado"
    else
        fallo "directivas «disable» sin motivo escrito" "$MUDAS"; RC=1
    fi
fi

echo
echo "=== RESUMEN ==="
echo "   correctas: $N_OK   fallos: $N_MAL   avisos: $N_AVI"
exit $RC
