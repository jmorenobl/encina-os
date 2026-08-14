# Los fondos

Los maestros están en `maestros/`, a 3936×2624, y **no viajan en el clon**: son
cinco JPEG de ~2,7 MB. Lo que viaja es [manifiesto.tsv](manifiesto.tsv).

Lo que se envía son seis ficheros a 3840×2160 dentro de
`debian-packages/encina-branding/src/usr/share/backgrounds/encina/`.

## De dónde sale cada uno

| Se envía como | Sale de | Cómo se supo |
|---|---|---|
| `encina.jpg` | `caliza.jpg` | **Medido el 2026-08-14 mirándolas**: es la misma fotografía, recortada de 3:2 a 16:9 —se va cielo por arriba y roca por abajo— |
| `encina-dark.jpg` | `caliza.jpg` | El mismo recorte, oscurecido |
| `amapolas.jpg` | `amapolas.jpg` | Mismo nombre |
| `farallon.jpg` | `farallon.jpg` | Mismo nombre |
| `olivar.jpg` | `olivar.jpg` | Mismo nombre |
| `sierra.jpg` | `sierra.jpg` | Mismo nombre |

**`caliza.jpg` no era un maestro sin destino, como parecía: es el maestro de los
dos fondos que más se ven** —escritorio, salvapantallas y GDM—. Lo que pasaba es
que el derivado cambió de nombre y nadie lo escribió.

*Y lo que sigue sin saberse, dicho aquí y no en letra pequeña:* **la orden
exacta**. Que el recorte existe está mirado; con qué números y con qué
herramienta se hizo, no. Por eso la columna `orden` del manifiesto está a `-` en
las seis filas, y por eso hoy los fondos todavía **se heredan**: se pueden
comprobar, no rehacer.

## La licencia, que es el hueco que de verdad pesa

**Las seis fotografías viajan dentro de la ISO sin que esté escrito de dónde
salieron ni con qué permiso.**

Este proyecto publica la oferta de fuente de AutoFirma con cuatro repositorios y
sus etiquetas, y advierte de que el `.deb` no es el oficial. Aplicando ese mismo
listón, seis fotografías sin licencia declarada son un agujero de la misma
familia — y, a diferencia del de la orden, **este bloquea publicar**.

Está como primera casilla de
[../../tareas/aspecto/0-decidir.md](../../tareas/aspecto/0-decidir.md). Las
salidas son tres: que sean de Jorge y se declare bajo qué licencia se ceden, que
sean de un banco con licencia libre y se cite, o que se sustituyan.
