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

**Al día 2026-08-29 (`MEDICIONES.md` §4.82), la primera sesión de la fase 3:**
hecho **todo lo que no depende de dónde vive la ISO**, y **nada subido a
ningún sitio** —esa decisión es de Jorge, `alojamiento.md`—. Ninguna casilla
de abajo se marca hoy; cada una lleva qué hay hecho y qué le falta.

- [ ] **La release, con lo que trae y lo que no.** Arquitectura, que exige red al
      instalar, y que Secure Boot no está demostrado.
      **Escrita, no publicada (2026-08-29):** [publicar/notas-plantilla.md](../publicar/notas-plantilla.md)
      es el texto —lo que trae, lo que no, cómo comprobar, cómo reproducir— y
      `make publicar` (`imagen/preparar-publicacion.sh`) lo deja en
      `medios/publicar/<versión>/NOTAS.md` con huellas, tamaños, versiones y commit
      **sustituidos desde `SHA256SUMS` y el manifiesto**, nunca a mano, y con el
      control de que no queda ningún marcador. Le falta la URL (`--url-base`) y el
      acto de crear la release. **Dos decisiones que van con ella, y son de
      Jorge:** el nombre de la etiqueta (propuesta: `v0.2.1`, la versión de
      `encina-meta`, que es la del producto; y la regla de que **un medio nuevo
      es una versión nueva de `encina-meta`**, para que una etiqueta nunca
      cambie de contenido), y **si se publica `arm64` habiéndolo probado en
      hierro sólo en `amd64`** (la pregunta de arriba; las notas lo dicen tal
      cual, sin letra pequeña).
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
  **Hecha salvo la palabra «publicado» (2026-08-29, §4.82b, §4.82c y §4.82d):**
  `cosechar-repo.sh --cosecha <dir|tar|URL>` coge los 25 de ARCHIVO por huella
  sin tocar el archivo, Mozilla ni Launchpad (y `--archivo/--mozilla/--launchpad`
  para cortarlos: el control), `construir-todo.sh` y `make` lo pasan
  (`COSECHA=`), `make cosecha ARQ=…` deja `medios/encina-repo-<arq>.tar` —los 29
  con su `Packages`, tar reproducible (dos pasadas, mismos bytes), **y la ISO de
  esa misma pasada cotejada con `SHA256SUMS`**: `63f360dd…` y `3d5d12a9…`—, y
  **un clon limpio, con las tres URLs en `http://127.0.0.1:1/`, `--cache` vacío,
  los dos tar servidos por HTTP local y `autofirma` sacado del tar, da las dos
  huellas** (§4.82d). Se marca cuando el tar del que se cosecha sea **el de la
  release**, no el servido desde este Mac.
- [ ] **Conservar también la ISO oficial `arm64`, la entrada** (añadida el
  2026-08-29, `MEDICIONES.md` §4.82a, trampa 69). La casilla de arriba protege
  los `.deb`; dentro de un año tampoco estará la entrada: `cdimage.ubuntu.com`
  sirve dos *point releases* y `old-releases.ubuntu.com` **sólo conserva
  `amd64`** (`24.04.1`, `.2` y `.3` están, y en ninguno hay
  `*-desktop-arm64.iso`). El día que salga `24.04.5`,
  `ubuntu-24.04.4-desktop-arm64.iso` no estará en ningún sitio de Canonical,
  `traer-iso-oficial.sh` dirá `[RETIRADO]` y la receta `arm64` se parará ahí
  **con la cosecha publicada y todo**. Son 3,3 GiB más que alojar (con su
  huella, `c2610520…`, y la firma de Canonical al lado), o aceptar por escrito
  que reproducir el `arm64` exige tener la ISO de aquel día. **Es una decisión
  de Jorge y va con la de `alojamiento.md`.** Hecha cuando: el clon limpio de la
  casilla anterior arranca desde la ISO oficial **bajada de donde diga esta
  casilla**, no de `medios/`.
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
      **Al día 2026-08-29: es de Jorge y sigue abierta.** Lo que hay que mirar, y
      en cuál de los dos medios, está fila a fila en [ojos.md](ojos.md) —las
      PENDIENTE de la tabla A son sobre `3d5d12a9…` en el Acer (menú de GRUB del
      medio, el instalador en español, el splash del medio, GDM con la identidad,
      el GRUB de la máquina instalada, los nombres en español, Firefox en
      `about:support`) y las de B.1 sobre `63f360dd…` (la bellota en oscuro, la
      firma en `valide.redsara.es` en un clon efímero, el menú de GRUB del medio,
      las diapositivas del instalador)—. Ningún guion de hoy toca lo que se ve:
      los dos medios son los mismos bytes que el 2026-08-25.
- [ ] **Poner el enlace en el README** y quitar de él la frase «todavía no hay una
      imagen que descargar».
      **Bloqueada por la URL (2026-08-29):** se hace en el mismo commit que la
      release, con la huella al lado del enlace, y la insignia
      «imagen: sin publicar» cambia con ella.
