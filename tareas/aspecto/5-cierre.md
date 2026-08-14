# 5 — El cierre

Lo que convierte «se ve bien hoy en mi VM» en algo que se puede entregar y que
seguirá viéndose bien mañana.

- [ ] **El verificador aprende a mirar el aspecto.** Hoy
      `imagen/verificar-instalacion.sh` da 52 de 52 sobre una máquina cuyo botón
      de aplicaciones lleva el logotipo de Ubuntu: **el aspecto no está en el
      perímetro**, y por eso puede romperse sin que nada se ponga rojo.
      Casillas: tema efectivo, tema de iconos, acento, tipografía, la alternativa
      de Plymouth y `GRUB_DISTRIBUTOR`.
      *Hecha cuando:* cada una **tiene su control negativo probado en rojo en la
      misma máquina**, y lo roto se restaura con huella idéntica. Es lo que se
      hizo con la lista de etapas del `telemetry`, y es lo único que demuestra que
      una comprobación comprueba: un `[OK]` se imprime igual aunque la línea de
      arriba esté neutralizada.
      *Y las que no se pueden automatizar se marcan `[OJOS]`*, con la cuenta hecha
      de antemano: **un agente no sabe pulsar un botón del invitado** —cinco vías
      descartadas y medidas en §4.35i—, así que abrir la rejilla necesita una
      mano, y eso se escribe **al escribir la casilla**, no al llegar a ella.

- [ ] **La foto del «después», y el par en el README.** Las seis capturas contra
      las seis del «antes».
      *Hecha cuando:* están en `design/capturas/despues/` y el par sale en el
      README — que es donde de verdad sirve, porque es lo único que le dice a un
      desconocido qué está mirando.

- [ ] **La oferta de fuente, al día.** Si entra un tema de terceros, es una fila
      nueva en la tabla «Licencia y fuentes» con su repositorio y su etiqueta, y
      un `debian/copyright` que lo diga. Y la licencia de las seis fotografías
      —[0-decidir.md](0-decidir.md)— también acaba ahí.
      *Hecha cuando:* la tabla del README describe todo lo que viaja y no una
      parte. Es obligación, no cortesía.

- [ ] **Reconstruir la ISO y comprobar que sigue saliendo igual.** Todo este
      bloque entra en los `.deb`, así que el Bloque 0 tiene que seguir de pie
      después: `construir-todo.sh` sobre un árbol limpio, y dos pasadas con la
      misma huella.
      *Hecha cuando:* dos construcciones seguidas dan la misma huella y
      `fabricar-iso.sh` sigue diciendo que los tres binarios firmados del arranque
      están intactos.
      *Y con el aviso que ya se pagó una vez:* cambiar los `.deb` **cambia la
      huella de la ISO**, así que `95758c9e…` deja de ser la que produce este
      repositorio. Eso no es un fallo — es lo que pasa —, pero hay que escribirlo
      donde esa huella esté citada, que son varios sitios.

- [ ] **Instalar desde cero y mirar la pantalla.** El aspecto no se entrega
      probado en la máquina donde se hizo.
      *Hecha cuando:* una instalación limpia enseña las seis pantallas con la
      identidad puesta, mirado por una persona, y el verificador da 0 fallos.
