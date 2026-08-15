# 4 — Arranque y pantalla de inicio de sesión

Las dos pantallas que se ven antes de que exista una sesión, y la que la abre.
Son las que más delatan la marca ajena y las que menos se miran, porque duran
segundos.

- [x] ~~**Plymouth, mirado a resolución de verdad.**~~ **CERRADA EL 2026-08-15
      POR LA SEGUNDA MITAD DE SU «HECHA CUANDO»: está escrito dónde no se ve y
      por qué.** El límite, con la forma de D9 y leído hasta el final:

      > **En el banco de UTM, el tema de arranque de Encina no se dibuja nunca, y
      > no porque esté mal.** Cumple R6 —se basa en `spinner`, no en `bgrt`—,
      > cumple R7 —el `postinst` ejecuta `update-initramfs -u`—, está instalado y
      > registrado como alternativa. Lo que pasa es que **la pantalla del
      > invitado está apagada todo el arranque**: tres arranques desde frío de
      > `encina-95758c9e` con `scripts/capturar-aspecto.sh` dan del segundo 9 al
      > 20 —y hasta el 48 en otra pasada— «Display output is not active» de UTM
      > encima, entre 5 y 14 fotogramas seguidos. **No es un parpadeo que se
      > escapara entre disparos: es la fase entera.** La sospecha razonable, y
      > sigue sin medir, es el `virtio-gpu` de UTM apagando la salida mientras el
      > núcleo toma el control del modo de vídeo.
      > **Lo que esto NO dice:** que el tema esté roto. Nadie lo ha visto, ni
      > bien ni mal. Es un límite **del instrumento**, no un resultado sobre el
      > producto, y por eso no se marca ninguna casilla de aspecto diciendo que
      > el arranque tiene cara propia.
      > **Cómo se levanta el límite, el día que se quiera:** arrancando la ISO en
      > una máquina que no sea esta VM. Es la primera cosa que hay que mirar en
      > hardware real, antes de tocar una línea del tema — y si allí tampoco se
      > ve, entonces sí es del producto.

      *Y una consecuencia que se lleva por delante media casilla de otro fichero:*
      la lista canónica de pantallas de [1-instrumentacion.md](1-instrumentacion.md)
      decía seis, y ésta es una de las dos que **no existen en esta máquina**.

      *Lo que decía la casilla, con su medición, que es de donde sale todo lo de
      arriba:* hay tema propio, está
      instalado y las dos reglas caras ya están resueltas: **R6**, se basa en
      `spinner` y nunca en `bgrt` —que enseñaría el logotipo del firmware del
      fabricante y el propio no aparecería jamás—, y **R7**, el `postinst`
      ejecuta `update-initramfs -u`, sin lo cual no se observa ningún cambio y el
      fallo es silencioso.
      ~~*Lo que no se sabe:* **cómo se ve**.~~ **CONTESTADO EL 2026-08-14, y la
      respuesta es que NO SE VE.** Tres arranques desde frío de
      `encina-95758c9e`, con `scripts/capturar-aspecto.sh`: del segundo 9 al 20
      —y hasta el 48 en otra pasada— la pantalla del invitado está **apagada**,
      con «Display output is not active» de UTM encima. La fase dura entre 5 y 14
      fotogramas, así que no es un parpadeo que se escapara entre disparos: es
      **todo el arranque**. La captura está en
      `design/capturas/antes/02-pantalla-apagada.png`.
      **El tema de arranque de Encina no lo ha visto nadie todavía**, y lo que se
      ve al arrancar es un rectángulo negro — más feo que el de Ubuntu, no más
      bonito. Cumple R6 y R7, está instalado y registrado como alternativa; nada
      de eso hace que se dibuje.
      *Lo que NO se sabe todavía, y es lo que decide si esto es un problema del
      producto o del banco de pruebas:* **si pasa también fuera de esta VM**. La
      sospecha razonable es el `virtio-gpu` de UTM, que apaga la salida mientras
      el núcleo toma el control del modo de vídeo. Medirlo en hardware real —o al
      menos en otro anfitrión— va antes que tocar una línea del tema.
      *Hecha cuando:* o se ve en una captura, o está escrito **dónde no se ve y
      por qué**, con la medición al lado.

- [x] ~~**GDM, hasta donde se llegue sin romper R5.**~~ **CERRADA EL 2026-08-15,
      Y LA SEGUNDA MITAD DE SU «HECHA CUANDO» ERA IMPOSIBLE DE CUMPLIR — se
      sustituye por el límite, que es lo que este proyecto hace con un imposible
      en vez de dejarlo colgando.** Pedía *«y la captura de GDM ya no tiene
      naranja»*, apostando a que **el acento arreglaría (c) solo**. **La apuesta
      está perdida, y con captura:** `../../design/capturas/despues/03-gdm.png`
      está tomada sobre `encina-95758c9e` **con el paquete puesto y `Yaru-sage`
      aplicado por él** —el mismo arranque del que salen las otras del «después»,
      donde el botón «Siguiente» de la bienvenida **sí** está en salvia— y **el
      recuadro de selección de usuario sigue siendo naranja Yaru**.

      *Por qué, y es la misma causa que cierra el límite del shell en
      [3-tema-e-iconos.md](3-tema-e-iconos.md):* **el saludador de GDM es
      `gnome-shell`**, no una aplicación GTK. El acento alcanza GTK3 y
      GTK4/libadwaita y se detiene ahí, porque **el tema del shell de Yaru no
      tiene variantes**: hay uno solo. El naranja no está mal configurado — es
      que no hay dónde escribir otro color. La captura de GDM y la de
      `../../design/capturas/acento/archivos-sage.png` son **el par**: misma
      máquina, mismo acento, una verde y la otra naranja.

      **EL LÍMITE, ESCRITO CON LA FORMA DE D9:**

      > **La pantalla de inicio de sesión lleva el logotipo de Encina y conserva
      > el naranja de Yaru en el recuadro del usuario, y así se entrega.** Lo que
      > se puede cambiar sin romper **R5** está cambiado y medido: el logotipo se
      > lee en la captura, y el mecanismo que lo hace posible —el
      > `etc/dconf/profile/gdm` que instala este mismo paquete, porque el perfil
      > que trae `gdm3` **no incluye `system-db:gdm`**— está documentado y es
      > frágil a propósito: si alguien quita ese fichero, el logotipo desaparece
      > **en silencio**. Lo que no se puede cambiar sin romper R5 es el color:
      > vive dentro de `gnome-shell-theme.gresource`, que es **propiedad de
      > `gnome-shell`**, y reempaquetarlo es exactamente lo que descartó a
      > WhiteSur en este mismo bloque. **Las dos vías limpias —una extensión
      > propia cargada en modo saludador, y un `dpkg-divert`— quedan NOMBRADAS Y
      > NO PROBADAS**, que no es lo mismo que descartadas: si algún día el
      > naranja de GDM molesta lo bastante, se empieza por ahí y se paga con una
      > vuelta de paquete.

      *Y lo que sigue sin saberse, que se deja escrito porque un `[OMIT]` no se
      da por bueno:* **por qué los dos ajustes (a) y (b) no hacían nada.** Se
      quitaron en 0.1.14 porque no producían efecto, no porque se supiera la
      causa, y el control que descartó la fontanería entera está abajo.
      *Lo que decía la casilla:*

      **GDM, hasta donde se llegue sin romper R5.** El logotipo y el banner ya
      están puestos, y con la trampa resuelta: GDM no lee `gschema.override`, usa
      su propia base de datos de dconf, y el perfil que trae `gdm3` **no incluye
      `system-db:gdm`** — lo que lo activa es el `etc/dconf/profile/gdm` que
      instala este mismo paquete. Si alguien quita ese fichero, deja de tener
      efecto **en silencio**.
      *Lo que falta, y no está medido:* el aspecto del saludador vive dentro de
      `gnome-shell-theme.gresource`, que es **propiedad de `gnome-shell`**.
      Reempaquetarlo —que es lo que hace WhiteSur— choca de frente con R5. Las dos
      vías limpias son una **extensión propia cargada en modo saludador** y un
      **`dpkg-divert`**, y ninguna de las dos se ha probado.
      ~~*Y una que puede ser un no-op y nadie ha comprobado:*~~ **MIRADO EL
      2026-08-14 en `design/capturas/antes/03-gdm.png`, y hay tres cosas, no una:**
      **(a)** el fondo del saludador **no es `encina-dark.jpg`**: es un negro
      liso. El `org/gnome/desktop/background` del perfil de GDM parece, en
      efecto, **un no-op**. ~~Se quita o se documenta.~~ **QUITADO en 0.1.14.**
      **(b)** el `banner-message-text='Encina OS'` **no aparece por ningún
      sitio**, con `banner-message-enable` a `true`. Segundo ajuste que se puso y
      no hace nada. **QUITADO en 0.1.14.**
      *Las dos, decididas el 2026-08-15, y lo que las decidió fue un control que
      ya estaba en esta casilla sin que nadie lo nombrara:* `logo` vive en la
      **misma sección** `[org/gnome/login-screen]` del **mismo fichero** y **sí
      funciona** —el logotipo se lee en la captura—, así que la fontanería está
      descartada entera: el perfil se lee, la base se compila y `dconf update`
      corre. **Lo que sigue SIN medirse es por qué no hacen nada**, ni (a) ni
      (b): se quitan porque no producen efecto, no porque se sepa la causa, y eso
      va escrito en el propio `99-encina` con lo que decían al lado. Se quitan y
      no se dejan comentadas dentro de la sección porque una clave puesta que no
      surte efecto es de la familia del `[OK]` que describe lo que se pidió y no
      lo que pasó: hace creer que la pantalla de inicio de sesión dice «Encina
      OS» cuando no lo dice.
      **(c)** y lo que de verdad se mira: **el recuadro de selección del usuario
      es naranja Yaru**, en mitad de la pantalla. El logotipo de la encina está
      abajo y se lee bien, pero el color que domina la primera pantalla en la que
      alguien se fija es el de Ubuntu.
      ~~*La (c) es la que engancha con el acento* de
      [2-golpes-baratos.md](2-golpes-baratos.md): si el acento alcanza a GDM, se
      arregla sola.~~ **NO SE ARREGLA SOLA: el acento no alcanza a GDM, medido
      arriba.**
      ~~*Hecha cuando:* está escrito **hasta dónde se llega y qué se descarta, con
      el motivo**, y la captura de GDM ya no tiene naranja.~~ **La primera mitad,
      cumplida; la segunda, sustituida por el límite.**

- [x] ~~**GRUB: decidir que no, o hacerlo con el medio.**~~ **DECIDIDO EL
      2026-08-15 POR JORGE: NO AQUÍ.** La casilla se cerraba escribiendo la
      decisión, y la decisión es la que su propio texto anticipaba.
      **Qué se queda, que ya está hecho y no se toca:** `GRUB_DISTRIBUTOR="Encina
      OS"`, editando `/etc/default/grub` in situ con `sed` —nunca
      sobrescribiéndolo, R5— y con la sustitución idempotente, que es lo que
      evita que se duplique la línea en cada reinstalación (R9).
      **Qué NO se hace, y el motivo, que no es pereza sino aritmética:** un tema
      gráfico de GRUB. En una máquina con un solo sistema operativo **el menú
      está oculto y nadie lo ve nunca**, así que es trabajo cuyo resultado no
      aparece en pantalla — la definición exacta de una tarde invisible.
      **Dónde sí se ve GRUB, y por eso esto no es un abandono sino un traslado:**
      en el arranque de la ISO, que es [../marca-del-medio.md](../marca-del-medio.md).
      Si alguna vez hay tema de GRUB, se paga allí y de una vez, con el resto del
      medio, y no dos veces.
