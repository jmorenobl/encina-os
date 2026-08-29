# mk/medio.mk — el medio: fabricarlo, fabricarlo DOS VECES, sus sumas, arrancarlo.
#
# Todo pasa por imagen/construir-todo.sh, que es la orden de verdad y cruza a
# la VM constructora ($(CONSTRUCTOR)) para los pasos que macOS no puede dar.
# Aqui solo se le ponen nombre y se le exige su definicion de terminado.

.PHONY: iso dos-veces qemu verificador sumas cosecha trozos publicar

# DESDE LA COSECHA PUBLICADA (2026-08-29, MEDICIONES.md §4.82): con
# COSECHA=<dir|tar|URL> los 25 .deb de ARCHIVO salen de ahi por huella y no
# del archivo de Ubuntu, que retira (trampa 68). CONSTRUIR_OPTS son banderas
# sueltas mas para construir-todo.sh (p. ej. las URLs cortadas del control).
COSECHA        ?=
CONSTRUIR_OPTS ?=
COSECHA_ARG     = $(if $(COSECHA),--cosecha $(COSECHA),)
# la version del PRODUCTO es la de encina-meta (bancos/versiones.sh), leida del
# manifiesto y no escrita aqui
VERSION := $(shell awk -F'\t' '$$1=="PROPIO" && $$2=="encina-meta" {print $$3}' imagen/repo-manifiesto.tsv)

# la ISO de la arquitectura pedida, a su nombre de siempre en medios/
iso:
	./imagen/construir-todo.sh --constructor $(CONSTRUCTOR) --iso-oficial $(ISO_OFICIAL) \
	    --autofirma $(AUTOFIRMA) --salida $(ISO_SALIDA) $(COSECHA_ARG) $(CONSTRUIR_OPTS)

# LA DEFINICION DE TERMINADO DE construir-todo.sh, ejecutable. Hasta el
# 2026-08-28 era una frase en CLAUDE.md --«dos pasadas dan la misma huella»--,
# y una definicion de terminado que no es ejecutable acaba siendo opcional. Dos
# pasadas a dos salidas, las huellas comparadas, y la segunda se borra si
# cuadran: un medio y su huella, no dos.
dos-veces:
	@set -euo pipefail; \
	for p in 1 2; do \
	    echo "== pasada $$p"; \
	    ./imagen/construir-todo.sh --constructor $(CONSTRUCTOR) --iso-oficial $(ISO_OFICIAL) \
	        --autofirma $(AUTOFIRMA) --salida $(MEDIOS)/.dos-veces-$$p.iso $(COSECHA_ARG) $(CONSTRUIR_OPTS); \
	done; \
	H1=$$(shasum -a 256 $(MEDIOS)/.dos-veces-1.iso | cut -d' ' -f1); \
	H2=$$(shasum -a 256 $(MEDIOS)/.dos-veces-2.iso | cut -d' ' -f1); \
	echo "pasada 1  $$H1"; echo "pasada 2  $$H2"; \
	if [ "$$H1" != "$$H2" ]; then echo "[FALLO] las dos pasadas NO dan la misma huella: el medio no es reproducible"; exit 1; fi; \
	cmp -s $(MEDIOS)/.dos-veces-1.iso $(MEDIOS)/.dos-veces-2.iso || { echo "[FALLO] misma huella y cmp distinto: parar y mirar"; exit 1; }; \
	mv $(MEDIOS)/.dos-veces-1.iso $(ISO_SALIDA); rm -f $(MEDIOS)/.dos-veces-2.iso; \
	echo "[OK]    dos pasadas, la misma huella: $(ISO_SALIDA)  $$H1"

# LAS SUMAS, CALCULADAS Y NO ESCRITAS A MANO. medios/SHA256SUMS eran 185 bytes
# escritos a mano, y este repositorio ya apunto una vez una huella por el nombre
# de la VM en vez de por el fichero (TAREAS.md). Un fichero por ISO presente,
# por orden de nombre; la orden es la que un tercero puede repetir.
sumas: $(MEDIOS)/SHA256SUMS
$(MEDIOS)/SHA256SUMS: $(wildcard $(MEDIOS)/*.iso)
	cd $(MEDIOS) && shasum -a 256 $(sort $(notdir $^)) > SHA256SUMS
	@cat $@

# un bundle de UTM para arrancar el medio, con la huella en el nombre para que
# la VM no se pueda confundir con otra (trampa 66 de SCRIPTS.md)
qemu:
	@H=$$(shasum -a 256 $(ISO_SALIDA) | cut -c1-8); \
	python3 scripts/fabricar-vm-medio.py --iso $(ISO_SALIDA) --nombre encina-medio-$$H --arq $(ARQ)

# EL VERIFICADOR QUE VIAJA SOLO. imagen/verificar-instalacion.sh carga
# lib/salida.sh (tarea 3), y dentro de la maquina instalada no hay clon: la
# copia que se le manda por el buzon lleva la biblioteca PEGADA entre las dos
# marcas del guion. bash -n sobre el resultado, y que no quede ni un 'source'.
verificador: $(MEDIOS)/verificar-instalacion.sh
$(MEDIOS)/verificar-instalacion.sh: imagen/verificar-instalacion.sh lib/salida.sh
	@awk -v lib=lib/salida.sh -v fecha="$$(date +%Y-%m-%d)" \
	    '/^# --- INICIO lib\/salida.sh/ { print "# --- lib/salida.sh, EMPAQUETADO por make verificador el " fecha " (no editar: edita lib/salida.sh) ---"; while ((getline l < lib) > 0) print l; skip=1; next } \
	     /^# --- FIN lib\/salida.sh ---/ { skip=0; next } !skip' imagen/verificar-instalacion.sh > $@.parcial
	@bash -n $@.parcial
	@if grep -q 'lib/salida.sh" 2>/dev/null' $@.parcial; then echo "[FALLO] el empaquetado no sustituyo el bloque"; rm -f $@.parcial; exit 1; fi
	@chmod +x $@.parcial && mv $@.parcial $@
	@echo "[OK]    $@: $$(wc -l < $@ | tr -d ' ') lineas, $$(shasum -a 256 $@ | cut -c1-16)…  (imagen/verificar-instalacion.sh + lib/salida.sh)"

# LA COSECHA QUE SE PUBLICA CON LA ISO (tareas/publicar.md, MEDICIONES.md
# §4.82): el /encina-repo que construir-todo.sh deja con --trabajo --conservar
# --29 .deb y su Packages-- empaquetado reproducible por empaquetar-cosecha.py.
# La ISO de esa misma pasada se COTEJA con medios/SHA256SUMS y se borra: la
# cosecha tiene que ser la del medio vigente, o no es su cosecha. Es lo que
# hace que la receta publica siga reproduciendo el producto cuando el archivo
# de Ubuntu o Mozilla hayan retirado lo que el manifiesto ancla (trampa 68).
COSECHA_DIR = $(MEDIOS)/cosecha-$(ARQ)
COSECHA_TAR = $(MEDIOS)/encina-repo-$(ARQ).tar
cosecha:
	@set -euo pipefail; \
	rm -rf $(COSECHA_DIR) $(MEDIOS)/.cosecha-$(ARQ).iso; \
	./imagen/construir-todo.sh --constructor $(CONSTRUCTOR) --iso-oficial $(ISO_OFICIAL) \
	    --autofirma $(AUTOFIRMA) --salida $(MEDIOS)/.cosecha-$(ARQ).iso \
	    --trabajo $(COSECHA_DIR) --conservar $(COSECHA_ARG) $(CONSTRUIR_OPTS); \
	H=$$(shasum -a 256 $(MEDIOS)/.cosecha-$(ARQ).iso | cut -d' ' -f1); \
	V=$$(awk '$$2=="encina-os-$(ARQ).iso" {print $$1}' $(MEDIOS)/SHA256SUMS); \
	rm -f $(MEDIOS)/.cosecha-$(ARQ).iso; \
	[ -n "$$V" ] || { echo "[FALLO] $(MEDIOS)/SHA256SUMS no tiene la linea de encina-os-$(ARQ).iso"; exit 1; }; \
	if [ "$$H" != "$$V" ]; then echo "[FALLO] la ISO de esta pasada ($$H) NO es el medio vigente ($$V): esta cosecha no es la suya"; exit 1; fi; \
	echo "[OK]    la cosecha es la del medio vigente: la ISO de esta misma pasada da $$H"; \
	python3 imagen/empaquetar-cosecha.py --repo $(COSECHA_DIR) --arq $(ARQ) --salida $(COSECHA_TAR)

# TROZOS DE MENOS DE 2 GiB, por si el alojamiento es una release de GitHub
# («cada fichero de una release tiene que ser menor de 2 GiB», su
# documentacion; tareas/alojamiento.md). Se recomponen con 'cat', y aqui se
# comprueba que recompuestos dan la huella del medio: un troceado que no se
# comprueba es una ISO que a lo mejor no arranca en casa de nadie.
TROZO ?= 2000m
trozos:
	@set -euo pipefail; \
	rm -f $(ISO_SALIDA).parte-*; \
	split -b $(TROZO) -a 2 $(ISO_SALIDA) $(ISO_SALIDA).parte-; \
	ls -l $(ISO_SALIDA).parte-*; \
	H=$$(shasum -a 256 $(ISO_SALIDA) | cut -d' ' -f1); \
	R=$$(cat $(ISO_SALIDA).parte-* | shasum -a 256 | cut -d' ' -f1); \
	[ "$$H" = "$$R" ] || { echo "[FALLO] los trozos recompuestos NO dan la huella del medio: $$R"; exit 1; }; \
	echo "[OK]    $$(ls $(ISO_SALIDA).parte-* | wc -l | tr -d ' ') trozos de $(TROZO), y 'cat' los recompone en $$H"

# LO QUE SE PUBLICA, EN UN DIRECTORIO Y CON SUS SUMAS CALCULADAS: las dos ISOs,
# las dos cosechas, SHA256SUMS y las notas de la release con las huellas
# sustituidas desde ese SHA256SUMS (nunca escritas a mano). No sube nada a
# ningun sitio: eso es de Jorge (tareas/alojamiento.md).
publicar:
	./imagen/preparar-publicacion.sh --medios $(MEDIOS) --salida $(MEDIOS)/publicar/$(VERSION)
