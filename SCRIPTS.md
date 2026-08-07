# Scripts de Encina OS

Once scripts. Se ejecutan en orden. Cada uno termina diciéndote cuál viene
después, y ninguno da nada por bueno sin comprobarlo.

## Orden

### Comunes y fase A1 — `encina-branding`

| Script | Qué hace | Dónde |
|---|---|---|
| `00-entorno.sh "Nombre" "correo"` | Instala herramientas, configura git y DEBEMAIL | VM |
| `01-repo.sh [tar.gz]` | Crea ~/encina, coloca el esqueleto, verifica el árbol | VM |
| `02-activos.sh [--forzar]` | Genera fondos y logotipo, verifica formatos | VM |
| `03-construir.sh` | **Reglas duras** + build + lintian | VM y CI |
| `04-instalar.sh` | Instala y comprueba todo lo verificable sin reiniciar | VM |
| `05-verificar.sh` | Usuario nuevo, idempotencia x5, purga | VM |
| `06-ci.sh` | GitHub Actions y repositorio remoto | VM |
| `diario.sh "texto"` | El ritual de cierre en un comando | VM |

### Fase A2 — `encina-firefox-native`

| Script | Qué hace | Dónde |
|---|---|---|
| `07-firefox-construir.sh` | Huella de la clave, **reglas duras**, build + lintian | VM y CI |
| `08-firefox-instalar.sh` | Instala, `apt update`, anclaje, idioma, Firefox nativo | VM |
| `09-firefox-verificar.sh` | **`full-upgrade` x2**, idempotencia x5, purga | VM |

Son scripts aparte y no una generalización de 03/04/05 a propósito: aquellos
están validados contra `encina-branding` y no se tocan. Lo único que comparten
es `lib.sh`, donde `PKG_DIR` acepta ahora el nombre del paquete y sigue
devolviendo `encina-branding` cuando no se le pasa ninguno.

`07` se detiene sin construir nada si la huella de la clave de firma de Mozilla
no coincide con `35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3`. La huella está
escrita a mano dentro del script: leerla del fichero que se quiere validar no
validaría nada.

`09` es el que importa. Ejecuta `apt full-upgrade` **dos veces** y comprueba que
Firefox no ha vuelto al Snap. Si esas dos vueltas no mueven ningún paquete
—porque el sistema ya estaba al día— lo dice y fuerza una vuelta más incluyendo
las actualizaciones por fases de Ubuntu, para que apt tenga algo que decidir:
una prueba vacía que imprime `[OK]` es peor que no tenerla. Al purgar comprueba
además que el candidato de `firefox` vuelve solo al deb de transición de Ubuntu,
que es la prueba A/B de que el anclaje es lo que sostiene Firefox nativo.

## Arranque en frío

Desde el Mac, con la VM ya creada en UTM:

```
scp encina-scripts.tar.gz encina-branding.tar.gz USUARIO@IP:~/
ssh USUARIO@IP
tar xzf encina-scripts.tar.gz
cd encina-scripts
./scripts/00-entorno.sh "Tu Nombre" "tu@correo.real"
./scripts/01-repo.sh ~/encina-branding.tar.gz
cd ~/encina
./scripts/02-activos.sh
./scripts/03-construir.sh
```

A partir de `01-repo.sh` los scripts viven dentro del repositorio, en
`~/encina/scripts`, y se versionan con él.

## Cómo leer la salida

```
[OK]     comprobado y correcto
[FALLO]  comprobado e incorrecto, con la salida literal del comando
[AVISO]  algo que mirar, no bloquea
[OMIT]   no se ha comprobado (no lo des por bueno)
[OJOS]   solo lo puedes verificar tú mirando la pantalla
```

Si hay un solo `[FALLO]`, el script sale con código distinto de cero y te
recuerda que no marques la casilla en ENCINA-OS.md.

## Lo que estos scripts NO pueden verificar

El splash de arranque, el logotipo de GDM y el fondo del escritorio hay que
mirarlos. `04` y `05` te los listan al final marcados `[OJOS]` y no los cuentan
como aprobados.

Lo mismo con Firefox: que arranque **en español** no lo puede comprobar ningún
script. `08` y `09` lo dejan marcado `[OJOS]` junto con `about:support`, donde
`Application Binary` no debe estar bajo `/snap`.

## Idempotencia

Todos son idempotentes: ejecútalos las veces que quieras. `02-activos.sh` no
sobrescribe activos existentes salvo con `--forzar`, para que el día que pongas
el logotipo de verdad no te lo machaque un script.

## Ubicación del repositorio

Por defecto `~/encina`. Si lo tienes en otro sitio:

```
export ENCINA_REPO=/ruta/a/tu/repo
```

## Comprobado

Los doce ficheros pasan `bash -n`. **`shellcheck` sí devuelve avisos**, al
contrario de lo que decía antes este documento: cuatro `SC2164` sobre `cd` y el
resto de nivel `info`/`style`. Los `SC2164` son falsos positivos —`lib.sh` fija
`set -euo pipefail`, de modo que un `cd` fallido ya aborta el script, pero
`shellcheck` no lo detecta porque no resuelve el `source` de ruta dinámica ni
siquiera con `-x`. Se dejan como están a propósito. Los tres scripts de A2
(07, 08, 09) están limpios a nivel `warning`.

Las comprobaciones de reglas
duras se han validado saboteando un paquete a propósito: detectan violaciones de
R1, R2, R3, R6, R7, la falta del callback de LUKS, la falta de `picture-uri-dark`
y la línea duplicada de `GRUB_DISTRIBUTOR`.

## Dos trampas de estos scripts, por si escribes más

Las dos aparecieron en A2 y las dos dan **falsos negativos**: el script dice
`[FALLO]` con la cosa comprobada funcionando perfectamente. Es el peor modo de
fallo posible para una herramienta de verificación, porque cuesta horas
persiguiendo un problema que no existe.

**1. `comando | grep -q` con `pipefail`.** `grep -q` termina en cuanto encuentra
la coincidencia; el proceso de la izquierda muere entonces con SIGPIPE (código
141) y `set -o pipefail` convierte eso en fallo de toda la tubería. Medido:

```
$ apt-cache policy firefox-l10n-es-es | grep -qE 'Candidate: [^(]'
PIPESTATUS: 141 0     <- apt-cache muerto, grep encontrando lo que buscaba
```

No basta con que la salida sea pequeña: aquí eran 604 bytes. La forma correcta
es capturar primero y examinar después, o usar una cadena aquí (`<<<`), que no
crea proceso escritor.

**2. La salida de apt está traducida.** En una VM en español `Candidate:` se
llama `Candidato:`, así que cualquier comprobación que busque la palabra en
inglés falla siempre. Todo lo que consulte a apt va con `LC_ALL=C`.
