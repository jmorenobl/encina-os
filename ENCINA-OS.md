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

> ### LA TAREA EN CURSO, 2026-08-23: **EL FALLO DEL INSTALADOR `amd64` NO SE REPRODUCE, Y EL RELOJ QUE LO EXPLICA ES DE UBUNTU**
>
> Todo con su control en `MEDICIONES.md` §4.65 —la predicción comprometida en el
> commit `0a5c636` **antes de arrancar ninguna VM**, el marcador en (g), el
> conteo de arranques en (h), el instrumento nuevo en (i), el registro en (j), el
> control que separa en (k) y lo medido contra lo deducido en (l)—. Los cuatro
> registros, en `design/registros/amd64-e6/`.
>
> **TRES ARRANQUES DEL MISMO BUNDLE, TRES RESULTADOS DISTINTOS:**
>
> ```
> 2026-08-22 noche  -> «Se produjo un problema ... ubuntu-desktop-bootstrap»
> 2026-08-23 02:34  -> la SESION GRAFICA se muere: «Algo salio mal»  (otro fallo)
> 2026-08-23 03:11  -> EL INSTALADOR VA: «Disposicion del teclado», en español
> ```
>
> Y el de las 03:11 **se dejó solo 5 h 33 min** —con un sueño del anfitrión de
> por medio— y seguía en la misma pantalla. **Sin manos no se cae.** Así que
> «el instalador `amd64` se cae» **no se puede escribir**: es la **octava
> atribución falsa**, y la ha parado **contar arranques** (§4.59).
>
> **YA SE PUEDE LEER EL REGISTRO DE DENTRO, que anoche no se pudo:** `Alt+F2` →
> «Ejecutar una orden» → `wget --post-file` contra un buzón del Mac, con sus tres
> controles delante (`SCRIPTS.md`, la vía nueva). **`curl` no está** en la sesión
> viva; `wget` sí. Trampas 57 y 58.
>
> **Y LO QUE EL REGISTRO NOMBRA ES UN RELOJ, no un paquete ni la capa:**
>
> ```
> INFO subiquity_server: Waiting server up to 90 seconds     <- literal, del frontal
>
>                                  reintentos   s hasta el zocalo
> ISO OFICIAL amd64 (sin Encina)       82            84,26
> NUESTRO medio amd64 (8924f148)       81            82,03
> presupuesto del frontal               -            90,00
> ```
>
> **LA OFICIAL ESTÁ PEOR QUE LA NUESTRA.** El reloj es de Ubuntu y el margen se lo
> come el **banco emulado**, con Encina y sin Encina. Ese es el control que
> §4.64(l) pedía, en una forma mejor y de **un solo arranque**: se supo al leer
> (j) que **el reloj corre antes de que el seed exista**, así que «la oficial +
> nuestro seed» ya no era el control.
>
> **Y EL CONTROL SALE POR DONDE NO SE ESPERABA, §4.65(p): LA ISO OFICIAL SE ROMPE
> IGUAL.** Con 2 CPU, la oficial `amd64` —cero líneas de Encina— dejó `plymouthd`
> **abortado con su backtrace** y acabó en «Oh no! Something has gone wrong», que
> es **la misma pantalla** que nuestro medio dio a las 02:34. El conteo va **2 de
> 4** el nuestro y **1 de 2** la oficial: **los dos fallan, y en la misma
> proporción.** Eso es el criterio 1 de §4.59 —un control conocido-bueno que
> falla— y es lo que contesta «de quién es».
>
> **Y UN MODELO TUMBADO POR EL CAMINO:** con **la mitad** de CPU el servidor
> tardó **menos** (65,83 s contra 82,03), así que esos segundos **no los manda la
> CPU del invitado**.
>
> **LO QUE FALTA, Y AHORA TIENE NOMBRE:** un arranque **roto** no se puede leer
> —`Alt+F2` no abre nada, `Alt+F1/F3/F4` no cambian de consola—. La vía apuntada y
> no pagada: editar la línea del núcleo en GRUB y añadir `console=ttyS0`, que
> levanta un `getty` en el `Serial = Ptty` que el bundle ya trae. Con eso sí se
> podría cazar el `ubuntu_bootstrap.log`.
> **Lo que sigue valiendo:** cazar un arranque que se caiga y sacarle
> el `ubuntu_bootstrap.log`. Si sus reintentos llegan a ~90 s, la hipótesis del
> reloj queda **probada**; si se cae por otra cosa, se tacha. Hasta entonces es
> deducción **con su aritmética** y así está escrita.
>
> **Y LO QUE SIGUE ES EL HIERRO, que ya tiene máquina: un portátil AMD A9 de 7ª
> generación y un pincho.** La receta, con sus controles, está abajo. Nada de la
> emulación lo sustituye: es lo único que desata `amd64` de la emulación **y** lo
> único que contesta Plymouth.

> ### LA RECETA DEL HIERRO — `amd64` en el portátil AMD A9 (7ª gen)
>
> **0. LA PREMISA, antes de grabar nada.** Lo que se graba es lo que se cree:
>
> ```
> shasum -a 256 medios/encina-os-amd64.iso        ->  8924f1484a74de93…
> ```
>
> **1. GRABAR EL PINCHO, y comprobarlo leyendo del dispositivo** —no mirando el
> diálogo del grabador—. La lectura de vuelta compara la ISO **entera**, y **su
> control negativo es gratis**: un byte de menos ya tiene que dar otra huella.
>
> ```
> diskutil list                                   # identificar el pincho, el EXTERNO
> diskutil unmountDisk /dev/diskN
> sudo dd if=medios/encina-os-amd64.iso of=/dev/rdiskN bs=4m
> sync
> N=$(stat -f %z medios/encina-os-amd64.iso)      # 6849232896
> B=$(( N/1048576 + 1 ))                          # 6532 MiB: se pasa A PROPOSITO
> sudo dd if=/dev/rdiskN bs=1m count=$B | head -c "$N"       | shasum -a 256  ->  8924f148…  [OK]
> sudo dd if=/dev/rdiskN bs=1m count=$B | head -c "$((N-1))" | shasum -a 256  ->  0ad9f99a…  <- el CONTROL:
>                                                              si diera lo mismo, la
>                                                              comprobación no compara nada
> ```
>
> `dd` lee **de más** y `head -c` corta en el byte exacto, así que la forma vale
> para cualquier ISO y no hay que rehacer la cuenta al cambiar de medio. **Las dos
> órdenes están ejecutadas contra el fichero antes de escribirlas aquí** —positivo
> `8924f148…`, control `0ad9f99a…`—, así que las dos huellas de arriba son
> medidas y no esperadas. Si se prefieren bloques exactos:
> `6 849 232 896 = 65 536 × 104 511`, o sea `bs=64k count=104511` —también
> comprobado— y su control es `count=104510`.
>
> **ENMIENDA DEL 2026-08-23, ANTES DE GRABAR NADA: LA CUENTA QUE HABÍA AQUÍ ERA
> FALSA Y HABRÍA DADO UN `[FALLO]` QUE NO ERA.** Este paso decía *«la ISO mide
> 6 849 232 896 bytes = **6 531 MiB exactos**»*, y de ahí salían `count=6531` y su
> control `count=6530`. No son exactos, y basta la división:
>
> ```
> 6 849 232 896 / 1 048 576 = 6531,9375 MiB
> 6531 MiB                  = 6 848 249 856 bytes   <- 983 040 bytes DE MENOS
> ```
>
> O sea que `count=6531` lee **960 KiB menos que la ISO**, y su huella **no puede**
> ser `8924f148…` ni con el pincho perfectamente escrito. **Y el control no habría
> avisado**: `count=6530` habría seguido diciendo «otra cosa», que es exactamente lo
> que dice cuando todo va bien. La lectura natural del resultado —*«el pincho está
> mal escrito»* o *«el `dd` se ha dejado bytes»*— habría sido una atribución falsa
> más, la novena, y sobre hierro recién estrenado, que es donde más barato sale
> creerse cualquier cosa. Se cazó **haciendo la división**, que es lo que había que
> hacer al escribirla.
>
> *Lo que se creía, dejado al lado:* que el tamaño de una ISO redondea a MiB
> enteros y que por eso `bs=1m count=<MiB>` la lee entera. Ninguna de las dos que
> hay en `medios/` lo cumple —la oficial `amd64` son 6 655 619 072 bytes, o sea
> **6347,29 MiB**—, así que la trampa no era de esta receta sino **de la forma**, y
> por eso se sustituye la forma y no el número.
>
> **2. EL CONTROL DEL ARRANQUE, y va DESPUÉS y no antes — con su motivo.**
> §4.64(b2) lo pedía delante; **si el nuestro arranca, no hace falta**: un
> positivo no necesita el negativo. **Sólo si el nuestro NO arranca** se graba
> `medios/ubuntu-24.04.4-desktop-amd64.iso` `3a4c9877…` **en el mismo pincho y el
> mismo portátil**, y hasta entonces **no se escribe nada**: sin ese control, un
> «no arranca» no distingue el medio de un arranque seguro activado, de un pincho
> mal escrito o de la máquina. Por eso esa ISO **no se ha borrado**.
>
> **3. EN LA BIOS: arranque UEFI, no *legacy*/CSM.** Motivo medido: la ESP es
> **byte a byte la oficial** y la cadena firmada está intacta, así que el arranque
> seguro debería pasar. El **BIOS heredado** tiene una pregunta abierta que nadie
> ha contestado —el `pvd_lba` que pasa de 16 a 64 en el `eltorito.img`,
> §4.64(j)—, así que si se prueba en ese modo, se prueba **sabiendo** que es
> terreno sin medir.
>
> **4. QUÉ MIRAR, en orden, y qué es `[OJOS]` de verdad:**
>
> | | qué | qué significa |
> |---|---|---|
> | a | el menú de GRUB dice **«Probar o instalar Encina OS»** | la marca del medio viaja |
> | b | **el *splash* del MEDIO dirá «Ubuntu»** | **NO ES UN FALLO.** Está declarado en **D23**: `watermark.png` y `bgrt-fallback.png` viven en el `initrd`, **antes de que exista ninguna capa**. La capa de marca no puede llegar ahí |
> | c | sesión viva: fondo de Encina y «ENCINA OS / Versión 24.04 LTS / Edición ‘La Mancha’» | ya medido en emulación |
> | d | el instalador en **español**, cinco pantallas | ya medido en emulación |
> | e | **CON RED:** que termine, y dentro `sudo ./imagen/verificar-instalacion.sh --forma e3 --visibles 27` | el positivo de extremo a extremo en `amd64` |
> | f | **el *splash* de la MÁQUINA INSTALADA: ahí sí tiene que salir la encina** | **ESTE es el `[OJOS]` de Plymouth**, y no el del medio. Lo pone `encina-branding`: registra `default.plymouth` con prioridad 200 y corre `update-initramfs -u` (R7), y el tema es `ModuleName=script`, **no `bgrt`** (R6) |
> | f | | **COBRADO EL 2026-08-23 en el Acer Aspire ES1-524 (AMD A9), con foto** (§4.70a). Y dos cosas que el hierro enseñó el mismo día y ninguna VM había enseñado: **el segundo arranque se queda en negro tras Plymouth**, y **no es de Encina** —el saludador toma tty1 y no presenta; `sudo systemctl restart gdm` lo resuelve; frecuencia y registro `[OMIT]`, §4.70b—, y **el modo oscuro de Ajustes se lleva la bellota del dock** (§4.70c), que sí es de producto y tiene casilla en `tareas/aspecto/5-cierre.md`. Las filas **a, d, e, g** siguen sin desglosar — **y la e PASÓ esa misma noche por `ssh` (§4.70e): 61/1/1/0, el `[FALLO]` es que Jorge volvió atrás en el instalador y el `[AVISO]` es `firmware-updater`, que amd64 siembra: en amd64 son `--visibles 28`**. Quedan a y d como `[OJOS]` y g sin hacer |
> | f | | **EL NEGRO, CAZADO LA MISMA NOCHE POR `ssh` (§4.70b, enmienda): NO era carrera ni azar, era 0 de 5.** `amdgpu` no va en el initrd (diseño de Ubuntu), tarda **17 s** en cargar en ese A9, y mutter 46.2 se rompe al pasar de `simpledrm` a `amdgpu` en caliente. **Remedio en el hierro, 3 de 3, y de los tres medidos el que no nombra hardware (§4.70f):** `/etc/systemd/system/gdm.service.d/encina-espera-gpu.conf` con `[Unit]`, `Wants=systemd-udev-settle.service`, `After=systemd-udev-settle.service`. Si el portátil de prueba es AMD, hazlo **antes** de juzgar nada de la sesión; y si no se hace, un [FALLO] del segundo arranque es de esto y no del medio |
> | g | **SIN RED:** repetir | si se cae, **el sitio donde mirar ya está escrito**: `curthooks`, §4.63(t). Sería el **límite declarado del producto**, no un fallo del portátil |

> ### EL ORDEN DE TODO LO QUE QUEDA, decidido por Jorge el 2026-08-23: **PUBLICAR ES LO ÚLTIMO**
>
> Tres fases, y no se solapan. El desarrollo detallado, en `TAREAS.md`, «El orden
> cambia el 2026-08-23» —donde queda **dejado al lado** el orden anterior, que
> ponía publicar antes de la refactorización y no era falso, sólo protegía otra
> cosa—.
>
> ```
> 1.  QUE LAS ISOs FUNCIONEN DE VERDAD   <- AQUI ESTAMOS
>       a) el hierro amd64: la receta de arriba, en el portatil AMD A9
>       b) la vuelta unica arm64: branding 0.1.15, dos pasadas, instalar y MIRAR
> 2.  LA REFACTORIZACION ENTERA          tareas/refactorizacion.md, 12 tareas
>       se ADELANTA a publicar, y sin la excepcion de las cinco
>       la 1 (bancos/enlaces.sh) y la 12 (que es «profesional», escrito) van delante
> 3.  PUBLICAR                           alojamiento.md + publicar.md
> ```
>
> **El motivo, en una frase:** publicar es **el único acto de este proyecto que no
> se puede deshacer** —una release tiene URL, se descarga y activa las dos
> obligaciones que §2 midió—, y un acto irreversible va detrás de los reversibles.
> Todo lo demás se rehace en el disco de Jorge sin que nadie se entere.
>
> **Y lo que eso obliga a decir ahora, para que no se dé por sabido luego:** la
> huella que se publique **no será ninguna de las de hoy**. La fase 2 toca
> `imagen/fabricar-iso.sh`, así que el medio se refabrica una última vez en la
> fase 3 con los guiones ya definitivos. **Nadie paga dos veces:** esa vuelta ya
> estaba debida por E6 y por `encina-branding` 0.1.15.

> ### LA TAREA EN CURSO, 2026-08-22 (noche): **HAY UN MEDIO `amd64` Y ARRANCA CON LA MARCA. EL INSTALADOR SE CAE, Y NO SE SABE DE QUIÉN ES**
>
> Todo con su control en `MEDICIONES.md` §4.64 —la predicción en (a)-(f), el
> marcador en (g), los hallazgos en (h)-(k) y lo que hay en (l)—. Las tres
> capturas, en `design/capturas/amd64-e6/`.
>
> ```
> medios/encina-os-amd64.iso   8924f1484a74de93…   6,38 GiB
> fabricar-iso.sh: 49 correctas, 0 fallos
> y el arm64 rehecho TRES veces: cd84d2ec… BYTE A BYTE las tres
> ```
>
> **LO QUE FUNCIONA, MEDIDO:** el medio arranca en un x86_64 emulado, sale el
> **fondo de Encina**, el reloj dice **«22 de ago»** —el `locale` se aplicó en
> las **dos** líneas de núcleo que la `amd64` tiene— y detrás del error hay una
> **sesión viva de Encina OS entera**, con su lanzador. O sea que **la capa de
> marca (D23) se monta en `amd64` igual que en `arm64`**.
>
> **LO QUE NO:** «Se produjo un problema … `ubuntu-desktop-bootstrap`».
>
> **Y DE QUIÉN ES ESE FALLO NO SE SABE. El control que hay NO lo separa**, y eso
> se dice antes de que alguien lo dé por sabido: la ISO oficial `amd64` sí llegó
> al instalador —en inglés, en 286 s— pero **se quedó en la primera pantalla
> porque no lleva `autoinstall.yaml`**, así que nunca recorrió el camino donde
> el nuestro se cae. **Lo siguiente son los tres controles de §4.64(l)**, en ese
> orden: (1) la ISO oficial `amd64` + NUESTRO seed en forma E2; (2) el medio
> `arm64` `cd84d2ec…` en un bundle igual, que ya se sabe que instala; (3) el
> registro de dentro.
>
> **LO QUE SÍ SE DESCARTA, y está medido:** que falte un `.deb`.
> `banco-autosuficiencia.sh --arq amd64` da `25 de 25` diciendo `localhost`.
>
> **DOS COSAS ESCRITAS QUE CADUCAN HOY:**
>
> - **NO hace falta un constructor `amd64`** (§4.64 P2), y `tareas/despues-de-publicar.md`
>   decía que sí. Los cuatro `.deb` son `_all`, `dpkg-scanpackages` indexó los 29
>   en la VM `arm64` y `apt-get -s` resolvió **394 paquetes** para `amd64` desde
>   ella, con su control. El portátil hace falta para **arrancar**, no para
>   fabricar.
> - **La ISO oficial `amd64` pesa 6,20 GiB contra 3,30 de la `arm64`.** Para
>   `alojamiento.md` eso no es un grado más del mismo problema: la entrega pasa
>   de 3,46 GB a ~6,4 GB **y hay que publicar dos**.
>
> **Y UN VERDE FALSO CAZADO, que valía para las dos arquitecturas:** las tres
> huellas de la cadena firmada salían `e3b0c442…` —la de la **cadena vacía**—
> porque la `amd64` llama `EFI/boot` a lo que la `arm64` llama `efi/boot`. Un
> medio con la cadena de arranque destrozada **habría pasado** esa comprobación
> y la de después. Trampas 52-56 de `SCRIPTS.md`.

> ### LA TAREA EN CURSO, 2026-08-22: **LA INSTALACIÓN OCURRE — Y SALE SIN NINGÚN PAQUETE DE ENCINA. Falta UN `.deb` en el medio**
>
> **La última casilla del incremento por fin se pagó**, y encontró exactamente lo
> que existía para encontrar (`MEDICIONES.md` §4.61). El medio `p10-capa` arrancó,
> el instalador salió en español, **Jorge contestó las cinco pantallas**, la
> instalación terminó y la máquina **arranca de su disco, 2 de 2**. Lo que
> bloqueaba desde el 2026-08-17 —«no hay instalación»— **está resuelto**.
>
> ```
> verificar-instalacion.sh --forma e3 --visibles 27, como root:
> [OK] 41   [FALLO] 20   [AVISO] 1   [OMIT] 0
>
> dpkg -l encina-branding encina-meta encina-firefox-native autofirma
>   no se ha encontrado ningun paquete que corresponda con ...  (los CUATRO)
> ```
>
> **Y el síntoma se vio en la PRIMERA pantalla, antes de entrar: el logotipo de
> GDM es el de Ubuntu**, donde `design/capturas/despues/03-gdm.png` tiene la
> encina. Repetido en los dos arranques.
>
> **LA CAUSA, MEDIDA, CON NOMBRE Y VERSIÓN — y es UN paquete:**
>
> ```
> Inst libnss3 [2:3.98-1build1] (2:3.98-1ubuntu0.2 Ubuntu:24.04/noble-updates ...)
>       ^ la UNICA de las 22 lineas de la simulacion que NO dice «localhost»
> E: Failed to fetch .../libnss3_3.98-1ubuntu0.2_arm64.deb
>    Temporary failure resolving 'ports.ubuntu.com'
> ```
>
> `imagen/repo-manifiesto.tsv` lleva **`libnss3-tools 2:3.98-1ubuntu0.2`** y **no
> lleva `libnss3`**; el `-tools` exige a su hermano en esa misma versión, así que
> `apt install encina-meta` tiene que salir a la red — **y en el `chroot` de
> `curtin` no hay DNS**, que es lo normal y **el propio seed lo mide en su paso
> 7**. Un solo `.deb` que no se puede traer **aborta la transacción entera**.
>
> **Lo que esto destapa es más grande que un `.deb`: el medio NO es
> autosuficiente, y nadie lo sabía porque nadie había instalado sin red.** El
> concepto está bien —el medio lleva su `/encina-repo` para no necesitarla—; la
> **lista** tiene un hueco. *No es regresión de un cambio nuestro: es deriva del
> archivo de Ubuntu, que se mueve mientras el manifiesto no.*
>
> **DE PASO, DOS CASILLAS QUE SÍ SE CIERRAN:**
>
> - **`[OMIT]` P5, cerrado.** El título de la ventana del instalador dice
>   **«Encina OS»**, leído con `xwininfo` dentro de la sesión viva y con otra
>   ventana como control. Las capturas no lo enseñaban porque pintan el título de
>   la **página**.
> - **El instalador NO se recorre sólo con teclado**, medido con su control
>   delante: las teclas llegan, pero `Tab` cicla entre dos paradas y nunca toca
>   «Siguiente»; `Intro` abre «Detectar». **Es un límite del banco, no del
>   producto**, y por eso las cinco pantallas las contestó Jorge.
>
> **Y EL BANCO SE LLEVA DOS CORRECCIONES, las dos tumbando algo que se creía:**
>
> - **La trampa 45 estaba mal explicada.** «Se destrabó con `open -a UTM`» es
>   falso: los informes de caída de macOS enseñan que **el UTM sordo segfaltea** y
>   arranca otro (`pid 35881` a las 16:34 del 21 — el que la trampa daba por «vivo
>   todo el rato» — y `pid 47537` a las 00:16 del 22, **38 s antes** del arranque
>   bueno). Habría sido la **sexta** atribución falsa. Y deja un **candidato
>   post-hoc** para el 33 % de §4.59.
> - **El tamaño de `debug.log` no separa nada.** El arranque que instaló el
>   sistema entero lo dejó en **2 727 bytes** —donde se creía que eso era «VM
>   colgada»—. Trampa 47.
>
> **Y HAY UNA TERCERA CORRECCIÓN, QUE ES LA MÁS GRAVE DEL DÍA: LA RED DE
> SEGURIDAD NO EXISTE.** El seed acaba en `[ "$ESTADO" = COMPLETO ] || exit 1`,
> con veinte líneas leídas en el código de `subiquity` que explican por qué eso
> tiene que enseñar «An error occurred during installation»… y la línea que lo
> invoca en `imagen/autoinstall.yaml` acaba en **`; true`**, que **se traga el
> código de salida**. Por eso una máquina **sin ningún paquete de Encina** se
> entregó diciendo *«listo para usarse»*. Con la red puesta, el hueco del repo se
> habría cazado en el minuto uno.
>
> ---
>
> ### AL DÍA, 2026-08-22 (tarde): **LOS DOS ARREGLOS Y LA GUARDA, HECHOS. FALTA LA PANTALLA**
>
> Los detalles y el marcador, en `MEDICIONES.md` §4.62. Lo hecho:
>
> - **El `; true`, fuera** de `imagen/fabricar-seed.sh` y de los dos `yaml`. Y la
>   **otra mitad, que no estaba en la lista:** `fabricar-iso.sh` comparaba sólo el
>   trozo del `base64` y **no la cola**, así que no habría visto volver el
>   `; true`. Ahora compara la línea entera, **medido con su control**: sobre un
>   `yaml` con la cola devuelta, la comprobación vieja **da `[OK]`** y la nueva lo
>   rechaza.
> - **`libnss3` al manifiesto** (28 → 29), cosecha rehecha, `29 de 29` cuadran. De
>   paso, el número de `.deb` **sale del manifiesto** y ya no está escrito a mano
>   en `construir-todo.sh`.
> - **La guarda existe y funciona: `imagen/banco-autosuficiencia.sh`.** Corre en
>   **segundos sin arrancar nada** y, desde fuera, saca **la misma línea** que el
>   `seed.log` escribió dentro de la máquina de anoche. Su control quita
>   `simple-scan` del índice y lo señala.
> - **Los dos medios, fabricados:** `…control-sin-libnss3.iso` `19587dd4…` (el del
>   punto 0, con el repo **todavía roto** a propósito) y `…libnss3.iso`
>   `cd84d2ec…`.
>
> **Y DOS COSAS QUE TUMBAN LO QUE SE CREÍA:**
>
> - **`libnss3` ERA el único hueco**, y se predijo que no. Medido sobre las
>   **tres** transacciones que el seed hace contra el repo, no sólo la primera.
>   No hay una familia de `.deb` partidos: hay **un archivo que se mueve**.
> - **La guarda salió CIEGA dos veces**, y no por donde se había escrito. No era
>   el `dpkg status` del constructor: eran **las listas de `apt`**. Con las
>   cacheadas en el squashfs, `apt` dice `0 not upgraded` y **no pide `libnss3`**;
>   la instalación de verdad decía `356`. **El instalador refresca las listas por
>   la red de la sesión viva**, así que la respuesta *depende del día* — que es la
>   deriva del archivo, vista por dentro.
> - **`full-upgrade` NO puede ser autosuficiente y no debe serlo.** También murió
>   anoche (`rc=100`), y meter `libnss3` no lo arregla **ni tiene que**: querría
>   los ~360 paquetes que el archivo ha movido. El bloque 11bis del seed existe
>   para eso. Por eso la guarda no se lo exige.
>
> **Y LAS DOS INSTALACIONES DE LA NOCHE, QUE TUMBAN MÁS DE LO QUE CIERRAN**
> (§4.62 (n) y (p)). Ninguna de las dos pagó la casilla, y las dos midieron algo:
>
> - **Con red: la máquina salió COMPLETA con el medio de 28.** `ENCINA_ESTADO=COMPLETO`,
>   `ENCINA_FALTA` vacío. **Porque esa vez SÍ había DNS en el `chroot`**
>   (`rc=0`, con su control). O sea que **el fallo de §4.61 es INTERMITENTE**: el
>   mismo medio entrega una máquina entera una noche y una sin ningún paquete de
>   Encina la siguiente, **diciendo «listo para usarse» las dos veces**. Se cae
>   con ello una frase que este proyecto daba por establecida —*«en el `chroot` no
>   hay DNS, y eso es lo normal»*—, que está en §4.61, aquí y en el propio seed.
> - **Sin red: se cayó `curtin` en `curthooks`, ANTES de la `late-command`.** Salió
>   «Se produjo un problema» —y hay captura, la primera de esa pantalla en forma
>   E3— pero **no es nuestro `exit 1`**: el seed no dejó ni estado ni registro y
>   `subiquity` no lo nombra. **No cuenta como control.** Lo impidió el haber
>   escrito que `ENCINA_ESTADO` va delante de la pantalla.
>
> **ASÍ QUE LA RED DE SEGURIDAD SIGUE SIN EJERCITARSE**, y ahora se sabe por qué es
> difícil: el fallo de §4.61 necesita **red en la sesión viva y sin DNS en el
> `chroot`** a la vez, que es un estado que ocurrió solo y que no se sabe forzar.
>
> **LO QUE FALTA, EN ESTE ORDEN:**
>
> 1. **LA RED DE SEGURIDAD, POR SABOTAJE Y NO POR `libnss3`.** La pregunta no es
>    sobre el repo: es sobre el instrumento —*¿una `late-command` que sale distinto
>    de cero enseña la pantalla?*—. Se contesta **con red puesta** (para que
>    `curtin` termine) y con **un seed que salga 1 a propósito**. Y **se puede
>    hacer con el seed desatendido**, o sea **sin manos**: es una medición del
>    instrumento, no la casilla, así que la forma E2 no estorba aquí.
> 2. **Instalar el medio bueno** (`cd84d2ec…`, ya fabricado) y pasar el verificador
>    buscando **0 fallos**. Esto **no** está bloqueado por lo anterior: lo que la
>    red de seguridad protege son las entregas futuras, no la validez de ésta, y
>    para «¿se instala sin red?» ya está `banco-autosuficiencia.sh`.
> 3. **Y ENTONCES** —y no antes— los `[OJOS]` de Jorge y la foto del «después».
>    Siguen **bloqueados**: sin `encina-branding` sería una captura que miente.
>
> ---
>
> ### AL DÍA, 2026-08-22 (mañana): **LA RED DE SEGURIDAD FUNCIONA. Ejercitada por sabotaje, con su control delante**
>
> El detalle en `MEDICIONES.md` §4.63, con la predicción escrita **antes** en
> `81568ca`. **Aciertos 6 de 6.**
>
> **LO QUE SE DEMUESTRA, y es la casilla que llevaba desde el 20 sin poder
> pagarse:** un seed que sale distinto de cero **para la instalación y lo
> enseña**. Sobre una **copia** del seed —nunca sobre `imagen/encina-seed.sh`—
> con la última línea cambiada a `exit 1` incondicional:
>
> ```
> CONTROL   (seed sin sabotear)   el seed acaba 09:33:03Z -> SE APAGA SOLA 09:33:18Z
> SABOTAJE  (una linea distinta)  el seed acaba 09:53:57Z -> SIGUE ENCENDIDA a las 10:00
>                                 y en la pantalla: «Se produjo un problema»
> ```
>
> **Y lo que lo convierte en medición y no en susto: la máquina del sabotaje está
> COMPLETA.** `ENCINA_ESTADO=COMPLETO`, `ENCINA_FALTA` vacío, los cuatro paquetes
> dentro, `curtin` terminado. No falta un `.deb`, no falla el repo, no hace falta
> DNS: **la única diferencia con el control es el código de salida**. Los dos
> registros del seed son el mismo trabajo —**14 líneas distintas de 1906**—.
>
> Y **arranca de su disco después de la pantalla**, con GDM en español y **el
> logotipo de la encina**: la consecuencia 2 del comentario del propio seed, que
> hasta hoy sólo estaba **leída en el código**.
>
> **LO QUE NO DEMUESTRA, y se dice:** está medido **en forma E2**. Que la pantalla
> salga igual en **forma E3** sigue siendo una **deducción** —`server.py:487,513`
> pone `ERROR` en las dos formas, y las 23 capas `squashfs` de la ISO oficial y
> del medio de Encina son **idénticas byte a byte**, medido con su control—. Y
> **E3 de las premisas** (que `subiquity` nombre a `encina-seed` en su registro)
> quedó **NO MEDIDO**: ese registro vive en la sesión viva y no se copia al
> objetivo si no hay final bueno.
>
> **DOS COSAS MÁS QUE SE LLEVA LA VUELTA:**
>
> - **El control hizo su trabajo y cazó un fallo del banco** antes de gastar el
>   sabotaje: **dos discos `virtio` del mismo bundle anuncian el MISMO `serial`**
>   —UTM lo saca de los 20 primeros dígitos del `Identifier`, y los nuestros sólo
>   se diferencian en el último—, y con eso el instalador **borró la cabecera del
>   volumen del seed a los 64 s**. Trampa 49.
> - **Un instrumento nuevo que quita manos: el registro de una instalación se lee
>   en los BYTES de `disco.img`, desde el Mac.** Las 1906 líneas del `seed.log`,
>   el estado y los testigos, sin entrar en la máquina y sin canal FAT. Trampa 50.
>   *Para **ejecutar** dentro —el verificador— el canal sigue haciendo falta.*
>
> **Y ESO YA ESTÁ PAGADO, EL MISMO DÍA:** el medio bueno `cd84d2ec…` instalado en
> forma E3 con las cinco pantallas contestadas a mano, el canal FAT conectado
> **después** (trampa 20), y el verificador dentro como root:
>
> ```
> [OK] 63   [FALLO] 0   [AVISO] 0   [OMIT] 0        <- §4.61 daba 41 y 20
> encina-meta 0.2.1  encina-branding 0.1.15  encina-firefox-native 0.2.1  autofirma 1.9.1+encina4
> ENCINA_ESTADO=COMPLETO   ENCINA_FALTA= (vacio)   REPO ELEGIDO -> /cdrom/encina-repo
> ```
>
> El síntoma de §4.61 —**el logotipo de GDM era el de Ubuntu**— ya no está: la
> máquina arranca de su disco con la encina.
>
> **El único `[FALLO]` de la primera pasada era del INSTRUMENTO**, y llevaba ocho
> días sin ejecutarse nunca: el bloque 8.5 sólo aceptaba iconos de
> `/usr/share/icons/Yaru/`, y **nuestro propio `index.theme` pide
> `Inherits=Yaru-sage,Yaru,hicolor`**, con Yaru-sage el primero. Los dos se
> escribieron **el mismo día** —`1d24ac2` y `c675c5d`, 2026-08-14— contradiciéndose,
> y en `MEDICIONES.md` no aparece ni un `[OK]` ni un `[FALLO]` de esa línea.
> Corregido **con control nuevo**, porque ensanchar una lista blanca es fácil de
> ensanchar de más (§4.63q).
>
> **Y LOS `[OJOS]` TAMBIÉN, EL MISMO DÍA (§4.63s).** Las seis capturas salen de la
> **máquina de la entrega** —no del banco— y **con el control de dos pasadas**:
>
> ```
> 01 firmware   1 fotograma en las dos  -> TRANSITORIA, no es una pantalla
> 02 apagada    sha256 6c8d7117… IDENTICO byte a byte
> 03 GDM        sha256 76c97e89… IDENTICO; 400 px, todos en la franja del reloj
> ```
>
> **Jorge aprobó cinco.** El **recuadro naranja de GDM** queda **aceptado como mal
> menor** —deja de ser casilla y pasa a ser decisión escrita—. Y el par «antes /
> después» de la primera sesión ya sale en el README: «Le damos la bienvenida a
> **Ubuntu**» contra el escritorio de **Encina OS** entrando directo. De paso cayó
> una frase vieja del README que decía que *el medio todavía lleva marca de
> Ubuntu*.
>
> ### LO ÚNICO QUE QUEDA DEL BLOQUE, Y NO SE PUEDE PAGAR AQUÍ: **PLYMOUTH**
>
> Del segundo 8 al 21 la pantalla está **apagada** y el tema de arranque **no se
> ve**. **Las dos hipótesis producen la misma captura:** si es de UTM, el producto
> está bien; si es del producto, **el arranque de Encina OS es más feo que el de
> Ubuntu, no más bonito**. Aquí no se separan.
>
> **Condición de salida, y es una sola: instalar en hierro.** Hasta entonces
> `02-pantalla-apagada.png` **no cuenta ni a favor ni en contra**, y la casilla
> «Instalar desde cero y mirar la pantalla» **se queda sin marcar a propósito**,
> con las otras dos terceras partes de su condición pagadas y medidas.
>
> ---
>
> ### LA TAREA SIGUIENTE, 2026-08-22 (cierre): **`amd64` (E6), Y NO PUBLICAR TODAVÍA**
>
> **Esto cambia el orden que tenía escrito este documento hace tres horas, y lo
> cambia un dato de Jorge, no una opinión:** el portátil donde puede instalar en
> hierro **es Intel/AMD**. Y el medio que existe es **`arm64` puro** —`bootaa64.efi`,
> `Volume Id: EncinaOS 0.2.1 arm64`—, **así que en ese portátil no arranca**.
>
> Las consecuencias, en cadena:
>
> 1. **Plymouth no se puede contestar sin `amd64`.** Su única condición de salida
>    es el hierro, y el hierro que hay es Intel.
> 2. **`tareas/despues-de-publicar.md` dice de E6: *«No es prioridad. Necesita con
>    qué probarlo»*. Esa razón ha CADUCADO** — ya hay con qué probarlo. Una
>    despriorización escrita cuyo motivo se cae **se revisa, no se hereda**.
> 3. **Publicar primero sería publicar algo que su propio autor no puede probar en
>    su máquina.** No está prohibido, pero hay que decidirlo a sabiendas.
>
> **LO QUE CUESTA E6, MEDIDO ESTA NOCHE Y NO ESTIMADO — y es menos de lo que
> parecía:**
>
> ```
> los CUATRO paquetes de Encina son _all.deb   -> NO HAY QUE RECONSTRUIRLOS
>     autofirma_1.9.1+encina4_all   encina-branding_0.1.15_all
>     encina-firefox-native_0.2.1_all   encina-meta_0.2.1_all
> el repo offline: 29 .deb = 14 _all + 15 _arm64  -> hay que cosechar QUINCE para amd64
> fabricar-iso.sh nombra la arquitectura en 14 lineas (bootaa64/grubaa64/mmaa64 -> x64)
> en todos los guiones: 29 lineas
> ```
>
> Falta además la ISO base `amd64` y **un constructor `amd64`** —el actual es una
> VM arm64—, que puede ser el propio portátil.
>
> **Y UN RIESGO QUE HAY QUE NOMBRAR ANTES DE TOCAR HIERRO, y que en una VM nunca
> importó:** `tareas/despues-de-publicar.md` declara que **la instalación exige
> red** y que meter el núcleo y `linux-firmware` en el medio cuesta **1 089 MB**,
> de los cuales `linux-firmware` son **655**. En una máquina virtual eso no se
> nota; **en un portátil de verdad es el WiFi**. No está medido aquí — está
> declarado allí—, y conviene medirlo antes de dar por fallida una instalación en
> hierro por un motivo que no sea el producto.
>
> *Lo que bloquea publicar sigue donde estaba* —[tareas/alojamiento.md](tareas/alojamiento.md),
> 3,46 GB que no caben en un release de GitHub, y [tareas/publicar.md](tareas/publicar.md)—,
> **pero deja de ser lo siguiente.**
>
> **Disco:** 26,3 GiB. La VM `encina-control-sinred` (8,2 GiB) lleva la
> instalación reventada de `curthooks` y **ya no hace falta**: es la única que
> sobra, y borrarla es de Jorge.
>
> **Y una consecuencia que ya está escrita donde estaba citada:** `59bc3a3c…`
> **deja de ser la huella que produce este repositorio**, porque los dos arreglos
> entran en el medio. No es un fallo, es lo que pasa —ya pasó con `95758c9e…`—.
> Por eso `medios/encina-os-p10-capa.iso` **no se borró** al hacer sitio: es el
> único ejemplar de lo que midieron §4.60 y §4.61.
>
> ---
>
> ### LO ANTERIOR, 2026-08-21: **LA REPRODUCIBILIDAD, PAGADA — y por partida doble**
>
> **`construir-todo.sh` entero, dos pasadas, la misma huella** (`MEDICIONES.md`
> §4.60). Era lo más viejo sin pagar: todos los medios salían de
> `fabricar-iso.sh --repo`, y **la vuelta entre las dos máquinas estaba sin
> ejercitar**.
>
> ```
> pasada 1 -> medios/encina-os-r1.iso   sha256 59bc3a3c...e946e1d4   0 fallos
> pasada 2 -> medios/encina-os-r2.iso   sha256 59bc3a3c...e946e1d4   0 fallos
>
> [OK]    DOS PASADAS, LA MISMA HUELLA     <- la definicion de terminado
> ```
>
> **Y LA COINCIDENCIA QUE NO SE BUSCABA VALE MÁS QUE LAS DOS PASADAS:** esa huella
> **es la de `p10-capa`**, fabricada el 20 **por el otro camino**, con
> `fabricar-iso.sh --repo` en local. **Dos caminos distintos, en días distintos,
> el mismo medio bit a bit** — el largo pasa por `git archive HEAD`, `ssh` al
> constructor Ubuntu, la cosecha de 28 `.deb` por huella y el `Packages` generado
> allí; el corto no sale del Mac. Es **reproducibilidad cruzada**: descarta que la
> huella dependa del camino, que es más de lo que pedía la casilla.
>
> **`[OMIT]`, y lo dice el propio guion: que arranque.** Con el 33 % de §4.59 de
> por medio eso exige **contar**, no un arranque. Como `r1` es bit a bit
> `p10-capa`, lo que se sabe de este medio es lo que §4.59 midió: **4 de 6**.
>
> **Y UNA TRAMPA DEL ENTORNO, cazada por su control** (trampa 45): `utmctl start`
> empezó a dar `OSStatus error -1712` con `encina-dev` parada, mientras `list` y
> `status` contestaban tan tranquilos. **La conclusión fácil era «encina-dev está
> rota».** El control —arrancar `p11`, que había arrancado 5 de 6 esa noche—
> **falló igual**: el sordo era **UTM**, y se destrabó con `open -a UTM`. Habría
> sido la quinta atribución falsa por el mismo camino.
>
> **EL DISCO, resuelto: de 10 GiB a 26.** Se borraron `p6-trozo`, `p12`, `p13` y
> `p14` con sus VMs (14 GiB), y después `r1` y `r2` (7 GiB más), porque **eran el
> mismo fichero que `p10-capa`** —misma huella—. **Se conserva `p10-capa`**: es la
> que citan §4.58 y §4.59 por nombre y **la única con VM registrada**, así que se
> puede volver a arrancar sin fabricar nada. Quedan **ocho** ISOs.
>
> **LO SIGUIENTE:**
>
> 1. **Los dos `[OJOS]` de Jorge** y las dos últimas casillas de
>    `tareas/aspecto/5-cierre.md`. **Es lo único que queda del incremento**, y ya
>    no hay nada delante: la capa se monta, la marca llega, el medio es
>    reproducible y el banco está acotado. Capturas en
>    `medios/conteo-arranques/capturas/`.
> 2. **`[OMIT]` P5**, el título de la ventana del instalador, sin medir.
> 3. **Qué causa el 33 % del banco** — acotado, no explicado, con la pista de
>    §4.59f (un fallo exacto por ronda, post-hoc).
>
> ---
>
> ### LO ANTERIOR, 2026-08-20 (noche): **EL FALLO INTERMITENTE ES DEL BANCO, MEDIDO: 33 % Y LOS TRES MEDIOS. La capa queda LIMPIA**
>
> **18 arranques, 6 rondas intercaladas, veredicto contado y no mirado**
> (`MEDICIONES.md` §4.59). Era el `[OMIT]` que contaminaba **cualquier** medición
> de arranque en este anfitrión, y ya no lo es:
>
> ```
>  brazo   la capa                        arranco
>  p10     entera, montada                4 de 6
>  p11     vacia, montada                 5 de 6
>  p9      presente pero INERTE           3 de 6
>
>  Fisher exacta de una cola, p10 contra p11+p9:  p = 0,6942   (umbral 0,05)
>  [OMIT]  NO hay senal. Tasa global de fallo del anfitrion: 6 de 18 = 33 %
> ```
>
> **LOS TRES BRAZOS FALLAN**, incluido `p9`, que lleva el squashfs dentro pero el
> núcleo **no lo nombra** —o sea que arranca como un medio sin capa—. **La capa no
> afecta a la probabilidad de arrancar**, y el brazo que sale peor en bruto es
> justo el de la capa **inerte**.
>
> **Y SE CAE DEL TODO LA CORRELACIÓN DE `ubuntu-text.plymouth`:** era «los dos
> medios que necesitaron reintento son los dos que lo llevan», y hoy `p11` y `p9`
> lo necesitaron **sin llevarlo**. Con un 33 % de fallo, la tabla de §4.58 —`1 de
> 3` en `p10`, `1 de 1` en tres medios— **es lo que se espera por azar**: la
> probabilidad de que un medio bueno dé `1 de 1` es 0,67. **Los cuatro bisecados
> de ayer no midieron nada del producto.**
>
> **EL MÉTODO, y es lo que hizo que esto valga:** la predicción con sus
> probabilidades y su umbral se escribió **antes de arrancar nada**, y el
> veredicto y su banco **antes del experimento** —commit `6f04353`, fechado antes
> del primer dato—. El criterio lo aplica `veredicto-conteo.py`, no yo: quince
> arranques con tasas cerca del 50 % se leen después como uno quiera.
>
> **CUATRO INSTRUMENTOS NUEVOS**, todos con su banco y sus sabotajes:
>
> | guion | qué hace | su banco |
> |---|---|---|
> | `scripts/veredicto-pantalla.py` | `NEGRA`/`GRAFICA`/`INDETERMINADA` contando **colores**, no bytes | `banco-veredicto.sh`: **9 correctas, 0 fallos** |
> | `scripts/banco-veredicto.sh` | control por columna, prueba de escala, 3 sabotajes | — |
> | `scripts/contar-arranques.sh` | las rondas intercaladas, con la guarda de la trampa 13 | — |
> | `scripts/veredicto-conteo.py` | aplica el criterio preinscrito, Fisher sin dependencias | `--banco`: **8 correctas, 0 fallos** |
>
> **DOS COSAS QUE EL DÍA PRODUJO Y NO ESTABAN PREVISTAS, y las dos son mías:**
>
> 1. **Un fallo EXACTO en cada una de las seis rondas** —ni cero, ni dos—, que
>    bajo independencia es **una entre 130**. Es **post-hoc**, así que es
>    hipótesis y no resultado, pero es la pista concreta para arreglar el banco en
>    vez de rodearlo: los fallos **no son independientes entre sí**.
> 2. **Un fallo de diseño mío (trampa 44):** intercalar siempre en el mismo orden
>    **confunde el brazo con la posición**. Hoy no cambia la conclusión —no hay
>    efecto que esconder—, pero si hubiera salido señal no habría sabido de qué
>    era. **La próxima vez se baraja el orden dentro de la ronda.**
>
> **LO SIGUIENTE, en este orden, y el primero ya no está bloqueado:**
>
> 1. **`construir-todo.sh` sigue SIN completarse** con el árbol de hoy —todos los
>    medios salieron de `fabricar-iso.sh --repo`, la vuelta entre las dos máquinas
>    está **sin ejercitar**— y **la segunda pasada de reproducibilidad sigue sin
>    pagarse**. Su definición de terminado no es «sale una ISO».
> 2. **Los dos `[OJOS]` de Jorge** y las dos últimas casillas de
>    `tareas/aspecto/5-cierre.md`. **Ahora hay de verdad qué mirar**, y las
>    capturas de los 18 arranques están en `medios/conteo-arranques/capturas/`.
> 3. **`[OMIT]` P5**, el título de la ventana del instalador, sin medir.
>
> **Y EL DISCO SIGUE MANDANDO:** ~12 GiB y nueve ISOs. Este experimento **no
> fabricó ninguna**: los tres medios ya estaban en disco y las VMs registradas.
>
> ---
>
> ### LO ANTERIOR, 2026-08-20 (cierre): **LA CAPA SE MONTA. La casilla 3 está HECHA salvo los `[OJOS]`**
>
> **LO QUE SE PEDÍA, HECHO Y MEDIDO DENTRO DE LA SESIÓN VIVA** (`MEDICIONES.md`
> §4.58e). Del 2026-08-15 al 20 esa orden devolvía **cero líneas**:
>
> ```
> encinaos@encinaos:~$ grep encina /proc/mounts
> /cow / overlay rw,relatime,lowerdir=/minimal.standard.live.encina.squashfs:
> /minimal.standard.live.squashfs:/minimal.standard.squashfs:/minimal.squashfs,…
> ```
>
> **SON DOS CAMBIOS Y NADA MÁS.** La capa se llama
> `minimal.standard.live.encina.squashfs` —**el nombre es la CADENA**: `casper`
> la construye quitando puntos y **hace `panic` si un eslabón no existe**, así
> que el nombre no se elige, se hereda— y el `grub.cfg` lleva **`layerfs-path=`**,
> que **pisa** al `LAYERFS_PATH` del initrd (`/init:94` lo lee, `casper:909` lo
> reexporta: **no hay que tocar el initrd**).
>
> **Y LA MARCA YA LLEGA:** en `p12` y `p13` el fondo de la sesión viva **ya no es
> el de Ubuntu**, es el nuestro. Es lo que la casilla 3 perseguía desde el 15.
>
> **LO QUE NO ESTÁ CERRADO, y no se cuela:** con la capa **entera** (30 ficheros)
> la sesión gráfica **no llega** —pantalla negra con el cursor de Xorg, **dos**
> arranques, con `systemd` entero en `[ OK ]` y con IP en el `arp`—. Bisecado
> **quitando piezas**, que es la única forma que produce causas aquí:
>
> | medio | qué lleva la capa | resultado |
> |---|---|---|
> | `p10-capa` | los **30** ficheros | **NEGRA**, dos arranques |
> | `p11-vacia` | **1** fichero que no tapa nada | escritorio entero + instalador |
> | `p12-sintexto` | **24**: los 6 de texto **fuera** | escritorio + **fondo de Encina** |
> | `p13-desktop` | 24 + `ubuntu.desktop` | escritorio + fondo de Encina |
> | `p14-plymouth` | 24 + `ubuntu-text.plymouth` | negra, y al **2º** arranque ESCRITORIO |
> | `p10-capa` | los **30**, otra vez | negra, negra, y al **3º** **ESCRITORIO** |
>
> **LAS DOS ÚLTIMAS FILAS SON LA LECCIÓN DEL DÍA: la pantalla negra era el BANCO,
> no el producto.** En este anfitrión el arranque gráfico **falla a veces**, y
> falla igual que un fallo de producto —negra, `systemd` entero en `[ OK ]`, IP
> en el `arp`, `debug.log` en el rellano de ~92 K—. Con un solo arranque negro se
> escribió que `ubuntu-text.plymouth` era la causa; **duró dos horas y la tumbó
> repetir el arranque** (§4.58j–l). **No queda ni un fichero bajo sospecha.**
>
> **LAS CINCO PREDICCIONES, escritas antes de fabricar nada: cuatro aciertos y
> una sin medir.** Leído dentro de `p10`, el medio de producto entero:
>
> ```
> PRETTY_NAME="Encina OS 24.04 LTS"     images  slides  whitelabel.yml
> NAME="Encina OS"   LOGO=encina-logo
> ```
>
> El 2026-08-17 esas mismas órdenes daban `NAME="Ubuntu"` y «No existe el
> archivo». **`[OMIT]`: P5**, el título de la ventana del instalador — las
> capturas enseñan el título de la **página**, no el `app-name`.
>
> **LO SIGUIENTE, en este orden:**
>
> 1. **Acotar el fallo intermitente del banco.** Contamina **cualquier** medición
>    de arranque que se haga aquí, y hoy costó una causa falsa. Mientras siga, un
>    «no arranca» **hay que contarlo** —N arranques y N de un control—; un
>    «arranca» vale a la primera.
> 2. **`construir-todo.sh` sigue SIN completarse** con el árbol de hoy, y **la
>    segunda pasada de reproducibilidad sigue sin pagarse**. Los medios de hoy
>    salieron todos de `fabricar-iso.sh --repo`.
> 3. **Los dos `[OJOS]` de Jorge** y las dos últimas casillas de
>    `tareas/aspecto/5-cierre.md`. **Ahora hay de verdad qué mirar:** la sesión
>    viva ya lleva marca.
>
> **Y EL DISCO MANDA:** quedan ~10 GiB y `medios/` tiene **nueve** ISOs. No cabe
> otra bisección sin borrar, y **qué se borra es de Jorge** (`p6-trozo` está
> marcada como gastada). Ojo: borrar VMs no libera nada si su ISO es enlace duro,
> y `fabricar-vm-medio.py` **se niega a fabricar** si quedan menos de dos bundles
> con `F6223E90`.
>
> ---
>
> ### LO ANTERIOR, 2026-08-20 (mañana): **HAY MEDIO DE PRODUCTO QUE ARRANCA, CON NOMBRE Y VERSIÓN PROPIOS** — lo que queda es la capa, la reproducibilidad y los `[OJOS]`
>
> **`71f7958c…` ARRANCA** y enseña «Disposición del teclado» en español, fabricada
> **sin `--info-crudo`**: **0 fallos, 0 avisos**, `1 1 1 1` (`MEDICIONES.md`
> §4.57h). Es el primer medio que lleva a la vez las dos cosas que hasta ayer eran
> incompatibles:
>
> ```
> .disk/info : EncinaOS 24.04.4 LTS "Nutria Nocturna" - Release arm64 (20260210)
> volid      : EncinaOS 0.2.1 arm64        <- NUESTRO nombre y NUESTRA version
> rotulo     : Install EncinaOS 24.04.4 LTS
> canal      : stable/ubuntu-24.04.4
> ```
>
> **LA CAUSA, CERRADA POR EXPERIMENTO:** el instalador exige que `/.disk/info`
> lleve **un nombre en clave entre comillas**; **el contenido da igual** (`"A B"`
> vale igual que `"Noble Numbat"`), el `LTS` solo **no basta**, y la primera
> palabra **puede ser la nuestra**. Ocho ficheros medidos, en §4.57e.
>
> **LA DERIVACIÓN DE §4.53 SE HA ROTO, y sin reintroducir «el nombre en dos
> sitios»:** el `Volume id` **no se escribe, se compone** de la 1ª palabra de
> `.disk/info` (única fuente del nombre) + la versión de `encina-meta` (cotejada
> por huella en el paso 2) + la arquitectura. Con su banco y su sabotaje gastado.
>
> **EL CODENAME ES UN ESQUEMA:** dos palabras aliteradas como Ubuntu, pero **en
> español, con fauna de dehesa** —el bosque de encinas— y con **la inicial atada a
> la base** (`N` de `Noble`), así que dice sobre qué Ubuntu va. **ASCII a
> propósito.**
>
> **LO QUE QUEDA, y no es poco:**
>
> 1. **LA CAPA NO SE MONTA** (§4.54e). Sin eso no hay marca en la sesión viva: ni
>    fondo, ni título de ventana, ni diapositivas, ni `os-release`. Candidato
>    medido: `layerfs-path=` en la línea del núcleo del `grub.cfg`.
> 2. **La segunda pasada de reproducibilidad**, que sigue sin pagarse.
> 3. **Los dos `[OJOS]` de Jorge** y las dos últimas casillas de
>    `tareas/aspecto/5-cierre.md`.
>
> **`[OMIT]` que no se cuela:** si un codename de **una sola palabra** vale, y si
> vale con tildes o eñes. Ninguna hace falta para el producto tal como queda.
>
> ---
>
> ### LO ANTERIOR, 2026-08-19 (cierre): la causa, cerrada — un nombre en clave entrecomillado
>
> **PROBADO QUITANDO Y PONIENDO** (`MEDICIONES.md` §4.57e). Ocho ficheros:
>
> | `.disk/info` | campos | instalador |
> |---|---|---|
> | `Ubuntu 24.04.4 LTS "Noble Numbat" - Release …` | 9 | **funciona** (el oficial) |
> | `EncinaOS 24.04.4 LTS "Noble Numbat" - Release …` | 9 | **funciona** |
> | `EncinaOS 24.04.4 LTS "A B" - Release …` | 9 | **FUNCIONA — codename NUESTRO** |
> | `EncinaOS 24.04.4 LTS - Release …` | 7 | se cae |
> | `Ubuntu 24.04.4 - Release …` | 6 | se cae |
> | `EncinaOS 24.04.4 - Release …` | 6 | se cae |
> | `EncinaOS 0.2.1 - Release …` | 6 | se cae |
> | `Encina OS 0.2.1 - Release …` | 7 | se cae |
>
> **El `LTS` solo no basta. La primera palabra puede ser la nuestra. El contenido
> del codename da igual.** Y ni el canal, ni el `Volume id`, ni el separador, ni el
> paréntesis tenían nada que ver: murieron todos por experimento.
>
> **ESTO DESBLOQUEA TODO LO QUE §4.56 DABA POR BLOQUEADO:**
>
> ```
> NO hace falta «Noble Numbat»       -> la casilla 2 ni se toca
> NO hace falta romper la derivacion -> «EncinaOS 24.04.4 LTS "A B" arm64» = 32 bytes, CABE
> NO hace falta --info-crudo         -> es cadena de PRODUCTO: 0 avisos, volid nuestro
> construir-todo.sh deja de parar en el 5e
> ```
>
> **LO QUE QUEDA ES CRITERIO DE JORGE, NO MEDICIÓN:**
>
> 1. **El nombre en clave de verdad.** Presupuesto durísimo: con `EncinaOS` delante
>    caben **5 bytes** de codename (`"A B"` y nada más); con `Encina`, **7**
>    (`Encina 24.04.4 LTS "Roble" arm64` = 32, `… "Ab Cd" arm64` = 32).
> 2. **Si aun así se rompe la derivación**, porque el `Volume id` arrastra el `LTS`
>    y las comillas: el USB se rotula `EncinaOS 24.04.4 LTS "A B" arm64`. **Cabe,
>    pero es feo.** Ya no es obligatorio; es estética de producto.
>
> **`[OMIT]`:** no está medido si un codename de **una sola palabra** vale —los
> tres que arrancan llevan dos—. Cuesta un medio.
>
> **Y detrás siguen, sin tocar:** que **la capa no se monta** (§4.54e), la
> **segunda pasada de reproducibilidad**, y los **`[OJOS]`**.
>
> ---
>
> ### LO ANTERIOR, 2026-08-19 (tarde): la causa acotada a `LTS "Noble Numbat"`, que resultó ser sólo las comillas
>
> **CERRADA POR EXPERIMENTO** (`MEDICIONES.md` §4.56cc). Se probó quitando y
> poniendo, no leyendo:
>
> | `.disk/info` | campos | instalador |
> |---|---|---|
> | `Ubuntu 24.04.4 LTS "Noble Numbat" - Release …` | 9 | **funciona** (el oficial) |
> | `EncinaOS 24.04.4 LTS "Noble Numbat" - Release …` | 9 | **FUNCIONA — con NUESTRO nombre** |
> | `Ubuntu 24.04.4 - Release …` | 6 | se cae |
> | `EncinaOS 24.04.4 - Release …` | 6 | se cae |
> | `EncinaOS 0.2.1 - Release …` | 6 | se cae |
> | `Encina OS 0.2.1 - Release …` | 7 | se cae |
>
> **Dos cosas cerradas de un golpe:** la causa es **la ausencia de ese trozo**, y
> **`EncinaOS` como primera palabra NO tumba el instalador** —las dos filas de 9
> campos sólo se diferencian en ella y las dos arrancan—. Por el camino murieron
> tres hipótesis por experimento: **el canal**, **el sabor** y, ayer, la capa, el
> `Volume id` y el `menuentry`.
>
> **LO SIGUIENTE, Y ES UNA CONSECUENCIA MEDIDA, NO UNA OPCIÓN: hay que ROMPER LA
> DERIVACIÓN de §4.53.** El `.disk/info` que arranca da un `Volume id` derivado de
> **41 bytes** contra los **32** del PVD (§4.56q: con el nombre en clave real no
> cabe **ningún** nombre de producto, ni la cadena vacía). El medio de hoy sólo se
> pudo fabricar porque `--info-crudo` hace viajar el volumen **oficial**, así que
> **NO es entregable: dice Ubuntu en el nombre del volumen**. Para tener a la vez
> el fichero que arranca y un `Volume id` propio, el `Volume id` tiene que dejar
> de salir de `.disk/info`.
>
> **Y HAY UNA DECISIÓN DE PRODUCTO QUE ES DE JORGE:** el fichero que funciona
> lleva **`LTS "Noble Numbat"`**, el nombre en clave de Ubuntu, dentro de la cadena
> del producto. Es terreno de la casilla 2.
>
> **`[OMIT]` que no se cuela como hecho:** cuál de los tres —el `LTS`, las
> comillas o el número de campos— es el que importa **no está medido**; el trozo
> los restaura a la vez. Lo separa `Ubuntu 24.04.4 LTS - Release …` (7 campos).
>
> **Instrumento nuevo: `--info-crudo`**, para medios de diagnóstico: las **tres**
> guardas de marca dejan de parar pero **se siguen evaluando** y lo dicen, con el
> `.disk/info` del producto como control. Sin ella nada de esto se podía fabricar.
>
> **Y UN PATRÓN QUE YA NO ES SOSPECHA:** cuatro atribuciones falsas seguidas
> construidas igual —mecanismo leído + control + caso que falla—. Esa forma **no
> produce causas** aquí. Marcador de predicciones de la sesión: **1 de 4**.
>
> ---
>
> ### LO ANTERIOR, 2026-08-19 (tarde, a medias): el bisecado baja a un solo trozo
>
> **TRES HIPÓTESIS MUERTAS POR EXPERIMENTO EN UNA SESIÓN** (`MEDICIONES.md`
> §4.56), las tres con predicción escrita antes de arrancar y las tres **falsas**:
>
> | `.disk/info` | campos | instalador |
> |---|---|---|
> | `Ubuntu 24.04.4 LTS "Noble Numbat" - Release …` | 9 | **funciona** (el oficial) |
> | `EncinaOS 24.04.4 - Release …` `d81586ae` | 6 | **se cae** — muere el CANAL |
> | `Ubuntu 24.04.4 - Release …` `9b1194b9` | 6 | **se cae** — muere el SABOR |
>
> El canal `stable/ubuntu-24.04.4` es **el del medio oficial**, que funciona, y aun
> así se cae. Y con `Ubuntu` de primera palabra —sabor válido— también. **El
> separador y el paréntesis están iguales en los dos lados.** Queda `LTS "Noble
> Numbat"`, y **las comillas están en el único que funciona y faltan en los cuatro
> que se caen**.
>
> **LO QUE YA SE PUEDE DAR POR CERRADO SIN SABER CUÁL GANA:** §4.56q mide que
> **con el nombre en clave real no cabe NINGÚN nombre de producto en el `Volume
> id`** —ni la cadena vacía: `LTS "Noble Numbat"` consume los 32 bytes enteros—.
> Así que si gana el trozo, la derivación no cabe; y si gana la primera palabra,
> el nombre no puede ir en el fichero. **En los dos casos hay que romper la
> derivación que §4.53 unió**, y la «tercera vía» de §4.56a deja de ser opcional.
>
> **LO QUE FALTA:** el medio `EncinaOS 24.04.4 LTS "Noble Numbat" - …`
> (`b7d287f7`), ya fabricado con `--info-crudo` y **sin arrancar todavía**: tres
> intentos, tres pantallas negras con el sistema vivo (log a 92 204 B e IP), que
> por la trampa 38 **no es un resultado**. Contesta si nuestro nombre vale una vez
> restaurado el trozo. Y detrás, separar cuál de los tres —`LTS`, comillas o
> recuento— es, con `Ubuntu 24.04.4 LTS - Release …` (7 campos).
>
> **INSTRUMENTO NUEVO: `--info-crudo`**, para medios de diagnóstico. Las **tres**
> guardas de marca dejan de parar pero se siguen evaluando y lo dicen, con el
> `.disk/info` del producto como control. Sin ella estos medios **no se podían
> fabricar**.
>
> **Y UN PATRÓN QUE YA NO ES SOSPECHA:** van **cuatro** atribuciones falsas
> seguidas hechas igual —mecanismo leído + control + caso que falla—. Esa forma
> **no produce causas** en este proyecto.
>
> ---
>
> ### LO ANTERIOR, 2026-08-19 (mañana): **EL BISECADO CIERRA — LA CAUSA ES `/.disk/info`**, y lo que falta es saber POR QUÉ y decidir el precio
>
> **SE BISECÓ D23 Y HAY RESPUESTA** (`MEDICIONES.md` §4.55). Primero hizo falta el
> instrumento: `fabricar-iso.sh` tiene ahora **una bandera por mecanismo**
> —`--sin-capa`, `--sin-volid`, `--sin-info`, `--sin-menu`— y un **paso 13 que abre
> la ISO terminada y comprueba que lleva lo que se pidió**, porque todas las demás
> comprobaciones del guion sacan sus expectativas de la misma bandera que dicen
> comprobar. Ese lector tiene banco propio de segundos, `imagen/banco-mecanismos.sh`,
> con su control gastado.
>
> | ISO | capa volid info menu | instalador |
> |---|---|---|
> | `e8a0ead2…` | 1 1 1 1 | **se cae** |
> | `26bf5442…` `--sin-capa` | 0 1 1 1 | **se cae** |
> | `08392ddc…` `--sin-volid` | 1 0 1 1 | **se cae** |
> | `4f856618…` `--sin-info` | 1 1 0 1 | **FUNCIONA** — «Disposición del teclado» |
>
> **La capa, el `Volume id` y el `menuentry` quedan exonerados POR EXPERIMENTO.**
> Y esto no es lo de §4.54h —mecanismo leído más control más caso que falla, que
> salió falso—: es quitar una pieza y ver arrancar lo que no arrancaba.
>
> **LO QUE FALTA, EN ESTE ORDEN:**
>
> 1. **Saber POR QUÉ, que no está medido.** El candidato sigue siendo el canal de
>    snap de `refresh.py`, y ahora se ve el agujero de §4.54i: comparó
>    `stable/ubuntu-OS` con `stable/ubuntu-0.2.1`, **dos canales que no existen
>    ninguno de los dos**, así que aquel descarte no valía. La prueba es un
>    `.disk/info` **nuestro** cuya segunda palabra sea `24.04.4`.
> 2. **DECIDIR EL PRECIO, Y ES DE JORGE.** Esa palabra manda a la vez en el canal,
>    en el rótulo del icono (`Install <dos primeras palabras>`) y, por derivación,
>    en el `Volume id`. Con `24.04.4` el medio se rotula **«Install EncinaOS
>    24.04.4»** y el volumen **«EncinaOS 24.04.4 arm64»**. La alternativa es
>    romper la derivación que §4.53 unió a propósito.
> 3. **Y sigue en pie que LA CAPA NO SE MONTA** (§4.54e), que es cosa aparte del
>    instalador: sin resolverlo no hay marca en la sesión viva. El candidato medido
>    es `layerfs-path=` en la línea del núcleo del `grub.cfg`.
>
> **Dos cosas del banco que hay que tener delante:** «se ve el instalador» es señal
> positiva y basta una vez; **«pantalla negra» NO es un resultado** —salió en tres
> medios, uno de los cuales arrancó al tercer intento—. Y el `_` **no llega** al
> invitado: llega como `?`, que es comodín del shell (trampa 35).
>
> ---
>
> ### LO ANTERIOR, 2026-08-17 (tarde): **LA CAPA NO SE MONTA** — la vuelta única se dio, y tumbó la casilla 3
>
> **LA VUELTA ESTÁ DADA Y LOS PASOS 1 Y 2 SALIERON LIMPIOS A LA PRIMERA**
> (`MEDICIONES.md` §4.54): `encina-branding` 0.1.15 construido y cotejado por
> huella (`6d9fcd64…`, 88 comprobaciones y 0 fallos entre los tres guiones), y la
> ISO **reproducible**, `ac175f64…`, 3 721 265 152 bytes, **dos pasadas la misma
> huella** con el control de que la comparación sabe decir «distintas». Los
> bloques 5e y 11 pasaron **en su sitio**, y el `Volume id` se predijo antes de
> mirarlo y salió el mismo: `Encina OS 0.2.1 arm64`.
>
> **PERO EL PASO 3 —arrancarla— TUMBA LA CASILLA 3 ENTERA: la capa de marca NO SE
> MONTA NUNCA.** Medido dentro de la sesión viva, no deducido:
>
> ```
> encina@encina:~$ grep zz-encina /proc/mounts          <- ni una línea
> encina@encina:~$ ls /usr/share/desktop-provision/     <- no existe
> encina@encina:~$ cat /etc/os-release                  <- NAME="Ubuntu"
> ```
>
> **La causa, leída en el `casper` de este mismo medio:** hay **dos ramas**, y la
> del glob `*.squashfs` —la que §4.52 describía— **sólo corre si `$LAYERFS_PATH`
> está vacío**. No lo está: vale `minimal.standard.live.squashfs`, puesto en
> `/conf/conf.d/default-layer.conf` **dentro del `initrd`**. La lista de capas se
> construye **quitando puntos del nombre**, y el `lowerdir` del invitado lo
> enseña: `minimal.standard.live` → `minimal.standard` → `minimal`, **tres y ni
> una más**. §4.52 buscó `layerfs-path` —la grafía de la línea de órdenes—, sacó
> 0, **y era verdad**; la variable de dentro se llama `LAYERFS_PATH` y vive en un
> cpio comprimido. **El `zz-` del nombre no sirve de nada.**
>
> **LO QUE SIGUE EN PIE, y no es poco:** `.disk/info` funciona —`whoami` da
> `encina`— y el `grub.cfg` también. Los otros tres mecanismos de D23 están
> verificados en el medio.
>
> **Y UN SEGUNDO HALLAZGO: EL INSTALADOR SE CAE, ES NUESTRO, Y LA CAUSA ESTÁ
> LEÍDA EN EL CÓDIGO** (§4.54h, enmienda del mismo día). El control se gastó y
> `ac0a5721…` **arranca y enseña el instalador**; la nuestra no, en dos arranques
> distintos. La causa está en `subiquity/server/controllers/refresh.py`:
>
> ```python
> release = info.split()[1]                       # de /cdrom/.disk/info
> return ("stable/ubuntu-" + release, ...)
> ```
>
> **La SEGUNDA PALABRA de `.disk/info` no es un nombre: es el número de versión**,
> y con ella se construye el canal de snap del instalador. `Ubuntu 24.04.4 …` da
> `24.04.4`; **`Encina OS 0.2.1 …` da `OS`**, o sea el canal `stable/ubuntu-OS`.
> Eso explica que el fallo sea **silencioso**: ni volcado, ni error en el
> `journal`, ni `Traceback`.
>
> **Y los dos controles anteriores no valían: los rompí yo.** Los tres bundles que
> fabriqué **compartían los `Drive.Identifier`**, y con eso la VM arranca y se
> cuelga antes de nada —pantalla negra y el `debug.log` de QEMU congelado en
> 2 759 bytes—. Con identificadores propios arrancó a la primera.
>
> **ENMIENDA DE LA MISMA TARDE (§4.54i): ESA CAUSA ERA FALSA.** Se rehízo el medio
> con `EncinaOS 0.2.1` —segunda palabra `0.2.1`, canal `stable/ubuntu-0.2.1`— y
> **el instalador se cae igual** (`e8a0ead2…`). El mecanismo de `refresh.py` es
> real y `stable/ubuntu-OS` era un defecto de verdad, **así que el cambio se
> queda**; lo falso era la atribución.
>
> **LO QUE SÍ ACOTA ES EL BISECADO**, tres ISOs en bundles idénticos:
>
> | ISO | Qué lleva de más | Instalador |
> |---|---|---|
> | `ac0a5721…` | la entregada de E4 | **funciona** |
> | `1224b5b1…` | `.deb` y seed nuevos, sin D23 | **funciona** |
> | `e8a0ead2…` | **+ los mecanismos de D23** | **se cae** |
>
> **La regresión está DENTRO de D23**, no en los `.deb`, ni en el seed, ni en el
> banco. Quedan tres sospechosos: **la presencia de `/casper/zz-encina.squashfs`**
> —el más gordo, porque es lo único que añade un fichero a `/casper`—, el
> **`Volume id`** y el **resto de `.disk/info`**.
>
> **LO SIGUIENTE, EN ESTE ORDEN:**
>
> 1. **Bisecar D23, y para eso `fabricar-iso.sh` necesita una bandera por
>    mecanismo** —hoy no sabe fabricar sin capa ni sin `Volume id`—. **Empezar por
>    quitar la capa**: si con eso arranca, la casilla 3 tiene que resolver **dos**
>    cosas a la vez, que la capa se monte y que su presencia no tire el instalador.
> 2. **Decidir por dónde entra la marca de la sesión viva**, ahora que la capa
>    suelta no vale. El candidato medido es **`layerfs-path=` en la línea del
>    núcleo del `grub.cfg`** —fichero nuestro, que ya reescribimos— encadenando
>    `minimal.standard.live.encina.squashfs`. No está probado.
> 3. **El inventario da verdes falsos** para todo lo que aporta la capa: dice «ya
>    no dice Ubuntu» de ficheros que el sistema en marcha no ve. Hay que enseñarle
>    la diferencia entre *está en el medio* y *se monta*.
>
> ---
>
> **LO QUE SIGUE DEBAJO ES EL ESTADO DE ESTA MAÑANA, y se deja porque explica por
> qué se llegó hasta aquí** — pero **su afirmación de que la casilla 3 estaba
> hecha es la que se acaba de caer**.
>
> **[tareas/marca-del-medio.md](tareas/marca-del-medio.md) está HECHA en lo que
> se puede hacer sin arrancar: las 4 casillas, 4 de 4** (eran 5, y la del
> logotipo de la rejilla resultó ser una copia rancia de una ya cerrada). **Lo
> que queda de ese bloque no es trabajo de agente: es un `[OJOS]` de Jorge**, y
> se cobra en la misma vuelta que las dos últimas casillas de
> [tareas/aspecto/5-cierre.md](tareas/aspecto/5-cierre.md). Sigue siendo **lo que
> bloquea publicar**, junto con los 3,46 GB del alojamiento.
>
> **LO QUE HAY QUE HACER, Y EN ESTE ORDEN:**
>
> 1. **Construir `encina-branding` 0.1.15 en la VM**, porque **no está en el
>    disco**: en `debian-packages/` sólo hay 0.1.7, 0.1.12 y 0.1.13, y la huella
>    que exige `fabricar-iso.sh` es `6d9fcd64…`. **Sin esto no se puede fabricar
>    nada**, y por eso `fabricar-iso.sh` no se ha podido ejecutar entero desde el
>    2026-08-15.
> 2. **Refabricar la ISO** con `construir-todo.sh`. Su definición de terminado
>    **no es «sale una ISO»**: es que **dos pasadas den la misma huella**. Las
>    dos piezas nuevas ya están medidas por separado y las dos son reproducibles
>    —la capa (§4.52e, con su control dentro del guion) y el `Volume id`
>    (§4.53c)—, pero **la ISO entera con las dos dentro no se ha construido ni
>    una vez**.
> 3. **Instalarla y MIRARLA.** Es donde se cobran, todos a la vez, el `[OJOS]` de
>    la casilla 3 —fondo, rótulo e icono del instalador, botón de la rejilla,
>    Acerca de, título de la ventana, dibujos de las páginas y las tres
>    diapositivas; y en máquina de verdad, el menú de GRUB—, el de la casilla 4
>    —que el medio **arranque** con el nombre nuevo— y las dos últimas casillas
>    de `5-cierre.md`. **La orden que separa «la capa no se montó» de «no me
>    gusta» es `grep zz-encina /proc/mounts && cat /etc/os-release && whoami`.**
>
> **LA CUARTA CASILLA, HECHA EL 2026-08-17 (`MEDICIONES.md` §4.53), y su premisa
> era falsa: el instalador NO usa el nombre del volumen para encontrarse a sí
> mismo.** El medio se llama **`Encina OS 0.2.1 arm64`**, derivado de
> `marca/disk-info` y no escrito a mano.
>
> - **Lo primero fue leer quién usa hoy ese nombre, antes de tocarlo**, en el
>   código que viaja en el medio: `casper` encuentra el medio **por contenido**
>   —¿hay algún `*.squashfs` en `/casper`?— y desempata **por UUID**;
>   `apt-cdrom` saca el nombre de **`.disk/info`**; y `subiquity` va **toda** por
>   la ruta `/cdrom`.
> - **Y lo que podía tumbar la casilla estaba sin medir y sale a favor: el
>   `grubaa64.efi` FIRMADO hace `search --file --set=root /.disk/info`, no
>   `search --label`** — leído en el `grub.cfg` empotrado en su `squashfs`
>   interno, con `search --label` a **0 apariciones**. La cadena de arranque
>   cuelga **del mismo fichero que este proyecto ya reescribe**.
> - **La comprobación que decide:** contra un **medio de control** remasterizado
>   sin tocar el nombre, la diferencia son **88 bytes de 3 715 235 840, todos
>   dentro del campo del nombre** de los cuatro descriptores. **17 correctas, 0
>   fallos**, y sin precio: `md5sum.txt` no cubre el PVD y no hay que rehacerlo.
> - **Se resuelve la trampa que la casilla pedía resolver:** el paso 10 de
>   `fabricar-iso.sh` —su comprobación más fuerte— era **ciego** a este cambio,
>   porque compara fichero a fichero y el `Volume id` **no es un fichero**. Hay
>   un paso 11 que lee **todos** los descriptores.
> - **Y dos defectos salieron de EJECUTAR los bloques nuevos**, que hubo que
>   ejecutar aparte porque el guion entero hoy se niega: el nombre se cortaba
>   **por número de palabras** y se truncaba en silencio; y **el número de
>   descriptores no es del formato** —la oficial tiene 2 primarios y 2 Joliet, la
>   nuestra 4 y 0—, de donde sale un hallazgo que nadie había medido:
>   **remasterizar se lleva el Joliet por delante, y eso pasa desde E3**.
>
> **LA TERCERA CASILLA, HECHA EL 2026-08-15 SALVO EL `[OJOS]`
> (`MEDICIONES.md` §4.52): aquí sí se tocó el producto, y la pregunta de fondo
> del bloque está contestada — es D23.**
>
> - **«Reempaquetar o E5» eran dos opciones que resultaron no ser las dos.** La
>   marca del medio se pone **con los mecanismos que Ubuntu ya trae**, y la razón
>   está medida y no admite discusión: **el medio no lleva `layerfs-path=`**, así
>   que casper monta **todos** los `*.squashfs` de `/casper` y **el último por
>   orden alfabético manda** — o sea que **una capa de 3 084 288 bytes tapa a una
>   de 1 692 274 688**, 549 veces menos. **E5 deja de ser lo que desbloquea
>   publicar.**
> - **Los dos `[OMIT]` de §4.51, contestados sobre el código del commit exacto
>   con el que se construyó el snap — y uno estaba MAL PLANTEADO.**
>   `{{ DISTRO }}` **no sale de `.disk/info` ni de `os-release`: es una constante
>   compilada en el binario**, y la única llave que existe (`flavor`) sólo admite
>   uno de los once sabores de Ubuntu. Las diapositivas **se sustituyen, no se
>   parchean**. El otro abre la puerta entera: **el `whitelabel.yml` se apunta
>   desde fuera del snap** —`/usr/share/desktop-provision/`, documentado por la
>   propia Canonical— y con él el **título de la ventana** (`app-name`), las
>   diapositivas y los dibujos de cada página, **sin tocar el snap firmado**.
> - **El inventario baja de 31 a 24 apariciones, con los OCHO sitios nombrados
>   uno a uno** y 0 fallos en los dos lados. La cuenta no cuadra a propósito: la
>   línea de `os-release` sigue contando porque **dice `ID=ubuntu`**, que D22
>   manda dejar.
> - **Y el instrumento sacó dos defectos suyos al usarlo:** contaba **sitios y no
>   valores**, así que el número **no podía bajar nunca**; y su control **caducó
>   justo al mejorar el producto**, dando un `[FALLO]` que se leía como
>   instrumento roto.
>
> **LO QUE FALTA DE ESTA CASILLA, y no se da por bueno:** el **splash del
> arranque** —`watermark.png` y `bgrt-fallback.png` viven en el `initrd`, antes de
> que exista ninguna capa, así que exigen reescribirlo— y **el `[OJOS]`**: nadie
> ha visto nada de esto en pantalla. Se paga en la vuelta única, detrás de la
> casilla 4.
>
> **LA SEGUNDA CASILLA, CERRADA EL 2026-08-15: los términos de Canonical están leídos y lo
> que obligan está escrito — es D22, con las citas literales en §2.1.** Es la
> única casilla del bloque sin comando que la demuestre, así que lo que la hace
> verificable es la forma: **fuente, fecha de consulta, redirección y huella del
> texto**, y **lo leído separado de lo interpretado**. Tres cosas que cambian el
> trabajo que viene:
>
> - **«Marca no es cadena»**, y con eso los 39 sitios de §4.51 se reparten en
>   **tres pilas**: lo que presenta el producto ante el usuario **sale**; los
>   activos gráficos de Canonical **salen aunque no se vean**; y la procedencia
>   técnica —`ID=ubuntu`, los 155 nombres de `.deb`, `Origin: Ubuntu` del
>   `Release` firmado— **se queda, y quedarse es lo correcto**. Sin este reparto
>   la casilla siguiente no tiene criterio para parar.
> - **La fórmula de atribución es NUESTRA, no de ellos.** La política **no
>   contiene** «derived from Ubuntu» ni ninguna otra autorizada, y **no existe
>   ningún documento de Canonical para derivadas** (27 entradas en su índice
>   legal, ninguna lo es). Lo que concede es referenciar sin implicar aval.
> - **La ISO de hoy no se puede publicar, y el bloqueo tiene nombre:** no son los
>   60 bytes de `.disk/info`, son los logotipos **dentro del snap firmado de
>   109 MB**. D22 **no resuelve** la pregunta de fondo del bloque —reempaquetar o
>   E5—: **la endurece**.
>
> **Y dos efectos fuera del bloque:** `os-release` sale **a medias** de §8 —lo
> decidido es qué campos cambian; sigue fuera el mecanismo, porque el
> `os-release` del medio vive dentro de una capa de 1,69 GB y un `dpkg-divert`
> desde un `.deb` **no lo alcanza**—, y **D6 queda acotada, no debilitada**:
> cubre `ID` y nunca cubrió `NAME`.
>
> **LA PRIMERA CASILLA, CERRADA HOY (`MEDICIONES.md` §4.51): el medio dice Ubuntu
> en 39 sitios, y están todos con su fichero, su cadena y dónde se ve.** Leídos
> sobre `1224b5b1…` **sin arrancarla y sin gastar VM**, con 6 controles delante y
> 0 fallos, y con instrumento que se queda: `imagen/inventario-marca.sh`. Lo que
> hay que saber antes de abrir la siguiente:
>
> - **El rótulo del icono del instalador no está escrito: se calcula desde
>   `/.disk/info`** —`casper-bottom/25adduser`, medido con su control: un
>   `.disk/info` de Encina da `Name=Install Encina OS`—. Son **60 bytes**.
> - **La sesión viva no lleva NI UN fichero de Encina** (0, con el control de que
>   el mismo recuento sobre `ubuntu` da 4 450). `encina-branding` se instala en el
>   objetivo y **no llega al medio**: el fondo, el dock y el botón de la rejilla
>   que rodean al instalador son Ubuntu de fábrica, y el fondo vive dentro de una
>   capa de **1,69 GB**.
> - **El instalador es un snap de 109 MB** —`ubuntu-desktop-bootstrap` 495— con
>   las diapositivas, los logotipos y el título dentro. **Es la frontera real del
>   reempaquetado**, y refuerza la decisión de fondo que la tarea ya planteaba
>   (¿reempaquetado o E5?). Trae un **`whitelabel.yml`** que mapea cada página a
>   su imagen, y que **nadie había nombrado en este repositorio**.
> - **Y dos cosas sin medir, escritas a propósito:** cuál de las dos fuentes
>   rellena `{{ DISTRO }}` —`/cdrom/.disk/info` o `/etc/os-release`, los dos
>   literales están en el binario— y si el `whitelabel.yml` se puede apuntar desde
>   fuera del snap.
>
> ~~**Lo siguiente es la casilla 4: el nombre del volumen de la ISO**, que hoy dice
> `Ubuntu 24.04.4 LTS arm64` … porque el instalador usa el nombre del volumen para
> encontrarse a sí mismo.~~ **HECHA EL 2026-08-17, y la frase que la justificaba
> era falsa** (§4.53a): ni el instalador ni `casper` ni el GRUB firmado miran la
> etiqueta. **Ya no queda ninguna casilla del bloque**; lo que queda es la vuelta
> única, que es la tarea de arriba.
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
>    | ~~`encina-os-E4-es-0.2.1-95758c9e.iso`~~ | `95758c9e…` | La primera que salió **reproducible** de este repositorio (§4.39). Nunca arrancada. **BORRADA el 2026-08-15 con permiso de Jorge — y `df` devolvió CERO, porque era un clon de la copia que vive dentro de `encina-95758c9e.utm` (§4.50). Sigue en disco ahí, y reproducible desde `git`** |
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
| `encina-udev-settle` | **Clon de APFS de `encina-E4-entrega`, hecho el 2026-08-23 (noche) para medir el coste del drop-in de `gdm.service` en arm64** (`MEDICIONES.md` §4.71): ocho arranques, tres sin el fichero, tres con él y un control quitándolo. Misma MAC e IP `.19` que su origen (trampa 29): **no se encienden las dos a la vez**. Testigo `/etc/encina-testigo-udev-settle` de las `17:13:56Z` | `gpu-pci` | **Parada, sin el drop-in** (se quitó para el control) y no es banco de nada más: se puede borrar. La original no se escribió: su `disco.img` sigue en `2026-08-13 10:29:38` |
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
