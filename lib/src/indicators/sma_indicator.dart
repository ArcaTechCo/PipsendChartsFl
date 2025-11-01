import 'package:flutter/material.dart';
import '../candle_data.dart';
import '../painter_params.dart';
import 'indicator.dart';
import 'indicator_panel.dart';
import 'indicator_value.dart';
import 'calculator/indicator_calculator.dart';

/// SMA (Simple Moving Average) indicator.
///
/// SMA calculates the average price over a specified number of periods.
/// It's one of the most commonly used technical indicators.
///
/// The SMA smooths out price data by creating a constantly updated average price.
/// It's useful for identifying trend direction and potential support/resistance levels.
///
/// Example:
/// ```dart
/// SMAIndicator(
///   period: 20,
///   panel: IndicatorPanel.overlay(),
///   style: SMAStyle(
///     lineColor: Colors.blue,
///     lineWidth: 2.0,
///   ),
/// )
/// ```
class SMAIndicator extends Indicator {
  /// The number of periods to use for SMA calculation.
  /// Common values: 20 (short-term), 50 (medium-term), 200 (long-term).
  final int period;

  SMAIndicator({
    String? id,
    this.period = 20,
    IndicatorPanel? panel,
    SMAStyle? style,
    bool visible = true,
  }) : super(
          id: id ?? 'sma_$period',
          panel: panel ?? IndicatorPanel.overlay(),
          style: style ?? const SMAStyle(),
          visible: visible,
        );

  @override
  List<IndicatorValue> calculate(List<CandleData> data) {
    // Extract close prices
    final closePrices = data.map((c) => c.close).toList();
    
    // Calculate SMA
    final smaValues = IndicatorCalculator.sma(closePrices, period);
    
    // Convert to IndicatorValue objects
    return smaValues.map((value) {
      return IndicatorValue(
        values: {'sma': value},
        timestamp: data[smaValues.indexOf(value)].timestamp,
      );
    }).toList();
  }

  @override
  void paint(Canvas canvas, PainterParams params, List<IndicatorValue> values) {
    if (!visible) return;
    if (values.isEmpty) return;

    final smaStyle = style as SMAStyle;
    final paint = Paint()
      ..color = smaStyle.lineColor
      ..strokeWidth = smaStyle.lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw the SMA line
    for (int i = 0; i < values.length - 1; i++) {
      final currentValue = values[i].values['sma'];
      final nextValue = values[i + 1].values['sma'];

      if (currentValue == null || nextValue == null) continue;

      // Find the index in visible candles using timestamp
      final currentIndex = params.candles.indexWhere((c) => c.timestamp == values[i].timestamp);
      final nextIndex = params.candles.indexWhere((c) => c.timestamp == values[i + 1].timestamp);
      
      if (currentIndex < 0 || nextIndex < 0) continue;

      final x1 = currentIndex * params.candleWidth;
      final y1 = params.fitPrice(currentValue);
      final x2 = nextIndex * params.candleWidth;
      final y2 = params.fitPrice(nextValue);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }
}

/// Style configuration for SMA indicator.
class SMAStyle extends IndicatorStyle {
  /// The color of the SMA line.
  final Color lineColor;

  /// The width of the SMA line.
  final double lineWidth;

  const SMAStyle({
    this.lineColor = Colors.blue,
    this.lineWidth = 2.0,
  });
}
