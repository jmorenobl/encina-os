#!/usr/bin/env bash
# Encina OS - BANCO DE LAS VERSIONES: una sola fuente, y una prosa que no la desmienta.
#
#     ./bancos/versiones.sh [--solo-control] [--solo-medicion]
#
# LA FUENTE DE LA VERSION DE CADA INGREDIENTE ES UNA, y no es este guion ni
# ningun .md: es imagen/repo-manifiesto.tsv (las filas PROPIO), que a su vez
# tiene que decir lo que dicen los debian/changelog de los tres paquetes de
# este repositorio y el del hermano (~/Projects/encina-autofirma). Y LA VERSION
# DEL PRODUCTO es la de encina-meta: fabricar-iso.sh compone con ella el
# Volume id («EncinaOS 0.2.1 arm64», paso 5e, §4.57f) y no la escribe nadie a
# mano en ningun otro sitio. La otra version que viaja en el medio -- el
# «24.04.4 LTS "Nutria Nocturna"» de imagen/marca/disk-info -- NO es nuestra:
# es la de la BASE, que subiquity usa como canal de snap y tiene que ser la de
# la ISO oficial (§4.56b, 33b de TRAMPAS.md); fabricar-iso.sh la coteja.
#
# QUE COMPRUEBA (tarea 14 de tareas/refactorizacion.md):
#   (A) manifiesto == changelog, para los tres paquetes propios (y autofirma si
#       el repositorio hermano esta en el disco; si no, [OMIT]);
#   (B) que NINGUN documento VIVO cite un ingrediente con una version que no
#       sea la del manifiesto. El 2026-08-23 los .md decian «autofirma
#       1.9.1+encina2» en 25 sitios y el manifiesto pinchaba +encina4 desde el
#       2026-08-12, empezando por la linea de alcance de AGENTS.md.
#
# QUE ES UN DOCUMENTO VIVO, y que no: AGENTS.md, ENCINA-OS.md, README.md,
# TAREAS.md, CLAUDE.md, TRAMPAS.md, medios/LEEME.md y tareas/ (menos
# tareas/cerradas/). NO lo son mediciones/, DIARIO.md, SCRIPTS.md ni
# tareas/cerradas/: son el registro de lo que se ejecuto aquel dia y NO SE
# REESCRIBEN (CLAUDE.md, «Método»). Una version vieja ahi es un dato, no un error.
#
# COMO SE DEJA UNA VERSION VIEJA EN UN DOCUMENTO VIVO SIN QUE ESTO LA SENALE, y
# son tres formas, todas visibles para quien lea:
#   - tachada, «~~+encina2~~ +encina4», que es la enmienda fechada de siempre;
#   - dentro de un bloque de codigo (una salida literal es una cita, no una
#     afirmacion). Entre acentos graves NO vale: asi se escriben los nombres;
#   - o en una linea que diga «histor» (historico, historial): «la maquina de
#     E1 llevaba +encina2 (historico)». Es la marca de que se habla del pasado.
#
# EL CONTROL VA DELANTE: un .md de mentira con «encina-branding 0.1.16» tiene
# que salir rojo, y un manifiesto de mentira con la version de encina-meta
# cambiada tiene que salir rojo contra el changelog. Si el comparador no da
# sus dos respuestas, no se mide nada.

# MODELO DE SALIDA: CONTAR Y SEGUIR (tarea 2, MEDICIONES.md §4.67).
set -uo pipefail
export LC_ALL=C

AQUI=$(cd "$(dirname "$0")" && pwd)
RAIZ=$(cd "$AQUI/.." && pwd)
HACER_CONTROL=1; HACER_MEDICION=1
while [ $# -gt 0 ]; do
    case "$1" in
        --solo-control)  HACER_MEDICION=0; shift ;;
        --solo-medicion) HACER_CONTROL=0;  shift ;;
        -h|--help)       sed -n '2,4p' "$0"; exit 0 ;;
        *) echo "[FALLO] argumento desconocido: $1"; exit 2 ;;
    esac
done
. "$RAIZ/lib/salida.sh"

MANIFIESTO="$RAIZ/imagen/repo-manifiesto.tsv"
HERMANO="${ENCINA_AUTOFIRMA:-$HOME/Projects/encina-autofirma}"
TMP=$(mktemp -d "${TMPDIR:-/tmp}/versiones.XXXXXX") || morir "mktemp"
trap 'rm -rf "$TMP"' EXIT

# version_manifiesto <manifiesto> <paquete>
version_manifiesto() { awk -F'\t' -v p="$2" '$1=="PROPIO" && $2==p {print $3}' "$1"; }
# version_changelog <fichero changelog> -> la de la primera linea
version_changelog() { head -1 "$1" | sed -n 's/^[a-z0-9.+-]* (\([^)]*\)).*/\1/p'; }

# documentos vivos, relativos a una raiz
vivos() {
    local r="$1"
    for f in AGENTS.md ENCINA-OS.md README.md TAREAS.md CLAUDE.md TRAMPAS.md medios/LEEME.md; do
        [ -f "$r/$f" ] && echo "$f"
    done
    [ -d "$r/tareas" ] && (cd "$r" && /usr/bin/find tareas -name '*.md' -not -path 'tareas/cerradas/*' | LC_ALL=C sort)
    return 0
}

# citas <raiz> <manifiesto> -> «fichero<TAB>linea<TAB>paquete<TAB>version citada<TAB>version buena»
# solo las que NO cuadran y NO estan exentas
citas() {
    local r="$1" man="$2" f
    for f in $(vivos "$r"); do
        awk -v F="$f" -v MAN="$man" '
        BEGIN { OFS="\t"
            while ((getline l < MAN) > 0) { split(l, c, "\t"); if (c[1]=="PROPIO") buena[c[2]]=c[3] } }
        /^[ \t>]*```/ { valla=!valla; next }
        valla { next }
        # «histor» y «histór»: bajo LC_ALL=C la o acentuada son dos bytes y «histor»
        # NO casa con «histórica» -- la primera pasada dejo 21 marcas sin eximir
        tolower($0) ~ /hist(o|ó)r/ { next }
        {
            linea=$0
            # fuera lo tachado. Lo que va entre acentos graves NO se exime: los
            # nombres de paquete se escriben asi («`autofirma 1.9.1+encina2`») y
            # la primera version de este banco, que los eximia, dio 0 fallos sobre
            # 25 citas rancias (2026-08-28). Una cita de salida literal va en valla.
            gsub(/~~[^~]*~~/, " ", linea)
            aux=linea
            # autofirma 1.9.1+encinaN, o 1.9.1+encinaN a secas
            while (match(aux, /1\.9\.1\+encina[0-9]+/)) {
                v=substr(aux, RSTART, RLENGTH); aux=substr(aux, RSTART+RLENGTH)
                if (v != buena["autofirma"]) print F, FNR, "autofirma", v, buena["autofirma"]
            }
            aux=linea
            while (match(aux, /encina-(branding|firefox-native|meta)[ _]([0-9]+\.[0-9]+\.[0-9]+)/)) {
                t=substr(aux, RSTART, RLENGTH); aux=substr(aux, RSTART+RLENGTH)
                p=t; sub(/[ _][0-9.]*$/, "", p); v=t; sub(/^.*[ _]/, "", v)
                if (v != buena[p]) print F, FNR, p, v, buena[p]
            }
        }' "$r/$f"
    done
}

RC=0
if [ "$HACER_CONTROL" = 1 ]; then
    titulo "EL CONTROL, antes de medir: una version cambiada en un .md, y una en el manifiesto"
    C="$TMP/corpus"; mkdir -p "$C/tareas" "$C/debian-packages/encina-meta/debian"
    cp "$MANIFIESTO" "$C/manifiesto.tsv"
    printf 'Lleva encina-branding %s y autofirma %s, que son las buenas.\n' \
        "$(version_manifiesto "$MANIFIESTO" encina-branding)" "$(version_manifiesto "$MANIFIESTO" autofirma)" > "$C/AGENTS.md"
    printf 'Y aqui una VIEJA: encina-branding 0.1.16, y otra tachada ~~1.9.1+encina2~~ que no cuenta,\ny una historica: autofirma 1.9.1+encina1 (historial).\n' > "$C/tareas/x.md"
    citas "$C" "$C/manifiesto.tsv" > "$TMP/c1"
    if [ "$(/usr/bin/grep -c . "$TMP/c1")" -eq 1 ] && /usr/bin/grep -q "tareas/x.md	1	encina-branding	0.1.16" "$TMP/c1"; then
        ok "rojo (1/2): la version vieja «encina-branding 0.1.16» se senala, y SOLO ella (la tachada y la historica no)"
    else
        fallo "CONTROL ROTO: esperaba exactamente una cita mala (encina-branding 0.1.16) y salio:" "$(cat "$TMP/c1")"; RC=1
    fi
    # el manifiesto contra el changelog: un digito cambiado
    awk -F'\t' -v OFS='\t' '$1=="PROPIO" && $2=="encina-meta" {$3="9.9.9"} 1' "$MANIFIESTO" > "$C/manifiesto-sab.tsv"
    cmp -s "$MANIFIESTO" "$C/manifiesto-sab.tsv" && morir "CONTROL ROTO: el sabotaje del manifiesto no saboteo"
    VM=$(version_manifiesto "$C/manifiesto-sab.tsv" encina-meta); VC=$(version_changelog "$RAIZ/debian-packages/encina-meta/debian/changelog")
    if [ "$VM" != "$VC" ] && [ -n "$VC" ]; then
        ok "rojo (2/2): el manifiesto saboteado («$VM») no cuadra con debian/changelog («$VC») y el comparador lo ve"
    else
        fallo "CONTROL ROTO: el manifiesto saboteado pasa contra el changelog ($VM / $VC)"; RC=1
    fi
    if [ "$RC" -ne 0 ]; then echo; echo "EL CONTROL NO PASA. No se mide nada."; exit 1; fi
fi

if [ "$HACER_MEDICION" = 1 ]; then
    titulo "(A) el manifiesto contra los debian/changelog"
    for p in encina-branding encina-firefox-native encina-meta; do
        VM=$(version_manifiesto "$MANIFIESTO" "$p"); VC=$(version_changelog "$RAIZ/debian-packages/$p/debian/changelog")
        if [ -n "$VM" ] && [ "$VM" = "$VC" ]; then ok "$p: manifiesto $VM == changelog $VC"
        else fallo "$p: el manifiesto dice «$VM» y debian/changelog «$VC»"; RC=1; fi
    done
    VM=$(version_manifiesto "$MANIFIESTO" autofirma)
    if [ -f "$HERMANO/debian/changelog" ]; then
        VC=$(version_changelog "$HERMANO/debian/changelog")
        if [ "$VM" = "$VC" ]; then ok "autofirma: manifiesto $VM == changelog del hermano $VC"
        else aviso "autofirma: el manifiesto dice «$VM» y el changelog de $HERMANO «$VC» (el hermano puede ir por delante: no bloquea)"; fi
    else
        omitido "autofirma: no esta $HERMANO/debian/changelog en este disco; el manifiesto dice $VM"
    fi
    echo "   la version del PRODUCTO es la de encina-meta: $(version_manifiesto "$MANIFIESTO" encina-meta) (fabricar-iso.sh la pone en el Volume id)"

    titulo "(B) los documentos VIVOS contra el manifiesto"
    citas "$RAIZ" "$MANIFIESTO" > "$TMP/malas"
    N=$(/usr/bin/grep -c . "$TMP/malas")
    NDOC=$(vivos "$RAIZ" | /usr/bin/grep -c .)
    if [ "$N" -eq 0 ]; then
        ok "los $NDOC documentos vivos no citan ninguna version que no sea la del manifiesto (o la citan tachada, citada o como historica)"
    else
        fallo "$N citas con una version que no es la del manifiesto en los documentos vivos (tachala, citala o marcala como historica):" \
"$(awk -F'\t' '{printf "%s:%s  %s %s  (manifiesto: %s)\n",$1,$2,$3,$4,$5}' "$TMP/malas")"
        RC=1
    fi
    omitido "los REGISTROS (mediciones/, DIARIO.md, SCRIPTS.md, tareas/cerradas/) no se miran: conservan las versiones de su dia a proposito"
fi

echo
echo "=== RESUMEN ==="
echo "   correctas: $N_OK   fallos: $N_MAL   avisos: $N_AVI   omitidas: $N_OMI"
exit $RC
