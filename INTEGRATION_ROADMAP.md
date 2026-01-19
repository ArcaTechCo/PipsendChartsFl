# 📊 Roadmap de Integración: Indicadores y Herramientas de Dibujo

**Proyecto:** Pipsend Charts Flutter  
**Fecha de Inicio:** 18 de Enero, 2026  
**Estado:** En Planificación

---

## 📈 Resumen Ejecutivo

### Objetivo
Integrar **12 indicadores técnicos** y **14 herramientas de dibujo interactivas** en la librería Flutter de gráficos de trading.

### Estado Global
- **Indicadores:** 12/12 ✅ (100% completo) 🎉
- **Herramientas:** 14/14 ✅ (100% completo) 🎉
- **Total:** 26/26 ✅ (100% completo) 🎉

---

## 🎯 Indicadores Técnicos (12 Total)

### ✅ YA Implementados (9/12)

| # | Indicador | Tipo | Archivo | Estado |
|---|-----------|------|---------|--------|
| 1 | **SMA** | Tendencia | `sma_indicator.dart` | ✅ Completo |
| 2 | **EMA** | Tendencia | `ema_indicator.dart` | ✅ Completo |
| 4 | **Bollinger Bands** | Volatilidad | `bollinger_bands_indicator.dart` | ✅ Completo |
| 5 | **ATR** | Volatilidad | `atr_indicator.dart` | ✅ Completo |
| 6 | **RSI** | Momentum | `rsi_indicator.dart` | ✅ Completo |
| 7 | **MACD** | Momentum | `macd_indicator.dart` | ✅ Completo |
| 8 | **Stochastic** | Momentum | `stochastic_indicator.dart` | ✅ Completo |
| 9 | **Volume** | Volumen | Built-in en chart | ✅ Completo |
| 10 | **OBV** | Volumen | `obv_indicator.dart` | ✅ Completo |

### ❌ PENDIENTES de Implementar (3/12)

| # | Indicador | Tipo | Complejidad | Prioridad | Estado |
|---|-----------|------|-------------|-----------|--------|
| 3 | **WMA** | Tendencia | 🟢 Baja | 🔴 Alta | ✅ Completo |
| 11 | **Volume Profile** | Volumen | 🔴 Alta | 🟡 Media | ✅ Completo |
| 12 | **Trading Sessions** | Especializado | 🟡 Media | 🟡 Media | ✅ Completo |

#### Detalles de Indicadores Pendientes

**3. WMA (Weighted Moving Average)**
- **Función:** Media móvil ponderada con pesos lineales
- **Características:**
  - Período configurable (default: 20)
  - Peso lineal decreciente hacia atrás
  - Balance entre SMA y EMA
- **Implementación:** Extender clase `Indicator`, panel overlay
- **Estimación:** 2-3 horas

**11. Volume Profile**
- **Función:** Distribución de volumen por niveles de precio
- **Características:**
  - Histograma horizontal por precio
  - POC (Point of Control) - precio con mayor volumen
  - Value Area (70% del volumen)
  - Bins configurables (default: 24)
- **Implementación:** Panel lateral, cálculos complejos de agregación
- **Estimación:** 1-2 días

**12. Trading Sessions (Forex)**
- **Función:** Visualiza sesiones de trading principales
- **Características:**
  - Tokyo (00:00-09:00 UTC) - Naranja
  - London (08:00-17:00 UTC) - Azul
  - New York (13:00-22:00 UTC) - Verde
  - Overlaps en morado
  - Rectángulos semi-transparentes
- **Implementación:** Overlay con zonas de tiempo
- **Estimación:** 4-6 horas

---

## 🎨 Herramientas de Dibujo (14 Total)

### ✅ YA Implementadas (4/14)

| # | Herramienta | Categoría | Archivo | Estado |
|---|-------------|-----------|---------|--------|
| 3 | **Fibonacci Retracement** | Fibonacci | `fibonacci_retracement.dart` | ✅ Completo |
| 6 | **Trend Line** | Líneas | `trend_line.dart` | ✅ Completo |
| 7 | **Horizontal Line** | Líneas | `trading_line.dart` | ✅ Completo |
| 10 | **Rectangle Tool** | Formas | `price_zone.dart` | ✅ Completo |

### ❌ PENDIENTES de Implementar (10/14)

#### 🔴 Alta Prioridad - Trading Essentials (2)

| # | Herramienta | Complejidad | Estimación | Estado |
|---|-------------|-------------|------------|--------|
| 1 | **Position Tool** | 🟡 Media | 6-8 horas | ⏳ Pendiente |
| 2 | **Ruler Tool** | 🟢 Baja | 3-4 horas | ⏳ Pendiente |

#### 🟡 Media Prioridad - Análisis Técnico (4)

| # | Herramienta | Complejidad | Estimación | Estado |
|---|-------------|-------------|------------|--------|
| 4 | **Fibonacci Extension** | 🟡 Media | 6-8 horas | ⏳ Pendiente |
| 5 | **Fibonacci Fan** | 🟡 Media | 6-8 horas | ⏳ Pendiente |
| 8 | **Vertical Line** | 🟢 Baja | 2-3 horas | ⏳ Pendiente |
| 9 | **Arrow Tool** | 🟢 Baja | 4-5 horas | ⏳ Pendiente |

#### 🟢 Baja Prioridad - Anotaciones (4)

| # | Herramienta | Complejidad | Estimación | Estado |
|---|-------------|-------------|------------|--------|
| 11 | **Circle/Ellipse Tool** | 🟡 Media | 5-6 horas | ⏳ Pendiente |
| 12 | **Gantt/Timeline Tool** | 🔴 Alta | 1-2 días | ⏳ Pendiente |
| 13 | **Brush Tool** | 🔴 Alta | 1-2 días | ⏳ Pendiente |
| 14 | **Text/Annotations Tool** | 🟡 Media | 6-8 horas | ⏳ Pendiente |

#### Detalles de Herramientas Pendientes

**1. Position Tool**
- **Función:** Marca posiciones de trading con Entry/SL/TP
- **Características:**
  - 3 líneas horizontales (Entry, Stop Loss, Take Profit)
  - Cálculo automático de Risk:Reward ratio
  - Etiquetas con precios y distancias en pips
  - Drag & drop individual por línea
  - Colores personalizables
- **Implementación:** Extender `ChartOverlay`, manager dedicado

**2. Ruler Tool**
- **Función:** Mide distancia entre dos puntos
- **Características:**
  - Medición de precio (diferencia absoluta)
  - Medición de porcentaje (%)
  - Medición en pips (para Forex)
  - Medición de tiempo (barras/velas)
  - Línea con etiquetas informativas
- **Implementación:** Overlay simple con 2 puntos

**4. Fibonacci Extension**
- **Función:** Proyecta niveles de extensión Fibonacci
- **Características:**
  - 3 puntos de referencia (A, B, C)
  - Niveles: 0%, 61.8%, 100%, 161.8%, 261.8%, 423.6%
  - Proyección hacia adelante
  - Útil para objetivos de precio
- **Implementación:** Similar a Fibonacci Retracement pero con 3 puntos

**5. Fibonacci Fan**
- **Función:** Líneas de tendencia en ángulos Fibonacci
- **Características:**
  - Líneas diagonales desde punto de origen
  - Ángulos: 23.6%, 38.2%, 50%, 61.8%
  - Soportes/resistencias dinámicos
- **Implementación:** Overlay con líneas radiales

**8. Vertical Line**
- **Función:** Marca eventos temporales
- **Características:**
  - Línea vertical en timestamp específico
  - Etiqueta de texto personalizable
  - Color y estilo configurables
  - Se extiende por todo el alto del gráfico
- **Implementación:** Similar a TradingLine pero vertical

**9. Arrow Tool**
- **Función:** Flechas direccionales para anotaciones
- **Características:**
  - Línea con punta de flecha
  - Múltiples puntos de control
  - Cabeza de flecha configurable
  - Color y grosor personalizables
- **Implementación:** Path con transformaciones

**11. Circle/Ellipse Tool**
- **Función:** Formas circulares para destacar áreas
- **Características:**
  - Forma circular/elíptica
  - 2 puntos de control (centro y radio)
  - Relleno y borde personalizables
  - Útil para patrones de cabeza y hombros
- **Implementación:** Canvas.drawOval con transformaciones

**12. Gantt/Timeline Tool**
- **Función:** Líneas de tiempo horizontales con segmentos
- **Características:**
  - Múltiples segmentos horizontales
  - Diferentes niveles de precio
  - Colores por segmento
  - Etiquetas personalizables
- **Implementación:** Overlay complejo con múltiples rectángulos

**13. Brush Tool**
- **Función:** Dibujo libre a mano alzada
- **Características:**
  - Dibujo libre con mouse/touch
  - Suavizado de líneas opcional (Catmull-Rom spline)
  - Color y grosor personalizables
  - Múltiples trazos independientes
  - Borrado individual de trazos
- **Implementación:** Path builder con gesture detector

**14. Text/Annotations Tool**
- **Función:** Anotaciones de texto en el gráfico
- **Características:**
  - Texto personalizable
  - Posicionamiento en precio y tiempo
  - Tamaño y color de fuente configurables
  - Fondo opcional
  - Edición inline
  - Drag & drop para reposicionar
- **Implementación:** TextPainter con overlay interactivo

---

## 🏗️ Arquitectura de Implementación

### Estructura de Archivos Propuesta

```
lib/src/
├── indicators/
│   ├── wma_indicator.dart              ← NUEVO
│   ├── volume_profile_indicator.dart   ← NUEVO
│   └── trading_sessions_indicator.dart ← NUEVO
│
└── overlays/
    ├── tools/                          ← NUEVA CARPETA
    │   ├── position_tool.dart          ← NUEVO
    │   ├── position_tool_manager.dart  ← NUEVO
    │   ├── ruler_tool.dart             ← NUEVO
    │   ├── ruler_tool_manager.dart     ← NUEVO
    │   ├── arrow_tool.dart             ← NUEVO
    │   ├── vertical_line.dart          ← NUEVO
    │   ├── circle_tool.dart            ← NUEVO
    │   ├── text_annotation.dart        ← NUEVO
    │   ├── brush_tool.dart             ← NUEVO
    │   └── gantt_tool.dart             ← NUEVO
    │
    └── fibonacci/
        ├── fibonacci_extension.dart    ← NUEVO
        └── fibonacci_fan.dart          ← NUEVO
```

### Patrones de Diseño

**Para Indicadores:**
```dart
class WMAIndicator extends Indicator {
  final int period;
  
  WMAIndicator({
    String? id,
    this.period = 20,
    WMAStyle? style,
  }) : super(
    id: id ?? 'wma_$period',
    panel: IndicatorPanel.overlay(),
    style: style ?? WMAStyle(),
  );
  
  @override
  List<IndicatorValue> calculate(List<CandleData> data) {
    // Implementación del cálculo WMA
  }
  
  @override
  void paint(Canvas canvas, PainterParams params, List<IndicatorValue> values) {
    // Rendering en canvas
  }
}
```

**Para Herramientas de Dibujo:**
```dart
class PositionTool extends ChartOverlay {
  final double entryPrice;
  final double stopLossPrice;
  final double takeProfitPrice;
  final PositionToolOptions options;
  
  double get riskRewardRatio => 
    (takeProfitPrice - entryPrice).abs() / 
    (entryPrice - stopLossPrice).abs();
  
  @override
  void paint(Canvas canvas, PainterParams params, {bool isBeingDragged = false}) {
    // Dibujar 3 líneas + etiquetas R:R
  }
  
  @override
  bool hitTest(Offset position, PainterParams params) {
    // Detección de toque para drag & drop
  }
}
```

---

## 📅 Plan de Implementación por Fases

### **Fase 1: Indicadores Faltantes** ✅ **COMPLETADA**
**Duración Real:** ~2 horas  
**Prioridad:** Alta

- [x] **WMA Indicator** (2-3 horas) ✅ **COMPLETADO**
  - ✅ Implementar cálculo de media móvil ponderada
  - ✅ Crear WMAStyle
  - ✅ Integrado en ejemplo con toggle
  - ✅ Exportado en librería principal
  
- [x] **Trading Sessions Indicator** (4-6 horas) ✅ **COMPLETADO**
  - ✅ Implementar zonas de tiempo para Tokyo/London/NY
  - ✅ Detectar overlaps
  - ✅ Configuración de colores por sesión
  - ✅ Integrado en ejemplo con toggle
  - ✅ Exportado en librería principal
  
- [x] **Volume Profile Indicator** (1-2 días) ✅ **COMPLETADO**
  - ✅ Implementar agregación de volumen por precio
  - ✅ Calcular POC y Value Area
  - ✅ Rendering de histograma horizontal
  - ✅ Optimización de performance
  - ✅ Integrado en ejemplo con toggle
  - ✅ Exportado en librería principal

### **Fase 2: Herramientas de Trading Esenciales** ✅ **COMPLETADA**
**Duración Real:** ~3 horas  
**Prioridad:** Alta

- [x] **Position Tool** (6-8 horas) ✅ **COMPLETADO**
  - ✅ Implementar 3 líneas (Entry/SL/TP)
  - ✅ Cálculo automático de R:R
  - ✅ Sistema de hit testing
  - ✅ Zonas de profit/risk visuales
  - ✅ Integrado en ejemplo con FAB
  - ✅ Exportado en librería principal
  
- [x] **Ruler Tool** (3-4 horas) ✅ **COMPLETADO**
  - ✅ Implementar medición de precio/pips/tiempo
  - ✅ Etiquetas informativas con múltiples métricas
  - ✅ Sistema de hit testing
  - ✅ Arrow heads en los extremos
  - ✅ Integrado en ejemplo con FAB
  - ✅ Exportado en librería principal
  
- [x] **Vertical Line** (2-3 horas) ✅ **COMPLETADO**
  - ✅ Línea vertical en timestamp
  - ✅ Etiquetas personalizables
  - ✅ Líneas sólidas y punteadas
  - ✅ Integrado en ejemplo con FAB
  - ✅ Exportado en librería principal

### **Fase 3: Fibonacci Avanzado** ✅ **COMPLETADA**
**Duración Estimada:** 2-3 días  
**Prioridad:** Media

- [x] **Fibonacci Extension** (6-8 horas) ✅ **COMPLETADO**
  - ✅ Implementar sistema de 3 puntos (A, B, C)
  - ✅ Calcular niveles de extensión (0%, 38.2%, 61.8%, 100%, 127.2%, 161.8%, 200%, 261.8%)
  - ✅ Proyección hacia adelante desde punto C
  - ✅ Marcadores de puntos A, B, C con labels
  - ✅ Líneas conectoras A-B-C
  - ✅ Integrado en ejemplo con FAB
  - ✅ Exportado en librería principal
  
- [x] **Fibonacci Fan** (4-6 horas) ✅ **COMPLETADO**
  - ✅ Implementar líneas radiales desde pivot
  - ✅ Calcular ángulos Fibonacci (38.2%, 50%, 61.8%)
  - ✅ Proyección desde punto pivot con clipping
  - ✅ Marcadores de puntos Start y End
  - ✅ Labels de porcentaje en cada línea
  - ✅ Integrado en ejemplo con FAB
  - ✅ Exportado en librería principal

### **Fase 4: Herramientas de Formas** ✅ **COMPLETADA**
**Duración Estimada:** 2 días  
**Prioridad:** Media

- [x] **Arrow Tool** (4-5 horas) ✅ **COMPLETADO**
  - ✅ Línea con punta de flecha personalizable
  - ✅ Dos puntos de control (inicio y fin)
  - ✅ Configuración de cabeza de flecha (tamaño, ángulo, relleno)
  - ✅ Drag de puntos con preview en tiempo real
  - ✅ Integrado en ejemplo con FAB
  - ✅ Exportado en librería principal
  
- [x] **Circle Tool** (3-4 horas) ✅ **COMPLETADO**
  - ✅ Círculo/elipse desde centro con radio
  - ✅ Radio ajustable en tiempo y precio
  - ✅ Relleno opcional con opacidad configurable
  - ✅ Drag de centro y radio con preview
  - ✅ Integrado en ejemplo con FAB
  - ✅ Exportado en librería principal

### **Fase 5: Anotaciones Avanzadas** ✅ **COMPLETADA**
**Duración Estimada:** 4-5 días  
**Prioridad:** Baja

- [x] **Text/Annotations Tool** (6-8 horas) ✅ **COMPLETADO**
  - ✅ TextPainter con overlay y estilos personalizables
  - ✅ Alineación horizontal y vertical configurable
  - ✅ Drag & drop funcional con preview
  - ✅ Fondo opcional con borde y padding
  - ✅ Integrado en ejemplo con FAB
  - ✅ Exportado en librería principal
  
- [x] **Brush/Freehand Tool** (8-10 horas) ✅ **COMPLETADO**
  - ✅ Path drawing con múltiples puntos
  - ✅ Smooth curves con bezier
  - ✅ Color y stroke width personalizables
  - ✅ Hit testing en segmentos de línea
  - ✅ Integrado en ejemplo con FAB
  - ✅ Exportado en librería principal
  
- [x] **Gantt Chart** (6-8 horas) ✅ **COMPLETADO**
  - ✅ Barras horizontales con período de tiempo
  - ✅ Labels personalizables con fondo
  - ✅ Colores y estilos configurables
  - ✅ Drag & resize de handles (start/end)
  - ✅ Integrado en ejemplo con FAB
  - ✅ Exportado en librería principal
## 🎯 Criterios de Aceptación

### Para Indicadores
- ✅ Cálculo matemático correcto y validado
- ✅ Rendering optimizado (60 FPS con 1000+ velas)
- ✅ Configuración flexible de parámetros
- ✅ Colores personalizables
- ✅ Cache de cálculos implementado
- ✅ Tests unitarios con cobertura >80%
- ✅ Documentación completa con ejemplos

### Para Herramientas de Dibujo
- ✅ Sistema de drag & drop funcional
- ✅ Hit testing preciso
- ✅ Rendering suave y responsivo
- ✅ Persistencia de estado
- ✅ Manager con eventos
- ✅ API consistente con herramientas existentes
- ✅ Tests de interacción
- ✅ Documentación con GIFs demostrativos

---

## 📊 Métricas de Progreso

### Indicadores
- **Completados:** 12/12 (100%) ✅ **FASE COMPLETA**
- **En Progreso:** 0/12 (0%)
- **Pendientes:** 0/12 (0%)

### Herramientas de Dibujo
- **Completadas:** 14/14 (100%) ✅ **FASE COMPLETA**
- **En Progreso:** 0/14 (0%)
- **Pendientes:** 0/14 (0%)

### Total General
- **Completado:** 26/26 (100%) ✅ **PROYECTO COMPLETO**
- **En Progreso:** 0/26 (0%)
- **Pendiente:** 0/26 (0%)

---

## 🔄 Historial de Cambios

| Fecha | Cambio | Responsable |
|-------|--------|-------------|
| 2026-01-18 | Documento inicial creado | Carlos Aroca |
| 2026-01-18 | ✅ WMA Indicator completado e integrado | Carlos Aroca |
| 2026-01-18 | ✅ Trading Sessions Indicator completado e integrado | Carlos Aroca |
| 2026-01-18 | ✅ Volume Profile Indicator completado e integrado | Carlos Aroca |
| 2026-01-18 | 🎉 **FASE 1 COMPLETADA** - Todos los indicadores implementados | Carlos Aroca |
| 2026-01-18 | ✅ Position Tool completado e integrado | Carlos Aroca |
| 2026-01-18 | ✅ Ruler Tool completado e integrado | Carlos Aroca |
| 2026-01-18 | ✅ Vertical Line completado e integrado | Carlos Aroca |
| 2026-01-18 | 🎉 **FASE 2 COMPLETADA** - Herramientas de Trading Esenciales | Carlos Aroca |
| 2026-01-18 | ✅ Soporte de drag añadido a Position/Ruler/VerticalLine en InteractiveChart | Carlos Aroca |
| 2026-01-18 | 🔧 RulerTool reescrito completamente basado en TrendLine con handles funcionales | Carlos Aroca |
| 2026-01-18 | ✅ Fibonacci Extension completado e integrado | Carlos Aroca |
| 2026-01-18 | ✅ Fibonacci Fan completado e integrado | Carlos Aroca |
| 2026-01-18 | 🎉 **FASE 3 COMPLETADA** - Fibonacci Avanzado | Carlos Aroca |
| 2026-01-18 | ✅ Arrow Tool completado e integrado | Carlos Aroca |
| 2026-01-18 | ✅ Circle Tool completado e integrado | Carlos Aroca |
| 2026-01-18 | 🎉 **FASE 4 COMPLETADA** - Herramientas de Formas | Carlos Aroca |
| 2026-01-18 | ✅ Text Tool completado e integrado | Carlos Aroca |
| 2026-01-18 | ✅ Brush Tool completado e integrado | Carlos Aroca |
| 2026-01-18 | ✅ Gantt Tool completado e integrado | Carlos Aroca |
| 2026-01-18 | 🎉 **FASE 5 COMPLETADA** - Anotaciones Avanzadas | Carlos Aroca |
| 2026-01-18 | 🎊 **PROYECTO 100% COMPLETADO** - Todas las herramientas implementadas | Carlos Aroca |
| | | |

---

## 📝 Notas y Consideraciones

### Optimización de Performance
- Implementar cache agresivo en indicadores complejos (Volume Profile)
- Usar `shouldRepaint` eficiente en todos los overlays
- Lazy loading de cálculos pesados
- Considerar Web Workers para cálculos en background (web)

### Compatibilidad
- Mantener API consistente con versión actual (v1.0.7)
- Asegurar compatibilidad con todas las plataformas (iOS, Android, Web, Desktop)
- Tests en diferentes tamaños de pantalla

### Documentación
- Crear ejemplos interactivos para cada indicador/herramienta
- GIFs demostrativos en README
- Guías de uso detalladas
- API reference completa

### Testing
- Tests unitarios para cálculos matemáticos
- Tests de integración para rendering
- Tests de interacción para drag & drop
- Performance benchmarks

---

## 🚀 Próximos Pasos Inmediatos

1. **Revisar y aprobar roadmap** con el equipo
2. **Priorizar fases** según necesidades del negocio
3. **Asignar recursos** para cada fase
4. **Iniciar Fase 1** con WMA Indicator
5. **Configurar CI/CD** para tests automáticos

---

**Última Actualización:** 18 de Enero, 2026  
**Próxima Revisión:** TBD  
**Responsable:** Carlos Aroca
