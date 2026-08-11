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

## 9. Trampas conocidas

Registro para no redescubrirlas. Todas verificadas en la investigación previa.

| Trampa | Síntoma | Causa |
|---|---|---|
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
| **`certutil` crea lo que iba a inspeccionar** | Un diagnóstico deja bases de datos NSS nuevas por los perfiles | `certutil -A` crea `cert9.db` si no existe; `-L` no (falla con `SEC_ERROR_BAD_DATABASE`, rc=255, sin tocar nada). Una herramienta de diagnóstico solo usa `-L`, y trata ese error como «sin almacén», no como fallo |
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
| Fallos raros con software de terceros | Instaladores y scripts que no reconocen el sistema | Se cambió `ID` en `os-release` |
| Fondo claro en modo oscuro | Solo en tema oscuro | Falta `picture-uri-dark` (GNOME 42+) |
| Builds no reproducibles | Dos builds del mismo commit difieren | Falta fijar fecha de snapshot del mirror |

