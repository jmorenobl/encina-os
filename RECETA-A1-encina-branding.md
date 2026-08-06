# Receta A1 — `encina-branding` construido, instalado y probado

**Para qué sirve este documento:** llegar desde «no hay nada» hasta «tengo un
`.deb` real instalado en una VM y las comprobaciones pasan». Nada más. Cuando
termines, y solo entonces, pasas a A2 (`encina-firefox-native`).

**Cómo está organizado:** siete sesiones de entre 30 y 60 minutos. Cada una
termina en un punto estable, con algo committeado. Puedes parar al final de
cualquiera sin dejar nada a medias.

**Regla de la noche:** si llevas 20 minutos atascado en el mismo error, anótalo
en el diario (ver «Ritual de cierre») y vete a dormir. El error seguirá ahí
mañana y lo verás en cinco minutos.

---

## Antes de empezar: una decisión de 30 segundos

Tu esqueleto tiene `noble` (Ubuntu 24.04) en el changelog. Desde abril de 2026
existe **Ubuntu 26.04 LTS**, que además ofrece imagen ARM de escritorio oficial
por primera vez.

**Recomendación: quédate en 24.04 para esta fase.** Es lo que asumen tus
documentos, es lo que tiene instalado la mayoría de gente a la que apuntas, y es
la versión sobre la que están documentados los fallos de AutoFirma que verás en
la Etapa B. Cambiar de base a mitad de la receta es lo único que te puede hacer
repetir trabajo.

Si decides 26.04, cámbialo **ahora**, en la sesión 0, no después: hay que tocar
la suite del changelog (`noble` → `resolute`) y descargar otra ISO.

---

## Sesión 0 — Descargas y decisiones (15 min, se puede hacer viendo la tele)

**Objetivo:** dejar las descargas corriendo para que la sesión 1 no empiece
esperando 3 GB.

1. **UTM.** Si no lo tienes:
   ```
   brew install --cask utm
   ```
   (o descárgalo de `https://mac.getutm.app/`)

2. **La ISO.** Ubuntu 24.04 de escritorio para ARM no aparece en la página de
   descargas principal; está en cdimage:
   ```
   https://cdimage.ubuntu.com/releases/24.04/release/ubuntu-24.04.4-desktop-arm64.iso
   ```
   Son 3,3 GB. Déjalo descargando.

3. **Busca el esqueleto.** Necesitas el `encina-branding.tar.gz` que ya
   generamos. Búscalo en `~/Downloads`. Si no aparece, no pasa nada: pídemelo y
   lo regenero, pero descúbrelo hoy y no el día que te sientes a construir.

4. **Homebrew tiene `gh`** (el cliente de GitHub). Instálalo ya, lo usarás en la
   sesión 7:
   ```
   brew install gh
   ```

**Ritual de cierre:** nada que committear todavía.

---

## Sesión 1 — La máquina virtual (60 min, casi todo es esperar)

**Objetivo:** una VM Ubuntu arm64 funcionando y accesible por SSH desde el
Terminal del Mac.

**Por qué SSH:** trabajar dentro de la ventanita de UTM a la una de la mañana es
horrible — no funciona el copiar y pegar y el ratón se queda capturado. Con SSH
usas el Terminal del Mac de siempre y pegas los comandos de esta receta
directamente.

### Pasos

1. **Crear la VM en UTM.**
   - `+` → **Virtualizar** → **Linux**
   - Marca *Apple Virtualization* si te lo ofrece
   - **Browse** → selecciona la ISO descargada
   - CPU: 4 núcleos · Memoria: 8 GB · Disco: 64 GB
   - Nombre: **`encina-dev`**

2. **Instalar Ubuntu.** Instalación normal, «borrar disco completo» (es virtual).
   - Usuario: el que quieras, en esta receta lo llamo `jorge`
   - Anota la contraseña donde sea, la vas a escribir mucho

3. **Al terminar, apaga la VM** (no «reiniciar»). En UTM: Configuración →
   Unidades → el CD/DVD → **Clear / Eject**. Si no lo haces, vuelve a arrancar el
   instalador.

4. **Arranca, abre un terminal dentro de la VM y actualiza:**
   ```
   sudo apt update && sudo apt full-upgrade -y
   sudo reboot
   ```

5. **Instala SSH y averigua la IP:**
   ```
   sudo apt install -y openssh-server
   hostname -I
   ```
   Te dará algo tipo `192.168.64.7`. Anótala.

6. **Desde el Terminal del Mac:**
   ```
   ssh jorge@192.168.64.7
   ```
   A partir de aquí, todo lo demás se hace desde esta ventana.

7. **Opcional pero muy recomendable** (te ahorra escribir la contraseña cada
   vez), desde el Mac:
   ```
   ssh-copy-id jorge@192.168.64.7
   ```

### Cómo sabes que ha ido bien

`ssh` entra sin errores y `lsb_release -a` dentro de la VM dice `24.04`.

### Si falla

- **No hay IP con `hostname -I`:** en UTM, Configuración → Red → modo
  **Shared Network**. Reinicia la VM.
- **La IP cambia entre arranques:** es normal con DHCP. Vuelve a mirarla con
  `hostname -I`. Si te molesta, más adelante puedes fijarla, pero no es
  prioritario.

### Ritual de cierre

Anota la IP y el nombre de usuario en tu ENCINA-OS.md.

---

## Sesión 2 — Repositorio y esqueleto (40 min)

**Objetivo:** el repositorio git creado **dentro de la VM**, con el esqueleto
dentro, y un primer commit.

**Por qué dentro de la VM y no en el Mac:** ahí están `dpkg-buildpackage`,
`lintian` y `debhelper`. Tener el código en un sitio y las herramientas en otro
te obliga a copiar ficheros de un lado a otro en cada iteración, y a las tantas
de la noche acabas construyendo una versión antigua sin darte cuenta. La copia
de seguridad la da GitHub en la sesión 7.

### Pasos

1. **Herramientas** (dentro de la VM, por SSH):
   ```
   sudo apt install -y git devscripts debhelper lintian dpkg-dev \
                       imagemagick librsvg2-bin
   ```

2. **Identidad de git y de los paquetes:**
   ```
   git config --global user.name  "Jorge Moreno"
   git config --global user.email "TU@CORREO.REAL"

   echo 'export DEBFULLNAME="Jorge Moreno"'      >> ~/.bashrc
   echo 'export DEBEMAIL="TU@CORREO.REAL"'       >> ~/.bashrc
   source ~/.bashrc
   ```
   Ese correo acaba dentro del paquete, en el campo `Maintainer`. Usa uno real:
   `lintian` da error si detecta una dirección inventada.

3. **Estructura:**
   ```
   mkdir -p ~/encina/debian-packages ~/encina/.github/workflows
   cd ~/encina
   git init
   ```

4. **Traer el esqueleto.** Desde el **Terminal del Mac**, en otra pestaña:
   ```
   scp ~/Downloads/encina-branding.tar.gz jorge@192.168.64.7:~/
   ```
   Y de vuelta en la VM:
   ```
   cd ~/encina/debian-packages
   tar xzf ~/encina-branding.tar.gz
   ```

5. **Verifica que el árbol es el que debe ser:**
   ```
   find ~/encina/debian-packages/encina-branding -type f | sort
   ```
   Contrástalo con la tabla 4.1 de AGENTS.md. Deben estar los ocho
   ficheros de `src/` más `debian/{control,changelog,copyright,rules,postinst,prerm,postrm}`.
   **Si falta algo, párate aquí y pregúntame.** No lo improvises de madrugada.

6. **Corrige el correo del mantenedor** en `debian/control` (el esqueleto trae un
   marcador de posición):
   ```
   nano debian-packages/encina-branding/debian/control
   ```

7. **`.gitignore`** en la raíz del repositorio:
   ```
   cat > ~/encina/.gitignore << 'EOF'
   debian-packages/*.deb
   debian-packages/*.buildinfo
   debian-packages/*.changes
   debian-packages/*/debian/encina-*/
   debian-packages/*/debian/files
   debian-packages/*/debian/*.substvars
   debian-packages/*/debian/*.debhelper
   debian-packages/*/debian/debhelper-build-stamp
   EOF
   ```
   Fíjate en que **no** excluye nada de `src/`: los fondos y el logotipo sí van
   al repositorio, aunque sean binarios. Son pequeños y son parte del producto.

8. **Licencia.** El proyecto es EUPL v1.2. Guarda el texto oficial como
   `~/encina/LICENSE` (lo encuentras buscando «EUPL 1.2» en
   `joinup.ec.europa.eu`). Si no lo localizas en dos minutos, deja el fichero con
   una línea que diga `EUPL-1.2 — texto pendiente` y sigue. No bloquea nada.

9. **Primer commit:**
   ```
   cd ~/encina
   git add -A
   git commit -m "Esqueleto inicial de encina-branding"
   ```

### Cómo sabes que ha ido bien

`git log --oneline` muestra un commit y `git status` sale limpio.

---

## Sesión 3 — Activos mínimos (30 min)

**Objetivo:** sustituir los marcadores de posición por ficheros reales. No tienen
que ser bonitos. Tienen que **existir y tener el formato correcto**, porque lo
que estás probando esta semana es la fontanería, no el diseño.

### Pasos

```
cd ~/encina/debian-packages/encina-branding/src/usr/share/backgrounds/encina
```

1. **Fondo claro** — degradado verde encina:
   ```
   magick -size 3840x2160 gradient:'#5B7553-#2F4033' -quality 92 encina.jpg
   ```

2. **Fondo oscuro** — el mismo tono, mucho más apagado:
   ```
   magick -size 3840x2160 gradient:'#1E2A22-#0D120F' -quality 92 encina-dark.jpg
   ```

3. **Logotipo para Plymouth**, PNG con transparencia, a partir del SVG que ya
   incluye el esqueleto:
   ```
   rsvg-convert -w 200 -h 200 \
     ../../icons/hicolor/scalable/apps/encina-logo.svg -o logo.png
   ```

4. **Comprueba que son lo que dicen ser:**
   ```
   file encina.jpg encina-dark.jpg logo.png
   ```
   Espera ver `JPEG image data` en los dos primeros y `PNG image data ... RGBA`
   en el tercero. **El `RGBA` importa**: si sale `RGB` a secas, el PNG no tiene
   transparencia y el logotipo saldrá con un cuadrado de fondo sobre el splash.

5. **Commit:**
   ```
   cd ~/encina && git add -A && git commit -m "Activos mínimos de branding"
   ```

### Si falla

- `magick: command not found` → en algunas versiones el binario es `convert`.
  Prueba `convert` con los mismos argumentos.
- `rsvg-convert` falla → falta `librsvg2-bin` (sesión 2, paso 1).

---

## Sesión 4 — Primer build y `lintian` (45–60 min, la más impredecible)

**Objetivo:** un fichero `.deb` que existe y que `lintian` acepta sin errores.

Ojo: esta es la sesión que se puede alargar, porque `lintian` es quisquilloso y
te va a sacar cosas. Son todas de arreglo rápido, pero pueden ser varias
seguidas.

### Pasos

1. **Construir:**
   ```
   cd ~/encina/debian-packages/encina-branding
   dpkg-buildpackage -us -uc -b
   ```
   Las opciones significan: `-us` no firmar el fuente, `-uc` no firmar el
   `.changes`, `-b` solo binario (no generar tarball de fuentes).

2. **Dónde queda el resultado.** En el **directorio padre**:
   ```
   ls -l ~/encina/debian-packages/*.deb
   ```
   Esto sorprende la primera vez. Es el comportamiento normal de Debian, no un
   error.

3. **Mirar dentro antes de instalar nada** (es gratis y te ahorra un reinicio):
   ```
   dpkg -c ~/encina/debian-packages/encina-branding_*.deb
   ```
   Deben aparecer las rutas de la tabla 4.1, todas colgando de `/usr` y `/etc`.
   Si ves `/home` o rutas raras, el `override_dh_auto_install` está mal.

4. **La puerta de calidad:**
   ```
   lintian --fail-on error ~/encina/debian-packages/encina-branding_*.deb
   ```

5. **Commit** cuando pase:
   ```
   cd ~/encina && git add -A && git commit -m "Primer build limpio"
   ```

### Errores de `lintian` que vas a ver, con su traducción

| Lo que dice | Qué significa | Arreglo |
|---|---|---|
| `maintainer-address-malformed` | El correo sigue siendo el de ejemplo | Edita `debian/control` |
| `no-copyright-file` | Falta `debian/copyright` o no es DEP-5 válido | Revisa el formato |
| `extended-description-too-short` | La descripción del paquete es de una línea | Añade párrafo con sangría de un espacio |
| `changed-by-address-malformed` | Falta `DEBEMAIL`/`DEBFULLNAME` | Sesión 2, paso 2, y `dch -r ''` |
| `unstripped-binary-or-object` | No debería salirte: no hay binarios | Si sale, se ha colado algo en `src/` |

**Distinción importante:** `E:` es error y bloquea. `W:` es aviso. Los avisos hay
que leerlos y decidir, pero no te impiden seguir esta noche. Anota en el diario
los que dejes pendientes.

### Si falla el build entero

Lee **la primera línea de error**, no la última. `dpkg-buildpackage` escupe mucho
ruido después del fallo real.

---

## Sesión 5 — Instalar y reiniciar (40 min)

**Objetivo:** el paquete instalado, el tema de arranque activo, y tu logotipo
saliendo al arrancar.

### Antes que nada: la red de seguridad

Esta es la primera sesión en la que puedes dejar la VM en mal estado (GDM que no
arranca, initramfs roto). Cinco minutos ahora te ahorran reinstalar Ubuntu
entero:

1. Apaga la VM: `sudo poweroff`
2. En UTM, clic derecho sobre `encina-dev` → **Clonar**
3. Llama al clon **`encina-limpia-respaldo`** y **no lo toques nunca más**
4. Arranca `encina-dev` y sigue

### Pasos

1. **Instalar:**
   ```
   cd ~/encina/debian-packages
   sudo apt install ./encina-branding_*.deb
   ```
   Fíjate en el `./` inicial: sin él, apt busca un paquete llamado
   «encina-branding» en los repositorios y falla.

2. **Verificar el tema de Plymouth sin reiniciar:**
   ```
   update-alternatives --display default.plymouth
   ```
   Debe aparecer tu ruta `/usr/share/plymouth/themes/encina/encina.plymouth`
   con prioridad 200 y marcada como la actual.

3. **La comprobación que de verdad predice si verás el logotipo** (R7 en tus
   reglas — el tema viaja *dentro* del initramfs):
   ```
   sudo lsinitramfs /boot/initrd.img-$(uname -r) | grep encina
   ```
   Si esto no devuelve nada, **no reinicies todavía**: el `update-initramfs -u`
   del `postinst` no se ha ejecutado o ha fallado. Fuérzalo a mano:
   ```
   sudo update-initramfs -u
   ```
   y vuelve a comprobar. Si sigue vacío, el fallo está en cómo el `postinst`
   registra el tema.

4. **GRUB:**
   ```
   grep GRUB_DISTRIBUTOR /etc/default/grub
   ```
   Una sola línea, con `"Encina OS"`.

5. **Reiniciar y mirar la ventana de UTM:**
   ```
   sudo reboot
   ```
   Verás, en orden: el menú de GRUB diciendo Encina OS → el splash con tu
   logotipo → la pantalla de GDM con tu logotipo → el escritorio con tu fondo.

### Si falla

| Síntoma | Causa probable |
|---|---|
| Arranque idéntico al de antes | El tema no está en el initramfs (paso 3) |
| Sale el logotipo del fabricante | El tema hereda de `bgrt` en vez de `spinner` (R6) |
| El splash pasa tan rápido que no lo ves | Normal en VM. Vale con las comprobaciones de los pasos 2 y 3 |
| GDM sin logotipo | Falta `dconf update` en el `postinst`, o el perfil no está en `/etc/dconf/db/gdm.d/` |
| El escritorio sigue con el fondo de Ubuntu | **No es concluyente**: tu usuario ya existía. Es exactamente lo que resuelve la sesión 6 |

### Si la VM no arranca

Apágala, arranca el clon `encina-limpia-respaldo`, y anota qué hiciste. No
pierdas la noche reparando el initramfs.

---

## Sesión 6 — Las pruebas que de verdad importan (45 min)

**Objetivo:** demostrar que el paquete cumple R1, R9 y que se puede desinstalar.
Esta es la sesión que separa «parece que funciona» de «funciona».

### 6.1 — Usuario nuevo (esta es *la* prueba)

Un `gschema.override` aplica a todo el mundo. `/etc/skel` solo a los usuarios
creados después, y no se puede actualizar. Si te has equivocado y has usado
`/etc/skel`, la única forma de descubrirlo es esta:

```
sudo useradd -m -s /bin/bash prueba
sudo passwd prueba
```

Comprobación rápida por consola, sin cerrar sesión:
```
sudo -u prueba gsettings get org.gnome.desktop.background picture-uri
sudo -u prueba gsettings get org.gnome.desktop.background picture-uri-dark
```
Los dos deben devolver rutas a `/usr/share/backgrounds/encina/`. **Los dos.** Si
el segundo devuelve el fondo de Ubuntu, te falta `picture-uri-dark` y quien use
modo oscuro verá el fondo que no es.

Después, la comprobación de verdad: cierra sesión, entra en GNOME como `prueba`,
y mira el escritorio.

### 6.2 — Idempotencia (R9)

```
cd ~/encina/debian-packages
md5sum /etc/default/grub
for i in 1 2 3 4 5; do
  sudo apt install -y --reinstall ./encina-branding_*.deb || { echo "FALLO EN $i"; break; }
done
md5sum /etc/default/grub
grep -c GRUB_DISTRIBUTOR /etc/default/grub
```

Los dos `md5sum` deben coincidir, y el `grep -c` debe decir **`1`**. Si dice `5`,
el `sed` del `postinst` está añadiendo la línea en vez de sustituirla: es el
fallo de idempotencia clásico y es real, aunque no se note a simple vista.

### 6.3 — Desinstalación limpia

```
sudo apt purge -y encina-branding
update-alternatives --display default.plymouth
grep GRUB_DISTRIBUTOR /etc/default/grub
```

El tema por defecto debe volver a ser el de Ubuntu. Reinicia una vez para
confirmar que el sistema arranca con el aspecto original.

Luego reinstala, que lo quieres puesto:
```
sudo apt install ./encina-branding_*.deb
```

### Ritual de cierre

Marca en ENCINA-OS.md las casillas de la sección «Terminado cuando» que hayas
pasado — **solo las que hayas pasado de verdad**, con el comando ejecutado.

---

## Sesión 7 — GitHub e integración continua (40 min)

**Objetivo:** el código fuera de la VM y un build automático en cada push.

### Pasos

1. **Autenticarse** (dentro de la VM):
   ```
   gh auth login
   ```
   Si `gh` no está: `sudo apt install -y gh`.

2. **Crear el repositorio, privado:**
   ```
   cd ~/encina
   gh repo create encina --private --source=. --remote=origin --push
   ```
   Privado a propósito: publicar activa expectativas de mantenimiento (D5). Ya
   lo abrirás cuando quieras.

3. **El flujo de trabajo:**
   ```
   cat > ~/encina/.github/workflows/build.yml << 'EOF'
   name: build

   on: [push, pull_request]

   jobs:
     build:
       runs-on: ubuntu-latest
       strategy:
         matrix:
           package: [encina-branding]
       steps:
         - uses: actions/checkout@v4

         - name: Instalar dependencias de construcción
           run: |
             sudo apt-get update
             sudo apt-get install -y devscripts debhelper lintian

         - name: Construir
           working-directory: debian-packages/${{ matrix.package }}
           run: dpkg-buildpackage -us -uc -b

         - name: Lintian
           working-directory: debian-packages
           run: lintian --fail-on error ${{ matrix.package }}_*.deb

         - uses: actions/upload-artifact@v4
           with:
             name: ${{ matrix.package }}-deb
             path: debian-packages/*.deb
   EOF

   cd ~/encina
   git add -A && git commit -m "CI: construir y validar los paquetes" && git push
   ```

4. **Mirar el resultado:**
   ```
   gh run watch
   ```

### Dos notas

- **El runner es amd64 y tu VM es arm64.** No es problema: ambos paquetes son
  `Architecture: all`, sin binarios compilados. Es justamente por eso que la CI
  puede ser tan simple en esta fase.
- **Ninguna clave de firma en el runner.** La firma del repositorio APT es de la
  fase A4 y no se toca ahora.

---

## Ritual de cierre (los tres minutos que salvan el proyecto)

Al terminar **cada** sesión, sin excepción:

1. Añade una línea al final de ENCINA-OS.md, en un apartado «Diario»:
   ```
   2026-08-04 — Sesión 4 hecha. .deb construido. lintian limpio salvo
   W:extended-description. Siguiente: sesión 5, clonar VM antes de instalar.
   ```
2. `git add -A && git commit -m "..."` aunque esté a medias.
3. Cierra el portátil.

El objetivo de esa línea no es documentar. Es que dentro de nueve días, cuando
vuelvas del trabajo agotado, no tengas que reconstruir en tu cabeza dónde
estabas. Leer una frase es gratis; reconstruir contexto cuesta media hora y es
lo que hace que los proyectos de una sola persona se mueran.

---

## Terminado cuando (copia de ENCINA-OS.md § 7)

- [ ] `lintian` sin errores
- [ ] Logotipo propio en arranque, GDM y escritorio
- [ ] Usuario creado *después* de instalar hereda el fondo — claro **y** oscuro
- [ ] Cinco reinstalaciones sin cambio de estado (`grep -c` devuelve 1)
- [ ] `apt purge` restaura el tema de arranque original
- [ ] CI verde en GitHub Actions

Entonces, y solo entonces, A2.

---

## Cosas que NO vas a hacer esta semana

Aunque se te ocurran a las once de la noche y parezcan de cinco minutos:
AutoFirma, `os-release`, `encina-locale-es`, la ISO, temas de iconos, la GUI.
Están en la sección 8 de ENCINA-OS.md por una razón. Si se te ocurre una idea
buena, apúntala en el diario y sigue.
