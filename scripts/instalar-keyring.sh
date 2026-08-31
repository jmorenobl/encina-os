#!/usr/bin/env bash
# instalar-keyring.sh — Instala encina-keyring y comprueba lo que deja.
#
# Uso:  ./scripts/instalar-keyring.sh
#
# OJO CON EL ORDEN (D25): el repositorio remoto tiene que existir antes de que
# una máquina de usuario lleve este paquete — una fuente sin servidor es un
# error rc 100 en cada apt update (§4.84e). En el banco se instala igual para
# medir, y verificar-keyring.sh deja ese estado escrito.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
# MODELO DE SALIDA: CONTAR Y SEGUIR (tarea 2, MEDICIONES.md §4.67).
set -euo pipefail
requiere_no_root

PAQUETE="encina-keyring"
HUELLA_ENCINA="58A525AB990C4B8DC5AB3D240A007E6F65F8C7EF"
SALIDA_DIR="$(raiz_repo)/debian-packages"
DEB=$(ls -t "$SALIDA_DIR"/${PAQUETE}_*.deb 2>/dev/null | head -1 || true)
[[ -n "$DEB" ]] || { echo "No hay ningún .deb. Ejecuta antes ./scripts/construir-keyring.sh"; exit 1; }

titulo "1. Instalación"
if SALIDA=$(sudo apt-get install -y "$DEB" 2>&1); then
    ok "apt-get install $(basename "$DEB") termina sin error"
else
    fallo "La instalación ha fallado" "$(echo "$SALIDA" | tail -20)"
    resumen; exit 1
fi

titulo "2. Lo que ha quedado en el sistema, releído (trampa 13)"
EST=$(dpkg-query -W -f='${Status} ${Version}' "$PAQUETE" 2>/dev/null || true)
if [[ "$EST" == "install ok installed"* ]]; then
    ok "dpkg dice: $EST"
else
    fallo "El paquete no consta como instalado" "$EST"
fi
for f in /usr/share/keyrings/encina-archive-keyring.gpg \
         /etc/apt/sources.list.d/encina.sources; do
    if [[ -f "$f" ]]; then ok "Presente: $f"; else fallo "FALTA $f" ""; fi
done
H=$(gpg --show-keys --with-colons /usr/share/keyrings/encina-archive-keyring.gpg 2>/dev/null \
    | awk -F: '/^fpr:/ {print $10; exit}')
if [[ "$H" == "$HUELLA_ENCINA" ]]; then
    ok "La clave instalada tiene la huella de Encina OS: $H"
else
    fallo "La clave instalada tiene OTRA huella" "instalada: ${H:-ilegible}"
fi

resumen
RES=$?
echo
echo "Siguiente:  ./scripts/verificar-keyring.sh [--repo-prueba <dir firmado>]"
exit $RES
