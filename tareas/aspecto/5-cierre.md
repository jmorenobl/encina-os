# 5 — El cierre

Lo que convierte «se ve bien hoy en mi VM» en algo que se puede entregar y que
seguirá viéndose bien mañana.

---

## EL ESTADO, 2026-08-15: ESTE FICHERO ES YA LO ÚNICO QUE QUEDA DE `aspecto/`

Los bloques 0, 2, 3 y 4 están **cerrados enteros**, y el 1 está **aplazado por
escrito**. O sea que estas cinco casillas son el bloque.

**Y el orden en que se pagan NO es el que están escritas.** Las dos últimas
—refabricar la ISO, e instalarla y mirarla— cuestan **una vuelta entera de
medio**, y ese precio es **por vuelta y no por cambio**: es el mismo argumento
con el que `ENCINA-OS.md` §7 metió todo E4 en una sola vuelta y con el que
[LEEME.md](LEEME.md) juntó lo de `encina-branding`. Pagarlo ahora por meter
0.1.15, y otra vez dentro de unos días por meter la marca del medio, **es pagarlo
dos veces**.

Así que la secuencia es:

| | Qué | Por qué ahí |
|---|---|---|
| 1 | Las **tres primeras** casillas de este fichero | Se hacen sin refabricar nada |
| 2 | [../marca-del-medio.md](../marca-del-medio.md) entero | Es lo que de verdad bloquea publicar, y toca el medio |
| 3 | Las **dos últimas** de este fichero, **una sola vez** | Con 0.1.15 **y** la marca del medio dentro |

*Lo que esto no cambia:* que **`1224b5b1…` ha caducado** — es la última que
produce este repositorio (§4.45), lleva `encina-branding` 0.1.11 y la buena es
0.1.15. Cierto desde hoy, aunque la refabricación se aplace hasta el paso 3.

*Y una corrección, porque la primera versión de este párrafo decía `95758c9e…`:*
se escribió **por el nombre de la VM del banco** —`encina-95758c9e`— y no por la
huella del fichero. Medidas las tres de `medios/` con `shasum`: `ac0a5721…` es la
entregada de E4 y la única arrancada, `95758c9e…` la primera reproducible, y
`1224b5b1…` la última. **Un nombre de VM no es una medición.**

---

- [ ] **El verificador aprende a mirar el aspecto.** Hoy
      `imagen/verificar-instalacion.sh` da 52 de 52 sobre una máquina cuyo
      aspecto **no está en el perímetro**, y por eso puede romperse sin que nada
      se ponga rojo.
      *Corrección del 2026-08-15:* esta casilla decía *«sobre una máquina cuyo
      botón de aplicaciones lleva el logotipo de Ubuntu»*, y **eso era falso** —
      el botón lleva la bellota desde 0.1.9 y lo que se estaba mirando era el
      icono de `gnome-initial-setup` ejecutándose. El ejemplo era malo; **el
      argumento se sostiene igual**, y de hecho lo refuerza: si el verificador
      hubiera sabido mirar el aspecto, el error se habría cazado en un día en vez
      de en tres.
      *Y ahora hay un ejemplo mejor, del mismo día y más caro:* con 0.1.14 el
      icono del Centro de aplicaciones **no se pintaba** —había un hueco en el
      dock— y **las cinco comprobaciones automáticas daban verde**, porque todas
      medían eslabones anteriores. La cadena es *existe → gana → resuelve →
      **carga** → se pinta*, y las casillas que se escriban aquí tienen que decir
      cuál de los cinco miden.
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
