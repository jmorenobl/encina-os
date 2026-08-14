# Las capturas

**Para qué existe este directorio:** para que «se ve mejor» deje de ser una
opinión. En todo lo demás este proyecto compara salidas literales; en lo visual
la única salida literal es una captura, y sin un «antes» guardado no hay con qué
comparar.

## Las seis pantallas canónicas

Siempre las mismas seis, siempre en el mismo orden y a la misma resolución. Si
se cambia la lista, se cambia para todas las tomas anteriores o dejan de ser
comparables.

| # | Pantalla | Por qué está |
|---|---|---|
| 1 | Menú de arranque (GRUB) | Es lo primero que se ve, y hoy dice Ubuntu |
| 2 | Arranque (Plymouth) | Ya lleva tema propio: hay que ver que se ve |
| 3 | Inicio de sesión (GDM) | Logo y banner puestos; el resto es del shell |
| 4 | Escritorio vacío | Fondo, dock, barra superior |
| 5 | Rejilla de aplicaciones | El botón del logotipo, y el conjunto de iconos |
| 6 | Una ventana GTK4 junto a una GTK3 | **La que decide el tema.** Archivos (GTK4) y una GTK3 lado a lado enseñan de un vistazo hasta dónde llega un tema en GNOME 46 |

La sexta es la que más informa y la que nadie hace: es la que contesta si merece
la pena empaquetar un tema GTK.

## Cómo se toman

Con el guion de [../../tareas/aspecto/1-instrumentacion.md](../../tareas/aspecto/1-instrumentacion.md),
que todavía no existe. Se apoya en `scripts/capturar-vm.sh` y
`scripts/teclear-vm.sh`, que sí.

**El control que hace que la comparación signifique algo:** dos pasadas seguidas
sin tocar nada tienen que dar seis capturas iguales. Si no, la diferencia que se
vea después puede ser del reloj, del puntero o de una notificación, y no del
cambio.

## Qué se versiona y qué no

- `antes/` y `despues/`: **el par canónico sí se versiona**, porque es la prueba
  de lo que se cambió y va al README.
- Las tomas intermedias del día a día, no. Se quedan en el disco.
