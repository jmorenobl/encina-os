<p align="center">
  <img src="assets/banner.png" alt="Encina OS — Ubuntu con la firma electrónica española lista de fábrica" width="100%">
</p>

<p align="center">
  <a href="https://github.com/jmorenobl/encina-os/actions/workflows/build.yml"><img src="https://github.com/jmorenobl/encina-os/actions/workflows/build.yml/badge.svg" alt="Estado de la construcción"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/licencia-EUPL--1.2-3A664E" alt="Licencia EUPL-1.2"></a>
  <img src="https://img.shields.io/badge/base-Ubuntu%2024.04%20LTS-A78B75" alt="Base: Ubuntu 24.04 LTS">
  <img src="https://img.shields.io/badge/arquitectura-arm64-A78B75" alt="Arquitectura: arm64">
  <img src="https://img.shields.io/badge/estado-en%20construcci%C3%B3n-D6BFA0" alt="Estado: en construcción">
</p>

<p align="center">
  <sub><b>Proyecto independiente.</b> Sin relación con la Administración General del Estado, la FNMT ni Canonical.<br>
  Derivado de Ubuntu; ni publicado ni avalado por Canonical Ltd.</sub>
</p>

---

Una distribución de escritorio basada en Ubuntu LTS, pensada para que un usuario
español la use con la mínima fricción — y en particular **para que la firma
electrónica con la administración funcione sin que nadie tenga que entender por
qué no funcionaba**.

Se construyen paquetes `.deb`; lo que se entrega es Ubuntu LTS con esos paquetes
aplicados. La base no se remasteriza: se hereda de Ubuntu toda la capa de
actualizaciones y aplicaciones.

**Estado: en construcción, y con el problema principal resuelto y medido.** El
7 de agosto de 2026 salió la primera firma real de extremo a extremo —certificado
de la FNMT, sede real, mirada en pantalla—. Lo que falta no es averiguar cómo se
hace, sino empaquetarlo y entregarlo.

---

## Qué es

- **Una distribución**, no un fork: `ID=ubuntu` intacto, repositorios de Ubuntu
  intactos, `ubuntu-desktop-minimal` como base.
- **Cuatro paquetes**, tres en este repositorio y uno en otro.
- **Reproducible y declarativo.** Todo en git; nada editado a mano dentro de un
  chroot.

## Qué no es

- **No es una herramienta que instales sobre tu Ubuntu.** Lo que se entrega es el
  sistema. Los `.deb` son ingredientes, no producto.
- **No hay imagen publicada todavía.** Hoy solo existe para arm64, que es lo
  único que el autor puede probar, y publicar una imagen que casi nadie puede
  arrancar activa obligaciones de mantenimiento sin dar nada a cambio.
- **No incluye estética de terceros.** Ni marca de Canonical, ni tipografías
  propietarias, ni iconos que imiten a otros sistemas.
- **No pretende ser un proyecto grande.** Es de una sola persona, y crece por
  incrementos que dejan un sistema usable cada uno.

## Por qué existe

Firmar electrónicamente en una Ubuntu recién instalada **no funciona**, y falla
de la peor manera posible: en silencio. AutoFirma se instala «con éxito» estando
roto entero, la herramienta de reparación del propio fabricante declara sano un
sistema roto, y al pulsar «Firmar» no ocurre absolutamente nada — sin diálogo,
sin error, sin una línea en el registro del sistema.

Medido en máquina propia, no citado de nadie: **son seis obstáculos encadenados**,
cada uno capaz de esconder al siguiente.

| # | Obstáculo | Quién lo cierra en Encina OS |
|---|---|---|
| B1a | Las preferencias del esquema `afirma:` están donde la compilación de Mozilla no las lee | `autofirma 1.9.1+encina1` |
| B1b | La preferencia con la que AutoFirma lanza el programa ya no existe en Firefox 153 | `autofirma 1.9.1+encina1` |
| B2 | El certificado del canal seguro se instala en el perfil de navegador equivocado | `autofirma 1.9.1+encina1` |
| B3 | Dentro del Snap, Firefox **no ve** el programa que debería abrir | `encina-firefox-native`, y quitar el Snap en la imagen |
| B4 | AutoFirma busca tu certificado en el perfil del Snap, que está vacío | `autofirma 1.9.1+encina1`, y quitar el Snap lo cierra solo |
| B6 | Las bibliotecas NSS no se encuentran fuera de x86 | `autofirma 1.9.1+encina1` |

Hay un séptimo, B5, que **no lo puede cerrar nadie desde el equipo**: algunas
sedes electrónicas bloquean con su propia política de seguridad el `iframe` que
su propio JavaScript necesita.

Las salidas literales de todas estas mediciones están en
[MEDICIONES.md](MEDICIONES.md).

---

## Estado actual

| Pieza | Estado |
|---|---|
| `encina-branding` | **Terminado.** v0.1.6, identidad visual: fondos, tema de Plymouth, logotipo de GDM |
| `encina-firefox-native` | **Terminado.** v0.2.0, Firefox de Mozilla en lugar del Snap, con repositorio, clave verificada por huella y anclaje |
| `autofirma 1.9.1+encina1` | **Terminado y con el primer positivo de extremo a extremo.** En un repositorio aparte, con CI verde en amd64 y arm64 |
| `encina-meta` | **En curso.** Un solo nombre que declara el conjunto. Escrito y construido; pendiente de verificar en VM. Un nombre no es una sola orden: la instalación son tres órdenes, y el motivo está medido (`MEDICIONES.md` §4.10) |
| Instalación desatendida | Sin abrir |
| Imagen | Sin abrir |

**Arquitectura: solo arm64 por ahora.** Es lo único que se puede medir con el
equipo disponible, y en este proyecto lo que no se mide no se da por bueno. La
integración continua construye en amd64 porque el runner lo es, pero eso no es
lo mismo que declararlo probado.

### El AutoFirma corregido, y por qué es temporal

El `.deb` oficial de AutoFirma tiene errores medidos: un campo mal escrito que
deja el entorno de ejecución de Java sin declarar, un `postinst` que declara
éxito con todo roto, el certificado del canal seguro en el perfil equivocado, y
rutas de bibliotecas escritas a mano que solo cubren x86.

Las correcciones se han propuesto al **repositorio oficial**, que es el único
sitio desde el que llegan a todo el mundo. Mientras no las incorporen, Encina OS
usa su propio paquete construido desde las fuentes oficiales.

**Ese paquete es un puente y se retira**, y la condición no es una fecha: es que
el `.deb` que publica la Administración pase la misma batería de comprobaciones
que pasa el nuestro.

---

## Cómo construir y probar

### Entorno

Los paquetes se construyen y se prueban **en una VM Ubuntu**, no en el Mac. El
entorno del autor es un repositorio en macOS montado por 9p dentro de una VM
Ubuntu 24.04 arm64 en UTM, de modo que se edita en el Mac y se ejecuta en la VM:

```
ssh USUARIO@IP-DE-TU-VM "cd /mnt/encina && ENCINA_REPO=/mnt/encina ./scripts/03-construir.sh"
```

`ENCINA_REPO` indica dónde está el repositorio; su valor por defecto es
`~/encina`. Los scripts no asumen nada más sobre la máquina.

### Scripts

Catorce scripts, en orden. Cada uno termina diciendo cuál viene después y
ninguno da nada por bueno sin comprobarlo. Detalle en [SCRIPTS.md](SCRIPTS.md).

| Script | Qué hace |
|---|---|
| `00-entorno.sh "Nombre" "correo"` | Instala herramientas de empaquetado, configura git y `DEBEMAIL` |
| `01-repo.sh` | Coloca el esqueleto del paquete y verifica el árbol de ficheros |
| `02-activos.sh` | Genera los activos gráficos mínimos y verifica sus formatos |
| `03-construir.sh` | Comprueba las reglas duras, construye el `.deb` y pasa `lintian` |
| `04-instalar.sh` | Instala y comprueba todo lo verificable sin reiniciar |
| `05-verificar.sh` | Usuario nuevo, idempotencia ×5, purga |
| `06-ci.sh` | Flujo de GitHub Actions y repositorio remoto |
| `07-firefox-construir.sh` | Huella de la clave de Mozilla, reglas duras, `.deb` y `lintian` |
| `08-firefox-instalar.sh` | Instala, `apt update`, anclaje, idioma y Firefox nativo |
| `09-firefox-verificar.sh` | `full-upgrade` ×2, idempotencia ×5, purga |
| `10-meta-construir.sh` | Reglas duras de `encina-meta`, `.deb` y `lintian` |
| `11-meta-instalar.sh` | La secuencia de tres órdenes, comprobada paso a paso |
| `12-meta-verificar.sh` | Idempotencia ×5, purga y `autoremove` |
| `diario.sh "texto"` | Añade una entrada fechada a `DIARIO.md` y hace commit |

Del 00 al 06 sirven para `encina-branding` y son de uso común; del 07 al 09, para
`encina-firefox-native`; del 10 al 12, para `encina-meta`. Los seis últimos son
scripts aparte y no una generalización de 03/04/05 a propósito: aquellos están
validados y no se tocan.

Ruta corta, con el entorno ya preparado:

```
./scripts/03-construir.sh     # build + lintian + reglas duras
./scripts/04-instalar.sh      # instalar y comprobar en caliente
sudo reboot
./scripts/05-verificar.sh     # las pruebas que de verdad importan

./scripts/07-firefox-construir.sh
./scripts/08-firefox-instalar.sh
./scripts/09-firefox-verificar.sh    # full-upgrade x2: la prueba del anclaje

./scripts/10-meta-construir.sh
./scripts/11-meta-instalar.sh        # las tres ordenes, comprobadas una a una
./scripts/12-meta-verificar.sh
```

Todos son idempotentes. `02-activos.sh` no sobrescribe activos existentes salvo
con `--forzar`, para que el día que estén los definitivos no los machaque un
script.

### Cómo leer la salida

```
[OK]     comprobado y correcto
[FALLO]  comprobado e incorrecto, con la salida literal del comando
[AVISO]  algo que mirar, no bloquea
[OMIT]   no se ha comprobado (no lo des por bueno)
[OJOS]   solo lo puedes verificar tú mirando la pantalla
```

Un solo `[FALLO]` hace que el script salga con código distinto de cero. Las
marcas `[OJOS]` no cuentan como aprobadas: el splash de arranque, el logotipo de
GDM, el fondo del escritorio, que Firefox arranque en español y que salga una
firma real hay que mirarlos.

**Y la regla que ha salido más cara de aprender:** una comprobación que pasa no
vale nada si no sabes contra qué ha pasado. Cuando una dé `[OK]`, comprueba que
habría dado `[FALLO]` de haber estado mal. [SCRIPTS.md](SCRIPTS.md) recoge siete
trampas reales, todas encontradas en este proyecto, y las siete producen falsos
negativos o comprobaciones que no comprueban nada.

### Reglas duras

Diez invariantes (R1–R10) recogidas en [AGENTS.md](AGENTS.md) §2, desde «nada de
`/etc/skel`» hasta «sin dependencias circulares de repositorio».
`03-construir.sh` comprueba estáticamente las que puede —R1, R2, R3, R6, R7, el
callback de contraseña de LUKS, la presencia de `picture-uri-dark` y la línea
duplicada de `GRUB_DISTRIBUTOR`— antes de dejar construir nada. Son justo los
fallos que en caliente resultan invisibles y solo aparecen al reiniciar, o solo
en máquinas con disco cifrado.

`07-firefox-construir.sh` hace lo propio con las que aplican a Firefox nativo
—R3, R4, R10— y añade la que puede detener la fase entera: la huella de la clave
de firma de Mozilla. Si no coincide con
`35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3`, no construye nada y manda avisar.

---

## Estructura del repositorio

```
debian-packages/
  encina-branding/
    debian/       # changelog (con dch, nunca a mano), control, copyright,
                  # rules, postinst, prerm, postrm
    src/          # árbol que se copia tal cual a la raíz del sistema
  encina-firefox-native/
    debian/       # changelog, control, copyright, rules, lintian-overrides
                  # (sin scripts de mantenedor: no hay nada que ejecutar)
    src/          # mozilla.sources, encina-mozilla y la clave de firma
  encina-meta/
    debian/       # solo control, rules, copyright y changelog.
                  # Ni src/, ni scripts de mantenedor, ni overrides de lintian:
                  # un metapaquete con contenido son dos paquetes mal separados
scripts/          # los catorce scripts + lib.sh
.github/workflows/build.yml
```

Los artefactos de construcción (`.deb`, `.buildinfo`, `.changes`) no se
versionan. El código y los activos sí.

## Identidad visual

<p align="center">
  <img src="assets/identidad.png" alt="Guía de identidad de Encina OS: logotipo, paleta de colores y fondo de pantalla" width="100%">
</p>

Una encina cuya copa y raíces son una red de nodos: el árbol de la dehesa
española y la red de confianza que hace posible una firma electrónica, que son
las dos cosas de las que va el proyecto.

| Color | Hex |
|---|---|
| Verde encina | `#3A664E` |
| Tierra íbera | `#A78B75` |
| Arcilla | `#D6BFA0` |
| Gris pizarra | `#E6E8E6` |
| Blanco roto | `#FFFFFF` |

**Procedencia de los activos**, que R8 exige declarar:

- **Logotipo y banner:** generados con Google Gemini a partir de indicaciones
  propias. Ninguna marca de terceros forma parte de ellos.
- **Fondos de pantalla:** fotografías de **Amanda Anusane** publicadas en
  Unsplash bajo la Unsplash License. Es una licencia permisiva pero **no es una
  licencia libre al uso** —prohíbe vender copias sin modificar y compilar las
  fotos para replicar un servicio competidor—, así que se declara como párrafo
  propio en el `debian/copyright` del paquete que las distribuya. La atribución
  no es obligatoria; se hace igualmente.

## Documentación

| Documento | Para qué |
|---|---|
| [ENCINA-OS.md](ENCINA-OS.md) | Documento maestro: qué es, decisiones cerradas, hoja de ruta y siguiente acción. Si los documentos se contradicen, manda este |
| [AGENTS.md](AGENTS.md) | Fuente de verdad de la implementación: reglas duras, convenciones y especificación de cada paquete, con su definición de terminado |
| [MEDICIONES.md](MEDICIONES.md) | Lo medido, con las salidas literales de los comandos. Antes de investigar algo, mirar aquí |
| [SCRIPTS.md](SCRIPTS.md) | Qué hace cada script, en qué orden, y las siete trampas |
| [DIARIO.md](DIARIO.md) | Dónde se quedó el trabajo |

## Licencia

EUPL-1.2. El fichero [LICENSE](LICENSE) contiene el **texto oficial completo**:
los quince artículos y el Apéndice de licencias compatibles.

Verificado carácter a carácter contra la publicación de la Unión Europea en
EUR-Lex —la EUPL v1.2 es el anexo de la Decisión de Ejecución (UE) 2017/863—
ignorando solo espaciado y comillas tipográficas: 10.956 caracteres idénticos.

Ninguna **marca** de terceros forma parte del proyecto: ni logotipos de Canonical
o Ubuntu, ni emblemas institucionales, ni tipografías propietarias, ni iconos que
imiten a otros sistemas (R8). Los activos gráficos que **sí** vienen de fuera son
las fotografías de los fondos de pantalla, con su licencia y su autoría
declaradas arriba, que es lo que R8 permite y exige.

El único fichero de terceros que se distribuye es la **clave pública de firma
del repositorio APT de Mozilla**, dentro de `encina-firefox-native`. Se incluye
íntegra y sin modificar, verificada contra su huella, y está declarada como tal
en el `debian/copyright` de ese paquete, que es lo que R8 exige. Una clave
pública se publica precisamente para ser copiada: es el único modo de que sirva
para verificar firmas.

AutoFirma es software libre de la Administración General del Estado (GPL 2+ y
EUPL 1.1) y es redistribuible. El paquete corregido se construye desde sus
fuentes oficiales y las correcciones están propuestas al repositorio de origen.
