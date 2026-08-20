#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Encina OS - QUE HAY EN UNA CAPTURA: NEGRA, TEXTO o GRAFICA, contado y no a ojo.

    ./scripts/veredicto-pantalla.py <captura.png> [--recorte-superior N]

POR QUE EXISTE. Quince arranques mirados a ojo se cuentan mal, y el 2026-08-20
un solo arranque negro tomado por un negativo costo una causa falsa que duro dos
horas (MEDICIONES.md 4.58j-l, trampa 42). Para CONTAR arranques hace falta un
veredicto que no dependa de que alguien mire.

POR QUE NO SIRVE EL TAMANO DEL PNG, que es lo que parecia (trampa 41). El tamano
solo distingue las tres pantallas A ESCALA FIJA: el 2026-08-19 una pantalla
GRAFICA dio 309 568 bytes -- dentro del rango que la trampa 41 asignaba a
"registro de texto" -- porque la ventana se capturo a 1280x840 y las otras a
2560x1680. La ventana del anfitrion cambia de tamano sola.

LO QUE SE MIDE EN SU LUGAR: cuantos COLORES DISTINTOS hay, cuantizados a 5 bits
por canal para no perseguir ruido de compresion, mas el brillo medio. Medido
sobre las capturas del 2026-08-20 y las de hoy:

    pantalla negra de verdad        1 color      brillo   0,0
    instalador, fondo de Ubuntu   585 colores    brillo 176,7
    instalador, fondo de Encina  3 638 colores   brillo 194,6
    escritorio con la capa       4 349 colores   brillo  95,3

Son mas de dos ordenes de magnitud de separacion, y el conteo de colores NO
depende de la escala como el tamano: reducir una imagen no crea colores donde no
los hay. Aun asi la escala se controla, ver ESCALA mas abajo.

DE DONDE SE SACA LA CAPTURA, y esto es la mitad del instrumento. UTM escribe
'screenshot.png' dentro del bundle con el FRAMEBUFFER DEL INVITADO: 1280x800
fijos, sin la barra de la ventana del anfitrion y sin permiso de Grabacion de
Pantalla. La trampa 41 no le aplica porque no hay ventana de por medio. MEDIDO
hoy, y las dos mitades hacen falta:

  - NO se actualiza mientras la VM corre: tres minutos arrancada y el mtime
    seguia siendo el de ayer. Sirve para leerlo DESPUES de parar, no en vivo.
  - SI refleja el estado real al parar, y no un framebuffer ya apagado: parando
    'encina-capa-p12' desde el instalador escribio 3 638 colores, y parandola
    tras un arranque fallido escribio 1 color. Sin esta segunda mitad, el negro
    del arranque fallido se habria podido achacar al instrumento -- o peor, se
    habria contado un fallo que no lo era.

ESCALA. Se acepta cualquier tamano, pero se IMPRIME, porque comparar conteos
entre escalas distintas es justo lo que rompio la trampa 41. Para una captura de
la ventana del anfitrion (capturar-vm.sh) hay que quitar la barra de titulo con
--recorte-superior, o el cromo de UTM aporta colores que no son del invitado.

ZONA GRIS. Entre las dos bandas calibradas hay un hueco, y ahi el veredicto es
INDETERMINADA a proposito: un instrumento que se calla donde no sabe vale mas que
uno que decide. TEXTO se declara como banda pero NO tiene control conocido: sale
marcada y no se da por buena.

Codigo de salida: 0 si la captura se pudo leer, 1 si no. El veredicto va en la
salida, no en el codigo: esto LEE, no juzga si esta bien.
"""
import argparse
import os
import subprocess
import sys

# --- INICIO REGLA ---  (banco-veredicto.sh extrae de aqui a FIN REGLA)
# Los umbrales salen de los controles medidos arriba, y el hueco entre bandas es
# deliberado. NEGRA se cierra en la media geometrica entre el control negro (1
# color) y el control grafico mas pobre (585): sqrt(1*585) ~ 24.
NEGRA_COLORES = 24      # <= esto y con brillo bajo: negra
NEGRA_BRILLO = 16.0     # una negra de verdad da 0,0; el margen es para ruido
GRAFICA_COLORES = 300   # >= esto: sesion grafica (el control mas pobre da 585)
GRAFICA_BRILLO = 40.0   # una grafica ilumina; el control mas oscuro da 95,3
TEXTO_BRILLO = 60.0     # registro de systemd: blanco sobre negro, brillo bajo


def clasificar(colores, brillo):
    """(veredicto, por que). Las cuatro salidas son intencionadas."""
    if colores <= NEGRA_COLORES and brillo < NEGRA_BRILLO:
        return "NEGRA", f"{colores} colores <= {NEGRA_COLORES} y brillo {brillo:.1f} < {NEGRA_BRILLO}"
    if colores >= GRAFICA_COLORES and brillo > GRAFICA_BRILLO:
        return "GRAFICA", f"{colores} colores >= {GRAFICA_COLORES} y brillo {brillo:.1f} > {GRAFICA_BRILLO}"
    if colores > NEGRA_COLORES and brillo <= TEXTO_BRILLO:
        return "TEXTO?", f"{colores} colores y brillo {brillo:.1f} <= {TEXTO_BRILLO} -- BANDA SIN CONTROL, no se da por buena"
    return "INDETERMINADA", f"{colores} colores, brillo {brillo:.1f}: cae en el hueco entre bandas, hay que mirarla"
# --- FIN REGLA ---


def leer(ruta, recorte_superior=0):
    """(ancho, alto, colores distintos a 5 bits, brillo medio) via ffmpeg."""
    if not os.path.exists(ruta):
        print(f"[FALLO] no existe: {ruta}")
        sys.exit(1)
    dim = subprocess.run(
        ["ffprobe", "-v", "error", "-select_streams", "v",
         "-show_entries", "stream=width,height", "-of", "csv=p=0", ruta],
        capture_output=True, text=True)
    if dim.returncode != 0 or "," not in dim.stdout:
        print(f"[FALLO] ffprobe no pudo leer {ruta}: {dim.stderr.strip()}")
        sys.exit(1)
    ancho, alto = (int(v) for v in dim.stdout.strip().split(",")[:2])
    vf = "format=rgb24"
    if recorte_superior:
        # in_h-N: recorta por arriba, que es donde vive la barra de UTM.
        vf = f"crop=in_w:in_h-{recorte_superior}:0:{recorte_superior},{vf}"
        alto -= recorte_superior
    crudo = subprocess.run(
        ["ffmpeg", "-v", "error", "-i", ruta, "-vf", vf, "-f", "rawvideo", "-"],
        capture_output=True)
    d = crudo.stdout
    if len(d) < 3:
        print(f"[FALLO] ffmpeg no devolvio pixeles de {ruta}: {crudo.stderr.decode().strip()}")
        sys.exit(1)
    vistos = set()
    for i in range(0, len(d) - 2, 3):
        vistos.add((d[i] >> 3, d[i + 1] >> 3, d[i + 2] >> 3))
    return ancho, alto, len(vistos), sum(d) / len(d)


def main():
    p = argparse.ArgumentParser(add_help=True)
    p.add_argument("captura")
    p.add_argument("--recorte-superior", type=int, default=0,
                   help="filas a quitar por arriba (barra de la ventana de UTM)")
    p.add_argument("--tsv", action="store_true", help="una linea: veredicto TAB colores TAB brillo")
    a = p.parse_args()
    ancho, alto, colores, brillo = leer(a.captura, a.recorte_superior)
    veredicto, porque = clasificar(colores, brillo)
    if a.tsv:
        print(f"{veredicto}\t{colores}\t{brillo:.1f}\t{ancho}x{alto}")
    else:
        print(f"{veredicto}  ({porque})")
        print(f"  {ancho}x{alto}  {os.path.basename(a.captura)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
