import 'dart:math';
import 'package:flutter/painting.dart';
import '../scale/price_scale.dart';
import '../painter_params.dart';
import '../common/min_max.dart';
import 'series.dart';
import 'series_type.dart';
import 'series_data.dart';

/// A series that displays data as vertical bars (histogram).
///
/// Commonly used for volume data.
class HistogramSeries extends Series {
  /// The histogram data to display.
  final List<HistogramData> data;

  /// Style configuration for this series.
  final HistogramStyle style;

  HistogramSeries({
    required String id,
    required this.data,
    PriceScale? priceScale,
    HistogramStyle? style,
    bool visible = true,
    int zIndex = 0,
  })  : this.style = style ?? HistogramStyle(),
        super(
          id: id,
          type: SeriesType.histogram,
          priceScale: priceScale ?? PriceScale.volume(),
          visible: visible,
          zIndex: zIndex,
        );

  @override
  void paint(Canvas canvas, PainterParams params) {
    if (!visible || data.isEmpty) return;

    for (int i = 0; i < data.length; i++) {
      _paintBar(canvas, params, i);
    }
  }

  void _paintBar(Canvas canvas, PainterParams params, int index) {
    final bar = data[index];
    if (bar.value == null || bar.value == 0) return;

    final x = index * params.candleWidth;
    final barWidth = max(params.candleWidth * style.widthFactor, 0.8);
    
    // Use bar-specific color or default color
    final color = bar.color ?? style.color;

    // For volume, we need to fit it in the volume area
    // This assumes params has a fitVolume method
    final baseY = params.chartHeight;
    final valueY = params.fitVolume(bar.value!);

    canvas.drawLine(
      Offset(x, baseY),
      Offset(x, valueY),
      Paint()
        ..strokeWidth = barWidth
        ..color = color,
    );
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

/// Style configuration for histogram series.
class HistogramStyle extends SeriesStyle {
  /// Default color for bars.
  final Color color;

  /// Width factor for bars (0.0 to 1.0).
  final double widthFactor;

  const HistogramStyle({
    this.color = const Color(0xFF757575),
    this.widthFactor = 0.8,
  });

  HistogramStyle copyWith({
    Color? color,
    double? widthFactor,
  }) {
    return HistogramStyle(
      color: color ?? this.color,
      widthFactor: widthFactor ?? this.widthFactor,
    );
  }
}
