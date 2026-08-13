#!/usr/bin/env python3
# Dice DONDE cambian dos PNG, sin dependencias: decodifica el PNG a mano
# (zlib + los cinco filtros) y devuelve la caja que encierra las diferencias.
# Sirve para localizar el anillo de foco de GTK, que es invisible al OCR.
import sys, zlib, struct

def leer(ruta):
    d = open(ruta, "rb").read()
    assert d[:8] == b"\x89PNG\r\n\x1a\n", "no es PNG"
    i, idat, w = 8, b"", None
    while i < len(d):
        ln = struct.unpack(">I", d[i:i+4])[0]
        tipo = d[i+4:i+8]
        dat = d[i+8:i+8+ln]
        if tipo == b"IHDR":
            w, h, prof, color = struct.unpack(">IIBB", dat[:10])
            assert prof == 8, f"profundidad {prof} no soportada"
            canales = {0:1, 2:3, 3:1, 4:2, 6:4}[color]
        elif tipo == b"IDAT":
            idat += dat
        elif tipo == b"IEND":
            break
        i += 12 + ln
    raw = zlib.decompress(idat)
    bpp = canales
    ancho_linea = w * bpp
    out = bytearray(h * ancho_linea)
    prev = bytearray(ancho_linea)
    p = 0
    for y in range(h):
        f = raw[p]; p += 1
        linea = bytearray(raw[p:p+ancho_linea]); p += ancho_linea
        if f == 1:
            for x in range(bpp, ancho_linea): linea[x] = (linea[x] + linea[x-bpp]) & 255
        elif f == 2:
            for x in range(ancho_linea): linea[x] = (linea[x] + prev[x]) & 255
        elif f == 3:
            for x in range(ancho_linea):
                a = linea[x-bpp] if x >= bpp else 0
                linea[x] = (linea[x] + ((a + prev[x]) >> 1)) & 255
        elif f == 4:
            for x in range(ancho_linea):
                a = linea[x-bpp] if x >= bpp else 0
                b = prev[x]
                c = prev[x-bpp] if x >= bpp else 0
                pa, pb, pc = abs(b-c), abs(a-c), abs(a+b-2*c)
                pr = a if (pa <= pb and pa <= pc) else (b if pb <= pc else c)
                linea[x] = (linea[x] + pr) & 255
        out[y*ancho_linea:(y+1)*ancho_linea] = linea
        prev = linea
    return w, h, bpp, bytes(out)

w1, h1, b1, a = leer(sys.argv[1])
w2, h2, b2, b = leer(sys.argv[2])
if (w1, h1, b1) != (w2, h2, b2):
    print("tamanos distintos:", (w1, h1, b1), (w2, h2, b2)); sys.exit(1)

UM = 24   # umbral por canal, para no perseguir ruido de compresion
xmin = ymin = 10**9; xmax = ymax = -1; n = 0
paso = b1
ancho_linea = w1 * b1
for y in range(h1):
    fila = y * ancho_linea
    for x in range(w1):
        o = fila + x*paso
        if abs(a[o]-b[o]) > UM or abs(a[o+1]-b[o+1]) > UM or abs(a[o+2]-b[o+2]) > UM:
            n += 1
            if x < xmin: xmin = x
            if x > xmax: xmax = x
            if y < ymin: ymin = y
            if y > ymax: ymax = y
if n == 0:
    print("IGUALES: 0 pixeles distintos")
else:
    print(f"pixeles distintos: {n}")
    print(f"caja: x {xmin}..{xmax}   y {ymin}..{ymax}   (centro {(xmin+xmax)//2},{(ymin+ymax)//2})")
