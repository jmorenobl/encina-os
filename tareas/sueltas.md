# Sueltas, de un rato cada una

- [ ] **La huella de la CA del socket, comparada con la del paquete.** §4.33f lo
      hizo (`73f752a4…` a los dos lados) y §4.42 **no**: allí se midió que la CA
      llega sola y al perfil correcto, no que sea la misma que instala el `.deb`.
      Cuesta dos órdenes y cierra el único cabo suelto de la firma.
      *Hecha cuando:* las dos huellas se enseñan juntas, con el control de que
      `certutil` sabe decir que no de un apodo inventado.

- [x] ~~**QUÉ HACER CON LA LISTA DE ETAPAS DEL VERIFICADOR.**~~ **HECHA el
      2026-08-14** (`MEDICIONES.md` §4.41): exige las **ocho** que dicen quién
      contestó qué, `loading` pasa a `[DATO]`, y **el motivo entero va en el
      propio guion**, encima de la comprobación, para que se lo encuentre quien
      vuelva a tocarlo. *Hecha cuando, cumplido:* **52 de 52 en verde y el rojo
      probado en la misma máquina** —`source` metido en el `telemetry` da 2
      fallos y `rc=1`, y se restaura con huella idéntica—, más la lógica probada
      antes en el Mac con las tres posiciones de `loading` y cuatro casos que
      tienen que fallar. *Lo que sigue sin explicar:* por qué §4.32f **sí** la
      escribió; su ISO ya no existe, **pero ya no bloquea nada**.
      *Lo que se midió para llegar aquí (§4.40c bis):* **`loading` no se registra nunca en esta ISO** —
      dos arranques independientes, uno instalando y otro sin instalar nada, y la
      palabra **no sale ni una vez** del registro del cliente, con el control de
      que el mismo `grep` encuentra `keyboard` catorce veces. El primer volcado
      del `telemetry`, **0,742 s antes de dibujarse ninguna pantalla**, ya decía
      `{"0":"keyboard"}`. **El fallo es del verificador, no del medio.**
      *La corrección que NO afloja nada:* exigir **las ocho** y admitir `loading`
      como posible pero no obligatoria, **con el motivo escrito al lado**. La
      lista seguiría fallando si falta cualquiera de las ocho o si aparece
      `locale` o `source`, que es para lo que existe.
      *Lo que sigue sin explicar:* por qué §4.32f **sí** la tenía. Su ISO
      `aa1ac76a…` se borró en §4.35l, así que **aquel arranque no se puede
      reproducir** y no hay a quién preguntárselo.
      *Hecha cuando:* la lista está decidida, el guion la aplica y la casilla
      correspondiente falla en rojo con una pantalla de más — probado, no
      supuesto.
- [x] ~~**Cerrar el eslabón que quedó a medias de §4.40d.**~~ **HECHA el
      2026-08-14** (`MEDICIONES.md` §4.41d). Los 5 conffiles —3 de
      `encina-branding` y 2 de `encina-firefox-native`, leídos de
      `/var/lib/dpkg/status`— **salen de los bytes del `.deb` que viajó en el
      medio**, con el control de que un md5 saboteado se señala; y `encina-meta`,
      con **0** conffiles, es el control natural que explica por qué en §4.40d
      fue el único que cuadró. **La cadena queda atada entera**: los bytes del
      `.deb` → lo que dpkg registró (`.md5sums` **y** `status`) → los ficheros
      que hay en el disco (`dpkg -V`, con su control).
- [ ] **Medir qué puede romper un autorrefresco de `snapd`.** El 2026-08-13 se
      autorrefrescó solo y llevó el Snap de Firefox de rev 7764 a 8753 sin que nadie
      lo pidiera. No rompió nada y está medido, **pero nadie lo controla**: la
      máquina del producto se actualiza sola cuando le parece.
- [ ] **Un agente no sabe pulsar un botón del invitado.** Cinco vías descartadas y
      medidas (`MEDICIONES.md` §4.35i). Mientras no haya una sexta, toda casilla
      `[OJOS]` que exija pulsar necesita una mano — y eso hay que tenerlo en cuenta
      **al escribir la casilla**, no al llegar a ella.
- [ ] **Hierro AMD: el saludador nace sobre `simpledrm` y muere al llegar `amdgpu`.**
      Nueva el 2026-08-23, del Acer Aspire ES1-524 (`MEDICIONES.md` §4.70b,
      enmienda): 0 de 5 arranques con saludador, y 3 de 3 con
      `echo amdgpu > /etc/modules-load.d/amdgpu.conf`. Tres capas, ninguna de
      Encina: Ubuntu no mete `amdgpu` en el initrd, el módulo tarda 17 s en
      cargar en ese A9, y mutter 46.2 no sobrevive al cambio de tarjeta en
      caliente. **Es de producto** porque el medio tal cual lo reproduce en
      cualquier portátil AMD parecido y «el primer arranque va y luego nunca» es
      la peor forma de fallar. *Lo que hay que decidir, no arreglar:* dónde vive
      el remedio —no en un paquete `all`, que en arm64 no hay `amdgpu`; quizá
      en el seed por arquitectura, quizá solo en la receta—. ~~*Antes, medir:* el
      experimento 2 (`amdgpu` en `/etc/initramfs-tools/modules`), que quizá no
      cueste los 16 s de GDM que cuesta el 1; y por qué tarda 17 s.~~ **MEDIDOS LOS TRES la misma noche (§4.70f): el initrd es el peor —Plymouth a los 20 s—, y el que no nombra hardware es un drop-in de `gdm.service` con `After=systemd-udev-settle.service`, 3 de 3.** **DECISIÓN DE JORGE, 2026-08-23 (noche): se usa el 3 —el drop-in de `gdm.service`— mientras mutter siga roto**, porque el fallo es de mutter y el 3 es el único que no apuesta por un hardware. Lo que queda: ~~**(1)** medir su coste en el banco arm64 —`udev-settle` espera a todo, con 120 s de tope—~~ **(1) MEDIDO el 2026-08-23 (noche), `MEDICIONES.md` §4.71: el coste en arm64 es CERO** —`udev-settle` termina a los 1,1 s y `Started gdm` queda en 1,97–2,05 s con el drop-in contra 2,05–2,14 sin él, 3 y 3, saludador a los 12,42 s en los seis, 0 aserciones; control: quitado el fichero, la unidad no corre—. El precio que sí tiene es el aviso literal `systemd-udev-settle.service is deprecated. Please fix gdm.service not to pull it in` una vez por arranque. `[OMIT]` el negativo del tope de 120 s: ningún dispositivo de la VM deja de asentar. **Siguiente, no hecho:** el fichero entra en `encina-branding` como conffile, con ese aviso citado como porqué y su casilla en `AGENTS.md`; y ~~**(2)** dónde vive (branding / paquete nuevo)~~ **(2) DECIDIDO el mismo día: vive en `encina-branding`**, que ya es dueño de lo que se ve al arrancar —Plymouth y el dconf de GDM— y cuyo `postinst` ya toca el arranque; la receta del hierro lo lleva ya. El día que mutter se arregle arriba, el fichero sobra y se quita con su fecha.
      *Hecha cuando:* una instalación **limpia** desde el medio en un AMD
      arranca tres veces seguidas con saludador sin que nadie toque la máquina,
      o la receta dice con esas palabras que hay que tocarla.

- [ ] **El verificador no sabe que un humano vuelve atrás.** Del Acer, 2026-08-23
      (`MEDICIONES.md` §4.70e): `verificar-instalacion.sh` compara las etapas de
      `telemetry` como lista exacta y dio `[FALLO]` porque identity, timezone y
      confirm aparecían dos veces — Jorge volvió atrás desde la confirmación.
      En la VM nunca pasó porque nadie navegaba. *Arreglo:* comparar el conjunto
      y decir aparte las repetidas como `[DATO]`, con el control de que una etapa
      que FALTE siga dando rojo. Y `--visibles` en amd64 son **28**, porque Ubuntu
      siembra `firmware-updater` ahí: la receta del hierro lo tiene que decir.
      *Hecha cuando:* el mismo `telemetry` del Acer da verde y uno con una etapa
      quitada da rojo.

- [ ] **DNIe con lector** (`opensc`, PKCS#11). Incremento futuro, no deuda.
- [ ] **Chrome y Chromium.** No se han medido; hoy el perímetro dice Firefox.
