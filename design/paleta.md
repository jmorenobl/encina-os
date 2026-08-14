# La paleta

Los colores viven en [paleta.tsv](paleta.tsv), que es la fuente legible por un
guion. Aquí está el porqué de cada uno y lo que falta.

## Los que están, y qué papel hacen

| Papel | Nombre | Hex | Por qué |
|---|---|---|---|
| **acento** | verde encina | `#3A664E` | El único color que dice «Encina». Verde de hoja de encina en sombra: no es el verde de una farmacia ni el de una app de reciclaje |
| acento-profundo | verde profundo | `#2F4033` | El fondo sobre el que descansa todo lo oscuro. Ya está puesto como `primary-color` de los fondos |
| acento-claro | verde hoja | `#5B7553` | El extremo claro. Sale del degradado de `02-activos.sh` |
| tierra | tierra ibera | `#A78B75` | Lo cálido. Impide que el verde se lea como corporativo |
| arcilla | arcilla | `#D6BFA0` | La malla del logotipo. Es lo que hace legible la red sobre el verde |
| neutro | gris pizarra | `#E6E8E6` | El gris que no es azul |

**Un color, un papel.** El acento es `#3A664E` y no hay un segundo acento: en
cuanto hay dos, la pantalla deja de tener un sitio donde mira el ojo.

## Lo que falta, y no es un detalle

Cinco colores de marca sirven para un banner. **Un sistema operativo necesita
más**, y hasta que estén elegidos, el tema pondrá los suyos:

- **Un color de error.** Es el que más falta hace y el que ninguna paleta de
  marca trae, porque en un banner no hay errores. En este producto sí: un
  certificado caducado, una firma que no sale.
- **Un color de aviso** y **uno de correcto**. El de correcto es probablemente el
  propio acento, pero eso hay que decidirlo, no darlo por hecho.
- **El texto**, claro y oscuro, con su contraste comprobado y no supuesto.

## Una incoherencia que hay que resolver

`identidad.png` declara **«BLANCO ROTO — #FFFFFF»**. `#FFFFFF` es blanco puro:
un blanco roto es otra cosa. O el nombre está mal o el hex está mal, y hasta que
se decida cuál, la fila está como `SIN DECIDIR` en el TSV.

No es cosmético: si el papel de ese color es «el fondo de una ventana clara»,
`#FFFFFF` contra `#E6E8E6` da un escritorio que parece dos escritorios.

## Y el acento tiene una vía barata que hay que medir antes de nada

Ubuntu 24.04 trae selector de color de acento, y su implementación **alcanza a
las aplicaciones GTK4/libadwaita**, que son las que un tema GTK3 no toca. Si eso
se confirma, media identidad se aplica con una línea de `gschema.override` y sin
rozar R5.

**Está sin medir.** Es la primera casilla de
[../tareas/aspecto/2-golpes-baratos.md](../tareas/aspecto/2-golpes-baratos.md), y
lo que hay que averiguar es si el acento admite un valor propio o solo una lista
cerrada — porque si es cerrada, `#3A664E` no está en ella y hay que elegir el más
cercano o descartar la vía.
