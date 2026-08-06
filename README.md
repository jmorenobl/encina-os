# Encina OS

Paquetería `.deb` sobre Ubuntu LTS para que un usuario español use su escritorio
con la mínima fricción.

Proyecto en desarrollo temprano. Hoy existe **un solo paquete construido y
probado**: `encina-branding`. Lo demás está especificado, no implementado.

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

Encina OS ataca eso en dos etapas:

- **Etapa A** (actual) — sistema base, identidad propia y cadena de construcción
  reproducible. Incluye instalar Firefox de forma nativa, no en Snap, lo que
  elimina por adelantado el obstáculo principal de la etapa siguiente.
- **Etapa B** (futura) — integración con la administración española: AutoFirma,
  certificados FNMT, DNIe.

---

## Estado actual

Base: Ubuntu 24.04 LTS (`noble`). Desarrollo sobre arm64 en UTM (D9); los
paquetes son de arquitectura `all`.

### Etapa A

| Fase | Contenido | Estado |
|---|---|---|
| A0 | Nombre, licencia, repositorio git | Hecho, salvo el texto de la licencia (ver [Licencia](#licencia)) |
| A1 | `encina-branding` construido, probado y en CI | **Hecho** — v0.1.6 verificada en VM el 2026-08-07 |
| A2 | `encina-firefox-native` (repo de Mozilla + clave + anclaje) | Especificado en [AGENTS.md](AGENTS.md) §5. **Sin empezar** |
| A3–A6 | `encina-locale-es`, `encina-meta` y repo APT propio, `autoinstall.yaml`, imagen propia | Fuera de alcance ahora ([AGENTS.md](AGENTS.md) §7). Nada de esto existe |

Todo lo listado en [AGENTS.md](AGENTS.md) §7 —AutoFirma, DNIe, PKCS#11,
`encina-locale-es`, `encina-meta`, imagen ISO, temas de GTK o iconos, cualquier
GUI— **no está implementado ni debe prepararse**. Si una tarea parece exigirlo,
la instrucción es detenerse y preguntar.

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

### Integración continua

`.github/workflows/build.yml` construye y valida el paquete en `ubuntu-latest`,
ejecutando el mismo `scripts/03-construir.sh` que se usa en local, y sube el
`.deb` como artefacto. No hay firma de repositorio: la clave de Encina no debe
existir en el runner.

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

Ocho scripts, en orden. Cada uno termina diciendo cuál viene después y
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
| `diario.sh "texto"` | Añade una entrada fechada a `DIARIO.md` y hace commit |

Ruta corta, con el entorno ya preparado:

```
./scripts/03-construir.sh     # build + lintian + reglas duras
./scripts/04-instalar.sh      # instalar y comprobar en caliente
sudo reboot
./scripts/05-verificar.sh     # las pruebas que de verdad importan
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
GDM y el fondo del escritorio hay que mirarlos.

### Reglas duras

Diez invariantes (R1–R10) recogidas en [AGENTS.md](AGENTS.md) §2, desde «nada de
`/etc/skel`» hasta «sin dependencias circulares de repositorio».
`03-construir.sh` comprueba estáticamente las que puede —R1, R2, R3, R6, R7, el
callback de contraseña de LUKS, la presencia de `picture-uri-dark` y la línea
duplicada de `GRUB_DISTRIBUTOR`— antes de dejar construir nada. Son justo los
fallos que en caliente resultan invisibles y solo aparecen al reiniciar, o solo
en máquinas con disco cifrado.

---

## Estructura del repositorio

```
debian-packages/
  encina-branding/
    debian/       # changelog (con dch, nunca a mano), control, copyright,
                  # rules, postinst, prerm, postrm
    src/          # árbol que se copia tal cual a la raíz del sistema
scripts/          # los ocho scripts + lib.sh
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

EUPL-1.2.

⚠️ El fichero [LICENSE](LICENSE) es **un marcador de posición**: contiene el
identificador y una nota, no el texto oficial. Falta sustituirlo por el texto de
la European Union Public Licence v1.2 publicado en joinup.ec.europa.eu.

Ningún activo de terceros forma parte del proyecto: ni marca de Canonical o
Ubuntu, ni tipografías propietarias, ni iconos que imiten a otros sistemas (R8).
