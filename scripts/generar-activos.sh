#!/usr/bin/env bash
# generar-activos.sh — Genera los activos gráficos mínimos y verifica su formato.
#
# Uso:  ./scripts/generar-activos.sh [--forzar]
#
# Por defecto NO sobrescribe activos que ya existan: el día que pongas el
# logotipo de verdad, no quieres que un script lo machaque. Usa --forzar
# para regenerarlos a propósito.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
# MODELO DE SALIDA: CONTAR Y SEGUIR (tarea 2, MEDICIONES.md §4.67). fallo()
# apunta, incrementa N_MAL y SIGUE midiendo; morir() aborta; quien fija el
# código de salida es resumen(). El 'set' lo pone lib.sh:5 al hacer source: se
# REAFIRMA aquí para que las opciones de shell de este guion no dependan de a
# quién llame. Reafirmarlo no cambia ni una opción — control en §4.67.
set -euo pipefail
requiere_no_root
requiere_cmd rsvg-convert file

FORZAR=0
[[ "${1:-}" == "--forzar" ]] && FORZAR=1

PKG="$(PKG_DIR)"
FONDOS="$PKG/src/usr/share/backgrounds/encina"
SVG="$PKG/src/usr/share/icons/hicolor/scalable/apps/encina-logo.svg"

# ImageMagick 7 usa 'magick'; el 6 usa 'convert'.
if command -v magick >/dev/null 2>&1; then IM=(magick)
elif command -v convert >/dev/null 2>&1; then IM=(convert)
else echo "Falta ImageMagick. Ejecuta ./scripts/preparar-entorno.sh"; exit 1; fi

titulo "Activos gráficos"

[[ -d "$PKG" ]] || { echo "No existe $PKG. Ejecuta antes ./scripts/colocar-esqueleto.sh"; exit 1; }
mkdir -p "$FONDOS"

generar() {   # generar <ruta> <descripción> <comando...>
    local destino="$1" desc="$2"; shift 2
    if [[ -f "$destino" && $FORZAR -eq 0 ]]; then
        omitido "$desc — ya existe (usa --forzar para regenerarlo)"
        return 0
    fi
    local salida
    if salida=$("$@" 2>&1); then
        ok "$desc generado"
    else
        fallo "$desc" "$salida"
    fi
}

paso "Generando"
generar "$FONDOS/encina.jpg" "Fondo claro (3840x2160)" \
    "${IM[@]}" -size 3840x2160 "gradient:#5B7553-#2F4033" -quality 92 "$FONDOS/encina.jpg"

generar "$FONDOS/encina-dark.jpg" "Fondo oscuro (3840x2160)" \
    "${IM[@]}" -size 3840x2160 "gradient:#1E2A22-#0D120F" -quality 92 "$FONDOS/encina-dark.jpg"

generar "$FONDOS/logo.png" "Logotipo PNG para Plymouth (200x200)" \
    rsvg-convert -w 200 -h 200 "$SVG" -o "$FONDOS/logo.png"

# ------------------------------------------------------------ verificación --
titulo "Verificación de formatos"

comprobar_salida "encina.jpg es un JPEG de verdad" "JPEG image data" \
    file -b "$FONDOS/encina.jpg"
comprobar_salida "encina-dark.jpg es un JPEG de verdad" "JPEG image data" \
    file -b "$FONDOS/encina-dark.jpg"
comprobar_salida "logo.png es un PNG" "PNG image data" \
    file -b "$FONDOS/logo.png"

# La comprobación que importa: sin canal alfa, el logotipo sale con un
# recuadro opaco encima del splash de arranque.
if file -b "$FONDOS/logo.png" | grep -q "RGBA"; then
    ok "logo.png tiene transparencia (RGBA)"
else
    fallo "logo.png NO tiene canal alfa" \
"$(file -b "$FONDOS/logo.png")
Sin transparencia el logotipo aparecerá con un cuadrado de fondo sobre el
splash. Regenéralo con:  ./scripts/generar-activos.sh --forzar"
fi

# Los fondos oscuro y claro deben ser distintos: es fácil copiar el mismo dos
# veces sin darse cuenta.
if [[ -f "$FONDOS/encina.jpg" && -f "$FONDOS/encina-dark.jpg" ]]; then
    if [[ "$(md5sum < "$FONDOS/encina.jpg")" == "$(md5sum < "$FONDOS/encina-dark.jpg")" ]]; then
        fallo "El fondo claro y el oscuro son el mismo fichero" "md5sum idéntico"
    else
        ok "El fondo claro y el oscuro son distintos"
    fi
fi

paso "Tamaños"
ls -lh "$FONDOS" | sed 's/^/  /'

titulo "Commit"
cd "$(raiz_repo)"
if [[ -n "$(git status --porcelain)" ]]; then
    if git add -A && git commit -q -m "Activos mínimos de branding"; then
        ok "Commit creado: $(git log -1 --oneline)"
    else
        fallo "No se ha podido crear el commit" "revisa la salida de git"
    fi
else
    ok "Sin cambios que committear"
fi

resumen
echo
echo "Siguiente:  ./scripts/construir-branding.sh"
