#!/usr/bin/env bash
# Encina OS - SUBIR LO PUBLICADO A SOURCEFORGE, Y COMPROBAR QUE LLEGO.
#
#     ./imagen/subir-sourceforge.sh --directorio <medios/publicar/<version>> [--usuario <u>]
#                                   [--proyecto encina-os] [--llave <clave ssh>] [--de-verdad]
#     ./imagen/subir-sourceforge.sh --base <arq> [--medios <dir>] [--de-verdad]
#         (2026-08-30, §4.83, trampa 69): conserva en base/<arq>/ LA ISO OFICIAL de
#         Canonical que fabricar-iso.sh exige, junto al SHA256SUMS y SHA256SUMS.gpg
#         de Canonical de aquel dia (imagen/base-firmada/<arq>/). Antes de subir
#         coteja la ISO contra ESE SHA256SUMS firmado: se conserva lo que Canonical
#         firmo, o nada.
#
# QUE HACE (2026-08-29, MEDICIONES.md §4.82, tareas/cerradas/alojamiento.md): sube por
# rsync sobre ssh a frs.sourceforge.net los ficheros de --directorio (lo que
# deja 'make publicar': las dos ISOs, las dos cosechas y SHA256SUMS) a
# /home/frs/project/<proyecto>/<version>/, y DESPUES comprueba que lo que hay
# alli es lo que hay aqui: 'rsync --checksum --dry-run' de vuelta tiene que no
# querer transferir nada, y la URL canonica de cada fichero tiene que
# contestar 302 hacia un espejo (asi sirve SourceForge, §4.82h).
#
# SIN --de-verdad NO SUBE NADA: hace el rsync con --dry-run y lo dice. Publicar
# es el unico acto irreversible del proyecto (TAREAS.md), y este guion no lo da
# por hecho ni por pedido: lo da por pasado, y solo cuando lo ha visto.
#
# LA CARPETA REMOTA ES LA VERSION (0.2.1): una carpeta nueva por medio nuevo,
# nunca se pisa una; el nombre de la version es el de encina-meta y sale del
# nombre de --directorio, que es como 'make publicar' lo deja.
#
# MODELO DE SALIDA: ABORTAR (tarea 2, §4.67): morir() al primer problema.
set -uo pipefail
export LC_ALL=C

AQUI=$(cd "$(dirname "$0")" && pwd)
RAIZ=$(cd "$AQUI/.." && pwd)
DIR=""; USUARIO="jmorenobl"; PROYECTO="encina-os"; LLAVE="$HOME/.ssh/sourceforge-encina"; DE_VERDAD=0
BASE_ARQ=""; MEDIOS="$RAIZ/medios"
uso() { sed -n '2,5p' "$0"; exit 2; }
while [ $# -gt 0 ]; do
    case "$1" in
        --directorio) DIR="$2";      shift 2 ;;
        --usuario)    USUARIO="$2";  shift 2 ;;
        --proyecto)   PROYECTO="$2"; shift 2 ;;
        --llave)      LLAVE="$2";    shift 2 ;;
        --de-verdad)  DE_VERDAD=1;   shift ;;
        --base)       BASE_ARQ="$2"; shift 2 ;;
        --medios)     MEDIOS="$2";   shift 2 ;;
        -h|--help)    sed -n '1,22p' "$0"; exit 0 ;;
        *) echo "[FALLO] argumento desconocido: $1"; uso ;;
    esac
done
[ -n "$DIR" ] || [ -n "$BASE_ARQ" ] || uso
. "$RAIZ/lib/salida.sh"

[ -f "$LLAVE" ] || morir "no existe la clave $LLAVE (registra su .pub en SourceForge: Account settings > SSH Settings)"
REMOTO="$USUARIO@frs.sourceforge.net"
SSH="ssh -i $LLAVE -o BatchMode=yes -o ConnectTimeout=20 -o StrictHostKeyChecking=accept-new"

if [ -n "$BASE_ARQ" ]; then
    # --- LA BASE: la ISO oficial, con las sumas firmadas de Canonical de aquel dia --
    FIRMADA="$RAIZ/imagen/base-firmada/$BASE_ARQ"
    [ -f "$FIRMADA/SHA256SUMS" ] && [ -f "$FIRMADA/SHA256SUMS.gpg" ] \
        || morir "no hay SHA256SUMS y SHA256SUMS.gpg de Canonical en $FIRMADA"
    # la huella la exige fabricar-iso.sh (la misma tabla que lee traer-iso-oficial.sh)
    H_ISO=$(sed -n '/^ISOS_OFICIALES="/,/^[a-z0-9]* [0-9a-f]\{64\} [^ ]* [^ ]*"$/p' "$RAIZ/imagen/fabricar-iso.sh" \
            | sed 's/"$//' | awk -v a="$BASE_ARQ" '$1==a {print $2}')
    [ ${#H_ISO} -eq 64 ] || morir "fabricar-iso.sh no tiene huella de ISO oficial para $BASE_ARQ"
    LINEA=$(grep -E "^$H_ISO \*" "$FIRMADA/SHA256SUMS" || true)
    [ -n "$LINEA" ] || morir "el SHA256SUMS firmado de $FIRMADA no contiene la huella que exige fabricar-iso.sh: no es el de aquel dia"
    NOMBRE=${LINEA##*\*}
    [ -f "$MEDIOS/$NOMBRE" ] || morir "no esta $MEDIOS/$NOMBRE (./imagen/traer-iso-oficial.sh --arq $BASE_ARQ)"
    DIR=$(mktemp -d) || morir "mktemp"
    trap 'rm -rf "$DIR"' EXIT
    ln "$MEDIOS/$NOMBRE" "$DIR/$NOMBRE" 2>/dev/null || cp -c "$MEDIOS/$NOMBRE" "$DIR/$NOMBRE" || cp "$MEDIOS/$NOMBRE" "$DIR/$NOMBRE" || morir "cp"
    cp "$FIRMADA/SHA256SUMS" "$FIRMADA/SHA256SUMS.gpg" "$DIR/" || morir "cp de las sumas firmadas"
    FICHEROS="$NOMBRE SHA256SUMS SHA256SUMS.gpg"
    RUTA="/home/frs/project/$PROYECTO/base/$BASE_ARQ"
    CANONICA="https://downloads.sourceforge.net/project/$PROYECTO/base/$BASE_ARQ"
    titulo "0. la base $BASE_ARQ, cotejada contra el SHA256SUMS FIRMADO por Canonical antes de subir nada"
    r=$(shasum -a 256 "$DIR/$NOMBRE" | cut -d' ' -f1)
    [ "$r" = "$H_ISO" ] || morir "$NOMBRE NO es el firmado: real $r, firmado $H_ISO"
    ok "$NOMBRE  $H_ISO  = la linea del SHA256SUMS firmado (y la que exige fabricar-iso.sh)"
    echo "        (la firma .gpg de esas sumas se comprueba con gpgv donde lo haya: traer-iso-oficial.sh --verificador)"
else
    [ -d "$DIR" ] || morir "no existe $DIR (make publicar)"
    VERSION=$(basename "$DIR")
    case "$VERSION" in [0-9]*.[0-9]*) ;; *) morir "el directorio tiene que llamarse como la version (0.2.1): $DIR" ;; esac
    # y desde la tarde del 2026-08-29 (§4.82h), los dos .torrent con web seed a SourceForge ('make torrent')
    FICHEROS="encina-os-arm64.iso encina-os-amd64.iso encina-repo-arm64.tar encina-repo-amd64.tar encina-os-arm64.iso.torrent encina-os-amd64.iso.torrent SHA256SUMS"
    for f in $FICHEROS; do [ -f "$DIR/$f" ] || morir "falta $DIR/$f"; done
    RUTA="/home/frs/project/$PROYECTO/$VERSION"
    CANONICA="https://downloads.sourceforge.net/project/$PROYECTO/$VERSION"
    titulo "0. lo que se va a subir, y a donde"
    ( cd "$DIR" && shasum -a 256 -c SHA256SUMS ) | sed 's/^/        /' || morir "SHA256SUMS no cuadra con los ficheros de $DIR"
    ok "los seis ficheros cuadran con su SHA256SUMS"
fi
echo "        destino  $REMOTO:$RUTA/"
echo "        canonica $CANONICA/<fichero>"

titulo "1. la via de subida contesta"
rsync --list-only -e "$SSH" "$REMOTO:/home/frs/project/$PROYECTO/" > /dev/null 2>&1 \
    || morir "rsync no puede listar /home/frs/project/$PROYECTO/ como $USUARIO: ¿la clave $LLAVE esta registrada en SourceForge?"
ok "frs.sourceforge.net lista /home/frs/project/$PROYECTO/ con la clave $LLAVE"

if [ "$DE_VERDAD" = 0 ]; then
    titulo "2. ENSAYO (--dry-run): lo que rsync haria"
    # shellcheck disable=SC2086  # FICHEROS son siete nombres fijos sin espacios: se quiere que se partan
    ( cd "$DIR" && rsync -av --dry-run --progress -e "$SSH" $FICHEROS "$REMOTO:$RUTA/" ) | sed 's/^/        /'
    echo
    echo "NO SE HA SUBIDO NADA. Con --de-verdad se sube, y es el acto irreversible: esa orden la da Jorge."
    exit 0
fi

titulo "2. LA SUBIDA (--de-verdad)"
# rsync solo crea EL ULTIMO nivel del destino; base/<arq>/ son dos, el openrsync
# de macOS no tiene --mkpath y frs no admite mkdir por ssh (la primera subida de
# la base murio con «unexpected end of file … child exited with status 11»,
# §4.83c). El padre se crea subiendo un directorio vacio.
if [ -n "$BASE_ARQ" ]; then
    VACIO=$(mktemp -d) || morir "mktemp"
    rsync -a -e "$SSH" "$VACIO/" "$REMOTO:/home/frs/project/$PROYECTO/base/" 2>/dev/null \
        || morir "no pude crear /home/frs/project/$PROYECTO/base/"
    rmdir "$VACIO"
    echo "        creado (o ya estaba) /home/frs/project/$PROYECTO/base/"
fi
# shellcheck disable=SC2086  # FICHEROS son siete nombres fijos sin espacios: se quiere que se partan
( cd "$DIR" && rsync -av --partial --progress -e "$SSH" $FICHEROS "$REMOTO:$RUTA/" ) | sed 's/^/        /' \
    || morir "rsync fallo (se puede relanzar: --partial conserva lo subido)"
ok "rsync termino"

titulo "3. lo que hay ALLI contra lo que hay AQUI (trampa 13: la mutacion se verifica)"
# rsync --checksum --dry-run de vuelta: si quisiera transferir algo, algo difiere
# shellcheck disable=SC2086  # idem
DIFIEREN=$( cd "$DIR" && rsync -ac --dry-run --out-format='%n' -e "$SSH" $FICHEROS "$REMOTO:$RUTA/" | grep -c . )
[ "$DIFIEREN" -eq 0 ] || morir "rsync --checksum querria volver a transferir $DIFIEREN fichero(s): lo de alli no es lo de aqui"
ok "rsync --checksum no quiere transferir nada: los ficheros son los mismos bytes a los dos lados"
echo "        (SourceForge tarda unos minutos en repartir a los espejos; la URL canonica se comprueba abajo)"

titulo "4. la URL canonica de cada fichero"
for f in $FICHEROS; do
    codigo=$(curl -sS -o /dev/null -w '%{http_code}' --max-time 30 "$CANONICA/$f")
    case "$codigo" in
        302|200) echo "        $codigo  $CANONICA/$f" ;;
        *)       echo "        $codigo  $CANONICA/$f   <- aun no, o no esta: mirar en unos minutos"; N_AVI=$((N_AVI+1)) ;;
    esac
done
echo
echo "Lo que este guion NO comprueba: que la descarga entera desde la canonica de la huella"
echo "(eso es bajarla, 3,5 GB, y shasum -c; y el torrent con aria2c sin pares, §4.82h)."
