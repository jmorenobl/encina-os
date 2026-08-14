# Los fondos

Los maestros están en `maestros/` y **no viajan en el clon**: son cinco JPEG de
~2,7 MB a 3936×2624, más dos PNG de ~9 MB a 3840×2160 desde el 2026-08-15 —el
mismo paisaje de día y de noche—. Lo que viaja es
[manifiesto.tsv](manifiesto.tsv).

Lo que se envía son seis ficheros a 3840×2160 dentro de
`debian-packages/encina-branding/src/usr/share/backgrounds/encina/`.

## De dónde sale cada uno

| Se envía como | Sale de | Cómo se supo |
|---|---|---|
| `encina.jpg` | `encina-os-splash-4k-3840x2160.png` | **Se hizo el 2026-08-15**, con la orden escrita en el manifiesto |
| `encina-dark.jpg` | `encina-os-splash-dark-4k-3840x2160.png` | **Maestro propio de noche**, misma sesión: ya no se deriva del claro |
| `amapolas.jpg` | `amapolas.jpg` | Mismo nombre |
| `farallon.jpg` | `farallon.jpg` | Mismo nombre |
| `olivar.jpg` | `olivar.jpg` | Mismo nombre |
| `sierra.jpg` | `sierra.jpg` | Mismo nombre |

**Enmienda del 2026-08-15.** Hasta hoy este párrafo decía que `caliza.jpg` era
«el maestro de los dos fondos que más se ven» —escritorio, salvapantallas y
GDM—. Lo fue, y ya no: el fondo por defecto es el maestro nuevo que aportó
Jorge. `caliza.jpg` sigue en `maestros/` **sin derivado**, y el contenido
anterior de `encina.jpg` y `encina-dark.jpg` está en el historial de git con las
huellas que llevaban esas dos filas del manifiesto.

*Y lo que se sabía a medias, ahora se sabe en dos de las seis filas:* **la orden
exacta**. De los cinco maestros del 2026-08-08 se sigue sin saber con qué
números y con qué herramienta se recortaron, y su columna `orden` sigue a `-`:
se pueden comprobar, no rehacer. Las dos filas del maestro nuevo **sí llevan su
orden**, porque se ejecutó aquí, y son reproducibles —dos pasadas dan la misma
`sha256`, comprobado—.

## El fondo oscuro deja de ser un derivado

Y es el cambio conceptual del día, no un detalle de ficheros. Hasta hoy
`encina-dark.jpg` **era el claro atenuado**: la misma fotografía, más oscura, para
que alternar entre tema claro y oscuro no cambiara de paisaje. Desde el
2026-08-15 es **una imagen propia** — el mismo paisaje **de noche**, con luna y
estrellas. La intención de no cambiar de paisaje se cumple igual, y mejor: lo que
cambia es la hora del día, que es lo que hace un tema oscuro.

*Y una hora de trabajo que se quedó por el camino, dicha porque el método de este
proyecto es contar también lo que se descartó:* antes de que llegara el maestro de
noche, el oscuro se fabricó aquí multiplicando el claro por **0,50**, factor
elegido por medida —igualaba el `YAVG` 53,8 del `encina-dark.jpg` anterior—. Esa
orden ya no está en el manifiesto. La sustituyó una conversión limpia del maestro
propio.

*El número, para quien compare:* el oscuro nuevo da `YAVG` **46,4** sobre el JPEG
que viaja, frente a 53,8 del anterior. Es **algo más oscuro**, y es una decisión
de Jorge. **Cuidado al medirlo:** ese mismo `ffmpeg signalstats` sobre el PNG
maestro devuelve 55,8, y no es otra imagen — es otra escala, porque el PNG se mide
en rango limitado y el JPEG en rango completo. Comparar un PNG con un JPEG por
este número da un susto falso.

## La licencia, que es el hueco que de verdad pesa

**Las seis imágenes viajan dentro de la ISO sin que esté escrito con qué permiso
se ceden.** Desde el 2026-08-15 hay una diferencia que conviene no confundir con
tenerlo resuelto: del maestro nuevo **sí se sabe el origen** —lo aportó Jorge—,
así que su columna `origen` ya no dice `SIN DETERMINAR`. La de `licencia` sí,
y es la que bloquea: saber de quién es no es lo mismo que haber escrito bajo qué
licencia se cede. **Es una línea, y la tiene que decir Jorge.**

Este proyecto publica la oferta de fuente de AutoFirma con cuatro repositorios y
sus etiquetas, y advierte de que el `.deb` no es el oficial. Aplicando ese mismo
listón, seis fotografías sin licencia declarada son un agujero de la misma
familia — y, a diferencia del de la orden, **este bloquea publicar**.

Está como primera casilla de
[../../tareas/aspecto/0-decidir.md](../../tareas/aspecto/0-decidir.md). Las
salidas son tres: que sean de Jorge y se declare bajo qué licencia se ceden, que
sean de un banco con licencia libre y se cite, o que se sustituyan.
