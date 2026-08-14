# Bloque ASPECTO — que el sistema instalado tenga cara propia

**Qué compra este bloque:** que alguien que arranca Encina OS y mira la pantalla
vea Encina OS, y no Ubuntu con otro fondo. Es el sistema **instalado**; el medio
y el instalador son [../marca-del-medio.md](../marca-del-medio.md), y van
después.

## Por qué éste va antes que el del medio

Todo lo de aquí vive en paquetes —`encina-branding`, y quizá un `encina-theme`—,
así que **sobrevive intacto al salto a E5, la imagen propia**. La marca del medio
y del instalador es justo la parte que se tira si E5 se hace, y esa decisión está
sin tomar (lo dice el propio bloque 1).

O sea: este bloque no se paga dos veces y el otro puede pagarse dos veces. Ése es
el orden, y no es comodidad.

## La estrategia: partir de un tema hecho, sí; de WhiteSur, no

Escribir un tema GTK y de shell desde cero son miles de líneas de SCSS que hay
que rehacer en cada versión de GNOME. **Partir de uno existente es lo correcto**
y es lo que hacen todas las derivadas.

**WhiteSur queda descartado, y no por gusto: lo prohíbe `AGENTS.md` R8** —*«ni
tipografía San Francisco de Apple, ni iconos que imiten macOS»*—. WhiteSur es,
por definición de su autor, una imitación de macOS Big Sur, y su tema de iconos
son redibujos de los de Apple. Adoptarlo sería derogar R8 el mismo día que se usa
para justificar por qué el botón de la rejilla no puede llevar el logotipo de
Canonical.

Y tres motivos más, independientes de la regla:

1. **Cambia un vestigio por otro peor.** Hoy una captura dice «es Ubuntu». Con
   WhiteSur diría «es un Mac falso» — y Ubuntu al menos es la base declarada y
   atribuida legalmente; Apple no es nada de este proyecto.
2. **Choca con R5 donde más duele.** Para tocar GDM, WhiteSur reempaqueta
   `gnome-shell-theme.gresource`, que es **propiedad de `gnome-shell`**. Es
   exactamente lo que obligó a inventar el tema de iconos `Encina` que hereda de
   Yaru en vez de pisar un fichero de `yaru-theme-icon`.
3. **La oferta de fuente.** Es GPL-3.0: distribuirlo añade una fila a la tabla
   del README, con la pregunta incómoda de qué licencia ampara unos iconos que
   reproducen artwork de Apple.

**Candidatos que no llevan la cara de nadie:** Colloid o Graphite (mismo autor,
neutros, con variante verde de fábrica), o forkear Yaru con el verde encina
—máxima compatibilidad, cero sorpresas, menos efecto—.

## El límite técnico que cambia el cálculo de todo, y está SIN MEDIR

En GNOME 46 —el de Ubuntu 24.04— **un tema GTK3 ya no pinta la mitad del
escritorio**. Archivos, Ajustes, el Centro de aplicaciones, el visor de imágenes:
todo eso es GTK4/libadwaita y **ignora el tema**. Instalar un tema esperando que
el sistema entero cambie de cara puede dar un escritorio partido: unas ventanas
de una manera y otras de otra.

Lo que sí alcanza a todo, y cuesta una línea, es **el color de acento**.

**La hipótesis de este bloque, escrita para poder equivocarse:** *acento +
iconos + fondo + arranque dan el grueso del cambio de cara, y el tema GTK da
poco.* Si se confirma, la elección del tema base deja de ser urgente y pasa a ser
una guinda. **No está medida**, y medirla es lo primero que se hace después de
tener con qué mirar.

Por eso el orden de los ficheros es el que es: primero decidir, luego poder ver,
luego lo barato, y el tema **el cuarto**.

**Y la regla que hace que ese orden se sostenga, aprendida el 2026-08-14 al
escribirlo mal:** en `0-decidir.md` sólo van casillas que se cierran **pensando y
escribiendo**. En cuanto un «hecha cuando» pide una captura, una orden o una
máquina, la casilla ya no es una decisión y baja al fichero que trae el
instrumento. El inventario de dónde se ve Ubuntu estaba en el 0 y exigía una
captura por línea: hacía el plan circular —el 0 no se podía terminar sin el 1— y
se movió al 1, que es donde nace el instrumento que lo prueba.

## El orden

| | Qué |
|---|---|
| [0-decidir.md](0-decidir.md) | La licencia de las fotos, la identidad escrita, los colores que faltan y el tema base |
| [1-instrumentacion.md](1-instrumentacion.md) | Poder ver lo que se cambia sin reinstalar, y el inventario |
| [2-golpes-baratos.md](2-golpes-baratos.md) | Acento, tipografía, fondos |
| [3-tema-e-iconos.md](3-tema-e-iconos.md) | El tema y los iconos |
| [4-arranque-y-sesion.md](4-arranque-y-sesion.md) | Plymouth, GDM, GRUB |
| [5-cierre.md](5-cierre.md) | Que el verificador lo mire, y que la ISO siga saliendo igual |

## Lo que este bloque NO hace

- **El medio y el instalador.** Es [../marca-del-medio.md](../marca-del-medio.md).
- **El nombre del volumen de la ISO.** Lo mismo.
- **Cambiar de escritorio.** Sigue siendo GNOME.
