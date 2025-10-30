import 'dart:math';
import 'package:flutter/painting.dart';
import '../candle_data.dart';
import '../painter_params.dart';
import '../common/min_max.dart';
import 'indicator.dart';
import 'indicator_panel.dart';
import 'indicator_value.dart';
import 'calculator/indicator_calculator.dart';

/// MACD (Moving Average Convergence Divergence) indicator.
///
/// MACD consists of three components:
/// - MACD Line: Difference between fast EMA and slow EMA
/// - Signal Line: EMA of the MACD line
/// - Histogram: Difference between MACD line and signal line
///
/// Trading signals:
/// - MACD crosses above signal: Bullish signal
/// - MACD crosses below signal: Bearish signal
/// - Histogram above zero: Bullish momentum
/// - Histogram below zero: Bearish momentum
///
/// Example:
/// ```dart
/// MACDIndicator(
///   fastPeriod: 12,
///   slowPeriod: 26,
///   signalPeriod: 9,
///   panel: IndicatorPanel.separate(height: 0.25),
///   style: MACDStyle(
///     macdLineColor: Colors.blue,
///     signalLineColor: Colors.orange,
///   ),
/// )
/// ```
class MACDIndicator extends Indicator {
  /// The fast EMA period (typically 12).
  final int fastPeriod;

  /// The slow EMA period (typically 26).
  final int slowPeriod;

  /// The signal line EMA period (typically 9).
  final int signalPeriod;

  MACDIndicator({
    String? id,
    this.fastPeriod = 12,
    this.slowPeriod = 26,
    this.signalPeriod = 9,
    IndicatorPanel? panel,
    MACDStyle? style,
    bool visible = true,
  }) : super(
          id: id ?? 'macd',
          panel: panel ?? IndicatorPanel.separate(height: 0.25),
          style: style ?? MACDStyle(),
          visible: visible,
        );

  MACDStyle get macdStyle => style as MACDStyle;

  @override
  List<IndicatorValue> calculate(List<CandleData> data) {
    final closes = data.map((c) => c.close).toList();
    final macdData = IndicatorCalculator.macd(
      closes,
      fastPeriod,
      slowPeriod,
      signalPeriod,
    );

    return List.generate(data.length, (i) {
      return IndicatorValue(
        timestamp: data[i].timestamp,
        values: {
          'macd': macdData['macd']![i],
          'signal': macdData['signal']![i],
          'histogram': macdData['histogram']![i],
        },
      );
    });
  }

  @override
  void paint(Canvas canvas, PainterParams params, List<IndicatorValue> values) {
    if (!visible || values.isEmpty) return;

    // Get panel rect for this indicator
    final panelRect = _getPanelRect(params);
    if (panelRect == null) return;

    // Calculate min/max for scaling
    final minMax = calculateMinMax(values, 0, values.length);
    if (minMax == null) return;

    // Draw zero line
    _drawZeroLine(canvas, panelRect, minMax);

    // Draw histogram first (behind the lines)
    _drawHistogram(canvas, params, values, panelRect, minMax);

    // Draw MACD and signal lines
    _drawLine(canvas, params, values, 'macd', panelRect, minMax, 
              macdStyle.macdLineColor, macdStyle.macdLineWidth);
    _drawLine(canvas, params, values, 'signal', panelRect, minMax,
              macdStyle.signalLineColor, macdStyle.signalLineWidth);
  }

  Rect? _getPanelRect(PainterParams params) {
    // For now, assume MACD panel is at the bottom
    // In a full implementation, this would come from ChartLayout
    final panelHeight = params.chartHeight * (panel.height ?? 0.25);
    final panelY = params.chartHeight - panelHeight;
    
    return Rect.fromLTWH(0, panelY, params.chartWidth, panelHeight);
  }

  void _drawZeroLine(Canvas canvas, Rect panelRect, MinMax minMax) {
    final y = _fitValue(0, panelRect, minMax);
    
    canvas.drawLine(
      Offset(0, y),
      Offset(panelRect.width, y),
      Paint()
        ..color = macdStyle.zeroLineColor
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawHistogram(
    Canvas canvas,
    PainterParams params,
    List<IndicatorValue> values,
    Rect panelRect,
    MinMax minMax,
  ) {
    final zeroY = _fitValue(0, panelRect, minMax);

    for (int i = 0; i < values.length; i++) {
      final histogram = values[i].getValue('histogram');
      if (histogram == null || histogram == 0) continue;

      final x = i * params.candleWidth;
      final y = _fitValue(histogram, panelRect, minMax);
      final barWidth = max(params.candleWidth * 0.8, 0.8);

      final color = histogram > 0
          ? macdStyle.histogramPositiveColor
          : macdStyle.histogramNegativeColor;

      canvas.drawLine(
        Offset(x, zeroY),
        Offset(x, y),
        Paint()
          ..strokeWidth = barWidth
          ..color = color,
      );
    }
  }

  void _drawLine(
    Canvas canvas,
    PainterParams params,
    List<IndicatorValue> values,
    String lineName,
    Rect panelRect,
    MinMax minMax,
    Color color,
    double width,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    bool hasStarted = false;

    for (int i = 0; i < values.length; i++) {
      final value = values[i].getValue(lineName);
      if (value == null) {
        hasStarted = false;
        continue;
      }

      final x = i * params.candleWidth;
      final y = _fitValue(value, panelRect, minMax);

      if (!hasStarted) {
        path.moveTo(x, y);
        hasStarted = true;
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  /// Fits a MACD value to the panel's Y coordinate.
  double _fitValue(double value, Rect panelRect, MinMax minMax) {
    final range = minMax.max - minMax.min;
    if (range == 0) return panelRect.center.dy;
    
    final normalized = (minMax.max - value) / range;
    return panelRect.top + (normalized * panelRect.height);
  }
}

/// Style configuration for MACD indicator.
class MACDStyle extends IndicatorStyle {
  /// Color of the MACD line.
  final Color macdLineColor;

  /// Width of the MACD line.
  final double macdLineWidth;

  /// Color of the signal line.
  final Color signalLineColor;

  /// Width of the signal line.
  final double signalLineWidth;

  /// Color of positive histogram bars.
  final Color histogramPositiveColor;

  /// Color of negative histogram bars.
  final Color histogramNegativeColor;

  /// Color of the zero line.
  final Color zeroLineColor;

  const MACDStyle({
    this.macdLineColor = const Color(0xFF2196F3),
    this.macdLineWidth = 2.0,
    this.signalLineColor = const Color(0xFFFF9800),
    this.signalLineWidth = 2.0,
    this.histogramPositiveColor = const Color(0xFF26A69A),
    this.histogramNegativeColor = const Color(0xFFEF5350),
    this.zeroLineColor = const Color(0x33FFFFFF),
  });

  MACDStyle copyWith({
    Color? macdLineColor,
    double? macdLineWidth,
    Color? signalLineColor,
    double? signalLineWidth,
    Color? histogramPositiveColor,
    Color? histogramNegativeColor,
    Color? zeroLineColor,
  }) {
    return MACDStyle(
      macdLineColor: macdLineColor ?? this.macdLineColor,
      macdLineWidth: macdLineWidth ?? this.macdLineWidth,
      signalLineColor: signalLineColor ?? this.signalLineColor,
      signalLineWidth: signalLineWidth ?? this.signalLineWidth,
      histogramPositiveColor: histogramPositiveColor ?? this.histogramPositiveColor,
      histogramNegativeColor: histogramNegativeColor ?? this.histogramNegativeColor,
      zeroLineColor: zeroLineColor ?? this.zeroLineColor,
    );
  }
}
