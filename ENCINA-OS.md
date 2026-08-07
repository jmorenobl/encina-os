# Encina OS — Documento maestro

**Punto de entrada único del proyecto.** Si no sabes por dónde seguir, lee la
sección 7 («Empieza aquí») y nada más.

Última actualización: 7 de agosto de 2026

---

## 0. Los documentos y para qué sirve cada uno

| Documento | Papel | Cuándo abrirlo |
|---|---|---|
| **ENCINA-OS.md** (este) | Índice, estado y siguiente acción | Siempre primero |
| `AGENTS.md` | Instrucciones ejecutables: reglas duras, convenciones y especificación de los paquetes | Al lanzar trabajo con Claude Code |
| `README.md` | Qué es el proyecto y en qué estado está, para quien llega de fuera | Al enseñar el repositorio |
| `SCRIPTS.md` | Qué hace cada script de `scripts/` y en qué orden | Antes de ejecutar nada en la VM |
| `RECETA-A1-encina-branding.md` | Guía por sesiones de la fase A1 | Histórico: A1 ya está terminada |
| `DIARIO.md` | Dónde se quedó el trabajo | Al retomarlo tras unos días |

Si se contradicen, **manda este**.

El `especificacion-proyecto.md` que citaban versiones anteriores de este
documento **no existe en el repositorio**, ni tampoco `AGENTS-encina.md`, que
hoy es `AGENTS.md`. El detalle largo de la Etapa B está sin escribir; se
escribirá al llegar a ella.

---

## 1. Qué es Encina OS

Una distribución de escritorio basada en Ubuntu LTS, pensada para que un usuario
español la use con la mínima fricción.

**El producto real es la paquetería `.deb`, no la imagen.** La imagen es un
envase que instala un metapaquete. Esta distinción es la decisión estructural del
proyecto: desacopla el ciclo de Encina del ciclo de Ubuntu, y permite que un
usuario que ya tiene Ubuntu instalado —el caso mayoritario— se beneficie sin
reinstalar nada.

El proyecto tiene dos etapas:

- **Etapa A** — sistema base, identidad propia y cadena de build reproducible.
- **Etapa B** — integración con la administración española: AutoFirma,
  certificados FNMT, DNIe.

Estamos en la Etapa A.

---

## 2. Decisiones cerradas

No volver a discutirlas sin motivo nuevo.

| # | Decisión | Motivo en una línea |
|---|---|---|
| D1 | Nombre: **Encina OS**, identificador `encina` | Sin colisión con distros activas; sin acentos; seis letras |
| D2 | Base: Ubuntu LTS con `ubuntu-desktop-minimal` | Sigue siendo GNOME completo; partir de mínimo y sumar es declarativo, quitar es frágil |
| D3 | El producto es la paquetería, no la ISO | Nadie reinstala el sistema para arreglar un trámite que vence hoy |
| D4 | Todo declarativo y versionado; Cubic solo como laboratorio | Un chroot editado a mano no es reproducible |
| D5 | No publicar imagen en la Etapa A | Publicar activa la obligación de mantener parches de seguridad para desconocidos |
| D6 | `ID=ubuntu` intacto en `os-release` | Software de terceros comprueba ese campo; cambiarlo produce fallos inconexos durante meses |
| D7 | Tema estético (macOS u otro) en paquete separado, nunca en la base | Es preferencia personal, no necesidad jurisdiccional |
| D8 | Certificado software FNMT antes que DNIe con lector | Cubre el 90% de trámites y no requiere hardware |
| D9 | Desarrollo en Mac M3; imágenes arm64 en la Etapa A | Son para UTM del autor: nativas y rápidas. amd64 solo cuando el destino son terceros |
| D10 | No comprar máquina física | SoftHSM2 cubre PKCS#11 sin lector; Hetzner por horas cubre amd64 de escritorio |
| D11 | Los dos lanzadores «Firefox» se resuelven quitando el Snap en la ISO propia, no ocultando entradas | Ocultar la del Snap borra el icono del dock de una sesión en marcha, y desde un paquete no se puede exigir cerrar sesión: R3 impide llamar a nada, §8 prohíbe cualquier GUI. Se vive como «me han roto el equipo» |

---

## 3. Qué existe ya

| Artefacto | Estado |
|---|---|
| `encina-branding` | **Construido, instalado y probado.** v0.1.6, 10/10 de la definición de terminado en VM Ubuntu 24.04 arm64, cuatro comprobaciones miradas en pantalla |
| `encina-firefox-native` | **Construido, instalado y probado.** v0.2.0, las siete casillas de la definición de terminado en VM Ubuntu 24.04 arm64, la última mirada en pantalla |
| Repositorio git | Creado: `jmorenobl/encina-os`, **privado** (D5) |
| Integración continua | `.github/workflows/build.yml` en `ubuntu-latest`, **una entrada de matriz por paquete**. **Verde por `push` y por `workflow_dispatch`**, comprobada sobre `9a673b8`. La entrega de los push fue irregular durante la incidencia de Actions del 2026-08-06 |
| Scripts de construcción y verificación | Once, en `scripts/`, versionados con el repositorio. 00–06 comunes y de A1; 07–09 de A2 |
| `AGENTS.md` | Escrito, cubre branding + firefox-native. §5.1 enmendado en A2: el paquete también hace que el icono abra el nativo, por D3 |
| Nombre y convenciones | Cerrado (D1) |
| Licencia | EUPL-1.2 elegida; `LICENSE` es todavía un **marcador de posición**, falta el texto oficial |

**Conclusión: la Etapa A tiene dos paquetes reales y la cadena de construcción
en marcha.** Con `encina-firefox-native` queda resuelto por adelantado el
obstáculo principal de la Etapa B: Firefox nativo, no en Snap, y por tanto sin
sandbox aislando el almacén NSS.

Sigue sin tocar la imagen: una receta de imagen instala paquetes, y con dos aún
no hay casi nada que instalar.

### 3.1 Verificaciones pendientes sobre el nombre

- [ ] PyPI: `encina` disponible
- [ ] GitHub: organización `encina` o alternativa
- [ ] Dominio: `encinaos.es`, `encinaos.org`
- [ ] OEPM, localizador de marcas, clases 9 y 42

Colisión conocida y descartada: Encina fue un sistema de transacciones de
Transarc/IBM, base de IBM TXSeries hasta 2006. Producto muerto; no es problema de
marca, pero competirá en resultados de búsqueda.

---

## 4. Estado del arte (no volver a investigar)

Resumen de lo ya averiguado, para no repetir el trabajo.

**Empaquetado alternativo de AutoFirma — existe, y está flojo:**

- `gecos-team/autofirma-gecos` — de la Agencia Digital de Andalucía. Parado: el
  último `.deb` commiteado es AutoFirma 1.7.1 y la versión actual es la 1.9.
  Paquete generado con `dpkg -b` sobre un `DEBIAN/` a mano, no en regla. Valioso
  por el diagnóstico, no como base de código.
- `albfernandez/clienteafirma-deb-package` — mejor ingeniería: `debian/` correcto,
  compila desde fuentes, no cierra los navegadores al instalar, elimina las
  librerías nativas de Windows y Mac de los jars. **Mejor base candidata.** Un solo
  mantenedor.
- openSUSE: paquete comunitario en el repo personal de Antonio Larrosa; sin
  paquete oficial para Leap 15.6.
- AUR: `autofirma`, `autofirma-bin`, y un `autofirmaja` cuyo mantenedor declara
  abiertamente que no puede sostenerlo.

**Licencia:** AutoFirma es software libre, GPL 2+ y EUPL 1.1, código en la forja
del CTT. **Es redistribuible.**

**El bug está vivo y documentado upstream:**

- Issue #459 de `ctt-gob-es/clienteafirma` (agosto 2025): el `.deb` oficial 1.9 en
  Ubuntu 24.04 lanza `certutil: SEC_ERROR_ADDING_CERT` durante la instalación y
  aun así se declara exitosa. Fallo parcial silencioso.
- Issue #302: `openjdk-11-jre` no se declara como dependencia ni se documenta;
  los usuarios no ejecutan el binario desde consola, no ven los errores de Java, y
  para ellos «simplemente no funciona». Es el argumento de existencia del futuro
  `encina doctor`.

**El hueco real:** no existe ninguna herramienta de diagnóstico. Todo lo que hay
es o un paquete o un tutorial. Nadie itera sobre perfiles de navegador, nadie
detecta sandbox, y nadie se dirige al usuario individual no técnico.

**Riesgo del sector, aplicable a ti:** todos estos proyectos mueren por
agotamiento de una sola persona. De ahí D5 y el alcance mínimo.

---

## 5. Reglas duras

Invariantes. Si algo parece exigir violarlas, parar y replantear.

| # | Regla |
|---|---|
| R1 | Nada de `/etc/skel`. Configuración por defecto con `gschema.override` o perfiles de dconf |
| R2 | No llamar a `glib-compile-schemas`: `libglib2.0-0` tiene un disparador de dpkg que lo hace |
| R3 | No llamar a `apt`, `apt-get`, `dpkg` ni `snap` desde scripts de mantenedor (bloqueo de dpkg) |
| R4 | No eliminar el Snap de Firefox desde un paquete; es destructivo. Corresponde a la receta de imagen. **Sustituir su lanzador no es eliminarlo** y sí está permitido: el Snap sigue instalado, su perfil intacto, y `apt purge` lo devuelve todo (ver `AGENTS.md` §5.1) |
| R5 | No sobrescribir conffiles de otros paquetes: `/etc/default/grub` con `sed`; `os-release` con `dpkg-divert` |
| R6 | Tema de Plymouth basado en `spinner`, nunca en `bgrt` (bgrt muestra el logo del fabricante) |
| R7 | Tras instalar un tema de Plymouth, `update-initramfs -u`. El tema va dentro del initramfs |
| R8 | Ningún activo de terceros: ni marca Canonical, ni tipografía San Francisco, ni iconos que imiten macOS |
| R9 | Idempotencia: cinco instalaciones seguidas dejan el sistema idéntico |
| R10 | Sin dependencias circulares de repositorio: no declarar `Depends:` sobre paquetes de un repo que ese mismo paquete configura |

---

## 6. Hoja de ruta

Marcada la posición actual.

### Etapa A

| Fase | Contenido | Estado |
|---|---|---|
| A0 | Nombre, licencia, repositorio git inicializado | Hecho. Falta el texto oficial de la EUPL-1.2 en `LICENSE` |
| A1 | `encina-branding` construido, probado, en CI | **Hecho** (v0.1.6), con la CI verde por `push` |
| A2 | `encina-firefox-native` (repo Mozilla + pinning + clave) | **Hecho** (v0.2.0), 7/7 de la definición de terminado |
| A3 | `encina-locale-es` (solo lo que delate `check-language-support -l es`) | **← AQUÍ.** Especificado, sin empezar. Sigue listado en §8 hasta que lo abras |
| A4 | `encina-meta` + repo APT firmado + `encina-keyring` | Especificado |
| A5 | `autoinstall.yaml` sobre ISO oficial de Ubuntu | Especificado |
| A6 | Imagen propia con `live-build` o `debos` | Opcional, al final |

### Etapa B

| Fase | Contenido |
|---|---|
| B1 | Núcleo de detección (perfiles, NSS, sandbox) + `encina doctor` |
| B2 | `encina configure` + `autofirma-fix` |
| B3 | GUI GTK4 |
| B4 | DNIe con lector físico |
| B∥ | Vía paralela: PR upstream a `ctt-gob-es/clienteafirma`. Arrancar al empezar la Etapa B |

**Por qué la imagen no va antes:** una receta de imagen instala paquetes. Sin
paquetes construidos no hay nada que instalar, y sin repo del que servirlos la
receta no se puede escribir en su forma definitiva. A5 depende de A1–A4.

**Nota sobre A5 vs A6:** construir una ISO instalable de Ubuntu Desktop de forma
declarativa es más difícil que toda la paquetería junta — el instalador espera una
disposición concreta y `livecd-rootfs` está acoplado a Launchpad. Es donde la
gente abandona. Un `autoinstall.yaml` aplicado a la ISO oficial da «un sistema que
es Encina OS» sin remasterizar nada, es un YAML en git, y es reproducible. La ISO
propia solo después.

**Nota sobre el repo en A5:** mientras no exista el repo firmado (A4), usar un
repo local sin firmar generado en el propio build con `dpkg-scanpackages` y
consumido con `[trusted=yes]`. Ejercita el mecanismo real (repo + metapaquete en
el seed) sin gestión de claves GPG. La receta que se escriba así es la definitiva.

---

## 7. Empieza aquí

Una sola tarea. No abras ninguna otra hasta terminarla.

### A2 está terminada

`encina-firefox-native` 0.2.0, las siete casillas de `AGENTS.md` §5.5 verificadas
en VM Ubuntu 24.04 arm64. Configura el repositorio de Mozilla, su clave y el
anclaje, y hace que el icono del escritorio abra Firefox nativo.

Lo aprendido en la fase, para no repetirlo:

- **El anclaje no se comprueba solo instalando.** `apt full-upgrade` dos veces
  puede pasar en verde sin haber probado nada, si el sistema ya estaba al día.
  Hay que mirar cuántos paquetes ha movido y forzar las actualizaciones por
  fases si fueron cero.
- **La prueba concluyente del anclaje es el A/B de la purga:** con el paquete,
  el candidato de `firefox` sale de Mozilla; sin él, vuelve solo al deb de
  transición de Ubuntu. La diferencia entre las dos situaciones es el paquete.
- **Todo lo verificable sin pantalla no bastó.** Con las siete comprobaciones
  automáticas en verde, el icono del escritorio seguía abriendo el Snap. Se vio
  mirando `about:support`. Y estaba en español, así que parecía correcto.

### Siguiente: decidir si se abre A3

La hoja de ruta pone `encina-locale-es` como A3, pero **sigue listado en §8 como
fuera de alcance**. Esa contradicción es deliberada: abrir una fase es una
decisión, no un automatismo. Antes de empezarla hay que sacarla de §8 y escribir
su especificación en `AGENTS.md`, que hoy solo cubre `encina-branding` y
`encina-firefox-native`.

### Pendiente de A0

No bloquea nada. Cuando tengas cinco minutos:

- [ ] Sustituir `LICENSE` por el texto oficial de la EUPL-1.2, de joinup.ec.europa.eu

---

## 8. Fuera de alcance ahora

No implementar, no preparar, no dejar «ganchos para el futuro»:

AutoFirma, FNMT, DNIe, `opensc`, PKCS#11, NSS · `encina-locale-es` ·
`encina-meta`, `encina-keyring`, repo APT, `aptly` · `os-release` y `dpkg-divert` ·
ISO, `live-build`, `debos`, Cubic, `autoinstall.yaml` · temas de GTK o iconos ·
cualquier GUI.

---

## 9. Trampas conocidas

Registro para no redescubrirlas. Todas verificadas en la investigación previa.

| Trampa | Síntoma | Causa |
|---|---|---|
| Tema de Plymouth no aparece | Arranque idéntico tras instalar | El tema va dentro del initramfs; falta `update-initramfs -u` |
| Logotipo propio nunca se ve | Aparece el del fabricante | El tema hereda de `bgrt` en lugar de `spinner` |
| Arranque en negro en disco cifrado | No pide frase LUKS | Falta el callback `SetDisplayPasswordFunction` en el script |
| Fondo no se aplica a usuarios nuevos | Solo funciona para el usuario original | Se usó `/etc/skel` en lugar de `gschema.override` |
| Snap de Firefox reaparece | Vuelve tras `apt full-upgrade` | Falta el anclaje `Pin-Priority` sobre `packages.mozilla.org` |
| Firefox nativo arranca en inglés | Interfaz en en-US | El paquete de idioma es aparte: `firefox-l10n-es-es` |
| **El icono sigue abriendo el Snap** | Todo instalado y correcto, y `about:support` dice `/snap/firefox/...`. Y está en español, así que parece bien | Conviven dos lanzadores con identificadores distintos y Ubuntu ancla el del Snap. Se sombrea el suyo desde `/usr/share/applications` |
| **Desaparece el icono de Firefox** | Se pierde el lanzador al instalar, en una sesión ya abierta | `NoDisplay=true` en la sombra. GNOME Shell retira el icono al instante por inotify pero no relee los favoritos por defecto hasta iniciar sesión (D11) |
| **`apt install firefox` se niega** | «se utilizó -y sin --allow-downgrades» | El deb de transición de Ubuntu lleva epoch `1:`, así que la versión real de Mozilla es *menor*. Interactivamente basta responder que sí |
| **El anclaje se comprueba en vacío** | `full-upgrade` ×2 en verde sin mover un paquete | El sistema ya estaba al día. Sin contar los paquetes movidos, la prueba parece más fuerte de lo que fue |
| **El perfil nativo no está donde parece** | Los marcadores «no aparecen» | El deb de Mozilla usa `~/.config/mozilla/firefox/`, no `~/.mozilla/firefox/`, que ni existe. El del Snap está en `~/snap/firefox/common/.mozilla/` |
| **Una comprobación pasa sin comprobar nada** | `[OK]` con la cosa rota, o `[FALLO]` con la cosa bien | Una sesión ssh no tiene `XDG_CURRENT_DESKTOP` ni `XDG_DATA_DIRS`, la salida de apt está traducida, y `comando \| grep -q` con `pipefail` muere de SIGPIPE. Detalle en `SCRIPTS.md` |
| Firma electrónica falla sin explicación | Error que no menciona el sandbox | Navegador en Snap/Flatpak aísla el almacén NSS |
| Fallos raros con software de terceros | Instaladores y scripts que no reconocen el sistema | Se cambió `ID` en `os-release` |
| Fondo claro en modo oscuro | Solo en tema oscuro | Falta `picture-uri-dark` (GNOME 42+) |
| Builds no reproducibles | Dos builds del mismo commit difieren | Falta fijar fecha de snapshot del mirror |

---

## 10. Criterios de parada

- **Fin de Etapa A:** si no se logra un build con `.manifest` reproducible, no
  avanzar a la imagen propia. Los paquetes siguen siendo válidos por separado.
- **Fase B1:** si `encina doctor` no encuentra fallos reales en cuatro VMs
  (Firefox nativo, Snap, Flatpak, Debian limpio), el problema es menor de lo
  estimado y no justifica B2–B4.
- **Vía upstream:** si el PR a `clienteafirma` entra rápido, replantear el alcance
  en lugar de continuar por inercia.
