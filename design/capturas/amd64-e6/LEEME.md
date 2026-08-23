# E6 — las tres capturas del primer medio `amd64` (2026-08-22, noche)

Tomadas en **UTM con el invitado x86_64 EMULADO** sobre Apple Silicon
(`Hypervisor=false`, `q35`, `virtio-vga`, firmware `edk2-i386-vars.fd`). El banco
lo fabrica `scripts/fabricar-vm-medio.py --arq amd64`, sin CIDATA: lo que arranca
sale de dentro del medio.

| fichero | qué es | cuándo |
|---|---|---|
| `01-control-oficial-amd64-instalador-en-ingles.png` | **EL CONTROL, y va delante.** La ISO **oficial** `ubuntu-24.04.4-desktop-amd64.iso` sin tocar, en un bundle hecho igual. Llega a «Welcome to Ubuntu / Choose your language», **en inglés**, que es lo que tiene que hacer | t+286 s |
| `02-medio-encina-amd64-el-instalador-se-cae.png` | El medio nuestro `encina-os-amd64.iso` `8924f148…`: fondo de Encina, reloj **«22 de ago»** —o sea `locale=es_ES.UTF-8` puesto en las DOS líneas de núcleo— y **«Se produjo un problema»** | t+338 s |
| `03-medio-encina-amd64-sesion-viva-con-la-marca.png` | Detrás de ese diálogo hay una **sesión viva de Encina OS entera**: el paisaje, «ENCINA OS / Versión 24.04 LTS / Edición ‘La Mancha’» y el lanzador con Firefox y Thunderbird | t+~11 min |

## Lo que estas tres dicen, y lo que NO dicen

**Dicen** que el medio `amd64` **arranca**, que la marca viaja y se monta, y que
el idioma se aplica. La 03 es la prueba de que la capa de marca (D23) se monta en
`amd64` igual que en `arm64`.

**NO dicen de quién es el fallo del instalador**, y aquí hay que ser exacto: el
control **no lo separa**. La ISO oficial se quedó en la primera pantalla porque
**no lleva `autoinstall.yaml`**, así que nunca recorrió el camino donde el
nuestro se cae. Un control que no ejercita el mismo camino no es el control de
este fallo. El que haría falta está escrito en `MEDICIONES.md` §4.64 (l).

**Y no dicen nada de Plymouth.** Sigue sin veredicto y sigue siendo `[OJOS]` de
Jorge en hierro.

---

## Cuatro más, del 2026-08-23, y son las que contestan «de quién es»

| fichero | qué es |
|---|---|
| `04-control-oficial-lento-plymouthd-abortado.png` | **La ISO OFICIAL `amd64`, sin una línea de Encina**, con 2 CPU: `plymouthd` **aborta** y deja su volcado y su backtrace en la consola |
| `05-control-oficial-lento-sesion-grafica-muerta.png` | La misma máquina 30 min después: **«Oh no! Something has gone wrong»** |
| `06-nuestro-medio-sesion-grafica-muerta.png` | **La misma pantalla, con nuestro medio** —«Algo salió mal», en español— del arranque de las 02:34 |
| `07-nuestro-medio-el-instalador-NO-se-cae.png` | Y el arranque de las 03:11, **con el mismo medio y el mismo bundle**: «Disposición del teclado», en español. Estuvo así **5 h 33 min sin que nadie lo tocara** |

**Lo que dicen las cuatro juntas, y es lo que la 02 no podía decir:** el fallo
**no se reproduce** —mismo bundle, tres resultados— y la familia de fallos
gráficos **se reproduce en la ISO oficial**. El conteo va **2 de 4** el nuestro y
**1 de 2** la oficial. `MEDICIONES.md` §4.65 (h) y (p).

**Y siguen sin decir nada de Plymouth como `[OJOS]`:** que el `splash` del
`amd64` emulado enseñe el logotipo del firmware y la palabra «Ubuntu» se vio en
un arranque **que acabó con la sesión muerta**, así que no vale de veredicto.
