#!/usr/bin/env bash
# generar.sh — deriva lo que viaja desde design/, y comprueba que cuadra.
#
# Uso:  ./design/generar.sh              COMPRUEBA. No escribe nada.
#       ./design/generar.sh --escribir   regenera lo que sabe regenerar.
#
# Por defecto no escribe, y no es prudencia de más: 'encina.jpg' y
# 'encina-dark.jpg' dejaron de ser degradados el 2026-08-08 y '02-activos.sh'
# sigue sabiendo fabricarlos, así que un guion que escribe por su cuenta en
# src/usr/share/backgrounds/ es una forma de perder trabajo medido.
#
# LO QUE ESTE GUION TODAVÍA NO PUEDE HACER, dicho por delante: rehacer los
# fondos. La orden que convierte un maestro de 3936x2624 en el fichero de
# 3840x2160 que viaja NO SE SABE -se hizo a mano-, y la columna 'orden' del
# manifiesto está a '-' en CUATRO de las seis filas. Mientras siga así, esos
# cuatro fondos se COMPRUEBAN pero no se rehacen, que es media reproducibilidad.
#
# Desde el 2026-08-15 las dos filas del fondo por defecto -encina.jpg y
# encina-dark.jpg, que salen de un maestro propio- SÍ llevan su orden escrita, y
# es reproducible: dos pasadas dan la misma sha256. Este guion todavía NO las
# ejecuta; sigue comprobando huellas y avisando de las filas con '-'. Ejecutarlas
# es lo que cierra la casilla de tareas/aspecto/1-instrumentacion.md, y hace falta
# ffmpeg, que no está declarado como requisito de este guion.

# La raíz sale de dónde está este fichero y no de $HOME/encina: este guion vive
# dentro del árbol, así que puede saberlo, y así funciona sobre un clon en
# cualquier sitio. Se exporta para que raiz_repo() y PKG_DIR() de lib.sh
# apunten aquí y no al valor por defecto.
RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export ENCINA_REPO="$RAIZ"
source "$RAIZ/scripts/lib.sh"
requiere_no_root
requiere_cmd shasum

ESCRIBIR=0
[[ "${1:-}" == "--escribir" ]] && ESCRIBIR=1

DISENO="$RAIZ/design"
PKG="$(PKG_DIR)"
FONDOS_PKG="$PKG/src/usr/share/backgrounds/encina"
SVG_PKG="$PKG/src/usr/share/icons/hicolor/scalable/apps/encina-logo.svg"
SVG_MAESTRO="$DISENO/logotipo/encina.svg"
# El icono del Centro de aplicaciones (D21, 0.1.14). Mismo trato que el
# logotipo: el maestro manda y lo que viaja es una copia idéntica.
TIENDA_PKG="$PKG/src/usr/share/icons/hicolor/scalable/apps/encina-centro-aplicaciones.svg"
TIENDA_MAESTRO="$DISENO/iconos/encina-centro-aplicaciones.svg"
MANIFIESTO="$DISENO/fondos/manifiesto.tsv"
PALETA="$DISENO/paleta.tsv"

huella() { shasum -a 256 "$1" | awk '{print $1}'; }

# El color de un papel de la paleta. paleta.tsv es LA fuente de los hex.
color() {
    awk -F'\t' -v p="$1" '$1==p {print $3}' "$PALETA"
}

titulo "Diseño: comprobación de lo que viaja"
(( ESCRIBIR == 1 )) && paso "MODO ESCRITURA: se regenerará lo que se sepa regenerar"

# --------------------------------------------------------------- logotipo ---
paso "Logotipo"

# Un maestro de design/ y su copia en el paquete. Lo que viaja NO se edita a
# mano (design/LEEME.md): si los dos difieren, o falta un --escribir o alguien
# tocó el derivado, y las dos cosas se dicen distinto.
cotejar_maestro() {
    local que="$1" maestro="$2" copia="$3"
    comprobar_fichero "el maestro existe: ${maestro#$RAIZ/}" "$maestro"
    comprobar_fichero "el derivado de $que existe en el paquete" "$copia"
    [[ -f "$maestro" && -f "$copia" ]] || return 0
    if cmp -s "$maestro" "$copia"; then
        ok "$que: el SVG del paquete es idéntico al maestro"
    elif (( ESCRIBIR == 1 )); then
        cp "$maestro" "$copia"
        ok "$que: SVG copiado al paquete desde el maestro"
    else
        fallo "$que: el SVG del paquete NO es el maestro" \
"maestro:  $(huella "$maestro")
paquete:  $(huella "$copia")
Si el bueno es el maestro:  ./design/generar.sh --escribir
Si el bueno es el del paquete, cópialo tú a design/ y averigua quién lo tocó."
    fi
}

cotejar_maestro "logotipo" "$SVG_MAESTRO" "$SVG_PKG"
cotejar_maestro "Centro de aplicaciones" "$TIENDA_MAESTRO" "$TIENDA_PKG"

# EL '<svg' TIENE QUE CAER DENTRO DE LOS PRIMEROS 256 BYTES, y no es una manía
# de estilo: gdk-pixbuf reconoce el formato husmeando el principio del fichero,
# y más allá de ese byte contesta «Couldn't recognize the image file format».
# Medido el 2026-08-15 con su umbral exacto -256 carga, 257 no- y en las dos
# direcciones (§4.49). Lo caro es que NO se nota: librsvg dibuja el fichero, GTK
# resuelve el nombre, y lo único que pasa es que GNOME Shell deja un HUECO en el
# dock. Por eso los comentarios de estos SVG van DENTRO de <svg>.
#
# Esto se comprueba aquí y no en el Mac con gdk-pixbuf porque en el Mac no hay
# gdk-pixbuf: lo que se mide es la causa -la posición-, no el síntoma.
paso "El '<svg' dentro de los primeros 256 bytes (si no, GNOME Shell no lo pinta)"
LIMITE=256
for svg in "$SVG_MAESTRO" "$TIENDA_MAESTRO" "$DISENO/iconos/view-app-grid-symbolic.svg"; do
    [[ -f "$svg" ]] || continue
    off=$(LC_ALL=C awk 'BEGIN{RS="\x04"} {print index($0,"<svg")-1; exit}' "$svg")
    if [[ "$off" -ge 0 && "$off" -le "$LIMITE" ]]; then
        ok "$(basename "$svg"): '<svg' en el byte $off"
    else
        fallo "$(basename "$svg"): '<svg' en el byte $off, y el límite es $LIMITE" \
"gdk-pixbuf no reconocera el fichero y GNOME Shell dejara un hueco donde va el
icono. librsvg SI lo dibuja, asi que rsvg-convert no lo caza y GTK resuelve el
nombre igual: el sintoma solo se ve mirando la pantalla.
Mueve el comentario de cabecera DENTRO de <svg>, como en los otros dos."
    fi
done

# --------------------------------------------------------- paleta y copias --
# Un hex escrito en dos sitios es un hex que algún día dirá dos cosas. Esto
# comprueba que las copias siguen cuadrando con paleta.tsv.
paso "Los colores, contra paleta.tsv"

ACENTO="$(color acento)"
ARCILLA="$(color arcilla)"
PROFUNDO="$(color acento-profundo)"
GSCHEMA="$PKG/src/usr/share/glib-2.0/schemas/99-encina-branding.gschema.override"

comprobar_salida "el acento $ACENTO está en el logotipo" "$ACENTO" \
    grep -io "$ACENTO" "$SVG_MAESTRO"
comprobar_salida "la arcilla $ARCILLA está en el logotipo" "$ARCILLA" \
    grep -io "$ARCILLA" "$SVG_MAESTRO"
comprobar_salida "el verde profundo $PROFUNDO está en el gschema.override" "$PROFUNDO" \
    grep -io "$PROFUNDO" "$GSCHEMA"

# El icono del Centro de aplicaciones usa TRES papeles, y los tres están en
# VIGENTE: la placa va de acento a acento-profundo y el cuerpo es arcilla.
# Ninguno de los ocho colores en PROPUESTO interviene: son de mensajes de
# estado, y un icono no los usa.
comprobar_salida "el acento $ACENTO está en el icono del Centro de aplicaciones" "$ACENTO" \
    grep -io "$ACENTO" "$TIENDA_MAESTRO"
comprobar_salida "el verde profundo $PROFUNDO está en el icono del Centro de aplicaciones" "$PROFUNDO" \
    grep -io "$PROFUNDO" "$TIENDA_MAESTRO"
comprobar_salida "la arcilla $ARCILLA está en el icono del Centro de aplicaciones" "$ARCILLA" \
    grep -io "$ARCILLA" "$TIENDA_MAESTRO"

# ----------------------------------------------------------------- fondos ---
paso "Fondos, contra design/fondos/manifiesto.tsv"

FILAS=0
while IFS=$'\t' read -r maestro derivado licencia origen sha_m sha_d orden; do
    [[ -z "${maestro:-}" || "$maestro" == \#* || "$maestro" == "maestro" ]] && continue
    FILAS=$((FILAS + 1))

    D="$FONDOS_PKG/$derivado"
    if [[ ! -f "$D" ]]; then
        fallo "$derivado: no está en el paquete" "esperado en $FONDOS_PKG"
        continue
    fi
    h="$(huella "$D")"
    if [[ "$h" == "$sha_d" ]]; then
        ok "$derivado cuadra con el manifiesto"
    else
        fallo "$derivado NO cuadra con el manifiesto" \
"manifiesto: $sha_d
en disco:   $h"
    fi

    M="$DISENO/fondos/maestros/$maestro"
    if [[ ! -f "$M" ]]; then
        omitido "$maestro: el maestro no está aquí (no viaja en el clon)"
    else
        hm="$(huella "$M")"
        if [[ "$hm" == "$sha_m" ]]; then
            ok "$maestro cuadra con el manifiesto"
        else
            fallo "$maestro NO cuadra con el manifiesto" \
"manifiesto: $sha_m
en disco:   $hm"
        fi
    fi

    [[ "$orden" == "-" ]] && aviso "$derivado: sin orden -> se comprueba, no se rehace"
done < "$MANIFIESTO"

if (( FILAS == 0 )); then
    fallo "el manifiesto no tiene ni una fila" "$MANIFIESTO"
else
    ok "$FILAS filas leídas del manifiesto"
fi

# ------------------------------------------------------------- logo.png ----
# No sale de un maestro fotográfico: sale del SVG. Por eso va aparte.
paso "logo.png (GDM y Plymouth)"

LOGO="$FONDOS_PKG/logo.png"
if (( ESCRIBIR == 1 )) && command -v rsvg-convert >/dev/null 2>&1; then
    rsvg-convert -w 200 -h 200 "$SVG_MAESTRO" -o "$LOGO"
    ok "logo.png regenerado desde el maestro (200x200)"
elif (( ESCRIBIR == 1 )); then
    omitido "logo.png: falta rsvg-convert"
fi

comprobar_fichero "logo.png existe" "$LOGO"
if [[ -f "$LOGO" ]]; then
    comprobar_salida "logo.png es un PNG" "PNG image data" file -b "$LOGO"
    # Sin canal alfa sale con un recuadro opaco encima del splash de arranque.
    if file -b "$LOGO" | grep -q "RGBA"; then
        ok "logo.png tiene transparencia (RGBA)"
    else
        fallo "logo.png NO tiene canal alfa" "$(file -b "$LOGO")"
    fi
fi

# ------------------------------------------------------------------ cierre --
paso "Lo que este guion NO ha comprobado"
echo "  - Que los fondos se puedan REHACER. Cuatro no tienen orden escrita, y las"
echo "    dos que sí la tienen este guion no las ejecuta: comprueba huellas."
echo "  - La licencia. Ya no hay ningún SIN DETERMINAR, pero este guion NO cuadra"
echo "    el manifiesto contra debian/copyright, que es quien manda desde el"
echo "    2026-08-15. Si se separan otra vez, aquí no se vería."
echo "  - Nada de lo que se ve en pantalla. Eso son las capturas."

resumen
