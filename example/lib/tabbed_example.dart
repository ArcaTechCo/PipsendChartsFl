import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:pipsend_charts/pipsend_charts.dart';
import 'mock_data.dart';
import 'infinite_history_example.dart';

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
  final InteractiveChartController _chartController = InteractiveChartController();
  
  // Position Tools
  final List<PositionTool> _positionTools = [];
  
  // Ruler Tools
  final List<RulerTool> _rulerTools = [];
  
  // Vertical Lines
  final List<VerticalLine> _verticalLines = [];
  
  // Fibonacci Extensions
  final List<FibonacciExtension> _fibonacciExtensions = [];
  
  // Fibonacci Fans
  final List<FibonacciFan> _fibonacciFans = [];
  
  // Arrow Tools
  final List<ArrowTool> _arrowTools = [];
  
  // Circle Tools
  final List<CircleTool> _circleTools = [];
  
  // Text Tools
  final List<TextTool> _textTools = [];
  
  // Brush Tools
  final List<BrushTool> _brushTools = [];
  
  // Gantt Tools
  final List<GanttTool> _ganttTools = [];
  
  // Settings
  bool _darkMode = true;
  bool _showVolume = true;
  bool _showWatermark = true;
  bool _enableInteraction = true;
  
  // Indicator toggles
  bool _showSMA20 = false;
  bool _showSMA50 = false;
  bool _showEMA12 = false;
  bool _showEMA26 = false;
  bool _showWMA20 = false;
  bool _showTradingSessions = false;
  bool _showVolumeProfile = false;
  bool _showRSI = false;
  bool _showMACD = false;
  bool _showStochastic = false;
  bool _showATR = false;
  bool _showADX = false;
  bool _showCCI = false;
  bool _showWilliamsR = false;
  bool _showOBV = false;
  bool _showBB = false;

  // Vertical zoom settings
  bool _enableVerticalPan = false;
  double _verticalZoom = 1.3;
  
  // Candle style settings
  double _candleBorderRadius = 0.0;
  
  // Grid settings
  bool _showHorizontalGrid = true;
  bool _showVerticalGrid = false;
  GridLineStyle _horizontalLineStyle = GridLineStyle.solid;
  GridLineStyle _verticalLineStyle = GridLineStyle.solid;
  double _horizontalStrokeWidth = 0.5;
  double _verticalStrokeWidth = 0.5;
  Color _horizontalGridColor = Colors.grey.withOpacity(0.3);
  Color _verticalGridColor = Colors.grey.withOpacity(0.3);
  
  // Label settings
  bool _adaptiveLabels = true;
  int? _priceLabelCount;  // null = adaptive
  int? _timeLabelDensity; // null = adaptive (90px)

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
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
    
    // Calculate timestamps for anchored overlays
    // Use last 40% of visible data for overlays
    final startIndex = (_data.length * 0.6).toInt();
    final endIndex = _data.length - 1;
    final startTime = _data[startIndex].timestamp;
    final endTime = _data[endIndex].timestamp;
    
    final entryId = 'entry_1';
    _lineManager.addLine(TradingLine(
      id: entryId,
      price: currentPrice,
      type: TradingLineType.entry,
      startTime: startTime,  // Anchor to specific time range
      endTime: endTime,
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
      startTime: startTime,  // Anchor to specific time range
      endTime: endTime,
      options: PriceZoneOptions(
        label: 'Demand Zone',
        showLabel: true,
        draggable: true,
        onRangeChanged: (newMin, newMax, newStartTime, newEndTime) {
          _zoneManager.updateZoneRange(demandId, newMin, newMax, startTime: newStartTime, endTime: newEndTime);
        },
      ),
    ));

    // Setup example Fibonacci
    final fibId = 'fib_1';
    _fibonacciManager.addFibonacci(FibonacciRetracement(
      id: fibId,
      highPrice: currentPrice * 1.075,
      lowPrice: currentPrice * 0.925,
      startTime: startTime,  // Anchor to specific time range
      endTime: endTime,
      options: FibonacciOptions(
        showLabels: true,
        showPercentages: true,
        draggable: true,
        onMoved: (newHigh, newLow, newStartTime, newEndTime) {
          _fibonacciManager.updateFibonacciRange(fibId, newHigh, newLow, startTime: newStartTime, endTime: newEndTime);
        },
      ),
    ));

    // Setup example Trend Line
    final trendStartIndex = _data.length > 60 ? _data.length - 60 : 0;
    final trendEndIndex = _data.length > 10 ? _data.length - 10 : _data.length - 1;
    
    final trendId = 'trend_1';
    _trendLineManager.addTrendLine(TrendLine(
      id: trendId,
      startTime: _data[trendStartIndex].timestamp,
      startPrice: (_data[trendStartIndex].low ?? 0) * 0.98,
      endTime: _data[trendEndIndex].timestamp,
      endPrice: (_data[trendEndIndex].high ?? 0) * 1.02,
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
              Tab(icon: Icon(Icons.zoom_out_map), text: 'Vertical Zoom'),
              Tab(icon: Icon(Icons.history), text: 'Infinite History'),
              Tab(icon: Icon(Icons.settings), text: 'Settings'),
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
            _buildVerticalZoomTab(),
            const InfiniteHistoryExample(),
            _buildSettingsTab(),
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
                _buildToggleChip('WMA(20)', _showWMA20, (v) => setState(() => _showWMA20 = v)),
                const SizedBox(width: 8),
                _buildToggleChip('Sessions', _showTradingSessions, (v) => setState(() => _showTradingSessions = v)),
                const SizedBox(width: 8),
                _buildToggleChip('Vol Profile', _showVolumeProfile, (v) => setState(() => _showVolumeProfile = v)),
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
              showWatermark: true,
              candles: _data,
              indicators: [
                if (_showSMA20) SMAIndicator(period: 20, style: SMAStyle(lineColor: Colors.blue)),
                if (_showSMA50) SMAIndicator(period: 50, style: SMAStyle(lineColor: Colors.green)),
                if (_showEMA12) EMAIndicator(period: 12, style: EMAStyle(lineColor: Colors.orange)),
                if (_showEMA26) EMAIndicator(period: 26, style: EMAStyle(lineColor: Colors.red)),
                if (_showWMA20) WMAIndicator(period: 20, style: WMAStyle(lineColor: Colors.purple)),
                if (_showTradingSessions) TradingSessionsIndicator(),
                if (_showVolumeProfile) VolumeProfileIndicator(bins: 24),
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
    // Calculate visible price range
    final visibleData = _data.length > 90 ? _data.sublist(_data.length - 90) : _data;
    final minVisiblePrice = visibleData.map((c) => c.low ?? 0).reduce((a, b) => a < b ? a : b);
    final maxVisiblePrice = visibleData.map((c) => c.high ?? 0).reduce((a, b) => a > b ? a : b);
    
    // Use helper to calculate smart position (15% height, 35% from bottom)
    final position = OverlayHelper.calculatePriceZonePosition(
      minPrice: minVisiblePrice,
      maxPrice: maxVisiblePrice,
      heightPercent: 0.15,
      centerPercent: 0.35,
    );
    
    final zoneId = 'demand_${DateTime.now().millisecondsSinceEpoch}';
    
    _zoneManager.addZone(PriceZone(
      id: zoneId,
      minPrice: position['minPrice']!,
      maxPrice: position['maxPrice']!,
      type: PriceZoneType.demand,
      options: PriceZoneOptions(
        label: 'Demand Zone',
        showLabel: true,
        draggable: true,
        onRangeChanged: (newMin, newMax, newStartTime, newEndTime) {
          _zoneManager.updateZoneRange(zoneId, newMin, newMax, startTime: newStartTime, endTime: newEndTime);
        },
      ),
    ));
  }

  void _addSupplyZone(BuildContext context) {
    // Calculate visible price range
    final visibleData = _data.length > 90 ? _data.sublist(_data.length - 90) : _data;
    final minVisiblePrice = visibleData.map((c) => c.low ?? 0).reduce((a, b) => a < b ? a : b);
    final maxVisiblePrice = visibleData.map((c) => c.high ?? 0).reduce((a, b) => a > b ? a : b);
    
    // Use helper to calculate smart position (15% height, 65% from bottom)
    final position = OverlayHelper.calculatePriceZonePosition(
      minPrice: minVisiblePrice,
      maxPrice: maxVisiblePrice,
      heightPercent: 0.15,
      centerPercent: 0.65,
    );
    
    final zoneId = 'supply_${DateTime.now().millisecondsSinceEpoch}';
    
    _zoneManager.addZone(PriceZone(
      id: zoneId,
      minPrice: position['minPrice']!,
      maxPrice: position['maxPrice']!,
      type: PriceZoneType.supply,
      options: PriceZoneOptions(
        label: 'Supply Zone',
        showLabel: true,
        draggable: true,
        onRangeChanged: (newMin, newMax, newStartTime, newEndTime) {
          _zoneManager.updateZoneRange(zoneId, newMin, newMax, startTime: newStartTime, endTime: newEndTime);
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
                'Tools: Arrow: ${_arrowTools.length} | Circle: ${_circleTools.length} | Text: ${_textTools.length} | Brush: ${_brushTools.length} | Gantt: ${_ganttTools.length}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
            // Chart
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: InteractiveChart(
                  candles: _data,
                  overlays: [..._fibonacciManager.fibonaccis, ..._fibonacciExtensions, ..._fibonacciFans, ..._trendLineManager.trendLines, ..._positionTools, ..._rulerTools, ..._verticalLines, ..._arrowTools, ..._circleTools, ..._textTools, ..._brushTools, ..._ganttTools],
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
            heroTag: 'add_position',
            onPressed: () => _addPosition(context),
            tooltip: 'Add Position',
            backgroundColor: Colors.blue[700],
            child: const Icon(Icons.add_chart, size: 20),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'clear_positions',
            onPressed: () {
              final count = _positionTools.length;
              setState(() => _positionTools.clear());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Cleared $count positions')),
              );
            },
            tooltip: 'Clear Positions',
            backgroundColor: Colors.grey[700],
            child: const Icon(Icons.clear_all, size: 20),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.small(
            heroTag: 'add_ruler',
            onPressed: () => _addRuler(context),
            tooltip: 'Add Ruler',
            backgroundColor: Colors.yellow[700],
            child: const Icon(Icons.straighten, size: 20),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'clear_rulers',
            onPressed: () {
              final count = _rulerTools.length;
              setState(() => _rulerTools.clear());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Cleared $count rulers')),
              );
            },
            tooltip: 'Clear Rulers',
            backgroundColor: Colors.grey[700],
            child: const Icon(Icons.clear, size: 20),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.small(
            heroTag: 'add_vline',
            onPressed: () => _addVerticalLine(context),
            tooltip: 'Add Vertical Line',
            backgroundColor: Colors.purple[700],
            child: const Icon(Icons.more_vert, size: 20),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'clear_vlines',
            onPressed: () {
              final count = _verticalLines.length;
              setState(() => _verticalLines.clear());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Cleared $count vertical lines')),
              );
            },
            tooltip: 'Clear Vertical Lines',
            backgroundColor: Colors.grey[700],
            child: const Icon(Icons.clear, size: 20),
          ),
          const SizedBox(height: 16),
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
            heroTag: 'add_fib_ext',
            onPressed: () => _addFibonacciExtension(context),
            tooltip: 'Add Fibonacci Extension',
            backgroundColor: Colors.deepPurple[700],
            child: const Text('Ext', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'clear_fib_ext',
            onPressed: () {
              final count = _fibonacciExtensions.length;
              setState(() => _fibonacciExtensions.clear());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Cleared $count Fibonacci extensions')),
              );
            },
            tooltip: 'Clear Fibonacci Extensions',
            backgroundColor: Colors.grey[700],
            child: const Icon(Icons.clear, size: 20),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.small(
            heroTag: 'add_fib_fan',
            onPressed: () => _addFibonacciFan(context),
            tooltip: 'Add Fibonacci Fan',
            backgroundColor: Colors.indigo[700],
            child: const Text('Fan', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'clear_fib_fan',
            onPressed: () {
              final count = _fibonacciFans.length;
              setState(() => _fibonacciFans.clear());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Cleared $count Fibonacci fans')),
              );
            },
            tooltip: 'Clear Fibonacci Fans',
            backgroundColor: Colors.grey[700],
            child: const Icon(Icons.clear, size: 20),
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
          const SizedBox(height: 16),
          FloatingActionButton.small(
            heroTag: 'add_arrow',
            onPressed: () => _addArrowTool(context),
            tooltip: 'Add Arrow',
            backgroundColor: Colors.orange[700],
            child: const Icon(Icons.arrow_forward, size: 20),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'clear_arrow',
            onPressed: () {
              final count = _arrowTools.length;
              setState(() => _arrowTools.clear());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Cleared $count arrows')),
              );
            },
            tooltip: 'Clear Arrows',
            backgroundColor: Colors.grey[700],
            child: const Icon(Icons.clear, size: 20),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.small(
            heroTag: 'add_circle',
            onPressed: () => _addCircleTool(context),
            tooltip: 'Add Circle',
            backgroundColor: Colors.teal[700],
            child: const Icon(Icons.circle_outlined, size: 20),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'clear_circle',
            onPressed: () {
              final count = _circleTools.length;
              setState(() => _circleTools.clear());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Cleared $count circles')),
              );
            },
            tooltip: 'Clear Circles',
            backgroundColor: Colors.grey[700],
            child: const Icon(Icons.clear, size: 20),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.small(
            heroTag: 'add_text',
            onPressed: () => _addTextTool(context),
            tooltip: 'Add Text',
            backgroundColor: Colors.purple[700],
            child: const Icon(Icons.text_fields, size: 20),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'clear_text',
            onPressed: () {
              final count = _textTools.length;
              setState(() => _textTools.clear());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Cleared $count text annotations')),
              );
            },
            tooltip: 'Clear Text',
            backgroundColor: Colors.grey[700],
            child: const Icon(Icons.clear, size: 20),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.small(
            heroTag: 'add_brush',
            onPressed: () => _addBrushTool(context),
            tooltip: 'Add Brush',
            backgroundColor: Colors.deepOrange[700],
            child: const Icon(Icons.brush, size: 20),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'clear_brush',
            onPressed: () {
              final count = _brushTools.length;
              setState(() => _brushTools.clear());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Cleared $count brush strokes')),
              );
            },
            tooltip: 'Clear Brush',
            backgroundColor: Colors.grey[700],
            child: const Icon(Icons.clear, size: 20),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.small(
            heroTag: 'add_gantt',
            onPressed: () => _addGanttTool(context),
            tooltip: 'Add Gantt',
            backgroundColor: Colors.green[700],
            child: const Icon(Icons.view_timeline, size: 20),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'clear_gantt',
            onPressed: () {
              final count = _ganttTools.length;
              setState(() => _ganttTools.clear());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Cleared $count gantt bars')),
              );
            },
            tooltip: 'Clear Gantt',
            backgroundColor: Colors.grey[700],
            child: const Icon(Icons.clear, size: 20),
          ),
        ],
      ),
    );
  }

  void _addFibonacci(BuildContext context) {
    // Calculate visible price range
    final visibleData = _data.length > 90 ? _data.sublist(_data.length - 90) : _data;
    final minVisiblePrice = visibleData.map((c) => c.low ?? 0).reduce((a, b) => a < b ? a : b);
    final maxVisiblePrice = visibleData.map((c) => c.high ?? 0).reduce((a, b) => a > b ? a : b);
    
    // Use helper to calculate smart position (40% height, centered)
    final position = OverlayHelper.calculateFibonacciPosition(
      minPrice: minVisiblePrice,
      maxPrice: maxVisiblePrice,
      heightPercent: 0.4,
      centerPercent: 0.5,
    );
    
    final fibId = 'fib_${DateTime.now().millisecondsSinceEpoch}';
    
    _fibonacciManager.addFibonacci(FibonacciRetracement(
      id: fibId,
      highPrice: position['highPrice']!,
      lowPrice: position['lowPrice']!,
      options: FibonacciOptions(
        showLabels: true,
        showPercentages: true,
        draggable: true,
        onMoved: (newHigh, newLow, newStartTime, newEndTime) {
          _fibonacciManager.updateFibonacciRange(fibId, newHigh, newLow, startTime: newStartTime, endTime: newEndTime);
        },
      ),
    ));
  }

  void _addTrendLine(BuildContext context) {
    // Calculate visible data range
    final visibleCount = 90;
    final visibleData = _data.length > visibleCount ? _data.sublist(_data.length - visibleCount) : _data;
    final minVisiblePrice = visibleData.map((c) => c.low ?? 0).reduce((a, b) => a < b ? a : b);
    final maxVisiblePrice = visibleData.map((c) => c.high ?? 0).reduce((a, b) => a > b ? a : b);
    
    // Calculate candle interval (assuming regular intervals)
    final candleInterval = _data.length > 1 
        ? _data.last.timestamp - _data[_data.length - 2].timestamp 
        : 3600000; // 1 hour default
    
    // Use helper to calculate smart position (30% width, centered, 50% vertical)
    final position = OverlayHelper.calculateTrendLinePosition(
      visibleCandleCount: visibleCount,
      minPrice: minVisiblePrice,
      maxPrice: maxVisiblePrice,
      latestTimestamp: _data.last.timestamp,
      candleInterval: candleInterval,
      widthPercent: 0.3,
      centerPercent: 0.5,
      verticalCenterPercent: 0.5,
    );
    
    final trendId = 'trend_${DateTime.now().millisecondsSinceEpoch}';
    
    _trendLineManager.addTrendLine(TrendLine(
      id: trendId,
      startTime: position['startTime']!.toInt(),
      startPrice: position['startPrice']!,
      endTime: position['endTime']!.toInt(),
      endPrice: position['endPrice']!,
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

  void _addPosition(BuildContext context) {
    // Calculate visible price range
    final visibleData = _data.length > 90 ? _data.sublist(_data.length - 90) : _data;
    final minVisiblePrice = visibleData.map((c) => c.low ?? 0).reduce((a, b) => a < b ? a : b);
    final maxVisiblePrice = visibleData.map((c) => c.high ?? 0).reduce((a, b) => a > b ? a : b);
    final priceRange = maxVisiblePrice - minVisiblePrice;
    
    // Create a sample position (Long)
    final entryPrice = minVisiblePrice + (priceRange * 0.5); // Middle
    final stopLossPrice = minVisiblePrice + (priceRange * 0.35); // Below entry
    final takeProfitPrice = minVisiblePrice + (priceRange * 0.8); // Above entry
    
    final positionId = 'position_${DateTime.now().millisecondsSinceEpoch}';
    
    final position = PositionTool(
      id: positionId,
      entryPrice: entryPrice,
      stopLossPrice: stopLossPrice,
      takeProfitPrice: takeProfitPrice,
      options: PositionToolOptions(
        showLabels: true,
        showPriceInLabel: true,
        showRiskReward: true,
        showPositionZone: true,
        draggable: true,
        onPositionChanged: (entry, sl, tp) {
          setState(() {
            final index = _positionTools.indexWhere((p) => p.id == positionId);
            if (index >= 0) {
              _positionTools[index] = _positionTools[index].copyWith(
                entryPrice: entry,
                stopLossPrice: sl,
                takeProfitPrice: tp,
              );
            }
          });
        },
      ),
    );
    
    setState(() {
      _positionTools.add(position);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Position added! Drag lines to adjust.')),
    );
  }

  void _addRuler(BuildContext context) {
    // Calculate visible data range
    final visibleCount = 90;
    final visibleData = _data.length > visibleCount ? _data.sublist(_data.length - visibleCount) : _data;
    final minVisiblePrice = visibleData.map((c) => c.low ?? 0).reduce((a, b) => a < b ? a : b);
    final maxVisiblePrice = visibleData.map((c) => c.high ?? 0).reduce((a, b) => a > b ? a : b);
    final priceRange = maxVisiblePrice - minVisiblePrice;
    
    // Create ruler from 30% to 70% of visible range (40% width)
    final startIndex = (_data.length - visibleCount) + (visibleCount * 0.3).toInt();
    final endIndex = (_data.length - visibleCount) + (visibleCount * 0.7).toInt();
    
    final startTime = _data[startIndex.clamp(0, _data.length - 1)].timestamp;
    final endTime = _data[endIndex.clamp(0, _data.length - 1)].timestamp;
    
    final startPrice = minVisiblePrice + (priceRange * 0.4);
    final endPrice = minVisiblePrice + (priceRange * 0.7);
    
    final rulerId = 'ruler_${DateTime.now().millisecondsSinceEpoch}';
    
    final ruler = RulerTool(
      id: rulerId,
      startTime: startTime,
      startPrice: startPrice,
      endTime: endTime,
      endPrice: endPrice,
      options: RulerToolOptions(
        showPrice: true,
        showPercentage: true,
        showPips: false,
        showTime: true,
        draggable: true,
        onMoved: (newStartTime, newStartPrice, newEndTime, newEndPrice) {
          setState(() {
            final index = _rulerTools.indexWhere((r) => r.id == rulerId);
            if (index >= 0) {
              _rulerTools[index] = _rulerTools[index].copyWith(
                startTime: newStartTime,
                startPrice: newStartPrice,
                endTime: newEndTime,
                endPrice: newEndPrice,
              );
            }
          });
        },
      ),
    );
    
    setState(() {
      _rulerTools.add(ruler);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ruler added! Shows price, %, and time.')),
    );
  }

  void _addVerticalLine(BuildContext context) {
    // Calculate visible data range
    final visibleCount = 90;
    
    // Place vertical line at 50% of visible range
    final targetIndex = (_data.length - visibleCount) + (visibleCount * 0.5).toInt();
    final timestamp = _data[targetIndex.clamp(0, _data.length - 1)].timestamp;
    
    final vlineId = 'vline_${DateTime.now().millisecondsSinceEpoch}';
    
    final vline = VerticalLine(
      id: vlineId,
      timestamp: timestamp,
      options: VerticalLineOptions(
        label: 'Event',
        showLabel: true,
        draggable: true,
        onMoved: (newTimestamp) {
          setState(() {
            final index = _verticalLines.indexWhere((v) => v.id == vlineId);
            if (index >= 0) {
              _verticalLines[index] = _verticalLines[index].copyWith(
                timestamp: newTimestamp,
              );
            }
          });
        },
      ),
    );
    
    setState(() {
      _verticalLines.add(vline);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vertical line added! Mark temporal events.')),
    );
  }

  void _addFibonacciExtension(BuildContext context) {
    // Calculate visible data range
    final visibleCount = 90;
    final visibleData = _data.length > visibleCount ? _data.sublist(_data.length - visibleCount) : _data;
    final minVisiblePrice = visibleData.map((c) => c.low ?? 0).reduce((a, b) => a < b ? a : b);
    final maxVisiblePrice = visibleData.map((c) => c.high ?? 0).reduce((a, b) => a > b ? a : b);
    final priceRange = maxVisiblePrice - minVisiblePrice;
    
    // Create 3 points: A (low), B (high), C (retracement)
    // Point A at 20% of visible range
    final indexA = (_data.length - visibleCount) + (visibleCount * 0.2).toInt();
    final pointATime = _data[indexA.clamp(0, _data.length - 1)].timestamp;
    final pointAPrice = minVisiblePrice + (priceRange * 0.3);
    
    // Point B at 50% of visible range
    final indexB = (_data.length - visibleCount) + (visibleCount * 0.5).toInt();
    final pointBTime = _data[indexB.clamp(0, _data.length - 1)].timestamp;
    final pointBPrice = minVisiblePrice + (priceRange * 0.7);
    
    // Point C at 70% of visible range
    final indexC = (_data.length - visibleCount) + (visibleCount * 0.7).toInt();
    final pointCTime = _data[indexC.clamp(0, _data.length - 1)].timestamp;
    final pointCPrice = minVisiblePrice + (priceRange * 0.5);
    
    final fibExtId = 'fib_ext_${DateTime.now().millisecondsSinceEpoch}';
    
    setState(() {
      _fibonacciExtensions.add(FibonacciExtension(
        id: fibExtId,
        pointAPrice: pointAPrice,
        pointATime: pointATime,
        pointBPrice: pointBPrice,
        pointBTime: pointBTime,
        pointCPrice: pointCPrice,
        pointCTime: pointCTime,
        options: FibonacciExtensionOptions(
          draggable: true,
          showLabels: true,
          onMoved: (newATime, newAPrice, newBTime, newBPrice, newCTime, newCPrice) {
            setState(() {
              final index = _fibonacciExtensions.indexWhere((f) => f.id == fibExtId);
              if (index >= 0) {
                final current = _fibonacciExtensions[index];
                _fibonacciExtensions[index] = FibonacciExtension(
                  id: current.id,
                  pointATime: newATime,
                  pointAPrice: newAPrice,
                  pointBTime: newBTime,
                  pointBPrice: newBPrice,
                  pointCTime: newCTime,
                  pointCPrice: newCPrice,
                  style: current.style,
                  options: current.options,
                );
              }
            });
          },
        ),
      ));
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fibonacci Extension added! Shows projection levels.')),
    );
  }

  void _addFibonacciFan(BuildContext context) {
    // Calculate visible data range
    final visibleCount = 90;
    final visibleData = _data.length > visibleCount ? _data.sublist(_data.length - visibleCount) : _data;
    final minVisiblePrice = visibleData.map((c) => c.low ?? 0).reduce((a, b) => a < b ? a : b);
    final maxVisiblePrice = visibleData.map((c) => c.high ?? 0).reduce((a, b) => a > b ? a : b);
    final priceRange = maxVisiblePrice - minVisiblePrice;
    
    // Create 2 points: Start (pivot) and End (defines trend)
    // Start point at 30% of visible range
    final startIndex = (_data.length - visibleCount) + (visibleCount * 0.3).toInt();
    final startTime = _data[startIndex.clamp(0, _data.length - 1)].timestamp;
    final startPrice = minVisiblePrice + (priceRange * 0.3);
    
    // End point at 70% of visible range
    final endIndex = (_data.length - visibleCount) + (visibleCount * 0.7).toInt();
    final endTime = _data[endIndex.clamp(0, _data.length - 1)].timestamp;
    final endPrice = minVisiblePrice + (priceRange * 0.7);
    
    final fibFanId = 'fib_fan_${DateTime.now().millisecondsSinceEpoch}';
    
    setState(() {
      _fibonacciFans.add(FibonacciFan(
        id: fibFanId,
        startPrice: startPrice,
        startTime: startTime,
        endPrice: endPrice,
        endTime: endTime,
        options: FibonacciFanOptions(
          draggable: true,
          showLabels: true,
          onMoved: (newStartTime, newStartPrice, newEndTime, newEndPrice) {
            setState(() {
              final index = _fibonacciFans.indexWhere((f) => f.id == fibFanId);
              if (index >= 0) {
                final current = _fibonacciFans[index];
                _fibonacciFans[index] = FibonacciFan(
                  id: current.id,
                  startTime: newStartTime,
                  startPrice: newStartPrice,
                  endTime: newEndTime,
                  endPrice: newEndPrice,
                  style: current.style,
                  options: current.options,
                );
              }
            });
          },
        ),
      ));
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fibonacci Fan added! Shows radial trend lines.')),
    );
  }

  void _addArrowTool(BuildContext context) {
    // Calculate visible data range
    final visibleCount = 90;
    final visibleData = _data.length > visibleCount ? _data.sublist(_data.length - visibleCount) : _data;
    final minVisiblePrice = visibleData.map((c) => c.low ?? 0).reduce((a, b) => a < b ? a : b);
    final maxVisiblePrice = visibleData.map((c) => c.high ?? 0).reduce((a, b) => a > b ? a : b);
    final priceRange = maxVisiblePrice - minVisiblePrice;
    
    // Create arrow from 30% to 70% of visible range
    final startIndex = (_data.length - visibleCount) + (visibleCount * 0.3).toInt();
    final startTime = _data[startIndex.clamp(0, _data.length - 1)].timestamp;
    final startPrice = minVisiblePrice + (priceRange * 0.4);
    
    final endIndex = (_data.length - visibleCount) + (visibleCount * 0.7).toInt();
    final endTime = _data[endIndex.clamp(0, _data.length - 1)].timestamp;
    final endPrice = minVisiblePrice + (priceRange * 0.6);
    
    final arrowId = 'arrow_${DateTime.now().millisecondsSinceEpoch}';
    
    setState(() {
      _arrowTools.add(ArrowTool(
        id: arrowId,
        startTime: startTime,
        startPrice: startPrice,
        endTime: endTime,
        endPrice: endPrice,
        options: ArrowToolOptions(
          draggable: true,
          onMoved: (newStartTime, newStartPrice, newEndTime, newEndPrice) {
            setState(() {
              final index = _arrowTools.indexWhere((a) => a.id == arrowId);
              if (index >= 0) {
                final current = _arrowTools[index];
                _arrowTools[index] = ArrowTool(
                  id: current.id,
                  startTime: newStartTime,
                  startPrice: newStartPrice,
                  endTime: newEndTime,
                  endPrice: newEndPrice,
                  style: current.style,
                  options: current.options,
                );
              }
            });
          },
        ),
      ));
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Arrow added! Draw directional annotations.')),
    );
  }

  void _addCircleTool(BuildContext context) {
    // Calculate visible data range
    final visibleCount = 90;
    final visibleData = _data.length > visibleCount ? _data.sublist(_data.length - visibleCount) : _data;
    final minVisiblePrice = visibleData.map((c) => c.low ?? 0).reduce((a, b) => a < b ? a : b);
    final maxVisiblePrice = visibleData.map((c) => c.high ?? 0).reduce((a, b) => a > b ? a : b);
    final priceRange = maxVisiblePrice - minVisiblePrice;
    
    // Create circle at center of visible range
    final centerIndex = (_data.length - visibleCount) + (visibleCount * 0.5).toInt();
    final centerTime = _data[centerIndex.clamp(0, _data.length - 1)].timestamp;
    final centerPrice = minVisiblePrice + (priceRange * 0.5);
    
    // Radius: 10 candles in time, 15% of price range
    final radiusTime = 10 * 86400000; // 10 days in milliseconds
    final radiusPrice = priceRange * 0.15;
    
    final circleId = 'circle_${DateTime.now().millisecondsSinceEpoch}';
    
    setState(() {
      _circleTools.add(CircleTool(
        id: circleId,
        centerTime: centerTime,
        centerPrice: centerPrice,
        radiusTime: radiusTime,
        radiusPrice: radiusPrice,
        style: const CircleToolStyle(
          filled: true,
          fillOpacity: 0.1,
        ),
        options: CircleToolOptions(
          draggable: true,
          onMoved: (newCenterTime, newCenterPrice, newRadiusTime, newRadiusPrice) {
            setState(() {
              final index = _circleTools.indexWhere((c) => c.id == circleId);
              if (index >= 0) {
                final current = _circleTools[index];
                _circleTools[index] = CircleTool(
                  id: current.id,
                  centerTime: newCenterTime,
                  centerPrice: newCenterPrice,
                  radiusTime: newRadiusTime,
                  radiusPrice: newRadiusPrice,
                  style: current.style,
                  options: current.options,
                );
              }
            });
          },
        ),
      ));
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Circle added! Highlight areas of interest.')),
    );
  }

  void _addTextTool(BuildContext context) {
    // Calculate visible data range
    final visibleCount = 90;
    final visibleData = _data.length > visibleCount ? _data.sublist(_data.length - visibleCount) : _data;
    final minVisiblePrice = visibleData.map((c) => c.low ?? 0).reduce((a, b) => a < b ? a : b);
    final maxVisiblePrice = visibleData.map((c) => c.high ?? 0).reduce((a, b) => a > b ? a : b);
    final priceRange = maxVisiblePrice - minVisiblePrice;
    
    // Create text at center of visible range
    final centerIndex = (_data.length - visibleCount) + (visibleCount * 0.5).toInt();
    final timestamp = _data[centerIndex.clamp(0, _data.length - 1)].timestamp;
    final price = minVisiblePrice + (priceRange * 0.5);
    
    final textId = 'text_${DateTime.now().millisecondsSinceEpoch}';
    
    setState(() {
      _textTools.add(TextTool(
        id: textId,
        timestamp: timestamp,
        price: price,
        text: 'Note ${_textTools.length + 1}',
        options: TextToolOptions(
          draggable: true,
          onMoved: (newTimestamp, newPrice) {
            setState(() {
              final index = _textTools.indexWhere((t) => t.id == textId);
              if (index >= 0) {
                _textTools[index] = _textTools[index].copyWith(
                  timestamp: newTimestamp,
                  price: newPrice,
                );
              }
            });
          },
          onEdit: (currentText) async {
            // Show dialog to edit text
            final controller = TextEditingController(text: currentText);
            final newText = await showDialog<String>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Edit Text'),
                content: TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Enter text...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onSubmitted: (value) => Navigator.of(context).pop(value),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(controller.text),
                    child: const Text('Save'),
                  ),
                ],
              ),
            );
            
            if (newText != null && newText.isNotEmpty) {
              setState(() {
                final index = _textTools.indexWhere((t) => t.id == textId);
                if (index >= 0) {
                  _textTools[index] = _textTools[index].copyWith(text: newText);
                }
              });
            }
            
            return newText;
          },
        ),
      ));
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Text annotation added! Drag to move, double-tap to edit.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _addBrushTool(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Brush Tool: The current implementation shows a sample stroke. Interactive drawing would require gesture capture during drag, which is a more advanced feature. For now, you can see how brush strokes are rendered.'),
        duration: Duration(seconds: 5),
      ),
    );
    
    // Calculate visible data range
    final visibleCount = 90;
    final visibleData = _data.length > visibleCount ? _data.sublist(_data.length - visibleCount) : _data;
    final minVisiblePrice = visibleData.map((c) => c.low ?? 0).reduce((a, b) => a < b ? a : b);
    final maxVisiblePrice = visibleData.map((c) => c.high ?? 0).reduce((a, b) => a > b ? a : b);
    final priceRange = maxVisiblePrice - minVisiblePrice;
    
    // Create a sample brush stroke with multiple points to show smooth curve
    final points = <BrushPoint>[];
    for (int i = 0; i < 10; i++) {
      final index = (_data.length - visibleCount) + (visibleCount * (0.2 + i * 0.06)).toInt();
      final timestamp = _data[index.clamp(0, _data.length - 1)].timestamp;
      // Create a wave pattern
      final wave = math.sin(i * 0.5) * 0.1;
      final price = minVisiblePrice + (priceRange * (0.5 + wave));
      points.add(BrushPoint(timestamp: timestamp, price: price));
    }
    
    final brushId = 'brush_${DateTime.now().millisecondsSinceEpoch}';
    
    setState(() {
      _brushTools.add(BrushTool(
        id: brushId,
        points: points,
        options: BrushToolOptions(
          draggable: false, // Brush strokes are typically not draggable
        ),
      ));
    });
  }

  void _addGanttTool(BuildContext context) {
    // Calculate visible data range
    final visibleCount = 90;
    final visibleData = _data.length > visibleCount ? _data.sublist(_data.length - visibleCount) : _data;
    final minVisiblePrice = visibleData.map((c) => c.low ?? 0).reduce((a, b) => a < b ? a : b);
    final maxVisiblePrice = visibleData.map((c) => c.high ?? 0).reduce((a, b) => a > b ? a : b);
    final priceRange = maxVisiblePrice - minVisiblePrice;
    
    // Create gantt bar from 30% to 70% of visible range
    final startIndex = (_data.length - visibleCount) + (visibleCount * 0.3).toInt();
    final startTime = _data[startIndex.clamp(0, _data.length - 1)].timestamp;
    
    final endIndex = (_data.length - visibleCount) + (visibleCount * 0.7).toInt();
    final endTime = _data[endIndex.clamp(0, _data.length - 1)].timestamp;
    
    final price = minVisiblePrice + (priceRange * 0.6);
    final height = priceRange * 0.1;
    
    final ganttId = 'gantt_${DateTime.now().millisecondsSinceEpoch}';
    
    setState(() {
      _ganttTools.add(GanttTool(
        id: ganttId,
        startTime: startTime,
        endTime: endTime,
        price: price,
        height: height,
        label: 'Period ${_ganttTools.length + 1}',
        options: GanttToolOptions(
          draggable: true,
          onMoved: (newStartTime, newEndTime, newPrice) {
            setState(() {
              final index = _ganttTools.indexWhere((g) => g.id == ganttId);
              if (index >= 0) {
                _ganttTools[index] = _ganttTools[index].copyWith(
                  startTime: newStartTime,
                  endTime: newEndTime,
                  price: newPrice,
                );
              }
            });
          },
        ),
      ));
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gantt bar added! Visualize time periods.')),
    );
  }

  // ============================================================================
  // TAB 5: VERTICAL ZOOM
  // ============================================================================
  Widget _buildVerticalZoomTab() {
    // Create some TP/SL lines for demonstration
    final currentPrice = _data.last.close ?? 150.0;
    final demoOverlays = [
      TradingLine(
        price: currentPrice * 1.08,
        type: TradingLineType.takeProfit,
        options: TradingLineOptions(
          title: 'TP',
          showPrice: true,
        ),
      ),
      TradingLine(
        price: currentPrice * 0.92,
        type: TradingLineType.stopLoss,
        options: TradingLineOptions(
          title: 'SL',
          showPrice: true,
        ),
      ),
    ];

    return Column(
      children: [
        // Control Panel
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue.shade50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.zoom_out_map, color: Colors.blue),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Vertical Zoom & Pan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Switch(
                    value: _enableVerticalPan,
                    onChanged: (value) => setState(() => _enableVerticalPan = value),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _enableVerticalPan 
                    ? 'Enabled - Use Shift+Scroll for zoom, Alt+Scroll for pan'
                    : 'Disabled - Auto-fit mode (legacy behavior)',
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
              if (_enableVerticalPan) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Zoom: ${_verticalZoom.toStringAsFixed(1)}x'),
                          Slider(
                            value: _verticalZoom,
                            min: 0.5,
                            max: 3.0,
                            divisions: 25,
                            label: _verticalZoom.toStringAsFixed(1),
                            onChanged: (value) => setState(() => _verticalZoom = value),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => setState(() => _verticalZoom = 1.0),
                      icon: const Icon(Icons.fit_screen, size: 16),
                      label: const Text('Fit (1.0x)', style: TextStyle(fontSize: 11)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => setState(() => _verticalZoom = 1.3),
                      icon: const Icon(Icons.zoom_out, size: 16),
                      label: const Text('Normal (1.3x)', style: TextStyle(fontSize: 11)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => setState(() => _verticalZoom = 1.5),
                      icon: const Icon(Icons.zoom_out, size: 16),
                      label: const Text('Wide (1.5x)', style: TextStyle(fontSize: 11)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => setState(() => _verticalZoom = 2.0),
                      icon: const Icon(Icons.zoom_out, size: 16),
                      label: const Text('Max (2.0x)', style: TextStyle(fontSize: 11)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.amber),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Notice how TP/SL lines are now visible with vertical zoom enabled!',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        // Chart
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: InteractiveChart(
              candles: _data,
              enableVerticalPan: _enableVerticalPan,
              initialVerticalZoom: _verticalZoom,
              overlays: demoOverlays,
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
  // TAB 6: SETTINGS & CONTROLS
  // ============================================================================
  Widget _buildSettingsTab() {
    return Stack(
      children: [
        // Chart (Full Screen)
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: InteractiveChart(
            candles: _data,
            controller: _chartController,
            showWatermark: _showWatermark,
            enableInteraction: _enableInteraction,
            style: ChartStyle(
              priceGainColor: Colors.green,
              priceLossColor: Colors.red,
              candleBorderRadius: _candleBorderRadius,
              adaptiveLabels: _adaptiveLabels,
              priceLabelCount: _priceLabelCount,
              timeLabelDensity: _timeLabelDensity,
              gridStyle: GridStyle(
                showHorizontalGrid: _showHorizontalGrid,
                showVerticalGrid: _showVerticalGrid,
                horizontalLineStyle: _horizontalLineStyle,
                verticalLineStyle: _verticalLineStyle,
                horizontalStrokeWidth: _horizontalStrokeWidth,
                verticalStrokeWidth: _verticalStrokeWidth,
                horizontalGridColor: _horizontalGridColor,
                verticalGridColor: _verticalGridColor,
              ),
            ),
          ),
        ),
        
        // Info Badge (Top)
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.settings, size: 16, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Grid: ${_showHorizontalGrid && _showVerticalGrid ? "Full" : _showHorizontalGrid ? "H" : _showVerticalGrid ? "V" : "Off"} • '
                  'Radius: ${_candleBorderRadius.toStringAsFixed(1)}',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
        
        // Floating Action Buttons
        Positioned(
          right: 16,
          bottom: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Open Settings Bottom Sheet
              Builder(
                builder: (context) => FloatingActionButton(
                  heroTag: 'open_settings',
                  onPressed: () => _showSettingsBottomSheet(context),
                  tooltip: 'Chart Settings',
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.tune),
                ),
              ),
              const SizedBox(height: 12),
              
              // Toggle Watermark
              FloatingActionButton.small(
                heroTag: 'toggle_watermark',
                onPressed: () => setState(() => _showWatermark = !_showWatermark),
                tooltip: _showWatermark ? 'Hide Watermark' : 'Show Watermark',
                backgroundColor: _showWatermark ? Colors.blue : Colors.grey,
                child: Icon(_showWatermark ? Icons.branding_watermark : Icons.branding_watermark_outlined, size: 20),
              ),
              const SizedBox(height: 8),
              
              // Toggle Interaction
              FloatingActionButton.small(
                heroTag: 'toggle_interaction',
                onPressed: () => setState(() => _enableInteraction = !_enableInteraction),
                tooltip: _enableInteraction ? 'Disable Interaction' : 'Enable Interaction',
                backgroundColor: _enableInteraction ? Colors.green : Colors.grey,
                child: Icon(_enableInteraction ? Icons.touch_app : Icons.touch_app_outlined, size: 20),
              ),
              const SizedBox(height: 8),
              
              // Jump to Latest
              FloatingActionButton.small(
                heroTag: 'jump_to_latest',
                onPressed: () => _chartController.jumpToLatest(),
                tooltip: 'Jump to Latest',
                backgroundColor: Colors.orange,
                child: const Icon(Icons.skip_next, size: 20),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // Show Settings Bottom Sheet
  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(Icons.settings, color: Colors.blue),
                    const SizedBox(width: 12),
                    const Text(
                      'Chart Settings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildCandleStyleSection(),
                    const SizedBox(height: 24),
                    _buildGridSection(),
                    const SizedBox(height: 24),
                    _buildLabelsSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Candle Style Section
  Widget _buildCandleStyleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.rounded_corner, size: 20, color: Colors.blue),
            const SizedBox(width: 8),
            const Text(
              'Candle Style',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Corner Radius: ${_candleBorderRadius.toStringAsFixed(1)}',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        Slider(
          value: _candleBorderRadius,
          min: 0.0,
          max: 8.0,
          divisions: 16,
          label: _candleBorderRadius.toStringAsFixed(1),
          onChanged: (value) => setState(() => _candleBorderRadius = value),
        ),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Square'),
              selected: _candleBorderRadius == 0.0,
              onSelected: (_) => setState(() => _candleBorderRadius = 0.0),
            ),
            ChoiceChip(
              label: const Text('Slight'),
              selected: _candleBorderRadius == 2.0,
              onSelected: (_) => setState(() => _candleBorderRadius = 2.0),
            ),
            ChoiceChip(
              label: const Text('Medium'),
              selected: _candleBorderRadius == 4.0,
              onSelected: (_) => setState(() => _candleBorderRadius = 4.0),
            ),
            ChoiceChip(
              label: const Text('Rounded'),
              selected: _candleBorderRadius == 8.0,
              onSelected: (_) => setState(() => _candleBorderRadius = 8.0),
            ),
          ],
        ),
      ],
    );
  }
  
  // Grid Section
  Widget _buildGridSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.grid_on, size: 20, color: Colors.blue),
            const SizedBox(width: 8),
            const Text(
              'Grid Configuration',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Horizontal Grid
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Horizontal Grid'),
          value: _showHorizontalGrid,
          onChanged: (val) => setState(() => _showHorizontalGrid = val),
        ),
        if (_showHorizontalGrid) ...[
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Style:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Solid'),
                      selected: _horizontalLineStyle == GridLineStyle.solid,
                      onSelected: (_) => setState(() => _horizontalLineStyle = GridLineStyle.solid),
                    ),
                    ChoiceChip(
                      label: const Text('Dashed'),
                      selected: _horizontalLineStyle == GridLineStyle.dashed,
                      onSelected: (_) => setState(() => _horizontalLineStyle = GridLineStyle.dashed),
                    ),
                    ChoiceChip(
                      label: const Text('Dotted'),
                      selected: _horizontalLineStyle == GridLineStyle.dotted,
                      onSelected: (_) => setState(() => _horizontalLineStyle = GridLineStyle.dotted),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Stroke Width: ${_horizontalStrokeWidth.toStringAsFixed(1)}', 
                     style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                Slider(
                  value: _horizontalStrokeWidth,
                  min: 0.1,
                  max: 3.0,
                  divisions: 29,
                  label: _horizontalStrokeWidth.toStringAsFixed(1),
                  onChanged: (val) => setState(() => _horizontalStrokeWidth = val),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Opacity: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    Expanded(
                      child: Slider(
                        value: _horizontalGridColor.opacity,
                        min: 0.0,
                        max: 1.0,
                        divisions: 20,
                        label: (_horizontalGridColor.opacity * 100).toStringAsFixed(0) + '%',
                        onChanged: (val) => setState(() => 
                          _horizontalGridColor = _horizontalGridColor.withOpacity(val)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        // Vertical Grid
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Vertical Grid'),
          value: _showVerticalGrid,
          onChanged: (val) => setState(() => _showVerticalGrid = val),
        ),
        if (_showVerticalGrid) ...[
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Style:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Solid'),
                      selected: _verticalLineStyle == GridLineStyle.solid,
                      onSelected: (_) => setState(() => _verticalLineStyle = GridLineStyle.solid),
                    ),
                    ChoiceChip(
                      label: const Text('Dashed'),
                      selected: _verticalLineStyle == GridLineStyle.dashed,
                      onSelected: (_) => setState(() => _verticalLineStyle = GridLineStyle.dashed),
                    ),
                    ChoiceChip(
                      label: const Text('Dotted'),
                      selected: _verticalLineStyle == GridLineStyle.dotted,
                      onSelected: (_) => setState(() => _verticalLineStyle = GridLineStyle.dotted),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Stroke Width: ${_verticalStrokeWidth.toStringAsFixed(1)}', 
                     style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                Slider(
                  value: _verticalStrokeWidth,
                  min: 0.1,
                  max: 3.0,
                  divisions: 29,
                  label: _verticalStrokeWidth.toStringAsFixed(1),
                  onChanged: (val) => setState(() => _verticalStrokeWidth = val),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Opacity: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    Expanded(
                      child: Slider(
                        value: _verticalGridColor.opacity,
                        min: 0.0,
                        max: 1.0,
                        divisions: 20,
                        label: (_verticalGridColor.opacity * 100).toStringAsFixed(0) + '%',
                        onChanged: (val) => setState(() => 
                          _verticalGridColor = _verticalGridColor.withOpacity(val)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        // Grid Presets
        const SizedBox(height: 8),
        const Text(
          'Presets:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('No Grid'),
              selected: !_showHorizontalGrid && !_showVerticalGrid,
              onSelected: (_) => setState(() {
                _showHorizontalGrid = false;
                _showVerticalGrid = false;
              }),
            ),
            ChoiceChip(
              label: const Text('Horizontal'),
              selected: _showHorizontalGrid && !_showVerticalGrid,
              onSelected: (_) => setState(() {
                _showHorizontalGrid = true;
                _showVerticalGrid = false;
              }),
            ),
            ChoiceChip(
              label: const Text('Full Grid'),
              selected: _showHorizontalGrid && _showVerticalGrid,
              onSelected: (_) => setState(() {
                _showHorizontalGrid = true;
                _showVerticalGrid = true;
              }),
            ),
          ],
        ),
      ],
    );
  }
  
  // Labels Section
  Widget _buildLabelsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.label, size: 20, color: Colors.blue),
            const SizedBox(width: 8),
            const Text(
              'Label Configuration',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Adaptive Labels Toggle
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Adaptive Labels'),
          subtitle: const Text('Auto-adjust based on chart size', style: TextStyle(fontSize: 12)),
          value: _adaptiveLabels,
          onChanged: (val) => setState(() {
            _adaptiveLabels = val;
            if (val) {
              _priceLabelCount = null;
              _timeLabelDensity = null;
            }
          }),
        ),
        const SizedBox(height: 12),
        // Manual Controls (when adaptive is off)
        if (!_adaptiveLabels) ...[
          Text(
            'Price Labels: ${_priceLabelCount ?? 5}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Slider(
            value: (_priceLabelCount ?? 5).toDouble(),
            min: 3,
            max: 10,
            divisions: 7,
            label: (_priceLabelCount ?? 5).toString(),
            onChanged: (val) => setState(() => _priceLabelCount = val.toInt()),
          ),
          const SizedBox(height: 12),
          Text(
            'Time Label Density: ${_timeLabelDensity ?? 90}px',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Slider(
            value: (_timeLabelDensity ?? 90).toDouble(),
            min: 60,
            max: 120,
            divisions: 12,
            label: '${_timeLabelDensity ?? 90}px',
            onChanged: (val) => setState(() => _timeLabelDensity = val.toInt()),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Labels automatically adjust based on chart dimensions',
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
  
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
