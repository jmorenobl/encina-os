# Mediciones de Encina OS

Registro de lo medido, con las salidas literales de los comandos. **No se
resume aquí nada: se conserva tal como se escribió el día que se midió**,
correcciones incluidas. Reproducir estas mediciones cuesta sesiones de máquina
virtual, y buena parte ya no se puede reproducir porque el `.deb` oficial de
AutoFirma que las produjo ha dejado de ser el que Encina OS usa.

Última actualización: 10 de agosto de 2026.

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
| **Desaparece el icono de Firefox** | Se pierde el lanzador al instalar, en una sesión ya abierta | `NoDisplay=true` en la sombra. GNOME Shell retira el icono al instante por inotify pero no relee los favoritos por defecto hasta iniciar sesión (D11) |
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
| Fallos raros con software de terceros | Instaladores y scripts que no reconocen el sistema | Se cambió `ID` en `os-release` |
| Fondo claro en modo oscuro | Solo en tema oscuro | Falta `picture-uri-dark` (GNOME 42+) |
| Builds no reproducibles | Dos builds del mismo commit difieren | Falta fijar fecha de snapshot del mirror |

