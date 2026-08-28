# Mediciones de Encina OS

**Desde el 2026-08-28 el registro vive en [`mediciones/`](mediciones/), un fichero
por sección**, y este fichero es sólo el puntero — se conserva con su nombre
porque `CLAUDE.md`, `AGENTS.md`, `SCRIPTS.md`, los guiones y el `MEDICIONES.md`
del repositorio hermano lo citan así, y porque **la forma de citar no cambia**:
una sección sigue siendo `MEDICIONES.md §4.37`, y su apartado (c), `§4.37c`.
`bancos/enlaces.sh` resuelve esas citas contra `mediciones/*.md`.

Empieza por [`mediciones/LEEME.md`](mediciones/LEEME.md): tiene lo que este
fichero tenía en su cabecera —cómo leer el registro y **la tabla de vigencia**,
que es lo que dice qué de lo escrito sigue en pie— y el índice de las 82
secciones con su fichero.

**Por qué se partió** (tarea 4 de [tareas/refactorizacion.md](tareas/refactorizacion.md)):
el fichero único medía 19 399 líneas y `CLAUDE.md` manda consultarlo *antes de
investigar cualquier cosa*; con ese tamaño la regla era físicamente incumplible
y el resultado práctico era investigar sin consultarlo. Se movió **verbatim**,
con el control de que los 82 ficheros concatenados reconstruyen el original
byte a byte (`mediciones/.orden.tsv` guarda el orden y las líneas de origen).

**Cómo se añade una sección nueva:** un fichero `mediciones/4.NN-<qué>.md` cuyo
primer línea sea `# 4.NN TÍTULO (fecha)`, una fila en la tabla de vigencia de
`LEEME.md` —`bancos/vigencia.sh` avisa si falta— y una fila en su índice.
