#!/bin/bash
# Encina OS - manda teclas a una VM de UTM sin ojos.
#
#     ./teclear-vm.sh <nombre VM> tecla <key code> [modificador...]
#     ./teclear-vm.sh <nombre VM> texto "lo que sea"
#
# SON TRES COSAS Y HAY QUE HACER LAS TRES (MEDICIONES.md 4.32h), y desde el
# 2026-08-13 son CUATRO -- la cuarta costo media hora de teclas que no llegaban:
#
#   1. El raton de UTM no llega; el teclado de System Events si.
#   2. Ctrl+Alt NUNCA llega al invitado: es el atajo de UTM para soltar el raton
#      y lo intercepta el anfitrion. Lo que funciona es Alt+F1 / Alt+F2.
#   3. Hay que reactivar UTM y comprobar que es el proceso frontal ANTES DE CADA
#      ENVIO: System Events entrega al proceso FRONTAL, no al que se nombra.
#   4. Y NO BASTA CON AXRaise: la ventana de la VM tiene que quedar como
#      AXMain. Con AXRaise sola la ventana se ve delante, la captura sale bien
#      Y LAS TECLAS NO LLEGAN, sin ningun error. La senal que lo delata es la
#      de la trampa: el reloj del invitado avanza y la pantalla no cambia.
#
# Y LA DEFENSA DE LOS CARACTERES COMIDOS: caracter a caracter con 0,2 s.
# keystroke "encinacinco" dejo "encinacin" en un campo y asi se quedo un
# hostname. MIRA EN LA PANTALLA LO QUE TECLEASTE antes de creerte el resultado.
#
# QUINTA, del 2026-08-14, Y ES LA QUE MAS CARA PUEDE SALIR:
#   LOS DIGITOS NO SE PUEDEN MANDAR CON keystroke. Llegan al invitado como
#   SECUENCIAS DE ESCAPE -ESC [ n ~-, que la terminal interpreta como teclas de
#   navegacion. Medido en pantalla: teclear "echo 1234567890 fin" dejo en la
#   linea 'sudo poweroff.:.. fin', que es una orden RECUPERADA DEL HISTORIAL.
#   Un Intro de mas ahi apaga la maquina.
#   Lo que si funciona, medido el mismo dia: mandarlos por CODIGO. Este guion lo
#   hace solo desde esta version -- 'texto' detecta los digitos y los manda con
#   'key code', y el resto con keystroke.
#   Del resto de caracteres, comprobado en pantalla:  /  -  _  .  :  llegan bien
#   con keystroke;  =  y  @  no llegan.
#
# Y LA REGLA QUE SE PAGO SOLA: captura la pantalla ANTES de pulsar Intro. La
# linea con 'sudo poweroff' la escribio este guion sin querer, y lo unico que lo
# evito fue mirarla.

set -u
VM="${1:?uso: teclear-vm.sh <nombre VM> tecla|texto ...}"
MODO="${2:?uso: teclear-vm.sh <nombre VM> tecla|texto ...}"
shift 2

delante() {
    osascript <<EOF
tell application "UTM" to activate
delay 1
tell application "System Events"
  tell process "UTM"
    set frontmost to true
    set w to first window whose name contains "$VM"
    perform action "AXRaise" of w
    set value of attribute "AXMain" of w to true
    delay 0.5
    if (value of attribute "AXMain" of w) is false then error "la ventana no quedo AXMain"
  end tell
end tell
EOF
}

case "$MODO" in
  tecla)
    CODIGO="${1:?falta el key code}"; shift
    MODS=""
    for m in "$@"; do MODS="$MODS $m down,"; done
    MODS="${MODS%,}"
    delante || exit 1
    if [ -n "$MODS" ]; then
        osascript -e "tell application \"System Events\" to tell process \"UTM\" to key code $CODIGO using {$MODS}"
    else
        osascript -e "tell application \"System Events\" to tell process \"UTM\" to key code $CODIGO"
    fi
    ;;
  texto)
    TEXTO="${1:?falta el texto}"
    delante || exit 1
    # Los digitos van por codigo y el resto por keystroke: ver la quinta trampa
    # de la cabecera. Codigos de macOS para 1..0.
    codigo_digito() {
        case "$1" in
            1) echo 18 ;; 2) echo 19 ;; 3) echo 20 ;; 4) echo 21 ;; 5) echo 23 ;;
            6) echo 22 ;; 7) echo 26 ;; 8) echo 28 ;; 9) echo 25 ;; 0) echo 29 ;;
        esac
    }
    i=0
    while [ $i -lt ${#TEXTO} ]; do
        c="${TEXTO:$i:1}"
        case "$c" in
            [0-9])
                osascript -e "tell application \"System Events\" to tell process \"UTM\" to key code $(codigo_digito "$c")"
                ;;
            *)
                osascript <<EOF
tell application "System Events" to tell process "UTM" to keystroke "$(printf '%s' "$c" | sed 's/[\\"]/\\\\&/g')"
EOF
                ;;
        esac
        /bin/sleep 0.2
        i=$((i + 1))
    done
    ;;
  *) echo "[FALLO] modo desconocido: $MODO (tecla|texto)"; exit 2 ;;
esac
