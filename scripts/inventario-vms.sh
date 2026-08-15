#!/usr/bin/env bash
# inventario-vms.sh — qué VMs hay en el banco, qué las respalda y qué cuestan.
#
# Uso:  ./scripts/inventario-vms.sh [--documentos <dir>] [--vms <dir>]
#
# SE EJECUTA EN EL MAC, no en una VM. Es de la familia de capturar-vm.sh y
# teclear-vm.sh: pilota el banco desde fuera.
#
# NO BORRA NADA, y no va a aprender a hacerlo. Decidir qué VM se va es de
# Jorge, y este guion existe para que esa decisión se tome con datos en vez de
# con el nombre del directorio — que es exactamente el error que se cometió el
# 2026-08-15 diciendo que la ISO «95758c9e…» llevaba 0.1.11 porque había una VM
# llamada así.
#
# ---------------------------------------------------------------------------
# LAS DOS COSAS QUE ESTE GUION NO PUEDE CONTESTAR, Y SE DICEN POR DELANTE
# ---------------------------------------------------------------------------
#
# 1. CUÁNTO ESPACIO SE RECUPERA BORRANDO UNA VM. Aquí se imprime `du`, y `du`
#    es una COTA SUPERIOR, no una promesa. En APFS dos ficheros pueden
#    compartir bloques —es lo que hace `cp -c`, y es lo que hace UTM al
#    duplicar una VM—, y `du` los cuenta enteros las dos veces. Ya mordió:
#    MEDICIONES.md §4.29 duplicó una VM, `du` dijo 9,2 GB y al borrarla `df`
#    devolvió 0,923 GiB. El control de abajo lo reproduce en dos segundos.
#    LA ÚNICA MEDICIÓN QUE VALE ES `df` ANTES Y DESPUÉS DE BORRAR.
#
# 2. SI UNA VM SE PUEDE BORRAR. Este guion cuenta en cuántos documentos se la
#    nombra, que no es lo mismo: una VM muy citada puede ser historia cerrada
#    —E1 está terminado 12 de 12— y una VM sin citar puede ser la única copia
#    de algo. Por eso el veredicto de cada fila es [OJOS] y no [OK].
#
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
requiere_no_root
requiere_cmd du df stat lsof grep awk

VMS_DIR="$HOME/Library/Containers/com.utmapp.UTM/Data/Documents"
DOCS_DIR="${ENCINA_REPO:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --vms)        VMS_DIR="$2"; shift 2 ;;
        --documentos) DOCS_DIR="$2"; shift 2 ;;
        -h|--help)    sed -n '2,30p' "$0"; exit 0 ;;
        *) echo "Opción desconocida: $1"; exit 1 ;;
    esac
done

# Dónde se busca el respaldo documental de cada VM. El orden importa poco; lo
# que importa es que estén los cuatro sitios donde este proyecto escribe.
DOCUMENTOS=(MEDICIONES.md ENCINA-OS.md AGENTS.md DIARIO.md SCRIPTS.md TAREAS.md)

# ---------------------------------------------------------------------------
# menciones <nombre> — en qué documentos aparece ese nombre, y cuántas veces.
# Imprime "TOTAL|fichero:n fichero:n ..." o "0|" si no aparece en ninguno.
# ---------------------------------------------------------------------------
menciones() {
    local nombre="$1" total=0 detalle=() d n
    for d in "${DOCUMENTOS[@]}"; do
        [[ -f "$DOCS_DIR/$d" ]] || continue
        n=$(grep -F -c -- "$nombre" "$DOCS_DIR/$d" 2>/dev/null || true)
        n=${n:-0}
        if (( n > 0 )); then total=$((total+n)); detalle+=("$d:$n"); fi
    done
    if [[ -d "$DOCS_DIR/tareas" ]]; then
        n=$(grep -F -r -c -- "$nombre" "$DOCS_DIR/tareas" 2>/dev/null | awk -F: '{s+=$NF} END{print s+0}')
        if (( n > 0 )); then total=$((total+n)); detalle+=("tareas/:$n"); fi
    fi
    echo "${total}|${detalle[*]:-}"
}

# ---------------------------------------------------------------------------
# LOS CONTROLES, Y VAN ANTES QUE LA MEDICIÓN
#
# Es la regla de este repositorio y no un adorno: una comprobación que no puede
# dar sus dos respuestas no es una comprobación, y varias mediciones salieron
# mal la primera vez justo por ahí.
# ---------------------------------------------------------------------------
titulo "CONTROLES — antes de medir nada"

paso "Control 1: el buscador de menciones sabe decir 0 y sabe decir más de 0"

CTRL_AUSENTE="encina-vm-que-no-existe-$$"
ctrl_a="$(menciones "$CTRL_AUSENTE")"; ctrl_a="${ctrl_a%%|*}"
if [[ "$ctrl_a" == "0" ]]; then
    ok "un nombre inventado ($CTRL_AUSENTE) da 0 menciones"
else
    fallo "un nombre inventado debería dar 0 menciones" "dio: $ctrl_a"
fi

ctrl_p="$(menciones "encina-dev")"; ctrl_p="${ctrl_p%%|*}"
if [[ "${ctrl_p:-0}" -gt 0 ]]; then
    ok "un nombre que sí está (encina-dev) da $ctrl_p menciones"
else
    fallo "encina-dev debería aparecer en los documentos" \
          "dio: $ctrl_p — o el buscador está roto, o DOCS_DIR no es el repositorio ($DOCS_DIR)"
fi

paso "Control 2: 'du' cuenta doble lo que 'df' no cobra — la trampa de §4.29"

CTRL_TMP="$(mktemp -d)"
trap 'rm -rf "$CTRL_TMP"' EXIT
if dd if=/dev/zero of="$CTRL_TMP/original.bin" bs=1m count=200 status=none 2>/dev/null; then
    libres_antes=$(df -k "$CTRL_TMP" | tail -1 | awk '{print $4}')
    if cp -c "$CTRL_TMP/original.bin" "$CTRL_TMP/clon.bin" 2>/dev/null; then
        libres_despues=$(df -k "$CTRL_TMP" | tail -1 | awk '{print $4}')
        du_dos=$(du -k -c "$CTRL_TMP/original.bin" "$CTRL_TMP/clon.bin" | tail -1 | awk '{print $1}')
        coste_real=$(( libres_antes - libres_despues ))
        # El clon comparte bloques: du tiene que decir ~el doble y df ~nada.
        if (( du_dos > 300000 )) && (( coste_real < 50000 )); then
            ok "du dice ${du_dos} KiB por dos ficheros; df dice que el clon costó ${coste_real} KiB"
            aviso "POR ESO los tamaños de abajo son COTA SUPERIOR y no lo que se recupera"
        else
            fallo "el control del clon no se comporta como se esperaba" \
                  "du=${du_dos} KiB   coste real segun df=${coste_real} KiB"
        fi
    else
        omitido "cp -c falló: este sistema de ficheros no clona, así que du puede ser fiable aquí"
    fi
else
    omitido "no se pudo crear el fichero del control"
fi

paso "Control 3: la fecha del último arranque es un PROXY, no una medición"
omitido "se lee el mtime de Data/efi_vars.fd, que el firmware reescribe al arrancar."
echo "          No se ha comprobado arrancando una VM y viendo cambiar la fecha:"
echo "          eso cuesta un arranque y no se ha hecho. Trátalo como indicio."

# ---------------------------------------------------------------------------
# LA MEDICIÓN
# ---------------------------------------------------------------------------
titulo "EL BANCO"

if [[ ! -d "$VMS_DIR" ]]; then
    fallo "no existe el directorio de VMs" "$VMS_DIR"
    resumen; exit 1
fi

libres=$(df -h "$HOME" | tail -1 | awk '{print $4}')
echo "  Disco: ${libres} libres"
echo "  VMs en: $VMS_DIR"
echo "  Documentos: $DOCS_DIR"
echo

printf '  %-24s %8s  %-12s %-8s %s\n' "VM" "du" "últ.arranque" "días" "respaldo documental"
printf '  %-24s %8s  %-12s %-8s %s\n' "------------------------" "--------" "------------" "--------" "-------------------"

hoy=$(date +%s)
total_kb=0
n_vms=0
declare -a SIN_RESPALDO=()
declare -a EN_USO=()

for vm in "$VMS_DIR"/*.utm; do
    [[ -d "$vm" ]] || continue
    n_vms=$((n_vms+1))
    nombre="$(basename "$vm" .utm)"

    kb=$(du -sk "$vm" | awk '{print $1}')
    total_kb=$((total_kb + kb))
    tam=$(du -sh "$vm" | awk '{print $1}')

    efi="$vm/Data/efi_vars.fd"
    if [[ -f "$efi" ]]; then
        fecha=$(stat -f '%Sm' -t '%Y-%m-%d' "$efi")
        seg=$(stat -f '%m' "$efi")
        dias=$(( (hoy - seg) / 86400 ))
    else
        fecha="-"; dias="-"
    fi

    men="$(menciones "$nombre")"
    n_men="${men%%|*}"
    d_men="${men#*|}"

    # ¿La está usando UTM ahora mismo? Si un proceso tiene abierto algo de
    # dentro, la VM está arrancada o suspendida y NO se toca.
    if lsof +D "$vm/Data" >/dev/null 2>&1 && [[ -n "$(lsof -t +D "$vm/Data" 2>/dev/null || true)" ]]; then
        marca="EN USO"
        EN_USO+=("$nombre")
    else
        marca=""
    fi

    printf '  %-24s %8s  %-12s %-8s %s %s\n' \
        "$nombre" "$tam" "$fecha" "$dias" "${d_men:-—}" "$marca"

    if [[ "$n_men" == "0" ]]; then SIN_RESPALDO+=("$nombre"); fi
done

echo
printf '  %-24s %8s\n' "TOTAL ($n_vms VMs)" "$(( total_kb / 1024 / 1024 )) GiB"
aviso "ese total es la suma de 'du', o sea la COTA SUPERIOR del control 2"

# ---------------------------------------------------------------------------
# LO QUE HAY QUE MIRAR, que no es lo mismo que lo que hay que borrar
# ---------------------------------------------------------------------------
titulo "PARA DECIDIR"

if (( ${#EN_USO[@]} > 0 )); then
    for v in "${EN_USO[@]}"; do
        aviso "$v tiene ficheros abiertos: está arrancada o suspendida. No se toca."
    done
else
    ok "ninguna VM tiene ficheros abiertos ahora mismo"
fi

if (( ${#SIN_RESPALDO[@]} > 0 )); then
    for v in "${SIN_RESPALDO[@]}"; do
        aviso "$v no aparece en ningún documento — MÍRALA ANTES DE NADA, en los dos sentidos: puede ser basura, o puede ser lo único que queda de algo que nadie escribió"
    done
else
    ok "todas las VMs aparecen citadas en algún documento"
fi

omitido "qué VM se borra. Es [OJOS] de Jorge, y el guion no lo va a decidir."
echo "          Y cuando decidas, mide el hueco de verdad:"
echo
echo "            df -h $HOME | tail -1        # antes"
echo "            rm -rf <la VM>.utm"
echo "            df -h $HOME | tail -1        # después"
echo
echo "          Si el segundo número no sube lo que decía 'du', la VM compartía"
echo "          bloques con otra — que es lo que midió §4.29 y por qué existe"
echo "          el control 2 de este guion."

resumen
