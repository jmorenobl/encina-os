# encina-meta

Metapaquete de Encina OS. Declara de qué se compone el producto y **no lleva ni
un fichero propio**: lo único que hay dentro del `.deb` es su `changelog` y su
`copyright`, bajo `/usr/share/doc/encina-meta/`.

Existe para que un instalador desatendido instale **un nombre** y no una lista.
Un metapaquete con contenido son dos paquetes mal separados.

```
Depends:    encina-branding, encina-firefox-native, autofirma,
            hunspell-es, language-pack-es, language-pack-gnome-es
Recommends: libreoffice-l10n-es, hyphen-es, mythes-es
```

## Un nombre no es una sola orden

La instalación completa son **tres órdenes**, y no es un apaño: es consecuencia
directa de R10. Está medido en `MEDICIONES.md` §4.10.

```
# 1. los cuatro .deb.  Aquí Firefox NO cambia todavía
sudo apt install ./encina-meta_*.deb ./encina-branding_*.deb \
                 ./encina-firefox-native_*.deb ./autofirma_*.deb

# 2. hasta aquí el repositorio de Mozilla existe, pero apt no lo ha leído
sudo apt update

# 3. aquí llega el Firefox nativo, y el idioma
sudo apt full-upgrade
sudo apt install firefox-l10n-es-es
```

El paso 3 **no lo hace `apt upgrade`**. El paquete `firefox` de Ubuntu es un deb
de transición al Snap y lleva epoch (`1:1snap1-0ubuntu5`), así que la versión
real de Mozilla es *menor* y el cambio es formalmente una desactualización:
`upgrade` no desactualiza nunca y `full-upgrade` sí. Un script que lo haga con
`-y` necesita además `--allow-downgrades`; una persona que responda a la
pregunta de apt, no.

## Por qué no declara `firefox`

Es la trampa que podía parar el incremento entero, y la respuesta está medida.

`firefox` y `firefox-l10n-es-es` viven en el repositorio de Mozilla, que lo
configura `encina-firefox-native` y **no está en los índices de apt cuando apt
resuelve estas dependencias**: los ficheros que lo declaran se desempaquetan en
esa misma transacción, cuando la decisión ya está tomada (R10).

Lo importante es que **declararlo no falla**, que sería lo cómodo:

- En un escritorio de fábrica, `Depends: firefox` lo satisface el deb de
  transición que Ubuntu ya trae instalado. apt sale con 0, no instala nada, y la
  máquina se queda en el Snap **sin decir nada**.
- En una base sin Firefox, apt lo resuelve contra el índice de Ubuntu e instala
  `snapd` y el Snap.

`firefox-l10n-es-es` sí falla en duro (`Depends: firefox-l10n-es-es but it is
not installable`), que es la diferencia entre las dos.

Entonces, ¿cómo llega el Firefox nativo si nadie lo declara? Porque **el nombre
`firefox` ya está instalado** en toda Ubuntu de escritorio, y el anclaje de
prioridad de `encina-firefox-native` reasigna ese nombre al paquete de Mozilla.
No se instala: se sustituye. Con control: quitando solo el anclaje, apt no
propone ningún cambio.

**Consecuencia para E2:** si la imagen no parte de un escritorio completo, no
habrá ningún `firefox` que sustituir y habrá que instalarlo explícitamente en el
seed, después del `apt update`.

## Por qué `autofirma` es insatisfacible hoy

`autofirma` no está en ningún repositorio: se construye en
`~/Projects/encina-autofirma`. Declararlo es correcto —describe la verdad del
producto— pero hasta que exista el repo local de E2 hay que poner el `.deb` al
lado, como en la orden de arriba. Se baja del artefacto de su CI:

```
gh run download <ID> -n autofirma-arm64 -R jmorenobl/encina-autofirma
```

## Lo que este paquete NO hace

- **No lleva configuración.** Ni `gschema.override`, ni dconf, ni nada en
  `/etc`. Lo que haya que configurar se configura en el paquete al que
  pertenece.
- **No lleva scripts de mantenedor.** Si hiciera falta uno, sería señal de que
  una dependencia está mal declarada.
- **No cierra ninguna barrera de la firma** (D13). La tentación aquí llega como
  «ya que `encina-meta` lo instala todo, que deje también el `policies.json`».
  La respuesta es D13.
- **No declara `thunderbird-locale-es`**, que sí estaba en la especificación
  inicial. Es un paquete de transición que arrastra `thunderbird`, y ese lleva
  `Pre-Depends: snapd`: un `Recommends:` que devuelve el Snap a la única imagen
  construida para no tenerlo. Cuando E4 decida qué aplicaciones trae Encina OS
  de serie, la línea vuelve con la forma que corresponda.
- **No fija versiones** de los otros paquetes de Encina. Mientras los tres se
  construyan juntos, un `>=` obliga a subir la versión del metapaquete cada vez
  que cambia cualquiera de los otros y no compra nada que la CI no dé ya.

## Verificación

```
./scripts/10-meta-construir.sh    # reglas duras, build, lintian     (VM y CI)
./scripts/11-meta-instalar.sh     # la secuencia de tres órdenes     (VM)
./scripts/12-meta-verificar.sh    # idempotencia y purga             (VM)
```

`lintian` sobre este paquete **no dice ni una línea**, medido con
`--display-info --pedantic`. Por eso no hay fichero de overrides: si algún día
aparece una etiqueta, es nueva.

La casilla que decide de verdad no la da ningún script: una firma real en
`valide.redsara.es`, mirada en pantalla, sobre un clon que se destruye después
porque lleva dentro un certificado personal (`ENCINA-OS.md` §9.1).
