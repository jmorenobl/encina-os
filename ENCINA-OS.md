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

---

## 3. Qué existe ya

| Artefacto | Estado |
|---|---|
| `encina-branding` | **Construido, instalado y probado.** v0.1.6, 10/10 de la definición de terminado en VM Ubuntu 24.04 arm64, cuatro comprobaciones miradas en pantalla |
| `encina-firefox-native` | Especificado en `AGENTS.md` §5. **Sin empezar** |
| Repositorio git | Creado: `jmorenobl/encina-os`, **privado** (D5) |
| Integración continua | `.github/workflows/build.yml` en `ubuntu-latest`. Verde, comprobada por `workflow_dispatch`; **el disparo por `push` está pendiente de confirmar** |
| Scripts de construcción y verificación | Ocho, en `scripts/`, versionados con el repositorio |
| `AGENTS.md` | Escrito, cubre branding + firefox-native |
| Nombre y convenciones | Cerrado (D1) |
| Licencia | EUPL-1.2 elegida; `LICENSE` es todavía un **marcador de posición**, falta el texto oficial |

**Conclusión: la Etapa A tiene su primer paquete real y la cadena de
construcción en marcha.** Lo que sigue es A2, no la imagen: una receta de imagen
instala paquetes, y con uno solo no hay casi nada que instalar.

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
| R4 | No eliminar el Snap de Firefox desde un paquete; es destructivo. Corresponde a la receta de imagen |
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
| A1 | `encina-branding` construido, probado, en CI | **Hecho** (v0.1.6). Falta confirmar que la CI se dispara por `push` |
| A2 | `encina-firefox-native` (repo Mozilla + pinning + clave) | **← AQUÍ.** Especificado, sin empezar |
| A3 | `encina-locale-es` (solo lo que delate `check-language-support -l es`) | Especificado |
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

### Objetivo: `encina-firefox-native` (fase A2)

Configurar el repositorio APT oficial de Mozilla, su clave de firma y el anclaje
de prioridad. **No** instala Firefox, ni el paquete de idioma, ni elimina el
Snap: ver R3, R4 y R10.

La especificación completa está en `AGENTS.md` §5 —contenido exacto de cada
fichero, huella de la clave que hay que verificar antes de usarla, orden de
instalación que el README del paquete debe documentar, y definición de
terminado—. No la dupliques aquí.

El camino es el mismo que en A1: escribir el paquete, `./scripts/03-construir.sh`
para reglas duras + build + `lintian`, y probarlo en la VM. La comprobación
crítica de este paquete es que `sudo apt full-upgrade` ejecutado **dos veces** no
reintroduzca el Snap ni degrade Firefox a la versión de Ubuntu: lo que se está
verificando es el anclaje, y su ausencia es la causa de fallo más habitual.

Antes de referenciar `firefox-l10n-es-es` en ningún sitio, confirma el nombre
real con `apt-cache search firefox-l10n` (AGENTS.md §5.3). Es previsible, no
verificado.

### Terminado cuando

Las siete casillas de `AGENTS.md` §5.5. Ninguna se marca sin ejecutar el comando.

### Pendiente de A0 y A1

No bloquea A2. Cuando tengas cinco minutos:

- [ ] Sustituir `LICENSE` por el texto oficial de la EUPL-1.2, de joinup.ec.europa.eu
- [ ] Confirmar que la CI se dispara por `push`, no solo por `workflow_dispatch`

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
