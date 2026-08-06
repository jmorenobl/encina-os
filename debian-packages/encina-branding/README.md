# encina-branding

Identidad visual de Encina OS.

## Antes de construir

1. Sustituye `CAMBIA ESTO <cambia@esto.example>` en `debian/control`,
   `debian/changelog` y `debian/copyright` por tu nombre y tu correo real.
   Lintian da error si detecta una direccion de ejemplo.
2. Genera los activos graficos: `./scripts/02-activos.sh`

## Construir

    ./scripts/03-construir.sh

## Activos

Los tres ficheros de `src/usr/share/backgrounds/encina/` NO estan en este
esqueleto: los genera `02-activos.sh` a partir del SVG del logotipo. Cuando
tengas los definitivos, sustituyelos y no vuelvas a ejecutar ese script sin
`--forzar`.
