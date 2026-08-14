# Diseño de Encina OS

**La regla de este directorio, y es la única que hay que recordar: aquí vive la
FUENTE; lo que viaja se GENERA desde aquí.**

Es la misma regla del Bloque 0 aplicada a lo que se ve. Allí el problema era que
para fabricar la ISO hacía falta *la ISO*; aquí el problema era el mismo con otro
disfraz: para tener los fondos había que sacarlos del paquete, porque nadie sabía
de dónde salían. Un activo que solo existe en su forma final **se hereda**, y lo
que se hereda no se puede auditar.

Así que:

| | Vive en | Qué es |
|---|---|---|
| **La fuente** | `design/` | maestros, decisiones, paleta, manifiestos |
| **Lo que viaja** | `debian-packages/*/src/…` | derivados, generados por `generar.sh` |

Nada de `design/` entra en un `.deb` directamente. Y ningún fichero de
`src/usr/share/backgrounds/` ni `src/usr/share/icons/` debería editarse a mano:
si hace falta cambiarlo, se cambia el maestro y se vuelve a generar.

## Qué hay aquí

```
identidad.md          a quién va dirigido, qué transmite, qué NO debe parecer
paleta.md             los colores con su papel y su motivo
paleta.tsv            los mismos, legibles por un guion — LA fuente de los hex
tipografia.md         la decisión de tipografía (abierta)

logotipo/
  encina.svg          el maestro
  usos.md             tamaño mínimo, aire, qué no hacer
iconos/               los iconos propios del tema Encina
fondos/
  manifiesto.tsv      origen, licencia y huellas: maestro -> derivado
  maestros/           los originales a resolución completa (NO versionados)
arranque/             piezas de Plymouth y GRUB
capturas/             las seis pantallas canónicas, antes y después

generar.sh            deriva lo que viaja, y comprueba que cuadra
```

## Los maestros de los fondos no viajan en el clon, y es a propósito

`design/fondos/maestros/` está en `.gitignore`: son cinco JPEG de ~2,7 MB cada
uno y el repositorio pesa kilobytes, que es la misma cuenta que decidió no meter
AutoFirma como submódulo.

Lo que sí viaja es **`fondos/manifiesto.tsv`**, con el origen de cada maestro, su
licencia, su `sha256` y el `sha256` del derivado que se envía. Es exactamente el
papel de `imagen/repo-manifiesto.tsv` con los 28 `.deb`: la lista versionada que
permite rehacer sin tener el original delante, y comprobar que lo rehecho es lo
mismo.

## Lo que este directorio todavía NO cierra

Se dice aquí y no en letra pequeña, porque es la mitad del agujero que sigue
abierta:

- **La orden que convierte un maestro en el fichero que viaja no se sabe.** Los
  maestros son 3936×2624 y lo que se envía es 3840×2160: hay un recorte y un
  redimensionado que se hicieron a mano el 2026-08-08 y no están escritos. El
  manifiesto tiene la columna preparada y **vacía**.
- **`02-activos.sh` sigue generando los degradados viejos.** `encina.jpg` y
  `encina-dark.jpg` dejaron de ser degradados el 2026-08-08, pero el guion sigue
  sabiendo fabricarlos, así que `--forzar` los sustituiría sin preguntar. Está
  escrito en `SCRIPTS.md` y sigue siendo verdad.

Las dos son casillas de `tareas/aspecto/1-instrumentacion.md`.
