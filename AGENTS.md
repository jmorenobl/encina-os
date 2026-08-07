# Encina OS — Instrucciones de implementación para el agente

**Alcance de este documento:** únicamente dos paquetes, `encina-branding` y
`encina-firefox-native`. Todo lo demás (AutoFirma, DNIe, locale, imagen ISO)
queda **fuera de alcance** y no debe implementarse ni preparse aún.

**Cómo usar este documento:** las reglas de la sección 2 son invariantes. Si una
tarea parece exigir violar una de ellas, **detente y pregunta** en lugar de
buscar un atajo. Cada paquete tiene una «Definición de terminado» verificable:
no declares una tarea completa sin ejecutar esas comprobaciones.

---

## 1. Contexto mínimo

Encina OS es un conjunto de paquetes `.deb` sobre Ubuntu LTS. **No es un fork.**
El producto es la paquetería; la imagen ISO es un envase opcional posterior.

Objetivo de estos dos paquetes: identidad visual propia y Firefox instalado de
forma nativa (no Snap) y en español.

El motivo técnico de lo segundo, para que se entienda la prioridad: los
navegadores instalados vía Snap o Flatpak aíslan el almacén de certificados NSS
mediante sandbox, lo que impide el funcionamiento de la firma electrónica
española. Resolver esto ahora elimina por adelantado el obstáculo principal de
fases futuras.

---

## 2. Reglas duras (invariantes)

| # | Regla |
|---|---|
| R1 | **Nada de `/etc/skel`.** Toda configuración por defecto se aplica con `gschema.override` o perfiles de dconf. `/etc/skel` solo afecta a usuarios creados después y no se puede actualizar. |
| R2 | **No llamar a `glib-compile-schemas`** desde ningún script. `libglib2.0-0` tiene un disparador de dpkg sobre `/usr/share/glib-2.0/schemas` que lo hace automáticamente. |
| R3 | **No llamar a `apt`, `apt-get`, `dpkg` ni `snap` desde un script de mantenedor** (`preinst`, `postinst`, `prerm`, `postrm`). dpkg mantiene el bloqueo y provocaría un interbloqueo. |
| R4 | **No eliminar el Snap de Firefox desde el paquete.** Es una acción destructiva (marcadores, sesiones del usuario). La eliminación pertenece a la receta de imagen, no a la paquetería. |
| R5 | **No sobrescribir ficheros de configuración propiedad de otros paquetes.** `/etc/default/grub` se edita in situ con `sed`; `/etc/os-release` requiere `dpkg-divert` y está fuera de alcance. |
| R6 | **El tema de Plymouth debe basarse en `spinner`, nunca en `bgrt`.** `bgrt` muestra el logotipo del firmware del fabricante, por lo que el logotipo propio no aparecería nunca. |
| R7 | **Tras instalar un tema de Plymouth hay que ejecutar `update-initramfs -u`.** El tema se copia dentro del initramfs; sin regenerarlo no se observa ningún cambio y el fallo es silencioso. |
| R8 | **No incluir activos de terceros.** Ni logotipos de Canonical/Ubuntu, ni tipografía San Francisco de Apple, ni iconos que imiten macOS. Solo activos propios o con licencia libre explícita, declarada en `debian/copyright`. |
| R9 | **Idempotencia.** Instalar, reinstalar y actualizar cualquier paquete cinco veces seguidas debe dejar el sistema en estado idéntico. |
| R10 | **Sin dependencias circulares de repositorio.** Un paquete que configura un repositorio de terceros no puede declarar `Depends:` sobre paquetes de ese mismo repositorio. |

---

## 3. Convenciones

- **Identificador técnico:** `encina` (minúsculas, sin acentos).
- **Nombre visible:** `Encina OS`.
- **Prefijo de paquetes:** `encina-<función>`.
- **Estructura de cada paquete:**

```
debian-packages/encina-<x>/
├── debian/
│   ├── changelog        # gestionar con dch, nunca a mano
│   ├── control
│   ├── copyright        # formato DEP-5
│   ├── rules
│   └── postinst, prerm, postrm   (solo si son necesarios)
└── src/                 # árbol que se copia tal cual a la raíz del sistema
```

- `debian/rules` usa `debhelper-compat (= 13)` y el patrón:

```make
#!/usr/bin/make -f
%:
	dh $@

override_dh_auto_install:
	cp -a src/. debian/encina-<x>/
```

- **Versionado:** semántico, `MAJOR.MINOR.PATCH`. Actualizar el changelog con
  `dch -v <versión>`. La suite del changelog es el codename de Ubuntu destino.
- **Arquitectura:** `all` en ambos paquetes. No hay binarios compilados.
- **Lintian es una puerta de calidad:** `lintian` sin errores es requisito.
  Los avisos deben justificarse o corregirse, no ignorarse en silencio.

---

## 4. Paquete `encina-branding`

### 4.1 Contenido

| Ruta | Propósito |
|---|---|
| `usr/share/backgrounds/encina/encina.jpg` | Fondo claro |
| `usr/share/backgrounds/encina/encina-dark.jpg` | Fondo oscuro |
| `usr/share/backgrounds/encina/logo.png` | Logotipo, PNG con transparencia (origen) |
| `usr/share/plymouth/themes/encina/logo.png` | **Copia obligatoria del logotipo dentro del tema.** `debian/rules` la instala |
| `usr/share/gnome-background-properties/encina.xml` | Hace que el fondo aparezca en Ajustes → Apariencia |
| `usr/share/glib-2.0/schemas/99-encina-branding.gschema.override` | Predeterminados de fondo y salvapantallas |
| `usr/share/icons/hicolor/scalable/apps/encina-logo.svg` | Logotipo del sistema |
| `usr/share/plymouth/themes/encina/encina.plymouth` | Definición del tema |
| `usr/share/plymouth/themes/encina/encina.script` | Script del tema |
| `etc/dconf/db/gdm.d/99-encina` | Logotipo y mensaje en la pantalla de inicio de sesión |
| `etc/dconf/profile/gdm` | Perfil que hace que GDM lea la base de datos anterior. Sin él, en Debian/Ubuntu no se lee nunca |

### 4.2 Requisitos concretos

**Fondos claro y oscuro.** Desde GNOME 42 existen `picture-uri` y
`picture-uri-dark`. Deben definirse ambos; si falta el oscuro, el usuario en modo
oscuro verá el fondo claro.

**El `gschema.override` debe duplicar cada sección con el sufijo `:ubuntu`.**
GSettings admite overrides por escritorio: una sección `[esquema:escritorio]`
solo se aplica cuando `XDG_CURRENT_DESKTOP` contiene ese nombre, y **tiene
prioridad sobre la genérica sea cual sea el número del fichero**. Ubuntu define
`[org.gnome.desktop.background:ubuntu]` en `10_ubuntu-settings.gschema.override`
y la sesión corre con `XDG_CURRENT_DESKTOP=ubuntu:GNOME`, así que un `99-`
genérico **no le gana**: no compiten en la misma categoría.

El fallo es traicionero porque `gsettings get` desde una terminal no tiene esa
variable y devuelve el valor propio, dando la falsa impresión de que funciona.
La comprobación válida es:

```
XDG_CURRENT_DESKTOP=ubuntu:GNOME gsettings get org.gnome.desktop.background picture-uri
```

Lo mismo aplica a `org.gnome.desktop.screensaver`.

**GDM usa su propia base de datos de dconf**, no `gschema.override`. Por eso el
perfil va en `/etc/dconf/db/gdm.d/` y el `postinst` debe ejecutar `dconf update`.

**En Debian y Ubuntu eso no basta.** El perfil que instala `gdm3` vive en
`/usr/share/dconf/profile/gdm` y **no incluye `system-db:gdm`**:

```
user-db:user
file-db:/var/lib/gdm3/greeter-dconf-defaults
```

Sin `system-db:gdm`, el fichero de `gdm.d/` se compila y no se lee jamás, y el
fallo es silencioso: la pantalla de GDM sigue con el logotipo de Ubuntu, que
`10_ubuntu-settings.gschema.override` fija por defecto. La solución es instalar
`/etc/dconf/profile/gdm` desde el propio paquete (dconf busca antes en `/etc`
que en `/usr/share`, así que no se sobrescribe nada ajeno y R5 se respeta),
conservando el `file-db:` de Debian para no perder sus valores por defecto.

Comprobación sin reiniciar GDM:

```
DCONF_PROFILE=gdm dconf read /org/gnome/login-screen/logo
```

**El campo `logo` de GDM sí acepta una ruta absoluta.** (En `os-release`, en
cambio, `LOGO` espera un *nombre de icono*; irrelevante aquí porque `os-release`
está fuera de alcance.)

**Las imágenes del tema de Plymouth deben estar dentro del directorio del
tema.** `Image("logo.png")` se resuelve contra el `ImageDir` declarado en el
`.plymouth`, y sobre todo: **el hook de initramfs copia únicamente el
directorio del tema**, así que una ruta absoluta a `/usr/share/backgrounds/`
tampoco sirve — ese fichero no existe dentro del initramfs. Si falta, el splash
pinta el fondo pero no el logotipo, **sin dar ningún error**. Comprobación:

```
lsinitramfs /boot/initrd.img-$(uname -r) | grep encina
```

Deben aparecer el `.plymouth`, el `.script` **y el `logo.png`**.

**El script de Plymouth debe implementar el callback de contraseña.** Sin él, en
equipos con disco cifrado (LUKS) el arranque se queda en negro sin solicitar la
frase de paso. Es un fallo que solo se manifiesta en máquinas cifradas:

```
fun display_password_callback(prompt, bullets) { ... }
Plymouth.SetDisplayPasswordFunction(display_password_callback);
```

### 4.3 `postinst` — acciones requeridas, en este orden

1. `update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth <ruta>.plymouth 200`
2. `update-initramfs -u` (ver R7), condicionado a que el binario exista
3. `dconf update`, condicionado a que el binario exista
4. `GRUB_DISTRIBUTOR="Encina OS"` en `/etc/default/grub` mediante `sed`
   (sustituir si la línea existe, añadir si no), seguido de `update-grub || true`

`prerm` debe hacer `update-alternatives --remove`. `postrm` debe regenerar
initramfs y dconf. Todas las invocaciones externas con guarda `|| true` donde un
fallo no deba abortar la desinstalación.

### 4.4 Definición de terminado

Ejecutar en una VM Ubuntu **virgen**:

- [ ] `dpkg-buildpackage -us -uc -b` termina sin error
- [ ] `lintian ../encina-branding_*.deb` sin errores
- [ ] `sudo apt install ./encina-branding_*.deb` sin error
- [ ] `update-alternatives --display default.plymouth` muestra el tema `encina` como activo
- [ ] Tras reiniciar: logotipo propio en el arranque
- [ ] Logotipo y mensaje propios en la pantalla de GDM
- [ ] Fondo propio en el escritorio
- [ ] **Crear un usuario nuevo después de instalar** (`sudo useradd -m -s /bin/bash prueba`), iniciar sesión con él, y comprobar que hereda el fondo. Si no lo hereda, el override no funciona (probable violación de R1 o R2)
- [ ] Reinstalar cinco veces: sin cambios de estado ni errores (R9)
- [ ] `sudo apt purge encina-branding` restaura el tema de arranque original

---

## 5. Paquete `encina-firefox-native`

### 5.1 Qué hace y qué NO hace

**Hace:** configurar el repositorio APT oficial de Mozilla, su clave y el
anclaje de prioridad (*pinning*), **y hacer que el Firefox que se abre al hacer
clic sea el nativo y no el Snap.**

**No hace:** instalar Firefox, ni instalar el paquete de idioma, ni eliminar el
Snap. Ver R3, R4 y R10.

**Por qué se añadió lo segundo.** La redacción original dejaba el problema del
Snap a la receta de imagen (R4), y para una máquina instalada desde una imagen
de Encina es correcto: allí el Snap no existe nunca. Pero **D3 dice que el
producto es la paquetería, no la ISO**, y quien instala el `.deb` sobre su
Ubuntu ya tiene el Snap y no va a ejecutar ninguna receta de imagen. Para esa
persona —el caso de uso principal— «corresponde a la receta de imagen»
significa «nunca».

El síntoma es que instalar el repositorio, Firefox nativo y el idioma deja el
sistema perfecto y el usuario sigue abriendo el Snap, porque Ubuntu tiene
anclado al dock `firefox_firefox.desktop`. Y no se nota: el Snap también está
en español. Solo lo delata `about:support`, con `Binario de la aplicación` bajo
`/snap/firefox/`.

**Esto no relaja R4.** R4 prohíbe *eliminar* el Snap por destructivo, y aquí no
se elimina nada: el Snap sigue instalado, con su perfil intacto, y arranca con
`snap run firefox`. Lo que se cambia es qué abre el icono. Desinstalarlo desde
el paquete sería además imposible por R3: dpkg mantiene el bloqueo mientras
corre un script de mantenedor, así que `snap remove` desde el `postinst` es un
interbloqueo.

**Queda sin resolver, y es deliberado:** los marcadores y sesiones del usuario
viven en `~/snap/firefox/common/.mozilla/firefox/` y el Firefox nativo usa
`~/.config/mozilla/firefox/`, así que **no los verá**. Migrar el perfil es un
problema aparte, no es configurar un repositorio APT, y no se aborda en A2.

Ojo con la ruta del nativo: **no es `~/.mozilla/firefox/`**, que es lo que uno
supone y no existe. El `.deb` de Mozilla usa la ubicación XDG. Verificado en
`about:support` → `Directorio de perfil`.

El motivo de R10 aquí es concreto: los paquetes `firefox` y
`firefox-l10n-es-es` viven en el repositorio de Mozilla, que no existe en el
sistema hasta que **este** paquete se instala. Declararlos como `Depends:`
produciría una dependencia irresoluble. La instalación de Firefox pertenece al
metapaquete `encina-meta` o a la receta de imagen, en un paso posterior.

### 5.2 Contenido

**Clave de firma:** `usr/share/keyrings/packages.mozilla.org.asc`

Descargada de `https://packages.mozilla.org/apt/repo-signing-key.gpg` y
**verificada** contra la huella:

```
35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3
```

Si la huella no coincide, **detenerse y avisar**. No continuar.

**Definición del repositorio**, formato deb822 (nunca `apt-key`, obsoleto):
`etc/apt/sources.list.d/mozilla.sources`

```
Types: deb
URIs: https://packages.mozilla.org/apt
Suites: mozilla
Components: main
Signed-By: /usr/share/keyrings/packages.mozilla.org.asc
```

**Anclaje de prioridad:** `etc/apt/preferences.d/encina-mozilla`

```
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
```

Sin el anclaje, apt reinstalará el Snap de Ubuntu en la primera actualización.
Es la causa de fallo más habitual de este paquete.

Cuidado con `Pin: origin`: casa con el **nombre de máquina** del repositorio, no
con el campo `Origin:` del fichero `Release`, que aquí vale
`namespaces/moz-fx-productdelivery-pr-38b5/repositories/mozilla`. Para casar con
ese campo habría que escribir `Pin: release o=...`. Confundirlos deja el anclaje
sin efecto, y el fallo es silencioso.

**Sombra del lanzador del Snap:** `usr/share/applications/firefox_firefox.desktop`

Mismo identificador que el lanzador del Snap, en un directorio que va **antes**
en `XDG_DATA_DIRS` de la sesión (`/usr/share/` precede a
`/var/lib/snapd/desktop`), de modo que lo sustituye sin tocarlo. Es el mismo
mecanismo que `encina-branding` usa para `/etc/dconf/profile/gdm`: no se
sobrescribe ningún fichero ajeno y R5 se respeta.

Debe llevar `TryExec=/usr/bin/firefox`, porque este paquete **no** instala
Firefox (R10): entre instalar el paquete e instalar Firefox el binario no
existe, y sin `TryExec` el icono abriría la nada. Y `NoDisplay=true`, para que
no aparezcan dos «Firefox» idénticos en el buscador.

**Predeterminados del escritorio:**
`usr/share/glib-2.0/schemas/99-encina-firefox-native.gschema.override`

Cambia `favorite-apps` para anclar `firefox.desktop` en lugar de
`firefox_firefox.desktop`. **Debe duplicar la sección con el sufijo `:ubuntu`**,
por el mismo motivo explicado en §4.2: Ubuntu define `favorite-apps` en
`[org.gnome.shell]` y en `[org.gnome.shell:ubuntu]`, con listas distintas entre
sí, y la de `:ubuntu` gana sea cual sea el número del fichero. La comprobación
válida es:

```
XDG_CURRENT_DESKTOP=ubuntu:GNOME gsettings get org.gnome.shell favorite-apps
```

Sin la variable, `gsettings` devuelve la sección genérica y da la falsa
impresión de que funciona.

### 5.3 Verificación del nombre del paquete de idioma

El paquete de idioma español de España es, previsiblemente,
`firefox-l10n-es-es`. **Confírmalo** antes de referenciarlo en cualquier sitio:

```
sudo apt update
apt-cache search firefox-l10n | grep -i 'es-es\|spanish'
```

Si el nombre difiere, usar el real y anotarlo en el README.

### 5.4 Documentar el orden de instalación

Este paquete no es autosuficiente por diseño. El README debe indicar la
secuencia:

```
sudo apt install ./encina-firefox-native_*.deb
sudo apt update
sudo apt install firefox firefox-l10n-es-es
```

### 5.5 Definición de terminado

- [ ] `lintian` sin errores
- [ ] Tras instalar y `apt update`, `apt policy firefox` muestra el candidato con
      origen `packages.mozilla.org` y prioridad 1000
- [ ] `apt install firefox firefox-l10n-es-es` funciona
- [ ] Firefox arranca **en español** (si arranca en inglés, falta el paquete de idioma)
- [ ] `snap list | grep firefox` no devuelve nada, o si lo devuelve, se documenta
      que la eliminación corresponde a la receta de imagen (R4)
- [ ] **`sudo apt full-upgrade` ejecutado dos veces no reintroduce el Snap ni
      degrada Firefox a la versión de Ubuntu.** Es la comprobación crítica del anclaje.
      Si esas dos vueltas no mueven ningún paquete, la prueba no ha probado nada:
      hay que forzar una vuelta con `-o APT::Get::Always-Include-Phased-Updates=true`
- [ ] `apt purge` deja el sistema con la configuración de repositorios original
- [ ] `XDG_CURRENT_DESKTOP=ubuntu:GNOME gsettings get org.gnome.shell favorite-apps`
      contiene `firefox.desktop` y **no** `firefox_firefox.desktop`. Sin la variable
      la comprobación no vale (§4.2)
- [ ] **Tras reiniciar la sesión, el icono del dock abre Firefox nativo.** En
      `about:support`, `Binario de la aplicación` debe ser `/usr/lib/firefox/firefox`
      y el `ID de distribución` no debe ser `canonical-*`. Que la interfaz salga en
      español **no demuestra nada por sí solo**: el Snap también está en español, así
      que primero se confirma el binario y después el idioma

---

## 6. Integración continua

Crear `.github/workflows/build.yml`:

- Disparadores: `push`, `pull_request`
- Runner: `ubuntu-latest` (amd64)
- Matriz por paquete
- Pasos: instalar `build-essential devscripts debhelper lintian` →
  `dpkg-buildpackage -us -uc -b` → `lintian` → subir los `.deb` como artefactos
- **`build-essential` es obligatorio y fácil de olvidar.** Es dependencia de
  construcción implícita de todo paquete Debian, así que `dpkg-checkbuilddeps`
  aborta sin él con `Unmet build dependencies: build-essential:native`. En una
  VM de desarrollo suele estar ya instalado porque `devscripts` lo recomienda,
  de modo que el fallo **solo aparece en el runner**
- **La firma del repositorio APT no se hace en CI en esta fase.** La clave de
  firma de Encina no debe existir en el runner. La publicación del repositorio
  está fuera de alcance por ahora.

---

## 7. Fuera de alcance — no implementar

- AutoFirma, certificados FNMT, DNIe, `opensc`, PKCS#11, NSS
- Paquete `encina-locale-es`. **Suprimido definitivamente el 2026-08-07 (D12).**
  No es «todavía no»: es que no existe nada que empaquetar.
  `check-language-support -l es` devuelve vacío en una Ubuntu 24.04 instalada en
  español, y lo que devolvería lo instala el propio instalador ejecutando ese
  mismo comando. Lo poco que Ubuntu no cubre —la l10n de aplicaciones instaladas
  después del sistema— son tres `Depends:` de `encina-meta`, no un paquete.
  Además, tocar `/etc/default/keyboard`, `/etc/locale.gen` o `/etc/default/locale`
  violaría R5: no son conffiles de nadie, los genera debconf. Salidas literales
  en `ENCINA-OS.md` §6.1. **Si esta tarea reaparece en un encargo, no la
  implementes: remite a D12.**
- `encina-keyring`, `encina-meta`, repositorio APT propio, `aptly`
- Modificación de `/etc/os-release` (requiere `dpkg-divert`; paquete separado futuro)
- Construcción de imagen ISO, `live-build`, `debos`, Cubic
- Temas de GTK o de iconos, incluidos los de estética macOS
- Cualquier interfaz gráfica

Si una tarea parece requerir algo de esta lista, **detente y pregunta**.

---

## 8. Ante la duda

- Si un nombre de paquete, ruta o clave de dconf no se puede verificar con un
  comando, **no lo inventes**: indícalo y pregunta.
- Si una comprobación de la «Definición de terminado» falla, no la marques como
  hecha ni la reformules: reporta el fallo con la salida literal del comando.
- Preferir la solución declarativa aunque sea más larga. Un `sed` en un
  `postinst` es aceptable solo donde el fichero pertenece a otro paquete (R5).
