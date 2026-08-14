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
      *Enmienda del 2026-08-15, y son DOS cosas distintas:* **(a)** las dos filas
      del fondo por defecto salen de la casilla —maestro propio de Jorge,
      `EUPL-1.2` en el manifiesto y en `debian/copyright`, que es la primera de
      las tres salidas—, así que quedan **cuatro**. **(b)** De las cuatro que
      quedan resulta que **la premisa de esta casilla era falsa desde el
      principio**: no es verdad que no haya escrito de dónde salieron.
      `debian/copyright` las declara **desde el 2026-08-08** —Amanda Anusane,
      Unsplash License, con su párrafo DEP-5 y su advertencia de que la Unsplash
      License no cumple las DFSG— y `DIARIO.md` lo cuenta ese mismo día. Lo que
      hay no es un agujero de licencia: es **el manifiesto desactualizado
      respecto de lo que viaja dentro del `.deb`**. No se ha tocado aquí porque
      la casilla es de Jorge y conviene mirar cuál de los dos manda antes de
      copiar nada de uno a otro.

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

- [ ] **Si hay fork de Yaru: dónde vive, y cómo no lo pisa un `apt upgrade`.**
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
