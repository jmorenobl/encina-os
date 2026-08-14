# 1 — Poder ver lo que se cambia

**Por qué esto va antes que ningún cambio.** En todo lo demás este proyecto
compara salidas literales y prueba el rojo antes de creerse el verde. En lo
visual la única salida literal es una captura, y sin un «antes» guardado
«se ve mejor» es una sensación — que es exactamente lo que aquí no se admite en
ninguna otra parte.

Ya existen `scripts/capturar-vm.sh` y `scripts/teclear-vm.sh`. Falta
encadenarlos.

- [ ] **Un guion que tome las seis pantallas canónicas de la VM**: menú de
      arranque, Plymouth, GDM, escritorio, rejilla de aplicaciones, y **una
      ventana GTK4 junto a una GTK3**. La sexta es la que más informa y la que
      nadie hace: es la que contesta si merece la pena empaquetar un tema, porque
      enseña de un vistazo hasta dónde llega en GNOME 46.
      *Hecha cuando:* una orden produce seis PNG fechados **y dos pasadas
      seguidas sin tocar nada dan seis capturas iguales**. Ese control es lo que
      hace que la diferencia que se vea después sea del cambio y no del reloj, del
      puntero o de una notificación.
      *Y lo que hay que tener en cuenta al escribir la casilla, no al llegar a
      ella:* **un agente no sabe pulsar un botón del invitado** —cinco vías
      descartadas y medidas en §4.35i—, así que abrir la rejilla o una ventana
      puede necesitar una mano. Si la necesita, se dice en el guion.

- [ ] **La foto del «antes», guardada.** Las seis de hoy, con `encina-branding`
      0.1.9 puesto, en `design/capturas/antes/`.
      *Hecha cuando:* existen las seis y están versionadas — es a lo que se
      comparará todo lo demás, y el día que se pierdan no se pueden rehacer,
      porque la máquina habrá cambiado.

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
