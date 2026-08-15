#!/bin/bash
# Encina OS - E2. Fabrica el volumen CIDATA del seed, EN MACOS.
#
# Que produce: una imagen CRUDA con etiqueta CIDATA que lleva dentro
#
#     user-data          <- imagen/autoinstall-unattended.yaml
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
YAML="$AQUI/autoinstall-unattended.yaml"
METADATA="$AQUI/meta-data"

REPO=""
SALIDA=""
ACTUALIZAR=0
# 128 MiB bastaban mientras el repo eran cuatro .deb y 44 MB. Desde el nivel 3
# de §4.27 el medio lleva ademas todo lo que bajaba de internet -el JRE, el
# navegador, la tienda, el escaner- y no cabe. El tamano se declara y se
# comprueba: si el repo no cupiera, el 'cp' fallaria a mitad y el volumen
# saldria a medias sin que nada lo dijera.
TAM_MB=768

uso() {
    cat <<'FIN'
uso: fabricar-seed.sh --repo DIR --salida IMG [--yaml RUTA] [--tam-mb N] [--actualizar-yaml]

  --repo DIR          directorio con los .deb de Encina, el resto del repo
                      offline (nivel 3 de §4.27) y el fichero Packages
  --salida IMG        imagen CIDATA a escribir (se sobrescribe)
  --yaml RUTA         seed a meter como user-data. Por defecto autoinstall-unattended.yaml,
                      que es el de E2 (desatendido, con contrasena de
                      laboratorio). Para medir la forma de E3 se le pasa
                      autoinstall.yaml, que pregunta y no lleva credenciales
  --tam-mb N          tamano del volumen en MiB (por defecto 768)
  --actualizar-yaml   reescribe la late-command del YAML elegido a partir de
                      encina-seed.sh, en vez de solo comprobar que coinciden
FIN
}

while [ $# -gt 0 ]; do
    case "$1" in
        --repo)             REPO="$2"; shift 2 ;;
        --salida)           SALIDA="$2"; shift 2 ;;
        --yaml)             YAML="$2"; shift 2 ;;
        --tam-mb)           TAM_MB="$2"; shift 2 ;;
        --actualizar-yaml)  ACTUALIZAR=1; shift ;;
        -h|--help)          uso; exit 0 ;;
        *) echo "[FALLO] argumento desconocido: $1"; uso; exit 2 ;;
    esac
done

[ -f "$YAML" ] || { echo "[FALLO] no existe el seed: $YAML"; exit 2; }

[ -n "$REPO" ] && [ -n "$SALIDA" ] || { uso; exit 2; }

fallo() { echo "[FALLO] $*"; exit 1; }
ok()    { echo "[OK]    $*"; }

# --- 1. las huellas, sacadas del guion que las va a comprobar dentro ---------
huella_de() {  # $1 = nombre de la variable en encina-seed.sh
    grep -E "^$1=" "$GUION" | head -1 | cut -d= -f2
}
declare -a FICHEROS HUELLAS
# LOS NOMBRES LLEVAN LA VERSION DENTRO, asi que cambiar un .deb son las CUATRO
# cosas de SCRIPTS.md y no una. Y el de autofirma se elige POR RUTA ENTERA:
# encina-autofirma/salida/ tiene TRES candidatos con la misma pinta
# -d5a0ebe1... (+encina2), 2d985724... (+encina3) y faeca3a9... (+encina4)- y
# un 'ls -t | head -1' construye una cosa distinta de la que crees (§4.13).
FICHEROS=(autofirma_1.9.1+encina4_all.deb
          encina-branding_0.1.14_all.deb
          encina-firefox-native_0.2.1_all.deb
          encina-meta_0.2.1_all.deb)
HUELLAS=("$(huella_de H_AUTOFIRMA)"
         "$(huella_de H_BRANDING)"
         "$(huella_de H_FFNATIVE)"
         "$(huella_de H_META)")

echo "== 1. los cuatro .deb de Encina, POR HUELLA (§4.13: misma version != mismos bytes)"
for i in 0 1 2 3; do
    f="$REPO/${FICHEROS[$i]}"
    [ -f "$f" ] || fallo "no esta: $f"
    real=$(shasum -a 256 "$f" | cut -d' ' -f1)
    [ "$real" = "${HUELLAS[$i]}" ] || fallo "huella distinta en ${FICHEROS[$i]}
        esperada ${HUELLAS[$i]}
        real     $real"
    ok "${FICHEROS[$i]}  ${real:0:8}…"
done

echo "== 2. el indice Packages describe esos mismos bytes, y TODO lo que viaja"
[ -f "$REPO/Packages" ] || fallo "no esta: $REPO/Packages"
for i in 0 1 2 3; do
    grep -q "^SHA256: ${HUELLAS[$i]}$" "$REPO/Packages" \
        || fallo "Packages no contiene la huella de ${FICHEROS[$i]}"
done
ok "las cuatro huellas de Encina estan en Packages"
# EL RESTO DEL REPO -- el nivel 3 de §4.27 -- no tiene huellas escritas a mano en
# ningun sitio: de el responde este indice, porque es lo que apt verifica al
# instalar. Asi que aqui se comprueba EL INDICE ENTERO contra los bytes que
# viajan, en las dos direcciones: ni sobra un Filename ni falta un .deb.
grep -qE '^Filename: \./' "$REPO/Packages" \
    || fallo "Packages no tiene rutas relativas ./ — el repo no se leeria"
NIDX=$(grep -cE '^Filename: \./' "$REPO/Packages")
NDEB=$(ls -1 "$REPO"/*.deb 2>/dev/null | wc -l | tr -d ' ')
[ "$NIDX" -eq "$NDEB" ] || fallo "Packages describe $NIDX ficheros y en el repo hay $NDEB .deb"
ok "Packages describe $NIDX ficheros y viajan $NDEB, ni uno mas ni uno menos"
MALAS=0
while read -r f; do
    [ -f "$REPO/$f" ] || { echo "        no viaja: $f"; MALAS=$((MALAS+1)); }
done < <(sed -n 's|^Filename: \./||p' "$REPO/Packages")
[ "$MALAS" -eq 0 ] || fallo "$MALAS ficheros descritos en Packages no estan en el repo"
# y las huellas del indice contra los bytes, una a una
paste -d' ' <(sed -n 's|^Filename: \./||p' "$REPO/Packages") \
            <(sed -n 's|^SHA256: ||p'      "$REPO/Packages") \
  | while read -r f h; do
        r=$(shasum -a 256 "$REPO/$f" | cut -d' ' -f1)
        [ "$r" = "$h" ] || echo "HUELLA-MALA $f"
    done > "$REPO/.huellas-malas.tmp"
if [ -s "$REPO/.huellas-malas.tmp" ]; then
    cat "$REPO/.huellas-malas.tmp"; rm -f "$REPO/.huellas-malas.tmp"
    fallo "el indice Packages no describe los bytes que viajan"
fi
rm -f "$REPO/.huellas-malas.tmp"
ok "las $NIDX huellas de Packages coinciden con los bytes del repo"
# CONTROL de ese comparador, que tiene que saber decir MALA. Si no supiera, el
# [OK] de arriba lo daria igual con un repo corrupto: se le enfrenta el primer
# fichero con la huella del SEGUNDO, y tiene que verlo.
PRIMERO=$(sed -n 's|^Filename: \./||p' "$REPO/Packages" | sed -n 1p)
H_OTRA=$(sed -n 's|^SHA256: ||p' "$REPO/Packages" | sed -n 2p)
r=$(shasum -a 256 "$REPO/$PRIMERO" | cut -d' ' -f1)
if [ -n "$H_OTRA" ] && [ "$r" = "$H_OTRA" ]; then
    fallo "CONTROL ROTO: dos ficheros distintos con la misma huella"
elif [ -z "$H_OTRA" ]; then
    fallo "CONTROL ROTO: el indice no tiene una segunda huella con la que comparar"
else
    ok "control: enfrentado a la huella de otro fichero, el comparador lo ve"
fi

echo "== 3. la late-command del seed == encina-seed.sh"
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
    ok "el seed actualizado desde encina-seed.sh"
fi
grep -qxF "$LINEA" "$YAML" \
    || fallo "el seed y encina-seed.sh se han separado.
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
