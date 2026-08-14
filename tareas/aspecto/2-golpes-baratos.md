# 2 — Los golpes baratos, medidos primero

Tres cambios que cuestan una línea de `gschema.override` cada uno, no rozan R5 y
**pueden dar el grueso del cambio de cara**. Si es así, la decisión del tema base
deja de ser urgente.

**La trampa que se paga en los tres, y ya está medida:** GSettings admite
overrides **por escritorio**, y una sección `[esquema:escritorio]` gana a la
genérica **sea cual sea el número del fichero**. Ubuntu define sus valores en
`[…:ubuntu]` y la sesión corre con `XDG_CURRENT_DESKTOP=ubuntu:GNOME`. Sin
duplicar la variante `:ubuntu`, el valor de Ubuntu gana siempre por muy alto que
sea el 99 del nombre. Y es especialmente traicionero porque **`gsettings get`
desde una terminal devuelve el valor de Encina y parece que todo está bien**.
Está explicado entero dentro del propio `99-encina-branding.gschema.override`.

- [ ] **QUITAR LA PANTALLA QUE DICE «Le damos la bienvenida a Ubuntu 24.04.4
      LTS». Es la primera de la lista y no estaba en ninguna.** Medido el
      2026-08-14 al entrar por primera vez en `encina-95758c9e`
      (`design/capturas/antes/04-bienvenida-dice-ubuntu.png`): nada más iniciar
      sesión sale `gnome-initial-setup` **a pantalla completa**, con la corona
      naranja de Ubuntu, el texto en español y un botón «Siguiente» naranja.
      **Todo el trabajo de marca se lo pasa por delante esta ventana**: el fondo,
      el logotipo de GDM, el tema de iconos y `GRUB_DISTRIBUTOR` los ve alguien
      que ya está dentro; esto lo ve **antes que nada**, y es lo único que un
      desconocido lee palabra por palabra.
      *Por qué está entre los baratos:* no es un tema ni un icono. Es un paquete
      que sobra o una clave que lo desactiva, así que cuesta una línea — hay que
      medir cuál de las dos, y si quitarlo se lleva algo por delante.
      *Hecha cuando:* una sesión nueva **no** enseña esa ventana, mirado en
      pantalla, con el control de que el resto de la primera sesión sigue igual.
      *Y una decisión que hay que tomar de paso, no dejarla caer:* si en su sitio
      va **una pantalla propia** que diga qué es Encina OS y qué trae, o si no va
      nada. Lo segundo es defendible y más barato; lo primero es la única
      oportunidad de contar el producto.

- [ ] **El acento, que resultó no ser un color sino un NOMBRE DE TEMA.** Medido
      el 2026-08-14 en `encina-dev` por `ssh`, y las tres preguntas que traía esta
      casilla están contestadas:
      **(a) NO existe la clave `accent-color`** en Ubuntu 24.04 —`gsettings list-keys
      org.gnome.desktop.interface` no la tiene, y pedirla da «No existe la clave»—.
      La hipótesis de esta casilla era falsa. Lo que hace el selector de Ajustes es
      cambiar **`gtk-theme` e `icon-theme` a `Yaru-<acento>`**.
      **(b) La lista es cerrada: diez variantes**, y las cuatro verdes son
      `viridian #03875B`, `sage #657B69`, `olive #4B8501` y
      `prussiangreen #308280`. El de Encina es `#3A664E`, y **no está**.
      **(c) Sí arrastra las carpetas.** `Yaru-viridian` hereda de `Yaru` y trae
      **469 ficheros propios**; `48x48/places/folder.png` tiene md5 distinto en
      las cuatro variantes. Y arrastra **también GTK4**: cada variante trae
      `gtk-4.0/gtk.css`, con `libadwaita 1.5.0-1ubuntu2`.
      *Lo que NO arrastra:* el tema del shell. Hay **uno solo**
      (`/usr/share/gnome-shell/theme/Yaru/`), sin variantes de acento, así que la
      barra superior y el resumen no cambian.
      **EL GOLPE BARATO EXISTE Y CUESTA DOS LÍNEAS:** poner `gtk-theme` e
      `icon-theme` a un verde de los que **ya viajan en la máquina** —los diez
      vienen dentro de `yaru-theme-gtk` y `yaru-theme-icon`, no hay paquete nuevo,
      ni `.deb`, ni fila en el manifiesto—.
      *Hecha cuando:* la captura del escritorio y la de Archivos salen verdes, **y
      el control es la misma captura con `Yaru` por defecto**. Dos capturas, no
      una. Y antes, comprobar que las variantes están en `encina-95758c9e` y no
      sólo en el constructor.

- [ ] **Elegir el verde prestado, y decidir si el fork merece la pena.** Ahora es
      una pregunta con números y no una preferencia. Distancia RGB a `#3A664E`:
      **sage 55**, prussiangreen 58, viridian 65, olive 85. Por carácter, `sage`
      es el más parecido —verde apagado, como el nuestro— aunque más claro;
      `viridian` es esmeralda y se ve mucho más.
      *La pregunta que hay que contestar mirando las capturas, no antes:* ¿merece
      un repositorio aparte, una CI y un rebase con cada Yaru nuevo **la
      diferencia entre `sage` y `#3A664E`**? Si al verlo no se distingue, el fork
      es coste recurrente por una diferencia invisible.
      *Hecha cuando:* está elegido cuál se usa, con la captura al lado, y escrito
      si se forkea o no **y por qué**.

- [ ] **La tipografía.** Es el cambio con más efecto y menos riesgo de todo el
      bloque: la letra es lo que más grita «Ubuntu» del escritorio, más que el
      naranja, porque el naranja se ve y la letra se lee sin mirarla. Los
      criterios y las candidatas están en `design/tipografia.md`, y el primer
      criterio descarta solo: **si no está empaquetada en el archivo de Ubuntu,
      no entra**.
      *Hecha cuando:* la fuente elegida viaja como `.deb` **con su huella en
      `imagen/repo-manifiesto.tsv`**, el override la fija con su sección
      `:ubuntu`, y se ve en la captura. Con el control de la comprobación
      medida: `XDG_CURRENT_DESKTOP=ubuntu:GNOME gsettings get …` dice la nueva.

- [ ] **Los fondos, revisados.** Ya hay seis puestos y funcionan. Lo que falta es
      mirarlos con la identidad delante: si el par claro/oscuro se lee como dos
      variantes del mismo sitio, y si el de GDM es el que debe.
      *Hecha cuando:* está decidido cuál es el de fábrica y por qué, y las
      capturas 3 y 4 lo enseñan.
      *Y un dato que ya está y ahorra la mitad del trabajo:* `caliza.jpg` es el
      maestro de los dos que se ven, y `encina-dark.jpg` es el mismo recorte
      oscurecido — o sea que el par ya es coherente por construcción.

---

**El hito de este fichero, y es lo que decide el siguiente.** Cuando las tres
estén hechas, hay seis capturas nuevas contra las seis del «antes». Con eso
delante se contesta la pregunta que hoy es una hipótesis:

> ¿Cuánto queda por cambiar que sólo pueda cambiar un tema GTK?

Si la respuesta es «poco», [3-tema-e-iconos.md](3-tema-e-iconos.md) se reduce a
los iconos y el tema base no se empaqueta. **Esa respuesta se escribe aquí**, con
las capturas al lado, antes de abrir el fichero siguiente.
