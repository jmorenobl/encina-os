#!/usr/bin/env bash
# colocar-esqueleto.sh — Coloca el esqueleto de encina-branding dentro del repositorio
# y verifica que el árbol de ficheros es el que exige AGENTS.md §4.1.
#
# ~~«Crea ~/encina»~~ — lo decía hasta el 2026-08-23 y era verdad: raiz_repo()
# se inventaba esa ruta y este guion la creaba con mkdir -p. Ahora la raíz es
# el árbol donde vive lib.sh, o ENCINA_REPO si la pones (§4.67).
#
# Uso:  ./scripts/colocar-esqueleto.sh [ruta/a/encina-branding.tar.gz]
#
# Si no le pasas la ruta, busca el tar.gz en ~ y en ~/Downloads.
# Idempotente: si el repositorio ya existe, no lo destruye.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
# MODELO DE SALIDA: CONTAR Y SEGUIR (tarea 2, MEDICIONES.md §4.67). fallo()
# apunta, incrementa N_MAL y SIGUE midiendo; morir() aborta; quien fija el
# código de salida es resumen(). El 'set' lo pone lib.sh:5 al hacer source: se
# REAFIRMA aquí para que las opciones de shell de este guion no dependan de a
# quién llame. Reafirmarlo no cambia ni una opción — control en §4.67.
set -euo pipefail
requiere_no_root
requiere_cmd git

ORIGEN_SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(raiz_repo)"
PKG="$REPO/debian-packages/encina-branding"

titulo "Repositorio Encina"

# Sin identidad de git, este script moriría al final con un error críptico.
if [[ -z "$(git config --global user.email 2>/dev/null || true)" ]]; then
    echo
    echo "${C_MAL}git no tiene configurada tu identidad.${C_FIN}"
    echo "Ejecuta primero:"
    echo "    ./scripts/preparar-entorno.sh \"Tu Nombre\" \"tu@correo.real\""
    exit 1
fi

# --------------------------------------------------------- 1. estructura ----
paso "Estructura de directorios"
mkdir -p "$REPO/debian-packages" "$REPO/.github/workflows" "$REPO/scripts"
ok "Directorios creados o ya existentes en $REPO"

if [[ -d "$REPO/.git" ]]; then
    ok "El repositorio git ya estaba inicializado"
else
    git -C "$REPO" init -q
    ok "git init"
fi

# --------------------------------------------------- 2. copiar los scripts --
paso "Scripts dentro del repositorio"
if [[ "$ORIGEN_SCRIPTS" != "$REPO/scripts" ]]; then
    cp -a "$ORIGEN_SCRIPTS"/*.sh "$REPO/scripts/"
    chmod +x "$REPO/scripts"/*.sh
    ok "Scripts copiados a $REPO/scripts (a partir de ahora ejecútalos desde ahí)"
else
    ok "Ya los estás ejecutando desde el repositorio"
fi

# ------------------------------------------------------- 3. el esqueleto ----
paso "Esqueleto de encina-branding"

if [[ -d "$PKG/debian" ]]; then
    ok "El esqueleto ya está en su sitio (no se toca)"
else
    TAR="${1:-}"
    if [[ -z "$TAR" ]]; then
        for cand in "$HOME/encina-branding.tar.gz" "$HOME/Downloads/encina-branding.tar.gz"; do
            [[ -f "$cand" ]] && { TAR="$cand"; break; }
        done
    fi

    if [[ -z "$TAR" || ! -f "$TAR" ]]; then
        fallo "No encuentro encina-branding.tar.gz" \
"Pásale la ruta:  ./scripts/colocar-esqueleto.sh /ruta/al/encina-branding.tar.gz
Desde el Mac lo copias con:
    scp ~/Downloads/encina-branding.tar.gz USUARIO@IP_DE_LA_VM:~/"
        resumen; exit 1
    fi

    tar xzf "$TAR" -C "$REPO/debian-packages"
    ok "Esqueleto desempaquetado desde $TAR"
fi

# ------------------------------------------------------- 4. .gitignore ------
paso "Ficheros del repositorio"
cat > "$REPO/.gitignore" << 'EOF'
# Artefactos de construcción. El código y los activos SÍ se versionan.
debian-packages/*.deb
debian-packages/*.buildinfo
debian-packages/*.changes
debian-packages/*/debian/encina-*/
debian-packages/*/debian/files
debian-packages/*/debian/*.substvars
debian-packages/*/debian/*.debhelper
debian-packages/*/debian/debhelper-build-stamp

# Ajustes locales de la herramienta, propios de cada maquina.
.claude/settings.local.json
EOF
ok ".gitignore escrito"

if [[ ! -f "$REPO/LICENSE" ]]; then
    cat > "$REPO/LICENSE" << 'EOF'
EUPL-1.2

PENDIENTE: sustituir este fichero por el texto oficial de la European Union
Public Licence v1.2, disponible en joinup.ec.europa.eu.

No bloquea la construcción del paquete. Hazlo cuando tengas cinco minutos.
EOF
    aviso "LICENSE creado como marcador de posición (falta el texto oficial de la EUPL-1.2)"
else
    ok "LICENSE ya existe"
fi

# ------------------------------------------- 5. verificar el árbol (§4.1) ---
titulo "Verificación del árbol de ficheros"

# Ficheros que DEBEN venir en el esqueleto.
OBLIGATORIOS=(
    "debian/control"
    "debian/changelog"
    "debian/copyright"
    "debian/rules"
    "debian/postinst"
    "debian/prerm"
    "debian/postrm"
    "src/usr/share/gnome-background-properties/encina.xml"
    "src/usr/share/glib-2.0/schemas/99-encina-branding.gschema.override"
    "src/usr/share/icons/hicolor/scalable/apps/encina-logo.svg"
    "src/usr/share/plymouth/themes/encina/encina.plymouth"
    "src/usr/share/plymouth/themes/encina/encina.script"
    "src/etc/dconf/db/gdm.d/99-encina"
)

# Estos los genera generar-activos.sh; aquí solo se informa.
GENERADOS=(
    "src/usr/share/backgrounds/encina/encina.jpg"
    "src/usr/share/backgrounds/encina/encina-dark.jpg"
    "src/usr/share/backgrounds/encina/logo.png"
)

for f in "${OBLIGATORIOS[@]}"; do
    comprobar_fichero "$f" "$PKG/$f"
done

for f in "${GENERADOS[@]}"; do
    if [[ -f "$PKG/$f" ]]; then ok "$f (ya generado)"
    else omitido "$f — lo genera generar-activos.sh"; fi
done

# ------------------------------------------------------------ 6. commit -----
titulo "Commit"
cd "$REPO"
if [[ -n "$(git status --porcelain)" ]]; then
    if git add -A && git commit -q -m "Esqueleto de encina-branding y scripts de construcción"; then
        ok "Commit creado: $(git log -1 --oneline)"
    else
        fallo "No se ha podido crear el commit" "revisa la salida de git"
    fi
else
    ok "Nada que committear, el árbol ya estaba limpio"
fi

resumen
RES=$?
echo
if (( RES == 0 )); then
    echo "Siguiente:  cd $REPO && ./scripts/generar-activos.sh"
else
    echo "Falta algún fichero del esqueleto. NO lo improvises: pregunta antes de inventarlo."
fi
exit $RES
