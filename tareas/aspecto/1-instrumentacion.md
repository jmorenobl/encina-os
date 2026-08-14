# 1 — Poder ver lo que se cambia

**Por qué esto va antes que ningún cambio.** En todo lo demás este proyecto
compara salidas literales y prueba el rojo antes de creerse el verde. En lo
visual la única salida literal es una captura, y sin un «antes» guardado
«se ve mejor» es una sensación — que es exactamente lo que aquí no se admite en
ninguna otra parte.

Ya existen `scripts/capturar-vm.sh` y `scripts/teclear-vm.sh`. Falta
encadenarlos.

- [x] ~~**Un guion que tome las pantallas canónicas de la VM.**~~ **HECHA el
      2026-08-14.** Es `scripts/capturar-aspecto.sh`, y **no cronometra las
      pantallas: las detecta** —dispara en ráfaga todo el arranque y agrupa los
      fotogramas consecutivos idénticos; cada grupo es una fase y de cada fase se
      guarda el último—. El día que el arranque tarde el doble salen las mismas
      fases con otros tiempos, que es lo que un `sleep 10` no aguanta.
      *Hecha cuando, cumplido:* dos pasadas seguidas dan las mismas fases —`[OK]`
      idéntica byte a byte la del arranque, `[AVISO]` 379 píxeles en GDM y todos
      en la franja del reloj— con **`rc=0`**, y **el rojo probado**: la misma fase
      volteada da `[FALLO] cambia POR DEBAJO de la franja` y `rc=1`.
      *Y los dos criterios costaron un defecto del instrumento cada uno, que es
      lo que enseña:*
      **(a)** agrupando por la huella del PNG entero salían **cinco** fases donde
      hay tres, porque **el reloj del invitado parte GDM en dos**. Se agrupa sin
      la franja de arriba de 130 px, y el 130 no es a ojo: `diferencia.py` situó
      las diferencias en la caja `y 6..119`. Probado con las dos huellas de la
      misma pantalla —distintas enteras, **idénticas sin la franja**—.
      **(b)** el recorte lo hacía `sips`, y `sips --cropOffset` **devuelve el
      fichero entero sin recortar y sin decir una palabra**. El «arreglo» estuvo
      un rato dando 4 fases por casualidad del minuto. Ahora lo hace
      `scripts/huella-recorte.py`, que decodifica el PNG a mano como
      `diferencia.py`, y lleva su control de que recortar 0 y recortar 130 dan
      huellas distintas.
      *Y un fallo mío en el propio guion, cazado por el control:* `..` dentro de
      un `split()` de `awk` es una **expresión regular**, así que la caja se leía
      mal y salía `[FALLO]` sobre diferencias que estaban dentro de la franja.

- [x] ~~**Que el guion llegue a la sesión.**~~ **HECHA el 2026-08-14 con la clave
      que dio Jorge**, y trae el hallazgo que más acota el banco de pruebas:
      **la tecla Super SÍ llega al invitado.** Super abre el resumen y **Super+A
      la rejilla**, capturadas las dos. UTM intercepta Ctrl+Alt, no la tecla de
      comando — o sea que §4.35i («un agente no sabe pulsar un botón del
      invitado») es **más estrecho de lo que se creía**: el ratón no llega, pero
      GNOME es un escritorio de teclado y la mitad de las capturas que se daban
      por imposibles no lo son.
      *Y un fallo del guion que sólo se ve probándolo:* la primera versión
      tecleaba la contraseña **antes** de elegir usuario, y GDM enseña la lista,
      no el campo. Ahora va Intro primero, y se captura en cada paso.
      *Lo que queda suelto:* el Intro de la contraseña cae después sobre el
      diálogo de bienvenida, que espera un «Siguiente» — en esta pasada eso abrió
      Firefox con las notas de versión de Ubuntu. El guion teclea a ciegas contra
      una pantalla que no esperaba.

- [ ] **El control de dos pasadas, también dentro de la sesión.** Las tres fases
      del arranque lo tienen; las de dentro se tomaron **una vez**, así que hoy
      no hay con qué distinguir un cambio del tema de un cambio del reloj o de
      una notificación.
      *Y lo que lo hace más difícil que en el arranque, dicho por delante:* la
      sesión no arranca dos veces igual — hay ventanas abiertas, una bienvenida
      que avanza y un Firefox que no debería estar. Puede que el control aquí no
      sea «dos pasadas iguales» sino otro, y decidir cuál es parte de la casilla.

- [ ] **Subir la cadencia del disparo, o declarar el límite.** Mide **3,1 s de
      media** entre capturas —los `delay` de `capturar-vm.sh` son 2 s por
      llamada—, así que **una pantalla más corta que eso se pierde**. No es
      teórico: la del firmware que dice `Boot0005 "Ubuntu"` salió en el
      reconocimiento y **no** en ninguna de las dos pasadas buenas, y por eso
      viaja con el nombre `reconocimiento-`.
      *Hecha cuando:* o la ráfaga baja de 1 s, o está escrito que las pantallas
      de menos de 3 s no se capturan y cuáles son.

- [ ] **Rehacer la lista canónica, que se escribió sin mirar.** Decía seis
      pantallas y **dos de ellas no existen en esta máquina**: el menú de GRUB
      está oculto porque sólo hay un sistema operativo, y Plymouth **no se ve
      nunca** —la pantalla del invitado está apagada todo el arranque—. La lista
      de verdad, medida, está en `design/capturas/LEEME.md`.
      *Hecha cuando:* la lista dice las pantallas que hay, y para las que no hay
      está escrito **por qué no las hay**, que es más información que la captura.

- [x] ~~**La foto del «antes», guardada.**~~ **HECHA A MEDIAS el 2026-08-14, y la
      mitad que falta es la que falta por la contraseña.** En
      `design/capturas/antes/` están las **tres fases del arranque** con
      `encina-branding` 0.1.9 puesto, más su `fases.tsv` y la del firmware del
      reconocimiento. Se marca porque es lo que el instrumento alcanza hoy y
      porque **el día que se pierdan no se pueden rehacer**: la máquina habrá
      cambiado. Las de dentro de la sesión cuelgan de la casilla de abajo.

- [ ] **Inventariar dónde se ve Ubuntu en el sistema INSTALADO**, midiendo y no
      suponiendo. El medio va aparte. Cuenta el fondo, la tipografía, el tema de
      iconos, el acento, el dock, la rejilla, GDM, el menú de GRUB y `os-release`.
      *Hecha cuando:* hay una lista de ajuste/fichero/cadena, **cada uno con la
      captura de dónde se ve**. Sin la captura es una lista de sospechas.
      *Y con el objetivo dicho bien, para no perseguir un imposible:* no se trata
      de que la palabra «Ubuntu» no exista —`ID_LIKE` tiene que seguir ahí, y la
      atribución es obligación legal—, sino de que **nada en pantalla presente el
      producto como Ubuntu**.
      *Por qué está aquí y no en [0-decidir.md](0-decidir.md), que es donde se
      escribió primero:* su «hecha cuando» exige una captura por línea, así que
      **depende del guion de arriba**. Puesta entre las decisiones hacía el plan
      circular — el fichero 0 no se podía terminar sin el 1. Es el primer uso real
      del instrumento, y las seis capturas del «antes» son justamente su prueba.

- [ ] **La orden que rehace un fondo, escrita.** Los maestros son 3936×2624 y lo
      que viaja es 3840×2160: hay un recorte y un redimensionado que se hicieron a
      mano el 2026-08-08 y **no están escritos**. Hoy los fondos se comprueban por
      huella pero no se rehacen, que es media reproducibilidad — el mismo agujero
      del Bloque 0 con otro disfraz.
      *Lo que ya está hecho, y era la mitad difícil:* `caliza.jpg` **es el maestro
      de `encina.jpg` y `encina-dark.jpg`**, medido el 2026-08-14 mirándolas; era
      el que parecía un maestro sin destino.
      *Hecha cuando:* la columna `orden` de `design/fondos/manifiesto.tsv` no
      tiene ningún `-`, y `./design/generar.sh --escribir` sobre un directorio de
      derivados **borrado** los deja con las huellas del manifiesto cuadrando una
      a una. Y con su rojo: una orden cambiada da otra huella y el guion lo dice.

- [ ] **El comentario del logotipo apunta a una ruta que ya no existe.**
      `encina-logo.svg` dice «coincide con la identidad visual del banner
      (`assets/identidad.png`)», y ese fichero está ahora en
      `design/identidad.png`. **Se intentó arreglar el 2026-08-14 y se revirtió a
      propósito**, porque tocar un solo byte del `src/` cambia la huella del
      `.deb` y `imagen/repo-manifiesto.tsv` clava `encina-branding` 0.1.9 en
      `7c2390dd…`: la corrección dejaría el medio sin poder fabricarse hasta
      reconstruir y volver a anclar. **Es la misma lección de §4.37 vista desde el
      otro lado**: lo que viaja no se retoca suelto.
      *Hecha cuando:* va montada en el siguiente cambio de versión de
      `encina-branding`, con su huella nueva en el manifiesto.

- [ ] **Retirar los degradados de `02-activos.sh`.** `encina.jpg` y
      `encina-dark.jpg` dejaron de ser degradados el 2026-08-08, pero el guion
      sigue sabiendo fabricarlos: `--forzar` **los sustituiría sin preguntar**, y
      las dos comprobaciones que hace después —que son JPEG y que difieren entre
      sí— saldrían **en verde igualmente**. Es un verde que miente, y está escrito
      en `SCRIPTS.md` desde entonces.
      *Hecha cuando:* `02-activos.sh --forzar` ya no puede destruir una
      fotografía, y `design/generar.sh` es el único que toca los fondos.

*Lo que este fichero deja hecho ya:* `design/generar.sh` existe, comprueba el
logotipo, los colores contra `design/paleta.tsv` y las seis filas del manifiesto,
**y su rojo está probado** — una huella saboteada en el último carácter da
`[FALLO]` y `rc=1`, que es justo el defecto que `cosechar-repo.sh` tuvo por
recortar las huellas.
