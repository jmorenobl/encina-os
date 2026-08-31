# Encina OS — una orden para probar y una para construir (tarea 6 de
# tareas/refactorizacion.md, 2026-08-28).
#
#     make bancos       los bancos que no necesitan maquina ni ISO, y shellcheck.
#                       Es lo que corre la CI. Sale distinto de cero si falla uno.
#     make paquetes     los tres .deb desde 'git archive HEAD', por huella contra
#                       el manifiesto (en Linux con los guiones; en el Mac, por docker)
#     make iso          la ISO, con construir-todo.sh (cruza a la VM constructora)
#     make dos-veces    LA definicion de terminado de construir-todo.sh: dos pasadas,
#                       la misma huella. Hasta hoy era una frase en CLAUDE.md
#     make medios/SHA256SUMS   las sumas de medios/, calculadas y no escritas a mano
#     make qemu         un bundle de UTM para arrancar el medio (fabricar-vm-medio.py)
#     make verificador  medios/verificar-instalacion.sh EMPAQUETADO, el que viaja solo
#     make release NUEVA=X.Y.Z   la receta de sacar una version, ENSAYO en seco (A3);
#                       con DE_VERDAD=1 la cadena real, que estrena C4 (sacar-version.sh)
#     make repo         el repositorio apt FIRMADO del canal (D25/C3) en medios/repo,
#                       desde los .deb por huella; la subida es subir-sourceforge.sh --repo
#
# La configuracion va partida por asunto en mk/*.mk, que es la forma de
# pop-os/iso (organizacion-comparada.md, fila A4/D4): este fichero solo dice
# que hay y que variables mandan. Las variables se pueden dar en la linea:
#     make iso ARQ=amd64 CONSTRUCTOR=jorge@192.168.64.3
#
# El make de macOS es el 3.81 (2006) y no tiene .RECIPEPREFIX ni ::=; se
# escribe para ese, y entonces vale tambien en el GNU make de Ubuntu.

SHELL := /bin/bash
.DEFAULT_GOAL := ayuda

# --- lo que manda -----------------------------------------------------------
ARQ         ?= arm64
CONSTRUCTOR ?= jorge@192.168.64.3
AUTOFIRMA   ?= $(HOME)/Projects/encina-autofirma/salida
MEDIOS      := medios
ISO_OFICIAL  = $(MEDIOS)/ubuntu-24.04.4-desktop-$(ARQ).iso
ISO_SALIDA   = $(MEDIOS)/encina-os-$(ARQ).iso

include mk/bancos.mk
include mk/paquetes.mk
include mk/medio.mk

.PHONY: ayuda
ayuda:
	@sed -n '4,17p' Makefile
	@echo
	@echo "  ARQ=$(ARQ)  CONSTRUCTOR=$(CONSTRUCTOR)  AUTOFIRMA=$(AUTOFIRMA)"
