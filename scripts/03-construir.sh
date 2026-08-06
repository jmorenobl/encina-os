#!/usr/bin/env bash
# 03-construir.sh — Comprueba las reglas duras, construye el .deb y pasa lintian.
#
# Uso:  ./scripts/03-construir.sh [--saltar-reglas]
#
# Las comprobaciones de reglas son estáticas (grep sobre los ficheros): tardan
# un segundo y detectan justo los fallos que en caliente son invisibles y que
# solo se manifiestan al reiniciar, o solo en máquinas con LUKS.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
requiere_no_root
requiere_cmd dpkg-buildpackage lintian

PKG="$(PKG_DIR)"
SALIDA_DIR="$(raiz_repo)/debian-packages"
[[ -d "$PKG/debian" ]] || { echo "No existe $PKG/debian. Ejecuta antes ./scripts/01-repo.sh"; exit 1; }

MANT=("$PKG/debian/postinst" "$PKG/debian/prerm" "$PKG/debian/postrm")
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
    # Se ignoran los comentarios y se exige palabra completa.
    linea=$(grep -nE '^[^#]*(\bapt\b|\bapt-get\b|\bdpkg\b|\bsnap\b)' "$m" 2>/dev/null || true)
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

for esperado in \
    "usr/share/backgrounds/encina/encina.jpg" \
    "usr/share/backgrounds/encina/encina-dark.jpg" \
    "usr/share/glib-2.0/schemas/99-encina-branding.gschema.override" \
    "usr/share/plymouth/themes/encina/encina.plymouth" \
    "etc/dconf/db/gdm.d/99-encina"
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
