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
      *Lo que no se sabe:* **cómo se ve**. Sólo está medido que está instalado.
      *Hecha cuando:* la captura 2 lo enseña, y el logotipo no sale con un
      recuadro opaco —lo que `logo.png` sin canal alfa provoca, y que
      `design/generar.sh` ya comprueba—.

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
      *Y una que puede ser un no-op y nadie ha comprobado:* el perfil de GDM fija
      `org/gnome/desktop/background`, y en GNOME 46 el fondo del saludador
      probablemente no salga de ahí. Si es un no-op, se quita o se documenta.
      *Hecha cuando:* está escrito **hasta dónde se llega y qué se descarta, con
      el motivo**, y la captura 3 enseña el resultado.

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
