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

**Dónde está el agujero al final del 2026-08-13, medido y no estimado
(`MEDICIONES.md` §4.36):** de los 28, **27 ya no dependen del medio** — los 24 de
fuera los baja `imagen/cosechar-repo.sh` y los comprueba por huella al llegar, y
tres de los cuatro propios salen del clon. **Queda uno**, `encina-branding`
0.1.8, y con él las dos casillas de abajo que aún no están marcadas.

Este bloque es el que convierte «constrúyela tú» de promesa en instrucción, y sin
él los bloques 2, 3 y 4 no valen nada: se publicaría algo que nadie puede auditar
rehaciéndolo.

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
- [ ] **Los tres `.deb` de Encina, construibles desde este repositorio.** Están en
      `debian-packages/` como fuente y `.gitignore` excluye los binarios, que es lo
      correcto; falta comprobar que la receta funciona partiendo de cero.
      **Y desde el 2026-08-13 esta casilla es el ÚLTIMO hilo de la circularidad**,
      no una comprobación de higiene: `encina-branding_0.1.8_all.deb` (`51b6603c…`)
      **no existe en el disco del autor** —en `debian-packages/` sólo hay un
      `0.1.7`, `0e870833…`— y hoy únicamente se obtiene extrayéndolo de la ISO.
      *Hecha cuando:* `03-construir.sh`, `07-firefox-construir.sh` y
      `10-meta-construir.sh` producen los tres con las huellas vigentes.
- [ ] **Decidir si `fabricar-iso.sh` fija el MODO de lo que añade**, como ya fija
      la fecha y por el mismo motivo (§4.36k). **Es una decisión de producto, y por
      eso se dejó sin tocar.** Medido: la ISO fabricada desde el repositorio
      cosechado se diferencia de la vigente en **2 sectores de 1 814 144**, y esos
      4 bytes son un solo campo `PX` de Rock Ridge — el modo de
      `encina-firefox-native_0.2.1_all.deb`, `0700` en el medio vigente y `0644`
      hoy. El contenido de las dos es idéntico, comprobado huella a huella sobre
      los 29 ficheros de cada una. **Y la consecuencia hay que mirarla de frente:**
      `ac0a5721…` no se reproduce bit a bit desde **ningún** directorio, ni
      siquiera desde el suyo, porque el modo del fichero de origen ya ha cambiado.
      *Hecha cuando:* está escrito qué modo llevan los ficheros añadidos y por qué,
      y dos construcciones desde el mismo repositorio dan la misma huella.
- [ ] **Un `construir-todo.sh` que encadene las cuatro cosas.** Cosecha, construye
      los tres, trae `autofirma`, fabrica la ISO.
      *Hecha cuando:* de `git clone` a ISO en una sola orden, y la ISO resultante
      tiene la **misma huella** que la vigente — o si no la tiene, se dice **qué
      byte** cambia y por qué.

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
