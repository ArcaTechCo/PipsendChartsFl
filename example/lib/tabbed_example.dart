import 'package:flutter/material.dart';
import 'package:pipsend_charts/pipsend_charts.dart';
import 'mock_data.dart';

/// Tabbed example with different chart features organized by category
class TabbedChartExample extends StatefulWidget {
  const TabbedChartExample({Key? key}) : super(key: key);

  @override
  State<TabbedChartExample> createState() => _TabbedChartExampleState();
}

class _TabbedChartExampleState extends State<TabbedChartExample> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<CandleData> _data = MockDataTesla.candles;
  
  // Managers
  final TradingLineManager _lineManager = TradingLineManager();
  final PriceZoneManager _zoneManager = PriceZoneManager();
  final FibonacciManager _fibonacciManager = FibonacciManager();
  final TrendLineManager _trendLineManager = TrendLineManager();
  
  // Settings
  bool _darkMode = true;
  bool _showVolume = true;
  
  // Indicator toggles
  bool _showSMA20 = false;
  bool _showSMA50 = false;
  bool _showEMA12 = false;
  bool _showEMA26 = false;
  bool _showRSI = false;
  bool _showMACD = false;
  bool _showStochastic = false;
  bool _showATR = false;
  bool _showADX = false;
  bool _showCCI = false;
  bool _showWilliamsR = false;
  bool _showOBV = false;
  bool _showBB = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _setupListeners();
    _setupExampleData();
  }

  void _setupListeners() {
    // Listen to manager events to trigger rebuilds
    _lineManager.addListener((event) {
      setState(() {});
    });
    
    _zoneManager.addListener((event) {
      setState(() {});
    });
    
    _fibonacciManager.addListener((event) {
      setState(() {});
    });
    
    _trendLineManager.addListener((event) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _setupExampleData() {
    // Setup example trading lines
    final currentPrice = _data.last.close ?? 150.0;
    
    final entryId = 'entry_1';
    _lineManager.addLine(TradingLine(
      id: entryId,
      price: currentPrice,
      type: TradingLineType.entry,
      options: TradingLineOptions(
        title: 'Entry',
        showPrice: true,
        draggable: true,
        onPriceChanged: (newPrice) {
          _lineManager.updateLinePrice(entryId, newPrice);
        },
      ),
    ));

    // Setup example price zones
    final demandId = 'demand_1';
    _zoneManager.addZone(PriceZone(
      id: demandId,
      minPrice: currentPrice * 0.92,
      maxPrice: currentPrice * 0.95,
      type: PriceZoneType.demand,
      options: PriceZoneOptions(
        label: 'Demand Zone',
        showLabel: true,
        draggable: true,
        onRangeChanged: (newMin, newMax) {
          _zoneManager.updateZoneRange(demandId, newMin, newMax);
        },
      ),
    ));

    // Setup example Fibonacci
    final fibId = 'fib_1';
    _fibonacciManager.addFibonacci(FibonacciRetracement(
      id: fibId,
      highPrice: currentPrice * 1.075,
      lowPrice: currentPrice * 0.925,
      options: FibonacciOptions(
        showLabels: true,
        showPercentages: true,
        draggable: true,
        onMoved: (newHigh, newLow) {
          _fibonacciManager.updateFibonacciRange(fibId, newHigh, newLow);
        },
      ),
    ));

    // Setup example Trend Line
    final startIndex = _data.length > 60 ? _data.length - 60 : 0;
    final endIndex = _data.length > 10 ? _data.length - 10 : _data.length - 1;
    
    final trendId = 'trend_1';
    _trendLineManager.addTrendLine(TrendLine(
      id: trendId,
      startTime: _data[startIndex].timestamp,
      startPrice: (_data[startIndex].low ?? 0) * 0.98,
      endTime: _data[endIndex].timestamp,
      endPrice: (_data[endIndex].high ?? 0) * 1.02,
      style: const TrendLineStyle(color: Color(0xFF4CAF50), lineWidth: 2.0),
      options: TrendLineOptions(
        draggable: true,
        showAngle: true,
        onMoved: (newStartTime, newStartPrice, newEndTime, newEndPrice) {
          _trendLineManager.updateTrendLinePoints(
            trendId,
            startTime: newStartTime,
            startPrice: newStartPrice,
            endTime: newEndTime,
            endPrice: newEndPrice,
          );
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: _darkMode ? Brightness.dark : Brightness.light,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("PipsendCharts Demo"),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(icon: Icon(Icons.show_chart), text: 'Indicators'),
              Tab(icon: Icon(Icons.horizontal_rule), text: 'Trading Lines'),
              Tab(icon: Icon(Icons.layers), text: 'Price Zones'),
              Tab(icon: Icon(Icons.trending_up), text: 'Drawing Tools'),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(_darkMode ? Icons.dark_mode : Icons.light_mode),
              onPressed: () => setState(() => _darkMode = !_darkMode),
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(), // ← Deshabilita swipe entre tabs
          children: [
            _buildIndicatorsTab(),
            _buildTradingLinesTab(),
            _buildPriceZonesTab(),
            _buildDrawingToolsTab(),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // TAB 1: INDICATORS
  // ============================================================================
  Widget _buildIndicatorsTab() {
    return Column(
      children: [
        // Indicator toggles
        Container(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildToggleChip('SMA(20)', _showSMA20, (v) => setState(() => _showSMA20 = v)),
                const SizedBox(width: 8),
                _buildToggleChip('SMA(50)', _showSMA50, (v) => setState(() => _showSMA50 = v)),
                const SizedBox(width: 8),
                _buildToggleChip('EMA(12)', _showEMA12, (v) => setState(() => _showEMA12 = v)),
                const SizedBox(width: 8),
                _buildToggleChip('EMA(26)', _showEMA26, (v) => setState(() => _showEMA26 = v)),
                const SizedBox(width: 8),
                _buildToggleChip('RSI', _showRSI, (v) => setState(() => _showRSI = v)),
                const SizedBox(width: 8),
                _buildToggleChip('MACD', _showMACD, (v) => setState(() => _showMACD = v)),
                const SizedBox(width: 8),
                _buildToggleChip('Stochastic', _showStochastic, (v) => setState(() => _showStochastic = v)),
                const SizedBox(width: 8),
                _buildToggleChip('ATR', _showATR, (v) => setState(() => _showATR = v)),
                const SizedBox(width: 8),
                _buildToggleChip('ADX', _showADX, (v) => setState(() => _showADX = v)),
                const SizedBox(width: 8),
                _buildToggleChip('CCI', _showCCI, (v) => setState(() => _showCCI = v)),
                const SizedBox(width: 8),
                _buildToggleChip('Williams %R', _showWilliamsR, (v) => setState(() => _showWilliamsR = v)),
                const SizedBox(width: 8),
                _buildToggleChip('OBV', _showOBV, (v) => setState(() => _showOBV = v)),
                const SizedBox(width: 8),
                _buildToggleChip('BB', _showBB, (v) => setState(() => _showBB = v)),
                const SizedBox(width: 8),
                _buildToggleChip('Volume', _showVolume, (v) => setState(() => _showVolume = v)),
              ],
            ),
          ),
        ),
        // Chart
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: InteractiveChart(
              candles: _data,
              indicators: [
                if (_showSMA20) SMAIndicator(period: 20, style: SMAStyle(lineColor: Colors.blue)),
                if (_showSMA50) SMAIndicator(period: 50, style: SMAStyle(lineColor: Colors.green)),
                if (_showEMA12) EMAIndicator(period: 12, style: EMAStyle(lineColor: Colors.orange)),
                if (_showEMA26) EMAIndicator(period: 26, style: EMAStyle(lineColor: Colors.red)),
                if (_showRSI) RSIIndicator(period: 14, panel: IndicatorPanel.separate(height: 0.2)),
                if (_showMACD) MACDIndicator(panel: IndicatorPanel.separate(height: 0.25)),
                if (_showStochastic) StochasticIndicator(kPeriod: 14, dPeriod: 3, panel: IndicatorPanel.separate(height: 0.2)),
                if (_showATR) ATRIndicator(period: 14, panel: IndicatorPanel.separate(height: 0.15)),
                if (_showADX) ADXIndicator(period: 14, panel: IndicatorPanel.separate(height: 0.2)),
                if (_showCCI) CCIIndicator(period: 20, panel: IndicatorPanel.separate(height: 0.2)),
                if (_showWilliamsR) WilliamsRIndicator(period: 14, panel: IndicatorPanel.separate(height: 0.2)),
                if (_showOBV) OBVIndicator(panel: IndicatorPanel.separate(height: 0.2)),
                if (_showBB) BollingerBandsIndicator(period: 20),
              ],
              style: ChartStyle(
                showVolume: _showVolume,
                volumeColor: Colors.grey.withOpacity(0.5),
                priceGridLineColor: Colors.grey.withOpacity(0.1),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // TAB 2: TRADING LINES
  // ============================================================================
  Widget _buildTradingLinesTab() {
    return Stack(
      children: [
        Column(
          children: [
            // Info
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Trading Lines: ${_lineManager.count} active',
                style: const TextStyle(fontSize: 12),
              ),
            ),
            // Chart
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: InteractiveChart(
                  candles: _data,
                  overlays: _lineManager.lines,
                  style: ChartStyle(
                    showVolume: _showVolume,
                    volumeColor: Colors.grey.withOpacity(0.5),
                    priceGridLineColor: Colors.grey.withOpacity(0.1),
                  ),
                ),
              ),
            ),
          ],
        ),
        // FAB buttons
        Positioned(
          right: 16,
          bottom: 16,
          child: _buildTradingLineButtons(),
        ),
      ],
    );
  }

  Widget _buildTradingLineButtons() {
    return Builder(
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'add_sl',
            onPressed: () => _addStopLoss(context),
            tooltip: 'Add Stop Loss',
            backgroundColor: Colors.red,
            child: const Text('SL', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'add_tp',
            onPressed: () => _addTakeProfit(context),
            tooltip: 'Add Take Profit',
            backgroundColor: Colors.green,
            child: const Text('TP', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'clear_lines',
            onPressed: () {
              final count = _lineManager.count;
              _lineManager.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Cleared $count trading lines')),
              );
            },
            tooltip: 'Clear All Lines',
            backgroundColor: Colors.grey,
            child: const Icon(Icons.clear_all, size: 20),
          ),
        ],
      ),
    );
  }

  void _addStopLoss(BuildContext context) {
    final currentPrice = _data.last.close ?? 150.0;
    final slPrice = currentPrice * 0.98;
    
    // Generar ID único
    final lineId = 'sl_${DateTime.now().millisecondsSinceEpoch}';
    
    _lineManager.addLine(TradingLine(
      id: lineId,
      price: slPrice,
      type: TradingLineType.stopLoss,
      style: const TradingLineStyle(
        color: Colors.red,
        lineWidth: 2.0,
        dashPattern: [5, 5],
      ),
      options: TradingLineOptions(
        title: 'Stop Loss',
        showPrice: true,
        draggable: true,
        onPriceChanged: (newPrice) {
          // Actualizar el precio en el manager
          _lineManager.updateLinePrice(lineId, newPrice);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('SL moved to \$${newPrice.toStringAsFixed(2)}')),
          );
        },
      ),
    ));
  }

  void _addTakeProfit(BuildContext context) {
    final currentPrice = _data.last.close ?? 150.0;
    final tpPrice = currentPrice * 1.05;
    
    // Generar ID único
    final lineId = 'tp_${DateTime.now().millisecondsSinceEpoch}';
    
    _lineManager.addLine(TradingLine(
      id: lineId,
      price: tpPrice,
      type: TradingLineType.takeProfit,
      style: const TradingLineStyle(
        color: Colors.green,
        lineWidth: 2.0,
      ),
      options: TradingLineOptions(
        title: 'Take Profit',
        showPrice: true,
        draggable: true,
        onPriceChanged: (newPrice) {
          // Actualizar el precio en el manager
          _lineManager.updateLinePrice(lineId, newPrice);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('TP moved to \$${newPrice.toStringAsFixed(2)}')),
          );
        },
      ),
    ));
  }

  // ============================================================================
  // TAB 3: PRICE ZONES
  // ============================================================================
  Widget _buildPriceZonesTab() {
    return Stack(
      children: [
        Column(
          children: [
            // Info
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Price Zones: ${_zoneManager.count} active',
                style: const TextStyle(fontSize: 12),
              ),
            ),
            // Chart
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: InteractiveChart(
                  candles: _data,
                  overlays: _zoneManager.zones,
                  style: ChartStyle(
                    showVolume: _showVolume,
                    volumeColor: Colors.grey.withOpacity(0.5),
                    priceGridLineColor: Colors.grey.withOpacity(0.1),
                  ),
                ),
              ),
            ),
          ],
        ),
        // FAB buttons
        Positioned(
          right: 16,
          bottom: 16,
          child: _buildPriceZoneButtons(),
        ),
      ],
    );
  }

  Widget _buildPriceZoneButtons() {
    return Builder(
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'add_demand',
            onPressed: () => _addDemandZone(context),
            tooltip: 'Add Demand Zone',
            backgroundColor: Colors.blue,
            child: const Text('D', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'add_supply',
            onPressed: () => _addSupplyZone(context),
            tooltip: 'Add Supply Zone',
            backgroundColor: Colors.orange,
            child: const Text('S', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'clear_zones',
            onPressed: () {
              final count = _zoneManager.count;
              _zoneManager.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Cleared $count price zones')),
              );
            },
            tooltip: 'Clear All Zones',
            backgroundColor: Colors.grey,
            child: const Icon(Icons.layers_clear, size: 20),
          ),
        ],
      ),
    );
  }

  void _addDemandZone(BuildContext context) {
    final currentPrice = _data.last.close ?? 150.0;
    final minPrice = currentPrice * 0.90;
    final maxPrice = currentPrice * 0.93;
    
    final zoneId = 'demand_${DateTime.now().millisecondsSinceEpoch}';
    
    _zoneManager.addZone(PriceZone(
      id: zoneId,
      minPrice: minPrice,
      maxPrice: maxPrice,
      type: PriceZoneType.demand,
      options: PriceZoneOptions(
        label: 'Demand Zone',
        showLabel: true,
        draggable: true,
        onRangeChanged: (newMin, newMax) {
          // Actualizar el rango en el manager
          _zoneManager.updateZoneRange(zoneId, newMin, newMax);
        },
      ),
    ));
  }

  void _addSupplyZone(BuildContext context) {
    final currentPrice = _data.last.close ?? 150.0;
    final minPrice = currentPrice * 1.07;
    final maxPrice = currentPrice * 1.10;
    
    final zoneId = 'supply_${DateTime.now().millisecondsSinceEpoch}';
    
    _zoneManager.addZone(PriceZone(
      id: zoneId,
      minPrice: minPrice,
      maxPrice: maxPrice,
      type: PriceZoneType.supply,
      options: PriceZoneOptions(
        label: 'Supply Zone',
        showLabel: true,
        draggable: true,
        onRangeChanged: (newMin, newMax) {
          // Actualizar el rango en el manager
          _zoneManager.updateZoneRange(zoneId, newMin, newMax);
        },
      ),
    ));
  }

  // ============================================================================
  // TAB 4: DRAWING TOOLS (Fibonacci & Trend Lines)
  // ============================================================================
  Widget _buildDrawingToolsTab() {
    return Stack(
      children: [
        Column(
          children: [
            // Info
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Fibonacci: ${_fibonacciManager.count} | Trend Lines: ${_trendLineManager.count}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
            // Chart
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: InteractiveChart(
                  candles: _data,
                  overlays: [..._fibonacciManager.fibonaccis, ..._trendLineManager.trendLines],
                  style: ChartStyle(
                    showVolume: _showVolume,
                    volumeColor: Colors.grey.withOpacity(0.5),
                    priceGridLineColor: Colors.grey.withOpacity(0.1),
                  ),
                ),
              ),
            ),
          ],
        ),
        // FAB buttons
        Positioned(
          right: 16,
          bottom: 16,
          child: _buildDrawingToolButtons(),
        ),
      ],
    );
  }

  Widget _buildDrawingToolButtons() {
    return Builder(
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'add_fib',
            onPressed: () => _addFibonacci(context),
            tooltip: 'Add Fibonacci',
            backgroundColor: Colors.purple[700],
            child: const Text('Fib', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'clear_fib',
            onPressed: () {
              final count = _fibonacciManager.count;
              _fibonacciManager.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Cleared $count Fibonacci retracements')),
              );
            },
            tooltip: 'Clear Fibonacci',
            backgroundColor: Colors.grey[700],
            child: const Icon(Icons.show_chart, size: 20),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.small(
            heroTag: 'add_trend',
            onPressed: () => _addTrendLine(context),
            tooltip: 'Add Trend Line',
            backgroundColor: Colors.green[700],
            child: const Icon(Icons.trending_up, size: 20),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'clear_trend',
            onPressed: () {
              final count = _trendLineManager.count;
              _trendLineManager.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Cleared $count trend lines')),
              );
            },
            tooltip: 'Clear Trend Lines',
            backgroundColor: Colors.grey[700],
            child: const Icon(Icons.trending_flat, size: 20),
          ),
        ],
      ),
    );
  }

  void _addFibonacci(BuildContext context) {
    final currentPrice = _data.last.close ?? 150.0;
    final highPrice = currentPrice * 1.075;
    final lowPrice = currentPrice * 0.925;
    
    final fibId = 'fib_${DateTime.now().millisecondsSinceEpoch}';
    
    _fibonacciManager.addFibonacci(FibonacciRetracement(
      id: fibId,
      highPrice: highPrice,
      lowPrice: lowPrice,
      options: FibonacciOptions(
        showLabels: true,
        showPercentages: true,
        draggable: true,
        onMoved: (newHigh, newLow) {
          _fibonacciManager.updateFibonacciRange(fibId, newHigh, newLow);
        },
      ),
    ));
  }

  void _addTrendLine(BuildContext context) {
    final startIndex = _data.length > 60 ? _data.length - 60 : 0;
    final endIndex = _data.length > 10 ? _data.length - 10 : _data.length - 1;
    
    final trendId = 'trend_${DateTime.now().millisecondsSinceEpoch}';
    
    _trendLineManager.addTrendLine(TrendLine(
      id: trendId,
      startTime: _data[startIndex].timestamp,
      startPrice: (_data[startIndex].low ?? 0) * 0.98,
      endTime: _data[endIndex].timestamp,
      endPrice: (_data[endIndex].high ?? 0) * 1.02,
      style: const TrendLineStyle(
        color: Color(0xFF4CAF50),
        lineWidth: 2.0,
      ),
      options: TrendLineOptions(
        draggable: true,
        extendRight: false,
        showAngle: true,
        onMoved: (newStartTime, newStartPrice, newEndTime, newEndPrice) {
          _trendLineManager.updateTrendLinePoints(
            trendId,
            startTime: newStartTime,
            startPrice: newStartPrice,
            endTime: newEndTime,
            endPrice: newEndPrice,
          );
        },
      ),
    ));
  }

  // ============================================================================
  // HELPER WIDGETS
  // ============================================================================
  Widget _buildToggleChip(String label, bool value, ValueChanged<bool> onChanged) {
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      selected: value,
      onSelected: onChanged,
      selectedColor: Colors.blue.withOpacity(0.3),
      checkmarkColor: Colors.blue,
    );
  }
}
