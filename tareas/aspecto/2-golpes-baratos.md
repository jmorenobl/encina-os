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

- [ ] **El acento. Ésta es la que más puede rendir y la que hay que medir
      primero.** Ubuntu 24.04 trae selector de color de acento, y su
      implementación **puede alcanzar a las aplicaciones GTK4/libadwaita**, que
      son las que un tema GTK3 no toca.
      *Lo primero que hay que averiguar, porque decide si la vía existe:* si el
      acento admite **un color propio** o sólo una **lista cerrada** de nombres.
      Si es cerrada, `#3A664E` no está en ella y hay que elegir el más cercano o
      descartar la vía.
      *Y la segunda mitad, que rendiría sola:* si el acento **arrastra el color
      de las carpetas de Yaru**. Si lo arrastra, medio tema de iconos se resuelve
      sin enviar un solo icono.
      *Hecha cuando:* la captura de Archivos con el acento puesto sale verde, **y
      el control es la misma captura con el acento por defecto**. Dos capturas, no
      una.

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
