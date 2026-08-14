# El arranque

Las dos pantallas que se ven antes de que exista una sesión. Son las que más
delatan la marca ajena y las que menos se miran, porque duran segundos.

## Plymouth — `plymouth/`

**Ya hay tema propio y está instalado.** Vive en
`debian-packages/encina-branding/src/usr/share/plymouth/themes/encina/`:
`encina.plymouth`, `encina.script` y dos PNG de la barra de progreso.

Dos cosas que están resueltas y que cuesta caro volver a descubrir:

- **R6:** el tema se basa en `spinner`, nunca en `bgrt`. `bgrt` enseña el
  logotipo del firmware del fabricante, así que el propio no aparecería jamás.
- **R7:** el tema viaja **dentro del initramfs**. Sin `update-initramfs -u` no se
  observa ningún cambio, y el fallo es silencioso. Lo hace el `postinst`.

*Lo que falta:* `barra.png` y `barra-fondo.png` son de 195 y 196 bytes y no
tienen maestro aquí. Y nadie ha mirado cómo se ve el tema a la resolución de una
pantalla de verdad — sólo se sabe que está instalado.

## GRUB — `grub/`

**Vacío a propósito, y con la decisión escrita para que no se haga trabajo que no
se ve.**

Lo que ya está: el `postinst` fija `GRUB_DISTRIBUTOR="Encina OS"` editando
`/etc/default/grub` in situ con `sed` —nunca sobrescribiéndolo, R5— y llama a
`update-grub`.

Lo que faltaría es un tema gráfico (`GRUB_THEME` con su `theme.txt` y su fondo).
**Y rinde mucho menos de lo que parece:** en una máquina con un solo sistema
operativo el menú de GRUB está oculto y nadie lo ve nunca. Donde sí se ve es en
**el arranque de la ISO**, y eso es el bloque de la marca del medio, no éste.

Conclusión: el tema de GRUB no es prioridad de este bloque. Si se hace, se hace
con el medio.
