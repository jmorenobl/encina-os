#!/usr/bin/env python3
# Cuenta las TIENDAS que el usuario ve en la rejilla, con el control que la hace
# significar algo: el mismo contador tiene que saber decir 2, 1 y 0.
#
# Usa el MISMO inventario que imagen/verificar-e2.sh -- Gio.AppInfo con
# should_show() -- para que los dos numeros sean comparables.
import locale, sys
locale.setlocale(locale.LC_ALL, "")   # sin esto los nombres salen en ingles (trampa 26bis)
import gi
gi.require_version("Gio", "2.0")
from gi.repository import Gio, GLib

TIENDAS = {"snap-store_snap-store.desktop", "org.gnome.Software.desktop"}

todas = Gio.AppInfo.get_all()
vis = [a for a in todas if a.should_show()]
ids = [a.get_id() for a in vis]

print("idioma que ve el proceso:", GLib.get_language_names()[:3])
print("aplicaciones visibles:", len(vis), "de", len(todas), "totales")

def cuenta(conjunto_ids):
    return sorted(i for i in conjunto_ids if i in TIENDAS)

reales = cuenta(ids)
print("TIENDAS VISIBLES:", len(reales))
for i in reales:
    nombre = next(a.get_name() for a in vis if a.get_id() == i)
    print("   ", i, "|", nombre)

# --- EL CONTROL: el contador tiene que saber decir 2, 1 y 0 -------------------
fingido_2 = ids + ["org.gnome.Software.desktop"]
fingido_0 = [i for i in ids if i not in TIENDAS]
print("control: con org.gnome.Software.desktop anadido el contador dice",
      len(cuenta(fingido_2)))
print("control: quitando las dos, el contador dice", len(cuenta(fingido_0)))

print("--- las aplicaciones que ve el usuario, por nombre ---")
for a in sorted(vis, key=lambda x: x.get_name().lower()):
    print("APP\t%s\t%s" % (a.get_id(), a.get_name()))
