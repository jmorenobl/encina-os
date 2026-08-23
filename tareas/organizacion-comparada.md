# Qué es «un proyecto de distribución bien organizado»

**Este documento es la tarea 12 de [refactorizacion.md](refactorizacion.md), y
es el criterio, no el trabajo.** Compara cómo está organizado este repositorio
con cómo lo están los proyectos que hacen algo parecido, y dice de **cada
diferencia** si se adopta o se rechaza, con motivo. Escrito el **2026-08-23**,
sobre `main` en `62dd026`, árbol limpio.

**Lo que este documento NO hace, y va primero porque es lo que se cuela:** no
decide E5. Hoy `imagen/` **reempaqueta** la ISO oficial (D3) y casi todos los
proyectos de fuera **construyen** la suya. Cuando una diferencia sólo tiene
sentido si se construye la imagen, aquí se **señala** y se deja sin resolver:
esa decisión es de `ENCINA-OS.md`, no de una refactorización. Las filas
afectadas llevan **[E5]** y están recogidas juntas en §3.

**Su control, que la propia tarea 12 exige:** al menos una fila **rechazada**
con motivo. Si todo lo de fuera se adoptara, no se habría comparado: se habría
copiado. **Salen ocho filas rechazadas enteras de dieciocho**, más dos partidas
que también rechazan la mitad, y todas llevan su porqué.

*Y una corrección del propio documento, del 2026-08-23 y de las que este
repositorio persigue:* esta línea decía **«quince filas»** —y lo decía en cuatro
sitios—, **y son dieciocho**. Se cazó contando con `grep` la tabla ya escrita,
que es como se cazó la de «Diez tareas» que eran once. El **ocho** sí era
exacto. La cifra escrita a ojo se equivoca aunque quien la escriba acabe de
contar las filas una por una: no hay excepción, y ésta es la prueba.

---

## 1. Lo medido y lo leído, separados

Esto no es un adorno de método: la mitad de este documento es **prosa de otros
proyectos leída en la web**, que es la clase de fuente que este repositorio
nunca ha admitido en una casilla.

### 1.a `[MEDIDO]` — el árbol de hoy, con la orden al lado

Ejecutado en el Mac, sobre `62dd026`. Todo lo de esta tabla se puede volver a
sacar con la orden escrita en la columna de la derecha.

| Qué | Hoy | Con qué se sacó |
|---|---|---|
| Referencias `§N…` en el repositorio | **2 153** | `grep -roE '§[0-9]+(\.[0-9]+[a-z]?)*' --include='*.md' --include='*.sh' --include='*.py' --include='*.yaml' --include='*.yml' .` |
| Referencias `§4.x` **distintas** citadas | **305** | el mismo `grep` acotado a `§4\.[0-9]+[a-z]?`, `sort -u` |
| De esas 305, **cuántas no resuelven** | **1**, y es `§4.999` | resolutor de dos niveles, §1.c |
| Secciones `### 4.x` en `MEDICIONES.md` | **65** | `grep -cE '^### 4\.' MEDICIONES.md` |
| Sub-subsecciones `#### (x)` | **451** | `grep -cE '^#### \([a-z]\)' MEDICIONES.md` |
| Sub-subsecciones `**x) …` (la **otra** forma) | **62** | `grep -cE '^\*\*[a-z]\) ' MEDICIONES.md` |
| `MEDICIONES.md` | **17 211 líneas, 903 KB** | `wc -lc MEDICIONES.md` |
| La `§4` sola | **11 220 líneas** (81 → 11 301) | `grep -n '^## ' MEDICIONES.md` |
| Filas de la tabla de vigencia | **33** de 65 secciones | resolutor de §1.c |
| `ENCINA-OS.md` §7 | **1 724 líneas** (400 → 2 124) | `grep -n '^## [78]\. ' ENCINA-OS.md` |
| `imagen/fabricar-iso.sh` | **1 413 líneas** | `wc -l` |
| Línea más larga de `DIARIO.md` | **6 518 caracteres** | `awk '{print length}' DIARIO.md \| sort -rn \| head -1` |
| Guiones `.sh` versionados | **35** (36 en disco: uno de `medios/` no se versiona) | `git ls-files '*.sh' \| wc -l` |
| Guiones `.py` versionados | **7** | `git ls-files '*.py' \| wc -l` |
| Guiones que hacen `source` de `lib.sh` | **17**, y **ninguno de `imagen/`** | `grep -rn '^\s*\(source\|\.\) .*lib\.sh'` |
| Guiones que definen `ok()` por su cuenta | **12** (10 en `imagen/`, `lib.sh`, y la copia sin versionar) | `grep -rln '^ok()'` |
| Bancos con punto de entrada propio | **5** | `banco-cadena`, `banco-mecanismos`, `banco-veredicto`, `banco-autosuficiencia`, `veredicto-conteo.py --banco` |
| Números de trampa **distintos** citados | **45**, llegando hasta la **58** | `grep -rhoiE 'trampa [0-9]+' \| sort -nu` |
| Secciones «Y N más…» en `SCRIPTS.md` | **28** | `grep -cE '^## (Y \|Cuatro\|Tres\|Dos\|Cinco\|Una)' SCRIPTS.md` |
| Enlaces relativos en los `.md` | **128**, de los que **2 están rotos** | §1.c |
| Rutas de guion citadas que no existen | **6**, y **ninguna es un error** | §1.c |
| `Makefile` | **no hay** | `ls Makefile` |
| Runner de la CI | ~~**`ubuntu-latest`, sólo amd64**~~ **`ubuntu-24.04` y `ubuntu-24.04-arm` desde el 2026-08-23** (tarea 13, `MEDICIONES.md` §4.69) | `.github/workflows/build.yml` |
| `autofirma` en `imagen/repo-manifiesto.tsv` | **`1.9.1+encina4`** | `grep autofirma imagen/repo-manifiesto.tsv` |
| `autofirma` en los `.md` de este repositorio | **`+encina2` 25 veces**, `+encina4` 19 | `grep -rhoE '1\.9\.1\+encina[0-9]' --include='*.md' .` |
| `debian/changelog` del repositorio hermano | **`1.9.1+encina4`** | `head -1 ~/Projects/encina-autofirma/debian/changelog` |

### 1.b `[LEÍDO]` — el exterior, con su URL y su fecha

**Consultado el 2026-08-23.** Nada de esto está ejecutado ni verificado contra
un artefacto: es lo que dicen sus repositorios y su documentación. Se marca
como lectura a propósito, porque la web se mueve y este documento no.

| Proyecto | Qué se leyó | Dónde |
|---|---|---|
| **Linux Mint** | Los proyectos son **un repositorio por paquete** con `debian/` en la raíz (~156 repos). La herramienta de paquete es `mint-build`, que además instala las dependencias de construcción. El medio: *«We recently moved to a new framework which uses docker to spawn a Debian image and run its version of live-build»* —Clem, en los comentarios del blog—. **La receta del medio no aparece como repositorio público**: la pregunta se ha hecho en su propio GitHub y la respuesta remite al blog | [linuxmint/live-installer](https://github.com/linuxmint/live-installer) · [guía de desarrollo](https://linuxmint-developer-guide.readthedocs.io/en/latest/building.html) · [discussions#131](https://github.com/orgs/linuxmint/discussions/131) · [blog.linuxmint.com/?p=4611](https://blog.linuxmint.com/?p=4611) |
| **elementary OS** | `elementary/os` es **un repositorio sólo para el medio**: `build.sh` en la raíz, `etc/terraform-amd64.conf` y `etc/terraform-arm64.conf` como configuración, `upload.py`/`upload.sh`. Usa **`live-build` de Debian, no el parcheado de Ubuntu**, con `lb clean` → `lb config` → `lb build`. La ISO se nombra `elementaryos-$VERSION-$CHANNEL-$BUILD_ARCH.$YYYYMMDD` y el propio guion calcula **md5 y sha256**. La CI de GitHub tiene flujos **«Stable 8.1» y «Daily 8.1»**: construye imágenes solo | [elementary/os](https://github.com/elementary/os) · [build.sh](https://raw.githubusercontent.com/elementary/os/main/build.sh) |
| **Pop!\_OS** | `pop-os/iso` es **un repositorio sólo para el medio**, y la orden de entrada es **`make`**: `make` (ISO), `make all` (ISO + `.zsync` + `SHA256SUMS` + `SHA256SUMS.gpg`), `make qemu_bios`, `make qemu_uefi`, `make clean`, `make distclean`, `make serve`. La configuración está partida en **`mk/*.mk` por asunto** —`config.mk`, `germinate.mk`, `qemu.mk`, `chroot.mk`, `update.mk`— y hay variables de **epoch y fecha para que la construcción sea reproducible**. Los paquetes propios van en repositorios aparte con **`debian/` en la raíz** junto al árbol del sistema (`etc/`, `lib/`, `usr/`, `src/`) | [pop-os/iso](https://github.com/pop-os/iso) · [Makefile](https://github.com/pop-os/iso/blob/master/Makefile) · [pop-os/default-settings](https://github.com/pop-os/default-settings) |
| **Ubuntu Cinnamon** | **Es el caso que más enseña, por su trayectoria.** Empezó con un `iso-builder` que era *«Debian Live configuration and scripts… forked from elementary OS Terraform»*, o sea `live-build`. Al pedir el estatus de sabor oficial, lo que se discutió fue *«its seed is good»* y *«needed changes to `livecd-rootfs` and `ubuntu-cdimage` are mostly complete»*. **Al profesionalizarse, se movió de `live-build` a semilla + `livecd-rootfs` + `ubuntu-cdimage`** | [iso-builder-old-archive](https://github.com/Ubuntu-Cinnamon-Remix/iso-builder-old-archive) · [ubuntu-release@, 2023-03](https://lists.ubuntu.com/archives/ubuntu-release/2023-March/005575.html) |
| **`livecd-rootfs`** (Canonical) | **La receta del medio es ella misma un paquete Debian**: `debian/` en la raíz, con su `changelog` y su número de versión, y `live-build/` con las recetas por sabor. O sea que la receta **se versiona y se publica como cualquier otro paquete** | [git.launchpad.net/ubuntu/+source/livecd-rootfs](https://git.launchpad.net/ubuntu/+source/livecd-rootfs/tree/) |
| **`live-build`** | Herramienta genérica: `lb config` crea un árbol `config/` que la herramienta lee. La receta es **configuración declarativa**, no un guion | [manpages: lb_config(1)](https://manpages.debian.org/bookworm/live-build/lb_config.1.en.html) |
| **`debos`** | Recetas en **YAML**, acciones encadenadas (`debootstrap`, `apt`, `overlay`, `pack`, `raw`…), se distribuye como contenedor (`docker pull godebos/debos`). **Construye imágenes de disco y tarballs, no ISOs** | [go-debos/debos](https://github.com/go-debos/debos) |
| **Ubuntu QA** | La validación de una imagen antes de publicarla incluye **casos de prueba manuales que firma una persona**, por hito, producto y arquitectura, en `iso.qa.ubuntu.com`: *«Manual testing is still required due to the importance of the ISO experience»* | [wiki.ubuntu.com/Testing/QATracker](https://wiki.ubuntu.com/Testing/QATracker) |
| **Runners arm64 de GitHub** | `ubuntu-24.04-arm` es **gratis y en disponibilidad general para repositorios públicos desde el 2025-08-07**. 4 vCPU | [GitHub Changelog, 2025-08-07](https://github.blog/changelog/2025-08-07-arm64-hosted-runners-for-public-repositories-are-now-generally-available/) |
| **`~/Projects/encina-autofirma`** | **No es «fuera», y por eso es la comparación más barata que hay:** mismo autor, mismo método, otra forma. `debian/` **en la raíz**; guiones con **verbo primero y sin números** —`construir-deb.sh`, `verificar-deb.sh`, y **doce** `medir-<qué>.sh`—; `docker/Dockerfile.build`; y una CI que construye **en `ubuntu-24.04` y `ubuntu-24.04-arm` en paralelo**, con el motivo escrito en el propio fichero: *«todo lo probado a mano hasta ahora es arm64, y la corrección de las rutas de NSS existe precisamente porque el código llevaba escritas a mano las de x86. Una CI que solo mirase una arquitectura no habría encontrado ese fallo»* | `~/Projects/encina-autofirma`, leído en disco |

### 1.c `[MEDIDO]` — el estado de las referencias, que la lectura del 22 dejó en `[OMIT]`

`refactorizacion.md` cierra diciendo que **no se comprobó si alguna de las
1 857 referencias `§` está rota hoy**. Para el subespacio `§4.x` —305
referencias distintas— **ya está contestado, y la respuesta es que ninguna lo
está**. Pero llegar ahí ha enseñado tres cosas que cambian la tarea 1, y van en
§5.

**El resolutor, que es lo que hacía falta:** una referencia `§4.37c` **no
apunta a ninguna sección `### 4.37c`** —no existe— sino a un `#### (c)`
**dentro** de `### 4.37`. Y hay una **segunda** convención, `**c) …`, con 62
apariciones. Contado con las tres reglas encadenadas:

```
comprobador que sólo mira '### 4.x'          ->  204 de 305 en rojo   [FALSOS]
comprobador que mira '### 4.x' + '#### (x)'  ->   34 de 305 en rojo   [FALSOS]
comprobador que mira las dos convenciones    ->    1 de 305 en rojo
```

**Y ese 1 es `§4.999`** — la referencia inventada a propósito que la tarea 1
manda usar como control, **ya escrita** en `refactorizacion.md` línea 68. O sea
que el instrumento nace con su control puesto en el árbol y su primera
respuesta es un verde legítimo.

**Los dos enlaces relativos que SÍ están rotos hoy** (de 128):

```
[FALLO] MEDICIONES.md:16713   [alojamiento.md](alojamiento.md)
                              -> el fichero está en tareas/alojamiento.md
[FALLO] design/capturas/despues/entrega-cd84d2ec/LEEME.md:46
                              ../../../tareas/aspecto/5-cierre.md
                              -> faltan cuatro niveles, no tres
```

**No se arreglan aquí**, y el motivo es de método: los encuentra la tarea 1 y
son su carga útil declarada (*«si sobre el árbol de hoy ya hay referencias
rotas, se listan y se arreglan aquí»*). Arreglarlos ahora, a mano y sin el
instrumento, sería quitarle a la tarea 1 su primer resultado y dejarla sin nada
que demostrar la primera vez que corra.

**Y las seis rutas de guion que no existen, que es el hallazgo importante,
porque ninguna es un error:**

```
bancos/enlaces.sh  bancos/vigencia.sh  lib/salida.sh  lib/vm.sh
    -> los cuatro son ficheros PLANEADOS por refactorizacion.md
imagen/autoinstall-e3.yaml   imagen/verificar-e2.sh
    -> nombres HISTÓRICOS conservados A PROPÓSITO: SCRIPTS.md §renombrado
       lleva su tabla de equivalencias, y DIARIO.md los conserva porque es
       el registro de lo que se ejecutó aquel día
```

Sin una política de exclusión, `bancos/enlaces.sh` sale con **seis `[FALLO]`
el primer día**, ninguno cierto, y lo que se aprende es a ignorarlo. Eso es
exactamente una comprobación que no comprueba.

---

## 2. La tabla: una fila por diferencia

**Dieciocho filas. Ninguna sin veredicto**, comprobado con `grep` sobre la
tabla ya escrita y no de memoria. Las que llevan **[E5]** son las que
sólo tienen sentido si se construye la imagen, y están recogidas en §3.

### Dónde vive la receta del medio

| # | Qué hacen ellos | Qué hacemos | Veredicto | Por qué |
|---|---|---|---|---|
| **A1** | **Un repositorio aparte sólo para la receta del medio**: `elementary/os`, `pop-os/iso`, `ubuntucinnamon/iso-builder`. Los paquetes viven en otros | `imagen/` dentro del mismo repositorio que `debian-packages/` y `scripts/` | **RECHAZADA** | Ellos parten porque tienen equipos distintos y ~156 repositorios; nosotros tenemos **244 ficheros versionados y 59 MB** y un autor. Y el precio de partir **ya está medido en este proyecto**: `encina-autofirma` está separado con motivo escrito (D14, 580 MB de árboles) y esa separación **ya ha producido una deriva, hoy**: el manifiesto pincha `autofirma 1.9.1+encina4` y los `.md` de este repositorio siguen diciendo `+encina2` en **25 sitios**. Un segundo repositorio compra ese problema por segunda vez. Y rompería lo que sostiene la reproducibilidad: `construir-todo.sh` hace `git archive HEAD` **del producto entero de una vez**, así que hoy **una sola huella de árbol describe el conjunto** |
| **A2** | **La receta es configuración declarativa que lee una herramienta genérica**: el árbol `config/` de `live-build` (elementary, Mint), el YAML de `debos`, los ganchos por sabor de `livecd-rootfs` | `imagen/fabricar-iso.sh`: **1 413 líneas de bash**, 21 fases marcadas con comentario, y buena parte del fichero es prosa | **RECHAZADA HOY · [E5]** | Es **la fila que la tarea 12 avisaba que aparecería**, y aparece la primera. Un árbol `config/` no describe «coge esta ISO y añádele estos ficheros»: describe **cómo construir un sistema desde `debootstrap`**. Adoptar la forma obliga a adoptar el fondo, y eso es decidir E5 por la puerta de atrás. **Y no es una fila neutra:** hay que decir en voz alta que la respuesta del mundo exterior a «cómo se organiza una derivada de Ubuntu» es, casi por unanimidad, **«una que construye su propia imagen»**. D3 es la posición minoritaria. Eso **no** es motivo para cambiar D3 —el motivo de D3 sigue en pie— pero es el dato honesto, y es de `ENCINA-OS.md` |
| **A3** | **El entorno de construcción es una receta, no una máquina**: Mint levanta *«a Debian image [with] docker»*, `debos` se distribuye como contenedor, y **`encina-autofirma` tiene `docker/Dockerfile.build`** | `construir-todo.sh` va por `ssh` a un constructor que se pasa como `usuario@vm-linux`. **No hay ninguna receta versionada de cómo se hace esa máquina**: `00-entorno.sh` comprueba que están las herramientas, no las pone | **ADOPTADA A MEDIAS** | La mitad de los `.deb` **sí** cabe: construir tres paquetes `all` en un contenedor Debian es lo que hace el repositorio hermano. La mitad del medio **no**: `fabricar-iso.sh` usa `xorriso`, `sips` y `shasum` **de macOS** y ahí no hay contenedor que valga. Se adopta sólo la mitad que cabe, **y de forma aditiva**: escribir la receta del constructor sin tocar `construir-todo.sh`, que es guion de fabricar el medio |
| **A4** | **La orden que construye produce también sus sumas**: `make all` de Pop saca ISO + `.zsync` + `SHA256SUMS` + `SHA256SUMS.gpg`; el `build.sh` de elementary calcula md5 y sha256 al terminar | `medios/SHA256SUMS` existe —185 bytes, dos líneas— **y se escribe a mano** | **ADOPTADA** | Es barata y es exactamente lo que este repositorio predica: una huella que se apunta a mano es una huella que un día describirá otro fichero. Ya pasó, y está escrito: `TAREAS.md` cuenta cómo se escribió `95758c9e…` **por el nombre de la VM y no por la huella del fichero**. Va dentro de la tarea 6 |

### Dónde viven los paquetes propios y su `debian/`

| # | Qué hacen ellos | Qué hacemos | Veredicto | Por qué |
|---|---|---|---|---|
| **B1** | **Un repositorio por paquete, con `debian/` en la raíz**: `linuxmint/live-installer`, `pop-os/default-settings`, y también `encina-autofirma` | `debian-packages/<paquete>/{debian,src}` — tres paquetes en subdirectorios del mismo repositorio | **RECHAZADA** | Mismo motivo que A1, y uno más que es propio: los tres paquetes de este repositorio **se entregan siempre juntos** —`encina-meta` sólo tiene `Depends:` sobre los otros dos— y su definición de terminado es una secuencia de tres órdenes medida como una sola cosa (`AGENTS.md` §6.4). Partirlos en tres repositorios convierte una invariante que hoy se comprueba en una sola vuelta en tres versiones que hay que casar a mano |
| **B2** | **El árbol del sistema va en la raíz del repositorio del paquete**: Pop pone `etc/`, `lib/`, `usr/` al lado de `debian/`, y `dh` los instala | `src/`, copiado con `cp -a src/. debian/encina-<x>/` en un `override_dh_auto_install` | **RECHAZADA** | Con `usr/` en la raíz, quien abre el repositorio ve mezclados el árbol que va al sistema y la maquinaria que lo empaqueta. `src/` dice cuál es cuál en una palabra, y la regla —«árbol que se copia tal cual a la raíz del sistema»— está escrita en `AGENTS.md` §3. Es una diferencia real y la nuestra se defiende sola |
| **B3** | **La receta del medio es ella misma un paquete versionado**: `livecd-rootfs` tiene `debian/changelog` y número de versión, igual que cualquier `.deb` | `imagen/` no tiene versión ninguna. Lo único versionado son los tres `.deb` | **ADOPTADA EN LA IDEA, RECHAZADA EN LA FORMA** | La idea —**la receta también tiene versión, y se puede citar**— es buena y hoy no la tenemos: una ISO sólo se identifica por su huella, que no dice nada de qué receta la hizo. La forma —empaquetar `imagen/` como `.deb`— se rechaza: `livecd-rootfs` es un `.deb` porque **corre dentro de la infraestructura de Canonical**, y el nuestro corre en el Mac de Jorge. Se adopta como una sola fuente de la versión del producto (C1) |

### Cómo versionan

| # | Qué hacen ellos | Qué hacemos | Veredicto | Por qué |
|---|---|---|---|---|
| **C1** | **Una sola fuente de la versión del producto, y todo lo demás derivado**: elementary lee `$VERSION` de `etc/terraform-*.conf` y de ahí salen el nombre de la ISO y los ficheros de suma; Pop lo tiene en `mk/config.mk` | La versión del producto está **escrita a mano y en más de un sitio**. `imagen/marca/disk-info` dice `EncinaOS 24.04.4 LTS "Nutria Nocturna"`, el `Volume id` que D23 declara es `Encina OS 0.2.1 arm64`, y los `.deb` van por su cuenta: `encina-branding` **0.1.15**, `encina-firefox-native` **0.2.1**, `encina-meta` **0.2.1** | **ADOPTADA** | Hoy `0.2.1` nombra a la vez **el producto y dos de los tres paquetes**, y nada garantiza que sigan coincidiendo — de hecho `encina-branding` ya no coincide. Un tercero que lea `Encina OS 0.2.1` no puede saber a qué se refiere. Nótese que **la arquitectura ya se deriva** (`@ARQ@` en `disk-info`): existe el mecanismo, falta aplicárselo a la versión |
| **C2** | **Las versiones de los ingredientes viven en un fichero que lee una máquina**, no en prosa: Pop y Mint declaran dependencias en `debian/control` y anclan en ficheros de configuración; `encina-autofirma` **lee los tres tags de `scripts/construir-deb.sh` en la propia CI**, y falla si no los encuentra | `imagen/repo-manifiesto.tsv` **es exactamente eso y funciona**: pincha `autofirma 1.9.1+encina4` con su huella, y la CI lo comprueba con su sabotaje delante. **El problema es la prosa que lo rodea**: `AGENTS.md` dice `1.9.1+encina2` en su línea de alcance, y `+encina2` aparece **25 veces** en los `.md` contra **19** de `+encina4` | **ADOPTADA** | El mecanismo bueno ya existe; lo que falta es que **la prosa no pueda contradecirlo en silencio**. Es la misma enfermedad que la tarea 1 persigue con las referencias `§`, aplicada a las versiones, y ya ha mordido: la única fuente cierta hoy es un `.tsv` que nadie lee al escribir un documento |

### Qué automatiza su CI

| # | Qué hacen ellos | Qué hacemos | Veredicto | Por qué |
|---|---|---|---|---|
| **D1** | **La CI construye el MEDIO**: elementary tiene flujos «Daily» y «Stable» que fabrican y suben ISOs solas | La CI construye los **tres `.deb`**, con su control saboteado antes de la medición, y **no toca el medio**. `construir-todo.sh` se lanza a mano y cruza dos máquinas | **RECHAZADA HOY, con fecha de reapertura escrita · [E5]** | Dos motivos, y el segundo es el que manda. **(1)** `fabricar-iso.sh` usa herramientas de macOS y necesita la ISO oficial de 3,3 GiB como insumo: un runner no la tiene y bajarla en cada empujón es 3,3 GiB por empujón. **(2)** Su CI puede construir la imagen porque su insumo es `debootstrap` **y el nuestro es un fichero de Canonical** (D3). Elementary fabrica desde cero; nosotros partimos de un binario firmado que no se puede regenerar. **Qué la reabriría:** que se decida E5, o que aparezca un sitio donde cachear la ISO oficial sin volver a bajarla |
| **D2** | **La CI cubre las arquitecturas del producto.** `encina-autofirma` —mismo autor, mismo método— construye **amd64 y arm64 en paralelo**, con el motivo escrito dentro del fichero | `runs-on: ubuntu-latest` y nada más. `AGENTS.md` §7 lo escribe así —*«Runner: `ubuntu-latest` (amd64)»*— y §8 lo justifica: *«amd64… se construye en CI porque el runner es amd64»* | **ADOPTADA** | **Esa frase describe hoy justo al revés lo que importa: el que NO se construye en CI es `arm64`, que es el producto que D9 declara.** Los runners `ubuntu-24.04-arm` son **gratis y GA para repositorios públicos desde el 2025-08-07**, y este repositorio es público (D5). El precio es una línea de matriz. Y el argumento de por qué vale la pena ya está escrito, por el propio autor, en el otro repositorio: la corrección de las rutas de NSS **existió** porque el código llevaba escritas a mano las de x86, y una CI de una sola arquitectura no la habría encontrado |
| **D3** | **Un solo punto de entrada, y es `make`**, con la configuración partida en `mk/*.mk` por asunto (Pop) | **No hay `Makefile`.** Hay **cinco** bancos con cinco puntos de entrada, tres de ellos sin VM y de segundos, y **la CI no ejecuta ninguno** | **ADOPTADA — y confirma la tarea 6 desde fuera** | La tarea 6 se escribió mirando sólo hacia dentro y proponía `make bancos`, `make paquetes`, `make iso`, `make dos-veces`. Pop!\_OS tiene literalmente eso desde hace años y con la misma partición por asuntos. Es la fila que menos discusión merece **y la que corrige un conteo**: los bancos no son cuatro, son cinco |
| **D4** | **Arrancar el artefacto es un objetivo del `Makefile`**: `make qemu_bios`, `make qemu_uefi` | `scripts/fabricar-vm-medio.py --iso <iso> --nombre <n>` fabrica el bundle de UTM, y arrancarlo es una receta en prosa de `SCRIPTS.md` con su trampa 32 al lado | **ADOPTADA EN SU FORMA MÍNIMA** | No se cambia el instrumento, que funciona: se le pone una puerta en el `Makefile` para que la receta de arrancar no viva sólo en la prosa. Va dentro de la tarea 6 y **no toca ningún guion que fabrique el medio** |

### Qué publican como oferta de fuente

| # | Qué hacen ellos | Qué hacemos | Veredicto | Por qué |
|---|---|---|---|---|
| **E1** | **Publican el código y ya**: todo en GitHub o Launchpad, sin ningún documento que se llame «oferta de fuente» | Sección «Licencia y fuentes» en el `README`, con los **cuatro repositorios anclados por etiqueta**, y la CI de `encina-autofirma` que **reconstruye desde fuentes públicas** para demostrar que la oferta es cumplible | **RECHAZADA — se confirma la nuestra** | Su forma les basta porque **redistribuyen lo suyo**. Nosotros distribuimos un `.deb` **modificado de un tercero bajo GPL-3.0**, que es exactamente el caso donde «está en GitHub» no es una oferta: hay que decir **qué versión**, **de qué árbol** y **con qué se reconstruye**. Copiar lo de fuera aquí sería un retroceso legal, no una mejora de organización |
| **E2** | **Los ficheros de suma se publican junto a la descarga y se firman**: `SHA256SUMS` + `SHA256SUMS.gpg` (Pop, y es lo que hace Ubuntu) | `medios/SHA256SUMS` a mano, sin firmar | **PARTIDA: adoptada la suma (A4), RECHAZADA hoy la firma** | La firma se rechaza con motivo ya escrito y no es un descuido: `AGENTS.md` §7 dice que **la clave de firma de Encina no debe existir en el runner**, y §8 pone el repositorio APT firmado fuera de alcance. Firmar exige antes decidir dónde vive esa clave, y eso es de `publicar.md` (fase 3), no de una refactorización |

### Lo que fuera no tiene

| # | Qué hacen ellos | Qué hacemos | Veredicto | Por qué |
|---|---|---|---|---|
| **F1** | **Nada.** Ninguno de los siete proyectos tiene nada equivalente a `MEDICIONES.md`, a la tabla de vigencia, al control ejecutado antes de la medición ni al sabotaje que tiene que sabotear | 903 KB de mediciones con salida literal, 33 secciones con su vigencia declarada, y una CI que **rompe la huella a propósito antes de comprobarla** | **RECHAZADA toda importación** | Se escribe como fila y con veredicto **precisamente porque no hay nada que adoptar**: el riesgo de una comparación con el exterior es concluir que lo que nadie más tiene sobra. No sobra. La ausencia de esto fuera no es una señal de que sea innecesario: es la razón por la que sus fallos se discuten en foros y los nuestros están fechados |
| **F2** | **Casos de prueba manuales que firma una persona**, por hito, producto y arquitectura, en un tablero (`iso.qa.ubuntu.com`): *«Manual testing is still required»* | El vocabulario `[OJOS]` dice **exactamente lo mismo** y es mejor, porque distingue `[OJOS]` de `[OMIT]`. Lo que no tenemos es **el tablero**: los `[OJOS]` debidos están repartidos por `marca-del-medio.md`, `aspecto/5-cierre.md`, `publicar.md` y `ENCINA-OS.md` §7 | **ADOPTADA en su parte barata** | Ubuntu no inventó el vocabulario, inventó **el sitio donde se apunta**. Y hace falta ahora mismo: la fase 1 son **dos** medios y **dos** arquitecturas, y hoy no hay una sola hoja que diga qué mirada falta en cuál. Se adopta el tablero, no el vocabulario, que ya es mejor |
| **F3** | **El porqué vive fuera del código**: en mensajes de commit, en bugs de Launchpad, en hilos de listas de correo | El porqué vive **pegado al código que explica**: `fabricar-iso.sh` y `autoinstall.yaml` son en buena parte prosa, y los documentos llevan **enmiendas fechadas** en vez de reescrituras limpias | **RECHAZADA** | Es la fila que protege «Lo que este bloque NO toca», y va escrita con veredicto para que nadie la vuelva a abrir en nombre de la limpieza. Un comentario de 40 líneas dentro de `fabricar-iso.sh` parece desorden **hasta que el fichero cambia de manos**; un hilo de lista de correo de 2019 parece orden hasta que hay que encontrarlo |

**Recuento del control, sacado con `grep` de la tabla de arriba y no de memoria:** **18 filas**. Con veredicto de **adopción**, diez: A3 (a medias), A4, B3 (en la idea), C1, C2, D2, D3, D4, E2 (en su mitad), F2. Con veredicto de **rechazo**, diez: A1, A2, B1, B2, B3 (en la forma), D1, E1, E2 (en su otra mitad), F1, F3. **Dos filas dan los dos veredictos** —B3 y E2— y **ocho se rechazan enteras**: A1, A2, B1, B2, D1, E1, F1, F3. **Ninguna sin veredicto.** El control pasa: lo de fuera no se ha adoptado en bloque, y las tres cosas que este repositorio hace mejor que los siete comparados —la oferta de fuente, el registro de mediciones y el porqué pegado al código— están rechazadas **explícitamente** para que no se pierdan por descuido.

---

## 3. Dónde se toca E5, recogido en un sitio

Dos filas, **A2** y **D1**, y las dos se han dejado sin resolver a propósito.

**El hallazgo que `ENCINA-OS.md` necesitaría para decidir, y que este documento
sí puede aportar:** de los proyectos comparados, **ninguno reempaqueta**. Todos
construyen — Mint con `live-build` sobre Docker, elementary con `live-build` de
Debian, Pop con su `Makefile` y `debootstrap`, los sabores oficiales con
`livecd-rootfs`. Y **Ubuntu Cinnamon es el caso que más enseña**: empezó
forkeando el `live-build` de elementary y, al convertirse en sabor oficial, se
movió a **semilla + `livecd-rootfs` + `ubuntu-cdimage`**. O sea que la
trayectoria «hacerse profesional» y la trayectoria «construir la imagen» son,
ahí fuera, **la misma trayectoria**.

**Lo que eso NO demuestra, y hay que decirlo con la misma claridad:** ninguno de
esos proyectos tenía el insumo que tenemos nosotros. D3 no eligió reempaquetar
por pereza — eligió **heredar la capa de actualizaciones de Ubuntu** y no tocar
los tres binarios firmados. La unanimidad de fuera mide **qué hacen proyectos
con equipo y con infraestructura**, no qué es correcto para un producto de un
autor cuyo valor entero son cuatro `.deb`.

**Lo que se lleva `ENCINA-OS.md`, y es todo lo que esta tarea puede dar:** que
la organización de fuera **presupone construir**, que adoptarla en su forma
adoptaría el fondo, y que por eso A2 y D1 están rechazadas *hoy* y no *para
siempre*. **La decisión sigue sin tomar, y sigue siendo suya.**

---

## 4. Las casillas que nacen, para copiar a `refactorizacion.md`

Cuatro nuevas —**13 a 16**— y **una que cambia de forma**, la 6. Están escritas
enteras en [refactorizacion.md](refactorizacion.md); aquí queda de qué fila
sale cada una.

| Casilla | Sale de | Qué la cierra |
|---|---|---|
| **13.** La CI construye también `arm64` | **D2** | La matriz corre en `ubuntu-24.04` y `ubuntu-24.04-arm`, las dos en verde, y **la frase de `AGENTS.md` §8 corregida con su enmienda fechada** |
| **14.** Una sola fuente de la versión, y la prosa que no puede contradecirla | **B3 · C1 · C2** | La versión del producto sale de un sitio y el resto se deriva; `+encina2` desaparece de los `.md` o queda como enmienda fechada; y un banco lo comprueba **con su control** |
| **15.** El constructor de los `.deb`, versionado | **A3** | Existe la receta del constructor y con ella salen los tres `.deb` con **las huellas del manifiesto**. **Aditiva: no toca `construir-todo.sh`** |
| **16.** La hoja de los `[OJOS]` debidos | **F2** | Un fichero con una fila por `[OJOS]`, su medio y su arquitectura, y **ninguna fila marcada que Jorge no haya mirado** |
| **6.** *(cambia de forma)* | **A4 · D3 · D4 · E2** | Gana `make medios/SHA256SUMS`, `make dos-veces` y `make qemu`; y su conteo se corrige: **cinco** bancos, **35** guiones |

---

## 5. Relectura de las tareas 1 a 11 contra el código de hoy

La tarea 12 lo pide con estas palabras: *«Las tareas 2–11 se releen a la luz de
lo que salga aquí, y alguna puede caerse o cambiar de forma.»* **No se cae
ninguna. Las once se confirman.** Nueve cambian de forma o de cifra, y las
correcciones salen de **ejecutar**, no de leer — que es lo que la lectura del
2026-08-22 declaró que no había hecho.

**Antes de la tabla, la corrección que vale para todas.** Las cifras de
`refactorizacion.md` **no llevan al lado la orden que las produjo**, y por eso
la primera —«1 857 referencias `§N.NN`»— **no se reproduce**: sobre `99e0e39`,
que es el árbol que se leyó, `grep -roE '§[0-9]+(\.[0-9]+[a-z]?)*'` da **1 919**
y el patrón estricto `§N.N` da **1 682**; sobre el árbol de hoy, **2 153**. Las
tres son defendibles y ninguna es la escrita.

*Y hay que decir lo contrario también, porque es lo que salió al comprobarlo:*
**todas las demás cifras de aquella lectura son exactas.** Sobre `99e0e39`,
`ENCINA-OS.md` §7 medía 1 189 líneas, `MEDICIONES.md` 14 637 líneas y 765 KB con
60 subsecciones, `fabricar-iso.sh` 1 201 líneas, la tabla de vigencia 33 filas y
la línea más larga de `DIARIO.md` 6 518 caracteres. Comprobadas una a una contra
`git archive 99e0e39`: **seis de seis**. Así que lo que falla no es el rigor de
la lectura — **es que la única cifra cuya orden no es obvia es la única que no se
reproduce**. La enmienda es de forma, no de número: **la cifra va con su orden o
no va**, que es exactamente lo que la tarea 1 viene a instalar.

| Tarea | Veredicto | Qué cambia, medido hoy |
|---|---|---|
| **1.** `bancos/enlaces.sh` | **CONFIRMADA · cambia de forma** | Tres cosas que la especificación no tenía. **(a)** El espacio de referencias es **de dos niveles y con dos convenciones**: `§4.37c` no apunta a una sección `### 4.37c` —no existe ninguna— sino a un `#### (c)` dentro de `### 4.37`, y hay una segunda forma `**c) …` con **62** apariciones frente a **451**. Un comprobador que sólo mire `###` da **204 falsos `[FALLO]` de 305**; con `#### (x)`, **34**; con las dos, **1**. **(b)** Ese 1 es `§4.999`, **el control que la propia tarea manda inventar y que ya está escrito** en este fichero, línea 68: el instrumento nace calibrado. **(c)** Necesita **política de exclusión o nace mintiendo**: de 51 rutas citadas, 6 no existen y **ninguna es un error** —cuatro son ficheros que esta misma lista planea, dos son nombres históricos que `SCRIPTS.md` conserva con su tabla de equivalencias—. **Y contesta un `[OMIT]` por adelantado:** de las **305** referencias `§4.x` distintas del repositorio, **ninguna está rota hoy**. Lo que sí hay son **dos enlaces relativos rotos** de 128, listados en §1.c y **sin arreglar a propósito**: son la carga útil de esta tarea |
| **2.** `fallo()` en dos modelos | **CONFIRMADA · conteo corregido** | No son «cuatro que cuentan y seis que abortan»: son **cinco y seis**. Faltaba `imagen/banco-autosuficiencia.sh`, que cuenta y sigue. Y hay **un tercer nombre ya en el árbol**: `imagen/capa-marca.sh` define `morir()` **junto a** `fallo()`, o sea que el guion que más lo necesitaba ya inventó la palabra por su cuenta. **Eso refuerza la tarea y le quita una decisión:** propone `abortar()`, y el árbol ya votó `morir()` — hay que elegir uno, y hay precedente. El `set` se confirma **literalmente**: los trece `00`–`12` no lo declaran, y `capturar-vm.sh`, `teclear-vm.sh` y `fabricar-seed.sh` llevan sólo `set -u`. Se añaden tres que la lista no nombraba y tampoco lo declaran: `design/generar.sh`, `capturar-aspecto.sh` y `diario.sh` |
| **3.** `lib/salida.sh` | **CONFIRMADA · y el problema es mayor, en tres formas** | No son nueve guiones de `imagen/` reimplementando el vocabulario: son **diez** los que definen `ok()` por su cuenta. Y **el vocabulario se reimplementa de tres maneras distintas**, no de dos: funciones en `lib.sh`; funciones propias en esos diez; y **`echo "[OK]"` a pelo, con `printf` de formato propio, en los tres bancos** —`banco-cadena.sh`, `banco-mecanismos.sh`, `banco-veredicto.sh`—, que ni siquiera definen la función. **Y la frontera está medida y es limpia:** de los 17 guiones que hacen `source` de `lib.sh`, **ninguno está en `imagen/`**. Cero. La partición que la tarea propone coincide exactamente con una línea que ya existe |
| **4.** Partir `MEDICIONES.md` | **CONFIRMADA · cifras crecidas y una restricción nueva** | No son 765 KB y 14 637 líneas: son **903 KB y 17 211**. No son 60 subsecciones: son **65**, y la `§4` ocupa **11 220 líneas**. Creció **138 KB en un día**. **La restricción nueva, y es la misma que la tarea 1:** partir por `### 4.NN` deja 65 ficheros, pero **513 sub-subsecciones** son destino de referencia, así que **el nombre del fichero no puede ser el único ancla** — el ancla de dentro tiene que sobrevivir al corte, o el movimiento *verbatim* rompe 305 referencias que hoy resuelven |
| **5.** La tabla de vigencia | **CONFIRMADA · el 33 es exacto, el 60 ya no** | La tabla nombra **33** secciones y existen **65**: faltan **32**, no 27. Las 32 están listadas: `4.29`–`4.31`, `4.33`–`4.44`, `4.46`–`4.50`, `4.54`–`4.65`. **Y el patrón es el que importa:** lo que falta no está repartido, es **la cola** — de la `4.54` en adelante **no hay ni una sola fila**. La tabla no está «a mitad»: está al día hasta el 2026-08-15 y parada desde entonces |
| **6.** `Makefile`, bancos en CI, `shellcheck` | **CONFIRMADA · reforzada desde fuera · dos conteos corregidos** | Es la tarea que **más gana con la comparación**: `pop-os/iso` tiene literalmente `make`, `make all`, `make qemu_*`, `make clean` y la configuración partida en `mk/*.mk` por asunto. Se escribió mirando hacia dentro y coincide con lo de fuera. **Correcciones:** los bancos son **cinco**, no cuatro (`banco-autosuficiencia.sh`); y los guiones para `shellcheck` son **35 `.sh` versionados**, no 33 —hay 36 en disco, pero `medios/verificar-instalacion.sh` es una copia que `.gitignore` tapa con `medios/*`—. **Y gana tres objetivos** de las filas A4, D4 y E2: `make medios/SHA256SUMS`, `make dos-veces` y `make qemu` |
| **7.** Vaciar `ENCINA-OS.md` §7 | **CONFIRMADA · cifra crecida** | No son 1 189 líneas: son **1 724** (400 → 2 124). Creció **535 líneas** en un día. `CLAUDE.md` manda leer «la tarea en curso, y sólo esa» de un documento donde la tarea en curso empieza en la línea 404 y el resto es archivo |
| **8.** Los tres bloques de `diario.sh` | **CONFIRMADA · sin cambios** | La línea más larga sigue siendo **6 518** caracteres, exacta. `DIARIO.md` son **71 líneas y 200 KB**: una media de 2 824 caracteres por línea |
| **9.** `TRAMPAS.md` | **CONFIRMADA · y la cifra ha envejecido mal** | La lista decía *«`SCRIPTS.md` tiene veintidós y pico»*. Hoy se citan **45 números de trampa distintos** y **llegan hasta la 58**, repartidos en **28** secciones tituladas «Y una octava…», «Y cuatro más…», «Y una cuadragésima quinta…». La numeración global tiene **huecos** —no se citan por número la 6, la 23, la 25, la 30, la 33, la 34, la 37, la 39 ni las 52 a 56: **trece huecos de 58**—, y eso es exactamente lo que un índice con una fila por trampa haría visible. La tarea **es más urgente que cuando se escribió**, no menos |
| **10.** Renombrar los guiones | **CONFIRMADA · y gana un precedente que no estaba escrito** | La tarea justificaba el renombrado con el precedente del 2026-08-13. Hay uno mejor y **más cercano**: `~/Projects/encina-autofirma`, mismo autor y mismo método, **ya usa la convención de destino** —verbo primero, sin números—: `construir-deb.sh`, `verificar-deb.sh`, `estado-vm.sh` y **doce** `medir-<qué>.sh`. O sea que la convención no hay que inventarla ni copiarla de fuera: **ya existe al lado, y lleva meses funcionando** |
| **11.** `fabricar-iso.sh`, una función por fase | **CONFIRMADA · cifras corregidas · NO SE HA TOCADO** | No son 1 201 líneas: son **1 413**. Y **la descomposición no está tan hecha como la tarea supone**: dice «las 13 fases» marcadas «del 0 al 13», y lo que hay son **21 marcas `# ---`** con numeración **discontinua** —`0,1,2,3,4,5,6,7,10,11,13`— más **ocho** subfases (`5a`, `5b`, `5b-bis`, `5c`, `5c-bis`, `5d`, `5e`, `10bis`) y dos bloques sin número. Faltan la 8, la 9 y la 12. **La reagrupación no es mecánica: hay que decidir qué es fase y qué es subfase**, y eso es más trabajo del que la casilla presupone. **Sigue yendo la última, y hoy no se ha tocado un byte: la fase 1 está en curso sobre la huella `8924f148…`** |

**Lo que la relectura NO ha comprobado, y no se da por bueno.** `[OMIT]`: no se
ha ejecutado ningún banco ni ningún guion de construcción —sólo lectura,
conteo y resolución de referencias en el Mac—; no se han leído una a una las 65
subsecciones de `MEDICIONES.md` §4, así que **el solapamiento entre secciones
que la lista del 22 sospechaba sigue sin descartarse**; y el subespacio de
referencias comprobado es `§4.x`, o sea **305 de las 2 153** del repositorio —
las `§6ter`, `§9`, `§2.1` y demás **no** se han resuelto.

---

*Este documento se escribió el 2026-08-23 y su mitad exterior es lectura de la
web de ese día. Cuando la refactorización cierre, se va a `tareas/cerradas/`
con el resto del bloque.*
