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
# §4.54i, con su arranque medido.
#
# LAS ESPERAS DE LA COLUMNA «capa» CAMBIARON EL 2026-08-20, y se deja escrito al
# lado lo que decian: hasta ese dia el lector daba la capa por presente con solo
# ver un squashfs de mas en /casper, y con esa regla e8a0ead2 y p9-nutria daban
# «1 1 1 1». Pero ESE FICHERO NO SE MONTABA NUNCA (§4.54e): el mecanismo no es
# que la capa viaje, es que la capa MANDE, y para eso hace falta ademas el
# layerfs-path= de la linea del nucleo. Con la regla nueva esos dos medios dan
# «0 1 1 1», que es una descripcion mas verdadera del producto que llevaban.
#
# Y ESO SE LLEVA POR DELANTE UNA PREMISA DE §4.54i: el bisecado que dejo la
# regresion «dentro del grupo de D23» vario una capa INERTE, asi que lo que alli
# se llamo «la capa» significaba solo «un fichero de mas en /casper». No invalida
# el bisecado -- la regresion sigue dentro del grupo -- pero si lo que se creia
# que era una de sus cuatro piezas.

# MODELO DE SALIDA: CONTAR Y SEGUIR (tarea 2, MEDICIONES.md §4.67). fallo()
# apunta, incrementa el contador y SIGUE midiendo; morir() aborta; el codigo
# de salida lo fija el resumen del final. El 'set' de abajo es el que este
# guion ya tenia y no se ha unificado con el de lib.sh: cambiar las opciones
# de shell de un guion sin ejecutarlo entero seria una mutacion sin verificar.
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

# EL VOCABULARIO VIENE DE lib/salida.sh (tarea 3): ok/fallo/aviso/omitido, los
# contadores N_OK/N_MAL/N_AVI/N_OMI y morir(). Este guion ya no define ninguno.
. "$AQUI/../lib/salida.sh"
CORRIDOS=()
echo "== el lector de mecanismos, contra medios reales (capa volid info menu)"
printf '   %-8s %-8s %s\n' esperado leido medio
while IFS='|' read -r ESP ISO NOTA; do
    if [ ! -f "$MEDIOS/$ISO" ]; then
        omitido "$(printf '%-8s %-8s %-38s %s' "$ESP" "--" "$ISO" "no esta en $MEDIOS")"; continue
    fi
    LEIDO=$("$AQUI/fabricar-iso.sh" --leer-mecanismos "$MEDIOS/$ISO" 2>&1 | cut -d' ' -f1-7 | sed 's/   .*//')
    CORRIDOS+=("$ESP")
    if [ "$LEIDO" = "$ESP" ]; then
        ok    "$(printf '%-8s %-8s %-38s %s' "$ESP" "$LEIDO" "$ISO" "$NOTA")"
    else
        fallo "$(printf '%-8s %-8s %-38s %s' "$ESP" "$LEIDO" "$ISO" "$NOTA")"
    fi
done <<'CASOS'
0 0 0 0|ubuntu-24.04.4-desktop-arm64.iso|la oficial de Canonical
0 0 0 0|encina-os-E4-es-0.2.1.iso|ac0a5721: el instalador FUNCIONA
0 0 0 0|encina-os-E4-es-0.2.1-1224b5b1.iso|1224b5b1, .deb y seed nuevos: FUNCIONA
0 1 1 1|encina-os-0.2.1-encinaos-p1.iso|e8a0ead2: capa INERTE (sin layerfs-path). Antes se esperaba 1 1 1 1
0 1 1 1|encina-os-p9-nutria.iso|71f7958c, el producto del 2026-08-20: capa INERTE, instalador FUNCIONA
1 1 1 1|encina-os-p10-capa.iso|el primero con layerfs-path=: la capa MANDA
CASOS

# EL CONTROL DEL PROPIO BANCO: si no se ha ejecutado ni un caso, o si todos los
# casos esperaran lo mismo, este banco no demostraria nada aunque saliera verde.
if [ "$N_OK" -eq 0 ] && [ "$N_MAL" -eq 0 ]; then
    echo "[FALLO] CONTROL ROTO: no se ejecuto ni un caso ($N_OMI omitidos): esto NO es un aprobado"
    exit 1
fi

# Y EL CONTROL QUE FALTABA, COLUMNA A COLUMNA. Que el banco haya ejecutado casos
# no basta: si UNA de las cuatro columnas sale constante entre los casos que de
# verdad corrieron, un lector que contestara siempre lo mismo EN ESA COLUMNA
# pasaria en verde. Es lo que iba a pasar el 2026-08-20 al redefinir «capa»: sin
# un medio con layerfs-path= no quedaba ni un caso que esperara «1» ahi.
echo
i=0
for COL in capa volid info menu; do
    i=$((i+1))
    VALS=$(printf '%s\n' "${CORRIDOS[@]}" | cut -d' ' -f$i | sort -u | tr '\n' ' ')
    N_V=$(printf '%s\n' "${CORRIDOS[@]}" | cut -d' ' -f$i | sort -u | /usr/bin/grep -c .)
    if [ "$N_V" -ge 2 ]; then
        # NO suma a «correctas»: esto describe la TABLA DE CASOS, no una lectura.
        # Sumarlo daria un «correctas: 3» con los cinco casos en rojo, que fue lo
        # primero que enseno este control al estrenarlo.
        echo "  [OK]    columna «$COL»: los casos que corrieron esperan las dos respuestas ($VALS)"
    else
        aviso "columna «$COL»: todos los casos que corrieron esperan «$VALS». En esa columna
          este banco NO puede distinguir un lector bueno de uno que conteste siempre lo mismo"
    fi
done
echo
echo "correctas: $N_OK   fallos: $N_MAL   omitidas: $N_OMI"
[ "$N_MAL" -eq 0 ] || exit 1
[ "$N_OMI" -eq 0 ] || echo "[AVISO] $N_OMI medios no estaban: el banco vale menos de lo que parece"
