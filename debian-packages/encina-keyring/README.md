# encina-keyring — la clave del repositorio de Encina OS, y su custodia

**Qué es.** El quinto paquete (D25, 2026-08-31): la clave pública con la que
Encina OS firma su repositorio de paquetes, y la fuente APT que apunta a él.
Dos ficheros, ninguno ejecutable:

- `/usr/share/keyrings/encina-archive-keyring.gpg` — la clave pública,
  huella `58A525AB990C4B8DC5AB3D240A007E6F65F8C7EF` (ed25519, solo firma,
  sin caducidad; generada el 2026-08-31).
- `/etc/apt/sources.list.d/encina.sources` — la fuente, con `Signed-By`
  apuntando a esa clave y **una sola suite (`encina`) para todas las series**,
  como hace Mozilla: así sobrevive al salto de versión de la base sin cambiar
  de nombre.

**El orden que importa (D25):** el repositorio remoto se publica —aunque esté
vacío— **antes** de que ninguna máquina instale este paquete. Una fuente cuyo
servidor no contesta convierte cada `apt update` en un error rc 100 (el patrón
medido en `MEDICIONES.md` §4.84e).

**Lo que este paquete no toca, a propósito:** la fuente local del medio
(`encina-local.list`). Medido en §4.84e: no hace ruido, no pisa versiones más
nuevas, y es lo que permite reinstalar los paquetes del medio sin red. No hay
`postinst` ni ningún otro script de mantenedor.

## La custodia de la clave privada, escrita (la exige la casilla C2)

- **Dónde vive:** en la VM constructora `encina-dev`, en el `GNUPGHOME`
  dedicado `~/.gnupg-encina` (permisos 700). Es la misma máquina donde `make
  repo` construirá y firmará los índices (C3): la clave vive donde firma.
- **El respaldo:** `~/Projects/claves-encina/encina-firma-SECRETA.asc` en el
  Mac de Jorge (directorio 700, fichero 600, **fuera de todo repositorio
  git** — comprobado al crearlo). El certificado de revocación queda en
  `~/.gnupg-encina/openpgp-revocs.d/` de la VM.
- **Quién la tiene:** Jorge. Nadie más; la CI no la ve ni la necesita (solo
  construye `.deb`, no firma repositorios).
- **Sin contraseña, y es una decisión con precio:** la firma es desatendida
  (`make repo` no puede preguntar), y quien tenga el portátil puede firmar —
  el mismo que puede hacer `git push` y subir a SourceForge, así que no añade
  una superficie nueva. Si un día se quiere contraseña:
  `GNUPGHOME=~/.gnupg-encina gpg --edit-key 58A525AB… passwd` en la VM, y
  `make repo` pasará a pedirla.
- **Cómo se rota:** se genera una clave nueva igual que ésta, se publica una
  versión nueva de `encina-keyring` que lleve **las dos** claves en el
  keyring durante una transición (las máquinas la reciben por el canal,
  firmado aún con la vieja), se pasa a firmar con la nueva, y una versión
  posterior retira la vieja. Si la clave se ha visto **comprometida**, no hay
  transición: clave nueva, keyring nuevo, y las máquinas existentes lo
  instalan a mano (la orden se publica en las notas de la release, como se
  hizo con el aviso de Firefox el 2026-08-31).

## Las máquinas que ya existen (C5)

No tienen la clave y no pueden recibirla por `apt`: es un paso a mano, una
vez, y se escribirá en el README del proyecto con la orden exacta y la huella
del `.deb` al lado cuando el canal esté en vivo (C3).
