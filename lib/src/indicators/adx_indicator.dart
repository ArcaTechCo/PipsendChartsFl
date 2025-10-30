import 'dart:math';
import 'package:flutter/material.dart';
import '../candle_data.dart';
import '../painter_params.dart';
import 'indicator.dart';
import 'indicator_panel.dart';
import 'indicator_value.dart';

/// ADX (Average Directional Index) indicator.
///
/// ADX measures the strength of a trend, regardless of direction.
/// It's derived from the +DI and -DI indicators.
///
/// ADX values:
/// - 0-25: Weak or no trend
/// - 25-50: Strong trend
/// - 50-75: Very strong trend
/// - 75-100: Extremely strong trend
///
/// Example:
/// ```dart
/// ADXIndicator(
///   period: 14,
///   panel: IndicatorPanel.separate(height: 0.2),
///   style: ADXStyle(
///     adxLineColor: Colors.blue,
///     plusDIColor: Colors.green,
///     minusDIColor: Colors.red,
///   ),
/// )
/// ```
class ADXIndicator extends Indicator {
  /// The period for ADX calculation (typically 14).
  final int period;

  ADXIndicator({
    String? id,
    this.period = 14,
    IndicatorPanel? panel,
    ADXStyle? style,
    bool visible = true,
  }) : super(
          id: id ?? 'adx_$period',
          panel: panel ?? IndicatorPanel.separate(height: 0.2),
          style: style ?? const ADXStyle(),
          visible: visible,
        );

  @override
  List<IndicatorValue> calculate(List<CandleData> data) {
    final result = <IndicatorValue>[];
    final trueRanges = <double>[];
    final plusDMs = <double>[];
    final minusDMs = <double>[];

    // Calculate TR, +DM, -DM
    for (int i = 0; i < data.length; i++) {
      if (i == 0) {
        trueRanges.add(0);
        plusDMs.add(0);
        minusDMs.add(0);
        result.add(IndicatorValue(
          values: {'adx': null, 'plusDI': null, 'minusDI': null},
          timestamp: data[i].timestamp,
        ));
        continue;
      }

      final high = data[i].high;
      final low = data[i].low;
      final prevHigh = data[i - 1].high;
      final prevLow = data[i - 1].low;
      final prevClose = data[i - 1].close;

      if (high == null || low == null || prevHigh == null || 
          prevLow == null || prevClose == null) {
        trueRanges.add(0);
        plusDMs.add(0);
        minusDMs.add(0);
        result.add(IndicatorValue(
          values: {'adx': null, 'plusDI': null, 'minusDI': null},
          timestamp: data[i].timestamp,
        ));
        continue;
      }

      // True Range
      final tr = max(
        high - low,
        max((high - prevClose).abs(), (low - prevClose).abs()),
      );

      // Directional Movement
      final upMove = high - prevHigh;
      final downMove = prevLow - low;

      final plusDM = (upMove > downMove && upMove > 0) ? upMove : 0.0;
      final minusDM = (downMove > upMove && downMove > 0) ? downMove : 0.0;

      trueRanges.add(tr);
      plusDMs.add(plusDM);
      minusDMs.add(minusDM);

      if (i < period) {
        result.add(IndicatorValue(
          values: {'adx': null, 'plusDI': null, 'minusDI': null},
          timestamp: data[i].timestamp,
        ));
        continue;
      }

      // Smoothed TR, +DM, -DM
      double smoothedTR, smoothedPlusDM, smoothedMinusDM;

      if (i == period) {
        smoothedTR = trueRanges.sublist(1, period + 1).reduce((a, b) => a + b);
        smoothedPlusDM = plusDMs.sublist(1, period + 1).reduce((a, b) => a + b);
        smoothedMinusDM = minusDMs.sublist(1, period + 1).reduce((a, b) => a + b);
      } else {
        final prevTR = result[i - 1].values['_smoothedTR'] ?? 0.0;
        final prevPlusDM = result[i - 1].values['_smoothedPlusDM'] ?? 0.0;
        final prevMinusDM = result[i - 1].values['_smoothedMinusDM'] ?? 0.0;

        smoothedTR = prevTR - (prevTR / period) + tr;
        smoothedPlusDM = prevPlusDM - (prevPlusDM / period) + plusDM;
        smoothedMinusDM = prevMinusDM - (prevMinusDM / period) + minusDM;
      }

      // +DI and -DI
      final plusDI = smoothedTR > 0 ? (smoothedPlusDM / smoothedTR) * 100 : 0.0;
      final minusDI = smoothedTR > 0 ? (smoothedMinusDM / smoothedTR) * 100 : 0.0;

      // DX
      final diSum = plusDI + minusDI;
      final dx = diSum > 0 ? ((plusDI - minusDI).abs() / diSum) * 100 : 0.0;

      result.add(IndicatorValue(
        values: {
          'adx': null,
          'plusDI': plusDI,
          'minusDI': minusDI,
          '_dx': dx,
          '_smoothedTR': smoothedTR,
          '_smoothedPlusDM': smoothedPlusDM,
          '_smoothedMinusDM': smoothedMinusDM,
        },
        timestamp: data[i].timestamp,
      ));
    }

    // Calculate ADX (smoothed DX)
    for (int i = 0; i < result.length; i++) {
      if (i < period * 2 - 1) continue;

      if (i == period * 2 - 1) {
        // First ADX: average of DX values
        double dxSum = 0;
        for (int j = 0; j < period; j++) {
          dxSum += result[i - j].values['_dx'] ?? 0.0;
        }
        result[i] = IndicatorValue(
          values: {
            ...result[i].values,
            'adx': dxSum / period,
          },
          timestamp: result[i].timestamp,
        );
      } else {
        // Subsequent ADX: smoothed
        final prevADX = result[i - 1].values['adx'] ?? 0.0;
        final currentDX = result[i].values['_dx'] ?? 0.0;
        final adx = ((prevADX * (period - 1)) + currentDX) / period;

        result[i] = IndicatorValue(
          values: {
            ...result[i].values,
            'adx': adx,
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

    final adxStyle = style as ADXStyle;

    // Draw ADX line
    final adxPaint = Paint()
      ..color = adxStyle.adxLineColor
      ..strokeWidth = adxStyle.lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < values.length - 1; i++) {
      final currentADX = values[i].values['adx'];
      final nextADX = values[i + 1].values['adx'];

      if (currentADX == null || nextADX == null) continue;

      final x1 = i * params.candleWidth;
      final y1 = params.fitPrice(currentADX);
      final x2 = (i + 1) * params.candleWidth;
      final y2 = params.fitPrice(nextADX);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), adxPaint);
    }

    // Draw +DI line
    final plusDIPaint = Paint()
      ..color = adxStyle.plusDIColor
      ..strokeWidth = adxStyle.lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < values.length - 1; i++) {
      final currentDI = values[i].values['plusDI'];
      final nextDI = values[i + 1].values['plusDI'];

      if (currentDI == null || nextDI == null) continue;

      final x1 = i * params.candleWidth;
      final y1 = params.fitPrice(currentDI);
      final x2 = (i + 1) * params.candleWidth;
      final y2 = params.fitPrice(nextDI);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), plusDIPaint);
    }

    // Draw -DI line
    final minusDIPaint = Paint()
      ..color = adxStyle.minusDIColor
      ..strokeWidth = adxStyle.lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < values.length - 1; i++) {
      final currentDI = values[i].values['minusDI'];
      final nextDI = values[i + 1].values['minusDI'];

      if (currentDI == null || nextDI == null) continue;

      final x1 = i * params.candleWidth;
      final y1 = params.fitPrice(currentDI);
      final x2 = (i + 1) * params.candleWidth;
      final y2 = params.fitPrice(nextDI);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), minusDIPaint);
    }
  }
}

/// Style configuration for ADX indicator.
class ADXStyle extends IndicatorStyle {
  /// The color of the ADX line.
  final Color adxLineColor;

  /// The color of the +DI line.
  final Color plusDIColor;

  /// The color of the -DI line.
  final Color minusDIColor;

  /// The width of the lines.
  final double lineWidth;

  const ADXStyle({
    this.adxLineColor = Colors.blue,
    this.plusDIColor = Colors.green,
    this.minusDIColor = Colors.red,
    this.lineWidth = 2.0,
  });
}
