# El «después» de la vuelta única `arm64` — `encina-entrega-63f360dd`, 2026-08-25

Máquina fabricada con `scripts/fabricar-vm-medio.py` desde
`medios/encina-os-arm64.iso` (`63f360dd…`, `encina-branding` 0.1.17), forma E3,
sin CIDATA. Las cinco pantallas las contestó Jorge; el verificador y las
capturas de sesión las sacó el agente por teclas y por el buzón HTTP
(`MEDICIONES.md` §4.79 y su enmienda).

| Fichero | Qué es | Quién lo ha mirado |
|---|---|---|
| `00-medio-instalador-teclado.png` | La sesión viva del MEDIO a los ~2 min: «Disposición del teclado» en español, fondo de Encina, la bellota abajo a la izquierda | el agente; veredicto de Jorge pendiente |
| `04-escritorio.png` | La máquina INSTALADA, tras `exit` del terminal: fondo, «ENCINA OS / Versión 24.04 LTS / Edición ‘La Mancha’», dock con la bellota; sin bienvenida de Ubuntu | el agente; veredicto de Jorge pendiente |
| `05-rejilla.png` | `Super+A`: la bellota iluminada, AutoFirma en la rejilla, nombres en español | el agente; veredicto de Jorge pendiente |
| `06-archivos.png` | `Alt+F2` → `nautilus`: carpetas en salvia; el medio «EncinaOS 0…» montado | el agente; veredicto de Jorge pendiente |
| `verificar-instalacion-e3-27.txt` | La salida entera del verificador dentro, como root: **65 / 0 / 0 / 0, rc=0** | instrumento |
| `buzon-control-invitado-hostname.txt` | El tercer control del buzón: `/etc/hostname` del invitado, llegado desde `192.168.64.26` antes de la medición | instrumento |

**Faltan `01-firmware`, `02-pantalla-apagada` y `03-gdm`**: las toma
`capturar-aspecto.sh` reiniciando la VM, y no se reinició sin preguntar. Plymouth
aquí sigue sin veredicto posible (§4.63s); en hierro `amd64` ya está cobrado
(§4.70a).

**El veredicto de Jorge NO ESTÁ DADO.** Estas capturas se toman, se guardan y se
ponen delante.
