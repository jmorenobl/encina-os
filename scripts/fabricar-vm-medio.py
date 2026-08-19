#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Encina OS - FABRICA UN BUNDLE DE UTM PARA ARRANCAR UN MEDIO, SIN TOCAR LA INTERFAZ.

    ./scripts/fabricar-vm-medio.py --iso medios/<x>.iso --nombre encina-bisec-sin-capa

QUE HACE, y las cuatro cosas son las que costaron caro el 2026-08-17:

  1. IDENTIFICADORES DE UNIDAD PROPIOS (trampa 32). Dos bundles con el mismo
     'Drive.Identifier' arrancan y se cuelgan antes de nada -- pantalla negra,
     disco a 0 bloques y el debug.log de QEMU CONGELADO en ~2 700 bytes frente a
     los ~110 KB de una que arranca --, y eso costo dos controles que parecian
     decir que dos ISOs no arrancaban. Aqui se eligen libres y SE COMPRUEBA
     contra TODOS los bundles del disco.
  2. LA ISO POR ENLACE DURO, no copiada: 3,7 GB por VM no caben. 'stat' tiene
     que decir 2 enlaces, y se comprueba DESPUES de hacerlo (trampa 13: una
     mutacion se verifica antes de leer su resultado).
  3. NINGUN CIDATA. La forma de E3: si se le inyecta un seed, lo que arranca ya
     no es lo que hay dentro del medio, y entonces el medio no se esta midiendo.
  4. UN DISCO VACIO Y DISPERSO. Ni clon ni copia: un disco con sistema dentro
     puede arrancar EL, y entonces la pantalla no dice nada del medio.

EL CONTROL DE LA COMPROBACION DE COLISIONES ES GRATIS Y ESTA DENTRO: en este
disco hay CINCO bundles que comparten el identificador F6223E90..., asi que un
detector que no los vea no esta mirando. (Y ojo con lo que ese dato dice de la
trampa 32: encina-dev es uno de los cinco y arranca todos los dias. O sea que
compartir identificador no basta por si solo para colgar una VM -- queda
MEDIDO que colisionan y SIN MEDIR que eso sea lo que las cuelga.)
"""
import argparse, os, plistlib, shutil, sys, glob

DOCS = os.path.expanduser("~/Library/Containers/com.utmapp.UTM/Data/Documents")
PLANTILLA = os.path.join(DOCS, "encina-marca-e8a0ead2.utm")
N_OK = 0; N_FALLO = 0

def ok(m):
    global N_OK; N_OK += 1; print("[OK]    " + m)
def fallo(m):
    global N_FALLO; N_FALLO += 1; print("[FALLO] " + m)
def morir(m):
    print("[FALLO] " + m); sys.exit(1)

def bundles():
    """(nombre, uuid, [drive ids], [macs]) de cada bundle del disco."""
    out = []
    for p in sorted(glob.glob(os.path.join(DOCS, "*.utm", "config.plist"))):
        try:
            c = plistlib.load(open(p, "rb"))
        except Exception:
            continue
        out.append((c.get("Information", {}).get("Name", "?"),
                    c.get("Information", {}).get("UUID", ""),
                    [d.get("Identifier", "") for d in c.get("Drive", [])],
                    [n.get("MacAddress", "") for n in c.get("Network", [])]))
    return out

def main():
    global N_FALLO
    ap = argparse.ArgumentParser()
    ap.add_argument("--iso", required=True)
    ap.add_argument("--nombre", required=True)
    ap.add_argument("--plantilla", default=PLANTILLA)
    ap.add_argument("--sufijo", default="", help="dos digitos hex, p.ej. C0; si no, se busca libre")
    a = ap.parse_args()

    iso = os.path.abspath(a.iso)
    if not os.path.isfile(iso):
        morir("no esta la ISO: " + iso)
    destino = os.path.join(DOCS, a.nombre + ".utm")
    if os.path.exists(destino):
        morir("ya existe el bundle: " + destino)
    if not os.path.isfile(os.path.join(a.plantilla, "config.plist")):
        morir("no esta la plantilla: " + a.plantilla)

    # --- 1. los identificadores, elegidos libres --------------------------
    usados = set()
    for _, u, ids, macs in bundles():
        usados.add(u.upper()); usados.update(i.upper() for i in ids)
    # OJO CON LAS CUENTAS: el ultimo grupo de un UUID son DOCE digitos. Con un
    # sufijo de dos, el de la VM lleva diez ceros delante y los de unidad NUEVE,
    # porque ademas les cuelga un 1 o un 2. La primera version puso diez a los
    # tres y los de unidad salieron de TRECE -- lo enseno su propia salida.
    base_vm = "A1C0DE01-0000-4000-9000-0000000000"      # + 2 = 12
    base_dr = "A1C0DE01-0000-4000-9000-000000000"       # + 2 + 1 = 12
    if a.sufijo:
        cand = [a.sufijo.upper()]
    else:
        cand = ["%02X" % n for n in range(0xC0, 0x100)]
    sufijo = None
    for s in cand:
        vm_uuid = base_vm + s
        d1, d2 = base_dr + s + "1", base_dr + s + "2"
        # el UUID de la VM lleva 12 digitos y los de unidad 12 tambien: se
        # comprueban los tres, y ademas que no choquen entre si
        if not ({vm_uuid.upper(), d1.upper(), d2.upper()} & usados):
            sufijo = s; break
    if sufijo is None:
        morir("no queda ningun sufijo libre entre C0 y FF")
    vm_uuid = base_vm + sufijo
    d1, d2 = base_dr + sufijo + "1", base_dr + sufijo + "2"
    for i in (vm_uuid, d1, d2):
        if len(i) != 36 or len(i.split("-")[-1]) != 12:
            morir("identificador mal formado (%d caracteres): %s" % (len(i), i))
    mac = "76:CE:%s:%s:%s:%s" % (sufijo, sufijo, sufijo, sufijo)
    print("== identificadores elegidos (sufijo %s)" % sufijo)
    print("        VM   %s" % vm_uuid)
    print("        disco %s" % d1)
    print("        medio %s" % d2)
    print("        MAC   %s" % mac)

    # --- 2. el bundle -----------------------------------------------------
    c = plistlib.load(open(os.path.join(a.plantilla, "config.plist"), "rb"))
    c["Information"]["Name"] = a.nombre
    c["Information"]["UUID"] = vm_uuid
    if len(c.get("Drive", [])) != 2:
        morir("la plantilla no tiene DOS unidades: %d" % len(c.get("Drive", [])))
    for d in c["Drive"]:
        if d.get("ImageType") == "CD":
            d["Identifier"] = d2; d["ImageName"] = "medio.iso"
        else:
            d["Identifier"] = d1; d["ImageName"] = "disco.img"
    for n in c.get("Network", []):
        n["MacAddress"] = mac
    os.makedirs(os.path.join(destino, "Data"))
    plistlib.dump(c, open(os.path.join(destino, "config.plist"), "wb"))

    # la ISO POR ENLACE DURO
    medio = os.path.join(destino, "Data", "medio.iso")
    os.link(iso, medio)
    # el disco, vacio y disperso: se crea truncando, no copiando
    disco = os.path.join(destino, "Data", "disco.img")
    with open(disco, "wb") as f:
        f.truncate(40 * 1024 * 1024 * 1024)
    # las variables EFI de la plantilla, que es un arranque UEFI que ya funciono
    efi_p = os.path.join(a.plantilla, "Data", "efi_vars.fd")
    if os.path.isfile(efi_p):
        shutil.copy2(efi_p, os.path.join(destino, "Data", "efi_vars.fd"))

    # --- 3. y ahora se comprueba lo que se acaba de hacer -----------------
    print("== lo que ha quedado en el disco")
    st_m = os.stat(medio); st_i = os.stat(iso)
    # LO QUE PRUEBA EL ENLACE ES EL INODO, NO EL NUMERO. La primera version
    # exigia EXACTAMENTE 2 enlaces y dio un [FALLO] enganoso con la ISO de
    # ac0a5721, que YA la comparte otra VM del banco: ahi el enlace nuevo hace 3
    # y estaba perfectamente bien. Se exige el mismo inodo y >= 2.
    if st_m.st_ino == st_i.st_ino and st_m.st_nlink >= 2:
        ok("medio.iso es un ENLACE DURO de la ISO: inodo %d, %d enlaces, %d bytes"
           % (st_m.st_ino, st_m.st_nlink, st_m.st_size))
    else:
        fallo("medio.iso NO es enlace duro: %d enlaces, inodo %d contra %d"
              % (st_m.st_nlink, st_m.st_ino, st_i.st_ino))
    st_d = os.stat(disco)
    if st_d.st_nlink == 1:
        ok("control: el disco recien creado tiene 1 enlace, o sea que 'st_nlink' distingue")
    else:
        fallo("CONTROL ROTO: el disco recien creado dice %d enlaces" % st_d.st_nlink)
    if st_d.st_blocks == 0:
        ok("disco.img: %d bytes declarados y 0 bloques en disco (disperso y vacio)" % st_d.st_size)
    else:
        fallo("disco.img ocupa %d bloques y tenia que estar vacio" % st_d.st_blocks)

    cidata = [p for p in glob.glob(os.path.join(destino, "Data", "*"))
              if "cidata" in os.path.basename(p).lower()]
    if not cidata:
        ok("ningun CIDATA: lo que arranque sale de dentro del medio")
    else:
        fallo("hay CIDATA en el bundle: %s" % cidata)

    # --- 4. colisiones, con su control ------------------------------------
    print("== identificadores repetidos, en TODO el disco")
    todos = {}
    for n, u, ids, macs in bundles():
        for i in [u] + ids:
            if i:
                todos.setdefault(i.upper(), []).append(n)
    mios = [vm_uuid, d1, d2]
    choque = {i: v for i, v in todos.items() if i in [m.upper() for m in mios] and len(v) > 1}
    if not choque:
        ok("los 3 identificadores de %s no los tiene ningun otro bundle" % a.nombre)
    else:
        fallo("identificadores REPETIDOS: %s" % choque)
    # EL CONTROL, y es gratis: en este disco hay una colision conocida.
    conocidas = {i: v for i, v in todos.items() if len(v) > 1}
    if conocidas:
        ok("control: el detector SI ve colisiones donde las hay -- %s"
           % "; ".join("%s en %d bundles (%s)" % (i[:8] + "…", len(v), ", ".join(v))
                       for i, v in sorted(conocidas.items())))
    else:
        fallo("CONTROL ROTO: el detector no encuentra NINGUNA colision, ni la conocida de F6223E90…")

    print()
    print("bundle: %s" % destino)
    print("medio:  %s" % iso)
    print("correctas: %d   fallos: %d" % (N_OK, N_FALLO))
    if N_FALLO:
        sys.exit(1)
    print()
    print("ARRANCARLA:  utmctl start %s   <- y OJO: devuelve 0 AUNQUE FALLE (trampa 28)." % vm_uuid)
    print("             Comprueba 'utmctl status' Y que Data/debug.log crezca de los")
    print("             ~2 700 bytes de una colgada a los ~110 KB de una que arranca.")

main()
