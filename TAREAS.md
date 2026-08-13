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

Este bloque es el que convierte «constrúyela tú» de promesa en instrucción, y sin
él los bloques 2, 3 y 4 no valen nada: se publicaría algo que nadie puede auditar
rehaciéndolo.

- [ ] **`imagen/cosechar-repo.sh`, que reconstruye `/encina-repo` desde cero.**
      No hay que inventar la lista: el `Packages` que ya tenemos lleva **nombre,
      versión, tamaño y `SHA256` de los 28**, así que el guion se escribe desde el
      índice. Baja los 24 de fuera del archivo de Ubuntu y de Mozilla, y falla si
      una huella no cuadra.
      *Hecha cuando:* partiendo de un directorio vacío produce 28 `.deb` cuyas
      huellas **coinciden una a una** con las del `Packages` vigente, y con el
      control de que una huella saboteada la hace fallar.
- [ ] **Fijar de dónde sale `autofirma_1.9.1+encina4_all.deb`.** Hoy sale de
      `encina-autofirma`, que es privado, así que es el eslabón que rompe la
      cadena para cualquiera que no seas tú. Decide una de las dos: publicar ese
      repositorio (va también en el bloque 2, que lo exige por otro motivo) o
      publicar el `.deb` construido con su huella y su receta.
      *Hecha cuando:* `fabricar-iso.sh` pasa el paso 2 en una máquina que **solo**
      ha clonado `encina-os`.
- [ ] **Los tres `.deb` de Encina, construibles desde este repositorio.** Están en
      `debian-packages/` como fuente y `.gitignore` excluye los binarios, que es lo
      correcto; falta comprobar que la receta funciona partiendo de cero.
      *Hecha cuando:* `03-construir.sh`, `07-firefox-construir.sh` y
      `10-meta-construir.sh` producen los tres con las huellas vigentes.
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

**D5 lo dice ya, y hay que releerla antes de tocar nada:** publicar la imagen
activa la obligación de **ofrecer la fuente correspondiente** del AutoFirma
parcheado, y eso obliga a hacer públicos `encina-autofirma` y los tres forks.
Hoy los cuatro son privados. Publicar la ISO sin eso sería incumplir.

- [ ] **Reescribir D5.** Su celda dice que la imagen no se publica hasta que haya
      una arquitectura que otros puedan arrancar. La decisión nueva es publicar
      arm64 **declarando** que es solo arm64. La propia D5 lo anticipa: «si se
      decide publicar la imagen desde la primera versión arm64, es esta celda la
      que cambia».
- [x] ~~**Hacer públicos los tres forks**~~ (`clienteafirma`, `jmulticard`,
      `clienteafirma-external`). **Ya lo son**, comprobado el 2026-08-13: son forks
      de `ctt-gob-es`, así que nacieron públicos. Esta tarea no existía.
- [ ] **Hacer público `encina-autofirma`.** Es el único privado, y es **donde vive
      el parche**, así que sin él la oferta de fuente está a medias — y, más
      urgente que eso, **el bloque 0 no se puede cerrar**: mientras sea privado,
      `fabricar-iso.sh` no pasa el paso 2 en una máquina que solo haya clonado
      `encina-os`. Revisado el 2026-08-13 y **está limpio para salir**: sin
      material de clave —los `.p12` viven en `build/`, ignorado, y son las pruebas
      del propio upstream—, historial sin secretos y sin datos personales.
      *Antes de darle al botón, una cosa:* que su README diga **por qué existe y
      cuándo se retira** (D14: se retira cuando `verificar-deb.sh` pase sobre el
      `.deb` oficial). Sin ese párrafo, un AutoFirma parcheado y público invita a
      que alguien lo use creyendo que es una versión mejor, y no lo es.
      *Hecha cuando:* el `.deb` que viaja se puede reconstruir desde fuentes
      públicas, y el README de Encina OS enlaza a ellas.
- [ ] **Escribir la oferta de fuente en el README**, con el enlace, junto a la
      licencia.

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
