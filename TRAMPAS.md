# Las trampas, en un registro único: una fila por número

**Qué es esto** (tarea 9 de [refactorizacion.md](tareas/cerradas/refactorizacion.md),
2026-08-28). Las trampas de este proyecto viven en **dos sitios con numeración
compartida**: las numeradas están en [SCRIPTS.md](SCRIPTS.md), repartidas en
28 secciones tituladas «Y una octava…», «Cuatro más…», y la tabla de
`MEDICIONES.md` §9 ([mediciones/9-trampas.md](mediciones/9-trampas.md)) tiene
67 filas de las que sólo 9 corresponden a un número. Para saber si una trampa
aplica a lo que estás tocando había que conocer las dos listas de memoria.
**Esto es un índice, no una reescritura**: el texto largo se queda donde está y
cada fila apunta a él. `SCRIPTS.md` no cambia. La columna que no existía es
**a qué guion o fase aplica**.

**El hallazgo al hacerlo: la numeración global tiene SEIS NÚMEROS DUPLICADOS,
no trece huecos.** `tareas/refactorizacion.md` decía «se citan 45 números,
llegan hasta la 58, trece huecos». Contadas las cabeceras `**N. …**` de
`SCRIPTS.md` (`/usr/bin/grep -nE '^\*\*[0-9]+(bis)?\. ' SCRIPTS.md`) son **61,
sin ningún hueco de definición**, pero **28, 29, 30, 31, 32 y 33 están
asignados dos veces**: el bloque del 2026-08-12/13 (`SCRIPTS.md` 1895-2024) y
la sección «Y cuatro más, todas del 2026-08-17» (`SCRIPTS.md` 2298-2344), que
contó a partir de la 27 sin mirar. Por la mañana iban aquí como **28a/28b …
33a/33b** (a = la primera en el fichero) y la decisión era de Jorge. **Tomada
la tarde del 2026-08-28: las seis «b» son la 62 a la 67** (28b→62, 29b→63,
30b→64, 31b→65, 32b→66, 33b→67; `MEDICIONES.md` §4.81b es la cuenta y §4.81e la
ejecución) y las «a» se quedan con su número. Lo que cambió: las seis cabeceras
de `SCRIPTS.md` (2298-2344, con el título de su sección diciendo que eran
28-33), 18 citas vivas (5 de «28» → 62, 11 de «32» → 66, y las «30b», «31b» y
«33b» que ya llevaban letra), y **6 citas en registros que NO se reescriben**
—`DIARIO.md` 2026-08-21, §4.54h, §4.55, §4.61 ×2, `organizacion-comparada.md`—
que llevan al lado «hoy la 62/66, renumerada el 2026-08-28». Cualquier «trampa
28» o «trampa 32» sin esa coletilla en un texto anterior al 2026-08-28 que hable
de `utmctl` o de `Drive.Identifier` es la 62 o la 66. La 33 nunca la citó nadie
por número; la 67 (la del `.disk/info`) ya se citaba con letra.

**Lo que la columna «dónde está medida» dice y lo que no:** `SCRIPTS.md:NNN` es
la línea del texto largo en `464b4fd` (el enlace va al fichero: markdown no
ancla líneas); las `§4.NN` las resuelve `bancos/enlaces.sh`; las marcadas
«§ DEDUCIDA» no están citadas en el texto de la trampa, se infirieron del
bloque y **no se dan por buenas**.

> **Nota del 2026-08-28 (tarde), `MEDICIONES.md` §4.81b — dos cosas.**
> **(1) La columna `SCRIPTS.md:NNN` caduca con cada edición de `SCRIPTS.md`, y
> ya había caducado el día que se escribió:** este fichero se generó sobre
> `794f57d` por la mañana y la tarea 10 insertó ese mismo día 66 líneas en
> `SCRIPTS.md` (la tabla de equivalencias, líneas 452-518) por delante de
> todas las trampas, así que **las 68 filas apuntaban 66 líneas por encima de
> su cabecera**. Corregido sumando 66 a cada `SCRIPTS.md:NNN` y a cada rango
> de este fichero (`perl -pe 's/(SCRIPTS\.md:)(\d+)/$1.($2+66)/ge'`), y el
> desfase medido después es 0 en todas. Para volver a medirlo: las cabeceras
> `**N. …**` de `SCRIPTS.md` **a partir de la línea 599** (las de 160-231 son la
> lista del laboratorio de E2 y casan con el mismo patrón) contra la cita de cada
> fila; la orden entera está en §4.81b. Un número de línea no es un ancla.
> **(2) Las 28-33 duplicadas, resueltas la misma tarde:** la propuesta con su
> precio —(a) dejar a/b para siempre, o (b) dar a las «b» los números 62-67—
> está en §4.81b, cita a cita (8 apuntan a la a, 24 a la b). **Jorge eligió la
> (b) y está aplicada (§4.81e)**: las seis filas «b» están ahora detrás de la 61
> con su número nuevo y «*(era la 28b)*» al lado; las «a» se quedan con el suyo
> y sin marca; las 18 citas vivas dicen el número nuevo; las 6 de registros
> llevan la coletilla fechada. La cuenta de después: ninguna cita a «28b … 33b»
> y ninguna «trampa 28» o «32» que hable de `utmctl` o de `Drive.Identifier`
> fuera de un registro con coletilla.

| Nº | Síntoma | Causa | A qué aplica | Dónde está medida |
|---|---|---|---|---|
| **1** | `comando | grep -q` da [FALLO] con la cosa funcionando (PIPESTATUS 141 0) | grep -q cierra la tubería, el escritor muere de SIGPIPE y `pipefail` lo convierte en fallo | scripts/*.sh y cualquier guion con `set -o pipefail` (reaparece en inventario-marca.sh) | [SCRIPTS.md:599](SCRIPTS.md) (A2; sin §; §9 fila «Una comprobación pasa sin comprobar nada» y fila «`grep -q` convierte un acierto en fallo» = §4.51a) |
| **2** | Toda comprobación que busque `Candidate:` falla en una VM en español | La salida de apt está traducida; hay que consultar con `LC_ALL=C` | scripts/*.sh, imagen/*.sh, CI (todo lo que lee apt) | [SCRIPTS.md:612](SCRIPTS.md) (A2; sin §) |
| **3** | El guion acusa a un fichero de hacer lo que su comentario dice que NO hace | El `grep` casa con los propios comentarios; anclar con `^` o filtrar `#` antes | scripts/*.sh (comprobaciones sobre ficheros de configuración) | [SCRIPTS.md:616](SCRIPTS.md) (A2; sin §) |
| **4** | `gsettings`/`xdg-mime` dan verdes falsos por ssh | Una sesión ssh no tiene `XDG_CURRENT_DESKTOP` ni `XDG_DATA_DIRS`; `lib.sh` los reconstruye del proceso gnome-shell | scripts/05, 09, 12 (verificadores por ssh), lib.sh | [SCRIPTS.md:627](SCRIPTS.md) (A1/A2; sin §) |
| **5** | `grep -i afirma` responde «ausente» en un sistema sano y en uno roto | La subcadena real es `oFirma` (SocketAutoFirma); comprobación que no puede decir [OK] nunca | Cualquier comprobación de ausencia; verificar-instalacion.sh; encina-seed.sh | [SCRIPTS.md:649](SCRIPTS.md); MEDICIONES.md §4.2 |
| **6** | `openssl verify -no-CAfile -no-CApath` responde OK sin almacén | OpenSSL 3.x tiene un tercer origen `-CAstore` activo por defecto; el control negativo también hay que controlarlo | Controles negativos con openssl (encina-autofirma, CI) | [SCRIPTS.md:656](SCRIPTS.md); MEDICIONES.md §4.2 |
| **7** | `certutil` deja bases NSS nuevas donde iba a mirar (o a borrar) | `-A` y `-D` crean cert9.db/key4.db/pkcs11.txt; `-L` y `-K` no (rc=255 = «sin almacén», no fallo) | Guiones que recorren perfiles de navegador; desinstalador de autofirma (M19(a)) | [SCRIPTS.md:670](SCRIPTS.md) (ampliada 2026-08-11); MEDICIONES.md §4.29c |
| **8** | Filtrar usuarios con `awk '$1 >= 1000'` se salta al único usuario y en silencio | El usuario de escritorio puede ser UID 501 (instalada a mano) o 1000 (por seed): depende del camino de instalación | postinst, encina-seed.sh, verificar-instalacion.sh (recorrer usuarios) | [SCRIPTS.md:708](SCRIPTS.md) (enmienda 2026-08-10); MEDICIONES.md §4.12a, §4.14i |
| **9** | Un control («el disco no crece en 20 min») da verde sobre una VM que ni arrancó | Un control necesita su propia señal de que llegó a ejecutarse: dos señales independientes | Mediciones en VM del laboratorio E2/E3 (fabricar-vm.sh, vigilancia) | [SCRIPTS.md:764](SCRIPTS.md); MEDICIONES.md §4.14h |
| **10** | `[ -e /target/... ]` en una late-command contesta por la raíz del INSTALADOR | Los enlaces absolutos de systemd bajo /target se siguen hacia la raíz del instalador; usar `-L` o `curtin in-target` y mirar /target antes y después | autoinstall late-command, encina-seed.sh, verificar-instalacion.sh | [SCRIPTS.md:787](SCRIPTS.md); MEDICIONES.md §4.16f |
| **11** | `resolver_desktop` nunca podía decir `NINGUNA`; una rama `case` inalcanzable | `g_desktop_app_info_new()` devuelve NULL y PyGObject lo convierte en `TypeError`, que caía en el `|| echo "?"` | lib.sh (resolver_desktop), instalar-firefox.sh, verificar-firefox.sh, verificar-instalacion.sh | [SCRIPTS.md:806](SCRIPTS.md); MEDICIONES.md §4.16i |
| **12** | Una orden por ssh con `pkill -f "firefox --headless"` mata su propia sesión (ssh 255) | `pkill -f` mira la línea de órdenes entera y el intérprete remoto lleva el patrón dentro; matar por PID | Mediciones por ssh; cualquier guion con `pkill -f` | [SCRIPTS.md:831](SCRIPTS.md); MEDICIONES.md §4.18 |
| **13** | «[OK] la máquina queda como estaba» porque nadie tocó nada; cuatro estados eran el mismo | `sudo` sin contraseña falló en silencio; una mutación se verifica ANTES de leer su resultado | Todo guion que muta y mide: verificar-branding.sh, fabricar-iso.sh, capa-marca.sh, contar-arranques.sh, fabricar-vm-medio.py, banco-autosuficiencia.sh | [SCRIPTS.md:854](SCRIPTS.md); MEDICIONES.md §4.19 (y §4.39g); §9 fila «Una comprobación de “lo dejé como estaba”…» |
| **14** | `ssh 192.168.64.3` contesta unas veces una VM y otras otra; el hostname no distingue | Dos VMs encendidas a la vez comparten IP; identificar por paquetes y testigos, no por nombre | VMs de UTM; construir-todo.sh (--vm comprueba que no hay otra encendida) | [SCRIPTS.md:889](SCRIPTS.md); MEDICIONES.md §4.19; §9 fila «Dos VMs contestan en la misma IP» |
| **15** | `crypt.crypt('x','$6$…')` en macOS devuelve 13 caracteres (DES) sin avisar | `crypt(3)` de macOS no implementa `$6$`; usar `openssl passwd -6` y verificar longitud y control | Generación del hash del seed (fabricar-seed.sh, autoinstall*.yaml) en el Mac | [SCRIPTS.md:1194](SCRIPTS.md); MEDICIONES.md §4.20b |
| **16** | La instalación sale bien pero midiendo el seed EQUIVOCADO (el CIDATA de E2, no el de la ISO) | `select_autoinstall` lee el CIDATA (4.º) antes que /cdrom/autoinstall.yaml (5.º); el testigo es el `debug.log` del arranque, que UTM reescribe en cada inicio | VMs de UTM con volumen CIDATA; mediciones de E3/E4; autoinstall.yaml | [SCRIPTS.md:1236](SCRIPTS.md); MEDICIONES.md §4.21c, §4.35o |
| **17** | `unsquashfs` en el Mac aborta con «File exists» a mitad | El disco del Mac no distingue mayúsculas (sys/ y Sys/); extraer solo la ruta necesaria o sobre imagen sensible a mayúsculas | inventario-marca.sh, capa-marca.sh, lectura de squashfs en macOS | [SCRIPTS.md:1285](SCRIPTS.md); MEDICIONES.md §4.21e (y §4.53a, §9 fila «`unsquashfs` de una capa de Ubuntu muere a mitad en macOS») |
| **18** | Una VM desaparece de `utmctl list` al reiniciar UTM con el bundle intacto | El registro de UTM guarda la ruta y no la actualiza al renombrar la carpeta; borrar la entrada del plist con PlistBuddy | VMs de UTM (registro com.utmapp.UTM.plist); limpieza del banco | [SCRIPTS.md:1315](SCRIPTS.md); MEDICIONES.md §4.26, §4.29h |
| **19** | `Image` de e2-medios no coincide con `/casper/vmlinuz` y parece de otra ISO | En aarch64 el vmlinuz va comprimido; `Image` es su gunzip: normalizar antes de comparar. Y el initrd son dos cpio pegados | Laboratorio E2 (fabricar-vm.sh), lectura de casper | [SCRIPTS.md:1358](SCRIPTS.md); MEDICIONES.md §4.22 |
| **20** | No se puede entrar a una máquina de forma E3 (sin ssh) para verificarla | Canal FAT conectado DESPUÉS de instalar; códigos de teclado de posición; `sh` es dash; `script -q -c` | Máquinas de forma E3; verificar-instalacion.sh; teclear-vm.sh | [SCRIPTS.md:1392](SCRIPTS.md); MEDICIONES.md §4.22 |
| **21** | Se borran 3,4 GB de medios y `df` devuelve 0,44 GiB | El Data/ de cada bundle de UTM es un clon de APFS de su ISO (1 enlace, no instantánea); solo `df` antes/después vale. Corrección: `utmctl delete` existe | Limpieza del banco de VMs/medios (macOS APFS) | [SCRIPTS.md:1679](SCRIPTS.md); MEDICIONES.md §4.26i, §4.29h; §9 fila «Se borra un medio de 3,4 GB…» |
| **22** | `PID=$(trabajo & echo $!)` no vuelve hasta que el trabajo cierra la tubería; el control dio 32 ms en vez de ~8 s | La sustitución de órdenes lee hasta EOF y el hijo hereda el descriptor; leer `$!` sin `$(...)` o redirigir a /dev/null | Instrumentos de medición en bash (M20 de encina-autofirma) | [SCRIPTS.md:1743](SCRIPTS.md); MEDICIONES.md §4.31; M20 encina-autofirma |
| **23** | Un contador que lee el journal en un contenedor cuenta 0 y parece la respuesta buena | En el contenedor el journal no se lee; control de mudez: la fuente tiene que saber decir algo distinto de cero | Mediciones en contenedor (M20 de encina-autofirma) | [SCRIPTS.md:1764](SCRIPTS.md); M20 encina-autofirma |
| **24** | El `.deb` lleva `._mimeapps.list` dentro sin ningún error; después, cabeceras pax que GNU tar descarta | El tar de macOS inventa entradas AppleDouble/cabeceras pax; `COPYFILE_DISABLE=1` es higiene, la protección es cotejar huellas a los dos lados | Transferencia Mac→VM: construir-todo.sh, cosechar-repo.sh, banco-autosuficiencia.sh | [SCRIPTS.md:1786](SCRIPTS.md); MEDICIONES.md §4.18m, §4.36i, §4.37j |
| **25** | `tar xzf … | head -2` extrae medio árbol y el `set -e` falla en otro sitio | Cualquier tubería a `head` mata al escritor por SIGPIPE; no filtrar la salida de tar | Taller del Mac (extracciones en guiones) | [SCRIPTS.md:1840](SCRIPTS.md) (sin §) |
| **26** | Una medición por ssh de algo del escritorio (mimeapps → firefox.desktop) mintió y decidió producto | Los `<escritorio>-mimeapps.list` solo se leen con `XDG_CURRENT_DESKTOP`; medir en las dos columnas o marcar [OJOS] | Mediciones por ssh del escritorio; contar-tiendas.py | [SCRIPTS.md:1865](SCRIPTS.md); MEDICIONES.md §4.26c, §4.26f |
| **26bis** *(sub-trampa de la 26, no es número global)* | Los nombres de aplicaciones salen en inglés con LANG=es_ES en las tres combinaciones | No son las variables: es `setlocale()`; un `python3 -c` no lo llama. Enseñar `get_language_names()` al lado | Mediciones con PyGObject/GLib de cadenas traducidas | [SCRIPTS.md:1848](SCRIPTS.md); MEDICIONES.md §4.26f |
| **27** | `verificar-instalacion.sh --forma e3` falla por la etapa `loading` que toda instalación escribe | Comprobación reescrita sin dispararla contra las dos formas que dice cubrir (luego revertida en §4.40c: `loading` NO siempre está) | verificar-instalacion.sh | [SCRIPTS.md:1883](SCRIPTS.md); MEDICIONES.md §4.32 (y §4.40c; §9 fila «Una lista exacta que da por segura una etapa…») |
| **28** | «hay un saludador gráfico vivo» solo sabía contestar `no` en una máquina E3 | Preguntar por el mecanismo (GDM) en vez de por lo que se quiere saber (el escritorio arranca); ahora vale saludador O sesión | verificar-instalacion.sh (forma E3) | [SCRIPTS.md:1895](SCRIPTS.md); MEDICIONES.md §4.32 |
| **29** | `utmctl clone` da un clon con la MISMA MAC e IP: indistinguible del origen por dentro y por arp | `utmctl clone` no regenera la MAC ni la huella; la prueba está fuera (mtime de disco.img) y un testigo en el primer minuto | VMs clonadas de UTM (clon efímero de la firma, encina-udev-settle) | [SCRIPTS.md:1913](SCRIPTS.md); MEDICIONES.md §4.33, §4.71; ENCINA-OS.md:2326 |
| **30** | «0 .p12 en el disco» no puede salir sano nunca; el contador de iconos dijo 2 donde hay 1 | Dos umbrales que no podían dar una de sus dos respuestas (autofirma.pfx siempre está; contar ficheros no aplica el ensombrecido de XDG_DATA_DIRS) | Huella de virginidad antes de gastar una VM con certificado (§4.33) | [SCRIPTS.md:1950](SCRIPTS.md); MEDICIONES.md §4.33; citada en §4.72 |
| **31** | Diálogo «QEMU error … Invalid argument» en cada instalación, despachado por fe | APFS exige alineación a 4096 para F_PUNCHHOLE y el instalador descarta alineado a 512 (discard=unmap); inocuo y reproducible. No sale en debug.log | VMs de UTM con disco de destino (instalaciones) | [SCRIPTS.md:1979](SCRIPTS.md); MEDICIONES.md §4.34; citada en [SCRIPTS.md:2994](SCRIPTS.md) |
| **32** | Se metieron el seed nuevo y `-set drive.discard=off` en la misma instalación y costó dos vueltas saber cuál atascaba | El arreglo evidente de la 31 rompe la instalación; regla: no cambiar dos variables a la vez | Método de medición (instalaciones en VM) | [SCRIPTS.md:2006](SCRIPTS.md); MEDICIONES.md §4.34; citada como «regla de la trampa 32» en §4.35 |
| **33** | El instalador cascó (apport) a mitad de instalación; la vigilancia no imprimió nada en diez minutos | El Mac se durmió (pmset «Maintenance Sleep») y se llevó la VM; toda instalación va con `caffeinate -dimsu` | Anfitrión macOS durante instalaciones largas | [SCRIPTS.md:2024](SCRIPTS.md); MEDICIONES.md §4.34 |
| **34** | No se pueden teclear redirecciones, tuberías, comillas ni índices en el invitado | `| & > " [ ]` no llegan con teclear-vm.sh; usar `script -c <orden> <fichero>`. `ubuntu-desktop-bootstrap` desde terminal solo da el foco | teclear-vm.sh, medios/envia.sh | [SCRIPTS.md:2365](SCRIPTS.md) (2026-08-17; §4.54 § DEDUCIDA por la fecha, no citada en el texto); citada en medios/envia.sh:4, MEDICIONES.md §4.79 |
| **35** | `echo A_B` llega como `A?B`; `ubuntu?bootstrap.log` funciona por comodín y puede leer otro fichero | El `_` no llega al invitado con teclear-vm.sh: llega como `?` (comodín del shell → verde falso) | teclear-vm.sh | [SCRIPTS.md:2478](SCRIPTS.md) (2026-08-19; §4.55/§4.56 § DEDUCIDA por la fecha, no citada en el texto); citada en MEDICIONES.md §4.63, [SCRIPTS.md:2998](SCRIPTS.md) |
| **36** | No se puede pulsar «Mostrar registro» en el diálogo del instalador caído | Hay terminal en la sesión: `Alt+F2` → gnome-terminal; Tab no mueve el foco visible y el ratón de UTM no llega | Sesión viva del instalador en VM de UTM (teclear-vm.sh) | [SCRIPTS.md:2492](SCRIPTS.md) (2026-08-19); citada en MEDICIONES.md §4.61, §4.62 |
| **37** | `construir-todo.sh --conservar --trabajo <dir>` muere en su control: «esperaba 27 .deb y hay 28» | La cosecha exige empezar en limpio; para repetir solo la ISO se llama a `fabricar-iso.sh --repo <dir>` directamente | construir-todo.sh, fabricar-iso.sh (bisecado) | [SCRIPTS.md:2498](SCRIPTS.md) (2026-08-19; sin §) |
| **38** | Pantalla negra con cursor de X a los 7 minutos; parecía la 32 | Una VM en negro no siempre está colgada: debug.log creciendo e IP en arp la separan… hasta la 47, que tumba la señal del debug.log; y la 42: hay que REPETIR | VMs de UTM arrancando medios (capturar-vm.sh, veredicto-pantalla.py) | [SCRIPTS.md:2511](SCRIPTS.md); MEDICIONES.md, §4.56, §4.58, §4.59; enmendada por 42 y 47 |
| **39** | Borrar una VM del banco no libera disco; una VM borrada a mano queda fantasma en `utmctl list` | fabricar-vm-medio.py mete la ISO por enlace duro (nlink=2): hay que borrar las dos copias; `utmctl delete <nombre>` desregistra y borra | Limpieza del banco de VMs de UTM (fabricar-vm-medio.py) | [SCRIPTS.md:2519](SCRIPTS.md) (2026-08-19; sin §) |
| **40** | `grep -r` sin `-a` concluyó «solo dos ficheros Python leen .disk/info» y faltaba `libapp.so` | `grep -r` se salta los binarios y devuelve un cero falso; siempre `-a` en árboles extraídos y `strings -a` con control | Lectura de snaps/squashfs/.deb desempaquetados en el Mac | [SCRIPTS.md:2562](SCRIPTS.md) (2026-08-19; cita §4.55, §4.54, §4.51); citada en MEDICIONES.md §4.58, §4.61 |
| **41** | El tamaño del PNG (73 K / 280 K / 700 K) distingue negra / texto / gráfica… solo a escala fija | `capturar-vm.sh` toma el tamaño de la ventana y la ventana cambia; tres capturas idénticas al byte sí significan pantalla quieta. Por eso existe veredicto-pantalla.py | capturar-vm.sh, veredicto-pantalla.py, banco-veredicto.sh | [SCRIPTS.md:2538](SCRIPTS.md) (enmienda mismo día; ojo: está ANTES de la 40 en el fichero); MEDICIONES.md §4.56, §4.59 |
| **42** | `p14-plymouth` dio negra en el 1.er arranque y escritorio en el 2.º sin tocar nada; se escribió una causa por suficiencia | En este anfitrión el arranque gráfico del medio falla a veces (33 %, 6 de 18): un «no arranca» hay que CONTARLO con control conocido-bueno | Banco de VMs de UTM (contar-arranques.sh, veredicto-conteo.py) | [SCRIPTS.md:2583](SCRIPTS.md) (2026-08-20); MEDICIONES.md §4.58, §4.59 (en §4.61) |
| **43** | Quitando seis ficheros de la capa, `mksquashfs` dio exactamente los mismos 3 084 288 bytes | El tamaño del squashfs no dice que el contenido sea el mismo (relleno de bloque): comparar por contenido y huella | capa-marca.sh, bisecado de la capa | [SCRIPTS.md:2610](SCRIPTS.md) (2026-08-20; §4.58 § DEDUCIDA por la sección, no citada) |
| **44** | p10 fue siempre 1.º, p11 2.º, p9 3.º: un efecto de posición daría la misma tabla que un efecto del medio | Intercalar siempre en el mismo orden confunde el brazo con la posición; barajar dentro de cada ronda (sin arreglar a propósito) | contar-arranques.sh (diseño del experimento) | [SCRIPTS.md:2716](SCRIPTS.md); MEDICIONES.md §4.59 (en §4.60) |
| **45** | `utmctl start` da -1712 y la VM sigue stopped mientras `list`/`status` funcionan; parecía la VM rota | UTM se queda sordo a los start. ENMIENDA 2026-08-22: NO se destraba con `open -a UTM` (solo -609); el proceso segfaltea (.ips en DiagnosticReports). Control: arrancar otra VM buena | VMs de UTM (construir-todo.sh --vm, cualquier `utmctl start`) | [SCRIPTS.md:2757](SCRIPTS.md) (enmienda en :2721); MEDICIONES.md §4.60, §4.61/§4.62, §4.63 |
| **46** | Con `ImageName` vacío en config.plist QEMU apunta al directorio Data/ y la VM no arranca (y `utmctl start` da 0) | Un CD no se «expulsa» vaciando ImageName: se borra la entrada `Drive` entera con UTM cerrado y `plutil -lint` | VMs de UTM (config.plist), fabricar-vm-medio.py | [SCRIPTS.md:2812](SCRIPTS.md) (2026-08-22); MEDICIONES.md §4.63 |
| **47** | `debug.log` de 2 727 bytes en el arranque que instaló el sistema entero (se creía «VM colgada» = 2 759) | El tamaño de debug.log no separa nada; lo que discrimina es arp/ping y el framebuffer con veredicto-pantalla.py. Y es UNA línea: `grep -c` da 1 como máximo | VMs de UTM (fabricar-vm-medio.py, contar-arranques.sh) | [SCRIPTS.md:2836](SCRIPTS.md); MEDICIONES.md §4.61; enmienda a la 38 y a §4.54h |
| **48** | `ls -1 medios/*.iso` contestó `(empty)` justo después de borrar seis ISOs, con tres ficheros delante | El hook de rtk filtra la salida de `ls` (como la de git); medir con `/bin/ls`, `/usr/bin/git`, `/usr/bin/grep`. Y borrar la ISO no libera disco si un bundle la retiene (nlink) | Entorno del agente (hook rtk) en el Mac; limpieza de medios/ | [SCRIPTS.md:2925](SCRIPTS.md) (2026-08-22); MEDICIONES.md §4.61 |
| **49** | El instalador borró la cabecera FAT del CIDATA a los 64 s; `ENCINA_ESTADO=INCOMPLETO` con pantalla negra y ping | Dos discos virtio del mismo bundle anuncian el mismo `serial` (20 primeros hex del Identifier): solo muerde con DOS unidades Disk | fabricar-vm-medio.py (identificadores de unidades E2) | [SCRIPTS.md:2968](SCRIPTS.md) (2026-08-22; §4.63 § DEDUCIDA por el título, no citada «red de seguridad») |
| **50** | Para leer el registro del seed hacía falta canal FAT, Alt+F2 y pelearse con las teclas | `disco.img` es cruda: `grep -a` desde el anfitrión saca `ENCINA_ESTADO=` y el registro entero, con control de cadena imposible. No alcanza a lo que nunca toca el disco | Lectura de instalaciones desde el Mac (disco.img de los bundles) | [SCRIPTS.md:2993](SCRIPTS.md) (2026-08-22; §4.63 § DEDUCIDA por el título, no citada) |
| **51** | La regla «captura la pantalla antes de Intro» no se podía cumplir sin ojos | `tesseract` está en el Mac y lee recortes (con control); NO es fiable sobre tipografía pequeña de terminal (leyó `e5` por `e3`); `sudo script` graba lo tecleado | capturar-vm.sh / teclear-vm.sh (lectura de pantalla) | [SCRIPTS.md:3020](SCRIPTS.md) (2026-08-22); MEDICIONES.md §4.65 |
| **52** | `traer-iso-oficial.sh` no encuentra la ISO amd64 en cdimage.ubuntu.com | La amd64 vive en releases.ubuntu.com; la firma sí es la misma clave. El servidor va en la tabla de huellas de fabricar-iso.sh (`--arq`) | traer-iso-oficial.sh, fabricar-iso.sh (amd64) | [SCRIPTS.md:3044](SCRIPTS.md); MEDICIONES.md §4.64 |
| **53** | El sabotaje `sed 's/^0/f/; s/^1/f/'` no cambia el SHA256SUMS de 6 líneas de releases → «CONTROL ROTO» | Un control negativo que depende del contenido se apaga solo; el sabotaje tiene que cambiar el fichero SIEMPRE y comprobarse | traer-iso-oficial.sh (control negativo); cualquier sabotaje de banco | [SCRIPTS.md:3052](SCRIPTS.md); MEDICIONES.md §4.64 |
| **54** | Las tres huellas de la cadena firmada salen `e3b0c442…` con [OK] y el paso siguiente compara vacío contra vacío | `efi/boot/` en arm64 es `EFI/boot/` en amd64; una huella de cadena vacía es [FALLO], el directorio se lee del medio | fabricar-iso.sh (cadena firmada, amd64) | [SCRIPTS.md:3059](SCRIPTS.md); MEDICIONES.md §4.64 |
| **55** | Una entrada de GRUB arranca en inglés o sin la marca de Encina | La amd64 trae una segunda entrada «Ubuntu (safe graphics)» con su propia línea de núcleo: `locale=` y `layerfs-path=` van en las dos, y se cuentan | fabricar-iso.sh (grub.cfg, amd64) | [SCRIPTS.md:3067](SCRIPTS.md); MEDICIONES.md §4.64 |
| **56** | Buscando `0xef` en el MBR de una amd64 no se encuentra la ESP; `eltorito.img` cambia 7 bytes | arm64: entrada 0xef del MBR; amd64: MBR protector 0xee + GPT (tipo C12A7328…). Los 7 bytes los reescribe xorriso y no son nuestros (medido con control) | fabricar-iso.sh (paso 10 y ESP, amd64) | [SCRIPTS.md:3074](SCRIPTS.md); MEDICIONES.md §4.64 |
| **57** | `curl` → «Orden no encontrada» en la sesión viva de Ubuntu 24.04 escritorio | `wget` sí está, y `--post-file X URL` funciona sin `=` | Sesión viva del instalador (vía Alt+F2 + buzón HTTP); teclear-vm.sh | [SCRIPTS.md:3116](SCRIPTS.md); MEDICIONES.md §4.65i |
| **58** | `=` se pierde, `@` llega como `2`, `:` llega como `>` en un invitado US | Los caracteres de teclear-vm.sh dependen de la disposición del INVITADO (deroga la cabecera del guion); mandar por `tecla <codigo> [shift]` y mirar la pantalla antes de Intro. Alt+F1/F3/F4 no cambian de VT en sesión gráfica | teclear-vm.sh | [SCRIPTS.md:3122](SCRIPTS.md); MEDICIONES.md §4.65i |
| **59** | `fabricar-iso.sh` da [FALLO] en el paso 10 sobre un arm64 correcto con la lista «en blanco»; o el guion muere sin [FALLO] | El bash 3.2 de macOS trata `"${A[@]}"`/`${A[*]}` de un array vacío como unbound variable bajo `set -u`; idioma seguro `${A[@]+"${A[@]}"}`; buscar `NOMBRE\[` no la forma de la expansión | bash 3.2 de macOS: fabricar-iso.sh (MOD_XORRISO) y todo guion con `set -u` | [SCRIPTS.md:3233](SCRIPTS.md); MEDICIONES.md §4.79 |
| **60** | `grep -v … SHA256SUMS > SHA256SUMS.nuevo` dejó dentro «1 matches in 1F:»; `shasum -c` lo cazó | El hook de rtk filtra también `grep`, y en una tubería que escribe lo filtrado acaba en el fichero; ruta absoluta o `rtk proxy` para medir Y escribir. `echo ====` en zsh muere | Entorno del agente (hook rtk, zsh) en el Mac | [SCRIPTS.md:3251](SCRIPTS.md); MEDICIONES.md §4.79 (amplía §4.9d y §4.77) |
| **61** | `utmctl start` contesta «Virtual machine not found» sobre un bundle recién fabricado y perfecto | UTM escanea Documents/ al arrancar; no es la 18. `open -a UTM <bundle>.utm` lo registra en el acto | fabricar-vm-medio.py, VMs de UTM | [SCRIPTS.md:3259](SCRIPTS.md); MEDICIONES.md §4.79 |
| **62** *(era la 28b)* | `utmctl start` escribe «OSStatus error -1712» y sale con código 0; `[OK] VMs encendidas: 0` | `utmctl start` devuelve 0 cuando falla; esperar al ESTADO (`utmctl status` hasta started). Causa de fondo: conexión interna de UTM caída, se reinicia UTM | construir-todo.sh, contar-arranques.sh, fabricar-vm-medio.py, VMs de UTM | [SCRIPTS.md:2298](SCRIPTS.md) (2026-08-17; §4.54 § DEDUCIDA por la fecha, no citada en el texto); MEDICIONES.md §4.61, §4.61 |
| **63** *(era la 29b)* | «el medio no lleva `layerfs-path`» era verdad y la capa no se montaba nunca | El mismo ajuste tiene dos grafías: `LAYERFS_PATH` vive en un cpio comprimido dentro del initrd donde ningún grep sobre la imagen llega | capa-marca.sh, fabricar-iso.sh, inventario-marca.sh (lectura del medio) | [SCRIPTS.md:2313](SCRIPTS.md); MEDICIONES.md §4.54e |
| **64** *(era la 30b)* | El inventario dice `PRETTY_NAME="Encina OS"` y en marcha `/etc/os-release` dice Ubuntu | «está en el medio» y «se monta» son dos cosas; inventario-marca.sh solo mide la primera | inventario-marca.sh | [SCRIPTS.md:2322](SCRIPTS.md) (2026-08-17; §4.54 § DEDUCIDA por la fecha, no citada en el texto) |
| **65** *(era la 31b)* | `ls /cdrom/casper/ | tail -n 4` llegó sin la tubería y ejecutó otra cosa | `|` y `&` no llegan al invitado con teclear-vm.sh (se suman a `=` y `@`); órdenes sin tuberías y una por línea | teclear-vm.sh | [SCRIPTS.md:2329](SCRIPTS.md) (2026-08-17; superada por 34, 35 y 58) |
| **66** *(era la 32b)* | Pantalla negra indefinida, disco a 0 bloques y `debug.log` congelado en ~2 700 bytes: parecía que dos ISOs no arrancaban | Dos bundles de UTM con el mismo `Drive.Identifier` no arrancan (clonar config.plist con sed sin cambiar los identificadores) | fabricar-vm-medio.py, VMs de UTM | [SCRIPTS.md:2335](SCRIPTS.md); MEDICIONES.md §4.54h; citada en CLAUDE.md:80, [SCRIPTS.md:2513](SCRIPTS.md), MEDICIONES.md |
| **67** *(era la 33b)* | Un `.disk/info` que dice `Encina OS 0.2.1 …` hace que el instalador se caiga en silencio | subiquity usa la 2.ª palabra como release del canal snap `stable/ubuntu-<release>`; tiene que ser la de la base (24.04.4), el nombre va en la 1.ª palabra | imagen/marca/disk-info, fabricar-iso.sh (paso 5b) | [SCRIPTS.md:2344](SCRIPTS.md) (enmienda 2026-08-19); MEDICIONES.md §4.56b |
| **68** | `make dos-veces` muere en la cosecha: «esperaba 28 .deb y hay 26», `[RETIRADO] openjdk-17-jre 17.0.19+10-1~24.04.2`, `pool` 404 en las dos arquitecturas | El archivo de Ubuntu retira las versiones superadas y el manifiesto ancla una; Launchpad las conserva (`+archive/primary/+files/<fichero sin epoch>`) y `cosechar-repo.sh` cae a él SÓLO si el archivo retiró, cotejando huella y tamaño igual (`[LAUNCHPAD]`, con control). Lo de Mozilla no tiene fuente permanente: publicar la cosecha con la ISO | cosechar-repo.sh, construir-todo.sh, make dos-veces, la fase 3 (publicar) | [SCRIPTS.md:3271](SCRIPTS.md); MEDICIONES.md §4.81c, §4.81f |
| **69** | `traer-iso-oficial.sh` dirá `[RETIRADO]` para la `arm64` el día que salga `24.04.5`, aunque la cosecha esté publicada; `old-releases.ubuntu.com/releases/24.04.N/` sólo lista `*-desktop-amd64.iso` | `cdimage.ubuntu.com` conserva dos *point releases* y `old-releases` no recoge el escritorio `arm64`: la ISO oficial `arm64`, la entrada de la construcción, no tiene fuente permanente en Canonical; conservarla uno (3,3 GiB) o aceptar que reproducir el `arm64` exige la ISO de aquel día | traer-iso-oficial.sh, construir-todo.sh, la receta pública arm64, la fase 3 (publicar). **Cerrada para arm64 el 2026-08-30 (§4.83): la base está en SourceForge `base/arm64/` con el `SHA256SUMS` firmado, y el guion cae a ella (`[RESPALDO]`); para amd64, a `old-releases`** | [SCRIPTS.md](SCRIPTS.md) («69.», sección del 2026-08-29); MEDICIONES.md §4.82a, §4.83 |

## Lo que NO lleva número, y dónde vive

- **58 filas de la tabla §9** ([mediciones/9-trampas.md](mediciones/9-trampas.md))
  no corresponden a ninguna numerada: son las de la firma electrónica (§4.1-§4.9),
  las del Snap, y las que cada sección de `MEDICIONES.md` dejó como «familia de»
  una numerada (la 13, la 27, la 24, la 11, la 64) **sin número propio**. Se
  quedan allí; la fila de §9 es su registro.
- **Numeraciones LOCALES que chocan con la global**, y hay que leer el ámbito:
  las siete trampas de `bancos/enlaces.sh` (`SCRIPTS.md` 3187-3223 y
  `MEDICIONES.md` §4.66d) se citan como «trampa 7», «trampas (2), (5) y (6)» y
  **no son** las globales 2, 5, 6 y 7; las cuatro de `inventario-marca.sh`
  (`SCRIPTS.md` 2117-2139) y las tres de «El nombre del volumen» (2258-2279)
  van numeradas desde 1 dentro de su sección. Un enlace automático por número
  tiene que distinguir ámbito.
- **Cinco números sin ninguna cita fuera de su definición**: 23, 25, 33, 37 y 39
  (y 53-55 y 60 sólo dentro de rangos). No es un hueco: es que nadie los ha
  necesitado por número.
- **Enmiendas que la fila tiene que decir o manda a una regla falsa**: la 38
  (su señal del `debug.log` la derogan la 42 y la 47), la 45 (su remedio
  `open -a UTM` era falso, enmienda del 2026-08-22), y la 65, la 34, la 35 y la
  58 son **la misma trampa creciendo** (qué caracteres no llegan con
  `teclear-vm.sh`; la 58 deroga la cabecera del guion).

---

*Filas generadas el 2026-08-28 desde `SCRIPTS.md` 592-3264 y `MEDICIONES.md` §9
leídos enteros (borrador de un agente de sólo lectura, con la orden `grep` de
cada recuento apuntada, y auditado fila a fila contra el fichero). Al añadir
una trampa a `SCRIPTS.md`, se le añade aquí su fila con el número siguiente al
último —hoy, la 70— y `bancos/enlaces.sh` comprueba que sus `§` y sus enlaces
resuelven.*
