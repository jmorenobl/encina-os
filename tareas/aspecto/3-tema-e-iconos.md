# 3 — El tema y los iconos

**No se abre hasta que [2-golpes-baratos.md](2-golpes-baratos.md) haya contestado
cuánto queda por cambiar.** Si la respuesta es «poco», de este fichero sólo se
hacen los iconos y el límite declarado.

- [ ] **El tema base, empaquetado como `encina-theme`** desde fuente anclada por
      commit y `sha256`, con su `debian/copyright`. No entra por una vía distinta
      a la de los otros 28: entra como paquete, con manifiesto y con huella.
      *Hecha cuando:* se construye desde el clon, `lintian` no dice una línea, y
      **dos pasadas dan la misma huella**. Es el estándar que ya rige, no uno
      nuevo — y ojo con lo que costó descubrirlo: `dpkg-deb` deja pasar los mtimes
      **anteriores** a `SOURCE_DATE_EPOCH`, así que la fecha que un fichero tenga
      en el disco viaja dentro del `.deb` y no está en git.

- [ ] **Aplicado por `gschema.override`, con su sección `:ubuntu`.** La trampa
      está explicada en [2-golpes-baratos.md](2-golpes-baratos.md) y dentro del
      propio fichero de overrides.
      *Hecha cuando:* medido con `XDG_CURRENT_DESKTOP=ubuntu:GNOME` **y** visto en
      pantalla. Lo primero solo no demuestra nada.

- [ ] **El tema del shell**, que no se aplica con un `gsettings` a secas: hace
      falta la extensión `user-theme` **habilitada por dconf** — nunca por
      `/etc/skel`, R1, que sólo alcanza a los usuarios creados después y no se
      puede actualizar.
      *Hecha cuando:* la barra superior sale distinta en la captura 4, y un
      usuario **creado después de instalar** la ve igual. Ese segundo control es
      el que distingue un override de un `/etc/skel` disfrazado.

- [ ] **Los iconos.** El tema `Encina` ya existe, hereda de Yaru y no pisa nada
      (R5). Aquí cambia de padre si el tema base trae iconos, y añade lo propio:
      **las carpetas** —que es lo que más se ve— y la rejilla.
      *Hecha cuando:* `folder` resuelve al nuestro **y otro icono cualquiera sigue
      saliendo del padre** — el control que ya se usó en §4.43d, y que es lo único
      que demuestra que se sustituye lo declarado y nada más.

- [x] ~~**El logotipo de la rejilla, que sigue abierta desde el bloque 1.**~~
      **CERRADA el 2026-08-14, y estaba mal leída desde el principio: el botón
      NUNCA llevó el logotipo de Ubuntu — lleva la bellota, y la lleva desde
      0.1.9.** La prueba está en `design/capturas/despues/05-rejilla-bellota.png`:
      con la rejilla abierta, **la bellota sale iluminada**, que es lo que
      distingue el botón de aplicaciones de cualquier otro icono del dock.
      *Qué se estaba mirando entonces:* el **icono naranja de Ubuntu que está en
      mitad del dock**, que no es un botón — es `gnome-initial-setup`
      ejecutándose, o sea la propia pantalla de bienvenida. Sale en todas las
      capturas de `design/capturas/antes/`, justo donde el ojo lo busca.
      *Y por qué no se vio antes, que es lo que lo explica y no es una excusa:*
      hasta el 2026-08-14 la ventana de UTM medía 2560×1410 y **el fondo del dock
      quedaba fuera de la captura**. El botón de la rejilla es el último de la
      fila y sencillamente no salía. Con el dock abajo sale entero.
      *Lo que esto deja en pie:* el trabajo de §4.43 —tema propio que hereda de
      Yaru y no pisa nada (R5), y el nombre `view-app-grid-ubuntu-symbolic` que
      el dock construye de verdad— **estaba bien y funcionaba**. Lo que fallaba
      era dónde se miraba. Las tres medidas que §4.43h dejó pendientes ya no hacen
      falta.

- [ ] **El límite de libadwaita, declarado.** En GNOME 46, Archivos, Ajustes, el
      Centro de aplicaciones y el visor de imágenes **ignoran el tema GTK3**.
      *Primer dato, del 2026-08-14* (`design/capturas/antes/06-archivos-gtk4.png`):
      Archivos sale **en claro mientras el shell va en oscuro**, y **sus carpetas
      son las de Yaru**, en berenjena. Ahí un tema GTK3 no pinta nada; lo que sí
      cambiaría el color de esas carpetas es **el acento**. Es un argumento más
      para no comprar tema hasta medir
      [2-golpes-baratos.md](2-golpes-baratos.md).
      *Hecha cuando:* la captura 6 —GTK4 y GTK3 lado a lado— está tomada con el
      tema puesto, y está escrito **qué no cambia y por qué**. No es un defecto:
      es un límite, y en este proyecto los límites se escriben con la forma de D9,
      leídos hasta el final, no se ocultan.
