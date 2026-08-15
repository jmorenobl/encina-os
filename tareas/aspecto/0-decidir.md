# 0 — Decidir y escribir, antes de tocar un píxel

Nada de aquí se ve en pantalla, y sin ello lo demás se hace dos veces.

- [x] **La licencia de las seis fotografías** — cerrada el 2026-08-15, y no como
      se esperaba. *Lo que decía esta casilla:* que seis fotos viajaban dentro de
      la ISO sin que estuviera escrito de dónde salieron ni con qué permiso, y
      que era la casilla que bloquea publicar. **La premisa era falsa.**
      `debian/copyright` de `encina-branding` las declara **desde el
      2026-08-08** —Amanda Anusane, Unsplash License, párrafo DEP-5 propio con
      el texto de la licencia transcrito— y `DIARIO.md` lo cuenta ese mismo día.
      Lo que había no era un agujero de licencia sino
      `design/fondos/manifiesto.tsv` **desactualizado respecto de lo que viaja
      dentro del `.deb`**, diciendo `SIN DETERMINAR` durante seis días.
      *Cómo se cierra:* Jorge decide el 2026-08-15 que **manda
      `debian/copyright`** —es lo que viaja y lo que lee quien recibe el
      paquete; el manifiesto es una copia de trabajo— y el manifiesto se cuadra
      con él. Las seis filas tienen ya `licencia` y `origen`: `EUPL-1.2` para
      los dos fondos propios de Jorge, Unsplash License para las cuatro fotos.
      *Y lo que esto NO resuelve, dicho aquí para que no se pierda al ver la
      casilla marcada:* la Unsplash License es permisiva pero **no es una
      licencia libre al uso ni cumple las DFSG**, y prohíbe vender las imágenes
      sin modificación significativa y compilar imágenes de Unsplash para
      replicar un servicio similar. El razonamiento de por qué distribuirlas
      como fondos de un sistema operativo no es ninguna de las dos está en
      `debian/copyright`. Quien reutilice el paquete tiene que leerlo.
      *Y el fleco que abre:* ninguna herramienta cuadra hoy el manifiesto contra
      `debian/copyright`. Si vuelven a separarse, nadie se entera —que es
      exactamente lo que pasó—. `design/generar.sh` lo dice en su cierre.

- [x] ~~**La identidad, como decisión D en `ENCINA-OS.md`.**~~ **HECHA el
      2026-08-15: es `D19`**, en §2 «Decisiones cerradas», y cumple las tres
      cosas que esta casilla exigía — para quién es (no un usuario de Linux:
      alguien con un plazo y consecuencias legales), qué transmite («esto es
      serio y no me va a fallar»), y **qué no debe parecer con los tres nombres**:
      Ubuntu, macOS/Windows y la Administración.
      *Por qué era una casilla y no una obviedad:* el texto llevaba escrito desde
      el 2026-08-14 en `design/identidad.md`, pero **un documento de diseño se
      rediscute y una decisión con su motivo no**.
      *Y D19 no tapa lo que queda abierto:* que el acento propio no existe en la
      lista de Ubuntu y hoy viaja un verde prestado, que los colores semánticos
      están `PROPUESTO`, y que el acento **no se lee** sobre el fondo oscuro de la
      propia marca (1,68). Las tres siguen aquí abajo.

- [x] ~~**Los colores que faltan: error, aviso, correcto y el texto.**~~
      **CERRADA el 2026-08-15: Jorge aprueba los ocho.** Siguen en
      `design/paleta.tsv` como **`PROPUESTO` y no `VIGENTE`**, y eso no es una
      reserva: `VIGENTE` significa «medido en el producto», y estos no se han
      aplicado a ningún paquete todavía. Se vuelven `VIGENTE` cuando entren en
      una versión de `encina-branding` y se vean en pantalla.
      *El texto original de la casilla, que es contra lo que se cerró:* Cinco
      colores de marca sirven para un banner; un sistema operativo necesita más.
      El de **error** es el que más falta hace y el que ninguna paleta de marca
      trae, porque en un banner no hay errores y en este producto sí: un
      certificado caducado, una firma que no sale.
      *Y una incoherencia que hay que resolver de paso:* `identidad.png` declara
      «BLANCO ROTO — `#FFFFFF`», y `#FFFFFF` es blanco puro.
      *Hecha cuando:* `design/paleta.tsv` no tiene ninguna fila `SIN DECIDIR`, y
      el contraste del texto sobre el fondo está **comprobado con un número**, no
      mirado.

      **ESTADO 2026-08-15: la parte medible está hecha; falta el sí de Jorge.**
      `design/paleta.tsv` tiene **cero filas `SIN DECIDIR`** y dos columnas de
      contraste **calculadas desde el hex**, no tecleadas —un comprobador las
      recalcula y la primera pasada cazó **siete** números puestos a ojo—. La
      incoherencia del blanco roto queda resuelta: **manda el nombre**, y el hex
      pasa a `#F5F7F4`, que contra el neutro da 1,14 en vez del 1,23 del blanco
      puro. Pero **los ocho hexes nuevos están `PROPUESTO`, no `VIGENTE`**: son
      una propuesta, y elegir un rojo es de Jorge. **La casilla se marca cuando
      él diga que sí**, no antes.
      *El hallazgo que obligó a partir cada papel en dos, y no estaba previsto:*
      **ningún hex único sirve para los dos modos.** `#9E2F26` da 6,75 sobre el
      papel claro y **1,52** sobre el oscuro. Un solo color de error habría
      pasado la revisión en claro y habría dejado el modo oscuro sin poder contar
      que una firma ha fallado.
      *Y un fallo en lo que YA estaba `VIGENTE`:* el acento `#3A664E` sobre
      `acento-profundo #2F4033` da **1,68**. **El acento no se lee sobre el fondo
      oscuro de la propia marca.** No es un color mal elegido: es que ese par
      **no se había medido nunca**. Dónde el papel sea identidad —el logotipo
      sobre fondo oscuro— hay que decidir qué se hace, y está **sin decidir**.

- [x] ~~**El tema base, elegido, anclado y con la licencia leída.**~~ **CERRADA
      el 2026-08-15: no hay tema base propio y no se forkea Yaru — es `D20`.** El
      «qué tema, anclado a qué versión, con qué licencia y por qué no los otros»
      que pedía se contesta así: **ninguno**; se usa `Yaru-sage`, que ya viaja en
      Ubuntu dentro de `yaru-theme-gtk` y `yaru-theme-icon`, así que no hay
      versión que anclar ni licencia nueva que leer. El razonamiento completo
      está abajo, en el bloque que empieza «DESBLOQUEADA EL 2026-08-15».
      *El texto original, que es contra lo que se cerró:* WhiteSur está
      descartado por R8 y el motivo está en [LEEME.md](LEEME.md).
      **Y desde el 2026-08-14 el candidato no es ninguno de los de fuera: es
      FORKEAR YARU**, preguntado por Jorge y contestado con la medición del mismo
      día. El motivo no es que Yaru sea bonito, es que **es el único tema al que
      el escritorio entero hace caso**: Ubuntu parchea libadwaita para que siga su
      acento y trae el tema del shell. La captura
      `design/capturas/antes/06-archivos-gtk4.png` enseña el problema del otro
      camino —Archivos en claro mientras el shell va en oscuro—, y ése es el
      estado en el que dejaría el escritorio cualquier tema GTK3 de terceros:
      comprado a medias y encima incoherente. Forkear Yaru conserva la coherencia
      y cambia el color, y de paso R8 deja de ser un problema porque Yaru no
      imita a nadie.
      *Hecha cuando:* está escrito **qué tema, anclado a qué versión, con qué
      licencia, y por qué no los otros**.
      *Y una condición que ahorra la decisión entera:* esta casilla **se aplaza
      hasta después de [2-golpes-baratos.md](2-golpes-baratos.md)**, porque la
      medición del acento no compite con el fork: **decide su tamaño**. Si el
      acento admite un color propio, no hay fork y es una línea de
      `gschema.override`. Si es una lista cerrada de diez, o se elige el verde más
      cercano de los suyos o se forkea **sólo para añadir un acento más**, que es
      una diferencia de datos en un SCSS y no un rediseño.

      **DESBLOQUEADA EL 2026-08-15: el aplazamiento ya no se sostiene.**
      [2-golpes-baratos.md](2-golpes-baratos.md) está **5 de 5** y su hito está
      escrito. La medición del acento tenía que «decidir el tamaño» del fork, y lo
      ha decidido: la lista es **cerrada, de diez**, `#3A664E` **no está** en ella,
      y el mecanismo alcanza GTK3, GTK4/libadwaita, iconos y carpetas. **O sea que
      el fork es añadir una variante, no rediseñar.**
      *Lo que hay hoy, y por qué no basta:* viaja `Yaru-sage`, elegido el
      2026-08-14 y aplicado en 0.1.10. Es **un verde prestado**: `#657B69` está
      tan desaturado que **pasa por gris**, así que casi no se lee que se haya
      decidido nada. El otro candidato, `viridian #03875B`, sí cambia la cara pero
      es esmeralda —«más de aplicación que de dehesa»—.
      **La decisión, servida, es de Jorge y son tres opciones:** (a) forkear Yaru
      para añadir la variante `encina` con `#3A664E`, que es lo único que da el
      verde propio y abre la casilla de abajo; (b) quedarse con `sage` y aceptar
      por escrito que el acento no es el de la marca; (c) cambiar a `viridian`,
      que se ve más pero tampoco es el de la marca. **Ya no es una decisión a
      ciegas, que era lo que el aplazamiento protegía.**

      **TOMADA: (b), `sage`. Decisión de Jorge, 2026-08-15, y el motivo es la
      agilidad**, dicho tal cual y no disfrazado de criterio técnico. Queda como
      **`D20`** en `ENCINA-OS.md` §2, con lo que cuesta escrito —hoy el producto
      **no tiene su acento**, tiene uno prestado que pasa por gris— y con **qué
      la reabriría**: que Ubuntu abra el acento a un valor libre, que el tema del
      shell obligue a un repositorio aparte de todas formas, o que alguien mire
      la pantalla y diga que el gris no pasa.
      *Y lo que se compró:* cero paquetes nuevos, cero filas en el manifiesto,
      cero mantenimiento de un fork —repositorio aparte, meson y sassc, rebase
      con aguas arriba, oferta de fuente y un anclaje contra `apt upgrade`, las
      mismas cinco cosas que `encina-autofirma`, para cambiar un color—.

- [x] ~~**Si hay fork de Yaru: dónde vive, y cómo no lo pisa un `apt upgrade`.**~~
      **CERRADA SIN OBJETO el 2026-08-15: `D20` dice que no hay fork**, así que
      no hay dónde alojarlo ni nada que un `apt upgrade` pueda pisar. Se cierra
      sin ejecutar su definición de terminado —que exigía un `apt upgrade`
      simulado— **porque la condición que la abría desapareció, no porque se haya
      comprobado nada**. La diferencia importa: si algún día se reabre `D20`,
      esta casilla vuelve entera y con su control sin hacer.
      *Y su contenido se conserva porque el análisis sigue valiendo el día que se
      forkee algo:* las cinco cosas que arrastra un fork son justamente lo que
      hizo elegir `sage`.
      *El texto original:*
      Dos decisiones, y la segunda es la que se paga cara si se descubre tarde.
      **(a) Repo aparte, por las mismas cuatro razones que `encina-autofirma`:**
      es un fork de un proyecto ajeno con su propia licencia (GPL-3.0 /
      CC-BY-SA), necesita su propia construcción —meson y sassc— que no encaja en
      la cadena de `03-construir.sh`, tiene una relación de rebase con aguas
      arriba que debe verse anclada, y su oferta de fuente **es un repositorio y
      no un directorio de aquí**. Este repositorio lo consumiría por huella en
      `imagen/repo-manifiesto.tsv`, igual que consume `autofirma`.
      **(b) El nombre del paquete.** Si el fork conserva `yaru-theme-gtk` con una
      versión tipo `24.04.1+encina1`, **un `apt upgrade` con una versión mayor lo
      sobrescribe en silencio**. Es la misma familia del problema que obligó a
      anclar el repositorio de Mozilla con `encina-mozilla`. Las salidas son
      nombres propios (`encina-theme-*`) o anclaje por `preferences.d`.
      *Hecha cuando:* la decisión está escrita **con el control que la demuestra**:
      un `apt upgrade` simulado sobre la máquina no toca el tema.
