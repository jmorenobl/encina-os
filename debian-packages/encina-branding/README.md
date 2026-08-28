# encina-branding

Identidad visual de Encina OS: fondos claro y oscuro, logotipo, tema de arranque
de Plymouth y personalizacion de la pantalla de inicio de sesion de GDM.

Version 0.1.6, verificada en VM Ubuntu 24.04 arm64: 10/10 de la definicion de
terminado de AGENTS.md §4.4.

## Construir

    ./scripts/construir-branding.sh

Comprueba las reglas duras, construye el `.deb` y pasa `lintian`.

## Instalar y probar

    ./scripts/instalar-branding.sh     # instala y comprueba lo verificable sin reiniciar
    sudo reboot
    ./scripts/verificar-branding.sh    # usuario nuevo, idempotencia x5, purga

El splash de arranque, el logotipo de GDM y el fondo del escritorio no los puede
comprobar ningun script: salen al final marcados `[OJOS]` y hay que mirarlos.

## Activos

Los tres ficheros de `src/usr/share/backgrounds/encina/` estan versionados en el
repositorio, pero son **provisionales**: los genero `generar-activos.sh` a partir del
SVG del logotipo. Cuando tengas los definitivos, sustituyelos sin mas.
`generar-activos.sh` no sobrescribe activos existentes salvo con `--forzar`,
precisamente para no machacartelos.

## Changelog

Con `dch -v <version>`, nunca a mano. La suite es el codename de Ubuntu destino
(`noble`).

## Si partes de este paquete para crear otro

Cambia el mantenedor en `debian/control`, `debian/changelog` y
`debian/copyright`. En este paquete ya esta puesto; `lintian` da error si
encuentra una direccion de ejemplo.
