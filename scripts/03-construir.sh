#!/usr/bin/env bash
# 03-construir.sh — Comprueba las reglas duras, construye el .deb y pasa lintian.
#
# Uso:  ./scripts/03-construir.sh [--saltar-reglas]
#
# Las comprobaciones de reglas son estáticas (grep sobre los ficheros): tardan
# un segundo y detectan justo los fallos que en caliente son invisibles y que
# solo se manifiestan al reiniciar, o solo en máquinas con LUKS.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
# MODELO DE SALIDA: CONTAR Y SEGUIR (tarea 2, MEDICIONES.md §4.67). fallo()
# apunta, incrementa N_MAL y SIGUE midiendo; morir() aborta; quien fija el
# código de salida es resumen(). El 'set' lo pone lib.sh:5 al hacer source: se
# REAFIRMA aquí para que las opciones de shell de este guion no dependan de a
# quién llame. Reafirmarlo no cambia ni una opción — control en §4.67.
set -euo pipefail
requiere_no_root
requiere_cmd dpkg-buildpackage lintian

PKG="$(PKG_DIR)"
SALIDA_DIR="$(raiz_repo)/debian-packages"
# DESDE DONDE SE LANZO, capturado ANTES de que nada haga 'cd'. Se usa mas
# abajo para comprobar que el arbol construido es el que tienes delante, y
# tiene que leerse aqui: la seccion de construccion hace 'cd "$PKG"', asi que
# a partir de ahi $PWD ya es el destino y comparar los dos siempre da igual
# -- que es como esta comprobacion salio verde sobre el fallo que caza.
INVOCADO_EN="$PWD"
[[ -d "$PKG/debian" ]] || { echo "No existe $PKG/debian. Ejecuta antes ./scripts/01-repo.sh"; exit 1; }

MANT=("$PKG/debian/preinst" "$PKG/debian/postinst" "$PKG/debian/prerm" "$PKG/debian/postrm")
PLY="$PKG/src/usr/share/plymouth/themes/encina"
OVERRIDE="$PKG/src/usr/share/glib-2.0/schemas/99-encina-branding.gschema.override"

# ============================================================================
if [[ "${1:-}" != "--saltar-reglas" ]]; then
titulo "Reglas duras (comprobación estática)"

# --- R1: nada de /etc/skel -------------------------------------------------
# Dos formas de violarla: enviar ficheros en src/etc/skel/, o escribir ahí
# desde un script de mantenedor. Se miran las dos, ignorando comentarios y
# sin entrar en debian/encina-branding/ (el directorio de montaje que deja
# el build anterior, que es una copia de src/ y daría un falso positivo).
R1_PRUEBAS=""
if [[ -d "$PKG/src/etc/skel" ]]; then
    R1_PRUEBAS+="El paquete instala ficheros en /etc/skel:"$'\n'
    R1_PRUEBAS+="$(find "$PKG/src/etc/skel" -type f 2>/dev/null)"$'\n'
fi
for m in "${MANT[@]}"; do
    [[ -f "$m" ]] || continue
    linea=$(grep -nE '^[^#]*etc/skel' "$m" 2>/dev/null || true)
    [[ -n "$linea" ]] && R1_PRUEBAS+="$m:$linea"$'\n'
done
if [[ -n "$R1_PRUEBAS" ]]; then
    fallo "R1 — se usa /etc/skel" \
"$R1_PRUEBAS
/etc/skel solo afecta a usuarios creados después y no se puede actualizar.
La configuración por defecto va en gschema.override o en perfiles de dconf."
else
    ok "R1 — no se usa /etc/skel"
fi

# --- R2: no llamar a glib-compile-schemas ----------------------------------
# Se ignoran los comentarios: mencionar la regla no es violarla.
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

# --- R3: no apt/dpkg/snap desde scripts de mantenedor ----------------------
SOSPECHOSO=""
for m in "${MANT[@]}"; do
    [[ -f "$m" ]] || continue
    # Se ignoran los comentarios y se exige palabra completa. Y dpkg-divert
    # NO es una llamada a dpkg (0.1.17): es el mecanismo que R5 prescribe y
    # no toca el bloqueo -esta hecho para correr desde un preinst-. Se borra
    # ese token antes de buscar, y solo ese, para que el resto de la linea
    # siga vigilada: un 'apt-get' al lado de un dpkg-divert se veria igual.
    linea=$(sed 's/dpkg-divert//g' "$m" | grep -nE '^[^#]*(\bapt\b|\bapt-get\b|\bdpkg\b|\bsnap\b)' || true)
    [[ -n "$linea" ]] && SOSPECHOSO+="$m:$linea"$'\n'
done
if [[ -n "$SOSPECHOSO" ]]; then
    fallo "R3 — posible llamada a apt/dpkg/snap desde un script de mantenedor" \
"$SOSPECHOSO
dpkg mantiene el bloqueo durante la instalación: esto provoca un interbloqueo.
(Si es un falso positivo, por ejemplo 'dpkg-divert' o una ruta, revísalo y sigue.)"
else
    ok "R3 — no se invoca apt/dpkg/snap desde los scripts de mantenedor"
fi

# --- R5: no enviar conffiles de otros paquetes -----------------------------
if [[ -e "$PKG/src/etc/default/grub" ]]; then
    fallo "R5 — el paquete incluye /etc/default/grub" \
"Ese fichero pertenece al paquete grub-common. Se edita in situ con sed
desde el postinst, nunca se sobrescribe."
else
    ok "R5 — no se sobrescribe /etc/default/grub"
fi
if [[ -e "$PKG/src/etc/os-release" || -e "$PKG/src/usr/lib/os-release" ]]; then
    fallo "R5 — el paquete toca os-release" "Está fuera de alcance (necesita dpkg-divert)."
else
    ok "R5 — no se toca os-release"
fi

# --- R5 + la máscara de la bienvenida (0.1.11) -----------------------------
# La ventana «Le damos la bienvenida a Ubuntu 24.04.4 LTS» la lanza la unidad
# de usuario gnome-initial-setup-first-login.service, que pertenece al paquete
# gnome-initial-setup y vive en /usr/lib/systemd/user/. Se desactiva
# ENMASCARÁNDOLA desde /etc/systemd/user/, que gana en la ruta de búsqueda de
# systemd y NO sobrescribe el fichero de nadie.
#
# Y la máscara SOLO funciona si es un enlace simbólico a /dev/null: un fichero
# normal vacío con ese nombre no enmascara nada, se lee como una unidad sin
# secciones y la ventana vuelve. Es justo lo que deja un clon de git con
# core.symlinks=false, así que esta comprobación no es decorativa.
MASCARA="$PKG/src/etc/systemd/user/gnome-initial-setup-first-login.service"
if [[ -e "$PKG/src/usr/lib/systemd" ]]; then
    fallo "R5 — el paquete envía unidades en /usr/lib/systemd" \
"$(find "$PKG/src/usr/lib/systemd" -mindepth 1 2>/dev/null)
Ese árbol pertenece a los paquetes que traen las unidades. Para desactivar
una, se enmascara desde /etc/systemd/user/."
else
    ok "R5 — no se envían unidades en /usr/lib/systemd"
fi
if [[ -L "$MASCARA" ]]; then
    DESTINO=$(readlink "$MASCARA")
    if [[ "$DESTINO" == "/dev/null" ]]; then
        ok "La máscara de la bienvenida apunta a /dev/null"
    else
        fallo "La máscara de la bienvenida apunta a otra cosa" \
"$MASCARA -> $DESTINO
systemd solo entiende como máscara un enlace a /dev/null."
    fi
elif [[ -e "$MASCARA" ]]; then
    fallo "La máscara de la bienvenida NO es un enlace simbólico" \
"$(ls -l "$MASCARA")
Un fichero normal con ese nombre no enmascara: systemd lo lee como una unidad
vacía y gnome-initial-setup vuelve a salir en cada sesión."
else
    fallo "Falta la máscara de gnome-initial-setup-first-login.service" \
"esperada en $MASCARA como enlace a /dev/null"
fi

# --- R6: tema basado en spinner, nunca en bgrt -----------------------------
if [[ -f "$PLY/encina.plymouth" ]]; then
    if grep -qi "bgrt" "$PLY/encina.plymouth"; then
        fallo "R6 — el tema hereda de bgrt" \
"$(grep -ni 'bgrt' "$PLY/encina.plymouth")
bgrt muestra el logotipo del firmware del fabricante: tu logotipo no
aparecería nunca. Debe basarse en spinner."
    else
        ok "R6 — el tema no hereda de bgrt"
    fi
else
    fallo "R6 — no existe encina.plymouth" "falta $PLY/encina.plymouth"
fi

# --- R7: el postinst debe regenerar el initramfs ---------------------------
if grep -qs "update-initramfs" "$PKG/debian/postinst"; then
    ok "R7 — el postinst llama a update-initramfs"
else
    fallo "R7 — el postinst no llama a update-initramfs" \
"El tema de Plymouth viaja dentro del initramfs. Sin regenerarlo no se
observa ningún cambio al arrancar, y el fallo es completamente silencioso."
fi

# --- Callback de contraseña (arranque con LUKS) ----------------------------
if grep -qs "SetDisplayPasswordFunction" "$PLY/encina.script"; then
    ok "Callback de contraseña presente (arranque con disco cifrado)"
else
    fallo "Falta SetDisplayPasswordFunction en encina.script" \
"En equipos con LUKS el arranque se queda en negro sin pedir la frase de
paso. Solo se manifiesta en máquinas cifradas: no lo verás en esta VM."
fi

# --- Fondo oscuro (GNOME 42+) ----------------------------------------------
if [[ -f "$OVERRIDE" ]]; then
    for clave in "picture-uri" "picture-uri-dark"; do
        if grep -q "$clave" "$OVERRIDE"; then
            ok "El override define $clave"
        else
            fallo "El override no define $clave" \
"Sin picture-uri-dark, quien use modo oscuro verá el fondo claro."
        fi
    done
else
    fallo "No existe el gschema.override" "falta $OVERRIDE"
fi

# --- El desvio de la bellota viaja con sus DOS MITADES (0.1.17) ------------
# dpkg-divert exige el protocolo entero: --add en el preinst (ANTES del
# desempaquetado, o dpkg ve nuestro fichero pisando el de yaru-theme-icon) y
# --remove en el postrm (remove). Una mitad sin la otra deja o bien el icono
# de Ubuntu ganando, o bien un desvio huerfano que se come los upgrades de
# yaru-theme-icon para siempre. El porque entero, en el preinst.
RUTA_BELLOTA='/usr/share/icons/Yaru/scalable/actions/view-app-grid-ubuntu-symbolic.svg'
if grep -qsF "$RUTA_BELLOTA" "$PKG/debian/preinst" \
   && grep -qs -- '--add "\$RUTA"' "$PKG/debian/preinst"; then
    ok "El preinst registra el desvio del icono de Yaru (--add)"
else
    fallo "El preinst no registra el desvio del icono de Yaru" \
"Sin el, dpkg no puede desempaquetar nuestro fichero en la ruta de Yaru y
la bellota vuelve a depender de icon-theme (MEDICIONES.md 4.70c)."
fi
if grep -qsF "$RUTA_BELLOTA" "$PKG/debian/postrm" \
   && grep -qs -- '--remove "\$RUTA"' "$PKG/debian/postrm"; then
    ok "El postrm retira el desvio (--remove, la mitad simetrica)"
else
    fallo "El postrm no retira el desvio del icono de Yaru" \
"Un desvio huerfano desvia los upgrades de yaru-theme-icon para siempre."
fi

# --- Otras acciones exigidas por AGENTS §4.3 -------------------------------
grep -qs "update-alternatives" "$PKG/debian/postinst" \
    && ok "El postinst registra el tema con update-alternatives" \
    || fallo "El postinst no usa update-alternatives" ""
grep -qs -- "--remove" "$PKG/debian/prerm" \
    && ok "El prerm hace update-alternatives --remove" \
    || fallo "El prerm no desregistra el tema" ""
grep -qs "dconf update" "$PKG/debian/postinst" \
    && ok "El postinst ejecuta dconf update (GDM usa su propia base de datos)" \
    || fallo "El postinst no ejecuta dconf update" ""
grep -qs "GRUB_DISTRIBUTOR" "$PKG/debian/postinst" \
    && ok "El postinst fija GRUB_DISTRIBUTOR" \
    || aviso "El postinst no menciona GRUB_DISTRIBUTOR"
grep -qs "^Format:" "$PKG/debian/copyright" \
    && ok "debian/copyright tiene formato DEP-5" \
    || fallo "debian/copyright no parece DEP-5" "falta la línea 'Format:'"

# --- Maintainer real -------------------------------------------------------
MANTENEDOR=$(grep -m1 "^Maintainer:" "$PKG/debian/control" || echo "")
if echo "$MANTENEDOR" | grep -qiE "ejemplo|example|CORREO|TODO|cambiar"; then
    fallo "El campo Maintainer sigue siendo un marcador de posición" \
"$MANTENEDOR
lintian dará error. Edita debian/control con tu correo real."
else
    ok "Maintainer: ${MANTENEDOR#Maintainer: }"
fi
fi  # fin --saltar-reglas

# ============================================================================
titulo "Construcción"
cd "$PKG" || exit 1
paso "dpkg-buildpackage -us -uc -b"
if BUILD=$(dpkg-buildpackage -us -uc -b 2>&1); then
    ok "El paquete se construye sin error"
else
    fallo "dpkg-buildpackage ha fallado" "$(echo "$BUILD" | tail -30)"
    echo
    echo "Lee la PRIMERA línea de error, no la última: dpkg-buildpackage escupe"
    echo "mucho ruido después del fallo real. Salida completa:"
    echo "$BUILD" | sed 's/^/  | /'
    resumen; exit 1
fi

DEB=$(ls -t "$SALIDA_DIR"/encina-branding_*.deb 2>/dev/null | head -1 || true)
if [[ -z "$DEB" ]]; then
    fallo "No aparece ningún .deb" "buscado en $SALIDA_DIR"
    resumen; exit 1
fi
ok "Generado: $(basename "$DEB")"

# DOS COMPROBACIONES, Y LA PRIMERA ES LA QUE IMPORTA.
#
# EL 2026-08-14 ESTE GUION DIJO
#     [OK] Generado: encina-branding_0.1.7_all.deb
# sobre un arbol cuyo changelog decia 0.1.9. Se invoco sin ENCINA_REPO, y
# raiz_repo() usa ~/encina por defecto: otro clon, de cuatro dias antes. El
# guion construyo ESE, entero y sin una queja. Lo cazo de rebote la lista de
# ficheros esperados -tres [FALLO] de iconos- y solo entonces se miro el
# numero de version.
#
# Y OJO CON EL ARREGLO FACIL, que fue mi primer intento: comparar la version
# del .deb con la del changelog NO SIRVE PARA ESTO. Cuando raiz_repo se
# desvia, se lleva las dos cosas al mismo sitio equivocado y las dos
# coinciden: la comprobacion habria dado verde sobre el fallo que dice cazar.
# Lo que separa los dos casos es OTRA cosa: que el arbol que se construye sea
# el que tienes delante.
#
# ENMIENDA DEL 2026-08-23 (§4.67): LA CAUSA YA ESTA ARREGLADA, y este detector
# se queda. raiz_repo() ya NO se inventa ~/encina: sin ENCINA_REPO devuelve el
# arbol donde vive lib.sh, o muere. O sea que el caso del 2026-08-14 ya no
# puede repetirse por descuido. Lo que este bloque sigue cazando es el caso que
# queda: un ENCINA_REPO puesto A PROPOSITO y apuntando a donde no querias.
if [[ -f "$INVOCADO_EN/debian-packages/encina-branding/debian/changelog" ]] \
   && [[ "$INVOCADO_EN/debian-packages/encina-branding" != "$PKG" ]]; then
    fallo "Se ha construido OTRO arbol, no el que tienes delante" \
"aqui:       $INVOCADO_EN/debian-packages/encina-branding
construido: $PKG
Tienes ENCINA_REPO puesto y apunta a otro arbol. Sin esa variable se
construye el de aqui; para forzar este, lanzalo asi:
    ENCINA_REPO=\"\$PWD\" ./scripts/03-construir.sh"
else
    ok "El arbol construido es el de aqui ($PKG)"
fi
# Y la segunda, barata, contra la trampa de §4.13: 'ls -t | head -1' sobre un
# directorio con varios .deb devuelve el mas nuevo, no el tuyo.
VER_CHANGELOG=$(dpkg-parsechangelog -l "$PKG/debian/changelog" -S Version)
VER_DEB=$(dpkg-deb -f "$DEB" Version)
if [[ "$VER_CHANGELOG" == "$VER_DEB" ]]; then
    ok "La version del .deb es la del changelog ($VER_DEB)"
else
    fallo "El .deb no es el de este changelog" \
"changelog: $VER_CHANGELOG
.deb:      $VER_DEB   ($DEB)"
fi

# ============================================================================
titulo "Contenido del paquete"
CONTENIDO=$(dpkg -c "$DEB")
echo "$CONTENIDO" | awk '{print $6}' | grep -v '/$' | sed 's/^/  /'

if echo "$CONTENIDO" | awk '{print $6}' | grep -qE '^\./(home|root|tmp|var/tmp)/'; then
    fallo "El paquete instala ficheros fuera de /usr y /etc" \
"$(echo "$CONTENIDO" | awk '{print $6}' | grep -E '^\./(home|root|tmp|var/tmp)/')
Revisa override_dh_auto_install en debian/rules."
else
    ok "Todas las rutas cuelgan de /usr y /etc"
fi

# Las dos ultimas son las DOS MITADES de D21 y por eso se comprueban las dos:
# la sombra sin el icono deja un lanzador con un icono roto -su Icon= apunta a
# un nombre que nadie sirve- y el icono sin la sombra no lo pide nadie, que es
# el fallo silencioso de siempre. Ninguna de las dos se nota hasta mirar el
# dock, y para entonces el .deb ya viaja.
for esperado in \
    "usr/share/backgrounds/encina/encina.jpg" \
    "usr/share/backgrounds/encina/encina-dark.jpg" \
    "usr/share/glib-2.0/schemas/99-encina-branding.gschema.override" \
    "usr/share/plymouth/themes/encina/encina.plymouth" \
    "etc/dconf/db/gdm.d/99-encina" \
    "usr/share/icons/Encina/index.theme" \
    "usr/share/icons/Encina/scalable/actions/view-app-grid-ubuntu-symbolic.svg" \
    "usr/share/icons/Encina/scalable/actions/view-app-grid-symbolic.svg" \
    "usr/share/icons/Yaru/scalable/actions/view-app-grid-ubuntu-symbolic.svg" \
    "etc/systemd/user/gnome-initial-setup-first-login.service" \
    "usr/share/applications/snap-store_snap-store.desktop" \
    "usr/share/icons/hicolor/scalable/apps/encina-centro-aplicaciones.svg"
do
    if echo "$CONTENIDO" | grep -q "$esperado"; then
        ok "Incluye $esperado"
    else
        fallo "El paquete NO incluye $esperado" ""
    fi
done

# ============================================================================
titulo "Lintian"
if LINT=$(lintian --fail-on error "$DEB" 2>&1); then
    ok "lintian sin errores"
    [[ -n "$LINT" ]] && { echo "  Avisos (léelos, no los ignores en silencio):"; echo "$LINT" | sed 's/^/    /'; }
else
    fallo "lintian ha encontrado errores" "$LINT"
fi

resumen
RES=$?
echo
echo "Paquete: $DEB"
(( RES == 0 )) && echo "Siguiente:  ./scripts/04-instalar.sh"
exit $RES
