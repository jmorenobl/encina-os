#!/usr/bin/env bash
# verificar-meta.sh — Idempotencia (R9) y purga de encina-meta.
#
# Uso:  ./scripts/verificar-meta.sh
#
# Es el equivalente de 05 y de 09 para E1, y va aparte de 11 por lo mismo que
# aquellos: la purga es destructiva y se ejecuta al final, cuando lo demás ya
# está comprobado.
#
# Lo que aquí importa de verdad es la conducta de purga de un METAPAQUETE:
# 'apt purge encina-meta' NO debe llevarse por delante los otros tres, y
# 'apt autoremove' SÍ debe proponerlos. Las dos cosas, y con la salida escrita.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
# MODELO DE SALIDA: CONTAR Y SEGUIR (tarea 2, MEDICIONES.md §4.67). fallo()
# apunta, incrementa N_MAL y SIGUE midiendo; morir() aborta; quien fija el
# código de salida es resumen(). El 'set' lo pone lib.sh:5 al hacer source: se
# REAFIRMA aquí para que las opciones de shell de este guion no dependan de a
# quién llame. Reafirmarlo no cambia ni una opción — control en §4.67.
set -euo pipefail
requiere_no_root

PAQUETE="encina-meta"
SALIDA_DIR="$(raiz_repo)/debian-packages"
DEB=$(ls -t "$SALIDA_DIR"/${PAQUETE}_*.deb 2>/dev/null | head -1 || true)
[[ -n "$DEB" ]] || { echo "No hay ningún .deb. Ejecuta antes ./scripts/construir-meta.sh"; exit 1; }

EST_INI=$(LC_ALL=C dpkg-query -W -f='${Status}' "$PAQUETE" 2>/dev/null || echo "")
if [[ "$EST_INI" != "install ok installed" ]]; then
    echo "$PAQUETE no está instalado. Ejecuta antes ./scripts/instalar-meta.sh"
    exit 1
fi

# Huella del sistema: lista de paquetes instalados con su versión. Es contra
# esto contra lo que se compara la idempotencia, y no contra "no ha dado error".
huella_sistema() {
    LC_ALL=C dpkg-query -W -f='${Package} ${Version} ${Status}\n' 2>/dev/null | sort
}

# ============================================================================
titulo "1. Idempotencia (R9): cinco instalaciones seguidas"
echo "  Instalar el mismo .deb cinco veces debe dejar el sistema idéntico."
echo "  Se compara la lista completa de paquetes con su versión, no el código"
echo "  de salida: un apt que sale con 0 y mueve cosas también pasaría."
echo

ANTES=$(huella_sistema)
FALLO_IDEM=0
for i in 1 2 3 4 5; do
    if SALIDA=$(sudo LC_ALL=C apt-get install -y --reinstall "$DEB" 2>&1); then
        echo "    vuelta $i: ok"
    else
        fallo "La vuelta $i ha fallado" "$(echo "$SALIDA" | tail -15)"
        FALLO_IDEM=1
        break
    fi
done
DESPUES=$(huella_sistema)

if (( ! FALLO_IDEM )); then
    DIFF=$(diff <(echo "$ANTES") <(echo "$DESPUES") || true)
    if [[ -z "$DIFF" ]]; then
        ok "Cinco instalaciones dejan el sistema idéntico"
    else
        fallo "El sistema ha cambiado tras reinstalar cinco veces" "$DIFF"
    fi
fi

# Control de la comprobación: si la huella no sabe detectar un cambio, el [OK]
# de arriba no vale nada. Se le da una huella con una línea alterada.
FALSA=$(echo "$ANTES" | sed '1s/$/ CONTROL/')
if [[ -n "$(diff <(echo "$ANTES") <(echo "$FALSA") || true)" ]]; then
    ok "La comprobación de idempotencia sabe detectar un cambio (control)"
else
    fallo "La comprobación de idempotencia no detecta un cambio inyectado" \
"Tal como está, habría dicho [OK] con el sistema cambiando."
fi

# ============================================================================
titulo "2. Purga: lo que un metapaquete NO debe llevarse por delante"

DEPENDIENTES="encina-branding encina-firefox-native autofirma"
echo "  Antes de purgar:"
for p in $DEPENDIENTES; do
    echo "    $p: $(LC_ALL=C dpkg-query -W -f='${Status}' "$p" 2>/dev/null || echo '(no instalado)')"
done
echo

paso "sudo apt purge encina-meta"
if PUR=$(sudo LC_ALL=C apt-get purge -y "$PAQUETE" 2>&1); then
    ok "apt purge termina sin error"
else
    fallo "apt purge ha fallado" "$(echo "$PUR" | tail -20)"
fi
echo "$PUR" | grep -E "^(Remv|Purg) " | sed 's/^/    /' || true

EST_META=$(LC_ALL=C dpkg-query -W -f='${Status}' "$PAQUETE" 2>/dev/null || echo "(no instalado)")
if [[ "$EST_META" != "install ok installed" ]]; then
    ok "encina-meta ya no está instalado ($EST_META)"
else
    fallo "encina-meta sigue instalado tras la purga" "$EST_META"
fi

SUPERVIVIENTES=0
for p in $DEPENDIENTES; do
    EST=$(LC_ALL=C dpkg-query -W -f='${Status}' "$p" 2>/dev/null || echo "")
    if [[ "$EST" == "install ok installed" ]]; then
        ok "$p sigue instalado, que es lo correcto para un metapaquete"
        SUPERVIVIENTES=$((SUPERVIVIENTES+1))
    else
        fallo "$p se ha desinstalado al purgar el metapaquete" \
"estado: ${EST:-(no instalado)}
Purgar un metapaquete no debe arrastrar lo que declara: quien lo instaló puede
querer seguir usándolo. Lo que sí debe pasar es que apt autoremove los proponga."
    fi
done

# ============================================================================
titulo "3. Y lo que sí debe proponer autoremove"
#
# Los tres quedan marcados como instalados automáticamente al haber entrado
# como dependencia. Si NINGUNO aparece en autoremove es que entraron marcados
# como manuales —cosa que pasa si se instalaron a mano antes— y entonces esta
# comprobación no está midiendo lo que cree.
AUTO=$(LC_ALL=C apt-get -s autoremove 2>&1 || true)
PROPUESTOS=$(grep -E "^Remv (encina-branding|encina-firefox-native|autofirma) " <<<"$AUTO" || true)
if [[ -n "$PROPUESTOS" ]]; then
    ok "apt autoremove propone retirarlos:"
    echo "$PROPUESTOS" | sed 's/^/         /'
else
    aviso "apt autoremove no propone ninguno de los tres"
    echo "         Suele significar que estaban marcados como instalados a mano"
    echo "         antes de que encina-meta los declarara. Compruébalo con:"
    echo "             apt-mark showmanual | grep -E 'encina|autofirma'"
    LC_ALL=C apt-mark showmanual 2>/dev/null | grep -E 'encina|autofirma' | sed 's/^/         /' || true
fi

echo
echo "  NO se ejecuta el autoremove: esta VM se conserva como banco de E1."
echo "  Si quieres dejarla limpia:  sudo apt autoremove --purge"

# ============================================================================
titulo "4. Reinstalación, para dejar la máquina como estaba"
if REINS=$(sudo LC_ALL=C apt-get install -y "$DEB" 2>&1); then
    ok "encina-meta reinstalado: la VM queda utilizable"
else
    fallo "No se ha podido reinstalar encina-meta" "$(echo "$REINS" | tail -20)"
fi

# ============================================================================
resumen
EST=$?
if (( EST == 0 )); then
    echo
    echo "Queda solo la casilla que decide, y no la da ningún script:"
    echo "  un clon aparte, el certificado dentro, una firma en valide.redsara.es,"
    echo "  mirada en pantalla, y la VM destruida después (ENCINA-OS.md §9.1)."
fi
exit $EST
