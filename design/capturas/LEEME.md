# Las capturas

**Para qué existe este directorio:** para que «se ve mejor» deje de ser una
opinión. En todo lo demás este proyecto compara salidas literales; en lo visual
la única salida literal es una captura, y sin un «antes» guardado no hay con qué
comparar.

El instrumento es `scripts/capturar-aspecto.sh`. **No cronometra las pantallas:
las detecta**, disparando en ráfaga todo el arranque y agrupando los fotogramas
consecutivos que son idénticos. Cada grupo es una **fase**, y de cada fase se
guarda el último fotograma.

```
./scripts/capturar-aspecto.sh encina-95758c9e <directorio>
./scripts/capturar-aspecto.sh --comparar <dirA> <dirB>     # el control
```

## Lo que hay en `antes/`, medido el 2026-08-14 sobre `encina-95758c9e`

La máquina del producto, con `encina-branding` 0.1.9, arrancada desde frío.
**Salen tres fases y no seis**, y eso ya es un hallazgo:

| Fichero | Cuándo | Qué es |
|---|---|---|
| `01-firmware-barra.png` | 6 s | La barra «Start boot option» del firmware. **Transitoria** |
| `02-pantalla-apagada.png` | 9–20 s | **«Display output is not active.»** Todo el arranque, en negro |
| `03-gdm.png` | 23–81 s | El saludador de GDM |
| `reconocimiento-firmware-dice-ubuntu.png` | ~10 s | El firmware cargando `\EFI\ubuntu\shimaa64.efi` |

## Los tres hallazgos, y ninguno se esperaba

**1. No hay menú de GRUB.** Con un solo sistema operativo está oculto, así que la
captura que la lista canónica pedía **no existe en esta máquina**. Lo que sí se ve
antes de eso es el firmware, y **dice Ubuntu dos veces**:

```
BdsDxe: loading Boot0005 "Ubuntu" from HD(...)/\EFI\ubuntu\shimaa64.efi
BdsDxe: starting Boot0005 "Ubuntu" from HD(...)/\EFI\ubuntu\shimaa64.efi
```

Eso **no lo arregla `GRUB_DISTRIBUTOR`**: son la etiqueta de la entrada de
arranque en la NVRAM y la ruta del `shim`, que vienen del paquete. Es una línea
del inventario que nadie había escrito.

**2. Plymouth no se ve. Nunca.** Del segundo 9 al 20 —y hasta el 48 en otras
pasadas— la pantalla del invitado está **apagada**, con el mensaje de UTM encima.
El tema de arranque de Encina está instalado, cumple R6 y R7, y **no lo ha visto
nadie todavía**: lo que se ve al arrancar es un rectángulo negro.

Si esto pasa también en hardware real, el trabajo de Plymouth no se está viendo,
y el arranque de Encina OS es más feo que el de Ubuntu, no más bonito. Es lo
primero que hay que medir fuera de esta VM.

**3. GDM lleva la encina, y también el naranja de Ubuntu.** El logotipo está
abajo y se lee bien. Pero:

- **el recuadro de selección del usuario es naranja Yaru**, en mitad de la
  pantalla, y es lo que más se mira;
- **el `banner-message-text='Encina OS'` no aparece** por ningún sitio, aunque
  `banner-message-enable` está a `true`;
- **el fondo no es `encina-dark.jpg`**: es un negro liso. O sea que el
  `org/gnome/desktop/background` del perfil de GDM parece **un no-op**, que era
  justo la sospecha escrita en `tareas/aspecto/4-arranque-y-sesion.md`.

## El control, y qué se aceptó como igual

Dos pasadas seguidas, sin tocar nada:

```
[OMIT]  01-fase.png: transitoria (1 y 1 fotogramas) -- no es una pantalla
[OK]    02-fase.png: identica byte a byte
[AVISO] 03-fase.png: 379 pixeles, todos en la franja de arriba -- reloj y barra de UTM
rc=0   y con el rojo probado: la misma fase volteada -> [FALLO] y rc=1
```

Dos criterios, y los dos costaron un defecto del instrumento antes de existir:

- **La franja de arriba (130 px) no cuenta.** Ahí viven el reloj del invitado y
  la barra de la ventana de UTM, y ninguno es el producto. El número sale de
  medir: `diferencia.py` situó las diferencias en la caja `y 6..119`.
- **Una fase de un solo fotograma no es una pantalla.** La primera es la barra de
  progreso del firmware, y salió al 65 % en una pasada y al 33 % en la otra:
  exigirle que coincida sería exigir que las dos dispararan en el mismo
  milisegundo.

## Lo que el instrumento todavía NO hace

- **No pasa de GDM.** Entrar en la sesión exige la contraseña del usuario, que no
  vive en este repositorio: `encina-95758c9e` se instaló contestando las cinco
  pantallas a mano. **Faltan el escritorio, la rejilla y las dos ventanas** — la
  mitad de la lista canónica, y justo la mitad donde vive el tema.
- **Dispara cada 3,1 s de media**, así que una pantalla más corta que eso se
  pierde. Le pasó a la del firmware: salió en el reconocimiento y **no** en las
  dos pasadas buenas. Por eso viaja aquí con el nombre `reconocimiento-`, para
  que se sepa que no sale del mismo sitio que las otras tres.
