# Roadmap de Encina OS

**Esto es intención de producto, no trabajo hecho ni medido.** Lo escribió
Jorge el 2026-08-30, el día siguiente a publicar `0.2.1`, y se guarda aquí para
que las tareas tengan un norte. Las reglas de este directorio:

- **El roadmap dice el «qué» y el «por qué»; el «cómo se sabe que está hecho»
  vive en [tareas/](../tareas/)**, casilla a casilla. Aquí no hay casillas que
  marcar: cuando un punto del roadmap se convierte en trabajo, se abre (o se
  enlaza) su fichero de tareas, y es ése el que se cierra.
- **Cada punto o enlaza a su tarea, o dice `[SIN TAREA]`** — que significa «es
  intención y nadie ha delimitado todavía qué costaría».
- **Nada de aquí promete fechas.** Una versión sale cuando su lista está
  medida, no cuando llega un día del calendario.
- **Los nombres `v1`, `v2`, `v3` son hitos de producto**, no la regla técnica
  de numeración: esa regla —cómo se mueve el número con los tres relojes
  (base, paquetes, medio)— está **sin decidir** y es la casilla A1 de
  [tareas/actualizacion.md](../tareas/actualizacion.md). Cuando A1 se decida,
  manda A1; si contradice a este directorio, se enmienda este directorio.

## Las versiones

| Hito | Qué significa | Estado |
|---|---|---|
| **v0** — hoy es `0.2.1` | **El experimento, publicado**: demostrar que una persona sola puede fabricar una derivada de Ubuntu reproducible, con la firma electrónica funcionando de fábrica, y escribir todo lo que mide. Está publicado en SourceForge y GitHub desde el 2026-08-29 | **Cumplido** con los límites escritos en las notas de la release: sin canal de actualización, sólo Firefox, sin DNIe, `arm64` sin hierro |
| **[v1](v1.md)** — el sistema que se puede recomendar | Actualizable sin reinstalar, con respaldo, DNIe, Chromium además de Firefox, sin decir Ubuntu donde se ve, y con las sedes a un clic | Abierto: dos de sus siete puntos ya tienen bloque de tareas ([actualizacion.md](../tareas/actualizacion.md)); el resto, delimitado en [v1.md](v1.md) |
| **[v2](v2.md)** — la cara propia de verdad | El tema derivado de Yaru personalizado entero, **y E5**: el medio e instalador propios (decisión de Jorge, 2026-08-30) | `[SIN TAREA]` — delimitado en [v2.md](v2.md) |
| **[v3](v3.md)** — aparcamiento de ideas | Robustez, facilidad de uso, aplicaciones propias (control parental…) | Ideas sin delimitar, a propósito |

## Lo que este roadmap no cambia

Las invariantes del proyecto siguen mandando sobre cualquier punto de esta
lista: la base no se modifica (D3), ningún paquete de este repositorio cierra
barreras de la firma (D13, eso es de AutoFirma), y nada se declara terminado
sin ejecutar su definición de terminado. Un punto del roadmap que choque con
una decisión `D` de [ENCINA-OS.md](../ENCINA-OS.md) no la salta: obliga a
enmendarla por escrito, con fecha, o a retirarse.
