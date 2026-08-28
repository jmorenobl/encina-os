#!/usr/bin/env bash
# Encina OS - BANCO DE LAS REFERENCIAS: que nada apunte a la nada.
#
#     ./bancos/enlaces.sh [--raiz D] [--solo-control] [--solo-medicion]
#
# QUE COMPRUEBA, y son tres espacios distintos que se cuentan por separado:
#
#   (A) las referencias «§N.NN» -- que la seccion citada EXISTA;
#   (B) las rutas de guion citadas entre acentos graves -- que el fichero este
#       en el disco;
#   (C) los enlaces relativos de los .md -- que el destino exista.
#
# POR QUE EXISTE. Las tareas 4 y 9 de tareas/refactorizacion.md parten
# MEDICIONES.md en un fichero por seccion y mueven las trampas a TRAMPAS.md; la
# 10 renombra los guiones. UNA REFERENCIA MUERTA NO SE MANIFIESTA HASTA QUE
# ALGUIEN LA SIGUE, meses despues, y para entonces ya no se sabe si el destino
# se movio, se borro o nunca existio. Este guion es el instrumento con el que se
# mide ese movimiento, y por eso va ANTES que el movimiento -- igual que
# veredicto-pantalla.py fue antes que contar arranques.
#
# EL CONTROL VA DELANTE DE LA MEDICION, no detras, y no es adorno: un
# comprobador de referencias que no encuentre nada da EXACTAMENTE la misma
# salida que un arbol sano. Es la leccion del 2026-08-17 -- un banco cuyo
# binario no existia leyo «command not found» como PASA y dio cuatro verdes
# falsos --. Aqui el control fabrica un arbol de mentira en /tmp con SEIS casos:
# tres que TIENEN que salir rojos (una referencia inventada §4.999, un guion
# citado que no esta, un enlace relativo roto) y tres que TIENEN que salir
# verdes (una referencia buena, un guion que si esta, un enlace que si resuelve).
# Si el control no da sus dos respuestas, el guion se para y NO mide nada: una
# medicion con el instrumento sin verificar no vale.
#
# ---------------------------------------------------------------------------
# LAS SIETE TRAMPAS DE ESTE ESPACIO. Las cuatro primeras se midieron el
# 2026-08-23 ANTES de escribir una linea, porque sin ellas el guion nace
# mintiendo. Las tres ultimas salieron AL USARLO. Estan en MEDICIONES.md §4.66(d).
#
# (1) EL ESPACIO DE ANCLAS TIENE CUATRO CONVENCIONES, NO UNA.
#     «§4.37c» NO apunta a ninguna seccion «### 4.37c» -- no existe -- sino a un
#     «#### (c)» DENTRO de «### 4.37». Y hay una segunda forma para lo mismo,
#     «**c) ...», con 62 apariciones frente a 451. Y una tercera, «### 9.a» en
#     ENCINA-OS.md, con letra en el segundo nivel. Un comprobador que solo mire
#     «###» pinta 204 falsos [FALLO] de 305; con «#### (x)», 34; con las cuatro,
#     ninguno.
#
# (2) EL SIGILO «§» NO SIEMPRE SIGNIFICA «SECCION DE UN DOCUMENTO».
#     La tabla «Paso del seed» de MEDICIONES.md numera con «§» los pasos de
#     imagen/encina-seed.sh: «§7 ¿hay red desde el chroot?», «§11 full-upgrade».
#     Seis filas. Cuatro de ellas resuelven POR CASUALIDAD contra secciones que
#     existen y dos no, asi que sin excluir la tabla entera el guion daria dos
#     [FALLO] falsos Y cuatro [OK] falsos -- que es peor. Se excluye por
#     contexto, no por numero de linea: los numeros de linea se mueven.
#
# (3) EL MISMO «§N.N» EXISTE EN DOS DOCUMENTOS. «§4.1» esta en MEDICIONES.md y
#     en AGENTS.md; «§6.1» en AGENTS.md y en ENCINA-OS.md. Asi que la
#     comprobacion es de DOS niveles y se cuenta por separado:
#       - referencia CUALIFICADA (el documento va pegado delante: «`AGENTS.md`
#         §6.8») -> se resuelve contra ESE documento. Es la comprobacion fuerte,
#         y es la que caza que AGENTS.md no tiene ninguna §6.8.
#       - referencia DESNUDA («§4.65» a secas) -> se resuelve contra la UNION de
#         los tres indices. Es la debil, y se dice que lo es: aqui un [OK]
#         significa «existe en algun sitio», no «existe donde se pretendia».
#     Lo que NO se hace es adivinar el documento por el fichero que cita: seria
#     deducir, y este repositorio separa lo medido de lo deducido.
#
# (4) NO TODO GUION CITADO ES DE ESTE REPOSITORIO. Las mediciones citan por su
#     nombre ficheros de subiquity (`refresh.py`), de apt (`apt.py`) y del
#     repositorio hermano ~/Projects/encina-autofirma
#     (`sincronizar-ca-mozilla.sh`). Por eso solo son [FALLO] las rutas que
#     empiezan por un directorio DE ESTE arbol; un nombre suelto que no aparece
#     sale [AVISO] y se lista, porque no se puede saber de quien es sin mirarlo.
#
# (5) UNA REFERENCIA TACHADA NO ES UNA REFERENCIA. El metodo de este repositorio
#     es corregir DEJANDO AL LADO lo que se creia, y la forma de dejarlo al lado
#     es «~~§7.7~~ §4.25». Un comprobador que no lo sepa castiga justo la
#     practica que existe para protegerlo, y entonces la unica manera de ponerlo
#     verde es BORRAR la historia. Se cazo al enmendar las dos §7.7 de hoy: las
#     dos siguieron saliendo rojas.
#
# (6) UN § DENTRO DE UN BLOQUE DE CODIGO O ENTRE ACENTOS GRAVES ES UNA CITA, no
#     un puntero. Sin esto, MEDICIONES.md §4.66 -- que pega la salida de este
#     guion, con su §4.998 de saboteo dentro -- SE DENUNCIA A SI MISMA, y con
#     ella cualquier documento que hable de referencias. Son 110 hoy, y se
#     CUENTAN en la linea de cabecera en vez de desaparecer: un instrumento que
#     tapa lo que no mira miente por omision.
#
# (7) ESTE GUION NO SE COMPRUEBA A SI MISMO, y esta declarado aqui porque es un
#     punto ciego de verdad. Sus «§4.998», «§4.1b» y «scripts/no-existe.sh» son
#     LOS NEGATIVOS DE SU PROPIO CONTROL, y sus «§6.5», «§6.8» y «§7.7» son la
#     lista de rotas declaradas escrita en prosa: al versionarlo se denuncio a si
#     mismo con QUINCE [FALLO] y ninguno cierto. Un instrumento no es un
#     documento -- sus tokens son su vocabulario, no punteros --. El precio, sin
#     maquillar: una referencia rota escrita DENTRO de este fichero no la caza
#     nadie.
#
# ---------------------------------------------------------------------------
# LA POLITICA DE EXCLUSION, con su motivo cada una. Sin ella el primer dia
# salen siete [FALLO] y NINGUNO ES CIERTO. Se declara aqui y no en un fichero
# aparte para que se lea al mismo tiempo que el guion.
#
#   (bancos/vigencia.sh estuvo aqui hasta que la tarea 5 lo creo, el 2026-08-28)
#   (lib/salida.sh y lib/vm.sh estuvieron aqui hasta que la tarea 3 los creo, el 2026-08-28: el guion aviso de que sobraban, que es para lo que existe el aviso)
#   scripts/00-entorno.sh … scripts/12-meta-verificar.sh   los TRECE nombres de antes de
#                             la tarea 10 (2026-08-28): los registros los conservan a
#                             proposito y SCRIPTS.md lleva la tabla de equivalencias.
#   scripts/construir-deb.sh  el nombre que la tarea 10 PROPONIA y tres documentos
#                             citan como propuesta; al final la convencion fue
#                             verbo-paquete (construir-branding.sh) y este no existe
#   imagen/autoinstall-e3.yaml   nombre historico conservado a proposito;
#   imagen/verificar-e2.sh       SCRIPTS.md los documenta en su tabla de
#                                equivalencias, asi que borrarlos seria perder
#                                el puente con las mediciones que los citan
#
# CADA VEZ QUE UNA DE ESTAS SEIS APAREZCA EN EL DISCO, SE CAE SOLA DE LA LISTA:
# el guion avisa de las exclusiones que ya no hacen falta, que es como una lista
# de excepciones deja de pudrirse.

# MODELO DE SALIDA: CONTAR Y SEGUIR (tarea 2, MEDICIONES.md §4.67). fallo()
# apunta y SIGUE midiendo; morir() aborta; el código de salida lo fija el
# resumen del final. Declarado aquí para no tener que deducirlo leyendo.
set -uo pipefail
export LC_ALL=C

AQUI=$(cd "$(dirname "$0")" && pwd)
RAIZ=$(cd "$AQUI/.." && pwd)
HACER_CONTROL=1
HACER_MEDICION=1

while [ $# -gt 0 ]; do
    case "$1" in
        --raiz)          RAIZ=$(cd "$2" && pwd); shift 2 ;;
        --solo-control)  HACER_MEDICION=0; shift ;;
        --solo-medicion) HACER_CONTROL=0;  shift ;;
        -h|--help)       sed -n '1,10p' "$0"; exit 0 ;;
        *) echo "[FALLO] argumento desconocido: $1"; exit 2 ;;
    esac
done

# EL VOCABULARIO VIENE DE lib/salida.sh (tarea 3): ok/fallo/aviso/omitido, los
# contadores N_OK/N_MAL/N_AVI/N_OMI y morir(). Este guion ya no define ninguno.
. "$AQUI/../lib/salida.sh"

TMP=$(mktemp -d "${TMPDIR:-/tmp}/enlaces.XXXXXX") || exit 2
trap 'rm -rf "$TMP"' EXIT

# ---------------------------------------------------------------- el indice --
#
# Escribe «documento<TAB>ancla» por cada ancla alcanzable con un «§». Las cuatro
# convenciones de la trampa (1) estan aqui y en ningun otro sitio.
cat > "$TMP/anclas.awk" <<'AWK'
BEGIN { OFS="\t" }
# EL DOCUMENTO SE LLAMA POR SU NOMBRE DE SIEMPRE: desde la tarea 4 (2026-08-28)
# MEDICIONES.md esta partido en mediciones/*.md, un fichero por seccion, y las
# citas siguen siendo «MEDICIONES.md §4.37». Asi que todo lo que viva bajo
# mediciones/ indexa como MEDICIONES.md, y el MEDICIONES.md de la raiz -- que
# ya es solo el puntero -- tambien.
FNR==1 { doc=FILENAME; if (doc ~ /(^|\/)mediciones\/[^\/]*$/) doc="MEDICIONES.md"; else sub(/^.*\//,"",doc); sub2="" }
# «# 4.37 ...», «# 9. ...», «# 4. ...»: la seccion que es UN FICHERO de mediciones/
# (su titulo bajo de ### a # al partir; los #### (x) de dentro siguen igual)
/^# +[0-9]+[a-z]*\.[0-9a-z]+ /  { sub2=$2; sub(/\.$/,"",sub2); print doc, sub2; next }
/^# +[0-9]+[a-z]*\. /           { s=$2; sub(/\.$/,"",s); print doc, s; sub2=""; next }
# «## 4. Estado del arte»  y  «## 6bis. La entrega»
/^## +[0-9]+[a-z]*\./          { s=$2; sub(/\.$/,"",s); print doc, s; sub2=""; next }
# «### 4.37 ...», «### 6bis.1 ...», «### 9.a ...»
/^### +[0-9]+[a-z]*\.[0-9a-z]+/ { sub2=$2; sub(/\.$/,"",sub2); print doc, sub2; next }
# «#### (c)» dentro de la «### 4.37» de arriba  ->  4.37c
/^#### +\([a-z]\)/             { if (sub2 != "") { l=$2; gsub(/[()]/,"",l); print doc, sub2 l } next }
# «**c) ...» dentro de la misma  ->  4.37c   (la segunda forma, 62 de 513)
/^\*\*[a-z]\)/                 { if (sub2 != "") print doc, sub2 substr($0,3,1); next }
AWK

# ------------------------------------------------------------- el escaneo ----
#
# Un solo recorrido por fichero y por linea, que emite hallazgos en
# «TIPO<TAB>fichero<TAB>linea<TAB>referencia<TAB>detalle». Quien decide si un
# hallazgo es [OK], [FALLO] o [AVISO] es el bash de abajo; este awk solo mira.
cat > "$TMP/escanear.awk" <<'AWK'
BEGIN { OFS="\t" }

# --- indice de anclas: primera entrada, «documento<TAB>ancla» -----------------
FILENAME == IDX { ancla[$1 SUBSEP $2]=1; union[$2]=1; next }

FNR==1 { rel=FILENAME; sub("^" RAIZ "/","",rel); dir=rel; if (!sub(/\/[^\/]*$/,"",dir)) dir="." ; tabla_seed=0; valla=0 }

{
    linea=$0

    # --- trampa (6a): un § dentro de un BLOQUE de codigo es una CITA ---------
    # Lo que hay entre ``` es salida literal o una orden, no un puntero que
    # nadie vaya a seguir. Sin esto, esta misma seccion -- §4.66, que pega la
    # salida del guion con un §4.998 dentro -- se denuncia a si misma.
    # El «[ \t>]*» no es adorno: ENCINA-OS.md §7 mete sus bloques DENTRO de una
    # cita de bloque, o sea con «> ```» delante.
    if (linea ~ /^[ \t>]*```/) { valla = !valla; next }
    if (valla) {
        aux=linea
        while (match(aux, /§[0-9]+(bis|ter|quater)?(\.[0-9]+[a-z]?)*/)) {
            print "CITA", rel, FNR, "§" substr(aux,RSTART+2,RLENGTH-2), "(bloque de codigo)"
            aux = substr(aux, RSTART+RLENGTH)
        }
        next
    }

    # --- trampa (2): la tabla que numera con § los PASOS del seed ------------
    if (linea ~ /^\| *Paso del seed/) tabla_seed=1
    else if (tabla_seed && linea !~ /^\|/) tabla_seed=0

    # --- trampa (6b): los tramos entre acentos graves, para lo mismo ---------
    # Se marcan los OFFSETS, no se borra el texto: el documento de una
    # referencia cualificada vive DENTRO del span -- «`AGENTS.md` §6.8» -- y
    # borrarlo destruiria justo la comprobacion fuerte.
    nsp=0; aux=linea; base=0
    while (match(aux, /`[^`]*`/)) {
        nsp++; sp_a[nsp]=base+RSTART; sp_b[nsp]=base+RSTART+RLENGTH-1
        base += RSTART+RLENGTH-1; aux = substr(aux, RSTART+RLENGTH)
    }

    # --- (A) referencias § --------------------------------------------------
    resto=linea; off=0
    while (match(resto, /§[0-9]+(bis|ter|quater)?(\.[0-9]+[a-z]?)*/)) {
        ref = substr(resto, RSTART+2, RLENGTH-2)    # el § son DOS bytes en UTF-8
        antes = substr(resto, 1, RSTART-1)
        abs = off + RSTART
        off += RSTART+RLENGTH-1
        resto = substr(resto, RSTART+RLENGTH)

        dentro=0
        for (k=1; k<=nsp; k++) if (abs > sp_a[k] && abs < sp_b[k]) { dentro=1; break }
        if (dentro) { print "CITA", rel, FNR, "§" ref, "(entre acentos graves)"; continue }

        if (tabla_seed && antes ~ /\| *$/) { print "SEED", rel, FNR, "§" ref, "paso del seed, no seccion"; continue }

        # --- trampa (5): UNA REFERENCIA TACHADA NO ES UNA REFERENCIA ---------
        # El metodo de este repositorio es corregir DEJANDO AL LADO lo que se
        # creia, y la forma de dejarlo al lado es «~~§7.7~~ §4.25». Un
        # comprobador que no lo sepa hace lo peor que puede hacer un
        # instrumento: castiga justo la practica que existe para protegerlo, y
        # entonces la unica manera de ponerlo verde es BORRAR la historia.
        if (antes ~ /~~$/ && resto ~ /^~~/) { print "TACHADA", rel, FNR, "§" ref, ""; continue }

        # cualificada: el documento pegado delante, con un acento grave y un
        # espacio como mucho. Mas ventana que eso y se cuela la frase anterior:
        # «... en `ENCINA-OS.md`. §4.12a ...» son DOS frases y §4.12a es de
        # MEDICIONES.md (DIARIO.md:16, medido).
        if (match(antes, /(MEDICIONES|AGENTS|ENCINA-OS)\.md`? ?$/)) {
            q = substr(antes, RSTART, RLENGTH); sub(/`? ?$/,"",q)
            if ((q SUBSEP ref) in ancla) print "REFQ_OK",  rel, FNR, "§" ref, q
            else                         print "REFQ_MAL", rel, FNR, "§" ref, q
        } else {
            if (ref in union) print "REFD_OK",  rel, FNR, "§" ref, ""
            else              print "REFD_MAL", rel, FNR, "§" ref, ""
        }
    }

    # --- (B) rutas de guion citadas entre acentos graves ---------------------
    resto=linea
    while (match(resto, /`[A-Za-z0-9_.\/-]+\.(sh|py|m|yaml)`/)) {
        p = substr(resto, RSTART+1, RLENGTH-2)
        resto = substr(resto, RSTART+RLENGTH)
        # medios/ NO esta en la lista a proposito: es .gitignore salvo su LEEME,
        # asi que una ruta «medios/verificar-instalacion.sh» existe en el Mac de
        # Jorge y NO en un clon limpio. La CI simulada en ubuntu:24.04 (tarea 6,
        # 2026-08-28) dio cinco [FALLO] por eso y ninguno era cierto: lo que
        # vive en medios/ no se puede comprobar desde el arbol versionado.
        if (p ~ /^(scripts|imagen|bancos|lib|design|tareas|debian-packages|\.github)\//)
            print "GUION", rel, FNR, p, "ruta"
        else if (p ~ /^medios\//)
            print "MEDIOS", rel, FNR, p, "no versionado"
        else if (p !~ /\//)
            print "GUION", rel, FNR, p, "nombre"
    }

    # --- (C) enlaces relativos de markdown ----------------------------------
    if (rel ~ /\.md$/) {
        resto=linea
        # el destino NO puede llevar espacios, y el «](» va pegado. Sin las dos
        # cosas se cuelan nueve salidas literales de apt como si fueran enlaces:
        # «Inst firefox [1:1snap1-0ubuntu5] (153.0.3~build1 .../mozilla...)»
        # (AGENTS.md:850 y ocho mas, medido el 2026-08-23).
        while (match(resto, /\]\([^) \t]+\)/)) {
            d = substr(resto, RSTART, RLENGTH)
            resto = substr(resto, RSTART+RLENGTH)
            sub(/^\]\(/,"",d); sub(/\)$/,"",d)
            if (d ~ /^(https?|mailto|ftp):/ || d ~ /^#/ || d == "") continue
            sub(/#.*$/,"",d); if (d == "") continue
            print "ENLACE", rel, FNR, d, dir
        }
    }
}
AWK

# escanear <raiz> -> escribe TMP/hallazgos.tsv
escanear() {
    local raiz="$1" lista="$TMP/lista.txt"
    ( cd "$raiz" && \
      # git ls-files y no find: lo que no esta versionado no se comprueba, y asi
      # medios/verificar-instalacion.sh -- la copia que .gitignore tapa -- no
      # cuenta dos veces. /usr/bin/git y no git: el hook de rtk filtra la salida
      # (MEDICIONES.md §4.9d).
      if /usr/bin/git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
          /usr/bin/git ls-files
      else
          # el corpus del control no es un repositorio
          /usr/bin/find . -type f | sed 's|^\./||'
      fi ) | grep -E '\.(md|sh|py|m|yaml)$' | grep -v '^bancos/enlaces\.sh$' \
          | sed "s|^|$raiz/|" > "$lista"

    local docs=""
    for d in MEDICIONES.md AGENTS.md ENCINA-OS.md; do
        [ -f "$raiz/$d" ] && docs="$docs $raiz/$d"
    done
    # y las secciones de MEDICIONES.md, que desde la tarea 4 son ficheros
    for d in "$raiz"/mediciones/*.md; do
        [ -f "$d" ] && docs="$docs $d"
    done
    # shellcheck disable=SC2086  # $docs se expande a proposito: es una lista de rutas separadas por espacio, y ninguna lleva espacios
    if [ -n "$docs" ]; then awk -f "$TMP/anclas.awk" $docs | sort -u > "$TMP/idx.tsv"
    else : > "$TMP/idx.tsv"; fi

    if [ ! -s "$lista" ]; then echo "[FALLO] corpus vacio en $raiz" >&2; return 1; fi
    # shellcheck disable=SC2046  # la division en palabras es QUERIDA: la lista es un fichero por linea, sin espacios (git ls-files)
    awk -v IDX="$TMP/idx.tsv" -v RAIZ="$raiz" -f "$TMP/escanear.awk" \
        "$TMP/idx.tsv" $(cat "$lista") > "$TMP/hallazgos.tsv"
}

# ------------------------------------------------------------- el control ----
control() {
    titulo "EL CONTROL, antes de medir nada: seis casos con respuesta conocida"
    local c="$TMP/corpus"
    mkdir -p "$c/scripts"
    printf '#!/bin/sh\n' > "$c/scripts/existe.sh"; chmod +x "$c/scripts/existe.sh"
    printf 'destino\n' > "$c/DESTINO.md"
    cat > "$c/MEDICIONES.md" <<'MD'
## 4. Estado del arte

### 4.1 Una seccion que si existe

#### (b) Una sub-subseccion que si existe

Los tres NEGATIVOS, que tienen que salir rojos: §4.999, `scripts/no-existe.sh`
y [este enlace](NO-EXISTE.md).

Los tres POSITIVOS, que tienen que salir verdes: §4.1b, `scripts/existe.sh`
y [este otro](DESTINO.md).
MD
    escanear "$c" || { echo "[FALLO] el control no pudo escanear"; return 1; }

    local r=0
    # los tres que TIENEN que salir rojos, y cada uno por SU motivo
    if grep -q '^REFD_MAL	MEDICIONES.md	.*	§4.999' "$TMP/hallazgos.tsv"
        then ok    "rojo (1/3): la referencia inventada §4.999 se detecta"
        else fallo "rojo (1/3): §4.999 NO se detecta -> el guion no sabe decir que no"; r=1; fi
    if grep -q '^GUION	MEDICIONES.md	.*	scripts/no-existe.sh' "$TMP/hallazgos.tsv"
        then ok    "rojo (2/3): el guion citado que no esta se detecta"
        else fallo "rojo (2/3): scripts/no-existe.sh NO se detecta"; r=1; fi
    if grep -q '^ENLACE	MEDICIONES.md	.*	NO-EXISTE.md' "$TMP/hallazgos.tsv"
        then ok    "rojo (3/3): el enlace relativo roto se detecta"
        else fallo "rojo (3/3): NO-EXISTE.md NO se detecta"; r=1; fi
    # los tres que TIENEN que salir verdes: sin esto el guion podria estar
    # diciendo que todo esta roto, que da el mismo rojo y no mide nada
    if grep -q '^REFD_OK	MEDICIONES.md	.*	§4.1b' "$TMP/hallazgos.tsv"
        then ok    "verde (1/3): §4.1b resuelve contra un «#### (b)», que es la trampa (1)"
        else fallo "verde (1/3): §4.1b NO resuelve -> el indice no ve el segundo nivel"; r=1; fi
    if [ -f "$c/scripts/existe.sh" ] && grep -q '^GUION	MEDICIONES.md	.*	scripts/existe.sh' "$TMP/hallazgos.tsv"
        then ok    "verde (2/3): el guion que si esta se cita y se encuentra"
        else fallo "verde (2/3): scripts/existe.sh no llego al escaneo"; r=1; fi
    if grep -q '^ENLACE	MEDICIONES.md	.*	DESTINO.md' "$TMP/hallazgos.tsv"
        then ok    "verde (3/3): el enlace que si resuelve se ve"
        else fallo "verde (3/3): DESTINO.md no llego al escaneo"; r=1; fi
    return $r
}

# ------------------------------------------------------------ la medicion ----
EXCLUIDAS="imagen/autoinstall-e3.yaml imagen/verificar-e2.sh scripts/construir-deb.sh scripts/00-entorno.sh scripts/01-repo.sh scripts/02-activos.sh scripts/03-construir.sh scripts/04-instalar.sh scripts/05-verificar.sh scripts/06-ci.sh scripts/07-firefox-construir.sh scripts/08-firefox-instalar.sh scripts/09-firefox-verificar.sh scripts/10-meta-construir.sh scripts/11-meta-instalar.sh scripts/12-meta-verificar.sh"
esta_excluida() { case " $EXCLUIDAS " in *" $1 "*) return 0 ;; *) return 1 ;; esac; }

# LAS ROTAS DECLARADAS: rotas de verdad, y SIN DESTINO DEMOSTRABLE. Salen
# [AVISO] y no [FALLO], y la diferencia entre las dos cosas es lo unico que
# importa de esta lista: un [FALLO] que nadie puede arreglar deja de leerse a la
# tercera vez, y entonces el guion completo deja de servir. Cada una lleva su
# motivo, y NINGUNA se arreglo inventandole un destino -- eso seria deducir, y
# aqui lo deducido va separado de lo medido.
#
# Se caen solas de la lista el dia que el texto cambie: la clave es el par
# (fichero, referencia), asi que si alguien la corrige, el guion avisa de que la
# entrada sobra.
declarar_rotas() {
    cat <<'ROTAS'
DIARIO.md	§6.5	apuntaba a la definicion de terminado de encina-doctor en AGENTS.md, y encina-doctor SE SUPRIMIO (ENCINA-OS.md §6.1). Era cierta el 2026-08-08, que es el dia de esa entrada, y el diario no se reescribe
tareas/cerradas/empieza-aqui-2026-08-08-a-2026-08-25.md	§6.1	(vivia en ENCINA-OS.md §7 hasta la tarea 7, 2026-08-28, que movio §7 entero a ese fichero) cualificada contra MEDICIONES.md, que NO HA TENIDO NUNCA una §6: sus secciones son la 4 y la 9. El motivo del residuo de l10n de D12 esta en algun sitio, pero cual no se puede demostrar sin la historia del documento
mediciones/4.2-remedicion-abrir-b1.md	§6.8	cualificada contra AGENTS.md, cuya §6 llega hasta la 6.4. La «lista completa» de lo deducido y no medido que la frase promete no existe hoy con ese numero (hasta la tarea 4, 2026-08-28, la clave era MEDICIONES.md: el fichero unico)
mediciones/4.66-el-instrumento-refactorizacion-bancos-enlaces.md	§6.8	es la §4.66 CITANDO la rota de arriba en su prosa (la tabla de (g)); en el fichero unico las dos vivian bajo la misma clave
ROTAS
}
esta_declarada() {
    declarar_rotas | awk -F'\t' -v f="$1" -v r="$2" '$1==f && $2==r {print $3; hallada=1} END{exit !hallada}'
}

medicion() {
    titulo "LA MEDICION, sobre $RAIZ"
    escanear "$RAIZ" || return 1
    local H="$TMP/hallazgos.tsv" r=0

    # ---- (A) referencias § --------------------------------------------------
    local nq nqm nd ndm nseed ntach ncita
    nq=$(grep -c '^REFQ_' "$H"); nqm=$(grep -c '^REFQ_MAL' "$H")
    nd=$(grep -c '^REFD_' "$H"); ndm=$(grep -c '^REFD_MAL' "$H")
    nseed=$(grep -c '^SEED' "$H"); ntach=$(grep -c '^TACHADA' "$H"); ncita=$(grep -c '^CITA' "$H")
    echo "   referencias §: $((nq+nd)) apariciones — $nq cualificadas, $nd desnudas, $nseed pasos del seed, $ntach tachadas y $ncita citadas (en un bloque de codigo o entre acentos graves), excluidas"

    # Se imprime UNA LINEA POR SITIO, no una por referencia distinta: la misma
    # referencia rota citada en dos ficheros son DOS arreglos, no uno. Y por eso
    # el contador del resumen y las lineas de arriba tienen que cuadrar.
    local nuevas=0
    if [ "$nqm" -eq 0 ]; then
        ok "las $nq referencias cualificadas resuelven contra el documento que nombran"
    else
        while IFS=$'\t' read -r _ f l ref q; do
            if motivo=$(esta_declarada "$f" "$ref"); then
                aviso "$f:$l cita $q $ref — ROTA DECLARADA: $motivo"
            else
                fallo "$f:$l cita $q $ref, y ese documento no tiene esa seccion"
                nuevas=$((nuevas+1))
            fi
        done < <(grep '^REFQ_MAL' "$H" | sort -u)
        [ "$nuevas" -gt 0 ] && r=1
    fi

    # §4.999 ES EL CONTROL VIVO Y NO ES CARGA UTIL, y por eso sale aparte en vez
    # de entre los hallazgos. Lo planta la casilla 1 de tareas/refactorizacion.md
    # -- «una referencia inventada a proposito tiene que ponerlo en rojo» -- y
    # hoy vive en seis sitios, todos hablando DEL control. Contarlo como fallo
    # ahogaria los rotos de verdad en una lista donde seis de once son mentira,
    # que es exactamente el ruido que hace que una lista deje de leerse. Que el
    # guion SEPA detectarlo esta demostrado dos veces: aqui, y en el corpus
    # sintetico de arriba, donde §4.999 SI cuenta como rojo.
    local n999 sitios999
    n999=$(grep -cE '^REF._MAL	.*	§4\.999	' "$H")
    sitios999=$(awk -F'\t' '$1=="REFD_MAL" && $4=="§4.999" {print $2":"$3}' "$H" | sort -u | tr '\n' ' ')
    ndm=$((ndm - n999))

    if [ "$ndm" -eq 0 ]; then
        ok "las $nd referencias desnudas resuelven contra la union de los tres indices"
    else
        nuevas=0
        while IFS=$'\t' read -r _ f l ref _; do
            [ "$ref" = "§4.999" ] && continue
            if motivo=$(esta_declarada "$f" "$ref"); then
                aviso "$f:$l — $ref — ROTA DECLARADA: $motivo"
            else
                fallo "$f:$l — $ref no existe en ningun indice"
                nuevas=$((nuevas+1))
            fi
        done < <(grep '^REFD_MAL' "$H" | sort -u)
        [ "$nuevas" -gt 0 ] && r=1
    fi

    # una rota declarada que ya no aparece: la entrada sobra y hay que quitarla
    while IFS=$'\t' read -r f ref _; do
        grep -q "^REF._MAL	$f	.*	$ref	" "$H" && continue
        aviso "sobra de la lista de rotas declaradas: $f ya no cita $ref"
    done < <(declarar_rotas)
    if [ "$n999" -gt 0 ]; then
        ok "el control vivo: §4.999 se detecta y NO se cuenta como carga util — $n999 vivo(s) en $sitios999(el resto de sus apariciones van entre acentos graves, o sea citadas)"
    else
        aviso "§4.999 ya no esta en el arbol: el control vivo de la casilla 1 se ha perdido"
    fi
    omitido "un [OK] desnudo dice «existe en algun sitio», no «existe donde se pretendia» (trampa 3)"
    omitido "este guion NO se comprueba a si mismo (trampa 7): sus §4.998 y §4.1b son los negativos de su control"

    # ---- (B) guiones citados ------------------------------------------------
    local rutas nrutas rotas=0
    rutas=$(awk -F'\t' '$1=="GUION" && $5=="ruta" {print $4}' "$H" | sort -u)
    nrutas=$(echo "$rutas" | grep -c .)
    for p in $rutas; do
        [ -e "$RAIZ/$p" ] && continue
        if esta_excluida "$p"; then continue; fi
        while IFS=$'\t' read -r _ f l _ _; do
            fallo "$f:$l cita $p, que no esta en el disco"
        done < <(awk -F'\t' -v p="$p" '$1=="GUION" && $4==p' "$H" | sort -u)
        rotas=$((rotas+1))
    done
    if [ "$rotas" -eq 0 ]; then ok "las $nrutas rutas de guion citadas existen (o estan en la lista de exclusion)"
    else r=1; fi

    # las exclusiones que ya no hacen falta: asi la lista no se pudre
    for p in $EXCLUIDAS; do
        [ -e "$RAIZ/$p" ] && aviso "sobra de la lista de exclusion: $p YA existe en el disco"
    done

    # las rutas bajo medios/: ni [OK] ni [FALLO], porque no se pueden comprobar
    # desde un clon (medios/ es .gitignore). Se cuentan para que no desaparezcan.
    local nmed
    nmed=$(awk -F'\t' '$1=="MEDIOS" {print $4}' "$H" | sort -u | /usr/bin/grep -c .)
    [ "$nmed" -gt 0 ] && omitido "$nmed rutas citadas bajo medios/, que no se versiona: no se comprueban (en un clon limpio no existen)"

    # los nombres sueltos: [AVISO] y no [FALLO], por la trampa (4)
    local sueltos
    sueltos=$(awk -F'\t' '$1=="GUION" && $5=="nombre" {print $4}' "$H" | sort -u \
              | while read -r b; do grep -qE "(^|/)$(echo "$b" | sed 's/\./\\./g')\$" "$TMP/lista.txt" || echo "$b"; done)
    if [ -z "$sueltos" ]; then ok "todos los nombres de guion sueltos aparecen en el arbol"
    else aviso "nombres de guion citados sin ruta que no estan en este arbol (pueden ser de subiquity, de apt o de encina-autofirma — hay que mirarlos):"
         echo "$sueltos" | sed 's/^/            /'; fi

    # ---- (C) enlaces relativos ----------------------------------------------
    local nenl=0 nrot=0
    while IFS=$'\t' read -r _ f l d dir; do
        nenl=$((nenl+1))
        local base; if [ "$dir" = "." ]; then base="$RAIZ"; else base="$RAIZ/$dir"; fi
        [ -e "$base/$d" ] && continue
        fallo "$f:$l — el enlace ($d) no resuelve desde $dir/"
        nrot=$((nrot+1))
    done < <(grep '^ENLACE' "$H")
    if [ "$nrot" -eq 0 ]; then ok "los $nenl enlaces relativos de los .md resuelven"
    else r=1; fi

    return $r
}

# ------------------------------------------------------------------ salida ---
RC=0
if [ "$HACER_CONTROL" = 1 ]; then
    if ! control; then
        echo
        echo "${C_MAL}EL CONTROL NO PASA.${C_FIN} No se mide nada: un comprobador de referencias"
        echo "que no encuentra nada da la misma salida que un arbol sano."
        exit 1
    fi
fi
if [ "$HACER_MEDICION" = 1 ]; then medicion || RC=1; fi

echo
echo "${C_TIT}== RESUMEN${C_FIN}"
echo "   correctas: $N_OK   fallos: $N_MAL   avisos: $N_AVI   omitidas: $N_OMI"
[ "$RC" = 0 ] && echo "   ${C_OK}ninguna referencia apunta a la nada.${C_FIN}"
exit $RC
