# Las dos del README — reducidas, 2026-08-15

**Para qué existe este directorio:** las capturas buenas son de 3420×2146 y 4,4
MB cada una. Pegadas en el README hacen que la portada del proyecto tarde en
cargar, y a 49 % de ancho nadie ve esos píxeles. Aquí viven las copias que sí
van en el README, y **no son evidencia de nada**: la evidencia está en
[../fondo-0.1.13/](../fondo-0.1.13/), que es lo que hay que mirar y lo que
aprueba Jorge.

| Fichero | Sale de | Huella del original (sha256) |
|---|---|---|
| `escritorio-claro.jpg` | `../fondo-0.1.13/3-escritorio-claro.png` | `7be26192…79ec5b73` |
| `escritorio-oscuro.jpg` | `../fondo-0.1.13/4-escritorio-oscuro.png` | `d8a1c732…374efe84` |

## Cómo se rehacen

```bash
cd design/capturas
sips -Z 1400 -s format jpeg -s formatOptions 85 \
     --out readme/escritorio-claro.jpg  fondo-0.1.13/3-escritorio-claro.png
sips -Z 1400 -s format jpeg -s formatOptions 85 \
     --out readme/escritorio-oscuro.jpg fondo-0.1.13/4-escritorio-oscuro.png
```

Sale 1400×878 y ~340 KB por captura, frente a los 4,4 MB del original.

**JPEG y no PNG, a propósito.** El contenido es una fotografía —los maestros de
`design/fondos/maestros/` ya son JPEG—, así que el PNG sólo estaba guardando el
mismo grano a peso completo: reducido a 1400 px seguía pesando 2,0 MB, seis
veces más que el JPEG, para la misma imagen. La calidad 85 se eligió mirando:
con 70 se ensucia el borde del texto de `ENCINA OS`, con 90 se pagan 70 KB más
por algo que no se distingue.

## Lo que estas dos NO enseñan, y por eso el pie del README lo dice

- Son del **sistema ya instalado**. El medio de instalación todavía lleva marca
  de Ubuntu — es la tarea que bloquea publicar la imagen.
- En el dock salen la «A» naranja del Centro de aplicaciones y el icono de
  ayuda, **que son de Ubuntu**. ~~Siguen siendo casilla abierta.~~ **Ya no: la
  «A» se sustituyó el 2026-08-15 en `encina-branding` 0.1.15** —`D21`, con la
  sombra de su `.desktop` y un icono propio, visto en
  [../despues/07-icono-tienda-aplicaciones.png](../despues/07-icono-tienda-aplicaciones.png)—
  y **el «?» se queda como está a propósito**, porque lo que abre es
  `ubuntu-docs`, titulado «Guía del escritorio de Ubuntu», y repintarlo no
  cambiaría eso (§4.47g). **Estas dos capturas son de 0.1.13 y no se rehacen por
  esto:** lo que enseñan es el fondo, y el fondo no ha cambiado. Cuando toque
  rehacerlas, saldrá el icono nuevo.
- La franja de arriba lleva **la pastilla de la ventana de UTM**, a la
  izquierda. No se recorta porque recortarla se llevaría por delante la barra de
  GNOME, que sí es el producto. Es el mismo criterio que el
  [LEEME de las capturas](../LEEME.md): esos 130 px de arriba no cuentan.
