# La marca dentro de la zona segura — `encina-branding` 0.1.13, 2026-08-15

Las mismas pantallas que [../fondo-0.1.12/](../fondo-0.1.12/) y **en la misma
ventana de UTM**, que es lo que hace que la comparación signifique algo: si el
tamaño de la ventana hubiera cambiado, esto no probaría nada.

Siguen siendo `[OJOS]`: aquí está la evidencia, la aprobación es de Jorge.

| Fichero | Qué es |
|---|---|
| `0-gdm.png` | GDM con los dos usuarios |
| `1-usuario.png`, `2-clave.png` | `prueba` elegido y la clave tecleada |
| `3-escritorio-claro.png` | **El fondo de día** |
| `4-escritorio-oscuro.png` | **El de noche** |

Se mira `prueba` y no `jorge`, por lo que está explicado en el LEEME de la
0.1.12: `jorge` tiene `amapolas` y el tema `Yaru` escritos en su propio `dconf` y
no sirve para mirar ningún valor por defecto.

## Qué cambia respecto de la 0.1.12

- **La bellota sale entera.** En `../fondo-0.1.12/prueba-3-escritorio-claro.png`
  queda cortada por el borde izquierdo; aquí no. Es el mismo recorte de `zoom`
  sobre la misma ventana: lo que cambió es dónde está la marca dentro de la
  imagen.
- **`Versión` lleva su tilde.** En la 0.1.12 viajaba sin ella dentro del JPEG.
- **`lanzamiento 'La Mancha'` pasa a `Edición 'La Mancha'`.**

## Lo que sigue igual, y conviene no darlo por resuelto

**El número de versión sigue quemado dentro de la imagen.** `24.04 LTS` es hoy
correcto y el día que cambie, el fondo mentirá y no se podrá actualizar sin
rehacer los dos maestros y sacar una versión del paquete. No es un fallo: es una
decisión con un coste, y el coste conviene tenerlo escrito.
