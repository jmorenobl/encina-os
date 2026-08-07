# Encina OS — Documento maestro

**Punto de entrada único del proyecto.** Si no sabes por dónde seguir, lee la
sección 7 («Empieza aquí») y nada más.

Última actualización: 7 de agosto de 2026

---

## 0. Los documentos y para qué sirve cada uno

| Documento | Papel | Cuándo abrirlo |
|---|---|---|
| **ENCINA-OS.md** (este) | Índice, estado y siguiente acción | Siempre primero |
| `AGENTS.md` | Instrucciones ejecutables: reglas duras, convenciones y especificación de los paquetes (§4 branding, §5 firefox-native, **§6 `encina-doctor`**) | Al lanzar trabajo con Claude Code |
| `README.md` | Qué es el proyecto y en qué estado está, para quien llega de fuera | Al enseñar el repositorio |
| `SCRIPTS.md` | Qué hace cada script de `scripts/` y en qué orden | Antes de ejecutar nada en la VM |
| `RECETA-A1-encina-branding.md` | Guía por sesiones de la fase A1 | Histórico: A1 ya está terminada |
| `DIARIO.md` | Dónde se quedó el trabajo | Al retomarlo tras unos días |

Si se contradicen, **manda este**.

El `especificacion-proyecto.md` que citaban versiones anteriores de este
documento **no existe en el repositorio**, ni tampoco `AGENTS-encina.md`, que
hoy es `AGENTS.md`. El detalle largo de la Etapa B está sin escribir; se
escribirá al llegar a ella.

---

## 1. Qué es Encina OS

Una distribución de escritorio basada en Ubuntu LTS, pensada para que un usuario
español la use con la mínima fricción.

**El producto real es la paquetería `.deb`, no la imagen.** La imagen es un
envase que instala un metapaquete. Esta distinción es la decisión estructural del
proyecto: desacopla el ciclo de Encina del ciclo de Ubuntu, y permite que un
usuario que ya tiene Ubuntu instalado —el caso mayoritario— se beneficie sin
reinstalar nada.

El proyecto tiene dos etapas:

- **Etapa A** — sistema base, identidad propia y cadena de build reproducible.
- **Etapa B** — integración con la administración española: AutoFirma,
  certificados FNMT, DNIe.

Estamos en la Etapa A.

---

## 2. Decisiones cerradas

No volver a discutirlas sin motivo nuevo.

| # | Decisión | Motivo en una línea |
|---|---|---|
| D1 | Nombre: **Encina OS**, identificador `encina` | Sin colisión con distros activas; sin acentos; seis letras |
| D2 | Base: Ubuntu LTS con `ubuntu-desktop-minimal` | Sigue siendo GNOME completo; partir de mínimo y sumar es declarativo, quitar es frágil |
| D3 | El producto es la paquetería, no la ISO | Nadie reinstala el sistema para arreglar un trámite que vence hoy |
| D4 | Todo declarativo y versionado; Cubic solo como laboratorio | Un chroot editado a mano no es reproducible |
| D5 | No publicar imagen en la Etapa A | Publicar activa la obligación de mantener parches de seguridad para desconocidos |
| D6 | `ID=ubuntu` intacto en `os-release` | Software de terceros comprueba ese campo; cambiarlo produce fallos inconexos durante meses |
| D7 | Tema estético (macOS u otro) en paquete separado, nunca en la base | Es preferencia personal, no necesidad jurisdiccional |
| D8 | Certificado software FNMT antes que DNIe con lector | Cubre el 90% de trámites y no requiere hardware |
| D9 | Desarrollo en Mac M3; imágenes arm64 en la Etapa A | Son para UTM del autor: nativas y rápidas. amd64 solo cuando el destino son terceros |
| D10 | No comprar máquina física | SoftHSM2 cubre PKCS#11 sin lector; Hetzner por horas cubre amd64 de escritorio |
| D11 | Los dos lanzadores «Firefox» se resuelven quitando el Snap en la ISO propia, no ocultando entradas | Ocultar la del Snap borra el icono del dock de una sesión en marcha, y desde un paquete no se puede exigir cerrar sesión: R3 impide llamar a nada, §8 prohíbe cualquier GUI. Se vive como «me han roto el equipo» |
| D12 | **No habrá `encina-locale-es`.** Lo poco que queda va como `Depends:` de `encina-meta` | Medido el 2026-08-07: `check-language-support -l es` sale vacío y el instalador de Ubuntu ya ejecuta ese mismo comando y actúa. El paquete tendría cero ficheros, y tocar locale o teclado chocaría con R5 (§6.1) |
| D13 | **Ninguna de las dos barreras de §4.1 se arregla desde `encina-firefox-native`.** Corresponden a B1/B2 | La segunda es estado por usuario y por perfil generado en tiempo de ejecución: ningún `.deb` la toca sin violar R1. Y cerrar solo la primera —que **sí** cabría en un paquete— deja el sistema sin firmar **y sin el diálogo que hoy avisa**: cambia un fallo con síntoma por uno sin él, que en un proyecto cuyo producto es el diagnóstico es un retroceso |

---

## 3. Qué existe ya

| Artefacto | Estado |
|---|---|
| `encina-branding` | **Construido, instalado y probado.** v0.1.6, 10/10 de la definición de terminado en VM Ubuntu 24.04 arm64, cuatro comprobaciones miradas en pantalla |
| `encina-firefox-native` | **Construido, instalado y probado.** v0.2.0, las siete casillas de la definición de terminado en VM Ubuntu 24.04 arm64, la última mirada en pantalla |
| Repositorio git | Creado: `jmorenobl/encina-os`, **privado** (D5) |
| Integración continua | `.github/workflows/build.yml` en `ubuntu-latest`, **una entrada de matriz por paquete**. **Verde por `push` y por `workflow_dispatch`**, comprobada sobre `9a673b8`. La entrega de los push fue irregular durante la incidencia de Actions del 2026-08-06 |
| Scripts de construcción y verificación | Once, en `scripts/`, versionados con el repositorio. 00–06 comunes y de A1; 07–09 de A2 |
| `AGENTS.md` | Escrito, cubre branding + firefox-native + **`encina-doctor` (§6, B1, especificado y sin construir)**. §5.1 enmendado en A2: el paquete también hace que el icono abra el nativo, por D3 |
| `encina-doctor` | **Especificado, no construido.** Contrato en `AGENTS.md` §6. Siete comprobaciones, cada una con sus dos salidas; ninguna se publica sin el par grabado (§6.5) |
| Nombre y convenciones | Cerrado (D1) |
| Licencia | EUPL-1.2. `LICENSE` tiene el **texto oficial completo**, verificado carácter a carácter contra EUR-Lex (Decisión de Ejecución (UE) 2017/863) |

**Conclusión: la Etapa A tiene dos paquetes reales y la cadena de construcción
en marcha.**

**Corrección del 2026-08-07, medida (§4.1).** Este documento venía afirmando que
`encina-firefox-native` «resuelve por adelantado el obstáculo principal de la
Etapa B». **Es falso.** A2 no eliminó el obstáculo: **lo desplazó.** Firefox
nativo sigue siendo la decisión correcta —sin sandbox aislando NSS—, pero
AutoFirma 1.9 no sabe encontrar el perfil nativo (`~/.config/mozilla/firefox/`)
ni lee `/etc/firefox/pref/`, así que sobre A2 **falla más** que sobre una Ubuntu
de fábrica, donde al menos acierta con el perfil del Snap. Y al quitar el Snap en
la ISO propia (D11, R4) se queda sin ningún perfil que reconocer.

Esto no invalida A2; cambia quién arregla qué. La Etapa B deja de ser «deseable»
para ser **consecuencia necesaria de A2**.

Sigue sin tocar la imagen: una receta de imagen instala paquetes, y con dos aún
no hay casi nada que instalar.

### 3.1 Verificaciones pendientes sobre el nombre

- [ ] PyPI: `encina` disponible
- [ ] GitHub: organización `encina` o alternativa
- [ ] Dominio: `encinaos.es`, `encinaos.org`
- [ ] OEPM, localizador de marcas, clases 9 y 42

Colisión conocida y descartada: Encina fue un sistema de transacciones de
Transarc/IBM, base de IBM TXSeries hasta 2006. Producto muerto; no es problema de
marca, pero competirá en resultados de búsqueda.

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

---

## 5. Reglas duras

Invariantes. Si algo parece exigir violarlas, parar y replantear.

| # | Regla |
|---|---|
| R1 | Nada de `/etc/skel`. Configuración por defecto con `gschema.override` o perfiles de dconf |
| R2 | No llamar a `glib-compile-schemas`: `libglib2.0-0` tiene un disparador de dpkg que lo hace |
| R3 | No llamar a `apt`, `apt-get`, `dpkg` ni `snap` desde scripts de mantenedor (bloqueo de dpkg) |
| R4 | No eliminar el Snap de Firefox desde un paquete; es destructivo. Corresponde a la receta de imagen. **Sustituir su lanzador no es eliminarlo** y sí está permitido: el Snap sigue instalado, su perfil intacto, y `apt purge` lo devuelve todo (ver `AGENTS.md` §5.1) |
| R5 | No sobrescribir conffiles de otros paquetes: `/etc/default/grub` con `sed`; `os-release` con `dpkg-divert` |
| R6 | Tema de Plymouth basado en `spinner`, nunca en `bgrt` (bgrt muestra el logo del fabricante) |
| R7 | Tras instalar un tema de Plymouth, `update-initramfs -u`. El tema va dentro del initramfs |
| R8 | Ningún activo de terceros: ni marca Canonical, ni tipografía San Francisco, ni iconos que imiten macOS |
| R9 | Idempotencia: cinco instalaciones seguidas dejan el sistema idéntico |
| R10 | Sin dependencias circulares de repositorio: no declarar `Depends:` sobre paquetes de un repo que ese mismo paquete configura |

---

## 6. Hoja de ruta

Marcada la posición actual.

### Etapa A

| Fase | Contenido | Estado |
|---|---|---|
| A0 | Nombre, licencia, repositorio git inicializado | **Hecho**, con el texto oficial de la EUPL-1.2 en `LICENSE` |
| A1 | `encina-branding` construido, probado, en CI | **Hecho** (v0.1.6), con la CI verde por `push` |
| A2 | `encina-firefox-native` (repo Mozilla + pinning + clave) | **Hecho** (v0.2.0), 7/7 de la definición de terminado |
| A3 | ~~`encina-locale-es`~~ | **Suprimida el 2026-08-07** tras medirla. No había nada que hacer. Su residuo lo absorbe A4. Ver §6.1 |
| A4 | `encina-meta` + repo APT firmado + `encina-keyring` | **Sin abrir.** §7 aconseja partirla: `encina-meta` sí, repo firmado y keyring no todavía. Hereda el residuo de A3 (§6.1). Es un día de trabajo que no compite con nada; se hará cuando haga falta empaquetar algo |
| A5 | `autoinstall.yaml` sobre ISO oficial de Ubuntu | Especificado |
| A6 | Imagen propia con `live-build` o `debos` | Opcional, al final |

### 6.1 Por qué se suprimió A3 (`encina-locale-es`)

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

### Etapa B

| Fase | Contenido | Estado |
|---|---|---|
| B1 | Núcleo de detección (perfiles, NSS) + `encina doctor` | **← POSICIÓN ACTUAL. Abierta el 2026-08-07.** Especificada en `AGENTS.md` §6, sin escribir una línea de código. Diagnostica y **no repara** |
| B2 | `encina configure` + `autofirma-fix` | Sin abrir. Es donde vive el remedio. D13 sigue vigente hasta entonces |
| B3 | GUI GTK4 | Sin abrir |
| B4 | DNIe con lector físico | Sin abrir |
| B∥ | **Fork de `ctt-gob-es/clienteafirma`**: PRs al oficial, y paquete propio mientras no las incorporen | Sin abrir, pero §4.5 y §4.6 lo han convertido en la vía más corta |

**El alcance de B1 es estrecho a propósito.** Detectar y reparar se separan
porque son fases con criterios de éxito distintos: una comprobación se valida
enseñando sus dos salidas (§4.2, `AGENTS.md` §6.5), y un remedio se valida
enseñando una firma que antes no salía y ahora sí. Mezclarlos produce una
herramienta que repara lo que cree ver.

**Lo que B1 quita del alcance de B1**, y conviene tenerlo escrito: `--fix`,
cualquier fichero de preferencias de Firefox, cualquier certificado instalado por
un paquete, y cualquier línea de salida que signifique «puedes firmar». Lo último
no es prudencia: es que **no existe ninguna máquina donde se haya visto
funcionar**, así que la afirmación no está respaldada por ninguna medición.

**Por qué la imagen no va antes:** una receta de imagen instala paquetes. Sin
paquetes construidos no hay nada que instalar, y sin repo del que servirlos la
receta no se puede escribir en su forma definitiva. A5 depende de A1–A4.

**Nota sobre A5 vs A6:** construir una ISO instalable de Ubuntu Desktop de forma
declarativa es más difícil que toda la paquetería junta — el instalador espera una
disposición concreta y `livecd-rootfs` está acoplado a Launchpad. Es donde la
gente abandona. Un `autoinstall.yaml` aplicado a la ISO oficial da «un sistema que
es Encina OS» sin remasterizar nada, es un YAML en git, y es reproducible. La ISO
propia solo después.

**Nota sobre el repo en A5:** mientras no exista el repo firmado (A4), usar un
repo local sin firmar generado en el propio build con `dpkg-scanpackages` y
consumido con `[trusted=yes]`. Ejercita el mecanismo real (repo + metapaquete en
el seed) sin gestión de claves GPG. La receta que se escriba así es la definitiva.

---

## 7. Empieza aquí

Una sola tarea. No abras ninguna otra hasta terminarla.

### A2 está terminada

`encina-firefox-native` 0.2.0, las siete casillas de `AGENTS.md` §5.5 verificadas
en VM Ubuntu 24.04 arm64. Configura el repositorio de Mozilla, su clave y el
anclaje, y hace que el icono del escritorio abra Firefox nativo.

Lo aprendido en la fase, para no repetirlo:

- **El anclaje no se comprueba solo instalando.** `apt full-upgrade` dos veces
  puede pasar en verde sin haber probado nada, si el sistema ya estaba al día.
  Hay que mirar cuántos paquetes ha movido y forzar las actualizaciones por
  fases si fueron cero.
- **La prueba concluyente del anclaje es el A/B de la purga:** con el paquete,
  el candidato de `firefox` sale de Mozilla; sin él, vuelve solo al deb de
  transición de Ubuntu. La diferencia entre las dos situaciones es el paquete.
- **Todo lo verificable sin pantalla no bastó.** Con las siete comprobaciones
  automáticas en verde, el icono del escritorio seguía abriendo el Snap. Se vio
  mirando `about:support`. Y estaba en español, así que parecía correcto.

### A3 está suprimida

Se midió antes de abrirla y no había nada que hacer: `check-language-support -l es`
devuelve vacío, y lo que devolvería lo instala el propio instalador de Ubuntu con
ese mismo comando. Detalle y salidas literales en §6.1. `encina-locale-es` se
queda en §8 **de forma permanente**, no «hasta que lo abras».

La lección va más allá de A3: llevaba meses en la hoja de ruta y bastó una hora
de comandos para demostrar que no existía. Sobrevivió porque nadie había
ejecutado el comando que la propia casilla proponía como criterio. **Antes de
abrir cualquier fase que quede, la pregunta es: ¿qué comando demuestra que este
problema existe?** Si no lo hay, la fase es una suposición. Aplicar sobre todo a
A5 y A6, donde la nota de §6 ya avisa de que es donde la gente abandona.

### La hipótesis de la Etapa B está comprobada

Era una de las dos opciones que planteaba este documento, y se ejecutó el
2026-08-07. **El resultado es que la Etapa B está justificada** y `encina doctor`
tiene un hueco real. Cinco fallos encadenados, ninguno con mensaje útil en
pantalla, el remedio obvio (instalar Java) no repara, y el remedio que propone el
propio fabricante declara sano un sistema roto. Salidas literales en §4.1.

Lo que hace concluyente el resultado no es el número de fallos, es **dónde**
aparecen: la VM era el caso favorable por construcción —Firefox nativo, sin
sandbox aislando NSS, en español—, y AutoFirma falla ahí **más** que en una
Ubuntu de fábrica. De ahí la corrección de §3: A2 no eliminó el obstáculo, lo
desplazó.

Dos lecciones de método, que es lo que sobrevive a la fase:

- **Una deducción bien fundada puede acertar la causa y errar el orden.** Estaba
  deducido que la firma fallaría en el TLS del socket local. Falla antes:
  AutoFirma ni siquiera arranca, porque el esquema `afirma:` no existe para
  Firefox. Pero al medir la segunda barrera resultó estar ahí también, esperando
  detrás (§4.1). La deducción no era falsa: **era la segunda de la cola.** La
  lección no es «desconfía de deducir», es que un sistema roto puede tener varias
  causas suficientes a la vez, y quedarse en la primera que se encuentra produce
  una reparación que no repara.
- **Una comprobación puede fallar por el método y no por lo comprobado.** Al
  lanzar AutoFirma por ssh salió `Can't connect to X11 window server`, que no era
  de AutoFirma sino de mi sesión sin `XAUTHORITY`. Y un `pkill -f` mató la propia
  sesión que lo ejecutaba, porque el patrón casaba con su línea de órdenes
  (`SCRIPTS.md`, trampa 3). Las dos veces, la salida parecía un hallazgo.
- **Que un error sea visible no lo hace diagnosticable.** El usuario ve un
  diálogo, hace exactamente lo que le dice, y el sistema le contesta con código 0
  que todo está bien. Distinguir «falla en silencio» de «falla con un mensaje que
  desorienta» es la diferencia entre no necesitar diagnóstico y necesitarlo mucho.

### B1 está abierta, y solo especificada

Abierta el 2026-08-07. **No se ha escrito una línea de código**, a propósito: en
este proyecto se ha suprimido una fase entera (A3) por medirla antes de abrirla,
y se han perdido días por comprobaciones que aprobaban sin comprobar nada. Lo que
existe es el contrato: `AGENTS.md` §6, con las siete comprobaciones, sus dos
salidas cada una, y la puerta que decide si sirven.

Al especificarla se remidió §4.1 y salieron tres correcciones (§4.2), las tres
del mismo tipo: **una comprobación que parecía obvia y habría dado la respuesta
equivocada.** Buscar la errata `Recoments:` no habría disparado nunca porque el
campo es `Recomends:`. Resolver «el perfil» por `Default=1` reproduce el bug de
AutoFirma. Y buscar un certificado llamado `SocketAutoFirma` dice que sí sobre un
perfil que no puede validar el socket. Ninguna de las tres se habría visto sin
volver a la máquina.

La siguiente acción **no es escribir código**: es la VM del Snap (§10). Es la
única que puede aportar un caso positivo real, y si lo aporta cambia tanto §6.5
como el alcance de toda la Etapa B.

### Sobre A4, cuando toque

Sigue siendo una decisión, no un automatismo. `encina-meta` (A4 reducida) no es
la pregunta interesante: es un día de trabajo que no compite con nada y que se
puede hacer cuando haga falta empaquetar algo.

Si se abre A4, el aviso de este documento se mantiene: **el repo APT firmado y
`encina-keyring` conviene separarlos y aplazarlos.** La nota de §6 ya dice que A5
puede ir con un repo local sin firmar y `[trusted=yes]`, y que esa receta sería
la definitiva. Un repo firmado que nadie consume da cero funcionalidad y compra
custodia de clave, rotación y alojamiento a perpetuidad. D5 dice además que no se
publica en la Etapa A.

### Las VMs de UTM

- `encina-A2-verificada` — estado bueno de A2, hecho el 2026-08-07 antes de tocar
  nada. Es la red de seguridad, no el banco de pruebas.
- `encina-autofirma-rota` — clonada el 2026-08-07 **después** de la medición de
  §4.1. No es basura: es el caso de prueba número uno de B1, con la cadena causal
  medida de punta a punta y captura de pantalla del síntoma. Reproducirla cuesta
  una tarde. **Es el banco de pruebas**; las comprobaciones pendientes de §4.1 se
  hacen aquí.
- `encina-dev-firefox` — la original, hoy en el mismo estado que la anterior:
  AutoFirma 1.9, `openjdk-17-jre` y `libnss3-tools` instalados, una CA raíz de
  AutoFirma en el almacén del sistema y otra huérfana en el perfil del Snap.
  **Ya no es el estado de A2.**

Las dos que estaban sin documentar, **identificadas el 2026-08-07** arrancándolas
de una en una. Las dos sirven, y una resultó ser justo lo que hacía falta:

- `encina-snap-fabrica` — **clon de `encina-limpia-respaldo`, creado el
  2026-08-07 para las mediciones de §4.3 y §4.4.** Ubuntu de fábrica + Snap
  Firefox 147 + AutoFirma 1.9 + `openjdk-17-jre`. **Es el caso positivo de C4**
  (`AGENTS.md` §6.4), el único sitio conocido donde AutoFirma instala la CA
  correcta en el perfil correcto (huella `B9:3B:A5:A1:…:9D:74:6F:73`), **y el
  caso de prueba de C8**, la barrera del confinamiento. **No reinstalar AutoFirma
  en ella:** cada reinstalación genera un par nuevo y el estado bueno se pierde.

  **Residuo del experimento de §4.4, y no es virgen.** Se retiró el `user.js`
  pero el perfil del Snap **conserva** las tres `network.protocol-handler.*.afirma`
  en `prefs.js` y el esquema registrado en `handlers.json`
  (`afirma: {"action": 4}`). Deshacerlo requiere editar los dos ficheros a mano.
  Que esté así **es útil**: es una máquina con la barrera 1 cerrada y la firma
  fallando igualmente, que es la prueba de que B3 existe. Si algún día hace falta
  una Ubuntu de fábrica limpia, se clona otra vez `encina-limpia-respaldo`.
- `encina-limpia-respaldo` — **Ubuntu 24.04.4 arm64 de fábrica.** Instalada el
  2026-08-06, cuatro arranques. **Ningún paquete de Encina**, ni AutoFirma, ni
  Java. Firefox es el Snap de Ubuntu (147.0.3, `firefox 1:1snap1-0ubuntu5` como
  deb de transición), sin repositorio de Mozilla y sin anclaje. **Firefox no se
  ha abierto nunca**: no existe `~/snap/firefox/common/.mozilla/firefox`. Es la
  línea base virgen del proyecto y **no se instala nada en ella**: cuando haga
  falta una Ubuntu de fábrica, se clona.
- `encina-dev` — **el banco de A1.** Instalada el 2026-08-06, 23 arranques.
  Lleva `encina-branding` 0.1.6 y **no** `encina-firefox-native`. Firefox es el
  Snap (153.0.3) **con perfil creado**, y está el usuario `prueba` de la
  definición de terminado de A1. Sirve para reverificar A1 y para cualquier
  prueba que necesite branding sin Firefox nativo.

Las cinco tienen el **mismo hostname (`encina-dev`) y la misma IP
(192.168.64.3)**, incluidas las clonadas: el hostname no distingue nada y no
sirve para saber en cuál estás. Para identificar una VM a ciegas, lo que
funciona es el conjunto «paquetes instalados + versión del Snap de Firefox +
qué perfiles existen».

No arrancar dos a la vez.

### Pendiente de A0

Ninguno. `LICENSE` ya tiene el texto oficial de la EUPL-1.2, verificado contra
EUR-Lex. Quedan solo las comprobaciones de nombre de §3.1, que no bloquean nada
y no son técnicas.

---

## 8. Fuera de alcance ahora

No implementar, no preparar, no dejar «ganchos para el futuro»:

**Reparar** AutoFirma (B2: `encina configure`, `autofirma-fix`, preferencias de
Firefox, `policies.json`, certificados instalados por un paquete) · FNMT, DNIe,
`opensc`, PKCS#11 como funcionalidad · **`encina-locale-es`** · `encina-meta`,
`encina-keyring`, repo APT, `aptly` · `os-release` y `dpkg-divert` · ISO,
`live-build`, `debos`, Cubic, `autoinstall.yaml` · temas de GTK o iconos ·
cualquier GUI.

**Lo que ha salido de esta lista el 2026-08-07: diagnosticar AutoFirma, y solo
eso.** Es la fase B1, especificada en `AGENTS.md` §6. `encina doctor` lee y no
escribe. **Reparar sigue dentro de la lista**, y D13 sigue vigente palabra por
palabra: ninguna de las dos barreras se cierra desde `encina-firefox-native`, ni
desde `encina-doctor`, ni desde ningún otro paquete, hasta que se abra B2.

Dos matices sobre esta lista:

- **`encina-locale-es` está aquí de forma permanente**, no en espera de turno. Se
  midió el 2026-08-07 y no había paquete que escribir (§6.1). El resto de la lista
  sí espera turno: sale de aquí cuando se abra su fase.
- **Medir no es implementar.** Instalar el `.deb` oficial de AutoFirma en una VM
  para ver si falla no viola esta sección: no crea código, ni paquete, ni gancho.
  Es lo contrario de un gancho — es la comprobación que decide si la Etapa B
  merece existir (§7, §10). **Hecho el 2026-08-07; resultado en §4.1 y §4.2.**
  Los dos fallos medidos tienen remedio conocido y declarativo, y **ese remedio
  no se escribe, ni se esboza, ni se deja preparado** hasta que se abra B2. Uno
  de los dos cabría en `encina-firefox-native` en media hora: **D13 dice que
  tampoco ahí**, y el motivo no es de alcance sino de daño. Con B1 abierta la
  tentación cambia de forma pero no desaparece: ahora llegará como «ya que doctor
  detecta la barrera 1, que la arregle». La respuesta es la misma y está en D13.

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
| Fallos raros con software de terceros | Instaladores y scripts que no reconocen el sistema | Se cambió `ID` en `os-release` |
| Fondo claro en modo oscuro | Solo en tema oscuro | Falta `picture-uri-dark` (GNOME 42+) |
| Builds no reproducibles | Dos builds del mismo commit difieren | Falta fijar fecha de snapshot del mirror |

---

## 10. Criterios de parada

- **Fin de Etapa A:** si no se logra un build con `.manifest` reproducible, no
  avanzar a la imagen propia. Los paquetes siguen siendo válidos por separado.
- **Fase B1:** el criterio original decía «si `encina doctor` no encuentra fallos
  reales en cuatro VMs (Firefox nativo, Snap, Flatpak, Debian limpio), el problema
  es menor de lo estimado y no justifica B2–B4».

  **Reescrito el 2026-08-07 al abrir B1, porque en su forma original ya no puede
  decidir nada.** La VM de Firefox nativo encontró dos barreras medidas; las otras
  tres no van a *desencontrarlas*. El criterio se había convertido en una casilla
  que solo puede salir a favor, que es exactamente lo que le pasó a A3 durante
  meses. Lo que las tres VMs restantes sí deciden, cada una una cosa distinta:

  | VM | Qué decide de verdad | ¿Hace falta para B1? |
  |---|---|---|
  | **Snap (Ubuntu de fábrica)** | Si existe alguna máquina donde AutoFirma acierte | **HECHA el 2026-08-07 (§4.3). Sí acierta.** La barrera 2 **no existe** en fábrica: la CA del perfil tiene la huella del socket vivo y la hoja valida. Es el **caso positivo real de C4**, y no hace falta construirlo |
  | **Debian limpio** | Si la barrera 1 es específica de la build de Mozilla. Un Firefox empaquetado por Debian **sí** lee `/etc/firefox/pref/`, así que ahí el esquema `afirma:` debería existir: sería el positivo real de C5 | **No bloquea, pero ha subido de valor.** §4.3 midió que el Snap tampoco lee `/etc/firefox/pref/`, así que las dos compilaciones que hay son negativas y C5 sigue sin positivo real. `AGENTS.md` §6.5(b) da uno equivalente sin VM |
  | **Flatpak** | Una ruta más de perfil (`~/.var/app/org.mozilla.firefox/…`). No es una clase nueva de fallo | **No.** No es el navegador por defecto de ningún sistema destino. Se cubre con un `[OMIT] Flatpak: no instalado`, que es honrado y cuesta cero |

  **Criterio de parada de B1, en su forma nueva:** si al terminar las siete
  comprobaciones de `AGENTS.md` §6.4 resulta que **dos o más no pueden producir su
  salida verde** (§6.5), B1 no ha construido un diagnóstico sino una lista de
  sospechas, y hay que parar antes de B2.

  **Resultado del 2026-08-07 (§4.3 y §4.4).** La respuesta es **no**: el problema
  no es menor. Hubo un momento del día en que lo pareció —§4.3 midió que en la
  máquina mayoritaria falta la barrera 2— y duró lo que tardó en medirse la
  tercera. Hay **tres** barreras, no dos, y ninguna máquina tiene menos de dos:

  - Ubuntu de fábrica + Snap: B1 y **B3**, y B3 **no la arregla ningún paquete**.
  - Encina con Firefox nativo: B1 y B2, las dos reparables.

  Eso **no** mueve trabajo a A2 para replantearla, como llegó a escribirse aquí:
  la confirma. A2 cambia dos barreras por dos barreras, pero cambia una
  infranqueable por una reparable. Y refuerza B1 por partida doble: el remedio
  correcto depende de qué máquina es, y en una de las dos el remedio **no es un
  remedio sino un consejo** —cambiar de navegador—, que es justo lo que ninguna
  herramienta existente sabe decir.
- **Vía upstream:** si el PR a `clienteafirma` entra rápido, replantear el alcance
  en lugar de continuar por inercia.
