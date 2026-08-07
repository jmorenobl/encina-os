# Encina OS — Documento maestro

**Punto de entrada único del proyecto.** Si no sabes por dónde seguir, lee la
sección 7 («Empieza aquí») y nada más.

Última actualización: 7 de agosto de 2026

---

## 0. Los documentos y para qué sirve cada uno

| Documento | Papel | Cuándo abrirlo |
|---|---|---|
| **ENCINA-OS.md** (este) | Índice, estado y siguiente acción | Siempre primero |
| `AGENTS.md` | Instrucciones ejecutables: reglas duras, convenciones y especificación de los paquetes | Al lanzar trabajo con Claude Code |
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
| `AGENTS.md` | Escrito, cubre branding + firefox-native. §5.1 enmendado en A2: el paquete también hace que el icono abra el nativo, por D3 |
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
  mantenedor.
- openSUSE: paquete comunitario en el repo personal de Antonio Larrosa; sin
  paquete oficial para Leap 15.6.
- AUR: `autofirma`, `autofirma-bin`, y un `autofirmaja` cuyo mantenedor declara
  abiertamente que no puede sostenerlo.

**Licencia:** AutoFirma es software libre, GPL 2+ y EUPL 1.1, código en la forja
del CTT. **Es redistribuible.**

**Los issues upstream, contrastados contra medición propia (ver §4.1):**

- Issue #302 (`openjdk-11-jre` no declarado): **confirmado, y es peor de lo que
  dice.** No es un olvido: el `control` del `.deb` 1.9 escribe `Recoments:` en
  lugar de `Recommends:`. Al no ser un campo Debian válido, dpkg lo arrastra como
  campo de usuario y no actúa. El JRE no queda declarado por ninguna vía, ni
  siquiera con `apt install --install-recommends`.
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
4. **Con Java presente, la CA del socket va al navegador equivocado.** Se instala
   en el perfil del **Snap** (`~/snap/firefox/common/.mozilla/firefox/`) y no en
   el del Firefox **nativo** (`~/.config/mozilla/firefox/`, §9). Lo confirma el
   propio desinstalador que AutoFirma se genera, que apunta solo al Snap.
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
| A4 | `encina-meta` + repo APT firmado + `encina-keyring` | **← POSICIÓN ACTUAL, sin abrir.** §7 la plantea como decisión, y aconseja partirla: `encina-meta` sí, repo firmado y keyring no todavía. Hereda el residuo de A3 (§6.1) |
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

| Fase | Contenido |
|---|---|
| B1 | Núcleo de detección (perfiles, NSS, sandbox) + `encina doctor` |
| B2 | `encina configure` + `autofirma-fix` |
| B3 | GUI GTK4 |
| B4 | DNIe con lector físico |
| B∥ | Vía paralela: PR upstream a `ctt-gob-es/clienteafirma`. Arrancar al empezar la Etapa B |

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

### Siguiente: qué fase se abre

Sigue siendo una decisión, no un automatismo. Con §4.1 medido, `encina-meta`
(A4 reducida) ya no es la pregunta interesante: es un día de trabajo que no
compite con nada y que se puede hacer cuando haga falta empaquetar algo. Lo que
la medición ha desbloqueado es **B1**, y el criterio de §10 sigue en pie para
ella.

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

Hay además `encina-dev` y `encina-limpia-respaldo`, anteriores a este trabajo y
**sin documentar aquí**: si alguna sigue sirviendo, anotar para qué; si no,
borrarlas, porque cinco VMs que comparten hostname e IP son una trampa esperando.

No arrancar dos a la vez: comparten hostname e IP.

### Pendiente de A0

Ninguno. `LICENSE` ya tiene el texto oficial de la EUPL-1.2, verificado contra
EUR-Lex. Quedan solo las comprobaciones de nombre de §3.1, que no bloquean nada
y no son técnicas.

---

## 8. Fuera de alcance ahora

No implementar, no preparar, no dejar «ganchos para el futuro»:

AutoFirma, FNMT, DNIe, `opensc`, PKCS#11, NSS · **`encina-locale-es`** ·
`encina-meta`, `encina-keyring`, repo APT, `aptly` · `os-release` y `dpkg-divert` ·
ISO, `live-build`, `debos`, Cubic, `autoinstall.yaml` · temas de GTK o iconos ·
cualquier GUI.

Dos matices sobre esta lista:

- **`encina-locale-es` está aquí de forma permanente**, no en espera de turno. Se
  midió el 2026-08-07 y no había paquete que escribir (§6.1). El resto de la lista
  sí espera turno: sale de aquí cuando se abra su fase.
- **Medir no es implementar.** Instalar el `.deb` oficial de AutoFirma en una VM
  para ver si falla no viola esta sección: no crea código, ni paquete, ni gancho.
  Es lo contrario de un gancho — es la comprobación que decide si la Etapa B
  merece existir (§7, §10). **Hecho el 2026-08-07; resultado en §4.1.** Que esté
  medido no abre nada: AutoFirma sigue en esta lista hasta que se abra B1.
  Los dos fallos medidos tienen remedio conocido y declarativo, y **ese remedio
  no se escribe, ni se esboza, ni se deja preparado** hasta entonces. Uno de los
  dos cabría en `encina-firefox-native` en media hora: **D13 dice que tampoco
  ahí**, y el motivo no es de alcance sino de daño.

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
| Firma electrónica falla sin explicación | Error que no menciona el sandbox | Navegador en Snap/Flatpak aísla el almacén NSS |
| **AutoFirma no arranca al pulsar «Firmar»** | La sede dice «No es posible conectar con Autofirma»; no hay ningún proceso `java` ni nada escuchando en el socket, y **no sale ningún diálogo de «abrir con»** | El `.deb` deja sus preferencias en `/etc/firefox/pref/Autofirma.js`, ruta de los Firefox de Debian/Ubuntu. **La compilación oficial de Mozilla no la lee**: las tres `network.protocol-handler.*.afirma` no existen. El handler del sistema (`xdg-open`) sí funciona: el eslabón roto es solo Firefox (§4.1) |
| **Arreglar el esquema `afirma:` no basta** | Ya arranca AutoFirma y la firma sigue sin ir | Son **dos barreras independientes**. El socket de AutoFirma es TLS (`CN=127.0.0.1` emitido por `CN=Autofirma ROOT`), así que el navegador también tiene que confiar en esa CA, y el Firefox nativo no la tiene. La primera barrera escondía la segunda (§4.1) |
| **AutoFirma configura el navegador equivocado** | Todo instalado y «correcto», y la firma falla | Su configurador encuentra el perfil del **Snap** y no el del Firefox nativo, que está en `~/.config/mozilla/firefox/`. Con el Snap quitado no encuentra **ninguno** y lo dice solo en un log que nadie lee |
| **«Restaurar instalación» de AutoFirma no repara nada** | Responde que ya está todo bien y sale con código 0 | Comprueba que exista un fichero en `/usr/lib/Autofirma`, no que el navegador tenga la CA. El usuario hace justo lo que el error le dice y el sistema le contesta que está sano |
| **Un `.deb` que se instala «con éxito» roto entero** | `install ok installed`, código 0, y nada funciona | `postinst` con `#!/bin/sh` **sin `set -e`** y `exit 0` incondicional. Los mensajes de éxito se imprimen aunque el comando anterior haya fallado. No es exclusivo de AutoFirma: es el patrón que hay que buscar |
| **Añadir el almacén del sistema no sirve para Firefox** | `update-ca-certificates` dice `1 added` y Firefox sigue sin confiar | Firefox no lee `/etc/ssl/certs` aunque `security.enterprise_roots.enabled` esté en `true`. Medido: 167 certificados visibles, ninguno el añadido |
| Fallos raros con software de terceros | Instaladores y scripts que no reconocen el sistema | Se cambió `ID` en `os-release` |
| Fondo claro en modo oscuro | Solo en tema oscuro | Falta `picture-uri-dark` (GNOME 42+) |
| Builds no reproducibles | Dos builds del mismo commit difieren | Falta fijar fecha de snapshot del mirror |

---

## 10. Criterios de parada

- **Fin de Etapa A:** si no se logra un build con `.manifest` reproducible, no
  avanzar a la imagen propia. Los paquetes siguen siendo válidos por separado.
- **Fase B1:** si `encina doctor` no encuentra fallos reales en cuatro VMs
  (Firefox nativo, Snap, Flatpak, Debian limpio), el problema es menor de lo
  estimado y no justifica B2–B4. **Matiz del 2026-08-07:** este criterio mide
  *cuánta cobertura necesita B1*, no *si el problema existe*. Lo segundo ya está
  resuelto en §4.1 sobre la VM de Firefox nativo, que era el caso favorable, así
  que la primera de las cuatro ya está hecha y salió que sí. Las otras tres siguen
  siendo el criterio de parada de B1.
- **Vía upstream:** si el PR a `clienteafirma` entra rápido, replantear el alcance
  en lugar de continuar por inercia.
