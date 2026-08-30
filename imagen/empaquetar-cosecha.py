#!/usr/bin/env python3
"""Encina OS - LA COSECHA QUE SE PUBLICA CON LA ISO, empaquetada y reproducible.

    ./imagen/empaquetar-cosecha.py --repo <dir> --arq arm64|amd64 --salida <tar>
                                   [--manifiesto <tsv>] [--epoca <segundos>]

POR QUE EXISTE (2026-08-29, MEDICIONES.md §4.82, tareas/cerradas/publicar.md): el archivo
de Ubuntu retira las versiones superadas y el manifiesto ancla una (trampa 68);
Launchpad conserva lo de Ubuntu, pero Firefox viene de packages.mozilla.org y
NO tiene fuente permanente. El dia que Mozilla publique la siguiente, la receta
publica de este repositorio deja de reproducir el producto. La unica defensa es
publicar la cosecha misma --los 29 .deb de /encina-repo, los que ya viajan
dentro de la ISO-- junto a la ISO, y que cosechar-repo.sh sepa cosechar DESDE
ella (--cosecha). Este guion es el que la empaqueta.

QUE HACE, y en este orden:
    1. lee el manifiesto (imagen/repo-manifiesto*.tsv, LA fuente de la lista);
    2. EL CONTROL VA DELANTE: el comparador tiene que rechazar una huella
       cambiada en un caracter y un tamano cambiado en un byte, o no se mide;
    3. coteja el directorio contra el manifiesto ENTERO --cada .deb por huella
       y tamano, ninguno de mas, ninguno de menos-- y el Packages contra el
       manifiesto en las dos direcciones (fichero, tamano, huella);
    4. escribe el tar DOS VECES y compara los bytes: si no salen iguales, no
       hay tar. Es la definicion de terminado de construir-todo.sh aplicada a
       este artefacto;
    5. vuelve a leer el tar escrito y coteja cada miembro contra el manifiesto
       (trampa 13: una mutacion se verifica antes de leer su resultado).

POR QUE ES REPRODUCIBLE, y no por casualidad: formato ustar, miembros por orden
de nombre, modo 0644, uid/gid 0 sin nombres, y la fecha de todos los miembros
es SOURCE_DATE_EPOCH -- la del ultimo commit que toco el manifiesto, leida de
git, o --epoca / la variable de entorno si se dan --. bsdtar (macOS) no tiene
--mtime ni ordena, y GNU tar no esta en el Mac: por eso es Python y no tar.

LO QUE NO HACE: no baja nada, no construye nada, no sube nada. El directorio
que lee es el --trabajo que deja construir-todo.sh --conservar ('make cosecha').

VOCABULARIO DE SALIDA: el de lib/salida.sh -- [OK] / [FALLO] con la salida
literal / [AVISO] -- y un solo [FALLO] sale con 1.
"""
import argparse
import hashlib
import io
import os
import subprocess
import sys
import tarfile

N_OK = 0
N_MAL = 0


def ok(msg):
    global N_OK
    N_OK += 1
    print(f"  [OK]    {msg}")


def fallo(msg, literal=None):
    global N_MAL
    N_MAL += 1
    print(f"  [FALLO] {msg}")
    if literal:
        for l in str(literal).splitlines():
            print(f"          {l}")


def morir(msg):
    print(f"  [FALLO] {msg}", file=sys.stderr)
    sys.exit(1)


def sha256_de(ruta):
    h = hashlib.sha256()
    with open(ruta, "rb") as f:
        for trozo in iter(lambda: f.read(1 << 20), b""):
            h.update(trozo)
    return h.hexdigest()


def cuadra(ruta, sha, tamano):
    """La comparacion de siempre: huella Y tamano, los dos."""
    return os.path.getsize(ruta) == tamano and sha256_de(ruta) == sha


def leer_manifiesto(ruta):
    filas = []
    with open(ruta, encoding="utf-8") as f:
        for linea in f:
            linea = linea.rstrip("\n")
            if not linea or linea.startswith("#") or linea.startswith("origen\t"):
                continue
            campos = linea.split("\t")
            if len(campos) != 6:
                morir(f"linea del manifiesto con {len(campos)} campos y no 6: {linea!r}")
            origen, paquete, version, fichero, tamano, sha = campos
            if origen not in ("ARCHIVO", "PROPIO"):
                morir(f"origen desconocido en el manifiesto: {origen}")
            filas.append((origen, paquete, version, fichero, int(tamano), sha))
    if not filas:
        morir(f"el manifiesto no tiene ni una linea de datos: {ruta}")
    return filas


def leer_packages(ruta):
    """{fichero: (tamano, sha256)} del indice, con el './' de dpkg-scanpackages fuera."""
    entradas = {}
    fichero = tamano = sha = None
    with open(ruta, encoding="utf-8") as f:
        for linea in f.read().split("\n") + [""]:
            if linea.startswith("Filename: "):
                fichero = linea[len("Filename: "):]
                if fichero.startswith("./"):
                    fichero = fichero[2:]
            elif linea.startswith("Size: "):
                tamano = int(linea[len("Size: "):])
            elif linea.startswith("SHA256: "):
                sha = linea[len("SHA256: "):]
            elif linea == "":
                if fichero is not None:
                    entradas[fichero] = (tamano, sha)
                fichero = tamano = sha = None
    return entradas


def epoca_de(manifiesto, epoca_pedida):
    if epoca_pedida is not None:
        return int(epoca_pedida), "--epoca"
    if os.environ.get("SOURCE_DATE_EPOCH"):
        return int(os.environ["SOURCE_DATE_EPOCH"]), "SOURCE_DATE_EPOCH"
    raiz = os.path.dirname(os.path.dirname(os.path.abspath(manifiesto)))
    try:
        salida = subprocess.run(
            ["git", "log", "-1", "--format=%ct", "--", os.path.abspath(manifiesto)],
            cwd=raiz, capture_output=True, text=True, check=True).stdout.strip()
    except (subprocess.CalledProcessError, FileNotFoundError) as e:
        morir(f"no puedo leer de git la fecha del ultimo commit del manifiesto ({e}); da --epoca")
    if not salida.isdigit():
        morir(f"git no dio una fecha para {manifiesto}: {salida!r} (¿no esta versionado?)")
    return int(salida), "git log -1 --format=%ct -- " + os.path.basename(manifiesto)


def escribir_tar(destino, prefijo, repo, nombres, epoca):
    """ustar, por orden de nombre, 0644, uid/gid 0, mtime fijo. Devuelve los bytes."""
    with open(destino, "wb") as salida:
        with tarfile.open(fileobj=salida, mode="w", format=tarfile.USTAR_FORMAT) as t:
            for nombre in sorted(nombres):
                ruta = os.path.join(repo, nombre)
                info = tarfile.TarInfo(name=f"{prefijo}/{nombre}")
                info.size = os.path.getsize(ruta)
                info.mtime = epoca
                info.mode = 0o644
                info.uid = info.gid = 0
                info.uname = info.gname = ""
                info.type = tarfile.REGTYPE
                with open(ruta, "rb") as f:
                    t.addfile(info, f)
    return sha256_de(destino)


def main():
    p = argparse.ArgumentParser(description=__doc__.split("\n")[0], add_help=True)
    p.add_argument("--repo", required=True, help="el directorio con los .deb y su Packages")
    p.add_argument("--arq", required=True, choices=["arm64", "amd64"])
    p.add_argument("--salida", required=True, help="el .tar que se escribe")
    p.add_argument("--manifiesto", help="por defecto, el de la arquitectura")
    p.add_argument("--epoca", help="SOURCE_DATE_EPOCH; por defecto, el commit del manifiesto")
    a = p.parse_args()

    aqui = os.path.dirname(os.path.abspath(__file__))
    manifiesto = a.manifiesto or os.path.join(
        aqui, "repo-manifiesto-amd64.tsv" if a.arq == "amd64" else "repo-manifiesto.tsv")
    if not os.path.isdir(a.repo):
        morir(f"no existe el directorio: {a.repo}")
    if not os.path.isfile(manifiesto):
        morir(f"no existe el manifiesto: {manifiesto}")

    # --- 1. el manifiesto ----------------------------------------------------
    print("== 1. el manifiesto")
    filas = leer_manifiesto(manifiesto)
    ok(f"{len(filas)} paquetes en {os.path.basename(manifiesto)}")

    # --- 2. EL CONTROL, delante ----------------------------------------------
    print("== 2. el control: el comparador tiene que saber decir que NO")
    origen, paquete, version, fichero, tamano, sha = filas[0]
    primero = os.path.join(a.repo, fichero)
    if not os.path.isfile(primero):
        morir(f"no puedo hacer el control: falta {primero}")
    if not cuadra(primero, sha, tamano):
        morir(f"no puedo hacer el control: {fichero} ya no cuadra con el manifiesto (no es un control, es un fallo)")
    # una huella cambiada en UN caracter (si empieza por f, a 0: §4.37c)
    sab = ("0" if sha[0] == "f" else "f") + sha[1:]
    if sab == sha:
        morir("CONTROL ROTO: el sabotaje de la huella no saboteo")
    if cuadra(primero, sab, tamano):
        morir("CONTROL ROTO: el comparador acepta una huella cambiada en un caracter")
    if cuadra(primero, sha, tamano + 1):
        morir("CONTROL ROTO: el comparador acepta un tamano cambiado en un byte")
    ok("rojo: con la huella cambiada en un caracter dice que no, y con el tamano en un byte tambien")

    # --- 3. el directorio y el Packages contra el manifiesto, enteros --------
    print("== 3. el directorio contra el manifiesto, entero")
    cuadran = 0
    for origen, paquete, version, fichero, tamano, sha in filas:
        ruta = os.path.join(a.repo, fichero)
        if not os.path.isfile(ruta):
            fallo(f"ausente     {fichero}")
            continue
        if cuadra(ruta, sha, tamano):
            cuadran += 1
        else:
            fallo(f"NO CUADRA   {fichero}",
                  f"esperada {sha}  {tamano} bytes\nreal     {sha256_de(ruta)}  {os.path.getsize(ruta)} bytes")
    en_disco = sorted(f for f in os.listdir(a.repo) if f.endswith(".deb"))
    esperados = sorted(f[3] for f in filas)
    sobran = sorted(set(en_disco) - set(esperados))
    if sobran:
        fallo(f"hay {len(sobran)} .deb que el manifiesto no nombra", "\n".join(sobran))
    if cuadran == len(filas) and not sobran:
        ok(f"los {len(filas)} .deb estan, cuadran por huella y tamano, y no sobra ninguno")

    packages = os.path.join(a.repo, "Packages")
    if not os.path.isfile(packages):
        fallo("no hay Packages en el directorio (lo genera construir-todo.sh en el constructor)")
    else:
        idx = leer_packages(packages)
        man = {f[3]: (f[4], f[5]) for f in filas}
        # y el control de ESTA comparacion: un tamano cambiado tiene que verse
        man_sab = dict(man)
        k0 = esperados[0]
        man_sab[k0] = (man[k0][0] + 1, man[k0][1])
        if idx == man_sab:
            morir("CONTROL ROTO: el Packages 'cuadra' con un manifiesto de tamano falseado")
        if idx == man:
            ok(f"Packages: {len(idx)} entradas, y dicen lo mismo que el manifiesto (fichero, tamano, huella)")
        else:
            solo_idx = sorted(set(idx) - set(man))
            solo_man = sorted(set(man) - set(idx))
            distintos = sorted(k for k in set(idx) & set(man) if idx[k] != man[k])
            fallo("el Packages y el manifiesto NO dicen lo mismo",
                  f"solo en Packages: {solo_idx}\nsolo en manifiesto: {solo_man}\ndistintos: {distintos}")
    if N_MAL:
        print(f"\n   correctas: {N_OK}   fallos: {N_MAL}")
        sys.exit(1)

    # --- 4. el tar, DOS VECES ------------------------------------------------
    epoca, de_donde = epoca_de(manifiesto, a.epoca)
    print(f"== 4. el tar, dos veces (SOURCE_DATE_EPOCH={epoca}, de {de_donde})")
    prefijo = f"encina-repo-{a.arq}"
    miembros = esperados + ["Packages"]
    salida = os.path.abspath(a.salida)
    os.makedirs(os.path.dirname(salida), exist_ok=True)
    h1 = escribir_tar(salida + ".pasada-1", prefijo, a.repo, miembros, epoca)
    h2 = escribir_tar(salida + ".pasada-2", prefijo, a.repo, miembros, epoca)
    print(f"        pasada 1  {h1}")
    print(f"        pasada 2  {h2}")
    if h1 != h2 or open(salida + ".pasada-1", "rb").read() != open(salida + ".pasada-2", "rb").read():
        os.remove(salida + ".pasada-1")
        os.remove(salida + ".pasada-2")
        morir("las dos pasadas NO dan los mismos bytes: el tar no es reproducible y no se deja ninguno")
    os.remove(salida + ".pasada-2")
    os.replace(salida + ".pasada-1", salida)
    ok(f"dos pasadas, los mismos bytes: {salida}")

    # --- 5. lo escrito, vuelto a leer ----------------------------------------
    print("== 5. el tar escrito, vuelto a leer contra el manifiesto (trampa 13)")
    leidos = 0
    with tarfile.open(salida, "r") as t:
        nombres = t.getnames()
        for origen, paquete, version, fichero, tamano, sha in filas:
            nombre = f"{prefijo}/{fichero}"
            try:
                m = t.getmember(nombre)
            except KeyError:
                fallo(f"no esta en el tar: {nombre}")
                continue
            datos = t.extractfile(m).read()
            if m.size == tamano and hashlib.sha256(datos).hexdigest() == sha:
                leidos += 1
            else:
                fallo(f"en el tar, {fichero} no cuadra con el manifiesto")
        if f"{prefijo}/Packages" not in nombres:
            fallo("no esta en el tar: Packages")
    if len(nombres) != len(miembros):
        fallo(f"el tar tiene {len(nombres)} miembros y tenian que ser {len(miembros)}", "\n".join(nombres))
    if leidos == len(filas):
        ok(f"{len(nombres)} miembros bajo {prefijo}/: los {leidos} .deb cuadran con el manifiesto, y Packages")
    print(f"\ntar:    {salida}")
    print(f"sha256: {h1}")
    print(f"tam:    {os.path.getsize(salida)} bytes")
    print(f"\n   correctas: {N_OK}   fallos: {N_MAL}")
    sys.exit(1 if N_MAL else 0)


if __name__ == "__main__":
    main()
