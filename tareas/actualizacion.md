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
   **CONFIRMADA POR COMPORTAMIENTO EL 2026-08-31 (B1, `MEDICIONES.md`
   §4.84d):** con un Firefox más nuevo en Mozilla que el instalado, el
   `--dry-run` dice literalmente `pkg firefox is not in an allowed origin`,
   y en la misma pasada los openjdk de `noble-security` **sí** salen (el
   control). Matiz medido que la deducción no tenía: el origen de Mozilla
   para la sintaxis `o:a` **no** es `packages.mozilla.org` sino
   `namespaces/moz-fx-productdelivery-pr-38b5/repositories/mozilla`
   (§4.84d); C-bis lo tiene en cuenta.
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

*Enmienda del 2026-08-31 (noche): DECIDIDA — es **D24** en `ENCINA-OS.md` §2
(«Adelante con la recomendación»). La regla de abajo queda con dos ajustes que
D24 fija: NO existe la «edición» (toda refabricación sube `encina-meta`, la
regla de §7 confirmada tal cual) y la serie de la base va en el título de
**toda** release, no solo al saltar de mayor. El texto original se conserva
como estaba.*

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

- [x] **HECHA EL 2026-08-31, noche — es D24, y su «hecha cuando» está entero**
      (`MEDICIONES.md` §4.87): decisión de Jorge («Adelante con la
      recomendación») con número y fecha; las dos preguntas contestadas —la
      serie va en el título de **toda** release («Encina OS <versión>
      (Ubuntu <serie>)») y la «edición» NO existe: toda refabricación sube
      `encina-meta`—; la regla de §7 del 2026-08-29 queda **CONFIRMADA con la
      enmienda al lado** (en D24 y aquí); y `bancos/versiones.sh` vigila la
      serie con la comprobación (C) **y su control rojo** — el cotejo es
      entre el literal `SERIE_BASE` de `sacar-version.sh` (lo que el título
      dirá) y la ISO oficial anclada del `Makefile` (lo que la base es), que
      es donde una serie mal escrita hace daño de verdad; el «.md de mentira»
      de la casilla se sustituyó por ese sabotaje ejecutable, y el porqué
      está en D24. La casilla original: **A1. Decidir la regla de los tres relojes y escribirla como decisión en
      `ENCINA-OS.md` §2.** Con las dos preguntas abiertas contestadas: ¿la serie
      de la base va en el nombre del producto?, y ¿existe la «edición» o toda
      refabricación sube `encina-meta`? Es de Jorge; las opciones y su precio
      están arriba.
      *Hecha cuando:* la decisión tiene número `D` y fecha, la regla de §7 del
      2026-08-29 queda enmendada o confirmada **con la enmienda al lado**, y
      `bancos/versiones.sh` vigila lo que la decisión diga que hay que vigilar,
      **con su control rojo** (un `.md` de mentira con la serie mal escrita se
      señala).
- [x] ~~**A2. Declarar en el README cómo se actualiza Encina OS y cómo no.**~~
      **HECHA EL 2026-08-30, el mismo día, a petición de Jorge** (*«indicar que
      las actualizaciones de momento no están soportadas … en la baseline no hay
      camino fácil de upgrade»*): el README lleva la sección «Actualizar: de
      momento, no hay camino» con la tabla de los tres relojes, la fila
      «Actualizaciones: no soportadas» en «El estado», y **la línea base de
      `0.2.1` por arquitectura** (qué se instaló dónde y qué se comprobó), más
      el aviso de que la distribución es experimental. Lo que dice de
      `unattended-upgrades` y de 26.04 va escrito como **no medido**; B1 y B3
      lo corrigen cuando se midan. *(La mitad de B1, corregida el 2026-08-31:
      el README dice desde hoy la excepción medida de Firefox, §4.84. Queda
      la de B3.)* Las notas de `v0.2.1` en GitHub no se han
      tocado: es de Jorge. Y de paso se enmendaron **D9** («son las dos») y la
      fila E6 de `ENCINA-OS.md` §6, que decía «Sin abrir» ocho días después de
      estar hecho. Tres
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
- [x] **HECHA EL 2026-08-31, noche (`MEDICIONES.md` §4.86), con su «hecha
      cuando» ejecutado:** la receta es **una orden**, `make release
      NUEVA=X.Y.Z` (`imagen/sacar-version.sh`, nueve fases cronometradas), y
      la última pieza «a mano» —el ritual de los seis sitios, §4.48f— es
      desde hoy `imagen/actualizar-seis-sitios.sh`, idempotente sobre lo
      vigente (ni un byte) y con su control (un `.deb` de bytes cambiados
      mueve exactamente los cinco ficheros que llevan su huella). **Ensayada
      en seco entera sobre un árbol limpio: 20/0 en ~2 min 20 s**, con las
      horas de cada fase apuntadas en §4.86c y la salida en
      `design/capturas/despues/a3-receta/`. La obligación de D5 queda a
      medias a sabiendas: el ensayo tiene sus tiempos y las fases reales ya
      medidas llevan su fuente (la subida ~20 min, §4.82j); **el
      punta-a-punta real lo mide C4, que es quien estrena `DE_VERDAD=1`** —
      el modo real existe, no se ha ejecutado nunca, y sus dos actos
      irreversibles (subida y etiqueta) son de quien lo escribe. La casilla
      original: **A3. La receta de «sacar `0.2.2`», escrita y ejecutable antes de
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
- [ ] **A4. Un guion de respaldo y restauración del usuario, porque hoy
      «actualizar» es reinstalar.** Lo pidió Jorge el 2026-08-30: *«habría que
      hacer un backup de los certificados cargados y los documentos y listado de
      aplicaciones instaladas para poder reproducirlo una vez se ha
      reinstalado»*. Mientras no exista el canal del bloque C —y aunque exista,
      para el salto de serie— es el único camino que tiene alguien con una
      `0.2.1` puesta, y hoy es un párrafo del README hecho a mano. Dos guiones
      que viajen en el medio (`encina-branding` no es su sitio: es una
      responsabilidad nueva, va con `encina-keyring` si C1 es (b), o en un
      paquete propio pequeño si es (a)): `respaldar-usuario.sh` deja un solo
      `.tar` en un destino que el usuario elige, y `restaurar-usuario.sh` lo
      vuelve a poner en una máquina recién instalada. **Qué guarda, y cada cosa
      con su medición delante:** el perfil de Firefox entero (los certificados
      viven en `cert9.db`/`key4.db` del perfil, y copiarlos no cierra ninguna
      barrera de la firma: **D13 no se toca**, la CA del socket la sigue
      poniendo AutoFirma), la configuración de AutoFirma **donde esté** (no se
      sabe todavía: ni este repositorio ni `encina-autofirma` lo tienen escrito
      — es lo primero que se mide), la carpeta personal salvo cachés, y
      `apt-mark showmanual` + `snap list` con un `restaurar` que los reinstala.
      **Y lo que no guarda, dicho:** ni `/etc` ni claves del sistema; es del
      usuario, no de la máquina.
      *Control:* un `.tar` con un `cert9.db` cambiado en un byte se señala al
      restaurar; y restaurar sobre una máquina que **no** es Encina OS se niega.
      *Hecha cuando:* en una VM instalada desde `63f360dd…` con un certificado
      de pruebas cargado se **firma** (el positivo de extremo a extremo de E1),
      se respalda, se reinstala desde el mismo medio, se restaura, y **se
      vuelve a firmar** con el mismo certificado sin importar nada a mano; las
      dos firmas están en `MEDICIONES.md` y la de después es `[OJOS]` en
      `valide.redsara.es`, como la primera. Entonces el párrafo del README pasa
      a ser una orden.

## Bloque B — Medir lo que ya existe, sin cambiar nada (VM; cada medición desde una instalación limpia de `63f360dd…`, §9.1)

- [x] **HECHA EL 2026-08-31 (`MEDICIONES.md` §4.84a-d), y su «hecha cuando»
      ejecutado entero:** VM nueva `encina-b1-actualizacion` instalada
      desatendida desde `63f360dd…` (verificador 64/0); los dos actores
      fabricados degradando a las versiones de la cosecha (la máquina recién
      instalada estaba al día); la salida literal del `--dry-run` en §4.84d
      con las dos respuestas —el control de `noble-security` **sí** («pkgs
      that look like they should be upgraded: openjdk-17-jre …»), Firefox
      **no** («pkg firefox is not in an allowed origin»)—; el resultado
      convertido en **C-bis, que pasa al primer puesto del bloque C**, y el
      README enmendado. El `[OJOS]` de `update-manager` va en
      [ojos.md](ojos.md), **y quedó COBRADO POR JORGE esa misma mañana**
      (§4.84, enmienda): «Actualización de software» enseña la de Firefox en
      español, bajo «Otras actualizaciones» y no bajo «seguridad». La casilla
      original, tal como se escribió: **B1. Qué hace `unattended-upgrades` en una Encina OS instalada, con
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
- [x] **HECHA EL 2026-08-31 (`MEDICIONES.md` §4.84e), en la misma VM y después
      de B1, las tres salidas literales en la sección:** (P1) con el
      directorio apartado, `apt update` termina en **error, rc 100** (`E:
      Failed to fetch … Packages`), aunque las fuentes de red se refrescan en
      esa misma pasada y los cuatro paquetes de Encina quedan **sin
      candidato**; (P2) un `encina-branding` más nuevo instalado a mano **se
      respeta** (instalado a 100 es el candidato; el 500 del repo local no
      degrada nada y `full-upgrade` ni lo nombra); (P3) `trusted=yes` **no
      provoca ni un aviso** en `apt update` (sólo las `Ign:` de cortesía del
      repo plano, rc 0). Lo que le dice a C2 está escrito en §4.84e; **la
      decisión de retirar o dejar `encina-local.list` sigue siendo de C2**.
      Todo deshecho y verificado (directorio y `0.1.17` restaurados). La
      casilla original: **B2. La fuente local `trusted=yes` cuando
      `/srv/encina-repo` deja de cuadrar.** Tres preguntas, y las tres
      cuestan una orden: ¿qué dice `apt update` si el directorio se borra
      (¿aviso o error que para todo lo demás?)?; si se instala a mano un
      `encina-branding` más nuevo que el del repositorio local, ¿lo respeta
      `full-upgrade` o lo baja de versión? (`apt-cache policy
      encina-branding`); y ¿`apt` señala algo por `trusted=yes` en cada
      `update`? Esto decide si el bloque C **retira** la fuente local tras
      instalar o la deja para siempre.
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

- [x] **HECHA EL 2026-08-31, noche — es D25 = la opción (b), y su «hecha
      cuando» está entero:** decisión de Jorge («Adelante con la
      recomendación»); la fila de D5 lleva la enmienda fechada — desde que el
      canal exista (C4), un fallo en un paquete se responde publicando el
      `.deb` en el repositorio firmado, sin reinstalar; hasta entonces, medio
      nuevo con la receta de A3. Y una regla de orden que D25 fija: **el
      repositorio se publica —aunque vacío— ANTES de que ninguna máquina
      lleve `encina-keyring`** (el patrón de B2: una fuente sin servidor es
      rc 100 en cada `apt update`). La casilla original: **C1. Decidir (a), (b) o (c), y escribirlo en `ENCINA-OS.md` §2.** Si es
      (a), el bloque C se cierra aquí con esa decisión y A2 es su texto. Si es
      (b) o (c), lo de abajo.
      *Hecha cuando:* tiene número `D`, y la fila de D5 lleva una enmienda
      fechada diciendo cómo se responde a un fallo desde entonces.
- [ ] **C2. `encina-keyring`: la clave pública del proyecto, la fuente y nada
      más.** `/usr/share/keyrings/encina-archive-keyring.gpg` y
      `/etc/apt/sources.list.d/encina.sources` con `Signed-By:`, **una sola
      suite para todas las series** (como Mozilla; deducción 3), y la decisión
      de B2 sobre `encina-local.list` aplicada en su `postinst` o dejada en paz
      **con el motivo escrito** *(B2 está medida, §4.84e: dejarla no hace
      ruido y no pisa versiones; su precio es que sin `/srv/encina-repo` cada
      `apt update` devuelve rc 100 — la decisión se toma aquí, con eso
      delante)*. Con su `construir-`, `instalar-` y
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
- [x] **HECHA EL 2026-08-31, noche (`MEDICIONES.md` §4.85), con su «hecha
      cuando» ejecutado entero y UNA MITAD PENDIENTE DE JORGE:** banco rehecho
      por la receta de §4.84a (verificador 64/0), el control de B1 reproducido
      SIN fichero («pkg firefox is not in an allowed origin», openjdk sí),
      **las dos sintaxis medidas por separado y las dos en verde**, y la
      elegida es `Origins-Pattern` con `site=packages.mozilla.org` — el
      precio de cada una escrito en §4.85c; de propina, un
      `unattended-upgrade` **real** con el fichero puesto subió firefox
      153.0.4→154.0.1 (dpkg lo confirma, §4.85d). El fichero
      `52encina-firefox` vive en la `0.2.2` **propuesta** de
      `encina-firefox-native` (el `dch` está hecho en la rama, no en `main`)
      con la definición de terminado ejecutada (construir 40/0, lintian limpio,
      verificar 25/0 con purga y con la comprobación nueva y su control), y
      el README enmendado. **Lo que es de Jorge:** todo el paquete está en la
      rama local **`cbis-52encina-firefox`, SIN publicar**, porque
      aterrizarlo en `main` toca `repo-manifiesto.tsv` y eso es comprometerse
      al medio `0.2.2` (meta nueva, cosecha nueva, carpeta y etiqueta nuevas
      — §4.85f lo desglosa); y a las máquinas `0.2.1` ya instaladas el
      fichero solo les llega a mano o reinstalando. *Enmienda de la misma
      noche: la orden a mano YA ESTÁ ESCRITA en las notas de la release
      `v0.2.1`, por decisión de Jorge y editadas por el agente a su orden,
      verificadas releyendo (§4.85, enmienda final).* La casilla
      original: **C-bis. B1 CONFIRMÓ la deducción 2 el 2026-08-31 (§4.84d): los parches
      de Firefox NO llegan solos, y esta casilla PASA AL PRIMER PUESTO del
      bloque** — afecta a las máquinas `0.2.1` ya publicadas y, al revés que
      el resto del bloque C, no depende de A1 ni de C1: es un fichero en
      `encina-firefox-native`, que es de quien es la fuente. Un
      `/etc/apt/apt.conf.d/52encina-firefox` con
      `Unattended-Upgrade::Allowed-Origins { "packages.mozilla.org:mozilla"; }`
      (el nombre exacto del origen sale del `Release` de Mozilla, y se mide, no
      se copia de aquí — **y B1 ya lo midió, §4.84d: para la sintaxis `o:a`
      el origen es `namespaces/moz-fx-productdelivery-pr-38b5/repositories/mozilla`,
      no `packages.mozilla.org`; la alternativa robusta es `Origins-Pattern`
      con `site=packages.mozilla.org`, que no depende del nombre interno del
      Artifact Registry — se decide midiendo las dos formas**). Y lo mismo
      para el origen de Encina en `encina-keyring` si C1 es (b). El fichero
      llega a las máquinas ya instaladas sólo con un medio nuevo o a mano:
      eso también se escribe cuando se haga.
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

*Enmienda del 2026-08-31: B1 y B2 están hechas (§4.84) y el orden del bloque C
cambia en una cosa: **C-bis va primero**, porque no depende de A1 ni de C1 y
es lo único del bloque que arregla un hueco de seguridad de las máquinas ya
publicadas. Lo demás del párrafo sigue tal cual.*

Y una cosa que este fichero no hace, a propósito: **no construye un actualizador
propio**. Ubuntu ya tiene uno (`do-release-upgrade`) y `apt`; lo que Encina tiene
que garantizar es que **no rompen lo que Encina promete**, y eso se mide, no se
sustituye.
