# Encina OS — Instrucciones de implementación para el agente

**Alcance de este documento:** tres paquetes, `encina-branding` (§4),
`encina-firefox-native` (§5) y `encina-doctor` (§6, fase B1, **abierta el
2026-08-07**). Todo lo demás (reparar AutoFirma, DNIe, locale, imagen ISO) queda
**fuera de alcance** y no debe implementarse ni prepararse aún.

**El alcance de B1 es estrecho a propósito: `encina doctor` diagnostica y no
repara.** Reparar es B2 y sigue fuera de alcance. **D13 no se toca:** ninguna de
las dos barreras se arregla desde `encina-firefox-native`, ni desde
`encina-doctor`, ni desde ningún otro paquete de la Etapa A.

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
española. Resolver esto ahora es **condición necesaria** para las fases futuras.

**Ese último párrafo es heredado y NO está medido.** Se arrastra desde la
investigación previa y nunca se comprobó en máquina propia. Lo medido el
2026-08-07 lo matiza: un `certutil` ejecutado fuera del sandbox **sí** escribe en
el `cert9.db` del perfil del Snap (`~/snap/firefox/common/.mozilla/firefox/`), y
de hecho hay una CA de AutoFirma dentro. Lo que el confinamiento impida leer
*desde dentro* del Snap es otra afirmación, distinta y sin medir. Está en la lista
de §6.8; hasta que se mida, no se construye nada encima.

**Corrección medida el 2026-08-07.** Este documento decía «elimina por adelantado
el obstáculo principal de fases futuras». Es falso, y se comprobó instalando el
`.deb` oficial de AutoFirma 1.9 en la VM: no lo elimina, **lo desplaza**.
AutoFirma no reconoce el perfil del Firefox nativo (`~/.config/mozilla/firefox/`)
ni lee `/etc/firefox/pref/`, así que sobre un sistema con Firefox nativo falla
*más* que sobre una Ubuntu de fábrica. Salidas literales en `ENCINA-OS.md` §4.1.
No cambia nada de lo que hay que implementar aquí: AutoFirma sigue fuera de
alcance (§7).

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

**Y tampoco hace que AutoFirma funcione. Léelo antes de añadir aquí una
preferencia de Firefox (D13).**

Esto no llegará como «voy a implementar AutoFirma» —eso ya lo para §7—. Llegará
como «añado una preferencia a `encina-firefox-native`», que suena a A2 y no
dispara ninguna alarma. Es la tentación concreta, y está medida en
`ENCINA-OS.md` §4.1:

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

## 6. Paquete `encina-doctor` (fase B1)

Fase abierta el 2026-08-07. Es el primer paquete de la Etapa B y el único que
esa etapa tiene abierto.

### 6.1 Qué hace y qué NO hace

**Hace:** una sola cosa. Ejecutar `encina doctor` como usuario normal, sin
`sudo`, y obtener una lista de obstáculos concretos para la firma electrónica en
esta máquina, cada uno con la evidencia literal que lo demuestra.

**No hace, y la lista es tan importante como la anterior:**

- **No repara nada.** Ni con `--fix`, ni con `--yes`, ni escondido tras una
  pregunta. Reparar es B2. Un `encina doctor` que repara no se puede probar, no
  se puede ejecutar dos veces, y no se puede recomendar a un usuario asustado.
- **No modifica el sistema.** Ni un fichero, ni un permiso, ni una base de datos
  NSS. Requisito verificable, no aspiración: ver §6.7. Tiene una trampa concreta
  y está en §6.4 (C4).
- **No instala nada**, ni AutoFirma, ni un JRE, ni `libnss3-tools`.
- **No arranca AutoFirma, ni Firefox, ni abre ningún socket.** Todo el
  diagnóstico de B1 es estáticamente decidible sobre ficheros en disco. Esto no
  es una limitación aceptada a regañadientes: es lo que hace que las
  comprobaciones se puedan probar (§6.5) y lo que permite ejecutarlas por ssh,
  sin sesión gráfica y sin tocar la pantalla del usuario.
- **No dice nunca que la firma funcione.** No puede saberlo: no existe ninguna
  máquina donde se haya visto funcionar (§6.5). Lo más fuerte que tiene derecho
  a decir es «no he encontrado ninguno de los obstáculos que sé buscar».
- **No requiere que AutoFirma esté instalado.** En una máquina sin AutoFirma,
  `encina doctor` sale con código 0 y marca `[OMIT]` con motivo todo lo que
  dependa de él. No es un fallo: es una máquina distinta.

### 6.2 Las dos barreras, traducidas a datos que se pueden leer

`ENCINA-OS.md` §4.1 mide dos barreras independientes. Toda la especificación
existe para detectarlas por separado, porque **arreglar la primera destapa la
segunda** y un diagnóstico que solo vea una produce una reparación que no repara.

| | Barrera | Enunciado medido | Dato en disco que la decide |
|---|---|---|---|
| **B-1** | Firefox no entrega el URI | La build de Mozilla no lee `/etc/firefox/pref/`, donde AutoFirma deja `Autofirma.js`, así que `network.protocol-handler.*.afirma` no existe para él | ¿Está esa preferencia en alguna ruta que **esta** build sí lee? |
| **B-2** | Firefox no confía en el socket | El socket es TLS: `CN=127.0.0.1` emitido por `CN=Autofirma ROOT`. El navegador tiene que confiar en esa CA | ¿Está esa CA, **por huella**, en el `cert9.db` del perfil que Firefox usa de verdad? |

**La segunda columna de B-2 se puede resolver sin arrancar nada.** Medido el
2026-08-07 sobre `encina-dev-firefox`: la CA viva está en
`/usr/lib/Autofirma/Autofirma_ROOT.cer`, y el par de claves del socket en
`/usr/lib/Autofirma/autofirma.pfx` (contraseña fija `654321`). La hoja del `.pfx`
valida contra esa CA y no contra ninguna otra:

```
$ openssl pkcs12 -in /usr/lib/Autofirma/autofirma.pfx -nokeys -passin pass:654321
subject=CN = 127.0.0.1     issuer=CN = Autofirma ROOT
notBefore=Aug  7 08:59:50 2026 GMT

$ openssl verify -CAfile <CA de /usr/lib/Autofirma/Autofirma_ROOT.cer>  <hoja>
OK
```

Es decir: el `openssl s_client` contra el socket vivo que hizo §4.1 se puede
reproducir **estáticamente**, y por tanto se puede convertir en comprobación.

### 6.3 Tres correcciones a §4.1, medidas el 2026-08-07, que cambian la especificación

Se documentan aquí y no solo en `ENCINA-OS.md` porque cada una invalida una
comprobación que parecía obvia.

**1. El campo mal escrito es `Recomends:`, no `Recoments:`.** `ENCINA-OS.md` §4
y §4.1 decían lo segundo. Medido:

```
$ dpkg -s autofirma | grep -iE "recom|depend"
Depends: libnss3-tools
Recomends: openjdk-17-jre
```

Una comprobación escrita contra la cadena documentada no habría disparado nunca.
**Consecuencia para la especificación:** C2 no busca la errata. Busca la ausencia
del hecho (§6.4).

**2. AutoFirma sí escribió en un perfil nativo. Escribió en el equivocado.**
§4.1 punto 4 decía que la CA va al perfil del Snap «y no en el del Firefox
nativo». Medido, hay tres perfiles y la CA está en dos:

```
~/.config/mozilla/firefox/cmnc3cx7.default-release   0 certificados   <- el que Firefox usa
~/.config/mozilla/firefox/ev2eu1nn.default           SocketAutoFirma  C,,
~/snap/firefox/common/.mozilla/firefox/297le6kh.default   SocketAutoFirma  C,,
```

`ev2eu1nn.default` tiene cuatro ficheros, ningún `compatibility.ini` y
`"firstUse": null`: **Firefox no lo ha abierto jamás.** Los dos ficheros de
control se contradicen, y ese es el fallo exacto:

```
profiles.ini:  [Profile1] Path=ev2eu1nn.default  Default=1
installs.ini:  [4F96D1932A9F858E] Default=cmnc3cx7.default-release  Locked=1
```

AutoFirma cree al primero; Firefox obedece al segundo. **Consecuencia:** «el
perfil» no existe en singular, y resolverlo por `Default=1` reproduce el bug que
se está diagnosticando. C3 lo resuelve por evidencia de uso (§6.4).

**3. La CA que hay en los perfiles no es la del socket.** Son certificados
distintos, los dos llamados `CN=Autofirma ROOT` y los dos con el apodo
`SocketAutoFirma`:

```
en los perfiles:            serial -21749C55   notBefore Aug  7 08:58:41
en disco y en el sistema:   serial -6D0BCF1F   notBefore Aug  7 08:59:50
sha256 del perfil:  E8:6F:D6:2D:...:86:51:0C:25
sha256 del disco:   4A:9F:CC:4C:...:85:5A:0B:09
$ openssl verify -CAfile <CA del perfil> <hoja del socket>
error 20 at 0 depth lookup: unable to get local issuer certificate
```

El log del configurador de la última ejecución explica por qué:

```
No se encuentran fichero de perfil de Mozilla, por lo que no se instalaran certificados
No se ha detectado un perfil de Mozilla Firefox en el que instalar el certificado
```

Las CA de los perfiles son residuo de una instalación anterior. **Consecuencia,
y es la más importante de las tres:** una comprobación que pregunte «¿hay un
certificado llamado `SocketAutoFirma` en el perfil?» responde **sí** sobre un
perfil que no puede validar el socket. Es exactamente el modo de fallo que este
repositorio ya ha pagado dos veces. **C4 compara huellas, nunca nombres.**

### 6.4 Comprobaciones: qué imprime cada una en sano y en roto

**Regla de admisión.** Una comprobación entra en esta tabla solo si se conocen
sus **dos** salidas. Si no se sabe qué diría en un sistema sano, no se
especifica: se anota en §6.8 y se mide primero. Tres candidatas obvias están en
§6.8 justamente por eso.

`M` = las dos salidas están medidas en máquina real. `C` = la salida sana es
construible con el control descrito en §6.5, y hay que grabarla antes de escribir
la comprobación.

| # | Pregunta | Cómo se decide | Sano | Roto (medido 2026-08-07) | |
|---|---|---|---|---|---|
| C1 | ¿Está AutoFirma instalado? | `dpkg-query -W -f='${Status}' autofirma` | `install ok installed` | rc≠0 → **todo lo demás pasa a `[OMIT]`, no a `[FALLO]`** | M |
| C2 | ¿Hay un JRE, y AutoFirma lo declara? | Dos líneas distintas. (a) `readlink -f "$(command -v java)"`. (b) `LC_ALL=C apt-cache depends autofirma` | (a) una ruta. (b) un JRE en la lista | (a) `openjdk 17.0.19` → `[OK]`. (b) solo `Depends: libnss3-tools` → `[FALLO]` | M |
| C3 | ¿Cuál es el perfil que Firefox usa **de verdad**? | Por evidencia de uso, **no** por `Default=1`: existe `compatibility.ini` **y** `times.json` tiene `firstUse` no nulo | exactamente uno por instalación | `cmnc3cx7.default-release` usado; `ev2eu1nn.default` con `firstUse: null` y sin `compatibility.ini` | M |
| C4 | ¿El perfil de C3 confía en la CA que el socket usará **hoy**? | huella SHA-256 de `/usr/lib/Autofirma/Autofirma_ROOT.cer` **==** huella de algún cert del `cert9.db`. Nunca por apodo | huellas iguales | perfil activo con 0 certificados → `[FALLO]` | C |
| C5 | ¿Firefox ve el esquema `afirma:`? | ¿está `network.protocol-handler.external.afirma` en `/usr/lib/firefox/defaults/pref/*.js`, `distribution/policies.json`, `distribution.ini` o el `prefs.js`/`user.js` del perfil de C3? | presente en una de esas | presente **solo** en `/etc/firefox/pref/Autofirma.js`, que esta build no lee → `[FALLO]` | C |
| C6 | ¿El manejador del sistema está puesto? | `xdg-mime query default x-scheme-handler/afirma`, y que el `.desktop` y su `Exec` existan | un `.desktop` existente | `afirma.desktop` → **`[OK]` hoy** | M |
| C7 | ¿Hay CA huérfanas de AutoFirma? | certs con `Subject == Issuer == CN=Autofirma ROOT` y huella **distinta** de la de C4 | ninguna | dos, huella `E8:6F:D6:…`, una en un perfil que Firefox nunca abrió | M |

**C6 sale verde, y por eso no se puede omitir.** Un diagnóstico que solo imprima
fallos borra el dato que separa las dos mitades del problema: el sistema operativo
entrega el URI y el navegador no. §4.1 tardó una sesión en establecerlo.

**C4 tiene una trampa de efectos secundarios.** `certutil -A` **crea** el
`cert9.db` si no existe: así es como `ev2eu1nn.default` acabó con una base de
datos. `certutil -L` no lo crea — medido sobre un directorio vacío:

```
$ certutil -L -d "sql:$(mktemp -d)"
certutil: function failed: SEC_ERROR_BAD_DATABASE
rc=255                      # y el directorio sigue vacío
```

Dos requisitos salen de ahí: **doctor solo usa `-L`**, y **`SEC_ERROR_BAD_DATABASE`
con rc=255 significa «este perfil no tiene almacén», que es `[OMIT]`, no
`[FALLO]`.** De regalo, esto explica el `SEC_ERROR_BAD_DATABASE` que §4.1 vio
salir del `prerm` de AutoFirma: su desinstalador apunta `certutil` a un perfil sin
base de datos.

### 6.5 Cómo se valida que una comprobación sirve

Las comprobaciones de `scripts/` se validaron **saboteando** un paquete: se coge
algo sano, se rompe, y se mira que la comprobación se ponga roja. Aquí no se
puede: **no existe ninguna máquina donde AutoFirma funcione**, así que no hay
caso positivo contra el que contrastar.

**La premisa es cierta, pero solo para una pregunta que doctor no hace.** No
existe caso positivo para *«¿puede firmar esta máquina?»*. Doctor no pregunta
eso: pregunta siete cosas locales e inspeccionables, y **cada una de las siete
sí tiene positivo**. Tres mecanismos, por orden de preferencia.

**(a) Positivo por construcción — reparar un eslabón, en la máquina rota, y
deshacerlo.** El sabotaje al revés. Se coge lo roto, se repara exactamente un
eslabón con una orden de usar y tirar —que **no** es el remedio que se
publicará—, se mira que esa comprobación y **solo** esa se ponga verde, y se
deshace. Para C4:

```
certutil -L -d sql:$PERFIL_ACTIVO                     # rojo: 0 certificados
certutil -A -d sql:$PERFIL_ACTIVO -n SocketAutoFirma -t "C,," \
         -i /usr/lib/Autofirma/Autofirma_ROOT.cer
certutil -L -d sql:$PERFIL_ACTIVO                     # verde
certutil -D -d sql:$PERFIL_ACTIVO -n SocketAutoFirma  # rojo otra vez
```

Esto no es implementar B2: son tres órdenes en una VM de pruebas, no código, no
paquete, no gancho. **La condición de «y solo esa» es la mitad del valor:** si al
poner la CA se mueve alguna otra línea, las comprobaciones están acopladas y una
de las dos no mide lo que dice.

**(b) Positivo por contraste — apuntar la misma comprobación a un hecho hermano
que hoy sí está sano.** Para cuando construir el positivo es caro o destructivo.
Dos casos reales:

- **C5.** La pregunta es «¿ve Firefox esta preferencia?». El positivo no necesita
  AutoFirma: `distribution.ini` contiene hoy `intl.locale.requested` y
  `browser.gnome-search-provider.enabled` en una ruta que Firefox **sí** lee. Si
  el lector de preferencias de doctor no encuentra esas dos, el roto es doctor.
- **C6.** §4.1 ya midió que el manejador del sistema funciona
  (`xdg-open afirma://…` arranca AutoFirma y se pone a escuchar). Hay positivo
  vivo para la mitad de sistema operativo en la misma máquina donde la mitad de
  navegador está roja.

**(c) Positivo por cálculo — cuando el hecho es criptográfico, las dos salidas se
obtienen sin tocar nada.** Ya medido, con cero efectos secundarios:

```
hoja = openssl pkcs12 -in /usr/lib/Autofirma/autofirma.pfx -nokeys -passin pass:654321
openssl verify -CAfile <CA viva del disco>     <hoja>   ->  OK
openssl verify -CAfile <CA huérfana del perfil> <hoja>   ->  error 20
```

Verde y rojo, los dos, en la máquina rota, sin instalar nada y sin modificar
nada.

**Aviso sobre el control negativo, y costó tres comandos descubrirlo.** El
negativo obvio —verificar sin almacén de confianza— **no es negativo**:

```
$ openssl verify -no-CAfile -no-CApath <hoja>
OK                                    # !!
$ openssl verify -no-CAfile -no-CApath -no-CAstore <hoja>
error 20 at 0 depth lookup: unable to get local issuer certificate
```

OpenSSL 3.x tiene un tercer origen de confianza, `-CAstore`, activo por defecto y
que lee `/etc/ssl/certs` — donde el `postinst` de AutoFirma dejó su CA. El
control negativo pasaba por la puerta de atrás. **La moraleja no es sobre
`openssl`:** un control negativo también hay que comprobarlo, y el negativo bueno
aquí es el de (c) —una CA *equivocada*—, que falla por el motivo correcto.

**La puerta dura que sale de todo esto.** Ninguna comprobación se publica sin un
**par de salidas literales grabadas, una verde y una roja, producidas las dos en
máquina real**, junto con la orden exacta que provocó cada estado. Se guardan en
`debian-packages/encina-doctor/pruebas/<id>.md`. Si el par verde no se puede
producir, la comprobación **no se publica**: no se ha medido nada, se ha escrito
una afirmación. Es la generalización literal de la moraleja de `SCRIPTS.md`:
*cuando una dé `[OK]`, comprueba que habría dado `[FALLO]` de haber estado mal.*

**Y la consecuencia sobre lo que doctor tiene derecho a decir.** Como el positivo
de extremo a extremo genuinamente no existe, **doctor no imprime nunca una línea
que signifique «puedes firmar»**. Eso no es prudencia: es que la afirmación no
está respaldada por ninguna medición de nadie.

### 6.6 Qué imprime, y cómo se distingue «no lo he comprobado»

**Se reutiliza el vocabulario de `SCRIPTS.md`**, sin inventar uno nuevo:

```
[OK]     comprobado y correcto
[FALLO]  comprobado e incorrecto, con la salida literal
[AVISO]  algo que mirar, no bloquea
[OMIT]   no se ha comprobado (no lo des por bueno)
[OJOS]   solo lo puedes verificar tú mirando la pantalla
```

**El motivo de reutilizarlo** es que los cinco estados ya cubren exactamente lo
que hace falta —`[OMIT]` incluido, que es la distinción cara— y ya están
validados contra fallos reales en dos fases. Un segundo vocabulario en el mismo
repositorio sería un impuesto de traducción a cambio de nada. Con **tres
enmiendas**, que sí son necesarias porque el lector cambia: los scripts los lee
el desarrollador, `encina doctor` lo lee un usuario asustado.

1. **`[OMIT]` obliga a dar motivo.** `[OMIT] <qué> — <por qué no se pudo>`. Un
   `[OMIT]` sin motivo es un fallo de la herramienta, no del sistema, y la
   definición de terminado lo trata como tal. «No comprobado» sin porqué es lo
   que ha salido caro en este repositorio.
2. **`[OJOS]` queda prohibido en B1.** Una comprobación que exige mirar la
   pantalla no se puede probar en regresión, y quien ejecuta doctor no sabe qué
   es `about:support`. Es un `[OMIT]` disfrazado de comprobación. La prohibición
   es sostenible porque las siete comprobaciones de §6.4 son estáticamente
   decidibles. Si alguna vez hace falta un `[OJOS]`, es señal de que la
   comprobación está mal planteada.
3. **Nada se calla.** Lo no comprobado se imprime como `[OMIT]`, no se omite del
   informe. El silencio se lee como «bien».

**El formato.** Cada línea lleva veredicto, qué se preguntó y —si no es `[OK]`—
la evidencia literal y qué significa para el usuario:

```
encina doctor 0.1.0
encina-dev · Ubuntu 24.04.4 LTS · aarch64 · usuario jorge · 2026-08-07 19:14

[OK]    Manejador del sistema para afirma:
        xdg-mime → afirma.desktop → /usr/bin/autofirma
[FALLO] Firefox no ve el esquema afirma:
        la preferencia solo está en /etc/firefox/pref/Autofirma.js
        y esta compilación de Firefox no lee ese directorio
        comprobado en: /usr/lib/firefox/defaults/pref/*.js, distribution.ini,
                       distribution/policies.json, prefs.js y user.js del perfil
        qué significa: al pulsar «Firmar», AutoFirma no llega a arrancar
[FALLO] El perfil activo no confía en la CA del socket de AutoFirma
        perfil activo: ~/.config/mozilla/firefox/cmnc3cx7.default-release
        CA que el socket usará: SHA256 4A:9F:CC:…:0B:09
        en el perfil: ningún certificado
[AVISO] Dos CA huérfanas de una instalación anterior (SHA256 E8:6F:D6:…:0C:25)
        ~/.config/mozilla/firefox/ev2eu1nn.default  (Firefox nunca lo ha abierto)
        ~/snap/firefox/common/.mozilla/firefox/297le6kh.default
[OMIT]  Chromium — no instalado, no comprobado
[OMIT]  Firefox en Flatpak — no instalado, no comprobado

2 obstáculos encontrados · 3 comprobaciones en verde · 2 sin comprobar
encina doctor no repara nada, y no puede afirmar que la firma funcione:
solo que no ha encontrado ninguno de los obstáculos que sabe buscar.
```

**La distinción «no lo he comprobado» / «lo he comprobado y está bien» no se
confía a una etiqueta: se confía a que las cuentas cuadren.** El resumen imprime
tres números y su suma tiene que ser igual al número de comprobaciones
declaradas. Una comprobación que se salta sin emitir línea rompe la suma y hace
que doctor salga con error propio. Una etiqueta se puede leer por encima; una
resta que no cuadra, no.

**Código de salida:** 0 si no hay ningún `[FALLO]`; distinto de 0 si hay alguno.
`[OMIT]` y `[AVISO]` no cambian el código, pero sí los números del resumen.

**`--json`** produce el mismo contenido en una estructura estable, con la huella,
la ruta y el estado de cada comprobación. Es el contrato con B2 —que consumirá
esta salida en lugar de rediagnosticar— y lo que hace que un informe de usuario
sea pegable. La forma humana y la JSON salen de la misma estructura: dos
generadores independientes se desincronizarían.

### 6.7 Definición de terminado

Ejecutar en VM. La primera casilla es la que decide si la fase vale.

- [ ] **Cada comprobación tiene su par grabado en
      `debian-packages/encina-doctor/pruebas/<id>.md`:** salida verde, salida
      roja, y la orden exacta que produjo cada estado. **Una comprobación sin par
      verde no se publica** (§6.5)
- [ ] **La prueba de la aguja, para C4:** tras `certutil -A` de la CA viva en el
      perfil activo, C4 pasa a verde y **ninguna otra línea del informe cambia**;
      tras `certutil -D`, vuelve a rojo. Las tres salidas, grabadas
- [ ] **La prueba del perfil, para C3:** con `Default=1` invertido a mano en
      `profiles.ini`, doctor **sigue eligiendo** el perfil que señala
      `compatibility.ini`. Si cambia de perfil, reproduce el bug de AutoFirma
- [ ] Sobre `encina-autofirma-rota`: imprime los dos `[FALLO]` de §6.4 y **ningún
      otro**, y sale con código ≠ 0
- [ ] Sobre `encina-A2-verificada` (sin AutoFirma): sale con **código 0**, todo lo
      dependiente de AutoFirma en `[OMIT]` **con motivo**, y **ninguna línea que
      signifique que la firma funciona**
- [ ] **No modifica nada.** `find $HOME/.config/mozilla $HOME/snap/firefox /usr/lib/Autofirma -newermt <t0>` está vacío tras ejecutarlo. Se comprueba también sobre un perfil **sin** `cert9.db`, que es donde `certutil` muerde
- [ ] Dos ejecuciones seguidas dan salida idéntica salvo la marca de tiempo (R9)
- [ ] La suma del resumen es igual al número de comprobaciones declaradas. Se
      comprueba forzando el salto de una: doctor debe salir con error propio
- [ ] `LANG=es_ES.UTF-8` y `LANG=C` producen el **mismo diagnóstico**. Es la
      trampa 2 de `SCRIPTS.md`: todo lo que consulte a apt o dpkg lleva `LC_ALL=C`
- [ ] Se ejecuta **sin `sudo`** y sin sesión gráfica (por ssh). Lo que necesite
      privilegios sale `[OMIT] requiere privilegios`, nunca un error
- [ ] Con el usuario `prueba` —que ya existe en la VM de A1— el diagnóstico es
      independiente del de `jorge`: los perfiles son por usuario
- [ ] `lintian` sin errores, y una entrada de matriz nueva en `build.yml`
- [ ] `encina doctor --json | python3 -m json.tool` no falla, y contiene los
      mismos veredictos que la salida humana

### 6.8 Lo que falta medir antes de escribir código

Ninguna de estas se da por buena, y las tres primeras bloquean su comprobación.

- **La salida sana de C4 y de C5.** Son las dos marcadas `C` en §6.4: hay que
  producirlas con los controles de §6.5 y grabarlas **antes** de escribir la
  comprobación, no después.
- **Que Firefox lea de verdad `/usr/lib/firefox/defaults/pref/`.** Está deducido
  de cómo se construye el paquete de Mozilla, **no medido**. §4.1 midió lo
  contrario —que **no** lee `/etc/firefox/pref/`— sobre un Firefox vivo, y esa
  medición no se traslada. Mientras no se mida, C5 puede dar `[FALLO]` con
  fundamento pero **no puede dar `[OK]`**.
- **Que `installs.ini` gane a `Default=1` de `profiles.ini`.** C3 no depende de
  ello —decide por evidencia de uso, que es un hecho observable— pero el informe
  no debe **explicar** el fallo con una regla que nadie ha comprobado.
- **El aislamiento NSS del Snap** (§1). Afirmado y nunca medido, y lo medido lo
  matiza.
- **El desinstalador vacío** (`/usr/lib/Autofirma/uninstall.sh`, 0 bytes) y el
  **log del configurador**. Los dos son datos buenos y ninguno tiene salida sana
  conocida, así que **no son comprobaciones**: como mucho `[AVISO]` informativo.
  El log vive además en `/var/tmp` y es de root: refleja la última ejecución de
  *cualquiera*, no la del usuario que ejecuta doctor.
- **Chrome y Chromium.** No instalados en ninguna VM. Hoy son `[OMIT]` honrados.

### 6.9 Lenguaje y empaquetado

**Python 3, en un `.deb` propio llamado `encina-doctor`, `Architecture: all`.**

**Por qué no bash, que es lo que hay hoy.** Las comprobaciones de `scripts/` son
«ejecuta una orden y busca una cadena». Estas no: hay que leer dos ficheros INI
con reglas de precedencia entre ellos (`profiles.ini` / `installs.ini`), leer
JSON (`times.json`), abrir almacenes NSS, comparar huellas X.509 y emitir JSON.
En bash todo eso es volver a texto y volver a analizarlo — y **tres de las cuatro
trampas de `SCRIPTS.md` son trampas de procesar texto en bash**: el SIGPIPE de
`grep -q`, la salida de apt traducida, y el `grep` que casa con los comentarios.
A eso se suma la de esta sesión: `grep -i afirma` **no** casa con
`SocketAutoFirma`, porque la subcadena es `oFirma`. Elegir bash aquí es elegir
repetir ese riesgo sobre un problema más difícil.

**Por qué no Rust ni Go.** Producen binarios por arquitectura: se pierde
`Architecture: all`, se mete una cadena de compilación en la CI y aparece el eje
arm64/amd64 que D9 ya señala como delicado. Para una herramienta cuyo trabajo
entero es leer ficheros, es coste sin contrapartida.

**Por qué Python 3 y no otra cosa.** No añade tiempo de ejecución nuevo. Medido
en la VM:

```
$ python3 -VV
Python 3.12.3
$ python3 -c "import cryptography, configparser, json, sqlite3"   # sin error
$ dpkg -l python3-cryptography libnss3-tools | grep ^ii
ii  python3-cryptography  41.0.7-4ubuntu0.4
ii  libnss3-tools         2:3.98-1ubuntu0.2
```

`Depends: python3 (>= 3.10), python3-cryptography, libnss3-tools`. **No
`Depends: autofirma`**: doctor tiene que arrancar y decir algo útil en una
máquina donde AutoFirma no está (§6.1). `libnss3-tools` sí, porque `certutil` es
la única vía a `cert9.db` que no implica reimplementar NSS.

**Dónde vive el binario:** `/usr/bin/encina`, con `doctor` como subcomando. El
nombre de la orden es `encina doctor` desde el primer día, aunque hoy solo haya
un subcomando, porque B2 añadirá `encina configure` y renombrar una orden que el
usuario ya ha escrito es peor que reservar el hueco.

**Lo que este paquete no puede contener, y hay que decirlo aquí porque es donde
llegará la tentación:** ningún fichero de preferencias de Firefox, ningún
`policies.json`, ningún certificado. **D13 cubre a `encina-doctor` igual que a
`encina-firefox-native`.** La barrera 1 cabría en este paquete tan fácilmente
como en aquel, y cerrarla sola sigue siendo peor que no cerrar ninguna, por el
mismo motivo: cambia un fallo con síntoma por uno sin él. Si una tarea pide
añadir aquí un remedio, **detente y remite a D13**.

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

- **Reparar** AutoFirma: `encina configure`, `autofirma-fix`, cualquier fichero
  de preferencias de Firefox, cualquier `policies.json`, cualquier certificado
  instalado por un paquete. Eso es B2 y **no está abierto**. **Esto incluye
  hacerlo desde `encina-firefox-native` y desde `encina-doctor` (D13).** Una de
  las dos barreras medidas cabría en cualquiera de los dos y pasaría lintian;
  cerrarla sola deja el sistema sin firmar y sin el aviso que hoy da. Detalle en
  §5.1, §6.9 y en `ENCINA-OS.md` §4.1
- **Diagnosticar** AutoFirma **sí está en alcance**, y solo eso: es §6, la fase
  B1, abierta el 2026-08-07. `encina doctor` lee y no escribe
- Certificados FNMT, DNIe, `opensc`, PKCS#11 como funcionalidad. Leer un almacén
  NSS para diagnosticarlo (§6) no es implementar PKCS#11
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

## 9. Ante la duda

- Si un nombre de paquete, ruta o clave de dconf no se puede verificar con un
  comando, **no lo inventes**: indícalo y pregunta.
- Si una comprobación de la «Definición de terminado» falla, no la marques como
  hecha ni la reformules: reporta el fallo con la salida literal del comando.
- Preferir la solución declarativa aunque sea más larga. Un `sed` en un
  `postinst` es aceptable solo donde el fichero pertenece a otro paquete (R5).
- **Antes de escribir una comprobación, responde a las dos preguntas: ¿qué
  salida daría en un sistema sano y qué salida en uno roto?** Si no sabes las
  dos, no la escribas: mídela primero, o anótala en §6.8. Vale para `scripts/` y
  vale para `encina doctor`.
