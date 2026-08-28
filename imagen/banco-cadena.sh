#!/usr/bin/env bash
# Encina OS - BANCO DE LA CADENA DE CAPAS.
#
#     ./imagen/banco-cadena.sh
#
# QUE COMPRUEBA: que 'cadena_de' y 'lowerdir_de' de capa-marca.sh reproducen el
# bucle de 'setup_overlay' de scripts/casper -- lineas 609-628 del initrd del
# medio -- y no otra cosa parecida.
#
# POR QUE EXISTE, y es el banco mas caro de no tener: casper construye la lista
# de capas QUITANDO PUNTOS del nombre y hace 'panic' si UN eslabon no existe como
# fichero. Un nombre mal calculado no da una capa que no tapa: da UN MEDIO QUE NO
# ARRANCA, y eso se descubre veinte minutos de construccion y un arranque mas
# tarde. Esto son segundos.
#
# EL CASO QUE MANDA ES EL PRIMERO, y no es inventado: es lo que el invitado
# imprimio de verdad en /proc/mounts el 2026-08-17 (MEDICIONES.md §4.54e) con el
# LAYERFS_PATH que trae el initrd. Si la reproduccion no saca ESA cadena, no
# reproduce nada y lo demas no vale.
#
# LA EXTRACCION ES DEL GUION, NO UNA COPIA. Si algun dia capa-marca.sh cambia
# esas funciones, este banco mide LAS NUEVAS. Y si la extraccion sale corta se
# NIEGA a medir, porque un banco que mide un guion vacio contesta que si a todo.

# MODELO DE SALIDA: CONTAR Y SEGUIR (tarea 2, MEDICIONES.md §4.67). fallo()
# apunta, incrementa el contador y SIGUE midiendo; morir() aborta; el codigo
# de salida lo fija el resumen del final. El 'set' de abajo es el que este
# guion ya tenia y no se ha unificado con el de lib.sh: cambiar las opciones
# de shell de un guion sin ejecutarlo entero seria una mutacion sin verificar.
set -uo pipefail
export LC_ALL=C
AQUI=$(cd "$(dirname "$0")" && pwd)
FUENTE="$AQUI/capa-marca.sh"
[ -f "$FUENTE" ] || { echo "[FALLO] no esta $FUENTE" >&2; exit 1; }

TMP=$(mktemp -d) || exit 1
trap 'rm -rf "$TMP"' EXIT
sed -n '/^cadena_de() {/,/^}/p;/^lowerdir_de() {/,/^}/p' "$FUENTE" > "$TMP/fn.sh"
N_L=$(/usr/bin/grep -c . "$TMP/fn.sh")
N_F=$(/usr/bin/grep -c '^[a-z_]*() {' "$TMP/fn.sh")
if [ "$N_F" -ne 2 ] || [ "$N_L" -lt 12 ]; then
    echo "[FALLO] CONTROL ROTO: la extraccion saca $N_F funciones y $N_L lineas de $FUENTE."
    echo "        Esperaba 2 funciones y >=12 lineas. NO se mide: un banco sobre un guion"
    echo "        vacio contesta que si a todo."
    exit 1
fi
echo "== extraidas $N_F funciones ($N_L lineas) de $(basename "$FUENTE")"
# shellcheck disable=SC1090  # el fichero que se carga se acaba de extraer de capa-marca.sh a un temporal: shellcheck no puede seguirlo
. "$TMP/fn.sh"

# EL VOCABULARIO VIENE DE lib/salida.sh (tarea 3): ok/fallo/aviso/omitido, los
# contadores N_OK/N_MAL/N_AVI/N_OMI y morir(). Este guion ya no define ninguno.
. "$AQUI/../lib/salida.sh"
comp() {   # rotulo  esperado  obtenido
    if [ "$2" = "$3" ]; then ok "$1"
    else fallo "$1" "esperaba: $2
obtuvo  : $3"; fi
}

echo
echo "== 1. EL CASO MEDIDO: lo que el invitado imprimio en /proc/mounts (§4.54e)"
# LAYERFS_PATH del initrd, sin tocar nada. Esta cadena no la he elegido yo.
comp "lowerdir= de 'minimal.standard.live.squashfs' == lo que se leyo en la VM" \
     "/minimal.standard.live.squashfs:/minimal.standard.squashfs:/minimal.squashfs" \
     "$(lowerdir_de "$(cadena_de minimal.standard.live.squashfs)")"

echo
echo "== 2. LA CAPA DE ENCINA: cuelga de esa misma cadena y queda la primera"
comp "cadena de 'minimal.standard.live.encina.squashfs', de la corta a la larga" \
     "minimal.squashfs minimal.standard.squashfs minimal.standard.live.squashfs minimal.standard.live.encina.squashfs" \
     "$(cadena_de minimal.standard.live.encina.squashfs)"
comp "y en lowerdir= queda LA PRIMERA, que en overlayfs es la que manda" \
     "/minimal.standard.live.encina.squashfs:/minimal.standard.live.squashfs:/minimal.standard.squashfs:/minimal.squashfs" \
     "$(lowerdir_de "$(cadena_de minimal.standard.live.encina.squashfs)")"

echo
echo "== 3. LOS CONTROLES: nombres que tienen que salir MAL, y por que"
comp "'zz-encina.squashfs' (el nombre de hasta el 2026-08-20): cadena de UNO" \
     "zz-encina.squashfs" "$(cadena_de zz-encina.squashfs)"
comp "'encina.squashfs': cadena de UNO -- el medio quedaria sin sistema debajo" \
     "encina.squashfs" "$(cadena_de encina.squashfs)"
comp "'minimal.squashfs': la base es su propia cadena, y no encadena hacia arriba" \
     "minimal.squashfs" "$(cadena_de minimal.squashfs)"
# y el control de que el calculo NO da lo mismo para todo
if [ "$(cadena_de minimal.standard.live.encina.squashfs)" = "$(cadena_de zz-encina.squashfs)" ]; then
    fallo "CONTROL ROTO: el calculo da lo mismo con los dos nombres"
else
    ok "control: el calculo distingue los dos nombres"
fi

echo
echo "== 4. LA OTRA MITAD: el orden de lowerdir NO es el alfabetico"
# Es lo que se creia hasta §4.54e y por lo que la capa se llamo 'zz-'. Si esta
# comprobacion pasara, la reproduccion estaria copiando la rama MUERTA.
ALFA=$(printf '%s\n' minimal.squashfs minimal.standard.squashfs minimal.standard.live.squashfs \
       | LC_ALL=C sort -r | sed 's|^|/|' | tr '\n' ':' | sed 's/:$//')
REAL=$(lowerdir_de "$(cadena_de minimal.standard.live.squashfs)")
if [ "$ALFA" = "$REAL" ]; then
    fallo "la reproduccion da el orden ALFABETICO: esta copiando la rama muerta" "$REAL"
else
    ok "el orden no es el alfabetico (alfabetico daria: $ALFA)"
fi

echo
echo "correctas: $N_OK   fallos: $N_MAL"
[ "$N_MAL" -eq 0 ] || exit 1
