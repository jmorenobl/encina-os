# La paleta

Los colores viven en [paleta.tsv](paleta.tsv), que es la fuente legible por un
guion. Aquí está el porqué de cada uno y lo que falta.

## Los que están, y qué papel hacen

| Papel | Nombre | Hex | Por qué |
|---|---|---|---|
| **acento** | verde encina | `#3A664E` | El único color que dice «Encina». Verde de hoja de encina en sombra: no es el verde de una farmacia ni el de una app de reciclaje |
| acento-profundo | verde profundo | `#2F4033` | El fondo sobre el que descansa todo lo oscuro. Ya está puesto como `primary-color` de los fondos |
| acento-claro | verde hoja | `#5B7553` | El extremo claro. Sale del degradado de `generar-activos.sh` |
| tierra | tierra ibera | `#A78B75` | Lo cálido. Impide que el verde se lea como corporativo |
| arcilla | arcilla | `#D6BFA0` | La malla del logotipo. Es lo que hace legible la red sobre el verde |
| neutro | gris pizarra | `#E6E8E6` | El gris que no es azul |

**Un color, un papel.** El acento es `#3A664E` y no hay un segundo acento: en
cuanto hay dos, la pantalla deja de tener un sitio donde mira el ojo.

## Lo que faltaba, propuesto el 2026-08-15 con los números delante

Cinco colores de marca sirven para un banner. **Un sistema operativo necesita
más.** Ya no hay ninguna fila `SIN DECIDIR` en el TSV, pero **todo lo de abajo
está `PROPUESTO` y no `VIGENTE`**: son colores escritos, no aplicados, y elegir
un rojo es de Jorge.

| Papel | Claro | sobre papel | Oscuro | sobre fondo oscuro |
|---|---|---|---|---|
| **texto** | `#1C231E` tinta encina | **14,90** AAA | `#E8ECE7` tiza | **9,24** AAA |
| **correcto** | `#2F5741` verde sello | **7,61** AAA | `#7FB394` verde brote | **4,62** AA |
| **aviso** | `#8A5A12` ocre | **5,49** AA | `#E0A94A` ocre claro | **5,23** AA |
| **error** | `#9E2F26` almagre | **6,75** AA | `#F0897C` almagre claro | **4,51** AA |

Los números son razones de contraste WCAG 2.1 contra `papel #F5F7F4` y contra
`acento-profundo #2F4033`. **Están calculados, no tecleados**: se generan desde
el hex, y un comprobador vuelve a calcularlos y avisa si alguno no cuadra —la
primera pasada cazó **siete** números puestos a ojo—.

**El error y el aviso salen de la tierra, no de un rojo de semáforo.** Almagre y
ocre son los pigmentos del paisaje que ya está en la paleta; un rojo puro al lado
del verde encina se lee como una alerta de navegador, no como este producto.

## POR QUÉ CADA PAPEL SEMÁNTICO SON DOS COLORES Y NO UNO

Porque **ningún hex único sirve para los dos modos**, y esto se midió, no se
supuso. `#9E2F26` da **6,75** sobre el papel claro y **1,52** sobre el oscuro:
ilegible. Un solo color de error habría pasado la revisión en claro y habría
dejado el modo oscuro sin poder contar que una firma ha fallado.

**Y de paso salió un fallo en lo que ya estaba VIGENTE:** el acento `#3A664E`
sobre `acento-profundo #2F4033` da **1,68**. **El acento no se lee sobre el fondo
oscuro de la propia marca.** No es que el color esté mal elegido: es que ese par
no se había medido nunca. Donde el papel sea semántico lo resuelve
`correcto-oscuro`; donde sea identidad —el logotipo sobre un fondo oscuro— hay
que decidir qué se hace, y **está sin decidir**.

## La incoherencia del «blanco roto», resuelta

`identidad.png` declaraba **«BLANCO ROTO — #FFFFFF»**, y `#FFFFFF` es blanco
puro. **Manda el nombre, no el hex**: el papel de ese color es «el fondo de una
ventana clara», y para eso un blanco roto es lo correcto. Queda `#F5F7F4`, un
blanco con el mismo sesgo verde que el `neutro`.

Y el motivo que daba este documento ahora tiene número: `#FFFFFF` contra
`#E6E8E6` da **1,23**, y `#F5F7F4` contra `#E6E8E6` da **1,14**. Más cerca del
neutro, o sea menos «dos escritorios». *`identidad.png` sigue diciendo `#FFFFFF`
y es una copia que hay que cuadrar —el TSV manda—.*

## Y el acento tuvo su vía barata, medida

~~Está sin medir.~~ **Medida el 2026-08-14** y contestada entera en
[../tareas/aspecto/2-golpes-baratos.md](../tareas/aspecto/2-golpes-baratos.md):
Ubuntu **no** tiene clave `accent-color`; lo que hay es una **lista cerrada de
diez temas** `Yaru-<acento>`, y **sí alcanza a GTK4/libadwaita**, que era la
duda. `#3A664E` **no está en la lista**, así que se puso `Yaru-sage` como verde
prestado en `encina-branding` 0.1.10 — y `sage #657B69` está tan desaturado que
pasa por gris.

Tener el verde propio exige **forkear Yaru para añadir una variante**, que es una
decisión abierta en
[../tareas/aspecto/0-decidir.md](../tareas/aspecto/0-decidir.md).
