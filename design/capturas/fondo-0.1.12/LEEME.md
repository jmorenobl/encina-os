# El fondo propio en pantalla — `encina-branding` 0.1.12, 2026-08-15

Las pantallas de `encina-dev` con el fondo nuevo puesto. **Nada de esto está
aprobado:** son `[OJOS]`, y los `[OJOS]` son de Jorge. Aquí solo está la
evidencia para que mirarla no cueste arrancar una VM.

## La trampa que casi arruina esta medición, y va primero

**El escritorio de `jorge` NO enseña el fondo del producto**, y no es un fallo:
tiene `amapolas` escrito en su propio `dconf`. Medido, con su control:

```
dconf read /org/gnome/desktop/background/picture-uri
  -> 'file:///usr/share/backgrounds/encina/amapolas.jpg'
dconf read /org/gnome/shell/welcome-dialog-last-shown-version   (control)
  -> '46.0'          # o sea que un vacío significaría «no lo ha tocado»
```

Gana la persona sobre el sistema, que es lo correcto. Pero significa que
**`jorge` no sirve para mirar ningún valor por defecto**: `sesion-03.png` está
aquí como ejemplo de eso y no como captura del producto.

Y hay una segunda contaminación en el mismo usuario, de la sesión del acento del
2026-08-14: `dconf read /org/gnome/desktop/interface/icon-theme` devuelve
`'Yaru'`. Por eso **en el dock de `jorge` el botón de la rejilla sale con el
logotipo de Ubuntu** y en el de `prueba` sale la bellota. No es una regresión de
la casilla que se cerró en 0.1.10: es un usuario con el tema cambiado a mano.

**Lo que se mira es `prueba`**, creado después de instalar, sin nada escrito en
su `dconf`. Es el mismo usuario que usa `verificar-branding.sh` y por el mismo motivo.

## Las capturas

| Fichero | Qué es |
|---|---|
| `01-fase.png` … `05-fase.png` | El arranque en frío, agrupado en fases por `capturar-aspecto.sh`. La 05 es GDM |
| `prueba-0-gdm.png` | GDM con los dos usuarios |
| `prueba-1-usuario-elegido.png` | `prueba` elegido, pidiendo contraseña |
| `prueba-3-escritorio-claro.png` | **El fondo de día, heredado sin tocar nada** |
| `prueba-4-escritorio-oscuro.png` | **El de noche**, con `color-scheme` a `prefer-dark` |
| `rejilla.png`, `sesion-*.png` | La sesión de `jorge` — ver la trampa de arriba |

## Lo que se ve, dicho sin adornos

- **El fondo por defecto es el propio, y el oscuro es el mismo paisaje de
  noche.** Alternar el tema cambia la hora del día y no el sitio, que era la
  intención declarada en `encina.xml`.
- **La bellota está en el dock** de `prueba`, confirmando 0.1.10.
- **`zoom` recorta por los lados, y recorta justo donde está la marca.** En la
  ventana de UTM —que no es 16:9— la bellota del logotipo de la imagen queda
  cortada por el borde izquierdo en las dos capturas. En una pantalla 16:9 no
  pasaría, pero conviene saber que el texto quemado vive en la zona que el
  recorte se come primero.
- **`Version 24.04 LTS` va sin tilde**, y está dentro del JPEG. También está
  dentro el número de versión, que no se puede actualizar sin rehacer la imagen.
- El dock, abajo y centrado, **no pisa el texto**: el bloque está a la izquierda.

## Lo que este directorio NO tiene

**El control de la segunda pasada.** `capturar-aspecto.sh` lo dice él mismo: la
casilla la cierra lanzarlo a otro directorio y comparar fase a fase con
`scripts/diferencia.py`. Aquí hay **una** pasada, tomada para mirar un fondo, no
para volver a validar el instrumento —que se validó el 2026-08-14—.
