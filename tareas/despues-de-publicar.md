# Después de publicar

- [ ] **E5 — la imagen propia** (`live-build`/`debos`). El destino declarado. Solo
      compra dos cosas, y son las que este proyecto quiere: marcar el propio
      instalador y controlar el conjunto base. Si el bloque 1 se hace aquí, se hace
      una vez en vez de dos.
- [ ] **El núcleo en el medio.** Hoy la instalación **exige red**, y es un límite
      declarado con la forma de D9: está leído hasta el final. Cuesta **1 089 MB**
      —`linux-firmware` son 655— y saca la ISO del DVD de una capa y del límite de
      FAT32. La vía está nombrada y **no medida**: re-firmar el `dists/` del medio
      con clave propia. **Es una decisión de producto, no una deuda.**
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
      Falta la ISO base `amd64` y **un constructor `amd64`** —el de hoy es una VM
      arm64—, que puede ser el propio portátil. Y sigue haciendo falta **repetir
      allí el positivo de extremo a extremo**.
