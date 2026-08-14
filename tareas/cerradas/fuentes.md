# Bloque 2 — FUENTES: lo que publicar obliga a publicar

**BLOQUE CERRADO EL 2026-08-13.** Las cuatro casillas están marcadas, y ninguna
se cerró por decreto: dos ya estaban hechas y decían lo contrario —los forks
nacieron públicos y `encina-autofirma` ya se había publicado esa misma mañana—,
y las otras dos se escribieron. Lo que este bloque temía —publicar la ISO
incumpliendo la oferta de fuente— **ya no puede pasar**: la oferta está en el
README, con los cuatro repositorios y sus tags, y la CI de `encina-autofirma`
mide que reconstruye de verdad.

*Lo que este bloque NO desbloquea, dicho aquí para que nadie lo confunda:* que
la fuente esté publicada no fabrica la ISO. El `.deb` sigue sin viajar en el
clon y `cosechar-repo.sh` sigue sin existir — eso es el bloque 0.

- [x] ~~**Reescribir D5.**~~ **HECHA el 2026-08-13.** La celda de `ENCINA-OS.md`
      dice ahora lo que se decidió: **el repositorio es público y la imagen se
      publica en cuanto esté lista, declarando que es solo arm64**. Se reescribe
      —no se parchea— porque su motivo entero era el precio de publicar, y ese
      precio **está pagado**: los cuatro repositorios de la oferta de fuente son
      públicos y la oferta está escrita. «Solo arm64» pasa de ser un motivo para
      no publicar a ser **una línea de la release**, que es donde D9 quiere que
      viva un límite declarado. *Lo que sigue costando y queda escrito sin
      maquillar:* cortar imagen nueva ante un fallo de seguridad de AutoFirma
      sigue siendo obligación, y se retira el día de D14, no hoy.
- [x] ~~**Hacer públicos los tres forks**~~ (`clienteafirma`, `jmulticard`,
      `clienteafirma-external`). **Ya lo son**, comprobado el 2026-08-13: son forks
      de `ctt-gob-es`, así que nacieron públicos. Esta tarea no existía.
- [x] ~~**Hacer público `encina-autofirma`.**~~ **HECHO el 2026-08-13**, y
      comprobado midiendo y no recordando: `gh repo list` da `PUBLIC` para
      `encina-autofirma` y para los tres forks. La condición que llevaba escrita
      —*que su README diga por qué existe y cuándo se retira*— **se cumplió antes
      de darle al botón, no después**: aquel README abre con «Esto NO es
      AutoFirma» y lleva una sección «Cuándo se retira este repositorio» con la
      condición de D14 en forma de orden (`verificar-deb.sh` sobre el `.deb`
      oficial). Y su *hecha cuando* está entera: el `.deb` **se puede reconstruir
      desde fuentes públicas** —la CI clona los tres forks anclados en `v1.9.1`,
      `v2.1` y `v1.0.7`, construye y verifica; verde sobre `main`, ejecución
      `31715687820` del 2026-08-13T15:29Z— y **el README de Encina OS enlaza a
      ellas**.
- [x] ~~**Escribir la oferta de fuente en el README**, con el enlace, junto a la
      licencia.~~ **HECHA el 2026-08-13.** La sección «Licencia y fuentes» lleva
      una tabla con los seis sitios de donde sale lo que viaja —empaquetado y
      parche, los tres forks con su tag, los tres paquetes de Encina, y el resto
      sin modificar, con `imagen/repo-manifiesto.tsv` como lista de los 28—. No es
      una dirección de correo a la que pedirla: son enlaces. Y va con la
      advertencia que evita el malentendido caro: **ese AutoFirma parcheado no es
      una versión mejor que el oficial**, es una muleta con condición de retirada.
