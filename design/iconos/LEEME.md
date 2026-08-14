# Los iconos propios

Aquí viven los maestros de los iconos que el tema `Encina` **sustituye**. El
tema hereda del padre y sólo declara lo suyo: todo lo que no esté en este
directorio sale del padre y no se toca (R5).

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
