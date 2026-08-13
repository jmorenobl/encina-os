# Lo que queda por hacer

**Cómo se usa esta lista.** Cada tarea es de un rato, no de una tarde, y lleva
tres cosas: **qué** hay que hacer, **por qué** —porque si no se sabe, se hace mal
o no se hace—, y **cómo se sabe que está hecha**, que es una salida concreta y no
una sensación. Los bloques van en orden: el 1 no se puede terminar sin el 0.

Lo que ya está hecho no vive aquí: vive en `AGENTS.md` como casilla marcada y en
`MEDICIONES.md` con sus salidas.

---

## Bloque 0 — REPRODUCIBILIDAD: el medio se fabrica, no se hereda

**El agujero, medido el 2026-08-13:** para fabricar la ISO hace falta *la ISO
anterior*. Los 28 `.deb` del repositorio offline **solo viven dentro del medio**,
y se sacan de él con `xorriso`. Si mañana se pierde `ac0a5721…`, no se puede
rehacer. Nadie de fuera puede construirla, y el autor tampoco desde cero.

**EL AGUJERO ESTÁ CERRADO DESDE EL 2026-08-13, medido y no estimado
(`MEDICIONES.md` §4.37): los 28 salen del clon, 28 de 28, sin tocar la ISO ni una
vez.** Los 24 de fuera los baja `imagen/cosechar-repo.sh` y los comprueba por
huella al llegar; los tres de Encina los construyen `03-construir.sh`,
`07-firefox-construir.sh` y `10-meta-construir.sh`; y `autofirma` sale de
`encina-autofirma`, que es público.

**Y la pregunta que nadie había hecho, contestada al cerrarlo: las huellas
vigentes hasta ese día no eran de un paquete, sino de UNA CONSTRUCCIÓN.**
`dpkg-deb` recorta los mtimes posteriores a `SOURCE_DATE_EPOCH` y deja pasar los
anteriores, así que la fecha que un fichero tuviera en el disco viajaba dentro
del `.deb` — un dato que no está en git. Las tres se pusieron al día; el
contenido de los paquetes no cambió ni un byte. **Consecuencia que hay que mirar
de frente: `ac0a5721…` ya no se fabrica desde este repositorio**, y la casilla de
`construir-todo.sh` de abajo se reescribe por eso.

Este bloque es el que convierte «constrúyela tú» de promesa en instrucción, y sin
él los bloques 2, 3 y 4 no valen nada: se publicaría algo que nadie puede auditar
rehaciéndolo.

**BLOQUE CERRADO EL 2026-08-13** (`MEDICIONES.md` §4.39). Las seis casillas están
marcadas y la última se cerró midiendo, no decretando: **de un árbol versionado a
la ISO en una sola orden, y cuatro pasadas dieron la misma huella,
`95758c9e954d834f6324b6f5e0464741742478247d29a2637009ad03e2a8aef6`.** El medio ya
no se hereda: se fabrica.

*Y lo que este bloque NO desbloquea, dicho aquí para que nadie lo confunda:*
**ninguna de esas ISOs se ha arrancado.** Lo cerrado es que el medio se
**fabrica** de forma reproducible, no que funcione — eso es el bloque 4, y hasta
entonces `ac0a5721…` sigue siendo el único medio que se probó de verdad.

*Y una premisa de este mismo documento que resultó falsa:* decía que en este Mac
no había ninguna ISO. Había trece, la oficial entre ellas y en dos copias. El
`find` que lo midió llevaba `-maxdepth 6` y la ruta tiene nueve componentes: no
dijo «no hay», dijo «no he mirado».

- [x] ~~**Fijar de dónde sale `autofirma_1.9.1+encina4_all.deb`**~~ **HECHO el
      2026-08-13: `encina-autofirma` es público.** Era el único de los 28 con
      bloqueo duro; ahora es **construible desde fuente pública**, con el parche
      dentro (`debian/patches/0001-perfiles-mozilla-todas-las-rutas.patch`). Y la
      licencia quedó comprobada leyendo el código: la cabecera de AutoFirma
      concede EUPL «1.1 or (at your option) any later version» en 683 de 1 308
      `.java`, así que EUPL-1.2 aquí es coherente y **no hay nada que cambiar**.
      *Lo que NO desbloquea, medido:* el `.deb` **no viaja en el clon** —está en
      `.gitignore`, y bien— así que sigue habiendo que construirlo.
- [x] ~~**La lista de los 24 de fuera sólo vive dentro de la ISO**~~ **CORTADO el
      2026-08-13 con `imagen/repo-manifiesto.tsv`**, que es la raíz de la
      circularidad y no el `.deb`: sin él, `cosechar-repo.sh` necesitaría una ISO
      anterior para saber **qué** cosechar. Ahora la lista —origen, paquete,
      versión, fichero, tamaño y `sha256` de los 28— está versionada aquí, con sus
      controles: las 28 huellas cuadran con los bytes que viajan, las 4 propias
      cuadran con lo que exige `encina-seed.sh`, y una huella saboteada la señala.
- [x] ~~**`imagen/cosechar-repo.sh`, que reconstruye `/encina-repo` desde cero.**~~
      **HECHA el 2026-08-13** (`MEDICIONES.md` §4.36). Partiendo de un directorio
      vacío baja los **24 de origen `ARCHIVO`** y los deja con las huellas del
      manifiesto cuadrando una a una, y el paso 2 de `fabricar-iso.sh` pasa: «los
      cuatro por huella» y «Packages describe 28 ficheros, viajan 28, y las 28
      huellas cuadran». El roto está reproducido —`[FALLO] no esta:
      autofirma_1.9.1+encina4_all.deb`— y el guion lleva **cinco** controles, uno
      de ellos positivo; el de la huella saboteada encontró un defecto del propio
      guion —recortaba las huellas y dos que solo difieren en el último carácter se
      leían iguales— y se arregló. *Y algo que no se dedujo:* **ninguno de los 24
      ha sido retirado hoy**, pero eso es una foto y no una propiedad, así que el
      guion sabe decir `[RETIRADO]` y **no** coge la versión nueva por su cuenta.
      *Lo que NO cierra, y por eso la casilla de abajo sigue viva:*
      `encina-branding` 0.1.8 **no sale del clon**, así que hoy salen **tres de los
      cuatro** `PROPIO` y el cuarto sigue saliendo del medio.
- [x] ~~**Los tres `.deb` de Encina, construibles desde este repositorio.**~~
      **HECHA el 2026-08-13** (`MEDICIONES.md` §4.37). Los tres guiones producen
      los tres `.deb` desde el árbol versionado, en verde y sin aflojar nada —25,
      39 y 14 comprobaciones, 0 fallos, `lintian` sin decir una línea— y con ellos
      la cosecha sobre un directorio **vacío** da **28 de 28 sin tocar la ISO**.
      *Y el «hecha cuando» de esta casilla hubo que reescribirlo, que es el
      hallazgo:* decía «con las huellas vigentes», y **eso no era alcanzable**. Las
      vigentes eran de una construcción hecha en un árbol de trabajo: `dpkg-deb`
      recorta los mtimes posteriores a `SOURCE_DATE_EPOCH` y **deja pasar los
      anteriores**, así que la fecha de `debian/copyright` en el disco viajaba
      dentro del `.deb` —aislado hasta los 7 bytes del campo `mtime` del bloque 11
      del tar— y ese dato no está en git. Demostrado con control positivo
      (restaurando el mtime sale `86da3cc9…` **exacta**) y negativo (264 segundos
      antes, otra huella). **Lo que sí es cierto, y es lo que la casilla dice
      ahora: los tres son reproducibles DESDE EL CLON** —con mtimes distintos a
      propósito sale la misma huella— y el manifiesto se puso al día con ellas por
      decisión de Jorge. El contenido de los tres paquetes **no cambió**: 0
      diferencias huella a huella, mismos modos, dueños, tamaños y rutas; lo único
      que cambian son las fechas, y por eso los tres son más pequeños.
      *Y una corrección:* el `0.1.8` no «sólo salía de la ISO» — no estaba en el
      Mac, pero en `encina-dev` estaba en cuatro sitios, encontrado por huella.
- [x] ~~**El MODO de lo que añade `fabricar-iso.sh`.**~~ **HECHA el 2026-08-13**
      (`MEDICIONES.md` §4.39). Dos construcciones seguidas desde el mismo
      repositorio dan **`95758c9e…`, la misma huella**, y dentro salen **30
      ficheros `-rw-r--r--` y ninguno `0700`** —los 29 de `/encina-repo` más
      `/autoinstall.yaml`—. *Y la mitad que de verdad valía:* dos pasadas desde el
      mismo directorio no atacan la causa de §4.36k, que era el modo **en el
      disco**, así que se construyó también desde una copia con **cuatro ficheros
      fuera de 644** —el caso real de §4.36k— y salió **la misma huella**. Con el
      `chmod` y su guardián neutralizados, **otra** (`3d10678e…`, mismo tamaño), y
      esos 4 sectores son el campo `PX` en sus dos copias y sus dos árboles: es
      §4.36k provocado a voluntad. *Y una cosa que enseña más que el verde:* el
      guion neutralizado imprime `[OK] modo fijado` igual — lo que lo cazaba era
      el guardián, no la línea de `[OK]`.
      *Y la premisa sobre la que se había aplazado era falsa:* **la ISO oficial
      estaba en este Mac en dos copias**, y la vigente también. El `find` de
      §4.37a llevaba `-maxdepth 6` y la ruta tiene nueve componentes.
- [x] ~~**Un `construir-todo.sh` que encadene las cuatro cosas.**~~ **HECHA el
      2026-08-13** (`MEDICIONES.md` §4.39). De un árbol versionado a la ISO en una
      orden: construye los tres `.deb`, cosecha los 24 y `autofirma`, genera el
      `Packages` y fabrica el medio. Cruza dos máquinas porque no hay remedio
      —`dpkg-buildpackage` y `dpkg-scanpackages` no existen en macOS y
      `fabricar-iso.sh` sólo corre aquí—, construye **`git archive HEAD` y no el
      directorio de trabajo** (§4.37d convertido en regla) y **se niega sobre un
      árbol sucio**, probado en rojo.
      *Hecha cuando, y medido:* **cuatro pasadas dieron `95758c9e…`**, la misma que
      la ruta manual — y con un cruce que no se buscaba, porque la manual llevaba
      dentro los tres `.deb` del runner **amd64** de la CI y las otras los
      construidos en `encina-dev`, **arm64**. §4.38b comprobado hasta el bit del
      medio.
      *Lo que NO cierra:* **ninguna de las cinco ISOs se ha arrancado**. Lo medido
      es que el medio se **fabrica** igual, no que funcione, así que `95758c9e…`
      todavía no es «la ISO vigente»: es la que produce este repositorio hoy.

---

## Bloque 1 — MARCA PROPIA: que el medio deje de decir Ubuntu

**Es la prioridad declarada, y no es cosmética: es lo que hace legal publicar.**
Hoy el instalador dice Ubuntu, el fondo del instalador es de Ubuntu, la rejilla
lleva el logo de Ubuntu y el volumen de la ISO se llama `Ubuntu 24.04.4 LTS`. El
sistema **instalado** sí lleva ya la identidad de Encina —de eso se ocupa
`encina-branding` 0.1.8—; lo que falta es **el medio y el instalador**.

**Y hay una decisión de fondo antes de tocar un icono:** repintar una ISO de
Ubuntu reempaquetada es una solución a medias, y el destino declarado del
proyecto es **E5, la imagen propia**. Conviene decidir si este bloque se hace
sobre el reempaquetado o si se hace ya construyendo la imagen.

- [ ] **Inventariar dónde aparece la marca, midiendo y no suponiendo.** El medio
      entero, el instalador vivo y la primera sesión.
      *Hecha cuando:* hay una lista de ficheros y cadenas concretas, cada una con
      dónde se ve.
- [ ] **Leer los términos de Canonical y escribir qué obligan**, en el mismo
      formato que las decisiones D: qué se puede decir («derivado de Ubuntu»), qué
      no se puede usar (nombre y logotipos como identidad del producto) y qué pasa
      con `os-release`.
      *Hecha cuando:* es una decisión escrita en `ENCINA-OS.md`, no una impresión.
- [ ] **El arranque y el instalador, con identidad de Encina.**
      *Hecha cuando:* alguien arranca la ISO y **lo que ve dice Encina**, mirado en
      pantalla.
- [ ] **El logo de la rejilla.** Es lo que Jorge nombró: hoy el botón de
      aplicaciones lleva el logotipo de Ubuntu.
      *Hecha cuando:* lleva la encina, mirado en pantalla, y el resto del escritorio
      no ha cambiado.
- [ ] **El nombre del volumen de la ISO.**
      *Hecha cuando:* `xorriso -indev` da un `Volume id` propio y el medio sigue
      arrancando — que es lo que hay que comprobar, porque el nombre del volumen lo
      usa el instalador para encontrarse a sí mismo.

---

## Bloque 2 — FUENTES: lo que publicar obliga a publicar

**BLOQUE CERRADO EL 2026-08-13.** Las cuatro casillas están marcadas, y ninguna
se cerró por decreto: dos ya estaban hechas y decían lo contrario —los forks
nacieron públicos y `encina-autofirma` ya se había publicado esa misma mañana—,
y las otras dos se escribieron. Lo que este bloque temía —publicar la ISO
incumpliendo la oferta de fuente— **ya no puede pasar**: la oferta está en el
README, con los cuatro repositorios y sus tags, y la CI de `encina-autofirma`
mide que reconstruye de verdad.

*Lo que este bloque NO desbloquea, dicho aquí para que nadie lo confunda:* que
la fuente esté publicada no fabrica la ISO. El `.deb` sigue sin viajar en el
clon y `cosechar-repo.sh` sigue sin existir — eso es el bloque 0.

- [x] ~~**Reescribir D5.**~~ **HECHA el 2026-08-13.** La celda de `ENCINA-OS.md`
      dice ahora lo que se decidió: **el repositorio es público y la imagen se
      publica en cuanto esté lista, declarando que es solo arm64**. Se reescribe
      —no se parchea— porque su motivo entero era el precio de publicar, y ese
      precio **está pagado**: los cuatro repositorios de la oferta de fuente son
      públicos y la oferta está escrita. «Solo arm64» pasa de ser un motivo para
      no publicar a ser **una línea de la release**, que es donde D9 quiere que
      viva un límite declarado. *Lo que sigue costando y queda escrito sin
      maquillar:* cortar imagen nueva ante un fallo de seguridad de AutoFirma
      sigue siendo obligación, y se retira el día de D14, no hoy.
- [x] ~~**Hacer públicos los tres forks**~~ (`clienteafirma`, `jmulticard`,
      `clienteafirma-external`). **Ya lo son**, comprobado el 2026-08-13: son forks
      de `ctt-gob-es`, así que nacieron públicos. Esta tarea no existía.
- [x] ~~**Hacer público `encina-autofirma`.**~~ **HECHO el 2026-08-13**, y
      comprobado midiendo y no recordando: `gh repo list` da `PUBLIC` para
      `encina-autofirma` y para los tres forks. La condición que llevaba escrita
      —*que su README diga por qué existe y cuándo se retira*— **se cumplió antes
      de darle al botón, no después**: aquel README abre con «Esto NO es
      AutoFirma» y lleva una sección «Cuándo se retira este repositorio» con la
      condición de D14 en forma de orden (`verificar-deb.sh` sobre el `.deb`
      oficial). Y su *hecha cuando* está entera: el `.deb` **se puede reconstruir
      desde fuentes públicas** —la CI clona los tres forks anclados en `v1.9.1`,
      `v2.1` y `v1.0.7`, construye y verifica; verde sobre `main`, ejecución
      `31715687820` del 2026-08-13T15:29Z— y **el README de Encina OS enlaza a
      ellas**.
- [x] ~~**Escribir la oferta de fuente en el README**, con el enlace, junto a la
      licencia.~~ **HECHA el 2026-08-13.** La sección «Licencia y fuentes» lleva
      una tabla con los seis sitios de donde sale lo que viaja —empaquetado y
      parche, los tres forks con su tag, los tres paquetes de Encina, y el resto
      sin modificar, con `imagen/repo-manifiesto.tsv` como lista de los 28—. No es
      una dirección de correo a la que pedirla: son enlaces. Y va con la
      advertencia que evita el malentendido caro: **ese AutoFirma parcheado no es
      una versión mejor que el oficial**, es una muleta con condición de retirada.

---

## Bloque 3 — ALOJAMIENTO: 3,46 GB no caben en un release de GitHub

- [ ] **Elegir dónde vive la ISO.** GitHub no acepta adjuntos de release de más de
      2 GiB, y la nuestra son 3,46 GB. Las salidas son partirla en trozos con su
      guion de recomposición, o alojarla fuera.
      *Hecha cuando:* hay una URL que descarga, y su `sha256` **publicado al lado**.
- [ ] **Publicar las huellas y cómo comprobarlas.** Una ISO sin huella al lado no
      se la puedes dar a nadie.

---

## Bloque 4 — PUBLICAR

- [ ] **La release, con lo que trae y lo que no.** Arquitectura, que exige red al
      instalar, y que Secure Boot no está demostrado.
- [ ] **Instalarla desde cero como lo haría un desconocido**, en una máquina que
      no sea del banco, y **mirando la pantalla**.
      *Hecha cuando:* arranca, se instala contestando lo que pregunta, y
      `verificar-instalacion.sh` como root da 0 fallos.
- [ ] **Poner el enlace en el README** y quitar de él la frase «todavía no hay una
      imagen que descargar».

---

## Después de publicar

- [ ] **E5 — la imagen propia** (`live-build`/`debos`). El destino declarado. Solo
      compra dos cosas, y son las que este proyecto quiere: marcar el propio
      instalador y controlar el conjunto base. Si el bloque 1 se hace aquí, se hace
      una vez en vez de dos.
- [ ] **El núcleo en el medio.** Hoy la instalación **exige red**, y es un límite
      declarado con la forma de D9: está leído hasta el final. Cuesta **1 089 MB**
      —`linux-firmware` son 655— y saca la ISO del DVD de una capa y del límite de
      FAT32. La vía está nombrada y **no medida**: re-firmar el `dists/` del medio
      con clave propia. **Es una decisión de producto, no una deuda.**
- [ ] **amd64 (E6).** No es prioridad. Necesita con qué probarlo, y repetir allí el
      positivo de extremo a extremo.

---

## Sueltas, de un rato cada una

- [ ] **Medir qué puede romper un autorrefresco de `snapd`.** El 2026-08-13 se
      autorrefrescó solo y llevó el Snap de Firefox de rev 7764 a 8753 sin que nadie
      lo pidiera. No rompió nada y está medido, **pero nadie lo controla**: la
      máquina del producto se actualiza sola cuando le parece.
- [ ] **Un agente no sabe pulsar un botón del invitado.** Cinco vías descartadas y
      medidas (`MEDICIONES.md` §4.35i). Mientras no haya una sexta, toda casilla
      `[OJOS]` que exija pulsar necesita una mano — y eso hay que tenerlo en cuenta
      **al escribir la casilla**, no al llegar a ella.
- [ ] **DNIe con lector** (`opensc`, PKCS#11). Incremento futuro, no deuda.
- [ ] **Chrome y Chromium.** No se han medido; hoy el perímetro dice Firefox.
