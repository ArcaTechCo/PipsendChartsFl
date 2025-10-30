import 'package:flutter/painting.dart';
import '../candle_data.dart';
import '../painter_params.dart';
import '../common/min_max.dart';
import 'indicator.dart';
import 'indicator_panel.dart';
import 'indicator_value.dart';
import 'calculator/indicator_calculator.dart';

/// Bollinger Bands indicator.
///
/// Bollinger Bands consist of three lines:
/// - Middle band: Simple Moving Average (SMA)
/// - Upper band: SMA + (standard deviation × multiplier)
/// - Lower band: SMA - (standard deviation × multiplier)
///
/// The bands expand and contract based on market volatility.
/// Price touching the upper band may indicate overbought conditions,
/// while touching the lower band may indicate oversold conditions.
///
/// Example:
/// ```dart
/// BollingerBandsIndicator(
///   period: 20,
///   stdDev: 2.0,
///   panel: IndicatorPanel.overlay(),
///   style: BollingerBandsStyle(
///     upperBandColor: Colors.red,
///     middleBandColor: Colors.blue,
///     lowerBandColor: Colors.green,
///   ),
/// )
/// ```
class BollingerBandsIndicator extends Indicator {
  /// The number of periods for the moving average.
  /// Typical value is 20.
  final int period;

  /// The number of standard deviations for the bands.
  /// Typical value is 2.0.
  final double stdDev;

  BollingerBandsIndicator({
    String? id,
    this.period = 20,
    this.stdDev = 2.0,
    IndicatorPanel? panel,
    BollingerBandsStyle? style,
    bool visible = true,
  }) : super(
          id: id ?? 'bb_$period',
          panel: panel ?? IndicatorPanel.overlay(),
          style: style ?? BollingerBandsStyle(),
          visible: visible,
        );

  BollingerBandsStyle get bbStyle => style as BollingerBandsStyle;

  @override
  List<IndicatorValue> calculate(List<CandleData> data) {
    final closes = data.map((c) => c.close).toList();
    final bands = IndicatorCalculator.bollingerBands(closes, period, stdDev);

    return List.generate(data.length, (i) {
      return IndicatorValue(
        timestamp: data[i].timestamp,
        values: {
          'upper': bands['upper']![i],
          'middle': bands['middle']![i],
          'lower': bands['lower']![i],
        },
      );
    });
  }

  @override
  void paint(Canvas canvas, PainterParams params, List<IndicatorValue> values) {
    if (!visible || values.isEmpty) return;

    // Draw fill between bands first (if enabled)
    if (bbStyle.fillBands) {
      _drawFill(canvas, params, values);
    }

    // Draw the three bands
    _drawBand(canvas, params, values, 'upper', bbStyle.upperBandColor, bbStyle.upperBandWidth);
    _drawBand(canvas, params, values, 'middle', bbStyle.middleBandColor, bbStyle.middleBandWidth);
    _drawBand(canvas, params, values, 'lower', bbStyle.lowerBandColor, bbStyle.lowerBandWidth);
  }

  void _drawFill(Canvas canvas, PainterParams params, List<IndicatorValue> values) {
    final path = Path();
    bool hasStarted = false;

    // Draw upper band path
    for (int i = 0; i < values.length; i++) {
      final upper = values[i].getValue('upper');
      if (upper == null) continue;

      final x = i * params.candleWidth;
      final y = params.fitPrice(upper);

      if (!hasStarted) {
        path.moveTo(x, y);
        hasStarted = true;
      } else {
        path.lineTo(x, y);
      }
    }

    // Draw lower band path in reverse
    for (int i = values.length - 1; i >= 0; i--) {
      final lower = values[i].getValue('lower');
      if (lower == null) continue;

      final x = i * params.candleWidth;
      final y = params.fitPrice(lower);
      path.lineTo(x, y);
    }

    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..color = bbStyle.fillColor
        ..style = PaintingStyle.fill,
    );
  }

  void _drawBand(
    Canvas canvas,
    PainterParams params,
    List<IndicatorValue> values,
    String bandName,
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
      final value = values[i].getValue(bandName);
      if (value == null) {
        hasStarted = false;
        continue;
      }

      final x = i * params.candleWidth;
      final y = params.fitPrice(value);

      if (!hasStarted) {
        path.moveTo(x, y);
        hasStarted = true;
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  MinMax? calculateMinMax(List<IndicatorValue> values, int startIndex, int endIndex) {
    // Bollinger Bands overlay on the main chart, so return null
    // to use the main chart's min/max
    return null;
  }
}

/// Style configuration for Bollinger Bands indicator.
class BollingerBandsStyle extends IndicatorStyle {
  /// Color of the upper band.
  final Color upperBandColor;

  /// Width of the upper band line.
  final double upperBandWidth;

  /// Color of the middle band (SMA).
  final Color middleBandColor;

  /// Width of the middle band line.
  final double middleBandWidth;

  /// Color of the lower band.
  final Color lowerBandColor;

  /// Width of the lower band line.
  final double lowerBandWidth;

  /// Whether to fill the area between bands.
  final bool fillBands;

  /// Color of the fill between bands.
  final Color fillColor;

  const BollingerBandsStyle({
    this.upperBandColor = const Color(0xFFEF5350),
    this.upperBandWidth = 1.5,
    this.middleBandColor = const Color(0xFF2196F3),
    this.middleBandWidth = 1.5,
    this.lowerBandColor = const Color(0xFF26A69A),
    this.lowerBandWidth = 1.5,
    this.fillBands = true,
    this.fillColor = const Color(0x1A2196F3),
  });

  BollingerBandsStyle copyWith({
    Color? upperBandColor,
    double? upperBandWidth,
    Color? middleBandColor,
    double? middleBandWidth,
    Color? lowerBandColor,
    double? lowerBandWidth,
    bool? fillBands,
    Color? fillColor,
  }) {
    return BollingerBandsStyle(
      upperBandColor: upperBandColor ?? this.upperBandColor,
      upperBandWidth: upperBandWidth ?? this.upperBandWidth,
      middleBandColor: middleBandColor ?? this.middleBandColor,
      middleBandWidth: middleBandWidth ?? this.middleBandWidth,
      lowerBandColor: lowerBandColor ?? this.lowerBandColor,
      lowerBandWidth: lowerBandWidth ?? this.lowerBandWidth,
      fillBands: fillBands ?? this.fillBands,
      fillColor: fillColor ?? this.fillColor,
    );
  }
}
