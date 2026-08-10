#!/bin/bash
# Encina OS - E2. Fabrica el volumen CIDATA del seed, EN MACOS.
#
# Que produce: una imagen CRUDA con etiqueta CIDATA que lleva dentro
#
#     user-data          <- imagen/autoinstall.yaml
#     meta-data          <- imagen/meta-data
#     encina-repo/       <- los cuatro .deb y el indice Packages
#
# Por que cruda y no un .dmg: 'hdiutil create' produce un UDIF y QEMU no lo lee
# (SCRIPTS.md, «El laboratorio de E2»).
#
# Por que el indice viaja hecho: 'dpkg-scanpackages' es de dpkg-dev, y en E2 de
# verdad el indice se genera en la construccion, no en la maquina (§4.15). Aqui
# se comprueba que el que viaja describe los .deb que viajan, por huella.
#
# Este script NO inventa huellas: las saca de imagen/encina-seed.sh, que es la
# unica autoridad, para que las dos no puedan separarse.

set -u

AQUI=$(cd "$(dirname "$0")" && pwd)
GUION="$AQUI/encina-seed.sh"
YAML="$AQUI/autoinstall.yaml"
METADATA="$AQUI/meta-data"

REPO=""
SALIDA=""
ACTUALIZAR=0
TAM_MB=128

uso() {
    cat <<'FIN'
uso: fabricar-seed.sh --repo DIR --salida IMG [--actualizar-yaml]

  --repo DIR          directorio con los cuatro .deb y el fichero Packages
  --salida IMG        imagen CIDATA a escribir (se sobrescribe)
  --actualizar-yaml   reescribe la late-command de autoinstall.yaml a partir
                      de encina-seed.sh, en vez de solo comprobar que coinciden
FIN
}

while [ $# -gt 0 ]; do
    case "$1" in
        --repo)             REPO="$2"; shift 2 ;;
        --salida)           SALIDA="$2"; shift 2 ;;
        --actualizar-yaml)  ACTUALIZAR=1; shift ;;
        -h|--help)          uso; exit 0 ;;
        *) echo "[FALLO] argumento desconocido: $1"; uso; exit 2 ;;
    esac
done

[ -n "$REPO" ] && [ -n "$SALIDA" ] || { uso; exit 2; }

fallo() { echo "[FALLO] $*"; exit 1; }
ok()    { echo "[OK]    $*"; }

# --- 1. las huellas, sacadas del guion que las va a comprobar dentro ---------
huella_de() {  # $1 = nombre de la variable en encina-seed.sh
    grep -E "^$1=" "$GUION" | head -1 | cut -d= -f2
}
declare -a FICHEROS HUELLAS
FICHEROS=(autofirma_1.9.1+encina2_all.deb
          encina-branding_0.1.7_all.deb
          encina-firefox-native_0.2.1_all.deb
          encina-meta_0.1.1_all.deb)
HUELLAS=("$(huella_de H_AUTOFIRMA)"
         "$(huella_de H_BRANDING)"
         "$(huella_de H_FFNATIVE)"
         "$(huella_de H_META)")

echo "== 1. los cuatro .deb, comparados POR HUELLA (§4.13: misma version != mismos bytes)"
for i in 0 1 2 3; do
    f="$REPO/${FICHEROS[$i]}"
    [ -f "$f" ] || fallo "no esta: $f"
    real=$(shasum -a 256 "$f" | cut -d' ' -f1)
    [ "$real" = "${HUELLAS[$i]}" ] || fallo "huella distinta en ${FICHEROS[$i]}
        esperada ${HUELLAS[$i]}
        real     $real"
    ok "${FICHEROS[$i]}  ${real:0:8}…"
done

echo "== 2. el indice Packages describe esos mismos bytes"
[ -f "$REPO/Packages" ] || fallo "no esta: $REPO/Packages"
for i in 0 1 2 3; do
    grep -q "^SHA256: ${HUELLAS[$i]}$" "$REPO/Packages" \
        || fallo "Packages no contiene la huella de ${FICHEROS[$i]}"
done
ok "las cuatro huellas de §4.15 estan en Packages"
# control: el indice no puede describir algo que no viaja
if grep -qE '^Filename: \./(autofirma|encina-)' "$REPO/Packages"; then
    n=$(grep -cE '^Filename: \./' "$REPO/Packages")
    [ "$n" -eq 4 ] || fallo "Packages describe $n ficheros y viajan 4"
    ok "Packages describe 4 ficheros, ni uno mas (el control)"
else
    fallo "Packages no tiene rutas relativas ./ — el repo no se leeria"
fi

echo "== 3. la late-command de autoinstall.yaml == encina-seed.sh"
B64=$(base64 -i "$GUION" | tr -d '\n')
LINEA="    - sh -c 'echo $B64 | base64 -d > /tmp/encina-seed.sh; sh /tmp/encina-seed.sh; true'"
if [ "$ACTUALIZAR" = 1 ]; then
    LINEA="$LINEA" python3 - "$YAML" <<'PY'
import os, sys
ruta = sys.argv[1]
linea = os.environ["LINEA"]
salida = []
for l in open(ruta, encoding="utf-8"):
    salida.append(linea + "\n" if l.startswith("    - sh -c 'echo ") else l)
open(ruta, "w", encoding="utf-8").write("".join(salida))
PY
    ok "autoinstall.yaml actualizado desde encina-seed.sh"
fi
grep -qxF "$LINEA" "$YAML" \
    || fallo "autoinstall.yaml y encina-seed.sh se han separado.
        Vuelve a lanzar esto con --actualizar-yaml"
ok "coinciden ($(wc -c <"$GUION" | tr -d ' ') bytes de guion, ${#B64} de base64)"

echo "== 4. el volumen CIDATA"
rm -f "$SALIDA"
dd if=/dev/zero of="$SALIDA" bs=1m count="$TAM_MB" 2>/dev/null || fallo "dd"
DEV=$(hdiutil attach -imagekey diskimage-class=CRawDiskImage -nomount "$SALIDA" | awk '{print $1}')
[ -n "$DEV" ] || fallo "hdiutil attach -nomount"
newfs_msdos -F 16 -v CIDATA "$DEV" >/dev/null 2>&1 || { hdiutil detach "$DEV" >/dev/null; fallo "newfs_msdos"; }
hdiutil detach "$DEV" >/dev/null || fallo "detach"

DEV=$(hdiutil attach -imagekey diskimage-class=CRawDiskImage "$SALIDA" | head -1 | awk '{print $1}')
[ -d /Volumes/CIDATA ] || { hdiutil detach "$DEV" >/dev/null; fallo "no se monto /Volumes/CIDATA"; }
cp "$YAML"     /Volumes/CIDATA/user-data || fallo "cp user-data"
cp "$METADATA" /Volumes/CIDATA/meta-data || fallo "cp meta-data"
mkdir -p /Volumes/CIDATA/encina-repo
# OJO AL COPIAR: macOS escribe al lado un AppleDouble '._<nombre>' por cada
# fichero. NO llegan al objetivo, y esta medido (§4.18m): el 'cp' de
# encina-seed.sh usa el glob '*' del interprete, que no casa con los que
# empiezan por punto, y /target/srv/encina-repo acaba con cinco ficheros
# exactos. Cambiar aquel 'cp' por un 'cp -a' o un 'rsync' SI los metería
# dentro del repositorio de apt. El volumen medido es este, con ellos dentro.
cp "$REPO"/*.deb "$REPO"/Packages /Volumes/CIDATA/encina-repo/ || fallo "cp repo"
sync
hdiutil detach "$DEV" >/dev/null || fallo "detach 2"
ok "escrito"

echo "== 5. releerlo antes de usarlo, que es gratis y evita medir con un seed vacio"
DEV=$(hdiutil attach -imagekey diskimage-class=CRawDiskImage "$SALIDA" | head -1 | awk '{print $1}')
[ -d /Volumes/CIDATA ] || fallo "no se volvio a montar"
ls -l /Volumes/CIDATA/ /Volumes/CIDATA/encina-repo/
for i in 0 1 2 3; do
    real=$(shasum -a 256 "/Volumes/CIDATA/encina-repo/${FICHEROS[$i]}" | cut -d' ' -f1)
    [ "$real" = "${HUELLAS[$i]}" ] || fallo "el .deb no sobrevivio al FAT: ${FICHEROS[$i]}"
done
ok "los cuatro .deb sobreviven al volumen, huella a huella"
diff -q "$YAML" /Volumes/CIDATA/user-data >/dev/null || fallo "user-data no coincide"
diff -q "$METADATA" /Volumes/CIDATA/meta-data >/dev/null || fallo "meta-data no coincide"
ok "user-data y meta-data coinciden byte a byte"
# control de que este paso 5 sabe decir que no
if [ -f /Volumes/CIDATA/encina-repo/fichero-que-no-existe-jamas ]; then
    fallo "control roto: existe un fichero que no se copio"
fi
ok "control: un fichero que no se copio no aparece"
hdiutil detach "$DEV" >/dev/null

echo
echo "seed:   $SALIDA"
echo "sha256: $(shasum -a 256 "$SALIDA" | cut -d' ' -f1)"
echo "tam:    $(stat -f %z "$SALIDA") bytes"
