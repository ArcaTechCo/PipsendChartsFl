import 'package:flutter/painting.dart';
import '../candle_data.dart';
import '../painter_params.dart';
import '../common/min_max.dart';
import 'indicator.dart';
import 'indicator_panel.dart';
import 'indicator_value.dart';
import 'calculator/indicator_calculator.dart';

/// RSI (Relative Strength Index) indicator.
///
/// RSI is a momentum oscillator that measures the speed and magnitude
/// of price changes. It oscillates between 0 and 100.
///
/// Typical interpretation:
/// - RSI > 70: Overbought (potential sell signal)
/// - RSI < 30: Oversold (potential buy signal)
///
/// Example:
/// ```dart
/// RSIIndicator(
///   period: 14,
///   panel: IndicatorPanel.separate(height: 0.2),
///   style: RSIStyle(
///     lineColor: Colors.purple,
///     overboughtLevel: 70,
///     oversoldLevel: 30,
///   ),
/// )
/// ```
class RSIIndicator extends Indicator {
  /// The number of periods to use for RSI calculation.
  /// Typical value is 14.
  final int period;

  /// The overbought level (typically 70).
  final double overbought;

  /// The oversold level (typically 30).
  final double oversold;

  RSIIndicator({
    String? id,
    this.period = 14,
    this.overbought = 70,
    this.oversold = 30,
    IndicatorPanel? panel,
    RSIStyle? style,
    bool visible = true,
  }) : super(
          id: id ?? 'rsi_$period',
          panel: panel ?? IndicatorPanel.separate(height: 0.2),
          style: style ?? RSIStyle(),
          visible: visible,
        );

  RSIStyle get rsiStyle => style as RSIStyle;

  @override
  List<IndicatorValue> calculate(List<CandleData> data) {
    final closes = data.map((c) => c.close).toList();
    final rsiValues = IndicatorCalculator.rsi(closes, period);

    return List.generate(data.length, (i) {
      return IndicatorValue(
        timestamp: data[i].timestamp,
        values: {'rsi': rsiValues[i]},
      );
    });
  }

  @override
  void paint(Canvas canvas, PainterParams params, List<IndicatorValue> values) {
    if (!visible || values.isEmpty) return;

    // Get panel rect for this indicator
    final panelRect = _getPanelRect(params);
    if (panelRect == null) return;

    // Draw background zones
    _drawBackgroundZones(canvas, panelRect);

    // Draw reference lines
    _drawReferenceLines(canvas, panelRect);

    // Draw RSI line
    _drawRSILine(canvas, params, values, panelRect);
  }

  Rect? _getPanelRect(PainterParams params) {
    // For now, assume RSI panel is at the bottom
    // In a full implementation, this would come from ChartLayout
    final panelHeight = params.chartHeight * (panel.height ?? 0.2);
    final panelY = params.chartHeight - panelHeight;
    
    return Rect.fromLTWH(0, panelY, params.chartWidth, panelHeight);
  }

  void _drawBackgroundZones(Canvas canvas, Rect panelRect) {
    // Draw overbought zone (70-100)
    final overboughtY = _fitValue(overbought, panelRect);
    final topY = _fitValue(100, panelRect);
    
    canvas.drawRect(
      Rect.fromLTRB(0, topY, panelRect.width, overboughtY),
      Paint()..color = rsiStyle.overboughtColor,
    );

    // Draw oversold zone (0-30)
    final oversoldY = _fitValue(oversold, panelRect);
    final bottomY = _fitValue(0, panelRect);
    
    canvas.drawRect(
      Rect.fromLTRB(0, oversoldY, panelRect.width, bottomY),
      Paint()..color = rsiStyle.oversoldColor,
    );
  }

  void _drawReferenceLines(Canvas canvas, Rect panelRect) {
    final paint = Paint()
      ..color = rsiStyle.referenceLinesColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw lines at 30, 50, 70
    for (final level in [oversold, 50.0, overbought]) {
      final y = _fitValue(level, panelRect);
      canvas.drawLine(
        Offset(0, y),
        Offset(panelRect.width, y),
        paint,
      );
    }
  }

  void _drawRSILine(Canvas canvas, PainterParams params, List<IndicatorValue> values, Rect panelRect) {
    final paint = Paint()
      ..color = rsiStyle.lineColor
      ..strokeWidth = rsiStyle.lineWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    bool hasStarted = false;

    for (int i = 0; i < values.length; i++) {
      final rsi = values[i].getValue('rsi');
      if (rsi == null) {
        hasStarted = false;
        continue;
      }

      final x = i * params.candleWidth;
      final y = _fitValue(rsi, panelRect);

      if (!hasStarted) {
        path.moveTo(x, y);
        hasStarted = true;
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  /// Fits an RSI value (0-100) to the panel's Y coordinate.
  double _fitValue(double value, Rect panelRect) {
    final normalized = (100 - value) / 100; // Invert so 100 is at top
    return panelRect.top + (normalized * panelRect.height);
  }

  @override
  MinMax? calculateMinMax(List<IndicatorValue> values, int startIndex, int endIndex) {
    // RSI always ranges from 0 to 100
    return MinMax(min: 0, max: 100);
  }
}

/// Style configuration for RSI indicator.
class RSIStyle extends IndicatorStyle {
  /// Color of the RSI line.
  final Color lineColor;

  /// Width of the RSI line.
  final double lineWidth;

  /// Color of the overbought zone background.
  final Color overboughtColor;

  /// Color of the oversold zone background.
  final Color oversoldColor;

  /// Color of the reference lines (30, 50, 70).
  final Color referenceLinesColor;

  /// The overbought level to display.
  final double overboughtLevel;

  /// The oversold level to display.
  final double oversoldLevel;

  const RSIStyle({
    this.lineColor = const Color(0xFF9C27B0),
    this.lineWidth = 2.0,
    this.overboughtColor = const Color(0x1AEF5350),
    this.oversoldColor = const Color(0x1A26A69A),
    this.referenceLinesColor = const Color(0x33FFFFFF),
    this.overboughtLevel = 70,
    this.oversoldLevel = 30,
  });

  RSIStyle copyWith({
    Color? lineColor,
    double? lineWidth,
    Color? overboughtColor,
    Color? oversoldColor,
    Color? referenceLinesColor,
    double? overboughtLevel,
    double? oversoldLevel,
  }) {
    return RSIStyle(
      lineColor: lineColor ?? this.lineColor,
      lineWidth: lineWidth ?? this.lineWidth,
      overboughtColor: overboughtColor ?? this.overboughtColor,
      oversoldColor: oversoldColor ?? this.oversoldColor,
      referenceLinesColor: referenceLinesColor ?? this.referenceLinesColor,
      overboughtLevel: overboughtLevel ?? this.overboughtLevel,
      oversoldLevel: oversoldLevel ?? this.oversoldLevel,
    );
  }
}
