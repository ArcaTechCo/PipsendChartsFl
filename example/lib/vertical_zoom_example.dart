import 'package:flutter/material.dart';
import 'package:pipsend_charts/pipsend_charts.dart';

/// Example demonstrating vertical zoom and pan functionality
class VerticalZoomExample extends StatefulWidget {
  const VerticalZoomExample({Key? key}) : super(key: key);

  @override
  State<VerticalZoomExample> createState() => _VerticalZoomExampleState();
}

class _VerticalZoomExampleState extends State<VerticalZoomExample> {
  final GlobalKey<State<StatefulWidget>> _chartKey = GlobalKey();
  double _currentZoom = 1.3;

  // Sample data
  final List<CandleData> _candles = [
    CandleData(timestamp: 1000, open: 1.2100, high: 1.2150, low: 1.2050, close: 1.2120, volume: 1000),
    CandleData(timestamp: 2000, open: 1.2120, high: 1.2180, low: 1.2100, close: 1.2160, volume: 1200),
    CandleData(timestamp: 3000, open: 1.2160, high: 1.2200, low: 1.2140, close: 1.2180, volume: 1100),
    CandleData(timestamp: 4000, open: 1.2180, high: 1.2220, low: 1.2150, close: 1.2200, volume: 1300),
    CandleData(timestamp: 5000, open: 1.2200, high: 1.2250, low: 1.2180, close: 1.2230, volume: 1400),
    CandleData(timestamp: 6000, open: 1.2230, high: 1.2280, low: 1.2210, close: 1.2260, volume: 1500),
    CandleData(timestamp: 7000, open: 1.2260, high: 1.2300, low: 1.2240, close: 1.2280, volume: 1600),
    CandleData(timestamp: 8000, open: 1.2280, high: 1.2320, low: 1.2260, close: 1.2300, volume: 1700),
    CandleData(timestamp: 9000, open: 1.2300, high: 1.2350, low: 1.2280, close: 1.2330, volume: 1800),
    CandleData(timestamp: 10000, open: 1.2330, high: 1.2380, low: 1.2310, close: 1.2360, volume: 1900),
  ];

  final List<ChartOverlay> _overlays = [
    TradingLine(
      price: 1.2400,
      type: TradingLineType.takeProfit,
      options: TradingLineOptions(
        title: 'TP',
        showLabel: true,
        draggable: true,
      ),
    ),
    TradingLine(
      price: 1.2000,
      type: TradingLineType.stopLoss,
      options: TradingLineOptions(
        title: 'SL',
        showLabel: true,
        draggable: true,
      ),
    ),
  ];

  void _setZoom(double zoom) {
    setState(() {
      _currentZoom = zoom;
    });
    // Note: In a real implementation, you would call:
    // (_chartKey.currentState as _InteractiveChartState?)?.setVerticalZoom(zoom);
  }

  void _resetView() {
    setState(() {
      _currentZoom = 1.0;
    });
    // Note: In a real implementation, you would call:
    // (_chartKey.currentState as _InteractiveChartState?)?.resetVerticalView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vertical Zoom Example'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Control Panel
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Controles de Zoom Vertical',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Zoom: ${_currentZoom.toStringAsFixed(1)}x'),
                          Slider(
                            value: _currentZoom,
                            min: 0.5,
                            max: 3.0,
                            divisions: 25,
                            label: _currentZoom.toStringAsFixed(1),
                            onChanged: _setZoom,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: () => _setZoom(1.0),
                      child: const Text('Fit (1.0x)'),
                    ),
                    ElevatedButton(
                      onPressed: () => _setZoom(1.3),
                      child: const Text('Normal (1.3x)'),
                    ),
                    ElevatedButton(
                      onPressed: () => _setZoom(1.5),
                      child: const Text('Zoom Out (1.5x)'),
                    ),
                    ElevatedButton(
                      onPressed: () => _setZoom(2.0),
                      child: const Text('Max (2.0x)'),
                    ),
                    ElevatedButton(
                      onPressed: _resetView,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Atajos de teclado:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text('• Shift + Scroll: Zoom vertical'),
                const Text('• Alt + Scroll: Pan vertical'),
                const Text('• Scroll: Zoom horizontal (normal)'),
                const SizedBox(height: 8),
                const Text(
                  'Nota: Las líneas TP/SL ahora son visibles gracias al zoom vertical',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          // Chart
          Expanded(
            child: InteractiveChart(
              key: _chartKey,
              candles: _candles,
              enableVerticalPan: true, // Enable vertical zoom/pan
              initialVerticalZoom: _currentZoom,
              overlays: _overlays,
              style: const ChartStyle(
                priceGainColor: Colors.green,
                priceLossColor: Colors.red,
                volumeColor: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
