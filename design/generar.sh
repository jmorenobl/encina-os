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
# manifiesto está a '-' en las seis filas. Mientras siga así, los fondos se
# COMPRUEBAN pero no se rehacen, que es media reproducibilidad.

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

comprobar_fichero "el maestro existe: design/logotipo/encina.svg" "$SVG_MAESTRO"
comprobar_fichero "el derivado existe en el paquete" "$SVG_PKG"

if [[ -f "$SVG_MAESTRO" && -f "$SVG_PKG" ]]; then
    if cmp -s "$SVG_MAESTRO" "$SVG_PKG"; then
        ok "el SVG del paquete es idéntico al maestro"
    elif (( ESCRIBIR == 1 )); then
        cp "$SVG_MAESTRO" "$SVG_PKG"
        ok "SVG copiado al paquete desde el maestro"
    else
        fallo "el SVG del paquete NO es el maestro" \
"maestro:  $(huella "$SVG_MAESTRO")
paquete:  $(huella "$SVG_PKG")
Si el bueno es el maestro:  ./design/generar.sh --escribir
Si el bueno es el del paquete, cópialo tú a design/ y averigua quién lo tocó."
    fi
fi

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
echo "  - Que los fondos se puedan REHACER: la orden no se sabe (columna 'orden')."
echo "  - La licencia de las seis fotografías: SIN DETERMINAR en el manifiesto,"
echo "    y es casilla de bloqueo para publicar."
echo "  - Nada de lo que se ve en pantalla. Eso son las capturas."

resumen
