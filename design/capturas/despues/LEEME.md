# El después: `encina-branding` 0.1.10

**2026-08-14, sobre `encina-95758c9e`, arrancada desde frío con el paquete
instalado.** Tres decisiones de Jorge, aplicadas por el paquete y no a mano.

| Fichero | Qué enseña |
|---|---|
| `03-gdm.png` | El saludador |
| `04-escritorio-dock-abajo.png` | El escritorio: **dock abajo y flotante**, botón «Siguiente» en salvia |
| `05-rejilla-bellota.png` | La rejilla abierta, **con la bellota iluminada** |

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

## Lo que sigue igual, y ya se sabía

- **La pantalla de bienvenida sigue diciendo «Le damos la bienvenida a Ubuntu
  24.04.4 LTS»**, y vuelve a salir en cada sesión. Es la primera casilla de
  `../../../tareas/aspecto/2-golpes-baratos.md`.
- **El Centro de aplicaciones sigue con su «A» naranja** y el icono de ayuda es
  el azul de Ubuntu: son iconos de aplicación, no acento.
- **La barra superior no cambia**: el tema del shell no tiene variantes.
