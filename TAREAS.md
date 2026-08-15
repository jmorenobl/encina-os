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
| [aspecto/](tareas/aspecto/) | Que el sistema instalado tenga cara propia | **5, y las cinco son [5-cierre.md](tareas/aspecto/5-cierre.md)** — el 2026-08-15 Jorge dio por bueno lo visual (*«como está, está bastante bien»*) y **los bloques 0, 2, 3 y 4 quedan cerrados enteros**, con el 1 **aplazado por escrito**. Las cinco que se cerraron ese día no costaron ni una medición nueva: las pruebas ya estaban en el disco, y **dos de ellas seguían abiertas sólo porque su «hecha cuando» apostaba a una hipótesis falsa** — que el acento alcanzaría a GDM. Detalle en [aspecto/LEEME.md](tareas/aspecto/LEEME.md) |
| **[marca-del-medio.md](tareas/marca-del-medio.md)** | **Que el medio y el instalador dejen de decir Ubuntu. Bloquea publicar.** Es lo que se está haciendo | **4** — eran 5, y la del logotipo de la rejilla era una **copia rancia**: se cerró el 2026-08-14 en `aspecto/`, donde además se descubrió que estaba mal leída —el botón nunca llevó el logotipo de Ubuntu— |
| [alojamiento.md](tareas/alojamiento.md) | 3,46 GB no caben en un release de GitHub | 2 |
| [publicar.md](tareas/publicar.md) | La release, y probarla en una máquina que no sea del banco | 3 |
| [despues-de-publicar.md](tareas/despues-de-publicar.md) | E5, el núcleo en el medio, amd64 | 3 |
| [sueltas.md](tareas/sueltas.md) | De un rato cada una, sin bloque | 5 |

## El orden, y por qué

**~~`aspecto/` va antes que `marca-del-medio.md`~~ — CUMPLIDO el 2026-08-15: el
turno es de `marca-del-medio.md`.** El motivo del orden sigue siendo bueno y se
conserva escrito, porque explica por qué se hizo así: todo lo del aspecto vive en
paquetes, así que **sobrevive intacto al salto a E5**, la imagen propia. La marca
del medio y del instalador es justo la parte que se tira si E5 se hace, y esa
decisión sigue sin tomar. Uno no se paga dos veces; el otro puede.

**Y el orden nuevo, con el mismo argumento aplicado a lo que queda:** las dos
últimas casillas de [aspecto/5-cierre.md](tareas/aspecto/5-cierre.md)
—refabricar la ISO, e instalarla y mirarla— **se pagan DESPUÉS de la marca del
medio y una sola vez**. Refabricar ahora para meter `encina-branding` 0.1.15, y
otra vez dentro de unos días para meter la marca, es pagar dos veces una vuelta
de medio. Las tres primeras de ese fichero sí se pueden hacer ya, porque no
refabrican nada.

**Lo que es cierto desde hoy:** la última ISO que produce este repositorio es
**`1224b5b1…`** (§4.45), lleva `encina-branding` **0.1.11** dentro y la buena es
**0.1.15**, así que **ha caducado**. No es un fallo —es lo que pasa cuando
cambian los `.deb`—, pero deja de ser verdad la frase «dos pasadas dan esta
huella» sobre el árbol de hoy.

*Y una corrección del mismo día, que es justo la trampa que este proyecto
persigue:* esto se escribió primero diciendo `95758c9e…`, **por el nombre de la
VM del banco y no por la huella del fichero**. `95758c9e…` es la primera ISO
reproducible (§4.39) y ya estaba superada por `1224b5b1…` desde antes. Se cazó
midiendo las tres con `shasum`, que es lo que había que hacer desde el principio.

**Y una nota de arquitectura que apareció el 2026-08-15 y no cambia nada todavía:**
`D9` dice *«solo arm64 por ahora; amd64 cuando haya con qué probarlo»*, y su
motivo escrito es *«solo hay un Mac M3»*. **Ese motivo ha dejado de ser cierto:**
hay un Mac de 2015, Intel, o sea **amd64**. No desbloquea nada de lo que está en
curso —la ISO de hoy es arm64 y **no arranca ahí**—, y amd64 sigue siendo E6 en
[despues-de-publicar.md](tareas/despues-de-publicar.md), con todo lo que eso
arrastra: reconstruir los cuatro `.deb`, repetir allí las mediciones y volver a
medir AutoFirma, porque `B6` es específica de arm64 y no aparecería. Lo que sí
cambia es que **E6 deja de estar bloqueado por falta de máquina**: pasa de «no se
puede medir» a «no es la prioridad», que es una frase distinta.

Después van alojamiento y publicar, que no dependen de lo visual salvo en una
cosa: ~~**la licencia de las seis fotografías que viajan en la ISO está sin
determinar**, y eso bloquea publicar igual que lo bloqueaba la oferta de fuente.
Es la primera casilla de
[aspecto/0-decidir.md](tareas/aspecto/0-decidir.md).~~ **Cerrada el 2026-08-15, y
la premisa era falsa:** `debian/copyright` las declaraba desde el 2026-08-08; lo
que estaba desactualizado era `design/fondos/manifiesto.tsv`. **Ya no queda nada
de lo visual bloqueando publicar** — lo que bloquea es la marca del medio y los
3,46 GB.

## Cerrado

| Bloque | Cerrado | Qué demostró |
|---|---|---|
| [cerradas/reproducibilidad.md](tareas/cerradas/reproducibilidad.md) | 2026-08-13 | El medio se fabrica, no se hereda: de un árbol versionado a la ISO en una orden, cuatro pasadas y la misma huella |
| [cerradas/fuentes.md](tareas/cerradas/fuentes.md) | 2026-08-13 | La oferta de fuente está publicada y la CI mide que reconstruye de verdad |

---

*Este fichero era la lista entera hasta el 2026-08-14. Se troceó porque el bloque
del aspecto no cabía: el texto de los bloques se movió **verbatim**, comprobado
con un `diff` que sólo señala los siete títulos que bajaron de nivel.*
