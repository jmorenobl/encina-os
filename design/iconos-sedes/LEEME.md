# Iconos de los accesos a sedes — primera hornada, para los ojos de Jorge

**Qué es esto.** El primer ensayo de los iconos del punto 6 de
[roadmap/v1.md](../../roadmap/v1.md) (accesos rápidos a la administración):
tres iconos y la loseta común, dibujados el 2026-08-30. **No hay paquete, no
hay `.desktop`, no hay tarea abierta**: son dibujos para que Jorge diga cuáles
sí y cuáles no, que es `[OJOS]` por naturaleza. La decisión de fondo —dibujos
propios con el nombre oficial en texto, nada de logotipos de la
Administración— está razonada en `roadmap/v1.md`.

| Fichero | Qué abre (cuando exista el `.desktop`) | Glifo |
|---|---|---|
| [loseta.svg](loseta.svg) | — (la plantilla sin glifo) | — |
| [encina-sede-dehu.svg](encina-sede-dehu.svg) | DEHú, notificaciones electrónicas | Campana |
| [encina-sede-tesoreria.svg](encina-sede-tesoreria.svg) | Tesorería General de la Seguridad Social | Edificio de frontón y columnas |
| [encina-sede-carpeta-ciudadana.svg](encina-sede-carpeta-ciudadana.svg) | Mi Carpeta Ciudadana | Carpeta con una persona |

## El método: medida, no derivación

Jorge pidió el estilo de Yaru sin obra derivada, así que **se midió la
plantilla oficial de Yaru y se copiaron números, no ficheros**: ningún trazado
de este directorio sale de un SVG ajeno. El estilo no es apropiable; los
ficheros sí lo serían (Yaru es CC-BY-SA 4.0 — si algún día se copia un
trazado, se declara en `debian/copyright` y en este LEEME).

**La fuente medida:** `icons/src/fullcolor/Square App Icon Template.svg` del
repositorio `github.com/ubuntu/yaru`, commit `e5d7e5100d161e26fe376446b093e189916f8a67`
(clon del 2026-08-30). Lo que se midió allí, en el lienzo de 256:

| Qué | Valor medido |
|---|---|
| Placa | 208×208 en lienzo 256, margen 24 por lado |
| Esquina | **No es un `rx`**: cúbica de ~39 px con controles a (35,3, 0) y (39,1, 3,6) — la «squircle» de Yaru |
| Brillo del borde alto | Tira blanca, opacidad 0,3, ~2 px, siguiendo la esquina |
| Sombra del borde bajo | Tira negra, opacidad 0,2, ~2 px |
| Sombras proyectadas | Dos copias de la placa desplazadas +1 px: desenfoque gaussiano 4,48 a opacidad 0,2 y 1,12 a opacidad 0,1 |
| Degradado de la plantilla | `#5884f4` → `#80a3fa` — **más oscuro ARRIBA y más claro abajo**, con leve diagonal |
| Tamaños pequeños | La plantilla trae lienzos 48, 32, 24 y 16 aparte: **Yaru redibuja cada tamaño, no escala el grande** (los pequeños llevan además un contorno negro a 0,4) |

## Las decisiones de dibujo, y por qué

- **Geometría de Yaru, colores de Encina.** La placa degrada de acento
  `#3A664E` a acento-profundo `#2F4033` —la misma pareja del icono del Centro
  de aplicaciones ([../iconos/encina-centro-aplicaciones.svg](../iconos/encina-centro-aplicaciones.svg)),
  que es el dialecto ya vigente— y los hex salen de
  [../paleta.tsv](../paleta.tsv), que es la fuente. **Discrepancia anotada:**
  Yaru degrada oscuro-arriba; la placa de Encina vigente degrada
  claro-arriba. Se conserva la de la casa, porque dos iconos de Encina en el
  mismo dock deben casar entre sí antes que con Yaru.
- **Glifos en papel `#F5F7F4`**, macizos y de formas grandes, pensados para
  leerse a 48 px (el tamaño del dock). Ningún glifo copia un emblema oficial:
  campana, edificio clásico, carpeta — categorías, no marcas.
- **La bellota de la esquina** (arcilla `#D6BFA0`) marca «acceso de Encina»:
  su papel es que el icono **no parezca oficial**, que es la mitad del motivo
  de dibujar iconos propios. **Tensión anotada, y la resuelve Jorge mirando:**
  el botón de la rejilla ya lleva la bellota, y el icono del Centro de
  aplicaciones la evita a propósito por convivir en el mismo dock; estos
  viven en la rejilla, no en el dock, pero si al verlos sobra bellota, se
  quita de la loseta y quedan los glifos solos.
- El comentario de cada SVG va **dentro** de `<svg>`: gdk-pixbuf husmea los
  primeros 256 bytes (trampa medida el 2026-08-15 en
  `encina-centro-aplicaciones.svg`, con umbral exacto).

## Lo que NO está hecho, para que nadie lo dé por hecho

- `[OJOS]` **de Jorge: nadie ha mirado estos iconos en pantalla todavía**, ni
  a 256 ni a 48. La página de muestra los enseña juntos sobre claro y oscuro.
- **Los tamaños pequeños no están redibujados.** Yaru redibuja 48/32/24/16;
  aquí sólo existe el 256. Si a 48 px el escalado no se lee, toca redibujar
  como hace Yaru.
- **No hay variantes simbólicas** (`-symbolic.svg`, 16 px monocromo).
- **La lista de sedes es de Jorge** (¿cuáles, con qué URLs?), y el paquete
  destino (`encina-branding` o un `encina-sedes` propio) está sin decidir —
  ambas cosas en [roadmap/v1.md](../../roadmap/v1.md), punto 6.
