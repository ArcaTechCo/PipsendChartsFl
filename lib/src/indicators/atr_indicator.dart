import 'dart:math';
import 'package:flutter/material.dart';
import '../candle_data.dart';
import '../painter_params.dart';
import 'indicator.dart';
import 'indicator_panel.dart';
import 'indicator_value.dart';

/// ATR (Average True Range) indicator.
///
/// ATR measures market volatility by calculating the average of true ranges
/// over a specified period. It doesn't indicate price direction, only volatility.
///
/// True Range is the greatest of:
/// - Current High - Current Low
/// - |Current High - Previous Close|
/// - |Current Low - Previous Close|
///
/// Higher ATR values indicate higher volatility.
/// Lower ATR values indicate lower volatility.
///
/// Example:
/// ```dart
/// ATRIndicator(
///   period: 14,
///   panel: IndicatorPanel.separate(height: 0.15),
///   style: ATRStyle(
///     lineColor: Colors.orange,
///     lineWidth: 2.0,
///   ),
/// )
/// ```
class ATRIndicator extends Indicator {
  /// The number of periods for ATR calculation (typically 14).
  final int period;

  ATRIndicator({
    String? id,
    this.period = 14,
    IndicatorPanel? panel,
    ATRStyle? style,
    bool visible = true,
  }) : super(
          id: id ?? 'atr_$period',
          panel: panel ?? IndicatorPanel.separate(height: 0.15),
          style: style ?? const ATRStyle(),
          visible: visible,
        );

  @override
  List<IndicatorValue> calculate(List<CandleData> data) {
    final result = <IndicatorValue>[];
    final trueRanges = <double>[];

    for (int i = 0; i < data.length; i++) {
      final candle = data[i];
      final high = candle.high;
      final low = candle.low;
      final close = candle.close;

      if (high == null || low == null || close == null) {
        result.add(IndicatorValue(
          values: {'atr': null},
          timestamp: candle.timestamp,
        ));
        trueRanges.add(0);
        continue;
      }

      double trueRange;
      if (i == 0) {
        // First candle: TR = High - Low
        trueRange = high - low;
      } else {
        final prevClose = data[i - 1].close;
        if (prevClose == null) {
          trueRange = high - low;
        } else {
          // TR = max(High-Low, |High-PrevClose|, |Low-PrevClose|)
          trueRange = max(
            high - low,
            max(
              (high - prevClose).abs(),
              (low - prevClose).abs(),
            ),
          );
        }
      }

      trueRanges.add(trueRange);

      if (i < period - 1) {
        result.add(IndicatorValue(
          values: {'atr': null},
          timestamp: candle.timestamp,
        ));
        continue;
      }

      double atr;
      if (i == period - 1) {
        // First ATR: Simple average of true ranges
        atr = trueRanges.sublist(0, period).reduce((a, b) => a + b) / period;
      } else {
        // Subsequent ATR: Smoothed average
        // ATR = ((Previous ATR * (period - 1)) + Current TR) / period
        final prevATR = result[i - 1].values['atr'];
        if (prevATR != null) {
          atr = ((prevATR * (period - 1)) + trueRange) / period;
        } else {
          atr = trueRanges.sublist(i - period + 1, i + 1).reduce((a, b) => a + b) / period;
        }
      }

      result.add(IndicatorValue(
        values: {'atr': atr},
        timestamp: candle.timestamp,
      ));
    }

    return result;
  }

  @override
  void paint(Canvas canvas, PainterParams params, List<IndicatorValue> values) {
    if (!visible) return;
    if (values.isEmpty) return;

    final atrStyle = style as ATRStyle;
    final paint = Paint()
      ..color = atrStyle.lineColor
      ..strokeWidth = atrStyle.lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Find min/max for scaling
    double? minATR;
    double? maxATR;
    for (final value in values) {
      final atr = value.values['atr'];
      if (atr != null) {
        minATR = minATR == null ? atr : min(minATR, atr);
        maxATR = maxATR == null ? atr : max(maxATR, atr);
      }
    }

    if (minATR == null || maxATR == null) return;

    // Add some padding
    final range = maxATR - minATR;
    final paddedMin = minATR - (range * 0.1);
    final paddedMax = maxATR + (range * 0.1);

    // Draw the ATR line
    for (int i = 0; i < values.length - 1; i++) {
      final currentATR = values[i].values['atr'];
      final nextATR = values[i + 1].values['atr'];

      if (currentATR == null || nextATR == null) continue;

      // Scale to chart height
      final y1 = params.priceHeight - 
          ((currentATR - paddedMin) / (paddedMax - paddedMin)) * params.priceHeight;
      final y2 = params.priceHeight - 
          ((nextATR - paddedMin) / (paddedMax - paddedMin)) * params.priceHeight;

      final x1 = i * params.candleWidth;
      final x2 = (i + 1) * params.candleWidth;

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }
}

/// Style configuration for ATR indicator.
class ATRStyle extends IndicatorStyle {
  /// The color of the ATR line.
  final Color lineColor;

  /// The width of the ATR line.
  final double lineWidth;

  const ATRStyle({
    this.lineColor = Colors.orange,
    this.lineWidth = 2.0,
  });
}
