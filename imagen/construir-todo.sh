#!/usr/bin/env bash
# Encina OS - Bloque 0. DE UN CLON A LA ISO, EN UNA SOLA ORDEN.
#
#     ./construir-todo.sh --constructor jorge@192.168.64.3 \
#                         --iso-oficial <ubuntu-24.04.4-desktop-arm64.iso> \
#                         --autofirma <dir con autofirma_*.deb> \
#                         --salida <encina.iso>
#
# QUE HACE, y son las cuatro cosas que hasta hoy habia que encadenar a mano:
#     1. construye los TRES .deb de Encina desde el arbol VERSIONADO
#     2. cosecha los 24 de fuera y trae autofirma, todo POR HUELLA
#     3. genera el indice Packages
#     4. fabrica la ISO
#
# POR QUE CRUZA DOS MAQUINAS, y no es un capricho: 'dpkg-buildpackage' y
# 'dpkg-scanpackages' NO existen en macOS, y 'fabricar-iso.sh' usa 'md5 -q',
# 'stat -f' y el xorriso del Mac. Asi que los pasos 1 y 3 van por ssh a un
# constructor Linux -- encina-dev -- y los pasos 2 y 4 se quedan aqui.
#
# LO QUE SE CONSTRUYE ES 'git archive HEAD', NO EL DIRECTORIO DE TRABAJO. Es la
# leccion de MEDICIONES.md §4.37: las huellas vigentes hasta ese dia no eran de
# un paquete sino de UNA CONSTRUCCION, porque 'dpkg-deb' RECORTA los mtimes
# posteriores a SOURCE_DATE_EPOCH y DEJA PASAR los anteriores, asi que la fecha
# que un fichero tuviera en el disco viajaba dentro del .deb. Un checkout
# siempre pone fechas posteriores al changelog, el recorte las absorbe todas y
# la huella sale estable. Por eso este guion se NIEGA sobre un arbol sucio: lo
# que construiria no seria lo que se ve.
#
# LA DEFINICION DE TERMINADO DE ESTE GUION no es «sale una ISO»: es que DOS
# PASADAS SEGUIDAS DEN LA MISMA HUELLA. Ejecutalo dos veces a dos salidas
# distintas y comparalas. No se compara contra ninguna ISO anterior a
# proposito: ac0a5721… lleva dentro los .deb viejos y un seed que exige sus
# huellas, o sea que es coherente CONSIGO MISMA y no con el arbol de hoy.
#
# UNA SOLA VM ENCENDIDA A LA VEZ, y este guion lo COMPRUEBA antes de nada: dos
# VMs contestan en la misma IP y el hostname no distingue (trampa 14 de
# SCRIPTS.md). Con --vm <uuid> la enciende y la apaga el; sin --vm, la
# enciendes tu y el solo comprueba que no haya otra.

set -uo pipefail
export LC_ALL=C   # trampa 2: la salida de las herramientas, sin traducir

AQUI=$(cd "$(dirname "$0")" && pwd)
RAIZ=$(cd "$AQUI/.." && pwd)
MANIFIESTO="$AQUI/repo-manifiesto.tsv"

CONSTRUCTOR=""; ISO_OFICIAL=""; AUTOFIRMA=""; SALIDA=""
TRABAJO=""; VM=""; LLAVE=""; PERMITIR_SUCIO=0; CONSERVAR=0

uso() { sed -n '2,9p' "$0"; exit 2; }
while [ $# -gt 0 ]; do
    case "$1" in
        --constructor)    CONSTRUCTOR="$2";  shift 2 ;;
        --iso-oficial)    ISO_OFICIAL="$2";  shift 2 ;;
        --autofirma)      AUTOFIRMA="$2";    shift 2 ;;
        --salida)         SALIDA="$2";       shift 2 ;;
        --trabajo)        TRABAJO="$2";      shift 2 ;;
        --vm)             VM="$2";           shift 2 ;;
        --llave)          LLAVE="$2";        shift 2 ;;
        --permitir-sucio) PERMITIR_SUCIO=1;  shift ;;
        --conservar)      CONSERVAR=1;       shift ;;
        -h|--help)        sed -n '1,40p' "$0"; exit 0 ;;
        *) echo "[FALLO] argumento desconocido: $1"; uso ;;
    esac
done
[ -n "$CONSTRUCTOR" ] && [ -n "$ISO_OFICIAL" ] && [ -n "$AUTOFIRMA" ] && [ -n "$SALIDA" ] || uso

fallo() { echo "[FALLO] $*"; exit 1; }
ok()    { echo "[OK]    $*"; }
paso()  { echo; echo "== $*"; }
# contar con un glob y no con 'ls | grep': un nombre raro no cuenta de mas ni de
# menos, y 'ls' de un directorio vacio no vale 1
contar_deb() { local n=0 f; for f in "$1"/*.deb; do [ -e "$f" ] && n=$((n+1)); done; echo "$n"; }

APAGAR_AL_SALIR=""
limpieza() {
    [ -n "$APAGAR_AL_SALIR" ] && { echo; echo "== apagando la VM"; utmctl stop "$APAGAR_AL_SALIR" >/dev/null 2>&1; }
    [ "$CONSERVAR" = 0 ] && [ -n "${TMP_PROPIO:-}" ] && rm -rf "$TMP_PROPIO"
    return 0
}
trap limpieza EXIT

SSH_OPTS=(-o StrictHostKeyChecking=no -o ConnectTimeout=8 -o BatchMode=yes)
[ -n "$LLAVE" ] && SSH_OPTS+=(-i "$LLAVE")
R()  { ssh "${SSH_OPTS[@]}" "$CONSTRUCTOR" "$@"; }

# --- 0. el sitio, las herramientas y el arbol -------------------------------
paso "0. donde se esta construyendo, escrito antes de construir nada"
echo "        mac        $(sw_vers -productName) $(sw_vers -productVersion)  $(uname -m)"
echo "        xorriso    $(xorriso -version 2>&1 | sed -n 's/^xorriso version *: *//p' | head -1)"
for c in xorriso git shasum python3; do
    command -v "$c" >/dev/null || fallo "no hay $c en este Mac"
done
[ -f "$ISO_OFICIAL" ] || fallo "no existe la ISO oficial: $ISO_OFICIAL"
[ -d "$AUTOFIRMA" ]   || fallo "no existe el directorio de autofirma: $AUTOFIRMA"
[ -f "$MANIFIESTO" ]  || fallo "no existe el manifiesto: $MANIFIESTO"

cd "$RAIZ" || fallo "no pude entrar en $RAIZ"
git rev-parse --git-dir >/dev/null 2>&1 || fallo "$RAIZ no es un repositorio git"
COMMIT=$(git rev-parse HEAD)
SUCIO=$(git status --porcelain | wc -l | tr -d ' ')
echo "        commit     $COMMIT"
if [ "$SUCIO" -ne 0 ]; then
    if [ "$PERMITIR_SUCIO" = 0 ]; then
        fallo "el arbol tiene $SUCIO cambios sin confirmar y se construye 'git archive HEAD'.
        Lo que saldria NO seria lo que ves. Confirmalos, o pasa --permitir-sucio
        sabiendo que la ISO NO describe este directorio de trabajo."
    fi
    echo "        AVISO      $SUCIO cambios sin confirmar: NO viajan (se construye HEAD)"
fi
ok "arbol versionado en $COMMIT${SUCIO:+ }"

# --- 1. una sola VM encendida a la vez --------------------------------------
paso "1. una sola VM encendida a la vez (trampa 14: dos contestan en la misma IP)"
if command -v utmctl >/dev/null; then
    ENCENDIDAS=$(utmctl list | awk 'NR>1 && $2=="started" {print $1" "$3}')
    N=$(printf '%s' "$ENCENDIDAS" | grep -c . )
    if [ -n "$VM" ]; then
        OTRAS=$(printf '%s\n' "$ENCENDIDAS" | grep -v "^$VM " | grep -c . )
        [ "$OTRAS" -eq 0 ] || fallo "hay $OTRAS VM(s) encendidas que no son la pedida:
$(printf '%s\n' "$ENCENDIDAS" | grep -v "^$VM ")"
        if ! printf '%s\n' "$ENCENDIDAS" | grep -q "^$VM "; then
            echo "        encendiendo $VM"
            utmctl start "$VM" >/dev/null || fallo "no pude encender $VM"
            APAGAR_AL_SALIR="$VM"
        else
            ok "la VM pedida ya estaba encendida (no la apago yo)"
        fi
    else
        [ "$N" -le 1 ] || fallo "hay $N VMs encendidas a la vez:
$ENCENDIDAS"
    fi
    ok "VMs encendidas: $(utmctl list | awk 'NR>1 && $2=="started"' | grep -c .)"
else
    echo "        (no hay utmctl: no puedo comprobar cuantas VMs hay encendidas)"
fi

# el constructor contesta, y se identifica POR HUELLA y nunca por nombre
for _ in $(seq 1 30); do R true 2>/dev/null && break; sleep 6; done
R true 2>/dev/null || fallo "el constructor $CONSTRUCTOR no contesta por ssh"
echo "        constructor $(R 'echo "$(lsb_release -ds 2>/dev/null)  $(dpkg --print-architecture)"')"
echo "        machine-id  $(R 'cat /etc/machine-id')"
echo "        dpkg        $(R 'dpkg-query -W -f="\${Version}" dpkg')  dpkg-dev $(R 'dpkg-query -W -f="\${Version}" dpkg-dev')"
for c in dpkg-buildpackage lintian dpkg-scanpackages gpg; do
    R "command -v $c >/dev/null" || fallo "al constructor le falta $c"
done
ok "el constructor tiene dpkg-buildpackage, lintian, dpkg-scanpackages y gpg"

# --- 2. el arbol versionado viaja, y se coteja a los dos lados --------------
paso "2. 'git archive HEAD' al constructor -- lo versionado, no el disco (§4.37c)"
REMOTO="encina-construir-$COMMIT"
R "rm -rf ~/$REMOTO && mkdir -p ~/$REMOTO" || fallo "no pude preparar ~/$REMOTO"
git archive HEAD | R "tar -xf - -C ~/$REMOTO" || fallo "no pude enviar el arbol"
# el cotejo, que es lo unico que protege de verdad (trampa 24: COPYFILE_DISABLE
# no suprime las cabeceras pax, y contar entradas '._' ya no demuestra nada)
TMP_PROPIO=$(mktemp -d) || fallo "mktemp"
git archive HEAD | tar -tf - | grep -v '/$' | LC_ALL=C sort > "$TMP_PROPIO/aqui"
R "cd ~/$REMOTO && find . -type f | sed 's|^\./||' | LC_ALL=C sort" > "$TMP_PROPIO/alli"
D=$(diff "$TMP_PROPIO/aqui" "$TMP_PROPIO/alli" | grep -c '^[<>]')
[ "$D" -eq 0 ] || fallo "el arbol no llego entero: $D diferencias
$(diff "$TMP_PROPIO/aqui" "$TMP_PROPIO/alli" | head -10)"
ok "$(grep -c . "$TMP_PROPIO/aqui") ficheros a los dos lados, 0 diferencias"
# CONTROL de ese cotejo: tiene que saber ver un nombre cambiado
sed '1s/^./Z/' "$TMP_PROPIO/aqui" > "$TMP_PROPIO/sab"
cmp -s "$TMP_PROPIO/aqui" "$TMP_PROPIO/sab" && fallo "CONTROL ROTO: el sabotaje no saboteo"
C=$(diff "$TMP_PROPIO/sab" "$TMP_PROPIO/alli" | grep -c '^[<>]')
[ "$C" -ge 1 ] || fallo "CONTROL ROTO: el cotejo no ve un nombre cambiado"
ok "control: con un nombre cambiado, el cotejo lo senala"

# --- 3. los tres .deb, construidos alli -------------------------------------
paso "3. los tres .deb de Encina, desde el arbol versionado"
for g in 03-construir.sh 07-firefox-construir.sh 10-meta-construir.sh; do
    echo "        $g"
    R "cd ~/$REMOTO && ENCINA_REPO=~/$REMOTO bash scripts/$g" > "$TMP_PROPIO/$g.log" 2>&1 \
        || { tail -25 "$TMP_PROPIO/$g.log"; fallo "$g no paso"; }
    # los tres guiones COLOREAN su salida (lib.sh), asi que hay que quitar los
    # codigos ANSI antes de contar. Y UN RECUENTO DE CERO NO ES «TODO BIEN»: es
    # que este contador no sabe leer la salida, y se trata como fallo. La primera
    # version de esta linea imprimia «0 comprobaciones, 0 fallos» sobre tres
    # construcciones que en realidad hacen 25, 39 y 14 (§4.37f).
    ESC=$(printf '\033')
    sed "s/${ESC}\[[0-9;]*m//g" "$TMP_PROPIO/$g.log" > "$TMP_PROPIO/$g.limpio"
    NOK=$(grep -c '\[OK\]'    "$TMP_PROPIO/$g.limpio")
    NML=$(grep -c '\[FALLO\]' "$TMP_PROPIO/$g.limpio")
    [ "$NOK" -gt 0 ] || { tail -25 "$TMP_PROPIO/$g.limpio"
        fallo "$g no imprimio ni una comprobacion: el contador no sabe leer su salida"; }
    [ "$NML" -eq 0 ] || { grep '\[FALLO\]' "$TMP_PROPIO/$g.limpio"; fallo "$g dio $NML fallos"; }
    echo "          $NOK comprobaciones, $NML fallos"
done
mkdir -p "$TMP_PROPIO/propios"
R "cd ~/$REMOTO/debian-packages && tar -cf - *.deb" | tar -xf - -C "$TMP_PROPIO/propios" \
    || fallo "no pude traerme los .deb"
ok "traidos $(contar_deb "$TMP_PROPIO/propios") .deb del constructor"

# LA COMPROBACION QUE IMPORTA: entran POR HUELLA, contra el manifiesto. Un .deb
# con el nombre bueno y otros bytes se rechaza aqui y no llega a la ISO.
MAL=0
while IFS=$'\t' read -r org pkg _ fic tam sha; do
    [ "$org" = PROPIO ] || continue
    [ "$pkg" = autofirma ] && continue          # ese no lo construye este repo
    f="$TMP_PROPIO/propios/$fic"
    if [ ! -f "$f" ]; then echo "        [FALTA]  $fic"; MAL=$((MAL+1)); continue; fi
    r=$(shasum -a 256 "$f" | cut -d' ' -f1)
    t=$(stat -f %z "$f")
    if [ "$r" = "$sha" ] && [ "$t" = "$tam" ]; then
        echo "        [OK]     $fic  ${r:0:12}…  $t bytes"
    else
        echo "        [HALLAZGO] $fic NO es el del manifiesto"
        echo "            esperada $sha  $tam"
        echo "            real     $r  $t"
        MAL=$((MAL+1))
    fi
done < "$MANIFIESTO"
[ "$MAL" -eq 0 ] || fallo "$MAL de los tres .deb propios no cuadran con el manifiesto"
ok "los tres .deb propios cuadran con el manifiesto, huella y tamano"

# --- 4. la cosecha: los 24 de fuera y autofirma, todo por huella -------------
paso "4. la cosecha -- 24 de fuera + autofirma, POR HUELLA"
[ -n "$TRABAJO" ] || TRABAJO="$TMP_PROPIO/repo"
mkdir -p "$TRABAJO" || fallo "no pude crear $TRABAJO"
# DOS ORDENES, y la PRIMERA TIENE QUE SALIR INCOMPLETA: en ese momento aun no
# esta autofirma, que se construye en otro repositorio. Su «27 de 28 -> [FALLO]»
# es EL CONTROL de que cosechar-repo.sh sabe dar la respuesta mala antes de
# escribir nada, y va anunciado para que nadie aprenda a saltarse los [FALLO].
echo "        (la 1a orden SALE INCOMPLETA a proposito: falta autofirma. Su [FALLO] es el control)"
"$AQUI/cosechar-repo.sh" --salida "$TRABAJO" --propios "$TMP_PROPIO/propios" \
    | sed 's/^/        /' | tail -6
N_PARCIAL=$(contar_deb "$TRABAJO")
[ "$N_PARCIAL" -eq 27 ] || fallo "CONTROL ROTO: sin autofirma esperaba 27 .deb y hay $N_PARCIAL"
ok "control: sin autofirma la cosecha se queda en 27 y se niega"
echo "        (la 2a orden la completa con autofirma, POR HUELLA entre tres casi homonimos)"
"$AQUI/cosechar-repo.sh" --salida "$TRABAJO" --propios "$AUTOFIRMA" \
    | sed 's/^/        /' | tail -6
N=$(contar_deb "$TRABAJO")
[ "$N" -eq 28 ] || fallo "en la cosecha hay $N .deb y tenian que ser 28"
ok "28 .deb cosechados sin tocar ninguna ISO"

# --- 5. el indice, que no se puede hacer aqui -------------------------------
paso "5. el indice Packages (dpkg-scanpackages no existe en macOS)"
R "rm -rf ~/$REMOTO-repo && mkdir -p ~/$REMOTO-repo"
( cd "$TRABAJO" && COPYFILE_DISABLE=1 tar -cf - *.deb ) \
    | R "cd ~/$REMOTO-repo && tar -xf - 2>/dev/null" || fallo "no pude enviar los 28"
# el cotejo de huellas a los dos lados, que es la proteccion de verdad (trampa 24)
( cd "$TRABAJO" && shasum -a 256 *.deb ) | LC_ALL=C sort > "$TMP_PROPIO/h.aqui"
R "cd ~/$REMOTO-repo && sha256sum *.deb" | LC_ALL=C sort > "$TMP_PROPIO/h.alli"
D=$(diff "$TMP_PROPIO/h.aqui" "$TMP_PROPIO/h.alli" | grep -c '^[<>]')
[ "$D" -eq 0 ] || fallo "los 28 no llegaron iguales: $D diferencias"
ok "las 28 huellas cuadran a los dos lados"
sed '1s/^./f/' "$TMP_PROPIO/h.aqui" > "$TMP_PROPIO/h.sab"
cmp -s "$TMP_PROPIO/h.aqui" "$TMP_PROPIO/h.sab" && fallo "CONTROL ROTO: el sabotaje no saboteo"
[ "$(diff "$TMP_PROPIO/h.sab" "$TMP_PROPIO/h.alli" | grep -c '^[<>]')" -ge 1 ] \
    || fallo "CONTROL ROTO: el cotejo no ve una huella cambiada en un caracter"
ok "control: con una huella cambiada en UN caracter, el cotejo la senala"

R "cd ~/$REMOTO-repo && dpkg-scanpackages . /dev/null > Packages 2>/dev/null" \
    || fallo "dpkg-scanpackages fallo"
scp -q "${SSH_OPTS[@]}" "$CONSTRUCTOR:~/$REMOTO-repo/Packages" "$TRABAJO/Packages" \
    || fallo "no pude traerme el Packages"
HA=$(R "sha256sum ~/$REMOTO-repo/Packages | cut -d' ' -f1")
HB=$(shasum -a 256 "$TRABAJO/Packages" | cut -d' ' -f1)
[ "$HA" = "$HB" ] || fallo "el Packages no llego igual
        alli $HA
        aqui $HB"
ok "Packages: $(grep -c '^Filename: ' "$TRABAJO/Packages") entradas, ${HB:0:16}…"

# el indice contra el manifiesto, en las dos direcciones
awk -F'\t' '$1=="PROPIO"||$1=="ARCHIVO"{print $4" "$5" "$6}' "$MANIFIESTO" | LC_ALL=C sort > "$TMP_PROPIO/man"
paste -d' ' <(sed -n 's|^Filename: \./||p' "$TRABAJO/Packages") \
            <(sed -n 's|^Size: ||p'         "$TRABAJO/Packages") \
            <(sed -n 's|^SHA256: ||p'       "$TRABAJO/Packages") | LC_ALL=C sort > "$TMP_PROPIO/idx"
D=$(diff "$TMP_PROPIO/man" "$TMP_PROPIO/idx" | grep -c '^[<>]')
[ "$D" -eq 0 ] || fallo "el indice y el manifiesto no dicen lo mismo: $D diferencias
$(diff "$TMP_PROPIO/man" "$TMP_PROPIO/idx" | head -8)"
ok "el indice y el manifiesto dicen lo mismo en las 28 lineas"
awk 'NR==1{$2=$2+1}1' "$TMP_PROPIO/man" > "$TMP_PROPIO/man.sab"
[ "$(diff "$TMP_PROPIO/man.sab" "$TMP_PROPIO/idx" | grep -c '^[<>]')" -eq 2 ] \
    || fallo "CONTROL ROTO: con un tamano falseado, la comparacion no lo senala"
ok "control: con un tamano falseado, la comparacion lo senala"

# --- 6. la ISO --------------------------------------------------------------
paso "6. la ISO"
"$AQUI/fabricar-iso.sh" --iso "$ISO_OFICIAL" --repo "$TRABAJO" --salida "$SALIDA" \
    | sed 's/^/        /' || fallo "fabricar-iso.sh no paso"
[ -f "$SALIDA" ] || fallo "no salio la ISO"

echo
echo "commit: $COMMIT"
echo "iso:    $SALIDA"
echo "sha256: $(shasum -a 256 "$SALIDA" | cut -d' ' -f1)"
echo "tam:    $(stat -f %z "$SALIDA") bytes"
echo
echo "LO QUE ESTE GUION NO PUEDE DECIR:"
echo "  - que la ISO arranque. Eso se mide en una VM creada desde cero."
echo "  - que sea reproducible. Eso es ESTA MISMA ORDEN OTRA VEZ, a otra salida,"
echo "    y las dos huellas comparadas. Una sola pasada no lo demuestra."
