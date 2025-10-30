import 'dart:math';
import 'package:flutter/material.dart';
import '../candle_data.dart';
import '../painter_params.dart';
import 'indicator.dart';
import 'indicator_panel.dart';
import 'indicator_value.dart';

/// Stochastic Oscillator indicator.
///
/// The Stochastic Oscillator compares a closing price to its price range
/// over a given time period. It consists of two lines:
/// - %K line: The main stochastic line
/// - %D line: A moving average of %K (signal line)
///
/// The oscillator ranges from 0 to 100:
/// - Above 80: Overbought (potential sell signal)
/// - Below 20: Oversold (potential buy signal)
///
/// Example:
/// ```dart
/// StochasticIndicator(
///   kPeriod: 14,
///   dPeriod: 3,
///   panel: IndicatorPanel.separate(height: 0.2),
///   style: StochasticStyle(
///     kLineColor: Colors.blue,
///     dLineColor: Colors.red,
///   ),
/// )
/// ```
class StochasticIndicator extends Indicator {
  /// The period for %K calculation (typically 14).
  final int kPeriod;

  /// The period for %D calculation (typically 3).
  final int dPeriod;

  /// The overbought level (typically 80).
  final double overbought;

  /// The oversold level (typically 20).
  final double oversold;

  StochasticIndicator({
    String? id,
    this.kPeriod = 14,
    this.dPeriod = 3,
    this.overbought = 80,
    this.oversold = 20,
    IndicatorPanel? panel,
    StochasticStyle? style,
    bool visible = true,
  }) : super(
          id: id ?? 'stochastic_${kPeriod}_$dPeriod',
          panel: panel ?? IndicatorPanel.separate(height: 0.2),
          style: style ?? const StochasticStyle(),
          visible: visible,
        );

  @override
  List<IndicatorValue> calculate(List<CandleData> data) {
    final result = <IndicatorValue>[];

    for (int i = 0; i < data.length; i++) {
      if (i < kPeriod - 1) {
        result.add(IndicatorValue(
          values: {'k': null, 'd': null},
          timestamp: data[i].timestamp,
        ));
        continue;
      }

      // Calculate %K
      double? highest;
      double? lowest;

      for (int j = 0; j < kPeriod; j++) {
        final candle = data[i - j];
        final high = candle.high;
        final low = candle.low;

        if (high != null && low != null) {
          highest = highest == null ? high : max(highest, high);
          lowest = lowest == null ? low : min(lowest, low);
        }
      }

      double? kValue;
      if (highest != null && lowest != null && data[i].close != null) {
        final range = highest - lowest;
        if (range > 0) {
          kValue = ((data[i].close! - lowest) / range) * 100;
        }
      }

      result.add(IndicatorValue(
        values: {'k': kValue, 'd': null},
        timestamp: data[i].timestamp,
      ));
    }

    // Calculate %D (SMA of %K)
    for (int i = 0; i < result.length; i++) {
      if (i < kPeriod - 1 + dPeriod - 1) {
        continue;
      }

      double sum = 0;
      int count = 0;

      for (int j = 0; j < dPeriod; j++) {
        final kVal = result[i - j].values['k'];
        if (kVal != null) {
          sum += kVal;
          count++;
        }
      }

      if (count == dPeriod) {
        result[i] = IndicatorValue(
          values: {
            'k': result[i].values['k'],
            'd': sum / dPeriod,
          },
          timestamp: result[i].timestamp,
        );
      }
    }

    return result;
  }

  @override
  void paint(Canvas canvas, PainterParams params, List<IndicatorValue> values) {
    if (!visible) return;
    if (values.isEmpty) return;

    final stochStyle = style as StochasticStyle;

    // Draw overbought/oversold zones
    final overboughtY = params.fitPrice(overbought);
    final oversoldY = params.fitPrice(oversold);

    canvas.drawRect(
      Rect.fromLTRB(0, 0, params.chartWidth, overboughtY),
      Paint()..color = stochStyle.overboughtColor,
    );

    canvas.drawRect(
      Rect.fromLTRB(0, oversoldY, params.chartWidth, params.priceHeight),
      Paint()..color = stochStyle.oversoldColor,
    );

    // Draw %K line
    final kPaint = Paint()
      ..color = stochStyle.kLineColor
      ..strokeWidth = stochStyle.lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < values.length - 1; i++) {
      final currentK = values[i].values['k'];
      final nextK = values[i + 1].values['k'];

      if (currentK == null || nextK == null) continue;

      final x1 = i * params.candleWidth;
      final y1 = params.fitPrice(currentK);
      final x2 = (i + 1) * params.candleWidth;
      final y2 = params.fitPrice(nextK);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), kPaint);
    }

    // Draw %D line
    final dPaint = Paint()
      ..color = stochStyle.dLineColor
      ..strokeWidth = stochStyle.lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < values.length - 1; i++) {
      final currentD = values[i].values['d'];
      final nextD = values[i + 1].values['d'];

      if (currentD == null || nextD == null) continue;

      final x1 = i * params.candleWidth;
      final y1 = params.fitPrice(currentD);
      final x2 = (i + 1) * params.candleWidth;
      final y2 = params.fitPrice(nextD);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), dPaint);
    }
  }
}

/// Style configuration for Stochastic indicator.
class StochasticStyle extends IndicatorStyle {
  /// The color of the %K line.
  final Color kLineColor;

  /// The color of the %D line.
  final Color dLineColor;

  /// The width of the lines.
  final double lineWidth;

  /// The color of the overbought zone.
  final Color overboughtColor;

  /// The color of the oversold zone.
  final Color oversoldColor;

  const StochasticStyle({
    this.kLineColor = Colors.blue,
    this.dLineColor = Colors.red,
    this.lineWidth = 2.0,
    this.overboughtColor = const Color(0x1AFF0000),
    this.oversoldColor = const Color(0x1A00FF00),
  });
}
