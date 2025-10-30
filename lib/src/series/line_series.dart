import 'dart:math';
import 'package:flutter/painting.dart';
import '../scale/price_scale.dart';
import '../painter_params.dart';
import '../common/min_max.dart';
import 'series.dart';
import 'series_type.dart';
import 'series_data.dart';

/// A series that displays data as a continuous line.
class LineSeries extends Series {
  /// The line data to display.
  final List<LineData> data;

  /// Style configuration for this series.
  final LineStyle style;

  LineSeries({
    required String id,
    required this.data,
    PriceScale? priceScale,
    LineStyle? style,
    bool visible = true,
    int zIndex = 1,
  })  : this.style = style ?? LineStyle(),
        super(
          id: id,
          type: SeriesType.line,
          priceScale: priceScale ?? PriceScale.main(),
          visible: visible,
          zIndex: zIndex,
        );

  @override
  void paint(Canvas canvas, PainterParams params) {
    if (!visible || data.isEmpty) return;

    final paint = Paint()
      ..color = style.color
      ..strokeWidth = style.lineWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    bool hasStarted = false;

    for (int i = 0; i < data.length; i++) {
      final point = data[i];
      if (point.value == null) {
        hasStarted = false;
        continue;
      }

      final x = i * params.candleWidth;
      final y = params.fitPrice(point.value!);

      if (!hasStarted) {
        path.moveTo(x, y);
        hasStarted = true;
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw points if enabled
    if (style.showPoints) {
      _drawPoints(canvas, params);
    }
  }

  void _drawPoints(Canvas canvas, PainterParams params) {
    final paint = Paint()
      ..color = style.pointColor ?? style.color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final point = data[i];
      if (point.value == null) continue;

      final x = i * params.candleWidth;
      final y = params.fitPrice(point.value!);

      canvas.drawCircle(
        Offset(x, y),
        style.pointRadius,
        paint,
      );
    }
  }

  @override
  double? getValueAt(int index) {
    if (index < 0 || index >= data.length) return null;
    return data[index].value;
  }

  @override
  MinMax? calculateMinMax(int startIndex, int endIndex) {
    if (data.isEmpty) return null;

    final start = startIndex.clamp(0, data.length - 1);
    final end = endIndex.clamp(start, data.length);

    double? minValue;
    double? maxValue;

    for (int i = start; i < end; i++) {
      final value = data[i].value;
      if (value == null) continue;

      minValue = minValue == null ? value : min(minValue, value);
      maxValue = maxValue == null ? value : max(maxValue, value);
    }

    if (minValue == null || maxValue == null) return null;

    return MinMax(min: minValue, max: maxValue);
  }

  @override
  int get dataLength => data.length;
}

/// Style configuration for line series.
class LineStyle extends SeriesStyle {
  /// Color of the line.
  final Color color;

  /// Width of the line.
  final double lineWidth;

  /// Whether to show points at data locations.
  final bool showPoints;

  /// Radius of the points (if shown).
  final double pointRadius;

  /// Color of the points (if null, uses line color).
  final Color? pointColor;

  const LineStyle({
    this.color = const Color(0xFF2196F3),
    this.lineWidth = 2.0,
    this.showPoints = false,
    this.pointRadius = 3.0,
    this.pointColor,
  });

  LineStyle copyWith({
    Color? color,
    double? lineWidth,
    bool? showPoints,
    double? pointRadius,
    Color? pointColor,
  }) {
    return LineStyle(
      color: color ?? this.color,
      lineWidth: lineWidth ?? this.lineWidth,
      showPoints: showPoints ?? this.showPoints,
      pointRadius: pointRadius ?? this.pointRadius,
      pointColor: pointColor ?? this.pointColor,
    );
  }
}
