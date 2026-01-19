import 'package:flutter/material.dart';
import '../candle_data.dart';
import '../painter_params.dart';
import 'indicator.dart';
import 'indicator_panel.dart';
import 'indicator_value.dart';
import 'calculator/indicator_calculator.dart';

/// WMA (Weighted Moving Average) indicator.
///
/// WMA is similar to SMA but assigns linearly decreasing weights to older values,
/// giving more importance to recent prices while still considering historical data.
///
/// The WMA provides a balance between SMA and EMA:
/// - More responsive than SMA to recent price changes
/// - Less reactive than EMA, providing smoother signals
/// - Useful for short to medium-term trend analysis
///
/// Weight calculation: Most recent value gets weight = period,
/// second most recent = period-1, and so on.
///
/// Example:
/// ```dart
/// WMAIndicator(
///   period: 20,
///   panel: IndicatorPanel.overlay(),
///   style: WMAStyle(
///     lineColor: Colors.purple,
///     lineWidth: 2.0,
///   ),
/// )
/// ```
class WMAIndicator extends Indicator {
  /// The number of periods to use for WMA calculation.
  /// Common values: 10 (short-term), 20 (medium-term), 50 (long-term).
  final int period;

  WMAIndicator({
    String? id,
    this.period = 20,
    IndicatorPanel? panel,
    WMAStyle? style,
    bool visible = true,
  }) : super(
          id: id ?? 'wma_$period',
          panel: panel ?? IndicatorPanel.overlay(),
          style: style ?? const WMAStyle(),
          visible: visible,
        );

  @override
  List<IndicatorValue> calculate(List<CandleData> data) {
    final closePrices = data.map((c) => c.close).toList();
    
    final wmaValues = IndicatorCalculator.wma(closePrices, period);
    
    return wmaValues.map((value) {
      return IndicatorValue(
        values: {'wma': value},
        timestamp: data[wmaValues.indexOf(value)].timestamp,
      );
    }).toList();
  }

  @override
  void paint(Canvas canvas, PainterParams params, List<IndicatorValue> values) {
    if (!visible) return;
    if (values.isEmpty) return;

    final wmaStyle = style as WMAStyle;
    final paint = Paint()
      ..color = wmaStyle.lineColor
      ..strokeWidth = wmaStyle.lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < values.length - 1; i++) {
      final currentValue = values[i].values['wma'];
      final nextValue = values[i + 1].values['wma'];

      if (currentValue == null || nextValue == null) continue;

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

/// Style configuration for WMA indicator.
class WMAStyle extends IndicatorStyle {
  /// The color of the WMA line.
  final Color lineColor;

  /// The width of the WMA line.
  final double lineWidth;

  const WMAStyle({
    this.lineColor = Colors.purple,
    this.lineWidth = 2.0,
  });
}
