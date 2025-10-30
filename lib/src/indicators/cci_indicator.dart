import 'package:flutter/material.dart';
import '../candle_data.dart';
import '../painter_params.dart';
import 'indicator.dart';
import 'indicator_panel.dart';
import 'indicator_value.dart';

/// CCI (Commodity Channel Index) indicator.
///
/// CCI measures the variation of a security's price from its statistical mean.
/// It's used to identify cyclical trends and overbought/oversold conditions.
///
/// CCI values:
/// - Above +100: Overbought (potential sell signal)
/// - Below -100: Oversold (potential buy signal)
/// - Between -100 and +100: Normal range
///
/// Example:
/// ```dart
/// CCIIndicator(
///   period: 20,
///   panel: IndicatorPanel.separate(height: 0.2),
///   style: CCIStyle(
///     lineColor: Colors.purple,
///     overboughtLevel: 100,
///     oversoldLevel: -100,
///   ),
/// )
/// ```
class CCIIndicator extends Indicator {
  /// The period for CCI calculation (typically 20).
  final int period;

  /// The overbought level (typically 100).
  final double overbought;

  /// The oversold level (typically -100).
  final double oversold;

  CCIIndicator({
    String? id,
    this.period = 20,
    this.overbought = 100,
    this.oversold = -100,
    IndicatorPanel? panel,
    CCIStyle? style,
    bool visible = true,
  }) : super(
          id: id ?? 'cci_$period',
          panel: panel ?? IndicatorPanel.separate(height: 0.2),
          style: style ?? const CCIStyle(),
          visible: visible,
        );

  @override
  List<IndicatorValue> calculate(List<CandleData> data) {
    final result = <IndicatorValue>[];
    final typicalPrices = <double>[];

    // Calculate Typical Price for each candle
    for (final candle in data) {
      final high = candle.high;
      final low = candle.low;
      final close = candle.close;

      if (high != null && low != null && close != null) {
        typicalPrices.add((high + low + close) / 3);
      } else {
        typicalPrices.add(0);
      }
    }

    for (int i = 0; i < data.length; i++) {
      if (i < period - 1) {
        result.add(IndicatorValue(
          values: {'cci': null},
          timestamp: data[i].timestamp,
        ));
        continue;
      }

      // Calculate SMA of Typical Price
      double sum = 0;
      for (int j = 0; j < period; j++) {
        sum += typicalPrices[i - j];
      }
      final sma = sum / period;

      // Calculate Mean Deviation
      double deviationSum = 0;
      for (int j = 0; j < period; j++) {
        deviationSum += (typicalPrices[i - j] - sma).abs();
      }
      final meanDeviation = deviationSum / period;

      // Calculate CCI
      double? cci;
      if (meanDeviation > 0) {
        cci = (typicalPrices[i] - sma) / (0.015 * meanDeviation);
      }

      result.add(IndicatorValue(
        values: {'cci': cci},
        timestamp: data[i].timestamp,
      ));
    }

    return result;
  }

  @override
  void paint(Canvas canvas, PainterParams params, List<IndicatorValue> values) {
    if (!visible) return;
    if (values.isEmpty) return;

    final cciStyle = style as CCIStyle;

    // Draw overbought/oversold zones
    final overboughtY = params.fitPrice(overbought);
    final oversoldY = params.fitPrice(oversold);
    final zeroY = params.fitPrice(0);

    // Overbought zone
    canvas.drawRect(
      Rect.fromLTRB(0, 0, params.chartWidth, overboughtY),
      Paint()..color = cciStyle.overboughtColor,
    );

    // Oversold zone
    canvas.drawRect(
      Rect.fromLTRB(0, oversoldY, params.chartWidth, params.priceHeight),
      Paint()..color = cciStyle.oversoldColor,
    );

    // Zero line
    canvas.drawLine(
      Offset(0, zeroY),
      Offset(params.chartWidth, zeroY),
      Paint()
        ..color = cciStyle.zeroLineColor
        ..strokeWidth = 1.0,
    );

    // Draw CCI line
    final paint = Paint()
      ..color = cciStyle.lineColor
      ..strokeWidth = cciStyle.lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < values.length - 1; i++) {
      final currentCCI = values[i].values['cci'];
      final nextCCI = values[i + 1].values['cci'];

      if (currentCCI == null || nextCCI == null) continue;

      final x1 = i * params.candleWidth;
      final y1 = params.fitPrice(currentCCI);
      final x2 = (i + 1) * params.candleWidth;
      final y2 = params.fitPrice(nextCCI);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }
}

/// Style configuration for CCI indicator.
class CCIStyle extends IndicatorStyle {
  /// The color of the CCI line.
  final Color lineColor;

  /// The width of the CCI line.
  final double lineWidth;

  /// The color of the overbought zone.
  final Color overboughtColor;

  /// The color of the oversold zone.
  final Color oversoldColor;

  /// The color of the zero line.
  final Color zeroLineColor;

  const CCIStyle({
    this.lineColor = Colors.purple,
    this.lineWidth = 2.0,
    this.overboughtColor = const Color(0x1AFF0000),
    this.oversoldColor = const Color(0x1A00FF00),
    this.zeroLineColor = Colors.grey,
  });
}
