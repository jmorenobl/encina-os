#!/usr/bin/env bash
# Encina OS - Comprueba que un .deb RECIEN CONSTRUIDO es byte a byte el que
# imagen/repo-manifiesto.tsv nombra.
#
#     ./imagen/comprobar-propios.sh <paquete> [--dir <dir>] [--manifiesto <tsv>]
#
# POR QUE EXISTE: la CI construia los tres paquetes y subia los .deb como
# artefacto SIN MIRARLOS. Un artefacto no es una comprobacion: se puede subir
# un paquete con otros bytes y la CI sigue verde. Aqui se compara contra el
# manifiesto, que es LA FUENTE de esa lista (§4.36, §4.37g) y no una lista
# escrita a mano en el YAML.
#
# LO QUE DE VERDAD SE ESTA MIDIENDO no es que el guion de construccion funcione
# -- eso ya lo dicen sus propias comprobaciones -- sino que la construccion es
# REPRODUCIBLE EN OTRA MAQUINA. Las huellas del manifiesto se midieron en
# encina-dev, que es arm64; el runner de GitHub es amd64. Los tres paquetes son
# Architecture: all, asi que DEBERIAN salir iguales, y 'deberian' es
# exactamente lo que resulto falso el 2026-08-12 (§4.37d).
#
# LAS TRES RESPUESTAS que sabe dar, y todas hacen falta:
#     [OK]        la huella y el tamano cuadran con el manifiesto
#     [HALLAZGO]  no cuadran -> imprime el desglose de §4.37d (miembros del ar,
#                 control.tar y data.tar por separado, listado con fechas y
#                 modos, y huella del CONTENIDO aparte de la de los metadatos)
#                 y sale con 1. Que el contenido cuadre y las fechas no es un
#                 diagnostico distinto de que el contenido cambie.
#     [FALLO]     no se puede contestar: el paquete no esta en el manifiesto,
#                 hay dos lineas para el, o no existe el .deb que nombra
#
# EL DESGLOSE SE IMPRIME AUNQUE SALGA BIEN (la parte barata: huellas de los
# tres miembros). En verde es la referencia con la que comparar el dia que
# alguna de las dos maquinas se mueva; sin ella, un [OK] no deja dato.

set -uo pipefail
export LC_ALL=C   # trampa 2: la salida de las herramientas, sin traducir

AQUI=$(cd "$(dirname "$0")" && pwd)
MANIFIESTO="$AQUI/repo-manifiesto.tsv"
DIR="$(cd "$AQUI/.." && pwd)/debian-packages"
PAQUETE=""

uso() { sed -n '3p' "$0"; exit 2; }
while [ $# -gt 0 ]; do
    case "$1" in
        --dir)        DIR="$2";        shift 2 ;;
        --manifiesto) MANIFIESTO="$2"; shift 2 ;;
        -h|--help)    sed -n '1,40p' "$0"; exit 0 ;;
        -*) echo "[FALLO] argumento desconocido: $1"; uso ;;
        *)  [ -n "$PAQUETE" ] && { echo "[FALLO] sobra un argumento: $1"; uso; }
            PAQUETE="$1"; shift ;;
    esac
done
[ -n "$PAQUETE" ] || uso
[ -f "$MANIFIESTO" ] || { echo "[FALLO] no existe el manifiesto: $MANIFIESTO"; exit 1; }

fallo()    { echo "[FALLO] $*"; exit 1; }
hallazgo() { echo "[HALLAZGO] $*"; }
ok()       { echo "[OK]    $*"; }

# sha256 se llama distinto en macOS y en Linux, y este guion corre en los dos
if   command -v sha256sum >/dev/null; then huella() { sha256sum "$1" | cut -d' ' -f1; }
elif command -v shasum    >/dev/null; then huella() { shasum -a 256 "$1" | cut -d' ' -f1; }
else fallo "no hay ni sha256sum ni shasum"; fi
huella_de_tuberia() {
    if command -v sha256sum >/dev/null; then sha256sum | cut -d' ' -f1
    else shasum -a 256 | cut -d' ' -f1; fi
}
tam() { wc -c <"$1" | tr -d ' '; }

TAB=$(printf '\t')

# --- 0. la maquina y las herramientas que deciden los bytes -----------------
# 'ubuntu-latest' es una FOTO, no una propiedad: hoy es noble y manana puede ser
# otra sin que nadie toque este repositorio. Y quien decide los bytes de un .deb
# es dpkg-deb y su compresor, no el guion de construccion. Sin esto escrito, el
# dia que una huella no cuadre no hay contra que comparar -- que es justo lo que
# hizo interpretable el hallazgo de §4.37c.
echo "== 0. donde se ha construido"
if [ -r /etc/os-release ]; then
    . /etc/os-release 2>/dev/null
    echo "        sistema  ${PRETTY_NAME:-?}   arquitectura $(uname -m)"
else
    echo "        sistema  $(uname -srm)"
fi
if command -v dpkg-query >/dev/null; then
    dpkg-query -W -f'        ${Package} ${Version}\n' dpkg dpkg-dev libzstd1 tar 2>/dev/null
else
    echo "        (no es una maquina Debian: sin versiones de dpkg)"
fi

# --- 1. la linea del manifiesto ---------------------------------------------
# Exactamente una. Ni cero (el paquete no viaja en el medio) ni dos (el
# manifiesto tiene un duplicado y cualquier respuesta seria por casualidad).
echo "== 1. $PAQUETE en el manifiesto"
LINEAS=$(awk -F"$TAB" -v p="$PAQUETE" '$1=="PROPIO" && $2==p' "$MANIFIESTO")
N=$(printf '%s\n' "$LINEAS" | grep -c .)
[ "$N" -eq 1 ] || fallo "$PAQUETE sale $N veces como PROPIO en $MANIFIESTO (tiene que salir 1)"
IFS="$TAB" read -r _origen _paq VERSION FICHERO TAMANO SHA <<EOF
$LINEAS
EOF
echo "        version  $VERSION"
echo "        fichero  $FICHERO"
echo "        esperado $SHA  $TAMANO bytes"

# --- 2. el .deb construido ---------------------------------------------------
# Se busca POR EL NOMBRE EXACTO que el manifiesto nombra, no con un comodin: si
# se ha construido otra version, eso es un hallazgo y no algo que un glob deba
# tapar cogiendo el fichero que haya.
echo "== 2. el .deb recien construido"
DEB="$DIR/$FICHERO"
if [ ! -f "$DEB" ]; then
    hallazgo "no existe $DEB"
    echo "        lo que si hay en $DIR:"
    find "$DIR" -maxdepth 1 -name "${PAQUETE}_*.deb" -type f 2>/dev/null \
        | while IFS= read -r f; do echo "          $(basename "$f")  $(huella "$f")  $(tam "$f")"; done
    echo "        o el manifiesto se ha quedado atras, o se construyo otra version."
    exit 1
fi
SHA_REAL=$(huella "$DEB")
TAM_REAL=$(tam "$DEB")
echo "        real     $SHA_REAL  $TAM_REAL bytes"

# --- 3. el desglose: los miembros del 'ar' ----------------------------------
# Un .deb es un archivo 'ar' con tres miembros. Si la huella de arriba no cuadra
# esto dice CUAL de los tres se movio, que es la diferencia entre 'ha cambiado
# el contenido' y 'ha cambiado una fecha' (§4.37d).
echo "== 3. los miembros del ar"
if command -v ar >/dev/null; then
    ar t "$DEB" 2>/dev/null | while IFS= read -r m; do
        [ -n "$m" ] || continue
        printf '        %-18s %s  %s\n' "$m" \
            "$(ar p "$DEB" "$m" 2>/dev/null | huella_de_tuberia)" \
            "$(ar p "$DEB" "$m" 2>/dev/null | wc -c | tr -d ' ')"
    done
else
    echo "        (no hay 'ar' en esta maquina: sin desglose de miembros)"
fi
# Los dos tar DESCOMPRIMIDOS. Es lo que separa 'otro contenido' de 'otro
# compresor': dos zstd distintos dan .tar.zst distintos con el mismo tar dentro.
if command -v dpkg-deb >/dev/null; then
    echo "        y descomprimidos (asi la compresion no enmascara el contenido):"
    printf '        %-18s %s  %s\n' "control.tar" \
        "$(dpkg-deb --ctrl-tarfile "$DEB" 2>/dev/null | huella_de_tuberia)" \
        "$(dpkg-deb --ctrl-tarfile "$DEB" 2>/dev/null | wc -c | tr -d ' ')"
    printf '        %-18s %s  %s\n' "data.tar" \
        "$(dpkg-deb --fsys-tarfile "$DEB" 2>/dev/null | huella_de_tuberia)" \
        "$(dpkg-deb --fsys-tarfile "$DEB" 2>/dev/null | wc -c | tr -d ' ')"
else
    echo "        (no hay 'dpkg-deb' en esta maquina: sin los tar descomprimidos)"
fi

# --- 4. el veredicto ---------------------------------------------------------
echo "== 4. el veredicto"
if [ "$SHA_REAL" = "$SHA" ] && [ "$TAM_REAL" = "$TAMANO" ]; then
    ok "$FICHERO cuadra con el manifiesto  ${SHA:0:12}…  $TAMANO bytes"
    exit 0
fi

# A partir de aqui NO cuadra, y el trabajo del guion es decir en que. Un
# 'no cuadra' a secas obliga a repetirlo todo a mano en la otra maquina.
hallazgo "$FICHERO NO es el del manifiesto"
echo "        manifiesto  $SHA  $TAMANO bytes"
echo "        construido  $SHA_REAL  $TAM_REAL bytes"
[ "$SHA_REAL" != "$SHA" ] && [ "$TAM_REAL" = "$TAMANO" ] \
    && echo "        MISMO TAMANO Y OTROS BYTES: el tamano no discrimina (§4.37i)"

if command -v dpkg-deb >/dev/null; then
    TMP=$(mktemp -d) || fallo "no puedo crear un temporal"
    trap 'rm -rf "$TMP"' EXIT

    echo
    echo "== 5. control.tar, entero (modos, duenos, tamanos y fechas)"
    dpkg-deb --ctrl-tarfile "$DEB" >"$TMP/control.tar" 2>/dev/null
    tar -tvf "$TMP/control.tar" 2>/dev/null | sed 's/^/        /'

    echo
    echo "== 6. data.tar, entero"
    dpkg-deb --fsys-tarfile "$DEB" >"$TMP/data.tar" 2>/dev/null
    # --full-time es de GNU tar; en macOS (bsdtar) no existe y se cae al listado
    # normal, que redondea a minutos. Se dice cual de los dos salio.
    if tar --full-time -tvf "$TMP/data.tar" >"$TMP/lista" 2>/dev/null; then
        echo "        (con --full-time: los segundos son exactos)"
    else
        tar -tvf "$TMP/data.tar" >"$TMP/lista" 2>/dev/null
        echo "        (sin --full-time: las fechas van redondeadas a minutos)"
    fi
    sed 's/^/        /' "$TMP/lista"

    echo
    echo "== 7. el CONTENIDO aparte de los metadatos"
    # Esta es la pregunta que de verdad decide: si los ficheros son identicos
    # huella a huella y solo bailan las fechas, el paquete es el mismo y lo que
    # falla es la reproducibilidad de los metadatos (§4.37f). Si algun fichero
    # cambia, es otro paquete.
    mkdir -p "$TMP/x" && ( cd "$TMP/x" && tar -xf "$TMP/data.tar" 2>/dev/null )
    ( cd "$TMP/x" && find . -type f | sort | while IFS= read -r f; do
        echo "        $(huella "$f")  $f"
      done )
    echo "        ficheros: $(cd "$TMP/x" && find . -type f | wc -l | tr -d ' ')"
    # LOS ENLACES VAN APARTE Y HAY QUE DECIRLOS: no tienen contenido que
    # huellar, y 'find -type f' NO los ve. Desde el 2026-08-15 encina-branding
    # envia uno -la mascara de gnome-initial-setup, a /dev/null- y sin esta
    # linea el listado diria «ficheros: N» sin mencionarlo. Es la misma familia
    # que el cotejo de construir-todo.sh, que dio [FALLO] por lo mismo.
    N_ENL=$(cd "$TMP/x" && find . -type l | wc -l | tr -d ' ')
    if [ "$N_ENL" -gt 0 ]; then
        ( cd "$TMP/x" && find . -type l | sort | while IFS= read -r l; do
            echo "        (enlace, sin huella)  $l -> $(readlink "$l")"
          done )
    fi
    echo "        enlaces:  $N_ENL"
fi

echo
echo "        NO se toca el manifiesto desde aqui: adoptar unas huellas nuevas"
echo "        es una decision de producto, como en §4.37g."
exit 1
