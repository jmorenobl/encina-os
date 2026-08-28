# encina-firefox-native

Configura el repositorio APT oficial de Mozilla, su clave de firma y el anclaje
de prioridad, para que Firefox se pueda instalar como paquete `.deb` nativo en
lugar de como Snap.

El motivo no es estetico: dentro del Snap, **Firefox no ve el manejador del
esquema `afirma:`** —su `XDG_DATA_DIRS` no incluye `/usr/share` del anfitrion,
asi que no encuentra `afirma.desktop` ni `/usr/bin/autofirma` y al pulsar
«Firmar» no hace nada, sin error y sin log—. Es un obstaculo que **ningun
`.deb` puede tocar** y que el Firefox nativo elimina de raiz.

Este parrafo decia antes que el Snap «aisla el almacen de certificados NSS
mediante sandbox». **Es falso, y esta medido** (`MEDICIONES.md` §4.3 y §4.4): el
almacen NSS del Snap funciona perfectamente y AutoFirma le instala la CA
correcta. La conclusion no cambia —este paquete sigue siendo condicion
necesaria— pero el cimiento es otro. Tambien decia «Etapa B», marco que
desaparecio el 2026-08-08: la hoja de ruta va por incrementos (`ENCINA-OS.md`
§6).

## Lo que este paquete NO hace

- **No instala Firefox.** Ni el navegador ni el paquete de idioma.
- **No elimina el Snap de Firefox** (R4). Borrarlo se lleva por delante
  marcadores y sesiones del usuario: es una accion destructiva que corresponde
  a la receta de imagen, no a la paqueteria.
- **No ejecuta `apt update`.** No puede: llamar a apt desde un script de
  mantenedor provoca un interbloqueo, porque dpkg mantiene el bloqueo mientras
  corre el script (R3). Lo lanza quien instala.

Tampoco declara `Depends:` sobre `firefox` ni sobre `firefox-l10n-es-es`, y no
es un olvido (R10): esos paquetes viven en el repositorio que configura este,
que no existe en el sistema hasta que este paquete esta instalado. La
dependencia seria irresoluble. Instalar Firefox pertenece a `encina-meta` o a la
receta de imagen.

## Orden de instalacion

El paquete no es autosuficiente por diseno. Son tres pasos y el segundo no se
puede saltar:

    sudo apt install ./encina-firefox-native_*.deb
    sudo apt update
    sudo apt install firefox firefox-l10n-es-es

El nombre del paquete de idioma esta confirmado con `apt-cache search` sobre el
repositorio ya instalado, no supuesto. En el repositorio conviven ademas
`firefox-l10n-es-ar`, `firefox-l10n-es-cl` y `firefox-l10n-es-mx`: el de Espana
es `es-es`.

### El aviso de desactualizacion es normal

Si el sistema ya tenia el paquete `firefox` de Ubuntu instalado (el de
transicion, el que instala el Snap), el tercer paso muestra esto:

    Se DESACTUALIZARAN los siguientes paquetes:
      firefox

Y dpkg avisa despues:

    dpkg: aviso: desactualizando firefox de 1:1snap1-0ubuntu5 a 153.0.3~build1

No es un error ni hay que hacer nada: el deb de Ubuntu lleva epoch (`1:`), lo
que lo hace formalmente **version mas alta** que cualquier version real de
Mozilla. Pasar al paquete de verdad es, para apt, una desactualizacion. Basta
responder que si.

En cambio, en un script no interactivo, `apt-get -y` se niega a desactualizar
por su cuenta y hace falta permiso explicito:

    sudo apt-get install -y --allow-downgrades firefox firefox-l10n-es-es

Es lo que hace `instalar-firefox.sh`. Una persona siguiendo el orden de
arriba no necesita la opcion.

Si Firefox arranca en ingles, falta el paquete de idioma o el locale del
sistema no es espanol; Firefox elige el idioma a partir del locale de la sesion.

## Que el icono abra el Firefox correcto

Instalar el repositorio y Firefox nativo **no basta**, y esta es la parte que
mas sorprende. Con todo correctamente instalado, hacer clic en el icono del dock
seguia abriendo el Snap, porque conviven dos lanzadores llamados «Firefox» con
identificadores distintos y ninguno pisa al otro:

| Fichero | `Exec=` | Quien lo pone |
|---|---|---|
| `/usr/share/applications/firefox.desktop` | `firefox %u` → `/usr/lib/firefox/firefox` | el deb de Mozilla |
| `/var/lib/snapd/desktop/applications/firefox_firefox.desktop` | `/snap/bin/firefox %u` | el Snap |

Ubuntu ancla al dock **el segundo**. Y el fallo no se nota, porque el Snap
tambien esta en espanol: la pantalla parece la correcta. Solo lo delata
`about:support`, con `Binario de la aplicacion` bajo `/snap/firefox/`.

Eso importa porque es justo lo que el proyecto quiere evitar: el sandbox del
Snap aisla el almacen NSS y la firma electronica no funciona. Un paquete que
instala Firefox nativo y deja que el usuario siga abriendo el Snap no ha
resuelto el problema.

### Como se arregla, sin tocar el Snap

**1. Una sombra del lanzador del Snap.** El paquete instala
`/usr/share/applications/firefox_firefox.desktop`, con el mismo identificador
que el del Snap, en un directorio que va **antes** en el `XDG_DATA_DIRS` de la
sesion:

    /usr/share/ubuntu:/usr/share/gnome:/usr/local/share/:/usr/share/:/var/lib/snapd/desktop
                                                          ^^^^^^^^^^  ^^^^^^^^^^^^^^^^^^^^^
                                                            gana            pierde

Asi que lo sustituye sin tocarlo. Es el mismo mecanismo que `encina-branding`
usa para `/etc/dconf/profile/gdm`: no se sobrescribe ningun fichero ajeno, se
gana por precedencia, y R5 se respeta.

No se limita a ocultarlo: **redirige a `/usr/bin/firefox`**, de modo que a quien
tuviera anclado el Firefox del Snap por decision propia el icono le sigue
funcionando, y ademas abre el correcto. Lleva `TryExec=/usr/bin/firefox` porque
este paquete no instala Firefox (R10): entre instalar el paquete e instalar
Firefox el binario no existe, y sin `TryExec` el icono abriria la nada.
`NoDisplay=true` evita que aparezcan dos «Firefox» identicos en el buscador.

**2. Un `gschema.override` que ancla el nativo al dock**, en
`/usr/share/glib-2.0/schemas/99-encina-firefox-native.gschema.override`. Cambia
`favorite-apps` para anclar `firefox.desktop`, y **duplica la seccion con el
sufijo `:ubuntu`**, que es la que manda. Sin esa duplicacion no funciona, y
`gsettings get` desde una terminal te diria que si. Es el mismo fallo que costo
cuatro versiones en `encina-branding`. La comprobacion valida:

    XDG_CURRENT_DESKTOP=ubuntu:GNOME gsettings get org.gnome.shell favorite-apps

### Por que esto no viola R4

R4 prohibe **eliminar** el Snap por destructivo. Aqui no se elimina nada:

- El Snap sigue instalado y su perfil intacto. Arranca con `snap run firefox`.
- `apt purge encina-firefox-native` devuelve el lanzador del Snap, y el
  identificador vuelve a resolver a `/snap/bin/firefox`. `verificar-firefox.sh`
  lo comprueba explicitamente: es lo que demuestra que la operacion es
  reversible y que nunca se destruyo nada.

Desinstalar el Snap desde el paquete seria ademas **imposible** por R3: dpkg
mantiene el bloqueo mientras corre un script de mantenedor, asi que `snap
remove` desde el `postinst` es un interbloqueo. La eliminacion de verdad sigue
correspondiendo a la receta de imagen.

### Un solo icono: `NoDisplay=true`, y por que se quito y se volvio a poner

**Desde la 0.2.1 la sombra lleva `NoDisplay=true` y el usuario ve un solo
«Firefox».** Antes veia dos, los dos con el mismo nombre y los dos abriendo
`/usr/bin/firefox`.

La 0.2.0 lo habia quitado por un motivo real: al instalar el paquete en una
sesion ya iniciada **el icono del dock desaparecia**. GNOME Shell vigila
`/usr/share/applications` por inotify y retira el icono al instante, pero los
favoritos por *defecto* solo los relee al iniciar sesion, asi que el
`gschema.override` que lo repone no actua hasta entonces. Se acepto el duplicado
a cambio, con el argumento de que ya no habia eleccion equivocada posible.

**Ese trato dejo de valer** cuando el producto paso a ser la imagen (D3) y la
imagen dejo de tener Snap: entonces el duplicado no lo sufre quien actualiza su
Ubuntu, lo ve **todo** usuario y siempre. El 2026-08-10 se midio el espacio
entero de arreglos en las dos maquinas, con la biblioteca que dibuja la rejilla
(`MEDICIONES.md` §4.19):

|                  | con Snap                          | sin Snap                          |
|------------------|-----------------------------------|-----------------------------------|
| como estaba      | 2 iconos, id → `/usr/bin/firefox` | 2 iconos, id → `/usr/bin/firefox` |
| `NoDisplay=true` | **1 icono**, id → `/usr/bin/firefox` | **1 icono**, id → `/usr/bin/firefox` |
| sin el fichero   | 2 iconos, id → **`/snap/bin/firefox`** | 1 icono, id → `NINGUNA`      |
| `Hidden=true`    | 1 icono, id → `NINGUNA`           | —                                 |

Lo que decide: **`NoDisplay` oculta pero no desactiva.** Con el puesto el
identificador sigue resolviendo a `/usr/bin/firefox %u`, asi que a quien tuviera
anclado el Firefox del Snap el icono le sigue funcionando y abre el correcto.
**Borrar el fichero reabre el fallo original** en una maquina con Snap, y
`Hidden=true` significa «borrado», no «oculto», y deja el icono anclado muerto.

**Lo que sigue costando, dicho claro:** en la *primera* instalacion sobre una
sesion grafica abierta cuyo dock tenga anclado el identificador del Snap, GNOME
Shell puede dejar de pintar ese icono hasta el siguiente inicio de sesion. Esta
medido que **no** reescribe `favorite-apps` en el dconf del usuario, o sea que la
lista no se corrompe y el icono vuelve al volver a entrar. Si desaparece de la
pantalla o no, no se ha podido medir sin ojos.

`construir-firefox.sh` falla si alguien vuelve a **quitar** `NoDisplay`, y
`instalar-firefox.sh` comprueba las dos cosas por separado: que la entrada
este oculta **y** que el identificador siga resolviendo. Oculta y desactivada no
son lo mismo, y confundirlas es lo que costo la 0.2.0.

### Lo que queda sin resolver

Los marcadores, el historial y las sesiones guardados en el Snap viven en
`~/snap/firefox/common/.mozilla/firefox/`, y el Firefox nativo usa
`~/.config/mozilla/firefox/`. **No los vera.** Migrar el perfil es un problema
aparte, no es configurar un repositorio APT, y este paquete no lo aborda.

Cuidado con esa ruta: **no es `~/.mozilla/firefox/`**, que es lo que uno supone
y ni siquiera existe. El `.deb` de Mozilla usa la ubicacion XDG. Comprobado en
`about:support` → `Directorio de perfil`:

    /home/USUARIO/.config/mozilla/firefox/cmnc3cx7.default-release

### Al verificar

GNOME Shell lee los favoritos al arrancar la sesion: **hay que cerrar sesion y
volver a entrar** antes de mirar el icono. Y en `about:support`, dos filas:

    Binario de la aplicacion   /usr/lib/firefox/firefox     <- correcto
                               /snap/firefox/8735/...       <- es el Snap
    ID de distribucion         (vacio o de Mozilla)         <- correcto
                               canonical-002                <- es el Snap

Que la interfaz salga en espanol **no demuestra nada por si solo**: el Snap
tambien esta en espanol. Primero se confirma el binario, despues el idioma.

## Contenido

| Ruta | Proposito |
|---|---|
| `etc/apt/sources.list.d/mozilla.sources` | Definicion del repositorio, formato deb822 |
| `etc/apt/preferences.d/encina-mozilla` | Anclaje de prioridad 1000 |
| `usr/share/keyrings/packages.mozilla.org.asc` | Clave de firma |

No lleva `postinst`, `prerm` ni `postrm`. No hay nada que ejecutar: los tres
ficheros son declarativos y apt los lee en el siguiente `apt update`.

## La clave de firma

Descargada de `https://packages.mozilla.org/apt/repo-signing-key.gpg` y
verificada contra la huella:

    35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3

El identificador de usuario de la clave es `Artifact Registry Repository Signer
<artifact-registry-repository-signer@google.com>`, no Mozilla, porque Mozilla
sirve el repositorio desde Google Artifact Registry. Es lo esperado: lo que se
verifica es la huella, no el nombre.

`construir-firefox.sh` la vuelve a comprobar en cada construccion y se
detiene sin construir nada si no coincide. La huella esta escrita a mano dentro
del script, no leida del fichero que valida.

La confianza va atada con `Signed-By:`, nunca con `apt-key`. `apt-key` esta
obsoleto y deposita la clave en el llavero global, de modo que esa clave
firmaria como valido cualquier repositorio del sistema.

## El anclaje es la pieza critica

Sin `etc/apt/preferences.d/encina-mozilla`, apt reinstala el Snap de Ubuntu en
la primera actualizacion. Es la causa de fallo mas habitual de este paquete y su
forma es traicionera: el dia de la instalacion todo funciona, y semanas despues
un `apt upgrade` rutinario deshace el trabajo sin decir nada.

El motivo concreto es que el paquete `firefox` de Ubuntu es un deb de transicion
cuya unica funcion es instalar el Snap, y lleva epoch (`1:...`), lo que lo hace
**version mas alta** que cualquier version real de Mozilla. Comparando solo
versiones, Ubuntu gana siempre. La prioridad 1000 decide por origen en vez de
por version, y ademas permite el cambio aunque suponga bajar de numero de
version: por debajo de 1000 apt no haria ese cambio.

Ojo con `Pin: origin packages.mozilla.org`: casa con el **nombre de maquina**
del repositorio, no con el campo `Origin:` del fichero `Release`, que aqui vale
`namespaces/moz-fx-productdelivery-pr-38b5/repositories/mozilla`. Para casar con
ese campo habria que escribir `Pin: release o=...`. Confundir los dos deja el
anclaje sin efecto.

## Construir y probar

    ./scripts/construir-firefox.sh    # huella, reglas duras, build, lintian
    ./scripts/instalar-firefox.sh     # instala, apt update, apt policy, idioma
    ./scripts/verificar-firefox.sh    # full-upgrade x2, idempotencia x5, purga

`09` es la que importa: ejecuta `apt full-upgrade` **dos veces** y comprueba que
Firefox no ha vuelto al Snap ni ha sido degradado a la version de Ubuntu. Es la
unica forma de saber que el anclaje funciona, porque el fallo que busca no da
ningun error cuando ocurre.

Que Firefox arranque **en espanol** no lo puede comprobar ningun script: sale al
final marcado `[OJOS]`.

## lintian

El paquete anula dos tags a proposito, con la justificacion escrita dentro de
`debian/encina-firefox-native.lintian-overrides`:

    package-installs-apt-sources
    package-installs-apt-preferences

Los dos son de visibilidad `error` y los dos son correctos en general: la
eleccion de repositorios y de prioridades es territorio del administrador. Pero
ese es el unico contenido de este paquete; sin esos ficheros el `.deb` queda
vacio. El administrador conserva la ultima palabra porque los dos son
conffiles: dpkg respeta cualquier edicion local y `apt purge` los retira.

El anclaje ademas no admite otra ubicacion: apt solo lee `/etc/apt/preferences`
y `/etc/apt/preferences.d/`. Comprobado en `Lintian/Check/Apt.pm` (lintian
2.117), el tag de `sources` se puede evitar renombrando el paquete binario a
algo acabado en `-apt-source`, pero el del anclaje no tiene excepcion alguna.

Se ven en cualquier momento con `lintian --show-overrides`, y
`construir-firefox.sh` los imprime en cada construccion para que no se
conviertan en un error olvidado.

## Changelog

Con `dch`, nunca a mano. La suite es el codename de Ubuntu destino (`noble`):

    dch -v 0.2.1 --distribution noble "Lo que cambia"

La primera entrada se creo con:

    dch --create --package encina-firefox-native -v 0.1.0 --distribution noble

Cuidado en sesiones ssh no interactivas: sin `DEBEMAIL` y `DEBFULLNAME`
definidos, `dch` construye la direccion a partir del usuario y del nombre de la
maquina y firma el changelog con algo como `jorge@encina-dev`.
