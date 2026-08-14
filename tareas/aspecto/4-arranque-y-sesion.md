# 4 — Arranque y pantalla de inicio de sesión

Las dos pantallas que se ven antes de que exista una sesión, y la que la abre.
Son las que más delatan la marca ajena y las que menos se miran, porque duran
segundos.

- [ ] **Plymouth, mirado a resolución de verdad.** Hay tema propio, está
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

- [ ] **GDM, hasta donde se llegue sin romper R5.** El logotipo y el banner ya
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
      efecto, **un no-op**. Se quita o se documenta.
      **(b)** el `banner-message-text='Encina OS'` **no aparece por ningún
      sitio**, con `banner-message-enable` a `true`. Segundo ajuste que se puso y
      no hace nada.
      **(c)** y lo que de verdad se mira: **el recuadro de selección del usuario
      es naranja Yaru**, en mitad de la pantalla. El logotipo de la encina está
      abajo y se lee bien, pero el color que domina la primera pantalla en la que
      alguien se fija es el de Ubuntu.
      *La (c) es la que engancha con el acento* de
      [2-golpes-baratos.md](2-golpes-baratos.md): si el acento alcanza a GDM, se
      arregla sola.
      *Hecha cuando:* está escrito **hasta dónde se llega y qué se descarta, con
      el motivo**, y la captura de GDM ya no tiene naranja.

- [ ] **GRUB: decidir que no, o hacerlo con el medio.** `GRUB_DISTRIBUTOR="Encina
      OS"` ya está, editando `/etc/default/grub` in situ con `sed` —nunca
      sobrescribiéndolo, R5— y con la sustitución idempotente, que es lo que
      evita que se duplique la línea en cada reinstalación (R9).
      *Lo que faltaría es un tema gráfico, y rinde mucho menos de lo que parece:*
      en una máquina con un solo sistema operativo **el menú está oculto y nadie
      lo ve nunca**. Donde sí se ve es en el arranque de la ISO, y eso es
      [../marca-del-medio.md](../marca-del-medio.md).
      *Hecha cuando:* la decisión está escrita — que es probablemente «no aquí».
      Cerrarla en falso cuesta una tarde de trabajo invisible.
