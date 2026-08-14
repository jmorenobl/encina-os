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

**Y el candidato dejó de ser una terna el 2026-08-14: es forkear Yaru.** Lo
preguntó Jorge —*«¿no sería más fácil clonar Yaru y tunearlo?»*— y la medición
del mismo día dice que sí, por una razón que no es estética:

**Yaru es el único tema al que el escritorio entero hace caso.** Ubuntu parchea
libadwaita para que siga su acento y trae el tema del shell. Colloid, Graphite y
WhiteSur son temas **GTK3**, y en GNOME 46 la mitad del escritorio es
GTK4/libadwaita y los ignora. Eso no es una hipótesis:
`design/capturas/antes/06-archivos-gtk4.png` enseña Archivos **en claro mientras
el shell va en oscuro**, con las carpetas de Yaru en berenjena. Comprar un tema
de fuera es comprar la mitad del escritorio y encima romper la coherencia.

Forkear Yaru conserva la coherencia y cambia el color. Y R8 deja de ser un
problema, porque Yaru no imita a nadie.

*Lo que sigue sin decidirse, y va después de medir el acento:* **el tamaño del
fork**. Si el acento admite un color propio, no hay fork. Si es una lista
cerrada, el fork puede ser sólo un acento más en un SCSS. Las dos decisiones que
lo acompañan —repo aparte y el nombre del paquete, que un `apt upgrade` puede
pisar en silencio— están en [0-decidir.md](0-decidir.md).

## El límite técnico, MEDIDO el 2026-08-14 — y no era el que yo decía

Lo que este fichero decía, y hay que corregir: *«en GNOME 46 un tema GTK3 ya no
pinta la mitad del escritorio; Archivos, Ajustes y el Centro de aplicaciones son
GTK4/libadwaita e ignoran el tema»*. **Como frase general es cierta; como
conclusión sobre Yaru, no.** Medido en `encina-dev`:

- **cada variante de Yaru trae su propia hoja `gtk-4.0/gtk.css`**, que importa un
  `gresource` con el tema entero, y la `libadwaita` de la base es
  `1.5.0-1ubuntu2` — parcheada. O sea que **Yaru sí llega a GTK4**;
- lo que no llega a GTK4 es **un tema que no traiga hoja `gtk-4.0`**, que es el
  caso de los de fuera;
- y **el tema del shell no tiene variantes**: hay uno solo, así que la barra
  superior y el resumen **no** cambian con el acento.

*Y de paso, una interpretación mía que era falsa:* de la captura de Archivos
—clara mientras el shell iba oscuro— deduje que el tema no llegaba. **No era
eso**: Archivos sale claro porque el `color-scheme` es claro, y el shell va
siempre oscuro en Ubuntu. Era el aspecto normal, no una grieta.

**Lo que sí resultó falso es la hipótesis del acento**, y con ella el orden de
todo lo barato: **no existe una clave `accent-color` en Ubuntu 24.04**. El acento
es un **nombre de tema** —`gtk-theme` e `icon-theme` a `Yaru-<acento>`—, hay diez
variantes cerradas y `#3A664E` no está entre ellas. Los detalles y los cuatro
verdes disponibles, en [2-golpes-baratos.md](2-golpes-baratos.md).

Consecuencia para el orden, que no cambia pero ahora se sabe por qué: hay **un
golpe barato de dos líneas** —ponerse uno de los cuatro verdes que ya viajan en
la máquina, sin paquete nuevo— y sólo después se decide si el verde exacto vale
un fork.

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
