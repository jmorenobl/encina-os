# Bloque 0 — REPRODUCIBILIDAD: el medio se fabrica, no se hereda

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

**CORREGIDO EL 2026-08-13/14 (`MEDICIONES.md` §4.40): `95758c9e…` YA SE HA
ARRANCADO E INSTALADO.** VM creada desde cero, sin ningún `CIDATA` —`0`
`-append`, **una** unidad de disco y **una** de CD, transcrito antes de que
arrancara nada—, las cinco pantallas contestadas por Jorge, el seed salido de
`/cdrom/autoinstall.yaml` (`CIDATA -> <no encontrado>`) y el repositorio del
medio (`REPO ELEGIDO -> /cdrom/encina-repo`). **Y con ella se cierra lo que
§4.37k y §4.38g dejaron abierto: los tres `.deb` reconstruidos desde el clon
están instalados**, atados por sus tres huellas —`9ec0a49d…`, `640f508e…`,
`204081f0…`— y por un `dpkg -V` sin una sola diferencia, con el control de que
`dpkg -V` sí señala algo en esa máquina.

~~***PERO EL ASTERISCO SE QUEDA…***~~ **EL ASTERISCO SE CAYÓ EL 2026-08-14**
(`MEDICIONES.md` §4.41). El `[FALLO]` era del verificador y no del producto:
exigía la etapa `loading` porque el 2026-08-12 se escribió que «toda instalación
la escribe» —una generalización sobre **una** medición—, y **en esta ISO no se
registra nunca**, medido en dos arranques con la palabra ausente del registro del
cliente. Corregido **con la causa delante**: exige las **ocho** que dicen quién
contestó qué y `loading` pasa a `[DATO]`.

```
verificar-instalacion.sh --forma e3 --visibles 27, como root:
  52 correctas · 0 fallos · 0 avisos · 0 omitidas          rc=0
  Y CON SU ROJO: metiendo "999":"source" en el telemetry -> 2 fallos, rc=1
  restaurado con huella IDENTICA (9b4e0030…), y verde otra vez
```

**Y el medio se ganó su nombre:** `medios/encina-os-E4-es-0.2.1-95758c9e.iso`.
Lleva la huella además de la versión porque **la versión sola no lo distingue**
de `ac0a5721…` —mismo E4, mismo `es`, misma 0.2.1 y el mismo tamaño exacto—, que
es el defecto que §4.35m dejó nombrado.

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
      *Lo que NO cerraba:* ~~**ninguna de las cinco ISOs se ha arrancado**~~
      **CONTESTADO el 2026-08-13/14 (§4.40): `95758c9e…` arranca, instala y
      produce la máquina del producto**, con los tres `.deb` nuevos instalados y
      atados por huella. Queda **un** `[FALLO]` del verificador —la etapa
      `loading`, ver arriba—, así que `95758c9e…` todavía no se declara «la ISO
      vigente»: es la que produce este repositorio hoy **y que ya se ha
      arrancado una vez**.
