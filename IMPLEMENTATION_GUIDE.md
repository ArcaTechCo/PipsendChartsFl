# 📘 Pipsend Charts Flutter - Implementation Guide

Complete guide for implementing Pipsend Charts Flutter in your application.

---

## 📦 Installation

### 1. Add Dependency

```yaml
# pubspec.yaml
dependencies:
  pipsend_charts: ^1.0.1
```

### 2. Install and Import

```bash
flutter pub get
```

```dart
import 'package:pipsend_charts/pipsend_charts.dart';
```

---

## 🎯 Basic Implementation

### Minimal Chart

```dart
import 'package:flutter/material.dart';
import 'package:pipsend_charts/pipsend_charts.dart';

class BasicChart extends StatelessWidget {
  final List<CandleData> data = [
    CandleData(
      timestamp: DateTime.now().millisecondsSinceEpoch,
      open: 100.0,
      high: 105.0,
      low: 98.0,
      close: 103.0,
      volume: 1000000.0,
    ),
    // Add more candles...
  ];

  @override
  Widget build(BuildContext context) {
    return InteractiveChart(
      candles: data,
      style: ChartStyle(
        priceGainColor: Colors.green,
        priceLossColor: Colors.red,
      ),
    );
  }
}
```

---

## 📊 Technical Indicators

### Adding Indicators

```dart
InteractiveChart(
  candles: data,
  indicators: [
    // RSI
    RSIIndicator(period: 14),
    
    // MACD
    MACDIndicator(
      fastPeriod: 12,
      slowPeriod: 26,
      signalPeriod: 9,
    ),
    
    // Bollinger Bands
    BollingerBandsIndicator(
      period: 20,
      stdDev: 2.0,
    ),
    
    // Moving Averages
    SMAIndicator(period: 20),
    EMAIndicator(period: 12),
  ],
)
```

### Available Indicators

- **RSIIndicator** - Relative Strength Index
- **MACDIndicator** - Moving Average Convergence Divergence
- **BollingerBandsIndicator** - Volatility bands
- **StochasticIndicator** - %K and %D lines
- **ATRIndicator** - Average True Range
- **ADXIndicator** - Average Directional Index
- **CCIIndicator** - Commodity Channel Index
- **WilliamsRIndicator** - Williams %R
- **OBVIndicator** - On-Balance Volume
- **SMAIndicator** - Simple Moving Average
- **EMAIndicator** - Exponential Moving Average

---

## 📈 Trading Lines

### Complete Implementation

```dart
class TradingLinesChart extends StatefulWidget {
  @override
  _TradingLinesChartState createState() => _TradingLinesChartState();
}

class _TradingLinesChartState extends State<TradingLinesChart> {
  final List<CandleData> _data = [];
  final TradingLineManager _lineManager = TradingLineManager();

  @override
  void initState() {
    super.initState();
    _setupLines();
    _lineManager.addListener((event) => setState(() {}));
  }

  void _setupLines() {
    // Add Stop Loss
    _lineManager.addLine(TradingLine(
      id: 'sl_1',
      price: 150.0,
      type: TradingLineType.stopLoss,
      options: TradingLineOptions(
        title: 'Stop Loss',
        draggable: true,
        onPriceChanged: (newPrice) {
          _lineManager.updateLinePrice('sl_1', newPrice);
          setState(() {});
        },
      ),
    ));

    // Add Take Profit
    _lineManager.addLine(TradingLine(
      id: 'tp_1',
      price: 180.0,
      type: TradingLineType.takeProfit,
      options: TradingLineOptions(
        title: 'Take Profit',
        draggable: true,
        onPriceChanged: (newPrice) {
          _lineManager.updateLinePrice('tp_1', newPrice);
          setState(() {});
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveChart(
      candles: _data,
      overlays: _lineManager.lines,
    );
  }

  @override
  void dispose() {
    _lineManager.clearListeners();
    super.dispose();
  }
}
```

### Trading Line Types

```dart
TradingLineType.entry       // Entry point
TradingLineType.stopLoss    // Stop loss
TradingLineType.takeProfit  // Take profit
TradingLineType.support     // Support level
TradingLineType.resistance  // Resistance level
TradingLineType.custom      // Custom line
```

### Manager Methods

```dart
// Add
lineManager.addLine(line);

// Update
lineManager.updateLinePrice('id', 150.0);

// Remove
lineManager.removeLine('id');

// Query
lineManager.getLinesByType(TradingLineType.stopLoss);
lineManager.getLineById('id');

// Clear
lineManager.clear();
lineManager.clearByType(TradingLineType.support);
```

---

## 📦 Price Zones

### Complete Implementation

```dart
class PriceZonesChart extends StatefulWidget {
  @override
  _PriceZonesChartState createState() => _PriceZonesChartState();
}

class _PriceZonesChartState extends State<PriceZonesChart> {
  final List<CandleData> _data = [];
  final PriceZoneManager _zoneManager = PriceZoneManager();

  @override
  void initState() {
    super.initState();
    _setupZones();
    _zoneManager.addListener((event) => setState(() {}));
  }

  void _setupZones() {
    // Add Demand Zone
    _zoneManager.addZone(PriceZone(
      id: 'demand_1',
      minPrice: 140.0,
      maxPrice: 145.0,
      type: PriceZoneType.demand,
      options: PriceZoneOptions(
        label: 'Demand Zone',
        draggable: true,
        onRangeChanged: (min, max) {
          _zoneManager.updateZoneRange('demand_1', min, max);
          setState(() {});
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveChart(
      candles: _data,
      overlays: _zoneManager.zones,
    );
  }
}
```

### Zone Types

```dart
PriceZoneType.support     // Support zone
PriceZoneType.resistance  // Resistance zone
PriceZoneType.demand      // Demand zone
PriceZoneType.supply      // Supply zone
PriceZoneType.custom      // Custom zone
```

---

## ✏️ Drawing Tools

### Fibonacci Retracement

```dart
final fibManager = FibonacciManager();

fibManager.addFibonacci(FibonacciRetracement(
  id: 'fib_1',
  highPrice: 200.0,
  lowPrice: 150.0,
  options: FibonacciOptions(
    draggable: true,
    onMoved: (high, low) {
      fibManager.updateFibonacciRange('fib_1', high, low);
    },
  ),
));
```

### Trend Lines

```dart
final trendManager = TrendLineManager();

trendManager.addTrendLine(TrendLine(
  id: 'trend_1',
  startTime: startTimestamp,
  startPrice: 140.0,
  endTime: endTimestamp,
  endPrice: 180.0,
  options: TrendLineOptions(
    draggable: true,
    showAngle: true,
    onMoved: (startTime, startPrice, endTime, endPrice) {
      trendManager.updateTrendLinePoints('trend_1',
        startTime: startTime,
        startPrice: startPrice,
        endTime: endTime,
        endPrice: endPrice,
      );
    },
  ),
));
```

---

## 🔄 Complete Example

```dart
class CompleteChart extends StatefulWidget {
  @override
  _CompleteChartState createState() => _CompleteChartState();
}

class _CompleteChartState extends State<CompleteChart> {
  final List<CandleData> _data = [];
  final TradingLineManager _lineManager = TradingLineManager();
  final PriceZoneManager _zoneManager = PriceZoneManager();
  
  bool _showRSI = true;
  bool _showMACD = false;

  @override
  void initState() {
    super.initState();
    _lineManager.addListener((event) => setState(() {}));
    _zoneManager.addListener((event) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InteractiveChart(
        candles: _data,
        indicators: [
          if (_showRSI) RSIIndicator(period: 14),
          if (_showMACD) MACDIndicator(
            fastPeriod: 12,
            slowPeriod: 26,
            signalPeriod: 9,
          ),
        ],
        overlays: [
          ..._lineManager.lines,
          ..._zoneManager.zones,
        ],
        style: ChartStyle(
          priceGainColor: Colors.green,
          priceLossColor: Colors.red,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _lineManager.clearListeners();
    _zoneManager.clearListeners();
    super.dispose();
  }
}
```

---

## 📝 Data Loading

### From API

```dart
Future<List<CandleData>> loadCandles() async {
  final response = await http.get(Uri.parse('api-url'));
  final data = json.decode(response.body) as List;
  
  return data.map((item) => CandleData(
    timestamp: item['timestamp'],
    open: item['open'].toDouble(),
    high: item['high'].toDouble(),
    low: item['low'].toDouble(),
    close: item['close'].toDouble(),
    volume: item['volume']?.toDouble() ?? 0.0,
  )).toList();
}
```

---

## 🎯 Best Practices

1. **Always call setState after manager updates**
2. **Clear listeners in dispose()**
3. **Use unique IDs for overlays**
4. **Limit candle data for performance (max 500)**
5. **Handle errors when loading data**

---

## 📚 More Examples

Check the example folder in the repository for complete implementations:
- https://github.com/ArcaTechCo/PipsendChartsFl/tree/main/example

---

## 💬 Support

- GitHub Issues: https://github.com/ArcaTechCo/PipsendChartsFl/issues
- Discussions: https://github.com/ArcaTechCo/PipsendChartsFl/discussions
- Email: https://pipsend.com
