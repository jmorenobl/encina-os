#!/usr/bin/env bash
# capturar-aspecto.sh — las pantallas canonicas de una VM, desde frio.
#
#     ./scripts/capturar-aspecto.sh <nombre VM> <directorio de salida> [--segundos N]
#
# POR QUE NO CRONOMETRA LAS PANTALLAS, QUE ES LO QUE PARECIA. Un guion con
# 'sleep 10; captura; sleep 15; captura' produce una foto de lo que hubiera a
# los 10 segundos, y eso cambia con la carga del anfitrion, con el estado del
# disco y con la version del firmware. El dia que se desplace medio segundo, la
# captura sale movida Y NADIE SE ENTERA, porque un PNG borroso no da error.
#
# Lo que hace en su lugar: dispara EN RAFAGA todo el arranque y despues AGRUPA
# los fotogramas consecutivos que son identicos byte a byte. Cada grupo es una
# FASE -- una pantalla que estuvo quieta un rato -- y de cada fase se guarda el
# ultimo fotograma. Las fases se detectan, no se suponen: si manana el arranque
# tarda el doble, salen las mismas fases con otros tiempos.
#
# Y el control que hace que la comparacion signifique algo, que es lo que pedia
# la casilla: dos pasadas seguidas sin tocar nada tienen que dar las mismas
# fases. Lo comprueba scripts/diferencia.py, que dice cuantos pixeles cambian y
# EN QUE CAJA -- no hace falta creerselo, sale el numero.
#
# LO QUE ESTE GUION NO PUEDE HACER SOLO, dicho por delante: pasar de GDM. Entrar
# en la sesion exige la contrasena del usuario, que no vive en este repositorio
# -encina-95758c9e se instalo contestando las cinco pantallas a mano-. Sin ella
# se paran en el saludador y se dice cual falta. Con ella:
#
#     ENCINA_CLAVE='...' ./scripts/capturar-aspecto.sh encina-95758c9e salida/
#
# El raton NO llega al invitado (§4.35i); el teclado si (teclear-vm.sh). Todo lo
# de dentro de la sesion se hace con teclas.

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export ENCINA_REPO="$RAIZ"
source "$RAIZ/scripts/lib.sh"
requiere_no_root
requiere_cmd utmctl shasum python3

# LA FRANJA DE ARRIBA NO CUENTA, y el numero no es a ojo. La primera version de
# este guion agrupaba por la huella del PNG entero y saco CINCO fases donde hay
# cuatro: el reloj del invitado cambia de minuto y parte GDM en dos. Medido con
# scripts/diferencia.py entre dos pasadas: 276 y 292 pixeles distintos, todos
# dentro de la caja y 6..119 -- el reloj (13:22 -> 13:24) y la barra de UTM, que
# ni siquiera es del invitado. 130 cubre esa caja con margen.
#
# Se recorta SOLO para agrupar y para comparar. Lo que se guarda es la captura
# entera: la barra superior de GNOME es parte de la cara del producto.
FRANJA=130

# --------------------------------------------------------------- comparar ---
# El control de la casilla: dos pasadas tienen que dar las mismas pantallas.
#     ./scripts/capturar-aspecto.sh --comparar <dirA> <dirB>
# Pasa si no cambia ni un pixel POR DEBAJO de la franja. Lo de dentro de la
# franja se cuenta y se ensena, pero no falla: ahi viven el reloj del invitado y
# la barra de UTM, y ninguno de los dos es el producto.
if [[ "${1:-}" == "--comparar" ]]; then
    A="${2:?uso: --comparar <dirA> <dirB>}"; B="${3:?uso: --comparar <dirA> <dirB>}"
    titulo "Control: dos pasadas, fase a fase"
    # Cuantos fotogramas duro cada fase, de fases.tsv.
    fotogramas() { awk -F'\t' -v f="$2" '$5==f {print $4}' "$1/fases.tsv"; }
    for fa in "$A"/[0-9][0-9]-fase.png; do
        n="$(basename "$fa")"; fb="$B/$n"
        if [[ ! -f "$fb" ]]; then
            fallo "$n: no existe en la segunda pasada" "$fb"
            continue
        fi
        # UNA FASE DE UN SOLO FOTOGRAMA NO ES UNA PANTALLA: es una animacion
        # cazada al vuelo. Medido el 2026-08-14: la primera fase es la barra de
        # progreso del firmware ("Start boot option"), y salio al 65% en una
        # pasada y al 33% en la otra. Exigirle que coincida seria exigir que las
        # dos pasadas dispararan en el mismo milisegundo. Se registra -es dato-
        # pero no se compara, y por eso la regla mira los FOTOGRAMAS y no el
        # contenido: no hay forma de aflojarla sin que se note.
        na="$(fotogramas "$A" "$n")"; nb="$(fotogramas "$B" "$n")"
        if [[ "${na:-0}" -lt 2 || "${nb:-0}" -lt 2 ]]; then
            omitido "$n: transitoria ($na y $nb fotogramas) -- no es una pantalla, no se compara"
            continue
        fi
        sal="$(python3 "$RAIZ/scripts/diferencia.py" "$fa" "$fb")"
        if [[ "$sal" == IGUALES* ]]; then
            ok "$n: identica byte a byte"
        else
            # OJO con awk aqui: '..' en split() es una EXPRESION REGULAR -dos
            # caracteres cualesquiera-, no dos puntos literales. La primera
            # version leia la caja mal y daba [FALLO] sobre diferencias que
            # estaban DENTRO de la franja. sed con los puntos escapados.
            ymax="$(echo "$sal" | sed -n 's/.*y [0-9]*\.\.\([0-9]*\).*/\1/p')"
            npx="$(echo "$sal" | sed -n 's/^pixeles distintos: \([0-9]*\)$/\1/p')"
            if [[ -n "$ymax" ]] && (( ymax < FRANJA )); then
                aviso "$n: $npx pixeles, todos en la franja de arriba (y<=$ymax) -- reloj y barra de UTM"
            else
                fallo "$n: cambia POR DEBAJO de la franja" "$sal"
            fi
        fi
    done
    resumen; exit $?
fi

VM="${1:?uso: capturar-aspecto.sh <nombre VM> <directorio> [--segundos N]}"
SALIDA="${2:?uso: capturar-aspecto.sh <nombre VM> <directorio> [--segundos N]}"
SEGUNDOS=80
[[ "${3:-}" == "--segundos" ]] && SEGUNDOS="${4:?falta el numero}"

CRUDAS="$SALIDA/crudas"
FASES="$SALIDA/fases.tsv"

# La huella de la captura SIN la franja de arriba. Es con la que se agrupa.
# No la hace sips: 'sips --cropOffset' devuelve el fichero entero sin recortar y
# sin decir nada -- medido, y esta escrito en huella-recorte.py.
huella_sin_franja() {
    python3 "$RAIZ/scripts/huella-recorte.py" "$1" "$FRANJA"
}

titulo "Pantallas canonicas de $VM"

# ------------------------------------------------------------- desde frio ---
# Una VM pausada o ya arrancada no ensena el arranque, y ese es medio trabajo.
paso "Apagando para arrancar desde frio"
ESTADO="$(utmctl status "$VM" 2>&1 || true)"
echo "  estado de partida: $ESTADO"
if [[ "$ESTADO" != "stopped" ]]; then
    utmctl stop "$VM" >/dev/null 2>&1 || true
    for _ in $(seq 1 30); do
        [[ "$(utmctl status "$VM" 2>&1 || true)" == "stopped" ]] && break
        /bin/sleep 1
    done
fi
comprobar_salida "la VM esta parada antes de empezar" "^stopped$" utmctl status "$VM"

rm -rf "$SALIDA"; mkdir -p "$CRUDAS"

# ---------------------------------------------------------------- rafaga ----
paso "Arrancando y disparando en rafaga durante ${SEGUNDOS}s"
utmctl start "$VM" >/dev/null 2>&1 &
T0=$(date +%s)
N=0
while (( $(date +%s) - T0 < SEGUNDOS )); do
    N=$((N + 1))
    F="$(printf '%s/%03d.png' "$CRUDAS" "$N")"
    "$RAIZ/scripts/capturar-vm.sh" "$VM" "$F" >/dev/null 2>&1 || true
    if [[ -s "$F" ]]; then
        printf '%s\t%s\t%s\t%s\n' "$N" "$(( $(date +%s) - T0 ))" \
            "$(shasum -a 256 "$F" | awk '{print $1}')" "$(huella_sin_franja "$F")" \
            >> "$CRUDAS/tiempos.tsv"
    else
        rm -f "$F"
    fi
done

if [[ ! -s "$CRUDAS/tiempos.tsv" ]]; then
    fallo "no se tomo ni una captura" \
"capturar-vm.sh no escribio nada. La causa habitual es el permiso de Grabacion
de Pantalla del terminal, y su sintoma es 'could not create image from display'."
    resumen; exit 1
fi
ok "$(wc -l < "$CRUDAS/tiempos.tsv" | tr -d ' ') fotogramas en ${SEGUNDOS}s"

# ------------------------------------------------------------------ fases ---
# Fase = fotogramas CONSECUTIVOS con la misma huella. Se guarda el ultimo de
# cada una: es el que ya no tiene animacion a medias.
paso "Agrupando en fases"
printf 'fase\tdesde_s\thasta_s\tfotogramas\tfichero\tsha256_sin_franja\n' > "$FASES"
python3 - "$CRUDAS" "$SALIDA" "$FASES" <<'PY'
import sys, os, shutil
crudas, salida, fases = sys.argv[1], sys.argv[2], sys.argv[3]
filas = [l.rstrip("\n").split("\t") for l in open(os.path.join(crudas, "tiempos.tsv"))]
grupos, act = [], None
for n, t, _entera, h in filas:
    if act and act["sha"] == h:
        act["hasta"], act["n"], act["ultimo"] = t, act["n"] + 1, n
    else:
        act = {"sha": h, "desde": t, "hasta": t, "n": 1, "ultimo": n}
        grupos.append(act)
with open(fases, "a") as f:
    for i, g in enumerate(grupos, 1):
        dst = f"{i:02d}-fase.png"
        shutil.copy(os.path.join(crudas, f"{int(g['ultimo']):03d}.png"),
                    os.path.join(salida, dst))
        f.write(f"{i}\t{g['desde']}\t{g['hasta']}\t{g['n']}\t{dst}\t{g['sha']}\n")
print(f"  fases: {len(grupos)}")
for i, g in enumerate(grupos, 1):
    print(f"    {i:02d}  {g['desde']:>3}s..{g['hasta']:>3}s  {g['n']:>2} fotogramas  {g['sha'][:12]}...")
PY

NFASES=$(( $(wc -l < "$FASES") - 1 ))
if (( NFASES < 2 )); then
    fallo "solo se detecto $NFASES fase" \
"Una sola fase significa que la pantalla no cambio en todo el arranque, o que
la ventana capturada no es la de la VM. Mira $CRUDAS."
else
    ok "$NFASES fases detectadas, cada una con su fotograma"
fi

# ----------------------------------------------------------------- sesion ---
paso "La sesion"
if [[ -z "${ENCINA_CLAVE:-}" ]]; then
    omitido "no hay ENCINA_CLAVE: las pantallas de dentro de la sesion no se toman"
    echo "      Faltan escritorio, rejilla de aplicaciones y las dos ventanas."
    echo "      Exportala y vuelve a lanzarlo para tomarlas."
else
    "$RAIZ/scripts/teclear-vm.sh" "$VM" texto "$ENCINA_CLAVE" >/dev/null 2>&1 || true
    "$RAIZ/scripts/teclear-vm.sh" "$VM" tecla 36 >/dev/null 2>&1 || true   # intro
    /bin/sleep 25
    "$RAIZ/scripts/capturar-vm.sh" "$VM" "$SALIDA/escritorio.png" >/dev/null 2>&1 || true
    comprobar_fichero "escritorio.png" "$SALIDA/escritorio.png"
    # La rejilla: el dock no se puede pulsar, pero GNOME la abre con teclado.
    "$RAIZ/scripts/teclear-vm.sh" "$VM" tecla 53 >/dev/null 2>&1 || true   # esc
    "$RAIZ/scripts/teclear-vm.sh" "$VM" tecla 55 >/dev/null 2>&1 || true   # super
    /bin/sleep 3
    "$RAIZ/scripts/capturar-vm.sh" "$VM" "$SALIDA/rejilla.png" >/dev/null 2>&1 || true
    comprobar_fichero "rejilla.png" "$SALIDA/rejilla.png"
    pendiente_visual "mira rejilla.png: si es el resumen y no la rejilla, la tecla Super no llego"
fi

paso "Salida"
echo "  $SALIDA"
ls -1 "$SALIDA"/*.png 2>/dev/null | sed 's|^|    |'
echo
echo "  El control de esta casilla NO lo da este guion: lo da la SEGUNDA pasada."
echo "  Lanzalo otra vez a otro directorio y compara fase a fase:"
echo "      python3 scripts/diferencia.py <a>/NN-fase.png <b>/NN-fase.png"

resumen
