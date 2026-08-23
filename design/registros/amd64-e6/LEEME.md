# E6 — los registros de dentro, leídos sin ratón (2026-08-23)

Cuatro ficheros, dos de cada máquina, sacados **de la sesión viva** del invitado
`x86_64` emulado con `Alt+F2` → `wget --post-file` contra un buzón del Mac
(`MEDICIONES.md` §4.65i). No son capturas: son los ficheros.

| fichero | de qué máquina |
|---|---|
| `nuestro-medio-*` | `medios/encina-os-amd64.iso` `8924f148…`, arranque del 2026-08-23 03:11 |
| `control-oficial-*` | `medios/ubuntu-24.04.4-desktop-amd64.iso` **sin tocar**, arranque del 2026-08-23 08:56 |

**Para qué sirven, y es una sola cosa:** el `ubuntu_bootstrap.log` es el del
**frontal** —`ubuntu-desktop-bootstrap`, el que enseñó «Se produjo un problema»
la noche del 22— y su tercera línea dice literalmente cuánto espera:

```
INFO subiquity_server: Waiting server up to 90 seconds
```

Y lo que tardó el servidor en aparecer, en este banco:

|  | reintentos | s hasta el zócalo | s hasta abrirlo |
|---|---|---|---|
| ISO **oficial** `amd64` | 82 | **84,26** | 93,91 |
| **nuestro** medio `amd64` | 81 | **82,03** | 92,55 |
| presupuesto del frontal | — | **90,00** | — |

**La oficial está PEOR que la nuestra.** El reloj de 90 s es de Ubuntu y el
margen se lo come el banco emulado, con Encina y sin Encina.

El `subiquity-server-info.log` es el del **servidor**, y ahí se ve la única
diferencia real entre las dos máquinas: `file /autoinstall.yaml` en la nuestra
contra `file None` en la oficial, y las cinco `interactive-sections` exactas.
