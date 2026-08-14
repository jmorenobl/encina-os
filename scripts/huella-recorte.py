#!/usr/bin/env python3
# La huella sha256 de un PNG SIN sus primeras N filas, sin dependencias.
#
#     huella-recorte.py <fichero.png> <filas a descartar>
#
# POR QUE NO LO HACE sips, QUE ES LO QUE PARECIA (medido el 2026-08-14):
# 'sips --cropOffset 130 0 -c 1280 2560 x.png --out y.png' devuelve el fichero
# ENTERO, byte a byte igual, sin decir una palabra. Con --cropOffset presente el
# recorte se ignora en silencio, y el mismo -c SIN --cropOffset si recorta. Un
# recorte que no recorta y no da error es la peor clase de instrumento: sale
# verde y no ha hecho nada.
#
# Para que sirve: agrupar capturas de una VM en fases. La franja de arriba lleva
# el reloj del invitado y la barra de la ventana del anfitrion, y los dos cambian
# solos; descartarlas es lo que hace que una pantalla quieta sea UNA fase y no
# una por minuto.
#
# El decodificador es el mismo de diferencia.py: zlib y los cinco filtros.
import sys, zlib, struct, hashlib


def leer(ruta):
    d = open(ruta, "rb").read()
    assert d[:8] == b"\x89PNG\r\n\x1a\n", "no es PNG"
    i, idat, w, h, bpp = 8, b"", None, None, None
    while i < len(d):
        ln = struct.unpack(">I", d[i:i+4])[0]
        tipo = d[i+4:i+8]
        dat = d[i+8:i+8+ln]
        if tipo == b"IHDR":
            w, h, prof, color = struct.unpack(">IIBB", dat[:10])
            assert prof == 8, f"profundidad {prof} no soportada"
            assert dat[12] == 0, "PNG entrelazado no soportado"
            bpp = {0: 1, 2: 3, 3: 1, 4: 2, 6: 4}[color]
        elif tipo == b"IDAT":
            idat += dat
        elif tipo == b"IEND":
            break
        i += 12 + ln
    raw = zlib.decompress(idat)
    ancho_linea = w * bpp
    out = bytearray(ancho_linea * h)
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


ruta = sys.argv[1]
descartar = int(sys.argv[2]) if len(sys.argv) > 2 else 0
w, h, bpp, pix = leer(ruta)
if descartar >= h:
    print("filas a descartar >= alto de la imagen", file=sys.stderr); sys.exit(2)
# El tamano entra en la huella a proposito: dos capturas de distinto tamano son
# pantallas distintas, y sin esto un recorte podria coincidir por casualidad.
m = hashlib.sha256(f"{w}x{h - descartar}x{bpp}|".encode())
m.update(pix[descartar * w * bpp:])
print(m.hexdigest())
