#!/usr/bin/env bash
# 10-meta-construir.sh — Reglas duras de encina-meta, build y lintian.
#
# Uso:  ./scripts/10-meta-construir.sh [--saltar-reglas]
#
# El equivalente de 03 y de 07 para E1. Es un script aparte y no una
# generalización de los otros dos a propósito: aquellos están validados contra
# sus paquetes y no se tocan. Lo único que comparten es lib.sh.
#
# Lo que de verdad protege este script es R10, y de una forma concreta: que el
# paquete no declare firefox. No basta con leerlo, porque declararlo NO falla
# —lo satisface el paquete de transición al Snap que Ubuntu ya trae— y el
# sistema se queda en el Snap saliendo con éxito (MEDICIONES.md §4.10e).

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
requiere_no_root
requiere_cmd dpkg-buildpackage lintian dpkg-deb

PAQUETE="encina-meta"
PKG="$(PKG_DIR "$PAQUETE")"
SALIDA_DIR="$(raiz_repo)/debian-packages"
[[ -d "$PKG/debian" ]] || { echo "No existe $PKG/debian."; exit 1; }

# ============================================================================
titulo "0. El changelog, que no se escribe a mano ni en el Mac"

# El changelog se gestiona con dch y se crea en la VM (AGENTS.md §3). El
# paquete se escribe en el Mac sin él a propósito, así que la primera vez que
# se construye aquí hay que crearlo. No lo crea este script: dch pone la fecha,
# el autor y el formato, y hacerlo desde aquí sería escribirlo a mano con más
# pasos.
if [[ ! -f "$PKG/debian/changelog" ]]; then
    echo
    echo "${C_AVI}No hay debian/changelog, y este script no lo crea.${C_FIN}"
    echo
    echo "Créalo aquí, en la VM, con dch (nunca a mano, nunca en el Mac):"
    echo
    echo "    cd $PKG"
    echo "    dch --create --package $PAQUETE -v 0.1.0 --distribution \$(lsb_release -cs) \\"
    echo "        \"Primera version: metapaquete de Encina OS\""
    echo
    echo "Y vuelve a ejecutar este script."
    exit 1
fi
ok "Hay debian/changelog"
VERSION=$(dpkg-parsechangelog -l "$PKG/debian/changelog" -S Version 2>/dev/null || echo "?")
SUITE=$(dpkg-parsechangelog -l "$PKG/debian/changelog" -S Distribution 2>/dev/null || echo "?")
echo "         versión $VERSION, suite $SUITE"

# ============================================================================
if [[ "${1:-}" != "--saltar-reglas" ]]; then
titulo "1. Reglas duras que aplican a este paquete"

# --- Un metapaquete no lleva ficheros propios (AGENTS.md §6.1) --------------
if [[ -d "$PKG/src" ]]; then
    fallo "El paquete tiene un árbol src/" \
"$(find "$PKG/src" -type f | head -20)
Un metapaquete con contenido son dos paquetes mal separados. Lo que haya que
instalar va en el paquete al que pertenece."
else
    ok "No hay árbol src/: el paquete no instala ficheros propios"
fi

# Ficheros de debhelper que instalarían contenido. Se listan por nombre en vez
# de mirar solo src/ porque .install, .links y .dirs meten ficheros sin que
# exista ningún src/.
CONTENIDO=""
for f in "$PKG"/debian/*.install "$PKG"/debian/*.links "$PKG"/debian/*.dirs \
         "$PKG"/debian/*.docs "$PKG"/debian/*.manpages "$PKG"/debian/*.examples; do
    if [[ -e "$f" ]]; then CONTENIDO+="$(basename "$f")"$'\n'; fi
done
if [[ -n "$CONTENIDO" ]]; then
    fallo "Hay ficheros de debhelper que instalan contenido" "$CONTENIDO"
else
    ok "No hay ficheros .install/.links/.dirs en debian/"
fi

# --- R3 y §6.1: ningún script de mantenedor ---------------------------------
# En este paquete no es solo que R3 prohíba llamar a apt desde ellos: es que si
# hace falta uno, la señal es que una dependencia está mal declarada.
MANT=""
for n in preinst postinst prerm postrm config triggers; do
    if [[ -e "$PKG/debian/$n" ]]; then MANT+="$n"$'\n'; fi
done
if [[ -n "$MANT" ]]; then
    fallo "El metapaquete lleva scripts de mantenedor" \
"$MANT
Si hace falta uno, es señal de que una dependencia está mal declarada
(AGENTS.md §6.1)."
else
    ok "Sin scripts de mantenedor"
fi

# --- Architecture: all ------------------------------------------------------
ARCH=$(awk '/^Package: /{p=1} p && /^Architecture:/{print $2; exit}' "$PKG/debian/control")
if [[ "$ARCH" == "all" ]]; then
    ok "Architecture: all"
else
    fallo "Architecture debería ser 'all'" "obtenida: ${ARCH:-<vacía>}"
fi

# --- R10, la que importa ----------------------------------------------------
#
# OJO CON LA FORMA DE ESTA COMPROBACIÓN. Un 'grep firefox debian/control'
# devuelve una docena de coincidencias en este paquete, porque su Description
# explica largamente POR QUÉ no se declara firefox. Es la trampa 3 de
# SCRIPTS.md: el grep casa con tus propios comentarios y acusa al fichero de
# hacer justo lo que documenta que no hace. Aquí no se puede filtrar por '#'
# —no hay comentarios, hay prosa— así que se extraen los campos de dependencia
# con sus líneas de continuación y se mira SOLO ahí.
campos_dependencia() {
    awk '
        /^(Depends|Pre-Depends|Recommends|Suggests|Build-Depends):/ { dentro=1; print; next }
        dentro && /^[[:space:]]/ { print; next }
        { dentro=0 }
    ' "$1"
}
DEPS=$(campos_dependencia "$PKG/debian/control")

if grep -qE '(^|[[:space:],])firefox([[:space:],]|$|-)' <<<"$DEPS"; then
    fallo "R10 — el paquete declara algo del repositorio de Mozilla" \
"$(grep -nE 'firefox' <<<"$DEPS")
firefox y firefox-l10n-es-es solo existen en el repositorio que configura
encina-firefox-native, y ese repositorio NO está en los índices de apt cuando
apt resuelve estas dependencias.

Y declararlo no falla, que es lo peor: en un escritorio de fábrica lo satisface
el paquete de transición al Snap que ya está instalado, apt sale con 0 y la
máquina se queda en el Snap sin decir nada (MEDICIONES.md §4.10e).

Es el criterio de parada de E1 (ENCINA-OS.md §10). Para y avisa."
else
    ok "R10 — no se declara firefox ni firefox-l10n-*"
fi

# Control de la comprobación anterior: si no sabe encontrar 'firefox' cuando
# SÍ está, no vale nada. Se le da un control de campos falso.
CONTROL_FALSO="Depends: encina-branding,
         firefox,
         hunspell-es"
if grep -qE '(^|[[:space:],])firefox([[:space:],]|$|-)' <<<"$CONTROL_FALSO"; then
    ok "La comprobación de R10 sabe decir que sí: detecta un 'firefox' inyectado"
else
    fallo "La comprobación de R10 no detecta un 'firefox' evidente" \
"Con este control debería haber saltado:
$CONTROL_FALSO
Tal como está, esta comprobación diría [OK] con el paquete roto."
fi

# Y el control complementario: que la extracción de campos no se esté comiendo
# la Description, donde 'firefox' aparece muchas veces de forma legítima.
#
# Se cuenta con EL MISMO patrón anclado que usa la comprobación de arriba, y no
# con un 'grep firefox' a secas. Un 'grep firefox' cuenta también
# 'encina-firefox-native', que es una dependencia legítima y contiene la
# subcadena: la primera versión de este control decía «1 mención en las
# dependencias» y era esa. Familia de la trampa 5 de SCRIPTS.md, del revés.
PATRON_FF='(^|[[:space:],])firefox([[:space:],]|$|-)'
N_TODO=$(grep -cE "$PATRON_FF" "$PKG/debian/control" || true)
N_DEPS=$(grep -cE "$PATRON_FF" <<<"$DEPS" || true)
if (( N_TODO > 0 && N_DEPS == 0 )); then
    ok "La extracción de campos ignora la Description ($N_TODO menciones de firefox en el control, 0 en las dependencias)"
else
    aviso "Menciones ancladas de firefox: $N_TODO en todo el control, $N_DEPS en los campos de dependencia"
fi
fi  # --saltar-reglas

# ============================================================================
titulo "2. Construcción"

paso "dpkg-buildpackage -us -uc -b"
if SALIDA=$(cd "$PKG" && dpkg-buildpackage -us -uc -b 2>&1); then
    ok "El paquete se construye sin error"
else
    fallo "dpkg-buildpackage ha fallado" "$(echo "$SALIDA" | tail -25)"
    resumen; exit 1
fi

DEB=$(ls -t "$SALIDA_DIR"/${PAQUETE}_*.deb 2>/dev/null | head -1 || true)
if [[ -z "$DEB" ]]; then
    fallo "No aparece ningún .deb en $SALIDA_DIR" "$(ls "$SALIDA_DIR" | tail -10)"
    resumen; exit 1
fi
ok "Paquete: $(basename "$DEB") ($(stat -c%s "$DEB") bytes)"

# ============================================================================
titulo "3. Lo que ha quedado DENTRO del paquete"
#
# Esto se comprueba sobre el .deb y no sobre el árbol de fuentes a propósito:
# es lo que se instalaría, no lo que creemos haber escrito.

CONT=$(dpkg-deb -c "$DEB" 2>&1)
# Ojo con las barras finales: dpkg-deb -c lista los directorios CON barra
# ('./usr/share/doc/') y los ficheros sin ella. Una primera versión de este
# patrón se las comía y acusaba al paquete de instalar './usr/share/doc/'.
FUERA=$(echo "$CONT" | awk '{print $6}' | grep -vE '^\./(usr/(share/(doc/(encina-meta/.*)?)?)?)?$' || true)
if [[ -z "$FUERA" ]]; then
    ok "No instala ni un fichero fuera de /usr/share/doc/encina-meta/"
    echo "$CONT" | awk '{print "         " $6}' | tail -3
else
    fallo "El paquete instala ficheros fuera de /usr/share/doc/" "$FUERA"
fi

# Los scripts de mantenedor, otra vez, ahora sobre el paquete construido.
CTRL_FILES=$(dpkg-deb --ctrl-tarfile "$DEB" 2>/dev/null | tar -t 2>/dev/null | sed 's|^\./||' | grep -v '^$' || true)
SCRIPTS_DENTRO=$(grep -xE 'preinst|postinst|prerm|postrm|config|triggers' <<<"$CTRL_FILES" || true)
if [[ -z "$SCRIPTS_DENTRO" ]]; then
    ok "El .deb no lleva scripts de mantenedor (${CTRL_FILES//$'\n'/, })"
else
    fallo "El .deb lleva scripts de mantenedor" "$SCRIPTS_DENTRO"
fi

# R10 sobre el artefacto: lo que cuenta es lo que apt va a leer.
DEPS_DEB=$(dpkg-deb -f "$DEB" Depends Pre-Depends Recommends Suggests 2>/dev/null || true)
echo "$DEPS_DEB" | sed 's/^/         /'
if grep -qE '(^|[[:space:],])firefox' <<<"$DEPS_DEB"; then
    fallo "R10 — el .deb CONSTRUIDO declara firefox" "$DEPS_DEB"
else
    ok "R10 — el .deb construido no declara firefox"
fi

# ============================================================================
titulo "4. lintian"
#
# Medido el 2026-08-08 en Ubuntu 24.04 con lintian 2.117: este paquete no
# produce NINGUNA etiqueta, ni siquiera con --display-info --pedantic. Por eso
# aquí no hay fichero de overrides, y por eso la comprobación es «ni una
# línea» y no «sin errores»: si aparece algo, es nuevo y hay que mirarlo.
paso "lintian $(basename "$DEB")"
LINT=$(lintian "$DEB" 2>&1 | grep -v "root privileges is not recommended" || true)
if [[ -z "$LINT" ]]; then
    ok "lintian no dice nada"
else
    fallo "lintian ha dicho algo, y en este paquete eso es nuevo" \
"$LINT
Medido el 2026-08-08: este paquete salía completamente limpio, incluso con
--display-info --pedantic. Si ahora aparece una etiqueta, míralas antes de
escribir ningún override; y si hay que escribirlo, con el motivo redactado."
fi

# ============================================================================
resumen
EST=$?
if (( EST == 0 )); then
    echo
    echo "Siguiente:  ./scripts/11-meta-instalar.sh"
fi
exit $EST
