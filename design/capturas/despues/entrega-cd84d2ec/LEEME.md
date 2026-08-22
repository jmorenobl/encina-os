# El «después» de la ENTREGA — `encina-entrega-cd84d2ec`, 2026-08-22

**Qué las distingue de las de `../`:** aquéllas son del banco —`encina-95758c9e`
y `encina-dev`, con `encina-branding` 0.1.10/0.1.11/0.1.15 instalado *encima*—.
**Éstas salen de la máquina del producto**: instalada desde
`medios/encina-os-libnss3.iso` (`cd84d2ec…`) en forma E3, con las cinco pantallas
contestadas por Jorge, y verificada dentro como root con
**`[OK] 63  [FALLO] 0  [AVISO] 0  [OMIT] 0`** (`MEDICIONES.md` §4.63p).

| Fichero | Cuándo | El «antes» decía | Qué hay que mirar |
|---|---|---|---|
| `01-firmware.png` | 5–6 s | barra «Start boot option» | **`[OMIT]`, no es una pantalla:** 1 fotograma en las dos pasadas. El firmware dice *Ubuntu* dos veces y eso **no lo arregla `GRUB_DISTRIBUTOR`** |
| `02-pantalla-apagada.png` | 8–21 s | «Display output is not active» | **`[OJOS]`. SIGUE IGUAL: Plymouth no se ve** |
| `03-gdm.png` | 22–81 s | la encina abajo, recuadro naranja, sin banner, fondo negro | **`[OJOS]`.** El recuadro, el `banner-message-text` y el fondo |
| `04-escritorio.png` | tras entrar | «Le damos la bienvenida a **Ubuntu**» a pantalla completa | El fondo de Encina y **el dock**: la bolsa verde del Centro de aplicaciones |
| `05-rejilla.png` | `Super+A` | el botón con el logo de Ubuntu (mal leído, §4.43) | **`[OJOS]`.** La bellota **iluminada**, y AutoFirma dentro |
| `06-archivos.png` | `Alt+F2` → `nautilus` | carpetas **berenjena** de Yaru | **`[OJOS]`.** Si con el acento `Yaru-sage` salen ya en salvia |

## El control, que es lo que hace que las tres del arranque signifiquen algo

**Dos pasadas seguidas sin tocar nada**, y las dos dan **tres fases**:

```
                         pasada 1        pasada 2      diferencia.py
01 firmware   1 fotograma en las dos, sha distinto     22 510 px  -> TRANSITORIA, no cuenta
02 apagada    5 fotogramas   5 fotogramas              0 px, IDENTICA byte a byte
03 GDM       18 fotogramas  19 fotogramas              400 px en y 100..119  <- EL RELOJ
```

Los dos criterios son los de `../../LEEME.md` y no se inventan aquí: **la franja
de arriba (130 px) no cuenta** —ahí viven el reloj del invitado y la barra de
UTM— y **una fase de un solo fotograma no es una pantalla**.

## Lo que ya está contestado, y lo que no

- **La bienvenida de Ubuntu NO SALE.** El escritorio entra directo. *Con una
  salvedad honesta: la **primera** sesión de esta máquina la abrió el agente a
  las 11:07 UTC pasando el verificador, no esta captura.* Aquélla ya salió sin
  bienvenida, y está en el rastro de la sesión.
- **Plymouth sigue sin verse**, igual que en el «antes». *Y sigue sin saberse si
  es del producto o del banco:* esto es una VM de UTM, y el «antes» ya dejó
  escrito que **lo primero es medirlo fuera de esta VM**.
- **Lo que ninguna de estas capturas prueba:** el verificador de la máquina
  **no mira el aspecto** —sus 63 correctas son paquetes, Firefox, el manejador
  del PDF y el tema de iconos—. Ni fondo, ni GDM, ni Plymouth, ni
  `GRUB_DISTRIBUTOR`. Es la casilla abierta de [../../../tareas/aspecto/5-cierre.md](../../../tareas/aspecto/5-cierre.md).

**Y el veredicto de las cuatro `[OJOS]` NO ESTÁ DADO.** Estas capturas se toman,
se guardan y se ponen delante; quien dice si valen es Jorge.
