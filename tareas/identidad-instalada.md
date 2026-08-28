# La identidad de la MÁQUINA INSTALADA: `os-release` sigue diciendo Ubuntu

**Por qué este fichero existe y no cabía en ninguno de los que ya hay.**
[marca-del-medio.md](marca-del-medio.md) es del **medio** y está cerrado salvo
sus `[OJOS]`; `aspecto/` es de lo que se **ve** y también está cerrado;
[refactorizacion.md](cerradas/refactorizacion.md) es ordenar lo que ya funciona. Lo de
aquí no es ninguna de las tres: es una **deuda declarada** que hasta hoy no
tenía dónde vivir, y por eso se quedaba sin turno.

La deuda está escrita en dos sitios y con estas palabras:

> **D23:** *«el `os-release` del medio dice `NAME="Encina OS"` y el de la máquina
> instalada sigue diciendo `Ubuntu` … **El medio y la máquina no dicen lo mismo, y
> eso es una deuda declarada, no un descuido.**»*

> **§8:** *«Lo que sigue fuera de alcance es **el mecanismo** … Elegir entre
> divertir desde un paquete y escribir el fichero en la construcción de la imagen
> es de las casillas 3 y 4 del bloque 1, no de aquí.»*

**Lo que hay hoy, leído y no supuesto:**

| Dónde | Qué dice | Leído en |
|---|---|---|
| el **medio** | `NAME="Encina OS"`, `LOGO=encina-logo`, **`ID=ubuntu`**, `ID_LIKE=debian` | [imagen/marca/sistema/usr/lib/os-release](../imagen/marca/sistema/usr/lib/os-release) |
| la **máquina instalada** | `NAME="Ubuntu"` entero, sin tocar | D23, y `encina-branding` no lo toca |
| la regla | **R5: *«`os-release` con `dpkg-divert`»*** — el mecanismo está **prescrito**, no prohibido | `ENCINA-OS.md` §5 |
| la guardia | `[FALLO] R5 — el paquete toca os-release` si un paquete **lleva** el fichero en `src/` | [scripts/construir-branding.sh:97](../scripts/construir-branding.sh#L97) |

O sea que la guardia vigila que nadie lo **sobrescriba**, no que nadie lo
**divierta**. Eso ya estaba bien escrito y conviene no volver a leerlo al revés.

**DE DÓNDE SALE ESTE BLOQUE, 2026-08-23.** Lo abre Jorge con una propuesta
concreta: *«`ID` debería ser `encina` y `ID_LIKE` `ubuntu`»*. La propuesta choca
de frente con **D6**, que lleva desde el principio diciendo lo contrario, así que
lo primero no es hacerla ni descartarla: es mirar sobre qué descansa D6.

**Y descansa sobre una deducción.** Su motivo entero, citado:

> *«Software de terceros comprueba ese campo; cambiarlo produce fallos inconexos
> durante meses.»*

**No tiene ningún `§N.NN` detrás.** Es plausible —lo bastante como para que nadie
la haya discutido en un año— pero en este repositorio *lo medido y lo deducido
van separados*, y **D6 es de las pocas decisiones que están enteras del lado
deducido**. Eso es lo que hace que la pregunta de Jorge sea legítima y lo que
decide el orden de las dos casillas de abajo: **primero se mide, y la medida
decide**.

**LO QUE ESTE BLOQUE NO ES, y va escrito para que no se cuele en la lista
equivocada: `ID` NO lo pide D22.** La política de Canonical no lo alcanza, y D22
lo clasifica en **pila C** con estas palabras: *«procedencia técnica — **se
queda, y quedarse es lo correcto**»*. Así que esto **no bloquea publicar**: es
una decisión **de producto**, y su sitio está **detrás de la fase 1**.

---

- [ ] **Medir quién lee `ID` de verdad, que es lo que D6 nunca midió.**
      Sobre una máquina **ya instalada** del banco —no hace falta refabricar
      nada, ni una ISO, ni una VM nueva—: **quién lee `/etc/os-release`, cuáles
      de esos se bifurcan por `ID`, y cuántos de esos leen también `ID_LIKE`**.
      Esa última columna es la que decide, porque `ID_LIKE` existe justamente
      para que un script que no reconozca `ID` tenga a qué caer: **lo que rompe
      no es cambiar `ID`, es cambiarlo delante de alguien que no mira `ID_LIKE`.**
      *Por qué:* convierte D6 de plausibilidad en medida. Mientras no exista esta
      lista, cualquiera de las dos respuestas —cambiarlo o no— sustituye una
      deducción por otra, que es exactamente lo que este proyecto no hace.
      *Su control, y sin él no vale:* el buscador tiene que **saber decir cero**
      — una variable inventada da 0 apariciones y `PRETTY_NAME` da N, las dos
      medidas en la misma pasada y **delante** del inventario, como manda la CI.
      *La trampa conocida que aplica aquí, §9 de `MEDICIONES.md`:* **«un
      inventario que cuenta SITIOS y no VALORES»**. Un fichero que *menciona*
      `os-release` no es un fichero que se *bifurque* por `ID`; la lista tiene que
      llevar **la línea** de cada uno, no su nombre. Y los binarios no se leen con
      un `grep` de texto — el inventario del medio ya se comió esa (§4.51a).
      *La fila que pesa más que todas las demás, y se mide aparte y por su
      nombre:* **AutoFirma y la cadena de la firma** —el `.deb` de
      `~/Projects/encina-autofirma`, su `postinst`, el vigilante y el almacén
      NSS—. Si algo ahí se bifurca por `ID`, el fallo es **silencioso** y la
      víctima es una gestoría con un plazo, que es el modo de fallo más caro que
      tiene este producto. **`apt` no entra en el riesgo** y eso también se dice:
      decide por el `Release` firmado, no por `os-release`, así que el anclaje de
      Mozilla y el repo propio están a salvo pase lo que pase.
      *Hecha cuando:* hay una lista con **ruta y línea literal** de cada cosa que
      se bifurca por `ID`, partida en dos columnas —**«lee `ID_LIKE`»** y **«no lo
      lee»**—, con su control delante y con AutoFirma contestado por su nombre en
      vez de por omisión.

- [ ] **Decidir `ID` y `DISTRIB_ID` A LA VEZ, y escribirlo como decisión.**
      O `ID=encina` con `ID_LIKE="ubuntu debian"`, o **D6 se confirma — pero ya
      con su medida debajo**, que es lo que hoy le falta.
      *Por qué los dos juntos y no `ID` solo:* **D22 llama a `DISTRIB_ID` de
      `/etc/lsb-release` «su gemelo»** y lo mete en la misma pila C. Si `ID` pasa
      a `encina` y `DISTRIB_ID` se queda en `Ubuntu`, **la máquina contesta dos
      cosas distintas a dos preguntas igual de comunes** — y eso es peor que
      cualquiera de las dos respuestas coherentes. No se pueden decidir por
      separado sin crear un defecto nuevo.
      *Y la forma exacta, si sale que cambia:* **`ID_LIKE="ubuntu debian"`, no
      `ID_LIKE=ubuntu`.** Ubuntu de fábrica declara `ID_LIKE=debian`; si `ID`
      sube a `encina` y `ID_LIKE` sólo dice `ubuntu`, **se pierde el escalón a
      Debian que el sistema tenía gratis**. La especificación pide la lista
      ordenada del más cercano al más lejano, y con dos valores lleva comillas.
      *Lo que juega a favor de cambiarlo, y no se había dicho:* **el mecanismo ya
      está pagado.** La máquina instalada va a tener que divertir `os-release` de
      todas formas —D22 obliga a que `NAME`, `PRETTY_NAME`, `LOGO` y las cuatro
      URL de `ubuntu.com` cambien, y hoy siguen sin cambiar—. El día que ese
      `dpkg-divert` exista, **`ID` es una línea más del mismo fichero: coste de
      mecanismo cero**. La pregunta queda limpia: sólo *«¿qué se rompe?»*, que es
      lo que contesta la casilla de arriba.
      *Lo que juega en contra, y tampoco se maquilla:* **D3 dice que esto no es un
      fork**, y `ID=ubuntu` es la forma más honrada de decir *«esto ES Ubuntu con
      cuatro `.deb` encima»*. Cambiar `ID` es el primer paso que hace que las
      herramientas lo traten como una derivada **sin que lo sea de verdad**.
      *Hecha cuando:* hay **fila `D` en `ENCINA-OS.md`** —enmienda fechada a D6,
      con lo que se creía **dejado al lado** y no borrado, como manda el método—,
      y esa fila cita la medida de la casilla anterior en vez de una
      plausibilidad. **Es una decisión escrita, no una impresión.**

---

## LO QUE ESTE BLOQUE NO CIERRA, con su nombre

- **El `dpkg-divert` de `os-release` para la máquina instalada no tiene casilla
  en ninguna parte**, y es deuda de **D22**, no de aquí: `NAME`, `PRETTY_NAME`,
  `LOGO` y las cuatro URL de `ubuntu.com` siguen diciendo Ubuntu en el sistema
  instalado. Este bloque **decide qué valor lleva `ID`**; quién escribe el
  fichero y cuándo sigue siendo la deuda de §8. Cuando esa casilla nazca, la
  decisión de aquí se sube a ella y no cuesta una vuelta aparte.
- **Nada de esto se ve en pantalla**, así que **no hay `[OJOS]`**: `os-release`
  se lee con `grep`, y lo único que un ojo notaría es «Configuración → Acerca
  de», que es `PRETTY_NAME` y no `ID`.
