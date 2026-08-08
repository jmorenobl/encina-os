#!/usr/bin/env bash
# 11-meta-instalar.sh — Instala encina-meta y ejecuta la secuencia de tres
# órdenes, comprobando en cada paso lo que debe verse y lo que no.
#
# Uso:  ./scripts/11-meta-instalar.sh [--si-ya-cloné] [--sin-firefox]
#
#   --si-ya-cloné   sáltate la pregunta del respaldo
#   --sin-firefox   para en el paso 2: deja el repositorio puesto y NO cambia
#                   Firefox. Sirve para mirar el estado intermedio.
#
# LA SECUENCIA SON TRES ÓRDENES Y NO UNA, y está medida (MEDICIONES.md §4.10):
#
#   1. apt install ./los-cuatro-deb          <- aquí Firefox NO cambia
#   2. apt update                            <- aquí apt lee el repo de Mozilla
#   3. apt full-upgrade + firefox-l10n-es-es <- aquí llega el nativo, y en español
#
# El paso 3 no lo hace 'apt upgrade': el cambio es formalmente una
# desactualización, por el epoch 1: del paquete de transición de Ubuntu.
#
# Toda la salida de apt se pide con LC_ALL=C: en una VM en español "Candidate"
# se llama "Candidato" y cualquier comprobación en inglés daría falso negativo.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
requiere_no_root

SALIDA_DIR="$(raiz_repo)/debian-packages"

CON_FIREFOX=1
CLONADO=0
for arg in "$@"; do
    case "$arg" in
        --si-ya-cloné|--si-ya-clone) CLONADO=1 ;;
        --sin-firefox)               CON_FIREFOX=0 ;;
        *) echo "Opción desconocida: $arg"; exit 1 ;;
    esac
done

if (( ! CLONADO )); then
    echo
    echo "${C_AVI}Antes de seguir:${C_FIN} ¿has clonado la VM en UTM?"
    echo "  Este script cambia la configuración de repositorios del sistema y"
    echo "  sustituye el Firefox de Ubuntu por el de Mozilla. No se deshace con"
    echo "  un apt purge."
    echo
    echo "  Y NO metas aquí tu certificado de la FNMT: esta máquina se conserva."
    echo "  La firma real va en un clon aparte que se destruye (ENCINA-OS.md §9.1)."
    echo
    read -r -p "Escribe 'si' para continuar: " resp
    [[ "$resp" == "si" ]] || { echo "Clónala y vuelve. Tarda dos minutos."; exit 1; }
fi

# ============================================================================
titulo "0. Los cuatro paquetes, y el que no se construye aquí"

DEB_META=$(ls -t "$SALIDA_DIR"/encina-meta_*.deb 2>/dev/null | head -1 || true)
DEB_BRAND=$(ls -t "$SALIDA_DIR"/encina-branding_*.deb 2>/dev/null | head -1 || true)
DEB_FFN=$(ls -t "$SALIDA_DIR"/encina-firefox-native_*.deb 2>/dev/null | head -1 || true)
DEB_AF=$(ls -t "$SALIDA_DIR"/autofirma_*.deb ~/autofirma_*.deb 2>/dev/null | head -1 || true)

for par in "encina-meta:$DEB_META" "encina-branding:$DEB_BRAND" "encina-firefox-native:$DEB_FFN"; do
    n="${par%%:*}"; f="${par#*:}"
    if [[ -n "$f" ]]; then ok "$n: $(basename "$f")"; else fallo "Falta el .deb de $n" "constrúyelo antes"; fi
done

# autofirma no se construye en este repositorio: vive en ~/Projects/encina-autofirma
# y su CI lo publica como artefacto. Es la trampa 2 de AGENTS.md §6.3, dicha por
# adelantado en vez de descubierta: el Depends es correcto pero insatisfacible
# hasta que exista el repo local de E2, así que el .deb se pone al lado a mano.
if [[ -n "$DEB_AF" ]]; then
    ok "autofirma: $(basename "$DEB_AF")"
else
    fallo "Falta el .deb de autofirma" \
"No se construye en este repositorio. Bájalo del artefacto de su CI:

    gh run download <ID> -n autofirma-arm64 -R jmorenobl/encina-autofirma

y déjalo en $SALIDA_DIR o en tu \$HOME.

Sin él, 'apt install ./encina-meta.deb' falla por dependencia insatisfecha, y
eso es CORRECTO: encina-meta describe el producto entero (AGENTS.md §6.3)."
fi
(( N_MAL == 0 )) || { resumen; exit 1; }

# ============================================================================
titulo "1. Estado de partida (para poder comparar después)"

FF_ANTES=$(LC_ALL=C dpkg-query -W -f='${Version}' firefox 2>/dev/null || echo "(no instalado)")
echo "  paquete deb firefox:  $FF_ANTES"
SNAP_ANTES=$(snap list firefox 2>/dev/null | tail -n +2 || echo "(sin snap de firefox)")
echo "  snap de firefox:      $SNAP_ANTES"
ENCINA_ANTES=$(LC_ALL=C dpkg-query -W -f='${Package} ${Version}\n' 'encina-*' 2>/dev/null | grep -v 'no packages' || echo "(ninguno)")
echo "  paquetes de encina:   ${ENCINA_ANTES//$'\n'/, }"

# La premisa entera de que encina-meta pueda NO declarar firefox es que el
# nombre ya esté instalado. Si esta máquina no lo tiene, la vía no existe y hay
# que instalarlo explícitamente (MEDICIONES.md §4.10d).
if [[ "$FF_ANTES" == 1:* ]]; then
    ok "Esta máquina trae el paquete de transición de Ubuntu ($FF_ANTES)"
    echo "         Es la premisa de la vía: el anclaje reasignará ESE nombre al deb de Mozilla."
elif [[ "$FF_ANTES" == "(no instalado)" ]]; then
    aviso "Esta máquina NO tiene el paquete firefox instalado"
    echo "         La vía medida no aplica aquí: sin un 'firefox' instalado, el"
    echo "         full-upgrade del paso 3 no traerá nada (MEDICIONES.md §4.10d)."
    echo "         Habría que instalarlo a mano tras el apt update."
else
    aviso "El firefox instalado ($FF_ANTES) no es el de transición ni falta: revisa en qué VM estás"
fi

# ============================================================================
titulo "2. PASO 1 — los cuatro .deb, en una sola transacción"

paso "sudo apt install (hace falta sudo)"
if INS=$(sudo LC_ALL=C apt-get install -y "$DEB_META" "$DEB_BRAND" "$DEB_FFN" "$DEB_AF" 2>&1); then
    ok "Los cuatro paquetes se instalan y apt sale con 0"
else
    fallo "La instalación ha fallado" "$(echo "$INS" | tail -25)"
    resumen; exit 1
fi

for p in encina-meta encina-branding encina-firefox-native autofirma; do
    EST=$(LC_ALL=C dpkg-query -W -f='${Status}' "$p" 2>/dev/null || echo "")
    if [[ "$EST" == "install ok installed" ]]; then
        ok "$p instalado"
    else
        fallo "$p no ha quedado instalado" "$(LC_ALL=C dpkg -l "$p" 2>&1 | tail -3)"
    fi
done

# --- El paquete no instala ficheros -----------------------------------------
# 'dpkg -L' lista los directorios SIN barra final y empieza por '/.', que es
# otro formato que el de 'dpkg-deb -c'. Los dos patrones son distintos a
# propósito: uno mira el .deb y el otro lo instalado.
FICHEROS=$(dpkg -L encina-meta 2>/dev/null \
           | grep -vE '^/\.$|^/(usr(/share(/doc(/encina-meta(/.*)?)?)?)?)?$' || true)
if [[ -z "$FICHEROS" ]]; then
    ok "encina-meta no ha instalado ni un fichero fuera de /usr/share/doc/"
else
    fallo "encina-meta ha instalado ficheros propios" "$FICHEROS"
fi

# --- LA COMPROBACIÓN QUE DELATARÍA UN 'Depends: firefox' --------------------
# Sano: aquí Firefox NO se ha tocado, sigue siendo el de transición.
# Roto: si ya apareciera una versión de Mozilla, alguien ha declarado firefox
#       y apt lo habría resuelto contra el índice de Ubuntu (o peor, habría
#       instalado el Snap). Es MEDICIONES.md §4.10e.
FF_P1=$(LC_ALL=C dpkg-query -W -f='${Version}' firefox 2>/dev/null || echo "(no instalado)")
if [[ "$FF_P1" == "$FF_ANTES" ]]; then
    ok "El paso 1 no ha tocado Firefox (sigue en $FF_P1)"
else
    fallo "El paso 1 ha cambiado Firefox, y no debería" \
"antes: $FF_ANTES
ahora: $FF_P1
Alguien ha declarado firefox en alguna parte. Mira AGENTS.md §6.3 y para."
fi

SNAP_P1=$(snap list firefox 2>/dev/null | tail -n +2 || echo "(sin snap de firefox)")
if [[ "$SNAP_P1" == "$SNAP_ANTES" ]]; then
    ok "El paso 1 no ha tocado el Snap (R4)"
else
    fallo "El Snap ha cambiado durante el paso 1" "antes: $SNAP_ANTES
ahora: $SNAP_P1"
fi

# --- El control de la decisión sobre Thunderbird ----------------------------
# Los Recommends de este paquete no deben arrastrar snapd. thunderbird-locale-es
# lo hacía —es un transitorio que depende de thunderbird, con Pre-Depends: snapd
# (MEDICIONES.md §4.10h)— y por eso se quitó. Esta comprobación es la que
# impediría que volviera sin que nadie lo note.
RECS=$(LC_ALL=C dpkg-query -W -f='${Recommends}' encina-meta 2>/dev/null | tr ',' ' ' || true)
if [[ -n "$RECS" ]]; then
    PLAN_RECS=$(LC_ALL=C apt-get -s install --no-install-recommends $RECS 2>&1 || true)
    if grep -qE '^Inst (snapd|thunderbird) ' <<<"$PLAN_RECS"; then
        fallo "Un Recommends de encina-meta arrastra el Snap" \
"$(grep -E '^Inst (snapd|thunderbird) ' <<<"$PLAN_RECS")
En un producto cuyo motivo es no depender del Snap, eso necesita decisión
explícita (MEDICIONES.md §4.10h)."
    else
        ok "Ningún Recommends de encina-meta arrastra snapd ni thunderbird"
    fi
    # Control: la comprobación tiene que saber decir que sí.
    PLAN_CTRL=$(LC_ALL=C apt-get -s install --no-install-recommends thunderbird-locale-es 2>&1 || true)
    if grep -qE '^Inst (snapd|thunderbird) ' <<<"$PLAN_CTRL"; then
        ok "El control funciona: con thunderbird-locale-es, la comprobación salta"
    else
        aviso "El control no ha saltado; puede que thunderbird ya esté instalado aquí"
        echo "         $(grep -E 'upgraded,' <<<"$PLAN_CTRL" || true)"
    fi
else
    omitido "encina-meta no declara ningún Recommends"
fi

# ============================================================================
titulo "3. PASO 2 — apt update, que ningún paquete puede lanzar por sí mismo"
echo "  Llamar a apt desde un script de mantenedor provoca un interbloqueo,"
echo "  porque dpkg mantiene el bloqueo mientras corre el script (R3)."
echo

paso "sudo apt update"
if UPD=$(sudo LC_ALL=C apt-get update 2>&1); then
    ok "apt update termina sin error"
else
    fallo "apt update ha fallado" "$UPD"
fi
if grep -qiE "NO_PUBKEY|GPG error|not signed" <<<"$UPD"; then
    fallo "apt no verifica la firma del repositorio de Mozilla" \
"$(grep -iE 'NO_PUBKEY|GPG|signed' <<<"$UPD" || true)"
else
    ok "Ninguna queja de firma"
fi

POL=$(LC_ALL=C apt-cache policy firefox 2>&1)
echo "$POL" | sed 's/^/    /'
CAND=$(awk '/Candidate:/ {print $2}' <<<"$POL")
BLOQUE=$(grep -A1 -F " $CAND " <<<"$POL" | head -2)
if grep -q "packages.mozilla.org" <<<"$BLOQUE"; then
    ok "Tras el apt update, el candidato de firefox sale de Mozilla ($CAND)"
else
    fallo "El candidato de firefox NO sale de Mozilla" \
"$POL
Sin esto, el paso 3 devolvería el Snap. El anclaje no está haciendo efecto:
ojo con que 'Pin: origin' casa con el nombre de máquina, no con el campo
Origin: del fichero Release (AGENTS.md §5.2)."
fi
if grep -qE '(^|[[:space:]])1000([[:space:]]|$)' <<<"$BLOQUE"; then
    ok "Con prioridad 1000"
else
    fallo "El candidato no tiene prioridad 1000" "$BLOQUE"
fi

if (( ! CON_FIREFOX )); then
    titulo "4. PASO 3 — OMITIDO por --sin-firefox"
    omitido "sudo apt full-upgrade"
    omitido "sudo apt install firefox-l10n-es-es"
    resumen; exit $?
fi

# ============================================================================
titulo "4. PASO 3 — el cambio a Firefox nativo, y el idioma"

# Antes de ejecutarlo, se mira el plan. Es la diferencia entre saber lo que va
# a pasar y enterarse después.
paso "apt-get -s full-upgrade (el plan, antes de aplicarlo)"
PLAN=$(LC_ALL=C apt-get -s full-upgrade 2>&1 || true)
LINEA_FF=$(grep -E '^Inst firefox ' <<<"$PLAN" || true)
echo "${LINEA_FF:-    (ninguna línea Inst firefox)}" | sed 's/^/    /'
if grep -q "packages.mozilla.org\|repositories/mozilla" <<<"$LINEA_FF"; then
    ok "El plan cambia firefox por el de Mozilla"
elif [[ -z "$LINEA_FF" ]]; then
    fallo "El plan no toca firefox" \
"$(grep -E 'upgraded,' <<<"$PLAN" || true)
Si esta máquina tenía el paquete de transición instalado, esto significa que el
anclaje no está decidiendo. Si no lo tenía, es lo previsto y hay que instalar
firefox a mano (MEDICIONES.md §4.10d)."
else
    fallo "El plan cambia firefox, pero no por el de Mozilla" "$LINEA_FF"
fi

# --allow-downgrades no es un parche. El paquete de transición de Ubuntu lleva
# epoch (1:1snap1-0ubuntu5), así que la versión real de Mozilla es MENOR y el
# cambio es formalmente una desactualización. Medido: sin este permiso,
# 'apt-get -y full-upgrade' se niega con
#     E: Packages were downgraded and -y was used without --allow-downgrades.
# Una persona que ejecute la orden documentada sin -y no necesita nada de esto:
# apt le enseña el plan y le pregunta.
paso "sudo apt full-upgrade --allow-downgrades (ver comentario)"
if FU=$(sudo LC_ALL=C apt-get -y full-upgrade --allow-downgrades 2>&1); then
    ok "full-upgrade termina sin error"
else
    fallo "full-upgrade ha fallado" "$(echo "$FU" | tail -25)"
fi

FF_P3=$(LC_ALL=C dpkg-query -W -f='${Version}' firefox 2>/dev/null || echo "(no instalado)")
if [[ "$FF_P3" == 1:* ]]; then
    fallo "Firefox sigue siendo el paquete de transición de Ubuntu" \
"versión instalada: $FF_P3
Ese paquete solo sirve para lanzar el Snap. Todo lo demás de esta lista puede
estar en verde con esto mal: es la casilla que lo delata."
elif [[ "$FF_P3" == "(no instalado)" ]]; then
    fallo "No hay ningún paquete firefox instalado" "$(LC_ALL=C dpkg -l firefox 2>&1 | tail -3)"
else
    ok "Firefox es el deb de Mozilla, versión $FF_P3 (sin epoch)"
fi

DESTINO=$(readlink -f /usr/bin/firefox 2>/dev/null || true)
if [[ -z "$DESTINO" ]]; then
    fallo "No hay binario en /usr/bin/firefox" "$(ls -l /usr/bin/firefox 2>&1 || true)"
elif [[ "$DESTINO" == /snap/* ]]; then
    fallo "/usr/bin/firefox apunta al Snap" "$DESTINO"
else
    ok "/usr/bin/firefox → $DESTINO"
fi

# --- El idioma, que ningún Depends puede declarar ---------------------------
# firefox-l10n-es-es SOLO existe en el repositorio de Mozilla: en el índice de
# Ubuntu da 'Candidate: (none)', y firefox-locale-es de Ubuntu es otro
# transitorio al Snap. Por eso va aquí y no en el control (MEDICIONES.md §4.10f).
POL_L10N=$(LC_ALL=C apt-cache policy firefox-l10n-es-es 2>&1)
CAND_L10N=$(awk '/Candidate:/ {print $2}' <<<"$POL_L10N")
if [[ -n "$CAND_L10N" && "$CAND_L10N" != "(none)" ]]; then
    ok "El paquete de idioma existe: firefox-l10n-es-es $CAND_L10N"
    paso "sudo apt install firefox-l10n-es-es"
    if L10=$(sudo LC_ALL=C apt-get install -y firefox-l10n-es-es 2>&1); then
        ok "firefox-l10n-es-es instalado"
    else
        fallo "No se ha podido instalar el paquete de idioma" "$(echo "$L10" | tail -20)"
    fi
    XPI=$(dpkg -L firefox-l10n-es-es 2>/dev/null | grep -i '\.xpi$' || true)
    if [[ -n "$XPI" ]]; then
        ok "Idioma desplegado: $(head -1 <<<"$XPI")"
    else
        aviso "El paquete de idioma no instala ningún .xpi; mira dpkg -L firefox-l10n-es-es"
    fi
else
    fallo "No hay candidato para firefox-l10n-es-es" \
"$POL_L10N
Sin el repositorio de Mozilla leído, este paquete no existe. ¿Se hizo el paso 2?"
fi

# ============================================================================
titulo "5. Lo que hereda de D12: el idioma del sistema"
CLS=$(LC_ALL=C check-language-support -l es 2>&1 || true)
if [[ -z "$CLS" ]]; then
    ok "check-language-support -l es sigue saliendo vacío: no falta nada"
else
    aviso "check-language-support -l es devuelve algo"
    echo "$CLS" | sed 's/^/         /'
    echo "         Si es un paquete que encina-meta debería declarar, anótalo."
fi

# ============================================================================
titulo "6. Lo que solo puedes comprobar tú, mirando"
pendiente_visual "Firefox arranca EN ESPAÑOL."
echo "           Y ojo: que salga en español no demuestra que sea el nativo."
echo "           El Snap también está en español. Primero el binario:"
echo "               about:support → Binario de la aplicación"
echo "           debe ser /usr/lib/firefox/firefox y NO algo bajo /snap/."
pendiente_visual "El icono del dock abre el nativo (cierra sesión y vuelve a entrar)."
pendiente_visual "El fondo, GDM y el arranque, si es la primera vez en esta VM."
echo
echo "  La casilla que decide —una firma real en valide.redsara.es— NO se hace"
echo "  aquí: va en un clon aparte que se destruye después, porque lleva dentro"
echo "  un certificado personal (ENCINA-OS.md §9.1)."

# ============================================================================
resumen
EST=$?
if (( EST == 0 )); then
    echo
    echo "Siguiente:  ./scripts/12-meta-verificar.sh   (idempotencia y purga)"
fi
exit $EST
