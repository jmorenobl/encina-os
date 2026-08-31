#!/usr/bin/env bash
# verificar-keyring.sh — La prueba de encina-keyring: que la clave manda.
#
# Uso:  ./scripts/verificar-keyring.sh [--repo-prueba <dir>] [--sin-purga]
#
# La comprobación que separa «parece que funciona» de «funciona» es la del
# MECANISMO, y necesita sus dos respuestas: un repositorio firmado con la
# clave de Encina tiene que entrar (apt update en verde y el Origin visible),
# y EL MISMO repositorio re-firmado con otra clave tiene que ser rechazado con
# NO_PUBKEY. Sin el rojo, el verde no mide nada.
#
# --repo-prueba es un repositorio apt COMPLETO (pool/ + dists/encina/ con
# InRelease firmado por la clave de verdad), fabricado en el constructor
# —la clave privada vive allí y no viaja—. Sin él, la sección 2 queda [OMIT].

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
# MODELO DE SALIDA: CONTAR Y SEGUIR (tarea 2, MEDICIONES.md §4.67).
set -euo pipefail
requiere_no_root

PAQUETE="encina-keyring"
HUELLA_ENCINA="58A525AB990C4B8DC5AB3D240A007E6F65F8C7EF"
KEYRING=/usr/share/keyrings/encina-archive-keyring.gpg
FUENTE=/etc/apt/sources.list.d/encina.sources
SALIDA_DIR="$(raiz_repo)/debian-packages"
DEB=$(ls -t "$SALIDA_DIR"/${PAQUETE}_*.deb 2>/dev/null | head -1 || true)
[[ -n "$DEB" ]] || { echo "No hay ningún .deb. Ejecuta antes ./scripts/construir-keyring.sh"; exit 1; }

REPO_PRUEBA=""; SIN_PURGA=0
while [[ $# -gt 0 ]]; do
    case "$1" in
        --repo-prueba) REPO_PRUEBA="$2"; shift 2 ;;
        --sin-purga)   SIN_PURGA=1; shift ;;
        *) echo "Opción desconocida: $1"; exit 1 ;;
    esac
done

EST=$(dpkg-query -W -f='${Status}' "$PAQUETE" 2>/dev/null || true)
[[ "$EST" == "install ok installed" ]] \
    || { echo "$PAQUETE no está instalado. Ejecuta antes ./scripts/instalar-keyring.sh"; exit 1; }

# apt update ACOTADO a una sola fuente: sin tocar las demás y sin borrar sus
# listas. Es el instrumento de toda la sección 2.
update_acotado() {  # $1 = fichero .list
    LC_ALL=C sudo apt-get update \
        -o Dir::Etc::SourceList="$1" \
        -o Dir::Etc::SourceParts=/dev/null \
        -o APT::Get::List-Cleanup=0 2>&1
}

# ============================================================================
titulo "1. Lo instalado: los dos ficheros, la huella y la integridad"

for f in "$KEYRING" "$FUENTE"; do
    if [[ -f "$f" ]]; then ok "Presente: $f"; else fallo "FALTA $f" ""; fi
done
H=$(gpg --show-keys --with-colons "$KEYRING" 2>/dev/null | awk -F: '/^fpr:/ {print $10; exit}')
if [[ "$H" == "$HUELLA_ENCINA" ]]; then
    ok "La clave instalada es la de Encina OS ($H)"
else
    fallo "La clave instalada tiene OTRA huella" "instalada: ${H:-ilegible}"
fi
comprobar "Integridad de los ficheros instalados (dpkg -V)" sudo dpkg -V "$PAQUETE"

# ============================================================================
titulo "2. EL MECANISMO: la clave manda, con sus dos respuestas"

if [[ -z "$REPO_PRUEBA" ]]; then
    omitido "sin --repo-prueba no hay repositorio firmado que medir (se fabrica en el constructor)"
else
    [[ -f "$REPO_PRUEBA/dists/encina/InRelease" ]] || { fallo "el repo de prueba no tiene dists/encina/InRelease" "$(ls -R "$REPO_PRUEBA" 2>/dev/null | head -10)"; }

    # --- EL CONTROL, PRIMERO: el mismo repo re-firmado con OTRA clave -------
    T=$(mktemp -d)
    cp -R "$REPO_PRUEBA" "$T/repo-malo"
    export GNUPGHOME="$T/gnupg-intruso"; mkdir -p "$GNUPGHOME"; chmod 700 "$GNUPGHOME"
    printf '%%no-protection\nKey-Type: eddsa\nKey-Curve: ed25519\nKey-Usage: sign\nName-Real: Intruso de prueba\nExpire-Date: 0\n%%commit\n' \
        | gpg --batch --generate-key >/dev/null 2>&1
    # el InRelease malo se firma sobre el MISMO Release (los mismos índices):
    # lo único distinto entre las dos respuestas es la clave
    sed -n '/^-----BEGIN PGP SIGNED MESSAGE-----$/,/^-----BEGIN PGP SIGNATURE-----$/p' \
        "$REPO_PRUEBA/dists/encina/InRelease" | sed '1,2d;$d' > "$T/Release.txt"
    gpg --clearsign -o "$T/repo-malo/dists/encina/InRelease.nuevo" "$T/Release.txt" >/dev/null 2>&1
    mv "$T/repo-malo/dists/encina/InRelease.nuevo" "$T/repo-malo/dists/encina/InRelease"
    unset GNUPGHOME
    cmp -s "$REPO_PRUEBA/dists/encina/InRelease" "$T/repo-malo/dists/encina/InRelease" \
        && fallo "CONTROL ROTO: el re-firmado no cambió el InRelease" ""
    echo "deb [signed-by=$KEYRING] file:$T/repo-malo encina main" > "$T/malo.list"
    if SAL=$(update_acotado "$T/malo.list"); then
        fallo "CONTROL ROTO: apt update ACEPTÓ un repo firmado con otra clave" "$SAL"
    else
        if grep -q "NO_PUBKEY" <<<"$SAL"; then
            ok "control: el repo firmado con OTRA clave se rechaza, y por el motivo correcto (NO_PUBKEY)"
        else
            fallo "el repo malo se rechazó pero NO por la clave" "$(tail -6 <<<"$SAL")"
        fi
    fi

    # --- LA MEDICIÓN: el repo firmado con la clave de verdad ----------------
    echo "deb [signed-by=$KEYRING] file:$REPO_PRUEBA encina main" > "$T/bueno.list"
    if SAL=$(update_acotado "$T/bueno.list"); then
        ok "el repo firmado con la clave de Encina entra: apt update en verde"
    else
        fallo "apt update rechazó el repo firmado con la clave BUENA" "$(tail -8 <<<"$SAL")"
    fi
    # shellcheck disable=SC2010  # los nombres de lista de apt derivan de URLs sin espacios; el filtro es por subcadena, un glob no sabe -i
    LISTA=$(ls /var/lib/apt/lists/ 2>/dev/null | grep -i "encina.*InRelease" | head -1 || true)
    if [[ -n "$LISTA" ]] && grep -q "^Origin: Encina OS" "/var/lib/apt/lists/$LISTA"; then
        ok "el origen quedó registrado: Origin: Encina OS (en $LISTA)"
    else
        # shellcheck disable=SC2010  # idem: listado informativo del [FALLO], nombres sin espacios
        fallo "no encuentro el Origin: Encina OS en las listas de apt" "$(ls /var/lib/apt/lists/ | grep -i encina || echo '(ninguna lista)')"
    fi
    sudo rm -f "/var/lib/apt/lists/$LISTA" 2>/dev/null || true
    rm -rf "$T"
fi

# ============================================================================
titulo "3. La fuente que viaja: el canal remoto, tal como está hoy"

if SAL=$(LC_ALL=C sudo apt-get update 2>&1); then
    if grep -q "downloads.sourceforge.net/project/encina-os/repo" <<<"$SAL"; then
        ok "el canal remoto CONTESTA: apt update en verde con la fuente de Encina dentro"
    else
        aviso "apt update en verde pero la fuente de Encina no aparece en la salida; revísalo"
    fi
else
    if grep -q "encina-os/repo" <<<"$SAL"; then
        aviso "apt update falla POR EL CANAL de Encina: esperado hasta que C3 publique el repositorio (D25: el repo va antes que la clave)"
        grep "encina-os/repo" <<<"$SAL" | head -3 | sed 's/^/         /'
    else
        fallo "apt update falla y NO es por el canal de Encina" "$(tail -8 <<<"$SAL")"
    fi
fi

# ============================================================================
titulo "4. Idempotencia: cinco instalaciones seguidas (R9)"

instantanea() {
    md5sum "$KEYRING" "$FUENTE" 2>&1
    dpkg -l "$PAQUETE" 2>/dev/null | tail -1
    ls -1 /etc/apt/sources.list.d/ 2>&1
}
IDEM_ANTES=$(instantanea)
CICLOS_OK=1
for i in 1 2 3 4 5; do
    if salida=$(sudo apt-get install -y --reinstall "$DEB" 2>&1); then
        printf "  ciclo %d/5 ok\n" "$i"
    else
        fallo "La reinstalación número $i ha fallado" "$(echo "$salida" | tail -15)"
        CICLOS_OK=0; break
    fi
done
(( CICLOS_OK )) && ok "Cinco reinstalaciones sin error"
IDEM_DESPUES=$(instantanea)
if [[ "$IDEM_ANTES" == "$IDEM_DESPUES" ]]; then
    ok "El estado es idéntico antes y después"
else
    fallo "El estado ha cambiado tras cinco reinstalaciones" \
"$(diff <(echo "$IDEM_ANTES") <(echo "$IDEM_DESPUES") || true)"
fi

# ============================================================================
if (( SIN_PURGA )); then
    titulo "5. Purga — OMITIDA por --sin-purga"
    omitido "apt purge devuelve la configuración original"
else
titulo "5. Purga: el sistema vuelve a su configuración original"

if salida=$(sudo apt-get purge -y "$PAQUETE" 2>&1); then
    ok "Purga ejecutada sin error"
else
    fallo "La purga ha fallado" "$(echo "$salida" | tail -15)"
fi
for f in "$KEYRING" "$FUENTE"; do
    if [[ -e "$f" ]]; then
        fallo "Tras purgar sigue existiendo $f" "$(ls -l "$f")"
    else
        ok "Eliminado: $f"
    fi
done
if SAL=$(LC_ALL=C sudo apt-get update 2>&1); then
    ok "Sin el paquete, apt update vuelve a estar en verde (la fuente de Encina ya no está)"
else
    aviso "apt update sigue fallando tras la purga; mira si es por otra fuente"
fi
paso "Reinstalando para dejar el sistema como estaba"
if sudo apt-get install -y "$DEB" >/dev/null 2>&1; then
    ok "Paquete reinstalado"
else
    fallo "No se ha podido reinstalar tras la purga" ""
fi
fi

resumen
