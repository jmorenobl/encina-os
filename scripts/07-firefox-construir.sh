#!/usr/bin/env bash
# 07-firefox-construir.sh — Reglas duras de encina-firefox-native, build y lintian.
#
# Uso:  ./scripts/07-firefox-construir.sh [--saltar-reglas]
#
# El equivalente de 03-construir.sh para A2. Es un script aparte y no una
# generalización de 03 a propósito: 03 está validado contra encina-branding y
# no se toca. Lo único que comparten es lib.sh.
#
# La comprobación que de verdad importa aquí es la huella de la clave de firma.
# Si no coincide, el script se detiene y no construye nada.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
requiere_no_root
requiere_cmd dpkg-buildpackage lintian gpg

PAQUETE="encina-firefox-native"
PKG="$(PKG_DIR "$PAQUETE")"
SALIDA_DIR="$(raiz_repo)/debian-packages"
[[ -d "$PKG/debian" ]] || { echo "No existe $PKG/debian."; exit 1; }

# La huella oficial del repositorio de Mozilla (AGENTS.md §5.2). Está aquí
# escrita a mano y no se lee de ningún sitio: es el patrón contra el que se
# compara, y leerlo del propio fichero que se quiere validar no validaría nada.
HUELLA_MOZILLA="35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3"

CLAVE="$PKG/src/usr/share/keyrings/packages.mozilla.org.asc"
FUENTES="$PKG/src/etc/apt/sources.list.d/mozilla.sources"
ANCLAJE="$PKG/src/etc/apt/preferences.d/encina-mozilla"
MANT=("$PKG/debian/preinst" "$PKG/debian/postinst" "$PKG/debian/prerm" "$PKG/debian/postrm")

# ============================================================================
if [[ "${1:-}" != "--saltar-reglas" ]]; then
titulo "1. La clave de firma"

if [[ ! -f "$CLAVE" ]]; then
    fallo "No existe la clave de firma" "falta $CLAVE"
    resumen; exit 1
fi

# Formato: .asc es por convención ASCII blindado. apt acepta ambos formatos,
# pero un fichero binario con extensión .asc es una señal de que se descargó
# de otro sitio o de otra forma.
if grep -q "BEGIN PGP PUBLIC KEY BLOCK" <<<"$(head -1 "$CLAVE")"; then
    ok "La clave está en ASCII blindado, como corresponde a la extensión .asc"
else
    aviso "La clave no empieza por -----BEGIN PGP PUBLIC KEY BLOCK-----: $(head -c 60 "$CLAVE")"
fi

HUELLA_REAL=$(gpg --show-keys --with-colons "$CLAVE" 2>/dev/null \
              | awk -F: '/^fpr:/ {print $10; exit}')
if [[ "$HUELLA_REAL" == "$HUELLA_MOZILLA" ]]; then
    ok "Huella verificada: $HUELLA_REAL"
    echo "         $(gpg --show-keys --with-colons "$CLAVE" 2>/dev/null | awk -F: '/^uid:/ {print $10; exit}')"
    echo "         (el uid es de Google porque Mozilla sirve el repositorio desde"
    echo "          Artifact Registry; lo que se verifica es la huella, no el nombre)"
else
    fallo "LA HUELLA DE LA CLAVE NO COINCIDE" \
"esperada: $HUELLA_MOZILLA
obtenida: ${HUELLA_REAL:-<gpg no ha podido leer la clave>}

DETENTE AQUÍ. No sigas, no busques otra fuente de la clave y no toques
esta comprobación. Una clave que no es la que debería ser significa que el
fichero no viene de donde crees, y este paquete existe precisamente para
decirle a apt en quién confiar.

Avisa antes de hacer nada más."
    resumen; exit 1
fi

# ============================================================================
titulo "2. Reglas duras que aplican a este paquete"

# --- R10: sin dependencias circulares de repositorio ------------------------
# firefox y firefox-l10n-es-es viven en el repositorio que configura ESTE
# paquete, que no existe en el sistema hasta que este paquete se instala.
# Declararlos como Depends daría una dependencia irresoluble.
DEPS=$(grep -A5 -E '^(Depends|Pre-Depends|Recommends):' "$PKG/debian/control" 2>/dev/null || true)
if grep -qE '\bfirefox' <<<"$DEPS"; then
    fallo "R10 — el paquete depende de algo del repositorio de Mozilla" \
"$(grep -nE '^(Depends|Pre-Depends|Recommends):|firefox' "$PKG/debian/control")
Ese repositorio no existe hasta que este paquete se instala: la dependencia
sería irresoluble. Instalar Firefox pertenece a encina-meta o a la receta de
imagen, no a este paquete."
else
    ok "R10 — no se depende de firefox ni de firefox-l10n-*"
fi

# --- R3: no apt/apt-get/dpkg/snap desde scripts de mantenedor --------------
# En este paquete la forma más limpia de cumplir R3 es no tener scripts de
# mantenedor en absoluto, así que se comprueban las dos cosas.
HAY_MANT=0
SOSPECHOSO=""
for m in "${MANT[@]}"; do
    [[ -f "$m" ]] || continue
    HAY_MANT=1
    linea=$(grep -nE '^[^#]*(\bapt\b|\bapt-get\b|\bdpkg\b|\bsnap\b)' "$m" 2>/dev/null || true)
    [[ -n "$linea" ]] && SOSPECHOSO+="$m:$linea"$'\n'
done
if (( HAY_MANT == 0 )); then
    ok "R3 — el paquete no lleva scripts de mantenedor (nada que ejecutar)"
elif [[ -n "$SOSPECHOSO" ]]; then
    fallo "R3 — un script de mantenedor llama a apt/dpkg/snap" \
"$SOSPECHOSO
dpkg mantiene el bloqueo mientras corre el script: esto es un interbloqueo.
'apt update' lo lanza quien instala, y por eso el README lo documenta."
else
    ok "R3 — hay scripts de mantenedor pero no invocan apt/dpkg/snap"
fi

# --- R4: no eliminar el Snap desde el paquete ------------------------------
R4_PRUEBAS=$(grep -rnE '^[^#]*snap +remove|snap_remove' "$PKG/debian" 2>/dev/null || true)
if [[ -n "$R4_PRUEBAS" ]]; then
    fallo "R4 — el paquete intenta eliminar el Snap" \
"$R4_PRUEBAS
Es una acción destructiva: se lleva por delante marcadores y sesiones del
usuario. Corresponde a la receta de imagen, no a la paquetería."
else
    ok "R4 — el paquete no elimina el Snap de Firefox"
fi

# --- apt-key está obsoleto -------------------------------------------------
# Se ignoran los comentarios: explicar por qué no se usa apt-key no es usarlo.
# (Este mismo script se lo comió en la primera pasada.)
APTKEY=$(grep -rns --exclude-dir=.debhelper --exclude-dir="$PAQUETE" \
         -E '^[^#]*apt-key' "$PKG/debian" "$PKG/src" 2>/dev/null || true)
if [[ -n "$APTKEY" ]]; then
    fallo "Se usa apt-key" \
"$APTKEY
apt-key está obsoleto y mete la clave en el llavero global: esa clave
firmaría como válido cualquier repositorio del sistema. Usa Signed-By."
else
    ok "No se usa apt-key (obsoleto); la confianza va atada con Signed-By"
fi

# ============================================================================
titulo "3. Los tres ficheros de configuración"

# --- Definición del repositorio, formato deb822 ----------------------------
if [[ -f "$FUENTES" ]]; then
    FALTAN=""
    for campo in "Types: deb" "URIs: https://packages.mozilla.org/apt" \
                 "Suites: mozilla" "Components: main" \
                 "Signed-By: /usr/share/keyrings/packages.mozilla.org.asc"; do
        grep -qF "$campo" "$FUENTES" || FALTAN+="  falta: $campo"$'\n'
    done
    if [[ -z "$FALTAN" ]]; then
        ok "mozilla.sources tiene los cinco campos de AGENTS.md §5.2"
    else
        fallo "mozilla.sources no casa con la especificación" "$FALTAN$(cat "$FUENTES")"
    fi

    # La ruta de Signed-By tiene que apuntar a un fichero que este mismo
    # paquete instale. Si apunta a otro sitio, apt update falla con NO_PUBKEY
    # y el paquete no sirve para nada.
    RUTA_CLAVE=$(grep -m1 '^Signed-By:' "$FUENTES" | sed 's/^Signed-By:[[:space:]]*//')
    if [[ -f "$PKG/src${RUTA_CLAVE}" ]]; then
        ok "Signed-By apunta a un fichero que instala este paquete: $RUTA_CLAVE"
    else
        fallo "Signed-By apunta a un fichero que el paquete no instala" \
"Signed-By: $RUTA_CLAVE
No existe $PKG/src${RUTA_CLAVE}
apt update fallaría con NO_PUBKEY."
    fi
else
    fallo "No existe mozilla.sources" "falta $FUENTES"
fi

# --- Anclaje de prioridad --------------------------------------------------
# Es LA pieza crítica: sin ella apt reinstala el Snap en la primera
# actualización, y no te enteras hasta que pasa.
if [[ -f "$ANCLAJE" ]]; then
    PRIO=$(grep -m1 '^Pin-Priority:' "$ANCLAJE" | tr -dc '0-9')
    PIN=$(grep -m1 '^Pin:' "$ANCLAJE" | sed 's/^Pin:[[:space:]]*//')
    if [[ "${PRIO:-0}" -ge 1000 ]]; then
        ok "Pin-Priority: $PRIO (>= 1000: apt puede cambiar de origen aunque baje de versión)"
    else
        fallo "Pin-Priority es ${PRIO:-<vacío>}, insuficiente" \
"El deb de transición de Ubuntu lleva epoch (1:...), lo que lo hace versión
MÁS ALTA que cualquier versión real de Mozilla. Por debajo de 1000 apt no
hace un cambio que suponga bajar de versión, así que ganaría Ubuntu y
volvería el Snap."
    fi
    if [[ "$PIN" == "origin packages.mozilla.org" ]]; then
        ok "Pin: $PIN (casa con el nombre de máquina, que es lo que se quiere)"
    else
        fallo "El Pin no es 'origin packages.mozilla.org'" \
"Pin: $PIN
'Pin: origin <host>' casa con el nombre de máquina. 'Pin: release o=<x>'
casa con el campo Origin: del fichero Release, que en este repositorio vale
'namespaces/moz-fx-productdelivery-pr-38b5/repositories/mozilla'. Confundir
los dos deja el anclaje sin efecto y el fallo es silencioso."
    fi
    grep -q '^Package: \*' "$ANCLAJE" \
        && ok "El anclaje aplica a todos los paquetes del origen (Package: *)" \
        || aviso "El anclaje no usa 'Package: *'; comprueba que cubre firefox y el paquete de idioma"
else
    fallo "No existe el anclaje de prioridad" \
"falta $ANCLAJE
Sin él apt reinstalará el Snap de Ubuntu en la primera actualización. Es la
causa de fallo más habitual de este paquete."
fi

# --- Nombres de fichero que apt acepta -------------------------------------
# apt ignora en silencio los ficheros con extensión que no reconoce. Un
# fichero ignorado no da ningún error: simplemente no hace nada.
[[ "$(basename "$FUENTES")" == *.sources ]] \
    && ok "El fichero de fuentes acaba en .sources (apt ignoraría otra extensión)" \
    || fallo "El fichero de fuentes no acaba en .sources" "$(basename "$FUENTES")"
BASE_ANCLAJE=$(basename "$ANCLAJE")
if [[ "$BASE_ANCLAJE" == *.* && "$BASE_ANCLAJE" != *.pref ]]; then
    fallo "El anclaje tiene una extensión que apt ignora" \
"$BASE_ANCLAJE
En preferences.d apt solo lee ficheros sin extensión o con extensión .pref.
Los demás los ignora sin decir nada."
else
    ok "El anclaje tiene un nombre que apt lee ($BASE_ANCLAJE)"
fi

# --- Higiene del empaquetado -----------------------------------------------
grep -qs "^Format:" "$PKG/debian/copyright" \
    && ok "debian/copyright tiene formato DEP-5" \
    || fallo "debian/copyright no parece DEP-5" "falta la línea 'Format:'"
# R8 pide declarar en copyright cualquier fichero de terceros, y la clave de
# Mozilla lo es.
grep -qs "packages.mozilla.org.asc" "$PKG/debian/copyright" \
    && ok "La clave de Mozilla está declarada en debian/copyright (R8)" \
    || aviso "debian/copyright no menciona la clave de Mozilla, que es un fichero de terceros"
MANTENEDOR=$(grep -m1 "^Maintainer:" "$PKG/debian/control" || echo "")
if grep -qiE "ejemplo|example|CORREO|TODO|cambiar|@.*-dev>" <<<"$MANTENEDOR"; then
    fallo "El campo Maintainer no parece real" \
"$MANTENEDOR
Ojo con el changelog: dch construye la dirección a partir del usuario y el
nombre de la máquina si DEBEMAIL no está definido, y en una sesión ssh no
interactiva no se carga .bashrc."
else
    ok "Maintainer: ${MANTENEDOR#Maintainer: }"
fi
CL_MANT=$(head -20 "$PKG/debian/changelog" | grep -m1 "^ -- " || echo "")
if grep -qE "@.*-dev>|localhost" <<<"$CL_MANT"; then
    fallo "El changelog lleva una dirección construida por dch, no la tuya" \
"$CL_MANT
Bórralo y vuelve a generarlo con DEBEMAIL definido:
    export DEBFULLNAME=\"...\" DEBEMAIL=\"...\"
    dch --create --package $PAQUETE -v 0.1.0 --distribution noble \"...\""
else
    ok "Changelog firmado por${CL_MANT# --}"
fi
fi  # fin --saltar-reglas

# ============================================================================
titulo "4. Construcción"
cd "$PKG" || exit 1
paso "dpkg-buildpackage -us -uc -b"
if BUILD=$(dpkg-buildpackage -us -uc -b 2>&1); then
    ok "El paquete se construye sin error"
else
    fallo "dpkg-buildpackage ha fallado" "$(echo "$BUILD" | tail -30)"
    echo
    echo "Lee la PRIMERA línea de error, no la última. Salida completa:"
    echo "$BUILD" | sed 's/^/  | /'
    resumen; exit 1
fi

DEB=$(ls -t "$SALIDA_DIR"/${PAQUETE}_*.deb 2>/dev/null | head -1 || true)
if [[ -z "$DEB" ]]; then
    fallo "No aparece ningún .deb" "buscado en $SALIDA_DIR"
    resumen; exit 1
fi
ok "Generado: $(basename "$DEB")"

# ============================================================================
titulo "5. Contenido del paquete"
CONTENIDO=$(dpkg -c "$DEB")
echo "$CONTENIDO" | awk '{print $6}' | grep -v '/$' | sed 's/^/  /'

for esperado in \
    "etc/apt/sources.list.d/mozilla.sources" \
    "etc/apt/preferences.d/encina-mozilla" \
    "usr/share/keyrings/packages.mozilla.org.asc"
do
    if grep -q "$esperado" <<<"$CONTENIDO"; then
        ok "Incluye $esperado"
    else
        fallo "El paquete NO incluye $esperado" ""
    fi
done

# Los ficheros bajo /etc son conffiles automáticamente, y de eso depende que
# 'apt purge' devuelva el sistema a su configuración de repositorios original.
CONFF=$(dpkg-deb -I "$DEB" conffiles 2>/dev/null || echo "")
if grep -q "sources.list.d/mozilla.sources" <<<"$CONFF" \
   && grep -q "preferences.d/encina-mozilla" <<<"$CONFF"; then
    ok "Los dos ficheros de /etc están declarados como conffiles (apt purge los quita)"
else
    fallo "Los ficheros de /etc no son conffiles" \
"conffiles del paquete:
$CONFF
Sin esto, apt purge dejaría el repositorio de Mozilla configurado."
fi

# ============================================================================
titulo "6. Lintian"

# El paquete anula dos tags a propósito (instalar en /etc/apt/sources.list.d y
# en /etc/apt/preferences.d es exactamente lo que hace, y el anclaje no tiene
# otra ubicación posible porque apt no lee ninguna otra). Un override sin
# justificación escrita sí sería silenciar, así que se exige que la lleve.
OVR="$PKG/debian/${PAQUETE}.lintian-overrides"
if [[ -f "$OVR" ]]; then
    N_TAGS=$(grep -cvE '^\s*(#|$)' "$OVR" || true)
    N_JUST=$(grep -cE '^\s*#' "$OVR" || true)
    if (( N_JUST >= N_TAGS )); then
        ok "Hay $N_TAGS override(s) de lintian, con $N_JUST líneas de justificación"
    else
        fallo "Hay overrides de lintian sin justificar" \
"$N_TAGS tags anulados y solo $N_JUST líneas de comentario en $OVR
Los avisos se justifican o se corrigen, no se silencian. Escribe por qué el
tag no aplica a este paquete, dentro del propio fichero."
    fi
fi

if LINT=$(lintian --fail-on error "$DEB" 2>&1); then
    ok "lintian sin errores"
    if [[ -n "$LINT" ]]; then
        echo "  Avisos (léelos, no los ignores en silencio):"
        echo "$LINT" | sed 's/^/    /'
    fi
else
    fallo "lintian ha encontrado errores" "$LINT"
fi

# Lo anulado se enseña siempre. Un override que no se ve por ninguna parte
# acaba siendo un error olvidado.
ANULADOS=$(lintian --show-overrides "$DEB" 2>&1 | grep '^O:' || true)
if [[ -n "$ANULADOS" ]]; then
    echo "  Tags anulados (justificados en $(basename "$OVR")):"
    echo "$ANULADOS" | sed 's/^/    /'
fi

resumen
RES=$?
echo
echo "Paquete: $DEB"
(( RES == 0 )) && echo "Siguiente:  ./scripts/08-firefox-instalar.sh"
exit $RES
