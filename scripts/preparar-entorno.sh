#!/usr/bin/env bash
# preparar-entorno.sh — Prepara la VM: herramientas de empaquetado e identidad.
# Idempotente: puedes ejecutarlo tantas veces como quieras.
#
# Uso:  ./scripts/preparar-entorno.sh "Tu Nombre" "tu@correo.real"

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
# MODELO DE SALIDA: CONTAR Y SEGUIR (tarea 2, MEDICIONES.md §4.67). fallo()
# apunta, incrementa N_MAL y SIGUE midiendo; morir() aborta; quien fija el
# código de salida es resumen(). El 'set' lo pone lib.sh:5 al hacer source: se
# REAFIRMA aquí para que las opciones de shell de este guion no dependan de a
# quién llame. Reafirmarlo no cambia ni una opción — control en §4.67.
set -euo pipefail
requiere_no_root

NOMBRE="${1:-}"
CORREO="${2:-}"

titulo "Entorno de construcción"

# ------------------------------------------------------------ 1. paquetes ---
PAQUETES=(git devscripts debhelper lintian dpkg-dev imagemagick librsvg2-bin file)

paso "Instalando herramientas (${PAQUETES[*]})"
FALTAN=()
for p in "${PAQUETES[@]}"; do
    dpkg-query -W -f='${Status}' "$p" 2>/dev/null | grep -q "install ok installed" || FALTAN+=("$p")
done

if (( ${#FALTAN[@]} == 0 )); then
    ok "Todas las herramientas ya estaban instaladas"
else
    echo "  Faltan: ${FALTAN[*]}  (hace falta sudo)"
    if sudo apt-get update -qq && sudo apt-get install -y "${FALTAN[@]}"; then
        ok "Herramientas instaladas"
    else
        fallo "No se pudieron instalar las herramientas" "revisa la salida de apt arriba"
    fi
fi

# ------------------------------------------------------------ 2. identidad --
paso "Identidad de git y de empaquetado"

if [[ -z "$NOMBRE" || -z "$CORREO" ]]; then
    NOMBRE_ACT=$(git config --global user.name  2>/dev/null || true)
    CORREO_ACT=$(git config --global user.email 2>/dev/null || true)
    if [[ -n "$NOMBRE_ACT" && -n "$CORREO_ACT" ]]; then
        NOMBRE="$NOMBRE_ACT"; CORREO="$CORREO_ACT"
        ok "Identidad ya configurada: $NOMBRE <$CORREO>"
    else
        echo
        echo "Uso: ./scripts/preparar-entorno.sh \"Tu Nombre\" \"tu@correo.real\""
        echo
        echo "El correo acaba dentro del paquete, en el campo Maintainer."
        echo "Usa uno real: lintian da error si detecta una dirección inventada."
        exit 1
    fi
else
    git config --global user.name  "$NOMBRE"
    git config --global user.email "$CORREO"
    ok "git configurado: $NOMBRE <$CORREO>"
fi

# DEBFULLNAME / DEBEMAIL los usa dch y dpkg-buildpackage.
PERFIL="$HOME/.bashrc"
for var in "DEBFULLNAME=$NOMBRE" "DEBEMAIL=$CORREO"; do
    clave="${var%%=*}"
    if grep -q "^export $clave=" "$PERFIL" 2>/dev/null; then
        sed -i "s|^export $clave=.*|export $clave=\"${var#*=}\"|" "$PERFIL"
    else
        echo "export $clave=\"${var#*=}\"" >> "$PERFIL"
    fi
done
export DEBFULLNAME="$NOMBRE" DEBEMAIL="$CORREO"
ok "DEBFULLNAME y DEBEMAIL escritos en ~/.bashrc"

# ------------------------------------------------------------ 3. verificar --
titulo "Verificación"
comprobar "dpkg-buildpackage disponible" command -v dpkg-buildpackage
comprobar "lintian disponible"           command -v lintian
comprobar "rsvg-convert disponible"      command -v rsvg-convert
comprobar "git disponible"               command -v git

if command -v magick >/dev/null 2>&1 || command -v convert >/dev/null 2>&1; then
    ok "ImageMagick disponible"
else
    fallo "ImageMagick no disponible" "ni 'magick' ni 'convert' están en el PATH"
fi

VER=$(lsb_release -rs 2>/dev/null || echo "?")
echo
echo "  Ubuntu detectado: $VER   (arquitectura: $(dpkg --print-architecture))"

resumen
echo
echo "Siguiente:  ./scripts/colocar-esqueleto.sh /ruta/a/encina-branding.tar.gz"
