#!/usr/bin/env bash
# 06-ci.sh — Escribe el flujo de GitHub Actions, crea el repositorio remoto
# (privado) y sube el código.
#
# Uso:  ./scripts/06-ci.sh [nombre-del-repo]
#
# Privado a propósito: publicar activa la obligación de mantener parches de
# seguridad para desconocidos (D5). Ya lo abrirás cuando quieras.
#
# OJO: el heredoc de abajo es una SEGUNDA COPIA de .github/workflows/build.yml,
# y este guion la sobrescribe sin preguntar. Ya mordió: el flujo del repositorio
# llevaba encina-meta en la matriz y el heredoc no, así que ejecutar esto habría
# quitado un paquete de la CI en silencio. Se sincronizó el 2026-08-13 copiando
# el fichero dentro, no transcribiéndolo a mano, y comprobando después que las
# dos copias no difieren en ningún byte. Si tocas una, toca la otra.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
# MODELO DE SALIDA: CONTAR Y SEGUIR (tarea 2, MEDICIONES.md §4.67). fallo()
# apunta, incrementa N_MAL y SIGUE midiendo; morir() aborta; quien fija el
# código de salida es resumen(). El 'set' lo pone lib.sh:5 al hacer source: se
# REAFIRMA aquí para que las opciones de shell de este guion no dependan de a
# quién llame. Reafirmarlo no cambia ni una opción — control en §4.67.
set -euo pipefail
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
  # LOS BANCOS QUE NO NECESITAN MAQUINA NI ISO, en cada push (tarea 6 de
  # tareas/refactorizacion.md, 2026-08-28). Hasta ese dia habia cinco bancos con
  # cinco puntos de entrada y la CI no corria ninguno: solo corrian si alguien
  # se acordaba. 'make bancos' es UNA orden, para en el primero que falle y sale
  # distinto de cero, y es la misma orden que en el Mac. El sabotaje de siempre
  # esta pagado en local (un banco roto a proposito pone esto en rojo por ese
  # motivo, MEDICIONES.md §4.80) y no aqui: romper la CI a proposito exige un
  # push, y eso es de Jorge.
  bancos:
    name: bancos · enlaces, vigencia, ci-copias, versiones, cadena, veredicto, conteo, shellcheck
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@v4
      - name: Instalar lo que necesitan los bancos
        run: |
          sudo apt-get update
          # ffmpeg: banco-veredicto.sh mide los pixeles de sus capturas de control.
          # shellcheck: bancos/shellcheck.sh usa el binario si lo hay (en el Mac
          # no lo hay y va por docker).
          sudo apt-get install -y ffmpeg shellcheck
      - name: make bancos
        run: make bancos

  build:
    name: ${{ matrix.arch }} · ${{ matrix.package }}
    # Las dos arquitecturas, y no por simetria (2026-08-23, MEDICIONES.md
    # §4.69): arm64 es el producto que D9 declara y hasta hoy era la UNICA que
    # no construia ninguna maquina automatica. Los tres .deb son
    # 'Architecture: all', asi que las dos filas tienen que dar el MISMO byte
    # y cuadrar con la misma huella del manifiesto; si un dia no lo hacen,
    # eso es un hallazgo de reproducibilidad y no un fallo de la matriz.
    # 'ubuntu-24.04' en vez de 'ubuntu-latest' porque es lo que 'latest'
    # resolvia ya (imagen ubuntu-24.04, medido en la ejecucion 32635412798)
    # y porque la fila arm64 no tiene alias: las dos van con el nombre puesto.
    runs-on: ${{ matrix.runner }}
    strategy:
      fail-fast: false
      # Cada paquete tiene su propio script de construccion, asi que la matriz
      # lleva las dos cosas emparejadas. Antes solo listaba el nombre y no lo
      # usaba en ningun sitio: el paso ejecutaba siempre 03-construir.sh y
      # subia debian-packages/*.deb, de modo que anadir una entrada mas habria
      # construido encina-branding dos veces sin que se notara.
      #
      # La forma es la de «expanding configurations» de GitHub: 'arch' y
      # 'package' son los ejes (2 x 3 = 6 trabajos), y cada 'include' ANADE
      # una clave a las combinaciones cuyo eje coincide -el runner a las de su
      # arch, el guion a las de su package- sin crear combinaciones nuevas.
      matrix:
        arch: [amd64, arm64]
        package: [encina-branding, encina-firefox-native, encina-meta]
        include:
          - arch: amd64
            runner: ubuntu-24.04
          - arch: arm64
            runner: ubuntu-24.04-arm
          - package: encina-branding
            script: scripts/03-construir.sh
          - package: encina-firefox-native
            script: scripts/07-firefox-construir.sh
          # encina-meta entra en la matriz en el MISMO commit que su
          # debian/changelog, y no antes: 10-meta-construir.sh se detiene sin
          # construir nada si no lo encuentra, asi que una entrada de matriz sin
          # changelog pondria la CI roja a sabiendas.
          - package: encina-meta
            script: scripts/10-meta-construir.sh

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

      # EL CONTROL VA ANTES QUE LA MEDICION, que es el orden que sirve: primero
      # se calibra el instrumento y despues se mide con el. Si el paso de abajo
      # dijera [OK] sin comprobar nada, este lo caza aqui y no dentro de tres
      # meses.
      - name: CONTROL — con la huella saboteada tiene que ponerse en rojo
        run: |
          set -u
          M=$(mktemp); LOG=$(mktemp)
          awk -F'\t' -v OFS='\t' -v p='${{ matrix.package }}' \
              '$1=="PROPIO" && $2==p { c=substr($6,1,1); $6=(c=="0"?"1":"0") substr($6,2) } 1' \
              imagen/repo-manifiesto.tsv > "$M"
          # El sabotaje tiene que sabotear. En §4.37c un 'sed 1s/^./f/' no
          # cambio nada porque la linea ya empezaba por 'f': un sabotaje que no
          # sabotea deja el control en decoracion.
          if cmp -s imagen/repo-manifiesto.tsv "$M"; then
            echo "[FALLO] el manifiesto saboteado es identico al original"; exit 1
          fi
          if ./imagen/comprobar-propios.sh '${{ matrix.package }}' --manifiesto "$M" >"$LOG" 2>&1; then
            echo "[FALLO] dice que cuadra con una huella falsa: no comprueba nada"
            cat "$LOG"; exit 1
          fi
          # Y que falle POR EL MOTIVO CORRECTO, no por un error de sintaxis: es
          # la trampa del control negativo que no es negativo (§9).
          grep -q '^\[HALLAZGO\]' "$LOG" \
            || { echo "[FALLO] fallo, pero no por la huella"; cat "$LOG"; exit 1; }
          echo "[OK]    sabe decir que no:  $(grep -m1 '^\[HALLAZGO\]' "$LOG")"

      # Y AHORA LA MEDICION DE VERDAD. Las huellas del manifiesto se midieron en
      # encina-dev, que es arm64; hasta el 2026-08-23 este runner era solo
      # amd64, y desde entonces la matriz lo mide en las dos. Que el paso anterior
      # subiera el .deb a un artefacto sin mirarlo no comprobaba nada: un
      # artefacto se sube igual de bien con otros bytes dentro.
      - name: Comprobar la huella de ${{ matrix.package }} contra el manifiesto
        run: ./imagen/comprobar-propios.sh '${{ matrix.package }}'

      # always(): si la huella NO cuadra, el .deb del runner es justamente lo
      # que hay que desglosar contra el de arm64, asi que es cuando mas falta
      # hace tenerlo. El nombre lleva la arquitectura porque upload-artifact@v4
      # se niega a subir dos artefactos con el mismo nombre en una ejecucion:
      # con la matriz de dos filas, '<package>-deb' a secas habria puesto en
      # rojo a la segunda fila en llegar, fuera cual fuera.
      - name: Subir el paquete como artefacto
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: ${{ matrix.package }}-${{ matrix.arch }}-deb
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
