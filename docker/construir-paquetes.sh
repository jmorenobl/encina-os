#!/usr/bin/env bash
# Encina OS - LOS TRES .deb, DENTRO DEL CONSTRUCTOR DE docker/Dockerfile.constructor.
#
#     docker run --rm -v "$PWD":/repo:ro -v "$PWD/debian-packages":/salida \
#         encina-constructor:24.04 /repo/docker/construir-paquetes.sh
#     (o, desde el Mac:  make paquetes)
#
#   /repo     este repositorio, DE SOLO LECTURA: aporta 'git archive HEAD'
#   /work     el arbol construido, en el sistema de ficheros del contenedor
#   /salida   donde se dejan los .deb, y SOLO si cuadran con el manifiesto
#
# QUE HACE, y es la misma secuencia que construir-todo.sh manda por ssh a
# encina-dev en su paso 3 (§4.60), con la misma exigencia:
#     0. las herramientas de la receta estan, y si falta una, la NOMBRA y para
#     1. 'git archive HEAD' de /repo a /work -- NUNCA el directorio de trabajo,
#        MEDICIONES.md §4.37: las fechas del disco viajan dentro del .deb
#     2. los tres guiones de construccion, uno por paquete, con ENCINA_REPO=/work
#     3. cada .deb contra imagen/repo-manifiesto.tsv, por huella y tamano
#        (imagen/comprobar-propios.sh, el mismo instrumento que la CI)
#     4. y solo entonces, a /salida
#
# EL CONTROL DEL PASO 0 ES LA DEFINICION DE TERMINADO DE LA TAREA 15: «la
# receta a la que le falta una de las siete herramientas FALLA, y falla
# nombrando cual. Si construyera igual, no describia nada». Se paga quitando
# una del contenedor y viendo que esto para ANTES de construir.
#
# LO QUE NO HACE: la ISO (xorriso de macOS, construir-todo.sh), ni autofirma,
# que se construye en ~/Projects/encina-autofirma con su propio Dockerfile.

# MODELO DE SALIDA: ABORTAR (tarea 2, MEDICIONES.md §4.67): el primer problema
# para, con morir(); las comprobaciones que si se cuentan las hacen los
# guiones de construccion y comprobar-propios.sh, cada uno con su modelo.
set -uo pipefail
export LC_ALL=C

REPO=${REPO:-/repo}
WORK=${WORK:-/work}
SALIDA=${SALIDA:-/salida}
. "$REPO/lib/salida.sh"

titulo "0. la receta: las herramientas, ANTES de construir nada"
# las siete de scripts/preparar-entorno.sh, mas las dos que la CI ya sabia que faltan
# en una maquina limpia (AGENTS.md §7)
HERRAMIENTAS="git dpkg-buildpackage dpkg-deb dpkg-scanpackages lintian rsvg-convert convert file gpg gcc"
FALTAN=""
for h in $HERRAMIENTAS; do
    command -v "$h" >/dev/null 2>&1 || FALTAN="$FALTAN $h"
done
[ -z "$FALTAN" ] || morir "a la receta le falta:$FALTAN
        Esto es docker/Dockerfile.constructor: lo que no este ahi no se improvisa aqui."
ok "las $(echo $HERRAMIENTAS | wc -w | tr -d ' ') herramientas estan: $HERRAMIENTAS"
echo "        $(. /etc/os-release && echo "$PRETTY_NAME") $(dpkg --print-architecture)   dpkg-dev $(dpkg-query -W -f='${Version}' dpkg-dev)   lintian $(dpkg-query -W -f='${Version}' lintian)"

titulo "1. 'git archive HEAD' de $REPO a $WORK (§4.37: no el directorio de trabajo)"
[ -d "$REPO/.git" ] || morir "$REPO no es un repositorio git (montalo con -v <clon>:/repo:ro)"
git config --global --add safe.directory "$REPO" >/dev/null 2>&1 || true
COMMIT=$(git -C "$REPO" rev-parse HEAD) || morir "no puedo leer HEAD de $REPO"
SUCIO=$(git -C "$REPO" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
# se vacia POR DENTRO: /work es del usuario ubuntu pero / no, y «rm -rf /work» se queja del directorio en si
mkdir -p "$WORK" && find "$WORK" -mindepth 1 -delete || morir "no puedo vaciar $WORK"
git -C "$REPO" archive HEAD | tar -xf - -C "$WORK" || morir "git archive HEAD no llego entero"
N_ARCH=$(git -C "$REPO" archive HEAD | tar -tf - | grep -v '/$' | wc -l | tr -d ' ')
N_WORK=$(find "$WORK" \( -type f -o -type l \) | wc -l | tr -d ' ')
[ "$N_ARCH" -eq "$N_WORK" ] || morir "el archive tiene $N_ARCH entradas y en $WORK hay $N_WORK"
ok "commit $COMMIT, $N_WORK ficheros en $WORK"
[ "$SUCIO" -eq 0 ] || echo "        AVISO: $SUCIO cambios sin confirmar en $REPO NO viajan (se construye HEAD)"

titulo "2. los tres .deb, con sus guiones (uno por paquete, a proposito)"
cd "$WORK" || morir "cd $WORK"
chmod +x scripts/*.sh
for g in scripts/construir-branding.sh scripts/construir-firefox.sh scripts/construir-meta.sh; do
    echo "== $g"
    ENCINA_REPO="$WORK" bash "$g" > "$WORK/.$(basename "$g").log" 2>&1 \
        || { tail -25 "$WORK/.$(basename "$g").log"; morir "$g no paso"; }
    # un recuento de CERO no es «todo bien» (§4.37f): el contador no sabe leer
    ESC=$(printf '\033')
    NOK=$(sed "s/${ESC}\[[0-9;]*m//g" "$WORK/.$(basename "$g").log" | grep -c '\[OK\]')
    NML=$(sed "s/${ESC}\[[0-9;]*m//g" "$WORK/.$(basename "$g").log" | grep -c '\[FALLO\]')
    [ "$NOK" -gt 0 ] || morir "$g no imprimio ni una comprobacion"
    [ "$NML" -eq 0 ] || morir "$g dio $NML fallos"
    echo "        $NOK comprobaciones, $NML fallos"
done

titulo "3. cada .deb contra el manifiesto, por huella (el mismo instrumento que la CI)"
for p in encina-branding encina-firefox-native encina-meta; do
    "$WORK/imagen/comprobar-propios.sh" "$p" --dir "$WORK/debian-packages" \
        --manifiesto "$WORK/imagen/repo-manifiesto.tsv" | grep -E '^ *\[(OK|HALLAZGO|FALLO)\]' \
        || morir "$p NO cuadra con el manifiesto: no sale del contenedor"
done

titulo "4. a $SALIDA, y solo porque cuadran"
mkdir -p "$SALIDA" || morir "no puedo crear $SALIDA"
cp "$WORK"/debian-packages/*.deb "$SALIDA"/ || morir "cp a $SALIDA"
for f in "$WORK"/debian-packages/*.deb; do
    b=$(basename "$f")
    [ "$(sha256sum "$f" | cut -d' ' -f1)" = "$(sha256sum "$SALIDA/$b" | cut -d' ' -f1)" ] \
        || morir "$b no llego igual a $SALIDA"
    echo "        $(sha256sum "$SALIDA/$b" | cut -c1-16)…  $b"
done
ok "los tres .deb, con la huella del manifiesto, en $SALIDA (commit $COMMIT)"
