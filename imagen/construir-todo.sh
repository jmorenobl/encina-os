#!/usr/bin/env bash
# Encina OS - Bloque 0. DE UN CLON A LA ISO, EN UNA SOLA ORDEN.
#
#     ./construir-todo.sh --constructor jorge@192.168.64.3 \
#                         --iso-oficial <ubuntu-24.04.4-desktop-arm64.iso> \
#                         --autofirma <dir con autofirma_*.deb> \
#                         --salida <encina.iso> [--cosecha <dir|tar|URL>]
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
# DESDE LA COSECHA PUBLICADA (2026-08-29, MEDICIONES.md §4.82): --cosecha, y
# tambien --archivo, --mozilla y --launchpad, se le pasan TAL CUAL a
# cosechar-repo.sh, que es quien sabe lo que significan: los 25 de ARCHIVO se
# cogen del tar publicado junto a la ISO, POR HUELLA, sin tocar el archivo de
# Ubuntu ni Mozilla ni Launchpad. Es lo que hace que un clon limpio reproduzca
# las huellas el dia que el archivo haya retirado lo que el manifiesto ancla
# (trampa 68). Los tres .deb de Encina se siguen construyendo aqui, del arbol.
#
# UNA SOLA VM ENCENDIDA A LA VEZ, y este guion lo COMPRUEBA antes de nada: dos
# VMs contestan en la misma IP y el hostname no distingue (trampa 14 de
# SCRIPTS.md). Con --vm <uuid> la enciende y la apaga el; sin --vm, la
# enciendes tu y el solo comprueba que no haya otra.

# MODELO DE SALIDA: ABORTAR (tarea 2, MEDICIONES.md §4.67). Este guion no
# cuenta ni resume: el primer problema lo para, y la palabra es morir(), que
# escribe [FALLO] por stderr y sale con 1. Hasta el 2026-08-28 esa misma
# funcion se llamaba fallo(), igual que la que en lib.sh APUNTA Y SIGUE; la
# misma palabra para dos flujos de control opuestos es lo que la tarea 2 quita.
# El 'set' de abajo es el que este guion ya tenia y no se ha unificado con el
# de lib.sh: cambiar las opciones de shell de un guion sin ejecutarlo entero
# seria una mutacion sin verificar.
set -uo pipefail
export LC_ALL=C   # trampa 2: la salida de las herramientas, sin traducir

AQUI=$(cd "$(dirname "$0")" && pwd)
RAIZ=$(cd "$AQUI/.." && pwd)
# LA ARQUITECTURA NO SE DECLARA AQUI: sale de la ISO oficial que se le da, igual
# que en fabricar-iso.sh (§4.64). Lo que hace este guion es PASARLA a los dos
# hijos que si la necesitan -- cosechar-repo.sh (que archivo, que manifiesto) --
# leyendola del nombre del fichero, que es lo unico que hay antes de tocar la
# ISO. fabricar-iso.sh la vuelve a deducir POR HUELLA y para si no cuadran.
ARQ=""
MANIFIESTO=""

CONSTRUCTOR=""; ISO_OFICIAL=""; AUTOFIRMA=""; SALIDA=""
TRABAJO=""; VM=""; LLAVE=""; PERMITIR_SUCIO=0; CONSERVAR=0
# LAS BANDERAS DE BISECADO NO SE INTERPRETAN AQUI: se le pasan tal cual a
# fabricar-iso.sh, que es quien sabe lo que significan y quien comprueba en su
# paso 13 que el medio terminado lleva justo eso. Este guion solo las repite en
# su salida, para que un registro de 20 minutos diga en la cabecera que se ha
# fabricado.
BISECADO=""
# lo que va a cosechar-repo.sh tal cual (--cosecha y las URLs); un array que
# puede estar vacio, y en el bash 3.2 de macOS eso se expande como dice la
# trampa 59: ${A[@]+"${A[@]}"}
COSECHA_OPTS=()

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
        --sin-capa|--sin-volid|--sin-info|--sin-menu)
                          BISECADO="$BISECADO $1"; shift ;;
        --cosecha|--archivo|--mozilla|--launchpad)
                          COSECHA_OPTS+=("$1" "$2"); shift 2 ;;
        -h|--help)        sed -n '1,40p' "$0"; exit 0 ;;
        *) echo "[FALLO] argumento desconocido: $1"; uso ;;
    esac
done
# --iso-oficial vale por defecto medios/, que es donde la deja
# imagen/traer-iso-oficial.sh. Ese directorio esta en .gitignore: la ISO son
# 3,3 GiB y no viaja en el clon, pero la ORDEN de traerla si (medios/LEEME.md).
[ -n "$ISO_OFICIAL" ] || ISO_OFICIAL="$RAIZ/medios/ubuntu-24.04.4-desktop-arm64.iso"
case "$(basename "$ISO_OFICIAL")" in
    *-amd64.iso) ARQ=amd64 ;;
    *-arm64.iso) ARQ=arm64 ;;
    *) echo "[FALLO] no se que arquitectura es «$(basename "$ISO_OFICIAL")»"; exit 1 ;;
esac
[ -n "$MANIFIESTO" ] || { [ "$ARQ" = amd64 ] \
    && MANIFIESTO="$AQUI/repo-manifiesto-amd64.tsv" \
    || MANIFIESTO="$AQUI/repo-manifiesto.tsv"; }
[ -n "$CONSTRUCTOR" ] && [ -n "$AUTOFIRMA" ] && [ -n "$SALIDA" ] || uso

# EL VOCABULARIO VIENE DE lib/salida.sh (tarea 3): ok/fallo/aviso/omitido, los
# contadores N_OK/N_MAL/N_AVI/N_OMI y morir(). Este guion ya no define ninguno.
. "$AQUI/../lib/salida.sh"
# las etapas de este guion se rotulan con titulo(); hasta la tarea 3 tenia un
# paso() propio que imprimia «== N.» y sombreaba al de la biblioteca
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
titulo "0. donde se esta construyendo, escrito antes de construir nada"
echo "        mac        $(sw_vers -productName) $(sw_vers -productVersion)  $(uname -m)"
echo "        xorriso    $(xorriso -version 2>&1 | sed -n 's/^xorriso version *: *//p' | head -1)"
for c in xorriso git shasum python3; do
    command -v "$c" >/dev/null || morir "no hay $c en este Mac"
done
[ -f "$ISO_OFICIAL" ] || morir "no esta la ISO oficial: $ISO_OFICIAL
        Traela y comprueba su firma con:  ./imagen/traer-iso-oficial.sh
        (medios/ esta en .gitignore a proposito: ver medios/LEEME.md)"
[ -d "$AUTOFIRMA" ]   || morir "no existe el directorio de autofirma: $AUTOFIRMA"
[ -f "$MANIFIESTO" ]  || morir "no existe el manifiesto: $MANIFIESTO"

cd "$RAIZ" || morir "no pude entrar en $RAIZ"
git rev-parse --git-dir >/dev/null 2>&1 || morir "$RAIZ no es un repositorio git"
COMMIT=$(git rev-parse HEAD)
SUCIO=$(git status --porcelain | wc -l | tr -d ' ')
echo "        commit     $COMMIT"
[ ${#COSECHA_OPTS[@]} -eq 0 ] || echo "        cosecha    ${COSECHA_OPTS[*]}   (los de ARCHIVO, de ahi y por huella)"
if [ "$SUCIO" -ne 0 ]; then
    if [ "$PERMITIR_SUCIO" = 0 ]; then
        morir "el arbol tiene $SUCIO cambios sin confirmar y se construye 'git archive HEAD'.
        Lo que saldria NO seria lo que ves. Confirmalos, o pasa --permitir-sucio
        sabiendo que la ISO NO describe este directorio de trabajo."
    fi
    echo "        AVISO      $SUCIO cambios sin confirmar: NO viajan (se construye HEAD)"
fi
ok "arbol versionado en $COMMIT${SUCIO:+ }"

# --- 1. una sola VM encendida a la vez --------------------------------------
titulo "1. una sola VM encendida a la vez (trampa 14: dos contestan en la misma IP)"
if command -v utmctl >/dev/null; then
    ENCENDIDAS=$(utmctl list | awk 'NR>1 && $2=="started" {print $1" "$3}')
    N=$(printf '%s' "$ENCENDIDAS" | grep -c . )
    if [ -n "$VM" ]; then
        OTRAS=$(printf '%s\n' "$ENCENDIDAS" | grep -v "^$VM " | grep -c . )
        [ "$OTRAS" -eq 0 ] || morir "hay $OTRAS VM(s) encendidas que no son la pedida:
$(printf '%s\n' "$ENCENDIDAS" | grep -v "^$VM ")"
        if ! printf '%s\n' "$ENCENDIDAS" | grep -q "^$VM "; then
            echo "        encendiendo $VM"
            # OJO: 'utmctl start' DEVUELVE 0 AUNQUE FALLE. Escribe
            # «Error from event: ... (OSStatus error -1712.)» por stderr y sale
            # con codigo 0, asi que un '|| morir' aqui NO SE DISPARA NUNCA. Paso
            # el 2026-08-17 (MEDICIONES.md §4.54g): la VM no arranco, este bloque
            # imprimio «[OK] VMs encendidas: 0» justo despues de decir que
            # encendia una, y el guion acabo culpando a ssh -- que manda a mirar
            # al sitio equivocado. La causa real era UTM con la conexion interna
            # caida (-609 por AppleScript), y se arregla reiniciando UTM.
            # Asi que NO se cree el codigo de salida: se espera al ESTADO.
            utmctl start "$VM" >/dev/null 2>&1
            ARRANCO=0
            for _ in $(seq 1 30); do
                [ "$(utmctl status "$VM" 2>/dev/null)" = "started" ] && { ARRANCO=1; break; }
                sleep 2
            done
            [ "$ARRANCO" -eq 1 ] || morir "no pude encender $VM: sigue en «$(utmctl status "$VM" 2>&1)».
        'utmctl start' devuelve 0 aunque falle, asi que mira su stderr. Si dice
        OSStatus -1712 o -609, UTM tiene la conexion interna caida: reinicialo."
            APAGAR_AL_SALIR="$VM"
        else
            ok "la VM pedida ya estaba encendida (no la apago yo)"
        fi
    else
        [ "$N" -le 1 ] || morir "hay $N VMs encendidas a la vez:
$ENCENDIDAS"
    fi
    # y este recuento SE COMPRUEBA en vez de imprimirse: un «0 encendidas» aqui
    # es el modo de fallo de arriba, no una buena noticia
    ENC=$(utmctl list | awk 'NR>1 && $2=="started"' | grep -c .)
    if [ -n "$VM" ]; then
        [ "$ENC" -eq 1 ] || morir "esperaba EXACTAMENTE 1 VM encendida y hay $ENC"
    fi
    ok "VMs encendidas: $ENC"
else
    echo "        (no hay utmctl: no puedo comprobar cuantas VMs hay encendidas)"
fi

# el constructor contesta, y se identifica POR HUELLA y nunca por nombre
for _ in $(seq 1 30); do R true 2>/dev/null && break; sleep 6; done
R true 2>/dev/null || morir "el constructor $CONSTRUCTOR no contesta por ssh"
echo "        constructor $(R 'echo "$(lsb_release -ds 2>/dev/null)  $(dpkg --print-architecture)"')"
echo "        machine-id  $(R 'cat /etc/machine-id')"
echo "        dpkg        $(R 'dpkg-query -W -f="\${Version}" dpkg')  dpkg-dev $(R 'dpkg-query -W -f="\${Version}" dpkg-dev')"
for c in dpkg-buildpackage lintian dpkg-scanpackages gpg; do
    R "command -v $c >/dev/null" || morir "al constructor le falta $c"
done
ok "el constructor tiene dpkg-buildpackage, lintian, dpkg-scanpackages y gpg"

# --- 2. el arbol versionado viaja, y se coteja a los dos lados --------------
titulo "2. 'git archive HEAD' al constructor -- lo versionado, no el disco (§4.37c)"
REMOTO="encina-construir-$COMMIT"
R "rm -rf ~/$REMOTO && mkdir -p ~/$REMOTO" || morir "no pude preparar ~/$REMOTO"
git archive HEAD | R "tar -xf - -C ~/$REMOTO" || morir "no pude enviar el arbol"
# el cotejo, que es lo unico que protege de verdad (trampa 24: COPYFILE_DISABLE
# no suprime las cabeceras pax, y contar entradas '._' ya no demuestra nada)
#
# Y '-o -type l' NO es una precaucion: el 2026-08-15 este cotejo dio [FALLO] con
# UNA diferencia sobre un arbol que habia llegado entero. El fichero era
#   debian-packages/encina-branding/src/etc/systemd/user/gnome-initial-setup-first-login.service
# el primer ENLACE SIMBOLICO versionado de este repositorio -la mascara de
# gnome-initial-setup, que apunta a /dev/null-. 'git archive' lo lista como una
# entrada mas y 'find -type f' NO lo ve, asi que los dos lados contaban cosas
# distintas. El fallo apunta en la direccion buena -dice que falta algo que si
# esta-, pero es del instrumento, no del arbol.
TMP_PROPIO=$(mktemp -d) || morir "mktemp"
git archive HEAD | tar -tf - | grep -v '/$' | LC_ALL=C sort > "$TMP_PROPIO/aqui"
R "cd ~/$REMOTO && find . \( -type f -o -type l \) | sed 's|^\./||' | LC_ALL=C sort" > "$TMP_PROPIO/alli"
D=$(diff "$TMP_PROPIO/aqui" "$TMP_PROPIO/alli" | grep -c '^[<>]')
[ "$D" -eq 0 ] || morir "el arbol no llego entero: $D diferencias
$(diff "$TMP_PROPIO/aqui" "$TMP_PROPIO/alli" | head -10)"
ok "$(grep -c . "$TMP_PROPIO/aqui") ficheros a los dos lados, 0 diferencias"
# CONTROL de ese cotejo: tiene que saber ver un nombre cambiado
sed '1s/^./Z/' "$TMP_PROPIO/aqui" > "$TMP_PROPIO/sab"
cmp -s "$TMP_PROPIO/aqui" "$TMP_PROPIO/sab" && morir "CONTROL ROTO: el sabotaje no saboteo"
C=$(diff "$TMP_PROPIO/sab" "$TMP_PROPIO/alli" | grep -c '^[<>]')
[ "$C" -ge 1 ] || morir "CONTROL ROTO: el cotejo no ve un nombre cambiado"
ok "control: con un nombre cambiado, el cotejo lo senala"

# --- 3. los tres .deb, construidos alli -------------------------------------
titulo "3. los tres .deb de Encina, desde el arbol versionado"
for g in construir-branding.sh construir-firefox.sh construir-meta.sh; do
    echo "        $g"
    R "cd ~/$REMOTO && ENCINA_REPO=~/$REMOTO bash scripts/$g" > "$TMP_PROPIO/$g.log" 2>&1 \
        || { tail -25 "$TMP_PROPIO/$g.log"; morir "$g no paso"; }
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
        morir "$g no imprimio ni una comprobacion: el contador no sabe leer su salida"; }
    [ "$NML" -eq 0 ] || { grep '\[FALLO\]' "$TMP_PROPIO/$g.limpio"; morir "$g dio $NML fallos"; }
    echo "          $NOK comprobaciones, $NML fallos"
done
mkdir -p "$TMP_PROPIO/propios"
R "cd ~/$REMOTO/debian-packages && tar -cf - *.deb" | tar -xf - -C "$TMP_PROPIO/propios" \
    || morir "no pude traerme los .deb"
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
[ "$MAL" -eq 0 ] || morir "$MAL de los tres .deb propios no cuadran con el manifiesto"
ok "los tres .deb propios cuadran con el manifiesto, huella y tamano"

# --- 4. la cosecha: los 24 de fuera y autofirma, todo por huella -------------
titulo "4. la cosecha -- 24 de fuera + autofirma, POR HUELLA"
[ -n "$TRABAJO" ] || TRABAJO="$TMP_PROPIO/repo"
mkdir -p "$TRABAJO" || morir "no pude crear $TRABAJO"
# CUANTOS .deb SON LO DICE EL MANIFIESTO, y no este guion. Estuvo escrito «28» a
# mano hasta el 2026-08-22, y ese dia el manifiesto paso a 29 al meter libnss3
# (§4.61): un numero repetido en dos sitios es un sitio donde se pueden separar,
# y el que manda es el manifiesto, que es LA FUENTE de la lista (cosechar-repo.sh).
N_MAN=$(grep -cE '^(ARCHIVO|PROPIO)'"$(printf '\t')" "$MANIFIESTO")
[ "$N_MAN" -gt 0 ] || morir "el manifiesto no tiene lineas de datos: $MANIFIESTO"
# DOS ORDENES, y la PRIMERA TIENE QUE SALIR INCOMPLETA: en ese momento aun no
# esta autofirma, que se construye en otro repositorio. Su «N-1 de N -> [FALLO]»
# es EL CONTROL de que cosechar-repo.sh sabe dar la respuesta mala antes de
# escribir nada, y va anunciado para que nadie aprenda a saltarse los [FALLO].
echo "        (la 1a orden SALE INCOMPLETA a proposito: falta autofirma. Su [FALLO] es el control)"
"$AQUI/cosechar-repo.sh" --arq "$ARQ" --salida "$TRABAJO" --propios "$TMP_PROPIO/propios" \
    ${COSECHA_OPTS[@]+"${COSECHA_OPTS[@]}"} | sed 's/^/        /' | tail -6
N_PARCIAL=$(contar_deb "$TRABAJO")
[ "$N_PARCIAL" -eq $((N_MAN - 1)) ] || morir "CONTROL ROTO: sin autofirma esperaba $((N_MAN - 1)) .deb y hay $N_PARCIAL"
ok "control: sin autofirma la cosecha se queda en $((N_MAN - 1)) y se niega"
echo "        (la 2a orden la completa con autofirma, POR HUELLA entre tres casi homonimos)"
"$AQUI/cosechar-repo.sh" --arq "$ARQ" --salida "$TRABAJO" --propios "$AUTOFIRMA" \
    ${COSECHA_OPTS[@]+"${COSECHA_OPTS[@]}"} | sed 's/^/        /' | tail -6
N=$(contar_deb "$TRABAJO")
[ "$N" -eq "$N_MAN" ] || morir "en la cosecha hay $N .deb y el manifiesto pide $N_MAN"
ok "$N .deb cosechados sin tocar ninguna ISO, los que pide el manifiesto"

# --- 5. el indice, que no se puede hacer aqui -------------------------------
titulo "5. el indice Packages (dpkg-scanpackages no existe en macOS)"
R "rm -rf ~/$REMOTO-repo && mkdir -p ~/$REMOTO-repo"
( cd "$TRABAJO" && COPYFILE_DISABLE=1 tar -cf - *.deb ) \
    | R "cd ~/$REMOTO-repo && tar -xf - 2>/dev/null" || morir "no pude enviar los $N_MAN"
# el cotejo de huellas a los dos lados, que es la proteccion de verdad (trampa 24)
( cd "$TRABAJO" && shasum -a 256 *.deb ) | LC_ALL=C sort > "$TMP_PROPIO/h.aqui"
R "cd ~/$REMOTO-repo && sha256sum *.deb" | LC_ALL=C sort > "$TMP_PROPIO/h.alli"
D=$(diff "$TMP_PROPIO/h.aqui" "$TMP_PROPIO/h.alli" | grep -c '^[<>]')
[ "$D" -eq 0 ] || morir "los $N_MAN no llegaron iguales: $D diferencias"
ok "las $N_MAN huellas cuadran a los dos lados"
sed '1s/^./f/' "$TMP_PROPIO/h.aqui" > "$TMP_PROPIO/h.sab"
cmp -s "$TMP_PROPIO/h.aqui" "$TMP_PROPIO/h.sab" && morir "CONTROL ROTO: el sabotaje no saboteo"
[ "$(diff "$TMP_PROPIO/h.sab" "$TMP_PROPIO/h.alli" | grep -c '^[<>]')" -ge 1 ] \
    || morir "CONTROL ROTO: el cotejo no ve una huella cambiada en un caracter"
ok "control: con una huella cambiada en UN caracter, el cotejo la senala"

R "cd ~/$REMOTO-repo && dpkg-scanpackages . /dev/null > Packages 2>/dev/null" \
    || morir "dpkg-scanpackages fallo"
scp -q "${SSH_OPTS[@]}" "$CONSTRUCTOR:~/$REMOTO-repo/Packages" "$TRABAJO/Packages" \
    || morir "no pude traerme el Packages"
HA=$(R "sha256sum ~/$REMOTO-repo/Packages | cut -d' ' -f1")
HB=$(shasum -a 256 "$TRABAJO/Packages" | cut -d' ' -f1)
[ "$HA" = "$HB" ] || morir "el Packages no llego igual
        alli $HA
        aqui $HB"
ok "Packages: $(grep -c '^Filename: ' "$TRABAJO/Packages") entradas, ${HB:0:16}…"

# el indice contra el manifiesto, en las dos direcciones
awk -F'\t' '$1=="PROPIO"||$1=="ARCHIVO"{print $4" "$5" "$6}' "$MANIFIESTO" | LC_ALL=C sort > "$TMP_PROPIO/man"
paste -d' ' <(sed -n 's|^Filename: \./||p' "$TRABAJO/Packages") \
            <(sed -n 's|^Size: ||p'         "$TRABAJO/Packages") \
            <(sed -n 's|^SHA256: ||p'       "$TRABAJO/Packages") | LC_ALL=C sort > "$TMP_PROPIO/idx"
D=$(diff "$TMP_PROPIO/man" "$TMP_PROPIO/idx" | grep -c '^[<>]')
[ "$D" -eq 0 ] || morir "el indice y el manifiesto no dicen lo mismo: $D diferencias
$(diff "$TMP_PROPIO/man" "$TMP_PROPIO/idx" | head -8)"
ok "el indice y el manifiesto dicen lo mismo en las $N_MAN lineas"
awk 'NR==1{$2=$2+1}1' "$TMP_PROPIO/man" > "$TMP_PROPIO/man.sab"
[ "$(diff "$TMP_PROPIO/man.sab" "$TMP_PROPIO/idx" | grep -c '^[<>]')" -eq 2 ] \
    || morir "CONTROL ROTO: con un tamano falseado, la comparacion no lo senala"
ok "control: con un tamano falseado, la comparacion lo senala"

# --- 6. la ISO --------------------------------------------------------------
titulo "6. la ISO"
# el $BISECADO va SIN comillas a proposito: o esta vacio -- y entonces no pone
# ningun argumento, que es el producto -- o son banderas sueltas sin espacios.
"$AQUI/fabricar-iso.sh" --iso "$ISO_OFICIAL" --repo "$TRABAJO" --salida "$SALIDA" $BISECADO \
    | sed 's/^/        /' || morir "fabricar-iso.sh no paso"
[ -f "$SALIDA" ] || morir "no salio la ISO"

echo
echo "commit: $COMMIT"
[ -n "$BISECADO" ] && echo "marca:  MEDIO DE BISECADO, le faltan mecanismos:$BISECADO"
echo "iso:    $SALIDA"
echo "sha256: $(shasum -a 256 "$SALIDA" | cut -d' ' -f1)"
echo "tam:    $(stat -f %z "$SALIDA") bytes"
echo
echo "LO QUE ESTE GUION NO PUEDE DECIR:"
echo "  - que la ISO arranque. Eso se mide en una VM creada desde cero."
echo "  - que sea reproducible. Eso es ESTA MISMA ORDEN OTRA VEZ, a otra salida,"
echo "    y las dos huellas comparadas. Una sola pasada no lo demuestra."
