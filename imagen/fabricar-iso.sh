#!/usr/bin/env bash
# Encina OS - E3. Fabrica la ISO que se entrega, EN MACOS.
#
#     ./fabricar-iso.sh [--iso <oficial.iso>] --repo <dir> --salida <encina.iso>
#
# --iso vale por defecto medios/ubuntu-24.04.4-desktop-arm64.iso, que es donde
# la deja imagen/traer-iso-oficial.sh. Ese directorio esta en .gitignore: la ISO
# oficial son 3,3 GiB y no viaja en el clon, pero la ORDEN de traerla si.
#
# QUE HACE: coge la ISO oficial de Ubuntu, le ANADE lo de Encina y MODIFICA dos
# ficheros, ni uno mas. Los cuatro sitios estan nombrados aqui porque la
# definicion de terminado de E3 se comprueba contra esta lista.
#
# ANADE:
#     /autoinstall.yaml   <- imagen/autoinstall.yaml, que es donde el
#                            instalador lo busca: /cdrom/autoinstall.yaml, el
#                            QUINTO sitio de select_autoinstall (MEDICIONES.md
#                            §4.21c), leido en el codigo que viaja en la ISO
#     /encina-repo/       <- los cuatro .deb de Encina, TODO lo que hasta E3
#                            bajaba de internet (el nivel 3 de MEDICIONES.md
#                            §4.27: el JRE de autofirma, libnss3-tools,
#                            hunspell-es, el navegador de Mozilla y su idioma,
#                            la tienda y el escaner) y su indice Packages
#
# MODIFICA, y hasta el 2026-08-10 no modificaba nada:
#     /boot/grub/grub.cfg <- 'locale=es_ES.UTF-8' en la linea del nucleo, que es
#                            lo que pone EL INSTALADOR en espanol. Sin esto la
#                            ISO recibe en ingles a quien la instala, aunque la
#                            maquina que sale quede en espanol: es la NOVENA
#                            casilla de AGENTS.md §6ter.3, anadida despues de
#                            marcar las ocho porque las ocho la dejaban pasar.
#                            El mecanismo esta LEIDO, no supuesto, en el
#                            casper de esta misma ISO: scripts/casper-bottom/
#                            14locales recorre TODOS los tokens de /proc/cmdline
#                            y con 'locale=*' escribe LANG en el
#                            /etc/default/locale de la SESION VIVA y corre
#                            locale-gen dentro de ella.
#     /md5sum.txt         <- EL PRECIO, y hay que pagarlo entero (§4.21d):
#                            md5sum.txt CUBRE ./boot/grub/grub.cfg, asi que
#                            editarlo y no rehacerlo deja una ISO que arranca
#                            bien y FALLA la comprobacion de integridad de su
#                            propio medio. Se reescribe UNA linea, la suya.
#
# CONSECUENCIA PARA LA DEFINICION DE TERMINADO: E3 ya no es «solo anadir
# ficheros», y la casilla de integridad pasa a comprobar el md5sum.txt NUEVO en
# vez del oficial. Por eso este guion no se cree a si mismo: al final compara la
# ISO nueva contra la oficial FICHERO A FICHERO -- las 300 y pico entradas del
# medio, no solo las 266 de md5sum.txt -- y se niega si cambio algo que no sean
# esos dos, o si aparecio algo que no sea el seed y el contenido de --repo. La
# lista de anadidos se DERIVA del directorio de origen, porque desde E4 ya no
# son seis ficheros: son el seed, el indice y todos los .deb del repo offline.
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
YAML="$AQUI/autoinstall.yaml"

ISO=""; REPO=""; SALIDA=""
# la ISO oficial medida desde §4.14, comprobada en §4.21 antes de leer nada
H_ISO=c2610520bf582976839a1724c669e1cfed0547427be5a0ad12d457b92b46ffbe
# el idioma del producto, que NO se pregunta (AGENTS.md §6ter.0). Va en el seed
# como 'locale:' para la maquina que sale, y aqui en el grub.cfg para que el
# INSTALADOR se vea en el mismo idioma. Los dos sitios dicen lo mismo a proposito.
LOCALE=es_ES.UTF-8

uso() { sed -n '2,10p' "$0"; exit 2; }
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
[ -n "$ISO" ] || ISO="$AQUI/../medios/ubuntu-24.04.4-desktop-arm64.iso"
[ -n "$REPO" ] && [ -n "$SALIDA" ] || uso

fallo() { echo "[FALLO] $*"; exit 1; }
ok()    { echo "[OK]    $*"; }

command -v xorriso >/dev/null || fallo "no hay xorriso (brew install xorriso)"
[ -f "$ISO" ]  || fallo "no esta la ISO oficial: $ISO
        Traela y comprueba su firma con:  ./imagen/traer-iso-oficial.sh
        (medios/ esta en .gitignore a proposito: ver medios/LEEME.md)"
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
FICHEROS=(autofirma_1.9.1+encina4_all.deb
          encina-branding_0.1.9_all.deb
          encina-firefox-native_0.2.1_all.deb
          encina-meta_0.2.1_all.deb)
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
# EL RESTO DEL MEDIO ES NUEVO EN E4: el nivel 3 de §4.27 mete en /encina-repo
# todo lo que hasta hoy bajaba de internet. No tiene huellas escritas a mano en
# ningun sitio -- de el responde Packages, que es lo que apt verifica -- asi que
# aqui se comprueba el indice ENTERO contra los bytes, en las dos direcciones.
NIDX=$(grep -cE '^Filename: \./' "$REPO/Packages")
NDEB=$(ls -1 "$REPO"/*.deb 2>/dev/null | wc -l | tr -d ' ')
[ "$NIDX" -eq "$NDEB" ] || fallo "Packages describe $NIDX ficheros y en el repo hay $NDEB .deb"
MALAS=0
while read -r f h; do
    [ -f "$REPO/$f" ] || { echo "        no viaja: $f"; MALAS=$((MALAS+1)); continue; }
    r=$(shasum -a 256 "$REPO/$f" | cut -d' ' -f1)
    [ "$r" = "$h" ] || { echo "        huella mala: $f"; MALAS=$((MALAS+1)); }
done < <(paste -d' ' <(sed -n 's|^Filename: \./||p' "$REPO/Packages") \
                    <(sed -n 's|^SHA256: ||p'      "$REPO/Packages"))
[ "$MALAS" -eq 0 ] || fallo "$MALAS entradas de Packages no cuadran con los bytes del repo"
ok "Packages describe $NIDX ficheros, viajan $NDEB, y las $NIDX huellas cuadran"

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
if grep -qE 'password|ssh-ed25519' "$AQUI/autoinstall-unattended.yaml"; then
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

# --- 5. los DOS ficheros que si se modifican, preparados y comprobados aqui ---
echo "== 5. el grub.cfg en espanol, y el md5sum.txt que lo cubre"
TMP=$(mktemp -d) || fallo "mktemp"
trap 'rm -rf "$TMP"' EXIT

tar -xOf "$ISO" boot/grub/grub.cfg > "$TMP/grub.cfg.oficial" \
    || fallo "no pude leer boot/grub/grub.cfg de la ISO"
# §4.21d: en todo el medio hay UN solo grub.cfg y una sola linea de nucleo. Si
# esto deja de ser verdad, la ISO no es la medida y hay que parar, no adivinar.
n=$(grep -c '/casper/vmlinuz' "$TMP/grub.cfg.oficial")
[ "$n" -eq 1 ] || fallo "esperaba UNA linea con /casper/vmlinuz y hay $n"
grep -q 'locale=' "$TMP/grub.cfg.oficial" \
    && fallo "el grub.cfg oficial ya trae un locale=: parar y mirar por que"
# la palabra va ANTES del '---', que es la ranura de casper
sed "s|/casper/vmlinuz|/casper/vmlinuz locale=$LOCALE|" \
    "$TMP/grub.cfg.oficial" > "$TMP/grub.cfg"
grep -q "linux[[:space:]]*/casper/vmlinuz locale=$LOCALE .*---" "$TMP/grub.cfg" \
    || fallo "la palabra no quedo en la linea del nucleo antes del ---"
d=$(diff "$TMP/grub.cfg.oficial" "$TMP/grub.cfg" | grep -c '^[<>]')
[ "$d" -eq 2 ] || fallo "grub.cfg cambia en $d lineas y tenia que cambiar en una"
ok "grub.cfg: locale=$LOCALE en la linea del nucleo, y no cambia nada mas"

tar -xOf "$ISO" md5sum.txt > "$TMP/md5sum.oficial" \
    || fallo "no pude leer md5sum.txt de la ISO"
n=$(grep -c '  \./boot/grub/grub.cfg$' "$TMP/md5sum.oficial")
[ "$n" -eq 1 ] || fallo "md5sum.txt tiene $n lineas de grub.cfg y esperaba una"
VIEJO=$(grep '  \./boot/grub/grub.cfg$' "$TMP/md5sum.oficial" | cut -d' ' -f1)
# CONTROL de que esa linea habla de ESTE fichero y no de otro (§4.21d, medido a
# mano entonces; aqui se vuelve a medir en cada construccion)
[ "$(md5 -q "$TMP/grub.cfg.oficial")" = "$VIEJO" ] \
    || fallo "la linea de md5sum.txt no describe el grub.cfg de esta ISO"
NUEVO=$(md5 -q "$TMP/grub.cfg")
[ "$NUEVO" != "$VIEJO" ] || fallo "el grub.cfg modificado tiene el mismo md5"
sed "s|^$VIEJO  \./boot/grub/grub.cfg\$|$NUEVO  ./boot/grub/grub.cfg|" \
    "$TMP/md5sum.oficial" > "$TMP/md5sum.txt"
d=$(diff "$TMP/md5sum.oficial" "$TMP/md5sum.txt" | grep -c '^[<>]')
[ "$d" -eq 2 ] || fallo "md5sum.txt cambia en $d lineas y tenia que cambiar en una"
L=$(wc -l < "$TMP/md5sum.oficial" | tr -d ' ')
[ "$(wc -l < "$TMP/md5sum.txt" | tr -d ' ')" = "$L" ] || fallo "md5sum.txt cambia de tamano"
ok "md5sum.txt: una linea rehecha (${VIEJO:0:8}… -> ${NUEVO:0:8}…), las otras $((L-1)) intactas"

# --- 6. construir ------------------------------------------------------------
echo "== 6. xorriso: anadir seis ficheros y reemplazar dos"
mkdir -p "$TMP/encina-repo"
cp "$YAML" "$TMP/autoinstall.yaml" || fallo "cp seed"
cp "$REPO"/*.deb "$REPO"/Packages "$TMP/encina-repo/" || fallo "cp repo"

# EL MODO DE LO QUE SE ANADE, FIJADO A PROPOSITO, POR EL MISMO MOTIVO QUE LA
# FECHA DE ABAJO Y CON LA MISMA FORMA. 'cp' conserva el modo que el fichero
# tuviera en el disco del Mac, y ese modo VIAJA DENTRO DE LA ISO: es el campo
# PX de Rock Ridge, en sus dos copias -little-endian y big-endian- y en los dos
# arboles de directorio. Medido (MEDICIONES.md §4.36k): la ISO vigente
# ac0a5721… se diferenciaba de la fabricada desde el repositorio cosechado en
# 2 sectores de 1 814 144, y esos 4 bytes eran un solo campo -- el modo de
# encina-firefox-native_0.2.1_all.deb, 0700 en el medio vigente porque ese dia
# el fichero estaba en 0700 en 'debian-packages/', y 0644 al dia siguiente
# porque ya no lo estaba. O sea que la ISO NO LA REPRODUCIA NI SU PROPIO
# DIRECTORIO DE ORIGEN. Hoy en 'debian-packages/' siguen conviviendo ficheros
# en 0600 y en 0644, asi que esto no es hipotetico.
#
# 0644 para los ficheros y 0755 para el directorio: es lo que ya llevan los 29
# ficheros del medio, asi que fijarlo no cambia el producto -- solo deja de
# depender de un dato que no esta versionado.
MODO_F=644
MODO_D=755
chmod "$MODO_D" "$TMP/encina-repo"                  || fallo "chmod dir repo"
chmod "$MODO_F" "$TMP/encina-repo"/* "$TMP/autoinstall.yaml" \
                "$TMP/grub.cfg" "$TMP/md5sum.txt"   || fallo "chmod ficheros"
# Y SE COMPRUEBA QUE SE APLICO, que es la trampa 13: una mutacion se verifica
# ANTES de leer su resultado. Sin esto, un chmod que fallara en silencio daria
# exactamente la ISO que este bloque existe para evitar, y nadie lo notaria.
n=$(find "$TMP/encina-repo" "$TMP/autoinstall.yaml" "$TMP/grub.cfg" \
         "$TMP/md5sum.txt" -type f ! -perm "$MODO_F" | wc -l | tr -d ' ')
[ "$n" -eq 0 ] || fallo "$n ficheros no quedaron en $MODO_F pese al chmod"
d=$(find "$TMP/encina-repo" -type d ! -perm "$MODO_D" | wc -l | tr -d ' ')
[ "$d" -eq 0 ] || fallo "el directorio del repo no quedo en $MODO_D"
t=$(find "$TMP/encina-repo" -type f | wc -l | tr -d ' ')
ok "modo fijado: $((t+3)) ficheros en $MODO_F y el directorio del repo en $MODO_D"

rm -f "$SALIDA"
# LA FECHA DE LO QUE SE ANADE, FIJADA A PROPOSITO: sin esto, la misma orden
# ejecutada dos veces produce dos ISOs distintas -- 192 bytes en 4 sectores, que
# son las marcas de tiempo de los ficheros nuevos en sus registros de directorio
# (medido: 20:08:38 contra 21:35:45). Se les pone la fecha de modificacion de la
# ISO OFICIAL, que la propia imagen declara en su receta
# (--modification-date='2026021001455100'), asi que lo anadido hereda la fecha
# del medio y la construccion es REPRODUCIBLE: misma entrada, misma huella.
FECHA='2026021001455100'
xorriso -indev "$ISO" -outdev "$SALIDA" \
        -boot_image any replay \
        -overwrite on \
        -map "$TMP/autoinstall.yaml" /autoinstall.yaml \
        -map "$TMP/encina-repo" /encina-repo \
        -map "$TMP/grub.cfg" /boot/grub/grub.cfg \
        -map "$TMP/md5sum.txt" /md5sum.txt \
        -alter_date_r b "$FECHA" /autoinstall.yaml /encina-repo \
                                 /boot/grub/grub.cfg /md5sum.txt -- \
        -alter_date_r c "$FECHA" /autoinstall.yaml /encina-repo \
                                 /boot/grub/grub.cfg /md5sum.txt -- \
        -commit -end 2>&1 | grep -iE "^xorriso : (FAILURE|SORRY|WARNING)" | head -20
[ -f "$SALIDA" ] || fallo "xorriso no produjo $SALIDA"
ok "escrita: $(stat -f %z "$SALIDA") bytes"

# --- 7. y ahora la parte que importa: comprobar que solo se anadio ----------
echo "== 7. la cadena firmada, DESPUES (si cambia una, este banco no lo notaria)"
for i in 0 1 2; do
    d=$(tar -xOf "$SALIDA" "efi/boot/${EFI[$i]}" | shasum -a 256 | cut -d' ' -f1)
    [ "$d" = "${ANTES[$i]}" ] || fallo "CAMBIO ${EFI[$i]}
        antes   ${ANTES[$i]}
        despues $d"
    ok "${EFI[$i]} intacto"
done

echo "== 8. lo anadido esta, y con las huellas de siempre"
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

echo "== 9. el arranque: la FORMA y el CONTENIDO de la ESP, contra la oficial"
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

# --- 10. el medio entero, fichero a fichero ----------------------------------
# Mientras E3 solo anadia ficheros, «no se modifico nada» se podia argumentar.
# Desde que toca grub.cfg y md5sum.txt hay que ENSENARLO, y sobre TODAS las
# entradas del medio, no solo sobre las 266 que md5sum.txt cubre. Se lee cada
# imagen UNA sola vez: xorriso da el LBA y el tamano de cada fichero y el md5 se
# calcula buscando dentro de la propia imagen, sin extraer 3,4 GB a disco.
echo "== 10. el medio entero, fichero a fichero, contra la oficial"
cat > "$TMP/mapa.py" <<'PY3'
import sys, hashlib
f = open(sys.argv[1], "rb")
for linea in sys.stdin:
    if not linea.startswith("File data lba:"):
        continue
    p = linea.split(",", 4)
    lba, tam, ruta = int(p[1]), int(p[3]), p[4].strip().strip("'")
    h = hashlib.md5()
    f.seek(lba * 2048)
    leidos = 0
    while leidos < tam:
        t = f.read(min(1 << 20, tam - leidos))
        if not t:
            break
        h.update(t)
        leidos += len(t)
    if leidos != tam:
        sys.exit("no pude leer entera: " + ruta)
    print(h.hexdigest(), ruta)
PY3
mapa() {
    xorriso -indev "$1" -find / -type f -exec report_lba -- 2>/dev/null \
        | python3 "$TMP/mapa.py" "$1" | LC_ALL=C sort -k2
}
mapa "$ISO"    > "$TMP/mapa.oficial" || fallo "no pude mapear la ISO oficial"
mapa "$SALIDA" > "$TMP/mapa.nuestra" || fallo "no pude mapear la ISO construida"
# guarda: si alguna ruta llevara espacios, el resto de este bloque mentiria
awk 'NF!=2 {exit 1}' "$TMP/mapa.oficial" \
    || fallo "hay rutas con espacios en el medio: esta comprobacion no vale"
ok "leidas $(wc -l < "$TMP/mapa.oficial" | tr -d ' ') entradas de la oficial y $(wc -l < "$TMP/mapa.nuestra" | tr -d ' ') de la nuestra"

awk '{print $2}' "$TMP/mapa.oficial" | LC_ALL=C sort > "$TMP/rutas.oficial"
awk '{print $2}' "$TMP/mapa.nuestra" | LC_ALL=C sort > "$TMP/rutas.nuestra"
# LOS ANADIDOS YA NO SON SEIS: con el nivel 3 de §4.27 el repo lleva dentro
# todo lo que bajaba de internet, asi que la lista esperada se DERIVA del
# directorio de origen. Lo que no cambia es la exigencia: ni uno mas, ni uno
# menos, y ninguno perdido.
{ echo /autoinstall.yaml
  for f in "$REPO"/*; do echo "/encina-repo/$(basename "$f")"; done
} | LC_ALL=C sort > "$TMP/anadidos.esperados"
N_ESPERADOS=$(wc -l < "$TMP/anadidos.esperados" | tr -d ' ')
LC_ALL=C comm -13 "$TMP/rutas.oficial" "$TMP/rutas.nuestra" > "$TMP/anadidos"
LC_ALL=C comm -23 "$TMP/rutas.oficial" "$TMP/rutas.nuestra" > "$TMP/quitados"
[ ! -s "$TMP/quitados" ] || fallo "la ISO nuestra ha PERDIDO ficheros:
$(cat "$TMP/quitados")"
diff -q "$TMP/anadidos.esperados" "$TMP/anadidos" >/dev/null \
    || fallo "los ficheros anadidos no son los seis esperados:
$(diff "$TMP/anadidos.esperados" "$TMP/anadidos")"
ok "$N_ESPERADOS ficheros anadidos, ni uno mas, y ninguno perdido"

LC_ALL=C join -1 2 -2 2 "$TMP/mapa.oficial" "$TMP/mapa.nuestra" \
    | awk '$2!=$3 {print $1}' | LC_ALL=C sort > "$TMP/cambiados"
printf '%s\n' /boot/grub/grub.cfg /md5sum.txt | LC_ALL=C sort > "$TMP/cambiados.esperados"
diff -q "$TMP/cambiados.esperados" "$TMP/cambiados" >/dev/null \
    || fallo "los ficheros modificados no son los dos declarados:
$(diff "$TMP/cambiados.esperados" "$TMP/cambiados")"
ok "modificados exactamente dos: /boot/grub/grub.cfg y /md5sum.txt"
# CONTROL de la comparacion entera: tiene que saber ver un cambio donde lo hay.
# Se compara la oficial consigo misma cambiandole una huella a mano.
awk 'NR==1{$1="ffffffffffffffffffffffffffffffff"}1' "$TMP/mapa.oficial" \
    | LC_ALL=C sort -k2 > "$TMP/mapa.saboteada"
c=$(LC_ALL=C join -1 2 -2 2 "$TMP/mapa.oficial" "$TMP/mapa.saboteada" | awk '$2!=$3' | wc -l | tr -d ' ')
[ "$c" -eq 1 ] || fallo "CONTROL ROTO: la comparacion no ve una huella cambiada"
ok "control: con una huella saboteada, la comparacion la senala"

echo "== 11. la integridad del propio medio, contra el md5sum.txt NUEVO"
tar -xOf "$SALIDA" md5sum.txt | sed 's|  \./|  /|' | LC_ALL=C sort -k2 > "$TMP/md5.declarado"
d=$(wc -l < "$TMP/md5.declarado" | tr -d ' ')
c=$(LC_ALL=C join -1 2 -2 2 "$TMP/md5.declarado" "$TMP/mapa.nuestra" | wc -l | tr -d ' ')
[ "$c" -eq "$d" ] || fallo "solo se pudieron comparar $c de $d lineas de md5sum.txt"
m=$(LC_ALL=C join -1 2 -2 2 "$TMP/md5.declarado" "$TMP/mapa.nuestra" | awk '$2!=$3' | wc -l | tr -d ' ')
[ "$m" -eq 0 ] || fallo "$m de las $d lineas de md5sum.txt NO cuadran con el medio"
ok "las $d lineas de md5sum.txt cuadran con la ISO construida, la del grub.cfg incluida"
# CONTROL: con el md5sum.txt OFICIAL, la del grub.cfg tiene que fallar -- que es
# exactamente la ISO que se entregaria si alguien se saltara el precio de §4.21d
sed 's|  \./|  /|' "$TMP/md5sum.oficial" | LC_ALL=C sort -k2 > "$TMP/md5.oficial.rutas"
m=$(LC_ALL=C join -1 2 -2 2 "$TMP/md5.oficial.rutas" "$TMP/mapa.nuestra" | awk '$2!=$3' | wc -l | tr -d ' ')
[ "$m" -eq 1 ] || fallo "CONTROL ROTO: con el md5sum.txt oficial esperaba 1 fallo y hay $m"
ok "control: con el md5sum.txt OFICIAL falla exactamente una linea, la del grub.cfg"

echo
echo "iso:    $SALIDA"
echo "sha256: $(shasum -a 256 "$SALIDA" | cut -d' ' -f1)"
echo "tam:    $(stat -f %z "$SALIDA") bytes"
echo
echo "LO QUE ESTE GUION NO PUEDE DECIR: que arranque. Eso se mide en una VM"
echo "creada desde cero, contestando las cinco pantallas (AGENTS.md §6ter.3)."
