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

## La zona segura: dónde puede ir una marca dentro del fondo

Medido el 2026-08-15, mirando la primera captura del fondo nuevo en pantalla.
**Es la regla que faltaba, y no se sabía porque hasta ahora ningún fondo llevaba
nada escrito encima.**

`picture-options` está en `zoom`: GNOME **rellena la pantalla y recorta** lo que
sobra. Una imagen 16:9 solo se ve entera en una pantalla exactamente 16:9; en
cualquier otra se pierde por los lados —o por arriba y abajo, si la pantalla es
más ancha—. Los números, sobre 3840×2160:

| Pantalla | Recorte | Se come… |
|---|---|---|
| 16:9 | 0 | nada |
| 16:10 | 192 px por lado (5 %) | la bellota |
| 3:2 | 300 px por lado (7,8 %) | la bellota y parte del texto |
| 4:3 | 480 px por lado (12,5 %) | la bellota y el texto |
| 21:9 | 257 px arriba y abajo | el texto, por abajo |

**La zona segura es la intersección de todas**, o sea el recuadro central que
sobrevive tanto al 4:3 como al 21:9:

```
x:  480 .. 3360      (2880 px de ancho)
y:  257 .. 1903      (1646 px de alto)
```

Está dibujada en [zona-segura.png](zona-segura.png), en verde, con las bandas de
recorte de cada proporción y —en blanco— la caja donde está hoy la marca:
`x 136..1076, y 1784..2060`. Se ve de un vistazo que **la marca actual está casi
entera fuera**: empieza a 136 px del borde, el 3,5 % del ancho.

**Todo lo que tenga que leerse siempre —logotipo, palabra, versión— va dentro del
recuadro verde.** El paisaje puede salirse: para eso está el recorte.

*Y la alternativa que se descartó, con su medida, porque volverá a proponerse:*
`picture-options='scaled'` no recorta nunca y pone franjas del color de relleno
—0 % en 16:9, 5 % de la altura en 16:10—. Se probó en caliente en `encina-dev` el
2026-08-15 y **funciona**: la bellota sale entera y las franjas apenas se notan,
porque `#2F4033` queda pegado a la barra de GNOME (captura
`design/capturas/fondo-0.1.12/prueba-5-escritorio-scaled.png`). Se descartó por
decisión de Jorge el mismo día: prefiere arreglar el maestro y no pagar franjas
en ninguna pantalla. Si algún día vuelve a hacer falta, está medido y es una
palabra en el `gschema.override` y en `encina.xml`.

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
