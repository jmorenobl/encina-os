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
cuesta una tarde**. Los medios auxiliares —`Image`, `initrd`, los `user-data` y
los volúmenes de laboratorio— viven en
`~/Library/Containers/com.utmapp.UTM/Data/Documents/e2-medios/`.

**Y las ISOs YA NO VIVEN AHÍ, desde el 2026-08-13** (`MEDICIONES.md` §4.39m).
Están en **`medios/`, dentro del repositorio y en `.gitignore`**, que es donde
las busca `fabricar-iso.sh` por defecto y donde las deja
`imagen/traer-iso-oficial.sh`. El motivo no es de orden sino de método: dentro
del contenedor de UTM estaban **a nueve componentes de profundidad**, y por eso
un `find -maxdepth 6` concluyó que no había ninguna y se aplazó una casilla
entera sobre esa conclusión.

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

**6. La máquina que sale se verifica con `imagen/verificar-instalacion.sh`**, copiado a la
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

### Qué hay en el banco: `scripts/inventario-vms.sh` (2026-08-15)

**Se ejecuta en el Mac**, como `capturar-vm.sh` y `teclear-vm.sh`. Lista las VMs
de UTM con su tamaño, su último arranque y **en qué documentos se las nombra**,
para decidir qué se borra con datos en vez de con el nombre del directorio.

```bash
ENCINA_REPO="$PWD" ./scripts/inventario-vms.sh
./scripts/inventario-vms.sh --vms <dir> --documentos <dir>
```

**NO BORRA NADA Y NO VA A APRENDER.** Qué VM se va es `[OJOS]` de Jorge. El guion
imprime `[OMIT]` en esa línea a propósito.

**Las dos cosas que este guion NO contesta, y las dice él mismo por delante:**

1. **Cuánto espacio se recupera.** Imprime `du`, y `du` es una **cota superior**.
   En APFS dos ficheros comparten bloques —es lo que hace `cp -c`, y lo que hace
   UTM al duplicar una VM— y `du` los cuenta enteros las dos veces. Ya mordió:
   `MEDICIONES.md` §4.29 duplicó una VM, `du` dijo 9,2 GB y al borrarla `df`
   devolvió **0,923 GiB**. **La única medición que vale es `df` antes y después
   de borrar**, y el guion imprime las tres órdenes.
2. **Si una VM se puede borrar.** Cuenta menciones, que no es lo mismo. Una VM
   muy citada puede ser historia cerrada —E1 está terminado 12 de 12— y una sin
   citar puede ser lo único que queda de algo que nadie escribió. El aviso de
   «no aparece en ningún documento» está redactado **en los dos sentidos** por
   eso.

**Los tres controles van antes que la medición**, que es la regla de la casa:

- **1** — el buscador de menciones sabe decir 0 (un nombre inventado) y sabe
  decir más de 0 (`encina-dev`, 80). **Su rojo está probado**: con
  `--documentos /tmp` el control 2 falla, salen los 11 avisos de «sin respaldo»
  y `rc=1`.
- **2** — **reproduce la trampa de §4.29 en dos segundos**: crea un fichero de
  200 MB, lo clona con `cp -c`, y enseña que `du` dice **409 600 KiB** mientras
  `df` dice que el clon costó **4 KiB**. No es una advertencia escrita: es la
  medición, hecha delante de ti cada vez que ejecutas el guion.
- **3** — `[OMIT]` honrado: la fecha del último arranque se lee del `mtime` de
  `Data/efi_vars.fd`, y **no se ha comprobado arrancando una VM y viéndola
  cambiar**. Es un indicio, no una medición, y va marcado como tal.

**Y detecta una cosa que sí es dura:** si un proceso tiene ficheros abiertos
dentro del bundle (`lsof`), la VM está arrancada o suspendida y se avisa. Esa no
se toca.

**La sección «FICHEROS GORDOS REPETIDOS» se añadió el mismo día, después de que
la trampa mordiera de verdad (§4.50).** Se borró `medios/…-95758c9e.iso` —3,5 GB
según `du`— y **`df` devolvió CERO**: no había instantáneas de APFS, lo que había
era una copia con **la misma huella** dentro de `encina-95758c9e.utm`, clonada,
compartiendo todos los bloques. **Borrar una de dos copias clonadas no libera
nada; solo la última paga.** La sección agrupa los ficheros de ≥1 GiB con los
mismos bloques asignados y los señala. **No demuestra el clonado** —macOS no da
los bloques únicos de un fichero—: es un indicio que se confirma con `shasum`, y
ese paso **no se salta**, porque `ac0a5721…` y `1224b5b1…` tienen el mismo tamaño
exacto y distinto contenido (§4.45).

**Dos defectos que costó escribirla, los dos cazados ejecutando:**

- **`find -size +1g` no vale en macOS**, que quiere `G` **mayúscula**. No dio un
  error legible: salió distinto de 0, `set -e` mató el guion **en mitad de la
  sección** y la salida terminó justo tras el título. Un guion que se muere en
  silencio es peor que uno que falla — y es de la familia del `[OK]` que describe
  lo que se pidió y no lo que pasó.
- **Agrupar por tamaño lógico (`%z`) daba un falso positivo gordo:** los cuatro
  `disco.img` de UTM son **dispersos** y los cuatro declaran 42 949 672 960 bytes
  exactos ocupando entre 10 y 12 GiB distintos. Habría dicho que cuatro VMs
  comparten 40 GiB. Se agrupa por **bloques asignados (`%b`)**, que los separa
  solos y deja juntas las ISOs que sí coinciden.

*Por qué existe este guion, que es la parte que conviene no perder:* el
2026-08-15 se escribió en tres documentos que la ISO `95758c9e…` llevaba
`encina-branding` 0.1.11, **porque había una VM llamada `encina-95758c9e`**. Era
falso —la de 0.1.11 es `1224b5b1…`— y se cazó midiendo las tres con `shasum`.
**Un nombre de directorio no es una medición**, y este guion existe para no
volver a tomar una decisión de borrado con esa clase de dato.

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
se rehacen desde `design/fondos/maestros/`, no con el script.

**Y desde el 2026-08-14 hay quien lo hace mejor: `design/generar.sh`.** Los
maestros se movieron a `design/fondos/maestros/`, de dónde sale cada derivado
está escrito en `design/fondos/manifiesto.tsv` con las doce huellas, y ese guion
las comprueba —con su rojo probado— en vez de fabricar un degradado. Retirar los
degradados de aquí es una casilla abierta:
`tareas/aspecto/1-instrumentacion.md`.

## Los nombres cambiaron el 2026-08-13, y aquí está la equivalencia

Tres ficheros se llamaban por la **fase en la que nacieron** en vez de por lo que
hacen, y eso ya mentía: `verificar-e2.sh` no es de E2 —se corrió el 2026-08-13 sobre
la máquina de E4, con `--visibles 34`— y `-e3` no le decía a nadie que ése es
justamente **el seed que va dentro de la ISO**.

```
ANTES                        AHORA                              QUE ES
imagen/autoinstall.yaml   -> imagen/autoinstall-unattended.yaml  el DESATENDIDO,
                                                                 con contrasena de
                                                                 laboratorio. Va en
                                                                 el volumen CIDATA
imagen/autoinstall-e3.yaml-> imagen/autoinstall.yaml             EL DE LA ENTREGA:
                                                                 pregunta, no lleva
                                                                 credenciales, y es
                                                                 el que viaja DENTRO
                                                                 de la ISO
imagen/verificar-e2.sh    -> imagen/verificar-instalacion.sh     verifica LA MAQUINA
                                                                 QUE SALE, sea de la
                                                                 forma que sea
```

**El renombrado no tocó un solo byte**, comprobado por huella antes y después
(`b280ce66…`, `5655205d…`, `dcaa98ab…`). Y **`/autoinstall.yaml` dentro de la ISO NO
cambia**: es la ruta donde el instalador lo busca, el quinto sitio de
`select_autoinstall`, y eso lo fija Ubuntu y no nosotros.

**`MEDICIONES.md` y `DIARIO.md` conservan los nombres viejos a propósito**: son el
registro de lo que literalmente se ejecutó aquel día, y reescribirlos sería falsear
una salida. Esta tabla es la que los hace legibles.

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

**AMPLIADA EL 2026-08-11, y la moraleja de arriba ya no basta.** Los cuatro
verbos, medidos con sus dos controles (M19(a) de `encina-autofirma`):

```
-A  rc=0    -> cert9.db key4.db pkcs11.txt      CREA   (control positivo)
-L  rc=255  -> (nada)                           no crea (control negativo)
-K  rc=255  -> (nada)                           no crea
-D  rc=255  -> cert9.db key4.db pkcs11.txt      CREA   <- el que no sospechaba nadie
```

**`certutil -D` también crea el almacén**: sale con 255 y *«could not find
certificate named …»* y aun así deja los tres ficheros detrás. **Y aquí el que
fabricaba no era un diagnóstico: era un DESINSTALADOR** —el `uninstall.sh` que
`autofirma` ejecutaba como root desde el `postinst` y desde el `prerm`—, y por eso
nadie lo miraba. El defecto vivió dos versiones (`MEDICIONES.md` §4.29c) y tenía
**tres puertas**; quitar solo la evidente lo habría dejado vivo por el camino de
desinstalar, **y la limpieza habría parecido funcionar**.

**La moraleja, en su forma nueva:** no basta con desconfiar de los verbos que
inspeccionan. **Hay que preguntarle a cada verbo qué deja detrás, incluidos los
que borran y sobre todo los que fallan**, y la pregunta se contesta con `ls` antes
y después, no leyendo el manual. Y el dato que lo hace barato: `-D` y `-L`
distinguen sus casos **por código de salida**, así que ninguna comprobación tiene
que mirar el texto del mensaje —que además la ataría al idioma de NSS—.

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
(`MEDICIONES.md` §4.19g).

**CORRECCIÓN DEL 2026-08-15: no son cuatro, son CINCO** (`MEDICIONES.md` §4.45).
Falta **el `autoinstall.yaml` Y el `autoinstall-unattended.yaml`**, que llevan el
seed entero dentro en base64 como `late-command`: cambiar `encina-seed.sh` sin
rehacerlos los separa. Se rehacen con
`./fabricar-seed.sh --yaml <ruta> --actualizar-yaml …`, **uno por uno, los dos**.
No hizo falta acordarse: `fabricar-iso.sh` lo dice con un `[FALLO]` que nombra la
orden. *La lista de abajo se conserva como estaba, con su numeración rara
incluida, porque el `0.` de en medio se escribió así el 2026-08-12 y renumerarla
borraría por qué.*

**SEGUNDA CORRECCIÓN, EL MISMO DÍA, subiendo `encina-branding` a 0.1.12: no son
cinco, son SEIS.** Falta **`imagen/fabricar-iso.sh`**, que lleva su PROPIO array
`FICHEROS=(…)` con los cuatro nombres —los nombres llevan la versión dentro—,
duplicado del de `fabricar-seed.sh` y a cuatro líneas de las huellas que sí saca
de `encina-seed.sh`. Es la sexta, y no se descubrió construyendo nada: se vio
buscando `0.1.11` por `imagen/` antes de tocar. *La buena noticia es que este
sitio no falla en silencio* —sin actualizarlo, `fabricar-iso.sh` para en seco con
`no esta: …encina-branding_0.1.11_all.deb`—, así que el riesgo es de tiempo
perdido y no de fabricar un medio equivocado. La mala es la de siempre: **la
lista de nombres vive en dos ficheros**, y mientras siga así habrá una séptima.

*Y una nota de procedimiento que sirve para la próxima:* para rehacer los dos
YAML hace falta un `--repo` completo que pase las comprobaciones 1 y 2, o sea los
28 `.deb` **y** su `Packages`. El 2026-08-15 esos bytes se sacaron de la ISO
anterior (`tar -xf` sobre el `.iso`, que `bsdtar` lee) y **se verificaron uno a
uno contra `repo-manifiesto.tsv`**: 28 de 28, con el control de que el `.deb`
cambiado sale señalado. Eso NO reabre la circularidad que cerró
`cosechar-repo.sh`, y conviene tener clara la diferencia: lo prohibido es sacar
**la lista** de un medio, y la lista siguió saliendo del manifiesto. Del medio
salieron solo los **bytes**, que el manifiesto valida. Los `.deb` de
`encina-firefox-native` y `encina-meta` que hay sueltos en `debian-packages/`
llevan la versión buena y **otros bytes** —§4.13 otra vez—, así que no valen.

**AMPLIACIÓN DEL 2026-08-15 (la de la tarde), subiendo `encina-branding` a
0.1.14** (`MEDICIONES.md` §4.48f). Se repitió esa vía y **hay dos cosas más que
saber antes de la próxima**:

- **De la ISO de E4 salen 26 de 28, no 28.** Los otros dos son
  `encina-firefox-native` y `encina-meta` con los bytes **anteriores a §4.37**
  —`972ec932…` y `86da3cc9…`, las que el comentario de `encina-seed.sh` llama
  «las anteriores»—: aquel medio se fabricó antes de la corrección y **los lleva
  fosilizados dentro**. Se arregla reconstruyéndolos desde el clon con
  `07-firefox-construir.sh` y `10-meta-construir.sh`, que dan **exactamente** las
  del manifiesto. Y sobra uno, `encina-branding_0.1.8_all.deb`, que era el de
  aquella ISO.
- **El bulto no es el problema:** `/encina-repo` pesa **168 MB**, no un gigabyte,
  así que extraerlo y mandarlo a la VM para el `dpkg-scanpackages` cuesta
  segundos.

*Y el control salió gratis, que es lo mejor que le puede pasar a uno:* no hizo
falta sabotear nada para probar que el cotejo sabe decir que no — señaló los dos
malos y el que sobraba él solo.

1. **`imagen/encina-seed.sh`**: la huella (`H_FFNATIVE=…`) **y** el nombre del
   fichero, que lleva la versión dentro.
2. **`imagen/fabricar-seed.sh`**: el nombre en el array `FICHEROS`.
3. **El índice `Packages`**, regenerado con `dpkg-scanpackages` **en una VM**
   —no existe en macOS—, porque lleva `Version`, `Size`, `Filename` y `SHA256`.
0. **AVISO DEL 2026-08-12, y es lo primero porque es lo que más fácil sale mal:**
   `encina-autofirma/salida/` tiene ya **TRES** `.deb` de `autofirma`
   —`d5a0ebe1…` (`+encina2`), `2d985724…` (`+encina3`) y `faeca3a9…`
   (`+encina4`)—. **Se elige por ruta entera y se comprueba la huella**; con
   `ls -t | head -1` construirías una cosa distinta de la que crees, y es la
   trampa de §4.13 con tres candidatos en vez de dos.
5. **Y desde E4 hay una quinta, que es de tamaño:** el repo deja de ser cuatro
   `.deb` y 44 MB. Con el nivel 3 de `MEDICIONES.md` §4.27 lleva dentro todo lo
   que bajaba de internet, así que **no cabe en los 128 MiB de siempre** y
   `fabricar-seed.sh` gana `--tam-mb`. El índice `Packages` deja de describir
   cuatro ficheros: las dos herramientas comprueban ahora **el índice entero**
   contra los bytes que viajan, en las dos direcciones.

**DÓNDE VIVE EL REPOSITORIO OFFLINE — y desde el 2026-08-13 la respuesta ya no es
«dentro de la ISO».** Se **fabrica**, con `imagen/cosechar-repo.sh`
(`MEDICIONES.md` §4.36), que lee `imagen/repo-manifiesto.tsv` y baja los 24 de
fuera comprobando cada uno **por huella al llegar**:

```
./imagen/cosechar-repo.sh --salida <dir> --propios ~/Projects/encina-autofirma/salida
./imagen/cosechar-repo.sh --salida <dir> --propios ./debian-packages
```

`--propios` busca **por huella en todo el árbol**, nunca por nombre ni por fecha:
en `encina-autofirma/salida/` conviven los tres `+encina2`/`+encina3`/`+encina4`,
y el `+encina2` renombrado como `+encina4` —y encima el más nuevo— **se rechaza**.
Después falta el `Packages`, que **no** se puede hacer en macOS (más abajo).

**Extraerlo de la ISO sigue siendo posible y ya no es la vía normal**, sino la
salida de emergencia y la forma de cotejar un medio contra el manifiesto:

```
xorriso -osirrox on -indev encina-os-E4-es-0.2.1.iso -extract /encina-repo <destino>
```

**Y DESDE EL 2026-08-13 NO HAY NADA QUE SÓLO SALGA DE AHÍ** (`MEDICIONES.md`
§4.37). Este párrafo decía que `encina-branding_0.1.8_all.deb` era el último hilo
de la circularidad; ya no lo es, porque **los tres `.deb` de Encina se
construyen desde el clon** con `03-construir.sh`, `07-firefox-construir.sh` y
`10-meta-construir.sh`, y la vuelta entera —cosecha sobre un directorio vacío,
`--propios` apuntando sólo a lo construido y a `encina-autofirma/salida`— da
**28 de 28 sin tocar la ISO ni una vez**.

*Y una corrección a §4.36g, que se midió mal por mirar sólo aquí:* el `0.1.8` no
«sólo salía de la ISO». **No estaba en el Mac**, que no es lo mismo: en
`encina-dev` estaba en cuatro sitios, encontrado por huella.

**El nombre lleva la versión desde el 2026-08-13** (`MEDICIONES.md` §4.35): la ISO
vigente es `encina-os-E4-es-0.2.1.iso` (`ac0a5721…`) y la anterior, `aa1ac76a…`,
llevaba dentro `encina-meta` 0.2.0. Las dos pesaban **exactamente lo mismo**, así
que se comprueba **por huella y nunca por tamaño**.

*Y una corrección medida el 2026-08-13 (§4.39m):* este párrafo decía que
`aa1ac76a…` **estaba borrada**, y no lo estaba — seguía viva en el `scratchpad`
de una sesión muerta, encontrada **por huella** al barrer el disco sin límite de
profundidad. Se borró entonces. Es la misma familia que (a): «lo borré» y «no lo
encuentro donde miré» no son lo mismo, y sólo el segundo se había medido.

Y de ahí se rehace cualquier volumen `CIDATA` con `fabricar-seed.sh`. Los
volúmenes de la vuelta de E4 **no se conservaron a propósito**: son
reproducibles, y el disco del banco no daba para todo.

**Las huellas vigentes desde el 2026-08-13** (`MEDICIONES.md` §4.37), que son las
que hay que ver salir de `fabricar-seed.sh`:

```
faeca3a9…  autofirma_1.9.1+encina4_all.deb
9ec0a49d…  encina-branding_0.1.8_all.deb        6158932 bytes
640f508e…  encina-firefox-native_0.2.1_all.deb    10876
204081f0…  encina-meta_0.2.1_all.deb               6904   <- 0.2.1 desde el 2026-08-13 (D18 reescrita)
```

**LAS TRES DE ENCINA CAMBIARON ESE MISMO DÍA Y EL CONTENIDO DE LOS PAQUETES NO.**
Las anteriores —`51b6603c…`, `972ec932…` y `86da3cc9…`— **no eran las de un
paquete, sino las de UNA CONSTRUCCIÓN CONCRETA**, y por eso no se podían
reproducir desde un clon. La causa, medida hasta el offset: `dpkg-buildpackage`
ya exporta `SOURCE_DATE_EPOCH` derivado del changelog, pero **`dpkg-deb` RECORTA
los mtimes posteriores y DEJA PASAR los anteriores**, así que la fecha que un
fichero tuviera en el disco se colaba dentro del `.deb`. Ese dato no está en git.

**La consecuencia práctica, y es buena: los tres SÍ son reproducibles desde el
clon.** Un checkout siempre pone fechas posteriores al changelog, el recorte las
absorbe todas y la huella sale estable — comprobado construyendo con mtimes
distintos a propósito. Lo que no se reproducía era la huella vieja.

**Y el aviso que va con esto: `ac0a5721…` ya no se fabrica desde este
repositorio.** Esa ISO lleva dentro los `.deb` viejos y un seed que exige las
huellas viejas: es coherente **consigo misma**, no con el árbol de hoy.

**LA HUELLA QUE ESTE REPOSITORIO PRODUCE, MEDIDA EL 2026-08-13**
(`MEDICIONES.md` §4.39). Se predijo que tendría otra por dos motivos a la vez
—las tres huellas nuevas y el modo de §4.36k— y así fue:

```
95758c9e954d834f6324b6f5e0464741742478247d29a2637009ad03e2a8aef6   3 715 366 912 bytes
```

**Cuatro pasadas de `imagen/construir-todo.sh` y una construcción manual dieron
esa misma huella**, así que es reproducible y no una foto. La diferencia contra
`ac0a5721…` son **cinco ficheros de 531** —los tres `.deb`, el `Packages` que los
describe y el `autoinstall.yaml` que lleva el seed empotrado— más el modo, que no
vive en el contenido de ningún fichero sino en los registros de directorio. Los
otros 526 son byte a byte iguales.

**Y OJO CON CÓMO SE LEE ESA HUELLA, porque no es lo mismo que la de arriba:**
`ac0a5721…` es el medio que **se probó** —se arrancó y se instaló (§4.34,
§4.35g)—, y `95758c9e…` es el que **este repositorio fabrica hoy**. Ninguna de
las cinco ISOs de §4.39 se ha arrancado. Hasta que una lo haga, ésta es una
huella de construcción, no de entrega. **Y otra vez el mismo tamaño exacto que la
vigente**, que es la tercera: se compara por huella y nunca por tamaño.

**DE UN CLON A LA ISO EN UNA SOLA ORDEN**, desde el 2026-08-13, que es lo que
antes había que encadenar a mano:

```
./imagen/construir-todo.sh --constructor jorge@192.168.64.3 \
                           --llave ~/.ssh/encina-e2-medicion \
                           --iso-oficial <ubuntu-24.04.4-desktop-arm64.iso> \
                           --autofirma ~/Projects/encina-autofirma/salida \
                           --salida <encina.iso>
```

Cruza dos máquinas y no es un capricho: `dpkg-buildpackage` y
`dpkg-scanpackages` **no existen en macOS** y `fabricar-iso.sh` sólo corre aquí.
Construye **`git archive HEAD` y no el directorio de trabajo** —es §4.37d
convertido en regla— y **se niega sobre un árbol sucio**, porque lo que saldría
no sería lo que ves. Con `--vm <uuid>` enciende y apaga la VM él, y comprueba
antes que no haya otra encendida (trampa 14).

**Y la ISO oficial de entrada ya no se cree por su huella escrita a mano.** Desde
el 2026-08-13 se comprueba contra la **firma de Canonical**, que es un control
independiente del guion:

```
gpgv --keyring /usr/share/keyrings/ubuntu-archive-keyring.gpg \
     SHA256SUMS.gpg SHA256SUMS          <- en encina-dev; en macOS no hay gpg
gpgv: Firma correcta de "Ubuntu CD Image Automatic Signing Key (2012)"
```

La clave sale del paquete `ubuntu-keyring`, **no de un servidor de claves**, que
sería confiar en un sitio más. Y `SHA256SUMS.gpg` está en el mismo directorio de
`cdimage` que `SHA256SUMS`: llevaba ahí desde siempre y nadie lo usaba.

**Y DESDE EL 2026-08-13 NO SON CUATRO COSAS: SON SEIS, y las dos nuevas no se
dedujeron, se cazaron gastando una instalación cada una** (§4.34h). Las cuatro de
arriba bastan cuando cambia la **versión** de un `.deb`; **cuando cambia lo que el
producto LLEVA, hay dos sitios más que guardan la lista por su cuenta**:

```
5. imagen/encina-seed.sh      la LISTA DE LO QUE TIENE QUE ESTAR en el objetivo
6. imagen/verificar-instalacion.sh     la MISMA LISTA, otra vez, y por su cuenta
```

- La **quinta** se delató sola: la instalación salió con `ESTADO=INCOMPLETO` y
  `ENCINA_FALTA=gnome-software gnome-software-plugin-snap`, porque el seed seguía
  exigiendo la tienda vieja. **Y eso es una buena noticia disfrazada de fallo: el
  nivel 2 de §4.27 se disparó SOLO, en un caso real que nadie provocó.**
- La **sexta** no se delata sola hasta que verificas: **47 correctas y 2 fallos, y
  los dos del verificador**. Es la trampa 27 otra vez.

**Regla: cuando cambie lo que el producto lleva, `grep` del nombre viejo por
`imagen/` ENTERO antes de fabricar nada** — y con su control, o sea comprobando
que el mismo `grep` encuentra el nombre nuevo donde debe.

**Y DESDE EL 2026-08-13 NO SON SEIS: SON SIETE, y la séptima es que la QUINTA HAY
QUE HACERLA DOS VECES** (`MEDICIONES.md` §4.35c). `encina-seed.sh` no viaja suelto:
viaja **empotrado en base64 dentro de un YAML**, y hay **dos** YAML que lo llevan:

```
7. imagen/autoinstall-unattended.yaml   <- el DESATENDIDO, el que va en el CIDATA
   imagen/autoinstall.yaml              <- EL QUE VIAJA DENTRO DE LA ISO
```

El 2026-08-12 se rehízo el seed y **se regeneró solo el primero**. Nadie lo notó
porque **aquel día no se fabricó ninguna ISO**. Al fabricarla al día siguiente, el
guardián del paso 3 de `fabricar-iso.sh` lo cazó:

```
[FALLO] el seed y encina-seed.sh se han separado.
```

Y no era cosmético: el guion empotrado en la ISO exigía `H_META=85c8cc56…` —la
huella de la versión **vieja**— y los dos `gnome-software`, así que **una ISO con el
repositorio corregido y ese seed habría rechazado su propio `.deb`**. Se pone al día
con la herramienta versionada, no a mano:

```
./fabricar-seed.sh --yaml imagen/autoinstall.yaml --actualizar-yaml \
                   --repo <dir> --salida <img de usar y tirar>
```

**Y se comprueba que cambió UNA sola línea**, con el control de que el fichero
comparado consigo mismo da 0.
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

## Y una decimoquinta, generando la contraseña del seed (2026-08-10)

**15. En macOS, `crypt` de Python **no** hace SHA-512: cae a DES sin avisar.**
Generando el hash de la contraseña de `imagen/autoinstall-unattended.yaml` (`MEDICIONES.md`
§4.20b), esto es lo que salió:

```
python3 -c "import crypt; print(crypt.crypt('encina','$6$'+salt))"
   -> $6WjIPoxPKheY
```

**Trece caracteres.** Eso es DES. `crypt(3)` de macOS **no implementa `$6$`**, e
ignora el prefijo en silencio: no hay error, no hay aviso, y `crypt.METHOD_SHA512`
aparece como disponible, que es lo que remata el engaño. Y **el prefijo `$6` a
simple vista parece correcto** — lo que lo delata es la longitud:

```
SHA-512 crypt   105-106 caracteres, empieza por $6$<salt>$
DES              13 caracteres
```

Lo caro no es el fallo, es que **el resultado funciona**: DES trunca la
contraseña a ocho caracteres, así que una contraseña corta entra igual y la
máquina parece correcta. Se habría entregado un seed con un hash trivial de
romper y nadie lo habría notado.

La forma correcta en macOS es `openssl passwd -6`, que sí lo implementa, y **se
verifica a la salida**, no se da por bueno:

```
H=$(openssl passwd -6 -salt "$SALT" encina)
[ ${#H} -gt 90 ] || fallo "el hash no es SHA-512"
[ "$(openssl passwd -6 -salt "$SALT" encina)"  = "$H" ] || fallo   # reproduce
[ "$(openssl passwd -6 -salt "$SALT" Encina)" != "$H" ] || fallo   # y el control
```

Es de la familia de la 5 y de la 13: **una herramienta que responde algo
plausible en vez de fallar**. La defensa es la misma de siempre: comprobar el
resultado contra lo que tiene que dar **y** contra lo que no.

---

## Y dos más, abriendo E3 (2026-08-10)

**16. Un volumen `CIDATA` olvidado le gana al seed que hay dentro de la ISO, y la instalación sale bien.**
Leído en el propio instalador (`MEDICIONES.md` §4.21c): `select_autoinstall`
mira cinco sitios **por orden**, el seed de cloud-init es el **cuarto** y el que
viaja dentro de la ISO es el **quinto**.

```
1. argumento de línea de órdenes del servidor
2. subiquity.autoinstallpath=...
3. /autoinstall.yaml
4. /run/subiquity/cloud.autoinstall.yaml   <- el CIDATA. GANA
5. /cdrom/autoinstall.yaml                 <- el de la ISO
```

En una máquina nueva, o con la ISO recién grabada, esto no se nota nunca. **En
este laboratorio sí**, porque los volúmenes `CIDATA` de E2 están a mano y una VM
puede llevar uno enganchado de una medición anterior. Entonces la instalación
**sale bien** —máquina completa, verificador en verde— y está midiendo **el seed
equivocado**: el de E2, no el de la ISO de E3.

Es de la familia de la 5: **la misma respuesta en un sistema sano y en uno
roto**. Y su defensa no puede ser el resultado, porque el resultado es idéntico:

```
# el testigo va en el arranque, no en la maquina
grep -c "append" debug.log          # 0 esperado en E3
grep -o "\-drive [^ ]*" debug.log   # exactamente dos: la ISO y el disco de destino
```

O sea: **la prueba de que la ISO se bastó sola es lo que NO había conectado**, y
eso solo se ve desde fuera, antes de arrancar.

**Y HAY QUE LEERLO EN EL MOMENTO, porque `debug.log` NO ES UN REGISTRO: ES UN
VOLÁTIL** (`MEDICIONES.md` §4.35o, encontrado al intentar salvar el rastro de una VM
antes de borrarla). **UTM lo reescribe entero en cada arranque**, así que lo que hay
dentro es la línea de órdenes del **último** inicio, no la de la instalación — y
después de una instalación se le quitan a la VM la ISO y los argumentos, con lo cual
el fichero acaba diciendo lo contrario de lo que se midió:

```
encina-E4-tienda, que se instalo con 1 -append y cinco unidades:
  su debug.log, meses despues   -append: 0   media=disk: 2
CONTROL, encina-E4-entrega, instalada igual y arrancada el mismo dia:
  su debug.log                  -append: 0   media=disk: 2
```

**La regla: el control de la trampa 16 se lee y se TRANSCRIBE a la medición en el
momento.** La transcripción **es** la evidencia; no hay copia de seguridad detrás.
Guardar el `debug.log` «por si acaso» no conserva nada: lo comprobé y no estaba.

**17. `unsquashfs` en el Mac revienta a mitad, y no es la imagen.**
Leyendo el código del instalador que viaja dentro de la ISO (§4.21e):

```
FATAL ERROR: dir_scan: failed to make directory
  .../usr/lib/aarch64-linux-gnu/perl/5.34.0/sys, because File exists
```

No hay nada corrupto: el sistema de ficheros del Mac **no distingue mayúsculas**,
y Perl trae `sys/` y `Sys/`. El mensaje habla de un fichero que «ya existe» y
apunta a un fallo de extracción, que es justo lo que no es.

Dos consecuencias prácticas:

- **Extraer solo la ruta que se quiere leer**, no el árbol entero:
  `unsquashfs -d salida imagen.squashfs /ruta/exacta`. Es más rápido y no toca la
  colisión.
- **Si de verdad hace falta el árbol completo**, hay que extraerlo sobre una
  imagen de disco sensible a mayúsculas, no sobre el disco del Mac.

Y lo que importa del método: **una extracción que aborta a mitad no invalida lo
leído si lo leído salió antes del aborto** — pero hay que decir dónde paró y
comprobar que el fichero que se cita estaba entero. Aquí `bin/subiquity/` y
`meta/snap.yaml` se extraen antes, y la versión del snap se transcribe para que
se pueda repetir.

---

## Y una decimoctava, del registro de UTM (2026-08-10)

**18. Una VM desaparece del listado de UTM al reiniciar la aplicación, y su bundle está intacto.**
Pasó fabricando la VM de la forma de E3: tras un `quit`/`open` de UTM,
`encina-E2-sinsnap` dejó de salir en `utmctl list` y `utmctl status` respondía
`Virtual machine not found` — con el bundle entero en disco y su `config.plist`
pasando `plutil -lint`.

**La causa no es el bundle, es el registro de UTM**, que guarda la ruta de cada
VM y **no la actualiza al renombrar la carpeta**:

```
clave del registro: DE23E4B0-60A6-4652-9428-0D03E844AFB0
Name: encina-E2-control                                   <- el nombre viejo
Path: .../encina-E2-control.utm                           <- una ruta que ya no existe
```

Esa VM nació como `encina-E2-control` y se renombró a `encina-E2-sinsnap`.
**Mientras UTM no se reinicie no se nota**, porque la lleva resuelta en memoria;
al reiniciar, la entrada apunta a un sitio que no existe y la VM no se lista,
**y el registro tampoco deja que UTM la redescubra**, porque el UUID ya está
cogido.

**El arreglo, con UTM cerrado y el `plist` respaldado antes:**

```
osascript -e 'quit app "UTM"'
P=~/Library/Containers/com.utmapp.UTM/Data/Library/Preferences/com.utmapp.UTM.plist
cp "$P" respaldo.plist
/usr/libexec/PlistBuddy -c "Delete :Registry:<UUID>" "$P"
plutil -lint "$P" && open -a UTM
```

Borrada la entrada obsoleta, UTM **redescubre el bundle** al escanear su carpeta
de documentos y lo vuelve a listar con su nombre y su UUID correctos.

Lo que hay que llevarse, y es método y no anécdota: **`utmctl list` no es un
inventario del disco, es un inventario del registro**. Antes de dar por perdida
una VM —o por buena una limpieza— hay que mirar los bundles con `ls`, que es la
otra mitad. Aquí nadie borró nada; una lista incompleta pareció una VM perdida.

---

## Y una decimonovena, remidiendo E2 (2026-08-10)

**19. `Image` no es byte a byte `/casper/vmlinuz`, y parece un núcleo de otra ISO.**
Antes de arrancar la VM desatendida se comprobó que los medios de `e2-medios`
salen de la ISO oficial. El `initrd` coincide; `Image` **no**:

```
/casper/vmlinuz            000d5917…   gzip compressed data
e2-medios/Image            a1586ff3…   Linux kernel ARM64 boot executable Image
gunzip -c /casper/vmlinuz  a1586ff3…   <- es el mismo fichero
```

En aarch64 el `vmlinuz` de la ISO va **comprimido** y QEMU quiere el núcleo
crudo, así que `Image` es su `gunzip`. **Hay que normalizar los dos lados antes
de comparar**, exactamente como el PEM contra el DER de §4.20: sin eso sale un
«este núcleo no es de esta ISO» perfectamente creíble y falso.

**Y de paso, cómo se leen los guiones de casper sin arrancar nada**, que hace
falta cada vez que hay que medir el instalador y no se deduce del fichero:

```
file initrd        -> ASCII cpio archive     <- y engana: son DOS archivos pegados
```

El primero es el firmware, sin comprimir; `cpio -it` se para al llegar a su
`TRAILER!!!` y parece que ahí se acaba todo. El segundo empieza justo después,
alineado, y es **zstd** (magia `28b52ffd`). Se localiza recorriendo las cabeceras
`070701` hasta el `TRAILER!!!` y saltando los ceros de relleno; a partir de ahí,
`zstd -dc | cpio -id` da `scripts/casper` y `scripts/casper-bottom/*`. No hay
colisión de mayúsculas en ese árbol, así que en el Mac se extrae entero sin
tropezar con la trampa 17.

---

## Y una vigésima, midiendo una máquina que no tiene `ssh` (2026-08-10)

**20. El canal que no depende de la red: un volumen FAT conectado DESPUÉS de instalar.**
El seed de la entrega de E3 **no lleva servidor `ssh` a propósito**, así que no
se puede entrar desde el Mac. El canal de red de §4.22 depende del cortafuegos y
falla en la dirección que hace falta. Lo que funcionó siempre:

```
# en el Mac: 16 MiB, FAT, con el verificador dentro; se conecta como segunda unidad
dd if=/dev/zero of=canal.img bs=1m count=16
newfs_msdos -F 12 -v CANAL <dispositivo>          # y se copia imagen/verificar-instalacion.sh

# dentro, tecleado por codigos crudos:
sudo mount /dev/vdb /mnt
sudo script -q -c "bash /mnt/v.sh --forma e3" /mnt/salida.txt
sudo cp /etc/encina-seed.log /mnt/seed.log
sudo umount /mnt
```

**Se conecta DESPUÉS de instalar, y eso no es un detalle:** la casilla «dos
unidades y ni una más» se cierra con el `debug.log` del **arranque de la
instalación**, que hay que guardar antes de tocar nada. Después ya da igual.

**Y tres cosas que cuestan un rodeo cada una:**

- **Los códigos de teclado son DE POSICIÓN, y la distribución la pone el
  INVITADO.** El conversor de §4.22 es de EE.UU.; si quien instaló eligió teclado
  español, `sudo mount /dev/vdb /mnt` llega como **`sudo mount -dev-vdb -mnt`**,
  porque el código 53 es `/` allí y `-` aquí. **Se ve en pantalla, que es la
  regla de la trampa 1.** Para el invitado español: `/` es `Shift`+código 8,
  `"` es `Shift`+código 3, y `-` es el código 53 a secas.
- **`sh` es `dash`**: `verificar-instalacion.sh` usa `set -o pipefail` y sale
  `Illegal option -o pipefail`. Va con `bash`.
- **`script -q -c` en vez de `>`**, y no por elegancia: el `>` español está en la
  tecla ISO que ni existe en el mapa de EE.UU. Menos signos raros, menos
  pulsaciones que perder.

---

## Cómo mirar y pilotar una VM de UTM sin ojos (2026-08-10)

Salió midiendo la forma de E3 (`MEDICIONES.md` §4.22), donde la sesión viva **no
tiene `ssh`** y el seed de la entrega no lo lleva a propósito. Vale para
cualquier medición futura sobre un instalador.

**1. Ver la pantalla.** `screencapture` del Mac, con permiso de Grabación de
Pantalla concedido al proceso. Sin él responde `could not create image from
display` y **no escribe fichero**, que al menos es un fallo ruidoso:

```
open -a UTM; sleep 2                      # la ventana tiene que estar delante
screencapture -x -o pantalla.png
sips -c 1670 2560 --cropOffset 290 359 pantalla.png --out vm.png   # recortar la ventana
```

**2. Escribir en la VM, y aquí está la trampa.** UTM tiene `input keystroke`,
pero **traduce el texto con la distribución del teclado del MAC**, no con la del
invitado: con el Mac en español, un `-` llega al invitado como `/`. Y
`sudo loadkeys us` **no lo arregla**, porque el problema está en el anfitrión. Lo
que sí funciona es mandar **códigos de teclado crudos**, que no pasan por ninguna
traducción:

```
osascript -e 'tell application "UTM" to input scan code (virtual machine named "X") codes {30, 158}'
```

Hay un conversor de texto a códigos de EE.UU. en el guion `teclear.py` que se usó
en §4.22 —el mapa cabe en diez líneas—. Y `input mouse click at {x, y}` sirve
para despertar la pantalla sin escribir nada.

**3. Sacar datos, que es lo que de verdad hace falta.** En vez de leer a base de
capturas, se abre un canal de solo lectura desde dentro y se tira de él con
`curl` desde el Mac:

```
sudo python3 -m http.server 8000 --directory /       # dentro del invitado
curl http://<ip>:8000/var/log/installer/telemetry    # desde el Mac
```

**Y esto ensucia la sesión viva**, así que se hace para *contestar una pregunta*,
no para producir la medición definitiva: después se rearranca la VM limpia.

**4. Cómo entrar sin contraseña en una sesión viva:** `Ctrl+Alt+F3`, usuario
`ubuntu`, contraseña vacía, y `sudo` sin contraseña. Los códigos de las VT son
`{29, 56, 59+n, ...}` con sus tres sueltas.

**5. La pantalla negra que no es un fallo.** A los pocos minutos la sesión viva
**se bloquea**: queda un fondo negro con el cursor de X y parece que no ha
arrancado nada. Un clic devuelve el saludador `Live session user` y detrás sigue
el instalador, intacto. **Antes de dar por muerta una sesión gráfica, despiértala**
— y contrástalo con una señal que no dependa de la pantalla, como que la máquina
tenga IP:

```
for i in $(seq 2 30); do ping -c1 -W 200 192.168.64.$i >/dev/null 2>&1 & done
arp -a -n | grep -i "<la MAC de la VM>"
```

### Cuatro cosas más, aprendidas midiendo la forma de E3 (2026-08-10)

Van aquí porque cada una costó un rodeo y ninguna se deduce.

**1. `input keystroke` se come caracteres.** Tecleando por códigos crudos salió
`echo encna | sudo -S …` en vez de `encina`, y la orden fallo por una contraseña
mal escrita, no por lo que se estaba midiendo. **Nunca des por hecho lo que
tecleaste: míralo en la pantalla antes de creer el resultado.** Si algo falla de
forma rara, la primera sospecha es la pulsación perdida, no el sistema.

**2. El invitado no siempre alcanza al Mac.** Un `python3 -m http.server` en el
anfitrión sirve para pasarle ficheros al invitado… hasta que el cortafuegos de
macOS deja de permitirlo, y entonces el invitado recibe `[Errno 111] Connection
refused` mientras `curl` **desde el propio Mac** contesta 200. Las dos cosas son
ciertas a la vez y confunden mucho. El sentido que sí funcionó siempre es el
contrario: **servidor dentro del invitado y `curl` desde el Mac**.

**3. Un servidor lanzado en segundo plano muere al acabar la orden.** Si hace
falta que viva mientras se teclea en el invitado, **todo tiene que ir en una sola
llamada**: levantarlo, teclear y recoger el resultado.

**4. `curl` NO está en la instalación mínima**, y su ausencia miente: el síntoma
fue `bash: /tmp/v.sh: No existe el archivo`, que apunta al fichero y no a la
orden que falta. `python3` sí está —lo usa el propio instalador—, así que para
traer algo:

```
python3 -c "import urllib.request as u; u.urlretrieve('http://host:puerto/x','/tmp/x')"
```

**Y una quinta, del 2026-08-12, que costó abandonar una medición:** `input scan
code` e `input mouse click` **pueden no llegar al invitado**, y no dan ningún
error. Con la ventana de UTM detrás de otra aplicación, ni las teclas ni los
clics tuvieron efecto; `set frontmost` y `AXRaise` de System Events **contestan
que sí** y la ventana sigue detrás. **La señal que lo delata** es comparar dos
capturas: si el **reloj del invitado avanza** pero la pantalla no cambia, el
invitado está vivo y **lo que no llega son tus pulsaciones** — no lo contrario.
Y las coordenadas del ratón son **del invitado**, así que hay que deducir la
escala mirando dónde se quedó el cursor, no suponerla.

**Y LA QUINTA QUEDÓ CONTESTADA EL 2026-08-12** (`MEDICIONES.md` §4.32h), así que
las cinco pantallas **sí se pueden pilotar**. Eran **tres cosas distintas**, no
una, y hay que hacer las tres:

1. **El ratón de UTM no llega, y el teclado de `System Events` sí.** Con la
   ventana delante, `input mouse click` deja el cursor del invitado donde estaba;
   `osascript -e 'tell application "System Events" to tell process "UTM" to key
   code 36'` **sí** entra. La prueba que no se puede fingir: ese `Return` abrió
   el diálogo «Detectar disposición de teclado» del instalador.
2. **`Ctrl+Alt` NUNCA llega al invitado: es el atajo de UTM** para soltar el
   ratón, y lo intercepta el anfitrión —sale su propio diálogo «Mouse
   capturado»—. Por eso `Ctrl+Alt+T` no abre ningún terminal. Lo que funciona es
   **`Alt+F2`** → «Ejecutar una orden».
3. **Hay que reactivar UTM y comprobar que es el proceso frontal ANTES DE CADA
   ENVÍO.** `System Events` entrega al proceso **frontal**, no al que se nombra;
   si otra aplicación toma el foco, las teclas se van a otro sitio **sin ningún
   error**. El control cuesta una línea:

```
osascript -e 'tell application "UTM" to activate'
osascript -e 'tell application "System Events" to get name of first process whose frontmost is true'
```

**Y la defensa de la trampa de los caracteres comidos (punto 1 de arriba):
teclear carácter a carácter con 0,2 s.** `keystroke "encinacinco"` dejó
**`encinacin`** en el campo —y así se quedó el hostname de esa máquina—; con la
pausa, `gnome-terminal` salió entero:

```applescript
repeat with c in characters of "gnome-terminal"
  keystroke (c as text)
  delay 0.2
end repeat
```

**LA SALIDA BARATA, cuando lo que hace falta es medir el MEDIO y no las
pantallas:** un volumen `CIDATA` con **el YAML y ningún `encina-repo` dentro`**.
El `CIDATA` gana el seed (trampa 16, usada a favor) y la instalación va
desatendida, pero el bloque 1 de `encina-seed.sh` no encuentra repositorio en él
y **cae a `/cdrom/encina-repo`**, que es justo lo que se quería demostrar de la
ISO. Se paga con lo que deja de medirse, y eso se escribe.

**Y TRES COSAS MÁS DEL 2026-08-13, que son donde lo de arriba se queda corto**
(`MEDICIONES.md` §4.35k). Van con los tres guiones que ahora viven en `scripts/`:
`capturar-vm.sh`, `teclear-vm.sh` y `leer-pantalla.m`.

**1. NO BASTA CON `AXRaise`: la ventana tiene que quedar `AXMain`.** Es la cuarta
cosa, y cuesta media hora de teclas al vacío:

```
osascript -e '… perform action "AXRaise" of w'                      -> se ve delante,
                                                                       la captura sale bien,
                                                                       LAS TECLAS NO LLEGAN
osascript -e '… set value of attribute "AXMain" of w to true'       -> ahora si
```

**Y no da ningún error.** La señal que lo delata es la de siempre: el reloj del
invitado avanza y la pantalla no cambia. `teclear-vm.sh` lo pone y **se niega** si la
ventana no queda `AXMain`.

**2. EL RATÓN NO LLEGA, y ahora con un control que no admite lectura subjetiva.**
Antes era «no parece que llegue». Ahora se compara **píxel a píxel** el antes y el
después de un clic sobre un blanco inequívoco —un elemento de la barra lateral—:

```
clic del anfitrion sobre «Juegos»   -> 0 pixeles distintos
control del comparador              -> contra si misma 0; contra otra, la caja de las diferencias
```

El comparador es `diferencia.py`: decodifica el PNG a mano (zlib + los cinco
filtros) porque **no hay PIL en el Python del sistema**, y devuelve la caja que
encierra los cambios. Sirve además para **seguir el anillo de foco de GTK**, que es
invisible para el OCR.

**3. La rejilla NO se abre con `Alt+F1` desde un Mac: se abre con `Cmd+A`.** GNOME
tiene `panel-main-menu` en `<Alt>F1`, pero **en un Mac `F1` es tecla de brillo y no
llega a la aplicación**. Lo que sí funciona es `show-applications`, que está en
`Super+A`, y `Cmd` se traduce a `Super`.

**Y LO QUE SIGUE SIN PODERSE HACER, dicho para que nadie lo vuelva a intentar a
ciegas: pulsar un botón concreto dentro de una aplicación del invitado.** El 2026-08-13
se descartaron **cinco** vías midiendo cada una (§4.35i): clic del anfitrión, `input
scan code`/`input mouse click` de UTM, tabular hasta el botón —`Tab` **sí** llega y
mueve el foco, pero no aterriza en él y `Return`/`Espacio` no lo activan—, la
interfaz de accesibilidad —la aplicación aparece, pero el árbol de un snap confinado
sale truncado y `queryAction` da `timeout from dbind`— y las teclas del ratón de
GNOME, que **desplazan la página** en vez de mover el puntero.

**Y ANTES QUE TODO LO DEMÁS: COMPRUEBA QUE LA VENTANA DE LA VM EXISTE**
(2026-08-14). `utmctl start` arranca la máquina **pero no siempre abre su
consola**: si UTM lleva rato abierto, la VM pasa a `started` y **no hay ninguna
ventana**. Entonces `System Events` entrega las teclas a la **lista de UTM**, y
ahí no hay error, no hay aviso y no pasa nada — salvo que la lista tiene VMs
dentro y una tecla suelta puede arrancar la que no es. Lo que lo arregla es
cerrar UTM y volver a abrirlo antes del `utmctl start`, y el control cuesta una
línea:

```
osascript -e 'tell application "System Events" to tell process "UTM" to get name of every window'
  -> UTM                        <- SOLO la lista: las teclas se van a ninguna parte
  -> encina-95758c9e, UTM       <- hay consola: ya se puede teclear
```

Y después de un susto así, lo primero es contar las encendidas:
`utmctl list | grep -v stopped` tiene que dar **una**.

**Y TRES FORMAS DE PERDER LO QUE TECLEAS, del 2026-08-13** (`MEDICIONES.md`
§4.40f). Las tres son de `teclear-vm.sh texto`, **las tres son mudas** —ni un
error, ni un aviso— y las tres se cazaron mirando la pantalla antes de pulsar
`Return`:

```
1. Las COMILLAS DOBLES no llegan, y se pierde la ORDEN ENTERA
   'script -q -c "bash /mnt/v.sh …" /mnt/salida.txt'   ->  el prompt se queda VACIO
   Causa: el guion interpola $TEXTO dentro de comillas dobles de AppleScript,
   asi que una " de dentro rompe el script y no se envia nada.
2. El '>' NO llega
   'echo hola > /mnt/prueba.txt'   ->  llego  'echo hola  /mnt/prueba.txt'
3. Los DIGITOS se pierden
   '--forma e3 --visibles 27'      ->  llego  '--forma e --visibles'
   'grep -n -A3 FALLO'             ->  llego  'grep -n -A FALLO'
```

**El 3 es el peligroso, y por poco:** `--forma e` hace que el verificador se
niegue con código 2, que se ve. Pero un dígito comido en `--visibles` sale por un
`[AVISO]`, y los avisos no los mira nadie. **Un número mal tecleado en una
comprobación cuyo resultado es un número es la peor combinación posible.**

**Las tres defensas, y las tres son baratas:**

- **Los dígitos van por `key code`**, que no pasan por ninguna traducción:
  `1`=18, `2`=19, `3`=20, `4`=21, `5`=23, `6`=22, `7`=26, `8`=28, `9`=25, `0`=29.
- **`script <fichero>` SIN `-c`** para grabar la salida: abre una shell que graba
  la sesión entera, y así no hace falta ni una comilla ni un `>`. Se cierra con
  `exit`.
- **Mirar la orden en la pantalla ANTES de pulsar `Return`.** Es la regla de
  siempre y el 2026-08-13 valió tres veces en una sola sesión.

Y `Ctrl+U` para borrar la línea **tampoco llegó limpio** —dejó pegado el resto de
la orden anterior—; lo que sí funciona es `Ctrl+C`.

**Y la conclusión de método, que vale más que las cuatro:** cuando medir cuesta
tanto como esto, **el dato bueno es el que la máquina deja escrito solo**
—`/var/log/installer/telemetry`, los testigos, `/etc/encina-seed.log`—, no el que
se arranca a base de teclear. Lo que decidió §4.22 fue un registro con fecha, no
una pantalla.

---

## Y una vigesimoprimera, limpiando el banco (2026-08-11)

**21. Borras 3,4 GB de medios y el disco devuelve 0,44 GiB.**
Es `ENCINA-OS.md` §9.a por un sitio que no estaba escrito: **no son solo las VMs
las que se clonan entre sí, es también el directorio de medios**. El `Data/` de
cada bundle de UTM lleva **un clon de APFS de su ISO**, así que borrar la copia de
`e2-medios` no libera nada mientras el bundle siga vivo.

```
libres antes             8,21 GiB
rm de 3,67 GB de medios  8,65 GiB    <- 0,44 GiB devueltos
rm de las dos VMs       33,57 GiB    <- ahi llegaron los 3,4 GB de la ISO
```

**Y las dos explicaciones fáciles quedan descartadas, con su control:**

```
stat -f "%l enlaces" *.iso              -> 1 en todas    (no son enlaces duros)
tmutil listlocalsnapshots /             -> vacio          (no son instantaneas)
```

Un clon de APFS **muestra 1 enlace** y comparte bloques, que es justo lo que hace
la comprobación de enlaces inútil aquí.

**Lo que hay que llevarse, y es método:**

- **Borrar un medio y borrar su VM no son dos ahorros, son uno.** Al planificar
  una limpieza, cuenta la ISO **una sola vez**.
- **Lo único que no miente es `df` antes y después.** Ni `du`, ni `stat`, ni la
  suma de lo que crees que has borrado.
- **Y por eso el orden correcto es medir el retorno, no predecirlo**: se anota
  `df`, se borra, se vuelve a anotar. El número que va a la medición es la resta.

**CORREGIDO EL 2026-08-11 (`MEDICIONES.md` §4.29h): `utmctl` SÍ sabe borrar.**
`utmctl delete <uuid>` existe en la versión instalada —sale en `utmctl --help`—,
borra el bundle **y** limpia el registro: comprobado por las dos mitades, 9 en
`utmctl list` y 9 bundles en disco, sin entrada fantasma y con `plutil -lint` en
verde. El respaldo del `plist` **antes** de borrar sigue siendo obligatorio, y el
procedimiento manual de abajo sigue valiendo como red de seguridad.

**Cómo se borra una VM a mano** (era: «que `utmctl` no sabe»), y
con la trampa 18 aplicada para que no quede un fantasma en el registro:

```
osascript -e 'quit app "UTM"'
P=~/Library/Containers/com.utmapp.UTM/Data/Library/Preferences/com.utmapp.UTM.plist
cp "$P" respaldo.plist                       # el respaldo va ANTES
rm -rf ".../encina-LA-QUE-SEA.utm"
/usr/libexec/PlistBuddy -c "Delete :Registry:<UUID>" "$P"
plutil -lint "$P" && open -a UTM
```

Y el control de que quedó consistente son **las dos mitades**: que
`utmctl list` y `ls -d *.utm` den el mismo número, y que cada nombre listado
tenga su bundle en disco. Un registro con una entrada de más es exactamente la
trampa 18 al revés.

---

## Y dos más, midiendo la espera por raíz (2026-08-12)

Las dos son de M20 de `encina-autofirma`, las dos son **del instrumento y no del
sistema**, y las dos las cazó un control que estaba puesto para otra cosa. Van
juntas porque enseñan lo mismo por dos caminos: **un instrumento que se equivoca
no da un número raro, da el número que esperabas.**

**22. `PID=$(...)` no espera al subshell: espera a que se cierre la tubería, y un
trabajo en segundo plano la mantiene abierta.** Midiendo cuánto tarda el vigilante
en instalar la CA, el control «sin raíz de Snap» dio **32 ms** cuando tenía que dar
unos 8 s. El almacén diferido —el que aparece unos segundos después, para simular
a Firefox creándolo— se lanzaba así:

```
PID=$(lanzar_almacen_diferido & echo $!)      # <- la sustitucion no vuelve hasta
                                              #    que se cierra la tuberia, y el
                                              #    trabajo en segundo plano la
                                              #    tiene cogida
```

La sustitución de órdenes lee hasta EOF, y el proceso en segundo plano hereda el
descriptor de escritura, así que `$(...)` **no vuelve cuando el subshell termina:
vuelve cuando ese descriptor se cierra**. Resultado: el ayudante arrancaba con el
perfil **ya hecho**, y entonces **contesta lo mismo con el mecanismo bueno y con el
malo** — trampa 5, pero dentro del instrumento, que es donde no se busca. Se evita
lanzando el trabajo y leyendo `$!` **sin** sustitución de órdenes, o redirigiendo
la salida del trabajo a `/dev/null` para no dejarle la tubería.

**23. Un contador que lee el `journal` en un contenedor cuenta cero, y el cero
parece la respuesta.** Contando cuántas veces arranca el servicio mientras la
unidad `.path` recibe once flancos, la cuenta salía **«0 arranques para 11
flancos»** — que es *muy* parecido a la respuesta buena («no se apila»), y por eso
casi cuela. La causa no era el mecanismo: era que **en el contenedor el `journal`
no se lee**, así que el contador no podía dar otra cosa. Lo cazó su **control de
mudez** —comprobar que la fuente sabe devolver algo distinto de cero antes de creerse
un cero—. La versión buena cuenta por una marca que escribe el propio servicio, y
entonces sí contesta: **once flancos dan un arranque, la unidad sigue `active` y
`Result=success`**, que es la pregunta que M15(E) dejó abierta.

**La regla que sale de las dos, y vale para cualquier medición futura:** antes de
creerte un número, oblígale a dar el otro. Si tu control no sabe fallar, no es un
control; y si tu fuente no sabe decir «algo», su «nada» no significa nada.

---

## Y tres más, de la vuelta de E4 (2026-08-12)

Las tres son **del taller del Mac**, no de las VMs, y las tres dejan un
resultado plausible en vez de un error.

**24. El `tar` de macOS mete AppleDouble DENTRO del `.deb`.** Empaquetando
`debian-packages/` para construir en `encina-dev`, el `.deb` de
`encina-branding` salió con esto dentro:

```
-rw-r--r-- root/root  163  ./etc/xdg/._mimeapps.list
-rw-r--r-- root/root 3077  ./etc/xdg/mimeapps.list
```

`tar` escribe una entrada `._x` por cada fichero con atributos extendidos, y
`--exclude='._*'` **no sirve**, porque esas entradas no existen en el disco: las
inventa `tar` al empaquetar. Lo que sí sirve es `COPYFILE_DISABLE=1`. Es
`MEDICIONES.md` §4.18m por una vía nueva —allí eran los `._` que macOS deja en un
volumen FAT, aquí los que `tar` inventa— y **no da ningún error**: el paquete se
construye, `lintian` calla y los ficheros de más viajan a la máquina. Se ve
mirando `dpkg-deb -c`, y solo si se mira.

**Y el 2026-08-13 esta trampa CAMBIÓ DE FORMA, medido al intentar que su control
se disparara y no conseguirlo** (§4.36i). Con `bsdtar 3.5.3 / libarchive 3.7.4`,
este Mac **no** produce entradas `._` — ni con un xattr de usuario, ni con un
fork de recursos, ni pidiéndole `--mac-metadata` a la cara. Lo que hace ahora es
escribir **cabeceras pax**, y se ven en el lado de Linux al desempaquetar:

```
tar: Se desestima la palabra clave de la cabecera extendida desconocida
     'LIBARCHIVE.xattr.com.apple.provenance'
```

O sea que hoy el `tar` de GNU las **descarta avisando** en vez de dejar ficheros
que `dpkg-scanpackages` indexaría. Consecuencias, y las dos importan:

1. **`COPYFILE_DISABLE=1` se sigue poniendo**: cuesta cero y el comportamiento
   depende de la versión de `libarchive`, que no se controla.
2. **Pero contar entradas `._` ya no demuestra nada**, porque hoy da `0` en los
   dos casos. La comprobación que **sí puede fallar** es cotejar las huellas de
   lo que salió y de lo que llegó, a los dos lados.

**Y el 2026-08-13, transfiriendo los 28 `.deb` de la cosecha, se midió una tercera
que no se sabía** (§4.37j): **`COPYFILE_DISABLE=1` NO suprime las cabeceras
pax.** Suprime los ficheros `._`, que este `libarchive` ya no escribe de todas
formas. Con la variable puesta salieron los 29 avisos igual:

```
COPYFILE_DISABLE=1 tar -cf - *.deb | ssh … tar -xf -
tar: Se desestima la palabra clave de la cabecera extendida desconocida
     'LIBARCHIVE.xattr.com.apple.provenance'              (x28)
     'LIBARCHIVE.xattr.com.docker.grpcfuse.ownership'
28 .deb llegaron   entradas que no son .deb: 0
```

O sea que la variable **no es la protección**, es higiene barata; la protección
es el cotejo de huellas, y en esa transferencia dio iguales con el control de que
una cambiada en un carácter la señala.

**25. `tar xzf … | head -2` mata el `tar` a mitad por SIGPIPE.** Se extrajo medio
árbol de fuentes, el `set -e` de la línea siguiente falló en un `cd` que no tenía
nada que ver, y el mensaje apuntaba al sitio equivocado. Lo mismo hizo saltar un
`panic` de Rust en un `cat … | head` de otra orden. **Cualquier tubería a `head`
mata a quien escribe**, y en una extracción eso no se nota: nadie cuenta los
ficheros que salieron. Es de la familia de la 22 —el instrumento se equivoca y da
un resultado plausible— y se evita no filtrando la salida de `tar`.

**26bis. Y dentro de esa misma trampa hay otra más fina: no son las variables de
entorno, es `setlocale()`.** §4.26f midió los nombres de las aplicaciones «en
las tres combinaciones de locale probadas» y salieron en inglés. La causa no era
el sistema:

```
LANG=es_ES.UTF-8  +  locale.setlocale(LC_ALL,"")   ->  Archivos
LANG=es_ES.UTF-8  SIN setlocale                    ->  Files
   y en los DOS casos GLib.get_language_names() ya dice ['es_ES.UTF-8','es_ES','es']
```

Un proceso que no llama a `setlocale` recibe el `msgid` en inglés **aunque la
biblioteca ya sepa el idioma**. GNOME Shell lo llama al arrancar; un `python3 -c`
no. **Regla: si vas a preguntar por una cadena traducida, llama a `setlocale`
primero, y enseña `get_language_names()` al lado de la respuesta** — es el
control que separa «el sistema está en inglés» de «tu proceso lo está».

**26. Una medición hecha por `ssh` sobre algo que vive en el escritorio miente, y
hay que marcarlo EN EL MOMENTO.** §4.26c dio `application/pdf -> firefox.desktop`
y de ahí salió media decisión de producto. Medido con `XDG_CURRENT_DESKTOP`
puesto, la respuesta es **Evince**: los ficheros `<escritorio>-mimeapps.list`
**solo se leen si el escritorio se llama así**, y una sesión `ssh` no lleva esa
variable. §4.26f ya lo avisaba para los nombres de las aplicaciones y nadie lo
llevó a la fila de al lado de la misma tabla. **La regla:** cuando el instrumento
sea `ssh` y la pregunta sea del escritorio, se mide **en las dos columnas** —con
la variable y sin ella— o se marca `[OJOS]` desde el primer día.

---

## Y dos más, cerrando la ISO de E4 (2026-08-12)

Las dos salieron midiendo `MEDICIONES.md` §4.32, y las dos son **comprobaciones
que no podían dar una de sus dos respuestas** — la familia de la 5 y de la 11,
que ya va por la cuarta aparición.

**27. Una lista de etapas exacta a la que le falta la etapa que siempre está.**
`verificar-instalacion.sh --forma e3` esperaba
`confirm,done,identity,install,keyboard,network,storage,timezone` y la máquina
dio esa misma lista **más `loading`**, que toda instalación escribe — la rama E2
del mismo guion, dos líneas más arriba, **ya la esperaba**. El fallo entró al
reescribir el verificador en la vuelta de E4 y **estuvo invisible un día entero
porque desde entonces no se había medido ninguna máquina de forma E3**.

La regla que sale, y no es «revisa las listas»: **una comprobación reescrita hay
que dispararla contra las dos formas que dice cubrir antes de creerla**. Si una
rama no se ejecuta desde que se tocó, no está medida — está escrita.

**28. Preguntar por el mecanismo en vez de por lo que se quiere saber.** La
comprobación decía *«hay un saludador gráfico vivo»* y esperaba `si`. Pero una
máquina de forma E3 **no lleva `ssh`** a propósito, así que se mide **desde
dentro de una sesión gráfica** (trampa 20) — y mientras hay alguien dentro, GDM
**no tiene saludador**: tiene una sesión de usuario. O sea que en el único sitio
donde hay que usarla, **sólo sabía contestar `no`**.

Lo que se quería saber era *«el escritorio arranca»*. Ahora vale el saludador
**o** una sesión gráfica de usuario, **se dice cuál de las dos se vio** —que es
más informativo que el sí/no de antes— y lleva su control de que `loginctl` no
está mudo. **No se aflojó: se corrigió, porque estaba mal escrita.**

---

## Y dos más, firmando de verdad sobre la forma (c) (2026-08-12)

Las dos son de `MEDICIONES.md` §4.33, y las dos **son mías**.

**29. `utmctl clone` NO regenera la MAC, así que un clon y su origen son
indistinguibles por los dos caminos a la vez.** Ya estaba escrito que el clon
contesta en la **misma IP**; lo que no estaba es que también trae la **misma
MAC**:

```
encina-E4-meta        MacAddress 76:CE:28:76:DC:40
encina-firma-efimera  MacAddress 76:CE:28:76:DC:40
```

Eso rompe el truco del punto 5 de «Cómo mirar y pilotar una VM sin ojos»
—`arp -a -n | grep "<la MAC de la VM>"`—, que **no discrimina un clon de su
origen**, y rompe también la huella de dentro: un clon recién nacido tiene, por
definición, la misma huella de paquetes y testigos que su padre. Es la trampa 14
llevada al extremo: allí dos VMs distintas se peleaban por una IP y las separaba
su huella; **aquí no hay huella que las separe**.

**Y esto muerde justo donde más caro sale**, porque el clon efímero de la firma
lleva dentro un certificado personal y su origen es un banco que se perdería si
lo tocara. Lo que sí funciona, **gratis y sin encender nada**, es preguntarle al
anfitrión cuándo se escribió por última vez la imagen de disco de la original:

```
/usr/bin/find "$B/<VM>.utm/Data" -type f -exec /usr/bin/stat -f '%Sm %z %N' -t '%F %T' {} \;

encina-E4-meta/Data/disco.img        2026-08-12 11:19:15   <- horas antes de la sesion
encina-firma-efimera/Data/disco.img  2026-08-12 20:31:11   <- la que estuvo viva
```

**La regla: cuando dos VMs no se pueden distinguir desde dentro, la prueba está
fuera.** Y el orden correcto es escribir un testigo dentro del clon **en el
primer minuto**, antes de que entre nada, para que a partir de ahí sí haya
huella. *(Y un detalle del instrumento que también sirve: `utmctl ip-address`
distingue las dos con dos mensajes distintos —`The QEMU guest agent is not
running` para la encendida, `The virtual machine is not running` para la
parada—.)*

**30. Dos umbrales escritos por mí que no podían dar una de sus dos respuestas, y
los dos en la misma huella.** La familia de la 5 y de la 11, quinta aparición.

- **«0 `.p12` en el disco»** no puede salir «sano» en **ninguna** máquina con
  AutoFirma instalado: el configurador fabrica
  `/usr/share/autofirma/autofirma.pfx`, y encima `dpkg -S` no lo reconoce porque
  no viaja en el paquete. El umbral que sí discrimina es el de §4.13: **0 en
  HOME**.
- **El contador de iconos que no aplica el ensombrecido de `XDG_DATA_DIRS`**
  cuenta ficheros, no iconos, y dijo **2** donde la máquina tiene **1**. La
  sombra de `encina-firefox-native` vive en `/usr/share/applications`, que gana a
  `/var/lib/snapd/desktop/applications`, y lleva `NoDisplay=true`; contando por
  fichero, el de abajo parece visible. **Para contar iconos hay que resolver por
  nombre de fichero en el orden de precedencia**, o usar el inventario de §4.19c
  que ya lo hace — y aun así la columna que decide es la de los ojos (trampa 26).

**Lo que hay que llevarse:** el peligro de estas dos no es que fallen, es que
**una salió «rota» y la otra «sana» siendo las dos falsas**, y las dos iban dentro
de una huella de virginidad que se toma justo antes de gastar una VM con un
certificado personal dentro. **Un umbral se prueba contra sus dos respuestas el
día que se escribe, no el día que estorba.**

---

## Y tres más, cambiando la tienda (2026-08-13)

Las tres son de `MEDICIONES.md` §4.34, y **ninguna es del producto: las tres son
del banco**. Van juntas porque las tres se llevaron una instalación por delante.

**31. `QEMU error … Invalid argument`: llevaba sesiones saliendo, se daba por
inocuo sin saber por qué, y la causa es de APFS.** §4.24 lo despachaba con
`errors_count 0`, que es un acto de fe. La unidad del error es **el disco de
destino**, y UTM lo declara —leído en la línea de órdenes real de QEMU, no
supuesto— con `discard=unmap,detect-zeroes=unmap`. Eso hace que QEMU **anuncie
TRIM al invitado** y traduzca cada descarte a `fcntl(F_PUNCHHOLE)` sobre el
fichero. Medido en C, con sus dos respuestas:

```
alineado a 4096   -> OK          offset no alineado (512)   -> Invalid argument
zona ya dispersa  -> OK          longitud no multiplo de 4K -> Invalid argument
pasa del final    -> OK
```

**APFS exige alineación a 4096 y devuelve `EINVAL` si no la hay**; el instalador
descarta alineado a **512**, que es el sector que anuncia virtio-blk. Reproducible
a voluntad desde dentro, y el control es que **la única diferencia son 512 bytes**:

```
blkdiscard -o 4096 -l 8192 /dev/vdb  -> rc=0                    dialogos: 0
blkdiscard -o 4608 -l 8192 /dev/vdb  -> BLKDISCARD ioctl: E/S   dialogos: 1
```

**Es inocuo, y ahora no por fe:** un descarte es una optimización de espacio, no un
dato; si falla, el sistema de ficheros se crea igual. **Y UTM no lo escribe en
`debug.log`**, así que la única forma de saber si salió es mirar la pantalla.

**32. El arreglo evidente de la 31 ROMPE LA INSTALACIÓN, y hay que decirlo con la
misma fuerza con la que casi se escribe como solución.** `-set
drive.<id>.discard=off` apaga el diálogo **en caliente** —el mismo `blkdiscard`
desalineado pasa a `rc=0`, y `fstrim` tampoco lo dispara—, así que parece cerrado.
No lo está: **con ese argumento la instalación se atasca y el seed no llega a
correr**. Aislado cambiando **una sola variable**, que es como debí hacerlo:

```
inst. 1  seed viejo, SIN -set  -> llego al seed
inst. 2  seed nuevo, CON -set  -> atascada en 9502 MB, sin testigo ni encina-seed.log
inst. 3  seed nuevo, CON -set  -> atascada en 9502 MB, igual
inst. 4  seed nuevo, SIN -set  -> 11002 MB, se apaga sola, ESTADO=COMPLETO
```

**La regla, que es de método y no de QEMU: no cambies dos variables a la vez.** Yo
metí el seed nuevo y el `-set` en la misma instalación y perdí dos vueltas
averiguando cuál de los dos era.

**33. El Mac se duerme a mitad de instalación y se lleva la VM por delante.** La
instalación 2 se paró y el instalador cascó (`apport`:
*«System program problem detected … ubuntu-desktop-bootstrap»*). **La causa no está
en ninguna VM: está en el anfitrión**, y la enseña `pmset`:

```
23:02:12  Entering Sleep state due to 'Maintenance Sleep' … Using Batt (86%)
   … ciclos de sueno …
00:09:05  Wake … due to MTP.DOCK…/HID Activity     <- alguien toca el trackpad
pmset: sleep 1   (a bateria)
```

La señal que lo delata desde dentro de la propia medición: **un bucle de vigilancia
que no imprime NI UNA LÍNEA en diez minutos** — `delay` tampoco avanza con el Mac
dormido. **Regla: toda instalación va envuelta en `caffeinate -dimsu`**, y si una
vigilancia se queda muda, lo primero que se mira es `pmset -g log`, no la VM.

**Y una corrección de método que va escrita porque casi la doy por prueba:** dije
que el reloj del invitado parado demostraba la suspensión. **No demostraba nada**:
el invitado iba en **UTC** y el anfitrión en CEST, así que la hora «parada» era la
hora real. La prueba buena vino de **otro sitio** —el registro del anfitrión—, que
es justamente lo que la hace prueba.

## Cómo leer la pantalla de una VM cuando no puedes mirarla (2026-08-13)

Salió de §4.34l, cuando en mitad del diagnóstico dejaron de poder cargarse
capturas. **Es un instrumento nuevo del banco y vale para cualquier medición
futura sin ojos**, incluidas las máquinas de forma E3 que no llevan `ssh`.

**1. OCR nativo, sin dependencias.** 25 líneas de Objective-C contra el framework
Vision, compiladas con `clang -framework Vision`. Reconoce español e inglés y
devuelve el texto de la pantalla por líneas.

**2. Y va con su control, que es lo que lo hace utilizable:** antes de usarlo para
nada, se dispara **contra una captura que ya se ha mirado con los ojos** y se
comprueba que devuelve lo que allí ponía. Sin ese par, un OCR que devuelve poco no
se distingue de una pantalla vacía.

**3. Capturar la ventana de la VM, y no la del editor.** `screencapture` a pantalla
completa coge lo que esté delante, y **el propio proceso que lanza la orden roba el
foco**. Lo que funciona es hacerlo **todo dentro del mismo AppleScript**: activar
UTM, `AXRaise` de la ventana de la VM, leer su posición y tamaño, y llamar a
`screencapture -R` con `do shell script` **sin salir del script**. (`Quartz` no
está en el Python del sistema, así que la vía del `windowid` no sirve aquí.)

Con esto se leyó la pantalla que estaba bloqueando la medición —*«Se produjo un
problema · System program problem detected · sudo ubuntu-bug
ubuntu-desktop-bootstrap»*— sin gastar una sola captura de las que se miran.

---

## Leer un medio sin arrancarlo: `imagen/inventario-marca.sh` (2026-08-15)

**Se ejecuta en el Mac.** Inventaría **dónde aparece la marca de Ubuntu en una
ISO** —el medio entero, el instalador vivo y la sesión viva— leyéndola: no la
monta, no la arranca y no gasta VM. Es el instrumento de `MEDICIONES.md` §4.51, y
existe porque §4.27 hizo esa lectura **a mano** y no dejó guion.

```bash
./imagen/inventario-marca.sh medios/encina-os-E4-es-0.2.1-1224b5b1.iso
./imagen/inventario-marca.sh <iso> --trabajo <dir> --conservar   # reutiliza lo extraido
./imagen/inventario-marca.sh <iso> --sin-capas                   # sin los squashfs: planos 2 y 3 [OMIT]
```

Necesita `xorriso`, `unsquashfs`, `zstd`, `bsdtar` y `python3`. **Cuesta ~3,2 GB de
disco temporal**, porque las capas hay que sacarlas del medio; con `--trabajo` la
segunda vuelta es barata.

**NO APRUEBA NADA, y por eso su vocabulario está torcido a propósito:** cada
aparición de la marca sale como **`[AVISO]`**, porque una aparición no es un fallo
del medio, es trabajo del bloque 1. Los `[FALLO]` son **sólo de los cuatro
controles**, y van los primeros: si el buscador no sabe decir «no lo hay», su
lista de apariciones no vale nada. Sale distinto de 0 **sólo** si falla un
control.

**CAMBIÓ EL 2026-08-15, y el cambio es la diferencia entre un inventario y un
instrumento de comparación (§4.52e):**

1. **Lo que decide si un sitio es una aparición es EL VALOR, no el sitio.** Antes
   emitía `[AVISO]` por cada sitio inventariado dijera lo que dijera, así que un
   medio cuyo `grub.cfg` ya pone «Probar o instalar Encina OS» **seguía sumando
   una aparición y el número no podía bajar nunca**. Ahora el sitio que ya no dice
   Ubuntu sale como `[OK]`, y el resumen da **dos números**: apariciones y sitios
   que ya no la dicen.
2. **Lee el fichero EFECTIVO, no el de la capa de abajo.** Si el medio lleva capas
   que no son `minimal.*` —la de marca de Encina—, las saca y las extrae **encima**
   de las de Ubuntu, que es el mismo orden con el que casper monta el overlay. Sin
   esto diría `NAME="Ubuntu"` de un medio que en pantalla dice Encina.
3. **Su control (b) tiene un `.disk/info` de prueba que no puede salir de ningún
   medio real** (`Bellota 9.9 LTS…`). El anterior decía `Encina OS 0.3 LTS…` y
   **caducó el día que el medio empezó a llevar de verdad un `.disk/info` de
   Encina**: los dos daban lo mismo y el control salía `[FALLO]`.

**Las cuatro trampas que se comió al escribirlo, y las cuatro están en su
cabecera:**

1. **`unsquashfs -ll | awk '{print $NF}'` esconde el nombre de los enlaces
   simbólicos**, porque en un enlace la línea acaba en el **destino**. Escondía
   justo `view-app-grid-ubuntu-symbolic.svg`, el icono del botón de la rejilla.
   Es **la misma familia que `find -type f`** de §4.45c. El nombre es el **campo
   6**, y el control (d) del guion existe para vigilarlo.
2. **`awk … | grep -q` con `pipefail` convierte el acierto en fallo:** `grep`
   acierta, corta la tubería, `awk` muere de SIGPIPE y el estado es 141. Se
   detectó porque el `[FALLO]` contradecía a sus propios números. La lista se
   vuelca a un fichero **antes** de buscar en ella.
3. **macOS no monta esta ISO** (*«sistemas de archivos que no pueden montarse»*),
   así que `hdiutil` no sirve de atajo: las capas se sacan con `osirrox`.
4. **El `cwd` se resetea entre órdenes**, y `unsquashfs` con rutas relativas
   contesta **`rc=1` en 0,00 s**, que se lee igual que «esta capa no se puede
   listar». Todo va con rutas absolutas.

Y una quinta que no es del guion sino del medio: **`casper/initrd` son dos `cpio`
pegados** —el primero sin comprimir, y a partir de su `TRAILER!!!` uno **zstd**—,
así que `bsdtar` sobre el fichero entero lista sólo firmware y módulos y **no
avisa de que se ha dejado la mitad**. El tema de arranque está en la segunda.

---

## Poner la marca del medio: `imagen/capa-marca.sh` (2026-08-15)

**Se ejecuta en el Mac.** Fabrica **un solo fichero**,
`minimal.standard.live.encina.squashfs`, que es **toda la marca de la sesión viva
y del instalador** del medio. Lo mete
después `fabricar-iso.sh` en `/casper/`. Es el instrumento de `MEDICIONES.md`
§4.52 y la forma de `ENCINA-OS.md` **D23**.

```bash
./imagen/capa-marca.sh <iso> --salida <dir> [--trabajo DIR] [--conservar]
```

Necesita `xorriso`, `osirrox`, `unsquashfs`, `mksquashfs`, `sips` y `python3`.
**Cuesta ~3,2 GB de disco temporal** —sus controles leen las capas del medio de
verdad— y **~14 s** con `--trabajo` ya poblado. El directorio de `--trabajo` es
**el mismo que usa `inventario-marca.sh`**, a propósito.

**Lo que hay que entender antes de tocarlo, y son DOS cosas: el nombre de la
capa no es tipografía, es la CADENA — y la capa no se monta sola.**

`casper` entra por su rama de **multi‑capa**, porque el initrd trae
`LAYERFS_PATH` puesto en `/conf/conf.d/default-layer.conf`. Esa rama **no
enumera el directorio**: construye la lista **quitando puntos del nombre**, un
eslabón cada vez, y **hace `panic` si un eslabón no existe como fichero**. Luego
las antepone dos veces, con lo que **la más larga acaba la primera de
`lowerdir=`**, que en `overlayfs` es la que manda. Por eso la capa se llama
`minimal.standard.live.encina.squashfs` y **no puede llamarse de otra forma**:
cuelga de la cadena que el medio ya tiene. Un nombre mal puesto no da una capa
que no tapa — da **un medio que no arranca**.

Y **que la capa viaje no basta**: hay que nombrarla en la línea del núcleo con
`layerfs-path=`, que lo pone `fabricar-iso.sh` (§4.58). Sin esa bandera el medio
la lleva dentro y **no la monta nunca**, en silencio y sin fallar nada — que es
exactamente lo que pasó del **2026-08-15 al 20**.

El control (a) del guion reproduce ese bucle tal cual está en `casper` y sabe
decir que **no** con `zz-encina.squashfs`, que no tiene ni un punto que quitar.
Y hay banco aparte, `banco-cadena.sh`, más abajo.

> **LO QUE ESTE PÁRRAFO DECÍA HASTA EL 2026-08-20, y se deja al lado porque era
> falso:** *«el medio no lleva `layerfs-path=`, así que `casper` monta todos los
> `*.squashfs` de `/casper` —21— y el último por orden alfabético acaba el
> primero de `lowerdir=`; `zz-encina` va detrás de los `minimal.*`»*. El cero que
> lo sostenía era **verdadero**: se buscó `layerfs-path` —la grafía de la línea
> de órdenes— y **la variable de dentro se llama `LAYERFS_PATH` y vive en un
> `cpio` comprimido**. El orden alfabético **no pinta nada** en la rama que
> corre, y el `zz-` no servía de nada.

**La fuente está versionada en [imagen/marca/](imagen/marca/)** y no dentro del
guion:

| Fichero | Qué es |
|---|---|
| `disk-info` | los 43 bytes de `/.disk/info`. **Valen tres cosas**: el rótulo del icono del instalador (`25adduser`), el usuario y el nombre de máquina de la sesión viva (`casper`, primera palabra) y el número de serie (`57pollinate`, el paréntesis del final) |
| `whitelabel.yml` | la marca del **instalador**, puesta desde fuera de su snap: `app-name` es el título de la ventana, y `pages:` cambia los dibujos de las páginas con marca de Canonical |
| `slides/{1,2,3}/slide_{es_ES,en_US}.html` | las diapositivas propias. **Se sustituyen enteras y no se parchean**, porque `{{ DISTRO }}` es una constante del binario y no sale de ningún fichero |
| `sistema/…` | los seis ficheros de presentación: `os-release`, `lsb-release`, `issue`, `issue.net`, la sesión Wayland y el tema de texto de Plymouth |
| `sustituciones.tsv` | los activos gráficos de Canonical que se tapan **por bytes en su misma ruta**, con su origen en `encina-branding` y por qué. Lo que **no** está ahí, está escrito ahí también |

**El fondo se cambia por el FICHERO, no por el ajuste**, y no es pereza: el
`10_ubuntu-settings.gschema.override` que lo nombra está **compilado** dentro de
`gschemas.compiled`, así que reescribirlo no sirve de nada sin volver a compilar
los esquemas — y eso exige un Linux.

**Los cuatro controles van delante, y el cuarto es el que más vale:** cada
sustitución tiene que tapar un fichero que **existe** en las capas del medio
(182 625 rutas), porque *una sustitución que no tapa nada es un fichero de más en
el medio y un «hecho» que no ha pasado*. Detrás, la capa recién hecha **se
desempaqueta y se compara fichero a fichero y huella a huella** con lo que se le
metió (trampa 13), con el control de que la comparación sabe ver una lista a la
que le falta una línea.

**Y una comprobación que no es cosmética: la capa se fabrica DOS VECES y se
compara.** Sin fijar la fecha, `mksquashfs` guarda la hora de creación del
sistema de ficheros y la de cada inodo —y las de los inodos las pone `cp`—, así
que **dos pasadas daban dos huellas distintas** (medido: `a4947f30…` y
`63218c57…`). Una capa no reproducible **se lleva por delante la definición de
terminado de la ISO entera**, y el `[FALLO]` habría salido tres pasos más abajo,
donde parece un problema de `xorriso`. Se fija con `-mkfs-time`, `-inode-time` y
`-root-time` a `1770687951`, que es **la misma fecha que ya usa
`fabricar-iso.sh`** para lo que añade.

**Cuatro cosas del entorno que están resueltas dentro y conviene no deshacer:**
`-all-root` (en el Mac los ficheros son de `jorge` y dentro de la sesión viva
tienen que ser de `root`), `-no-xattrs` (macOS cuelga atributos extendidos de
todo lo que toca), `-noappend` (sin él, una segunda pasada **añade** al fichero
anterior en vez de rehacerlo, y la capa crecería sin que nadie lo viera) y las
tres opciones de fecha de arriba. Y `unsquashfs -lln` y no `-ll` para comprobar
el dueño: en macOS el gid 0 se llama `wheel` y `root/wheel` sería un rojo falso.

**Lo que este guion NO puede decir: que en pantalla se vea.** Eso lo dice
arrancar la ISO, y es `[OJOS]` de Jorge.

## El nombre del volumen del medio, dentro de `fabricar-iso.sh` (2026-08-17)

**No hay guion nuevo, y es deliberado.** El nombre del volumen —lo que un gestor
de discos enseña al conectar el USB, en cualquier sistema operativo y antes de
arrancar nada— **es un parámetro de `xorriso`**, así que vive donde vive la
receta: en `imagen/fabricar-iso.sh`. Es la cuarta casilla de
`tareas/marca-del-medio.md` y está medida en `MEDICIONES.md` §4.53.

**El guion pasa a hacer dos cosas más, en dos bloques nuevos:**

- **paso `5e`** — **deriva** el nombre y se niega si no cuadra. No lo escribe a
  mano: lo saca de `imagen/marca/disk-info` (todo lo anterior al `« - »`) y de la
  arquitectura que declara el `Volume id` de la ISO oficial. `Encina OS 0.2.1 - …`
  + `… arm64` = **`Encina OS 0.2.1 arm64`**. Se niega si el resultado dice
  «Ubuntu» —con el control de que la misma búsqueda **sí** lo encuentra en el
  nombre oficial—, si pasa de **32 bytes** (el límite del campo del PVD) o si el
  `.disk/info` no trae el separador.
- **paso `11`** — comprueba que quedó puesto. **Existe porque el paso 10 es ciego
  a esto:** el paso 10 compara la ISO nueva contra la oficial **fichero a
  fichero** y el `Volume id` **no es un fichero**. Y no comprueba uno: **lee
  todos los descriptores de volumen de la imagen** y exige que **todos** los
  primarios digan lo nuestro y que **ninguno** diga Ubuntu.

**Tres cosas que cuestan una tarde si no están escritas:**

1. **`xorriso -indev … -pvd_info` lee UNO y hay más de uno.** La ISO que sale de
   este guion tiene **cuatro** descriptores primarios —sectores 16, 32, 64 y
   80— porque el medio se escribe con `partition_offset=16`. Dar por bueno lo que
   contesta `-pvd_info` sería aprobar un medio que, leído por su partición,
   podría seguir diciendo otra cosa.
2. **El número de descriptores NO es del formato: cambia al remasterizar.** La
   oficial de Canonical trae **2 primarios y 2 Joliet**; la nuestra, **4 y 0**.
   O sea que **`xorriso` se lleva el Joliet por delante**, y eso pasa **desde
   E3**. Ninguna comprobación puede esperar un número fijo ni calibrarlo contra
   la ISO de entrada.
3. **Los avisos de `xorriso` al escribir NO son nuestros.** Dice
   *«-volid text does not comply to ISO 9660 / ECMA 119 rules»* y *«problematic
   as automatic mount point name»*, y los dice **igual sin pasar `-volid`**:
   son del nombre que ya trae el medio oficial, porque `Ubuntu 24.04.4 LTS arm64`
   tampoco cumple la norma —minúsculas y espacios—. Lo nuestro **hereda la misma
   infracción, ni una más**. Está medido con su control (§4.53c) y escrito en la
   cabecera del guion; si algún día aparecen más de dos avisos de más, ahí sí hay
   algo que mirar.

**Y una del entorno, que muerde al leer el medio y no al escribirlo:**
`unsquashfs` de las capas grandes **muere a mitad en macOS** —*«FATAL ERROR:
write_file: … `xt_connmark.h` already exists»*— porque el disco del Mac no
distingue mayúsculas. Son **10 colisiones** en `minimal.squashfs` y **47** en
`minimal.standard.live.squashfs`, contadas con
`tr 'A-Z' 'a-z' | sort | uniq -d` sobre el listado. Con `-f` la extracción
termina y sólo se pierde una de cada pareja, **que se puede nombrar**. Sin `-f`,
y con la salida redirigida, queda un árbol truncado que `du -sh` describe como si
estuviera entero.

**Lo que estos bloques NO pueden decir: que el medio arranque.** Lo que sí está
medido es que **ninguno de los cuatro mecanismos que encuentran el medio mira la
etiqueta** —`casper` va por contenido y UUID, el GRUB firmado hace
`search --file /.disk/info`, `apt-cdrom` lee `.disk/info` y `subiquity` va por la
ruta `/cdrom`— y que la cadena de arranque sale **byte a byte idéntica**.
Arrancarlo es `[OJOS]` de Jorge.

## Y cuatro más, todas del 2026-08-17 al dar la vuelta única

**28. `utmctl start` devuelve 0 cuando falla.** Escribe
`Error from event: The operation couldn't be completed. (OSStatus error -1712.)`
por **stderr** y sale con **código 0**, así que cualquier `utmctl start … || fallo`
es código muerto. `construir-todo.sh` lo tenía, la VM no arrancó, el guion imprimió
`[OK] VMs encendidas: 0` **justo después de decir que encendía una**, y acabó
diciendo `[FALLO] el constructor no contesta por ssh` — que manda a mirar al sitio
equivocado. **No te creas el código de salida: espera al ESTADO** (`utmctl status`
hasta `started`, con tope). Arreglado en el guion.

**La causa de fondo, por si vuelve:** UTM vivo pero con **la conexión interna
caída** — contesta a lecturas (`utmctl list`, `get name of every virtual machine`)
y falla al arrancar con `-1712` por `utmctl` y **`-609 La conexión no es válida`**
por AppleScript. **Se arregla reiniciando UTM.** Antes de hacerlo, respalda
`com.utmapp.UTM.plist` y comprueba las dos mitades después (trampa 18).

**29. Un mismo ajuste tiene DOS nombres, y buscar uno no dice nada del otro.**
La marca de la sesión viva se apoyaba en que *«el medio no lleva `layerfs-path`»*,
buscado en el `grub.cfg`, la ESP y el resto de la imagen: **0 apariciones, y era
verdad**. Pero `casper` lo lee de la variable **`LAYERFS_PATH`** —con subrayado—,
que vive en `/conf/conf.d/default-layer.conf` **dentro del `initrd`**, o sea en un
cpio comprimido donde ningún `grep` sobre la imagen llega. Coste: una capa entera
que **no se monta nunca** (`MEDICIONES.md` §4.54e). **Regla: cuando concluyas «no
está», di en qué grafía lo buscaste y dónde NO miraste.**

**30. Un `[OK]` sobre un fichero del medio no dice que el sistema lo use.**
`inventario-marca.sh` lee los ficheros de la capa dentro de la ISO y los cuenta
como «sitios que ya no dicen Ubuntu». En marcha, `/etc/os-release` decía
`NAME="Ubuntu"` mientras el inventario declaraba `PRETTY_NAME="Encina OS 24.04
LTS"`. **No es un fallo de lectura: es que «está en el medio» y «se monta» son dos
cosas, y el instrumento sólo mide la primera.**

**31. Dos caracteres más que no llegan al invitado con `teclear-vm.sh`: `|` y
`&`.** Se suman a `=` y `@`. `ls /cdrom/casper/ | tail -n 4` llegó sin la tubería
y ejecutó otra cosa. **Los subrayados sí llegan** (`ubuntu_bootstrap.log`, medido).
Escribe las órdenes **sin tuberías y una por línea**, y mira la pantalla antes de
Intro.

**32. Dos bundles de UTM con el MISMO `Drive.Identifier` no arrancan.** Al
fabricar VMs clonando el guion con `sed` es fácil cambiar nombre, UUID, MAC e ISO
**y olvidar los identificadores de las unidades**. El síntoma no dice nada:
**pantalla negra indefinida, disco a 0 bloques y el `debug.log` de QEMU congelado
en ~2 700 bytes**, frente a los ~110 KB de una que arranca. Con identificadores
propios arranca a la primera. **Costó dos controles que parecían decir que dos
ISOs no arrancaban, y no era verdad** (`MEDICIONES.md` §4.54h). El `debug.log`
congelado es la señal que lo separa de «tarda mucho».

**33. La segunda palabra de `/.disk/info` es un NÚMERO DE VERSIÓN, no parte del
nombre.** `subiquity/server/controllers/refresh.py` hace
`release = info.split()[1]` y construye con ella el canal de snap del propio
instalador (`stable/ubuntu-<release>`). Un `.disk/info` que diga
`Encina OS 0.2.1 …` pide `stable/ubuntu-OS` y **el instalador se cae en silencio**
—sin volcado, sin error en el `journal` y sin `Traceback`—. Ese campo lo usan
**tres** cosas a la vez: el canal, el rótulo del icono (`25adduser` toma las dos
primeras palabras) y el `Volume id`, que se deriva de aquí.

> **ENMIENDA del 2026-08-19: «que sea un número de versión» NO BASTA, y esto es lo
> que decía de menos.** La comprobación que salió de esta trampa exigía
> `^[0-9]+(\.[0-9]+)*$`, y **`0.2.1` la pasaba**: es un número de versión. Pero
> `stable/ubuntu-0.2.1` **no existe** igual que no existía `stable/ubuntu-OS`, así
> que la regla dejaba pasar el mismo defecto con otra cara. Los únicos
> `stable/ubuntu-*` que existen son los de las **releases de Ubuntu**, o sea que la
> segunda palabra tiene que ser **la de la base** (`24.04.4`), no una versión
> cualquiera y desde luego no la nuestra. El paso 5b lo compara ya contra la 2ª
> palabra de la ISO oficial. Y **el nombre del producto va en la PRIMERA palabra**,
> que es lo único que queda nuestro: `EncinaOS 24.04.4 - Release arm64 (…)`.
> Lo que se creía y era falso queda arriba a propósito (`MEDICIONES.md` §4.56b).

**34. Más caracteres que no llegan al invitado con `teclear-vm.sh`:** a `=` y `@`
se suman **`|`, `&`, `>`, `"`, `[` y `]`**. O sea que **no se pueden teclear
redirecciones, tuberías, comillas ni índices**. Para capturar la salida de una
orden, `script -c <orden> <fichero>` funciona sin ninguno de ellos. Y ojo:
`ubuntu-desktop-bootstrap` lanzado desde el terminal **sale en el mismo segundo
con código 0** sin imprimir nada — no arranca otra instancia, sólo le da el foco a
la que ya corre, así que por ahí no se le saca el error.

## Bisecar la marca del medio: una bandera por mecanismo, dentro de `fabricar-iso.sh` (2026-08-19)

**El instalador gráfico se cae con los cuatro mecanismos de D23 puestos y arranca
sin ninguno** (`MEDICIONES.md` §4.54i, tres ISOs en bundles idénticos). Para
saber cuál de los cuatro es hay que fabricar medios que lleven tres y les falte
uno, y **eso el guion no lo sabía hacer**: la capa y el `Volume id` estaban
clavados. Desde hoy hay **una bandera por mecanismo**:

```
./imagen/fabricar-iso.sh --repo <dir> --salida <iso> [--sin-capa] [--sin-volid]
                                                    [--sin-info] [--sin-menu]
./imagen/construir-todo.sh … --sin-capa        # las pasa tal cual, no las interpreta
```

- `--sin-capa` — no se fabrica ni se añade
  `/casper/minimal.standard.live.encina.squashfs`, **y tampoco se pone el
  `layerfs-path=`**. Las dos cosas van juntas a propósito: un `layerfs-path=`
  apuntando a una capa que no viaja hace que `casper` haga **`panic`**, o sea un
  medio que no arranca por culpa del bisecado y no de lo que se bisecaba
- `--sin-volid` — el `Volume id` sigue siendo `Ubuntu 24.04.4 LTS arm64`
- `--sin-info` — el `/.disk/info` viaja **intacto**, el oficial
- `--sin-menu` — el `menuentry` sigue diciendo `Try or Install Ubuntu`

**El `locale=es_ES.UTF-8` NO tiene bandera, y no es un olvido:** ya viajaba en
`1224b5b1…`, que es una de las dos ISOs cuyo instalador **arranca**, así que no
está bajo sospecha. Las banderas son **para bisecar, no para el producto**: sin
ninguna sale el producto, y con cualquiera de ellas el guion lo dice en su primer
bloque y otra vez en el resumen.

**LA TRAMPA DE UN GUION CON BANDERAS, que es lo que obligó a escribir el paso 13:**
todas las comprobaciones del guion derivan sus expectativas **de la misma bandera
que dicen comprobar** —si `--sin-capa` no hiciera nada, el paso 10 esperaría la
capa, la encontraría y daría `[OK]`—. Por eso el **paso 13 abre la ISO terminada y
pregunta qué lleva**, sin mirar ninguna variable intermedia, y **no busca nombres
nuestros**: cuenta los `squashfs` de `/casper`, compara `.disk/info` con el de la
oficial y busca el título **oficial** del menú. Un lector que buscara «Encina»
estaría de acuerdo con el guion por construcción.

**Y ese lector tiene banco propio, que cuesta segundos en vez de 20 minutos:**

```
./imagen/fabricar-iso.sh --leer-mecanismos <alguna.iso>   # imprime «capa volid info menu»
./imagen/banco-mecanismos.sh                              # los cuatro medios del disco
```

Los casos son **medios reales con su arranque ya medido**, y el control va dentro:
tres tienen que dar `0 0 0 0` —la oficial, `ac0a5721…` y `1224b5b1…`, que son las
**tres cuyo instalador funciona**—. Un lector mudo falla ahí. **Gastado el
control:** con un directorio de medios trucado por enlaces duros —la ISO oficial
con el nombre de la que lleva los cuatro— el banco dice `[FALLO]` **en los dos
sentidos** y sale con código 1.

**El 2026-08-20 cambia la REGLA de la columna «capa», y con ella dos casillas**
(§4.58). Hasta ese día el lector daba la capa por presente con sólo ver un
`squashfs` de más en `/casper`; desde ese día exige **además** que el núcleo la
nombre con `layerfs-path=`, porque **un fichero que nadie monta no es un
mecanismo**. Con la regla nueva `e8a0ead2…` y `71f7958c…` pasan de `1 1 1 1` a
`0 1 1 1`, y **eso es una descripción más verdadera de lo que llevaban**. Se deja
escrito al lado lo que las casillas esperaban antes, dentro del propio banco.

> **Y se lleva por delante una premisa de §4.54i:** el bisecado que dejó la
> regresión «dentro del grupo de D23» varió una capa **inerte**, así que lo que
> allí se llamó «la capa» significaba sólo *«un fichero de más en `/casper`»*. No
> invalida el bisecado —la regresión sigue dentro del grupo— pero sí lo que se
> creía que era una de sus cuatro piezas.

**Y el banco estrena un control por COLUMNA, que le faltaba desde el principio:**
que haya ejecutado casos no basta; si **una** de las cuatro columnas sale
constante entre los casos que de verdad corrieron, un lector que contestara
siempre lo mismo **en esa columna** pasaría en verde. Lo primero que dijo al
estrenarlo fue justo eso —sin un medio con `layerfs-path=` no podía distinguir un
lector bueno de uno mudo en la columna de la capa—, y se calló al fabricar
`p10-capa`. **Ese control no suma a «correctas»**: describe la tabla de casos, no
una lectura, y sumarlo daba un «correctas: 3» con los cinco casos en rojo.

## El banco de la cadena de capas: `imagen/banco-cadena.sh` (2026-08-20)

**Es el banco más caro de no tener.** `casper` construye la lista de capas
**quitando puntos del nombre** y hace **`panic`** si un eslabón no existe como
fichero. Un nombre mal calculado no da una capa que no tapa: da **un medio que no
arranca**, y eso se descubre veinte minutos de construcción y un arranque más
tarde. Esto son **segundos**.

```bash
./imagen/banco-cadena.sh
```

**Extrae `cadena_de` y `lowerdir_de` de `capa-marca.sh`** en vez de recopiarlas, y
**se niega a medir si la extracción sale corta** —menos de dos funciones o menos
de doce líneas—, porque un banco sobre un guion vacío contesta que sí a todo.

**El caso que manda es el primero y no es inventado:** es el `lowerdir=` que el
invitado imprimió de verdad en `/proc/mounts` el 2026-08-17 (§4.54e) con el
`LAYERFS_PATH` que trae el initrd. Si la reproducción no saca **esa** cadena, no
reproduce nada y lo demás no vale. Y hay un caso que comprueba que el orden
**no** es el alfabético: si pasara, la reproducción estaría copiando la **rama
muerta** de `casper`.

**Gastado con tres sabotajes**, los tres cazados y con código 1 —el sano da 0—:
`cadena_de` anexando en vez de anteponer (3 fallos, y uno es el caso medido),
`lowerdir_de` sin invertir (2 fallos, igual), y las funciones renombradas en el
guion, que dispara el rechazo de la extracción.

## Cuatro más, bisecando la marca del medio (2026-08-19)

**35. El `_` NO llega al invitado: llega como `?`.** Se suma a `= @ | & > " [ ]`.
Medido con su control en la misma orden —el `-` y el `.` sí llegan—:

```
tecleado:     echo A_B-C.D
en pantalla:  echo A?B-C.D   ->   A?B-C.D
```

**Y es peor que las otras del grupo, porque puede dar un verde falso en vez de un
error:** `?` es **comodín del shell**, así que
`tail /var/log/installer/ubuntu?bootstrap.log` **funciona** —casa con el fichero
de verdad— y con dos ficheros parecidos habría leído otro sin decir nada. Casi
todos los registros del instalador llevan `_` en el nombre.

**36. Hay TERMINAL dentro de la sesión del instalador caído, y es la vía que no se
había usado.** Con el diálogo «Se produjo un problema» en pantalla, `Alt`+`F2`
abre «Ejecutar una orden» y desde ahí `gnome-terminal` arranca. La sesión viva
está entera. **Lo que NO se consigue por teclado: pulsar «Mostrar registro»** —ni
`Tab` ni `Shift`+`Tab` mueven el foco visible, y el ratón de UTM no llega—.

**37. `construir-todo.sh --conservar --trabajo <dir>` NO sirve para reutilizar el
repo en otra construcción.** La segunda pasada muere en su propio control:

```
[FALLO] CONTROL ROTO: sin autofirma esperaba 27 .deb y hay 28
```

y es correcto: la cosecha exige empezar **en limpio** y el directorio conservado
ya trae AutoFirma. Para repetir sólo la ISO —que es lo que pide un bisecado, donde
**ningún `.deb` cambia**— se llama directamente a `fabricar-iso.sh --repo <ese
dir>`, que **coteja las cuatro huellas antes de usarlas**, así que no se está
dando nada por bueno.

**38. Una VM en negro no siempre está colgada, y hay dos señales que lo separan.**
El primer arranque del medio de bisecado dio pantalla negra con el cursor de X a
los 7 minutos. **No era la trampa 32:** el `debug.log` crecía (70→97 KB, no
congelado en ~2 700 bytes) **y la VM tenía IP en el `arp` del anfitrión**
(`arp -a | grep <su MAC>`), o sea que el sistema live había arrancado y estaba en
red. En el segundo arranque del **mismo** medio salió el instalador. Así que
`[AVISO]` y repetir: una pantalla negra suelta no es un resultado.

**39. Borrar una VM del banco no libera nada si su ISO es enlace duro, y `utmctl`
tiene `delete`.** Las dos cosas medidas el 2026-08-19 antes de tocar el disco.
`fabricar-vm-medio.py` mete la ISO en el bundle **por enlace duro**, así que la
copia de `medios/` y la de dentro del `.utm` son **el mismo inodo**:

```
2 90304989 3717595136 medios/encina-os-bisec-sin-capa.iso
2 90304989 3717595136 …/encina-bisec-sin-capa.utm/Data/medio.iso
   ^ nlink   ^ inodo, el mismo
```

Con `nlink=2`, borrar **una sola** de las dos copias deja los 3,5 GiB donde
estaban y `df` no se mueve. Hay que borrar **las dos**, y la forma de saberlo
antes es `stat -f '%l %i %z %N'`, no acordarse. Y para la VM, **`utmctl delete
<nombre>` existe**: desregistra *y* borra el bundle en una orden. Borrar el
bundle a mano deja la VM **en el registro de UTM sin bundle detrás** —que es
exactamente lo que le pasó a `encina-marca-ac175f64`, que sigue en `utmctl list`
y no aparece en `inventario-vms.sh`—.

**41. El TAMAÑO del PNG distingue las tres pantallas sin abrirlo.** Medido sobre
las diez capturas del 2026-08-19, con `capturar-vm.sh` y la misma ventana:

```
~ 73 000 – 112 000 bytes   NEGRA          (no es un resultado, trampa 38)
~270 000 – 290 000 bytes   registro de systemd en texto
~670 000 – 780 000 bytes   sesion GRAFICA (escritorio, instalador o su dialogo)
```

Sirve para **decidir si merece la pena mirarla**, no para decir qué pone: tres
capturas negras seguidas dieron **exactamente 112 446 bytes** las tres, que además
es señal de que la pantalla no cambia entre ellas. Un `stat -f %z` cuesta cero y
ahorra abrir capturas que no dicen nada.

> **ENMIENDA DEL MISMO DÍA, y la tumbó una captura: LOS TAMAÑOS SÓLO VALEN A
> ESCALA FIJA.** Una pantalla **gráfica** dio **309 568 bytes** —dentro del rango
> que esta trampa asignaba a «registro de texto»— porque la ventana se capturó a
> **1280×840** y las anteriores a **2560×1680**. `capturar-vm.sh` toma el tamaño
> **de la ventana**, y la ventana cambia. **Compara tamaños sólo entre capturas de
> la MISMA sesión y la misma ventana**, y si la escala cambió, el número no dice
> nada: hay que abrirla. Lo que sí se sostiene es lo otro —tres capturas idénticas
> al byte significan que la pantalla no se mueve—. Escribí la regla sin este
> control y era demasiado ancha.

**40. `grep -r` SIN `-a` SE SALTA LOS BINARIOS Y DEVUELVE UN CERO FALSO.** Cazada
el 2026-08-19 buscando quién lee `.disk/info` dentro del snap del instalador. La
conclusión fue «sólo dos ficheros Python», **y era falsa**:

```
grep -rl  'disk/info' snapfs | grep -v '\.py$'   ->  hooks/install, ubuntu-image.rst
grep -ral 'disk/info' snapfs | grep -v '\.py$'   ->  bin/lib/libapp.so   <- ESTE FALTABA
```

`libapp.so` es **justo** el binario de la interfaz Flutter, o sea el que §4.55
midió que es el que se corta. Un cero de `grep -r` sobre un árbol que mezcla
texto y binarios **no significa «no está»**: significa «no está en los ficheros
que grep decidió leer». **Siempre `-a` al buscar en un árbol extraído** (un snap,
un squashfs, un `.deb` desempaquetado), y si lo que se busca es una cadena dentro
de un ejecutable, `strings -a` **con su control** —una cadena inventada tiene que
dar 0 y una que sabes que está tiene que dar más de 0—. Es la misma familia que
`timeout` en §4.54 y el banco de §4.51: **el instrumento contestó que no había
nada porque ni siquiera miró.**

## Y una más, montando la capa (2026-08-20)

**42. UNA PANTALLA NEGRA REPETIDA UNA VEZ SIGUE SIN SER UN RESULTADO. En este
anfitrión el arranque gráfico del medio FALLA A VECES.** Es la trampa 38 subida
de nivel, y hoy costó una causa escrita y dos horas de bisecado.

`p14-plymouth` dio **pantalla negra** en su primer arranque: dos capturas
idénticas, `debug.log` estabilizado en el **rellano de ~92 KB** —el mismo al que
llegan los medios que sí arrancan—, `systemd` entero en `[ OK ]` en la captura de
texto e **IP en el `arp`**. Con eso se escribió que `ubuntu-text.plymouth` era la
causa, **por suficiencia**, con los otros 24 ficheros constantes. **El segundo
arranque del MISMO medio, sin tocar nada, fue al escritorio entero** con el
instalador en español.

```
p14, arranque 1 -> NEGRA
p14, arranque 2 -> ESCRITORIO            <- mismo medio, mismo bundle, nada tocado
```

**Lo que hay que hacer distinto, y es caro:** un arranque **no es** una medición
y dos tampoco cuando el fallo es intermitente. Un «arranca» vale a la primera
—es un positivo—; un **«no arranca» hay que CONTARLO**, con N arranques del medio
en cuestión y N de un control conocido-bueno en el mismo rato. Un bisecado
construido sobre «negras» sueltas **no es un bisecado**: las cuatro comparaciones
de §4.58 se cayeron a la vez cuando cayó la primera.

**Y las dos señales de la trampa 38 no sirven para separar esto**, porque las dos
dicen «viva» en los dos casos. Lo único que separó fue **repetir**.

**43. El tamaño del `squashfs` NO dice que el contenido sea el mismo.** Quitando
seis ficheros de texto de la capa, `mksquashfs` dio **exactamente los mismos
3 084 288 bytes** que la capa entera —relleno de bloque—. Si se hubiera dado por
hecho que «pesa igual, será la misma», el bisecado entero habría medido dos veces
la misma capa. Se comprueba **por contenido y por huella**: `unsquashfs -ll` con
la ruta de cada fichero que tiene que faltar, **más un control** de uno que tiene
que seguir estando, y `shasum` de las dos capas.

## Contar arranques sin ojos: los tres guiones del 2026-08-21

Salieron de la tarea de acotar el fallo intermitente del banco (§4.59), y el
orden en que se escribieron **es** el método: primero el veredicto y su banco,
después el experimento, y sólo entonces los datos.

### `scripts/veredicto-pantalla.py` — qué hay en una captura, contado

```bash
./scripts/veredicto-pantalla.py <captura.png> [--recorte-superior N] [--tsv]
```

Devuelve `NEGRA`, `GRAFICA`, `TEXTO?` o `INDETERMINADA` contando **colores
distintos** (cuantizados a 5 bits por canal) y el **brillo medio**. La separación
medida es de más de dos órdenes de magnitud:

```
pantalla negra de verdad        1 color      brillo   0,0
instalador, fondo de Ubuntu   585 colores    brillo 176,7
instalador, fondo de Encina  3 638 colores   brillo 194,6
escritorio con la capa       4 349 colores   brillo  95,3
```

**No usa el tamaño del PNG, y ese es el motivo de que exista** (trampa 41): el
tamaño sólo separa las tres pantallas a escala fija. El conteo de colores no
depende de la escala, y el banco lo comprueba reduciendo los controles a la mitad.

**La zona gris es deliberada.** Entre las dos bandas calibradas hay hueco y ahí
contesta `INDETERMINADA`: un instrumento que se calla donde no sabe vale más que
uno que decide. `TEXTO?` se declara **sin control conocido** y no se da por buena.

**DE DÓNDE SACAR LA CAPTURA, que resultó ser la mitad del instrumento.** UTM
escribe `screenshot.png` en el bundle con el **framebuffer del invitado** —
1280×800 fijos, sin barra de ventana, sin permiso de Grabación de Pantalla —, y
**la trampa 41 no le aplica porque no hay ventana de por medio**. Con dos
condiciones medidas:

```
VM corriendo, 3 min  ->  mtime intacto: NO se actualiza en vivo
utmctl stop          ->  lo reescribe, y con el framebuffer REAL:
                         parada desde el instalador  -> 3 638 colores
                         parada tras fallar          ->     1 color
```

La segunda mitad es la que importa: sin ella, un negro tras parar podría ser el
framebuffer ya apagado y **el instrumento diría «negra» siempre**.

### `scripts/banco-veredicto.sh` — su banco (segundos)

**9 correctas, 0 fallos.** Extrae la regla de `veredicto-pantalla.py` entre los
marcadores `INICIO REGLA`/`FIN REGLA` y **se niega a medir si sale corta**
(≥12 líneas, ≥4 umbrales, ≥4 salidas distintas). Cuatro secciones: las dos
respuestas sobre capturas de verdad, **control por columna** (negra y gráfica no
pueden dar el mismo veredicto), **la trampa 41** (los controles a 640×400 dan el
mismo veredicto) y **tres sabotajes**, los tres cazados.

Los controles viven en `scripts/pruebas/veredicto/` y son capturas reales, no
imágenes fabricadas para pasar. El que **aprieta el umbral por abajo** es
`control-grafica-fondo-ubuntu.png`: con la capa inerte el fondo es el púrpura de
Ubuntu y da sólo **585 colores**, el gráfico más pobre que hay.

### `scripts/contar-arranques.sh` — el experimento

```bash
./scripts/contar-arranques.sh --rondas 6 [--ventana 420] [--salida DIR]
```

Arranca los brazos **intercalados ronda a ronda**, nunca en bloques: la carga de
este anfitrión deriva, y en bloques la deriva se confunde con el efecto. Ventana
**fija e idéntica** para todos, **sin prórroga** — una prórroga sólo se dispararía
en los arranques que van mal, o sea daría trato distinto justo a lo que se cuenta.

**LA COMPROBACIÓN QUE NO SE PUEDE QUITAR** (trampa 13, y aquí muerde de verdad):
como UTM sólo reescribe `screenshot.png` al parar, se compara el `mtime` de antes
con el de después. Si no cambió —`stop` que falló, VM que ya estaba parada,
`utmctl` devolviendo 0 sin hacer nada (trampa 28)— se estaría leyendo **el
framebuffer del arranque anterior** y contando dos veces el mismo dato. Esa línea
sale `FALLO-SIN-CAPTURA` y **no cuenta como arranque**.

### `scripts/veredicto-conteo.py` — el criterio, aplicado por un guion

```bash
./scripts/veredicto-conteo.py <arranques.tsv>
./scripts/veredicto-conteo.py --banco
```

Aplica **el criterio escrito antes de empezar** (§4.59a) y nada más: Fisher
exacta de una cola con `p ≤ 0,05`, mínimo de rondas completas, y la prueba
primaria de que basta con que **un control** falle. Su banco: **8 correctas, 0
fallos**, con control por columna y una comprobación de que la cola es la
declarada.

**Por qué un guion y no yo:** quince arranques con tasas cerca del 50 % se leen
después como uno quiera. `3 de 5` frente a `5 de 5` **parece** peor y da
`p = 0,095`. El guion no negocia.
