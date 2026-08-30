# Actualizar Encina OS: los tres relojes, y lo que hay que medir antes de tocar nada

**Por qué este fichero existe, y desde cuándo.** Abierto el 2026-08-30, el día
siguiente a publicar, a pregunta de Jorge: *«¿cómo delimito lo que son
actualizaciones de los paquetes de versiones nuevas del sistema operativo? ¿y
cómo he de pensar el proceso de actualización de sistema operativo?»*. Hasta hoy
la palabra «actualización» aparecía en el repositorio sólo como **prueba** —el
`full-upgrade` x2 que demuestra que el Snap no vuelve— y nunca como **producto**.
Publicar la convierte en producto: hay máquinas que no son del banco con
`Encina OS 0.2.1` dentro, y lo que les pase a partir de ahora ya no se rehace en
el disco de Jorge.

**Nada de lo de aquí bloquea nada.** `v0.2.1` está publicada con lo que trae y lo
que no ([cerradas/publicar.md](cerradas/publicar.md)); esto es lo que viene
después, y su primer bloque es **medir**, no implementar. Es candidato a ser el
incremento **E7** de `ENCINA-OS.md` §6, y **no está inscrito allí**: se inscribe
cuando Jorge decida la primera casilla, no antes.

## Lo que ya está medido, y es el punto de partida

Separado de lo deducido, que va más abajo con su etiqueta.

- **La base se actualiza sola, y es lo que compra D3.** La máquina instalada
  bebe de `archive.ubuntu.com` como cualquier Ubuntu, y dos `sudo apt
  full-upgrade` seguidos **no reintroducen el Snap** (`AGENTS.md`, la casilla del
  `full-upgrade` x2; `MEDICIONES.md` §4.10 y §4.31). `unattended-upgrades` viene
  en la base y **hace `upgrade`, no `full-upgrade`** (§4.10), que es justo por lo
  que el paso 3 de la vía de Firefox no lo da nunca.
- **El anclaje es un fichero y una cifra:**
  `debian-packages/encina-firefox-native/src/etc/apt/preferences.d/encina-mozilla`,
  `Pin: origin packages.mozilla.org`, `Pin-Priority: 1000`, y
  `imagen/verificar-instalacion.sh` lo comprueba dentro de la máquina
  («el anclaje de Mozilla sigue a prioridad 1000»).
- **Los cuatro `.deb` de Encina NO tienen canal de actualización tras instalar.**
  `imagen/encina-seed.sh` copia `/encina-repo` del medio a `/srv/encina-repo` y
  deja `deb [trusted=yes] file:/srv/encina-repo ./` en
  `/etc/apt/sources.list.d/encina-local.list`; el verificador exige que la línea
  exista. Ese repositorio es **local y estático**: quien instaló `0.2.1` no
  recibirá nunca una `encina-branding` más nueva que la que viajó en su medio,
  salvo que baje un `.deb` a mano o reinstale. **No es un descuido: es lo que
  E2/E3 necesitaban para instalar sin red, y nadie le pidió más.**
  D5 ya cuenta con ello: su obligación de responder
  a un fallo de AutoFirma dice *«cortando imagen nueva»*, o sea, reinstalando.
- **La regla escrita al publicar** (`ENCINA-OS.md` §7, 2026-08-29 y 2026-08-30):
  *un medio nuevo es una `encina-meta` nueva, una carpeta nueva en SourceForge y
  una etiqueta nueva; nada publicado cambia. La base no flota; con `24.04.5` se
  decide si `0.2.2`.* Y el Volume id del medio **ya es** la versión de
  `encina-meta` (`bancos/versiones.sh`): sin decirlo, la versión del producto es
  la del metapaquete.

## Lo deducido, con su etiqueta — **NADA de esto está medido**

Se escribe aquí para que las tareas de abajo sepan qué contrastar, y para
tacharlo con fecha si resulta falso.

1. **`do-release-upgrade` desactiva las fuentes de terceros.** Al saltar de
   serie, el actualizador comenta toda fuente que no sea de Ubuntu y le pone
   `# disabled on upgrade to <serie>`; eso alcanzaría a la de Mozilla **y** a
   `encina-local.list`. Las preferencias de `apt` (el anclaje) no las toca. Sin
   la fuente de Mozilla no hay candidato nativo, y el `firefox` de Ubuntu lleva
   época `1:` —que es la razón misma de que el anclaje necesite `>= 1000`—, así
   que **el primer `full-upgrade` tras el salto reinstalaría el Snap**. Es la
   barrera que `encina-firefox-native` existe para cerrar, atacada por la única
   vía que nadie ha medido.
2. **`unattended-upgrades` no actualiza Firefox.** Sus `Allowed-Origins` por
   defecto son `${distro_id}:${distro_codename}-security` y ESM;
   `packages.mozilla.org` no está. Las correcciones de seguridad de Firefox
   llegarían sólo cuando alguien abra «Actualización de software» o teclee
   `apt`. Si es cierto, hay que **declararlo** o **cerrarlo**, y cerrarlo es un
   fichero en `/etc/apt/apt.conf.d/` que pertenece a `encina-firefox-native`.
3. **Existe una puerta documentada para la 1:** `/etc/update-manager/release-upgrades.d/*.cfg`
   admite `[Sources]` `AllowThirdParty=yes`, que conserva las fuentes de terceros
   durante el salto. Un paquete de Encina puede llevar ese fichero. La fuente de
   Mozilla tiene **una sola suite (`mozilla`) para todas las series**, así que
   sobrevive al cambio de nombre en clave; una fuente propia de Encina tendría
   que hacer lo mismo si quiere sobrevivir también.
4. **Los cuatro `.deb` puede que no instalen en 26.04.** Son `_all`, pero
   `autofirma` depende de un Java concreto (`openjdk-17`, que el archivo ya ha
   retirado en 24.04 dos veces, trampas 68 y 69), `encina-branding` escribe en
   rutas de Yaru, Plymouth y GDM que 26.04 puede haber movido, y la sombra de
   `firefox_firefox.desktop` cuenta con un Snap que 26.04 puede haber cambiado.

## La delimitación que se propone, y es decisión de Jorge

Un solo número —`0.2.1`— lleva hoy **tres relojes** que se mueven por manos
distintas:

| Reloj | Qué es | Quién lo mueve | Qué lo identifica |
|---|---|---|---|
| **La base** | Ubuntu 24.04 LTS, la serie; y dentro de ella los *point releases* 24.04.4, .5… | Canonical; Encina no toca nada (D3) | La serie, y la huella de la ISO oficial anclada (§4.83) |
| **Los paquetes** | `encina-branding`, `encina-firefox-native`, `encina-meta`, `autofirma` | Jorge, con `dch` | Su versión Debian, y `encina-meta` como receta de las otras tres |
| **El medio** | Una ISO = una base + una cosecha + unos `.deb`, fijada por su `sha256` | `make dos-veces` | La huella, no el número |

Firefox es un cuarto reloj que **no es de Encina**: flota desde Mozilla y no
entra en la versión del producto.

La regla, con su precio:

- **Un `.deb` nuevo → `encina-meta` sube en menor** (`0.2.1 → 0.2.2`). Es una
  «actualización de paquetes». La base no cambia y **la máquina instalada no
  tiene que reinstalarse** — si existe el canal del bloque C; si no, sí.
- **Una base nueva (Ubuntu 26.04) → `encina-meta` sube en mayor** y el nombre
  del producto lleva la serie al lado: *«Encina OS 1.0 (Ubuntu 26.04)»*. Es lo
  único que de verdad es «versión nueva del sistema operativo», porque cambia lo
  que hay debajo de los cuatro paquetes. Un usuario de `0.x` llega ahí por
  `do-release-upgrade`, si el bloque D demuestra que puede, o reinstalando.
- **Refabricar el medio con los mismos `.deb` sobre un *point release* más
  nuevo → misma versión, huella nueva.** Es una **edición** del medio, no una
  versión del producto, y la distingue `SHA256SUMS` y la carpeta en SourceForge.
  *Choca con la regla de §7 («un medio nuevo es una `encina-meta` nueva»), y hay
  que resolverlo en la casilla A1: o toda refabricación sube la versión —más
  simple, y `encina-meta` cambia sin que cambie nada suyo—, o se admite la
  edición —más honesto, y hace falta un segundo identificador.*

Precio: la serie de la base pasa a estar escrita en el Volume id o en el nombre
de la release, y `bancos/versiones.sh` tiene que vigilar ese segundo número. Lo
que compra: quien lee «0.2.2» sabe que no reinstala; quien lee «1.0 (26.04)»
sabe que hay un salto de base debajo.

## Bloque A — Delimitar: una decisión y dos textos (sin VM)

- [ ] **A1. Decidir la regla de los tres relojes y escribirla como decisión en
      `ENCINA-OS.md` §2.** Con las dos preguntas abiertas contestadas: ¿la serie
      de la base va en el nombre del producto?, y ¿existe la «edición» o toda
      refabricación sube `encina-meta`? Es de Jorge; las opciones y su precio
      están arriba.
      *Hecha cuando:* la decisión tiene número `D` y fecha, la regla de §7 del
      2026-08-29 queda enmendada o confirmada **con la enmienda al lado**, y
      `bancos/versiones.sh` vigila lo que la decisión diga que hay que vigilar,
      **con su control rojo** (un `.md` de mentira con la serie mal escrita se
      señala).
- [ ] **A2. Declarar en el README cómo se actualiza Encina OS y cómo no.** Tres
      frases, y son las medidas: la base se actualiza sola desde Ubuntu; los
      cuatro paquetes de Encina **no** (hasta que el bloque C exista: un
      `.deb` nuevo es un medio nuevo, y la máquina instalada lo recibe
      reinstalando o instalando el `.deb` de la release a mano); y el salto a la
      LTS siguiente **no está medido**. Es un límite declarado con la forma de
      D9, no un pendiente. *Las notas de `v0.2.1` en GitHub se pueden editar sin
      cambiar ningún fichero publicado, y si se añade allí es Jorge quien lo
      hace y con fecha: «nada publicado cambia» habla de los ficheros y sus
      huellas, no de un aviso fechado.*
      *Hecha cuando:* el README lo dice en una sección propia, y esa sección
      cita este fichero y las casillas B1 y B3 como lo que la sostiene.
- [ ] **A3. La receta de «sacar `0.2.2`», escrita y ejecutable antes de
      necesitarla.** Hoy está repartida entre `mk/*.mk`, `subir-sourceforge.sh`,
      `make publicar` y la regla de §7. Un solo apartado en `SCRIPTS.md` —o un
      `make release`— que encadene: `dch` en la VM, los tres `.deb` por huella,
      `make dos-veces` por arquitectura, `make cosecha`, `make publicar
      --url-base` con la carpeta nueva, la subida, la etiqueta, y el README.
      **Y la obligación de D5 dentro:** el mismo camino es el que responde a un
      fallo de seguridad de AutoFirma, así que se mide **cuánto tarda de punta a
      punta** y se escribe.
      *Hecha cuando:* se ha ensayado en seco una vez sobre un árbol limpio
      —`make publicar` ya tiene ensayo en seco (§4.82g)— con las horas
      apuntadas, y ninguna orden de la receta es «a mano».

## Bloque B — Medir lo que ya existe, sin cambiar nada (VM; cada medición desde una instalación limpia de `63f360dd…`, §9.1)

- [ ] **B1. Qué hace `unattended-upgrades` en una Encina OS instalada, con
      Firefox y con los cuatro `.deb`.** Contrasta la deducción 2. En la máquina
      recién instalada: `systemctl list-timers apt-daily*`,
      `/etc/apt/apt.conf.d/20auto-upgrades`, `50unattended-upgrades` y
      `unattended-upgrade --dry-run --debug` con `firefox` teniendo un
      candidato más nuevo en Mozilla (esperar a que Mozilla publique, o
      instalar a mano la versión anterior de la cosecha, que está publicada y
      con huella).
      *Control:* un paquete de `noble-security` con candidato más nuevo **sí**
      aparece en el mismo `--dry-run`. Sin ese control, «Firefox no sale» no
      distingue «no está permitido» de «no había nada».
      *`[OJOS]`:* «Actualización de software» (`update-manager`) **sí** enseña
      la de Firefox al abrirse, y lo dice en español. Va a [ojos.md](ojos.md).
      *Hecha cuando:* la salida literal del `--dry-run` está en
      `MEDICIONES.md` con las dos respuestas, y el resultado está escrito en A2
      o se convierte en la casilla C-bis de abajo.
- [ ] **B2. La fuente local `trusted=yes` cuando `/srv/encina-repo` deja de
      cuadrar.** Tres preguntas, y las tres cuestan una orden: ¿qué dice `apt
      update` si el directorio se borra (¿aviso o error que para todo lo
      demás?)?; si se instala a mano un `encina-branding` más nuevo que el del
      repositorio local, ¿lo respeta `full-upgrade` o lo baja de versión?
      (`apt-cache policy encina-branding`); y ¿`apt` señala algo por
      `trusted=yes` en cada `update`? Esto decide si el bloque C **retira** la
      fuente local tras instalar o la deja para siempre.
      *Hecha cuando:* las tres salidas literales están en `MEDICIONES.md` y la
      casilla C2 cita cuál de las dos cosas hace con `encina-local.list` y por
      qué.
- [ ] **B3. EL SALTO DE LTS CONTRA EL ANCLAJE — la medición que decide el
      bloque D.** Contrasta las deducciones 1 y 4. En una VM instalada desde
      `63f360dd…`: (1) `apt-cache policy firefox`, `dpkg -l firefox`, `snap
      list`, `dpkg-query -W` de los cuatro `.deb`, y `verificar-instalacion.sh`
      como root, **antes**; (2) `do-release-upgrade` tal como lo haría el
      usuario —`Prompt=lts` en `/etc/update-manager/release-upgrades`, sin `-d`—
      guardando `/var/log/dist-upgrade/` entero y el `sources.list.d/` de
      después; (3) las mismas cinco cosas **después**, y (4) otra vez tras
      `sudo apt full-upgrade` x2.
      *Control:* el mismo camino sobre una Ubuntu 24.04 oficial **sin** los
      `.deb` de Encina tiene que dejar el Snap de Firefox donde estaba; si no lo
      deja, el resultado no es de Encina.
      *Lo que no se puede fingir:* hace falta que exista `26.04.1`, que es
      cuando `Prompt=lts` ofrece el salto. Si no está, la casilla queda
      `[OMIT]` con la fecha en que se miró y **no se sustituye por `-d`**: el
      producto no lo ofrecerá con `-d`.
      *Hecha cuando:* la tabla antes / después / tras `full-upgrade` x2 está en
      `MEDICIONES.md` con las salidas literales y las líneas
      `# disabled on upgrade to` que hayan aparecido; la deducción 1 queda
      **confirmada o tachada con fecha**; y el estado de cada uno de los cuatro
      `.deb` en 26.04 —instalado, roto, sin candidato— está escrito con el
      motivo (`apt-get -s`, `dpkg -C`, `journalctl` de Plymouth y GDM).
- [ ] **B4. Los cuatro `.deb` sobre una 26.04 limpia, sin pasar por el salto.**
      Es la otra mitad de la deducción 4 y separa dos causas que B3 mezcla: lo
      que rompe **el salto** de lo que rompe **la serie**. Una VM con la ISO
      oficial de 26.04, los cuatro `.deb` de la release `v0.2.1` (por huella) y
      la secuencia de E1 (`apt update`, `full-upgrade`, idioma).
      *Control:* la misma secuencia en 24.04 da 0 fallos (ya medido, §4.10).
      *Hecha cuando:* `verificar-instalacion.sh` da su recuento en 26.04 y cada
      `[FALLO]` tiene al lado si es de rutas (branding), de Java (autofirma), del
      Snap (firefox-native) o de `Depends` (meta).

## Bloque C — Implementar el canal de los paquetes de Encina (sólo tras B2, y con A1 decidida)

**Qué se decide primero, y es de Jorge:** si Encina OS es un producto **con**
actualizaciones o un medio que se reinstala. Las dos son honestas si se
declaran (A2). Las opciones, con su precio:

| Opción | Qué compra | Qué cuesta |
|---|---|---|
| **(a) Ninguna, declarada** | Nada que custodiar; coherente con D5 tal como está escrita | Un fallo de seguridad en AutoFirma se responde con un medio nuevo y **reinstalar**; y la deducción 2, si es cierta, deja Firefox sin parches automáticos |
| **(b) Repositorio `apt` estático firmado, publicado junto a la release** (SourceForge ya sirve ficheros estáticos con `302`, medido en §4.82h) | Un `full-upgrade` trae `0.2.2` a las máquinas instaladas; D5 se cumple sin reinstalar; **los `.deb` son los mismos bytes, por huella**, que los del medio | Una clave que custodiar; un **quinto paquete** con la clave y la fuente; y `apt` tiene que seguir el `302` de SourceForge (medir) |
| **(c) PPA en Launchpad** | Firma y alojamiento resueltos por Launchpad; ya se cosecha de allí (trampa 68) | Launchpad **construye** los `.deb` desde fuente: los bytes no serían los de la huella publicada, y la reproducibilidad de §4.39 deja de ser un argumento para el canal |

**Recomendación: (b)**, por robustez y porque no cambia lo que ya es verdad del
producto (los `.deb` por huella). Y con el paquete de la clave **separado** de
los cuatro: `encina-firefox-native` es «la fuente de Mozilla y su anclaje» y
`encina-branding` es lo que se ve; una clave y una fuente propias son una
responsabilidad nueva y R-«un paquete, una responsabilidad» pide que tenga
nombre propio (`encina-keyring`, como `ubuntu-keyring`).

- [ ] **C1. Decidir (a), (b) o (c), y escribirlo en `ENCINA-OS.md` §2.** Si es
      (a), el bloque C se cierra aquí con esa decisión y A2 es su texto. Si es
      (b) o (c), lo de abajo.
      *Hecha cuando:* tiene número `D`, y la fila de D5 lleva una enmienda
      fechada diciendo cómo se responde a un fallo desde entonces.
- [ ] **C2. `encina-keyring`: la clave pública del proyecto, la fuente y nada
      más.** `/usr/share/keyrings/encina-archive-keyring.gpg` y
      `/etc/apt/sources.list.d/encina.sources` con `Signed-By:`, **una sola
      suite para todas las series** (como Mozilla; deducción 3), y la decisión
      de B2 sobre `encina-local.list` aplicada en su `postinst` o dejada en paz
      **con el motivo escrito**. Con su `construir-`, `instalar-` y
      `verificar-keyring.sh` por la misma convención que los otros tres, y en la
      CI. **La clave privada no entra en este repositorio** ni en la CI: se
      escribe dónde vive, quién la tiene y cómo se rota, y se mide que un `.deb`
      firmado con **otra** clave es rechazado por `apt`.
      *Hecha cuando:* `lintian` limpio, instala e idempotencia x5 como los
      demás, `apt update` en una `0.2.1` con el paquete puesto enseña el origen
      de Encina en `apt-cache policy`, **y** con la clave equivocada `apt
      update` falla en rojo con `NO_PUBKEY` (el control).
- [ ] **C3. `make repo`: el repositorio firmado a partir de los `.deb` por
      huella, y su subida.** `dists/<suite>/` con `Packages`, `Release`,
      `InRelease` (`apt-ftparchive` o `reprepro` en la VM; el Mac no tiene
      ninguno, trampa de siempre), firmado con la clave de C2, y
      `subir-sourceforge.sh` sabiendo subirlo a `repo/` **sin tocar `0.2.1/`**.
      `Release` lleva fecha y no será byte a byte reproducible; lo que sí se
      exige es que **cada `.deb` del repositorio sea, por huella, el de una
      release publicada**: `comprobar-propios.sh` contra el manifiesto lo mide.
      *Hecha cuando:* desde una VM `0.2.1` con `encina-keyring` puesto, `apt
      update && apt full-upgrade` trae una `encina-branding` **real** un número
      más alta (aunque el cambio sea una línea de `changelog`) y
      `verificar-instalacion.sh` da 0 fallos después; y **el anclaje de Firefox
      sigue a 1000** en ese mismo `apt-cache policy` —el canal nuevo no puede
      pagarse con el viejo—. Control: con la fuente cortada (`127.0.0.1:1`,
      como en §4.82) `apt update` falla y nada cambia.
- [ ] **C4. El medio que nace con el canal puesto.** `encina-meta` declara
      `encina-keyring` en `Depends`, la cosecha lleva el quinto `.deb`,
      `encina-seed.sh` comprueba su huella como las otras cuatro, y el
      verificador exige `encina.sources` además de `encina-local.list`. Es la
      primera `encina-meta` nueva, y por la regla de §7, **la primera carpeta
      nueva en SourceForge y la primera etiqueta nueva**: A3 se ejecuta aquí de
      verdad, no en seco.
      *Hecha cuando:* `make dos-veces` por arquitectura da una huella; el clon
      limpio la reproduce sólo con lo publicado (la condición de cierre de
      [cerradas/publicar.md](cerradas/publicar.md), otra vez); y una máquina
      instalada desde ese medio recibe por `apt` la siguiente versión sin que
      nadie le añada nada.
- [ ] **C5. Las máquinas `0.2.1` que ya existen.** No tienen la clave y no
      pueden recibirla por `apt`: es **un paso a mano, una vez**, y hay que
      escribirlo en el README con la orden exacta y la huella del `.deb` de
      `encina-keyring` al lado. Es lo único de todo el bloque que no se puede
      arreglar desde el repositorio, y por eso se escribe y no se esconde.
      *Hecha cuando:* la orden del README, copiada tal cual en una VM `0.2.1`
      limpia, deja `apt-cache policy` enseñando el origen de Encina, y a
      continuación C3 se cumple en ella.
- [ ] **C-bis. Si B1 confirma la deducción 2: los parches de Firefox llegan
      solos.** Un fichero `/etc/apt/apt.conf.d/52encina-firefox` con
      `Unattended-Upgrade::Allowed-Origins { "packages.mozilla.org:mozilla"; }`
      (el nombre exacto del origen sale del `Release` de Mozilla, y se mide, no
      se copia de aquí), **en `encina-firefox-native`**, que es de quien es la
      fuente. Y lo mismo para el origen de Encina en `encina-keyring` si C1 es
      (b).
      *Hecha cuando:* el `--dry-run` de B1 repetido con el fichero puesto
      **sí** lista a Firefox, y sin el fichero (el control, que es la propia
      B1) no.

## Bloque D — El salto de LTS: implementar lo que B3 y B4 digan (no se abre antes)

- [ ] **D1. Que las fuentes de Encina y de Mozilla sobrevivan a
      `do-release-upgrade`.** Si B3 confirma la deducción 1: un fichero
      `/etc/update-manager/release-upgrades.d/encina.cfg` con `[Sources]`
      `AllowThirdParty=yes`, **en `encina-firefox-native`** —la barrera que mide
      es «el Snap vuelve», que es la suya, y `verificar-firefox.sh` ya tiene el
      `full-upgrade` x2—. Si B3 la tacha, esta casilla se cierra con la
      medición al lado y sin fichero.
      *Hecha cuando:* B3 repetida entera con el fichero puesto deja `firefox`
      nativo, el anclaje a 1000 y `snap list` sin Firefox tras `full-upgrade`
      x2; y **sin el fichero** (el control) pasa lo que B3 midió la primera vez.
- [ ] **D2. Que los cuatro `.deb` —cinco, si hay C2— instalen en la serie
      nueva.** Cada `[FALLO]` de B4 con su remedio: `Depends` alternativos
      (`openjdk-17 | openjdk-21`, si AutoFirma lo admite: es del otro
      repositorio y tiene sus M1–M20), rutas de Yaru/Plymouth/GDM comprobadas en
      el `postinst` y no supuestas, la sombra del `.desktop` contra el Snap que
      haya. **D13 sigue mandando:** nada de lo que se arregle aquí cierra
      barrera alguna de la firma fuera del paquete de AutoFirma.
      *Hecha cuando:* B4 repetida da 0 fallos en 26.04 **y sigue dando 0 en
      24.04** (los mismos `.deb` en las dos series; si hacen falta dos ramas de
      `changelog`, se escribe por qué).
- [ ] **D3. «Encina OS 1.0 (Ubuntu 26.04)»: el medio sobre la base nueva.** Es
      un incremento entero —ISO oficial nueva anclada y conservada como en
      §4.83, cosecha nueva, `inventario-marca.sh` sobre un instalador que puede
      haber cambiado, D23 revisada, `ojos.md` otra vez— y **no se abre hasta que
      D1 y D2 estén medidas**, porque sin ellas las máquinas `0.x` no tienen
      camino y el medio nuevo sería una reinstalación disfrazada de versión.
      *Hecha cuando:* lo mismo que cerró `v0.2.1`, sobre la serie nueva, y
      **además** una máquina `0.2.x` llevada por `do-release-upgrade` da el mismo
      `verificar-instalacion.sh` que una instalada desde el medio `1.0`. Esa
      igualdad es la definición de «actualización del sistema operativo» en este
      proyecto: no que salga una ISO, sino que **los dos caminos lleguen al mismo
      sitio**.

## El orden, y por qué

**A1 y A2 primero y sin VM**, porque son las que faltan para que el README diga
la verdad hoy. **B3 en cuanto exista `26.04.1`**, porque es la única medición
que puede convertir una deducción en un fallo del producto en manos de un
usuario, y hasta entonces se mira la fecha y se apunta `[OMIT]`. **B1 y B2
cuando toque encender una VM por cualquier otro motivo**: cuestan una orden
cada una y no dependen de nada. **C detrás de A1 y B2**, porque implementar un
canal sin haber decidido qué es una versión es pagar dos veces. **D detrás de
B3 y B4**, por definición.

Y una cosa que este fichero no hace, a propósito: **no construye un actualizador
propio**. Ubuntu ya tiene uno (`do-release-upgrade`) y `apt`; lo que Encina tiene
que garantizar es que **no rompen lo que Encina promete**, y eso se mide, no se
sustituye.
