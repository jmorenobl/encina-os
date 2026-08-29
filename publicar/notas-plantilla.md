# Encina OS @VERSION@ — distribución derivada de Ubuntu con la firma electrónica española funcionando de fábrica

Distribución derivada de Ubuntu 24.04.4 LTS **sin modificar la base**, con
cuatro paquetes encima y un instalador que los pone solo: `encina-branding` @V_BRANDING@,
`encina-firefox-native` @V_FIREFOX_NATIVE@, `encina-meta` @V_META@ y
`autofirma` @V_AUTOFIRMA@. Entrar en una sede electrónica con el certificado,
pulsar «Firmar» y que el documento salga firmado — con el Firefox de Mozilla,
no el de Snap, que es donde la firma fallaba en silencio.

Todo lo que hace está medido y escrito, incluido lo que salió mal:
[MEDICIONES.md](https://github.com/jmorenobl/encina-os/blob/@COMMIT@/mediciones/LEEME.md).

## Lo que trae

| Fichero | Bytes | SHA-256 |
|---|---|---|
| `encina-os-arm64.iso` — **el producto**, para Apple Silicon (UTM/Parallels/VMware) y equipos ARM de 64 bits | @TAM_ISO_ARM64@ | `@SHA_ISO_ARM64@` |
| `encina-os-amd64.iso` — para Intel/AMD; instalado y verificado en hierro (Acer Aspire ES1-524) | @TAM_ISO_AMD64@ | `@SHA_ISO_AMD64@` |
| `encina-repo-arm64.tar` — los 29 `.deb` que viajan en `/encina-repo` de la ISO arm64, con su `Packages` | @TAM_REPO_ARM64@ | `@SHA_REPO_ARM64@` |
| `encina-repo-amd64.tar` — los mismos 29 para amd64 | @TAM_REPO_AMD64@ | `@SHA_REPO_AMD64@` |
| `encina-os-arm64.iso.torrent` — el torrent de la ISO arm64, con *web seed* a la URL de arriba y sin tracker | | `@SHA_TORRENT_ARM64@` |
| `encina-os-amd64.iso.torrent` — lo mismo para amd64 | | `@SHA_TORRENT_AMD64@` |
| `SHA256SUMS` — las huellas de arriba, calculadas y no escritas a mano | | |

**Dónde se baja:** las dos ISOs (y todo lo demás) en `@URL_BASE@/<fichero>`
—SourceForge, que redirige a un espejo cercano—; también con cualquier cliente
de BitTorrent abriendo el `.torrent`, que baja de esa misma URL aunque nadie
siembre y comprueba cada pieza al llegar. Los `.torrent`, las cosechas,
`SHA256SUMS` y estas notas están además en la release de GitHub, atados al
commit.

Los dos `.tar` **no son para instalar**: la ISO ya lleva esos `.deb` dentro.
Son para **volver a fabricar esta misma ISO** dentro de un año, cuando el
archivo de Ubuntu y Mozilla hayan retirado las versiones exactas que ancla
(abajo, «Reproducirla»).

## Lo que NO trae, sin letra pequeña

- **Exige red al instalar.** El núcleo de Ubuntu no viaja en el medio y lo baja
  el instalador (como la ISO oficial). Los cuatro paquetes de Encina y sus
  dependencias sí van dentro.
- **Secure Boot no está demostrado.** El banco de pruebas no lo aplica y no se
  ha medido en ninguna máquina con él activado.
- **`arm64` es el producto** que el proyecto declara; se ha instalado y mirado
  en máquina virtual. **`amd64`** se ha instalado en hierro, sin red, y mirado.
  Lo que queda por mirar, y en cuál de los dos, está en
  [tareas/ojos.md](https://github.com/jmorenobl/encina-os/blob/@COMMIT@/tareas/ojos.md).
- **Certificado software de la FNMT.** DNIe con lector no está medido.
- **Firefox.** Chrome y Chromium no se han medido; no los des por buenos.
- El sistema instalado sigue diciendo `ID=ubuntu` en `/etc/os-release`, a
  propósito: es Ubuntu, y así lo ven los programas.

## Comprobar lo que has bajado, antes de grabar nada

```
# macOS
shasum -a 256 -c SHA256SUMS
# Linux
sha256sum -c SHA256SUMS
```

Tiene que decir `OK` en cada línea. Si la ISO vino en trozos
(`encina-os-arm64.iso.parte-aa`, `-ab`, …), primero se recompone y luego se
comprueba:

```
cat encina-os-arm64.iso.parte-* > encina-os-arm64.iso
```

## Reproducirla

Esta ISO sale **byte a byte** del commit `@COMMIT@` de
[jmorenobl/encina-os](https://github.com/jmorenobl/encina-os), dos pasadas y la
misma huella. Hace falta un Mac con `xorriso`, un Ubuntu 24.04 arm64 al que
llegar por `ssh` (construye los tres `.deb` y el índice), la ISO oficial de
Canonical comprobada contra su firma (`./imagen/traer-iso-oficial.sh`), y la
cosecha de arriba en vez del archivo, que ya no sirve las versiones ancladas:

```
git clone https://github.com/jmorenobl/encina-os && cd encina-os
git checkout @COMMIT@
./imagen/traer-iso-oficial.sh
mkdir -p cosecha && tar -xf encina-repo-arm64.tar -C cosecha
make dos-veces ARQ=arm64 CONSTRUCTOR=usuario@vm-ubuntu \
     COSECHA=@URL_BASE@/encina-repo-arm64.tar AUTOFIRMA=cosecha/encina-repo-arm64
```

`make dos-veces` fabrica el medio dos veces y sólo lo deja si las dos huellas
coinciden; la que tiene que salir es la de la tabla. Con `ARQ=amd64` y el otro
`.tar`, la otra.

## Licencia

Los paquetes de Encina, EUPL-1.2. Ubuntu y Firefox, los suyos, sin modificar.
Proyecto independiente: sin relación con la Administración General del Estado,
la FNMT ni Canonical. Ubuntu es una marca de Canonical Ltd.; esta distribución
ni está publicada ni avalada por Canonical.

*Notas generadas el @FECHA@ por `imagen/preparar-publicacion.sh` desde `SHA256SUMS`
y `imagen/repo-manifiesto.tsv`; ninguna huella de esta página está escrita a mano.*
