# mk/paquetes.mk — los tres .deb de Encina, y con que se construyen.
#
# En Linux (la VM constructora, el runner de la CI) corren los tres guiones de
# construccion tal cual, uno por paquete y a proposito (CLAUDE.md: cada uno
# esta validado contra el suyo). En el Mac no hay dpkg-buildpackage, asi que
# 'make paquetes' pasa por el constructor VERSIONADO de docker/ (tarea 15):
# la misma receta que antes solo existia como una VM en el disco de Jorge.
#
# LO QUE SE CONSTRUYE ES 'git archive HEAD', NO EL DIRECTORIO DE TRABAJO
# (MEDICIONES.md §4.37): un .deb del arbol de trabajo lleva dentro fechas que
# no estan en git y su huella no la reproduce nadie. Por eso 'paquetes' hace
# el archive a un directorio nuevo y construye ahi, en las dos vias.

SISTEMA := $(shell uname -s)
GUIONES_DEB := scripts/construir-branding.sh scripts/construir-firefox.sh scripts/construir-meta.sh
PAQUETES := encina-branding encina-firefox-native encina-meta

.PHONY: paquetes paquetes-linux paquetes-docker constructor

ifeq ($(SISTEMA),Linux)
paquetes: paquetes-linux
else
paquetes: paquetes-docker
endif

# la via de Linux: 'git archive HEAD' a un directorio nuevo, los tres guiones
# con ENCINA_REPO apuntando ahi (como la CI y como construir-todo.sh), y los
# .deb cotejados contra el manifiesto ANTES de copiarlos a debian-packages/.
paquetes-linux:
	@set -euo pipefail; \
	T=$$(mktemp -d); trap 'rm -rf "$$T"' EXIT; \
	git archive HEAD | tar -xf - -C "$$T"; \
	for g in $(GUIONES_DEB); do echo "== $$g"; ( cd "$$T" && ENCINA_REPO="$$T" bash "$$g" ); done; \
	for p in $(PAQUETES); do ./imagen/comprobar-propios.sh "$$p" --dir "$$T/debian-packages"; done; \
	cp "$$T"/debian-packages/*.deb debian-packages/; \
	echo "== los tres .deb, con la huella del manifiesto, en debian-packages/"

# la via del Mac: el constructor de docker/ (tarea 15). Construye la imagen si
# no esta y ejecuta dentro docker/construir-paquetes.sh, que es la misma
# secuencia de arriba pero en un Ubuntu 24.04 limpio.
constructor:
	docker build -t encina-constructor:24.04 -f docker/Dockerfile.constructor docker/
paquetes-docker: constructor
	docker run --rm -v "$(CURDIR)":/repo:ro -v "$(CURDIR)/debian-packages":/salida encina-constructor:24.04 \
	    /repo/docker/construir-paquetes.sh
