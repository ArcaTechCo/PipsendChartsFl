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

  /// Horizontal padding for the label.
  final double labelHorizontalPadding;

  /// Vertical padding (gap between label and line).
  final double labelVerticalPadding;

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
    this.lineWidth = 1.0,
    this.dashPattern,
    this.labelColor,
    this.labelFontSize = 10,
    this.labelHorizontalPadding = 2,
    this.labelVerticalPadding = 1,
    this.labelBackgroundColor,
    this.priceColor,
    this.priceFontSize = 10,
    this.priceBackgroundColor,
  });

  /// Creates a style from a trading line type with default values.
  factory TradingLineStyle.fromType(TradingLineType type) {
    final color = type.defaultColor;
    return TradingLineStyle(
      color: color,
      lineWidth: type == TradingLineType.stopLoss ? 1.5 : 1.0,
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
    double? labelHorizontalPadding,
    double? labelVerticalPadding,
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
      labelHorizontalPadding: labelHorizontalPadding ?? this.labelHorizontalPadding,
      labelVerticalPadding: labelVerticalPadding ?? this.labelVerticalPadding,
      labelBackgroundColor: labelBackgroundColor ?? this.labelBackgroundColor,
      priceColor: priceColor ?? this.priceColor,
      priceFontSize: priceFontSize ?? this.priceFontSize,
      priceBackgroundColor: priceBackgroundColor ?? this.priceBackgroundColor,
    );
  }

  Map<String, dynamic> toJson() => {
    'color': color.value,
    'lineWidth': lineWidth,
    if (dashPattern != null) 'dashPattern': dashPattern,
    if (labelColor != null) 'labelColor': labelColor!.value,
    'labelFontSize': labelFontSize,
    'labelHorizontalPadding': labelHorizontalPadding,
    'labelVerticalPadding': labelVerticalPadding,
    if (labelBackgroundColor != null) 'labelBackgroundColor': labelBackgroundColor!.value,
    if (priceColor != null) 'priceColor': priceColor!.value,
    'priceFontSize': priceFontSize,
    if (priceBackgroundColor != null) 'priceBackgroundColor': priceBackgroundColor!.value,
  };

  factory TradingLineStyle.fromJson(Map<String, dynamic> json) {
    return TradingLineStyle(
      color: Color(json['color'] as int),
      lineWidth: (json['lineWidth'] as num?)?.toDouble() ?? 1.0,
      dashPattern: (json['dashPattern'] as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList(),
      labelColor: json['labelColor'] != null ? Color(json['labelColor'] as int) : null,
      labelFontSize: (json['labelFontSize'] as num?)?.toDouble() ?? 10,
      labelHorizontalPadding: (json['labelHorizontalPadding'] as num?)?.toDouble() ?? 2,
      labelVerticalPadding: (json['labelVerticalPadding'] as num?)?.toDouble() ?? 1,
      labelBackgroundColor: json['labelBackgroundColor'] != null ? Color(json['labelBackgroundColor'] as int) : null,
      priceColor: json['priceColor'] != null ? Color(json['priceColor'] as int) : null,
      priceFontSize: (json['priceFontSize'] as num?)?.toDouble() ?? 10,
      priceBackgroundColor: json['priceBackgroundColor'] != null ? Color(json['priceBackgroundColor'] as int) : null,
    );
  }
}
