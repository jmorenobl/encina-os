# Scripts de Encina OS

Catorce scripts. Se ejecutan en orden. Cada uno termina diciéndote cuál viene
después, y ninguno da nada por bueno sin comprobarlo.

## Orden

### Comunes y de `encina-branding`

| Script | Qué hace | Dónde |
|---|---|---|
| `00-entorno.sh "Nombre" "correo"` | Instala herramientas, configura git y DEBEMAIL | VM |
| `01-repo.sh [tar.gz]` | Crea ~/encina, coloca el esqueleto, verifica el árbol | VM |
| `02-activos.sh [--forzar]` | Genera fondos y logotipo, verifica formatos | VM |
| `03-construir.sh` | **Reglas duras** + build + lintian | VM y CI |
| `04-instalar.sh` | Instala y comprueba todo lo verificable sin reiniciar | VM |
| `05-verificar.sh` | Usuario nuevo, idempotencia x5, purga | VM |
| `06-ci.sh` | GitHub Actions y repositorio remoto | VM |
| `diario.sh "texto"` | El ritual de cierre en un comando | VM |

### De `encina-firefox-native`

| Script | Qué hace | Dónde |
|---|---|---|
| `07-firefox-construir.sh` | Huella de la clave, **reglas duras**, build + lintian | VM y CI |
| `08-firefox-instalar.sh` | Instala, `apt update`, anclaje, idioma, Firefox nativo | VM |
| `09-firefox-verificar.sh` | **`full-upgrade` x2**, idempotencia x5, purga | VM |

Son scripts aparte y no una generalización de 03/04/05 a propósito: aquellos
están validados contra `encina-branding` y no se tocan. Lo único que comparten
es `lib.sh`, donde `PKG_DIR` acepta ahora el nombre del paquete y sigue
devolviendo `encina-branding` cuando no se le pasa ninguno.

`07` se detiene sin construir nada si la huella de la clave de firma de Mozilla
no coincide con `35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3`. La huella está
escrita a mano dentro del script: leerla del fichero que se quiere validar no
validaría nada.

### De `encina-meta`

| Script | Qué hace | Dónde |
|---|---|---|
| `10-meta-construir.sh` | **Reglas duras** + build + lintian | VM y CI |
| `11-meta-instalar.sh` | **La secuencia de tres órdenes**, paso a paso | VM |
| `12-meta-verificar.sh` | Idempotencia x5, purga, `autoremove` | VM |

Mismo motivo que antes para que sean aparte: 03/04/05 y 07/08/09 están
validados contra sus paquetes y no se tocan.

`10` **se detiene sin construir nada si no hay `debian/changelog`**, y no lo
crea él: imprime la orden `dch --create` y para. El changelog se gestiona con
`dch` y en la VM (`AGENTS.md` §3), así que el paquete se escribe en el Mac sin
él a propósito. Su comprobación de R10 tiene una forma concreta: extrae los
campos de dependencia con sus líneas de continuación y mira **solo ahí**, porque
la `Description` de este paquete explica largamente por qué no declara Firefox y
un `grep firefox` a secas lo acusaría de hacer justo lo que documenta que no
hace (trampa 3). Lleva además dos controles: uno que inyecta un `firefox` y
comprueba que la comprobación salta, y otro que verifica que la extracción no se
está comiendo la `Description`. Las tres reglas —R10, sin ficheros propios, sin
scripts de mantenedor— se validaron saboteando el paquete, y cada una la
detectan **dos** comprobaciones independientes: una sobre el árbol de fuentes y
otra sobre el `.deb` construido.

**`11` creció el 2026-08-08, después de que su forma anterior costara una sesión
entera** (`MEDICIONES.md` §4.12a). Dos cosas:

- **Ahora imprime los avisos de los scripts de mantenedor.** Antes guardaba la
  salida de apt en una variable y solo la enseñaba si apt fallaba. El `postinst`
  de `autofirma` avisó de que no había ningún perfil de Mozilla y **dio la orden
  exacta para arreglarlo**, apt salió con 0, y nadie lo vio. Un aviso que nadie
  ve no es un aviso. Lleva su control: un aviso literal de aquel día contra el
  que se comprueba que el filtro sabe decir que sí.
- **Y comprueba la CA del socket en el perfil de Firefox, por huella.** Sin ella
  la firma no sale aunque todo lo demás esté en verde. Tres salidas, las tres con
  su significado escrito: sin perfil todavía (`[OMIT]`, es lo normal en una
  máquina virgen), con perfil y sin CA (`[FALLO]`, es el defecto), y con una CA
  de apodo correcto pero huella distinta (`[FALLO]`, que es una instalación
  anterior). Solo usa `certutil -L`, nunca `-A`, por la trampa 7.

**Y esa sección cambió otra vez el 2026-08-09, cuando el defecto se cerró en
`encina-autofirma`.** Aquello obligaba a un cuarto paso manual, `sudo
dpkg-reconfigure autofirma`; `autofirma 1.9.1+encina2` trae un vigilante de
systemd de usuario que instala la CA cuando el perfil aparece, y la secuencia
volvió a ser de tres órdenes (`MEDICIONES.md` §4.12a, enmienda). **Lo delicado no
era quitar el consejo manual, era no quitarlo de más:** este script tiene que
seguir diciendo la verdad sobre una máquina con el paquete viejo o sin systemd de
usuario, donde la CA no llega sola. Por eso pregunta primero por el vigilante
(`vigilante_estado` en `lib.sh`) y da el consejo manual solo a quien lo necesita.
**Los cuatro estados están medidos antes de escribir el mensaje** —por ssh sobre
`encina-E1-vigilante`, 2026-08-09— y la comprobación sabe dar las cuatro
respuestas:

| estado | cuándo | `is-active` | rc |
|---|---|---|---|
| `armado` | paquete `+encina2`, sesión sana | `active` | 0 |
| `dormido` | unidad presente, sesión abierta antes de instalar | `inactive` | 3 |
| `ausente` | la unidad no está: `autofirma` viejo | `inactive` | 4 |
| `sin-bus` | sin systemd de usuario alcanzable | `Failed to connect to bus` | 1 |

Decide con **dos señales independientes** y no con el código de retorno: que el
fichero de la unidad exista —lo instala el paquete nuevo, y solo él— y que
`is-active` diga literalmente `active`. Los rc 3 y 4 se midieron y están escritos
en `lib.sh`, pero distinguir «no armada» de «no existe» por un número de retorno
es más frágil que mirar el fichero.

`11` es el que enseña la secuencia. Comprueba lo que debe verse **y lo que no**:
que el paso 1 no toque Firefox —si lo tocara, alguien ha declarado `firefox` y
hay que parar—, que tras el paso 2 el candidato salga de Mozilla con prioridad
1000, y que tras el paso 3 la versión instalada **no lleve epoch**, que es lo
que distingue el deb de Mozilla del de transición al Snap. Lleva `-y
--allow-downgrades` en el `full-upgrade` y el comentario dice por qué: sin él,
`apt-get -y` se niega, porque el cambio es formalmente una desactualización.

`12` deja escrito lo que debe pasar al purgar un metapaquete: los otros tres
**siguen instalados** y `autoremove` los propone. Y no ejecuta el `autoremove`:
esa VM se conserva como banco de E1.

`09` es el que importa de A2. Ejecuta `apt full-upgrade` **dos veces** y comprueba que
Firefox no ha vuelto al Snap. Si esas dos vueltas no mueven ningún paquete
—porque el sistema ya estaba al día— lo dice y fuerza una vuelta más incluyendo
las actualizaciones por fases de Ubuntu, para que apt tenga algo que decidir:
una prueba vacía que imprime `[OK]` es peor que no tenerla. Al purgar comprueba
además que el candidato de `firefox` vuelve solo al deb de transición de Ubuntu,
que es la prueba A/B de que el anclaje es lo que sostiene Firefox nativo.

## Arranque en frío

Desde el Mac, con la VM ya creada en UTM:

```
scp encina-scripts.tar.gz encina-branding.tar.gz USUARIO@IP:~/
ssh USUARIO@IP
tar xzf encina-scripts.tar.gz
cd encina-scripts
./scripts/00-entorno.sh "Tu Nombre" "tu@correo.real"
./scripts/01-repo.sh ~/encina-branding.tar.gz
cd ~/encina
./scripts/02-activos.sh
./scripts/03-construir.sh
```

A partir de `01-repo.sh` los scripts viven dentro del repositorio, en
`~/encina/scripts`, y se versionan con él.

## El laboratorio de E2: fabricar una VM desatendida desde el Mac

Esto no es un script del repositorio, es el procedimiento que hay detrás de
`MEDICIONES.md` §4.14 y §4.16, y se escribe aquí porque **derivarlo otra vez
cuesta una tarde**. Los medios viven en
`~/Library/Containers/com.utmapp.UTM/Data/Documents/e2-medios/`.

**1. El volumen del seed.** Un `CIDATA` es un sistema de ficheros FAT etiquetado
así con `user-data` y `meta-data` dentro. En macOS se fabrica **crudo**, que es
lo que QEMU sabe leer:

```
dd if=/dev/zero of=seed.img bs=1m count=8
DEV=$(hdiutil attach -imagekey diskimage-class=CRawDiskImage -nomount seed.img | awk '{print $1}')
newfs_msdos -F 12 -v CIDATA "$DEV"
hdiutil detach "$DEV"
DEV=$(hdiutil attach -imagekey diskimage-class=CRawDiskImage seed.img | head -1 | awk '{print $1}')
cp user-data meta-data /Volumes/CIDATA/
sync; hdiutil detach "$DEV"
```

`hdiutil create` **no** vale: produce un UDIF, no una imagen cruda. Y hay que
releer el resultado antes de usarlo, que es gratis y evita medir con un seed
vacío.

**2. La VM, y el único truco que importa.** Para instalar sin humano hace falta
la palabra `autoinstall` en la línea de órdenes del núcleo, y eso obliga a
arrancar con `-kernel`/`-initrd` extraídos de la ISO. **UTM está en la caja de
arena de la App Store y solo le concede a QEMU el acceso a los ficheros que son
UNIDADES de la VM**, así que:

- `Image` e `initrd` van **declarados como unidades** (`ImageType: CD`,
  `ReadOnly: true`) **además** de citados en los argumentos. Sin eso, QEMU dice
  `failed to load "…/Image"` con el fichero presente, legible y válido.
- El campo `file urls` del registro `qemu argument` de AppleScript **no basta**.
- `update configuration` de AppleScript **borra del bundle todo lo que no sea
  unidad**, incluso lo que acabas de referenciar.
- Los argumentos son `-kernel <ruta> -initrd <ruta> -append autoinstall
  -no-reboot`. **`-no-reboot` no es opcional**: sin él la máquina vuelve al
  instalador en cada arranque y **se come su propia instalación** (§4.14h). Y
  `-append` admite **una sola palabra**: UTM parte las demás.
- La palabra va **suelta**. `autoinstall=1` no vale (§4.16a).

**3. Que ha terminado** se sabe porque la VM **se apaga sola**. Después se
quitan los argumentos y las unidades del núcleo y de la ISO, y arranca del disco.

**4. Vigilar con dos señales, nunca una** (trampa 9): que el disco crezca —a los
90 s van ya un par de miles de MB— **y** que la máquina conteste en la red.

**5. El seed de verdad ya no se fabrica a mano.** Desde el 2026-08-10 lo hace
`imagen/fabricar-seed.sh`, que aplica los pasos 1 y 5 de aquí arriba y además
comprueba las cuatro huellas de los `.deb` **antes** de construir y **otra vez**
releyendo el volumen, y se niega si `autoinstall.yaml` y `encina-seed.sh` se han
separado (`MEDICIONES.md` §4.18b):

```
./imagen/fabricar-seed.sh --repo <dir con los 4 .deb y Packages> \
                          --salida seed-e2-completa.img [--actualizar-yaml]
```

**Y la VM se puede construir sin tocar la interfaz de UTM**, que es lo que hizo
§4.18: `config.plist` es un plist normal —se escribe con `plistlib`—, el disco de
destino puede ser un fichero **crudo y disperso** creado con `dd … seek=40g`
(**no hay `qemu-img` ejecutable**: en UTM viaja como biblioteca, no como orden), y
UTM lo ve al reiniciar la aplicación. Los argumentos se ponen después con
AppleScript, con la propiedad `argument string` de cada registro `qemu argument`:

```
update configuration of vm with {qemu additional arguments:{ ¬
   {argument string:"-kernel"}, {argument string:"…/Image"}, ¬
   {argument string:"-append"}, {argument string:"autoinstall"}, ¬
   {argument string:"-no-reboot"} }}
```

**Que la palabra ha llegado no se comprueba en el YAML**: con `DebugLog` puesto,
UTM escribe la línea de órdenes entera de QEMU en `Data/debug.log`, y ahí se lee
`-append autoinstall` **suelto**.

**6. La máquina que sale se verifica con `imagen/verificar-e2.sh`**, copiado a la
VM y ejecutado **como root** (`telemetry` es 0600). Cada comprobación lleva su
control dentro; el script sale con código distinto de cero si hay un solo
`[FALLO]` y te recuerda que no marques ninguna casilla.

## Cómo leer la salida

```
[OK]     comprobado y correcto
[FALLO]  comprobado e incorrecto, con la salida literal del comando
[AVISO]  algo que mirar, no bloquea
[OMIT]   no se ha comprobado (no lo des por bueno)
[OJOS]   solo lo puedes verificar tú mirando la pantalla
```

Si hay un solo `[FALLO]`, el script sale con código distinto de cero y te
recuerda que no marques la casilla de la definición de terminado (`AGENTS.md`).

## Lo que estos scripts NO pueden verificar

El splash de arranque, el logotipo de GDM y el fondo del escritorio hay que
mirarlos. `04` y `05` te los listan al final marcados `[OJOS]` y no los cuentan
como aprobados.

**El splash no se ha podido mirar en estas VMs, y no es un fallo del paquete.** UTM
responde *«display output is not active»* durante el arranque, así que la
pantalla no está viva cuando Plymouth pinta. **No se ha visto nunca el splash con
el logotipo nuevo.**

**Pero hasta dónde llega ese «no se va a poder» es una pregunta abierta**, y
conviene no leerlo como cerrado: se midió en `encina-dev`, que es de la familia
`gpu-pci`, y más abajo está escrito que un resultado visual de una familia no vale
en la otra. Se buscó una medida barata desde dentro del invitado y **no la hay**:
`plymouth-start.service` arranca y `plymouthd` queda vivo, con `splash` en
`/proc/cmdline`, **igual se vea el splash o no** —la frase la dice UTM, en el
anfitrión—, así que es otra comprobación que responde lo mismo en los dos casos.
Lo único medido: las dos familias tienen un dispositivo DRM listo antes de que
Plymouth arranque, de modo que nada apunta a que la tarjeta mande aquí
(`MEDICIONES.md` §4.12f). Lo que lo cerraría es capturar la ventana de UTM desde
el anfitrión durante el arranque.

Lo que sí cierra el hueco casi entero, sin ojos, es comprobar que el fichero
correcto está en el sitio correcto **dentro del initramfs**, que es lo que R7
protege y donde falla en silencio:

```
sudo unmkinitramfs /boot/initrd.img-$(uname -r) /tmp/x
sha256sum /tmp/x/**/themes/encina/logo.png \
          /usr/share/plymouth/themes/encina/logo.png
```

Si las dos huellas coinciden, el initramfs lleva el logotipo que crees. Queda
sin comprobar únicamente que Plymouth lo dibuje — y ese camino ya se vio
funcionar en A1, así que lo único nuevo es el contenido del fichero. **Es un
`[OMIT] no se puede mirar en UTM`, no un `[OK]`.**

Lo mismo con Firefox: que arranque **en español** no lo puede comprobar ningún
script. `08` y `09` lo dejan marcado `[OJOS]` junto con `about:support`, donde
`Application Binary` no debe estar bajo `/snap`.

### Sí se puede mirar la pantalla sin ojos, si la ventana es de X11

Encontrado el 2026-08-08 persiguiendo un diálogo de AutoFirma que no se dibujaba
(`MEDICIONES.md` §4.12d). **No** funcionan las dos vías obvias: la captura por
DBus de GNOME responde `Screenshot is not allowed`, y `org.gnome.Shell.Eval` está
capado desde GNOME 41 y devuelve `(false, '')`. Lo que sí funciona, por ssh, para
cualquier cliente X11 bajo XWayland —que es el caso de AutoFirma y de cualquier
aplicación Java:

```
export DISPLAY=:0
export XAUTHORITY=$(ls -t /run/user/$(id -u)/.mutter-Xwaylandauth.* | head -1)
xwininfo -root -children                    # titulo, geometria y Map State
import -window <id> /tmp/x.png              # captura de esa ventana
identify -format '%k %[mean]' /tmp/x.png    # colores distintos y luminancia
```

`XAUTHORITY` es imprescindible: sin él, `Authorization required`. Y **el número de
colores es la medida**: `1` es una ventana sin pintar, y eso distingue «no se ve»
de «se ve mal» sin depender de nadie mirando. Con eso se midió, con control:

```
por defecto        colores=1     medio=0        negro absoluto
xrender=false      colores=4317  medio=40590    la interfaz entera
```

No sirve para ventanas Wayland nativas, solo para las de XWayland.

### Las VMs de este proyecto no son comparables entre sí

Medido el 2026-08-08. El `Display Hardware` de UTM no es el mismo en todas, y el
diff completo de las configuraciones da **exactamente esa diferencia y ninguna
más**:

```
virtio-gpu-pci    encina-dev, encina-dev-firefox, encina-A2-verificada, encina-autofirma-rota
virtio-ramfb-gl   encina-limpia-respaldo, encina-snap-fabrica, y todo clon suyo
```

Las cuatro de arriba son las máquinas viejas, donde se validó A1, A2 y el primer
positivo. La línea base virgen de la que salían los clones nuevos era de la otra
familia. **Un resultado visual medido en una no vale automáticamente en la otra**,
y eso mira hacia atrás: el `[OMIT]` del splash de Plymouth se midió en
`encina-dev`, que es `virtio-gpu-pci`.

**Ese reparto es el del día en que se descubrió, y explica las mediciones
anteriores; no es el de hoy.** Ese mismo día se igualaron casi todas, dejando
`encina-snap-fabrica` como único testigo de `virtio-ramfb-gl`. **El reparto
vigente está en `ENCINA-OS.md` §9**, que es donde hay que mirarlo.

**Y ojo con cómo se comprueba qué tarjeta hay puesta**, que aquí ya hubo una
comprobación inútil: `lspci` devuelve `Virtio 1.0 GPU (rev 01)` **con las dos**.
No discrimina, nunca discriminó, y se usó para dar por aplicado un cambio de
configuración. Es la trampa 5 en estado puro. **La que sí discrimina**, validada
contra los dos estados conocidos antes de usarla (`MEDICIONES.md` §4.12e):

```
sudo dmesg | grep '\[drm\] features:'      # +virgl = ramfb-gl ; -virgl = gpu-pci
```

**Y ya se sabe qué diferencia hacen.** Cambiando solo la tarjeta en la misma VM,
la interfaz de AutoFirma pasa de `colores=1` (negro absoluto) con `ramfb-gl` a
`colores=3858` con `gpu-pci`, sin ninguna variable de entorno. El
`_JAVA_OPTIONS=-Dsun.java2d.xrender=false` que se venía usando tapaba **un defecto
del laboratorio, no del producto**.

## Idempotencia

Todos son idempotentes: ejecútalos las veces que quieras. `02-activos.sh` no
sobrescribe activos existentes salvo con `--forzar`, para que el día que pongas
el logotipo de verdad no te lo machaque un script.

**Desde el 2026-08-08, `02-activos.sh --forzar` es destructivo.** Ese día llegó:
`encina.jpg` y `encina-dark.jpg` ya no son los degradados que generaba el script,
son fotografías. El script sigue sabiendo fabricar el degradado, así que
`--forzar` **las sustituiría por él sin preguntar** y las dos comprobaciones que
hace después —que son JPEG y que difieren entre sí— saldrían en verde igualmente.
Sin `--forzar` las omite, que es lo correcto. Si alguna vez hay que regenerarlas,
se rehacen desde `assets/wallpaper/`, no con el script.

## Ubicación del repositorio

Por defecto `~/encina`. Si lo tienes en otro sitio:

```
export ENCINA_REPO=/ruta/a/tu/repo
```

## Comprobado

Los quince ficheros pasan `bash -n`. **`shellcheck` sí devuelve avisos**, al
contrario de lo que decía antes este documento: cuatro `SC2164` sobre `cd` y el
resto de nivel `info`/`style`. Los `SC2164` son falsos positivos —`lib.sh` fija
`set -euo pipefail`, de modo que un `cd` fallido ya aborta el script, pero
`shellcheck` no lo detecta porque no resuelve el `source` de ruta dinámica ni
siquiera con `-x`. Se dejan como están a propósito. Los tres scripts de Firefox
(07, 08, 09) y los tres de `encina-meta` (10, 11, 12) están limpios a nivel
`warning`; los de `encina-meta` se verificaron con `shellcheck -S warning` y
tenían tres avisos reales —dos `SC2010` y un `SC2034`—, que se **corrigieron**
en lugar de silenciarse.

Las comprobaciones de reglas
duras se han validado saboteando un paquete a propósito: detectan violaciones de
R1, R2, R3, R6, R7, la falta del callback de LUKS, la falta de `picture-uri-dark`
y la línea duplicada de `GRUB_DISTRIBUTOR`.

## Cuatro trampas de estos scripts, por si escribes más

Las cuatro aparecieron en A2 y las cuatro dan **falsos negativos**: el script
dice `[FALLO]` con la cosa comprobada funcionando perfectamente. Es el peor modo
de fallo posible para una herramienta de verificación, porque cuesta horas
persiguiendo un problema que no existe.

**1. `comando | grep -q` con `pipefail`.** `grep -q` termina en cuanto encuentra
la coincidencia; el proceso de la izquierda muere entonces con SIGPIPE (código
141) y `set -o pipefail` convierte eso en fallo de toda la tubería. Medido:

```
$ apt-cache policy firefox-l10n-es-es | grep -qE 'Candidate: [^(]'
PIPESTATUS: 141 0     <- apt-cache muerto, grep encontrando lo que buscaba
```

No basta con que la salida sea pequeña: aquí eran 604 bytes. La forma correcta
es capturar primero y examinar después, o usar una cadena aquí (`<<<`), que no
crea proceso escritor.

**2. La salida de apt está traducida.** En una VM en español `Candidate:` se
llama `Candidato:`, así que cualquier comprobación que busque la palabra en
inglés falla siempre. Todo lo que consulte a apt va con `LC_ALL=C`.

**3. El `grep` casa con tus propios comentarios.** Tres veces en A2. Un fichero
que explica *por qué no* se usa `apt-key`, o *por qué* se deja de anclar
`firefox_firefox.desktop`, contiene esas cadenas, y la comprobación las
encuentra y acusa al fichero de hacer justo lo que documenta que no hace. Las
comprobaciones se anclan con `^` o filtran comentarios antes de mirar:

```
EFECTIVO=$(grep -vE '^[[:space:]]*#' "$FICHERO")
grep -q "lo que sea" <<<"$EFECTIVO"
```

**4. El entorno de una sesión ssh no es el de la sesión gráfica.** Dos
variables muerden:

- `XDG_CURRENT_DESKTOP` no está definida, así que `gsettings get` devuelve la
  sección genérica del override y no la `:ubuntu`, que es la que aplica de
  verdad. Es el fallo que costó cuatro versiones en A1.
- `XDG_DATA_DIRS` tampoco, y su valor por defecto **no incluye**
  `/var/lib/snapd/desktop`. Una comprobación de precedencia de lanzadores
  `.desktop` hecha sin ella no prueba nada: el fichero del Snap ni siquiera
  está en el camino. `lib.sh` tiene `xdg_data_dirs_sesion` y `resolver_desktop`
  para eso, que leen el valor real del proceso `gnome-shell`.

La moraleja común de las cuatro: **una comprobación que pasa no vale nada si no
sabes contra qué ha pasado.** Cuando una dé `[OK]`, comprueba que habría dado
`[FALLO]` de haber estado mal.

## Tres más, encontradas midiendo AutoFirma (2026-08-07)

Salieron de las mediciones de `MEDICIONES.md` §4.2. No son de ningún script de
aquí, pero son de la misma familia y el sitio de leerlas es este — y las tres
aplican igual a la receta de imagen y a la CI.

**5. Una subcadena que creías que estaba.** `grep -i afirma` **no** casa con
`SocketAutoFirma`: antes de la `F` hay una `o`, así que la subcadena real es
`oFirma`. La comprobación no falla ni avisa — responde «ausente» siempre, en un
sistema sano y en uno roto. Es peor que un falso negativo: es una comprobación
que no comprueba. Se detecta con la misma disciplina de siempre, comprobando que
sabe decir `[OK]` alguna vez.

**6. El control negativo tampoco es gratis.** Verificar un certificado sin
almacén de confianza debería fallar, y no falla:

```
$ openssl verify -no-CAfile -no-CApath <hoja>
OK
$ openssl verify -no-CAfile -no-CApath -no-CAstore <hoja>
error 20 at 0 depth lookup: unable to get local issuer certificate
```

OpenSSL 3.x tiene un tercer origen de confianza, `-CAstore`, activo por defecto,
que lee `/etc/ssl/certs`. **Si validas una comprobación con un control negativo,
comprueba también el control.**

**7. La herramienta de inspección modifica lo inspeccionado.** `certutil -A` crea
`cert9.db` si no existe. `certutil -L` no —falla con `SEC_ERROR_BAD_DATABASE` y
rc=255 dejando el directorio intacto—, pero ese rc≠0 parece un fallo del sistema
y es un «aquí no hay almacén». Cualquier script que recorra perfiles de navegador
solo usa `-L`, y trata ese error como `[OMIT]`, no como `[FALLO]`.

## Y una octava, que ningún contenedor habría enseñado (2026-08-09)

Salió midiendo el vigilante de `autofirma 1.9.1+encina2` (M18 de
`encina-autofirma`, y la enmienda de `MEDICIONES.md` §4.12a). Es de la misma
familia que la 5: **una comprobación que responde lo mismo en un sistema sano y
en uno roto**, y encima en el sitio donde más caro sale.

**8. En la imagen base de Encina OS, el usuario del escritorio es UID 501.** No
1000. Comprobado hoy sobre `encina-E1-vigilante`, con el usuario de siempre:

```
$ id
uid=501(jorge) gid=1000(jorge) grupos=1000(jorge),4(adm),24(cdrom),27(sudo),...
```

**Y el detalle que lo hace venenoso: el GID sí es 1000.** Una comprobación que
filtre por grupo pasa; la misma filtrando por UID salta al usuario. Recorrer las
sesiones o el `passwd` con `awk '$1 >= 1000'` —que es lo que hace todo el mundo,
porque es el `UID_MIN` de Debian— **se salta justo al único usuario que importa,
y en silencio**: no hay error, no hay aviso, simplemente no aparece nadie. En
`encina-autofirma` costó un `postinst` que decía «queda vigilando» y no vigilaba
nada, y no lo vio ninguna prueba en contenedor porque `useradd` sin más da 1000.

**En este repositorio, comprobado hoy, no muerde:** los diez `1000` que hay en
`scripts/` son **prioridades de apt** —`Pin-Priority` en `07`, `apt-cache policy`
en `08` y `11`—, ninguno es un filtro de usuario, y lo único que discrimina
usuarios es `lib.sh`: `$EUID -eq 0` para negarse a correr como root, y `id -un`
para buscar el `gnome-shell` de la sesión. Ninguno de los dos usa el número.

```
$ grep -rn "1000" scripts/          # las diez, todas de apt
scripts/07-firefox-construir.sh:210:    if [[ "${PRIO:-0}" -ge 1000 ]]; then
scripts/08-firefox-instalar.sh:125:  if grep -q "1000" <<<"$MOZ_GEN"; then
scripts/11-meta-instalar.sh:249:    if grep -qE '(^|[[:space:]])1000([[:space:]]|$)' <<<"$BLOQUE"; then
    ...
```

**Se deja escrito para el que venga**, que es lo que hace falta: la receta de
imagen de E2/E3 y cualquier `postinst` futuro van a querer «recorrer los usuarios
de verdad», y el número que parece obvio es el equivocado aquí. Lo correcto es
recorrer a todo el mundo menos `root` y dejar que cada usuario se descarte solo
por no tener lo que se busca.

> **Enmienda del 2026-08-10, y refuerza la trampa en vez de anularla.** El 501 no
> es una propiedad de la imagen: es una propiedad del **camino de instalación**.
> Medido al abrir E2 (`MEDICIONES.md` §4.14i), sobre la misma ISO oficial
> `ubuntu-24.04.4-desktop-arm64.iso` y con la misma huella de medio:
>
> ```
> encina-E1-vigilante   instalada A MANO         uid=501(jorge)   gid=1000(jorge)
> encina-E2-seed        instalada POR SEED       uid=1000(encina) gid=1000(encina)
> ```
>
> O sea que una comprobación con `awk '$1 >= 1000'` **se salta al usuario en las
> máquinas de E1 y no en las de E2**: acierta o falla según cómo naciera la
> máquina, que es el peor modo de fallo que puede tener una comprobación. El
> consejo no cambia, se vuelve obligatorio: **no filtrar por número**.

## Y una novena, del propio laboratorio (2026-08-10)

No es de un script de `scripts/`, es de cómo se miden las cosas, y costó dar por
bueno un control que no valía. Va aquí porque la siguiente vez muerde igual.

**9. Un control necesita su propia señal de que llegó a ejecutarse.** Midiendo si
el instalador de escritorio se para sin el parámetro `autoinstall`
(`MEDICIONES.md` §4.14h), el control era «el disco no crece en 20 minutos». Dio
verde. Y era falso: aquella VM **no había arrancado siquiera** —nació con el
lector vacío y se quedó en el `initramfs`—, así que el disco no crecía por el
motivo equivocado:

```
/init: line 38: can't open /dev/sr0: No medium found      (en bucle, por la consola serie)
```

«No crece» responde lo mismo cuando la máquina espera un clic que cuando está
muerta. La forma correcta lleva **dos señales independientes**: una que demuestre
que el sistema llegó donde tenía que llegar —aquí, `lease` de DHCP y el `getty`
de la serie— y otra que mida lo que se quería medir —el disco intacto—. Es la
misma familia que la 5 y la 8, aplicada al control en vez de a la comprobación.

## Y dos más, del instalador desatendido (2026-08-10)

Salieron midiendo si el Snap se puede quitar desde el seed (`MEDICIONES.md`
§4.16). Las dos son de escribir comprobaciones **sobre un sistema que todavía no
ha arrancado**, que es el sitio donde va a vivir la receta de imagen de E2 y E3.

**10. Bajo `/target`, `[ -e ]` sigue los enlaces absolutos hacia la raíz DEL
INSTALADOR.** Una `late-command` corre en el entorno del instalador con el
sistema instalado montado en `/target`. Muchas unidades de systemd habilitadas
son enlaces **absolutos**, leído del propio `minimal.squashfs` de la ISO:

```
.../multi-user.target.wants/snap-firefox-7764.mount -> /etc/systemd/system/snap-firefox-7764.mount
```

Así que `[ -e /target/etc/systemd/system/multi-user.target.wants/snap-firefox-7764.mount ]`
no pregunta por `/target/etc/...`: pregunta por `/etc/...` **del instalador**. En
§4.16f eso contó un cambio en el objetivo que no había ocurrido —el enlace seguía
donde estaba, y lo que había desaparecido era el fichero de la otra máquina—. Se
evita con `[ -e ]` sobre `-L` (preguntar por el enlace, no por su destino), o
entrando al chroot con `curtin in-target` para que la raíz sea la que se cree que
es. **Y el corolario general, que es lo caro:** en una `late-command`, un `rc=0`
no dice nada sobre el objetivo. Lo único que lo dice es mirar `/target` desde
fuera del chroot, **antes y después**.

**11. Una excepción de PyGObject convirtió una de las dos respuestas en la
tercera.** `resolver_desktop` de `lib.sh` prometía tres salidas: la orden `Exec`,
`NINGUNA` si el identificador no resuelve, y `?` si no se ha podido averiguar.
**`NINGUNA` no se podía imprimir nunca**: `g_desktop_app_info_new()` devuelve
NULL cuando no resuelve, y PyGObject convierte ese NULL en
`TypeError: constructor returned NULL`, no en un `None`. El intérprete moría, se
disparaba el `|| echo "?"`, y «el lanzador del Snap ya no está» respondía igual
que «no lo sé» — en la comprobación que decide la casilla «Sin Snap». Arreglado
con un `except TypeError`, y las tres salidas medidas (§4.16i).

**Y la señal de que llevaba roto desde el principio, comprobada en el propio
repositorio:** `08-firefox-instalar.sh` tiene un `case` con una rama `NINGUNA)`
que **no se podía alcanzar jamás**. Los dos consumidores mejoran con el arreglo y
ninguno se rompe: en `08`, lo que antes caía en `*)` («no se ha podido resolver,
¿falta python3-gi?») ahora cae en su rama correcta; en `09-firefox-verificar.sh`
el `[FALLO]` pasa de decir «resuelve a: ?» a decir «resuelve a: NINGUNA», que es
lo que de verdad ocurre. Una rama de `case` que nunca se ejecuta es un síntoma
barato de esta trampa, y se busca leyendo.

Las dos son de la familia de la 5: **una comprobación que no puede dar una de sus
respuestas no es una comprobación**, y no se nota mirándola, se nota
obligándola a dar las dos.

## Y una duodécima, midiendo el seed completo (2026-08-10)

**12. `pkill -f` casa con la orden que lo ejecuta.** Midiendo el seed de verdad
(`MEDICIONES.md` §4.18), esta línea, mandada por `ssh`, mató su propia sesión:

```
ssh … 'nohup firefox --headless … & sleep 45; …; pkill -f "firefox --headless"'
   -> ssh sale con 255 a mitad de la medicion
```

`pkill -f` mira **la línea de órdenes entera** de cada proceso, y la del intérprete
remoto contenía el texto `firefox --headless` porque el guion entero es su
argumento. O sea que el patrón casó con el proceso que lo estaba ejecutando.

Es la **trampa 3 con otro traje** —el `grep` que casa con tus propios
comentarios—, y aquí sale más cara porque no da un falso negativo: **corta la
medición por la mitad**, y si la orden hubiera ido después de escribir algo y
antes de comprobarlo, el resultado sería un «no está» falso. Se evita matando por
PID —el que devuelve `$!`— en vez de por patrón, o anclando el patrón a algo que
solo tenga el proceso de verdad.

## Y dos más, midiendo la sombra del lanzador (2026-08-10)

Las dos salieron midiendo `MEDICIONES.md` §4.19, y las dos son mías del mismo día.

**13. Una mutación que falla en silencio convierte cuatro estados en uno, y el
paso de restaurar lo certifica.** El guion que compara «como está / con
`NoDisplay` / sin el fichero / con `Hidden`» hacía cada cambio con `sudo`. En
`encina-E2-completa` el usuario `encina` **no tiene sudo sin contraseña**, así que
los cuatro `sudo` fallaron, los cuatro «estados» eran el mismo, y el resultado se
leía como un hallazgo perfectamente coherente: «`NoDisplay` no hace nada en esta
máquina».

Y lo venenoso no es eso, es el final:

```
=========== restaurar ===========
  huella tras restaurar: 16aedbd1…
  [OK] la maquina queda como estaba          <- verdad, y por el peor motivo
```

La comprobación de restauración **dio `[OK]` porque nadie había tocado nada**. Es
la familia de la trampa 5 —la misma respuesta en un sistema sano y en uno roto—
puesta justo donde uno baja la guardia. La regla: **una mutación no es un efecto
secundario, es un paso que se verifica antes de leer su resultado**, y si no se
aplicó no se imprime ningún número:

```
if [ "$(grep -c '^NoDisplay=true' "$F")" -eq 1 ]; then
    echo "  [MUTACION APLICADA]"; mirar
else
    echo "  [MUTACION NO APLICADA] no se mide nada"
fi
```

El detalle que la delató por casualidad: un `grep -n` de control imprimía el
número de línea, y en la máquina buena salía `70:NoDisplay=true` y en ésta solo
las cuatro líneas de comentario que hablan de `NoDisplay` (trampa 3 otra vez).
**Sin ese número de línea, la pasada entera habría pasado por medición.**

**14. Dos VMs a la vez se pelean por `192.168.64.3`, y ninguna avisa.** Está
escrito «no arrancar dos a la vez» y por esto: `encina-dev` y `encina-E1-meta`
encendidas al mismo tiempo, `ssh jorge@192.168.64.3` contestando unas veces una y
otras la otra. Un `ls` de un directorio que sí existía respondió «no existe»,
desde la máquina equivocada.

No estropeó ninguna medición **porque cada salida lleva su huella de identidad
dentro**, que es exactamente para lo que se ponen:

```
encina-E1-meta   los cuatro paquetes de Encina    snap firefox 147.0.3-1 rev 7764
encina-dev       ninguno                          snap firefox 153.0.3-1 rev 8735
```

Y hay más motivo del que parecía: **el `hostname` no distingue nada**.
`encina-E1-meta` se llama `encina-dev` por dentro —es un clon y nadie lo cambió—,
y la máquina nueva de §4.19 se llama `encina-e2-completa` igual que la vieja,
porque el nombre lo pone el seed. **Identificar una VM por su nombre, el de UTM o
el de dentro, no vale; se identifica por lo que tiene instalado y por sus
testigos.**

## Cómo se rehace el seed cuando cambia un `.deb` (2026-08-10)

Vale para cualquier cambio de paquete, y son cuatro cosas, no una
(`MEDICIONES.md` §4.19g):

1. **`imagen/encina-seed.sh`**: la huella (`H_FFNATIVE=…`) **y** el nombre del
   fichero, que lleva la versión dentro.
2. **`imagen/fabricar-seed.sh`**: el nombre en el array `FICHEROS`.
3. **El índice `Packages`**, regenerado con `dpkg-scanpackages` **en una VM**
   —no existe en macOS—, porque lleva `Version`, `Size`, `Filename` y `SHA256`.
4. **Los otros tres `.deb` se sacan del volumen del seed anterior**, no de
   `debian-packages/` de este repositorio: es la trampa de §4.13, y allí hay
   ficheros con la misma versión y **otros bytes**.

Antes de fabricar el bueno, **fabrica uno malo a propósito** —el `.deb` viejo con
el nombre nuevo— y comprueba que la herramienta se niega. Cuesta diez segundos:

```
[FALLO] huella distinta en encina-firefox-native_0.2.1_all.deb
        esperada 972ec932…   real c2de429a…
```

Y para la VM nueva, dos cosas que costaron un arranque fallido cada una:

- **`efi_vars.fd` no puede estar vacío**: QEMU aborta con `cfi.pflash01 device
  '/machine/virt.flash1' requires 67108864 bytes, pflash1 block backend provides
  0 bytes`. Se crea disperso de 64 MiB con `truncate`.
- **La ISO se enlaza DURO dentro del bundle, no simbólico.** UTM le concede a
  QEMU los ficheros que son unidades de la VM; un enlace simbólico saca la ruta
  real fuera de esa concesión. Duro no cuesta disco: es el mismo volumen.
- Y los valores de `config.plist` son enumerados con nombres exactos
  (`UsbBusSupport: '3.0'`, no `'Usb3_0'`; `DirectoryShareMode: 'WebDAV'`). Si uno
  no le gusta, **UTM no da error: la VM simplemente no aparece en la lista.** Lo
  barato es partir del `config.plist` de una VM que ya funciona y cambiar solo lo
  necesario.
