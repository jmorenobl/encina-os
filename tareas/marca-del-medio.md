# Bloque 1 — MARCA PROPIA: que el medio deje de decir Ubuntu

**Es la prioridad declarada, y no es cosmética: es lo que hace legal publicar.**
Hoy el instalador dice Ubuntu, el fondo del instalador es de Ubuntu, la rejilla
lleva el logo de Ubuntu y el volumen de la ISO se llama `Ubuntu 24.04.4 LTS`. El
sistema **instalado** sí lleva ya la identidad de Encina —de eso se ocupa
`encina-branding` 0.1.8—; lo que falta es **el medio y el instalador**.

**Y hay una decisión de fondo antes de tocar un icono:** repintar una ISO de
Ubuntu reempaquetada es una solución a medias, y el destino declarado del
proyecto es **E5, la imagen propia**. Conviene decidir si este bloque se hace
sobre el reempaquetado o si se hace ya construyendo la imagen.

- [x] ~~**Inventariar dónde aparece la marca, midiendo y no suponiendo.** El medio
      entero, el instalador vivo y la primera sesión.~~ **HECHA EL 2026-08-15
      (`MEDICIONES.md` §4.51): 39 apariciones, cada una con su fichero, su cadena
      y dónde se ve**, leídas sobre `encina-os-E4-es-0.2.1-1224b5b1.iso`
      —huella comprobada antes de leer nada— **sin arrancarla y sin gastar VM**.
      Deja instrumento, `imagen/inventario-marca.sh`, con **6 controles delante y
      0 fallos**, porque §4.27 leyó un medio a mano y no dejó ninguno.
      **Las cuatro cosas que cambian el trabajo que viene:**
      *(1)* **el rótulo del icono del instalador NO está escrito: se calcula desde
      `/.disk/info`** por `casper-bottom/25adduser`, y está medido con su control
      —un `.disk/info` de Encina da `Name=Install Encina OS`—, así que son **60
      bytes** y no un paquete;
      *(2)* **la sesión viva no lleva ni un fichero de Encina** (0 de 182 893
      entradas, con el control de que el mismo recuento sobre `ubuntu` da 4 450):
      `encina-branding` se instala en el objetivo y **nunca llega al medio**, así
      que el fondo, el dock y el botón de la rejilla que rodean al instalador son
      Ubuntu de fábrica;
      *(3)* **el instalador es un snap de 109 MB** (`ubuntu-desktop-bootstrap`
      495) y ahí dentro están las diapositivas, los logotipos y el título —o sea
      **la frontera real del reempaquetado**—, con un hallazgo que nadie había
      nombrado: trae un **`whitelabel.yml`** que mapea cada página a su imagen;
      *(4)* lo barato y lo caro quedan separados: el Volume id, el `grub.cfg`
      —que **ya es fichero nuestro**— y el `.disk/info` se tocan sin rehacer nada,
      y el fondo de la sesión viva exige **rehacer una capa de 1,69 GB**.
      **Y OJO con lo que NO se midió, que va escrito:** cuál de las dos fuentes
      rellena `{{ DISTRO }}` —`/cdrom/.disk/info` o `/etc/os-release`, los dos
      literales están en el binario— y si el `whitelabel.yml` se puede apuntar
      desde fuera del snap.
- [ ] **Leer los términos de Canonical y escribir qué obligan**, en el mismo
      formato que las decisiones D: qué se puede decir («derivado de Ubuntu»), qué
      no se puede usar (nombre y logotipos como identidad del producto) y qué pasa
      con `os-release`.
      *Hecha cuando:* es una decisión escrita en `ENCINA-OS.md`, no una impresión.
- [ ] **El arranque y el instalador, con identidad de Encina.**
      *Hecha cuando:* alguien arranca la ISO y **lo que ve dice Encina**, mirado en
      pantalla.
- [x] ~~**El logo de la rejilla.**~~ **CERRADA EL 2026-08-14 EN
      [aspecto/3-tema-e-iconos.md](aspecto/3-tema-e-iconos.md), Y AQUÍ QUEDÓ UNA
      COPIA RANCIA DICIENDO LO CONTRARIO DURANTE UN DÍA — corregida el
      2026-08-15.** Se sincroniza porque este fichero es el que se lee para saber
      qué bloquea publicar, y una casilla abierta de más ahí dentro es del mismo
      tipo de defecto que el resto del proyecto persigue: **decía que faltaba
      trabajo que ya no faltaba**.
      **La casilla estaba MAL LEÍDA desde el principio: el botón NUNCA llevó el
      logotipo de Ubuntu — lleva la bellota, y la lleva desde 0.1.9.** La prueba
      es `../design/capturas/despues/05-rejilla-bellota.png`: con la rejilla
      abierta, **la bellota sale iluminada**, que es lo que distingue el botón de
      aplicaciones de cualquier otro icono del dock.
      *Qué se estaba mirando en su lugar:* el **icono naranja de Ubuntu que
      estaba en mitad del dock**, que no era un botón — era `gnome-initial-setup`
      **ejecutándose**, o sea la propia pantalla de bienvenida, que 0.1.11 quitó.
      *Y por qué no se vio antes:* hasta el 2026-08-14 la ventana de UTM medía
      2560×1410 y **el fondo del dock quedaba fuera de la captura**. El botón de
      la rejilla es el último de la fila y sencillamente no salía.
      *Lo que decía esta copia, con lo que sí era cierto de ella:* hoy el botón de
      aplicaciones lleva el logotipo de Ubuntu.
      *Hecha cuando:* lleva la encina, mirado en pantalla, y el resto del escritorio
      no ha cambiado.
      **SIGUE ABIERTA, y ahora se sabe mucho más (`MEDICIONES.md` §4.43).**
      `encina-branding` 0.1.9 está construido, instalado y verificado —**62 de 62,
      0 fallos**—, con un tema propio `/usr/share/icons/Encina` que hereda de Yaru
      y no pisa nada (R5). **Y el botón sigue con el logotipo de Ubuntu**, mirado
      tras un reinicio completo. Las dos sospechas previstas están descartadas con
      dato: el tema efectivo de la sesión **es `Encina`** y el resolvedor de GTK 4
      devuelve el fichero de Encina para `view-app-grid-ubuntu-symbolic`, que es el
      nombre que el dock construye de verdad —no `view-app-grid-symbolic`, que era
      lo que parecía—. Lo que falta por medir está en §4.43h: **a 48 px**, el
      `sessionMode` dentro del shell, y si el `St` del shell usa otra cadena de
      temas que la `Gtk.IconTheme` con la que se midió.
- [ ] **El nombre del volumen de la ISO.**
      *Hecha cuando:* `xorriso -indev` da un `Volume id` propio y el medio sigue
      arrancando — que es lo que hay que comprobar, porque el nombre del volumen lo
      usa el instalador para encontrarse a sí mismo.
