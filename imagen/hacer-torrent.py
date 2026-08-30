#!/usr/bin/env python3
"""Encina OS - UN .torrent POR FICHERO, REPRODUCIBLE, CON WEB SEED Y SIN TRACKER.

    ./imagen/hacer-torrent.py --fichero <iso> --salida <torrent> --web-seed <URL> [--web-seed <URL>…]
                              [--pieza <MiB>]

POR QUE EXISTE (2026-08-29, MEDICIONES.md §4.82h, tareas/cerradas/alojamiento.md): la ISO
vive en SourceForge y un .torrent con web seed (BEP 19, 'url-list') deja que un
cliente de BitTorrent la baje entera desde esa URL aunque nadie siembre, con la
integridad de cada pieza comprobada al llegar, y que se reparta entre quien la
tenga. Es una capa de reparto ENCIMA del alojamiento, no un alojamiento.

POR QUE ES REPRODUCIBLE, y no por casualidad: no se escribe 'creation date' ni
'created by', no hay tracker ('announce'), bencode ordena las claves por
definicion, y las piezas son sha1 de trozos fijos del fichero. Dos pasadas dan
el mismo .torrent byte a byte y el mismo infohash: es la definicion de terminado
de construir-todo.sh aplicada a este artefacto, y este guion la ejecuta (escribe
dos veces y compara antes de dejar nada).

LA WEB SEED TIENE QUE SER LA URL CANONICA de SourceForge
(https://downloads.sourceforge.net/project/<proyecto>/<carpeta>/<fichero>): los
espejos llevan un token que caduca y sin el devuelven 301 al canonico; el
cliente sigue el 302 (medido con aria2c en §4.82h; qBittorrent y Transmission,
[OMIT]).

EL CONTROL VA DELANTE: el infohash calculado aqui tiene que cambiar si cambia UN
byte del fichero, y eso se comprueba sobre una copia de los primeros bytes antes
de escribir nada. VOCABULARIO: el de lib/salida.sh; un solo [FALLO] sale con 1.
"""
import argparse
import hashlib
import os
import sys


def ben(x):
    if isinstance(x, bool):
        raise TypeError(x)
    if isinstance(x, int):
        return b"i%de" % x
    if isinstance(x, bytes):
        return b"%d:" % len(x) + x
    if isinstance(x, str):
        return ben(x.encode("utf-8"))
    if isinstance(x, list):
        return b"l" + b"".join(ben(e) for e in x) + b"e"
    if isinstance(x, dict):
        return b"d" + b"".join(ben(k) + ben(x[k]) for k in sorted(x)) + b"e"
    raise TypeError(type(x))


def piezas_de(ruta, pieza):
    h = []
    with open(ruta, "rb") as f:
        for trozo in iter(lambda: f.read(pieza), b""):
            h.append(hashlib.sha1(trozo).digest())
    return b"".join(h)


def torrent(nombre, tamano, piezas, pieza, webseeds):
    info = {"name": nombre, "length": tamano, "piece length": pieza, "pieces": piezas}
    t = {"info": info, "url-list": list(webseeds), "comment": "Encina OS: web seed, sin tracker; la huella SHA-256 va en SHA256SUMS"}
    return ben(t), hashlib.sha1(ben(info)).hexdigest()


def main():
    p = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    p.add_argument("--fichero", required=True)
    p.add_argument("--salida", required=True)
    p.add_argument("--web-seed", action="append", required=True, help="una o mas URLs del fichero ENTERO")
    p.add_argument("--pieza", type=int, default=4, help="MiB por pieza (4 por defecto; 3,5 GiB son ~890 piezas)")
    a = p.parse_args()
    if not os.path.isfile(a.fichero):
        print(f"  [FALLO] no existe {a.fichero}"); sys.exit(1)
    for u in a.web_seed:
        if not (u.startswith("https://") or u.startswith("http://")):
            print(f"  [FALLO] la web seed no es una URL http(s): {u}"); sys.exit(1)
        if not u.endswith("/" + os.path.basename(a.fichero)):
            print(f"  [FALLO] la web seed tiene que terminar en el nombre del fichero ({os.path.basename(a.fichero)}): {u}"); sys.exit(1)
    pieza = a.pieza << 20
    nombre = os.path.basename(a.fichero)
    tamano = os.path.getsize(a.fichero)

    print("== 1. el control: el infohash tiene que cambiar con UN byte del fichero")
    with open(a.fichero, "rb") as f:
        cabeza = f.read(pieza)
    h_a = hashlib.sha1(cabeza).digest()
    sab = bytearray(cabeza); sab[0] ^= 0x01
    h_b = hashlib.sha1(bytes(sab)).digest()
    _, i_a = torrent(nombre, len(cabeza), h_a, pieza, a.web_seed)
    _, i_b = torrent(nombre, len(cabeza), h_b, pieza, a.web_seed)
    if h_a == h_b or i_a == i_b:
        print("  [FALLO] CONTROL ROTO: un byte cambiado da la misma pieza o el mismo infohash"); sys.exit(1)
    print(f"  [OK]    rojo: con un byte cambiado, la pieza y el infohash cambian ({i_a[:8]}… / {i_b[:8]}…)")

    print(f"== 2. las piezas de {nombre} ({tamano} bytes, piezas de {a.pieza} MiB)")
    piezas = piezas_de(a.fichero, pieza)
    print(f"        {len(piezas) // 20} piezas")

    print("== 3. el .torrent, dos veces")
    b1, ih1 = torrent(nombre, tamano, piezas, pieza, a.web_seed)
    b2, ih2 = torrent(nombre, tamano, piezas_de(a.fichero, pieza), pieza, a.web_seed)
    print(f"        pasada 1  infohash {ih1}")
    print(f"        pasada 2  infohash {ih2}")
    if b1 != b2:
        print("  [FALLO] las dos pasadas NO dan los mismos bytes: no se deja ningun .torrent"); sys.exit(1)
    os.makedirs(os.path.dirname(os.path.abspath(a.salida)), exist_ok=True)
    with open(a.salida, "wb") as f:
        f.write(b1)
    # trampa 13: lo escrito, vuelto a leer
    escrito = open(a.salida, "rb").read()
    if escrito != b1:
        print("  [FALLO] lo escrito no es lo calculado"); sys.exit(1)
    print(f"  [OK]    dos pasadas, el mismo .torrent: {a.salida}  ({len(b1)} bytes)")
    print(f"\ntorrent:  {a.salida}")
    print(f"infohash: {ih1}")
    print(f"sha256:   {hashlib.sha256(b1).hexdigest()}")
    for u in a.web_seed:
        print(f"web seed: {u}")
    print("\nLO QUE ESTE GUION NO PUEDE DECIR: que la web seed sirva el fichero. Eso se mide")
    print("bajando el .torrent con un cliente sin DHT, PEX, LPD ni tracker (§4.82h).")


if __name__ == "__main__":
    main()
