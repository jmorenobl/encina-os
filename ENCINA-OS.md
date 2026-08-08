# Encina OS — Documento maestro

**Punto de entrada único del proyecto.** Si no sabes por dónde seguir, lee la
sección 7 («Empieza aquí») y nada más.

Última actualización: 9 de agosto de 2026

---

## 0. Los documentos y para qué sirve cada uno

| Documento | Papel | Cuándo abrirlo |
|---|---|---|
| **ENCINA-OS.md** (este) | Índice, estado y siguiente acción | Siempre primero |
| `AGENTS.md` | Instrucciones ejecutables: reglas duras, convenciones y especificación de cada paquete y de la imagen | Al lanzar trabajo con Claude Code |
| `MEDICIONES.md` | Lo medido, con las salidas literales | Antes de volver a investigar algo. Casi siempre ya está medido |
| `SCRIPTS.md` | Qué hace cada script y en qué orden, y las ocho trampas | Antes de ejecutar nada en la VM |
| `README.md` | Qué es el proyecto, para quien llega de fuera | Al enseñar el repositorio |
| `DIARIO.md` | Dónde se quedó el trabajo | Al retomarlo tras unos días |

Si se contradicen, **manda este**.

**Hay un segundo repositorio:** `~/Projects/encina-autofirma`
(`jmorenobl/encina-autofirma`), con el `.deb` corregido de AutoFirma, sus
mediciones (M1–M18) y los tres forks de los que salen las PRs al repositorio
oficial. Es un **ingrediente** de Encina OS con condición de salida (D14), no
una línea de trabajo paralela.

---

## 1. Qué es Encina OS

Una distribución de escritorio basada en Ubuntu LTS, pensada para que un usuario
español la use con la mínima fricción, y en particular para que **la firma
electrónica funcione sin que nadie tenga que entender por qué no funcionaba**.

**Se construyen `.deb`; se entrega Encina OS.** Lo que se escribe y se versiona
aquí son paquetes; lo que se usa es Ubuntu LTS con esos paquetes aplicados. No
se remasteriza la base: se hereda de Ubuntu toda la capa de actualizaciones y
aplicaciones, que es la razón entera de no partir de cero.

**El alcance de hoy es deliberadamente pequeño: un Encina OS arm64 que funcione
en las VMs del autor.** A partir de ahí se añade funcionalidad por incrementos,
y cada incremento deja un sistema que se puede usar. amd64, más aplicaciones de
serie y el DNIe son incrementos futuros, no deuda.

**Ya no hay «Etapa A» y «Etapa B».** Ese marco describía un proyecto que
construía paquetes de base y aplazaba la integración con la administración. Hoy
la integración está hecha y medida, y lo que falta es entregarla. La hoja de
ruta (§6) va por incrementos.

---

## 2. Decisiones cerradas

No volver a discutirlas sin motivo nuevo. **D3, D5, D9 y D13 se revisaron el
2026-08-08**, al cambiar el enfoque del proyecto; las tres primeras cambian de
redacción y la cuarta se enmienda.

| # | Decisión | Motivo en una línea |
|---|---|---|
| D1 | Nombre: **Encina OS**, identificador `encina` | Sin colisión con distros activas; sin acentos; seis letras |
| D2 | Base: Ubuntu LTS con `ubuntu-desktop-minimal` | Sigue siendo GNOME completo; partir de mínimo y sumar es declarativo, quitar es frágil |
| D3 | **Se construyen `.deb`; se entrega Encina OS.** El producto final es Ubuntu LTS con los `.deb` de Encina aplicados: ni los `.deb` sueltos, ni una base remasterizada desde cero | Partir de `ubuntu-desktop-minimal` y sumar paquetes propios cuesta mucho menos que construir una base, y hereda las actualizaciones de Ubuntu. Es también lo que ordena §6: primero instalación desatendida, la imagen propia al final. **Reescrita el 2026-08-08:** el motivo sigue en pie y la conclusión anterior («el producto es la paquetería, *no* la ISO») confundía lo que se construye con lo que se entrega. Cae con ella su motivo escrito —«nadie reinstala el sistema para arreglar un trámite que vence hoy»—, que describía a un usuario que ya tiene Ubuntu y ha dejado de ser el destinatario |
| D4 | Todo declarativo y versionado; Cubic solo como laboratorio | Un chroot editado a mano no es reproducible |
| D5 | **El repositorio es público. La imagen se publica cuando exista una arquitectura que otros puedan arrancar** | Publicar una imagen solo-arm64 activa hoy las obligaciones —responder a un fallo de seguridad de AutoFirma cortando imagen nueva, y ofrecer la fuente correspondiente del build parcheado, lo que obliga a hacer públicos `encina-autofirma` y los tres forks— para un público que es el autor. Hacer público el **repositorio** cuesta cero y no compra ninguna de esas obligaciones. **Reescrita el 2026-08-08**, separando las dos cosas que la versión anterior mezclaba. Si se decide publicar la imagen desde la primera versión arm64, es esta celda la que cambia |
| D6 | `ID=ubuntu` intacto en `os-release` | Software de terceros comprueba ese campo; cambiarlo produce fallos inconexos durante meses |
| D7 | Tema estético (macOS u otro) en paquete separado, nunca en la base | Es preferencia personal, no necesidad jurisdiccional |
| D8 | Certificado software FNMT antes que DNIe con lector | Cubre el 90% de trámites y no requiere hardware. **Cumplido:** el positivo de `MEDICIONES.md` §4.9 se hizo con certificado real de la FNMT |
| D9 | **Solo arm64 por ahora.** amd64 cuando haya con qué probarlo | Solo hay un Mac M3, así que arm64 es lo único que se puede medir, y en este proyecto lo que no se mide no se da por bueno. **Es un límite de alcance declarado, no un pendiente.** Consecuencia conocida y medida: B6 (`MEDICIONES.md` §4.9c) es específica de arm64 y no aparecería en amd64 |
| D10 | No comprar máquina física | SoftHSM2 cubre PKCS#11 sin lector; Hetzner por horas cubre amd64 de escritorio el día que haga falta |
| D11 | Los dos lanzadores «Firefox» se resuelven **quitando el Snap en la imagen**, no ocultando entradas | Ocultar la del Snap borra el icono del dock de una sesión en marcha, y desde un paquete no se puede exigir cerrar sesión: R3 impide llamar a nada y §8 prohíbe cualquier GUI. **Con D3 reescrita, esto deja de ser un aplazamiento indefinido: la imagen es el producto, así que es el sitio donde ocurre.** Y quitar el Snap cierra además B3 y B4 (§4 de este documento) |
| D12 | **No habrá `encina-locale-es`.** Lo poco que queda va como `Depends:` de `encina-meta` | Medido el 2026-08-07: `check-language-support -l es` sale vacío y el instalador de Ubuntu ya ejecuta ese mismo comando y actúa. Detalle en `MEDICIONES.md` §A3 |
| D13 | **Ningún paquete de Encina cierra una sola de las barreras de la firma por su cuenta** | Cerrar una barrera aislada deja el sistema sin firmar **y sin el síntoma que hoy avisa**: cambia un fallo visible por uno silencioso. **Enmendada el 2026-08-08: la regla se mantiene y su caso se ha cumplido, no violado.** Las barreras se cerraron todas a la vez, en el sitio correcto —el paquete de AutoFirma— y por el dueño correcto, que es exactamente lo que D13 estaba esperando. Lo que se prohíbe sigue prohibido: nada de `policies.json`, ficheros de preferencias de Firefox ni certificados en `encina-branding` ni en `encina-firefox-native` |
| D14 | **El AutoFirma corregido es un ingrediente con condición de salida medible** | El fork existe porque el `.deb` oficial está roto, y se retira cuando deje de estarlo. La condición no es una fecha ni la aceptación de las PRs: es que `verificar-deb.sh` pase sobre el `.deb` descargado de `firmaelectronica.gob.es`. Medido: la AGE va **un año por detrás de su propio código** (`MEDICIONES.md` §4.5) y una PR de una línea tardó 87 días |
| D15 | **Se crece por incrementos, y cada incremento deja un sistema usable** | Es un proyecto de una sola persona, y §4 documenta que así es como mueren estos proyectos. Un incremento que no se puede usar no se puede validar, y lo que no se valida se acumula |

---

## 3. Qué existe ya

| Artefacto | Estado |
|---|---|
| `encina-branding` | **Construido, instalado y probado.** v0.1.6, 10/10 de la definición de terminado en VM Ubuntu 24.04 arm64, cuatro comprobaciones miradas en pantalla |
| `encina-firefox-native` | **Construido, instalado y probado.** v0.2.0, las siete casillas de la definición de terminado, la última mirada en pantalla. **Es condición necesaria del producto, y está medido por qué** (§4) |
| `autofirma 1.9.1+encina2` | **Construido, probado, y con el primer positivo de extremo a extremo del proyecto.** En `~/Projects/encina-autofirma`, anclado en `v1.9.1`, CI verde en amd64 y arm64. **`+encina2`, del 2026-08-09, cierra el defecto de `MEDICIONES.md` §4.12a**: dos unidades de systemd de usuario meten la CA del socket en el perfil de Mozilla cuando el perfil aparece, así que la secuencia de E1 vuelve a ser de tres órdenes (M14–M18 de aquel repositorio) |
| Forks de AutoFirma | `jmorenobl/{clienteafirma, jmulticard, clienteafirma-external}`. Cuatro PRs escritas; **abrirlas está pendiente** |
| Repositorio git | `jmorenobl/encina-os`, **ya público** (comprobado el 2026-08-09: `gh repo view` da `"visibility":"PUBLIC"`), como pedía D5. **`jmorenobl/encina-autofirma` sigue privado**, y por eso la secuencia de instalación todavía no la puede completar alguien de fuera |
| Integración continua | `.github/workflows/build.yml`, una entrada de matriz por paquete. Verde por `push` y por `workflow_dispatch` |
| Scripts | Catorce, en `scripts/`, versionados con el repositorio |
| Licencia | EUPL-1.2, texto oficial completo verificado contra EUR-Lex |
| `encina-meta` | **Construido, instalado y verificado en VM.** v0.1.1, `changelog` creado con `dch`, matriz de CI verde, `lintian` mudo también en el runner. **10 de 12 casillas de §6.4 de `AGENTS.md`.** Sobre una máquina virgen instalada por su secuencia salió una firma real en `valide.redsara.es`, mirada en pantalla — pero **la casilla que decide sigue sin marcar**. El cuarto paso que hizo falta entonces **ya no existe** (`+encina2`, §4.12a enmendada); lo que falta ahora es solo repetir el experimento de la firma en un clon efímero |
| Instalación desatendida | **No existe.** Es el segundo incremento |
| ~~`encina-doctor`~~ | **Suprimido el 2026-08-08 sin escribir una línea.** Ver §6.1 |

### 3.1 Verificaciones pendientes sobre el nombre

- [ ] PyPI: `encina` disponible
- [ ] GitHub: organización `encina` o alternativa
- [ ] Dominio: `encinaos.es`, `encinaos.org`
- [ ] OEPM, localizador de marcas, clases 9 y 42

Colisión conocida y descartada: Encina fue un sistema de transacciones de
Transarc/IBM, muerto desde 2006. No es problema de marca, pero competirá en
resultados de búsqueda.

---

## 4. Por qué el producto es este y no otro, en cinco líneas

Lo largo está en `MEDICIONES.md`. Lo que hay que tener en la cabeza al trabajar:

**La firma electrónica en Ubuntu falla por seis barreras encadenadas**, cada una
capaz de esconder a la siguiente, y ninguna con un mensaje de error útil.
Encina OS las cierra así:

| # | Barrera | Quién la cierra en Encina OS |
|---|---|---|
| B1a | Las preferencias del esquema `afirma:` están donde la compilación de Mozilla no lee | `autofirma 1.9.1+encina2` |
| B1b | `network.protocol-handler.app` ya no existe en Firefox 153 | `autofirma 1.9.1+encina2` |
| B2 | La CA del socket va al perfil equivocado —y no va a ninguno si el perfil aún no existe | `autofirma 1.9.1+encina2`: `+encina1` acertó el perfil, `+encina2` acierta también **el momento** |
| B3 | Dentro del Snap, Firefox **no ve** el manejador de protocolo | `encina-firefox-native`, y **quitar el Snap en la imagen** |
| B4 | AutoFirma busca tu certificado en el perfil del Snap | `autofirma 1.9.1+encina2`, y quitar el Snap lo cierra solo |
| B6 | Las bibliotecas NSS no se encuentran fuera de x86 | `autofirma 1.9.1+encina2` |

*(B5 —la CSP de la sede bloqueando su propio iframe— no la cierra nadie desde el
equipo. Solo afecta a qué sede sirve para validar: `valide.redsara.es` sí,
`sededgsfp.gob.es` no.)*

**Las dos consecuencias que más veces se han olvidado en este proyecto:**

1. **Ningún `.deb` arregla B3.** Firefox dentro del Snap no ve
   `afirma.desktop` ni `/usr/bin/autofirma`, porque su `XDG_DATA_DIRS` no
   incluye `/usr/share` del anfitrión. No falla: **no hace nada.** Por eso
   `encina-firefox-native` no es un accesorio y por eso la imagen quita el Snap.
2. **Quitar el Snap cierra B3 y B4 a la vez**, y B4 está medido con control
   (`encina-autofirma/MEDICIONES.md` M6): sin perfil de Snap, AutoFirma acierta
   con el nativo él solo.

---

## 5. Reglas duras

Invariantes. Si algo parece exigir violarlas, parar y replantear. **Rigen
también la receta de imagen**, no solo los paquetes.

| # | Regla |
|---|---|
| R1 | Nada de `/etc/skel`. Configuración por defecto con `gschema.override` o perfiles de dconf |
| R2 | No llamar a `glib-compile-schemas`: `libglib2.0-0` tiene un disparador de dpkg que lo hace |
| R3 | No llamar a `apt`, `apt-get`, `dpkg` ni `snap` desde scripts de mantenedor (bloqueo de dpkg) |
| R4 | No eliminar el Snap de Firefox **desde un paquete**; es destructivo. Corresponde a la receta de imagen, donde ahora sí se hace (D11). Sustituir su lanzador no es eliminarlo y sí está permitido |
| R5 | No sobrescribir conffiles de otros paquetes: `/etc/default/grub` con `sed`; `os-release` con `dpkg-divert` |
| R6 | Tema de Plymouth basado en `spinner`, nunca en `bgrt` (bgrt muestra el logo del fabricante) |
| R7 | Tras instalar un tema de Plymouth, `update-initramfs -u`. El tema va dentro del initramfs |
| R8 | Ningún activo de terceros: ni marca Canonical, ni tipografía San Francisco, ni iconos que imiten macOS |
| R9 | Idempotencia: cinco instalaciones seguidas dejan el sistema idéntico |
| R10 | Sin dependencias circulares de repositorio: no declarar `Depends:` sobre paquetes de un repo que ese mismo paquete configura |

---

## 6. Hoja de ruta — incrementos

Cada uno deja un sistema que se puede usar y se valida solo (D15). El orden es
de menor a mayor riesgo, no de menor a mayor interés.

| # | Incremento | Qué lo da por terminado | Estado |
|---|---|---|---|
| **E1** | `encina-meta` | Una secuencia documentada —los cuatro `.deb`, `apt update`, `full-upgrade` más el idioma— deja branding, Firefox nativo y AutoFirma funcionando. Hereda el residuo de l10n de D12. **Medido el 2026-08-08 (`MEDICIONES.md` §4.10): «un solo `apt install`» no era posible, y declarar `firefox` para conseguirlo lo estropea en silencio** | **CASI.** 10 de 12 casillas. Firma real conseguida sobre máquina virgen; la secuencia **no bastó entonces** y **hoy sí basta** —`+encina2` cerró el cuarto paso, §4.12a enmendada—, pero eso hay que volver a verlo en pantalla |
| **E2** | Instalación desatendida | `autoinstall.yaml` + repo local sin firmar sobre la ISO oficial de Ubuntu arm64. **Sin Snap.** Terminado cuando salga una firma en `valide.redsara.es` sobre una máquina que nadie ha tocado a mano | Sin abrir |
| **E3** | ISO que arranca sola | La ISO oficial reempaquetada con el seed embebido. Se la puedes dar a alguien —o a ti dentro de seis meses— y arranca | Sin abrir |
| **E4** | Aplicaciones de serie | Lo que quieras que Encina OS traiga puesto, como `Depends:`/`Recommends:` de `encina-meta`. Es el eje por el que crece el producto | Sin abrir |
| **E5** | Imagen propia (`live-build`/`debos`) | El destino declarado. Solo compra marcar el propio instalador y controlar el conjunto base | Sin abrir |
| **E6** | amd64 | Cuando haya con qué probarlo (D9). Repetir el positivo de extremo a extremo allí | Sin abrir |
| **B∥** | Sostener AutoFirma | Abrir las cuatro PRs; retirar el fork cuando se cumpla D14 | **Abierto** |

**Por qué E5 va al final y no al principio.** Construir una ISO instalable de
Ubuntu Desktop de forma declarativa es más difícil que toda la paquetería junta:
el instalador espera una disposición concreta y `livecd-rootfs` está acoplado a
Launchpad. Es donde la gente abandona. E2 y E3 dan «un sistema que es Encina OS»
sin remasterizar nada, son ficheros en git, y son reproducibles. La receta que
se escriba en E2 es la definitiva; E5 la envuelve.

**Y hay un antecedente a favor de E2**, aunque no es prueba: al menos una de las
VMs de este proyecto se instaló con `autoinstall`, y su
`/var/log/installer/subiquity-server-debug.log` se leyó entero para `MEDICIONES.md`
§6.1. O sea que el mecanismo funciona en Ubuntu 24.04 arm64. Lo que no está
probado es el seed que haya que escribir.

### 6.1 Por qué se suprimió `encina-doctor`

Estaba especificado en detalle —ocho comprobaciones, cada una con sus dos
salidas, y una puerta que decidía si servían— y **no se escribió ni una línea**.
Se suprime el 2026-08-08 por el mismo motivo por el que se suprimió
`encina-locale-es`: se midió antes de abrirlo y el problema que resolvía había
dejado de existir.

**El motivo, en corto.** `encina doctor` existía para explicarle a un usuario por
qué el `.deb` oficial de AutoFirma le había roto el sistema sin decírselo. Encina
OS ya no instala ese `.deb`: instala uno que no lo rompe. Un diagnóstico cuya
respuesta es siempre la misma no es un diagnóstico.

**Lo que sí sobrevive, y no es un programa nuevo:** la pregunta «¿sigue intacta
esta instalación?». Su sitio es la **verificación de la construcción de la
imagen, en CI**, no una orden que teclee un usuario. Y el código ya existe:
`verificar-deb.sh` en `encina-autofirma` hace 21 comprobaciones con sus dos
salidas medidas y ya corre en dos arquitecturas.

**Lo que se pierde, y conviene tenerlo escrito:** el veredicto «esta máquina
tiene Snap y por eso no puede firmar». En una imagen controlada no hace falta,
porque la imagen no lleva Snap. Si alguna vez Encina OS se instala sobre una
Ubuntu que el usuario ya tenía, esa pregunta vuelve.

La especificación completa que se descarta está en el historial de git, en
`AGENTS.md` §6 hasta el commit del 2026-08-08. Las **mediciones** que se hicieron
para escribirla no se pierden: están en `MEDICIONES.md` §4.2 y §4.9.

---

## 7. Empieza aquí

Una sola tarea. No abras ninguna otra hasta terminarla.

### E1 — `encina-meta`

Un paquete `Architecture: all` sin ficheros propios cuyo trabajo entero es
declarar dependencias. Es pequeño a propósito y desbloquea todo lo demás: un
instalador desatendido instala **un nombre**, no tres.

Contiene:

- `Depends:` sobre `encina-branding`, `encina-firefox-native` y `autofirma`.
- El residuo de l10n que D12 le dejó: `hunspell-es`, `language-pack-es`,
  `language-pack-gnome-es` en `Depends:`; `libreoffice-l10n-es`, `hyphen-es`,
  `mythes-es`, `thunderbird-locale-es` en `Recommends:`. El motivo, con las
  salidas, en `MEDICIONES.md` §6.1.
- **Ojo con R10:** `encina-firefox-native` configura el repositorio de Mozilla,
  así que `encina-meta` no puede depender de nada que venga de ese repositorio.

**R10 medida el 2026-08-08, antes de escribir una línea** (`MEDICIONES.md`
§4.10). Tres cosas, y la segunda cambia lo que este documento prometía:

1. **E1 no se para.** `encina-meta` puede no declarar `firefox` sin dejar la
   máquina sin navegador, porque el nombre `firefox` **ya está instalado** en
   toda Ubuntu de escritorio —deb de transición al Snap— y el anclaje de
   `encina-firefox-native` lo reasigna al deb de Mozilla. No se instala: se
   sustituye. Con control negativo: sin el anclaje, apt no propone nada.
2. **«Un solo `apt install`» no era posible, y no por culpa de este paquete.** El
   cambio lo hace `apt full-upgrade` —`apt upgrade` no—, después de un
   `apt update` que no puede ocurrir dentro de la misma transacción (R3). Y el
   idioma, `firefox-l10n-es-es`, solo existe en el repositorio de Mozilla, así
   que ningún `Depends:` de Encina puede traerlo. La secuencia de tres órdenes
   está escrita en `AGENTS.md` §6.4.
3. **Declarar `firefox` no lo arreglaría: lo estropearía en silencio.** No es
   irresoluble, como se suponía: en un escritorio de fábrica lo satisface el deb
   de transición ya instalado y la máquina sigue en el Snap con apt saliendo con
   0; en una base sin Firefox, apt instala `snapd` y el Snap.

Lo que lo da por terminado: esa secuencia, ejecutada tal cual sobre una Ubuntu
24.04 arm64 limpia, deja un sistema que firma en `valide.redsara.es`, mirado en
pantalla.

**Estado el 2026-08-08: 10 de 12 casillas, y la que decide sigue abierta a
propósito.** La firma salió —«Fichero firmado correctamente», con certificado real
de la FNMT, sobre una máquina virgen instalada por la secuencia, y la VM se
destruyó después—, pero **la secuencia no bastó**, y la casilla exige que baste.
Faltaba un cuarto paso: el `postinst` de `autofirma` corre en el paso 1, cuando
Firefox nativo todavía no existe, así que no hay perfil donde instalar la CA de su
socket, y sin ella la sede dice «No es posible conectar con Autofirma». Con
`sudo dpkg-reconfigure autofirma` después de abrir Firefox una vez, funcionaba.

**Lo que cerraba E1 no era otra tarde de VM: era un disparador en
`encina-autofirma`** que instalase la CA cuando apareciera un perfil de Mozilla.

**Y eso está hecho, el 2026-08-09.** `autofirma 1.9.1+encina2` lleva dos unidades
de systemd de usuario que hacen exactamente eso, medido sobre un clon virgen con
la secuencia de tres órdenes y sin ejecutar `dpkg-reconfigure` ni una vez (M18 de
`encina-autofirma`; enmienda en `MEDICIONES.md` §4.12a). **La secuencia son otra
vez tres órdenes** y así está escrita en `AGENTS.md` §6.4.

**La casilla que decide sigue sin marcar, y ahora por un solo motivo: el
experimento no se ha repetido.** Ya no hay desviación del producto que lo
bloquee — falta clonar otra vez de `encina-limpia-respaldo`, meter un certificado
personal, firmar en `valide.redsara.es` mirándolo en pantalla, y destruir la VM.
Todo lo demás de E1 está hecho y medido, incluidas las seis barreras cerradas
sobre esa máquina (`MEDICIONES.md` §4.12).

### La pregunta que hay que hacerle a E2 antes de abrirlo

Es la lección de A3 y de B∥, y ha acertado las dos veces: **¿qué comando
demuestra que esto es viable?** Para E2 es un `autoinstall.yaml` mínimo sobre la
ISO oficial de Ubuntu Desktop 24.04 arm64 que instale desatendido y ejecute una
`late-command`. Si el instalador de escritorio no honra el seed como se supone,
E2 cambia de forma entera, y eso se sabe en media tarde o no se sabe.

### Lo aprendido que sigue valiendo

- **Una comprobación que pasa no vale nada si no sabes contra qué ha pasado.**
  Cuando una dé `[OK]`, comprueba que habría dado `[FALLO]` de haber estado mal.
  Las ocho trampas de `SCRIPTS.md` son ocho formas de que esto salga caro, y
  aplican igual dentro de un `autoinstall.yaml`.
- **Todo lo verificable sin pantalla no basta.** En A2, con las siete
  comprobaciones automáticas en verde, el icono seguía abriendo el Snap. Se vio
  mirando `about:support`, y estaba en español, así que parecía correcto.
- **Una deducción bien fundada puede acertar el mecanismo y errar la causa.**
  Pasó tres veces en un solo día (`MEDICIONES.md` §4.9, M12).
- **`git` a través del hook de `rtk` devuelve commits que no son.** Cualquier
  medición sobre git va con `/usr/bin/git` o `rtk proxy`.

---

## 8. Fuera de alcance ahora

No implementar, no preparar, no dejar «ganchos para el futuro»:

`encina-doctor` y cualquier herramienta de diagnóstico · `encina-locale-es` ·
DNIe, `opensc` y PKCS#11 como funcionalidad · repo APT **firmado** y
`encina-keyring` · `os-release` y `dpkg-divert` · `live-build`, `debos` y Cubic ·
temas de GTK o iconos · cualquier GUI · amd64.

Tres matices:

- **`encina-locale-es` y `encina-doctor` están aquí de forma permanente.** Los
  dos se midieron antes de abrirlos y los dos resultaron no existir. El resto de
  la lista espera turno y sale de aquí cuando le toque su incremento.
- **El repo APT firmado no hace falta y puede que no haga falta nunca.** Si los
  `.deb` solo los consume la construcción de la imagen, basta un repo local sin
  firmar generado en el propio build con `dpkg-scanpackages` y consumido con
  `[trusted=yes]`. Eso ejercita el mecanismo real —repo más metapaquete en el
  seed— sin gestión de claves, y la receta que se escriba así es la definitiva.
- **D13 sigue vigente.** Ninguna de las barreras de la firma se cierra desde
  `encina-branding` ni desde `encina-firefox-native`, por muy fácil que parezca.

---

## 9. Las VMs de UTM

`ssh jorge@192.168.64.3`, `sudo` sin contraseña. **Las ocho tienen el mismo
hostname (`encina-dev`) y la misma IP**, incluidas las clonadas: el hostname no
distingue nada. Para saber en cuál estás, lo que funciona es «paquetes
instalados + versión del Snap de Firefox + qué perfiles existen».

**No arrancar dos a la vez.** Se listan y se arrancan con `utmctl list` y
`utmctl start <nombre>`, sin abrir la interfaz de UTM.

| VM | Qué es | Vídeo | Estado |
|---|---|---|---|
| `encina-dev` | Banco de A1, con el usuario `prueba`. Snap 153.0.3 con perfil, sin Firefox nativo | `gpu-pci` | **En uso.** Aquí se verificó `encina-branding` 0.1.7 |
| `encina-E1-meta` | **Banco de E1.** Clon virgen instalado por la secuencia, con los cuatro paquetes y `encina-meta` 0.1.1. **Sin ningún certificado, a propósito** | `gpu-pci` | **En uso.** Aquí se ejecutó la definición de terminado de E1, y el 2026-08-08 el experimento de la tarjeta: nació `ramfb-gl` y **se cambió** (§4.12b) |
| `encina-E1-vigilante` | **Donde se cerró el defecto de §4.12a.** Clon virgen instalado por la secuencia de E1 **sin el cuarto paso**, con `autofirma 1.9.1+encina2`: la CA del socket llegó sola al perfil al abrir Firefox (M18 de `encina-autofirma`). **Sin ningún certificado personal**, así que no le aplican las precauciones de §9.1 | `gpu-pci` | **Parada.** Se queda de momento: es el testigo del arreglo. **No sirve para reproducir el caso virgen otra vez** —ya tiene la CA dentro—, para eso hay que clonar de nuevo. El autologin de GDM que hizo falta quedó revertido y verificado por huella (`ceee968c…10af`) |
| `encina-limpia-respaldo` | Ubuntu 24.04.4 arm64 de fábrica, sin nada. Firefox nunca abierto | `gpu-pci` | Se queda: línea base virgen, y de ella se clona. **Cambiada el 2026-08-08** para que los clones no nazcan con AutoFirma invisible (§4.12g) |
| `encina-autofirma-rota` | AutoFirma 1.9 **oficial** sobre Firefox nativo, con la cadena causal medida | `gpu-pci` | Se queda: es la mitad roja de las mediciones, y la base del positivo de §4.9 |
| `encina-dev-firefox` | «Hoy en el mismo estado que la anterior» | `gpu-pci` | **Redundante.** Candidata a borrar |
| `encina-snap-fabrica` | Ubuntu de fábrica + Snap. Caso positivo de la CA correcta y caso de prueba de B3 | `ramfb-gl` | **Ya no es candidata a borrar, y no por el Snap:** es el **único testigo de `ramfb-gl`** que queda, o sea el único sitio donde se puede reproducir que AutoFirma no se dibuja (§4.12g) |
| `encina-A2-verificada` | Red de seguridad de A2 | `gpu-pci` | A2 está en git y en CI verde. **Candidata** |
| ~~`encina-firma-efimera`~~ | El positivo de E1, sobre máquina virgen | `ramfb-gl` | **Destruida el 2026-08-08**, como manda §9.1: llevaba dentro el certificado personal |

**La columna de vídeo es nueva y no es decorativa: con `ramfb-gl`, la interfaz de
AutoFirma no se dibuja.** Medido el 2026-08-08 en la misma VM cambiando solo la
tarjeta (`MEDICIONES.md` §4.12b): `colores=1` con `ramfb-gl` y `colores=3858` con
`gpu-pci`, sin ninguna variable de entorno. Antes de saberlo, las VMs no eran
comparables entre sí y el diff completo de sus configuraciones de UTM daba **esa
única diferencia** (§4.12c): un resultado visual medido en una familia no valía
automáticamente en la otra.

**Ese mismo día se igualaron**, para que ningún clon nuevo vuelva a nacer con
AutoFirma invisible: `encina-E1-meta` y `encina-limpia-respaldo` pasaron a
`gpu-pci`. **`encina-snap-fabrica` se dejó a propósito en `ramfb-gl`**, porque
igualarlas todas escondería un fallo que un usuario final puede sufrir y hace
falta un sitio donde reproducirlo (§4.12g).

**Para saber qué tarjeta tienes puesta, `lspci` no sirve** — devuelve
`Virtio 1.0 GPU (rev 01)` con las dos. La que discrimina, validada contra los dos
estados conocidos antes de usarla (§4.12e):

```
sudo dmesg | grep '\[drm\] features:'      # +virgl = ramfb-gl ; -virgl = gpu-pci
```

### 9.1 No hay estado bueno conservable, y es a propósito

`encina-autofirma-firma` —la VM donde salió el primer positivo de extremo a
extremo el 2026-08-07— **ya no existe. Se destruyó deliberadamente porque
contenía el certificado personal de la FNMT**, y una máquina con un certificado
de firma real dentro no se guarda ni se clona. Es la decisión correcta y no se
revisa.

**La consecuencia hay que tenerla presente cada vez que se escriba una
definición de terminado**, porque es fácil escribir una casilla imposible:

- **El positivo sigue siendo real.** Está medido y registrado con sus salidas
  (`MEDICIONES.md` §4.9, y M11 del repositorio `encina-autofirma`). Lo que no
  hay es una máquina contra la que volver a contrastar.
- **Todo lo que no sea la firma final se verifica con un certificado de
  prueba**, sin tocar el personal: es lo que ya se hizo en M6 con
  `CERT-PRUEBA-ENCINA`, y lo que hacen las 21 comprobaciones de
  `verificar-deb.sh` en contenedor. Cubre las seis barreras salvo el «¿la sede
  lo acepta?».
- **La firma real es, por construcción, manual y efímera.** Se clona una VM, se
  mete el certificado, se firma en `valide.redsara.es`, se mira en pantalla, se
  anota, y **se destruye la VM**. No es un banco de pruebas: es un experimento
  de un solo uso.
- **Ninguna casilla puede decir «compruébalo contra el estado bueno».** No lo
  hay ni lo habrá. Puede decir «repite el experimento efímero», que es otra cosa
  y cuesta más.

---

## 10. Criterios de parada

- **E1.** Si `encina-meta` no puede declarar sus dependencias sin violar R10,
  parar: significa que `encina-firefox-native` está haciendo dos cosas y hay que
  partirlo antes de seguir. **Medido el 2026-08-08 y no dispara**
  (`MEDICIONES.md` §4.10). Y de paso se midió que **el remedio que este criterio
  prescribía no habría servido**: partir `encina-firefox-native` no compra nada,
  porque lo que impide declarar Firefox no es de quién sea el paquete, sino que
  el índice de Mozilla no está presente **cuando apt resuelve**. Un paquete
  aparte tendría el mismo problema en la misma transacción. Si el criterio vuelve
  a dispararse por otra vía, la salida es una **segunda orden** con `apt update`
  en medio, no un paquete nuevo.
- **E2.** Si el instalador de Ubuntu Desktop 24.04 arm64 no honra un
  `autoinstall.yaml` con `late-commands`, **no** forzarlo con Cubic ni con un
  chroot editado a mano (D4). Replantear la forma de la entrega.
- **E5.** Si a las dos semanas de abrir `live-build`/`debos` no hay una imagen
  que arranque, cerrarlo y quedarse en E3. E3 ya entrega el producto; E5 solo lo
  envuelve mejor. **Es donde este tipo de proyecto muere.**
- **B∥.** Si una PR entra rápido en el repositorio oficial, replantear el alcance
  del fork en lugar de continuar por inercia. Y aplicar D14: la retirada del fork
  la decide `verificar-deb.sh` sobre el `.deb` oficial, no la fecha de un merge.
- **General.** Antes de abrir cualquier incremento: **¿qué comando demuestra que
  este problema existe?** Si no lo hay, el incremento es una suposición. Ha
  suprimido dos fases ya.
