#!/usr/bin/env python3
"""zona-segura.py — ¿cabe la marca del fondo dentro de lo que NO recorta 'zoom'?

    ./scripts/zona-segura.py <maestro-claro.png> <maestro-oscuro.png> [--dibujar salida.png]

POR QUE EXISTE. 'picture-options' está en 'zoom': GNOME rellena la pantalla y
recorta lo que sobra, así que una imagen 16:9 solo se ve entera en una pantalla
16:9 exactamente. El 2026-08-15 eso se descubrió MIRANDO UNA CAPTURA —la bellota
del logotipo salía cortada por el borde izquierdo—, y una cosa que se descubre
mirando es una cosa que la próxima vez no se descubre. Esto la mide.

LA ZONA SEGURA es el recuadro que sobrevive a la vez al 4:3 y al 21:9, los dos
extremos razonables. Sobre 3840x2160:  x 480..3360,  y 257..1903. La tabla por
proporción y de dónde salen esos números están en design/fondos/LEEME.md.

COMO SE LOCALIZA LA MARCA, y por que hacen falta LAS DOS IMAGENES. El primer
intento buscaba «lo blanco» y «lo brillante», y las dos cosas fallaron con su
control delante: cogían las nubes doradas, las casas blancas del pueblo y el
campo iluminado, y devolvían una caja del ancho entero. Lo que sí distingue a la
marca es que ES LO UNICO IGUAL EN LAS DOS IMAGENES: el paisaje es de día en una
y de noche en la otra, y el logotipo es el mismo. Así que se comparan píxel a
píxel y se queda lo que coincide y además es claro.

Eso deja todavía píxeles sueltos coincidiendo por casualidad, así que se dilata
la máscara para que las letras sueltas formen un grupo, se agrupa por vecindad y
SE DESCARTAN LOS GRUPOS PEQUEÑOS. Lo que queda son cuatro: el logotipo, las dos
partes del nombre y el bloque de dos líneas de abajo.

El umbral son 100 píxeles a esta escala, y no es redondo por gusto: con 40 se
colaba un grupo de 56 arriba a la derecha —la luna del maestro oscuro cae sobre
una nube clara del maestro de día, y coinciden—, que estiraba la caja hasta
x=3248 sin cambiar el veredicto pero contando una mentira. El grupo real más
pequeño tiene 239. Cien deja fuera cualquier cosa menor que una letra.

EL CONTROL, y sin él esto no vale nada: con --dibujar sale un PNG con la caja
detectada y la zona segura encima; si la detección se equivoca, se ve. Y la
prueba de que sabe decir que no es el par de maestros del 2026-08-15 por la
mañana, que da FALLO con la marca a 136 px del borde.

No usa Pillow: no está en este Mac. Lee los píxeles con ffmpeg, que sí está.
"""
import subprocess
import sys
from collections import deque

ANCHO, ALTO = 3840, 2160
SEGURA = (480, 257, 3360, 1903)   # x0, y0, x1, y1
W, H = 960, 540                   # se analiza reducido: 4 px de resolución, y basta
IGUAL = 10                        # diferencia máxima por canal para considerar «lo mismo»
CLARO = 110                       # la marca es clara; esto quita coincidencias en sombras
DILATA = 5                        # radio para unir letras sueltas en un grupo
MINIMO = 100                      # grupos más pequeños que una letra: ruido, fuera


def pixeles(ruta):
    orden = ["ffmpeg", "-hide_banner", "-v", "error", "-i", ruta,
             "-vf", f"scale={W}:{H},format=rgb24", "-f", "rawvideo", "-"]
    return subprocess.run(orden, capture_output=True, check=True).stdout


def mascara(claro, oscuro):
    a, b = pixeles(claro), pixeles(oscuro)
    m = bytearray(W * H)
    for y in range(H):
        for x in range(W):
            i = (y * W + x) * 3
            if (abs(a[i] - b[i]) <= IGUAL and abs(a[i + 1] - b[i + 1]) <= IGUAL
                    and abs(a[i + 2] - b[i + 2]) <= IGUAL
                    and min(a[i], a[i + 1], a[i + 2]) >= CLARO):
                m[y * W + x] = 1
    return m


def grupos(m):
    d = bytearray(W * H)
    for y in range(H):
        for x in range(W):
            if m[y * W + x]:
                for dy in range(-DILATA, DILATA + 1):
                    yy = y + dy
                    if 0 <= yy < H:
                        for dx in range(-DILATA, DILATA + 1):
                            xx = x + dx
                            if 0 <= xx < W:
                                d[yy * W + xx] = 1
    vis, fuera = bytearray(W * H), []
    for y in range(H):
        for x in range(W):
            if d[y * W + x] and not vis[y * W + x]:
                q, pts = deque([(x, y)]), []
                vis[y * W + x] = 1
                while q:
                    cx, cy = q.popleft()
                    if m[cy * W + cx]:
                        pts.append((cx, cy))
                    for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                        nx, ny = cx + dx, cy + dy
                        if 0 <= nx < W and 0 <= ny < H and d[ny * W + nx] and not vis[ny * W + nx]:
                            vis[ny * W + nx] = 1
                            q.append((nx, ny))
                if len(pts) >= MINIMO:
                    fuera.append(pts)
    return sorted(fuera, key=len, reverse=True)


def caja(pts):
    k = ANCHO / W
    xs, ys = [p[0] for p in pts], [p[1] for p in pts]
    return (int(min(xs) * k), int(min(ys) * k), int(max(xs) * k), int(max(ys) * k))


def main():
    if len(sys.argv) < 3:
        print("uso: zona-segura.py <maestro-claro.png> <maestro-oscuro.png> [--dibujar salida.png]")
        return 2
    claro, oscuro = sys.argv[1], sys.argv[2]
    dibujar = sys.argv[sys.argv.index("--dibujar") + 1] if "--dibujar" in sys.argv else None

    gs = grupos(mascara(claro, oscuro))
    if not gs:
        print("[FALLO] no se ha encontrado ninguna marca: ¿son estas dos el mismo par?")
        return 1

    cajas = [caja(g) for g in gs]
    total = (min(c[0] for c in cajas), min(c[1] for c in cajas),
             max(c[2] for c in cajas), max(c[3] for c in cajas))

    print(f"zona segura   x {SEGURA[0]}..{SEGURA[2]}   y {SEGURA[1]}..{SEGURA[3]}")
    for i, (c, g) in enumerate(zip(cajas, gs), 1):
        print(f"  grupo {i}     x {c[0]}..{c[2]}   y {c[1]}..{c[3]}   ({len(g)} px)")
    print(f"marca entera  x {total[0]}..{total[2]}   y {total[1]}..{total[3]}")

    margen = (total[0] - SEGURA[0], total[1] - SEGURA[1],
              SEGURA[2] - total[2], SEGURA[3] - total[3])
    print(f"margenes      izq {margen[0]}  arr {margen[1]}  der {margen[2]}  abj {margen[3]}  "
          f"(la medida tiene {ANCHO // W} px de resolucion)")

    codigo = 0
    if min(margen) < 0:
        print("[FALLO] la marca SE SALE de la zona segura: se cortara en pantallas que no sean 16:9")
        codigo = 1
    else:
        print("[OK]    la marca cabe entera en la zona segura")

    if dibujar:
        filtro = (f"drawbox=x={SEGURA[0]}:y={SEGURA[1]}:w={SEGURA[2]-SEGURA[0]}:"
                  f"h={SEGURA[3]-SEGURA[1]}:color=lime:t=8,"
                  f"drawbox=x={total[0]}:y={total[1]}:w={total[2]-total[0]}:"
                  f"h={total[3]-total[1]}:color=white:t=6,scale=1920:1080")
        subprocess.run(["ffmpeg", "-hide_banner", "-v", "error", "-y", "-i", claro,
                        "-vf", filtro, dibujar], check=True)
        print(f"[OJOS]  {dibujar}: la caja blanca tiene que rodear la marca y nada mas")
    return codigo


if __name__ == "__main__":
    sys.exit(main())
