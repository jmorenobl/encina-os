# Mediciones de Encina OS

Registro de lo medido, con las salidas literales de los comandos. **No se
resume aquí nada: se conserva tal como se escribió el día que se midió**,
correcciones incluidas. Reproducir estas mediciones cuesta sesiones de máquina
virtual, y buena parte ya no se puede reproducir porque el `.deb` oficial de
AutoFirma que las produjo ha dejado de ser el que Encina OS usa.

Última actualización: 11 de agosto de 2026.

**La numeración `§4.x` y `§9` se conserva a propósito.** Estas secciones vivían
en `ENCINA-OS.md` hasta el 2026-08-08 y se citan por ese nombre desde
`AGENTS.md`, desde `SCRIPTS.md` y desde el `MEDICIONES.md` del repositorio
`encina-autofirma`. Renumerarlas rompería las referencias sin ganar nada.

**La única que sí se ha renombrado es la de `encina-locale-es`**, que era «§6.1»
y ahora es «A3». El motivo es que `ENCINA-OS.md` tiene hoy su propia §6.1 —la
supresión de `encina-doctor`— y dos secciones distintas con el mismo número, las
dos citadas, son una trampa esperando.

Las mediciones del `.deb` propio de AutoFirma —la cadena de compilación, el
parche del configurador, las rutas de preferencias de Firefox, el primer
positivo de extremo a extremo— **no están aquí**: viven en
`~/Projects/encina-autofirma/MEDICIONES.md`, M1 a M13.

---

## Cómo leer esto

Tres cosas se repiten en todo el registro y son lo que le da valor:

- **Lo medido y lo deducido van separados**, y cuando una deducción resultó
  falsa se dice, con lo que se creía al lado.
- **Ninguna comprobación vale sin su control.** Varias de las mediciones de
  aquí abajo salieron mal la primera vez porque el control negativo no era
  negativo.
- **Lo que solo se sabe mirando la pantalla se marca**, y no se da por bueno de
  otra manera.

### Estado de vigencia, en una tabla

| Sección | Qué mide | ¿Sigue vigente? |
|---|---|---|
| §4.1 | AutoFirma 1.9 oficial sobre Firefox nativo | Sí como retrato del `.deb` **oficial**. Su prueba de firma no discrimina: se hizo en la sede de la DGSFP (§4.9b) |
| §4.2 | Remedición: tres perfiles, CA residual, decidibilidad estática | Sí, y es la base de cómo se elige un perfil |
| §4.3 | Ubuntu de fábrica con Snap | Sí lo estático. Su prueba de firma, no (§4.9b) |
| §4.4 | La tercera barrera: el manejador invisible en el Snap | Sí, y es la que sostiene que el Firefox nativo es condición necesaria. Se sostiene por el `XDG_DATA_DIRS`, no por la prueba de firma |
| §4.5 | Qué está arreglado upstream y qué no | Sí. Es el estado del arte del que salen las PRs |
| §4.6 | Estrategia de fork | Ejecutada. Histórico |
| §4.7 | ¿El `.deb` corregido hace innecesario el Firefox nativo? | **Sí, y es la sección más importante para el producto de hoy.** La respuesta es no |
| §4.8 | Forma del fork: tres repositorios | Ejecutada. Histórico |
| §4.9 | El primer positivo de extremo a extremo, y las seis barreras | Sí. **Pero la VM donde ocurrió ya no existe**: se destruyó porque contenía un certificado personal de la FNMT (`ENCINA-OS.md` §9.1). El positivo está medido; el estado bueno no es conservable |
| §4.10 | R10 y `encina-meta`: por qué vía llega Firefox nativo | Sí **para las máquinas con Snap**, que son todas las de E1. Es lo que decide que E1 no se para, y corrige el motivo escrito en `AGENTS.md` §6.3. **Su apartado (h) queda corregido por §4.11c**, y **su premisa (a) deja de valer en una máquina sin Snap** (§4.16j): al purgar `snapd` se va también el `.deb` `firefox` de transición, así que ya no hay nada que sustituir |
| §4.11 | E1 ejecutado en una VM con escritorio | Sí. Cierra lo que §4.10 dejaba deducido, y tumba el `Recommends: libreoffice-l10n-es` con su motivo escrito |
| §4.12 | El positivo sobre una máquina virgen instalada por la secuencia | Sí. Las seis barreras cerradas ahí, **y el defecto de orden que dejaba AutoFirma sin CA en el navegador — cerrado el 2026-08-09, con la enmienda dentro del propio apartado (a)**. Contiene además la única técnica conocida para mirar la pantalla de una VM sin ojos |
| §4.13 | La casilla que decide de E1, marcada: la secuencia de tres órdenes basta | Sí. Es el positivo que cierra E1, y **no se puede volver a contrastar contra ninguna máquina**: la VM llevaba certificado personal y se destruyó (§9.1) |
| §4.14 | E2: la ISO oficial de escritorio honra un `autoinstall` mínimo, y a qué precio | Sí. Es la medición de apertura de E2, y **corrige a `DIARIO.md` y a `ENCINA-OS.md` §6**, que daban por hecho que la línea base se había instalado por `autoinstall` |
| §4.15 | El repo local sin firmar, y la casilla novena de E1 | Sí. **Cierra la última casilla de `AGENTS.md` §6.4**, y con el mecanismo de verdad en vez del A/B del 2026-08-08 |
| §4.16 | E2: ninguna clave del seed quita el clic (leído), y el Snap sí se quita desde el seed (medido) | Sí. Da la orden concreta que quita el Snap y **descarta la vía obvia, que no falla sino que miente**. Lo que su apartado (j) dejaba abierto lo cierra §4.17 |
| §4.17 | Por qué vía llega Firefox nativo sin deb de transición | Sí. **La secuencia de §6.4 sigue valiendo, pero el paso 4 pasa a ser también el navegador**, no solo el idioma. Y saca un defecto visible **que es de E1, no de E2**: dos iconos de Firefox, medido en los dos mundos |
| §4.18 | **El seed de verdad, escrito y medido entero** | Sí. Es la receta de E2 —`imagen/`— y la máquina que produce, en una sola pasada y sin humano. Contesta lo que §4.16l dejaba pendiente (**hay red desde el chroot**) y lo que §4.17i dejaba colgando (**el vigilante de AutoFirma funciona sin Snap**). Y **enmienda una casilla de `AGENTS.md` §6bis.3**: la tercera condición de «Sin Snap» no la puede cumplir ninguna máquina de Encina OS mientras `encina-firefox-native` ponga su sombra `.desktop` |
| §4.19 | La sombra `.desktop`: un solo icono, y la casilla que pedía romper A2 | Sí. **Corrige la tercera condición de «Sin Snap» de `AGENTS.md` §6bis.3, que estaba escrita al revés**, y le añade la que no tenía nadie: cuántos iconos ve el usuario. El arreglo es `NoDisplay=true` en `encina-firefox-native` 0.2.1, elegido midiendo el espacio entero en los dos mundos |
| §4.20 | La firma sobre la máquina del seed, y la contraseña que no existía | Sí. **Cierra E2, 6 de 6.** La firma es `[OJOS]` y la declara Jorge. Contiene el defecto del seed —nadie sabía la contraseña— y la trampa 15: `crypt` de Python en macOS cae a DES sin avisar |
| §4.23 | **E3: la ISO existe y se instala** | Sí. **Es la medición que cierra E3.** Una ISO construida por `imagen/fabricar-iso.sh`, en una **VM creada desde cero** con dos unidades y ni una más, produce Encina OS entero contestando solo las cinco pantallas: **36 correctas, 0 fallos**. La línea que decide es `REPO ELEGIDO -> /cdrom/encina-repo`. La construcción es **reproducible** y saca un defecto de la definición de terminado: el instalador se ve en inglés |
| §4.25 | **E3: la novena casilla, el instalador en español** | Sí. **Es la medición que cierra E3, 9 de 9.** El mecanismo está leído en el `14locales` del `initrd` de esta ISO, el precio de §4.21d **pagado y enseñado** —`md5sum.txt` rehecho, 501 entradas del medio comparadas, y el control de que **con el `md5sum.txt` oficial falla exactamente una línea**—, y la ISO `02ab929d…` existe y es reproducible. **El instalador se ve en español —lo declara Jorge, `[OJOS]`— y la máquina que sale es idéntica a la de §4.23d: 36 correctas, 0 fallos**. Y trae el método para medir una máquina sin `ssh`: un volumen FAT conectado DESPUÉS de instalar |
| §4.24 | **E2 remedido: la vía `CIDATA` del guion de las dos vías** | Sí. `imagen/autoinstall.yaml` cambió al enseñarle a `encina-seed.sh` las dos vías, y **sigue produciendo la misma máquina: 35 correctas, 0 fallos**. Con §4.23a, el guion queda medido **por sus dos ramas**. Trae el control que hacía falta —el `user-data` sacado del volumen **construido**, porque el de ayer daría el mismo verde sin medir nada— y un hallazgo de instrumento: `Image` no es byte a byte `/casper/vmlinuz`, **es su `gunzip`** |
| §4.22 | **E3: la forma del producto, medida entera** | Sí. Hecha **antes de tocar `xorriso`**, con `CIDATA` y el banco de E2. El instalador de escritorio **sabe mezclar**: enseña solo las cinco pantallas pedidas —confirmado por `telemetry`, que las lista— y aplica del seed el idioma y la instalación mínima. La máquina que sale es **la de E2**: 33 correctas. **Y los 2 fallos son del instrumento, no de la máquina**: el bloque 1 de `verificar-e2.sh` codifica el criterio de E2, que E3 no puede cumplir por diseño |
| §4.21 | **E3: las dos mediciones baratas de apertura** | Sí. Es la medición de apertura de E3. **El banco de UTM no aplica Secure Boot y no puede** —queda declarado como límite—, y **`/cdrom/autoinstall.yaml` es el quinto sitio que mira el instalador**, leído en el código de esta ISO, con la consecuencia de que **un volumen `CIDATA` conectado le gana** |
| §4.26 | **E4: la medición de apertura, y la pregunta del Snap** | Sí. **Es la medición que abre E4** y la primera que nombra las **25 aplicaciones** que trae la entrega, que hasta hoy solo se contaban. El criterio de §10 **no suprime E4**: hay tres huecos con su comando —ofimática, escáner y **ninguna forma de instalar nada**—. Saca además dos cosas que no son de E4: la entrega **depende de la red en duro** (el navegador, 76,4 MB, baja de `packages.mozilla.org`) y **`gnome-software` arrastra `snapd`**. Y contesta que **el Snap sí puede convivir**, porque es el estado en el que se firmó en §4.13 |
| §4.27 | **E3: el agujero de red, leído antes de gastar la VM** | Sí, y **no marca ninguna casilla**: es el paso 1 de `ENCINA-OS.md` §7 hecho por lectura. Leído en el propio medio de la entrega (`02ab929d…`, sus manifiestos y su `pool/`), con el control de que el conjunto derivado reproduce la foto de §4.26g. **Corrige a §4.26e por lo alto:** sin red no falta el navegador, falta **todo Encina** —`autofirma` pide un JRE y `libnss3-tools`, `encina-meta` pide `hunspell-es`, y nada de eso viaja en el medio—, así que apt, que es todo o nada, no instala ni uno de los cuatro `.deb`. Trae **el sano y el roto escritos antes de medir** y el precio |
| §4.28 | **¿B3 se arregla en AutoFirma en vez de en el navegador?** | Sí, y **cierra la pregunta: no se puede**, leído en las fuentes del fork (v1.9.1) sin gastar VM. No es el confinamiento: **el puerto lo elige la página al azar —tres de 16 384— y se lo dice a la aplicación por la URI `afirma://` que el Snap no entrega**, así que un AutoFirma residente es inalcanzable por construcción. Y encima habría que quitarle sus dos temporizadores y su `halt(0)` —bifurcación permanente, contra D14— y **saltarse la comprobación de `idsession`**. Consecuencia para E4: la condición de D16 —el Firefox que se puede abrir es el nativo— **no es cosmética, es la defensa entera** |
| §4.32 | **E3: el núcleo leído hasta el final, y la ISO de E4 contestando las cinco pantallas** | Sí. **Contesta la pregunta del núcleo por el lado contrario del que se preguntaba:** el objetivo **ya tiene** el medio como fuente de apt cuando `curtin` instala el núcleo —lo enseña el registro sirviendo GRUB entero desde `file:/cdrom`—, así que lo que falta no es una fuente sino **el núcleo dentro del archivo indexado**, y eso lo cierra la **firma de Canonical**. La clave `apt:` del seed **no** vale: sin red `subiquity` borra todas las partes de `sources.list.d` a propósito. El tamaño **medido, no estimado: 1 089 MB**, no ~700. **Y cierra la ISO de E4:** `CIDATA -> <no encontrado>`, `REPO ELEGIDO -> /cdrom/encina-repo` y el `telemetry` nombra **exactamente las cinco pantallas**. Saca dos defectos del verificador y el instrumento que faltaba para pilotar sin ojos |
| §4.51 | **Dónde dice Ubuntu el medio: el inventario de la marca** | Sí. **Es la primera casilla de `tareas/marca-del-medio.md`**, hecha leyendo `1224b5b1…` sin arrancarla y sin gastar VM: **39 apariciones, cada una con su fichero, su cadena y dónde se ve**, en los tres planos que pedía la casilla. Deja guion —`imagen/inventario-marca.sh`— porque §4.27 leyó a mano y no dejó ninguno. Lo que más cambia el trabajo que viene: **el rótulo del icono del instalador se calcula desde `/.disk/info`** (medido con su control), **la sesión viva no lleva ni un fichero de Encina** —o sea que todo lo que rodea al instalador es Ubuntu de fábrica—, y **el instalador es un snap de 109 MB con un `whitelabel.yml` dentro** que nadie había nombrado. Y saca dos defectos de su propio instrumento: `awk '{print $NF}'` esconde los nombres de los enlaces —§4.45c otra vez— y `grep -q` con `pipefail` convierte un acierto en `[FALLO]` |
| §4.52 | **La marca entra en el medio sin rehacer 1,69 GB: una capa de 2,9 MiB** | Sí. **Es la tercera casilla de `tareas/marca-del-medio.md`**, hecha leyendo el mismo `1224b5b1…` sin arrancarlo. Contesta los dos `[OMIT]` de §4.51 **sobre el código del commit exacto con el que se construyó el snap** —y uno estaba **mal planteado**: `{{ DISTRO }}` no sale de `.disk/info` ni de `os-release`, es **una constante del binario**, así que las diapositivas se sustituyen, no se parchean—. Y el otro abre la puerta entera: **el `whitelabel.yml` se apunta desde fuera del snap**, `/usr/share/desktop-provision/`, y con él el **título de la ventana** (`app-name`), las diapositivas y los dibujos de cada página. Lo que hace posible la casilla es que **el medio no lleva `layerfs-path=`**, así que casper monta **todos** los `*.squashfs` de `/casper` y **el último alfabéticamente manda**: una capa de **3 084 288 bytes** tapa a la de **1 692 274 688**. Deja `imagen/capa-marca.sh` (4 controles + 4 comprobaciones) y el inventario pasa de **31 a 24 apariciones**, con **los ocho sitios nombrados uno a uno**. Y saca **dos defectos del propio instrumento**: contaba sitios en vez de valores —el número no podía bajar nunca— y un control que **caducó al mejorar el producto** |
| §4.53 | **El nombre del volumen: 88 bytes cambian de sitio y nada más** | Sí. **Es la cuarta y última casilla de `tareas/marca-del-medio.md`**, y la única cuyo «hecha cuando» pedía que **no se rompiera nada**. Se lee primero **quién usa hoy ese nombre**, en el código que viaja en el medio: `casper` encuentra el medio **por contenido** (`is_casper_path`: ¿hay `*.squashfs` en `/casper`?) y desempata **por UUID**, `apt-cdrom` saca el nombre de **`.disk/info`**, `subiquity` va toda por la **ruta `/cdrom`**, y **lo que podía tumbar la casilla —el `grubaa64.efi` firmado— busca `search --file /.disk/info`, no `--label`**, leído en el `grub.cfg` empotrado en su `squashfs` interno. **El `Volume id` no está escrito en ningún fichero del medio**: 0 apariciones en los 133 140 ficheros de las dos capas grandes, con su control. Medido contra **un medio de control remasterizado sin tocar el nombre**, la diferencia son **88 bytes de 3 715 235 840, todos dentro del campo del nombre de los cuatro descriptores**; dos pasadas dan la misma huella y `md5sum.txt` no hay que rehacerlo. Y el banco de los dos bloques nuevos de `fabricar-iso.sh` saca **dos defectos**: el nombre se cortaba **por número de palabras** y se truncaba en silencio, y **el número de descriptores no es constante** —la oficial tiene 2 primarios y 2 Joliet, la nuestra 4 y 0—, o sea que **remasterizar se lleva el Joliet desde E3** y nadie lo había medido |
| A3 | Por qué se suprimió `encina-locale-es` | Sí, y de forma permanente. Se llamaba «§6.1» hasta el 2026-08-08 |
| §9 | Trampas conocidas | Sí, entera. Es método y aplica igual al trabajo de imagen |

---

## Índice: un fichero por sección, y el número es el nombre del fichero

La sección se cita como siempre —`MEDICIONES.md §4.37`, o `§4.37c` para su
apartado (c)— y `bancos/enlaces.sh` resuelve la cita contra estos ficheros. El
orden de esta lista es el que tenían en el fichero único, que no era el
numérico (la §9 y la A3 vivían en medio de la §4, y la §4.22 detrás de la
§4.24): se conserva porque `.orden.tsv` es lo que permite reconstruir el
original byte a byte, que es el control de la partición.

| Fichero | Sección |
|---|---|
| [4-estado-del-arte.md](4-estado-del-arte.md) | 4. Estado del arte (no volver a investigar) |
| [4.1-medicion-propia-autofirma-1-9.md](4.1-medicion-propia-autofirma-1-9.md) | 4.1 Medición propia de AutoFirma 1.9 (2026-08-07) |
| [4.2-remedicion-abrir-b1.md](4.2-remedicion-abrir-b1.md) | 4.2 Remedición al abrir B1 (2026-08-07) |
| [4.3-la-vm-snap-dos-barreras-son-dos-universales.md](4.3-la-vm-snap-dos-barreras-son-dos-universales.md) | 4.3 La VM del Snap: las dos barreras NO son las dos universales (2026-08-07) |
| [4.4-hay-tercera-barrera-snap.md](4.4-hay-tercera-barrera-snap.md) | 4.4 Hay una TERCERA barrera, y es del Snap (2026-08-07) |
| [4.5-que-esta-arreglado-ya-revisado-2026-08-07.md](4.5-que-esta-arreglado-ya-revisado-2026-08-07.md) | 4.5 Qué está arreglado ya y qué no, revisado el 2026-08-07 |
| [4.6-la-estrategia-fork-oficial-tercero.md](4.6-la-estrategia-fork-oficial-tercero.md) | 4.6 La estrategia: fork del oficial, no de un tercero |
| [4.7-el-deb-corregido-hace-innecesario-firefox-nativo.md](4.7-el-deb-corregido-hace-innecesario-firefox-nativo.md) | 4.7 ¿El `.deb` corregido hace innecesario el Firefox nativo? No |
| [4.8-forma-fork-tres-repositorios-empaquetado-aparte.md](4.8-forma-fork-tres-repositorios-empaquetado-aparte.md) | 4.8 Forma del fork: tres repositorios, y el empaquetado aparte |
| [4.9-el-primer-positivo-extremo-extremo.md](4.9-el-primer-positivo-extremo-extremo.md) | 4.9 EL PRIMER POSITIVO DE EXTREMO A EXTREMO (2026-08-07) |
| [4.10-r10-encina-meta-via-llega-firefox-nativo.md](4.10-r10-encina-meta-via-llega-firefox-nativo.md) | 4.10 R10 y `encina-meta`: por qué vía llega Firefox nativo (2026-08-08) |
| [4.11-e1-vm-verdad-deducido-4-10-dos-cosas-salieron.md](4.11-e1-vm-verdad-deducido-4-10-dos-cosas-salieron.md) | 4.11 E1 en una VM de verdad: lo deducido de §4.10, y dos cosas que no salieron (2026-08-08) |
| [4.12-el-positivo-maquina-virgen-costo-llegar.md](4.12-el-positivo-maquina-virgen-costo-llegar.md) | 4.12 EL POSITIVO SOBRE UNA MÁQUINA VIRGEN, y lo que costó llegar (2026-08-08) |
| [4.13-la-casilla-decide-marcada-secuencia-tres-ordenes.md](4.13-la-casilla-decide-marcada-secuencia-tres-ordenes.md) | 4.13 LA CASILLA QUE DECIDE, MARCADA: la secuencia de tres órdenes basta (2026-08-09) |
| [4.14-e2-iso-oficial-escritorio-si-honra-autoinstall.md](4.14-e2-iso-oficial-escritorio-si-honra-autoinstall.md) | 4.14 E2 — La ISO oficial de escritorio SÍ honra un `autoinstall` mínimo, y a qué precio (2026-08-09, cerrada de madrugada el 10) |
| [4.15-el-repo-local-sin-firmar-casilla-e1-podia-cumplir.md](4.15-el-repo-local-sin-firmar-casilla-e1-podia-cumplir.md) | 4.15 El repo local sin firmar, y la casilla que E1 no podía cumplir (2026-08-10) |
| [4.16-e2-ninguna-clave-seed-quita-clic-leido-snap-si.md](4.16-e2-ninguna-clave-seed-quita-clic-leido-snap-si.md) | 4.16 E2 — Ninguna clave del seed quita el clic (leído), y el Snap SÍ se quita desde el seed (medido) (2026-08-10) |
| [4.17-por-via-llega-firefox-nativo-cuando-hay-deb-transicion.md](4.17-por-via-llega-firefox-nativo-cuando-hay-deb-transicion.md) | 4.17 Por qué vía llega Firefox nativo cuando no hay deb de transición (2026-08-10) |
| [4.18-el-seed-verdad-escrito-medido-entero.md](4.18-el-seed-verdad-escrito-medido-entero.md) | 4.18 EL SEED DE VERDAD, ESCRITO Y MEDIDO ENTERO (2026-08-10) |
| [4.19-la-sombra-solo-icono-casilla-pedia-romper-a2.md](4.19-la-sombra-solo-icono-casilla-pedia-romper-a2.md) | 4.19 LA SOMBRA: un solo icono, y la casilla que pedía romper A2 (2026-08-10) |
| [4.20-la-firma-maquina-seed-contrasena-existia.md](4.20-la-firma-maquina-seed-contrasena-existia.md) | 4.20 LA FIRMA SOBRE LA MÁQUINA DEL SEED, Y LA CONTRASEÑA QUE NO EXISTÍA (2026-08-10) |
| [4.21-e3-dos-mediciones-baratas-apertura-secure-boot.md](4.21-e3-dos-mediciones-baratas-apertura-secure-boot.md) | 4.21 E3 — Las dos mediciones baratas de apertura: el Secure Boot del banco y el seed dentro de la ISO (2026-08-10) |
| [4.22-e3-forma-funciona-instalador-escritorio-si-honra.md](4.22-e3-forma-funciona-instalador-escritorio-si-honra.md) | 4.22 E3 — La forma funciona: el instalador de escritorio SÍ honra `interactive-sections`, y sabe mezclar (2026-08-10) |
| [4.23-e3-iso-existe-instala-seed-viaja-dentro-coge-cdrom.md](4.23-e3-iso-existe-instala-seed-viaja-dentro-coge-cdrom.md) | 4.23 E3 — LA ISO EXISTE, Y SE INSTALA: el seed viaja dentro y se coge de `/cdrom` (2026-08-10) |
| [4.24-e2-remedido-via-cidata-guion-aprendio-dos-vias.md](4.24-e2-remedido-via-cidata-guion-aprendio-dos-vias.md) | 4.24 E2 remedido — la vía `CIDATA` del guion que aprendió dos vías (2026-08-10) |
| [4.25-e3-novena-casilla-instalador-idioma-producto.md](4.25-e3-novena-casilla-instalador-idioma-producto.md) | 4.25 E3 — La novena casilla: el instalador en el idioma del producto (2026-08-10) |
| [4.26-e4-medicion-apertura-le-falta-maquina-sale-iso.md](4.26-e4-medicion-apertura-le-falta-maquina-sale-iso.md) | 4.26 E4 — La medición de apertura: qué le falta a la máquina que sale de la ISO (2026-08-11) |
| [4.27-e3-agujero-red-lectura-hecha-antes-gastar-vm.md](4.27-e3-agujero-red-lectura-hecha-antes-gastar-vm.md) | 4.27 E3 — El agujero de red: la lectura, hecha antes de gastar la VM (2026-08-11) |
| [4.28-y-si-b3-arreglara-autofirma-vez-navegador.md](4.28-y-si-b3-arreglara-autofirma-vez-navegador.md) | 4.28 ¿Y si B3 se arreglara en AutoFirma en vez de en el navegador? (2026-08-11) |
| [4.29-la-puerta-convivencia-c-contestada-maquina-tenia.md](4.29-la-puerta-convivencia-c-contestada-maquina-tenia.md) | 4.29 LA PUERTA DE LA CONVIVENCIA (c), CONTESTADA — y la máquina que la tenía que contestar no llevaba el paquete (2026-08-11) |
| [4.30-la-limpieza-banco-dos-extremos-mentira-du-medidos.md](4.30-la-limpieza-banco-dos-extremos-mentira-du-medidos.md) | 4.30 La limpieza del banco, y los dos extremos de la mentira de `du` medidos el mismo día (2026-08-11) |
| [4.31-e4-vuelta-entera-snap-vuelve-declarado-tres-arreglos.md](4.31-e4-vuelta-entera-snap-vuelve-declarado-tres-arreglos.md) | 4.31 E4 — LA VUELTA ENTERA: el Snap vuelve declarado, y tres «arreglos» resultan ser otra cosa (2026-08-12) |
| [4.32-e3-e4-nucleo-leido-hasta-final-iso-e4-contestando.md](4.32-e3-e4-nucleo-leido-hasta-final-iso-e4-contestando.md) | 4.32 E3/E4 — El núcleo, leído hasta el final; y la ISO de E4 contestando las cinco pantallas (2026-08-12) |
| [4.33-la-firma-real-forma-c-fichero-firmado-correctamente.md](4.33-la-firma-real-forma-c-fichero-firmado-correctamente.md) | 4.33 LA FIRMA REAL SOBRE LA FORMA (c): «Fichero firmado correctamente» con el Snap dentro (2026-08-12) |
| [4.34-la-tienda-cambia-sale-gnome-software-queda-centro.md](4.34-la-tienda-cambia-sale-gnome-software-queda-centro.md) | 4.34 LA TIENDA CAMBIA: sale `gnome-software`, se queda el Centro de aplicaciones (2026-08-12/13) |
| [4.35-la-iso-entrega-llevaba-tienda-vieja-refabricada.md](4.35-la-iso-entrega-llevaba-tienda-vieja-refabricada.md) | 4.35 LA ISO QUE SE ENTREGA LLEVABA LA TIENDA VIEJA — refabricada, arrancada y probada (2026-08-13) |
| [4.36-el-medio-ya-fabrica-desde-cero-cosechar-repo-sh.md](4.36-el-medio-ya-fabrica-desde-cero-cosechar-repo-sh.md) | 4.36 EL MEDIO YA SE FABRICA DESDE CERO: `cosechar-repo.sh`, y la ISO sale a DOS BYTES (2026-08-13) |
| [4.37-los-tres-deb-construyen-desde-clon-huella-vigente.md](4.37-los-tres-deb-construyen-desde-clon-huella-vigente.md) | 4.37 LOS TRES `.deb` SE CONSTRUYEN DESDE EL CLON — y la huella vigente era de una CONSTRUCCIÓN, no de un paquete (2026-08-13) |
| [4.38-la-ci-ya-mira-tres-deb-salen-iguales-amd64-reproducibilidad.md](4.38-la-ci-ya-mira-tres-deb-salen-iguales-amd64-reproducibilidad.md) | 4.38 LA CI YA MIRA LOS TRES `.deb` — y salen IGUALES en amd64: la reproducibilidad es entre máquinas Y entre arquitecturas (2026-08-13) |
| [4.39-el-medio-fabrica-dos-veces-sale-igual-iso-oficial.md](4.39-el-medio-fabrica-dos-veces-sale-igual-iso-oficial.md) | 4.39 EL MEDIO SE FABRICA DOS VECES Y SALE IGUAL — y la ISO oficial llevaba cuatro días en este Mac (2026-08-13) |
| [4.40-la-iso-este-repositorio-arranca-instala-lista.md](4.40-la-iso-este-repositorio-arranca-instala-lista.md) | 4.40 LA ISO DE ESTE REPOSITORIO SE ARRANCA Y SE INSTALA — y la lista de etapas del verificador daba por segura una que no lo es (2026-08-13/14) |
| [4.41-el-verificador-corregido-causa-delante-52-52-medio.md](4.41-el-verificador-corregido-causa-delante-52-52-medio.md) | 4.41 EL VERIFICADOR CORREGIDO CON SU CAUSA DELANTE: 52 de 52, y el medio se gana su nombre (2026-08-14) |
| [4.42-fichero-firmado-correctamente-maquina-sale-iso.md](4.42-fichero-firmado-correctamente-maquina-sale-iso.md) | 4.42 «FICHERO FIRMADO CORRECTAMENTE» SOBRE LA MÁQUINA QUE SALE DE LA ISO DE HOY (2026-08-14) |
| [4.43-el-tema-iconos-gana-nombre-era-otro-boton-sigue.md](4.43-el-tema-iconos-gana-nombre-era-otro-boton-sigue.md) | 4.43 EL TEMA DE ICONOS GANA, EL NOMBRE ERA OTRO — y el botón sigue con el logo de Ubuntu (2026-08-14) |
| [4.44-fuera-bienvenida-ubuntu-era-clave-era-unidad-systemd.md](4.44-fuera-bienvenida-ubuntu-era-clave-era-unidad-systemd.md) | 4.44 FUERA LA BIENVENIDA DE UBUNTU: no era una clave, era una unidad de systemd (2026-08-15) |
| [4.45-la-iso-vuelve-salir-0-1-11-dentro-cambiar-deb.md](4.45-la-iso-vuelve-salir-0-1-11-dentro-cambiar-deb.md) | 4.45 LA ISO VUELVE A SALIR, con 0.1.11 dentro — y cambiar un `.deb` no eran cuatro sitios, son cinco (2026-08-15) |
| [A3-encina-locale-es.md](A3-encina-locale-es.md) | A3 — Por qué se suprimió `encina-locale-es` (2026-08-07) |
| [4.46-la-misma-trampa-4-37-otra-vez-huella-0-1-13-era.md](4.46-la-misma-trampa-4-37-otra-vez-huella-0-1-13-era.md) | 4.46 LA MISMA TRAMPA DE §4.37, OTRA VEZ: la huella de 0.1.13 era del árbol de trabajo, y la CI la cazó (2026-08-15) |
| [4.47-la-pregunta-iconos-dock-era-dos-preguntas-dos.md](4.47-la-pregunta-iconos-dock-era-dos-preguntas-dos.md) | 4.47 LA PREGUNTA DE LOS ICONOS DEL DOCK ERA DOS PREGUNTAS, y una de las dos no tiene por dónde (2026-08-15) |
| [4.48-la-vuelta-encina-branding-0-1-14-d21-dentro-dos.md](4.48-la-vuelta-encina-branding-0-1-14-d21-dentro-dos.md) | 4.48 LA VUELTA DE `encina-branding` 0.1.14: D21 dentro, dos ajustes de GDM fuera, y el ritual de los seis sitios pagado entero (2026-08-15) |
| [4.49-el-icono-0-1-14-pintaba-gdk-pixbuf-solo-husmea.md](4.49-el-icono-0-1-14-pintaba-gdk-pixbuf-solo-husmea.md) | 4.49 EL ICONO DE 0.1.14 NO SE PINTABA: gdk-pixbuf sólo husmea 256 bytes, y el comentario de cabecera empujaba el `<svg>` al 2090 (2026-08-15) |
| [9-trampas.md](9-trampas.md) | 9. Trampas conocidas |
| [4.50-se-borro-iso-3-5-gb-df-devolvio-cero-era-clon.md](4.50-se-borro-iso-3-5-gb-df-devolvio-cero-era-clon.md) | 4.50 SE BORRÓ UNA ISO DE 3,5 GB Y `df` DEVOLVIÓ CERO: era un clon de APFS, y el hueco lo sigue reteniendo la VM (2026-08-15) |
| [4.51-donde-dice-ubuntu-medio-39-sitios-leidos-sin-arrancarlo.md](4.51-donde-dice-ubuntu-medio-39-sitios-leidos-sin-arrancarlo.md) | 4.51 DÓNDE DICE UBUNTU EL MEDIO: 39 sitios, leídos sin arrancarlo — y el instalador trae un mecanismo de marca blanca que nadie había mirado (2026-08-15) |
| [4.52-la-marca-entra-medio-sin-rehacer-1-69-gb-capa.md](4.52-la-marca-entra-medio-sin-rehacer-1-69-gb-capa.md) | 4.52 LA MARCA ENTRA EN EL MEDIO SIN REHACER 1,69 GB: una capa de 2,9 MiB — y las dos preguntas de §4.51 se contestan, una de ellas estaba mal planteada (2026-08-15) |
| [4.53-el-nombre-volumen-88-bytes-cambian-sitio-nada.md](4.53-el-nombre-volumen-88-bytes-cambian-sitio-nada.md) | 4.53 EL NOMBRE DEL VOLUMEN: 88 bytes cambian de sitio y nada más — y lo que podía tumbar la casilla estaba en el GRUB firmado, que busca POR FICHERO y no por etiqueta (2026-08-17) |
| [4.54-la-vuelta-unica-iso-sale-reproducible-primera.md](4.54-la-vuelta-unica-iso-sale-reproducible-primera.md) | 4.54 LA VUELTA ÚNICA: la ISO sale reproducible a la primera — y al ARRANCARLA se cae la premisa de la casilla 3: LA CAPA NO SE MONTA NUNCA (2026-08-17) |
| [4.55-bisecar-d23-bandera-mecanismo-prediccion-escrita.md](4.55-bisecar-d23-bandera-mecanismo-prediccion-escrita.md) | 4.55 BISECAR D23: una bandera por mecanismo, y la predicción escrita antes de gastar el arranque (2026-08-19) |
| [4.56-la-hipotesis-canal-paga-precio-producto-escribe.md](4.56-la-hipotesis-canal-paga-precio-producto-escribe.md) | 4.56 LA HIPÓTESIS DEL CANAL: se paga el precio de producto y se escribe la predicción antes de fabricar (2026-08-19, tarde) |
| [4.57-separar-lts-comillas-omit-4-56cc-estaba-ruta-critica.md](4.57-separar-lts-comillas-omit-4-56cc-estaba-ruta-critica.md) | 4.57 SEPARAR EL `LTS` DE LAS COMILLAS: el `[OMIT]` de §4.56cc estaba en la ruta crítica y nadie lo había visto (2026-08-19, cierre) |
| [4.58-que-capa-monte-layerfs-path-linea-nucleo-capa.md](4.58-que-capa-monte-layerfs-path-linea-nucleo-capa.md) | 4.58 QUE LA CAPA SE MONTE: `layerfs-path=` en la línea del núcleo y la capa renombrada a la cadena (2026-08-20) |
| [4.59-contar-arranques-separar-fallo-intermitente-banco.md](4.59-contar-arranques-separar-fallo-intermitente-banco.md) | 4.59 CONTAR ARRANQUES: separar el fallo intermitente del banco de un posible efecto de la capa (2026-08-20, noche) |
| [4.60-construir-todo-sh-entero-reproducibilidad-pagada.md](4.60-construir-todo-sh-entero-reproducibilidad-pagada.md) | 4.60 `construir-todo.sh` ENTERO Y LA REPRODUCIBILIDAD, PAGADA (2026-08-21) |
| [4.61-instalar-desde-cero-mirar-pantalla-prediccion.md](4.61-instalar-desde-cero-mirar-pantalla-prediccion.md) | 4.61 INSTALAR DESDE CERO Y MIRAR LA PANTALLA: la predicción, escrita ANTES de arrancar nada (2026-08-22) |
| [4.62-arreglar-medio-prediccion-escrita-antes-tocar.md](4.62-arreglar-medio-prediccion-escrita-antes-tocar.md) | 4.62 ARREGLAR EL MEDIO: la predicción, escrita ANTES de tocar un solo fichero (2026-08-22) |
| [4.63-la-red-seguridad-sabotaje-prediccion-escrita-antes.md](4.63-la-red-seguridad-sabotaje-prediccion-escrita-antes.md) | 4.63 LA RED DE SEGURIDAD, POR SABOTAJE: la predicción, escrita ANTES de fabricar nada (2026-08-22, madrugada) |
| [4.64-e6-medio-amd64-prediccion-escrita-antes-tocar.md](4.64-e6-medio-amd64-prediccion-escrita-antes-tocar.md) | 4.64 E6 — UN MEDIO `amd64`: la predicción, escrita ANTES de tocar un solo fichero (2026-08-22, noche) |
| [4.65-e6-quien-fallo-instalador-amd64-prediccion-escrita.md](4.65-e6-quien-fallo-instalador-amd64-prediccion-escrita.md) | 4.65 E6 — ¿DE QUIÉN ES EL FALLO DEL INSTALADOR `amd64`? La predicción, escrita ANTES de arrancar ninguna VM (2026-08-23) |
| [4.66-el-instrumento-refactorizacion-bancos-enlaces.md](4.66-el-instrumento-refactorizacion-bancos-enlaces.md) | 4.66 EL INSTRUMENTO DE LA REFACTORIZACIÓN: `bancos/enlaces.sh`, y las cinco trampas del espacio de referencias (2026-08-23) |
| [4.67-tarea-2-fallo-partido-arbol-ya-habia-votado-segundo.md](4.67-tarea-2-fallo-partido-arbol-ya-habia-votado-segundo.md) | 4.67 TAREA 2: `fallo()` partido, y el árbol ya había votado el segundo nombre (2026-08-23) |
| [4.68-la-raiz-inventa-raiz-repo-deja-tener-encina-reserva.md](4.68-la-raiz-inventa-raiz-repo-deja-tener-encina-reserva.md) | 4.68 LA RAÍZ NO SE INVENTA: `raiz_repo()` deja de tener `~/encina` de reserva (2026-08-23) |
| [4.69-tarea-13-ci-construye-tambien-arm64-casilla-iba.md](4.69-tarea-13-ci-construye-tambien-arm64-casilla-iba.md) | 4.69 TAREA 13: la CI construye también `arm64`, y la casilla iba corta en tres sitios (2026-08-23) |
| [4.70-el-hierro-primer-dia-ojos-plymouth-cobra-segundo.md](4.70-el-hierro-primer-dia-ojos-plymouth-cobra-segundo.md) | 4.70 EL HIERRO, PRIMER DÍA: el `[OJOS]` de Plymouth se cobra, el segundo arranque se queda en negro por GDM y no por Encina, y el modo oscuro se lleva la bellota (2026-08-23, tarde) |
| [4.71-el-drop-in-gdm-service-banco-arm64-cuanto-cuesta.md](4.71-el-drop-in-gdm-service-banco-arm64-cuanto-cuesta.md) | 4.71 EL DROP-IN DE `gdm.service` EN EL BANCO arm64: cuánto cuesta esperar a `udev-settle` donde no hay `amdgpu` (2026-08-23, noche) |
| [4.72-encina-branding-0-1-16-drop-in-entra-conffile.md](4.72-encina-branding-0-1-16-drop-in-entra-conffile.md) | 4.72 `encina-branding` 0.1.16: el drop-in entra como conffile, y la comprobación que lo vigila nació sin poder decir «sí» (2026-08-23, noche) |
| [4.73-el-acer-encina-branding-0-1-16-3-3-saludador-desde.md](4.73-el-acer-encina-branding-0-1-16-3-3-saludador-desde.md) | 4.73 EL ACER CON `encina-branding` 0.1.16: 3 de 3 con saludador desde el `.deb`, y el primero mirado por Jorge (2026-08-23, noche) |
| [4.74-el-medio-amd64-0-1-16-primer-intento-ensena-amd64.md](4.74-el-medio-amd64-0-1-16-primer-intento-ensena-amd64.md) | 4.74 EL MEDIO `amd64` CON 0.1.16 — y el primer intento enseña que el `amd64` NUNCA se había reproducido: xorriso le pone un GUID de GPT al azar (2026-08-23, noche) |
| [4.75-la-medicion-pedia-bellota-19-yaru-heredan-view.md](4.75-la-medicion-pedia-bellota-19-yaru-heredan-view.md) | 4.75 LA MEDICIÓN QUE PEDÍA LA BELLOTA: los 19 `Yaru-*` HEREDAN `view-app-grid-ubuntu-symbolic.svg` — un solo desvío en `Yaru` cubre todos los acentos (2026-08-24) |
| [4.76-encina-branding-0-1-17-desvio-bellota-salida-1.md](4.76-encina-branding-0-1-17-desvio-bellota-salida-1.md) | 4.76 `encina-branding` 0.1.17: EL DESVÍO DE LA BELLOTA — la salida (1) de §4.70c implementada, 26 de 26 con sus controles en la purga, y el control negativo de la trampa 13 cobrado a mano (2026-08-24) |
| [4.77-el-medio-amd64-0-1-17-existe-reproduce-primera.md](4.77-el-medio-amd64-0-1-17-existe-reproduce-primera.md) | 4.77 EL MEDIO `amd64` CON 0.1.17 EXISTE Y SE REPRODUCE A LA PRIMERA: `3d5d12a9…`, dos pasadas byte a byte del mismo commit — y el hook de `rtk` también filtra `diff` (2026-08-24) |
| [4.78-la-fila-g-pagada-instalacion-sin-red-acer-termina.md](4.78-la-fila-g-pagada-instalacion-sin-red-acer-termina.md) | 4.78 LA FILA g, PAGADA: la instalación SIN RED en el Acer termina y la máquina funciona — y la bellota sobrevive al modo oscuro EN EL HIERRO (2026-08-25, testimonio de Jorge) |
| [4.79-la-fase-1b-mitad-pagada-medio-arm64-0-1-17-existe.md](4.79-la-fase-1b-mitad-pagada-medio-arm64-0-1-17-existe.md) | 4.79 LA FASE 1b, MITAD PAGADA: el medio `arm64` con 0.1.17 existe y se reproduce —`63f360dd…`, SEIS pasadas en tres commits, una huella—, la deducción del GUID de §4.74 cobrada, y `fabricar-iso.sh` se quejaba de un `arm64` correcto por el `bash` 3.2 de macOS (2026-08-25) |

---

*Este directorio nació el 2026-08-28 (tarea 4 de
[refactorizacion.md](../tareas/refactorizacion.md)): `MEDICIONES.md` medía
19 399 líneas y 82 secciones, y `CLAUDE.md` manda leerlo **antes de investigar
cualquier cosa**, que con ese tamaño era físicamente incumplible. Se movió
**verbatim**, sección a sección, y el control es que la concatenación de los 82
ficheros —con cada título devuelto a su nivel y sin el `../` de cuatro enlaces
relativos— da `diff` vacío contra el fichero original. Lo único que cambia de
cada sección es que su título pasa de `###` (o `##`) a `#`, porque ahora es un
fichero; los `#### (x)` de dentro no se tocan, que es lo que mantiene vivas las
513 referencias del tipo `§4.37c`. Las cifras y los números de línea que las
secciones citan de sí mismas (`MEDICIONES.md:16713`) son los del fichero único
y se dejan como estaban: son el registro de lo que se leyó ese día.*
