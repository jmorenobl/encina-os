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
- [x] ~~**Leer los términos de Canonical y escribir qué obligan**, en el mismo
      formato que las decisiones D: qué se puede decir («derivado de Ubuntu»), qué
      no se puede usar (nombre y logotipos como identidad del producto) y qué pasa
      con `os-release`.~~ **HECHA EL 2026-08-15: es `ENCINA-OS.md` D22, con las
      citas literales en §2.1** —fuente, fecha de consulta, redirección y huella
      del texto—, y con **lo leído y lo interpretado separados**, que es lo que
      protegía de la trampa de esta casilla: no hay comando que la demuestre, así
      que el riesgo era colar una impresión con formato de decisión.
      **Lo que sale, en tres respuestas:**
      *(1)* **se puede nombrar a Ubuntu como hecho y como atribución, nunca como
      identidad**, con una fórmula fija de tres frases —**y la fórmula es NUESTRA:
      la política no contiene «derived from Ubuntu» ni ninguna otra autorizada**,
      lo que concede es referenciar sin implicar aval—;
      *(2)* **no se puede usar la marca ni los logotipos como identidad**, y de ahí
      sale lo que esta casilla aporta de verdad: **marca no es cadena**, y los 39
      sitios de §4.51 se reparten en **tres pilas** —lo que se ve (sale), los
      activos gráficos de Canonical (salen aunque no se vean) y la procedencia
      técnica (`ID=ubuntu`, los 155 `.deb`, el `Release` firmado: se queda)—;
      *(3)* **`os-release`: la política NO LO NOMBRA**, así que la obligación se
      deriva de qué hace cada campo — cambian `NAME`, `PRETTY_NAME`, `LOGO` y las
      cuatro URL; **`ID` no**, y D6 queda **acotada, no debilitada**.
      **Y el resultado que importa, sin maquillar: con este criterio la ISO de hoy
      NO SE PUEDE PUBLICAR**, y lo que lo bloquea no son los 60 bytes de
      `.disk/info` sino los logotipos **dentro del snap firmado de 109 MB**. O sea
      que esta casilla **no resuelve la decisión de fondo de arriba —reempaquetar
      o E5—: la endurece**.
      **`os-release` sale a medias de `ENCINA-OS.md` §8**, por escrito y con su
      motivo: lo decidido es **qué** cambia; sigue fuera de alcance **el
      mecanismo**, y ahora con dato — el `os-release` del medio vive dentro de una
      capa de 1,69 GB, así que un `dpkg-divert` desde un `.deb` **no lo alcanza**.
      *Hecha cuando:* es una decisión escrita en `ENCINA-OS.md`, no una impresión.
- [ ] **El arranque y el instalador, con identidad de Encina.**
      *Hecha cuando:* alguien arranca la ISO y **lo que ve dice Encina**, mirado en
      pantalla.
      **HECHA EL 2026-08-16 SALVO EL `[OJOS]`, QUE ES DE JORGE
      (`MEDICIONES.md` §4.52).** Aquí sí se tocó el producto, y la pregunta de
      fondo de arriba —reempaquetado o E5— **está contestada por escrito: es
      `ENCINA-OS.md` D23**.
      **Lo primero, porque decidía cuánto trabajo había: los dos `[OMIT]` que
      §4.51 dejó a propósito**, contestados sobre el código del **commit exacto**
      con el que se construyó este snap (`f329626`, que sale de su
      `snapcraft.yaml`), no sobre `main`. *(1)* **`{{ DISTRO }}` no sale de
      `/cdrom/.disk/info` ni de `/etc/os-release`: la pregunta estaba MAL
      PLANTEADA.** Es `UbuntuFlavor.displayName`, **una constante compilada dentro
      del binario**, y la única llave que la toca —`flavor` del whitelabel— sólo
      admite uno de los **once** sabores de Ubuntu. O sea que las diapositivas
      **se sustituyen enteras, no se parchean**. *(2)* **el `whitelabel.yml` SÍ se
      apunta desde fuera del snap** —`/usr/share/desktop-provision/`, o
      `$DESKTOP_PROVISION_PATH`—, y lo dice la propia documentación de Canonical:
      *«Placing this `whitelabel.yaml` at
      `/usr/share/desktop-provision/whitelabel.yaml` on your LiveCD is
      sufficient…»*. Con esa puerta entran **el título de la ventana**
      (`app-name`), **las diapositivas** y **los dibujos de cada página**, sin
      tocar el snap firmado. **Con el control que separa esto de una lectura de
      internet:** las cuatro cadenas están en el `libapp.so` de **este** medio y
      una inventada no, y el snap es `confinement: classic`, que es lo que hace
      que ese `/usr/share` sea el de la sesión viva.
      **Y lo que abre la casilla entera:** §4.51 dijo que el fondo exigía *«rehacer
      una capa de 1,69 GB»*, y **eso era verdad de la capa, no del medio**. El
      medio **no lleva `layerfs-path=`** —buscado en el `grub.cfg`, en la ESP y en
      el resto de la imagen: 0 apariciones—, así que casper monta **los 21
      `*.squashfs`** de `/casper` y **el último por orden alfabético manda**. Una
      capa propia, `zz-encina.squashfs`, **3 084 288 bytes contra 1 692 274 688**:
      **549 veces menos**.
      **Lo que se ha construido:** `imagen/capa-marca.sh` (**4 controles delante y
      4 comprobaciones detrás, 0 fallos**), el árbol versionado `imagen/marca/`, y
      `fabricar-iso.sh` pasa de modificar dos ficheros a **modificar tres**
      —`grub.cfg` con su `menuentry`, `/.disk/info` y `md5sum.txt`— **y añadir la
      capa**.
      **El control que pedía la casilla, y dice CUÁLES:** el inventario pasa de
      **31 a 24 apariciones** (0 fallos en los dos lados) y los **ocho** sitios que
      dejan de decirlo están nombrados uno a uno en §4.52d — el `menuentry`, el
      `.disk/info`, el rótulo del icono del instalador, `PRETTY_NAME`, `NAME` y
      `LOGO`, `/etc/issue`, la sesión Wayland y el tema de texto de Plymouth.
      **Baja siete y no ocho a propósito:** la línea de `os-release` sigue
      contando porque dice `ID=ubuntu`, que D22 manda dejar.
      **Y el instrumento sacó dos defectos suyos, los dos al usarlo:** contaba
      **sitios y no valores**, así que **el número no podía bajar nunca**; y su
      control **caducó justo al mejorar el producto**.
      **LO QUE FALTA, y no se da por bueno:** el **splash del arranque**
      —`watermark.png` y `bgrt-fallback.png` viven en el `initrd`, antes de que
      exista ninguna capa—, `/.disk/release_notes_url`, los logotipos **dentro del
      snap** (que dejan de verse pero siguen viajando) y **el `[OJOS]`: nadie ha
      visto nada de esto en pantalla**. Se paga en la vuelta única, detrás de la
      casilla 4.
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
