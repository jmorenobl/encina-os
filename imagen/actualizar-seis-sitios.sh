#!/usr/bin/env bash
# Encina OS - EL RITUAL DE LOS SEIS SITIOS (MEDICIONES.md §4.48f), EJECUTABLE.
#
#     ./imagen/actualizar-seis-sitios.sh --repo <dir> [--constructor u@host] [--raiz <arbol>]
#
# QUE HACE (A3 de tareas/actualizacion.md, 2026-08-31): cuando cambia un .deb
# PROPIO, su version nueva tiene que aterrizar en todos los sitios que la
# llevan, y hasta hoy eso era trabajo a mano que ya se ha pagado mal dos veces
# (§4.45b, §4.48f). Este guion lo hace entero, leyendo TODO de --repo (el
# directorio que sera /encina-repo: los 29 .deb, con los PROPIO nuevos dentro):
#
#   1-2. imagen/repo-manifiesto.tsv y repo-manifiesto-amd64.tsv: las filas
#        PROPIO reescritas con version, fichero, tamano y sha256 DE LOS BYTES
#        (los .deb PROPIO son _all: las mismas filas en los dos manifiestos).
#   3.   imagen/encina-seed.sh: las cuatro H_* y los nombres de fichero que
#        lleva escritos (el verificador de dentro de la instalacion).
#   4.   El indice Packages de --repo, si dejo de describir los bytes: se
#        regenera en el constructor (dpkg-scanpackages no existe en macOS),
#        con el cotejo de huellas a los dos lados de construir-todo.sh.
#   5-6. imagen/autoinstall.yaml y autoinstall-unattended.yaml: regenerados
#        con fabricar-seed.sh --actualizar-yaml, que ademas verifica que
#        manifiesto, encina-seed.sh y --repo cuentan la misma historia.
#
# Los otros dos sitios historicos --los arrays FICHEROS de fabricar-seed.sh y
# fabricar-iso.sh-- se actualizan SOLOS desde la tarea 14 (2026-08-28): leen
# el manifiesto. Por eso este guion toca seis cosas y ninguna mas.
#
# LO QUE NO HACE: ni dch (la version la decide una persona y se escribe con
# dch en la VM, nunca aqui), ni commit, ni construir nada. Es el paso 2 de la
# receta de imagen/sacar-version.sh, y se puede correr solo.
#
# ES IDEMPOTENTE A PROPOSITO: sobre el estado vigente no cambia un byte, y esa
# es su prueba de ensayo (git diff limpio despues). Su control es el contrario:
# con un .deb de bytes distintos en --repo, el diff tiene que ensenar
# exactamente los sitios que llevan su huella.
#
# MODELO DE SALIDA: ABORTAR (tarea 2, MEDICIONES.md §4.67): morir() al primer
# problema, como el resto de imagen/.
set -uo pipefail
export LC_ALL=C

AQUI=$(cd "$(dirname "$0")" && pwd)
RAIZ=$(cd "$AQUI/.." && pwd)
REPO=""; CONSTRUCTOR=""
uso() { sed -n '2,4p' "$0"; exit 2; }
while [ $# -gt 0 ]; do
    case "$1" in
        --repo)        REPO="$2";        shift 2 ;;
        --constructor) CONSTRUCTOR="$2"; shift 2 ;;
        --raiz)        RAIZ="$2";        shift 2 ;;
        -h|--help)     sed -n '1,38p' "$0"; exit 0 ;;
        *) echo "[FALLO] argumento desconocido: $1"; uso ;;
    esac
done
[ -n "$REPO" ] || uso

. "$RAIZ/lib/salida.sh"

[ -d "$REPO" ] || morir "no existe --repo: $REPO"
REPO=$(cd "$REPO" && pwd)
MAN_ARM="$RAIZ/imagen/repo-manifiesto.tsv"
MAN_AMD="$RAIZ/imagen/repo-manifiesto-amd64.tsv"
SEED_SH="$RAIZ/imagen/encina-seed.sh"
for f in "$MAN_ARM" "$MAN_AMD" "$SEED_SH" "$RAIZ/imagen/fabricar-seed.sh" \
         "$RAIZ/imagen/autoinstall.yaml" "$RAIZ/imagen/autoinstall-unattended.yaml"; do
    [ -f "$f" ] || morir "no esta: $f"
done
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT

# los cuatro PROPIO y su variable en encina-seed.sh, en el orden de siempre
PAQUETES="autofirma encina-branding encina-firefox-native encina-meta"
var_de() {
    case "$1" in
        autofirma)             echo H_AUTOFIRMA ;;
        encina-branding)       echo H_BRANDING ;;
        encina-firefox-native) echo H_FFNATIVE ;;
        encina-meta)           echo H_META ;;
    esac
}

# ============================================================================
titulo "1. los cuatro .deb PROPIO, leidos de --repo (los bytes mandan)"

: > "$TMP/nuevo.tsv"    # paquete\tversion\tfichero\ttamano\tsha256
for p in $PAQUETES; do
    N=$(find "$REPO" -maxdepth 1 -name "${p}_*.deb" | wc -l | tr -d ' ')
    [ "$N" = 1 ] || morir "en $REPO hay $N ficheros ${p}_*.deb y tiene que haber exactamente 1"
    F=$(basename "$(find "$REPO" -maxdepth 1 -name "${p}_*.deb")")
    V=${F#"${p}"_}; V=${V%_all.deb}
    case "$V" in *_*|"") morir "no se lee la version en el nombre: $F" ;; esac
    T=$(wc -c < "$REPO/$F" | tr -d ' ')
    H=$(shasum -a 256 "$REPO/$F" | cut -d' ' -f1)
    printf '%s\t%s\t%s\t%s\t%s\n' "$p" "$V" "$F" "$T" "$H" >> "$TMP/nuevo.tsv"
    ok "$p $V  $T bytes  $(printf %.16s "$H")…"
done

# ============================================================================
titulo "2. los dos manifiestos: las filas PROPIO reescritas desde esos bytes"

# los nombres VIEJOS se capturan ANTES de tocar nada: son los que hay que
# sustituir en encina-seed.sh
awk -F'\t' '$1=="PROPIO"{print $2"\t"$4}' "$MAN_ARM" > "$TMP/viejos.tsv"

for MAN in "$MAN_ARM" "$MAN_AMD"; do
    awk -F'\t' -v OFS='\t' -v NUEVO="$TMP/nuevo.tsv" '
        BEGIN { while ((getline l < NUEVO) > 0) { split(l, c, "\t"); v[c[1]]=l } }
        $1=="PROPIO" && ($2 in v) { split(v[$2], c, "\t"); $3=c[2]; $4=c[3]; $5=c[4]; $6=c[5] }
        { print }' "$MAN" > "$TMP/man.nuevo"
    # trampa 13: lo escrito se relee y se compara con lo calculado
    while IFS="$(printf '\t')" read -r p v f t h; do
        FILA=$(awk -F'\t' -v p="$p" '$1=="PROPIO" && $2==p {print $3"\t"$4"\t"$5"\t"$6}' "$TMP/man.nuevo")
        [ "$FILA" = "$(printf '%s\t%s\t%s\t%s' "$v" "$f" "$t" "$h")" ] \
            || morir "la fila PROPIO de $p no quedo como se calculo en $(basename "$MAN"):
        escrita:   $FILA
        calculada: $v	$f	$t	$h"
    done < "$TMP/nuevo.tsv"
    NF1=$(grep -c . "$MAN"); NF2=$(grep -c . "$TMP/man.nuevo")
    [ "$NF1" = "$NF2" ] || morir "$(basename "$MAN") cambio de $NF1 a $NF2 lineas: solo podian cambiar 4 filas"
    if cmp -s "$MAN" "$TMP/man.nuevo"; then
        ok "$(basename "$MAN"): ya decia esto (idempotente, ni un byte)"
    else
        cp "$TMP/man.nuevo" "$MAN"
        ok "$(basename "$MAN"): filas PROPIO reescritas ($(grep -c '^PROPIO' "$MAN") filas)"
    fi
done

# y el arbitro de verdad: comprobar-propios.sh, que tiene su control dentro,
# tiene que dar verde para los cuatro contra ESTE repo y ESTE manifiesto
for p in $PAQUETES; do
    "$RAIZ/imagen/comprobar-propios.sh" "$p" --dir "$REPO" --manifiesto "$MAN_ARM" >"$TMP/cp.log" 2>&1 \
        || morir "comprobar-propios.sh dice que $p NO cuadra tras reescribir:
$(tail -5 "$TMP/cp.log")"
done
ok "comprobar-propios.sh da verde para los cuatro contra el manifiesto reescrito"

# ============================================================================
titulo "3. encina-seed.sh: las cuatro H_* y los nombres que lleva escritos"

cp "$SEED_SH" "$TMP/seed.nuevo"
while IFS="$(printf '\t')" read -r p v f t h; do
    VAR=$(var_de "$p")
    VIEJO=$(awk -F'\t' -v p="$p" '$1==p{print $2}' "$TMP/viejos.tsv")
    [ -n "$VIEJO" ] || morir "no se el nombre viejo de $p (¿el manifiesto no lo tenia?)"
    python3 - "$TMP/seed.nuevo" "$VAR" "$h" "$VIEJO" "$f" <<'PY' || exit 1
import re, sys
ruta, var, hnueva, viejo, nuevo = sys.argv[1:6]
t = open(ruta).read()
t2, n = re.subn(r'(?m)^%s=[0-9a-f]{64}$' % re.escape(var), '%s=%s' % (var, hnueva), t)
if n != 1:
    sys.exit("[FALLO] %s aparece %d veces como linea de asignacion y tenia que ser 1" % (var, n))
t2 = t2.replace(viejo, nuevo)
open(ruta, 'w').write(t2)
PY
done < "$TMP/nuevo.tsv"

# trampa 13: releer y exigir lo nuevo presente y lo viejo ausente
while IFS="$(printf '\t')" read -r p v f t h; do
    VAR=$(var_de "$p")
    grep -q "^$VAR=$h\$" "$TMP/seed.nuevo" || morir "en encina-seed.sh no quedo $VAR=$h"
    grep -q "srv/encina-repo/$f" "$TMP/seed.nuevo" || morir "en encina-seed.sh no quedo el nombre $f"
    VIEJO=$(awk -F'\t' -v p="$p" '$1==p{print $2}' "$TMP/viejos.tsv")
    if [ "$VIEJO" != "$f" ] && grep -q "$VIEJO" "$TMP/seed.nuevo"; then
        morir "en encina-seed.sh sigue el nombre viejo $VIEJO"
    fi
done < "$TMP/nuevo.tsv"
if cmp -s "$SEED_SH" "$TMP/seed.nuevo"; then
    ok "encina-seed.sh: ya decia esto (idempotente, ni un byte)"
else
    cp "$TMP/seed.nuevo" "$SEED_SH"
    ok "encina-seed.sh: huellas y nombres reescritos, releidos del disco"
fi

# ============================================================================
titulo "4. el indice Packages de --repo, si dejo de describir los bytes"

indice_cuadra() {
    [ -f "$REPO/Packages" ] || return 1
    N_DEB=$(find "$REPO" -maxdepth 1 -name '*.deb' | wc -l | tr -d ' ')
    N_IDX=$(grep -cE '^Filename: \./' "$REPO/Packages" || true)
    [ "$N_DEB" = "$N_IDX" ] || return 1
    while IFS="$(printf '\t')" read -r p v f t h; do
        grep -q "^SHA256: $h\$" "$REPO/Packages" || return 1
    done < "$TMP/nuevo.tsv"
    return 0
}
if indice_cuadra; then
    ok "Packages ya describe estos bytes ($(grep -cE '^Filename: ' "$REPO/Packages") entradas): no se regenera"
else
    [ -n "$CONSTRUCTOR" ] || morir "Packages no describe los .deb nuevos y no me diste --constructor.
        dpkg-scanpackages no existe en macOS (construir-todo.sh §5); la orden que falta es:
        ./imagen/actualizar-seis-sitios.sh --repo $REPO --constructor jorge@192.168.64.3"
    R() { ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -o LogLevel=ERROR "$CONSTRUCTOR" "$@"; }
    R true || morir "el constructor $CONSTRUCTOR no contesta por ssh"
    REMOTO="seis-sitios-$$"
    R "rm -rf ~/$REMOTO && mkdir -p ~/$REMOTO"
    ( cd "$REPO" && COPYFILE_DISABLE=1 tar -cf - -- *.deb ) | R "cd ~/$REMOTO && tar -xf - 2>/dev/null" \
        || morir "no pude enviar los .deb al constructor"
    # el cotejo a los dos lados, con su control (el patron de construir-todo.sh, trampa 24)
    ( cd "$REPO" && shasum -a 256 -- *.deb ) | sort > "$TMP/h.aqui"
    R "cd ~/$REMOTO && sha256sum *.deb" | sort > "$TMP/h.alli"
    D=$(diff "$TMP/h.aqui" "$TMP/h.alli" | grep -c '^[<>]' || true)
    [ "$D" = 0 ] || morir "los .deb no llegaron iguales al constructor: $D diferencias"
    sed '1s/^./f/' "$TMP/h.aqui" > "$TMP/h.sab"
    cmp -s "$TMP/h.aqui" "$TMP/h.sab" && morir "CONTROL ROTO: el sabotaje no saboteo"
    [ "$(diff "$TMP/h.sab" "$TMP/h.alli" | grep -c '^[<>]' || true)" -ge 1 ] \
        || morir "CONTROL ROTO: el cotejo no ve una huella cambiada en un caracter"
    ok "los .deb llegaron iguales, y el cotejo sabe decir que no"
    R "cd ~/$REMOTO && dpkg-scanpackages . /dev/null > Packages 2>/dev/null" || morir "dpkg-scanpackages fallo"
    scp -q -o StrictHostKeyChecking=no -o LogLevel=ERROR "$CONSTRUCTOR:~/$REMOTO/Packages" "$REPO/Packages" \
        || morir "no pude traerme el Packages"
    HA=$(R "sha256sum ~/$REMOTO/Packages | cut -d' ' -f1")
    HB=$(shasum -a 256 "$REPO/Packages" | cut -d' ' -f1)
    [ "$HA" = "$HB" ] || morir "el Packages no llego igual: alli $HA, aqui $HB"
    R "rm -rf ~/$REMOTO"
    indice_cuadra || morir "el Packages regenerado SIGUE sin describir los bytes: parar y mirar"
    ok "Packages regenerado en el constructor y releido: describe los bytes nuevos"
fi

# ============================================================================
titulo "5-6. los dos YAML, regenerados por fabricar-seed.sh (que ademas coteja todo)"

for Y in autoinstall.yaml autoinstall-unattended.yaml; do
    ANTES=$(shasum -a 256 "$RAIZ/imagen/$Y" | cut -d' ' -f1)
    "$RAIZ/imagen/fabricar-seed.sh" --yaml "$RAIZ/imagen/$Y" --actualizar-yaml \
        --repo "$REPO" --salida "$TMP/seed-$Y.img" > "$TMP/fs-$Y.log" 2>&1 \
        || morir "fabricar-seed.sh se nego con $Y (el cotejo manifiesto/seed/repo no cuadra):
$(tail -12 "$TMP/fs-$Y.log")"
    DESPUES=$(shasum -a 256 "$RAIZ/imagen/$Y" | cut -d' ' -f1)
    if [ "$ANTES" = "$DESPUES" ]; then
        ok "$Y: ya llevaba este encina-seed.sh dentro (idempotente)"
    else
        ok "$Y: regenerado ($(printf %.8s "$ANTES")… -> $(printf %.8s "$DESPUES")…)"
    fi
    rm -f "$TMP/seed-$Y.img"
done

# ============================================================================
titulo "lo que ha cambiado, dicho por git"
if git -C "$RAIZ" rev-parse HEAD >/dev/null 2>&1; then
    if git -C "$RAIZ" diff --quiet -- imagen/ 2>/dev/null; then
        echo "   ni un byte: el arbol ya estaba en este estado (la pasada idempotente)"
    else
        git -C "$RAIZ" diff --stat -- imagen/ | sed 's/^/   /'
    fi
else
    echo "   ($RAIZ no es un arbol git: revisa los seis ficheros a mano)"
fi

resumen
