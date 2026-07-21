import 'package:flutter/material.dart';
import '../candle_data.dart';
import '../painter_params.dart';
import 'indicator.dart';
import 'indicator_panel.dart';
import 'indicator_value.dart';

/// Bill Williams Fractals indicator.
///
/// Marks swing highs and lows using the classic 5-bar pattern: a bar
/// whose `high` is greater than the two bars on each side is an up
/// fractal; a bar whose `low` is lower than the two bars on each side
/// is a down fractal. Up fractals are drawn as an up triangle above the
/// bar, down fractals as a down triangle below the bar.
class FractalsIndicator extends Indicator {
  FractalsIndicator({
    String? id,
    IndicatorPanel? panel,
    FractalsStyle? style,
    bool visible = true,
  }) : super(
          id: id ?? 'fractals',
          panel: panel ?? IndicatorPanel.overlay(),
          style: style ?? const FractalsStyle(),
          visible: visible,
        );

  @override
  List<IndicatorValue> calculate(List<CandleData> data) {
    final result = <IndicatorValue>[];
    for (int i = 2; i < data.length - 2; i++) {
      final high = data[i].high;
      final low = data[i].low;
      final hL2 = data[i - 2].high, hL1 = data[i - 1].high;
      final hR1 = data[i + 1].high, hR2 = data[i + 2].high;
      final lL2 = data[i - 2].low, lL1 = data[i - 1].low;
      final lR1 = data[i + 1].low, lR2 = data[i + 2].low;

      double? up;
      double? down;

      if (high != null &&
          hL2 != null &&
          hL1 != null &&
          hR1 != null &&
          hR2 != null &&
          high > hL1 &&
          high > hL2 &&
          high > hR1 &&
          high > hR2) {
        up = high;
      }

      if (low != null &&
          lL2 != null &&
          lL1 != null &&
          lR1 != null &&
          lR2 != null &&
          low < lL1 &&
          low < lL2 &&
          low < lR1 &&
          low < lR2) {
        down = low;
      }

      if (up != null || down != null) {
        result.add(IndicatorValue(
          timestamp: data[i].timestamp,
          values: {
            if (up != null) 'up': up,
            if (down != null) 'down': down,
          },
        ));
      }
    }
    return result;
  }

  @override
  void paint(Canvas canvas, PainterParams params, List<IndicatorValue> values) {
    if (!visible || values.isEmpty) return;
    final s = style as FractalsStyle;

    for (final value in values) {
      final index =
          params.candles.indexWhere((c) => c.timestamp == value.timestamp);
      if (index < 0) continue;
      final x = index * params.candleWidth;

      final up = value.values['up'];
      if (up != null) {
        _paintMarker(canvas, x, params.fitPrice(up), s, pointsUp: true);
      }
      final down = value.values['down'];
      if (down != null) {
        _paintMarker(canvas, x, params.fitPrice(down), s, pointsUp: false);
      }
    }
  }

  void _paintMarker(
    Canvas canvas,
    double x,
    double priceY,
    FractalsStyle s, {
    required bool pointsUp,
  }) {
    final paint = Paint()
      ..color = pointsUp ? s.upColor : s.downColor
      ..style = PaintingStyle.fill;

    final path = Path();
    if (pointsUp) {
      final baseY = priceY - s.markerGap;
      final apexY = baseY - s.markerSize * 1.6;
      path.moveTo(x, apexY);
      path.lineTo(x - s.markerSize, baseY);
      path.lineTo(x + s.markerSize, baseY);
    } else {
      final baseY = priceY + s.markerGap;
      final apexY = baseY + s.markerSize * 1.6;
      path.moveTo(x, apexY);
      path.lineTo(x - s.markerSize, baseY);
      path.lineTo(x + s.markerSize, baseY);
    }
    path.close();
    canvas.drawPath(path, paint);
  }
}

/// Style configuration for the Fractals indicator.
class FractalsStyle extends IndicatorStyle {
  /// Color of up-fractal (swing high) markers.
  final Color upColor;

  /// Color of down-fractal (swing low) markers.
  final Color downColor;

  /// Half-width (and base size) of the triangle marker in pixels.
  final double markerSize;

  /// Gap in pixels between the bar's high/low and the marker.
  final double markerGap;

  const FractalsStyle({
    this.upColor = const Color(0xFF26A69A),
    this.downColor = const Color(0xFFEF5350),
    this.markerSize = 6.0,
    this.markerGap = 6.0,
  });
}
