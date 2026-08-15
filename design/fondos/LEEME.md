# Los fondos

Los maestros están en `maestros/` y **no viajan en el clon**: son cinco JPEG de
~2,7 MB a 3936×2624, más dos PNG de ~9 MB a 3840×2160 desde el 2026-08-15 —el
mismo paisaje de día y de noche—. Lo que viaja es
[manifiesto.tsv](manifiesto.tsv).

*Y hay un tercer par en `maestros/`, el de la 0.1.12* —`encina-os-splash-4k-*`,
sin `light`/`dark` en el nombre—. **No se borra a propósito:** es el control de
`scripts/zona-segura.py`, el par cuya marca se salía. Sin él, esa comprobación no
puede demostrar que sabe dar su rojo.

Lo que se envía son seis ficheros a 3840×2160 dentro de
`debian-packages/encina-branding/src/usr/share/backgrounds/encina/`.

## De dónde sale cada uno

| Se envía como | Sale de | Cómo se supo |
|---|---|---|
| `encina.jpg` | `encina-os-splash-light-4k.png` | **0.1.13**, con la marca ya dentro de la zona segura |
| `encina-dark.jpg` | `encina-os-splash-dark-4k.png` | Lo mismo de noche: no se deriva del claro, es una imagen propia |
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

*El número, para quien compare:* el oscuro da `YAVG` **47,0** sobre el JPEG que
viaja en la 0.1.13 —46,4 en la 0.1.12—, frente a 53,8 del de Unsplash. Es **algo más oscuro**, y es una decisión
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
recorte de cada proporción y —en blanco— la caja de la marca. Regenerada el
2026-08-15 con el maestro de la 0.1.13, donde la marca ya cae dentro:
`x 508..1556, y 1536..1884`. En la 0.1.12 esa caja era `x 136..1076,
y 1784..2060` y se salía por la izquierda y por abajo.

**Todo lo que tenga que leerse siempre —logotipo, palabra, versión— va dentro del
recuadro verde.** El paisaje puede salirse: para eso está el recorte.

### Y se comprueba, que era la otra mitad

`./scripts/zona-segura.py <claro> <oscuro>` lo mide. **Localiza la marca
comparando las dos imágenes**, porque es lo único igual en ambas —el paisaje es
de día en una y de noche en la otra—; buscar «lo blanco» o «lo brillante» no
sirve, y no es una suposición: los dos primeros intentos devolvían el ancho
entero porque cogían las nubes doradas, las casas del pueblo y el campo
iluminado. El control lo dijo antes que nadie.

Con los maestros de la 0.1.13: `[OK]`, con **28 px de margen a la izquierda y 19
por abajo**, que es poco pero está medido y la resolución de la medida son 4 px.
Con los de la 0.1.12: `[FALLO]`, la marca a 136 px del borde. Sabe dar sus dos
respuestas.

*Y la alternativa que se descartó, con su medida, porque volverá a proponerse:*
`picture-options='scaled'` no recorta nunca y pone franjas del color de relleno
—0 % en 16:9, 5 % de la altura en 16:10—. Se probó en caliente en `encina-dev` el
2026-08-15 y **funciona**: la bellota sale entera y las franjas apenas se notan,
porque `#2F4033` queda pegado a la barra de GNOME (captura
`design/capturas/fondo-0.1.12/prueba-5-escritorio-scaled.png`). Se descartó por
decisión de Jorge el mismo día: prefiere arreglar el maestro y no pagar franjas
en ninguna pantalla. Si algún día vuelve a hacer falta, está medido y es una
palabra en el `gschema.override` y en `encina.xml`.

## La licencia: manda `debian/copyright`

**Decidido por Jorge el 2026-08-15**, y es la regla que hay que recordar cuando
esto se vuelva a mirar: la autoridad es
[`debian/copyright`](../../debian-packages/encina-branding/debian/copyright), no
este directorio. Es lo que **viaja** con el paquete y lo que lee quien lo recibe;
`manifiesto.tsv` es una copia para trabajar. Si algún día dicen cosas distintas,
el equivocado es el manifiesto.

Con esa regla, la columna `licencia` ya no tiene ningún `SIN DETERMINAR`:

| Fondos | Licencia | Origen |
|---|---|---|
| `encina.jpg`, `encina-dark.jpg` | `EUPL-1.2` | Jorge MB, 2026-08-15 |
| `amapolas`, `farallon`, `olivar`, `sierra` | Unsplash License | Amanda Anusane, unsplash.com |

**Y lo que este documento decía y era falso, dejado al lado en vez de borrado:**
decía que «seis fotografías viajan dentro de la ISO sin que esté escrito de dónde
salieron ni con qué permiso», y lo llamaba la casilla que bloquea publicar. No lo
era. `debian/copyright` las declara **desde el 2026-08-08** —párrafo DEP-5 propio,
con el texto de la Unsplash License transcrito y la fecha— y `DIARIO.md` lo cuenta
ese mismo día. Lo que había no era un agujero de licencia: era **este fichero
desactualizado respecto de lo que viaja dentro del `.deb`**. Se descubrió el
2026-08-15 al separar los dos fondos propios del párrafo de Unsplash, y estuvo
escrito aquí seis días diciendo lo contrario de lo que el paquete declaraba.

*Lo que sigue siendo verdad y no conviene perder al rellenar una columna:* la
Unsplash License **es permisiva pero no es una licencia libre al uso** ni cumple
las DFSG. Prohíbe dos cosas —vender las imágenes sin modificación significativa, y
compilar imágenes de Unsplash para replicar un servicio similar—, y el
razonamiento de por qué distribuirlas como fondos de un sistema operativo no es
ninguna de las dos está en `debian/copyright`, que es donde tiene que estar. Quien
reutilice este paquete tiene que leerlo.
