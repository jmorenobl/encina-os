# mk/bancos.mk — los bancos, y cuales corren donde.
#
# Tres grupos, porque no todos necesitan lo mismo:
#   bancos          ni maquina ni ISO: segundos, y es lo que corre la CI
#   bancos-medios   necesitan ISOs en medios/ (banco-mecanismos.sh)
#   banco-autosuficiencia   necesita la VM constructora y un repo cosechado
#
# 'make bancos' PARA EN EL PRIMERO QUE FALLE y sale distinto de cero, que es lo
# que pide la casilla. Para verlos todos aunque uno falle: 'make -k bancos'.

.PHONY: bancos bancos-medios banco-autosuficiencia \
        banco-enlaces banco-vigencia banco-ci-copias banco-shellcheck \
        banco-cadena banco-veredicto banco-conteo banco-mecanismos

bancos: banco-enlaces banco-vigencia banco-ci-copias banco-cadena banco-veredicto banco-conteo banco-shellcheck

banco-enlaces:
	./bancos/enlaces.sh
banco-vigencia:
	./bancos/vigencia.sh
banco-ci-copias:
	./bancos/ci-copias.sh
banco-shellcheck:
	./bancos/shellcheck.sh
banco-cadena:
	./imagen/banco-cadena.sh
banco-veredicto:
	./scripts/banco-veredicto.sh
banco-conteo:
	python3 scripts/veredicto-conteo.py --banco

bancos-medios: banco-mecanismos
banco-mecanismos:
	./imagen/banco-mecanismos.sh --medios $(MEDIOS)

# REPO es el directorio cosechado (el --trabajo de construir-todo.sh, o el que
# deja 'make repo'); sin el no hay nada que medir.
REPO ?= $(MEDIOS)/repo-trabajo
banco-autosuficiencia:
	./imagen/banco-autosuficiencia.sh --repo $(REPO) --constructor $(CONSTRUCTOR) --arq $(ARQ)
