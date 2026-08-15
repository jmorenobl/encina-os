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
| `MEDICIONES.md` | Lo medido, con las salidas literales | Antes de volver a investigar algo. Casi siempre ya está medido |
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
| D6 | `ID=ubuntu` intacto en `os-release` | Software de terceros comprueba ese campo; cambiarlo produce fallos inconexos durante meses |
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
| D19 | **La identidad visual, cerrada como decisión el 2026-08-15.** **Para quién:** no un usuario de Linux — una gestoría, un autónomo, un funcionario, alguien mayor con el certificado de la FNMT y un plazo que vence. Gente para la que el ordenador tiene **consecuencias legales**. **Qué transmite:** *«esto es serio y no me va a fallar»* — confianza, calma y permanencia; **no** entusiasmo, **no** modernidad, **no** personalidad. Sobria, cálida y arraigada, con sus opuestos declarados: ni llamativa, ni fría, ni genérica. **La metáfora es la encina**, y no se toca: un árbol que aguanta siglos en suelo pobre y no se muere, con la copa hecha de nodos — la red de confianza que hace posible una firma. **Y QUÉ NO DEBE PARECER, que es la mitad que se olvida, con los tres nombres: (1) no debe parecer UBUNTU** —fuera el naranja, la tipografía Ubuntu y Yaru como identidad visible; el objetivo no es que la palabra no exista, porque `ID_LIKE` y la atribución se quedan, sino **que nada en pantalla presente el producto como Ubuntu**, que es lo único comprobable—; **(2) no debe parecer macOS ni Windows**, que ya es R8, y por un motivo que va más allá de la regla: cambiar «esto es Ubuntu» por «esto es un Mac falso» no es avanzar, y el segundo ni siquiera es una base que puedas atribuir; **(3) no debe parecer un producto oficial de la ADMINISTRACIÓN** —ni rojigualda, ni escudos, ni el azul de las sedes, ni tipografías institucionales—. **La voz también es identidad:** frases cortas en indicativo que digan qué está pasando, nada de «¡Bienvenido!» ni «Preparando tu experiencia» | **Por qué es una decisión y no un documento de diseño:** el texto llevaba escrito desde el 2026-08-14 en `design/identidad.md` y `design/paleta.md`, pero **un documento de diseño se rediscute y una decisión con su motivo no**, que es justo lo que §2 existe para evitar. **El tercer «no» es el que justifica la fila él solo:** el README declara en su primera pantalla que el proyecto no tiene relación con la Administración General del Estado, la FNMT ni Canonical, y **el diseño no puede desmentir esa declaración**. Un sistema que sirve para firmar ante el Estado y que *parece* del Estado induce a error sobre quién responde si algo sale mal — es el riesgo menos evidente y el más caro, y la paleta verde-tierra ya protege de él, pero conviene que sea a propósito. **Lo que esta decisión NO cierra, y está abierto en `tareas/aspecto/0-decidir.md`:** el acento propio `#3A664E` no existe en la lista cerrada de Ubuntu, así que hoy viaja `Yaru-sage`, **un verde prestado que pasa por gris**; tenerlo exige forkear Yaru para añadir una variante. Y los colores semánticos —error, aviso, correcto y texto— están **`PROPUESTO` y no `VIGENTE`** en `design/paleta.tsv`, con su contraste calculado. **Y un fallo que salió al medirlos, que esta fila no tapa:** el acento sobre `acento-profundo` da **1,68** — el acento no se lee sobre el fondo oscuro de la propia marca, y ese par no se había medido nunca |
| D21 | **El icono del Centro de aplicaciones se sustituye SOMBREANDO SU `.desktop`, no desde el tema de iconos. Decisión de Jorge, 2026-08-15.** Un `.desktop` propio en `/usr/share/applications` con el id del snap, `Name=Centro de aplicaciones`, el mismo `Exec`, `TryExec=/snap/bin/snap-store` y `Icon=` de Encina. La aplicación sigue siendo la misma y se abre igual: cambia el cuadrado del dock y de la rejilla. **Y el criterio general, que es lo que no hay que rediscutir la próxima vez:** cuando el icono de una aplicación ajena **no es alcanzable desde el tema**, la vía es sombrear su `.desktop` — **nunca** tocar el fichero ajeno. **Entra en la vuelta de `encina-branding`, y la casilla NO se marca hasta que el icono esté dibujado y visto en pantalla** | **Porque no había otra vía, y eso está medido, no supuesto** (`MEDICIONES.md` §4.47): su `.desktop` no declara un nombre sino una **ruta absoluta dentro del snap** —`Icon=${SNAP}/…/app-center.png`, escrita por el propio snap en su `meta/gui`, idéntica en la revisión del producto (1271) y en la del banco (1391)—, así que `Gio` devuelve un `GFileIcon` y **ningún tema interviene**: ni el nuestro ni el de Ubuntu, con el control de que la misma función da el mismo fichero con los dos. Y el fichero vive en un squashfs de solo lectura que se sustituye entero en cada autorrefresco. **La forma no es nueva:** `encina-firefox-native` sombrea `firefox_firefox.desktop` desde la 0.2.1 y está medido en producción (§4.19); el árbol sintético confirma que `/usr/share` gana a `/var/lib/snapd/desktop`, con el control invertido. **R5 sigue intacta:** fichero nuestro, directorio nuestro, ningún fichero de Canonical tocado — y la objeción de fondo («repintar la aplicación de otro») está contestada con dato: **el propio Ubuntu sirve el icono de aplicaciones ajenas 62 veces de 71**. **El motivo de producto:** es lo único que queda en el escritorio con marca de Canonical a la vista, y encima donde el ojo va primero; el nombre ya no delata nada porque ellos mismos lo traducen. **El precio, sin maquillar:** seis líneas que hay que mantener —no cincuenta y cinco: la ISO fija `locale=es_ES.UTF-8` (§7.7), así que las traducciones del `Name=` no se copian, **y quien cambie el idioma del sistema verá ese nombre en español**—, más lo que Canonical añada a ese fichero y nuestra copia no recoja. Sin `TryExec` quitar la tienda dejaría un lanzador roto. **Y abre trabajo que hoy no existe: el icono hay que dibujarlo**, con la paleta todavía en `PROPUESTO`. **Qué la reabriría:** que el App Center deje de empotrar su icono y pase a declararlo por nombre, o que la tienda cambie (D18) |
| D20 | **NO se forkea Yaru. El acento del producto es `Yaru-sage`, prestado. Decisión de Jorge, 2026-08-15.** Se queda lo que ya viaja desde `encina-branding` 0.1.10: `gtk-theme='Yaru-sage'` y el tema de iconos `Encina` heredando `Yaru-sage,Yaru,hicolor`. **Y se acepta por escrito lo que cuesta:** `sage` es `#657B69`, **no** el `#3A664E` de la marca, y está tan desaturado que **pasa por gris** — o sea que hoy el producto **no tiene su acento**, tiene uno prestado que casi no se lee como decisión. **Con ella caen dos casillas de `tareas/aspecto/0-decidir.md`**: la del tema base y la de dónde vive el fork, que se queda sin objeto | **El motivo es la agilidad, y se dice tal cual en vez de disfrazarlo de criterio técnico.** La alternativa medida era forkear Yaru para añadir una variante `encina` — que **no es un rediseño**: la lista de acentos es cerrada, `#3A664E` no está en ella, y añadir uno es una diferencia de datos en un SCSS (§2 de `2-golpes-baratos.md`). Pero un fork arrastra **repositorio aparte, construcción con meson y sassc, relación de rebase con aguas arriba, oferta de fuente propia y un anclaje para que un `apt upgrade` no lo pise en silencio** — las mismas cinco cosas que `encina-autofirma`, para cambiar un color. **Lo que se compra:** cero paquetes nuevos, cero filas en el manifiesto y cero mantenimiento; los diez acentos ya viajan dentro de `yaru-theme-gtk` y `yaru-theme-icon`. **Lo que se paga, y no se maquilla:** el verde de la identidad no está en pantalla, y `design/identidad.md` sigue diciendo que la cara del producto es propia. **Qué reabriría esta decisión, que es lo que la hace revisable y no un dogma:** que Ubuntu abra el acento a un valor libre —hoy no existe la clave `accent-color` (§2 de `2-golpes-baratos.md`)—, que el fork deje de costar un repositorio porque el tema del shell obligue a uno de todas formas, o que alguien mire la pantalla y diga que el gris no pasa. **Es una decisión de compromiso tomada a sabiendas, no un descuido** |

---

## 3. Qué existe ya

| Artefacto | Estado |
|---|---|
| `encina-branding` | **Construido, instalado y probado.** v0.1.6, 10/10 de la definición de terminado en VM Ubuntu 24.04 arm64, cuatro comprobaciones miradas en pantalla. **v0.1.8 (2026-08-12, `9ec0a49d…` desde el 2026-08-13; era `51b6603c…`, §4.37)**: añade `/etc/xdg/mimeapps.list` —**nuestro**, no el conffile de nadie (R5)— que ata `application/pdf` al visor, y `Depends: evince`, porque ese fichero es una promesa sobre un lanzador concreto. `lintian` mudo. **Y la ruta no es la que parecía:** un `ubuntu-mimeapps.list` no habría servido, porque los ficheros con nombre de escritorio delante **solo se leen si el escritorio se llama así** (`MEDICIONES.md` §4.31d) |
| `encina-firefox-native` | **Construido, instalado y probado.** v0.2.1 (2026-08-10), que pone `NoDisplay=true` en la sombra y deja **un solo icono de Firefox** en las dos máquinas, con y sin Snap, sin reabrir A2 (§4.19). La definición de terminado pasa de siete casillas a nueve: las dos nuevas cuentan *cuántos* iconos hay y comprueban que ocultar no es desactivar. **Es condición necesaria del producto, y está medido por qué** (§4) |
| `autofirma 1.9.1+encina2` | **Construido, probado, y con el primer positivo de extremo a extremo del proyecto.** En `~/Projects/encina-autofirma`, anclado en `v1.9.1`, CI verde en amd64 y arm64. **`+encina2`, del 2026-08-09, cierra el defecto de `MEDICIONES.md` §4.12a**: dos unidades de systemd de usuario meten la CA del socket en el perfil de Mozilla cuando el perfil aparece, así que la secuencia de E1 vuelve a ser de tres órdenes (M14–M18 de aquel repositorio). **Y ya no es la última versión, aunque sí la que viaja en el medio de la entrega** (2026-08-12): **`+encina3`** (`2d985724…`, M19) quita el almacén NSS de root que el paquete dejaba dentro de los perfiles —eran **tres puertas**, y la tercera era desinstalar—, y **`+encina4`** (`faeca3a9…`, M20) hace que la espera del vigilante sea **por raíz**, que es lo que cierra §4.29e. **Las dos están en `main` de aquel repositorio, con la CI verde** (`d00dc92`, 2026-08-11T23:29). *(Esta celda dijo durante un rato lo contrario —«`+encina3` en `main` y la CI en rojo»— y era falso: la ejecución roja era de `56549fe`, el commit de la fusión de M19, no de la cabeza. Se corrige el 2026-08-12 y **se deja de anotar aquí un estado que cambia solo**: el estado vivo se pregunta con `gh run list --repo jmorenobl/encina-autofirma --branch main`, y lo que esta tabla fija es **qué versión viaja en el medio, por huella**.)* **Y un dato de aquel rojo que sí conviene no perder:** la CI de `56549fe` falló con `[FALLO] la CA no ha llegado sola en 30 s` en arm64 — **§4.29e apareciendo sola en el runner**, cuando el contenedor de la sesión de M19 daba 17/0 y la CI 16/1. **Una carrera que tu máquina gana no está cerrada: está sin medir** — **y el 2026-08-12 `+encina4` tiene ya su propio positivo de extremo a extremo** (§4.33): firma real en `valide.redsara.es` sobre la forma (c), con la CA llegando sola al perfil nativo en 2 s y con un Snap de Firefox delante. Lo que ese positivo **no** hace es discriminar `+encina3` de `+encina4`: eso sigue siendo M20, en contenedor |
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
| B1a | Las preferencias del esquema `afirma:` están donde la compilación de Mozilla no lee | `autofirma 1.9.1+encina2` |
| B1b | `network.protocol-handler.app` ya no existe en Firefox 153 | `autofirma 1.9.1+encina2` |
| B2 | La CA del socket va al perfil equivocado —y no va a ninguno si el perfil aún no existe | `autofirma 1.9.1+encina2`: `+encina1` acertó el perfil, `+encina2` acierta también **el momento** |
| B3 | Dentro del Snap, Firefox **no ve** el manejador de protocolo | `encina-firefox-native`, y **quitar el Snap en la imagen** |
| B4 | AutoFirma busca tu certificado en el perfil del Snap | `autofirma 1.9.1+encina2`, y quitar el Snap lo cierra solo |
| B6 | Las bibliotecas NSS no se encuentran fuera de x86 | `autofirma 1.9.1+encina2` |

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
| R8 | Ningún activo de terceros: ni marca Canonical, ni tipografía San Francisco, ni iconos que imiten macOS |
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

> ### LA TAREA EN CURSO, 2026-08-15: **[tareas/marca-del-medio.md](tareas/marca-del-medio.md)**
>
> **Que el medio y el instalador dejen de decir Ubuntu.** Son **4 casillas** —eran
> 5, y la del logotipo de la rejilla resultó ser una copia rancia de una que ya
> estaba cerrada—, y es **lo que bloquea publicar** junto con los 3,46 GB del
> alojamiento.
>
> **Por qué le toca ahora:** `aspecto/` ha cumplido su turno. El 2026-08-15 Jorge
> dio por bueno lo visual —*«como está, está bastante bien, y ya le da un toque
> personal»*— y de sus 16 abiertas quedan **5**, todas en
> [tareas/aspecto/5-cierre.md](tareas/aspecto/5-cierre.md): los bloques 0, 2, 3 y
> 4 están **cerrados enteros** y el 1 **aplazado por escrito**. No se cerraron
> construyendo nada — se cerraron **leyéndolas hasta el final**, y las pruebas ya
> estaban en el disco.
>
> **Y el orden de lo que queda, con el argumento de siempre —el precio es por
> vuelta y no por cambio—:** las dos últimas casillas de `5-cierre.md`
> —refabricar la ISO, e instalarla y mirarla— **se pagan DESPUÉS de la marca del
> medio, y una sola vez**. Refabricar ahora para meter `encina-branding` 0.1.15 y
> otra vez dentro de unos días para meter la marca es pagar dos veces la misma
> vuelta.
>
> **Lo que hay que saber antes de tocar nada, y es de hoy:**
>
> 1. **NINGUNA DE LAS TRES ISOs DE `medios/` ESTÁ AL DÍA, y son tres cosas
>    distintas** — medidas con `shasum` el 2026-08-15, no deducidas del nombre:
>
>    | Fichero | Huella | Qué es |
>    |---|---|---|
>    | `encina-os-E4-es-0.2.1.iso` | `ac0a5721…` | **La entregada de E4**, y la única de las tres que alguien ha arrancado e instalado (§4.35) |
>    | `encina-os-E4-es-0.2.1-95758c9e.iso` | `95758c9e…` | La primera que salió **reproducible** de este repositorio (§4.39). Nunca arrancada |
>    | `encina-os-E4-es-0.2.1-1224b5b1.iso` | `1224b5b1…` | **La última que produce este repositorio**, con `encina-branding` **0.1.11** dentro (§4.45). Nunca arrancada |
>
>    O sea que **`1224b5b1…` es la que ha caducado hoy**: lleva 0.1.11 y la buena
>    es **0.1.15** (`6d9fcd64…`). `95758c9e…` ya estaba superada antes.
> 2. **Se entregan dos cosas naranjas, a propósito y por escrito.** El recuadro de
>    selección de usuario de GDM y —fuera de esto— el icono de la Ayuda. El de GDM
>    **no se arregla con el acento**: el saludador es `gnome-shell`, el tema del
>    shell de Yaru **no tiene variantes**, y cambiarlo exige reempaquetar
>    `gnome-shell-theme.gresource`, que choca con **R5**. Está medido con captura
>    en [tareas/aspecto/4-arranque-y-sesion.md](tareas/aspecto/4-arranque-y-sesion.md).
> 3. **El tema de arranque de Encina no lo ha visto nadie.** En UTM la pantalla del
>    invitado está **apagada todo el arranque**. Es un límite del banco, no un
>    resultado sobre el producto, y **se levanta arrancando la ISO en una máquina
>    de verdad** — o sea en el paso «instalar desde cero y mirar».
> 4. **El Mac de 2015 es Intel y NO arranca esta ISO**, que es arm64. Lo que sí
>    hace es tumbar el motivo escrito de **D9**: ya hay con qué probar amd64, así
>    que E6 pasa de «no se puede medir» a «no es la prioridad».

**E3 TERMINADO el 2026-08-10, 9 de 9** (§4.25), y con él **la entrega existe**:
hay una ISO —`encina-os-E3-es.iso`, `02ab929d…`— que se le puede dar a alguien,
que recibe en español, y que deja una máquina de Encina OS contestando solo las
cinco pantallas que pregunta Ubuntu.

**LA MEDICIÓN DE APERTURA DE E4 ESTÁ HECHA, el 2026-08-11** (§4.26), y el
criterio general de §10 **no lo suprime: lo redefine.** Lo que le falta a la
máquina de la entrega está nombrado con su comando —ofimática, escáner y
**ninguna forma de instalar nada**—, y **el hueco grande no es qué aplicaciones,
es que la máquina no puede crecer.**

**LA VUELTA DE E4 ESTÁ DADA, el 2026-08-12** (`MEDICIONES.md` §4.31), y con ella
**Encina OS deja de ser «una máquina que firma» para ser un escritorio que
crece**: el Snap vuelve **declarado** (D16, forma (c)), están la tienda, el
escáner y el manejador del PDF (D17 y D18), viaja `autofirma 1.9.1+encina4`, y una
instalación incompleta **falla a la vista**. La máquina es `encina-E4-meta`,
instalada sola en **9 min 52 s**: `verificar-instalacion.sh --visibles 28` como root da
**48 correctas, 0 fallos, 0 avisos, 0 omitidas**. ~~La ISO es
`encina-os-E4-es.iso` (`aa1ac76a…`).~~

**LA ISO QUE SE ENTREGA ES `encina-os-E4-es-0.2.1.iso` (`ac0a5721…`) DESDE EL
2026-08-13** (`MEDICIONES.md` §4.35), y la anterior **está borrada**. `aa1ac76a…`
llevaba dentro `encina-meta` **0.2.0**, o sea que quien la instalara se encontraba
**las dos tiendas** que D18 reescrita había quitado el día antes: E4 estaba
terminado 13 de 13 y el entregable no lo reflejaba. Refabricada con el 0.2.1
dentro y **probada arrancándola**: `encina-E4-entrega` se instaló sola en 9 min con
`ESTADO=COMPLETO`, su registro dice **`REPO ELEGIDO -> /cdrom/encina-repo`** —o sea
que el repositorio salió del medio nuevo— y `verificar-instalacion.sh --visibles 27` como
root da **51 correctas, 0 fallos**. **La versión va en el nombre a propósito:** las
dos ISOs pesan **exactamente lo mismo**, así que el tamaño no las separa y la huella
sí.

**LO QUE LA VUELTA DEJÓ ABIERTO — dos de las tres cosas están cerradas el
2026-08-12** (`MEDICIONES.md` §4.32):

1. ~~**EL NÚCLEO NO VIAJA EN EL MEDIO.**~~ **LEÍDO HASTA EL FINAL, y es un LÍMITE
   DECLARADO como D9, no una deuda.** La pregunta estaba mal planteada: **no
   falta una fuente**, porque el objetivo **ya lee el medio** por `file:/cdrom`
   cuando `curtin` instala el núcleo —el registro lo enseña sirviéndole **GRUB
   entero** desde ahí—. Lo que falta es el núcleo **dentro del archivo indexado**
   del medio, y eso lo cierra la **firma de Canonical**: tocar `Packages` rompe
   `Release`, y la línea que escribe `subiquity` no lleva `[trusted=yes]`. **Y la
   clave `apt:` del seed no sirve:** sin red `subiquity` borra a propósito todas
   las partes de `sources.list.d` del objetivo. **El precio, medido y no
   estimado: 1 089 MB**, de los que 655 son `linux-firmware`, que es `Depends:`.
   **Queda una salida nombrada y NO medida** —re-firmar el `dists/` con clave
   propia, que sobrevive porque va a `trusted.gpg.d`— y **es de Jorge decidir si
   se compra**: el medio pasaría de 3,7 a ~4,7 GB, o sea fuera del DVD de una
   capa y del límite de 4 GiB de FAT32.
2. ~~**EL USUARIO VE DOS TIENDAS.**~~ **DECIDIDA Y CERRADA EL 2026-08-12/13
   (§4.34): se queda el «Centro de aplicaciones» y SALE `gnome-software`, y D18
   se reescribió entera.** El usuario ve **una** tienda, contada y mirada, con el
   control de que el contador sabe decir 2, 1 y 0; las aplicaciones visibles
   pasan de 28 a **27** y la que se fue está **nombrada**. **Y el motivo que la
   reabrió no fue el gusto:** D18 había elegido `gnome-software` **sin haber
   considerado `snap-store`**, porque el día de aquella decisión el seed aún
   purgaba `snapd` y esa tienda no existía en la máquina.
3. ~~**De la ISO de E4 falta medir dos cosas.**~~ **CERRADA, y la casilla de
   `AGENTS.md` §6quater.1 queda marcada entera.** Sobre `encina-E4-cinco`, creada
   desde cero y **sin ningún `CIDATA`**: el seed salió del **quinto sitio**
   (`CIDATA -> <no encontrado>`, `REPO ELEGIDO -> /cdrom/encina-repo`) y **las
   cinco pantallas las nombra el propio instalador** —`telemetry` da `keyboard,
   network, storage, identity, timezone`, sin `locale` ni `source`—, que es mejor
   prueba que contar capturas. **47 correctas y 2 fallos, los dos del verificador
   y corregidos con su motivo** (§4.32g).

**El banco queda en 8,3 GiB libres y 10 VMs**: se borró `encina-E4-iso` —devolvió
**10,182 GiB** medidos con `df`— y nació `encina-E4-cinco`, que hace lo mismo
**más** las dos medidas que faltaban. **Sigue sin caber otra vuelta sin limpiar
antes.**

**Y el instrumento para pilotar una VM sin ojos ya existe** (§4.32h), que es lo
que hizo abandonar §4.31m: el ratón de UTM no llega, **el teclado de `System
Events` sí**, `Ctrl+Alt` se lo queda UTM, hay que reactivar la aplicación antes de
cada envío, y se teclea **carácter a carácter con 0,2 s**.

**Tres cosas que parecían arreglos y eran del INSTRUMENTO**, y conviene tenerlas
juntas porque salieron el mismo día: el manejador del PDF (§4.26c se midió por
`ssh`, y en una sesión de escritorio ya estaba atado), el `--yaml` de
`fabricar-seed.sh` (ya estaba hecho y el documento no se había enterado) y los
nombres en inglés de §4.26f (faltaba `setlocale()`).

---

**El registro de cómo se llegó hasta aquí**, que empezaba diciendo *«la siguiente
tarea no es E4»*. Son tres cosas, en este orden, y las dos primeras costaron
mucho menos que la tercera:

1. ~~**EL AGUJERO DE RED, que es de E3 y no de E4.**~~ **LEÍDO EL 2026-08-11, y
   sale más grande de lo que decía §4.26e** (`MEDICIONES.md` §4.27). La lectura se
   hizo **en el propio medio de la entrega, sin arrancar nada**, y con el control
   de que el conjunto que se deriva de sus manifiestos reproduce la foto de
   §4.26g. Tres cosas:
   *(1)* **Purgar `snapd` se lleva el `.deb` de transición**, así que el paso 1 ya
   deja la máquina sin ningún Firefox (§4.16g, medido).
   *(2)* **Sin red no falta el navegador: falta todo Encina.** `autofirma` pide un
   JRE y `libnss3-tools`, `encina-meta` pide `hunspell-es`, y **ninguno de los tres
   viaja en el medio** —ni en el `pool/`, y el objetivo no tiene fuente `cdrom`—,
   así que apt, que es todo o nada, **no instala ni uno de los cuatro `.deb`**. La
   entrega sin red es Ubuntu sin navegador, y **peor que la Ubuntu de la que
   salió**, que al menos conservaba el Snap. Sigue siendo deducción: lo medido es
   el medio, no la máquina, y el sano y el roto están escritos en §4.27d.
   *(3)* **El defecto de fondo no es la red: es que el seed no sabía decir que
   no.** *«Nunca sale distinto de 0»* es una regla del **instrumento** —se escribió
   para no quedarse sin datos midiendo— que acabó dentro de la ISO que se entrega.
   Tercera vez que aparece un criterio de validación disfrazado de producto.
   **Hecho el mismo día, sin gastar VM (nivel 1):** el seed **comprueba lo que ha
   dejado** y escribe `/etc/encina-estado` (`COMPLETO`/`INCOMPLETO` y qué falta),
   con su control dentro; `verificar-instalacion.sh` lo lee; los dos YAML rehechos y
   comprobados por el camino de vuelta. **Lo que falta, y va en la vuelta de E4:**
   decidir si una instalación incompleta **falla a la vista** (nivel 2, es
   producto), y **que el medio lleve lo que hoy baja de internet** (nivel 3), que
   es la misma obra que decide E4. **Ninguna ISO nueva: la entrega sigue siendo
   `02ab929d…` y sigue teniendo el agujero.**
2. ~~**LA PUERTA DE LA CONVIVENCIA (c), y ya son TRES preguntas, no una.**~~
   **CONTESTADA EL 2026-08-11, las tres** (`MEDICIONES.md` §4.29), sobre un
   **duplicado** de `encina-E1-meta` que se destruyó después —devolvió 0,923 GiB
   medidos con `df`, frente a los 9,2 GB que decía `du`—. *(1)* **La CA sigue
   llegando al perfil nativo, en 1 segundo** — pero **no por el mecanismo que lo
   garantizaba**: con un perfil de Snap presente `hay_perfiles()` da verdad y el
   vigilante **se salta la espera de 90 s** de M15(F); funcionó por un flanco
   posterior de `PathChanged`, o sea por carambola. *(2)* **También la mete en el
   del Snap**, en 2 segundos y con la misma huella: es el bucle de las tres
   raíces, escrito a propósito. *(3)* **AutoFirma lee del perfil que se usó el
   último**, y la regla es simétrica a propósito (M6): con el Snap usado el
   último, el lanzador le pasa el `profiles.ini` **del Snap**, y allí no está el
   certificado de la persona. **O sea que en el estado (d) vuelve B4**, además de
   B3, y **el daño sigue al último navegador abierto**, no es permanente.
   **Y la máquina que tenía que contestarlo no llevaba el paquete:**
   `encina-E1-meta` tiene `autofirma 1.9.1+encina1`, sin vigilante — se instaló
   `+encina2` (`d5a0ebe1…`, el artefacto de §4.13) **en el duplicado**. **De
   propina salió un defecto que no es del Snap**: el paso 2 del `postinst`
   ejecuta `script.sh` **como root** y deja un almacén NSS de root dentro del
   perfil que nadie usa, con lo que **el servicio del vigilante queda en rojo en
   todas las sesiones**. Es de `encina-autofirma` y va allí, no aquí.
3. **UNA SOLA VUELTA DE E4, con todo dentro.** El precio es **por vuelta y no por
   paquete**, así que en la misma van: la convivencia (c) de D16, las
   aplicaciones decididas, la tienda que salga del punto 2, lo que salga del
   punto 1, el `--yaml` pendiente de `fabricar-seed.sh` (§6ter.4) y
   `imagen/verificar-instalacion.sh` reescrito —la casilla «Sin Snap» se sustituye y el
   control de «25 aplicaciones visibles» deja de valer 25—.
   **Y el `.deb` que tiene que viajar dentro es `autofirma 1.9.1+encina4`
   (`faeca3a9…`)**, no el `+encina2` que lleva hoy el medio: es la razón por la
   que `+encina3` y `+encina4` se hicieron **antes** de esta vuelta, porque el
   ritual de rehacer el seed son cuatro cosas y se paga **por vuelta**.
   **Cuidado al construir:** `encina-autofirma/salida/` tiene ya **tres** `.deb`
   de `autofirma` —`d5a0ebe1…`, `2d985724…`, `faeca3a9…`—, así que la trampa de
   §4.13 es peor que nunca: **se elige por ruta entera y se comprueba la huella,
   nunca con `ls -t | head -1`**.

~~**Lo que sigue pendiente de decidir, y es producto:** qué ofimática exactamente,
y qué tienda.~~ **DECIDIDO EL 2026-08-12 por Jorge, y queda UNA sola cosa: D17.**
**No hay suite ofimática ni cliente de correo** —los elige el usuario—, **no entra
Okular**, y **de serie van el visor de PDF con el manejador atado y `simple-scan`**.
Cae con ello la obligación de §4.11 de meter `libreoffice-l10n-es` y
`libreoffice-help-es`, que era consecuencia de traer LibreOffice de serie; el
residuo de D12 se queda en `hunspell-es` y los `language-pack`, que ya están.

**LA TIENDA ES EL «CENTRO DE APLICACIONES» (D18, reescrita el 2026-08-12).**
Sostiene a las otras tres (D17): sin ella, «que lo instale el usuario» no se puede
cumplir. **`gnome-software` estuvo aquí y salió**, con lo medido en §4.26d en
contra —4 paquetes y devolvía `snapd`— y con lo medido en §4.34 a favor de la que
se queda: **cuesta 0 paquetes** porque viaja pre-sembrada en el medio, **abre y
sirve en arm64** —encuentra LibreOffice y Thunderbird, mirado en pantalla— y **no
es solo de snaps**: su filtro ofrece «Paquetes snap» y «Paquetes de Debian». Las
dos vías que tampoco devolvían `snapd` —`gnome-packagekit` y `synaptic`— siguen
descartadas por lo mismo de siempre: **son gestores de paquetes, no una tienda
para un ciudadano**. **Flathub y el plugin de flatpak quedan fuera a propósito**
(D18). **Y el precio de la decisión nueva, sin maquillar: la tienda deja de estar
declarada en un `Depends:`**, porque un `.deb` no puede declarar un snap; lo que
se declara es `snapd`. **Con esto, E4 no tiene ninguna decisión de producto
pendiente.**

**Tres cosas de E4 que ya tienen su forma escrita, para no rediscutirlas en la
vuelta:**

1. **El manejador del PDF es una medición con dos mitades**, no un fichero suelto:
   `xdg-mime query default application/pdf` **antes y después**. Y tiene trampa
   conocida: **varios ficheros compiten y el `gnome-mimeapps.list` del escritorio
   gana al `mimeapps.list` genérico**, así que hay que comprobar quién gana, no
   suponerlo — y R5 prohíbe sobrescribir el conffile de otro paquete: el fichero
   que se ponga tiene que ser **nuestro**.
2. **`simple-scan` cierra el eslabón «escanear» solo hasta donde se puede medir sin
   hardware.** La casilla honrada es *«está instalado y el backend de SANE
   responde»*; *«escanea de verdad»* necesita un escáner y unos ojos. **Y hay una
   pregunta que contestar antes de darlo por cerrado:** los escáneres de red
   modernos son *driverless* (eSCL/WSD) y eso lo da `sane-airscan`, no
   `simple-scan` — hay que mirar si viaja con él o si es otra línea del
   `Depends:`.
3. **El `.deb` de AutoFirma que viaja es `faeca3a9…` (`+encina4`)**, elegido por
   **ruta entera y huella**: hay tres candidatos en `salida/`.

**Y una casilla `[OJOS]` que cuesta una captura:** si el usuario ve los nombres de
las aplicaciones en español (§4.26f).

**Lo que queda escrito abajo es cómo se llegó hasta aquí**, y se conserva porque
explica **por qué** la receta es la que es.

**El registro de cuando E3 estaba abierto**, que empezaba aquí: E1 (12 de 12) y E2 (6 de 6) están
terminados; lo que queda de esta sección es el registro de cómo se llegó, que se
conserva porque explica **por qué** la receta es la que es.

**Lo que E3 ya tiene medido el día que se abre, y no hay que volver a
preguntarlo** (`MEDICIONES.md` §4.21, las dos mediciones baratas hechas **antes
de tocar `xorriso`**):

1. **El banco de UTM no aplica Secure Boot, y no puede.** No está desactivado:
   el firmware que UTM arranca —`edk2-aarch64-code.fd`, leído de la orden de
   QEMU real, no del fichero de configuración— es un EDK II compilado sin él. No
   existen `PK`, `KEK`, `db` ni `SetupMode`, `mokutil` responde *«This system
   doesn't support Secure Boot»*, y el núcleo dice `secureboot: Secure boot
   disabled`. Todo con el control de que sí se ven las otras 32 variables EFI y
   se lee una de verdad.
2. **Pero la cadena firmada está y se recorre:** `MokListRT` y `SbatLevelRT`
   existen, y las escribe el `shim`. **De ahí sale la regla dura de E3: no se
   toca ninguno de los tres binarios firmados** (`bootaa64.efi`, `grubaa64.efi`,
   `mmaa64.efi`), porque si se rompieran **este banco no se daría cuenta**.
3. **Y de ahí sale un límite declarado, no una deuda:** E3 **no puede** demostrar
   aquí que la ISO arranque en una máquina con Secure Boot activo. Se dice, como
   D9 dice lo de amd64, y no se disfraza de casilla verde.
4. **El seed va dentro de la ISO: `/cdrom/autoinstall.yaml`.** Es el **quinto**
   sitio que mira `select_autoinstall` (`server.py:889-924`), la ruta es literal
   (`server.py:73-75`, con raíz `/` en ejecución real), y **`/cdrom` es el
   medio**, medido en el casper que viaja en esta misma ISO. **E3 no necesita el
   volumen `CIDATA` para nada.**
5. **El `CIDATA` va CUARTO, o sea que le gana al seed de la ISO.** A favor: la
   ISO de E3 sigue siendo anulable sin tocarla. En contra, y hay que escribirlo
   en la medición: **un volumen olvidado en la VM secuestraría la prueba de E3 en
   silencio**, y la instalación saldría bien midiendo el seed equivocado.
6. **Si alguna vez hiciera falta la palabra, va en `boot/grub/grub.cfg`, suelta**,
   en la línea `linux /casper/vmlinuz`. Es **el único `grub.cfg` de todo el
   medio**: la partición EFI tiene tres binarios y **cero** ficheros de
   configuración, y el GRUB firmado no lleva el menú dentro (con su control de
   que `strings` sí encuentra cosas en ese binario). **Y `md5sum.txt` cubre ese
   fichero**: quien lo edite y no lo actualice deja una ISO que arranca y que
   falla la comprobación de integridad del propio medio. **Con la forma decidida
   (punto 7), E3 no lo necesita y no lo toca.**

7. **LA FORMA DE E3, decidida el 2026-08-10: la ISO PREGUNTA, como Ubuntu**
   (`AGENTS.md` §6ter.0). Teclado, red, disco, usuario y zona horaria los elige
   quien instala —las cinco secciones van listadas por su nombre real en el
   código de esta ISO—, y el seed aporta **solo lo de Encina**. **Con dos
   excepciones deliberadas, y las dos son producto y no preferencia:**
   `source` va fijo a `ubuntu-desktop-minimal` —Encina OS **se construye sobre la
   mínima** y lo que va encima lo declara `encina-meta`, que es el eje de E4—, y
   **`locale` va fijo a `es_ES.UTF-8`**, porque el seed instala
   `firefox-l10n-es-es` sin condición y quien eligiera otro idioma se llevaría
   una máquina a medias. **El teclado sí se pregunta**, que es hardware. Por eso
   la lista es explícita y no `['*']`, que haría interactivas las dos.
   **El motivo del resto, y corrige una inercia de este documento:** lo
   desatendido era el **criterio de validación de E2, no el producto** —§10 lo
   dice—, y E3 lo había heredado como si fuera el producto; de ahí un usuario
   escrito dentro de la ISO, y de ahí la contraseña. **La contraseña no era un
   problema que resolver: era el síntoma.** Consecuencias: desaparece la
   contraseña, **desaparece la deuda del GRUB** y con ella el `md5sum.txt`, y lo
   único que queda es meter el seed dentro de la ISO. **Y quitar la identidad no
   rompe nada, leído y no supuesto:** ni `encina-seed.sh` ni `verificar-instalacion.sh`
   nombran al usuario ni usan `/home`, que es consecuencia directa de R1.
   **El precio, dicho sin maquillar:** la casilla de E2 era «nadie la toca»; la
   de E3 no puede serlo y pasa a ser «una persona contesta lo que Ubuntu
   pregunta, y nada más». Por eso **el seed de E2 se conserva tal cual**: es la
   única prueba que queda de que la receta funciona sin humano.

8. **LA FORMA ESTÁ MEDIDA ENTERA, el mismo 2026-08-10** (§4.22), con `CIDATA` y
   el banco de E2, **sin tocar `xorriso`**. El instalador de escritorio **sabe
   mezclar**: `telemetry` de la máquina instalada lista **exactamente** las cinco
   pantallas pedidas —`keyboard, network, storage, identity, timezone`— más
   `confirm, install, done`, y **no** aparecen `locale` ni `source`. La máquina
   que sale es **la de E2**: `verificar-instalacion.sh` como root da **33 correctas**, con
   el sistema en español, el usuario creado por quien instaló y sin servidor ssh.
   **Los 2 fallos son del instrumento**: el bloque 1 del verificador codifica el
   criterio de E2 —«nadie la tocó»—, que E3 no puede cumplir por diseño.

**Lo que queda por medir en E3, y ya es una sola cosa:** que `xorriso` sepa
reconstruir esta ISO conservando la ESP y El Torito, y que el seed valga desde
`/cdrom` —el quinto sitio—, que es por donde llegará cuando viaje dentro.
Colgando de eso van dos comprobaciones baratas: que el interfaz del instalador
salga en español con `locale=es_ES.UTF-8` en el `grub.cfg` (leído en
`casper-bottom/14locales`, no medido) y qué pasa si alguien conecta un `CIDATA`,
que por precedencia le ganaría.

**Lo que E2 tiene medido, y sigue valiendo entero**
(`MEDICIONES.md` §4.14 y §4.15):

1. **La ISO oficial de Ubuntu Desktop 24.04.4 arm64 honra un `autoinstall`
   mínimo** servido en un volumen etiquetado `CIDATA`, sin tocar la ISO.
2. **Las `late-commands` se ejecutan**, tanto sobre `/target/` desde el entorno
   del instalador como con `curtin in-target`, ésta como root.
3. **Y hay un precio: sin `autoinstall` en la línea de órdenes del núcleo, el
   instalador de escritorio se para a esperar un clic.** Con él, instala solo.
   Medido con su control: la misma máquina sin esa palabra estuvo 14 minutos
   viva sin escribir un byte.
4. **El repo local sin firmar funciona**: `dpkg-scanpackages` + `[trusted=yes]`,
   `apt install encina-meta` a secas, y los otros tres entran marcados
   automáticos.
5. **El Snap se puede quitar desde el seed, y por una vía concreta** (§4.16):
   `curtin in-target -- apt-get -y purge snapd` en una `late-command`. Deja el
   objetivo sin `/var/lib/snapd`, sin `/snap`, sin el lanzador y sin unidades, y
   **el escritorio sigue vivo** porque `snapd` es `Recommends` de
   `ubuntu-desktop-minimal`, no `Depends`. **La vía obvia —`snap remove`— NO
   sirve y no falla: dice `firefox eliminado` y `rc=0` mientras se lo quita al
   entorno vivo del instalador.**
6. **No hay ninguna clave del seed que quite el clic**, y eso está **leído** en
   el código que viaja dentro de la ISO, no deducido (§4.16a). O sea que la
   decisión de §10 sigue siendo entre tres salidas y no hay una cuarta gratis.

7. **La secuencia de §6.4 se traslada al seed tal cual, y con un aviso** (§4.17):
   en una máquina sin Snap el paso 3 (`full-upgrade`) **no hace nada** para
   Firefox, y el paso 4 (`apt install firefox-l10n-es-es`) **instala el navegador
   entero**, no solo el idioma. El anclaje funciona igual con el nombre libre.
   Quitar el paso 4 deja la máquina sin ningún Firefox.

**Y la decisión de forma está tomada: el parámetro `autoinstall` lo pone el
hipervisor** (2026-08-10, §10, con su motivo). No queda nada que decidir antes de
escribir el seed.

8. **El seed de verdad está escrito, versionado y medido entero** (2026-08-10,
   §4.18). Vive en `imagen/` —cinco ficheros, `AGENTS.md` §6bis.4— y produce una
   máquina completa en **menos de 10 min 48 s sin que nadie abriera su ventana**.
   Lo que faltaba por medir y era el riesgo de verdad, **hay red desde dentro del
   chroot**, y la pregunta que colgaba también está contestada: **el vigilante de
   AutoFirma mete la CA en el perfil igual en una máquina sin Snap** (§4.18l).

**E2 ESTÁ TERMINADO, 6 de 6 (2026-08-10).** La firma salió. Lo que sigue de esta
lista es el registro de cómo se llegó, y **la siguiente tarea es E3**, abierto el
mismo día y especificado en `AGENTS.md` §6ter.

9. **La sombra `.desktop` está arreglada y la casilla «Sin Snap» marcada**
   (2026-08-10, §4.19): `encina-firefox-native` **0.2.1** con `NoDisplay=true`,
   un solo icono de Firefox en los dos mundos y A2 intacto. Cambió una de las
   cuatro huellas del seed, así que el volumen se reconstruyó (`b8269e52…`) y
   **§4.18 se remidió entero** con una máquina nueva. **E2 va 5 de 6.**

10. **LA FIRMA, HECHA** (2026-08-10, §4.20d). `[OJOS]`: la hizo y la vio Jorge;
    el agente no ha visto la pantalla. Sobre un clon efímero de
    `encina-E2-0.2.1`, destruido después con control de que no queda copia del
    `.p12`. La máquina corrobora lo esencial: el navegador que firmó era
    `/usr/lib/firefox/firefox-bin` **fuera de `/snap/`**, AutoFirma se lanzó por
    `afirma://websocket` contra el **perfil nativo**, y la CA del socket estaba
    en el almacén NSS del perfil que Firefox usa de verdad, **con la misma huella
    que la del paquete en disco**.

**E3 ESTÁ ABIERTO desde el 2026-08-10**, y se especifica en `AGENTS.md` §6ter.
**Las dos deudas que heredaba se han caído el mismo día, y las dos por el mismo
motivo.** La primera era poner la palabra `autoinstall` sin hipervisor: **ya no
hace falta ponerla**, porque con la ISO preguntando hay alguien delante y el clic
de confirmación es la pantalla normal de «instalar ahora». La segunda era la
contraseña: **no había que resolverla, había que quitar su causa**, que era un
usuario escrito dentro de la ISO. `encina` sigue viva donde tiene sentido —el
seed de laboratorio, servido con `CIDATA`, débil y pública a propósito— y **no
entra en ninguna ISO**.

**Los dos iconos de Firefox y la casilla que dependía de ellos: CERRADOS el
2026-08-10** (§4.19). Eran la misma cosa vista por dos sitios, y las dos se
arreglan en `encina-firefox-native` **0.2.1**, con `NoDisplay=true` en la sombra.
**Medido en los dos mundos, y es el único estado que sirve:** deja un icono con
Snap y sin Snap, y **el identificador sigue resolviendo a `/usr/bin/firefox %u`**,
así que A2 no se reabre. Las alternativas están descartadas por medición, no por
criterio: borrar la sombra devuelve `/snap/bin/firefox %u` en la máquina con
Snap, y `Hidden=true` la deja en `NINGUNA` y mata el icono anclado del dock.

**Y la casilla no estaba floja, estaba al revés, que es peor:** pedía `NINGUNA`,
y `NINGUNA` **solo se alcanza reabriendo A2** o dejando el icono muerto. Se
corrigió con su motivo escrito —ahora pregunta que no resuelva bajo `/snap/`— y
se le añadió la condición que no tenía nadie: **cuántos iconos ve el usuario**.
Ninguna de las doce casillas contaba iconos, y por eso el defecto vivió desde A2.

Cambiar el paquete cambió una de las cuatro huellas del seed, así que se
reconstruyó el volumen y **se remidió §4.18 entero** con una instalación nueva
(`encina-E2-0.2.1`): 34 comprobaciones correctas, ningún fallo.

Lo que sigue en esta sección es el registro de E1, que se conserva porque explica
**por qué** la secuencia de instalación es la que es.

### E1 — `encina-meta` (terminado en lo que decide)

Un paquete `Architecture: all` sin ficheros propios cuyo trabajo entero es
declarar dependencias. Es pequeño a propósito y desbloquea todo lo demás: un
instalador desatendido instala **un nombre**, no tres.

Contiene:

- `Depends:` sobre `encina-branding`, `encina-firefox-native` y `autofirma`.
- El residuo de l10n que D12 le dejó: `hunspell-es`, `language-pack-es`,
  `language-pack-gnome-es` en `Depends:`; `libreoffice-l10n-es`, `hyphen-es`,
  `mythes-es`, `thunderbird-locale-es` en `Recommends:`. El motivo, con las
  salidas, en `MEDICIONES.md` §6.1.
- **Ojo con R10:** `encina-firefox-native` configura el repositorio de Mozilla,
  así que `encina-meta` no puede depender de nada que venga de ese repositorio.

**R10 medida el 2026-08-08, antes de escribir una línea** (`MEDICIONES.md`
§4.10). Tres cosas, y la segunda cambia lo que este documento prometía:

1. **E1 no se para.** `encina-meta` puede no declarar `firefox` sin dejar la
   máquina sin navegador, porque el nombre `firefox` **ya está instalado** en
   toda Ubuntu de escritorio —deb de transición al Snap— y el anclaje de
   `encina-firefox-native` lo reasigna al deb de Mozilla. No se instala: se
   sustituye. Con control negativo: sin el anclaje, apt no propone nada.
2. **«Un solo `apt install`» no era posible, y no por culpa de este paquete.** El
   cambio lo hace `apt full-upgrade` —`apt upgrade` no—, después de un
   `apt update` que no puede ocurrir dentro de la misma transacción (R3). Y el
   idioma, `firefox-l10n-es-es`, solo existe en el repositorio de Mozilla, así
   que ningún `Depends:` de Encina puede traerlo. La secuencia de tres órdenes
   está escrita en `AGENTS.md` §6.4.
3. **Declarar `firefox` no lo arreglaría: lo estropearía en silencio.** No es
   irresoluble, como se suponía: en un escritorio de fábrica lo satisface el deb
   de transición ya instalado y la máquina sigue en el Snap con apt saliendo con
   0; en una base sin Firefox, apt instala `snapd` y el Snap.

Lo que lo da por terminado: esa secuencia, ejecutada tal cual sobre una Ubuntu
24.04 arm64 limpia, deja un sistema que firma en `valide.redsara.es`, mirado en
pantalla.

**Estado el 2026-08-08: 10 de 12 casillas, y la que decide sigue abierta a
propósito.** La firma salió —«Fichero firmado correctamente», con certificado real
de la FNMT, sobre una máquina virgen instalada por la secuencia, y la VM se
destruyó después—, pero **la secuencia no bastó**, y la casilla exige que baste.
Faltaba un cuarto paso: el `postinst` de `autofirma` corre en el paso 1, cuando
Firefox nativo todavía no existe, así que no hay perfil donde instalar la CA de su
socket, y sin ella la sede dice «No es posible conectar con Autofirma». Con
`sudo dpkg-reconfigure autofirma` después de abrir Firefox una vez, funcionaba.

**Lo que cerraba E1 no era otra tarde de VM: era un disparador en
`encina-autofirma`** que instalase la CA cuando apareciera un perfil de Mozilla.

**Y eso está hecho, el 2026-08-09.** `autofirma 1.9.1+encina2` lleva dos unidades
de systemd de usuario que hacen exactamente eso, medido sobre un clon virgen con
la secuencia de tres órdenes y sin ejecutar `dpkg-reconfigure` ni una vez (M18 de
`encina-autofirma`; enmienda en `MEDICIONES.md` §4.12a). **La secuencia son otra
vez tres órdenes** y así está escrita en `AGENTS.md` §6.4.

**Y LA CASILLA QUE DECIDE ESTÁ MARCADA, el mismo 2026-08-09.** Se repitió el
experimento sobre otro clon virgen, `encina-firma-efimera`: la secuencia de tres
órdenes tal cual —29 correctas, 0 fallos, sin `dpkg-reconfigure`—, la CA del
socket llegando **sola** al perfil al abrir Firefox, el certificado importado, y
la firma **mirada en pantalla**. Salidas en `MEDICIONES.md` §4.13. La VM se
destruyó después, como manda §9.1.

**Queda una casilla de doce, y no depende de este paquete.** `apt autoremove` no
propone los tres porque entraron **por ruta** en la línea de órdenes, así que apt
los marcó manuales; medido con A/B el 2026-08-08. Se cumple sola en cuanto los
`.deb` lleguen como dependencias de un repositorio, que es lo que hace E2. **E1
está terminado para lo que E1 prometía: una máquina que firma.**

### La pregunta que se le hizo a E2 antes de abrirlo, y lo que contestó

Es la lección de A3 y de B∥, y ha vuelto a acertar: **¿qué comando demuestra que
esto es viable?** Para E2 era un `autoinstall.yaml` mínimo sobre la ISO oficial de
Ubuntu Desktop 24.04 arm64 que instalase desatendido y ejecutase una
`late-command`. **Contestada el 2026-08-09 en una tarde** (`MEDICIONES.md` §4.14),
y contestó tres cosas en vez de una:

- **Sí, el seed se honra**, y la ISO no hay que tocarla.
- **Sí, las `late-commands` corren**, las dos formas.
- **Y no, no es desatendido gratis**: falta una palabra en la línea de órdenes
  del núcleo, y ponerla en una máquina de verdad no es cosa del seed.

**De paso tumbó una premisa que este documento daba por buena** —el «antecedente»
de que la línea base se había instalado por `autoinstall`— que era falsa. Media
tarde de medición ha corregido una creencia y ha movido la frontera de un
incremento; es exactamente lo que la pregunta compra.

### Lo aprendido que sigue valiendo

- **Una comprobación que pasa no vale nada si no sabes contra qué ha pasado.**
  Cuando una dé `[OK]`, comprueba que habría dado `[FALLO]` de haber estado mal.
  Las dieciocho trampas de `SCRIPTS.md` son dieciocho formas de que esto salga caro, y
  aplican igual dentro de un `autoinstall.yaml`. **La novena salió justo aquí, al
  abrir E2:** un control necesita su propia señal de que llegó a ejecutarse.
- **Todo lo verificable sin pantalla no basta.** En A2, con las siete
  comprobaciones automáticas en verde, el icono seguía abriendo el Snap. Se vio
  mirando `about:support`, y estaba en español, así que parecía correcto.
- **Una deducción bien fundada puede acertar el mecanismo y errar la causa.**
  Pasó tres veces en un solo día (`MEDICIONES.md` §4.9, M12).
- **`git` a través del hook de `rtk` devuelve commits que no son.** Cualquier
  medición sobre git va con `/usr/bin/git` o `rtk proxy`.

---

## 8. Fuera de alcance ahora

No implementar, no preparar, no dejar «ganchos para el futuro»:

`encina-doctor` y cualquier herramienta de diagnóstico · `encina-locale-es` ·
DNIe, `opensc` y PKCS#11 como funcionalidad · repo APT **firmado** y
`encina-keyring` · `os-release` y `dpkg-divert` · `live-build`, `debos` y Cubic ·
temas de GTK o iconos · cualquier GUI · amd64.

Tres matices:

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
en `e2-medios` el `encina-meta_0.2.0_all.deb` (`85c8cc56…`), que es lo único de ella
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
| `encina-E1-meta` | **Banco de E1, y el único sitio donde se puede comprobar que algo no reabre A2**, porque es la única máquina con Snap **y** con los paquetes de Encina puestos. Clon virgen instalado por la secuencia. **Sin ningún certificado, a propósito.** Su huella de identidad: los cuatro paquetes, **`autofirma 1.9.1+encina1`** y el Snap `firefox 147.0.3-1` rev 7764. **La versión de `autofirma` es nueva en esta huella y no es un detalle** (§4.29b): faltaba, y por faltar esta fila declaró durante un día que aquí se podía contestar una pregunta sobre un paquete que la máquina no tiene | `gpu-pci` | **En uso. Fue el banco de la puerta de la convivencia (c), CONTESTADA el 2026-08-11** (§4.29) — pero **no sobre ella: sobre un duplicado**, que se destruyó al terminar. **Y salió que NO llevaba `+encina2` sino `+encina1`**, o sea que el vigilante por el que se preguntaba **no existía en esta máquina**; el `+encina2` se instaló en el duplicado. **Tampoco es virgen de Firefox**: tiene dos perfiles nativos, uno usado, y su almacén NSS estaba **vacío** —ni un `SocketAutoFirma`—. **No se borra.** Aquí se ejecutó la definición de terminado de E1, y el 2026-08-08 el experimento de la tarjeta: nació `ramfb-gl` y **se cambió** (§4.12b). **Cambiada el 2026-08-10 (§4.19e): ya NO es la máquina de §4.17h.** Lleva `encina-firefox-native` **0.2.1**, instalado sobre una sesión gráfica viva a propósito, que es como se midió la regresión de D11. El dock del usuario quedó como estaba (`dconf` vacío) y el autologin de GDM que hizo falta está revertido y verificado por huella (`ceee968c…10af`) |
| `encina-E1-vigilante` | **Donde se cerró el defecto de §4.12a.** Clon virgen instalado por la secuencia de E1 **sin el cuarto paso**, con `autofirma 1.9.1+encina2`: la CA del socket llegó sola al perfil al abrir Firefox (M18 de `encina-autofirma`). **Sin ningún certificado personal**, así que no le aplican las precauciones de §9.1 | `gpu-pci` | **Parada.** Se queda de momento: es el testigo del arreglo. **No sirve para reproducir el caso virgen otra vez** —ya tiene la CA dentro—, para eso hay que clonar de nuevo. El autologin de GDM que hizo falta quedó revertido y verificado por huella (`ceee968c…10af`) |
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
| ~~`encina-E4-meta`~~ | **FUE LA MÁQUINA DE E4, y la primera Encina OS que es un escritorio que crece.** Nace del seed `360bb894…` sobre la ISO oficial, **desatendida, en 9 min 52 s**, y **se apagó sola** —que desde el 2026-08-12 significa `ESTADO=COMPLETO`, porque el seed sale distinto de 0 si no lo está—. Verificada como root: **48 correctas, 0 fallos, 0 avisos, 0 omitidas**. Su huella de identidad: `encina-meta 0.2.0`, `encina-branding 0.1.8`, `encina-firefox-native 0.2.1`, **`autofirma 1.9.1+encina4`**, `firefox 153.0.4~build1` sin epoch, Snap `firefox_7764` **presente y nunca abierto**, y `gnome-software` + `simple-scan` dentro. IP `.15`, hostname `encina-e2-completa` —lo pone el seed, como todas—, testigo `/etc/encina-e2-testigo-seed` de las `00:55:08Z` | `gpu-pci` | **Parada. Se queda: es el banco de E4, y desde el 2026-08-12 es también EL ORIGEN DEL CLON EFÍMERO DE LA FIRMA** (§4.33) — se eligió frente a `encina-E4-cinco` porque tiene `ssh` y así los ojos se gastan solo en firmar. **No se encendió durante aquella sesión, y está medido**: su `disco.img` no se escribió ni una vez (§4.33d). **Sin certificado personal**, y **en la forma (c)**: 0 perfiles de Mozilla bajo `~/snap/`, comprobado después de crear y destruir el usuario desechable de la medición de `+encina4`. El autologin de GDM que hizo falta para el `[OJOS]` está revertido y verificado por huella (`ceee968c…`) |
| ~~`encina-E4-iso`~~ | **Fue la máquina de la ISO de E4** (`aa1ac76a…`), creada desde cero. Se usó primero para comprobar **con los ojos** que la ISO arranca y que **el instalador se ve en español**, con el control de la trampa 16 recogido antes: **0** `-append` y **dos** unidades. Después se rehízo desatendida con un `CIDATA` que lleva **solo el YAML y ningún repo**, para que el repositorio tuviera que salir de `/cdrom`. **14 min 13 s, se apagó sola**, y su registro dice `CIDATA -> /dev/vdb` **y** `REPO ELEGIDO -> /cdrom/encina-repo`. Verificada como root: **48 correctas, 0 fallos** | `gpu-pci` | **BORRADA EL 2026-08-12** (§4.32b), que era lo que §4.31ñ dejó nombrado: nació de la ISO, o sea **caché reproducible** (§9.a). **Devolvió 10,182 GiB reales**, medidos con `df` antes y después. Antes de borrarla se comprobó **por huella** que su ISO vive en `e2-medios` (`aa1ac76a…`), y salió mejor de lo escrito: **su bundle no llevaba ningún clon de la ISO dentro**, así que aquí no aplicaba la trampa 21. Su papel lo hace ahora `encina-E4-cinco`, que además mide las dos cosas que a ésta le faltaban. Su medición está escrita entera en §4.31n **BORRADA EL 2026-08-13**, con permiso de Jorge y para hacer sitio: lleva la **0.2.0**, o sea la tienda vieja, y la sustituye `encina-E4-tienda` con la 0.2.1. Nació de la ISO → **caché reproducible** (§9.a), y **devolvió 10,656 GiB reales** medidos con `df` antes y después. **Sus dos papeles estaban traspasados antes de tocarla:** el de banco de E4, a `encina-E4-tienda`; y el de **origen del clon efímero de la firma**, medido y no supuesto —la nueva es virgen de Firefox con sus dos controles—. Su medición está escrita entera en §4.31, §4.33 y §4.34 |
| `encina-E4-entrega` | **LA MÁQUINA DEL ENTREGABLE: la primera Encina OS nacida de una ISO que lleva dentro la tienda buena** (§4.35). Creada desde cero desde `encina-os-E4-es-0.2.1.iso` (`ac0a5721…`) **enlazada en duro** (`2 enlaces`), con un `CIDATA` de 128 MiB (`53479f61…`) que lleva el YAML de E2 y **NINGÚN `encina-repo` dentro**, para forzar que el repositorio salga del medio. Instalada **desatendida en 9 min**, **se apagó sola** = `ESTADO=COMPLETO`. La línea que decide, del registro que dejó ella sola: **`REPO ELEGIDO -> /cdrom/encina-repo`** y 29 ficheros copiados. Testigo de las `00:06:03Z`, MAC propia `76:CE:28:E4:72:1A`, IP `.19` | `gpu-pci` | **Parada. Es el entregable vigente.** `verificar-instalacion.sh --visibles 27` como root: **51 correctas, 0 fallos, 0 avisos, 0 omitidas**, con `encina-meta` **0.2.1** salido del medio, `gnome-software` en `unknown ok not-installed` y `snap-store` rev 1271. **Y sobre ella está el `[OJOS]` que §4.34 dejó sobre un clon:** una sola tienda **mirada en la rejilla de la instalación limpia**, con el contador sabiendo decir 2, 1 y 0. **Sin certificado personal**, forma (c), **0** perfiles de Mozilla bajo `~/snap/` con el control de los dos sentidos. **Y es también donde está medido que la tienda INSTALA** (§4.35i): lleva `libreoffice` **rev 376** puesto desde el Centro de aplicaciones, **34** aplicaciones visibles, y `verificar-instalacion.sh --visibles 34` sigue dando **51 correctas, 0 fallos** con la forma (c) intacta. Lo que lleva encima de una instalación virgen y se dice: LibreOffice y sus tres dependencias (`core24`, `gnome-46-2404`, `mesa-2404`), **el Snap de Firefox autorrefrescado solo de rev 7764 a 8753** —con las dos revisiones en disco—, `~/.config/gnome-initial-setup-done`, `~/snap/` con `snap-store` y `libreoffice`, y los índices de `apt` actualizados. El autologin de GDM se activó y se **revirtió por huella** (`ceee968c…` antes y después) |
| ~~`encina-E4-tienda`~~ | **LA MÁQUINA DE LA TIENDA, y la primera Encina OS en la que el usuario ve UNA SOLA TIENDA.** Creada desde cero, con la ISO `aa1ac76a…` enlazada en duro y un `CIDATA` nuevo (`f99324ff…`, 768 MiB) que lleva dentro `encina-meta` **0.2.1**. Instalada **desatendida en 9 min**, **se apagó sola** = `ESTADO=COMPLETO`. Su huella: `encina-meta 0.2.1`, `branding 0.1.8`, `firefox-native 0.2.1`, `autofirma 1.9.1+encina4`, **`gnome-software` en `unknown ok not-installed`** y **`snap-store` rev 1271** en `snap list`. Testigo `/etc/encina-e2-testigo-seed` de las `22:55:41Z`, IP `.18` | `gpu-pci` | **Parada. Se queda: es el banco de D18 reescrita**, y el único sitio donde está medido que `encina-meta` 0.2.1 instala solo y deja **una** tienda: `verificar-instalacion.sh --visibles 27` como root da **51 correctas, 0 fallos, 0 avisos, 0 omitidas**, con **1** icono de Firefox y **27** aplicaciones visibles que **coinciden con las declaradas por adelantado**. **Sin certificado personal**, forma (c). **Costó CUATRO instalaciones y las cuatro están escritas** (§4.34j y §4.34k): la 1ª cazó que el seed llevaba su propia lista de paquetes obligatorios, la 2ª se la comió el **Mac durmiéndose** a mitad, la 3ª aisló que **`-set discard=off` rompe la instalación**, y la 4ª es ésta. **PASA A SER CANDIDATA A BORRAR EL 2026-08-13** (§4.35m): `encina-E4-entrega` hace lo mismo por un camino mejor —nace de la ISO corregida y con el repositorio saliendo del medio—, y **su ISO (`aa1ac76a…`) ya no vive en `e2-medios`**, así que la condición de §9.a no se cumpliría: hay que decirlo antes de borrarla, no descubrirlo después. ~~**Es de Jorge decidirlo**~~ **BORRADA EL 2026-08-13** (§4.35o), con permiso de Jorge y **sabiendo que esa condición no se cumplía**. **Devolvió 11,523 GiB reales** medidos con `df` antes y después, con `du` diciendo 12 G: nació del medio, así que aquí `du` acertó. Su papel estaba traspasado **midiendo**: `encina-E4-entrega` hace lo mismo por mejor camino y encima lleva las dos casillas `[OJOS]` de §4.35. Se conservó su rastro en `e2-medios/rastro-encina-E4-tienda/` (119 KB), **y al hacerlo salió un hallazgo del banco: `debug.log` no es un registro, es un volátil** — UTM lo reescribe en cada arranque, así que el control de la trampa 16 que §4.34i cita **ya no estaba dentro**. Su medición está escrita entera en §4.34 |
| `encina-E4-cinco` | **LA MÁQUINA QUE CIERRA LA ISO DE E4, y la primera de este proyecto instalada contestando de verdad las cinco pantallas de la ISO de E4** (§4.32f). Creada desde cero, con la ISO `aa1ac76a…` enlazada **en duro** al bundle y **ningún `CIDATA`** —control de la trampa 16 antes de arrancar: **0** `-append`, `media=disk` + `media=cdrom` y nada más—. Su registro dice `CIDATA -> <no encontrado>` y `REPO ELEGIDO -> /cdrom/encina-repo`, o sea que **el seed salió del quinto sitio**, de dentro de la ISO. Su `telemetry` nombra **exactamente** las cinco: `keyboard, network, storage, identity, timezone`. Verificada como root: **47 correctas, 2 fallos**, y los dos fallos eran **del verificador**, corregidos el mismo día. Usuario `encina`, **hostname `encinacin`** —tecleado `encinacinco` y el instrumento se comió dos letras, §4.32h—, testigo de las `08:18:21Z` | `gpu-pci` | **Parada. Se queda: es el testigo de que la ISO de E4 se basta sola.** **Sin certificado personal**, forma (c). **No tiene `ssh`** —la forma de E3 no lo lleva a propósito—, así que se mide por el volumen FAT de §4.25e, que sigue conectado como segunda unidad con el verificador vigente (`1128f738…`) dentro. **Las dos últimas pantallas las contestó Jorge con la mano**, que es exactamente lo que §6ter.0 declara como la forma de E3 |
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
