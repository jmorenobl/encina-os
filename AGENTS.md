# Encina OS — Instrucciones de implementación para el agente

**Alcance de este documento:** tres paquetes —`encina-branding` (§4),
`encina-firefox-native` (§5) y `encina-meta` (§6, incremento E1, **abierto el
2026-08-08** y con R10 medida antes de escribirlo: `MEDICIONES.md` §4.10)— y la
entrega: **E2 en §6bis** (terminado 6 de 6 el 2026-08-10) y **E3 en §6ter**
(**abierto el 2026-08-10**, con sus dos mediciones de apertura en §4.21). Todo lo
demás —DNIe, locale, `live-build`/`debos`/Cubic, cualquier herramienta de
diagnóstico— queda **fuera de alcance** (`ENCINA-OS.md` §8) y no debe
implementarse ni prepararse aún.

**Ojo con esta línea, que estuvo desfasada:** decía «imagen ISO» entre lo fuera
de alcance, y desde que E2 se abrió eso ya no era verdad. **Reempaquetar la ISO
oficial es E3 y está abierto**; lo que sigue fuera es **rehacerla**, que es E5.

**El cuarto paquete del producto, `autofirma 1.9.1+encina2`, no se especifica
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
Encina OS ya no instala ese `.deb`: instala `autofirma 1.9.1+encina2` —era
`+encina1` cuando se midió lo que sigue—, que cierra B1a, B1b, B2, B4 y B6.
Sobre Firefox nativo, y con ese paquete, **la firma sale** —medido con
certificado real de la FNMT en `valide.redsara.es`, mirado en
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

**Ojo con `NoDisplay`, que se quitó y se volvió a poner, y las dos veces por un
motivo.** La 0.2.0 lo retiró porque con él, instalar el paquete en una sesión ya
abierta hacía desaparecer el icono del dock, y se aceptó el duplicado a cambio.
La 0.2.1 lo repuso porque ese trato dejó de valer al pasar el producto a ser la
imagen (D3) y dejar la imagen de tener Snap: entonces el duplicado no lo ve solo
quien actualiza su Ubuntu, lo ve **todo** usuario, siempre. **Lo que decide está
medido en los dos mundos** (`MEDICIONES.md` §4.19), y son tres hechos:

| Estado de la sombra | Con Snap (`encina-E1-meta`) | Sin Snap (`encina-E2-completa`) |
|---|---|---|
| como estaba (0.2.0) | 2 iconos, id → `/usr/bin/firefox %u` | 2 iconos, id → `/usr/bin/firefox %u` |
| **`NoDisplay=true`** | **1 icono**, id → `/usr/bin/firefox %u` | **1 icono**, id → `/usr/bin/firefox %u` |
| sin el fichero | 2 iconos, id → **`/snap/bin/firefox %u`** | 1 icono, id → `NINGUNA` |
| `Hidden=true` | 1 icono, id → `NINGUNA` | — |

- **`NoDisplay` oculta pero NO desactiva.** Con él puesto el identificador sigue
  resolviendo a `/usr/bin/firefox %u`, así que el dock de Ubuntu de fábrica, que
  tiene anclado ese identificador, sigue abriendo el nativo. A2 no se toca.
- **Borrar el fichero reabre A2 entero** en la máquina con Snap.
- **`Hidden=true` no sirve:** significa «borrado», no «oculto», y deja el icono
  anclado muerto.

Lo que sigue costando, y va dicho en el propio fichero: en la **primera**
instalación sobre una sesión gráfica abierta cuyo dock tenga anclado el
identificador del Snap, GNOME Shell puede dejar de pintar ese icono hasta el
siguiente inicio de sesión. Medido que **no** reescribe `favorite-apps` en el
dconf del usuario, así que no es permanente; si desaparece de la pantalla o no,
es `[OJOS]`.

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
- [ ] **El usuario ve UN SOLO icono de Firefox, y se cuenta en las dos máquinas:
      una con Snap y otra sin él.** Esta casilla es nueva desde la 0.2.1 y existe
      porque **ninguna de las doce anteriores la hacía**: todas preguntaban *a qué
      resuelve* el identificador y ninguna *cuántos iconos hay*, que es por lo que
      el duplicado vivió sin que nadie lo viera desde A2 hasta `MEDICIONES.md`
      §4.17h. Es la familia de A2 en estado puro: siete comprobaciones en verde y
      la pantalla haciendo otra cosa.
      No se cuenta mirando ficheros ni con `ls`, se le pregunta a la misma
      biblioteca que dibuja la rejilla:

      ```
      XDG_DATA_DIRS=$(xdg_data_dirs_sesion) XDG_CURRENT_DESKTOP=ubuntu:GNOME python3 -c '
      import gi; gi.require_version("Gio","2.0")
      from gi.repository import Gio
      t=Gio.AppInfo.get_all(); v=[a for a in t if a.should_show()]
      print(sum(1 for a in v if "firefox" in a.get_id().lower()), "de", len(v), "visibles")'
      ```

      *Sano:* `1`. *Roto:* `2` — el de Mozilla y la sombra, los dos llamados
      «Firefox» y los dos abriendo `/usr/bin/firefox`, que es lo que se veía
      hasta la 0.2.0. **El segundo número es el control**: si el total de
      visibles saliera 0, un `1` no significaría nada. Y no vale hacerla solo sin
      Snap: el duplicado ya existía **con** Snap (§4.17h), así que se cuenta en
      las dos o no se marca
- [ ] **Con `NoDisplay` puesto, el identificador del Snap SIGUE resolviendo al
      nativo.** *Sano:* `resolver_desktop firefox_firefox.desktop` →
      `/usr/bin/firefox %u` y `should_show()` → `False`. *Roto:* `NINGUNA`, que
      es lo que dan `Hidden=true` o quitar el fichero, y deja muerto el icono
      anclado del dock de fábrica; o `/snap/bin/firefox %u`, que es A2 reabierto.
      Las dos preguntas son distintas y se hacen por separado: «oculta» y
      «desactivada» no son lo mismo, y confundirlas es lo que costó la 0.2.0

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

**Y E4 la reclama: el 2026-08-11 se decidió que la ofimática entra en el básico**
(`ENCINA-OS.md` §6 y §7), porque la máquina de la entrega **no tiene con qué abrir
un `.odt`, un `.doc`, un `.docx`, un `.xls` ni un `.csv`** — `xdg-mime` devuelve
`<NINGUNO>` en los cinco (`MEDICIONES.md` §4.26c). **Lo que falta es solo el
alcance**, y su precio está medido: `libreoffice-writer` solo son **46 paquetes**
nuevos, y `writer + calc + libreoffice-l10n-es + libreoffice-help-es` son **54**
(§4.26d). **El paquete de ayuda no es opcional**: sin él se abre el hueco de l10n
que este mismo párrafo documenta.

**LA MINA ERA REAL, ESTABA DONDE DECÍA, Y NO SE PISÓ** (2026-08-12,
`MEDICIONES.md` §4.31g). `imagen/encina-seed.sh` lleva `--allow-downgrades` en el
`full-upgrade` desde esta vuelta, y el registro de la instalación enseña la
palabra que la delata:

```
The following packages will be DOWNGRADED:  firefox
dpkg: warning: downgrading firefox from 1:1snap1-0ubuntu5 to 153.0.4~build1
```

**Y el reparto se invirtió tal como se predijo:** el paso 11 (`full-upgrade`)
vuelve a ser **el** paso y el 12 vuelve a ser **solo el idioma** (`1 newly
installed`). El bloque 11bis del seed —la red de seguridad para el caso sin
red— **no hizo nada y lo dijo**. *Lo que sigue debajo es la mina tal como se
escribió el 2026-08-11, y se conserva porque explica por qué el argumento está
ahí:*

**UNA MINA QUE ESPERA EN LA VUELTA DE E4, y cuesta la vuelta entera si se pisa**
(escrita el 2026-08-11, deducida de dos mediciones que ya existen). Con D16 el
seed **deja de purgar `snapd`** —la forma (c) exige que esté—, y eso devuelve el
`.deb` de transición `firefox 1:1snap1-…` a la máquina durante la instalación.
Entonces el reparto de §4.17 se invierte otra vez: **el paso que sustituye el
navegador vuelve a ser el `full-upgrade`**, y el paso 4 vuelve a ser solo el
idioma. **Y ahí está la mina:** ese cambio es un *downgrade* formal por el epoch
`1:`, así que con `-y` **hace falta `--allow-downgrades`** (§4.10c, medido, y está
en la lista de trampas). El `full-upgrade` de `imagen/encina-seed.sh` **no lleva
ese flag** —y hoy no lo necesita, porque después de purgar no hay nada que
degradar—. Sin él, el paso **no falla ruidosamente**: deja la máquina con el deb
de transición, o sea abriendo el Snap, o sea **el estado (d), el que no firma**.
Con el veredicto de §4.27 dentro, al menos saldría `INCOMPLETO` con
`firefox-de-transicion`, pero la vuelta ya estaría gastada.

**Tres avisos más para el día que se toque este bloque**, todos medidos el
2026-08-11 sobre `encina-E2-2vias` con `apt-get -s` y con sus controles:

- **`thunderbird-locale-es` sigue metiendo `snapd`**, o sea que el aviso de §4.10h
  ya no es una cita sino una medición de hoy. Con D16 eso deja de ser un veto,
  pero **tiene que ir declarado**, no colarse por vía transitiva.
- **`gnome-software` también arrastra `snapd`**, y **no existe
  `gnome-software-plugin-deb`** en los índices de 24.04: solo `-plugin-snap` y
  `-plugin-flatpak`. Las alternativas sin Snap son `gnome-packagekit` y
  `synaptic`, tres paquetes cada una. **DESDE EL 2026-08-13 ESTE AVISO ES
  HISTÓRICO: `gnome-software` YA NO SE DECLARA** (D18 reescrita, §4.34). La tienda
  es el `snap-store` pre-sembrado del medio, que **cuesta 0 paquetes** y **no se
  puede declarar en un `Depends:` porque no es un `.deb`**; lo que se declara es
  `snapd`. El aviso se conserva porque **la medición sigue siendo cierta** y
  volvería a decidir si alguna vez se replantea la tienda.
- **`simple-scan` es un solo paquete** y `sane-utils` ya está instalado sin que
  nada lo use. **Y `sane-airscan` NO viaja con él** —leído el 2026-08-12: sus
  `Depends` piden `libsane1` y no tiene `Recommends`— **pero ya está en
  `ubuntu-desktop-minimal`**, así que declararlo cuesta **0 paquetes**. Sin él no
  se ve ningún escáner de red moderno, que son *driverless* (eSCL/WSD).

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

**En una máquina SIN Snap el paso 4 no es «el idioma»: es el navegador entero.**
Medido el 2026-08-10 (`MEDICIONES.md` §4.17) sobre una máquina de la que se había
purgado `snapd`, que se lleva con él el `.deb` `firefox` de transición:

| Paso | Máquina CON Snap (E1) | Máquina SIN Snap (E2) |
|---|---|---|
| 3 · `apt full-upgrade` | **sustituye** el deb de transición por el de Mozilla | **no hace nada** para Firefox — 84 paquetes propuestos y ni uno es él |
| 4 · `apt install firefox-l10n-es-es` | añade el idioma | **instala Firefox entero** y el idioma, por `Depends: firefox (= 153.0.3~build1)` |

Las tres órdenes **no cambian**, y el anclaje funciona igual con el nombre libre
(`Candidate: 153.0.3~build1` a prioridad 1000 frente al `1:1snap1-0ubuntu5` a
500). Lo que cambia es que **quitar el paso 4 deja la máquina sin ningún
Firefox**, y el síntoma no aparece hasta que alguien va a firmar.

**Hubo un cuarto paso entre el 2026-08-08 y el 2026-08-09, y se ha caído porque
lo arreglaron donde tocaba.** Era «abre Firefox una vez y `sudo dpkg-reconfigure
autofirma`», y lo obligaba un defecto real (`MEDICIONES.md` §4.12a): el
configurador de AutoFirma corre en el paso 1, cuando **Firefox nativo todavía no
existe** —llega en el paso 3—, así que no hay ningún perfil de Mozilla donde
instalar la CA de su socket, y sin ella el navegador rechaza la conexión y la
sede dice «No es posible conectar con Autofirma». Aquí se escribió como lo que
era, un apaño, y el arreglo bueno se dijo en voz alta: un disparador en
`encina-autofirma`.

**Eso es exactamente lo que se hizo allí.** `autofirma 1.9.1+encina2` trae dos
unidades de systemd de usuario que instalan la CA **cuando el perfil aparece**,
sin que el usuario teclee nada. Medido en aquel repositorio (M14–M18 de su
`MEDICIONES.md`), y lo que cierra el asunto es M18: sobre un clon virgen de
`encina-limpia-respaldo`, con esta secuencia de tres órdenes ejecutada tal cual y
**sin ejecutar `dpkg-reconfigure` ni una vez**, la CA acabó dentro del perfil.
Con el mismo par de fechas que enunció el defecto, ya unido: la CA se genera a
las `00:13:10` (paso 1) y entra en el perfil a las `00:16:12`, dos segundos
después de que Firefox creara su almacén NSS.

**Lo que no se ha cambiado es el aviso.** El `postinst` sigue diciendo que no ha
encontrado perfil y sigue dando la orden manual, para las máquinas donde el
mecanismo no pueda actuar. No se ha sustituido un fallo visible por uno
silencioso.

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
      **Los cuatro quedan `install ok installed`.** El de `autofirma` era, el día
      de esta medición, `autofirma_1.9.1+encina1_all.deb`, bajado del artefacto
      `autofirma-arm64` de la ejecución 31232027825 de su CI
      (`sha256 4aa647220eb62cc5b73a257760b44950663c2151f3efc063d81f14ffa92fff3e`).
      **El paquete de hoy es `1.9.1+encina2`**, y con él se repitió la secuencia
      entera el 2026-08-09 sobre otro clon virgen (M18 de `encina-autofirma`)
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
- [x] `apt purge encina-meta` **no** desinstala los otros tres —es lo correcto
      para un metapaquete— y `apt autoremove` sí los propone. Comprobar las dos
      cosas y dejar la salida escrita.
      **CUMPLIDA EL 2026-08-10, en E2 y con el mecanismo de verdad**
      (`MEDICIONES.md` §4.15): repo local **sin firmar** generado con
      `dpkg-scanpackages` y consumido con `[trusted=yes]`, sobre una máquina
      instalada por seed. `apt install encina-meta` a secas mete los cuatro, y
      entonces las marcas salen solas —`showauto`: los tres; `showmanual`:
      `encina-meta`—, que es lo único que faltaba:

      ```
      CONTROL (encina-meta instalado):  autoremove no propone ninguno
      purge encina-meta              :  los tres siguen install ok installed
      autoremove despues             :  Remv autofirma / Remv encina-branding /
                                        Remv encina-firefox-native
      ```

      **Con esto E1 queda en 12 de 12.** Lo que la cerró no fue tocar este
      paquete: fue cambiar la vía por la que llegan los otros tres.
      *Lo de abajo es el registro del 2026-08-08 y se conserva, porque explica
      por qué esta casilla estuvo abierta y por qué el remedio no estaba aquí.*
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
- [x] **[OJOS] La casilla que decide:** sobre esa máquina, con la secuencia de
      arriba ejecutada **tal cual y sin ningún arreglo fuera de ella**, sale una
      firma en `valide.redsara.es` con certificado real. Mirada en pantalla.
      **MARCADA EL 2026-08-09** sobre `encina-firma-efimera`, clon virgen de
      `encina-limpia-respaldo` con huella tomada antes de tocarla. La secuencia,
      **tres órdenes, sin `dpkg-reconfigure` y sin nada fuera de ella**: 29
      correctas, 0 fallos, 1 aviso —el del `postinst`, que es el que debe
      salir— y 1 omitida. La CA del socket **llegó sola** al abrir Firefox
      (`11:16:59`, dos segundos tras el almacén NSS; misma huella que la del
      paquete, `30:67:39:25…69:C1`), y el `postinst` había corrido **una** sola
      vez. Certificado importado y **firma mirada en pantalla por Jorge**.
      Salidas completas en `MEDICIONES.md` §4.13. La VM se destruyó después
      (§9.1) y se comprobó que no queda ninguna copia del `.p12`.
      **Es un experimento de un solo uso:** se hace sobre una VM clonada para
      la ocasión y **esa VM se destruye después**, porque lleva dentro un
      certificado de firma personal (`ENCINA-OS.md` §9.1). Todo lo demás de
      esta lista se comprueba sin él. **Y por eso esta casilla, una vez marcada,
      no se puede volver a contrastar contra ninguna máquina**: si algún día hay
      que rehacerla, se rehace el experimento entero.
      **El intento del 2026-08-08, que es lo que hizo falta para llegar aquí.**
      Sobre otra VM efímera con el mismo nombre, **la firma salió igual** —mirada
      en pantalla, con certificado real de la FNMT— **y aun así la casilla no se
      marcó**, porque la secuencia no bastó. Detalle con salidas en
      `MEDICIONES.md` §4.12. Hubo dos desviaciones, y **ninguna de las dos existe
      ya**:
      *(1)* **RESUELTA el 2026-08-09, y no aquí.** Era que el paso 1 instalaba
      `autofirma` cuando Firefox nativo aún no existía —llega en el paso 3—, así
      que su configurador no encontraba ningún perfil de Mozilla y **la CA del
      socket no se instalaba en ningún navegador**; la sede respondía «No es
      posible conectar con Autofirma», que apunta al sitio equivocado. Obligaba a
      un cuarto paso manual. `autofirma 1.9.1+encina2` trae el disparador que
      aquí se pedía, y **M18 de `encina-autofirma` mide la secuencia de tres
      órdenes sobre un clon virgen, sin `dpkg-reconfigure` ni una vez, con la CA
      dentro del perfil al abrir Firefox**. La secuencia de arriba vuelve a ser
      de tres pasos. *(El otro cabo de aquella tarde también está cosido:
      `11-meta-instalar.sh` se tragaba el aviso del `postinst` porque apt salía
      con 0, y desde entonces lo imprime.)*
      *(2)* El diálogo de AutoFirma **no se dibujaba** en la VM (medido: 1 solo
      color en la ventana). Eso no es del producto sino del laboratorio, y **su
      causa sí quedó establecida el mismo 2026-08-08**: la tarjeta de vídeo
      emulada. Con `virtio-gpu-pci` pinta sin ninguna variable de entorno
      (`MEDICIONES.md` §4.12b), y las VMs se igualaron.
      Aquella VM se destruyó también, y se comprobó que no quedaba ninguna copia
      del `.p12`.
      **Lo que separa las dos fechas no es una tarde más de VM: es un paquete.**
      El 8 de agosto la firma salía y la secuencia no bastaba; el 9, con
      `autofirma 1.9.1+encina2`, basta. Es la diferencia entre «se puede hacer
      funcionar» y «funciona», que es justo lo que esta casilla mide

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

## 6bis. La entrega — E2, abierto el 2026-08-09

**E3 se abrió el 2026-08-10 y se especifica en §6ter.** Lo que sigue es E2, que
está terminado 6 de 6 y se conserva porque la receta de E2 **es** la que E3
mete dentro de la ISO.

### 6bis.1 Lo decidido, que no se vuelve a discutir

- **Repo local sin firmar**, generado en la propia construcción con
  `dpkg-scanpackages` y consumido con `[trusted=yes]`. **Medido el 2026-08-10 y
  funciona** (`MEDICIONES.md` §4.15): `apt update` traga los `Ign:` de firma,
  `apt install encina-meta` mete los cuatro y los otros tres quedan marcados
  automáticos. **La receta que se escriba así es la definitiva**
  (`ENCINA-OS.md` §8).
- **El Snap de Firefox se quita en la receta de imagen, no desde un paquete**
  (R4, D11). Ahí sí está permitido, y cierra dos barreras de golpe: B3, que
  **ningún `.deb` puede tocar**, y B4, que se cierra sola al desaparecer el
  perfil del Snap (medido con control en `encina-autofirma/MEDICIONES.md` M6).
  **Y desde el 2026-08-10 ya no es una intención: está medido que se puede, y
  por qué vía** (`MEDICIONES.md` §4.16). La orden que lo hace, desde una
  `late-command`, es una sola:

  ```
  curtin in-target -- env DEBIAN_FRONTEND=noninteractive LC_ALL=C apt-get -y purge snapd
  ```

  **La vía obvia —`snap remove`— NO sirve, y lo peligroso es que no falla:**
  dice `firefox eliminado` con `rc=0` porque `curtin` bind-monta el `/run` del
  instalador dentro de `/target`, así que se lo quita **al entorno vivo del
  instalador**, no al objetivo. La prueba, en la misma orden: cliente `2.76` del
  objetivo contra demonio `2.73` del instalador (§4.16e).
- **D13 intacta:** nada de esto se cierra desde `encina-branding` ni desde
  `encina-firefox-native`.

### 6bis.2 Lo medido al abrir, que ya no se pregunta

Todo en `MEDICIONES.md` §4.14, sobre la ISO oficial
`ubuntu-24.04.4-desktop-arm64.iso` (`sha256 c2610520…`, verificada desde el
2026-08-13 contra la **firma** de Canonical y no sólo contra el `SHA256SUMS` de
cdimage, que se baja del mismo sitio que la ISO y por tanto no es un control
independiente — `MEDICIONES.md` §4.39d):

| Pregunta | Respuesta medida |
|---|---|
| ¿Honra la ISO oficial de **escritorio** un `autoinstall` servido en un volumen `CIDATA`? | **Sí.** `autoinstall found in cloud-config`, `file /autoinstall.yaml`, y el seed leído de `/dev/vdb` con sus 976 y 52 bytes exactos |
| ¿Se ejecutan las `late-commands`? | **Sí, las dos formas.** Sobre `/target/` desde el entorno del instalador, y con `curtin in-target`, ésta **como root** y en `aarch64` |
| ¿Instala desatendido tal cual? | **No.** Se para en «Ready to install» y espera un clic. Con `autoinstall` en la línea de órdenes del núcleo, no se para — **y el control lo aísla**: la misma máquina sin esa palabra estuvo 14 min viva sin escribir un byte |
| ¿La base que produce sirve para la secuencia de §6.4? | **Sí.** Trae el `firefox 1:1snap1-0ubuntu5` de transición, que es la premisa (a) de §4.10, y el Snap, que es lo que hay que quitar |

**Y dos avisos que salieron de ahí, para el que escriba el seed:**

- **`/var/log/installer/autoinstall-user-data` no demuestra nada.** El instalador
  lo escribe siempre, también sin seed. Lo que sí distingue una instalación
  contestada a mano de una gobernada por seed es
  `/var/log/installer/telemetry`: trece entradas contra dos. **Pero no detecta el
  clic de confirmación** (§4.14g), así que no sirve para la casilla de «nadie la
  ha tocado».
- **El repositorio local no puede vivir en un `$HOME`**: apt baja a usuario `_apt`
  y un `/home/x` en `drwxr-x---` lo deja mudo, sin error reconocible (§4.15).

**Y lo medido el 2026-08-10, que cierra una pregunta y abre otra** (§4.16):

| Pregunta | Respuesta |
|---|---|
| ¿Hay alguna clave del `autoinstall.yaml` que quite el clic de confirmación? | **No, y no es una suposición: está leído** en el código que viaja dentro de la ISO. La puerta es `if "autoinstall" in self.app.kernel_cmdline` (`install.py:587-597`), y `model.confirm()` solo se llama desde ahí y desde el manejador HTTP que pulsa el botón. Con `interactive-sections` ausente el instalador **ya** es no interactivo y se para igual |
| ¿Cómo hay que escribir esa palabra? | **Suelta.** El analizador (`cmd/server.py:32-52`) mete lo que lleva `=` en otro sitio, e `in` solo mira los testigos sueltos: **`autoinstall=1` NO vale**, ni `subiquity.autoinstallpath=…` |
| ¿Se puede quitar el Snap desde el seed? | **Sí**, con `apt-get purge snapd` por `curtin in-target`. Deja el objetivo sin `/var/lib/snapd`, sin `/snap`, sin lanzador y sin unidades, y **el escritorio sobrevive** (`ubuntu-desktop-minimal` y `gnome-shell` en `ii`, saludador de GDM `Type=wayland Class=greeter State=active`) |
| ¿Por qué sobrevive el escritorio? | Porque `snapd` y `firefox` son **`Recommends`** de `ubuntu-desktop-minimal`, no `Depends`. Medido con `dpkg-query` sobre el paquete instalado |
| ¿Y el `.deb` `firefox` de transición? | **Se va con el purgado**, porque depende de `snapd`. Eso invalida la premisa (a) de §4.10: ya no hay nada que sustituir. **Medido el mismo día (§4.17): la secuencia de §6.4 sigue valiendo, pero el paso 4 pasa a instalar el navegador entero**, no solo el idioma. El anclaje funciona igual con el nombre libre |
| ¿Y el repo local, sobre una máquina sin Snap? | **Igual que en §4.15**: `apt install encina-meta` mete los cuatro y los otros tres quedan en `showauto`, sin tocar ninguna marca (§4.17c) |

### 6bis.3 Definición de terminado de E2

Cada casilla, con lo que daría en un sistema sano y en uno roto. **No marcar
ninguna sin la salida literal.**

- [x] Un `autoinstall.yaml` versionado en este repositorio instala una máquina
      **sin que nadie conteste ni pulse nada, con el parámetro `autoinstall`
      puesto por el hipervisor** (decidido el 2026-08-10, `ENCINA-OS.md` §10).
      *Sano:* `telemetry` con dos entradas (`loading`, `done`). *Roto:* aparecen
      `identity`, `storage` o `confirm`. **Ojo: `telemetry` no detecta el clic**
      (§4.14g), así que la prueba de que nadie pulsó nada es que la máquina se
      apagó sola por `-no-reboot` sin que nadie abriera su ventana.
      **Medido el 2026-08-10 (`MEDICIONES.md` §4.18d y §4.18e):** el seed es
      `imagen/autoinstall.yaml`; `telemetry` da `{"1":"loading","409":"done"}`;
      arrancó a las `14:40:02Z` y estaba apagada a las `14:50:50Z` — **menos de
      10 min 48 s y nadie abrió su ventana**—; y que la palabra llegó no se dice
      leyendo el YAML sino el `debug.log` de QEMU: `-append autoinstall`, suelto
- [x] Ese seed **trae el repo local sin firmar** con los cuatro `.deb` e instala
      `encina-meta`. *Sano:* los cuatro `install ok installed` y los tres
      dependientes en `apt-mark showauto`. *Roto:* alguno en `showmanual`, que
      es lo que pasaba con `.deb` por ruta.
      **Medido (§4.18g):** los cuatro `.deb` viajan **dentro del propio volumen
      del seed** —128 MiB y sigue siendo un fichero—, con las cuatro huellas de
      §4.15 comprobadas tres veces: en el Mac, en el volumen, y ya copiadas
      dentro de `/target`. Los cuatro `install ok installed`, tres en `showauto`
      y `encina-meta` en `showmanual`, **sin tocar ninguna marca**
- [x] ~~**Sin Snap.**~~ **SUSTITUIDA EL 2026-08-12 POR LA CASILLA DE D16, y sale
      MÁS exigente, no más floja** (`MEDICIONES.md` §4.31). Lo de abajo se
      conserva porque es lo que se midió el día que se marcó, y porque explica
      por qué la casilla nueva pregunta lo que pregunta.
      **LA CASILLA VIGENTE, y la cumplen las máquinas CON Snap y sin él:**
      *(a)* el usuario ve **UN SOLO** icono de Firefox; *(b)* ese icono resuelve
      **fuera de `/snap/`** y el paquete no es el de transición (versión **sin**
      epoch `1:`); *(c)* **no existe ningún perfil de Mozilla bajo `~/snap/`**,
      que es lo que separa el estado (c) —Snap instalado y **nunca abierto**— del
      (d), el único que rompe.
      **Por qué se sustituye y no se afloja:** quitar `snapd` nunca fue condición
      de que la firma funcione —la máquina donde salió la firma de §4.13 lo tenía
      dentro—, la tienda que exige «un escritorio que crece» lo arrastra de todas
      formas (§4.26d), y lo que rompe es **un Firefox de Snap que alguien abre**:
      B3, que **no tiene arreglo posible por nuestra parte** (§4.28), y B4 de
      vuelta hasta que el nativo sea otra vez el último abierto (§4.29f). O sea
      que «un solo icono, y abre el nativo» **es la defensa entera**.
      **Y la (c) se comprueba con sus dos controles** (§4.26i): que el buscador
      sepa encontrar algo (`.bashrc` → ≥1) y sepa decir cero.
      *El texto de la casilla vieja, para el registro:* *Sano:* `snap list` no
      menciona `firefox`, y
      `/var/lib/snapd/desktop/applications/firefox_firefox.desktop` no existe.
      *Roto:* cualquiera de las dos cosas presente — y ojo, que el icono puede
      seguir en el dock aunque el paquete se haya ido (es el caso de A2).
      Y no vale `dpkg -l | grep -i snap`: da falsa alarma con `libsnapd-glib`,
      `gir1.2-snapd-2`, `xdg-desktop-portal` y una extensión de GNOME que ordena
      ventanas (§4.16h).
      **LA TERCERA CONDICIÓN ESTABA MAL ESCRITA, Y SE CORRIGE CON SU MOTIVO
      (§4.19d) — no se afloja.** Pedía que `resolver_desktop firefox_firefox.desktop`
      respondiera `NINGUNA`, y se redactó con §4.16i, medido sobre una máquina
      **sin ningún paquete de Encina**, donde `NINGUNA` era correcto porque no
      había ni Snap ni sombra. **Lo que la delata no es que ninguna máquina de
      Encina la cumpliera, sino algo peor, y está medido:** `NINGUNA` solo se
      alcanza quitando la sombra o poniéndole `Hidden`, y quitar la sombra hace
      que en una máquina **con** Snap el identificador vuelva a resolver a
      `/snap/bin/firefox %u`. **Tal como estaba, la casilla exigía un estado que
      solo se consigue reabriendo A2.** Lo que quería preguntar es que **no
      resuelva a nada bajo `/snap/`**, y eso es lo que pregunta ahora.
      **Y se le añade una cuarta condición que no tenía nadie: cuántos iconos de
      Firefox ve el usuario.** Ninguna de las doce casillas lo preguntaba, y por
      eso el duplicado de §4.17h vivió desde A2 sin que nadie lo viera.
      **MARCADA el 2026-08-10 (§4.19g)**, sobre `encina-E2-0.2.1`, máquina nueva
      instalada de una pasada por el seed reconstruido con
      `encina-firefox-native` **0.2.1**: no existe la orden `snap` —control:
      `command -v bash` → `/usr/bin/bash`—, no existe el lanzador, ni
      `/var/lib/snapd`, ni `/snap`, `snapd` está en `un`,
      `firefox_firefox.desktop` → `/usr/bin/firefox %u` (fuera de `/snap/`), con
      su control de que el resolvedor **sabe decir `NINGUNA`** ante un
      identificador que no existe (trampa 11), y **1 icono de Firefox** de 25
      aplicaciones visibles, que es el control de que el inventario no está mudo
- [x] **Firefox es el nativo y está en español**, por la vía de §4.10: versión
      **sin** epoch y `/usr/bin/firefox` fuera de `/snap/`. *Roto:* versión
      `1:…` = sigue siendo el deb de transición.
      **Medido (§4.18i):** `firefox 153.0.3~build1` sin epoch,
      `/usr/bin/firefox -> ../lib/firefox/firefox`, el `.xpi` de
      `langpack-es-ES` puesto, y el anclaje de Mozilla sigue a prioridad 1000
- [x] La secuencia de §6.4 **deja de hacer falta**: lo que allí eran tres
      órdenes lo hace el seed. Si algo de la secuencia no se puede expresar en
      el seed, **eso es un hallazgo y se mide**; no se cambia la secuencia para
      que encaje. **Medido el 2026-08-10 (§4.17): los cuatro pasos se trasladan
      tal cual y ninguno se queda fuera.** Lo que cambia es el reparto: el paso 3
      deja de traer Firefox y lo trae el 4. **No quitar el paso 4 pensando que es
      «solo el idioma».**
      **Ejecutados por el seed el 2026-08-10 (§4.18i), y con sus controles:** el
      paso 3 propone 84 paquetes y **ni uno es Firefox** —`firefox` no aparece
      ni una vez en las 627 líneas de la simulación más el `full-upgrade` real,
      y `gnome-shell` aparece 16, así que el conteo no está ciego—; el paso 4
      instala `firefox` **y** `firefox-l10n-es-es`. **Y lo que faltaba por
      medir, que era el riesgo de verdad: hay red desde dentro del chroot**
      (§4.18f), porque `curtin in-target` deja dentro el `resolv.conf` del
      entorno vivo
- [x] **[OJOS] Una firma en `valide.redsara.es`** sobre una máquina instalada
      así, **que nadie ha tocado a mano**.
      **MARCADA el 2026-08-10 (§4.20d). La firma la hizo y la vio Jorge; el
      agente no ha visto la pantalla**, y así queda dicho. Sobre un clon efímero
      de `encina-E2-0.2.1` —máquina 100 % producto del seed, verificada como root
      con 35 correctas y 0 fallos— que **se destruyó después**, con control de que
      no queda ninguna copia del `.p12` en los bundles de UTM, ni en el
      repositorio, ni en el scratchpad, y con el original intacto por huella.
      **Corroboración que dejó la máquina, recogida antes de destruirla:** el
      navegador que firmó era `/usr/lib/firefox/firefox-bin`, **fuera de
      `/snap/`**; AutoFirma se lanzó desde el navegador por el esquema
      `afirma://websocket` (o sea que B1 sigue cerrada) apuntando al **perfil
      nativo** `~/.config/mozilla/` y no al del Snap (o sea que B5 no se
      reprodujo); y la CA `SocketAutoFirma` estaba en el almacén NSS del perfil
      que Firefox usa de verdad, **con la misma huella que la del paquete en
      disco, comparadas las dos en DER**. **Ojo al medirlo: hay cinco entradas en
      el directorio de perfiles y tres no son perfiles; `profiles.ini` e
      `installs.ini` se contradicen, y un `head -1` responde «la CA no está»,
      que es falso (§4.2a).** Va en un **clon efímero que se
      destruye después** (`ENCINA-OS.md` §9.1), y se comprueba por huella que no
      queda copia del `.p12`.
      **Lo que colgaba de aquí ya está contestado y quita el riesgo de que fuera
      imposible (§4.18l): el vigilante de AutoFirma funciona igual en una
      máquina sin Snap.** Instalado por el seed, cuando **no existía ninguna
      sesión de usuario** —su `postinst` avisa de que no ha podido quedar
      vigilando ninguna, y dice la verdad—, deja las dos unidades enlazadas en
      `default.target.wants`, que arman cualquier sesión posterior. Medido: al
      abrir Firefox una vez, el almacén NSS nace a las `15:02:52` y la CA entra
      a las `15:02:54`, **con la misma huella sha256 que la del paquete en
      disco**, y en el perfil que Firefox usa de verdad. **Ojo al medirlo: hay
      dos perfiles y `profiles.ini` e `installs.ini` se contradicen (§4.2a); un
      `head -1` coge el vacío y responde «la CA no está», que es falso**

**Cómo llega el parámetro `autoinstall` a la máquina: DECIDIDO el 2026-08-10 —
lo pone el hipervisor.** El motivo entero está en `ENCINA-OS.md` §10 y en una
línea es éste: lo que E2 entrega es la receta, y el hipervisor la valida; lo que
el hipervisor no prueba —«se la puedes dar a alguien»— es literalmente la
definición de E3. Reempaquetar la ISO **es** E3, y mezclarlo con E2 haría
indistinguible un fallo de la ISO de un fallo de la receta. **Las tres salidas no
cambian ni una línea del `autoinstall.yaml`**, así que elegir no compromete nada.
E3 hereda la deuda con nombre: poner esa palabra sin hipervisor.

**Lo que la medición del Snap abrió quedó cerrado el mismo día** (§4.17): la
secuencia de §6.4 se traslada al seed **tal cual**, con el aviso de que en una
máquina sin Snap el paso 4 es también el navegador.

**Los dos iconos de Firefox: CERRADO el 2026-08-10** (§4.19). Era un defecto de
`encina-firefox-native` y no de la entrega —el duplicado ya existía en E1
(§4.17h)—, y se arregla con `NoDisplay=true` en la sombra
(`encina-firefox-native` **0.2.1**), que es **el único estado que deja un icono
en los dos mundos sin reabrir A2**: quitar la sombra devuelve
`/snap/bin/firefox %u` en una máquina con Snap, y `Hidden=true` deja muerto el
icono anclado. `NoDisplay` oculta pero no desactiva.

**Y de paso se arregló la casilla, que estaba al revés, no floja:** pedía
`NINGUNA`, y `NINGUNA` solo se alcanza reabriendo A2 o matando el icono. Ahora
pregunta lo que quería preguntar —que no resuelva bajo `/snap/`— y añade la
condición que no tenía nadie: **cuántos iconos ve el usuario**. Ninguna de las
doce casillas de §6.4 contaba iconos; todas preguntaban a qué resuelve el
identificador, y por eso el duplicado vivió desde A2.

**Consecuencia obligatoria y hecha:** cambiar el paquete cambia una de las cuatro
huellas del seed, así que se reconstruyó el volumen (`b8269e52…`) y **se remidió
§4.18 con una instalación entera en una máquina nueva**, `encina-E2-0.2.1`.

### 6bis.4 Dónde vive el seed, y qué hace cada fichero

Escrito y medido entero el 2026-08-10 (`MEDICIONES.md` §4.18). **Son cinco
ficheros en `imagen/` y ninguno toca la ISO oficial.**

| Fichero | Qué es |
|---|---|
| `imagen/autoinstall.yaml` | **El seed.** Identidad, almacenamiento y tres `late-commands`: los dos testigos de §4.14e y la que hace el trabajo |
| `imagen/encina-seed.sh` | El fuente **legible** de esa tercera, que viaja en base64. Hace, en este orden: monta el volumen por etiqueta, copia el repo a `/srv/encina-repo` **comprobando las cuatro huellas**, purga `snapd`, ejecuta los pasos 2, 3 y 4 de §6.4 y **comprueba lo que ha dejado** (bloque 14, desde el 2026-08-11). Deja 1900 líneas de registro dentro de `/target` y **nunca sale distinto de 0** |
| `imagen/meta-data` | `instance-id` y `local-hostname` |
| `imagen/fabricar-seed.sh` | Fabrica el volumen `CIDATA` en macOS. **Se niega** si un `.deb` no coincide con su huella o si el YAML y el guion se han separado |
| `imagen/verificar-instalacion.sh` | Verifica la máquina que sale, **como root**, cada comprobación con su control. Su bloque 6 lee el veredicto del seed |

**EL VEREDICTO DEL SEED, nuevo el 2026-08-11** (`MEDICIONES.md` §4.27). Hasta ese
día el guion hacía sus seis pasos, apuntaba seis `rc` en un fichero que nadie lee
y escribía «llegué al final» **aunque no hubiera llegado nada más**. Sin red no
entra **ni uno** de los cuatro `.deb` —apt es todo o nada, y ni el JRE que pide
`autofirma`, ni `libnss3-tools`, ni `hunspell-es` viajan en el medio— y la
instalación **terminaba diciendo que fue bien**: trampa 5. Ahora el guion pregunta
al objetivo por `dpkg` y deja **`/etc/encina-estado`** con
`ENCINA_ESTADO=COMPLETO|INCOMPLETO` y `ENCINA_FALTA=<lo que falta>`, con su
control dentro —un paquete inventado— que hace que un comprobador ciego **no
pueda certificar nada**. El testigo del seed termina desde entonces en `estado=…`,
y es lo que le permite a `verificar-instalacion.sh` distinguir «esta máquina no puede
contestar» (seed anterior, `[OMIT]`) de «esta máquina tenía que contestar y no
está el fichero» (`[FALLO]`).

~~**Y una regla de este guion queda marcada como pendiente de decidir, no como
buena:** *«nunca sale distinto de 0»* se escribió para **medir** (§4.16), y en el
producto significa que una instalación incompleta termina bien igual. Que falle a
la vista es una línea, está escrita como comentario y **no** puesta.~~
**DECIDIDA Y PUESTA EL 2026-08-12** (`MEDICIONES.md` §4.31c). El guion termina en
`[ "$ESTADO" = COMPLETO ] || exit 1`, y se pudo poner porque **se leyó qué hace
`subiquity`** en el código que viaja dentro de la ISO: `LateController` hereda
`cmd_check = True`, la excepción se recoge en `install.py:628-639` **después** de
`curtin_install()` y `postinstall()`, y el manejador de último nivel pone
`ApplicationState.ERROR`. O sea: **se ve, la máquina queda instalada y
arrancable, y el registro se queda dentro**. Por eso el log, `/etc/encina-estado`
y el testigo se escriben **antes** de esa línea.
**Y de propina, un discriminador gratis:** en la forma E2, con `-no-reboot`, una
VM que **se apaga sola** ya significa `ESTADO=COMPLETO`, sin abrir nada.

**El seed cambia además de tamaño en E4:** con el nivel 3 de §4.27 el repositorio
deja de ser cuatro `.deb` y 44 MB, así que `fabricar-seed.sh` gana `--tam-mb`
(por defecto 768) y sus dos herramientas comprueban ahora **el índice `Packages`
entero** contra los bytes que viajan, en las dos direcciones, en vez de las
cuatro huellas de siempre.

**Tres cosas que no son obvias y cuestan caro si se cambian sin medir:**

- **El guion va en base64 y en una sola `late-command`** a propósito: así no hay
  ni una comilla que YAML o el intérprete puedan leer de otra manera, y así el
  registro sale de una pieza. Cada intento cuesta una instalación entera.
- **Un `rc=0` de una `late-command` no dice nada del objetivo** (trampa 10). Por
  eso el guion inventaría `/target` **antes y después**, desde fuera del chroot,
  y con `-e` **y** `-L`.
- **El repositorio no puede vivir en un `$HOME`** (§4.15). Va en `/srv/encina-repo`,
  y ahí se queda en la máquina instalada, con su `.list` de `[trusted=yes]`.

---

## 6ter. La ISO que arranca sola — E3, abierto el 2026-08-10

**Qué entrega E3, en una línea:** la ISO oficial de Ubuntu **reempaquetada** con
el seed de Encina dentro, de forma que se la puedas dar a alguien —o a ti dentro
de seis meses— y **se instale como se instala Ubuntu**, preguntando lo que
pregunta Ubuntu, pero dejando una máquina que es Encina OS.

### 6ter.0 LA FORMA DE E3, decidida el 2026-08-10, y no se vuelve a discutir

**La ISO pregunta lo que pregunta Ubuntu, menos lo que es el producto.** Las
**cinco** secciones que contesta quien instala van listadas por nombre
—`keyboard`, `network`, `storage`, `identity`, `timezone`—, y **no son nombres
inventados: son los `autoinstall_key` de los controladores de esta ISO**
(`keyboard.py:162`, `network.py:77`, `filesystem.py:248` para `storage`,
`identity.py:50`, `timezone.py:80`). El seed no aporta ninguna de esas respuestas
— aporta **solo lo de Encina**, que va entero en las `late-commands` y es **byte a
byte el mismo** trabajo que el de E2.

**LO QUE NO SE PREGUNTA, Y ES LO QUE HACE QUE ESTO SEA UN PRODUCTO: `source` y
`locale`.**

- **`source: ubuntu-desktop-minimal`**, y con él `codecs: {install: false}` y
  `drivers: {install: false}`. Encina OS **se construye sobre la instalación
  mínima**, y lo que va encima se declara en `encina-meta`, que es el eje por el
  que crece (E4, `ENCINA-OS.md` §6). Si se preguntara, media entrega dependería
  de que el usuario acertara con una pantalla y **dos máquinas de Encina OS no
  serían la misma cosa**.
- **`locale: es_ES.UTF-8`** (decidido el 2026-08-10, a la vez que lo anterior).
  Mismo motivo y además una incoherencia que quita: el seed instala
  `firefox-l10n-es-es` **sin condición** y `encina-meta` arrastra el resto del
  idioma. **Si el idioma se preguntara, quien eligiera otro se llevaría una
  máquina a medias** —sistema en un idioma, navegador en español—. Encina OS
  existe para firmar con la administración española; el idioma es producto, no
  preferencia.
- **El teclado sí se pregunta, y la distinción importa:** el teclado es
  **hardware**, y no todo el que quiere el sistema en español teclea en un
  teclado español.

Se usa la lista explícita **en vez de `['*']`** exactamente por esto: `'*'` haría
interactivas también `source` y `locale`.

**Y el mecanismo permite mezclar**, que es lo que esto usa: `controller.py:113-127`
decide **sección por sección**, no todo o nada. Que el instalador **de
escritorio** lo haga bien con unas interactivas y otras no **es justo lo que hay
que medir**, y es la primera casilla de §6ter.3.

**Por qué, y hay que leerlo entero porque corrige una inercia de este
documento.** E2 tenía que instalar sin que nadie tocara nada, y eso **no era el
producto: era el criterio de validación**. Está escrito en `ENCINA-OS.md` §10 con
esas palabras. Lo que pasó es que E3 heredó el criterio como si fuera el
producto, y de ahí salía todo lo demás: si la ISO no puede preguntar, el usuario
tiene que venir escrito dentro; si viene escrito dentro, hace falta una
contraseña; y entonces hay tres salidas y ninguna buena. **La contraseña no era
un problema que resolver: era el síntoma de haberse llevado a la entrega un
criterio de laboratorio.** Lo señaló Jorge el 2026-08-10 con la pregunta correcta
—«si instalo Ubuntu me pide las credenciales, ¿por qué aquí no?»— y la decisión
es suya.

**Tres consecuencias, y las tres abaratan E3:**

1. **Desaparece la contraseña**, y con ella las tres salidas de §6ter.5. No hay
   `identity:`, ni `ssh:`, ni clave, ni hash en el repositorio.
2. **Desaparece la deuda del GRUB.** La palabra `autoinstall` existía para
   saltarse el clic de confirmación **cuando no hay nadie delante**. Con
   secciones interactivas hay alguien delante y ese clic es la pantalla normal de
   «instalar ahora». **E3 no toca `boot/grub/grub.cfg`**, y por tanto tampoco
   `md5sum.txt`.
3. **Lo que sí sigue haciendo falta es meter el seed dentro de la ISO**, que es
   exactamente lo que se midió el mismo día (§4.21). El trabajo de esa medición
   es la parte que sobrevive entera.

**Y se puede quitar la identidad sin romper nada, comprobado leyendo y no
supuesto:** ni `imagen/encina-seed.sh` ni `imagen/verificar-instalacion.sh` nombran al
usuario, ni usan `/home` ni `$HOME`. Todo el trabajo es del sistema
—`/srv/encina-repo`, `apt`, purgar `snapd`—, que es consecuencia directa de **R1**
(nada de `/etc/skel`). La receta es **agnóstica del usuario**, y eso no se sabía
escrito hasta hoy.

**Lo que esto le cuesta a la definición de terminado, y hay que decirlo sin
maquillarlo:** la casilla de E2 era «nadie la toca». **La de E3 no puede serlo, y
no debe.** Pasa a ser: *una persona contesta lo que Ubuntu pregunta, y nada
más* — ni una orden, ni un fichero, ni una edición. Eso es más débil como prueba
automática, y por eso **el seed de E2 se conserva tal cual**: es la única prueba
que queda de que la receta entera funciona sin humano, y sigue corriendo con
`CIDATA` en el banco.

### 6ter.1 Lo decidido antes de escribir nada, y por qué no se vuelve a discutir

Todo esto sale de `MEDICIONES.md` §4.21, que se hizo **antes de tocar `xorriso`**
justamente para no llegar al reempaquetado con tres candidatos.

- **El seed va a la raíz del ISO9660 como `autoinstall.yaml`**, y el instalador
  lo encuentra en `/cdrom/autoinstall.yaml`. Es el quinto sitio de
  `select_autoinstall` (`server.py:889-924`), la ruta es literal
  (`server.py:73-75`) y `/cdrom` es el medio, medido en el casper de esta misma
  ISO. **E3 NO usa `CIDATA`.**
- **No se toca `boot/grub/grub.cfg`, y por tanto tampoco `md5sum.txt`**
  (§6ter.0): sin instalación desatendida no hace falta la palabra. **Se deja
  escrito lo que costó medirlo, por si alguna vez vuelve a hacer falta:** la
  palabra iría **suelta** en la línea `linux /casper/vmlinuz` de ese fichero, que
  es **el único `grub.cfg` del medio** —la partición EFI tiene tres binarios y
  cero ficheros de configuración, y el GRUB firmado no lleva menú dentro—;
  `autoinstall=1` NO vale (§4.16a); y **`md5sum.txt` cubre ese fichero**, así que
  editarlo sin rehacerlo deja una ISO que arranca y falla la comprobación de
  integridad del propio medio.
- **No se toca ninguno de los tres binarios firmados** —`bootaa64.efi` (shim),
  `grubaa64.efi`, `mmaa64.efi`—. **El motivo no es prudencia, es una medición:**
  el banco de UTM **no aplica Secure Boot** —no implementa ni `PK`, ni `KEK`, ni
  `db`—, así que **si se rompieran, aquí no lo notaría nadie**. Su huella sha256
  antes y después es una comprobación de la definición de terminado, no un
  detalle. **Con la forma de §6ter.0, además, no hay ni un motivo para tocarlos:
  E3 añade ficheros al medio y no modifica ninguno.**
- **El repo local y los cuatro `.deb` viajan dentro de la ISO**, igual que hoy
  viajan dentro del volumen del seed, y con **las mismas cuatro huellas**
  comprobadas por los dos lados (trampa de §4.13). La ISO crece ~128 MiB.

### 6ter.2 Lo medido al abrir, que ya no se pregunta

| Pregunta | Respuesta medida (§4.21) |
|---|---|
| ¿Aplica Secure Boot en el banco de UTM? | **No, y no puede.** UTM arranca `edk2-aarch64-code.fd` —leído de la orden de QEMU real, no del fichero de configuración—; no existen `SecureBoot`, `SetupMode`, `PK`, `KEK` ni `db`; `mokutil` dice *«This system doesn't support Secure Boot»* y el núcleo, `secureboot: Secure boot disabled`. **Con su control:** hay 32 variables EFI y se lee una en hexadecimal, así que «no está» significa «no está» |
| ¿Está la cadena firmada, entonces? | **Sí, y se recorre.** `MokListRT` y `SbatLevelRT` existen y las escribe el `shim`. Lo que no hay es quien verifique |
| ¿Dónde busca el instalador un seed metido en la ISO? | **`/cdrom/autoinstall.yaml`**, quinto de cinco, leído en el código que viaja dentro de esta ISO (snap `0+git.4bc1f4077`, el mismo que leyó §4.16a) |
| ¿Y `/cdrom` es el medio? | **Sí**, medido en casper: `scripts/casper:7` → `mountpoint=/cdrom`, y `casper-bottom` consume `/root/cdrom/.disk/info`, que existe en la raíz del ISO9660 |
| ¿Quién gana si además hay un `CIDATA`? | **El `CIDATA`**, que va cuarto. Bueno para el producto —la ISO se puede anular sin tocarla— y **trampa para la medición**: un volumen olvidado la secuestraría en silencio |
| ¿Qué `grub.cfg` manda? | **`boot/grub/grub.cfg`, el único del medio.** La ESP (FAT12, 6,59 MiB, El Torito platform 0xEF) tiene tres `.efi` y **cero** `.cfg`, y los tres son byte a byte los mismos que los de `efi/boot/` del ISO9660 |

### 6ter.3 Definición de terminado de E3

Cada casilla con lo que daría en un sistema sano y en uno roto. **No marcar
ninguna sin la salida literal.**

**CONTRA QUÉ ISO ESTÁ MARCADA CADA UNA, que desde el 2026-08-10 hay dos y sin
esto la lista mentiría.** Las ocho se marcaron contra `encina-os-E3.iso`
(`0a1127f4…`), la del instalador en inglés. La novena obliga a una ISO nueva,
`encina-os-E3-es.iso` (`02ab929d…`), y **una ISO distinta es otro artefacto**:
las casillas que hablan del **fichero** se remarcan solas al construirla —el
guion las comprueba todas en cada construcción, y con la nueva salieron verdes—,
pero las tres que hablan de **arrancarla** no las puede marcar ningún guion, así
que **vuelven a abrirse** y se cierran con la misma instalación que cierra la
novena. Aflojar esto sería marcar como probada una ISO que nadie ha arrancado.

- [x] **La forma nueva funciona, y se mide ANTES de tocar `xorriso`, con un
      volumen `CIDATA`.** Es el paso que separa «¿es esta la forma correcta?» de
      «¿sé reempaquetar una ISO?», y las dos preguntas no se mezclan.
      *Sano:* el instalador **de escritorio** enseña las pantallas de Ubuntu
      —usuario, contraseña, disco— y aun así **las `late-commands` corren**.
      *Roto:* ignora `interactive-sections` y se comporta como hasta ahora, o las
      enseña y se salta el trabajo de Encina. **Está leído que la clave existe en
      esta ISO** (`server.py:236`, `controller.py:113-127`, y el punto HTTP
      `interactive_sections_GET` que consulta el cliente gráfico), **pero leído
      no es medido**, y el instalador de escritorio no es el de servidor.
- [x] **Un guion versionado de este repositorio construye la ISO**, no una
      secuencia tecleada a mano. *Sano:* se ejecuta dos veces y produce la misma
      huella, o si no la produce se dice **por qué** y qué byte cambia. *Roto:*
      hace falta acordarse de un paso.
- [x] **La ISO no necesita nada de fuera.** *Sano:* el `debug.log` de QEMU **sin
      `-append`** y **con un solo disco además de la ISO** —el de destino—, o sea
      que **no había ningún `CIDATA` conectado**. *Roto:* cualquier `-append`, o
      un segundo `-drive`. **Es el control que importa y es nuevo:** con un
      `CIDATA` enganchado la instalación saldría bien **midiendo el seed
      equivocado** (§4.21c, trampa 16). **La prueba es lo que NO estaba
      conectado, y eso solo se ve desde fuera y antes de arrancar.**
      **Reabierta el 2026-08-10:** se marcó con el `debug.log` de la ISO
      `0a1127f4…`, y el `debug.log` de otra ISO es otro `debug.log`.
- [x] **La ISO es la oficial reempaquetada, y se demuestra.** **REESCRITA el
      2026-08-10 con su motivo, al añadir la novena casilla:** decía «solo
      ficheros añadidos, ninguno modificado», y eso dejaba de ser verdad en
      cuanto el instalador tenía que hablar español. No se afloja — se hace **más
      exigente**, porque ahora hay que enseñar *qué* cambió y no solo *que* nada
      cambió. *Sano:* los tres binarios firmados con **la misma sha256** que en
      la ISO oficial, y la lista de diferencias del medio entero —las **501**
      entradas, no solo las 266 de `md5sum.txt`— es exactamente ésta: **seis
      ficheros añadidos** (`/autoinstall.yaml` y los cinco de `/encina-repo/`),
      **dos modificados y nombrados** (`/boot/grub/grub.cfg` y `/md5sum.txt`),
      **ninguno perdido**. *Roto:* cualquier binario firmado con huella distinta
      —y ojo, que **este banco no lo detectaría al arrancar**, así que la huella
      es la única señal—, o **un solo fichero cambiado que no sea uno de esos
      dos**. **Con su control:** la comparación tiene que señalar una huella
      saboteada a mano.
- [x] **La comprobación de integridad del propio medio sigue pasando, contra el
      `md5sum.txt` NUEVO.** **REESCRITA a la vez que la de arriba, y es el precio
      de §4.21d pagado entero.** *Sano:* las 266 líneas del `md5sum.txt` **que
      viaja en la ISO construida** cuadran con el medio, la del `grub.cfg`
      incluida. *Roto:* cualquiera que falle. **Y el control que hace que esto no
      sea autocomplaciente:** con el `md5sum.txt` **oficial** tiene que fallar
      **exactamente una** línea, la de `./boot/grub/grub.cfg` — que es la ISO que
      se entregaría si alguien editara el `grub.cfg` y no pagara el precio.
- [x] **La máquina que sale es la de E2.** *Sano:* `imagen/verificar-instalacion.sh` como
      root, **35 correctas, 0 fallos, 0 avisos, 0 omitidas**, igual que §4.20c,
      **con el usuario que haya elegido quien instaló**, no con uno fijo. *Roto:*
      cualquier diferencia — y sería un hallazgo, porque el trabajo del seed es
      el mismo y solo ha cambiado quién contesta las preguntas.
      **Reabierta el 2026-08-10:** la máquina que la marcó salió de `0a1127f4…`.
      Y **ahora la casilla dice más de lo que decía**, porque el `locale=` del
      `grub.cfg` toca la sesión viva: si esa máquina saliera distinta, el arreglo
      del idioma habría cambiado algo que no tenía que cambiar.
- [x] **En la ISO no hay ninguna credencial.** *Sano:* ni `identity:`, ni
      contraseña, ni hash, ni clave ssh en el seed que viaja dentro — comprobado
      sobre el fichero extraído de la ISO construida, no sobre el del
      repositorio. *Roto:* cualquiera de las cuatro cosas. **Con su control:** la
      búsqueda tiene que saber encontrarlas en el seed de laboratorio, que sí las
      lleva.
- [x] **[OJOS] La ISO se entrega y se instala en una VM creada desde cero**, sin
      relación con las del proyecto: sin clonar, sin heredar configuración, sin
      que nadie le pase ningún parámetro y **sin más intervención que contestar
      las pantallas que Ubuntu pregunta**. Es la casilla que decide, porque es
      literalmente lo que E3 promete —«se la puedes dar a alguien»— y lo único
      que no se puede comprobar reutilizando el banco. **Va acompañada de lo que
      se contestó**, para que se sepa qué se dio por normal.
      **Reabierta el 2026-08-10:** se marcó instalando `0a1127f4…`. La ISO que se
      entrega es `02ab929d…`, y esta casilla es literalmente «se la puedes dar a
      alguien»: no la puede heredar una ISO de otra.

- [x] **NOVENA CASILLA, añadida el 2026-08-10 DESPUES de marcar las ocho, con
      su motivo (§4.23e).** *El instalador se ve en el idioma del producto.*
      **Las ocho de arriba se cumplieron enteras y aun así la ISO recibe a quien
      la instala en inglés**, porque sacar `locale` de `interactive-sections`
      deja la sesión viva en el idioma por defecto. **Eso es un defecto de esta
      definición, no del producto**, y es el error de §4.19d otra vez: una
      casilla que deja pasar un estado que nadie querría entregar. No se añade
      por gusto: Encina OS existe para la administración española.
      *Sano:* el instalador sale en español. *Roto:* en inglés, con el sistema
      instalado en español, que es lo medido hoy.
      **El arreglo está leído** en `casper-bottom/14locales` de esta ISO:
      `locale=es_ES.UTF-8` en la línea del núcleo. **Y tiene precio, que hay que
      pagar entero:** va en `boot/grub/grub.cfg`, así que E3 deja de ser «solo
      añadir ficheros» y **hay que rehacer `md5sum.txt`** (§4.21d). La casilla de
      integridad de arriba pasa a comprobar el `md5sum.txt` **nuevo**, no el
      oficial.
      **EL PRECIO YA ESTÁ PAGADO, y lo que falta es exactamente lo que no puede
      pagar ningún guion** (2026-08-10, §4.25): `imagen/fabricar-iso.sh` pone la
      palabra, rehace la línea de `md5sum.txt`, y **enseña que no cambió nada
      más** comparando las 501 entradas del medio contra la oficial —seis
      añadidos, dos modificados y nombrados, ninguno perdido—, con el control de
      que **con el `md5sum.txt` oficial falla exactamente una línea**. La ISO
      `encina-os-E3-es.iso` (`02ab929d…`) existe, es reproducible y los tres
      binarios firmados siguen intactos. **Lo que queda es mirar la pantalla**, y
      eso es de Jorge.
      **MARCADA el 2026-08-10 (§4.25d). Lo declara Jorge: «el instalador se ve en
      español».** Yo no he visto esa pantalla y así queda escrito. Y la máquina
      que sale es **idéntica** a la de §4.23d —36 correctas, 0 fallos—, que es lo
      que prueba que el `locale=` **no tocó nada que no tuviera que tocar**: toca
      la sesión viva, o sea el entorno donde corren las `late-commands`.

**Lo que E3 NO promete, y va escrito para que no se cuele como casilla verde:**
que la ISO arranque en una máquina con **Secure Boot activo**. Este banco no lo
puede demostrar (§6ter.2), y es un **límite declarado**, como D9 con amd64. La
regla de no tocar los binarios firmados existe para que ese límite siga siendo
solo un límite y no se convierta en un fallo.

**LÍMITE DECLARADO DE E3, con la forma de D9 — el medio no lleva el núcleo
(2026-08-13).** Llega aquí desde `§6quater.1`, donde estaba mal puesto: aquella
casilla mezclaba dos incrementos, y **el núcleo no es una aplicación de serie, es
qué lleva el medio**, o sea E3. **No es un pendiente ni una casilla floja: es un
límite de alcance declarado**, y se declara porque **está leído hasta el final**
(`MEDICIONES.md` §4.32) y no porque se ignore.

- **Qué pasa:** una instalación **sin red** no llega al seed. El disco se para en
  **4 461 MB** y la pantalla dice *«Se produjo un problema»* (§4.31l). El motivo
  es que **`curtin` instala el núcleo antes de que exista nuestro repositorio**, y
  lo baja de internet.
- **Qué NO lo arregla, medido y no supuesto:** una sección `apt:` en el seed. En
  el camino sin red `subiquity` **borra a propósito** las partes de
  `sources.list.d` que hereda el objetivo (`apt.py`), así que esa fuente existiría
  **con** red —donde no hace falta— y no **sin** ella.
- **Qué falta exactamente:** no una fuente nueva. El objetivo **ya lee el medio**
  por `file:/cdrom` cuando `curtin` instala el núcleo, y el registro lo enseña
  sirviéndole **GRUB entero**. Lo que falta es el núcleo **dentro del archivo
  indexado** (`/dists` + `/pool`), y eso lo cierra **la firma de Canonical**:
  tocar `Packages` rompe `Release`, y la línea que escribe `subiquity` no lleva
  `[trusted=yes]`.
- **Cuánto cuesta:** **1 089 MB medidos**, no ~700, con `linux-firmware` (655 MB)
  como `Depends:`. El medio pasaría de 3,7 a ~4,7 GB, o sea **fuera del DVD de una
  capa y fuera del límite de 4 GiB de FAT32**. Esa consecuencia se declara aquí
  para que no la descubra nadie al grabar.
- **La salida, nombrada y NO medida:** re-firmar el `dists/` del medio con clave
  propia y hacerla viajar en `apt: sources: {key:}`, que **sí** sobrevive al
  borrado porque va a `trusted.gpg.d`.
- **Es de Jorge decidir si se compra**, igual que amd64 en D9. Mientras no se
  compre, **Encina OS requiere red durante la instalación**, y eso es una
  propiedad declarada del producto, no un defecto sin encontrar.

### 6ter.4 Dónde vivirá lo nuevo

Nada de esto existe todavía; se escribe según se mida.

| Fichero | Qué es |
|---|---|
| `imagen/autoinstall.yaml` | **Escrito el 2026-08-10. El seed de la entrega.** Siete claves: `version`; `interactive-sections` con las **cinco** secciones que contesta quien instala (`keyboard`, `network`, `storage`, `identity`, `timezone`); **`locale: es_ES.UTF-8`** y **`source: ubuntu-desktop-minimal`** con `codecs` y `drivers` en `false`, **que son las que NO se preguntan porque son el producto**; y las **mismas tres `late-commands` de E2, byte a byte** (comprobado con `diff`). Sin `identity:`, sin `ssh:`, sin `storage:`, **sin ninguna credencial**. Va a la **raíz del ISO9660** con el nombre `autoinstall.yaml` |
| `imagen/autoinstall.yaml` | **El de E2, y se queda como está.** Es la única prueba que queda de que la receta entera funciona **sin humano**, y sigue corriendo con `CIDATA` en el banco. Su contraseña de laboratorio es legítima ahí y **no viaja a ninguna ISO** |
| `imagen/encina-seed.sh` | **El mismo, sin cambios.** Los dos seeds llevan su base64 y `fabricar-seed.sh` se sigue negando si se separan |
| `imagen/verificar-instalacion.sh` | **El mismo, sin cambios**: la máquina que sale tiene que ser la misma |
| `imagen/fabricar-iso.sh` | **Escrito el 2026-08-10, y ampliado el mismo día.** Construye la ISO a partir de la oficial **añadiendo seis ficheros —el seed y el repo local— y modificando dos, nombrados: `boot/grub/grub.cfg` (el `locale=` del instalador) y `md5sum.txt` (su precio, §4.21d)**. Comprueba las huellas de los tres binarios firmados antes y después, compara **las 501 entradas del medio** contra la oficial, verifica las 266 líneas de `md5sum.txt` contra la ISO construida, y **se niega** si algo no cuadra, como `fabricar-seed.sh`. **Y desde el 2026-08-13 fija también el MODO de lo que añade** —`0644` los ficheros, `0755` el directorio, con un guardián que comprueba que el `chmod` se aplicó (trampa 13)—, porque `cp` heredaba el modo del disco del Mac y ese modo viajaba dentro de la ISO (§4.36k). **Es reproducible, y ya no es una afirmación: cinco construcciones dieron la misma huella, una de ellas desde un directorio con cuatro ficheros fuera de `0644` a propósito (§4.39f)** |
| `imagen/construir-todo.sh` | **Escrito el 2026-08-13** (§4.39i). **De un árbol versionado a la ISO en una sola orden**: construye los tres `.deb`, cosecha los 24 de fuera y `autofirma`, genera el `Packages` y fabrica el medio. **Cruza dos máquinas y no hay remedio**: `dpkg-buildpackage` y `dpkg-scanpackages` no existen en macOS y `fabricar-iso.sh` sólo corre aquí, así que los pasos 1 y 3 van por `ssh` al constructor. Construye **`git archive HEAD` y no el directorio de trabajo** —§4.37d convertido en regla— y **se niega sobre un árbol sucio**. Comprueba que no haya dos VMs encendidas (trampa 14). Su definición de terminado no es «sale una ISO» sino que **dos pasadas seguidas den la misma huella**, y lo dice al final en vez de fingir que una sola lo demuestra |

~~**Un apaño pequeño que hace falta antes del paso 1:** `fabricar-seed.sh` tiene
la ruta `autoinstall.yaml` fija.~~ **HECHO, y la deuda estaba mal contada: no se
hizo el 2026-08-12, se había hecho antes y este párrafo no se enteró.**
`fabricar-seed.sh` acepta `--yaml <ruta>` desde que se escribió `autoinstall.yaml`
—es lo que usa `--actualizar-yaml` sobre los dos seeds—, y **ninguna de sus
negativas se aflojó**: sigue negándose si un `.deb` no coincide por huella y si
el YAML y `encina-seed.sh` se han separado. Comprobado el 2026-08-12 rehaciendo
**los dos** seeds desde el mismo `encina-seed.sh` y verificando el camino de
vuelta —sacar el base64 del YAML, decodificarlo y compararlo con el guion—, con
el control de que un byte de más rompe la comparación. La `late-command` sigue
siendo **la misma en los dos ficheros, byte a byte** (37 291 caracteres).
**Lo que sí era nuevo el 2026-08-12 es `--tam-mb`**: con el nivel 3 de §4.27 el
repo del medio deja de caber en los 128 MiB de siempre.

**Lo que no se sabe todavía, en orden de riesgo:**

1. **Si el instalador de escritorio honra `interactive-sections`.** Está en el
   código de esta ISO, pero leído no es medido. **Se contesta con `CIDATA`, sin
   `xorriso`.**
2. **Si `xorriso` sabe reconstruir esta ISO** conservando la ESP y El Torito.
3. **Qué pasa si quien instala elige la instalación completa** en vez de la
   mínima. El seed ya no impone `source:`, así que es una respuesta más del
   usuario. El purgado de `snapd` debería taparlo, pero **no está medido**.

### 6ter.5 La contraseña: disuelta, no resuelta (2026-08-10)

**Aquí había tres salidas y una decisión pendiente. Ya no.** Con la forma de
§6ter.0, el seed de la entrega **no lleva usuario**, así que no hay ninguna
contraseña que elegir: la pone quien instala, en la pantalla de siempre, y no
existe en ningún fichero de este repositorio ni dentro de la ISO.

**Lo que sí queda, y es una casilla:** comprobar que no se ha colado ninguna
credencial en la ISO construida — ni contraseña, ni hash, ni clave ssh — mirando
**el fichero extraído de la ISO**, no el del repositorio, y con el control de que
la búsqueda sabe encontrarlas en el seed de laboratorio, que sí las lleva.

**Y `encina` sigue viva donde tiene sentido:** en `imagen/autoinstall.yaml`, el
seed de laboratorio, que se sirve con `CIDATA` y nunca entra en una ISO. Es
débil y pública **a propósito y por escrito**, porque su trabajo es medir sin
humano en máquinas desechables (`MEDICIONES.md` §4.20).

---

## 6quater. Las aplicaciones de serie — E4, abierto el 2026-08-11

### 6quater.0 Lo decidido, que no se vuelve a discutir

Está en `ENCINA-OS.md` §2, y se resume aquí para no tener que abrir el otro
documento en mitad de la vuelta:

- **D16 — la convivencia (c).** `snapd` presente, el Snap de Firefox instalado y
  **nunca abierto**, y el Firefox que el usuario puede abrir es **el nativo**.
- **D17 — ni suite ofimática ni cliente de correo.** Entran el visor de PDF **con
  el manejador atado** y `simple-scan`. No entran LibreOffice, Thunderbird ni
  Okular.
- **D18 (REESCRITA el 2026-08-12) — la tienda es el «Centro de aplicaciones»
  (`snap-store`), y `gnome-software` SALE.** La tienda **no es una línea de
  `encina-meta`**: es un snap pre-sembrado en el medio, así que cuesta **0
  paquetes** y llega solo porque desde D16 el seed ya no purga `snapd`. Lo que
  `encina-meta` 0.2.1 declara es **`snapd`**, el motor. Flathub y el plugin de
  flatpak siguen fuera a propósito.
  **El motivo por el que D18 se reabrió, para no rediscutirlo:** la versión
  anterior eligió `gnome-software` **sin haber considerado `snap-store`**, porque
  aquel día el seed aún purgaba `snapd` y esa tienda no existía en la máquina;
  apareció después (§4.31h) y el usuario pasó a ver **dos**.

**El precio de la tienda, escrito para que nadie lo descubra por su cuenta, y NO
cambia al cambiar de tienda:** en ella aparece también el Firefox del Snap, y
quien lo abra y firme **falla en silencio por B3, sin arreglo posible por nuestra
parte** (`MEDICIONES.md` §4.28), y se lleva **B4** de vuelta hasta que el nativo
sea otra vez el último abierto (§4.29f). **La defensa entera es la condición de
D16.** **Lo que sí cambia, y a mejor:** con `gnome-software` fuera, su catálogo
deja de meterse en el buscador de la rejilla —el bloque «Software, 15 más» que
§4.33c vio al firmar—, y el usuario ve **una** tienda en vez de dos (§4.34).

### 6quater.1 Definición de terminado de E4

Cada casilla, con lo que daría en un sistema sano y en uno roto. **No marcar
ninguna sin la salida literal.**

- [x] **El Firefox que el usuario puede abrir es el nativo** — la casilla que
      sustituye a «Sin Snap» (§6bis.3), y la cumplen las máquinas con Snap y sin
      él. *Sano:* **un solo** icono de Firefox; resuelve **fuera de `/snap/`** y
      el paquete no lleva epoch `1:`; **cero** perfiles de Mozilla bajo `~/snap/`,
      con el control de que el buscador sabe encontrar algo y sabe decir cero.
      *Roto:* dos iconos, o cualquier cosa bajo `/snap/`, o un perfil bajo
      `~/snap/` — eso último es el estado (d), el que no firma.
      **MARCADA el 2026-08-12 (§4.31h)** sobre `encina-E4-meta`: **1** icono,
      `firefox_firefox.desktop -> /usr/bin/firefox %u`, `firefox 153.0.4~build1`
      sin epoch, `/usr/bin/firefox -> /usr/lib/firefox/firefox`, **0** perfiles
      bajo `~/snap/` —y el buscador dijo **1** mientras existió el usuario
      desechable de la casilla de `+encina4`, así que ese cero significa algo—.
      **REFORZADA EL 2026-08-13 (§4.35ñ) con el caso que faltaba: la forma (c)
      SOBREVIVE a instalar y abrir un snap de terceros.** Con LibreOffice dentro y
      `~/snap/libreoffice` creado, siguen **0** perfiles de Mozilla bajo `~/snap/`
      y **1** icono de Firefox. **Y el control es más fuerte que antes:** no basta
      con que el buscador encuentre *algo*, tiene que encontrar **lo que busca** —se
      fabricó un `.mozilla/firefox/profiles.ini` a propósito en `/tmp`, el mismo
      patrón lo vio (**1**) y se borró—. **Dos correcciones que van escritas:**
      instalar un snap **no** crea `~/snap/<app>`, lo crea la **primera ejecución**;
      y `snapd` **se autorrefrescó solo**, llevando el Snap de Firefox de rev 7764 a
      **8753** sin que nadie lo tocara — refrescar no es abrir, así que la casilla
      aguanta, pero la huella escrita de la máquina cambia y el dato «revisiones de
      firefox en `/snap`» pasa de 1 a 2
- [x] **El Snap de Firefox SIGUE instalado y nadie lo ha tocado.** *Sano:* el
      inventario de `/target` **idéntico** antes y después del paso que antes
      purgaba, y `firefox_*.snap` presente. *Roto:* desaparece algo → alguien
      sigue purgando, y entonces esto es la forma (b) y no la (c) que declara
      D16. **MARCADA:** `diff` sin diferencias entre los bloques 4 y 6, los nueve
      `[PRESENTE]`, y **sustituir el `.deb` de transición por el de Mozilla no se
      lleva el Snap por delante** — que era lo que había que medir y no suponer
- [x] **Las aplicaciones de D17 y D18 están, y LA TIENDA DONDE DE VERDAD ESTÁ.**
      **REESCRITA el 2026-08-12 con D18** (§4.34): `gnome-software` sale, y la
      tienda pasa a ser un **snap**, así que **`dpkg-query` no la vería nunca** y
      preguntar por ella ahí sería una comprobación que solo sabe decir «no».
      *Sano:* `simple-scan`, `sane-airscan` y `evince` en `install ok installed`;
      `snap list snap-store` **la encuentra**; `gnome-software` **NO** está; y los
      tres dependientes de siempre en `apt-mark showauto`. *Roto:* cualquiera
      ausente, o `gnome-software` presente —eso son **dos** tiendas—, o alguno en
      `showmanual`. **Los dos controles que la hacen valer:** un `.deb` inventado
      tiene que salir «no encontrado» **y** un **snap** inventado también.
      **MARCADA sobre `encina-E4-tienda`:** los tres `.deb`, `snap-store rev
      1271`, `gnome-software` en `unknown ok not-installed`, 3 en `showauto` y
      `encina-meta` en `showmanual`
- [x] **EL USUARIO VE UNA SOLA TIENDA.** Casilla nueva del 2026-08-12, y es la
      que cierra D18. *Sano:* **1** tienda visible, y es «Centro de aplicaciones»;
      las aplicaciones visibles bajan de 28 a **27** y **se nombra cuál se fue**.
      *Roto:* 2 —la enfermedad que D18 nombra— o **0**, que sería haberse llevado
      las dos por delante. **El control que la convierte en casilla:** el contador
      tiene que saber decir **2, 1 y 0**, probado el día que se escribe.
      **MARCADA (§4.34f):** contada y **mirada** en la rejilla sobre el clon del
      nivel 1 —antes «Software» y «Centro de aplicaciones», después solo el
      segundo, y el bloque de catálogo de `gnome-software` desaparecido—, y
      contada por inventario en la instalación limpia: **27 visibles**, que
      **coinciden con las declaradas por adelantado**, y la que se fue nombrada:
      `org.gnome.Software.desktop`. ~~**Lo que esta casilla NO dice:** el `[OJOS]`
      está tomado sobre el **clon**, no sobre la instalación limpia~~
      **CERRADA DEL TODO EL 2026-08-13 (§4.35h): el `[OJOS]` ya está sobre la
      INSTALACIÓN LIMPIA**, `encina-E4-entrega`, y además nacida de la ISO
      corregida. La misma búsqueda «softw» en la rejilla da **Actualización de
      software · Programas y actualizaciones · Más controladores · Centro de
      aplicaciones** y **nada más** — ni «Software» ni su bloque de catálogo—,
      mirado en pantalla; y el contador dice **1**, con el control de que sabe
      decir **2** y **0**
- [x] **LA TIENDA ABRE Y SIRVE, que es la premisa de D17** `[OJOS]`. Casilla
      nueva del 2026-08-12, y se dice por qué no estaba antes: hasta ese día la
      tienda estaba instalada y **nadie la había abierto** (§4.33j), así que D17
      se apoyaba en un cheque sin cobrar. *Sano:* la ventana abre en arm64, carga
      catálogo, y **encuentra LibreOffice y Thunderbird**. *Roto:* no abre, o sale
      vacía → **D17 se queda sin sustento**. **MARCADA (§4.34c):** «Centro de
      aplicaciones», menú en español, catálogo con editores verificados, y los dos
      encontrados. **De propina y no era una casilla:** la tienda **no es solo de
      snaps** —ofrece «Paquetes de Debian» y con ese filtro encuentra
      `file-roller`, que no existe como snap—. **Lo que NO se midió:** que
      **instale**; nadie pulsó «Instalar».
      **REMEDIDA SOBRE LA INSTALACIÓN LIMPIA EL 2026-08-13 (§4.35i)**, que es
      donde antes solo estaba el clon: abierta **desde la rejilla**, ventana
      «Centro de aplicaciones», catálogo cargado, y encuentra `libreoffice`
      **por las dos vías** —«Paquetes snap» y «Paquetes de Debian»—, con su ficha
      diciendo `latest/stable 26.2.5.2`, confinamiento estricto y **1,17 GB** de
      descarga. **Y LA MITAD QUE SIGUE ABIERTA, ahora con motivo medido y no
      abandonada:** no se ha conseguido **pulsar** «Instalar». Cinco vías
      descartadas una a una —clic del anfitrión (**0 píxeles** cambian, comparado
      a nivel de píxel), `input scan code`/`input mouse click` de UTM, tabular
      hasta el botón (`Tab` **sí** llega y mueve el foco, pero no aterriza en él),
      la accesibilidad (árbol truncado del snap confinado, `timeout from dbind`)
      y las teclas del ratón de GNOME (desplazan la página)—. **Y NO se sustituyó
      por un `snap install` desde un terminal:** eso mide que `snapd` instala, no
      que la tienda instala, y sería otra medición con el nombre de ésta.
      **CERRADA EL MISMO DÍA, Y LA PULSÓ JORGE (§4.35i)** — igual que las dos
      últimas pantallas de E3 en §4.32h, y **no afloja la casilla**: lo que un
      `[OJOS]` prohíbe es una orden, un fichero o una edición, y no hubo ninguno.
      `snap changes` lo registra: **`Instalar snap "libreoffice"`, 08:12 → 08:22**.
      Las aplicaciones visibles pasan de **27 a 34** y **las siete que entraron van
      nombradas una a una**; la tienda **sigue siendo una**; el coste real, medido y
      no estimado: 1,17 GB declarados, `.snap` de 1,1 GB, **2 GiB** en el disco del
      invitado. **Y ABRE, desde la rejilla y en español:**
      `soffice.bin --writer`, ventana «Sin título 1 — LibreOffice Writer», barra de
      estado «Español (España)». La máquina entera: `verificar-instalacion.sh --visibles 34`
      como root, **51 correctas, 0 fallos**
- [x] **El manejador del PDF, atado, y medido en LAS DOS COLUMNAS.** *Sano:*
      `xdg-mime query default application/pdf` da el visor **con
      `XDG_CURRENT_DESKTOP=ubuntu:GNOME` y sin él**, y el fichero que manda es
      **nuestro** (`dpkg -S /etc/xdg/mimeapps.list` → `encina-branding`, R5).
      *Roto:* el navegador por alguna de las dos vías, o el fichero es de otro.
      **Una sola columna no vale**: §4.26c se midió por `ssh` y por eso el defecto
      parecía mayor de lo que era (§4.31d).
      **MARCADA, y con el roto reproducido sobre la propia máquina del producto:**
      apartando el fichero, la columna sin escritorio vuelve a `firefox.desktop`
      y la de `ubuntu:GNOME` se queda en Evince; restaurado, las dos dan Evince, y
      la máquina queda como estaba **por huella**. La mutación se verificó
      **antes** de leer nada (trampa 13)
- [x] **El `.deb` que viaja es `autofirma 1.9.1+encina4`** (`faeca3a9…`), elegido
      **por ruta entera y huella**. *Sano:* `dpkg-query` da `1.9.1+encina4`.
      *Roto:* cualquier otra — y no es un detalle: con `+encina2` o `+encina3`, un
      perfil de Snap delante desactiva la espera de 90 s (§4.29e, M20). **MARCADA**
- [x] **`+encina4` EN UNA MÁQUINA CON SNAP DE VERDAD**, que es lo único que §4.29
      dejó sin medir. *Sano:* con un perfil de Snap presente, la CA llega **sola**
      al perfil **nativo**, comparada **por huella sha256** contra la del paquete
      en disco. *Roto:* no llega, o llega con otra huella. Va sobre un **usuario
      nuevo y desechable**, como el `convivb` de §4.29e: crear el perfil de Snap
      en la cuenta del producto la pasaría al estado (d).
      **MARCADA (§4.31i):** perfil del Snap primero, nativo después, y la CA entra
      en el nativo **en 2 s** con huella idéntica; el servicio termina
      `Result=success`, o sea que el almacén de root de §4.29c **no ha vuelto**.
      **Lo que esta casilla NO dice:** no discrimina `+encina3` de `+encina4` —el
      almacén nativo apareció en 1 s y con un segundo ganan los dos—; eso lo
      discrimina M20, en contenedor
- [x] **Una instalación incompleta FALLA A LA VISTA** (nivel 2 de §4.27). *Sano:*
      con `ESTADO=COMPLETO` el guion sale 0 y la instalación termina bien.
      *Roto:* que salga 1 con la máquina entera. **El camino contrario está leído
      y no medido** (§4.31c): `subiquity` va a `ApplicationState.ERROR`, la
      máquina queda instalada y arrancable, y el registro se queda dentro.
      **PUESTO Y MARCADO**, y con un regalo: en la forma E2, *«la VM se apagó
      sola»* pasa a significar `ESTADO=COMPLETO`, sin abrir nada
- [x] **El medio lleva lo que hoy baja de internet** (nivel 3 de §4.27).
      **LA CASILLA ESTABA MAL ESCRITA, MEZCLABA DOS INCREMENTOS, Y EL 2026-08-13
      SE PARTE DE VERDAD: su mitad de E4 se cierra aquí y la otra SE VA A E3**
      (§6ter.3), que es donde le toca. *Por qué no es aflojarla:* E4 es «las
      aplicaciones de serie, como `Depends:` de `encina-meta`», y **el núcleo no
      es una aplicación de serie: es qué lleva el medio, que es E3**. Dejarla
      abierta aquí condenaba a E4 a no cerrarse nunca por algo que no decide.
      - [x] *La mitad que ES de E4, y se cierra:* el medio lleva **todo lo que
        necesita el seed** — los 24 paquetes de §4.31k, `hunspell-es` incluido,
        que **solo apareció porque el control preguntó** por qué no estaba en la
        cosecha. **Y sigue cerrada tras el cambio de tienda** (§4.34i): la
        instalación de `encina-meta` 0.2.1 salió del repositorio del medio y
        terminó con `ESTADO=COMPLETO`.
      - [→] *La mitad que NO es de E4:* **una instalación sin red no llega al
        seed**, porque el núcleo lo baja `curtin` de internet. **Movida a E3 el
        2026-08-13 como LÍMITE DECLARADO, con la forma de D9**, y no como
        pendiente: está **leída hasta el final** (§4.32), se sabe **qué** falta
        (el núcleo dentro del archivo indexado), **por qué** la vía obvia no vale
        (sin red `subiquity` borra las fuentes heredadas, así que la sección
        `apt:` existiría donde no hace falta), **cuánto** cuesta (**1 089 MB**
        medidos, con `linux-firmware` de 655 MB como `Depends:`) y **cuál es la
        salida**, nombrada y **no medida** (re-firmar el `dists/` del medio con
        clave propia, que viaja en `apt: sources: {key:}` y sobrevive al borrado
        porque va a `trusted.gpg.d`). **Es de Jorge decidir si se compra.**
        Ver `AGENTS.md` §6ter.3.
- [x] **[OJOS] Los nombres de las aplicaciones en español** (§4.26f). *Sano:*
      «Archivos», «Terminal», «Visor de documentos». *Roto:* en inglés, y
      entonces es un defecto de la familia de la novena casilla de E3. **Cuesta
      una captura**, y no vale una sesión `ssh`.
      **MARCADA (§4.31j), y §4.26f queda corregida: era el instrumento.** Lo que
      cambia la respuesta no son las variables de entorno sino **`setlocale()`**;
      sin él, un proceso contesta inglés aunque GLib ya vea `es`. Con el entorno
      real de `gnome-shell` las 28 salen en español, y **en pantalla**: el
      escritorio dice *«Le damos la bienvenida a Ubuntu 24.04.4 LTS»* y
      `simple-scan` abre como **«Escáner de documentos»** con **«No se detectó
      ningún escáner»** — que cierra de paso la mitad medible del escáner

- [x] **La ISO de E4 existe, arranca e instala.** *Sano:* `fabricar-iso.sh` en
      verde entero, el instalador **en español**, y la máquina que sale da
      **48 correctas, 0 fallos**. *Roto:* cualquier control de `fabricar-iso.sh`
      en rojo, o una máquina distinta de la de `encina-E4-meta`.
      **Y LA ISO A LA QUE SE REFIERE CAMBIÓ EL 2026-08-13 (§4.35):** es
      `encina-os-E4-es-0.2.1.iso` (`ac0a5721…`), porque `aa1ac76a…` llevaba dentro
      `encina-meta` **0.2.0**, o sea las dos tiendas. **Una ISO distinta es otro
      artefacto** —lo dice §6ter.3—, así que la casilla **se remarcó entera con la
      nueva**: `fabricar-iso.sh` en verde entero, y `encina-E4-entrega` instalada
      sola en 9 min con `REPO ELEGIDO -> /cdrom/encina-repo` y **51 correctas, 0
      fallos**. *Lo que la nueva NO rehace, y se dice:* el instalador en español y
      las cinco pantallas, que van en el `grub.cfg` y en el seed de dentro —ni uno
      ni otro han cambiado— y los cerró `encina-E4-cinco` con `aa1ac76a…`.
      ~~**MARCADA a medias, y se dice cuál mitad:**~~ **MARCADA ENTERA EL
      2026-08-12 (§4.32).** *Lo que ya estaba:* `encina-os-E4-es.iso`
      (`aa1ac76a…`) arranca, su instalador se ve en español, y una instalación
      desatendida con un `CIDATA` **sin repo dentro** deja
      `REPO ELEGIDO -> /cdrom/encina-repo`, 29 ficheros copiados y
      `ESTADO=COMPLETO` en **14 min 13 s**. *Lo que faltaba y hoy está*, sobre
      `encina-E4-cinco`, creada desde cero y **sin ningún `CIDATA`** —control de
      la trampa 16 recogido antes de arrancar: **0** `-append` y **dos** unidades,
      `media=disk` y `media=cdrom`—: el seed salió del **quinto sitio**
      (`CIDATA -> <no encontrado>`, `REPO ELEGIDO -> /cdrom/encina-repo`,
      `ESTADO=COMPLETO`) y **las cinco pantallas las nombra el propio
      instalador**, no una captura: `telemetry` da `keyboard, network, storage,
      identity, timezone` + `loading, confirm, install, done`, **sin `locale` ni
      `source`**. La máquina: **47 correctas y 2 fallos, los dos del verificador
      y corregidos** (§4.32g).
- [x] **[OJOS] LA FIRMA REAL SALE SOBRE LA FORMA (c).** **Casilla nueva, añadida
      el 2026-08-12 y marcada el mismo día**, y se dice por qué no estaba antes:
      D16 y D18 metieron el Snap al alcance del usuario, y hasta hoy **la única
      firma real del proyecto sobre una máquina con Snap era la de §4.13**, que
      salió con `+encina2`, sin tienda y sobre la máquina de E1 — o sea que E4 se
      apoyaba en un positivo de otra forma. *Sano:* «Fichero firmado
      correctamente» **mirado en pantalla** en `valide.redsara.es`, con
      certificado real, sobre un **clon efímero** de la máquina de E4, y con las
      tres cosas demostradas y no supuestas: el binario que corre está **fuera de
      `/snap/`**, la CA llega **sola** al perfil nativo comparada **por huella
      sha256**, y **la forma (c) sigue en pie después de firmar** (0 perfiles bajo
      `~/snap/`, revisión del Snap sin tocar). *Roto:* cualquier otra cosa en
      pantalla, o un `exe` bajo `/snap/`, o un perfil de Snap aparecido por el
      camino. **Va con certificado personal, así que es un experimento de un solo
      uso y la VM SE DESTRUYE** (`ENCINA-OS.md` §9.1): no deja estado bueno contra
      el que contrastar, y ninguna casilla futura puede pedirlo.
      **MARCADA (`MEDICIONES.md` §4.33):** `exe -> /usr/lib/firefox/firefox-bin`
      con el control de que la comprobación sabe decir `/snap/`; CA en el nativo
      en **2 s** con huella `73f752a4…` idéntica y `Result=success`; las seis
      barreras en el registro de AutoFirma y **10 s** de la URI a la firma; y la
      forma (c) intacta al terminar. La VM se destruyó y devolvió **2,008 GiB**

**Lo que NO es una casilla de E4, y conviene decirlo:** el número de aplicaciones
visibles. El control es que **el inventario sepa contar** (§4.19c), no que dé el
número que esperas; el número se declara por adelantado con `--visibles` y se
**contrasta**, y una diferencia obliga a **nombrar** cuál sobra o cuál falta, no
a fallar.

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
  firmar** está **en alcance desde el 2026-08-09**, con E2 abierto, y ya está
  medido (`MEDICIONES.md` §4.15); el firmado puede que no haga falta nunca
  (`ENCINA-OS.md` §8)
- Modificación de `/etc/os-release` (requiere `dpkg-divert`; paquete separado futuro)
- Construcción de imagen: `live-build`, `debos`, Cubic. **El `autoinstall.yaml`
  de E2 y el reempaquetado de la ISO oficial de E3 no son esto.** Los dos están
  **abiertos**: E2 terminado 6 de 6 (§6bis) y **E3 abierto el 2026-08-10**
  (§6ter). La frontera es exacta: E3 **reempaqueta** la imagen oficial y no toca
  ni uno de sus tres binarios firmados; **rehacerla** es E5, y sigue fuera
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
  `scripts/`, para la CI y para la receta de imagen. Las dieciocho trampas de
  `SCRIPTS.md` son catorce formas de que esto salga caro, y las nueve dan **falsos
  negativos o comprobaciones que no comprueban**. **La novena es del propio
  método** y se pagó abriendo E2: un control también necesita su señal de que
  llegó a ejecutarse.
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
