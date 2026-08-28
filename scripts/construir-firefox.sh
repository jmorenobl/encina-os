#!/usr/bin/env bash
# construir-firefox.sh — Reglas duras de encina-firefox-native, build y lintian.
#
# Uso:  ./scripts/construir-firefox.sh [--saltar-reglas]
#
# El equivalente de construir-branding.sh para A2. Es un script aparte y no una
# generalización de 03 a propósito: 03 está validado contra encina-branding y
# no se toca. Lo único que comparten es lib.sh.
#
# La comprobación que de verdad importa aquí es la huella de la clave de firma.
# Si no coincide, el script se detiene y no construye nada.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
# MODELO DE SALIDA: CONTAR Y SEGUIR (tarea 2, MEDICIONES.md §4.67). fallo()
# apunta, incrementa N_MAL y SIGUE midiendo; morir() aborta; quien fija el
# código de salida es resumen(). El 'set' lo pone lib.sh:5 al hacer source: se
# REAFIRMA aquí para que las opciones de shell de este guion no dependan de a
# quién llame. Reafirmarlo no cambia ni una opción — control en §4.67.
set -euo pipefail
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
SOMBRA="$PKG/src/usr/share/applications/firefox_firefox.desktop"
OVERRIDE="$PKG/src/usr/share/glib-2.0/schemas/99-encina-firefox-native.gschema.override"
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
# paquete, que no está en los índices de apt cuando apt resuelve.
#
# Este comentario decía «daría una dependencia irresoluble», y es falso, medido
# el 2026-08-08 (MEDICIONES.md §4.10e): el nombre firefox existe también en el
# índice de Ubuntu, como paquete de transición al Snap. Declararlo no falla —lo
# satisface el Snap, en silencio—, que es bastante peor.
DEPS=$(grep -A5 -E '^(Depends|Pre-Depends|Recommends):' "$PKG/debian/control" 2>/dev/null || true)
if grep -qE '\bfirefox' <<<"$DEPS"; then
    fallo "R10 — el paquete depende de algo del repositorio de Mozilla" \
"$(grep -nE '^(Depends|Pre-Depends|Recommends):|firefox' "$PKG/debian/control")
Ese repositorio no está en los índices de apt cuando apt resuelve, así que la
dependencia la satisfaría el paquete de transición al Snap de Ubuntu, en
silencio y saliendo con 0 (MEDICIONES.md §4.10e). Instalar Firefox pertenece a
la secuencia documentada o a la receta de imagen, no a este paquete."
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

# --- R1: nada de /etc/skel -------------------------------------------------
# Aplica desde que el paquete toca predeterminados del escritorio: la tentación
# de dejar caer un fichero en /etc/skel para «configurar el dock» es real, y
# solo alcanzaría a los usuarios creados después.
if [[ -d "$PKG/src/etc/skel" ]]; then
    fallo "R1 — el paquete instala ficheros en /etc/skel" \
"$(find "$PKG/src/etc/skel" -type f 2>/dev/null)
/etc/skel solo afecta a usuarios creados después y no se puede actualizar.
Los predeterminados van en gschema.override."
else
    ok "R1 — no se usa /etc/skel"
fi

# --- R2: no llamar a glib-compile-schemas ----------------------------------
R2_PRUEBAS=""
for m in "${MANT[@]}"; do
    [[ -f "$m" ]] || continue
    linea=$(grep -nE '^[^#]*glib-compile-schemas' "$m" 2>/dev/null || true)
    [[ -n "$linea" ]] && R2_PRUEBAS+="$m:$linea"$'\n'
done
if [[ -n "$R2_PRUEBAS" ]]; then
    fallo "R2 — un script de mantenedor llama a glib-compile-schemas" \
"$R2_PRUEBAS
libglib2.0-0 tiene un disparador de dpkg que ya lo hace. Quítalo."
else
    ok "R2 — no se llama a glib-compile-schemas"
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

# ============================================================================
titulo "3b. Que el icono abra el Firefox correcto"

# --- La sombra del lanzador del Snap ---------------------------------------
if [[ -f "$SOMBRA" ]]; then
    ok "Existe la sombra del lanzador del Snap ($(basename "$SOMBRA"))"

    # El nombre TIENE que ser exactamente el del Snap: es lo que hace que gane
    # por identificador. Cualquier otro nombre crea un tercer lanzador en vez
    # de sustituir al segundo.
    if [[ "$(basename "$SOMBRA")" == "firefox_firefox.desktop" ]]; then
        ok "El identificador coincide con el del Snap (por eso lo sustituye)"
    else
        fallo "La sombra no se llama firefox_firefox.desktop" \
"$(basename "$SOMBRA")
La sustitución es por identificador de fichero .desktop. Con otro nombre no
sustituye nada: añade un tercer lanzador."
    fi

    # TryExec es obligatorio porque este paquete NO instala Firefox (R10).
    if grep -q '^TryExec=/usr/bin/firefox' "$SOMBRA"; then
        ok "Lleva TryExec=/usr/bin/firefox"
    else
        fallo "La sombra no lleva TryExec=/usr/bin/firefox" \
"Este paquete no instala Firefox (R10), así que entre instalarlo e instalar
Firefox el binario no existe. Sin TryExec el icono abriría la nada, y sería
peor que no haber hecho nada."
    fi
    # NoDisplay tiene que estar PRESENTE. ESTA COMPROBACIÓN ESTUVO INVERTIDA
    # HASTA LA 0.2.1, y el motivo del cambio está medido, no razonado:
    # `MEDICIONES.md` §4.19, en las DOS máquinas y con el mismo método.
    #
    # Lo que decía antes: con NoDisplay, instalar en una sesión ya abierta hacía
    # desaparecer el icono del dock, así que se prefería ver dos «Firefox».
    # Ese trato dejó de valer cuando el producto pasó a ser la imagen (D3) y la
    # imagen dejó de tener Snap (E2): el duplicado dejó de ser un feo pasajero
    # de quien actualiza su Ubuntu y pasó a ser lo que ve todo usuario, siempre.
    #
    # Y lo medido descarta las alternativas: SIN este fichero, en una máquina con
    # Snap el identificador vuelve a resolver a /snap/bin/firefox %u —A2 entero
    # otra vez—; con Hidden=true pasa a NINGUNA y el icono anclado se queda
    # muerto. Con NoDisplay=true sigue resolviendo a /usr/bin/firefox %u: oculta
    # sin desactivar, que es justo lo que hace falta.
    if grep -q '^NoDisplay=true' "$SOMBRA"; then
        ok "Lleva NoDisplay=true: un solo icono, y el identificador sigue vivo"
    else
        fallo "La sombra no lleva NoDisplay=true" \
"Sin NoDisplay el usuario ve DOS «Firefox» idénticos, y en el producto —que es
la imagen, y no tiene Snap— los ve siempre. Medido en los dos mundos el
2026-08-10 (MEDICIONES.md §4.19).

Y no vale quitar el fichero ni poner Hidden=true: sin él, en una máquina con
Snap el identificador vuelve a resolver a /snap/bin/firefox %u, que es A2
reabierto; con Hidden pasa a NINGUNA y el icono anclado se queda muerto.
NoDisplay oculta sin desactivar: el identificador sigue dando
/usr/bin/firefox %u."
    fi
    if grep -qE '^Exec=/usr/bin/firefox' "$SOMBRA"; then
        ok "Redirige a /usr/bin/firefox, no al Snap"
    else
        fallo "La sombra no redirige a /usr/bin/firefox" "$(grep '^Exec=' "$SOMBRA" || echo 'sin Exec')"
    fi
    if grep -qE '^Exec=.*(/snap/|snap run)' "$SOMBRA"; then
        fallo "La sombra sigue apuntando al Snap" "$(grep '^Exec=' "$SOMBRA")"
    fi
else
    fallo "No existe la sombra del lanzador del Snap" \
"falta $SOMBRA
Sin ella, el icono del dock sigue abriendo el Snap con todo lo demás bien
instalado, y no se nota porque el Snap también está en español."
fi

# --- El override de los favoritos ------------------------------------------
if [[ -f "$OVERRIDE" ]]; then
    ok "Existe el gschema.override de los favoritos"

    # LA comprobación de este bloque, y la que costó cuatro versiones en A1.
    if grep -q '^\[org.gnome.shell:ubuntu\]' "$OVERRIDE"; then
        ok "El override duplica la sección con el sufijo :ubuntu (§4.2)"
    else
        fallo "Al override le falta la sección [org.gnome.shell:ubuntu]" \
"$(grep '^\[' "$OVERRIDE" || echo 'sin secciones')
La sesión corre con XDG_CURRENT_DESKTOP=ubuntu:GNOME y Ubuntu define
favorite-apps en [org.gnome.shell:ubuntu]. Esa sección gana sea cual sea el
número del fichero: un 99- genérico NO le gana.

Y el fallo es traicionero: 'gsettings get' desde una terminal no tiene esa
variable y te devolvería el valor genérico, dando la falsa impresión de que
funciona. Es exactamente el fallo de encina-branding 0.1.2."
    fi
    if grep -q '^\[org.gnome.shell\]' "$OVERRIDE"; then
        ok "El override define también la sección genérica"
    else
        aviso "El override no define [org.gnome.shell]; en sesiones no-Ubuntu no se aplicaría"
    fi

    # Se miran SOLO las líneas efectivas. Los comentarios de este fichero
    # citan 'firefox_firefox.desktop' para explicar por qué se deja de anclar,
    # y un grep sobre el fichero entero da FALLO con el override correcto.
    # (Es la tercera vez que esta familia de falso negativo aparece en A2:
    # explicar algo en un comentario no es hacerlo.)
    EFECTIVO=$(grep -vE '^[[:space:]]*#' "$OVERRIDE" || true)

    N_SEC=$(grep -c '^favorite-apps' <<<"$EFECTIVO" || true)
    N_NATIVO=$(grep -c "'firefox\.desktop'" <<<"$EFECTIVO" || true)
    if [[ "$N_SEC" == "$N_NATIVO" && "$N_SEC" -ge 2 ]]; then
        ok "Las $N_SEC secciones anclan firefox.desktop"
    else
        fallo "No todas las secciones anclan firefox.desktop" \
"$N_SEC definiciones de favorite-apps, $N_NATIVO con firefox.desktop
$(grep -n 'favorite-apps' <<<"$EFECTIVO")"
    fi
    if grep -q "'firefox_firefox\.desktop'" <<<"$EFECTIVO"; then
        fallo "El override sigue anclando el lanzador del Snap" \
"$(grep -n 'firefox_firefox.desktop' <<<"$EFECTIVO")
Ese es justo el que hay que dejar de anclar."
    else
        ok "El override ya no ancla firefox_firefox.desktop"
    fi
else
    fallo "No existe el gschema.override de los favoritos" \
"falta $OVERRIDE
Sin él, el icono anclado seguiría siendo el del Snap."
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
    "usr/share/keyrings/packages.mozilla.org.asc" \
    "usr/share/applications/firefox_firefox.desktop" \
    "usr/share/glib-2.0/schemas/99-encina-firefox-native.gschema.override"
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
(( RES == 0 )) && echo "Siguiente:  ./scripts/instalar-firefox.sh"
exit $RES
