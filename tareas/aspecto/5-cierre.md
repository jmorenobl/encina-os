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

- [x] ~~**Reconstruir la ISO y comprobar que sigue saliendo igual.**~~ **HECHA EL
      2026-08-17 (`MEDICIONES.md` §4.54b): `ac175f648b6406bd…`, 3 721 265 152
      bytes, DOS PASADAS LA MISMA HUELLA** desde `b9b0de09`, 66 `[OK]` cada una y
      los tres binarios firmados intactos, con el control de que la comparación
      sabe decir «distintas» contra `1224b5b1…`. La huella que este repositorio
      produce **ya no es `95758c9e…`**, y eso es lo que tenía que pasar al cambiar
      los `.deb`.
      **Reconstruir la ISO y comprobar que sigue saliendo igual.** Todo este
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
      **INTENTADA EL 2026-08-17 Y NO SE PUDO: NO HAY INSTALACIÓN**
      (`MEDICIONES.md` §4.54d/f). La ISO `ac175f64…` arranca hasta la sesión viva
      —usuario `encina`, escritorio en español— y ahí **el instalador se cae**:
      «Se produjo un problema». Así que esta casilla **no ha empezado**, y no por
      el aspecto. **Y aunque arrancara, no enseñaría la identidad:** la capa de
      marca no se monta, así que el fondo, el título de la ventana, las
      diapositivas y `os-release` siguen siendo los de Ubuntu.
      *Lo que se aprendió y sirve para cuando se retome:* la VM se fabrica desde
      cero sin tocar la interfaz, la sesión viva se pilota con
      `scripts/teclear-vm.sh` y se lee con `scripts/leer-pantalla.m` —con el
      control de mirar la captura con los ojos—, y **dos caracteres más que no
      llegan al invitado: `|` y `&`**, que se suman a `=` y `@`.

      ---

      **HECHA EL 2026-08-22 POR FIN —LA INSTALACIÓN OCURRIÓ— Y LA CASILLA SIGUE
      ABIERTA, PERO YA NO POR LO MISMO** (`MEDICIONES.md` §4.61). El medio
      `p10-capa` arrancó, el instalador salió en español, Jorge contestó las
      cinco pantallas, la instalación **terminó** y la máquina **arranca de su
      disco**, 2 de 2. O sea que lo que bloqueaba desde el 2026-08-17 —«no hay
      instalación»— **está resuelto**.

      **Lo que la casilla encontró, y es para lo que existía:**

      ```
      verificar-instalacion.sh --forma e3 --visibles 27, como root:
      [OK] 41   [FALLO] 20   [AVISO] 1   [OMIT] 0
      ```

      **La máquina instalada no lleva NI UNO de los cuatro paquetes de Encina**,
      y los veinte fallos cuelgan de ahí. El síntoma se vio en la **primera
      pantalla**, antes de entrar: **el logotipo de GDM es el de Ubuntu**, y en
      `design/capturas/despues/03-gdm.png` es la encina.

      **La causa está medida, con nombre y versión:** falta **`libnss3
      2:3.98-1ubuntu0.2`** en los 28 `.deb` de `/encina-repo`. `libnss3-tools`
      **sí** viaja y exige a su hermano en esa misma versión; sin él, `apt
      install encina-meta` tiene que salir a la red, **y en el `chroot` de
      `curtin` no hay DNS** —lo normal, y el propio seed lo mide en su paso 7—.
      Un `.deb` que no se puede traer aborta la **transacción entera**.

      *Lo que esto NO era, y conviene decirlo porque era lo primero que se pensó:*
      no es que el repositorio no viajara —`encina-local.list` está puesto y el
      Firefox nativo 153.0.4 **sí** se instaló desde él—, ni una regresión del
      aspecto.

      **AL DÍA 2026-08-22 (tarde) — los tres puntos de abajo, hechos salvo la
      instalación. Marcador y detalle en `MEDICIONES.md` §4.62.**

      1. ~~Meter `libnss3` en el manifiesto y rehacer la cosecha~~ **HECHO**:
         28 → 29, `cuadran 29 de 29`. **Y la búsqueda de más huecos dio que NO
         los hay:** medido sobre las **tres** transacciones que el seed hace
         contra el repo, `libnss3` era **el único**. La predicción decía lo
         contrario y se deja escrita: no hay una familia de `.deb` partidos,
         hay **un archivo de Ubuntu que se mueve mientras el manifiesto no**.
      2. ~~Que se compruebe solo~~ **HECHO: `imagen/banco-autosuficiencia.sh`.**
         Corre en **segundos sin arrancar nada** y, desde fuera, saca **la misma
         línea `Inst libnss3`** que el `seed.log` escribió dentro de la máquina.
         Con el repo de 29: **25 de 25 líneas dicen `localhost`**. Su control
         quita `simple-scan` del índice y lo señala.
         **OJO al leerlo dentro de seis meses:** la guarda salió **ciega dos
         veces**, y no por el `dpkg status` sino por **las listas de `apt` —con
         las cacheadas en el squashfs no pide `libnss3`—. Y **no se le exige
         `full-upgrade`**, que no puede ser autosuficiente ni debe.
      3. **PENDIENTE, y es lo único que queda de la casilla.** Antes de
         reinstalar hay **una vuelta que hay que pagar y no estaba en esta
         lista**: un medio con el `; true` **fuera** y el repo **todavía sin
         `libnss3`** tiene que enseñar «Se produjo un problema». Sin ese medio,
         «arreglado» es otra lectura de código —que es como nació el fallo—.
         Los dos medios están fabricados:

         ```
         control : encina-os-control-sin-libnss3.iso  19587dd4…   <- arrancado y esperando
         bueno   : encina-os-libnss3.iso              cd84d2ec…
         ```

         **Las cinco pantallas las contesta Jorge** (K2: el instalador no se
         recorre con teclado), y los `[OJOS]` y la foto del «después» siguen
         **bloqueados** hasta que el verificador dé 0 fallos.
