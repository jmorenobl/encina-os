# Después de publicar

**AVISO DEL 2026-08-23: EL NOMBRE DE ESTE FICHERO YA NO DESCRIBE LO QUE HAY
DENTRO, Y SE DEJA ASÍ A PROPÓSITO.** De las tres cosas que lista, **`amd64` (E6)
ya no es «después de publicar»: es la FASE 1 y está en curso** —`ENCINA-OS.md`
§7, la receta del hierro—. Las otras dos —**E5** y **el núcleo en el medio**— sí
siguen siendo posteriores a publicar. Renombrar y repartir el fichero es trabajo
de la refactorización (fase 2), no de hoy: moverlo ahora rompería referencias
antes de que exista `bancos/enlaces.sh`, que es la tarea 1 de ese bloque.

**Y el orden entero, decidido por Jorge el 2026-08-23:** (1) que las ISOs
funcionen probadas de verdad, (2) la refactorización entera, (3) publicar, que
pasa a ser **lo último**. Está en `TAREAS.md`, «El orden cambia el 2026-08-23».

- [ ] **E5 — la imagen propia** (`live-build`/`debos`). El destino declarado. Solo
      compra dos cosas, y son las que este proyecto quiere: marcar el propio
      instalador y controlar el conjunto base. Si el bloque 1 se hace aquí, se hace
      una vez en vez de dos.
- [ ] **El núcleo en el medio.** Hoy la instalación **exige red**, y es un límite
      declarado con la forma de D9: está leído hasta el final. Cuesta **1 089 MB**
      —`linux-firmware` son 655— y ~~saca la ISO del DVD de una capa y del límite de
      FAT32~~. La vía está nombrada y **no medida**: re-firmar el `dists/` del medio
      con clave propia. **Es una decisión de producto, no una deuda.**

      **ENMIENDA DEL 2026-08-22, y la levantó Jorge: LOS DOS LÍMITES QUE FRENABAN
      ESTO YA NO FRENAN.** *«Ya nadie instala usando DVD. Se usan pinchos USB.»*

      - **El DVD de una capa (4,7 GB) no es un límite de nada** si el medio se
        entrega en USB. Era el límite de un soporte que ya no se usa.
      - **Y el de 4 GiB por fichero de FAT32 tampoco aplica al caso real**: una
        ISO se escribe **cruda** al pincho (`dd`, Rufus, balenaEtcher) y ahí no
        hay sistema de ficheros que la contenga como fichero. Sólo mordería si
        alguien **copiase el `.iso` DENTRO** de un pincho formateado en FAT32,
        que no es cómo se instala.

      **Lo que queda en pie de la objeción, y es lo único:** los 1 089 MB y **el
      límite de 2 GiB por adjunto de una release de GitHub**
      ([alojamiento.md](alojamiento.md)) — que ya se pasa hoy con 3,46 GB, así que
      **crecer a ~4,7 GB no cambia de categoría el problema: lo empeora en grado,
      no en clase.**

      *Lo que se creía, dejado al lado:* que meter el núcleo sacaba el medio «del
      DVD y de FAT32», o sea de dos formatos de entrega. Ninguno de los dos era el
      formato de entrega.
- [ ] **amd64 (E6).** ~~No es prioridad. Necesita con qué probarlo~~ — **ESA RAZÓN
      CADUCÓ EL 2026-08-22: Jorge tiene un portátil Intel/AMD donde instalar.** Y
      con ello E6 pasa a ser **lo siguiente**, por delante de publicar, porque es
      **la única vía para contestar a Plymouth** (`design/capturas/despues/entrega-cd84d2ec/LEEME.md`)
      y porque el medio actual **no arranca en ese portátil**: es `arm64` puro.
      *Lo que cuesta, medido el 2026-08-22 y no estimado:*
      ```
      los CUATRO paquetes de Encina son _all.deb  -> NO hay que reconstruirlos
      el repo offline: 29 .deb = 14 _all + 15 _arm64  -> cosechar QUINCE
      fabricar-iso.sh nombra la arquitectura en 14 lineas; 29 en todos los guiones
      ```
      ~~Falta la ISO base `amd64` y **un constructor `amd64`** —el de hoy es una VM
      arm64—, que puede ser el propio portátil.~~ Y sigue haciendo falta **repetir
      allí el positivo de extremo a extremo**.

      **AL DÍA, 2026-08-22 (noche): CASI TODO ESTO YA ESTÁ HECHO, y una de las
      dos cosas que faltaban NO hacía falta** (`MEDICIONES.md` §4.64):

      - **La ISO base `amd64` está**, y de paso se descubrió que **no vive en el
        servidor de la `arm64`**: `cdimage` no sirve `amd64`; es
        `releases.ubuntu.com/24.04`, con la misma firma de Canonical.
      - **NO hace falta un constructor `amd64`, y era una deducción falsa.**
        Medido con su control: `dpkg-scanpackages` en la VM `arm64` indexó los
        29 `.deb` (14 `all` + 15 `amd64`) y `apt-get -s` con
        `APT::Architecture=amd64` resolvió **394 paquetes** desde esa misma
        máquina. El portátil hace falta para **arrancar** el medio, no para
        fabricarlo.
      - **El medio existe:** `encina-os-amd64.iso` `8924f148…`, 49 correctas y 0
        fallos, y **el `arm64` sigue saliendo `cd84d2ec…` byte a byte**.
      - **Arranca, con la marca puesta y en español** — pero **el instalador se
        cae** y de quién es no se sabe todavía. Los tres controles que lo
        separarían están escritos en §4.64(l).
      - **Y sube el listón de `alojamiento.md`:** la ISO oficial `amd64` pesa
        **6,20 GiB** contra 3,30 de la `arm64`, así que el medio nuestro sale a
        **6,38 GiB** y hay que publicar **dos**.
