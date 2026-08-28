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

- [x] ~~**El acento, que resultó no ser un color sino un NOMBRE DE TEMA.**~~
      **CERRADA el 2026-08-15 con la evidencia delante**, que estaba tomada
      desde el 2026-08-14 y sin marcar. Las tres preguntas de abajo siguen
      contestadas tal cual; lo que faltaba era enseñarlo.
      *Las capturas, y su control:* `../../design/capturas/acento/archivos-sage.png`
      —carpetas verdes— contra `../../design/capturas/antes/06-archivos-gtk4.png`
      —carpetas berenjena—, **la misma ventana, la misma carpeta y la misma
      máquina** (`encina-95758c9e`, 13:52 y 15:36 del mismo día). Y con la
      variante `viridian` al lado, `archivos-viridian.png`, que es lo que
      permitió elegir.
      *La precondición, cumplida y no supuesta:* las dos órdenes `gsettings` se
      lanzaron **sobre `encina-95758c9e`**, no sobre el constructor, y
      funcionaron en caliente sin reiniciar la sesión — o sea que las diez
      variantes ya viajan en la máquina del producto.
      *El control que salió gratis, y vale doble:* al resetear, `gtk-theme`
      vuelve a `'Yaru'` pero `icon-theme` vuelve a **`'Encina'`**, no a `Yaru`.
      El `gschema.override` del paquete está vivo y gana cuando el usuario no
      tiene valor propio (`reseteado-y-control.png`).
      *Y LO QUE ESTA CASILLA NO ENSEÑA, dicho aquí y no en letra pequeña:* pedía
      **también la captura del escritorio con su control**, y ese par **no
      existe**. Hay escritorio en verde —`../../design/capturas/fondo-0.1.13/3-escritorio-claro.png`,
      con la «Carpeta personal» en el verde del acento— pero **no hay ningún
      escritorio con `Yaru` por defecto** con el que contrastarlo: en `antes/` no
      se tomó, y todo lo de `despues/` y `fondo-0.1.1x/` es ya posterior a la
      0.1.10, que es donde entró `sage`. Lo que iba a ser esa captura,
      `despues/04-escritorio-dock-abajo.png`, es la ventana de bienvenida
      tapando el escritorio entero. **Se cierra igual porque el par que decide es
      el de Archivos** —en un escritorio desnudo el acento sólo toca el icono de
      la carpeta—, pero el hueco queda escrito: si algún día se quiere el par
      completo, cuesta arrancar la máquina, dos `gsettings` y una captura.

      *Y lo que se midió el 2026-08-14 en `encina-dev` por `ssh`, que es lo que
      esta casilla traía como tres preguntas y quedan contestadas:*
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
      *Lo que esta casilla pedía para darse por hecha, y se conserva porque es
      contra lo que se ha comprobado:* «la captura del escritorio y la de
      Archivos salen verdes, **y el control es la misma captura con `Yaru` por
      defecto**. Dos capturas, no una. Y antes, comprobar que las variantes están
      en `encina-95758c9e` y no sólo en el constructor».

- [x] ~~**Elegir el verde, ahora con las capturas delante.**~~ **ELEGIDO `sage`
      el 2026-08-14, decisión de Jorge —«el otro es muy llamativo»— y APLICADO en
      `encina-branding` 0.1.10**, junto con el dock abajo. Construido en
      `encina-dev` con `construir-branding.sh` —**30 correctas, 0 fallos**, `lintian`
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

---

## LA RESPUESTA, escrita el 2026-08-15 con las capturas delante

**Las cinco casillas están hechas.** Y no son «seis capturas contra seis»: el
«antes» son 7 —una de ellas, `reconocimiento-firmware-…`, de otra pasada— y el
«después» llegó en tres tandas, `despues/` (5), `acento/` (3) y
`fondo-0.1.13/` (5). Se dice así y no se cuadra el número, porque las tandas
responden a preguntas distintas y forzarlas a una tabla de seis filas sería
maquillaje.

**La respuesta corta: queda poco, y casi nada de lo que queda lo arregla un tema
GTK.** Desglosado, que es lo que sirve:

| Lo que sigue siendo de Ubuntu | ¿Lo arregla un tema GTK? |
|---|---|
| **El acento no es el de Encina.** `#3A664E` no está en la lista cerrada de diez, y `sage` es un verde prestado que «pasa por gris» | **Sí, y es lo único.** Pero no es un tema nuevo: es **una variante más** dentro de Yaru, que es la escala a la que Yaru ya está construido |
| **La barra superior y el resumen** siguen igual | **No.** Es el tema del **shell**, y hay uno solo, `/usr/share/gnome-shell/theme/Yaru/`, sin variantes de acento. Otro artefacto, otra tarea |
| **El dock**: la «A» naranja del Centro de aplicaciones, el «?» de ayuda, el logo de Ubuntu de la rejilla | **No.** Son **iconos de aplicación**, no acento. Se ven en `fondo-0.1.13/3-escritorio-claro.png`, publicada ya en el README |
| **GDM**: el recuadro de selección naranja de Yaru, y el fondo que no llega | **No.** Es el perfil de GDM y su `dconf`; sospecha vieja, ahora con captura (`fondo-0.1.13/0-gdm.png`) |
| **El firmware dice «Ubuntu» dos veces** y no hay menú de GRUB | **No.** Es la NVRAM y la ruta del `shim`: ni tema ni `GRUB_DISTRIBUTOR` |
| **Plymouth no se ha visto NUNCA** —del segundo 9 al 20 la pantalla está apagada— | **No**, y además no es un problema de aspecto sino de si el tema llega a verse |

**Lo que esto decide, que era el objeto del hito:**

1. **Un tema GTK de terceros no se empaqueta.** Ya estaba descartado por R8 y
   ahora además está medido que no compraría casi nada: lo que un tema GTK toca
   —ventanas, carpetas, botones, GTK4— **ya está verde** desde la 0.1.10, con
   dos líneas de `gschema.override` y sin un solo `.deb` nuevo.
2. **[3-tema-e-iconos.md](3-tema-e-iconos.md) se reduce**, que es lo que la
   hipótesis apostaba: **iconos de aplicación** —lo más visible que queda— y, si
   se quiere el verde propio, **una variante de acento**. El tema del shell y GDM
   son bloque aparte y van en [4-arranque-y-sesion.md](4-arranque-y-sesion.md).
3. **La decisión del fork de Yaru queda desbloqueada y madura**, que era su
   condición en [0-decidir.md](0-decidir.md): la medición del acento tenía que
   «decidir su tamaño», y lo ha decidido — **es añadir una variante, no
   rediseñar**. Sigue siendo decisión de Jorge si se paga; lo que ya no es, es
   una decisión a ciegas.

**Y lo que esta respuesta NO dice:** ninguna de estas capturas es una aprobación.
El `[OJOS]` de las de `fondo-0.1.13/` sigue sin dar, y el README ya las publica.
