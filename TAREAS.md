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
| [aspecto/](tareas/aspecto/) | Que el sistema instalado tenga cara propia | **6 desde el 2026-08-23 —el hierro abrió una: el modo oscuro de Ajustes se lleva la bellota del dock, `MEDICIONES.md` §4.70c—, y aquí ponía ~~5~~, y las seis son [5-cierre.md](tareas/aspecto/5-cierre.md)** — el 2026-08-15 Jorge dio por bueno lo visual (*«como está, está bastante bien»*) y **los bloques 0, 2, 3 y 4 quedan cerrados enteros**, con el 1 **aplazado por escrito**. Las cinco que se cerraron ese día no costaron ni una medición nueva: las pruebas ya estaban en el disco, y **dos de ellas seguían abiertas sólo porque su «hecha cuando» apostaba a una hipótesis falsa** — que el acento alcanzaría a GDM. Detalle en [aspecto/LEEME.md](tareas/aspecto/LEEME.md) |
| **[marca-del-medio.md](tareas/marca-del-medio.md)** | **Que el medio y el instalador dejen de decir Ubuntu. Bloquea publicar.** | **0, y sólo queda el `[OJOS]` de Jorge, que se cobra en la vuelta única** — eran 4, y antes 5: la del logotipo de la rejilla era una **copia rancia** (cerrada el 2026-08-14 en `aspecto/`, donde además se vio que estaba **mal leída**: el botón nunca llevó el logotipo de Ubuntu). **El 2026-08-15 se cerraron dos**: el inventario (`MEDICIONES.md` §4.51, con instrumento `imagen/inventario-marca.sh`) y los términos de Canonical, que son **`ENCINA-OS.md` D22** — **«marca no es cadena»** y las tres pilas. **El 2026-08-15 se hizo la tercera salvo su `[OJOS]`** (§4.52), y con ella **la pregunta de fondo del bloque está contestada: `ENCINA-OS.md` D23**. Reempaquetar y E5 no eran las dos opciones: **el medio no lleva `layerfs-path=`**, así que **una capa de 2,9 MiB tapa a la de 1,69 GB**, y el instalador trae **una puerta de marca blanca documentada por Canonical** (`/usr/share/desktop-provision/`) que se apunta **desde fuera de su snap firmado**. El inventario baja de **31 a 24 apariciones** con los **ocho** sitios nombrados. ~~**Queda el nombre del volumen**~~ **— CERRADO EL 2026-08-17 (§4.53): el medio se llama `Encina OS 0.2.1 arm64`, y la premisa de la casilla era falsa, porque ni `casper` ni `apt-cdrom` ni `subiquity` ni el GRUB firmado buscan por etiqueta — el `grubaa64.efi` hace `search --file /.disk/info`. Contra un medio de control, la diferencia son 88 bytes de 3 715 235 840 y todos dentro del campo del nombre; y se tapó el punto ciego del paso 10 de `fabricar-iso.sh`, que compara fichero a fichero y no veía este cambio**, y **fuera de la casilla pero dentro de lo que bloquea publicar: el splash del `initrd` y los logotipos que siguen viajando dentro del snap** |
| [identidad-instalada.md](tareas/identidad-instalada.md) | Que la MÁQUINA INSTALADA deje de identificarse como Ubuntu ante los scripts | **2, nuevas el 2026-08-23, y las abre Jorge** con una propuesta concreta —`ID=encina`, `ID_LIKE="ubuntu debian"`— que choca con **D6**. Al mirar sobre qué descansa D6 salió lo que las abre de verdad: **su motivo es una deducción y no tiene ningún `§N.NN` detrás**, así que primero se **mide** quién lee `ID` —y cuántos de esos leen `ID_LIKE`, que es la columna que decide— y luego se decide, con `DISTRIB_ID` de `lsb-release` **en el mismo enunciado**, porque D22 lo llama «su gemelo» y separarlos crearía un defecto nuevo. **NO bloquea publicar**: `ID` está en la pila C de D22, o sea que esto es decisión **de producto** y va **detrás de la fase 1**. El mecanismo no lo paga este bloque —R5 ya prescribe `dpkg-divert` y la máquina instalada lo va a necesitar igualmente por D22— |
| **[despues-de-publicar.md](tareas/despues-de-publicar.md)** | E5, el núcleo en el medio, **y `amd64` (E6), que ya NO es «después»** | 3, pero **E6 es la FASE 1 y está en curso** —el nombre del fichero le queda mal desde el 2026-08-22 y se corrige en la refactorización, no antes—. E5 y el núcleo sí siguen siendo posteriores a publicar |
| **[actualizacion.md](tareas/actualizacion.md)** | **Actualizar Encina OS: los tres relojes** —base, paquetes, medio— y lo que hay que medir antes de tocar nada. Abierto el 2026-08-30, el día siguiente a publicar, a pregunta de Jorge | **17, una hecha el mismo día, en cuatro bloques, y ninguna bloquea nada:** A (delimitar: la regla de numeración como decisión `D`, ~~el README diciendo cómo se actualiza y cómo no~~ **hecha el 2026-08-30: «Actualizar: de momento, no hay camino», la línea base por arquitectura y el aviso de experimental**, la receta de «sacar `0.2.2`», y **el guion de respaldo y restauración que pidió Jorge**, porque hoy actualizar es reinstalar); B (medir lo que ya existe: `unattended-upgrades` contra Firefox, la fuente local `trusted=yes`, **el salto de LTS contra el anclaje**, y los cuatro `.deb` sobre 26.04); C (el canal de los paquetes: hoy **no hay ninguno** —`/srv/encina-repo` es local y estático—, y la recomendación es un repositorio `apt` firmado con un quinto paquete `encina-keyring`); D (el salto de LTS, sólo con lo que B diga). Cuatro deducciones escritas con su etiqueta y **ninguna medida**. Candidato a E7 de `ENCINA-OS.md` §6, no inscrito |
| [sueltas.md](tareas/sueltas.md) | De un rato cada una, sin bloque | 7 — **la nueva es del hierro, 2026-08-23: en AMD el saludador nace sobre `simpledrm` y muere al llegar `amdgpu`, 0 de 5; remedio medido 3 de 3 (§4.70b)** |

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

**Y el «después» es AHORA, desde el 2026-08-17:** cerrada la casilla 4, la marca
del medio no tiene ya nada que se pueda hacer sin arrancar, así que **la vuelta
única es la tarea en curso** (`ENCINA-OS.md` §7). Lleva dentro, todo junto:
construir `encina-branding` **0.1.15** en la VM —**no está en el disco**, y por
eso `fabricar-iso.sh` no se ha podido ejecutar entero desde el 2026-08-15—,
refabricar con `construir-todo.sh` **comprobando que dos pasadas dan la misma
huella**, e instalar y **mirar**, que es donde se cobran los dos `[OJOS]` de
`marca-del-medio.md` y las dos casillas de `5-cierre.md`.

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

## EL ORDEN CAMBIA EL 2026-08-23, Y LO DECIDE JORGE: **PUBLICAR VA EL ÚLTIMO**

**Las tres fases, y no se solapan:**

| | Fase | Qué la cierra |
|---|---|---|
| **1.ª** | **QUE LAS ISOs FUNCIONEN DE VERDAD** — y son **dos**: el hierro `amd64` y la vuelta única `arm64` | **`amd64`:** la receta de `ENCINA-OS.md` §7 pasa en el portátil AMD A9 —arranca, se instala, `verificar-instalacion.sh` da 0 fallos— y ahí se cobra **Plymouth de la máquina instalada**, que no tiene otra condición de salida. **`arm64`:** la vuelta única que ya estaba en curso —`encina-branding` 0.1.15, dos pasadas con la misma huella, instalar y **mirar**— *(al día 2026-08-25: con 0.1.17, `63f360dd…`, seis pasadas una huella, y arrancado hasta la primera pantalla; cinco pantallas contestadas, verificador 65/0 dentro, seis capturas aprobadas por Jorge: **fase 1 COMPLETA**, §4.79)*, que es donde se cobran los `[OJOS]` de [marca-del-medio.md](tareas/marca-del-medio.md) y las dos casillas de [aspecto/5-cierre.md](tareas/aspecto/5-cierre.md). **Esa huella `arm64` NO es la que se publicará** —la fase 2 la invalida a propósito— y no pasa nada: lo que compra esta vuelta son los ojos de Jorge, no una huella |
| **2.ª** | **LA REFACTORIZACIÓN, ahora ENTERA y adelantada** — [refactorizacion.md](tareas/cerradas/refactorizacion.md) | `bancos/enlaces.sh` (tarea 1) en verde sobre el árbol ya movido, **y** el documento de la tarea 12 sin ninguna fila sin veredicto — *lo segundo, hecho el 2026-08-23; ~~queda lo primero, que es lo que no existe~~ **lo primero, hecho el 2026-08-28: `enlaces.sh` 9/0 sobre el árbol entero movido, y las dieciséis casillas marcadas con su §4.80. FASE 2 COMPLETA**, y el bloque está en `tareas/cerradas/`* |
| **3.ª** | **PUBLICAR** — [alojamiento.md](tareas/cerradas/alojamiento.md) y [publicar.md](tareas/cerradas/publicar.md) | lo que ya dicen esos ficheros |

**Y el motivo, que es lo que hay que conservar:** *«sabiendo que las ISOs
funcionan y que el proyecto está bien organizado, siguiendo las mejores
prácticas, es cuando publicamos»*. Publicar es **el único acto de este proyecto
que no se puede deshacer**: una release tiene URL, se descarga, y activa las dos
obligaciones que §2 ya midió —responder a un fallo y sostener la oferta de
fuente—. Todo lo demás se rehace en el disco de Jorge sin que nadie se entere.
Un acto irreversible va detrás de los reversibles, no delante.

**LA REFACTORIZACIÓN SE ADELANTA, Y ESO INVIERTE UN ARGUMENTO QUE ESTABA
ESCRITO — conviene ver por qué, porque el argumento viejo no era falso.** Decía:

> ~~**Y la refactorización va DESPUÉS de publicar, por el mismo argumento de no
> pagar dos veces.** La definición de terminado de `construir-todo.sh` es que dos
> pasadas den la misma huella, así que tocar `imagen/fabricar-iso.sh` —la última
> tarea del bloque— invalida la huella que la release lleva dentro. Publicar
> primero, refactorizar después, y la siguiente vuelta de medio se paga una sola
> vez.~~

Eso es **cierto** y sigue siéndolo: tocar `fabricar-iso.sh` invalida la huella.
Lo que cambia es **qué se protege con ello**. El argumento viejo protegía *la
refactorización* de tener que refabricar; el orden nuevo protege *la release* de
nacer con una huella que su propio repositorio ya no sabe reproducir. Y lo
segundo pesa más, porque la huella publicada es lo que un tercero puede
comprobar y lo único que no se puede corregir sin retirar la descarga. **Nadie
paga dos veces en ninguno de los dos órdenes**: la vuelta de medio que la
refactorización obliga a repetir **ya está debida** por E6 y por
`encina-branding` 0.1.15, así que se paga una sola vez, al final, y con los
guiones ya en su forma definitiva.

**Lo que sigue valiendo del párrafo viejo, y no depende del orden:** la tarea 1
—`bancos/enlaces.sh`— va **antes que todas** las demás del bloque, porque es el
instrumento con el que se mide el resto (~~**1.857 referencias `§N.NN`**~~ **más
de dos mil**, y esa cifra concreta **no se reproduce con ninguna orden**: es la
enmienda del 2026-08-23 dentro de la propia tarea 1, y su primer argumento a
favor —en el repositorio, y dos tareas que mueven ficheros—); y la **11** —`fabricar-iso.sh`,
una función por fase— sigue yendo **la última**, con el producto congelado. ~~**La
tarea 12 es nueva y va con la 1**: la 1 es el instrumento, la 12 el criterio.~~
**La 12 ya está HECHA (2026-08-23) y la 1 sigue sin existir**, así que el
criterio llegó antes que el instrumento — y visto el resultado, fue el orden
barato: para escribirse, la 12 tuvo que medir el árbol, y con esa medida enmendó
nueve cifras de las once tareas **y contestó por adelantado parte de la 1**
(ninguna de las 305 referencias `§4.x` está rota hoy; sí hay dos enlaces
relativos rotos, listados y **sin arreglar a propósito**). Lo que **deja de aplicar** es la
excepción: las tareas 4, 5, 6, 7 y 8 estaban señaladas como *«ésas no dependen de
publicar»* para poder adelantarlas; ahora **ninguna depende de publicar**, así
que la excepción sobra y el bloque se hace entero y seguido.

**Y una casilla de [publicar.md](tareas/cerradas/publicar.md) cambia de significado con la
fase 1, sin que nadie la toque:** *«instalarla en una máquina que no sea del
banco»*. El hierro la contesta **para `amd64`**, y el producto declarado por `D9`
es **`arm64`**, que en ese portátil no arranca. O sea que la fase 1 **no la
marca**: la deja con su alcance escrito y traslada la pregunta —*¿se publica
`arm64` habiéndolo probado en hierro sólo en `amd64`?*— a la fase 3, que es donde
se decide, y **a sabiendas**.

## Cerrado

| Bloque | Cerrado | Qué demostró |
|---|---|---|
| [cerradas/reproducibilidad.md](tareas/cerradas/reproducibilidad.md) | 2026-08-13 | El medio se fabrica, no se hereda: de un árbol versionado a la ISO en una orden, cuatro pasadas y la misma huella |
| [cerradas/fuentes.md](tareas/cerradas/fuentes.md) | 2026-08-13 | La oferta de fuente está publicada y la CI mide que reconstruye de verdad |
| [cerradas/refactorizacion.md](tareas/cerradas/refactorizacion.md) (y [cerradas/organizacion-comparada.md](tareas/cerradas/organizacion-comparada.md)) | 2026-08-28 | **La fase 2 entera, las dieciséis tareas, sin tocar un byte del producto** (`MEDICIONES.md` §4.80): un solo vocabulario en `lib/salida.sh`, `mediciones/` un fichero por sección con la tabla de vigencia entera y su banco, `make bancos` con ocho bancos en la CI, `ENCINA-OS.md` §7 en 38 líneas, `TRAMPAS.md`, los guiones por verbo y paquete, `fabricar-iso.sh` por fases, la versión con una fuente, el constructor en `docker/` y la hoja de los `[OJOS]`. Y la huella `arm64` vigente, `63f360dd…`, **no caducó**: sale igual del árbol refactorizado |
| [cerradas/alojamiento.md](tareas/cerradas/alojamiento.md) | 2026-08-29 | **Dónde vive la ISO, y con la huella al lado**: SourceForge (`downloads.sourceforge.net/project/encina-os/0.2.1/`), elegido por Jorge; las dos ISOs, las cosechas, los `.torrent` con web seed y `SHA256SUMS`, bajados desde fuera con su huella (`MEDICIONES.md` §4.82j-l); y el 2026-08-30 la base `arm64` conservada con la firma de Canonical (§4.83) |
| [cerradas/publicar.md](tareas/cerradas/publicar.md) | 2026-08-30 | **PUBLICADO: la fase 3, lo último del proyecto.** La release `v0.2.1` sobre `ac663f5` con las notas y las cosechas, el README enlazando, un clon limpio sin archivo ni Canonical reproduciendo `63f360dd…` y `3d5d12a9…` sólo con lo publicado (§4.82k, §4.83d), y la decisión de Jorge, a sabiendas: `arm64` publicado probado en hierro sólo en `amd64` («no tengo acceso a otra máquina Apple Silicon») |

---

*Este fichero era la lista entera hasta el 2026-08-14. Se troceó porque el bloque
del aspecto no cabía: el texto de los bloques se movió **verbatim**, comprobado
con un `diff` que sólo señala los siete títulos que bajaron de nivel.*
