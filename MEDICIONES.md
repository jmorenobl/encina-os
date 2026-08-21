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

## 4. Estado del arte (no volver a investigar)

Resumen de lo ya averiguado, para no repetir el trabajo.

**Empaquetado alternativo de AutoFirma — existe, y está flojo:**

- `gecos-team/autofirma-gecos` — de la Agencia Digital de Andalucía. Parado: el
  último `.deb` commiteado es AutoFirma 1.7.1 y la versión actual es la 1.9.
  Paquete generado con `dpkg -b` sobre un `DEBIAN/` a mano, no en regla. Valioso
  por el diagnóstico, no como base de código.
- `albfernandez/clienteafirma-deb-package` — mejor ingeniería: `debian/` correcto,
  compila desde fuentes, no cierra los navegadores al instalar, elimina las
  librerías nativas de Windows y Mac de los jars. **Mejor base candidata.** Un solo
  mantenedor. **Revisado el 2026-08-07 (§4.5): ya corrige dos de los cinco fallos
  de §4.1 y tiene `debian/patches/`.** Último empuje 2025-12-22, tres estrellas.

### 4.1 Medición propia de AutoFirma 1.9 (2026-08-07)

La hipótesis central de la Etapa B **está comprobada en máquina propia**. Deja de
ser una cita de issues de terceros. Medido en la VM de A2 —Ubuntu 24.04 arm64,
Firefox 153 **nativo** de Mozilla, `encina-branding` 0.1.6 y
`encina-firefox-native` 0.2.0—, que es el caso favorable por construcción.

**Procedencia.** `Autofirma_Linux_Debian.zip` de `firmaelectronica.gob.es`
(certificado TLS de la Agencia Estatal de Administración Digital emitido por
FNMT-RCM). SHA-256 del zip `c29c251f…716798`, idéntico descargado por dos rutas
de red; del `.deb`, `2667d826…84acee`. El `.deb` va firmado con `dpkg-sig` por
«Secretaría General de Administración Digital - Afirma»
(`FFD0 16F8 398C 10F5 0781 EC8C F70B 0257 BF86 A0CB`) y su firma verifica. El
`postinst` y el `preinst` son **byte a byte idénticos** a la fuente pública de
`ctt-gob-es/clienteafirma`. Es auténtico: lo que hay es ingeniería descuidada, no
nada turbio. **La página oficial no publica hash, ni firma, ni la clave**; la
clave está en `keyserver.ubuntu.com`. Para un usuario, la única garantía es
HTTPS.

**Cinco fallos encadenados, cada uno capaz de esconder al siguiente:**

1. **El JRE no está declarado** (la errata `Recoments:`). `apt-cache depends
   autofirma` devuelve solo `Depende: libnss3-tools`.
2. **La instalación se declara exitosa con todo roto.** Sin Java, el `postinst`
   encadena ocho comandos fallidos y termina en `install ok installed`, código 0.
   El `postinst` es `#!/bin/sh` **sin `set -e` y con `exit 0` incondicional**, y
   además imprime `Instalacion del certificado CA en el almacenamiento del
   sistema` justo después de haber fallado al instalarlo.
3. **Instalar Java después no repara nada.** El `postinst` ya corrió y nada lo
   vuelve a lanzar: no se generan los certificados y no queda ningún mensaje.
4. **Con Java presente, la CA del socket va al perfil equivocado.** Se instala en
   el perfil del **Snap** (`~/snap/firefox/common/.mozilla/firefox/`) y no en el
   que Firefox usa de verdad. **Enmendado el 2026-08-07 al remedirlo (§4.2):** la
   redacción original decía «y no en el del Firefox nativo», y eso es falso.
   Sí escribió en un perfil nativo — en uno que Firefox no ha abierto jamás.
5. **Firefox de Mozilla no lee `/etc/firefox/pref/`**, que es donde el paquete
   deja `Autofirma.js`. Medido en ejecución sobre un Firefox 153 vivo: las tres
   preferencias `network.protocol-handler.*.afirma` **no existen**. Tampoco vale
   el almacén del sistema: aunque `security.enterprise_roots.enabled` está en
   `true` y la CA sí está en `/etc/ssl/certs`, Firefox ve 167 certificados y
   **ninguno** de AutoFirma.

**Prueba de firma real, en sede real** (`sededgsfp.gob.es`, TEST AUTOFIRMA, con
el Firefox **nativo** verificado por `/proc`): sale el diálogo *«No es posible
conectar con Autofirma debido a un problema de comunicación o de instalación del
cliente»*. Y **AutoFirma nunca llegó a arrancar**: ningún proceso `java`, nada
escuchando en los puertos del socket, y su propio log sin tocar. El fallo está en
el handler de protocolo (punto 5), **no** en el TLS del socket, que era donde se
había deducido que estaría.

**El remedio que propone el propio diálogo no hace nada.** «Herramientas →
Restaurar instalación» responde `Ya se encuentra instalado el certificado para la
configuración del canal seguro, no se hará nada` y sale con código 0, dejando el
perfil nativo intacto: comprueba que exista un fichero en `/usr/lib/Autofirma`,
no que el navegador tenga la CA. De propina, no puede ni escribir su log, porque
el `postinst` lo creó como root.

**Residuo.** Cada reinstalación genera un par de claves nuevo, así que quedan CA
raíz huérfanas confiadas como `C,,` en el perfil del navegador, y `apt purge` no
las retira porque el desinstalador que AutoFirma se genera puede quedar vacío.

**No apareció ningún diálogo de «abrir con»** antes del error, observado en
pantalla: al usuario no se le llegó a ofrecer nada.

**Y el handler del sistema sí funciona.** Medido con la sesión gráfica abierta,
al margen del navegador:

```
$ xdg-mime query default x-scheme-handler/afirma
afirma.desktop
$ autofirma "afirma://websocket?v=3&idsession=…&ports=63117"
INFORMACIÓN: Se inicia el modo de comunicacion por websockets: …
INFORMACIÓN: Tratamos de abrir el socket en el puerto: 63117

$ ss -ltn
LISTEN 0  50  *:63117  users:(("java",pid=4704))
```

AutoFirma arranca, abre ventana, interpreta el URI y **se pone a escuchar**. Con
una versión de protocolo inválida da un diálogo de error claro y legible en
pantalla (`SAF_21`), o sea que sabe informar cuando llega a ejecutarse. El
eslabón roto es exclusivamente **Firefox, que no entrega el URI**.

### Las dos barreras son independientes, y la segunda esperaba detrás

El socket que abre AutoFirma es **TLS**, no texto en claro:

```
$ openssl s_client -connect 127.0.0.1:63117
subject=CN = 127.0.0.1
issuer=CN = Autofirma ROOT
X509v3 Subject Alternative Name: IP Address:127.0.0.1, DNS:127.0.0.1, DNS:localhost
```

Un handshake sin TLS recibe una alerta fatal. Así que **el navegador tiene que
confiar en `Autofirma ROOT` para conectar**, y el Firefox nativo no lo hace
(punto 5: 167 certificados visibles, ninguno de AutoFirma).

Esto importa para el diseño de B1 más que ningún otro dato de esta sección:
**hay dos barreras, medidas por separado, y arreglar la primera destapa la
segunda.** Un diagnóstico que solo registre el esquema `afirma:` producirá un
sistema que sigue sin firmar, y esta vez sin ningún síntoma nuevo que seguir.

Y hay una asimetría que conviene tener delante, porque es la que fija **D13**:
la primera barrera **sí** es empaquetable —un `policies.json` o un fichero de
preferencias en `/usr/lib/firefox/distribution/` la cierra, declarativo y del
sistema—, y la segunda **no lo es en absoluto**: la CA se genera en el `postinst`
de AutoFirma, es distinta en cada máquina y en cada reinstalación, y vive en el
perfil del usuario. Por eso la mitad barata es la peligrosa.

**Lo demás que NO se midió, y no se da por bueno:** el `SEC_ERROR_ADDING_CERT`
de #459 (no reproducido); y Chrome o Chromium, que no están instalados en la VM.
Nada de lo medido depende de la arquitectura: el `.deb` es `Architecture: all`.

### 4.2 Remedición al abrir B1 (2026-08-07)

Antes de especificar `encina doctor` se volvió a medir §4.1 sobre
`encina-dev-firefox` (hoy en el mismo estado que `encina-autofirma-rota`; Ubuntu
24.04.4 arm64, AutoFirma 1.9.0, `openjdk-17-jre`, Firefox 153.0.3 nativo). **Lo
esencial se confirma. Tres cosas no, y las tres cambian una comprobación.**

**a) No hay «el perfil». Hay tres, y la CA está en los dos que no valen.**

```
~/.config/mozilla/firefox/cmnc3cx7.default-release   0 certificados   <- el que Firefox usa
~/.config/mozilla/firefox/ev2eu1nn.default           SocketAutoFirma  C,,
~/snap/firefox/common/.mozilla/firefox/297le6kh.default   SocketAutoFirma  C,,
```

`ev2eu1nn.default` tiene cuatro ficheros, `"firstUse": null`, `"source":
"legacy"` y **ningún `compatibility.ini`**: Firefox no lo ha abierto nunca. El
que sí usa lleva `LastPlatformDir=/usr/lib/firefox`. La causa es que los dos
ficheros de control se contradicen:

```
profiles.ini:  [Profile1] Path=ev2eu1nn.default  Default=1
installs.ini:  [4F96D1932A9F858E] Default=cmnc3cx7.default-release  Locked=1
```

AutoFirma cree al primero, Firefox obedece al segundo. **Un diagnóstico que
resuelva «el perfil» por `Default=1` reproduce el fallo que está diagnosticando.**

**b) La CA de los perfiles no es la del socket. Es residuo.** Los dos
certificados se llaman `CN=Autofirma ROOT` y los dos tienen el apodo
`SocketAutoFirma`, pero son distintos:

```
en los perfiles:  serial -21749C55  notBefore Aug  7 08:58:41  sha256 E8:6F:D6:…
en disco:         serial -6D0BCF1F  notBefore Aug  7 08:59:50  sha256 4A:9F:CC:…
```

Y el log del configurador de la última ejecución dice que no instaló nada:

```
No se encuentran fichero de perfil de Mozilla, por lo que no se instalaran certificados
No se ha detectado un perfil de Mozilla Firefox en el que instalar el certificado
```

**Consecuencia:** preguntar «¿hay un certificado llamado `SocketAutoFirma`?»
responde **sí** sobre un perfil que no puede validar el socket. Se compara por
huella o no se compara.

**c) La barrera 2 se puede medir sin arrancar AutoFirma.** El `openssl s_client`
de §4.1 se reproduce estáticamente, con las dos salidas —verde y roja— en la
misma máquina rota:

```
$ openssl pkcs12 -in /usr/lib/Autofirma/autofirma.pfx -nokeys -passin pass:654321
subject=CN = 127.0.0.1   issuer=CN = Autofirma ROOT   notBefore=Aug  7 08:59:50 2026

$ openssl verify -CAfile <CA del disco>    <hoja>   ->  OK
$ openssl verify -CAfile <CA del perfil>   <hoja>   ->  error 20: unable to get local issuer
```

Esto es lo que hace que B1 sea escribible: el diagnóstico entero es estáticamente
decidible, sin sesión gráfica, sin lanzar nada y sin abrir ningún socket.

**Y un `SEC_ERROR_BAD_DATABASE` explicado de propina.** `certutil -L` sobre un
directorio sin `cert9.db` falla con ese error y rc=255 **sin crear nada**; es
`certutil -A` el que crea la base de datos. Explica a la vez el error que §4.1 vio
en el `prerm` de AutoFirma y cómo `ev2eu1nn.default` acabó teniendo un `cert9.db`.

**COMPLETADO EL 2026-08-11, y lo que faltaba costó un defecto que duró dos
versiones (§4.29c): `certutil -D` TAMBIÉN la crea.** Medido con los cuatro verbos
y sus dos controles en M19(a) de `encina-autofirma`:

```
-A (añadir)            rc=0    ficheros tras la orden: cert9.db key4.db pkcs11.txt   <- control positivo
-L (listar)            rc=255  ficheros tras la orden: (ninguno)                     <- control negativo
-D (borrar por apodo)  rc=255  ficheros tras la orden: cert9.db key4.db pkcs11.txt   <- lo que faltaba
-K (listar claves)     rc=255  ficheros tras la orden: (ninguno)
```

`-D` sale con 255 y con *«could not find certificate named "SocketAutoFirma"»* y
**aun así deja los tres ficheros detrás**. O sea que **la frase de arriba era
cierta y estaba incompleta**, y por eso el defecto de §4.29c tenía **tres puertas
y no una**: `-D` es lo que lleva `uninstall.sh`, que se ejecutaba como root desde
el paso 0 del `postinst` y desde el `prerm`. Se reproduce en contenedor en
treinta segundos y no hace falta ninguna VM.

**Lo que sigue sin medirse tras esta tanda:** que Firefox lea de verdad
`/usr/lib/firefox/defaults/pref/` (deducido de cómo se construye el paquete de
Mozilla, no medido); que `installs.ini` gane a `Default=1` (deducido); y el
aislamiento NSS del Snap, que este documento afirma en §9 y **nadie ha medido** —
y lo medido lo matiza, porque un `certutil` de fuera sí escribe en el `cert9.db`
del Snap. Lista completa en `AGENTS.md` §6.8.

### 4.3 La VM del Snap: las dos barreras NO son las dos universales (2026-08-07)

Medido sobre `encina-snap-fabrica`, clon de `encina-limpia-respaldo`: **Ubuntu
24.04.4 arm64 de fábrica, Firefox Snap 147.0.3, ningún paquete de Encina.** Es la
máquina mayoritaria (D3: quien instala los `.deb` sobre su Ubuntu tiene el Snap).
Mismo artefacto que §4.1, verificado antes de instalar:

```
sha256 del zip:  c29c251f2ee9f00dfc87f9582677dbd436a83565986ab0417ff065ceae716798
sha256 del deb:  2667d8262eb0a18f371b015dc8a8fef06465dd981db9198faf3d91f96e84acee
```

**Etapa A, instalar el `.deb` solo: idéntico a §4.1.** `Recomends:` sin declarar,
`java: not found`, ocho órdenes fallidas, y aun así imprime `Instalacion del
certificado CA en el almacenamiento del sistema` y apt lo da por bueno. Nada
generado, cero certificados en el perfil.

**Etapa B, con Java y reinstalando: aquí se separan las dos máquinas.**

```
-- CA viva en disco:        serial=-6E3BE0F8  sha256 B9:3B:A5:A1:…:9D:74:6F:73
-- CA en el perfil del Snap: serial=-6E3BE0F8  sha256 B9:3B:A5:A1:…:9D:74:6F:73
-- ¿valida la hoja del socket contra la CA del perfil?
   /tmp/hoja.pem: OK
```

**La barrera 2 no existe en Ubuntu de fábrica.** No es que «acierte con el
perfil»: es que instala **la CA correcta, la del socket vivo, con la huella
correcta y la confianza correcta (`C,,`)**, en el único perfil que hay. Y el
desinstalador que se genera **funciona** —107 bytes, apuntando a ese perfil con
el apodo correcto—, frente a los 0 bytes de la VM nativa. §4.1 dedujo que en
fábrica «al menos acierta con el perfil del Snap»: la deducción era correcta y se
quedaba corta.

**La barrera 1 sí sigue ahí.** El Snap es la compilación de Mozilla, y no lee
`/etc/firefox/pref/` —donde AutoFirma deja `Autofirma.js`— igual que no la lee el
`.deb` nativo:

```
$ strings -a /snap/firefox/current/usr/lib/firefox/libxul.so | grep -c "etc/firefox"
0
$ strings -a … | grep -E "^(defaults/pref|distribution)"
defaults/preferences/*.js
defaults/pref/*.js
distribution.ini
```

Y no hay ninguna preferencia `afirma` en el `prefs.js` del perfil. El manejador
del sistema, igual que en §4.1, sí está: `xdg-mime` devuelve `afirma.desktop`.

**Lo que esto significa, y es lo más importante que ha salido del día:**

| | Barrera 1 (esquema `afirma:`) | Barrera 2 (CA del socket) |
|---|---|---|
| Ubuntu de fábrica + Snap | **presente** | **ausente** |
| Encina (Firefox nativo) | **presente** | **presente** |

**La barrera 2 no es un fallo de AutoFirma: es consecuencia de A2.** El
configurador funciona correctamente cuando encuentra el perfil que el navegador
usa; lo que no sabe es dónde vive el perfil del Firefox nativo de Mozilla, ni
resolver la contradicción `profiles.ini` / `installs.ini` (§4.2a). §3 decía que
A2 «desplazó» el obstáculo. Medido: **A2 añadió uno que en fábrica no estaba.**

**Y hay un matiz sobre D13 que hay que mirar de frente.** El motivo de D13 es que
«cerrar solo la barrera 1 deja el sistema sin firmar y sin el aviso que hoy da».
Eso es cierto **en una máquina Encina**, donde la barrera 2 espera detrás. En una
Ubuntu de fábrica **es falso**: allí la barrera 2 no existe, así que cerrar la 1
haría que la firma funcionase. **El mismo remedio tiene efectos opuestos en las
dos máquinas.** No se toca D13 aquí; se anota que su justificación tiene una
excepción medida, y que decidirla es una conversación aparte.

Esto no debilita `encina doctor`: lo refuerza. **El remedio correcto depende de
qué máquina es, y hoy no hay nada que las distinga.** Eso es exactamente lo que
un diagnóstico hace y un tutorial no.

**Prueba de firma real, medida el mismo día en `sededgsfp.gob.es`** (TEST
AUTOFIRMA, Firefox Snap 147, mirada en pantalla): sale **el mismo diálogo** que en
§4.1, *«No es posible conectar con Autofirma debido a un problema de comunicación
o de instalación del cliente»*. Y se comprobó que falla **por la misma causa**, no
solo con el mismo síntoma:

```
$ ps -eo args | grep -iE "java|autofirma"      # NINGUNO
$ ss -ltn | grep -E ":6[0-9]{4}"               # NADA escuchando
$ ls ~/.afirma/
ls: no se puede acceder a '/home/jorge/.afirma/': No existe el archivo o el directorio
```

El directorio de log de AutoFirma **ni siquiera existe**: no se ha ejecutado
nunca en esa máquina. Es la barrera 1, sola, y basta para romper la firma.

**Lo que esto deja demostrado, y es el resultado limpio del día:** en la Ubuntu de
fábrica la barrera 2 está **cerrada y medida** —la CA correcta, en el perfil
correcto, y la hoja del socket valida contra ella— **y la firma falla igualmente**.
Cada barrera basta por sí sola. Es la mitad complementaria de §4.1, que midió la
máquina donde están las dos.

### 4.4 Hay una TERCERA barrera, y es del Snap (2026-08-07)

Se cerró la barrera 1 a mano sobre `encina-snap-fabrica` para ver si la firma
salía: un `user.js` de usar y tirar en el perfil, con las tres preferencias que
AutoFirma deja en `/etc/firefox/pref/`. **No es el remedio** —un `user.js` en el
perfil del usuario es justo lo que R1 y D13 prohíben empaquetar—, es un
experimento reversible.

**Firefox las leyó, y registró el esquema.** Medido, no supuesto:

```
$ grep afirma prefs.js
user_pref("network.protocol-handler.app.afirma", "/usr/bin/autofirma");
user_pref("network.protocol-handler.external.afirma", true);
user_pref("network.protocol-handler.warn-external.afirma", false);

$ python3 -c '...' handlers.json
esquemas registrados: ['afirma', 'mailto']
afirma: {"action": 4}                    # 4 = useSystemDefault
```

**Y la firma siguió fallando, con AutoFirma sin arrancar**: ni proceso `java`, ni
socket, ni `~/.afirma`. Dos veces, mirado en pantalla.

**El motivo, medido con control positivo y negativo en la misma máquina:**

```
DENTRO del snap                          |  FUERA, en el host
-----------------------------------------|---------------------------------
$ ls /usr/share/applications/            |  $ xdg-mime query default \
mimeapps.list  python3.10.desktop        |        x-scheme-handler/afirma
vim.desktop    xdg-open.desktop          |  afirma.desktop
   4 ficheros                            |  $ ls /usr/share/applications | wc -l
$ ls /usr/share/applications/afirma.desktop |  94
   No such file or directory             |  $ ls /usr/bin/autofirma
$ ls /usr/bin/autofirma                  |  (existe)
   No such file or directory             |
$ echo $XDG_DATA_DIRS                    |
/snap/firefox/7764/... (solo rutas del snap, ninguna del host)
```

**Firefox dentro del Snap no ve `afirma.desktop` ni `/usr/bin/autofirma`.** Su
`XDG_DATA_DIRS` no incluye `/usr/share` del host. Cuando resuelve
`useSystemDefault` no encuentra nada y **no falla: no hace nada.** Sin diálogo,
sin error, y sin una sola línea en el journal ni una denegación de AppArmor —
comprobado.

**Y el sistema sí puede hacerlo**, lo que descarta que sea una prohibición de
snapd:

```
$ snap run --shell firefox -c 'xdg-open "afirma://websocket?v=3&idsession=…&ports=63117"'
rc=0
$ pgrep -a java
9098 java … -jar /usr/lib/Autofirma/autofirma.jar afirma://websocket?v=3&…
```

`xdg-open` dentro del snap es un shim de 38 bytes (`exec snapctl user-open "$@"`)
que cruza la frontera del sandbox y se lo pide al host. **Firefox no pasa por
ahí.** Que use GIO en su espacio de nombres confinado es la explicación
razonable, pero eso es **deducción**: lo medido es que el manejador es invisible
dentro y que nada arranca.

**Las tres barreras, y quién las tiene:**

| | B1 esquema `afirma:` | B2 CA del socket | B3 manejador invisible |
|---|---|---|---|
| Ubuntu de fábrica + Snap | presente | **ausente** | **presente** |
| Encina (Firefox nativo) | presente | presente | ausente |

**Esto corrige dos cosas que este documento llegó a afirmar hoy mismo.**

1. **A2 no «añadió» una barrera: quitó una que no tiene arreglo.** §4.3 concluyó
   que la barrera 2 la introduce el Firefox nativo, y es cierto, pero se quedaba
   ahí. Con B3 medida, el balance se invierte: en el Snap hay un obstáculo que
   **ningún `.deb` puede tocar** —no se añaden ficheros al `XDG_DATA_DIRS` de un
   snap desde fuera—, y el Firefox nativo lo elimina de raíz a cambio de una
   barrera que sí es reparable. **A2 deja de ser una preferencia y pasa a ser
   condición necesaria**, ahora sí medido y no supuesto.
2. **D13 no tiene la excepción que se le apuntó.** Se escribió que en Ubuntu de
   fábrica «cerrar solo la barrera 1 haría que la firma funcionase». **Medido:
   es falso.** Se cerró, y no funciona, porque detrás está B3. La regla de D13
   —cerrar una barrera sola no arregla nada y quita el síntoma— **se sostiene en
   las dos máquinas.** El motivo cambia según cuál; la conclusión no.

**Y corrige la suposición fundacional del proyecto sobre el sandbox.** §9 y
`AGENTS.md` §1 vienen diciendo que el navegador en Snap rompe la firma porque
**aísla el almacén NSS**. Medido hoy: el almacén NSS del Snap está **perfecto**
—AutoFirma le instala la CA correcta, §4.3—. Lo que el sandbox rompe es la
**visibilidad del manejador de protocolo**. La conclusión de siempre era
correcta; el mecanismo que se le atribuía, no.

**Lo que sigue sin medirse:** que en el Firefox **nativo** cerrar las barreras 1
y 2 haga que la firma salga. Sigue sin existir ningún positivo de extremo a
extremo, y `encina-snap-fabrica` ha demostrado que **no puede darlo**: allí B3
es infranqueable. El positivo, si llega, tiene que salir de una máquina con
Firefox nativo.

> **Medido el 2026-08-07, y con más barreras de las que aquí se contaban: el
> positivo existe (§4.9).** Cerrar 1 y 2 no bastaba; hacían falta también B4 —el
> perfil donde AutoFirma busca el certificado del usuario— y B6 —NSS no se
> encuentra en arm64—. Y esta prueba se hizo en `sededgsfp.gob.es`, que §4.9(b)
> demuestra incapaz de dar un positivo en Firefox de escritorio por su propia
> CSP: la conclusión sobre B3 se sostiene por la medición del `XDG_DATA_DIRS`,
> no por esta prueba de firma.

### 4.5 Qué está arreglado ya y qué no, revisado el 2026-08-07

Contrastado contra el código, no contra los README.

**Upstream acepta PRs externas, pero despacio.** 34 fusionadas, 25 abiertas. La
mediana de 2 días es de `dependabot`; las humanas son otra cosa: la #497
—**una sola línea**, `+1 −0`— tardó **87 días**, el README de la #481 tardó 23, y
las siete de seguridad de `reatlat` del 2026-07-13 siguen abiertas. No es un
repositorio muerto; es uno lento.

**La barrera 2 NO está arreglada en ninguna versión publicada.** El fichero que
instala la CA del socket, `ConfiguratorFirefoxLinux.java`, es **idéntico byte a
byte (15995) en `v1.9`, `v1.9.1` y `v1.9.2`**, y no menciona `.config/mozilla`
en ninguna. Solo conoce dos rutas, y en este orden:

```java
PROFILES_INI_RELATIVE_PATH_UBUNTU_22 = "snap/firefox/common/.mozilla/firefox/profiles.ini"
PROFILES_INI_RELATIVE_PATH           = ".mozilla/firefox/profiles.ini"
```

Es un `if/else`: si existe la del Snap la usa, **si no** cae a `~/.mozilla/`, que
en un sistema con el `.deb` de Mozilla **no existe**. Ni una ni otra es
`~/.config/mozilla/firefox/`. Esto explica exactamente lo medido en §4.2 y
convierte la barrera 2 en un **bug upstream concreto, vivo y pequeño**.

**Y el arreglo XDG que sí existe está en otro sitio y se perdió.**
`MozillaKeyStoreUtilities.java` —que busca los certificados **de firma** del
usuario, no instala la CA— sí conoce la ruta XDG. Entró en `v1.9.1` (2026-04-29,
35016 bytes) y **`v1.9.2` (2026-05-12) vuelve a los 34562 bytes exactos de `v1.9`
y a cero apariciones**. Medido sobre los tres tags; la causa (¿rama que no
incluyó el cambio?) no se ha investigado.

**El `.deb` oficial va un año por detrás de su propio código fuente:** está
construido sobre `v1.9` (2025-05-21) y upstream está en `v1.9.2` (2026-05-12).

**Lo que `albfernandez` ya corrige**, leído en su `debian/`:

| Fallo de §4.1 | ¿Corregido? |
|---|---|
| 1. JRE no declarado (`Recomends:`) | **Sí** — `Depends: java-runtime, libnss3-tools, openssl, ca-certificates` |
| 2. `postinst` sin `set -e`, éxito con todo roto | **Sí** — el `postinst` empieza con `set -e` |
| B2 — perfil equivocado | **No.** Su changelog cita un ajuste XDG, pero es un salto de versión de upstream (`1.9.202507.1`→`.4`), no un parche suyo, y no toca el configurador |
| B1 — preferencia en `/etc/firefox/pref/` | **No, y no le hace falta**: empaqueta para Debian, cuyo `firefox-esr` **sí** lee ese directorio. B1 solo existe con la compilación de Mozilla |

### 4.6 La estrategia: fork del oficial, no de un tercero

Decidido el 2026-08-07, y corrige una recomendación previa de este documento que
proponía partir de `albfernandez`. **Los parches van al repositorio oficial**, que
es el único sitio desde el que llegan a todo el mundo. Arreglar el repositorio de
un tercero deja el fallo intacto donde importa.

`albfernandez` **no es la base: es una fuente de la que copiar** lo que ya tiene
resuelto —el `debian/control` con `java-runtime`, el `postinst` con `set -e`, la
construcción desde fuentes y el parche de NSS compartida—. Copiar de él ahorra
trabajo; contribuirle no lleva la corrección a ninguna parte.

**El empaquetado Debian está DENTRO del repositorio oficial**, así que los tres
fallos de empaquetado de §4.1 son PRs upstream y no problemas de Encina.
Verificado en `HEAD` el 2026-08-07, en
`afirma-simple-installer/linux/instalador_deb/src/DEBIAN/`:

```
control:   Depends: libnss3-tools
           Recomends: openjdk-17-jre        <- la errata, viva en HEAD
postinst:  #!/bin/sh, sin set -e, con exit 0 final
```

Idénticos en `v1.9` y `v1.9.2`. **No hay CLA, ni `CONTRIBUTING.md`, ni plantilla
de PR**, así que no hay traba formal para contribuir.

**Las cuatro PRs, de menor a mayor riesgo de rechazo:**

> **Nota del 2026-08-11, y esta tabla se queda como está porque es el registro de
> cómo se planearon aquel día:** son **cinco** y **las cinco están abiertas** —
> #552, #553, #554 y #555 el 2026-08-07, y #556 (`no-fabricar-almacen-nss`, la que
> sale de §4.29c) el 2026-08-11. El estado vivo está en `ENCINA-OS.md`, filas
> «Forks de AutoFirma» y B∥, y se pregunta con `gh pr list`, no a este documento.

| | Qué | Tamaño | Nota |
|---|---|---|---|
| 1 | `Recomends:` → `Recommends:` | una palabra | Issue #302 lleva años abierto. Es la más fácil de aceptar |
| 2 | `ConfiguratorFirefoxLinux`: añadir la ruta XDG a `getMozillaProfilesIniPaths` | un método | **La importante (B2).** Se defiende sola: `MozillaKeyStoreUtilities` **ya** hace esa comprobación en el mismo repositorio, así que es coherencia interna, no una función nueva |
| 3 | Preferencias donde la compilación de Mozilla las lee (B1) | pequeña | Beneficia a cualquiera que use el `.deb` o el `.tar.bz2` de Mozilla, no solo a Encina |
| 4 | `postinst` que no declare éxito con todo roto | pequeña | **La más delicada:** un `set -e` a secas convierte instalaciones que hoy pasan en verde en instalaciones que fallan. Es lo correcto, pero conviene presentarlo como gestión de errores explícita y no como una línea suelta, o lo rechazan por regresión |

**Y el argumento de la PR 2 es mejor de lo previsto: upstream ya arregló esto, en
uno de tres sitios.** Hay **tres implementaciones independientes** de la misma
búsqueda, leídas en `HEAD` el 2026-08-07, y no se comportan igual:

| Clase | Para qué | Snap | `.config/mozilla` | `~/.mozilla` |
|---|---|---|---|---|
| `MozillaKeyStoreUtilities` | encontrar los certificados **de firma** del usuario | sí | **sí** | sí |
| `RestoreConfigFirefox` | *Herramientas → Restaurar instalación* | sí | **no** | sí |
| `ConfiguratorFirefoxLinux` | el `postinst`: **instalar la CA del socket** | sí | **no** | sí |

Y la que sí lo hace lleva el motivo escrito al lado:

```java
// Directorio de Firefox 147 y superiores
if (new File(Platform.getUserHome() + "/.config/mozilla/firefox/profiles.ini").isFile()) {
    return Platform.getUserHome() + "/.config/mozilla/firefox/profiles.ini";
}
```

**La PR no pide una función nueva: pide terminar una que ya está empezada.** En
`ConfiguratorFirefoxLinux` es insertar una rama `else if` en un `if/else` de seis
líneas, copiando el comentario incluido.

**Un detalle del `if/else` que conviene entender antes de tocarlo:** es
excluyente. Si existe el `profiles.ini` del Snap, **no se mira ninguna otra
ruta**. Como R4 deja el Snap instalado en las máquinas Encina, el configurador se
queda siempre con el perfil del Snap y **nunca llega a considerar el nativo**.
Por eso `cmnc3cx7.default-release` tenía cero certificados (§4.2). El arreglo
correcto no es sustituir una ruta por otra: es **recorrerlas todas**, porque en
una máquina puede haber a la vez perfil de Snap y perfil nativo.

**Hipótesis refutada, y queda un cabo suelto.** Se supuso que la CA que apareció
en `~/.config/mozilla/firefox/ev2eu1nn.default` (§4.2) la había puesto
«Restaurar instalación». **Es falso: esa clase tampoco conoce la ruta XDG.**
Ninguna de las dos que escriben la CA puede llegar ahí, así que su origen sigue
sin explicar. No bloquea nada —la divergencia está medida y la PR se sostiene
sola—, pero no se da por bueno.

Y un **issue**, no una PR: `v1.9.2` (2026-05-12) devuelve
`MozillaKeyStoreUtilities.java` a los 34562 bytes exactos de `v1.9`, perdiendo el
arreglo XDG que había entrado en `v1.9.1`. Es un aviso de rama mal fusionada, y no
es nuestro para arreglarlo.

**Y no se espera a que las acepten.** La #497, de una sola línea, tardó 87 días.
El paquete propio sale del fork y se usa en Encina mientras tanto; cada PR que
entre se retira del fork.

### 4.7 ¿El `.deb` corregido hace innecesario el Firefox nativo? No

Pregunta razonable al decidir el fork, y la respuesta está **medida**, no
deducida: es el experimento de §4.4. Se cerró la barrera 1 a mano sobre
`encina-snap-fabrica`, con la barrera 2 ya cerrada de fábrica, **y la firma
siguió fallando**. Un `.deb` corregido no habría hecho más que eso.

El motivo es que **B3 no la puede arreglar AutoFirma**, por mucho que se corrija:
las rutas de preferencias que la compilación de Mozilla lee dentro del Snap están
en un `squashfs` de solo lectura, y el `afirma.desktop` y el `/usr/bin/autofirma`
que AutoFirma instala en el host **no existen dentro del confinamiento**. No hay
nada que un paquete `.deb` pueda escribir para hacerse visible ahí.

**Ninguna de las dos piezas basta sola, y las dos juntas sí:**

| | B1 | B2 | B3 | ¿Firma? |
|---|---|---|---|---|
| `.deb` oficial + Snap (hoy, de fábrica) | sí | no | **sí** | no |
| `.deb` oficial + Firefox nativo (Encina hoy) | **sí** | **sí** | no | no |
| `.deb` **corregido** + Snap | no | no | **sí** | **no** |
| `.deb` **corregido** + Firefox nativo | no | no | no | **SÍ, medido el 2026-08-07** |

La última fila **ya está comprobada**: «Fichero firmado correctamente» en
`valide.redsara.es`, con certificado real de la FNMT y Firefox nativo. Detalle en
§4.9. La tabla se quedaba corta: hacían falta además B4 y B6, que entonces no se
conocían.

**Esto no reabre A2: la confirma, y le cambia el fundamento.** A2 se justificaba
con que «el Snap aísla el almacén NSS», que era heredado y **falso** —el almacén
NSS del Snap funciona perfectamente (§4.3)—. Se sostiene por otro motivo, este sí
medido: **el Snap esconde el manejador de protocolo.** Misma conclusión, cimiento
distinto.

**Y hay una consecuencia para el parche.** R4 deja el Snap instalado en una
máquina Encina, así que conviven los dos perfiles. Como el `if/else` del
configurador es excluyente y el Snap va primero, el `.deb` corregido **tiene que
recorrer todas las rutas**, no elegir una: si solo se le añade una rama `else if`,
en una máquina Encina seguirá configurando el perfil del Snap y dejando el nativo
—el que el usuario usa— sin la CA. Es el fallo medido en §4.2, sin cambios.
- openSUSE: paquete comunitario en el repo personal de Antonio Larrosa; sin
  paquete oficial para Leap 15.6.
- AUR: `autofirma`, `autofirma-bin`, y un `autofirmaja` cuyo mantenedor declara
  abiertamente que no puede sostenerlo.

**Licencia:** AutoFirma es software libre, GPL 2+ y EUPL 1.1, código en la forja
del CTT. **Es redistribuible.**

**Los issues upstream, contrastados contra medición propia (ver §4.1):**

- Issue #302 (`openjdk-11-jre` no declarado): **confirmado, y es peor de lo que
  dice.** No es un olvido: el `control` del `.deb` 1.9 escribe `Recomends:` en
  lugar de `Recommends:`. Al no ser un campo Debian válido, dpkg lo arrastra como
  campo de usuario y no actúa. El JRE no queda declarado por ninguna vía, ni
  siquiera con `apt install --install-recommends`. **Corrección del 2026-08-07:**
  este documento venía escribiendo la errata como `Recoments:`; el campo real es
  `Recomends:`, remedido con `dpkg -s autofirma`. Importa porque una comprobación
  escrita contra la cadena equivocada no habría disparado nunca.
- Issue #459 (`certutil: SEC_ERROR_ADDING_CERT` durante la instalación):
  **NO reproducido.** Cinco instalaciones en VM propia y dos intentos de
  provocarlo a mano no lo produjeron. No darlo por bueno. Quien lo reportó dice
  además que la aplicación le firma igualmente, así que puede ser el menor de los
  problemas. Lo que sí apareció, en el `prerm`, fue `SEC_ERROR_BAD_DATABASE`.

**El hueco real:** no existe ninguna herramienta de diagnóstico. Todo lo que hay
es o un paquete o un tutorial. Nadie itera sobre perfiles de navegador, nadie
detecta sandbox, y nadie se dirige al usuario individual no técnico. **Y la
herramienta de reparación del propio fabricante declara sano un sistema roto**
(§4.1).

**Riesgo del sector, aplicable a ti:** todos estos proyectos mueren por
agotamiento de una sola persona. De ahí D5 y el alcance mínimo.

### 4.8 Forma del fork: tres repositorios, y el empaquetado aparte

Medido el 2026-08-07. **AutoFirma no se construye desde un repositorio, sino
desde tres**, todos vivos en la organización oficial:

```
ctt-gob-es/clienteafirma            594 620 KB   (~580 MB)   push 2026-08-05
ctt-gob-es/jmulticard                 7 033 KB               push 2026-04-29
ctt-gob-es/clienteafirma-external    11 796 KB               push 2026-04-29
```

`albfernandez` **forkea los tres** y los compila con Maven en cadena
(`jmulticard` → `clienteafirma-external` → `clienteafirma`), y guarda su
empaquetado en un **cuarto repositorio de 110 KB**,
`clienteafirma-deb-package`, que no contiene código de AutoFirma: solo un
`debian/` y un script que descarga los tags y llama a `dpkg-buildpackage`.

**Y su `master` no tiene ni un commit propio:** `ahead_by=0, behind_by=182`
frente al oficial. No parchea el Java; todo su trabajo está en el `debian/`.
Su `debian/` **sustituye** al empaquetado de upstream —que es un `DEBIAN/`
hecho a mano y no un `debian/` en regla—, así que los dos fallos de
empaquetado de §4.1 **no le afectan**: no usa esos ficheros.

**Consecuencia para las PRs, y conviene tenerla clara:** las PRs 1 y 4
(`Recomends:` y el `postinst`) arreglan **el `.deb` oficial que se descarga la
gente**, no el paquete propio, que llevará su propio `debian/`. Siguen mereciendo
la pena —son el `.deb` que usa todo el mundo— pero no desbloquean nada de Encina.
Las que sí lo desbloquean son la 2 y la 3, que son Java.

**Por qué NO va como submódulo de `encina-os`.** No es una preferencia de estilo,
son los números: `encina-os` pesa **176 KB** y el árbol de AutoFirma **580 MB**,
tres mil veces más, y no sería un submódulo sino tres. Cada clonación del
repositorio y **cada trabajo de la CI** —incluidos los dos que construyen
`encina-branding` y `encina-firefox-native` en segundos— arrastrarían ese peso.
Un submódulo fija un commit, sí; pero una variable de versión en el script de
construcción lo fija igual, que es lo que hace albfernandez y funciona. Y de
propina evita mezclar en un mismo árbol la EUPL-1.2 de Encina con la GPL-2+ /
EUPL-1.1 de AutoFirma.

**La forma, decidida y ya creada el 2026-08-07:**

```
jmorenobl/clienteafirma            \
jmorenobl/jmulticard                > forks del oficial, una rama por corrección.
jmorenobl/clienteafirma-external   /  De aquí salen las PRs.

jmorenobl/encina-autofirma            repositorio APARTE, privado (D5).
                                      Solo debian/ + script de construcción con
                                      los tres tags anclados. En el Mac,
                                      ~/Projects/encina-autofirma
```

**El empaquetado va en un repositorio aparte y NO en `debian-packages/` de
`encina-os`**, que es lo que este documento proponía en una redacción anterior.
El motivo es el aviso de coste de aquí abajo: si vive aquí, comparte CI con A1 y
A2. El árbol de AutoFirma no se versiona en ninguno de los dos: va a `build/`,
ignorado. `encina-os` sigue pesando kilobytes.

**Aviso de coste, una vez y sin insistir:** esto añade una cadena de tres
proyectos Maven a un proyecto que hoy construye dos paquetes triviales en
segundos. Es donde §4 dice que estos proyectos mueren por agotamiento de una sola
persona. De ahí el repositorio aparte: un fallo de Maven no debe tapar el estado
de A1 y A2, ni al revés.

**Lo primero que hay que medir allí, antes de escribir ningún parche:** cuánto
tarda la cadena completa en compilar y si sale limpia en arm64. Si tarda cuarenta
minutos, condiciona cómo se monta la CI, y eso se sabe el primer día o no se sabe.
Es la lección de A3 aplicada aquí: **¿qué comando demuestra que esto es viable?**

**Medido el 2026-08-07: 83 segundos con la caché de Maven vacía**, en Ubuntu
24.04 arm64. La CI no está condicionada. El `.deb` completo con
`dpkg-buildpackage` son 120 s más, así que una CI desde cero es de tres minutos
y medio. Detalle en `MEDICIONES.md` M1 del repositorio `encina-autofirma`.

### 4.9 EL PRIMER POSITIVO DE EXTREMO A EXTREMO (2026-08-07)

**«Fichero firmado correctamente», mirado en pantalla.** En
`valide.redsara.es/valide/firmar/ejecutar.html`, con Firefox 153.0.3 **nativo**
de Mozilla y un certificado **real de la FNMT** (`AC FNMT Usuarios`, válido
09/05/2025–09/05/2029), sobre un clon de `encina-autofirma-rota` y con el `.deb`
propio `autofirma 1.9.1+encina1`.

Es lo que §4.7 pedía y §4.4 daba por inexistente. **Y lo hizo el paquete, no el
laboratorio:** `dpkg -V autofirma` sale sin una sola diferencia, así que ningún
parche aplicado a mano durante el diagnóstico sobrevivía.

La cadena, medida en directo mientras se pulsaba «Firmar»:

```
19s  java=1  escucha=0.0.0.0:65429
21s  java=1  conexion=127.0.0.1:60278<->127.0.0.1:65429
```

El handshake `wss://` completo prueba que **el navegador confió en la CA de
AutoFirma**: la barrera 2, cerrada en producción.

**No eran dos barreras, ni tres. Son seis, y solo cuatro las cierra el paquete:**

| # | Qué | ¿Quién la cierra? |
|---|---|---|
| B1a | Preferencias del esquema en `/etc/firefox/pref/`, que la compilación de Mozilla no lee | El paquete: las instala además en `/usr/lib/firefox/defaults/pref/` |
| B1b | **`network.protocol-handler.app` ya no existe en Firefox 153** | El paquete: `expose.afirma=false` |
| B2 | La CA del socket en el perfil equivocado | Parche de Java al configurador |
| B3 | El manejador invisible dentro del Snap | **Nadie.** Se evita con Firefox nativo |
| B4 | El perfil donde AutoFirma busca el certificado **del usuario**: el Snap primero | El lanzador, con `AFIRMA_NSS_PROFILES_INI` |
| B5 | La CSP de la sede bloquea el iframe de `autoscript.js` | **Nadie desde el equipo** |
| B6 | **NSS no se encuentra en arm64** | El lanzador, con `AFIRMA_NSS_HOME_ENV` |

**Cuatro correcciones a lo que este documento venía afirmando:**

**a) La barrera 1 no era solo una cuestión de ruta.** §4.1 concluyó que el
fichero estaba donde nadie lo lee. Es cierto y se queda corto: **aunque
estuviera en la ruta correcta tampoco funcionaría**, porque la preferencia con
la que AutoFirma dice «ejecuta `/usr/bin/autofirma`» ha desaparecido del motor.
Medido con `strings` sobre `libxul` de Firefox 153, con control negativo:

```
network.protocol-handler.app               0     <- INEXISTENTE
network.protocol-handler.external          5
network.protocol-handler.expose            2
network.protocol-handler.warn-external     2
INVENTADA.no.existe                        0     <- control
```

**b) La sede de la DGSFP no puede dar un positivo en Firefox de escritorio.**
`sededgsfp.gob.es` es la que usaron §4.1, §4.3 y §4.4. Su propia
Content-Security-Policy bloquea el iframe con el que `autoscript.js` invoca el
esquema en Firefox de escritorio:

```
frame-src 'self' blob: https://*.sededgsfp.gob.es https://www.google.com/recaptcha/ …
```

`afirma:` no figura. **Ninguna de aquellas tres pruebas de firma podía salir
positiva**, midieran lo que midieran. No invalida B3, que tiene prueba propia
—el `XDG_DATA_DIRS` del snap—, pero sí significa que aquella prueba no
discriminaba lo que se creía, y que el criterio de éxito de §4.7 estaba anclado
a una sede incapaz de darlo. **La sede válida para el criterio es
`valide.redsara.es`**, que no envía CSP.

**c) D9 sí muerde, por un camino que no se había mirado.** `Architecture: all`
sigue siendo correcto —el paquete no lleva binarios de ninguna arquitectura—
pero el **código** sí depende de ella: `MozillaKeyStoreUtilitiesUnix` lleva
escritas a mano `/usr/lib/x86_64-linux-gnu` y `/usr/lib/i386-linux-gnu`, y
ninguna `aarch64`. Sin proveedor NSS el almacén no se inicializa y el diálogo
dice «No se han encontrado certificados válidos en el almacén» **teniendo el
certificado delante**. El síntoma no menciona NSS por ninguna parte.

**d) `git` a través del hook de `rtk` devuelve commits que no son.** Se le pide
uno concreto y contesta otro, con su asunto, sin fallar ni avisar. `rev-parse
--short HEAD` sí coincide, así que una comprobación rápida lo declara sano.
**Cualquier medición sobre git de este proyecto debe tomarse con `/usr/bin/git`
o con `rtk proxy`.** Las conclusiones de §4.5 y §4.6 que se apoyen en hashes o
fechas conviene rehacerlas.

**Las PRs, ahora cuatro, escritas y sin abrir:** la errata `Recomends:`, las
preferencias del esquema, los perfiles XDG del configurador y las rutas NSS
multiarch. Se descartó una quinta —hacer que Firefox de escritorio use
`document.location` en lugar del iframe— porque el único A/B disponible la
contradice: el iframe **sí** lanza AutoFirma y `document.location` no. Sin
medición que la respalde, no se propone.

**Lo que sigue sin medirse:** amd64 (todo esto es arm64, y B6 no aparecería
allí); Ubuntu de fábrica con Snap, donde B3 sigue siendo infranqueable; y si el
paquete sobrevive a una actualización de Firefox de Mozilla.

> **Enmienda del 2026-08-08.** El tercero de esos tres ya está medido: el
> paquete sobrevive a la actualización de Firefox, a la purga entera de Firefox
> y a su reinstalación, con los dos controles puestos —que `libxul.so` fue
> realmente reemplazado, y que Firefox *lee* el fichero y no solo que exista—.
> `encina-autofirma/MEDICIONES.md` M13. Los otros dos siguen abiertos, y amd64
> es hoy un límite de alcance declarado (§2, D9), no un pendiente.


### 4.10 R10 y `encina-meta`: por qué vía llega Firefox nativo (2026-08-08)

Medición previa a escribir `encina-meta`, para responder a la pregunta que puede
parar E1 (`ENCINA-OS.md` §10): **¿puede `encina-meta` no declarar `firefox` sin
que la máquina se quede sin navegador?**

**Respuesta: sí, y por un motivo distinto del que suponía `AGENTS.md` §6.3.** El
nombre `firefox` **ya está instalado** en toda Ubuntu de escritorio, apuntando a
un deb de transición al Snap, y el anclaje de `encina-firefox-native` reasigna
ese nombre al deb de Mozilla. Nadie instala Firefox: se sustituye el que ya hay.

> **Enmienda del 2026-08-10, y no anula esta sección: le pone frontera.** Esa
> premisa (a) —«el nombre `firefox` ya está instalado»— **es cierta en toda
> máquina con Snap, que son todas las de E1, y deja de serlo en cuanto E2 quite
> el Snap.** El `.deb` de transición **depende de `snapd`**, así que
> `apt-get purge snapd` se lo lleva, y la máquina se queda con
> `firefox: Installed: (none)` (§4.16j). Ahí ya no hay nada que sustituir:
> Firefox nativo tendría que **instalarse**. Probablemente sea más simple —el
> anclaje se encuentra el nombre libre— pero **no está medido**, y lo que esta
> sección concluye por la vía de la sustitución no se puede dar por bueno en una
> máquina sin Snap sin volver a medirlo.

**Dónde se midió.** Contenedor `ubuntu:24.04` **arm64 nativo** en el Mac
(`dpkg --print-architecture` → `arm64`), con los índices reales de
`ports.ubuntu.com` y de `packages.mozilla.org` y el `.deb` real
`encina-firefox-native_0.2.0`. Todo en simulación (`apt-get -s`) y con `LC_ALL=C`
(trampa 2 de `SCRIPTS.md`). La premisa de partida (a) se confirmó además en la
VM `encina-limpia-respaldo`, arrancada, leída y apagada, **sin instalar nada**.

**Lo que el contenedor NO es, y hay que tenerlo delante:** no es un escritorio y
nunca tuvo el Snap vivo. Aquí no se ha medido ni una sola conducta de Snap ni de
GNOME: se han medido **decisiones de apt**, que dependen de la versión instalada,
de los índices y del anclaje, y de nada más.

**a) La premisa: una Ubuntu de escritorio ya trae el nombre `firefox`.** En
`encina-limpia-respaldo` (Ubuntu 24.04.4 arm64, huella: cero paquetes `encina-*`,
sin ningún perfil de Mozilla, solo `ubuntu.sources`, instalada el 2026-08-06,
Snap de Firefox 147.0.3-1 rev 7764):

```
$ LC_ALL=C apt-cache policy firefox
firefox:
  Installed: 1:1snap1-0ubuntu5
  Candidate: 1:1snap1-0ubuntu5

$ LC_ALL=C apt-cache rdepends --installed firefox
Reverse Depends:
  ubuntu-desktop-minimal
```

Llega como **`Recommends:` de `ubuntu-desktop-minimal`**, no como `Depends:`
(comprobado en el índice: `firefox` figura en su `Recommends:` y no en su
`Depends:`). Y ese paquete no es Firefox:

```
Package: firefox
Version: 1:1snap1-0ubuntu5
Pre-Depends: debconf, snapd (>= 2.54)
Depends: debconf (>= 0.5) | debconf-2.0
```

77 kB: iconos, documentación y un `/usr/bin/firefox` de 2377 bytes que es un
script. Su `preinst` imprime `=> Installing the firefox snap`. **Y el script hace
algo que conviene saber:** si lo ejecutas, reescribe `favorite-apps` cambiando
`firefox.desktop` por `firefox_firefox.desktop` y mueve
`xdg-settings default-web-browser` al Snap — es decir, deshace en caliente lo que
hace el `gschema.override` de `encina-firefox-native`. Deja de poder hacerlo en
cuanto el deb de Mozilla lo sustituye, porque entonces `/usr/bin/firefox` es el
binario de verdad.

**b) La vía, y su control.** Sobre un escritorio simulado con los paquetes
**reales** de Ubuntu (`snapd` y el `firefox` de transición instalados con apt, y
el sistema puesto al día antes de empezar):

```
--- linea base, sin el repo de Mozilla ---
$ LC_ALL=C apt-get -s full-upgrade
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
firefox:  Installed: 1:1snap1-0ubuntu5   Candidate: 1:1snap1-0ubuntu5

--- tras instalar encina-firefox-native y hacer apt update ---
firefox:  Installed: 1:1snap1-0ubuntu5   Candidate: 153.0.3~build1

$ LC_ALL=C apt-get -s upgrade
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.

$ LC_ALL=C apt-get -s full-upgrade
The following packages will be DOWNGRADED:
  firefox
0 upgraded, 79 newly installed, 1 downgraded, 0 to remove and 0 not upgraded.
Inst firefox [1:1snap1-0ubuntu5] (153.0.3~build1 …/repositories/mozilla:mozilla [arm64])
```

La tabla de versiones, con las dos prioridades a la vista:

```
     1:1snap1-0ubuntu5 500
        500 http://ports.ubuntu.com/ubuntu-ports noble/main arm64 Packages
     153.0.3~build1 1000
       1000 https://packages.mozilla.org/apt mozilla/main arm64 Packages
```

**Control negativo**, sobre ese mismo sistema y retirando **solo**
`/etc/apt/preferences.d/encina-mozilla`:

```
firefox:  Installed: 1:1snap1-0ubuntu5   Candidate: 1:1snap1-0ubuntu5
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
      # ninguna linea "Inst firefox": se queda en el Snap
```

**Control del control:** repuesto el fichero, vuelve a aparecer la línea `Inst
firefox … mozilla`. La comprobación sabe decir que sí y sabe decir que no, y lo
que la mueve es el anclaje y nada más.

**c) `upgrade` no hace el cambio; `full-upgrade` sí. Y con `-y` se niega.**
Es un *downgrade* formal (el epoch `1:` del deb de transición lo hace versión más
alta), así que:

```
$ LC_ALL=C apt-get -y -s full-upgrade
E: Packages were downgraded and -y was used without --allow-downgrades.

$ LC_ALL=C apt-get -y -s full-upgrade --allow-downgrades
Inst firefox [1:1snap1-0ubuntu5] (153.0.3~build1 …/repositories/mozilla:mozilla [arm64])
```

Importa para E2: una `late-command` que dé este paso necesita
`--allow-downgrades`, y sin él **falla ruidosamente**, que es lo bueno. Y
`unattended-upgrades`, que hace `upgrade` y no `full-upgrade`, no lo dará nunca.

**d) El límite de la vía: depende de la base.** Sobre una base **sin** `firefox`
instalado, un metapaquete que no lo declara instala con código 0 y después:

```
firefox:  Installed: (none)   Candidate: 153.0.3~build1
$ LC_ALL=C apt-get -s full-upgrade
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
      # la maquina se queda SIN NAVEGADOR
```

O sea que la vía existe porque Ubuntu Desktop trae el deb de transición. **Si la
imagen de E2 no parte de un escritorio completo, esta vía no está**, y hay que
instalar Firefox explícitamente en el seed.

**e) Qué haría `Depends: firefox`, medido con dos metapaquetes de laboratorio.**
No es lo que decía `AGENTS.md` §6.3 —«produciría una dependencia irresoluble»—.
Son dos modos, y **el peor es silencioso**:

```
--- escritorio de fabrica, repo de Mozilla aun ausente de los indices,
--- una sola transaccion: apt-get -s install ./meta.deb ./encina-firefox-native.deb
0 upgraded, 5 newly installed, 0 to remove and 0 not upgraded.
Inst libdconf1 … Inst dconf-service … Inst dconf-gsettings-backend
Inst encina-firefox-native (0.2.0 local-deb [all])
Inst lab-meta-a (0 local-deb [all])
      # NINGUNA linea de firefox: la dependencia la satisface el deb de
      # transicion YA instalado. apt sale con 0 y la maquina sigue en el Snap.

--- la misma orden sobre una base sin firefox instalado
0 upgraded, 104 newly installed, 0 to remove and 0 not upgraded.
Inst snapd (2.76+ubuntu24.04.1 Ubuntu:24.04/noble-updates, …)
Inst firefox (1:1snap1-0ubuntu5 Ubuntu:24.04/noble [arm64])
      # INSTALA EL SNAP.
```

El motivo de fondo es que el repositorio de Mozilla no está en los índices
**cuando apt resuelve**: los ficheros que lo declaran se desempaquetan dentro de
esa misma transacción, y apt ya había decidido. R10 se sostiene, y por un motivo
más fuerte que el escrito: no es que falle, es que **acierta con el paquete
equivocado sin decir nada**. Es el patrón de D13 —cambiar un fallo visible por
uno silencioso— aplicado al resolutor.

**f) El idioma español no tiene ninguna vía, y es el hueco real de E1.**

```
$ LC_ALL=C apt-cache policy firefox-l10n-es-es      # sin el repo de Mozilla
firefox-l10n-es-es:
  Installed: (none)
  Candidate: (none)

$ LC_ALL=C apt-cache policy firefox-locale-es
  Candidate: 1:1snap1-0ubuntu5   # noble/universe: OTRO transitorio al Snap
```

Declararlo sí es duro y ruidoso, que es la diferencia con (e):

```
 lab-meta-c : Depends: firefox-l10n-es-es but it is not installable
E: Unable to correct problems, you have held broken packages.
```

Y no declararlo tampoco lo trae: en el `full-upgrade` de (b) **no aparece
ninguna línea `Inst firefox-l10n`**. Conclusión medida: con `encina-meta` tal
como está especificado en `AGENTS.md` §6.2, **Firefox nativo llega en inglés**.
No lo arregla partir `encina-firefox-native`: lo que impide declararlo es que el
índice no esté presente al resolver, así que un paquete aparte tendría el mismo
problema en la misma transacción. Solo funciona como **segundo paso**, con un
`apt update` en medio — que es la secuencia que `AGENTS.md` §5.4 ya documenta.

**g) La cláusula «ni transitivamente» de R10 está limpia.** Simulando el resto de
lo que `encina-meta` declararía (el bloque de l10n de D12 y las `Depends:` de
`autofirma`) **sobre la máquina que sí tiene el repo de Mozilla configurado**,
que es donde algo de allí podría colarse:

```
     70 Ubuntu:24.04/noble
     41 Ubuntu:24.04/noble-updates,
      6 Ubuntu:24.04/noble-updates
--- lineas de packages.mozilla.org: NINGUNA
--- control positivo (apt-get -s install firefox):
Inst firefox [1:1snap1-0ubuntu5] (153.0.3~build1 …/repositories/mozilla:mozilla [arm64])
```

117 paquetes, ninguno de Mozilla, y el control demuestra que la comprobación no
está ciega: sabe imprimir esa línea cuando la hay.

**h) Un `Recommends:` de §6.2 instala un Snap.** `thunderbird-locale-es` es él
mismo un transitorio:

```
thunderbird-locale-es:  Candidate: 2:1snap1-0ubuntu3
Depends: thunderbird (>= 2:1snap1-0ubuntu3)

$ LC_ALL=C apt-get -s install --no-install-recommends thunderbird-locale-es
Inst thunderbird (2:1snap1-0ubuntu3 Ubuntu:24.04/noble [arm64])
Inst thunderbird-locale-es (2:1snap1-0ubuntu3 …)

Package: thunderbird
Pre-Depends: debconf, snapd
```

En un producto cuyo motivo es no depender del Snap, esa línea necesita decisión
explícita. **No medido:** si el escritorio de fábrica ya trae Thunderbird, en
cuyo caso sobre esa base concreta es inocuo. `libreoffice-l10n-es`, en cambio,
está limpio: `Depends: locales | locales-all`.

**Lo deducido y NO medido, que no se da por bueno:** que el `full-upgrade` de (b)
se comporte igual en una VM real con escritorio. El contenedor comparte apt,
arquitectura e índices, pero no es un escritorio. El A/B cuesta un clon y
`08-firefox-instalar.sh --sin-firefox`, y hace falta instalar en una máquina.

> **Cerrado el 2026-08-08.** Ese A/B ya está hecho, en una VM real con escritorio
> y con el Snap vivo: §4.11(a). Se comporta igual que el contenedor.


### 4.11 E1 en una VM de verdad: lo deducido de §4.10, y dos cosas que no salieron (2026-08-08)

Ejecución de la definición de terminado de `AGENTS.md` §6.4 sobre la VM
**`encina-E1-meta`**, clon de `encina-limpia-respaldo` hecho ese día con
`utmctl clone`. **Huella tomada antes de tocarla**, porque las seis VMs comparten
hostname (`encina-dev`) e IP: cero paquetes `encina-*`, sin `autofirma`, solo
`ubuntu.sources` en `sources.list.d`, ningún perfil de Mozilla, `firefox` deb
`1:1snap1-0ubuntu5`, Snap de Firefox `147.0.3-1` rev 7764, Ubuntu 24.04.4 arm64,
un solo usuario. Coincide con la premisa (a) de §4.10.

Los tres scripts —`10`, `11`, `12`— dieron **48 comprobaciones correctas y 0
fallos**. Lo que importa no son las 48: son las tres cosas de abajo.

**a) Lo que §4.10 dejaba deducido, ahora medido.** Aquella sección cerró con «lo
deducido y NO medido: que el `full-upgrade` de (b) se comporte igual en una VM
real con escritorio». Se comporta igual, y con el Snap instalado y vivo:

```
paso 1 (los cuatro .deb):  firefox 1:1snap1-0ubuntu5    <- intacto
                           snap firefox 147.0.3-1 7764  <- intacto (R4)
paso 2 (apt update):       Candidate: 153.0.3~build1
                            *** 1:1snap1-0ubuntu5 500  ports.ubuntu.com
                                153.0.3~build1   1000  packages.mozilla.org
plan del paso 3:  Inst firefox [1:1snap1-0ubuntu5] (153.0.3~build1 …/mozilla)
paso 3 aplicado:  dpkg-query -W firefox -> 153.0.3~build1   (sin epoch)
                  readlink -f /usr/bin/firefox -> /usr/lib/firefox/firefox
                  firefox-l10n-es-es 153.0.3~build1 instalado
```

Mirado en pantalla en `about:support`, y en el orden que exige §6.4 —primero el
binario, después el idioma—: `Binario de la aplicación =
/usr/lib/firefox/firefox-bin`, `ID de distribución = mozilla-deb`, `Directorio de
perfil = /home/jorge/.config/mozilla/firefox/…` y la interfaz en español.
`Políticas empresariales: Inactivo`, o sea D13 vista y no deducida.

*Trampa anotada para no perseguirla:* el `Agente de usuario` dice `x86_64` en una
máquina arm64. Firefox congela ese campo en Linux a propósito.

**b) El paquete abría un hueco de l10n, y lo abría su bloque de l10n.** La
casilla «`check-language-support -l es` sigue saliendo vacío» **no se cumplió**:

```
$ LC_ALL=C check-language-support -l es
libreoffice-help-es
```

La cadena, medida entera y no supuesta. En `/var/log/apt/history.log`, la
transacción del paso 1 instaló, todos marcados `automatic`,
`libreoffice-l10n-es`, `libreoffice-common`, `libreoffice-core`,
`libreoffice-uiconfig-common`, `libreoffice-style-colibre`, `ure`, `python3-uno`
y compañía: **33 paquetes y 244 MB**, con `libreoffice-core` (148 MB) dentro. Y
en `/usr/share/language-selector/data/pkg_depends`, la regla 13:

```
tr::libreoffice-common:libreoffice-help-
```

Con `libreoffice-common` instalado, el sistema pasa a echar en falta
`libreoffice-help-<lang>`. **La línea que existía para cerrar huecos de idioma
abría uno.** En §A3 la misma orden salía vacía porque allí no había ningún
LibreOffice: no es que Ubuntu haya cambiado, es que la máquina ya no es la misma.

**c) Y el motivo escrito para ponerla ahí era falso por los dos lados.**
`AGENTS.md` §6.2 decía que `libreoffice-l10n-es` iba en `Recommends:` y no en
`Depends:` «porque depende de `libreoffice-common`: en `Depends:` obligaría a
instalar LibreOffice entero». Medido:

```
$ LC_ALL=C apt-cache show libreoffice-l10n-es | grep -E '^(Depends|Recommends):'
Depends: locales | locales-all
Recommends: libreoffice-core (>> 4:25.8.7)
```

No lo **depende**: lo **recomienda**. Y un `Recommends:` se instala por defecto,
así que ponerlo en `Recommends:` no evitaba nada. **Esto corrige también §4.10h**,
que declaró ese paquete «limpio» mirando solo su `Depends:` — el mismo error de
mirar el campo equivocado que esa misma viñeta acierta en `thunderbird-locale-es`.
Los otros dos del bloque sí están limpios, con control:

```
$ LC_ALL=C apt-cache show hyphen-es mythes-es | grep -E '^(Package|Depends):'
Package: hyphen-es      Depends: dictionaries-common
Package: mythes-es      Depends: dictionaries-common
$ LC_ALL=C apt-get -s install hyphen-es mythes-es
0 upgraded, 0 newly installed, 0 to remove and 4 not upgraded.
```

**Decisión tomada el 2026-08-08:** la línea se cae del `Recommends:` y vuelve en
E4, con `libreoffice-help-es` al lado. Se quita la causa en vez de taparla.

**Y el arreglo, verificado en la misma VM.** `encina-meta 0.1.1` construido con
`10-meta-construir.sh` (14/14, `lintian` sigue sin decir una línea, `Recommends:
hyphen-es, mythes-es`), instalado sobre el 0.1.0, y `apt autoremove --purge` de
los 37 paquetes que quedaron huérfanos —lista mirada entera antes de ejecutarla:
toda la cadena de LibreOffice más `libfwupd2`, que ya estaba huérfano de antes, y
**ninguno de `encina-*`, `autofirma`, `firefox`, `openjdk` ni `snapd`**—:

```
$ LC_ALL=C check-language-support -l es
                                # vacio
$ LC_ALL=C check-language-support -l fr
gnome-user-docs-fr hunspell-fr language-pack-fr language-pack-gnome-fr wfrench
```

El francés es el control, y es imprescindible: sin él, «vacío» y «esta orden ya
no sabe responder» son la misma salida. Firefox sigue en `153.0.3~build1` con
`/usr/bin/firefox → /usr/lib/firefox/firefox`, y los cuatro paquetes en
`install ok installed`.

**Aquí se llegó quitando, no no-poniendo**, así que esto solo no demuestra que
una instalación desde cero con 0.1.1 no traiga LibreOffice. **Demostrado aparte,
el mismo día, en el clon efímero `encina-firma-efimera`** —virgen, con la línea
base tomada antes de tocarla: sin `libreoffice-common`, sin `libreoffice-core` y
con `check-language-support -l es` ya vacío—, ejecutando la secuencia entera «tal
cual y sin ningún arreglo fuera de ella»:

```
$ LC_ALL=C dpkg-query -W libreoffice-common libreoffice-core libreoffice-l10n-es
dpkg-query: no packages found matching libreoffice-common
dpkg-query: no packages found matching libreoffice-core
dpkg-query: no packages found matching libreoffice-l10n-es
$ LC_ALL=C check-language-support -l es
                                # vacio
$ LC_ALL=C dpkg-query -W hyphen-es mythes-es
hyphen-es 1:24.2.1-1
mythes-es 1:24.2.1-1
```

`11-meta-instalar.sh` dio ahí **27 correctas, 0 fallos y 0 avisos**: una más que
en el banco —la del l10n, que allí era el aviso— y ninguna pendiente.

**Y la máquina quedó lista para la casilla que decide**, comprobado antes de
meter ningún certificado, porque cada una de estas ausencias abortaría el intento
sin decir por qué:

```
/usr/bin/autofirma                              presente
/usr/share/applications/autofirma.desktop       presente
xdg-mime query default x-scheme-handler/afirma  -> autofirma.desktop
/usr/lib/firefox/defaults/pref/autofirma.js:
    pref("network.protocol-handler.expose.afirma", false);   <- B1b
    pref("network.protocol-handler.external.afirma", true);
```

Esa ruta —`/usr/lib/firefox/defaults/pref/`— es la que **sí** lee la compilación
de Mozilla, que es B1a; la copia en `/etc/firefox/pref/` también está, y es la
que no se lee. *Ojo con el nombre:* el manejador se llama `autofirma.desktop`, no
`afirma.desktop` como dice el `.deb` oficial y como este documento repite al
hablar de él.

**d) `apt autoremove` y el metapaquete: la casilla depende de cómo entraron.**
Tras `apt purge encina-meta`, los otros tres siguen instalados —correcto—, pero
`autoremove` **no propone ninguno**, porque en el paso 1 entraron *por ruta* en
la línea de órdenes y apt los marcó como manuales. La pregunta se responde con
A/B, marcándolos `auto`:

```
A) con encina-meta INSTALADO -> autoremove no propone ninguno   (control)
B) con encina-meta PURGADO   -> Remv autofirma
                                Remv encina-branding
                                Remv encina-firefox-native
```

O sea que la conducta es la correcta y lo que faltaba era la premisa. **Importa
para E2:** la casilla se cumplirá sola cuando los tres entren como dependencias
desde el repo local; con `.deb` sueltos al lado, no, y no es un fallo.

**Lo que sigue sin medirse:** la firma real sobre esta secuencia. Va en un clon
efímero con certificado personal, que se destruye después (§9.1), y es la única
casilla que decide.

---

### 4.12 EL POSITIVO SOBRE UNA MÁQUINA VIRGEN, y lo que costó llegar (2026-08-08)

**«Fichero firmado correctamente», mirado en pantalla**, en
`valide.redsara.es/valide/firmar/ejecutar.html`, con certificado real de la FNMT,
sobre `encina-firma-efimera` —clon virgen de `encina-limpia-respaldo` **instalado
por la secuencia de E1**, no montado a mano— y con los cuatro paquetes de Encina.
La VM se destruyó después (§9.1): `utmctl delete`, directorio borrado y
comprobado que no queda ninguna copia del `.p12`.

**Qué añade esto al positivo de §4.9.** Aquel se hizo sobre un clon de
`encina-autofirma-rota`, una máquina montada a mano que **ya tenía Firefox nativo
y perfiles de Mozilla creados**. Este es el primero sobre una máquina que no
había tenido nunca nada, instalada por la secuencia documentada. Las seis
barreras, del log de AutoFirma y de `ss`:

```
java ... -jar /usr/share/autofirma/autofirma.jar afirma://websocket?ports=...&v=4
    -> Firefox entrega el URI afirma:            B1a y B1b
127.0.0.1:53215 <-> 127.0.0.1:36164  (establecida y sostenida)
    -> el navegador confia en la CA del socket   B2
Directorio de bibliotecas NSS: /usr/lib/aarch64-linux-gnu
    -> NSS localizado en arm64                   B6
perfiles determinado por 'AFIRMA_NSS_PROFILES_INI' -> 9002enln.default-release
    -> el perfil correcto, no el del Snap        B4
Almacen de claves cargado / Mostramos el dialogo de seleccion de certificados
Certificado seleccionado por el usuario
```

**Pero la casilla que decide NO se marca, y hay que ser exacto con el motivo.**
`AGENTS.md` §6.4 exige la secuencia «tal cual y sin ningún arreglo fuera de
ella». Hubo dos desviaciones, y **solo la primera es culpa del producto**:

**a) La secuencia de E1 deja AutoFirma sin configurar en el navegador. Es un
defecto real, y va con fechas:**

```
12:13:52  se genera /usr/share/autofirma/Autofirma_ROOT.cer   (postinst, paso 1)
12:22:19  NACE ~/.config/mozilla/firefox/                     (nueve minutos despues)
```

El configurador corre en el paso 1, cuando **Firefox nativo todavía no existe** —
llega en el paso 3 — y por tanto no hay ningún perfil donde instalar la CA del
socket. Resultado: `certutil -L` sobre el perfil lista **solo** el certificado
personal, sin `SocketAutoFirma`, y la sede responde «No es posible conectar con
Autofirma debido a un problema de comunicación o de instalación del cliente»,
que es un mensaje que apunta al sitio equivocado.

**El paquete lo avisó, y el script se lo tragó.** En `/var/log/apt/term.log`:

```
autofirma: AVISO: no se ha encontrado ningún perfil de Mozilla, así que la CA
autofirma:        del socket NO se ha instalado en ningún navegador.
autofirma:        Es lo normal si Firefox no se ha abierto todavía. Abre Firefox
autofirma:        una vez y repite la configuración con:
autofirma:          sudo dpkg-reconfigure autofirma
```

`11-meta-instalar.sh` captura la salida de apt en una variable y **solo la
imprime si apt falla**. apt salió con 0. Un aviso que nadie ve no es un aviso.

Ejecutado `sudo dpkg-reconfigure autofirma` con Firefox cerrado, la CA aparece, y
se comprueba **por huella y no por nombre** (trampa de §9), con control negativo:

```
CA en el perfil   96:CE:8D:21:...:73:EA:E7
CA del paquete    96:CE:8D:21:...:73:EA:E7    (antes era C2:F6:...: la regenero)
socket CN=127.0.0.1 emitido por CN=Autofirma ROOT
openssl verify -no-CAfile -no-CApath -no-CAstore -CAfile <CA del perfil>  -> OK
   ... contra una CA equivocada                                          -> error 20
```

**Consecuencia: la secuencia son CUATRO pasos, no tres**, mientras el paquete no
traiga un disparador que reejecute su configurador cuando aparezca un perfil. El
cuarto es «abre Firefox una vez y `sudo dpkg-reconfigure autofirma`». **El arreglo
bueno pertenece a `encina-autofirma`, no a este repositorio.**

**ENMIENDA DEL 2026-08-09 A ESTE APARTADO (a): el defecto está cerrado, y la
secuencia vuelve a ser de tres pasos.** Lo de arriba **no se reescribe**: fue
correcto el día que se midió, y el registro de por qué la casilla no se marcó
vale tal cual. Lo que cambia es el mundo, no la medición.

**El arreglo se hizo donde se dijo que pertenecía**, en `encina-autofirma`
(commits `45ccad6` y `fb5aa9a`). `autofirma 1.9.1+encina2` trae dos unidades de
systemd **de usuario** —una `.path` que vigila las tres raíces de perfiles de
Mozilla y un `.service` que llama al ayudante `sincronizar-ca-mozilla.sh`— que
meten la CA del socket en el perfil **cuando el perfil aparece**, que es minutos
u horas después de instalar el paquete. Las mediciones son **M14–M18 de
`~/Projects/encina-autofirma/MEDICIONES.md`**, y ahí está el detalle; lo que
importa aquí es lo que cierra este apartado, citado de M18:

```
00:13:10  se genera /usr/share/autofirma/Autofirma_ROOT.cer   (postinst, paso 1)
00:16:12  el vigilante la mete en el perfil                    (dos segundos
          despues de que Firefox creara el almacen NSS)
```

**Es el mismo par de fechas de arriba —12:13:52 y 12:22:19—, ahora unido.** Se
midió sobre `encina-E1-vigilante`, clon virgen de `encina-limpia-respaldo` con su
huella de virginidad tomada antes de tocarlo, con la secuencia de `AGENTS.md`
§6.4 ejecutada **tal cual y sin el cuarto paso**, más abrir Firefox una vez en
una sesión Wayland de GNOME de verdad. **No se ejecutó `dpkg-reconfigure` ni una
vez**, y la CA que acabó en el perfil es la del paquete comparada por huella
(`AF:66:CF:22:…:FD:9A`). Que aquel `[OK]` no venía de un `postinst` reejecutado
se comprobó en vez de suponerse: el `postinst` corrió **una** sola vez, tres
minutos antes de que se escribiera el `cert9.db`.

**Tres cosas que esta enmienda NO dice:**

- **No dice que el aviso haya desaparecido.** El `postinst` sigue avisando cuando
  no encuentra perfil y sigue dando la orden manual, para las máquinas donde el
  mecanismo no pueda actuar. No se ha cambiado un fallo visible por uno
  silencioso, y `11-meta-instalar.sh` sigue imprimiendo ese aviso.
- **No dice que la casilla que decide esté marcada.** Sigue sin marcar: falta
  repetir el experimento de la firma real, en otro clon efímero. Lo que ha
  cambiado es que ya no hay ninguna desviación del producto que lo bloquee.
- **No dice que `encina-E1-vigilante` sirva para volver a comprobarlo.** Esa VM
  ya tiene la CA dentro, así que no puede reproducir el caso virgen. Para
  repetirlo hay que clonar otra vez de `encina-limpia-respaldo`.

**Y una trampa nueva salió de allí**, que es de la familia de las de `SCRIPTS.md`
y está anotada como la número 8: **en la imagen base el usuario del escritorio es
UID 501**, no 1000.

**Lo que se ha comprobado desde ESTE repositorio, hoy, y no viene citado de
allí.** Todo lo de arriba es de M18; esto se midió por ssh sobre
`encina-E1-vigilante` al ponerla al día, y es lo que autoriza a escribir lo que
`11-meta-instalar.sh` imprime ahora:

```
$ id
uid=501(jorge) gid=1000(jorge) grupos=1000(jorge),4(adm),24(cdrom),27(sudo),...
$ dpkg-query -W autofirma        ->  autofirma  1.9.1+encina2
$ sudo dmesg | grep '\[drm\] features:'
[drm] features: -virgl +edid ...      <- '-virgl' = virtio-gpu-pci  (§9)
$ sha256sum /etc/gdm3/custom.conf
ceee968ce0212138...d61810af          <- la misma huella de antes del autologin
$ certutil -L -d sql:~/.config/mozilla/firefox/g9amkmb8.default-release
SocketAutoFirma    C,,               <- el unico certificado: ningun personal
$ find ~ -name '*.p12' -o -name '*.pfx' | wc -l   ->  0
```

Y la sección 6 de `11-meta-instalar.sh`, **extraída del script con `sed` y
ejecutada tal cual** para no probar una copia divergente:

```
=== 6. La CA del socket de AutoFirma, en el perfil de Firefox ===
--- el vigilante de AutoFirma, que es quien instala la CA cuando nace el perfil
  [OK]    El vigilante está ARMADO: cuando aparezca un perfil, la CA se instala sola
  [OK]    La CA del socket está en g9amkmb8.default-release, y es la del paquete
         AF:66:CF:22:71:80:5D:1F:07:49:F7:76:38:0F:09:24:FA:C0:E6:D9:E8:3C:EB:5C:4B:EC:25:03:69:97:FD:9A
```

Esa huella es la de M18, carácter por carácter. **Y las dos respuestas que el
consejo nuevo necesitaba saber dar, medidas antes de escribirlo**, con sus
sabotajes —parar la unidad, y apuntar la ruta de la unidad a algo que no
existe—; el detalle está en `SCRIPTS.md`, trampa 8 y sección de `11`:

```
  [OK]    armado  -> armado     (la maquina tal cual)
  [OK]    dormido -> dormido    (unidad parada: sesion abierta antes de instalar)
  [OK]    ausente -> ausente    (sin unidad: 'autofirma' anterior a +encina2)
  [OK]    sin-bus -> sin-bus    (sin systemd de usuario alcanzable)
```

**Es lo que impide que el arreglo de allí convierta este script en un mentiroso:**
a una máquina con el paquete viejo le sigue diciendo que tiene que teclear
`sudo dpkg-reconfigure autofirma`, porque en ésa la CA no llega sola.

**b) La segunda desviación no es del producto: es del laboratorio, y la causa
está medida. Es la tarjeta de vídeo emulada.** El diálogo de AutoFirma **no se
dibuja** en la VM. Medido sin ojos, capturando la ventana X11 y contando colores
(método en (d)).

**El experimento que lo cierra, 2026-08-08, sobre `encina-E1-meta`.** Misma VM,
mismo disco, misma sesión Wayland de GNOME, mismo comando y misma ventana
(`0xe00007 "Autofirma v1.10"`, 790x637, `Map State: IsViewable` en los tres
casos). **Una sola variable**: la tarjeta, cambiada **desde la interfaz de UTM** —
no editando el `config.plist`, que es justo lo que la vez anterior no se supo
verificar— y comprobada **dentro del invitado** con (e):

```
tarjeta (verificada dentro)   variable Java    colores    medio    resultado
virtio-ramfb-gl               ninguna                1        0    negro absoluto
virtio-ramfb-gl               xrender=false       2976    39605    pinta
virtio-gpu-pci                ninguna             3858    42957    pinta
```

Con `virtio-ramfb-gl` el histograma de la ventana entera son 503230 píxeles
`#000000` y nada más. **Con `virtio-gpu-pci` se dibuja sin ninguna variable de
entorno.** La fila de en medio es el control positivo, tomado en la misma máquina
y la misma tarde: prueba que el `colores=1` es la ventana y no la captura.

**Consecuencias, y hay tres:**

- **`_JAVA_OPTIONS=-Dsun.java2d.xrender=false` no arregla un defecto del
  producto.** Tapa uno del laboratorio. No tiene por qué llevarlo la imagen ni
  ningún paquete de Encina.
- **La hipótesis de Xorg queda descartada, y ahora el pasado encaja.**
  `encina-autofirma-rota` —base del positivo de §4.9— corría **Wayland**
  (`Session=ubuntu` en `/var/lib/AccountsService/users/jorge`,
  `gnome-session-wayland.target` en el journal del 7 de agosto, y sin
  `~/.xsession-errors`, que solo existe en X11; el método se validó antes de
  usarlo contra la verdad conocida `Type=x11` ↔ `Session=ubuntu-xorg`). Lo que
  tiene `rota` **no es Xorg: es `virtio-gpu-pci`**, y con eso basta para que
  pinte. La sesión gráfica no entra en la explicación.
- **La fila `"virtio-gpu-pci" + Wayland → colores=106` queda retirada.** Se tomó
  con el plist editado a mano y `lspci` por toda verificación, así que no se sabe
  qué tarjeta estaba activa cuando se midió. Con `virtio-gpu-pci` **verificada**,
  esa medida da 3858.

**c) Las VMs de este proyecto no son comparables entre sí, y no estaba escrito.**

```
virtio-gpu-pci    encina-dev, encina-dev-firefox, encina-A2-verificada, encina-autofirma-rota
virtio-ramfb-gl   encina-limpia-respaldo, encina-snap-fabrica, y todo clon de la primera
```

Las cuatro de arriba son las máquinas viejas, donde se validó A1, A2 y el
positivo de §4.9. La línea base virgen de la que sale todo lo nuevo tenía otra
tarjeta. El diff completo de las dos configuraciones de UTM da **exactamente una
diferencia**, esa. **Un resultado visual medido en una familia no vale
automáticamente en la otra**, y eso afecta hacia atrás: el `[OMIT]` del splash de
Plymouth se midió en `encina-dev`, que es de la otra familia.

**Ese reparto es el del descubrimiento y se deja escrito tal cual, porque es el
que explica las mediciones anteriores a esta fecha.** El reparto de hoy es otro:
(b) y (g) mueven `encina-E1-meta` y `encina-limpia-respaldo` a `virtio-gpu-pci`, y
**`encina-snap-fabrica` queda como único testigo de `virtio-ramfb-gl`**. El de hoy
está en `ENCINA-OS.md` §9, que es donde se mira; este de aquí es historia.

**d) Cómo se miró la pantalla sin ojos, que sirve para el futuro.** La captura por
DBus de GNOME está prohibida (`Screenshot is not allowed`) y `org.gnome.Shell.Eval`
está capado desde GNOME 41 (devuelve `(false, '')`). Lo que **sí** funciona, para
clientes X11 bajo XWayland:

```
export DISPLAY=:0
export XAUTHORITY=$(ls -t /run/user/<uid>/.mutter-Xwaylandauth.* | head -1)
xwininfo -root -children                  # geometria y Map State
import -window <id> /tmp/x.png            # captura de esa ventana
identify -format '%k %[mean]' /tmp/x.png  # colores distintos y luminancia media
```

`XAUTHORITY` es imprescindible: sin él, `Authorization required`. Y el número de
colores es la medida: **1 color es una ventana sin pintar**, y lo distingue de una
pintada sin necesidad de mirarla. No sirve para ventanas Wayland nativas, solo
para las de XWayland — que es justo el caso de AutoFirma.

Dos detalles que costaron un intento cada uno. Hace falta una **sesión gráfica
iniciada**: `encina-E1-meta` arranca en el greeter de GDM, y ahí no hay ventana
que medir. Y AutoFirma necesita `DISPLAY` en el entorno; sin él no falla de forma
visible, sino que se degrada a modo consola y escribe su ayuda:

```
ADVERTENCIA: No se puede crear el entorno grafico. Se tratar la peticion como
             una llamada por consola
```

**e) La comprobación que sí dice qué tarjeta está activa.** Validada **antes** de
usarla, contra los dos estados conocidos: `encina-autofirma-rota`
(`virtio-gpu-pci`) y `encina-E1-meta` sin tocar (`virtio-ramfb-gl`). Cuatro
señales independientes, y las cuatro coinciden:

```
                              virtio-gpu-pci            virtio-ramfb-gl
dmesg '[drm] features:'       -virgl                    +virgl
dmesg simple-framebuffer      ausente                   presente, en 0,4 s
/proc/fb                      0 virtio_gpudrmfb         0 simpledrmdrmfb
                                                        1 virtio_gpudrmfb
/sys/class/drm/card0 ->       .../0000:00:02.0          .../simple-framebuffer.0
lspci                         Virtio 1.0 GPU (rev 01)   lo mismo, palabra por palabra
```

La más corta y la más legible es la primera:

```
sudo dmesg | grep '\[drm\] features:'
```

`+virgl` es `virtio-ramfb-gl`; `-virgl` es `virtio-gpu-pci`. La segunda señal dice
lo mismo por otra vía: `ramfb` deja **dos** framebuffers, porque expone uno
temprano de firmware (`simpledrm`, fb0) antes de que el driver virtio tome el
relevo (fb1); `gpu-pci` deja uno solo. **`lspci` se incluye a propósito, como
control negativo**: respondió idéntico en las dos máquinas, y otra vez en directo
al cambiar la tarjeta de `encina-E1-meta`. No discriminó nunca.

**f) El splash de Plymouth queda como pregunta abierta, no como respuesta.**
`SCRIPTS.md` daba por bueno que «no se puede mirar en UTM», y eso se midió en
`encina-dev`, que es de la familia `gpu-pci`; (c) dice que un resultado visual de
una familia no vale en la otra. Se buscó una medida barata desde dentro del
invitado y **no la hay**: el journal muestra `plymouth-start.service` arrancando y
`plymouthd` vivo, con `splash` en `/proc/cmdline`, exactamente igual tanto si el
anfitrión enseña el splash como si no —porque «display output is not active» lo
dice UTM, fuera del invitado—. Es otra comprobación que respondería lo mismo en
los dos casos, así que **no se escribe**. Lo único medido y pertinente: **las dos
familias tienen un dispositivo DRM listo antes de que Plymouth arranque**
(`simpledrm` a los 0,4 s con `ramfb`, `virtio_gpu` a los 0,22 s con `gpu-pci`), de
modo que nada apunta a que la tarjeta decida aquí. El experimento que lo cerraría
es del anfitrión: capturar la ventana de UTM durante el arranque.

**g) `encina-limpia-respaldo` pasa a `virtio-gpu-pci`. Propuesto y hecho el mismo
día.** De ella salen todos los clones nuevos, y era `virtio-ramfb-gl`: **cada clon
nacía con la interfaz de AutoFirma invisible**, y quien lo heredara habría vuelto
a perseguirlo. Cambiada desde la interfaz de UTM:

```
encina-limpia-respaldo   17112b5e... ramfb-gl  ->  80d291f5... gpu-pci
encina-snap-fabrica      4e1125f1... ramfb-gl  ->  4e1125f1... sin tocar
```

**La comprobación de (e) sobre esta VM está pendiente a propósito**, y no es un
descuido: arrancarla le escribe journal y es la línea base virgen. Se hará en el
próximo clon, que es donde el resultado importa, con
`sudo dmesg | grep '\[drm\] features:'` — debe decir `-virgl`. Lo que sí está
verificado es que **un cambio hecho por la interfaz de UTM llega al invitado**:
se midió en (b) sobre `encina-E1-meta`, plist y `dmesg` de acuerdo.

Razones y objeción, que se decidieron con las dos delante:

- A favor: iguala las VMs, retira una variable que ya ha estropeado dos
  mediciones, y **no toca el disco** — es configuración del emulador, no del
  sistema instalado, así que ningún resultado de paquetes o de apt cambia.
- La objeción seria: **el defecto es real y el usuario final puede tenerlo.** Si
  Encina se instala algún día sobre una máquina con una pila gráfica parecida a
  `ramfb`+virgl, AutoFirma se verá negra. Igualar las VMs **escondería ese caso**.
  Por eso el cambio fue con condición, y la condición se cumplió:
  **`encina-snap-fabrica` se queda en `virtio-ramfb-gl` como testigo de la
  familia**, y por eso **deja de ser candidata a borrar** por ahora. Sale gratis
  conservar un caso reproducible del fallo, y sin él la única prueba de que
  `ramfb-gl` rompe AutoFirma sería este texto.
- Lo que **no** hay que hacer es meter `_JAVA_OPTIONS` en ningún paquete para
  tapar esto: el remedio del laboratorio no pertenece al producto.

**h) En qué estado queda `encina-E1-meta`.** Con `virtio-gpu-pci`, cambiada en
este experimento y **no revertida** (ENCINA-OS.md §9 al día). Para medir hizo
falta una sesión gráfica, así que se activó el autologin de GDM y **se revirtió al
terminar, verificado por huella**: `/etc/gdm3/custom.conf` vuelve a
`ceee968c…10af`, la que tenía antes. AutoFirma dejó `~/.afirma`, que son sus
propios registros. **No entró ningún certificado**, y se comprobó al acabar: el
perfil `marwtfna.default-release` no lista ninguno, ni siquiera `SocketAutoFirma`
—lo que de paso vuelve a mostrar el defecto de (a)—.

---

### 4.13 LA CASILLA QUE DECIDE, MARCADA: la secuencia de tres órdenes basta (2026-08-09)

**«Fichero firmado correctamente», mirado en pantalla por Jorge**, en
`valide.redsara.es`, con certificado real de la FNMT, sobre
`encina-firma-efimera` —clon virgen de `encina-limpia-respaldo` hecho ese día—
**instalado por la secuencia de `AGENTS.md` §6.4 ejecutada tal cual, en tres
órdenes, sin `dpkg-reconfigure` y sin ningún arreglo fuera de ella**.

Es lo que §4.12 no pudo dar: allí la firma también salió, pero la secuencia no
bastaba y la casilla se dejó sin marcar a propósito. Lo que ha cambiado entre una
y otra es `autofirma 1.9.1+encina2` (enmienda de §4.12a).

**Huella de virginidad, tomada antes de tocar la VM:**

```
Ubuntu:          Ubuntu 24.04.4 LTS arm64
paquetes encina: (ninguno)
autofirma:       no se ha encontrado ningún paquete
firefox deb:     1:1snap1-0ubuntu5
snap firefox:    firefox  147.0.3-1  7764
sources.list.d:  ubuntu.sources  ubuntu.sources.curtin.orig
usuario:         uid=501(jorge) gid=1000(jorge)     <- la trampa 8, otra vez
perfiles Mozilla: los tres AUSENTES
p12/pfx en HOME: 0
[drm] features: -virgl                              <- gpu-pci, hereda la buena
```

**Los cuatro `.deb`, por huella**, y de dónde salió cada uno. Los tres de este
repositorio se bajaron de los artefactos de la ejecución `31304750876` de su
propia CI, verde sobre `2ff0c6e`; el de AutoFirma, de `salida/` de su
repositorio. **Es una diferencia con M18, que construyó `encina-meta` en la
propia VM**, y se dice en vez de callarse: se hizo así para no instalar el
entorno de construcción en una máquina que tenía que llegar virgen a la
secuencia. De dónde salgan los `.deb` no forma parte de la secuencia.

```
d5a0ebe1…  autofirma_1.9.1+encina2_all.deb
d4205134…  encina-branding_0.1.7_all.deb
3880b8aa…  encina-firefox-native_0.2.0_all.deb
e15ce56f…  encina-meta_0.1.1_all.deb
```

*Y un tropiezo que casi muerde:* el árbol copiado a la VM traía `.deb` viejos en
`debian-packages/` —`encina-branding` de 0.1.0 a 0.1.6—, y el script elige con
`ls -t | head -1`. Se limpiaron **antes** de ejecutar nada y se comprobó cuál
elegía cada uno. Un `0.1.6` instalado por descuido habría dado una medición
verde de un paquete que no era el que se quería medir.

**La secuencia: 29 correctas, 0 fallos, 1 aviso, 1 omitida.** El aviso es el del
`postinst` —no hay perfil todavía—, que es el que tiene que seguir saliendo. La
omitida es la sección 6, y dijo lo que había que decir:

```
=== 6. La CA del socket de AutoFirma, en el perfil de Firefox ===
  [OK]    El vigilante está ARMADO: cuando aparezca un perfil, la CA se instala sola
  [OMIT]  No hay ningún perfil de Firefox todavía, así que la CA no puede estar
         Basta con abrir Firefox una vez: la CA se instala sola en cuanto
         el navegador crea su almacén NSS (encina-autofirma, M16 y M18).
```

**Y el vigilante estaba armado en una sesión gráfica recién nacida**, sin que
nadie lo tocara: se activó el autologin de GDM para tener sesión sin nadie
delante, se reinició, y la unidad salió `active` y `enabled` por el camino de
`dh_installsystemduser`, no por el `postinst`.

#### La CA llega sola, y esta vez se vio el ciclo entero

```
11:11:36  se genera /usr/share/autofirma/Autofirma_ROOT.cer     (postinst, paso 1)
11:13:03  primer disparo: aparece el directorio raiz de Mozilla, sin almacen
11:14:38  segundo disparo, espera 90 s
11:16:08  «hay directorio de Mozilla pero ningun almacen NSS tras esperar 90s»
11:16:57  tercer disparo: Firefox crea el perfil de verdad
11:16:59  «CA del socket instalada en …/czmsza3t.default-release»
```

```
paquete: 30:67:39:25:23:5E:40:7C:3E:90:72:BE:C2:BB:01:96:B9:3B:15:5D:15:BD:B3:21:2E:BA:C1:D4:9A:D0:69:C1
perfil : 30:67:39:25:23:5E:40:7C:3E:90:72:BE:C2:BB:01:96:B9:3B:15:5D:15:BD:B3:21:2E:BA:C1:D4:9A:D0:69:C1
```

**Las líneas del medio son nuevas, y salen de un fallo de laboratorio que resultó
útil.** El primer intento de lanzar Firefox murió con `no DISPLAY environment
variable specified` —el entorno gráfico no está en `gnome-shell` sino en el
gestor de usuario, `systemctl --user show-environment`— pero alcanzó a crear
`~/.config/mozilla/firefox/` **sin ningún perfil dentro**. El vigilante se
disparó, esperó sus 90 s, **se rindió diciéndolo en voz alta**, y aun así volvió
a dispararse un minuto después, cuando el perfil apareció de verdad. Es
`PathChanged` rearmándose por flanco, que es lo que M15 de `encina-autofirma`
predice; aquí se ve en una máquina real, incluido el caso «se rindió y funcionó
igual». **Un mecanismo que se rinde en silencio sería otra cosa; éste lo dice.**

Y el `[OK]` no está contaminado: `grep -c "Setting up autofirma"` sobre
`term.log` sigue dando **1**.

#### La trampa de §4.2a, por tercera vez

```
Profile0  Name=default          Path=39lh7j1m.default          Default=1
Profile1  Name=default-release  Path=czmsza3t.default-release

  39lh7j1m.default          cert9=no   compat=no
  czmsza3t.default-release  cert9=si   compat=si
```

`Default=1` vuelve a caer en el perfil que Firefox no usa. El ayudante elige por
`cert9.db` y acierta; y el certificado personal, importado por Jorge desde la
interfaz de Firefox, quedó en `czmsza3t.default-release`, que es el mismo que
resolvió AutoFirma.

#### Las barreras, del log de AutoFirma

```
URI recibida: afirma://websocket?ports=…&v=4&jvc=3&idsession=…   B1a y B1b
Se inicia el modo de comunicacion por websockets                  B2 (el socket valida)
Fichero de perfiles de Firefox determinado a partir de la
    variable de entorno 'AFIRMA_NSS_PROFILES_INI'                 B4
Directorio de bibliotecas NSS: /usr/lib/aarch64-linux-gnu         B6
```

B3 la cierra el Firefox nativo, que es lo que el paso 3 instala.

#### Lo que esta medición NO contesta

**La pregunta abierta de M17 sigue abierta: si un Firefox YA ABIERTO se entera de
una CA que le meten en `cert9.db` por debajo.** Aquí no se ha probado eso: la CA
entró a las 11:16:59 con Firefox abierto, pero ese Firefox **se cerró** antes de
que nadie firmara. Cuando Jorge entró e importó su certificado, el navegador
arrancó de cero con la CA ya dentro. Quien quiera contestarla tendrá que buscarla
a propósito.

#### Estado de la VM

**`encina-firma-efimera` se destruye**, como manda §9.1: llevaba dentro el
certificado personal. El autologin se revirtió antes, y se verificó por huella
(`ceee968c…10af`, 0 líneas activas). Ni el nombre del fichero `.p12` ni el
titular aparecen en ningún sitio de este repositorio: se copió a la VM con un
nombre neutro a propósito.

---

### 4.14 E2 — La ISO oficial de escritorio SÍ honra un `autoinstall` mínimo, y a qué precio (2026-08-09, cerrada de madrugada el 10)

Medición de apertura de E2, hecha **antes de escribir una línea del seed de
verdad**, para contestar la pregunta de A3: *¿qué comando demuestra que esto es
viable?*

**Respuesta corta: sí es viable, la ISO oficial no hay que tocarla, y el precio es
una palabra en la línea de órdenes del núcleo.** Sin ella, el instalador de
escritorio lee el seed entero, lo enseña por pantalla y **se para a esperar un
clic**; con ella, instala solo y no pregunta. Las dos vías están medidas aquí, y
la segunda lleva su control.

#### (a) La pista del DIARIO era falsa, y el motivo es una trampa de método

`DIARIO.md` del 2026-08-07 dice que aquella VM «se instalo por autoinstall», y
`ENCINA-OS.md` §6 lo repetía como «antecedente a favor de E2». **No es cierto: se
instaló a mano.**

Comprobado sobre `encina-E1-vigilante`, que es clon de `encina-limpia-respaldo` y
por tanto trae sus mismos `/var/log/installer/`. Se usó el clon **para no tocar la
línea base**. Tres señales del propio instalador y una de cloud-init:

```
$ sudo grep -h "autoinstall found in cloud-config" /var/log/installer/subiquity-server-debug.log*
2026-08-06 19:10:44,625 DEBUG subiquity.server.server:872 no autoinstall found in cloud-config
2026-08-06 19:11:49,108 DEBUG subiquity.server.server:872 no autoinstall found in cloud-config

$ sudo grep -h "load_autoinstall_config" /var/log/installer/subiquity-server-debug.log*
... load_autoinstall_config only_early True file None
... load_autoinstall_config only_early False file None

$ sudo grep -h "as interactive" /var/log/installer/subiquity-server-debug.log* | head -2
... apply_autoinstall_config: skipping Locale as interactive
... apply_autoinstall_config: skipping Refresh as interactive

$ sudo grep -h "bytes from /var/lib/cloud/seed" /var/log/installer/cloud-init.log
... Reading 0 bytes from /var/lib/cloud/seed/nocloud/user-data
... Reading 0 bytes from /var/lib/cloud/seed/nocloud/meta-data
```

El único `seed` de aquella instalación era **el vacío que trae la propia ISO**.

**Y lo que engaña, que es lo que hay que llevarse de aquí:**

```
$ sudo ls -l /var/log/installer/autoinstall-user-data
-r-------- 1 root root 2489 ago  6 21:20 autoinstall-user-data
```

**Ese fichero existe en las dos.** El instalador lo escribe **siempre**, también
cuando nadie le dio ninguna configuración: es la reconstrucción de lo que se
eligió, no una copia del seed. Que esté no demuestra nada. La prueba de que es
una reconstrucción, por el otro lado, en (f); y la comprobación que **sí**
distingue, en (g).

#### (b) El montaje, y por qué se puede repetir

No se tocó ninguna VM de E1. Se crearon máquinas nuevas.

```
ISO:   ubuntu-24.04.4-desktop-arm64.iso     # cdimage.ubuntu.com/ubuntu/releases/24.04
       c2610520bf582976839a1724c669e1cfed0547427be5a0ad12d457b92b46ffbe
       verificada contra el SHA256SUMS oficial: COINCIDE
seed:  volumen FAT12 etiquetado CIDATA, 4 MiB, con user-data (976 B) y meta-data (52 B)
       f5ecde113184f470ad6f8e14840be7110f20475d624bad8cacc852dc77804a55
VM:    aarch64/virt, UEFI, 4 CPU, 8 GiB, disco nuevo de 40 GiB, virtio-gpu-pci
```

Y la ISO es exactamente la que instaló la línea base, comprobado por texto:

```
$ tar -xOf ubuntu-24.04.4-desktop-arm64.iso .disk/info      # en el Mac, bsdtar lee ISO9660
Ubuntu 24.04.4 LTS "Noble Numbat" - Release arm64 (20260210)
$ sudo cat /var/log/installer/media-info                    # en encina-E1-vigilante
Ubuntu 24.04.4 LTS "Noble Numbat" - Release arm64 (20260210)
```

El `user-data` es un `#cloud-config` con `autoinstall:`: `version`, `locale`,
`keyboard`, `source: ubuntu-desktop-minimal`, `codecs`/`drivers` a `false`,
`storage: layout: direct` con `match: size: largest`, `identity`, `ssh` con una
clave **efímera generada para esto**, y **dos `late-commands` que dejan un testigo
cada una**: la primera escribe sobre `/target/etc/` desde el entorno del
instalador, la segunda pasa por `curtin in-target`. Son dos formas distintas a
propósito.

`match: size: largest` no es adorno: el seed va en un disco de 4 MiB y sin esa
línea `layout: direct` podría elegirlo como destino.

#### (c) Qué daría un sistema sano y qué uno roto, escrito antes de mirar

- **Sano:** la VM instala sin que nadie toque nada, y se entra por `ssh` con la
  clave del seed; en su log, `autoinstall found in cloud-config`; los dos
  testigos existen con su contenido.
- **Roto:** se queda en la pantalla del instalador y el disco no crece; y si
  alguien la instalara a mano, el log diría `no autoinstall found in
  cloud-config`.

**Ese «roto» no es hipotético: es la salida literal de (a)**, medida el mismo día
sobre una máquina real. La comprobación sabía decir que no antes de que se le
preguntara que sí.

#### (d) Vía A — ISO oficial arrancada tal cual: el seed se honra, pero hay un clic

Arranque normal por el GRUB de la ISO, que es este:

```
menuentry "Try or Install Ubuntu" {
	linux	/casper/vmlinuz  --- quiet splash console=tty0
	initrd	/casper/initrd
}
```

cloud-init encuentra el seed y dice de dónde:

```
Running command ['blkid', '-tLABEL=CIDATA', '-odevice'] ...
DataSourceNoCloud.py[DEBUG]: Attempting to use data from /dev/vdb
Running command ['mount', '-o', 'ro', '-t', 'auto', '/dev/vdb', '/run/cloud-init/tmp/tmphzyiocpm']
DataSourceNoCloud.py[DEBUG]: Using data from /dev/vdb
util.py[DEBUG]: Reading 976 bytes from /run/cloud-init/tmp/tmphzyiocpm//user-data
util.py[DEBUG]: Reading 52 bytes from /run/cloud-init/tmp/tmphzyiocpm//meta-data
```

976 y 52 son **exactamente** los tamaños de los dos ficheros del seed. Y un
detalle que importa para escribir el seed de verdad: el seed vacío de la ISO se
lee **antes** (`Reading 0 bytes from /var/lib/cloud/seed/nocloud/user-data`) y aun
así gana el del volumen. Que haya un seed vacío por delante no estorba.

Subiquity dice lo contrario que en (a):

```
2026-08-09 10:08:03,704 DEBUG subiquity.server.server:866 autoinstall found in cloud-config
2026-08-09 10:08:03,776 DEBUG subiquity.server.server:704 load_autoinstall_config only_early True file /autoinstall.yaml
2026-08-09 10:08:03,779 DEBUG subiquity.server.server:704 load_autoinstall_config only_early False file /autoinstall.yaml
```

**Y entonces se para.** [OJOS] En pantalla, «Ready to install → Review your
choices», con **el YAML del seed listado entero** —`codecs: install: false`,
`identity: hostname: encina-e2 / username: encina`, `keyboard: layout: es`,
`locale: es_ES.UTF-8` y las dos `late-commands` palabra por palabra— y un botón
`Install`. **El disco se quedó en 197 248 bytes desde las `12:06` hasta que Jorge
pulsó el botón**; medido a las `12:09:03` seguía intacto, y a las `12:13:57` ya
llevaba 955 MB. *(La hora exacta del clic no se midió; lo que se midió es el
antes y el después.)*

Esto **no es un defecto del seed**: es el comportamiento documentado de esta vía.
*Citado, no medido aquí* — `canonical/ubuntu-desktop-provision`,
`docs/oem-provisioning-24_04_1.md`, líneas 287-289:

> The installer prompts for a confirmation before modifying the disk based on the
> provided `autoinstall`. To skip the need for a confirmation you can interrupt
> the booting process then add the `autoinstall` parameter to the kernel command
> line.

El montaje de esta medición coincide además con el que esa misma página describe:
la ISO como `cdrom` y el seed como segundo disco.

#### (e) Las `late-commands` se ejecutan, las dos, y con control

Sobre la máquina de la vía A, entrando con la clave del seed —`ssh` disponible a
las `12:23:28`, sin que nadie volviera a tocar la ventana tras el clic—:

```
$ hostname; lsb_release -ds; uname -m
encina-e2 / Ubuntu 24.04.4 LTS / aarch64

$ cat /etc/encina-e2-testigo-instalador
testigo-entorno-instalador 2026-08-09T10:23:00Z
$ cat /etc/encina-e2-testigo-in-target
testigo-in-target 2026-08-09T10:23:01Z uname=aarch64 id=0

# control: un testigo que no se escribio nunca
[AUSENTE] /etc/encina-e2-testigo-que-no-existe   <- la comprobacion sabe decir que no
```

Las dos formas funcionan, y la de `curtin in-target` corre **como root**
(`id=0`) y en la arquitectura de la máquina (`aarch64`, no la del constructor).

#### (f) El fichero que engaña, demostrado por el otro lado

Sobre esa misma máquina —donde **sí** hubo autoinstall y sabemos exactamente qué
se le dio— el instalador escribió su `autoinstall-user-data`:

```
$ sudo wc -c /var/log/installer/autoinstall-user-data
2636 /var/log/installer/autoinstall-user-data          # el seed son 976

$ sudo grep -E "^  [a-z-]+:" /var/log/installer/autoinstall-user-data
  active-directory:   apt:   codecs:   drivers:   identity:   kernel:
  keyboard:   locale:   network:   oem:   source:   ssh:   storage:   updates:
```

**No contiene `late-commands`**, que es lo más característico de lo que se le dio,
y sí contiene `active-directory` y `oem`, que no se le dieron. Es una
reconstrucción de las secciones interactivas. Queda cerrado (a): ese fichero no
distingue una instalación a mano de una automática, ni en un sentido ni en el
otro.

#### (g) La que SÍ distingue una cosa, y NO distingue la otra

`/var/log/installer/telemetry` guarda las pantallas por las que se pasó. Las tres
máquinas, con la misma ISO:

```
encina-E1-vigilante   (a mano):       "Stages": {"1":"locale","4":"accessibility","5":"keyboard",
                                       "7":"network","8":"autoinstall","99":"sourceSelection",
                                       "131":"codecsAndDrivers","160":"storage","179":"identity",
                                       "256":"timezone","271":"confirm","277":"install","704":"done"}

encina-E2-seed        (por seed + clic):        "Stages": {"4":"loading","896":"done"}
encina-E2-desatendida (por seed, sin clic):     "Stages": {"1":"loading","552":"done"}
```

Dos entradas contra trece: **`telemetry` sí distingue una instalación contestada a
mano de una gobernada por un seed**, y es la comprobación que `autoinstall-user-data`
no puede dar. *Sano:* dos entradas. *Roto:* aparecen `identity`, `storage`,
`confirm`…

**Y lo que NO hace, medido a propósito con la tercera máquina:** las dos
instaladas por seed dan **la misma telemetría**, con clic y sin clic. O sea que
esto **no** demuestra «nadie la ha tocado»: demuestra «nadie contestó las
pantallas». La casilla de E2 no puede apoyarse solo en esto. Se apunta porque la
tentación de usarlo como prueba de lo otro es exactamente el error de (a).

#### (h) Vía B — con `autoinstall` en la línea de órdenes: nadie toca nada

Máquina nueva, **el mismo seed byte a byte y la misma ISO**, arrancando el núcleo
y el `initrd` **de la propia ISO** (extraídos con `tar`; `casper/vmlinuz` viene
comprimido y se descomprime a un `Image` de arm64) y una sola cosa cambiada:
`-append autoinstall`.

```
00:26:00  arranca la VM
00:36:26  la VM se apaga sola  <- -no-reboot: la instalacion ha terminado
          10 min 26 s, y nadie ha tocado nada
```

Arrancada después **desde el disco, con la ISO fuera y sin el núcleo externo**:

```
$ hostname; id
encina-e2
uid=1000(encina) gid=1000(encina) grupos=1000(encina),4(adm),24(cdrom),27(sudo),...

$ cat /etc/encina-e2-testigo-instalador
testigo-entorno-instalador 2026-08-09T22:36:03Z
$ cat /etc/encina-e2-testigo-in-target
testigo-in-target 2026-08-09T22:36:04Z uname=aarch64 id=0
[AUSENTE] /etc/encina-e2-testigo-que-no-existe        <- el control, otra vez

$ sudo grep -h "autoinstall found in cloud-config" .../subiquity-server-debug.log*
2026-08-09 22:26:46,777 DEBUG subiquity.server.server:866 autoinstall found in cloud-config
```

**El `-no-reboot` no es un detalle: es lo que hace la medición legible.** El
primer intento de esta vía no lo llevaba, y **la máquina se reinstaló en bucle**:
con `-kernel`, QEMU arranca ese núcleo en **todos** los arranques, así que cada
reinicio volvía al instalador y, con `autoinstall` puesto, ni preguntaba.
Sobrevivió a tres vueltas y la última se quedó a medias, **borrando los testigos
de la buena**: dejó el sistema arrancable con el usuario y la clave del seed —eso
lo escribe `curtin` pronto— y sin `late-commands` ni logs, que van al final. Se
descartó ese resultado y se repitió entero. *(Que no era la ISO del lector se
sabe sin más medición: el GRUB de la ISO no lleva `autoinstall`, así que por ahí
se habría parado a preguntar en vez de reinstalar.)*

Es el mismo motivo por el que la orden de ejemplo de Canonical lleva
`-no-reboot`, y **es un modo de fallo real para E3**: una entrega que reinstale en
cada arranque.

#### (i) El control de (h), que es lo que lo convierte en medido

La vía B cambia dos cosas respecto de la A, no una: el parámetro **y** la forma de
arrancar. Sin cerrar eso, «lo que quita el clic» sería una deducción. Tercera
máquina, idéntica a la B **salvo el parámetro** —`-append quiet` en lugar de
`-append autoinstall`—, con el mismo núcleo, el mismo `initrd` y el mismo seed:

```
00:03:08  arranca
00:17:32  ping -c2 192.168.64.7  ->  0.0% packet loss
          consola serie          ->  "Ubuntu 24.04.4 LTS ubuntu ttyAMA0" / "ubuntu login:"
          disco                  ->  197 248 bytes
00:20:06  14 min: sistema vivo y disco intacto
```

Catorce minutos encendida, con red y con `getty`, **sin escribir un byte en el
disco de destino**; la vía B, con la misma línea de una sola palabra cambiada,
llevaba 1418 MB a los 90 segundos.

**El primer intento de este control era falso y se anula.** Consistía solo en «el
disco no crece», y dio verde porque aquella VM **no había arrancado siquiera**:

```
/init: line 38: can't open /dev/sr0: No medium found      (en bucle, por la serie)
```

Nació con el lector vacío por un fallo al crearla. «No crece» responde lo mismo
cuando el instalador espera un clic que cuando la máquina está muerta. De ahí
salen las dos señales de arriba, y la **trampa 9** de `SCRIPTS.md`.

*Lo que este control no prueba, y no se escribe como si lo probara:* que la
máquina de control esté **enseñando** la pantalla de confirmación. Sin
`console=tty0` la pantalla está negra —UTM no deja pasar varias palabras en
`-append`, las parte y QEMU protesta con `---: invalid option`—, así que puede
estar esperando ahí o puede que la interfaz no haya arrancado. Da igual para lo
que se mide, porque en los dos casos no instala, y **la vía B tenía la pantalla
igual de negra y aun así instaló entera**. Quien vio la pantalla de confirmación
fue la vía A, con la ISO arrancada tal cual.

#### (j) De propina, dos cosas que no se buscaban

**El UID del usuario depende de cómo se instale**, y eso enmienda la trampa 8:

```
encina-E1-vigilante  (a mano):     uid=501(jorge)    gid=1000(jorge)
encina-E2-seed       (por seed):   uid=1000(encina)  gid=1000(encina)
```

El 501 no es una propiedad de la imagen: es del camino. Una comprobación con
`awk '$1 >= 1000'` acierta o falla **según cómo naciera la máquina**.

**Y la base que produce el seed cumple la premisa (a) de §4.10.** Con
`source: ubuntu-desktop-minimal`:

```
$ LC_ALL=C apt-cache policy firefox
firefox:  Installed: 1:1snap1-0ubuntu5   Candidate: 1:1snap1-0ubuntu5
$ snap list | grep firefox
firefox  147.0.3-1  7764  latest/stable/…  mozilla**
$ ls /etc/apt/sources.list.d/
ubuntu.sources  ubuntu.sources.curtin.orig
```

Campo por campo, la huella de virginidad de §4.13. La vía por la que llega Firefox
nativo —sustitución del deb de transición, no instalación— **existe también sobre
una máquina instalada por seed**, que es la condición que §4.10(d) dejaba escrita.
Y el Snap está ahí, que es lo que la receta de imagen tiene que quitar (R4, D11).

#### (k) Lo que esta medición NO contesta

- **No hay ningún `.deb` de Encina en juego todavía.** Aquí solo se ha medido el
  mecanismo del instalador.
- **`-kernel`/`-append` es un truco de hipervisor, no una entrega.** Sirve para
  medir sin humano; no es cómo llegará el parámetro a una máquina de verdad, que
  es una ISO reempaquetada (E3) o una edición manual del GRUB. Cambia la frontera
  entre E2 y E3, y está escrito en §6 y §7 de `ENCINA-OS.md`.
- **No se ha medido `apt` dentro de una `late-command`.** Los dos testigos
  escriben ficheros; que `curtin in-target -- apt install` funcione con red es
  otra cosa.
- **amd64, nada.** D9 sigue igual.

---

### 4.15 El repo local sin firmar, y la casilla que E1 no podía cumplir (2026-08-10)

La casilla novena de `AGENTS.md` §6.4 —la única de las doce que quedaba— decía:
`apt purge encina-meta` **no** desinstala los otros tres, y `apt autoremove` **sí**
los propone. La primera mitad estaba medida en E1; la segunda **no se podía
demostrar allí**, porque los `.deb` entraban *por ruta* en la línea de órdenes y
apt los marcaba manuales. El 2026-08-08 se midió con un A/B que el
comportamiento correcto existía en cuanto estuvieran marcados automáticos, y se
dejó dicho que se cerraría con el repo local de E2.

**Se cierra aquí, y sin A/B: con el mecanismo de verdad.**

Sobre `encina-E2-seed` —máquina instalada por seed, virgen de paquetes de
Encina—, con los cuatro `.deb` de §4.13 (mismas huellas, comprobadas en la propia
VM) en un repositorio local **sin firmar**, generado con `dpkg-scanpackages` y
consumido con `[trusted=yes]`, que es lo decidido en `ENCINA-OS.md` §8.

```
$ sudo sh -c 'cd /srv/encina-repo && dpkg-scanpackages . /dev/null > Packages'
dpkg-scanpackages: warning: Packages in archive but missing from override file:
dpkg-scanpackages: warning:   autofirma encina-branding encina-firefox-native encina-meta
dpkg-scanpackages: info: Wrote 4 entries to output Packages file.

$ grep -E '^(Package|Version|SHA256):' /srv/encina-repo/Packages
Package: autofirma              Version: 1.9.1+encina2   SHA256: d5a0ebe1…
Package: encina-branding        Version: 0.1.7           SHA256: d4205134…
Package: encina-firefox-native  Version: 0.2.0           SHA256: 3880b8aa…
Package: encina-meta            Version: 0.1.1           SHA256: e15ce56f…
```

Las cuatro huellas son, carácter por carácter, las de §4.13.

```
$ cat /etc/apt/sources.list.d/encina-local.list
deb [trusted=yes] file:/srv/encina-repo ./

$ sudo apt-get update
Get:1 file:/srv/encina-repo ./ InRelease
Ign:1 file:/srv/encina-repo ./ InRelease      <- sin firma, y apt sigue
Get:3 file:/srv/encina-repo ./ Packages

$ LC_ALL=C apt-cache policy encina-meta
encina-meta:
  Installed: (none)
  Candidate: 0.1.1
  Version table:
     0.1.1 500
        500 file:/srv/encina-repo ./ Packages

$ LC_ALL=C apt-cache policy encina-paquete-que-no-existe
                                              # vacio: la comprobacion no esta ciega
```

**Un solo `apt install`, y entran los cuatro:**

```
$ sudo apt-get install -y encina-meta
Inst autofirma (1.9.1+encina2 localhost [all])
Inst encina-branding (0.1.7 localhost [all])
Inst encina-firefox-native (0.2.0 localhost [all])
Inst encina-meta (0.1.1 localhost [all])
...
$ dpkg-query -W -f='${Package} ${Version} ${Status}\n' encina-meta encina-branding encina-firefox-native autofirma
autofirma 1.9.1+encina2 install ok installed
encina-branding 0.1.7 install ok installed
encina-firefox-native 0.2.0 install ok installed
encina-meta 0.1.1 install ok installed
```

**Y las marcas, que son lo que decide la casilla:**

```
$ apt-mark showauto   | grep -E '^(encina-|autofirma)'
autofirma
encina-branding
encina-firefox-native
$ apt-mark showmanual | grep -E '^(encina-|autofirma)'
encina-meta
```

Con `.deb` por ruta salían los cuatro en `showmanual`. Ésa era toda la
diferencia, y no hizo falta tocar ninguna marca a mano.

**La casilla, con su control delante:**

```
--- CONTROL: con encina-meta INSTALADO, autoremove no debe proponer ninguno
$ LC_ALL=C sudo apt-get -s autoremove | grep -E '^Remv (encina|autofirma)'
                                        # ninguno: sabe decir que NO

--- mitad 1: purge encina-meta no se lleva a los otros tres
$ sudo apt-get -y purge encina-meta
Removing encina-meta (0.1.1) ...
$ dpkg-query -W -f='${Package} ${Status}\n' encina-branding encina-firefox-native autofirma
autofirma install ok installed
encina-branding install ok installed
encina-firefox-native install ok installed

--- mitad 2: LA QUE E1 NO PUDO
$ LC_ALL=C sudo apt-get -s autoremove | grep -E '^Remv (encina|autofirma)'
Remv autofirma [1.9.1+encina2]
Remv encina-branding [0.1.7]
Remv encina-firefox-native [0.2.0]
```

**Casilla novena de `AGENTS.md` §6.4 cumplida. E1 pasa a 12 de 12**, y lo que la
cerró no fue tocar `encina-meta`: fue cambiar la vía por la que llegan los otros
tres, que es justo lo que se predijo el 2026-08-08.

**Tres cosas del laboratorio, que costaron tiempo y se dicen:**

- **El repositorio NO puede vivir en el `$HOME`.** `/home/encina` es `drwxr-x---`
  y apt baja a usuario `_apt`, así que `file:$HOME/repo` no se lee y **apt no
  protesta de forma reconocible**: `apt-cache policy` sale vacío y el `install`
  no hace nada. Se mudó a `/srv/encina-repo`. En la receta de imagen esto no
  aparece —el repo irá en un sitio del sistema—, pero el modo de fallo silencioso
  sí importa.
- **`dpkg-dev` se instaló para generar el índice y se purgó antes de medir**, para
  no medir con el entorno de construcción dentro (`command -v dpkg-scanpackages`
  → `AUSENTE` antes del `apt install encina-meta`). En E2 de verdad el índice se
  genera en la construcción, no en la máquina.
- **Un `sudo -S` con la contraseña por tubería se come el `stdin` del comando.**
  `echo "linea" | sudo -S tee fichero` escribe **la contraseña** en el fichero, no
  la línea, y no falla: dejó `encina-local.list` vacío y costó una vuelta
  entenderlo. Es de la familia de la trampa 1.

---

### 4.16 E2 — Ninguna clave del seed quita el clic (leído), y el Snap SÍ se quita desde el seed (medido) (2026-08-10)

Dos preguntas en un día. La primera se contestó **leyendo**, sin gastar ni una
máquina, porque el código del instalador viaja dentro de la ISO que ya estaba
bajada. La segunda es la casilla «Sin Snap» de `AGENTS.md` §6bis.3, que R4 y D11
llevaban aplazando desde el principio con un «eso se hace en la receta de
imagen» que nadie había medido.

**Respuestas cortas.** *(1)* **No existe** ninguna clave de `autoinstall.yaml`
que quite el clic de confirmación: la puerta está en la línea de órdenes del
núcleo y en ningún otro sitio. *(2)* **Sí se puede** quitar el Snap desde el
seed, pero **no por la vía obvia**, que además no falla, sino que dice que sí
mientras se lo quita a otra máquina.

#### (a) Lo primero, y salió gratis: no hay ninguna clave que quite el clic

`tar` de macOS lee ISO9660 sin montar nada, y el instalador de escritorio de
24.04 **es un snap** que viaja en la capa viva:

```
$ tar -xOf ubuntu-24.04.4-desktop-arm64.iso casper/filesystem.manifest | grep bootstrap
snap:ubuntu-desktop-bootstrap	24.04/stable/ubuntu-24.04.4	495
```

Ese snap está dentro de `casper/minimal.standard.live.squashfs`, en
`/var/lib/snapd/snaps/ubuntu-desktop-bootstrap_495.snap`, y **lleva dentro el
código fuente entero de subiquity en Python**, no compilado:

```
$ cat meta/snap.yaml | head -3
name: ubuntu-desktop-bootstrap
version: 0+git.4bc1f4077
summary: Ubuntu Desktop Bootstrap
$ ls bin/subiquity/ | head
autoinstall-schema.json  subiquity/  subiquitycore/  system_setup/  ...
```

**El esquema que trae ESTA ISO**, primer nivel completo, y no hay ninguna clave
de confirmación:

```
active-directory, apt, codecs, debconf-selections, drivers, early-commands,
error-commands, identity, interactive-sections, kernel, keyboard, late-commands,
locale, network, oem, packages, proxy, refresh-installer, reporting, shutdown,
snaps, source, ssh, storage, timezone, ubuntu-advantage, ubuntu-pro, updates,
user-data, version
```

**Y la puerta, literal**, en `subiquity/server/controllers/install.py:587-597`:

```python
                self.app.update_state(ApplicationState.WAITING)
                await self.model.wait_install()

                if not self.app.interactive:
                    if "autoinstall" in self.app.kernel_cmdline:
                        await self.model.confirm()

                self.app.update_state(ApplicationState.NEEDS_CONFIRMATION)

                if await self.model.wait_confirmation():
                    break
```

Tres cosas se leen ahí, y las tres importan:

1. `self.app.interactive` **ya es falso** con nuestro seed: sale de
   `server.py:729`, `self.interactive = bool(self.autoinstall_config.get("interactive-sections"))`,
   y el seed no lleva esa clave. O sea que **no interactivo no basta**: el
   instalador de escritorio se para igual.
2. Lo único que le hace confirmarse a sí mismo es **`"autoinstall" in
   self.app.kernel_cmdline`**, y `kernel_cmdline` se construye leyendo
   `/proc/cmdline` (`subiquity/cmd/server.py:88`). Ninguna clave del YAML puede
   tocar eso.
3. `model.confirm()` se llama **solo desde dos sitios** en todo el árbol: esa
   línea, y el manejador HTTP `confirm_POST` de `server.py:103-105`, que es lo
   que pulsa el botón.

**Y un detalle que decide cómo se escribe esa palabra**, leído del analizador,
`subiquity/cmd/server.py:32-52`:

```python
        for tok in shlex.split(cmdline):
            if "=" in tok:
                k, v = tok.split("=", 1)
                r._values[k] = v
            else:
                r._tokens.add(tok)
    ...
    def __contains__(self, item):
        return item in self._tokens
```

`in` mira **solo los testigos sin `=`**. Luego la palabra tiene que ir **suelta**:
`autoinstall` sí, y **`autoinstall=1` NO**, ni tampoco
`subiquity.autoinstallpath=/loquesea`, que va a `_values` y sirve para *dónde*
está el seed, no para saltarse el clic. Quien escriba el `grub.cfg` de E3 se
juega la casilla en ese carácter.

**Conclusión: la salida (1) de `ENCINA-OS.md` §10 no se puede evitar por seed.**
No es que no se haya encontrado la clave: es que la decisión está tomada en el
código y se ha leído. *(La elección entre las tres salidas se tomó ese mismo día,
delegada por Jorge: **es la (1), el hipervisor**, con su motivo escrito en
`ENCINA-OS.md` §10.)*

*Una pista que esto abre y que NO se ha medido, escrita para que no se pierda:*
`confirm_POST` es un manejador HTTP sobre el zócalo del servidor de subiquity, y
las `early-commands` del propio seed corren como root en el entorno del
instalador **antes** de que se llegue a esa espera. Si una `early-command`
pudiera hablar con ese zócalo, habría una cuarta salida que no necesita ni
hipervisor ni reempaquetar la ISO. **No está medido, no está probado y no se
recomienda**; se apunta porque salió de la lectura y porque, si algún día se
mide, cambia §10.

#### (b) Qué se daría por sano y qué por roto, escrito antes de medir

| # | Lo que se prueba | Sano | Roto |
|---|---|---|---|
| P1 | `curtin in-target -- snap remove --purge firefox` | — | **se predijo que falla**: `curtin` bind-monta `/run` del instalador dentro de `/target` (leído en `curtin/util.py:775`), así que el cliente `snap` de dentro del chroot habla con el snapd del entorno **vivo**. Señal que lo distingue: inventario de `/target` antes y después, tomado **sin** chroot |
| P2 | `curtin in-target -- apt-get -y purge snapd` | rc=0 y en `/target` desaparecen el `.snap`, el lanzador, las unidades `snap-*.mount` y `/snap`; `ubuntu-desktop-minimal` sobrevive | rc≠0, o rc=0 y quedan ficheros porque el `postrm` no pudo desmontar sin systemd |
| P3 | La máquina resultante | arranca, sin orden `snap`, sin lanzador, y con sesión gráfica | no arranca, o arranca sin escritorio |

Que `ubuntu-desktop-minimal` sobreviviera no era suposición: se midió antes, en
`encina-E2-seed`, **sin modificar nada**, y con su control:

```
$ LC_ALL=C sudo apt-get -s purge snapd | grep -E "^(Purg|Remv)"
Purg firefox [1:1snap1-0ubuntu5]
Purg snapd [2.76+ubuntu24.04.1]
$ LC_ALL=C dpkg-query -W -f='Depends: ${Depends}\nRecommends: ${Recommends}\n' ubuntu-desktop-minimal | tr ',' '\n' | grep -nE '^(Depends|Recommends):| firefox| snapd'
1:Depends: alsa-base
56:Recommends: apport-gtk
72: firefox
138: snapd
$ LC_ALL=C sudo apt-get -s purge paquete-que-no-existe | tail -1
E: Unable to locate package paquete-que-no-existe     <- la simulacion no esta ciega
```

`snapd` y `firefox` son **`Recommends`**, no `Depends`, y por eso apt no se lleva
el escritorio por delante.

#### (c) El montaje, y qué máquina se ha gastado

Se ha reutilizado `encina-E2-control` —la del control de §4.14i, que el encargo
marcaba como candidata a borrar—, y **queda renombrada `encina-E2-sinsnap`**. O
sea que **el control de §4.14i ya no existe como máquina**; lo que queda de él
es lo escrito allí. `encina-E2-desatendida` no se ha tocado.

El seed de la medición es el mínimo de §4.14 **con dos cambios y ni uno más**:

```
$ diff user-data-minimo.yaml user-data-medicion-snap.yaml
22c22
<     hostname: encina-e2
---
>     hostname: encina-e2-sinsnap
31a32
>     - sh -c 'echo IyEvYmluL3NoCiMgTWVkaWNpb24gRTIgKDIwMjYtMDgtMTApOiBzZSBw… | base64 -d > /tmp/medicion-snap.sh; sh /tmp/medicion-snap.sh; true'
```

El guion va en base64 en una sola `late-command` a propósito: así no hay ni una
comilla que YAML o el intérprete puedan interpretar de otra manera, y el guion se
conserva legible aparte (`e2-medios/medicion-snap.sh`). Termina siempre en 0,
porque una `late-command` que aborta se lleva la instalación por delante y deja
la medición sin datos.

```
seed:  seed-cidata-snap.img   FAT12 etiquetado CIDATA, 8 MiB
       user-data 6032 B, meta-data 63 B
       sha256 3fcddd266a4c3c54b15f0390f8f8f7763bdcffeea99387393ceabe96d83824ef
ISO:   c2610520bf582976839a1724c669e1cfed0547427be5a0ad12d457b92b46ffbe   <- la de §4.14, identica
Image: a1586ff3cb7ced7c40dcb0aba5bf320ebb94a46d1a6505eb03157a8f9525632d
initrd:948d5f0449382571eceb32fbbcd5652dff2f9359e69e5f5ec10432b098776b28
```

La instalación fue **desatendida**, por la vía B de §4.14h (`-append autoinstall`,
`-no-reboot`), y nadie tocó nada:

```
10:00:00Z  arranca
10:01:32Z  disco = 2 190 999 552 bytes (2089 MB)   <- instalando de verdad
           arp -an -> 192.168.64.7 viva            <- segunda senal (trampa 9)
10:08:32Z  se apaga sola                            8 min 32 s, disco 9667 MB
```

Anclaje con §4.14, del propio log del instalador:

```
2026-08-10 10:00:45,756 DEBUG subiquity.server.server:866 autoinstall found in cloud-config
```

#### (d) Cómo llega el Snap al sistema instalado, leído del medio — y no es lo que se suponía

El encargo apuntaba a «atacar el seed de snapd (`/var/lib/snapd/seed/`) para que
el Snap no llegue a instalarse en el primer arranque». **Leyendo
`casper/minimal.squashfs`, que es literalmente el sistema que se copia al disco,
eso no basta**: la imagen no viene *sembrada*, viene **pre-sembrada**.

```
$ python3 -c "…json.load(open('var/lib/snapd/state.json'))…"
preseeded: True
seeded: None
snaps: ['bare','core22','firefox','gnome-42-2204','gtk-common-themes','snap-store','snapd','snapd-desktop-integration']
cambios: [('1', 'seed', 'Initialize system state', 0)]      <- estado 0 = pendiente
nº tareas: 178      tareas que mencionan firefox: 49
```

Y los artefactos del pre-sembrado ya están puestos en la imagen: los `.snap` en
`/var/lib/snapd/snaps/`, los perfiles de AppArmor, `/snap/firefox/7764`, las
unidades `snap-firefox-7764.mount` **ya habilitadas**, y el lanzador
`/var/lib/snapd/desktop/applications/firefox_firefox.desktop`. Borrar el seed a
mano dejaría `state.json` con 49 tareas apuntando a un snap que ya no está.

#### (e) La vía obvia no falla: dice que sí, y se lo quita a otra máquina

```
$ curtin in-target -- snap remove --purge firefox
firefox eliminado
  rc=0
```

**rc=0 y «firefox eliminado».** Y el objetivo, intacto:

```
=== 3. INVENTARIO DEL OBJETIVO, DESPUES DE LA VIA OBVIA ===
[PRESENTE] /target/var/lib/snapd/snaps/firefox_7764.snap
[PRESENTE] /target/var/lib/snapd/seed/snaps/firefox_7764.snap
[PRESENTE] /target/var/lib/snapd/desktop/applications/firefox_firefox.desktop
[PRESENTE] /target/snap/firefox/current
[AUSENTE ] /target/var/lib/snapd/snaps/fichero-que-no-existe-jamas  <- control
```

**La prueba de a quién se lo quitó**, y es de las que no admiten discusión:

```
$ curtin in-target -- snap version
snap          2.76+ubuntu24.04.1        <- el cliente, del OBJETIVO
snapd         2.73+ubuntu24.04          <- el demonio, del entorno VIVO
$ curtin in-target -- ls -l /run/snapd.socket
srw-rw-rw- 1 root root 0 Aug 10 10:00 /run/snapd.socket
```

Dos versiones distintas en la misma orden: el binario sale del chroot y el
demonio del instalador, porque `curtin` bind-monta `/run`. Y en el `snap list`
de después —que es el del entorno vivo, aunque se pida con `in-target`— firefox
ya no está, mientras `thunderbird` y `ubuntu-desktop-bootstrap` siguen.

**Una corrección mía, y va escrita porque casi se me cuela.** Antes de medir
afirmé, leyendo el `.squashfs` de la capa viva, que el entorno del instalador
«solo tiene un snap, el instalador». **Es falso**: casper apila varias capas, y
el entorno vivo trae los ocho más `thunderbird` y el propio instalador:

```
$ ls -l /var/lib/snapd/snaps/          # en el entorno del instalador, medido
firefox_7764.snap  thunderbird_958.snap  ubuntu-desktop-bootstrap_495.snap  …
```

Lo que estaba mal no era la conclusión —la vía obvia no sirve— sino el motivo que
yo le había puesto. Si el entorno vivo no hubiera tenido firefox, la orden habría
dicho «no está instalado» y el error habría sido igual de invisible.

**Moraleja, que es la que hay que llevarse:** una `late-command` que dice `rc=0`
no demuestra nada sobre el objetivo. Lo único que lo demuestra es mirar
`/target` desde fuera del chroot, antes y después.

#### (f) Y de ahí salió una trampa nueva, que estuvo a punto de contar un cambio falso

En el inventario del paso 3, **una línea sí cambió**:

```
[AUSENTE ] /target/etc/systemd/system/multi-user.target.wants/snap-firefox-7764.mount
```

Parecía que `snap remove` sí había tocado el objetivo. **No lo tocó.** El fichero
es un enlace **absoluto**, leído del propio `minimal.squashfs`:

```
lrwxrwxrwx  .../multi-user.target.wants/snap-firefox-7764.mount -> /etc/systemd/system/snap-firefox-7764.mount
-rw-r--r--  .../etc/systemd/system/snap-firefox-7764.mount   329 bytes
```

Un `[ -e /target/…/enlace ]` ejecutado **en el entorno del instalador** resuelve
ese `/etc/...` contra la raíz **del instalador**, no contra `/target`. Y el
`snap remove` acababa de borrar ahí ese fichero. O sea: el enlace del objetivo
seguía en su sitio, y la comprobación dijo AUSENTE. Es la **trampa 10** de
`SCRIPTS.md`.

#### (g) La vía por paquete: funciona, y del todo

```
$ curtin in-target -- env DEBIAN_FRONTEND=noninteractive LC_ALL=C apt-get -y purge snapd
The following packages will be REMOVED:
  firefox* snapd*
0 upgraded, 0 newly installed, 2 to remove and 88 not upgraded.
E: Can not write log (Is /dev/pts mounted?) - posix_openpt (19: No such device)
Removing firefox (1:1snap1-0ubuntu5) ...
Removing snapd (2.76+ubuntu24.04.1) ...
/usr/sbin/policy-rc.d returned 101, not running 'stop snapd.apparmor.service …'
/usr/sbin/policy-rc.d returned 101, not running 'stop snapd.service'
Running in chroot, ignoring command 'daemon-reload'
Purging configuration files for snapd (2.76+ubuntu24.04.1) ...
Running in chroot, ignoring command 'stop'
Waiting until unit snap-bare-5.mount is stopped [attempt 1] … [attempt 20]
Removing snap bare and revision 5
…
  rc=0
```

**Sin systemd vivo, `snap-mgmt` no puede parar ni desmontar nada** —lo dice él
mismo, veinte intentos por unidad— **y aun así termina el trabajo**, porque en el
objetivo esas unidades nunca llegaron a arrancar: no hay nada montado que
desmontar. El `E: Can not write log` es del `apt` sin `/dev/pts` y no impide
nada. Y el inventario de después:

```
=== 5. INVENTARIO DEL OBJETIVO, DESPUES DEL PURGADO ===
[AUSENTE ] /target/var/lib/snapd/snaps/firefox_7764.snap
[AUSENTE ] /target/var/lib/snapd/seed/snaps/firefox_7764.snap
[AUSENTE ] /target/var/lib/snapd/desktop/applications/firefox_firefox.desktop
[AUSENTE ] /target/etc/systemd/system/snap-firefox-7764.mount
[AUSENTE ] /target/snap/firefox/current
[AUSENTE ] /target/var/lib/snapd/state.json
[AUSENTE ] /target/usr/bin/firefox

$ ls -la /target/var/lib/snapd   -> No such file or directory   rc=2
$ ls -la /target/snap            -> No such file or directory   rc=2
$ ls /target/etc/systemd/system/ | grep -i snap   -> (vacio)     rc=1

$ curtin in-target -- dpkg -l snapd firefox
un  firefox        <none>   <none>
un  snapd          <none>   <none>
$ curtin in-target -- dpkg -l ubuntu-desktop-minimal gnome-shell
ii  gnome-shell            46.0-0ubuntu6~24.04.13  arm64
ii  ubuntu-desktop-minimal 1.539.2                 arm64
```

El mismo inventario dio nueve `[PRESENTE]` antes de tocar nada y un `[AUSENTE]`
en su control, así que sabe decir las dos cosas.

#### (h) La máquina que sale, verificada con sus controles

Sobre `encina-E2-sinsnap` arrancada **desde el disco**, con la ISO fuera y sin
núcleo externo:

```
$ hostname; id
encina-e2-sinsnap
uid=1000(encina) gid=1000(encina) grupos=1000(encina),4(adm),24(cdrom),27(sudo),…

$ command -v snap  ->  AUSENTE: no hay orden snap
  control: command -v bash -> PRESENTE /usr/bin/bash

[AUSENTE ] /var/lib/snapd/desktop/applications/firefox_firefox.desktop
[AUSENTE ] /var/lib/snapd/desktop
[AUSENTE ] /var/lib/snapd
[AUSENTE ] /snap
[AUSENTE ] /usr/bin/firefox
  control: [PRESENTE] /usr/bin/gnome-shell

$ ls /etc/systemd/system/ | grep -i snap   -> ninguna

$ sudo cat /var/log/installer/telemetry
{"1": "loading", "409": "done"}          <- dos entradas: la goberno un seed

$ systemctl is-system-running   -> running
$ systemctl list-units --state=failed --no-legend  -> (ninguna)
```

**Y el escritorio está vivo de verdad, no solo «gdm active»:**

```
$ loginctl list-sessions --no-legend
 5   1000 encina -     -    active
c1    120 gdm    seat0 tty1 active
$ loginctl show-session c1 -p User -p Name -p Type -p Class -p State -p Seat
User=120 Name=gdm Seat=seat0 Type=wayland Class=greeter State=active
$ systemctl is-active graphical.target   -> active
$ systemctl is-active rescue.target      -> inactive     <- el control
```

**Lo que NO he mirado en pantalla:** la captura que UTM guarda es la del final de
la instalación —el instalador en «Copiando archivos…», sin haber pasado por
ninguna pantalla de confirmación, que ya es un dato— y la de después del apagado
dice «Display output is not active». El saludador de GDM está demostrado por
`loginctl`, no por una foto.

**Un aviso para quien escriba la comprobación de la casilla:** `dpkg -l | grep -i
snap` **da falsa alarma** en esta máquina, y es de la familia de la trampa 5:

```
ii  gir1.2-snapd-2:arm64      Typelib file for libsnapd-glib1
ii  libsnapd-glib-2-1:arm64   GLib snapd library
ii  gnome-shell-extension-ubuntu-tiling-assistant   … adds a Windows-like snap assist to GNOME Shell
ii  xdg-desktop-portal        desktop integration portal for Flatpak and Snap
```

Ninguno es snapd: dos son bibliotecas, uno es una extensión de ventanas y el
cuarto es un portal. `snapd` **no** está (`un`, ver (g)). Lo mismo con
`systemctl list-units | grep -i snap`, que casa con `e2scrub_reap.service`
—«Remove Stale Online ext4 Metadata Check **Snap**shots»— y con nada más.

#### (i) El defecto de `resolver_desktop`, que esta casilla sacó a la luz

La casilla «Sin Snap» dice que hay que mirar la **precedencia real** del
lanzador, no solo si el fichero está (trampa 4, y el caso A2 donde las siete
comprobaciones estaban verdes y el icono seguía abriendo el Snap). `lib.sh`
tiene `resolver_desktop` para eso, y **estaba roto de una forma que esta casilla
no habría detectado**:

```
$ python3 -c 'import gi; gi.require_version("Gio","2.0"); from gi.repository import Gio; \
              a=Gio.DesktopAppInfo.new("firefox_firefox.desktop"); print(a or "NINGUNA")'
Traceback (most recent call last):
  File "<stdin>", line 4, in <module>
TypeError: constructor returned NULL
   rc=1
```

`g_desktop_app_info_new()` devuelve NULL cuando el identificador no resuelve, y
**PyGObject convierte ese NULL en una excepción**, no en un `None`. Con el
`|| echo "?"` que tenía la función, el resultado era `?` —«no se ha podido
averiguar»— y **`NINGUNA` no se podía imprimir jamás**. O sea: «el lanzador del
Snap ya no está» y «no lo sé» daban la misma respuesta, que es exactamente el
modo de fallo de las trampas 5 y 8.

Arreglado en `scripts/lib.sh` con un `except TypeError`, y **las tres salidas
medidas** sobre esta máquina, con el `XDG_DATA_DIRS` por defecto, que es el
**más favorable al Snap** porque incluye `/var/lib/snapd/desktop`:

```
1) el que no resuelve : firefox_firefox.desktop    -> NINGUNA
2) el que si resuelve : org.gnome.Nautilus.desktop -> nautilus --new-window %U
3) el que no se sabe  : sin interprete             -> ?
```

*Lo que esta medición no da:* el `XDG_DATA_DIRS` de una sesión gráfica **de
usuario** abierta, porque esta máquina no tiene autologin y nadie ha entrado. La
lista usada es la de por defecto, que contiene el directorio del Snap, así que un
`NINGUNA` ahí es más fuerte, no más débil.

#### (j) Lo que esto le cuesta a la premisa (a) de §4.10, y hay que decidirlo al escribir el seed

El `.deb` `firefox` de transición **depende de `snapd`**, así que el purgado se lo
lleva:

```
$ curtin in-target -- env LC_ALL=C apt-cache policy firefox
firefox:
  Installed: (none)
  Candidate: 1:1snap1-0ubuntu5
     1:1snap1-0ubuntu5 500  http://ports.ubuntu.com/ubuntu-ports noble/main
```

La premisa (a) de §4.10 decía que Firefox nativo llega **por sustitución** del
deb de transición, no por instalación. **En una máquina así ya no hay nada que
sustituir.** No es un problema —probablemente sea más simple, porque el anclaje
de `encina-firefox-native` se encuentra el nombre libre— pero **es una premisa de
§4.10 que deja de valer, y no se ha medido qué pasa en su lugar**. Es la primera
cosa que hay que comprobar al escribir el seed completo.

#### (k) Notas de laboratorio, que costaron más que la medición

- **`-kernel` en UTM solo funciona con ficheros declarados como *unidad*.** Cinco
  intentos fallaron con `qemu-aarch64-softmmu: failed to load ".../Image"` con el
  fichero presente, válido (`ARMd` en el desplazamiento 0x38) y dentro del
  contenedor de UTM. Lo que lo aclaró fue un experimento discriminante: apuntar
  `-kernel` a un fichero que **sí** es unidad (`seed-cidata-snap.img`) — y la VM
  arrancó. UTM está en la caja de arena de la App Store y solo le concede a QEMU
  el acceso a los ficheros de las unidades. **La solución es declarar `Image` e
  `initrd` como unidades `CD` de solo lectura** y dejar los argumentos apuntando
  a esas mismas rutas. *(La primera hipótesis —que el renombrado del bundle había
  invalidado un marcador— era falsa: revertir el nombre no arregló nada. Se dice
  porque se perdió tiempo ahí.)*
- **El campo `file urls` del registro `qemu argument` de AppleScript no basta**, y
  además `update configuration` **borra del bundle todo lo que no sea unidad**,
  incluso lo que acabas de referenciar. La trampa de §4.14 sigue vigente y ahora
  se entiende mejor: no es «primero argumentos y luego ficheros», es «los
  ficheros tienen que ser unidades».
- **Un experimento discriminante mal elegido miente.** El primero fue apuntar
  `-kernel` a la ISO —que sí es unidad— y dio el mismo error; parecía cerrar la
  hipótesis de acceso, y no la cerraba: son 3,5 GB y `-kernel` lee el fichero
  entero en memoria. Se repitió con un fichero de 8 MB y salió lo contrario.
- **En `encina-E2-sinsnap` no hay `sudo` sin contraseña**, al revés que en
  `encina-E2-seed`, donde se puso a mano en §4.15. El seed mínimo no lo
  configura. La contraseña desechable es la de siempre.

#### (l) Lo que esta medición NO contesta

- **No se ha escrito el seed de verdad.** Aquí solo se ha medido el mecanismo de
  quitar el Snap, con un seed que no trae ningún `.deb` de Encina.
- **No se ha probado la vía estrecha**: quitar *solo* el snap de Firefox dejando
  snapd y los otros siete. El camino leído sería `snap-preseed --reset` sobre
  `/target` más cirugía en `seed.yaml`, y **no se ha medido**. Lo medido purga
  snapd entero, que cumple la casilla con holgura pero **también se lleva
  `snap-store` y `snapd-desktop-integration`**, y eso es una decisión de producto
  que no se toma aquí.
- **No se ha medido `apt` contra la red desde una `late-command`.** El purgado no
  necesita red; el repo local y `encina-meta` son otra cosa.
- **La firma en `valide.redsara.es` sigue sin hacerse**, y sigue siendo [OJOS].
- **amd64, nada.** D9 sigue igual.

---

### 4.17 Por qué vía llega Firefox nativo cuando no hay deb de transición (2026-08-10)

La medición del Snap (§4.16j) dejó la premisa (a) de §4.10 sin efecto en una
máquina sin Snap: al purgar `snapd` se va también el `.deb` `firefox` de
transición, así que **el nombre `firefox` queda libre y no hay nada que
sustituir**. Esto lo mide, porque de ello cuelga la secuencia de §6.4 entera.

**Respuesta corta: la secuencia de tres órdenes sigue valiendo tal cual, pero
cambia de manos.** El paso 3 —`full-upgrade`— deja de traer Firefox, y lo trae el
paso 4, el que estaba escrito «para el idioma». **Y de propina sale un defecto
visible que no es de E2 sino de E1, y que nadie había medido: el usuario ve dos
iconos de Firefox.**

#### (a) Qué se daría por sano y qué por roto, escrito antes de medir

| Resultado | Qué se vería |
|---|---|
| **Sano A** (el previsto) | `full-upgrade` **no propone Firefox** y `apt install firefox-l10n-es-es` **arrastra `firefox` de `packages.mozilla.org`**: versión **sin epoch** y `/usr/bin/firefox` fuera de `/snap/` |
| **Roto** | ni el paso 3 ni el 4 traen Firefox: la máquina se queda **sin navegador**, y §6.4 necesita una orden más |
| **Roto y silencioso, el peor** | llega el `1:1snap1-0ubuntu5` de `ports` —el deb de transición— que sin `snapd` no puede instalar ningún Snap. El anclaje debería impedirlo, y hay que verificarlo con `apt-cache policy` **tras** el `apt update` |

#### (b) El banco, y una trampa antes de empezar

`encina-E2-firefox`, **clon de `encina-E2-sinsnap`** hecho con `duplicate` de
UTM, para no gastar la línea base sin Snap. Huella tomada antes de tocarlo:

```
$ dpkg-query -W encina-meta encina-branding encina-firefox-native autofirma
   (los cuatro: «no se ha encontrado ningún paquete»)
$ ls /etc/apt/sources.list.d/     ->  ubuntu.sources  ubuntu.sources.curtin.orig
$ LC_ALL=C apt-cache policy firefox
firefox:  Installed: (none)   Candidate: 1:1snap1-0ubuntu5
     1:1snap1-0ubuntu5 500  http://ports.ubuntu.com/ubuntu-ports noble/main
$ command -v snap   -> NO          $ ls -d ~/.mozilla  -> ninguno
$ cat /etc/encina-e2-testigo-medicion-snap
medicion-snap llego al final 2026-08-10T10:08:19Z     <- es clon de la buena
$ telemetry  ->  {"1": "loading", "409": "done"}
```

**Y la trampa, que es la de §4.13 otra vez y casi muerde:** los `.deb` que hay en
`debian-packages/` **de este repositorio** tienen la misma versión que los
medidos y **no son los mismos bytes**:

```
en el arbol:   0e870833…  encina-branding_0.1.7_all.deb
en §4.15:      d4205134…  encina-branding_0.1.7_all.deb
en el arbol:   c2de429a…  encina-firefox-native_0.2.0_all.deb
en §4.15:      3880b8aa…  encina-firefox-native_0.2.0_all.deb
```

Se descartaron y se usó el juego de `/srv/encina-repo` de `encina-E2-seed`, cuyas
cuatro huellas coinciden con §4.15 carácter por carácter, **comprobadas otra vez
ya dentro de la VM de destino**.

#### (c) Paso 1, en la forma de E2: el repo local, sobre una máquina sin Snap

No se usó la forma de §6.4 —los cuatro `.deb` por ruta—, sino la que va a usar el
seed: repo local sin firmar y **un solo nombre**.

```
$ sudo apt-get update
Get:1 file:/srv/encina-repo ./ InRelease     Ign:1 …      <- sin firma, y sigue
$ LC_ALL=C apt-cache policy encina-meta
   Candidate: 0.1.1        500 file:/srv/encina-repo ./ Packages
$ LC_ALL=C apt-cache policy encina-que-no-existe
                                              # vacio: no esta ciego

$ sudo apt-get install -y encina-meta
$ dpkg-query -W …
autofirma 1.9.1+encina2 install ok installed
encina-branding 0.1.7 install ok installed
encina-firefox-native 0.2.0 install ok installed
encina-meta 0.1.1 install ok installed
$ apt-mark showauto   -> autofirma, encina-branding, encina-firefox-native
$ apt-mark showmanual -> encina-meta
```

**§4.15 se reproduce igual en una máquina sin Snap**, sin tocar ninguna marca. Y
el `postinst` de AutoFirma se comporta como debe, sin perfil de Mozilla todavía:

```
WARNING: A Mozilla Firefox profile to install the certificate was not detected
autofirma: Queda vigilando: al abrir Firefox por primera vez la CA se
autofirma:        instalará sola (2 sesión/es de usuario avisadas).
autofirma: CA instalada en el almacén del sistema.
```

#### (d) La respuesta: el anclaje funciona igual con el nombre libre

Tras el paso 2 (`apt update`, ya con el repositorio de Mozilla que puso
`encina-firefox-native`):

```
$ cat /etc/apt/preferences.d/*     (efectivo)
Package: *   Pin: origin packages.mozilla.org   Pin-Priority: 1000

$ LC_ALL=C apt-cache policy firefox
firefox:
  Installed: (none)
  Candidate: 153.0.3~build1                     <- el de Mozilla, NO el 1:1snap1
  Version table:
     1:1snap1-0ubuntu5 500
        500 http://ports.ubuntu.com/ubuntu-ports noble/main arm64 Packages
     153.0.3~build1 1000
       1000 https://packages.mozilla.org/apt mozilla/main arm64 Packages
```

**El caso «roto y silencioso» queda descartado**: el candidato es el de Mozilla
aunque no haya nada instalado que sustituir. El anclaje no dependía de la
sustitución, dependía de la prioridad.

#### (e) El paso 3 deja de hacer su trabajo, y hay que saberlo

```
$ LC_ALL=C sudo apt-get -s full-upgrade | grep -i firefox
   (nada)
$ LC_ALL=C sudo apt-get -s full-upgrade | grep -c "^Inst"
84                                     <- el control: propone 84 cosas, no esta mudo
$ sudo apt-get -y full-upgrade
   …
$ LC_ALL=C apt-cache policy firefox    ->  Installed: (none)
```

84 paquetes propuestos y **ni uno es Firefox**. En una máquina con Snap el paso 3
era **el** paso, el que cambiaba el deb de transición por el de Mozilla. Aquí no
hace nada para Firefox, y es correcto: no hay nada instalado que actualizar.

#### (f) Lo hace el paso 4, y el mecanismo está en el índice

```
$ LC_ALL=C apt-cache show firefox-l10n-es-es | grep -E "^(Version|Depends):"
Version: 153.0.3~build1
Depends: firefox (= 153.0.3~build1)          <- version exacta
```

Así que:

```
$ sudo apt-get install -y firefox-l10n-es-es
The following NEW packages will be installed:
  firefox firefox-l10n-es-es
Setting up firefox (153.0.3~build1) ...
Setting up firefox-l10n-es-es (153.0.3~build1) ...

$ dpkg-query -W firefox firefox-l10n-es-es
firefox 153.0.3~build1                       <- SIN epoch: es el de Mozilla
firefox-l10n-es-es 153.0.3~build1
$ ls -l /usr/bin/firefox
lrwxrwxrwx … /usr/bin/firefox -> ../lib/firefox/firefox      <- fuera de /snap/
$ dpkg -S /usr/bin/firefox      -> firefox: /usr/bin/firefox
  control: dpkg -S /usr/bin/gnome-shell -> gnome-shell: /usr/bin/gnome-shell
$ dpkg -L firefox-l10n-es-es | grep xpi
/usr/lib/firefox/distribution/extensions/langpack-es-ES@firefox.mozilla.org.xpi
```

**Y la precedencia real de lanzadores, con el `resolver_desktop` ya arreglado**
(§4.16i), y con el `XDG_DATA_DIRS` que incluye el directorio del Snap:

```
firefox_firefox.desktop      -> /usr/bin/firefox %u
firefox.desktop              -> firefox %u
org.mozilla.firefox.desktop  -> NINGUNA          <- el control, y ya sabe decirlo
```

#### (g) Conclusión, y el aviso que hay que escribir en §6.4

**La secuencia de §6.4 no cambia ni una letra, pero cambia quién hace qué:**

| Paso | Máquina CON Snap (E1) | Máquina SIN Snap (E2) |
|---|---|---|
| 3 · `apt full-upgrade` | **sustituye** el deb de transición por el de Mozilla | **no hace nada** para Firefox |
| 4 · `apt install firefox-l10n-es-es` | añade el idioma | **instala Firefox entero** y el idioma |

**El aviso, y es serio:** §6.4 presenta el paso 4 como «el idioma, que ningún
`Depends:` puede declarar». En una máquina sin Snap ese paso **es también el
navegador**. Quien lo dé por opcional —o quien escriba el seed y decida que el
idioma se pone «luego»— deja la máquina **sin ningún Firefox**, y el síntoma no
aparece hasta que alguien va a firmar.

#### (h) De propina, un defecto visible — y NO es de E2, es de E1

Sin Snap hay dos ficheros `.desktop` de Firefox: el de Mozilla
(`firefox.desktop`) y la **sombra** que pone `encina-firefox-native`
(`firefox_firefox.desktop`), cuyo trabajo entero era ganarle por precedencia al
lanzador del Snap. Sin Snap ya no tiene a quién ganar, y el usuario ve dos:

```
# en encina-E2-firefox (SIN Snap)
id=firefox_firefox.desktop   nombre=Firefox   visible=True
id=firefox.desktop           nombre=Firefox   visible=True
   control: 26 aplicaciones visibles en total
```

La sombra no lleva `NoDisplay` ni `Hidden`: `Name=Firefox`,
`Exec=/usr/bin/firefox %u`, `TryExec=/usr/bin/firefox`.

**Antes de escribir que esto es un efecto de quitar el Snap, se midió en el otro
mundo**, sobre `encina-E1-meta` —máquina **con** Snap y con la secuencia completa
de E1 puesta— con exactamente el mismo método:

```
$ dpkg-query -W … firefox firefox-l10n-es-es
firefox 153.0.3~build1     firefox-l10n-es-es 153.0.3~build1
$ snap list | grep firefox
firefox   147.0.3-1   7764   latest/stable/…   mozilla**
   [PRESENTE] /usr/share/applications/firefox.desktop
   [PRESENTE] /usr/share/applications/firefox_firefox.desktop
   [PRESENTE] /var/lib/snapd/desktop/applications/firefox_firefox.desktop

id=firefox_firefox.desktop   nombre=Firefox   visible=True
id=firefox.desktop           nombre=Firefox   visible=True
   control: 28 aplicaciones visibles en total
```

**El duplicado ya estaba en E1.** No lo crea quitar el Snap: quitar el Snap solo
deja a la sombra sin motivo. Es un defecto de producto, visible para el usuario,
que **ninguna de las doce casillas de §6.4 miraba** —todas preguntaban a qué
resuelve el identificador, ninguna preguntaba cuántos iconos hay—, y es
exactamente la familia de A2: siete comprobaciones en verde y el icono haciendo
otra cosa.

*No se ha arreglado aquí, a propósito:* el arreglo toca `encina-firefox-native`,
que es un paquete con su propia definición de terminado y su CI, y hoy la tarea
era medir por dónde llega Firefox. Queda escrito con las dos mediciones que hacen
falta para decidir dónde se arregla.

#### (i) Lo que esta medición NO contesta

- **No se ha abierto Firefox**, así que no se ha visto al vigilante de AutoFirma
  meter la CA en el perfil sobre una máquina sin Snap. Está medido en máquinas
  **con** Snap (§4.13 y M14–M18 de `encina-autofirma`), no aquí.
- **Nada de la firma.** Sigue siendo [OJOS] y sigue pendiente.
- **Esto se hizo a mano, no desde un seed.** Es lo que había que saber antes de
  escribir el seed; el seed sigue sin escribirse.
- **El duplicado de iconos no se ha mirado en pantalla**, se ha medido con la
  misma biblioteca que dibuja la rejilla (`Gio.AppInfo.get_all()` +
  `should_show()`), en las dos máquinas y con su control.

---

### 4.18 EL SEED DE VERDAD, ESCRITO Y MEDIDO ENTERO (2026-08-10)

El `autoinstall.yaml` completo, versionado en `imagen/`, y la máquina que
produce. **Una sola pasada, sin humano dentro, 10 min 48 s**: repo local sin
firmar con los cuatro `.deb` en el propio volumen del seed, `encina-meta`,
purgado de `snapd` y los pasos 2, 3 y 4 de `AGENTS.md` §6.4.

**Lo que sale:** todo lo que se predijo funciona a la primera, **se contesta la
pregunta que colgaba —el vigilante de AutoFirma sí mete la CA en una máquina sin
Snap—**, y aparece **un hallazgo que no es de la máquina sino de la casilla**:
la tercera condición de «Sin Snap» pide algo que `encina-firefox-native` impide
por diseño.

#### (a) Qué se daría por sano y qué por roto, escrito antes de arrancar

| # | Lo que se prueba | Sano | Roto |
|---|---|---|---|
| P1 | la palabra llega | `debug.log` de QEMU con `-append autoinstall` **suelto** | `autoinstall=1`, o el error `failed to load ".../Image"` de §4.16k |
| P2 | instala sin humano | el disco crece a los ~90 s **y** la máquina contesta en la red, y se apaga sola | disco intacto **y máquina viva** = se paró a esperar el clic; disco intacto **y máquina muda** = no arrancó (que es el control falso de §4.14i) |
| P3 | el trabajo del seed | los cuatro `.deb` puestos, sin Snap, Firefox nativo en español | cualquiera de las tres cosas a medias, y el registro dentro de `/target` lo dice |
| P4 | el vigilante sin Snap | la CA del socket entra en el perfil al crearse el almacén NSS, **con la huella del paquete** | no entra nunca → la casilla `[OJOS]` de E2 no se puede cumplir; o entra con **otra huella**, que es el caso silencioso de §4.2b |

#### (b) Qué lleva el seed, y por qué así

Versionado en `imagen/`, y son cuatro ficheros:

```
imagen/autoinstall.yaml    el seed: identidad, almacenamiento, y TRES late-commands
imagen/encina-seed.sh      el fuente legible de la tercera, que hace todo el trabajo
imagen/meta-data           instance-id y hostname
imagen/fabricar-seed.sh    fabrica el volumen CIDATA en macOS, con sus controles
imagen/verificar-e2.sh     verifica la maquina que sale, cada casilla con su control
```

El guion va **en base64 en una sola `late-command`**, como el de §4.16: así no hay
ni una comilla que YAML o el intérprete puedan leer de otra manera, y así deja
**un registro propio dentro de `/target`** —1916 líneas—, que es lo único que
permite depurar algo cuyo intento cuesta una instalación entera. Termina siempre
en 0. `fabricar-seed.sh` **se niega a construir el volumen si el YAML y el guion
se han separado**, para que no puedan divergir.

**El volumen pasa de 8 MiB a 128 MiB y sigue siendo un fichero**: dentro van
`user-data`, `meta-data` y `encina-repo/` con los cuatro `.deb` (45,7 MB) y el
índice `Packages`. Nada de red del Mac ni de servidor: es lo más cercano a la
forma definitiva.

**El índice viaja hecho, y no es pereza:** `dpkg-scanpackages` es de `dpkg-dev`, y
§4.15 ya dejó dicho que en E2 de verdad el índice se genera en la construcción y
no en la máquina. El que viaja es el generado en `encina-E2-seed`, y
`fabricar-seed.sh` comprueba que **describe esos mismos bytes**.

#### (c) Los .deb, con la trampa de §4.13 comprobada por los dos lados

Las cuatro huellas, verificadas en el Mac antes de construir, dentro del volumen
después de construirlo, y **otra vez dentro de `/target`** ya en la máquina:

```
d5a0ebe1…  autofirma 1.9.1+encina2          3880b8aa…  encina-firefox-native 0.2.0
d4205134…  encina-branding 0.1.7            e15ce56f…  encina-meta 0.1.1
```

**Y el comparador sabe decir que no, medido con la trampa de verdad**, que es el
`.deb` de `debian-packages/` de este repositorio:

```
$ ./imagen/fabricar-seed.sh --repo <con el encina-branding del arbol> …
[FALLO] huella distinta en encina-branding_0.1.7_all.deb
        esperada d4205134392abd5c345b13d9977f27034fbcd9f083e941a1795fa2dd1ab21a10
        real     0e870833f03618066c108f678613d194a2e57e7b5f3d35167cc54f6d5a713b29
```

Mismo nombre, misma versión, otros bytes. El otro control de la herramienta —que
se niega si el YAML y el guion no coinciden— también se disparó a propósito antes
de usarla.

#### (d) La máquina y el arranque: la palabra la pone el hipervisor

VM nueva `encina-E2-completa`, bundle de UTM construido a mano, `aarch64/virt`,
UEFI, 4 CPU, 8 GiB, disco nuevo de 40 GiB, `virtio-gpu-pci`. Medios, huella a
huella los mismos de §4.14 y §4.16:

```
ISO:    c2610520bf582976839a1724c669e1cfed0547427be5a0ad12d457b92b46ffbe
Image:  a1586ff3cb7ced7c40dcb0aba5bf320ebb94a46d1a6505eb03157a8f9525632d
initrd: 948d5f0449382571eceb32fbbcd5652dff2f9359e69e5f5ec10432b098776b28
seed:   e1f6b8eecf6315cd0cc1b95487b37657e77bed93664c4d167038c84e9e987265   (128 MiB)
```

`Image` e `initrd` **declarados como unidades** (§4.16k), y la palabra suelta. La
prueba de que llegó no es el YAML: es la línea de órdenes de QEMU, leída de su
propio `debug.log`:

```
-kernel  …/encina-E2-completa.utm/Data/Image
-initrd  …/encina-E2-completa.utm/Data/initrd
-append  autoinstall
-no-reboot
```

#### (e) Instala sola, con las dos señales (trampa 9)

```
14:40:02Z  arranca                                    disco.img ocupa 0 MB reales
14:41:17Z  disco 1056 MB   arp: 192.168.64.8 viva     <- las DOS senales
14:48:21Z  empiezan las late-commands (del registro de dentro)
14:50:22Z  el guion del seed llega al final
14:50:50Z  la VM esta apagada                          disco 11 050 MB
```

Menos de **10 min 48 s** desde el arranque hasta el apagado, **sin que nadie
abriera su ventana**. Y del propio log del instalador, el anclaje con §4.14 y
§4.16:

```
2026-08-10 14:48:21Z  testigo-entorno-instalador
2026-08-10 14:48:21Z  testigo-in-target  uname=aarch64 id=0
2026-08-10 14:50:22Z  encina-seed llego al final
[AUSENTE] /etc/encina-e2-testigo-que-no-existe        <- el control, otra vez
```

#### (f) Lo que NO estaba medido y ahora sí: hay red desde dentro del chroot

§4.16l lo dejó escrito como pendiente —«no se ha medido `apt` contra la red desde
una `late-command`»—, y era el riesgo de verdad de esta casilla, porque de él
cuelgan los pasos 2, 3 y 4 de §6.4. **La hay**, y por una razón concreta:
`curtin in-target` deja dentro el `resolv.conf` del entorno vivo.

```
$ curtin in-target -- getent hosts ports.ubuntu.com        -> 6 direcciones   rc=0
$ curtin in-target -- getent hosts packages.mozilla.org    -> 34.160.78.70    rc=0
$ curtin in-target -- getent hosts nombre-que-no-existe.encina.invalid
                                                              (vacio)        rc=2
   <- el control: sabe decir que no
$ curtin in-target -- cat /etc/resolv.conf   -> el stub de systemd-resolved, 127.0.0.53
```

#### (g) El repo local, del volumen al objetivo

El volumen se localiza **por etiqueta, no por `/dev/vdX`**:

```
$ blkid
/dev/vdb: SEC_TYPE="msdos" LABEL_FATBOOT="CIDATA" LABEL="CIDATA" … TYPE="vfat"
  CIDATA -> /dev/vdb
```

y las huellas se comprueban **ya copiadas dentro de `/target`**, con sus dos
controles, que es lo que convierte esto en una comprobación y no en un adorno:

```
[HUELLA  OK ] /target/srv/encina-repo/autofirma_1.9.1+encina2_all.deb
[HUELLA  OK ] /target/srv/encina-repo/encina-branding_0.1.7_all.deb
[HUELLA  OK ] /target/srv/encina-repo/encina-firefox-native_0.2.0_all.deb
[HUELLA  OK ] /target/srv/encina-repo/encina-meta_0.1.1_all.deb
[HUELLA MALA] …/encina-meta_0.1.1_all.deb  esperada=0000…  real=e15ce56f…
[HUELLA MALA] …/fichero-que-no-existe-jamas  real=<no se pudo leer>
```

`apt-get update` traga los `Ign:` de firma y sale con **rc=0**, igual que en §4.17,
y `apt install encina-meta` mete los cuatro con **un solo nombre**:

```
$ curtin in-target -- … apt-get -y install encina-meta
autofirma 1.9.1+encina2 install ok installed      encina-branding 0.1.7 install ok installed
encina-firefox-native 0.2.0 install ok installed  encina-meta 0.1.1 install ok installed
$ apt-mark showauto   -> autofirma, encina-branding, encina-firefox-native
$ apt-mark showmanual -> encina-meta
```

**§4.15 y §4.17c se reproducen desde el seed, sin tocar ninguna marca.**

#### (h) El Snap, con el inventario antes y después (trampa 10)

La orden es la de §4.16g, **literal**, y el inventario mira `/target` desde fuera
del chroot, con `-e` **y** `-L`, porque bajo `/target` los enlaces absolutos
apuntan a la raíz del instalador:

```
ANTES                                    DESPUES
[PRESENTE] …/snaps/firefox_7764.snap     [AUSENTE ] …
[PRESENTE] …/seed/snaps/firefox_7764…    [AUSENTE ] …
[PRESENTE] …/desktop/…/firefox_firefox.desktop   [AUSENTE ] …
[PRESENTE] /target/etc/systemd/system/snap-firefox-7764.mount        [AUSENTE ]
[PRESENTE] …/multi-user.target.wants/snap-firefox-7764.mount         [AUSENTE ]
[PRESENTE] /target/snap/firefox/current  [AUSENTE ] …
[PRESENTE] /target/var/lib/snapd/state.json                          [AUSENTE ]
[PRESENTE] /target/usr/bin/snap          [AUSENTE ] …
[PRESENTE] /target/usr/bin/firefox       [AUSENTE ] …   <- se va con el purgado
[AUSENTE ] …/fichero-que-no-existe-jamas   <- control, en las dos pasadas
[PRESENTE] /target/usr/bin/gnome-shell     <- control, en las dos pasadas
```

Nueve `[PRESENTE]` que pasan a nueve `[AUSENTE]`, con los dos controles diciendo
lo mismo antes y después. Y el estado que decide, que no es un `grep` (§4.16h):
`un firefox` / `un snapd`, con `ii gnome-shell` y `ii ubuntu-desktop-minimal`.

#### (i) Los pasos 2, 3 y 4 de §6.4, trasladados tal cual

**Paso 2 — el anclaje manda con el nombre libre**, igual que en §4.17d:

```
firefox:  Installed: (none)   Candidate: 153.0.3~build1
     1:1snap1-0ubuntu5 500   http://ports.ubuntu.com/ubuntu-ports noble/main
     153.0.3~build1   1000   https://packages.mozilla.org/apt mozilla/main
```

**Paso 3 — no hace nada para Firefox, y el control dice que no está mudo:**

```
$ apt-get -s full-upgrade | grep -c "^Inst "           -> 84
$ apt-get -s full-upgrade | grep -c "^Inst.*firefox"   ->  0
```

**84, el mismo número que en §4.17e**, medido allí a mano sobre otra máquina con
la misma base. Y en las **627 líneas** que ocupan la simulación y el
`full-upgrade` real juntos, la palabra `firefox` **no aparece ni una vez** —con
su control, para que el conteo no esté ciego: `gnome-shell` aparece 16—.

**Paso 4 — es el navegador entero**, por `Depends: firefox (= 153.0.3~build1)`:

```
The following NEW packages will be installed:  firefox firefox-l10n-es-es
Get:1 …/mozilla/main arm64 firefox arm64 153.0.3~build1 [76,4 MB]
Setting up firefox (153.0.3~build1) …
firefox 153.0.3~build1          <- SIN epoch
/usr/bin/firefox -> ../lib/firefox/firefox
/usr/lib/firefox/distribution/extensions/langpack-es-ES@firefox.mozilla.org.xpi
```

**Quien quite el paso 4 por «es solo el idioma» deja la máquina sin navegador.**

#### (j) La máquina que sale: 31 correctas y 1 fallo

`imagen/verificar-e2.sh`, ejecutado como root sobre la máquina arrancada de su
disco. Lo que dio verde, cada cosa con su control:

```
telemetry -> {"1":"loading","409":"done"}    dos entradas: la goberno un seed
no existe la orden snap                      control: command -v bash -> /usr/bin/bash
no existe /var/lib/snapd  /snap  ni el lanzador del Snap
estado dpkg de snapd: un
firefox 153.0.3~build1 (sin epoch)           /usr/bin/firefox -> /usr/lib/firefox/firefox
el idioma puesto                             anclaje de Mozilla a 1000
los cuatro paquetes install ok installed     3 en showauto, 1 en showmanual
                                             control: encina-meta NO esta en showauto
is-system-running: running                   ninguna unidad fallida
graphical.target active                      control: rescue.target inactive
saludador: Name=gdm Seat=seat0 Type=wayland Class=greeter State=active
```

#### (k) EL FALLO, y no es de la máquina: la casilla pide algo que el producto impide

```
[FALLO]  a que resuelve firefox_firefox.desktop
         | esperado: NINGUNA
         | obtenido: /usr/bin/firefox %u
```

La casilla «Sin Snap» de `AGENTS.md` §6bis.3 manda mirar tres cosas, y la tercera
es que `resolver_desktop firefox_firefox.desktop` responda **`NINGUNA`**. **En
esta máquina responde `/usr/bin/firefox %u`, y es correcto**: ese identificador lo
resuelve la **sombra** que instala `encina-firefox-native`, cuyo trabajo entero
era ganarle por precedencia al lanzador del Snap.

```
$ dpkg -S /usr/share/applications/firefox_firefox.desktop
encina-firefox-native: /usr/share/applications/firefox_firefox.desktop
   control: dpkg -S /usr/share/applications/firefox.desktop -> firefox: …
```

**De dónde viene el error, que es de método:** la casilla se escribió con la
medición de §4.16i, hecha sobre `encina-E2-sinsnap`, **una máquina sin ningún
paquete de Encina**. Allí `NINGUNA` era la respuesta correcta porque no había ni
Snap ni sombra. §4.17f midió el otro mundo y ya dio `/usr/bin/firefox %u`, pero
la casilla no se revisó. O sea: **tal como está escrita, ninguna máquina de
Encina OS puede cumplirla**, porque la sombra la pone `encina-meta` por vía de
`encina-firefox-native`.

**Y lo que esto descubre, que es lo que vale:** esta casilla y el defecto de los
dos iconos (§4.17h) son **la misma cosa vista por dos sitios**. La sombra se
quedó sin trabajo el día que desapareció el Snap; mientras siga puesta, el
usuario ve dos iconos **y** la casilla no puede dar verde. **No se toca aquí**:
el arreglo es de `encina-firefox-native`, con su propia definición de terminado y
su CI. Lo que sí queda escrito es que la casilla depende de él.

**La casilla se deja SIN marcar.** Lo que sí está medido y se puede decir sin
aflojar nada: no hay orden `snap`, no hay lanzador del Snap, no hay `/var/lib/snapd`
ni `/snap`, `snapd` está en `un`, y el identificador `firefox_firefox.desktop`
**no resuelve a nada bajo `/snap/`**, que es lo que la casilla quería preguntar.

#### (l) LA PREGUNTA QUE COLGABA: el vigilante de AutoFirma SÍ funciona sin Snap

§4.17i la dejó abierta: el vigilante está medido en máquinas **con** Snap (§4.13,
y M14–M18 de `encina-autofirma`), no en una sin él. Si no funcionase, la casilla
`[OJOS]` de E2 no se podría cumplir.

**Huella de virginidad, antes de tocar nada:** ningún perfil de Mozilla, ningún
`~/.mozilla`, y la CA del paquete recién generada en disco:

```
$ ls -d $HOME/.config/mozilla/firefox/*/   -> NINGUNO
$ openssl x509 -in /usr/share/autofirma/Autofirma_ROOT.cer -noout -subject -fingerprint -sha256
subject=CN = Autofirma ROOT
sha256 E2:A7:4D:EC:C4:C8:74:93:A9:44:9D:37:C1:46:92:E5:B0:E6:43:90:E3:63:7C:86:DE:50:A6:5A:29:4A:60:59
```

**El vigilante está armado**, y esto es distinto de todo lo medido antes: el
paquete se instaló **cuando no existía ninguna sesión de usuario**, así que su
`postinst` no pudo avisar a nadie —lo dijo, y dijo la verdad— pero dejó las dos
unidades enlazadas en `default.target.wants`, que es lo que arma cualquier sesión
posterior:

```
autofirma: AVISO: no se ha encontrado ningún perfil de Mozilla, … y NO HA
autofirma:        PODIDO QUEDAR VIGILANDO ninguna sesión abierta.
/etc/systemd/user/default.target.wants/autofirma-ca-mozilla.path -> /usr/lib/…
$ systemctl --user is-active autofirma-ca-mozilla.path   -> active      rc=0
   control: unidad-que-no-existe.path                    -> inactive    rc=4
$ certutil -L -d sql:/tmp/sin-almacen  -> SEC_ERROR_BAD_DATABASE  rc=255
   <- control de la trampa 7: «sin almacen», no un fallo
```

**Se abrió Firefox una vez** (`firefox --headless`, que es el gesto del usuario
sin pantalla). El almacén NSS nació y la CA entró **dos segundos después**:

```
15:02:52  arranca firefox --headless
15:02:54  cert9.db creado en …/9ysnmsww.default-release
15:02:54  sincronizar-ca-mozilla.sh[3174]: autofirma: CA del socket instalada en
          /home/encina/.config/mozilla/firefox/9ysnmsww.default-release
```

**Y por huella, que el apodo miente (§4.2b):**

```
$ certutil -L -d sql:…/9ysnmsww.default-release
SocketAutoFirma        C,,
   en el perfil: E2:A7:4D:EC:…:60:59
   en el disco:  E2:A7:4D:EC:…:60:59      IGUALES
   control: certutil -L -n ApodoQueNoExiste -> «Could not find cert», rc distinto de 0
```

**Contestado: el mecanismo del 2026-08-09 funciona igual en una máquina sin
Snap.** La barrera que faltaba para la firma no se cierra sola, pero tampoco se
queda abierta por no haber Snap.

**Y de propina, §4.2a reproducida sin buscarla, que casi me hace escribir lo
contrario:** hay **dos** perfiles, y los dos ficheros de control se contradicen
igual que en aquella medición.

```
profiles.ini:  [Profile1] Path=9w21f9gn.default          Default=1   <- vacio, sin cert9.db
installs.ini:  Default=9ysnmsww.default-release  Locked=1            <- el que Firefox usa
```

Mi primera comprobación cogió el perfil con `head -1`, dio con el vacío y dijo
**«la CA no está»**. Era falso: la CA estaba en el que Firefox usa de verdad.
**Una comprobación que resuelva «el perfil» sin mirarlos todos reproduce el fallo
que viene a diagnosticar**, que es literalmente lo que §4.2a dejó escrito el
2026-08-07 y que aquí ha vuelto a morder.

#### (m) Notas de laboratorio

- **`pkill -f "firefox --headless"` mató la sesión que lo ejecutaba.** El patrón
  casó con la línea de órdenes del propio `ssh`, que llevaba ese texto dentro.
  `ssh` salió con 255 a mitad de la medición. Es la **trampa 12** de `SCRIPTS.md`,
  y es de la familia de la 3: el patrón casa con quien lo escribe.
- **El bundle de UTM se puede construir a mano**, sin la interfaz: `config.plist`
  es un plist normal, el disco puede ser un fichero **crudo y disperso** (no hay
  `qemu-img` ejecutable: en UTM viaja como biblioteca, no como orden), y UTM lo ve
  después de reiniciar la aplicación. Los argumentos se ponen con AppleScript
  —registro `qemu argument` con la propiedad `argument string`— y quedan en el
  plist como una lista de cadenas sueltas. **`update configuration` no borró
  nada** esta vez, y es coherente con §4.16k: los cuatro medios estaban
  declarados como unidades.
- **El volumen lleva ficheros `._*` de macOS** (`._user-data`, `._Packages`…), que
  son los AppleDouble que escribe `cp` desde el Finder-land. **No llegan al
  objetivo**, y está medido: el `cp` del guion usa el glob `*` del intérprete, que
  no casa con los que empiezan por punto, y el listado de `/target/srv/encina-repo`
  tiene exactamente cinco ficheros. Se deja escrito porque **cambiar ese `cp` por
  un `cp -a` o un `rsync` los metería dentro del repositorio de apt**, y el
  volumen medido es éste.

#### (n) Lo que esta medición NO contesta

- **La firma en `valide.redsara.es` sigue sin hacerse**, y sigue siendo `[OJOS]`.
  Va en un clon efímero que se destruye (`ENCINA-OS.md` §9.1).
- **La máquina medida ya no es virgen de Firefox**: se abrió una vez, a propósito,
  para contestar (l). Sigue **sin ningún certificado personal**.
- **No se ha mirado ninguna pantalla.** El saludador de GDM está demostrado por
  `loginctl`, no por una foto, igual que en §4.16h.
- **No se ha medido una segunda instalación con el mismo seed.** La reproducción
  cuesta una máquina nueva y no se ha hecho.
- **Nada de E3.** La ISO no se ha tocado, y la palabra `autoinstall` sigue
  poniéndola el hipervisor.
- **amd64, nada.** D9 sigue igual.

---

### 4.19 LA SOMBRA: un solo icono, y la casilla que pedía romper A2 (2026-08-10)

§4.17h dejó medido que el usuario ve **dos iconos de Firefox** y que el duplicado
**ya existía en E1**, o sea que es un defecto de `encina-firefox-native` y no de
la entrega. §4.18k dejó medido que la casilla «Sin Snap» pide algo que ninguna
máquina de Encina puede dar. Esto cierra las dos, y de paso **descubre que la
casilla estaba peor de lo que parecía: tal como estaba escrita, solo se podía
cumplir reabriendo A2.**

**Resultado: `encina-firefox-native` 0.2.1, con `NoDisplay=true` en la sombra.**
Un icono en los dos mundos, A2 intacto, y la casilla corregida y **marcada**.

#### (a) Lo que estaba escrito y no cuadraba entre sí, antes de medir nada

Esto no es una medición, es lectura, y sale primero porque cambia la pregunta:

1. `AGENTS.md` §5.2 **exigía** `NoDisplay=true` en la sombra.
2. El fichero que se entrega **no lo llevaba**, y su propia cabecera decía que
   ponerlo «fue un error» porque hacía desaparecer el icono del dock, y aceptaba
   el duplicado: «es feo, pero los dos abren `/usr/bin/firefox`».
3. `07-firefox-construir.sh` **fallaba** si lo encontraba, y `08-firefox-instalar.sh`
   **fallaba** si la entrada no se mostraba. Las dos comprobaciones estaban
   escritas al revés de §5.2.
4. `ENCINA-OS.md` D11 resuelve los dos lanzadores «quitando el Snap en la imagen,
   **no ocultando entradas**».

O sea que §5.2 llevaba desde A2 contradiciendo al producto y a sus propios
scripts, y nadie lo vio porque **ninguna comprobación contaba iconos**.

**Y D11 no está contradicha: está incompleta.** D11 daba por hecho que el segundo
lanzador era el del Snap, así que quitar el Snap bastaba. E2 quitó el Snap y
siguieron saliendo dos, porque **el segundo es nuestro**. Esa es la parte que D11
no podía prever, y por eso esto no reabre una decisión cerrada.

#### (b) Qué se daría por sano y qué por roto, escrito antes de tocar una VM

| Pregunta | Sano | Roto |
|---|---|---|
| ¿Cuántos iconos hay hoy? | — | **2, en los dos mundos**; si no salieran 2 la premisa es falsa y hay que parar |
| ¿`NoDisplay` quita el duplicado? | 1 icono **y** el identificador sigue resolviendo | 2 (no oculta) o `NINGUNA` (desactiva, y el icono anclado muere) |
| ¿Quitar la sombra reabre A2? | resuelve a algo fuera de `/snap/` | resuelve a `/snap/...` |
| ¿La regresión de D11 es permanente? | el dconf del usuario no se toca | GNOME Shell reescribe `favorite-apps` sin Firefox, y ya no vuelve |

Todo con el método de §4.17h: `Gio.AppInfo.get_all()` + `should_show()`, **con el
número total de visibles al lado como control** de que el inventario no está mudo.

#### (c) El espacio entero de arreglos, medido en las DOS máquinas

`encina-E1-meta` (CON Snap, `firefox` snap `147.0.3-1` rev 7764, los cuatro
paquetes) y `encina-E2-completa` (SIN Snap, testigo del seed de las `14:50:22Z`).
En E1 se editó el fichero en su sitio y se restauró comprobando huella y
`dpkg -V`; en E2 **no hay sudo sin contraseña**, así que se construyó un árbol
`XDG_DATA_DIRS` sintético —copia completa de `/usr/share/applications`— y el
control es que sin mutar da exactamente lo mismo que el sistema real.

| Estado de la sombra | CON Snap | SIN Snap |
|---|---|---|
| **como se entregaba (0.2.0)** | 2 iconos (de 28) · id → `/usr/bin/firefox %u` | 2 iconos (de 26) · id → `/usr/bin/firefox %u` |
| **`NoDisplay=true`** | **1 icono** (de 27) · id → `/usr/bin/firefox %u` | **1 icono** (de 25) · id → `/usr/bin/firefox %u` |
| **sin el fichero** | 2 iconos (de 28) · id → **`/snap/bin/firefox %u`** | 1 icono (de 25) · id → `NINGUNA` |
| **`Hidden=true`** | 1 icono (de 27) · id → `NINGUNA` | — |

**Las tres cosas que decide esta tabla:**

- **`NoDisplay` oculta pero NO desactiva.** Es el hallazgo que lo cambia todo:
  con él puesto el identificador **sigue** dando `/usr/bin/firefox %u`, así que
  el dock de Ubuntu de fábrica, que tiene anclado ese identificador, sigue
  abriendo el nativo. La sustitución de A2 no se toca.
- **Quitar la sombra reabre A2 entero**, y está medido, no razonado:
  `/snap/bin/firefox %u`.
- **`Hidden=true` no sirve:** significa «borrado», no «oculto».

Así que **F1 es el único arreglo que da un icono en los dos mundos sin reabrir
A2**, y no hay que elegir entre los dos mundos: gana en los dos.

#### (d) LA CASILLA: no estaba floja, estaba al revés

La tercera condición de «Sin Snap» (`AGENTS.md` §6bis.3) pedía
`resolver_desktop firefox_firefox.desktop` → **`NINGUNA`**. Mirando la tabla de
(c), `NINGUNA` **solo** se alcanza por dos vías: quitar la sombra o poner
`Hidden`. La primera, en una máquina con Snap, devuelve `/snap/bin/firefox %u`.

**O sea que la casilla, tal como estaba escrita, exigía un estado que solo se
consigue reabriendo A2 o dejando muerto el icono del dock.** No se afloja: se
corrige, porque preguntaba mal. Lo que quería preguntar —y lo que pregunta
ahora— es **que no resuelva a nada bajo `/snap/`**, más una condición nueva que
no tenía nadie: **cuántos iconos ve el usuario**.

#### (e) La regresión de D11, medida sobre una sesión gráfica VIVA

Es el motivo por el que la 0.2.0 quitó `NoDisplay`, y no estaba acotado. Para
medirlo hizo falta una sesión de verdad: en `encina-E1-meta` **no había ninguna**
(`gnome-shell` no corría, solo el saludador), así que se activó el autologin de
GDM **con permiso explícito**, y se restauró al terminar comprobando huella:

```
antes y despues:  ceee968ce021213814ef4f87e19f6e76fcb0333170786dd0c006760ad61810af
```

Con la sesión viva (`gnome-shell` pid 1227, `XDG_DATA_DIRS` leído de su propio
`/proc/<pid>/environ`, y **coincide con el valor por defecto** que usa `lib.sh`,
lo que valida hacia atrás el método de §4.17h), y con el dock del usuario
teniendo anclado el identificador del Snap **en su propio dconf**:

```
$ dconf write /org/gnome/shell/favorite-apps "['firefox_firefox.desktop', ...]"
$ sudo apt-get install ./encina-firefox-native_0.2.1_all.deb     <- dpkg de verdad
   Unpacking encina-firefox-native (0.2.1) over (0.2.0) ...
   Processing triggers for gnome-menus, libglib2.0-0t64, desktop-file-utils

  a los 10 s:  ICONOS = 1   id -> /usr/bin/firefox %u   dconf = ['firefox_firefox.desktop', ...]
  a los 30 s:  ICONOS = 1   id -> /usr/bin/firefox %u   dconf = ['firefox_firefox.desktop', ...]
```

**GNOME Shell NO reescribió `favorite-apps`.** Eso acota el daño y descarta el
caso peor, que era el que preocupaba: la lista del usuario **no se corrompe**, así
que el icono no se pierde para siempre; vuelve al siguiente inicio de sesión. Y
la entrada, oculta, **sigue abriendo Firefox nativo**.

**Lo que esto NO dice, y no se disfraza:** si el icono desaparece o no **de la
pantalla** mientras dura esa sesión. No se ha podido medir sin ojos: la captura
por DBus responde `Screenshot is not allowed` (ya estaba en §4.12d) y el dock es
una superficie Wayland nativa, así que el truco de X11 de `SCRIPTS.md` no aplica.
**Queda `[OJOS]`, y afecta solo a la primera instalación sobre una sesión abierta
de una Ubuntu de fábrica** — que es, además, el caso que D3 dejó de considerar
destinatario.

#### (f) El paquete: 0.2.1, con los dos controles de sabotaje

Construido con `07-firefox-construir.sh` en `encina-dev`, versión por `dch`:

```
correctas: 39   fallos: 0   avisos: 0   omitidas: 0
[OK] Lleva NoDisplay=true: un solo icono, y el identificador sigue vivo
lintian sin errores; 3 overrides justificados y ninguna etiqueta nueva
sha256 del .deb:  972ec9323140d9aa7522be8a3608ff751b042725a3111154321ea1f304b999f2
sha256 de la sombra instalada: a36dac8155ed6543e9cd1bf51c3bea90cf1d7842955b9a23a18956969f8d3324
```

Y la comprobación nueva **sabe decir las dos cosas**, saboteada a propósito:

```
sin NoDisplay          -> [FALLO] La sombra no lleva NoDisplay=true    correctas 38, fallos 1
con Hidden=true        -> [FALLO] La sombra no lleva NoDisplay=true    correctas 38, fallos 1
restaurada             -> [OK]                                          correctas 39, fallos 0
```

#### (g) El seed y la máquina nueva: §4.18 remedido entero

Cambiar el paquete cambia una de las cuatro huellas del seed. Los otros tres
`.deb` se sacaron **del propio volumen medido en §4.18**, no de
`debian-packages/` (§4.13), y coinciden carácter por carácter con §4.18c. El
índice `Packages` se regeneró con `dpkg-scanpackages`.

```
d5a0ebe1…  autofirma 1.9.1+encina2      972ec932…  encina-firefox-native 0.2.1   <- nueva
d4205134…  encina-branding 0.1.7        e15ce56f…  encina-meta 0.1.1
seed:  b8269e52b6de1108933aebbb49e066bb11cbfa469daa4a36aae874a03416273d  (128 MiB)
```

**Y el comparador siguió sabiendo decir que no**, probado con el `.deb` viejo
puesto con el nombre nuevo:

```
[FALLO] huella distinta en encina-firefox-native_0.2.1_all.deb
        esperada 972ec932…   real c2de429a…
```

**VM nueva `encina-E2-0.2.1`**, bundle fabricado sin tocar la interfaz de UTM. **AVISO: esta máquina y este seed se rehicieron el mismo día** (§4.20c), al cambiar la contraseña del YAML. Los números de aquí son los de la primera pasada y siguen siendo válidos como medición; **la máquina vigente es la de §4.20c** —seed `420ca3df…`, testigo `17:14:27Z`—, y es de la que salió el clon de la firma.
La palabra la puso el hipervisor y se lee en el `debug.log` de QEMU, no en el
YAML: `-append autoinstall`, suelto, con `-no-reboot`.

```
16:21:05Z  arranca                       disco 0 MB reales
16:22:39Z  disco 2671 MB   arp 192.168.64.9 viva      <- las DOS senales
16:28:56Z  testigo-entorno-instalador
16:31:03Z  encina-seed llego al final
16:31:12Z  la VM esta apagada            disco 10 666 MB
```

**Menos de 10 min 07 s, sin que nadie abriera su ventana.** Y el verificador,
sobre la máquina arrancada de su disco:

```
[OK] 34   [FALLO] 0   [AVISO] 1   [OMIT] 0
  no existe la orden snap        control: command -v bash -> /usr/bin/bash
  firefox_firefox.desktop no resuelve a nada bajo /snap/ (/usr/bin/firefox %u)
  control: un identificador que no existe (NINGUNA)      <- la trampa 11, viva
  ICONOS DE FIREFOX QUE VE EL USUARIO: 1                 <- la casilla nueva
  control: 25 aplicaciones visibles en total
  encina-firefox-native 0.2.1 install ok installed       3 showauto, 1 showmanual
  firefox 153.0.3~build1 (sin epoch)   el idioma puesto  anclaje a 1000
  is-system-running: running   graphical.target active   gdm Class=greeter State=active
```

El `[AVISO]` es que no se ejecutó como root. **No tapa nada:** en esta máquina
`/var/log/installer/telemetry` es `0644` —no `0600` como decía §4.18m— así que se
leyó igualmente y su casilla dio `[OK]` de verdad, con el fichero a la vista.

#### (h) Tres correcciones mías, y las tres van escritas

- **Una pasada entera sobre `encina-E2-completa` no midió NADA y decía `[OK]`.**
  El usuario `encina` **no tiene sudo sin contraseña**, así que las cuatro
  mutaciones fallaron en silencio y los cuatro «estados» eran el mismo. Peor: el
  paso de restaurar comprobó la huella, la encontró igual —porque nadie había
  tocado nada— y escribió **«[OK] la maquina queda como estaba»**. Es la familia
  de la trampa 5: una comprobación que responde lo mismo sana y rota. Se rehízo
  con un `[MUTACION APLICADA]` **antes** de cada lectura, y si no se aplica no se
  imprime ningún número. Va a `SCRIPTS.md` como **trampa 13**.
- **Arranqué dos VMs a la vez**, `encina-dev` y `encina-E1-meta`, y **las dos
  quieren `192.168.64.3`**. Una consulta contestó desde la máquina equivocada.
  No contaminó ninguna medición porque todas las salidas llevan su huella de
  identidad dentro —E1-meta tiene los cuatro paquetes y el snap `147.0.3-1` rev
  7764; `encina-dev` no tiene ninguno y su snap es `153.0.3-1` rev 8735—, que es
  exactamente para lo que están. Va a `SCRIPTS.md` como **trampa 14**.
- **La copia de seguridad de `/etc/gdm3/custom.conf` la puse en `/tmp`, y el paso
  siguiente era reiniciar.** `/tmp` es tmpfs: se evaporó. Se restauró igual
  porque la huella estaba anotada fuera de la máquina, que es lo que de verdad
  vale como recibo.

Y una que no es mía sino del laboratorio: **`grep -n NoDisplay` sobre ese fichero
casa con sus propios comentarios** —cuatro líneas de la cabecera explican por qué
lo lleva—. Es la trampa 3 otra vez; no engañó porque se imprimieron los números
de línea y el `07` filtra comentarios.

#### (i) Lo que esta medición NO contesta

- **Si el icono desaparece de la pantalla** en la primera instalación sobre una
  sesión abierta. Es `[OJOS]`, está dicho en (e) y está escrito en el propio
  `.desktop`.
- **Nada de la firma.** Sigue `[OJOS]` y sigue pendiente.
- **No se ha mirado ninguna pantalla**, igual que en §4.17h y §4.18.
- **No se ha medido una segunda instalación con el seed nuevo.**
- **`encina-E1-meta` queda con la 0.2.1 puesta**, no con la 0.2.0 de §4.17h. Su
  dock quedó como estaba (`dconf` del usuario vacío) y el autologin restaurado
  por huella, pero **ya no es la máquina exacta de §4.17h**.
- **La máquina nueva se llama `encina-e2-completa` de hostname**, igual que la
  vieja, porque el nombre lo pone el seed. Se distinguen por el testigo:
  `16:31:03Z` la nueva, `14:50:22Z` la vieja.

---

### 4.20 LA FIRMA SOBRE LA MÁQUINA DEL SEED, Y LA CONTRASEÑA QUE NO EXISTÍA (2026-08-10)

**La última casilla de E2.** Y para llegar a ella hubo que arreglar antes un
defecto del propio seed que nadie había notado porque nunca había hecho falta
entrar por la pantalla: **la contraseña del usuario no la sabía nadie.**

#### (a) El defecto: un seed con una contraseña que no se puede usar

`imagen/autoinstall.yaml` lleva la contraseña como hash `$6$…`, que es de una
sola dirección. Para la firma hace falta **entrar en la sesión gráfica**, y hasta
ahora todo se había medido por `ssh` con clave, así que el texto claro nunca se
echó de menos. No estaba anotado en ninguna parte del repositorio —correcto— pero
tampoco lo recordaba nadie.

Comprobado que **el mismo hash viaja en los cuatro seeds** (`user-data-minimo`,
`user-data-medicion-snap`, `user-data-completa` y `autoinstall.yaml`), lo que
concuerda con lo escrito en §4.16k: «la contraseña desechable es la de siempre».
No lo era, o ya no.

**Decisión de Jorge: regenerar con `encina`.** Se hace en el seed versionado, no a
mano sobre la máquina, para que la máquina siga siendo **100 % producto del
seed** — retocarla por GRUB habría sido tocarla a mano, que es justo lo que la
casilla `[OJOS]` prohíbe.

#### (b) LA TRAMPA, y habría colado una contraseña rota

Primer intento, con `crypt` de Python en el Mac:

```
hash nuevo: $6WjIPoxPKheY
```

**Trece caracteres. Eso es DES, no SHA-512.** macOS **no implementa `$6$` en
`crypt(3)`** y cae al método antiguo **sin avisar y sin error**; Python declara
`crypt.METHOD_SHA512` disponible, que es lo que engaña. Y el prefijo `$6` a
simple vista parece correcto: lo que lo delata es **la longitud**, no el prefijo.

DES trunca la contraseña **a ocho caracteres** y su hash es trivial de romper.
Habría «funcionado» —`encina` tiene seis— y habría sido mentira. Rehecho con
`openssl passwd -6`, que en macOS sí lo implementa, y verificado a la salida:

```
$6$X7olMGXFyS5DEjp$YAhAR8.Yf…       105 caracteres, prefijo $6$
  'encina'  -> COINCIDE
  'Encina'  -> no coincide            <- los dos controles
  'encinaX' -> no coincide
```

Va a `SCRIPTS.md` como **trampa 15**.

#### (c) La reinstalación, y el verificador por fin como root

Seed nuevo `420ca3df57c97993b7328816da27c9f379d3c4e2a56e3cb9319538ad1851138d`
—las cuatro huellas de los `.deb` intactas, solo cambia el YAML—. Máquina
`encina-E2-0.2.1` rehecha entera:

```
17:04:16Z  arranca                     disco 0 MB reales
17:05:48Z  disco 2054 MB  arp .10 viva          <- las DOS senales
17:12:19Z  testigo-entorno-instalador
17:14:27Z  encina-seed llego al final
17:14:59Z  la VM esta apagada          disco 11 130 MB
```

**10 min 43 s, sin que nadie abriera su ventana**, con `-append autoinstall`
leído del `debug.log` de QEMU. Y con la contraseña ya conocida se pudo ejecutar
`verificar-e2.sh` **como root**, que es como pedía §4.18m:

```
[OK] 35   [FALLO] 0   [AVISO] 0   [OMIT] 0
```

**Cero omitidas por primera vez:** la casilla de `telemetry` deja de estar
omitida. Y la contraseña se comprueba contra quien la valida de verdad, con su
control:

```
$ echo "encina"   | sudo -S -k true   -> [OK]    la acepta
$ echo "noesesta" | sudo -S -k true   -> [OK]    control: rechaza una equivocada
$ grep ^encina: /etc/shadow           -> $6$X7olMGXFyS5DEjp$…   106 caracteres
```

#### (d) LA FIRMA — `[OJOS]`, hecha por Jorge el 2026-08-10

**Esto lo vio Jorge en pantalla y lo declara él; yo no he visto la pantalla.** Lo
que sigue es la corroboración que dejó la máquina, recogida **antes** de
destruirla, y que es consistente con su declaración.

**Y la trampa de §4.2a mordió, exactamente como está escrita.** Hay **cinco**
entradas bajo el directorio de perfiles y tres ni siquiera son perfiles
(`Crash Reports`, `Pending Pings`, `Profile Groups`). Los dos ficheros se
contradicen:

```
profiles.ini:  Default=quf9icbd.default-release     (arriba)
profiles.ini:  Name=default   Path=hodgdgie.default   Default=1
installs.ini:  Default=quf9icbd.default-release   Locked=1
```

Un `head -1` habría cogido `Crash Reports` o el perfil vacío `hodgdgie.default` y
habría respondido «la CA no está», que es falso. **El perfil se eligió por
evidencia de uso**, que es el criterio de §4.2a:

```
  quf9icbd.default-release   compatibility.ini=SI  firstUse=1786382464491  cert9.db=SI
  hodgdgie.default           compatibility.ini=no  firstUse=None           cert9.db=no
```

**La CA de AutoFirma llegó sola al perfil que Firefox usa de verdad**, comparada
por huella y no por apodo (§4.2b):

```
$ certutil -L -d sql:<perfil usado>          (solo -L, trampa 7)
   SocketAutoFirma                                C,,
   <el certificado personal de la FNMT>           u,u,u

  CA del paquete en disco, en DER:  9d3621278884a004d908ba1b2ff9006fa61d5280f4a5fd9a7a072d0d5ff2904f
  CA en el almacen NSS,     en DER:  9d3621278884a004d908ba1b2ff9006fa61d5280f4a5fd9a7a072d0d5ff2904f
  [OK] COINCIDE
```

**Detalle de método que conviene no olvidar:** el `.crt` en disco está en PEM y
su `sha256` de fichero es `5ad03b99…`, que **no** es comparable con nada sacado
de NSS. Hay que normalizar **los dos lados a DER** antes de comparar; si no, sale
un falso «no coincide» perfectamente creíble.

**Y el certificado personal estaba en el almacén con su clave privada** (`u,u,u`,
y `certutil -K` lista una clave RSA asociada). *El sujeto no se transcribe aquí:
lleva nombre y DNI, y este repositorio es público (D5).*

**AutoFirma se ejecutó de verdad**, y desde el navegador:

```
java … -DAFIRMA_NSS_PROFILES_INI=/home/encina/.config/mozilla/firefox/profiles.ini
       -jar /usr/share/autofirma/autofirma.jar afirma://websocket?ports=59098,60297,55743&…
  305 lineas con «autofirma» en el journal de la sesion
  /home/encina/.afirma                       creado a las 17:22:27Z
  cert9.db del perfil usado                  escrito a las 17:22:00Z
```

Dos cosas que ese volcado demuestra y que son las que importaban: el
`AFIRMA_NSS_PROFILES_INI` apunta al **perfil nativo** (`~/.config/mozilla/`), no
al del Snap, o sea que B5 no se reprodujo; y el esquema `afirma://` llegó a
AutoFirma, o sea que B1 sigue cerrada.

**Y el navegador que firmó era el nativo**, que es la condición de todo el
proyecto:

```
$ readlink -f /proc/<pid>/exe    -> /usr/lib/firefox/firefox-bin
  control: ¿esta bajo /snap/?    -> fuera de /snap/
  lanzado como                   -> /usr/bin/firefox
```

#### (e) El clon, destruido, con su control

```
[OK] encina-firma-efimera ya no aparece en utmctl
[OK] el bundle ya no existe en disco
ninguna copia de *.p12 en los bundles de UTM, ni en el scratchpad, ni en el repositorio
  control de que la busqueda sabe encontrar algo:  ~/Documents/CertificadoJMB.p12
  el original, intacto: 1f1679705959902f0d3579ced856fe20d81c67a41a486158ed22dbcda47f21a0
```

#### (f) Lo que esta medición NO contesta

- **La firma en sí no la he visto yo.** Es `[OJOS]` y la declara Jorge. Lo que
  hay aquí es la corroboración que dejó la máquina, no una captura de la sede.
- **No se ha medido una segunda firma**, ni sobre otra sede.
- **La contraseña `encina` es débil y ahora es pública**, porque está en el
  `autoinstall.yaml` versionado. Para E2 —receta validada en un hipervisor, con
  máquinas desechables— es aceptable y es la decisión tomada. **Para E3 no lo
  es**, y queda escrito como deuda de E3 en `ENCINA-OS.md`.
- **amd64, nada.** D9 sigue igual.

---

### 4.21 E3 — Las dos mediciones baratas de apertura: el Secure Boot del banco y el seed dentro de la ISO (2026-08-10)

**Medición de apertura de E3**, y sigue la regla de §10: *¿qué comando demuestra
que esto es viable?* Aquí son dos preguntas, las dos baratas, y las dos se
contestan **antes de tocar `xorriso`**, que es el riesgo de verdad de este
incremento:

1. **¿Aplica Secure Boot en el banco de UTM?** Porque si no aplica, una ISO
   reempaquetada que arranque aquí **no demuestra nada** sobre una máquina real
   con Secure Boot activo, y eso cambia lo que E3 puede prometer.
2. **¿Basta con meter el seed en `/cdrom/autoinstall.yaml` y la palabra en el
   GRUB de la ISO?** Es la deuda que E3 hereda con nombre (`ENCINA-OS.md` §10).

**Respuestas cortas.** *(1)* **No aplica, y no es que esté desactivado: es que el
firmware no lo implementa.** Medido por los dos lados —la orden de QEMU con la
que arranca de verdad una VM del proyecto, y la ausencia de la variable EFI
dentro del invitado con su control—. *(2)* **Sí, y está leído en el código que
viaja dentro de esta misma ISO**, con su orden de precedencia exacto y con una
consecuencia que nadie había escrito: **un volumen `CIDATA` conectado GANA al
seed de la ISO**, porque va cuarto y el de la ISO va quinto.

**Coste: cero instalaciones.** Una VM arrancada un minuto para leer una variable
y devuelta parada, y lecturas sobre la ISO en el Mac.

#### (a) Qué se daría por sano y qué por roto, escrito antes de medir

Escrito entero antes de las mediciones decisivas, y se conserva:

- **M1.** «No aplica» solo se da por medido si dentro de un invitado de este
  banco *(i)* `mokutil --sb-state` lo dice, **y** *(ii)* la variable
  `SecureBoot-8be4df61-…` **no existe** en `/sys/firmware/efi/efivars/`.
  **Control obligatorio:** «el fichero no está» no vale si el directorio de
  variables EFI no está montado o está vacío — hay que **contar** cuántas
  variables hay y leer una de verdad. Sin ese control, la respuesta es una
  trampa 11 de manual.
- **M2.** Sano: existe en esta ISO una función que elige el seed,
  `/cdrom/autoinstall.yaml` está entre los sitios que mira, y se puede escribir
  su **orden exacto** frente al `CIDATA` de cloud-init. Roto: no existe, o está
  tapado por algo, o depende de algo que E3 no puede poner. **Control:** solo
  cuenta el código que sale del `.snap` que está dentro de este fichero `.iso`.
- **M2b.** Sano: se identifica **qué** fichero gobierna la línea de órdenes del
  núcleo en el arranque UEFI de esta ISO y **dónde** iría la palabra suelta.
  Roto: la configuración que manda está embebida en un binario firmado, o hay
  más de una y no se sabe cuál gana. **Control:** comprobar si `md5sum.txt`
  cubre ese fichero, porque si lo cubre, editarlo rompe la comprobación de
  integridad del propio medio y eso hay que saberlo **antes**.

**Honestidad de método:** cuando se escribió ese texto ya estaban leídos, del
lado Mac, el descriptor de firmware de UTM y el `debug.log` de la VM. O sea que
la mitad Mac de M1 se midió antes de escribir el sano/roto; el resto, después.

#### (b) M1 — El banco de UTM no aplica Secure Boot, y no puede

**Lado Mac, lo que UTM arranca de verdad.** No es el fichero de configuración
sino la orden que se ejecutó, del `debug.log` de `encina-E2-0.2.1`:

```
-drive if=pflash,format=raw,unit=0,file.filename=.../Caches/qemu/edk2-aarch64-code.fd,file.locking=off,readonly=on
-drive if=pflash,unit=1,file.filename=.../encina-E2-0.2.1.utm/Data/efi_vars.fd
```

`edk2-aarch64-code.fd`, **no** `edk2-aarch64-secure-code.fd`. Los dos ficheros
están en la aplicación —los dos de 67108864 bytes—, pero **solo uno tiene
descriptor**, y sus rasgos declarados lo dicen todo. Con su control por el otro
lado, que es lo que separa «UTM no lo usa» de «el formato no sabe expresarlo»:

```
50-edk2-x86_64-secure.json -> ['acpi-s3','amd-sev','requires-smm','secure-boot','verbose-dynamic']   <- el control
60-edk2-x86_64.json        -> ['acpi-s3','amd-sev','amd-sev-es','verbose-dynamic']
60-edk2-aarch64.json       -> ['verbose-static']
60-edk2-arm.json           -> ['verbose-static']
```

O sea: el formato **sí** sabe decir `secure-boot` —lo dice para x86—, y para
aarch64 no lo dice ninguno. Y en toda la aplicación, `secure-code` solo aparece
en esos dos descriptores de x86 y en la firma de código; no hay ni un camino
desde la interfaz.

**Lado invitado, sobre `encina-E2-sinsnap`** (identificada por huella, no por
hostname: testigo `2026-08-10T10:07:39Z`, IP `.7`), arrancada sola —ninguna otra
VM viva, trampa 14— y devuelta parada:

```
=== CONTROL: cuantas variables EFI se ven, y algunas por nombre ===
efivarfs on /sys/firmware/efi/efivars type efivarfs (rw,nosuid,nodev,noexec,relatime)
32
Boot0000-…  BootCurrent-…  BootOrder-…  ConIn-…  MokListRT-…  SbatLevelRT-…  Timeout-…

=== LA PREGUNTA: existe SecureBoot / SetupMode / PK / KEK / db ? ===
NINGUNA DE ESAS VARIABLES EXISTE

=== CONTROL POSITIVO: leer de verdad una variable que si existe ===
variable elegida: Boot0000-8be4df61-93ca-11d2-aa0d-00e098032b8c
 07 00 00 00 09 01 00 00 2c 00 55 00 69 00 41 00

=== mokutil ===
This system doesn't support Secure Boot
rc=255

=== lo que dice el nucleo al arrancar ===
kernel: efi: EFI v2.7 by EDK II
kernel: secureboot: Secure boot disabled
kernel: Loaded X.509 cert 'Canonical Ltd. Secure Boot Signing: 61482aa2…'
```

**Tres cosas que se leen ahí y las tres importan:**

1. **El control funciona:** hay 32 variables EFI, se lee una de verdad en
   hexadecimal, y el `efivarfs` está montado. Así que «no está» significa **no
   está**, y no «no he sabido mirar».
2. **`mokutil` no dice «desactivado», dice «este sistema no lo soporta»**, que es
   otra cosa: no hay `PK`, ni `KEK`, ni `db`, ni `SetupMode`. El firmware es un
   EDK II compilado sin Secure Boot, y el propio invitado lo confirma:
   `bios_vendor` = `EFI Development Kit II / OVMF`.
3. **Pero la cadena firmada SÍ está y SÍ se recorre:** `MokListRT`,
   `MokListXRT` y `SbatLevelRT` existen, y esas variables **las escribe el
   `shim`**. O sea que la máquina arranca por `shim` → `grub` → núcleo firmado
   por Canonical; lo que no hay es nadie que verifique las firmas.

**Qué le compra esto a E3, que es para lo que se midió:**

- **E3 no puede validar Secure Boot aquí, y eso se declara** en vez de suponerse
  cubierto — igual que D9 declara amd64. Una ISO que arranque en este banco no
  prueba que arranque en una máquina real con Secure Boot activo.
- **Y por eso mismo E3 no toca los tres binarios firmados** —`bootaa64.efi`
  (shim), `grubaa64.efi`, `mmaa64.efi`—: si los rompiera, **este banco no se
  daría cuenta**, porque no verifica nada. La regla no es prudencia: es la
  consecuencia directa de lo que se acaba de medir.
- **Y eso encaja con lo que E3 necesita**, según (d): el único fichero que hay
  que cambiar para poner la palabra **no es ninguno de los tres**.

#### (c) M2 — `/cdrom/autoinstall.yaml` es el quinto sitio, leído en el código de ESTA ISO

Mismo método que §4.16a, sobre la misma ISO y comprobada antes de leer nada:

```
$ sha256sum ubuntu-24.04.4-desktop-arm64.iso
c2610520bf582976839a1724c669e1cfed0547427be5a0ad12d457b92b46ffbe     <- la de §4.14
$ head -3 meta/snap.yaml        # del snap del instalador, dentro de la capa viva
name: ubuntu-desktop-bootstrap
version: 0+git.4bc1f4077                                              <- la misma que leyó §4.16a
```

**La función entera**, `subiquity/server/server.py:889-924`, literal:

```python
    def select_autoinstall(self):
        # precedence
        # 1. command line argument autoinstall
        # 2. kernel command line argument subiquity.autoinstallpath
        # 3. autoinstall at root of drive
        # 4. autoinstall supplied by cloud config
        # 5. autoinstall baked into the iso, found at /cdrom/autoinstall.yaml
        ...
        kernel_install_path = self.kernel_cmdline.get("subiquity.autoinstallpath", None)

        locations = (
            self.opts.autoinstall,
            kernel_install_path,
            self.base_relative(root_autoinstall_path),
            self.base_relative(cloud_autoinstall_path),
            self.base_relative(iso_autoinstall_path),
        )

        for loc in locations:
            if loc is not None and os.path.exists(loc):
                break
        else:
            return None

        rootpath = self.base_relative(root_autoinstall_path)
        copy_file_if_exists(loc, rootpath)
        return rootpath
```

Y las constantes, `server.py:73-75`, que es donde está el nombre exacto:

```python
iso_autoinstall_path = "cdrom/autoinstall.yaml"
root_autoinstall_path = "autoinstall.yaml"
cloud_autoinstall_path = "run/subiquity/cloud.autoinstall.yaml"
```

**Son rutas relativas a `base_relative`, y en una ejecución de verdad la raíz es
`/`** —`server.py:285-287`, `root = "/"`, y solo cambia con `--dry-run`—. Luego
el quinto sitio es literalmente **`/cdrom/autoinstall.yaml`**.

**Y `/cdrom` es el medio, medido y no supuesto**, en el código de casper que
viaja en esta misma ISO: `scripts/casper:7` dice `mountpoint=/cdrom`, y los
guiones de `casper-bottom` consumen `/root/cdrom/.disk/info` —o sea
`${rootmnt}/cdrom`, ya en la raíz real— en `25adduser`, `43disable_updateinitramfs`
y `57pollinate`. Y `.disk/info` **está en la raíz de la ISO**, en el listado.
Conclusión: un fichero llamado `autoinstall.yaml` puesto en la raíz del ISO9660
aparece en el sistema vivo como `/cdrom/autoinstall.yaml`.

**LO QUE NADIE HABÍA ESCRITO Y SALE DE LEER EL ORDEN: el `CIDATA` gana.** El seed
servido por cloud-init es el **cuarto**, el de la ISO es el **quinto**, y el
bucle se para en el primero que existe. Tiene dos caras:

- **A favor:** la ISO de E3 sigue siendo **anulable**. Quien quiera otra
  instalación le conecta su propio volumen `CIDATA` y el suyo manda, sin tocar
  la ISO. Eso es una propiedad del producto, no un accidente.
- **En contra, y es una trampa de laboratorio con nombre:** en este banco los
  volúmenes `CIDATA` de E2 están a mano y **un volumen olvidado en la VM
  secuestraría la medición de E3 en silencio** — la instalación saldría bien y
  estaría midiendo el seed equivocado. **La medición de E3 tiene que enseñar que
  no había ningún segundo disco conectado**, y el testigo que lo distingue no
  puede ser «la máquina salió bien».

También se lee, y evita una tentación: `subiquity.autoinstallpath=` es el
**segundo** sitio y sí funciona para *dónde* está el seed — pero lleva `=`, así
que sigue haciendo falta la palabra `autoinstall` **suelta** para el clic
(§4.16a). No se gana nada usándolo: `/cdrom` no necesita ningún parámetro.

#### (d) M2b — Solo hay UN `grub.cfg` en todo el medio, y no está en la partición EFI

**El fichero, entero** (`boot/grub/grub.cfg` del ISO9660, 571509730281fc143dd548e53a927777):

```
set timeout=30
loadfont unicode
set menu_color_normal=white/black
set menu_color_highlight=black/light-gray

menuentry "Try or Install Ubuntu" {
	set gfxpayload=keep
	linux	/casper/vmlinuz  --- quiet splash console=tty0
	initrd	/casper/initrd
}
menuentry 'Boot from next volume' {
	exit 1
}
menuentry 'UEFI Firmware Settings' {
	fwsetup
}
```

**Cómo arranca esta ISO por UEFI, medido de la propia imagen** y no de la
documentación de nadie:

```
MBR part 1: tipo=0xcd  inicio_lba=64        sectores=6900480
MBR part 2: tipo=0xef  inicio_lba=6900544   sectores=13504        <- la ESP, 6,59 MiB
BRVD id: 'EL TORITO SPECIFICATION'   catalogo en LBA 860   platform id = 239 (0xEF = UEFI)
  entrada arrancable=0x88  sectores_virtuales=13504  LBA=1725136  -> 6,59 MiB   (= la misma)
```

Esa ESP es una FAT12 con etiqueta `ESP`, y **dentro solo hay tres ficheros y
ningún `.cfg`**:

```
efi/boot/bootaa64.efi    987336
efi/boot/mmaa64.efi      884360
efi/boot/grubaa64.efi   2443144
```

Los tres son **byte a byte los mismos** que los de `efi/boot/` del ISO9660
—sha256 idénticos—, o sea que el medio los publica una vez y los ve por dos
sitios. Y el GRUB firmado **no lleva el menú dentro**, con su control:

```
'Try or Install'        -> 0        'GRUB'        -> 9    <- control: strings SÍ
'Boot from next volume' -> 0        'configfile'  -> 3       encuentra cosas en
'/casper/vmlinuz'       -> 0        'linux'       -> 15      ese mismo binario
```

**Conclusión por eliminación, y es la que E3 necesita:** en todo el medio hay
**un** `grub.cfg` —`boot/grub/grub.cfg`—, la ESP tiene **cero** ficheros de
configuración, y el binario firmado no trae menú. Luego el menú que sale en
pantalla es ese fichero, y **ahí va la palabra**, en la línea
`linux /casper/vmlinuz`, **suelta** (§4.16a: `autoinstall=1` NO vale).

**Y el aviso que la casilla de control pedía: `md5sum.txt` cubre ese fichero.**

```
571509730281fc143dd548e53a927777  ./boot/grub/grub.cfg      <- en md5sum.txt
571509730281fc143dd548e53a927777                            <- md5 del fichero extraído
```

Coinciden, así que la línea habla de este fichero y no de otro. **Consecuencia
para E3: quien edite `grub.cfg` y no actualice `md5sum.txt` deja una ISO que
arranca bien y que falla la comprobación de integridad del propio medio.** Es
exactamente la clase de fallo que no aparece hasta que alguien lo prueba, y ahora
está escrito antes de que ocurra.

#### (e) Notas de laboratorio

- **`unsquashfs` sobre macOS revienta a mitad, y no por culpa de la imagen:**
  `FATAL ERROR: dir_scan: failed to make directory subiquity/usr/lib/aarch64-linux-gnu/perl/5.34.0/sys, because File exists`.
  Es el sistema de ficheros del Mac, que no distingue mayúsculas, contra `sys/`
  y `Sys/` de Perl. **No invalida nada de lo leído** —`bin/subiquity/` se extrae
  antes de llegar ahí, y `meta/snap.yaml` da la versión—, pero si algún día hace
  falta el árbol entero hay que extraer sobre una imagen de disco sensible a
  mayúsculas. Lo barato es extraer **solo la ruta que se quiere leer**, que es lo
  que se hizo con los guiones de casper.
- **La ISO que se ha leído es la copia de trabajo**,
  `e2-medios/ubuntu-24.04.4-desktop-arm64.iso`, con el `sha256 c2610520…` de
  §4.14 comprobado antes de leer nada. Hay una segunda copia idéntica en tamaño
  dentro del bundle de `encina-E2-sinsnap`, y no se ha tocado.
- **Una sola VM viva en todo momento** (trampa 14), identificada por huella
  antes de preguntarle nada, y devuelta al estado en que estaba: parada.

#### (f) Lo que estas mediciones NO contestan

- **Que el mecanismo funcione.** Está **leído**, no ejecutado. Poner un fichero
  en `/cdrom/` es modificar la ISO, o sea `xorriso`, y esto se ha hecho
  precisamente para llegar allí con **un** objetivo en vez de tres. La primera
  medición de E3 con máquina de por medio sigue siendo la que decide.
- **Dónde va exactamente la palabra respecto del `---`.** El separador está en
  la línea del núcleo y casper lo interpreta. Que `subiquity` la vea da igual
  —lee `/proc/cmdline` entero (§4.16a)—, pero **qué le hace casper a lo que va
  antes y después no está medido**, y se decide en el primer arranque de la ISO
  reempaquetada.
- **Si `xorriso` sabe reconstruir esta ISO conservando la ESP y El Torito.** No
  se ha intentado. Es el riesgo entero de E3 y no se ha tocado hoy a propósito.
- **Secure Boot en hardware real.** Este banco **no puede** contestarlo, y esa es
  justo la respuesta de (b). Queda declarado como límite, no como deuda.
- **Si UTM podría forzarse al firmware seguro.** `edk2-aarch64-secure-code.fd`
  existe en la aplicación, sin descriptor y sin camino desde la interfaz. **No
  se ha intentado** y no se recomienda: no es lo que E3 entrega.
- **La contraseña.** Sigue siendo `encina`, débil y pública. Esta medición no la
  toca; la deuda sigue viva y es de E3.

#### (g) La tercera lectura, que no estaba planeada, y deja sin objeto media lista de (f)

**Posterior a las dos mediciones**, y la provocó una pregunta de Jorge al leerlas:
*«si instalo Ubuntu me pide las credenciales, ¿por qué aquí no?»*. La pregunta
señala una contradicción que el proyecto llevaba dentro sin escribirla, y la
respuesta se lee en el mismo código.

**Lo primero, que no es una medición sino un error de encuadre.** E2 tenía que
instalar sin que nadie tocara nada, y eso **era su criterio de validación, no el
producto** — está escrito con esas palabras en §10 de `ENCINA-OS.md`. E3 había
heredado el criterio **como si fuera el producto**, y de ahí salía todo lo demás:
si la ISO no puede preguntar, el usuario tiene que venir escrito dentro; si viene
escrito, hace falta una contraseña; y entonces hay tres salidas malas. **La
contraseña no era un problema que resolver: era el síntoma.**

**Lo segundo, leído en la subiquity de esta misma ISO:** el seed **puede** dejar
secciones a que las conteste una persona.

```python
# server.py:236, el esquema
"interactive-sections": {"type": "array", "items": {"type": "string"}},

# controller.py:113-127, quien decide seccion por seccion
def interactive(self):
    i_sections = self.app.autoinstall_config.get("interactive-sections", [])
    if "*" in i_sections:                  return self._active
    if self.autoinstall_key in i_sections: return self._active

# server.py:166, y hay un punto HTTP que el cliente GRAFICO consulta
async def interactive_sections_GET(self) -> Optional[List[str]]:
```

Ese tercer trozo es lo que hace la lectura interesante: **no es solo que el
servidor entienda la clave, es que el cliente pregunta por ella**, o sea que la
interfaz está escrita para enseñar esas pantallas. **Sigue sin estar medido** que
el instalador **de escritorio** lo haga —leído no es medido, y el de escritorio
no es el de servidor—, y esa es la siguiente tarea.

**Lo tercero, y es lo que hace la decisión barata: la receta es agnóstica del
usuario.** También leído, sobre los dos guiones del repositorio:

```
$ grep -n "/home\|HOME\|useradd\|usermod\|sudo -u" imagen/encina-seed.sh
                                    # vacio: ni una linea
$ grep -n "encina\b" imagen/verificar-e2.sh   # solo nombres de paquete y de testigo
```

Ni el guion del seed ni el verificador nombran al usuario. Todo el trabajo es del
sistema —`/srv/encina-repo`, `apt`, purgar `snapd`—, que **es consecuencia directa
de R1** (nada de `/etc/skel`: la configuración por defecto va por `dconf` y
`gschema.override`, que no necesitan saber cómo se llama nadie). Una regla escrita
para otra cosa acaba de pagar aquí.

**DECIDIDO por Jorge el 2026-08-10: la ISO de E3 pregunta, como Ubuntu — menos la
instalación mínima, que va forzada.** Queda en `AGENTS.md` §6ter.0 con su motivo.

**La excepción tiene su propio motivo y no es de instalación, es de producto.**
`source` va fijo a `ubuntu-desktop-minimal`, y con él `codecs` y `drivers` en
`false`. **Encina OS se construye sobre la mínima**, y lo que va encima se
declara en `encina-meta` —el eje de E4—; si `source` se preguntara, media entrega
dependería de que el usuario acertara con una pantalla y **dos máquinas de Encina
OS no serían la misma cosa**. Por eso la lista es **explícita** y no `['*']`:
`'*'` haría interactivo también `source`. Y el mecanismo lo permite, porque
`controller.py:113-127` decide **sección por sección**. Los seis nombres que sí
se preguntan salen del código de esta ISO, no de la documentación: `locale`
(`locale.py:30`), `keyboard` (`keyboard.py:162`), `network` (`network.py:77`),
**`storage`** (`filesystem.py:248` — ojo, el controlador se llama `Filesystem` y
la clave `storage`), `identity` (`identity.py:50`) y `timezone`
(`timezone.py:80`).

**Y cambia lo que (f) dejaba abierto:**

- **La contraseña deja de ser una deuda.** No hay `identity:` en el seed de la
  entrega, así que no hay nada que elegir. `encina` se queda donde tiene sentido:
  el seed de laboratorio, que se sirve con `CIDATA` y no entra en ninguna ISO.
- **La palabra del GRUB deja de hacer falta**, y con ella el `md5sum.txt`: el
  clic de confirmación es la pantalla normal de «instalar ahora» cuando hay
  alguien delante. **Lo medido en (d) no se tira** — dice exactamente qué habría
  que tocar y qué se rompería al tocarlo, y es lo que sostiene que **E3 solo
  añade ficheros al medio y no modifica ninguno**.
- **Lo de `/cdrom` sigue siendo justo lo que E3 necesita**, entero.
- **Y aparece una medición nueva, más barata que `xorriso` y anterior a él:**
  fabricar el seed de E3 en un volumen `CIDATA` y arrancar con él la ISO oficial.
  Contesta la forma **sin tocar la ISO**, usando el banco de E2 tal cual.

**Lo que esta lectura NO contesta, y es lo que hay que medir:** si el instalador
de escritorio enseña de verdad esas seis pantallas; **si sabe mezclar** —unas
secciones interactivas y otras no— o si se atraganta; **qué hace con la pantalla
de «¿qué aplicaciones quieres?» ahora que `source` no se pregunta**, que es la
que en el escritorio comparte sitio con los códecs y los controladores; y si las
`late-commands` siguen corriendo cuando hay secciones interactivas.

**Una arista del producto que salió de aquí, y se cerró el mismo día.** El seed
instala `firefox-l10n-es-es` **sin condición**, así que si el idioma se
preguntara, quien eligiera otro se llevaría **una máquina a medias**: sistema en
un idioma y navegador en español. **Jorge lo vio y decidió forzar el español**:
`locale: es_ES.UTF-8` sale de `interactive-sections` y pasa a ser producto, igual
que `source`. **El teclado no**, y la distinción es la que importa: el teclado es
**hardware**, y no todo el que quiere el sistema en español teclea en un teclado
español. **Queda por medir una consecuencia de esto:** con `locale` no
interactiva, en qué idioma sale la interfaz **del propio instalador**.

---

### 4.22 E3 — La forma funciona: el instalador de escritorio SÍ honra `interactive-sections`, y sabe mezclar (2026-08-10)

**La primera medición de E3 con máquina de por medio, y se hace ANTES de tocar
`xorriso` a propósito**, con un volumen `CIDATA` y el banco de E2 tal cual. Separa
las dos preguntas que no deben mezclarse: *¿es correcta la forma del producto?* y
*¿sé reempaquetar una ISO?*. Ésta contesta la primera.

**Respuesta corta: SÍ, y con la mezcla que hacía falta.** El instalador **de
escritorio** enseña **solo** las cinco pantallas pedidas —teclado, red, disco,
usuario y zona horaria— y aplica del seed las dos que van fijas —idioma
`es_ES.UTF-8` e instalación mínima—. No hay que elegir entre «todo automático» y
«todo preguntado».

#### (a) Qué se daría por sano y qué por roto, escrito antes de arrancar

- **Sano:** el instalador de escritorio enseña las cinco pantallas de
  `interactive-sections`, **y no** la de idioma ni la de «¿qué aplicaciones
  quieres?», y aun así el seed se aplica.
- **Roto:** ignora la clave y se comporta como hasta ahora; o la respeta y se
  atraganta al mezclar; o no enseña nada.
- **Y una pregunta que solo se puede contestar en el escritorio:** `source` es en
  el instalador gráfico **la misma pantalla** que los códecs y los controladores.
  Si `source` no se pregunta, ¿desaparece la pantalla entera o queda a medias?

#### (b) El banco, y lo que llevaba dentro

Volumen fabricado con la herramienta versionada, que además **es la primera vez
que se usa `--yaml`**:

```
./imagen/fabricar-seed.sh --yaml imagen/autoinstall-e3.yaml --repo <repo> --salida seed-e3-forma.img
   [OK] los cuatro .deb, huella a huella          [OK] Packages describe 4 ficheros, ni uno mas
   [OK] los cuatro .deb sobreviven al volumen     [OK] user-data y meta-data coinciden byte a byte
   sha256: 18a22ce8c2b767532c0f181ad6c487978fec19c041a2f3d498d68e44489ba317
```

Los `.deb` **no salen de `debian-packages/`** sino del volumen medido de E2, que
es la trampa de §4.13; sus cuatro huellas se comprueban dos veces.

La VM, `encina-E3-forma`, se fabricó **sin tocar la interfaz de UTM**: ISO
oficial como CD, el volumen del seed y un disco disperso de 40 GiB. Y lo que la
distingue de todas las de E2 se lee en la orden de QEMU, no en el YAML:

```
$ grep -o "\-append [^ ]*" debug.log
                          # vacio: SIN -append, o sea SIN la palabra autoinstall
$ curl http://192.168.64.11:8000/proc/cmdline
BOOT_IMAGE=/casper/vmlinuz --- quiet splash console=tty0
```

#### (c) LA RESPUESTA, leída del registro del propio instalador

**Del servidor** (`subiquity-server-debug.log`), que enseña las dos mitades:

```
18:41:12,200 autoinstall found in cloud-config
18:41:12,284 load_autoinstall_config only_early True  file /autoinstall.yaml
18:41:12,583 apply_autoinstall_config: skipping Keyboard as interactive     <- las pedidas, SE SALTAN
18:41:12,584 apply_autoinstall_config: skipping Network as interactive
18:41:12,584 model source for install stage is configured                   <- las fijas, SE APLICAN
18:41:12,585 model locale for postinstall stage is configured
18:41:13,398 finish: Meta/interactive_sections_GET: SUCCESS: 200
             ["keyboard", "network", "storage", "identity", "timezone"]
```

**Y del cliente gráfico** (`ubuntu_bootstrap.log`), que es lo que decide, porque
el de servidor no prueba nada sobre el escritorio:

```
18:41:12.681 ApplicationStatus(state: WAITING, cloudInitOk: true, interactive: true)
18:41:13.398 ==> getInteractiveSections() ["keyboard","network","storage","identity","timezone"]
18:41:13.398 INFO installer_service: Showing only pages requested by subiquity:
             {keyboard, network, storage, identity, timezone}
18:41:13.418 INFO keyboard: Initialized es () keyboard layout
```

Y el estado, del `telemetry` de la sesión viva:

```
{"Type":"Flutter","OEM":false,"Media":"Ubuntu 24.04.4 LTS","Stages":{"1":"keyboard"}}
```

**Cuatro cosas se leen ahí y las cuatro importan:**

1. **`Showing only pages requested by subiquity`** — el instalador de escritorio
   no solo entiende la clave: **el cliente gráfico la consulta y obedece**. Era
   lo único que la lectura de §4.21g no podía garantizar.
2. **Sabe mezclar.** `skipping … as interactive` para las pedidas y
   `model … is configured` para `source` y `locale`. No es todo o nada.
3. **La pantalla de «¿qué aplicaciones?» desaparece con `source`**, que era la
   duda del escritorio: no queda a medias.
4. **De propina, el idioma forzado arrastra el teclado:** el instalador arranca
   con `es` ya elegido —`Initialized es () keyboard layout`— aunque el teclado se
   pregunte. O sea que la pantalla sale con la respuesta correcta puesta y el que
   tenga otro teclado la cambia, que es exactamente lo que se quería.

**CONTROL DE MÉTODO, y sostiene todo lo anterior: la prueba es ANTERIOR a que yo
tocara la máquina.** Todas esas líneas están fechadas a las **18:41**, y la
primera pulsación que yo mandé fue a las **18:51**. Lo que se lee no lo pudo
provocar ninguna manipulación mía.

#### (d) Cómo se leyó, que costó más que la medición

La sesión viva no tiene `ssh` —y el seed de E3 no lo lleva a propósito—, así que
hubo que abrir un canal. **Tres trampas por el camino, las tres nuevas:**

- **La pantalla negra NO era un fallo: era el bloqueo de GDM.** Tras unos minutos
  la sesión viva se bloquea y queda un fondo negro con el cursor de X, que se
  parece muchísimo a «esto no ha arrancado». Un clic devuelve el saludador
  —`Live session user`— y detrás está el instalador, intacto. **Antes de dar por
  muerta una sesión gráfica hay que despertarla.**
- **Se puede entrar por consola de texto sin contraseña.** `Ctrl+Alt+F3` y
  usuario `ubuntu` con la contraseña vacía; y desde ahí, `sudo` sin contraseña.
- **UTM traduce el texto con la distribución del MAC, no con la del invitado.**
  `input keystroke` con un `-` producía un `/` en el invitado, y `sudo loadkeys us`
  **no lo arregla**, porque el problema está en el anfitrión. La salida es mandar
  **códigos de teclado crudos** con `input scan code`, que no pasan por ninguna
  traducción.

Con eso, el canal de lectura fue un `python3 -m http.server` **de solo lectura**
dentro de la sesión viva, y los registros se trajeron con `curl` desde el Mac.

#### (e) Lo que la PRIMERA MITAD no contestaba — y se contestó el mismo día en (f)

- **Que las `late-commands` corran.** El instalador está **esperando en la
  primera pantalla**, así que el trabajo de Encina no ha empezado: **0 MB
  escritos** en el disco de destino, comprobado. Hace falta que alguien conteste
  las cinco pantallas, y eso es `[OJOS]` **por diseño del producto**: la casilla
  de E2 era «nadie la toca» y la de E3 es «una persona contesta lo que Ubuntu
  pregunta, y nada más».
- **Que el seed valga desde `/cdrom`.** Aquí llegó por `CIDATA` —`autoinstall
  found in cloud-config`—, que es el **cuarto** sitio. El quinto sigue sin
  ejercitarse y necesita `xorriso`.
- **Nada sobre la máquina resultante.** Ni `verificar-e2.sh`, ni el Snap, ni
  Firefox. Todo eso cuelga de la instalación completa.
- **Y esta sesión viva quedó manipulada** —consola abierta, un servidor HTTP como
  root— así que **no sirve para la medición completa**. La VM se paró y se
  rearrancó con el disco todavía a **0 MB**, para que la instalación de verdad
  salga de un entorno limpio.

#### (f) SEGUNDA MITAD: la instalación entera, contestada por una persona

**Sobre la VM rearrancada limpia**, Jorge contestó las cinco pantallas y nada
más. **Es `[OJOS]` por diseño del producto**, no por falta de instrumentación: la
casilla de E2 era «nadie la toca» y la de E3 es «una persona contesta lo que
Ubuntu pregunta». Puso usuario `encina`, contraseña `encina` y nombre de equipo
`Encina`; el teclado, `es`.

**Y el resultado se lee sin depender de ninguna pantalla, que es lo que lo hace
una medición: `telemetry` dice exactamente por qué pantallas pasó.**

```
"Stages": { "1":"keyboard", "513":"network", "515":"storage", "528":"identity",
            "553":"timezone", "556":"confirm", "558":"install", "976":"done" }
"PartitionMethod": "use_device"
```

**Las cinco pedidas, en orden, y ni una más.** No aparece `locale` ni `source`,
que son las dos que el seed fija. Es la confirmación de extremo a extremo de lo
que (c) leía en el registro: **el instalador de escritorio sabe mezclar**.

**La máquina que sale es la de E2**, verificada **como root** con
`imagen/verificar-e2.sh` traído desde el Mac:

```
=== Resumen ===
  [OK] 33   [FALLO] 2   [AVISO] 0   [OMIT] 0
```

Los 33 correctos son los que importan y son idénticos a los de §4.20c: sin Snap
—no existe la orden, ni `/snap`, ni el lanzador; `firefox_firefox.desktop` →
`/usr/bin/firefox %u`; **1 icono** de Firefox sobre 25 aplicaciones visibles—;
`firefox 153.0.3~build1` sin epoch con el `.xpi` de `langpack-es-ES` y el anclaje
a prioridad 1000; los cuatro paquetes `install ok installed` con los tres
dependientes en `showauto` y `encina-meta` en `showmanual`; y la máquina entera
—`is-system-running: running`, ninguna unidad fallida, `graphical.target` activo
y un saludador de GDM vivo—. Los tres testigos están, y el del seed dice que
llegó al final:

```
encina-e2-testigo-seed: encina-seed llego al final 2026-08-10T19:20:50Z
/etc/encina-seed.log: 1916 lineas, «=== 14. FIN ===», rc=0
```

**Lo que el seed fijaba, fijado, y sin nadie que lo eligiera en pantalla:**

```
/etc/default/locale     LANG=es_ES.UTF-8        <- el sistema instalado, en espanol
/etc/default/keyboard   XKBLAYOUT="es"          <- esto SI lo eligio Jorge
/etc/passwd             encina  uid 1000        <- el unico usuario, creado por el
/usr/sbin/sshd          no existe               <- el seed de E3 no pone servidor ssh
```

#### (g) LOS DOS FALLOS NO SON DE LA MÁQUINA: SON DEL INSTRUMENTO

```
[FALLO]  las etapas por las que paso el instalador
         | esperado: done,loading
         | obtenido: confirm,done,identity,install,keyboard,network,storage,timezone
[FALLO]  hay pantallas de instalacion a mano en telemetry
```

**`verificar-e2.sh` se llama así por algo: su bloque 1 codifica el criterio de
E2**, que era «esto lo gobernó un seed y nadie tocó nada». En E3 eso **tiene que
fallar**, porque el producto pregunta. **No se afloja la comprobación: se le pone
la de E3**, que además es **más exigente** que la de E2 —E2 solo pedía que no
hubiera pantallas; E3 puede pedir **exactamente cuáles** y fallar si sobra una—:

*Sano en E3:* las etapas son exactamente `keyboard, network, storage, identity,
timezone` más `confirm, install, done`. *Roto:* aparece `locale` o `source` —el
seed dejó de fijarlos— o falta alguna de las cinco.

Es el mismo error de método que §4.19d, con la diferencia de que aquí se vio a la
primera: **una casilla escrita para un incremento no vale para el siguiente sin
releerla**. Queda como trabajo inmediato dar a `verificar-e2.sh` un modo para las
dos formas, sin tocar el de E2.

#### (h) Dos cosas que salieron de propina, y una es del producto

**1. El instalador se ve en inglés, y el sistema instalado en español.** Es
consecuencia directa de sacar `locale` de `interactive-sections`: sin pantalla de
idioma, el interfaz se queda en el idioma por defecto de la sesión viva. **Tiene
arreglo, y está leído en el casper de esta misma ISO**
(`casper-bottom/14locales`):

```sh
locale=*)
    locale=${x#locale=}
    set_locale="true"
...
LANG=$(grep "^${locale}" /root/usr/share/i18n/SUPPORTED | grep UTF-8 | sed -e 's, .*,,' -e q)
printf 'LANG="%s"\n' "${LANG}" > /root/etc/default/locale
chroot /root /usr/sbin/locale-gen --keep-existing
```

O sea: **`locale=es_ES.UTF-8` en la línea del núcleo pone la sesión viva en
español**. Y encaja con que la ISO trae capas de idioma dedicadas
—`casper/minimal.standard.es.squashfs`, en el listado de §4.21—.

**El precio, y hay que decirlo antes de que parezca gratis: esa palabra va en
`boot/grub/grub.cfg`, así que E3 deja de ser «solo añadir ficheros» y pasa a
modificar uno.** Vuelve a aplicar §4.21d: **`md5sum.txt` cubre ese fichero** y hay
que rehacerlo. La regla de no tocar los tres binarios firmados sigue intacta;
`grub.cfg` no está firmado. **No medido todavía:** que el interfaz Flutter siga a
`LANG`. Se comprueba de una vez cuando exista la ISO reempaquetada.

**2. Un `QEMU error: … #block908: Invalid argument` durante la instalación, dos
veces, y NO es del producto.** El identificador señala **el disco de destino**, y
la orden que UTM le pasa lleva `discard=unmap,detect-zeroes=unmap`: al formatear,
el sistema de ficheros manda un descarte, QEMU intenta agujerear el fichero
disperso creado con `dd … seek=40g` sobre APFS y macOS contesta `Invalid
argument`. **Es del banco, no de la ISO ni del seed.** Y no hizo daño, comprobado
donde se vería:

```
/sys/fs/ext4/vda2/errors_count  ->  0
```

#### (i) Notas de laboratorio, y un falso positivo mío

- **`curl` NO está en la instalación mínima.** El primer intento de traer el
  verificador falló por eso, y el síntoma fue engañoso —`bash: /tmp/v.sh: No
  existe el archivo`—, que apunta al fichero y no a la orden que no existe. Se
  hizo con `python3 -c urllib.request`, que sí está.
- **Un falso positivo mío, cazado y anotado:** comprobé si había servidor `ssh`
  con `curl -s -o /dev/null <url>/etc/ssh/sshd_config` **mirando el código de
  salida**, y dio «existe». Es falso: `curl` sale con 0 al recibir un **404**, y
  lo que descargó fue la página de error. La comprobación buena mira el **código
  HTTP** (`-w %{http_code}`), y entonces `/usr/sbin/sshd` responde **404**: no hay
  servidor ssh. Familia de la trampa 5, en el instrumento de medida.
- **El teclado del sistema instalado es `es`**, así que los códigos crudos de
  EE.UU. vuelven a descolocarse; `sudo loadkeys us` en la consola **sí** lo
  arregla aquí, porque en este lado el problema es del invitado y no del
  anfitrión.

#### (j) Lo que sigue sin contestar

- **Que el seed valga desde `/cdrom`.** Aquí llegó por `CIDATA`, que es el
  **cuarto** sitio. El quinto necesita `xorriso` y es lo único que queda de E3.
- **Que el interfaz del instalador salga en español** con `locale=` en el
  `grub.cfg`. Leído, no medido.
- **Qué pasa si alguien conecta un `CIDATA`** a la ISO de E3: por orden de
  precedencia le ganaría (§4.21c). No se ha probado.
- **Nada de la firma.** Esta máquina no ha firmado; la casilla `[OJOS]` de E2 ya
  está marcada y E3 no la repite.

---

### 4.23 E3 — LA ISO EXISTE, Y SE INSTALA: el seed viaja dentro y se coge de `/cdrom` (2026-08-10)

**La medición que cierra E3.** Una ISO construida por
`imagen/fabricar-iso.sh` a partir de la oficial, arrancada en una **VM creada
desde cero** —sin clonar, sin heredar nada, con **dos unidades y ni una más**:
la ISO y un disco vacío—, produjo una máquina de Encina OS entera contestando
**solo las cinco pantallas que pregunta Ubuntu**.

**`verificar-e2.sh --forma e3` como root: 36 correctas, 0 fallos, 0 avisos,
0 omitidas.**

#### (a) La línea que decide, y no es la del resumen

De `/etc/encina-seed.log`, dentro de la máquina instalada:

```
=== 1. DONDE ESTA EL REPO: las dos vias, y se dice cual se uso ===
  CIDATA -> <no encontrado>
  REPO ELEGIDO -> /cdrom/encina-repo
```

**No había ningún volumen `CIDATA`, y el repositorio salió de dentro de la
ISO.** Junto con el seed —que el instalador encontró en `/cdrom/autoinstall.yaml`,
el quinto sitio leído en §4.21c—, eso es E3 entero: **la imagen se basta sola**.

Y el arranque lo confirma desde fuera, que es donde no se puede fingir:

```
$ grep -o "\-append [^ ]*" debug.log      # vacio: nadie le paso 'autoinstall'
$ grep -o "file.filename=[^ ,]*" debug.log
    edk2-aarch64-code.fd   efi_vars.fd   encina-os-E3.iso   disco.img
```

Dos unidades además del firmware. **Ningún `CIDATA` conectado**, que es el
control que pedía la trampa 16: con uno enchufado la instalación habría salido
igual de bien midiendo el seed equivocado.

#### (b) La ISO: qué se le hizo a la oficial, y qué no

`xorriso` **sabe reconstruir esta imagen**, y no hubo que adivinar cómo: la
receta se la da la propia ISO.

```
$ xorriso -indev ubuntu-24.04.4-desktop-arm64.iso -report_el_torito as_mkisofs
-V 'Ubuntu 24.04.4 LTS arm64'   --modification-date='2026021001455100'
-partition_cyl_align all        -partition_offset 16
-append_partition 2 0xef --interval:local_fs:6900544d-6914047d::'…iso'
-iso_mbr_part_type 0xcd         -c '/boot/boot.cat'
-e '--interval:appended_partition_2_start_1725136s_size_13504d:all::'  -no-emul-boot
```

Con eso, `-boot_image any replay` reproduce el arranque tal cual. **Lo que el
guion comprueba, y es lo que hace que la ISO se pueda entregar:**

```
[OK] bootaa64.efi intacto      [OK] grubaa64.efi intacto      [OK] mmaa64.efi intacto
[OK] la ESP es byte a byte la oficial en sus 13504 sectores (0616185672c2636e…)
[OK] los 192 sectores de mas son relleno de alineacion: 0 bytes distintos de cero
[OK] el seed no lleva identidad, ni contrasena, ni clave ssh
[OK] control: la misma busqueda SI las encuentra en el seed de laboratorio
```

**Las huellas de los tres binarios firmados no son un adorno:** el banco **no
aplica Secure Boot** (§4.21b), así que si se rompieran **aquí no lo notaría
nadie**, y la huella es la única señal que queda.

**Y `md5sum.txt` es el oficial byte a byte**, porque no se modificó ningún
fichero: solo se añadieron dos. Comprobado además sobre tres entradas sueltas
—`boot/grub/grub.cfg`, `casper/vmlinuz`, `.disk/info`—, que siguen cuadrando. La
comprobación de integridad del propio medio sigue pasando **sin hacer nada**.

#### (c) La construcción es reproducible, y costó tres intentos saberlo

La primera versión del guion daba **dos ISOs distintas con la misma entrada**.
No se dio por bueno: se localizó qué cambiaba.

| intento | bytes distintos | qué eran |
|---|---|---|
| tal cual | **192**, en 4 sectores | las marcas de tiempo RRIP de los ficheros añadidos: `20:08:38` contra `21:35:45` |
| `-alter_date_r b` | **16** | el **segundero** del registro de directorio ISO9660: `2026-08-10 21:37:26` contra `21:37:45` |
| `+ -alter_date_r c` | **0** | — |

La fecha que se les pone no es inventada: es **la de modificación de la ISO
oficial**, `2026021001455100`, que la propia imagen declara en su receta. Lo
añadido hereda la fecha del medio.

```
sha256 de dos construcciones seguidas: 13a7d815837162435377bdfba4f32dd3… (las dos)
```

**La ISO que se instaló de verdad es anterior a ese arreglo** —`0a1127f4…`— y se
comprobó que la diferencia es exactamente esa y ninguna otra: **256 bytes, todos
en los sectores 82, 118, 296 y 332**, que son los árboles de directorio ISO9660 y
Joliet, con **el contenido de todos los ficheros idéntico** (comprobado sobre el
seed, el índice `Packages`, un `.deb` y `grubaa64.efi`).

#### (d) La máquina que sale

Idéntica a la de E2, y ahora con el instrumento correcto (§4.22g):

```
=== 1. El seed lo goberno todo menos las cinco pantallas de E3 (forma E3) ===
  [OK] las etapas (confirm,done,identity,install,keyboard,network,storage,timezone)
  [OK] ni el idioma ni el tipo de instalacion se preguntaron
  [OK] control: el mismo grep si encuentra 'keyboard' en telemetry
  [OK] testigo encina-e2-testigo-seed: encina-seed llego al final 2026-08-10T21:29:28Z
=== Resumen ===
  [OK] 36   [FALLO] 0   [AVISO] 0   [OMIT] 0
```

Sin Snap, **1 icono** de Firefox sobre 25 aplicaciones visibles, `firefox
153.0.3~build1` sin epoch con el `langpack-es-ES`, los cuatro paquetes con sus
marcas, `graphical.target` activo y saludador vivo. Y lo que fija el seed, fijado
sin que nadie lo eligiera: `LANG=es_ES.UTF-8`. El teclado, `es`, **ése sí lo
eligió Jorge**. Un solo usuario, el que él creó. **Sin servidor ssh**
(`/usr/sbin/sshd` → 404 por el canal de lectura).

**Y arranca de su propio disco:** se le quitó la ISO de las unidades antes de
volver a encenderla.

#### (e) EL DEFECTO QUE ESTA MEDICIÓN SACA, y no es pequeño

**El instalador se ve entero en inglés.** Lo vio Jorge y es reproducible: es la
consecuencia directa de sacar `locale` de `interactive-sections` (§4.22h). El
sistema instalado queda en español —`LANG=es_ES.UTF-8`—, pero **la primera cosa
que ve quien recibe la ISO está en un idioma que el producto no habla**.

**La definición de terminado de E3 no lo pedía, así que no lo detuvo. Eso es un
defecto de la definición, no del producto**, y es exactamente el error de §4.19d:
una casilla que deja pasar un estado que nadie querría entregar. Se propone
añadirla, con el arreglo ya leído en el casper de esta ISO
(`casper-bottom/14locales`): `locale=es_ES.UTF-8` en el `grub.cfg`, **con su
precio**: E3 dejaría de ser «solo añadir ficheros» y habría que rehacer
`md5sum.txt` (§4.21d).

#### (f) Notas de laboratorio

- **Interpreté mal una pantalla y lo digo:** al capturar vi «Copying files…» y
  escribí que estaba instalando **sin haber preguntado nada**. Era falso: Jorge
  ya había contestado las cinco pantallas mientras tanto. **La captura de una
  pantalla no lleva fecha; el registro sí**, y por eso lo que decide en §4.22 fue
  un `telemetry`, no una imagen.
- **El `QEMU error … #block…: Invalid argument` volvió a salir dos veces**, en
  una VM distinta y recién creada. Es del **banco**: `discard=unmap` sobre el
  fichero disperso que se crea con `dd … seek=40g` en APFS. No hizo daño, y se
  comprobó donde se vería: `/sys/fs/ext4/vda2/errors_count` → **0**. Sale en
  todas las VMs que se fabriquen así.

#### (g) Lo que E3 sigue sin contestar

- **El idioma del instalador**, que es (e), y necesita una segunda ISO.
- **Qué pasa si alguien conecta un `CIDATA`** a esta ISO: por precedencia le
  ganaría al seed de dentro (§4.21c). Sigue sin probarse.
- **Secure Boot en hardware real**: el límite declarado de §4.21b, intacto.
- ~~**Que `imagen/autoinstall.yaml` —el seed de E2— sigue produciendo lo
  mismo.**~~ **CONTESTADO el 2026-08-10 en §4.24: sí lo sigue produciendo**, 35
  correctas y 0 fallos sobre una VM creada desde cero, y con eso el guion de las
  dos vías queda medido por sus dos ramas.

---

### 4.24 E2 remedido — la vía `CIDATA` del guion que aprendió dos vías (2026-08-10)

**Por qué se remide un incremento cerrado.** `imagen/encina-seed.sh` cambió al
enseñarle las dos vías del repo, así que `imagen/autoinstall.yaml` **ya no es
byte a byte el que produjo `encina-E2-0.2.1`** (§4.23g). Por el precedente de
§4.19g, un `.deb` nuevo obligó a rehacer el volumen y a **remedir la instalación
entera**; aquí lo que cambió es el guion, que pesa más.

**Y no mide «lo de E2», que es lo que hace que valga la pena hacerlo primero.**
El base64 incrustado en los dos seeds es **el mismo fichero**, comprobado por
huella y no por lectura:

```
$ for f in imagen/autoinstall.yaml imagen/autoinstall-e3.yaml; do
      grep -o "echo [A-Za-z0-9+/=]\{100,\}" $f | sed 's/^echo //' | shasum -a 256; done
8e8ac75b55378109fffdf7306dbbf11c4fa10677449d20aacf7557f99d844f0a  -
8e8ac75b55378109fffdf7306dbbf11c4fa10677449d20aacf7557f99d844f0a  -
```

O sea que esta medición mira **la vía `CIDATA` del mismo guion que viaja dentro
de la ISO de E3**. La vía `/cdrom` está medida en verde (§4.23a); la `CIDATA` es
la que cambió y nadie ha vuelto a mirar. Si aquí sale un defecto, el arreglo va
en `encina-seed.sh` → cambia el base64 → cambia `autoinstall-e3.yaml` → **cambia
la ISO**. Por eso va antes que la novena casilla de E3.

**El cambio, acotado**, que es todo el diff desde el commit que cerró E2 (`89c98e3`):
secciones 1 y 2 del guion. Antes montaba `CIDATA` **sin preguntar si existía** y
copiaba de una ruta literal; ahora elige entre dos vías y copia de `$REPO`. En la
forma de E2 las dos deberían dar exactamente lo mismo, y eso es lo que hay que
enseñar, no razonar.

#### (a) Qué se daría por sano y qué por roto, escrito ANTES de medir

| # | Qué se mira | Sano | Roto |
|---|---|---|---|
| 1 | `fabricar-seed.sh` sobre el YAML nuevo | construye y **no se niega**: las cuatro huellas de los `.deb` cuadran **dos veces** —antes de construir y releyendo el volumen— y el par YAML/guion no está separado | se niega, o construye con alguna huella mala |
| 2 | La instalación | la VM **se apaga sola**, nadie abre su ventana, y `-append autoinstall` **suelto** se lee en el `debug.log` de QEMU | hace falta tocar algo, o la palabra no aparece en el `debug.log` |
| 3 | **La línea que decide esta medición**, en `/etc/encina-seed.log` | `CIDATA -> /dev/vdX` (encontrado **por etiqueta**) y `REPO ELEGIDO -> /mnt/encina-seed/encina-repo` | `REPO ELEGIDO -> <NINGUNO>`, o cualquier otra cosa: sería el defecto que la elección nueva puede haber metido, y es **el único sitio donde se vería** |
| 4 | Las huellas dentro del registro del seed | los cuatro `[HUELLA  OK ]` | uno solo `[HUELLA MALA]` en los cuatro reales |
| 5 | `verificar-e2.sh` como root, **sin `--forma`** | **35 correctas, 0 fallos, 0 avisos, 0 omitidas**, idéntico a §4.20c, con etapas `done,loading` | cualquier `[FALLO]`, cualquier `[AVISO]`, cualquier `[OMIT]`, o un número distinto de 35 |

**Y los controles, porque ninguna de las cinco vale sin el suyo:**

- **1, 3 y 4 traen el suyo dentro** y ya están medidos: el comparador de huellas
  tiene dos entradas que **tienen que salir `[HUELLA MALA]`**, y el inventario
  del Snap tiene una que tiene que salir `AUSENTE` y otra `PRESENTE`. Si esos
  cuatro no aparecen como se espera, el registro entero no vale nada (trampa 13).
- **El control de que se está midiendo el YAML NUEVO y no el volumen viejo**, que
  es la trampa propia de esta medición: el volumen se **rehace**, se identifica
  **por huella sha256**, y el `user-data` se extrae **del volumen construido** y
  se compara byte a byte con `imagen/autoinstall.yaml`. Las dos huellas —la del
  volumen viejo `seed-e2-0.2.1-pw.img` y la del nuevo— van escritas. Sin esto,
  arrancar con el volumen de ayer da **exactamente el mismo verde** y no mide nada.
- **El control de la trampa 16, al revés que en E3:** aquí el `CIDATA` **tiene**
  que estar, y la prueba de que se usó no es que la instalación salga bien, es la
  línea 3 nombrando el dispositivo encontrado por etiqueta.
- **Una sola VM encendida**, comprobado con `utmctl list` antes de arrancar, y la
  máquina **creada desde cero**: sin clonar nada, para que lo que se mida sea el
  seed y no un estado heredado (§9.1).

**Lo que esta medición NO contesta**, dicho antes para que no se cuele después:
nada sobre la ISO de E3 —esa está medida en §4.23 y no se toca aquí—, y nada
sobre el idioma del instalador, que es la novena casilla y va después.

#### (b) Las cinco, cumplidas, y las huellas de lo que se usó

**`imagen/autoinstall.yaml` sigue produciendo la misma máquina. 35 correctas,
0 fallos, 0 avisos, 0 omitidas**, igual que §4.20c.

| # | Predicción | Lo que salió |
|---|---|---|
| 1 | el guion no se niega | las cuatro huellas dos veces, `Packages` describe cuatro y ni uno más, y `coinciden (11106 bytes de guion, 14808 de base64)` |
| 2 | se apaga sola, con la palabra suelta | `-append autoinstall`, **una sola vez** en el `debug.log`, y la VM parada sola |
| 3 | **la línea que decide** | `CIDATA -> /dev/vdb` · `REPO ELEGIDO -> /mnt/encina-seed/encina-repo` |
| 4 | las cuatro huellas dentro | cuatro `[HUELLA  OK ]`, **y los dos controles `[HUELLA MALA]`** |
| 5 | el verificador | `[OK] 35   [FALLO] 0   [AVISO] 0   [OMIT] 0` |

**Las huellas, para que esto se pueda repetir y para que no se pueda confundir
un volumen con otro:**

```
seed viejo (el que produjo encina-E2-0.2.1)   ebcda148a3f1fc3c374bb9a49bccd3ff…
seed nuevo (el de esta medicion)              13aa8f59d4ad38eb544df82638813847…
user-data extraido del volumen CONSTRUIDO     270c099680fab82f10854d3a7b188955…
imagen/autoinstall.yaml                       270c099680fab82f10854d3a7b188955…   <- iguales
user-data del volumen viejo                   f094083bf025029e62ae188453566de2…   <- el control los distingue
```

**Y el control que esta medición necesitaba**, porque arrancar con el volumen de
ayer habría dado el mismo verde sin medir nada: el `user-data` **sacado del
volumen construido** es byte a byte `imagen/autoinstall.yaml`, y la misma
comparación contra el YAML viejo dice que **no**. Los dos se diferencian en 7 261
bytes, que son los de la late-command del guion.

**La máquina y los tiempos**, del registro y no de la pantalla:

```
VM   encina-E2-2vias   UUID 2060C1BE-…-C383AEDF0F4A   MAC 76:CE:28:E7:F7:AA   .13
encendida            2026-08-10T21:54:33Z
testigo instalador   2026-08-10T22:01:24Z
testigo in-target    2026-08-10T22:01:25Z   uname=aarch64 id=0
testigo del seed     2026-08-10T22:03:03Z   <- 8 min 30 s, y nadie contesto nada
```

**El nombre de la máquina no identifica nada, y aquí se ve:** `hostname` dice
`encina-e2-completa`, que es el que fija el seed de E2 y el que llevan todas las
máquinas que salen de él. Lo que distingue a ésta son los testigos con fecha.

#### (c) El error de QEMU salió otra vez, y esta vez lo vio Jorge

**`QEMU error: drive…, #block561: Invalid argument`, dos veces durante la
instalación.** Es el defecto del **banco** de §4.23f —`discard=unmap` sobre el
fichero disperso que crea `dd … seek=40g` en APFS—, y sale en todas las VMs
fabricadas así. Se comprobó **donde se vería si hubiera hecho daño**, con su
control de que sabe leer otro contador:

```
/sys/fs/ext4/vda2/errors_count   -> 0        (control) warning_count -> 0
dmesg | grep -cE "I/O error|blk_update_request"  -> 0
```

**Lo que sí hay que decir sin maquillarlo:** el diálogo es de **UTM**, no del
invitado, y Jorge lo descartó con `OK`. O sea que **la ventana estuvo abierta y
alguien pulsó algo del anfitrión**. No es contestar una pantalla del instalador
—las etapas siguen siendo `done,loading` y el bloque 1 del verificador está en
verde—, pero la casilla de E2 dice «nadie la toca» y esto merece quedar escrito
tal cual, no dado por equivalente.

#### (d) Un control lateral que mordió, y conviene no volver a pagarlo

Antes de arrancar se comprobó que `Image` e `initrd` de `e2-medios` son los de
**esta** ISO. El `initrd` coincide byte a byte con `/casper/initrd`. **`Image`
no**, y eso parece un núcleo de otra imagen:

```
/casper/vmlinuz               000d59171b8e49f31f55c0d52123571c…   gzip
e2-medios/Image               a1586ff3cb7ced7c40dcb0aba5bf320e…   Linux kernel ARM64 boot executable
gunzip -c /casper/vmlinuz     a1586ff3cb7ced7c40dcb0aba5bf320e…   <- es el mismo
```

**`Image` ES el `vmlinuz` de esta ISO, descomprimido**, porque QEMU en aarch64
quiere el núcleo crudo. Sin descomprimir antes de comparar, la comprobación
habría dicho «no es de esta ISO» y habría sido falsa — la misma clase de trampa
que el PEM contra el DER de §4.20.

#### (e) Lo que esto cierra y lo que no

- **Cierra** el punto abierto de §4.23g: `imagen/autoinstall.yaml` sigue
  produciendo la misma máquina, y **la vía `CIDATA` del guion de las dos vías
  está medida**. Con §4.23a —que midió la vía `/cdrom`— el guion queda medido
  **por sus dos ramas**, que es lo que hacía falta antes de tocar la ISO.
- **No toca** E2 como incremento: sigue 6 de 6. Esto no es una casilla nueva, es
  el precedente de §4.19g aplicado a un cambio del guion.
- **No dice nada** del idioma del instalador, que es la novena casilla de E3.

---

### 4.25 E3 — La novena casilla: el instalador en el idioma del producto (2026-08-10)

**Qué se arregla y por qué es un defecto de la definición, no del producto.** Las
ocho casillas de §6ter.3 se cumplieron enteras y aun así la ISO recibía en inglés
a quien la instala (§4.23e). El arreglo estaba **leído** en el casper de la propia
ISO, y ahora está **hecho**: `locale=es_ES.UTF-8` en la línea del núcleo de
`boot/grub/grub.cfg`, con su precio pagado entero.

#### (a) El mecanismo, leído en el `initrd` de esta ISO y no supuesto

`scripts/casper-bottom/14locales`, sacado del `initrd` que viaja en la imagen:

```sh
# commandline
for x in $(cat /proc/cmdline); do
    case $x in
	locale=*)
	    locale=${x#locale=}
	    set_locale="true"
	    ;;
    esac
done
...
if [ "${set_locale}" ]; then
    LANG=$(grep "^${locale}" /root/usr/share/i18n/SUPPORTED | grep UTF-8 |sed -e 's, .*,,' -e q)
    printf 'LANG="%s"\n' "${LANG}" > /root/etc/default/locale
    printf '%s UTF-8\n' "${LANG}" > /root/etc/locale.gen
    chroot /root /usr/sbin/locale-gen --keep-existing
fi
```

**Tres cosas que decide esta lectura y que no se podían dar por hechas:**

1. **Recorre TODOS los tokens de `/proc/cmdline`**, así que la palabra vale a
   cualquier lado del `---`. Se pone **antes**, que es la ranura de casper.
2. **Escribe el `LANG` de la SESIÓN VIVA** y corre `locale-gen` dentro de ella:
   por eso afecta al instalador, que es lo que se quiere, y no a la máquina
   destino, que ya lo tenía del seed.
3. `grep "^es_ES.UTF-8"` sobre `SUPPORTED` casa con `es_ES.UTF-8 UTF-8`, así que
   la forma **con** `.UTF-8` es la correcta.

**Cómo se lee el casper sin arrancar nada**, porque costó un rodeo y está en
`SCRIPTS.md` (trampa 19): el `initrd` son **dos archivos pegados** —el primero
firmware sin comprimir, el segundo **zstd** en el desplazamiento 60952064—, y
`file` dice «ASCII cpio archive» de los dos.

#### (b) El precio, pagado y enseñado, que es la parte que se podía hacer mal

`imagen/fabricar-iso.sh` ya no solo añade. Modifica dos ficheros y **lo demuestra
sobre el medio entero**, no sobre los que le convienen:

```
== 5. el grub.cfg en espanol, y el md5sum.txt que lo cubre
[OK]    grub.cfg: locale=es_ES.UTF-8 en la linea del nucleo, y no cambia nada mas
[OK]    md5sum.txt: una linea rehecha (57150973… -> ea5f7d01…), las otras 265 intactas
== 10. el medio entero, fichero a fichero, contra la oficial
[OK]    leidas 501 entradas de la oficial y 507 de la nuestra
[OK]    seis ficheros anadidos, ni uno mas, y ninguno perdido
[OK]    modificados exactamente dos: /boot/grub/grub.cfg y /md5sum.txt
[OK]    control: con una huella saboteada, la comparacion la senala
== 11. la integridad del propio medio, contra el md5sum.txt NUEVO
[OK]    las 266 lineas de md5sum.txt cuadran con la ISO construida, la del grub.cfg incluida
[OK]    control: con el md5sum.txt OFICIAL falla exactamente una linea, la del grub.cfg
```

**El control de la línea 11 es el que convierte §4.21d de advertencia en
medición:** con el `md5sum.txt` oficial falla **exactamente una** línea, la del
`grub.cfg`. Eso es, byte a byte, la ISO que se entregaría si alguien editara el
menú y no rehiciera el índice. Ya no hay que creérselo.

**Y el medio se compara entero por LBA, sin extraer 3,4 GB:** `xorriso -find /
-type f -exec report_lba` da el desplazamiento y el tamaño de cada fichero, y el
md5 se calcula buscando dentro de la propia imagen. Una lectura por ISO.

```
la ISO que se entrega   encina-os-E3-es.iso   02ab929d0336eebc81f7e8a50c7f8d73…
                        reproducible: dos construcciones seguidas, misma huella
la anterior (ingles)    encina-os-E3.iso      0a1127f403b4d1ee3e6e03980795bd4e…
boot/grub/grub.cfg          linux	/casper/vmlinuz locale=es_ES.UTF-8  --- quiet splash console=tty0
bootaa64.efi / grubaa64.efi / mmaa64.efi      intactos, huella a huella
```

#### (c) Qué se daría por sano y qué por roto, escrito ANTES de arrancarla

**La casilla es `[OJOS]` y la declara Jorge: yo no veo la pantalla.**

| # | Qué se mira | Sano | Roto |
|---|---|---|---|
| 1 | **La casilla novena** | el instalador se ve **en español** desde la primera pantalla | en inglés: entonces el `locale=` de casper **no basta** para el instalador de escritorio, y el hallazgo es que la lectura de (a) era necesaria pero no suficiente |
| 2 | La ISO se basta sola | `debug.log` **sin `-append`** y con **dos unidades y ni una más** además del firmware: la ISO y el disco vacío | cualquier `-append`, o un tercer `-drive` — con un `CIDATA` olvidado la instalación saldría bien midiendo el seed equivocado (trampa 16) |
| 3 | La máquina que sale | `verificar-e2.sh --forma e3` como root: **36 correctas, 0 fallos**, y `REPO ELEGIDO -> /cdrom/encina-repo` | cualquier diferencia con §4.23d **es un hallazgo**, porque lo único que ha cambiado es el idioma del instalador: querría decir que el `locale=` tocó algo que no tenía que tocar |
| 4 | Las cinco pantallas | `telemetry` lista `confirm,done,identity,install,keyboard,network,storage,timezone` y **ni `locale` ni `source`** | que aparezca `locale`: querría decir que el `grub.cfg` ha vuelto interactiva una sección que el seed fija |

**Y el riesgo que se sabe y va escrito antes, no después:** que el instalador de
escritorio **no** lea el `LANG` de la sesión viva al arrancar. `14locales` deja
`/etc/default/locale` puesto, pero **quién lo lee no está medido**, y la primera
pantalla del instalador de Ubuntu es normalmente la del idioma — la que este
producto quita a propósito (§6ter.0). Si sale en inglés, la siguiente pregunta no
es «cambiar de sitio la palabra» sino **quién decide el idioma del instalador**, y
se contesta leyendo, como se ha contestado todo lo demás.

#### (d) LAS CUATRO SALIERON, Y LA NOVENA CASILLA SE MARCA

**`[OJOS]`, y lo declara Jorge: «El instalador se ve en español».** Yo no he visto
esa pantalla y así queda escrito. El riesgo de (c) **no se materializó**: el
`locale=` de casper basta para el instalador de escritorio.

| # | Predicción | Lo que salió |
|---|---|---|
| 1 | el instalador en español | **en español, declarado por Jorge** |
| 2 | la ISO se basta sola | `-append`: **0** · unidades: `edk2-aarch64-code.fd`, `efi_vars.fd`, `disco.img`, `encina-os-E3-es.iso` — **dos y ni una más**, guardado del `debug.log` del arranque de la instalación |
| 3 | la máquina que sale | **36 correctas, 0 fallos, 0 avisos, 0 omitidas**, y `CIDATA -> <no encontrado>` · `REPO ELEGIDO -> /cdrom/encina-repo` |
| 4 | las cinco pantallas | `telemetry` lista **ocho etapas y ninguna es `locale` ni `source`** |

```
"Stages": { "0":"keyboard", "137":"network", "139":"storage", "141":"identity",
            "162":"timezone", "164":"confirm", "166":"install", "561":"done" }
```

**La máquina, identificada por lo que deja escrito y no por su nombre:**

```
VM   encina-E3-iso-es   ISO 02ab929d…   MAC 76:CE:28:E7:F7:E5   .14
hostname                encina-QEMU-Virtual-Machine   <- lo eligio el instalador, no el seed
testigo instalador      2026-08-10T22:27:41Z
testigo in-target       2026-08-10T22:27:41Z   uname=aarch64 id=0
testigo del seed        2026-08-10T22:29:21Z
firefox 153.0.3~build1 sin epoch, langpack-es-ES, 1 icono de 25 aplicaciones visibles
los cuatro paquetes instalados, graphical.target activo, saludador vivo
```

**Y lo que la casilla 3 valía de más esta vez:** el `locale=` toca la **sesión
viva**, o sea el entorno donde corren las `late-commands`. Que la máquina salga
**idéntica** a la de §4.23d es la prueba de que el arreglo del idioma **no tocó
nada que no tuviera que tocar**.

#### (e) Cómo se midió una máquina que no tiene `ssh`, y es método

El seed de la entrega **no lleva servidor `ssh` a propósito**, así que no hay
manera de entrar desde el Mac. Lo que funcionó, y no depende del cortafuegos —que
es lo que hizo fracasar el canal de red en §4.22—: **un volumen FAT con el
verificador dentro, conectado DESPUÉS de la instalación**.

```
canal.img  (16 MiB, FAT, etiqueta CANAL)   9a845b758bc55bfcce72fdaca8aab379…
  v.sh  =  imagen/verificar-e2.sh          aa4c7952051768ffe47fae39ded68c35…

sudo mount /dev/vdb /mnt
sudo script -q -c "bash /mnt/v.sh --forma e3" /mnt/salida.txt
sudo cp /etc/encina-seed.log /mnt/seed.log ; sudo cp /var/log/installer/telemetry /mnt/tele.txt
sudo umount /mnt
```

**Se conecta después de instalar a propósito**, y por eso no toca la casilla de
«dos unidades y ni una más»: esa se cierra con el `debug.log` del arranque de la
instalación, que está guardado antes de que nada de esto ocurriera.

**Tres cosas que costaron un rodeo cada una** (van a `SCRIPTS.md`, trampa 20):

1. **Los códigos de teclado son DE POSICIÓN y el invitado tiene teclado
   español**, que es lo que eligió quien instaló. Con el mapa de EE.UU. de
   §4.22, `sudo mount /dev/vdb /mnt` llegó como **`sudo mount -dev-vdb -mnt`**:
   el código 53 es `/` en EE.UU. y `-` en España. **Se vio en pantalla, que es la
   regla**, y el mapa se rehízo con la distribución del invitado.
2. **`sh` es `dash`** y el verificador usa `set -o pipefail`:
   `/mnt/v.sh: 32: set: Illegal option -o pipefail`. Va con `bash`.
3. **`script -q -c` en vez de `>`**, y no por elegancia: el `>` en teclado
   español es `Shift` del código 86, la tecla que ni siquiera existe en el mapa
   de EE.UU. Menos signos raros que teclear, menos ocasiones de perder una
   pulsación.

#### (f) Lo que E3 sigue sin contestar

- **Qué pasa si alguien conecta un `CIDATA`** a esta ISO: por precedencia le
  ganaría al seed de dentro (§4.21c). Sigue sin probarse.
- **Secure Boot en hardware real**: el límite declarado de §4.21b, intacto.
- **Qué pasa si quien instala elige la instalación completa**: el seed fija
  `source`, así que no se puede elegir. Deja de ser una pregunta abierta.

---

### 4.26 E4 — La medición de apertura: qué le falta a la máquina que sale de la ISO (2026-08-11)

**El criterio general de §10 aplicado a E4**, antes de abrirlo y antes de tocar
`encina-meta`: *¿qué comando demuestra que este problema existe?* Para E4 la
pregunta es «qué le falta HOY a la máquina de la entrega para que alguien la
use», y se contesta sobre esa máquina, no sobre una lista de deseos. **La
respuesta es que E4 tiene caso, y el hueco grande no es el que parecía.**

#### (a) El instrumento, y el control que lo habilita — escrito ANTES de medir

La máquina de la entrega, `encina-E3-iso-es`, **no tiene `ssh`**: medirla cuesta
el procedimiento de §4.25e y la gasta como testigo de la novena casilla. Se midió
sobre **`encina-E2-2vias`** —que sí lo tiene— con **el control declarado por
adelantado**: su recuento de aplicaciones visibles tenía que dar **25**, el mismo
número escrito en §4.23d y §4.25d para las dos máquinas de E3, o el instrumento
quedaba rechazado.

**Las diferencias entre el instrumento y la máquina de la entrega, nombradas y no
supuestas** (leídas en los dos YAML): `imagen/autoinstall.yaml` e
`imagen/autoinstall-e3.yaml` fijan **los mismos** `locale: es_ES.UTF-8`,
`source: ubuntu-desktop-minimal`, `codecs: false`, `drivers: false` y **las mismas
tres `late-commands`**. El de E2 añade `identity`, `storage` y
`ssh: install-server: true`. O sea: **una sola diferencia en el conjunto
instalado, `openssh-server`, y no tiene `.desktop`.**

```
testigo del seed   encina-seed llego al final 2026-08-10T22:03:03Z   <- el de §4.24
VISIBLES = 25      FIREFOX = 1      (total con ocultas: 89)
control: dpkg-query de un paquete inventado -> "no se ha encontrado"
```

**El control se cumplió: 25 y 1.** El instrumento vale.

#### (b) Las 25 «aplicaciones de serie», que nadie había nombrado nunca

`Gio.AppInfo.get_all()` con `should_show()`, el mismo del bloque de iconos de
`imagen/verificar-e2.sh` — que **cuenta** las visibles como control y nunca las
**nombra**:

```
 1 Additional Drivers          10 Files                    19 Settings
 2 Advanced Network Config.    11 Firefox                  20 Software & Updates
 3 AutoFirma                   12 Fonts                    21 Software Updater
 4 Calculator                  13 Help                     22 Startup Applications
 5 Characters                  14 Image Viewer             23 System Monitor
 6 Clocks                      15 Language Support         24 Terminal
 7 Disk Usage Analyzer         16 Logs                     25 Text Editor
 8 Disks                       17 Passwords and Keys
 9 Document Viewer             18 Power Statistics
```

**Veinte de las veinticinco son utilidades del sistema.** Para el trabajo por el
que Encina OS existe hay cinco: Firefox, AutoFirma, Files, Document Viewer y
Text Editor.

#### (c) La cadena *recibir → abrir → firmar → guardar*, eslabón a eslabón

| Eslabón | Estado | La salida que lo dice |
|---|---|---|
| Recibir | cierra | Firefox |
| Abrir un PDF | cierra, **mal atado** | `application/pdf -> firefox.desktop`. **Evince está instalado y no es el manejador por defecto**: el producto trae un visor que nunca se abre |
| Abrir un ZIP | cierra | `application/zip -> org.gnome.Nautilus.desktop`, sin `file-roller` |
| **Abrir .odt / .doc / .docx / .xls / .csv** | **NO CIERRA** | `-> <NINGUNO>` en los cinco, y `libreoffice-core` ausente |
| Firmar | cierra | `autofirma 1.9.1+encina2` |
| Guardar / devolver | cierra | Firefox |
| Imprimir | cierra | `cups` **activo** (control: `dbus` también activo) y panel de impresoras en Settings |
| **Escanear** | **NO CIERRA** | `simple-scan` AUSENTE, con `sane-utils` instalado y sin nada que lo use |
| **Instalar cualquier otra cosa** | **NO CIERRA** | `gnome-software` AUSENTE · `snap` AUSENTE · `flatpak` AUSENTE · `apt` presente (control) |

**El control de todas las ausencias, sin el cual ninguna vale:** el mismo comando
devuelve presencia para lo que sí está (`firefox: install ok installed`;
`apt-get -s install nautilus` → 0 nuevos) y error para lo inventado
(`E: Unable to locate package paquete-que-no-existe-jamas`; `xdg-mime` de un tipo
falso → vacío). El inventario sabe decir «sí», así que su «no» significa algo.

**El veredicto de §10, con su comando:**

```
$ xdg-mime query default application/vnd.oasis.opendocument.text
                                              # <NINGUNO>
$ command -v gnome-software snap flatpak
                                              # los tres AUSENTES
```

**E4 no es una suposición.** Pero el hueco grande no es *qué aplicaciones*: es
que **la máquina no puede crecer**. Sin tienda, sin Snap y sin Flatpak, el único
camino para añadir algo es teclear `apt` en un terminal. Eso convierte la lista
de E4 en la entrega entera y no en un punto de partida.

#### (d) Cuánto cuesta cada candidato, y la trampa de §4.10h reproducida

`apt-get -s install` sobre el instrumento. **No se hizo `apt-get update`**: eso sí
habría modificado la máquina, así que los índices son los del 2026-08-10.

| Candidato | Paquetes nuevos | ¿Devuelve el Snap? |
|---|---|---|
| `file-roller` | 2 | no |
| `simple-scan` | 1 | no |
| `gnome-calendar` | 2 | no |
| `libreoffice-writer` solo | 46 | no |
| `writer + calc + l10n-es + help-es` | 54 | no |
| **`gnome-software`** | 4 | **SÍ — `Inst snapd 2.76+ubuntu24.04.1`** |
| `gnome-packagekit` | 3 | no |
| `synaptic` | 3 | no |
| `thunderbird` | 2 | **SÍ — `Inst snapd`** |
| `thunderbird-locale-es` | 3 | **SÍ — `Inst snapd`** |
| *control:* `nautilus`, ya instalado | 0 | — |
| *control:* paquete inexistente | 0, con `E:` | — |

**Dos hallazgos:**

1. **La tienda obvia reintroduce el Snap.** `gnome-software` en 24.04 arrastra
   `snapd`, o sea el motivo por el que este producto existe. Los índices solo
   ofrecen `gnome-software-plugin-flatpak` y `-plugin-snap`: **no existe
   `-plugin-deb`**. Las dos vías que no lo devuelven son `gnome-packagekit` y
   `synaptic`, tres paquetes cada una.
2. **El aviso de §4.10h deja de ser una cita y pasa a ser una medición de hoy:**
   `thunderbird-locale-es` mete `snapd`.

**Lo que esta tabla NO da:** los MB. `apt-get -s` no imprimió `Need to get` con la
caché en ese estado, y no se forzó porque no cambia ninguna decisión —lo que
decide es el recuento y la bandera de `snapd`—. El dato exacto es un comando el
día que se abra E4.

#### (e) EL HALLAZGO QUE NO ES DE E4: la entrega depende de la red, y en duro

Del registro del seed de la propia máquina, `/etc/encina-seed.log`, 1 917 líneas:

```
141 lineas Get:     36 de file:/srv/encina-repo (el medio)
                   100 de http://ports.ubuntu.com
                     5 de https://packages.mozilla.org
Get:1 https://packages.mozilla.org/apt … firefox arm64 153.0.3~build1 [76.4 MB]
Get:2 https://packages.mozilla.org/apt … firefox-l10n-es-es           [437 kB]
purge snapd rc=0 · update rc=0 · install encina-meta rc=0 · update rc=0
full-upgrade rc=0 · install firefox-l10n-es-es rc=0
control: el registro sabe ensenar rc distintos de 0 (lineas 556, 559, 561, 597)
```

**El navegador entero, 76,4 MB, bajó de la red.** Y `network` es **una de las
cinco secciones que contesta quien instala**.

**De ahí sale una deducción, y va marcada como deducción:** `encina-seed.sh`
**nunca sale distinto de 0** —por diseño (§4.16)— y §4.17f dice que sin el paso 6
no queda **ningún** Firefox. Luego **quien instale la ISO sin red se llevaría una
Encina OS sin navegador, y el instalador le diría que ha ido bien.** Es la familia
de la trampa 5: la misma respuesta en un sistema sano y en uno roto.

**No está medido.** El comando que lo demostraría es instalar la ISO contestando
«no» en la pantalla de red y leer el registro; cuesta una VM nueva. **Y si se
confirma es un defecto de la definición de terminado de E3, no de E4**, igual que
el instalador en inglés de §4.23e.

#### (f) Lo que NO se da por medido, y por qué

**Los nombres de las aplicaciones salieron en inglés en las tres combinaciones de
locale probadas**, con `LANG`, `LANGUAGE` y `LC_ALL`. Los datos:

```
88 de 91 .desktop de /usr/share/applications NO llevan Name[es]
  (los tres que si: autofirma, vim, xdg-desktop-portal-gtk)
delegan en X-Ubuntu-Gettext-Domain=<dominio>, y la traduccion EXISTE:
  gettext('Files') con el dominio nautilus -> "Archivos"
LANG del sistema: es_ES.UTF-8    locales generados: es_ES.utf8 (control: 25 en total)
check-language-support -l es -> vacio (control: --show-installed no esta mudo)
```

**No se da por roto.** El instrumento es una sesión `ssh`, y `SCRIPTS.md` avisa
exactamente de esto: una sesión `ssh` no es una sesión de escritorio. **Es
`[OJOS]`, cuesta una captura de pantalla**, y si sale en inglés es un defecto de
la misma familia que la novena casilla de E3.

#### (g) La foto de la máquina, para que se pueda comparar dentro de seis meses

```
disco                       9,4 GB de 39 GB
/srv/encina-repo            44 MB permanentes, con 'deb [trusted=yes] file:...'
fuentes de apt              encina-local.list, mozilla.sources, ubuntu.sources
                            + ubuntu.sources.curtin.orig   <- residuo del instalador
unattended-upgrades         PRESENTE      update-notifier PRESENTE
cups activo · gvfs · gvfs-backends · xdg-desktop-portal-gnome · evince   PRESENTES
file-roller · libreoffice-core · gnome-software · simple-scan            AUSENTES
```

#### (h) Y la pregunta que abrió Jorge al leer esto: ¿puede convivir el Snap?

**Sí, y no es una hipótesis: es el estado en el que se demostró E1.** La huella de
virginidad de §4.13 —la máquina donde salió la firma en `valide.redsara.es`— dice
`snap firefox: firefox 147.0.3-1 7764` y `perfiles Mozilla: los tres AUSENTES`.
**Quitar el Snap nunca fue condición de que la firma funcione**; la condición es
que el Firefox que se abre sea el nativo, y de eso se ocupa
`encina-firefox-native`, cuya sombra `NoDisplay=true` está medida **en los dos
mundos** (§4.19): con Snap presente, un solo icono y `firefox_firefox.desktop`
resolviendo a `/usr/bin/firefox %u`.

**La frontera no es `snapd`: son cuatro estados y no valen lo mismo.**

| Estado | ¿Medido? | Veredicto |
|---|---|---|
| **a.** sin `snapd` | sí — E2 6/6, E3 9/9 | lo de hoy |
| **b.** `snapd` sí, Snap de Firefox no | **no medido** | lo deseable a futuro |
| **c.** `snapd` + Snap de Firefox instalado y **nunca abierto** | sí — `encina-E1-meta` y la firma de §4.13 | **funciona** |
| **d.** `snapd` + Snap de Firefox **con perfil usado** | sí — §4.3, §4.4, A2 entero | **roto, y en silencio** |

**Lo que rompe es un Firefox de Snap que alguien abre**, por B3 —dentro del Snap
no ve `afirma.desktop` ni `/usr/bin/autofirma`, y no falla: *no hace nada*— y por
B4 —AutoFirma busca el certificado en el perfil del Snap—. En el estado (c) eso
no ocurre por accidente, y por un motivo medido: **el único icono de Firefox que
el usuario ve abre el nativo.**

**Y una delimitación de §4.16e, que no es una corrección:** aquella medición
concluye que la vía obvia —`snap remove --purge firefox`— «no sirve y encima dice
que sí», y sigue entera **para el seed**. Su causa está en la propia sección:
`curtin` bind-monta `/run`, así que el cliente del chroot le habló al demonio del
**entorno vivo del instalador** (`snap 2.76` del objetivo contra `snapd 2.73` del
instalador, en la misma orden). **Eso es un defecto del entorno de instalación, no
de la orden.** En una máquina ya arrancada, con su propio `snapd`, no tiene por
qué mentir — **y no está medido**, que es justo lo que separa el estado (b) de ser
alcanzable hoy.

~~**Lo que queda por medir antes de decidir la tienda, y es la puerta de (c):**~~
**CONTESTADA EL MISMO DÍA, y son tres preguntas: §4.29.** El vigilante sigue
acertando el nativo (1 s) **y** mete la CA también en el del Snap (2 s), así que
por ese lado (c) aguanta; lo que cambia el peso de la casilla es la tercera:
**AutoFirma busca el certificado en el perfil que se usó el último**, o sea que en
el estado (d) **vuelve B4** además de B3. **Y el banco declarado aquí estaba mal:**
`encina-E1-meta` lleva `+encina1`, sin vigilante; se midió sobre un duplicado con
`+encina2` instalado, y ella sigue intacta.

#### (i) La limpieza del banco, y la trampa que sacó

**Devueltos 25,35 GiB reales**, medidos con `df` antes y después, que es lo único
que no miente (§9.a).

```
libres antes            8,21 GiB
tras borrar los medios  8,65 GiB     <- 3,67 GB borrados, 0,44 GiB devueltos (!)
tras borrar las dos VMs 33,57 GiB
```

**LA TRAMPA, y es §9.a por un sitio nuevo: el directorio de medios miente igual
que las VMs.** Borrar `encina-os-E3.iso` de `e2-medios` devolvió 0,44 GiB de 3,4 GB
porque **el `Data/` de cada bundle tiene un clon de APFS de su ISO**. No son
enlaces duros —`stat` da **1 enlace** en todos, con su control— y no hay
instantáneas locales (`tmutil listlocalsnapshots /` → vacío). **Consecuencia
práctica: borrar un medio y borrar su VM no son dos ahorros, son uno.** Los 3,4 GB
llegaron con el bundle.

**Recibo de lo destruido, por huella:**

```
encina-os-E3.iso        0a1127f403b4d1ee…   la ISO inglesa, sustituida por 02ab929d…
seed-e3-forma.img       18a22ce8c2b76753…   el seed de §4.22, cuya VM ya no existia
seed-e2-0.2.1-pw.img    ebcda148a3f1fc3c…   el seed viejo; su control ya corrio en §4.24
seed-cidata.img         f5ecde113184f470…   §4.14
seed-cidata-snap.img    3fcddd266a4c3c54…   §4.16
VM encina-E3-iso        UUID EBC222AB-…     la maquina de §4.23
VM encina-E2-0.2.1      UUID D60D020A-…     la maquina de §4.19g
```

Lo que se queda, comprobado por huella y no por nombre: `02ab929d…`,
`c2610520…`, `13aa8f59…`, `9a845b75…`, `a1586ff3…`, y los ficheros de texto de
`e2-medios`, que son documentación y no ocupan nada.

**La condición que habilitó borrar `encina-E2-0.2.1`**, medida antes y no supuesta:
`encina-E2-2vias` es **virgen de Firefox**, así que hereda el papel de origen del
clon efímero de la firma (§9.1).

```
ausentes ~/.mozilla · ~/.config/mozilla · ~/snap · ~/.cache/mozilla
0 profiles.ini · 0 cert9.db · 0 .p12/.pfx
control: el find sabe encontrar algo (.bashrc -> 1) y sabe decir cero (inventado -> 0)
```

**Y la que NO se borró, con su motivo:** `encina-E2-sinsnap` se queda. Con 33,5 GiB
la vuelta de E4 está pagada de sobra, y al pasar a la convivencia (c) **todas las
máquinas nuevas tendrán Snap**: ésa y `encina-E2-2vias` serían las dos últimas sin
él, y la segunda tiene un papel que no se puede gastar. Lo irreversible no se hace
cuando no compra nada hoy. Es la siguiente candidata, y vale ~13 GB reales porque
lleva dentro su propio clon de la ISO oficial.

**El registro de UTM quedó consistente** (trampa 18): 9 en `utmctl list`, 9 bundles
en disco, cero fantasmas, con las dos entradas borradas por UUID y `plutil -lint`
en verde.

#### (j) Lo que esta medición NO contesta

- **Si la instalación sin red rompe la entrega.** Deducido en (e), no medido.
- **Si el usuario ve los nombres de las aplicaciones en español.** `[OJOS]`, (f).
- **Si el vigilante de AutoFirma acierta el perfil con los dos presentes.** Es la
  puerta de (c), y el banco es `encina-E1-meta`.
- **Los MB de cada candidato.** Solo hay recuentos de paquetes.
- **Nada de la ISO**: no se construyó ninguna y `02ab929d…` sigue siendo la
  entrega.

---

### 4.27 E3 — El agujero de red: la lectura, hecha antes de gastar la VM (2026-08-11)

**Es el paso 1 de los tres de `ENCINA-OS.md` §7**, y se hace como lo pedía §4.26e:
**por lectura primero**. Todo lo que sigue está escrito **antes de arrancar
ninguna VM**, no marca ninguna casilla y no cambia ningún documento de decisión.

#### (a) El instrumento de la lectura: el medio de la entrega, sin arrancarlo

Las dos ISOs, comprobadas por huella **antes** de leer nada:

```
02ab929d0336eebc81f7e8a50c7f8d73cb9b670d231f94a658dace6b4934104c  encina-os-E3-es.iso
c2610520bf582976839a1724c669e1cfed0547427be5a0ad12d457b92b46ffbe  ubuntu-24.04.4-desktop-arm64.iso
```

**El conjunto que instala la ISO está escrito dentro de ella.**
`casper/install-sources.yaml` declara `ubuntu-desktop-minimal` con
`path: minimal.squashfs` y ocho idiomas preinstalados, y cada capa lleva su
manifiesto. El conjunto real del objetivo es el de la mínima **menos** lo que
quita la capa de español:

```
casper/minimal.manifest      1484 paquetes  (diff contra vacio: todo '+')
casper/minimal.es.manifest     42 quitados  (de, fr, it, pt, ru, zh, ibus-*)
conjunto = 1442 lineas, 1439 nombres una vez quitada la coletilla ':arm64'
```

**El control del instrumento, sin el cual esto no vale nada:** el conjunto
derivado del medio tiene que reproducir **la foto de §4.26g**, que se midió sobre
la máquina ya instalada. **Doce nombres, doce aciertos:** `evince`, `gvfs`,
`gvfs-backends`, `xdg-desktop-portal-gnome`, `cups`, `unattended-upgrades`,
`update-notifier` y `sane-utils` **presentes**; `file-roller`, `libreoffice-core`,
`gnome-software` y `simple-scan` **ausentes**. Y dice `AUSENTE` de un nombre
inventado, así que sabe decir las dos cosas.

**Dos trampas del propio instrumento, y las dos estuvieron a punto de colar un
resultado falso:**

- **El manifiesto lleva la arquitectura pegada al nombre** (`libnss3:arm64`,
  `gvfs:arm64`). Comparando exacto, `gvfs` sale **AUSENTE**, que es falso — y se
  ve al instante **porque el control de §4.26g lo desmiente**. Hay que normalizar
  los dos lados. Familia de la trampa 3.
- **`grep` a través del hook de `rtk` resume la salida** —`1486 matches … +1461`—,
  así que una tubería `grep | sed | sort | comm` contó **31** paquetes en vez de
  1484 **sin avisar de nada**. Es §4.9d por un sitio nuevo: lo que ya valía para
  `git` vale para **cualquier lectura de datos**. Todo lo de aquí va con
  `/usr/bin/grep`.

#### (b) Lo primero ya estaba medido: al purgar `snapd` se va el navegador

§4.16g, literal: `The following packages will be REMOVED: firefox* snapd*`, y el
inventario de después da `[AUSENTE] /target/usr/bin/firefox` y `un firefox` en
dpkg. El `.deb` de transición **se purga con el Snap**, porque de él depende.

O sea: **el paso 1 del seed deja la máquina sin ningún Firefox**, haya red o no,
y desde ahí **el único navegador posible baja de `packages.mozilla.org`** (§4.17f).

#### (c) Y lo que la lectura añade: el agujero es más grande que «sin navegador»

`encina-meta` **no se puede instalar sin red**, y no por Firefox: por lo que
declara. Sus `Depends:` enfrentadas al conjunto del medio:

| Lo que se pide | ¿Está en el medio? |
|---|---|
| `encina-branding`, `encina-firefox-native`, `autofirma` | sí — viajan en `/cdrom/encina-repo` |
| `language-pack-es`, `language-pack-gnome-es` | **sí** (los trae la capa `minimal.es`) |
| `hunspell-es` | **NO** (sí `dictionaries-common` y `hunspell-en-us`) |
| `autofirma` → `openjdk-17-jre \| openjdk-21-jre \| java-runtime` | **NO — ninguno de los tres** |
| `autofirma` → `libnss3-tools` | **NO** (sí `libnss3`, que es otra cosa) |
| `autofirma` → `openssl`, `ca-certificates` | sí |

**Y no hay otra fuente offline.** El `pool/` del medio son **185 `.deb`** —núcleo,
GRUB, `build-essential`, herramientas de disco— y **ninguno** de los que faltan; y
el objetivo **no tiene fuente `cdrom`** en apt: sus tres fuentes son
`encina-local.list`, `mozilla.sources` y `ubuntu.sources` (§4.26g).

**Como apt es todo o nada, sin red no entra ni uno de los cuatro `.deb` de
Encina**, ni siquiera los que viajan en el medio. Y sin `encina-firefox-native` no
hay repositorio de Mozilla, así que el paso 6 ni siquiera tiene dónde buscar.

**La deducción de §4.26e se queda corta, y así queda escrita:** sin red la entrega
no es «Encina OS sin navegador», es **Ubuntu sin navegador** —sin AutoFirma, sin
branding y sin repositorio de Mozilla—, y **peor que la Ubuntu de la que salió**,
que al menos conservaba el Snap. **Sigue siendo deducción:** lo medido aquí es el
contenido del medio, no la máquina.

#### (d) Qué se dará por SANO y qué por ROTO — escrito ANTES de medir

Todo se lee en `/etc/encina-seed.log` de la máquina que salga, que es el dato que
la máquina deja escrito sola.

| Paso del seed | **ROTO** — lo que predice esta lectura | **SANO** — lo que la refutaría |
|---|---|---|
| §7 ¿hay red desde el chroot? | los dos `getent` fallan, **y el control del nombre inventado también** | alguno resuelve → **había red y la medición no vale**: se descarta y se repite |
| §5 purgar `snapd` | `REMOVED: firefox* snapd*` y `[AUSENTE] /target/usr/bin/firefox` | cualquier otra cosa |
| §8 `apt-get update` | `Err:` de `ports.ubuntu.com` y `W: Failed to fetch`, **con `rc=0`** | — *(es la predicción floja: podría salir 100; no cambia nada, porque el guion nunca sale distinto de 0)* |
| §9 `install encina-meta` | **`rc≠0` y ni un paquete instalado**: `Depends: openjdk-17-jre but it is not installable` —o `E: Failed to fetch`—, y los cuatro `dpkg-query` diciendo «no se ha encontrado» | los cuatro `install ok installed` → **(c) es falsa** y hay una fuente offline que no he sabido ver |
| §11 `full-upgrade` | `0 upgraded, 0 newly installed`, `rc=0` | que proponga algo |
| §12 `firefox-l10n-es-es` | `E: Unable to locate package`, `rc≠0` | que lo encuentre → había repo de Mozilla |
| final | el testigo `/etc/encina-e2-testigo-seed` **escrito**, y **el instalador termina bien y no avisa de nada** | el instalador avisa o falla → **no hay defecto que arreglar** |

**Y la máquina que salga, con `imagen/verificar-e2.sh --forma e3` como root:**

| | **ROTO** (predicho) | **SANO** |
|---|---|---|
| aplicaciones visibles | **23** — las 25 de §4.26b menos Firefox y AutoFirma | 25 |
| iconos de Firefox | **0** | 1 |
| los cuatro `.deb` de Encina | ninguno | los cuatro |
| fondo de pantalla y Plymouth | los de Ubuntu | los de Encina |

**El resultado que decide es el 23 con el instalador diciendo que fue bien**, que
es la familia de la trampa 5: la misma respuesta en un sistema sano y en uno roto.
**Si sale así, el defecto es de la definición de terminado de E3**, como el
instalador en inglés de §4.23e — no de E4.

#### (e) El control con red ya está pagado, y por qué la red se quita por hardware

El control positivo **existe y es sobre esta misma ISO**: §4.25d, `02ab929d…`, 36
correctas, 0 fallos, 25 visibles y 1 Firefox. **No hay que volver a instalarlo.**

Lo único que puede cambiar entre aquella máquina y ésta es la red, así que **hay
que quitarla de la VM, no contestar «no» en la pantalla de red**: la pantalla es
una preferencia del instalador y no garantiza que el objetivo se quede sin ruta,
y un resultado sano no distinguiría «no hay defecto» de «sí había red». El control
declarado por adelantado de que de verdad no la había son **los tres `getent` del
paso 7 del propio registro**, con su nombre inventado.

#### (f) El precio, dicho antes de arrancar nada

**El banco no ha cambiado** —9 VMs, todas paradas, 9 bundles en disco, sin
fantasmas (trampa 18)—, **pero el disco sí**: donde §4.26i dejó **33,57 GiB**
libres, hoy `df` da **22 GiB**. Se los ha llevado algo de fuera de este banco.

| Concepto | Precio |
|---|---|
| VM nueva desde `02ab929d…`, dos unidades y ni una más, **sin tarjeta de red** | ~10–11 GiB reales. **Cabe una; dos no** |
| Instalación contestando las cinco pantallas | ~11 min de instalación, y hay que pilotarla sin ojos |
| Leer el registro y verificar la máquina | **volumen FAT conectado después** (trampa 20), tecleado por códigos crudos con teclado español |
| Control con red | **0** — ya está medido en §4.25d sobre la misma ISO |

**Y no hay instrumento barato, y está leído, no supuesto:** `openssh-server`
**tampoco está en el medio**, así que una máquina instalada sin red no puede tener
`ssh` ni usando el seed de E2. El único canal es el volumen FAT de la trampa 20.

#### (g) Lo decidido, y lo que se ha hecho hoy: el nivel 1

**No se compra la confirmación: se compra el cierre.** La VM de (f) demostraría un
mecanismo que el medio ya prueba, y **el arreglo no cambia con su respuesta**, así
que se aplaza a la vuelta de E4 — donde la misma instalación mide el defecto **y**
su arreglo por el mismo precio. Decidido por Jorge el 2026-08-11.

**Y el defecto de fondo no es la red: es que el seed no sabía decir que no.** Su
cabecera lo lleva escrito desde §4.16 —*«NUNCA sale distinto de 0»*— y esa regla
**es del instrumento, no del producto**: se escribió para no quedarse sin datos
midiendo, y ha acabado dentro de la ISO que se entrega. Es la tercera vez que este
proyecto encuentra un criterio de validación disfrazado de producto (las otras
dos: lo desatendido de E2, y la contraseña de E3).

**Nivel 1, hecho el 2026-08-11 y sin gastar VM:** `imagen/encina-seed.sh` gana un
bloque 14 que **pregunta al objetivo qué ha quedado** —los cuatro `.deb`, `firefox`
y `firefox-l10n-es-es`, por `dpkg`, más la versión y el destino de
`/usr/bin/firefox`— y escribe el veredicto en **`/etc/encina-estado`**:

```
ENCINA_ESTADO=INCOMPLETO
ENCINA_FALTA=encina-meta encina-branding encina-firefox-native autofirma firefox firefox-l10n-es-es
ENCINA_FECHA=2026-08-11T18:05:47Z
```

Lleva **su control dentro**: pregunta además por un paquete inventado, y si el
comprobador dijera que lo tiene, el veredicto sale `INCOMPLETO` con
`comprobador-roto` — **se niega a certificar con un instrumento ciego**. Y el
testigo `/etc/encina-e2-testigo-seed` pasa a terminar en `estado=…`: «llegué al
final» era verdad y aun así no decía nada de la máquina.

**Probado en el Mac antes de meterlo en ninguna ISO**, con un `curtin` de mentira,
porque cada intento dentro de una VM cuesta una instalación entera:

| Escenario | Veredicto |
|---|---|
| los seis paquetes, `firefox` sin epoch y fuera de `/snap/` | `COMPLETO`, `FALTA` vacío |
| sin red: no entra ni uno | `INCOMPLETO` con los seis nombrados |
| todo instalado pero el navegador es el `1:1snap1` bajo `/snap/` | `INCOMPLETO`: `firefox-de-transicion firefox-dentro-de-snap` |
| **control:** un comprobador que dice que sí a todo | `INCOMPLETO`: `comprobador-roto` |

**`imagen/verificar-e2.sh` gana el bloque 6, que lo lee**, y distingue tres cosas
que no se pueden leer igual: veredicto `COMPLETO` → `[OK]`; veredicto
`INCOMPLETO` → `[FALLO]` con lo que falta; **fichero ausente** → `[FALLO]` si el
testigo dice `estado=` (o sea, lo instaló un seed que sí lo escribe) y `[OMIT]`
si no, porque **una máquina anterior a §4.27 no puede contestar y eso no es un
aprobado**. Probados los cuatro caminos, también en el Mac.

**Los dos YAML se rehicieron desde el guion** —`autoinstall.yaml` y
`autoinstall-e3.yaml`, con el formato exacto que produce `--actualizar-yaml`— y se
comprobaron por el camino de vuelta, que es el que no se puede fingir: **sacar el
base64 del YAML, decodificarlo y compararlo con `encina-seed.sh`**, idéntico en
los dos, con el control de que un byte de más rompe la comparación. La
`late-command` sigue siendo **la misma en los dos ficheros, byte a byte** (20 907
caracteres).

**Lo que NO se ha hecho, y se dice para que nadie lo dé por hecho:**

- **No se ha construido ninguna ISO.** La entrega sigue siendo `02ab929d…`, que es
  la única medida (§4.25) — **y sigue teniendo el agujero**. El medio que lleve
  este seed se fabrica y se mide en la vuelta de E4.
- **Nivel 2, sin decidir y es producto:** con `ESTADO=INCOMPLETO` la instalación
  **termina bien igual** y quien instala no se entera hasta que abre la máquina.
  Que falle a la vista es una línea —`[ "$ESTADO" = COMPLETO ] || exit 1`—, está
  escrita en el guion como comentario y **no** puesta: cambia una regla escrita, y
  **está sin medir qué hace subiquity con una `late-command` que falla al final**
  (si deja la máquina, si deja el registro dentro, y qué ve la persona).
- **Nivel 3, la cura de verdad:** que el medio lleve `openjdk-17-jre`,
  `libnss3-tools`, `hunspell-es`, `firefox` y `firefox-l10n-es-es` en
  `/cdrom/encina-repo`, que ya existe y ya está medido. **Va en la vuelta de E4**,
  porque E4 decide qué más lleva el medio y hacerlo dos veces es exactamente lo
  que prohíbe el criterio del precio de §10.

---

### 4.28 ¿Y si B3 se arreglara en AutoFirma en vez de en el navegador? (2026-08-11)

**La duda es de Jorge y está bien puesta**, porque las mediciones de este proyecto
la apoyaban a medias: §4.3 midió que **el almacén NSS del Snap es correcto** y
§4.4 que lo único que rompe el confinamiento es que Firefox **no ve
`afirma.desktop` ni `/usr/bin/autofirma`**. O sea que dentro del Snap el eslabón
roto **no es firmar: es arrancar**. Y el protocolo `afirma:` solo existe para
*lanzar* el programa — después la sede habla con él por un websocket a
`127.0.0.1`, que un snap con el plug `network` **sí puede** abrir. Luego la
pregunta era legítima: **si AutoFirma ya estuviera escuchando, ¿sobraría B3?**

**Contestada por lectura, sin VM y sin construir nada**, sobre las fuentes
ancladas del propio fork (`jmorenobl/clienteafirma`, tag **v1.9.1**, el mismo que
compila `construir-deb.sh`).

#### (a) La respuesta corta: NO, y no es por el confinamiento

**El puerto lo elige la página y se lo dice a la aplicación por la URI que el
Snap no puede entregar.** `autoscript.js:2424` pide tres puertos **al azar**:

```
autoscript.js:1955-1978  getRandomPorts()  -> TRES aleatorios unicos del rango
autoscript.js:1908,1911  DEFAULT_MIN_PORT = 49152 … MAX_PORT = 65535
autoscript.js:2469       "afirma://websocket?ports=" + portsLine + "&idsession=" + idSession
autoscript.js:2486-2492  waitAppAndProcessRequest -> solo prueba ESOS tres puertos
```

Y del lado de la aplicación, el puerto sale de ahí y de ningún otro sitio:
`ServiceInvocationManager.java:117`, `tryPorts(channelInfo.getPorts(), …)`, con
`channelInfo` construido al analizar la URI.

**Luego un AutoFirma residente es inalcanzable por construcción:** escuche donde
escuche, la página solo llama a tres puertos de **16 384**, elegidos después, y no
tiene forma de enterarse de cuál usa el que ya está vivo. La probabilidad de
acertar es **3/16384**, un 0,018 %. No es una barrera de seguridad ni de
confinamiento: es que **el canal se negocia por la vía que el Snap corta**.

**El control de que este código es el que corre de verdad**, y no una copia del
repositorio que la sede no sirva: la consola medida contra `valide.redsara.es`
(M11 de `encina-autofirma`) dijo *«Tratamos de conectar con el cliente a traves de
WebSockets en los puertos 65429,57281,55579»* — **tres** puertos, y **los tres**
dentro de 49152–65535. Coincide con `getRandomPorts` línea por línea.

#### (b) Y aunque el puerto se resolviera, la aplicación está hecha para morirse

```
AfirmaWebSocketServer.java:51        INITIAL_INACTIVITY_TIMEOUT = 30000  (30 s)
AfirmaWebSocketServer.java:126-129   onClose -> "Cerramos la aplicacion" -> halt(0)
ServiceInvocationManager.java:132-138 temporizador de 90 s -> halt(0)
```

Volverla residente **no es corregir un defecto: es cambiar el modelo de la
aplicación** —quitarle los dos temporizadores y el `halt(0)`—, y eso no lo acepta
nadie aguas arriba. Con D14 sobre la mesa, convertiría un puente temporal en una
**bifurcación permanente**, que es justo lo que D14 existe para evitar.

#### (c) Y hay un tercer motivo, que es de seguridad y va en contra

La versión 4 del protocolo **ata el socket a la página que lo pidió**:

```
AfirmaWebSocketServerV4Sup.java  exige que la peticion venga de 127.0.0.1
                                 y que traiga el idsession correcto… PERO:
   if (this.sessionId != null && !this.sessionId.equals(getSessionId(message)))
AfirmaWebSocketServerManager.java:79,84  new …(port, channelInfo.getIdSession(), …)
```

**Si el `idsession` es nulo, la comprobación se salta entera** — y en el servidor
de la versión 1 (`AfirmaWebSocketServer.java:146-157`) **no se comprueba nunca**:
responde `OK` a cualquier eco y pasa cualquier otra cosa a
`ProtocolInvocationLauncher.launch`. O sea que un AutoFirma residente lanzado sin
sesión **atendería a cualquier página local**. Hacerlo para servir al Snap sería
**debilitar justo la comprobación que upstream añadió**.

#### (d) Lo que sí queda contestado, y cambia el peso de una casilla

**B3 no tiene arreglo posible desde nuestro lado**, y ahora se sabe *por qué* y no
solo *que*. Las tres salidas que existen **son de otros**: que la sede fije el
rango de puertos (`setPortRange`, `autoscript.js:974`), que Firefox enrute los
esquemas desconocidos por el portal (Mozilla/Canonical), o que el Snap permita
lanzar manejadores del anfitrión (Canonical).

**Y de aquí sale lo que de verdad importa para E4:** con la tienda vuelve el Snap
de Firefox al alcance del usuario (D16), y **un usuario que abra ese Firefox y
firme fallará en silencio, sin que exista arreglo por nuestra parte**. Luego la
condición de D16 —*el Firefox que el usuario puede abrir es el nativo: un solo
icono*— **no es cosmética: es la defensa entera**. La casilla que sustituye a «Sin
Snap» no se puede aflojar ni un milímetro, y ahora tiene su motivo medido.

#### (e) Lo que esta lectura NO contesta

- **Si el vigilante de `+encina2` mete la CA también en el perfil del Snap**, y
  **de qué perfil lee AutoFirma el certificado con los dos presentes** —hoy lo fija
  el lanzador con `AFIRMA_NSS_PROFILES_INI` (M6), apuntando al nativo—. Son las dos
  patas que quedan de la puerta de la convivencia, y **se miden en el paso 2**,
  sobre un **duplicado** de `encina-E1-meta`: crear ahí un perfil de Snap la
  convierte en el estado (d) y gastaría el único testigo del estado (c) del banco.
- **Nada de la sede real:** se leyó el `autoscript.js` del repositorio, y el
  control de que coincide con lo servido es la consola de M11, no un diff.

---

### 4.29 LA PUERTA DE LA CONVIVENCIA (c), CONTESTADA — y la máquina que la tenía que contestar no llevaba el paquete (2026-08-11)

**Es el paso 2 de los tres de `ENCINA-OS.md` §7**, y son **tres preguntas**, no una
(§4.28e). Medido sobre un **duplicado** de `encina-E1-meta`, destruido al terminar:
crear ahí un perfil de Snap la pasaría al estado (d) y gastaría el único testigo
del estado (c) del banco.

**Las tres respuestas, en una línea cada una:**

| # | Pregunta | Respuesta |
|---|---|---|
| **1** | ¿la CA sigue llegando al perfil **nativo** con un perfil de Snap presente? | **Sí**, en **1 segundo** — pero **no por el mecanismo que lo garantizaba**, y eso es el hallazgo |
| **2** | ¿la mete **también** en el del Snap? | **Sí**, en **2 segundos**, con la misma huella. No es un defecto: es el bucle escrito a propósito |
| **3** | ¿de qué perfil lee AutoFirma con los dos presentes? | **Del que se usó el último**, y la regla es simétrica a propósito. Con el Snap usado el último, **AutoFirma va a buscar el certificado al perfil del Snap** |

**Y de la 3 sale lo que importa para E4:** en el estado (d) —alguien abre el
Firefox del Snap— **la barrera B4 vuelve**, y vuelve *aunque* el vigilante haya
hecho su trabajo perfectamente en los dos perfiles. No es un fallo del remedio de
M6: es su regla, cumpliéndose.

#### (a) Qué se daría por sano y qué por roto, escrito ANTES de medir

| # | SANO | ROTO |
|---|---|---|
| P0 | los cuatro paquetes, Snap `147.0.3-1` rev 7764, `.path` **`active`**; control: unidad inexistente → `inactive` rc=4 | otra cosa → **parar**, la premisa es falsa |
| Q1 | `SocketAutoFirma` en el nativo con **sha256 idéntico** al del paquete, sin reiniciar sesión | no llega, llega con otra huella, **o llega solo tras volver a entrar** — esto último cuenta como roto: nadie vuelve a entrar antes de firmar |
| Q2 | entra también, misma huella, y el nativo intacto | entra en el del Snap y **no** en el nativo; o falla y deja la unidad en rojo; o **crea** un `cert9.db` donde no lo había |
| Q3 | apunta al perfil realmente usado, y **cambia** si cambia el uso | no pasa ninguna `-DAFIRMA_NSS_PROFILES_INI` (manda `getProfilesIniPath()`, que por M6 mira el Snap primero) |

**Y la predicción escrita antes de arrancar, para que se pueda contrastar:** Q2 sí
(casi lectura); Q3 el del Snap; **Q1 la única dudosa, 60/40 a que sale bien *por
carambola*** y no por diseño. **Salió exactamente eso**, y el motivo estaba leído
de antemano: ver (e).

#### (b) LA PREMISA ERA FALSA: `encina-E1-meta` lleva `+encina1`, no `+encina2`

Lo primero que dijo P0, sobre el duplicado y sin mutar nada:

```
autofirma 1.9.1+encina1  install ok installed      <- no es la version por la que se pregunta
ficheros del paquete que casan con 'ca-mozilla'     : 0
/usr/lib/systemd/user/autofirma-ca-mozilla.{path,service} : no existen
/usr/share/autofirma/sincronizar-ca-mozilla.sh            : no existe
systemctl --user is-enabled autofirma-ca-mozilla.path -> not-found  rc=4
   CONTROL: el listado del paquete no esta mudo — 29 ficheros, y si encuentra /usr/bin/autofirma
```

**El vigilante no estaba desarmado: no existía.** `ENCINA-OS.md` §9 y §4.26h
declaran esa máquina *«el único sitio donde se puede contestar la puerta de (c)»*,
y **no lleva el paquete cuyo comportamiento se pregunta**. Nadie lo había mirado
porque su huella de identidad nombra los cuatro paquetes y la revisión del Snap,
**pero no la versión de `autofirma`**.

**Lo que sí se pudo salvar sin instalar nada, y es medición aparte:** el lanzador
`/usr/bin/autofirma` es **byte a byte el mismo** en las dos versiones, así que la
pregunta 3 no dependía de la premisa rota.

```
/usr/bin/autofirma instalado (+encina1) : 58b552940e46f0a5c87ffd69fe1d440f4477e8274fb485aa7185ead3851bf19c
/usr/bin/autofirma dentro del .deb de +encina2 : 58b552940e46f0a5c87ffd69fe1d440f4477e8274fb485aa7185ead3851bf19c
sincronizar-ca-mozilla.sh: solo viaja en +encina2
```

**Con permiso de Jorge se instaló `+encina2` en el duplicado desechable**, del
`.deb` `d5a0ebe1…` de `encina-autofirma/salida/` — **la misma huella que anotó
§4.13** como el artefacto con el que se marcó la casilla que decide.

**Y de paso, dos cosas que el banco daba por otras:** `encina-E1-meta` **no es
virgen de Firefox** —dos perfiles nativos, uno usado— y **su almacén NSS estaba
vacío**: ni un `SocketAutoFirma`, coherente con que el `postinst` de `+encina1`
corriera cuando no había perfil y con que nada lo arreglara después. Control del
apodo en verde (`Could not find cert`).

#### (c) EL DEFECTO QUE SALTÓ EN EL CONTROL, y no es del Snap: el configurador deja un almacén de ROOT en el perfil que nadie usa

El control de la fase 1 decía «`cert9.db` en todo el HOME tiene que seguir siendo
1». Salió **2**.

```
c2ace5tw.default/   cert9.db  key4.db  pkcs11.txt   -rw------- root root   22:26:43
marwtfna.default-release/  cert9.db                 -rw------- jorge jorge 22:26:43
```

**Lo hizo el configurador de AutoFirma**, que corre como **root** dentro del
`postinst`, y lo hizo sobre el perfil que `profiles.ini` marca `Default=1` **y que
nadie ha abierto nunca** —la trampa de §4.2a, por quinta vez—. Donde el almacén ya
existía lo actualizó conservando el dueño; donde no existía **lo creó, y nació de
root**. El vigilante **no puede haber sido**: exige `cert9.db` previo (línea 140 de
`sincronizar-ca-mozilla.sh`), que es justo la trampa «`certutil` crea lo que iba a
inspeccionar» escrita en §9.

**Y la consecuencia se ve en el registro, no se deduce:**

```
sincronizar-ca-mozilla.sh: AVISO: no se pudo instalar la CA del socket en …/c2ace5tw.default
autofirma-ca-mozilla.service: Failed with result 'exit-code'.
```

**El servicio del vigilante queda en rojo en TODAS las sesiones**, para siempre:
el bucle entra primero en ese perfil —va por orden alfabético—, `certutil` no
puede escribir un `cert9.db` de root, `FALLOS=1`, y el guion sale distinto de 0.
Se repitió en las cuatro sesiones medidas (22:26:43, 22:27:30, 22:28:52, 22:28:53).

**Lo que salva al producto, y por poco:** el bucle **no aborta** al fallar, así que
la CA sí entró en el perfil bueno. **Un servicio que falla y aun así funciona es
exactamente lo que esconde el siguiente fallo de verdad.**

**Cuándo aparece, y por qué no se había visto:** solo si `autofirma` se
(re)instala **después** de que Firefox se haya abierto alguna vez —actualización,
reinstalación o `dpkg-reconfigure`—. En el orden del producto —el paquete antes
que el navegador— el configurador no encuentra ningún perfil, no crea nada, y todo
lo hace el vigilante como usuario. **Va a `encina-autofirma`, no a esta puerta.**

**ARREGLADO EL MISMO DÍA, en `autofirma 1.9.1+encina3`** (M19 de
`encina-autofirma`) — **y de paso corrige este apartado, que se quedaba corto.**
Aquí se escribió que el defecto nace en el **paso 2** del `postinst`. Eran **tres
puertas**, y la que las une no se ve leyendo: **`certutil -D` también crea el
almacén** —sale con `rc=255` y *«could not find certificate»* y aun así deja
`cert9.db`, `key4.db` y `pkcs11.txt` detrás—, así que el paso 0 del `postinst` y
el `prerm`, que ejecutan `uninstall.sh`, hacían lo mismo por el camino de
**desinstalar**. Suprimir solo el paso 2 habría dejado el defecto vivo por el
lado que nadie mira, **y la limpieza habría parecido funcionar**. Las tres
suprimidas: un solo dueño, el vigilante, como el usuario. Y la segunda
consecuencia queda cerrada con su control —las comprobaciones nuevas sobre
`+encina2` dan `OK=55 FALLO=7`, y entre los siete está la frase literal de este
apartado: *«el vigilante sale con 1: la unidad quedaría en rojo para siempre»*—.

#### (d) Q2 — SÍ, y en dos segundos: el caso realista del producto

Perfil nativo existente y usado; aparece el del Snap porque el usuario abre ese
Firefox (`snap run firefox --headless`, el gesto sin pantalla de §4.18l; se mata
**por PID**, nunca por patrón, que es la trampa 12).

```
22:28:53  el Snap crea su perfil  fsw3is6c.default
22:28:54  autofirma: CA del socket instalada en /home/jorge/snap/…/fsw3is6c.default
```

| perfil | veredicto, POR HUELLA contra la CA del paquete (`22:2D:C0:31…`) |
|---|---|
| `.config/…/marwtfna.default-release` | **CA CORRECTA**, antes y después de aparecer el Snap |
| `snap/…/fsw3is6c.default` | **CA CORRECTA**, 2 s después de nacer |
| `.config/…/c2ace5tw.default` | sin `SocketAutoFirma` — es el almacén de root de (c) |

Es lo que dice el guion en sus propias líneas 33-35: *«se miran todas, no la
primera que exista, que era justo el fallo que aquel parche corrige»*. Los
ficheros del perfil del Snap son `jorge:jorge` —viven en `~/snap`, fuera del
confinamiento— así que `certutil` del anfitrión escribe en ellos sin problema.

**Y no reabre B3:** la CA del socket en el perfil del Snap no le da a ese Firefox
ninguna forma de lanzar AutoFirma (§4.28a). No estorba y no arregla nada.

#### (e) Q1 — SÍ, en un segundo, pero la garantía es más fina de lo que parecía

Medido en su versión **difícil**, que es la que puede fallar: usuario **virgen**
creado a propósito, **perfil del Snap PRIMERO y nativo DESPUÉS**. El orden
contrario se contesta solo —nada quita una CA cuya huella ya es la correcta—.

```
22:31:29  sesion nueva, vigilante active     (control: unidad inexistente -> rc=4)
22:31:31  CA instalada en snap/…/r1scr4ly.default
22:31:56  se lanza el Firefox NATIVO
22:31:57  CA instalada en .config/…/llzoicsk.default-release   <- UN SEGUNDO
```

Y a los 60 s, a los 120 s y tras cerrar el navegador, los dos perfiles siguen con
la CA correcta por huella.

**Lo que hay debajo, leído ANTES de medir y confirmado por el reloj.** El guion
espera hasta 90 s a que nazca el almacén NSS porque `inotify` no es recursivo y
`cert9.db` está un nivel por debajo de lo vigilado (M15 F). Pero `hay_perfiles()`
mira **las tres raíces**: con un perfil de Snap presente devuelve verdad y **la
espera se salta entera**. Se ve en el reloj: el disparo de las `22:31:56` terminó
**en el mismo segundo** en vez de esperar; si no hubiera habido perfil de Snap
habría esperado hasta 90 s.

**Entonces, ¿por qué funcionó?** Porque `PathChanged` se rearma por flanco y
Firefox escribe **varias veces** en la raíz vigilada al nacer un perfil
—`profiles.ini`, `installs.ini`, `Crash Reports`, `Pending Pings`, `Profile
Groups`—, así que **hubo un flanco posterior a la creación de `cert9.db`**. O sea:
**el mecanismo que garantizaba esto está neutralizado por la presencia del Snap, y
lo que queda es una carambola con muchas oportunidades.** No falla hoy y no hay
que tocarlo hoy; pero **la casilla que diga «la CA llega sola» ya no puede
apoyarse en la espera de 90 s** en una máquina con Snap.

**Y `+encina3` NO cierra esto, aunque lo parezca. Escrito aquí para que nadie lo
dé por cerrado leyendo el título de M19(g).** Aquella medición encontró el mismo
síntoma por otra causa —`hay_perfiles()` daba verdad con el almacén de **root**
delante— y lo arregló exigiendo que el `cert9.db` **sea del usuario**. Eso mata el
caso del almacén **ajeno**, no el de **otra raíz**: el `cert9.db` del perfil del
Snap **es del usuario**, medido en (d) —`-rw------- 1 jorge jorge`—, así que con
un perfil de Snap presente `hay_perfiles()` sigue dando verdad **desde otra
raíz** y la espera se sigue saltando justo cuando nace el perfil nativo. **Ajeno
≠ de otra raíz.**

~~**La forma del arreglo, si alguna vez se hace:**~~ **HECHO EL 2026-08-12, en
`autofirma 1.9.1+encina4`** (M20 de `encina-autofirma`), y **se hizo porque la
medición dijo que sale barato, no porque lo pareciera.** La espera es ahora **por
raíz**, y este apartado queda cerrado con tres números que no eran míos:

```
sin raiz de Snap delante (control)   8044 ms   CA en el perfil nativo: 1
con almacen de Snap delante          21 ms     CA en el perfil nativo: 0   <- esto era 4.29e
con +encina4                         8080 ms   CA en el perfil nativo: 1   por huella
```

**8044 ms contra 21 ms es este apartado entero**, y es la primera vez que el
defecto se ve **fallar**: aquí ganó la carrera por un flanco tardío, y en
contenedor, sin ese flanco, se pierde.

**Y lo que yo no había previsto, que es lo que hacía peligroso el arreglo:**
esperar por raíz **a secas** habría sido peor que el defecto —una raíz fantasma
cuesta **20153 ms** en cada disparo—. Lo que lo hace barato no es la espera sino
**una ventana**: `AUTOFIRMA_VENTANA_RAIZ=30`, y el 30 **está medido y no
elegido** —1 s del nacimiento de la raíz a que exista `cert9.db` con el Firefox
nativo, 2 s en M18, 1 s en §4.29e: quince veces el peor de los tres—. Con la
ventana, la raíz fantasma vuelve a costar 21 ms y el peor caso son 30 s, no 90.

**Lo que sigue SIN medir, y es justo el escenario de este apartado:** todo eso
está hecho **en contenedor**. **Nadie ha visto a `+encina4` funcionando en una
máquina con un Snap de Firefox de verdad** — eso es esta sección, y va con VM.
Lo que cambia para la casilla de E4 es de dónde cuelga la afirmación: «la CA
llega sola» vuelve a apoyarse en el mecanismo de M15(F) **y no en la carambola
de flancos**, pero apoyarse en un mecanismo medido en contenedor no es lo mismo
que haberlo visto en el estado (c).

#### (f) Q3 — el que se usó el último, y la prueba discrimina en tres direcciones

Método **C1 de M6**: suplantar el `java` que el lanzador elige —`mount --bind`
sobre `/usr/lib/jvm/java-17-openjdk-arm64/bin/java`— y leer su **línea de órdenes
real**. No vale leer el guion: hay que ejecutar el fichero instalado. Con el
control de la trampa 13: **la suplantación se verifica antes de leer nada**
(`JAVA-ESPIA-MARCA`), y al terminar se restaura y se comprueba por huella
(`980ca04e…` antes y después, y `java -version` responde).

| caso | último uso | lo que el lanzador le dice a AutoFirma |
|---|---|---|
| **jorge** | el **Snap** (22:28) frente al nativo (2026-08-08) | `-DAFIRMA_NSS_PROFILES_INI=/home/jorge/snap/firefox/common/.mozilla/firefox/profiles.ini` |
| **convivb** | el **nativo** (22:31:56) frente al Snap (22:31:29) | `-DAFIRMA_NSS_PROFILES_INI=/home/convivb/.config/mozilla/firefox/profiles.ini` |
| **convivsin** | **ningún perfil** (control) | **ninguna variable** — manda `getProfilesIniPath()`, que por M6 mira el Snap primero |

**Las tres salidas posibles, medidas.** Y la del medio es la que convierte esto en
una medición y no en una anécdota: **la respuesta cambia cuando cambia el uso**, o
sea que el daño **no es permanente**, sigue al último navegador abierto.

#### (g) La consecuencia, hecha concreta con un certificado de PRUEBA

Con `CERT-PRUEBA-ENCINA` generado en la propia máquina —nunca el personal, §9.1—
e importado **solo** en el perfil nativo, que es donde lo tendría una persona que
usa el Firefox de Encina:

```
[1] perfil NATIVO (donde esta el certificado)   SocketAutoFirma C,,   CERT-PRUEBA-ENCINA u,u,u
[2] perfil del SNAP                             SocketAutoFirma C,,   (y nada mas)
[3] a donde manda el lanzador a AutoFirma       al profiles.ini del SNAP
[4] buscar el certificado alli   -> certutil: Could not find cert: CERT-PRUEBA-ENCINA
[5] buscarlo en el otro          -> Certificate: Data: Version: 3 (0x2)   <- esta
```

**Eso es B4, viva, en el escenario exacto que abre D16.** Y encadena con §4.28d:
el que abra el Firefox del Snap y firme **falla en silencio por B3**; y el que lo
abra, lo cierre y firme **desde el nativo** puede fallar además por B4, porque
AutoFirma seguirá mirando al perfil del Snap hasta que el nativo vuelva a ser el
último usado. **La condición de D16 —«el Firefox que el usuario puede abrir es el
nativo: un solo icono»— sale de aquí reforzada y con una razón más.**

#### (h) El coste, medido y no predicho

```
libres antes de duplicar     23,092 GiB
tras duplicar                23,093 GiB   <- el clon de APFS cuesta CERO (9.a)
antes de destruir            22,123 GiB   <- 0,970 GiB de divergencia en toda la sesion
tras destruir                23,046 GiB   <- DEVUELTOS 0,923 GiB
neto de la sesion            -0,046 GiB
du del bundle: 9,2 GB        <- la mentira de 9.a, por diez
```

Una sola VM encendida en todo momento; `encina-E1-meta` **no se arrancó**, solo se
leyó su bundle para duplicar. Ninguna ISO, ningún seed, ninguna casilla marcada.
El registro de UTM quedó consistente por las dos mitades (trampa 18): **9 en
`utmctl list` y 9 bundles en disco**, sin entrada fantasma, `plutil -lint` en
verde y el `plist` respaldado **antes** de borrar.

**Y una corrección a la trampa 21:** dice que `utmctl` no sabe borrar. **Esta
versión sí**: `utmctl delete <uuid>` existe, borra el bundle y limpia el registro
—comprobado por las dos mitades—. El procedimiento manual sigue valiendo, pero ya
no es obligatorio.

#### (i) Tres tropiezos del instrumento, y se dicen en vez de callarse

1. **Un `ls A B` con dos comodines devuelve error si el segundo no existe**, así
   que el bucle que esperaba el almacén nativo no lo detectó y anunció «tras 90 s»
   cuando el registro del sistema dice que la CA entró a **1 segundo**. No estropeó
   nada **porque el dato bueno es el que la máquina deja escrito sola** —el
   `journal`—, que es la conclusión de método de `SCRIPTS.md`; pero si la conclusión
   se hubiera sacado de mi contador, habría sido falsa por 89 segundos.
2. **`rc=$?` después de un `| head`** mide la tubería, no el `certutil`: imprimió
   `rc=0` donde el mensaje decía `Could not find cert`. Lo que discrimina es el
   mensaje, no el número que puse al lado.
3. **Un `for` sobre `/home/convivb/*/` ejecutado como `jorge`** no lista nada
   —permisos— y deja un apartado mudo sin decir que está mudo. Los `mtime` de ese
   usuario están en la salida de la fase 3, no en la de la fase 4.

#### (j) Lo que esta medición NO contesta

- **Si una firma real sale o falla** en el estado (d). Eso es certificado personal,
  clon efímero y ojos (§9.1), y no se ha hecho aquí.
- **El estado (b)** —`snapd` sí, Snap de Firefox no—, que sigue sin medir.
- **Si el defecto de (c) se reproduce en una instalación limpia del producto**:
  aquí salió sobre una máquina que ya tenía perfiles y a la que se le instaló el
  paquete encima. Deducido que en el orden del producto no ocurre; no medido.
- **Nada de la sede**, nada de la tienda, y **ninguna casilla de E2 tocada**: la de
  «Sin Snap» de `AGENTS.md` §6bis.3 se sustituye el día de la vuelta de E4.

#### (k) Estado de las máquinas

`encina-E1-conviv-efimera` —duplicado de `encina-E1-meta`, testigo
`/etc/encina-conviv-testigo` de las `22:21:36`— **destruida**. Llevaba dentro un
certificado de prueba, nunca el personal. **`encina-E1-meta` sigue parada, intacta
y en el estado (c)**, y sigue siendo la más valiosa del banco — pero **con
`+encina1` dentro**, que es lo que hay que corregir en su fila.

---

### 4.30 La limpieza del banco, y los dos extremos de la mentira de `du` medidos el mismo día (2026-08-11)

**Borrada `encina-E2-sinsnap`, y devolvió 12,923 GiB reales.** Es la primera
limpieza que se hace **para pagar algo concreto**: la vuelta de E4 cuesta ~22 GB
(§4.26) y quedaban 23,06 GiB, o sea que cabía **sin ningún margen**.

```
libres antes    23,062 GiB
libres despues  35,985 GiB
DEVUELTOS       12,923 GiB
```

#### (a) Por qué esa y no otra, y por qué las otras ocho no se tocan

**Su papel lo gastó D16.** Era «la primera máquina de Encina OS sin Snap», y con
la convivencia (c) **todas las máquinas nuevas llevan Snap**: ya estaba declarada
«siguiente candidata» en §4.26i, y lo único que la salvaba entonces era que
borrarla no compraba nada. Hoy compra el margen de E4.

**Y las que no se tocan, con su motivo, que no es sentimental:**

- **La familia de E1 no devuelve espacio si no se va entera** (§9.a), y dentro hay
  dos que no son testigos sino **herramientas**: `encina-dev`, que es **la máquina
  de construir** —`dpkg-scanpackages` no existe en macOS y rehacer el seed lo
  exige (`SCRIPTS.md`)—, y `encina-E1-meta`, el único sitio con Snap **y** los
  paquetes de Encina, que es donde se comprueba que algo no reabre A2 en el mundo
  al que vuelve D16.
- **`encina-E1-vigilante`, `encina-autofirma-rota` y `encina-snap-fabrica`
  devuelven ~0 GB**, así que se aplica la regla de §4.26i: *lo irreversible no se
  hace cuando no compra nada hoy*. Borrarlas compra tres filas menos, no espacio.

#### (b) Los dos extremos de `du`, el mismo día y en el mismo disco

Es lo que convierte §9.a de aviso en tabla:

```
clon de la familia de E1 (§4.29h)   du 9,2 GB  ->  0,923 GiB   miente por DIEZ
independiente, nacida de la ISO     du  13 GB  -> 12,923 GiB   aqui du acierta
```

**`du` no miente siempre: miente sobre los clones.** La pregunta antes de una
limpieza no es «¿cuánto ocupa?» sino **«¿de quién es clon?»**.

#### (c) La condición que se puso ANTES de borrar, y lo que destapó

Comprobar **por huella** que lo que la VM lleva dentro vive también en `e2-medios`:

```
ubuntu-24.04.4-desktop-arm64.iso   c2610520…  en el bundle  ==  en e2-medios
Image                              a1586ff3…  en el bundle  ==  en e2-medios
encina-os-E3-es.iso                02ab929d…  intacta despues de borrar  <- LA ENTREGA
```

**Y destapó una inexactitud del recibo de §4.26i:** el seed `3fcddd26…` figura allí
en la lista de *«lo destruido»*, y **sobrevivía una copia dentro de este bundle**.
Es la trampa 21 por un tercer sitio: **lo que un bundle lleva dentro no es lo que
uno cree que borró**. Se fue con la VM —su medición (§4.16) está escrita entera y
lo sustituye `13aa8f59…`—, pero la lección es de método: **un recibo de destrucción
solo vale si se comprueba dónde más vive ese fichero.**

#### (d) Dos notas de laboratorio

1. **`utmctl delete` limpia el registro, pero no en el mismo instante.** La primera
   lectura del `plist` justo después dio la entrada **todavía presente**; segundos
   más tarde ya no estaba. UTM vuelca sus preferencias con retraso, así que el
   control de la trampa 18 **se lee después, no a la vez**, o se lee un fantasma
   que no existe.
2. **El control de las dos mitades quedó en verde:** 8 en `utmctl list`, 8 bundles
   en disco, cero entradas de más en el registro, `plutil -lint` OK, y el `plist`
   respaldado **antes** de borrar.

#### (e) El punto de entrada, que no es una VM

Las tres máquinas nacidas de la ISO son **una caché**, no un activo: renacen del
medio y del seed en **8–11 minutos**, medido tres veces (8m30s, 10m07s, 10m43s).
Lo que hay que conservar es lo que ya está conservado y versionado por huella:
`encina-os-E3-es.iso` (`02ab929d…`), la ISO oficial (`c2610520…`) y
`seed-e2-2vias.img` (`13aa8f59…`). **De ahí sale la regla: toda máquina nueva del
banco nace de la ISO y del seed, no de un clon** — que además desactiva la trampa
14, porque las ocho de E1 contestan todas en `192.168.64.3` llamándose `encina-dev`.

**Y el aviso que deja §4.29 y que ninguna limpieza arregla:** el problema del banco
no es cuántas VMs hay, **es que una fila mintió durante un día**. Lo que lo arregla
es que cada fila lleve su huella de identidad **completa**, con la versión de cada
paquete de Encina dentro.

---

### 4.31 E4 — LA VUELTA ENTERA: el Snap vuelve declarado, y tres «arreglos» resultan ser otra cosa (2026-08-12)

**Es el paso 3 de los tres de `ENCINA-OS.md` §7, y el precio es por vuelta**, así
que en la misma van la convivencia (c) de D16, las aplicaciones de D17 y D18, el
manejador del PDF, el `.deb` `+encina4`, el verificador reescrito, el `--yaml` y
los niveles 2 y 3 de §4.27.

**Lo que hay que llevarse, en cuatro líneas y antes del detalle:**

1. **La casilla «Sin Snap» se sustituye y sale más exigente**, no más floja.
2. **Tres cosas que parecían arreglos eran otra cosa.** El manejador del PDF
   estaba *medido* mal, no roto (el instrumento era una sesión `ssh`); el
   `--yaml` ya estaba hecho y el documento no se había enterado; y `sane-airscan`
   no lo arrastra `simple-scan` **pero ya viajaba en el medio**.
3. **La mina de `AGENTS.md` §6.2 era real y estaba donde decía.**
4. **El nivel 2 se pudo poner porque se leyó qué hace `subiquity`**, no porque se
   supusiera.

#### (a) El precio, dicho ANTES de arrancar nada

```
df -k /       37 512 372 KiB libres = 35,775 GiB     utmctl list -> 8 VMs, las 8 paradas
```

| Concepto | Precio declarado |
|---|---|
| ISO nueva en `e2-medios` (3,4 GB + los `.deb` del nivel 3) | ~3,7–3,9 GB |
| Volumen `CIDATA` nuevo | hasta 0,75 GiB (con el nivel 3 no cabe en los 128 MiB de siempre) |
| `encina-dev` encendida para construir | ~0,5 GiB |
| **Instalación 1** — forma E2, con red, desatendida: el banco de E4 | ~10–11 GiB |
| **Instalación 2** — forma E3, **sin red**, desde la ISO nueva: el nivel 3 | ~10–11 GiB |
| **Total declarado** | **~26–27 GiB** |

El retorno se mide con `df` al terminar, no se predice (§9.a).

#### (b) El orden, que es lo que abarata esto, y no es opcional

**Primero se escribe todo —seed, verificador, `encina-meta`, `encina-branding`,
el manejador— sin arrancar nada; solo entonces se instala.** Una instalación
medida entera vale por diez comprobaciones a mano, y dos vueltas cuestan el doble
que una. La única máquina que se enciende antes de instalar es `encina-dev`,
**porque es la de construir**: `dpkg-scanpackages` no existe en macOS.

**Y su huella de identidad, tomada antes de tocar nada** (trampa 14: ocho
máquinas contestan en `192.168.64.3` llamándose `encina-dev`):

```
hostname encina-dev · usuario jorge · ningun paquete de Encina salvo encina-branding
snap firefox 153.0.3-1 rev 8735       <- la revision que la separa de encina-E1-meta (7764)
sin ~/.mozilla ni ~/.config/mozilla
```

#### (c) LA LECTURA QUE DECIDE EL NIVEL 2: qué hace `subiquity` con una `late-command` que falla

§4.27 dejó el nivel 2 sin decidir con dos motivos, y uno era *«está sin medir qué
hace subiquity con una late-command que falla al final»*. **Se contesta leyendo el
código que viaja dentro de la propia ISO**, como se contestó lo del clic en §4.16a
—`unsquashfs` de `casper/minimal.standard.live.squashfs`, de ahí el snap
`ubuntu-desktop-bootstrap_495.snap`, y de ahí `bin/subiquity/`—:

```
cmdlist.py:50-61        CmdListController.cmd_check = True
                        LateController NO lo cambia; ErrorController SI (cmd_check = False)
                        -> arun_command(..., check=True) LANZA si la orden sale != 0
install.py:628-639      Late.run() va DESPUES de curtin_install() y de postinstall();
                        la excepcion se recoge, se escribe un apport INSTALL_FAIL
                        con el texto "install failed", y se relanza
server.py:487 y 513     el manejador de ultimo nivel pone ApplicationState.ERROR
                        en las DOS formas: interactiva (E3) y no interactiva (E2)
installprogress.py:189  ERROR -> "An error occurred during installation", con
                        "Reboot Now" habilitado
```

**Las tres consecuencias, y son las que permiten poner la línea:**

1. **Se ve**, que es exactamente lo que pedía el nivel 2.
2. **La máquina sigue ahí y arranca**: el fallo ocurre *después* de instalar y de
   `postinstall`, o sea con el disco hecho y el GRUB puesto.
3. **El registro sobrevive dentro.** Por eso el orden del guion no es casual: el
   log, `/etc/encina-estado` y el testigo se escriben **antes** de la línea, para
   que quien arranque la máquina pueda leer *qué* falta.

Así que `imagen/encina-seed.sh` termina desde hoy en
`[ "$ESTADO" = COMPLETO ] || exit 1`, y la regla *«nunca sale distinto de 0»*
—que era del instrumento y se había colado en el producto— queda retirada con su
motivo. **Lo que sigue sin medirse, y se dice: no se ha visto esa pantalla con los
ojos.** Lo leído es el código de esta ISO, no una captura.

**Y de propina, un discriminador gratis para la forma E2:** una instalación
desatendida con `-no-reboot` **se apaga sola** cuando termina bien. Si el seed
sale 1, `subiquity` va a ERROR y **no apaga**. O sea que *«la VM se apagó sola»*
pasa a significar `ESTADO=COMPLETO`, sin abrir nada.

#### (d) EL MANEJADOR DEL PDF: la mitad «antes» de §4.26c era del INSTRUMENTO, no del producto

D17 daba por hecho que `application/pdf` resolvía a `firefox.desktop` con Evince
instalado. **Es verdad, y solo por `ssh`.** Reproducido en un árbol sintético en
`/tmp` de `encina-dev` —sin mutar nada— con el `firefox.desktop` de Mozilla
delante en las cuatro pasadas:

```
                                        sin XDG_CURRENT_DESKTOP    con ubuntu:GNOME
sin ningun fichero nuestro (el ANTES)   firefox.desktop            org.gnome.Evince.desktop
con /etc/xdg/ubuntu-mimeapps.list       firefox.desktop            org.gnome.Evince.desktop
con /etc/xdg/mimeapps.list (GENERICO)   org.gnome.Evince.desktop   org.gnome.Evince.desktop
```

**El control que lo convierte en medición y no en anécdota:** con el mismo
fichero genérico diciendo `application/pdf=firefox.desktop`, las dos columnas
pasan a `firefox.desktop`. La prueba **sabe dar las dos respuestas**, así que lo
que manda es el fichero y no otra cosa.

Tres cosas se leen ahí:

1. **En una sesión de escritorio de verdad ya ganaba Evince**, porque
   `/usr/share/applications/gnome-mimeapps.list` —de `gnome-session-common`, leído
   con `dpkg -S`— trae `application/pdf=org.gnome.Evince.desktop` en `[Default
   Applications]`, y está en el conjunto del medio. **El defecto era más pequeño
   de lo que parecía**, y es la familia de §4.26f: *una sesión `ssh` no es una
   sesión de escritorio*.
2. **Pero los ficheros con nombre de escritorio delante solo se leen si el
   escritorio se llama así.** Sin `XDG_CURRENT_DESKTOP` no se mira
   `gnome-mimeapps.list` y manda la asociación declarada en los `.desktop` — y el
   de Mozilla declara `MimeType=…;application/pdf;…` (leído del `.deb`
   `411b2a57…`, cuyos scripts de mantenedor **no tocan ninguna asociación**: solo
   `update-alternatives` de `x-www-browser`).
3. **Por eso el fichero que se pone es el genérico `/etc/xdg/mimeapps.list`** y no
   un `ubuntu-mimeapps.list`, que tendría exactamente el mismo agujero. Vive en
   `$XDG_CONFIG_DIRS`, que la especificación mira antes que todo
   `$XDG_DATA_DIRS`, así que **la respuesta es la misma se pregunte como se
   pregunte** — y sigue perdiendo contra `$XDG_CONFIG_HOME`, o sea contra la
   persona. R5 se cumple: `/etc/xdg/mimeapps.list` no lo declara ningún paquete
   de la base, comprobado con `dpkg -S` sobre un escritorio **completo**, que es
   un superconjunto de `ubuntu-desktop-minimal`.

**Consecuencia de método, y es la tercera vez en dos sesiones:** una medición
hecha por `ssh` sobre algo que vive en una sesión de escritorio hay que marcarla
como tal **en el momento de hacerla**, no cuando se va a arreglar.

#### (e) Las otras dos preguntas de producto, contestadas leyendo

**`sane-airscan`: `simple-scan` NO lo arrastra, y aun así ya viaja.** Sus
`Depends` piden `libsane1` y no tiene `Recommends`. Pero el conjunto derivado de
los manifiestos del medio —con el control de §4.27a repetido hoy: **doce nombres,
doce aciertos**— dice que `sane-airscan` **y** `ipp-usb` están en
`ubuntu-desktop-minimal`. Se declara igualmente en `encina-meta`: cuesta **0
paquetes** y es lo que impide que un cambio de la base se lo lleve en silencio.

```
conjunto del objetivo: 1435 nombres (1484 de minimal.manifest menos 42 de la capa es)
control: evince gvfs gvfs-backends xdg-desktop-portal-gnome cups unattended-upgrades
         update-notifier sane-utils  -> PRESENTES
         file-roller libreoffice-core gnome-software simple-scan  -> AUSENTES
         paquete-inventado-jamas                                  -> AUSENTE
lo que E4 pregunta: sane-airscan PRESENTE · ipp-usb PRESENTE · gnome-session-common PRESENTE
                    snapd 2.73+ubuntu24.04 PRESENTE · firefox 1:1snap1-0ubuntu5 PRESENTE
                    openjdk-17-jre AUSENTE · libnss3-tools AUSENTE · hunspell-es AUSENTE
                    gnome-software-plugin-snap AUSENTE
```

*(Ojo con el instrumento: los manifiestos son **diffs**, con `+` y `-` delante de
cada nombre y dos líneas de cabecera. Sin quitarlos, el conjunto sale vacío y los
doce controles fallan a la vez — que es justo para lo que están.)*

**Y `gnome-software-plugin-deb` sigue sin existir**, remedido hoy contra los
índices: sostiene D18 y no es una cita de ayer.

#### (f) La construcción: los dos `.deb`, y el ritual de las cuatro cosas

`encina-branding` **0.1.8** (el manejador del PDF y `Depends: evince`) y
`encina-meta` **0.2.0** (las aplicaciones de D17/D18 y `sane-airscan`),
construidos en `encina-dev` con `dpkg-buildpackage -us -uc -b`, **`lintian` mudo
en los dos**:

```
faeca3a9f0cf7a6e01a8d6ab28ae9fe6f56f6aa326287675701bd3962064cd6d  autofirma_1.9.1+encina4_all.deb
51b6603ca1cfd431d459865f21df095a628200681b6deed1bca0c3c2ccebfdb3  encina-branding_0.1.8_all.deb
972ec9323140d9aa7522be8a3608ff751b042725a3111154321ea1f304b999f2  encina-firefox-native_0.2.1_all.deb
85c8cc56d586a40d2b6736688591d493bf988b234bff3e331e7c1c642239b596  encina-meta_0.2.0_all.deb
```

Las cuatro cosas de `SCRIPTS.md`, cumplidas: el `.deb` de AutoFirma se eligió
**por ruta entera** entre los **tres** candidatos de `encina-autofirma/salida/` y
se comprobó por huella; `encina-firefox-native` se sacó **del volumen del seed
anterior** (`13aa8f59…`) y no de `debian-packages/`; el índice `Packages` se
regeneró con `dpkg-scanpackages` **en la VM**; y los nombres con versión dentro se
cambiaron en `encina-seed.sh`, `fabricar-seed.sh` y `fabricar-iso.sh`.

**Y el control del ritual, hecho antes de fabricar el bueno:** un repo con el
`+encina2` renombrado a `+encina4`, y la herramienta se niega **antes de escribir
nada**.

```
[FALLO] huella distinta en autofirma_1.9.1+encina4_all.deb
        esperada faeca3a9…   real d5a0ebe1…
  -> existe la salida? no
```

**Una trampa nueva del propio taller, y se dice porque coló un paquete entero:**
el `tar` de macOS mete **AppleDouble `._x`** dentro del tarball si el fichero
tiene atributos extendidos, y de ahí pasaron a `./etc/xdg/._mimeapps.list`
**dentro del `.deb`**. Es §4.18m por una vía nueva —allí eran los `._` del volumen
FAT, aquí los del tarball de fuentes— y se evita con `COPYFILE_DISABLE=1`. Se vio
mirando `dpkg-deb -c`, no por ningún error.

**Y otra del mismo rato, que además apareció dos veces:** `tar xzf … | head -2`
**mata el `tar` a mitad por SIGPIPE**, y deja el árbol de fuentes incompleto sin
decir nada; el `set -e` de después falla en un sitio que no tiene nada que ver.
Es la familia de la trampa 22: el instrumento se equivoca y no da un número raro,
da un resultado plausible.

**El seed y los dos YAML, rehechos desde el mismo guion**, con el camino de vuelta
—sacar el base64 del YAML, decodificarlo y compararlo con `encina-seed.sh`— y su
control de que un byte de más rompe la comparación. La `late-command` es **la
misma en los dos ficheros, byte a byte**: 37 291 caracteres.

#### (g) INSTALACIÓN 1 — la máquina de E4, y la mina donde decía que estaba

`encina-E4-meta`, forma E2 (volumen `CIDATA` `360bb894…`, ISO oficial
`c2610520…`, `-append autoinstall` suelto y `-no-reboot`), **desatendida**:
arrancó a las `00:45:47Z` y **se apagó sola** a las `00:55:39Z` — **9 min 52 s**,
sin que nadie abriera su ventana.

**Y apagarse sola ya significa algo más que antes**, por la lectura de (c): con
el `exit 1` puesto, un seed que saliera distinto de 0 dejaría a `subiquity` en
`ERROR` y **no apagaría**. O sea que *«se apagó sola»* = `ESTADO=COMPLETO`, y se
sabe **sin abrir nada**. Lo confirma el testigo:

```
encina-seed llego al final 2026-08-12T00:55:08Z estado=COMPLETO
ENCINA_ESTADO=COMPLETO      ENCINA_FALTA=
```

**El paso 5, que es el que cambia de signo:** el inventario del Snap sale
**idéntico** antes (bloque 4) y después (bloque 6) — `diff` sin diferencias, los
nueve `[PRESENTE]`, un `firefox_*.snap`, y sus dos controles. **Nadie ha tocado
el Snap.**

**LA MINA DE `AGENTS.md` §6.2 ERA REAL Y ESTABA DONDE DECÍA**, y esta vez se ve
la palabra:

```
The following packages will be DOWNGRADED:  firefox
83 upgraded, 1 newly installed, 1 downgraded, 0 to remove
Inst firefox [1:1snap1-0ubuntu5] (153.0.4~build1 …/repositories/mozilla:mozilla)
dpkg: warning: downgrading firefox from 1:1snap1-0ubuntu5 to 153.0.4~build1
Unpacking firefox (153.0.4~build1) over (1:1snap1-0ubuntu5) ...
  rc=0
```

**Y el reparto de §4.17 se invierte, exactamente como estaba previsto:** el paso
11 (`full-upgrade`) vuelve a ser **el** paso, y el 12 vuelve a ser **solo el
idioma** —`1 newly installed`, `Setting up firefox-l10n-es-es`—. El bloque
11bis, la red de seguridad, **no hizo nada y lo dijo**: *«el navegador ya es el
de Mozilla (sin epoch): este bloque no hace nada»*.

**Y una cosa que había que medir y no suponer:** sustituir el `.deb` de
transición por el de Mozilla **NO se lleva el Snap por delante**. El inventario
del bloque 13 sigue con `firefox_7764.snap` dentro. Es lo que hace que la forma
(c) sea alcanzable **por seed** y no solo a mano, como en E1.

**La máquina, con `imagen/verificar-e2.sh --visibles 28` como root:**
**48 correctas, 0 fallos, 0 avisos, 0 omitidas.**

#### (h) LA CASILLA DE D16, y el control que la hace significar algo

```
iconos de Firefox que ve el usuario ......... 1
firefox 153.0.4~build1 (sin epoch)          /usr/bin/firefox -> /usr/lib/firefox/firefox
firefox_firefox.desktop -> /usr/bin/firefox %u      (fuera de /snap/)
perfiles de Mozilla bajo ~/snap/ ............ 0
  control: el buscador encuentra .bashrc -> 2, y sabe decir cero -> 0
forma (c): snapd 'ii' + 1 revision de Snap de Firefox + 0 perfiles   <- la de D16
```

**Y la casilla sabe decir las dos cosas, que es lo que la convierte en casilla.**
Durante la medición de (i) se creó un perfil de Snap en un usuario desechable, y
mientras existió el buscador contestó **1**; al borrarlo volvió a **0**. Sin ese
par, un cero no significaría nada.

**Las 28 aplicaciones, declaradas antes de instalar y acertadas:** las 25 de
§4.26b **+ Centro de aplicaciones** (`snap-store`, que vuelve con `snapd`)
**+ Software** (`gnome-software`) **+ Escáner de documentos** (`simple-scan`).
**Y de ahí sale un dato de producto que no es una casilla y va sin adornos: el
usuario ve DOS tiendas.** D18 eligió `gnome-software`, y el `snap-store`
pre-sembrado del medio sigue ahí porque ya no se purga `snapd`. No lo decido yo:
se dice, y es exactamente la enfermedad que D18 nombra —la misma cosa dos veces
con dos orígenes—, aunque aquí sean dos tiendas y no dos Firefox.

#### (i) `+encina4` EN UNA MÁQUINA CON SNAP DE VERDAD — la casilla que §4.29 dejó sin medir

Sobre un usuario **virgen y desechable** (`convivd`), como el `convivb` de
§4.29e, y en la versión **difícil**: perfil del Snap **primero**, nativo
**después**.

```
CA de esta maquina (la genera el configurador, NO viaja en el .deb):
   /usr/share/autofirma/Autofirma_ROOT.cer   sha256 73:F7:52:A4:00:71:2F:92:…
el guion instalado ES el de M20 (tiene AUTOFIRMA_VENTANA_RAIZ)
vigilante en la sesion nueva: active     control: unidad inexistente -> inactive rc=4
cert9.db en el HOME antes de nada: 0

01:04:0x  el Snap crea su perfil   i0kdyj44.default   (-rw------- convivd convivd)
01:04:06  Starting autofirma-ca-mozilla.service
01:04:08  autofirma: CA del socket instalada en …/.config/mozilla/firefox/9hikzpoq.default-release
01:04:08  Finished.        Result=success   ExecMainStatus=0

[SNAP]   …/snap/…/i0kdyj44.default          -> CA CORRECTA (huella identica)
[NATIVO] …/.config/…/9hikzpoq.default-release -> CA CORRECTA (huella identica)
  control: certutil: Could not find cert: APODO-QUE-NO-EXISTE
```

**La casilla queda marcada: con un perfil de Snap delante, la CA llega sola al
perfil nativo, en 2 segundos, comparada por huella sha256.** Y el servicio
**termina bien** —`Result=success`—, o sea que el defecto de §4.29c, el almacén
de root, **no ha vuelto**: es `+encina3` sosteniéndose en una instalación limpia.

**Lo que esta medición NO añade, y decirlo importa:** no discrimina `+encina3` de
`+encina4`. El almacén nativo apareció **en 1 segundo**, y con un segundo ganan
los dos —en §4.29e ganó `+encina2` por carambola—. Lo que discrimina son los
**8044 ms contra 21 ms** de M20, y eso está en contenedor. Lo que esta sección
añade es que **el mecanismo bueno se comporta bien fuera del contenedor, con un
Snap real delante**, que es justo lo que §4.29e dejó abierto.

#### (j) EL `[OJOS]` DE §4.26f, CONTESTADO — y §4.26f corregida: era el instrumento

§4.26f decía *«los nombres de las aplicaciones salieron en inglés en las tres
combinaciones de locale probadas»*. **Es falso, y la causa no son las variables
de entorno: es `setlocale()`.**

```
LANG=es_ES.UTF-8, con locale.setlocale(LC_ALL,"")   -> Archivos / Escáner de documentos
LANG=es_ES.UTF-8, SIN setlocale                     -> Files
   (y en los dos casos GLib.get_language_names() ya dice ['es_ES.UTF-8','es_ES','es'])
```

Un proceso que no llama a `setlocale` recibe el `msgid` en inglés aunque GLib ya
sepa que el idioma es español. GNOME Shell —que es quien dibuja la rejilla— lo
llama al arrancar. **Era el instrumento, como el PDF de (d) y como los
manifiestos de (e): tres en la misma vuelta.**

Con el entorno **real** de `gnome-shell` de esta máquina —leído de
`/proc/<pid>/environ`: `LANG=es_ES.UTF-8`, `XDG_CURRENT_DESKTOP=ubuntu:GNOME`,
`XDG_DATA_DIRS` con el directorio del Snap dentro— las 28 salen en español:

```
 1 Actualización de software      11 Configuración de red avanzada  21 Registros
 2 Analizador de uso de disco     12 Contraseñas y claves           22 Relojes
 3 Aplicaciones al inicio         13 Discos                         23 Software
 4 Archivos                       14 Editor de texto                24 Soporte de idiomas
 5 AutoFirma                      15 Escáner de documentos          25 Terminal
 6 Ayuda                          16 Estadísticas de energía        26 Tipografías
 7 Calculadora                    17 Firefox                        27 Visor de documentos
 8 Caracteres                     18 Monitor del sistema            28 Visor de imágenes
 9 Centro de aplicaciones         19 Más controladores
10 Configuración                  20 Programas y actualizaciones
```

**Y con los ojos, que es lo que pedía la casilla.** Con autologin puesto a
propósito y revertido después —huella `ceee968c…` antes y después—, en la sesión
gráfica de verdad: el asistente de primer arranque dice *«Le damos la bienvenida
a Ubuntu 24.04.4 LTS»*, el reloj *«12 de ago»*, y al lanzar `simple-scan` dentro
de la sesión la ventana dice **«Escáner de documentos»**, el botón **«Escanear»**
y el cuerpo **«No se detectó ningún escáner»**.

**Esa última frase cierra de paso la mitad medible del escáner** (D17): la
aplicación arranca, habla con SANE y contesta que no hay hardware, que es la
respuesta correcta en una VM. *«Escanea de verdad»* sigue necesitando un escáner.

#### (k) EL NIVEL 3, y el agujero que solo esta medición podía encontrar

**El conjunto que le falta al medio no se dedujo: lo dejó escrito la máquina que
acababa de bajarlo.** Se cruzan **dos fuentes independientes** —las líneas `Get:`
del bloque 9 de `/etc/encina-seed.log` y los `.deb` de
`/var/cache/apt/archives`— y se ve dónde no cuadran.

**Los 24 que pasan a viajar en el medio**, 125 MB:

```
ca-certificates-java  fonts-dejavu-extra  gnome-software  gnome-software-common
gnome-software-plugin-snap  hunspell-es  hyphen-es  java-common  libatk-wrapper-java
libatk-wrapper-java-jni  libnss3-tools  mythes-es  openjdk-17-jre  openjdk-17-jre-headless
simple-scan  wspanish  firefox  firefox-l10n-es-es
+ libplymouth5 plymouth plymouth-label plymouth-theme-spinner plymouth-theme-ubuntu-text plymouth-themes
```

**El control —ninguno puede estar ya en el medio— cazó dos cosas, y las dos
importan:**

1. **Los seis `plymouth*` SÍ están en el medio**, pero en versión anterior: son
   **actualizaciones** que apt hace de paso, no requisitos. Viajan igual porque
   cuestan 1 MB y hacen que la máquina de sin red sea la misma que la de con red.
2. **`hunspell-es` NO aparecía en la cosecha, y `encina-meta` lo declara.** El
   `dpkg.log` de la máquina dice por qué: lo instaló **el instalador**, a las
   `00:49:37`, junto con `wspanish` —el paso de soporte de idioma—, o sea **de la
   red y antes del seed**. Sin red no estarían, y entonces `apt install
   encina-meta` no entraría. **Se descargaron aparte y viajan.** *Sin ese control,
   el medio habría salido con un agujero que solo se habría visto instalando.*

**Y AHÍ APARECIÓ ALGO MÁS GRANDE, que no es de E4 sino de una capa por debajo.**
Buscando qué más entra por esa vía, el registro de la propia máquina dice esto:

```
/var/log/installer/curtin-install.log
  apt-get --quiet --assume-yes … install --download-only linux-generic-hwe-24.04
  Get:26 http://ports.ubuntu.com/… linux-image-7.0.0-28-generic arm64 … [17.5 MB]
```

**EL NÚCLEO NO VIAJA EN EL MEDIO: LO BAJA `curtin` DE LA RED.** Leído en los
manifiestos de la propia ISO, con su control:

```
casper/minimal.manifest             (lo que se instala)    linux-image: 0
casper/minimal.standard.manifest    (el escritorio entero) linux-image: 0
casper/minimal.standard.live.manifest (la capa VIVA)       linux-generic-hwe-24.04 6.17.0-14
pool/ del medio: 185 .deb, y los 4 'linux*' son headers y libc-dev, NINGUNA imagen
```

O sea: **el núcleo solo existe en la capa viva, que no es la que se copia al
disco.** La deducción de §4.27 —*«sin red la entrega es Ubuntu sin navegador»*—
**se queda corta por debajo**: sin red no hay ni Ubuntu, porque `curtin` pide el
núcleo con códigos de retorno permitidos `[0]` y no lo va a encontrar.

**Consecuencia para la casilla del nivel 3, y no se afloja: se PARTE, porque
estaba escrita sobre una lectura incompleta.**

- **La mitad que sí se cierra:** el medio lleva **todo lo que necesita el seed**,
  o sea lo que §4.27c enumeró (`hunspell-es`, el JRE, `libnss3-tools`, el
  navegador y su idioma) más lo de D17/D18. Eso se mide.
- **La mitad que NO se cierra con este mecanismo, y se dice con su motivo:**
  meter el núcleo en `/cdrom/encina-repo` **no serviría**, porque cuando `curtin`
  lo instala **nuestro repositorio todavía no existe** —lo añade el seed en una
  `late-command`, que corre después—. Cerrarlo pide otra cosa: una sección `apt:`
  en el seed que le dé al objetivo una fuente que el instalador pueda leer
  **antes**, y el cierre de los ~700 MB del cierre del núcleo. **Es de E3, no de
  E4**, y va nombrado, no aflojado.

#### (l) LA INSTALACIÓN SIN RED, MEDIDA — y §4.27 se queda corta por debajo

**La red se quitó por hardware, no contestando «no» en una pantalla** (§4.27e), y
el control está en la orden real de QEMU, recogido antes de arrancar:

```
grep -c "netdev\|virtio-net" debug.log   ->  0        <- no hay tarjeta, no hay preferencia
grep -o "-append [^ ]*"      debug.log   ->  -append autoinstall   (suelto)
```

**Y lo que pasa es esto:**

```
01:15:35Z  arranca
01:18      el disco deja de crecer en 4 461 MB   (la completa llego a 10 786 MB)
01:20      la pantalla dice, EN ESPANOL:  «Se produjo un problema»
           con «Report problem…», «Cancel» y  sudo ubuntu-bug ubuntu-desktop-bootstrap
```

**La instalación sin red FALLA A LA VISTA, y falla ANTES de llegar al seed.** No
hay `/etc/encina-estado` que leer porque las `late-commands` no llegan a correr:
lo que se rompe es el paso de `curtin` que instala el núcleo. **Eso convierte la
deducción de §4.26e —*«el instalador le diría que ha ido bien»*— en falsa por un
motivo mejor que el previsto:** no es que avise, es que **no termina**.

**Y reordena los tres niveles de §4.27:**

- **El nivel 2 se queda igual de bien puesto**, pero deja de ser el que salva
  este caso: cuando falta la red, el que grita es `curtin`, no nuestro `exit 1`.
  El `exit 1` sigue siendo la red de seguridad de los casos en que el seed **sí**
  corre y deja la máquina a medias.
- **El nivel 3 no se puede cerrar por el medio**, por lo dicho en (k).

*Lo que esta medición no da:* el mensaje exacto de `curtin` desde dentro. La
máquina no tiene red —esa es la premisa— y abrir un canal habría exigido teclear
en una sesión en estado de error. Lo que se afirma se apoya en tres cosas
medidas: el tamaño del disco, el reloj, y que el núcleo no está en el medio.

#### (m) LA ISO DE E4

```
aa1ac76a31afd75506b862eb6da9599bd53638dcdaa8aa0fbb07e625716c08cb  encina-os-E4-es.iso
3 715 366 912 bytes   (la de E3 eran 3 540 299 776)
```

`imagen/fabricar-iso.sh`, con todos sus controles en verde:

```
los tres binarios firmados     intactos por huella, antes y despues
la ESP                         byte a byte la oficial en sus 13 504 sectores
                               y los 640 de mas son relleno: 0 bytes distintos de cero
la FORMA de arranque           MBR hibrido, El Torito y plataforma UEFI, iguales
el medio entero                501 entradas la oficial, 531 la nuestra
                               30 anadidos (el seed + 28 .deb + Packages), ni uno mas
                               2 modificados y nombrados: grub.cfg y md5sum.txt
                               ninguno perdido
control                        con una huella saboteada, la comparacion la senala
integridad                     las 266 lineas de md5sum.txt cuadran
control                        con el md5sum.txt OFICIAL falla exactamente UNA, la del grub.cfg
```

**Y arranca, y el instalador se ve en español**, con el control de la trampa 16
recogido **antes** de que arrancara nada: **0** argumentos `-append` y
**exactamente dos** unidades. La primera pantalla es *«Disposición del teclado /
Elija la disposición del teclado»* con **Español** ya marcado.

**Y aquí me aparté del plan, y digo por qué.** El plan decía pilotar las cinco
pantallas sin ojos, como en §4.23 y §4.25. **No lo conseguí:** ni las teclas ni
los clics llegaban al invitado —la ventana de UTM no tomaba el foco desde
AppleScript, y las coordenadas del ratón no acertaban el botón—, y tras varios
intentos el precio dejó de compensar. **Lo que hice en su lugar mide lo que de
verdad estaba en duda del medio y no necesita manos:** un volumen `CIDATA` con
**el YAML de E2 y NINGÚN `encina-repo` dentro**. Así el seed lo gana el `CIDATA`
—la trampa 16, usada a favor— pero el bloque 1 no encuentra repositorio en él y
**tiene que caer a `/cdrom/encina-repo`**, que es exactamente lo que había que
demostrar de la ISO nueva. Lo que esta sustitución **no** mide, y queda dicho:
que el `autoinstall.yaml` que viaja **dentro** de la ISO se lea desde `/cdrom`
—eso lo midió §4.23 y §4.25 con la ISO anterior— y las cinco pantallas.

#### (n) INSTALACIÓN 2 — la ISO nueva instala, y el repositorio sale de `/cdrom`

`encina-E4-iso`, con el `CIDATA` sin repo dentro. Arrancó a las `01:28:06Z` y
**se apagó sola** a las `01:42:19Z` — **14 min 13 s** —, que con el `exit 1`
puesto ya significa `ESTADO=COMPLETO`.

**Y la línea que decide, del registro que dejó la máquina sola:**

```
  CIDATA -> /dev/vdb                     <- el seed lo dio el volumen
  REPO ELEGIDO -> /cdrom/encina-repo     <- el REPOSITORIO salio de la ISO
  29 ficheros copiados a /target/srv/encina-repo   (28 .deb + Packages)
ENCINA_ESTADO=COMPLETO   ENCINA_FALTA=
```

**La máquina, con `verificar-e2.sh --visibles 28` como root: 48 correctas, 0
fallos, 0 avisos, 0 omitidas** — el mismo resultado que `encina-E4-meta`, por dos
caminos distintos y con el repositorio saliendo de sitios distintos.

#### (ñ) El coste, medido y no predicho

```
libres al empezar        35,775 GiB     (8 VMs, todas paradas)
libres al terminar        6,725 GiB
GASTADO                  29,050 GiB     (se habian declarado ~26-27)
```

**Dónde se fue, y por qué se pasó de lo declarado:** dos máquinas de ~10 GiB
—`encina-E4-meta` y `encina-E4-iso`—, la ISO nueva de 3,7 GB en `e2-medios`, el
volumen `CIDATA` del nivel 3 (0,75 GiB), el de E2 (128 MiB), y **una tercera
máquina que no estaba en el presupuesto**, `encina-E4-sinred`, que se creó y se
destruyó en la misma sesión y **devolvió 4,4 GiB** —lo que había llegado a
escribir antes de que la instalación fallara—. El registro de UTM quedó
consistente por las dos mitades (trampa 18): **10 en `utmctl list` y 10 bundles
en disco**, sin entrada fantasma.

**Y dónde vive el repositorio offline, para que nadie lo tenga que volver a
cosechar:** **dentro de la ISO**. Los 28 `.deb` y su `Packages` se sacan con

```
xorriso -osirrox on -indev encina-os-E4-es.iso -extract /encina-repo <destino>
```

Los volúmenes `CIDATA` de esta vuelta **no** se conservan: se rehacen con
`fabricar-seed.sh` a partir de ese directorio, y las huellas de los cuatro `.deb`
de Encina están escritas en `imagen/encina-seed.sh`, que es la autoridad.

**Y queda dicho para la próxima:** con 6,7 GiB no cabe otra vuelta. La primera
candidata a borrar es `encina-E4-iso` —nacida de la ISO, o sea **caché
reproducible** por §9.a, y su papel lo repite `encina-E4-meta` salvo en la línea
`REPO ELEGIDO`—, y devolvería ~10 GiB reales.

#### (o) Lo que esta vuelta NO contesta, y hay que decirlo entero

- **Que la ISO instale contestando las cinco pantallas.** Arranca y se ve en
  español; el resto se sustituyó por lo de (m) porque el piloto sin ojos no
  llegaba.
- **Una firma real sobre la máquina de E4.** Sigue siendo `[OJOS]`, certificado
  personal y clon efímero (§9.1). Lo que sí está aquí es que el vigilante mete la
  CA correcta en el perfil nativo con un Snap delante.
- **Que `+encina4` sea NECESARIO en una máquina de verdad.** Aquí gana, pero
  también habría ganado `+encina3`: el almacén nativo nació en 1 s. Lo que
  discrimina está en M20 y es contenedor.
- **Qué mensaje exacto da `curtin` sin red.** Se sabe dónde para y qué ve la
  persona, no la línea del log: la máquina no tiene red, que es la premisa.
- **El estado (b)** —`snapd` sí, Snap de Firefox no— sigue sin medir, como en
  §4.29j.
- **Si el usuario prefiere una tienda u otra**, ni si `snap-store` debe irse. Es
  producto y lo decide Jorge.
- **amd64, nada.** D9 sigue igual.

---

### 4.32 E3/E4 — El núcleo, leído hasta el final; y la ISO de E4 contestando las cinco pantallas (2026-08-12)

**Es lo que la vuelta de E4 dejó abierto** (`ENCINA-OS.md` §7): el núcleo —que es
de E3— y las dos medidas que le faltaban a la ISO. Y va primero la limpieza,
porque con 8,3 GiB no cabía nada.

**Lo que hay que llevarse, en cuatro líneas y antes del detalle:**

1. **La pregunta del núcleo estaba mal planteada, y la máquina ya tenía la
   respuesta escrita.** No falta una fuente: el objetivo **ya lee el medio** por
   `file:/cdrom` cuando `curtin` instala el núcleo. Lo que falta es el núcleo
   **dentro del archivo indexado**, y ahí manda la firma de Canonical.
2. **La clave `apt:` del seed NO sirve, y por un motivo que solo se ve leyendo:**
   en el camino sin red `subiquity` **borra a propósito** todas las partes de
   `sources.list.d` que hereda el objetivo.
3. **El cierre del núcleo son 1 089 MB, no ~700**, y 655 de ellos son
   `linux-firmware`, que **es `Depends:` y no se puede dejar fuera**.
4. **La ISO de E4 queda cerrada entera:** el `autoinstall.yaml` de dentro se lee
   —`CIDATA -> <no encontrado>`— y las cinco pantallas están **nombradas por la
   propia máquina**, no contadas en capturas.

#### (a) El coste, dicho ANTES de arrancar nada

```
df -k /   8 704 892 KiB libres = 8,302 GiB     utmctl list -> 10 VMs, las 10 paradas
          10 en utmctl list y 10 bundles en disco: registro consistente (trampa 18)
```

| Concepto | Precio declarado |
|---|---|
| Limpieza de `encina-E4-iso` | 0 gastados; **devuelve ~9,9 GiB** según `du`, y se mide con `df` |
| El núcleo, por lectura (capa viva de la ISO al scratchpad) | ~1 GiB **temporal**, 0 VMs |
| El cierre del núcleo, medido | 1 VM encendida para leer su propio registro |
| Las dos medidas de la ISO: VM nueva, dos unidades | ~10–11 GiB + pilotar cinco pantallas sin ojos |
| **Total** | queda por encima de **5 GiB** |

#### (b) LA LIMPIEZA, y la condición de §9.a cumplida por huella

La condición antes de borrar es **comprobar que su ISO vive también en
`e2-medios`**, y aquí salió mejor de lo escrito: **el bundle no llevaba ningún
clon de la ISO dentro** —solo `disco.img`, `debug.log`, `efi_vars.fd`,
`config.plist` y una captura—, así que **no aplicaba la trampa 21**.

```
e2-medios/encina-os-E4-es.iso  aa1ac76a31afd75506b862eb6da9599bd53638dcdaa8aa0fbb07e625716c08cb
libres antes     8 704 892 KiB =  8,302 GiB
libres despues  19 381 948 KiB = 18,484 GiB
DEVUELTO        10 677 056 KiB = 10,182 GiB      <- du decia 9,9G: aqui du acierta (§9.a)
```

Y el control de que quedó consistente son **las dos mitades**: 9 en `utmctl list`
y 9 bundles en disco, `plutil -lint` en verde, y la ISO intacta.

#### (c) EL NÚCLEO — la pregunta de la fuente ya la había contestado la máquina

§4.31k dejó escrito que *«meter el núcleo en `/cdrom/encina-repo` no serviría,
porque cuando `curtin` lo instala nuestro repositorio todavía no existe»*. **La
primera mitad es cierta y la conclusión es falsa**, y lo demuestra el registro de
`encina-E4-meta`, que es el dato que la máquina dejó escrito sola:

```
/var/log/installer/curtin-install.log
  start: cmd-install/stage-curthooks/builtin/cmd-curthooks/writing-apt-config
  start: cmd-install/stage-curthooks/builtin/cmd-curthooks/installing-missing-packages
  ...
  start: cmd-install/stage-curthooks/builtin/cmd-curthooks/installing-kernel   <- DESPUES

  Get:1 file:/cdrom noble InRelease            <- el objetivo YA lee el medio
  Hit:4 http://ports.ubuntu.com/ubuntu-ports noble InRelease
  Get:4 file:/cdrom noble/main arm64 grub-common arm64 2.12-1ubuntu7.3 [2197 kB]
  Get:8 file:/cdrom noble/main arm64 grub-efi-arm64-signed arm64 1.202.5+2.12-1ubuntu7.3 [1395 kB]
```

**O sea que el medio ya es una fuente de apt del objetivo, y ya le sirve paquetes
—GRUB entero— justo antes de la orden del núcleo.** El mecanismo está leído en el
código que viaja en esta ISO: `install.py:394` llama a `setup_target` **después
de extraer y antes de `curthooks`**, y `apt.py:363-365` monta `/cdrom` dentro de
`/target`; la línea `deb [check-date=no] file:///cdrom $codename main restricted`
la escribe `subiquity` en `apt.py:262`.

**Lo que falta, entonces, no es una fuente: es el núcleo dentro del archivo
indexado del medio.** El medio **sí** es un archivo de apt completo:

```
/dists/noble/Release        (645 B)    /dists/noble/Release.gpg   <- firma de Canonical
/dists/noble/main/binary-arm64/Packages.gz          51 618 B
/pool/  185 .deb, y los 4 'linux*' son headers y libc-dev, NINGUNA imagen  (§4.31k)
```

#### (d) LAS CUATRO VÍAS, leídas en el código de ESTA ISO, y por qué tres están cerradas

**Vía 1 — la clave `apt:` por `curthooks`: no llega.** `subiquity` **no** mete
`apt` en la configuración del paso de `curthooks`, y el registro lo dice con
todas las letras:

```
subiquity-curthooks.conf  ->  grub:, install:, kernel: {package: linux-generic-hwe-24.04},
                              pollinate:, storage:, write_files:   ... y NINGUN 'apt:'
curtin-install.log:503    ->  No apt config provided, skipping
```

**Vía 2 — la clave `apt:` por el árbol del que se extrae el objetivo: llega con
red y DESAPARECE sin ella.** El `apt:` del seed sí entra en
`subiquity-curtin-apt.conf` —lo que no consume el modelo va a
`merge_config(self.config, data)`, `models/mirror.py:318`— y `curtin apt-config`
lo aplica al `configured_tree`, del que hereda el `install_tree` y de ahí se
extrae `/target`. **Pero la rama sin red de `configure_for_install` borra
justamente eso:**

```python
else:                                    # apt.py, cuando NO hay red
    self.install_tree.pp("etc/apt/sources.list").unlink(missing_ok=True)
    for relpath in apt_sourceparts_files(self.configured_tree):
        self.install_tree.pp(relpath).unlink()      # <- se lleva NUESTRA fuente
```

O sea que existiría **con red, donde no hace falta**, y no existiría **sin red,
que es el único caso que importa**. Es la familia de la trampa 5 al revés: la vía
funciona exactamente cuando no se la necesita.

**Vía 3 — meter el núcleo en el `/pool` del medio: la firma lo impide.** El
`Release` lista las SHA256 de los `Packages`, y `Release.gpg` es de Canonical:

```
SHA256:
 97801a81bef86e1db723e9b548dcc54b8359cee01f4426466943620defc27b79    51618 main/binary-arm64/Packages.gz
 0630daf8c69eebf335b8d7b77764d8e42aea71572142f14bb6625730424014d4   206069 main/binary-arm64/Packages
```

Añadir un `.deb` obliga a rehacer `Packages` → cambia el `Release` → **la firma
deja de cuadrar**, y la línea que escribe `subiquity` **no lleva `[trusted=yes]`**
(lleva `[check-date=no]`, que es otra cosa). No podemos re-firmar como Canonical.

**Vía 4 — decirle a `curtin` que no instale núcleo: no hay clave que llegue.**
`curtin` sí sabe (`kernel: {install: false}`, `curthooks.py:361`), pero el
esquema de autoinstall de `subiquity` **exige `package` o `flavor`**
(`controllers/kernel.py:28-44`), así que desde el seed no se puede expresar.

**Y la vía que queda abierta, con su precio, y va marcada como LEÍDA Y NO
MEDIDA:** re-firmar el `dists/` del medio **con clave propia** y hacer viajar esa
clave en `apt: sources: {…: {key: …}}`. Se sostiene sobre un detalle del mismo
código: la rama sin red borra las **fuentes**, pero `add_apt_key_raw` escribe en
`/etc/apt/trusted.gpg.d/`, que **no** se borra. Cuesta rehacer `Packages`,
`Release`, `md5sum.txt` —precedente pagado en §4.25— y **1 089 MB** de medio.
**No se ha probado, y hasta que se pruebe esto es una lectura, no un resultado.**

#### (e) EL TAMAÑO, medido y no estimado: 1 089 MB, no ~700

Lo dejó escrito la máquina que lo bajó:

```
apt-get install --download-only linux-generic-hwe-24.04
4 upgraded, 31 newly installed, 0 to remove and 358 not upgraded.
Need to get 1089 MB/1091 MB of archives.
  linux-firmware                    655 MB    <- el 60% de todo
  linux-modules-7.0.0-28-generic    286 MB
  libllvm19 27,4 · libllvm18 26,3 · linux-image 17,5 · linux-hwe-7.0-headers 14,8
  libclang-cpp18 13,2 · firmware-sof-signed 9,0 · libclang1-18 7,5 · ...
De los 35, TRES salieron de file:/cdrom (2,2 MB); los otros 32 de la red.
```

**Y `linux-firmware` no es opcional, medido con su control:**

```
linux-image-generic-hwe-24.04   Depends: linux-image-7.0.0-28-generic, linux-firmware
linux-image-7.0.0-28-generic    Depends: kmod, linux-base, linux-modules-7.0.0-28-generic
linux-generic-hwe-24.04         Depends: linux-image-generic-hwe-24.04, linux-headers-generic-hwe-24.04
                                Recommends: linux-tools-7.0.0-28-generic, ubuntu-kernel-accessories
CONTROL: apt-cache show paquete-inventado-jamas -> E: No se encontró ningún paquete
```

Así que **lo único que se puede recortar sin cambiar de producto son los headers
y las herramientas** (~116 MB, pasando `kernel: package: linux-image-generic-hwe-24.04`):
quedan **~973 MB**. Con eso el medio pasa de **3,715 GB** a **~4,69 GB**, que
**se sale del DVD de una capa (4,7 GB)** y **del límite de 4 GiB por fichero de
FAT32**. Los dos límites hay que decirlos porque deciden cómo se entrega.

**Lo que esto le deja a la casilla del nivel 3:** su mitad del núcleo **no se
cierra con lo que la ISO ofrece hoy**. Queda **declarada como límite, igual que
D9 con amd64**, con una salida nombrada y no medida —la vía de (d)—. **No es una
deuda escondida: es un límite con su motivo escrito.**

#### (f) LA ISO DE E4 — las cinco pantallas, y el control recogido antes de arrancar

VM nueva `encina-E4-cinco`, creada desde cero, con la ISO `aa1ac76a…` enlazada
**en duro** al bundle (`stat` dijo **2 enlaces**, que es lo que un clon de APFS
nunca dice — trampa 21). **Y el instrumento se validó antes de usarlo:** no había
ningún ejemplo vivo de unidad de CD en el banco, así que se escribió el
`config.plist` y **se comprobó que UTM listaba la VM** — su propio modo de fallo
es no listarla.

**El control de la trampa 16, recogido antes de que arrancara nada:**

```
argumentos -append: 0
-drive ... media=disk   ...encina-E4-cinco.utm/Data/disco.img
-drive ... media=cdrom  ...encina-E4-cinco.utm/Data/encina-os-E4-es.iso
                        NINGUN volumen CIDATA
```

**Y lo que dejó escrito la máquina, que es lo que decide:**

```
  CIDATA -> <no encontrado>              <- el seed salio de /cdrom/autoinstall.yaml, el 5º sitio
  REPO ELEGIDO -> /cdrom/encina-repo
ENCINA_ESTADO=COMPLETO   ENCINA_FALTA=
testigo: encina-seed llego al final 2026-08-12T08:18:21Z estado=COMPLETO
```

**Las cinco pantallas no se cuentan en capturas: las nombra el instalador**, y
son **exactamente** los cinco `autoinstall_key` de `AGENTS.md` §6ter.0:

```
/var/log/installer/telemetry
  "0":loading  "1":keyboard  "314":network  "398":storage  "439":identity
  "867":timezone  "955":confirm  "957":install  "1418":done
```

Ni `locale`, ni `source`, ni aplicaciones, ni códecs: **el seed de dentro fijó lo
que tenía que fijar**. En pantalla se vio además el salto —del punto 4 al 8— que
es esa misma ausencia vista por el otro lado.

**La máquina, con `verificar-e2.sh --forma e3 --visibles 28` como root:
47 correctas, 2 fallos, 0 avisos, 0 omitidas — y los dos fallos son del
verificador**, están en (g). Lo que contestó del producto: **1** icono de
Firefox, `firefox 153.0.4~build1` sin epoch, **0** perfiles bajo `~/snap/`
—forma (c)—, las **28** aplicaciones declaradas por adelantado, los cuatro `.deb`
con `autofirma 1.9.1+encina4`, y el PDF atado **en las dos columnas** por un
fichero nuestro.

#### (g) DOS DEFECTOS DEL VERIFICADOR, y ninguno se afloja

```
[FALLO] las etapas por las que paso el instalador
        | esperado: confirm,done,identity,install,keyboard,network,storage,timezone
        | obtenido: confirm,done,identity,install,keyboard,loading,network,storage,timezone
[FALLO] hay un saludador grafico vivo   | esperado: si   | obtenido: no
```

1. **A la lista de etapas de `--forma e3` le faltaba `loading`**, que toda
   instalación escribe —la rama E2 de al lado ya la esperaba—. No se vio antes
   porque **desde que el verificador se reescribió en la vuelta de E4 no se había
   medido ninguna máquina de forma E3**. Corregido, y el arreglo va con su
   control: con la lista nueva casa, y **si faltara una pantalla seguiría
   fallando**.
2. **La comprobación del saludador no podía dar una de sus dos respuestas** justo
   donde hay que usarla: una máquina de forma E3 no lleva `ssh`, así que se mide
   **desde dentro de una sesión gráfica** (§4.25e) — y mientras hay alguien
   dentro, GDM **no** tiene saludador. Preguntaba por el mecanismo en vez de por
   lo que se quiere saber. Ahora vale el saludador **o** una sesión gráfica de
   usuario, **se dice cuál se vio**, y lleva el control de que `loginctl` no está
   mudo. Es la familia de las trampas 5 y 11.

#### (h) EL INSTRUMENTO QUE FALTABA: por qué §4.31m no pudo y hoy sí

`§4.31m` abandonó el pilotaje porque *«ni las teclas ni los clics llegaban»*. La
causa está encontrada y son **tres cosas distintas**, no una:

- **El ratón de UTM no llega; el teclado de `System Events` sí.** Con la ventana
  al frente, `input mouse click` deja el cursor del invitado donde estaba, y
  `tell process "UTM" to key code …` **sí** entra: el primer `Return` abrió el
  diálogo «Detectar disposición de teclado», que es una respuesta que no se puede
  fingir.
- **`Ctrl+Alt` nunca llega al invitado: es el atajo de UTM** para soltar el
  ratón, y lo intercepta el anfitrión (sale su propio diálogo «Mouse
  capturado»). Por eso `Ctrl+Alt+T` no abre ningún terminal. Lo que sí funciona
  es `Alt+F2` → «Ejecutar una orden».
- **Hay que reactivar UTM y comprobar que es el proceso frontal ANTES de cada
  envío.** `System Events` entrega al proceso **frontal**, no al que se nombra;
  en cuanto otra aplicación toma el foco, las teclas se van a otro sitio **sin
  ningún error**.

**Y la trampa de los caracteres comidos se reprodujo y se arregló:** `keystroke
"encinacinco"` dejó **`encinacin`** en el campo del nombre del equipo —dos
caracteres perdidos, y así se quedó el hostname de esta máquina—; tecleando
**carácter a carácter con 0,2 s** entre teclas, `gnome-terminal` salió entero. La
regla de SCRIPTS.md sigue valiendo entera: **mira en la pantalla lo que
tecleaste antes de creerte el resultado.**

**Las dos últimas pantallas las contestó Jorge con la mano**, y eso **no afloja
la casilla**: la forma de E3 es exactamente *«una persona contesta lo que Ubuntu
pregunta, y nada más»* (`AGENTS.md` §6ter.0). Lo que la casilla prohíbe es una
orden, un fichero o una edición — y de eso no hubo ninguno hasta que la máquina
ya estaba instalada.

#### (i) El coste, medido: la sesión salió a cero

```
libres al empezar     8 704 892 KiB =  8,302 GiB
libres tras limpiar  19 381 948 KiB = 18,484 GiB
libres al terminar    8 710 292 KiB =  8,307 GiB
```

**Se cambió una VM por otra, y el disco quedó igual** —+5 MiB—: se fue
`encina-E4-iso` y llegó `encina-E4-cinco`, que hace **todo lo que hacía aquélla
más las dos medidas que le faltaban**. El banco queda en **10 VMs y 10 bundles**,
consistente por las dos mitades.

#### (j) Lo que esta medición NO contesta, y hay que decirlo entero

- **Que la vía de (d) funcione.** Es una lectura del código de esta ISO, no un
  experimento: nadie ha re-firmado un `dists/` ni ha visto a `curtin` instalar un
  núcleo desde el medio. **Refutaría la lectura** que `apt-get update` fallara en
  el objetivo, o que la clave no sobreviviera a la rama sin red.
- **El mensaje exacto de `curtin` sin red.** Sigue sin sacarse, como en §4.31l.
- **Una firma real sobre una máquina de E4.** Sigue siendo `[OJOS]`, certificado
  personal y clon efímero (§9.1). Es la casilla más cara que queda.
- **El error que Jorge vio en pantalla durante la instalación** no lo vi yo y no
  dejó rastro: `debug.log` no tiene ni una línea con `error`, `invalid` ni
  `warning`, y el instalador terminó diciendo que fue bien. **Queda anotado sin
  interpretar**: si vuelve, hay que capturarlo en el momento.
- **El estado (b)** —`snapd` sí, Snap de Firefox no— sigue sin medir.
- **amd64, nada.** D9 sigue igual.

---

### 4.33 LA FIRMA REAL SOBRE LA FORMA (c): «Fichero firmado correctamente» con el Snap dentro (2026-08-12)

**Mirado en pantalla por Jorge a las 18:29Z**, en
`valide.redsara.es/valide/firmar/ejecutar.html`, con certificado real de la FNMT,
sobre un clon efímero de `encina-E4-meta` — o sea **la primera vez que se firma
sobre la convivencia (c)**: `snapd` instalado, el Snap de Firefox presente y
nunca abierto, y `autofirma 1.9.1+encina4`.

Es lo que §4.32 dejaba nombrado como *«la casilla más cara que queda»*, y lo que
D16 y D18 necesitaban para dejar de apoyarse en una firma medida en otra forma:
la de §4.13 salió con `+encina2` y Snap `7764`, sí, pero **sin tienda, sin
`gnome-software` y con la máquina de E1**. Aquí se firma sobre el producto de E4.

#### (a) Qué se daría por sano y qué por roto, escrito ANTES de meter el certificado

| Comprobación | Sano | Roto |
|---|---|---|
| Testigo de efímera | No existía antes; existe después | Ya existía → estoy en la original, parada inmediata |
| Linaje E4 | `encina-meta 0.2.0`, `branding 0.1.8`, `firefox-native 0.2.1`, **`autofirma 1.9.1+encina4`**, testigo de seed `00:55:08Z` | Cualquier otra versión → no es el clon de `encina-E4-meta` |
| Forma (c) | `snapd ii` + Snap `firefox` rev **7764** + `/usr/bin/firefox` fuera de `/snap/` + **0** perfiles bajo `~/snap/` | Un perfil bajo `~/snap/` → estado (d), el que no firma |
| Virginidad de Firefox | **0** `profiles.ini`, **0** `cert9.db`, **0** `.p12` **en HOME**, sin `~/.mozilla`, `~/.config/mozilla`, `~/.cache/mozilla` | Cualquiera > 0 → la máquina no llega virgen |
| Control del buscador | Encuentra `.bashrc` **y** sabe decir cero de un nombre inventado | Si no sabe las dos, el cero no significa nada |
| Vigilante | El guion instalado tiene `AUTOFIRMA_VENTANA_RAIZ` (es el de M20) | Sin ella es `+encina3` o anterior, y §4.29e vuelve |
| Qué Firefox corre | `readlink /proc/PID/exe` fuera de `/snap/` | Bajo `/snap/` → B3, y la firma falla en silencio |
| La CA | Llega **sola** al perfil nativo, huella sha256 idéntica a la del paquete | No llega, o llega con otra huella (§4.2b) |

#### (b) La huella de virginidad, tomada antes de tocar nada

```
testigo de seed: encina-seed llego al final 2026-08-12T00:55:08Z estado=COMPLETO
encina-meta 0.2.0 · encina-branding 0.1.8 · encina-firefox-native 0.2.1
autofirma 1.9.1+encina4 · firefox 153.0.4~build1 · snapd 2.76+ubuntu24.04.1
snap firefox 147.0.3-1 rev 7764        /usr/bin/firefox -> /usr/lib/firefox/firefox
usuarios uid>=1000: solo encina (1000)
~/.mozilla ausente · ~/.config/mozilla ausente · ~/.cache/mozilla ausente
profiles.ini 0 · cert9.db 0 · key4.db 0 · perfiles bajo ~/snap 0 · .p12 en HOME 0
  control: .bashrc -> 2   NOMBRE-QUE-NO-EXISTE-JAMAS -> 0
[drm] features: -virgl                 <- gpu-pci, AutoFirma se dibuja
autologin de GDM: 0 lineas activas, custom.conf sha256 ceee968c…
CA del paquete: 73f752a400712f9213582b0aa87cc55229b951d4758ac0886a390c1dc3d78e62
sincronizar-ca-mozilla.sh -> AUTOFIRMA_VENTANA_RAIZ aparece 1 vez   (es el de M20)
  control: la misma orden con una cadena inventada -> 0
```

`~/snap/` **existe** y no es un fallo: dentro solo hay
`snapd-desktop-integration` —15 ficheros, **0** de Mozilla, con el control de que
ahí el buscador ve 72 entradas—. La forma (c) mira perfiles, no directorios.

#### (c) Dos comprobaciones MÍAS que estaban mal escritas, y se dicen

**1. «0 `.p12` en el disco» no puede dar «sano» en ninguna máquina con AutoFirma
instalado.** El buscador contestó **2**, y los dos son del sistema:
`/usr/share/doc/openvpn/examples/sample-keys/client.p12` (del paquete `openvpn`)
y `/usr/share/autofirma/autofirma.pfx`, que **lo fabrica el configurador** y por
eso `dpkg -S` no lo reconoce. El umbral correcto es el de §4.13 —**0 en HOME**—,
que sí discrimina. Es la familia de la trampa 5: un umbral que solo sabe decir
«roto» no mide nada.

**2. Mi contador de iconos no sabía ensombrecer, y dijo 2 donde §4.31h midió 1.**
Contó por fichero, sin aplicar la precedencia de `XDG_DATA_DIRS`. La realidad,
mirando las cuatro raíces:

```
/usr/share/applications/firefox.desktop          NoDisplay=      Exec=firefox %u
/usr/share/applications/firefox_firefox.desktop  NoDisplay=true  Exec=/usr/bin/firefox %u   <- NUESTRA sombra
/var/lib/snapd/desktop/applications/firefox_firefox.desktop      Exec=/snap/bin/firefox %u  <- ensombrecido
/home/encina/.local/share/applications           (vacio)
```

Nuestra sombra vive en `/usr/share/applications`, que **gana** a
`/var/lib/snapd/desktop/applications`, y lleva `NoDisplay=true`. Visible queda
**uno**. **Y la columna que decide es la de los ojos** (trampa 26): en la rejilla
sale **un solo icono** de Firefox, y debajo, en un bloque aparte rotulado
*«Software, 5 más»*, el **catálogo de la tienda** — que es exactamente el precio
de D18 puesto delante, y no un icono del sistema.

#### (d) El control de identidad que sirvió, y el que NO: `utmctl clone` no regenera la MAC

El clon contesta en la **misma IP `.15`** que la original, y eso ya estaba
previsto. Lo que no estaba escrito es que **la MAC tampoco cambia**:

```
encina-E4-meta        MAC 76:CE:28:76:DC:40
encina-firma-efimera  MAC 76:CE:28:76:DC:40     <- identica
```

O sea que el truco de identificar una VM por su MAC en el `arp`
(`SCRIPTS.md`, «Cómo mirar y pilotar una VM sin ojos», punto 5) **no discrimina
un clon de su origen**. Las tres defensas que sí funcionaron, en orden de fuerza:

1. **La fecha de escritura de la imagen de disco, leída desde el anfitrión y sin
   encender nada** — el control más fuerte, y sale gratis:
   ```
   encina-E4-meta/Data/disco.img        2026-08-12 11:19:15    <- de esta manana
   encina-firma-efimera/Data/disco.img  2026-08-12 20:31:11    <- de la sesion
   ```
   La original **no se escribió ni una vez** en toda la sesión. El certificado
   nunca entró en el banco de E4, y está **medido**, no supuesto.
2. Un **testigo escrito dentro del clon** en el primer minuto
   (`/etc/encina-testigo-efimera`, `18:19:25Z`), con el control previo de que no
   existía.
3. `utmctl status` de los dos UUID antes de cada paso. Y el instrumento sabe
   decir las dos cosas con **dos mensajes distintos**: `The QEMU guest agent is
   not running` para la encendida, `The virtual machine is not running` para la
   parada.

#### (e) Qué Firefox corrió de verdad, demostrado y no supuesto

Abierto **desde el icono de la rejilla**, no desde un terminal:

```
exe    -> /usr/lib/firefox/firefox-bin              <- EL NATIVO
cgroup -> app-gnome-firefox-7068.scope              <- lo lanzo GNOME, no una shell
  control: la comprobacion SABE decir /snap/ -> encuentra 2 procesos con exe ahi
           y SABE encontrar /usr/lib        -> 21
```

El control importa: una comprobación que no encontrara **nada** bajo `/snap/` en
toda la tabla de procesos no distinguiría «el Firefox es nativo» de «mi lector de
`/proc` no funciona».

#### (f) La CA llega sola en 2 s, por huella — y §4.2a por CUARTA vez

```
18:18:19 · 18:19:25 · 18:20:02 · 18:21:07 · 18:21:24 · 18:22:21 · 18:23:32
     siete disparos que terminan en el mismo segundo: no hay perfil que tocar
18:25:12  Starting autofirma-ca-mozilla.service        <- Jorge abre Firefox
18:25:14  «CA del socket instalada en …/lvredwdf.default-release»
18:25:14  Finished.   Result=success  ExecMainStatus=0  NRestarts=0
```

```
paquete: 73f752a400712f9213582b0aa87cc55229b951d4758ac0886a390c1dc3d78e62
perfil : 73f752a400712f9213582b0aa87cc55229b951d4758ac0886a390c1dc3d78e62
  control: certutil -n APODO-QUE-NO-EXISTE -> «Could not find cert» + PR_FILE_NOT_FOUND_ERROR
```

`Result=success` dice además que **el almacén de root de §4.29c no ha vuelto**.
Esto es §4.31i repetido **sobre la cuenta del producto y en la máquina que
firma**, no sobre un usuario desechable — y con la misma advertencia: **no
discrimina `+encina3` de `+encina4`**, porque con dos segundos ganan los dos. Lo
que discrimina son los 8044 ms contra 21 ms de M20, y eso sigue en contenedor.

**Y la trampa de §4.2a aparece por cuarta vez, en una máquina recién nacida:**

```
[Install4F96D1932A9F858E]  Default=lvredwdf.default-release  Locked=1
[Profile1] Name=default          Path=zh6abe52.default          Default=1   <- sin cert9.db
[Profile0] Name=default-release  Path=lvredwdf.default-release              <- el unico con cert9.db
```

`Default=1` vuelve a caer en el perfil que Firefox no usa. El ayudante elige por
`cert9.db` y acierta.

#### (g) LA FIRMA

Jorge importó el `.p12` desde el Firefox ya abierto —así entra en el perfil que
AutoFirma va a mirar—, pulsó «Firmar», eligió el PDF y eligió su certificado.

```
«Fichero firmado correctamente»     valide.redsara.es, 18:29Z, mirado en pantalla
```

El almacén NSS del perfil nativo después de firmar, con el apodo personal
**omitido a propósito** (§9.1):

```
[SocketAutoFirma]                        trust=C,,
[<certificado personal, apodo omitido>]  trust=u,u,u
total de certificados: 2      claves privadas: 1
  control: certutil -n NO-EXISTE -> Could not find cert
```

**Y la forma (c) sigue en pie después de firmar**, que es la mitad que hacía
falta comprobar y es fácil olvidar:

```
perfiles de Mozilla bajo ~/snap ..... 0
~/snap/firefox ...................... no existe
cert9.db en TODO el disco ........... 1, y es el nativo
revision del Snap de Firefox ........ 147.0.3-1 7764   (la misma: nadie lo abrio)
```

#### (h) Las seis barreras, del registro que la máquina dejó escrito sola

```
18:28:52.046331723Z   afirma://websocket?ports=55908,55043,63685&v=4&jvc=3&idsession=…   B1a y B1b
                      Se inicia el modo de comunicacion por websockets, puerto 55908     B2
                      Fichero de perfiles determinado por 'AFIRMA_NSS_PROFILES_INI'      B4
                      Directorio de bibliotecas NSS: /usr/lib/aarch64-linux-gnu          B6
                      es.gob.afirma.standalone.protocol.AfirmaWebSocketServerV4Sup
18:29:02.126528038Z   fin del registro
  control: la misma busqueda con una cadena inventada -> 0 en los dos ficheros
```

Diez segundos de la URI a la firma. B3 la cierra el Firefox nativo, y en (e) está
demostrado que era el nativo el que corría. **Y de regalo, el control de §4.28a
reproducido solo:** los puertos son **tres**, aleatorios, y los tres dentro de
49152–65535 — o sea que el `autoscript.js` que sirve la sede sigue siendo el que
se leyó, y un AutoFirma residente seguiría siendo inalcanzable.

#### (i) El coste, medido y no predicho

```
libres al empezar                  13,940 GiB
tras clonar                        14,140 GiB    <- el numero se mueve solo, como siempre
justo antes de destruir            13,801 GiB
tras destruir                      15,809 GiB
                                   ---------
DEVUELTO                            2,008 GiB     y `du` decia 11 GB   <- mintio por 5,5x
```

Otra fila para la tabla de §9.a: **clon de una máquina nacida de la ISO → `du`
miente por 5,5×**, entre el ×10 de la familia de E1 y el ×1 de una independiente.
El registro quedó consistente por las dos mitades —**10** en `utmctl list` y
**10** bundles en disco, cero rastro de la efímera— con el respaldo del `plist`
hecho **antes** y `plutil -lint` en verde después.

#### (j) Lo que esta medición NO contesta

- **No discrimina `+encina3` de `+encina4`.** Ver (f).
- **No prueba el estado (d).** Nadie abrió el Snap: la máquina murió en (c). Que
  quien lo abra falle sigue siendo §4.28d y §4.29g, medido con certificado de
  prueba, no aquí.
- **No contesta la pregunta abierta de M17** —si un Firefox ya abierto se entera
  de una CA que le meten por debajo—. Aquí la CA entró **antes** de que existiera
  el certificado personal y el navegador no se cerró en medio, así que el caso
  difícil sigue sin buscarse a propósito, igual que en §4.13.
- **No dice nada de la tienda.** `gnome-software` estaba instalado y nadie lo
  abrió; lo único que se vio de él es que su catálogo aparece en la búsqueda de
  la rejilla, que es (c) y no una medición de la tienda.
- **No hay estado bueno conservable.** La VM se destruyó, como manda §9.1. Lo que
  queda es este registro.

---

### 4.34 LA TIENDA CAMBIA: sale `gnome-software`, se queda el Centro de aplicaciones (2026-08-12/13)

**D18 se reescribe entera, no se parchea**, y el motivo nuevo que la reabre no es
una preferencia: **D18 eligió `gnome-software` sin haber considerado `snap-store`**,
porque el día que se decidió el seed todavía purgaba `snapd` y esa tienda **no
existía en la máquina**. Apareció horas después como efecto imprevisto de §4.31h,
y con ella **el usuario veía DOS tiendas**.

La asimetría que ordenó el trabajo: quitar `snap-store` es cirugía sobre un snap
pre-sembrado —la vía obvia miente (§4.16e) y la estrecha sigue sin medir
(§4.16l)—; quitar `gnome-software` era borrar una línea de `Depends:`. **Se probó
primero lo barato y reversible**, en dos niveles, y el 2 solo porque el 1 salió
verde.

#### (a) Qué se daría por sano y qué por roto, escrito ANTES de tocar la tienda

| Comprobación | Sano | Roto |
|---|---|---|
| Identidad del clon | `/etc/encina-testigo-tienda` **no** existía antes y existe después; linaje E4 completo | Ya existía → estoy en la original, parada inmediata |
| La original intacta | `encina-E4-meta/Data/disco.img` sigue en `11:19:15` al terminar | Otra fecha → se encendió el banco |
| (a) **[OJOS]** La tienda abre | Ventana rotulada y usable en arm64 | No abre o sale vacía → **D17 se queda sin sustento** |
| (a) **[OJOS]** …y sirve | LibreOffice **y** Thunderbird con botón de instalar. *Control:* una cadena inventada da **cero** | Cero para los dos, o el control también da resultados |
| (b) **[OJOS]** ¿`.deb` o solo snaps? | Se busca algo que solo existe como `.deb`. *Control:* algo que sí es snap tiene que aparecer | — (dato, no casilla) |
| (c) El purgado no se lleva nada | `snapd`, `simple-scan`, `sane-airscan`, `evince` y los tres de Encina en `install ok installed`. *Control:* el mismo comando sabe decir que no de un paquete inventado | Cualquiera ausente |
| (c) Resta del inventario | Nombra **uno a uno** lo que se fue | Algo de más en la resta |
| (d) **[OJOS]** Una sola tienda | **1**, y es «Centro de aplicaciones» | 0 (se fueron las dos) o 2 |
| (d) El contador sabe contar | Antes **2**, después **1** | El mismo número las dos veces → no mide nada |
| (d) 28 → 27, **nombrando** | El diff nombra «Software» | Un número sin nombre |

#### (b) NIVEL 1 — sobre un clon efímero, que se destruyó al terminar

`encina-tienda-efimera`, clon de `encina-E4-meta`. Testigo escrito **en el primer
minuto** (trampa 29), con su control previo:

```
control previo: ls /etc/encina-testigo-tienda -> No existe el archivo
despues:        clon efimero de la tienda 2026-08-12T19:38:19Z
```

Linaje, y **la primera cosa que la medición enseña**:

```
encina-meta 0.2.0 · encina-branding 0.1.8 · encina-firefox-native 0.2.1
autofirma 1.9.1+encina4 · firefox 153.0.4~build1 · snapd 2.76+ubuntu24.04.1
gnome-software 46.0-1ubuntu2 · gnome-software-plugin-snap 46.0-1ubuntu2
snap-store        -> NO-INSTALADO como .deb
snap list         -> snap-store  0+git.90575829  rev 1271  canonical**  2/stable
  control: dpkg-query de un paquete inventado -> «no se ha encontrado ningun paquete»
```

**`snap-store` no es un `.deb`: es un snap.** Por eso `encina-meta` no puede
declararlo, y por eso la asimetría del encargo era real.

#### (c) (a) [OJOS] LA TIENDA ABRE Y SIRVE EN arm64 — que es la premisa entera de D17

Abierta **desde la rejilla**, no desde un terminal, sobre sesión gráfica de verdad
(autologin de GDM activado en el clon y **revertido por huella** al terminar:
`ceee968ce0212138` antes y después, la misma que documenta §9).

```
proceso: 8325 /snap/snap-store/1271/bin/snap-store
ventana: «Centro de aplicaciones»
menu:    Explorar · Destacado · Productividad · Desarrollo · Juegos · Acerca de
catalogo cargado: «Snaps destacados», GNOME System Monitor, pycharm,
                  plexmediaserver, halloy, parca-agent, kubelet
```

Y **sirve**, que es lo que había que medir:

```
buscar «libreoffice»  -> libreoffice  Canonical (verificado)  «office suite»
buscar «thunderbird»  -> thunderbird  Canonical (verificado)  «Mozilla Thunderbird email application»
```

**D17 se queda de pie:** «que lo instale el usuario» tiene detrás una tienda que
abre, que carga catálogo y que encuentra las dos aplicaciones que D17 decidió no
traer.

#### (d) (b) [OJOS] NO ES SOLO DE SNAPS, y la respuesta preliminar era FALSA

El candidato se eligió midiendo antes de gastar ojos: **`file-roller` existe como
`.deb` (44.3) y NO existe como snap** (`snap find` no lo encuentra; el control es
que la misma orden con un nombre inventado contesta «No hay snaps que coincidan»).

```
Filtrar por: «Paquetes snap»    -> «No se encontro ningun resultado para file-roller»
Filtrar por: «Paquetes de Debian» -> File Roller
                                     «Abrir, modificar y crear archivos de archivadores comprimidos»
```

**El control es inmejorable y no admite discusión:** la **misma** búsqueda, en el
**mismo** instante, da **cero** con un filtro y **uno** con el otro. La prueba sabe
dar sus dos respuestas.

**Iba a escribir «solo snaps» y habría sido falso.** El desplegable «Filtrar por»
ofrece **dos** opciones, y con «Paquetes de Debian» el Centro de aplicaciones
encuentra `.deb`. O sea que **la tienda que se queda no pierde capacidad frente a
la que sale: gana una** respecto a lo que D18 daba por supuesto («el catálogo del
usuario es de *snaps*»).

#### (e) (c) EL PURGADO — y lo que se lleva por delante, que no es nada… salvo una cosa

La simulación, **antes** de ejecutar nada:

```
$ apt-get -s purge gnome-software gnome-software-plugin-snap
The following packages will be REMOVED:
  encina-meta* gnome-software* gnome-software-plugin-snap*
```

**`encina-meta` se va con ellos**, porque los declaraba en `Depends:`. **Eso es lo
que obliga a la 0.2.1 y lo que convierte el nivel 2 en obligatorio, no en un
extra.** Ejecutado:

```
Removing encina-meta (0.2.0) · Removing gnome-software-plugin-snap · Removing gnome-software
Purging configuration files for gnome-software

snapd                        install ok installed 2.76+ubuntu24.04.1
simple-scan                  install ok installed 46.0-0ubuntu2.1
sane-airscan                 install ok installed 0.99.29-0ubuntu4
evince                       install ok installed 46.3.1-0ubuntu1.1
encina-branding              install ok installed 0.1.8
encina-firefox-native        install ok installed 0.2.1
autofirma                    install ok installed 1.9.1+encina4
  control: un paquete inventado -> «no se ha encontrado ningun paquete»
```

**Los cuatro nombrados siguen, y los tres de Encina también.** La resta del
inventario completo, que es lo que convierte «no se llevó nada» en una medición:

```
paquetes ANTES: 1502    DESPUES: 1499
  -encina-meta 0.2.0
  -gnome-software 46.0-1ubuntu2
  -gnome-software-plugin-snap 46.0-1ubuntu2
lo que aparecio: (nada)
  control: el comparador encuentra 3 diferencias, y comparado consigo mismo dice 0
```

Y lo que **quedaría** huérfano, simulado y **no** ejecutado:

```
$ apt-get -s autoremove
  gnome-software-common  libfwupd2        <- y NADA de Encina
```

Los tres de Encina están en `showmanual`, así que `autoremove` no los toca; en
`/var/lib/apt/extended_states` no tienen `Auto-Installed`, **con el control de que
la lectura sí lo encuentra en `snapd` y en `gnome-software-common`**.

#### (f) (d) UNA SOLA TIENDA, contada y MIRADA, con el control que la hace significar algo

```
aplicaciones visibles   ANTES 28   DESPUES 27
tiendas visibles        ANTES  2   DESPUES  1     <- la que queda: «Centro de aplicaciones»
LA QUE SE FUE, NOMBRADA:  org.gnome.Software.desktop  |  Software
  control: el diff comparado consigo mismo -> 0 lineas
```

**El contador sabe decir 2, 1 y 0**, probado el día que se escribió y no el día que
estorba: quitando «Software» del inventario contesta **1**, quitando las dos
contesta **0**, y sobre el fichero real contesta **2**.

**Y la columna que decide es la de los ojos** (trampa 26). La misma búsqueda
«softw» en la rejilla, antes y después:

```
ANTES:    Actualizacion de software · Software · Programas y actualizaciones ·
          Mas controladores · Centro de aplicaciones
          + un bloque aparte rotulado «Software, 15 mas» con el CATALOGO
            (Kylin Software Center, QtPass, Gjots2 Jotter, Telegram, ONLYOFFICE)
DESPUES:  Actualizacion de software · Mas controladores ·
          Programas y actualizaciones · Centro de aplicaciones
          y el bloque del catalogo, DESAPARECIDO
```

Ese bloque era **el precio de D18 puesto delante**, el mismo que §4.33c describió
al firmar. Se va con `gnome-software`.

**Y la tienda que queda sigue sirviendo DESPUÉS del purgado**, que era la mitad
fácil de olvidar: reabierta desde la rejilla, encuentra `libreoffice` igual.

#### (g) Lo que costó el nivel 1, medido y no predicho

```
libres al empezar        15,711 GiB
tras clonar              15,138 GiB
tras destruir            15,640 GiB
                         ----------
DEVUELTO                  0,502 GiB     y `du` decia 11 GB   <- mintio por ~22x
```

**Fila nueva y extrema para §9.a**, y la más alta del proyecto: el ×10 de la
familia de E1 y el ×5,5 de §4.33 se quedan cortos. El motivo es que **la mentira de
`du` no depende solo de quién es clon de quién, sino de CUÁNTO ha divergido**: esta
sesión escribió un purgado de tres paquetes y unas capturas; la de §4.33 metió un
certificado y abrió Firefox.

Y la original **no se tocó**, medido desde el anfitrión sin encender nada:

```
encina-E4-meta/Data/disco.img        2026-08-12 11:19:15   <- igual que al empezar
encina-tienda-efimera/Data/disco.img 2026-08-12 21:58:53
```

#### (h) NIVEL 2 — `encina-meta` 0.2.1, y las SEIS cosas que hay que tocar

Construido en `encina-dev`, que es la máquina de construir:

```
encina-meta_0.2.1_all.deb   86da3cc9ec071bcb597871b1337824fba0f5e7b8c4491b2f6c51f910a631ed2c
lintian                     no dice nada     (control: lintian v2.117.0ubuntu1.5 responde)
Depends: encina-branding, encina-firefox-native, autofirma, hunspell-es,
         language-pack-es, language-pack-gnome-es, simple-scan, sane-airscan, snapd
entradas AppleDouble dentro del .deb: 0      (control de la trampa 24)
CI: verde
```

**`snapd` entra en `Depends:` y es el patrón de `sane-airscan`**: cuesta 0 paquetes
—ya está en toda máquina desde D16— y va declarado para que un cambio de la base no
se lo lleve en silencio. **Un `.deb` no puede declarar un snap**, así que lo que se
declara es el motor sin el cual no hay tienda ninguna.

**Y aquí está el hallazgo de método: la lista de «cuatro cosas» de `SCRIPTS.md` está
INCOMPLETA.** Cambiar un `.deb` toca cuatro cosas; **cambiar lo que el producto
LLEVA toca dos más**, y las dos muerden en sitios distintos:

```
5. imagen/encina-seed.sh      lleva la LISTA DE LO QUE TIENE QUE ESTAR
6. imagen/verificar-e2.sh     lleva la MISMA LISTA, por su cuenta
```

Las dos se cazaron **midiendo, no leyendo**, y cada una costó una vuelta:

- La **quinta** salió en la primera instalación: `ESTADO=INCOMPLETO`, con
  `ENCINA_FALTA=gnome-software gnome-software-plugin-snap`. **Y esto es un
  regalo, no un fallo: el nivel 2 de §4.27 se disparó SOLO, en un caso real y no
  provocado.** La casilla que E4 marcó el 2026-08-12 acaba de demostrarse sin que
  nadie la provocara.
- La **sexta** salió al verificar la máquina buena: **47 correctas y 2 fallos, los
  dos del verificador**, que seguía exigiendo `gnome-software`. Es la trampa 27
  otra vez —una rama que no se ejecuta desde que se tocó no está medida, está
  escrita—.

Corregidas las dos, y **la tienda pasa a comprobarse donde de verdad está**: no con
`dpkg-query`, que nunca la vería, sino con `snap list`, más el `.snap` sembrado y su
lanzador en `/target`; y `gnome-software` se comprueba **ausente**, que es lo que
distingue «una tienda» de «dos».

#### (i) LA INSTALACIÓN LIMPIA, de punta a punta

Máquina `encina-E4-tienda`, creada desde cero, con el `CIDATA` nuevo
(`f99324ff…`, 768 MiB) sobre la ISO `aa1ac76a…` verificada por huella. Control de
la trampa 16 recogido **antes** de arrancar: **1** `-append`, la palabra
`autoinstall` **suelta** leída en la línea de órdenes real de QEMU, y cinco
unidades.

```
se apago sola en 9 min           = ESTADO=COMPLETO (el seed sale != 0 si no lo esta)
testigo: encina-seed llego al final 2026-08-12T22:55:41Z estado=COMPLETO

encina-meta 0.2.1 · encina-branding 0.1.8 · encina-firefox-native 0.2.1
autofirma 1.9.1+encina4 · firefox 153.0.4~build1 · snapd 2.76+ubuntu24.04.1
simple-scan · sane-airscan · evince        gnome-software -> unknown ok not-installed
snap list -> snap-store rev 1271 · firefox rev 7764 (presente y sin abrir) · snapd

verificar-e2.sh --visibles 27, como root:
  51 correctas · 0 fallos · 0 avisos · 0 omitidas
  iconos de Firefox que ve el usuario: 1
  27 aplicaciones visibles de 95 totales, y COINCIDEN con las 27 declaradas antes
  la tienda: snap-store 0+git.90575829 rev 1271
  gnome-software fuera (unknown ok not-installed)
  control: un snap inventado -> snap list dice que no
```

**El repositorio del medio sigue llevando los tres `.deb` de `gnome-software`**, y
se dice: es un superconjunto, ya nadie los instala, y quitarlos tocaría el nivel 3
de §4.27, que está a medias.

#### (j) EL ERROR `QEMU error … Invalid argument`, que llevaba sesiones saliendo — CAUSA CERRADA

Lo levantó Jorge a media medición: *«este error lo hemos visto muchas veces ya»*.
§4.24 lo daba por inocuo con `errors_count 0`, que es un acto de fe. **Ahora está la
causa, y con ella el motivo por el que es inocuo.**

La unidad del error es **el disco de destino**, y UTM lo declara así —leído en la
línea de órdenes real, no supuesto—:

```
-drive if=none,media=disk,id=drive4BA4F79A-…,file.filename=…/disco.img,
       discard=unmap,detect-zeroes=unmap
```

`discard=unmap` hace que QEMU **anuncie TRIM al invitado**. Cuando el invitado lo
usa, QEMU perfora agujeros en el fichero con `fcntl(F_PUNCHHOLE)`. Medido en C
sobre un fichero disperso en APFS, **con sus dos respuestas**:

```
alineado 4K, zona escrita         offset=0          len=4096      OK
alineado, 1 MiB                   offset=0          len=1048576   OK
offset NO alineado (512)          offset=512        len=4096      Invalid argument
longitud NO alineada (512)        offset=0          len=512       Invalid argument
longitud no multiplo de 4K        offset=4096       len=4608      Invalid argument
alineado, zona YA dispersa        offset=33554432   len=4096      OK
alineado, PASA DEL FINAL          offset=66060288   len=8388608   OK
```

**APFS exige alineación a 4096 y devuelve `EINVAL` —«Invalid argument»— si no la
hay.** Ni la zona ya dispersa ni pasarse del final fallan: **solo la alineación**.
El instalador emite discards alineados a **512**, que es el sector que virtio-blk
anuncia. De ahí el diálogo.

Reproducido a voluntad desde dentro del invitado, y el control es que **la única
diferencia entre las dos órdenes son 512 bytes**:

```
blkdiscard -o 4096 -l 8192 /dev/vdb   -> rc=0                       dialogos: 0
blkdiscard -o 4608 -l 8192 /dev/vdb   -> BLKDISCARD ioctl: E/S      dialogos: 1
```

**Por eso es inocuo, y ya no por fe:** un discard es una optimización de espacio, no
un dato. Si falla, el sistema de ficheros se crea igual.

**Y el arreglo que parecía bueno NO lo es, medido:** `-set drive.<id>.discard=off`
apaga el diálogo en caliente —el mismo `blkdiscard` desalineado pasa a `rc=0` y
`fstrim` tampoco lo dispara—, **pero ROMPE LA INSTALACIÓN**. Aislado cambiando una
sola variable, que es como debí hacerlo desde el principio:

```
instalacion 1  seed viejo, SIN -set  -> llego al seed (INCOMPLETO por la lista vieja)
instalacion 2  seed nuevo, CON -set  -> se atasca en 9502 MB, el seed NO corre
instalacion 3  seed nuevo, CON -set  -> se atasca en 9502 MB, el seed NO corre
instalacion 4  seed nuevo, SIN -set  -> 11002 MB, se apaga sola, ESTADO=COMPLETO
```

Con `-set` no hay testigo, no hay `/etc/encina-seed.log` y no hay `encina-meta`: el
instalador cae **antes** de las `late-commands`. **Conclusión: el diálogo se queda,
y se queda sabiendo por qué sale y por qué no hace daño.** Quitarlo de verdad pide
que virtio-blk anuncie sectores de 4096, y UTM no lo expone.

#### (k) Y una causa de banco que no era del producto: EL MAC SE DUERME

La instalación 2 se paró a mitad. **La hipótesis la puso Jorge y el registro del
propio Mac la confirmó**, que es el dato que ninguna VM podía dar:

```
2026-08-12 23:02:12  Entering Sleep state due to 'Maintenance Sleep' … Using Batt (86%)
   … ciclos de sueno hasta …
2026-08-13 00:09:05  Wake … due to MTP.DOCK…/HID Activity     <- Jorge toca el trackpad
pmset: sleep 1   (a bateria)
```

El anfitrión se durmió **a mitad de instalación** y el instalador cascó por ahí
(`apport`: *«System program problem detected … ubuntu-desktop-bootstrap»*). Encaja
con que el bucle de vigilancia no imprimiera **ni una línea** en diez minutos:
`delay` tampoco avanza con el Mac dormido.

**Y una corrección mía, que va escrita porque casi la doy por prueba:** dije que el
reloj del invitado parado en `22:12` demostraba la suspensión. **No demostraba
nada**: el invitado iba en UTC y el anfitrión en CEST, así que `22:12` UTC era la
hora real. La prueba buena es `pmset -g log`, que es de otro sitio y no depende de
mi interpretación.

**La regla que sale, y vale para toda instalación futura: `caffeinate -dimsu`
mientras dure.** Las instalaciones 3 y 4 se hicieron con él y el Mac no durmió.

#### (l) Un instrumento nuevo que el banco no tenía: leer la pantalla sin ojos

Cuando dejaron de poder cargarse capturas, el diagnóstico se cerró con **OCR
nativo** (Vision de macOS, 25 líneas de Objective-C compiladas con `clang`).
Validado **contra una captura que ya se había mirado con los ojos** antes de
usarlo para nada: devolvió «Centro de aplicaciones», «Explorar», «Destacado».

Y con él se leyó la pantalla que estaba bloqueando la medición:

```
Se produjo un problema · System program problem detected
sudo ubuntu-bug ubuntu-desktop-bootstrap
```

**Dos detalles del instrumento que costaron un rodeo cada uno:** `screencapture` a
pantalla completa coge la ventana del editor, porque el proceso que lanza la orden
roba el foco —hay que activar UTM, leer posición/tamaño y capturar **dentro del
mismo AppleScript**, con `-R`—; y `Quartz` no está en el Python del sistema, así
que la vía del `windowid` no sirve aquí.

#### (m) Lo que esta medición NO contesta

- **No se ha probado quitar `snap-store`.** Sigue siendo cirugía sobre un snap
  pre-sembrado, y la vía estrecha de §4.16l sigue **sin medir**. No hacía falta:
  la decisión fue quedarse con ella.
- **El `[OJOS]` de la tienda única está medido sobre el CLON, no sobre la
  instalación limpia.** En la máquina final la tienda única está medida por
  inventario (27 visibles, 1 tienda, `gnome-software` ausente), no en pantalla.
- **No se ha medido que la tienda INSTALE algo.** Se midió que abre, que carga
  catálogo y que encuentra; nadie pulsó «Instalar». Instalar un snap desde ella
  metería una aplicación en la máquina y es otra medición.
- **Quién retiene `snapd` en la máquina del producto no se midió.** Se midió que
  `autoremove` **no** lo propone, que es lo que decide; el `Depends: snapd` de la
  0.2.1 lo declara de todas formas.
- **No se ha vuelto a firmar.** §4.33 salió sobre la forma (c) con `gnome-software`
  dentro; nada de lo que cambia aquí toca las seis barreras, pero **no se ha
  remedido**.
- **El error de QEMU se queda.** Su causa está cerrada y su arreglo por `-set`
  está **descartado por medición**, no por sospecha.
- **amd64, nada.** D9 sigue igual.

---

### 4.35 LA ISO QUE SE ENTREGA LLEVABA LA TIENDA VIEJA — refabricada, arrancada y probada (2026-08-13)

**E4 estaba terminado 13 de 13 y el entregable no lo reflejaba.** La ISO vigente
`aa1ac76a…` llevaba dentro `encina-meta` **0.2.0**, o sea que quien la instalara
**hoy** se encontraba las DOS tiendas que D18 reescrita quitó ayer. No había
ninguna decisión de producto que tomar: había que refabricarla y demostrarla
arrancándola.

**Y el defecto era MÁS GRANDE de lo que decía el encargo**, que es lo primero que
hay que llevarse: no bastaba con cambiar el `.deb` del repositorio.

#### (a) Qué se daría por sano y qué por roto, escrito ANTES de tocar nada

| Comprobación | Sano | Roto |
|---|---|---|
| El defecto, reproducido | La ISO vigente lleva `encina-meta_0.2.0_all.deb` y su `Packages` dice `Version: 0.2.0` | No lo lleva → el encargo parte de una premisa falsa, parar |
| El repositorio nuevo | **28** `.deb`, el índice los describe **en las dos direcciones**, y la huella vieja `85c8cc56…` **ausente** | Cualquier descuadre, o que quede rastro del 0.2.0 |
| El control negativo | Con el `.deb` viejo bajo el nombre nuevo, `fabricar-iso.sh` **se niega** y no escribe ISO | La fabrica igual → la herramienta no protege nada |
| La ISO nueva | Huella **distinta** de `aa1ac76a…`, y con el 0.2.1 dentro leído **de la ISO** | Misma huella, o el 0.2.0 dentro |
| Trampa 16, antes de arrancar | `-append` con `autoinstall` **suelto** y **cinco** unidades, leídas en la línea de órdenes real de QEMU | Otra cosa → no sé qué seed va a ganar |
| La instalación | **Se apaga sola** = `ESTADO=COMPLETO`, y el registro dice `REPO ELEGIDO -> /cdrom/encina-repo` | No se apaga, o el repo sale del `CIDATA` → no he probado la ISO |
| La máquina | `verificar-e2.sh --visibles 27` como root: **0 fallos** | Cualquier fallo |
| (d1) **[OJOS]** Una sola tienda **en la instalación limpia** | **1**, «Centro de aplicaciones», y en la rejilla no aparece «Software» ni su bloque de catálogo. *Control:* el contador sabe decir **2** y **0** | 2, o 0, o un contador que da el mismo número siempre |
| (d2) **[OJOS]** La tienda **instala** | Pulsar «Instalar», la aplicación aparece en la rejilla y **abre**. *Control:* `~/snap/` gana `<app>` y sigue con **0** perfiles de Mozilla | No instala → la premisa de D17 se queda a medias |

#### (b) EL DEFECTO, reproducido y no supuesto

Sacado de la ISO vigente con `xorriso -osirrox on -indev … -extract /encina-repo`:

```
29 ficheros restaurados (168,2 MB) = 28 .deb + Packages
encina-meta_0.2.0_all.deb   85c8cc56d586a40d2b6736688591d493bf988b234bff3e331e7c1c642239b596

y lo que ese indice le declaraba a apt, que es lo que decide:
  Version: 0.2.0
  Depends: … simple-scan, sane-airscan, gnome-software, gnome-software-plugin-snap
```

**Las dos tiendas no estaban insinuadas: estaban escritas en el medio.**

#### (c) EL DEFECTO SEGUNDO, que el encargo no contemplaba y cazó el guardián

Con el repositorio ya arreglado, `fabricar-iso.sh` se negó en el paso 3:

```
[FALLO] autoinstall-e3.yaml y encina-seed.sh se han separado.
```

**Ayer se rehizo el seed en UNO de los dos YAML, no en los dos.** `autoinstall.yaml`
—el de E2, el del `CIDATA`— se regeneró en `98f0fb9`; `autoinstall-e3.yaml` —**el que
viaja DENTRO de la ISO**— seguía en `a8fcc89`, del 2026-08-12. Nadie lo notó porque
**ayer no se fabricó ninguna ISO**.

Y lo que llevaba empotrado en base64 no era un detalle:

```
guion empotrado HOY en autoinstall-e3.yaml   27 906 bytes
imagen/encina-seed.sh (el bueno)             28 860 bytes

lo que EXIGIA el que viajaba:   H_META=85c8cc56…   <- la huella del 0.2.0
                                simple-scan gnome-software gnome-software-plugin-snap
lo que exige el bueno:          H_META=86da3cc9…   snap-store por `snap list`
                                gnome-software comprobado AUSENTE
```

O sea que una ISO con el repositorio corregido y el seed viejo **habría rechazado su
propio `.deb`** por huella. Puesto al día con la herramienta versionada
(`--actualizar-yaml`), y **cambió UNA sola línea**, la 83, con el control de que el
fichero contra sí mismo da 0.

**La regla de `SCRIPTS.md` era buena y estaba incompleta: cuando cambia lo que el
producto lleva no son seis cosas, son SIETE — y la séptima es que la quinta hay que
hacerla DOS VECES, una por cada YAML.**

#### (d) EL REPOSITORIO, con las dos direcciones y sus controles

`dpkg-scanpackages` se corrió en `encina-dev`, identificada **por huella** y no por
nombre (snap `firefox 153.0.3-1` rev 8735, `/home/prueba`, `encina-branding 0.1.7`).
Los 28 `.deb` viajaron con `COPYFILE_DISABLE=1` —la trampa 24, que aquí muerde más
fuerte porque las entradas que inventa `tar` **terminan en `.deb`** y `dpkg-scanpackages`
las indexaría—:

```
entradas AppleDouble que llegaron: 0          .deb que llegaron: 28
CONTROL: las 28 huellas del Mac y de la VM, iguales
CONTROL del comparador: consigo mismo 0 diferencias; saboteado, las senala
```

El índice nuevo, y **el diff contra el viejo, que es lo que convierte «lo he
regenerado» en una medición**:

```
Version: 0.2.1        Filename: ./encina-meta_0.2.1_all.deb    Size: 6912
Depends: … simple-scan, sane-airscan, snapd
SHA256: 86da3cc9ec071bcb597871b1337824fba0f5e7b8c4491b2f6c51f910a631ed2c

la huella vieja 85c8cc56… en el indice nuevo:  0   (control: la nueva sale 1)
«0.2.0» en el indice nuevo:                    0
el diff viejo/nuevo cae ENTERO dentro de la estrofa de encina-meta:
  las otras 27 estrofas, byte a byte iguales   (control: el viejo contra si mismo, 0 lineas)

direccion 1: 28 entradas de Packages, 28 ficheros, 0 malas
direccion 2: 28 .deb, 0 huerfanos
CONTROL: con un .deb de mas, la direccion 2 lo ve; con un Filename inventado, la 1 lo ve
```

#### (e) EL CONTROL NEGATIVO: cuesta diez segundos y hay que hacerlo

Con el `.deb` **viejo** bajo el nombre **nuevo**:

```
[OK]    encina-firefox-native_0.2.1_all.deb  972ec932…
[FALLO] huella distinta en encina-meta_0.2.1_all.deb
y NO escribio ninguna ISO: No such file or directory
```

Se niega **en el paso 2**, antes de tocar un byte del medio. Por eso el control
negativo es gratis: no cuesta 3,5 GB, cuesta cero.

#### (f) LA ISO NUEVA, y una cosa que conviene saber: PESA LO MISMO QUE LA VIEJA

```
ac0a5721b9ff5b2b762d3467bbc20d8e62374df22a5d18e3c483f8c25b1fa443  encina-os-E4-es-0.2.1.iso
3 715 366 912 bytes

aa1ac76a31afd75506b862eb6da9599bd53638dcdaa8aa0fbb07e625716c08cb  (la vieja)
3 715 366 912 bytes    <- EXACTAMENTE LOS MISMOS
```

**El tamaño no discrimina: la huella sí.** Los dos `.deb` se diferencian en 1 516
bytes y el medio los alinea al mismo número de bloques.

Todos los controles del guion, en verde y sin aflojar ninguno:

```
los tres binarios firmados     intactos por huella, antes y despues
la ESP                         byte a byte la oficial en sus 13 504 sectores
                               y los 640 de mas son relleno: 0 bytes distintos de cero
la FORMA de arranque           MBR hibrido, El Torito y plataforma UEFI, iguales
el medio entero                501 entradas la oficial, 531 la nuestra
                               30 anadidos, ni uno mas, ninguno perdido
                               2 modificados y nombrados: grub.cfg y md5sum.txt
control                        con una huella saboteada, la comparacion la senala
integridad                     las 266 lineas de md5sum.txt cuadran
control                        con el md5sum.txt OFICIAL falla exactamente UNA, la del grub.cfg
```

Y lo que lleva dentro, **leído de la ISO y no del directorio de donde salió**:

```
28 .deb    encina-meta_0.2.1_all.deb   86da3cc9…   Version: 0.2.1
           Depends: … simple-scan, sane-airscan, snapd
el 0.2.0 y su huella: 0 y 0        CONTROL: la misma busqueda sobre la ISO VIEJA da 1
```

#### (g) LA INSTALACIÓN: `encina-E4-entrega`, y el repositorio sale de `/cdrom`

VM nueva desde cero, con la ISO **enlazada en duro** (`2 enlaces`, que es lo que un
clon de APFS nunca dice) y un `CIDATA` de 128 MiB con el YAML de E2 y **ningún
`encina-repo` dentro** —la salida barata de `SCRIPTS.md`, que fuerza a que el
repositorio salga del medio—:

```
seed 53479f61…    dentro: user-data, meta-data
/Volumes/CIDATA/encina-repo -> No such file or directory
CONTROL: el mismo ls SI encuentra user-data, o sea que no esta mudo
CONTROL: user-data y meta-data sobreviven byte a byte
```

Y el `Image` y el `initrd` de `e2-medios` se comprobaron **contra esta ISO** en vez de
darlos por buenos, que es donde casi me equivoco: `initrd` coincide byte a byte, y
`Image` **no** coincide con `/casper/vmlinuz`… porque es su **descompresión**:

```
gunzip -c /casper/vmlinuz de la ISO nueva -> a1586ff3cb7ced7c40dcb0aba5bf320ebb94a46d1a6505eb03157a8f9525632d
e2-medios/Image                          -> a1586ff3cb7ced7c40dcb0aba5bf320ebb94a46d1a6505eb03157a8f9525632d
```

**El control de la trampa 16, recogido en la línea de órdenes real de QEMU:**

```
-append autoinstall        <- 1, y la palabra SUELTA
unidades con media=        <- 5:  2 media=disk (disco.img, seed.img)
                                  3 media=cdrom (la ISO NUEVA, Image, initrd)
-kernel Image  -initrd initrd  -no-reboot
```

**Y lo que dejó escrito la máquina sola, que es lo que decide:**

```
se apago sola en 9 min           = ESTADO=COMPLETO
testigo: encina-seed llego al final 2026-08-13T00:06:03Z estado=COMPLETO

  CIDATA -> /dev/vdb                     <- el seed lo dio el volumen
  REPO ELEGIDO -> /cdrom/encina-repo     <- EL REPOSITORIO SALIO DE LA ISO NUEVA
  ls /target/srv/encina-repo | wc -l  -> 29     (28 .deb + Packages)
ENCINA_ESTADO=COMPLETO   ENCINA_FALTA=

y en la maquina instalada:
  /srv/encina-repo/encina-meta_0.2.1_all.deb   86da3cc9…
  encina-meta 0.2.1 · encina-branding 0.1.8 · encina-firefox-native 0.2.1
  autofirma 1.9.1+encina4 · firefox 153.0.4~build1 · snapd 2.76+ubuntu24.04.1
  gnome-software -> unknown ok not-installed
  snap list -> snap-store rev 1271 · firefox rev 7764 (presente y sin abrir)
  CONTROL: un snap inventado -> «no hay snaps instalados que coincidan»
  CONTROL: un .deb inventado -> «no se ha encontrado ningun paquete»

verificar-e2.sh --visibles 27, como root:
  51 correctas · 0 fallos · 0 avisos · 0 omitidas
  1 icono de Firefox · 27 aplicaciones visibles de 95, y COINCIDEN con las declaradas
```

**El mismo resultado que `encina-E4-tienda`, por un camino distinto: aquélla nació de
la ISO vieja con un `CIDATA` que llevaba el repositorio dentro; ésta nace de la ISO
nueva y el repositorio le sale del medio.**

#### (h) (d1) [OJOS] UNA SOLA TIENDA, sobre la INSTALACIÓN LIMPIA — la casilla que §4.34 dejó sobre el clon

Sesión gráfica de verdad, con autologin de GDM activado por `ssh` y **revertido por
huella** al terminar —la misma vía de §4.34c, y la huella de virginidad salió
`ceee968ce0212138…`, que es **exactamente la que documenta §9**, o sea el fichero de
fábrica intacto—.

La misma búsqueda «softw» de §4.34f, ahora sobre la instalación limpia:

```
Actualizacion de software · Programas y actualizaciones · Mas controladores ·
Centro de aplicaciones
y NADA MAS: ni «Software», ni el bloque de catalogo «Software, 15 mas»
```

**Mirado con los ojos en la captura**, y el contador al lado, con su control:

```
aplicaciones visibles: 27 de 95
TIENDAS VISIBLES: 1     snap-store_snap-store.desktop | Centro de aplicaciones
control: con org.gnome.Software.desktop anadido, el contador dice 2
control: quitando las dos, el contador dice 0
idioma que ve el proceso: ['es_ES.UTF-8','es_ES','es.UTF-8']   (setlocale, trampa 26bis)
```

**Y de propina, en la rejilla los nombres salen en español** —«Actualización de
software», «Visor de documentos», «Escáner de documentos», «Editor de textos»—, que
es §4.31j confirmado sobre una máquina distinta.

#### (i) (d2) LA TIENDA INSTALA — **CERRADA, y la pulsó Jorge**

**La tienda abre, carga catálogo y encuentra LibreOffice en la instalación limpia**, y
eso sí está medido:

```
abierta DESDE LA REJILLA (buscar «Centro de apl» -> un solo resultado -> Return)
proceso: /snap/snap-store/1271/bin/snap-store
ventana «Centro de aplicaciones», menu Explorar · Destacado · Productividad ·
        Desarrollo · Juegos, catalogo cargado

buscar «libreoffice»:
  Paquetes snap      -> libreoffice, Cantara
  Paquetes de Debian -> LibreOffice Writer, LibreOffice Impress, LibreOffice Calc

la ficha del snap, y EL COSTE DICHO ANTES DE PULSAR:
  libreoffice · Canonical (verificado) · Productividad
  Canal latest/stable 26.2.5.2 · Confinamiento Estricto · Licencia MPL-2.0
  Tamano de la descarga: 1.17 GB
```

**Lo que NO conseguí es pulsar «Instalar»**, y las cuatro vías se dicen porque cada
una es un dato del banco:

```
1. clic del anfitrion (System Events) sobre el boton   -> 0 pixeles cambian
   y sobre «Juegos» de la barra lateral, blanco inequivoco -> 0 pixeles cambian
2. UTM «input scan code» / «input mouse click»          -> nada
3. teclado: Tab SI llega (mueve el anillo fuera de la busqueda, medido),
   pero el foco no aterriza NUNCA en el boton; Return y Espacio no lo activan
4. accesibilidad (at-spi): la tienda SI aparece en el escritorio de a11y,
   pero su arbol sale truncado -29 nodos, 2 botones SIN NOMBRE- y
   queryAction/getExtents dan «timeout from dbind»
5. teclas del raton de GNOME: el teclado numerico DESPLAZA LA PAGINA
   en vez de mover el puntero
```

**Y no lo he sustituido por un `snap install` desde un terminal**, que era la salida
fácil: eso mide que *snapd* instala, no que *la tienda* instala, y sería otra
medición con el nombre de ésta. **La casilla se queda abierta.**

**Y LA PULSÓ JORGE, la misma tarde**, que es exactamente lo que §4.32h hizo con las
dos últimas pantallas de E3 y **no afloja la casilla**: lo que un `[OJOS]` prohíbe es
una orden, un fichero o una edición, y de eso no hubo ninguno. Yo no toqué el ratón.

```
snap changes
  3  Done  08:12 UTC -> 08:22 UTC   Instalar snap "libreoffice" desde el canal "latest/stable"
```

**Diez minutos, y la instalación la registra la máquina sola.** El después, contra el
antes que se tomó antes de encender:

```
snaps        ANTES  8   DESPUES 12
  +libreoffice 376   +core24 1644   +gnome-46-2404 154   +mesa-2404 1836
  (los tres ultimos son dependencias que la tienda trajo sin preguntar)

aplicaciones visibles  ANTES 27   DESPUES 34
LO QUE ENTRO, NOMBRADO UNO A UNO:
  libreoffice_libreoffice.desktop | LibreOffice 26.2
  libreoffice_base.desktop        | LibreOffice 26.2 Base
  libreoffice_calc.desktop        | LibreOffice 26.2 Calc
  libreoffice_draw.desktop        | LibreOffice 26.2 Draw
  libreoffice_impress.desktop     | LibreOffice 26.2 Impress
  libreoffice_math.desktop        | LibreOffice 26.2 Math
  libreoffice_writer.desktop      | LibreOffice 26.2 Writer
TIENDAS VISIBLES: sigue 1     control: el contador sigue sabiendo decir 2 y 0

lo que ocupa, MEDIDO y no estimado:
  se declararon 1,17 GB de descarga
  el .snap en disco            1,1 GB
  el disco del invitado        11G -> 13G usados   = 2 GiB reales
  el disco del anfitrion       -1,60 GiB           <- menos, porque el disco es disperso
```

**Y ABRE**, lanzada **desde la rejilla** —buscar «writer» → `Return`—, no desde un
terminal:

```
proceso: 7492 /snap/libreoffice/376/lib/libreoffice/program/soffice.bin --writer
ventana: «Sin titulo 1 - LibreOffice Writer»
menus:   Archivo · Editar · Ver · Insertar · Formato · Estilos · Tabla ·
         Formulario · Herramientas · Ventana · Ayuda
barra de estado: «Espanol (Espana)»
```

**El cheque de D17 está cobrado entero:** «que lo instale el usuario» tiene detrás una
tienda que abre, que encuentra, **que instala** y una aplicación que **arranca en
español**.

#### (ñ) Y LA FORMA (c) SIGUE EN PIE DESPUÉS, con el control que la hace valer

Primero una corrección de lo que yo había escrito: **instalar un snap NO crea
`~/snap/<app>`; lo crea la PRIMERA EJECUCIÓN.** Medido en los dos momentos:

```
tras INSTALAR   ~/snap: snapd-desktop-integration, snap-store        (no esta libreoffice)
tras ABRIRLO    ~/snap: libreoffice, snapd-desktop-integration, snap-store
                ~/snap/libreoffice: 376, common, current
```

Y con ese directorio ya existiendo:

```
perfiles de Mozilla bajo ~/snap/: 0
  control A: el buscador encuentra .bashrc                        -> 1
  control B: el buscador sabe decir cero                          -> 0
  control C: el MISMO buscador sobre ~/snap encuentra algo        -> 3
  control D: el MISMO patron sobre un perfil FABRICADO a proposito -> 1
```

**El control D es el que lo cierra**, y es el que faltaba en las veces anteriores: no
basta con que el buscador sepa encontrar *algo*, tiene que saber encontrar **lo que
busca** — un `.mozilla/firefox/profiles.ini` — el día que exista. Se fabricó uno falso
en `/tmp`, se comprobó que lo ve, y se borró. **La comprobación sabe dar sus dos
respuestas.**

Y la máquina entera, con LibreOffice dentro y abierto:

```
verificar-e2.sh --visibles 34, como root:
  51 correctas · 0 fallos · 0 avisos · 0 omitidas
  iconos de Firefox que ve el usuario: 1
  34 aplicaciones visibles de 102, y COINCIDEN con las declaradas
  forma (c): snapd + Snap de Firefox instalado y NUNCA abierto   <- la de D16
  la tienda: snap-store rev 1271        gnome-software fuera
```

**UN EFECTO QUE NADIE PIDIÓ Y HAY QUE DECIR: `snapd` se autorrefrescó solo.** Al
empezar la instalación disparó `Autorefrescar los snaps "core22", "firefox"`, y el
Snap de Firefox pasó de **rev 7764 a rev 8753** sin que nadie lo tocara:

```
/snap/firefox/7764   /snap/firefox/8753   /snap/firefox/current
```

**No rompe nada, y se dice por qué en vez de darlo por bueno:** refrescar no es abrir,
así que siguen los **0** perfiles bajo `~/snap/`, y el lanzador que ve el usuario sigue
siendo la sombra de `encina-firefox-native` en `/usr/share/applications` —que gana a
`/var/lib/snapd/desktop/applications` por orden de `XDG_DATA_DIRS` y lleva
`NoDisplay=true`—. El verificador sigue clasificando la máquina como **forma (c)**,
y su dato «revisiones de firefox en `/snap`» pasa de **1 a 2**, que es dato y no
casilla. **Lo que sí cambia es la huella escrita de esta máquina**, y por eso va aquí.

**Y lo que NO se hizo, con su motivo:** la tienda ofrecía «Actualizar todo» con cinco
snaps. No se pulsó. Habría metido cuatro variables más —`snapd`, `core22`,
`gnome-42-2204`, `snapd-desktop-integration`— en mitad de una medición y sobre la
máquina que **es el entregable**, y hoy no compraba nada. Es la regla de la trampa 32.

#### (j) UN REGALO, como el de §4.34h: D16 demostrada por un acto de usuario real

Una tecla que se me escapó en el asistente de bienvenida abrió el enlace «Ver
novedades de la versión». **El navegador que salió, en la instalación limpia y sin que
nadie lo provocara:**

```
2276 /usr/bin/firefox http://www.ubuntu.com/getubuntu/releasenotes?os=ubuntu&ver=24.04
2281 /usr/lib/firefox/crashhelper …
2367 /usr/lib/firefox/firefox-bin -contentproc …
```

**El nativo, no el del Snap.** La condición de D16 —*el Firefox que el usuario puede
abrir es el nativo*— estaba medida por inventario; aquí está medida **por lo que pasó
cuando alguien pulsó**. Y `~/snap/` siguió con 0 perfiles de Mozilla.

#### (k) EL INSTRUMENTO, y los TRES sitios donde §4.32h se queda corto

El lector de pantalla sin ojos se rehízo y **esta vez vive en `scripts/`**
(`leer-pantalla.m`, 25 líneas de Objective-C contra Vision, más `capturar-vm.sh` y
`teclear-vm.sh`). Validado **contra una captura ya mirada con los ojos**, y con su
control:

```
captura ya mirada -> «Display output is / not active.»   (lo que yo habia visto)
negro puro        -> 0 lineas                            (sabe decir NADA)
```

**1. No basta con `AXRaise`: la ventana tiene que quedar `AXMain`.** Con `AXRaise`
sola la ventana se ve delante, **la captura sale bien y las teclas no llegan**, sin
ningún error. Media hora de teclas al vacío. La señal que lo delata es la de la
trampa: el reloj del invitado avanza y la pantalla no cambia.

**2. El ratón NO llega, y ahora está medido con un control que no admite lectura
subjetiva.** §4.32h lo decía; aquí se comprueba comparando **píxel a píxel** dos
capturas alrededor de un clic sobre un blanco inequívoco: **0 píxeles distintos**. El
comparador es un decodificador de PNG propio (`diferencia.py`), con su control: contra
sí mismo dice 0 y contra otra imagen da la caja de las diferencias.

**3. El atajo de la rejilla no es `Alt+F1` desde un Mac: es `Super+A`, o sea `Cmd+A`.**
GNOME tiene `panel-main-menu` en `<Alt>F1`, pero **en un Mac `F1` es tecla de brillo y
no llega a la aplicación**. `show-applications` está en `Super+A` y `Cmd` sí se traduce
a `Super`.

#### (l) EL COSTE, medido y no predicho — y un borrado que devolvió CERO

```
libres al empezar    58 839 700 KiB = 56,109 GiB     10 VMs, las 10 paradas
libres al terminar   43 156 232 KiB = 41,157 GiB     11 VMs, las 11 paradas
                     -----------------------------
GASTADO                              14,952 GiB      (se declararon ~14)
```

Dónde se fue: la ISO nueva (3,46 GiB), `encina-E4-entrega` (11 GiB según `du`, y aquí
`du` acierta porque nace del medio, §9.a), el `CIDATA` (0,125 GiB).

**Y AQUÍ HAY UNA FILA NUEVA PARA §9.a, Y ES LA MÁS EXTREMA: borrar la ISO vieja de
3,46 GB devolvió CERO.**

```
df ANTES de borrar   43 157 080 KiB
rm de encina-os-E4-es.iso (3 715 366 912 bytes)
df DESPUES           43 157 052 KiB      <- devolvio 0 (bajo 28 KiB, que es el .deb que guarde)
```

Y **antes** de borrar se había descartado la trampa 21 midiendo, no suponiendo:
`1 enlace`, y **ningún bundle vivo llevaba la ISO dentro** —`encina-E4-cinco` y
`encina-E4-tienda` ya no la tenían—. O sea que **predije 3,46 GiB y me equivoqué**.

**El control que convierte esto en un hallazgo en vez de en un misterio:**

```
dd de 3 GiB en el MISMO directorio  -> df baja 3 154 840 KiB
rm de esos 3 GiB                    -> df los devuelve enteros
```

**El disco SÍ libera; esos 3,46 GB no estaban donde yo creía.** Y las dos
explicaciones fáciles quedan descartadas: `tmutil listlocalsnapshots /` está **vacío**,
no hay ningún otro fichero de 3 715 366 912 bytes en el contenedor ni en el home
—`encina-os-E4-es-0.2.1.iso` tiene **otro inodo**—, y ningún proceso retiene el fichero
borrado *(la línea `deleted` que salió en `lsof` es un proceso de macOS que se llama
así, no un fichero retenido: lo digo porque llegué a leerlo mal)*.

**Queda medido y SIN EXPLICAR, que es mejor que inventarle una causa** (§9.a, tercera
regla). Lo que la fila añade a la tabla: la mentira de `du` tenía su simétrica sin
escribir —**un fichero que `du` cuenta y cuyo borrado no devuelve nada, sin ser clon
de nada que se pueda encontrar**—.

Y antes de borrarla se guardó lo único que no se puede rehacer de la ISO vieja:
`e2-medios/encina-meta_0.2.0_all.deb` (`85c8cc56…`, 5 396 bytes). Con él, el
`fabricar-iso.sh` versionado y el `autoinstall-e3.yaml` de `a8fcc89`, la ISO vieja es
reproducible; sin él, no.

#### (m) El estado del banco al terminar

```
11 en utmctl list y 11 bundles en disco: consistente por las dos mitades (trampa 18)
las 11 paradas
e2-medios: encina-os-E4-es-0.2.1.iso (ac0a5721…) · encina-os-E3-es.iso (02ab929d…)
           ubuntu-24.04.4-desktop-arm64.iso (c2610520…) · encina-meta_0.2.0_all.deb
```

**La ISO nueva conserva la versión en el nombre a propósito**: `encina-os-E4-es.iso` a
secas ya significó dos artefactos distintos con el mismo nombre, y (f) enseña que el
tamaño no los separa.

**`encina-E4-entrega` se queda como la máquina del entregable**, y con ella
**`encina-E4-tienda` pasa a ser candidata a borrar**: hace lo mismo por un camino peor
—nació de la ISO defectuosa— y su ISO **ya no vive en `e2-medios`, así que §9.a no
dejaría borrarla sin decirlo**. Es de Jorge decidirlo; yo no borro VMs que no he
creado.

#### (n) Lo que esta vuelta NO contesta

- ~~**Que la tienda INSTALE.**~~ **CONTESTADO el mismo día, y lo pulsó Jorge** (i):
  10 min, `snap changes` lo registra, 27 → 34 aplicaciones visibles con las siete
  nombradas, y **abre desde la rejilla en español**. La forma (c) sigue en pie con el
  control D, que es nuevo (ñ).
- **QUE UN AGENTE PUEDA PULSAR UN BOTÓN DEL INVITADO. Sigue sin poderse**, con cinco
  vías descartadas y medidas (i). Lo que cerró la casilla fue una mano, no un
  instrumento — y eso hay que tenerlo escrito antes de escribir la siguiente casilla
  `[OJOS]`, no después.
- **Si el autorrefresco de `snapd` puede romper algo alguna vez.** Hoy no rompió nada
  y se midió (ñ), pero **nadie lo pidió y nadie lo controla**: la máquina del producto
  se refresca sola cuando le parece. No se ha medido qué pasa si un refresco cambia el
  lanzador del Snap de Firefox.
- **Qué hace «Actualizar todo».** No se pulsó, con motivo (ñ).

#### (o) LA LIMPIEZA: `encina-E4-tienda` se va, y una condición de §9.a NO se cumplía

Decidido por Jorge al cerrar la sesión. **Su papel estaba traspasado**: `encina-E4-entrega`
hace lo mismo por mejor camino —nace de la ISO corregida, con el repositorio saliendo
del medio— y encima lleva las dos casillas `[OJOS]` de esta vuelta.

**Y la condición de §9.a NO se cumplía, así que se dice antes en vez de descubrirse
después:** *comprobar por huella que su ISO vive también en `e2-medios`*. **No vive:**
`aa1ac76a…` se había borrado esa misma madrugada, en (l). Se borró igualmente porque lo
decidió Jorge, y queda escrito que se hizo sin esa condición.

Lo que sí se comprobó antes de tocar nada:

```
parada                                     stopped
clon de ISO dentro del bundle (trampa 21)  ninguno
su seed                                    f99324ff…  (reproducible con fabricar-seed.sh)
respaldo del registro                      hecho ANTES, plutil -lint OK
```

**Y el retorno, medido con las dos lecturas pegadas al borrado:**

```
df ANTES   40 607 152 KiB
utmctl delete 86AA1724-…
df DESPUES 52 689 940 KiB
           ---------------
DEVUELTO   12 082 788 KiB = 11,523 GiB      y `du` decia 12G  <- AQUI du ACERTO
```

**Segunda aparición de la fila «independiente» de §9.a**, y confirma la regla: una
máquina nacida de la ISO no comparte bloques con nadie, así que `du` no miente sobre
ella. Registro consistente por las dos mitades: **10** en `utmctl list` y **10**
bundles.

**Y UN HALLAZGO DEL BANCO QUE SALIÓ AL INTENTAR SALVAR SU RASTRO: `debug.log` NO ES UN
REGISTRO, ES UN VOLÁTIL.** Antes de borrar se copió su `debug.log` a `e2-medios` para
conservar la evidencia del control de la trampa 16 que §4.34i cita —«1 `-append` y
cinco unidades»—. **No estaba:**

```
rastro-encina-E4-tienda/debug.log   -append: 0    media=disk: 2
CONTROL, encina-E4-entrega arrancada hoy:  -append: 0    media=disk: 2
```

**UTM lo reescribe en cada arranque**, así que lo que queda es la línea de órdenes del
**último** inicio, no la de la instalación. Las dos máquinas dicen lo mismo, y las dos
se instalaron con `-kernel`, `-append autoinstall` y cinco unidades. **Consecuencia de
método: el control de la trampa 16 hay que LEERLO Y TRANSCRIBIRLO en el momento**, como
se hizo en (g) y en §4.34i — el fichero que lo contiene no sobrevive al siguiente
arranque. La transcripción de la medición **es** la evidencia; no hay copia de
seguridad detrás.

Se conservó igualmente `e2-medios/rastro-encina-E4-tienda/` (119 KB: `debug.log`,
`screenshot.png` y `config.plist`), **diciendo lo que es y lo que no es**.
- **Las cinco pantallas de esta ISO.** No se repiten a propósito: la forma no ha
  cambiado y las cerró `encina-E4-cinco` (§4.32f). Lo que aquí no se mide es que el
  `autoinstall.yaml` de **dentro** de la ISO se lea desde `/cdrom` — lo gana el
  `CIDATA` (trampa 16, usada a favor).
- **No se ha vuelto a firmar.** Quitar una tienda no toca ninguna de las seis
  barreras, y nada de lo medido hoy lo reabre.
- **Por qué borrar 3,46 GB devolvió cero.** Está en (l), con su control, y sin causa.
- **amd64, nada.** D9 sigue igual.

---

### 4.36 EL MEDIO YA SE FABRICA DESDE CERO: `cosechar-repo.sh`, y la ISO sale a DOS BYTES (2026-08-13)

**El agujero que cierra esta vuelta, con la forma que tenía escrita:** para
fabricar la ISO hacía falta la ISO anterior, porque los 28 `.deb` de
`/encina-repo` **solo vivían dentro del medio**. §4.35d cortó la mitad de la
circularidad —la **lista**, con `imagen/repo-manifiesto.tsv`—; faltaba quien
fabricara el directorio. Eso es `imagen/cosechar-repo.sh`, y es toda esta
medición.

#### (a) El coste, dicho ANTES de arrancar nada — y en qué me quedé corto

Se predijo: 124,5 MB de red por los 24 `.deb`, ~3,5 GB por la ISO, pico ~4,0 GB
contra 53,9 GiB libres (`df` medido al empezar: **53 GiB**; y `xorriso`, que lee
el volumen de verdad, dejó escrito `53.9g free`).

**Lo que faltaba en esa cuenta, dicho al descubrirlo y no al final:** los
**índices del archivo**, 33,4 MB comprimidos que en disco son **135 MB**. Total
de red 158 MB. Ocupación real en el pico: **4,5 GB**, no 4,0. Y al terminar,
`df` vuelve a **53 GiB**, o sea que la vuelta salió a cero.

#### (b) Qué se daría por sano y qué por roto, escrito ANTES de tocar nada

| Comprobación | Sano | Roto |
|---|---|---|
| La ISO vigente | `ac0a5721…` | Otra huella → el manifiesto y el medio se han separado, PARAR |
| Las 28 del manifiesto contra los bytes de la ISO | 28 de 28, huella **y** tamaño | Cualquier descuadre → PARAR |
| Control del comparador | Una huella, un tamaño o un nombre saboteados los señala | 28/28 igualmente → no comprueba nada |
| Las 4 `PROPIO` contra `encina-seed.sh` | 0 diferencias | Cualquiera → el seed rechazaría su propio `.deb` |
| La cosecha de los 24 | 24 bajados, 24 huellas cuadran **al llegar** | Cualquier fallo → el guion se niega |
| Disponibilidad en el archivo | Los 24, en la versión exacta | Alguno retirado → **HALLAZGO**, decirlo, y **NO** coger la versión nueva |
| El paso 2 de `fabricar-iso.sh` | Los cuatro por huella y «28 ficheros, viajan 28, y las 28 huellas cuadran» | Cualquier `[FALLO]` |
| La ISO desde el repo cosechado | `ac0a5721…` | Distinta → decir **qué** cambia, no darlo por malo |

#### (c) EL MANIFIESTO SIGUE CUADRANDO, comprobado antes de fiarse de él

Los 28 `.deb` salieron de la ISO vigente con `xorriso -osirrox` (29 ficheros,
168,2 MB = 28 `.deb` + `Packages`) y se cotejaron contra el manifiesto por
**huella y tamaño**:

```
lineas del manifiesto: 28   faltan: 0   descuadres: 0
```

**Y las tres respuestas malas, porque una comprobación que no sabe dar la suya
no es una comprobación:**

```
huella saboteada  -> HUELLA MAL firefox_153.0.4~build1_arm64.deb  manif=000000000000 real=411b2a5790a6
tamano saboteado  -> TAMANO MAL encina-meta_0.2.1_all.deb  manif=6913 real=6912
nombre inventado  -> FALTA      wspanish_9.9.9_all.deb
```

Y las cuatro `PROPIO` contra lo que **exige** `encina-seed.sh`: **0 diferencias**,
con el control de que el mismo `diff` señala una huella cambiada en un carácter.

#### (d) EL GUION, y por qué NO construye la ruta del `pool` a mano

`imagen/cosechar-repo.sh` no deduce la dirección de descarga, la **busca en los
índices del archivo**. No es rodeo: los nombres del `pool` no son deducibles del
nombre del paquete. Medido en Mozilla, que es donde más se ve:

```
manifiesto:  firefox_153.0.4~build1_arm64.deb
pool real:   pool/mozilla/firefox_153.0.4~build1_arm64_af3daf3686cdd1b56adedee5b1733689.deb
```

Y en Ubuntu el directorio depende del paquete **fuente**, que no es el binario
(`libnss3-tools` sale de `nss`, los seis `plymouth*` de `plymouth`, los tres
diccionarios de `libreoffice-dictionaries`). Ocho índices, **106 100 entradas**.

Eso además es lo que le permite dar **tres respuestas distintas** en vez de una,
que es lo que separa un hallazgo de un contratiempo:

```
[OK]           esta, y sus bytes cuadran
[RETIRADO]     el archivo ya no ofrece ESA version   <- decision de producto, no del guion
[OTROS BYTES]  esa version esta, con otra huella     <- el manifiesto se quedo atras
```

#### (e) LOS 24, BAJADOS — y la respuesta a la pregunta que abría el encargo

**Ninguno ha sido retirado. Los 24 se bajaron hoy en la versión exacta del
manifiesto y las 24 huellas cuadraron al llegar.**

```
bajados: 24   ya estaban: 0   fallos de descarga: 0
cuadran 24 de 24   no cuadran 0   ausentes 0
```

**Y esto es una foto de hoy, no una propiedad del proyecto.** `noble` es LTS y
las versiones vigentes de `-updates`/`-security` siguen publicadas; el día que
salga un `openjdk-17-jre` nuevo, el de hoy desaparece del índice y el guion dirá
`[RETIRADO]`. Está previsto y **no se tapa cogiendo la versión nueva**: eso
cambiaría lo que el producto lleva.

#### (f) LOS CINCO CONTROLES DEL GUION, y uno de ellos destapó un defecto MÍO

Todos sobre `ca-certificates-java`, que son 11 KB, así que costaron segundos:

```
A. version que no existe (99.99.99)     -> [RETIRADO] ... lo que hay hoy: 20240118
                                           y NO baja la que hay
B. misma version, huella saboteada      -> [OTROS BYTES] con las dos huellas ENTERAS
C. huella buena, tamano falso (11625)   -> [FALLO] los bytes que llegaron no son
                                           los del manifiesto, y NO deja el .deb en disco
D. el fichero ya esta con otros bytes   -> "se rehace", lo baja, y acaba en [OK]  <- control POSITIVO
E. el +encina2 con el NOMBRE del +encina4,
   y ademas el mas nuevo por fecha      -> [FALTA] autofirma_1.9.1+encina4  (no se lo traga)
```

**El control B encontró un defecto del propio guion, y se arregla en vez de
rodearlo:** recortaba las huellas a 12 caracteres para el mensaje, así que un
sabotaje en el **último** carácter imprimía dos huellas que se leen **iguales**.
Un mensaje que no distingue no informa. Ahora las imprime enteras.

**El control E es la trampa de §4.13 con tres candidatos**, y es la razón de que
`--propios` busque **por huella en todo el árbol** y nunca por nombre ni por
fecha.

#### (g) LOS CUATRO `PROPIO`, en tres pasadas a propósito — y el que NO sale del clon

Se trajeron en tres órdenes separadas para que **cada procedencia quede escrita**:

```
1. --propios debian-packages/          -> encina-firefox-native 972ec932…, encina-meta 86da3cc9…
2. --propios encina-autofirma/salida/  -> autofirma faeca3a9…  (habiendo TRES casi homonimos ahi)
3. --propios <extraccion de la ISO>    -> encina-branding 51b6603c…
```

**Y la tercera es el punto flojo de esta vuelta, dicho antes de usarla y no
después: `encina-branding_0.1.8_all.deb` NO existe en este Mac.** En
`debian-packages/` solo está el `0.1.7` (`0e870833…`). O sea que hoy, en una
máquina que solo ha clonado `encina-os` y `encina-autofirma`, salen **tres de los
cuatro** `PROPIO`, y el cuarto sigue saliendo del medio. **La circularidad está
cortada para los 24 y para tres de los cuatro; queda un hilo, y es exactamente la
casilla siguiente del bloque 0** («los tres `.deb` de Encina, construibles desde
este repositorio»). No se cierra aquí porque no es esta tarea.

Con los cuatro dentro:

```
cuadran 28 de 28   no cuadran 0   ausentes 0
[OK]    los 28 .deb estan y sus huellas cuadran con el manifiesto
```

#### (h) EL ÍNDICE, en `encina-dev` — y sale BYTE A BYTE el de la ISO

VM identificada **por huella y no por nombre**, y coincide con la de §4.35d:

```
hostname encina-dev   /home/prueba   encina-branding 0.1.7
snap firefox 153.0.3-1 rev 8735      machine-id 1ee16aeb6e284f668fde407cfa31a3ac
```

Transferencia con `COPYFILE_DISABLE=1`, y **el cotejo que sí puede fallar**:

```
28 ficheros llegaron   entradas que no son .deb: 0
las 28 huellas del Mac y de la VM, iguales   (control: con una cambiada, el diff la senala)
```

Y el índice:

```
dpkg-scanpackages . /dev/null > Packages   ->  28 entradas, 41 154 bytes
11171cc460f23d5876bc8c1cfdaa8284c42cd28318152b88cf89d4ee0ed5b59c   el generado hoy
11171cc460f23d5876bc8c1cfdaa8284c42cd28318152b88cf89d4ee0ed5b59c   el de la ISO vigente
diff: BYTE A BYTE IGUAL
```

`encina-dev` se apagó antes de tocar nada más, y `utmctl list` da **0** encendidas.

#### (i) LA TRAMPA 24 NO SE REPRODUCE EN ESTE MAC, y hoy tiene OTRA cara

Se midió que `tar` no metía entradas AppleDouble: **0**. Y ese `0` no valía nada
hasta intentar que el control se disparara — que es la regla de siempre. **No se
pudo:**

```
.deb con un xattr de usuario  + tar SIN COPYFILE_DISABLE   -> 0 entradas ._
.deb con FORK DE RECURSOS     + tar SIN COPYFILE_DISABLE   -> 0 entradas ._
                              + tar --mac-metadata         -> 0 entradas ._
bsdtar 3.5.3 - libarchive 3.7.4
```

**La trampa 24 sigue siendo verdad y ha cambiado de forma.** Este `libarchive`
ya no escribe ficheros `._x.deb`: escribe **cabeceras pax**, y se vieron en el
lado de Linux al desempaquetar:

```
tar: Se desestima la palabra clave de la cabecera extendida desconocida
     'LIBARCHIVE.xattr.com.apple.provenance'          (x28)
     'LIBARCHIVE.xattr.com.docker.grpcfuse.ownership'
```

O sea que hoy el `tar` de GNU las **descarta avisando** en vez de dejar ficheros
que `dpkg-scanpackages` indexaría. `COPYFILE_DISABLE=1` se puso igual —cuesta
cero y el comportamiento depende de la versión de `libarchive`—, pero **la
protección que de verdad se midió es el cotejo de las 28 huellas a los dos
lados**, que es el que puede fallar.

#### (j) LA CASILLA QUE LO CIERRA: el paso 2, con los dos controles negativos primero

Los controles cuestan cero porque el guion se niega **antes** de escribir un byte
de medio, y el primero **reproduce literalmente el defecto del encargo**:

```
falta un .deb            -> [FALLO] no esta: …/autofirma_1.9.1+encina4_all.deb
el +encina2 con el nombre
del +encina4             -> [FALLO] huella distinta en autofirma_1.9.1+encina4_all.deb
y en los dos casos NO escribio ninguna ISO: No such file or directory
```

Y con el directorio cosechado:

```
== 2. los cuatro .deb, por huella (§4.13: misma version != mismos bytes)
[OK]    autofirma_1.9.1+encina4_all.deb  faeca3a9…
[OK]    encina-branding_0.1.8_all.deb  51b6603c…
[OK]    encina-firefox-native_0.2.1_all.deb  972ec932…
[OK]    encina-meta_0.2.1_all.deb  86da3cc9…
[OK]    Packages describe 28 ficheros, viajan 28, y las 28 huellas cuadran
```

Los once pasos del guion, en verde y sin aflojar ninguno: la cadena firmada
intacta, la ESP byte a byte la oficial en sus 13 504 sectores, 30 añadidos y
2 modificados nombrados (`grub.cfg` y `md5sum.txt`), y las 266 líneas de
`md5sum.txt` cuadrando con el control de que con el `md5sum.txt` **oficial**
falla exactamente una.

#### (k) LA COMPROBACIÓN FUERTE: la ISO sale a DOS SECTORES — y la causa es un PERMISO

```
ac0a5721b9ff5b2b762d3467bbc20d8e62374df22a5d18e3c483f8c25b1fa443   la vigente
1ef3a6689037b0688293c864ff8d5a5cb17fc913069b5d8b58db33fe88d436f9   desde la cosecha
3 715 366 912 bytes las dos                     <- otra vez, el tamano no discrimina
```

**No se da por malo: se dice qué cambia.** Comparadas sector a sector:

```
sectores totales:   1 814 144
sectores distintos:         2      (el 118 y el 334)
bytes distintos dentro de cada uno: 2
```

Y esos cuatro bytes son **un solo campo**, el `PX` de Rock Ridge, o sea el modo
del fichero, en sus dos copias (little-endian y big-endian) y en los dos árboles
de directorio:

```
vieja:  81c0  ->  0100700      ENCINA_FIREFOX_NATIVE_0_2_1.DEB
nueva:  81a4  ->  0100644      el mismo fichero
```

Leído también por el otro lado, que es el control:

```
dentro de la ISO vigente:  28 ficheros -rw-r--r--  y UNO -rwx------
dentro de la ISO nueva:    29 ficheros -rw-r--r--
```

**La causa, medida:** `fabricar-iso.sh` copia lo que le dan a un temporal con
`cp` y hereda el modo que el fichero tuviera en el disco del Mac. El día de §4.35
`encina-firefox-native_0.2.1_all.deb` estaba en `0700`; **hoy ese mismo fichero
en `debian-packages/` ya es `644`**, así que **la ISO vigente no la reproduce ni
su propio directorio de origen**. No es el orden y no es una fecha: es un permiso,
y por eso **no se ha arreglado por mi cuenta** — tocar `fabricar-iso.sh` cambia
cómo se construye el producto, y eso es una decisión de Jorge (§4.36m).

**Y el contenido es el mismo, demostrado y no inferido:** extraídos los 29
ficheros de las **dos** ISOs y comparadas sus huellas, **0 diferencias**, con el
control de que el mismo `diff` señala una huella cambiada en un carácter.

#### (l) El coste, medido: la vuelta salió a cero

```
libre al empezar   53 GiB   (xorriso, que lee el volumen: 53.9g free)
pico               49 GiB   (4,5 GB: ISO 3,5 + cosecha 311 MB + indices 135 MB + extracciones 336 MB)
libre al terminar  53 GiB
red                158 MB   (124,5 de .deb + 33,4 de indices)
VMs encendidas     1, encina-dev, y apagada antes de nada mas
```

Se borró lo **reproducible** —la ISO nueva, que ya solo se diferencia de la
vigente en un bit de permiso— y se conservó la cosecha, que vuelve a fabricarse
con una sola orden.

#### (m) Lo que esta medición NO contesta, y hay que decirlo entero

- **`encina-branding` 0.1.8 no sale del clon.** Sale de la ISO. Es (g), y es la
  casilla siguiente del bloque 0, no ésta.
- **Los dos bytes no se han arreglado.** Están diagnosticados hasta el campo y
  hasta el fichero, y la decisión de si `fabricar-iso.sh` fija el modo de lo que
  añade —como ya fija la fecha, y por el mismo motivo— **es de producto**.
  Mientras no se tome, la ISO vigente `ac0a5721…` **no es reproducible bit a bit**
  desde ningún directorio, ni siquiera desde el suyo.
- **Que la ISO nueva arranque.** No se arrancó. No hacía falta para esta casilla
  y habría costado una instalación; y su contenido es el mismo que el de una que
  sí se arrancó (§4.35g).
- **Que los 24 sigan estando mañana.** Es (e): una foto de hoy. El instrumento
  para enterarse ya existe y dice `[RETIRADO]`.
- **amd64 y E5.** Nada. `cosechar-repo.sh` pide `binary-arm64` a los índices,
  que es lo que el manifiesto describe.

---

### 4.37 LOS TRES `.deb` SE CONSTRUYEN DESDE EL CLON — y la huella vigente era de una CONSTRUCCIÓN, no de un paquete (2026-08-13)

**La casilla que cierra esta vuelta:** «los tres `.deb` de Encina, construibles
desde este repositorio», que era el ÚLTIMO hilo de la circularidad — de los 28
del medio, 27 ya no dependían de la ISO y el que faltaba era
`encina-branding_0.1.8_all.deb` (§4.36g). Se cierra, y en el camino contesta una
pregunta que nadie había medido: **si estas construcciones son reproducibles**.
Ninguno de los tres guiones fija `SOURCE_DATE_EPOCH` ni `--root-owner-group`.

#### (a) El coste, dicho ANTES de arrancar — y el error de la predicción

Predicho: 158 MB de red y ~450 MB de disco para la cosecha; **~3,5 GB de red más
y ~11,8 GB de pico si se fabricaba la ISO**.

**Y el hallazgo que cambió esa cuenta, medido antes de encender nada: en este Mac
NO HAY NINGUNA ISO.** `find /` con `-maxdepth 6` no encuentra ni un `.iso`: ni la
oficial de Ubuntu `c2610520…`, que es la ENTRADA de `fabricar-iso.sh`, ni la
vigente `ac0a5721…`. La ISO se aplazó por eso y **la comparación sector a sector
contra `ac0a5721…` que esta vuelta iba a hacer NO SE PUEDE HACER AQUÍ.**

Coste real, con la ISO fuera:

```
libre al empezar   53 GiB
pico               51 GiB   (2 GB: cosecha 311 MB -135 de indices- + 2 volumenes CIDATA de 768 MB)
libre al terminar  53 GiB
red                158 MB   (124,5 de .deb + 33,4 de indices)
VMs encendidas     1, encina-dev, dos veces, y apagada las dos
```

#### (b) Qué se daría por sano y qué por roto, escrito ANTES de tocar nada

| Comprobación | Sano | Roto |
|---|---|---|
| `encina-meta` reconstruido | `86da3cc9…`, 6 912 bytes | Otra huella → **HALLAZGO**, decir en qué difieren y **PARAR** |
| El entorno contra el `.buildinfo` | Las 150 `Installed-Build-Depends` iguales | Alguna movida → decirlo **antes** de interpretar la huella |
| `encina-firefox-native` | `972ec932…` | Igual |
| `encina-branding` 0.1.8 | `51b6603c…` | El único sin red de seguridad *(resultó tenerla, ver (f))* |
| El modo fijado en `fabricar-iso.sh` | Un `chmod` neutralizado se caza | `[OK]` con el modo sin fijar → no comprueba nada |
| La cosecha con `--propios` a lo construido | **28 de 28**, sin tocar la ISO | 27 → sigue el hilo |

#### (c) EL ENTORNO NO SE HA MOVIDO, y eso es lo que hace interpretable la huella

`encina-dev` identificada **por huella y no por nombre**, los cinco testigos:

```
hostname encina-dev   /home/prueba   encina-branding 0.1.7
snap firefox 153.0.3-1 rev 8735      machine-id 1ee16aeb6e284f668fde407cfa31a3ac
```

Y las **150** dependencias de construcción que el `.buildinfo` del 2026-08-12
declara, comparadas una a una con lo que hay hoy:

```
comprobadas: 150   distintas: 0
CONTROL: dpkg (= 9.9.9-inventada) -> DISTINTO  dpkg  buildinfo=9.9.9-inventada  hoy=1.22.6ubuntu6.6
```

**Si la huella sale distinta, la causa no es el entorno.** Eso se sabía antes de
mirarla, que es cuando sirve.

El árbol viajó con `git archive HEAD`, no con `tar` del disco — así lo que se
construye es **lo versionado** y la trampa 24 no entra. Cotejo a los dos lados:
**0 diferencias en 85 ficheros**, con el control de que una huella cambiada en un
carácter la señala. *Y el primer intento de ese control NO SE DISPARÓ*: el
sabotaje era `sed '1s/^./f/'` y la primera línea ya empezaba por `f`. Un sabotaje
que no sabotea no es un control.

#### (d) NO SALE IGUAL — y la diferencia es UN CAMPO de UNA cabecera

```
86da3cc9ec071bcb597871b1337824fba0f5e7b8c4491b2f6c51f910a631ed2c  6912  la del manifiesto
204081f0ff3c5dc33481bbe4e3febccf3d289615f174270ca9b0d067e085f9b6  6904  desde el clon
```

Desglosado miembro a miembro del `ar`:

```
debian-binary     IGUAL
control.tar.zst   IGUAL          (y descomprimido, byte a byte identico)
data.tar.zst      DISTINTO  ->  descomprimido: 7 bytes de 10 240, posiciones 5773-5786
```

5772 = 11 × 512 + 140, o sea la cabecera del bloque 11 en su offset 136–147, que
es el campo `mtime` del tar:

```
bloque 11  ->  ./usr/share/doc/encina-meta/copyright
vigente:   octal 15235571250  = 1786180264 = 2026-08-08 09:11:04 UTC
del clon:  octal 15237150653  = 1786565035 = 2026-08-12 20:03:55 UTC  <- SOURCE_DATE_EPOCH EXACTO
```

**LA CAUSA, y no es un descuido de nadie: `dpkg-deb` hace *clamp*, no *set*.**
`dpkg-buildpackage` **ya exporta** `SOURCE_DATE_EPOCH` derivado del changelog
—el `.buildinfo` lo declara en su línea 172— y **recorta los mtimes posteriores,
dejando pasar los anteriores**. El día de la construcción vigente,
`debian/copyright` llevaba en el disco un mtime del 8 de agosto, anterior a la
fecha del changelog, y se coló dentro del `.deb`. **Ese dato no está en git.**

Demostrado con los dos controles, no inferido:

```
touch -d @1786180264 debian/copyright + reconstruir -> 86da3cc9…  EXACTA, 6912 bytes
touch -d @1786180000 (264 s antes)    + reconstruir -> dade2ff0…  distinta
```

#### (e) Y EL CONTROL QUE LE DA LA VUELTA AL SENTIDO DEL HALLAZGO

La pregunta que faltaba: ¿es el paquete irreproducible, o es la huella vigente la
que no se puede reproducir? Se separa haciendo variar **sólo** los mtimes, todos
ellos posteriores al epoch:

```
mismo arbol, mtimes a 2026-08-13 18:41:46.48 (subsegundos incluidos)  ->  204081f0…  LA MISMA
```

**Los tres `.deb` SON reproducibles desde un clon.** Cualquier clon, cualquier
día: el checkout siempre pone mtimes posteriores a la fecha del changelog, el
clamp los absorbe todos y la huella es estable. **Lo que no se reproduce es la
huella VIGENTE**, porque nació de un árbol de trabajo con fechas viejas.

*Un intento de control que no valió y hay que decirlo:* la segunda construcción se
hizo re-extrayendo con `git archive`, y salió el **mismo** mtime — `git archive`
fija las fechas a la del commit (`4de872a`, `2026-08-13T18:22:53+02:00`). Eso no
varía la entrada, así que no prueba nada; el control bueno es el `touch` de
arriba, que sí la varía.

#### (f) LOS TRES CONSTRUYEN, y `encina-branding` 0.1.8 SÍ tenía red de seguridad

Los tres guiones pasan en verde desde el árbol versionado —**25, 39 y 14**
comprobaciones, 0 fallos, `lintian` sin decir nada—, `encina-branding` 0.1.8
incluido:

```
9ec0a49db9983e6b98956152094aa78b544d1da6c8ed5482e9930414b6a5ea78  6158932  branding  (era 51b6603c…, 6159072)
640f508e3802a2513a5be33ecab192e637f5c09f659d6273966458fe1fcc9925    10876  firefox   (era 972ec932…,   10922)
204081f0ff3c5dc33481bbe4e3febccf3d289615f174270ca9b0d067e085f9b6     6904  meta      (era 86da3cc9…,    6912)
```

**Y el contenido es el mismo, medido por los dos lados:**

| | ficheros iguales | listado sin la fecha | fechas distintas |
|---|---|---|---|
| branding | 0 dif. en 20 | idéntico (modos, dueños, tamaños, rutas) | 43 de 43 |
| firefox | 0 dif. en 8 | idéntico | 15 de 23 |
| meta | 0 dif. en 2 | idéntico | 1 de 7 |

Los tres son **más pequeños**: los mtimes uniformes comprimen mejor. El
`control.tar` de branding, que salía distinto, es el mismo caso — `02:41`
conservada frente a `10:00` clampeada, con sus ficheros idénticos huella a
huella; el changelog de 0.1.8 lleva una fecha escrita a mano, `Wed, 12 Aug 2026
10:00:00 +0200`, **posterior a la construcción real de las 02:41**.

**Y §4.36g estaba incompleta, dicho aquí porque es lo que se midió:**
`encina-branding_0.1.8_all.deb` (`51b6603c…`) **sí existía fuera de la ISO** — en
`encina-dev`, en cuatro sitios (`~/cosecha`, `~/repo-nuevo`, `~/repo-0.2.1`,
`~/e4build`), encontrado **por huella** entre los 321 `.deb` de esa máquina. Lo
cierto era «no está en el Mac», no «sólo sale del medio».

#### (g) LA DECISIÓN, que es de producto y la tomó Jorge: EL MANIFIESTO AL DÍA

Las dos salidas eran adoptar las huellas del clon o versionar las 76 fechas
históricas para conservar las viejas. **Se adoptan las del clon**, y el
argumento que decidió es que **la ISO cambia de huella igualmente** por el modo
(§4.36k), así que conservar las de los `.deb` no salvaba `ac0a5721…`; y versionar
mtimes mete en git un dato que no describe el producto.

Se hizo el `grep` de las huellas viejas por el repositorio **antes de tocar
nada**, con su control (`faeca3a9…`, que NO cambia, aparece en tres ficheros).
Sólo **dos** sitios escriben huellas; `fabricar-seed.sh` y `fabricar-iso.sh` las
leen de `encina-seed.sh` con `huella_de()`, y `verificar-instalacion.sh` no
guarda ninguna:

```
imagen/encina-seed.sh        H_BRANDING, H_FFNATIVE, H_META
imagen/repo-manifiesto.tsv   las tres lineas PROPIO (huella Y tamano)
```

Y los **dos** YAML, porque el seed viaja empotrado en base64 (la séptima cosa de
`SCRIPTS.md`). Regenerados con la herramienta, no a mano:

```
imagen/autoinstall.yaml              cambia 1 linea (la 83)   control consigo mismo: 0
imagen/autoinstall-unattended.yaml   cambia 1 linea           control consigo mismo: 0
los dos: el seed empotrado es BYTE A BYTE imagen/encina-seed.sh
```

**Dos veces el barrido de huellas viejas dio `1` y las dos veces era mi propio
comentario** — el que explica el cambio nombrando las huellas que sustituye. Es
la trampa 3 de `SCRIPTS.md` en su forma más literal, y una vez propagada dentro
del base64. Sobre líneas efectivas: **0**, con el control de que las nuevas dan 3.

#### (h) EL MODO, en `fabricar-iso.sh` — con el control que puede fallar

Decisión de Jorge ya tomada: `fabricar-iso.sh` fija el modo de lo que añade, como
ya fija la fecha y por el mismo motivo. `0644` para los ficheros y `0755` para el
directorio del repo, que es lo que los 29 ficheros ya llevan. **Y no es
hipotético:** en `debian-packages/` conviven hoy `.deb` en `0600` y en `0644`.

Probado **aislado**, porque la ISO se aplazó, con el caso real —un `.deb` en
`0600` y el directorio en `0700`— y con su control negativo:

```
chmod real           -> [OK]    modo fijado: 6 ficheros en 644 y el directorio en 755
chmod NEUTRALIZADO   -> [FALLO] 1 ficheros no quedaron en 644 pese al chmod
```

El guardián es la trampa 13: **una mutación se verifica antes de leer su
resultado**. Sin él, un `chmod` que fallara en silencio daría exactamente la ISO
que este bloque existe para evitar.

**Lo que NO se toca: el propietario.** El uid/gid también viaja en el campo `PX`,
y cambiarlo movería más sectores. La decisión era el modo.

#### (i) LA VUELTA ENTERA: 28 DE 28 SIN TOCAR LA ISO NI UNA VEZ

Directorio **vacío** (`0 entradas`), y las dos procedencias en órdenes separadas
para que cada una quede escrita:

```
--propios <lo construido hoy>      -> 24 bajados, 0 fallos; branding 9ec0a49d…,
                                      firefox 640f508e…, meta 204081f0…
                                      cuadran 27 de 28, ausentes 1  -> [FALLO], y se niega
--propios encina-autofirma/salida  -> autofirma faeca3a9…  (con TRES casi homonimos alli)
                                      cuadran 28 de 28   no cuadran 0   ausentes 0
                                      [OK] los 28 .deb estan y sus huellas cuadran
```

El `27 de 28` de la primera pasada **es el control**: el guion sabe dar la
respuesta mala, y la da antes de escribir nada.

**Y los 24 volvieron a bajarse hoy: ninguno retirado.** Es otra foto, no una
propiedad, igual que en §4.36e.

El índice, en `encina-dev`, y aquí hay un dato que engaña:

```
28 entradas, 41 154 bytes, sha256 ccf5edf4…
el de la ISO vigente:      41 154 bytes, sha256 11171cc4…
```

**EXACTAMENTE EL MISMO TAMAÑO Y OTRO CONTENIDO** — los tres tamaños que cambian
tienen los mismos dígitos (6159072→6158932, 10922→10876, 6912→6904). El tamaño no
discrimina, otra vez. Y el índice generado contra el manifiesto: **0 diferencias
en las 28 líneas**, con el control de que un tamaño falseado las señala.

#### (j) LA TRAMPA 24, REPRODUCIDA HOY EN SU FORMA NUEVA — y con `COPYFILE_DISABLE=1` puesto

Al transferir los 28 a la VM, con `COPYFILE_DISABLE=1` delante:

```
tar: Se desestima la palabra clave de la cabecera extendida desconocida
     'LIBARCHIVE.xattr.com.apple.provenance'              (x28)
     'LIBARCHIVE.xattr.com.docker.grpcfuse.ownership'
28 .deb llegaron   entradas que no son .deb: 0
```

**`COPYFILE_DISABLE=1` no suprime las cabeceras pax** — sólo los ficheros `._`,
que este `libarchive` ya no escribe. Lo confirma §4.36i por una vía nueva: lo que
protege de verdad es el cotejo de las 28 huellas a los dos lados, que dio
**iguales** con el control de que una cambiada en un carácter la señala.

#### (k) Lo que esta medición NO contesta, y hay que decirlo entero

- **LA ISO NO SE HA FABRICADO.** El modo está escrito y probado aislado, pero
  **las dos construcciones seguidas con la misma huella —que es la mitad del
  «hecha cuando» de esa casilla— NO ESTÁN MEDIDAS**, y por eso la casilla del
  modo sigue **sin marcar**. La predicción falsable, para cuando se haga: con el
  modo fijado y nada más tocado, la ISO desde la cosecha tenía que dar
  `1ef3a668…`, que es la de §4.36k. Ahora **ya no**, porque los tres `.deb` de
  dentro han cambiado; lo que sigue en pie es que los 29 ficheros salgan
  `-rw-r--r--` y que dos construcciones seguidas coincidan.
- **`ac0a5721…` SIGUE SIENDO LA ISO QUE EXISTE, Y YA NO SE REPRODUCE DESDE ESTE
  REPOSITORIO.** Lleva dentro los `.deb` viejos y un seed que exige las huellas
  viejas, así que es coherente **consigo misma** y **no** con el árbol de hoy. No
  está en este Mac para comprobarlo: es lo que dice (a).
- **Ninguno de los tres `.deb` nuevos se ha instalado ni arrancado.** El contenido
  es idéntico huella a huella al de los vigentes, que sí se instalaron y
  arrancaron (§4.34, §4.35g), pero eso es un argumento, no una medición.
- **Los `.buildinfo` y `.changes` de `debian-packages/` NO se han rehecho.**
  Siguen describiendo la construcción del 12 de agosto — y son la evidencia de
  donde salió `SOURCE_DATE_EPOCH` en (d). Rehacerlos borraría eso.
- **Que los 24 sigan estando mañana.** Otra foto. `cosechar-repo.sh` dice
  `[RETIRADO]` cuando deje de ser verdad.
- **`shellcheck` no está en este Mac**, así que los guiones tocados sólo pasaron
  `bash -n`. Lo que `SCRIPTS.md` dice de `shellcheck` se midió en su día, no hoy.
- **En `encina-dev` quedan los árboles de esta vuelta** (`~/construir-hoy`,
  `~/clon-2`, `~/repo-2026-08-13`) y en `~/construir-hoy` el `copyright` tiene el
  mtime tocado a mano. No es un clon limpio: para volver a medir, se rehace.

---

### 4.38 LA CI YA MIRA LOS TRES `.deb` — y salen IGUALES en amd64: la reproducibilidad es entre máquinas Y entre arquitecturas (2026-08-13)

**Lo que había, y por qué no valía:** `.github/workflows/build.yml` construía los
tres paquetes y los subía a un artefacto **sin mirarlos**. Un artefacto no es una
comprobación: se sube igual de bien con otros bytes dentro. Los tres jobs podían
estar produciendo `.deb` distintos a los del manifiesto y la CI habría seguido
verde indefinidamente.

**Y la pregunta que eso tapaba, que es la que de verdad importa:** las huellas de
§4.37 se midieron **en una sola máquina**, `encina-dev`, que es **arm64**. El
runner de GitHub es **amd64**. Los tres paquetes son `Architecture: all`, así que
«deberían» salir iguales — y «deberían» es exactamente lo que resultó falso el
día anterior (§4.37d).

#### (a) Qué se daría por sano y qué por roto, escrito ANTES de tocar nada

| Comprobación | Sano | Roto |
|---|---|---|
| El comprobador con un `.deb` que NO cuadra | `[HALLAZGO]`, rc=1 | rc=0 → no comprueba nada |
| El comprobador con un `.deb` que SÍ cuadra | `[OK]`, rc=0 | rc≠0 → no sabe dar la respuesta buena |
| El heredoc de `06-ci.sh` contra `build.yml` | 0 diferencias | difieren → `06-ci.sh` borra la comprobación |
| CONTROL en cada job: huella saboteada | rojo, **y por la línea `[HALLAZGO]`** | verde → un `[OK]` que no comprueba nada |
| Que el sabotaje sabotee | el fichero cambia | igual → es el `sed '1s/^./f/'` de §4.37c |
| **Las tres huellas en amd64** | `9ec0a49d…` `640f508e…` `204081f0…` | otra → **HALLAZGO**, decir qué difiere y **PARAR** |

**La predicción, falsable y escrita antes:** salen iguales, porque `dpkg-deb`
hace *clamp* contra `SOURCE_DATE_EPOCH` (§4.37d) y un checkout siempre pone
fechas posteriores al changelog. Y si fallaba, predije que fallaría en
`data.tar.zst` y no en `control.tar` — por el compresor o por el orden de
`readdir`.

#### (b) LA RESPUESTA: LAS TRES CUADRAN, en amd64, a la primera

Salida literal del runner, ejecución `31726150686`, commit `9a5d6a8`:

```
== 0. donde se ha construido
        sistema  Ubuntu 24.04.4 LTS   arquitectura x86_64
        dpkg 1.22.6ubuntu6.6      dpkg-dev 1.22.6ubuntu6.6
        libzstd1 1.5.5+dfsg2-2build1.1     tar 1.35+dfsg-3ubuntu0.3

[OK]  encina-branding_0.1.8_all.deb       9ec0a49db998…  6158932 bytes
[OK]  encina-firefox-native_0.2.1_all.deb 640f508e3802…    10876 bytes
[OK]  encina-meta_0.2.1_all.deb           204081f0ff3c…     6904 bytes
```

**Lo que esto hace más fuerte que §4.37:** ayer se sabía que la construcción era
reproducible *desde cualquier clon en la misma máquina*. Hoy se sabe que lo es
**en otra máquina, de otra arquitectura y sin ningún estado previo** — un runner
efímero que nace vacío. Y **dos ejecuciones distintas** (`9a5d6a8` y `b5488b7`),
en seis runners efímeros distintos, dieron las **mismas tres huellas**.

Los mtimes de dentro, en el runner amd64, son el `SOURCE_DATE_EPOCH` exacto:

```
-rw-r--r-- root/root  2540  2026-08-12 20:03:55  ./usr/share/doc/encina-meta/changelog.gz
-rw-r--r-- root/root  1250  2026-08-12 20:03:55  ./usr/share/doc/encina-meta/copyright
```

**El clamp de `dpkg-deb` se comporta igual en las dos arquitecturas**, que era el
mecanismo del que dependía todo el argumento de §4.37e.

#### (c) Y UNA CONFIRMACIÓN CRUZADA QUE NO SE BUSCABA

El desglose por miembros del `ar` se imprime **también en verde**, y comparado
con el `.deb` **viejo** de arm64 que hay en este Mac (`86da3cc9…`, la
construcción del 12 de agosto en `encina-dev`):

```
                    arm64, 2026-08-12          amd64, runner de hoy
debian-binary       d526eb4e…    4             d526eb4e…    4        IGUAL
control.tar.zst     60509549…  3060            60509549…  3060       IGUAL
data.tar.zst        30179e3a…  3659            6798c5de…  3651       distinto
```

**El `control.tar.zst` sale byte a byte idéntico en las dos arquitecturas**, con
dos `zstd` que ni siquiera son el mismo binario. Es §4.37d medido otra vez por
una vía independiente, en una tercera máquina: lo que cambiaba era `data.tar`, y
por una fecha.

#### (d) EL CONTROL, y va DELANTE de la medición

Primero se calibra el instrumento y después se mide con él. Cada job sabotea
**un carácter** de la huella de su paquete en una copia del manifiesto y exige
que el comprobador falle:

```
[OK]    sabe decir que no:  [HALLAZGO] encina-meta_0.2.1_all.deb NO es el del manifiesto
[OK]    sabe decir que no:  [HALLAZGO] encina-branding_0.1.8_all.deb NO es el del manifiesto
[OK]    sabe decir que no:  [HALLAZGO] encina-firefox-native_0.2.1_all.deb NO es el del manifiesto
```

Con **tres** cautelas que vienen de trampas ya pagadas:

- **Que el sabotaje sabotee**: se compara con `cmp` contra el original y se
  aborta si son iguales. En §4.37c un `sed '1s/^./f/'` no cambió nada porque la
  línea ya empezaba por `f`.
- **Que falle POR EL MOTIVO CORRECTO**: no basta rc≠0 —eso lo da también un
  error de sintaxis—, se exige la línea `[HALLAZGO]` en la salida. Es la trampa
  del control negativo que no es negativo (§9).
- **El control interno no basta**, porque sólo demuestra que el *guion* sabe
  fallar, no que el YAML propague el fallo. Así que se empujó una rama de verdad
  con la huella de `encina-meta` saboteada, ejecución `31726191588`:

```
build (encina-meta, ...)            failure     <- solo el saboteado
build (encina-branding, ...)        success
build (encina-firefox-native, ...)  success
```

**Rojo, y sólo en su job.** La rama se borró; su ejecución sigue consultable.

#### (e) EL DESGLOSE LO HACE EL PROPIO GUION, y funcionó en rojo

Cuando no cuadra, `imagen/comprobar-propios.sh` imprime el mismo desglose que
§4.37d hubo que hacer a mano — para no tener que repetirlo en la otra máquina.
Verificado en el job rojo de verdad: `control.tar` y `data.tar` enteros con modos
y fechas (`--full-time`, segundos exactos), y las huellas del **contenido**
aparte de las de los metadatos, que es lo que separa «ha cambiado el paquete» de
«ha cambiado una fecha». Y dijo lo que tenía que decir:

```
        MISMO TAMANO Y OTROS BYTES: el tamano no discrimina (§4.37i)
```

El artefacto pasa a subirse con `always()`: si la huella falla es **cuando más
falta hace** tener el `.deb` para desglosarlo.

#### (f) UN HALLAZGO DE PASO: `06-ci.sh` iba a borrar la CI en silencio

`scripts/06-ci.sh` lleva una **segunda copia** de `build.yml` en un heredoc y la
sobrescribe sin preguntar. Esa copia **ya estaba desfasada**: no tenía
`encina-meta` en la matriz, así que ejecutarlo habría quitado un paquete de la CI
sin que nadie lo notara. Sincronizada **copiando el fichero dentro, no
transcribiéndolo**, y comprobado después: `0 diferencias`, con el control de que
un carácter cambiado se señala.

#### (g) Lo que esta medición NO contesta

- **NO está demostrado que sobreviva a un `dpkg` distinto.** Las dos máquinas
  corren **noble** y **exactamente el mismo `dpkg 1.22.6ubuntu6.6`** (§4.37c lo
  registró en `encina-dev`). Lo medido es reproducibilidad **entre
  arquitecturas**, no entre versiones de herramientas. La variable que §4.37
  dejaba abierta —«las 150 dependencias de construcción idénticas»— sigue en pie
  para `dpkg-dev` y `libzstd1`.
- **`ubuntu-latest` es una foto.** Hoy es 24.04.4; puede pasar a otra imagen sin
  que nadie toque este repositorio, y ese día las huellas son una pregunta
  abierta otra vez. Por eso el guion escribe ahora las versiones en cada
  ejecución: para que haya contra qué comparar.
- **`autofirma`, el cuarto `PROPIO`, no entra.** Se construye en otro
  repositorio y la CI no lo toca: de los cuatro `PROPIO` del manifiesto se
  comprueban tres.
- **Los 24 de origen `ARCHIVO` no se comprueban en CI.** Eso es `cosechar-repo.sh`
  y necesita red y 158 MB.
- **Ninguno de los `.deb` del runner se ha instalado ni arrancado.** Son iguales
  huella a huella a los de §4.37f, que tampoco se instalaron.
- **Nadie consume el artefacto.** La ISO no se fabrica en CI, y todo lo de §4.37k
  sobre la ISO sigue igual de sin medir.

---

### 4.39 EL MEDIO SE FABRICA DOS VECES Y SALE IGUAL — y la ISO oficial llevaba cuatro días en este Mac (2026-08-13)

**Las dos casillas que quedaban del bloque 0**, y van juntas porque necesitan lo
mismo: el MODO de lo que añade `fabricar-iso.sh` —decidido y escrito en §4.37h,
**sin medir**— y `construir-todo.sh`, que no existía. Las dos se cierran, y en el
camino se cae la premisa sobre la que se habían aplazado.

#### (a) LA PREMISA SE CAYÓ ANTES DE GASTAR UN BYTE, y el defecto es mío

§4.37a dice, y TAREAS.md lo repetía: **«en este Mac NO HAY NINGUNA ISO»**, ni la
oficial `c2610520…` ni la vigente `ac0a5721…`. Sobre eso se aplazó la ISO, se
presupuestaron 3,5 GB de red y se declaró imposible comparar sector a sector.

Es falso. Un `find` sin límite de profundidad:

```
3540299776  .../Documents/encina-E2-2vias.utm/Data/ubuntu.iso
3540299776  .../Documents/e2-medios/ubuntu-24.04.4-desktop-arm64.iso
3715366912  .../Documents/e2-medios/encina-os-E4-es-0.2.1.iso
3587178496  .../Documents/e2-medios/encina-os-E3-es.iso
   … 13 ficheros .iso en total, ~44 GB
```

Medidas por huella, no por nombre ni por tamaño:

```
c2610520bf582976839a1724c669e1cfed0547427be5a0ad12d457b92b46ffbe  e2-medios/ubuntu-24.04.4-desktop-arm64.iso
c2610520bf582976839a1724c669e1cfed0547427be5a0ad12d457b92b46ffbe  encina-E2-2vias.utm/Data/ubuntu.iso
ac0a5721b9ff5b2b762d3467bbc20d8e62374df22a5d18e3c483f8c25b1fa443  e2-medios/encina-os-E4-es-0.2.1.iso
```

**La oficial estaba en DOS copias independientes, y la vigente también.**

**LA CAUSA, y es exactamente la clase de defecto que este proyecto persigue:** el
`find` de §4.37a llevaba `-maxdepth 6` y la ruta tiene **nueve** componentes
(`/Users/jorge/Library/Containers/com.utmapp.UTM/Data/Documents/e2-medios/…`).
No fue una medición equivocada: fue **un instrumento que no podía dar una de sus
dos respuestas**, la familia de la trampa 5. Un `find` que no llega no dice «no
hay»; dice «no he mirado», y se leyó como lo primero.

#### (b) EL COSTE, dicho antes de arrancar — y las dos veces que fallé la cuenta

| | predicho en el encargo | corregido tras (a) | medido |
|---|---|---|---|
| red | 3,54 GB + 158 MB | ~165 MB | **~960 MB** |
| disco nuevo, pico | ~11,8 GB | ~7,3 GiB | **~19,6 GiB** (calculado, no muestreado) |
| libre | 52,6 GiB | | 51,5 → 40,4 → 35,6 → **47,1 GiB** |
| VMs | 1 a la vez | | `encina-dev`, 1 a la vez, apagada al terminar |

Al terminar se borró **lo reproducible** —tres ISOs duplicadas, la de control y
tres cosechas— y se conservó una ISO y su cosecha, que es §4.36l otra vez: 35,6
→ **47,1 GiB**. La vuelta costó **5,5 GiB netos** de los ~19,6 que llegó a
ocupar.

**Las dos veces me pasé por el mismo motivo: conté una vuelta y se hicieron
cinco.** Cada pasada de `construir-todo.sh` rehace la cosecha **desde cero** —a
propósito, porque reutilizar el directorio haría que la segunda pasada no
probara nada— así que fueron **cinco cosechas completas** (5 × 158 MB de `.deb`
+ 5 × 33,4 MB de índices) y **cinco ISOs de 3,46 GiB** en vez de dos.

#### (c) Qué se daría por sano y qué por roto, escrito ANTES de tocar nada

| Comprobación | Sano | Roto |
|---|---|---|
| La ISO oficial contra la **firma** de Canonical | `Firma correcta`, rc=0 | otra cosa → parar |
| La misma firma sobre un `SHA256SUMS` saboteado | `Firma INCORRECTA`, rc=1 | rc=0 → no comprueba nada |
| La cosecha sobre directorio vacío | **28 de 28** | 27 → sigue el hilo |
| **Dos ISOs seguidas del mismo repositorio** | **la misma huella** | distintas → decir qué sectores y qué campo, y **PARAR** |
| Dentro de la ISO | 29 en `/encina-repo` `-rw-r--r--`, ninguno `0700` | uno `0700` → el `chmod` no sirvió |
| Con el `chmod` neutralizado | **otra** huella | la misma → el modo no era la causa y §4.36k estaba mal |
| `construir-todo.sh` dos veces | la misma huella | distintas → no hay orden única |

**La predicción falsable, y esta vez sin patrón heredado:** `1ef3a668…` de
§4.36k **ya no vale** (§4.37k), así que no se predice una huella concreta — se
predice **igualdad entre pasadas**, que es lo que de verdad se quería.

#### (d) LA ISO OFICIAL, CONTRA LA FIRMA Y NO CONTRA UN FICHERO BAJADO

Hasta hoy `H_ISO` era **una huella escrita a mano** en `fabricar-iso.sh:69`, y
`AGENTS.md` §6bis.2 decía «verificada contra el `SHA256SUMS` de cdimage» — o sea
contra un fichero bajado del mismo sitio que la ISO. Eso no es un control
independiente. `cdimage` publica también `SHA256SUMS.gpg`, y nadie lo usaba.

`gpg` no está en este Mac y **no se instaló**: se verifica en `encina-dev`, que
hacía falta igual. Y la clave firmante **no hubo que bajarla de ningún servidor
de claves**, que habría sido confiar en otro sitio más:

```
$ dpkg -S /usr/share/keyrings/ubuntu-archive-keyring.gpg
ubuntu-keyring: /usr/share/keyrings/ubuntu-archive-keyring.gpg
paquete ubuntu-keyring 2023.11.28.1

$ gpgv --keyring /usr/share/keyrings/ubuntu-archive-keyring.gpg SHA256SUMS.gpg SHA256SUMS
gpgv: Firmado el jue 12 feb 2026 15:52:52 CET
gpgv:                usando RSA clave 843938DF228D22F7B3742BC0D94AA3F0EFE21092
gpgv: Firma correcta de "Ubuntu CD Image Automatic Signing Key (2012) <cdimage@ubuntu.com>"
rc=0
```

Y su control negativo, con la cautela de §4.38d —**que el sabotaje sabotee**—
comprobada antes (`cmp` dice que el fichero cambia en 2 líneas):

```
$ gpgv … SHA256SUMS.gpg SHA256SUMS.malo
gpgv: Firma INCORRECTA de "Ubuntu CD Image Automatic Signing Key (2012) <cdimage@ubuntu.com>"
rc=1
```

La cadena, atada mecánicamente y no a ojo, con el control de que un carácter
cambiado la rompe:

```
firmada por Canonical : c2610520bf58…2b46ffbe
escrita en el guion   : c2610520bf58…2b46ffbe   (imagen/fabricar-iso.sh:69)
los bytes de este Mac : c2610520bf58…2b46ffbe
[OK]    las tres son la misma
```

**Lo que esto compra:** `H_ISO` deja de ser una huella que hay que creerse y pasa
a estar respaldada por **una firma de Canonical**. Es el mismo agujero que el
bloque 0 cerró una capa más abajo, cerrado una capa más arriba.

#### (e) LA COSECHA: 28 de 28, y un fallo de red que el guion supo NOMBRAR

Directorio vacío, dos órdenes, y la primera **tiene que salir mal**:

```
--propios <los tres de la CI>   -> 23 bajados, 1 FALLO DE DESCARGA, autofirma [FALTA]
                                  cuadran 26 de 28   ausentes 2  -> [FALLO], y se niega
--propios encina-autofirma/salida -> bajado hunspell-es 7e40ad79…, autofirma faeca3a9…
                                  cuadran 28 de 28   no cuadran 0   ausentes 0
                                  [OK] los 28 .deb estan y sus huellas cuadran
```

**El fallo de descarga no estaba previsto y se midió antes de interpretarlo:**
`hunspell-es_24.2.1-1_all.deb` da **HTTP 200** en el `pool`, y la segunda pasada
lo bajó con la huella del manifiesto. Fue red, no una retirada — y el guion dijo
`[FALLO] no se pudo bajar` y **no** `[RETIRADO]`, que es la respuesta correcta:
las tres respuestas de §4.36 siguen distinguiéndose.

Los tres `.deb` propios entraron **del artefacto de la CI** (ejecución
`31726941155`, commit `7b5320a`, runner **amd64**) y cuadraron con el manifiesto
a la primera. Es §4.38b medido otra vez, en una ejecución que nadie planeó.

El índice, en `encina-dev`, y **es el mismo de §4.37i**:

```
28 entradas, 41 154 bytes, sha256 ccf5edf4c9e04316…
el indice contra el manifiesto: 28 y 28 lineas, 0 diferencias
control: con un tamano falseado, la comparacion lo senala (2)
```

Y la trampa 24 en su forma de §4.37j, otra vez idéntica: 28 avisos de cabecera
pax con `COPYFILE_DISABLE=1` puesto, `0` entradas que no son `.deb`, y el cotejo
de las 28 huellas a los dos lados en **0 diferencias**, con su control.

#### (f) LA CASILLA DEL MODO: DOS PASADAS, LA MISMA HUELLA

Lo que nunca se había podido comprobar, y salió a la primera:

```
95758c9e954d834f6324b6f5e0464741742478247d29a2637009ad03e2a8aef6   pasada 1
95758c9e954d834f6324b6f5e0464741742478247d29a2637009ad03e2a8aef6   pasada 2
3 715 366 912 bytes las dos
```

**Y otra vez el mismo tamaño exacto que `ac0a5721…`**, que es la tercera vez que
el tamaño no discrimina (§4.35, §4.37i, aquí).

**Pero dos pasadas desde el MISMO directorio no atacan la causa de §4.36k**, que
era el modo *en el disco*. El control que sí la ataca: una copia de la cosecha
con **cuatro ficheros fuera de 644** —el caso real, `encina-firefox-native` en
`0700` y tres en `0600`, y el directorio en `0711`—

```
modos distintos de 644 en el origen:          4
modos distintos de 644 en la cosecha buena:   0
-> [OK] modo fijado: 32 ficheros en 644 y el directorio del repo en 755
-> sha256: 95758c9e…   LA MISMA
```

**La ISO ya no depende de un dato que no está versionado.**

#### (g) EL CONTROL QUE PUEDE FALLAR — y un `[OK]` que no comprueba nada

Neutralizando el `chmod` **y su guardián** (8 líneas cambiadas, comprobado que
el sabotaje sabotea), sobre ese mismo directorio:

```
[OK]    modo fijado: 32 ficheros en 644 y el directorio del repo en 755   <- MIENTE
sha256: 3d10678ea5e6f2bb4fcf692eec7db568e90e31b4b8ff95fac9164307680a1bac
tam:    3715366912 bytes
```

**Otra huella, mismo tamaño.** Y fíjese en la primera línea: el guion neutralizado
imprime `[OK] modo fijado` **igual**, porque lo que lo cazaba era el guardián.
Es la trampa 13 enseñada por el lado que duele: sin él, un `chmod` que fallara en
silencio daría exactamente la ISO que este bloque existe para evitar, **con la
línea de `[OK]` puesta**.

Y con el guardián puesto, sobre el mismo directorio:

```
[FALLO] 4 ficheros no quedaron en 644 pese al chmod
```

Es §4.37h reproducido sobre el caso real, con 4 ficheros en vez de 1.

El control por el otro lado, dentro de los medios:

```
                        -rw-r--r--   -rw-------   -rwx------
iso-1 (la de hoy)           30           0            0
iso-sinmodo (control)       26           3            1
ac0a5721… (la vigente)      29           0            1
```

*(30 = los 29 de `/encina-repo` —28 `.deb` + `Packages`— más `/autoinstall.yaml`.
§4.36k contaba 29 porque miraba sólo `/encina-repo`.)*

#### (h) LA COMPARACIÓN QUE §4.37 DABA POR IMPOSIBLE

Sector a sector, ahora que la vigente está:

```
iso-sinmodo  contra  iso-1        sectores totales 1 814 144   distintos 4
    sector 118: 6 bytes  offsets 262 269 756 763 918 925
    sector 119: 2 bytes  offsets 1778 1785
    sector 334, 335: los mismos, el otro arbol de directorio
        80 -> a4   (0100600 -> 0100644)   x3 ficheros
        c0 -> a4   (0100700 -> 0100644)   x1 fichero
```

**Es §4.36k exacto, provocado a voluntad y ampliado:** allí 1 fichero daba 2
sectores y 2 bytes cada uno; aquí 4 ficheros dan **4 sectores y 8 bytes por árbol
de directorio** —cada uno en su copia *little-endian* y *big-endian* del campo
`PX` de Rock Ridge—. El registro de directorio cruza el límite de sector, por eso
son 118 **y** 119.

Contra la vigente, **86 167 sectores distintos**. El número solo no dice nada; el
desglose fichero a fichero sí, y son **cinco de 531**, con el control primero
—una huella saboteada da 1— y ninguno añadido ni perdido:

```
/encina-repo/encina-branding_0.1.8_all.deb        6 159 072 -> 6 158 932
/encina-repo/encina-firefox-native_0.2.1_all.deb     10 922 ->    10 876
/encina-repo/encina-meta_0.2.1_all.deb                6 912 ->     6 904
/encina-repo/Packages                                41 154 ->    41 154   <- otra vez
/autoinstall.yaml                                    42 995 ->    43 935
los otros 526: byte a byte iguales
```

**Los cinco estaban previstos y ninguno sobra:** los tres `.deb` son §4.37g, el
`Packages` los describe y el `autoinstall.yaml` lleva el seed empotrado que
declara sus huellas (la séptima cosa de `SCRIPTS.md`). El sexto motivo —el
modo— no sale en esta lista porque **no vive en el contenido de ningún fichero**,
sino en los registros de directorio: es (g).

#### (i) `construir-todo.sh`: DE UN CLON A LA ISO EN UNA ORDEN

Cruza dos máquinas y no hay remedio: `dpkg-buildpackage` y `dpkg-scanpackages`
no existen en macOS, y `fabricar-iso.sh` usa `md5 -q`, `stat -f` y el `xorriso`
del Mac. Los pasos 1 y 3 van por `ssh` al constructor; los 2 y 4 se quedan aquí.

**Construye `git archive HEAD` y NO el directorio de trabajo**, que es §4.37d
convertido en regla, y **se niega sobre un árbol sucio**. Probado en rojo:

```
[FALLO] el arbol tiene 1 cambios sin confirmar y se construye 'git archive HEAD'.
        Lo que saldria NO seria lo que ves.
```

La vuelta entera, con `encina-dev` identificada por huella:

```
mac         macOS 26.5.2 arm64     xorriso 1.5.8.pl02
constructor Ubuntu 24.04.4 LTS  arm64   machine-id 1ee16aeb6e284f668fde407cfa31a3ac
dpkg 1.22.6ubuntu6.6   dpkg-dev 1.22.6ubuntu6.6
87 ficheros a los dos lados, 0 diferencias      (+ control de un nombre cambiado)
03-construir.sh          25 comprobaciones, 0 fallos
07-firefox-construir.sh  39 comprobaciones, 0 fallos
10-meta-construir.sh     14 comprobaciones, 0 fallos
los tres .deb propios cuadran con el manifiesto, huella y tamano
28 .deb cosechados sin tocar ninguna ISO
Packages: 28 entradas, ccf5edf4c9e04316…
```

**Y su definición de terminado, medida:**

```
ct-1  (commit 62513f2)  95758c9e954d834f6324b6f5e0464741742478247d29a2637009ad03e2a8aef6
ct-2  (commit e6a90ba)  95758c9e954d834f6324b6f5e0464741742478247d29a2637009ad03e2a8aef6
ct-3  (commit e6a90ba)  95758c9e954d834f6324b6f5e0464741742478247d29a2637009ad03e2a8aef6
ct-4  (commit e6da719)  95758c9e954d834f6324b6f5e0464741742478247d29a2637009ad03e2a8aef6
```

**Cinco construcciones contando la manual, por DOS rutas distintas, y la misma
huella.** Y hay un cruce que no se buscaba: `iso-1` se fabricó con los tres
`.deb` **bajados del runner amd64 de la CI**, y `ct-1..4` con los tres
**construidos de nuevo en `encina-dev`, arm64**. Salen la misma ISO. Es §4.38b
comprobado por sus consecuencias, hasta el bit del medio entregable.

#### (j) DOS DEFECTOS EN MI PROPIO GUION, cazados por su salida y no por leerlo

1. **`0 comprobaciones, 0 fallos`** sobre tres construcciones que hacen **25, 39
   y 14** (§4.37f). Los tres guiones colorean con `lib.sh`, y mi `grep` anclado a
   `^\[OK\]` no casaba ni una línea. Se leía como «todo bien». Arreglado
   quitando los códigos ANSI **y haciendo que un recuento de cero sea un
   fallo**: un contador que no sabe leer la salida no puede decir que todo va
   bien. De paso, los `[FALLO]` ahora se cuentan en vez de darse por 0.
2. **Un `[FALLO]` esperado en medio de una pasada buena.** La primera de las dos
   órdenes de cosecha sale incompleta a propósito, y su `27 de 28 -> [FALLO]`
   aparecía sin explicación. Eso enseña a saltarse los `[FALLO]`. Ahora va
   anunciado **y comprobado**: si sin `autofirma` no salen exactamente 27, el
   control está roto y el guion para.

#### (k) `shellcheck` SÍ ESTABA — en la otra máquina

§4.37k dejó escrito que «`shellcheck` no está en este Mac», y era verdad y era
incompleto: **está en `encina-dev`**, `/usr/bin/shellcheck` 0.9.0. Los guiones
tocados hoy pasan `-S warning` en verde, con sus cuatro avisos iniciales
corregidos (dos `SC2010` de `ls | grep`, que son de la familia que miente en
silencio, y dos `SC2034`).

**Y su control se calibró en dos intentos, porque el primero no valía:** meter
`$SINCOMILLAS` cambió el fichero (2 líneas) pero **no es un defecto que
`shellcheck` señale a ese nivel**, así que dio verde. Un sabotaje que sabotea el
fichero pero no la comprobación **sigue sin ser un control**. El segundo —`cd $X`
sin comillas, `ls | grep`, `rm -rf $X/*`— dio tres avisos y rc=1.

#### (l) Lo que esta medición NO contesta, y hay que decirlo entero

- **NINGUNA DE LAS CINCO ISOs SE HA ARRANCADO.** Ni instalado. Lo medido es que
  el medio se **fabrica** igual, no que **funcione**. Su contenido es idéntico
  huella a huella al de `ac0a5721…` salvo en los cinco ficheros de (h), y esa
  sí arrancó y se instaló (§4.34, §4.35g) — pero eso es un argumento, no una
  medición, y los tres `.deb` nuevos siguen sin instalarse (§4.37k, §4.38g).
- **`95758c9e…` NO ES «LA ISO VIGENTE» HASTA QUE ALGUIEN LA ARRANQUE.** Es la
  huella que **produce este repositorio hoy**. `ac0a5721…` sigue siendo el medio
  que existe y que se probó, y ya no se reproduce desde aquí.
- **La reproducibilidad medida es EN ESTE MAC.** Cinco pasadas, un `xorriso`
  1.5.8.pl02, un macOS 26.5.2. Que otro Mac con otro `xorriso` dé lo mismo es
  una pregunta abierta — la misma que §4.38g deja para `dpkg`.
- **El constructor es siempre `encina-dev`.** Los `.deb` de la CI amd64 entraron
  en `iso-1`, así que hay dos arquitecturas en el lado de los paquetes, pero el
  `Packages` lo generó siempre la misma máquina con el mismo
  `dpkg-scanpackages`.
- **`c2610520…` NO ESTÁ EN `repo-manifiesto.tsv`.** La firma la respalda desde
  hoy, pero sigue siendo el único insumo del producto **sin copia versionada y
  sin instrumento que sepa decir `[RETIRADO]`**. Es la propuesta que va aparte.
- **La cosecha volvió a bajarse cinco veces y ninguno de los 24 fue retirado.**
  Otra foto, como §4.36e y §4.37i.
- **El pico de disco está calculado, no muestreado.** Se midió 52,6 → 51,5 →
  40,4 → 35,6 GiB, y el máximo se deduce de los tamaños de fichero. Nadie corrió
  un `df` en el instante peor.
- **En `encina-dev` quedan los árboles de esta vuelta** (`~/encina-construir-*`,
  `~/repo-b0`, `~/firma-b0`) más los de §4.37k. No es un clon limpio.

#### (m) LA LIMPIEZA, decidida por Jorge — y «dos copias» resultó no costar dos

Decisión de Jorge al leer (a): **la ISO no puede vivir perdida dentro del
contenedor de UTM**, que es lo que la escondió del `find`. Pasa a `medios/`,
dentro del repositorio y en `.gitignore`, con `imagen/traer-iso-oficial.sh` para
traerla. El `mv` es en el mismo volumen, así que **costó 0 bytes** y las huellas
salieron intactas después.

Y la segunda parte —quitar duplicados— dio un resultado que hay que escribir
porque contradice la pregunta:

```
libre al empezar la limpieza          47,08 GiB
cinco ISOs de E3 de un scratchpad muerto      +16,72
el scratchpad de E2 (oficial + seed)           +3,29
la E4 de otro scratchpad                       +3,46
mis cosechas y directorios de prueba           +0,91
e2-medios/encina-os-E3-es.iso (3,34 GiB)       +0,00   <- CERO
libre al terminar                     68,01 GiB        total +23,5 GiB (dos veces mi retorno previsto)
```

**Borrar la ISO de E3 de `e2-medios` devolvió 0,00 GiB**, con la copia del
bundle byte a byte idéntica (`02ab929d…` las dos). Es §4.26i medido otra vez y
por tercera vía: el `Data/` de cada bundle de UTM lleva **un clon de APFS**, así
que las dos «copias» son **un solo juego de bloques con dos nombres**. La
consecuencia práctica, y va contra la intuición: **las dos copias de la ISO
oficial no cuestan dos ISOs, cuestan una**, y borrar la del bundle rompería
`encina-E2-2vias` sin devolver nada.

**Lo que de verdad ocupaba eran los `scratchpad` de sesiones muertas: 23,5 de
los 23,5 GiB.** Y dentro había un hallazgo: `aa1ac76a…`, la ISO anterior a la
vigente, que `SCRIPTS.md` daba por **borrada** desde el 2026-08-13. No lo
estaba. Ahora sí.

---

### 4.40 LA ISO DE ESTE REPOSITORIO SE ARRANCA Y SE INSTALA — y la lista de etapas del verificador daba por segura una que no lo es (2026-08-13/14)

**El agujero que esta vuelta ataca, dicho sin maquillar:** §4.39 midió que el
medio se **fabrica** igual seis veces, y dejó escrito que **nadie había arrancado
ninguna de las cinco ISOs**. Los tres `.deb` reconstruidos desde el clon **no se
habían instalado nunca** (§4.37k, §4.38g), y el argumento de que su contenido es
idéntico huella a huella al de los vigentes **es un argumento, no una medición**.

**Lo que se lleva esta vuelta, en cuatro líneas:**

1. **`95758c9e…` arranca, instala y produce la máquina del producto.** Las cinco
   pantallas las contestó Jorge; el seed salió de `/cdrom` y el repositorio del
   medio, con `CIDATA -> <no encontrado>` escrito por la máquina.
2. **Los tres `.deb` nuevos están instalados y atados por huella**, y con eso se
   cierra lo que §4.37k y §4.38g dejaron abierto.
3. **UN `[FALLO]`, y no es del producto: falta la etapa `loading` en el
   `telemetry`.** El verificador la exige desde §4.32g porque allí se escribió
   que *«toda instalación la escribe»*. **Esta no la escribió.**
4. **Y un defecto de mi propio guion de medida**, cazado por su salida: comparar
   un `.deb` contra los `.md5sums` de dpkg **no puede cuadrar**, porque dpkg no
   mete ahí los conffiles.

#### (a) LA VM, y la prueba es lo que NO estaba conectado

`encina-95758c9e` —el nombre lleva la huella de la ISO a propósito, que el nombre
no distingue nada (trampa 14)—, creada desde cero escribiendo el `config.plist`
con `plistlib`, sin clonar nada. **La ISO va por ENLACE DURO desde `medios/`**,
que es el mismo volumen: costó **0 bytes** y `stat` dice **2 enlaces**, que es lo
que un clon de APFS nunca dice (trampa 21).

Lo que se puede enseñar **antes** de arrancar, que es donde vive esta prueba:

```
todo lo que hay en el bundle:  config.plist, Data/disco.img, Data/encina-os-nueva.iso
                               y NADA MAS
la ISO y la de medios/:        inodo 89645149, 2 enlaces, 3 715 366 912 bytes  <- el MISMO fichero
Drive declarados:              disco.img (Disk)  ·  encina-os-nueva.iso (CD, ReadOnly)
QEMU.AdditionalArguments:      []
disco.img:                     40 GiB declarados, 0 bloques de 512 ocupados
bytes distintos de cero en sus primeros 100 MiB:   0
CONTROL, los mismos 100 MiB de la ISO:            101 265 107
```

**Y el control de la trampa 16, LEÍDO Y TRANSCRITO en el momento**, porque
`debug.log` es un volátil y no hay copia de seguridad detrás (§4.35o):

```
-append        0
media=disk     1   .../encina-95758c9e.utm/Data/disco.img
media=cdrom    1   .../encina-95758c9e.utm/Data/encina-os-nueva.iso
CIDATA         0        -kernel  0        -initrd  0
CONTROL: 'edk2' en el mismo fichero -> 1   (el grep no esta mudo)
```

**Y la trampa se demostró sola una hora después**, que es mejor que citarla:
quitada la ISO y puesto el canal, el **mismo** `debug.log` pasó a decir **dos**
`media=disk` y **cero** `media=cdrom`. Quien lo leyera ahora mediría lo
contrario de lo que pasó.

#### (b) LAS CINCO PANTALLAS, y el instalador se ve en español

Se escribieron **antes de arrancar** con lo que había que teclear y lo que se
esperaba ver en cada una. Las contestó Jorge; yo no toqué el ratón.

**La novena casilla de §6ter.3, sobre esta ISO:** la primera pantalla salió en
español —«Elija la disposición del teclado», «Seleccione la variante del
teclado»— y **no hubo pantalla de idioma ni de bienvenida**: entró directa a
`keyboard`.

Y el hueco de `source` visto por el otro lado, en «Revise sus elecciones»:

```
Configuracion del disco   Borrar disco e instalar Ubuntu
Disco de instalacion      vda
Aplicaciones              <VACIO>     <- 'source' no se pregunto: es el producto
Cifrado del disco         Ninguna
Software propietario      None        <- codecs: false, drivers: false
vda1 fat32 /boot/efi   ·   vda2 ext4 /
```

**LA CASILLA 1 DE §6ter.3, MEDIDA POR PRIMERA VEZ EN EL PROPIO INSTALADOR Y NO
POR SUS CONSECUENCIAS.** Hasta hoy se marcaba mirando qué pantallas salían;
`ubuntu_bootstrap.log` lo dice con todas las letras:

```
21:11:57.132552  ==> getInteractiveSections() ["keyboard","network","storage","identity","timezone"]
21:11:57.132611  installer_service: Showing only pages requested by subiquity:
                 {keyboard, network, storage, identity, timezone}
```

**El instalador de escritorio pide la lista, la recibe entera y dice que sólo
enseña esas.** Es §6ter.0 leído en la máquina que lo ejecuta.

**Y el error de QEMU salió, como estaba previsto** (§4.34j). Se dejó estar, y
esta vez su inocuidad se midió **en vivo** en lugar de citarse: el diálogo
apareció con el disco en 3 110 MiB y el disco siguió creciendo hasta **11 065
MiB**, que es donde llegó la instalación buena de §4.34j (11 002 MB) y no donde
se atascaban las dos que llevaban `-set` (9 502 MB).

#### (c) EL VERIFICADOR: 51 correctas y UN fallo

`imagen/verificar-instalacion.sh --forma e3 --visibles 27`, como root, dentro de
la máquina, por un canal FAT conectado **después** de instalar (trampa 20):

```
[OK] 51   [FALLO] 1   [AVISO] 0   [OMIT] 0
```

Lo que contestó del producto, y es lo que había que saber:

```
iconos de Firefox que ve el usuario: 1
27 aplicaciones visibles de 95, y COINCIDEN con las 27 declaradas antes de instalar
forma (c): snapd + Snap de Firefox instalado y NUNCA abierto      <- la de D16
encina-meta 0.2.1 · encina-branding 0.1.8 · encina-firefox-native 0.2.1
autofirma 1.9.1+encina4  (la que espera por raiz, M20)
la tienda: snap-store 0+git.90575829 rev 1271
gnome-software fuera (unknown ok not-installed)
el fichero que ata el PDF es NUESTRO (R5): encina-branding
CONTROL: gnome-mimeapps.list es de 'gnome-session-common' (dpkg -S no esta mudo)
```

Y lo que la máquina dejó escrito sola, que es lo que decide:

```
CIDATA -> <no encontrado>            <- el seed salio del QUINTO sitio, /cdrom/autoinstall.yaml
REPO ELEGIDO -> /cdrom/encina-repo   <- el repositorio salio DEL MEDIO
ENCINA_ESTADO=COMPLETO   ENCINA_FALTA=   ENCINA_FECHA=2026-08-13T21:26:17Z
```

**EL FALLO, literal y hasta la etapa:**

```
[FALLO]  las etapas por las que paso el instalador
         | esperado: confirm,done,identity,install,keyboard,loading,network,storage,timezone
         | obtenido: confirm,done,identity,install,keyboard,        network,storage,timezone
```

El `telemetry` entero, al lado del de la instalación **de la misma forma** con la
ISO anterior (§4.32f, `encina-E4-cinco`), que es la comparación que toca —§4.35g
no vale aquí: aquélla corrió con `--forma e2`, y esa rama espera otra lista—:

```
ESTA (95758c9e)              §4.32f (aa1ac76a)
  "0":   keyboard              "0":    loading
  "200": network               "1":    keyboard
  "202": storage               "314":  network
  "204": identity              "398":  storage
  "274": timezone              "439":  identity
  "286": confirm               "867":  timezone
  "377": install               "955":  confirm
  "774": done                  "957":  install
                               "1418": done
```

**Ninguna etapa sobra, ninguna se preguntó de más:** `locale` y `source` no
aparecen, y el control de que ese `grep` sabe encontrar algo —`keyboard`— salió
en verde. **Lo único que falta es `loading`**, y allí ocupaba el tick `0` con
`keyboard` en el `1`; aquí `keyboard` ocupa el `0`.

**Lo que esto dice del verificador, y es el hallazgo:** la lista se hizo exacta en
§4.32g **añadiendo `loading` porque se escribió que «toda instalación la
escribe»**. Era una generalización sobre **una** medición. Esta instalación no la
escribió, así que la premisa era falsa o incompleta. **Lo que no se sabe todavía
es por qué**, y no se arregla en esta vuelta: aflojar la lista sin causa sería
convertir una casilla exacta en una que no distingue.

**Y AQUÍ EL REGISTRO DA UN ANCLAJE QUE CONVIERTE LA CORAZONADA EN UN NÚMERO.**
Las claves de `Stages` son un contador, no una hora, y **se puede fijar dónde cae
el tick 0** usando un suceso que sí tiene hora: `network` está en el tick **200**,
y el registro dice cuándo terminó Jorge la pantalla del teclado.

```
21:11:48.321775  Waiting server up to 90 seconds
21:11:48.427915  ApplicationState.CLOUD_INIT_WAIT      (x8, uno por segundo)
21:11:56.442546  ApplicationState.WAITING
21:11:56.444819  telemetry: Writing report to /var/log/installer/telemetry
21:11:57.132611  Showing only pages requested by subiquity: {keyboard,…}
21:15:16.728835  keyboard: Saved es () keyboard layout      <- Jorge pasa a 'network'

tick 0 deducido de 21:15:16.728 - 200 s  ->  21:11:56.728
'keyboard' se dibujo a las               ->  21:11:57.132
CUADRA dentro de medio segundo: el tick 0 ES esa pantalla
```

**Y la separación entre las dos etapas en disputa, medida:**

```
primer telemetry / WAITING   21:11:56.444
'keyboard' dibujado          21:11:57.132
                             ------------
                             0,688 s      <- MENOS DE UN SEGUNDO
```

**La hipótesis pasa de «encaja» a «encaja con un número»:** si el tick es la
diferencia en segundos truncada, `loading` y `keyboard` **caerían los dos en el
tick 0** y el segundo machacaría al primero, porque `Stages` es un diccionario
indexado por ese tick. En §4.32f salieron en `0` y `1`, o sea más de un segundo
entre las dos.

#### (c bis) LA HIPÓTESIS ERA MÍA Y ERA FALSA — medido el mismo día

La prueba que la decidía costaba **16 MiB y diez minutos**: arrancar la ISO en
una VM **sin disco de destino** y leer el `telemetry` de la **sesión viva**, sin
instalar nada. `encina-viva-loading`, ISO por enlace duro (0 bytes) y un canal
FAT vacío para sacar el dato.

```
{"Type":"Flutter","OEM":false,"Media":"Ubuntu 24.04.4 LTS","Stages":{"0":"keyboard"}}
```

**Una sola etapa, `keyboard`, en el tick 0. `loading` no está tampoco aquí.** Y
lo que mata la hipótesis no es eso —una colisión daría el mismo fichero—, sino
**cuándo** se escribió, leído en el registro del cliente:

```
22:17:54.002  ApplicationState.WAITING
22:17:54.008  telemetry: Writing report to /var/log/installer/telemetry   <- ya dice {"0":"keyboard"}
22:17:54.751  Showing only pages requested by subiquity: {keyboard,…}     <- la pagina, 0,742 s DESPUES
```

**El fichero ya decía `keyboard` 0,742 s antes de que se dibujara ninguna
pantalla.** Si `loading` se hubiera registrado alguna vez, ese primer volcado
—hecho 6 ms después de pasar a `WAITING`— la llevaría. No la lleva. **No hay
ningún instante en que `Stages` valiera `{"0":"loading"}`, así que no hay nada
que colisione.**

Y el remate, sobre los dos arranques y con su control:

```
                loading   CONTROL keyboard   lineas
instalacion        0            14            117
sesion viva        0            11             38
```

**La palabra `loading` no aparece NI UNA VEZ en el registro del cliente**, y el
mismo `grep` encuentra `keyboard` catorce y once veces, o sea que no está mudo.

**LO QUE QUEDA MEDIDO, y es bastante más de lo que se buscaba:**

1. **`loading` no se registra nunca en esta ISO.** No es azar de aquella
   instalación ni un tick perdido: es **reproducible en dos arranques
   independientes**, uno con instalación completa y otro sin instalar nada.
2. **El `[FALLO]` es del verificador y no del medio.** Nada de lo que Encina OS
   añade a la ISO toca el cliente del instalador.
3. **La etapa se registra al DECIDIR la primera página, no al dibujarla**, que es
   por lo que `keyboard` cae en el tick 0 aunque la pantalla salga después.

**Y LO QUE SIGUE SIN EXPLICAR, que hay que decir entero:** por qué §4.32f **sí**
tenía `loading`. Esa instalación salió de `aa1ac76a…`, y esa ISO **ya no existe**
—se borró en §4.35l—, así que aquel arranque **no se puede reproducir**. Lo
honesto es que hoy hay dos arranques que no la escriben, cero explicación de por
qué hubo uno que sí, y ninguna forma de volver a preguntárselo a aquel medio.

**Lo que esto le deja a la casilla, y es de Jorge:** con la causa medida, la
corrección que NO afloja nada es exigir **las ocho** y admitir `loading` como
posible pero no obligatoria, **con este párrafo al lado**. La lista seguiría
fallando si falta cualquiera de las ocho o si aparece `locale` o `source`, que es
para lo que existe. Lo que no se puede hacer es quitarla en silencio para que
salga verde.

#### (d) LOS TRES `.deb`, DENTRO DE LA MÁQUINA — la casilla que §4.37k dejó abierta

La cadena son tres eslabones, y comprobar sólo el primero mediría **el medio**
otra vez, no la instalación.

**1. Los bytes que viajaron en la ISO**, leídos de `/srv/encina-repo` de la
máquina instalada (29 ficheros = 28 `.deb` + `Packages`):

```
[OK] encina-branding_0.1.8_all.deb        9ec0a49db9983e6b98956152094aa78b544d1da6c8ed5482e9930414b6a5ea78
[OK] encina-firefox-native_0.2.1_all.deb  640f508e3802a2513a5be33ecab192e637f5c09f659d6273966458fe1fcc9925
[OK] encina-meta_0.2.1_all.deb            204081f0ff3c5dc33481bbe4e3febccf3d289615f174270ca9b0d067e085f9b6
CONTROL: contra una huella de ceros dice MALA
```

**Y el seed las comparó él solo durante la instalación**, con sus dos controles
negativos, que es un dato que no depende de mi guion:

```
[HUELLA  OK ] autofirma · encina-branding · encina-firefox-native · encina-meta
[HUELLA MALA] encina-meta_0.2.1_all.deb   esperada=000…000  real=204081f0…
[HUELLA MALA] fichero-que-no-existe-jamas real=<no se pudo leer>
```

**3. Lo registrado contra los ficheros que hay en el disco ahora**, que es el
eslabón que separa «el `.deb` está en `/srv`» de «el `.deb` está instalado»:

```
[OK] encina-branding:        dpkg -V no senala ni un fichero cambiado
[OK] encina-firefox-native:  dpkg -V no senala ni un fichero cambiado
[OK] encina-meta:            dpkg -V no senala ni un fichero cambiado
CONTROL: dpkg -V sobre el sistema entero senala 1 -> missing c /etc/apparmor.d/nautilus
         o sea que NO esta mudo, y los tres ceros de arriba significan algo
```

**2. Y el eslabón de en medio salió en rojo por un defecto MÍO**, no del
producto. Comparé los ficheros de dentro del `.deb` contra
`/var/lib/dpkg/info/<pkg>.md5sums`:

```
encina-branding        20 en el .deb   17 registrados   3 lineas distintas   [FALLO]
    < etc/dconf/db/gdm.d/99-encina  ·  etc/dconf/profile/gdm  ·  etc/xdg/mimeapps.list
encina-firefox-native   8 en el .deb    6 registrados   2 lineas distintas   [FALLO]
    < etc/apt/preferences.d/encina-mozilla  ·  etc/apt/sources.list.d/mozilla.sources
encina-meta             2 en el .deb    2 registrados   0                    [OK]
CONTROL: con una linea saboteada la comparacion la senala (2 diferencias)
```

**Los cinco que «faltan» son conffiles, y dpkg no los mete en `.md5sums`.** No es
una interpretación: la correspondencia se comprobó **en el clon**, y es uno a
uno con los ficheros que cada paquete instala bajo `/etc/`:

```
encina-branding        3 ficheros bajo etc/   ->  3 diferencias
encina-firefox-native  2 ficheros bajo etc/   ->  2 diferencias
encina-meta            0 ficheros bajo etc/   ->  0 diferencias   <- el control natural
```

**`encina-meta` es el que lo cierra**, porque es el único de los tres que no
instala nada en `/etc/` y es el único que cuadró. Un guion que compara contra un
fichero donde el dato **no puede estar** no es una comprobación; es la familia de
la trampa 5, y esta vez la escribí yo.

#### (e) LA FIRMA: no se intentó, y con motivo

Con un `[FALLO]` abierto no se sigue. Y aunque no lo hubiera: la firma real es
`[OJOS]`, pide certificado personal y clon efímero (§9.1), y **el que puede
pulsar es Jorge**, que ya había gastado dos horas en las cinco pantallas. Queda
donde estaba.

#### (f) EL INSTRUMENTO: `teclear-vm.sh` pierde caracteres, y dos de tres formas son mudas

Tres modos de fallo distintos, los tres **sin ningún error**, y los tres cazados
mirando la pantalla antes de pulsar `Return`:

```
1. Las COMILLAS DOBLES no llegan, y la orden entera desaparece
   'script -q -c "bash /mnt/v.sh …" /mnt/salida.txt'  ->  el prompt se queda VACIO
   Causa: el guion interpola $TEXTO dentro de comillas dobles de AppleScript.
2. El '>' NO llega
   'echo hola > /mnt/prueba.txt'  ->  llego  'echo hola  /mnt/prueba.txt'
3. Los DIGITOS se pierden
   '--forma e3 --visibles 27'  ->  llego  '--forma e --visibles'
   'grep -n -A3 FALLO'         ->  llego  'grep -n -A FALLO'
```

**El 3 es el peligroso, y por poco:** `--forma e` habría hecho que el verificador
se negara con código 2, que se ve. Pero un dígito comido en `--visibles` habría
pasado por un `[AVISO]` y nadie lo mira.

Las tres defensas, y las tres son baratas: **los dígitos van por `key code`** (`3`
es 20, `2` es 19, `7` es 26), **`script <fichero>` sin `-c`** graba la sesión
entera sin necesitar ni comillas ni `>`, y **se mira la orden en la pantalla
antes de ejecutarla**, que es la regla de siempre y hoy ha valido tres veces.
(`Ctrl+U` para borrar la línea tampoco llegó limpio; lo que sí funciona es
`Ctrl+C`.)

#### (g) EL COSTE, medido y no predicho

```
libre al empezar    72 957 616 KiB = 69,58 GiB     10 VMs, las 10 paradas
libre al terminar   61 265 000 KiB = 58,43 GiB     11 VMs, las 11 paradas
                    ------------------------------
GASTADO                              11,15 GiB     (se declararon ~11)
```

Dónde se fue, y **`du` vuelve a mentir en la dirección de §9.a**: dice `14G`
sobre el bundle, y de esos **3,46 GiB son la ISO, que no cuesta nada** porque es
un enlace duro a `medios/`. Lo real es `disco.img` con 22 695 264 bloques de 512
= **10,82 GiB**, más el canal de 16 MiB.

**Y la ISO salió intacta de servir de medio**, comprobado por huella después:
`95758c9e…`, la misma.

#### (h) Lo que esta medición NO contesta

- ~~**POR QUÉ FALTA `loading`.**~~ **CONTESTADO EL MISMO DÍA en (c bis), y mi
  hipótesis era falsa:** no se registra nunca en esta ISO, medido en dos
  arranques y con la palabra ausente del registro del cliente. **Lo que sigue sin
  explicar es por qué §4.32f sí la tenía, y su ISO ya no existe.** La casilla de
  §6ter.3 que depende del verificador **NO se marca** y el asterisco del bloque 0
  se queda: la lista del verificador hay que decidirla, y eso es de Jorge.
- **La firma real sobre esta máquina.** No se intentó (e). Sigue siendo la
  casilla más cara que queda.
- **Que la tienda instale en ESTA máquina.** Se midió que está y que
  `gnome-software` no; nadie la abrió. §4.35i lo cerró sobre otra máquina.
- **Una sola instalación.** `95758c9e…` se ha arrancado **una vez**. Que dos
  instalaciones de la misma ISO den lo mismo no está medido, y es justo la
  pregunta que el `loading` deja abierta.
- **El eslabón 2 de (d) sigue sin cerrarse por su lado bueno.** Los conffiles se
  registran en `/var/lib/dpkg/status`, no en `.md5sums`, y no se han comparado
  contra los bytes del `.deb`. Lo que sí está atado son los eslabones 1 y 3.
- **Secure Boot, amd64 y el núcleo en el medio.** Igual que ayer: límites
  declarados, no deudas.

---

### 4.41 EL VERIFICADOR CORREGIDO CON SU CAUSA DELANTE: 52 de 52, y el medio se gana su nombre (2026-08-14)

La única cosa que quedaba abierta de §4.40, hecha con la causa ya medida y no
para desatascar una casilla.

#### (a) EL CAMBIO, y por qué sacar una etapa de una lista exacta NO la afloja

La casilla existe para saber **una** cosa: *que una persona contestó lo que
Ubuntu pregunta, y nada más*. Las ocho que quedan dicen exactamente eso.
`loading` no dice quién contestó qué — dice **cómo arrancó el cliente del
instalador**. Meterla en una lista exacta no la hizo más estricta: le metió una
etapa que puede faltar sin que nada esté mal, y **una casilla que falla cuando
todo está bien enseña a saltarse los fallos**, que es §4.39j otra vez.

```
antes:    confirm,done,identity,install,keyboard,loading,network,storage,timezone
ahora:    confirm,done,identity,install,keyboard,network,storage,timezone   <- exigidas
          'loading' -> [DATO], y se dice si estaba
```

**No se ignora, se DICE**, que es más informativo que exigirla y más que
callarla. Y el motivo entero va en el propio guion, encima de la comprobación,
porque el que vuelva a tocar esto merece encontrárselo ahí y no en un `git log`.

**La lógica se probó primero en el Mac, que es gratis**, con las tres posiciones
donde puede caer la etapa y con los casos que **tienen que fallar**:

```
loading en medio / al principio / al final / ausente   -> las cuatro dan las OCHO
falta 'storage'                                        -> falla, como debe
sobra 'source'                                         -> falla, como debe
sobra 'locale'                                         -> falla, como debe
falta 'keyboard' con 'loading' dentro                  -> falla, como debe
```

#### (b) EL PAR VERDE/ROJO SOBRE LA MÁQUINA DE VERDAD, con la mutación verificada

Una casilla que sólo se ha visto en verde no está medida, está escrita (trampa
27). El sabotaje mete **`source`**, que es justo lo que el seed fija y lo que la
casilla existe para detectar — o sea que sabotea **la comprobación** y no sólo
los bytes (§4.39k):

```
0. VERDE     telemetry 9b4e0030…
             [OK] las etapas … (confirm,done,identity,install,keyboard,network,storage,timezone)
             [DATO] 'loading' NO aparece, que es lo normal en esta ISO
             [OK] 52   [FALLO] 0   [AVISO] 0   [OMIT] 0        rc=0

1. ROJO      se mete "999":"source"        telemetry b15b8ce3…
             [OK] el sabotaje SI cambio el fichero      <- verificado ANTES de leer nada
             [FALLO] las etapas por las que paso el instalador (las OCHO que deciden)
                     | obtenido: …,keyboard,network,source,storage,timezone
             [FALLO] se pregunto algo que el seed tiene que fijar
             [OK] 50   [FALLO] 2   rc=1

2. RESTAURADO  huella 9b4e0030…  IDENTICA a la de antes     <- trampa 13, por los dos lados

3. VERDE      [OK] 52   [FALLO] 0    rc=0
```

**Los dos `[FALLO]` del rojo son los dos que tenían que salir**, y eso importa:
la lista lo caza por su lado y el `grep` de `locale|source` por el suyo. Dos
comprobaciones independientes viendo el mismo defecto.

#### (c) EL MEDIO SE GANA SU NOMBRE — y el nombre lleva la huella, no sólo la versión

`encina-os-nueva.iso` era un provisional declarado. Ya no lo es:

```
medios/encina-os-E4-es-0.2.1-95758c9e.iso    95758c9e…   el que produce este repositorio
medios/encina-os-E4-es-0.2.1.iso             ac0a5721…   el de §4.35
```

**Y el nombre lleva los ocho primeros dígitos de la huella por un motivo medido,
no por gusto:** §4.35m dejó escrito que `encina-os-E4-es.iso` a secas ya
significó **dos artefactos distintos**, y §4.35f que **el tamaño no los separa**
—los dos pesan 3 715 366 912 bytes exactos—. Aquí vuelve a pasar: estas dos ISOs
tienen **el mismo E4, el mismo `es` y la misma 0.2.1**, y son ficheros
distintos, porque los tres `.deb` se reconstruyeron desde el clon (§4.37). Un
nombre que sólo lleve la versión **no puede distinguirlas**. El de la huella sí.

```
mv en el mismo volumen        -> 0 bytes
huella DESPUES del renombrado -> 95758c9e…, la misma
enlace duro con el bundle     -> inodo 89645149, 2 enlaces: sobrevive
```

#### (d) EL ESLABÓN QUE §4.40d DEJÓ A MEDIAS POR UN DEFECTO MÍO, cerrado

Allí comparé lo de dentro del `.deb` contra `/var/lib/dpkg/info/*.md5sums` y dos
paquetes «no cuadraban» por 3 y 2 ficheros. **No era el producto: dpkg no mete
los conffiles en `.md5sums`**, los registra en `/var/lib/dpkg/status`. Una
comprobación que busca el dato **donde el dato no puede estar** no es una
comprobación, y ésa la escribí yo.

Cerrado por su lado bueno — los conffiles que dpkg registró, contra **los bytes
que viajan dentro del `.deb` del medio**:

```
encina-branding        9ec0a49d…   3 conffiles registrados
  [OK] los 3 SALEN de los bytes de este .deb
       /etc/dconf/db/gdm.d/99-encina        b16e964b…
       /etc/dconf/profile/gdm               ecb70675…
       /etc/xdg/mimeapps.list               f0f26fff…
  [OK] control: con un md5 saboteado la comparacion lo senala (2)

encina-firefox-native  640f508e…   2 conffiles registrados
  [OK] los 2 SALEN de los bytes de este .deb
       /etc/apt/preferences.d/encina-mozilla    ed8dd610…
       /etc/apt/sources.list.d/mozilla.sources  ae9db12c…
  [OK] control: con un md5 saboteado la comparacion lo senala (2)

encina-meta            204081f0…   0 conffiles
  [DATO] no instala nada bajo /etc/  <- EL CONTROL NATURAL: en §4.40d fue el
                                        unico que cuadro, y ahora se ve por que

paquetes con conffiles que no cuadran: 0
```

**Con esto la cadena está atada entera y sin huecos**, que es lo que la casilla
(d) de §4.40 quería decir:

```
los BYTES del .deb que viajo en la ISO      -> sha256 contra la huella declarada   §4.40d
   -> los NO-conffiles que dpkg registro    -> .md5sums                            §4.40d
   -> los CONFFILES que dpkg registro       -> status                              aqui
   -> los FICHEROS QUE HAY EN EL DISCO      -> dpkg -V, con el control de que
                                              senala 1 en todo el sistema
                                              (missing c /etc/apparmor.d/nautilus)
```

**Los tres `.deb` reconstruidos desde el clon no sólo están instalados: cada
fichero suyo que hay en el disco sale de los bytes que viajaron en el medio.**

#### (e) Lo que esta vuelta NO contesta

- **Por qué §4.32f sí escribió `loading`.** Sigue sin explicar y su ISO ya no
  existe (§4.40c bis). Lo que ha cambiado es que **ya no bloquea nada**: la
  casilla no depende de esa etapa y la etapa se sigue diciendo.
- **La firma real sobre esta máquina.** Intacta como casilla, y ahora es **la más
  cara que queda** de verdad, porque ya no hay nada rojo delante.
- **Una sola instalación.** `95758c9e…` se ha instalado **una vez**. Dos
  instalaciones dando la misma máquina sigue sin medirse.
- **Que la tienda instale en ESTA máquina.** Sigue medida sobre otra (§4.35i).

---

### 4.42 «FICHERO FIRMADO CORRECTAMENTE» SOBRE LA MÁQUINA QUE SALE DE LA ISO DE HOY (2026-08-14)

**Por qué había que repetirla y no valía §4.33.** Aquella firma real salió el
2026-08-12 sobre una máquina que **no nació de esta ISO**, con `gnome-software`
dentro y con los `.deb` viejos. Que `autofirma` sea el mismo `faeca3a9…` por
huella es un buen argumento — **y es exactamente el mismo tipo de argumento que
decía que los tres `.deb` reconstruidos «son idénticos y por eso no hace falta
instalarlos»**, que es el agujero que §4.40 acaba de cerrar. Firmar sobre la
máquina que sale del medio de hoy es lo que convierte el argumento en medición.

#### (a) EL CLON EFÍMERO, y el control que §9.1 exige

`encina-firma-efimera`, clon de `encina-95758c9e`. **Y el clon costó 0 bytes**,
que es §4.30 otra vez: `utmctl clone` hace un clon de APFS.

```
df antes de clonar   66 785 588 KiB
df tras clonar       66 789 712 KiB     <- CERO (el ruido va al alza)
```

**El control de identidad que sirve, y no es la MAC** (§4.33d: `utmctl clone` no
la regenera, y el clon contesta en la misma IP):

```
encina-95758c9e/disco.img      2026-08-14 09:21:34   al empezar
                               2026-08-14 09:21:34   al terminar   <- NO SE ESCRIBIO
testigo dentro del clon: «clon efimero para la firma real 2026-08-14T10:14:34+02:00»
  con su control previo: NO existia antes de escribirlo
```

**El hostname del clon sigue siendo `encina-95758c9e`** —un clon no cambia de
nombre—, y por eso el testigo no es un adorno: es lo único que distingue en qué
máquina se está mirando.

#### (b) EL CERTIFICADO, dentro y atado por huella

Viajó en un volumen FAT **creado dentro del bundle del clon**, para que se
destruya con él y no toque ningún fichero compartido con la original:

```
CertificadoJMB.p12   8b5f4815d743e8c381e9f9b1ad8f97d9742e03ad   en el Mac
                     8b5f4815d743e8c381e9f9b1ad8f97d9742e03ad   en /home/jorge del clon
                     3 685 bytes, modo 600, propiedad de jorge
```

**Y se importó desde el Firefox ya abierto**, que es lo que hizo §4.33g y no es
un detalle de estilo: así entra en el perfil que AutoFirma va a mirar.

#### (c) LO QUE LA MÁQUINA DEJÓ ESCRITO SOLA — las barreras, en vivo

```
AutoFirma ARRANCO, y por el esquema afirma:      proceso 4198
  java -DAFIRMA_NSS_PROFILES_INI=/home/jorge/.config/mozilla/firefox/profiles.ini
       -jar /usr/share/autofirma/autofirma.jar
       afirma://websocket?ports=57519,53740,65274&v=4&jvc=3&idsession=yQFlKafeb…

el navegador que corrio                          3120 /usr/bin/firefox   <- EL NATIVO
la CA del socket, sola                           10:22:01 «instalada en
                                                 …/dlmaf4vt.default-release»
                                                 Finished, sin reintentos
~/.java 10:22   ·   ~/.afirma 10:24
```

**El `-DAFIRMA_NSS_PROFILES_INI` apuntando a `~/.config/mozilla/firefox` es la
medición que más vale de todo esto**, porque es literalmente lo que el parche de
`+encina4` existe para conseguir: AutoFirma buscando el perfil **donde el deb de
Mozilla lo pone**, y no en `~/.mozilla` (§4.9c y la trampa del perfil que no
está donde parece).

Y el almacén del perfil nativo después de firmar, **con el apodo personal
omitido a propósito** (§9.1):

```
certutil -L -d sql:.        (en …/dlmaf4vt.default-release)
  SocketAutoFirma                 C,,      <- la CA del socket
  <el certificado personal>       u,u,u
certutil -K                 -> su clave privada RSA, presente
CONTROL: -n APODO-QUE-NO-EXISTE-JAMAS -> «Could not find cert» + PR_FILE_NOT_FOUND_ERROR
cert9.db 229 376 B y key4.db 294 912 B, escritos a las 10:22
```

**Las dos barreras en el mismo almacén**: la CA que hace que el navegador confíe
en el socket TLS de AutoFirma, y el certificado con el que se firma.

#### (d) LA FIRMA — **la declara Jorge, y yo no vi esa pantalla**

```
«Fichero firmado correctamente»     valide.redsara.es, 2026-08-14, mirado por Jorge
```

**Palabra por palabra lo mismo que §4.33g.** Yo capturé la pantalla después y el
OCR sólo alcanzó la página de VALIDe con sus botones: el diálogo ya se había
cerrado. **Así que esta línea es una declaración, como la del instalador en
español de §4.25d, y va escrita como tal** — lo que sí está medido por mi parte
es todo lo de (c), que es la cadena entera salvo el «¿la sede lo acepta?».

**Y no se guardó el fichero firmado**, dicho por Jorge y comprobado en el disco:
`Descargas` y `Escritorio` vacíos. **Consecuencia que hay que escribir: no hay
artefacto que validar después.** Lo que se midió es que la firma **se ejecuta**;
que el fichero resultante pase un validador es otra medición y no se hizo.

#### (e) LA DESTRUCCIÓN, que no es opcional

```
lo que llevaba dentro: disco.img (con el certificado en el perfil) y cert.img (el .p12)
respaldo del registro de UTM, ANTES        plutil OK
df 66 417 928 -> 66 736 172 KiB            devuelto 0,304 GiB
```

Y la comprobación de que no queda rastro, **con su control**:

```
.p12 bajo el contenedor de UTM   0
.p12 en el scratchpad            0
.p12 en el repositorio           0
CONTROL: el buscador NO esta mudo -> encuentra ~/Documents/CertificadoJMB.p12
11 en utmctl y 11 bundles, las 11 paradas, plutil OK
```

**Van cuatro firmas reales y las cuatro máquinas destruidas** (§9.1): 2026-08-08,
2026-08-09, 2026-08-12 y ésta.

#### (f) DOS FALSOS `[FALLO]` DE MI PROPIO INSTRUMENTO, y uno daba miedo

1. **`afirma.desktop: AUSENTE`**, que si se lee mal parece que falta el manejador
   del esquema y la firma no puede ir. **Es falso: el fichero se llama
   `autofirma.desktop`**, y lo que decide contestó bien a la primera:
   ```
   xdg-mime query default x-scheme-handler/afirma  ->  autofirma.desktop
   /usr/share/applications/autofirma.desktop, 376 bytes
   ```
   Mi guion preguntaba por un nombre inventado por mí. **Se pregunta por la
   asociación, no por la ruta que uno se imagina.**
2. **`certutil: SEC_ERROR_BAD_DATABASE`**, que parece un almacén corrupto y es
   **un espacio de más al teclear**: el comodín llegó como `firefox/ *.default-release`,
   o sea una ruta que no existe. Tecleado bien, el almacén contesta perfectamente
   (c). Es la regla de siempre: **mira la orden en la pantalla antes de creerte
   su resultado**, y esta vez casi me hace escribir que el perfil estaba roto.

#### (g) Lo que esta medición NO contesta

- **La huella de la CA del socket no se comparó con la del paquete.** §4.33f sí
  lo hizo (`73f752a4…` a los dos lados). Aquí se midió que la CA **llega sola y
  al perfil correcto**, no que sea la misma que instala el `.deb`. Es un cabo
  suelto barato y queda dicho.
- **No hay fichero firmado.** Ver (d).
- **Una sola firma, y en una VM.** No dice nada sobre otro hardware, otra sede ni
  otro certificado.
- **Nada de esto discrimina `+encina3` de `+encina4`**, que sigue siendo M20 en
  contenedor, igual que en §4.33.

---

### 4.43 EL TEMA DE ICONOS GANA, EL NOMBRE ERA OTRO — y el botón sigue con el logo de Ubuntu (2026-08-14)

**La casilla NO se marca.** El paquete hace todo lo que se propuso —el tema
propio gana, resuelve al icono de Encina y no rompe nada, con el verificador en
**62 de 62**—, y **el botón de la rejilla sigue pintando el logotipo de
Ubuntu**, mirado en pantalla después de un reinicio completo. Las dos sospechas
que se escribieron por adelantado están **descartadas con dato**, y lo que queda
es una tercera que nadie había puesto sobre la mesa.

#### (a) LAS CUATRO MEDIDAS, antes de escribir una línea del paquete

Sobre `encina-95758c9e`, por su canal FAT, con `script <fichero>` sin `-c`. La
sesión de verdad estaba viva y el guion lo comprobó primero: `Type=wayland`,
`Active=yes`, `gnome-shell` en el pid 1744.

```
(a) icon-theme de la sesion (por el bus de jorge)   'Yaru'
    con XDG_CURRENT_DESKTOP=ubuntu:GNOME            'Yaru'
    por defecto del gschema, sin overrides          'Adwaita'
    CONTROL: una clave que no existe                No such key ?clave-que-no-existe-jamas?

(c) el fichero de hoy, y de quien es
    /usr/share/icons/Yaru/scalable/actions/view-app-grid-ubuntu-symbolic.svg
        -> yaru-theme-icon                     <- por eso R5 prohibe pisarlo
        -> y ES UN ENLACE: ../places/start-here-symbolic.svg
    CONTROL: un fichero inventado -> dpkg-query: no path found matching pattern
    CONTROL: uno ajeno conocido   -> /usr/share/icons/Yaru/index.theme -> yaru-theme-icon

(d) un tema de PRUEBA con Inherits=Yaru,hicolor y un cuadrado dentro,
    preguntado al resolvedor de GTK 4, que es el que decide:
      tema=EncinaPrueba  view-app-grid-symbolic -> /usr/share/icons/EncinaPrueba/…  <- GANA
                         folder                 -> /usr/share/icons/Yaru/16x16/places/folder.png
                         firefox                -> /usr/share/icons/hicolor/16x16/apps/firefox.png
                         system-run-symbolic    -> /usr/share/icons/Yaru/scalable/actions/…
      tema=Yaru          view-app-grid-symbolic -> /usr/share/icons/Yaru/scalable/actions/…
    CONTROL: el mismo comparador, con tema='Yaru', da OTRO fichero: distingue
    Y el instrumento se borro solo, con su comprobacion: quedan 0 directorios
```

**La (d) contesta la sospecha nº1 antes de gastar nada: un tema que hereda de
Yaru GANA para lo suyo y no rompe el resto.** Y contesta también la pregunta
que no se hizo: sin el tema instalado, con `set_theme_name('Encina')`, **todo**
resuelve a `None` — o sea que el resolvedor no miente por inercia.

#### (b) EL HALLAZGO QUE CAMBIÓ EL PAQUETE, y es la medida que valió la vuelta

`view-app-grid-symbolic` **no es el nombre que pide el botón**:

```
/usr/share/gnome-shell/extensions/ubuntu-dock@ubuntu.com/appIcons.js:1371
    this._iconActor.iconName = `view-app-grid-${Main.sessionMode.currentMode}-symbolic`;
```

Eso es un JS, o sea un argumento. **Atado al sistema vivo**, que es lo que lo
convierte en medición:

```
/proc/<pid de gnome-shell>/environ   GNOME_SHELL_SESSION_MODE=ubuntu
                                     XDG_CURRENT_DESKTOP=ubuntu:GNOME
    CONTROL de ese lector: USER=jorge   (no sale vacio a todo)
los cuatro .desktop de sesion        Exec=env GNOME_SHELL_SESSION_MODE=ubuntu …
los modos instalados                 initial-setup.json  ubuntu.json
nombre deducido                      view-app-grid-ubuntu-symbolic
y existe                             lrwxrwxrwx … -> ../places/start-here-symbolic.svg
    CONTROL: el mismo ls sobre un nombre inventado -> No such file or directory
```

**Un paquete con `view-app-grid-symbolic.svg` dentro se habría construido,
instalado y verificado sin un solo error, y no habría cambiado nada.** El SVG
que había en `assets/` llevaba ese nombre.

**Y la segunda mitad, la del `gschema.override`:** Ubuntu fija `icon-theme`
**sólo por escritorio**, y esto decide si el fichero sirve de algo:

```
10_ubuntu-settings.gschema.override, con su seccion:
    [org.gnome.desktop.interface:GNOME-Greeter]  icon-theme = "Yaru"
    [org.gnome.desktop.interface:ubuntu]         icon-theme = "Yaru"
    [org.gnome.desktop.interface:Unity]          icon-theme = "ubuntu-mono-dark"
    [org.gnome.desktop.interface:communitheme]   icon-theme = "Suru"
    NO HAY SECCION GENERICA
dconf del usuario para icon-theme    <vacio>   -> el override gana
    CONTROL: la misma orden si contesta '46.0' para welcome-dialog-last-shown-version
```

Es la trampa de 0.1.2 —la del fondo— vista **antes** de tropezar con ella.

#### (c) EL PAQUETE, y las siete cosas

`encina-branding` **0.1.9**: `/usr/share/icons/Encina` con `Inherits=Yaru,hicolor`,
el icono en `scalable/actions/` con **los dos nombres y un solo fichero fuente**
—el genérico lo hace `debian/rules` a partir del otro, igual que ya hacía con
`logo.png`—, e `icon-theme='Encina'` en las secciones genérica y `:ubuntu`.

```
7c2390dd93974ff440b89ba322575e69b82751ce1f15b0ab86997fb767ae1b49   6 161 756 bytes
```

**Reproducible, y comprobado a propósito:** dos árboles extraídos del mismo
commit, al segundo se le pusieron **todos los mtimes en otra fecha** con
`touch`, y la huella salió idéntica. (La fecha del changelog se puso a las
09:00 del día por esto mismo: `dpkg-deb` recorta los mtimes posteriores y **deja
pasar los anteriores**, §4.37.)

Las siete de `SCRIPTS.md`, con el control de la regla delante —`grep` del nombre
viejo por `imagen/` entero, y el mismo `grep` con el nuevo—:

```
1. encina-seed.sh        H_BRANDING y el nombre del fichero
2. fabricar-seed.sh      el array FICHEROS
3. el indice Packages    regenerado en la VM: 28 entradas, la huella vieja 0 veces,
                         la nueva 1
5. la lista del seed     no cambia: sigue siendo 'encina-branding'
6. la del verificador    no cambia por version, PERO gana la seccion 8 (abajo)
7. LOS DOS YAML          autoinstall.yaml y autoinstall-unattended.yaml
   autoinstall.yaml            -> 1 linea distinta
   autoinstall-unattended.yaml -> 1 linea distinta
   CONTROL del diff: el fichero consigo mismo da 0
mas fabricar-iso.sh y repo-manifiesto.tsv, que tambien llevan el nombre dentro
```

**Y el malo a propósito, antes del bueno** — el `.deb` viejo con el nombre nuevo:

```
[FALLO] huella distinta en encina-branding_0.1.9_all.deb
        esperada 7c2390dd…   real 9ec0a49d…
```

#### (d) UN `[OK]` MÍO QUE NO COMPROBABA NADA — y un arreglo que daba verde sobre el fallo

`03-construir.sh` dijo esto sobre un árbol cuyo changelog decía 0.1.9:

```
[OK] Generado: encina-branding_0.1.7_all.deb
```

Se invocó sin `ENCINA_REPO`, y `raiz_repo()` usa `~/encina` por defecto: **otro
clon, de cuatro días antes**. El guion lo construyó entero sin una queja. Lo
cazó de rebote la lista de ficheros esperados —tres `[FALLO]` de iconos—, y la
versión pasó en verde.

**Y el arreglo obvio no servía, que es lo que hay que llevarse.** Comparar la
versión del `.deb` con la del changelog **da verde sobre este mismo fallo**,
porque el desvío se lleva las dos cosas al mismo sitio equivocado. Está en la
salida del rojo reproducido:

```
0. ROJO (sin ENCINA_REPO)
   [OK]    Generado: encina-branding_0.1.7_all.deb
   [FALLO] Se ha construido OTRO arbol, no el que tienes delante
           | aqui:       /home/jorge/rejilla3/debian-packages/encina-branding
           | construido: /home/jorge/encina/debian-packages/encina-branding
   [OK]    La version del .deb es la del changelog (0.1.7)   <- EL ARREGLO FACIL, EN VERDE
   correctas: 26   fallos: 4   rc=1

1. VERDE (con ENCINA_REPO)
   [OK]    Generado: encina-branding_0.1.9_all.deb
   [OK]    El arbol construido es el de aqui (…/rejilla3/…)
   correctas: 30   fallos: 0   rc=0
```

Lo que separa los dos casos no es la versión: es **que el árbol construido sea
el que tienes delante**, y hay que leerlo antes del `cd` que hace el propio
guion — la primera versión de la comprobación lo leía después y por eso salió
verde las dos veces.

#### (e) LA INSTALACIÓN, con el antes y el después de lo único que decide

`dpkg -i` sobre la máquina, sin red y sin refabricar la ISO. El `.deb` se
comprobó por huella **antes** de instalarlo, con su control contra una huella de
ceros.

```
                                    ANTES (0.1.8)            DESPUES (0.1.9)
icon-theme por defecto (ubuntu:GNOME)   'Yaru'                   'Encina'
/usr/share/icons/Encina/index.theme     No such file             1865 bytes, de encina-branding
tema=Encina  view-app-grid-ubuntu-…     None                     /usr/share/icons/Encina/…
tema=Encina  view-app-grid-symbolic     None                     /usr/share/icons/Encina/…
tema=Encina  folder                     None                     /usr/share/icons/Yaru/…
tema=Yaru    view-app-grid-ubuntu-…     /usr/share/icons/Yaru/…  /usr/share/icons/Yaru/…   <- CONTROL
```

**Y el de Yaru sigue siendo de Yaru (R5), sin tocar:**

```
/usr/share/icons/Yaru/scalable/actions/view-app-grid-ubuntu-symbolic.svg  yaru-theme-icon
lrwxrwxrwx 1 root root 33 Apr 18 2024 … -> ../places/start-here-symbolic.svg
dpkg -V encina-branding   -> ni una linea
    CONTROL: dpkg -V sobre el sistema entero -> 1 linea (no esta mudo)
```

El verificador, como root, con la sección 8 nueva:

```
[OK] 62   [FALLO] 0   [AVISO] 0   [OMIT] 0
```

**62 = las 52 de §4.41 más 10.** Las 52 siguen en verde: el paquete no rompió
nada. Las 10 nuevas preguntan **a qué fichero resuelve el nombre**, con el
control que las hace valer: *el mismo comparador, preguntado por `Yaru`, tiene
que contestar OTRO fichero*.

**Y una de esas diez salió `[FALLO]` la primera vez, por mi culpa y no del
producto** (§4.42f otra vez):

```
[FALLO] control: un icono inventado no resuelve
        | esperado: NO-RESUELVE
        | obtenido: None
```

En GTK 4 `lookup_icon` **nunca falla**: ante un nombre inventado devuelve el
icono de reserva, cuyo `GFile` no tiene ruta y `get_path()` vale `None`. El
control funcionaba; lo que estaba mal era la cadena que yo esperaba.

#### (f) EL ROJO, mirado en pantalla — y las dos sospechas previstas, descartadas

Reinicio completo de la máquina, sesión nueva, `Super+A`:

```
EL BOTON DE APLICACIONES DEL DOCK SIGUE SIENDO EL LOGOTIPO NARANJA DE UBUNTU
```

**Sospecha nº1, «el tema propio no gana a Yaru para ese icono»: FALSA.**

```
gsettings get org.gnome.desktop.interface icon-theme   (EN LA SESION VIVA de jorge)
  -> 'Encina'
tema=Encina  view-app-grid-ubuntu-symbolic -> /usr/share/icons/Encina/scalable/actions/…
```

**Sospecha nº2, «gnome-shell cachea y hace falta reiniciar la sesión»: no lo
explica.** No se reinició la sesión: se reinició **la máquina entera**, y el
`gnome-shell` que pintó ese botón arrancó con el tema ya puesto.

**Lo que queda, y es una tercera que no estaba escrita:** el tema efectivo es
`Encina`, el resolvedor de GTK 4 devuelve el fichero de Encina para el nombre
exacto que el JS del dock construye, y el shell pinta otro. Se para aquí a
propósito, sin tocar nada más.

#### (g) EL COSTE

```
libre al empezar   'df -h' decia 64Gi        11 VMs, las 11 paradas
libre al terminar   65 760 572 KiB = 62,71 GiB   11 VMs, las 11 paradas
```

**Y hay un defecto en esta propia cuenta, que se dice:** el `df` inicial se tomó
en `-h`, que redondea a 1 GiB, así que el gasto sólo se puede acotar entre 0,3 y
1,8 GiB. Se declararon ≤0,8 GiB. `df -k` a los dos lados, la próxima vez.

Lo que sí está medido: **el repo offline son 169 MB, no 3,4 GB** —eso es la ISO
entera—, y no hubo que extraerlo de ningún medio: cuatro repos cosechados del
constructor cuadraban con las huellas del seed, y `~/cosecha` no, lo cual sirvió
de control natural. **No se fabricó ninguna ISO.**

#### (h) Lo que esta medición NO contesta

- **POR QUÉ EL SHELL NO PINTA EL ICONO DEL TEMA.** Es lo que queda. Tres cosas
  que no se han medido y que separan las explicaciones: a qué resuelve el nombre
  **a 48 px** —todo lo de arriba se preguntó a 16, y el dock usa
  `dash-max-icon-size 48`—; si `Main.sessionMode.currentMode` vale de verdad
  `ubuntu` **dentro del shell** y no sólo en su entorno; y si el `St` del shell
  usa otra cadena de temas que la `Gtk.IconTheme` con la que se midió.
- **El color.** El icono se envía con `fill="#808080"`, que es la convención del
  fichero de Yaru al que sustituye, y **no se ha visto pintado**, así que no se
  sabe si el recoloreado del shell lo trata como se espera.
- **`view-app-grid-ubiquity-symbolic`** —el del modo del instalador— no se toca:
  es la otra mitad del bloque 1.
- **La ISO no se ha refabricado**, así que la huella de un medio con 0.1.9
  dentro no existe. El seed y los dos YAML ya la exigen, o sea que **el árbol de
  hoy no puede fabricar la ISO vieja**, que es lo correcto.
- **Una sola máquina, y no virgen.** `encina-95758c9e` lleva ahora 0.1.9
  instalado por encima de 0.1.8. Que una instalación **desde el medio** dé lo
  mismo no está medido.
- **La primera sesión sigue diciendo Ubuntu:** `gnome-initial-setup` abre con la
  corona y «Le damos la bienvenida a Ubuntu 24.04.4 LTS». Es del bloque 1 y no
  estaba inventariado.

---

### 4.44 FUERA LA BIENVENIDA DE UBUNTU: no era una clave, era una unidad de systemd (2026-08-15)

**La casilla se marca.** Una sesión nueva de `encina-95758c9e` entra directa al
escritorio de Encina y la ventana no aparece, con `encina-branding` 0.1.11
instalado. Y lo que la quita no es lo que esta casilla suponía —«un paquete que
sobra o una clave que lo desactiva»—: **no hay ninguna clave, y el paquete no
sobra**. Lo que hay es una unidad de usuario de systemd, y se enmascara.

#### (a) QUÉ LA LANZA, medido en `encina-dev` por `ssh`

```
$ dpkg -l gnome-initial-setup | tail -1
ii  gnome-initial-setup 46.3-1ubuntu3~24.04.2 arm64

$ cat /usr/lib/systemd/user/gnome-initial-setup-first-login.service
[Unit]
Description=GNOME Initial Setup
BindsTo=gnome-session.target
After=gnome-session.target
Conflicts=gnome-session@gnome-login.target
Conflicts=gnome-session@gnome-initial-setup.target
ConditionPathExists=!%E/gnome-initial-setup-done
[Service]
Type=oneshot
ExecStart=/usr/libexec/gnome-initial-setup --existing-user
Restart=no

$ ls -la /usr/lib/systemd/user/gnome-session.target.wants/
gnome-initial-setup-first-login.service -> ../gnome-initial-setup-first-login.service
```

**Y el `.desktop` de `/etc/xdg/autostart/` NO es el que decide**, aunque es el
sitio donde uno mira primero:

```
$ cat /etc/xdg/autostart/gnome-initial-setup-first-login.desktop
Exec=/usr/libexec/gnome-initial-setup --existing-user
AutostartCondition=unless-exists gnome-initial-setup-done
X-GNOME-HiddenUnderSystemd=true          <-- esta linea
```

`X-GNOME-HiddenUnderSystemd=true` significa «si la sesión la gestiona systemd,
ignórame», y la de Ubuntu 24.04 la gestiona systemd. Los dos caminos existen;
sólo uno está vivo.

#### (b) POR QUÉ VOLVÍA EN CADA SESIÓN, con su control

La puerta es `ConditionPathExists=!%E/gnome-initial-setup-done`, o sea
`~/.config/gnome-initial-setup-done`, **que sólo se escribe si el asistente se
termina**. En la máquina del producto no existe; en el constructor sí, y por eso
allí la ventana no sale nunca. Ése es el control de la explicación, y las dos
mitades están medidas:

```
encina-dev        $ ls -la ~/.config/gnome-initial-setup-done
-rw-rw-r-- 1 jorge jorge 3 ago  6 21:38 /home/jorge/.config/gnome-initial-setup-done

encina-95758c9e   $ ls -l /home/jorge/.config/gnome-initial-setup-done
ls: no se puede acceder a '/home/jorge/.config/gnome-initial-setup-done': No existe el archivo o el directorio
```

#### (c) POR QUÉ NO SE ARREGLA CON ESE FICHERO, y es R1 en estado puro

Ese fichero es **del usuario**. Ponerlo por defecto para todos exige
`/etc/skel`, que R1 prohíbe: sólo alcanza a los usuarios creados después y no se
puede actualizar. Así que se ataca **la unidad**, no la puerta.

#### (d) LA MÁSCARA, y su mecanismo probado por los dos lados

`/etc/systemd/user/` gana a `/usr/lib/systemd/user/` en la ruta de búsqueda de
systemd, así que un enlace a `/dev/null` con el nombre de la unidad la
enmascara **sin sobrescribir el fichero de `gnome-initial-setup`** (R5). Es la
misma sombra que el paquete ya usa para `/etc/dconf/profile/gdm` y
`encina-firefox-native` para `firefox_firefox.desktop`.

Probado a mano en `encina-dev` **antes** de meterlo en el paquete, con los dos
controles y devolviendo la máquina a como estaba:

```
CONTROL, antes de nada                        static
con la mascara puesta a mano                  masked
y retirada, que es el control por el otro lado  static
queda algo?   ls: no se puede acceder ... No existe el archivo o el directorio
```

**Y tiene que ser un enlace a `/dev/null`:** un fichero normal vacío con ese
nombre no enmascara, systemd lo lee como una unidad sin secciones. Es lo que
deja un clon de git con `core.symlinks=false`, así que `03-construir.sh` lo
comprueba (`[OK] La máscara de la bienvenida apunta a /dev/null`).

#### (e) EN LA MÁQUINA DEL PRODUCTO, con el control por delante

`encina-95758c9e`, a ciegas con `teclear-vm.sh` y capturando antes de cada
Intro. **El control se tomó primero**, en la sesión que se abrió antes de
instalar nada:

```
sesion recien abierta, 0.1.10   la ventana SALE, entera, con la corona
                                (design/capturas/despues/06-control-la-bienvenida-vuelve.png)
$ systemctl --user is-enabled gnome-initial-setup-first-login.service
static
```

Y después de `sudo dpkg -i encina-branding_0.1.11_all.deb`:

```
Desempaquetando encina-branding (0.1.11) sobre (0.1.10) ...
Configurando encina-branding (0.1.11) ...

$ systemctl --user is-enabled gnome-initial-setup-first-login.service
masked
$ ls -l /etc/systemd/user/gnome-initial-setup-first-login.service
lrwxrwxrwx 1 root root 9 ago 15 00:11 ... -> /dev/null
```

**Reiniciada la máquina y abierta sesión otra vez: no sale**
(`design/capturas/despues/06-primera-sesion-sin-bienvenida.png`). El resto de la
primera sesión sigue igual —fondo, dock abajo, bellota—, que es el control que
pedía la casilla.

#### (f) EL CONFUSOR QUE HABÍA QUE DESCARTAR, y se descartó

Durante la sesión de antes se intentó cerrar la ventana con Escape y con
Alt+F4 y en algún momento desapareció de la pantalla. **Si el asistente se
hubiera completado, habría escrito el marcador y la ausencia posterior no
probaría nada.** Medido después del reinicio, dentro de la sesión nueva:

```
$ ls -l /home/jorge/.config/gnome-initial-setup-done
ls: no se puede acceder a ... : No existe el archivo o el directorio
```

Sigue sin existir. La ventana falta **por la máscara**, no por la puerta.

#### (g) LA BATERÍA, con el control de la purga dentro

`05-verificar.sh` en `encina-dev` — **14 correctas, 0 fallos**. La comprobación
nueva no vale sin su control, y el control es la purga:

```
=== 2. La bienvenida de Ubuntu, enmascarada (0.1.11) ===
  [OK]    /etc/systemd/user/gnome-initial-setup-first-login.service -> /dev/null
  [OK]    systemctl --user is-enabled ... -> masked
=== 4. Purga: desinstalación limpia ===
  [OK]    Control: purgado, la unidad vuelve a 'static' (la bienvenida volvería)
```

`03-construir.sh`: **33 correctas, 0 fallos, 0 avisos**, `lintian` sin una
línea. El enlace a `/dev/null` no le molesta.

#### (h) UNA CORRECCIÓN DE ALGO QUE IBA A ESCRIBIR SIN MEDIRLO

Iba a justificar «no se desinstala `gnome-initial-setup` porque se lleva por
delante `ubuntu-desktop-minimal`». **Falso.** Medido:

```
$ apt-cache show ubuntu-desktop-minimal | (campo de cada linea)
Recommends            <- las dos versiones del indice
Recommends

$ sudo apt-get -s purge gnome-initial-setup
Los siguientes paquetes se ELIMINARÁN:  gnome-initial-setup*
0 actualizados, 0 nuevos se instalarán, 1 para eliminar y 15 no actualizados.
```

Es un `Recommends:`, y purgarlo no arrastra a nadie. El motivo real de no
quitarlo es otro: **quitar un paquete cambia el juego de paquetes del medio**
—otra fila del manifiesto y otra ISO— y un `Recommends:` desinstalado vuelve en
cuanto apt reconsidere `ubuntu-desktop-minimal`. La máscara cuesta un enlace
simbólico y no se deshace sola.

#### (i) LA DECISIÓN QUE ACOMPAÑA, tomada y no dejada caer

**En su sitio no va nada**, decisión de Jorge del 2026-08-15. La primera
impresión pasa a ser el escritorio de Encina. La pantalla propia que cuente el
producto queda **abierta como decisión**, no cerrada.

#### (j) LO QUE ESTA MEDICIÓN NO CONTESTA

- **Una sesión sin systemd.** Si algún día la sesión no la gestionara systemd,
  el `.desktop` de `/etc/xdg/autostart/` volvería a mandar y la máscara no lo
  taparía. No hay forma de sombrear ese fichero sin `/etc/skel` (R1) ni
  sobrescribirlo (R5); hoy no hace falta y queda dicho.
- **`gnome-initial-setup-copy-worker.service` no se toca.** Corre antes de la
  sesión y no pinta nada.
- **Un usuario nuevo en la máquina del producto.** La máscara es del sistema y
  `05-verificar.sh` crea el usuario `prueba` en el constructor, pero **entrar
  con él en la sesión gráfica sigue siendo `[OJOS]`** y no se ha hecho.
- **Un aviso que no es de este cambio:** tras el reinicio salió el diálogo de
  apport «…error interno», y `/var/crash` tiene **un** volcado,
  `_usr_bin_spice-vdagent.1000.crash` de las 00:25 — el agente de invitado de
  UTM, no `gnome-initial-setup`. No se ha investigado.

---

### 4.45 LA ISO VUELVE A SALIR, con 0.1.11 dentro — y cambiar un `.deb` no eran cuatro sitios, son cinco (2026-08-15)

**La casilla se marca.** `construir-todo.sh` pasa entero y **dos pasadas dan la
misma huella**, que es su definición de terminado y no «sale una ISO».

```
pasada 1   1224b5b17b559007071dee8fcaa620ff28cc3d8361eb75fdbe4af1eb3401529f   3715366912
pasada 2   1224b5b17b559007071dee8fcaa620ff28cc3d8361eb75fdbe4af1eb3401529f   3715366912
$ cmp encina-os-0.1.11-pasada1.iso encina-os-0.1.11-pasada2.iso
                                    (sin salida: identicas byte a byte)
CONTROL, para que «iguales» signifique algo:
  encina-os-E4-es-0.2.1.iso   ac0a5721b9ff5b2b762d3467bbc20d8e62374df22a5d18e3c483f8c25b1fa443
```

Las dos pasadas son del commit `8ca22f4`. El medio se conserva como
`medios/encina-os-E4-es-0.2.1-1224b5b1.iso`, con la huella en el nombre porque
la versión sola no distingue dos medios (§4.35m).

#### (a) LA HUELLA DEL `.deb`, y por qué no vale la del árbol de trabajo

La casilla lo pedía explícito y aquí está el número que lo demuestra:

```
construido sobre 'git archive HEAD'   fe5e87b00d8b41e0…   6165162 bytes
el que se instalo en el producto,
salido de un tar del arbol de trabajo  (otra)             6165258 bytes
```

**96 bytes de diferencia, y el contenido es el mismo:** son las fechas que
`dpkg-deb` deja pasar cuando son anteriores a `SOURCE_DATE_EPOCH` (§4.37). El
`.deb` que se instaló en `encina-95758c9e` para mirar la pantalla **no es el que
viaja en la ISO**, y eso está bien: lo que se midió allí fue el comportamiento,
no los bytes.

#### (b) LOS CINCO SITIOS, y el quinto lo dijo una herramienta y no una lectura

`SCRIPTS.md` («Cómo se rehace el seed cuando cambia un `.deb`») dice cuatro:

1. `imagen/repo-manifiesto.tsv` — versión, nombre, tamaño y huella
2. `imagen/encina-seed.sh` — `H_BRANDING=` **y** el nombre en la línea `huella`
3. `imagen/fabricar-seed.sh` — el nombre en el array `FICHEROS`
4. `imagen/fabricar-iso.sh` — el nombre en su array `FICHEROS`

**Y hay un quinto:** los **dos** `autoinstall*.yaml` llevan el seed entero
dentro, en base64, como `late-command`. No se descubrió leyendo nada:

```
== 3. la late-command del seed == encina-seed.sh
[FALLO] autoinstall.yaml y encina-seed.sh se han separado.
        Rehazlo con: ./fabricar-seed.sh --yaml .../imagen/autoinstall.yaml --actualizar-yaml ...
```

Un `[FALLO]` que nombra la orden que lo arregla. Se rehicieron los dos —el de E2
desatendido y el de E3—, y `fabricar-seed.sh` confirmó el ajuste:
`[OK] coinciden (29563 bytes de guion, 39420 de base64)`.

#### (c) UN FALLO DEL INSTRUMENTO QUE SÓLO PODÍA SALIR HOY

La primera pasada murió en el paso 2 con esto:

```
== 2. 'git archive HEAD' al constructor -- lo versionado, no el disco (§4.37c)
[FALLO] el arbol no llego entero: 1 diferencias
23d22
< debian-packages/encina-branding/src/etc/systemd/user/gnome-initial-setup-first-login.service
```

**El árbol había llegado entero.** Lo que fallaba era el cotejo: compara
`git archive HEAD | tar -tf -` contra `find . -type f`, y **`-type f` no ve los
enlaces simbólicos**. Ese fichero es el primer enlace versionado de este
repositorio —la máscara de §4.44—, así que hasta hoy el defecto no podía
manifestarse:

```
$ git ls-files -s | awk '$1=="120000"'
120000 dc1dc0cd… 0  debian-packages/encina-branding/src/etc/systemd/user/gnome-initial-setup-first-login.service
                     (uno, y es de hoy)
```

Arreglado con `find . \( -type f -o -type l \)`. **Y la misma familia en
`comprobar-propios.sh`**, que huella el contenido de un `.deb` con `find -type f`
y luego imprime «ficheros: N»: con un enlace dentro, la cuenta era correcta y el
enlace no se mencionaba. Ahora se listan aparte, con su destino y **diciendo que
no tienen huella**, en vez de dejar que el listado parezca completo.

*Lo que hace este fallo interesante y no una errata:* **apuntaba en la dirección
segura**. Dijo «falta algo» de algo que sí estaba, que es el lado bueno por el
que puede equivocarse un cotejo. Si hubiera sido al revés —`find` viendo un
fichero que `git archive` no manda— habría pasado en silencio.

#### (d) LO QUE SIGUE EN VERDE, y no se da por hecho

Los controles de `construir-todo.sh` volvieron a dar su respuesta mala cuando les
tocaba, que es lo único que hace valer los `[OK]`:

```
[OK]  control: con un nombre cambiado, el cotejo lo senala
[OK]  control: sin autofirma la cosecha se queda en 27 y se niega
[OK]  control: con una huella cambiada en UN caracter, el cotejo la senala
[OK]  control: con un tamano falseado, la comparacion lo senala
[OK]  los tres .deb propios cuadran con el manifiesto, huella y tamano
      encina-branding_0.1.11_all.deb  fe5e87b00d8b…  6165162 bytes
```

#### (e) LO QUE ESTA MEDICIÓN NO CONTESTA

- **Que la ISO arranque.** El propio guion lo dice al terminar. Hace falta una VM
  creada desde cero, y con este medio no se ha hecho.
- **Que la máscara de §4.44 llegue por el medio.** Está medida instalando el
  `.deb` a mano sobre la máquina del producto; que salga así de una instalación
  **desde la ISO** no está medido y es lo que cerraría el círculo.
- **`deb-historicos/`** no se ha tocado: el 0.1.9 y el 0.1.10 no están ahí, y sus
  bytes no se conservan. El 0.1.9 sí se puede rehacer desde su commit.

---

### A3 — Por qué se suprimió `encina-locale-es` (2026-08-07)

Registro para no volver a plantearla. **Medido en VM Ubuntu 24.04 arm64 en español**,
con `encina-branding` 0.1.6 y `encina-firefox-native` 0.2.0 instalados:

```
$ check-language-support -l es
                                    # vacío: no falta nada

$ check-language-support -l es --show-installed
fonts-noto-core gnome-user-docs-es hunspell-es language-pack-es
language-pack-gnome-es poppler-data wspanish
                                    # los siete, instalados
```

Locale (`es_ES.UTF-8` en las 13 categorías), teclado (`XKBLAYOUT="es"`,
`input-sources = [('xkb', 'es')]`), diccionarios (`hunspell-es` con `es_ES.dic`
y las 21 variantes americanas), fuentes y zona horaria: correctos sin tocar nada.

**El motivo es que Ubuntu ya hace exactamente lo que A3 proponía hacer**, con el
mismo comando. En `/var/log/installer/subiquity-server-debug.log`:

```
19:20:02 start: .../postinstall/get_target_packages: calculating extra packages
19:20:02 arun_command called: ['chroot', '/target', 'check-language-support', '-l', 'es_ES']
19:20:03 start: .../postinstall/install_hunspell-es: installing hunspell-es
19:20:08 start: .../postinstall/install_wspanish: installing wspanish
```

Y en `/usr/share/language-selector/data/pkg_depends`, la **única** regla
específica de español en 184 líneas es `wa:es::wspanish`. El resto son genéricas
o condicionadas a que otro paquete esté instalado (`language_support_pkgs.py:80`).

**El residuo, que pasa a A4.** Lo único que Ubuntu no cubre es que las
aplicaciones instaladas *después* del sistema no reciben su l10n español: no hay
hook de apt, ni disparador de dpkg, ni aviso de `update-notifier` que reejecute
la comprobación. Verificado con `apt-get -s install libreoffice-writer`, que no
arrastra `libreoffice-l10n-es` ni `hyphen-es` ni `mythes-es`. Son tres líneas en
el `debian/control` de `encina-meta`, no un paquete:

```
Depends: ..., hunspell-es, language-pack-es, language-pack-gnome-es
Recommends: ..., libreoffice-l10n-es, hyphen-es, mythes-es, thunderbird-locale-es
```

`libreoffice-l10n-es` depende de `libreoffice-common`, así que va en `Depends:`
solo si Encina incluye LibreOffice de serie; si no, en `Recommends:`.

**Y además chocaba con R5.** `/etc/default/keyboard`, `/etc/locale.gen` y
`/etc/default/locale` **no son conffiles de nadie**: los genera debconf
(`keyboard-configuration`, `locales`). Escribirlos desde un paquete es el patrón
que R5 prohíbe, sin la salida airosa que `os-release` tiene con `dpkg-divert`.

**Lo que NO se midió, y no se da por bueno:** que una instalación *completa* (no
`ubuntu-desktop-minimal`) en español reciba `libreoffice-l10n-es`; y que el
instalador interactivo se comporte como el `autoinstall` que se usó aquí. Ambas
requerirían una VM virgen. Si alguna vez se comprueba y sale un hueco real, es
el único motivo nuevo que reabriría esta discusión.

---

### 4.46 LA MISMA TRAMPA DE §4.37, OTRA VEZ: la huella de 0.1.13 era del árbol de trabajo, y la CI la cazó (2026-08-15)

**La CI llevaba cinco ejecuciones en rojo** —desde `932bc5c`, que es donde entró
0.1.12— y **solo fallaba `encina-branding`**: `encina-firefox-native` y
`encina-meta` pasaban. El paso que fallaba era la medición de §4.38, no el
control, que decía `[OK]` antes.

```
[HALLAZGO] encina-branding_0.1.13_all.deb NO es el del manifiesto
        manifiesto  bf821ee664ef332b9d5445eddd8dc2f1c9bfb3e00a360c6ec34c119e838578b4  6943792 bytes
        construido  4df508cd1dc9da51252dbc61d6588e17ddefa55ea7756dc1d9d044e4e1377635  6943670 bytes
```

**122 bytes de diferencia, y el contenido era el mismo.** Bajado el artefacto
del runner y desglosado contra el `.deb` arm64 que había en `debian-packages/`:

| miembro | arm64 (= manifiesto) | amd64 (runner) |
|---|---|---|
| `debian-binary` | `d526eb4e878a23ef` | igual |
| `control.tar.zst` | `a4b7ad35aa0dabb1` | igual |
| `control.tar` | `f9cf4833445a4e60` | igual |
| `data.tar.zst` | `45347c810e87b43a`, 6 940 891 b | `4310bd3ee1426e73`, 6 940 769 b |
| `data.tar` | `17a4f9256526120f`, 7 055 360 b | `ad427db8c49a9792`, **7 055 360 b** |

`control.tar` **idéntico** significa que `md5sums` es idéntico, y `md5sums` es la
huella de los 23 ficheros: el contenido no podía cambiar. Confirmado por partida
doble —`md5sums` extraído da `62264aef40f2bf61` en los dos, y un `diff -r` de los
dos `data.tar` extraídos sale limpio—. `data.tar` con **el mismo tamaño** y otra
huella solo deja una posibilidad: metadatos.

**Y eran las fechas, que es exactamente §4.37:**

```
amd64 (runner):   52 entradas, UNA sola fecha:  2026-08-15 00:28:22 UTC
arm64 (manifiesto): 22 fechas distintas: Aug 6 18:48, Aug 8 00:45, Aug 12 00:37,
                    Aug 14 09:42, Aug 14 13:49, Aug 14 23:10, Aug 15 00:23...
```

`00:28:22 UTC` es el `SOURCE_DATE_EPOCH` que impone el changelog. `dpkg-deb`
**recorta los mtimes posteriores y deja pasar los anteriores**: en el runner todo
viene de un `checkout` recién hecho —todo posterior, todo recortado—; en
`encina-dev` se construyó sobre el árbol de trabajo, cuyos ficheros son de hace
días, más antiguos, y se colaron dentro del `.deb`.

**El que no era reproducible era el del manifiesto, no el del runner.** Y no es
opinión: reconstruido en `encina-dev` desde `git archive HEAD` sobre un
directorio nuevo,

```
4df508cd1dc9da51252dbc61d6588e17ddefa55ea7756dc1d9d044e4e1377635  6943670 bytes
fechas distintas en data.tar: 1  (2026-08-15 02:28 = SOURCE_DATE_EPOCH)
```

**la misma huella que el runner amd64, byte a byte, y los cinco miembros
también.** Con las mismas versiones de herramientas en las dos máquinas —dpkg
1.22.6ubuntu6.6, libzstd1 1.5.5+dfsg2-2build1.1, tar 1.35+dfsg-3ubuntu0.4—, así
que nada más podía explicarlo. **§4.38 sigue en pie: la reproducibilidad entre
arquitecturas es real.** Lo que no es reproducible es el árbol de trabajo.

**Corregido en los dos sitios donde vivía la huella**, con su control por
delante en las dos máquinas (manifiesto saboteado → `[HALLAZGO]`; manifiesto
bueno → `[OK]`):

| Sitio | Estado |
|---|---|
| `imagen/repo-manifiesto.tsv` línea 32 | corregido y verificado en arm64 y en el Mac |
| `imagen/encina-seed.sh` `H_BRANDING` | corregido, con la enmienda fechada al lado del aviso de §4.37 |

**Lo que queda abierto, y no se da por hecho:** `imagen/autoinstall.yaml` y
`imagen/autoinstall-unattended.yaml` llevan `encina-seed.sh` **empotrado en
base64**, así que los dos siguen con `H_BRANDING=bf821ee6…` dentro. Medido
decodificando el base64: los 29 563 bytes empotrados coinciden con
`HEAD:encina-seed.sh` —el control— y **no** con el corregido. Rehacerlos es
`fabricar-seed.sh --actualizar-yaml`, que exige `--repo` con los 28 `.deb` y su
`Packages`; no se tocan a mano. **No bloquea la CI**, que solo lee el manifiesto.

**Lo que esto enseña, y no es la huella:** el aviso de §4.37 estaba escrito
dentro de `encina-seed.sh` desde el 2026-08-13 y aun así volvió a pasar dos
veces seguidas —0.1.12 y 0.1.13—. Un aviso en un comentario no es una barrera.
La barrera fue la CI, que lo cazó a la primera; el aviso no lo evitó.

---

### 4.47 LA PREGUNTA DE LOS ICONOS DEL DOCK ERA DOS PREGUNTAS, y una de las dos no tiene por dónde (2026-08-15)

**Lo que la casilla preguntaba antes de tocar nada:** sustituir el icono de una
aplicación ajena desde el tema `Encina`, **¿es declarar lo nuestro o pisar lo
suyo?** La medición dice que **los dos iconos del dock que siguen diciendo
Ubuntu no son el mismo caso**, y que a uno de ellos la pregunta ni le llega:

| | Qué declara su `.desktop` | ¿Puede un tema? |
|---|---|---|
| El **«?»** de la Ayuda (`yelp`) | un **NOMBRE**: `org.gnome.Yelp` | **Sí**, y es lo que un tema hace |
| La **«A»** naranja del Centro de aplicaciones (`snap-store`) | una **RUTA ABSOLUTA** dentro del snap | **No. Ninguno** |

**Dónde se midió, y por qué ahí:** `encina-dev`, por `ssh`, que es el banco
barato — tiene `snap-store`, `yelp`, las veinte variantes de Yaru, `encina-branding`
0.1.13 puesto y `gir1.2-gtk-4.0`. **No se gastó la máquina del producto**, y el
único fleco que parecía exigirla se cerró aquí mismo (apartado e).

#### (a) DE QUÉ TIPO ES EL ICONO QUE DECLARA CADA `.desktop`

`ThemedIcon` es un nombre y el tema decide el fichero; `FileIcon` es una ruta y
**el tema no interviene**. El control va delante: un `.desktop` inventado tiene
que dar `None`, y en la lista tienen que salir **los dos** tipos —si sólo sale
uno, el lector no distingue y la medición no vale—.

```
firefox_firefox.desktop          -> FileIcon    /snap/firefox/current/default256.png
                                    duenno: DENTRO DEL SNAP (squashfs de solo lectura)
org.gnome.Nautilus.desktop       -> ThemedIcon  org.gnome.Nautilus
snap-store_snap-store.desktop    -> FileIcon    /snap/snap-store/current/bin/data/flutter_assets/assets/app-center.png
                                    duenno: DENTRO DEL SNAP (squashfs de solo lectura)
yelp.desktop                     -> ThemedIcon  org.gnome.Yelp
org.gnome.Settings.desktop       -> ThemedIcon  org.gnome.Settings
no-existe-jamas.desktop          -> None   <- CONTROL
tipos distintos vistos: ['File', 'Themed']    <- el lector distingue
```

**Y la trampa del entorno mordió a la primera:** sin `XDG_DATA_DIRS`, `Gio` no
encuentra **ningún** `.desktop` de snap y el guion murió en la primera línea.
Una sesión `ssh` no es una sesión de escritorio, otra vez.

#### (b) EL CONTROL DECISIVO: la misma función, los dos tipos, dos temas

`lookup_by_gicon` a 48 px —el tamaño del dock, `dash-max-icon-size 48`—:

```
el Centro de aplicaciones — FileIcon (RUTA)
  tema=Encina     /snap/snap-store/current/bin/data/flutter_assets/assets/app-center.png
  tema=Yaru-sage  /snap/snap-store/current/bin/data/flutter_assets/assets/app-center.png
  ¿cambia con el tema?  NO
```

**Y un defecto de esta comprobación mía, que se dice en vez de callarse:** en la
misma tabla, `yelp` y `nautilus` también dieron «NO», y eso **no prueba lo
contrario de lo que parece**. Dan «NO» porque ni `Encina` ni `Yaru-sage`
declaran esos nombres y los dos caen al mismo padre. Esa fila **no separa los
dos casos**; los separa (c), donde un tema que **sí** declara el nombre lo
cambia. Una comprobación que no puede dar sus dos respuestas no es una
comprobación, y aquí estaba dentro de la tabla buena.

#### (c) UN TEMA HIJO QUE DECLARA UN ICONO DE APLICACIÓN, a 48 px

No era evidente y por eso se midió: el `index.theme` de `Encina` sólo declara
`scalable/actions`, y para servir el icono de una aplicación hace falta un
directorio de `apps` — **y que un SVG propio gane a un PNG de `48x48` del
padre**. Tema efímero `EncinaPrueba` (`Inherits=Yaru-sage,Yaru,hicolor`), que se
borró solo con su comprobación:

```
org.gnome.Yelp                 /tmp/…/EncinaPrueba/scalable/apps/org.gnome.Yelp.svg   <- GANA EL NUESTRO
                               /usr/share/icons/Yaru/48x48/apps/org.gnome.Yelp.png       (tema=Yaru-sage)
org.gnome.Nautilus             /usr/share/icons/Yaru-sage/48x48/apps/org.gnome.Nautilus.png  <- del padre, intacto
firefox                        /usr/share/icons/hicolor/48x48/apps/firefox.png              <- del padre, intacto
folder                         /usr/share/icons/Yaru-sage/48x48/places/folder.png           <- del padre, intacto
view-app-grid-ubuntu-symbolic  /usr/share/icons/Yaru/scalable/actions/…                     <- del padre, intacto
el instrumento se borro solo: quedan 0 directorios
```

**La última fila es un control que salió gratis:** `EncinaPrueba` no declara la
rejilla y por eso sale de Yaru. **Y de paso cierra un hueco de §4.43h**, que
dejaba escrito que todo se había preguntado a 16 px y el dock usa 48: con el
tema `Encina` de verdad, a **48 px**, `view-app-grid-ubuntu-symbolic` sigue
resolviendo al fichero de Encina y `Yaru-sage` sigue dando otro.

#### (d) EL PRECEDENTE, que es lo que convierte la pregunta en dato y no en opinión

¿Sustituir el icono de una aplicación ajena desde un tema es una transgresión?
**Lo hace el propio Ubuntu, 62 veces de 71.** Se recorrieron los `.desktop` de
`/usr/share/applications` que declaran su icono por nombre, y se contó a cuántos
les sirve el fichero `Yaru` siendo el `.desktop` **de otro paquete**:

```
.desktop con icono por NOMBRE examinados:                                    71
de esos, cuyo icono lo sirve Yaru siendo el .desktop de OTRO paquete:        62
  org.gnome.Nautilus     .desktop de nautilus              icono de yaru-theme-icon
  org.gnome.Evince       .desktop de evince                icono de yaru-theme-icon
  org.gnome.Calculator   .desktop de gnome-calculator      icono de yaru-theme-icon
  org.gnome.Settings     .desktop de gnome-control-center  icono de yaru-theme-icon
  … (58 más)
CONTROL, un nombre que Yaru no tiene: None
```

**O sea que servir un nombre desde tu propio tema no es pisar: es el mecanismo.**
Pisar es sobrescribir el fichero de otro paquete, que es lo que R5 prohíbe y lo
que el tema `Encina` evita por construcción (§4.43e: `dpkg -V` mudo, y el fichero
de `yaru-theme-icon` intacto).

#### (e) LA «A» NARANJA: por qué no hay vía, y el fleco de la revisión, cerrado aquí

La ruta no la inventa `snapd` al generar el `.desktop`: **la escribe el propio
snap** en su `meta/gui`, y es **idéntica en la revisión 1271 —la que lleva la
máquina del producto— y en la 1391**, que es la que hay aquí:

```
rev 1271  Icon=${SNAP}/bin/data/flutter_assets/assets/app-center.png
rev 1391  Icon=${SNAP}/bin/data/flutter_assets/assets/app-center.png
-rw-r--r-- root root 26390 mar 31  2025  /snap/snap-store/1271/…/app-center.png
-rw-r--r-- root root 26390 ago  7 23:05  /snap/snap-store/1391/…/app-center.png
CONTROL: el mismo ls sobre una ruta inventada -> No existe el archivo o el directorio
```

**Por eso este fleco no costó la máquina del producto:** su revisión estaba
montada aquí. Y el fichero no se puede tocar ni queriendo, con su control:

```
/snap/snap-store/current -> 1391          <- y la maquina llego a este banco con la 1271
touch dentro del snap:  Sistema de archivos de solo lectura
CONTROL: el mismo touch en /tmp si se pudo
```

**El `current` es un objetivo móvil:** aquí mismo saltó de 1271 a 1391 el
2026-08-14 por autorrefresco, con las dos revisiones montadas a la vez.

#### (f) LA ÚNICA VÍA QUE SÍ EXISTE PARA LA «A», medida sin tocar el sistema

Sombrear el `.desktop` en `/usr/share/applications`, que es **exactamente lo que
`encina-firefox-native` ya hace** con `firefox_firefox.desktop` (§4.19). Medido
sobre un árbol sintético en `/tmp`, dos directorios con el mismo id dentro:

```
CONTROL, con snapd DELANTE (tiene que ganar el suyo):
   gana:  /tmp/xdgs/snapd/applications/snap-store_snap-store.desktop
   Icon=: /ruta/del/snap.png
Y con el orden de la sesion real, /usr/share antes que snapd:
   gana:  /tmp/xdgs/propio/applications/snap-store_snap-store.desktop
   Icon=: ICONO-DE-ENCINA
```

**Y su precio, dicho entero:** el `.desktop` del App Center trae **55
traducciones** de `Name=` y las acciones del snap; una sombra las **congela**, y
el día que Canonical las cambie nuestra copia no se entera. Es el mismo precio
que ya se paga con Firefox, donde la sombra son cinco líneas y aquí serían
sesenta.

#### (g) LO QUE HAY DETRÁS DEL «?», que decide si repintarlo compra algo

El «?» abre `yelp`, y lo que `yelp` enseña **no es la ayuda de GNOME**:

```
/usr/share/help/es/gnome-help/index.page   <title>Guía del escritorio de Ubuntu</title>
dpkg -S de ese fichero                      ubuntu-docs
    CONTROL: dpkg -S de una pagina inventada -> no se ha encontrado ningun paquete
ubuntu-docs 24.04.2 «Ubuntu Desktop Guide», y yelp es Depends de ubuntu-desktop-minimal
```

**O sea que el icono es lo de menos:** repintar el «?» deja un icono de Encina
que abre un documento titulado «Guía del escritorio de Ubuntu». No es un
argumento para no hacerlo, pero sí para no contarlo como que el «?» ya no dice
Ubuntu.

#### (h) Lo que esta medición NO contesta

- **No se ha visto ninguna pantalla.** Todo es resolución de iconos y lectura de
  ficheros; que el shell **pinte** lo que el resolvedor dice sigue siendo
  `[OJOS]`, y §4.43f es el recordatorio de que esas dos cosas se separaron una
  vez.
- **No se ha probado la sombra del `.desktop` en una máquina**, sólo en un árbol
  sintético en `/tmp`. Lo que está medido de verdad en producción es la de
  Firefox (§4.19), que es la misma forma con otro id.
- **No se ha medido en la máquina del producto.** Lo que se midió aquí y vale
  allí está atado por revisión (e) o por fichero del repositorio; el resto, no.
- **El Firefox del producto no es este.** Aquí es el Snap —`FileIcon`, o sea
  tampoco sustituible por tema—; en el producto es el nativo con la sombra de
  `encina-firefox-native`, que declara `Icon=firefox`, un **nombre**. No se toca:
  es la marca de Mozilla y el usuario la espera.

---

### 4.48 LA VUELTA DE `encina-branding` 0.1.14: D21 dentro, dos ajustes de GDM fuera, y el ritual de los seis sitios pagado entero (2026-08-15)

**ENMIENDA DEL MISMO DÍA, y hay que leerla antes que nada de lo que sigue:
0.1.14 duró tres cuartos de hora.** Su icono **no se pintaba** —en el dock había
un hueco— y la vuelta hubo que darla otra vez con **0.1.15** (`6d9fcd64…`). Todo
lo que esta sección mide sigue siendo verdad; lo que no es verdad es la
conclusión de que con eso bastaba. **La causa y las cinco comprobaciones que
pasaron sin ver el fallo están en §4.49**, y la huella buena es la de allí.

**Una vuelta y no cinco, que era el argumento de `tareas/aspecto/LEEME.md`:** el
precio de tocar este paquete no es el `.deb`, es el ritual —y esta vez se pagó
entero, incluidos los dos `autoinstall*.yaml` que llevaban la huella vieja desde
§4.46.

**Lo que entró, cinco cosas:** la sombra del `.desktop` del Centro de
aplicaciones con su icono propio (`D21`), los dos ajustes de GDM medidos como
no-op —fuera—, el comentario del logotipo que apuntaba a un directorio que ya no
existe, y el cotejo del icono nuevo en `design/generar.sh`.

#### (a) LAS DOS DECISIONES QUE HABÍA QUE TOMAR ANTES DE ESCRIBIR UNA LÍNEA

**La primera se cayó al mirarla, y ese es el dato:** la casilla decía que
dibujar el icono *«depende de que la paleta pase de PROPUESTO a VIGENTE»*. No
depende. Un icono usa `acento` `#3A664E`, `acento-profundo` `#2F4033`, `arcilla`
`#D6BFA0` y `tierra` `#A78B75`, **los cuatro VIGENTE**; lo que está en
PROPUESTO son `papel`, los dos de texto y los seis semánticos, que son colores
de **mensajes de estado** —«la firma salió», «el certificado caduca»— y no
intervienen en un dibujo. La dependencia estaba escrita, no medida.

**La segunda tenía un control que ya estaba en la casilla sin que nadie lo
nombrara.** Los dos ajustes de GDM se quitan, y lo que lo decide es que `logo`
vive en la **misma sección** `[org/gnome/login-screen]` del **mismo fichero** y
**sí funciona** —el logotipo se lee en `design/capturas/antes/03-gdm.png`—. Eso
descarta la fontanería entera: el perfil de dconf se lee, la base se compila y
`dconf update` corre. **Lo que sigue sin medirse es POR QUÉ no hacen nada**, ni
el fondo ni el rótulo, y se dice al lado en vez de callarse: se quitan porque no
producen efecto, no porque se sepa la causa.

#### (b) EL ICONO: tres tandas, y el motivo del descarte no se deduce del resultado

Las tres primeras variantes ponían la copa de la encina dentro de una bolsa de
asa estrecha y alta. **A 48 px —el tamaño del dock, `dash-max-icon-size 48`— las
tres se leen como un CANDADO.** No es una impresión: es lo que se ve en
`design/iconos-borrador/lamina.png`, y por eso ese directorio se versiona. El
asa se ensanchó y se bajó, el contenido pasó a ser una rejilla de cuatro
aplicaciones, y **la bellota no se usa a propósito**: es la del botón de la
rejilla y los dos iconos viven en el mismo dock.

**Y una corrección de `[OJOS]` que no habría salido de ningún guion:** en el
primer J la fila de abajo tocaba la base de la bolsa. Se subió el bloque y se
probaron dos tamaños; entró el de 7.4.

**El icono va en `hicolor/scalable/apps`, no en el tema `Encina`**, y el motivo
corrige por dónde se iba a atacar: §4.47(c) midió que para **ganarle** a un
icono del padre hace falta declararlo en el tema con su directorio de `apps`,
pero aquí **no hay a quién ganarle** —el nombre `encina-centro-aplicaciones` no
lo declara ningún otro tema—. `hicolor` es el último de la cadena y por eso
mismo el respaldo de **todos** los temas: el icono sobrevive a que alguien
cambie el tema de iconos, y no hay que tocar el `index.theme`.

#### (c) LA MEDICIÓN QUE IMPORTA, con su control tomado ANTES de instalar

En `encina-dev`, mismo lector para las dos pasadas, con `XDG_DATA_DIRS` de una
sesión de escritorio —sin él `Gio` no encuentra **ningún** `.desktop` de snap—:

```
CON 0.1.13 (control negativo, tomado antes de instalar):
snap-store_snap-store.desktop  -> File    /snap/snap-store/current/bin/data/flutter_assets/assets/app-center.png
                                  fichero: /var/lib/snapd/desktop/applications/snap-store_snap-store.desktop
  tema=Encina     -> /snap/snap-store/current/.../app-center.png
  tema=Yaru-sage  -> /snap/snap-store/current/.../app-center.png

CON 0.1.14:
snap-store_snap-store.desktop  -> Themed  encina-centro-aplicaciones,encina-centro-aplicaciones-symbolic
                                  fichero: /usr/share/applications/snap-store_snap-store.desktop
                                  Name=  : Centro de aplicaciones
  tema=Encina     -> /usr/share/icons/hicolor/scalable/apps/encina-centro-aplicaciones.svg
  tema=Yaru-sage  -> /usr/share/icons/hicolor/scalable/apps/encina-centro-aplicaciones.svg   <- hicolor es el respaldo de los DOS

CONTROLES, en la misma pasada:
firefox_firefox.desktop        -> File    /snap/firefox/current/default256.png   <- sigue habiendo un FileIcon
org.gnome.Nautilus.desktop     -> Themed  ... -> /usr/share/icons/Yaru-sage/48x48/apps/org.gnome.Nautilus.png  <- del padre, intacto
yelp.desktop                   -> Themed  ... -> /usr/share/icons/Yaru/48x48/apps/org.gnome.Yelp.png           <- del padre, intacto
no-existe-jamas.desktop        -> None                                                       <- CONTROL
tipos distintos vistos: ['File', 'Themed']
```

**Dos defectos del instrumento, dichos porque cuestan mediciones:**
*(1)* `Gio.DesktopAppInfo.new` **no devuelve `None`** cuando el id no existe:
**lanza `TypeError`**, así que el control murió dentro del propio control y se
llevó por delante la mitad de la pasada. *(2)* Al instalar 0.1.14 la lista se
quedó con **un solo tipo** —ya no había ningún `FileIcon`—, con lo que el lector
dejaba de demostrar que sabe distinguirlos: se añadió `firefox_firefox.desktop`,
que en `encina-dev` es el Snap, para que la medición vuelva a valerse sola.

#### (d) EL PAQUETE, 59 comprobaciones y 0 fallos

`03-construir.sh` 35 · `04-instalar.sh` 10 · `05-verificar.sh` 14 —usuario nuevo,
cinco reinstalaciones, purga y reinstalación—, todas sobre el árbol de
`git archive HEAD`. Las dos comprobaciones que faltaban y se añadieron: que el
`.deb` incluya **la sombra y el icono**, que son las dos mitades de `D21` y
**ninguna de las dos se nota hasta mirar el dock** —una sombra sin icono deja un
lanzador con el icono roto; un icono sin sombra no lo pide nadie—.

**Lo que sigue siendo `[OJOS]` y no se cuenta como aprobado:** que GNOME Shell
**pinte** ese icono en el dock. Todo lo de arriba es resolución de iconos y
lectura de ficheros, que es lo mismo que avisaba §4.47(h) y lo que §4.43f dejó
como recordatorio de la vez que esas dos cosas se separaron.

#### (e) LA HUELLA, POR FIN SACADA COMO MANDA §4.46 — y sus dos controles

```
encina-branding_0.1.14_all.deb
  131c464e4eba2ad472b5a85b0dc79181ff101761873e55737bd870078f9a7afd   6 947 742 bytes
  fechas distintas dentro de data.tar: 1   (2026-08-15)
  dos pasadas, desde DOS commits distintos (f1d12b5 y 6e6621e): la misma huella
```

**Una sola fecha dentro** es el control de que salió de `git archive HEAD` y no
del árbol de trabajo —con 22 fechas distintas fue como mordió §4.46—. Y la
segunda pasada demuestra de paso que tocar `scripts/` no cambia el `.deb`.

#### (f) LOS SEIS SITIOS, y la lista de `SCRIPTS.md` acertó en los seis

| Sitio | Qué llevaba |
|---|---|
| `imagen/repo-manifiesto.tsv` | versión, fichero, tamaño y `sha256` |
| `imagen/encina-seed.sh` | `H_BRANDING` **y** el nombre del `.deb`, que lleva la versión dentro |
| `imagen/fabricar-seed.sh` | el nombre en el array `FICHEROS` |
| `imagen/fabricar-iso.sh` | el mismo array, duplicado del anterior |
| `imagen/autoinstall.yaml` | el seed empotrado en base64 |
| `imagen/autoinstall-unattended.yaml` | ídem |

**Y rehacer los dos YAML costó más que ejecutar una orden**, porque
`fabricar-seed.sh --actualizar-yaml` exige un `--repo` con los 28 `.deb` y su
`Packages`. Los bytes salieron de la ISO de E4 —`tar -xf` sobre el `.iso`, 168
MB, que es mucho menos de lo que parecía— y **la lista siguió saliendo del
manifiesto, no del medio**, que es lo único que cerraría la circularidad. El
cotejo dio esto, y el control no hubo que inventarlo:

```
26 de 28 cuadran. Los 2 que no:
  encina-firefox-native_0.2.1_all.deb   real 972ec932…  (esperada 640f508e…)
  encina-meta_0.2.1_all.deb             real 86da3cc9…  (esperada 204081f0…)
sobra en el repo: encina-branding_0.1.8_all.deb
```

**Esas dos huellas son las de §4.37**, citadas por su nombre en el comentario de
`encina-seed.sh` como «las anteriores»: la ISO de E4 lleva dentro los `.deb`
construidos sobre un árbol de trabajo, **fosilizados**. Reconstruidos desde el
clon en `encina-dev` dan **exactamente** `640f508e…` y `204081f0…`, las del
manifiesto. Con los tres propios al día: **28 de 28 y ninguno sobrando**, y el
`Packages` regenerado con `dpkg-scanpackages` en la VM —no existe en macOS—.

**El fleco de §4.46, cerrado y comprobado por dentro**, que era el que dejaba el
ritual a medias:

```
encina-seed.sh en disco: 31070 bytes
autoinstall.yaml            31070 bytes empotrados, identicos al de disco
                            H_BRANDING=131c464e dentro; ninguna vieja; .deb 0.1.14
autoinstall-unattended.yaml igual
CONTROL: un guion con la huella cambiada, comparado con el de disco -> distinto
```

#### (g) LO QUE ESTA VUELTA NO HACE

- **No refabrica la ISO.** Cambiar los `.deb` cambia su huella, y `95758c9e…`
  deja de ser la que produce este repositorio en cuanto se rehaga. Está avisado
  en `tareas/aspecto/5-cierre.md` y no se toca aquí.
- **No marca la casilla de los iconos.** Su condición no es que el paquete lleve
  la sombra dentro: es que **el icono esté dibujado y visto en pantalla**, y lo
  segundo no está.
- **No mide por qué los dos ajustes de GDM no hacían nada.** Se quitan medidos,
  no explicados.

---


### 4.49 EL ICONO DE 0.1.14 NO SE PINTABA: gdk-pixbuf sólo husmea 256 bytes, y el comentario de cabecera empujaba el `<svg>` al 2090 (2026-08-15)

**Lo cazó un `[OJOS]`, y ninguna de las cuatro comprobaciones que lo dieron por
bueno.** Jorge miró el dock de `encina-dev` con 0.1.14 puesto y dijo: *«No
aparece el icono. Hay un hueco donde debería estar»*. **Y era literal: un
hueco** — la entrada ocupaba su sitio entre Archivos y el «?», que es
exactamente su posición en `favorite-apps`, y no dibujaba nada.

**Lo que hace grave este fallo no es el fallo: es que §4.48 estaba en verde.**

| Lo que se midió en §4.48 | Contestaba |
|---|---|
| ¿Qué `.desktop` gana? | el nuestro, `/usr/share/applications/…` |
| ¿De qué tipo es el icono? | `ThemedIcon encina-centro-aplicaciones` |
| ¿A qué fichero resuelve, a 48 px, con dos temas? | a nuestro SVG, con `Encina` y con `Yaru-sage` |
| ¿Se muestra la entrada? (añadido al mirar el fallo) | `should_show() == True`, `NoDisplay=False` |
| ¿Lo dibuja librsvg? | sí, `rsvg-convert` saca el PNG |

**Las cinco eran verdad y el icono no se veía.** Faltaba una pregunta que no es
ninguna de ésas: **¿puede `gdk-pixbuf` cargar el fichero?** Porque resolver un
nombre a un fichero **no es lo mismo que poder pintarlo**, y quien pinta en el
dock es GNOME Shell a través de `gdk-pixbuf`, no `librsvg` a secas.

#### (a) LA PISTA ESTABA EN EL REGISTRO, Y YO LA HABÍA DESCARTADO

```
ago 15 12:44:58 encina-dev gnome-shell[99227]: Could not load a pixbuf from icon theme.
   This may indicate that pixbuf loaders or the mime database could not be found.
```

**Y antes de encontrarla ya había tenido la respuesta delante y la tiré**: una
prueba con `GdkPixbuf.new_from_file_at_size` falló para nuestro SVG **y también
para `encina-logo.svg`**, y **decidí que el instrumento estaba roto porque
fallaban los dos**. Era justo al revés: el control decía la verdad —los dos
están rotos— y yo leí «los dos fallan, luego el lector no vale». *Un control que
sale rojo dos veces no es un control averiado: puede ser un hallazgo doble.*

#### (b) LA MEDICIÓN QUE SEPARA LOS CASOS, con su control dentro

```
formatos que conoce gdk-pixbuf: [... 'svg' ...]      <- el cargador ESTA
[FALLO] encina-centro-aplicaciones.svg   Couldn't recognize the image file format
[FALLO] encina-logo.svg                  Couldn't recognize the image file format
[OK]    view-app-grid-ubuntu-symbolic.svg  48x48     <- CONTROL: otro SVG nuestro que SI carga
[OK]    org.gnome.Nautilus.png             48x48     <- CONTROL: el lector funciona
```

La bellota es SVG y carga; los dos de `hicolor` no. **Lo único en que se
diferencian es dónde empieza el `<svg>`**, porque los dos llevan delante el
comentario largo que en este proyecto es método y no adorno.

#### (c) LA CAUSA, y el umbral exacto por búsqueda binaria

`gdk-pixbuf` reconoce el formato **husmeando el principio del fichero**. Si el
`<svg` no cae dentro de los primeros bytes, no reconoce nada:

```
'<svg' en el byte   256 -> CARGA
'<svg' en el byte   257 -> NO RECONOCE
```

**Doscientos cincuenta y seis bytes.** Y con el control **en las dos
direcciones**, que es lo que lo convierte en causa y no en correlación:

```
nuestro, tal cual                   -> NO RECONOCE   '<svg' en el byte 2090
nuestro, sin el comentario          -> CARGA         '<svg' en el byte   39
nuestro, comentario DENTRO de <svg> -> CARGA         '<svg' en el byte   39
la bellota, tal cual                -> CARGA         '<svg' en el byte    0
la bellota + comentario delante     -> NO RECONOCE   '<svg' en el byte 1510
```

**Quitarle el comentario al roto lo arregla, y ponérselo al sano lo rompe.**

#### (d) Y NO ERA SOLO EL ICONO NUEVO: `encina-logo.svg` lleva así desde 0.1.9

Con el `<svg>` en el byte **799** —medido también en el `.deb` anterior, así que
no lo introdujo la vuelta de hoy—. **Seis versiones con el defecto dentro**, y
nadie lo notó porque ese icono no se pinta en el dock. Barrido de los SVG del
árbol: **dos rotos de cuatro**, los dos de `hicolor`, y los dos del tema `Encina`
bien porque empiezan por `<svg`.

#### (e) EL ARREGLO, y lo que se comprueba a partir de ahora

Los comentarios pasan **dentro** del `<svg>`, con el porqué escrito en los
propios ficheros. **El dibujo no cambia**, y eso se comprueba en vez de
suponerse: `rsvg-convert` saca el **mismo PNG byte a byte** antes y después de
mover el comentario.

`design/generar.sh` mide ahora **la causa y no el síntoma** —la posición del
`<svg>`, no si `gdk-pixbuf` carga—, porque en el Mac no hay `gdk-pixbuf` y el
síntoma solo se ve en una pantalla. Con su rojo probado: un maestro con el
comentario fuera da `[FALLO] '<svg' en el byte 2087, y el límite es 256`.

Y con 0.1.15 instalada, la pregunta que faltaba ya contesta que sí:

```
[OK]    encina-centro-aplicaciones.svg     48x48
[OK]    encina-logo.svg                    48x48
[OK]    view-app-grid-ubuntu-symbolic.svg  48x48
[OK]    org.gnome.Nautilus.png             48x48
```

#### (e bis) Y EL `[OJOS]`, DADO: el icono se ve

**2026-08-15, `encina-dev` con 0.1.15 puesto y sesión reiniciada.** En el dock,
donde estaba la «A» naranja del Centro de aplicaciones, está la bolsa verde —
entre Archivos y el «?», que es su posición en `favorite-apps`. **Lo vio Jorge; el
agente no ha visto ninguna pantalla en todo esto.** La captura está guardada:
`design/capturas/despues/07-icono-tienda-aplicaciones.png`. Con eso la casilla de los
iconos de `tareas/aspecto/3-tema-e-iconos.md` queda marcada, y es la primera vez
en el bloque que se cumple entera: *dibujado* **y** *visto*.

*Dónde se vio, que hay que decirlo:* en el **banco**, no en la máquina del
producto —`encina-95758c9e` sigue con 0.1.13—. Lo que esto demuestra es que el
paquete pinta el icono en un GNOME 46 con el snap presente, que es el caso.

#### (f) EL PRECIO, sin maquillar

**0.1.14 duró tres cuartos de hora.** El ritual de los seis sitios se pagó dos
veces el mismo día —huella `131c464e…` y luego `6d9fcd64…`—, y esta vez el
argumento de «una vuelta y no cinco» no protegía de nada: **el defecto no estaba
en la lista de lo que había que hacer, sino en cómo estaba escrito un fichero
que llevaba seis versiones igual**.

**Lo que esto enseña, y es lo caro:** las cinco comprobaciones de §4.48 eran
correctas y ninguna medía lo que el usuario ve. La cadena tiene un eslabón más
de los que se habían mirado —*existe → gana → resuelve → **carga** → se pinta*—
y sólo el `[OJOS]` cubre el último.

---


## 9. Trampas conocidas

Registro para no redescubrirlas. Todas verificadas en la investigación previa.

| Trampa | Síntoma | Causa |
|---|---|---|
| **Una huella de `.deb` que ninguna otra máquina puede reproducir** | La CI dice `[HALLAZGO] NO es el del manifiesto` con unos cientos de bytes de diferencia, y el contenido es idéntico —`md5sums` byte a byte igual— | Se apuntó la huella de un `.deb` construido **sobre el árbol de trabajo**. `dpkg-deb` recorta los mtimes posteriores a `SOURCE_DATE_EPOCH` y **deja pasar los anteriores**, así que las fechas que los ficheros tenían en ese disco se cuelan dentro del paquete, y ese dato no está en git. **Toda huella que se apunte sale de `git archive HEAD` sobre un directorio nuevo.** Mordió el 2026-08-13 (§4.37) y **otras dos veces** el 2026-08-15, con 0.1.12 y 0.1.13 (§4.46), teniendo el aviso escrito en el propio fichero: lo cazó la CI, no el aviso |
| Tema de Plymouth no aparece | Arranque idéntico tras instalar | El tema va dentro del initramfs; falta `update-initramfs -u` |
| Logotipo propio nunca se ve | Aparece el del fabricante | El tema hereda de `bgrt` en lugar de `spinner` |
| Arranque en negro en disco cifrado | No pide frase LUKS | Falta el callback `SetDisplayPasswordFunction` en el script |
| Fondo no se aplica a usuarios nuevos | Solo funciona para el usuario original | Se usó `/etc/skel` en lugar de `gschema.override` |
| Snap de Firefox reaparece | Vuelve tras `apt full-upgrade` | Falta el anclaje `Pin-Priority` sobre `packages.mozilla.org` |
| Firefox nativo arranca en inglés | Interfaz en en-US | El paquete de idioma es aparte: `firefox-l10n-es-es` |
| **El icono sigue abriendo el Snap** | Todo instalado y correcto, y `about:support` dice `/snap/firefox/...`. Y está en español, así que parece bien | Conviven dos lanzadores con identificadores distintos y Ubuntu ancla el del Snap. Se sombrea el suyo desde `/usr/share/applications` |
| **Desaparece el icono de Firefox** | Se pierde el lanzador al instalar, en una sesión ya abierta | `NoDisplay=true` en la sombra. GNOME Shell retira el icono al instante por inotify pero no relee los favoritos por defecto hasta iniciar sesión (D11). **Acotado el 2026-08-10 (§4.19e): NO es permanente.** Con la sesión viva y el identificador en los favoritos *del usuario*, GNOME Shell **no reescribe** `favorite-apps` en su dconf, así que la lista no se corrompe y el icono vuelve al siguiente inicio de sesión; y la entrada, oculta, sigue abriendo el nativo. Si desaparece de la pantalla o no es `[OJOS]` |
| **Dos «Firefox» idénticos en el buscador** | Dos iconos con el mismo nombre, los dos abriendo `/usr/bin/firefox` | La sombra de `encina-firefox-native` sin `NoDisplay`. **Y no se arregla borrándola:** sin ella, en una máquina con Snap el identificador vuelve a resolver a `/snap/bin/firefox %u` —A2 entero— y con `Hidden=true` pasa a `NINGUNA` y el icono anclado se queda muerto. `NoDisplay` oculta **sin** desactivar (§4.19c) |
| **Una comprobación de «lo dejé como estaba» que certifica que no tocaste nada** | El paso de restaurar dice `[OK]`, la huella coincide, y las cuatro mediciones anteriores eran la misma | Las mutaciones fallaron en silencio —`sudo` pedía contraseña— y nadie comprobó que se aplicaran. Una mutación es un paso que se verifica **antes** de leer su resultado (trampa 13 de `SCRIPTS.md`) |
| **Dos VMs contestan en la misma IP** | `ssh` a `192.168.64.3` responde unas veces una máquina y otras otra | Dos VMs encendidas a la vez. Y el `hostname` no distingue: `encina-E1-meta` se llama `encina-dev` por dentro, y la VM de §4.19 se llama `encina-e2-completa` igual que la vieja. Se identifica por paquetes y testigos, nunca por nombre (trampa 14) |
| **`apt install firefox` se niega** | «se utilizó -y sin --allow-downgrades» | El deb de transición de Ubuntu lleva epoch `1:`, así que la versión real de Mozilla es *menor*. Interactivamente basta responder que sí |
| **El anclaje se comprueba en vacío** | `full-upgrade` ×2 en verde sin mover un paquete | El sistema ya estaba al día. Sin contar los paquetes movidos, la prueba parece más fuerte de lo que fue |
| **El perfil nativo no está donde parece** | Los marcadores «no aparecen» | El deb de Mozilla usa `~/.config/mozilla/firefox/`, no `~/.mozilla/firefox/`, que ni existe. El del Snap está en `~/snap/firefox/common/.mozilla/` |
| **Una comprobación pasa sin comprobar nada** | `[OK]` con la cosa rota, o `[FALLO]` con la cosa bien | Una sesión ssh no tiene `XDG_CURRENT_DESKTOP` ni `XDG_DATA_DIRS`, la salida de apt está traducida, y `comando \| grep -q` con `pipefail` muere de SIGPIPE. Detalle en `SCRIPTS.md` |
| **Firma electrónica falla sin explicación en un navegador de Snap** | Todo instalado, la CA correcta en el perfil, y al pulsar «Firmar» no pasa **nada**: sin diálogo, sin error, sin AutoFirma, sin nada en el journal | **NO es el almacén NSS**, como venía diciendo este documento sin medirlo. El `cert9.db` del Snap es correcto (§4.3). Lo que el confinamiento rompe es que **Firefox no ve `afirma.desktop` ni `/usr/bin/autofirma`**: su `XDG_DATA_DIRS` no incluye `/usr/share` del host, así que `useSystemDefault` no encuentra manejador y no hace nada (§4.4). Ningún `.deb` lo arregla |
| **AutoFirma no arranca al pulsar «Firmar»** | La sede dice «No es posible conectar con Autofirma»; no hay ningún proceso `java` ni nada escuchando en el socket, y **no sale ningún diálogo de «abrir con»** | El `.deb` deja sus preferencias en `/etc/firefox/pref/Autofirma.js`, ruta de los Firefox de Debian/Ubuntu. **La compilación oficial de Mozilla no la lee**: las tres `network.protocol-handler.*.afirma` no existen. El handler del sistema (`xdg-open`) sí funciona: el eslabón roto es solo Firefox (§4.1) |
| **Arreglar el esquema `afirma:` no basta** | Ya arranca AutoFirma y la firma sigue sin ir | Son **dos barreras independientes**. El socket de AutoFirma es TLS (`CN=127.0.0.1` emitido por `CN=Autofirma ROOT`), así que el navegador también tiene que confiar en esa CA, y el Firefox nativo no la tiene. La primera barrera escondía la segunda (§4.1) |
| **AutoFirma configura el navegador equivocado** | Todo instalado y «correcto», y la firma falla | Su configurador encuentra el perfil del **Snap** y no el del Firefox nativo, que está en `~/.config/mozilla/firefox/`. Con el Snap quitado no encuentra **ninguno** y lo dice solo en un log que nadie lee |
| **«Restaurar instalación» de AutoFirma no repara nada** | Responde que ya está todo bien y sale con código 0 | Comprueba que exista un fichero en `/usr/lib/Autofirma`, no que el navegador tenga la CA. El usuario hace justo lo que el error le dice y el sistema le contesta que está sano |
| **Un `.deb` que se instala «con éxito» roto entero** | `install ok installed`, código 0, y nada funciona | `postinst` con `#!/bin/sh` **sin `set -e`** y `exit 0` incondicional. Los mensajes de éxito se imprimen aunque el comando anterior haya fallado. No es exclusivo de AutoFirma: es el patrón que hay que buscar |
| **Añadir el almacén del sistema no sirve para Firefox** | `update-ca-certificates` dice `1 added` y Firefox sigue sin confiar | Firefox no lee `/etc/ssl/certs` aunque `security.enterprise_roots.enabled` esté en `true`. Medido: 167 certificados visibles, ninguno el añadido |
| **El perfil «por defecto» no es el que Firefox abre** | Se mira un perfil, se toca un perfil, y Firefox usa otro | `profiles.ini` marca `Default=1` en uno e `installs.ini` apunta a otro con `Locked=1`. Es el fallo de AutoFirma (§4.2a). Se resuelve por evidencia de uso: `compatibility.ini` presente y `times.json` con `firstUse` no nulo |
| **Un certificado con el nombre correcto y la clave equivocada** | El perfil «tiene» `SocketAutoFirma` y el socket sigue sin validar | Cada reinstalación genera un par nuevo; la CA vieja se queda. Mismo `CN`, mismo apodo, distinta huella (§4.2b). **Se compara por huella SHA-256, nunca por nombre** |
| **El control negativo no es negativo** | `openssl verify` sin almacén de confianza responde `OK` | OpenSSL 3.x tiene un tercer origen, `-CAstore`, activo por defecto, que lee `/etc/ssl/certs` — donde el `postinst` de AutoFirma dejó su CA. Hace falta `-no-CAstore`, o mejor, verificar contra una CA *equivocada*, que falla por el motivo correcto |
| **`grep` de una subcadena que no existe** | Una comprobación de ausencia sale siempre «ausente» | `grep -i afirma` **no** casa con `SocketAutoFirma`: antes de la `F` hay una `o`, así que la subcadena es `oFirma`. Familia de la trampa 3 de `SCRIPTS.md` |
| **`certutil` crea lo que iba a inspeccionar — y también lo que iba a BORRAR** | Un diagnóstico deja bases de datos NSS nuevas por los perfiles… y un **desinstalador** también | **Crean: `-A` (rc=0) y `-D` (rc=255)**. **No crean: `-L` y `-K`**, que fallan con `SEC_ERROR_BAD_DATABASE` y rc=255 sin tocar nada. Los cuatro medidos con sus dos controles en M19(a) de `encina-autofirma`. Una herramienta de diagnóstico solo usa `-L`, y trata ese error como «sin almacén», no como fallo. **Y lo de `-D` es lo traicionero, porque costó un defecto que duró dos versiones (§4.29c): un verbo que BORRA y que además SALE CON ERROR es el último del que se sospecha que cree algo** — sale con 255 y *«could not find certificate named …»* y aun así deja `cert9.db`, `key4.db` y `pkcs11.txt` detrás |
| **La preferencia del navegador ya no existe** | Se pone el fichero en la ruta correcta y sigue sin pasar nada al pulsar «Firmar» | `network.protocol-handler.app.<esquema>` **ha desaparecido** de Firefox (0 apariciones en `libxul` de la 153). Hace falta `expose.<esquema>=false`, que es lo que le dice a Firefox que el esquema no le corresponde. Sin ella `expose-all` vale `true` y el navegador se queda el URI (§4.9a) |
| **«No se han encontrado certificados válidos» con el certificado delante** | `certutil -L` lo ve en el perfil y AutoFirma no | AutoFirma no encuentra las bibliotecas NSS: solo busca en `/usr/lib/x86_64-linux-gnu` y `/usr/lib/i386-linux-gnu`. En arm64 falla con «No se ha podido determinar la localizacion de NSS en UNIX», y el diálogo no menciona NSS por ninguna parte (§4.9c) |
| **La sede se bloquea a sí misma** | Todo correcto en la máquina y la firma no arranca; nada en pantalla | La CSP de la sede no incluye `afirma:` en `frame-src`, y `autoscript.js` invoca el esquema por iframe en Firefox de escritorio. Solo se ve en la consola del navegador (§4.9b) |
| **`git` contesta un commit que no es** | Se pide un hash y devuelve otro, con su asunto | El hook de `rtk` filtra la salida de `git`. No falla ni avisa, y `rev-parse --short HEAD` sí coincide. Medir con `/usr/bin/git` o `rtk proxy` (§4.9d) |
| **Un `Depends: firefox` se cumple con el Snap** | El metapaquete instala «bien», apt sale con 0, y la máquina sigue abriendo el Snap | El nombre `firefox` existe en los dos repositorios. En un escritorio de fábrica ya está instalado el deb de transición, así que la dependencia se da por satisfecha y no se instala nada; y en una base sin él, apt lo resuelve contra el índice de Ubuntu, porque el repo de Mozilla no está en los índices **cuando apt resuelve** (§4.10e) |
| **`apt upgrade` no cambia el Snap por el nativo** | El anclaje está bien puesto y Firefox sigue siendo el de transición | Es un *downgrade* formal, por el epoch `1:`. Solo lo hace `full-upgrade`, y con `-y` hace falta `--allow-downgrades`. `unattended-upgrades` no lo dará nunca (§4.10c) |
| **Firefox nativo llega en inglés y nadie lo nota hasta abrirlo** | Todo en verde, `apt policy` correcto, y la interfaz en inglés | `firefox-l10n-es-es` **solo** existe en el repositorio de Mozilla: `Candidate: (none)` en Ubuntu, y `firefox-locale-es` de Ubuntu es otro transitorio al Snap. Ningún paquete de Encina puede declararlo sin violar R10, y el `full-upgrade` no lo arrastra (§4.10f) |
| **Un `Recommends:` de l10n instala un Snap** | Se pide el idioma de Thunderbird y entra `snapd` | `thunderbird-locale-es` es un transitorio (`2:1snap1-…`) que depende de `thunderbird`, que lleva `Pre-Depends: debconf, snapd` (§4.10h) |
| **La tienda de software devuelve el Snap** | Se quiere «un escritorio que crece», se declara `gnome-software`, y entra `snapd` con él | En 24.04 `gnome-software` lleva `snapd` entre sus dependencias, y los índices **no** ofrecen ningún `gnome-software-plugin-deb`: solo `-plugin-snap` y `-plugin-flatpak`. Medido el 2026-08-11 (§4.26d), con el control de que `gnome-packagekit` y `synaptic` **no** lo arrastran. Y si entra, «Firefox» en la tienda es el Snap, que es la única vía medida al estado (d) — el que no firma |
| **Se borra un medio de 3,4 GB y el disco devuelve 0,44 GiB** | `rm` de una ISO de `e2-medios`, y `df` casi no se mueve | Es §9.a por un sitio nuevo: el `Data/` de cada bundle de UTM tiene un **clon de APFS** de su ISO, así que los bloques siguen referenciados. **No son enlaces duros** —`stat` da 1 enlace— ni instantáneas locales (`tmutil listlocalsnapshots /` vacío). Borrar un medio y borrar su VM **no son dos ahorros, son uno**. Lo único que no miente es `df` antes y después (§4.26i) |
| **Un `find` acotado contesta «no hay» cuando quería decir «no he mirado»** | `find / -maxdepth 6 -name '*.iso'` no encuentra ninguna, y de ahí sale «en este Mac no hay ninguna ISO»: se aplaza una casilla, se presupuestan 3,5 GB de red y se declara imposible una comparación que sí se podía hacer | El `-maxdepth` estaba por debajo de la profundidad real. Las ISOs vivían a **nueve** componentes (`~/Library/Containers/com.utmapp.UTM/Data/Documents/e2-medios/`) y había **trece**. Es la familia de la 5: **una comprobación que no puede dar una de sus dos respuestas no es una comprobación**, y una búsqueda vacía sólo significa «no hay» si el instrumento podía encontrarlo. Se dice el ámbito al lado del resultado, o se busca sin acotar (§4.39a) |
| **Un `[OK]` que sigue saliendo con la comprobación desactivada** | El guion imprime `[OK] modo fijado: 32 ficheros en 644` y produce una ISO con cuatro ficheros que **no** están en 644 | La línea de `[OK]` describe lo que el guion *pidió*, no lo que *pasó*. Lo único que separaba las dos cosas era el guardián de la trampa 13 — verificar la mutación **antes** de leer su resultado. Neutralizado el guardián, el `[OK]` se imprime igual y la ISO sale rota (§4.39g) |
| **Un `[FALLO]` esperado en medio de una pasada buena** | Una vuelta que termina en verde lleva un `[FALLO] el repositorio NO esta completo` a la mitad, y nadie se para | Era el control —la cosecha se pide en dos órdenes y la primera sale incompleta a propósito— pero no iba anunciado. Un `[FALLO]` sin explicar dentro de una salida buena **enseña a saltarse los `[FALLO]`**, que es justo lo contrario de para lo que están. Se anuncia antes y se comprueba que dé exactamente el número esperado (§4.39j) |
| **Una lista exacta que da por segura una etapa que no siempre está** | El verificador exige nueve etapas en `telemetry` y una instalación buena escribe **ocho**: falta `loading`. La máquina está entera —51 comprobaciones en verde, `ESTADO=COMPLETO`— y la casilla no se puede marcar | La lista se hizo exacta **añadiendo `loading` porque se escribió que “toda instalación la escribe”**, y eso era una generalización sobre **una** medición (§4.32g). En esta ISO **no se registra nunca**: medido en dos arranques —uno instalando y otro sin instalar nada— y la palabra no sale ni una vez del registro del cliente, con el control de que el mismo `grep` encuentra `keyboard` catorce veces. **Una lista exacta es más fuerte que una laxa sólo si cada elemento está medido, no supuesto** — y aflojarla sin causa la convierte en una que ya no distingue (§4.40c, c bis) |
| **Una hipótesis que “encaja con los datos” y aun así es falsa** | Dos ficheros compatibles con una explicación —`loading` y `keyboard` colisionando en el mismo tick—, un número que la apoyaba (0,688 s de separación, menos de un tick) y estaba **equivocada** | Encajar con el resultado no es ser la causa: la colisión y la ausencia **producen el mismo fichero**. Lo que las separa no es el contenido sino **cuándo** se escribió, y eso estaba en el registro del cliente: el primer volcado, 6 ms después de arrancar y 0,742 s **antes** de dibujarse ninguna pantalla, ya decía `keyboard`. **Nunca hubo un instante que colisionar.** Y la prueba que lo decidió costó 16 MiB: arrancar el medio **sin disco de destino** y leer la sesión viva (§4.40c bis) |
| **Comparar un `.deb` contra los `.md5sums` de dpkg no puede cuadrar** | Dos paquetes «no cuadran» por 3 y 2 ficheros, el tercero cuadra, y los cinco que faltan existen y están bien | **dpkg no mete los conffiles en `.md5sums`**: los registra aparte, en `/var/lib/dpkg/status`. Los cinco eran exactamente los ficheros bajo `/etc/`, uno a uno, y el paquete que cuadró es el único que no instala nada ahí. Es la familia de la 5 escrita por uno mismo: **una comprobación que busca el dato donde el dato no puede estar**. Para atar un `.deb` instalado sirve `dpkg -V` —con el control de que sepa señalar algo en el sistema— y los conffiles hay que ir a buscarlos a `status` (§4.40d) |
| **Un sabotaje que sí cambia el fichero y aun así no es un control** | `cmp` confirma que el fichero cambió, y la herramienta sigue dando verde | Cambiar el fichero no basta: hay que cambiarlo **por donde la herramienta mira**. Meter `$SINCOMILLAS` en un guion cambia dos líneas y `shellcheck -S warning` lo ignora, porque no es un defecto de ese nivel. Es la 24 de `SCRIPTS.md` un paso más allá: el sabotaje tiene que sabotear **la comprobación**, no sólo los bytes (§4.39k) |
| **Un icono que ningún tema de iconos puede cambiar** | Se pone el tema propio, se comprueba que gana para lo suyo, y el icono de esa aplicación sigue exactamente igual — y con el tema de Ubuntu también, o sea que no es «que el nuestro no gane» | Su `.desktop` no declara un **nombre** sino una **ruta absoluta**: `Gio` devuelve un `GFileIcon` y no un `GThemedIcon`, y el tema **no interviene**. Es lo que hacen los snaps —`Icon=${SNAP}/…` escrito en su propio `meta/gui`—, así que el fichero vive además en un squashfs de solo lectura que se sustituye entero en cada autorrefresco. Se distingue antes de gastar nada preguntando el **tipo** del icono, no su ruta (§4.47a y b). La única vía que queda es sombrear el `.desktop`, como §4.19 con Firefox |
| **El control muere dentro del propio control** | Un lector de `.desktop` con su control por delante —un id inventado tiene que dar `None`— revienta con `TypeError` en esa línea y se lleva media medición | `Gio.DesktopAppInfo.new` **no devuelve `None`** cuando el id no existe: **lanza `TypeError`**. El control se escribió esperando `None`, que es la forma más tonta de perder una pasada. Se envuelve en `try/except` (§4.48c) |
| **Una medición que dejó de valerse sola justo al arreglar la cosa** | La lista de iconos enseñaba los dos tipos —`File` y `Themed`— antes del cambio, y después del cambio sólo enseña `Themed`, así que el lector ya no demuestra que sabe distinguirlos | Lo que separaba los dos casos era **el ejemplar de la clase que se arregló**. Al arreglarlo desaparece de la lista y el instrumento se queda ciego sin avisar. Se mete a propósito otro del tipo que se va —aquí `firefox_firefox.desktop`, que en `encina-dev` es Snap— para que la pasada siga probando su propio poder de resolución (§4.48c) |
| **Un repositorio sacado de un medio anterior trae `.deb` fosilizados** | Se extrae `/encina-repo` de la ISO buena para rehacer los YAML y 2 de los 28 no cuadran con el manifiesto, con el contenido correcto | Aquel medio se fabricó **antes** de §4.37, así que lleva dentro los `.deb` construidos sobre un árbol de trabajo —`972ec932…` y `86da3cc9…`, las huellas que el comentario del seed llama «las anteriores»—. Un medio conserva el estado del día que se fabricó, incluidos sus defectos. Se reconstruyen desde el clon y dan las del manifiesto (§4.48f) |
| **Un nombre de fichero es una huella disfrazada** | Se actualizan las huellas del ritual y queda un sitio con el nombre del `.deb` viejo, que ni siquiera es una huella | Los nombres llevan **la versión dentro**, y viven duplicados en dos arrays `FICHEROS` —`fabricar-seed.sh` y `fabricar-iso.sh`—. `SCRIPTS.md` los nombra a los dos desde el 2026-08-12 y aun así lo que cierra la duda es `grep -rn 'encina-branding_0\.1\.' imagen/ scripts/`: la lista se comprueba, no se recita. Este sitio **no falla en silencio** —`fabricar-iso.sh` para con `no esta: …`— así que el riesgo es tiempo, no un medio equivocado (§4.48f) |
| **Un SVG que se resuelve, se dibuja con librsvg y aun asi deja un HUECO en el dock** | El `.desktop` gana, `should_show()` da `True`, `Gtk.IconTheme` —en 3 y en 4— resuelve el nombre a nuestro SVG y `rsvg-convert` lo pinta. Y en la pantalla no hay icono: hay un hueco, y el Shell escribe *«Could not load a pixbuf from icon theme»* | **`gdk-pixbuf` reconoce el formato husmeando el principio del fichero: si el `<svg` no cae dentro de los primeros 256 BYTES, no lo reconoce.** El comentario de cabecera —que en este proyecto es método— lo empujaba al byte 2090. Umbral medido con búsqueda binaria (256 carga, 257 no) y con control en las dos direcciones: quitárselo al roto lo arregla y ponérselo al sano lo rompe. **El comentario va DENTRO de `<svg>`.** Afectaba también a `encina-logo.svg` desde 0.1.9, invisible seis versiones porque ese icono no se pinta en el dock (§4.49) |
| **Un control que sale rojo dos veces y se lee como instrumento averiado** | La prueba de carga falla con el fichero nuevo **y** con el viejo, así que se descarta el lector y se busca por otro lado | Un control que falla en los dos casos puede ser **un hallazgo doble**, no un instrumento roto. Aquí los dos SVG estaban rotos de verdad y la conclusión «el lector no vale» costó buscar la causa por tres sitios equivocados. Lo que separa las dos lecturas es meter un ejemplar que **tenga** que salir bien —un PNG, u otro SVG que sí cargue— y mirar si el lector lo distingue (§4.49a) |
| **Un listado que esconde el nombre de los enlaces simbólicos** | Se inventaría una capa del medio con `unsquashfs -ll \| awk '{print $NF}'` y el icono del botón de la rejilla **no aparece**, así que el inventario sale corto y nadie lo nota | En un enlace, la línea acaba en el **destino**, no en el nombre: `$NF` devuelve `../places/start-here-symbolic.svg` y el nombre `view-app-grid-ubuntu-symbolic.svg` desaparece del recuento. Es **§4.45c otra vez** —allí fue `find -type f`, que tampoco ve enlaces— y aquí escondía justo el fichero que decide el botón que §4.43 costó dos días. El nombre es el **campo 6**, y el guion lleva un control que lo vigila (§4.51a) |
| **`grep -q` convierte un acierto en fallo cuando hay `pipefail`** | Un control que dice `[FALLO] no se pueden listar las capas` mientras las listas están delante, con 123 695 y 59 198 entradas | `awk … \| grep -q` con `set -o pipefail`: `grep` acierta y **sale antes de leerlo todo**, `awk` recibe SIGPIPE y muere con 141, y el estado de la tubería es 141 aunque la búsqueda haya salido bien. Se ve porque el mensaje contradice a sus propios números. Se saca la lista a un fichero **antes** de buscar en ella (§4.51a) |
| **Un inventario que cuenta SITIOS y no VALORES** | Se cambia el medio, se vuelve a pasar el inventario y **sale el mismo número**: 39 antes y 39 después, con el `grub.cfg` diciendo ya «Probar o instalar Encina OS» delante | El guion emitía `[AVISO]` por cada **sitio** inventariado, dijera lo que dijera. Un inventario así sirve para la primera pasada —enumerar dónde mirar— y **no sabe decir que el trabajo está hecho**, que es justo para lo que se le pide después. Lo que decide tiene que ser **el valor medido**, y hacen falta dos contadores: los que todavía la dicen y los que ya no (§4.52e) |
| **Un control que caduca cuando el producto mejora** | `[FALLO] el calculo de RELEASE da lo mismo con cualquier .disk/info`, sobre un guion que no se ha tocado y que ayer salía verde | El fichero de prueba del control decía `Encina OS 0.3 LTS …`, y el día que el medio empezó a llevar de verdad un `.disk/info` de Encina **los dos daban lo mismo**. Un control cuyo caso de prueba se parece al producto deja de discriminar en cuanto el producto avanza — y el rojo se lee como «instrumento roto» cuando lo que dice es «tu control ya no separa nada». El caso de prueba tiene que ser algo que **no pueda salir de ningún medio real** (§4.52e) |
| **Un `squashfs` recién hecho no es reproducible** | La capa se fabrica dos veces seguidas, sin tocar nada, y da dos huellas distintas — y el `[FALLO]` no sale ahí sino tres pasos más abajo, en la huella de la ISO, donde parece un problema de `xorriso` | `mksquashfs` guarda **la hora de creación del sistema de ficheros y la de cada inodo**, y las de los inodos las pone `cp` al copiar los ficheros al árbol de trabajo. Se fija la misma fecha que ya usa `fabricar-iso.sh` para lo que añade, con `-mkfs-time`, `-inode-time` y `-root-time`, **y el control se mete dentro del guion**: fabricarla dos veces y comparar. Es la misma familia que la fecha de `xorriso` de §4.36k (§4.52e) |
| **Un fichero que se lee de la capa de abajo mientras el medio enseña el de arriba** | El inventario dice `NAME="Ubuntu"` de un medio que en pantalla dice Encina | Con capas apiladas (`overlay`), leer una sola capa **no** es leer el medio. `unsquashfs` de `minimal.squashfs` devuelve el fichero **tapado**. Hay que extraer en el mismo orden en que casper monta —primero las de Ubuntu, **encima** las de marca— o el instrumento miente en la dirección más peligrosa, que es la de decir que queda trabajo por hacer donde ya está hecho, y a la inversa (§4.52e) |
| **Una comprobación ciega en el sitio más fuerte del guion** | `fabricar-iso.sh` compara la ISO nueva contra la oficial **fichero a fichero** —531 entradas, huella a huella— y aun así dejaría pasar en silencio un cambio del `Volume id` | El `Volume id` **no es un fichero**: vive en los descriptores de volumen, sector 16 y siguientes, que el árbol de ficheros no cubre. Una comprobación exhaustiva **dentro de su dominio** no dice nada de lo que está fuera de él, y cuanto más fuerte es, más fácil es creerse que lo cubre todo. Lo mismo vale para `md5sum.txt`, que sólo cubre ficheros. Hace falta una comprobación aparte y **por bytes** (§4.53d) |
| **Un número que parece del formato y es del que lo escribió** | Un bloque que exige «tantas copias del descriptor como tenía la oficial» **falla siempre**, sobre una ISO correcta | La ISO oficial de Canonical lleva **2 descriptores primarios y 2 Joliet**; la que sale de `fabricar-iso.sh` lleva **4 y 0**. Remasterizar con `xorriso` **duplica los primarios y se lleva el Joliet**, y eso pasaba desde E3 sin que nadie lo hubiera medido. Calibrar contra la entrada era calibrar contra otra cosa: se **leen todos** los descriptores de la salida y se exige que digan lo nuestro (§4.53d) |
| **`unsquashfs` de una capa de Ubuntu muere a mitad en macOS, y `du` lo disimula** | `FATAL ERROR: write_file: … xt_connmark.h already exists`, y si se ha redirigido la salida queda un árbol **truncado** que `du -sh` describe como «27M» sin que nada diga que faltan 47 000 ficheros | El disco del Mac **no distingue mayúsculas**, y las capas del medio traen pares como `xt_connmark.h` / `xt_CONNMARK.h`. Son pocos —10 en `minimal.squashfs` y 47 en `minimal.standard.live.squashfs`, contados con `tr 'A-Z' 'a-z' \| sort \| uniq -d`— así que con `-f` la extracción **termina** y lo único que se pierde es una de cada pareja, que **se puede nombrar**. Un hueco declarado y contado vale; un árbol a medias que parece entero, no (§4.53a) |
| Fallos raros con software de terceros | Instaladores y scripts que no reconocen el sistema | Se cambió `ID` en `os-release` |
| Fondo claro en modo oscuro | Solo en tema oscuro | Falta `picture-uri-dark` (GNOME 42+) |
| Builds no reproducibles | Dos builds del mismo commit difieren | Falta fijar fecha de snapshot del mirror |


---

### 4.50 SE BORRÓ UNA ISO DE 3,5 GB Y `df` DEVOLVIÓ CERO: era un clon de APFS, y el hueco lo sigue reteniendo la VM (2026-08-15)

**La medición no salió como se esperaba, y por eso vale.** Con permiso de Jorge
se borró `medios/encina-os-E4-es-0.2.1-95758c9e.iso` —3,5 GB según `du`, nunca
arrancada, superada por `1224b5b1…` y reproducible desde `git` (§4.39)—,
midiendo con `df` antes y después como manda §9.1:

```
== confirmo QUE fichero es, por huella y no por nombre:
95758c9e954d834f

df antes    59217924 KiB libres
rm -f medios/encina-os-E4-es-0.2.1-95758c9e.iso
df despues  59217904 KiB libres

DEVUELTO REAL: 0 MiB          du decia: 3,5 GiB
```

**Cero. Y el espacio libre incluso BAJÓ 20 KiB**, que es el ruido de otras
escrituras del sistema durante la medición.

#### (a) La causa, medida y no supuesta

Dos explicaciones posibles, y se descartó una:

```
== instantaneas locales de APFS:
Snapshots for disk /:                       (ninguna)

== la copia que vive dentro de encina-95758c9e.utm:
  Data/encina-os-nueva.iso    3,5 GB    95758c9e954d834f    <- LA MISMA HUELLA
```

**No era una instantánea: era un clon.** UTM enlazó la ISO al arrancar la VM
—`imagen/` y §4.35 ya lo hacen «en duro» a propósito— y las dos copias
comparten **todos** los bloques. Borrar una de las dos no libera nada. **Solo la
última paga.**

Es la trampa 21 de `SCRIPTS.md` otra vez, y la tercera vez que este proyecto la
encuentra: §4.26i la vio en `encina-E3-iso` (3,4 GB de clon de la ISO inglesa
dentro del bundle) y §4.29 la vio en una VM duplicada (`du` 9,2 GB, `df`
0,923 GiB).

#### (b) Lo que esto cambia en la decisión de limpiar, que es lo caro

**El tamaño de una VM no es independiente del de las demás.** Los 15 GB de
`encina-95758c9e` incluyen 3,5 GB que también contaban en `medios/`. Sumar la
columna `du` del inventario y creerse el total es exactamente el error que
§4.29 ya castigó.

**Y una consecuencia que no es intuitiva:** aquel borrado **no fue un error pero
tampoco compró nada**. La ISO no ocupaba: sus bloques ya estaban pagados por la
copia de la VM. Se fue el nombre, no el espacio. **El hueco de esos 3,5 GB solo
aparece el día que se borre `encina-95758c9e`**, y entonces `df` devolverá más
de lo que diga `du` de la VM sola.

#### (c) El instrumento, y los dos defectos que costó

Se añadió a `scripts/inventario-vms.sh` una sección que **habría cazado esto
antes de borrar**: agrupa los ficheros de ≥1 GiB que declaran el mismo número de
bloques y los señala como candidatos a clon. Hoy encuentra las tres ISOs de
3,5 GB y las dos copias de la ISO oficial.

**No es una comprobación de clonado y se dice así en el guion:** macOS no
expone los bloques únicos de un fichero. Es un indicio barato que se confirma
con `shasum`, **y ese paso no se puede saltar**: dos ISOs de este proyecto
—`ac0a5721…` y `1224b5b1…`— tienen **el mismo tamaño exacto y distinto
contenido** (§4.45).

Los dos defectos, los dos míos y los dos cazados ejecutando:

1. **`find -size +1g` no es válido en macOS**, que quiere `G` mayúscula. No dio
   un error legible: salió distinto de 0, `set -e` mató el guion **en mitad de
   la sección** y la salida terminó justo después del título. Un guion que se
   muere en silencio es peor que uno que falla.
2. **Agrupar por tamaño lógico (`%z`) daba un falso positivo gordo:** los cuatro
   `disco.img` de UTM son **dispersos** y declaran los mismos 42 949 672 960
   bytes exactos ocupando entre 10 y 12 GiB distintos. Con **bloques asignados
   (`%b`)** se separan solos —24320864, 22141472, 21780928, 25570784— y las tres
   ISOs siguen juntas en 7256576 clavados. **El primer criterio habría dicho que
   cuatro VMs comparten 40 GiB, que es falso y habría llevado a borrar la que no
   era.**

---

### 4.51 DÓNDE DICE UBUNTU EL MEDIO: 39 sitios, leídos sin arrancarlo — y el instalador trae un mecanismo de marca blanca que nadie había mirado (2026-08-15)

**Es la primera casilla de `tareas/marca-del-medio.md`**, y se hace como manda su
enunciado: **midiendo y no suponiendo**. Todo lo de aquí sale de leer
`medios/encina-os-E4-es-0.2.1-1224b5b1.iso` —huella comprobada **antes** de leer
nada— **sin arrancarla, sin montarla y sin gastar ninguna VM**.

```
1224b5b17b559007071dee8fcaa620ff28cc3d8361eb75fdbe4af1eb3401529f   3715366912 bytes
```

**Y la casilla llegaba con una suposición dentro**, que es exactamente lo que
había que no heredar: su copia rancia decía que *«el botón de la rejilla lleva el
logotipo de Ubuntu»*, y esa lectura estaba mal desde el principio —lo que se
estaba mirando era `gnome-initial-setup` **ejecutándose** (enmienda del
2026-08-15)—. Aquí no se ha copiado ni una línea de aquello: **cada renglón del
inventario tiene su fichero y su cadena**.

#### (a) EL INSTRUMENTO, y los dos defectos que sacó de sí mismo

§4.27 leyó un medio sin arrancarlo y §4.39 lo fabricó cuatro veces, pero **ninguna
de las dos dejó guion**: lo de §4.27 fue lectura a mano de manifiestos. Así que
hay uno nuevo, y por eso se dice: **`imagen/inventario-marca.sh`**, que en el Mac
saca el árbol con `xorriso`, las capas `squashfs` con `osirrox` y el `initrd`
partiéndolo por su `TRAILER!!!`.

**Los controles van los primeros, y no es adorno: un buscador que no sabe decir
«no lo hay» dice «no he mirado», y se lee como «no hay marca».**

```
--- (a) el arbol del medio sabe decir SI y NO
  [OK]    531 ficheros: encuentra /casper/minimal.squashfs y NO encuentra uno inventado
--- (b) el calculo de RELEASE no esta clavado
  [OK]    sobre un .disk/info inventado da «Encina OS», no «Ubuntu 24.04.4 LTS»
--- (c) las capas squashfs se sacan del medio y se listan
  [OK]    capa base 123695 entradas, capa viva 59198: encuentra /etc/os-release y no uno inventado
--- (d) el listado ENSENA EL NOMBRE de los enlaces simbolicos (trampa 1)
  [OK]    el nombre del enlace view-app-grid-ubuntu-symbolic.svg se ve en el campo 6
```

XXPLACEHOLDERXX el inventario:**

1. **`unsquashfs -ll | awk '{print $NF}'` esconde el nombre de los enlaces
   simbólicos**, porque en un enlace la línea acaba en el **destino**. Lo que
   escondía era justo `view-app-grid-ubuntu-symbolic.svg` —el icono del botón de
   la rejilla, el que costó §4.43 entera—, que salía como
   `../places/start-here-symbolic.svg` y no se contaba. Es **§4.45c otra vez**
   (allí fue `find -type f`). El nombre es el **campo 6**, y el control (d) existe
   para vigilarlo.
2. **`awk … | grep -q` con `pipefail` convierte el acierto en fallo.** El control
   (c) salió `[FALLO] no se pueden listar las capas del medio` **enseñando al lado
   sus 123 695 y 59 198 entradas**: `grep -q` acierta, sale antes de leerlo todo,
   `awk` muere de SIGPIPE y la tubería devuelve 141. Se ve porque **el mensaje
   contradice a sus propios números**. Se saca la lista a un fichero antes de
   buscar.

Y una tercera, del entorno y no del guion: **macOS no monta esta ISO**
(*«sistemas de archivos que no pueden montarse»*), así que las capas hay que
sacarlas a disco —**~3,2 GB**— y no se pueden leer en el sitio.

#### (b) PLANO 1 — EL MEDIO ENTERO

| Fichero | Cadena medida | Dónde se ve |
|---|---|---|
| el volumen ISO 9660 | `Ubuntu 24.04.4 LTS arm64` | **el nombre del disco al conectar el USB, en cualquier sistema operativo**. Es la última casilla de la tarea |
| `/boot/grub/grub.cfg` | `menuentry "Try or Install Ubuntu"` | **la primerísima pantalla del arranque**. Y es **fichero nuestro**: lo reescribe `fabricar-iso.sh` para meter el `locale=` |
| `/.disk/info` | `Ubuntu 24.04.4 LTS "Noble Numbat" - Release arm64 (20260210)` | no se ve tal cual, **pero de aquí sale el nombre del icono del instalador** (plano 2) |
| `/.disk/release_notes_url` | `http://www.ubuntu.com/getubuntu/releasenotes?os=ubuntu&…` | el enlace de «notas de la versión» del instalador |
| `/casper/install-sources.yaml` | `name: en: Ubuntu Desktop (minimized)` y `Ubuntu Desktop`; `id: ubuntu-desktop-minimal` | la pantalla de «tipo de instalación» — **que el seed de Encina NO enseña**: las cinco son `keyboard, network, storage, identity, timezone` (§4.32g) |
| `/dists/noble/Release` | `Origin: Ubuntu`, `Label: Ubuntu`, `Description: Ubuntu Noble 24.04` | en `apt`. **Firmado por Canonical**: tocarlo rompe `Release.gpg` (D9, §4.32) |
| `/preseed/ubuntu.seed` | el nombre, y dentro `tasksel/first multiselect ubuntu-desktop` | no lo lee `subiquity`; el fichero viaja igual |
| `/pool/*.deb` | **155 de 185** nombres llevan `ubuntu` (versiones `-Nubuntu…`) | en `apt` y `dpkg` de la máquina instalada |
| `/md5sum.txt` | esos mismos nombres | sólo quien lo abra |
| `/efi/boot/{bootaa64,grubaa64,mmaa64}.efi` | **[OMIT]** | firmados: **no se tocan** (regla dura de E3, §4.21) |

**Y una que sale a favor:** la tabla de particiones es **MBR y no lleva nombres**
(dos entradas, `0xcd` y `0xef`), así que **lo único que un gestor de discos enseña
es el Volume id**. Cambiarlo cambia lo que se ve en todas partes.

**Lo único de Encina que viaja en el medio son los 29 ficheros de
`/encina-repo/`**, y eso decide el plano 3.

#### (c) PLANO 2 — EL INSTALADOR VIVO, que es un SNAP

`/var/lib/snapd/seed/snaps/ubuntu-desktop-bootstrap_495.snap`, **109 600 768
bytes**, y va **por duplicado** (también en `snaps/`). Dentro, **153 de 8 544**
nombres llevan `ubuntu`.

**EL NOMBRE DEL ICONO NO ESTÁ ESCRITO: SE CALCULA, Y SE CALCULA DESDE
`.disk/info`.** El `.desktop` que viaja dice literalmente:

```
Name=Install RELEASE
Icon=ubiquity
```

y quien sustituye `RELEASE` es `casper-bottom/25adduser`, **leído en el guion que
viaja en este mismo medio** (líneas 80-88):

```sh
LTS="$(cut -d' ' -f3 /root/cdrom/.disk/info)"
RELEASE="$(cut -d' ' -f1-2 /root/cdrom/.disk/info | sed 's/-/ /')"
[ "$LTS" = "LTS" ] && RELEASE="$RELEASE LTS"
sed -i "s/RELEASE/$RELEASE/" "/root$file"     # y lo copia al Escritorio del usuario vivo
```

Ejecutado sobre el `.disk/info` **de este medio**, y con su control delante:

```
.disk/info inventado (Encina OS 0.3 LTS …)  -> Name=Install Encina OS
.disk/info de este medio                    -> Name=Install Ubuntu 24.04.4 LTS
```

O sea: **una línea de `.disk/info` cambia el rótulo del icono del escritorio y del
dock.** Es la palanca más barata de todo el bloque 1.

| Fichero | Cadena medida | Dónde se ve |
|---|---|---|
| `…/ubuntu-desktop-bootstrap_….desktop` | `Name=Install RELEASE` → `Install Ubuntu 24.04.4 LTS` | **el icono del Escritorio y el del dock** de la sesión viva |
| el mismo | `Icon=ubiquity` → `Yaru/…/apps/ubiquity.png` | **el dibujo del icono: un disco duro con la chincheta naranja del logotipo de Ubuntu** — mirado, no supuesto |
| `…/bin/lib/libapp.so` | `Try or install ` / `Probar o instalar ` (con espacio final) | **el título de la ventana del instalador**: es plantilla, se le pega el nombre del producto |
| el mismo | `Installing Ubuntu`, `installUbuntu`, `tryUbuntu`, `_isUbuntuDerivative` | botones y páginas del instalador |
| `…/assets/slides/9/slide_es_ES.html` | **«Ubuntu» literal ×7 en el texto visible** (×12 en el fichero): *«La documentación oficial de Ubuntu…», «Ask Ubuntu», «Ubuntu Discourse», «…con Ubuntu Pro»* + `ask-ubuntu-light.svg` | **la presentación que se ve mientras instala** |
| `…/assets/slides/{2..8}/slide_es_ES.html` | `{{ DISTRO }}` ×1 en cada una | las otras siete diapositivas — **son plantilla, se rellenan en marcha** |
| `…/ubuntu_provision/assets/images/` | `logo-light.svg`, `logo-dark.svg`, `mascot.svg`, `mascot_no_background.svg`, `ubuntu_pro.svg`, `ubuntu_certified.svg`, `ubuntu_storage_icon.svg` | los dibujos de cada página del instalador |

**EL HALLAZGO QUE NO SE BUSCABA: el instalador trae un mecanismo de MARCA
BLANCA.** Dentro del snap hay
`…/packages/ubuntu_provision/assets/whitelabel.yml`, que mapea **cada página a su
imagen** —`locale`, `try-or-install`, `keyboard`, `network`, `storage`,
`identity`, `confirm`, `done`, `error`…—, y el binario lleva la cadena
`whitelabel`. Es la única pieza del medio pensada **para que otro ponga su
marca**, y hasta hoy no estaba nombrada en ningún documento de este repositorio.

#### (d) PLANO 3 — LA PRIMERA SESIÓN, y lo primero decide todo lo demás

```
  [OK]    NI UN fichero de Encina en las capas del medio (0), y 4450 con «ubuntu»:
          la sesion viva es Ubuntu entera
```

**Con su control**: el mismo recuento sobre `ubuntu` no es cero, así que el
buscador sabe contar. Y tiene explicación, no es una sorpresa: `encina-branding`
se instala **en el objetivo**, desde `/encina-repo`, y **nunca llega a la sesión
viva**. Todo lo que rodea al instalador es Ubuntu de fábrica.

| Fichero | Cadena medida | Dónde se ve |
|---|---|---|
| `10_ubuntu-settings.gschema.override` | `[org.gnome.desktop.background:ubuntu] picture-uri = 'file:///usr/share/backgrounds/warty-final-ubuntu.png'` | **el fondo que se ve detrás del instalador** (el fichero está, 5 871 771 bytes) |
| el mismo | `favorite-apps` con `ubuntu-desktop-bootstrap`, `firefox_firefox`, `snap-store`, `yelp` | **los iconos del dock** de la sesión viva |
| el mismo | `[org.gnome.login-screen] logo='/usr/share/plymouth/ubuntu-logo.png'` | el saludador GDM — **no sale en el medio**, que entra solo; el instalado lo cierra `encina-branding` |
| `…/Yaru/scalable/actions/view-app-grid-ubuntu-symbolic.svg` | enlace → `../places/start-here-symbolic.svg` | **el botón de la rejilla del dock**. Es el nombre que §4.43 midió, y en la sesión viva **no hay tema de Encina que lo tape** |
| `/etc/os-release` | `PRETTY_NAME="Ubuntu 24.04.4 LTS"`, `NAME="Ubuntu"`, `ID=ubuntu`, `LOGO=ubuntu-logo`, y cuatro URL de `ubuntu.com` | Configuración → Acerca de, en la sesión viva. **Es lo que la segunda casilla tiene que decidir** |
| `/etc/lsb-release` | `DISTRIB_ID=Ubuntu`, `DISTRIB_DESCRIPTION="Ubuntu 24.04.4 LTS"` | lo lee software de terceros |
| `/etc/issue`, `/etc/issue.net` | `Ubuntu 24.04.4 LTS \n \l` | una consola de texto (Ctrl+Alt+F3) |
| `/usr/share/wayland-sessions/ubuntu.desktop` | `Name=Ubuntu`, `Comment=This session logs you into Ubuntu` | el selector de sesión del saludador |
| `…/themes/ubuntu-text/ubuntu-text.plymouth` | `Name=Ubuntu Text`, `title=Ubuntu 24.04` | el arranque en modo texto |

**EL ARRANQUE DEL MEDIO, que es lo PRIMERO que se ve, sale del `initrd` y no de
ninguna capa.** `casper/initrd` son **dos `cpio` pegados** —el primero sin
comprimir con firmware y módulos, y a partir del byte 60 952 064 uno **zstd** de
24 227 401 bytes—, y dentro:

```
usr/share/plymouth/themes/default.plymouth -> /usr/share/plymouth/themes/bgrt/bgrt.plymouth
usr/share/plymouth/themes/spinner/watermark.png       248x87   bfc97707…
usr/share/plymouth/themes/spinner/bgrt-fallback.png   128x128  0d4f0416…
```

Las dos son **el logotipo de Ubuntu**, mirado y contado: en `watermark.png`, 6 576
píxeles opacos —4 196 naranjas del cuadro con el *circle of friends* y **1 505 a
la derecha del cuadro**, que son la palabra «ubuntu» en blanco—. El tema `bgrt`
las dibuja al 96 % de la altura (`WatermarkVerticalAlignment=.96`).

**[OJOS] — en pantalla no lo ha visto nadie**, y eso no cambia hoy: en UTM la
pantalla del invitado está apagada todo el arranque (aviso 3 de `ENCINA-OS.md`
§7). Es límite del banco, no resultado sobre el producto.

#### (e) LO QUE NO SE HA MEDIDO, dicho con su nombre

- **Quién gana rellenando `{{ DISTRO }}` y el título de la ventana.** En
  `libapp.so` están **los dos** literales —`/cdrom/.disk/info` (junto a
  `ubuntu_wizard/src/wizard_data.dart`) y
  `/var/lib/snapd/hostfs/etc/os-release`, con `PRETTY_NAME`,
  `_readProductName` y `_parseProductName`—. Que existan los dos no dice cuál
  manda. **`[OMIT]`, y se decide leyendo la fuente de `ubuntu_provision` o
  arrancando el medio con un `.disk/info` cambiado**, que es barato porque el
  fichero pesa 60 bytes.
- **Si el `whitelabel.yml` se puede apuntar desde fuera del snap.** El fichero
  vive dentro de un `squashfs` de solo lectura que se sustituye entero en cada
  autorrefresco (la misma trampa de §4.47a), y **no se ha encontrado ninguna ruta
  de configuración externa** en el binario. `[OMIT]`.
- **Nada de la máquina instalada.** Ese bloque está cerrado y no se ha vuelto a
  medir aquí: lo que aparece de él —el logo de GDM, `os-release`— sale sólo
  porque **viaja en el medio**.

#### (f) LO QUE ESTO DEJA PARA LAS TRES CASILLAS QUE QUEDAN

**39 apariciones, y no todas cuestan lo mismo.** Ordenadas por lo que se ve
dividido por lo que cuesta:

1. **El Volume id** — un campo, y se ve en cualquier ordenador antes de arrancar.
2. **`/boot/grub/grub.cfg`** — «Try or Install Ubuntu», y **el fichero ya es
   nuestro**: lo escribe `fabricar-iso.sh`, con el precio de `md5sum.txt` ya
   pagado y medido (§4.21d, §4.25).
3. **`/.disk/info`** — 60 bytes que cambian el rótulo del icono del instalador,
   demostrado con su control.
4. **El fondo de la sesión viva** — un `gschema.override` dentro de
   `minimal.squashfs`, o sea **rehacer una capa de 1,69 GB**: aquí se acaba lo
   barato.
5. **El instalador por dentro** —diapositivas, `logo-*.svg`, el título— vive en un
   snap firmado de 109 MB. **Es la frontera real del reempaquetado**, y es el
   argumento que la tarea ya anticipaba: *«repintar una ISO de Ubuntu
   reempaquetada es una solución a medias»*. La única puerta declarada es el
   `whitelabel.yml`, y está sin medir.

---

### 4.52 LA MARCA ENTRA EN EL MEDIO SIN REHACER 1,69 GB: una capa de 2,9 MiB — y las dos preguntas de §4.51 se contestan, una de ellas estaba mal planteada (2026-08-15)

**Es la tercera casilla de `tareas/marca-del-medio.md`**, y llega con lo que
dejaron las dos primeras: el inventario (§4.51) y el criterio de parada
(`ENCINA-OS.md` D22, las tres pilas). Lo que faltaba por decidir era **hasta
dónde llega el reempaquetado**, y eso no se podía decidir sin contestar antes lo
que §4.51 dejó `[OMIT]` a propósito. Se contesta entero **sin arrancar nada y
sin gastar VM**.

**La ISO que se lee sigue siendo la misma, y por huella:**

```
1224b5b17b559007071dee8fcaa620ff28cc3d8361eb75fdbe4af1eb3401529f   3715366912 bytes
```

#### (a) LOS DOS `[OMIT]` DE §4.51, CONTESTADOS — y el primero estaba MAL PLANTEADO

**El snap se identifica, y por eso las respuestas son sobre ESTE binario y no
sobre «el instalador de Ubuntu» en general.** `meta/snap.yaml` de
`ubuntu-desktop-bootstrap_495.snap` dice `version: 0+git.4bc1f4077`; ese commit
(`4bc1f4077ec85b42e222a7f10a5c99c11fbe9a4f`, **2026-02-05**) es de la rama de
empaquetado, y su `snap/snapcraft.yaml` declara con qué fuente se compiló:
`source-commit: f32962636fbf4bb445c8e221c718dbee3c57edf1`. Todo lo de abajo está
leído **ahí**, no en `main`.

**1. «¿Quién rellena `{{ DISTRO }}`, `/cdrom/.disk/info` o `/etc/os-release`?»
— NINGUNO DE LOS DOS. La pregunta estaba mal hecha.** En
`packages/ubuntu_bootstrap/lib/slides/slides_provider.dart` de ese commit:

```dart
final slidesProvider = Provider(
  (ref) => SlidesModel(flavorName: ref.watch(flavorProvider).displayName),
);
…
final flavorSpecificContent = content.replaceAll('{{ DISTRO }}', flavorName);
```

y `displayName` es **una constante compilada dentro del binario**:
`enum UbuntuFlavor { …, ubuntu('Ubuntu'), … }`. Quién elige el sabor es
`FlavorService._loadFlavor()`, que mira la clave `flavor` del whitelabel y, si no
nombra uno de los **once** sabores de Ubuntu, devuelve `UbuntuFlavor.ubuntu`. O
sea que **`{{ DISTRO }}` no puede decir «Encina OS» de ninguna manera**: no hay
fichero del medio que lo rellene, y la única llave que existe es una lista
cerrada de sabores de Ubuntu. **Consecuencia práctica: las diapositivas no se
parchean, se sustituyen enteras.**

**Y de paso se corrige a §4.51e, que había leído mal el binario:** allí se
apuntaron `_readProductName` y `_parseProductName` como pistas de que el nombre
salía de `os-release`. Leído el código, `_readProductName` está en
`identity_model.dart` y **lee el DMI de la máquina**
(`/sys/class/dmi/id/product_name`) para proponer un nombre de equipo. No tiene
nada que ver con el nombre del sistema. Era una deducción por el nombre de una
función, que es exactamente lo que este proyecto dice que no vale.

**2. «¿El `whitelabel.yml` se puede apuntar desde fuera del snap?» — SÍ, y es la
puerta que decide toda la casilla.**
`packages/ubuntu_provision/lib/src/services/config_service.dart`, en ese mismo
commit:

```dart
static const _extensions = ['yaml', 'yml'];
static const _filename = 'whitelabel';
static const whiteLabelDirectory = '/usr/share/desktop-provision/';
…
static String? lookupPath(FileSystem fs) {
  for (final ext in _extensions) {
    final path = join(
      Platform.environment['DESKTOP_PROVISION_PATH'] ?? whiteLabelDirectory,
      '$_filename.$ext',
    );
    if (fs.file(path).existsSync()) return path;
  }
  return null;
}
```

Lo que se lee del disco **se mezcla en profundidad sobre lo del snap**
(`mergeConfig`), así que basta con nombrar las claves que cambian. Y **no es una
lectura nuestra del código: es lo que Canonical documenta**, en
`docs/oem-provisioning-24_04_1.md` del mismo repositorio — *«Placing this
`whitelabel.yaml` at `/usr/share/desktop-provision/whitelabel.yaml` on your
LiveCD is sufficient…»*.

**Tres cosas más salieron de leer eso, y las tres son producto:**

- **el título de la ventana del instalador es una clave del whitelabel.** En
  `installer.dart`: `final windowTitle = await configService.get<String>('app-name');`
  y `onGenerateTitle` devuelve ese valor **si no es nulo**; sólo si lo es cae en
  `windowTitle(flavor.displayName)`, que es *«Install Ubuntu»*. O sea que
  `app-name: Encina OS` cambia el título **sin tocar el snap**.
- **las diapositivas se pueden sustituir desde fuera:** `preCache()` cuenta
  directorios en `/usr/share/desktop-provision/slides/N` y **sólo si no
  encuentra ninguno** usa las suyas (*«No custom slides found, using default
  slides.»*).
- **los dibujos de cada página también:** en `page_images.dart`, una ruta que
  **no** empieza por `assets/` se busca en `/usr/share/desktop-provision/images/`.
  Y la mezcla es por clave, así que hay que nombrar `image` **y** `image-dark` de
  cada página: cambiar sólo la primera deja el dibujo de Canonical en modo
  oscuro.

**EL CONTROL, y es lo que separa esto de una lectura de internet: las cadenas
están en el binario que viaja en ESTE medio.** Sobre
`bin/lib/libapp.so` sacado del snap del propio `1224b5b1…`:

```
/usr/share/desktop-provision/      1
DESKTOP_PROVISION_PATH             1
whitelabel                         1
app-name                           1
mode                               1
```

y una inventada, `/usr/share/bellota-provision/`, **0**. Además
`meta/snap.yaml` dice `confinement: classic`, que es lo que hace que ese
`/usr/share` sea **el de la sesión viva de verdad** y no uno privado del snap.

#### (b) POR DÓNDE ENTRA LA MARCA SIN REHACER `minimal.squashfs`

§4.51 dejó escrito que el fondo de la sesión viva exige *«rehacer una capa de
1,69 GB»*. **Eso era verdad de la capa, no del medio.** Leyendo
`scripts/casper` del initrd de este mismo medio:

- **el medio NO lleva `layerfs-path=` en la línea del núcleo.** Buscado en los
  tres sitios donde podría estar: el `grub.cfg` del árbol ISO —que es el único
  `.cfg` del medio—, la **ESP** (particion `0xef`, 14 144 sectores, FAT12, y
  dentro sólo `EFI/`) y el resto de la imagen. **0 apariciones.**
- sin `LAYERFS_PATH`, `setup_unionfs` entra por su rama de «no multi-capa» y
  **monta TODOS los `*.squashfs` del directorio** —aquí **21**—, en orden de
  glob y **poniendo cada uno DELANTE** del anterior:

```sh
rofslist="${croot}${imagename} ${rofslist}"
…
for mount in $rofslist; do mounts="$mounts:$mount"; done
mount -t overlay -o "upperdir=/cow/upper,lowerdir=$mounts,workdir=/cow/work" …
```

  y en `overlayfs` **el primero de `lowerdir` es el que manda**. O sea: **el
  último por orden alfabético gana**. De ahí el nombre de la capa,
  `zz-encina.squashfs`, que no es tipográfico: es la única razón por la que tapa
  en vez de quedar tapada.

**El control de esa lectura, porque una lectura de código no es una medición:**
si el orden alfabético mandara de verdad, `minimal.standard.squashfs` estaría por
encima de `minimal.standard.live.squashfs` (`l` < `s`), que es al revés de lo que
parecería sensato — así que había que ver si eso rompe algo. **No rompe nada
porque las capas son disjuntas:** de **46 978** ficheros regulares en
`minimal.standard` y **48 367** en `minimal.standard.live`, sólo **51** están en
las dos, y son todos cachés (`ld.so.cache`, `gschemas.compiled`,
`var/lib/dpkg/status`, perfiles de AppArmor de snaps). Y hay una comprobación de
producto que apunta al mismo sitio: **la sesión viva del medio se ve en español**,
lo que exige que `minimal.es.squashfs` esté montada, y con `layerfs-path=` no lo
estaría.

**Lo que esto compra, en números:** los nueve ficheros de presentación y los
quince dibujos que hay que cambiar viven **todos** en `/casper/minimal.squashfs`,
**1 692 274 688 bytes**. La capa que los tapa pesa **3 084 288 bytes**. Es
**549 veces menos**.

**Y lo que NO compra, dicho antes de que alguien lo descubra tarde:** si algún
día el `grub.cfg` llevara `layerfs-path=`, la capa dejaría de montarse **y no
fallaría nada**: el medio volvería a decir Ubuntu en silencio. Es la peor forma
de fallar que hay, y por eso el nombre y el mecanismo están escritos en la
cabecera de los dos guiones y aquí.

#### (c) LO QUE SE HA CONSTRUIDO

**`imagen/capa-marca.sh`**, que fabrica `zz-encina.squashfs` en el Mac, con **4
controles delante y 4 comprobaciones detrás**, todos con sus dos respuestas:

```
--- (a) el orden de montaje de casper deja la capa de Encina la primera
  [OK]    sobre las 21 capas del medio: 'zz-' queda la primera de lowerdir y 'aa-' NO (queda /minimal.zh.squashfs)
--- (b) el .disk/info de Encina da «Install Encina OS» y el del medio no
  [OK]    Name=Install Encina OS  (el del medio da: Install Ubuntu 24.04.4 LTS)
--- (c) el instalador de ESTE medio lleva dentro el mecanismo de marca blanca
  [OK]    ubuntu-desktop-bootstrap_495.snap: estan las cuatro cadenas, una inventada NO esta, y es 'confinement: classic'
--- (d) cada sustitucion tapa un fichero que EXISTE en las capas del medio
  [OK]    las 15 sustituciones tapan ficheros que estan entre las 182625 rutas del medio, y una ruta inventada no aparece
…
  zz-encina.squashfs: 3084288 bytes  sha256 ef15c522b0899f6d…
--- los mismos ficheros, y los mismos bytes
  [OK]    30 ficheros, ni uno mas ni uno menos, y las 30 huellas cuadran
  [OK]    quitando una linea, la comparacion lo dice
  [OK]    ni un fichero con dueno distinto de 0/0
  [OK]    ef15c522b0899f6d… las dos veces
  [OK]    zz-encina.squashfs: va detras de los «minimal.*» del medio
```

**El control (d) es el que más vale y no estaba previsto:** una sustitución que
no tapa nada es un fichero de más en el medio y un «hecho» que no ha pasado. Se
comprueba contra las **182 625** rutas reales de las capas del medio.

**Dentro de la capa, 30 ficheros:** el `os-release`, el `lsb-release`, `/etc/issue`,
`/etc/issue.net`, el `.desktop` de la sesión Wayland y el tema de texto de
Plymouth; `/usr/share/desktop-provision/` con `whitelabel.yml`, **tres
diapositivas propias** en `es_ES` y `en_US` y su dibujo; y **quince activos
gráficos de Canonical sustituidos por bytes en su misma ruta** —el fondo
`warty-final-ubuntu.png`, el `ubuntu-logo.png` de GDM, los doce tamaños de
`ubiquity.png` de Yaru y el `view-app-grid-ubuntu-symbolic.svg` del botón de la
rejilla—, más el `encina-logo.svg` que hace falta para que `LOGO=encina-logo`
resuelva a algo.

**El fondo se cambia por el FICHERO y no por el ajuste, y eso no es pereza:** el
`10_ubuntu-settings.gschema.override` que lo nombra está **compilado** dentro de
`gschemas.compiled`, así que reescribirlo no sirve de nada sin volver a compilar
los esquemas, y eso exige un Linux. Tapar el fichero al que apunta hace lo mismo
y cuesta cero.

**`fabricar-iso.sh` pasa de modificar dos ficheros a modificar tres**
—`/boot/grub/grub.cfg` (ahora también el `menuentry`), `/.disk/info` y
`/md5sum.txt`— y a añadir la capa. Comprobado contra la ISO oficial, pieza a
pieza, sin fabricar la entrega:

```
grub.cfg:  lineas cambiadas 4 (dos lineas), y «Ubuntu» aparece 0 veces
md5sum.txt: dos lineas rehechas (57150973… -> e7e098ae… y 606dfb43… -> 5b4ffae2…)
            y una anadida; 266 -> 267 lineas, diff = 5
```

**El `.disk/info` de Encina son 43 bytes y valen TRES cosas, no una**, y las tres
están leídas en el casper de este medio:

```
Encina OS 0.2.1 - Release arm64 (20260210)
   -> 25adduser:  RELEASE=«Encina OS»  ->  Name=Install Encina OS
   -> casper:     FLAVOUR=«encina»     ->  usuario y nombre de maquina de la sesion viva
   -> 57pollinate: SERIAL=«20260210»   ->  por eso se conserva el parentesis del final
```

#### (d) EL CONTROL DE VERDAD: EL INVENTARIO, ANTES Y DESPUÉS

Se fabricó **un medio de control** —la ISO oficial con los tres ficheros
cambiados y la capa dentro, **sin** `/encina-repo`, en el borrador y borrado
después— sólo para poder medir el después sin gastar la vuelta de la entrega, que
se paga una sola vez y va detrás de la casilla 4.

```
                                    ANTES (1224b5b1)   DESPUES (medio de control)
apariciones de la marca de Ubuntu         31                    24
sitios que YA NO la dicen                 10                    19
controles correctos / fallos             6 / 0                 6 / 0
```

**Y los OCHO sitios que dejan de decirlo, nombrados uno a uno**, que es lo que
pedía la casilla:

| Sitio | Antes | Después |
|---|---|---|
| `/boot/grub/grub.cfg` | `menuentry "Try or Install Ubuntu"` | `menuentry "Probar o instalar Encina OS"` |
| `/.disk/info` | `Ubuntu 24.04.4 LTS "Noble Numbat" …` | `Encina OS 0.2.1 - Release arm64 (20260210)` |
| el `.desktop` del instalador | `Name=Install Ubuntu 24.04.4 LTS` | `Name=Install Encina OS` |
| `os-release` `PRETTY_NAME` | `"Ubuntu 24.04.4 LTS"` | `"Encina OS 24.04 LTS"` |
| `os-release` `NAME`/`LOGO` | `NAME="Ubuntu" LOGO=ubuntu-logo` | `NAME="Encina OS" LOGO=encina-logo` |
| `/etc/issue` | `Ubuntu 24.04.4 LTS \n \l` | `Encina OS 24.04 LTS \n \l` |
| la sesión Wayland | `Name=Ubuntu` | `Name=Encina OS` |
| el tema de texto de Plymouth | `Name=Ubuntu Text  title=Ubuntu 24.04` | `Name=Encina OS Text  title=Encina OS 24.04` |

**Son ocho y el número baja siete, y la diferencia no es un error: es pila C
funcionando.** La línea de `os-release` sigue contándose como aparición porque
**dice `ID=ubuntu`**, que D22 manda dejar. Un inventario que no la contara
estaría escondiendo justo la incoherencia que D22 declaró a propósito.

**Y dos ruidos del medio de control, dichos para que no se lean como resultado:**
la línea de `/encina-repo/` pasa de «29 ficheros» a «0» porque el medio de
control no lleva el repositorio —no es un cambio de marca—; y ese medio se
fabricó con la capa **antes** de fijarle la fecha, o sea con la huella
`a4947f30…` en vez de `ef15c522…`. **El contenido es el mismo fichero a fichero**
—lo único que cambia son las marcas de tiempo de los inodos—, así que el
inventario mide lo mismo; pero la huella de aquel medio no es la que saldrá.

#### (e) CUATRO DEFECTOS DE LOS INSTRUMENTOS, y todos salieron de USARLOS

Los dos primeros los sacó la primera pasada del después, y los dos habrían
dejado la casilla con un verde falso o un rojo falso:

1. **El inventario contaba SITIOS y no VALORES, así que el número no podía bajar
   nunca.** `marca()` emitía `[AVISO]` por cada sitio inventariado, dijera lo que
   dijera: un medio cuyo `grub.cfg` ya pone «Probar o instalar Encina OS» seguía
   sumando una aparición. **El instrumento no sabía decir que el trabajo estaba
   hecho** — que es exactamente para lo que existe, comparar un medio antes y
   después. Ahora lo que decide es el valor medido, y hay dos contadores.
2. **El control (b) caducó justo al avanzar el trabajo.** Su `.disk/info`
   inventado decía `Encina OS 0.3 LTS …`; el día que el medio empezó a llevar de
   verdad un `.disk/info` de Encina, los dos daban «Encina OS» y el control salió
   **`[FALLO] el calculo de RELEASE da lo mismo con cualquier .disk/info`**. Un
   control que se rompe cuando el producto mejora no es un control: el fichero de
   prueba pasa a decir `Bellota 9.9 LTS`, que no puede salir de ningún medio real.

**Y un tercero, del guion NUEVO, que habría reventado la definición de terminado
de la ISO entera sin decir de dónde venía:** la capa **no era reproducible**. Dos
pasadas seguidas, sin tocar nada, daban `a4947f302efab6a1…` y
`63218c57e35c38cb…`. `mksquashfs` guarda **la hora de creación del sistema de
ficheros y la de cada inodo**, y las de los inodos las pone `cp` al copiarlos. Se
fija la misma fecha que ya usa `fabricar-iso.sh` para lo que añade —la de
modificación de la ISO oficial, `1770687951`— con `-mkfs-time`, `-inode-time` y
`-root-time`, y **el control se mete dentro del guion**: fabrica la capa dos
veces y compara. Ahora da `ef15c522b0899f6d…` las dos. Si esto se hubiera colado,
el `[FALLO]` habría salido tres pasos más abajo, en la huella de la ISO, y habría
parecido un problema de `xorriso`.

**Y una cuarta, que es del inventario y se arregló con las dos primeras:** leía
`/usr/lib/os-release` de `minimal.squashfs` y punto. Sobre un medio con capa de
marca eso es **el fichero tapado**: habría dicho `NAME="Ubuntu"` de un medio que
en pantalla dice Encina. Ahora extrae primero la capa de Ubuntu y **encima** las
de marca, que es el mismo orden con el que casper monta el overlay.

#### (f) LO QUE SIGUE SIN HACERSE, CON SU NOMBRE

- **El splash del arranque.** `watermark.png` (248×87, `bfc97707…`) y
  `bgrt-fallback.png` (128×128, `0d4f0416…`) siguen siendo el logotipo de Ubuntu.
  Viven **en el initrd**, o sea antes de que exista ninguna capa, así que la vía
  de esta casilla no los alcanza: hay que reescribir el `initrd`. Es pila A **y**
  pila B, y es **lo primero que se ve**.
- **Los logotipos dentro del snap** —`logo-light.svg`, `logo-dark.svg`,
  `mascot*.svg`, `ubuntu_pro.svg`, `ubuntu_certified.svg`— siguen dentro. Lo que
  se ve se cambia por `whitelabel.yml`; los ficheros **viajan igual**, y eso es lo
  que la pila B de D22 dice que no debería.
- **`/.disk/release_notes_url`** sigue apuntando a `ubuntu.com`. No se ha
  inventado una URL propia porque no existe: se deja dicho, no resuelto.
- **Los seis `ubiquity.svg` de Humanity** y los dos simbólicos de Yaru
  (`ubiquity-symbolic.svg`, `view-app-grid-ubiquity-symbolic.svg`) no se tapan:
  Humanity no es el tema de la sesión y no hay simbólico propio dibujado.
- **El nombre del volumen** es la casilla 4 y sigue diciendo `Ubuntu 24.04.4 LTS
  arm64`.
- **`[OJOS]` — nadie ha visto nada de esto en pantalla.** Todo lo de arriba está
  leído y medido en ficheros. Que la sesión viva se vea con el fondo de Encina,
  que el icono ponga «Instalar Encina OS» y que el instalador titule «Encina OS»
  sólo lo dice arrancar la ISO, y eso es de Jorge y va en la vuelta única, detrás
  de la casilla 4.

---

### 4.53 EL NOMBRE DEL VOLUMEN: 88 bytes cambian de sitio y nada más — y lo que podía tumbar la casilla estaba en el GRUB firmado, que busca POR FICHERO y no por etiqueta (2026-08-17)

> **ENMIENDA DEL 2026-08-20: LA DERIVACIÓN QUE ESTA MEDICIÓN UNIÓ A PROPÓSITO SE
> HA ROTO, y no por gusto: quedó medido que NO CABE** (§4.57e/f). El instalador
> exige un **nombre en clave entrecomillado** en `.disk/info`, y con cualquiera de
> verdad el `Volume id` derivado se pasa de los **32 bytes** del PVD —§4.56q midió
> que con el de Ubuntu no cabe **ni la cadena vacía** de nombre—.
>
> **Lo que esta medición defendía sigue en pie y NO se ha tirado:** el nombre del
> producto no puede estar escrito en dos ficheros. Por eso el `Volume id` **no se
> escribe: se compone** de la 1ª palabra de `.disk/info` (que sigue siendo la
> única fuente del nombre) más la versión de `encina-meta` (cotejada por huella en
> el paso 2) más la arquitectura. **Y de paso se recupera lo que esta medición
> obligaba a ceder:** el volumen dice **`EncinaOS 0.2.1 arm64`**, nuestra versión,
> en vez de la de Ubuntu.
>
> Lo que se creía —que atar las dos cosas era lo correcto— se queda escrito abajo
> a propósito: era correcto **con la información de entonces**, y lo que lo tumba
> es una restricción que no se conocía.

**Es la cuarta y última casilla de `tareas/marca-del-medio.md`**, y su «hecha
cuando» no es la de las otras tres: *«`xorriso -indev` da un `Volume id` propio
**y el medio sigue arrancando**»*. Cambiarlo es un parámetro de `xorriso` y no
tiene mérito; lo que había que comprobar es **que no se rompe nada**, porque el
nombre del volumen es de las pocas cosas que software ajeno usa para encontrar el
medio. Todo lo de aquí está leído y medido **sin arrancar nada y sin gastar VM**,
sobre el mismo medio que las tres casillas anteriores:

```
1224b5b17b559007071dee8fcaa620ff28cc3d8361eb75fdbe4af1eb3401529f   3715366912 bytes
Volume id: «Ubuntu 24.04.4 LTS arm64»
```

#### (a) QUIÉN USA HOY ESE NOMBRE — se lee ANTES de cambiarlo, y la respuesta es: nadie

Cuatro sitios donde podía estar la dependencia, los cuatro leídos en el código
que **viaja en este medio**, no en internet:

**1. `scripts/casper` y `scripts/casper-helpers` del `initrd`** —sacados
partiendo el `initrd` por su `TRAILER!!!` (byte 60 952 018) y descomprimiendo con
`zstd` el segundo `cpio` que empieza en el 60 952 064, la receta de §4.52—.
**`find_livefs` no busca por etiqueta: busca por CONTENIDO.** Recorre
`/sys/block/*`, monta cada candidato y pregunta `is_casper_path`, que es esto:

```sh
is_casper_path() {
    path=$1
    if [ -d "$path/$LIVE_MEDIA_PATH" ]; then
        if [ "$(echo $path/$LIVE_MEDIA_PATH/*.squashfs)" != "$path/$LIVE_MEDIA_PATH/*.squashfs" ] || …
```

o sea **«¿hay algún `*.squashfs` en `/casper`?»**. Y para desempatar entre dos
medios usa `matches_uuid`, que compara el `UUID` del `initrd` con
`.disk/casper-uuid-*` del medio — **medido, los dos ficheros existen y dicen lo
mismo**:

```
initrd:/conf/uuid.conf          88e2e90e-0b09-4e16-8591-34e7f2de608b
medio:/.disk/casper-uuid-generic 88e2e90e-0b09-4e16-8591-34e7f2de608b
```

**Y las únicas etiquetas que `casper` sí busca son de PERSISTENCIA, no del
medio**: `writable`, `casper-rw`, `home-rw`, `casper-sn`, `home-sn`
(`/dev/disk/by-label/$(root_persistence_label)`). Ninguna es el `Volume id`.

**2. `casper-bottom/41apt_cdrom`**, que era el candidato serio porque ejecuta
`apt-cdrom add` y **apt sí escribe un nombre** en `sources.list`. No lo saca del
volumen: **lo saca de `.disk/info`**, que ya es de Encina desde D23. El guion
monta por RUTA y desactiva la detección automática:

```sh
chroot /root apt-cdrom -o Acquire::cdrom::mount=/cdrom \
                       -o Dir::Media::MountPath=/cdrom \
                       -o Acquire::cdrom::AutoDetect=false -m add
```

y el `libapt-pkg.so.6.0.0` **de este medio** —sacado de `minimal.squashfs`— lo
corrobora, con su control de que la misma búsqueda encuentra lo que sí está:

```
cdrom:        10 cadenas        /.disk        2 cadenas
by-label       0                /dev/disk     0            blkid   0
```

**3. `grubaa64.efi` de la ESP. ERA LO QUE PODÍA TUMBAR LA CASILLA, y estaba sin
medir**: si su configuración empotrada buscara por etiqueta, el nombre del
volumen **sería la cadena de arranque** y cambiarlo dejaría la ISO sin arrancar.
El binario firmado lleva un **`squashfs` empotrado** —el `memdisk`, en el byte
1 586 640, 840 690 bytes, comprimido con `xz`— y dentro está el `grub.cfg` que se
ejecuta antes que ningún otro. **Leído entero, sin tocar el binario:**

```
if [ -z "$prefix" -o ! -e "$prefix" ]; then
	if ! search --file --set=root /.disk/info; then
		search --file --set=root /.disk/mini-info
	fi
	set prefix=($root)/boot/grub
fi
if [ -e $prefix/arm64-efi/grub.cfg ]; then
	source $prefix/arm64-efi/grub.cfg
…
```

**`search --file`, no `search --label`.** El GRUB firmado encuentra el medio
buscando **el fichero `/.disk/info`**, que es exactamente el fichero que este
proyecto ya está reescribiendo. Con el control de las cadenas del propio binario:
`search --label` **0 apariciones**, `--label` **0**, `cd_label` **0**, y el
`Volume id` literal **0**. La única cadena con «Ubuntu» en los 2 443 144 bytes de
`grubaa64.efi` es su propio identificador SBAT
(`grub.ubuntu,2,Ubuntu,grub2,2.12-1ubuntu7.3,…`).

**4. El instalador**, o sea el snap `ubuntu-desktop-bootstrap_495` (109 MB) y la
`subiquity` que lleva dentro. **Todo lo que hace con el medio va por la RUTA
`/cdrom`**, y está nombrado uno a uno:

| Fichero de `subiquity` | Qué usa |
|---|---|
| `server/server.py:73` | `iso_autoinstall_path = "cdrom/autoinstall.yaml"` — el quinto sitio de §4.21c |
| `server/apt.py:242-262` | monta `/cdrom` con `--bind` y escribe `deb [check-date=no] file:///cdrom` |
| `server/controllers/source.py:32` | `/cdrom/casper/install-sources.yaml` |
| `server/controllers/refresh.py:165` | `/cdrom/.disk/info` |
| `server/controllers/install.py:556` | `glob("/cdrom/.disk/casper-uuid-*")` — **desempata por UUID, igual que casper** |
| `common/errorreport.py:395` | `/cdrom/.disk/info` |

**El `Volume id` literal aparece 0 veces en los 6 656 ficheros del snap.** Las 22
menciones de `/dev/disk/by-label` que sí hay son de `pyudev`, `cloud-init`,
`os-prober`, `curtin` **y de los ficheros de ejemplo de `subiquity`**
(`examples/machines/*.json`, datos de prueba): ninguna resuelve el medio vivo.

**Y el remate, sobre las dos capas grandes extraídas enteras** —`minimal.squashfs`
y `minimal.standard.live.squashfs`, 133 140 ficheros regulares—:

```
«Ubuntu 24.04.4 LTS arm64» -> 0 ficheros en las dos capas
control «Ubuntu 24.04.4 LTS» -> 4 ficheros en la capa base (os-release, lsb-release, issue, plymouth)
control (una cadena inventada) -> 0
```

**O sea que el `Volume id` no está escrito en NINGÚN fichero del medio**: sólo en
los descriptores de volumen. Un barrido en crudo de los 3,7 GB de la imagen lo
confirma — **4 apariciones, todas en el byte 40 de un sector de descriptor**.

**Lo que sale a favor, y decide el nombre que se elige:** la tabla de particiones
es **MBR con dos entradas y sin nombres** (`0xcd` y `0xef`), y la única otra
etiqueta del medio es la del sistema de ficheros de la ESP, **`ESP`** —FAT12,
`mkfs.fat`, entrada de raíz con atributo `0x08`, medida—, que no es de Canonical
y no hay que tocar. **El `Volume id` es lo único que un gestor de discos enseña.**

#### (b) LO QUE SE CAMBIA, Y POR QUÉ NO SE ESCRIBE A MANO

`Encina OS 0.2.1 arm64`, **21 bytes de los 32 que admite el campo**. No es una
constante nueva: se **deriva** de dos datos que ya existen, para que no puedan
separarse.

```
marca/disk-info : «Encina OS 0.2.1 - Release arm64 (20260210)»
                   \_____________/                              lo de ANTES del « - »
volid oficial   : «Ubuntu 24.04.4 LTS arm64»
                                      \___/                     la arquitectura
Volume id       : «Encina OS 0.2.1 arm64»
```

#### (c) LA MEDICIÓN: 17 correctas, 0 fallos — y lo que la hace valer es el MEDIO DE CONTROL

Se fabricaron **tres** medios a partir de `1224b5b1…`: dos con el nombre nuevo y
**uno de control con la misma orden de `xorriso` sin `-volid`**. Sin ese tercero
la medición no vale nada, y la primera versión lo demostró: **atribuyó al nombre
dos cosas que pasan igual sin tocarlo**.

```
nuevo1 : c51c542ebe1ad88d… 3715235840 bytes (4 avisos de xorriso)
nuevo2 : c51c542ebe1ad88d… 3715235840 bytes (4 avisos)
control: 776dab0c8ee14971… 3715235840 bytes (2 avisos)
  [OK] las dos pasadas dan la misma huella: el nombre NO reintroduce variabilidad
  [OK] control: xorriso ya avisa 2 veces SIN tocar el nombre -- la infraccion es del de
       Ubuntu, que tampoco cumple ISO 9660 (con el nuestro avisa 4: los mismos 2 mas 2
       del texto nuevo, palabra por palabra el mismo aviso)
  [OK] el nombre no cambia el tamano de la imagen
  (remasterizar encoge 131072 bytes, tambien en el medio de control)
```

**LA COMPROBACIÓN QUE DECIDE, y es la más fuerte que esta casilla podía dar sin
arrancar: en qué se diferencian el medio de control y el nuestro.**

```
BYTES 88
TRAMO 32808..32831   sector 16   en_campo_volid=SI      (3 tramos)
TRAMO 65576..65599   sector 32   en_campo_volid=SI      (3 tramos)
TRAMO 131112..131135 sector 64   en_campo_volid=SI      (3 tramos)
TRAMO 163880..163903 sector 80   en_campo_volid=SI      (3 tramos)
  [OK] 88 bytes distintos en toda la imagen, TODOS dentro del campo del nombre,
       en los sectores 16 32 64 80
```

**88 bytes de 3 715 235 840, y ni uno fuera del campo del nombre.** El resto:

```
  [OK] xorriso -indev lee «Encina OS 0.2.1 arm64»
  [OK] el nombre viejo NO queda ni una vez en la imagen        (4/0 -> 0/4, ascii/ucs2)
  [OK] control: el mismo contador dice 4 y 0 sobre el medio de partida
  [OK] bootaa64.efi / grubaa64.efi / mmaa64.efi intactos
  [OK] forma CON los LBA contra el medio de control: identica
  [OK] la ESP es byte a byte la del medio de partida en sus 14144 sectores
  [OK] 0 anadidos, 0 quitados, 0 modificados en las 531 entradas del medio
  [OK] control: con una huella saboteada, la comparacion la senala
  [OK] las 266 lineas de md5sum.txt siguen cuadrando sin rehacerlo
```

**La última línea es una diferencia de fondo con las otras casillas: cambiar el
nombre NO TIENE PRECIO.** `md5sum.txt` cubre ficheros, y el `Volume id` no lo es,
así que —al revés que el `grub.cfg` y el `.disk/info`— no hay que rehacer nada
para que la comprobación de integridad del propio medio siga cuadrando.

**Y el `[OJOS]` va escrito y no disimulado: que arranque no lo dice ningún guion.**
Lo que está medido es que **ninguno de los cuatro mecanismos que encuentran el
medio mira la etiqueta**, y que la cadena de arranque —MBR, El Torito, la ESP y
los tres binarios firmados— sale **byte a byte idéntica**. Arrancarlo es de la
vuelta única.

#### (d) LOS DOS BLOQUES NUEVOS DE `fabricar-iso.sh`, EJECUTADOS — porque el guion entero HOY NO SE PUEDE EJECUTAR

`fabricar-iso.sh` se niega en su paso 2: exige `encina-branding` **0.1.15** por
huella y ese `.deb` no está en el disco. O sea que los dos bloques nuevos —el 5e,
que deriva el nombre, y el 11, que lo comprueba— **se habrían quedado sin ver
pasar**, que es justo lo que este proyecto no admite. Se ejecutan **las líneas
literales del fichero**, recortadas por sus marcas y alimentadas con un andamio,
y **cada una con el caso en el que tiene que negarse**:

```
  bloque 5e: lineas 341..389    bloque 11: lineas 630..700
  [OK]    sale «Encina OS 0.2.1 arm64», derivado y no escrito a mano
  [OK]    se niega: un nombre que dice Ubuntu no pasa (pila A de D22)
  [OK]    se niega: no trunca en silencio el campo del PVD
  [OK]    pasa, y dice en cuantas copias
  [OK]    se niega sobre un medio que no lleva el nombre puesto
  5 correctas, 0 fallos
```

**Y los dos defectos que sacó, los dos al ejecutarlo y ninguno visible leyéndolo:**

1. **El nombre se cortaba por número de palabras, así que un producto más largo
   salía TRUNCADO EN SILENCIO.** La primera versión hacía `cut -d' ' -f1-3` sobre
   `.disk/info`; con `Encina OS Distribucion Nacional 9.9.9 …` dentro, el control
   de los 32 bytes **no llegaba a dispararse** porque el corte ya había tirado la
   mitad del nombre: salía `Encina OS Distribucion arm64` y el guion decía `[OK]`.
   Se corta por el separador `« - »`, que es lo que el propio formato de
   `.disk/info` usa para separar el producto del resto.
2. **El número de copias del descriptor NO es constante, y calibrarlo contra la
   ISO oficial hacía que el bloque fallara SIEMPRE.** Medido en las tres imágenes:

```
ISO oficial de Canonical      2 primarios (16, 32)  + 2 Joliet (18, 33)
ISO que sale de fabricar-iso  4 primarios (16, 32, 64, 80) + 0 Joliet
```

   O sea que **remasterizar duplica los descriptores primarios y se lleva por
   delante el Joliet**, y eso **ya pasaba desde E3 sin que nadie lo hubiera
   medido**: el `Volume id` Joliet de la ISO oficial es
   **`Ubuntu 24.04.4 L`** —truncado a los 16 caracteres del límite de Joliet— y
   en los medios de este repositorio **no existe**. Para la casilla sale a favor:
   hay **un solo** nombre que cambiar. Pero el bloque no puede depender de un
   número: **lee TODOS los descriptores de la imagen construida y exige que todos
   los primarios digan lo nuestro y que ninguno diga Ubuntu**, con el control de
   que el mismo lector encuentra los 4 de la oficial y los 4 dicen Ubuntu. Buscar
   la cadena entera tampoco habría valido si el Joliet volviera: su nombre va
   truncado.

**El orden de las opciones de `xorriso` también se ha visto pasar, y no se ha
supuesto:** la secuencia real del guion —`-boot_image any replay`, `-overwrite
on`, `-volid`, los seis `-map` y los dos `-alter_date_r`— produce los **4
descriptores primarios diciendo `Encina OS 0.2.1 arm64`**. Ni los `-map` ni los
`-alter_date_r` posteriores lo pisan.

#### (e) EL CONTROL DE PRODUCTO: EL INVENTARIO, ANTES Y DESPUÉS

`imagen/inventario-marca.sh --sin-capas` sobre el medio de hoy y sobre un medio
de control con el nombre nuevo. Los planos 2 y 3 salen `[OMIT]` a propósito —no
es un aprobado—, porque lo que esta casilla toca es el plano 1:

```
                                          ANTES (1224b5b1)   DESPUES
apariciones de la marca de Ubuntu (plano 1)      9                7
sitios inventariados que YA NO la dicen          0                2
controles correctos / fallos                   3 / 0            3 / 0
```

**Los dos que dejan de decirla son el volumen ISO 9660 y `/.disk/info`**, y sólo
el primero es de esta casilla: el segundo ya lo había cerrado D23. El instrumento
no necesitó ningún cambio — desde §4.52e lo que decide es **el valor**, y un
`Volume id` que no dice Ubuntu deja de contar solo.

#### (e bis) POR QUÉ ESTA MEDICIÓN NO DEJA GUION, y no es un descuido

§4.51 dejó `inventario-marca.sh` y lo dijo con su motivo —§4.27 había leído un
medio a mano y no dejó ninguno—, así que aquí toca justificar lo contrario. **El
instrumento que se queda es el propio `fabricar-iso.sh`**: los pasos 5e y 11 se
ejecutan **en cada construcción**, que es exactamente cuando hay algo que
comprobar. Los dos guiones que se usaron hoy —el que fabrica el medio de control
y compara byte a byte, y el banco que ejecuta los dos bloques— son **de un solo
uso y no se versionan**: el primero contesta una pregunta que ya está contestada
(*«¿cambiar el nombre mueve algo más?»*), y el segundo **deja de tener sentido en
cuanto exista `encina-branding` 0.1.15**, porque entonces el guion entero se
puede ejecutar y el banco sería código muerto que hay que mantener. Lo que sí se
queda, y es lo que se podría necesitar, son **sus salidas literales, arriba**.

#### (f) LO QUE SIGUE SIN HACERSE, CON SU NOMBRE

- **El `[OJOS]`: nadie ha arrancado nada.** Va en la vuelta única, con el de la
  casilla 3.
- **El splash del arranque.** `watermark.png` (248×87, `bfc97707…`) y
  `bgrt-fallback.png` (128×128, `0d4f0416…`) siguen siendo el logotipo de Ubuntu,
  viven en el `initrd` y ninguna capa los alcanza. **Es lo primero que se ve.**
- **`/.disk/release_notes_url`** sigue apuntando a `ubuntu.com`.
- **Los logotipos dentro del snap firmado** siguen viajando aunque ya no se vean.
- **El Joliet que la remasterización se lleva por delante** desde E3: medido hoy,
  **no decidido**. Hoy juega a favor —un nombre menos que cambiar— pero significa
  que un Windows que abra la ISO no ve los nombres largos de Joliet, sino los de
  ISO 9660. Nadie lo ha mirado y no se da por bueno.

---

### 4.54 LA VUELTA ÚNICA: la ISO sale reproducible a la primera — y al ARRANCARLA se cae la premisa de la casilla 3: LA CAPA NO SE MONTA NUNCA (2026-08-17)

**La ISO se refabricó y se arrancó, que es lo que ninguna de las tres casillas
anteriores podía hacer.** Los pasos 1 y 2 salieron limpios y a la primera. El
paso 3 —arrancarla y mirarla— **tumba la casilla 3 entera**: los 31 ficheros de
`zz-encina.squashfs` **no llegan al sistema en marcha**, y no por un descuido de
montaje sino porque **`casper` de este medio no mira los `*.squashfs` de
`/casper`**. Lo que sigue está medido dentro del invitado, no deducido.

#### (a) PASO 1 — `encina-branding` 0.1.15, CONSTRUIDO Y COTEJADO POR HUELLA

No hizo falta paso aparte: `construir-todo.sh` lo construye en su paso 3, desde
`git archive HEAD`, y lo coteja contra `repo-manifiesto.tsv` **por huella y por
tamaño** antes de gastar la cosecha y la ISO.

```
        03-construir.sh            35 comprobaciones, 0 fallos
        07-firefox-construir.sh    39 comprobaciones, 0 fallos
        10-meta-construir.sh       14 comprobaciones, 0 fallos
        [OK]  encina-branding_0.1.15_all.deb       6d9fcd64aa40…  6948796 bytes
        [OK]  encina-firefox-native_0.2.1_all.deb  640f508e3802…    10876 bytes
        [OK]  encina-meta_0.2.1_all.deb            204081f0ff3c…     6904 bytes
```

#### (b) PASO 2 — DOS PASADAS, LA MISMA HUELLA, CON SU CONTROL

```
ac175f648b6406bd324268e09552fdfea1eefc23845be80afda055c4e87a968b  pasada 1
ac175f648b6406bd324268e09552fdfea1eefc23845be80afda055c4e87a968b  pasada 2
3 721 265 152 bytes las dos · 66 [OK] cada una · commit b9b0de09
CONTROL: contra 1224b5b1… la misma comparación dice DISTINTAS
```

Los dos `[FALLO]` de cada registro son **el control anunciado** de
`cosechar-repo.sh`: la primera orden sale con 27 de 28 a propósito porque aún no
está AutoFirma. **Y los bloques 5e y 11, que nunca habían corrido dentro del
guion entero, pasaron en su sitio:**

```
== 5e.  [OK] Volume id: «Ubuntu 24.04.4 LTS arm64» -> «Encina OS 0.2.1 arm64» (21 bytes de 32)
== 11.  [OK] control: el lector encuentra 4 descriptores en la ISO oficial (2 primarios) y los 4 dicen Ubuntu
        [OK] los 4 descriptores primarios dicen «Encina OS 0.2.1 arm64», y ninguno de los 4 dice Ubuntu
```

El nombre se **predijo antes de mirarlo** derivándolo a mano de `marca/disk-info`
y salió el mismo. Los avisos de `xorriso` fueron **cuatro líneas, dos de cada
tipo**, o sea la misma infracción que hereda del nombre oficial y **ni una más**.

#### (c) LOS CUATRO MECANISMOS DE D23, LEÍDOS EN EL MEDIO FINAL POR CUENTA PROPIA

| Mecanismo | Lo que dice el medio |
|---|---|
| `grub.cfg` | `menuentry "Probar o instalar Encina OS"` + `locale=es_ES.UTF-8` |
| `/.disk/info` | 43 bytes: `Encina OS 0.2.1 - Release arm64 (20260210)` |
| capa | `/casper/zz-encina.squashfs`, 3 084 288 bytes |
| `Volume id` | `Encina OS 0.2.1 arm64` |

Con el control de que el mismo lector saca `Ubuntu 24.04.4 LTS "Noble Numbat" -
Release arm64 (20260210)` de la ISO oficial. **Y el inventario, mismo instrumento
sobre los dos medios reales:** `1224b5b1…` da **31** apariciones y 10 sitios
limpios; `ac175f64…` da **23** y **20**. 6 controles correctos y 0 fallos en los
dos lados.

#### (d) PASO 3 — Y AQUÍ SE CAE TODO: LA CAPA NO SE MONTA

VM `encina-marca-ac175f64`, creada desde cero con el `config.plist` escrito a
mano, la ISO por **enlace duro** (inodo 90226780, **2 enlaces**, 0 bytes) y
**ningún `CIDATA`**. Control de la trampa 16 recogido **en el momento**, porque
`debug.log` es un volátil:

```
-append 0 · media=disk 1 · media=cdrom 1 · CIDATA 0 · -kernel 0 · -initrd 0
CONTROL: 'edk2' en el mismo fichero -> 1   (el grep no está mudo)
```

O sea que **nada se le inyecta**: lo que arranque sale de dentro de la ISO. Y lo
que contesta la orden que la tarea nombraba, tecleada dentro de la sesión viva:

```
encina@encina:~$ grep zz-encina /proc/mounts
encina@encina:~$ ls -l /usr/share/desktop-provision/
ls: no se puede acceder a '/usr/share/desktop-provision/': No existe el archivo o el directorio
encina@encina:~$ cat /etc/os-release
PRETTY_NAME="Ubuntu 24.04.4 LTS"
NAME="Ubuntu"
LOGO=ubuntu-logo
encina@encina:~$ whoami
encina
```

**Ni una línea.** El directorio de la marca blanca **no existe**, y `os-release`
en marcha dice **Ubuntu** — cuando el inventario, leyendo el fichero de la capa
dentro de la ISO, decía `[OK] PRETTY_NAME="Encina OS 24.04 LTS"`.

#### (e) LA CAUSA, LEÍDA EN EL `casper` DE ESTE MISMO MEDIO

`casper` tiene **dos ramas** para montar las imágenes, y la de abajo —la del glob
`"${image_directory}"/*."${image_type}"`, que es la que §4.52b describía— **sólo
corre si `$LAYERFS_PATH` está vacío**. Con `$LAYERFS_PATH` puesto corre la de
arriba, que **no mira el directorio**: construye la lista **quitando puntos del
nombre**.

```
lowerdir=/minimal.standard.live.squashfs:/minimal.standard.squashfs:/minimal.squashfs
    ^ leído en /proc/mounts del invitado: TRES capas, y son exactamente la cadena
      minimal -> minimal.standard -> minimal.standard.live
```

**Y `LAYERFS_PATH` no viene de donde se buscó:**

```
initrd:/conf/conf.d/default-layer.conf:1:LAYERFS_PATH=minimal.standard.live.squashfs
```

§4.52 buscó la cadena **`layerfs-path`** —la grafía de la línea de órdenes— en el
`grub.cfg`, en la ESP y en el resto de la imagen, y sacó **0 apariciones**. Y era
**verdad**: en la línea de órdenes no está, y el `/proc/cmdline` del invitado lo
confirma (`BOOT_IMAGE=/casper/vmlinuz locale=es_ES.UTF-8 --- quiet splash
console=tty0`). Lo que la búsqueda no podía ver es que **la variable se escribe
`LAYERFS_PATH`, con subrayado, en otro fichero, y vive DENTRO de un cpio
comprimido**. La conclusión que se sacó de aquel cero —*«casper monta los 21
squashfs y el último por orden alfabético manda»*— **es falsa**, y con ella el
`zz-` del nombre, que no sirve de nada.

**La trampa, con su nombre: buscar la grafía de la línea de órdenes y concluir
sobre la variable.** Un mismo ajuste tiene dos nombres —`layerfs-path=` fuera,
`LAYERFS_PATH` dentro— y sólo uno de los dos se buscó.

#### (f) Y UN SEGUNDO HALLAZGO, SIN CAUSA: EL INSTALADOR SE CAE

Entre los 60 s y los 120 s el instalador muestra **«Se produjo un problema»**,
mirado en pantalla y leído por OCR con el control de mirar la captura con los
ojos. **No es la capa**, y eso queda excluido por construcción: la capa nunca se
montó. El servidor de `subiquity` **está sano** —sigue emitiendo eventos de red
una hora después— y su registro **no tiene ni un `Traceback`**; el registro de la
interfaz termina limpio en `Inhibiting Gnome session`. **La causa está SIN
DETERMINAR y no se adivina.** Lo nuevo en este medio respecto a `ac0a5721…`, que
es la única que alguien instaló, son `.disk/info`, el `Volume id`, el título del
menú y los `.deb`; de ésos, el único que la sesión viva lee antes de instalar es
`.disk/info`, **y eso es un candidato, no un resultado**.

**El control que lo separaría no está hecho:** se arrancó `1224b5b1…` en un
bundle idéntico y **su pantalla siguió negra a los 15 minutos** con QEMU vivo, así
que no dice nada. `[OMIT]`. **El control bueno es `ac0a5721…`**, que es la única
conocida-buena, y hay que gastarlo antes de tocar nada.

#### (g) UN DEFECTO DEL BANCO Y UNO DEL GUION, LOS DOS DE HOY

1. **`utmctl start` devuelve 0 cuando falla.** Escribe
   `Error from event: … (OSStatus error -1712.)` por stderr y sale con **código
   0**, así que el `|| fallo` de `construir-todo.sh` **no puede dispararse**; y la
   línea siguiente imprimió `[OK] VMs encendidas: 0` justo después de decir que
   encendía una. El guion acabó culpando a `ssh` —`[FALLO] el constructor no
   contesta`— que manda a mirar al sitio equivocado. **La causa real era UTM con
   la conexión interna caída** (`-609` por AppleScript), y se arregló
   reiniciándolo; el registro quedó consistente por las dos mitades antes y
   después.
2. **El inventario da VERDES FALSOS para todo lo que aporta la capa.** No es un
   defecto de lectura —lee bien el fichero que hay en la ISO— sino de lo que su
   `[OK]` significa: dice «este sitio ya no dice Ubuntu» de ficheros que **el
   sistema en marcha no ve**. Diez y pico de sus 20 «sitios limpios» son de la
   capa. Mientras la capa no se monte, **ese número no describe el producto**.

#### (h) ENMIENDA DEL MISMO DÍA: EL CONTROL SE GASTÓ, LA CAÍDA ES NUESTRA, Y LA CAUSA ESTÁ LEÍDA EN EL CÓDIGO

**(f) decía que el control no estaba hecho y que `1224b5b1…` se quedaba negra. Las
dos cosas eran ciertas y las dos las había roto yo**, con un defecto del banco que
no estaba en ninguna trampa:

> **Los tres bundles que fabriqué compartían los IDENTIFICADORES DE UNIDAD**
> —`…000081` y `…000082`—, porque el guion se clonó con `sed` cambiando nombre,
> UUID, MAC e ISO **y no los `Drive.Identifier`**. El bundle de referencia del
> proyecto (`encina-95758c9e`) usa los suyos, `…071`/`…073`. Con identificadores
> repetidos **la VM arranca y se queda colgada antes de nada**: pantalla negra,
> disco a 0 bloques y el `debug.log` de QEMU **congelado en 2 759 bytes durante
> 10 minutos**, frente a los ~110 KB de una que arranca. Dándoles identificadores
> propios, **arrancó a la primera**.

**Y entonces el control dice lo que hacía falta:**

```
ac0a5721…  (la entregada de E4)   -> el instalador FUNCIONA: «Disposición del
                                     teclado» en español, 2ª de las cinco
ac175f64…  (la de hoy)            -> «Se produjo un problema», reproducible en
                                     dos arranques distintos
```

**O sea que la caída es NUESTRA**, una regresión entre esas dos ISOs.

**LA CAUSA, LEÍDA EN EL CÓDIGO QUE VIAJA EN EL MEDIO** —
`subiquity/server/controllers/refresh.py`, líneas 165-181, leído en el invitado:

```python
info_file = "/cdrom/.disk/info"
...
    with fp:
        info = fp.read()
release = info.split()[1]
return ("stable/ubuntu-" + release, SnapChannelSource.DISK_INFO_FILE)
```

**La SEGUNDA PALABRA de `.disk/info` no es un nombre: es el número de versión, y
con ella se construye el canal de snap del propio instalador.** Comprobado en
frío sobre las tres cadenas, con el control de la oficial:

```
split()[1] = 24.04.4     <-  Ubuntu 24.04.4 LTS "Noble Numbat" - Release arm64 (20260210)
split()[1] = OS          <-  Encina OS 0.2.1 - Release arm64 (20260210)      <- EL NUESTRO
split()[1] = 0.2.1       <-  Encina 0.2.1 - Release arm64 (20260210)
```

Nuestro medio pide el canal **`stable/ubuntu-OS`**. **Es la explicación de por qué
el fallo es SILENCIOSO** —no hay volcado en `/var/crash`, ni error en el
`journal`, ni `Traceback` en el servidor, ni nada por `stderr`: es un controlador
del arranque que no puede resolver su canal, y la interfaz sólo sabe decir «no
estamos seguros de cuál es el error»—.

**LO QUE ESTO NO ES TODAVÍA:** no se ha visto la excepción con estos ojos —el
`grep` de `channel` sobre el registro del servidor da 0 y la consola del invitado
escupe mensajes que arruinan el OCR—. **Mecanismo leído + control que pasa + caso
que falla, pero la prueba final es rehacer el medio con una segunda palabra que
sea una versión y ver arrancar el instalador.** Hasta entonces es la causa
probable, no la causa.

**Y TIENE PRECIO DE PRODUCTO, que es lo que hay que decidir antes de tocarlo:** la
segunda palabra de `.disk/info` la usan **tres** cosas a la vez —el canal de
`refresh.py`, el rótulo del icono (`25adduser` toma las dos primeras palabras) y,
por derivación, el `Volume id`—. O sea que **«Encina OS» no cabe ahí**: hay que
elegir entre `Encina 0.2.1 …` —que deja el `Volume id` idéntico y cambia el rótulo
a «Install Encina 0.2.1»— y meter `LTS`. **Es decisión de Jorge, no del agente.**

**Y una trampa más del pilotaje:** a `=`, `@`, `|` y `&` se suman **`>`, `"`, `[` y
`]`** — no llegan al invitado. Las órdenes con redirección, comillas o índices de
Python **no se pueden teclear**; `script -c <orden> <fichero>` es la vía que sí
funciona para capturar salida. Y `ubuntu-desktop-bootstrap` desde el terminal
**sale en el mismo segundo con código 0**: no lanza una instancia nueva, sólo da
el foco a la que ya corre.

#### (i) LA CAUSA DE (h) ERA FALSA, Y EL EXPERIMENTO QUE LA PROBABA ES EL QUE LA TUMBA

**(h) daba `.disk/info` por causa probable. Se rehizo el medio con la segunda
palabra convertida en versión y EL INSTALADOR SE SIGUE CAYENDO IGUAL.** Se deja
escrito al lado lo que se creía, que es lo que manda el método.

```
.disk/info : «EncinaOS 0.2.1 - Release arm64 (20260210)»
             split()[1] = 0.2.1  ->  canal stable/ubuntu-0.2.1   (ya no «OS»)
             FLAVOUR    = encinaos     rotulo = Install EncinaOS 0.2.1
ISO        : e8a0ead24e3d6358…  3 721 265 152 bytes  ·  67 [OK]
en pantalla: «Se produjo un problema»  <- IGUAL que antes
```

**Lo que estaba bien y lo que estaba mal, separado:** el mecanismo leído en
`refresh.py` **es real** —`release = info.split()[1]` construye el canal de snap—
y `stable/ubuntu-OS` **era un defecto de verdad**, así que el cambio se queda. Lo
que era falso es la **atribución**: no es lo que tira el instalador. Mecanismo
leído + control que pasa + caso que falla **no es una causa**, y aquí está la
prueba de por qué este proyecto no marca una casilla sin verla pasar.

**Y EL BISECADO, que es lo que sí acota** — las tres ISOs arrancadas en bundles
idénticos, todos con identificadores de unidad propios (trampa 32):

| ISO | Qué lleva de más | Instalador |
|---|---|---|
| `ac0a5721…` (2026-08-13) | la entregada de E4 | **funciona** — «Disposición del teclado» |
| `1224b5b1…` (2026-08-15) | `.deb` y seed nuevos, **sin** capa, `Volume id` ni `.disk/info` | **funciona** — misma pantalla |
| `ac175f64…` / `e8a0ead2…` (2026-08-17) | **+ los mecanismos de D23** | **se cae**, reproducible en tres arranques |

**O sea que la regresión está DENTRO del grupo de D23**, y no en los `.deb`, ni en
el seed, ni en el banco. Quedan **tres** sospechosos y ninguno medido:

1. **La PRESENCIA de `/casper/zz-encina.squashfs`** — aunque no se monte. Es el
   candidato más gordo: es lo único que añade un fichero a `/casper`, que es el
   directorio que `casper` y `install-sources.yaml` enumeran.
2. **El `Volume id`** — §4.53a leyó que nadie lo usa, pero eso se midió sobre
   `casper`, `apt-cdrom` y el GRUB firmado, **no sobre el instalador gráfico**.
3. **El resto del contenido de `.disk/info`** — descartada su segunda palabra, no
   el fichero entero.

**EL EXPERIMENTO QUE TOCA, y hay que escribirlo antes de hacerlo:** `fabricar-iso.sh`
no tiene forma de saltarse la capa ni el `Volume id`, así que el bisecado exige
**una bandera por mecanismo** y una construcción por combinación —~20 min cada
una—. El orden barato es empezar por **quitar la capa** dejando lo demás: si el
instalador arranca, es la capa, y entonces el rediseño de la casilla 3 tiene que
resolver **dos** cosas a la vez —que la capa se monte (`layerfs-path=`) y que su
presencia no tire el instalador—.

**Y una cosa que este día deja clara sobre el instrumento:** la comprobación nueva
del paso 5b —que la 2ª palabra sea una versión— **se queda y vale**, aunque no
fuera la causa. Habría cazado `stable/ubuntu-OS` sin gastar un arranque, y eso
sigue siendo cierto.

### 4.55 BISECAR D23: una bandera por mecanismo, y la predicción escrita antes de gastar el arranque (2026-08-19)

**§4.54i dejó la regresión acotada al grupo de D23 y tres sospechosos sin medir.
Bisecarlos exigía algo que el guion no sabía hacer:** fabricar un medio que lleve
tres mecanismos y le falte uno. La capa y el `Volume id` estaban clavados.

#### (a) EL INSTRUMENTO: cuatro banderas, y un paso que lee el producto

`imagen/fabricar-iso.sh` acepta `--sin-capa`, `--sin-volid`, `--sin-info` y
`--sin-menu`; `construir-todo.sh` las pasa **sin interpretarlas**. Sin ninguna
sale el producto. El `locale=es_ES.UTF-8` **no tiene bandera y no es un olvido**:
ya viajaba en `1224b5b1…`, que **arranca**, así que no está bajo sospecha.

**Y con las banderas aparece una trampa que no existía:** todas las
comprobaciones del guion —el `diff` de `md5sum.txt`, la lista de añadidos del
paso 10, los descriptores del 11— **derivan sus expectativas de la misma bandera
que dicen comprobar**. Si `--sin-capa` no hiciera nada, el paso 10 esperaría la
capa, la encontraría, y daría `[OK]`. **Un bisecado entero saldría al revés y
nada lo diría.** De ahí el **paso 13**, que abre la ISO terminada y pregunta qué
lleva sin mirar ninguna variable intermedia, y que **no busca nombres nuestros**:
cuenta los `squashfs` de `/casper`, compara `.disk/info` con el de la oficial y
busca el título **oficial** del menú.

**Ese lector tiene banco propio y cuesta segundos, no 20 minutos**
(`imagen/banco-mecanismos.sh`, y `--leer-mecanismos <iso>` para una suelta). Los
casos son **medios reales con su arranque ya medido**, y el control va dentro:

```
esperado  leido    medio                                que es
0 0 0 0   0 0 0 0  ubuntu-24.04.4-desktop-arm64.iso     la oficial de Canonical
0 0 0 0   0 0 0 0  encina-os-E4-es-0.2.1.iso            ac0a5721: FUNCIONA
0 0 0 0   0 0 0 0  encina-os-E4-es-0.2.1-1224b5b1.iso   1224b5b1: FUNCIONA
1 1 1 1   1 1 1 1  encina-os-0.2.1-encinaos-p1.iso      e8a0ead2: SE CAE
correctas: 4   fallos: 0
```

**CONTROL GASTADO:** con un directorio de medios trucado por enlaces duros —la
ISO oficial con el nombre de la que lleva los cuatro, y al revés— el banco dice
`[FALLO]` **en los dos sentidos** (`0 0 0 0` donde esperaba `1 1 1 1` y al revés)
y sale con código 1.

**Y de paso, un comentario FALSO del propio guion, corregido dejando al lado lo
que decía:** el bloque de la capa afirmaba que *«casper monta todos los
`*.squashfs` de `/casper` en orden alfabético y el último manda»*, que es de
donde salía el `zz-`. §4.54e lo tumbó. La comprobación del nombre se queda —el
día que la capa entre por `layerfs-path=` seguirá haciendo falta que encadene—,
pero ya no miente sobre por qué.

#### (b) LA PREDICCIÓN, ESCRITA ANTES DE CONSTRUIR — y dos lecturas de segundos que la cambiaron de bando

**Primero pensé que la capa NO era la causa**, y por un motivo medido: el único
argumento para sospechar de ella es *«añade un fichero al directorio que `casper`
e `install-sources.yaml` enumeran»*, y de esos dos, **`casper` ya está medido y
NO enumera el directorio** (§4.54e: la rama del glob sólo corre con
`$LAYERFS_PATH` vacío, y no lo está).

**Dos lecturas de la ISO oficial, de segundos, me han cambiado la predicción:**

1. **`install-sources.yaml` no lista ficheros: lista DOS rutas explícitas**
   —`minimal.squashfs` y `minimal.standard.squashfs`, las dos
   `type: fsimage-layered`, con `locale_support: langpack` y **nueve**
   `preinstalled_langs`—. Para servir esos langpacks alguien tiene que
   **localizar `minimal.standard.es.squashfs` y compañía**, y esos nombres **no
   están escritos en ningún sitio del yaml**.
2. **CADA `squashfs` de `/casper` viaja con DOS ficheros acompañantes**, su
   `.manifest` y su `.size`: 21 `squashfs` y sus 21 pares. **`zz-encina.squashfs`
   no tiene ni `zz-encina.manifest` ni `zz-encina.size`** — es el único fichero
   suelto del directorio. Tampoco está en `casper/SHA256SUMS`.

**PREDICCIÓN, y es falsable: con `--sin-capa` el instalador ARRANCA** —o sea, la
capa es la causa—. Lo que creo que pasa, y esto es **deducción, no medición**:
algo del instalador recorre `/casper/*.squashfs` para descubrir las variantes de
idioma, se encuentra un `zz-encina.squashfs` que no tiene `.size` ni `.manifest`,
y revienta antes de la segunda pantalla. Encaja con que el fallo sea **silencioso
y temprano**.

**Si me equivoco y se sigue cayendo**, lo que se aprende es que **no hay tal
tercer consumidor**, la capa queda descartada, y el siguiente es el `Volume id`
—§4.53a midió que nadie lo usa, pero lo midió sobre `casper`, `apt-cdrom` y el
GRUB firmado, **no sobre el instalador gráfico**—.

**Lo que el guion tiene que imprimir si la bandera hace lo que dice** (predicho
también, para que el registro se pueda cotejar sin interpretarlo):
`capa --` en el bloque 0, `md5sum.txt: 2 líneas rehechas, 0 añadidas`,
`modificados exactamente 3`, un fichero añadido menos que en `e8a0ead2…`,
`--sin-capa: /casper tiene los mismos 21 squashfs que la oficial`, y el paso 13
`0 1 1 1`.

#### (c) EL RESULTADO: LA PREDICCIÓN DE (b) ERA FALSA — LA CAPA NO ES LA CAUSA

**Se fabricó `--sin-capa` y el instalador SE SIGUE CAYENDO.** Se deja escrito al
lado lo que se creía, que es lo que manda el método.

```
ISO      : 26bf5442a65efc42…   3 717 595 136 bytes   (los otros tres mecanismos SÍ)
paso 13  : «el medio lleva exactamente lo pedido (capa volid info menu): 0 1 1 1»
en pantalla, a los 110 s: «Se produjo un problema»   <- IGUAL que con los cuatro
```

**Lo que el guion imprimió, cotejado contra lo predicho en (b), palabra por
palabra:** `md5sum.txt: 2 líneas rehechas, 0 añadidas` · `modificados exactamente
3` · `30 ficheros añadidos` (uno menos que con capa) · `--sin-capa: /casper tiene
los mismos 21 squashfs que la oficial` · paso 13 `0 1 1 1`. **Las cinco.** Lo que
falló no fue el instrumento: fue la hipótesis.

**Y el razonamiento que la sostenía, para saber qué parte se cae:** el hallazgo de
que cada `squashfs` viaja con su `.manifest` y su `.size` y que la capa no tenía
ninguno de los dos **sigue siendo cierto** — lo que era falso es que algo del
instalador recorra `/casper` y se atragante con ellos. **No hay tal tercer
consumidor**, y ahora está medido y no deducido: `casper` no enumera (§4.54e),
`install-sources.yaml` lista **dos rutas explícitas**, y quitar el fichero **no
cambia nada**.

**EL CONTROL, Y ES LO QUE HACE QUE ESTO VALGA.** El primer arranque de este medio
dio **pantalla negra con el cursor de X a los 7 minutos**, con la VM en red
(`192.168.64.26` en el `arp` del anfitrión) y el `debug.log` creciendo —o sea, ni
colgada ni la trampa 32—. Eso **no es** el fallo de ayer, así que antes de
escribirlo se gastó el control: **`ac0a5721…` en un bundle fabricado con el mismo
guion nuevo enseña «Disposición del teclado» en español a los ~110 s**. El banco
estaba sano. Y el **segundo** arranque del mismo medio dio «Se produjo un
problema» a los 110 s, o sea que **la pantalla negra no se reprodujo**: queda como
anomalía de un arranque, `[AVISO]`, no como resultado.

#### (d) LA VÍA QUE SE ABRIÓ: HAY TERMINAL DENTRO DE LA SESIÓN CAÍDA, Y LO QUE DICE

Con el diálogo de error en pantalla, **`Alt`+`F2` abre «Ejecutar una orden»**, y
desde ahí `gnome-terminal`. **La sesión viva está entera**: el prompt dice
`encinaos@encinaos`, que de paso confirma otra vez que `.disk/info` funciona.
Desde ahí, leído con estos ojos:

```
/var/crash                                      VACÍO
grep -ril traceback /var/log /var/crash         solo mis PROPIAS ordenes en auth.log
journalctl -m -g Traceback                      idem: NI UN Traceback del instalador
/var/log/installer/                             block/ subiquity-server-{debug,info}.log
                                                ubuntu_bootstrap.log (+ los .PID)
servidor, últimas líneas                        eventos de red, SANO, sin excepción
interfaz, últimas líneas                        ... markConfigured([mirror, proxy, ssh,
                                                snaplist, ubuntu_pro]) · Disabling screen
                                                blanking · Disabling screensaver ·
                                                Inhibiting Gnome session   <- y AHÍ SE CORTA
estado del servidor                             ApplicationState.WAITING,
                                                error: null, nonreportableError: null
```

**O sea que el diálogo sale con `error: null`**, que es exactamente lo que la
pantalla dice con otras palabras: *«no estamos seguros de cuál es el error»*. **Lo
que NO se ha conseguido:** pulsar el botón **«Mostrar registro»** —`Tab` y
`Shift`+`Tab` no mueven el foco visible y el ratón de UTM no llega—, y esa es la
única vía que queda sin agotar dentro de la sesión.

**Y una trampa nueva del pilotaje, medida con su control en la misma orden:
el `_` NO llega al invitado — llega como `?`.**

```
tecleado:  echo A_B-C.D
en pantalla: echo A?B-C.D      ->  A?B-C.D
```

El `-` y el `.` llegan bien, que es el control. Se suma a `= @ | & > " [ ]`. Y
tiene un efecto que puede dar un verde falso: `?` es **comodín del shell**, así
que `tail /var/log/installer/ubuntu?bootstrap.log` **funcionó** —casaba con el
fichero de verdad— y podría haber casado con otro sin que nadie lo notara.

#### (e) EL `Volume id` TAMPOCO ES LA CAUSA — y lo que queda pone en duda cómo se descartó `.disk/info`

```
ISO      : 08392ddc38b02633…   3 721 265 152 bytes   ·  41 [OK]
paso 13  : «el medio lleva exactamente lo pedido (capa volid info menu): 1 0 1 1»
volid    : «Ubuntu 24.04.4 LTS arm64» en los 4 descriptores primarios (comprobado invertido)
en pantalla, 2º arranque, 100 s: «Se produjo un problema»
```

Así que de los cuatro mecanismos de D23 quedan **dos**: el `.disk/info` entero y
el `menuentry` del `grub.cfg`.

**Y AL LLEGAR AQUÍ SE VE UN AGUJERO EN CÓMO §4.54i DESCARTÓ `.disk/info`.** Aquel
experimento cambió la segunda palabra de `OS` a `0.2.1` y, como el instalador se
siguió cayendo, se dio por descartado el fichero. Pero `refresh.py` construye con
esa palabra un **canal de snap**, y:

```
Ubuntu 24.04.4 LTS …  ->  stable/ubuntu-24.04.4     <- existe
Encina OS 0.2.1 …     ->  stable/ubuntu-OS          <- NO existe
EncinaOS 0.2.1 …      ->  stable/ubuntu-0.2.1       <- TAMPOCO existe
```

**Se cambió un canal inexistente por OTRO canal inexistente.** Que el resultado no
cambiara no descarta el mecanismo: descarta *esa* variante. Lo que nunca se ha
probado es un medio cuyo `.disk/info` produzca un canal **que exista**.

**PREDICCIÓN, escrita antes de fabricar `--sin-info`: el instalador ARRANCA.** Es
el único de los dos que queda que el instalador **lee de verdad** —leído en el
código que viaja en el medio, §4.54h—, mientras que el `menuentry` sólo lo lee
GRUB antes de arrancar el núcleo. **Si acierto**, la causa es `.disk/info` y el
precio de producto vuelve a la mesa con una forma nueva: no basta con que la
segunda palabra *parezca* una versión, **tiene que ser la de Ubuntu**. **Si
fallo**, la causa es el `menuentry` —lo que sería un resultado grande y raro— o
hay algo fuera de los cuatro.

#### (f) EL BISECADO CIERRA: LA CAUSA ES `/.disk/info`, Y ESTA VEZ NO ES UNA LECTURA, ES UN EXPERIMENTO

```
ISO                          capa volid info menu   instalador
ac0a5721… (la entregada)      0    0    0    0      FUNCIONA  «Disposición del teclado»
1224b5b1… (.deb y seed)       0    0    0    0      FUNCIONA  (§4.54i)
e8a0ead2… (los cuatro)        1    1    1    1      SE CAE    3 arranques
26bf5442… --sin-capa          0    1    1    1      SE CAE    «Se produjo un problema», 110 s
08392ddc… --sin-volid         1    0    1    1      SE CAE    «Se produjo un problema», 100 s
4f856618… --sin-info          1    1    0    1      FUNCIONA  «Disposición del teclado», 105 s
```

**La única variable que cambia el resultado es `/.disk/info`.** Los otros tres
mecanismos —la capa, el `Volume id` y el `menuentry`— están **exonerados por
experimento**, cada uno con su medio propio y su paso 13 comprobando que el medio
llevaba lo que se pidió.

**Y OJO CON LA DIFERENCIA RESPECTO A §4.54h, que es justo la lección de ayer:**
aquello era *mecanismo leído + control que pasa + caso que falla*, y resultó
falso. Esto es otra cosa: **quitar una pieza y ver arrancar lo que no arrancaba**,
dejando las otras tres puestas. No hace falta leer ni una línea de código para
sostenerlo.

**Lo que sigue SIN estar medido, y no se da por bueno:** *por qué* lo tumba.
`refresh.py` sigue siendo el candidato —y ahora con el agujero de (e) tapado: los
tres valores probados (`OS`, `0.2.1`) daban canales **inexistentes** y el oficial
(`24.04.4`) existe—, pero **eso es la hipótesis, no el resultado**. La prueba es
un medio con `.disk/info` propio cuya segunda palabra sea **la versión de Ubuntu**.

**Una asimetría del banco que conviene tener escrita:** «se ve el instalador» es
una señal **positiva** y basta una vez; «pantalla negra» **no** es un resultado
—apareció en 3 de los medios, incluido uno que luego arrancó—, así que un negro
obliga a repetir y nunca a concluir. Con `--sin-info` hicieron falta **tres
arranques** para verlo.

**EL PRECIO DE PRODUCTO, que vuelve a la mesa y es DE JORGE:** si la hipótesis del
canal se confirma, la segunda palabra de `.disk/info` no puede ser nuestra versión
—`0.2.1`—, tiene que ser **la de Ubuntu** (`24.04.4`). Y esa palabra la usan tres
cosas: el canal, el rótulo del icono (`Install <dos primeras palabras>`) y, por
derivación, el `Volume id`. O sea que el medio se rotularía **«Install EncinaOS
24.04.4»** y el volumen **«EncinaOS 24.04.4 arm64»**. La alternativa es dejar de
derivar el `Volume id` y el rótulo de ese fichero, que es lo que §4.53 unió a
propósito para que no se separaran.

---

### 4.56 LA HIPÓTESIS DEL CANAL: se paga el precio de producto y se escribe la predicción antes de fabricar (2026-08-19, tarde)

**a) LA DECISIÓN, que era de Jorge y está tomada: la segunda palabra es `24.04.4`.**
`imagen/marca/disk-info` pasa de

```
EncinaOS 0.2.1 - Release arm64 (20260210)
EncinaOS 24.04.4 - Release arm64 (20260210)
```

y **sólo cambia esa palabra**: ni el separador ` - `, ni el paréntesis del final,
ni la ausencia de `LTS` y del codename entrecomillado que sí lleva el oficial
(`Ubuntu 24.04.4 LTS "Noble Numbat" - Release arm64 (20260210)`). **Una variable
por experimento**, porque si esto no arranca lo que queda es acotar dentro del
propio fichero y esas tres diferencias son los siguientes sospechosos.

Lo que la palabra arrastra, derivado con el cálculo de `casper-bottom/25adduser`
tal cual viaja en el medio, no deducido de memoria:

```
rotulo -> Install EncinaOS 24.04.4
canal  -> stable/ubuntu-24.04.4
```

Se descartó la tercera vía —romper la derivación y escribir el rótulo y el
`Volume id` aparte— porque §4.53 los unió a propósito y separarlos cuesta trabajo
**sin medir** antes de poder arrancar nada. Queda anotada, no cerrada.

**b) EL AGUJERO DE §4.55e, HECHO CÓDIGO: el paso 5b ya exigía una versión y `0.2.1`
LA PASABA.** Esto no se dedujo, se leyó en el guion: la regla era
`grep -qE '^[0-9]+(\.[0-9]+)*$'`, o sea «que sea un número de versión», y `0.2.1`
lo es. Por eso la comprobación que se escribió en §4.54 para no volver a gastar un
arranque **no cazó nada**: verificaba la forma, no el valor. La regla nueva es que
la segunda palabra sea **la de la base**, porque los únicos `stable/ubuntu-*` que
existen son los de las releases de Ubuntu, y la base es la ISO oficial que el
guion ya tiene abierta.

**Y va con su control, ejecutado ANTES que la medición**, gastado con las dos
palabras que de verdad fallaron:

```
[OK] CONTROL: la regla del canal acepta «24.04.4» y rechaza «0.2.1» y «OS»
```

**c) EL BANCO DE ESA REGLA, y falla en los dos sentidos.** El banco **no recltea**
la regla: la **extrae del guion de verdad** entre sus dos marcas, y si la
extracción sacara menos de 10 líneas se niega a medir —que es la familia de
defecto de §4.54, donde `timeout` no existía en macOS y el banco leyó cuatro
`command not found` como PASA—. Cuatro casos:

```
== extraidas 13 lineas del bloque real de imagen/fabricar-iso.sh
[OK] CONTROL DEL BANCO: el bloque se extrajo del guion, no esta retecleado aqui
  [OK]    «24.04.4» -> acepta
  [OK]    «0.2.1» -> rechaza
  [OK]    «OS» -> rechaza
  [OK]    «24.04» -> rechaza
== 4 correctas, 0 fallos
```

Y gastado contra dos guiones saboteados, porque un banco que sólo sabe decir
«bien» no es un banco:

```
SABOTAJE 1 — regla_canal() { true; }   (el defecto que dejó pasar 0.2.1)
  [OK]    «24.04.4» -> acepta
  [FALLO] «0.2.1» -> acepta, se esperaba rechaza
  [FALLO] «OS» -> acepta, se esperaba rechaza
  [FALLO] «24.04» -> acepta, se esperaba rechaza
== 1 correctas, 3 fallos          salida 1

SABOTAJE 2 — el bloque borrado del guion
  == extraidas 1 lineas
  [FALLO] CONTROL DEL BANCO: no extraje el bloque      salida 1
```

**d) LA PREDICCIÓN, ESCRITA ANTES DE FABRICAR Y ANTES DE ARRANCAR.** Se coteja
abajo, salga como salga, y si sale falsa se queda al lado como se quedó la de
§4.55b.

> **Predigo que el instalador ARRANCA** y que se ve «Disposición del teclado» en
> español, igual que con `--sin-info`, **con los cuatro mecanismos de D23 puestos**
> —capa, `Volume id`, `.disk/info` y `menuentry`—.
>
> **En qué me apoyo, y es una sola cosa:** §4.55f probó por experimento que quitar
> `.disk/info` hace arrancar lo que se caía, y `refresh.py` construye con su
> segunda palabra el canal de snap del propio instalador
> (`"stable/ubuntu-" + info.split()[1]`). `stable/ubuntu-0.2.1` no existe;
> `stable/ubuntu-24.04.4` sí. Si la causa es el canal, ésta es la única palabra
> que hacía falta cambiar.
>
> **Lo que puede tumbarla, y lo digo antes:** que lo que rompa no sea el canal sino
> otra de las tres diferencias contra el oficial —el `LTS` ausente, el codename
> entrecomillado ausente o la forma del separador—, en cuyo caso el medio se caerá
> **igual** y la hipótesis del canal quedará FALSA. Que arranque no probaría que el
> canal existe: probaría que ESTA cadena no lo tumba.
>
> **Y predigo además** que el `Volume id` saldrá `EncinaOS 24.04.4 arm64` y el
> rótulo del icono `Install EncinaOS 24.04.4`, que es el precio pagado.

**e) LO QUE COSTÓ EL BANCO, y la trampa del enlace duro medida en vez de recordada.**
Se borraron las dos ISOs del bisecado ya gastadas (`--sin-capa` y `--sin-volid`,
que ya dieron su dato) con sus dos VMs. **Cada ISO tenía `nlink=2` y el mismo
inodo dentro del bundle de UTM**, o sea que borrar una sola de las dos copias no
habría liberado **nada**:

```
2 90304989 3717595136 medios/encina-os-bisec-sin-capa.iso
2 90304989 3717595136 …/encina-bisec-sin-capa.utm/Data/medio.iso
```

Predicción escrita antes de borrar: **≈6,9 GiB**. Medido: **7,07 GiB** (28 → 35 GiB
libres). Y `utmctl delete` **existe** y desregistra *y* borra el bundle —lo que
explica el fantasma `encina-marca-ac175f64`, que sigue en `utmctl list` con el
bundle borrado a mano—. Las dos mutaciones se verificaron después de pedirlas
(trampa 13), no se dieron por hechas.

**f) LA ISO, y el medio lleva los CUATRO mecanismos.** `d81586ae5db18076…`,
3 721 265 152 bytes, commit `ee88f2a8`. **El mismo tamaño exacto que `e8a0ead2…`
y huella distinta**, que es la tercera vez que pasa y por lo que aquí se compara
por huella y nunca por tamaño. El paso 13 lo lee del medio terminado:

```
[OK]    CONTROL: la regla del canal acepta «24.04.4» y rechaza «0.2.1» y «OS»
[OK]    la 2a palabra es una version: «24.04.4» -> canal stable/ubuntu-24.04.4 (la oficial: «24.04.4»)
[OK]    .disk/info: Name=Install EncinaOS 24.04.4 (el oficial daba: Install Ubuntu 24.04.4 LTS), FLAVOUR=encinaos
[OK]    Volume id: «Ubuntu 24.04.4 LTS arm64» -> «EncinaOS 24.04.4 arm64» (22 bytes de 32)
[OK]    control: sobre la ISO oficial el lector no encuentra ninguno de los cuatro
[OK]    el medio lleva exactamente lo pedido (capa volid info menu): 1 1 1 1
```

El único `[FALLO]` de las cuatro etapas es **el control intencionado** de la
cosecha (la 1ª orden sale incompleta a propósito). Y **`FLAVOUR=encinaos`**: un
**cuarto** consumidor de la primera palabra que no estaba en la lista de tres.

**g) LA PREDICCIÓN DE (d) ES FALSA. LA HIPÓTESIS DEL CANAL ESTÁ TUMBADA.**
Arrancado `encina-canal-d81586ae` desde cero, la sesión llega a escritorio —barra
de GNOME en español, «19 de ago»— y a los ~3 minutos sale **el mismo diálogo**:

```
Se produjo un problema
Lo sentimos, pero no estamos seguros de cuál es el error.
…
sudo ubuntu-bug ubuntu-desktop-bootstrap
```

Con la segunda palabra **idéntica a la del medio oficial** —`24.04.4`, canal
`stable/ubuntu-24.04.4`, el mismo que pide la ISO de Canonical, que funciona— **el
instalador se cae igual**. Así que el canal de `refresh.py` **no es la causa**.

**Lo que se creía y era falso, al lado y sin ordenar:** §4.55f probó por
experimento que `/.disk/info` tumba el instalador, y de ahí se dedujo que lo hacía
**por el canal**. El mecanismo era real y está leído en el fuente; **la atribución
era falsa, otra vez**. Es la segunda vez en tres sesiones que un mecanismo leído
más un caso que falla no dan una causa (§4.54h fue la primera, §4.55b la segunda).
**Lo que la predicción sí acertó** —y estaba escrito antes— es el precio: el
rótulo salió `Install EncinaOS 24.04.4` y el volumen `EncinaOS 24.04.4 arm64`,
exactos. Y también estaba escrito por delante qué la tumbaría: *«que lo que rompa
no sea el canal sino otra de las tres diferencias contra el oficial»*.

**h) LO QUE ESTO ACOTA, Y ES MUCHO: QUEDAN DOS SOSPECHOSOS.** Al igualar la
segunda palabra, las diferencias contra el fichero oficial se han quedado en dos:

```
oficial: Ubuntu   24.04.4 LTS "Noble Numbat" - Release arm64 (20260210)   FUNCIONA
nuestro: EncinaOS 24.04.4                    - Release arm64 (20260210)   SE CAE
         ^^^^^^^^         ^^^^^^^^^^^^^^^^^^
         1. la 1a palabra   2. falta este trozo
```

El separador ` - ` y el paréntesis del final **ya no son sospechosos**: los dos
están en el fichero que se cae **y** en el que funciona, iguales.

**i) EL BOTÓN «Mostrar registro» SIGUE SIN PODERSE PULSAR, y ahora se sabe POR
QUÉ.** Se intentó por ratón, que era la vía que quedaba después de que §4.55
descartara el teclado: leída la posición de la ventana (`168,53`, 1280×840
puntos) y calculado el botón en `(1033, 809)` absolutos, el clic **no llegó** —el
cursor del invitado apareció en el borde izquierdo—. **La causa es que UTM usa
puntero RELATIVO**: mueve el cursor del invitado por incrementos, así que una
coordenada absoluta del anfitrión no mapea a nada. No es que el botón esté
inerte: es que **ni el teclado ni el ratón absoluto llegan a él**. Sigue siendo la
única vía sin agotar dentro de la sesión, y para abrirla haría falta puntero
absoluto en la configuración del bundle. **`[OMIT]`, no descartado.**

**j) EL SIGUIENTE MEDIO, Y LA PREDICCIÓN ESCRITA ANTES DE FABRICARLO.** Con dos
sospechosos, un medio discrimina. Se elige el que además deja una configuración
**usable** si sale bien —conservar nuestro nombre y añadir el trozo que falta—:

```
EncinaOS 24.04.4 LTS "Noble Numbat" - Release arm64 (20260210)
```

Una sola variable contra `d81586ae…`: **se añade `LTS "Noble Numbat"`**, y la
primera palabra no se toca. Rótulo `Install EncinaOS 24.04.4 LTS`, volumen
`EncinaOS 24.04.4 LTS arm64` (26 bytes de 32).

**EL MECANISMO EN EL QUE ME APOYO, y es CONTADO, no leído en ningún fuente:** el
número de campos separados por espacios.

```
OFICIAL   9 campos  Ubuntu 24.04.4 LTS "Noble Numbat" - Release arm64 (20260210)   FUNCIONA
e8a0ead2  6 campos  EncinaOS 0.2.1 - Release arm64 (20260210)                      SE CAE
d81586ae  6 campos  EncinaOS 24.04.4 - Release arm64 (20260210)                    SE CAE
§4.54     7 campos  Encina OS 0.2.1 - Release arm64 (20260210)                     SE CAE
NUEVO     9 campos  EncinaOS 24.04.4 LTS "Noble Numbat" - Release arm64 (20260210)  ?
```

**Los tres ficheros que tumban el instalador tienen 6 ó 7 campos; el que funciona
tiene 9.** Si algo del instalador hace un `split()` e indexa por posición más allá
del 5, nuestro fichero da `IndexError` y el suyo no. Eso explicaría además por qué
no hay `Traceback` en el `journal` (§4.55) sin que deje de ser una excepción: la
recogería el propio arranque del instalador.

> **Predigo que el instalador ARRANCA.**
>
> **Y lo digo con menos confianza que las dos anteriores, a propósito:** esto es
> una **correlación sobre cuatro casos**, no un mecanismo leído en el código, y
> llevo **dos atribuciones falsas seguidas** (§4.55b y §4.56g). El recuento de
> campos y «falta `LTS "Noble Numbat"`» son **la misma diferencia contada de dos
> maneras**, así que este medio **no separa** «es el número de campos» de «es ese
> trozo concreto». Eso costaría otro medio.
>
> **Lo que la tumba:** que arranque no probaría el recuento de campos; y si **se
> cae**, entonces la causa es **la primera palabra** —`EncinaOS` en vez de
> `Ubuntu`—, y eso mataría la posibilidad de renombrar este fichero, obligando a
> romper la derivación del rótulo y el `Volume id` que §4.53 unió.

**Y UNA CONSECUENCIA DE PRODUCTO QUE ES DE JORGE Y NO SE DECIDE AQUÍ:** si la
causa resulta ser ese trozo, la salida pasa por llevar **`LTS "Noble Numbat"`
—el nombre en clave de Ubuntu— dentro de la cadena de nuestro producto**, que es
justo el terreno que miró la casilla 2. Como **medio de diagnóstico** no se
entrega nada; como **producto**, es una decisión aparte.

**k) EL MEDIO DE (j) NO SE PUDO FABRICAR, Y LO PARÓ EL PROPIO GUION.** La cuenta
del `Volume id` que escribí en (j) —26 bytes— **estaba mal**: usé la fórmula del
**rótulo** (`release_de`, que corta los dos primeros campos) para predecir el
**volumen**, que se deriva de otra manera. El paso 5e lo cazó antes de gastar
nada:

```
[FALLO] «EncinaOS 24.04.4 LTS "Noble Numbat" arm64» son 41 bytes y el campo del PVD admite 32
```

O sea que **la derivación que §4.53 unió tiene un techo de 32 bytes**, y con `LTS
"Noble Numbat"` dentro no cabe. El experimento de (j) **no es fabricable tal cual**.
La predicción de (j) queda **sin cotejar**, no refutada.

**l) UN CERO FALSO MÍO, CAZADO POR SU PROPIO CONTROL: `grep -r` SIN `-a` SE SALTA
LOS BINARIOS.** Buscando quién lee `.disk/info` dentro del snap del instalador
concluí que sólo lo tocaban dos ficheros Python. **Era falso**, y el defecto
estaba en el instrumento:

```
grep -rl  'disk/info' snapfs | grep -v '\.py$'   ->  hooks/install, ubuntu-image.rst
grep -ral 'disk/info' snapfs | grep -v '\.py$'   ->  bin/lib/libapp.so  <- ESTE FALTABA
```

**Un `grep -r` sobre un árbol con binarios devuelve un CERO FALSO**, que es
exactamente la familia de verde falso de §4.54 (`timeout`) y §4.51. Va a
`SCRIPTS.md`.

**m) EL MECANISMO, LEÍDO EN EL MEDIO Y CON SU CONTROL — Y NO ES EL RECUENTO DE
CAMPOS: ES LA PRIMERA PALABRA.** Extraído `minimal.standard.live.squashfs` de la
ISO **oficial**, de ahí `ubuntu-desktop-bootstrap_495.snap`, y de ahí su
`bin/lib/libapp.so` (13 239 216 bytes), que es la interfaz Flutter —la que §4.55
midió que es la que se corta, con el servidor sano—. Dentro están, juntas:

```
/cdrom/.disk/info
FlavorService                 package:ubuntu_provision/src/services/flavor_service.dart
UbuntuFlavor.fromName         package:ubuntu_flavor/src/ubuntu_flavor.dart
. Valid flavors are:
Unknown flavor found in config:
```

**Y los once sabores están; el nuestro no.** Con el control delante —una cadena
inventada da 0 y la de verdad da 1—:

```
Ubuntu ESTA   Kubuntu ESTA   Xubuntu ESTA   Lubuntu ESTA   Edubuntu ESTA
Ubuntu MATE ESTA   Ubuntu Budgie ESTA   Ubuntu Studio ESTA
Ubuntu Kylin ESTA   Ubuntu Unity ESTA   Ubuntu Cinnamon ESTA
EncinaOS  no esta          Encina  no esta
```

Encaja con **las cinco** mediciones que hay: los tres medios cuya primera palabra
es nuestra se caen (`e8a0ead2`, `d81586ae`, el de §4.54), y los dos cuyo
`.disk/info` va intacto arrancan (`4f856618` con `--sin-info`, `1224b5b1`).

> **ESTO NO ES UNA CAUSA, Y AQUÍ MENOS QUE NUNCA.** Es un mecanismo **leído** más
> un control más casos que fallan, que es **literalmente** la forma de las dos
> atribuciones falsas de §4.55b y §4.56g. **El recuento de campos de (j) encaja
> con las mismas cinco mediciones**, así que hay **dos** hipótesis vivas y
> ninguna medida.
>
> **EL MEDIO QUE LAS SEPARA, y es uno solo:** `.disk/info` con **6 campos** (lo
> que el recuento dice que se cae) y **primera palabra válida** (lo que el sabor
> dice que arranca):
>
> ```
> Ubuntu 24.04.4 - Release arm64 (20260210)
> ```
>
> Si **arranca**, la causa es la primera palabra y el recuento queda falso. Si
> **se cae**, es al revés. **Pero el paso 5b lo RECHAZA a propósito** —«el rótulo
> del icono seguiría diciendo Ubuntu»—, y los once sabores válidos llevan todos
> «buntu» dentro, así que **no hay ninguna cadena que pase la comprobación de
> marca y sirva para este experimento**. Hace falta **una bandera de bisecado
> más**, igual que §4.55 necesitó una por mecanismo.

**n) LO QUE ESTO PONE EN DUDA, Y ES DE JORGE.** Si la primera palabra resulta ser
la causa, entonces **`/.disk/info` no puede llevar nuestro nombre nunca**, y con
él se caen los tres sitios que §4.53 ató a ese fichero: el rótulo del icono, el
`Volume id` y el `FLAVOUR`. Eso **no es un ajuste, es replantear el mecanismo de
D23 para este fichero**, y la tercera vía que §4.56a dejó anotada —romper la
derivación— pasaría de opción a obligación.

**o) EL MEDIO QUE SÍ SE PUEDE FABRICAR HOY, Y DISCRIMINA IGUAL — CON `--sin-volid`.**
El techo de 32 bytes de (k) sólo aplica **si se cambia el `Volume id`**. Con
`--sin-volid` el volumen se queda el oficial y el fichero de 9 campos **sí es
fabricable**, conservando **nuestra primera palabra**:

```
EncinaOS 24.04.4 LTS "Noble Numbat" - Release arm64 (20260210)
```

**Y esto separa las dos hipótesis igual de bien que el medio «Ubuntu …» de (m),
sin necesitar ninguna bandera nueva:**

```
si ARRANCA -> la 1a palabra sigue siendo «EncinaOS», un sabor que NO esta en el
              binario, asi que LA HIPOTESIS DEL SABOR ES FALSA y la causa es el
              trozo que faltaba / el recuento de campos
si SE CAE  -> el fichero ya tiene 9 campos, asi que EL RECUENTO ES FALSO y la
              hipotesis del sabor sobrevive (sin quedar probada)
```

**Por qué `--sin-volid` no contamina, y es medido, no supuesto:** §4.55f gastó un
medio con `--sin-volid` (`08392ddc…`, `1 0 1 1`) y **se cayó igual**, y el medio
que funciona (`4f856618…`) lleva el `Volume id` **puesto**. O sea que se ha visto
`volid=1` con los **dos** resultados: el `Volume id` **no determina** el
resultado, y ya estaba exonerado por experimento.

> **PREDICCIÓN, escrita antes de fabricar: predigo que SE CAE**, o sea que el
> recuento de campos de (j) es falso y la primera palabra sigue viva. Me apoyo en
> (m): los once sabores están en el binario y el nuestro no, junto a
> `/cdrom/.disk/info` y `UbuntuFlavor.fromName` en el mismo fichero.
> **Y esto contradice mi predicción de (j)**, escrita hace dos horas, cuando aún
> no había leído el binario. La de (j) se queda escrita y sin cotejar.
> **Lo que la tumba:** que arranque. Y aun cayéndose, **no probaría** el sabor:
> dejaría dos hipótesis en una.

**p) `--sin-volid` NO SALTA ESA COMPROBACIÓN, Y LA PREMISA DE (o) ERA FALSA.** El
medio no se fabricó, con el mismo `[FALLO]` de (k). Leído el bloque 5e —en vez de
suponerlo por tercera vez—, el guion comprueba **el fichero nuestro siempre,
«lo lleve el medio o no»**, por la misma razón declarada que el 5b: de él sale el
`Volume id` aunque la bandera decida no aplicarlo. **`--sin-volid` decide qué
viaja, no qué se comprueba.**

**q) Y DE AHÍ SALE UNA RESTRICCIÓN DURA QUE NO ESTABA ESCRITA EN NINGÚN SITIO.**
La fórmula del 5e es **lo de antes del ` - `, más la arquitectura**, y el campo
del PVD admite **32 bytes**:

```
«24.04.4 LTS "Noble Numbat"»   26 bytes
« arm64»                        6 bytes
                              -------
                               32 bytes  <- YA ESTAN LOS 32, y aun no hay NOMBRE
```

```
«EncinaOS 24.04.4 LTS "Noble Numbat" arm64»   41 bytes   NO CABE
«E        24.04.4 LTS "Noble Numbat" arm64»   34 bytes   NO CABE
«         24.04.4 LTS "Noble Numbat" arm64»   33 bytes   NO CABE
```

**Con el nombre en clave de verdad no cabe NINGÚN nombre de producto, ni siquiera
la cadena vacía.** No es que «EncinaOS» sea largo: es que `LTS "Noble Numbat"`
consume el presupuesto entero. O sea que **`.disk/info` no puede llevar a la vez
el nombre en clave de Ubuntu y un `Volume id` derivado de él.**

**r) LAS DOS HIPÓTESIS VIVAS CONVERGEN EN LA MISMA CONSECUENCIA.** Y esto sí se
puede decir hoy, sin haber medido cuál de las dos es:

```
si gana el SABOR (m)     -> .disk/info no puede llevar nuestra 1a palabra
si gana el RECUENTO (j)  -> .disk/info tiene que llevar LTS "Noble Numbat",
                            y entonces el Volume id NO CABE (q)
```

**En los dos casos, la derivación que §4.53 unió a propósito tiene que romperse.**
La «tercera vía» que §4.56a dejó anotada como opción —dejar de derivar el rótulo
y el `Volume id` de este fichero— **deja de ser opcional**, y lo es ya, antes de
saber cuál de las dos hipótesis es la buena. Es lo único que hoy se puede dar por
cerrado de esta sesión aparte de la falsación del canal.

**s) EL MEDIO QUE FALTA SIGUE SIN PODERSE FABRICAR, Y AHORA SE SABE QUÉ INSTRUMENTO
FALTA.** Los dos medios que separan (j) de (m) chocan cada uno con una guarda **de
producto**:

```
«Ubuntu 24.04.4 - Release arm64 (20260210)»              -> lo rechazan 5b y 5e
   (6 campos + sabor valido: separa las dos de un golpe)     («todavia dice Ubuntu»)
«EncinaOS 24.04.4 LTS "Noble Numbat" - …»                -> lo rechaza 5e (41 > 32)
```

Esas guardas existen para que **el producto** no salga mal rotulado, y hacen bien
su trabajo: han parado dos fabricaciones. Lo que falta es **una bandera de
bisecado que permita un `.disk/info` crudo en un medio de DIAGNÓSTICO**, igual que
§4.55 necesitó una bandera por mecanismo para poder bisecar. **`[OMIT]`: no está
escrita, así que la elección entre (j) y (m) sigue SIN MEDIR.**

**t) EL INSTRUMENTO QUE FALTABA: `--info-crudo`, Y SU CONTROL EN LOS DOS SENTIDOS.**
Decidido por Jorge entre las tres vías de (s). La bandera **no relaja nada del
producto** —sin ella el guion se comporta exactamente igual que hoy—; lo que hace
es que las dos guardas de marca **dejen de PARAR y sigan EVALUÁNDOSE**, diciendo
en voz alta qué habrían hecho:

```
[AVISO] DIAGNOSTICO: el rotulo diria «Install Ubuntu 24.04.4». En el producto esto seria [FALLO].
```

**Y lleva un control de que la guarda sigue viva**, que es lo que separa esto de
apagarla: la **misma** regla, sobre el `.disk/info` **del producto**, tiene que
seguir diciendo que ése pasa. Si dijera que no, la guarda estaría rota y el
`[AVISO]` no significaría nada —que es exactamente como se cuela un verde falso—.
Además **el `Volume id` no se trunca jamás**: si no cabe en 32 bytes, el medio de
diagnóstico viaja con el oficial y lo dice.

**EL BANCO, que extrae la guarda del guion en vez de retectearla, y la prueba es
que la MISMA cadena da respuestas OPUESTAS según la bandera:**

```
== extraidas 7 lineas de la guarda de marca de imagen/fabricar-iso.sh
[OK] CONTROL DEL BANCO: la guarda se extrajo del guion, no esta retecleada aqui
  [OK]    «Ubuntu 24.04.4» crudo=no    -> para
  [OK]    «Ubuntu 24.04.4» crudo=si    -> avisa
  [OK]    «EncinaOS 24.04.4» crudo=no  -> pasa
  [OK]    «EncinaOS 24.04.4» crudo=si  -> pasa
== 4 correctas, 0 fallos
```

Y gastado contra un guion saboteado —la guarda deja de parar también en el
producto—, que saca el fallo **donde toca** y sólo ahí:

```
  [FALLO] «Ubuntu 24.04.4» crudo=no -> avisa, se esperaba para
== 3 correctas, 1 fallos     salida 1
```

**u) EL MEDIO QUE SEPARA LAS DOS HIPÓTESIS.** `.disk/info` de diagnóstico:

```
Ubuntu 24.04.4 - Release arm64 (20260210)     6 campos, 1a palabra un sabor VALIDO
```

**Seis campos** —lo que la hipótesis del recuento (j) dice que **se cae**— y
**primera palabra válida** —lo que la hipótesis del sabor (m) dice que
**arranca**—. Fabricado reutilizando la cosecha de (p), que sobrevivió al
`[FALLO]` de `fabricar-iso.sh` (28 `.deb` y su `Packages`), así que no cuesta la
vuelta entera por `ssh`.

> **PREDICCIÓN, escrita antes de fabricar y antes de arrancar: predigo que
> ARRANCA**, o sea que la causa es **la primera palabra** y el recuento de campos
> de (j) queda falso. Me apoyo en (m): `/cdrom/.disk/info`, `FlavorService`,
> `UbuntuFlavor.fromName` y los once sabores están en el mismo binario, y el
> nuestro no.
>
> **Y lo digo con la desconfianza ganada hoy:** llevo **dos predicciones falsas**
> en esta sesión (la del canal en (d), la del `Volume id` en (j)) y **dos premisas
> falsas** ((o) y el `grep` de (l)). Esta hipótesis tiene la misma forma que las
> que se cayeron.
>
> **Lo que la tumba:** que se caiga. Y **aun arrancando, no cierra la causa del
> todo**: probaría que con un sabor válido el instalador levanta, no que
> `UbuntuFlavor.fromName` sea la línea exacta que lo tira. Eso último seguiría
> siendo lectura.

**v) LA BANDERA NECESITÓ CONVERTIR TRES GUARDAS, NO DOS — Y LA TERCERA NO SALIÓ
LEYENDO, SALIÓ EJECUTANDO.** Las dos de (t) miran **la cadena** antes de fabricar
(pasos 5b y 5e); la tercera vive en el **paso 11** y mira **el medio ya
construido**, leyendo sus descriptores de volumen. Por eso no apareció en la
misma búsqueda: no es la misma clase de comprobación. La primera fabricación paró
ahí, **con la ISO ya escrita pero sin haber corrido el paso 12 (integridad) ni el
13 (mecanismos)** —o sea, un medio a medio verificar, que no se arranca—.

**w) Y AL EJECUTARLA SALIERON DOS DEFECTOS DE SU PROPIA SALIDA, los dos míos.**

**El primero es un `[OK]` que describía lo que el guion quería y no lo que había
en el medio**, que es la trampa 13 escrita en la salida:

```
[OK]    los 4 descriptores primarios dicen «Ubuntu 24.04.4 arm64», y ninguno de los 4 dice Ubuntu
                                             ^^^^^^                              ^^^^^^^^^^^^^^^
                                             lo dicen los cuatro          ...y aqui dice que ninguno
```

Convertí el `fallo` en `[AVISO]` y **dejé el mensaje de éxito sin tocar**. Ahora
el texto cuenta lo que hay: «y 4 de 4 dicen Ubuntu, porque es un medio de
DIAGNOSTICO».

**El segundo envenena el instrumento con el que cuento fallos:** los avisos
llevaban el literal `[FALLO]` dentro («En el producto esto sería [FALLO]»), así
que `grep -c '\[FALLO\]'` sobre el registro daba **3** en una fabricación que no
tuvo ninguno. Un guion que escribe en su salida la cadena que usas para buscar
errores **fabrica falsos positivos en cada lectura del registro**. Reescrito como
«En el producto esto pararía la fabricación».

**x) EL MEDIO, VERIFICADO ENTERO.** `9b1194b92775eeae…`, 3 721 265 152 bytes:

```
[AVISO] DIAGNOSTICO: el rotulo diria «Install Ubuntu 24.04.4». …
[OK]    CONTROL: la guarda de marca sigue viva -- rechazaria «Ubuntu 24.04.4 LTS» y acepta el producto «EncinaOS 24.04.4 LTS»
[OK]    las 267 lineas de md5sum.txt cuadran con la ISO construida…
[OK]    control: con el md5sum.txt OFICIAL fallan exactamente 2 lineas: /boot/grub/grub.cfg /.disk/info
[OK]    control: sobre la ISO oficial el lector no encuentra ninguno de los cuatro
[OK]    el medio lleva exactamente lo pedido (capa volid info menu): 1 1 1 1
```

**Los cuatro mecanismos de D23 puestos**, como el que se cae. La única diferencia
contra `d81586ae…` es `.disk/info`.

**y) SE CAE. LA PREDICCIÓN DE (u) ES FALSA Y LA HIPÓTESIS DEL SABOR ESTÁ TUMBADA
— PERO ESTE ES EL MEDIO QUE MÁS HA ACOTADO EN TRES SESIONES.** Arrancado
`encina-sabor-9b1194b9` desde cero, con `.disk/info` = `Ubuntu 24.04.4 - Release
arm64 (20260210)` —**primera palabra un sabor VÁLIDO**— sale **el mismo diálogo**
«Se produjo un problema» a los ~3 minutos.

**Es mi TERCERA predicción falsa de la sesión** (el canal en (d), el `Volume id`
en (j), el sabor aquí), y las tres estaban escritas antes de arrancar. La lectura
de (m) era real —`/cdrom/.disk/info`, `FlavorService`, `UbuntuFlavor.fromName` y
los once sabores están en `libapp.so`, con su control—, pero **la atribución era
falsa OTRA VEZ**. Van cuatro atribuciones falsas seguidas construidas igual:
mecanismo leído + control + caso que falla. **Esa forma de razonar no produce
causas en este proyecto, y ya no es una sospecha: es un patrón medido.**

**PERO MIRA DÓNDE DEJA EL BISECADO:**

```
FICHERO                                           CAMPOS  RESULTADO
Ubuntu   24.04.4 LTS "Noble Numbat" - Release …     9     FUNCIONA (el oficial)
Ubuntu   24.04.4                    - Release …     6     SE CAE      <- HOY
EncinaOS 24.04.4                    - Release …     6     SE CAE
EncinaOS 0.2.1                      - Release …     6     SE CAE
Encina OS 0.2.1                     - Release …     7     SE CAE
```

**El fichero de hoy y el oficial se diferencian en UNA sola cosa: `LTS "Noble
Numbat"`.** Y el de hoy se cae. O sea que **la causa está DENTRO de ese trozo**
—el `LTS`, el nombre en clave entrecomillado, o el número de campos—, y no en el
canal, ni en la primera palabra, ni en el separador, ni en el paréntesis.

**LO QUE ESTO EXONERA Y LO QUE NO, dicho con precisión:** que poner una primera
palabra válida **no arregle** el fallo prueba que **arreglarla no basta**; **no**
prueba que la nuestra sea inofensiva. Podría haber dos causas. Lo que sí queda
medido es que **restaurar ese trozo es necesario**, y eso es lo que hay que
probar ahora — **con nuestro nombre delante**, que es la prueba que de verdad le
importa al producto:

```
EncinaOS 24.04.4 LTS "Noble Numbat" - Release arm64 (20260210)
```

**Y AHORA SÍ SE PUEDE FABRICAR**, porque `--info-crudo` se salta el techo de 32
bytes de (q) y hace viajar el `Volume id` oficial sin truncar nada. Era
exactamente el medio que (k) y (p) no pudieron construir.

**z) EL MEDIO DEL PRODUCTO: nuestro nombre CON el trozo restaurado.** `.disk/info`
de diagnóstico:

```
EncinaOS 24.04.4 LTS "Noble Numbat" - Release arm64 (20260210)
```

**9 campos como el oficial, y la primera palabra la NUESTRA.** Es la pregunta que
de verdad le importa al producto: ¿basta con devolver el trozo, conservando
`EncinaOS`? Fabricado con `--info-crudo`, que se salta el techo de 32 bytes y hace
viajar el `Volume id` **oficial** sin truncar nada.

**UNA OBSERVACIÓN QUE NO HABÍA HECHO, y es más específica que el recuento:** las
**comillas** están en el único fichero que funciona y **faltan en los cuatro que
se caen**. Un parseador que saque el nombre en clave *de entre comillas* y no
encuentre ninguna explicaría los cinco casos igual de bien que el recuento, y con
un mecanismo más concreto.

> **PREDICCIÓN: predigo que ARRANCA.** Si arranca, `EncinaOS` como primera palabra
> queda exonerado **por experimento** y el producto puede llevar su nombre en este
> fichero.
>
> **Y va con mi marcador de hoy delante: llevo 0 de 3.** Las tres predicciones de
> esta sesión eran falsas y las tres tenían apoyo que parecía bueno.
>
> **Lo que NO separa este medio, dicho antes de gastarlo:** restaura **el `LTS`,
> las comillas y el recuento a la vez**, así que si arranca **no dirá cuál de los
> tres era**. Eso costaría un medio más (`Ubuntu 24.04.4 LTS - Release …`, 7
> campos, con `LTS` y sin comillas). Se gasta este primero porque es el que
> contesta la pregunta **del producto**, no la de la curiosidad.

**aa) EL MEDIO SE FABRICÓ, Y LA BANDERA HIZO LO QUE PROMETÍA CON EL `Volume id`.**
`b7d287f7f763cc4a…`, 3 721 265 152 bytes, **0 fallos**:

```
[AVISO] DIAGNOSTICO: «EncinaOS 24.04.4 LTS "Noble Numbat" arm64» son 41 bytes y caben 32.
        Este medio viaja con el Volume id OFICIAL (como --sin-volid). NO se trunca.
[OK]    el medio lleva exactamente lo pedido (capa volid info menu): 1 0 1 1
volid:  Ubuntu 24.04.4 LTS arm64
```

O sea que la restricción de (q) **se cumplió en la práctica** y el guion la
resolvió **diciéndolo** en vez de truncando en silencio, que es lo que el bloque
5e existe para evitar desde que se escribió.

**bb) PRIMER ARRANQUE: PANTALLA NEGRA, QUE NO ES UN RESULTADO.** Aplicada la
trampa 38 en vez de concluir. Las dos señales dicen que el sistema **está vivo**:

```
t=20s  log=83790B   ip=—
t=40s  log=84507B   ip=192.168.64.28
t=60s  log=92203B   ip=192.168.64.28
t=80s  log=92203B   ip=192.168.64.28   <- y ahi se queda 90s mas
```

`92203B` es **el mismo tamaño** al que llegaron los dos medios de hoy cuando
alcanzaron el escritorio, así que llegó igual de lejos; lo que no salió es la
pantalla. Capturas de **112 446 bytes** —negra— frente a los ~730 000 de una
gráfica: el tamaño del PNG distingue las dos sin mirarlas, y eso vale como
criterio barato. **Se repite el arranque**, que es lo que §4.55 midió que hacía
falta (un medio arrancó al **tercer** intento).

**cc) ARRANCA. LA CAUSA ESTÁ CERRADA: ES `LTS "Noble Numbat"`, Y NUESTRO NOMBRE
QUEDA EXONERADO POR EXPERIMENTO.** Tercer arranque de `b7d287f7…` —los dos
primeros en negro, trampa 38 aplicada—: **«Disposición del teclado», en español,
con «Español» marcado**. Es **el primer medio de toda la línea de D23 que lleva un
`.disk/info` NUESTRO y arranca el instalador**.

```
.disk/info                                                campos  instalador
Ubuntu   24.04.4 LTS "Noble Numbat" - Release arm64 (…)      9     FUNCIONA (el oficial)
EncinaOS 24.04.4 LTS "Noble Numbat" - Release arm64 (…)      9     FUNCIONA  <- con NUESTRO nombre
Ubuntu   24.04.4                    - Release arm64 (…)      6     se cae
EncinaOS 24.04.4                    - Release arm64 (…)      6     se cae
EncinaOS 0.2.1                      - Release arm64 (…)      6     se cae
Encina OS 0.2.1                     - Release arm64 (…)      7     se cae
```

**Las dos filas de arriba se diferencian sólo en la primera palabra y las dos
funcionan; las cuatro de abajo son las que no llevan el trozo y las cuatro se
caen.** Eso cierra las dos cosas a la vez:

- **La causa es la ausencia de `LTS "Noble Numbat"`.** Restaurarlo hace arrancar
  lo que no arrancaba, con todo lo demás igual. No es lectura: es el experimento.
- **`EncinaOS` como primera palabra no tumba el instalador.** §4.56y sólo pudo
  decir que arreglarla no bastaba; esta fila lo cierra en el otro sentido.

**Y LA PREDICCIÓN DE (z) SALIÓ BIEN — la primera de cuatro.** Marcador de la
sesión: **1 acertada de 4**. Se apoyaba en la observación de que las comillas
están en el único fichero que funcionaba y faltan en todos los que se caen.

**LO QUE SIGUE SIN SEPARAR, y lo digo porque este medio no podía hacerlo:** el
trozo restaura **el `LTS`, las comillas y el recuento a la vez**. Cuál de los tres
es, **no está medido**. El medio que lo separa es `Ubuntu 24.04.4 LTS - Release
arm64 (…)` —7 campos, con `LTS`, sin comillas—. **`[OMIT]`.**

**dd) EL PRECIO, QUE AHORA ES UNA CONSECUENCIA MEDIDA Y NO UNA OPCIÓN.** El
fichero que funciona da un `Volume id` derivado de **41 bytes** y el campo del PVD
admite **32** (§4.56q). El medio de hoy sólo pudo fabricarse porque `--info-crudo`
hace viajar el `Volume id` **oficial** —`Ubuntu 24.04.4 LTS arm64`—, o sea que
**este medio no es entregable: dice Ubuntu en el nombre del volumen**. Para que el
producto lleve a la vez el `.disk/info` que arranca y un `Volume id` propio, **hay
que romper la derivación de §4.53** y escribir el `Volume id` por su cuenta. Es lo
que §4.56r predijo antes de saber cuál de las dos hipótesis ganaba, y ha ganado
por el camino que llevaba a la misma consecuencia.

---

### 4.57 SEPARAR EL `LTS` DE LAS COMILLAS: el `[OMIT]` de §4.56cc estaba en la ruta crítica y nadie lo había visto (2026-08-19, cierre)

**a) POR QUÉ ESTO NO ES CURIOSIDAD.** §4.56cc dejó sin separar cuál de los tres
—el `LTS`, las comillas del nombre en clave, o el número de campos— es el que
importa. Parecía una pregunta para después. **No lo es**, y la aritmética de
§4.56q es la que lo decide: un nombre en clave real de dos palabras **no cabe
nunca** en los 32 bytes del `Volume id` derivado. O sea que **la única salida que
conserva la derivación de §4.53 es que el nombre en clave NO haga falta.**

El candidato de **7 campos**, comprobado con las fórmulas del propio guion:

```
EncinaOS 24.04.4 LTS - Release arm64 (20260210)      7 campos
  [OK] 5b: el rotulo «Install EncinaOS 24.04.4 LTS» no dice Ubuntu
  [OK] 5b: la 2a palabra es la de la base
  [OK] 5b: conserva la forma «Palabra … (numero)»
  [OK] 5e: «EncinaOS 24.04.4 LTS arm64» = 26 bytes, CABE en 32
  [OK] 5e: el volid no dice Ubuntu
```

**Pasa las tres guardas del producto**, así que no necesita `--info-crudo`: es una
cadena **entregable**. Si arranca se caen de golpe tres problemas —el nombre en
clave de Ubuntu dentro del producto, romper la derivación, y el bloqueo del paso
5e que hoy impide construir—.

> **PREDICCIÓN, escrita antes de fabricar: predigo que SE CAE**, o sea que lo que
> importa son **las comillas / el nombre en clave** y no el `LTS`.
>
> **En qué me apoyo:** `LTS` y las comillas están **igual de correlacionados** con
> los cinco casos medidos, así que la correlación no decide; lo que inclina es el
> mecanismo plausible. Un parseador que saque el nombre en clave **de entre
> comillas** y no encuentre ninguna es una forma corriente de romperse; que falte
> un `LTS` opcional lo es mucho menos.
>
> **Y con el marcador delante: llevo 1 de 4 en esta sesión.** Las tres falsas
> también tenían apoyo que parecía bueno, así que esta predicción vale lo que vale.
>
> **Lo que la tumba:** que arranque, y sería la mejor noticia posible —producto
> entregable sin tocar la derivación—.
>
> **Y si se cae, queda una tercera salida que hoy nadie ha probado:** un nombre en
> clave **corto y propio** que conserve las comillas y quepa en 32 bytes
> (`EncinaOS 24.04.4 LTS "A B"` da exactamente 32). Separaría «hacen falta las
> comillas» de «hace falta el nombre en clave DE UBUNTU», que no es lo mismo y
> tiene consecuencias distintas para la casilla 2.

**b) EL MEDIO SALE LIMPIO, Y ESO YA ES UN DATO.** `7325c90030f14906…`,
3 721 265 152 bytes, fabricado **sin `--info-crudo`**:

```
== 13. los cuatro mecanismos, leidos del medio terminado
[OK]    el medio lleva exactamente lo pedido (capa volid info menu): 1 1 1 1
volid:  EncinaOS 24.04.4 LTS arm64   (lo que se ve al conectar el USB)
0 fallos     0 avisos de DIAGNOSTICO
```

**Cero avisos de diagnóstico** es la comprobación de que la cadena es
**entregable**: las tres guardas de marca se ejecutaron **en modo producto** y
ninguna tuvo nada que decir. Y el `Volume id` es **nuestro**, no el oficial —a
diferencia de `b7d287f7…`, que sólo se pudo fabricar con el volumen de Ubuntu—.
O sea que **si este medio arranca, es un producto completo**, no un diagnóstico.

**c) SE CAE. `LTS` SOLO NO BASTA — Y LA PREDICCIÓN DE (a) ACERTÓ (2 de 5).**
Arrancado `encina-lts-7325c900`: **«Se produjo un problema»**, el mismo diálogo,
a la primera y sin pantallas negras.

```
EncinaOS 24.04.4 LTS "Noble Numbat" - Release arm64 (…)   9 campos   FUNCIONA
EncinaOS 24.04.4 LTS                - Release arm64 (…)   7 campos   SE CAE   <- HOY
```

**Una sola diferencia entre esas dos filas: `"Noble Numbat"`.** O sea que lo que
hace falta son **las comillas o el nombre en clave**, y el `LTS` queda descartado
como lo que importa. **Y con eso muere la salida barata:** no hay forma de que el
producto arranque sin llevar un nombre en clave entrecomillado.

**d) LA PREGUNTA QUE DE VERDAD DECIDE EL PRODUCTO, y no es la que parecía.** No es
«¿hace falta el nombre en clave?» sino **«¿hace falta el de UBUNTU, o vale uno
nuestro?»**. Son cosas distintas y tienen consecuencias distintas:

```
si vale uno NUESTRO  -> ni marca de Ubuntu en el producto, ni romper la derivacion
si hace falta el SUYO -> «Noble Numbat» dentro del producto (casilla 2) Y romper
                         la derivacion, porque 41 bytes no caben en 32 (§4.56q)
```

**El medio que lo separa, y también es cadena de PRODUCTO:**

```
EncinaOS 24.04.4 LTS "A B" - Release arm64 (20260210)      9 campos
  volid  -> «EncinaOS 24.04.4 LTS "A B" arm64» = 32 bytes  CABE, justo
  rotulo -> Install EncinaOS 24.04.4 LTS
  no dice «Ubuntu» en ningun sitio
```

`"A B"` no es un nombre, es **el máximo que cabe** con `EncinaOS` delante: el
presupuesto deja exactamente 5 bytes para el codename entrecomillado. Si esto
arranca, el nombre de verdad se elige después (acortar el producto a `Encina`
compraría 2 bytes más).

> **PREDICCIÓN: predigo que ARRANCA**, o sea que lo que importa es **la forma
> —unas comillas con algo dentro—** y no el nombre concreto. Me apoyo en que la
> interfaz que se rompe es la que **parsea** el fichero, y un parseo que exige
> comillas se satisface con cualquier contenido.
>
> **Lo que la tumba:** que el instalador **compruebe** el nombre en clave contra
> algo —`VERSION_CODENAME=noble` de `/etc/os-release`, o una tabla de releases—,
> en cuyo caso `"A B"` no vale y hace falta el de Ubuntu.
>
> Marcador: **2 de 5**.

**e) ARRANCA CON UN NOMBRE EN CLAVE NUESTRO. LA PREDICCIÓN DE (d) ACERTÓ (3 de 6),
Y EL BLOQUEO DEL PRODUCTO DESAPARECE.** `cf4bce47b2e228a0…`, fabricado **sin
`--info-crudo`** (0 fallos, **0 avisos de diagnóstico**, `1 1 1 1`, `Volume id`
propio `EncinaOS 24.04.4 LTS "A B" arm64`). Arrancado a la primera: **«Disposición
del teclado», en español**.

**EL BISECADO, YA COMPLETO — ocho ficheros:**

```
.disk/info                                          campos  instalador
Ubuntu   24.04.4 LTS "Noble Numbat" - Release …       9     FUNCIONA (oficial)
EncinaOS 24.04.4 LTS "Noble Numbat" - Release …       9     FUNCIONA
EncinaOS 24.04.4 LTS "A B"          - Release …       9     FUNCIONA   <- codename NUESTRO
EncinaOS 24.04.4 LTS                - Release …       7     se cae
Ubuntu   24.04.4                    - Release …       6     se cae
EncinaOS 24.04.4                    - Release …       6     se cae
EncinaOS 0.2.1                      - Release …       6     se cae
Encina OS 0.2.1                     - Release …       7     se cae
```

**LA CAUSA, EN UNA FRASE Y PROBADA QUITANDO Y PONIENDO:** el instalador gráfico
necesita que `/.disk/info` lleve **un nombre en clave entre comillas**. **El
contenido da igual** —`"A B"` vale igual que `"Noble Numbat"`—, el `LTS` **no
basta** por sí solo, la primera palabra **puede ser la nuestra**, y ni el canal,
ni el `Volume id`, ni el separador, ni el paréntesis tienen nada que ver.

**LO QUE ESTO DESBLOQUEA, Y ES TODO:**

```
NO hace falta el nombre en clave de Ubuntu  -> la casilla 2 ni se toca
NO hace falta romper la derivacion de §4.53 -> «EncinaOS 24.04.4 LTS "A B" arm64» = 32 bytes, CABE
NO hace falta --info-crudo                  -> es cadena de PRODUCTO, 0 avisos
construir-todo.sh deja de parar en el 5e
```

**LO QUE QUEDA, Y ES DECISIÓN DE JORGE, NO MEDICIÓN:**

**1. El nombre en clave de verdad, y el presupuesto es durísimo.** Con `EncinaOS`
delante quedan **exactamente 5 bytes** para el codename entrecomillado, o sea
`"A B"` y nada más. Acortar el producto a `Encina` compra 2 bytes:

```
Encina 24.04.4 LTS "Roble" arm64   = 32 bytes  CABE   (codename de UNA palabra)
Encina 24.04.4 LTS "Ab Cd" arm64   = 32 bytes  CABE   (de dos, de 2+2 letras)
```

**`[OMIT]`: no está medido si un codename de UNA sola palabra vale.** Todos los
que han arrancado llevan dos. Cuesta un medio.

**2. Y hay un efecto que el bloqueo tapaba:** el `Volume id` derivado **arrastra
ahora el `LTS` y las comillas**, así que lo que se ve al conectar el USB es
`EncinaOS 24.04.4 LTS "A B" arm64`. **Cabe, pero es feo.** Romper la derivación
ya no es *obligatorio* —lo era en §4.56dd—, pero sigue siendo la única forma de
que el rótulo del USB sea legible. Eso ya es criterio de producto, no medición.

**f) SE ROMPE LA DERIVACIÓN DE §4.53, Y SIN REINTRODUCIR «EL NOMBRE EN DOS
SITIOS».** Decidido por Jorge. La derivación cae porque quedó **medido** que no
cabe: el instalador exige un codename entrecomillado y con cualquiera de verdad
se pasan los 32 bytes. Pero el peligro que §4.53 evitaba —que el nombre del
producto se escriba en dos ficheros y se separen— **no vuelve**, porque el
`Volume id` ya no se escribe: **se compone de fuentes que ya existen y ya están
verificadas**.

```
nombre  <- la 1a palabra de .disk/info      (sigue siendo la UNICA fuente del nombre)
version <- la del encina-meta que el paso 2 acaba de cotejar POR HUELLA
arq     <- la ultima palabra del Volume id OFICIAL, como siempre
        -> «EncinaOS 0.2.1 arm64»  = 20 bytes
```

**Y de paso se recupera lo que §4.53 obligó a ceder:** el volumen dice **nuestra
versión**, no la de Ubuntu.

**EL CONTROL VA DELANTE, y hace falta:** un `sed` que no case devuelve **cadena
vacía sin quejarse**, y un `Volume id` con un hueco en medio pasaría los 32 bytes
tan tranquilo. Banco que **extrae la función del guion**:

```
[OK] CONTROL DEL BANCO: la funcion se extrajo del guion, no esta retecleada aqui
  [OK] [encina-meta_0.2.1_all.deb]      -> [0.2.1]
  [OK] [encina-meta_1.0_all.deb]        -> [1.0]
  [OK] [otra-cosa_0.2.1_all.deb]        -> []
  [OK] [encina-meta_0.2.1_arm64.deb]    -> []
  [OK] [encina-branding_0.1.15_all.deb] -> []
== 5 correctas, 0 fallos        [EncinaOS 0.2.1 arm64] = 20 bytes CABE
```

y gastado contra un guion saboteado —la extracción acepta **cualquier** paquete y
no sólo `encina-meta`—, que saca **los dos fallos donde tocan**:

```
  [FALLO] [otra-cosa_0.2.1_all.deb]        -> [0.2.1], se esperaba []
  [FALLO] [encina-branding_0.1.15_all.deb] -> [0.1.15], se esperaba []
== 3 correctas, 2 fallos        salida 1
```

**Y el banco tenía un defecto suyo, visto en su primera ejecución:** sin `LC_ALL`
su salida salía **ilegible** —las comillas angulares rotas— y los valores no se
podían leer, así que los cinco `[OK]` no significaban nada hasta arreglarlo. Es
la trampa 2 otra vez, y van dos veces hoy.

**g) EL CODENAME: `"Nutria Nocturna"`.** Esquema, no nombre suelto: **dos palabras
aliteradas** como Ubuntu, pero **en español y con fauna de dehesa** —que es
literalmente el bosque de encinas—, y con **la inicial atada a la base**: `N` de
`Noble`, así que el codename dice de un vistazo sobre qué Ubuntu va. **En ASCII a
propósito**: el `.disk/info` oficial es ASCII puro y el paso 5e cuenta **bytes**,
no caracteres. Se descartó `"Nutria Noble"` por reutilizar el adjetivo de Ubuntu.

```
EncinaOS 24.04.4 LTS "Nutria Nocturna" - Release arm64 (20260210)
  9 campos    rotulo «Install EncinaOS 24.04.4 LTS»    canal stable/ubuntu-24.04.4
  volid «EncinaOS 0.2.1 arm64»  (compuesto, ya no derivado de aqui)
```

**`[OMIT]` que sigue sin medir:** si un codename de **una sola palabra** vale
—los tres que han arrancado llevan dos—, y si un codename con **tildes o eñes**
vale. Ninguna de las dos hace falta para el producto tal como queda.

**h) ARRANCA, Y ES UN MEDIO DE PRODUCTO COMPLETO.** `71f7958c7f19b256…`,
3 721 265 152 bytes, fabricado **sin `--info-crudo`**: **0 fallos, 0 avisos de
diagnóstico**, `1 1 1 1`. Y la composición del `Volume id` se ve en la salida:

```
[OK]  el Volume id se compone: nombre «EncinaOS» (.disk/info) + version «0.2.1»
      (encina-meta, cotejado por huella) + «arm64»
volid: EncinaOS 0.2.1 arm64   (lo que se ve al conectar el USB)
```

Arrancado: **«Disposición del teclado», en español**. O sea que el medio lleva a
la vez **el `.disk/info` que hace arrancar al instalador** y **un `Volume id`
propio con nuestro nombre y NUESTRA versión** —las dos cosas que hasta hoy eran
incompatibles—.

**i) Y UNA REGLA MÍA DE HOY, TUMBADA EL MISMO DÍA POR UNA CAPTURA.** La trampa 41
decía que el tamaño del PNG distingue negra / texto / gráfica. **Esta captura
gráfica pesó 309 568 bytes**, dentro del rango que yo había asignado a «registro
de texto». La causa: `capturar-vm.sh` captura **el tamaño de la ventana**, y ésta
era de **1280×840** mientras las anteriores eran de **2560×1680**. **La regla sólo
vale a escala fija**, y la escribí sin ese control. Enmendada en `SCRIPTS.md`.
Es la segunda vez hoy que un instrumento mío pasa por bueno algo que no había
mirado —la otra fue el `grep -r` sin `-a`—.

---

### 4.58 QUE LA CAPA SE MONTE: `layerfs-path=` en la línea del núcleo y la capa renombrada a la cadena (2026-08-20)

**LA PREDICCIÓN, ESCRITA ANTES DE FABRICAR NADA Y ANTES DE TOCAR UN GUION.** Va
delante por una razón que este proyecto se ha ganado a golpes: en las tres
últimas sesiones van **cuatro atribuciones falsas seguidas**, y **las cuatro
construidas igual** —mecanismo leído en el código + su control + un caso que
falla—. Esa forma **no produce causas aquí**. Lo único que ha producido causas es
**quitar una pieza y ver cambiar el resultado**. Así que lo de abajo se marca por
lo que es: **lectura**, y la lectura no cierra nada hasta que arranque un medio.

#### (a) LO LEÍDO EN EL `casper` DE ESTE MEDIO, con sus controles

Todo sobre el `scripts/casper` sacado del initrd de la ISO oficial, y **el nombre
de la función que §4.52b citaba estaba mal**: no es `setup_unionfs` —ése es el
nombre de arriba, de las versiones viejas— sino **`setup_overlay`** (línea 545).
Lo pilló el control: `grep setup_unionfs` dio **0** y mi control con una cadena
inventada dio **el mismo 0**, o sea que **el control no discriminaba** y el cero
no significaba lo que parecía. Es la trampa 40 otra vez, por otro lado.

```
grep -c setup_overlay  scripts/casper -> 3   (definicion 545, llamada 145)
grep -c setup_bellota  scripts/casper -> 0   (control: la busqueda no dice que si a todo)
```

**EL ORDEN DE PRECEDENCIA, que es la pregunta 4 de la tarea, contestado sin gastar
un arranque** —leído en los dos ficheros, no deducido de uno—:

```
/init:94     for conf in conf/conf.d/*; do . "${conf}" ; done
             -> conf.d/default-layer.conf:  LAYERFS_PATH=minimal.standard.live.squashfs
/init:287    . "/scripts/casper"            (BOOT=casper, de default-boot-to-casper.conf)
/init:292    mountroot
casper:909     parse_cmdline
casper:67-69     layerfs-path=*) export LAYERFS_PATH="${x#layerfs-path=}"
casper:145     mount_images_in_directory -> setup_overlay   <- LEE LA VARIABLE AQUI
```

**La línea del núcleo PISA al `conf.d`**, y no al revés: el `conf.d` se lee en el
paso 94 y `parse_cmdline` reexporta en el 909. **No hay que tocar el initrd.**

#### (b) EL ALGORITMO DE LA CADENA, COPIADO Y NO RESUMIDO (`casper:609-628`)

```sh
layer_name=$(basename ${LAYERFS_PATH%.*})      # quita la extension
layer_ext=${LAYERFS_PATH##*.}                  # squashfs
while :; do
    layer_cur="${layer_dir}/${layer_name}.${layer_ext}"
    if [ ! -f "${layer_cur}" ]; then layer_err="…doesn't exist." ; fi
    layers="${layer_dir}/${layer_name} ${layers}"      # antepone: acaba corta->larga
    parent_layer_name=${layer_name%.*}
    if [ "${parent_layer_name}" = "${layer_name}" ]; then break; fi
    layer_name=${parent_layer_name}
done
if [ -n "${layer_err}" ]; then panic "File system layers are missing:…" ; fi
…
    rofslist="${croot}${imagename} ${rofslist}"        # antepone otra vez: larga->corta
```

**Dos consecuencias que mandan sobre el nombre, y no son opinión:**

1. **CADA ESLABÓN TIENE QUE EXISTIR COMO FICHERO O CASPER HACE `panic`.** No es un
   aviso: es el arranque entero. O sea que el nombre **no se puede elegir libre**:
   tiene que colgar de la cadena que ya existe. `encina.squashfs` daría una cadena
   de un solo eslabón —sin sistema base— y cualquier otro prefijo daría `panic`.
   **`minimal.standard.live.encina.squashfs` es el único nombre posible**, y su
   cadena tiene los cuatro ficheros:

```
minimal.squashfs                        existe en el medio
minimal.standard.squashfs               existe
minimal.standard.live.squashfs          existe
minimal.standard.live.encina.squashfs   la nuestra, renombrada
```

2. **EL DOBLE ANTEPONER DEJA LA MÁS LARGA LA PRIMERA DE `lowerdir`**, y en
   `overlayfs` la primera manda. Cuadra con lo medido en §4.54e, que es su
   control: con `LAYERFS_PATH=minimal.standard.live.squashfs` el invitado enseñó
   `lowerdir=/minimal.standard.live.squashfs:/minimal.standard.squashfs:/minimal.squashfs`
   —tres eslabones, la más larga delante—.

**Y ESTO MATA EL `zz-`, QUE YA ESTABA MUERTO:** el orden alfabético no pinta nada
en esta rama. El nombre no es tipografía, **es la cadena**.

#### (c) LO QUE SE CAMBIA, Y ES POCO A PROPÓSITO

```
imagen/capa-marca.sh    zz-encina.squashfs -> minimal.standard.live.encina.squashfs
                        y el control (a) deja de medir el orden del glob -que es
                        rama MUERTA en este medio- y pasa a medir LA CADENA
imagen/fabricar-iso.sh  layerfs-path=<capa> en la linea del nucleo del grub.cfg,
                        derivado del nombre del fichero y NO escrito a mano
```

#### (d) LAS PREDICCIONES, NUMERADAS Y FALSABLES

| # | Qué predigo | Cómo se falsa |
|---|---|---|
| P1 | `grep encina /proc/mounts` **dentro de la sesión viva** devuelve ≥1 línea, y el `lowerdir=` empieza por `/minimal.standard.live.encina.squashfs` seguido de los **otros tres** | 0 líneas, o una cadena de 3 |
| P2 | `/usr/share/desktop-provision/` **existe** y tiene `whitelabel.yml` | no existe |
| P3 | `/etc/os-release` dice `NAME="Encina OS"` | dice `NAME="Ubuntu"` |
| P4 | **el instalador sigue arrancando** y enseña «Disposición del teclado» en español | «Se produjo un problema», o pantalla que no llega |
| P5 | el **título de la ventana** del instalador deja de decir *Install Ubuntu* | sigue diciéndolo |

**P4 ES LA QUE MENOS CONFIANZA ME MERECE Y HAY QUE DECIRLO ANTES.** La capa pasa
de ser un fichero **que nadie mira** a ser un eslabón **montado encima de todo**,
y `/etc/os-release` cambia debajo de un instalador que lleva tres sesiones
costando. **No está medido que eso sea inocuo.** Si P1–P3 salen y P4 se cae, el
resultado sigue siendo bueno —acota a «la capa montada tira el instalador», que
es información nueva— pero **no es producto**, y entonces hay que mirar qué
fichero de la capa lo tira, uno a uno.

**Y LO QUE NO VOY A CONTAR COMO CAUSA PASE LO QUE PASE:** que (a) y (b) estén
leídos con sus controles **no prueba nada** sobre el medio que arranque. La señal
es `/proc/mounts` **dentro de la sesión viva**, no lo que diga el guion ni lo que
diga esta sección.

#### (e) EL RESULTADO: **LA CAPA SE MONTA.** P1, leída dentro de la sesión viva

Es lo único que contaba, y no lo dice el guion: lo dice `/proc/mounts` del
invitado, tecleado en un `gnome-terminal` de la sesión viva de `p11`.

```
encinaos@encinaos:~$ grep encina /proc/mounts
/cow / overlay rw,relatime,lowerdir=/minimal.standard.live.encina.squashfs:/mini
mal.standard.live.squashfs:/minimal.standard.squashfs:/minimal.squashfs,upperdir
=/cow/upper,workdir=/cow/work,uuid=on,xino=off,nouserxattr 0 0
```

**Cuatro eslabones, el nuestro el primero**, que es carácter por carácter lo que
`banco-cadena.sh` había calculado antes de fabricar nada. **P1 se cumple.** Del
2026-08-15 al 20 esa orden devolvía **cero líneas**; ahora devuelve la capa
encima de todo. **El mecanismo de la casilla 3 está resuelto y medido.**

Y con él caen dos cosas de paso: `casper` **no hace `panic`** con la cadena de
cuatro —lo que confirma que cada eslabón existía—, y **la línea del núcleo pisa
de verdad** al `LAYERFS_PATH` del initrd, que es lo que (a) había leído.

#### (f) Y LO QUE NO SE ESPERABA: **CON LA CAPA REAL, LA SESIÓN GRÁFICA NO LLEGA**

`p10-capa` (`59bc3a3c…`, 0 fallos, 0 avisos, `1 1 1 1`), **dos arranques
completos**, VM `encina-capa-p10` con identificadores propios:

```
arranque 1  -> pantalla NEGRA con el cursor «X» de Xorg, a los 5 min y a los 10
arranque 2  -> los mensajes de systemd salen en texto y TODOS en [ OK ]
               -- ufw, systemd-resolved, NetworkManager, cups, cloud-init,
               snap-ubuntu-desktop-bootstrap-495.mount, gdm.service --
               y al llegar ahi: pantalla NEGRA con el cursor «X»
```

**No es una colgada y hay que decirlo con lo que la separa:** el `debug.log` de
QEMU llega a **92 424 bytes** y se estabiliza —una VM colgada se queda en
**2 759** (§4.54h)—, y la máquina **tiene IP en el `arp` del anfitrión**
(`192.168.64.30` en `76:ce:c4:c4:c4:c4`). O sea que el núcleo arranca, `casper`
monta, `systemd` llega al final y la red sube. **Lo que no llega es la sesión.**

**Y se repitió el arranque a propósito, que es lo que manda la trampa 38:** una
pantalla negra no es un resultado, y un medio arrancó al tercer intento. Aquí
salió **igual las dos veces**, así que sí lo es.

#### (g) LA BISECCIÓN, Y AQUÍ SÍ SE QUITA UNA PIEZA Y CAMBIA EL RESULTADO

**`p11-vacia`**: el **mismo** medio y el **mismo** `layerfs-path=`, con una capa
de **4 096 bytes** que lleva **un solo fichero** —`/usr/share/encina-capa-vacia/LEEME`—
que **no tapa nada** del medio. Todo lo demás, idéntico.

```
p10-capa   capa de 3 084 288 bytes, 30 ficheros, 21 de ellos TAPAN  -> NEGRA (x2)
p11-vacia  capa de     4 096 bytes,  1 fichero,  que no tapa nada   -> ESCRITORIO
                                                                       ENTERO
```

**`p11` arranca al escritorio completo**, con el fondo de Ubuntu, la barra
superior, el reloj, y el instalador abriéndose solo: *«Le damos la bienvenida a
Ubuntu» → «Preparando Ubuntu…» → «Disposición del teclado», en español*, en la
2ª de las once pantallas. Y desde ahí se abrió el `gnome-terminal` de (e).

**LA CONCLUSIÓN, y es la forma que este proyecto acepta —quitar una pieza y ver
cambiar el resultado, no leer un mecanismo—:**

> **El mecanismo NO rompe nada. Lo que tumba la sesión gráfica es el CONTENIDO
> de la capa**, porque es lo ÚNICO que se movió entre los dos medios.

**Y con la precisión que el experimento permite y ni una más:** en `p11` no viajó
**ninguno** de los 30 ficheros, así que lo medido es que **los 30 como grupo**
tumban la sesión. Dentro del grupo hay una división que **no** está medida y sólo
ordena a los sospechosos: **21 TAPAN** un fichero del medio y **9 son rutas
nuevas** que no tapan nada. Los 21 son los primeros a los que mirar; los 9 no
quedan exonerados —`whitelabel.yml` lo lee alguien, aunque sea el instalador—.

**Lo que esto NO dice todavía, y no se adivina:** cuál de los 21. La lectura no
lo delata —los 15 activos gráficos son PNG y SVG válidos, con dimensiones sanas,
y los 6 de texto sólo se diferencian del original del medio en el nombre y en
tres campos de adorno (`HOME_URL`, `SUPPORT_URL`, `X-Ubuntu-Gettext-Domain`)—.
**Y eso es exactamente lo previsto:** leer no produce causas aquí.


#### (h) SEGUNDA BISECCIÓN: **EL CULPABLE ESTÁ ENTRE LOS SEIS FICHEROS DE TEXTO**, y el fondo de Encina ya se ve

`p12-sintexto` (`988b6c2e…`, 0 fallos): la **misma** capa de `p10` con los **seis
ficheros de presentación quitados** y **los otros 24 dentro** —los 15 activos
gráficos y las 9 rutas nuevas—. Verificado dentro del `squashfs` antes de
fabricar, uno a uno, con su control:

```
0  etc/issue                     0  usr/lib/os-release
0  etc/issue.net                 0  usr/share/wayland-sessions/ubuntu.desktop
0  etc/lsb-release               0  usr/share/plymouth/themes/ubuntu-text/ubuntu-text.plymouth
1  usr/share/backgrounds/warty-final-ubuntu.png   <- CONTROL: el resto sigue dentro
huellas: ef15c522… (entera)  vs  5f326fdd… (sin texto)   <- y NO coinciden
```

**El tamaño de las dos capas salió idéntico —3 084 288 bytes las dos— y eso NO
significaba que fueran iguales:** es el relleno de bloque del `squashfs`. Se
comprobó por contenido y por huella, no por tamaño (trampa 13).

```
p10  30 ficheros (los 6 de texto DENTRO)  -> NEGRA, dos arranques
p12  24 ficheros (los 6 de texto FUERA)   -> ESCRITORIO ENTERO + instalador
```

**Y ADEMÁS ES LA PRIMERA VEZ QUE LA MARCA LLEGA A LA SESIÓN VIVA:** en la captura
de `p12` **el fondo ya no es el de Ubuntu**, es el nuestro —la dehesa con el
molino y las amapolas— tapando `warty-final-ubuntu.png` desde la capa. O sea que
**el mecanismo entrega lo que tenía que entregar**; lo que sobra es uno de los
seis. *(El juicio de si se ve BIEN es `[OJOS]` de Jorge; aquí sólo se constata
que el fichero que viaja en la capa es el que se pinta.)*

**Los seis ficheros están limpios a nivel de bytes** —sin BOM, sin CRLF, con
salto de línea final, todo ASCII, con el control sobre el original del medio—,
así que **no es un defecto de codificación**. Otra vez: leer no lo delata.

#### (i) TERCERA BISECCIÓN: **`ubuntu.desktop` QUEDA EXONERADO**, y era mi favorito

Era el sospechoso obvio y **mecanísticamente** el mejor: es **el fichero que
define la sesión que GDM arranca**, y «pantalla negra con el cursor de Xorg» es
exactamente lo que se ve cuando GDM no tiene sesión que lanzar. Se probó en vez
de concluirlo, que es la diferencia entera.

`p13-desktop`: las 24 de `p12` **más `usr/share/wayland-sessions/ubuntu.desktop`
y nada más** —los otros cinco de texto siguen fuera, verificado uno a uno—.

```
p13  24 + ubuntu.desktop  ->  ESCRITORIO ENTERO, fondo de Encina, instalador
                              «Preparando Ubuntu…» y luego «Disposicion del teclado»
```

**Habría sido la QUINTA atribución falsa seguida de la misma familia** —mecanismo
leído + control que pasa + caso que falla— si se hubiera dado por buena. No se
dio. **Quedan CINCO** y el siguiente en la lista es `ubuntu-text.plymouth`,
porque `plymouth-quit-wait.service` es **el último servicio del registro antes de
`gdm.service`** y un plymouth que no suelta la pantalla la deja negra.

**Y un apunte del instrumento, trampa 41 otra vez:** una captura de `p13` dio
**22 271 bytes** con el texto *«Display output is not active»* —que es un mensaje
**de UTM**, no del invitado— y la ventana medía **800×630** en vez de 1280×840. Los
tamaños de captura **no son comparables entre ventanas de distinto tamaño**, ni
siquiera dentro de la misma sesión de trabajo.

#### (j) CUARTA BISECCIÓN: **UN SOLO FICHERO. `ubuntu-text.plymouth`**

`p14-plymouth`: las **mismas 24** de `p12` —que arrancan al escritorio— **más
`usr/share/plymouth/themes/ubuntu-text/ubuntu-text.plymouth` y nada más**. Los
otros cuatro de texto siguen fuera, verificado uno a uno antes de fabricar.

```
p12  24                        -> ESCRITORIO
p13  24 + ubuntu.desktop       -> ESCRITORIO
p14  24 + ubuntu-text.plymouth -> NEGRA
```

**Es una prueba de SUFICIENCIA y por eso vale:** añadir **ese fichero y sólo ese**
a una capa que arranca la deja negra. No es «el mecanismo encaja»: es la pieza
puesta y quitada, con los otros 24 constantes.

**Y encaja con el registro del arranque, que es una confirmación y no la prueba:**
`plymouth-quit-wait.service` es **el último servicio que aparece antes de
`gdm.service`** en la captura de texto de `p11`. Un `plymouth` que no suelta la
pantalla deja a GDM sin ella, y eso es exactamente «negra con el cursor de Xorg»
y todo lo demás sano —`systemd` entero en `[ OK ]`, IP en el `arp`, el
`debug.log` de QEMU en el **mismo rellano de ~92 K** que los medios que sí
arrancan—.

**LO QUE ESTO NO DICE, y no se adivina:** POR QUÉ ese fichero lo rompe. Los bytes
están limpios —sin BOM, sin CRLF, salto final, ASCII— y las claves son las mismas
que el original (`Name`, `Description`, `ModuleName`, `title` y los cuatro
colores). **La causa DENTRO del fichero está `[OMIT]`**, y el camino barato es
volver a bisecar el propio fichero: la sospecha ordenada es que el tema de texto
lo carga también el `plymouth` del **initrd**, donde esta capa **no existe**, y
que la incoherencia entre los dos es lo que cuelga a `plymouth-quit-wait` — pero
**eso es una hipótesis escrita, no una medición**, y en este proyecto no cuenta
hasta que se quite la pieza.

**Consecuencia de producto, y es buena:** los otros **29** ficheros de la capa
están **exonerados por experimento** en tres medios, y con ellos la marca de la
sesión viva —el fondo— ya llega. La capa de producto puede salir **hoy** sin ese
fichero; lo que se pierde es el rótulo del `plymouth` de texto, que es el modo
sin gráficos.

#### (k) **LA (j) ERA FALSA, Y LA TUMBÓ SU PROPIO SEGUNDO ARRANQUE.** La pantalla negra es INTERMITENTE

Se deja escrito al lado lo que se creía dos horas antes, que es lo que manda el
método. **(j) daba `ubuntu-text.plymouth` por causa aislada, por suficiencia.**
Se repitió el arranque de `p14` —trampa 38, que dice que una pantalla negra no es
un resultado— **y el mismo medio, sin tocar nada, arrancó al escritorio entero**:
fondo de Encina, «Disposición del teclado», **Español** marcado en la lista.

```
p14, arranque 1  -> NEGRA   (dos capturas identicas, debug.log en el rellano de 92 K)
p14, arranque 2  -> ESCRITORIO ENTERO, instalador en espanol   <- MISMO MEDIO
```

**HABRÍA SIDO LA QUINTA ATRIBUCIÓN FALSA SEGUIDA**, y esta vez ni siquiera por
leer código: por tomar **un** arranque negro como negativo. La trampa 38 estaba
escrita desde hace días y aun así se cayó en ella al escribir (j).

**LO QUE ESTO SE LLEVA POR DELANTE, dicho entero:**

> **Todos los «NEGRA» de (f), (g), (h), (i) y (j) son NEGATIVOS NO FIABLES.** El
> bisecado se construyó sobre ellos y **no vale como bisecado**. `ubuntu.desktop`
> **no queda exonerado** por (i): lo único que dice `p13` es que **puede**
> arrancar con él.

**LO QUE SÍ SOBREVIVE, y no es poco, porque son POSITIVOS:**

1. **LA CAPA SE MONTA.** (e) es una lectura directa de `/proc/mounts` dentro de la
   sesión viva, con los cuatro eslabones y el nuestro el primero. **Eso no
   depende de ningún arranque negro.** Es la casilla 3 en lo que pedía.
2. **EL MECANISMO NO IMPIDE EL ESCRITORIO.** `p11`, `p12`, `p13` y `p14` —cuatro
   medios distintos, todos con la capa **montada** por `layerfs-path=`— llegan al
   escritorio y abren el instalador **en español**.
3. **LA MARCA LLEGA A LA SESIÓN VIVA.** El fondo de Encina se ve en `p12`, `p13`
   y `p14`. Es lo que la casilla perseguía desde el 2026-08-15.
4. **Y UN HECHO NUEVO DEL BANCO, que vale para todo lo que venga: en este
   anfitrión el arranque gráfico del medio FALLA A VECES**, y el fallo se ve
   igual que un fallo de producto —negra, `systemd` entero en `[ OK ]`, IP en el
   `arp`, `debug.log` en el rellano de ~92 K—. **Un arranque no es una medición;
   hacen falta varios, y un «negra» sólo cuenta si se repite.**

**LO QUE QUEDA ABIERTO, con su nombre:** si la capa **entera** deja arrancar. `p10`
va **negra en dos** de dos; los tres medios sin `ubuntu-text.plymouth` fueron al
escritorio **a la primera**, y los dos que lo llevan son los dos que se pusieron
negros. **Eso es una correlación sobre cinco medios, no una causa**, y con un
fallo intermitente de por medio hace falta **contar arranques**, no mirar uno.

#### (l) **Y `p10` ARRANCA AL TERCER INTENTO: LA CAPA ENTERA NO ROMPE NADA**

Se le dio el tercer arranque que pedía la trampa 38 —«un medio arrancó al tercer
intento», escrito ahí desde hace días— y **`p10-capa`, con los TREINTA ficheros,
llegó al escritorio**: fondo de Encina, y el instalador en **«Disposición del
teclado» con Español marcado**, la 2ª de las once pantallas.

**Con eso se cae también la correlación de (k)** —«los dos medios con
`ubuntu-text.plymouth` son los dos que se pusieron negros»—: los dos han acabado
arrancando. **No queda ni un fichero bajo sospecha.** Lo único que había era el
fallo intermitente del banco.

**Y las tres predicciones que faltaban, leídas DENTRO de `p10`**, que es el medio
de producto entero:

```
encinaos@encinaos:~$ cat /etc/os-release; ls /usr/share/desktop-provision
PRETTY_NAME="Encina OS 24.04 LTS"
NAME="Encina OS"
VERSION_ID="24.04"
VERSION="24.04.4 LTS (Noble Numbat)"
VERSION_CODENAME=noble
ID=ubuntu
ID_LIKE=debian
UBUNTU_CODENAME=noble
LOGO=encina-logo
images  slides  whitelabel.yml
```

**El 2026-08-17 esas dos órdenes daban `NAME="Ubuntu"` y «No existe el archivo o
el directorio» (§4.54d).**

#### (m) EL MARCADOR DE LAS PREDICCIONES DE (d)

| # | qué predije | resultado |
|---|---|---|
| P1 | `grep encina /proc/mounts` da ≥1 línea, cadena de 4 con la nuestra la 1ª | **ACIERTO**, y carácter por carácter |
| P2 | `/usr/share/desktop-provision/` existe con su `whitelabel` | **ACIERTO** |
| P3 | `/etc/os-release` dice `NAME="Encina OS"` | **ACIERTO** |
| P4 | el instalador sigue arrancando, «Disposición del teclado» en español | **ACIERTO** — y era la que menos confianza me merecía, dicho por escrito antes |
| P5 | el título de la ventana deja de decir *Install Ubuntu* | **`[OMIT]`**: las capturas enseñan el título de la PÁGINA («Disposición del teclado»), no el `app-name`. No se ha medido |

**Cinco de cinco medidas, cuatro aciertos y una sin medir.** Y aun así el día
produjo **una atribución falsa** —(j)— que duró dos horas y la tumbó repetir un
arranque: acertar las predicciones **no protege** de concluir de más entre medias.

**LO QUE QUEDA `[OMIT]` Y NO SE CUELA:**

- **P5**, el título de la ventana del instalador.
- **La capa entera arranca 1 de 3**; los medios de bisecado fueron 1 de 1, 1 de 1
  y 1 de 1, y `p14` 1 de 2. **No hay conteo suficiente para decir que la capa no
  afecta a la PROBABILIDAD de arrancar**, sólo para decir que no lo impide.
- **La causa del fallo intermitente del banco.** Contamina cualquier medición de
  arranque que se haga en este anfitrión.


---

### 4.59 CONTAR ARRANQUES: separar el fallo intermitente del banco de un posible efecto de la capa (2026-08-20, noche)

**POR QUÉ ESTA MEDICIÓN Y NO OTRA.** §4.58j–l dejó el banco bajo sospecha y con
él **cualquier** medición de arranque que se haga en este anfitrión: esta misma
tarde se
escribió una causa (`ubuntu-text.plymouth`) sobre **un** arranque negro, y la
tumbó **repetir**. Mientras la tasa de fallo del anfitrión no esté acotada, no se
puede bisecar nada. Esto la acota.

#### (a) LA PREDICCIÓN, ESCRITA ANTES DE ARRANCAR NADA

Se escribe **antes** de fabricar el instrumento y **antes** del primer arranque,
y se deja aquí para que el resultado no se interprete solo. Van **cinco**
atribuciones falsas en este repositorio, y la de esta tarde **no fue por leer mal el
código**: fue por tomar **un** arranque negro como un negativo.

**EL DATO DE PARTIDA, y es todo lo que hay** (§4.58, y las tres primeras filas
vienen de sesiones distintas):

| medio | qué lleva la capa | arrancó |
|---|---|---|
| `p10-capa` | los 30 ficheros | **1 de 3** |
| `p11-vacia` | 1 fichero que no tapa nada | 1 de 1 |
| `p12-sintexto` | 24 (los 6 de texto fuera) | 1 de 1 |
| `p13-desktop` | 24 + `ubuntu.desktop` | 1 de 1 |
| `p14-plymouth` | 24 + `ubuntu-text.plymouth` | **1 de 2** |

Es una **correlación sobre cinco medios con N=1..3**. No es una causa, y con un
fallo intermitente de por medio un «arranca» vale a la primera pero un **«no
arranca» hay que contarlo**.

**LOS TRES BRAZOS**, elegidos porque **ya están en disco** y no cuestan una ISO
(el disco manda: 12 GiB libres, nueve ISOs). Cotejados por `inode` contra el
`medio.iso` de su bundle antes de empezar:

| brazo | ISO | inode | la capa |
|---|---|---|---|
| `p10` | `encina-os-p10-capa.iso` | 90350889 | entera (30 ficheros) y **montada** |
| `p11` | `encina-os-p11-vacia.iso` | 90351676 | **montada** pero vacía (1 fichero inocuo) |
| `p9` | `encina-os-p9-nutria.iso` | 90347109 | **presente pero INERTE** (sin `layerfs-path=`) |

`p9` es el control de fondo: lleva el squashfs dentro pero el núcleo **no lo
nombra**, así que su arranque es el de un medio sin capa. `p11` separa «montar
una capa» de «lo que la capa contiene».

**QUÉ ESPERO, con probabilidad dicha antes:**

- **~70 %: es el banco.** Las tres tasas salen parecidas y **los controles
  también fallan alguna vez**. Razón: la única señal a favor de un efecto de la
  capa —los dos medios con reintento son los dos que llevan `ubuntu-text.plymouth`—
  ya se cayó una vez, y `p10` acabó arrancando **con la capa entera puesta**, o
  sea que la capa **no impide** arrancar. Un fallo que a veces no ocurre con la
  causa presente es un fallo del entorno mucho más a menudo que del producto.
- **~25 %: hay efecto y es de grado**, no de suficiencia: la capa entera hace el
  arranque más frágil (más ficheros que leer del squashfs de arriba, más presión
  de E/S en un arranque ya justo).
- **~5 %: el banco no falla en absoluto esta noche** y los tres brazos salen limpios.
  Sería el peor resultado: no probaría nada y dejaría el `[OMIT]` abierto, porque
  el fallo de esta tarde seguiría sin explicar.

**QUÉ CONSIDERO SEÑAL Y QUÉ CONSIDERO RUIDO, dicho antes de ver un solo número.**
Con `E` = arranques que llegan al escritorio y `N` = arranques por brazo:

1. **PRUEBA DE QUE EL FALLO ES DEL BANCO** (y es el objetivo primario, y se
   alcanza con N pequeño): **basta con que `p11` o `p9` fallen al menos una vez.**
   Un control conocido-bueno que falla es el fallo intermitente **sin la capa
   entera de por medio**, y eso cierra el `[OMIT]` de §4.58 en positivo.
2. **SEÑAL DE EFECTO DE LA CAPA:** `p10` contra la **unión** de los dos controles
   por **Fisher exacta de una cola con `p ≤ 0,05`**. Con N=5 por brazo (5 vs 10)
   eso exige `p10 ≤ 1/5` con los controles a `10/10`, o `p10 = 0/5` con los
   controles a `9/10`. **Cualquier cosa por encima de eso es RUIDO** y se escribe
   como `[OMIT]`, no como «tendencia».
3. **RUIDO EXPLÍCITO:** una diferencia de **un solo arranque** entre brazos no es
   nada. Con tasas alrededor del 50 % y N=5, ver 3/5 frente a 5/5 por puro azar
   es corriente. **No voy a llamar a eso «peor».**
4. **LO QUE NO VOY A HACER:** concluir con menos de **4 rondas completas**. Si el
   experimento se corta antes, el resultado entero es `[OMIT]` y se dice.

**EL PRESUPUESTO, dicho antes de empezar.** Un arranque hasta el escritorio son
~6–10 min; la ventana de observación se fija en **8 min** por arranque, más el
apagado en frío. Una ronda son los tres brazos: **~27 min**. **Objetivo: 5
rondas** (15 arranques, ~2 h 15). **Mínimo para concluir: 4.**

**Y EL ORDEN ES INTERCALADO —`p10`, `p11`, `p9`, `p10`, `p11`, `p9`…— y NO por
bloques.** La carga de este anfitrión deriva a lo largo de la sesión, y en
bloques la deriva se confunde con el efecto: el brazo que toque el mal rato
saldría peor sin que la capa tenga nada que ver. Es exactamente el error que
convierte una correlación en una causa falsa.

**LA TRAMPA QUE ME PUEDE MORDER HOY.** La 42 estaba escrita **antes** de la
sesión de esta tarde y aun así se cayó en ella. La forma concreta que tomaría
ahora:
tomar la primera ronda como resultado porque «ya se ve la tendencia». Por eso el
criterio está escrito arriba, con números, antes de que exista el primer dato.

#### (b) EL INSTRUMENTO, CONSTRUIDO ANTES QUE EL EXPERIMENTO, CON SU CONTROL

**Lo primero que se descartó es el tamaño del PNG**, que es lo que la trampa 41
proponía: sólo separa las tres pantallas **a escala fija**, y la ventana del
anfitrión cambia de tamaño sola. Se cuenta otra cosa: **cuántos colores distintos
hay** (cuantizados a 5 bits por canal, para no perseguir ruido de compresión) más
el **brillo medio**. Reducir una imagen no crea colores donde no los hay.

**DE DÓNDE SALE LA CAPTURA, y esto resultó ser la mitad del instrumento.** UTM
escribe `screenshot.png` dentro del bundle con el **framebuffer del invitado**:
**1280×800 fijos**, sin la barra de la ventana del anfitrión y sin necesitar el
permiso de Grabación de Pantalla. **La trampa 41 no le aplica porque no hay
ventana de por medio.** Medido hoy, y las dos mitades hicieron falta:

```
VM arrancada, 3 min:  mtime del screenshot.png = 16:11:52 (el de AYER), 598 369 b
                      -> NO se actualiza en vivo. Sirve DESPUES de parar.
utmctl stop:          mtime 17:00:35, 13 560 b  -> SI lo reescribe al parar
```

**Y la segunda mitad, que es la que salva de una atribución falsa.** Ese `stop`
escribió una pantalla de **1 color y brillo 0,0**. Con eso sólo, caben dos
lecturas: **(A)** `p12` falló el arranque, o **(B)** UTM captura el framebuffer
**ya apagado** y entonces diría «negra» siempre y el instrumento no vale. Se
separaron arrancando `p12` otra vez, **mirándola viva** con `capturar-vm.sh` —
estaba en el instalador, «Disposición del teclado» en español — y parándola
**desde ahí**:

```
parada DESDE el instalador   ->  3 638 colores, brillo 194,65   GRAFICA
parada tras arranque fallido ->      1 color,   brillo   0,00   NEGRA
```

**El instrumento distingue, y por tanto aquel negro era un fallo de verdad.** Sin
este control se habría contado un fallo que podía no serlo — o descartado el
instrumento por bueno. Es la regla del sitio en su forma más literal: *una
comprobación que no puede dar sus dos respuestas no es una comprobación.*

**Y DE PASO, UN DATO QUE NO SE BUSCABA: `p12` FALLÓ HOY SU PRIMER ARRANQUE Y
ARRANCÓ EL SEGUNDO**, sin tocar nada. `p12` es el medio que esta tarde hizo 1 de 1.
**Es la trampa 42 reproducida en un medio que no es `p10` ni `p14`**, o sea en
uno que **no** lleva `ubuntu-text.plymouth`. Esto ya apunta a que el fallo no es
de un fichero de la capa, pero **es un arranque**: se cuenta abajo, no aquí.

**LOS DOS INSTRUMENTOS NUEVOS:**

- **`scripts/veredicto-pantalla.py`** — lee una captura y dice `NEGRA`,
  `GRAFICA`, `TEXTO?` o `INDETERMINADA`. **La zona gris entre bandas es
  deliberada**: un instrumento que se calla donde no sabe vale más que uno que
  decide. `TEXTO?` se declara **sin control conocido** y no se da por buena.
- **`scripts/banco-veredicto.sh`** — **9 correctas, 0 fallos**. Extrae la regla
  del guion entre marcadores y **se niega a medir si la extracción sale corta**
  (exige ≥12 líneas, ≥4 umbrales y ≥4 salidas distintas). Cuatro secciones:

```
1. las dos respuestas, sobre capturas de VERDAD (no fabricadas para pasar)
2. CONTROL POR COLUMNA: negra y grafica no pueden dar el mismo veredicto
3. la trampa 41: los dos controles a la MITAD (640x400) dan el MISMO veredicto
4. tres sabotajes, y los tres se notan
```

Los controles son capturas reales y viven en `scripts/pruebas/veredicto/`. El
**control gráfico que aprieta** es `encina-nutria`: con la capa inerte, el fondo
es el **púrpura de Ubuntu** y da sólo **585 colores** — el gráfico más pobre que
hay, y el que fija el umbral por abajo.

#### (c) UNA ENMIENDA AL PRESUPUESTO DE (a), ESCRITA ANTES DEL PRIMER ARRANQUE

La predicción fijó la ventana de observación en **8 min** «porque un arranque son
6–10 min». **Medido hoy: no lo son.** `p12` mostraba el instalador ya en la
captura de los **90 s**. La ventana baja a **420 s**, que sigue siendo **4,6×** el
arranque bueno observado.

**Y se retira la prórroga que iba a llevar el guion.** La idea era mirar en vivo
a mitad de ventana y alargar si aún no había escritorio; se descarta porque daría
**trato distinto a los brazos** —sólo se alargaría en los fallos— y la carga del
anfitrión es justo la variable que hay que mantener constante. **Ventana fija e
idéntica para los tres.** El criterio de señal de (a) **no cambia**: sigue siendo
Fisher exacta de una cola con `p ≤ 0,05`, sea cual sea el N que se alcance.

#### (d) EL ANALIZADOR, TAMBIÉN ANTES DE VER UN DATO — Y UNA CORRECCIÓN A (a)

`scripts/veredicto-conteo.py` lee el TSV y aplica **el criterio de (a) y nada
más**. Fisher exacta por la hipergeométrica con `math.comb`, sin dependencias.
Su banco (`--banco`): **8 correctas, 0 fallos**, con casos de respuesta conocida
calculada a mano, **control por columna** —si devolviera siempre «señal» o
siempre «ruido», los casos 1 y 4 lo cazan— y una comprobación de que **la cola
es la declarada**: `10/10` frente a `0/5` da `p = 1,0000`, no señal.

**Y AL EJECUTARLO SALTÓ UN ERROR MÍO DE (a), que se corrige ahora que todavía no
hay datos y dejando al lado lo que decía.** (a) ilustró el umbral así:

> «Con N=5 por brazo (5 vs 10) eso exige `p10 ≤ 1/5` con los controles a `10/10`,
> o `p10 = 0/5` con los controles a `9/10`.»

**La ilustración era más estricta que el criterio.** Calculado:

```
0 de 5 frente a 10 de 10   p = 0,000333   señal
1 de 5 frente a 10 de 10   p = 0,003663   señal
2 de 5 frente a 10 de 10   p = 0,021978   señal  <- ESTE me lo dejé fuera
3 de 5 frente a 10 de 10   p = 0,095238   ruido
```

**El criterio operativo sigue siendo el mismo y no se toca: Fisher de una cola
con `p ≤ 0,05`.** Lo que estaba mal era el ejemplo, no la regla; pero un ejemplo
mal puesto es un umbral movido a mano después, y por eso queda escrito. La regla
la aplica el guion, no yo.

#### (e) EL CONTEO: 18 ARRANQUES, 6 RONDAS INTERCALADAS, VEREDICTO CONTADO

`./scripts/contar-arranques.sh --rondas 6 --ventana 420`, de 17:18 a 19:27, con
cadencia de **7 min 11 s por arranque** y **ninguna** línea `FALLO-SIN-CAPTURA`
—o sea que UTM reescribió el framebuffer las 18 veces y no se leyó dos veces el
mismo dato—:

```
R1  p10 GRAFICA   p11 GRAFICA   p9  NEGRA
R2  p10 NEGRA     p11 GRAFICA   p9  GRAFICA
R3  p10 GRAFICA   p11 GRAFICA   p9  NEGRA
R4  p10 GRAFICA   p11 GRAFICA   p9  NEGRA
R5  p10 GRAFICA   p11 NEGRA     p9  GRAFICA
R6  p10 NEGRA     p11 GRAFICA   p9  GRAFICA
```

| brazo | qué lleva la capa | arrancó |
|---|---|---|
| `p10` | entera, montada | **4 de 6** |
| `p11` | vacía, montada | **5 de 6** |
| `p9` | presente pero **inerte** | **3 de 6** |

**EL CRITERIO DE (a), APLICADO POR `veredicto-conteo.py` Y NO POR MÍ:**

```
== 1. EL OBJETIVO PRIMARIO
  [OK]    un control conocido-bueno FALLA (p11: 1, p9: 3)
          -> el fallo intermitente existe SIN la capa entera de por medio

== 2. SENAL DE EFECTO DE LA CAPA: p10 contra la union de p11+p9
  p10        arranco 4, fallo 2
  controles  arranco 8, fallo 4
  Fisher exacta de una cola: p = 0.6942   (umbral 0.05)
  [OMIT]  p > 0.05: NO hay senal.
```

**LO QUE QUEDA MEDIDO, y era el `[OMIT]` que bloqueaba todo lo demás:**

1. **EL FALLO INTERMITENTE ES DEL BANCO.** Tasa global: **6 fallos de 18, un
   33 %**. Y **los TRES brazos fallan** —capa entera, capa vacía y capa inerte—,
   incluido `p9`, que lleva el squashfs dentro pero **el núcleo no lo nombra**, o
   sea que arranca como un medio sin capa.
2. **LA CAPA NO AFECTA A LA PROBABILIDAD DE ARRANCAR.** `p = 0,6942`, ni de
   lejos. Y el brazo que sale **peor en bruto es `p9`, el de la capa inerte**:
   justo el que la hipótesis del efecto habría puesto el mejor.
3. **LA CORRELACIÓN DE `ubuntu-text.plymouth` SE CAE DEL TODO.** Era «los dos
   medios que necesitaron reintento son los dos que lo llevan». Hoy `p11` y `p9`
   lo necesitaron **sin llevarlo**. Ya no queda ni la correlación.

**Y ASÍ QUEDA LA TABLA DE §4.58, QUE ERA LA QUE PEDÍA CAUSA:** con una tasa de
fallo del anfitrión del 33 %, ver `1 de 3` en `p10` y `1 de 1` en tres medios de
bisección **es lo que se espera por azar** — la probabilidad de que un medio
bueno dé `1 de 1` es 0,67, y `1 de 3` en otro no pide explicación ninguna. **Los
cuatro bisecados de esta tarde no midieron nada del producto.**

#### (f) UN HALLAZGO QUE NO SE BUSCABA, Y ES POST-HOC: UN FALLO EXACTO POR RONDA

Se dice **post-hoc** porque el patrón se vio **después** de mirar los datos, y
eso lo baja de resultado a hipótesis. Pero es demasiado limpio para no escribirlo:

```
ronda 1: 1 fallo de 3      ronda 4: 1 fallo de 3
ronda 2: 1 fallo de 3      ronda 5: 1 fallo de 3
ronda 3: 1 fallo de 3      ronda 6: 1 fallo de 3
```

**Ni una ronda con cero, ni una con dos.** Con la tasa medida (1/3) y arranques
independientes, la probabilidad de que una ronda dé exactamente un fallo es
0,4444, y la de que **las seis** lo den es **0,0077 — una entre 130**.

**Lo que sugiere, y es DEDUCCIÓN, no medición:** los fallos **no son
independientes entre sí**. Algo del anfitrión se agota y se repone, de forma que
cada tres arranques hay uno que cae, en vez de que cada arranque tire un dado por
su cuenta. **No está medido qué**, y `debug.log` no lo separa: en los 18
arranques se queda en el rellano de ~92 KB tanto si la pantalla acaba negra como
si acaba en el instalador (91 935 – 92 402), **que es la trampa 38 confirmada
otra vez**. Para el conteo de esta noche da igual —la tasa es la tasa, y el intercalado
reparte esa estructura entre los tres brazos por igual—, pero **es la pista
concreta para el día que se quiera arreglar el banco en vez de rodearlo**.

**Y EL POST-HOC QUE ME OBLIGUÉ A CALCULAR, porque es la trampa de este día:**
`p9` sale `3 de 6`, el peor. Si la hipótesis se hubiera escrito señalando a `p9`
en vez de a `p10`, ¿habría «señal»? **No: `p = 0,2943`.** Es la comprobación de
que el resultado no depende de a qué brazo se apuntara.

#### (g) UN FALLO DE DISEÑO DEL EXPERIMENTO, MÍO, Y NO LO INVALIDA PERO HAY QUE DECIRLO

**El orden intercalado fue SIEMPRE el mismo: `p10`, `p11`, `p9`.** Eso resuelve
lo que se quería resolver —la deriva de carga le cae a los tres por igual, que
era el motivo de no ir por bloques— pero **confunde perfectamente el brazo con la
posición dentro de la ronda**. `p10` fue siempre el 1.º, `p11` siempre el 2.º y
`p9` siempre el 3.º, así que un efecto de **posición** («el tercero de cada ronda
falla más») sería indistinguible de un efecto **del medio**.

**Hoy no cambia la conclusión**, porque la conclusión es que **no** hay
diferencia: si ni siquiera separando se ve efecto, la confusión no puede estar
escondiendo uno. Pero **si hubiera salido señal, no habría podido decir de qué
era**, y me habría llevado a bisecar un producto por un artefacto del banco —que
es exactamente el error del 2026-08-20 con otra cara—. **Lo que hay que hacer la
próxima vez: barajar el orden dentro de cada ronda.** Queda escrito en la
trampa 44 y sin implementar: `contar-arranques.sh` sigue recorriendo `BRAZOS` en
orden fijo, y no se toca hoy porque cambiarlo ahora invalidaría la comparación
con estos 18 arranques.

#### (h) EL MARCADOR DE LAS PREDICCIONES DE (a)

| # | qué predije, antes de arrancar nada | resultado |
|---|---|---|
| ~70 % | **es el banco**: tasas parecidas y los controles fallan también | **ACIERTO**, y por el camino más fuerte: fallan **los tres** brazos |
| ~25 % | hay efecto de grado: la capa entera hace el arranque más frágil | **NO**: `p = 0,6942`, y el peor brazo es el de capa inerte |
| ~5 % | el banco no falla hoy y no se prueba nada | **NO**: falló 6 de 18 |
| criterio 1 | basta con que un control falle para cerrar el `[OMIT]` | **se cumplió en la RONDA 1**, con `p9` |
| criterio 3 | «una diferencia de un solo arranque no es nada» | **hizo falta**: `p11` 5/6 y `p9` 3/6 se leerían como efecto sin él |

**Acerté la predicción principal, y aun así el día produjo dos cosas que no
estaban previstas:** el patrón de (f) y el fallo de diseño de (g). Como el
2026-08-20: acertar lo que se predice **no protege** de lo que no se predijo.

**LO QUE QUEDA `[OMIT]` Y NO SE CUELA:**

- **Qué causa el fallo del 33 %.** Está **acotado** —es del anfitrión, no del
  producto— pero **no explicado**. La pista es (f).
- **Si el patrón de un fallo por ronda se sostiene**, que es post-hoc y necesita
  su propia predicción escrita antes.
- **El efecto de la posición dentro de la ronda**, indistinguible hoy por (g).

---

### 4.60 `construir-todo.sh` ENTERO Y LA REPRODUCIBILIDAD, PAGADA (2026-08-21)

**Era lo más viejo sin pagar.** Todos los medios del 20 salieron de
`fabricar-iso.sh --repo`, o sea por el camino corto y local: **la vuelta entre
las dos máquinas estaba sin ejercitar**, y la definición de terminado del guion
—`AGENTS.md`— no es «sale una ISO» sino que **dos pasadas den la misma huella**.

**LOS INGREDIENTES, cotejados antes y no supuestos:**

```
constructor : jorge@192.168.64.3 -> encina-dev, aarch64, Ubuntu 24.04, por clave
autofirma   : el manifiesto pide 1.9.1+encina4 con huella faeca3a9...
              y el .deb presente da faeca3a9...  -> cuadra
arbol       : limpio, commit 48bc1e49
```

**LAS DOS PASADAS, cada una completa y con sus controles internos:**

```
pasada 1 -> medios/encina-os-r1.iso   sha256 59bc3a3c...e946e1d4   0 fallos
pasada 2 -> medios/encina-os-r2.iso   sha256 59bc3a3c...e946e1d4   0 fallos

[OK]    DOS PASADAS, LA MISMA HUELLA        <- la definicion de terminado
```

**Y UNA COINCIDENCIA QUE NO SE BUSCABA Y VALE MÁS QUE LAS DOS PASADAS:** esa
huella **es la de `p10-capa`**, el medio de producto que se fabricó el 20 **por
el otro camino**, con `fabricar-iso.sh --repo` en local. Comprobado a mano:

```
r1        : 59bc3a3c3b86cda3b15958aff2fe744d45733f290e9772aa214446eae946e1d4
p10-capa  : 59bc3a3c3b86cda3b15958aff2fe744d45733f290e9772aa214446eae946e1d4
IGUALES      3 721 265 152 bytes los dos
```

**Dos caminos distintos, en días distintos, dan el mismo medio bit a bit.** El
largo pasa por `git archive HEAD`, `ssh` al constructor Ubuntu para los tres
`.deb`, la cosecha de 28 por huella, el `Packages` generado allí y la vuelta al
Mac; el corto no sale de aquí. **Es una reproducibilidad cruzada**, y es más
fuerte que repetir la misma orden dos veces: descarta que la huella dependa del
camino. Lo que la segunda pasada añade —y por eso se pagó igual— es que el
**camino largo** es reproducible **consigo mismo**, que es lo que dice la
definición de terminado.

**LO QUE PASARON LOS CONTROLES INTERNOS, y son suyos, no míos:**

```
[FALLO] el repositorio NO esta completo: 0 no cuadran, 1 ausentes
        <- ES EL CONTROL: la 1a orden sale incompleta A PROPOSITO
[OK]    los 28 .deb estan y sus huellas cuadran con el manifiesto
[OK]    las 28 huellas cuadran a los dos lados            <- la ida y vuelta
[OK]    control: con una huella cambiada en UN caracter, el cotejo la senala
[OK]    30 ficheros de la capa, ni uno mas ni uno menos
[OK]    modificados exactamente 3: /md5sum.txt /boot/grub/grub.cfg /.disk/info
[OK]    las 267 lineas de md5sum.txt cuadran con la ISO construida
[OK]    control: con el md5sum.txt OFICIAL fallan exactamente 2 lineas
[OK]    control: sobre la ISO oficial el lector no encuentra ninguno de los cuatro
[OK]    el medio lleva exactamente lo pedido (capa volid info menu): 1 1 1 1
```

**LO QUE SIGUE `[OMIT]` Y EL PROPIO GUION LO DICE:** **que arranque**. Esto no lo
puede decir `construir-todo.sh`, y con el 33 % de §4.59 de por medio, decirlo
exige **contar**, no un arranque. Como `r1` es **bit a bit** `p10-capa`, lo que
§4.59 midió de `p10` —**4 de 6**— es exactamente lo que se sabe de este medio.

#### (a) UNA TRAMPA DEL ENTORNO, CAZADA POR SU CONTROL Y NO POR MIRAR

Al ir a arrancar el constructor, `utmctl start encina-dev` falló **dos veces**
con `OSStatus error -1712` y la VM se quedó `stopped`. **La conclusión fácil era
«`encina-dev` está rota»** —y habría sido la quinta atribución falsa del
proyecto, por el mismo camino que las otras cuatro—.

**El control costó un minuto:** arrancar una VM que se sabía buena. **`p11`
tampoco arrancó**, con el mismo error, y `p11` había arrancado **5 de 6** veces
esa misma noche. O sea que **no era la VM: era UTM**, sordo a los `start`
mientras seguía contestando `list` y `status` sin protestar.

```
utmctl list / status  ->  contestan bien, 19 VMs
utmctl start <la que sea>  ->  OSStatus error -1712, y la VM sigue stopped
quit por AppleScript  ->  no cierra;  open -a UTM  ->  error -609
```

**Se destrabó con `open -a UTM`** —el proceso seguía vivo todo el rato, PID
35881— y a partir de ahí `start` volvió a funcionar a la primera. Queda escrito
como trampa 45.
