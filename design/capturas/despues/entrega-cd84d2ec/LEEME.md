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
  `GRUB_DISTRIBUTOR`. Es la casilla abierta de [../../../../tareas/aspecto/5-cierre.md](../../../../tareas/aspecto/5-cierre.md).

**Y el veredicto de las cuatro `[OJOS]` NO ESTÁ DADO.** Estas capturas se toman,
se guardan y se ponen delante; quien dice si valen es Jorge.

---

## EL VEREDICTO DE JORGE, 2026-08-22

**Las seis, vistas. Aprobadas, con dos salvedades y ninguna de ellas oculta.**

| | Qué dijo |
|---|---|
| `04` escritorio · `05` rejilla · `06` archivos · `01` firmware | **Bien** |
| `03` GDM | **Bien, con salvedad:** *«es cierto que el recuadro en GDM es naranja, pero es un mal menor»*. **Se acepta como está** y deja de ser una casilla |
| `02` Plymouth | **NO SE PUEDE JUZGAR AQUÍ. Aplazado por escrito**, ver abajo |

### El aplazamiento de Plymouth, con su condición de salida

*«No lo voy a poder probar hasta que no tengamos la ISO y lo pueda instalar en
hierro.»*

**No es un pendiente suelto: es un aplazamiento con condición.** Lo que se sabe,
medido dos veces esta noche y byte a byte idéntico entre las dos pasadas: **del
segundo 8 al 21 la pantalla del invitado está apagada** («Display output is not
active») y el tema de arranque de Encina **no se ve**. Lo que **no** se sabe es
de quién es el fallo:

- **si es del banco**, es un artefacto de la máquina virtual de UTM y el producto
  está bien;
- **si es del producto**, el arranque de Encina OS es **más feo** que el de
  Ubuntu, no más bonito.

**Y no se puede separar aquí**, porque las dos hipótesis producen exactamente la
misma captura. **Se desbloquea con una sola cosa: instalar en hierro.** Hasta
entonces, `02-pantalla-apagada.png` se queda **sin veredicto** y no cuenta ni a
favor ni en contra. *Es la misma advertencia que ya dejó escrita
`../../LEEME.md` el 2026-08-14 —«es lo primero que hay que medir fuera de esta
VM»— y sigue siendo verdad ocho días después.*
