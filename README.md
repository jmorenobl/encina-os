# Encina OS

Paquetería `.deb` sobre Ubuntu LTS para que un usuario español use su escritorio
con la mínima fricción.

Proyecto en desarrollo temprano. Hoy existen **dos paquetes construidos y
probados**: `encina-branding` y `encina-firefox-native`. Lo demás está
especificado, no implementado.

---

## Qué es

Un conjunto de paquetes Debian que se instalan sobre una Ubuntu LTS existente.

**El producto es la paquetería, no la imagen.** Es la decisión estructural del
proyecto (D3 en [ENCINA-OS.md](ENCINA-OS.md)): desacopla el ciclo de Encina del
ciclo de Ubuntu y permite que quien ya tiene Ubuntu instalado —el caso
mayoritario— se beneficie sin reinstalar nada. Una imagen ISO, si llega, será un
envase que instala un metapaquete.

## Qué no es

- **No es un fork de Ubuntu.** No hay árbol de fuentes propio, ni rebase, ni
  parches sobre paquetes ajenos. `ID=ubuntu` se mantiene intacto en
  `/etc/os-release` a propósito (D6): el software de terceros comprueba ese
  campo.
- **No es un tema estético.** Los temas de GTK o de iconos son preferencia
  personal y van, si acaso, en un paquete separado (D7).
- **No hay imagen publicada** y no la habrá en la Etapa A (D5): publicar activa
  la obligación de mantener parches de seguridad para desconocidos.

## Por qué existe

El motivo técnico concreto, y el que fija las prioridades:

> Los navegadores instalados vía Snap o Flatpak aíslan el almacén de
> certificados NSS mediante sandbox, lo que impide el funcionamiento de la firma
> electrónica española.

Ubuntu instala Firefox como Snap por defecto. El resultado es que la firma con
certificado FNMT o con AutoFirma falla, y falla con un error que no menciona el
sandbox por ninguna parte: el usuario ve «no funciona» y no tiene forma de
averiguar por qué. El estado del arte —recogido en [ENCINA-OS.md](ENCINA-OS.md)
§4— es que existen empaquetados alternativos de AutoFirma, todos con un solo
mantenedor, y **ninguna herramienta de diagnóstico**.

Eso dejó de ser una hipótesis el 2026-08-07. Se instaló el `.deb` oficial de
AutoFirma 1.9 en una VM propia y se intentó firmar en una sede real. Resultado:
**cinco fallos encadenados**, ninguno con un mensaje útil en pantalla; el remedio
obvio (instalar Java, que el paquete no declara por culpa de una errata en
`debian/control`) no repara nada; y el remedio que propone el propio fabricante
responde que todo está bien y sale con código 0 sobre un sistema roto. Salidas
literales en [ENCINA-OS.md](ENCINA-OS.md) §4.1.

Encina OS ataca eso en dos etapas:

- **Etapa A** (actual) — sistema base, identidad propia y cadena de construcción
  reproducible. Incluye instalar Firefox de forma nativa, no en Snap.
- **Etapa B** (futura) — integración con la administración española: AutoFirma,
  certificados FNMT, DNIe.

**Un matiz medido, y cuesta reconocerlo:** instalar Firefox nativo no elimina el
obstáculo de la Etapa B, lo **desplaza**. Sigue siendo la decisión correcta —sin
sandbox no hay aislamiento del almacén NSS—, pero AutoFirma 1.9 no sabe encontrar
el perfil de Firefox nativo ni lee su ruta de preferencias, así que sobre un
sistema así falla *más* que sobre una Ubuntu de fábrica. La Etapa B no es un
extra: es la consecuencia necesaria de la Etapa A.

---

## Estado actual

Base: Ubuntu 24.04 LTS (`noble`). Desarrollo sobre arm64 en UTM (D9); los
paquetes son de arquitectura `all`.

### Etapa A

| Fase | Contenido | Estado |
|---|---|---|
| A0 | Nombre, licencia, repositorio git | **Hecho** — `LICENSE` con el texto oficial de la EUPL-1.2 verificado contra EUR-Lex |
| A1 | `encina-branding` construido, probado y en CI | **Hecho** — v0.1.6 verificada en VM el 2026-08-07 |
| A2 | `encina-firefox-native` (repo de Mozilla + clave + anclaje) | **Hecho** — v0.2.0, 7/7 verificadas en VM el 2026-08-07, la última mirando la pantalla |
| A3 | ~~`encina-locale-es`~~ | **Suprimida el 2026-08-07.** Se midió antes de abrirla y no había paquete que escribir (ver abajo) |
| A4–A6 | `encina-meta` y repo APT propio, `autoinstall.yaml`, imagen propia | Fuera de alcance ahora ([AGENTS.md](AGENTS.md) §8). Nada de esto existe |
| B1 | `encina-doctor` — diagnóstico de la firma electrónica | **Abierta el 2026-08-07, solo especificada.** Contrato en [AGENTS.md](AGENTS.md) §6. **No hay código**, y es deliberado |

**Por qué no habrá `encina-locale-es`.** En una Ubuntu 24.04 instalada en español,
`check-language-support -l es` devuelve vacío: locale, teclado, diccionarios,
fuentes y traducciones ya están. Y no es casualidad — el instalador de Ubuntu
ejecuta ese mismo comando al final de la instalación e instala lo que devuelve.
El paquete habría tenido cero ficheros. Lo poco que Ubuntu no cubre (la l10n de
aplicaciones instaladas *después*) son tres `Depends:` de `encina-meta`. Detalle
y salidas literales en [ENCINA-OS.md](ENCINA-OS.md) §6.1; decisión cerrada D12.

Todo lo listado en [AGENTS.md](AGENTS.md) §8 —**reparar** AutoFirma, DNIe,
PKCS#11, `encina-meta`, imagen ISO, temas de GTK o iconos, cualquier GUI— **no
está implementado ni debe prepararse**. Si una tarea parece exigirlo, la
instrucción es detenerse y preguntar.

La única excepción, desde el 2026-08-07, es **diagnosticar** AutoFirma: es la
fase B1, y `encina doctor` lee y no escribe. La decisión D13 sigue vigente sin
cambios — ninguna de las dos barreras medidas se arregla desde un paquete de la
Etapa A, ni desde el propio `encina-doctor`.

### `encina-branding` 0.1.6

Identidad visual del sistema: fondos claro y oscuro, logotipo, tema de arranque
de Plymouth y personalización de la pantalla de GDM. Todo como predeterminados
del sistema vía `gschema.override` y perfiles de dconf, nunca `/etc/skel`, de
modo que los usuarios creados después de instalar también los heredan.

Verificado en VM Ubuntu 24.04 arm64: **10/10 comprobaciones** de la definición
de terminado ([AGENTS.md](AGENTS.md) §4.4), cuatro de ellas mirando la pantalla
—splash de arranque, logotipo de GDM y fondo de escritorio no se pueden
comprobar por script—. Llegar ahí costó seis versiones de corrección (0.1.1 a
0.1.6), cuatro de ellas fallos silenciosos: fallos que no producían ningún error
en ninguna parte y solo se manifestaban al reiniciar o en una sesión gráfica
real.

Detalle de uso del paquete:
[debian-packages/encina-branding/README.md](debian-packages/encina-branding/README.md).

### `encina-firefox-native` 0.2.0

Configura el repositorio APT oficial de Mozilla, su clave de firma y el anclaje
de prioridad, para que Firefox se instale como `.deb` nativo y no como Snap. Es
condición necesaria para la Etapa B: el sandbox del Snap aísla el almacén NSS e
impide que funcione la firma electrónica.

**Necesaria, pero no suficiente**, y está medido (§4.1 de
[ENCINA-OS.md](ENCINA-OS.md)): AutoFirma 1.9 no reconoce el perfil del Firefox
nativo —que vive en `~/.config/mozilla/firefox/`, no en `~/.mozilla/firefox/`— ni
lee `/etc/firefox/pref/`, donde deja sus preferencias. Quitar el Snap, que es lo
que hará la imagen propia, lo deja sin ningún perfil que reconocer. Cerrar ese
hueco es trabajo de la Etapa B, no de este paquete.

**No instala Firefox, no instala el paquete de idioma y no elimina el Snap.**
Ninguna de las tres cosas es un olvido. No declara `Depends:` sobre `firefox`
porque ese paquete vive en el repositorio que configura este, que no existe
hasta que este se instala (R10); y borrar el Snap se lleva por delante
marcadores y sesiones, así que corresponde a la receta de imagen (R4).

Verificado en VM Ubuntu 24.04 arm64: **7/7 comprobaciones** de la definición de
terminado ([AGENTS.md](AGENTS.md) §5.5). La última —que Firefox arranque en
español— no la puede comprobar ningún script, y se confirmó en `about:support`
mirando el binario (`/usr/lib/firefox/firefox-bin`) y el ID de distribución
(`mozilla-deb`) **antes** que el idioma: el Snap también está en español, así
que ver la interfaz traducida no demuestra nada por sí solo.

**El paquete también hace que el icono abra el Firefox correcto**, y esa parte
no estaba en la especificación original. Instalar el repositorio y Firefox
nativo dejaba el sistema perfecto y el usuario seguía abriendo el Snap, porque
conviven dos lanzadores llamados «Firefox» con identificadores distintos y
Ubuntu ancla al dock el del Snap. Y no se notaba: el Snap también está en
español, así que la pantalla parecía la correcta.

R4 delegaba esto en la receta de imagen, y para una máquina instalada desde una
imagen es correcto —allí el Snap no existe—. Pero **D3 dice que el producto es
la paquetería**, y quien instala el `.deb` sobre su Ubuntu ya tiene el Snap y no
va a ejecutar ninguna receta de imagen. Se resuelve sombreando el lanzador del
Snap con otro del mismo identificador que redirige al nativo, ganando por
precedencia de `XDG_DATA_DIRS`. **No se elimina nada:** el Snap sigue instalado,
su perfil intacto, y `apt purge` devuelve su lanzador —cosa que
`09-firefox-verificar.sh` comprueba explícitamente—.

La comprobación crítica es el anclaje, porque su fallo es silencioso: sin él,
apt reinstala el Snap en la primera actualización y no te enteras hasta
entonces. Dos resultados la sostienen:

- `apt full-upgrade` ejecutado hasta que **movió 15 paquetes de verdad**, sin
  tocar Firefox. Las dos primeras vueltas no movieron ninguno porque el sistema
  ya estaba al día, y el script lo dice en vez de dar el `[OK]` por bueno.
- Al purgar el paquete, el candidato de `firefox` vuelve solo al deb de
  transición de Ubuntu (`1:1snap1-0ubuntu5`, el que instala el Snap). La única
  diferencia entre las dos situaciones es este paquete.

Detalle de uso:
[debian-packages/encina-firefox-native/README.md](debian-packages/encina-firefox-native/README.md).

### Integración continua

`.github/workflows/build.yml` construye y valida **los dos paquetes** en
`ubuntu-latest`, con una entrada de matriz por paquete que ejecuta el mismo
script que se usa en local (`03-construir.sh` y `07-firefox-construir.sh`), y
sube cada `.deb` como artefacto. No hay firma de repositorio: la clave de Encina
no debe existir en el runner.

Estado: **verde por `push` y por `workflow_dispatch`**, comprobado sobre
`9a673b8`.

El disparo por `push` funciona, pero su entrega fue irregular durante la
incidencia de GitHub Actions del 2026-08-06 (webhooks throttled): la ejecución
del push de `9a673b8` tardó **doce minutos** en crearse, y el push de `ffbb7fd`
no llegó a generar ninguna. Si tras un push no aparece ejecución, el flujo
probablemente no tiene nada roto: espera y, si hace falta, lánzalo a mano con
`workflow_dispatch`.

El repositorio (`jmorenobl/encina-os`) es **privado**.

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

Once scripts, en orden. Cada uno termina diciendo cuál viene después y
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
| `diario.sh "texto"` | Añade una entrada fechada a `DIARIO.md` y hace commit |

Del 00 al 06 son de A1 y de uso común; del 07 al 09, de A2. Los de A2 son
scripts aparte y no una generalización de 03/04/05 a propósito: aquellos están
validados contra `encina-branding` y no se tocan.

Ruta corta, con el entorno ya preparado:

```
./scripts/03-construir.sh     # build + lintian + reglas duras
./scripts/04-instalar.sh      # instalar y comprobar en caliente
sudo reboot
./scripts/05-verificar.sh     # las pruebas que de verdad importan

./scripts/07-firefox-construir.sh
./scripts/08-firefox-instalar.sh
./scripts/09-firefox-verificar.sh    # full-upgrade x2: la prueba del anclaje
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
GDM, el fondo del escritorio y que Firefox arranque en español hay que mirarlos.

### Reglas duras

Diez invariantes (R1–R10) recogidas en [AGENTS.md](AGENTS.md) §2, desde «nada de
`/etc/skel`» hasta «sin dependencias circulares de repositorio».
`03-construir.sh` comprueba estáticamente las que puede —R1, R2, R3, R6, R7, el
callback de contraseña de LUKS, la presencia de `picture-uri-dark` y la línea
duplicada de `GRUB_DISTRIBUTOR`— antes de dejar construir nada. Son justo los
fallos que en caliente resultan invisibles y solo aparecen al reiniciar, o solo
en máquinas con disco cifrado.

`07-firefox-construir.sh` hace lo propio con las que aplican a A2 —R3, R4, R10—
y añade la que puede detener la fase entera: la huella de la clave de firma de
Mozilla. Si no coincide con `35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3`, no
construye nada y manda avisar.

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
scripts/          # los once scripts + lib.sh
.github/workflows/build.yml
```

Los artefactos de construcción (`.deb`, `.buildinfo`, `.changes`) no se
versionan. El código y los activos sí.

## Documentación

| Documento | Para qué |
|---|---|
| [ENCINA-OS.md](ENCINA-OS.md) | Documento maestro: visión, decisiones cerradas, hoja de ruta, trampas conocidas. Si los documentos se contradicen, manda este |
| [AGENTS.md](AGENTS.md) | Fuente de verdad de la implementación: reglas duras, convenciones y especificación de los paquetes, con su definición de terminado |
| [SCRIPTS.md](SCRIPTS.md) | Qué hace cada script y en qué orden |
| [RECETA-A1-encina-branding.md](RECETA-A1-encina-branding.md) | Guía paso a paso de la fase A1, por sesiones |
| [DIARIO.md](DIARIO.md) | Dónde se quedó el trabajo |

## Licencia

EUPL-1.2. El fichero [LICENSE](LICENSE) contiene el **texto oficial completo**:
los quince artículos y el Apéndice de licencias compatibles.

Verificado carácter a carácter contra la publicación de la Unión Europea en
EUR-Lex —la EUPL v1.2 es el anexo de la Decisión de Ejecución (UE) 2017/863—
ignorando solo espaciado y comillas tipográficas: 10.956 caracteres idénticos.

Ningún activo gráfico de terceros forma parte del proyecto: ni marca de Canonical
o Ubuntu, ni tipografías propietarias, ni iconos que imiten a otros sistemas (R8).

El único fichero de terceros que se distribuye es la **clave pública de firma
del repositorio APT de Mozilla**, dentro de `encina-firefox-native`. Se incluye
íntegra y sin modificar, verificada contra su huella, y está declarada como tal
en el `debian/copyright` de ese paquete, que es lo que R8 exige. Una clave
pública se publica precisamente para ser copiada: es el único modo de que sirva
para verificar firmas.
