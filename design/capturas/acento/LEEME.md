# El acento, probado en la máquina del producto

**2026-08-14, sobre `encina-95758c9e`.** Dos órdenes, en caliente, sin
empaquetar nada y sin reiniciar la sesión:

```
gsettings set org.gnome.desktop.interface gtk-theme  Yaru-sage
gsettings set org.gnome.desktop.interface icon-theme Yaru-sage
```

| Captura | Qué es |
|---|---|
| `../antes/06-archivos-gtk4.png` | El antes: carpetas berenjena, botón naranja |
| `archivos-sage.png` | `Yaru-sage` `#657B69` |
| `archivos-viridian.png` | `Yaru-viridian` `#03875B` |
| `reseteado-y-control.png` | El reseteo, con el control que salió gratis |

## Qué cambió, y es más de lo que se esperaba

**Funciona, en caliente y sin reiniciar la sesión.** Con las dos órdenes:

- **las carpetas de Archivos** pasan de berenjena a verde;
- **la selección** de la barra lateral se pone verde;
- **el botón «Siguiente» de la pantalla de bienvenida deja de ser naranja** — y
  ésa es una aplicación **GTK4/libadwaita**, que es justo lo que se dudaba que
  el tema alcanzara. Lo alcanza.

**Y lo que NO cambió, también medido:** el dock sigue con el icono naranja del
Centro de aplicaciones y con el botón de la rejilla de Ubuntu, porque ésos son
**iconos de aplicación**, no acento. Y la barra superior tampoco: el tema del
shell no tiene variantes.

## El control que salió gratis

Al resetear:

```
gsettings get org.gnome.desktop.interface gtk-theme   -> 'Yaru'
gsettings get org.gnome.desktop.interface icon-theme  -> 'Encina'
```

**`icon-theme` vuelve a `Encina`, no a `Yaru`.** O sea que el
`gschema.override` de `encina-branding` está vivo y gana cuando el usuario no
tiene valor propio — que es exactamente lo que se diseñó y lo que §4.43 midió por
otra vía. La máquina queda como estaba.

## La conclusión, y es la que decide el fork

**Ninguno de los dos prestados es el verde de Encina.**

| | Hex | Cómo se lee |
|---|---|---|
| **encina** | `#3A664E` | Verde de hoja en sombra: oscuro y apagado |
| sage | `#657B69` | Tan desaturado que parece «carpetas grises»: casi no se nota que se ha decidido algo |
| viridian | `#03875B` | Sí se lee como verde, pero es esmeralda —más de aplicación que de dehesa— |

`sage` es el más cercano por distancia RGB y **el que peor cuenta la identidad**:
pasa por gris. `viridian` cambia la cara de verdad, pero es otro verde.

Así que la pregunta de si merece la pena forkear Yaru **está contestada por una
captura y no por una preferencia**: si se quiere `#3A664E`, hay que forkear,
porque no hay dónde escribir ese color. Lo que este experimento sí deja probado
es que **el mecanismo entero funciona** —GTK3, GTK4, iconos y carpetas— y que
el fork consiste en **añadir una variante más**, que es la escala a la que Yaru
ya está construido.
