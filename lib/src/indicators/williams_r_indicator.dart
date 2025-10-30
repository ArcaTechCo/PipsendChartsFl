import 'dart:math';
import 'package:flutter/material.dart';
import '../candle_data.dart';
import '../painter_params.dart';
import 'indicator.dart';
import 'indicator_panel.dart';
import 'indicator_value.dart';

/// Williams %R indicator.
///
/// Williams %R is a momentum indicator that measures overbought and oversold levels.
/// It's similar to the Stochastic Oscillator but inverted (ranges from 0 to -100).
///
/// Williams %R values:
/// - 0 to -20: Overbought (potential sell signal)
/// - -80 to -100: Oversold (potential buy signal)
///
/// Example:
/// ```dart
/// WilliamsRIndicator(
///   period: 14,
///   panel: IndicatorPanel.separate(height: 0.2),
///   style: WilliamsRStyle(
///     lineColor: Colors.teal,
///     overboughtLevel: -20,
///     oversoldLevel: -80,
///   ),
/// )
/// ```
class WilliamsRIndicator extends Indicator {
  /// The period for Williams %R calculation (typically 14).
  final int period;

  /// The overbought level (typically -20).
  final double overbought;

  /// The oversold level (typically -80).
  final double oversold;

  WilliamsRIndicator({
    String? id,
    this.period = 14,
    this.overbought = -20,
    this.oversold = -80,
    IndicatorPanel? panel,
    WilliamsRStyle? style,
    bool visible = true,
  }) : super(
          id: id ?? 'williams_r_$period',
          panel: panel ?? IndicatorPanel.separate(height: 0.2),
          style: style ?? const WilliamsRStyle(),
          visible: visible,
        );

  @override
  List<IndicatorValue> calculate(List<CandleData> data) {
    final result = <IndicatorValue>[];

    for (int i = 0; i < data.length; i++) {
      if (i < period - 1) {
        result.add(IndicatorValue(
          values: {'williams_r': null},
          timestamp: data[i].timestamp,
        ));
        continue;
      }

      // Find highest high and lowest low in period
      double? highestHigh;
      double? lowestLow;

      for (int j = 0; j < period; j++) {
        final candle = data[i - j];
        final high = candle.high;
        final low = candle.low;

        if (high != null && low != null) {
          highestHigh = highestHigh == null ? high : max(highestHigh, high);
          lowestLow = lowestLow == null ? low : min(lowestLow, low);
        }
      }

      double? williamsR;
      if (highestHigh != null && lowestLow != null && data[i].close != null) {
        final range = highestHigh - lowestLow;
        if (range > 0) {
          williamsR = ((highestHigh - data[i].close!) / range) * -100;
        }
      }

      result.add(IndicatorValue(
        values: {'williams_r': williamsR},
        timestamp: data[i].timestamp,
      ));
    }

    return result;
  }

  @override
  void paint(Canvas canvas, PainterParams params, List<IndicatorValue> values) {
    if (!visible) return;
    if (values.isEmpty) return;

    final wrStyle = style as WilliamsRStyle;

    // Draw overbought/oversold zones
    final overboughtY = params.fitPrice(overbought);
    final oversoldY = params.fitPrice(oversold);

    // Overbought zone (top)
    canvas.drawRect(
      Rect.fromLTRB(0, 0, params.chartWidth, overboughtY),
      Paint()..color = wrStyle.overboughtColor,
    );

    // Oversold zone (bottom)
    canvas.drawRect(
      Rect.fromLTRB(0, oversoldY, params.chartWidth, params.priceHeight),
      Paint()..color = wrStyle.oversoldColor,
    );

    // Draw Williams %R line
    final paint = Paint()
      ..color = wrStyle.lineColor
      ..strokeWidth = wrStyle.lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < values.length - 1; i++) {
      final currentWR = values[i].values['williams_r'];
      final nextWR = values[i + 1].values['williams_r'];

      if (currentWR == null || nextWR == null) continue;

      final x1 = i * params.candleWidth;
      final y1 = params.fitPrice(currentWR);
      final x2 = (i + 1) * params.candleWidth;
      final y2 = params.fitPrice(nextWR);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }
}

/// Style configuration for Williams %R indicator.
class WilliamsRStyle extends IndicatorStyle {
  /// The color of the Williams %R line.
  final Color lineColor;

  /// The width of the Williams %R line.
  final double lineWidth;

  /// The color of the overbought zone.
  final Color overboughtColor;

  /// The color of the oversold zone.
  final Color oversoldColor;

  const WilliamsRStyle({
    this.lineColor = Colors.teal,
    this.lineWidth = 2.0,
    this.overboughtColor = const Color(0x1AFF0000),
    this.oversoldColor = const Color(0x1A00FF00),
  });
}
