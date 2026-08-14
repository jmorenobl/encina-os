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

- [x] ~~**Elegir el verde, ahora con las capturas delante.**~~ **ELEGIDO `sage`
      el 2026-08-14, decisión de Jorge —«el otro es muy llamativo»— y APLICADO en
      `encina-branding` 0.1.10**, junto con el dock abajo. Construido en
      `encina-dev` con `03-construir.sh` —**30 correctas, 0 fallos**, `lintian`
      sin una línea— e instalado en la máquina del producto; el después está en
      `design/capturas/despues/`.
      *Lo que hace el paquete, y por qué así:* `gtk-theme='Yaru-sage'` con su
      sección `:ubuntu`, y el tema de iconos `Encina` pasa a
      `Inherits=Yaru-sage,Yaru,hicolor` — **así las carpetas salen verdes sin
      enviar un solo icono**, y `Encina` sigue siendo el tema efectivo, que es lo
      que mantiene la bellota.
      *Y queda escrito lo que es, sin maquillar:* `sage` es **un verde prestado**.
      El de Encina, `#3A664E`, no está en la lista cerrada de Ubuntu y para
      tenerlo hay que forkear Yaru — [0-decidir.md](0-decidir.md).

- [x] ~~**El dock, abajo.**~~ **HECHO el 2026-08-14, decisión de Jorge.**
      `dock-position='BOTTOM'` y `extend-height=false` en la sección
      `[org.gnome.shell.extensions.dash-to-dock:ubuntu]`, que es **la única que
      hace algo**: `10_ubuntu-dock.gschema.override` fija `'LEFT'` ahí mismo y una
      sección genérica nuestra perdería. Misma trampa que le pasó al fondo en
      0.1.2 y al tema de iconos en 0.1.9, y esta vez se supo de antemano.
      *Flotante y no pegado al borde entero* para que se lea como una decisión y
      no como el mismo dock girado.

- [ ] **Actualizar `imagen/repo-manifiesto.tsv`, que ha quedado desfasado.** El
      manifiesto clava `encina-branding` **0.1.9** en `7c2390dd…` y el paquete va
      por **0.1.10**, así que hoy la ISO **no se puede fabricar**.
      *Y no se arregla pegando la huella del `.deb` que se construyó hoy:* ése
      salió de un `tar` del árbol de trabajo, no de `git archive HEAD`, que es la
      regla de §4.37d. La huella buena es la que produzca `construir-todo.sh`
      sobre el árbol versionado.
      *Hecha cuando:* `construir-todo.sh` pasa entero y **dos pasadas dan la
      misma huella de ISO**.

---

**El hito de este fichero, y es lo que decide el siguiente.** Cuando las tres
estén hechas, hay seis capturas nuevas contra las seis del «antes». Con eso
delante se contesta la pregunta que hoy es una hipótesis:

> ¿Cuánto queda por cambiar que sólo pueda cambiar un tema GTK?

Si la respuesta es «poco», [3-tema-e-iconos.md](3-tema-e-iconos.md) se reduce a
los iconos y el tema base no se empaqueta. **Esa respuesta se escribe aquí**, con
las capturas al lado, antes de abrir el fichero siguiente.
