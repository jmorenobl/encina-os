# Mediciones de Encina OS

Registro de lo medido, con las salidas literales de los comandos. **No se
resume aquí nada: se conserva tal como se escribió el día que se midió**,
correcciones incluidas. Reproducir estas mediciones cuesta sesiones de máquina
virtual, y buena parte ya no se puede reproducir porque el `.deb` oficial de
AutoFirma que las produjo ha dejado de ser el que Encina OS usa.

Última actualización: 8 de agosto de 2026.

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
| §4.10 | R10 y `encina-meta`: por qué vía llega Firefox nativo | Sí. Es lo que decide que E1 no se para, y corrige el motivo escrito en `AGENTS.md` §6.3. **Su apartado (h) queda corregido por §4.11c** |
| §4.11 | E1 ejecutado en una VM con escritorio | Sí. Cierra lo que §4.10 dejaba deducido, y tumba el `Recommends: libreoffice-l10n-es` con su motivo escrito |
| §4.12 | El positivo sobre una máquina virgen instalada por la secuencia | Sí. Las seis barreras cerradas ahí, **y el defecto de orden que deja AutoFirma sin CA en el navegador**. Contiene además la única técnica conocida para mirar la pantalla de una VM sin ojos |
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
positivo de §4.9. La línea base virgen de la que sale todo lo nuevo tiene otra
tarjeta. El diff completo de las dos configuraciones de UTM da **exactamente una
diferencia**, esa. **Un resultado visual medido en una familia no vale
automáticamente en la otra**, y eso afecta hacia atrás: el `[OMIT]` del splash de
Plymouth se midió en `encina-dev`, que es de la otra familia.

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

**g) Qué hacer con `encina-limpia-respaldo`. Propuesta, no ejecutada.** De ella
salen todos los clones nuevos, y hoy es `virtio-ramfb-gl`: **cada clon nace con la
interfaz de AutoFirma invisible**, y quien lo herede volverá a perseguirlo.
Recomendación: **ponerla en `virtio-gpu-pci`**, desde la interfaz de UTM, y
comprobarlo con (e). Razones y objeción, para que se decida con las dos delante:

- A favor: iguala las siete VMs, retira una variable que ya ha estropeado dos
  mediciones, y **no toca el disco** — es configuración del emulador, no del
  sistema instalado, así que ningún resultado de paquetes o de apt cambia.
- La objeción seria: **el defecto es real y el usuario final puede tenerlo.** Si
  Encina se instala algún día sobre una máquina con una pila gráfica parecida a
  `ramfb`+virgl, AutoFirma se verá negra. Igualar las VMs **esconde ese caso**.
  Por eso la recomendación va con una condición: dejar `encina-snap-fabrica` en
  `virtio-ramfb-gl` como testigo de la familia, ya que sus mediciones están
  grabadas y es candidata a borrar de todos modos. Sale gratis conservar un caso
  reproducible del fallo.
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

