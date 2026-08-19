#!/usr/bin/env bash
# Encina OS - BANCO DEL LECTOR DE MECANISMOS DE MARCA.
#
#     ./imagen/banco-mecanismos.sh [--medios <dir>]
#
# QUE COMPRUEBA: que «fabricar-iso.sh --leer-mecanismos» sabe decir, mirando una
# ISO y solo la ISO, cuales de los CUATRO mecanismos de marca del medio (D23)
# lleva dentro -- capa, Volume id, .disk/info y menuentry --.
#
# POR QUE EXISTE, y no es adorno: el paso 13 de fabricar-iso.sh coteja lo que
# lleva el medio terminado contra las banderas «--sin-*» con las que se pidio, y
# ES LA UNICA COMPROBACION DEL GUION QUE NO PUEDE ESTAR DE ACUERDO CONSIGO MISMA
# -- todas las demas derivan sus expectativas de la misma bandera --. Si el
# lector se equivocara, un bisecado entero saldria mal y nada lo diria. Una
# construccion son ~20 minutos; este banco son segundos.
#
# EL CONTROL VA DENTRO DE LOS CASOS, no aparte: hay medios donde la respuesta
# tiene que ser «no lleva ninguno» y un medio donde tiene que ser «los lleva los
# cuatro». Un lector mudo -- que contestara siempre lo mismo, o que no llegara a
# ejecutarse -- falla aqui. Es la leccion del 2026-08-17: un banco cuyo binario
# no existia leyo «command not found» como PASA y dio cuatro verdes falsos.
#
# LOS CASOS SON MEDIOS REALES y su composicion esta escrita en MEDICIONES.md
# §4.54i, con su arranque medido -- las tres que dicen «0 0 0 0» son las tres
# cuyo instalador FUNCIONA, y la que dice «1 1 1 1» es la que SE CAE --.

set -uo pipefail
export LC_ALL=C

AQUI=$(cd "$(dirname "$0")" && pwd)
MEDIOS="$AQUI/../medios"
while [ $# -gt 0 ]; do
    case "$1" in
        --medios) MEDIOS="$2"; shift 2 ;;
        -h|--help) sed -n '1,30p' "$0"; exit 0 ;;
        *) echo "[FALLO] argumento desconocido: $1"; exit 2 ;;
    esac
done

N_OK=0; N_FALLO=0; N_OMIT=0
echo "== el lector de mecanismos, contra medios reales (capa volid info menu)"
printf '   %-8s %-8s %s\n' esperado leido medio
while IFS='|' read -r ESP ISO NOTA; do
    if [ ! -f "$MEDIOS/$ISO" ]; then
        printf '[OMIT]  %-8s %-8s %-38s %s\n' "$ESP" "--" "$ISO" "no esta en $MEDIOS"
        N_OMIT=$((N_OMIT+1)); continue
    fi
    LEIDO=$("$AQUI/fabricar-iso.sh" --leer-mecanismos "$MEDIOS/$ISO" 2>&1 | cut -d' ' -f1-7 | sed 's/   .*//')
    if [ "$LEIDO" = "$ESP" ]; then
        printf '[OK]    %-8s %-8s %-38s %s\n' "$ESP" "$LEIDO" "$ISO" "$NOTA"; N_OK=$((N_OK+1))
    else
        printf '[FALLO] %-8s %-8s %-38s %s\n' "$ESP" "$LEIDO" "$ISO" "$NOTA"; N_FALLO=$((N_FALLO+1))
    fi
done <<'CASOS'
0 0 0 0|ubuntu-24.04.4-desktop-arm64.iso|la oficial de Canonical
0 0 0 0|encina-os-E4-es-0.2.1.iso|ac0a5721: el instalador FUNCIONA
0 0 0 0|encina-os-E4-es-0.2.1-1224b5b1.iso|1224b5b1, .deb y seed nuevos: FUNCIONA
1 1 1 1|encina-os-0.2.1-encinaos-p1.iso|e8a0ead2, los cuatro de D23: SE CAE
CASOS

# EL CONTROL DEL PROPIO BANCO: si no se ha ejecutado ni un caso, o si todos los
# casos esperaran lo mismo, este banco no demostraria nada aunque saliera verde.
if [ "$N_OK" -eq 0 ] && [ "$N_FALLO" -eq 0 ]; then
    echo "[FALLO] CONTROL ROTO: no se ejecuto ni un caso ($N_OMIT omitidos): esto NO es un aprobado"
    exit 1
fi
echo
echo "correctas: $N_OK   fallos: $N_FALLO   omitidas: $N_OMIT"
[ "$N_FALLO" -eq 0 ] || exit 1
[ "$N_OMIT" -eq 0 ] || echo "[AVISO] $N_OMIT medios no estaban: el banco vale menos de lo que parece"
