# La refactorización, con lo que ya sabemos

**CERRADO EL 2026-08-28: las dieciséis casillas marcadas, cada una con su apartado en `MEDICIONES.md` §4.80, y `bancos/enlaces.sh` en verde sobre el árbol entero movido, que era la condición. Movido a `tareas/cerradas/` ese mismo día, con [organizacion-comparada.md](organizacion-comparada.md).**

**Qué es este bloque.** **Doce tareas** que no cambian el producto: ni un byte de
la ISO, ni un `.deb`, ni una decisión. Cambian **cómo está guardado** lo que ya
funciona, para que siga siendo legible dentro de seis meses y para que el
vocabulario del proyecto sea uno y no dos.

*Y una corrección de conteo del 2026-08-23, que es de las baratas y por eso se
hace:* aquí decía **«Diez tareas»** y en la tabla de `TAREAS.md` ponía **10**.
**Eran once** desde que se escribió el fichero —once secciones numeradas y once
casillas, contadas con `grep`—, así que el encabezado llevaba mal el número
desde el primer día. Con la tarea 12 son ~~**doce**~~ **DIECISÉIS desde esa
misma tarde, y el motivo es que la tarea 12 se ejecutó.**

**ENMIENDA DEL 2026-08-23 (tarde): EJECUTADA LA TAREA 12, EL BLOQUE PASA DE DOCE
A DIECISÉIS.** El documento está en
[organizacion-comparada.md](organizacion-comparada.md): **dieciocho** filas,
ninguna sin veredicto, **ocho rechazadas enteras** —con lo que su control pasa:
no se copió—.
Nacen las tareas **13, 14, 15 y 16**, y la **6 cambia de forma**. **No se cae
ninguna de las once**: se releyeron contra el código ejecutando, y las once se
confirman con nueve correcciones de cifra o de forma, recogidas en §5 de aquel
documento. **Y las cifras de este fichero quedan enmendadas donde estaban
rancias**, cada una en su sitio y con lo que decían al lado.

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

**Y dónde entran las cuatro nuevas, decidido el 2026-08-23 con su motivo:** la
**13** puede ir **cuando se quiera y descuelga sola** —es una línea de matriz en
la CI y no depende de nada de aquí—; la **14** y la **16** van **con el grueso**,
porque tocan documentos que las tareas 4, 7 y 9 mueven; y la **15** va **detrás
de la 6**, porque su sitio natural es un objetivo del `Makefile` que la 6 aún no
ha creado. **Ninguna de las cuatro toca un guion que fabrique el medio**, que es
la condición que mantiene a la 11 la última.

**Cómo se cierra el bloque entero.** Cuando `bancos/enlaces.sh` —la tarea 1— pase
en verde sobre el árbol ya movido, **y el documento de la tarea 12 no tenga
ninguna fila sin veredicto** —*hecho el 2026-08-23: dieciocho filas, veinte
veredictos —dos filas se parten—, ocho rechazadas enteras. **Y la tarea 1
también está hecha esa misma tarde**, así que las dos condiciones de cierre
existen ya: lo que falta es que `bancos/enlaces.sh` siga en verde **sobre el
árbol ya movido**, que es lo que todavía no ha pasado*—. Sin ese instrumento y sin ese criterio,
«refactorización terminada» sería una sensación y no una salida — y con el
encargo nuevo, «proyecto profesional» lo sería aún más.

---

## 1. El instrumento primero: `bancos/enlaces.sh`

- [x] ~~**Un guion que compruebe que ninguna referencia apunta a la nada.**~~
      **HECHA EL 2026-08-23. El guion es [`bancos/enlaces.sh`](../../bancos/enlaces.sh)
      y la medición entera, con su control, su saboteo sobre el árbol real y sus
      cifras, está en `MEDICIONES.md` §4.66.** Corre en menos de dos segundos, y
      hoy da **0 fallos** con **5 avisos declarados**. Lo que salió, y no estaba
      previsto, en cuatro líneas:
      **(1) LAS TRAMPAS ERAN SIETE Y NO TRES**, y las dos últimas no se podían ver
      sin escribir el guion: una referencia **tachada** (`~~§7.7~~ §4.25`) seguía
      contando —o sea que el comprobador castigaba justo el método de este
      repositorio, y la única forma de ponerlo verde habría sido borrar la
      historia—; un `§` **dentro de un bloque de código** también, con lo que la
      propia §4.66 **se denunció a sí misma con nueve `[FALLO]` y ninguno
      cierto**; y **el propio guion se denunció con quince más al versionarlo**,
      porque sus referencias inventadas son los negativos de su control. Las tres
      sólo se ven **usándolo**, que es el argumento entero de por qué esta tarea
      iba la primera.
      **(2) LA CARGA ÚTIL FUERON SIETE ROTAS Y NO DOS.** Los dos enlaces
      relativos que (c) apuntaba, arreglados; y **cinco referencias `§` rotas que
      nadie había visto**, todas **fuera** del subespacio `§4.x` —que es
      justamente el 12 % que la lectura de ayer no miró, así que aquella medida
      no era falsa: era parcial—. Dos arregladas (`§7.7`, que apuntaba a un paso
      de la §7 de `ENCINA-OS.md` que ya no existe → §4.25, que es donde está
      medido) y **tres declaradas y NO arregladas**, porque inventarles destino
      sería deducir: salen `[AVISO]` con su motivo dentro del guion.
      **(3) LAS EXCLUSIONES SON SIETE Y NO SEIS** —faltaba `scripts/construir-deb.sh`,
      que la tarea 10 propone y que además es un guion real del repositorio
      hermano—, **y la lista no se pudre**: el guion avisa de la entrada que
      sobra en cuanto el fichero aparece. `bancos/enlaces.sh` **se cayó sola hoy**.
      **(4) LO QUE NO HACE, y no se da por bueno:** la atribución de las **1.741**
      referencias desnudas queda `[OMIT]` —ahí un `[OK]` dice «existe», no
      «existe donde se pretendía»—, y `shellcheck` no está en este Mac, así que
      sólo pasó `bash -n`.

      *Lo que pedía la casilla, conservado entero porque su análisis se cumplió:*

      ~~**Un guion que compruebe que ninguna referencia apunta a la nada.**~~ Recorre
      los `.md` y los `.sh` y saca `[FALLO]` por cada referencia `§N.NN` que no
      exista, cada nombre de guion citado que no esté en el disco y cada ruta
      relativa rota.
      *Por qué:* hay ~~**1.857 referencias `§N.NN`**~~ repartidas por el
      repositorio ~~—694 en `MEDICIONES.md`, 220 en `ENCINA-OS.md`, 201 en
      `AGENTS.md`, 53 dentro del propio `fabricar-iso.sh`—~~.
      **ENMIENDA DEL 2026-08-23: ESA CIFRA NO SE REPRODUCE, Y ES LA ÚNICA DE
      ESTE FICHERO QUE NO LO HACE.** Sobre `99e0e39`, que es el árbol que se
      leyó, `grep -roE '§[0-9]+(\.[0-9]+[a-z]?)*'` da **1.919** y el patrón
      estricto `§N.N` da **1.682**; sobre el árbol de hoy, **2.153**. Las tres
      son defendibles y ninguna es la escrita, porque **la cifra se escribió sin
      la orden al lado**. Las otras cinco cifras de aquella lectura sí se
      reprodujeron, seis de seis. *No invalida la tarea: es su primera medida a
      favor,* y la enmienda es de forma — **una cifra va con su orden o no va**. Las tareas 4 y 9 mueven ficheros, y
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
      **AMPLIACIÓN DEL 2026-08-23, y son tres cosas que esta casilla no tenía y
      sin las cuales el guion nace mintiendo** (medido en
      [organizacion-comparada.md](organizacion-comparada.md) §1.c):
      **(a) El espacio de referencias es de DOS niveles y con DOS convenciones.**
      `§4.37c` **no** apunta a una sección `### 4.37c` —no existe ninguna— sino a
      un `#### (c)` **dentro** de `### 4.37`; y hay una segunda forma, `**c) …`,
      con **62** apariciones frente a **451**. Un comprobador que sólo mire `###`
      pinta **204 falsos `[FALLO]` de 305**; con `#### (x)`, **34**; con las dos,
      **1**.
      **(b) Hace falta una política de exclusión, o el primer día salen seis
      `[FALLO]` y ninguno es cierto:** de 51 rutas de guion citadas, no existen
      seis — cuatro son ficheros que **esta misma lista planea**
      (`bancos/enlaces.sh`, `bancos/vigencia.sh`, `lib/salida.sh`, `lib/vm.sh`) y
      dos son **nombres históricos conservados a propósito**
      (`imagen/autoinstall-e3.yaml`, `imagen/verificar-e2.sh`), que `SCRIPTS.md`
      documenta en su tabla de equivalencias.
      **(c) Y una parte del trabajo ya está hecha, con su control incluido:** de
      las **305** referencias `§4.x` distintas del repositorio, **ninguna está
      rota hoy** — la única que no resuelve es `§4.999`, que es **el control que
      esta misma casilla manda inventar y que ya está escrito seis líneas más
      arriba**. Lo que sí hay son **dos enlaces relativos rotos de 128**, y son
      la carga útil de esta tarea: `MEDICIONES.md:16713`
      (`[alojamiento.md](../alojamiento.md)`, que está en `tareas/`) y
      `design/capturas/despues/entrega-cd84d2ec/LEEME.md:46` (faltan cuatro
      niveles de `..`, no tres). ~~**No se arreglaron el 2026-08-23 a propósito:**
      son el primer resultado del instrumento y quitárselo lo dejaría sin nada
      que demostrar.~~ **ARREGLADOS ESA MISMA TARDE, en cuanto el instrumento
      existió y los enseñó él: era eso lo que había que esperar, no más tiempo.**
      **Y las tres cifras de esta casilla quedan enmendadas, cada una con la
      orden que la da** (§4.66h): las referencias `§` son **2.251** en el árbol y
      **2.126 comprobadas** —las otras 125 las excluyen las trampas 2, 5, 6 y 7, con
      su motivo y contadas—, y no ~~1.857~~, que sigue sin reproducirse; las
      rutas de guion citadas son **39** más 18 nombres sueltos que se cuentan
      aparte, y no ~~51~~; y los enlaces relativos son **145**, no ~~128~~.

## 2. `fallo()` significa dos cosas opuestas

- [x] ~~Partir `fallo()` en dos nombres, y declarar el `set` en cada guion.~~ **HECHA EL 2026-08-28, la mitad de `imagen/` que faltaba (§4.80b):** los seis que abortaban renombran su `fallo()` a `morir()`, los doce de `imagen/` declaran su modelo, `encina-seed.sh` no se toca (viaja en la ISO), y `grep -rn 'fallo()'` enseña seis definiciones que cuentan y siguen; los cuatro bancos, idénticos byte a byte a la línea base.
      *Lo que pedía la casilla, conservado:* **Partir `fallo()` en dos nombres, y declarar el `set` en cada guion.** En
      `scripts/lib.sh` y en tres guiones de `imagen/` —`capa-marca.sh`,
      `inventario-marca.sh`, `verificar-instalacion.sh`— `fallo()` incrementa un
      contador y **sigue** —**enmienda del 2026-08-23: son CUATRO de `imagen/`,
      no tres: faltaba `banco-autosuficiencia.sh`, así que el reparto es cinco
      que cuentan y seis que abortan**—. En otros seis —`fabricar-iso.sh`,
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
      **Comprobado el 2026-08-23 ejecutando el `grep` sobre los 36 guiones: los
      trece `00`–`12` no lo declaran, exacto, y los tres del `set -u` también. Se
      añaden otros tres que esta casilla no nombraba y tampoco lo declaran:
      `design/generar.sh`, `capturar-aspecto.sh` y `diario.sh`.**
      **Y una corrección del 2026-08-23 que le quita una decisión a esta casilla:
      el tercer nombre ya existe en el árbol.** `imagen/capa-marca.sh` define
      `morir()` **junto a** `fallo()`, o sea que el guion que más lo necesitaba ya
      inventó la palabra por su cuenta. Esta casilla propone `abortar()`; el árbol
      votó `morir()`. Hay que elegir uno, y hay precedente.
      *Hecha cuando:* `fallo()` apunta y sigue en todos los guiones y `abortar()`
      sale en todos, `grep -rn 'fallo()' ` enseña una sola forma, cada guion
      declara su `set` en la cabecera con una línea que diga cuál de los dos
      modelos usa, y **los cuatro bancos siguen dando lo mismo que hoy**.

      **ENMIENDA DEL 2026-08-23 (noche): EJECUTADA LA MITAD QUE NO TOCA
      `imagen/`. LA CASILLA SIGUE SIN MARCAR, y el motivo está escrito.** La
      medición entera es [MEDICIONES.md](../../MEDICIONES.md) §4.67.

      **El reparto no es cinco y seis: son SEIS y SEIS.** La enmienda de esta
      mañana no era falsa, era **de ayer**: la sexta que cuenta es
      `bancos/enlaces.sh`, **que la tarea 1 creó esa misma tarde**. En un plan
      que se ejecuta, una cuenta de guiones caduca en horas.

      **El tercer nombre es `morir()` y no `abortar()`**, y no por gusto: el
      árbol lo tenía ya en dos sitios —`imagen/capa-marca.sh:92` lo define, y
      `scripts/contar-arranques.sh:43` escribe su cuerpo entero a mano sin
      ponerle nombre—. Dos usos son un precedente; cero son una preferencia.
      Queda definida en `scripts/lib.sh` con el cuerpo de `capa-marca.sh`.

      **Hecho:** los **23 guiones fuera de `imagen/`** declaran su modelo en la
      cabecera; **16** no tenían `set` propio y ahora lo reafirman tras el
      `source` —**demostrado no-op con su control y su negativo**, §4.67 (a)—.
      **Cuatro son de modelo ABORTAR y son herramientas, no instrumentos**:
      `capturar-vm.sh`, `teclear-vm.sh`, `contar-arranques.sh` y `diario.sh`.

      **Y la casilla contaba dos modelos: hay CUATRO.** Los guiones numerados
      abortan de dos formas más que ésta no nombraba —**20** veces
      `fallo "…"; resumen; exit 1`, y **20 o más** guardas mudas
      `{ echo "…"; exit 1; }` que **no escriben `[FALLO]`**—. Medido en §4.67 (d)
      y **no convertido**: es mutación de comportamiento en guiones de VM que
      este Mac no ejecuta.

      **Y hay un guion sin `set` que no estaba en ninguna lista, y no debe
      tenerlo:** `imagen/encina-seed.sh`. Es `#!/bin/sh` y **va dentro de la
      ISO** —`fabricar-iso.sh:376` lo mete en base64 en la `late-command`—, así
      que tocarlo cambia los bytes del medio. §4.67 (e).

      *Lo que falta, que es la carga útil y está bloqueada por la fase 1:* los
      **10 `fallo()` de `imagen/`**, seis que abortan y cuatro que cuentan.
      **Jorge está arrancando el medio `amd64` en el portátil**, e `imagen/` es
      lo que fabrica y lo que lee ese medio. La lista exacta está en §4.67 (b) y
      (k); es una sesión corta cuando la fase 1 acabe.

      *Y una trampa nueva, que costó un commit:* **`source` de un guion para
      leerle el `set` no lo lee, LO EJECUTA.** El primer control por guion
      ejecutó los 23, `scripts/colocar-esqueleto.sh:154` hizo un `git commit` que nadie
      pidió y `crear-ci.sh` fabricó un repositorio en `~/encina`. Deshecho con
      `git reset --mixed`; nada fuera de los 23 `.sh` se tocó. **Y el control
      dio un `[OK] FALSO Y VACÍO`**, porque el árbol quedó limpio y «no hay
      líneas raras» sobre **cero** líneas se lee igual que un aprobado: por eso
      el control definitivo empieza comprobando que el `diff` no está vacío.
      §4.67 (h).

      *Y los bancos son cinco, no cuatro:* `banco-cadena` (8/0),
      `banco-veredicto` (9/0) y `banco-mecanismos` salen **idénticos byte a
      byte** a antes de tocar nada —el de mecanismos, `[OMIT]`: sin las ISOs en
      `medios/` sale `CONTROL ROTO`, ni antes ni después es un aprobado—;
      `banco-autosuficiencia` va **`[OMIT]`**, exige VM. Y **`bancos/enlaces.sh`
      cazó esta misma tarea**: ~30 `[FALLO]` ciertos porque las cabeceras nuevas
      citaban §4.67 antes de que existiera. Escrita, vuelve a
      `correctas: 9  fallos: 0`.

## 3. `lib/salida.sh`, y que `imagen/` lo use

- [x] ~~Partir `scripts/lib.sh` en dos capas y llevar la portátil a `imagen/`.~~ **HECHA EL 2026-08-28 (§4.80c):** `lib/salida.sh` y `lib/vm.sh`, `scripts/lib.sh` de puente; ningún fichero fuera de `lib/` define `ok`/`fallo`/`aviso`/`omitido`; `verificar-instalacion.sh` y `verificar-branding.sh` en la misma columna por construcción, y el que viaja se empaqueta con `make verificador`; los cinco bancos con los mismos recuentos.
      *Lo que pedía la casilla, conservado:* **Partir `scripts/lib.sh` en dos capas y llevar la portátil a `imagen/`.**
      `lib/salida.sh` con el vocabulario, los contadores y `resumen()`, sin nada
      de VM; `lib/vm.sh` con lo que hoy sólo sirve en Ubuntu
      —`xdg_data_dirs_sesion`, `resolver_desktop`, `PKG_DIR`—.
      *Por qué:* ~~nueve~~ **diez** guiones de `imagen/` reimplementan `ok`,
      `fallo`, `aviso`, `omitido` y sus contadores, cada uno con su propio relleno
      de espacios, así que **la salida del proyecto no está alineada consigo
      misma**.
      **ENMIENDA DEL 2026-08-23, y el problema es mayor de lo que decía esta
      casilla: se reimplementa de TRES formas, no de dos.** Además de `lib.sh` y
      de los diez que definen su propia función, **los tres bancos
      —`banco-cadena.sh`, `banco-mecanismos.sh`, `banco-veredicto.sh`— ni
      siquiera la definen: escriben `echo "[OK]"` y `printf` a pelo, con formato
      propio cada uno.** **Y la frontera que esta casilla quiere trazar ya existe
      medida y es limpia:** de los **17** guiones que hacen `source` de `lib.sh`,
      **ninguno está en `imagen/`**. Cero. La partición propuesta coincide
      exactamente con una línea que el árbol ya tiene. El
      vocabulario y los contadores no dependen del sistema operativo; lo que sí
      depende es el resto de `lib.sh`, y ésa es la frontera real.
      *Hecha cuando:* ningún fichero fuera de `lib/` define `ok`, `fallo`,
      `aviso` ni `omitido`, y la salida de `verificar-instalacion.sh` y de
      `verificar-branding.sh` está alineada en la misma columna. **Control:** los
      cuatro bancos y `comprobar-propios.sh` dan el mismo número de correctas y
      fallos que antes del cambio, apuntado antes de tocar nada.

## 4. Partir `MEDICIONES.md` conservando los `§`

- [x] ~~Un fichero por sección, y el número es el nombre del fichero.~~ **HECHA EL 2026-08-28 (§4.80d):** 82 ficheros en `mediciones/`, verbatim —la concatenación reconstruye el original con `diff` vacío—, `enlaces.sh` en verde sobre el árbol partido (2 440 referencias) y `grep '§4.37'` encuentra las 88 de antes.
      *Lo que pedía la casilla, conservado:* **Un fichero por sección, y el número es el nombre del fichero.**
      `mediciones/4.37-huella-del-arbol-sucio.md`, `mediciones/9-trampas.md`,
      y `mediciones/LEEME.md` con la tabla de vigencia y el índice.
      *Por qué:* `CLAUDE.md` ordena consultar `MEDICIONES.md` **antes de
      investigar cualquier cosa**, y el fichero son ~~**765 KB y 14.637
      líneas**~~, con una sola sección —la §4— que ocupa ~~**11.200 líneas y 60
      subsecciones**~~.
      **REMEDIDO EL 2026-08-23, UN DÍA DESPUÉS: 903 KB y 17.211 líneas, y la §4
      son 11.220 líneas y 65 subsecciones.** Las cifras viejas eran **exactas**
      sobre `99e0e39`, comprobado con `git archive`: creció **138 KB y 2.574
      líneas en un día**, que es el mejor argumento que esta casilla puede tener.
      La regla es correcta y hoy es físicamente incumplible, así que el resultado
      práctico es que se investiga sin consultarlo, que es justo lo que la regla
      existe para evitar. No se reescribe ni una línea del contenido: se mueve
      **verbatim**, como se hizo con `TAREAS.md` el 2026-08-14.
      **Y UNA RESTRICCIÓN DEL 2026-08-23 QUE ESTA CASILLA NO TENÍA, y es la
      misma que la tarea 1:** partir por `### 4.NN` deja 65 ficheros, pero
      **513 sub-subsecciones son destino de referencia** —451 con la forma
      `#### (x)` y 62 con la forma `**x)`—, así que **el nombre del fichero no
      puede ser el único ancla**: el ancla de dentro tiene que sobrevivir al
      corte, o un movimiento *verbatim* rompe 305 referencias que **hoy resuelven
      todas**.
      *Hecha cuando:* `bancos/enlaces.sh` en verde después del movimiento,
      `grep -rn '§4.37'` sigue encontrando lo mismo que antes, y un `diff` del
      contenido concatenado contra el fichero original **no señala más que los
      títulos que cambian de nivel**. Ése es el control: si el diff enseña texto,
      se ha perdido algo.

## 5. La tabla de vigencia, entera y comprobada

- [x] ~~Que ninguna sección se quede sin fila, y que lo diga un guion.~~ **HECHA EL 2026-08-28 (§4.80e):** `bancos/vigencia.sh` da 0 fallos sobre 83 secciones y 83 filas, con sus dos controles; faltaban 47 filas y no 46 (la §4.45 no estaba en ningún rango).
      *Lo que pedía la casilla, conservado:* **Que ninguna sección se quede sin fila, y que lo diga un guion.** La tabla
      cubre ~~**33 de las 60**~~ subsecciones §4.x.
      **REMEDIDO EL 2026-08-23: el 33 es exacto y sigue siéndolo; el 60 ya no
      —son 65—, así que faltan 32 filas, no 27. Y el patrón importa más que el
      número: lo que falta no está repartido, es LA COLA.** De la §4.54 en
      adelante **no hay ni una sola fila**. La tabla no está «a mitad»: está al
      día hasta el 2026-08-15 y parada desde entonces. Las 32 sin fila son
      `4.29`–`4.31`, `4.33`–`4.44`, `4.46`–`4.50` y `4.54`–`4.65`.
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

- [x] ~~Una orden para construir y una para probar, y que la CI las use.~~ **HECHA EL 2026-08-28 (§4.80f):** `Makefile` con `mk/*.mk`; `make bancos` corre los ocho y sale distinto de cero si falla uno (sabotaje pagado en local); job `bancos` en la CI con `shellcheck` (simulado tres veces en `ubuntu:24.04`, verde); `make dos-veces`, `make medios/SHA256SUMS`, `make qemu`. **`[OMIT]` el push que ponga la CI de verdad en rojo: es de Jorge.**
      *Lo que pedía la casilla, conservado:* **Una orden para construir y una para probar, y que la CI las use.** Hoy
      hay ~~**cuatro bancos con cuatro puntos de entrada**~~ **CINCO, remedidos
      el 2026-08-23: faltaba `imagen/banco-autosuficiencia.sh`** —`banco-cadena.sh`,
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
      **AMPLIADA EL 2026-08-23 POR LA TAREA 12, y es la casilla que más gana con
      la comparación:** `pop-os/iso` tiene literalmente esto desde hace años
      —`make`, `make all`, `make qemu_bios`, `make qemu_uefi`, `make clean`— y la
      configuración partida en **`mk/*.mk` por asunto**, que es la forma que
      conviene copiar. Esta casilla se escribió mirando sólo hacia dentro y
      coincide con lo de fuera, así que **se confirma con precedente**. Gana tres
      objetivos y corrige un conteo:
      **`make medios/SHA256SUMS`** —hoy ese fichero son 185 bytes **escritos a
      mano**, y este repositorio ya se equivocó una vez apuntando una huella por
      el nombre de la VM en vez de por el fichero (`TAREAS.md`); fuera lo genera
      la propia orden que construye (fila **A4**)—;
      **`make dos-veces`**, que es la definición de terminado real de
      `construir-todo.sh` y hoy es **una frase en `CLAUDE.md`**, o sea opcional;
      y **`make qemu`**, una puerta a `scripts/fabricar-vm-medio.py` para que
      arrancar el medio deje de vivir sólo en la prosa de `SCRIPTS.md` (fila
      **D4**). **Y los guiones para `shellcheck` son 35, no 33**: hay 36 `.sh` en
      disco, pero `medios/verificar-instalacion.sh` es una copia que `.gitignore`
      tapa con `medios/*`. **Lo que NO entra: firmar las sumas** — exige una clave
      que `AGENTS.md` §7 prohíbe en el runner, y decidir dónde vive es de
      [publicar.md](../publicar.md) (fila **E2**).

## 7. Vaciar `ENCINA-OS.md` §7

- [x] ~~Que «Empieza aquí» vuelva a caber en una pantalla.~~ **HECHA EL 2026-08-28 (§4.80g):** §7 son 38 líneas; lo que había está verbatim en `tareas/cerradas/empieza-aqui-2026-08-08-a-2026-08-25.md` y `enlaces.sh` sigue en verde.
      *Lo que pedía la casilla, conservado:* **Que «Empieza aquí» vuelva a caber en una pantalla.** Hoy son ~~**1.189
      líneas**~~ **1.724, remedidas el 2026-08-23 —creció 535 en un día, y la
      cifra vieja era exacta sobre `99e0e39`—**. Se queda con la tarea en curso y nada más; el resto baja a
      `tareas/cerradas/` con su fecha.
      *Por qué:* `CLAUDE.md` manda leer §7 «siempre primero, la tarea en curso y
      sólo esa». Con 1.189 líneas ya no es por dónde empezar: es el archivo de por
      dónde se empezó. Y `tareas/cerradas/` es el sitio que ya existe y ya se usa
      para esto.
      *Hecha cuando:* §7 baja de 60 líneas, lo que salió está en
      `tareas/cerradas/` con su fecha, y `bancos/enlaces.sh` sigue en verde —hay
      **220 referencias `§`** en este documento y algunas apuntan dentro de §7—.

## 8. Los tres bloques de `diario.sh`

- [x] ~~Que cada entrada del diario salga partida en tres.~~ **HECHA EL 2026-08-28 (§4.80j):** `diario.sh` escribe los tres bloques; la primera entrada nueva es la de este cierre, y la línea más larga de una entrada nueva baja de 1 500 (59 en la prueba). Las viejas no se reescriben.
      *Lo que pedía la casilla, conservado:* **Que cada entrada del diario salga partida en tres.** Qué se midió · qué
      salió mal · qué toca mañana.
      *Por qué:* `DIARIO.md` tiene entradas de hasta **6.518 caracteres en una
      sola línea**. El contenido es bueno y ya trae esas tres cosas mezcladas; lo
      que no se puede es localizar nada dentro de una entrada ni ver en un `diff`
      qué parte cambió. Sale gratis porque `diario.sh` ya escribe el fichero.
      *Hecha cuando:* la primera entrada nueva sale con los tres bloques y
      `awk '{print length}' DIARIO.md | sort -rn | head -1` baja de 1.500 para
      las entradas nuevas. **No se reescriben las viejas.**

## 9. Un registro único de trampas

- [x] ~~`TRAMPAS.md`: una fila por trampa, con la columna que hoy no existe.~~ **HECHA EL 2026-08-28 (§4.80i):** 68 filas, numeración conservada —y el hallazgo de que 28-33 están asignados dos veces, resuelto con a/b sin renumerar—, `enlaces.sh` resuelve todos los enlaces al texto largo.
      *Lo que pedía la casilla, conservado:* **`TRAMPAS.md`: una fila por trampa, con la columna que hoy no existe.**
      Número —global, conservado—, síntoma, causa, **a qué guion o fase aplica**,
      y dónde está medida.
      *Por qué:* las trampas viven en dos sitios con numeración compartida
      —`MEDICIONES.md` §9 tiene una tabla, `SCRIPTS.md` tiene ~~veintidós y
      pico~~ repartidas en secciones tituladas «Y una octava…», «Y una
      vigesimoprimera…»—
      **RECONTADO EL 2026-08-23, Y LA CIFRA HA ENVEJECIDO MAL: se citan 45
      números de trampa DISTINTOS y llegan hasta la 58**, repartidos en **28**
      secciones con títulos de esa forma. **Y la numeración global tiene trece
      huecos de 58** —no se citan por número la 6, la 23, la 25, la 30, la 33, la
      34, la 37, la 39 ni las 52 a 56—, que es exactamente lo que una fila por
      trampa haría visible. **La tarea es más urgente que cuando se escribió, no
      menos.**
      y la propia tabla de §9 cita «trampa 13 de `SCRIPTS.md`». Para saber si una
      trampa aplica a lo que estás tocando hay que conocer las dos listas de
      memoria. **Es un índice, no una reescritura:** el texto largo se queda donde
      está y la fila apunta. `SCRIPTS.md` no se toca y recupera su papel de
      referencia de guiones.
      *Hecha cuando:* toda trampa numerada tiene exactamente una fila, la
      numeración global no cambia, y `bancos/enlaces.sh` resuelve todos los
      enlaces de la tabla al texto largo.

## 10. Renombrar los guiones por paquete y fase

- [x] ~~Que el nombre diga qué paquete y qué fase, y que el orden lo diga
      `SCRIPTS.md`.~~ **HECHA EL 2026-08-28 (§4.80k):** los trece por verbo y paquete, tabla de equivalencias en `SCRIPTS.md`, la CI apunta a los nuevos, `enlaces.sh` en verde, y `make paquetes` en docker da las tres huellas del manifiesto con los guiones renombrados.
      *Lo que pedía la casilla, conservado:* **Que el nombre diga qué paquete y qué fase, y que el orden lo diga
      `SCRIPTS.md`.** Los trece números `00–12` son en realidad tres tríadas
      —construir · instalar · verificar, por paquete— intercaladas con cuatro
      utilidades.
      *Por qué:* un cuarto paquete no tiene hueco, y el número no dice a qué
      paquete pertenece cada guion: hay que abrirlo.
      **Y desde el 2026-08-23 hay un precedente mejor y más cercano que el del
      renombrado, encontrado por la tarea 12: `~/Projects/encina-autofirma`
      —mismo autor, mismo método— YA USA la convención de destino**, verbo primero
      y sin números: `construir-deb.sh`, `verificar-deb.sh`, `estado-vm.sh` y
      **doce** `medir-<qué>.sh`. O sea que la convención no hay que inventarla ni
      copiarla de fuera: lleva meses funcionando al lado. Hay precedente de que aquí
      renombrar sale barato — `SCRIPTS.md` documenta el renombrado del 2026-08-13
      con su tabla de equivalencias, y así se hace éste también.
      *Hecha cuando:* los nombres nuevos están, `SCRIPTS.md` lleva su tabla de
      equivalencias como la otra vez, la CI apunta a los nuevos, y
      `bancos/enlaces.sh` en verde. **Va la penúltima** porque es la que más
      citas rompe en los documentos.

## 11. `fabricar-iso.sh`, una función por fase

- [x] ~~Que las 13 fases sean ejecutables y no comentarios.~~ **HECHA EL 2026-08-28 (§4.80l):** 22 funciones (14 fases, siete subfases de la 5 y la 10bis) y la lista que las llama en orden; **la ISO sale con la misma huella que antes del cambio, `63f360dd…`, apuntada antes de tocar nada, y las dos pasadas dan la misma**.
      *Lo que pedía la casilla, conservado:* **Que las 13 fases sean ejecutables y no comentarios.** Cada
      `# --- N. ---` pasa a `fase_N_nombre()`, y al final un bloque que las llama
      en orden. **Un fichero, misma lectura lineal.**
      *Por qué:* son ~~**1.201 líneas**~~ **1.413, remedidas el 2026-08-23 (la
      cifra vieja era exacta sobre `99e0e39`)** y la descomposición ~~**ya está
      pensada** —las fases están marcadas del 0 al 13—~~; lo que falta es que sea
      ejecutable.
      **ENMIENDA DEL 2026-08-23: LA DESCOMPOSICIÓN NO ESTÁ TAN PENSADA COMO DECÍA
      ESTA CASILLA, y eso la encarece.** Contadas, hay **21 marcas `# ---`** con
      numeración **discontinua** —`0,1,2,3,4,5,6,7,10,11,13`, o sea que **faltan
      la 8, la 9 y la 12**—, más **ocho subfases** (`5a`, `5b`, `5b-bis`, `5c`,
      `5c-bis`, `5d`, `5e`, `10bis`) y **dos bloques sin número**. Así que
      «`# --- N. ---` pasa a `fase_N_nombre()`» no es mecánico: **hay que decidir
      qué es fase y qué es subfase**, y esa decisión es trabajo, no transcripción. Sin
      eso no se puede probar una fase sola y las banderas de bisecado
      —`--sin-capa`, `--sin-volid`, `--sin-info`, `--sin-menu`— tienen que
      dispersarse por el cuerpo.
      *Hecha cuando:* **la ISO que sale tiene la misma huella que antes del
      cambio**, apuntada antes de tocar nada, y las dos pasadas siguen dando la
      misma. Ése es el único control que vale aquí.
      **VA LA ÚLTIMA, y con el producto congelado:** es el guion que fabrica lo
      que se entrega.

## 12. Qué es «un proyecto de distribución bien organizado», escrito ANTES de mover nada

- [x] ~~**Un documento que compare este repositorio con cómo están organizados
      los proyectos que hacen lo mismo, y que diga de cada diferencia si se adopta
      o no, y por qué.**~~ **HECHA el 2026-08-23:**
      [organizacion-comparada.md](organizacion-comparada.md). **Su definición de
      terminado, ejecutada casilla a casilla:** **dieciocho** filas con **una
      diferencia por fila** y las cuatro columnas; **ninguna fila sin veredicto**,
      contado con `grep` sobre la tabla y no a ojo — diez con veredicto de
      adopción, diez con veredicto de rechazo, **dos filas** (**B3** y **E2**)
      **dan los dos** y **ocho se rechazan enteras**; **cada fila adoptada convertida en
      casilla** — las **13, 14, 15 y 16** de este mismo fichero, y la **6**
      ampliada con `make medios/SHA256SUMS`, `make dos-veces` y `make qemu`; **y
      su control pasa: ocho filas rechazadas, cada una con su motivo**, entre
      ellas las tres que protegen lo que este repositorio hace mejor que los
      siete comparados —la oferta de fuente (**E1**), el registro de mediciones
      (**F1**) y el porqué pegado al código (**F3**)—. **La pregunta de fondo
      está contestada sin resolverla, que es lo que la casilla pedía:** las filas
      **A2** y **D1** son las que presuponen `live-build`, están marcadas
      **[E5]** y recogidas juntas en §3 con el hallazgo que `ENCINA-OS.md`
      necesitaría — **de los siete proyectos comparados, ninguno reempaqueta**, y
      Ubuntu Cinnamon, al profesionalizarse, se movió de `live-build` a semilla +
      `livecd-rootfs`. **No se decide aquí.** No es «aplicar buenas prácticas»: es **decidir cuáles**,
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


## 13. La CI construye también `arm64`, que es el producto que D9 declara

- [x] **Una entrada más en la matriz: `ubuntu-24.04-arm`.** **HECHA EL 2026-08-23**
      (`MEDICIONES.md` §4.69: ejecución 32650010668, 6 de 6, tres huellas arm64
      iguales a las del manifiesto; la casilla iba corta en tres sitios, (c)). Hoy
      `.github/workflows/build.yml` corre en `ubuntu-latest` y nada más, así que
      los tres `.deb` **sólo se construyen en amd64**.
      *Por qué:* `AGENTS.md` §8 dice *«amd64… se construye en CI porque el runner
      es amd64, pero no se declara probado»*, y **esa frase describe hoy justo al
      revés lo que importa: el que no se construye en CI es `arm64`**, que es el
      producto declarado por D9 y el único que se ha probado a mano. Los runners
      `ubuntu-24.04-arm` son **gratis y en disponibilidad general para
      repositorios públicos desde el 2025-08-07**, y este repositorio es público
      (D5), así que el precio es una línea. Y el argumento de por qué vale la
      pena **ya está escrito por el propio autor** en la CI de
      `~/Projects/encina-autofirma`, que lleva meses construyendo las dos: *«la
      corrección de las rutas de NSS existe precisamente porque el código llevaba
      escritas a mano las de x86. Una CI que solo mirase una arquitectura no
      habría encontrado ese fallo.»*
      *Hecha cuando:* la matriz corre en las dos arquitecturas y **las dos pasan
      su control saboteado** —el que ya existe, no uno nuevo—, y la frase de
      `AGENTS.md` §8 queda **enmendada con su fecha**, dejando al lado lo que
      decía. **Control:** el `.deb` de `arm64` sale con **la huella del
      manifiesto**, que es lo que hoy no se puede afirmar de ninguna
      construcción automática. Si no coincidiera, eso es un hallazgo y va a
      `MEDICIONES.md`, no un fallo de esta casilla.
      *Sale de:* [organizacion-comparada.md](organizacion-comparada.md), fila
      **D2**. **Descuelga sola y no depende de nada de este bloque.**

## 14. Una sola fuente de la versión, y una prosa que no pueda contradecirla

- [x] ~~Que la versión del producto salga de un sitio, y que las versiones de
      los ingredientes no se puedan escribir mal en un `.md`.~~ **HECHA EL 2026-08-28 (§4.80j):** la versión del producto es la de `encina-meta` y el resto se deriva (nombres de los `.deb` desde el manifiesto); `bancos/versiones.sh` da 0 fallos, con sus dos controles pagados sobre el árbol real; los `+encina2` de los documentos vivos, tres enmendados y 21 marcados históricos.
      *Lo que pedía la casilla, conservado:* **Que la versión del producto salga de un sitio, y que las versiones de
      los ingredientes no se puedan escribir mal en un `.md`.** Hoy la versión
      está a mano y en varios sitios: `imagen/marca/disk-info` dice
      `EncinaOS 24.04.4 LTS "Nutria Nocturna"`, el `Volume id` que D23 declara es
      `Encina OS 0.2.1 arm64`, y los tres paquetes van por su cuenta
      —`encina-branding` **0.1.15**, `encina-firefox-native` **0.2.1**,
      `encina-meta` **0.2.1**—.
      *Por qué:* `0.2.1` nombra hoy **a la vez el producto y dos de los tres
      paquetes**, y ya han dejado de coincidir. Y hay una deriva medida el
      2026-08-23 que lo demuestra en el otro extremo: `imagen/repo-manifiesto.tsv`
      pincha `autofirma` **`1.9.1+encina4`** —y el `debian/changelog` del
      repositorio hermano también—, mientras los `.md` de aquí dicen
      **`+encina2` en 25 sitios** contra 19 de `+encina4`, empezando por la línea
      de alcance de `AGENTS.md`. **El mecanismo bueno ya existe y funciona** —el
      manifiesto, con su sabotaje delante en la CI—: lo que falta es que la prosa
      no pueda desmentirlo en silencio. Nótese que la arquitectura **ya se
      deriva** (`@ARQ@` en `disk-info`): el mecanismo está inventado, falta
      aplicárselo a la versión.
      *Hecha cuando:* la versión del producto vive en **un** sitio y el resto se
      deriva de él; un banco compara las versiones que citan los `.md` contra las
      del manifiesto y los `debian/changelog`, y da 0 fallos; y lo que hoy dice
      `+encina2` **o se corrige o queda como enmienda fechada** —lo segundo vale,
      porque `MEDICIONES.md` y `DIARIO.md` son el registro de lo que se ejecutó
      aquel día y **no se reescriben**—. **Control:** se cambia un dígito de una
      versión en un `.md` a propósito y el banco tiene que señalarlo, **y por ese
      motivo**; y se cambia en el manifiesto y también.
      *Sale de:* filas **B3**, **C1** y **C2**.

## 15. El constructor de los `.deb`, versionado en vez de acordado

- [x] ~~Una receta de la máquina que construye, no un nombre de máquina.~~ **HECHA EL 2026-08-28 (§4.80h):** `docker/Dockerfile.constructor` y `docker/construir-paquetes.sh`, puerta `make paquetes`; los tres `.deb` salen con las huellas del manifiesto, y la receta sin `lintian` (o sin `rsvg-convert`) falla nombrándola. `construir-todo.sh` no se toca.
      *Lo que pedía la casilla, conservado:* **Una receta de la máquina que construye, no un nombre de máquina.** Hoy
      `construir-todo.sh` va por `ssh` a un constructor que se le pasa como
      `usuario@vm-linux`, y **no hay ninguna receta versionada de cómo se hace esa
      máquina**: `preparar-entorno.sh` comprueba que están las siete herramientas, no
      las pone.
      *Por qué:* la definición de terminado de la reproducibilidad —**dos pasadas,
      la misma huella**— se apoya hoy en una VM concreta del disco de Jorge. Si esa
      VM se pierde, la propiedad no se puede volver a demostrar, y es la propiedad
      que sostiene la publicación. Fuera lo resuelven así: Mint levanta *«a Debian
      image [with] docker»*, `debos` se distribuye como contenedor, y
      **`~/Projects/encina-autofirma` ya tiene `docker/Dockerfile.build`** — otra
      vez la respuesta está al lado y no fuera.
      **Alcance, y es estrecho a propósito: SOLO los tres `.deb`.** La otra mitad
      —`fabricar-iso.sh`— usa `xorriso`, `sips` y `shasum` de macOS y **no cabe en
      ningún contenedor**; eso no se toca aquí ni se pretende.
      *Hecha cuando:* existe la receta del constructor, versionada, y los tres
      `.deb` que salen de ella tienen **las huellas de `imagen/repo-manifiesto.tsv`**.
      **Es aditiva: no se toca `construir-todo.sh`**, que es guion de fabricar el
      medio, así que la casilla se puede cerrar sin refabricar nada.
      **Control:** la receta a la que le falta una de las siete herramientas
      **falla**, y falla nombrando cuál. Si construyera igual, no describía nada.
      *Sale de:* fila **A3**. **Va detrás de la tarea 6**, porque su puerta
      natural es un objetivo del `Makefile` que la 6 todavía no ha creado.

## 16. La hoja de los `[OJOS]` debidos

- [x] ~~Un sitio donde se apunte qué mirada falta, por medio y por
      arquitectura.~~ **HECHA EL 2026-08-28 (§4.80j):** `tareas/ojos.md`, 47 filas recogidas sin reescribir las casillas, enlace a cada una resuelto por `enlaces.sh`, y ninguna marcada por un agente.
      *Lo que pedía la casilla, conservado:* **Un sitio donde se apunte qué mirada falta, por medio y por
      arquitectura.** Hoy los `[OJOS]` pendientes están repartidos por
      [marca-del-medio.md](../marca-del-medio.md),
      [aspecto/5-cierre.md](../aspecto/5-cierre.md), [publicar.md](../publicar.md) y
      `ENCINA-OS.md` §7, y **no hay ninguna hoja que los junte**.
      *Por qué:* es lo único que la comparación con el exterior encontró que este
      repositorio no tiene y otro sí. Ubuntu valida cada imagen con **casos de
      prueba manuales que firma una persona**, por hito, producto y arquitectura,
      en `iso.qa.ubuntu.com`: *«Manual testing is still required due to the
      importance of the ISO experience.»* **No inventaron el vocabulario —el
      nuestro es mejor, porque distingue `[OJOS]` de `[OMIT]`—: inventaron el
      sitio donde se apunta.** Y hace falta ahora: la fase 1 son **dos** medios y
      **dos** arquitecturas, y hoy no existe una sola hoja que diga qué falta
      mirar en cuál.
      *Hecha cuando:* existe el fichero con una fila por `[OJOS]` —qué se mira,
      en qué medio, en qué arquitectura, y con qué huella de ISO—, las filas se
      recogen de los cuatro sitios donde hoy viven **sin reescribirlas**, y
      `bancos/enlaces.sh` resuelve el enlace de cada fila a su casilla original.
      **Y la regla que la hace valer, que es la de `CLAUDE.md`: ninguna fila la
      marca un agente. `[OJOS]` es de Jorge.**
      *Sale de:* fila **F2**.

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
