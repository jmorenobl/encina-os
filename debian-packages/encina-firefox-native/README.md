# encina-firefox-native

Configura el repositorio APT oficial de Mozilla, su clave de firma y el anclaje
de prioridad, para que Firefox se pueda instalar como paquete `.deb` nativo en
lugar de como Snap.

El motivo no es estetico: los navegadores instalados via Snap o Flatpak aislan
el almacen de certificados NSS mediante sandbox, y eso impide que funcione la
firma electronica espanola. Resolverlo aqui quita por adelantado el obstaculo
principal de la Etapa B.

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

Es lo que hace `08-firefox-instalar.sh`. Una persona siguiendo el orden de
arriba no necesita la opcion.

Si Firefox arranca en ingles, falta el paquete de idioma o el locale del
sistema no es espanol; Firefox elige el idioma a partir del locale de la sesion.

## El icono del escritorio puede seguir abriendo el Snap

Esto sorprende y conviene saberlo antes de tropezar. Con el paquete instalado,
Firefox nativo instalado y todo funcionando, **hacer clic en el icono del dock
puede seguir abriendo el Snap.** No es un fallo del paquete: es que conviven dos
lanzadores llamados «Firefox» y ninguno pisa al otro.

| Fichero | `Exec=` | Quien lo pone |
|---|---|---|
| `/usr/share/applications/firefox.desktop` | `firefox %u` → `/usr/lib/firefox/firefox` | el deb de Mozilla |
| `/var/lib/snapd/desktop/applications/firefox_firefox.desktop` | `/snap/bin/firefox %u` | el Snap |

Los valores por defecto del sistema si apuntan al nativo: `xdg-settings get
default-web-browser` devuelve `firefox.desktop` y la alternativa
`x-www-browser` apunta a `/usr/bin/firefox`. Lo que queda apuntando al Snap es
el icono **anclado** al dock, porque Ubuntu lo fijo al instalar el sistema por
el identificador del Snap:

    $ gsettings get org.gnome.shell favorite-apps
    [..., 'firefox_firefox.desktop', ...]

Este paquete no lo cambia, y no por descuido: modificar los favoritos del
escritorio no es configurar un repositorio APT, y eliminar el Snap esta
prohibido (R4). Corresponde a `encina-meta` o a la receta de imagen.

**Consecuencia practica al verificar:** para mirar el Firefox nativo hay que
lanzarlo a mano desde una terminal.

    /usr/bin/firefox

Y en `about:support`, comprobar dos filas, no una:

    Binario de la aplicacion   /usr/lib/firefox/firefox     <- correcto
                               /snap/firefox/8735/...       <- es el Snap
    ID de distribucion         (vacio o de Mozilla)         <- correcto
                               canonical-002                <- es el Snap

Que la interfaz salga en espanol **no demuestra nada por si solo**: el Snap
tambien esta en espanol. Primero se confirma el binario, despues el idioma.

`08-firefox-instalar.sh` detecta esta situacion y avisa.

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

`07-firefox-construir.sh` la vuelve a comprobar en cada construccion y se
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

    ./scripts/07-firefox-construir.sh    # huella, reglas duras, build, lintian
    ./scripts/08-firefox-instalar.sh     # instala, apt update, apt policy, idioma
    ./scripts/09-firefox-verificar.sh    # full-upgrade x2, idempotencia x5, purga

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
`07-firefox-construir.sh` los imprime en cada construccion para que no se
conviertan en un error olvidado.

## Changelog

Con `dch`, nunca a mano. La suite es el codename de Ubuntu destino (`noble`):

    dch --create --package encina-firefox-native -v 0.1.0 --distribution noble

Cuidado en sesiones ssh no interactivas: sin `DEBEMAIL` y `DEBFULLNAME`
definidos, `dch` construye la direccion a partir del usuario y del nombre de la
maquina y firma el changelog con algo como `jorge@encina-dev`.
