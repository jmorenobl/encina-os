#!/usr/bin/env bash
# construir-keyring.sh — Reglas duras de encina-keyring, build y lintian.
#
# Uso:  ./scripts/construir-keyring.sh [--saltar-reglas]
#
# El equivalente de 03/07/10 para el quinto paquete (D25). Es un script aparte
# y no una generalización a propósito: aquellos están validados contra sus
# paquetes y no se tocan. Lo único que comparten es lib.sh.
#
# La comprobación que de verdad importa aquí es la huella de la clave: este
# paquete existe para decirle a apt en quién confiar, y una clave que no es la
# que debería ser significa que el fichero no viene de donde crees. Si la
# huella no coincide, el script se detiene y no construye nada — el mismo
# patrón que construir-firefox.sh con la clave de Mozilla.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
# MODELO DE SALIDA: CONTAR Y SEGUIR (tarea 2, MEDICIONES.md §4.67). fallo()
# apunta, incrementa N_MAL y SIGUE midiendo; morir() aborta; quien fija el
# código de salida es resumen(). El 'set' lo pone lib.sh:5 al hacer source: se
# REAFIRMA aquí para que las opciones de shell de este guion no dependan de a
# quién llame.
set -euo pipefail
requiere_no_root
requiere_cmd dpkg-buildpackage lintian dpkg-deb gpg

PAQUETE="encina-keyring"
PKG="$(PKG_DIR "$PAQUETE")"
SALIDA_DIR="$(raiz_repo)/debian-packages"
[[ -d "$PKG/debian" ]] || { echo "No existe $PKG/debian."; exit 1; }

# La huella de la clave de Encina OS (D25, generada el 2026-08-31; la custodia
# está en el README del paquete). Está aquí escrita a mano y no se lee de
# ningún sitio: es el patrón contra el que se compara, y leerla del propio
# fichero que se quiere validar no validaría nada.
HUELLA_ENCINA="58A525AB990C4B8DC5AB3D240A007E6F65F8C7EF"

CLAVE="$PKG/src/usr/share/keyrings/encina-archive-keyring.gpg"
FUENTE="$PKG/src/etc/apt/sources.list.d/encina.sources"

# ============================================================================
titulo "0. El changelog, que no se escribe a mano ni en el Mac"

if [[ ! -f "$PKG/debian/changelog" ]]; then
    echo
    echo "${C_AVI}No hay debian/changelog, y este script no lo crea.${C_FIN}"
    echo "Créalo en la VM con dch --create (nunca a mano) y vuelve."
    exit 1
fi
ok "Hay debian/changelog"
VERSION=$(dpkg-parsechangelog -l "$PKG/debian/changelog" -S Version 2>/dev/null || echo "?")
echo "         versión $VERSION"

# ============================================================================
if [[ "${1:-}" != "--saltar-reglas" ]]; then
titulo "1. La clave de firma"

if [[ ! -f "$CLAVE" ]]; then
    fallo "No existe la clave: $CLAVE" ""
    resumen; exit 1
fi
HUELLA_REAL=$(gpg --show-keys --with-colons "$CLAVE" 2>/dev/null \
              | awk -F: '/^fpr:/ {print $10; exit}')
if [[ "$HUELLA_REAL" == "$HUELLA_ENCINA" ]]; then
    ok "Huella verificada: $HUELLA_REAL"
    echo "         $(gpg --show-keys --with-colons "$CLAVE" 2>/dev/null | awk -F: '/^uid:/ {print $10; exit}')"
else
    fallo "LA HUELLA DE LA CLAVE NO COINCIDE" \
"esperada: $HUELLA_ENCINA
obtenida: ${HUELLA_REAL:-<gpg no ha podido leer la clave>}

DETENTE AQUÍ. Este paquete existe para decirle a apt en quién confiar; una
clave con otra huella no es un detalle, es el fallo entero. Avisa antes de
hacer nada más."
    resumen; exit 1
fi
# la clave tiene que ser de SOLO FIRMA y sin subclaves de cifrado: es una
# clave de repositorio, no un buzón
N_CLAVES=$(gpg --show-keys --with-colons "$CLAVE" 2>/dev/null | grep -c '^pub:' || true)
if [[ "$N_CLAVES" == 1 ]]; then
    ok "El keyring lleva exactamente UNA clave pública"
else
    fallo "El keyring lleva $N_CLAVES claves y tenía que llevar 1 (la rotación con dos es una versión futura, a sabiendas)" \
"$(gpg --show-keys "$CLAVE" 2>/dev/null)"
fi

# ============================================================================
titulo "2. Reglas duras que aplican a este paquete"

# --- R3: sin scripts de mantenedor, y aquí ninguno es la forma de cumplirlo -
MANT_PRESENTES=$(ls "$PKG/debian"/preinst "$PKG/debian"/postinst "$PKG/debian"/prerm "$PKG/debian"/postrm 2>/dev/null || true)
if [[ -z "$MANT_PRESENTES" ]]; then
    ok "R3 — el paquete no lleva scripts de mantenedor (nada que ejecutar; encina-local.list se deja en paz, §4.84e)"
else
    fallo "R3 — hay scripts de mantenedor y este paquete no debe llevar ninguno" "$MANT_PRESENTES"
fi

# --- la fuente dice lo que D25 decidió, campo a campo -----------------------
comprobar_fuente() {  # $1 campo  $2 valor exacto
    if grep -qx "$1: $2" "$FUENTE"; then
        ok "encina.sources: $1: $2"
    else
        fallo "encina.sources no dice «$1: $2»" "$(cat "$FUENTE")"
    fi
}
comprobar_fuente "Types" "deb"
comprobar_fuente "URIs" "https://downloads.sourceforge.net/project/encina-os/repo"
comprobar_fuente "Suites" "encina"
comprobar_fuente "Components" "main"
comprobar_fuente "Signed-By" "/usr/share/keyrings/encina-archive-keyring.gpg"
# y el Signed-By apunta EXACTAMENTE al fichero que este paquete instala
RUTA_SB=$(sed -n 's/^Signed-By: //p' "$FUENTE")
if [[ "$PKG/src$RUTA_SB" -ef "$CLAVE" ]] || [[ "$PKG/src$RUTA_SB" == "$CLAVE" ]]; then
    ok "Signed-By apunta al keyring que viaja en este mismo paquete"
else
    fallo "Signed-By apunta a $RUTA_SB y el keyring del paquete es $CLAVE" ""
fi

# --- sin dependencias: la clave no necesita nada para ser leída -------------
DEPS=$(grep -E '^(Depends|Pre-Depends|Recommends):' "$PKG/debian/control" | grep -v '^Depends: ${misc:Depends}$' || true)
if [[ -z "$DEPS" ]]; then
    ok "Sin dependencias más allá de \${misc:Depends}"
else
    fallo "El paquete declara dependencias que no necesita" "$DEPS"
fi
fi

# ============================================================================
titulo "3. Construcción"

paso "dpkg-buildpackage -us -uc -b"
if SALIDA=$(cd "$PKG" && dpkg-buildpackage -us -uc -b 2>&1); then
    ok "dpkg-buildpackage termina sin error"
else
    fallo "dpkg-buildpackage ha fallado" "$(echo "$SALIDA" | tail -25)"
    resumen; exit 1
fi
DEB=$(ls -t "$SALIDA_DIR"/${PAQUETE}_*.deb 2>/dev/null | head -1 || true)
[[ -n "$DEB" ]] || { fallo "No ha aparecido ningún .deb en $SALIDA_DIR" ""; resumen; exit 1; }
ok "Generado: $(basename "$DEB")"

# ============================================================================
titulo "4. Lo que ha quedado DENTRO del paquete"
CONTENIDO=$(dpkg-deb -c "$DEB")
echo "$CONTENIDO" | awk '{print $6}' | grep -v '/$' | sed 's/^/  /'

for esperado in \
    "etc/apt/sources.list.d/encina.sources" \
    "usr/share/keyrings/encina-archive-keyring.gpg"
do
    if grep -q "$esperado" <<<"$CONTENIDO"; then
        ok "Incluye $esperado"
    else
        fallo "El paquete NO incluye $esperado" ""
    fi
done
# la clave DE DENTRO del .deb tiene la huella buena (lo que viaja, no lo que
# hay en src/: trampa 13 aplicada al empaquetado)
TMPX=$(mktemp -d); trap 'rm -rf "$TMPX"' EXIT
dpkg-deb -x "$DEB" "$TMPX"
H_DENTRO=$(gpg --show-keys --with-colons "$TMPX/usr/share/keyrings/encina-archive-keyring.gpg" 2>/dev/null \
           | awk -F: '/^fpr:/ {print $10; exit}')
if [[ "$H_DENTRO" == "$HUELLA_ENCINA" ]]; then
    ok "La clave DENTRO del .deb tiene la huella buena"
else
    fallo "La clave dentro del .deb tiene otra huella" "dentro: ${H_DENTRO:-ilegible}"
fi
CONFF=$(dpkg-deb -I "$DEB" conffiles 2>/dev/null || echo "")
if grep -q "sources.list.d/encina.sources" <<<"$CONFF"; then
    ok "encina.sources es conffile (apt purge lo quita y dpkg respeta ediciones)"
else
    fallo "encina.sources NO es conffile" "conffiles: $CONFF"
fi

# ============================================================================
titulo "5. Lintian"
OVR="$PKG/debian/${PAQUETE}.lintian-overrides"
if [[ -f "$OVR" ]]; then
    N_TAGS=$(grep -cvE '^\s*(#|$)' "$OVR" || true)
    N_JUST=$(grep -cE '^\s*#' "$OVR" || true)
    ok "Hay $N_TAGS override(s) de lintian, con $N_JUST líneas de justificación"
fi
if SALIDA=$(lintian --fail-on error "$DEB" 2>&1); then
    ok "lintian sin errores"
    ANULADOS=$(lintian --show-overrides "$DEB" 2>&1 | grep '^O:' || true)
    [[ -n "$ANULADOS" ]] && { echo "  Tags anulados (justificados en $(basename "$OVR")):"; echo "$ANULADOS" | sed 's/^/    /'; }
else
    fallo "lintian ha encontrado errores" "$SALIDA"
fi

resumen
