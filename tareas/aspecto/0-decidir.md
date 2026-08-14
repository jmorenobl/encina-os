# 0 — Decidir y escribir, antes de tocar un píxel

Nada de aquí se ve en pantalla, y sin ello lo demás se hace dos veces.

- [ ] **La licencia de las seis fotografías. ES LA CASILLA QUE BLOQUEA
      PUBLICAR, y estaba sin nombrar.** Seis fotos viajan hoy dentro de la ISO y
      **no hay escrito de dónde salieron ni con qué permiso**
      (`design/fondos/manifiesto.tsv`, columna `licencia`: `SIN DETERMINAR` en
      las seis filas). Este proyecto publica la oferta de fuente de AutoFirma con
      cuatro repositorios y sus etiquetas; con ese listón, esto es un agujero de
      la misma familia. Las salidas son tres: que sean de Jorge y se declare bajo
      qué licencia se ceden, que sean de un banco con licencia libre y se cite, o
      que se sustituyan.
      *Hecha cuando:* las seis filas tienen `licencia` y `origen`, y lo que diga
      la columna está también en `debian/copyright` de `encina-branding`.

- [ ] **La identidad, como decisión D en `ENCINA-OS.md`.** El texto ya está
      escrito en `design/identidad.md` y `design/paleta.md`; lo que falta es que
      sea una decisión con su motivo, en el sitio donde este proyecto guarda las
      decisiones, para que no se vuelva a discutir sin motivo nuevo.
      *Hecha cuando:* es una fila D que dice para quién es, qué transmite y **qué
      no debe parecer** — con los tres nombres: Ubuntu, macOS y la Administración.

- [ ] **Los colores que faltan: error, aviso, correcto y el texto.** Cinco
      colores de marca sirven para un banner; un sistema operativo necesita más.
      El de **error** es el que más falta hace y el que ninguna paleta de marca
      trae, porque en un banner no hay errores y en este producto sí: un
      certificado caducado, una firma que no sale.
      *Y una incoherencia que hay que resolver de paso:* `identidad.png` declara
      «BLANCO ROTO — `#FFFFFF`», y `#FFFFFF` es blanco puro.
      *Hecha cuando:* `design/paleta.tsv` no tiene ninguna fila `SIN DECIDIR`, y
      el contraste del texto sobre el fondo está **comprobado con un número**, no
      mirado.

- [ ] **El tema base, elegido, anclado y con la licencia leída.** WhiteSur está
      descartado por R8 y el motivo está en [LEEME.md](LEEME.md).
      *Hecha cuando:* está escrito **qué tema, anclado a qué commit, con qué
      licencia, y por qué no los otros dos**.
      *Y una condición que ahorra la decisión entera:* esta casilla **se puede
      aplazar hasta después de [2-golpes-baratos.md](2-golpes-baratos.md)**. Si
      allí se confirma que el acento y los iconos dan el grueso del cambio, el
      tema GTK pasa a ser una guinda y se elige con capturas delante en vez de
      con una preferencia.
