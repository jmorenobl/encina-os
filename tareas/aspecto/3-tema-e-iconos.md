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

- [ ] **El logotipo de la rejilla, que sigue abierta desde el bloque 1.** Hoy el
      botón lleva el de Ubuntu. Lo que ya se descartó con dato: el tema efectivo
      **es `Encina`**, y el resolvedor de GTK 4 devuelve el fichero de Encina para
      `view-app-grid-ubuntu-symbolic`, que es el nombre que el dock construye de
      verdad —no `view-app-grid-symbolic`, que era lo que parecía—. **Y el botón
      sigue con el de Ubuntu.** O sea: el dibujo no es el problema.
      *Lo que falta por medir, y está en §4.43h:* a **48 px**, el `sessionMode`
      leído dentro del shell, y si el `St` del shell usa **otra cadena de temas**
      que la `Gtk.IconTheme` con la que se midió. Esa tercera es la sospecha
      buena: el shell no pinta sus iconos con GTK.
      *Hecha cuando:* lleva la encina, mirado en pantalla tras un reinicio
      completo, y el resto del escritorio no ha cambiado.
      *Y al cerrarla:* redibujar el símbolo desde `design/logotipo/encina.svg`,
      porque hoy no comparten silueta y son el mismo árbol.

- [ ] **El límite de libadwaita, declarado.** En GNOME 46, Archivos, Ajustes, el
      Centro de aplicaciones y el visor de imágenes **ignoran el tema GTK3**.
      *Hecha cuando:* la captura 6 —GTK4 y GTK3 lado a lado— está tomada con el
      tema puesto, y está escrito **qué no cambia y por qué**. No es un defecto:
      es un límite, y en este proyecto los límites se escriben con la forma de D9,
      leídos hasta el final, no se ocultan.
