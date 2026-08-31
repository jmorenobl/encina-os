#!/usr/bin/env bash
# Encina OS - FABRICA EL REPOSITORIO APT FIRMADO DEL CANAL (D25, casilla C3).
#
#     ./imagen/fabricar-repo.sh --constructor usuario@vm-linux [--salida medios/repo]
#                               [--debs medios/cosecha-arm64] [--laboratorio <sufijo>]
#                               [--llave <clave ssh>]
#
# QUE HACE (2026-09-01, MEDICIONES.md §4.88): construye dists/encina/ con
# Packages, Release (Origin: Encina OS, Suite: encina) e InRelease FIRMADO con
# la clave del proyecto, a partir de los .deb PROPIO del manifiesto -- POR
# HUELLA: cada .deb del repositorio tiene que ser, byte a byte, el de una
# release publicada, y eso lo arbitra comprobar-propios.sh contra el
# manifiesto ANTES de mover nada. La firma ocurre EN EL CONSTRUCTOR, que es
# donde vive la clave privada (GNUPGHOME dedicado, §4.87b): la clave no viaja.
#
# El Release lleva fecha y NO es reproducible byte a byte; lo que la casilla
# C3 exige -- y este guion comprueba a los dos lados (trampa 24) -- es que los
# .deb si lo sean, por huella contra el manifiesto.
#
# CON --laboratorio <sufijo> fabrica en su lugar el REPO DE PRUEBA de la
# medicion: un solo encina-branding reempaquetado con dpkg-deb a
# <version>+<sufijo> (el patron P2 de §4.84e: solo cambia Version:), firmado
# con la MISMA clave. Es el actor del «full-upgrade trae una mas alta» y NO SE
# PUBLICA NUNCA: sirve para medir el canal por HTTP local antes de que exista
# el remoto.
#
# Este guion NO SUBE NADA: la subida es ./imagen/subir-sourceforge.sh --repo,
# y el acto irreversible (--de-verdad) es de Jorge.
#
# MODELO DE SALIDA: ABORTAR (tarea 2, §4.67): morir() al primer problema.
set -uo pipefail
export LC_ALL=C

AQUI=$(cd "$(dirname "$0")" && pwd)
RAIZ=$(cd "$AQUI/.." && pwd)
CONSTRUCTOR=""; SALIDA=""; LABORATORIO=""; LLAVE=""
SUITE="encina"; ORIGEN="Encina OS"; COMPONENTE="main"; ARQS="arm64 amd64"
HUELLA_ENCINA="58A525AB990C4B8DC5AB3D240A007E6F65F8C7EF"
# la clave PUBLICA que viaja en encina-keyring: contra ella se verifica la firma
PUBLICA="$RAIZ/debian-packages/encina-keyring/src/usr/share/keyrings/encina-archive-keyring.gpg"
# los .deb salen de LA COSECHA PUBLICADA (la de 'make cosecha', cotejada con el
# medio vigente): es lo publicado por huella, que es lo unico que entra al canal.
# debian-packages/ no vale de fuente: el de autofirma no se construye aqui.
DEBS="$RAIZ/medios/cosecha-arm64"

uso() { sed -n '4,5p' "$0"; exit 2; }
while [ $# -gt 0 ]; do
    case "$1" in
        --constructor) CONSTRUCTOR="$2"; shift 2 ;;
        --salida)      SALIDA="$2";      shift 2 ;;
        --debs)        DEBS="$2";        shift 2 ;;
        --laboratorio) LABORATORIO="$2"; shift 2 ;;
        --llave)       LLAVE="$2";       shift 2 ;;
        -h|--help)     sed -n '1,28p' "$0"; exit 0 ;;
        *) echo "[FALLO] argumento desconocido: $1"; uso ;;
    esac
done
[ -n "$CONSTRUCTOR" ] || uso
if [ -z "$SALIDA" ]; then
    if [ -n "$LABORATORIO" ]; then SALIDA="$RAIZ/medios/repo-laboratorio"; else SALIDA="$RAIZ/medios/repo"; fi
fi
. "$RAIZ/lib/salida.sh"

SSH_OPTS=(-o StrictHostKeyChecking=no -o ConnectTimeout=8 -o BatchMode=yes)
[ -n "$LLAVE" ] && SSH_OPTS+=(-i "$LLAVE")
R() { ssh "${SSH_OPTS[@]}" "$CONSTRUCTOR" "$@"; }

command -v shasum >/dev/null || morir "no hay shasum en esta maquina"
[ -f "$PUBLICA" ] || morir "no esta la clave publica del paquete: $PUBLICA"

# ============================================================================
titulo "1. los .deb, por huella: comprobar-propios.sh arbitra contra el manifiesto"

# los PROPIO de los DOS manifiestos tienen que ser los mismos ficheros con las
# mismas huellas: el repositorio es uno y sirve a las dos arquitecturas
M1="$AQUI/repo-manifiesto.tsv"; M2="$AQUI/repo-manifiesto-amd64.tsv"
for m in "$M1" "$M2"; do [ -f "$m" ] || morir "no esta el manifiesto $m"; done
P1=$(awk -F'\t' '$1=="PROPIO" {print $4"\t"$5"\t"$6}' "$M1" | sort)
P2=$(awk -F'\t' '$1=="PROPIO" {print $4"\t"$5"\t"$6}' "$M2" | sort)
[ "$P1" = "$P2" ] || morir "los PROPIO de los dos manifiestos NO coinciden:
$(diff <(echo "$P1") <(echo "$P2") || true)"
ok "los PROPIO de repo-manifiesto.tsv y repo-manifiesto-amd64.tsv son los mismos ficheros y huellas"

PAQUETES=$(awk -F'\t' '$1=="PROPIO" {print $2}' "$M1")
[ -n "$PAQUETES" ] || morir "el manifiesto no tiene ninguna fila PROPIO"
[ -d "$DEBS" ] || morir "no existe el directorio de .deb: $DEBS (make cosecha, o --debs)"
for p in $PAQUETES; do
    if salida=$("$AQUI/comprobar-propios.sh" "$p" --dir "$DEBS" 2>&1); then
        ok "$p: comprobar-propios.sh en verde ($(echo "$salida" | sed -n 's/.*\[OK\][[:space:]]*//p' | head -1))"
    else
        morir "$p NO cuadra con el manifiesto:
$(echo "$salida" | tail -12)"
    fi
done

# ============================================================================
titulo "2. lo que viaja al constructor (la clave privada NO: ya vive alli)"

ETAPA=$(mktemp -d) || morir "mktemp"
trap 'rm -rf "$ETAPA"' EXIT
mkdir -p "$ETAPA/debs"
if [ -n "$LABORATORIO" ]; then
    # el actor del laboratorio: SOLO encina-branding, que el constructor
    # reempaquetara a <version>+<sufijo> (P2, §4.84e)
    FICHERO_B=$(awk -F'\t' '$1=="PROPIO" && $2=="encina-branding" {print $4}' "$M1")
    VERSION_B=$(awk -F'\t' '$1=="PROPIO" && $2=="encina-branding" {print $3}' "$M1")
    [ -n "$FICHERO_B" ] || morir "el manifiesto no tiene fila PROPIO de encina-branding"
    cp "$DEBS/$FICHERO_B" "$ETAPA/debs/" || morir "cp de $FICHERO_B"
    echo "        laboratorio: encina-branding $VERSION_B -> $VERSION_B+$LABORATORIO (solo cambia Version:)"
else
    for f in $(awk -F'\t' '$1=="PROPIO" {print $4}' "$M1"); do
        cp "$DEBS/$f" "$ETAPA/debs/" || morir "cp de $f"
    done
fi
cp "$PUBLICA" "$ETAPA/encina-archive-keyring.gpg" || morir "cp de la clave publica"
N_DEBS=$(/bin/ls "$ETAPA/debs" | grep -c '\.deb$')
ok "en la etapa: $N_DEBS .deb y la clave publica del paquete"

R "rm -rf .encina-fabricar-repo && mkdir -p .encina-fabricar-repo" \
    || morir "no puedo preparar el directorio remoto en $CONSTRUCTOR"
# trampa 24: TODO tar que sale del Mac lleva COPYFILE_DISABLE=1 (los ._* de
# AppleDouble costaron un lintian con 2 errores en §4.87f)
( cd "$ETAPA" && COPYFILE_DISABLE=1 tar --no-xattrs -cf - debs encina-archive-keyring.gpg ) \
    | R "tar -xf - -C .encina-fabricar-repo" || morir "el tar Mac -> constructor fallo"
ok "los ficheros estan en el constructor (COPYFILE_DISABLE=1)"

# ============================================================================
titulo "3. EN EL CONSTRUCTOR: indices, Release e InRelease firmado (la clave no viaja)"

GUION_REMOTO="$ETAPA/remoto.sh"
cat > "$GUION_REMOTO" <<FIN
set -euo pipefail
export LC_ALL=C
cd ~/.encina-fabricar-repo
for h in apt-ftparchive gpg gpgv dpkg-deb gzip; do
    command -v "\$h" >/dev/null || { echo "[FALLO] falta \$h en el constructor"; exit 1; }
done

# la clave privada: presente y con LA huella de D25, o nada
H=\$(GNUPGHOME=~/.gnupg-encina gpg --list-secret-keys --with-colons 2>/dev/null | awk -F: '/^fpr:/ {print \$10; exit}')
[ "\$H" = "$HUELLA_ENCINA" ] || { echo "[FALLO] la clave secreta del constructor no es la de D25: \${H:-ninguna}"; exit 1; }
echo "[remoto] clave secreta presente: \$H"

if [ -n "$LABORATORIO" ]; then
    # P2 (§4.84e): reempaquetar cambiando SOLO Version:. Para medir el
    # comportamiento de apt la version es lo unico que juega.
    DEB=\$(ls debs/encina-branding_*.deb)
    dpkg-deb -R "\$DEB" x
    V=\$(sed -n 's/^Version: //p' x/DEBIAN/control)
    sed -i "s/^Version: .*/Version: \$V+$LABORATORIO/" x/DEBIAN/control
    grep -q "^Version: \$V+$LABORATORIO\$" x/DEBIAN/control || { echo "[FALLO] la version no cambio"; exit 1; }
    rm "\$DEB"
    dpkg-deb -b x "debs/\$(basename "\$DEB" .deb | sed "s/\${V}/\${V}+$LABORATORIO/").deb" >/dev/null
    rm -rf x
    echo "[remoto] laboratorio: \$(ls debs/)"
fi

mkdir -p salida/pool/$COMPONENTE
cp debs/*.deb salida/pool/$COMPONENTE/
cd salida
mkdir -p dists/$SUITE/$COMPONENTE/binary-arm64 dists/$SUITE/$COMPONENTE/binary-amd64
# los cuatro .deb son Architecture: all: el mismo indice describe a las dos
apt-ftparchive packages pool > dists/$SUITE/$COMPONENTE/binary-arm64/Packages
cp dists/$SUITE/$COMPONENTE/binary-arm64/Packages dists/$SUITE/$COMPONENTE/binary-amd64/Packages
N=\$(grep -c '^Package:' dists/$SUITE/$COMPONENTE/binary-arm64/Packages)
[ "\$N" -eq "$N_DEBS" ] || { echo "[FALLO] el Packages describe \$N paquetes y hay $N_DEBS .deb"; exit 1; }
for a in $ARQS; do gzip -9n -c dists/$SUITE/$COMPONENTE/binary-\$a/Packages > dists/$SUITE/$COMPONENTE/binary-\$a/Packages.gz; done
echo "[remoto] Packages: \$N paquetes, para $ARQS"

apt-ftparchive \
    -o "APT::FTPArchive::Release::Origin=$ORIGEN" \
    -o "APT::FTPArchive::Release::Label=$ORIGEN" \
    -o "APT::FTPArchive::Release::Suite=$SUITE" \
    -o "APT::FTPArchive::Release::Codename=$SUITE" \
    -o "APT::FTPArchive::Release::Architectures=$ARQS" \
    -o "APT::FTPArchive::Release::Components=$COMPONENTE" \
    release dists/$SUITE > ../Release.tmp
# el > directo dentro de dists/ crea el fichero ANTES de que apt-ftparchive
# escanee el arbol, y el Release acaba listandose a si mismo (mordido aqui)
mv ../Release.tmp dists/$SUITE/Release
grep -q "^Origin: $ORIGEN\$" dists/$SUITE/Release || { echo "[FALLO] el Release no dice Origin: $ORIGEN"; exit 1; }
grep -q "^Suite: $SUITE\$"   dists/$SUITE/Release || { echo "[FALLO] el Release no dice Suite: $SUITE"; exit 1; }

GNUPGHOME=~/.gnupg-encina gpg --batch --yes --clearsign -o dists/$SUITE/InRelease dists/$SUITE/Release
GNUPGHOME=~/.gnupg-encina gpg --batch --yes -abs      -o dists/$SUITE/Release.gpg dists/$SUITE/Release

# LA MUTACION SE VERIFICA (trampa 13), y con su control: la firma se comprueba
# con LA CLAVE PUBLICA DEL PAQUETE (la que llevara cada maquina), y un keyring
# vacio tiene que rechazarla -- sin el rojo, el verde no mide nada
if ! gpgv --keyring ~/.encina-fabricar-repo/encina-archive-keyring.gpg dists/$SUITE/InRelease 2>&1 | grep -q "Good signature"; then
    echo "[FALLO] la clave publica del paquete NO verifica el InRelease recien firmado"; exit 1
fi
echo "[remoto] InRelease verificado con la clave publica DEL PAQUETE"
if gpgv --keyring /dev/null dists/$SUITE/InRelease >/dev/null 2>&1; then
    echo "[FALLO] CONTROL ROTO: un keyring vacio dio por buena la firma"; exit 1
fi
echo "[remoto] control: un keyring vacio la rechaza"
if ! gpgv --keyring ~/.encina-fabricar-repo/encina-archive-keyring.gpg dists/$SUITE/Release.gpg dists/$SUITE/Release 2>&1 | grep -q "Good signature"; then
    echo "[FALLO] Release.gpg no verifica"; exit 1
fi
echo "[remoto] Release.gpg verificado"
FIN
R "bash -s" < "$GUION_REMOTO" | sed 's/^/        /' || morir "la construccion remota fallo"
ok "el constructor dejo el repositorio firmado en ~/.encina-fabricar-repo/salida"

# ============================================================================
titulo "4. de vuelta al Mac, y el cotejo A LOS DOS LADOS (trampa 24)"

rm -rf "$SALIDA"; mkdir -p "$SALIDA" || morir "mkdir $SALIDA"
R "tar -cf - -C .encina-fabricar-repo/salida ." | tar -xf - -C "$SALIDA" || morir "el tar constructor -> Mac fallo"
R "rm -rf .encina-fabricar-repo" || aviso "no pude limpiar el directorio remoto"

# cada .deb del pool, por huella contra el manifiesto (la exigencia de C3);
# en el laboratorio la huella cambia A PROPOSITO y se coteja contra el remoto
for deb in "$SALIDA/pool/$COMPONENTE"/*.deb; do
    f=$(basename "$deb")
    if [ -n "$LABORATORIO" ]; then
        case "$f" in
            *"+$LABORATORIO"_*) ok "$f: el actor del laboratorio (huella nueva a proposito)" ;;
            *) morir "en el pool del laboratorio hay un fichero inesperado: $f" ;;
        esac
        continue
    fi
    ESPERADA=$(awk -F'\t' -v n="$f" '$1=="PROPIO" && $4==n {print $6}' "$M1")
    [ -n "$ESPERADA" ] || morir "$f esta en el pool y NO en el manifiesto"
    REAL=$(shasum -a 256 "$deb" | cut -d' ' -f1)
    [ "$REAL" = "$ESPERADA" ] || morir "$f llego con OTRA huella: $REAL (manifiesto: $ESPERADA)"
    ok "$f  ${REAL:0:12}… = la del manifiesto"
done
if [ -z "$LABORATORIO" ]; then
    N_POOL=$(/bin/ls "$SALIDA/pool/$COMPONENTE" | grep -c '\.deb$')
    N_MAN=$(awk -F'\t' '$1=="PROPIO"' "$M1" | grep -c .)
    [ "$N_POOL" -eq "$N_MAN" ] || morir "el pool tiene $N_POOL .deb y el manifiesto $N_MAN filas PROPIO"
fi

# el Release describe los indices que viajaron: cada linea SHA256 se recalcula
coteja_release() {  # $1 = dists/<suite>  -> rc 0 si toda linea SHA256 cuadra
    local dir="$1" fallos=0
    while read -r sha _tam fich; do
        [ -f "$dir/$fich" ] || { echo "        falta $fich"; fallos=1; continue; }
        local real; real=$(shasum -a 256 "$dir/$fich" | cut -d' ' -f1)
        [ "$real" = "$sha" ] || { echo "        $fich: $real != $sha"; fallos=1; }
    done < <(awk '/^SHA256:/{en=1;next} /^[A-Z]/{en=0} en&&NF==3{print}' "$dir/Release")
    return $fallos
}
if coteja_release "$SALIDA/dists/$SUITE"; then
    ok "toda linea SHA256 del Release cuadra con los indices que llegaron"
else
    morir "el Release NO describe los indices que llegaron"
fi
# el control del cotejo: un byte anadido a una copia se tiene que notar
CTRL=$(mktemp -d) || morir "mktemp"
cp -R "$SALIDA/dists/$SUITE" "$CTRL/d"
printf 'x' >> "$CTRL/d/$COMPONENTE/binary-arm64/Packages"
if coteja_release "$CTRL/d" >/dev/null 2>&1; then
    morir "CONTROL ROTO: el cotejo no ve un Packages con un byte de mas"
fi
rm -rf "$CTRL"
ok "control: el mismo cotejo, sobre un Packages saboteado, da rojo"

# y el Packages describe los .deb del pool, por huella
while read -r campo valor; do
    case "$campo" in
        Filename:) FICH_P="$valor" ;;
        SHA256:)
            [ -f "$SALIDA/$FICH_P" ] || morir "el Packages nombra $FICH_P y no esta en el pool"
            REAL=$(shasum -a 256 "$SALIDA/$FICH_P" | cut -d' ' -f1)
            [ "$REAL" = "$valor" ] || morir "$FICH_P: el Packages dice $valor y el fichero da $REAL"
            ;;
    esac
done < <(awk '$1=="Filename:"||$1=="SHA256:"' "$SALIDA/dists/$SUITE/$COMPONENTE/binary-arm64/Packages")
ok "todo Filename del Packages existe en el pool y su SHA256 cuadra"

echo
echo "repositorio en $SALIDA (la firma, verificada en el constructor con la clave publica del paquete)"
if [ -n "$LABORATORIO" ]; then
    echo "ES EL DEL LABORATORIO: no se publica. Se sirve por HTTP local para medir (§4.88)."
else
    echo "ensayo de subida:  ./imagen/subir-sourceforge.sh --repo $SALIDA"
    echo "la subida real (--de-verdad) es de Jorge: publica el canal ANTES que la clave (D25)."
fi
resumen
