# 📚 Guía de Integración - PipsendCharts

**Versión:** 1.0.0  
**Fecha:** Enero 2026  
**Autor:** Carlos Aroca

---

## 📋 Tabla de Contenidos

1. [Introducción](#introducción)
2. [Instalación](#instalación)
3. [Indicadores Técnicos (12)](#indicadores-técnicos)
4. [Herramientas de Dibujo (14)](#herramientas-de-dibujo)
5. [Ejemplos de Uso](#ejemplos-de-uso)
6. [Personalización](#personalización)
7. [Mejores Prácticas](#mejores-prácticas)

---

## 🎯 Introducción

PipsendCharts es una librería Flutter completa para gráficos de trading que incluye:
- **12 Indicadores Técnicos** profesionales
- **14 Herramientas de Dibujo** interactivas
- **Drag & Drop** completo con preview en tiempo real
- **Personalización** total de estilos y colores

---

## 📦 Instalación

### 1. Agregar Dependencia

```yaml
dependencies:
  pipsend_charts: ^1.0.0
```

### 2. Importar

```dart
import 'package:pipsend_charts/pipsend_charts.dart';
```

### 3. Uso Básico

```dart
InteractiveChart(
  candles: yourCandleData,
  overlays: [...], // Herramientas de dibujo
  indicators: [...], // Indicadores técnicos
)
```

---

## 📊 Indicadores Técnicos

### 1. SMA (Simple Moving Average)

Media móvil simple para identificar tendencias.

```dart
SMAIndicator(
  period: 20,
  color: Colors.blue,
  strokeWidth: 2.0,
)
```

**Parámetros:**
- `period`: Período de cálculo (default: 20)
- `color`: Color de la línea
- `strokeWidth`: Grosor de la línea

---

### 2. EMA (Exponential Moving Average)

Media móvil exponencial con más peso en datos recientes.

```dart
EMAIndicator(
  period: 12,
  color: Colors.orange,
  strokeWidth: 2.0,
)
```

**Parámetros:**
- `period`: Período de cálculo (default: 12)
- `color`: Color de la línea
- `strokeWidth`: Grosor de la línea

---

### 3. WMA (Weighted Moving Average)

Media móvil ponderada con pesos lineales.

```dart
WMAIndicator(
  period: 20,
  color: Colors.purple,
  strokeWidth: 2.0,
)
```

**Parámetros:**
- `period`: Período de cálculo (default: 20)
- `color`: Color de la línea
- `strokeWidth`: Grosor de la línea

---

### 4. Bollinger Bands

Bandas de volatilidad basadas en desviación estándar.

```dart
BollingerBandsIndicator(
  period: 20,
  standardDeviation: 2.0,
  upperColor: Colors.blue.withOpacity(0.5),
  lowerColor: Colors.blue.withOpacity(0.5),
  middleColor: Colors.blue,
  fillColor: Colors.blue.withOpacity(0.1),
)
```

**Parámetros:**
- `period`: Período para SMA (default: 20)
- `standardDeviation`: Desviaciones estándar (default: 2.0)
- `upperColor`: Color de banda superior
- `lowerColor`: Color de banda inferior
- `middleColor`: Color de línea media
- `fillColor`: Color de relleno entre bandas

---

### 5. ATR (Average True Range)

Indicador de volatilidad que mide el rango promedio.

```dart
ATRIndicator(
  period: 14,
  color: Colors.orange,
  strokeWidth: 2.0,
)
```

**Parámetros:**
- `period`: Período de cálculo (default: 14)
- `color`: Color de la línea
- `strokeWidth`: Grosor de la línea

---

### 6. RSI (Relative Strength Index)

Oscilador de momentum entre 0-100.

```dart
RSIIndicator(
  period: 14,
  overboughtLevel: 70.0,
  oversoldLevel: 30.0,
  color: Colors.purple,
  overboughtColor: Colors.red.withOpacity(0.2),
  oversoldColor: Colors.green.withOpacity(0.2),
)
```

**Parámetros:**
- `period`: Período de cálculo (default: 14)
- `overboughtLevel`: Nivel de sobrecompra (default: 70)
- `oversoldLevel`: Nivel de sobreventa (default: 30)
- `color`: Color de la línea RSI
- `overboughtColor`: Color de zona sobrecompra
- `oversoldColor`: Color de zona sobreventa

---

### 7. MACD

Convergencia/Divergencia de medias móviles.

```dart
MACDIndicator(
  fastPeriod: 12,
  slowPeriod: 26,
  signalPeriod: 9,
  macdColor: Colors.blue,
  signalColor: Colors.red,
  histogramPositiveColor: Colors.green,
  histogramNegativeColor: Colors.red,
)
```

**Parámetros:**
- `fastPeriod`: Período EMA rápida (default: 12)
- `slowPeriod`: Período EMA lenta (default: 26)
- `signalPeriod`: Período línea señal (default: 9)
- `macdColor`: Color línea MACD
- `signalColor`: Color línea señal
- `histogramPositiveColor`: Color histograma positivo
- `histogramNegativeColor`: Color histograma negativo

---

### 8. Stochastic

Oscilador de momentum que compara precio de cierre con rango.

```dart
StochasticIndicator(
  kPeriod: 14,
  dPeriod: 3,
  kColor: Colors.blue,
  dColor: Colors.red,
  overboughtLevel: 80.0,
  oversoldLevel: 20.0,
)
```

**Parámetros:**
- `kPeriod`: Período %K (default: 14)
- `dPeriod`: Período %D (default: 3)
- `kColor`: Color línea %K
- `dColor`: Color línea %D
- `overboughtLevel`: Nivel sobrecompra (default: 80)
- `oversoldLevel`: Nivel sobreventa (default: 20)

---

### 9. Volume

Volumen de trading (built-in en el chart).

```dart
ChartStyle(
  showVolume: true,
  volumeColor: Colors.grey.withOpacity(0.5),
)
```

**Parámetros:**
- `showVolume`: Mostrar/ocultar volumen
- `volumeColor`: Color de las barras de volumen

---

### 10. OBV (On-Balance Volume)

Indicador de volumen acumulativo.

```dart
OBVIndicator(
  color: Colors.orange,
  strokeWidth: 2.0,
)
```

**Parámetros:**
- `color`: Color de la línea
- `strokeWidth`: Grosor de la línea

---

### 11. Volume Profile

Distribución de volumen por niveles de precio.

```dart
VolumeProfileIndicator(
  period: 100,
  bins: 24,
  color: Colors.blue.withOpacity(0.3),
  showPOC: true,
  pocColor: Colors.red,
)
```

**Parámetros:**
- `period`: Número de velas a analizar (default: 100)
- `bins`: Número de niveles de precio (default: 24)
- `color`: Color de las barras horizontales
- `showPOC`: Mostrar Point of Control
- `pocColor`: Color del POC

---

### 12. Trading Sessions

Resalta sesiones de trading (Asia, Europa, América).

```dart
TradingSessionsIndicator(
  showAsian: true,
  showEuropean: true,
  showAmerican: true,
  asianColor: Colors.yellow.withOpacity(0.1),
  europeanColor: Colors.blue.withOpacity(0.1),
  americanColor: Colors.green.withOpacity(0.1),
)
```

**Parámetros:**
- `showAsian`: Mostrar sesión asiática
- `showEuropean`: Mostrar sesión europea
- `showAmerican`: Mostrar sesión americana
- `asianColor`: Color sesión asiática
- `europeanColor`: Color sesión europea
- `americanColor`: Color sesión americana

---

## 🎨 Herramientas de Dibujo

### 1. Trading Line

Línea horizontal para marcar niveles de precio.

```dart
TradingLine(
  price: 150.0,
  type: TradingLineType.support,
  style: TradingLineStyle(
    color: Colors.green,
    strokeWidth: 2.0,
    dashPattern: [5, 3],
  ),
)
```

**Tipos:**
- `TradingLineType.support`: Soporte
- `TradingLineType.resistance`: Resistencia
- `TradingLineType.takeProfit`: Take Profit
- `TradingLineType.stopLoss`: Stop Loss
- `TradingLineType.entry`: Entrada

**Drag:** ✅ Vertical (cambiar precio)

---

### 2. Price Zone

Zona rectangular entre dos precios.

```dart
PriceZone(
  id: 'zone_1',
  minPrice: 145.0,
  maxPrice: 155.0,
  style: PriceZoneStyle(
    fillColor: Colors.blue.withOpacity(0.2),
    borderColor: Colors.blue,
    borderWidth: 2.0,
  ),
  options: PriceZoneOptions(
    draggable: true,
    resizable: true,
    onMoved: (newMin, newMax) {
      // Actualizar zona
    },
  ),
)
```

**Drag:** ✅ Vertical (mover zona completa)  
**Resize:** ✅ Handles superior e inferior

---

### 3. Fibonacci Retracement

Niveles de retroceso de Fibonacci.

```dart
FibonacciRetracement(
  id: 'fib_1',
  highPrice: 160.0,
  lowPrice: 140.0,
  style: FibonacciStyle(
    showLabels: true,
    showLevels: true,
  ),
  options: FibonacciOptions(
    draggable: true,
    onMoved: (newHigh, newLow) {
      // Actualizar fibonacci
    },
  ),
)
```

**Niveles:** 0%, 23.6%, 38.2%, 50%, 61.8%, 78.6%, 100%  
**Drag:** ✅ Handles superior e inferior  
**Resize:** ✅ Cambiar rango

---

### 4. Fibonacci Extension

Proyección de Fibonacci con 3 puntos.

```dart
FibonacciExtension(
  id: 'fib_ext_1',
  pointATime: timestamp1,
  pointAPrice: 140.0,
  pointBTime: timestamp2,
  pointBPrice: 160.0,
  pointCTime: timestamp3,
  pointCPrice: 150.0,
  options: FibonacciExtensionOptions(
    draggable: true,
    showLabels: true,
    onMoved: (newATime, newAPrice, newBTime, newBPrice, newCTime, newCPrice) {
      // Actualizar puntos
    },
  ),
)
```

**Niveles:** 0%, 38.2%, 61.8%, 100%, 127.2%, 161.8%, 200%, 261.8%  
**Drag:** ✅ 3 puntos independientes (A, B, C)

---

### 5. Fibonacci Fan

Líneas radiales de Fibonacci desde un pivot.

```dart
FibonacciFan(
  id: 'fib_fan_1',
  startTime: timestamp1,
  startPrice: 150.0,
  endTime: timestamp2,
  endPrice: 160.0,
  options: FibonacciFanOptions(
    draggable: true,
    showLabels: true,
    onMoved: (newStartTime, newStartPrice, newEndTime, newEndPrice) {
      // Actualizar fan
    },
  ),
)
```

**Niveles:** 38.2%, 50%, 61.8%  
**Drag:** ✅ Punto pivot y punto de tendencia

---

### 6. Trend Line

Línea de tendencia entre dos puntos.

```dart
TrendLine(
  id: 'trend_1',
  startTime: timestamp1,
  startPrice: 140.0,
  endTime: timestamp2,
  endPrice: 160.0,
  style: TrendLineStyle(
    color: Colors.blue,
    strokeWidth: 2.0,
    extend: true, // Extender línea
  ),
  options: TrendLineOptions(
    draggable: true,
    onMoved: (newStartTime, newStartPrice, newEndTime, newEndPrice) {
      // Actualizar línea
    },
  ),
)
```

**Drag:** ✅ Handles inicio y fin  
**Resize:** ✅ Mover endpoints

---

### 7. Position Tool

Herramienta para visualizar posiciones con Entry, SL y TP.

```dart
PositionTool(
  id: 'position_1',
  entryPrice: 150.0,
  stopLossPrice: 145.0,
  takeProfitPrice: 160.0,
  positionType: PositionType.long,
  options: PositionToolOptions(
    draggable: true,
    onMoved: (newEntry, newSL, newTP) {
      // Actualizar posición
    },
  ),
)
```

**Tipos:** `PositionType.long` o `PositionType.short`  
**Drag:** ✅ Entry, SL y TP independientes

---

### 8. Ruler Tool

Regla para medir distancia y porcentaje entre dos puntos.

```dart
RulerTool(
  id: 'ruler_1',
  startTime: timestamp1,
  startPrice: 140.0,
  endTime: timestamp2,
  endPrice: 160.0,
  options: RulerToolOptions(
    draggable: true,
    showStats: true,
    onMoved: (newStartTime, newStartPrice, newEndTime, newEndPrice) {
      // Actualizar regla
    },
  ),
)
```

**Muestra:**
- Diferencia de precio
- Porcentaje de cambio
- Número de velas
- Tiempo transcurrido

**Drag:** ✅ Handles inicio y fin

---

### 9. Vertical Line

Línea vertical para marcar eventos temporales.

```dart
VerticalLine(
  id: 'vline_1',
  timestamp: timestamp,
  style: VerticalLineStyle(
    color: Colors.orange,
    strokeWidth: 2.0,
    dashPattern: [5, 3],
  ),
  options: VerticalLineOptions(
    draggable: true,
    onMoved: (newTimestamp) {
      // Actualizar línea
    },
  ),
)
```

**Drag:** ✅ Horizontal (cambiar timestamp)

---

### 10. Arrow Tool

Flecha direccional para señalar movimientos.

```dart
ArrowTool(
  id: 'arrow_1',
  startTime: timestamp1,
  startPrice: 140.0,
  endTime: timestamp2,
  endPrice: 160.0,
  style: ArrowToolStyle(
    color: Colors.blue,
    strokeWidth: 2.0,
    arrowheadSize: 12.0,
    filled: true,
  ),
  options: ArrowToolOptions(
    draggable: true,
    onMoved: (newStartTime, newStartPrice, newEndTime, newEndPrice) {
      // Actualizar flecha
    },
  ),
)
```

**Drag:** ✅ Handles inicio y fin  
**Características:** Punta de flecha personalizable

---

### 11. Circle Tool

Círculo/elipse para resaltar áreas.

```dart
CircleTool(
  id: 'circle_1',
  centerTime: timestamp,
  centerPrice: 150.0,
  radiusTime: 10 * 86400000, // 10 días
  radiusPrice: 5.0,
  style: CircleToolStyle(
    color: Colors.blue,
    strokeWidth: 2.0,
    filled: true,
    fillOpacity: 0.1,
  ),
  options: CircleToolOptions(
    draggable: true,
    onMoved: (newCenterTime, newCenterPrice, newRadiusTime, newRadiusPrice) {
      // Actualizar círculo
    },
  ),
)
```

**Drag:** ✅ Centro y radio  
**Resize:** ✅ Handle de radio

---

### 12. Text Tool

Anotaciones de texto en el gráfico.

```dart
TextTool(
  id: 'text_1',
  timestamp: timestamp,
  price: 150.0,
  text: 'Importante',
  style: TextToolStyle(
    textColor: Colors.white,
    fontSize: 14.0,
    showBackground: true,
    backgroundColor: Colors.black,
    showBorder: true,
    borderColor: Colors.blue,
  ),
  options: TextToolOptions(
    draggable: true,
    onMoved: (newTimestamp, newPrice) {
      // Actualizar posición
    },
    onEdit: (currentText) async {
      // Mostrar diálogo de edición
      return await showEditDialog(currentText);
    },
  ),
)
```

**Drag:** ✅ Mover posición  
**Edición:** ✅ Doble tap para editar texto

---

### 13. Brush Tool

Trazos a mano alzada (visualización).

```dart
BrushTool(
  id: 'brush_1',
  points: [
    BrushPoint(timestamp: t1, price: p1),
    BrushPoint(timestamp: t2, price: p2),
    // ... más puntos
  ],
  style: BrushToolStyle(
    color: Colors.orange,
    strokeWidth: 2.0,
    smooth: true, // Curvas suaves
  ),
)
```

**Nota:** Actualmente para visualización de trazos predefinidos.

---

### 14. Gantt Tool

Barras horizontales para períodos de tiempo.

```dart
GanttTool(
  id: 'gantt_1',
  startTime: timestamp1,
  endTime: timestamp2,
  price: 150.0,
  height: 5.0,
  label: 'Fase 1',
  style: GanttToolStyle(
    fillColor: Colors.green,
    fillOpacity: 0.3,
    borderColor: Colors.green,
    showLabel: true,
  ),
  options: GanttToolOptions(
    draggable: true,
    onMoved: (newStartTime, newEndTime, newPrice) {
      // Actualizar período
    },
  ),
)
```

**Drag:** ✅ Handles inicio y fin  
**Resize:** ✅ Cambiar duración del período

---

## 💡 Ejemplos de Uso

### Ejemplo Completo: Chart con Indicadores y Herramientas

```dart
class MyChartPage extends StatefulWidget {
  @override
  _MyChartPageState createState() => _MyChartPageState();
}

class _MyChartPageState extends State<MyChartPage> {
  List<CandleData> _candles = [];
  List<ChartOverlay> _overlays = [];
  List<Indicator> _indicators = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _setupIndicators();
    _setupOverlays();
  }

  void _loadData() {
    // Cargar datos de velas
    _candles = loadCandleData();
  }

  void _setupIndicators() {
    _indicators = [
      SMAIndicator(period: 20, color: Colors.blue),
      EMAIndicator(period: 12, color: Colors.orange),
      RSIIndicator(period: 14),
      MACDIndicator(),
    ];
  }

  void _setupOverlays() {
    _overlays = [
      TradingLine(
        price: 150.0,
        type: TradingLineType.support,
      ),
      FibonacciRetracement(
        id: 'fib_1',
        highPrice: 160.0,
        lowPrice: 140.0,
        options: FibonacciOptions(
          draggable: true,
          onMoved: (newHigh, newLow) {
            setState(() {
              // Actualizar fibonacci
            });
          },
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Trading Chart')),
      body: InteractiveChart(
        candles: _candles,
        overlays: _overlays,
        indicators: _indicators,
        style: ChartStyle(
          showVolume: true,
          priceGridLineColor: Colors.grey.withOpacity(0.1),
        ),
      ),
    );
  }
}
```

---

### Ejemplo: Agregar Herramienta Dinámicamente

```dart
void _addTrendLine() {
  final trendId = 'trend_${DateTime.now().millisecondsSinceEpoch}';
  
  setState(() {
    _overlays.add(
      TrendLine(
        id: trendId,
        startTime: _candles[50].timestamp,
        startPrice: _candles[50].close ?? 0,
        endTime: _candles[80].timestamp,
        endPrice: _candles[80].close ?? 0,
        options: TrendLineOptions(
          draggable: true,
          onMoved: (startTime, startPrice, endTime, endPrice) {
            setState(() {
              final index = _overlays.indexWhere((o) => o.id == trendId);
              if (index >= 0) {
                _overlays[index] = TrendLine(
                  id: trendId,
                  startTime: startTime,
                  startPrice: startPrice,
                  endTime: endTime,
                  endPrice: endPrice,
                  options: (_overlays[index] as TrendLine).options,
                );
              }
            });
          },
        ),
      ),
    );
  });
}
```

---

### Ejemplo: Text Tool con Edición

```dart
void _addTextAnnotation() {
  final textId = 'text_${DateTime.now().millisecondsSinceEpoch}';
  
  setState(() {
    _overlays.add(
      TextTool(
        id: textId,
        timestamp: _candles[60].timestamp,
        price: _candles[60].close ?? 0,
        text: 'Nota importante',
        options: TextToolOptions(
          draggable: true,
          onMoved: (newTimestamp, newPrice) {
            setState(() {
              final index = _overlays.indexWhere((o) => o.id == textId);
              if (index >= 0) {
                _overlays[index] = (_overlays[index] as TextTool).copyWith(
                  timestamp: newTimestamp,
                  price: newPrice,
                );
              }
            });
          },
          onEdit: (currentText) async {
            final controller = TextEditingController(text: currentText);
            final newText = await showDialog<String>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Editar Texto'),
                content: TextField(
                  controller: controller,
                  autofocus: true,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, null),
                    child: Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, controller.text),
                    child: Text('Guardar'),
                  ),
                ],
              ),
            );
            
            if (newText != null) {
              setState(() {
                final index = _overlays.indexWhere((o) => o.id == textId);
                if (index >= 0) {
                  _overlays[index] = (_overlays[index] as TextTool).copyWith(
                    text: newText,
                  );
                }
              });
            }
            
            return newText;
          },
        ),
      ),
    );
  });
}
```

---

## 🎨 Personalización

### Estilos Globales del Chart

```dart
InteractiveChart(
  candles: _candles,
  style: ChartStyle(
    // Colores de velas
    candleUpColor: Colors.green,
    candleDownColor: Colors.red,
    
    // Grid
    priceGridLineColor: Colors.grey.withOpacity(0.1),
    timeGridLineColor: Colors.grey.withOpacity(0.1),
    
    // Volumen
    showVolume: true,
    volumeColor: Colors.grey.withOpacity(0.5),
    
    // Fondo
    backgroundColor: Colors.black,
    
    // Texto
    priceLabelStyle: TextStyle(color: Colors.white),
    timeLabelStyle: TextStyle(color: Colors.white),
  ),
)
```

---

### Temas Predefinidos

```dart
// Tema Oscuro
ChartStyle.dark()

// Tema Claro
ChartStyle.light()

// Personalizado
ChartStyle(
  candleUpColor: Color(0xFF26A69A),
  candleDownColor: Color(0xFFEF5350),
  backgroundColor: Color(0xFF1E1E1E),
)
```

---

## 🚀 Mejores Prácticas

### 1. Gestión de Estado

Usa `setState()` dentro de los callbacks `onMoved` para actualizar las herramientas:

```dart
options: TrendLineOptions(
  draggable: true,
  onMoved: (startTime, startPrice, endTime, endPrice) {
    setState(() {
      // Actualizar overlay
    });
  },
)
```

---

### 2. IDs Únicos

Siempre usa IDs únicos para las herramientas:

```dart
final id = 'tool_${DateTime.now().millisecondsSinceEpoch}';
```

---

### 3. Performance

- Limita el número de overlays visibles (< 50 recomendado)
- Usa `visible: false` para ocultar en lugar de eliminar
- Implementa paginación para datos históricos grandes

---

### 4. Callbacks

Implementa callbacks para todas las herramientas interactivas:

```dart
onMoved: (params) {
  // Guardar en base de datos
  // Actualizar estado
  // Notificar cambios
}
```

---

### 5. Validación

Valida los datos antes de crear herramientas:

```dart
if (startPrice > 0 && endPrice > 0 && startTime < endTime) {
  // Crear herramienta
}
```

---

## 📱 Gestos Soportados

### Chart
- **Pan**: Arrastrar para mover el gráfico
- **Pinch**: Pellizcar para zoom
- **Scroll**: Rueda del mouse para zoom
- **Tap**: Seleccionar overlay

### Overlays
- **Single Tap**: Seleccionar para drag
- **Double Tap**: Editar (Text Tool)
- **Drag**: Mover overlay
- **Drag Handle**: Resize/mover punto específico

---

## 🔧 Solución de Problemas

### Overlay no se mueve

Verifica que:
1. `draggable: true` en options
2. Callback `onMoved` implementado
3. `setState()` llamado en el callback

### Preview no se muestra durante drag

Verifica que:
1. Los parámetros se pasan correctamente al ChartPainter
2. El método `copyWith` está implementado
3. Las flags de estado están correctas

### Texto no se edita

Verifica que:
1. `onEdit` callback está implementado
2. Doble tap está funcionando (< 300ms entre taps)
3. El diálogo retorna el nuevo texto

---

## 📚 Recursos Adicionales

- **Ejemplo Completo**: Ver `example/lib/tabbed_example.dart`
- **Roadmap**: Ver `INTEGRATION_ROADMAP.md`
- **Changelog**: Ver `CHANGELOG.md`
- **API Docs**: Generar con `dart doc`

---

## 🤝 Contribuciones

Para contribuir al proyecto:

1. Fork el repositorio
2. Crea una rama feature (`git checkout -b feature/nueva-herramienta`)
3. Commit cambios (`git commit -am 'Agregar nueva herramienta'`)
4. Push a la rama (`git push origin feature/nueva-herramienta`)
5. Crea un Pull Request

---

## 📄 Licencia

MIT License - Ver LICENSE file para más detalles.

---

## 👨‍💻 Autor

**Carlos Aroca**  
Email: carlos@pipsend.com  
GitHub: @carlosaroca

---

## 🎉 ¡Gracias por usar PipsendCharts!

Si tienes preguntas o sugerencias, no dudes en abrir un issue en GitHub.

**Happy Trading! 📈**
