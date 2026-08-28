#!/usr/bin/env bash
# lib.sh — utilidades comunes de los scripts de Encina OS.
# No se ejecuta directamente; se carga con:  source "$(dirname "$0")/lib.sh"
#
# DESDE EL 2026-08-28 (tarea 3 de tareas/refactorizacion.md) ESTE FICHERO NO
# DEFINE NADA: es el puente a las dos capas en que se partio.
#
#   lib/salida.sh   el vocabulario [OK] [FALLO] [AVISO] [OMIT] [OJOS], los
#                   contadores, fallo()/morir(), comprobar*() y resumen().
#                   Portatil: lo cargan tambien imagen/ y bancos/.
#   lib/vm.sh       lo que solo sirve en la VM Ubuntu: raiz_repo(), los
#                   requisitos, resolver_desktop(), PKG_DIR, el vigilante.
#
# Se conserva con este nombre y en este sitio porque 17 guiones lo cargan con
# la linea de arriba y los documentos lo citan por su ruta; renombrar el punto
# de entrada habria sido tocar 17 guiones de VM que este Mac no ejecuta, para
# no ganar nada. Lo que cambia es que ya no hay dos sitios donde definir ok().
#
# MODELO DE SALIDA: CONTAR Y SEGUIR — es la biblioteca que lo define (tarea 2,
# MEDICIONES.md §4.67). Los 17 guiones que hacen source heredan de aqui estas
# opciones, y desde la tarea 2 TODOS las reafirman en su cabecera: se deja
# esta linea porque es la que ellos reafirman, no porque nadie dependa de ella.
# lib/salida.sh y lib/vm.sh NO tocan las opciones del shell a proposito: los
# guiones de imagen/ que cargan salida.sh corren sin -e.
set -euo pipefail

# shellcheck source=lib/vm.sh
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/vm.sh"
