#!/bin/bash
# Encina OS - captura la ventana de una VM de UTM, y no la del editor.
#
#     ./capturar-vm.sh <nombre de la VM> <salida.png>
#
# POR QUE NO VALE UN screencapture A SECAS (MEDICIONES.md 4.34l): a pantalla
# completa coge lo que este delante, y EL PROPIO PROCESO QUE LANZA LA ORDEN ROBA
# EL FOCO. Lo que funciona es hacerlo TODO DENTRO DEL MISMO AppleScript: activar
# UTM, subir la ventana de la VM, leer su posicion y su tamano, y llamar a
# screencapture -R sin salir del script.
#
# (La via del windowid no sirve aqui: Quartz no esta en el Python del sistema.)
#
# Y SIN PERMISO DE GRABACION DE PANTALLA no escribe fichero y dice
# «could not create image from display», que al menos es un fallo ruidoso.

set -u
VM="${1:?uso: capturar-vm.sh <nombre VM> <salida.png>}"
SALIDA="${2:?uso: capturar-vm.sh <nombre VM> <salida.png>}"

rm -f "$SALIDA"

osascript <<EOF
tell application "UTM" to activate
delay 1
tell application "System Events"
  tell process "UTM"
    set frontmost to true
    delay 0.5
    -- la ventana de la VM es la que lleva su nombre en el titulo
    set w to first window whose name contains "$VM"
    perform action "AXRaise" of w
    delay 0.5
    set {x, y} to position of w
    set {a, b} to size of w
    do shell script "screencapture -x -o -R" & x & "," & y & "," & a & "," & b & " " & quoted form of "$SALIDA"
  end tell
end tell
EOF

if [ ! -s "$SALIDA" ]; then
    echo "[FALLO] no se escribio la captura (permiso de Grabacion de Pantalla?)"
    exit 1
fi
echo "[OK]    $SALIDA  $(/usr/bin/stat -f %z "$SALIDA") bytes"
