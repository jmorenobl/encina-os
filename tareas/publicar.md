# Bloque 4 — PUBLICAR

**FASE 3, Y ES LO ÚLTIMO DEL PROYECTO — decidido por Jorge el 2026-08-23.** Antes
van, en este orden: **(1)** que las ISOs se prueben de verdad —el hierro `amd64`
en el portátil AMD A9 y la vuelta única `arm64`— y **(2)** la refactorización
entera, [refactorizacion.md](cerradas/refactorizacion.md). El motivo, en una frase:
**publicar es el único acto de este proyecto que no se puede deshacer**, y un
acto irreversible va detrás de los reversibles. El argumento completo, y el
anterior dejado al lado, en `TAREAS.md`, «El orden cambia el 2026-08-23».

**Consecuencia para la segunda casilla, y no la marca nadie por el camino:** el
hierro de la fase 1 contesta *«en una máquina que no sea del banco»* **para
`amd64`**, y el producto que `D9` declara es **`arm64`**, que en ese portátil no
arranca. Así que la casilla **sigue abierta** cuando la fase 1 termine, y lo que
llega aquí es una pregunta que se decide **a sabiendas**: ¿se publica `arm64`
habiéndolo probado en hierro sólo en `amd64`, o se busca antes un hierro `arm64`?

**Y una consecuencia de la fase 2 que hay que tener presente al llegar:** la
refactorización toca `imagen/fabricar-iso.sh`, así que **la ISO se refabrica una
última vez aquí**, con los guiones ya en su forma definitiva, y **la huella que
se publique será la de entonces** — ninguna de las de hoy.

- [ ] **La release, con lo que trae y lo que no.** Arquitectura, que exige red al
      instalar, y que Secure Boot no está demostrado.
- [ ] **Publicar la cosecha con la ISO, no sólo la ISO** (añadida el 2026-08-28,
  `MEDICIONES.md` §4.81f, trampa 68). El archivo de Ubuntu retira las versiones
  superadas y el manifiesto ancla una: `cosechar-repo.sh` cae a Launchpad por
  huella y eso cubre todo lo de Ubuntu para siempre, pero **Firefox viene de
  `packages.mozilla.org` y no tiene fuente permanente**: el día que Mozilla
  publique la 153.0.5, la receta pública se para en «`[RETIRADO] … Launchpad
  tampoco lo tiene`». Así que la release lleva, además de las dos ISOs y
  `SHA256SUMS`, **los 29 `.deb` de `/encina-repo` por arquitectura** (el
  directorio que deja `construir-todo.sh --trabajo <dir> --conservar`, con su
  `Packages`), con sus huellas, y `cosechar-repo.sh` tiene que saber cosechar
  **desde esa release** (`--propios` ya copia por huella: es la misma vía). Hecha
  cuando: un clon limpio, sin archivo ni Launchpad (`--cache` vacío y las URLs
  cortadas), reproduce las dos huellas sólo con lo publicado.
- [ ] **Instalarla desde cero como lo haría un desconocido**, en una máquina que
      no sea del banco, y **mirando la pantalla**.
      *Hecha cuando:* arranca, se instala contestando lo que pregunta, y
      `verificar-instalacion.sh` como root da 0 fallos.
      **NO SE MARCA, y lo que falta es UNA palabra de la casilla.** El 2026-08-13
      se hizo todo lo demás (`MEDICIONES.md` §4.40): arrancó, se instaló
      contestando las cinco pantallas mirándolas, y el verificador da **52
      correctas y 0 fallos**. Lo que **no** se cumple es *«en una máquina que no
      sea del banco»*: fue una VM de UTM en este mismo Mac. **Y esa palabra no es
      un detalle de forma** — es lo único que separa «me funciona a mí» de «se la
      puedes dar a alguien», y es justo lo que este bloque promete. Hace falta
      hardware real, o al menos otro anfitrión.
- [ ] **Poner el enlace en el README** y quitar de él la frase «todavía no hay una
      imagen que descargar».
