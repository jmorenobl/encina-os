# El después: `encina-branding` 0.1.10, 0.1.11 y 0.1.15

**2026-08-14, sobre `encina-95758c9e`, arrancada desde frío con el paquete
instalado.** Tres decisiones de Jorge, aplicadas por el paquete y no a mano.
**Las dos últimas filas son del 2026-08-15 y son de la 0.1.11.**

| Fichero | Qué enseña |
|---|---|
| `03-gdm.png` | El saludador |
| `04-escritorio-dock-abajo.png` | El escritorio: **dock abajo y flotante**, botón «Siguiente» en salvia |
| `05-rejilla-bellota.png` | La rejilla abierta, **con la bellota iluminada** |
| `06-control-la-bienvenida-vuelve.png` | **EL CONTROL, y se tomó primero:** sesión recién abierta con 0.1.10, y la bienvenida de Ubuntu vuelve a salir entera |
| `06-primera-sesion-sin-bienvenida.png` | La misma máquina con 0.1.11 y reiniciada: **la sesión entra directa al escritorio** |
| `07-icono-tienda-aplicaciones.png` | **2026-08-15, `encina-dev` con 0.1.15**: el Centro de aplicaciones con **el icono de Encina** en el dock, donde estaba la «A» naranja |

## Lo que cambió

- **El dock está abajo y flotante** (`dock-position='BOTTOM'`,
  `extend-height=false`), y no ocupa el borde entero: se lee como una decisión y
  no como el mismo dock girado.
- **El acento es `Yaru-sage`**: el botón «Siguiente» de la bienvenida —una
  aplicación GTK4/libadwaita— ya no es naranja.
- **El fondo sigue siendo el de `caliza`**, que es lo que ya funcionaba.

## Y una casilla que se cierra, porque estaba mal leída

**El botón de la rejilla NO lleva el logotipo de Ubuntu: lleva la bellota, y la
lleva desde 0.1.9.** En `05-rejilla-bellota.png` se ve **iluminada** con la
rejilla abierta, que es la prueba de que es el botón de aplicaciones y no otra
cosa.

Lo que `MEDICIONES.md` §4.43 dio por «el botón sigue con el logotipo de Ubuntu»
es, casi con seguridad, **el icono naranja de Ubuntu que está en mitad del
dock** — y que no es un botón: es `gnome-initial-setup` **ejecutándose**, o sea
la propia pantalla de bienvenida. Está en todas las capturas de `../antes/`,
justo donde el ojo lo busca.

*Y por qué no se vio antes, que es lo que lo explica:* hasta esta pasada la
ventana de UTM medía 2560×1410 y **el fondo del dock quedaba fuera de la
captura**. El botón de la rejilla es el último de la fila, y sencillamente no
salía. Con el dock abajo, sale entero.

O sea que el trabajo de §4.43 —el tema propio que hereda y no pisa nada— estaba
bien y funcionaba. Lo que fallaba era dónde se miraba.

## Y la bienvenida de Ubuntu, fuera (0.1.11, 2026-08-15)

**Ya no sale.** Lo que la lanzaba no era una clave sino la unidad de usuario
`gnome-initial-setup-first-login.service`, y 0.1.11 la enmascara desde
`/etc/systemd/user/`. Las dos capturas van juntas a propósito: sin el control
—la misma máquina enseñándola una hora antes— la otra no demuestra nada.
Mecanismo y controles en `MEDICIONES.md` §4.44.

*Y de paso se ve confirmado lo de arriba:* el icono naranja de Ubuntu que estaba
en mitad del dock **ha desaparecido con la ventana**, porque era ella
ejecutándose y no ningún botón.

## El Centro de aplicaciones ya no dice Ubuntu (0.1.15, 2026-08-15)

`07-icono-tienda-aplicaciones.png` es el `[OJOS]` que cierra `D21`: en el dock,
entre Archivos y el «?», está **la bolsa verde de Encina** donde estaba la «A»
naranja. Es el banco —`encina-dev`—, **no** la máquina del producto, que sigue
con 0.1.13.

**Y esta captura tiene una historia que conviene no perder** (`MEDICIONES.md`
§4.49): con **0.1.14** ahí había un **hueco**, con las cinco comprobaciones
automáticas en verde. `gdk-pixbuf` no reconoce un SVG cuyo `<svg` caiga más allá
del **byte 256**, y el comentario de cabecera lo empujaba al 2090. *Sin mirar la
pantalla, aquel paquete se habría dado por bueno.*

## Lo que sigue igual, y ya se sabía
- **El icono de ayuda es el azul de Ubuntu**, y se queda así a propósito: lo que
  abre es `ubuntu-docs`, titulado «Guía del escritorio de Ubuntu», así que
  repintarlo compra casi nada (§4.47g).
- **La barra superior no cambia**: el tema del shell no tiene variantes.
