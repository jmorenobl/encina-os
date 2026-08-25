# El «después» de la vuelta única `arm64` — `encina-entrega-63f360dd`, 2026-08-25

Máquina fabricada con `scripts/fabricar-vm-medio.py` desde
`medios/encina-os-arm64.iso` (`63f360dd…`, `encina-branding` 0.1.17), forma E3,
sin CIDATA. Las cinco pantallas las contestó Jorge; el verificador y las
capturas de sesión las sacó el agente por teclas y por el buzón HTTP
(`MEDICIONES.md` §4.79 y su enmienda).

| Fichero | Qué es | Quién lo ha mirado |
|---|---|---|
| `00-medio-instalador-teclado.png` | La sesión viva del MEDIO a los ~2 min: «Disposición del teclado» en español, fondo de Encina, la bellota abajo a la izquierda | el agente; veredicto de Jorge pendiente |
| `01-firmware.png` | 6–7 s, «Start boot option», 1 fotograma en las dos pasadas | transitoria: no es una pantalla (`[OMIT]`) |
| `01b-firmware-bdsdxe.png` | 10 s, `BdsDxe: loading Boot0005 "Ubuntu"…`, 1 fotograma (sólo la pasada 1 lo cazó) | transitoria; el firmware dice *Ubuntu* y `GRUB_DISTRIBUTOR` no lo toca |
| `02-pantalla-apagada.png` | 9–39 s, «Display output is not active»; **0 píxeles distintos** entre pasadas | `[OJOS]` sin veredicto posible aquí: Plymouth no se ve (§4.63s); cobrado en hierro amd64 (§4.70a) |
| `03-gdm.png` | 24–82 s: la encina abajo, usuario «Encina», recuadro naranja, sin banner; 264 px distintos entre pasadas, todos en la franja del reloj | el agente; veredicto de Jorge pendiente (el recuadro ya se aceptó el 2026-08-22) |
| `04-escritorio.png` | La máquina INSTALADA, tras `exit` del terminal: fondo, «ENCINA OS / Versión 24.04 LTS / Edición ‘La Mancha’», dock con la bellota; sin bienvenida de Ubuntu | el agente; veredicto de Jorge pendiente |
| `05-rejilla.png` | `Super+A`: la bellota iluminada, AutoFirma en la rejilla, nombres en español | el agente; veredicto de Jorge pendiente |
| `06-archivos.png` | `Alt+F2` → `nautilus`: carpetas en salvia; el medio «EncinaOS 0…» montado | el agente; veredicto de Jorge pendiente |
| `verificar-instalacion-e3-27.txt` | La salida entera del verificador dentro, como root: **65 / 0 / 0 / 0, rc=0** | instrumento |
| `buzon-control-invitado-hostname.txt` | El tercer control del buzón: `/etc/hostname` del invitado, llegado desde `192.168.64.26` antes de la medición | instrumento |

**El control de las tres del arranque:** dos pasadas seguidas de
`capturar-aspecto.sh` (Jorge autorizó el reinicio), comparadas por contenido con
`diferencia.py`; las tablas de fases en `fases-pasada1.tsv` y `fases-pasada2.tsv`.

## EL VEREDICTO DE JORGE, 2026-08-25

**«Las capturas las veo todas bien.»** Las siete (`00`–`06`), aprobadas. Con
ello se cierran las casillas «Instalar desde cero y mirar la pantalla» de
`tareas/aspecto/5-cierre.md` y «El arranque y el instalador, con identidad de
Encina» de `tareas/marca-del-medio.md`. `02` (Plymouth) se aprueba como lo que
es: apagada en la VM, y cobrada en hierro `amd64` (§4.70a).
