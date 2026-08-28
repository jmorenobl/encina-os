# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**Todo el proyecto está en español.** Documentos, mensajes de los scripts,
commits y comentarios del código. Escribe en español.

## Antes de nada: `AGENTS.md` manda

Este fichero es solo el mapa. **Las instrucciones ejecutables están en
[AGENTS.md](AGENTS.md)** —reglas duras R1–R10, convenciones de empaquetado y la
«definición de terminado» de cada paquete y de cada incremento, casilla a
casilla— y no se resumen aquí porque un resumen se desactualiza y el original
no.

Orden de lectura, que no es arbitrario:

| Cuándo | Qué |
|---|---|
| Siempre primero | [ENCINA-OS.md](ENCINA-OS.md) §7 «Empieza aquí» — la tarea en curso, y solo esa |
| Al lanzar trabajo de implementación | [AGENTS.md](AGENTS.md) — reglas y definiciones de terminado |
| **Antes de investigar cualquier cosa** | [mediciones/LEEME.md](mediciones/LEEME.md) — la tabla de vigencia y el índice; cada sección es un fichero de [mediciones/](mediciones/) y se sigue citando `MEDICIONES.md §4.NN` (el [MEDICIONES.md](MEDICIONES.md) de la raíz es sólo el puntero desde la tarea 4, 2026-08-28). Casi siempre ya está medido, con la salida literal. Su §9 es la tabla de trampas conocidas |
| Antes de ejecutar nada en una VM | [SCRIPTS.md](SCRIPTS.md) — qué hace cada guion y sus ~60 trampas, y desde el 2026-08-28 **[TRAMPAS.md](TRAMPAS.md)**: una fila por trampa numerada, con a qué guion o fase aplica |
| Qué queda por hacer | [TAREAS.md](TAREAS.md) → [tareas/](tareas/); y lo que sólo puede mirar Jorge, en [tareas/ojos.md](tareas/ojos.md) |
| Al retomar tras unos días | [DIARIO.md](DIARIO.md) |

Si dos documentos se contradicen, manda `ENCINA-OS.md`.

## Comandos

**Desde el 2026-08-28 hay `make`** (tarea 6 de la refactorización), y es la
orden que corre la CI; los guiones de abajo siguen siendo lo que hace el trabajo:

```bash
make bancos            # los bancos que no necesitan máquina ni ISO + shellcheck (segundos; es el job «bancos» de la CI)
make bancos-medios     # banco-mecanismos, que lee ISOs de medios/
make paquetes          # los tres .deb desde git archive HEAD, por huella (Linux: guiones; Mac: docker/, tarea 15)
make iso ARQ=arm64     # construir-todo.sh con nombre; make dos-veces es SU definición de terminado, ejecutable
make medios/SHA256SUMS # las sumas calculadas, no escritas a mano
make verificador       # medios/verificar-instalacion.sh EMPAQUETADO (lleva lib/salida.sh dentro): el que viaja a la máquina
```

Construcción y lintian (van en la VM Ubuntu **y** en la CI; un paquete por
guion, a propósito — no se generalizan porque cada uno está validado contra el
suyo):

```bash
./scripts/construir-branding.sh          # encina-branding   (--saltar-reglas omite las comprobaciones estáticas)
./scripts/construir-firefox.sh  # encina-firefox-native (se detiene si la huella de la clave de Mozilla no cuadra)
./scripts/construir-meta.sh     # encina-meta       (se detiene si falta debian/changelog; no lo crea)
ENCINA_REPO="$PWD" ./scripts/construir-branding.sh   # así los invoca la CI
```

Instalar y verificar en VM (nunca en el Mac):

```bash
./scripts/instalar-branding.sh   ./scripts/verificar-branding.sh   # branding: usuario nuevo, idempotencia x5, purga
./scripts/instalar-firefox.sh ./scripts/verificar-firefox.sh   # full-upgrade x2 = la prueba del anclaje
./scripts/instalar-meta.sh ./scripts/verificar-meta.sh         # la secuencia de tres órdenes
```

Imagen (`imagen/`), desde el Mac:

```bash
./imagen/traer-iso-oficial.sh                       # la ISO de Ubuntu a medios/, verificando su firma
./imagen/construir-todo.sh --constructor usuario@vm-linux \
                           --autofirma <dir con autofirma_*.deb> \
                           --salida medios/encina-os.iso
./imagen/comprobar-propios.sh <paquete> [--manifiesto X]   # huella del .deb contra repo-manifiesto.tsv
./imagen/inventario-marca.sh <iso> [--trabajo D]    # dónde dice Ubuntu un medio, leyéndolo (no lo arranca)
./imagen/capa-marca.sh <iso> --salida <dir>         # fabrica la capa de marca del medio (D23)
./imagen/banco-cadena.sh                            # el banco de la cadena de capas de casper (segundos)
./imagen/banco-autosuficiencia.sh --repo D --constructor usuario@vm-linux
                                                   # ¿el medio se instala SIN RED? apt de verdad contra
                                                   # el repo, con el dpkg status de la base. Segundos
./imagen/fabricar-iso.sh --repo D --salida X [--sin-capa|--sin-volid|--sin-info|--sin-menu]
                                                   # una bandera por mecanismo de D23: es para BISECAR, no el producto
./imagen/fabricar-iso.sh --leer-mecanismos <iso>   # qué mecanismos lleva un medio, leídos de él
./imagen/banco-mecanismos.sh                       # el banco de ese lector, con su control (segundos)
./scripts/fabricar-vm-medio.py --iso <iso> --nombre <n>   # bundle de UTM para arrancar un medio (trampa 66)
sudo ./imagen/verificar-instalacion.sh --forma e3 --visibles 27   # DENTRO de la máquina instalada, como root
```

Cierre de sesión (añade una entrada fechada a `DIARIO.md`, **en tres bloques**
desde el 2026-08-28, y hace commit de todo):

```bash
./scripts/diario.sh "qué se midió" "qué salió mal" "qué toca mañana"
```

**El changelog se gestiona con `dch -v <versión>`, nunca a mano**, y en la VM.

## Arquitectura

**El producto es Ubuntu 24.04 LTS arm64 con cuatro `.deb` encima**, entregado
como ISO reempaquetada a partir de la oficial. No es un fork y no se
remasteriza la base (D3).

Los cuatro paquetes, y el reparto de responsabilidades entre ellos es lo que
hay que entender antes de tocar nada:

- **`encina-branding`** — identidad visual: fondos, tema de Plymouth, logotipo de
  GDM, GRUB, y `/etc/xdg/mimeapps.list` que ata el PDF al visor.
- **`encina-firefox-native`** — configura el repositorio de Mozilla, su clave y
  el **anclaje de prioridad**, y sombrea `firefox_firefox.desktop` para que el
  icono abra el nativo. **No instala Firefox** (R10) ni elimina el Snap (R4).
- **`encina-meta`** — solo `Depends:`. Sin `src/`, sin configuración, sin lógica
  en el `postinst`. Un metapaquete con contenido son dos paquetes mal separados.
- **`autofirma 1.9.1+encinaN`** — **vive en `~/Projects/encina-autofirma`**, no
  aquí. Es un ingrediente con condición de salida (D14), con su propio
  `MEDICIONES.md` (M1–M20) y tres forks de los que salen las PRs upstream.

**D13 es la invariante que más se tienta:** ningún paquete de este repositorio
cierra barrera alguna de la firma electrónica —ni `policies.json`, ni
preferencias de Firefox, ni certificados—. Se cerraron todas a la vez en el
paquete de AutoFirma. Si una tarea parece pedir lo contrario, para y remite a
D13.

**La construcción cruza dos máquinas y no es un capricho:**
`dpkg-buildpackage`/`dpkg-scanpackages` no existen en macOS y `fabricar-iso.sh`
usa herramientas de macOS. `construir-todo.sh` va por `ssh` a un constructor
Ubuntu arm64 para los pasos 1 y 3, y hace 2 y 4 en el Mac. Construye
`git archive HEAD`, **no el directorio de trabajo**, y se niega sobre un árbol
sucio; su definición de terminado no es «sale una ISO» sino que **dos pasadas
den la misma huella**.

**Lo compartido entre guiones vive en `lib/` desde el 2026-08-28** (tarea 3):
`lib/salida.sh` es el vocabulario —colores, contadores, `ok`/`fallo`/`aviso`/
`omitido`/`morir`/`comprobar`/`comprobar_salida`/`resumen`— y es portátil: lo
cargan también `imagen/` y `bancos/`; `lib/vm.sh` es lo que sólo sirve en la VM
Ubuntu (`raiz_repo`, `resolver_desktop`, `PKG_DIR`, el vigilante). `scripts/lib.sh`
sigue existiendo como puente para los 17 guiones que lo cargan. **`fallo()`
apunta y sigue; `morir()` aborta** (tarea 2): son dos palabras en todo el árbol.

## Método — esto es lo que distingue a este repositorio

Es un proyecto que **escribe lo que mide**, incluido lo que sale mal. No es
estilo: es lo que hace que el trabajo sea verificable por una persona sola.

- **Nada se da por bueno sin medirlo, y nada se declara terminado sin ejecutar
  su definición de terminado.** No marques una casilla de `AGENTS.md` que no
  hayas visto pasar.
- **Ninguna comprobación vale sin su control.** Una comprobación que no puede
  dar sus dos respuestas no es una comprobación. Varias mediciones de este
  repositorio salieron mal la primera vez justo por ahí, y la CI ejecuta el
  control **antes** que la medición por ese motivo.
- **Vocabulario de salida**, y se respeta al escribir guiones nuevos:
  `[OK]` comprobado y correcto · `[FALLO]` comprobado e incorrecto, **con la
  salida literal** · `[AVISO]` mirar, no bloquea · `[OMIT]` no comprobado (no
  darlo por bueno) · `[OJOS]` solo lo puede verificar una persona mirando la
  pantalla. Un solo `[FALLO]` y el guion sale con código distinto de cero.
- **`[OJOS]` es de Jorge.** Splash, GDM, fondo, la firma en `valide.redsara.es`:
  se listan y no se cuentan como aprobados.
- **Lo medido y lo deducido van separados**, y cuando una deducción resulta
  falsa se corrige **dejando al lado lo que se creía**. Por eso los documentos
  llevan enmiendas fechadas en vez de reescrituras limpias: no las «ordenes».
- **Una mutación se verifica antes de leer su resultado** (trampa 13). Un `[OK]`
  que describe lo que el guion *pidió* y no lo que *pasó* es peor que no
  tenerlo.

### Dos trampas del entorno que muerden al agente

- **`git` puede contestar un commit que no es:** el hook de `rtk` filtra su
  salida. Para medir, `/usr/bin/git` o `rtk proxy git …` (`MEDICIONES.md` §4.9d).
- **Una sesión `ssh` no es una sesión de escritorio.** Sin `XDG_CURRENT_DESKTOP`
  ni `XDG_DATA_DIRS`, `gsettings` y `xdg-mime` contestan otra cosa y dan verdes
  falsos. Exporta la variable en la comprobación o no vale.

## Convenciones de commits

Mensajes en español, en una frase, contando **qué se descubrió o qué cambió de
verdad** — no `fix:` ni `feat:`. El ritual de cierre (`diario.sh`) genera
`diario: <texto>`.
