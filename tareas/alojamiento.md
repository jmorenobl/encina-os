# Bloque 3 — ALOJAMIENTO: 3,46 GB no caben en un release de GitHub

- [ ] **Elegir dónde vive la ISO.** GitHub no acepta adjuntos de release de más de
      2 GiB, y la nuestra son 3,46 GB. Las salidas son partirla en trozos con su
      guion de recomposición, o alojarla fuera.
      *Hecha cuando:* hay una URL que descarga, y su `sha256` **publicado al lado**.
      **SIGUE ABIERTA el 2026-08-29 (`MEDICIONES.md` §4.82a) y la decisión es de
      Jorge**: nada se ha subido a ningún sitio. Lo que está hecho es lo que no
      depende de la elección —`make trozos` (los trozos, y que `cat` los recompone
      en la huella), `make publicar` (el directorio con `SHA256SUMS` calculado y
      las notas con las huellas sustituidas desde él)— y las opciones de abajo,
      con su precio.
- [ ] **Publicar las huellas y cómo comprobarlas.** Una ISO sin huella al lado no
      se la puedes dar a nadie.
      **Preparada, no hecha (2026-08-29):** `imagen/preparar-publicacion.sh` deja
      `SHA256SUMS` calculado junto a los cuatro ficheros —y comprueba que `shasum
      -a 256 -c` pasa y que con una huella cambiada falla— y `NOTAS.md` con las
      cuatro huellas y la orden para comprobarlas (`shasum -a 256 -c SHA256SUMS` en
      macOS, `sha256sum -c` en Linux). Se marca cuando estén **al lado de la URL**
      de la casilla de arriba.

**Lo que hay que alojar, medido el 2026-08-29 (§4.82a):** `encina-os-arm64.iso`
3 721 265 152 bytes (3,47 GiB), `encina-os-amd64.iso` 6 849 232 896 bytes
(6,38 GiB), las dos cosechas (`encina-repo-arm64.tar` y `-amd64.tar`, ~180 y
~190 MB) y `SHA256SUMS`: **10,9 GB en total**. El límite de GitHub, citado de
su documentación: *«Each file included in a release must be under 2 GiB.
There is no limit on the total size of a release, nor bandwidth usage»* — así
que las cosechas, `SHA256SUMS` y las notas **caben en la release siempre**, y
lo que no cabe entero es cada ISO.

**Las opciones para las ISOs, con su precio, y la decisión es de Jorge:**

1. **La release de GitHub, con cada ISO en trozos de menos de 2 GiB**
   (`make trozos ARQ=…`: `arm64` en 2, `amd64` en 4; se recomponen con
   `cat` y aquí se mide que recompuestos dan la huella). Precio en dinero,
   cero, y no añade ninguna cuenta, dominio ni tarjeta que pueda caducar: dura
   lo que dure el repositorio. Precio para quien baja: seis ficheros y un `cat`
   antes del `shasum -c`, que las notas explican en dos líneas.
2. **Cloudflare R2 con un dominio propio** (un *bucket* público bajo un
   dominio que esté en Cloudflare; la cuenta y las herramientas ya están).
   Precio: 10 GB/mes de almacenamiento gratis y la salida no se cobra, así que
   los 10,9 GB cuestan céntimos al mes por el exceso; pero exige un dominio en
   Cloudflare (el subdominio `r2.dev` gratuito va limitado y no es para
   producción) y una tarjeta en la cuenta. Es la mejor experiencia —una URL,
   descarga rápida— y el mayor riesgo a un año: una cuenta o una tarjeta que
   caduca se lleva la URL.
3. **Internet Archive (`archive.org`)**, un ítem con los cinco ficheros.
   Precio: cero, sin límite de tamaño, URL estable
   (`archive.org/download/<ítem>/<fichero>`) y lo publicado es permanente —no
   se puede retirar del todo, que para el único acto irreversible del proyecto
   es coherente—. Lo malo: la descarga es lenta e irregular (del orden de 1 a
   5 MB/s: una ISO de 3,5 GB son entre 15 y 60 minutos) y su página enseña
   md5/sha1, no sha256, así que nuestro `SHA256SUMS` tiene que ir al lado.
4. **SourceForge**, que aloja ISOs de distribuciones con espejos ~~y enseña el
   SHA-256 en la página de descarga~~ *(corregido la misma tarde, §4.82h: lo
   que publica por fichero, en su RSS, es sólo `md5`; nuestro `SHA256SUMS` va
   al lado)*. Precio: cero y sin límite; exige registrar el proyecto allí y
   aceptar su página intermedia de descarga con publicidad. Dura mientras dure
   SourceForge, y es lo que usan muchas distribuciones pequeñas. **Medido
   (§4.82h): su URL canónica `downloads.sourceforge.net/project/…` redirige a
   un espejo con token, admite `Range`, y sirve de web seed.**
5. **BitTorrent con web seed, encima de cualquiera de las anteriores salvo la
   (1)** (añadida a pregunta de Jorge, §4.82h). Un `.torrent` por ISO —kilobytes,
   reproducible, sin tracker— con `url-list` a la URL del fichero entero;
   precio cero, la integridad de las piezas va dentro, la descarga se reanuda
   sola y cuando haya gente sembrando deja de depender del alojamiento. Lo malo:
   el usuario necesita un cliente de torrent, y una web seed muerta sin
   sembradores es un torrent muerto. **Medido con `aria2c` contra SourceForge
   sin ningún par: baja entero, y los dos controles (web seed cortada, pieza
   saboteada) fallan como tienen que fallar.** No encaja con GitHub en trozos.

**Jorge, la misma tarde:** *«creo que lo voy a hacer con SourceForge»*. Si se
confirma: el proyecto en SourceForge lo crea él (es una cuenta); el `.torrent`
pasa a `make torrent` con la URL canónica del proyecto, y `SHA256SUMS`, las
notas y los dos `.torrent` van también en la release de GitHub, atados al
commit.

**Recomendación (del agente, 2026-08-29):** la (1) como base en cualquier
caso —las cosechas, `SHA256SUMS`, las notas y los trozos en la release, atados
al commit, sin depender de nadie más—; y si se quiere una URL única para la
ISO, la (2) **además**, no en vez de: el enlace del README apunta a la URL
buena y los trozos de la release quedan como la copia que no caduca. Cuesta
subir 10 GB dos veces, una sola vez.
