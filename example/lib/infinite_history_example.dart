import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pipsend_charts/pipsend_charts.dart';

/// Example demonstrating Infinite History / Lazy Loading of historical data.
///
/// This example shows how to:
/// 1. Detect when the user scrolls near the beginning of the chart
/// 2. Load more historical data dynamically
/// 3. Maintain the visual position while adding data
/// 4. Show loading indicators
///
/// This pattern is similar to TradingView's Lightweight Charts
/// "Infinite History" feature.
class InfiniteHistoryExample extends StatefulWidget {
  const InfiniteHistoryExample({Key? key}) : super(key: key);

  @override
  State<InfiniteHistoryExample> createState() => _InfiniteHistoryExampleState();
}

class _InfiniteHistoryExampleState extends State<InfiniteHistoryExample> {
  List<CandleData> _candles = [];
  bool _isLoadingHistory = false;
  bool _isLoadingRecent = false;
  int _totalLoadedBatches = 0;
  
  // Simulate the "current" timestamp (most recent data point)
  late DateTime _currentTime;
  
  // Simulate the "oldest" timestamp we've loaded
  late DateTime _oldestTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _oldestTime = _currentTime.subtract(const Duration(days: 200));
    _loadInitialData();
  }

  /// Load initial data (e.g., last 200 candles)
  Future<void> _loadInitialData() async {
    final initialData = _generateMockCandles(
      startTime: _oldestTime,
      count: 200,
    );
    
    setState(() {
      _candles = initialData;
      _totalLoadedBatches = 1;
    });
  }

  /// Load more historical data (older candles)
  Future<void> _loadMoreHistory() async {
    if (_isLoadingHistory) return;
    
    setState(() => _isLoadingHistory = true);
    
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Calculate the timestamp for older data
    final oldestTimestamp = _candles.first.timestamp;
    final oldestDate = DateTime.fromMillisecondsSinceEpoch(oldestTimestamp);
    
    // Generate 100 more historical candles
    final olderData = _generateMockCandles(
      startTime: oldestDate.subtract(const Duration(days: 100)),
      count: 500,
    );
    
    setState(() {
      // Prepend: Add to the beginning of the list
      // The chart will automatically adjust the offset to maintain visual position
      _candles = [...olderData, ..._candles];
      _isLoadingHistory = false;
      _totalLoadedBatches++;
      _oldestTime = DateTime.fromMillisecondsSinceEpoch(_candles.first.timestamp);
    });
    
    print('✅ Loaded 100 more historical candles. Total: ${_candles.length}');
  }

  /// Load more recent data (newer candles)
  Future<void> _loadMoreRecent() async {
    if (_isLoadingRecent) return;
    
    setState(() => _isLoadingRecent = true);
    
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Calculate the timestamp for newer data
    final newestTimestamp = _candles.last.timestamp;
    final newestDate = DateTime.fromMillisecondsSinceEpoch(newestTimestamp);
    
    // Generate 50 more recent candles
    final newerData = _generateMockCandles(
      startTime: newestDate.add(const Duration(days: 1)),
      count: 50,
    );
    
    setState(() {
      // Append: Add to the end of the list
      _candles = [..._candles, ...newerData];
      _isLoadingRecent = false;
      _totalLoadedBatches++;
      _currentTime = DateTime.fromMillisecondsSinceEpoch(_candles.last.timestamp);
    });
    
    print('✅ Loaded 50 more recent candles. Total: ${_candles.length}');
  }

  /// Generate mock candle data for demonstration
  List<CandleData> _generateMockCandles({
    required DateTime startTime,
    required int count,
  }) {
    final random = Random();
    final candles = <CandleData>[];
    var price = 50000.0 + random.nextDouble() * 10000;
    
    for (int i = 0; i < count; i++) {
      final timestamp = startTime.add(Duration(days: i)).millisecondsSinceEpoch;
      
      // Random walk
      final change = (random.nextDouble() - 0.5) * 1000;
      price = (price + change).clamp(40000.0, 70000.0);
      
      final open = price;
      final close = price + (random.nextDouble() - 0.5) * 500;
      final high = max(open, close) + random.nextDouble() * 300;
      final low = min(open, close) - random.nextDouble() * 300;
      final volume = 1000000 + random.nextDouble() * 5000000;
      
      candles.add(CandleData(
        timestamp: timestamp,
        open: open,
        high: high,
        low: low,
        close: close,
        volume: volume,
      ));
      
      price = close;
    }
    
    return candles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Infinite History Example'),
        backgroundColor: const Color(0xFF1E222D),
      ),
      backgroundColor: const Color(0xFF131722),
      body: Column(
        children: [
          // Info Panel
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1E222D),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📊 Infinite History / Lazy Loading Demo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Candles: ${_candles.length}',
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  'Batches Loaded: $_totalLoadedBatches',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                const Text(
                  '💡 Scroll left to load more historical data',
                  style: TextStyle(color: Colors.blue, fontSize: 12),
                ),
                const Text(
                  '💡 Scroll right to load more recent data',
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
            ),
          ),
          
          // Loading Indicators
          if (_isLoadingHistory || _isLoadingRecent)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.orange.withOpacity(0.2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isLoadingHistory 
                        ? 'Loading historical data...' 
                        : 'Loading recent data...',
                    style: const TextStyle(color: Colors.orange),
                  ),
                ],
              ),
            ),
          
          // Chart
          Expanded(
            child: _candles.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: InteractiveChart(
                      candles: _candles,
                      style: ChartStyle(
                        priceGainColor: const Color(0xFF26A69A),
                        priceLossColor: const Color(0xFFEF5350),
                        volumeColor: const Color(0xFF26A69A).withOpacity(0.3),
                        timeLabelHeight: 32,
                        priceLabelWidth: 60,
                        overlayBackgroundColor: const Color(0xFF1E222D),
                        overlayTextStyle: const TextStyle(color: Colors.white),
                        selectionHighlightColor: Colors.blue.withOpacity(0.2),
                      ),
                      
                      // 🔥 This is where the magic happens!
                      onXOffsetChanged: (details) {
                        // Print debug info
                        print('📍 Offset changed:');
                        print('   Visible: ${details.startCandleIndex} - ${details.endCandleIndex}');
                        print('   Before: ${details.candlesBeforeVisible}');
                        print('   After: ${details.candlesAfterVisible}');
                        
                        // Load more historical data when near the start
                        // Use Future.microtask to avoid setState during build
                        if (details.isNearStart(50) && !_isLoadingHistory) {
                          print('⚠️ Near start! Loading more history...');
                          Future.microtask(() => _loadMoreHistory());
                        }
                        
                        // Load more recent data when near the end
                        // Use Future.microtask to avoid setState during build
                        if (details.isNearEnd(50) && !_isLoadingRecent) {
                          print('⚠️ Near end! Loading more recent data...');
                          Future.microtask(() => _loadMoreRecent());
                        }
                      },
                    ),
                  ),
          ),
          
          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1E222D),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🎯 How it works:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '1. onXOffsetChanged detects when you scroll',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  '2. isNearStart() checks if < 50 candles before visible area',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  '3. Load more data and prepend to the list',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  '4. Chart automatically maintains visual position',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
