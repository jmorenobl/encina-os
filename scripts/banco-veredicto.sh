#!/usr/bin/env bash
# Encina OS - BANCO DEL VEREDICTO DE PANTALLA.
#
#     ./scripts/banco-veredicto.sh
#
# QUE COMPRUEBA: que la regla de scripts/veredicto-pantalla.py sabe decir LAS DOS
# COSAS -- NEGRA sobre una pantalla negra conocida y GRAFICA sobre una sesion
# grafica conocida -- y que un sabotaje se le nota.
#
# POR QUE EXISTE. Este veredicto se construyo para CONTAR quince arranques, y el
# 2026-08-20 un solo arranque negro mal leido costo una causa falsa (trampa 42).
# Un contador de arranques que solo sepa decir "arranco" no es un contador: dice
# que si a todo y el conteo sale perfecto y falso. Aqui se gasta contra los dos
# extremos y contra tres sabotajes.
#
# LOS CONTROLES SON CAPTURAS DE VERDAD, no imagenes fabricadas para pasar:
#   control-negra.png                 el framebuffer de encina-capa-p14 tras un
#                                     arranque fallido (2026-08-20)
#   control-grafica.png               encina-capa-p12 parada DESDE el instalador
#                                     (2026-08-20), fondo de Encina
#   control-grafica-fondo-ubuntu.png  encina-nutria, capa inerte: el instalador
#                                     con el fondo PURPURA de Ubuntu, que es el
#                                     control grafico mas POBRE en colores (585)
#                                     y por tanto el que aprieta el umbral
#
# LA EXTRACCION ES DEL GUION, NO UNA COPIA: se saca el bloque entre los
# marcadores 'INICIO REGLA' y 'FIN REGLA'. Si sale corta se NIEGA a medir,
# porque un banco sobre una regla vacia contesta que si a todo.

set -uo pipefail
export LC_ALL=C
AQUI=$(cd "$(dirname "$0")" && pwd)
FUENTE="$AQUI/veredicto-pantalla.py"
CONTROLES="$AQUI/pruebas/veredicto"
[ -f "$FUENTE" ] || { echo "[FALLO] no esta $FUENTE" >&2; exit 1; }

TMP=$(mktemp -d) || exit 1
trap 'rm -rf "$TMP"' EXIT

# ------------------------------------------------------------- extraccion ---
sed -n '/# --- INICIO REGLA ---/,/# --- FIN REGLA ---/p' "$FUENTE" > "$TMP/regla.py"
N_L=$(/usr/bin/grep -c . "$TMP/regla.py")
N_C=$(/usr/bin/grep -c '^[A-Z_]*_[A-Z]* = ' "$TMP/regla.py")
N_R=$(/usr/bin/grep -c 'return "' "$TMP/regla.py")
if [ "$N_L" -lt 12 ] || [ "$N_C" -lt 4 ] || [ "$N_R" -lt 4 ]; then
    echo "[FALLO] la extraccion sale corta: $N_L lineas, $N_C umbrales, $N_R salidas"
    echo "        Esperaba >=12 lineas, >=4 umbrales y >=4 salidas distintas."
    echo "        NO se mide: un banco sobre una regla vacia contesta que si a todo."
    exit 1
fi
echo "== extraidas $N_L lineas con $N_C umbrales y $N_R salidas de $(basename "$FUENTE")"

# Lector de pixeles INDEPENDIENTE de la regla: el banco mide los datos por su
# cuenta y solo le pide a la regla que los clasifique.
medir() {   # <png> -> "colores brillo"
    ffmpeg -v error -i "$1" -vf format=rgb24 -f rawvideo - 2>/dev/null | python3 -c '
import sys
d = sys.stdin.buffer.read()
v = set()
for i in range(0, len(d)-2, 3): v.add((d[i]>>3, d[i+1]>>3, d[i+2]>>3))
print(len(v), round(sum(d)/len(d), 2))'
}

# aplica <fichero de regla> <colores> <brillo> -> veredicto
aplica() {
    python3 -c '
import sys
g = {}
exec(open(sys.argv[1]).read(), g)
print(g["clasificar"](int(sys.argv[2]), float(sys.argv[3]))[0])' "$1" "$2" "$3"
}

N_OK=0; N_MAL=0
comp() {   # rotulo esperado obtenido
    if [ "$2" = "$3" ]; then N_OK=$((N_OK+1)); echo "  [OK]    $1"
    else N_MAL=$((N_MAL+1)); echo "  [FALLO] $1"
         echo "          esperaba: $2"; echo "          obtuvo  : $3"; fi
}

# ------------------------------------------------------ 1. los dos extremos --
echo
echo "== 1. LAS DOS RESPUESTAS, sobre capturas de verdad"
for par in "control-negra.png NEGRA" \
           "control-grafica.png GRAFICA" \
           "control-grafica-fondo-ubuntu.png GRAFICA"; do
    set -- $par
    F="$CONTROLES/$1"; ESP="$2"
    if [ ! -f "$F" ]; then
        N_MAL=$((N_MAL+1)); echo "  [FALLO] falta el control $1 -- sin el no se mide nada"
        continue
    fi
    read -r C B <<<"$(medir "$F")"
    comp "$1: $C colores, brillo $B -> $ESP" "$ESP" "$(aplica "$TMP/regla.py" "$C" "$B")"
done

# ------------------------------------------------- 2. el control por COLUMNA --
echo
echo "== 2. CONTROL POR COLUMNA: la regla tiene que DISTINGUIR, no acertar por"
echo "      quedarse muda. Una que conteste siempre lo mismo acertaria la mitad."
read -r CN BN <<<"$(medir "$CONTROLES/control-negra.png")"
read -r CG BG <<<"$(medir "$CONTROLES/control-grafica.png")"
VN=$(aplica "$TMP/regla.py" "$CN" "$BN"); VG=$(aplica "$TMP/regla.py" "$CG" "$BG")
if [ "$VN" = "$VG" ]; then
    N_MAL=$((N_MAL+1)); echo "  [FALLO] CONTROL ROTO: negra y grafica dan el MISMO veredicto ($VN)"
else
    N_OK=$((N_OK+1)); echo "  [OK]    negra -> $VN  y  grafica -> $VG : la regla separa las dos columnas"
fi
# separacion medida, para que quede escrito cuanto margen hay
echo "          margen: $CN colores frente a $CG, brillo $BN frente a $BG"

# --------------------------------------------------------- 3. LA ESCALA -----
echo
echo "== 3. LA TRAMPA 41: el veredicto NO puede depender de la escala"
echo "      (el TAMANO del PNG si dependia, y por eso no se usa)"
for par in "control-negra.png NEGRA" "control-grafica-fondo-ubuntu.png GRAFICA"; do
    set -- $par
    ffmpeg -v error -y -i "$CONTROLES/$1" -vf scale=640:400 "$TMP/mitad-$1" 2>/dev/null
    read -r C B <<<"$(medir "$TMP/mitad-$1")"
    comp "$1 a la MITAD (640x400): $C colores, brillo $B -> sigue $2" \
         "$2" "$(aplica "$TMP/regla.py" "$C" "$B")"
done

# ------------------------------------------------------- 4. los sabotajes ---
echo
echo "== 4. TRES SABOTAJES: si la regla esta rota, esto tiene que decirlo"
sabotaje() {   # rotulo  sed-expr  fichero-control  veredicto-que-YA-NO-debe-salir
    sed "$2" "$TMP/regla.py" > "$TMP/roto.py"
    if cmp -s "$TMP/regla.py" "$TMP/roto.py"; then
        N_MAL=$((N_MAL+1)); echo "  [FALLO] el sabotaje '$1' no cambio la regla: el sed no pego"
        return
    fi
    read -r C B <<<"$(medir "$CONTROLES/$3")"
    V=$(aplica "$TMP/roto.py" "$C" "$B")
    if [ "$V" = "$4" ]; then
        N_MAL=$((N_MAL+1)); echo "  [FALLO] sabotaje '$1' NO se nota: $3 sigue dando $4"
    else
        N_OK=$((N_OK+1)); echo "  [OK]    sabotaje '$1' cazado: $3 pasa de $4 a $V"
    fi
}
# a) la banda de negra tragandoselo todo: es lo que pasaria si el umbral se
#    subiera "para no perder arranques dudosos".
sabotaje "banda NEGRA hasta 100000 colores y brillo 1000" \
    -e's/^NEGRA_COLORES = .*/NEGRA_COLORES = 100000/;s/^NEGRA_BRILLO = .*/NEGRA_BRILLO = 1000.0/' \
    control-grafica.png GRAFICA
# b) LA BANDA DE NEGRA DESACTIVADA. Es la familia del sabotaje que banco-mecanismos.sh
#    encontro que no sabia cazar en su columna de la capa, y aqui si se caza.
sabotaje "banda NEGRA desactivada: deja de poder decir NEGRA" \
    -e's/^    if colores <= NEGRA_COLORES.*/    if False:/' \
    control-negra.png NEGRA
# c) el umbral apretado de mas: 200 deja fuera al control de 194,6.
sabotaje "GRAFICA_BRILLO subido a 200, por encima del control (194,6)" \
    -e's/^GRAFICA_BRILLO = .*/GRAFICA_BRILLO = 200.0/' \
    control-grafica.png GRAFICA

echo
echo "correctas: $N_OK   fallos: $N_MAL"
[ "$N_MAL" -eq 0 ] || exit 1
