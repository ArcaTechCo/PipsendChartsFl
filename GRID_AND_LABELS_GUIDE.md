# 📐 Version 1.0.6 Features - Complete Implementation Guide

**Version:** 1.0.6  
**Features:** Grid Configurable, Adaptive Labels & Infinite History

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Grid Configurable](#grid-configurable)
3. [Adaptive Labels](#adaptive-labels)
4. [Infinite History](#infinite-history)
5. [Complete Examples](#complete-examples)
6. [Best Practices](#best-practices)
7. [Troubleshooting](#troubleshooting)

---

## Overview

Version 1.0.6 introduces three powerful features to enhance chart functionality and user experience:

### **Grid Configurable** 🎨
Customize horizontal and vertical grid lines with full control over style, color, and thickness.

### **Adaptive Labels** 📏
Labels automatically adjust to chart size, ensuring optimal readability on any device.

### **Infinite History** 📜
Load historical data dynamically as users scroll, similar to TradingView's lazy loading.

---

## Grid Configurable

### Quick Start

#### 1. Using Presets (Easiest)

```dart
import 'package:pipsend_charts/pipsend_charts.dart';

InteractiveChart(
  candles: yourCandleData,
  style: ChartStyle(
    gridStyle: GridStyle.full,  // Show both horizontal and vertical
  ),
)
```

**Available Presets:**
- `GridStyle.none` - No grid lines
- `GridStyle.horizontalOnly` - Only horizontal (default)
- `GridStyle.full` - Both horizontal and vertical
- `GridStyle.subtle` - Low opacity (10%)
- `GridStyle.dashed` - Dashed style
- `GridStyle.dotted` - Dotted style

---

### 2. Custom Grid Configuration

```dart
InteractiveChart(
  candles: yourCandleData,
  style: ChartStyle(
    gridStyle: GridStyle(
      // Horizontal Grid (Price levels)
      showHorizontalGrid: true,
      horizontalLineStyle: GridLineStyle.solid,
      horizontalStrokeWidth: 1.0,
      horizontalGridColor: Colors.grey.withOpacity(0.3),
      
      // Vertical Grid (Time intervals)
      showVerticalGrid: true,
      verticalLineStyle: GridLineStyle.dashed,
      verticalStrokeWidth: 0.5,
      verticalGridColor: Colors.grey.withOpacity(0.1),
    ),
  ),
)
```

---

### 3. Grid Line Styles

```dart
enum GridLineStyle {
  solid,      // ─────────
  dashed,     // ─ ─ ─ ─ ─
  dotted,     // · · · · ·
  longDashed, // ── ── ──
}
```

**Example - Different styles for each grid:**

```dart
gridStyle: GridStyle(
  showHorizontalGrid: true,
  horizontalLineStyle: GridLineStyle.solid,  // Solid horizontal
  
  showVerticalGrid: true,
  verticalLineStyle: GridLineStyle.dotted,   // Dotted vertical
)
```

---

### 4. Customizing Colors and Opacity

#### Light Theme
```dart
gridStyle: GridStyle(
  showHorizontalGrid: true,
  showVerticalGrid: true,
  horizontalGridColor: Colors.grey.withOpacity(0.3),  // 30% opacity
  verticalGridColor: Colors.grey.withOpacity(0.15),   // 15% opacity
)
```

#### Dark Theme
```dart
gridStyle: GridStyle(
  showHorizontalGrid: true,
  showVerticalGrid: true,
  horizontalGridColor: Colors.white.withOpacity(0.2),  // 20% opacity
  verticalGridColor: Colors.white.withOpacity(0.1),    // 10% opacity
)
```

#### Custom Colors
```dart
gridStyle: GridStyle(
  showHorizontalGrid: true,
  showVerticalGrid: true,
  horizontalGridColor: Colors.blue.withOpacity(0.2),
  verticalGridColor: Colors.green.withOpacity(0.1),
)
```

---

### 5. Adjusting Line Thickness

```dart
gridStyle: GridStyle(
  showHorizontalGrid: true,
  horizontalStrokeWidth: 0.5,  // Thin lines (0.1 - 3.0)
  
  showVerticalGrid: true,
  verticalStrokeWidth: 1.5,    // Thicker lines
)
```

**Recommended Values:**
- `0.3` - Very thin, subtle
- `0.5` - Thin (default)
- `1.0` - Normal
- `1.5` - Thick
- `2.0+` - Very thick

---

### 6. Grid Only (No Vertical)

```dart
gridStyle: GridStyle(
  showHorizontalGrid: true,
  showVerticalGrid: false,  // Disable vertical
  horizontalLineStyle: GridLineStyle.solid,
  horizontalStrokeWidth: 0.5,
)
```

---

### 7. Professional Trading Style

```dart
gridStyle: GridStyle(
  // Horizontal - Prominent for price levels
  showHorizontalGrid: true,
  horizontalLineStyle: GridLineStyle.solid,
  horizontalStrokeWidth: 1.0,
  horizontalGridColor: Colors.grey.withOpacity(0.3),
  
  // Vertical - Subtle for time
  showVerticalGrid: true,
  verticalLineStyle: GridLineStyle.dotted,
  verticalStrokeWidth: 0.5,
  verticalGridColor: Colors.grey.withOpacity(0.1),
)
```

---

## Adaptive Labels

### Quick Start

#### 1. Automatic (Default - Recommended)

```dart
InteractiveChart(
  candles: yourCandleData,
  style: ChartStyle(
    adaptiveLabels: true,  // Default - labels auto-adjust
  ),
)
```

**Behavior:**
- **Price Labels:** 3-10 labels based on chart height
- **Time Labels:** Dynamic spacing based on chart width
- **Formula:** ~80 pixels per price label
- **Grid Alignment:** Grid lines always align with labels

---

### 2. How It Works

#### Price Labels (Vertical Axis)

| Chart Height | Labels | Calculation |
|--------------|--------|-------------|
| 240px | 3 | min(240/80 = 3) |
| 400px | 5 | 400/80 = 5 |
| 640px | 8 | 640/80 = 8 |
| 800px | 10 | max(800/80 = 10) |

#### Time Labels (Horizontal Axis)

| Chart Width | Labels | Spacing |
|-------------|--------|---------|
| 360px | 4 | 90px default |
| 720px | 8 | 90px default |
| 1920px | 21 | 90px default |

---

### 3. Manual Override

When you need precise control:

```dart
InteractiveChart(
  candles: yourCandleData,
  style: ChartStyle(
    adaptiveLabels: false,        // Disable automatic
    priceLabelCount: 7,            // Force 7 price labels
    timeLabelDensity: 100,         // One label every 100px
  ),
)
```

**Parameters:**
- `priceLabelCount`: 3-10 (number of price labels)
- `timeLabelDensity`: 60-120 (pixels between time labels)

---

### 4. Device-Specific Examples

#### Mobile (Small Screen)
```dart
// Automatic - Recommended
style: ChartStyle(
  adaptiveLabels: true,
)
// Result: 3-4 price labels, 4-5 time labels
```

#### Tablet (Medium Screen)
```dart
// Automatic - Recommended
style: ChartStyle(
  adaptiveLabels: true,
)
// Result: 5-6 price labels, 8-10 time labels
```

#### Desktop (Large Screen)
```dart
// Automatic - Recommended
style: ChartStyle(
  adaptiveLabels: true,
)
// Result: 8-10 price labels, 20+ time labels
```

---

### 5. Manual Control for Specific Needs

#### Dense Labels (More Information)
```dart
style: ChartStyle(
  adaptiveLabels: false,
  priceLabelCount: 10,      // Maximum
  timeLabelDensity: 60,     // Minimum spacing (more labels)
)
```

#### Sparse Labels (Clean Look)
```dart
style: ChartStyle(
  adaptiveLabels: false,
  priceLabelCount: 3,       // Minimum
  timeLabelDensity: 120,    // Maximum spacing (fewer labels)
)
```

---

## Infinite History

Load historical data dynamically as the user scrolls, perfect for large datasets and real-time applications.

### Quick Start

#### 1. Basic Implementation

```dart
import 'package:flutter/material.dart';
import 'package:pipsend_charts/pipsend_charts.dart';

class ChartWithHistory extends StatefulWidget {
  @override
  State<ChartWithHistory> createState() => _ChartWithHistoryState();
}

class _ChartWithHistoryState extends State<ChartWithHistory> {
  List<CandleData> _candles = [];
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }
  
  Future<void> _loadInitialData() async {
    // Load initial 100 candles
    final data = await fetchCandles(limit: 100);
    setState(() => _candles = data);
  }
  
  Future<void> _loadMoreHistory() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    // Fetch older data
    final oldestTimestamp = _candles.first.timestamp;
    final moreData = await fetchCandles(
      before: oldestTimestamp,
      limit: 50,
    );
    
    setState(() {
      _candles = [...moreData, ..._candles];  // Prepend
      _isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return InteractiveChart(
      candles: _candles,
      onXOffsetChanged: (details) {
        // Load more when near start
        if (details.isNearStart(50) && !_isLoading) {
          // IMPORTANT: Use Future.microtask to avoid setState during build
          Future.microtask(() => _loadMoreHistory());
        }
      },
    );
  }
}
```

**Key Points:**
- ✅ Use `Future.microtask()` to avoid `setState()` during build
- ✅ Prepend new data: `[...newData, ...existingData]`
- ✅ Check `_isLoading` flag to prevent duplicate requests
- ✅ Visual position is maintained automatically

---

### 2. Understanding XAxisOffsetDetails

The `onXOffsetChanged` callback provides an `XAxisOffsetDetails` object with useful properties:

```dart
class XAxisOffsetDetails {
  final double offset;              // Current scroll offset
  final int startCandleIndex;       // First visible candle
  final int endCandleIndex;         // Last visible candle
  final int totalCandles;           // Total candles in dataset
  
  // New in 1.0.6
  int get candlesBeforeVisible;     // Candles before visible area
  int get candlesAfterVisible;      // Candles after visible area
  bool isNearStart([int threshold = 50]);  // Near beginning?
  bool isNearEnd([int threshold = 50]);    // Near end?
}
```

**Example Usage:**
```dart
onXOffsetChanged: (details) {
  print('Visible: ${details.startCandleIndex} - ${details.endCandleIndex}');
  print('Before visible: ${details.candlesBeforeVisible}');
  print('After visible: ${details.candlesAfterVisible}');
  print('Near start: ${details.isNearStart(50)}');
  print('Near end: ${details.isNearEnd(50)}');
}
```

---

### 3. Bidirectional Loading

Load data in both directions (past and future):

```dart
class BidirectionalChart extends StatefulWidget {
  @override
  State<BidirectionalChart> createState() => _BidirectionalChartState();
}

class _BidirectionalChartState extends State<BidirectionalChart> {
  List<CandleData> _candles = [];
  bool _isLoadingHistory = false;
  bool _isLoadingRecent = false;
  
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }
  
  Future<void> _loadInitialData() async {
    final data = await fetchCandles(limit: 100);
    setState(() => _candles = data);
  }
  
  Future<void> _loadMoreHistory() async {
    if (_isLoadingHistory) return;
    
    setState(() => _isLoadingHistory = true);
    
    try {
      final oldestTimestamp = _candles.first.timestamp;
      final moreData = await fetchCandles(
        before: oldestTimestamp,
        limit: 50,
      );
      
      setState(() {
        _candles = [...moreData, ..._candles];  // Prepend
      });
    } finally {
      setState(() => _isLoadingHistory = false);
    }
  }
  
  Future<void> _loadMoreRecent() async {
    if (_isLoadingRecent) return;
    
    setState(() => _isLoadingRecent = true);
    
    try {
      final newestTimestamp = _candles.last.timestamp;
      final moreData = await fetchCandles(
        after: newestTimestamp,
        limit: 50,
      );
      
      setState(() {
        _candles = [..._candles, ...moreData];  // Append
      });
    } finally {
      setState(() => _isLoadingRecent = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return InteractiveChart(
      candles: _candles,
      onXOffsetChanged: (details) {
        // Load historical data when scrolling left
        if (details.isNearStart(50) && !_isLoadingHistory) {
          Future.microtask(() => _loadMoreHistory());
        }
        
        // Load recent data when scrolling right
        if (details.isNearEnd(50) && !_isLoadingRecent) {
          Future.microtask(() => _loadMoreRecent());
        }
      },
    );
  }
}
```

---

### 4. With Loading Indicators

Show visual feedback during data loading:

```dart
class ChartWithLoadingIndicators extends StatefulWidget {
  @override
  State<ChartWithLoadingIndicators> createState() => 
      _ChartWithLoadingIndicatorsState();
}

class _ChartWithLoadingIndicatorsState 
    extends State<ChartWithLoadingIndicators> {
  List<CandleData> _candles = [];
  bool _isLoadingHistory = false;
  bool _isLoadingRecent = false;
  
  // ... (same loading methods as above)
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InteractiveChart(
          candles: _candles,
          onXOffsetChanged: (details) {
            if (details.isNearStart(50) && !_isLoadingHistory) {
              Future.microtask(() => _loadMoreHistory());
            }
            if (details.isNearEnd(50) && !_isLoadingRecent) {
              Future.microtask(() => _loadMoreRecent());
            }
          },
        ),
        
        // Loading indicator - Left (History)
        if (_isLoadingHistory)
          Positioned(
            left: 16,
            top: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Loading history...',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        
        // Loading indicator - Right (Recent)
        if (_isLoadingRecent)
          Positioned(
            right: 16,
            top: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Loading recent...',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
```

---

### 5. Custom Threshold

Adjust when to trigger loading:

```dart
onXOffsetChanged: (details) {
  // Load when 100 candles away from edge (more aggressive)
  if (details.isNearStart(100) && !_isLoading) {
    Future.microtask(() => _loadMoreHistory());
  }
  
  // Load when 20 candles away (less aggressive)
  if (details.isNearStart(20) && !_isLoading) {
    Future.microtask(() => _loadMoreHistory());
  }
}
```

**Threshold Guidelines:**
- `20-30` - Conservative (load very close to edge)
- `50` - Balanced (default, recommended)
- `100+` - Aggressive (preload early)

---

### 6. With API Integration

Real-world example with API calls:

```dart
class ApiChartScreen extends StatefulWidget {
  final String symbol;
  
  const ApiChartScreen({required this.symbol});
  
  @override
  State<ApiChartScreen> createState() => _ApiChartScreenState();
}

class _ApiChartScreenState extends State<ApiChartScreen> {
  List<CandleData> _candles = [];
  bool _isLoading = false;
  bool _hasMoreData = true;
  
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }
  
  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await http.get(
        Uri.parse('https://api.example.com/candles/${widget.symbol}?limit=100'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final candles = data.map((json) => CandleData.fromJson(json)).toList();
        
        setState(() {
          _candles = candles;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _loadMoreHistory() async {
    if (_isLoading || !_hasMoreData) return;
    
    setState(() => _isLoading = true);
    
    try {
      final oldestTimestamp = _candles.first.timestamp;
      final response = await http.get(
        Uri.parse(
          'https://api.example.com/candles/${widget.symbol}'
          '?before=$oldestTimestamp&limit=50'
        ),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final candles = data.map((json) => CandleData.fromJson(json)).toList();
        
        setState(() {
          if (candles.isEmpty) {
            _hasMoreData = false;  // No more data available
          } else {
            _candles = [...candles, ..._candles];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading history: $e');
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.symbol} Chart')),
      body: _candles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : InteractiveChart(
              candles: _candles,
              onXOffsetChanged: (details) {
                if (details.isNearStart(50) && !_isLoading && _hasMoreData) {
                  Future.microtask(() => _loadMoreHistory());
                }
              },
            ),
    );
  }
}
```

---

### 7. Error Handling

Robust error handling for production:

```dart
Future<void> _loadMoreHistory() async {
  if (_isLoading) return;
  
  setState(() => _isLoading = true);
  
  try {
    final oldestTimestamp = _candles.first.timestamp;
    final moreData = await fetchCandles(
      before: oldestTimestamp,
      limit: 50,
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw TimeoutException('Request timeout'),
    );
    
    if (!mounted) return;  // Check if widget is still mounted
    
    setState(() {
      _candles = [...moreData, ..._candles];
      _isLoading = false;
    });
  } on TimeoutException {
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request timeout. Please try again.')),
    );
  } catch (e) {
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error loading data: $e')),
    );
  }
}
```

---

### 8. Caching Strategy

Implement caching to avoid redundant API calls:

```dart
class CachedChartScreen extends StatefulWidget {
  @override
  State<CachedChartScreen> createState() => _CachedChartScreenState();
}

class _CachedChartScreenState extends State<CachedChartScreen> {
  List<CandleData> _candles = [];
  bool _isLoading = false;
  final Set<int> _loadedTimestamps = {};  // Track loaded data
  
  Future<void> _loadMoreHistory() async {
    if (_isLoading) return;
    
    final oldestTimestamp = _candles.first.timestamp;
    
    // Check if already loaded
    if (_loadedTimestamps.contains(oldestTimestamp)) {
      print('Data already loaded, skipping...');
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final moreData = await fetchCandles(
        before: oldestTimestamp,
        limit: 50,
      );
      
      // Mark as loaded
      for (var candle in moreData) {
        _loadedTimestamps.add(candle.timestamp);
      }
      
      setState(() {
        _candles = [...moreData, ..._candles];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return InteractiveChart(
      candles: _candles,
      onXOffsetChanged: (details) {
        if (details.isNearStart(50) && !_isLoading) {
          Future.microtask(() => _loadMoreHistory());
        }
      },
    );
  }
}
```

---

## Complete Examples

### Example 1: Professional Trading Chart

```dart
import 'package:flutter/material.dart';
import 'package:pipsend_charts/pipsend_charts.dart';

class TradingChartScreen extends StatelessWidget {
  final List<CandleData> candles;
  
  const TradingChartScreen({required this.candles});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trading Chart')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: InteractiveChart(
          candles: candles,
          style: ChartStyle(
            // Adaptive labels for all devices
            adaptiveLabels: true,
            
            // Professional grid
            gridStyle: GridStyle(
              // Horizontal - Clear price levels
              showHorizontalGrid: true,
              horizontalLineStyle: GridLineStyle.solid,
              horizontalStrokeWidth: 1.0,
              horizontalGridColor: Colors.grey.withOpacity(0.3),
              
              // Vertical - Subtle time markers
              showVerticalGrid: true,
              verticalLineStyle: GridLineStyle.dotted,
              verticalStrokeWidth: 0.5,
              verticalGridColor: Colors.grey.withOpacity(0.1),
            ),
            
            // Other styling
            priceGainColor: Colors.green,
            priceLossColor: Colors.red,
            candleBorderRadius: 2.0,
          ),
        ),
      ),
    );
  }
}
```

---

### Example 2: Minimal Clean Chart

```dart
InteractiveChart(
  candles: candles,
  style: ChartStyle(
    // Adaptive labels
    adaptiveLabels: true,
    
    // Minimal grid - horizontal only
    gridStyle: GridStyle.horizontalOnly,
    
    // Clean styling
    priceGainColor: Colors.teal,
    priceLossColor: Colors.orange,
    candleBorderRadius: 4.0,
  ),
)
```

---

### Example 3: High-Contrast Grid

```dart
InteractiveChart(
  candles: candles,
  style: ChartStyle(
    // Adaptive labels
    adaptiveLabels: true,
    
    // High-contrast grid
    gridStyle: GridStyle(
      showHorizontalGrid: true,
      showVerticalGrid: true,
      horizontalLineStyle: GridLineStyle.solid,
      verticalLineStyle: GridLineStyle.solid,
      horizontalStrokeWidth: 1.5,
      verticalStrokeWidth: 1.5,
      horizontalGridColor: Colors.grey.withOpacity(0.5),
      verticalGridColor: Colors.grey.withOpacity(0.5),
    ),
  ),
)
```

---

### Example 4: Theme-Aware Grid

```dart
class ThemedChart extends StatelessWidget {
  final List<CandleData> candles;
  
  const ThemedChart({required this.candles});
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InteractiveChart(
      candles: candles,
      style: ChartStyle(
        adaptiveLabels: true,
        gridStyle: GridStyle(
          showHorizontalGrid: true,
          showVerticalGrid: true,
          horizontalLineStyle: GridLineStyle.solid,
          verticalLineStyle: GridLineStyle.dashed,
          horizontalStrokeWidth: 0.5,
          verticalStrokeWidth: 0.5,
          // Theme-aware colors
          horizontalGridColor: isDark 
            ? Colors.white.withOpacity(0.2)
            : Colors.grey.withOpacity(0.3),
          verticalGridColor: isDark
            ? Colors.white.withOpacity(0.1)
            : Colors.grey.withOpacity(0.15),
        ),
        priceGainColor: Colors.green,
        priceLossColor: Colors.red,
      ),
    );
  }
}
```

---

### Example 5: User-Configurable Grid

```dart
class ConfigurableChartScreen extends StatefulWidget {
  final List<CandleData> candles;
  
  const ConfigurableChartScreen({required this.candles});
  
  @override
  State<ConfigurableChartScreen> createState() => _ConfigurableChartScreenState();
}

class _ConfigurableChartScreenState extends State<ConfigurableChartScreen> {
  bool _showHorizontalGrid = true;
  bool _showVerticalGrid = true;
  GridLineStyle _horizontalStyle = GridLineStyle.solid;
  GridLineStyle _verticalStyle = GridLineStyle.dashed;
  double _horizontalWidth = 0.5;
  double _verticalWidth = 0.5;
  bool _adaptiveLabels = true;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurable Chart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
          ),
        ],
      ),
      body: InteractiveChart(
        candles: widget.candles,
        style: ChartStyle(
          adaptiveLabels: _adaptiveLabels,
          gridStyle: GridStyle(
            showHorizontalGrid: _showHorizontalGrid,
            showVerticalGrid: _showVerticalGrid,
            horizontalLineStyle: _horizontalStyle,
            verticalLineStyle: _verticalStyle,
            horizontalStrokeWidth: _horizontalWidth,
            verticalStrokeWidth: _verticalWidth,
            horizontalGridColor: Colors.grey.withOpacity(0.3),
            verticalGridColor: Colors.grey.withOpacity(0.15),
          ),
        ),
      ),
    );
  }
  
  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Horizontal Grid'),
              value: _showHorizontalGrid,
              onChanged: (val) => setState(() => _showHorizontalGrid = val),
            ),
            SwitchListTile(
              title: const Text('Vertical Grid'),
              value: _showVerticalGrid,
              onChanged: (val) => setState(() => _showVerticalGrid = val),
            ),
            SwitchListTile(
              title: const Text('Adaptive Labels'),
              value: _adaptiveLabels,
              onChanged: (val) => setState(() => _adaptiveLabels = val),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Best Practices

### ✅ Do's

#### Grid & Labels
1. **Use Adaptive Labels by Default**
   ```dart
   adaptiveLabels: true  // Let the chart optimize for device
   ```

2. **Match Grid to Theme**
   ```dart
   // Light theme: Grey with 30% opacity
   // Dark theme: White with 20% opacity
   ```

3. **Subtle Vertical Grid**
   ```dart
   verticalGridColor: Colors.grey.withOpacity(0.1)  // Less prominent
   ```

4. **Use Presets for Quick Setup**
   ```dart
   gridStyle: GridStyle.full  // Fast and reliable
   ```

5. **Test on Multiple Screen Sizes**
   - Mobile (360x640)
   - Tablet (768x1024)
   - Desktop (1920x1080)

#### Infinite History
6. **Always Use Future.microtask()**
   ```dart
   if (details.isNearStart(50)) {
     Future.microtask(() => _loadMoreHistory());  // ✅ Correct
   }
   ```

7. **Implement Loading Flags**
   ```dart
   bool _isLoading = false;  // Prevent duplicate requests
   ```

8. **Prepend Historical Data**
   ```dart
   _candles = [...newData, ..._candles];  // ✅ Correct order
   ```

9. **Use Appropriate Thresholds**
   ```dart
   details.isNearStart(50)  // Balanced (recommended)
   ```

10. **Add Loading Indicators**
    ```dart
    if (_isLoading) CircularProgressIndicator()
    ```

11. **Handle Errors Gracefully**
    ```dart
    try {
      // Load data
    } catch (e) {
      // Show error to user
    }
    ```

12. **Check Widget Mounted State**
    ```dart
    if (!mounted) return;  // Before setState
    ```

---

### ❌ Don'ts

1. **Don't Disable Adaptive Without Reason**
   ```dart
   // ❌ Bad - Fixed labels on all devices
   adaptiveLabels: false,
   priceLabelCount: 5,
   ```

2. **Don't Use Too Many Labels**
   ```dart
   // ❌ Bad - Cluttered
   priceLabelCount: 10,
   timeLabelDensity: 60,
   ```

3. **Don't Use High Opacity on Both Grids**
   ```dart
   // ❌ Bad - Too prominent
   horizontalGridColor: Colors.grey.withOpacity(0.8),
   verticalGridColor: Colors.grey.withOpacity(0.8),
   ```

4. **Don't Mix Too Many Styles**
   ```dart
   // ❌ Bad - Inconsistent
   horizontalLineStyle: GridLineStyle.dotted,
   verticalLineStyle: GridLineStyle.longDashed,
   ```

#### Infinite History
5. **Don't Call setState Directly**
   ```dart
   // ❌ Bad - Causes error
   if (details.isNearStart(50)) {
     _loadMoreHistory();  // setState during build
   }
   
   // ✅ Good
   if (details.isNearStart(50)) {
     Future.microtask(() => _loadMoreHistory());
   }
   ```

6. **Don't Forget Loading Flags**
   ```dart
   // ❌ Bad - Multiple simultaneous requests
   if (details.isNearStart(50)) {
     _loadMoreHistory();
   }
   
   // ✅ Good
   if (details.isNearStart(50) && !_isLoading) {
     _loadMoreHistory();
   }
   ```

7. **Don't Append Historical Data**
   ```dart
   // ❌ Bad - Wrong order
   _candles = [..._candles, ...newData];
   
   // ✅ Good - Prepend
   _candles = [...newData, ..._candles];
   ```

8. **Don't Ignore Errors**
   ```dart
   // ❌ Bad - Silent failures
   await fetchCandles();
   
   // ✅ Good - Handle errors
   try {
     await fetchCandles();
   } catch (e) {
     // Show error to user
   }
   ```

---

## Troubleshooting

### Grid Issues

### Issue 1: Grid Lines Not Visible

**Problem:** Grid lines don't appear on the chart.

**Solutions:**
```dart
// 1. Check if grid is enabled
gridStyle: GridStyle(
  showHorizontalGrid: true,  // ✅ Must be true
  showVerticalGrid: true,    // ✅ Must be true
)

// 2. Increase opacity
horizontalGridColor: Colors.grey.withOpacity(0.5),  // ✅ Higher opacity

// 3. Increase stroke width
horizontalStrokeWidth: 1.0,  // ✅ Thicker lines
```

---

### Issue 2: Too Many/Few Labels

**Problem:** Labels are too dense or too sparse.

**Solutions:**
```dart
// Option 1: Let adaptive handle it (recommended)
adaptiveLabels: true,

// Option 2: Manual adjustment
adaptiveLabels: false,
priceLabelCount: 6,        // Adjust this
timeLabelDensity: 90,      // Adjust this
```

---

### Issue 3: Grid Not Aligned with Labels

**Problem:** Grid lines don't match label positions.

**Solution:**
This should never happen as grid lines are automatically aligned. If it does:
1. Ensure you're using version 1.0.6+
2. Check that you haven't modified `ChartPainter` manually
3. Report as a bug if issue persists

---

### Issue 4: Performance Issues

**Problem:** Chart feels slow with grid enabled.

**Solutions:**
```dart
// 1. Use solid lines (fastest)
horizontalLineStyle: GridLineStyle.solid,
verticalLineStyle: GridLineStyle.solid,

// 2. Reduce stroke width
horizontalStrokeWidth: 0.5,
verticalStrokeWidth: 0.5,

// 3. Disable vertical grid if not needed
showVerticalGrid: false,
```

---

### Issue 5: Grid Color Not Visible on Background

**Problem:** Grid blends with background color.

**Solutions:**
```dart
// For light backgrounds
gridStyle: GridStyle(
  horizontalGridColor: Colors.grey.withOpacity(0.3),
  verticalGridColor: Colors.grey.withOpacity(0.15),
)

// For dark backgrounds
gridStyle: GridStyle(
  horizontalGridColor: Colors.white.withOpacity(0.2),
  verticalGridColor: Colors.white.withOpacity(0.1),
)

// For custom backgrounds
gridStyle: GridStyle(
  // Use contrasting color
  horizontalGridColor: Colors.blue.withOpacity(0.3),
)
```

---

### Infinite History Issues

### Issue 6: setState() During Build Error

**Problem:** `FlutterError: setState() or markNeedsBuild() called during build`

**Solution:**
```dart
// ❌ Wrong
onXOffsetChanged: (details) {
  if (details.isNearStart(50)) {
    _loadMoreHistory();  // Calls setState during build
  }
}

// ✅ Correct
onXOffsetChanged: (details) {
  if (details.isNearStart(50)) {
    Future.microtask(() => _loadMoreHistory());  // Defers setState
  }
}
```

---

### Issue 7: Chart Jumps When Loading Data

**Problem:** Chart position jumps unexpectedly when prepending data.

**Solution:**
The chart automatically maintains position. If jumping occurs:
1. Ensure you're prepending (not appending) historical data
2. Check that you're using version 1.0.6+
3. Verify data order is correct (oldest first)

```dart
// ✅ Correct - Prepend
_candles = [...newHistoricalData, ..._candles];

// ❌ Wrong - Append
_candles = [..._candles, ...newHistoricalData];
```

---

### Issue 8: Multiple Simultaneous Requests

**Problem:** Multiple API calls triggered at once.

**Solution:**
```dart
// Add loading flag
bool _isLoading = false;

Future<void> _loadMoreHistory() async {
  if (_isLoading) return;  // ✅ Prevent duplicate calls
  
  setState(() => _isLoading = true);
  
  try {
    // Load data
  } finally {
    setState(() => _isLoading = false);
  }
}
```

---

### Issue 9: Data Not Loading

**Problem:** `isNearStart()` returns true but data doesn't load.

**Checklist:**
1. ✅ Check `_isLoading` flag
2. ✅ Verify API endpoint is correct
3. ✅ Check network connectivity
4. ✅ Add error handling to see exceptions
5. ✅ Verify `Future.microtask()` is used

```dart
Future<void> _loadMoreHistory() async {
  print('Loading history...');  // Debug
  
  try {
    final data = await fetchCandles();
    print('Loaded ${data.length} candles');  // Debug
    
    setState(() => _candles = [...data, ..._candles]);
  } catch (e) {
    print('Error: $e');  // See actual error
  }
}
```

---

### Issue 10: Performance Degradation

**Problem:** Chart becomes slow with many candles.

**Solutions:**
1. **Limit Total Candles**
   ```dart
   // Keep only last 1000 candles
   if (_candles.length > 1000) {
     _candles = _candles.sublist(_candles.length - 1000);
   }
   ```

2. **Implement Pagination**
   ```dart
   // Load smaller batches
   final moreData = await fetchCandles(limit: 20);  // Instead of 50
   ```

3. **Use Caching**
   ```dart
   // Cache loaded data to avoid re-fetching
   final Set<int> _loadedTimestamps = {};
   ```

---

## Migration from 1.0.5

### Old Code (1.0.5)
```dart
InteractiveChart(
  candles: data,
  style: ChartStyle(
    priceGridLineColor: Colors.grey,  // Deprecated
  ),
)
```

### New Code (1.0.6)
```dart
InteractiveChart(
  candles: data,
  style: ChartStyle(
    gridStyle: GridStyle(
      showHorizontalGrid: true,
      horizontalGridColor: Colors.grey.withOpacity(0.3),
    ),
  ),
)
```

**Note:** Old code still works (backward compatible) but will show deprecation warning.

---

## Summary

### Grid Configurable 🎨
- ✅ 4 line styles (solid, dashed, dotted, longDashed)
- ✅ Independent horizontal/vertical control
- ✅ Customizable colors, opacity, and thickness
- ✅ 6 built-in presets
- ✅ Always aligned with labels
- ✅ Theme-aware colors

### Adaptive Labels 📏
- ✅ Automatic adjustment to chart size
- ✅ 3-10 price labels (based on height)
- ✅ Dynamic time labels (based on width)
- ✅ Manual override available
- ✅ Grid synchronization
- ✅ Optimal readability on all devices

### Infinite History 📜
- ✅ Dynamic data loading on scroll
- ✅ Bidirectional loading (past & future)
- ✅ XAxisOffsetDetails helpers
- ✅ Automatic position maintenance
- ✅ Loading indicators support
- ✅ Error handling built-in
- ✅ Caching strategies available

---

## Support

- **Documentation:** [README.md](README.md)
- **Changelog:** [CHANGELOG.md](CHANGELOG.md)
- **Issues:** [GitHub Issues](https://github.com/ArcaTechCo/PipsendChartsFl/issues)
- **Example App:** Run `flutter run` in the `example` folder

---

**Version:** 1.0.6  
**Last Updated:** December 2025  
**License:** Dual License (Free + Commercial)
