#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Encina OS - APLICA AL CONTEO EL CRITERIO ESCRITO ANTES DE EMPEZAR.

    ./scripts/veredicto-conteo.py medios/conteo-arranques/arranques.tsv
    ./scripts/veredicto-conteo.py --banco        (los casos de control, segundos)

POR QUE EXISTE, y por que se escribio ANTES de ver un solo dato. Un conteo de
quince arranques con tasas alrededor del 50 % se puede leer de la forma que uno
quiera despues de verlo: 3 de 5 frente a 5 de 5 "parece peor" y no lo es. El
criterio esta en MEDICIONES.md 4.59a, escrito antes del primer arranque, y esto
solo lo aplica. Si el resultado no le gusta a nadie, el criterio ya estaba.

EL CRITERIO, literal:

  1. PRUEBA DE QUE EL FALLO ES DEL BANCO -- y es el objetivo primario: basta con
     que UN CONTROL (p11 o p9) falle al menos una vez. Un control conocido-bueno
     que falla es el fallo intermitente SIN la capa entera de por medio.
  2. SENAL DE EFECTO DE LA CAPA: p10 contra la UNION de los dos controles por
     Fisher exacta de UNA COLA con p <= 0,05.
  3. Cualquier cosa por encima de eso es RUIDO y se escribe [OMIT], no
     "tendencia". Una diferencia de UN SOLO arranque no es nada.
  4. No se concluye con menos de 4 RONDAS COMPLETAS.

Fisher se calcula con la hipergeometrica y math.comb, sin dependencias. La cola
es la de "p10 arranca MENOS", que es la hipotesis que se quiere poner a prueba;
la otra no se mira, y eso tambien estaba dicho antes.
"""
import math
import sys
from collections import defaultdict

RONDAS_MINIMAS = 4
ALFA = 0.05
BRAZO_PRUEBA = "p10"
BRAZOS_CONTROL = ("p11", "p9")


# --- INICIO REGLA ---
def fisher_una_cola(a, b, c, d):
    """p de que el brazo de arriba arranque TAN POCO o menos, por azar.

        a = arranques buenos del brazo de prueba   b = fallos del brazo de prueba
        c = arranques buenos de los controles      d = fallos de los controles
    """
    n = a + b                  # arranques del brazo de prueba
    K = a + c                  # buenos en total
    N = a + b + c + d          # arranques en total
    if N == 0 or n == 0:
        return 1.0
    total = math.comb(N, n)
    p = 0.0
    for k in range(0, a + 1):
        if k > K or (n - k) > (N - K):
            continue
        p += math.comb(K, k) * math.comb(N - K, n - k) / total
    return p
# --- FIN REGLA ---


def leer(ruta):
    """{brazo: {'GRAFICA': n, ...}} y el numero de rondas completas."""
    cuentas = defaultdict(lambda: defaultdict(int))
    por_ronda = defaultdict(set)
    with open(ruta) as f:
        cab = f.readline().rstrip("\n").split("\t")
        ir, ib, iv = cab.index("ronda"), cab.index("brazo"), cab.index("veredicto")
        for linea in f:
            c = linea.rstrip("\n").split("\t")
            if len(c) <= iv or not c[ir]:
                continue
            cuentas[c[ib]][c[iv]] += 1
            if c[iv] in ("GRAFICA", "NEGRA"):
                por_ronda[c[ir]].add(c[ib])
    brazos = set(cuentas)
    completas = sum(1 for r, bs in por_ronda.items() if bs >= brazos)
    return cuentas, completas


def informe(ruta):
    cuentas, completas = leer(ruta)
    if not cuentas:
        print("[FALLO] el TSV no tiene ni una linea de datos")
        return 1

    print("== el conteo, tal cual")
    print(f"  {'brazo':<6}{'arranco':>9}{'negra':>8}{'otros':>8}{'total':>8}   tasa")
    for b in sorted(cuentas, key=lambda x: (x != BRAZO_PRUEBA, x)):
        g = cuentas[b].get("GRAFICA", 0)
        n = cuentas[b].get("NEGRA", 0)
        o = sum(v for k, v in cuentas[b].items() if k not in ("GRAFICA", "NEGRA"))
        t = g + n + o
        tasa = f"{g}/{g+n}" if (g + n) else "-"
        print(f"  {b:<6}{g:>9}{n:>8}{o:>8}{t:>8}   {tasa}")

    fallos = 0
    print()
    print(f"== 4. RONDAS COMPLETAS: {completas} (minimo para concluir: {RONDAS_MINIMAS})")
    if completas < RONDAS_MINIMAS:
        print("  [OMIT]  NO SE CONCLUYE. El criterio lo dijo antes de empezar.")
        fallos += 1
    else:
        print("  [OK]    hay suficientes rondas para aplicar el criterio")

    print()
    print("== 1. EL OBJETIVO PRIMARIO: un control que falla prueba que el fallo")
    print("      es del BANCO, y no hace falta N grande para eso")
    fallos_control = {b: cuentas[b].get("NEGRA", 0) for b in BRAZOS_CONTROL if b in cuentas}
    if any(v > 0 for v in fallos_control.values()):
        det = ", ".join(f"{b}: {v}" for b, v in fallos_control.items())
        print(f"  [OK]    un control conocido-bueno FALLA ({det})")
        print("          -> el fallo intermitente existe SIN la capa entera de por medio")
    else:
        print(f"  [OMIT]  ningun control fallo ({fallos_control})")
        print("          -> el fallo de ayer sigue sin explicar; el [OMIT] de 4.58 NO se cierra")

    print()
    print(f"== 2. SENAL DE EFECTO DE LA CAPA: {BRAZO_PRUEBA} contra la union de"
          f" {'+'.join(BRAZOS_CONTROL)}")
    a = cuentas[BRAZO_PRUEBA].get("GRAFICA", 0)
    b = cuentas[BRAZO_PRUEBA].get("NEGRA", 0)
    c = sum(cuentas[x].get("GRAFICA", 0) for x in BRAZOS_CONTROL)
    d = sum(cuentas[x].get("NEGRA", 0) for x in BRAZOS_CONTROL)
    p = fisher_una_cola(a, b, c, d)
    print(f"  {BRAZO_PRUEBA:<10} arranco {a}, fallo {b}")
    print(f"  controles  arranco {c}, fallo {d}")
    print(f"  Fisher exacta de una cola: p = {p:.4f}   (umbral {ALFA})")
    if p <= ALFA:
        print(f"  [OK]    p <= {ALFA}: HAY SENAL. La capa entera afecta a la probabilidad")
        print("          de arrancar, y toca bisecar OTRA VEZ -- ya con veredicto contado.")
    else:
        print(f"  [OMIT]  p > {ALFA}: NO hay senal. Se escribe [OMIT], NO 'tendencia'.")
        if a + b and c + d and (a / (a + b)) < (c / (c + d)):
            print(f"          Y si, {BRAZO_PRUEBA} sale por debajo en bruto. NO CUENTA: el")
            print("          criterio de (a) decia esto exactamente, escrito antes de mirar.")

    print()
    return 1 if fallos else 0


# ---------------------------------------------------------------- el banco ---
def banco():
    """El control de la regla: casos donde la respuesta se sabe de antemano.

    UN CONTRASTE QUE NO PUEDE DAR SUS DOS RESPUESTAS NO ES UN CONTRASTE. Si
    'fisher_una_cola' devolviera siempre 1,0 (nunca hay senal) o siempre 0,0
    (siempre la hay), los casos 1 y 3 lo cazan.
    """
    print("== banco de fisher_una_cola: casos con respuesta conocida")
    # (rotulo, a, b, c, d, p esperada -- calculada a mano con la hipergeometrica)
    casos = [
        ("0 de 5 frente a 10 de 10: el peor caso posible -> SENAL",
         0, 5, 10, 0, 1 / 3003, True),
        ("1 de 5 frente a 10 de 10 -> SENAL",
         1, 4, 10, 0, 11 / 3003, True),
        ("2 de 5 frente a 10 de 10 -> SENAL, y por poco",
         2, 3, 10, 0, 66 / 3003, True),
        ("3 de 5 frente a 10 de 10 -> RUIDO, no llega",
         3, 2, 10, 0, 286 / 3003, False),
        ("5 de 5 frente a 10 de 10: identicos -> RUIDO",
         5, 0, 10, 0, 1.0, False),
        ("3 de 5 frente a 6 de 10: el banco falla en los TRES -> RUIDO",
         3, 2, 6, 4, None, False),
    ]
    n_ok = n_mal = 0
    for rot, a, b, c, d, esperada, hay_senal in casos:
        p = fisher_una_cola(a, b, c, d)
        bien = (p <= ALFA) == hay_senal
        if esperada is not None and abs(p - esperada) > 1e-9:
            bien = False
            rot += f"  [p esperada {esperada:.6f}]"
        if bien:
            n_ok += 1
            print(f"  [OK]    p={p:.6f}  {rot}")
        else:
            n_mal += 1
            print(f"  [FALLO] p={p:.6f}  {rot}")

    # CONTROL POR COLUMNA: la regla tiene que dar las DOS respuestas.
    ps = [fisher_una_cola(*c[1:5]) for c in casos]
    if all(p <= ALFA for p in ps) or all(p > ALFA for p in ps):
        n_mal += 1
        print("  [FALLO] CONTROL ROTO: todos los casos caen del mismo lado del umbral")
    else:
        n_ok += 1
        print("  [OK]    control por columna: la regla dice SENAL en unos casos y RUIDO en otros")

    # Y LA COLA ES LA QUE ES: al reves no puede salir senal.
    p_reves = fisher_una_cola(10, 0, 0, 5)
    if p_reves <= ALFA:
        n_mal += 1
        print(f"  [FALLO] la cola esta invertida: 10/10 frente a 0/5 da p={p_reves:.6f}")
    else:
        n_ok += 1
        print(f"  [OK]    la cola es la declarada: 10/10 frente a 0/5 da p={p_reves:.4f}, sin senal")

    print()
    print(f"correctas: {n_ok}   fallos: {n_mal}")
    return 1 if n_mal else 0


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--banco":
        sys.exit(banco())
    if len(sys.argv) < 2:
        print(__doc__.strip().splitlines()[2])
        sys.exit(1)
    sys.exit(informe(sys.argv[1]))
