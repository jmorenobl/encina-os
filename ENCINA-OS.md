# Encina OS — Documento maestro

**Punto de entrada único del proyecto.** Si no sabes por dónde seguir, lee la
sección 7 («Empieza aquí») y nada más.

Última actualización: 11 de agosto de 2026

---

## 0. Los documentos y para qué sirve cada uno

| Documento | Papel | Cuándo abrirlo |
|---|---|---|
| **ENCINA-OS.md** (este) | Índice, estado y siguiente acción | Siempre primero |
| `AGENTS.md` | Instrucciones ejecutables: reglas duras, convenciones y especificación de cada paquete y de la imagen | Al lanzar trabajo con Claude Code |
| `MEDICIONES.md` — **desde el 2026-08-28, [`mediciones/`](mediciones/), un fichero por sección, y `MEDICIONES.md` es el puntero** (tarea 4 de la refactorización) | Lo medido, con las salidas literales. Se sigue citando `MEDICIONES.md §4.NN` | Antes de volver a investigar algo. Casi siempre ya está medido. Empieza por [`mediciones/LEEME.md`](mediciones/LEEME.md), que tiene la tabla de vigencia |
| `SCRIPTS.md` | Qué hace cada script y en qué orden, y las dieciocho trampas | Antes de ejecutar nada en la VM |
| `README.md` | Qué es el proyecto, para quien llega de fuera | Al enseñar el repositorio |
| `DIARIO.md` | Dónde se quedó el trabajo | Al retomarlo tras unos días |

Si se contradicen, **manda este**.

**Hay un segundo repositorio:** `~/Projects/encina-autofirma`
(`jmorenobl/encina-autofirma`), con el `.deb` corregido de AutoFirma, sus
mediciones (M1–M18) y los tres forks de los que salen las PRs al repositorio
oficial. Es un **ingrediente** de Encina OS con condición de salida (D14), no
una línea de trabajo paralela.

---

## 1. Qué es Encina OS

Una distribución de escritorio basada en Ubuntu LTS, pensada para que un usuario
español la use con la mínima fricción, y en particular para que **las gestiones
electrónicas con la administración española funcionen sin que nadie tenga que
entender por qué no funcionaban**.

**La unidad de valor es la gestión, no la herramienta.** Nadie quiere que
AutoFirma arranque: quiere renovar el certificado, presentar un escrito o firmar
un documento. AutoFirma es un ingrediente con condición de salida (D14), y así
se nombra.

**Y el alcance de esa frase es el medido, no el deseado**, que es lo que la
separa del `postinst` oficial de AutoFirma diciendo «éxito» con todo roto: hoy
cubre **certificado software de la FNMT, en Firefox, sobre arm64**. El DNIe con
lector es un incremento futuro —como dice el párrafo del alcance, más abajo—,
Chrome y Chromium no se han medido, y B5 —las sedes que bloquean con su propia
política de seguridad el `iframe` que su propio JavaScript necesita— **no lo
cierra ningún equipo**: se arregla en la sede. El README enuncia ese perímetro
por delante y no en la letra pequeña.

**Se construyen `.deb`; se entrega Encina OS.** Lo que se escribe y se versiona
aquí son paquetes; lo que se usa es Ubuntu LTS con esos paquetes aplicados. No
se remasteriza la base: se hereda de Ubuntu toda la capa de actualizaciones y
aplicaciones, que es la razón entera de no partir de cero.

**El alcance de hoy es deliberadamente pequeño: un Encina OS arm64 que funcione
en las VMs del autor.** A partir de ahí se añade funcionalidad por incrementos,
y cada incremento deja un sistema que se puede usar. amd64, más aplicaciones de
serie y el DNIe son incrementos futuros, no deuda.

**Ya no hay «Etapa A» y «Etapa B».** Ese marco describía un proyecto que
construía paquetes de base y aplazaba la integración con la administración. Hoy
la integración está hecha y medida, y lo que falta es entregarla. La hoja de
ruta (§6) va por incrementos.

---

## 2. Decisiones cerradas

No volver a discutirlas sin motivo nuevo. **D3, D5, D9 y D13 se revisaron el
2026-08-08**, al cambiar el enfoque del proyecto; las tres primeras cambian de
redacción y la cuarta se enmienda.

| # | Decisión | Motivo en una línea |
|---|---|---|
| D1 | Nombre: **Encina OS**, identificador `encina` | Sin colisión con distros activas; sin acentos; seis letras |
| D2 | Base: Ubuntu LTS con `ubuntu-desktop-minimal` | Sigue siendo GNOME completo; partir de mínimo y sumar es declarativo, quitar es frágil |
| D3 | **Se construyen `.deb`; se entrega Encina OS.** El producto final es Ubuntu LTS con los `.deb` de Encina aplicados: ni los `.deb` sueltos, ni una base remasterizada desde cero | Partir de `ubuntu-desktop-minimal` y sumar paquetes propios cuesta mucho menos que construir una base, y hereda las actualizaciones de Ubuntu. Es también lo que ordena §6: primero instalación desatendida, la imagen propia al final. **Reescrita el 2026-08-08:** el motivo sigue en pie y la conclusión anterior («el producto es la paquetería, *no* la ISO») confundía lo que se construye con lo que se entrega. Cae con ella su motivo escrito —«nadie reinstala el sistema para arreglar un trámite que vence hoy»—, que describía a un usuario que ya tiene Ubuntu y ha dejado de ser el destinatario |
| D4 | Todo declarativo y versionado; Cubic solo como laboratorio | Un chroot editado a mano no es reproducible |
| D5 | **El repositorio es público, y la imagen se publica en cuanto esté lista, DECLARANDO que es solo arm64. Reescrita el 2026-08-13** | La versión anterior aplazaba la imagen «hasta que exista una arquitectura que otros puedan arrancar», y su motivo era el precio: publicar activa dos obligaciones —responder a un fallo de seguridad de AutoFirma cortando imagen nueva, y **ofrecer la fuente correspondiente** del build parcheado, lo que obliga a hacer públicos `encina-autofirma` y los tres forks— para un público que era el autor. Y ella misma dejó escrito quién la cambiaba: *«si se decide publicar la imagen desde la primera versión arm64, es esta celda la que cambia»*. **Se reescribe, y no porque el precio haya bajado: porque YA ESTÁ PAGADO.** Los tres forks nunca fueron privados —son forks de `ctt-gob-es`, así que nacieron públicos—, `jmorenobl/encina-autofirma` es público desde el 2026-08-13, y la oferta de fuente está escrita en el README junto a la licencia. Que la oferta no es un enlace de adorno lo mide la CI de aquel repositorio, que hace exactamente lo que la obligación exige: clona los tres forks anclados por tag (`v1.9.1`, `v2.1`, `v1.0.7`), construye el `.deb` y lo verifica — verde sobre `main` (`31715687820`, 2026-08-13T15:29Z). **Lo que la decisión nueva compra:** «solo arm64» deja de ser un motivo para no publicar y pasa a ser **una línea de la release**, que es donde D9 quiere que esté un límite declarado — un límite leído hasta el final no bloquea, se anuncia. **Y lo que sigue costando, sin maquillar:** la obligación de cortar imagen nueva ante un fallo de seguridad de AutoFirma es real, no se retira con esta celda y se paga con trabajo; se retira el día de D14, cuando el `.deb` oficial pase `verificar-deb.sh` y este ingrediente sobre. **Lo que bloquea publicar ya no es esta decisión:** es el bloque 1 —el medio todavía dice Ubuntu— y el bloque 3 —3,46 GB no caben en un release de GitHub— |
| D6 | `ID=ubuntu` intacto en `os-release`. **Confirmada y ACOTADA el 2026-08-15 por D22: cubre `ID` y nada más** | Software de terceros comprueba ese campo; cambiarlo produce fallos inconexos durante meses. **La acotación no la debilita, la separa de lo que nunca dijo:** los campos de presentación del mismo fichero —`NAME`, `PRETTY_NAME`, `LOGO` y las cuatro URL de `ubuntu.com`— **no estuvieron nunca cubiertos por D6 y cambian**, porque son marca ante el usuario y no un identificador para scripts; el propio formato los separa con esas palabras (§2.1) |
| D7 | Tema estético (macOS u otro) en paquete separado, nunca en la base | Es preferencia personal, no necesidad jurisdiccional |
| D8 | Certificado software FNMT antes que DNIe con lector | Cubre el 90% de trámites y no requiere hardware. **Cumplido:** el positivo de `MEDICIONES.md` §4.9 se hizo con certificado real de la FNMT |
| D9 | **Solo arm64 por ahora.** amd64 cuando haya con qué probarlo | ~~Solo hay un Mac M3, así que arm64 es lo único que se puede medir~~, y en este proyecto lo que no se mide no se da por bueno. **Es un límite de alcance declarado, no un pendiente.** Consecuencia conocida y medida: B6 (`MEDICIONES.md` §4.9c) es específica de arm64 y no aparecería en amd64. **ENMIENDA DEL 2026-08-15, y es al MOTIVO, no a la decisión: el motivo escrito ha dejado de ser cierto.** Hay un segundo Mac, de 2015 y **Intel**, o sea que **sí hay con qué probar amd64** — que era literalmente la condición que esta celda ponía. La decisión **no cambia hoy**, y el motivo que la sostiene ahora es otro y más pequeño: amd64 no es un ajuste sino **E6 entero** —reconstruir los cuatro `.deb`, repetir allí todas las mediciones y volver a medir AutoFirma, porque B6 no aparecería—, y lo que está en curso es entregar la arm64. O sea que **E6 pasa de «no se puede medir» a «no es la prioridad»**, que es una frase distinta y menos firme: el día que se quiera, ya no hay excusa de banco |
| D10 | No comprar máquina física | SoftHSM2 cubre PKCS#11 sin lector; Hetzner por horas cubre amd64 de escritorio el día que haga falta |
| D11 | Los dos lanzadores «Firefox» se resuelven **quitando el Snap en la imagen**, no ocultando entradas. **Matizada el 2026-08-10 (§4.19a): no estaba equivocada, estaba incompleta.** Daba por hecho que el segundo lanzador era el del Snap, así que quitarlo bastaba; E2 lo quitó y siguieron saliendo dos, porque **el segundo es nuestro**. Ocultar *nuestra* sombra sí es correcto y es lo que hace la 0.2.1 — y está medido que ocultarla **no** la desactiva, así que el icono anclado del dock de fábrica sigue abriendo el nativo | Ocultar la del Snap borra el icono del dock de una sesión en marcha, y desde un paquete no se puede exigir cerrar sesión: R3 impide llamar a nada y §8 prohíbe cualquier GUI. **Con D3 reescrita, esto deja de ser un aplazamiento indefinido: la imagen es el producto, así que es el sitio donde ocurre.** Y quitar el Snap cierra además B3 y B4 (§4 de este documento) |
| D12 | **No habrá `encina-locale-es`.** Lo poco que queda va como `Depends:` de `encina-meta` | Medido el 2026-08-07: `check-language-support -l es` sale vacío y el instalador de Ubuntu ya ejecuta ese mismo comando y actúa. Detalle en `MEDICIONES.md` §A3 |
| D13 | **Ningún paquete de Encina cierra una sola de las barreras de la firma por su cuenta** | Cerrar una barrera aislada deja el sistema sin firmar **y sin el síntoma que hoy avisa**: cambia un fallo visible por uno silencioso. **Enmendada el 2026-08-08: la regla se mantiene y su caso se ha cumplido, no violado.** Las barreras se cerraron todas a la vez, en el sitio correcto —el paquete de AutoFirma— y por el dueño correcto, que es exactamente lo que D13 estaba esperando. Lo que se prohíbe sigue prohibido: nada de `policies.json`, ficheros de preferencias de Firefox ni certificados en `encina-branding` ni en `encina-firefox-native` |
| D14 | **El AutoFirma corregido es un ingrediente con condición de salida medible** | El fork existe porque el `.deb` oficial está roto, y se retira cuando deje de estarlo. La condición no es una fecha ni la aceptación de las PRs: es que `verificar-deb.sh` pase sobre el `.deb` descargado de `firmaelectronica.gob.es`. Medido: la AGE va **un año por detrás de su propio código** (`MEDICIONES.md` §4.5) y una PR de una línea tardó 87 días |
| D15 | **Se crece por incrementos, y cada incremento deja un sistema usable** | Es un proyecto de una sola persona, y §4 documenta que así es como mueren estos proyectos. Un incremento que no se puede usar no se puede validar, y lo que no se valida se acumula |
| D16 | **Encina OS es un escritorio que crece, y por eso el Snap vuelve a convivir. Decisión de Jorge, 2026-08-11.** La primera ISO con aplicaciones de serie va en la forma **(c)**: `snapd` presente, el Snap de Firefox instalado y **nunca abierto**, y el Firefox que se puede abrir es **el nativo**. La forma **(b)** —`snapd` sí, Snap de Firefox no— queda como mejora posterior | **La convivencia no es una hipótesis: es el estado en el que se demostró E1.** La huella de virginidad de `MEDICIONES.md` §4.13 —la máquina donde salió la firma en `valide.redsara.es`— dice `snap firefox: firefox 147.0.3-1 7764`. **Quitar el Snap nunca fue condición de que la firma funcione**; la condición es que el Firefox que se abre sea el nativo, y de eso se ocupa `encina-firefox-native`, cuya sombra `NoDisplay=true` está medida **en los dos mundos** (§4.19). **Lo que rompe no es `snapd`: es un Firefox de Snap que alguien abre** —B3 y B4—, y eso es el estado (d), no el (c). **El motivo de producto:** «un escritorio que crece» exige una tienda, y la tienda de Ubuntu arrastra `snapd` de todas formas (§4.26d), así que la elección real no era tenerlo o no, sino tenerlo declarado o tenerlo por la puerta de atrás. **El precio, sin maquillar:** matiza D11 por tercera vez, y **obliga a sustituir la casilla «Sin Snap» de `AGENTS.md` §6bis.3** por una más exigente —*el Firefox que el usuario puede abrir es el nativo: un solo icono, resuelve fuera de `/snap/`, y no existe ningún perfil de Mozilla bajo `~/snap/`*—, que la cumplen **las máquinas con Snap y sin él**. ~~**Esto NO se aplica todavía:** E2 sigue 6 de 6 tal como se midió, y la sustitución se paga el día de la vuelta de E4.~~ **APLICADO EL 2026-08-12** (`MEDICIONES.md` §4.31): el seed deja de purgar `snapd`, la casilla «Sin Snap» de `AGENTS.md` §6bis.3 queda **sustituida** por las tres condiciones de arriba —y sale **más** exigente—, y la máquina que produce el seed es la forma (c) medida: `snapd` `ii`, una revisión del Snap de Firefox, **un solo icono**, `/usr/bin/firefox` fuera de `/snap/` y **cero** perfiles de Mozilla bajo `~/snap/`, con el control de que ese cero sabe ser un uno. **Y sustituir el `.deb` de transición por el de Mozilla NO se lleva el Snap por delante**, que era lo que había que medir y no suponer. ~~**Y tiene una puerta sin contestar:** con un perfil de Snap presente, ¿el vigilante de `+encina2` acierta el nativo?~~ **LA PUERTA ESTÁ CONTESTADA, 2026-08-11** (`MEDICIONES.md` §4.29), y **D16 sale reforzada con un motivo medido que no tenía**: el vigilante acierta el nativo *y* mete la CA también en el del Snap, así que por ese lado la convivencia (c) aguanta; **pero el certificado de la persona lo busca AutoFirma en el perfil que se usó el último** (M6, regla simétrica a propósito), o sea que **quien abra el Snap una vez se lleva B4 de vuelta además de B3**, y lo recupera solo cuando el nativo vuelve a ser el último abierto. La condición de D16 —*un solo icono, y abre el nativo*— **no es cosmética por partida doble**. **Se midió sobre un duplicado, no sobre `encina-E1-meta`**, que sigue intacta — y que, medido el mismo día, **lleva `+encina1` y no `+encina2`** |

| D17 | **Encina OS no trae suite ofimática ni cliente de correo: trae la base para ver, firmar y enviar un PDF, y un escáner. Decisión de Jorge, 2026-08-12.** Entran de serie **el visor de PDF con el manejador por defecto ATADO** y **`simple-scan`** (1 paquete, §4.26d). **No** entran LibreOffice, Thunderbird ni Okular | **Es D2 llevado a su conclusión:** sumar lo que el producto necesita y dejar que el usuario elija el resto. **El visor no es un paquete nuevo, es un defecto:** hoy `application/pdf` resuelve a `firefox.desktop` y **Evince está instalado sin abrirse nunca** (§4.26c), así que lo que cierra ese eslabón es `xdg-mime`, no instalar otro visor. **HECHO el 2026-08-12, y el defecto era MÁS PEQUEÑO de lo que decía §4.26c** (§4.31d): aquella medición se hizo **por `ssh`**, y sin `XDG_CURRENT_DESKTOP` no se lee `gnome-mimeapps.list`, que ya ataba el PDF a Evince. En una sesión de escritorio de verdad **no estaba roto**. Lo que se pone —`/etc/xdg/mimeapps.list`, de `encina-branding` 0.1.8— hace que **la respuesta sea la misma se pregunte como se pregunte**, y está medido en las dos columnas con el control que discrimina: el mismo fichero diciendo `firefox.desktop` cambia las dos. **`simple-scan` también queda cerrado hasta donde se puede sin hardware:** la ventana dice «Escáner de documentos» y «No se detectó ningún escáner», mirado en pantalla. **Okular se descartó con motivo, no por gusto:** su firma de PDF sería **un segundo consumidor del almacén NSS del usuario**, con su propia regla para elegirlo —la familia de B2, B4 y M6, que ha costado tres sesiones—, y **no añade capacidad**, porque AutoFirma ya firma un PDF suelto. **Y el precio, sin maquillar: cada «que lo instale el usuario» es un cheque contra la tienda.** Con esta decisión la tienda deja de ser un elemento más de la lista de E4 y pasa a ser **la premisa de la que cuelgan las tres**: sin ella la entrega no es «un escritorio que crece», es Ubuntu sin ofimática y sin correo (§4.26c: *el hueco grande no es qué aplicaciones, es que la máquina no puede crecer*) **Y ESA PREMISA SE PUSO A PRUEBA POR PRIMERA VEZ EL 2026-08-12/13** (§4.34): hasta ese día la tienda estaba *instalada* pero **nadie la había abierto** —§4.33j lo decía con todas las letras—, así que «que lo instale el usuario» era un cheque sin cobrar. Cobrado: el Centro de aplicaciones **abre, carga catálogo y encuentra LibreOffice y Thunderbird**, mirado en pantalla, en arm64. **D17 se queda de pie, y ahora medida.** ~~Lo que sigue sin medirse es que la tienda **instale**: nadie ha pulsado «Instalar».~~ **PULSADO EL 2026-08-13, y con esto D17 deja de tener ningún cheque sin cobrar** (§4.35i): `snap changes` registra `Instalar snap "libreoffice"` de `08:12` a `08:22`, las aplicaciones visibles pasan de **27 a 34** con **las siete nombradas una a una**, la tienda **sigue siendo una**, y **LibreOffice Writer abre desde la rejilla en español** —`soffice.bin --writer`, «Sin título 1 — LibreOffice Writer», barra de estado «Español (España)»—. El coste real, medido: 1,17 GB declarados de descarga, `.snap` de 1,1 GB, **2 GiB** en el disco del invitado. **Y la forma (c) de D16 sigue en pie después**, con `~/snap/libreoffice` creado y **0** perfiles de Mozilla dentro, con el control de que el mismo patrón encuentra un perfil fabricado a propósito. **Lo pulsó Jorge**, que es lo que un `[OJOS]` admite: lo que prohíbe es una orden, un fichero o una edición. |

| D18 | **La tienda es el «Centro de aplicaciones» (`snap-store`), y `gnome-software` SALE. Decisión de Jorge, 2026-08-12; D18 reescrita entera, no parcheada.** La tienda **no es una línea de `encina-meta`**: es el snap `snap-store`, que viaja **pre-sembrado dentro del medio** y llega al sistema instalado sin que nadie lo pida, porque desde D16 el seed ya no purga `snapd`. Lo que `encina-meta` 0.2.1 declara es **`snapd`**, el motor sin el cual no hay tienda ninguna | **El motivo nuevo que reabrió esta decisión, y por eso se reescribe en vez de parchearse: la versión anterior eligió `gnome-software` SIN HABER CONSIDERADO `snap-store`**, porque el día que se decidió el seed todavía purgaba `snapd` y **esa tienda no existía en la máquina**. Apareció horas después como efecto imprevisto de §4.31h, y con ella **el usuario veía DOS tiendas** — la enfermedad que la propia D18 nombraba, con dos tiendas en vez de dos Firefox. **MEDIDO ENTERO EL 2026-08-12/13 (§4.34), en dos niveles, y el 2 solo porque el 1 salió verde. La tienda que se queda ABRE Y SIRVE en arm64**, mirado en pantalla: ventana «Centro de aplicaciones», catálogo cargado, y encuentra **LibreOffice y Thunderbird** — que es **la premisa entera de D17** puesta a prueba por primera vez. **Y da MÁS de lo que la versión anterior daba por supuesto: no es solo de snaps.** Su filtro ofrece «Paquetes snap» **y** «Paquetes de Debian», y con el segundo encuentra `file-roller`, que no existe como snap; la misma búsqueda da **cero** con un filtro y **uno** con el otro, así que la prueba sabe dar sus dos respuestas. **El precio de `gnome-software` estaba medido y era real:** 4 paquetes, devolvía `snapd` (§4.26d) y metía **su catálogo dentro del buscador de la rejilla** —el bloque «Software, 15 más» que §4.33c vio al firmar—, que se va con él. **Quitarlo no se llevó nada por delante**, y eso se midió en vez de suponerlo: siguen `snapd`, `simple-scan`, `sane-airscan`, `evince` y los tres paquetes de Encina, con la resta del inventario nombrando **una a una** las tres cosas que se fueron. **Las aplicaciones visibles pasan de 28 a 27 y la que se fue está NOMBRADA** (`org.gnome.Software.desktop`, «Software»), con el control de que el contador sabe decir 2, 1 y 0. **Lo que NO cambia:** en la tienda sigue apareciendo el Firefox del Snap, y quien lo abra y firme falla en silencio por B3 (§4.28); **la defensa entera sigue siendo la condición de D16**. Tampoco entran Flathub ni el plugin de flatpak. **Y el precio de esta decisión, sin maquillar: la tienda deja de estar DECLARADA.** Un `.deb` no puede declarar un snap, así que ahora viaja heredada del medio y lo que la protege es `Depends: snapd` más que el seed no purgue `snapd` |
| D19 | **La identidad visual, cerrada como decisión el 2026-08-15.** **Para quién:** no un usuario de Linux — una gestoría, un autónomo, un funcionario, alguien mayor con el certificado de la FNMT y un plazo que vence. Gente para la que el ordenador tiene **consecuencias legales**. **Qué transmite:** *«esto es serio y no me va a fallar»* — confianza, calma y permanencia; **no** entusiasmo, **no** modernidad, **no** personalidad. Sobria, cálida y arraigada, con sus opuestos declarados: ni llamativa, ni fría, ni genérica. **La metáfora es la encina**, y no se toca: un árbol que aguanta siglos en suelo pobre y no se muere, con la copa hecha de nodos — la red de confianza que hace posible una firma. **Y QUÉ NO DEBE PARECER, que es la mitad que se olvida, con los tres nombres: (1) no debe parecer UBUNTU** —fuera el naranja, la tipografía Ubuntu y Yaru como identidad visible; el objetivo no es que la palabra no exista, porque `ID_LIKE` y la atribución se quedan, sino **que nada en pantalla presente el producto como Ubuntu**, que es lo único comprobable— *(**corrección del 2026-08-15, D22:** la atribución técnica que esta celda situaba en `ID_LIKE` está en realidad en `ID`, que D6 mantiene en `ubuntu`; con `ID=ubuntu`, `ID_LIKE` sigue valiendo `debian` y no cambia. Lo que la celda quería decir sigue en pie)*; **(2) no debe parecer macOS ni Windows**, que ya es R8, y por un motivo que va más allá de la regla: cambiar «esto es Ubuntu» por «esto es un Mac falso» no es avanzar, y el segundo ni siquiera es una base que puedas atribuir; **(3) no debe parecer un producto oficial de la ADMINISTRACIÓN** —ni rojigualda, ni escudos, ni el azul de las sedes, ni tipografías institucionales—. **La voz también es identidad:** frases cortas en indicativo que digan qué está pasando, nada de «¡Bienvenido!» ni «Preparando tu experiencia» | **Por qué es una decisión y no un documento de diseño:** el texto llevaba escrito desde el 2026-08-14 en `design/identidad.md` y `design/paleta.md`, pero **un documento de diseño se rediscute y una decisión con su motivo no**, que es justo lo que §2 existe para evitar. **El tercer «no» es el que justifica la fila él solo:** el README declara en su primera pantalla que el proyecto no tiene relación con la Administración General del Estado, la FNMT ni Canonical, y **el diseño no puede desmentir esa declaración**. Un sistema que sirve para firmar ante el Estado y que *parece* del Estado induce a error sobre quién responde si algo sale mal — es el riesgo menos evidente y el más caro, y la paleta verde-tierra ya protege de él, pero conviene que sea a propósito. **Lo que esta decisión NO cierra, y está abierto en `tareas/aspecto/0-decidir.md`:** el acento propio `#3A664E` no existe en la lista cerrada de Ubuntu, así que hoy viaja `Yaru-sage`, **un verde prestado que pasa por gris**; tenerlo exige forkear Yaru para añadir una variante. Y los colores semánticos —error, aviso, correcto y texto— están **`PROPUESTO` y no `VIGENTE`** en `design/paleta.tsv`, con su contraste calculado. **Y un fallo que salió al medirlos, que esta fila no tapa:** el acento sobre `acento-profundo` da **1,68** — el acento no se lee sobre el fondo oscuro de la propia marca, y ese par no se había medido nunca |
| D21 | **El icono del Centro de aplicaciones se sustituye SOMBREANDO SU `.desktop`, no desde el tema de iconos. Decisión de Jorge, 2026-08-15.** Un `.desktop` propio en `/usr/share/applications` con el id del snap, `Name=Centro de aplicaciones`, el mismo `Exec`, `TryExec=/snap/bin/snap-store` y `Icon=` de Encina. La aplicación sigue siendo la misma y se abre igual: cambia el cuadrado del dock y de la rejilla. **Y el criterio general, que es lo que no hay que rediscutir la próxima vez:** cuando el icono de una aplicación ajena **no es alcanzable desde el tema**, la vía es sombrear su `.desktop` — **nunca** tocar el fichero ajeno. **Entra en la vuelta de `encina-branding`, y la casilla NO se marca hasta que el icono esté dibujado y visto en pantalla** | **Porque no había otra vía, y eso está medido, no supuesto** (`MEDICIONES.md` §4.47): su `.desktop` no declara un nombre sino una **ruta absoluta dentro del snap** —`Icon=${SNAP}/…/app-center.png`, escrita por el propio snap en su `meta/gui`, idéntica en la revisión del producto (1271) y en la del banco (1391)—, así que `Gio` devuelve un `GFileIcon` y **ningún tema interviene**: ni el nuestro ni el de Ubuntu, con el control de que la misma función da el mismo fichero con los dos. Y el fichero vive en un squashfs de solo lectura que se sustituye entero en cada autorrefresco. **La forma no es nueva:** `encina-firefox-native` sombrea `firefox_firefox.desktop` desde la 0.2.1 y está medido en producción (§4.19); el árbol sintético confirma que `/usr/share` gana a `/var/lib/snapd/desktop`, con el control invertido. **R5 sigue intacta:** fichero nuestro, directorio nuestro, ningún fichero de Canonical tocado — y la objeción de fondo («repintar la aplicación de otro») está contestada con dato: **el propio Ubuntu sirve el icono de aplicaciones ajenas 62 veces de 71**. **El motivo de producto:** es lo único que queda en el escritorio con marca de Canonical a la vista, y encima donde el ojo va primero; el nombre ya no delata nada porque ellos mismos lo traducen. **El precio, sin maquillar:** seis líneas que hay que mantener —no cincuenta y cinco: la ISO fija `locale=es_ES.UTF-8` (~~§7.7~~ `MEDICIONES.md` §4.25 — enmendado el 2026-08-23 por `bancos/enlaces.sh`: §7 de `ENCINA-OS.md` se reescribió como «Empieza aquí» y sus pasos numerados ya no existen; el dato está medido en §4.25), así que las traducciones del `Name=` no se copian, **y quien cambie el idioma del sistema verá ese nombre en español**—, más lo que Canonical añada a ese fichero y nuestra copia no recoja. Sin `TryExec` quitar la tienda dejaría un lanzador roto. **Y abre trabajo que hoy no existe: el icono hay que dibujarlo**, con la paleta todavía en `PROPUESTO`. **Qué la reabriría:** que el App Center deje de empotrar su icono y pase a declararlo por nombre, o que la tienda cambie (D18) |
| D20 | **NO se forkea Yaru. El acento del producto es `Yaru-sage`, prestado. Decisión de Jorge, 2026-08-15.** Se queda lo que ya viaja desde `encina-branding` 0.1.10: `gtk-theme='Yaru-sage'` y el tema de iconos `Encina` heredando `Yaru-sage,Yaru,hicolor`. **Y se acepta por escrito lo que cuesta:** `sage` es `#657B69`, **no** el `#3A664E` de la marca, y está tan desaturado que **pasa por gris** — o sea que hoy el producto **no tiene su acento**, tiene uno prestado que casi no se lee como decisión. **Con ella caen dos casillas de `tareas/aspecto/0-decidir.md`**: la del tema base y la de dónde vive el fork, que se queda sin objeto | **El motivo es la agilidad, y se dice tal cual en vez de disfrazarlo de criterio técnico.** La alternativa medida era forkear Yaru para añadir una variante `encina` — que **no es un rediseño**: la lista de acentos es cerrada, `#3A664E` no está en ella, y añadir uno es una diferencia de datos en un SCSS (§2 de `2-golpes-baratos.md`). Pero un fork arrastra **repositorio aparte, construcción con meson y sassc, relación de rebase con aguas arriba, oferta de fuente propia y un anclaje para que un `apt upgrade` no lo pise en silencio** — las mismas cinco cosas que `encina-autofirma`, para cambiar un color. **Lo que se compra:** cero paquetes nuevos, cero filas en el manifiesto y cero mantenimiento; los diez acentos ya viajan dentro de `yaru-theme-gtk` y `yaru-theme-icon`. **Lo que se paga, y no se maquilla:** el verde de la identidad no está en pantalla, y `design/identidad.md` sigue diciendo que la cara del producto es propia. **Qué reabriría esta decisión, que es lo que la hace revisable y no un dogma:** que Ubuntu abra el acento a un valor libre —hoy no existe la clave `accent-color` (§2 de `2-golpes-baratos.md`)—, que el fork deje de costar un repositorio porque el tema del shell obligue a uno de todas formas, o que alguien mire la pantalla y diga que el gris no pasa. **Es una decisión de compromiso tomada a sabiendas, no un descuido** |
| D22 | **LO QUE OBLIGAN LOS TÉRMINOS DE CANONICAL, leídos el 2026-08-15 y citados literalmente en §2.1.** El documento que manda es **uno solo**: la *IPRights Policy* de Canonical, **fechada el 15 de julio de 2015**. **(1) SE PUEDE nombrar a Ubuntu como hecho técnico y como atribución, nunca como identidad**, y la forma exacta —la única que este proyecto usa— tiene dos versiones. **Larga**, para el README, la página de la publicación y cualquier «Acerca de»: *«Encina OS está construido sobre Ubuntu 24.04 LTS. Ubuntu es una marca registrada de Canonical Ltd. Encina OS no está afiliado a Canonical Ltd. ni avalado por ella.»* **Corta**, donde no quepa: *«Derivado de Ubuntu; ni publicado ni avalado por Canonical Ltd.»* Va en **texto corrido**, y **nunca**: en el nombre del producto, en un título de ventana, en un icono, dentro de un logotipo, ni en el nombre de un volumen, de un fichero, de un paquete o de un dominio. **(2) NO SE PUEDE usar la marca ni los logotipos como identidad del producto**, y de ahí sale el criterio que reparte los 39 sitios de §4.51 en tres pilas, que es lo que esta decisión aporta de verdad: **marca no es cadena**. **Pila A —lo que presenta el producto ante el usuario— SALE, sin excepción:** el `Volume id`, el `menuentry` del GRUB, `/.disk/info` y con él el rótulo del icono del instalador, el título de su ventana, las diapositivas, `NAME`, `PRETTY_NAME` y `LOGO` de `os-release`, `DISTRIB_DESCRIPTION` de `lsb-release`, `/etc/issue`, el `Name=Ubuntu` de la sesión Wayland y el tema de texto de Plymouth. **Pila B —activos gráficos de Canonical— SE QUITAN O SE SUSTITUYEN aunque no lleguen a verse:** `watermark.png` y `bgrt-fallback.png` del `initrd`, `ubuntu-logo.png`, `warty-final-ubuntu.png`, `ubiquity.png`, y `logo-light.svg`, `logo-dark.svg`, `mascot*.svg`, `ubuntu_pro.svg` y `ubuntu_certified.svg` del snap. **Pila C —procedencia técnica— SE QUEDA, y quedarse es lo correcto:** `ID=ubuntu` (D6) y su gemelo `DISTRIB_ID` de `lsb-release`, los 155 nombres de `.deb` con `-Nubuntu`, `Origin: Ubuntu` del `Release` firmado y las fuentes de `apt` que apuntan a `archive.ubuntu.com`. **(3) `os-release`: LA POLÍTICA NO LO NOMBRA** —ni él ni ningún otro fichero, y eso va escrito porque es lo que se cuela—, así que la obligación se deriva de **qué hace cada campo**, y eso sí está escrito: la especificación del formato dice que `NAME` y `PRETTY_NAME` son *«suitable for presentation to the user»* y que `ID` es *«suitable for processing by scripts»*. **Cambian los de presentación y NO cambia `ID`: D6 sigue entera**, porque hablaba solo de `ID` y **nunca autorizó `NAME="Ubuntu"`**. `LOGO=ubuntu-logo` es pila B. **Las cuatro URL de `ubuntu.com` se van** —mandan al usuario al soporte de Canonical, que es lo más parecido a implicar aval que hay en el fichero, y la especificación las declara opcionales—; hasta que existan las propias, se quitan. **Y una corrección a D19 de paso: la atribución que aquella daba por hecha en `ID_LIKE` está en realidad en `ID`**, porque D6 mantiene `ID=ubuntu` y entonces `ID_LIKE` sigue siendo `debian` y no cambia. **Lo que esta decisión NO decide, a propósito: el mecanismo y el momento** —si ese fichero lo escribe un `dpkg-divert` desde un paquete o la construcción de la imagen—, que son de las casillas 3 y 4 | **Porque la casilla pedía una decisión y no una impresión, y el riesgo de esta casilla era exactamente ése: es la única del bloque 1 que no tiene un comando que la demuestre.** De ahí la forma: **cita literal con su URL, su fecha de consulta y la huella del texto en §2.1**, y todo lo interpretado marcado como lectura. **La frase que decide el caso es una sola:** *«Any redistribution of modified versions of Ubuntu must be approved, certified or provided by Canonical if you are going to associate it with the Trademarks. Otherwise you must remove and replace the Trademarks…»* — y Encina OS es exactamente eso, una redistribución modificada y sin aprobar. **Lo que la política NO dice, que es la mitad que se olvida:** no contiene la expresión «derived from Ubuntu» **ni ninguna fórmula autorizada** —la de arriba es **nuestra**, elegida para caber en lo que sí concede: *«you may reference Ubuntu, but must avoid: (i) any implication of endorsement»*—; no nombra ningún fichero; no da umbral de qué cuenta como *modification*; y **no existe ningún documento de Canonical para distribuciones derivadas**, comprobado contra el índice, que tiene 27 entradas y ninguna lo es. **Por qué hace falta «marca no es cadena»:** *remove and replace the Trademarks* no puede querer decir borrar las 39 apariciones, porque `Origin: Ubuntu` vive dentro de un `Release` **firmado por Canonical** que no se puede tocar (§4.32) y los nombres de los 155 `.deb` los pone el propio Ubuntu; leerlo así haría imposible **cualquier** derivada, incluida E5. **El precio, sin maquillar, y es el resultado que importa: con este criterio la ISO de hoy NO SE PUEDE PUBLICAR**, y lo que lo bloquea no son los 60 bytes de `.disk/info` sino la pila B **dentro del snap firmado de 109 MB** (§4.51) — o sea que **D22 no resuelve la decisión de fondo del bloque 1 —reempaquetar o E5—: la endurece**. **Y una incoherencia declarada, no un descuido:** con D6 el producto se identifica ante los scripts como `ubuntu` para siempre mientras la pantalla dice Encina; la política no dice nada de eso y D6 tiene su motivo técnico. **No confundir con las licencias de los paquetes**, que es la otra trampa: los paquetes se redistribuyen por su licencia libre —lo dice la propia política, *«This does not affect your rights under any open source licence»*— y lo que decide **cómo se llama el producto** es esta política y solo ella. **Qué reabriría D22:** que Canonical publique una IPRights Policy nueva —la vigente es de 2015 y en §2.1 queda la huella de lo citado—, que se pida y se obtenga el permiso escrito que el §4 admite, o que el producto deje de derivar de Ubuntu |

| D23 | **HASTA DÓNDE LLEGA EL REEMPAQUETADO: hasta donde llegue el propio medio, y E5 NO se adelanta. Decisión del 2026-08-15, y contesta la pregunta que la tarea del bloque 1 arrastraba desde el principio y que D22 endureció en vez de resolver.** La marca del medio se pone **con los mecanismos que Ubuntu ya trae**, y son tres, los tres **leídos en el código que viaja en este mismo medio** (§4.52): *(1)* **`/boot/grub/grub.cfg`**, que ya es fichero nuestro —el `menuentry` pasa a *«Probar o instalar Encina OS»*—; *(2)* **`/.disk/info`**, 43 bytes que valen tres cosas a la vez: el rótulo del icono del instalador vía `casper-bottom/25adduser`, el usuario y el nombre de máquina de la sesión viva vía `scripts/casper`, y el número de serie de `57pollinate`; *(3)* **UNA CAPA `squashfs` PROPIA, `/casper/zz-encina.squashfs`**, que tapa a las de Ubuntu porque **el medio no lleva `layerfs-path=`** y entonces casper monta **todos** los `*.squashfs` del directorio y **el último por orden alfabético manda** — y dentro de esa capa entran los ficheros de presentación (`os-release`, `lsb-release`, `/etc/issue`, la sesión Wayland, el tema de texto de Plymouth), **los activos gráficos de Canonical sustituidos por bytes en su misma ruta** (el fondo, el logotipo de GDM, los doce tamaños del icono del instalador, el botón de la rejilla) y **`/usr/share/desktop-provision/`**, que es la puerta declarada por Canonical para ponerle marca al instalador **sin tocar su snap**: el título de la ventana (`app-name`), las diapositivas y los dibujos de cada página. **DÓNDE PARA, y para de verdad: en el snap firmado.** Los `logo-*.svg`, `mascot*.svg`, `ubuntu_pro.svg` y `ubuntu_certified.svg` **siguen viajando dentro** aunque dejen de verse; el snap **no se reempaqueta**. **Y lo que queda por hacer y no está: el splash del arranque** —`watermark.png` y `bgrt-fallback.png` viven en el `initrd`, antes de que exista ninguna capa, así que exigen reescribirlo—, **el `release_notes_url`** y ~~el nombre del volumen, que es la casilla 4~~ **—el nombre del volumen se cerró el 2026-08-17 (§4.53) y ES UN CUARTO MECANISMO, así que D23 pasa de tres a cuatro: el `Volume id`, que no es un fichero, se deriva de `/.disk/info` y lo pone `fabricar-iso.sh` con `-volid`, sin precio en `md5sum.txt` y sin tocar la cadena de arranque, que sale byte a byte idéntica—** | **Porque la pregunta se planteaba entre dos opciones que resultaron no ser las dos.** «Reempaquetar o E5» daba por hecho que el reempaquetado sólo podía repintar por fuera y que todo lo de dentro exigía rehacer capas de 1,69 GB — y §4.51 lo escribió así. **Medido, es falso, y por un margen que no admite discusión: la capa que tapa `minimal.squashfs` pesa 3 084 288 bytes contra 1 692 274 688, o sea 549 veces menos**, y el instalador trae **su propio mecanismo de marca blanca documentado por Canonical**, que nadie de este proyecto había mirado hasta §4.51. Con eso, el reempaquetado deja de ser «una solución a medias» para casi toda la pila A y buena parte de la pila B, y **E5 deja de ser lo que desbloquea publicar**. **Lo que bloquea publicar después de esto está nombrado y es corto:** el splash del `initrd` y los activos dentro del snap. **El precio, sin maquillar, y es una fragilidad real: la capa manda por su NOMBRE.** Si algún día el `grub.cfg` de Ubuntu llevara `layerfs-path=`, la capa dejaría de montarse **y no fallaría nada** — el medio volvería a decir Ubuntu en silencio, que es la peor forma de fallar que hay. Por eso el mecanismo está escrito en la cabecera de `capa-marca.sh`, en la de `fabricar-iso.sh` y en §4.52b, y por eso `inventario-marca.sh` sabe leer el fichero **efectivo** y no el de la capa de abajo. **Y una consecuencia que no se esconde: el medio y la máquina instalada NO dicen lo mismo.** El `os-release` del medio dice `NAME="Encina OS"` y el de la máquina instalada sigue diciendo `Ubuntu`, porque el mecanismo para el sistema instalado sigue fuera de alcance (§8) y ningún `.deb` puede tocar ese fichero sin chocar con R5. Es una deuda declarada, no un descuido. **Qué reabriría D23:** que Ubuntu ponga `layerfs-path=` en el `grub.cfg` de su ISO, que el instalador deje de leer `/usr/share/desktop-provision/`, o que aparezca una razón de producto —no de marca— para construir la imagen desde cero, que es lo que E5 es de verdad |

---

### 2.1 Los términos de Canonical, citados literalmente

**Esto es la prueba de D22, y va aparte a propósito.** No hay comando que
demuestre una lectura, así que lo único que la hace verificable es que **cualquiera
pueda abrir la misma página y comparar**. Lo citado va en inglés y sin traducir;
la traducción sería ya una lectura.

**Fuente que manda —hay una sola: la *IPRights Policy* de Canonical**,
`https://ubuntu.com/legal/intellectual-property-policy`. Todo lo demás que se
cita abajo es apoyo, y va marcado como tal.

| Dato | Valor |
|---|---|
| Fecha del documento | **15 de julio de 2015** (la página anterior, del 14 de mayo de 2013, sigue enlazada como *Older versions*) |
| Consultado | **2026-08-15T20:44Z** |
| Redirección | `ubuntu.com/…` → **301** → `canonical.com/legal/intellectual-property-policy`, `200` |
| Huella del texto citado | secciones 1 a 9, texto plano: **7 056 bytes**, `sha256 3e290677…` |
| Licencia del propio texto | *«published by Canonical Limited … under the Creative Commons CC-BY-SA version 3.0 UK licence»* |

**Y dos cosas medidas sobre las fuentes, que importan porque este proyecto cita
URL:** la dirección `ubuntu.com/legal/intellectual-property-rights-policy` —con
el `rights` que lleva el nombre por el que se la conoce— da **404**; la viva es
`…/intellectual-property-policy`, sin él. Y el enlace *«Ubuntu
logo guidelines»* del §6 de la propia política, `design.ubuntu.com/brand/ubuntu-logo`,
**ya no lleva a ninguna directriz**: redirige a `design.ubuntu.com/brand`, que
tiene valores de marca, logotipos y paleta, y **ni una línea sobre permisos**.
O sea que **la política remite a unas directrices que no están donde dice**.

#### Lo que el texto DICE — citas literales

> **§3** — *«You can redistribute Ubuntu, but only where there has been no modification to it.»*

> **§3** — *«Any redistribution of modified versions of Ubuntu must be approved, certified or provided by Canonical if you are going to associate it with the Trademarks. Otherwise you must remove and replace the Trademarks and will need to recompile the source code to create your own binaries. This does not affect your rights under any open source licence applicable to any of the components of Ubuntu.»*

> **§3** — *«We do not recommend using modified versions of Ubuntu which are not modified in accordance with this IPRights Policy. … If they use the Trademarks, they are in contravention of this IPRights Policy.»*

> **§4** — *«You can use the Trademarks, in accordance with Canonical's brand guidelines, with Canonical's permission in writing.»*

> **§4** — *«You will require Canonical's permission to use: (i) any mark ending with the letters UBUNTU or BUNTU which is sufficiently similar to the Trademarks or any other confusingly similar mark, and (ii) any Trademark in a domain name or URL or for merchandising purposes.»*

> **§4** — *«You cannot use the Trademarks in software titles. If you are producing software for use with or on Ubuntu you may reference Ubuntu, but must avoid: (i) any implication of endorsement, or (ii) any attempt to unfairly or confusingly capitalise on the goodwill of Canonical or Ubuntu.»*

> **§4** — *«You can write articles, create websites, blogs or talk about Ubuntu, provided that it is clear that you are in no way speaking for or on behalf of Canonical and that you do not imply endorsement by Canonical.»*

> **§2** — *«Ubuntu is an aggregate work of many works, each covered by their own licence(s). … For the avoidance of doubt, where any other licence grants rights, this policy does not modify or reduce those rights under those licences.»*

> **§5** — *«The disk, CD, installer and system images, together with Ubuntu packages and binary files, are in many cases copyright of Canonical … and can only be used in accordance with the copyright licences therein and this IPRights Policy.»*

> **§5** — *«Canonical owns intellectual property rights in the trade dress and look and feel of Ubuntu (including the Unity interface), along with various themes and components that may include unregistered design rights, registered design rights and design patents…»*

**La lista de marcas, y las dos fuentes no dicen lo mismo** —conviene saberlo
antes de citar una sola—. El §4 de la política lista **seis**: UBUNTU, KUBUNTU,
EDUBUNTU, XUBUNTU, JUJU, LANDSCAPE. La página de marcas
(`https://ubuntu.com/legal/trademarks`, consultada el mismo día, redirige a
`canonical.com`) lista **dieciséis**: las seis más CANONICAL, LAUNCHPAD, LUBUNTU,
BAZAAR, BOOTSTACK, JAAS, LXD, MAAS, SNAPCRAFT y SNAPPY. Las dos coinciden en la
que importa aquí —**UBUNTU**— y la segunda añade el aviso de que *«The absence of
a name or logo from the list above does not constitute a waiver by Canonical of a
Canonical trademark or other intellectual property rights concerning that name or
logo»*.

**Y una cita que no es de Canonical**, porque el §3 de D22 se apoya en ella: la
especificación del formato `os-release`, leída en su fuente
(`https://raw.githubusercontent.com/systemd/systemd/main/man/os-release.xml`,
consultada el 2026-08-15 — la página de `freedesktop.org` contesta **418** a un
cliente que no es un navegador). Define `NAME` como *«A string identifying the operating
system … suitable for presentation to the user»*, `PRETTY_NAME` como *«A pretty
operating system name in a format suitable for presentation to the user»*, `ID`
como *«A lower-case string … suitable for processing by scripts or usage in
generated filenames»*, `LOGO` como *«the name of an icon … This can be used by
graphical applications to display an operating system's or distributor's logo»*,
y de las URL dice *«These settings are optional»* y que van *«behind links with
captions such as "About this Operating System", "Obtain Support"»*.

#### Lo que el texto NO DICE — y se escribe porque es lo que se cuela

1. **No contiene la expresión «derived from Ubuntu», ni «based on Ubuntu», ni
   ninguna fórmula autorizada** para que una derivada nombre su base. Lo único
   que concede es *referenciar* sin implicar aval, y lo concede hablando de
   *«software for use with or on Ubuntu»* —que no es exactamente nuestro caso—,
   y de artículos, webs y blogs. **La fórmula de D22 es nuestra**, no de ellos.
2. **No nombra ningún fichero.** Ni `os-release`, ni `lsb-release`, ni `ID`, ni
   `ID_LIKE`, ni `/etc/issue`. Todo lo que D22 dice de `os-release` es derivación.
3. **No da un umbral de qué cuenta como *modification*.** Añadir cuatro `.deb` y
   un seed a una ISO oficial es obviamente modificarla, pero el texto no gradúa.
4. **No explica cómo atribuir.** No hay «pon esta línea en el pie».
5. **No hay ningún documento de Canonical para distribuciones derivadas.**
   Comprobado el 2026-08-15 contra `canonical.com/legal/terms-and-policies`:
   **27 entradas** —desde la licencia de la tipografía hasta los términos de la
   tienda de snaps— y **ninguna** sobre derivadas. Lo que hay en el wiki de la
   comunidad (`wiki.ubuntu.com/DerivativeTeam/FAQ`) **no es de Canonical, no está
   mantenido desde enero de 2020**, y a la pregunta de la marca contesta
   remitiendo a esta misma política.

#### Lectura mía — todo esto es interpretación, no cita

- **«Remove and replace the Trademarks» no puede ser literal sobre cada cadena.**
  Si lo fuera, ninguna derivada sería posible: `Origin: Ubuntu` está dentro de un
  `Release` firmado por Canonical, y quitar la palabra de los 155 nombres de
  `.deb` obligaría a renumerar el archivo entero. Lo que se quita es **la marca
  usada como marca**: el nombre del producto, sus logotipos y su presentación.
  De ahí las tres pilas de D22.
- **La pila B se quita aunque no se vea.** El texto habla de la *redistribución*,
  no de lo que se enseña, así que lo conservador es no distribuir los activos de
  Canonical. Hay una lectura más laxa —sólo importa lo que el usuario ve—, y se
  descarta a propósito: el objetivo de todo el bloque 1 es que publicar sea
  defendible, no que sea discutible.
- **`ID=ubuntu` no es un uso de marca.** Es un identificador para scripts, y el
  formato lo dice. Presentar el producto como Ubuntu es otra cosa, y eso es lo
  que cambia.
- **El nombre no colisiona:** «Encina OS» no termina en `UBUNTU` ni en `BUNTU`,
  así que la cláusula (i) del §4 no aplica; y ninguno de los dominios de §3.1
  lleva la marca, que es la cláusula (ii).
- **`recompile the source code to create your own binaries` es la frase más cara
  del texto y no se acata como está escrita.** El §2 y el propio §3 dicen que la
  política no reduce los derechos que dan las licencias libres, y esas licencias
  ya permiten redistribuir los binarios. Lo que sí obliga es sustituir los
  binarios que **llevan la marca dentro** —el snap del instalador, los temas, los
  iconos—. **Es una lectura, y si algún día importa de verdad, se pregunta a un
  abogado y no a este documento.**
- **R8 se queda corta y conviene precisarlo cuando toque**: dice *«ningún activo
  de terceros: ni marca Canonical»* y se escribió pensando en **no añadirlos**;
  §4.51 mide que el medio **los hereda**. La regla no distingue, y con D22 la
  pila B dice que da igual cómo llegaron.
- **Yaru no está resuelto aquí.** El §5 reclama derechos sobre *«trade dress and
  look and feel … along with various themes»*, y D20 decidió seguir usando
  `Yaru-sage`. Mi lectura es que usar Yaru bajo su licencia es una cosa y
  presentar el producto como Ubuntu es otra, y que D19 ya prohíbe lo segundo
  —fuera el naranja y la tipografía Ubuntu—, pero **el texto no lo aclara** y
  queda dicho que no lo aclara.

---

## 3. Qué existe ya

| Artefacto | Estado |
|---|---|
| `encina-branding` | **Construido, instalado y probado.** v0.1.6, 10/10 de la definición de terminado en VM Ubuntu 24.04 arm64, cuatro comprobaciones miradas en pantalla. **v0.1.8 (2026-08-12, `9ec0a49d…` desde el 2026-08-13; era `51b6603c…`, §4.37)**: añade `/etc/xdg/mimeapps.list` —**nuestro**, no el conffile de nadie (R5)— que ata `application/pdf` al visor, y `Depends: evince`, porque ese fichero es una promesa sobre un lanzador concreto. `lintian` mudo. **Y la ruta no es la que parecía:** un `ubuntu-mimeapps.list` no habría servido, porque los ficheros con nombre de escritorio delante **solo se leen si el escritorio se llama así** (`MEDICIONES.md` §4.31d) |
| `encina-firefox-native` | **Construido, instalado y probado.** v0.2.1 (2026-08-10), que pone `NoDisplay=true` en la sombra y deja **un solo icono de Firefox** en las dos máquinas, con y sin Snap, sin reabrir A2 (§4.19). La definición de terminado pasa de siete casillas a nueve: las dos nuevas cuentan *cuántos* iconos hay y comprueban que ocultar no es desactivar. **Es condición necesaria del producto, y está medido por qué** (§4) |
| `autofirma 1.9.1+encina4` *(~~`+encina2`~~ **`+encina4`**, enmienda del 2026-08-28: el manifiesto pincha `1.9.1+encina4` desde el 2026-08-12 y la prosa no lo decía; lo vigila `bancos/versiones.sh`)* | **Construido, probado, y con el primer positivo de extremo a extremo del proyecto.** En `~/Projects/encina-autofirma`, anclado en `v1.9.1`, CI verde en amd64 y arm64. **`+encina2`, del 2026-08-09, cierra el defecto de `MEDICIONES.md` §4.12a**: dos unidades de systemd de usuario meten la CA del socket en el perfil de Mozilla cuando el perfil aparece, así que la secuencia de E1 vuelve a ser de tres órdenes (M14–M18 de aquel repositorio). **Y ya no es la última versión, aunque sí la que viaja en el medio de la entrega** (2026-08-12): **`+encina3`** (`2d985724…`, M19) quita el almacén NSS de root que el paquete dejaba dentro de los perfiles —eran **tres puertas**, y la tercera era desinstalar—, y **`+encina4`** (`faeca3a9…`, M20) hace que la espera del vigilante sea **por raíz**, que es lo que cierra §4.29e. **Las dos están en `main` de aquel repositorio, con la CI verde** (`d00dc92`, 2026-08-11T23:29). *(Esta celda dijo durante un rato lo contrario —«`+encina3` en `main` y la CI en rojo»— y era falso: la ejecución roja era de `56549fe`, el commit de la fusión de M19, no de la cabeza. Se corrige el 2026-08-12 y **se deja de anotar aquí un estado que cambia solo**: el estado vivo se pregunta con `gh run list --repo jmorenobl/encina-autofirma --branch main`, y lo que esta tabla fija es **qué versión viaja en el medio, por huella**.)* **Y un dato de aquel rojo que sí conviene no perder:** la CI de `56549fe` falló con `[FALLO] la CA no ha llegado sola en 30 s` en arm64 — **§4.29e apareciendo sola en el runner**, cuando el contenedor de la sesión de M19 daba 17/0 y la CI 16/1. **Una carrera que tu máquina gana no está cerrada: está sin medir** — **y el 2026-08-12 `+encina4` tiene ya su propio positivo de extremo a extremo** (§4.33): firma real en `valide.redsara.es` sobre la forma (c), con la CA llegando sola al perfil nativo en 2 s y con un Snap de Firefox delante. Lo que ese positivo **no** hace es discriminar `+encina3` de `+encina4`: eso sigue siendo M20, en contenedor |
| Forks de AutoFirma | `jmorenobl/{clienteafirma, jmulticard, clienteafirma-external}`. **CINCO PRs, y las CINCO ABIERTAS** contra `ctt-gob-es/clienteafirma`: **#552** `control-recommends`, **#553** `perfiles-xdg-configurador`, **#554** `nss-multiarch` y **#555** `esquema-afirma-firefox-moderno`, las cuatro el **2026-08-07** (22:17–22:19Z); y **#556** `no-fabricar-almacen-nss`, la que sale de §4.29c, el **2026-08-11** (22:04Z). **Esta celda decía «cuatro PRs escritas; abrirlas está pendiente», y era falsa desde el día que se escribió**: se descubrió al ir a abrir la quinta, porque `gh pr create` contestó *«a pull request for branch … already exists»* (M19j de `encina-autofirma`). Se comprueba con `gh pr list --repo ctt-gob-es/clienteafirma --author jmorenobl --state all` |
| Repositorio git | `jmorenobl/encina-os`, **ya público** (comprobado el 2026-08-09: `gh repo view` da `"visibility":"PUBLIC"`), como pedía D5. **Y `jmorenobl/encina-autofirma` también, desde el 2026-08-13**: `gh repo list` da `PUBLIC` para los cinco que importan —éste, el del empaquetado y los tres forks—, así que la oferta de fuente de D5 está entera. ~~Esta celda decía «sigue privado, y por eso la secuencia de instalación todavía no la puede completar alguien de fuera».~~ **Corregido lo que era falso, y sin inflar lo que sí queda:** alguien de fuera ya puede **reconstruir** el `.deb` desde fuentes públicas —la CI lo hace en cada `push`, clonando los tres forks anclados por tag—, pero **todavía no puede fabricar la ISO sin construirlo él**, porque el `.deb` no viaja en el clon (está en `.gitignore`, y bien) y `imagen/cosechar-repo.sh` no existe aún. Medido el 2026-08-13: el paso 2 de `fabricar-iso.sh` falla con `[FALLO] no esta: autofirma_1.9.1+encina4_all.deb` sobre un clon anónimo, y pasa con el directorio bueno. Eso es el bloque 0 de `TAREAS.md`, no una barrera de licencia |
| Integración continua | `.github/workflows/build.yml`, una entrada de matriz por paquete. Verde por `push` y por `workflow_dispatch` |
| Scripts | Catorce, en `scripts/`, versionados con el repositorio |
| Licencia | EUPL-1.2, texto oficial completo verificado contra EUR-Lex |
| `encina-meta` | **v0.2.1 (2026-08-12, `204081f0…` desde el 2026-08-13; era `86da3cc9…`, §4.37): LA TIENDA CAMBIA.** Salen `gnome-software` y `gnome-software-plugin-snap`; entra **`snapd`**. La tienda pasa a ser el «Centro de aplicaciones» (`snap-store`), que **no es un `.deb`** y por eso no puede ir en un `Depends:`: viaja pre-sembrado en el medio y cuesta **0 paquetes**. Lo que se declara es el motor, con el patrón de `sane-airscan` —cuesta 0 y va escrito para que un cambio de la base no se lo lleve en silencio—. `lintian` mudo, CI verde, y **una instalación limpia de punta a punta que se apagó sola en 9 min con `ESTADO=COMPLETO` y dio 51 correctas, 0 fallos** (§4.34). **Y lo que obligó a esta versión, medido y no supuesto:** `apt purge gnome-software` **se lleva `encina-meta` por delante**, porque lo declaraba. *Antes:* **v0.2.0 (2026-08-12, `85c8cc56…`): las aplicaciones de D17 y D18 dentro** —`simple-scan`, `sane-airscan`, `gnome-software` y `gnome-software-plugin-snap`—, la secuencia de tres órdenes con `--allow-downgrades` en el `full-upgrade`, y sin la obligación de `libreoffice-l10n-es` que cae con D17. `lintian` mudo. **`sane-airscan` contesta la pregunta que §7 dejaba abierta:** `simple-scan` **no** lo arrastra —sus `Depends` solo piden `libsane1` y no tiene `Recommends`— pero **ya viaja en `ubuntu-desktop-minimal`**, así que cuesta 0 paquetes y se declara para que un cambio de la base no se lo lleve en silencio. *Antes:* **Construido, instalado y verificado en VM, y con LA CASILLA QUE DECIDE MARCADA (2026-08-09).** v0.1.1, `changelog` con `dch`, matriz de CI verde, `lintian` mudo también en el runner. **12 de 12 casillas de §6.4 de `AGENTS.md`, completadas el 2026-08-10.** Sobre un clon virgen instalado por la secuencia de **tres órdenes, tal cual y sin nada fuera de ella**, salió una firma real en `valide.redsara.es`, mirada en pantalla (`MEDICIONES.md` §4.13). **La novena —la del `autoremove`— se cerró ya en E2**, con el repo local sin firmar: `apt install encina-meta` a secas deja los otros tres marcados automáticos y entonces `autoremove` los propone (`MEDICIONES.md` §4.15) |
| Instalación desatendida | **No existe.** Es el segundo incremento |
| ~~`encina-doctor`~~ | **Suprimido el 2026-08-08 sin escribir una línea.** Ver §6.1 |

### 3.1 Verificaciones pendientes sobre el nombre

- [ ] PyPI: `encina` disponible
- [ ] GitHub: organización `encina` o alternativa
- [ ] Dominio: `encinaos.es`, `encinaos.org`
- [ ] OEPM, localizador de marcas, clases 9 y 42

Colisión conocida y descartada: Encina fue un sistema de transacciones de
Transarc/IBM, muerto desde 2006. No es problema de marca, pero competirá en
resultados de búsqueda.

---

## 4. Por qué el producto es este y no otro, en cinco líneas

Lo largo está en `MEDICIONES.md`. Lo que hay que tener en la cabeza al trabajar:

**La firma electrónica en Ubuntu falla por seis barreras encadenadas**, cada una
capaz de esconder a la siguiente, y ninguna con un mensaje de error útil.
Encina OS las cierra así:

| # | Barrera | Quién la cierra en Encina OS |
|---|---|---|
| B1a | Las preferencias del esquema `afirma:` están donde la compilación de Mozilla no lee | `autofirma 1.9.1+encina2` *(versión histórica, la de aquel día)* |
| B1b | `network.protocol-handler.app` ya no existe en Firefox 153 | `autofirma 1.9.1+encina2` *(versión histórica, la de aquel día)* |
| B2 | La CA del socket va al perfil equivocado —y no va a ninguno si el perfil aún no existe | `autofirma 1.9.1+encina2`: `+encina1` acertó el perfil, `+encina2` acierta también **el momento** *(versión histórica, la de aquel día)* |
| B3 | Dentro del Snap, Firefox **no ve** el manejador de protocolo | `encina-firefox-native`, y **quitar el Snap en la imagen** |
| B4 | AutoFirma busca tu certificado en el perfil del Snap | `autofirma 1.9.1+encina2`, y quitar el Snap lo cierra solo *(versión histórica, la de aquel día)* |
| B6 | Las bibliotecas NSS no se encuentran fuera de x86 | `autofirma 1.9.1+encina2` *(versión histórica, la de aquel día)* |

*(B5 —la CSP de la sede bloqueando su propio iframe— no la cierra nadie desde el
equipo. Solo afecta a qué sede sirve para validar: `valide.redsara.es` sí,
`sededgsfp.gob.es` no.)*

**Las dos consecuencias que más veces se han olvidado en este proyecto:**

1. **Ningún `.deb` arregla B3.** Firefox dentro del Snap no ve
   `afirma.desktop` ni `/usr/bin/autofirma`, porque su `XDG_DATA_DIRS` no
   incluye `/usr/share` del anfitrión. No falla: **no hace nada.** Por eso
   `encina-firefox-native` no es un accesorio y por eso la imagen quita el Snap.
   **Y tampoco lo arregla AutoFirma, leído en sus fuentes el 2026-08-11**
   (`MEDICIONES.md` §4.28): la salida evidente —dejar AutoFirma escuchando siempre,
   que haría innecesario el manejador— **es imposible por el protocolo, no por el
   confinamiento**: la página elige **tres puertos al azar de 16 384** y se los
   dice a la aplicación **por la misma URI `afirma://` que el Snap no entrega**.
   Un AutoFirma residente es inalcanzable por construcción. **Consecuencia para
   E4:** cuando la tienda devuelva el Snap de Firefox al alcance del usuario
   (D16), el que lo abra y firme fallará en silencio **y no hay arreglo posible
   por nuestra parte**, así que «un solo icono, y abre el nativo» no es
   cosmética: **es la defensa entera**.
2. **Quitar el Snap cierra B3 y B4 a la vez**, y B4 está medido con control
   (`encina-autofirma/MEDICIONES.md` M6): sin perfil de Snap, AutoFirma acierta
   con el nativo él solo.

---

## 5. Reglas duras

Invariantes. Si algo parece exigir violarlas, parar y replantear. **Rigen
también la receta de imagen**, no solo los paquetes.

| # | Regla |
|---|---|
| R1 | Nada de `/etc/skel`. Configuración por defecto con `gschema.override` o perfiles de dconf |
| R2 | No llamar a `glib-compile-schemas`: `libglib2.0-0` tiene un disparador de dpkg que lo hace |
| R3 | No llamar a `apt`, `apt-get`, `dpkg` ni `snap` desde scripts de mantenedor (bloqueo de dpkg) |
| R4 | No eliminar el Snap de Firefox **desde un paquete**; es destructivo. Corresponde a la receta de imagen, donde ahora sí se hace (D11). Sustituir su lanzador no es eliminarlo y sí está permitido |
| R5 | No sobrescribir conffiles de otros paquetes: `/etc/default/grub` con `sed`; `os-release` con `dpkg-divert` |
| R6 | Tema de Plymouth basado en `spinner`, nunca en `bgrt` (bgrt muestra el logo del fabricante) |
| R7 | Tras instalar un tema de Plymouth, `update-initramfs -u`. El tema va dentro del initramfs |
| R8 | Ningún activo de terceros: ni marca Canonical, ni tipografía San Francisco, ni iconos que imiten macOS. **PRECISADA el 2026-08-15 por D23, porque se quedaba corta y §2.1 ya lo dejó dicho:** se escribió pensando en **no añadirlos**, y §4.51 midió que **el medio los HEREDA**. La regla cubre las dos cosas: no añadir, **y quitar o tapar los que el medio traiga**, hasta donde el propio medio deje. Lo que no se alcanza no se da por bueno: se nombra (§4.52f) |
| R9 | Idempotencia: cinco instalaciones seguidas dejan el sistema idéntico |
| R10 | Sin dependencias circulares de repositorio: no declarar `Depends:` sobre paquetes de un repo que ese mismo paquete configura |

---

## 6. Hoja de ruta — incrementos

Cada uno deja un sistema que se puede usar y se valida solo (D15). El orden es
de menor a mayor riesgo, no de menor a mayor interés.

| # | Incremento | Qué lo da por terminado | Estado |
|---|---|---|---|
| **E1** | `encina-meta` | Una secuencia documentada —los cuatro `.deb`, `apt update`, `full-upgrade` más el idioma— deja branding, Firefox nativo y AutoFirma funcionando. Hereda el residuo de l10n de D12. **Medido el 2026-08-08 (`MEDICIONES.md` §4.10): «un solo `apt install`» no era posible, y declarar `firefox` para conseguirlo lo estropea en silencio** | **HECHO, 12 de 12 (2026-08-09, cerrada la última el 2026-08-10).** La que importa: la secuencia de tres órdenes, ejecutada tal cual sobre un clon virgen, deja una máquina que firma — mirado en pantalla (§4.13). La novena —`apt purge` + `autoremove`— no era cumplible con `.deb` sueltos y **se cumplió en E2 con el repo local** (§4.15) |
| **E2** | Instalación desatendida | `autoinstall.yaml` + repo local sin firmar sobre la ISO oficial de Ubuntu arm64. **Sin Snap.** Terminado cuando salga una firma en `valide.redsara.es` sobre una máquina que nadie ha tocado a mano | **ABIERTO el 2026-08-09.** Su medición de apertura está hecha (`MEDICIONES.md` §4.14): la ISO oficial honra un `autoinstall` mínimo servido en un volumen `CIDATA` y ejecuta las `late-commands`. **Y trae un precio medido:** sin `autoinstall` en la línea de órdenes del núcleo, el instalador de escritorio **se para a esperar un clic**, así que «que nadie la toque» obliga a poner ese parámetro — y ponerlo sin hipervisor por medio es reempaquetar la ISO, que es E3. **El 2026-08-10 (§4.16) se cerró la casilla técnica que faltaba: el Snap SÍ se quita desde el seed**, con `apt-get purge snapd` por `curtin in-target`, y el escritorio sobrevive; **la vía obvia, `snap remove`, no sirve y encima dice que sí**. **El seed de verdad está escrito y medido entero el 2026-08-10 (§4.18): `imagen/autoinstall.yaml` instala una máquina completa —repo local con los cuatro `.deb` dentro del propio volumen, `encina-meta`, sin Snap, Firefox nativo en español— en menos de 11 minutos y sin humano dentro. 4 de 6 casillas marcadas.** **El 2026-08-10 (§4.19) se cierra la quinta: 5 de 6.** La casilla «Sin Snap» no se aflojó — se descubrió que **estaba escrita al revés**: pedía que `firefox_firefox.desktop` no resolviera a nada, y ese estado **solo se alcanza reabriendo A2**, porque sin la sombra el identificador vuelve a dar `/snap/bin/firefox %u`. Se corrigió con su motivo, se le añadió la condición que faltaba —**cuántos iconos de Firefox ve el usuario**— y se arregló la sombra en `encina-firefox-native` 0.2.1. Con el `.deb` nuevo cambió una de las cuatro huellas del seed, así que se reconstruyó el volumen y **se remidió §4.18 entero** con una instalación nueva y desatendida: 34 comprobaciones correctas y ningún fallo. **Y E2 QUEDA TERMINADO EL MISMO DÍA, 6 DE 6** (§4.20): la firma `[OJOS]` salió en `valide.redsara.es` sobre un clon efímero de `encina-E2-0.2.1` —máquina 100 % producto del seed— que se destruyó después. Antes hubo que arreglar un defecto del propio seed: **la contraseña del usuario no la sabía nadie**, porque en el YAML solo va el hash y hasta entonces todo se había medido por `ssh` con clave. Se regeneró en el seed versionado —no a mano sobre la máquina, que habría sido tocarla— y la máquina se rehízo entera: **10 min 43 s** y, con la contraseña ya conocida, el verificador pudo correr **como root**: **35 correctas, 0 fallos, 0 avisos, 0 omitidas** |
| **E3** | ISO que se instala como Ubuntu | La ISO oficial reempaquetada con el seed embebido. Se la puedes dar a alguien —o a ti dentro de seis meses— y se instala | **TERMINADO EL 2026-08-10, 9 DE 9** (§4.25). La ISO que se entrega es `encina-os-E3-es.iso` (`02ab929d…`): **el instalador se ve en español** —lo declara Jorge, `[OJOS]`— y la máquina que sale es **idéntica** a la de la ISO anterior: `verificar-instalacion.sh --forma e3` da **36 correctas y 0 fallos**, con `CIDATA -> <no encontrado>` y `REPO ELEGIDO -> /cdrom/encina-repo`. **El precio de §4.21d está pagado y enseñado:** `locale=es_ES.UTF-8` en `boot/grub/grub.cfg` obliga a rehacer `md5sum.txt`, así que **E3 deja de ser «solo añadir ficheros»** y el guion lo demuestra comparando **las 501 entradas del medio** contra la oficial —seis añadidos, dos modificados y nombrados, ninguno perdido—, con el control de que **con el `md5sum.txt` oficial falla exactamente una línea**. **Antes de eso, 8 de 8 el mismo día** (§4.23) `imagen/fabricar-iso.sh` produce una ISO —**reproducible**, misma entrada misma huella— que en una **VM creada desde cero, con dos unidades y ni una más**, instala Encina OS entero contestando **solo las cinco pantallas de Ubuntu**: `verificar-instalacion.sh --forma e3` da **36 correctas y 0 fallos**. La línea que lo cierra es del registro del seed: `CIDATA -> <no encontrado>` / `REPO ELEGIDO -> /cdrom/encina-repo`. Los tres binarios firmados intactos por huella, la ESP byte a byte la oficial y `md5sum.txt` el oficial sin tocar. **La novena casilla, abierta: el instalador se ve en inglés** —las ocho se cumplieron y aun así la ISO recibe en un idioma que el producto no habla—, y es un defecto de la definición, no del producto. **Antecedentes:** Sus dos mediciones de apertura están hechas y las dos salieron baratas (`MEDICIONES.md` §4.21), **antes de tocar `xorriso`**. *(1)* **El banco de UTM no aplica Secure Boot, y no es que esté desactivado: el firmware no lo implementa** —`edk2-aarch64-code.fd`, sin `PK`, `KEK`, `db` ni `SetupMode`, y `mokutil` dice «este sistema no lo soporta»—. **Queda declarado como límite, como D9 con amd64**, y de ahí sale una regla: E3 **no toca los tres binarios firmados**, porque si los rompiera este banco no se daría cuenta. *(2)* **`/cdrom/autoinstall.yaml` es el quinto sitio donde el instalador busca el seed**, leído en el código que viaja en esta ISO, y `/cdrom` es el medio (medido en casper). O sea que **el seed va dentro de la ISO y no hace falta `CIDATA`**. Y sale una consecuencia que nadie había escrito: **el `CIDATA` va cuarto, así que un volumen conectado le gana al seed de la ISO** — bueno para el producto, trampa para la medición. La palabra `autoinstall` va **suelta** en `boot/grub/grub.cfg`, que es **el único `grub.cfg` de todo el medio**, y **está cubierto por `md5sum.txt`**. **Y EL MISMO DÍA SE DECIDIÓ SU FORMA, que es lo que de verdad la define: la ISO PREGUNTA, como Ubuntu** (`AGENTS.md` §6ter.0, decisión de Jorge). E2 tenía que instalar sin nadie delante porque eso **era su criterio de validación, no el producto** —§10 lo dice con esas palabras—, y E3 había heredado el criterio como si fuera el producto: de ahí salía un usuario escrito dentro de la ISO, y de ahí la contraseña. **La contraseña no era un problema que resolver: era el síntoma.** Con `interactive-sections` el instalador pregunta teclado, red, disco, usuario y zona horaria, y el seed aporta **solo lo de Encina** — **salvo `source`, fijo a `ubuntu-desktop-minimal`, y `locale`, fijo a `es_ES.UTF-8`**, que van a propósito porque son el producto: Encina OS se construye sobre la mínima, lo que va encima lo declara `encina-meta` (E4), y el idioma no se pregunta porque el seed instala `firefox-l10n-es-es` sin condición. **Tres consecuencias, y las tres abaratan E3:** desaparece la contraseña; **desaparece la deuda del GRUB** —el clic de confirmación es la pantalla normal de «instalar ahora» cuando hay alguien delante—, y con ella el `md5sum.txt`; y lo único que sigue haciendo falta es meter el seed dentro de la ISO, que es justo lo medido. **Y se puede quitar la identidad sin romper nada, leído y no supuesto:** ni `encina-seed.sh` ni `verificar-instalacion.sh` nombran al usuario ni usan `/home`, que es consecuencia directa de R1 |
| **E4** | Aplicaciones de serie | Lo que quieras que Encina OS traiga puesto, como `Depends:`/`Recommends:` de `encina-meta`. Es el eje por el que crece el producto | **TERMINADO, 13 de 13, el 2026-08-13** (`MEDICIONES.md` §4.34), **y EL ENTREGABLE LO REFLEJA DESDE EL MISMO DÍA** (§4.35): la ISO vigente `aa1ac76a…` seguía llevando dentro `encina-meta` **0.2.0**, o sea las **dos tiendas**, así que se refabricó con el 0.2.1 —`encina-os-E4-es-0.2.1.iso`, `ac0a5721…`— y **se probó arrancándola**: `encina-E4-entrega`, sola en 9 min, `REPO ELEGIDO -> /cdrom/encina-repo`, **51 correctas y 0 fallos**, y **el `[OJOS]` de la tienda única pasa del clon a la instalación limpia**. **Y la última casilla de E4 se marcó el mismo día: la tienda INSTALA** (§4.35i) — `libreoffice` desde el Centro de aplicaciones en 10 min, 27 → 34 visibles con las siete nombradas, y **abre desde la rejilla en español**; la forma (c) sigue en pie después, con un control nuevo que sabe encontrar un perfil fabricado a propósito. **Lo pulsó Jorge**, como las dos últimas pantallas de E3. Lo que sigue sin poderse es que **un agente** pulse un botón del invitado: cinco vías descartadas y medidas. *Y el defecto era mayor de lo que parecía:* `imagen/autoinstall.yaml` —el seed que viaja **dentro** de la ISO— llevaba empotrado el `encina-seed.sh` viejo, con la huella del 0.2.0, así que **son SIETE cosas y no seis** las que hay que tocar al cambiar lo que el producto lleva. Lo último que le faltaba era **la tienda**, y no por una casilla floja sino por una decisión que había que medir: **sale `gnome-software` y se queda el «Centro de aplicaciones»**, con D18 **reescrita entera**. El motivo nuevo que la reabrió: D18 eligió `gnome-software` **sin haber considerado `snap-store`**, porque aquel día el seed aún purgaba `snapd` y esa tienda **no existía en la máquina**. Lo medido, en dos niveles y el 2 solo porque el 1 salió verde: la tienda que se queda **abre y sirve en arm64** —encuentra LibreOffice y Thunderbird, mirado en pantalla, que es **la premisa entera de D17 cobrada por primera vez**—, **no es solo de snaps** —ofrece «Paquetes de Debian» y con ese filtro encuentra `file-roller`—, **cuesta 0 paquetes** porque viaja pre-sembrada en el medio, y **quitar la otra no se llevó nada por delante**, con la resta del inventario nombrando una a una las tres cosas que se fueron. **El usuario ve UNA tienda**, contada y mirada, con el control de que el contador sabe decir 2, 1 y 0. `encina-meta` **0.2.1**, `lintian` mudo, CI verde y una **instalación limpia que se apagó sola en 9 min con `ESTADO=COMPLETO` y dio 51 correctas, 0 fallos** (`encina-E4-tienda`). **Y la casilla que quedaba abierta no se aflojó: estaba MAL ESCRITA y se partió** —«el medio lleva lo que hoy baja de internet» mezclaba dos incrementos—: su mitad de E4 está cerrada y medida, y la otra **se ha movido a E3 como límite declarado, con la forma de D9**, con su coste (1 089 MB), su consecuencia (fuera del DVD de una capa y de FAT32) y su salida nombrada y no medida. *Antes:* **LA VUELTA ESTÁ DADA, el 2026-08-12** (`MEDICIONES.md` §4.31). La máquina de E4 existe —`encina-E4-meta`, instalada sola en **9 min 52 s**, `verificar-instalacion.sh --visibles 28` como root: **48 correctas, 0 fallos, 0 avisos, 0 omitidas**— y con ella: **la convivencia (c) de D16** (el seed deja de purgar `snapd`; un solo icono de Firefox, fuera de `/snap/`, y **cero** perfiles de Mozilla bajo `~/snap/`), **las aplicaciones de D17 y D18** (`simple-scan`, `sane-airscan`, `gnome-software`, `gnome-software-plugin-snap`), **el manejador del PDF atado** con un fichero nuestro, **`autofirma 1.9.1+encina4`**, el **nivel 2** de §4.27 puesto tras leer qué hace `subiquity`, y una **ISO nueva** (`aa1ac76a…`) con el repo offline dentro. **Y la mina de `AGENTS.md` §6.2 era real:** `The following packages will be DOWNGRADED: firefox`. **Tres cosas que parecían arreglos eran del instrumento** —el manejador del PDF (§4.26c se midió por `ssh`), el `--yaml` (ya estaba hecho) y los nombres en inglés de §4.26f (faltaba `setlocale`)—. **Lo que la vuelta encontró y NO cierra, y es de E3:** el **núcleo no viaja en el medio**, lo baja `curtin` de la red, así que una instalación sin red no se arregla metiendo ficheros en `/cdrom/encina-repo`. **LEÍDO HASTA EL FINAL EL 2026-08-12** (§4.32): no falta una fuente —el objetivo **ya lee el medio** por `file:/cdrom` cuando `curtin` instala el núcleo—, falta el núcleo **dentro del archivo indexado**, y eso lo cierra la **firma de Canonical**; la clave `apt:` del seed **no** vale porque sin red `subiquity` borra las fuentes heredadas. Son **1 089 MB**, no ~700. **Límite declarado, como D9.** **Y el mismo día se cerró la ISO de E4 entera**, con las cinco pantallas nombradas por el propio instalador (`encina-E4-cinco`). *Antecedentes:* **Su medición de apertura está hecha el 2026-08-11** (`MEDICIONES.md` §4.26), y **el criterio general de §10 NO lo suprime**: hay tres huecos con su comando —ninguna suite ofimática (`xdg-mime` da `<NINGUNO>` para `.odt`, `.doc`, `.docx`, `.xls` y `.csv`), ningún escáner, y **ninguna forma de instalar nada** (`gnome-software`, `snap` y `flatpak`, los tres ausentes)—. **Es la primera vez que se nombran las 25 aplicaciones que la entrega trae puestas**, que hasta hoy solo se contaban como control; **veinte son utilidades del sistema** y solo cinco sirven para el trabajo. **Lo decidido por Jorge el mismo día:** Encina OS es **un escritorio que crece**, no un aparato cerrado; los tres huecos **entran en el básico**; y **el Snap vuelve a convivir, en la forma (c)** (D16). **Y el precio está medido antes de abrirlo:** una vuelta son dos instalaciones nuevas medidas enteras, ~22 GB de disco y una sesión larga — y **es por vuelta, no por paquete**, así que E4 se decide entero y se paga una sola vez. **Antes va lo que la medición sacó y no es de E4:** la entrega **depende de la red en duro** (el navegador, 76,4 MB, baja de `packages.mozilla.org`), y eso es un defecto de la definición de terminado de E3 si se confirma |
| **E5** | Imagen propia (`live-build`/`debos`) | El destino declarado. Solo compra marcar el propio instalador y controlar el conjunto base | Sin abrir |
| **E6** | amd64 | Cuando haya con qué probarlo (D9). Repetir el positivo de extremo a extremo allí | Sin abrir |
| **B∥** | Sostener AutoFirma | ~~Abrir las cuatro PRs~~; **las cinco están abiertas** (#552–#556), así que lo que queda es **sostenerlas y retirar el fork cuando se cumpla D14**. **Y la primera evidencia propia de por qué D14 no condiciona la salida a que las acepten:** las cuatro primeras llevan **abiertas desde el 2026-08-07 22:17Z** y al **2026-08-11 22:21Z** —cuatro días exactos— tienen **cero comentarios, cero revisiones y `reviewDecision` vacío**. La quinta (#556) se abrió el 2026-08-11 22:04Z, o sea **17 minutos antes de mirar: su cero todavía no significa nada** y no cuenta como evidencia. Se comprueba con `gh pr view <n> --repo ctt-gob-es/clienteafirma --json state,reviewDecision,comments,reviews` | **Abierto** |

**Por qué E5 va al final y no al principio.** Construir una ISO instalable de
Ubuntu Desktop de forma declarativa es más difícil que toda la paquetería junta:
el instalador espera una disposición concreta y `livecd-rootfs` está acoplado a
Launchpad. Es donde la gente abandona. E2 y E3 dan «un sistema que es Encina OS»
sin remasterizar nada, son ficheros en git, y son reproducibles. La receta que
se escriba en E2 es la definitiva; E5 la envuelve.

**El «antecedente a favor de E2» que decía aquí era falso, y se retira el
2026-08-10.** Este documento afirmaba que al menos una de las VMs del proyecto se
había instalado con `autoinstall`. **No es cierto: `encina-limpia-respaldo` se
instaló a mano**, y su propio log lo dice tres veces (`no autoinstall found in
cloud-config`, `load_autoinstall_config … file None`, `skipping Locale as
interactive`). Lo que engañó fue el fichero
`/var/log/installer/autoinstall-user-data`, que **el instalador escribe siempre**,
también cuando nadie le dio ninguna configuración. Salidas y demostración por el
otro lado —una máquina que sí llevaba seed, con ese fichero distinto del seed y
sin sus `late-commands`— en `MEDICIONES.md` §4.14a y §4.14f.

**Lo que hay en su lugar no es un antecedente sino una medición**, hecha el
2026-08-09 antes de escribir el seed de verdad: la ISO oficial de Ubuntu Desktop
24.04.4 arm64 **sí** honra un `autoinstall` mínimo servido en un volumen
`CIDATA`, y **sí** ejecuta las `late-commands`. El precio, que cambia la frontera
entre E2 y E3, está en la fila de E2 de la tabla y en §7.

### 6.1 Por qué se suprimió `encina-doctor`

Estaba especificado en detalle —ocho comprobaciones, cada una con sus dos
salidas, y una puerta que decidía si servían— y **no se escribió ni una línea**.
Se suprime el 2026-08-08 por el mismo motivo por el que se suprimió
`encina-locale-es`: se midió antes de abrirlo y el problema que resolvía había
dejado de existir.

**El motivo, en corto.** `encina doctor` existía para explicarle a un usuario por
qué el `.deb` oficial de AutoFirma le había roto el sistema sin decírselo. Encina
OS ya no instala ese `.deb`: instala uno que no lo rompe. Un diagnóstico cuya
respuesta es siempre la misma no es un diagnóstico.

**Lo que sí sobrevive, y no es un programa nuevo:** la pregunta «¿sigue intacta
esta instalación?». Su sitio es la **verificación de la construcción de la
imagen, en CI**, no una orden que teclee un usuario. Y el código ya existe:
`verificar-deb.sh` en `encina-autofirma` hace 21 comprobaciones con sus dos
salidas medidas y ya corre en dos arquitecturas.

**Lo que se pierde, y conviene tenerlo escrito:** el veredicto «esta máquina
tiene Snap y por eso no puede firmar». En una imagen controlada no hace falta,
porque la imagen no lleva Snap. Si alguna vez Encina OS se instala sobre una
Ubuntu que el usuario ya tenía, esa pregunta vuelve.

La especificación completa que se descarta está en el historial de git, en
`AGENTS.md` §6 hasta el commit del 2026-08-08. Las **mediciones** que se hicieron
para escribirla no se pierden: están en `MEDICIONES.md` §4.2 y §4.9.

---

## 7. Empieza aquí

Una sola tarea. No abras ninguna otra hasta terminarla.

> ### AL DÍA, 2026-08-30: **LA BASE CONSERVADA** — reproducir `0.2.1` ya no depende de que Canonical siga sirviendo la ISO de aquel día (`MEDICIONES.md` §4.83)
>
> Jorge preguntó si la base podía «fijar 24.04 y coger la última»; **no, por
> diseño** (la huella del producto es función de los bytes de la base, y cada
> *point release* cambia cosas medidas), y aprobó lo otro: **anclar y
> conservar**. La ISO oficial `arm64` está en SourceForge, `base/arm64/`,
> junto al `SHA256SUMS` y al `.gpg` **de Canonical** de aquel día (versionados
> en `imagen/base-firmada/`); `traer-iso-oficial.sh` cae a ese respaldo
> —cuarta columna de `ISOS_OFICIALES`; `amd64` → `old-releases`— por huella y
> con la firma, por los mismos pasos que el servidor (`[RESPALDO]`); y **el clon
> limpio, con Canonical y el archivo cortados, bajó la base del respaldo y dio
> `63f360dd…` dos veces**. Quinta casilla de [publicar.md](tareas/cerradas/publicar.md)
> marcada. **Lo que queda del proyecto es una sola cosa, y es de Jorge:**
> instalar «en una máquina que no sea del banco, mirando la pantalla»
> ([ojos.md](tareas/ojos.md)). Y la regla: la base no flota; con `24.04.5` se
> decide si `0.2.2`.
>
> ### AL DÍA, 2026-08-29 (noche): **PUBLICADO.** Las dos ISOs en SourceForge con `SHA256SUMS` al lado, la release `v0.2.1` en GitHub y el README enlazándolas (`MEDICIONES.md` §4.82j-m)
>
> **Jorge eligió SourceForge y ordenó los dos actos irreversibles.** Los siete
> ficheros —las dos ISOs, las dos cosechas, los dos `.torrent` y `SHA256SUMS`—
> están en `https://downloads.sourceforge.net/project/encina-os/0.2.1/`
> (`imagen/subir-sourceforge.sh --de-verdad`, 10,9 GB en 20 min, cotejados de
> vuelta), y **bajados desde fuera dan su huella**: la `arm64` por la URL
> canónica y la `amd64` sólo por la web seed del torrent publicado. **El clon
> limpio contra la cosecha publicada**, con el archivo, Mozilla y Launchpad
> cortados, da `63f360dd…` y `3d5d12a9…` otra vez. La release
> [`v0.2.1`](https://github.com/jmorenobl/encina-os/releases/tag/v0.2.1) está
> sobre `ac663f5` con las notas de cuerpo y `SHA256SUMS`, torrents y cosechas
> de adjuntos, y el README dice desde dónde bajar y con qué huella. **Marcadas:
> las dos casillas de [alojamiento.md](tareas/cerradas/alojamiento.md) y tres de las
> cinco de [publicar.md](tareas/cerradas/publicar.md).** **Lo que queda, y es de Jorge:**
> instalar «en una máquina que no sea del banco, mirando la pantalla»
> ([ojos.md](tareas/ojos.md)), y decidir si se conserva la ISO oficial `arm64`
> (trampa 69). Y la regla nueva: un medio nuevo es una `encina-meta` nueva, una
> carpeta nueva en SourceForge y una etiqueta nueva; nada publicado cambia.
>
> ### AL DÍA, 2026-08-29 (tarde): **LA FASE 3 HA EMPEZADO, y está hecho todo lo que no depende de dónde vive la ISO — nada subido a ningún sitio** (`MEDICIONES.md` §4.82)
>
> **Lo que hay desde hoy:** la cosecha de 29 `.deb` por arquitectura,
> empaquetada reproducible y **cotejada contra los dos medios vigentes**
> (`make cosecha`: la ISO de esa misma pasada da `63f360dd…` / `3d5d12a9…`,
> otra vez, desde `74504fc`); `cosechar-repo.sh --cosecha` cosechando desde
> ella con el archivo, Mozilla y Launchpad **cortados**; y la definición de
> terminado de la casilla ejecutada: **un clon limpio, `--cache` vacío, las
> URLs en `127.0.0.1:1` y los dos tar por HTTP local, da las dos huellas** —en
> la mitad de tiempo que ayer, porque no baja nada—. `make trozos` (2 y 4
> trozos, `cat` los recompone en la huella) y `make publicar` (SHA256SUMS
> calculado y las notas con las huellas sustituidas desde él, con sus
> controles) están medidos. **Lo que no se ha hecho, a propósito:** subir nada
> —dónde vive la ISO es de Jorge, y las opciones con su precio están en
> [alojamiento.md](tareas/cerradas/alojamiento.md)—, instalar en hierro mirando
> ([ojos.md](tareas/ojos.md) dice qué y dónde), y el enlace del README. **Y
> tres decisiones nuevas que son de Jorge** ([publicar.md](tareas/cerradas/publicar.md)):
> la etiqueta de la release (propuesta `v0.2.1`, y que un medio nuevo sea una
> `encina-meta` nueva), publicar `arm64` con hierro sólo `amd64`, y **conservar
> la ISO oficial `arm64`**, porque `old-releases.ubuntu.com` sólo guarda
> `amd64` y dentro de un año la entrada `arm64` no estará en Canonical (trampa
> 69). Ninguna casilla marcada hoy.
>
> ### AL DÍA, 2026-08-28: **LA FASE 2 ESTÁ COMPLETA — la refactorización entera, sin tocar un byte del producto** — y lo que queda es la fase 3, publicar
>
> **Añadido la tarde del 2026-08-28 (§4.81), la sesión previa a la fase 3:**
> los dos medios **refabricados desde estos guiones**, dos pasadas cada uno,
> y salen **`63f360dd…` y `3d5d12a9…` otra vez**, byte a byte iguales a los
> vigentes: la deducción de abajo («caducan con la fase 3») era falsa para los
> dos. **El archivo de Ubuntu ha retirado openjdk-17 `17.0.19+10-1~24.04.2`**
> (hoy da `17.0.20`) y `make dos-veces` dejó de terminar (§4.81c); esa misma
> tarde, por decisión de Jorge y sin atajos, `cosechar-repo.sh` **cae a
> Launchpad por huella** sólo cuando el archivo ha retirado (trampa 68) y
> **`make dos-veces` tal cual vuelve a dar las dos huellas** desde `8a0cbef`
> (§4.81f). También esa tarde: **la CI de verdad, los siete jobs en verde**
> (§4.81a), y las trampas 28b-33b **renumeradas a 62-67** (§4.81e). Lo que
> queda abierto para la fase 3 es una sola cosa nueva: Firefox no tiene fuente
> permanente (Mozilla retira y Launchpad no lo tiene), así que publicar
> incluye publicar la cosecha (`tareas/cerradas/publicar.md`).
>
> **Dónde está el proyecto:** la fase 1 del orden del 2026-08-23 está completa
> desde el 2026-08-25 —`3d5d12a9…` (`amd64`) en el hierro, §4.78, y `63f360dd…`
> (`arm64`) en el banco, §4.79, las dos instalando y verificando a 65 / 0, y las
> seis pantallas con el veredicto de Jorge—. **Y la fase 2, hoy:** las dieciséis
> tareas de [tareas/cerradas/refactorizacion.md](tareas/cerradas/refactorizacion.md),
> cada una con su definición de terminado ejecutada y un apartado en
> `MEDICIONES.md` §4.80. `bancos/enlaces.sh` en verde sobre el árbol entero
> movido —la condición de cierre— y el bloque está en `tareas/cerradas/`.
>
> **Lo que cambió, en una pantalla:** un solo vocabulario en `lib/salida.sh`
> (`fallo()` apunta y sigue, `morir()` aborta); `mediciones/`, un fichero por
> sección, con la tabla de vigencia entera y `bancos/vigencia.sh`; **`make
> bancos`** —ocho bancos, el job «bancos» de la CI, `shellcheck` por docker—,
> `make paquetes` (el constructor versionado en `docker/`, que da las huellas
> del manifiesto sin la VM), `make dos-veces` y `make verificador`; este §7 en
> una pantalla; `TRAMPAS.md`; los guiones por verbo y paquete; `fabricar-iso.sh`
> por fases; una sola fuente de la versión (`bancos/versiones.sh`); y la hoja de
> los `[OJOS]` debidos, [tareas/ojos.md](tareas/ojos.md).
>
> **Y lo que se creía y no era:** este párrafo decía que las dos huellas
> «caducan a propósito con esta fase». **La `arm64` no caducó**: `fabricar-iso.sh`
> refactorizado, sobre el mismo repositorio, da `63f360dd…` dos veces, byte a
> byte igual a la línea base tomada con los guiones de `794f57d` —y sin VM,
> con el índice `Packages` del contenedor— (§4.80l). De la `amd64` no se afirma
> nada hasta refabricarla. Lo que sigue `[OMIT]`: la CI de verdad (ningún push
> hoy; simulada tres veces en `ubuntu:24.04`), los guiones de VM (no se encendió
> ninguna), y el medio `amd64`.
>
> **Lo siguiente, y es lo último del proyecto: la fase 3.**
> [alojamiento.md](tareas/cerradas/alojamiento.md) y [publicar.md](tareas/cerradas/publicar.md):
> `make dos-veces ARQ=arm64` y `ARQ=amd64` desde estos guiones, instalar,
> mirar —[tareas/ojos.md](tareas/ojos.md) dice qué falta por mirar y dónde—, y
> publicar. Antes, un push para ver el job «bancos» en verde en la CI de verdad.
>
> **Lo que había aquí hasta el 2026-08-28** —1 772 líneas, del 2026-08-08 al
> 2026-08-25: la receta del hierro, el reloj del instalador `amd64`, la vuelta
> única, el bisecado de D23, y lo que §7 conservaba de E1 y E2— está movido
> **verbatim** a
> [tareas/cerradas/empieza-aqui-2026-08-08-a-2026-08-25.md](tareas/cerradas/empieza-aqui-2026-08-08-a-2026-08-25.md),
> con cada bloque bajo su fecha. Se lee cuando haga falta saber por dónde se
> empezó, no para empezar.

## 8. Fuera de alcance ahora

No implementar, no preparar, no dejar «ganchos para el futuro»:

`encina-doctor` y cualquier herramienta de diagnóstico · `encina-locale-es` ·
DNIe, `opensc` y PKCS#11 como funcionalidad · repo APT **firmado** y
`encina-keyring` · ~~`os-release` y `dpkg-divert`~~ **`dpkg-divert` sobre
`os-release` desde un paquete** · `live-build`, `debos` y Cubic ·
temas de GTK o iconos · cualquier GUI · amd64.

Cuatro matices:

- **`os-release` sale de esta lista a medias, el 2026-08-15, y se dice por qué en
  vez de cambiarlo en silencio: D22 choca de frente con esta línea.** Lo que
  estaba fuera de alcance era la pregunta entera, y D22 la contesta: **qué campos
  cambian y cuáles no está decidido** —presentación fuera, `ID` intacto (D6)—.
  Lo que sigue fuera de alcance es **el mecanismo**, y ahora con motivo medido:
  el `os-release` que dice Ubuntu en el arranque del medio **vive dentro de una
  capa `squashfs` de 1,69 GB** (§4.51), o sea que **un `dpkg-divert` desde un
  `.deb` no llega a tocarlo** —`encina-branding` no llega al medio, medido: 0
  ficheros—. Elegir entre divertir desde un paquete y escribir el fichero en la
  construcción de la imagen es de las casillas 3 y 4 del bloque 1, no de aquí.
  **ENMIENDA DEL 2026-08-15, D23: el mecanismo está decidido PARA EL MEDIO y
  sigue fuera de alcance PARA LA MÁQUINA INSTALADA, y esas son dos cosas
  distintas que conviene no confundir.** En el medio lo escribe **una capa
  `squashfs` propia** que tapa a la de 1,69 GB sin rehacerla (§4.52b), así que
  ahí `NAME="Encina OS"`. En la máquina instalada **sigue diciendo `Ubuntu`**,
  porque ningún `.deb` puede tocar ese fichero sin chocar con **R5** y nadie ha
  decidido todavía el `dpkg-divert`. **El medio y la máquina no dicen lo mismo, y
  eso es una deuda declarada, no un descuido.**

- **`encina-locale-es` y `encina-doctor` están aquí de forma permanente.** Los
  dos se midieron antes de abrirlos y los dos resultaron no existir. El resto de
  la lista espera turno y sale de aquí cuando le toque su incremento.
- **El repo APT firmado no hace falta y puede que no haga falta nunca.** Si los
  `.deb` solo los consume la construcción de la imagen, basta un repo local sin
  firmar generado en el propio build con `dpkg-scanpackages` y consumido con
  `[trusted=yes]`. Eso ejercita el mecanismo real —repo más metapaquete en el
  seed— sin gestión de claves, y la receta que se escriba así es la definitiva.
- **D13 sigue vigente.** Ninguna de las barreras de la firma se cierra desde
  `encina-branding` ni desde `encina-firefox-native`, por muy fácil que parezca.
- **Desde el 2026-08-10, reempaquetar la ISO oficial con `xorriso` ya NO está
  fuera de alcance: es E3 y está abierto.** Lo que sigue fuera, y no cambia, es
  **`live-build`, `debos` y Cubic**: los dos primeros son E5, y Cubic no entra
  nunca (D4). La frontera es exacta —E3 **reempaqueta** la imagen oficial y no
  toca ni uno de sus tres binarios firmados (§10); en cuanto haya que
  **rehacerla**, eso es E5.

---

## 9. Las VMs de UTM

**VUELVEN A SER DIEZ el 2026-08-13, al cerrar la vuelta de la ISO** (`MEDICIONES.md`
§4.35o): se borró `encina-E4-tienda` —la de la ISO defectuosa, sustituida por
`encina-E4-entrega`— y **devolvió 11,523 GiB reales** con `du` diciendo 12 G, o sea que
**aquí `du` acertó**, como §9.a predice para las nacidas del medio. **Y una de las dos
condiciones NO se cumplía, y se dice en vez de callarse:** su ISO (`aa1ac76a…`) **ya no
vivía en `e2-medios`**, porque se había borrado esa misma madrugada. Se borró igual
porque lo decidió Jorge. La otra sí: **su papel estaba traspasado midiendo**, no
suponiendo. El registro quedó consistente por las dos mitades: **10** en `utmctl list`
y **10** bundles, con `plutil -lint` en verde y el respaldo del `plist` hecho antes.
*Antes:* **eran ONCE el 2026-08-13, al refabricar la ISO** (§4.35): nació
`encina-E4-entrega`, la primera Encina OS nacida de una ISO que **lleva dentro la
tienda buena**. No se destruyó ninguna, así que el banco sube a 11, consistente por
las dos mitades: **11** en `utmctl list` y **11** bundles en disco, las once paradas.
**Y se borró un MEDIO, no una VM:** la ISO vieja `aa1ac76a…`, la defectuosa, que
**devolvió 0 GiB** — la fila nueva y sin explicar de §9.a. Antes de borrarla se guardó
en `e2-medios` el `encina-meta_0.2.0_all.deb` (`85c8cc56…`), que es lo único de ella *(versión histórica, la de aquel día)*
que no se puede rehacer.
*Antes:* **VOLVIERON A SER DIEZ el 2026-08-13, haciendo sitio**: se borró
`encina-E4-meta` —la de la 0.2.0, sustituida por `encina-E4-tienda`— y **devolvió
10,656 GiB reales** con `du` diciendo 10,78, o sea que **aquí `du` acertó**, como
§9.a predice para las nacidas de la ISO. Antes de borrarla se cumplieron las dos
condiciones: su ISO vive en `e2-medios` **por huella** (`aa1ac76a…`) y **su papel
se traspasó midiendo, no suponiendo** — `encina-E4-tienda` es virgen de Firefox
(0 `profiles.ini`, 0 `cert9.db`, 0 `.p12`, sin `~/.mozilla`, `~/.config/mozilla`,
`~/.cache/mozilla` ni `~/snap/firefox`, con el control de que el buscador
encuentra `.bashrc` y sabe decir cero), está en la forma (c) y tiene `ssh`.
El registro quedó consistente por las dos mitades: **10** en `utmctl list` y
**10** bundles.
*Antes:* **eran ONCE el 2026-08-13, al cambiar la tienda** (§4.34): nació
`encina-E4-tienda` —la primera Encina OS con **una sola tienda**, instalada sola
en 9 min con `ESTADO=COMPLETO`— y se destruyó `encina-tienda-efimera`, el clon del
nivel 1, que devolvió **0,502 GiB** con `du` diciendo 11 GB. El registro quedó
consistente por las dos mitades: **11** en `utmctl list` y **11** bundles en disco,
y el disco cerró en **5,163 GiB** libres.
*Antes:* **eran DIEZ el 2026-08-12 al cerrar la firma de E4** (§4.33): nació
`encina-firma-efimera` —clon de `encina-E4-meta`— y **se destruyó el mismo día**,
como manda §9.1, porque llevaba dentro el certificado personal. Devolvió
**2,008 GiB** medidos con `df`, y el registro quedó consistente por las dos
mitades: 10 en `utmctl list` y 10 bundles en disco.
*Antes:* **eran DIEZ al cerrar la ISO de E4** (§4.32): se borró
`encina-E4-iso` —devolvió **10,182 GiB** medidos con `df`— y nació
`encina-E4-cinco`, que hace su papel **y** las dos medidas que le faltaban. El
disco quedó igual que al empezar el día, **8,3 GiB**, y el registro consistente
por las dos mitades: 10 en `utmctl list` y 10 bundles en disco.
*Antes:* **eran DIEZ al cerrar la vuelta de E4** —nacieron `encina-E4-meta` y
`encina-E4-iso`, y se destruyó `encina-E4-sinred` en la misma sesión, que era la
de la medición sin red (§4.31l)—. *Antes:* **eran OCHO el 2026-08-11 al cerrar el día** —se borró `encina-E2-sinsnap`, que
**devolvió 12,923 GiB reales** (§4.30)— y ya no forman una sola familia.
El 2026-08-10 se borró `encina-E3-forma` —su pregunta la contestó mejor §4.23— y
nacieron tres: `encina-E3-iso`, `encina-E2-2vias` y `encina-E3-iso-es`. **El
2026-08-11, al abrir E4, se borraron dos más** —`encina-E3-iso` y
`encina-E2-0.2.1`, las dos sustituidas— y **devolvieron 25,35 GiB reales**,
medidos con `df` antes y después (`MEDICIONES.md` §4.26i).

- **Las ocho de E1** —clonadas unas de otras— comparten hostname `encina-dev`,
  usuario `jorge` con `sudo` sin contraseña y la IP `192.168.64.3`. **El hostname
  no distingue nada entre ellas.** Para saber en cuál estás, lo que funciona es
  «paquetes instalados + versión del Snap de Firefox + qué perfiles existen».
- **Las dos de E2** que quedan, las dos **nacidas de la ISO oficial**, con
  usuario `encina` y una IP propia cada una (`.7`, `.10`). Se entra con la
  clave efímera de la medición, no con la de siempre. Dos comparten hostname
  `encina-e2`; `encina-E2-sinsnap` y `encina-E2-completa` traen el suyo desde su
  propio seed, **y aun así hay que identificarlas por huella**.
  **Y desde el 2026-08-10 `telemetry` ya no basta para distinguirlas todas:**
  sirve para separar la del clic (`896:done`) de la desatendida (`552:done`),
  pero **`encina-E2-completa` da `409:done`, el mismo par que
  `encina-E2-sinsnap`** —medido, no deducido, y no se sabe qué mide ese número—.
  Lo que sí las separa es el testigo `/etc/encina-e2-testigo-seed`, que solo
  escribe el seed definitivo, y los cuatro paquetes de Encina instalados.

**No arrancar dos a la vez.** Se listan y se arrancan con `utmctl list` y
`utmctl start <nombre>`, sin abrir la interfaz de UTM. **Y no es un consejo:** el
2026-08-10 se arrancaron `encina-dev` y `encina-E1-meta` a la vez y las dos
respondieron en `192.168.64.3`, alternándose, sin que nada avisara (trampa 14 de
`SCRIPTS.md`). No estropeó ninguna medición **porque cada salida lleva dentro su
huella de identidad**, que es exactamente para lo que se pone.

| VM | Qué es | Vídeo | Estado |
|---|---|---|---|
| `encina-dev` | Banco de A1, con el usuario `prueba`. Snap 153.0.3 con perfil, sin Firefox nativo. **Y sobre todo: ES LA MÁQUINA DE CONSTRUIR**, que es un papel que esta tabla no decía (§4.30a) — `dpkg-scanpackages` no existe en macOS y rehacer el seed lo exige (`SCRIPTS.md`), y aquí se construyeron los `.deb` con `dch` (§4.19f) | `gpu-pci` | **En uso, y no es candidata a borrar: la vuelta de E4 la necesita.** Aquí se verificó `encina-branding` 0.1.7 |
| `encina-E1-meta` | **Banco de E1, y el único sitio donde se puede comprobar que algo no reabre A2**, porque es la única máquina con Snap **y** con los paquetes de Encina puestos. Clon virgen instalado por la secuencia. **Sin ningún certificado, a propósito.** Su huella de identidad: los cuatro paquetes, **`autofirma 1.9.1+encina1`** y el Snap `firefox 147.0.3-1` rev 7764. **La versión de `autofirma` es nueva en esta huella y no es un detalle** (§4.29b): faltaba, y por faltar esta fila declaró durante un día que aquí se podía contestar una pregunta sobre un paquete que la máquina no tiene | `gpu-pci` | **En uso. Fue el banco de la puerta de la convivencia (c), CONTESTADA el 2026-08-11** (§4.29) — pero **no sobre ella: sobre un duplicado**, que se destruyó al terminar. **Y salió que NO llevaba `+encina2` sino `+encina1`**, o sea que el vigilante por el que se preguntaba **no existía en esta máquina**; el `+encina2` se instaló en el duplicado. **Tampoco es virgen de Firefox**: tiene dos perfiles nativos, uno usado, y su almacén NSS estaba **vacío** —ni un `SocketAutoFirma`—. **No se borra.** Aquí se ejecutó la definición de terminado de E1, y el 2026-08-08 el experimento de la tarjeta: nació `ramfb-gl` y **se cambió** (§4.12b). **Cambiada el 2026-08-10 (§4.19e): ya NO es la máquina de §4.17h.** Lleva `encina-firefox-native` **0.2.1**, instalado sobre una sesión gráfica viva a propósito, que es como se midió la regresión de D11. El dock del usuario quedó como estaba (`dconf` vacío) y el autologin de GDM que hizo falta está revertido y verificado por huella (`ceee968c…10af`) *(versión histórica, la de aquel día)* |
| `encina-E1-vigilante` | **Donde se cerró el defecto de §4.12a.** Clon virgen instalado por la secuencia de E1 **sin el cuarto paso**, con `autofirma 1.9.1+encina2`: la CA del socket llegó sola al perfil al abrir Firefox (M18 de `encina-autofirma`). **Sin ningún certificado personal**, así que no le aplican las precauciones de §9.1 | `gpu-pci` | **Parada.** Se queda de momento: es el testigo del arreglo. **No sirve para reproducir el caso virgen otra vez** —ya tiene la CA dentro—, para eso hay que clonar de nuevo. El autologin de GDM que hizo falta quedó revertido y verificado por huella (`ceee968c…10af`) *(versión histórica, la de aquel día)* |
| `encina-limpia-respaldo` | Ubuntu 24.04.4 arm64 de fábrica, sin nada. Firefox nunca abierto | `gpu-pci` | Se queda: línea base virgen, y de ella se clona. **Cambiada el 2026-08-08** para que los clones no nazcan con AutoFirma invisible (§4.12g) |
| `encina-autofirma-rota` | AutoFirma 1.9 **oficial** sobre Firefox nativo, con la cadena causal medida | `gpu-pci` | Se queda: es la mitad roja de las mediciones, y la base del positivo de §4.9 |
| ~~`encina-dev-firefox`~~ | «Hoy en el mismo estado que la anterior» | `gpu-pci` | **Borrada el 2026-08-10** en la limpieza. Era redundante con `encina-autofirma-rota`, que se queda |
| `encina-snap-fabrica` | Ubuntu de fábrica + Snap. Caso positivo de la CA correcta y caso de prueba de B3 | `ramfb-gl` | **Ya no es candidata a borrar, y no por el Snap:** es el **único testigo de `ramfb-gl`** que queda, o sea el único sitio donde se puede reproducir que AutoFirma no se dibuja (§4.12g) |
| ~~`encina-A2-verificada`~~ | Red de seguridad de A2 | `gpu-pci` | **Borrada el 2026-08-10** en la limpieza. A2 está en git y en CI verde |
| ~~`encina-firma-efimera`~~ (2026-08-08) | El positivo de E1, sobre máquina virgen, con la secuencia que aún necesitaba un cuarto paso | `ramfb-gl` | **Destruida el 2026-08-08**, como manda §9.1: llevaba dentro el certificado personal |
| ~~`encina-firma-efimera`~~ (2026-08-09) | **La casilla que decide.** Otro clon virgen, mismo nombre, con la secuencia ya de tres órdenes: 29/0/1/1, la CA llegando sola, y la firma mirada en pantalla (§4.13) | `gpu-pci` | **Destruida el 2026-08-09.** Mismo motivo, misma regla: llevaba el certificado personal |
| ~~`encina-E2-seed`~~ | **Vía A de E2.** No es un clon: **nace de la ISO oficial**, instalada por el seed `CIDATA` con un clic en «Ready to install» (§4.14d). Es también donde se cerró la casilla novena con el repo local en `/srv/encina-repo` (§4.15) | `gpu-pci` | **En uso.** Su estado tras §4.15: `encina-meta` purgado y los otros tres puestos y marcados automáticos. **Sin ningún certificado personal.** Lleva un `sudoers.d` sin contraseña puesto para medir, y `dpkg-dev` purgado. **Borrada el 2026-08-10, cerrado E2.** Era la «vía A» —instalada con un clic— y estaba **modificada a mano** (`sudoers.d` sin contraseña, `dpkg-dev` purgado), así que no representaba nada entregable. Sus mediciones están escritas en §4.15. Devolvió **13 GB reales** |
| ~~`encina-E2-desatendida`~~ | **Vía B de E2, y el testigo que importa: instalada sin que nadie la tocara**, con `autoinstall` en la línea de órdenes y `-no-reboot` (§4.14h). Sus dos testigos de `late-commands` están dentro | `gpu-pci` | **Parada.** Se queda: es la única máquina del proyecto que nadie ha tocado a mano. **Sin certificado personal**. **Borrada el 2026-08-10, cerrado E2.** Era el testigo de §4.14h, «la única máquina que nadie ha tocado a mano»; ese papel lo hace ahora `encina-E2-0.2.1`, que también la instaló el seed y además es el producto vigente. Devolvió **9 GB reales** |
| ~~`encina-E2-firefox`~~ | **Fue el banco de §4.17**, clon de `encina-E2-sinsnap`. Allí se midió por qué vía llega Firefox nativo sin deb de transición, y salió el duplicado de iconos | `gpu-pci` | **Borrada el 2026-08-10** en la limpieza. Su medición está escrita en §4.17, y su estado final lo reproduce `encina-E2-completa` **por seed** en vez de a mano |
| ~~`encina-E2-completa`~~ | **LA MÁQUINA DE E2, y la primera Encina OS entera instalada sola.** Nace de la ISO oficial con el seed definitivo `imagen/autoinstall.yaml` (§4.18): repo local con los cuatro `.deb` dentro del propio volumen, `encina-meta`, sin Snap, Firefox nativo en español. Hostname `encina-e2-completa`, IP `.8`. Su bundle de UTM se construyó a mano | `gpu-pci` | **Parada.** **Ya NO es de aquí de donde sale el clon efímero de la firma** (lo es `encina-E2-0.2.1`): esta máquina se quedó con la 0.2.0 y con los dos iconos, y además **ya no es virgen de Firefox**. Se conservó **como control hasta que la firma saliera**, no por nostalgia: si hubiera fallado sobre la máquina nueva, era lo único que distinguía «lo ha roto la 0.2.1» de «la firma no iba a salir de todas formas». **La firma salió el 2026-08-10, así que ya sobra: es la primera candidata a borrar.** **Sin ningún certificado personal.** **No es virgen de Firefox**: se abrió una vez, a propósito, para medir el vigilante de AutoFirma (§4.18l). Lleva dentro su propio registro de instalación en `/etc/encina-seed.log`, 1916 líneas. **El 2026-08-10 se usó de banco para §4.19 sin modificarla:** el usuario `encina` no tiene `sudo` sin contraseña, así que los estados de la sombra se midieron sobre un árbol `XDG_DATA_DIRS` sintético en `/tmp`, con el control de que sin mutar da lo mismo que el sistema real. **Queda con `encina-firefox-native` 0.2.0**, o sea con los dos iconos: la sustituye `encina-E2-0.2.1`. **Borrada el 2026-08-10, cerrado E2.** Su único trabajo desde que existió la 0.2.1 era ser el control por si la firma fallaba; la firma salió (§4.20d). Devolvió **12 GB reales**, que confirma §9.a: nació de la ISO y no compartía bloques con nadie |
| ~~`encina-E2-0.2.1`~~ | **LA MÁQUINA DE E2 VIGENTE**, la que sustituye a `encina-E2-completa` como banco de la entrega. Nace de la ISO oficial con el seed reconstruido (`b8269e52…`), ya con `encina-firefox-native` **0.2.1** dentro, así que es la primera Encina OS con **un solo icono de Firefox**. Instalada de una pasada en **10 min 07 s** sin que nadie abriera su ventana (§4.19g). Su bundle de UTM se fabricó sin tocar la interfaz. IP `.9` | `gpu-pci` | **Parada.** Se queda: es de aquí de donde tiene que salir ahora el clon efímero de la firma `[OJOS]`. **Virgen de Firefox y sin ningún certificado personal, y está medido, no supuesto:** no existen `~/.mozilla`, `~/.config/mozilla` ni `~/snap`, cero perfiles, cero `cert9.db` y cero `.p12` —con el control de que el `find` sabe encontrar algo—. Verificada con `imagen/verificar-instalacion.sh`: 34 correctas, 0 fallos. **Y `telemetry` sí la distingue: `421:done`**, frente al `409:done` que comparten `encina-E2-completa` y `encina-E2-sinsnap`. **Ojo: su hostname es `encina-e2-completa`, igual que la vieja**, porque lo pone el seed; se distinguen por el testigo `/etc/encina-e2-testigo-seed` (`17:14:27Z` la vigente, `14:50:22Z` la vieja). **Borrada el 2026-08-11, al abrir E4** (§4.26i). La sustituyó `encina-E2-2vias` como banco de E2 el 2026-08-10, y lo único que le quedaba era ser el origen del clon efímero de la firma. **Ese papel se traspasó midiendo, no suponiendo:** `encina-E2-2vias` es virgen de Firefox —cero `profiles.ini`, cero `cert9.db`, cero `.p12`, sin `~/.mozilla`, `~/.config/mozilla`, `~/snap` ni `~/.cache/mozilla`, con el control de que el `find` sabe encontrar algo y sabe decir cero—. Nacida de la ISO, o sea independiente |
| ~~`encina-E3-iso`~~ | **LA MÁQUINA DE E3, y la primera nacida de una ISO de Encina.** Creada desde cero —sin clonar, sin heredar nada—, con **dos unidades y ni una más**: `encina-os-E3.iso` (`0a1127f4…`) y un disco vacío. Se instaló contestando **solo las cinco pantallas de Ubuntu** y su registro dice `CIDATA -> <no encontrado>` / `REPO ELEGIDO -> /cdrom/encina-repo` (§4.23). Usuario y contraseña los eligió Jorge | `gpu-pci` | **Borrada el 2026-08-11, al abrir E4** (§4.26i). Su condición para quedarse —«hasta que la ISO en español tenga su propia máquina instalada»— se cumplió el 2026-08-10 con `encina-E3-iso-es`. **Su instalador se vio en inglés**, que es el defecto que abrió la novena casilla, y su medición está escrita entera en §4.23. Nacida de la ISO, independiente: junto con `encina-E2-0.2.1` devolvió 25,35 GiB, **y de esos 3,4 GB eran el clon de APFS de la ISO inglesa que llevaba dentro** — la trampa 21 de `SCRIPTS.md` |
| ~~`encina-E3-forma`~~ | **El banco de §4.22:** la forma de E3 medida **antes de tocar `xorriso`**, con `CIDATA` y la ISO oficial. Ahí se midió que el instalador de escritorio **sabe mezclar** secciones interactivas y no interactivas | `gpu-pci` | **Borrada el 2026-08-10, con el permiso de Jorge y para hacer sitio.** Su única pregunta la contestó **mejor** §4.23, que midió lo mismo sobre la ISO de verdad; su medición está escrita entera. Nació de la ISO oficial, o sea independiente: **devolvió 10,2 GiB reales**, confirmando §9.a |
| ~~`encina-firma-efimera`~~ (2026-08-12) | **La firma real sobre la forma (c), que es la casilla más cara que quedaba.** Tercer clon efímero con el mismo nombre, y el primero que sale de una máquina de E4: `snapd` dentro, Snap de Firefox presente y nunca abierto, `autofirma 1.9.1+encina4`. «Fichero firmado correctamente» en `valide.redsara.es`, mirado en pantalla (§4.33) | `gpu-pci` | **Destruida el 2026-08-12.** Misma regla de siempre: llevaba el certificado personal. **Y el control de que la original no se tocó no fue «estaba parada»**, que es débil, sino la fecha de escritura de su imagen de disco leída desde el anfitrión: `encina-E4-meta/Data/disco.img` seguía en las `11:19:15` de esa mañana mientras la del clon marcaba las `20:31:11`. Devolvió **2,008 GiB** con `du` diciendo 11 GB. **Aquí se descubrió que `utmctl clone` NO regenera la MAC**, así que un clon y su origen son indistinguibles por MAC *y* por IP |
| ~~`encina-E4-meta`~~ | **FUE LA MÁQUINA DE E4, y la primera Encina OS que es un escritorio que crece.** Nace del seed `360bb894…` sobre la ISO oficial, **desatendida, en 9 min 52 s**, y **se apagó sola** —que desde el 2026-08-12 significa `ESTADO=COMPLETO`, porque el seed sale distinto de 0 si no lo está—. Verificada como root: **48 correctas, 0 fallos, 0 avisos, 0 omitidas**. Su huella de identidad: `encina-meta 0.2.0`, `encina-branding 0.1.8`, `encina-firefox-native 0.2.1`, **`autofirma 1.9.1+encina4`**, `firefox 153.0.4~build1` sin epoch, Snap `firefox_7764` **presente y nunca abierto**, y `gnome-software` + `simple-scan` dentro. IP `.15`, hostname `encina-e2-completa` —lo pone el seed, como todas—, testigo `/etc/encina-e2-testigo-seed` de las `00:55:08Z` | `gpu-pci` | **Parada. Se queda: es el banco de E4, y desde el 2026-08-12 es también EL ORIGEN DEL CLON EFÍMERO DE LA FIRMA** (§4.33) — se eligió frente a `encina-E4-cinco` porque tiene `ssh` y así los ojos se gastan solo en firmar. **No se encendió durante aquella sesión, y está medido**: su `disco.img` no se escribió ni una vez (§4.33d). **Sin certificado personal**, y **en la forma (c)**: 0 perfiles de Mozilla bajo `~/snap/`, comprobado después de crear y destruir el usuario desechable de la medición de `+encina4`. El autologin de GDM que hizo falta para el `[OJOS]` está revertido y verificado por huella (`ceee968c…`) *(versión histórica, la de aquel día)* |
| ~~`encina-E4-iso`~~ | **Fue la máquina de la ISO de E4** (`aa1ac76a…`), creada desde cero. Se usó primero para comprobar **con los ojos** que la ISO arranca y que **el instalador se ve en español**, con el control de la trampa 16 recogido antes: **0** `-append` y **dos** unidades. Después se rehízo desatendida con un `CIDATA` que lleva **solo el YAML y ningún repo**, para que el repositorio tuviera que salir de `/cdrom`. **14 min 13 s, se apagó sola**, y su registro dice `CIDATA -> /dev/vdb` **y** `REPO ELEGIDO -> /cdrom/encina-repo`. Verificada como root: **48 correctas, 0 fallos** | `gpu-pci` | **BORRADA EL 2026-08-12** (§4.32b), que era lo que §4.31ñ dejó nombrado: nació de la ISO, o sea **caché reproducible** (§9.a). **Devolvió 10,182 GiB reales**, medidos con `df` antes y después. Antes de borrarla se comprobó **por huella** que su ISO vive en `e2-medios` (`aa1ac76a…`), y salió mejor de lo escrito: **su bundle no llevaba ningún clon de la ISO dentro**, así que aquí no aplicaba la trampa 21. Su papel lo hace ahora `encina-E4-cinco`, que además mide las dos cosas que a ésta le faltaban. Su medición está escrita entera en §4.31n **BORRADA EL 2026-08-13**, con permiso de Jorge y para hacer sitio: lleva la **0.2.0**, o sea la tienda vieja, y la sustituye `encina-E4-tienda` con la 0.2.1. Nació de la ISO → **caché reproducible** (§9.a), y **devolvió 10,656 GiB reales** medidos con `df` antes y después. **Sus dos papeles estaban traspasados antes de tocarla:** el de banco de E4, a `encina-E4-tienda`; y el de **origen del clon efímero de la firma**, medido y no supuesto —la nueva es virgen de Firefox con sus dos controles—. Su medición está escrita entera en §4.31, §4.33 y §4.34 |
| `encina-E4-entrega` | **LA MÁQUINA DEL ENTREGABLE: la primera Encina OS nacida de una ISO que lleva dentro la tienda buena** (§4.35). Creada desde cero desde `encina-os-E4-es-0.2.1.iso` (`ac0a5721…`) **enlazada en duro** (`2 enlaces`), con un `CIDATA` de 128 MiB (`53479f61…`) que lleva el YAML de E2 y **NINGÚN `encina-repo` dentro**, para forzar que el repositorio salga del medio. Instalada **desatendida en 9 min**, **se apagó sola** = `ESTADO=COMPLETO`. La línea que decide, del registro que dejó ella sola: **`REPO ELEGIDO -> /cdrom/encina-repo`** y 29 ficheros copiados. Testigo de las `00:06:03Z`, MAC propia `76:CE:28:E4:72:1A`, IP `.19` | `gpu-pci` | **Parada. Es el entregable vigente.** `verificar-instalacion.sh --visibles 27` como root: **51 correctas, 0 fallos, 0 avisos, 0 omitidas**, con `encina-meta` **0.2.1** salido del medio, `gnome-software` en `unknown ok not-installed` y `snap-store` rev 1271. **Y sobre ella está el `[OJOS]` que §4.34 dejó sobre un clon:** una sola tienda **mirada en la rejilla de la instalación limpia**, con el contador sabiendo decir 2, 1 y 0. **Sin certificado personal**, forma (c), **0** perfiles de Mozilla bajo `~/snap/` con el control de los dos sentidos. **Y es también donde está medido que la tienda INSTALA** (§4.35i): lleva `libreoffice` **rev 376** puesto desde el Centro de aplicaciones, **34** aplicaciones visibles, y `verificar-instalacion.sh --visibles 34` sigue dando **51 correctas, 0 fallos** con la forma (c) intacta. Lo que lleva encima de una instalación virgen y se dice: LibreOffice y sus tres dependencias (`core24`, `gnome-46-2404`, `mesa-2404`), **el Snap de Firefox autorrefrescado solo de rev 7764 a 8753** —con las dos revisiones en disco—, `~/.config/gnome-initial-setup-done`, `~/snap/` con `snap-store` y `libreoffice`, y los índices de `apt` actualizados. El autologin de GDM se activó y se **revirtió por huella** (`ceee968c…` antes y después) |
| ~~`encina-E4-tienda`~~ | **LA MÁQUINA DE LA TIENDA, y la primera Encina OS en la que el usuario ve UNA SOLA TIENDA.** Creada desde cero, con la ISO `aa1ac76a…` enlazada en duro y un `CIDATA` nuevo (`f99324ff…`, 768 MiB) que lleva dentro `encina-meta` **0.2.1**. Instalada **desatendida en 9 min**, **se apagó sola** = `ESTADO=COMPLETO`. Su huella: `encina-meta 0.2.1`, `branding 0.1.8`, `firefox-native 0.2.1`, `autofirma 1.9.1+encina4`, **`gnome-software` en `unknown ok not-installed`** y **`snap-store` rev 1271** en `snap list`. Testigo `/etc/encina-e2-testigo-seed` de las `22:55:41Z`, IP `.18` | `gpu-pci` | **Parada. Se queda: es el banco de D18 reescrita**, y el único sitio donde está medido que `encina-meta` 0.2.1 instala solo y deja **una** tienda: `verificar-instalacion.sh --visibles 27` como root da **51 correctas, 0 fallos, 0 avisos, 0 omitidas**, con **1** icono de Firefox y **27** aplicaciones visibles que **coinciden con las declaradas por adelantado**. **Sin certificado personal**, forma (c). **Costó CUATRO instalaciones y las cuatro están escritas** (§4.34j y §4.34k): la 1ª cazó que el seed llevaba su propia lista de paquetes obligatorios, la 2ª se la comió el **Mac durmiéndose** a mitad, la 3ª aisló que **`-set discard=off` rompe la instalación**, y la 4ª es ésta. **PASA A SER CANDIDATA A BORRAR EL 2026-08-13** (§4.35m): `encina-E4-entrega` hace lo mismo por un camino mejor —nace de la ISO corregida y con el repositorio saliendo del medio—, y **su ISO (`aa1ac76a…`) ya no vive en `e2-medios`**, así que la condición de §9.a no se cumpliría: hay que decirlo antes de borrarla, no descubrirlo después. ~~**Es de Jorge decidirlo**~~ **BORRADA EL 2026-08-13** (§4.35o), con permiso de Jorge y **sabiendo que esa condición no se cumplía**. **Devolvió 11,523 GiB reales** medidos con `df` antes y después, con `du` diciendo 12 G: nació del medio, así que aquí `du` acertó. Su papel estaba traspasado **midiendo**: `encina-E4-entrega` hace lo mismo por mejor camino y encima lleva las dos casillas `[OJOS]` de §4.35. Se conservó su rastro en `e2-medios/rastro-encina-E4-tienda/` (119 KB), **y al hacerlo salió un hallazgo del banco: `debug.log` no es un registro, es un volátil** — UTM lo reescribe en cada arranque, así que el control de la trampa 16 que §4.34i cita **ya no estaba dentro**. Su medición está escrita entera en §4.34 |
| `encina-E4-cinco` | **LA MÁQUINA QUE CIERRA LA ISO DE E4, y la primera de este proyecto instalada contestando de verdad las cinco pantallas de la ISO de E4** (§4.32f). Creada desde cero, con la ISO `aa1ac76a…` enlazada **en duro** al bundle y **ningún `CIDATA`** —control de la trampa 16 antes de arrancar: **0** `-append`, `media=disk` + `media=cdrom` y nada más—. Su registro dice `CIDATA -> <no encontrado>` y `REPO ELEGIDO -> /cdrom/encina-repo`, o sea que **el seed salió del quinto sitio**, de dentro de la ISO. Su `telemetry` nombra **exactamente** las cinco: `keyboard, network, storage, identity, timezone`. Verificada como root: **47 correctas, 2 fallos**, y los dos fallos eran **del verificador**, corregidos el mismo día. Usuario `encina`, **hostname `encinacin`** —tecleado `encinacinco` y el instrumento se comió dos letras, §4.32h—, testigo de las `08:18:21Z` | `gpu-pci` | **Parada. Se queda: es el testigo de que la ISO de E4 se basta sola.** **Sin certificado personal**, forma (c). **No tiene `ssh`** —la forma de E3 no lo lleva a propósito—, así que se mide por el volumen FAT de §4.25e, que sigue conectado como segunda unidad con el verificador vigente (`1128f738…`) dentro. **Las dos últimas pantallas las contestó Jorge con la mano**, que es exactamente lo que §6ter.0 declara como la forma de E3 |
| ~~`encina-udev-settle`~~ | **Clon de APFS de `encina-E4-entrega`, hecho el 2026-08-23 (noche) para medir el coste del drop-in de `gdm.service` en arm64** (`MEDICIONES.md` §4.71): ocho arranques, tres sin el fichero, tres con él y un control quitándolo. Misma MAC e IP `.19` que su origen (trampa 29): **no se encienden las dos a la vez**. Testigo `/etc/encina-testigo-udev-settle` de las `17:13:56Z` | `gpu-pci` | **Parada, sin el drop-in** (se quitó para el control) y no es banco de nada más: se puede borrar. La original no se escribió: su `disco.img` sigue en `2026-08-13 10:29:38`. **Borrada el 2026-08-23 (noche), la misma sesión**, a petición de Jorge: `utmctl delete`, cuatro VMs en `utmctl list` y cuatro `.utm` en disco, y devolvió **164 MiB** (`df` 102 480 376 → 102 647 980 KiB): lo que escribió en ocho arranques, porque el resto eran bloques compartidos con su origen (§4.29). Su medición está entera en §4.71 |
| `encina-E2-2vias` | **LA MÁQUINA DE E2 VIGENTE desde el 2026-08-10 (§4.24)**, la que sustituye a `encina-E2-0.2.1`: nace del seed **de las dos vías**, el que hoy está en `imagen/autoinstall.yaml` (volumen `13aa8f59…`). Instalada desatendida, **8 min 30 s** desde el arranque hasta el final del seed. Verificada como root: **35 correctas, 0 fallos, 0 avisos, 0 omitidas**. IP `.13`, MAC `76:CE:28:E7:F7:AA` | `gpu-pci` | **Parada.** Se queda: es el testigo de que la receta entera sigue funcionando **sin humano**, que es lo único que la forma de E3 ya no puede probar. Sin certificado personal. **Su hostname es `encina-e2-completa`**, como todas las del seed de E2: se distingue por el testigo `/etc/encina-e2-testigo-seed` (`2026-08-10T22:03:03Z`). Durante su instalación salió **dos veces** el `QEMU error … Invalid argument` del banco, y se comprobó donde se vería el daño: `errors_count` 0. **Desde el 2026-08-11 hace además dos papeles nuevos** (§4.26): fue **el instrumento de la medición de apertura de E4** —legítimo porque su recuento de aplicaciones visibles dio los mismos **25** que las dos máquinas de E3, que era el control declarado por adelantado, y porque su única diferencia de conjunto instalado con la entrega es `openssh-server`, que no tiene `.desktop`—; y **hereda de `encina-E2-0.2.1` el papel de origen del clon efímero de la firma**, porque se midió que es virgen de Firefox. **Cuando E4 pase a la convivencia (c), será una de las dos últimas máquinas del banco sin Snap** |
| `encina-E3-iso-es` | **La máquina del `[OJOS]` de la novena casilla:** creada desde cero para la ISO **en español**, `encina-os-E3-es.iso` (`02ab929d…`), con dos unidades y ni una más. El control de la trampa 16 está recogido **antes de que arrancara nada**: `0` argumentos `-append` y dos unidades además del firmware | `gpu-pci` | **Parada. LA MÁQUINA QUE CIERRA E3, 9 de 9** (§4.25d). El instalador **se vio en español** —lo declara Jorge— y la máquina que sale da **36 correctas, 0 fallos**, con `REPO ELEGIDO -> /cdrom/encina-repo`. Usuario `encina`, hostname `encina-QEMU-Virtual-Machine`, que **lo eligió el instalador y no el seed** — otra razón para no identificar por nombre. **Sin servidor `ssh` a propósito**, así que se midió por un volumen FAT conectado **después** de instalar (§4.25e). Sin certificado personal. Sustituye a `encina-E3-iso`, que pasa a ser la primera candidata a borrar |
| ~~`encina-E2-sinsnap`~~ (nacida como `encina-E2-control`) | **Era el control de §4.14i**, cuyo valor estaba en el registro y no en el disco. **Se consumió el 2026-08-10** para medir si el Snap se puede quitar desde el seed (§4.16), y **ya no es un control**: lo que queda de aquel control es lo escrito en §4.14i | `gpu-pci` | **Parada.** Ahora es **la primera máquina de Encina OS sin Snap**: instalada desatendida en 8 min 32 s, sin `/var/lib/snapd`, sin `/snap`, sin orden `snap`, con el saludador de GDM vivo. Hostname propio `encina-e2-sinsnap`, IP `.7`. **Sin certificado personal**, y **sin `sudo` sin contraseña** (al revés que `encina-E2-seed`). **Candidata a borrar el 2026-08-11 y NO borrada, con su motivo** (§4.26i): con 33,5 GiB libres la vuelta de E4 ya está pagada, y lo irreversible no se hace cuando no compra nada hoy. Al pasar a la convivencia (c) **todas las máquinas nuevas tendrán Snap**, así que ésta y `encina-E2-2vias` serán las dos últimas sin él y la segunda tiene un papel que no se puede gastar. **Es la siguiente candidata, y vale ~13 GB reales** porque lleva dentro su propio clon de la ISO oficial. **BORRADA EL 2026-08-11** (§4.30), con permiso de Jorge y para pagar la vuelta de E4: **D16 gastó su papel** —con la convivencia (c) todas las máquinas nuevas llevan Snap— y era independiente, así que **devolvió 12,923 GiB reales**, medidos con `df` una a una. Antes de borrarla se comprobó **por huella** que su ISO (`c2610520…`), su `Image` (`a1586ff3…`) y su `initrd` viven también en `e2-medios`. **Y llevaba dentro el seed `3fcddd26…`, que el recibo de §4.26i daba por destruido**: sobrevivía una copia dentro del bundle. Se fue con ella; su medición (§4.16) está escrita entera y lo sustituye `13aa8f59…` |

**La columna de vídeo es nueva y no es decorativa: con `ramfb-gl`, la interfaz de
AutoFirma no se dibuja.** Medido el 2026-08-08 en la misma VM cambiando solo la
tarjeta (`MEDICIONES.md` §4.12b): `colores=1` con `ramfb-gl` y `colores=3858` con
`gpu-pci`, sin ninguna variable de entorno. Antes de saberlo, las VMs no eran
comparables entre sí y el diff completo de sus configuraciones de UTM daba **esa
única diferencia** (§4.12c): un resultado visual medido en una familia no valía
automáticamente en la otra.

**Ese mismo día se igualaron**, para que ningún clon nuevo vuelva a nacer con
AutoFirma invisible: `encina-E1-meta` y `encina-limpia-respaldo` pasaron a
`gpu-pci`. **`encina-snap-fabrica` se dejó a propósito en `ramfb-gl`**, porque
igualarlas todas escondería un fallo que un usuario final puede sufrir y hace
falta un sitio donde reproducirlo (§4.12g).

**Para saber qué tarjeta tienes puesta, `lspci` no sirve** — devuelve
`Virtio 1.0 GPU (rev 01)` con las dos. La que discrimina, validada contra los dos
estados conocidos antes de usarla (§4.12e):

```
sudo dmesg | grep '\[drm\] features:'      # +virgl = ramfb-gl ; -virgl = gpu-pci
```

### 9.a Cuánto ocupan de verdad, que no es lo que dice `du`

**Medido el 2026-08-10, haciendo limpieza, y no es un detalle:** se borraron tres
VMs que sumaban **34,8 GB según `du`** y el disco solo devolvió **unos 2 GiB**.

El motivo es que **un clon de APFS no ocupa nada y `du` lo cuenta entero**, y las
VMs de este proyecto están clonadas unas de otras —las de E1 entre sí, y
`encina-E2-firefox` con el `duplicate` de UTM (§4.17b)—. Medido con su control,
que es lo que separa las dos mitades:

```
cp    fichero copia   ->  el disco baja 2000 MB    du: 2000 MB
cp -c fichero clon    ->  el disco baja      0 MB    du: 2000 MB   <- la mentira
borrar el clon        ->  el disco sube      0 MB
```

`cp` normal **no** clona, así que la comparación no es una suposición: la misma
orden con y sin `-c` da resultados opuestos, y `du` responde lo mismo en los dos
casos.

**Consecuencia práctica, para la próxima limpieza:** borrar un clon libera solo
lo que ha divergido. Lo que devuelve espacio de verdad son las máquinas
**independientes** —las cuatro de E2 nacen cada una de la ISO, así que no
comparten bloques con nadie— o **una familia entera** de clones. Y **no se puede
elegir por tamaño mirando `du`**: hay que saber quién es clon de quién.

**Y el 2026-08-11 esto se amplió por un sitio que no estaba escrito: el
directorio de medios miente igual** (`MEDICIONES.md` §4.26i, trampa 21 de
`SCRIPTS.md`). El `Data/` de cada bundle de UTM lleva **un clon de APFS de su
ISO**, así que borrar la copia de `e2-medios` no libera nada mientras el bundle
siga vivo:

```
libres antes                     8,21 GiB
rm de 3,67 GB de medios          8,65 GiB    <- 0,44 GiB devueltos
rm de encina-E3-iso y E2-0.2.1  33,57 GiB    <- ahi llegaron los 3,4 GB de la ISO
```

Y las dos explicaciones fáciles quedan descartadas con su control: **no son
enlaces duros** (`stat -f %l` da **1** en todas las ISOs, porque un clon de APFS
comparte bloques y aun así muestra un solo enlace) **ni instantáneas locales**
(`tmutil listlocalsnapshots /` vacío).

**Las dos reglas que salen de aquí:** al planear una limpieza, **la ISO se cuenta
una sola vez** —borrar el medio y borrar su VM no son dos ahorros, son uno—, y
**el retorno se mide, no se predice**: `df` antes, borrar, `df` después, y a la
medición va la resta.

**Y una tercera, del 2026-08-13, que casi estropea una medición limpia: `df` mide
EL DISCO ENTERO, no lo que tú has borrado.** Haciendo sitio, entre dos lecturas
aparecieron **~14 GiB** que no eran de ninguna VM: Jorge estaba borrando modelos
de `ollama` en paralelo. Llegué a escribir que «el número se mueve solo», que era
una explicación **falsa y cómoda**; la buena la dio él. El borrado de
`encina-E4-meta` salió limpio **por poco**, porque su `df` antes y después fueron
seguidos. **La regla: la resta de `df` solo mide lo tuyo si NADIE MÁS toca el
disco entre las dos lecturas**, así que las dos van pegadas al borrado y, si algo
no cuadra, lo primero que se pregunta es qué más ha pasado en el Mac — no se le
inventa una explicación al número.

**Y el 2026-08-11 se midieron LOS DOS EXTREMOS de la mentira el mismo día y en el
mismo disco** (§4.29h y §4.30), que es lo que convierte la regla en una tabla:

```
clon de la familia de E1   du 9,2 GB   ->  devolvio 0,923 GiB   <- miente por DIEZ
clon de una nacida de ISO  du  11 GB   ->  devolvio 2,008 GiB   <- miente por 5,5 (§4.33)
clon APENAS TOCADO         du  11 GB   ->  devolvio 0,502 GiB   <- miente por ~22 (§4.34)
independiente (de la ISO)  du  13 GB   ->  devolvio 12,923 GiB  <- aqui du acierta
independiente (de la ISO)  du  12 GB   ->  devolvio 11,523 GiB  <- y otra vez (§4.35o)
un MEDIO, no una VM       3,46 GB      ->  devolvio 0,000 GiB   <- y SIN EXPLICAR (§4.35)
```

**La segunda fila «independiente» es del 2026-08-13** (`encina-E4-tienda`) y no aporta
una regla nueva: **confirma la que había**. Una máquina nacida del medio no comparte
bloques con nadie, así que `du` no miente sobre ella. Es la única de las cinco filas en
la que se puede predecir el retorno — y aun así se midió, porque predecirlo es
justamente lo que salió mal en la fila del medio.

**LA ÚLTIMA FILA ES DEL 2026-08-13 Y NO ENCAJA EN LA REGLA, así que se escribe tal
cual en vez de forzarla** (`MEDICIONES.md` §4.35l). Borrar la ISO vieja de E4
—3 715 366 912 bytes— **no devolvió nada**, y la trampa 21 se había descartado
**midiendo antes de borrar**: `1 enlace` y **ningún bundle vivo la llevaba dentro**.
El control es lo que lo convierte en hallazgo y no en misterio:

```
dd de 3 GiB en el MISMO directorio  -> df baja 3 154 840 KiB
rm de esos 3 GiB                    -> df los devuelve enteros
```

**El disco sí libera; esos 3,46 GB no estaban donde yo creía.** Descartadas también
las instantáneas locales (`tmutil listlocalsnapshots /` vacío), la existencia de otro
fichero del mismo tamaño (no hay, y la ISO nueva tiene otro inodo) y que algún proceso
retuviera el fichero borrado. **Queda medido y sin causa**, que es lo que manda la
tercera regla de aquí abajo: al número no se le inventa una explicación.

**Y la consecuencia práctica: `du` tenía una simétrica sin escribir.** No solo hay
ficheros que `du` cuenta de más porque son clones; hay ficheros que `du` cuenta y cuyo
borrado no devuelve nada **sin ser clon de nada que se pueda encontrar**. Con lo cual
la regla se refuerza en vez de aflojarse: **el retorno se mide con `df`, y solo con
`df`, y las dos lecturas van pegadas al borrado.**

**La fila del ×22 es del 2026-08-13 y corrige la regla, que estaba incompleta:**
las dos primeras filas son **clones de la misma máquina** —`encina-E4-meta`— y sin
embargo devuelven 2,008 GiB y 0,502 GiB. O sea que **la mentira de `du` no depende
solo de quién es clon de quién, sino de CUÁNTO ha divergido el clon**: §4.33 metió
un certificado y abrió Firefox; §4.34 purgó tres paquetes y sacó capturas. La
pregunta antes de una limpieza pasa a ser **dos**: «¿de quién es clon?» y «¿cuánto
ha escrito desde que nació?».

**La fila del medio es del 2026-08-12** y coloca el caso que faltaba: un clon
**de una máquina nacida de la ISO** miente menos que uno de la familia de E1
—porque su origen no comparte bloques con nadie más— pero miente igual. La regla
no cambia: **el retorno se mide con `df`, no se predice con `du`.**

**`du` no miente siempre: miente sobre los clones.** Sobre una máquina nacida de
la ISO, que no comparte bloques con nadie, su número es bueno. Así que la pregunta
correcta antes de una limpieza no es «¿cuánto ocupa?» sino **«¿de quién es clon?»**,
y la respuesta la da el origen: nacida de la ISO → independiente; clonada con
`utmctl clone` o el `duplicate` de UTM → comparte.

**Corolario que decide qué se borra, y no es de espacio:** las máquinas nacidas de
la ISO son **una caché reproducible** —renacen del medio y del seed en 8–11 minutos,
medido tres veces— y las de la familia de E1 son **estados que no fabrica ningún
guion**. O sea que **lo que libera espacio de verdad es justo lo que es barato
rehacer**, y lo que no se puede rehacer no ocupa casi nada. La condición antes de
borrar cualquiera: comprobar **por huella** que su ISO y su seed viven también en
`e2-medios`.

### 9.1 No hay estado bueno conservable, y es a propósito

`encina-autofirma-firma` —la VM donde salió el primer positivo de extremo a
extremo el 2026-08-07— **ya no existe. Se destruyó deliberadamente porque
contenía el certificado personal de la FNMT**, y una máquina con un certificado
de firma real dentro no se guarda ni se clona. Es la decisión correcta y no se
revisa.

**La consecuencia hay que tenerla presente cada vez que se escriba una
definición de terminado**, porque es fácil escribir una casilla imposible:

- **El positivo sigue siendo real.** Está medido y registrado con sus salidas
  (`MEDICIONES.md` §4.9, y M11 del repositorio `encina-autofirma`). Lo que no
  hay es una máquina contra la que volver a contrastar.
- **Todo lo que no sea la firma final se verifica con un certificado de
  prueba**, sin tocar el personal: es lo que ya se hizo en M6 con
  `CERT-PRUEBA-ENCINA`, y lo que hacen las 21 comprobaciones de
  `verificar-deb.sh` en contenedor. Cubre las seis barreras salvo el «¿la sede
  lo acepta?».
- **La firma real es, por construcción, manual y efímera.** Se clona una VM, se
  mete el certificado, se firma en `valide.redsara.es`, se mira en pantalla, se
  anota, y **se destruye la VM**. No es un banco de pruebas: es un experimento
  de un solo uso. **Van tres, y las tres destruidas:** 2026-08-08 (§4.12),
  2026-08-09 (§4.13) y **2026-08-12, la primera sobre la forma (c)** (§4.33).
- **Y el clon efímero exige un control que no es «la original estaba parada».**
  `utmctl clone` **no regenera la MAC**, así que el duplicado contesta en la
  misma IP y con la misma MAC que su origen: ni el `arp` ni la huella de dentro
  los distinguen. Lo que sí lo demuestra, gratis y sin encender nada, es la
  **fecha de escritura de la imagen de disco** de la original leída desde el
  anfitrión, antes y después. Si esa fecha no se ha movido, el certificado no
  entró (§4.33d).
- **Ninguna casilla puede decir «compruébalo contra el estado bueno».** No lo
  hay ni lo habrá. Puede decir «repite el experimento efímero», que es otra cosa
  y cuesta más.

---

## 10. Criterios de parada

- **E1.** Si `encina-meta` no puede declarar sus dependencias sin violar R10,
  parar: significa que `encina-firefox-native` está haciendo dos cosas y hay que
  partirlo antes de seguir. **Medido el 2026-08-08 y no dispara**
  (`MEDICIONES.md` §4.10). Y de paso se midió que **el remedio que este criterio
  prescribía no habría servido**: partir `encina-firefox-native` no compra nada,
  porque lo que impide declarar Firefox no es de quién sea el paquete, sino que
  el índice de Mozilla no está presente **cuando apt resuelve**. Un paquete
  aparte tendría el mismo problema en la misma transacción. Si el criterio vuelve
  a dispararse por otra vía, la salida es una **segunda orden** con `apt update`
  en medio, no un paquete nuevo.
- **E2. Medido el 2026-08-09, y no dispara** (`MEDICIONES.md` §4.14): el
  instalador de Ubuntu Desktop 24.04.4 arm64 **sí** honra un `autoinstall.yaml`
  con `late-commands`. Si no lo hubiera honrado, el criterio decía **no** forzarlo
  con Cubic ni con un chroot editado a mano (D4), y replantear la entrega.
  **Lo que sí apareció es un criterio nuevo, y éste sigue abierto:** sin
  `autoinstall` en la línea de órdenes del núcleo el instalador **se para a
  esperar un clic**, y esa palabra no la puede poner el seed. Las salidas son
  tres, y hay que elegir **antes** de escribir el seed de verdad:
  *(1)* aceptar que E2 se entrega con un hipervisor que pasa el parámetro
  —vale para las VMs de este proyecto y no vale para nadie más—;
  *(2)* adelantar de E3 lo justo para reempaquetar la ISO con esa palabra en su
  `grub.cfg`, y entonces E2 y E3 se solapan a propósito y se dice;
  *(3)* aflojar la casilla a «una edición manual del GRUB y nada más», que es
  volver a tener un humano dentro y **no** es lo que E2 prometía.
  **No elegir es la peor**: deja el seed escrito contra una casilla que no se
  puede cumplir.
  **El 2026-08-10 se comprobó que no hay una cuarta salida por seed, y por
  lectura del código, no por deducción** (`MEDICIONES.md` §4.16a): la puerta es
  `if "autoinstall" in self.app.kernel_cmdline` en
  `subiquity/server/controllers/install.py:587-597`, `model.confirm()` solo se
  llama desde ahí y desde el manejador HTTP del botón, y **con
  `interactive-sections` ausente el instalador ya es no interactivo y se para
  igual**. Ninguna clave del YAML toca `/proc/cmdline`. Además, la palabra hay
  que escribirla **suelta**: el analizador manda lo que lleva `=` a otro sitio,
  así que **`autoinstall=1` no vale**. *(Queda apuntada una pista no medida y no
  recomendada: `confirm_POST` es HTTP sobre el zócalo de subiquity y las
  `early-commands` corren antes. Si alguna vez se mide, §10 cambia.)*

  ---

  **DECIDIDO el 2026-08-10: la salida es la (1), el hipervisor.** Jorge delegó la
  elección. Queda escrita aquí con su motivo para que no se vuelva a discutir sin
  dato nuevo.

  **Por qué la (1).** Lo que E2 entrega es **la receta** —«la receta que se
  escriba en E2 es la definitiva; E5 la envuelve» (§6)—, y lo desatendido es su
  criterio de validación, no el producto. El hipervisor **valida exactamente
  eso**: el 2026-08-10 produjo una máquina instalada en 8 min 32 s sin que nadie
  tocara nada (§4.16). Lo que no prueba es que se la puedas dar a otra persona —y
  eso **es literalmente la definición de E3**: «se la puedes dar a alguien». O
  sea que la (1) no recorta E2: respeta la frontera entre los dos incrementos.

  **Por qué NO la (2), que era la tentadora.** Reempaquetar la ISO **es** E3, no
  «adelantar lo justo de E3». Y mete una clase de riesgo nueva —cadena de
  arranque UEFI, El Torito, `xorriso`, y la firma de `shim`/GRUB— que no tiene
  nada que ver con lo que E2 valida. Si se mezclan, **un fallo de la ISO y un
  fallo de la receta se vuelven indistinguibles**, que es cambiar dos cosas a la
  vez: lo que este proyecto prohíbe en todas las demás páginas. Y §6 ya dice
  dónde muere este tipo de proyecto.

  **Por qué NO la (3).** Vuelve a meter un humano dentro, que es lo único que E2
  existe para quitar.

  **Y lo que hace que esta elección no cueste nada más adelante:** las tres
  salidas **no cambian ni una línea del `autoinstall.yaml`**. Cambian cómo se
  entrega, no qué dice. Así que elegir la (1) hoy no compromete nada de la receta.

  **Cómo queda redactada la casilla de E2**, sin aflojarla y sin mentir: *la
  máquina se instala sin que nadie conteste ni pulse nada, con el parámetro
  `autoinstall` **puesto por el hipervisor**.* Lo de «nadie la toca» sigue intacto;
  lo que se nombra es quién pone la palabra, que la casilla anterior nunca decía.

  **La deuda que hereda E3, con nombre y apellidos:** poner esa misma palabra sin
  hipervisor. **Y hoy sale más barata de lo que parecía**, por lo leído en
  `select_autoinstall` (§4.16a): el instalador busca el seed en cinco sitios por
  orden, y el quinto es **`/cdrom/autoinstall.yaml`, «autoinstall baked into the
  iso»**. O sea que E3 no necesita el volumen `CIDATA` para nada: el seed va
  dentro de la ISO, y la palabra —**suelta**, que `autoinstall=1` no vale— en su
  `grub.cfg`. **El 2026-08-10 esa lectura se completó** (§4.21): la ruta es
  literal y `/cdrom` es el medio; el `grub.cfg` que manda es
  **`boot/grub/grub.cfg`, el único del medio**; y **el `CIDATA` va cuarto, o sea
  que le gana al seed de la ISO**, que es a la vez una propiedad del producto y
  una trampa para la medición.
- **E3. Y su criterio de apertura, contestado el mismo día que se abrió.** La
  pregunta de §10 —«¿qué comando demuestra que esto es viable?»— tenía **una
  respuesta más barata que `xorriso`**, y es la siguiente tarea: **fabricar el
  seed de E3 en un volumen `CIDATA` y arrancar la ISO oficial con él**. Eso
  contesta si el instalador de escritorio honra `interactive-sections` y si las
  `late-commands` siguen corriendo, **usando el banco de E2 tal cual y sin tocar
  la ISO**. Si esa respuesta fuera que no, E3 cambia de forma **antes** de
  reempaquetar nada, que es exactamente lo que este criterio existe para comprar.
- **E3, el criterio de parada propiamente dicho: `xorriso`.** Si reconstruir esta
  ISO conservando la ESP y El Torito no sale —o sale una imagen que arranca en el
  banco pero solo porque el banco no verifica nada—, **parar y no insistir por la
  vía de editar la imagen a mano ni con Cubic** (D4 sigue rigiendo). La salida en
  ese caso **no** es aflojar la casilla: es reconocer que la entrega necesita
  construir la imagen en vez de remasterizarla, que es E5, y decirlo.
  **Y un criterio propio, que sale de §4.21 y no existía:** E3 **no puede**
  demostrar en este banco que la ISO arranque con Secure Boot activo, porque el
  firmware de UTM no lo implementa. Eso **no** dispara el criterio de parada —es
  un límite declarado, como D9 con amd64—, pero **sí** prohíbe una cosa: tocar
  `bootaa64.efi`, `grubaa64.efi` o `mmaa64.efi`. Si alguna vez E3 pareciera
  exigirlo, ahí sí hay que parar: significaría que la ISO se está rehaciendo, no
  reempaquetando, y eso es E5.
- **E5.** Si a las dos semanas de abrir `live-build`/`debos` no hay una imagen
  que arranque, cerrarlo y quedarse en E3. E3 ya entrega el producto; E5 solo lo
  envuelve mejor. **Es donde este tipo de proyecto muere.**
- **B∥.** Si una PR entra rápido en el repositorio oficial, replantear el alcance
  del fork en lugar de continuar por inercia. Y aplicar D14: la retirada del fork
  la decide `verificar-deb.sh` sobre el `.deb` oficial, no la fecha de un merge.
- **E4. Su criterio de apertura, contestado el 2026-08-11 antes de tocar
  `encina-meta`** (`MEDICIONES.md` §4.26). La pregunta general —«¿qué comando
  demuestra que este problema existe?»— **no suprime E4**, y los comandos son
  dos: `xdg-mime query default application/vnd.oasis.opendocument.text` →
  `<NINGUNO>`, y `command -v gnome-software snap flatpak` → los tres ausentes.
  **Pero corrige de qué va E4:** el hueco grande no es *qué aplicaciones*, es que
  **la máquina no puede crecer**, y eso convierte la lista de E4 en la entrega
  entera en vez de en un punto de partida. De ahí sale D16.
  **Y el criterio de parada propiamente dicho, que sale de la misma medición:**
  si al declarar las aplicaciones alguna arrastrara `snapd` **sin que la ISO lo
  declare**, parar — no porque `snapd` esté prohibido (ya no lo está, D16), sino
  porque significaría que el conjunto entra por una vía que la definición de
  terminado no ve. Está medido que pasa: `gnome-software`, `thunderbird` y
  `thunderbird-locale-es` lo arrastran (§4.26d).
  **Un segundo criterio, del precio:** E4 se paga **por vuelta y no por
  paquete** —dos instalaciones nuevas medidas enteras, ~22 GB—, así que si la
  lista no está decidida entera, **no se abre la vuelta**. Abrirla con la lista a
  medias es pagarla N veces, que es exactamente lo que §4.19g documenta.
- **General.** Antes de abrir cualquier incremento: **¿qué comando demuestra que
  este problema existe?** Si no lo hay, el incremento es una suposición. Ha
  suprimido dos fases ya. **Y el 2026-08-11 hizo lo contrario por primera vez:
  aplicado a E4 no lo suprimió, pero cambió de qué iba.**
