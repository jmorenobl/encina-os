# Scripts de Encina OS — fase A1

Ocho scripts. Se ejecutan en orden. Cada uno termina diciéndote cuál viene
después, y ninguno da nada por bueno sin comprobarlo.

## Orden

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

Los nueve ficheros pasan `shellcheck` sin avisos, y las comprobaciones de reglas
duras se han validado saboteando un paquete a propósito: detectan violaciones de
R1, R2, R3, R6, R7, la falta del callback de LUKS, la falta de `picture-uri-dark`
y la línea duplicada de `GRUB_DISTRIBUTOR`.
