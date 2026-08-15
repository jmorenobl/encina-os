# 3 — El tema y los iconos

~~**No se abre hasta que [2-golpes-baratos.md](2-golpes-baratos.md) haya contestado
cuánto queda por cambiar.** Si la respuesta es «poco», de este fichero sólo se
hacen los iconos y el límite declarado.~~

**ABIERTO EL 2026-08-15, Y LA RESPUESTA FUE «POCO».** El hito de
[2-golpes-baratos.md](2-golpes-baratos.md) está escrito: de todo lo que sigue
siendo de Ubuntu, **lo único que arreglaría un tema es el acento** — y `D20`
decidió no forkear, así que **este fichero se queda en los iconos, el tema del
shell y el límite declarado**, tal como la condición de arriba anticipaba.

- [x] ~~**El tema base, empaquetado como `encina-theme`**~~ **CERRADA SIN OBJETO
      el 2026-08-15: `D20` dice que no se forkea Yaru y no hay tema base propio**,
      así que no hay nada que empaquetar, ni fuente que anclar, ni huella que
      medir. Se cierra porque su condición desapareció, **no porque se haya
      construido nada** — si `D20` se reabre, esta casilla vuelve entera.
      *Lo que decía, y su aviso sigue valiendo para cualquier paquete futuro:*
      entraba «desde fuente anclada por commit y `sha256`, con su
      `debian/copyright`», no por una vía distinta a la de los otros 28. Y el
      aviso: `dpkg-deb` deja pasar los mtimes **anteriores** a
      `SOURCE_DATE_EPOCH`, así que la fecha que un fichero tenga en el disco viaja
      dentro del `.deb` y no está en git — que es exactamente lo que volvió a
      morder el 2026-08-15 con 0.1.13 (§4.46).

- [x] ~~**Aplicado por `gschema.override`, con su sección `:ubuntu`.**~~ **HECHA
      el 2026-08-14 en `encina-branding` 0.1.10**, aunque para el tema prestado y
      no para uno propio: `gtk-theme='Yaru-sage'` con su sección `:ubuntu`, y el
      tema de iconos `Encina` heredando `Yaru-sage,Yaru,hicolor`.
      *Su «hecha cuando» pedía las dos cosas y las dos están:* medido con
      `XDG_CURRENT_DESKTOP` —la trampa de la variante `:ubuntu` se conocía de
      antemano y por eso se escribió la sección— **y visto en pantalla**, en
      `../../design/capturas/acento/archivos-sage.png` contra
      `../../design/capturas/antes/06-archivos-gtk4.png`.

- [ ] **El tema del shell**, que no se aplica con un `gsettings` a secas: hace
      falta la extensión `user-theme` **habilitada por dconf** — nunca por
      `/etc/skel`, R1, que sólo alcanza a los usuarios creados después y no se
      puede actualizar.
      *Hecha cuando:* la barra superior sale distinta en la captura 4, y un
      usuario **creado después de instalar** la ve igual. Ese segundo control es
      el que distingue un override de un `/etc/skel` disfrazado.

- [ ] **Los iconos. ES LA CASILLA VIVA DE ESTE FICHERO desde el 2026-08-15.** El
      tema `Encina` ya existe, hereda de Yaru y no pisa nada (R5). Aquí cambia de
      padre si el tema base trae iconos, y añade lo propio: **las carpetas** —que
      es lo que más se ve— y la rejilla.
      *Hecha cuando:* `folder` resuelve al nuestro **y otro icono cualquiera sigue
      saliendo del padre** — el control que ya se usó en §4.43d, y que es lo único
      que demuestra que se sustituye lo declarado y nada más.
      **Enmienda del 2026-08-15, y recorta la casilla a la mitad:** *las carpetas
      ya salen verdes y no hay que enviar ni un icono* — las trae `Yaru-sage` por
      herencia, medido en `../../design/capturas/acento/archivos-sage.png`, y la
      rejilla lleva la bellota desde 0.1.9 (casilla de abajo, cerrada el 14). Así
      que lo que queda **no son las carpetas: son los iconos de aplicación del
      dock** —la «A» naranja del Centro de aplicaciones y el «?» de ayuda—, que
      es lo más visible que sigue diciendo Ubuntu en el escritorio y que **ningún
      tema de iconos hereda**, porque son iconos que trae cada aplicación.
      *Y ahí hay una pregunta que hay que contestar antes de tocar nada, porque
      decide si esto es barato o roza R5:* sustituir el icono de una aplicación
      ajena desde el tema `Encina` **¿es declarar lo nuestro o pisar lo suyo?**
      **CONTESTADA MIDIENDO EL 2026-08-15 (§4.47), y era DOS preguntas: los dos
      iconos que quedaban no son el mismo caso.**
      *(1) El «?» de la Ayuda: es declarar lo nuestro, y no de milagro.* Su
      `.desktop` pide un **nombre** (`org.gnome.Yelp`), un tema que lo sirve no
      toca ningún fichero ajeno —R5 va de sobrescribir, y aquí no se sobrescribe
      nada—, y **no es una excepción que nos inventemos: el propio Ubuntu lo hace
      62 veces de 71**. Medido además que un tema hijo con un directorio de `apps`
      gana **a 48 px** para lo que declara y deja intacto todo lo demás, lo cual
      cierra de paso el hueco de §4.43h —aquello se había preguntado a 16 px—.
      *(2) La «A» naranja del Centro de aplicaciones: ni una cosa ni la otra,
      porque no hay por dónde.* Su `.desktop` **no pide un nombre: pide una ruta
      absoluta dentro del snap**, escrita por el propio snap en su `meta/gui` e
      idéntica en la revisión del producto (1271) y en la del banco (1391). El
      tema **no interviene** —ni el nuestro ni el de Ubuntu, con el control de que
      la misma función da el mismo fichero con los dos—, y el fichero vive en un
      squashfs de solo lectura que se sustituye entero en cada autorrefresco.
      *La única vía que existe para ésa, medida:* **sombrear el `.desktop`** en
      `/usr/share/applications`, que es lo que ya hace `encina-firefox-native`
      (§4.19). Y su precio, entero: congela las **55 traducciones** del `Name=` y
      las acciones del snap.
      *Y un dato que decide si el «?» compra algo:* lo que abre es `ubuntu-docs`,
      titulado **«Guía del escritorio de Ubuntu»**. Repintar el icono deja un
      icono de Encina delante de un documento que sigue diciendo Ubuntu.
      **LO QUE QUEDABA DE ESTA CASILLA YA NO ERA MEDIR SINO DECIDIR, Y ESTÁ
      DECIDIDO EL MISMO 2026-08-15, las dos mitades.** Lo que queda ahora es
      **dibujar un icono** y **verlo en pantalla**, que es otra clase de trabajo.
      *El «?»: DECIDIDO EL 2026-08-15 — se queda como está.* El «?» azul de Yaru
      no lleva marca de Ubuntu; lo que dice Ubuntu está **detrás** del icono, y
      repintarlo compra casi nada. Si algún día se reabre, lo que hace falta está
      medido: un SVG en `scalable/apps` con el nombre `org.gnome.Yelp` y un
      directorio nuevo en el `index.theme`.
      *La «A»: DECIDIDA EL 2026-08-15 por Jorge, y es `D21`: **se sombrea el
      `.desktop`**.* Con ella queda escrito el criterio general —cuando el icono
      de una aplicación ajena no es alcanzable desde el tema, se sombrea su
      `.desktop` y **nunca** se toca el fichero ajeno—, y su precio. **Esta
      casilla no se marca cuando el paquete lleve la sombra dentro: se marca
      cuando el icono esté dibujado y visto en pantalla**, que es `[OJOS]`.
      *Y va **montada en la siguiente versión de `encina-branding`
      que otra casilla ya tenga que pagar** —no en una suya—, porque el precio de
      tocar ese paquete no es el `.deb`: es el ritual de las siete cosas de
      `SCRIPTS.md`, que se paga **por vuelta y no por cambio** (el argumento de
      ENCINA-OS §7 para E4) y que **ahora mismo está a medias**: los dos
      `autoinstall*.yaml` siguen con la huella vieja.
      *Y dos correcciones al precio que se escribió arriba, medidas y no
      supuestas:* **las 55 traducciones no hay que copiarlas** —la ISO fija
      `locale=es_ES.UTF-8` (ENCINA-OS §7.7), así que basta `Name=Centro de
      aplicaciones` y la sombra se queda en seis líneas, como la de Firefox—, y
      **falta `TryExec=/snap/bin/snap-store`** o quitar la tienda deja un lanzador
      roto en la rejilla. Límite a declarar: quien cambie el idioma del sistema
      verá ese nombre en español.
      *Y una condición previa que no es de empaquetado:* ~~**el icono no existe**, y
      dibujarlo con la paleta en PROPUESTO es trabajo que puede haber que rehacer.~~
      **EL ICONO YA EXISTE, y esa condición previa era falsa** (2026-08-15,
      §4.48a). Un icono usa `acento`, `acento-profundo`, `arcilla` y `tierra`,
      **los cuatro VIGENTE**; lo que está en PROPUESTO son `papel`, los dos de
      texto y los seis semánticos, que son colores de **mensajes de estado** y no
      intervienen en un dibujo. La dependencia estaba escrita, no medida.
      **LO QUE ESTÁ HECHO, en `encina-branding` 0.1.14** (`131c464e…`): la sombra
      de seis líneas con `TryExec=` —y con `Name=App Center` más
      `Name[es]=Centro de aplicaciones`, que **rebaja el precio**: quien use otro
      idioma ve el nombre real en inglés en vez de uno en español que no eligió—,
      el `MimeType` copiado a propósito para no dejar los `.deb` sin manejador, y
      el icono `encina-centro-aplicaciones` **en `hicolor/scalable/apps`, no en el
      tema `Encina`**: ese nombre no lo declara ningún otro tema, así que no hay a
      quien ganarle y `hicolor` es el respaldo de todos —el icono sobrevive a que
      alguien cambie el tema de iconos, y no hay que tocar el `index.theme`—.
      *Medido en `encina-dev` con el control tomado ANTES de instalar:* con
      0.1.13 el `.desktop` que gana es el de snapd, `FileIcon`, ruta del snap con
      los dos temas; con 0.1.14 gana el nuestro, el icono pasa a `ThemedIcon` y
      resuelve a nuestro SVG **con `Encina` y con `Yaru-sage`**, mientras
      `Nautilus` y `yelp` siguen saliendo del padre, intactos.
      **Y LA CASILLA SIGUE SIN MARCARSE, que es lo que dice su propia condición:**
      falta **verlo en pantalla**. Todo lo medido es resolución de iconos, no
      píxeles pintados por GNOME Shell, y §4.43f es el recordatorio de la vez que
      esas dos cosas se separaron. `[OJOS]`.

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
      *Segundo dato, del 2026-08-14, y corrige la premisa de esta casilla:* **el
      acento SÍ alcanza libadwaita.** Cada variante `Yaru-<acento>` trae su propia
      `gtk-4.0/gtk.css`, y con `Yaru-sage` puesto **el botón «Siguiente» de la
      bienvenida deja de ser naranja** —y esa ventana es GTK4/libadwaita—. O sea
      que el límite no es «libadwaita ignora el tema», sino el más estrecho
      **«libadwaita ignora el tema GTK3, pero no el acento»**. La casilla sigue
      abierta porque lo que falta es **escribirlo con la forma de D9**, no
      medirlo.
      *Hecha cuando:* la captura 6 —GTK4 y GTK3 lado a lado— está tomada con el
      tema puesto, y está escrito **qué no cambia y por qué**. No es un defecto:
      es un límite, y en este proyecto los límites se escriben con la forma de D9,
      leídos hasta el final, no se ocultan.
