# Especificación de features para la versión Web

Documento **funcional / de UX** (no de código) de las mejoras del gráfico y del modo Replay, pensado para llevarlas a la versión **web**. Describe *cómo debe comportarse* cada feature, tomando como referencia **TradingView web**.

> **Nota importante sobre plataforma.** Estas features nacieron en móvil (gestos táctiles). En web el dispositivo principal es el **mouse/trackpad + teclado**, así que cada sección describe primero el comportamiento **desktop (mouse)** y luego el equivalente **táctil** (pantallas táctiles / tablet). Donde el gesto móvil no aplica en web, se indica la adaptación.

---

## Convenciones

| Concepto | Móvil (táctil) | Web (mouse) |
|---|---|---|
| "Apuntar" a un punto | tocar / arrastrar el dedo | mover el cursor (hover) |
| "Confirmar" | tap / soltar | click |
| "Arrastrar" | drag con el dedo | click sostenido + mover |
| Área del eje de precios | franja derecha con las etiquetas de precio | igual |
| Área del eje de tiempo | franja inferior con las fechas | igual |

---

## 1. Crosshair (mira) tipo TradingView

### Objetivo
Una mira que ayuda a leer con precisión **qué precio** y **en qué fecha/hora** está el cursor sobre el gráfico, resaltando ambos valores en los ejes.

### Comportamiento en Web (mouse) — principal
- El crosshair **sigue el cursor** mientras el mouse está sobre el área del gráfico (hover). No hace falta hacer click ni arrastrar: aparece al entrar el cursor y se oculta al salir.
- Se compone de:
  - Una **línea vertical** punteada que pasa por el centro de la vela bajo el cursor.
  - Una **línea horizontal** punteada a la altura exacta del cursor.
  - Una **etiqueta de precio** resaltada en el **eje derecho**, alineada con la línea horizontal.
  - Una **etiqueta de fecha/hora** resaltada en el **eje inferior**, centrada bajo la línea vertical.
- La línea vertical **se ancla al centro de la vela** más cercana (snap horizontal), como en TradingView; la horizontal sigue el cursor libremente en el eje de precio.
- Las etiquetas tienen **fondo opaco** (no translúcido) y el **texto se auto-contrasta** (claro u oscuro según el color de fondo) para que siempre se lean.

### Comportamiento táctil (tablet / pantallas táctiles)
Como no hay "hover", el crosshair funciona en **modo persistente**:
- Está **siempre visible** desde el inicio, en una posición de reposo por defecto (centro del área visible, sobre la última vela).
- Se **arrastra de forma relativa**: al tocar y arrastrar, el crosshair se mueve **según el desplazamiento del dedo** desde su posición actual — **no** salta al punto tocado. Esto lo hace preciso y evita que el dedo tape el objetivo.
- Un tap simple no lo mueve; solo el arrastre.

### Detalles visuales
- Líneas punteadas (patrón corto, ~5px trazo / 3px espacio).
- Color/estilo configurable; por defecto en el estilo "dashed" tipo TradingView.
- La etiqueta de fecha usa un formato completo (día, mes, año, hora), independientemente de qué tan alejado esté el zoom del eje inferior.

### Estados
- **Inactivo (web):** cursor fuera del gráfico → sin crosshair.
- **Activo (web):** cursor dentro → crosshair siguiendo el mouse.
- **Persistente (táctil):** siempre visible; permanece donde el usuario lo dejó.

### Casos borde
- Cerca de los bordes, las etiquetas de los ejes se **recortan/clampan** para no salirse del área visible.
- El panel flotante con el OHLC (open/high/low/close) del modo táctil **no** se muestra en el modo persistente; solo las líneas y las etiquetas de los ejes (menos ruido visual). En web se puede mostrar el OHLC en una **leyenda superior fija** (estilo TradingView), no como panel flotante.

---

## 2. Activar / desactivar el crosshair

### Objetivo
Poder encender o apagar el modo crosshair sin depender de un botón fijo.

### Web (mouse)
- En web el crosshair de hover está **siempre disponible**; no necesita un toggle explícito. Opcionalmente, un botón/menú puede alternar entre "modo crosshair" y "modo cursor normal" (como el selector de cursor de TradingView: Cross / Dot / Arrow).

### Táctil
- Un **long-press** (mantener presionado ~400 ms) sobre un área **vacía** del gráfico **activa o desactiva** el crosshair persistente.
- Importante: el long-press **no debe activarse** si el usuario está presionando sobre una **herramienta de dibujo** (para redimensionar/mover una zona, línea, etc.). Es decir, el toggle solo ocurre en zona vacía; sobre un dibujo, ese gesto pertenece a la edición del dibujo.

---

## 3. Modo de colocación de herramientas de dibujo (drawing tools)

### Objetivo
Crear herramientas (zonas de oferta/demanda, líneas de tendencia, Fibonacci, flechas, etc.) **colocando los puntos con precisión**, en lugar de que aparezcan en una posición por defecto que luego hay que arrastrar. Igual que TradingView: eliges la herramienta y el chart entra en un **modo de colocación** con una mira interactiva.

### Flujo general
1. El usuario elige una herramienta del panel.
2. El gráfico entra en **modo colocación**: se muestra una **mira azul** (líneas azules punteadas + un **punto en el centro**) que indica que es interactivo. Se suspende el pan/zoom normal mientras dura la colocación.
3. El usuario coloca **N puntos** (según la herramienta). Cada punto se fija con:
   - **Web:** un **click** en la posición deseada. Entre clicks, la mira sigue el cursor y se ve un **preview en vivo** del dibujo.
   - **Táctil:** un **tap** (o soltar tras arrastrar la mira). Cada tap fija un punto.
4. Al fijar el primer punto, aparece un **marcador** y un **preview en vivo** (rectángulo o línea) desde ese punto hasta el cursor/mira.
5. Al fijar el último punto, se **crea el dibujo real** y la mira azul **desaparece**. El dibujo queda editable (arrastrar/redimensionar) como siempre.

### Cantidad de puntos y preview por herramienta
| Herramienta | Puntos | Preview mientras se coloca |
|---|---|---|
| Zona de Demanda / Oferta | 2 (esquinas opuestas) | Rectángulo |
| Línea de tendencia | 2 | Línea |
| Flecha | 2 | Línea |
| Regla (medición) | 2 | Línea |
| Fibonacci (retroceso) | 2 | Línea |
| Fibonacci Fan | 2 | Línea |
| Fibonacci Extension | 3 (A → B → C) | Línea |
| Círculo / Elipse | 2 (caja contenedora) | Rectángulo |
| Gantt (rango de tiempo) | 2 | Rectángulo |
| Línea vertical | 1 (posición en el tiempo) | — |
| Texto / Nota | 1 (posición) | — |
| Posición (entry/SL/TP) | 1 (entry; SL/TP con offsets por defecto) | — |

### Reglas / casos borde
- **Un solo punto por gesto:** un mismo click/tap fija **exactamente un** punto (no debe colocar dos de un solo gesto). Se necesitan clicks/taps separados para definir el dibujo.
- **Tamaño mínimo:** si el dibujo requiere área (zonas, fibonacci) y los dos puntos caen casi en el mismo precio/tiempo, se fuerza un **tamaño mínimo** para que el dibujo sea válido y agarrable (no degenerado). Referencia: ~2% del rango de precios visible.
- **Cancelar:** elegir otra herramienta, presionar `Esc` (web), o deseleccionar la herramienta cancela la colocación en curso.
- La mira de colocación muestra también las etiquetas de precio/fecha (en azul) para colocar con precisión leyendo los valores.

---

## 4. Escalado del eje de precios (eje Y)

### Objetivo
Comprimir/expandir la escala de precios (zoom vertical) directamente desde el eje, como en TradingView.

### Comportamiento
- **Arrastrar sobre la escala de precios** (la franja derecha con las etiquetas) escala el eje Y:
  - Arrastrar **hacia abajo** → **comprime** (se ve **más** rango de precio / zoom out).
  - Arrastrar **hacia arriba** → **expande** (se ve **menos** rango / zoom in).
  - Web: click sostenido sobre el eje + mover verticalmente. Táctil: un dedo arrastrando sobre el eje.
- El escalado es **relativo** al punto donde se empezó a arrastrar; el centro de la vista se mantiene.
- **Doble click / doble tap** sobre la escala de precios → **reset** a *auto-fit* (la escala vuelve a encajar automáticamente las velas visibles).
- Debe **priorizar** este gesto sobre el pan/zoom general: solo se activa cuando el arrastre **empieza dentro de la franja del eje de precios**; en el resto del gráfico el arrastre hace pan/zoom normal.
- Una vez que el usuario escala manualmente, la escala deja de auto-ajustarse hasta el reset (doble click).

### Equivalente para el eje de tiempo (opcional, futuro)
El mismo patrón aplica al **eje de tiempo** (franja inferior): arrastrar horizontalmente sobre él comprime/expande el eje X. (Aún no implementado; se menciona por paridad con TradingView.)

---

## 5. Densidad de etiquetas de precio

### Objetivo
Mostrar suficientes niveles de precio en el eje Y para leer con comodidad, sin quedar demasiado espaciados.

### Comportamiento
- La cantidad de etiquetas de precio es **adaptativa según la altura** del gráfico: aproximadamente **una etiqueta cada ~55px**, hasta un máximo de ~20.
- La **grilla horizontal** se alinea con estas etiquetas (misma cantidad), para que líneas y precios coincidan.
- Configurable: se puede fijar un número exacto de etiquetas (rango recomendado 3–20).

---

## 6. Modo Replay

### Objetivo
Reproducir el histórico "como si estuviera pasando en vivo", avanzando vela a vela o tick a tick, para practicar y analizar. Referencia: **Bar Replay** de TradingView.

### Comportamiento
- **Playhead** (línea de reproducción) marca el punto actual; lo que está a la derecha (futuro) se **oscurece/oculta**. El playhead es **arrastrable** para saltar a otro punto (scrubbing).
- **Modos de avance:**
  - **Bar (barra):** cada paso avanza una vela completa.
  - **Tick:** anima la vela en formación (progreso sub-vela), como si llegaran cotizaciones en tiempo real. **El modo Tick es el predeterminado.**
- **Controles de transporte:** play/pausa, paso adelante/atrás, y **velocidad** (½×, 1×, 2×, 5×…).
- **Selección del punto de inicio:** el usuario elige desde qué fecha/momento arranca el replay (recorte del histórico).
- **Barra de tiempo / scrubber** con un minimapa del rango cargado para navegar rápido.

### UX / layout (aprendizajes de la app)
- Los controles inferiores deben respetar el **área segura** del sistema (barras de navegación, notch): en web esto se traduce en no pegar los controles al borde y dejar padding suficiente.
- La info del replay (badge "REPLAY", símbolo · timeframe, y **fecha/hora del punto actual**) va en una **barra superior compacta**, con un botón de **volver/salir** al lado. Nada de controles de trading (compra/venta) en modo replay.
- El acceso a **indicadores y herramientas de dibujo** en replay debe ser **el mismo** que en el gráfico normal (mismo panel, mismas herramientas), para no tener funciones a medias entre pantallas.

---

## 7. Paridad general con TradingView (checklist)

- [ ] Crosshair sigue el mouse (hover) en desktop; persistente y arrastrable en táctil.
- [ ] Línea vertical del crosshair anclada al centro de la vela; horizontal libre.
- [ ] Etiquetas de precio (derecha) y fecha (abajo) resaltadas, con fondo opaco y texto legible.
- [ ] Leyenda OHLC superior fija (en vez de panel flotante) para desktop.
- [ ] Selector de tipo de cursor (Cross / Dot / Arrow) — opcional.
- [ ] Herramientas de dibujo con **modo de colocación** (click para fijar puntos + preview en vivo).
- [ ] Tamaño mínimo y cancelación (Esc) al colocar.
- [ ] Escala del eje Y arrastrando sobre el eje; doble click para auto-fit.
- [ ] (Opcional) Escala del eje X arrastrando sobre el eje de tiempo.
- [ ] Densidad de precios adaptativa.
- [ ] Replay con playhead arrastrable, modos Bar/Tick (Tick por defecto), velocidades y punto de inicio configurable.

---

*Este documento describe el comportamiento esperado; la implementación web puede usar la tecnología que prefiera (Canvas, WebGL, librería de charting propia o de terceros), siempre que respete estas interacciones.*
