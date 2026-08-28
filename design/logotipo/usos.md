# El logotipo

El maestro es [encina.svg](encina.svg): una encina cuya copa y raíces son una red
de nodos. La copa es un racimo de círculos del mismo color y sin borde, para que
al solaparse se lean como una silueta lobulada — que es lo que hace que siga
siendo reconocible a 16 px, cuando la malla interior ya no se distingue.

Colores: acento `#3A664E` y arcilla `#D6BFA0`, de [../paleta.tsv](../paleta.tsv).

## Dónde acaba cada versión

| Se genera | Dónde vive | Qué lo pide |
|---|---|---|
| `encina-logo.svg` | `src/usr/share/icons/hicolor/scalable/apps/` | el icono de aplicación del sistema |
| `logo.png` 200×200 | `src/usr/share/backgrounds/encina/` | GDM (`org/gnome/login-screen` `logo`) y Plymouth |

`logo.png` **tiene que llevar canal alfa**. Sin transparencia sale con un
recuadro opaco encima del arranque, y `generar-activos.sh` ya lo comprueba.

## Reglas de uso

- **Tamaño mínimo del símbolo solo: 16 px.** Por debajo, la malla se convierte en
  ruido. Si hace falta más pequeño, se dibuja una versión sin malla — no se
  reduce ésta.
- **Aire alrededor: la altura de un lóbulo de la copa** por cada lado. El
  logotipo apretado contra un borde parece un error de maquetación.
- **Sobre fondo oscuro se usa tal cual**; el verde `#3A664E` aguanta. Sobre fondo
  verde no se usa nunca: se pierde.
- **No se reencuadra, no se estira, no se le cambia el color** para que pegue con
  algo. Si no pega, lo que se cambia es el algo.

## Lo que falta

- **Las dos variantes que `identidad.png` ya enseña y que no existen como
  fichero:** el símbolo suelto y el horizontal con «ENCINA OS» al lado. Hoy solo
  hay el símbolo completo.
- **La versión monocroma para la rejilla de aplicaciones**, que es un icono
  simbólico y va en `currentColor`, no en verde. Está en
  [../iconos/](../iconos/), y su casilla sigue abierta.
