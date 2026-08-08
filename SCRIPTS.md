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
- **Y comprueba la CA del socket en el perfil de Firefox, por huella.** Es el
  paso 4 de la secuencia, y sin él la firma no sale aunque todo lo demás esté en
  verde. Tres salidas, las tres con su significado escrito: sin perfil todavía
  (`[OMIT]`, es lo normal en una máquina virgen y explica el paso 4), con perfil
  y sin CA (`[FALLO]`, es el defecto), y con una CA de apodo correcto pero huella
  distinta (`[FALLO]`, que es una instalación anterior). Solo usa `certutil -L`,
  nunca `-A`, por la trampa 7.

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
positivo. La línea base virgen de la que salen los clones nuevos es de la otra
familia. **Un resultado visual medido en una no vale automáticamente en la otra**,
y eso mira hacia atrás: el `[OMIT]` del splash de Plymouth se midió en
`encina-dev`, que es `virtio-gpu-pci`.

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
