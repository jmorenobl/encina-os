#!/usr/bin/env bash
# Encina OS - LA RECETA DE «SACAR UNA VERSION», ENTERA Y EJECUTABLE (A3).
#
#     ./imagen/sacar-version.sh --version <X.Y.Z> [--paquetes "p1 p2"] [--cambio "texto"]
#                               [--constructor u@host] [--de-verdad]
#
# QUE ES (A3 de tareas/actualizacion.md, 2026-08-31): hasta hoy «sacar una
# version» estaba repartido entre mk/*.mk, subir-sourceforge.sh, make publicar
# y la regla de ENCINA-OS.md §7, y las partes que los guiones no cubrian eran
# trabajo a mano. Esta es la cadena entera, fase a fase y CRONOMETRADA, porque
# la obligacion de D5 es saber cuanto tarda responder a un fallo de seguridad
# con un medio nuevo:
#
#   0. lo que se comprueba antes de empezar (arbol, version, constructor,
#      clave de SourceForge, gh, la etiqueta vieja SI y la nueva NO)
#   1. dch en la VM constructora (nunca a mano; R: el changelog viaja y vuelve)
#   2. los .deb nuevos y EL RITUAL DE LOS SEIS SITIOS (actualizar-seis-sitios.sh)
#   3. make dos-veces ARQ=arm64 y ARQ=amd64  (la definicion de terminado del medio)
#   4. make medios/SHA256SUMS
#   5. make cosecha ARQ=arm64 y ARQ=amd64    (la receta publica sigue reproduciendo)
#   6. make publicar                          (carpeta nueva, notas sin huellas a mano)
#   7. la subida a SourceForge                (subir-sourceforge.sh)
#   8. la etiqueta                            (gh release create, con las notas y adjuntos)
#   9. el README                              (las huellas de la tabla, desde SHA256SUMS)
#
# SIN --de-verdad ES UN ENSAYO EN SECO, y el ensayo EJECUTA de verdad lo que se
# puede ejecutar sin cambiar el producto: el dch de prueba en un directorio
# tirado de la VM; el ritual de los seis sitios DOS veces en un worktree
# desechable (la pasada idempotente sobre lo vigente, que no puede cambiar un
# byte, y su control con un .deb de bytes cambiados, que tiene que mover
# exactamente cinco ficheros); make -n para lo que construye; preparar-
# publicacion.sh a un directorio tirado comparado con lo publicado; el rsync
# --dry-run de subir-sourceforge.sh contra la carpeta publicada (nada que
# transferir); y las comprobaciones de etiqueta y README. Lo que NO se ejecuta
# en seco se dice con su duracion medida o estimada y su fuente.
#
# --de-verdad ejecuta la cadena real y NO SE HA ESTRENADO NUNCA: lo estrena la
# casilla C4 de tareas/actualizacion.md («A3 se ejecuta aqui de verdad, no en
# seco»), que es tambien donde se mide el punta-a-punta real que D5 pide.
# Requiere --paquetes (que .deb cambian; encina-meta va SIEMPRE, regla de §7)
# y --cambio (el texto del changelog). La subida y la etiqueta son los actos
# irreversibles del proyecto: los ejecuta quien escribe --de-verdad, sabiendolo.
#
# MODELO DE SALIDA: ABORTAR (tarea 2, MEDICIONES.md §4.67): morir() al primer
# problema. Una release a medias no se continua a ciegas.
set -uo pipefail
export LC_ALL=C

AQUI=$(cd "$(dirname "$0")" && pwd)
RAIZ=$(cd "$AQUI/.." && pwd)
VERSION=""; PAQUETES=""; CAMBIO=""; CONSTRUCTOR="jorge@192.168.64.3"; DE_VERDAD=0
uso() { sed -n '2,5p' "$0"; exit 2; }
while [ $# -gt 0 ]; do
    case "$1" in
        --version)     VERSION="$2";     shift 2 ;;
        --paquetes)    PAQUETES="$2";    shift 2 ;;
        --cambio)      CAMBIO="$2";      shift 2 ;;
        --constructor) CONSTRUCTOR="$2"; shift 2 ;;
        --de-verdad)   DE_VERDAD=1;      shift ;;
        -h|--help)     sed -n '1,46p' "$0"; exit 0 ;;
        *) echo "[FALLO] argumento desconocido: $1"; uso ;;
    esac
done
[ -n "$VERSION" ] || uso

. "$RAIZ/lib/salida.sh"
cd "$RAIZ" || morir "no pude entrar en $RAIZ"
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
R() { ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -o LogLevel=ERROR "$CONSTRUCTOR" "$@"; }

# el cronometro: una fila por fase, y la tabla al final (la obligacion de D5)
: > "$TMP/tiempos"
FASE_T0=0
fase_abre()  { FASE_T0=$(date +%s); }
fase_cierra(){ printf '%-46s %5d s\n' "$1" "$(( $(date +%s) - FASE_T0 ))" >> "$TMP/tiempos"; }

MODO="ENSAYO EN SECO"; [ "$DE_VERDAD" = 1 ] && MODO="DE VERDAD"
echo "== sacar-version $VERSION -- $MODO"

# ============================================================================
titulo "0. lo que se comprueba antes de empezar"
fase_abre

SUCIO=$(git status --porcelain | wc -l | tr -d ' ')
[ "$SUCIO" = 0 ] || morir "el arbol esta sucio ($SUCIO ficheros): una release sale de un commit, no de un directorio"
ok "el arbol esta limpio ($(git rev-parse --short HEAD))"

VIGENTE=$(awk -F'\t' '$1=="PROPIO" && $2=="encina-meta" {print $3}' "$AQUI/repo-manifiesto.tsv")
[ -n "$VIGENTE" ] || morir "no leo la version vigente del manifiesto"
case "$VERSION" in
    *[!0-9.]*|.*|*.) morir "la version «$VERSION» no tiene la forma X.Y.Z" ;;
esac
MAYOR=$(printf '%s\n%s\n' "$VIGENTE" "$VERSION" | sort -V | tail -1)
{ [ "$MAYOR" = "$VERSION" ] && [ "$VERSION" != "$VIGENTE" ]; } \
    || morir "la version pedida ($VERSION) no es mayor que la vigente ($VIGENTE)"
ok "version: $VIGENTE (vigente, del manifiesto) -> $VERSION (pedida)"

R true 2>/dev/null || morir "el constructor $CONSTRUCTOR no contesta por ssh"
R "command -v dch >/dev/null" || morir "al constructor le falta dch (devscripts)"
ok "el constructor contesta y tiene dch: $(R 'echo "$(lsb_release -ds 2>/dev/null)  $(dpkg --print-architecture)"')"

[ -f "$HOME/.ssh/sourceforge-encina" ] || morir "no esta la clave de SourceForge: ~/.ssh/sourceforge-encina"
ok "la clave de SourceForge esta"
command -v gh >/dev/null || morir "no esta gh (la etiqueta es 'gh release create')"
gh auth status >/dev/null 2>&1 || morir "gh no esta autenticado (gh auth status)"
ok "gh esta y autenticado"

# la pareja de controles de la etiqueta: la vigente SI existe (el instrumento
# ve etiquetas) y la nueva NO (nada publicado se pisa)
gh release view "v$VIGENTE" >/dev/null 2>&1 \
    || morir "control roto: la release v$VIGENTE tendria que existir y gh no la ve"
ok "control: la release v$VIGENTE existe (el instrumento ve etiquetas)"
if gh release view "v$VERSION" >/dev/null 2>&1; then
    morir "la release v$VERSION YA existe: nada publicado cambia (regla de §7)"
fi
ok "v$VERSION no existe todavia: la carpeta y la etiqueta seran nuevas"

for f in medios/ubuntu-24.04.4-desktop-arm64.iso medios/ubuntu-24.04.4-desktop-amd64.iso \
         medios/encina-repo-arm64.tar medios/encina-repo-amd64.tar; do
    [ -f "$f" ] || morir "falta $f (la base o la cosecha; ./imagen/traer-iso-oficial.sh / make cosecha)"
done
ok "las dos bases oficiales y las dos cosechas estan en medios/"
if [ "$DE_VERDAD" = 1 ]; then
    [ -n "$PAQUETES" ] || morir "--de-verdad exige --paquetes (que .deb cambian; encina-meta va solo)"
    [ -n "$CAMBIO" ]   || morir "--de-verdad exige --cambio (el texto del changelog; dch no escribe frases vacias)"
fi
fase_cierra "0 comprobaciones previas"

# ============================================================================
titulo "1. dch en la VM constructora (nunca a mano)"
fase_abre

dch_en_vm() {  # $1 paquete  $2 texto ; deja el changelog nuevo en el arbol
    local p="$1" texto="$2" REM="dch-$$-$1"
    R "rm -rf ~/$REM && mkdir -p ~/$REM/debian"
    scp -q -o StrictHostKeyChecking=no -o LogLevel=ERROR \
        "debian-packages/$p/debian/changelog" "$CONSTRUCTOR:~/$REM/debian/changelog"
    R "cd ~/$REM && export DEBFULLNAME='Jorge MB' DEBEMAIL='jmorenobl@gmail.com' && \
       dch -v '$VERSION' -D noble --force-distribution '$texto'"
    R "head -1 ~/$REM/debian/changelog" | grep -q "($VERSION)" \
        || morir "el changelog de $p no quedo en $VERSION tras dch"
    scp -q -o StrictHostKeyChecking=no -o LogLevel=ERROR \
        "$CONSTRUCTOR:~/$REM/debian/changelog" "debian-packages/$p/debian/changelog"
    R "rm -rf ~/$REM"
}

if [ "$DE_VERDAD" = 1 ]; then
    for p in $PAQUETES; do
        [ -d "debian-packages/$p" ] || morir "no existe debian-packages/$p"
        dch_en_vm "$p" "$CAMBIO"
        ok "dch $VERSION en $p, traido y releido"
    done
    case " $PAQUETES " in *" encina-meta "*) : ;; *)
        dch_en_vm encina-meta "Version $VERSION del medio: encina-meta sube con el (un medio nuevo es una encina-meta nueva, ENCINA-OS.md §7)."
        ok "dch $VERSION en encina-meta (va siempre: la regla de §7)" ;;
    esac
    git add debian-packages/*/debian/changelog
    git commit -q -m "dch $VERSION: los changelogs, escritos con dch en $CONSTRUCTOR (sacar-version.sh, fase 1)"
    ok "changelogs confirmados: $(git rev-parse --short HEAD)"
else
    REM="dch-ensayo-$$"
    R "rm -rf ~/$REM && mkdir -p ~/$REM/debian"
    scp -q -o StrictHostKeyChecking=no -o LogLevel=ERROR \
        debian-packages/encina-meta/debian/changelog "$CONSTRUCTOR:~/$REM/debian/changelog"
    R "cd ~/$REM && export DEBFULLNAME='Jorge MB' DEBEMAIL='jmorenobl@gmail.com' && \
       dch -v '$VERSION' -D noble --force-distribution 'Ensayo en seco de sacar-version.sh: esta linea no toca el arbol.'"
    R "head -1 ~/$REM/debian/changelog" | grep -q "($VERSION)" \
        || morir "el dch de ensayo no dejo el changelog en $VERSION"
    R "rm -rf ~/$REM"
    ok "[ENSAYO] dch -v $VERSION probado en un directorio tirado de la VM; el arbol no se toca"
fi
fase_cierra "1 dch en la VM"

# ============================================================================
titulo "2. los .deb nuevos y el ritual de los seis sitios"
fase_abre

if [ "$DE_VERDAD" = 1 ]; then
    # los tres .deb desde 'git archive HEAD' en el constructor (§4.37: nunca
    # el arbol de trabajo), como los construye la CI
    REM="debs-$$"
    R "rm -rf ~/$REM && mkdir -p ~/$REM"
    git archive HEAD | R "cd ~/$REM && tar -xf -"
    for g in construir-branding.sh construir-firefox.sh construir-meta.sh; do
        R "cd ~/$REM && chmod +x scripts/*.sh && ENCINA_REPO=\$HOME/$REM ./scripts/$g" >"$TMP/build.log" 2>&1 \
            || morir "$g fallo en el constructor:
$(tail -10 "$TMP/build.log")"
    done
    mkdir -p "$TMP/debs"
    scp -q -o StrictHostKeyChecking=no -o LogLevel=ERROR \
        "$CONSTRUCTOR:~/$REM/debian-packages/*.deb" "$TMP/debs/"
    R "rm -rf ~/$REM"
    ok "los tres .deb construidos desde git archive HEAD: $(ls "$TMP/debs" | tr '\n' ' ')"
    # el repo futuro: la cosecha vigente con los PROPIO nuevos dentro
    cp -R medios/cosecha-arm64 "$TMP/repo-futuro"
    for p in encina-branding encina-firefox-native encina-meta; do
        rm -f "$TMP/repo-futuro/${p}"_*.deb
        cp "$TMP/debs/${p}"_*.deb "$TMP/repo-futuro/"
    done
    "$AQUI/actualizar-seis-sitios.sh" --repo "$TMP/repo-futuro" --constructor "$CONSTRUCTOR" \
        || morir "el ritual de los seis sitios fallo"
    git add imagen/repo-manifiesto.tsv imagen/repo-manifiesto-amd64.tsv \
            imagen/encina-seed.sh imagen/autoinstall.yaml imagen/autoinstall-unattended.yaml
    git commit -q -m "Version $VERSION: el ritual de los seis sitios (§4.48f), ejecutado por actualizar-seis-sitios.sh"
    ok "los seis sitios confirmados: $(git rev-parse --short HEAD)"
else
    # EL ENSAYO DEL RITUAL, con su pareja de respuestas, en un worktree tirado:
    # 1) idempotente sobre lo vigente (ni un byte), 2) con un .deb de bytes
    # cambiados mueve EXACTAMENTE los cinco ficheros que llevan su huella
    git worktree add -q "$TMP/wt" HEAD || morir "no pude abrir el worktree del ensayo"
    [ -x "$TMP/wt/imagen/actualizar-seis-sitios.sh" ] \
        || morir "HEAD no lleva actualizar-seis-sitios.sh: confirma antes de ensayar"
    "$TMP/wt/imagen/actualizar-seis-sitios.sh" --repo medios/cosecha-arm64 >"$TMP/rito1.log" 2>&1 \
        || morir "el ritual fallo sobre lo vigente:
$(tail -8 "$TMP/rito1.log")"
    git -C "$TMP/wt" diff --quiet \
        || morir "el ritual NO fue idempotente sobre lo vigente:
$(git -C "$TMP/wt" diff --stat)"
    ok "[ENSAYO] ritual sobre lo vigente: idempotente, ni un byte (11 comprobaciones dentro)"
    cp -R medios/cosecha-arm64 "$TMP/repo-sab"
    printf '\0' >> "$TMP/repo-sab/encina-meta_${VIGENTE}_all.deb"
    "$TMP/wt/imagen/actualizar-seis-sitios.sh" --repo "$TMP/repo-sab" --constructor "$CONSTRUCTOR" \
        >"$TMP/rito2.log" 2>&1 || morir "el ritual fallo con el .deb saboteado:
$(tail -8 "$TMP/rito2.log")"
    N_CAMBIADOS=$(git -C "$TMP/wt" diff --name-only | wc -l | tr -d ' ')
    [ "$N_CAMBIADOS" = 5 ] || morir "control roto: el .deb saboteado cambio $N_CAMBIADOS ficheros y tenian que ser 5:
$(git -C "$TMP/wt" diff --stat)"
    ok "control: un .deb de bytes cambiados mueve exactamente 5 ficheros (2 manifiestos, encina-seed.sh, 2 YAML)"
    git worktree remove --force "$TMP/wt"
fi
fase_cierra "2 seis sitios (+ .deb en de-verdad)"

# ============================================================================
titulo "3-5. el medio dos veces, las sumas y la cosecha, por arquitectura"
fase_abre

if [ "$DE_VERDAD" = 1 ]; then
    for a in arm64 amd64; do
        make dos-veces ARQ=$a           || morir "make dos-veces ARQ=$a fallo"
    done
    make medios/SHA256SUMS              || morir "make medios/SHA256SUMS fallo"
    for a in arm64 amd64; do
        make cosecha ARQ=$a             || morir "make cosecha ARQ=$a fallo"
    done
    ok "los dos medios reproducidos dos veces, sus sumas y sus cosechas"
else
    for objetivo in "dos-veces ARQ=arm64" "dos-veces ARQ=amd64" "medios/SHA256SUMS" \
                    "cosecha ARQ=arm64" "cosecha ARQ=amd64"; do
        # shellcheck disable=SC2086
        make -n $objetivo >"$TMP/make-n.log" 2>&1 || morir "make -n $objetivo no resuelve:
$(tail -5 "$TMP/make-n.log")"
        ok "[ENSAYO] make $objetivo resuelve (make -n, sin ejecutar)"
    done
    echo "         duracion real: no se ejecuta en seco; el punta-a-punta lo mide C4."
    echo "         Referencias medidas: la reproduccion desde cosecha publicada, minutos"
    echo "         por arquitectura (§4.82); la subida de 10,9 GB, ~20 min (§4.82j)."
fi
fase_cierra "3-5 medios, sumas y cosechas"

# ============================================================================
titulo "6. make publicar: la carpeta nueva, sin una huella escrita a mano"
fase_abre

if [ "$DE_VERDAD" = 1 ]; then
    make publicar || morir "make publicar fallo"
    [ -d "medios/publicar/$VERSION" ] || morir "make publicar no dejo medios/publicar/$VERSION"
    ok "medios/publicar/$VERSION preparado"
else
    "$AQUI/preparar-publicacion.sh" --medios medios --salida "$TMP/publicar-ensayo" \
        --url-base "https://downloads.sourceforge.net/project/encina-os/$VIGENTE" \
        >"$TMP/publicar.log" 2>&1 \
        || morir "preparar-publicacion.sh fallo en el ensayo:
$(tail -8 "$TMP/publicar.log")"
    if [ -f "medios/publicar/$VIGENTE/SHA256SUMS" ]; then
        cmp -s "$TMP/publicar-ensayo/SHA256SUMS" "medios/publicar/$VIGENTE/SHA256SUMS" \
            || morir "el SHA256SUMS del ensayo NO es el publicado de $VIGENTE:
$(diff "$TMP/publicar-ensayo/SHA256SUMS" "medios/publicar/$VIGENTE/SHA256SUMS" || true)"
        ok "[ENSAYO] preparar-publicacion.sh reproduce byte a byte el SHA256SUMS publicado de $VIGENTE"
    else
        ok "[ENSAYO] preparar-publicacion.sh corre entero (no hay medios/publicar/$VIGENTE con que comparar)"
    fi
fi
fase_cierra "6 make publicar"

# ============================================================================
titulo "7. la subida a SourceForge"
fase_abre

if [ "$DE_VERDAD" = 1 ]; then
    "$AQUI/subir-sourceforge.sh" --directorio "medios/publicar/$VERSION" --de-verdad \
        || morir "la subida fallo"
    ok "subido a SourceForge y cotejado de vuelta (subir-sourceforge.sh)"
else
    if [ -d "medios/publicar/$VIGENTE" ]; then
        "$AQUI/subir-sourceforge.sh" --directorio "medios/publicar/$VIGENTE" >"$TMP/subida.log" 2>&1 \
            || morir "el rsync --dry-run contra lo publicado fallo:
$(tail -8 "$TMP/subida.log")"
        ok "[ENSAYO] subir-sourceforge.sh en seco contra la carpeta publicada de $VIGENTE (su propio --dry-run)"
    else
        omitido "no hay medios/publicar/$VIGENTE: el ensayo de la subida no tiene carpeta que ensayar"
    fi
fi
fase_cierra "7 subida"

# ============================================================================
titulo "8. la etiqueta"
fase_abre

if [ "$DE_VERDAD" = 1 ]; then
    git push origin main || morir "git push fallo (la etiqueta necesita el commit publicado)"
    ( cd "medios/publicar/$VERSION" && \
      gh release create "v$VERSION" --title "Encina OS $VERSION" --notes-file NOTAS.md \
          SHA256SUMS ./*.torrent encina-repo-arm64.tar encina-repo-amd64.tar ) \
        || morir "gh release create fallo"
    gh release view "v$VERSION" >/dev/null 2>&1 || morir "la release v$VERSION no aparece tras crearla"
    ok "release v$VERSION creada y releida"
else
    echo "   [ENSAYO] la orden real (v$VERSION no existe: comprobado en la fase 0):"
    echo "     cd medios/publicar/$VERSION && gh release create v$VERSION \\"
    echo "        --title 'Encina OS $VERSION' --notes-file NOTAS.md \\"
    echo "        SHA256SUMS *.torrent encina-repo-arm64.tar encina-repo-amd64.tar"
    ok "[ENSAYO] etiqueta: la pareja de controles ya paso en la fase 0 (v$VIGENTE si, v$VERSION no)"
fi
fase_cierra "8 etiqueta"

# ============================================================================
titulo "9. el README: las huellas de la tabla, desde SHA256SUMS"
fase_abre

# EL README PROMETE LAS HUELLAS DE LAS DOS ISOs (su tabla de descargas), no las
# de tars ni torrents: la fase se cine a eso, medido el 2026-08-31 con grep.
if [ "$DE_VERDAD" = 1 ]; then
    python3 - "medios/publicar/$VERSION/SHA256SUMS" README.md <<'PY' || morir "el README no se pudo reescribir"
import re, sys
sumas, readme = sys.argv[1], sys.argv[2]
h = {l.split()[1]: l.split()[0] for l in open(sumas)
     if l.strip() and l.split()[1].endswith('.iso')}   # fichero -> huella, solo ISOs
t = open(readme).read(); n = 0
for fichero, huella in h.items():
    # en la fila de la tabla que nombra el fichero, la huella vieja (64 hex) pasa a la nueva
    patron = re.compile(r'(%s.*?)\b[0-9a-f]{64}\b' % re.escape(fichero))
    t, k = patron.subn(lambda m: m.group(1) + huella, t)
    n += k
open(readme, 'w').write(t)
print("filas con huella reescrita:", n)
if n < len(h):
    sys.exit("[FALLO] el README nombra %d de las %d ISOs de SHA256SUMS" % (n, len(h)))
PY
    # trampa 13: releer — la huella de cada ISO tiene que estar en el README
    while read -r H F; do
        case "$F" in *.iso) grep -q "$H" README.md || morir "la huella de $F no quedo en el README" ;; esac
    done < "medios/publicar/$VERSION/SHA256SUMS"
    git add README.md && git commit -q -m "README: las huellas de $VERSION, sustituidas desde SHA256SUMS (sacar-version.sh, fase 9)"
    git push origin main || morir "git push del README fallo"
    ok "README reescrito desde SHA256SUMS, releido, confirmado y publicado"
else
    FALTAN=0
    while read -r H F; do
        case "$F" in *.iso)
            grep -q "$H" README.md || { echo "   [ENSAYO] la huella de $F no esta en el README"; FALTAN=1; } ;;
        esac
    done < "medios/publicar/$VIGENTE/SHA256SUMS"
    [ "$FALTAN" = 0 ] || morir "el README no lleva las huellas de las ISOs publicadas de $VIGENTE: la fase 9 no tiene ancla"
    ok "[ENSAYO] el README lleva las huellas de las dos ISOs publicadas de $VIGENTE: la sustitucion tiene ancla"
fi
fase_cierra "9 README"

# ============================================================================
titulo "el cronometro, fase a fase (la obligacion de D5)"
sed 's/^/   /' "$TMP/tiempos"
if [ "$DE_VERDAD" = 1 ]; then
    echo "   TOTAL punta a punta: $(awk '{s+=$(NF-1)} END {print s}' "$TMP/tiempos") s -- apuntalo en la medicion de la casilla que lo ejecuto"
else
    echo "   (tiempos del ENSAYO; el punta-a-punta real es de C4, que estrena --de-verdad)"
fi

resumen
