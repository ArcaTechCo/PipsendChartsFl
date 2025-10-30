import 'package:flutter/material.dart';
import '../candle_data.dart';
import '../painter_params.dart';
import 'indicator.dart';
import 'indicator_panel.dart';
import 'indicator_value.dart';

/// OBV (On-Balance Volume) indicator.
///
/// OBV is a momentum indicator that uses volume flow to predict changes in price.
/// It's based on the premise that volume precedes price movement.
///
/// OBV interpretation:
/// - Rising OBV: Buying pressure (bullish)
/// - Falling OBV: Selling pressure (bearish)
/// - OBV confirms price trend when moving in same direction
/// - Divergence between OBV and price may signal reversal
///
/// Example:
/// ```dart
/// OBVIndicator(
///   panel: IndicatorPanel.separate(height: 0.2),
///   style: OBVStyle(
///     lineColor: Colors.cyan,
///     lineWidth: 2.0,
///   ),
/// )
/// ```
class OBVIndicator extends Indicator {
  OBVIndicator({
    String? id,
    IndicatorPanel? panel,
    OBVStyle? style,
    bool visible = true,
  }) : super(
          id: id ?? 'obv',
          panel: panel ?? IndicatorPanel.separate(height: 0.2),
          style: style ?? const OBVStyle(),
          visible: visible,
        );

  @override
  List<IndicatorValue> calculate(List<CandleData> data) {
    final result = <IndicatorValue>[];
    double obv = 0;

    for (int i = 0; i < data.length; i++) {
      final candle = data[i];
      final close = candle.close;
      final volume = candle.volume;

      if (close == null || volume == null) {
        result.add(IndicatorValue(
          values: {'obv': obv},
          timestamp: candle.timestamp,
        ));
        continue;
      }

      if (i == 0) {
        // First candle: OBV = volume
        obv = volume;
      } else {
        final prevClose = data[i - 1].close;
        if (prevClose != null) {
          if (close > prevClose) {
            // Price up: add volume
            obv += volume;
          } else if (close < prevClose) {
            // Price down: subtract volume
            obv -= volume;
          }
          // If close == prevClose, OBV stays the same
        }
      }

      result.add(IndicatorValue(
        values: {'obv': obv},
        timestamp: candle.timestamp,
      ));
    }

    return result;
  }

  @override
  void paint(Canvas canvas, PainterParams params, List<IndicatorValue> values) {
    if (!visible) return;
    if (values.isEmpty) return;

    final obvStyle = style as OBVStyle;

    // Find min/max for scaling
    double? minOBV;
    double? maxOBV;
    for (final value in values) {
      final obv = value.values['obv'];
      if (obv != null) {
        minOBV = minOBV == null ? obv : (obv < minOBV ? obv : minOBV);
        maxOBV = maxOBV == null ? obv : (obv > maxOBV ? obv : maxOBV);
      }
    }

    if (minOBV == null || maxOBV == null) return;

    // Add padding
    final range = maxOBV - minOBV;
    final paddedMin = minOBV - (range * 0.1);
    final paddedMax = maxOBV + (range * 0.1);
    final paddedRange = paddedMax - paddedMin;

    if (paddedRange == 0) return;

    // Draw OBV line
    final paint = Paint()
      ..color = obvStyle.lineColor
      ..strokeWidth = obvStyle.lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < values.length - 1; i++) {
      final currentOBV = values[i].values['obv'];
      final nextOBV = values[i + 1].values['obv'];

      if (currentOBV == null || nextOBV == null) continue;

      // Scale to chart height
      final y1 = params.priceHeight - 
          ((currentOBV - paddedMin) / paddedRange) * params.priceHeight;
      final y2 = params.priceHeight - 
          ((nextOBV - paddedMin) / paddedRange) * params.priceHeight;

      final x1 = i * params.candleWidth;
      final x2 = (i + 1) * params.candleWidth;

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }

    // Draw zero line if it's within range
    if (0 >= paddedMin && 0 <= paddedMax) {
      final zeroY = params.priceHeight - 
          ((0 - paddedMin) / paddedRange) * params.priceHeight;
      
      canvas.drawLine(
        Offset(0, zeroY),
        Offset(params.chartWidth, zeroY),
        Paint()
          ..color = obvStyle.zeroLineColor
          ..strokeWidth = 1.0,
      );
    }
  }
}

/// Style configuration for OBV indicator.
class OBVStyle extends IndicatorStyle {
  /// The color of the OBV line.
  final Color lineColor;

  /// The width of the OBV line.
  final double lineWidth;

  /// The color of the zero line.
  final Color zeroLineColor;

  const OBVStyle({
    this.lineColor = Colors.cyan,
    this.lineWidth = 2.0,
    this.zeroLineColor = Colors.grey,
  });
}
