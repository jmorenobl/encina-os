#!/usr/bin/env bash
# Encina OS - Bloque 0. TRAE LA ISO OFICIAL DE UBUNTU, Y LA COMPRUEBA CONTRA LA
# FIRMA DE CANONICAL.
#
#     ./traer-iso-oficial.sh [--arq arm64|amd64] [--medios <dir>]
#                            [--verificador usuario@maquina] [--respaldo <URL>|--sin-respaldo]
#
# POR QUE EXISTE: la ISO oficial es LA ENTRADA de fabricar-iso.sh y es el unico
# insumo del producto que no viaja en el clon -- son 3,3 GiB, no caben en git y
# no tienen por que estar ahi. Lo que si tiene que estar es LA ORDEN de traerla
# y, sobre todo, EL INSTRUMENTO QUE SABE DECIR QUE YA NO ESTA.
#
# LAS TRES RESPUESTAS, como en cosechar-repo.sh:
#     [OK]        la ISO esta y sus bytes son los que Canonical firma
#     [RETIRADO]  el SHA256SUMS firmado de hoy YA NO CONTIENE esa huella. Es un
#                 HALLAZGO, no un contratiempo: Canonical retira los point
#                 releases viejos de 'releases/' cuando sale el siguiente. Este
#                 guion NO coge la version nueva por su cuenta -- eso cambiaria
#                 lo que el producto lleva, y es una decision de producto.
#     [OTROS BYTES] el fichero local existe con ese nombre y NO es el firmado
#     [RESPALDO]  (2026-08-30, MEDICIONES.md §4.83, trampa 69) el servidor de
#                 Canonical la ha retirado -- o no contesta -- y la ISO se coge del
#                 RESPALDO de la tabla de fabricar-iso.sh (cuarta columna): para
#                 amd64, old-releases.ubuntu.com, que conserva los point releases
#                 con su SHA256SUMS firmado; para arm64, que Canonical NO
#                 conserva, nuestra copia en SourceForge JUNTO AL SHA256SUMS Y AL
#                 SHA256SUMS.gpg DE CANONICAL de aquel dia (imagen/base-firmada/).
#                 El respaldo pasa EXACTAMENTE por los mismos pasos que el
#                 servidor: la firma de Canonical con su control negativo, la
#                 huella dentro del fichero firmado, y la ISO cotejada al llegar.
#                 Lo que no cambia es la regla: NO se coge una version nueva.
#
# POR QUE CONTRA LA FIRMA Y NO CONTRA EL SHA256SUMS A SECAS: ese fichero se baja
# del MISMO sitio que la ISO, asi que comprobar uno con el otro no es un control
# independiente -- quien pudiera cambiar la ISO podria cambiar el SHA256SUMS. La
# firma la hace una clave que ya esta en el sistema, dentro del paquete
# 'ubuntu-keyring', y no hay que bajarla de ningun servidor de claves.
#
# MACOS NO TRAE gpg. Si no lo hay aqui, se verifica por ssh en una maquina que
# si (--verificador jorge@192.168.64.3, o sea encina-dev). Y si no hay ninguna
# de las dos cosas, EL GUION LO DICE A GRITOS en vez de fingir que comprobo:
# quedarse solo con la huella es exactamente el control que NO es independiente.
#
# LA HUELLA NO SE ESCRIBE AQUI. Se lee de imagen/fabricar-iso.sh, que es quien
# la exige, para que no puedan separarse. Y el NOMBRE del fichero tampoco se
# escribe: se DEDUCE buscando esa huella dentro del SHA256SUMS firmado, que es
# lo que permite distinguir [RETIRADO] de [OTROS BYTES].
#
# EL SERVIDOR TAMPOCO SE ESCRIBE AQUI, y eso es del 2026-08-22 (§4.64 P1): la
# prediccion decia que la ISO amd64 estaria en el mismo directorio de cdimage
# que la arm64 y ES FALSO -- cdimage.ubuntu.com/ubuntu/releases sirve arm64,
# ppc64el, riscv64 y s390x, y amd64 vive en releases.ubuntu.com/24.04 --. Asi
# que la direccion va en la MISMA tabla de fabricar-iso.sh que la huella, por
# arquitectura, y aqui no hay ninguna escrita. Lo que NO cambia es la confianza:
# los dos servidores firman con la misma «Ubuntu CD Image Automatic Signing Key
# (2012)», medido con su control negativo.

# MODELO DE SALIDA: ABORTAR (tarea 2, MEDICIONES.md §4.67). Este guion no
# cuenta ni resume: el primer problema lo para, y la palabra es morir(), que
# escribe [FALLO] por stderr y sale con 1. Hasta el 2026-08-28 esa misma
# funcion se llamaba fallo(), igual que la que en lib.sh APUNTA Y SIGUE; la
# misma palabra para dos flujos de control opuestos es lo que la tarea 2 quita.
# El 'set' de abajo es el que este guion ya tenia y no se ha unificado con el
# de lib.sh: cambiar las opciones de shell de un guion sin ejecutarlo entero
# seria una mutacion sin verificar.
set -uo pipefail
export LC_ALL=C   # trampa 2: la salida de las herramientas, sin traducir

AQUI=$(cd "$(dirname "$0")" && pwd)
RAIZ=$(cd "$AQUI/.." && pwd)
MEDIOS="$RAIZ/medios"
VERIFICADOR=""
LLAVE=""
BASE=""      # sale de la tabla de fabricar-iso.sh; --base solo para diagnostico
RESPALDO=""  # idem, cuarta columna; --respaldo <URL> lo cambia, --sin-respaldo lo quita
ARQ=arm64

uso() { sed -n '2,5p' "$0"; exit 2; }
while [ $# -gt 0 ]; do
    case "$1" in
        --arq)         ARQ="$2";         shift 2 ;;
        --medios)      MEDIOS="$2";      shift 2 ;;
        --verificador) VERIFICADOR="$2"; shift 2 ;;
        --llave)       LLAVE="$2";       shift 2 ;;
        --base)        BASE="$2";        shift 2 ;;
        --respaldo)    RESPALDO="$2";    shift 2 ;;
        --sin-respaldo) RESPALDO="-";    shift ;;
        -h|--help)     sed -n '1,45p' "$0"; exit 0 ;;
        *) echo "[FALLO] argumento desconocido: $1"; uso ;;
    esac
done

# EL VOCABULARIO VIENE DE lib/salida.sh (tarea 3): ok/fallo/aviso/omitido, los
# contadores N_OK/N_MAL/N_AVI/N_OMI y morir(). Este guion ya no define ninguno.
. "$AQUI/../lib/salida.sh"

command -v curl >/dev/null || morir "no hay curl"
if command -v shasum >/dev/null; then HUELLA() { shasum -a 256 "$1" | cut -d' ' -f1; }
elif command -v sha256sum >/dev/null; then HUELLA() { sha256sum "$1" | cut -d' ' -f1; }
else morir "no hay ni shasum ni sha256sum"; fi

# --- 1. la huella, leida de quien la exige ----------------------------------
echo "== 1. que ISO hace falta para $ARQ, segun quien la exige"
GUION="$AQUI/fabricar-iso.sh"
[ -f "$GUION" ] || morir "no existe $GUION"
# la tabla vive entre ISOS_OFICIALES="\ y la comilla que la cierra
# la tabla tiene CUATRO columnas desde el 2026-08-30 (arq, huella, servidor,
# respaldo); la linea que la cierra es la ultima fila con su comilla
FILA=$(sed -n '/^ISOS_OFICIALES="/,/^[a-z0-9]* [0-9a-f]\{64\} [^ ]* [^ ]*"$/p' "$GUION" \
       | sed 's/"$//' | awk -v a="$ARQ" '$1==a {print $2, $3, $4}')
H_ISO=$(printf '%s' "$FILA" | cut -d' ' -f1)
B_TABLA=$(printf '%s' "$FILA" | cut -d' ' -f2)
R_TABLA=$(printf '%s' "$FILA" | cut -d' ' -f3)
if [ ${#H_ISO} -ne 64 ]; then
    echo "[FALLO] $GUION no acepta la arquitectura «$ARQ». Las que acepta:"
    sed -n '/^ISOS_OFICIALES="/,/^[a-z0-9]* [0-9a-f]\{64\} [^ ]* [^ ]*"$/p' "$GUION" \
        | sed 's/"$//' | awk 'NF==4 {printf "          %-6s %s\n", $1, $3}'
    exit 1
fi
[ -n "$BASE" ] || BASE="$B_TABLA"
[ -n "$BASE" ] || morir "la tabla no dice de que servidor sale la ISO $ARQ"
[ -n "$RESPALDO" ] || RESPALDO="$R_TABLA"
[ "$RESPALDO" = "-" ] && RESPALDO=""
ok "fabricar-iso.sh exige ${H_ISO:0:16}…  para $ARQ, desde $BASE"
[ -n "$RESPALDO" ] && echo "        respaldo, si la han retirado: $RESPALDO"

mkdir -p "$MEDIOS" || morir "no pude crear $MEDIOS"

# --- 2, 3 y 4: LAS SUMAS FIRMADAS DE UN SERVIDOR, y que dicen de nuestra huella --
# Desde el 2026-08-30 es una funcion porque se hace hasta DOS veces -- contra el
# servidor de Canonical y, si este ya no tiene la ISO (o no contesta), contra el
# respaldo -- y las dos pasan por LOS MISMOS pasos: bajar SHA256SUMS y su .gpg,
# el sabotaje que tiene que sabotear, la firma de Canonical (aqui o en el
# verificador) con su control negativo, y la huella dentro del fichero firmado.
TMP=$(mktemp -d) || morir "mktemp"
trap 'rm -rf "$TMP"' EXIT
LLAVERO=/usr/share/keyrings/ubuntu-archive-keyring.gpg
FIRMA_COMPROBADA=0
SSH_OPTS=(-o StrictHostKeyChecking=no -o ConnectTimeout=8 -o BatchMode=yes)
[ -n "$LLAVE" ] && SSH_OPTS+=(-i "$LLAVE")
TMP_R=""
if [ -n "$VERIFICADOR" ] && ! { command -v gpgv >/dev/null && [ -f "$LLAVERO" ]; }; then
    TMP_R=$(ssh "${SSH_OPTS[@]}" "$VERIFICADOR" 'mktemp -d') \
        || morir "el verificador $VERIFICADOR no contesta por ssh"
    # shellcheck disable=SC2064  # la expansion inmediata en el trap es QUERIDA: el temporal remoto se conoce ahora y no al salir
    trap "rm -rf '$TMP'; ssh ${SSH_OPTS[*]} '$VERIFICADOR' \"rm -rf '$TMP_R'\" 2>/dev/null" EXIT
    ssh "${SSH_OPTS[@]}" "$VERIFICADOR" "[ -f $LLAVERO ]" \
        || morir "el verificador no tiene $LLAVERO (falta el paquete ubuntu-keyring)"
fi

verificar_aqui() {   # 1=directorio con SHA256SUMS.gpg  2=fichero a verificar. rc 0 si la firma es buena
    if command -v gpgv >/dev/null && [ -f "$LLAVERO" ]; then
        gpgv --keyring "$LLAVERO" "$1/SHA256SUMS.gpg" "$2" >/dev/null 2>&1
    else
        return 2
    fi
}
verificar_alli() {   # 1=etiqueta del directorio remoto  2=nombre del fichero
    ssh "${SSH_OPTS[@]}" "$VERIFICADOR" \
        "gpgv --keyring $LLAVERO $TMP_R/$1/SHA256SUMS.gpg $TMP_R/$1/$2" >/dev/null 2>&1
}

# sumas_de <URL> <etiqueta>: rc 0 si el SHA256SUMS firmado de esa URL contiene
# nuestra huella (y deja la linea en $TMP/<etiqueta>/linea); rc 3 si NO la
# contiene ([RETIRADO]); rc 4 si la URL no contesta. La firma se comprueba en
# los tres casos que llegan a tener fichero.
sumas_de() {
    local url="$1" et="$2" d="$TMP/$2" f c
    mkdir -p "$d"
    echo "== 2. el SHA256SUMS de $url y su firma"
    for f in SHA256SUMS SHA256SUMS.gpg; do
        if ! c=$(curl -fsSL -o "$d/$f" -w '%{http_code}' --max-time 120 "$url/$f"); then
            echo "        [NO CONTESTA] $url/$f (HTTP ${c:-?})"
            return 4
        fi
        echo "        $f  HTTP $c  $(wc -c <"$d/$f" | tr -d ' ') bytes"
    done

    echo "== 3. la firma de Canonical -- y su control, que va delante"
    # el sabotaje se prepara AQUI y se comprueba que sabotea (trampa de §4.37c).
    #
    # NO ES «s/^0/f/; s/^1/f/», Y ESO ESTUVO MAL HASTA EL 2026-08-22 (§4.64): ese
    # sabotaje solo mordia si ALGUNA linea empezaba por 0 o por 1, o sea que dependia
    # del contenido del fichero. Con las 32 lineas de cdimage siempre habia alguna;
    # con las SEIS de releases.ubuntu.com no hay ninguna, y el guion se planto con
    # «CONTROL ROTO: el sabotaje no cambia el fichero». Paro en vez de fingir --que
    # es lo que tenia que hacer-- pero un control que se apaga solo segun el dia no
    # es un control. Este cambia el primer caracter de la primera linea SIEMPRE, y
    # ademas por uno distinto del que hubiera.
    awk 'NR==1 { c=substr($0,1,1); print (c=="0" ? "1" : "0") substr($0,2); next } { print }' \
        "$d/SHA256SUMS" > "$d/SHA256SUMS.malo"
    cmp -s "$d/SHA256SUMS" "$d/SHA256SUMS.malo" \
        && morir "CONTROL ROTO: el sabotaje no cambia el fichero"
    if verificar_aqui "$d" "$d/SHA256SUMS"; then
        verificar_aqui "$d" "$d/SHA256SUMS.malo" \
            && morir "CONTROL ROTO: la firma da por buena una suma saboteada"
        FIRMA_COMPROBADA=1
        ok "firma correcta aqui, y el control negativo falla como debe"
    elif [ -n "$TMP_R" ]; then
        ssh "${SSH_OPTS[@]}" "$VERIFICADOR" "mkdir -p $TMP_R/$et" || morir "mkdir remoto"
        scp -q "${SSH_OPTS[@]}" "$d/SHA256SUMS" "$d/SHA256SUMS.gpg" "$d/SHA256SUMS.malo" \
            "$VERIFICADOR:$TMP_R/$et/" || morir "no pude enviar las sumas al verificador"
        verificar_alli "$et" SHA256SUMS || morir "la firma de $url NO es correcta en $VERIFICADOR"
        verificar_alli "$et" SHA256SUMS.malo \
            && morir "CONTROL ROTO: la firma da por buena una suma saboteada"
        FIRMA_COMPROBADA=1
        ok "firma correcta en $VERIFICADOR, y el control negativo falla como debe"
    else
        echo "        [AVISO] EN ESTA MAQUINA NO HAY gpgv Y NO SE HA DADO --verificador."
        echo "                Lo que viene NO es un control independiente: el SHA256SUMS"
        echo "                se baja del mismo sitio que la ISO. Para cerrarlo de verdad:"
        echo "                  brew install gnupg      (o)"
        echo "                  --verificador usuario@una-maquina-con-gpgv"
    fi

    echo "== 4. la huella que exige el guion, dentro de ese SHA256SUMS"
    grep -E "^$H_ISO \*" "$d/SHA256SUMS" > "$d/linea" || true
    if [ ! -s "$d/linea" ]; then
        echo "        [RETIRADO] el SHA256SUMS firmado de $url NO contiene ${H_ISO:0:16}…"
        echo "        Lo que ofrece hoy ese directorio para escritorio $ARQ:"
        grep -E "\\*ubuntu-[0-9.]+-desktop-${ARQ}\\.iso$" "$d/SHA256SUMS" | sed 's/^/          /'
        return 3
    fi
    return 0
}

ORIGEN=""
if sumas_de "$BASE" servidor; then
    ORIGEN="$BASE"; LINEA=$(cat "$TMP/servidor/linea")
else
    rc=$?
    [ "$rc" = 3 ] && echo "        Canonical retira los point releases viejos cuando sale el siguiente."
    if [ -n "$RESPALDO" ]; then
        echo
        echo "== 4bis. EL RESPALDO (trampa 69): $RESPALDO -- por los mismos pasos"
        if sumas_de "$RESPALDO" respaldo; then
            ORIGEN="$RESPALDO"; LINEA=$(cat "$TMP/respaldo/linea")
            echo "        [RESPALDO] la ISO se coge de $RESPALDO, con la firma de Canonical y por huella"
        else
            echo
            echo "        El respaldo tampoco la tiene (o no contesta)."
        fi
    fi
    if [ -z "$ORIGEN" ]; then
        echo
        echo "        ESTO ES UN HALLAZGO, NO UN FALLO DE ESTE GUION, y NO se coge la"
        echo "        version nueva por cuenta propia: cambiar la ISO de partida cambia"
        echo "        lo que el producto lleva y eso lo decide una persona."
        [ "$rc" = 4 ] && [ -z "$RESPALDO" ] && morir "no pude bajar $BASE/SHA256SUMS y no hay respaldo"
        exit 3
    fi
fi
NOMBRE=${LINEA##*\*}
ok "$NOMBRE  ${H_ISO:0:16}…  (nombre DEDUCIDO del fichero firmado, no escrito aqui)"

# --- 5. la ISO --------------------------------------------------------------
echo "== 5. la ISO"
DESTINO="$MEDIOS/$NOMBRE"
if [ -f "$DESTINO" ]; then
    r=$(HUELLA "$DESTINO")
    if [ "$r" = "$H_ISO" ]; then
        ok "ya estaba y sus bytes son los firmados: $DESTINO"
        echo
        echo "iso:    $DESTINO"
        echo "sha256: $H_ISO"
        [ "$FIRMA_COMPROBADA" = 1 ] \
            && echo "firma:  comprobada contra la clave de Canonical" \
            || echo "firma:  NO COMPROBADA (ver el aviso de arriba)"
        exit 0
    fi
    echo "[OTROS BYTES] $DESTINO existe y NO es el firmado"
    echo "        firmado ${H_ISO}"
    echo "        real    ${r}"
    morir "no lo sobrescribo yo: mira que es ese fichero y quitalo tu"
fi

echo "        bajando $NOMBRE  (~3,3 GiB) de $ORIGEN"
curl -fL --progress-bar -C - -o "$DESTINO.parcial" "$ORIGEN/$NOMBRE" \
    || morir "no pude bajar $ORIGEN/$NOMBRE"
r=$(HUELLA "$DESTINO.parcial")
[ "$r" = "$H_ISO" ] || { mv "$DESTINO.parcial" "$DESTINO.mala"
    morir "lo bajado NO cuadra con la huella firmada
        firmada $H_ISO
        real    $r
        se ha dejado en $DESTINO.mala en vez de borrarlo, por si hay que mirarlo"; }
mv "$DESTINO.parcial" "$DESTINO" || morir "no pude renombrar"
ok "bajada y comprobada contra la huella FIRMADA por Canonical"

echo
echo "iso:    $DESTINO"
echo "sha256: $H_ISO"
[ "$FIRMA_COMPROBADA" = 1 ] \
    && echo "firma:  comprobada contra la clave de Canonical" \
    || echo "firma:  NO COMPROBADA (ver el aviso de arriba)"
