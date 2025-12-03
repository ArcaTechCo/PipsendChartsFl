<div align="center">

# 📊 Pipsend Charts Flutter

**Professional Trading Charts for Flutter Applications**

[![License](https://img.shields.io/badge/license-Dual%20License-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-%E2%89%A5%202.0.0-02569B?logo=flutter)](https://flutter.dev)
[![Pub Version](https://img.shields.io/badge/pub-v1.0.6-blue)](https://pub.dev)

*A powerful, feature-rich charting library for Flutter with 12+ technical indicators, interactive overlays, and professional trading tools.*

[Features](#-features) • [Installation](#-installation) • [Quick Start](#-quick-start) • [Documentation](#-documentation) • [Examples](#-examples) • [License](#-license)

</div>

---

## 📸 Screenshots

<div align="center">

<table>
  <tr>
    <td align="center">
      <img src="https://raw.githubusercontent.com/ArcaTechCo/PipsendChartsFl/main/example/demo_gifs/indicators.png" alt="Technical Indicators" width="240"/><br/>
      <b>Technical Indicators</b><br/>
      <sub>RSI, MACD, Bollinger Bands, Stochastic</sub>
    </td>
    <td align="center">
      <img src="https://raw.githubusercontent.com/ArcaTechCo/PipsendChartsFl/main/example/demo_gifs/lines.png" alt="Trading Lines" width="240"/><br/>
      <b>Trading Lines</b><br/>
      <sub>Stop Loss, Take Profit, Support & Resistance</sub>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="https://raw.githubusercontent.com/ArcaTechCo/PipsendChartsFl/main/example/demo_gifs/zones.png" alt="Price Zones" width="240"/><br/>
      <b>Price Zones</b><br/>
      <sub>Demand and Supply zones with labels</sub>
    </td>
    <td align="center">
      <img src="https://raw.githubusercontent.com/ArcaTechCo/PipsendChartsFl/main/example/demo_gifs/draw.png" alt="Drawing Tools" width="240"/><br/>
      <b>Drawing Tools</b><br/>
      <sub>Fibonacci Retracement and Trend Lines</sub>
    </td>
  </tr>
</table>

</div>

---

## ✨ Features

### 📈 Core Charting
- **Candlestick Charts** - Professional OHLC visualization
- **Pinch-to-Zoom** - Smooth, responsive zooming (horizontal & vertical)
- **Vertical Zoom & Pan** - Control vertical space for TP/SL lines and indicators
- **Pan & Scroll** - Intuitive navigation with natural scrolling
- **Configurable Grid** - Horizontal & vertical grid with 4 line styles
- **Adaptive Labels** - Auto-adjust labels based on chart size
- **Infinite History** - Lazy loading of historical data (like TradingView)
- **Rounded Candles** - Customizable corner radius for modern appearance
- **Dark/Light Mode** - Built-in theme support
- **Customizable Styles** - Full control over appearance
- **Volume Bars** - Integrated volume display
- **Responsive** - Works on mobile, web, and desktop

### 📊 Technical Indicators (12+)
- **Moving Averages** - SMA(20, 50), EMA(12, 26)
- **RSI** - Relative Strength Index with overbought/oversold zones
- **MACD** - Moving Average Convergence Divergence with histogram
- **Bollinger Bands** - Volatility bands with customizable periods
- **Stochastic** - %K and %D lines with signal zones
- **ATR** - Average True Range for volatility
- **ADX** - Average Directional Index for trend strength
- **CCI** - Commodity Channel Index
- **Williams %R** - Momentum indicator
- **OBV** - On-Balance Volume
- **Volume** - Dedicated volume indicator

### 🎯 Trading Tools
- **Trading Lines** - Entry, Stop Loss, Take Profit, Support, Resistance
- **Price Zones** - Demand, Supply, Support, Resistance zones
- **Fibonacci Retracement** - Standard Fib levels with draggable points
- **Trend Lines** - Diagonal lines with angle display
- **All Draggable** - Interactive repositioning with callbacks

### 🔧 Management System
- **TradingLineManager** - Manage multiple trading lines
- **PriceZoneManager** - Manage price zones
- **FibonacciManager** - Manage Fibonacci retracements
- **TrendLineManager** - Manage trend lines
- **Event System** - Real-time updates and notifications
- **Query API** - Find overlays by type, price, range

---

## 🚀 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  pipsend_charts: ^1.0.6
```

Then run:

```bash
flutter pub get
```

---

## 🎯 Quick Start

### Basic Chart

```dart
import 'package:pipsend_charts/pipsend_charts.dart';

InteractiveChart(
  candles: candleData,
  style: ChartStyle(
    priceGainColor: Colors.green,
    priceLossColor: Colors.red,
  ),
)
```

### With Indicators

```dart
InteractiveChart(
  candles: candleData,
  indicators: [
    RSIIndicator(period: 14),
    MACDIndicator(fastPeriod: 12, slowPeriod: 26, signalPeriod: 9),
    BollingerBandsIndicator(period: 20, stdDev: 2.0),
  ],
)
```

### With Trading Lines

```dart
final lineManager = TradingLineManager();

// Add a stop loss
lineManager.addLine(TradingLine(
  id: 'sl_1',
  price: 150.0,
  type: TradingLineType.stopLoss,
  options: TradingLineOptions(
    title: 'Stop Loss',
    draggable: true,
    onPriceChanged: (newPrice) {
      lineManager.updateLinePrice('sl_1', newPrice);
    },
  ),
));

InteractiveChart(
  candles: candleData,
  overlays: lineManager.lines,
)
```

### With Price Zones

```dart
final zoneManager = PriceZoneManager();

// Add a demand zone
zoneManager.addZone(PriceZone(
  id: 'demand_1',
  minPrice: 140.0,
  maxPrice: 145.0,
  type: PriceZoneType.demand,
  options: PriceZoneOptions(
    label: 'Demand Zone',
    draggable: true,
    onRangeChanged: (newMin, newMax) {
      zoneManager.updateZoneRange('demand_1', newMin, newMax);
    },
  ),
));

InteractiveChart(
  candles: candleData,
  overlays: zoneManager.zones,
)
```

---

## 📚 Documentation

### Core Components

#### InteractiveChart
The main chart widget.

```dart
InteractiveChart(
  candles: List<CandleData>,           // Required: OHLC data
  indicators: List<Indicator>,         // Optional: Technical indicators
  overlays: List<ChartOverlay>,        // Optional: Lines, zones, etc.
  style: ChartStyle,                   // Optional: Visual customization
  onTap: (TapDetails details) {},     // Optional: Tap callback
  onXOffsetChanged: (details) {},     // Optional: Scroll callback
)
```

#### CandleData
OHLC data structure.

```dart
CandleData(
  timestamp: DateTime.now().millisecondsSinceEpoch,
  open: 100.0,
  high: 105.0,
  low: 98.0,
  close: 103.0,
  volume: 1000000.0,
)
```

### Technical Indicators

#### RSI (Relative Strength Index)
```dart
RSIIndicator(
  period: 14,                          // Default: 14
  style: RSIStyle(
    lineColor: Colors.purple,
    overboughtLevel: 70,
    oversoldLevel: 30,
  ),
)
```

#### MACD
```dart
MACDIndicator(
  fastPeriod: 12,
  slowPeriod: 26,
  signalPeriod: 9,
  style: MACDStyle(
    macdLineColor: Colors.blue,
    signalLineColor: Colors.orange,
    histogramPositiveColor: Colors.green,
    histogramNegativeColor: Colors.red,
  ),
)
```

#### Bollinger Bands
```dart
BollingerBandsIndicator(
  period: 20,
  stdDev: 2.0,
  style: BollingerBandsStyle(
    upperBandColor: Colors.red,
    middleBandColor: Colors.blue,
    lowerBandColor: Colors.green,
  ),
)
```

### Trading Lines

#### Types
- `TradingLineType.entry` - Entry point
- `TradingLineType.stopLoss` - Stop loss level
- `TradingLineType.takeProfit` - Take profit target
- `TradingLineType.support` - Support level
- `TradingLineType.resistance` - Resistance level
- `TradingLineType.custom` - Custom line

#### Manager Methods
```dart
// Add line
String? id = lineManager.addLine(line);

// Update price
lineManager.updateLinePrice(id, newPrice);

// Remove line
lineManager.removeLine(id);

// Query
List<TradingLine> lines = lineManager.getLinesByType(TradingLineType.stopLoss);

// Clear all
lineManager.clear();

// Listen to events
lineManager.addListener((event) {
  print('Line ${event.type}: ${event.line.id}');
});
```

### Price Zones

#### Types
- `PriceZoneType.support` - Support zone
- `PriceZoneType.resistance` - Resistance zone
- `PriceZoneType.demand` - Demand zone
- `PriceZoneType.supply` - Supply zone
- `PriceZoneType.custom` - Custom zone

#### Manager Methods
```dart
// Add zone
String? id = zoneManager.addZone(zone);

// Update range
zoneManager.updateZoneRange(id, newMin, newMax);

// Remove zone
zoneManager.removeZone(id);

// Query
List<PriceZone> zones = zoneManager.getZonesByType(PriceZoneType.demand);

// Clear all
zoneManager.clear();
```

### Fibonacci Retracement

```dart
final fibManager = FibonacciManager();

fibManager.addFibonacci(FibonacciRetracement(
  id: 'fib_1',
  highPrice: 200.0,
  lowPrice: 150.0,
  options: FibonacciOptions(
    showLabels: true,
    showPercentages: true,
    draggable: true,
    onMoved: (newHigh, newLow) {
      fibManager.updateFibonacciRange('fib_1', newHigh, newLow);
    },
  ),
));

InteractiveChart(
  candles: candleData,
  overlays: fibManager.fibonaccis,
)
```

### Trend Lines

```dart
final trendManager = TrendLineManager();

trendManager.addTrendLine(TrendLine(
  id: 'trend_1',
  startTime: startTimestamp,
  startPrice: 100.0,
  endTime: endTimestamp,
  endPrice: 150.0,
  options: TrendLineOptions(
    draggable: true,
    showAngle: true,
    extendRight: false,
    onMoved: (newStartTime, newStartPrice, newEndTime, newEndPrice) {
      trendManager.updateTrendLinePoints('trend_1',
        startTime: newStartTime,
        startPrice: newStartPrice,
        endTime: newEndTime,
        endPrice: newEndPrice,
      );
    },
  ),
));

InteractiveChart(
  candles: candleData,
  overlays: trendManager.trendLines,
)
```

### Configurable Grid

Customize chart grid lines for better readability and visual appeal.

#### Basic Usage

```dart
InteractiveChart(
  candles: data,
  style: ChartStyle(
    gridStyle: GridStyle.full,  // Show both horizontal and vertical
  ),
)
```

#### Custom Grid

```dart
InteractiveChart(
  candles: data,
  style: ChartStyle(
    gridStyle: GridStyle(
      // Horizontal (price) grid
      showHorizontalGrid: true,
      horizontalLineStyle: GridLineStyle.solid,
      horizontalStrokeWidth: 1.0,
      horizontalGridColor: Colors.grey.withOpacity(0.3),
      
      // Vertical (time) grid
      showVerticalGrid: true,
      verticalLineStyle: GridLineStyle.dashed,
      verticalStrokeWidth: 0.5,
      verticalGridColor: Colors.grey.withOpacity(0.1),
    ),
  ),
)
```

#### Available Presets

```dart
GridStyle.none          // No grid lines
GridStyle.horizontalOnly // Only horizontal (default)
GridStyle.full          // Both horizontal and vertical
GridStyle.subtle        // Low opacity (10%)
GridStyle.dashed        // Dashed style
GridStyle.dotted        // Dotted style
```

#### Line Styles

- **`GridLineStyle.solid`** - Continuous lines (─────────)
- **`GridLineStyle.dashed`** - Dashed lines (─ ─ ─ ─ ─)
- **`GridLineStyle.dotted`** - Dotted lines (· · · · ·)
- **`GridLineStyle.longDashed`** - Long dashed lines (── ── ──)

---

### Adaptive Labels

Labels automatically adjust to chart size for optimal readability on any device.

#### Automatic (Default)

```dart
InteractiveChart(
  candles: data,
  style: ChartStyle(
    adaptiveLabels: true,  // Default - auto-adjusts
  ),
)
```

**Behavior:**
- **Price Labels:** 3-10 labels based on chart height (~80px per label)
- **Time Labels:** Dynamic spacing based on chart width (default: 90px)
- **Grid Alignment:** Grid lines always align with labels

#### Manual Override

```dart
InteractiveChart(
  candles: data,
  style: ChartStyle(
    adaptiveLabels: false,
    priceLabelCount: 7,      // Force 7 price labels
    timeLabelDensity: 100,   // One time label every 100px
  ),
)
```

#### Examples by Screen Size

| Device | Height | Price Labels | Width | Time Labels |
|--------|--------|--------------|-------|-------------|
| Mobile | 300px | 4 labels | 360px | 4 labels |
| Tablet | 500px | 6 labels | 768px | 8 labels |
| Desktop | 800px | 10 labels | 1920px | 21 labels |

---

### Infinite History / Lazy Loading

Load historical data dynamically as the user scrolls, similar to TradingView's Lightweight Charts.

#### Basic Implementation

```dart
class ChartScreen extends StatefulWidget {
  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  List<CandleData> _candles = [];
  bool _isLoadingHistory = false;
  
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }
  
  Future<void> _loadInitialData() async {
    // Load initial 200 candles
    final data = await api.fetchCandles(limit: 200);
    setState(() => _candles = data);
  }
  
  Future<void> _loadMoreHistory() async {
    if (_isLoadingHistory || _candles.isEmpty) return;
    
    setState(() => _isLoadingHistory = true);
    
    // Get oldest timestamp
    final oldestTimestamp = _candles.first.timestamp;
    
    // Load 100 more historical candles
    final olderData = await api.fetchCandles(
      before: oldestTimestamp,
      limit: 100,
    );
    
    setState(() {
      // Prepend: Add to the beginning
      // Chart automatically maintains visual position
      _candles = [...olderData, ..._candles];
      _isLoadingHistory = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return InteractiveChart(
      candles: _candles,
      
      // 🔥 Detect when user scrolls near the beginning
      onXOffsetChanged: (details) {
        // Load more when less than 50 candles before visible area
        if (details.isNearStart(50) && !_isLoadingHistory) {
          print('Loading more historical data...');
          // Use Future.microtask to avoid setState during build
          Future.microtask(() => _loadMoreHistory());
        }
      },
    );
  }
}
```

#### XAxisOffsetDetails Properties

The `onXOffsetChanged` callback provides detailed information:

```dart
onXOffsetChanged: (details) {
  // Visible range
  print('Start index: ${details.startCandleIndex}');
  print('End index: ${details.endCandleIndex}');
  print('Visible count: ${details.visibleCandleCount}');
  
  // Available data
  print('Candles before visible: ${details.candlesBeforeVisible}');
  print('Candles after visible: ${details.candlesAfterVisible}');
  print('Total candles: ${details.totalCandles}');
  
  // Boundary checks
  print('At start: ${details.isAtStart}');
  print('At end: ${details.isAtEnd}');
  
  // Threshold checks (default: 50)
  print('Near start: ${details.isNearStart()}');
  print('Near end: ${details.isNearEnd()}');
  
  // Custom threshold
  print('Near start (100): ${details.isNearStart(100)}');
}
```

#### Advanced: Bidirectional Loading

Load data in both directions:

```dart
onXOffsetChanged: (details) {
  // Load historical data when scrolling left
  if (details.isNearStart(50) && !_isLoadingHistory) {
    Future.microtask(() => _loadMoreHistory());
  }
  
  // Load recent data when scrolling right
  if (details.isNearEnd(50) && !_isLoadingRecent) {
    Future.microtask(() => _loadMoreRecentData());
  }
}
```

#### Key Features

- **Automatic Position Maintenance** - Chart preserves visual position when prepending data
- **Configurable Threshold** - Control when to trigger loading (default: 50 candles)
- **Bidirectional Loading** - Load both historical and recent data
- **Efficient** - Only renders visible candles, handles large datasets smoothly

See the **Infinite History** tab in the example app for a complete working demo.

---

## 💡 Examples

Check out the comprehensive example app in the `example` folder:

```bash
cd example
flutter run
```

The example includes:
- **Indicators Tab** - All 12 technical indicators with toggles
- **Trading Lines Tab** - Interactive trading lines with FABs
- **Price Zones Tab** - Draggable price zones
- **Drawing Tools Tab** - Fibonacci and trend lines
- **Vertical Zoom Tab** - Interactive vertical zoom/pan demo with TP/SL
- **Infinite History Tab** - Lazy loading demo with bidirectional data loading
- **Settings Tab** - Modern Bottom Sheet with Grid, Labels, and Candle controls

---

## 🎨 Customization

### Vertical Zoom & Pan

Control vertical chart space to see TP/SL lines and indicators outside the candle range.

```dart
InteractiveChart(
  candles: candleData,
  enableVerticalPan: true,        // Enable vertical controls
  initialVerticalZoom: 1.3,       // 30% padding above/below
  overlays: [
    TradingLine(
      price: 1.2500,
      type: TradingLineType.takeProfit,
      options: TradingLineOptions(title: 'TP'),
    ),
  ],
)
```

**Controls:**
- **Desktop**: `Shift + Scroll` for zoom, `Alt + Scroll` for pan
- **Mobile**: Vertical drag to pan

**Programmatic Control:**
```dart
final chartKey = GlobalKey<State<StatefulWidget>>();

// Set zoom level
(chartKey.currentState as _InteractiveChartState?)?.setVerticalZoom(1.5);

// Reset view
(chartKey.currentState as _InteractiveChartState?)?.resetVerticalView();
```

See [VERTICAL_ZOOM_GUIDE.md](VERTICAL_ZOOM_GUIDE.md) for complete documentation.

### Rounded Candles

Customize candle appearance with rounded corners for a modern look.

```dart
InteractiveChart(
  candles: candleData,
  style: ChartStyle(
    candleBorderRadius: 4.0,  // 0.0 = square, 8.0 = very rounded
    priceGainColor: Colors.green,
    priceLossColor: Colors.red,
  ),
)
```

**Recommended Values:**
- `0.0` - Square corners (classic)
- `2.0` - Slightly rounded
- `4.0` - Moderately rounded (recommended)
- `8.0` - Very rounded (modern)

See [CANDLE_STYLING_GUIDE.md](CANDLE_STYLING_GUIDE.md) for complete documentation.

### Chart Styles

```dart
ChartStyle(
  // Candle appearance
  candleBorderRadius: 4.0,
  priceGainColor: Colors.green,
  priceLossColor: Colors.red,
  
  // Volume
  showVolume: true,
  volumeColor: Colors.grey,
  volumeHeightFactor: 0.2,
  
  // Grid
  priceGridLineColor: Colors.grey.withOpacity(0.2),
  
  // Labels
  priceLabelStyle: TextStyle(color: Colors.white, fontSize: 12),
  timeLabelStyle: TextStyle(color: Colors.white, fontSize: 12),
  
  // Selection
  selectionHighlightColor: Colors.blue.withOpacity(0.2),
)
```

### Indicator Styles

Each indicator has its own style class:
- `RSIStyle`
- `MACDStyle`
- `BollingerBandsStyle`
- `StochasticStyle`
- `ATRStyle`
- And more...

### Overlay Styles

- `TradingLineStyle` - Line appearance
- `PriceZoneStyle` - Zone colors and borders
- `FibonacciStyle` - Fib level colors
- `TrendLineStyle` - Trend line appearance

---

## 🔄 Event System

All managers support event listeners:

```dart
// Trading Lines
lineManager.addListener((event) {
  switch (event.type) {
    case TradingLineEventType.added:
      print('Line added: ${event.line.id}');
      break;
    case TradingLineEventType.priceChanged:
      print('Price changed: ${event.line.price}');
      break;
    case TradingLineEventType.removed:
      print('Line removed');
      break;
  }
});

// Price Zones
zoneManager.addListener((event) {
  print('Zone event: ${event.type}');
});

// Fibonacci
fibManager.addListener((event) {
  print('Fibonacci event: ${event.type}');
});

// Trend Lines
trendLineManager.addListener((event) {
  print('Trend line event: ${event.type}');
});
```

---

## 📱 Platform Support

| Platform | Supported |
|----------|-----------|
| iOS | ✅ |
| Android | ✅ |
| Web | ✅ |
| macOS | ✅ |
| Windows | ✅ |
| Linux | ✅ |

---

## 📄 License

This project is available under a **dual licensing model**:

### Free License
- ✅ Use in personal projects
- ✅ Use in commercial applications (unmodified)
- ✅ Educational and research use
- ❌ Cannot sell or redistribute modified versions

### Commercial License
For modifying and redistributing the library commercially:
- 🥉 **Startup**: $499/year
- 🥈 **Business**: $1,999/year
- 🥇 **Enterprise**: $4,999/year
- 💎 **Perpetual**: Contact us

See [LICENSE](LICENSE) and [COMMERCIAL_LICENSE.md](COMMERCIAL_LICENSE.md) for details.

**Contact**: https://pipsend.com

---

## 🤝 Contributing

We welcome contributions! However, please note:
- This is a commercially licensed project
- Contributors must sign a CLA
- See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines

---

## 💬 Support

### Free License Users
- 📚 [Documentation](https://github.com/ArcaTechCo/PipsendChartsFl/wiki)
- 💬 [GitHub Discussions](https://github.com/ArcaTechCo/PipsendChartsFl/discussions)
- 🐛 [GitHub Issues](https://github.com/ArcaTechCo/PipsendChartsFl/issues)

### Commercial License Users
- 📧 Priority Email Support
- 💬 Private Slack Channel (Business+)
- 📞 Video Calls (Enterprise)
- 👨‍💼 Dedicated Account Manager (Enterprise)

---

## 🙏 Acknowledgments

This project is based on [interactive_chart](https://github.com/MassimoTambu/interactive_chart) by Mehdi Zarepour.

Special thanks to the Flutter community for their support and contributions.

---

## 📞 Contact

**Pipsend**  
📧 Email: https://pipsend.com  
🌐 Website: https://github.com/ArcaTechCo/PipsendChartsFl  
💬 Discussions: https://github.com/ArcaTechCo/PipsendChartsFl/discussions

---

<div align="center">

**Made with ❤️ by Pipsend**

[⭐ Star us on GitHub](https://github.com/ArcaTechCo/PipsendChartsFl) • [📦 View on pub.dev](https://pub.dev) • [📖 Documentation](https://github.com/ArcaTechCo/PipsendChartsFl/wiki)

</div>