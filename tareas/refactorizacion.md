# La refactorización, con lo que ya sabemos

**Qué es este bloque.** **Doce tareas** que no cambian el producto: ni un byte de
la ISO, ni un `.deb`, ni una decisión. Cambian **cómo está guardado** lo que ya
funciona, para que siga siendo legible dentro de seis meses y para que el
vocabulario del proyecto sea uno y no dos.

*Y una corrección de conteo del 2026-08-23, que es de las baratas y por eso se
hace:* aquí decía **«Diez tareas»** y en la tabla de `TAREAS.md` ponía **10**.
**Eran once** desde que se escribió el fichero —once secciones numeradas y once
casillas, contadas con `grep`—, así que el encabezado llevaba mal el número
desde el primer día. Con la tarea 12 son **doce**.

**Por qué existe.** El repositorio se leyó entero el 2026-08-22 sobre `main` en
`99e0e39`, con el árbol limpio, contando y sin ejecutar nada. Lo que salió está
abajo, y las cifras que se citan son de esa lectura.

**Cuándo. ENMENDADO EL 2026-08-23, Y LO DECIDE JORGE: ESTE BLOQUE VA ANTES DE
PUBLICAR, ENTERO Y SEGUIDO.** Es la **fase 2** de las tres de `TAREAS.md`: detrás
de que las ISOs se hayan probado —el hierro `amd64` y la vuelta `arm64`— y
**delante** de publicar, que pasa a ser lo último del proyecto.

*Lo que decía, dejado al lado, porque no era falso:*

> ~~**Cuándo.** Después de publicar, y por el mismo argumento de no pagar dos veces
> que ya ordena el resto de `TAREAS.md`: la definición de terminado de
> `construir-todo.sh` es que **dos pasadas den la misma huella**, así que tocar
> `imagen/fabricar-iso.sh` invalida la huella que la release lleva dentro.
> **Excepción escrita:** las tareas 4, 5, 7 y 8 no tocan ningún guion que fabrique
> el medio, y la 6 es aditiva. Ésas no dependen de publicar.~~

Sigue siendo verdad que tocar `fabricar-iso.sh` invalida la huella. Lo que cambia
es **qué se protege**: antes, la refactorización de tener que refabricar; ahora,
**la release de nacer con una huella que su propio repositorio ya no reproduce**,
que es la que un tercero puede comprobar y la única que no se corrige sin retirar
la descarga. El argumento entero está en `TAREAS.md`, «El orden cambia el
2026-08-23».

**Y la excepción de las tareas 4, 5, 6, 7 y 8 sobra:** existía para poder
adelantarlas a publicar. Ahora **ninguna depende de publicar**, así que no hay
nada que adelantar y el bloque se hace entero. Lo que **sí** se conserva es el
orden interno: la **1** y la **12** van primero —el instrumento y el criterio—, y
la **11** va la última, con el producto congelado.

**Cómo se cierra el bloque entero.** Cuando `bancos/enlaces.sh` —la tarea 1— pase
en verde sobre el árbol ya movido, **y el documento de la tarea 12 no tenga
ninguna fila sin veredicto**. Sin ese instrumento y sin ese criterio,
«refactorización terminada» sería una sensación y no una salida — y con el
encargo nuevo, «proyecto profesional» lo sería aún más.

---

## 1. El instrumento primero: `bancos/enlaces.sh`

- [ ] **Un guion que compruebe que ninguna referencia apunta a la nada.** Recorre
      los `.md` y los `.sh` y saca `[FALLO]` por cada referencia `§N.NN` que no
      exista, cada nombre de guion citado que no esté en el disco y cada ruta
      relativa rota.
      *Por qué:* hay **1.857 referencias `§N.NN`** repartidas por el repositorio
      —694 en `MEDICIONES.md`, 220 en `ENCINA-OS.md`, 201 en `AGENTS.md`, 53
      dentro del propio `fabricar-iso.sh`—. Las tareas 4 y 9 mueven ficheros, y
      una referencia muerta no se manifiesta hasta que alguien la sigue, meses
      después. Va **antes** que todo lo demás porque es el instrumento con el que
      se mide el resto, igual que `veredicto-pantalla.py` fue antes que contar
      arranques.
      *Hecha cuando:* corre sobre el árbol de hoy y dice cuántas referencias hay
      y cuántas resuelven, **con su control**: una referencia inventada a
      propósito —`§4.999`— y un guion citado que no existe tienen que ponerlo en
      rojo, y por ese motivo y no por un error de sintaxis. Si sobre el árbol de
      hoy ya hay referencias rotas, se listan y se arreglan aquí: es un hallazgo,
      no un fallo del guion.

## 2. `fallo()` significa dos cosas opuestas

- [ ] **Partir `fallo()` en dos nombres, y declarar el `set` en cada guion.** En
      `scripts/lib.sh` y en tres guiones de `imagen/` —`capa-marca.sh`,
      `inventario-marca.sh`, `verificar-instalacion.sh`— `fallo()` incrementa un
      contador y **sigue**. En otros seis —`fabricar-iso.sh`,
      `construir-todo.sh`, `traer-iso-oficial.sh`, `cosechar-repo.sh`,
      `fabricar-seed.sh`, `comprobar-propios.sh`— es
      `{ echo "[FALLO] $*"; exit 1; }`: **aborta**.
      *Por qué:* la misma palabra para «apunta y sigue midiendo» y para «no se
      puede continuar». Quien mueva un bloque de un guion a otro cambia el flujo
      de control sin verlo, y no lo caza nada. Y contradice a `CLAUDE.md`, que
      declara «un solo `[FALLO]` y el guion sale con código distinto de cero» —
      cierto sólo en el modelo de contar y resumir. Lo mismo con el `set`:
      ninguno de los trece guiones numerados lo escribe, lo heredan de la línea 5
      de `lib.sh` al hacer `source`, así que las opciones de shell de un guion
      dependen de a quién llame. Y tres —`capturar-vm.sh`, `teclear-vm.sh`,
      `fabricar-seed.sh`— llevan sólo `set -u`, sin `pipefail`.
      *Hecha cuando:* `fallo()` apunta y sigue en todos los guiones y `abortar()`
      sale en todos, `grep -rn 'fallo()' ` enseña una sola forma, cada guion
      declara su `set` en la cabecera con una línea que diga cuál de los dos
      modelos usa, y **los cuatro bancos siguen dando lo mismo que hoy**.

## 3. `lib/salida.sh`, y que `imagen/` lo use

- [ ] **Partir `scripts/lib.sh` en dos capas y llevar la portátil a `imagen/`.**
      `lib/salida.sh` con el vocabulario, los contadores y `resumen()`, sin nada
      de VM; `lib/vm.sh` con lo que hoy sólo sirve en Ubuntu
      —`xdg_data_dirs_sesion`, `resolver_desktop`, `PKG_DIR`—.
      *Por qué:* nueve guiones de `imagen/` reimplementan `ok`, `fallo`, `aviso`,
      `omitido` y sus contadores, cada uno con su propio relleno de espacios, así
      que **la salida del proyecto no está alineada consigo misma**. El
      vocabulario y los contadores no dependen del sistema operativo; lo que sí
      depende es el resto de `lib.sh`, y ésa es la frontera real.
      *Hecha cuando:* ningún fichero fuera de `lib/` define `ok`, `fallo`,
      `aviso` ni `omitido`, y la salida de `verificar-instalacion.sh` y de
      `05-verificar.sh` está alineada en la misma columna. **Control:** los
      cuatro bancos y `comprobar-propios.sh` dan el mismo número de correctas y
      fallos que antes del cambio, apuntado antes de tocar nada.

## 4. Partir `MEDICIONES.md` conservando los `§`

- [ ] **Un fichero por sección, y el número es el nombre del fichero.**
      `mediciones/4.37-huella-del-arbol-sucio.md`, `mediciones/9-trampas.md`,
      y `mediciones/LEEME.md` con la tabla de vigencia y el índice.
      *Por qué:* `CLAUDE.md` ordena consultar `MEDICIONES.md` **antes de
      investigar cualquier cosa**, y el fichero son **765 KB y 14.637 líneas**,
      con una sola sección —la §4— que ocupa **11.200 líneas y 60 subsecciones**.
      La regla es correcta y hoy es físicamente incumplible, así que el resultado
      práctico es que se investiga sin consultarlo, que es justo lo que la regla
      existe para evitar. No se reescribe ni una línea del contenido: se mueve
      **verbatim**, como se hizo con `TAREAS.md` el 2026-08-14.
      *Hecha cuando:* `bancos/enlaces.sh` en verde después del movimiento,
      `grep -rn '§4.37'` sigue encontrando lo mismo que antes, y un `diff` del
      contenido concatenado contra el fichero original **no señala más que los
      títulos que cambian de nivel**. Ése es el control: si el diff enseña texto,
      se ha perdido algo.

## 5. La tabla de vigencia, entera y comprobada

- [ ] **Que ninguna sección se quede sin fila, y que lo diga un guion.** La tabla
      cubre **33 de las 60** subsecciones §4.x.
      *Por qué:* es lo mejor que tiene el repositorio —resuelve el problema que
      hunde a todos los registros de laboratorio, que es no saber qué de lo
      escrito hace un mes sigue en pie— y está a mitad. Desde fuera no se
      distingue «vigente» de «nadie lo ha revisado», que son cosas muy
      distintas.
      *Hecha cuando:* `bancos/vigencia.sh` compara las secciones que existen
      contra las filas de la tabla y da 0 fallos. Con el fichero ya partido es un
      `ls` contra un `grep`. **Control:** se borra una fila a propósito y tiene
      que señalarla; se inventa una fila de una sección que no existe y también.

## 6. `Makefile`, bancos en la CI y `shellcheck`

- [ ] **Una orden para construir y una para probar, y que la CI las use.** Hoy
      hay **cuatro bancos con cuatro puntos de entrada** —`banco-cadena.sh`,
      `banco-mecanismos.sh`, `banco-veredicto.sh`, `veredicto-conteo.py
      --banco`— y **ninguna orden que los corra todos**; la CI no ejecuta
      ninguno.
      *Por qué:* tres de los cuatro no necesitan VM ni ISO y tardan segundos, así
      que ahora mismo sólo corren si alguien se acuerda. Y la definición de
      terminado real de `construir-todo.sh` —dos pasadas, misma huella— es una
      frase en `CLAUDE.md`: una definición de terminado que no es ejecutable
      acaba siendo opcional. Objetivo: `make bancos`, `make paquetes`, `make
      iso`, `make dos-veces`.
      *Hecha cuando:* `make bancos` corre los cuatro y sale distinto de cero si
      falla uno; la CI tiene un job `bancos` con los tres que no necesitan
      máquina más `shellcheck` sobre los 33 guiones; y **el sabotaje de siempre**:
      se rompe un banco a propósito y la CI se pone roja por ese motivo.

## 7. Vaciar `ENCINA-OS.md` §7

- [ ] **Que «Empieza aquí» vuelva a caber en una pantalla.** Hoy son **1.189
      líneas**. Se queda con la tarea en curso y nada más; el resto baja a
      `tareas/cerradas/` con su fecha.
      *Por qué:* `CLAUDE.md` manda leer §7 «siempre primero, la tarea en curso y
      sólo esa». Con 1.189 líneas ya no es por dónde empezar: es el archivo de por
      dónde se empezó. Y `tareas/cerradas/` es el sitio que ya existe y ya se usa
      para esto.
      *Hecha cuando:* §7 baja de 60 líneas, lo que salió está en
      `tareas/cerradas/` con su fecha, y `bancos/enlaces.sh` sigue en verde —hay
      **220 referencias `§`** en este documento y algunas apuntan dentro de §7—.

## 8. Los tres bloques de `diario.sh`

- [ ] **Que cada entrada del diario salga partida en tres.** Qué se midió · qué
      salió mal · qué toca mañana.
      *Por qué:* `DIARIO.md` tiene entradas de hasta **6.518 caracteres en una
      sola línea**. El contenido es bueno y ya trae esas tres cosas mezcladas; lo
      que no se puede es localizar nada dentro de una entrada ni ver en un `diff`
      qué parte cambió. Sale gratis porque `diario.sh` ya escribe el fichero.
      *Hecha cuando:* la primera entrada nueva sale con los tres bloques y
      `awk '{print length}' DIARIO.md | sort -rn | head -1` baja de 1.500 para
      las entradas nuevas. **No se reescriben las viejas.**

## 9. Un registro único de trampas

- [ ] **`TRAMPAS.md`: una fila por trampa, con la columna que hoy no existe.**
      Número —global, conservado—, síntoma, causa, **a qué guion o fase aplica**,
      y dónde está medida.
      *Por qué:* las trampas viven en dos sitios con numeración compartida
      —`MEDICIONES.md` §9 tiene una tabla, `SCRIPTS.md` tiene veintidós y pico
      repartidas en secciones tituladas «Y una octava…», «Y una vigesimoprimera…»—
      y la propia tabla de §9 cita «trampa 13 de `SCRIPTS.md`». Para saber si una
      trampa aplica a lo que estás tocando hay que conocer las dos listas de
      memoria. **Es un índice, no una reescritura:** el texto largo se queda donde
      está y la fila apunta. `SCRIPTS.md` no se toca y recupera su papel de
      referencia de guiones.
      *Hecha cuando:* toda trampa numerada tiene exactamente una fila, la
      numeración global no cambia, y `bancos/enlaces.sh` resuelve todos los
      enlaces de la tabla al texto largo.

## 10. Renombrar los guiones por paquete y fase

- [ ] **Que el nombre diga qué paquete y qué fase, y que el orden lo diga
      `SCRIPTS.md`.** Los trece números `00–12` son en realidad tres tríadas
      —construir · instalar · verificar, por paquete— intercaladas con cuatro
      utilidades.
      *Por qué:* un cuarto paquete no tiene hueco, y el número no dice a qué
      paquete pertenece cada guion: hay que abrirlo. Hay precedente de que aquí
      renombrar sale barato — `SCRIPTS.md` documenta el renombrado del 2026-08-13
      con su tabla de equivalencias, y así se hace éste también.
      *Hecha cuando:* los nombres nuevos están, `SCRIPTS.md` lleva su tabla de
      equivalencias como la otra vez, la CI apunta a los nuevos, y
      `bancos/enlaces.sh` en verde. **Va la penúltima** porque es la que más
      citas rompe en los documentos.

## 11. `fabricar-iso.sh`, una función por fase

- [ ] **Que las 13 fases sean ejecutables y no comentarios.** Cada
      `# --- N. ---` pasa a `fase_N_nombre()`, y al final un bloque que las llama
      en orden. **Un fichero, misma lectura lineal.**
      *Por qué:* son **1.201 líneas** y la descomposición **ya está pensada** —las
      fases están marcadas del 0 al 13—; lo que falta es que sea ejecutable. Sin
      eso no se puede probar una fase sola y las banderas de bisecado
      —`--sin-capa`, `--sin-volid`, `--sin-info`, `--sin-menu`— tienen que
      dispersarse por el cuerpo.
      *Hecha cuando:* **la ISO que sale tiene la misma huella que antes del
      cambio**, apuntada antes de tocar nada, y las dos pasadas siguen dando la
      misma. Ése es el único control que vale aquí.
      **VA LA ÚLTIMA, y con el producto congelado:** es el guion que fabrica lo
      que se entrega.

## 12. Qué es «un proyecto de distribución bien organizado», escrito ANTES de mover nada

- [ ] **Un documento que compare este repositorio con cómo están organizados los
      proyectos que hacen lo mismo, y que diga de cada diferencia si se adopta o
      no, y por qué.** No es «aplicar buenas prácticas»: es **decidir cuáles**,
      con nombre y con motivo, dejando por escrito también **las que se rechazan**.
      *Por qué:* lo pide Jorge el 2026-08-23 con estas palabras —*«limpiar el
      repo, refactorizarlo, seguir las mejores prácticas y organización para
      creación de distros y en definitiva tener un proyecto profesional»*— y
      **«profesional» no es una salida, es una sensación**, que es justo lo que
      este repositorio no admite en una casilla (`CLAUDE.md`, «Método»). Sin un
      criterio escrito **antes**, una refactorización degenera en mover ficheros
      hasta que dé gusto mirarlos, y eso es exactamente lo que arrasa con lo que
      la sección «Lo que este bloque NO toca» protege. Y hay un punto ciego que
      conviene nombrar: **las once tareas de arriba salen de leer ESTE
      repositorio**; ninguna sale de mirar hacia fuera.
      *Qué mirar, y es el mínimo:* cómo reparten árbol y responsabilidades los
      proyectos que reempaquetan o derivan Ubuntu/Debian —**Linux Mint**,
      **elementary OS**, **Pop!\_OS**, **Ubuntu Cinnamon**— y las herramientas de
      referencia —**`livecd-rootfs`** de Canonical, **`live-build`** y
      **`debos`**—: dónde vive la receta del medio, dónde los paquetes propios y
      su `debian/`, cómo versionan, qué automatiza su CI y qué publican como
      oferta de fuente.
      **Y la pregunta de fondo, que es una sola y hay que contestarla en el
      documento:** hoy `imagen/` **reempaqueta** la ISO oficial (**D3**) y esos
      proyectos en su mayoría **construyen** la suya (**E5**). Si la organización
      que se copia presupone `live-build`, se estaría tomando la decisión de E5
      **por la puerta de atrás** — y esa decisión es de `ENCINA-OS.md`, no de una
      refactorización. La tarea es señalar dónde pasa eso, no resolverlo aquí.
      *Hecha cuando:* existe el documento con **una fila por diferencia** —qué
      hacen ellos · qué hacemos · se adopta o se rechaza · por qué—, **ninguna
      fila queda sin veredicto**, y cada fila adoptada está convertida en una
      casilla de este mismo fichero con su «hecha cuando».
      *Su control, y sin él no vale:* al menos **una fila rechazada con motivo**.
      Si todo lo de fuera se adopta, no se comparó — se copió, y el documento no
      estaba midiendo nada.
      **VA LA PRIMERA, junto con la tarea 1**, y por el mismo motivo: la 1 es el
      instrumento con el que se mide y ésta es el criterio que dice hacia dónde.
      Las tareas 2–11 **se releen a la luz de lo que salga aquí**, y alguna puede
      caerse o cambiar de forma.

---

## Lo que este bloque NO toca

Se escribe aquí porque una refactorización arrasa por descuido con lo que
funciona, y estas cinco cosas están por encima de la media y hay que protegerlas
a propósito:

- **El control antes de la medición, y el sabotaje que tiene que sabotear.** La
  forma que tiene `.github/workflows/build.yml` es la que se copia para cualquier
  banco nuevo, no una que se herede sin pensar.
- **Un guion de construcción por paquete, a propósito.** Cada uno está validado
  contra el suyo. **Compartir el vocabulario no es generalizar la lógica**, y
  ninguna tarea de arriba pide fundir los tres.
- **Las enmiendas fechadas en vez de reescrituras limpias.** Es lo que hace
  auditable el repositorio. Mover un texto verbatim sí; «ordenarlo», no.
- **Los comentarios largos dentro de los guiones.** `fabricar-iso.sh` y
  `autoinstall.yaml` son en buena parte prosa: son el registro del *porqué*,
  pegado al código que explica. Borrarlos en nombre de la limpieza sería la peor
  pérdida posible de toda esta lista.
- **El vocabulario `[OK] [FALLO] [AVISO] [OMIT] [OJOS]`.** El problema no es el
  vocabulario: es que sólo la mitad del repositorio lo obtiene de un sitio común,
  y eso es exactamente lo que arregla la tarea 3.

## Lo que la lectura del 2026-08-22 NO comprobó

`[OMIT]`, y no se da por bueno: no se ejecutó ningún guion ni ningún banco —todo
salió de leer el árbol y contar—; no se entró en `~/Projects/encina-autofirma`;
no se leyeron una por una las 60 subsecciones de `MEDICIONES.md` §4, sólo su
estructura y la tabla de vigencia, así que **puede haber solapamientos entre
secciones que esta lista no recoge**; y **no se comprobó si alguna de las 1.857
referencias `§` ya está rota hoy**, que es justo lo que contestará la tarea 1 el
día que exista.
