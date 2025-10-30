import 'package:flutter/painting.dart';
import 'trading_line_type.dart';

/// Style configuration for trading lines.
class TradingLineStyle {
  /// Color of the line.
  final Color color;

  /// Width of the line.
  final double lineWidth;

  /// Dash pattern for the line (null for solid line).
  /// Example: [5, 5] creates a dashed line with 5px dashes and 5px gaps.
  final List<double>? dashPattern;

  /// Color of the label text.
  final Color? labelColor;

  /// Font size of the label.
  final double labelFontSize;

  /// Background color of the label.
  final Color? labelBackgroundColor;

  /// Color of the price text.
  final Color? priceColor;

  /// Font size of the price.
  final double priceFontSize;

  /// Background color of the price.
  final Color? priceBackgroundColor;

  const TradingLineStyle({
    required this.color,
    this.lineWidth = 1.5,
    this.dashPattern,
    this.labelColor,
    this.labelFontSize = 12,
    this.labelBackgroundColor,
    this.priceColor,
    this.priceFontSize = 11,
    this.priceBackgroundColor,
  });

  /// Creates a style from a trading line type with default values.
  factory TradingLineStyle.fromType(TradingLineType type) {
    final color = type.defaultColor;
    return TradingLineStyle(
      color: color,
      lineWidth: type == TradingLineType.stopLoss ? 2.0 : 1.5,
      dashPattern: type.isDashedByDefault ? [5, 5] : null,
      labelBackgroundColor: color.withOpacity(0.8),
      priceBackgroundColor: color,
    );
  }

  /// Creates a solid line style.
  factory TradingLineStyle.solid(Color color, {double lineWidth = 1.5}) {
    return TradingLineStyle(
      color: color,
      lineWidth: lineWidth,
    );
  }

  /// Creates a dashed line style.
  factory TradingLineStyle.dashed(
    Color color, {
    double lineWidth = 1.5,
    List<double>? dashPattern,
  }) {
    return TradingLineStyle(
      color: color,
      lineWidth: lineWidth,
      dashPattern: dashPattern ?? [5, 5],
    );
  }

  /// Creates a dotted line style.
  factory TradingLineStyle.dotted(Color color, {double lineWidth = 1.5}) {
    return TradingLineStyle(
      color: color,
      lineWidth: lineWidth,
      dashPattern: [2, 3],
    );
  }

  /// Creates a copy with modified properties.
  TradingLineStyle copyWith({
    Color? color,
    double? lineWidth,
    List<double>? dashPattern,
    Color? labelColor,
    double? labelFontSize,
    Color? labelBackgroundColor,
    Color? priceColor,
    double? priceFontSize,
    Color? priceBackgroundColor,
  }) {
    return TradingLineStyle(
      color: color ?? this.color,
      lineWidth: lineWidth ?? this.lineWidth,
      dashPattern: dashPattern ?? this.dashPattern,
      labelColor: labelColor ?? this.labelColor,
      labelFontSize: labelFontSize ?? this.labelFontSize,
      labelBackgroundColor: labelBackgroundColor ?? this.labelBackgroundColor,
      priceColor: priceColor ?? this.priceColor,
      priceFontSize: priceFontSize ?? this.priceFontSize,
      priceBackgroundColor: priceBackgroundColor ?? this.priceBackgroundColor,
    );
  }
}
