#!/usr/bin/env bash
# instalar-branding.sh — Instala el .deb y comprueba todo lo verificable sin reiniciar.
#
# Uso:  ./scripts/instalar-branding.sh [--si-ya-cloné]
#
# ANTES de ejecutarlo por primera vez: apaga la VM y clónala en UTM con el
# nombre encina-limpia-respaldo. Es la primera vez que puedes dejar la máquina
# sin arrancar, y reinstalar Ubuntu a la una de la mañana es como se abandonan
# los proyectos.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
# MODELO DE SALIDA: CONTAR Y SEGUIR (tarea 2, MEDICIONES.md §4.67). fallo()
# apunta, incrementa N_MAL y SIGUE midiendo; morir() aborta; quien fija el
# código de salida es resumen(). El 'set' lo pone lib.sh:5 al hacer source: se
# REAFIRMA aquí para que las opciones de shell de este guion no dependan de a
# quién llame. Reafirmarlo no cambia ni una opción — control en §4.67.
set -euo pipefail
requiere_no_root

SALIDA_DIR="$(raiz_repo)/debian-packages"
DEB=$(ls -t "$SALIDA_DIR"/encina-branding_*.deb 2>/dev/null | head -1 || true)
[[ -n "$DEB" ]] || { echo "No hay ningún .deb. Ejecuta antes ./scripts/construir-branding.sh"; exit 1; }

# ---------------------------------------------------------- red de seguridad -
if [[ "${1:-}" != "--si-ya-cloné" ]]; then
    echo
    echo "${C_AVI}Antes de seguir:${C_FIN} ¿has clonado la VM en UTM como respaldo?"
    echo "  (clic derecho sobre encina-dev -> Clonar -> encina-limpia-respaldo)"
    echo
    read -r -p "Escribe 'si' para continuar: " resp
    [[ "$resp" == "si" ]] || { echo "Clónala y vuelve. Tarda dos minutos."; exit 1; }
fi

titulo "Instalación"
echo "  Paquete: $(basename "$DEB")"

# Estado previo, para poder compararlo después.
GRUB_ANTES=$(md5sum /etc/default/grub 2>/dev/null | cut -d' ' -f1 || echo "-")

paso "sudo apt install (hace falta sudo)"
if sudo apt-get install -y "$DEB"; then
    ok "Paquete instalado"
else
    fallo "La instalación ha fallado" "revisa la salida de apt arriba"
    resumen; exit 1
fi

# ============================================================================
titulo "Comprobaciones sin reiniciar"

# --- 1. Tema de Plymouth registrado ----------------------------------------
comprobar_salida "El tema encina es la alternativa activa de default.plymouth" \
    "encina" update-alternatives --display default.plymouth

# --- 2. LA comprobación que predice si verás el logotipo -------------------
paso "¿Está el tema dentro del initramfs? (R7)"
KERNEL=$(uname -r)
INITRD="/boot/initrd.img-$KERNEL"
if [[ ! -f "$INITRD" ]]; then
    fallo "No encuentro $INITRD" "$(ls -1 /boot/initrd.img-* 2>&1 || true)"
elif sudo lsinitramfs "$INITRD" 2>/dev/null | grep -q "themes/encina"; then
    ok "El tema encina está dentro del initramfs"
else
    fallo "El tema NO está en el initramfs" \
"NO REINICIES todavía: no verías ningún cambio.
Fuérzalo a mano y vuelve a ejecutar este script:
    sudo update-initramfs -u"
fi

# --- 3. GRUB ---------------------------------------------------------------
N_GRUB=$(grep -c "^GRUB_DISTRIBUTOR" /etc/default/grub 2>/dev/null || echo 0)
if [[ "$N_GRUB" == "1" ]] && grep -q 'GRUB_DISTRIBUTOR="Encina OS"' /etc/default/grub; then
    ok "GRUB_DISTRIBUTOR fijado, una sola línea"
elif [[ "$N_GRUB" -gt 1 ]]; then
    fallo "GRUB_DISTRIBUTOR aparece $N_GRUB veces" \
"$(grep -n '^GRUB_DISTRIBUTOR' /etc/default/grub)
El sed del postinst está añadiendo en vez de sustituir. Fallo de
idempotencia (R9): se agravará con cada reinstalación."
else
    fallo "GRUB_DISTRIBUTOR no está fijado" "$(grep -n 'GRUB_DISTRIBUTOR' /etc/default/grub || echo 'no aparece')"
fi

# --- 4. dconf de GDM -------------------------------------------------------
if [[ -f /etc/dconf/db/gdm ]]; then
    ok "La base de datos de dconf de GDM existe (dconf update se ejecutó)"
else
    fallo "No existe /etc/dconf/db/gdm" \
"El perfil está en /etc/dconf/db/gdm.d/ pero no se ha compilado.
Falta 'dconf update' en el postinst, o ha fallado."
fi
comprobar_fichero "El perfil de GDM está instalado" /etc/dconf/db/gdm.d/99-encina

# --- 5. Esquemas de GSettings compilados (R2: lo hace el disparador) -------
if [[ -f /usr/share/glib-2.0/schemas/gschemas.compiled ]]; then
    if [[ /usr/share/glib-2.0/schemas/gschemas.compiled -nt \
          /usr/share/glib-2.0/schemas/99-encina-branding.gschema.override ]]; then
        ok "Los esquemas se recompilaron después del override (disparador de dpkg, R2)"
    else
        fallo "gschemas.compiled es más antiguo que el override" \
"El disparador de libglib2.0-0 no se ha ejecutado. NO llames a
glib-compile-schemas desde el postinst (R2): averigua por qué no saltó."
    fi
else
    fallo "No existe gschemas.compiled" ""
fi

# --- 6. Valores por defecto efectivos --------------------------------------
paso "Valores por defecto que verá un usuario nuevo"
for clave in picture-uri picture-uri-dark; do
    VAL=$(gsettings get org.gnome.desktop.background "$clave" 2>/dev/null || echo "?")
    if echo "$VAL" | grep -q "backgrounds/encina"; then
        ok "$clave -> $VAL"
    else
        aviso "$clave -> $VAL  (tu usuario puede tener un valor propio; lo definitivo es verificar-branding.sh)"
    fi
done

# --- 7. Ficheros instalados íntegros ---------------------------------------
comprobar "Los ficheros instalados coinciden con el paquete (dpkg -V)" \
    sudo dpkg -V encina-branding

GRUB_DESPUES=$(md5sum /etc/default/grub 2>/dev/null | cut -d' ' -f1 || echo "-")
[[ "$GRUB_ANTES" != "$GRUB_DESPUES" ]] && echo "  (nota: /etc/default/grub ha cambiado, era lo esperado)"

resumen
RES=$?

# ============================================================================
echo
titulo "Lo que solo pueden verificar tus ojos"
pendiente_visual "Reinicia y mira la ventana de UTM, en este orden:"
echo "            1. menú de GRUB con 'Encina OS'"
echo "            2. splash de arranque con tu logotipo (no el de Ubuntu, no el del fabricante)"
echo "            3. pantalla de GDM con tu logotipo y tu mensaje"
echo "            4. escritorio con tu fondo"
echo
echo "  sudo reboot"
echo
echo "Si el splash pasa demasiado rápido para verlo, no pasa nada: la"
echo "comprobación del initramfs de arriba ya te dice que está puesto."
echo
(( RES == 0 )) && echo "Después del reinicio:  ./scripts/verificar-branding.sh"
exit $RES
