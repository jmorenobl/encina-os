# Encina OS — Instrucciones de implementación para el agente

**Alcance de este documento:** tres paquetes, `encina-branding` (§4),
`encina-firefox-native` (§5) y `encina-meta` (§6, incremento E1, **abierto el
2026-08-08** y con R10 medida antes de escribirlo: `MEDICIONES.md` §4.10). Todo
lo demás —DNIe, locale, imagen ISO, cualquier herramienta de diagnóstico— queda
**fuera de alcance** (§8) y no debe implementarse ni prepararse aún.

**El cuarto paquete del producto, `autofirma 1.9.1+encina1`, no se especifica
aquí:** vive en `~/Projects/encina-autofirma`, con su propio `MEDICIONES.md`. Es
un ingrediente con condición de salida (D14), no una línea de trabajo de este
repositorio.

**D13 no se toca:** ninguna barrera de la firma se cierra desde
`encina-branding`, ni desde `encina-firefox-native`, ni desde `encina-meta`. Se
cerraron todas a la vez y en el sitio correcto —el paquete de AutoFirma—, que es
justo lo que D13 pedía.

**Cómo usar este documento:** las reglas de la sección 2 son invariantes. Si una
tarea parece exigir violar una de ellas, **detente y pregunta** en lugar de
buscar un atajo. Cada paquete tiene una «Definición de terminado» verificable:
no declares una tarea completa sin ejecutar esas comprobaciones.

---

## 1. Contexto mínimo

Encina OS es una distribución de escritorio basada en Ubuntu LTS. **No es un
fork.** Se construyen `.deb`; **se entrega Ubuntu LTS con esos `.deb` aplicados**
(D3, reescrita el 2026-08-08). La base no se remasteriza: se hereda de Ubuntu la
capa de actualizaciones y aplicaciones, que es la razón entera de no partir de
cero.

**El alcance de hoy es pequeño a propósito:** un Encina OS arm64 que funcione en
las VMs del autor, y a partir de ahí incrementos que dejen un sistema usable cada
uno (D15). amd64 es un límite de alcance declarado, no deuda (D9).

Objetivo de los paquetes de este documento: identidad visual propia, Firefox
instalado de forma nativa (no Snap) y en español, y **un solo nombre de Encina**
que declare el conjunto. Un nombre, no una sola orden: medido el 2026-08-08, la
instalación son tres órdenes documentadas y el motivo es R10 (`AGENTS.md` §6.3,
`MEDICIONES.md` §4.10).

El motivo técnico del Firefox nativo, para que se entienda la prioridad: los
navegadores instalados vía Snap o Flatpak aíslan el almacén de certificados NSS
mediante sandbox, lo que impide el funcionamiento de la firma electrónica
española.

**Ese último párrafo tenía razón en la conclusión y se equivocaba en el
mecanismo. Medido el 2026-08-07** (`MEDICIONES.md` §4.3 y §4.4): el almacén NSS
del Snap **no** es el problema —AutoFirma le instala la CA correcta, con la
huella del socket vivo, y `openssl verify` la valida—. Lo que el confinamiento
rompe es que **Firefox dentro del Snap no ve `afirma.desktop` ni
`/usr/bin/autofirma`**: su `XDG_DATA_DIRS` solo tiene rutas del snap, así que al
resolver el manejador del esquema `afirma:` no encuentra nada y **no hace nada**,
sin error y sin log.

Eso **sí** hace de A2 una condición necesaria, y ahora medida: es un obstáculo
que **ningún `.deb` puede tocar** —no se añaden ficheros al `XDG_DATA_DIRS` de un
snap desde fuera— y que el Firefox nativo elimina de raíz.

**Corrección medida el 2026-08-07.** Este documento decía «elimina por adelantado
el obstáculo principal de fases futuras». Es falso, y se comprobó instalando el
`.deb` oficial de AutoFirma 1.9 en la VM: no lo elimina, **lo desplaza**.
AutoFirma no reconoce el perfil del Firefox nativo (`~/.config/mozilla/firefox/`)
ni lee `/etc/firefox/pref/`, así que sobre un sistema con Firefox nativo falla
*más* que sobre una Ubuntu de fábrica. Salidas literales en `MEDICIONES.md` §4.1.

**Y esa corrección tiene a su vez una corrección, del 2026-08-08.** «Falla más
que en una Ubuntu de fábrica» era cierto **con el `.deb` oficial de AutoFirma**.
Encina OS ya no instala ese `.deb`: instala `autofirma 1.9.1+encina1`, que cierra
B1a, B1b, B2, B4 y B6. Sobre Firefox nativo, y con ese paquete, **la firma sale**
—medido con certificado real de la FNMT en `valide.redsara.es`, mirado en
pantalla (`MEDICIONES.md` §4.9)—. A2 deja de ser «necesaria para fases futuras» y
pasa a ser **una de las dos piezas del producto de hoy**.

No cambia nada de lo que hay que implementar aquí: corregir AutoFirma es trabajo
de `~/Projects/encina-autofirma`, no de este repositorio (§8).

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

`encina-meta` es la excepción y lo es por definición: **no tiene `src/`**, y por
tanto tampoco el `override_dh_auto_install` de aquí abajo. Un metapaquete con
contenido son dos paquetes mal separados (§6.1).

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
- **Arquitectura:** `all` en los tres paquetes. No hay binarios compilados.
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

**Y tampoco hace que AutoFirma funcione. Léelo antes de añadir aquí una
preferencia de Firefox (D13).**

Esto no llegará como «voy a implementar AutoFirma» —eso ya lo para §7—. Llegará
como «añado una preferencia a `encina-firefox-native`», que suena a A2 y no
dispara ninguna alarma. Es la tentación concreta, y está medida en
`MEDICIONES.md` §4.1:

- **Barrera 1.** Firefox de Mozilla no lee `/etc/firefox/pref/`, donde AutoFirma
  deja `Autofirma.js`, así que el esquema `afirma:` no existe para él y AutoFirma
  no llega a arrancar. **Esto sí cabría aquí**: un `policies.json` o un fichero de
  preferencias en `/usr/lib/firefox/distribution/` lo cierra, es declarativo, es
  del sistema y no toca `/etc/skel`. Pasaría lintian. Media hora.
- **Barrera 2.** El socket de AutoFirma es TLS (`CN=127.0.0.1` emitido por
  `CN=Autofirma ROOT`) y el Firefox nativo no tiene esa CA. **Esto no cabe aquí de
  ninguna manera**: la CA la genera el `postinst` de AutoFirma, es distinta en cada
  máquina y en cada reinstalación, y vive en el perfil del usuario. Escribirla
  desde un `.deb` es exactamente el patrón que R1 prohíbe.

**Cerrar solo la 1 es peor que no cerrar ninguna.** Hoy el usuario ve un diálogo
—desorientador, pero un síntoma—. Si se cierra la 1, AutoFirma arrancará, abrirá
su socket, el navegador rechazará el certificado, y el usuario se quedará sin
firmar **y sin el aviso**. Se cambia un fallo con síntoma por uno sin él, que en
un proyecto cuyo producto es el diagnóstico es un retroceso.

Si una tarea pide añadir aquí cualquier cosa relacionada con `afirma:`,
certificados, NSS o el socket local: **detente y remite a D13.**

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

## 6. Paquete `encina-meta` (incremento E1)

Incremento abierto el 2026-08-08. Es el siguiente y el más pequeño del proyecto
a propósito: desbloquea la entrega, porque un instalador desatendido instala
**un nombre**, no tres.

**Sustituye a la especificación de `encina-doctor`, suprimida el 2026-08-08.**
El motivo está en `ENCINA-OS.md` §6.1: `encina doctor` existía para explicar por
qué el `.deb` oficial de AutoFirma rompía el sistema en silencio, y Encina OS ya
no instala ese `.deb`. La especificación completa que se descarta sigue en el
historial de git. Las mediciones que se hicieron para escribirla **no se
pierden**: están en `MEDICIONES.md` §4.2 y §4.9.

### 6.1 Qué hace y qué NO hace

**Hace una sola cosa:** declarar dependencias. `Architecture: all`, **sin un solo
fichero propio** fuera de `debian/`.

**No hace:**

- **No lleva configuración.** Ni `gschema.override`, ni dconf, ni ficheros en
  `/etc`. Si algo hay que configurar, se configura en el paquete al que
  pertenece. Un metapaquete con contenido es dos paquetes mal separados.
- **No lleva `postinst` con lógica.** Si hace falta uno, es señal de que una
  dependencia está mal declarada.
- **No cierra ninguna barrera de la firma (D13).** La tentación aquí es distinta
  a la de los otros paquetes y llegará como «ya que `encina-meta` lo instala
  todo, que deje también el `policies.json`». La respuesta es D13.

### 6.2 Contenido

```
Package: encina-meta
Architecture: all
Depends: encina-branding,
         encina-firefox-native,
         autofirma,
         hunspell-es,
         language-pack-es,
         language-pack-gnome-es
Recommends: hyphen-es, mythes-es
```

**El bloque de l10n es el residuo de D12**, y su motivo está medido en
`MEDICIONES.md` §A3: Ubuntu cubre el idioma del sistema, pero **las
aplicaciones instaladas después no reciben su l10n española** —no hay hook de
apt ni disparador de dpkg que reejecute `check-language-support`—. Verificado
con `apt-get -s install libreoffice-writer`, que no arrastra
`libreoffice-l10n-es`.

**`libreoffice-l10n-es` se cayó del `Recommends:` el 2026-08-08, medido en la
VM** (`MEDICIONES.md` §4.11). Lo que este párrafo decía —«va en `Recommends:` y
no en `Depends:` porque depende de `libreoffice-common`: en `Depends:` obligaría
a instalar LibreOffice entero»— **era falso en la práctica y en las dos mitades**:
no depende de `libreoffice-common` sino que lo **recomienda** (`Recommends:
libreoffice-core`), y un `Recommends:` se instala por defecto, así que ponerlo
ahí no evitaba nada. Medido: metió 33 paquetes y 244 MB —`libreoffice-core`
incluido— en una máquina sin LibreOffice, y con ellos abrió un **hueco de l10n
nuevo**, porque la regla `tr::libreoffice-common:libreoffice-help-` de
`pkg_depends` pide entonces `libreoffice-help-es`. La línea vuelve en E4, cuando
se decida si Encina OS trae LibreOffice de serie, y entonces con
`libreoffice-help-es` al lado. `hyphen-es` y `mythes-es` se quedan: los dos
declaran solo `Depends: dictionaries-common` y no arrastran nada.

**Dos avisos medidos el 2026-08-08** (`MEDICIONES.md` §4.10), antes de copiar ese
bloque tal cual:

- **`thunderbird-locale-es` arrastra un Snap.** Es él mismo un paquete de
  transición (`2:1snap1-0ubuntu3`) que depende de `thunderbird`, y ese lleva
  `Pre-Depends: debconf, snapd`. En un producto cuyo motivo es no depender del
  Snap, esa línea necesita **una decisión explícita**, no copiarse. ~~`libreoffice-l10n-es`
  está limpio (`Depends: locales | locales-all`).~~ **Esa última frase es falsa y
  se corrige el 2026-08-08:** miró solo el `Depends:` y se dejó el `Recommends:
  libreoffice-core`, que es justo el que instala. Familia de la misma trampa que
  esta viñeta acierta en el paquete de al lado.
- **El resto del bloque no viola R10 por vía transitiva.** Simulado con el
  repositorio de Mozilla configurado —que es donde algo de allí podría colarse—,
  los 117 paquetes que arrastran el bloque de l10n y las `Depends:` de
  `autofirma` salen todos de Ubuntu, y el control positivo demuestra que la
  comprobación sabe detectar lo contrario.

### 6.3 Las tres trampas de este paquete

**1. R10, y es la que podía pararlo. Medida el 2026-08-08: no lo para.**
`encina-firefox-native` **configura** el repositorio de Mozilla. `encina-meta` no
puede depender —ni directa ni transitivamente— de ningún paquete que solo exista
en ese repositorio.

En particular: **`encina-meta` NO declara `Depends: firefox`**. Lo que sigue está
medido en `MEDICIONES.md` §4.10, con sus controles, y **corrige el motivo que
esta sección venía dando**.

*Por qué no hace falta declararlo.* No es que «el Firefox nativo llegue porque el
repositorio está puesto»: es que **el nombre `firefox` ya está instalado** en
toda Ubuntu de escritorio —deb de transición al Snap, `Recommends:` de
`ubuntu-desktop-minimal`— y el anclaje de prioridad reasigna ese nombre al deb de
Mozilla en el siguiente `apt full-upgrade`. Nadie instala Firefox: **se sustituye
el que ya hay**. Con control negativo: quitando solo el anclaje, apt no propone
ningún cambio y la máquina se queda en el Snap.

*Por qué declararlo sería peor que inútil.* `Depends: firefox` **no es
irresoluble**, que es lo que esta sección afirmaba sin medirlo. Es resoluble por
el paquete equivocado y en silencio: en un escritorio de fábrica lo satisface el
deb de transición ya instalado —apt sale con 0 sin instalar nada y la máquina
sigue en el Snap—, y en una base sin Firefox apt lo resuelve contra el índice de
Ubuntu e **instala `snapd` y el Snap**. El repositorio de Mozilla no está en los
índices *cuando apt resuelve*: sus ficheros se desempaquetan en esa misma
transacción, cuando la decisión ya está tomada.

*Y por qué partir el paquete no arreglaría nada.* El criterio de parada de E1
(`ENCINA-OS.md` §10) prescribía partir `encina-firefox-native` si hacía falta
declarar Firefox. Medido: partirlo **no compra nada**, porque lo que impide
declararlo no es de quién sea el paquete, sino que el índice no esté presente al
resolver. Un paquete aparte tendría el mismo problema en la misma transacción.
Solo funciona como **segundo paso**, con un `apt update` en medio, que es la
secuencia que §5.4 ya documenta sin paquete nuevo.

*Lo que esto sí deja abierto, y es el hueco real de E1:* **el idioma**.
`firefox-l10n-es-es` existe solo en el repositorio de Mozilla (`Candidate:
(none)` en Ubuntu, y `firefox-locale-es` de Ubuntu es otro transitorio al Snap).
Declararlo falla en duro; no declararlo tampoco lo trae, porque el `full-upgrade`
no lo arrastra. Con el contenido de §6.2 tal cual, **Firefox nativo llega en
inglés**. Se cierra en la secuencia de instalación (§6.4) o en el seed de E2, no
con un `Depends:`.

**2. `autofirma` no está en ningún repositorio.** Hoy es un `.deb` que se
construye en `~/Projects/encina-autofirma`. Un `Depends: autofirma` es
insatisfacible hasta que exista el repo local de E2. Es correcto declararlo
—describe la verdad del producto— pero **la instalación de E1 se prueba con el
`.deb` puesto a mano al lado**, y eso hay que decirlo en la definición de
terminado en vez de descubrirlo.

**3. `Depends:` sin versión.** No fijar versiones mínimas de los paquetes de
Encina mientras los tres se construyan juntos: un `>=` obliga a subir la versión
del metapaquete cada vez que cambia cualquiera de los otros, y no compra nada
que la CI no dé ya.

### 6.4 Definición de terminado

Ejecutar en VM, sobre una Ubuntu 24.04 arm64 limpia clonada de
`encina-limpia-respaldo`.

**La secuencia de instalación, escrita antes de empezar y no descubierta.** Son
tres órdenes y no una, y las tres están medidas (`MEDICIONES.md` §4.10). No es un
apaño: es la consecuencia directa de R10, la misma que §5.4 ya documenta para
`encina-firefox-native`.

```
# 1. los cuatro .deb, con el de autofirma puesto al lado (trampa 2 de §6.3)
sudo apt install ./encina-meta_*.deb ./encina-branding_*.deb \
                 ./encina-firefox-native_*.deb ./autofirma_*.deb
# 2. hasta aqui el repositorio de Mozilla existe pero apt no lo ha leido
sudo apt update
# 3. el cambio de Snap a nativo, y el idioma, que ningun Depends: puede declarar
sudo apt full-upgrade          # el paso 3 NO lo hace 'apt upgrade'
sudo apt install firefox-l10n-es-es
```

**Un solo `apt install` no basta, y eso no lo arregla ningún contenido de este
paquete.** Es lo que hay que corregir de la promesa de E1 (`ENCINA-OS.md` §7):
declarar `firefox` no lo arreglaría, lo estropearía en silencio (§6.3).

**Ejecutada el 2026-08-08 sobre la VM `encina-E1-meta`**, clon de
`encina-limpia-respaldo` hecho ese día con `utmctl clone`. Huella tomada antes de
tocarla, porque las seis VMs comparten hostname e IP: cero paquetes `encina-*`,
sin `autofirma`, solo `ubuntu.sources` en `sources.list.d`, sin ningún perfil de
Mozilla, `firefox` deb `1:1snap1-0ubuntu5`, Snap de Firefox `147.0.3-1` rev 7764,
Ubuntu 24.04.4 arm64, un solo usuario. Coincide con la premisa (a) de
`MEDICIONES.md` §4.10.

Los tres scripts dieron **14 + 26 + 8 = 48 comprobaciones correctas, 0 fallos y
2 avisos**. Los dos avisos fueron las dos únicas casillas que no salieron a la
primera: el hueco de l10n —**corregido el mismo día en la versión 0.1.1**, y por
eso su casilla está marcada— y la de `autoremove`, que no depende del paquete
sino de cómo entraron los otros tres.

Casillas, cada una con lo que daría en un sistema sano y en uno roto:

- [x] **`lintian` no dice ni una línea.** No es «sin errores»: medido el
      2026-08-08 con lintian 2.117 sobre el paquete construido, no produce
      **ninguna** etiqueta, ni siquiera con `--display-info --pedantic`. Esta
      sección esperaba avisos de metapaquete vacío y no los hay, así que **no
      existe fichero de overrides y no debe crearse uno preventivo**. Si algún
      día aparece una etiqueta, es nueva: se mira antes de escribir nada, y si
      hay que anularla, con el motivo redactado.
      **Confirmado el 2026-08-08 sobre `encina-meta_0.1.0_all.deb` (2966 bytes):
      `[OK] lintian no dice nada`.** Sigue sin haber fichero de overrides
- [x] El paquete **no instala ni un fichero** fuera de `/usr/share/doc/`.
      `dpkg -L encina-meta` lo demuestra.
      **Comprobado dos veces y por dos vías**, sobre el `.deb` (`dpkg-deb -c`) y
      sobre lo instalado (`dpkg -L`). El contenido entero son tres entradas:
      `./usr/share/doc/encina-meta/`, `changelog.gz` y `copyright`
- [x] `apt install ./encina-meta_*.deb` con los otros tres `.deb` al lado
      instala los cuatro y sale con código 0.
      **Los cuatro quedan `install ok installed`.** El de `autofirma` es
      `autofirma_1.9.1+encina1_all.deb`, bajado del artefacto `autofirma-arm64`
      de la ejecución 31232027825 de su CI
      (`sha256 4aa647220eb62cc5b73a257760b44950663c2151f3efc063d81f14ffa92fff3e`)
- [x] **El paso 1 no ha instalado ni tocado Firefox.** `LC_ALL=C apt-cache policy
      firefox` sigue diciendo `Installed: 1:1snap1-0ubuntu5`. *Sano:* esa versión
      con epoch, intacta. *Roto:* si apareciera una versión de Mozilla ya aquí,
      alguien ha declarado `firefox` y hay que volver a §6.3; si desapareciera el
      paquete, se ha desinstalado algo que no tocaba.
      **Medido: sigue en `1:1snap1-0ubuntu5`, idéntico al de antes de la
      transacción, y el Snap tampoco se ha movido (147.0.3-1 rev 7764, R4)**
- [x] **Tras el paso 2, el anclaje manda.** `LC_ALL=C apt-cache policy firefox`
      da `Candidate: 153.0.3~build1` con prioridad `1000` y origen
      `packages.mozilla.org`. *Roto:* `Candidate: 1:1snap1-0ubuntu5`, o sea que
      el anclaje no está haciendo efecto y el paso 3 devolvería el Snap.
      **Medido, exactamente eso:**

      ```
       *** 1:1snap1-0ubuntu5 500
              500 http://ports.ubuntu.com/ubuntu-ports noble/main arm64 Packages
           153.0.3~build1 1000
             1000 https://packages.mozilla.org/apt mozilla/main arm64 Packages
      ```

- [x] **Tras el paso 3, Firefox es el nativo.** `dpkg-query -W -f='${Version}'
      firefox` **no empieza por `1:`**, y `readlink -f /usr/bin/firefox` no cae
      bajo `/snap/`. *Roto:* versión con epoch = sigue siendo el deb de
      transición, y todo lo demás de esta lista puede estar verde igualmente.
      **Medido: `153.0.3~build1` (sin epoch) y `/usr/bin/firefox →
      /usr/lib/firefox/firefox`.** El plan, mirado antes de aplicarlo, decía
      `Inst firefox [1:1snap1-0ubuntu5] (153.0.3~build1 …/repositories/mozilla…)`.
      **Y esto es lo que convierte en MEDIDO lo único que §4.10 dejaba
      deducido:** el `full-upgrade` se comporta en una VM con escritorio, con el
      Snap vivo, igual que en el contenedor. `firefox-l10n-es-es 153.0.3~build1`
      instalado y desplegado en
      `/usr/lib/firefox/distribution/extensions/langpack-es-ES@firefox.mozilla.org.xpi`
- [x] Tras instalar: `check-language-support -l es` sigue saliendo vacío.
      **Con la versión 0.1.0 NO SE CUMPLIÓ. Salida literal:**

      ```
      $ LC_ALL=C check-language-support -l es
      libreoffice-help-es
      ```

      **La causa se midió y era este paquete.** `Recommends:
      libreoffice-l10n-es` arrastró `libreoffice-common` y `libreoffice-core`
      —33 paquetes y 244 MB, en el log de apt del paso 1 y todos marcados
      `automatic`— y la regla 13 de
      `/usr/share/language-selector/data/pkg_depends`, `tr::libreoffice-common:libreoffice-help-`,
      dice que con `libreoffice-common` instalado hace falta
      `libreoffice-help-<lang>`. O sea que **la l10n que este paquete declaraba
      abría un hueco de l10n nuevo.** En §A3 la misma orden salía vacía porque
      allí no había ningún LibreOffice.
      **Corregido el mismo día en `encina-meta 0.1.1`**, quitando la causa en vez
      de tapándola: la línea se cae del `Recommends:` y vuelve en E4 con
      `libreoffice-help-es` al lado (§6.2, `MEDICIONES.md` §4.11c). Verificado
      tras el `autoremove` de los 37 paquetes huérfanos, **y con control, que es
      lo que hace que el vacío signifique algo**:

      ```
      $ LC_ALL=C check-language-support -l es
                                      # vacio
      $ LC_ALL=C check-language-support -l fr
      gnome-user-docs-fr hunspell-fr language-pack-fr language-pack-gnome-fr wfrench
      ```

      *Sano:* vacío. *Roto:* enumera lo que falta — y sabe hacerlo, como
      demuestra el francés.
      **Y confirmado desde cero**, que es distinto: en el banco se llegó
      *quitando*. Sobre `encina-firma-efimera`, virgen y con línea base tomada
      —sin `libreoffice-common` ni `libreoffice-core`—, la secuencia entera con
      0.1.1 **no los trae**, y `11-meta-instalar.sh` da allí **27 correctas, 0
      fallos y 0 avisos**
- [x] **Idempotencia (R9):** cinco instalaciones seguidas dejan el sistema
      idéntico.
      **Medido comparando la lista completa de paquetes con su versión antes y
      después, no el código de salida; y con control, alterando una línea de la
      huella para comprobar que el `diff` sabe verlo**
- [ ] `apt purge encina-meta` **no** desinstala los otros tres —es lo correcto
      para un metapaquete— y `apt autoremove` sí los propone. Comprobar las dos
      cosas y dejar la salida escrita.
      **La primera mitad, medida y correcta:** tras `apt purge encina-meta`, los
      tres siguen `install ok installed`.
      **La segunda mitad no se puede demostrar tal cual en esta VM, y el motivo
      importa para E2:** los tres entraron *por ruta* en la línea de órdenes del
      paso 1, así que apt los marcó como **manuales** y `autoremove` no propone
      ninguno. Medido con A/B, que es como sí se responde la pregunta:

      ```
      A) apt-mark auto los tres, con encina-meta INSTALADO
         -> autoremove no propone ninguno          (control: sabe decir que no)
      B) los mismos tres, con encina-meta PURGADO
         -> Remv autofirma / Remv encina-branding / Remv encina-firefox-native
      ```

      La casilla se cumple **cuando los tres entran como dependencias
      automáticas**, que es lo que hará el repo local de E2. Con `.deb` sueltos
      al lado, no. Las marcas se devolvieron a manual y `encina-meta` quedó
      reinstalado
- [x] Una entrada de matriz nueva en `build.yml`, verde.
      **Verde el 2026-08-08**, ejecución `31252036419` sobre `ed86a45`, con las
      tres entradas de la matriz en `success`. La de `encina-meta` da las mismas
      **14 correctas, 0 fallos, 0 avisos** que en la VM, `encina-meta_0.1.1_all.deb`
      de 3402 bytes, y —lo que importaba— **`lintian 2.117.0ubuntu1.5` en el
      runner tampoco dice nada**, igual que el de la VM. La entrada entró en el
      mismo commit que el `changelog`, porque sin él `10-meta-construir.sh` se
      detiene y la CI habría salido roja a sabiendas.
      *Aviso, no fallo:* GitHub anota que `actions/checkout@v4` y
      `actions/upload-artifact@v4` van sobre Node 20, ya obsoleto, y los fuerza a
      Node 24. Afecta a todo el workflow, no a este paquete
- [x] **[OJOS] Firefox arranca en español.** No lo puede comprobar ningún script,
      y **que salga en español no demuestra por sí solo que sea el nativo**: el
      Snap también está en español. Primero el binario (casilla anterior),
      después el idioma.
      **Mirada por Jorge el 2026-08-08 en `encina-E1-meta`, en `about:support`, y
      en ese orden.** Tres campos independientes descartan el Snap antes de
      mirar el idioma: `Binario de la aplicación = /usr/lib/firefox/firefox-bin`
      (esta lista y §5.5 dicen `/usr/lib/firefox/firefox`; `firefox-bin` es el
      ejecutable real al que apunta ese nombre, mismo sitio), `ID de
      distribución = mozilla-deb` —no `canonical-*`— y `Directorio de perfil =
      /home/jorge/.config/mozilla/firefox/…`, la ubicación XDG del deb de
      Mozilla y no `~/.mozilla/` ni `~/snap/firefox/`. Solo después, la interfaz
      en español. Versión 153.0.3, compilación 20260803132010.
      **De propina, D13 vista y no deducida:** `Políticas empresariales:
      Inactivo`, o sea que no hay ningún `policies.json` puesto por nadie.
      *No perseguir:* el `Agente de usuario` dice `x86_64` en una máquina arm64;
      Firefox congela ese campo en Linux a propósito y no significa nada aquí.
      Miradas también en la misma sesión, y correctas, el fondo en claro y en
      oscuro (`encina-branding` 0.1.7 sobre una máquina donde nunca había estado)
- [ ] **[OJOS] La casilla que decide:** sobre esa máquina, con la secuencia de
      arriba ejecutada **tal cual y sin ningún arreglo fuera de ella**, sale una
      firma en `valide.redsara.es` con certificado real. Mirada en pantalla.
      **Es un experimento de un solo uso:** se hace sobre una VM clonada para
      la ocasión y **esa VM se destruye después**, porque lleva dentro un
      certificado de firma personal (`ENCINA-OS.md` §9.1). Todo lo demás de
      esta lista se comprueba sin él

**La última casilla es la única que importa de verdad**, y es la única que
ningún script puede dar por buena. Las otras pueden salir todas verdes con el
producto sin funcionar: ya pasó en A2, donde con siete comprobaciones
automáticas en verde el icono seguía abriendo el Snap.

**La sede tiene que ser `valide.redsara.es`.** `sededgsfp.gob.es` **no puede dar
un positivo** en Firefox de escritorio: su propia Content-Security-Policy bloquea
el iframe que el JavaScript de AutoFirma necesita. Está medido en
`MEDICIONES.md` §4.9b, y tres pruebas de firma de este proyecto se hicieron allí
sin saberlo.

---

## 6bis. La entrega (incrementos E2 y E3)

Sin abrir. Se especifica cuando E1 esté terminado. Lo que ya está decidido y no
hay que volver a discutir:

- **Repo local sin firmar**, generado en la propia construcción con
  `dpkg-scanpackages` y consumido con `[trusted=yes]`. Ejercita el mecanismo
  real —repo más metapaquete en el seed— sin gestión de claves. **La receta que
  se escriba así es la definitiva** (`ENCINA-OS.md` §8).
- **El Snap de Firefox se quita en la receta de imagen, no desde un paquete**
  (R4, D11). Ahí sí está permitido, y cierra dos barreras de golpe: B3, que
  **ningún `.deb` puede tocar**, y B4, que se cierra sola al desaparecer el
  perfil del Snap (medido con control en `encina-autofirma/MEDICIONES.md` M6).
- **Antes de escribir el seed de verdad, la pregunta de A3:** ¿qué comando
  demuestra que esto es viable? Un `autoinstall.yaml` mínimo que instale
  desatendido y ejecute una `late-command` en la ISO oficial de Ubuntu Desktop
  24.04 arm64. Media tarde, y decide la forma de E2 entera.

---

## 7. Integración continua

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

## 8. Fuera de alcance — no implementar

- **Tocar la firma electrónica desde un paquete de Encina**: ficheros de
  preferencias de Firefox, `policies.json`, certificados instalados por un
  paquete. **D13, y cubre a los tres paquetes de este documento.** Cualquiera de
  ellos podría cerrar una barrera suelta y pasaría `lintian`; cerrarla sola deja
  el sistema sin firmar y **sin el aviso que hoy da**. Lo que hay que corregir de
  AutoFirma se corrige en `~/Projects/encina-autofirma`, que es su sitio
- **`encina-doctor` y cualquier herramienta de diagnóstico. Suprimido el
  2026-08-08** tras especificarlo entero y no escribir una línea. El motivo, en
  `ENCINA-OS.md` §6.1: existía para explicar por qué el `.deb` oficial rompía el
  sistema en silencio, y Encina OS ya no instala ese `.deb`. **Si esta tarea
  reaparece en un encargo, no la implementes:** lo que sobrevive es la
  verificación de la construcción en CI, y su código ya existe
  (`verificar-deb.sh`)
- Certificados FNMT, DNIe, `opensc`, PKCS#11 como funcionalidad
- Paquete `encina-locale-es`. **Suprimido definitivamente el 2026-08-07 (D12).**
  No es «todavía no»: es que no existe nada que empaquetar.
  `check-language-support -l es` devuelve vacío en una Ubuntu 24.04 instalada en
  español, y lo que devolvería lo instala el propio instalador ejecutando ese
  mismo comando. Lo poco que Ubuntu no cubre —la l10n de aplicaciones instaladas
  después del sistema— son tres `Depends:` de `encina-meta`, no un paquete.
  Además, tocar `/etc/default/keyboard`, `/etc/locale.gen` o `/etc/default/locale`
  violaría R5: no son conffiles de nadie, los genera debconf. Salidas literales
  en `MEDICIONES.md` §A3. **Si esta tarea reaparece en un encargo, no la
  implementes: remite a D12.**
- `encina-keyring`, repositorio APT **firmado**, `aptly`. El repo **local sin
  firmar** de E2 sí está en alcance cuando se abra E2, y puede que el firmado no
  haga falta nunca (`ENCINA-OS.md` §8)
- Modificación de `/etc/os-release` (requiere `dpkg-divert`; paquete separado futuro)
- Construcción de imagen: `live-build`, `debos`, Cubic. **El `autoinstall.yaml`
  de E2 y el reempaquetado de la ISO oficial de E3 no son esto**, pero tampoco
  están abiertos todavía
- amd64 (D9). Se construye en CI porque el runner es amd64, pero **no se declara
  probado**: no hay máquina donde medirlo
- Temas de GTK o de iconos, incluidos los de estética macOS
- Cualquier interfaz gráfica

Si una tarea parece requerir algo de esta lista, **detente y pregunta**.

---

## 9. Ante la duda

- Si un nombre de paquete, ruta o clave de dconf no se puede verificar con un
  comando, **no lo inventes**: indícalo y pregunta.
- Si una comprobación de la «Definición de terminado» falla, no la marques como
  hecha ni la reformules: reporta el fallo con la salida literal del comando.
- Preferir la solución declarativa aunque sea más larga. Un `sed` en un
  `postinst` es aceptable solo donde el fichero pertenece a otro paquete (R5).
- **Antes de escribir una comprobación, responde a las dos preguntas: ¿qué
  salida daría en un sistema sano y qué salida en uno roto?** Si no sabes las
  dos, no la escribas: mídela primero y anótala en `MEDICIONES.md`. Vale para
  `scripts/`, para la CI y para la receta de imagen. Las siete trampas de
  `SCRIPTS.md` son siete formas de que esto salga caro, y las siete dan **falsos
  negativos o comprobaciones que no comprueban**.
- **No existe ninguna máquina donde la firma funcione, y no va a existir.** La
  VM del primer positivo se destruyó a propósito porque contenía un certificado
  personal de la FNMT (`ENCINA-OS.md` §9.1). El positivo está medido y
  registrado; lo que no hay es un estado bueno contra el que contrastar. **No
  escribas nunca una comprobación cuya validación sea «ejecútala en la máquina
  buena».** Lo que sí puedes hacer: verificar todo menos la firma final con un
  **certificado de prueba** —es lo que hizo M6 con `CERT-PRUEBA-ENCINA`— y dejar
  la firma real como experimento manual de un solo uso, en una VM que se
  destruye después.
- **`git` a través del hook de `rtk` devuelve commits que no son.** Se le pide un
  hash y contesta otro, con su asunto, sin fallar ni avisar. Cualquier medición
  sobre git va con `/usr/bin/git` o con `rtk proxy` (`MEDICIONES.md` §4.9d).
