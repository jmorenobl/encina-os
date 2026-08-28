# mk/medio.mk — el medio: fabricarlo, fabricarlo DOS VECES, sus sumas, arrancarlo.
#
# Todo pasa por imagen/construir-todo.sh, que es la orden de verdad y cruza a
# la VM constructora ($(CONSTRUCTOR)) para los pasos que macOS no puede dar.
# Aqui solo se le ponen nombre y se le exige su definicion de terminado.

.PHONY: iso dos-veces qemu verificador sumas

# la ISO de la arquitectura pedida, a su nombre de siempre en medios/
iso:
	./imagen/construir-todo.sh --constructor $(CONSTRUCTOR) --iso-oficial $(ISO_OFICIAL) \
	    --autofirma $(AUTOFIRMA) --salida $(ISO_SALIDA)

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
	        --autofirma $(AUTOFIRMA) --salida $(MEDIOS)/.dos-veces-$$p.iso; \
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
# la VM no se pueda confundir con otra (trampa 32 de SCRIPTS.md)
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
