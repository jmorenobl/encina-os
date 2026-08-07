#!/usr/bin/env bash
# 06-ci.sh — Escribe el flujo de GitHub Actions, crea el repositorio remoto
# (privado) y sube el código.
#
# Uso:  ./scripts/06-ci.sh [nombre-del-repo]
#
# Privado a propósito: publicar activa la obligación de mantener parches de
# seguridad para desconocidos (D5). Ya lo abrirás cuando quieras.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
requiere_no_root
requiere_cmd git

REPO="$(raiz_repo)"
NOMBRE_REPO="${1:-encina}"
FLUJO="$REPO/.github/workflows/build.yml"

titulo "Integración continua"

mkdir -p "$(dirname "$FLUJO")"
cat > "$FLUJO" << 'EOF'
name: build

on:
  push:
  pull_request:
  # Disparo manual. Ademas de ser comodo para relanzar sin tocar el codigo,
  # es la unica via cuando GitHub tiene throttled los webhooks: durante la
  # incidencia de Actions del 2026-08-06 los push no creaban ejecuciones y
  # workflow_dispatch si.
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      # Cada paquete tiene su propio script de construccion, asi que la matriz
      # lleva las dos cosas emparejadas. Antes solo listaba el nombre y no lo
      # usaba en ningun sitio: el paso ejecutaba siempre 03-construir.sh y
      # subia debian-packages/*.deb, de modo que anadir una entrada mas habria
      # construido encina-branding dos veces sin que se notara.
      matrix:
        include:
          - package: encina-branding
            script: scripts/03-construir.sh
          - package: encina-firefox-native
            script: scripts/07-firefox-construir.sh

    steps:
      - uses: actions/checkout@v4

      - name: Instalar dependencias de construcción
        run: |
          sudo apt-get update
          # build-essential es dependencia de construccion implicita de todo
          # paquete Debian: sin el, dpkg-checkbuilddeps aborta con
          # "Unmet build dependencies: build-essential:native". En una VM de
          # desarrollo suele estar ya puesto porque devscripts lo recomienda,
          # asi que este fallo SOLO se manifiesta en el runner.
          #
          # gnupg lo necesita 07-firefox-construir.sh para verificar la huella
          # de la clave de firma de Mozilla.
          sudo apt-get install -y build-essential devscripts debhelper lintian gnupg

      - name: Construir y validar ${{ matrix.package }}
        run: |
          chmod +x scripts/*.sh
          ENCINA_REPO="$GITHUB_WORKSPACE" ./${{ matrix.script }}

      - name: Subir el paquete como artefacto
        uses: actions/upload-artifact@v4
        with:
          name: ${{ matrix.package }}-deb
          path: debian-packages/${{ matrix.package }}_*.deb
          if-no-files-found: error
EOF
ok "Flujo escrito en .github/workflows/build.yml"

echo
echo "  El paso de CI reutiliza 03-construir.sh, así que las reglas duras y"
echo "  lintian se comprueban igual en tu VM y en el runner. Si algo pasa en"
echo "  local y falla en CI, es una diferencia real, no una diferencia de script."
echo
echo "  El runner es amd64 y tu VM arm64: da igual, el paquete es"
echo "  Architecture: all y no contiene binarios compilados."
echo
echo "  Ninguna clave de firma vive en el runner. La firma del repositorio APT"
echo "  es de la fase A4."

# ---------------------------------------------------------------- commit ----
cd "$REPO"
if [[ -n "$(git status --porcelain)" ]]; then
    if git add -A && git commit -q -m "CI: construir y validar los paquetes de encina en cada push"; then
        ok "Commit creado: $(git log -1 --oneline)"
    else
        fallo "No se ha podido crear el commit" ""
    fi
else
    ok "Sin cambios que committear"
fi

# ---------------------------------------------------------------- remoto ----
titulo "Repositorio remoto"

if ! command -v gh >/dev/null 2>&1; then
    aviso "No está instalado 'gh'. Instálalo con: sudo apt install -y gh"
    echo "  Después:  gh auth login  &&  ./scripts/06-ci.sh"
    resumen; exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
    aviso "No has iniciado sesión en GitHub"
    echo "  Ejecuta:  gh auth login    y vuelve a lanzar este script"
    resumen; exit 1
fi

if git remote get-url origin >/dev/null 2>&1; then
    ok "Ya existe el remoto origin: $(git remote get-url origin)"
    if git push -u origin HEAD 2>&1 | tail -3 | sed 's/^/    /'; then
        ok "Cambios subidos"
    fi
else
    if salida=$(gh repo create "$NOMBRE_REPO" --private --source=. --remote=origin --push 2>&1); then
        ok "Repositorio privado '$NOMBRE_REPO' creado y subido"
    else
        fallo "No se ha podido crear el repositorio" "$salida"
    fi
fi

resumen
RES=$?
echo
echo "Mira cómo va la construcción:"
echo "    gh run watch"
echo
(( RES == 0 )) && echo "Si sale verde, A1 está terminado. Entonces, y solo entonces, A2."
exit $RES
