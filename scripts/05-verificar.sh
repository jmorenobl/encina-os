#!/usr/bin/env bash
# 05-verificar.sh — La batería que separa "parece que funciona" de "funciona".
#
# Uso:  ./scripts/05-verificar.sh [--sin-purga] [--conservar-usuario]
#
#   --sin-purga          no desinstala el paquete (sáltate la prueba de purga)
#   --conservar-usuario  no recrea el usuario 'prueba'
#
# Cubre las casillas de ENCINA-OS.md §7 que se pueden automatizar. Las que no,
# las lista al final marcadas [OJOS], sin darlas por buenas.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
# MODELO DE SALIDA: CONTAR Y SEGUIR (tarea 2, MEDICIONES.md §4.67). fallo()
# apunta, incrementa N_MAL y SIGUE midiendo; morir() aborta; quien fija el
# código de salida es resumen(). El 'set' lo pone lib.sh:5 al hacer source: se
# REAFIRMA aquí para que las opciones de shell de este guion no dependan de a
# quién llame. Reafirmarlo no cambia ni una opción — control en §4.67.
set -euo pipefail
requiere_no_root

SIN_PURGA=0; CONSERVAR_USUARIO=0
for arg in "$@"; do
    case "$arg" in
        --sin-purga)         SIN_PURGA=1 ;;
        --conservar-usuario) CONSERVAR_USUARIO=1 ;;
        *) echo "Opción desconocida: $arg"; exit 1 ;;
    esac
done

SALIDA_DIR="$(raiz_repo)/debian-packages"
DEB=$(ls -t "$SALIDA_DIR"/encina-branding_*.deb 2>/dev/null | head -1 || true)
[[ -n "$DEB" ]] || { echo "No hay ningún .deb. Ejecuta antes ./scripts/03-construir.sh"; exit 1; }

dpkg-query -W -f='${Status}' encina-branding 2>/dev/null | grep -q "install ok installed" \
    || { echo "encina-branding no está instalado. Ejecuta antes ./scripts/04-instalar.sh"; exit 1; }

USUARIO_PRUEBA="prueba"
CLAVE_PRUEBA="encina"

# ============================================================================
titulo "1. Usuario creado DESPUÉS de instalar (R1)"

echo "  Es la prueba que descubre si se ha usado /etc/skel por error."
echo "  /etc/skel solo alcanza a los usuarios creados después y no se puede"
echo "  actualizar; gschema.override alcanza a todos, siempre."
echo

if id "$USUARIO_PRUEBA" &>/dev/null; then
    if (( CONSERVAR_USUARIO )); then
        aviso "El usuario '$USUARIO_PRUEBA' ya existía y se conserva: si se creó ANTES de instalar, esta prueba no vale"
    else
        paso "Recreando '$USUARIO_PRUEBA' para que la prueba sea válida"
        sudo pkill -u "$USUARIO_PRUEBA" 2>/dev/null || true
        sleep 1
        sudo userdel -r "$USUARIO_PRUEBA" 2>/dev/null || true
        sudo useradd -m -s /bin/bash "$USUARIO_PRUEBA"
        echo "$USUARIO_PRUEBA:$CLAVE_PRUEBA" | sudo chpasswd
        ok "Usuario '$USUARIO_PRUEBA' recreado después de la instalación (contraseña: $CLAVE_PRUEBA)"
    fi
else
    sudo useradd -m -s /bin/bash "$USUARIO_PRUEBA"
    echo "$USUARIO_PRUEBA:$CLAVE_PRUEBA" | sudo chpasswd
    ok "Usuario '$USUARIO_PRUEBA' creado (contraseña: $CLAVE_PRUEBA)"
fi

paso "Valores que hereda el usuario nuevo"
for clave in picture-uri picture-uri-dark; do
    VAL=$(sudo -u "$USUARIO_PRUEBA" env HOME="/home/$USUARIO_PRUEBA" \
          gsettings get org.gnome.desktop.background "$clave" 2>/dev/null || echo "ERROR")
    if echo "$VAL" | grep -q "backgrounds/encina"; then
        ok "$clave -> $VAL"
    else
        fallo "$clave no lo hereda el usuario nuevo" \
"valor obtenido: $VAL
El gschema.override no está haciendo su trabajo. Sospecha de R1 (se usó
/etc/skel) o de R2 (los esquemas no se han recompilado).
Si el que falla es solo picture-uri-dark, falta esa clave en el override:
quien use modo oscuro verá el fondo claro."
    fi
done

# ============================================================================
titulo "2. La bienvenida de Ubuntu, enmascarada (0.1.11)"

echo "  La ventana «Le damos la bienvenida a Ubuntu 24.04.4 LTS» la lanza la"
echo "  unidad de usuario gnome-initial-setup-first-login.service. Su puerta"
echo "  es ~/.config/gnome-initial-setup-done, que es del USUARIO: ponerlo por"
echo "  defecto seria /etc/skel y lo prohibe R1. Por eso se enmascara la"
echo "  unidad desde /etc/systemd/user/, que alcanza a todos los usuarios."
echo

MASCARA=/etc/systemd/user/gnome-initial-setup-first-login.service
if [[ -L "$MASCARA" && "$(readlink "$MASCARA")" == "/dev/null" ]]; then
    ok "$MASCARA -> /dev/null"
else
    fallo "La máscara no está instalada como enlace a /dev/null" \
"$(ls -l "$MASCARA" 2>&1)
Un fichero normal con ese nombre NO enmascara: systemd lo lee como una unidad
vacía y la ventana vuelve en cada sesión."
fi

# Y esto es lo que de verdad decide, porque le pregunta a systemd y no al
# sistema de ficheros. El control de esta comprobación está en la purga: allí
# la misma orden tiene que volver a decir 'static'.
EST=$(systemctl --user is-enabled gnome-initial-setup-first-login.service 2>&1 || true)
if [[ "$EST" == "masked" ]]; then
    ok "systemctl --user is-enabled ... -> masked"
else
    fallo "systemd NO ve la unidad enmascarada" \
"is-enabled dijo: $EST
Esperado: masked. /etc/systemd/user gana a /usr/lib/systemd/user en la ruta
de búsqueda; si dice 'static', la máscara no está llegando."
fi

# ============================================================================
titulo "2b. GDM espera a udev-settle (0.1.16, MEDICIONES.md §4.70f y §4.71)"

echo "  En hierro AMD el saludador nace sobre simpledrm y muere al llegar"
echo "  amdgpu (mutter 46.2). El drop-in hace que gdm.service espere a"
echo "  systemd-udev-settle.service; en arm64 cuesta 0 s (§4.71). Lo que"
echo "  decide no es que el fichero este, sino que systemd lo haya leido."
echo

DROPIN=/etc/systemd/system/gdm.service.d/encina-espera-gpu.conf
if [[ -f "$DROPIN" ]] && grep -q '^After=systemd-udev-settle.service' "$DROPIN" \
   && grep -q '^Wants=systemd-udev-settle.service' "$DROPIN"; then
    ok "$DROPIN con Wants= y After="
else
    fallo "El drop-in no esta o no lleva las dos lineas" "$(cat "$DROPIN" 2>&1)"
fi
comprobar_salida "El drop-in es nuestro (dpkg -S)" "encina-branding" dpkg -S "$DROPIN"

# Lo que de verdad decide: systemd, no el sistema de ficheros. Su control
# esta en la purga, donde la misma orden tiene que dejar de listarla.
# La salida es UNA linea 'Wants=a.service b.service': hay que quitar el
# 'Wants=' antes de buscar la unidad exacta. La primera version no lo quitaba
# y esta comprobacion no podia decir 'si' NUNCA -y su control de la purga
# decia 'no' siempre, o sea verde falso- (MEDICIONES.md §4.72).
WANTS=$(systemctl show gdm.service -p Wants 2>&1 || true)
if echo "${WANTS#Wants=}" | tr ' ' '\n' | grep -qx 'systemd-udev-settle.service'; then
    ok "systemctl show gdm.service -p Wants lista systemd-udev-settle.service"
else
    fallo "systemd NO tiene el drop-in cargado" \
"$WANTS
Esperado: systemd-udev-settle.service en Wants=. Si el fichero esta y esto
falla, falta el daemon-reload del postinst."
fi
# El precio, que se apunta y no se esconde: el aviso de udevadm en el ultimo
# arranque. Solo sale si la unidad corrio, o sea si el drop-in estaba puesto
# AL ARRANCAR; recien instalado sin reiniciar es normal que no este.
if journalctl -b --no-pager 2>/dev/null | grep -q 'udev-settle.service is deprecated'; then
    aviso "En este arranque udevadm dijo: '$(journalctl -b --no-pager | grep -m1 -o 'systemd-udev-settle.service is deprecated.*')' -- es el precio conocido (§4.70f)"
else
    omitido "El aviso de deprecacion de udev-settle no esta en este arranque: el drop-in no estaba al arrancar, o no hay journal. Reinicia y repite para verlo"
fi

# ============================================================================
titulo "2c. La bellota no depende de icon-theme (0.1.17, MEDICIONES.md §4.70c y §4.75)"

echo "  En el Acer, tocar el modo oscuro en Ajustes y volver a claro dejo"
echo "  icon-theme='Yaru-sage' escrito en el perfil del usuario, y un valor"
echo "  de usuario gana SIEMPRE al override: la bellota del dock se fue con"
echo "  el. La salida es que el fichero que Yaru sirve sea el nuestro, via"
echo "  dpkg-divert en el preinst; UN desvio cubre los 19 acentos porque"
echo "  todas las cadenas de Inherits mueren en Yaru (§4.75)."
echo

BELLOTA_YARU=/usr/share/icons/Yaru/scalable/actions/view-app-grid-ubuntu-symbolic.svg
BELLOTA_ENCINA=/usr/share/icons/Encina/scalable/actions/view-app-grid-ubuntu-symbolic.svg
CACHE_YARU=/usr/share/icons/Yaru/icon-theme.cache

# (i) El desvio esta registrado y es nuestro. Su control esta en la purga:
# alli la MISMA orden tiene que devolver vacio, o esto no comprueba nada.
DIVERT=$(dpkg-divert --listpackage "$BELLOTA_YARU" 2>&1 || true)
if [[ "$DIVERT" == "encina-branding" ]]; then
    ok "dpkg-divert --listpackage -> encina-branding"
else
    fallo "El desvio del icono de Yaru no esta registrado (o no es nuestro)" \
"--listpackage dijo: '$DIVERT'
$(dpkg-divert --list '*view-app-grid*' 2>&1)"
fi

# (ii) El fichero que se sirve en la ruta de Yaru es EL NUESTRO, por huella:
# la misma que el del tema Encina (misma fuente unica, debian/rules). No
# basta con que exista: existir tambien lo cumplia el enlace de Ubuntu.
H_YARU=$(md5sum "$BELLOTA_YARU" 2>/dev/null | cut -d' ' -f1 || true)
H_ENCINA=$(md5sum "$BELLOTA_ENCINA" 2>/dev/null | cut -d' ' -f1 || true)
if [[ -n "$H_YARU" && "$H_YARU" == "$H_ENCINA" ]]; then
    ok "El fichero en la ruta de Yaru es el nuestro (md5 $H_YARU)"
else
    fallo "El fichero en la ruta de Yaru NO es el nuestro" \
"Yaru:   ${H_YARU:-no se pudo leer}   $(ls -l "$BELLOTA_YARU" 2>&1)
Encina: ${H_ENCINA:-no se pudo leer}"
fi

# (iii) El original de Yaru espera entero en .distrib: era un ENLACE a
# ../places/start-here-symbolic.svg (§4.75a) y el desvio lo renombro, no lo
# destruyo. Es lo que la purga tiene que devolver a su sitio.
DESTINO=$(readlink "$BELLOTA_YARU.distrib" 2>/dev/null || true)
if [[ "$DESTINO" == *start-here-symbolic.svg ]]; then
    ok "El original de Yaru espera en .distrib -> $DESTINO"
else
    fallo "El original de Yaru no esta en .distrib como enlace a start-here" \
"$(ls -l "$BELLOTA_YARU.distrib" 2>&1)"
fi

# (iv) TRAMPA 13: Yaru lleva icon-theme.cache y GTK lo consulta. Quien lo
# regenera -MEDIDO el 2026-08-24, no supuesto- es el trozo que dh_icons
# añade a NUESTRO postinst y postrm: 'update-icon-caches
# /usr/share/icons/Encina /usr/share/icons/Yaru' (solo toca caches que ya
# existen: el de Yaru; Encina no lleva). Pero eso es lo que el paquete
# pide, no lo que paso. Se mide: el cache tiene que ser MAS NUEVO que nuestro SVG (el mtime del SVG
# viene del .deb, o sea del build; el del cache, de cuando corrio el
# disparador). Un cache rancio puede seguir sirviendo el dibujo viejo con
# el fichero nuevo ya en disco, y nadie lo ve hasta mirar el dock -la
# cadena existe->gana->resuelve->carga->se pinta, y esto mide 'carga'-.
if [[ -f "$CACHE_YARU" && "$CACHE_YARU" -nt "$BELLOTA_YARU" ]]; then
    ok "icon-theme.cache de Yaru es mas nuevo que el SVG (el disparador corrio)"
else
    fallo "icon-theme.cache de Yaru NO se regenero tras instalar el SVG" \
"$(ls -l --time-style=full-iso "$CACHE_YARU" "$BELLOTA_YARU" 2>&1)
El update-icon-caches de dh_icons (postinst) no corrio o no existe el
cache. Un cache mas viejo que el fichero puede seguir sirviendo el de Ubuntu.
A mano:  sudo gtk-update-icon-cache -f /usr/share/icons/Yaru"
fi

# ============================================================================
titulo "3. Idempotencia: cinco instalaciones seguidas (R9)"

instantanea() {
    {
        md5sum /etc/default/grub 2>/dev/null || true
        grep -c "^GRUB_DISTRIBUTOR" /etc/default/grub 2>/dev/null || true
        update-alternatives --query default.plymouth 2>/dev/null | grep -E "^(Value|Best|Priority):" || true
        dpkg -l encina-branding 2>/dev/null | tail -1 || true
        dpkg-divert --listpackage "$BELLOTA_YARU" 2>/dev/null || true
        md5sum "$BELLOTA_YARU" 2>/dev/null || true
    } 2>/dev/null
}

ANTES=$(instantanea)
paso "Reinstalando cinco veces"
CICLOS_OK=1
for i in 1 2 3 4 5; do
    if salida=$(sudo apt-get install -y --reinstall "$DEB" 2>&1); then
        printf "  ciclo %d/5 ok\n" "$i"
    else
        fallo "La reinstalación número $i ha fallado" "$(echo "$salida" | tail -20)"
        CICLOS_OK=0
        break
    fi
done
(( CICLOS_OK )) && ok "Cinco reinstalaciones sin error"

DESPUES=$(instantanea)
if [[ "$ANTES" == "$DESPUES" ]]; then
    ok "El estado del sistema es idéntico antes y después"
else
    fallo "El estado del sistema ha cambiado tras reinstalar" \
"$(diff <(echo "$ANTES") <(echo "$DESPUES") || true)"
fi

N_GRUB=$(grep -c "^GRUB_DISTRIBUTOR" /etc/default/grub 2>/dev/null || echo 0)
if [[ "$N_GRUB" == "1" ]]; then
    ok "GRUB_DISTRIBUTOR sigue apareciendo una sola vez"
else
    fallo "GRUB_DISTRIBUTOR aparece $N_GRUB veces tras cinco ciclos" \
"$(grep -n '^GRUB_DISTRIBUTOR' /etc/default/grub)
El sed del postinst añade en vez de sustituir. Es el fallo de idempotencia
clásico y no se nota a simple vista."
fi

comprobar "Integridad de los ficheros instalados (dpkg -V)" sudo dpkg -V encina-branding

# ============================================================================
if (( SIN_PURGA )); then
    titulo "4. Purga — OMITIDA por --sin-purga"
    omitido "apt purge restaura el tema de arranque original"
    omitido "EL CONTROL de la máscara: sin purgar, 'masked' no demuestra nada"
    omitido "EL CONTROL del desvio (2c): sin purgar, un desvio puesto no demuestra que sepa irse"
else
titulo "4. Purga: desinstalación limpia"

paso "sudo apt purge encina-branding"
T_PURGA=$(date +%s)   # para medir que el cache de Yaru se regenera DESPUES
if salida=$(sudo apt-get purge -y encina-branding 2>&1); then
    ok "Purga ejecutada sin error"
else
    fallo "La purga ha fallado" "$(echo "$salida" | tail -20)"
fi

ALT_DESPUES=$(update-alternatives --query default.plymouth 2>/dev/null | grep "^Value:" || echo "")
if echo "$ALT_DESPUES" | grep -q "encina"; then
    fallo "Tras purgar, el tema de Plymouth sigue siendo el de Encina" \
"$ALT_DESPUES
Falta update-alternatives --remove en el prerm."
else
    ok "El tema de arranque vuelve al original (${ALT_DESPUES#Value: })"
fi

if [[ -d /usr/share/backgrounds/encina ]]; then
    fallo "Los fondos siguen instalados tras la purga" "$(ls /usr/share/backgrounds/encina)"
else
    ok "Los fondos se han eliminado"
fi

# EL CONTROL DE LA COMPROBACIÓN 2, y sin él aquel 'masked' no vale: una
# comprobación que no puede dar sus dos respuestas no es una comprobación.
EST_PURGA=$(systemctl --user is-enabled gnome-initial-setup-first-login.service 2>&1 || true)
if [[ "$EST_PURGA" == "static" ]]; then
    ok "Control: purgado, la unidad vuelve a 'static' (la bienvenida volvería)"
else
    fallo "Tras purgar, la unidad NO vuelve a su estado original" \
"is-enabled dijo: $EST_PURGA
Esperado: static. Si sigue diciendo 'masked', la máscara ha sobrevivido a la
purga y el paquete no es reversible."
fi

# EL CONTROL DE LA COMPROBACION 2b: purgado, udev-settle tiene que salir de
# Wants= de gdm.service, y el conffile del drop-in tiene que haberse ido.
WANTS_PURGA=$(systemctl show gdm.service -p Wants 2>&1 || true)
if [[ -e /etc/systemd/system/gdm.service.d/encina-espera-gpu.conf ]]; then
    fallo "Tras purgar, el drop-in de gdm.service sigue en /etc" \
"$(ls -l /etc/systemd/system/gdm.service.d/)"
elif echo "${WANTS_PURGA#Wants=}" | tr ' ' '\n' | grep -qx 'systemd-udev-settle.service'; then
    fallo "Tras purgar, systemd sigue queriendo udev-settle para gdm" \
"$WANTS_PURGA
El fichero se fue pero systemd no releyo: falta el daemon-reload del postrm."
else
    ok "Control: purgado, udev-settle sale de Wants= de gdm.service"
fi

# EL CONTROL DE LA COMPROBACION 2c, en sus cuatro mitades: sin esto, aquel
# 'encina-branding' del --listpackage no demostraba saber decir que no.
DIVERT_PURGA=$(dpkg-divert --listpackage "$BELLOTA_YARU" 2>&1 || true)
if [[ -z "$DIVERT_PURGA" ]]; then
    ok "Control 2c: purgado, el desvio del icono de Yaru ya no esta"
else
    fallo "Tras purgar, el desvio sigue registrado" \
"--listpackage dijo: '$DIVERT_PURGA'
Falta el dpkg-divert --remove del postrm: los upgrades de yaru-theme-icon
quedarian desviados para siempre."
fi
DESTINO_PURGA=$(readlink "$BELLOTA_YARU" 2>/dev/null || true)
if [[ "$DESTINO_PURGA" == *start-here-symbolic.svg ]]; then
    ok "Control 2c: el enlace original de Yaru ha vuelto a su ruta"
else
    fallo "Tras purgar, la ruta de Yaru no recupera el enlace original" \
"$(ls -l "$BELLOTA_YARU" 2>&1)
El --rename del postrm no devolvio el .distrib: el sistema se queda SIN
icono de rejilla en Yaru, que es peor que el de Ubuntu."
fi
if [[ ! -e "$BELLOTA_YARU.distrib" && ! -L "$BELLOTA_YARU.distrib" ]]; then
    ok "Control 2c: .distrib ya no existe"
else
    fallo "Tras purgar, .distrib sigue ahi" "$(ls -l "$BELLOTA_YARU.distrib" 2>&1)"
fi
# Y la trampa 13 otra vez: QUITAR nuestro SVG tambien tiene que regenerar
# el cache de Yaru, o el dibujo nuestro sobreviviria en el cache al paquete.
if [[ -f "$CACHE_YARU" && $(stat -c %Y "$CACHE_YARU") -ge $T_PURGA ]]; then
    ok "Control 2c: icon-theme.cache regenerado tambien al purgar"
else
    fallo "Tras purgar, icon-theme.cache de Yaru no se regenero" \
"$(ls -l --time-style=full-iso "$CACHE_YARU" 2>&1)   (la purga empezo en el segundo $T_PURGA)"
fi

paso "Reinstalando para dejar el sistema como estaba"
if sudo apt-get install -y "$DEB" >/dev/null 2>&1; then
    ok "Paquete reinstalado"
else
    fallo "No se ha podido reinstalar tras la purga" ""
fi
fi

# ============================================================================
resumen
RES=$?

echo
titulo "Pendiente de tus ojos (no lo doy por bueno yo)"
pendiente_visual "Cierra sesión y entra en GNOME como '$USUARIO_PRUEBA' (contraseña: $CLAVE_PRUEBA)"
echo "            El escritorio debe salir con tu fondo. Cambia a modo oscuro"
echo "            en Ajustes y comprueba que también cambia."
pendiente_visual "EL CONTROL DE PRODUCTO de la bellota (§4.70c, casilla de aspecto/5-cierre.md):"
echo "            en sesion grafica: Ajustes -> Apariencia -> oscuro, volver a"
echo "            claro, cerrar sesion, entrar - y la bellota del dock SIGUE."
echo "            Antes y despues, ensena en una terminal DE LA SESION:"
echo "                dconf read /org/gnome/desktop/interface/icon-theme"
echo "            y apunta que escribe el panel en oscuro (el pendiente de"
echo "            §4.75: ¿'Yaru-sage-dark'?). Con el desvio ese valor puede"
echo "            quedarse escrito: la bellota ya no depende de el."
pendiente_visual "Reinicia y confirma: GRUB, splash, GDM y escritorio con tu identidad"
pendiente_visual "Al entrar NO debe salir la ventana «Le damos la bienvenida a Ubuntu»"
echo "            Y el control es que el resto de la primera sesion siga igual:"
echo "            dock, fondo y rejilla donde estaban. 'masked' lo dice systemd;"
echo "            que no se pinte la ventana solo lo dice la pantalla."
echo
echo "Cuando eso pase, marca las casillas de ENCINA-OS.md §7 y anota el día:"
echo "    ./scripts/diario.sh \"A1 verificado. Siguiente: CI (06-ci.sh)\""
exit $RES
