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

- [x] ~~**QUITAR LA PANTALLA QUE DICE «Le damos la bienvenida a Ubuntu 24.04.4
      LTS».**~~ **HECHO el 2026-08-15 en `encina-branding` 0.1.11**, mirado en
      pantalla sobre `encina-95758c9e`: una sesión nueva entra directa al
      escritorio y la ventana no aparece
      (`design/capturas/despues/06-primera-sesion-sin-bienvenida.png`), con el
      resto de la primera sesión igual —fondo, dock abajo, bellota—.
      *Y esta casilla se equivocaba en el diagnóstico, que es lo que hay que
      guardar:* decía «es un paquete que sobra o **una clave** que lo
      desactiva». **No hay ninguna clave y el paquete no sobra.** Lo que la
      lanza es una **unidad de usuario de systemd**,
      `gnome-initial-setup-first-login.service`, enlazada desde
      `gnome-session.target.wants/`; el `.desktop` de `/etc/xdg/autostart/`
      —donde uno mira primero— lleva `X-GNOME-HiddenUnderSystemd=true` y **no
      es el que decide**.
      *Por qué volvía en cada sesión:* su puerta es
      `~/.config/gnome-initial-setup-done`, que sólo se escribe si el asistente
      se **termina**. Y como es del usuario, ponerlo por defecto sería
      `/etc/skel` y lo prohíbe R1: por eso se ataca la unidad y no la puerta.
      *Lo que hace el paquete:*
      `/etc/systemd/user/gnome-initial-setup-first-login.service -> /dev/null`.
      `/etc/systemd/user` gana a `/usr/lib/systemd/user`, así que no se
      sobrescribe nada de `gnome-initial-setup` (R5) y la purga lo retira.
      *Los controles, que son tres y están en `MEDICIONES.md` §4.44:* la ventana
      **sí** salía en la sesión de antes de instalar (`static`); la máscara pasa
      a `masked` y al purgar vuelve a `static`; y el marcador
      `gnome-initial-setup-done` **sigue sin existir** después de todo, así que
      la ventana falta por la máscara y no porque el asistente se completara.
      *Y la decisión que acompañaba, tomada:* **en su sitio no va nada**
      —decisión de Jorge—. La primera impresión pasa a ser el escritorio de
      Encina. La pantalla propia que cuente el producto sigue **abierta como
      decisión** en [0-decidir.md](0-decidir.md), no descartada.

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

- [x] ~~**Actualizar `imagen/repo-manifiesto.tsv`, que ha quedado desfasado.**~~
      **HECHO el 2026-08-15, y con la ISO fabricada dos veces:**
      `1224b5b17b559007…`, **3 715 366 912 bytes las dos**, `cmp` idénticas byte
      a byte, y el control de que la comparación sabe decir «distintas» es la ISO
      anterior (`ac0a5721…`), otros bytes y otra huella.
      *La huella salió de donde tenía que salir:* `fe5e87b0…`, **6 165 162
      bytes**, construida sobre `git archive HEAD`. El `.deb` que se instaló en
      la máquina del producto, salido de un `tar` del árbol de trabajo, pesaba
      **6 165 258** — 96 bytes de diferencia que son sólo fechas (§4.37).
      *Y no eran cuatro sitios, son cinco.* SCRIPTS.md dice cuatro
      —manifiesto, `H_BRANDING` y el nombre en `encina-seed.sh`, y el array
      `FICHEROS` de `fabricar-seed.sh` y de `fabricar-iso.sh`— y falta **el
      quinto: los dos `autoinstall*.yaml`**, que llevan el seed dentro en base64
      y hay que rehacerlos con `fabricar-seed.sh --actualizar-yaml`. No se
      descubrió leyendo: lo dijo `fabricar-iso.sh` con un `[FALLO]` que nombra la
      orden que lo arregla.
      *Y de regalo, un fallo del instrumento que sólo podía salir hoy:* el cotejo
      del árbol de `construir-todo.sh` usaba `find -type f` y **no veía los
      enlaces simbólicos**, así que dio `[FALLO]` sobre un árbol que había
      llegado entero — el primer enlace versionado del repositorio es justo la
      máscara de la casilla de arriba. Arreglado, y lo mismo en
      `comprobar-propios.sh`, que decía «ficheros: N» sin mencionarlo.
      *Lo que esta casilla NO dice:* que la ISO arranque. Eso es una VM desde
      cero y no se ha hecho con este medio.

---

**El hito de este fichero, y es lo que decide el siguiente.** Cuando las tres
estén hechas, hay seis capturas nuevas contra las seis del «antes». Con eso
delante se contesta la pregunta que hoy es una hipótesis:

> ¿Cuánto queda por cambiar que sólo pueda cambiar un tema GTK?

Si la respuesta es «poco», [3-tema-e-iconos.md](3-tema-e-iconos.md) se reduce a
los iconos y el tema base no se empaqueta. **Esa respuesta se escribe aquí**, con
las capturas al lado, antes de abrir el fichero siguiente.
