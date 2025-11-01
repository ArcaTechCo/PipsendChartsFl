import 'package:flutter/material.dart';
import '../candle_data.dart';
import '../painter_params.dart';
import 'indicator.dart';
import 'indicator_panel.dart';
import 'indicator_value.dart';
import 'calculator/indicator_calculator.dart';

/// EMA (Exponential Moving Average) indicator.
///
/// EMA is similar to SMA but gives more weight to recent prices,
/// making it more responsive to new information.
///
/// The EMA reacts more quickly to price changes than the SMA,
/// which makes it useful for short-term trading and identifying trends earlier.
///
/// Example:
/// ```dart
/// EMAIndicator(
///   period: 12,
///   panel: IndicatorPanel.overlay(),
///   style: EMAStyle(
///     lineColor: Colors.orange,
///     lineWidth: 2.0,
///   ),
/// )
/// ```
class EMAIndicator extends Indicator {
  /// The number of periods to use for EMA calculation.
  /// Common values: 12 (fast), 26 (slow), 50, 200.
  final int period;

  EMAIndicator({
    String? id,
    this.period = 12,
    IndicatorPanel? panel,
    EMAStyle? style,
    bool visible = true,
  }) : super(
          id: id ?? 'ema_$period',
          panel: panel ?? IndicatorPanel.overlay(),
          style: style ?? const EMAStyle(),
          visible: visible,
        );

  @override
  List<IndicatorValue> calculate(List<CandleData> data) {
    // Extract close prices
    final closePrices = data.map((c) => c.close).toList();
    
    // Calculate EMA
    final emaValues = IndicatorCalculator.ema(closePrices, period);
    
    // Convert to IndicatorValue objects
    return emaValues.map((value) {
      return IndicatorValue(
        values: {'ema': value},
        timestamp: data[emaValues.indexOf(value)].timestamp,
      );
    }).toList();
  }

  @override
  void paint(Canvas canvas, PainterParams params, List<IndicatorValue> values) {
    if (!visible) return;
    if (values.isEmpty) return;

    final emaStyle = style as EMAStyle;
    final paint = Paint()
      ..color = emaStyle.lineColor
      ..strokeWidth = emaStyle.lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw the EMA line
    for (int i = 0; i < values.length - 1; i++) {
      final currentValue = values[i].values['ema'];
      final nextValue = values[i + 1].values['ema'];

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

/// Style configuration for EMA indicator.
class EMAStyle extends IndicatorStyle {
  /// The color of the EMA line.
  final Color lineColor;

  /// The width of the EMA line.
  final double lineWidth;

  const EMAStyle({
    this.lineColor = Colors.orange,
    this.lineWidth = 2.0,
  });
}
