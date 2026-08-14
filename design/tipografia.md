# La tipografía

**Decisión abierta.** Aquí está lo que hay que decidir y con qué criterio, no lo
decidido.

## El problema

Hoy el sistema usa la tipografía **Ubuntu**, que es la que trae la base. Y es,
probablemente, **lo que más grita «Ubuntu» de todo el escritorio** — más que el
naranja, porque el naranja se ve y la letra se lee sin mirarla. Está en cada
título de ventana, en cada menú y en cada botón del instalador.

Cambiarla es el cambio con más efecto y menos riesgo de todo el bloque: es un
valor de `gschema.override`, no toca ningún fichero ajeno y no puede romper nada.

*Precisión, para no pelearse con el problema equivocado:* la tipografía Ubuntu
tiene licencia libre (Ubuntu Font Licence) y **redistribuirla no es el problema**.
El problema es que es la cara de otro producto.

## Con qué criterio se elige

En este orden, y el primero manda:

1. **Que esté empaquetada en el archivo de Ubuntu.** Si no está, no entra: cada
   fuente nueva es una fila de `imagen/repo-manifiesto.tsv` y un `.deb` más en el
   medio. Una fuente descargada de una web no entra de ninguna manera.
2. **Que tenga los acentos, la ñ y el signo de apertura** —`¿` y `¡`— bien
   dibujados, no interpolados. Es un sistema en español.
3. **Que sea legible a 11 px en una pantalla mala**, porque el público de este
   producto no tiene un monitor bueno.
4. **Que no sea la de nadie.** Ni la de Ubuntu, ni San Francisco (R8), ni
   Segoe.
5. Que sea sobria. Nada con personalidad: la personalidad la pone el logotipo.

## Candidatas

**Sin medir ninguna.** Lo primero que hay que hacer es comprobar cuáles existen
como `.deb` en el archivo de 24.04, porque eso descarta solo.

| Candidata | A favor | En contra |
|---|---|---|
| **Cantarell** | Es la de GNOME: está en el archivo seguro, encaja con todo y no es de nadie en particular | Es *tan* neutra que no aporta nada. Y dice «GNOME de serie» |
| **Inter** | Excelente a tamaño pequeño, muy legible, aspecto contemporáneo sin ser llamativo | Hay que comprobar que está empaquetada en 24.04 |
| **Source Sans 3** | Sobria, buen juego de acentos, licencia OFL, muy probada | Menos carácter |
| **Noto Sans** | Está segurísimo en el archivo, cobertura enorme | Es la más genérica de todas |

**El monoespaciado se elige aparte**, y sí importa: la terminal y el verificador
son parte de la cara del producto para quien lo construye.

## Hecha cuando

Está en [../tareas/aspecto/2-golpes-baratos.md](../tareas/aspecto/2-golpes-baratos.md).
Resumida: la fuente elegida está en el archivo con su `.deb`, viaja con su huella
en `imagen/repo-manifiesto.tsv`, el `gschema.override` la fija **con su sección
`:ubuntu`** —si no, gana la de Ubuntu y `gsettings get` desde una terminal
miente— y se ve en la captura.
