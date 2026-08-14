# Lo que queda por hacer

**Esto es el índice, y es lo único que hay que leer para saber dónde está el
proyecto.** Cada bloque vive en su fichero, dentro de [tareas/](tareas/).

**Cómo se usa esta lista.** Cada tarea es de un rato, no de una tarde, y lleva
tres cosas: **qué** hay que hacer, **por qué** —porque si no se sabe, se hace mal
o no se hace—, y **cómo se sabe que está hecha**, que es una salida concreta y no
una sensación.

Lo que ya está hecho no vive aquí: vive en `AGENTS.md` como casilla marcada y en
`MEDICIONES.md` con sus salidas. Un bloque que se cierra entero se va a
[tareas/cerradas/](tareas/cerradas/) y deja de leerse.

## Abierto

| Bloque | Qué | Abiertas |
|---|---|---|
| **[aspecto/](tareas/aspecto/)** | **Que el sistema instalado tenga cara propia.** Es lo que se está haciendo | **30** |
| [marca-del-medio.md](tareas/marca-del-medio.md) | Que el medio y el instalador dejen de decir Ubuntu. Bloquea publicar | 5 |
| [alojamiento.md](tareas/alojamiento.md) | 3,46 GB no caben en un release de GitHub | 2 |
| [publicar.md](tareas/publicar.md) | La release, y probarla en una máquina que no sea del banco | 3 |
| [despues-de-publicar.md](tareas/despues-de-publicar.md) | E5, el núcleo en el medio, amd64 | 3 |
| [sueltas.md](tareas/sueltas.md) | De un rato cada una, sin bloque | 5 |

## El orden, y por qué

**`aspecto/` va antes que `marca-del-medio.md`**, y no es comodidad. Todo lo del
aspecto vive en paquetes, así que **sobrevive intacto al salto a E5**, la imagen
propia. La marca del medio y del instalador es justo la parte que se tira si E5
se hace, y esa decisión sigue sin tomar. Uno no se paga dos veces; el otro puede.

Después van alojamiento y publicar, que no dependen de lo visual salvo en una
cosa: **la licencia de las seis fotografías que viajan en la ISO está sin
determinar**, y eso bloquea publicar igual que lo bloqueaba la oferta de fuente.
Es la primera casilla de
[aspecto/0-decidir.md](tareas/aspecto/0-decidir.md).

## Cerrado

| Bloque | Cerrado | Qué demostró |
|---|---|---|
| [cerradas/reproducibilidad.md](tareas/cerradas/reproducibilidad.md) | 2026-08-13 | El medio se fabrica, no se hereda: de un árbol versionado a la ISO en una orden, cuatro pasadas y la misma huella |
| [cerradas/fuentes.md](tareas/cerradas/fuentes.md) | 2026-08-13 | La oferta de fuente está publicada y la CI mide que reconstruye de verdad |

---

*Este fichero era la lista entera hasta el 2026-08-14. Se troceó porque el bloque
del aspecto no cabía: el texto de los bloques se movió **verbatim**, comprobado
con un `diff` que sólo señala los siete títulos que bajaron de nivel.*
