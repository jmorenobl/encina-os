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
ubuntu-24.04.4-desktop-arm64.iso   c2610520…   la ENTRADA, firmada por Canonical
encina-os-E4-es-0.2.1.iso          ac0a5721…   el medio que SE PROBO: se arranco y se instalo
```

**`ac0a5721…` ya no se fabrica desde este repositorio** —lleva dentro los `.deb`
viejos y un seed que exige sus huellas, así que es coherente consigo misma y no
con el árbol de hoy— y se conserva porque es el único medio que alguien ha
arrancado de verdad. Lo que este repositorio produce hoy es
`95758c9e954d834f6324b6f5e0464741742478247d29a2637009ad03e2a8aef6`, medido en
cinco construcciones, **y todavía no lo ha arrancado nadie**.
