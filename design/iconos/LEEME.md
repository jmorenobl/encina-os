# Los iconos propios

Aquí viven los maestros de los iconos propios. La mayoría son iconos que el
tema `Encina` **sustituye**: el tema hereda del padre y sólo declara lo suyo,
así que todo lo que no esté en este directorio sale del padre y no se toca
(R5). **Uno no es de ese tipo y conviene no confundirlo** — el del Centro de
aplicaciones, que va en `hicolor` y lo pide una sombra de `.desktop`.

## `encina-centro-aplicaciones.svg`

El icono del Centro de aplicaciones, desde `encina-branding` 0.1.14. Es `D21`.

**No va en el tema `Encina`, va en `hicolor/scalable/apps`**, y el motivo es
que aquí no hay a quién ganarle: ese nombre no lo declara ningún otro tema.
`hicolor` es el último de la cadena y por eso mismo el respaldo de **todos**
los temas, así que el icono sigue saliendo aunque alguien cambie el tema de
iconos. `MEDICIONES.md` §4.47(c) es lo que mide la otra situación —para
ganarle a un icono del padre sí hace falta declararlo en el tema, con su
directorio de `apps` en el `index.theme`—, y no es ésta.

**Y lo que hace falta entender antes de tocarlo:** a este icono el tema no
llega. Su `.desktop` declara una **ruta absoluta dentro del snap** y no un
nombre, así que `Gio` devuelve un `GFileIcon` y ningún tema interviene —ni el
nuestro ni el de Ubuntu, medido con el mismo `lookup_by_gicon` a 48 px—. Lo
que lo cambia es la **sombra del `.desktop`** que instala `encina-branding`, y
allí está escrito el criterio general.

*Del dibujo, lo que se aprendió mirándolo y no se deduce:* las primeras tres
variantes ponían la copa de la encina dentro de una bolsa de asa estrecha y
alta, y **a 48 px las tres se leían como un candado**. El asa se ensanchó y se
bajó, y el contenido pasó a ser una rejilla de cuatro aplicaciones. La bellota
no se usa aquí **a propósito**: es la del botón de la rejilla, y los dos
iconos viven en el mismo dock. Los descartes están en
[../iconos-borrador/](../iconos-borrador/).

## `view-app-grid-symbolic.svg`

El botón de la rejilla de aplicaciones del dock. Es un icono **simbólico**: va en
`currentColor`, monocromo, sin la malla y sin la paleta. El logotipo en verde no
sirve aquí.

**Este activo hace falta con cualquier tema base que se elija.** Ni Yaru, ni
Papirus, ni Colloid, ni ninguno traen una encina: es propio por narices.

### Lo que ya se sabe, y lo que no

`MEDICIONES.md` §4.43 dejó esto medido, y es contraintuitivo:

- **El dock no pide `view-app-grid-symbolic`.** Pide
  `view-app-grid-${Main.sessionMode.currentMode}-symbolic`, y el modo de la
  sesión es `ubuntu` — así que el nombre que hace falta es
  **`view-app-grid-ubuntu-symbolic`**. Un paquete con sólo el nombre genérico
  dentro se instala, no da ningún error **y no cambia nada**.
- Con `encina-branding` 0.1.9 puesto, el tema efectivo de la sesión **es
  `Encina`** y el resolvedor de GTK 4 devuelve el fichero de Encina para ese
  nombre. **Y el botón sigue enseñando el logotipo de Ubuntu**, mirado tras un
  reinicio completo.

O sea: el dibujo no es el problema. Lo que falta por medir está en §4.43h — a 48
px, el `sessionMode` leído dentro del shell, y si el `St` del shell usa otra
cadena de temas que la `Gtk.IconTheme` con la que se midió.

*Y un detalle del dibujo, aparte de eso:* el maestro de hoy no comparte silueta
con [../logotipo/encina.svg](../logotipo/encina.svg). Cuando la casilla se cierre,
hay que redibujarlo desde ella para que sean el mismo árbol.
