#!/usr/bin/env bash
# Encina OS - E3. Fabrica la ISO que se entrega, EN MACOS.
#
#     ./fabricar-iso.sh --iso <oficial.iso> --repo <dir> --salida <encina.iso>
#
# QUE HACE, Y ES DELIBERADAMENTE POCO: coge la ISO oficial de Ubuntu y le ANADE
# dos cosas, sin modificar ni un fichero de los que ya trae:
#
#     /autoinstall.yaml   <- imagen/autoinstall-e3.yaml, que es donde el
#                            instalador lo busca: /cdrom/autoinstall.yaml, el
#                            QUINTO sitio de select_autoinstall (MEDICIONES.md
#                            §4.21c), leido en el codigo que viaja en la ISO
#     /encina-repo/       <- los cuatro .deb y su indice Packages
#
# POR QUE NO TOCA EL grub.cfg: porque no hace falta. La palabra 'autoinstall'
# servia para saltarse el clic de confirmacion CUANDO NO HAY NADIE DELANTE, y
# la ISO de E3 pregunta cinco cosas, asi que hay alguien (AGENTS.md §6ter.0).
# Si algun dia hiciera falta tocarlo -- por ejemplo para poner el instalador en
# espanol con 'locale=es_ES.UTF-8' -- HAY QUE REHACER md5sum.txt, que cubre ese
# fichero (§4.21d). Mientras no se toque, la comprobacion de integridad del
# propio medio sigue pasando sola.
#
# LO QUE NO TOCA NUNCA, Y NO ES PRUDENCIA SINO UNA MEDICION: los tres binarios
# firmados de la cadena de arranque -- bootaa64.efi (shim), grubaa64.efi y
# mmaa64.efi --. El banco de UTM NO aplica Secure Boot (§4.21b), asi que si se
# rompieran AQUI NO LO NOTARIA NADIE. Por eso sus huellas se comparan antes y
# despues y este guion se niega si cambia una.
#
# COMO SE RECONSTRUYE LA ISO SIN ROMPER EL ARRANQUE: no se inventa. Se le
# pregunta a la propia imagen con
#     xorriso -indev <iso> -report_el_torito as_mkisofs
# y se usa 'xorriso -boot_image any replay', que reproduce la ESP anadida por
# intervalo de bytes, El Torito y la tabla MBR hibrida tal cual estaban.

set -uo pipefail

AQUI=$(cd "$(dirname "$0")" && pwd)
GUION="$AQUI/encina-seed.sh"
YAML="$AQUI/autoinstall-e3.yaml"

ISO=""; REPO=""; SALIDA=""
# la ISO oficial medida desde §4.14, comprobada en §4.21 antes de leer nada
H_ISO=c2610520bf582976839a1724c669e1cfed0547427be5a0ad12d457b92b46ffbe

uso() { sed -n '2,6p' "$0"; exit 2; }
while [ $# -gt 0 ]; do
    case "$1" in
        --iso)    ISO="$2";    shift 2 ;;
        --repo)   REPO="$2";   shift 2 ;;
        --salida) SALIDA="$2"; shift 2 ;;
        --yaml)   YAML="$2";   shift 2 ;;
        -h|--help) sed -n '1,40p' "$0"; exit 0 ;;
        *) echo "[FALLO] argumento desconocido: $1"; uso ;;
    esac
done
[ -n "$ISO" ] && [ -n "$REPO" ] && [ -n "$SALIDA" ] || uso

fallo() { echo "[FALLO] $*"; exit 1; }
ok()    { echo "[OK]    $*"; }

command -v xorriso >/dev/null || fallo "no hay xorriso (brew install xorriso)"
[ -f "$ISO" ]  || fallo "no existe la ISO: $ISO"
[ -f "$YAML" ] || fallo "no existe el seed: $YAML"

# --- 1. la ISO de partida es la medida, no otra -----------------------------
echo "== 1. la ISO oficial, por huella"
real=$(shasum -a 256 "$ISO" | cut -d' ' -f1)
[ "$real" = "$H_ISO" ] || fallo "esta ISO no es la medida en §4.14/§4.21
        esperada $H_ISO
        real     $real"
ok "ubuntu-24.04.4-desktop-arm64.iso  ${real:0:16}…"

# --- 2. los cuatro .deb, con las huellas del guion que las comprueba dentro --
echo "== 2. los cuatro .deb, por huella (§4.13: misma version != mismos bytes)"
huella_de() { grep -E "^$1=" "$GUION" | head -1 | cut -d= -f2; }
declare -a FICHEROS HUELLAS
FICHEROS=(autofirma_1.9.1+encina2_all.deb
          encina-branding_0.1.7_all.deb
          encina-firefox-native_0.2.1_all.deb
          encina-meta_0.1.1_all.deb)
HUELLAS=("$(huella_de H_AUTOFIRMA)" "$(huella_de H_BRANDING)"
         "$(huella_de H_FFNATIVE)"  "$(huella_de H_META)")
for i in 0 1 2 3; do
    f="$REPO/${FICHEROS[$i]}"
    [ -f "$f" ] || fallo "no esta: $f"
    r=$(shasum -a 256 "$f" | cut -d' ' -f1)
    [ "$r" = "${HUELLAS[$i]}" ] || fallo "huella distinta en ${FICHEROS[$i]}"
    ok "${FICHEROS[$i]}  ${r:0:8}…"
done
[ -f "$REPO/Packages" ] || fallo "no esta $REPO/Packages"
for i in 0 1 2 3; do
    grep -q "^SHA256: ${HUELLAS[$i]}$" "$REPO/Packages" \
        || fallo "Packages no describe ${FICHEROS[$i]}"
done
n=$(grep -cE '^Filename: \./' "$REPO/Packages")
[ "$n" -eq 4 ] || fallo "Packages describe $n ficheros y viajan 4"
ok "Packages describe los cuatro y ni uno mas (el control)"

# --- 3. el seed y el guion no se han separado -------------------------------
echo "== 3. la late-command del seed == encina-seed.sh"
B64=$(base64 -i "$GUION" | tr -d '\n')
grep -q "echo $B64 | base64 -d" "$YAML" \
    || fallo "$(basename "$YAML") y encina-seed.sh se han separado.
        Rehazlo con: ./fabricar-seed.sh --yaml $YAML --actualizar-yaml ..."
ok "coinciden ($(wc -c <"$GUION" | tr -d ' ') bytes de guion)"
# y que el seed de la entrega NO lleve credenciales, que es una casilla
if grep -qE '^\s*(identity|ssh):|password|ssh-ed25519' "$YAML"; then
    fallo "el seed de la entrega lleva credenciales dentro"
fi
ok "el seed no lleva identidad, ni contrasena, ni clave ssh"
# CONTROL de esa busqueda: tiene que encontrarlas en el seed de laboratorio
if grep -qE 'password|ssh-ed25519' "$AQUI/autoinstall.yaml"; then
    ok "control: la misma busqueda SI las encuentra en el seed de laboratorio"
else
    fallo "CONTROL ROTO: no sabe encontrar credenciales ni donde las hay"
fi

# --- 4. las huellas de la cadena firmada, ANTES ------------------------------
echo "== 4. los tres binarios firmados, antes"
declare -a EFI ANTES
EFI=(bootaa64.efi grubaa64.efi mmaa64.efi)
for i in 0 1 2; do
    ANTES[$i]=$(tar -xOf "$ISO" "efi/boot/${EFI[$i]}" | shasum -a 256 | cut -d' ' -f1)
    ok "${EFI[$i]}  ${ANTES[$i]:0:16}…"
done

# --- 5. construir ------------------------------------------------------------
echo "== 5. xorriso: anadir, sin modificar nada"
TMP=$(mktemp -d) || fallo "mktemp"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/encina-repo"
cp "$YAML" "$TMP/autoinstall.yaml" || fallo "cp seed"
cp "$REPO"/*.deb "$REPO"/Packages "$TMP/encina-repo/" || fallo "cp repo"
rm -f "$SALIDA"
xorriso -indev "$ISO" -outdev "$SALIDA" \
        -boot_image any replay \
        -map "$TMP/autoinstall.yaml" /autoinstall.yaml \
        -map "$TMP/encina-repo" /encina-repo \
        -commit -end 2>&1 | grep -iE "^xorriso : (FAILURE|SORRY|WARNING)" | head -20
[ -f "$SALIDA" ] || fallo "xorriso no produjo $SALIDA"
ok "escrita: $(stat -f %z "$SALIDA") bytes"

# --- 6. y ahora la parte que importa: comprobar que solo se anadio ----------
echo "== 6. la cadena firmada, DESPUES (si cambia una, este banco no lo notaria)"
for i in 0 1 2; do
    d=$(tar -xOf "$SALIDA" "efi/boot/${EFI[$i]}" | shasum -a 256 | cut -d' ' -f1)
    [ "$d" = "${ANTES[$i]}" ] || fallo "CAMBIO ${EFI[$i]}
        antes   ${ANTES[$i]}
        despues $d"
    ok "${EFI[$i]} intacto"
done

echo "== 7. lo anadido esta, y con las huellas de siempre"
tar -xOf "$SALIDA" autoinstall.yaml | diff -q - "$YAML" >/dev/null \
    || fallo "el seed dentro de la ISO no coincide con $YAML"
ok "/autoinstall.yaml == $(basename "$YAML")"
for i in 0 1 2 3; do
    d=$(tar -xOf "$SALIDA" "encina-repo/${FICHEROS[$i]}" | shasum -a 256 | cut -d' ' -f1)
    [ "$d" = "${HUELLAS[$i]}" ] || fallo "${FICHEROS[$i]} no sobrevivio a la ISO"
done
ok "los cuatro .deb sobreviven a la ISO, huella a huella"
# CONTROL: la ISO no puede contener algo que no se metio
if tar -tf "$SALIDA" 2>/dev/null | grep -q "^encina-repo/fichero-que-no-existe"; then
    fallo "CONTROL ROTO: aparece un fichero que nadie metio"
fi
ok "control: un fichero que no se metio no aparece"

echo "== 8. el arranque: la FORMA y el CONTENIDO de la ESP, contra la oficial"
# OJO: los desplazamientos y el tamano de la ESP CAMBIAN por fuerza al anadir
# ficheros -- la ISO crece y la particion anadida se mueve al final, y xorriso
# la alinea rellenando con ceros (-partition_cyl_align all). Comparar LBAs seria
# una comprobacion que falla siempre y no dice nada. Lo que tiene que ser igual
# es la FORMA -- tipos de particion, El Torito, plataforma -- y el CONTENIDO de
# la ESP, que es donde viven los tres binarios firmados.
forma() {
    python3 - "$1" <<'PY2'
import sys, struct
f=open(sys.argv[1],'rb'); mbr=f.read(512); out=[]
for i in range(4):
    e=mbr[446+16*i:446+16*i+16]
    if any(e): out.append("mbr_tipo:0x%02x" % e[4])
f.seek(17*2048); b=f.read(2048)
out.append("brvd:"+b[7:30].decode(errors='replace').strip('\0'))
cat=struct.unpack('<I', b[0x47:0x4b])[0]; f.seek(cat*2048); c=f.read(64)
out.append("plataforma:%d" % c[1])
out.append("arrancable:0x%02x" % c[32])
print(" | ".join(out))
PY2
}
A=$(forma "$ISO"); B=$(forma "$SALIDA")
echo "  oficial: $A"
echo "  nuestra: $B"
[ "$A" = "$B" ] || fallo "la FORMA de arranque no es la misma"
ok "MBR hibrido, El Torito y plataforma UEFI, iguales"

# el contenido de la ESP: se localiza en cada imagen por su propia tabla MBR
esp() {  # imprime "inicio sectores" de la particion 0xef
    python3 - "$1" <<'PY2'
import sys, struct
mbr=open(sys.argv[1],'rb').read(512)
for i in range(4):
    e=mbr[446+16*i:446+16*i+16]
    if any(e) and e[4]==0xef:
        print(struct.unpack('<I',e[8:12])[0], struct.unpack('<I',e[12:16])[0]); break
PY2
}
read -r AI AN <<<"$(esp "$ISO")"
read -r BI BN <<<"$(esp "$SALIDA")"
[ -n "$AI" ] && [ -n "$BI" ] || fallo "no encuentro la ESP en alguna de las dos"
[ "$BN" -ge "$AN" ] || fallo "la ESP de nuestra ISO es MAS PEQUENA que la oficial"
HA=$(dd if="$ISO"    bs=512 skip="$AI" count="$AN" 2>/dev/null | shasum -a 256 | cut -d' ' -f1)
HB=$(dd if="$SALIDA" bs=512 skip="$BI" count="$AN" 2>/dev/null | shasum -a 256 | cut -d' ' -f1)
[ "$HA" = "$HB" ] || fallo "el CONTENIDO de la ESP ha cambiado
        oficial ${HA:0:32}
        nuestra ${HB:0:32}"
ok "la ESP es byte a byte la oficial en sus $AN sectores  (${HA:0:16}…)"
# y lo que xorriso anade al final tiene que ser relleno, no datos
SOBRA=$((BN - AN))
if [ "$SOBRA" -gt 0 ]; then
    NOCERO=$(dd if="$SALIDA" bs=512 skip=$((BI + AN)) count="$SOBRA" 2>/dev/null | tr -d '\000' | wc -c | tr -d ' ')
    [ "$NOCERO" = 0 ] || fallo "los $SOBRA sectores que xorriso anade a la ESP NO son ceros ($NOCERO bytes)"
    ok "los $SOBRA sectores de mas son relleno de alineacion: 0 bytes distintos de cero"
fi

echo
echo "iso:    $SALIDA"
echo "sha256: $(shasum -a 256 "$SALIDA" | cut -d' ' -f1)"
echo "tam:    $(stat -f %z "$SALIDA") bytes"
echo
echo "LO QUE ESTE GUION NO PUEDE DECIR: que arranque. Eso se mide en una VM"
echo "creada desde cero, contestando las cinco pantallas (AGENTS.md §6ter.3)."
