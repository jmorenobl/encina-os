#!/usr/bin/env bash
# Encina OS - LO QUE SE PUBLICA, EN UN DIRECTORIO Y CON SUS SUMAS CALCULADAS.
#
#     ./imagen/preparar-publicacion.sh --medios <dir> --salida <dir>
#                                      [--url-base <URL>] [--plantilla <md>]
#
# QUE HACE (2026-08-29, MEDICIONES.md §4.82, tareas/alojamiento.md y
# tareas/publicar.md): junta en --salida lo que la release lleva --las dos
# ISOs, las dos cosechas (encina-repo-<arq>.tar, 'make cosecha')--, calcula
# ahi su SHA256SUMS, y escribe NOTAS.md desde la plantilla sustituyendo las
# huellas, los tamanos, las versiones y el commit DESDE ESOS FICHEROS: ninguna
# huella de las notas se escribe a mano, porque este repositorio ya apunto una
# vez una huella por el nombre de la VM y no por el fichero (TAREAS.md).
#
# LO QUE NO HACE: subir nada a ningun sitio. Donde vive la ISO lo decide Jorge
# (tareas/alojamiento.md); --url-base es la URL bajo la que quedaran los
# ficheros, y sin ella las notas llevan «<URL-PENDIENTE>» y se avisa.
#
# LOS CONTROLES VAN DELANTE de lo que protegen: 'shasum -c' sobre el
# SHA256SUMS recien escrito tiene que pasar, y con una huella cambiada en un
# caracter tiene que FALLAR; y en NOTAS.md no puede quedar ningun «@…@».
#
# MODELO DE SALIDA: ABORTAR (tarea 2, MEDICIONES.md §4.67): morir() al primer
# problema, como el resto de imagen/.
set -uo pipefail
export LC_ALL=C

AQUI=$(cd "$(dirname "$0")" && pwd)
RAIZ=$(cd "$AQUI/.." && pwd)
MEDIOS=""; SALIDA=""; URL_BASE=""; PLANTILLA="$RAIZ/publicar/notas-plantilla.md"
MANIFIESTO="$AQUI/repo-manifiesto.tsv"

uso() { sed -n '2,5p' "$0"; exit 2; }
while [ $# -gt 0 ]; do
    case "$1" in
        --medios)    MEDIOS="$2";    shift 2 ;;
        --salida)    SALIDA="$2";    shift 2 ;;
        --url-base)  URL_BASE="$2";  shift 2 ;;
        --plantilla) PLANTILLA="$2"; shift 2 ;;
        -h|--help)   sed -n '1,22p' "$0"; exit 0 ;;
        *) echo "[FALLO] argumento desconocido: $1"; uso ;;
    esac
done
[ -n "$MEDIOS" ] && [ -n "$SALIDA" ] || uso

. "$RAIZ/lib/salida.sh"

[ -d "$MEDIOS" ]     || morir "no existe $MEDIOS"
[ -f "$PLANTILLA" ]  || morir "no existe la plantilla: $PLANTILLA"
[ -f "$MANIFIESTO" ] || morir "no existe el manifiesto: $MANIFIESTO"
FICHEROS="encina-os-arm64.iso encina-os-amd64.iso encina-repo-arm64.tar encina-repo-amd64.tar"

# --- 0. el commit desde el que se reproduce, y el arbol limpio ---------------
titulo "0. desde que commit se reproduce lo que se publica"
cd "$RAIZ" || morir "no pude entrar en $RAIZ"
COMMIT=$(git rev-parse HEAD 2>/dev/null) || morir "$RAIZ no es un repositorio git"
SUCIO=$(git status --porcelain | wc -l | tr -d ' ')
[ "$SUCIO" -eq 0 ] || morir "el arbol tiene $SUCIO cambios sin confirmar: las notas dirian un commit que no es lo que hay"
echo "        commit  $COMMIT"
ok "arbol limpio en $COMMIT"

# --- 1. los ficheros, enlazados (o copiados) a --salida ----------------------
titulo "1. los cuatro ficheros"
for f in $FICHEROS; do
    [ -f "$MEDIOS/$f" ] || morir "falta $MEDIOS/$f (make dos-veces / make cosecha)"
done
rm -rf "$SALIDA"; mkdir -p "$SALIDA" || morir "no pude crear $SALIDA"
for f in $FICHEROS; do
    ln "$MEDIOS/$f" "$SALIDA/$f" 2>/dev/null || cp -c "$MEDIOS/$f" "$SALIDA/$f" || cp "$MEDIOS/$f" "$SALIDA/$f" \
        || morir "no pude poner $f en $SALIDA"
    echo "        $(stat -f %z "$SALIDA/$f") bytes  $f"
done
ok "los cuatro ficheros estan en $SALIDA"

# --- 2. SHA256SUMS, calculado, y su control ---------------------------------
titulo "2. SHA256SUMS calculado en $SALIDA"
# shellcheck disable=SC2086
( cd "$SALIDA" && shasum -a 256 $FICHEROS > SHA256SUMS ) || morir "shasum"
sed 's/^/        /' "$SALIDA/SHA256SUMS"
( cd "$SALIDA" && shasum -a 256 -c SHA256SUMS >/dev/null 2>&1 ) || morir "shasum -c NO pasa sobre el SHA256SUMS recien escrito"
ok "shasum -a 256 -c SHA256SUMS pasa"
# EL CONTROL: con una huella cambiada en un caracter, 'shasum -c' tiene que fallar
sed '1s/^./X/' "$SALIDA/SHA256SUMS" > "$SALIDA/.SHA256SUMS.sab"
cmp -s "$SALIDA/SHA256SUMS" "$SALIDA/.SHA256SUMS.sab" && morir "CONTROL ROTO: el sabotaje no saboteo"
if ( cd "$SALIDA" && shasum -a 256 -c .SHA256SUMS.sab >/dev/null 2>&1 ); then
    morir "CONTROL ROTO: shasum -c pasa con una huella cambiada"
fi
rm -f "$SALIDA/.SHA256SUMS.sab"
ok "control: con una huella cambiada en un caracter, shasum -c falla"

# --- 3. las notas, desde la plantilla y desde los ficheros -------------------
titulo "3. NOTAS.md desde $(basename "$PLANTILLA"), con las huellas de SHA256SUMS"
huella() { awk -v f="$1" '$2==f {print $1}' "$SALIDA/SHA256SUMS"; }
tamano() { stat -f %z "$SALIDA/$1"; }
version_de() { awk -F'\t' -v p="$1" '$1=="PROPIO" && $2==p {print $3}' "$MANIFIESTO"; }
for p in encina-branding encina-firefox-native encina-meta autofirma; do
    [ -n "$(version_de "$p")" ] || morir "el manifiesto no tiene la version de $p"
done
[ -n "$URL_BASE" ] || { URL_BASE="<URL-PENDIENTE>"; aviso "sin --url-base: las notas llevan <URL-PENDIENTE> (tareas/alojamiento.md)"; }
sed -e "s|@VERSION@|$(version_de encina-meta)|g" \
    -e "s|@COMMIT@|$COMMIT|g" \
    -e "s|@FECHA@|$(date +%Y-%m-%d)|g" \
    -e "s|@URL_BASE@|$URL_BASE|g" \
    -e "s|@V_BRANDING@|$(version_de encina-branding)|g" \
    -e "s|@V_FIREFOX_NATIVE@|$(version_de encina-firefox-native)|g" \
    -e "s|@V_META@|$(version_de encina-meta)|g" \
    -e "s|@V_AUTOFIRMA@|$(version_de autofirma)|g" \
    -e "s|@SHA_ISO_ARM64@|$(huella encina-os-arm64.iso)|g"   -e "s|@TAM_ISO_ARM64@|$(tamano encina-os-arm64.iso)|g" \
    -e "s|@SHA_ISO_AMD64@|$(huella encina-os-amd64.iso)|g"   -e "s|@TAM_ISO_AMD64@|$(tamano encina-os-amd64.iso)|g" \
    -e "s|@SHA_REPO_ARM64@|$(huella encina-repo-arm64.tar)|g" -e "s|@TAM_REPO_ARM64@|$(tamano encina-repo-arm64.tar)|g" \
    -e "s|@SHA_REPO_AMD64@|$(huella encina-repo-amd64.tar)|g" -e "s|@TAM_REPO_AMD64@|$(tamano encina-repo-amd64.tar)|g" \
    "$PLANTILLA" > "$SALIDA/NOTAS.md" || morir "sed sobre la plantilla"
# EL CONTROL: ningun marcador sin sustituir
QUEDAN=$(grep -o '@[A-Z_0-9]*@' "$SALIDA/NOTAS.md" | sort -u | tr '\n' ' ')
[ -z "$QUEDAN" ] || morir "en NOTAS.md quedan marcadores sin sustituir: $QUEDAN"
# y que cada huella del SHA256SUMS este en las notas: una release cuyas notas
# no dicen la huella del fichero es una ISO sin huella al lado
for f in $FICHEROS; do
    grep -q "$(huella "$f")" "$SALIDA/NOTAS.md" || morir "NOTAS.md no lleva la huella de $f"
done
ok "NOTAS.md: $(wc -l < "$SALIDA/NOTAS.md" | tr -d ' ') lineas, las cuatro huellas dentro y ningun marcador suelto"

echo
echo "listo en $SALIDA:"
ls -l "$SALIDA" | sed 's/^/        /'
echo
echo "LO QUE ESTE GUION NO HACE: subirlo. Donde vive la ISO es de tareas/alojamiento.md."
