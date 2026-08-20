#!/usr/bin/env bash
# Encina OS - CUENTA ARRANQUES DE VARIOS MEDIOS, INTERCALANDO, CON VEREDICTO.
#
#     ./scripts/contar-arranques.sh --rondas 5 [--ventana 420] [--salida DIR]
#
# QUE HACE: por cada ronda arranca los brazos UNO DETRAS DE OTRO en el mismo
# orden, los deja la misma ventana de tiempo, los para y lee el framebuffer que
# UTM escribe al parar. Cada arranque produce una linea del TSV.
#
# POR QUE INTERCALADO Y NO EN BLOQUES. La carga de este anfitrion deriva a lo
# largo de la sesion. En bloques, el brazo al que le toque el mal rato sale peor
# SIN QUE LA CAPA TENGA NADA QUE VER, y eso es exactamente lo que convierte una
# correlacion en una causa falsa. Ronda a ronda, la deriva le cae a los tres.
#
# POR QUE UNA VENTANA FIJA Y SIN PRORROGA. Una prorroga solo se dispararia en los
# arranques que van mal, o sea que daria trato distinto a los brazos justo en los
# casos que se estan contando. 420 s son 4,6 veces el arranque bueno medido (el
# instalador sale a los ~90 s).
#
# LA COMPROBACION QUE NO SE PUEDE QUITAR (trampa 13: una mutacion se verifica
# ANTES de leer su resultado). UTM solo reescribe 'screenshot.png' al parar. Si
# no lo reescribiera -- porque el stop fallo, porque la VM ya estaba parada,
# porque utmctl devolvio 0 sin hacer nada (trampa 28) -- se leeria el framebuffer
# DEL ARRANQUE ANTERIOR y se contaria dos veces el mismo dato. Se compara el
# mtime de antes con el de despues y si no cambio la linea sale [FALLO] y NO
# cuenta como arranque.
#
# EL VEREDICTO NO LO DA ESTE GUION: lo da veredicto-pantalla.py, que tiene su
# banco (banco-veredicto.sh, 9 correctas y tres sabotajes cazados).

set -uo pipefail
export LC_ALL=C
AQUI=$(cd "$(dirname "$0")" && pwd)
DOCS="$HOME/Library/Containers/com.utmapp.UTM/Data/Documents"

RONDAS=5; VENTANA=420
SALIDA="$AQUI/../medios/conteo-arranques"
while [ $# -gt 0 ]; do
    case "$1" in
        --rondas)  RONDAS="$2"; shift 2 ;;
        --ventana) VENTANA="$2"; shift 2 ;;
        --salida)  SALIDA="$2"; shift 2 ;;
        *) echo "[FALLO] argumento desconocido: $1" >&2; exit 1 ;;
    esac
done

# LOS BRAZOS, en el orden en que se intercalan. El tercer campo es lo que lleva
# la capa, y esta aqui para que la linea del TSV se lea sola dentro de un ano.
BRAZOS=(
  "p10:encina-capa-p10:capa-entera-montada"
  "p11:encina-capa-p11:capa-vacia-montada"
  "p9:encina-nutria:capa-inerte-sin-layerfs-path"
)

mkdir -p "$SALIDA/capturas"
TSV="$SALIDA/arranques.tsv"
[ -f "$TSV" ] || printf 'ronda\tbrazo\tvm\tque_lleva\thora\tsegundos\tveredicto\tcolores\tbrillo\tdebug_log\tnota\n' > "$TSV"

echo "== conteo de arranques: $RONDAS rondas x ${#BRAZOS[@]} brazos, ventana ${VENTANA}s"
echo "   salida: $TSV"
echo "   estimado: $(( RONDAS * ${#BRAZOS[@]} * (VENTANA + 35) / 60 )) min"

parar_y_esperar() {   # <vm>  -> 0 si quedo parada
    utmctl stop "$1" >/dev/null 2>&1 || true
    for _ in $(seq 1 40); do
        [ "$(utmctl status "$1" 2>&1)" = "stopped" ] && return 0
        /bin/sleep 1
    done
    return 1
}

for r in $(seq 1 "$RONDAS"); do
    echo
    echo "--- RONDA $r de $RONDAS"
    for entrada in "${BRAZOS[@]}"; do
        BRAZO="${entrada%%:*}"; resto="${entrada#*:}"
        VM="${resto%%:*}"; LLEVA="${resto#*:}"
        SHOT="$DOCS/$VM.utm/screenshot.png"
        DBG="$DOCS/$VM.utm/Data/debug.log"

        if ! parar_y_esperar "$VM"; then
            printf '%s\t%s\t%s\t%s\t%s\t\tFALLO-NO-PARA\t\t\t\tno se pudo dejar parada antes de empezar\n' \
                "$r" "$BRAZO" "$VM" "$LLEVA" "$(date +%H:%M:%S)" >> "$TSV"
            echo "  [FALLO] $BRAZO: no se pudo parar antes de arrancar -- no cuenta"
            continue
        fi
        ANTES=$(/usr/bin/stat -f %m "$SHOT" 2>/dev/null || echo 0)
        H=$(date +%H:%M:%S)
        utmctl start "$VM" >/dev/null 2>&1
        # utmctl start DEVUELVE 0 CUANDO FALLA (trampa 28): el estado es lo que vale.
        /bin/sleep 5
        EST=$(utmctl status "$VM" 2>&1)
        if [ "$EST" != "started" ]; then
            printf '%s\t%s\t%s\t%s\t%s\t\tFALLO-NO-ARRANCA-UTM\t\t\t\testado tras start: %s\n' \
                "$r" "$BRAZO" "$VM" "$LLEVA" "$H" "$EST" >> "$TSV"
            echo "  [FALLO] $BRAZO: utmctl no la puso en marcha (estado: $EST) -- no cuenta"
            continue
        fi
        echo "  $BRAZO ($VM) arrancada a las $H, esperando ${VENTANA}s..."
        /bin/sleep "$VENTANA"
        TAM_DBG=$(/usr/bin/stat -f %z "$DBG" 2>/dev/null || echo 0)
        parar_y_esperar "$VM" || true
        /bin/sleep 3

        DESPUES=$(/usr/bin/stat -f %m "$SHOT" 2>/dev/null || echo 0)
        if [ "$DESPUES" = "$ANTES" ]; then
            printf '%s\t%s\t%s\t%s\t%s\t%s\tFALLO-SIN-CAPTURA\t\t\t%s\tel screenshot NO se reescribio: se estaria leyendo el arranque anterior\n' \
                "$r" "$BRAZO" "$VM" "$LLEVA" "$H" "$VENTANA" "$TAM_DBG" >> "$TSV"
            echo "  [FALLO] $BRAZO: UTM no reescribio el framebuffer -- NO cuenta como arranque"
            continue
        fi
        DST="$SALIDA/capturas/r${r}-${BRAZO}.png"
        cp "$SHOT" "$DST"
        LEIDO=$("$AQUI/veredicto-pantalla.py" "$DST" --tsv)
        V=$(echo "$LEIDO" | cut -f1); C=$(echo "$LEIDO" | cut -f2); B=$(echo "$LEIDO" | cut -f3)
        printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t\n' \
            "$r" "$BRAZO" "$VM" "$LLEVA" "$H" "$VENTANA" "$V" "$C" "$B" "$TAM_DBG" >> "$TSV"
        case "$V" in
            GRAFICA) echo "  [OK]    $BRAZO -> $V ($C colores, brillo $B, debug.log $TAM_DBG)" ;;
            NEGRA)   echo "  [FALLO] $BRAZO -> $V ($C colores, brillo $B, debug.log $TAM_DBG)" ;;
            *)       echo "  [AVISO] $BRAZO -> $V ($C colores, brillo $B) -- hay que MIRAR $DST" ;;
        esac
    done
done

echo
echo "== recuento"
awk -F'\t' 'NR>1 && $7=="GRAFICA" {a[$2]++} NR>1 && $7=="NEGRA" {n[$2]++}
            NR>1 && $7!="GRAFICA" && $7!="NEGRA" {o[$2]++} NR>1 {t[$2]++}
     END {printf "  %-6s %8s %8s %8s %8s\n","brazo","arranco","negra","otros","total";
          for (b in t) printf "  %-6s %8d %8d %8d %8d\n", b, a[b]+0, n[b]+0, o[b]+0, t[b]}' "$TSV"
echo
echo "  El TSV es $TSV. LA CONCLUSION NO LA DA ESTE GUION."
