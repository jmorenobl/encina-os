# `medios/` — lo que no cabe en git

Aquí viven las imágenes de disco: **la ISO oficial de Ubuntu, que es la entrada
de la construcción, y las que salen de ella**. Ninguna se versiona —son 3,3 GiB
cada una— y por eso este directorio está en `.gitignore` salvo este fichero.

**Lo que sí está versionado es la orden de traerla y el instrumento que sabe
avisar cuando ya no esté**, que es lo que de verdad hacía falta: los bytes se
vuelven a bajar, pero enterarse de que Canonical ha retirado tu punto de partida
no se improvisa.

## Traer la ISO oficial

```
./imagen/traer-iso-oficial.sh
```

Baja `ubuntu-24.04.4-desktop-arm64.iso` (~3,3 GiB) aquí dentro y **la comprueba
contra la firma de Canonical**, no sólo contra su huella. La diferencia importa:
el `SHA256SUMS` se baja del mismo sitio que la ISO, así que comprobar uno con
el otro no es un control independiente. La firma la hace una clave que ya viene
en el paquete `ubuntu-keyring`, y no hay que traerla de ningún servidor de
claves.

**macOS no trae `gpg`.** Si no lo hay, o se instala (`brew install gnupg`) o se
verifica en otra máquina:

```
./imagen/traer-iso-oficial.sh --verificador jorge@192.168.64.3 \
                              --llave ~/.ssh/encina-e2-medicion
```

Y si no hay ninguna de las dos cosas el guion **no se calla**: dice a gritos que
lo que hizo no es un control independiente.

## Las tres respuestas que sabe dar

| | qué significa |
|---|---|
| `[OK]` | la ISO está y sus bytes son los que Canonical firma |
| `[RETIRADO]` | el `SHA256SUMS` firmado de hoy **ya no contiene** esa huella. Canonical retira los *point releases* viejos cuando sale el siguiente. **Es un hallazgo, no un fallo**, y el guion **no** coge la versión nueva por su cuenta: cambiar la ISO de partida cambia lo que el producto lleva |
| `[OTROS BYTES]` | hay un fichero con ese nombre y **no** es el firmado. No lo sobrescribe: lo dice y para |

La huella no está escrita en este guion. La lee de `imagen/fabricar-iso.sh`, que
es quien la exige, para que los dos no puedan separarse; y el nombre del fichero
tampoco, que lo **deduce** buscando esa huella dentro del `SHA256SUMS` firmado —
que es justo lo que permite distinguir `[RETIRADO]` de `[OTROS BYTES]`.

## Construir

Con la ISO aquí, la vuelta entera es una orden
(`MEDICIONES.md` §4.39, `SCRIPTS.md`):

```
./imagen/construir-todo.sh --constructor jorge@192.168.64.3 \
                           --llave ~/.ssh/encina-e2-medicion \
                           --autofirma ~/Projects/encina-autofirma/salida \
                           --salida medios/encina-os.iso
```

## Qué hay aquí hoy, y no es lo mismo

```
ubuntu-24.04.4-desktop-arm64.iso        c2610520…  la ENTRADA, firmada por Canonical
encina-os-E4-es-0.2.1-1224b5b1.iso      1224b5b1…  EL DE HOY: encina-branding 0.1.11
                                                   dentro, fabricado dos veces con la
                                                   misma huella (§4.45). SIN ARRANCAR
encina-os-E4-es-0.2.1-95758c9e.iso      95758c9e…  el anterior, arrancado e instalado (§4.40)
encina-os-E4-es-0.2.1.iso               ac0a5721…  el de §4.35, que ya no se fabrica aqui
```

**Ojo con el `0.2.1` de los tres nombres:** es la versión de `encina-meta`, que no
ha cambiado. Lo que distingue a `1224b5b1…` de los otros dos es `encina-branding`
**0.1.11** —el acento salvia, el dock abajo y la bienvenida de Ubuntu fuera—, y
eso **no sale en el nombre**. Otra razón para cogerlas por huella.

**Fijese en que las dos de Encina son `E4`, `es` y `0.2.1`, y son ficheros
distintos** — y encima **pesan exactamente lo mismo**, 3 715 366 912 bytes. Por
eso la que se entrega lleva **la huella en el nombre**: la versión sola no las
distingue, y §4.35m ya se encontró con dos artefactos distintos compartiendo
nombre. **Se coge por huella, nunca por nombre.**

**`ac0a5721…` ya no se fabrica desde este repositorio** —lleva dentro los `.deb`
viejos y un seed que exige sus huellas, así que es coherente consigo misma y no
con el árbol de hoy— y se conserva porque durante un día fue el único medio que
alguien había arrancado.

**Y desde el 2026-08-13/14 ya no es el único: `95758c9e…` SE HA ARRANCADO E
INSTALADO** (`MEDICIONES.md` §4.40 y §4.41). VM desde cero sin ningún `CIDATA`,
las cinco pantallas contestadas a mano, el seed salido de
`/cdrom/autoinstall.yaml` y el repositorio del medio, los tres `.deb` nuevos
instalados y atados por huella, y `verificar-instalacion.sh --forma e3` en **52
correctas y 0 fallos**, con su rojo probado.

**Lo que todavía NO se ha hecho con ella, y es lo que separa «me funciona» de
«se la puedes dar a alguien»: instalarla en una máquina que no sea del banco.**
Todo lo medido es sobre una VM de UTM en el Mac del autor.

## `deb-historicos/` — lo único que no se puede rehacer

Los `.deb` **propios** de versiones ya superadas, rescatados el 2026-08-14 de
scratchpads de sesiones muertas antes de borrarlos. No están en
`imagen/repo-manifiesto.tsv` y **no salen del clon**: §4.37 midió que sus huellas
eran de **una construcción** —`dpkg-deb` dejaba pasar los mtimes que los ficheros
tuvieran en el disco, y ese dato no está en git—, así que si se pierden estos
bytes, se pierden.

Sirven para una sola cosa: **rehacer un medio histórico** si alguna vez hiciera
falta auditarlo. Para construir Encina OS hoy no valen ni deben usarse.

```
autofirma_1.9.1+encina2_all.deb        d5a0ebe1…
encina-branding_0.1.7_all.deb          d4205134…
encina-firefox-native_0.2.0_all.deb    3880b8aa…
encina-firefox-native_0.2.1_all.deb    972ec932…   <- OJO, leer abajo
encina-meta_0.1.1_all.deb              e15ce56f…
encina-meta_0.2.0_all.deb              85c8cc56…   (el que §4.35l salvo a proposito)
```

**Y AQUÍ HAY UNA TRAMPA QUE HAY QUE VER ANTES DE COGER NINGUNO: el nombre no
identifica el fichero.** `encina-firefox-native_0.2.1_all.deb` aparece **dos
veces con dos huellas distintas** — `972ec932…` aquí y `640f508e…` en el
manifiesto vigente. Mismo paquete, misma versión, **otros bytes**: es §4.37 otra
vez, la reconstrucción desde el clon cambió las fechas de dentro sin cambiar el
contenido. **Se coge por huella, nunca por nombre**, igual que las VMs.

## `rastro-95758c9e/` — la evidencia de §4.40

Lo que la máquina dejó escrito sola en la instalación del 2026-08-13/14, salvado
porque **el único punto que quedó abierto se discute sobre estos ficheros** y
hasta hoy sólo vivían en un scratchpad:

```
telemetry-instalacion.json          las 8 etapas, sin 'loading'
telemetry-sesion-viva.json          {"0":"keyboard"} — el mismo medio SIN instalar nada
ubuntu_bootstrap-*.log              los dos registros del cliente del instalador
verificar-instalacion-salida.txt    51 correctas, 1 fallo, entero
encina-seed.log                     lo que hizo el seed dentro, paso a paso
```

**Lo que es y lo que no es:** son los registros de **una** instalación y **un**
arranque de `95758c9e…`. No son un patrón contra el que comparar, y no
sustituyen a la transcripción de `MEDICIONES.md` §4.40 — que es la evidencia
(§4.35o). Están aquí porque el `debug.log` de UTM enseñó que lo que no se
transcribe se pierde.
