import 'package:flutter/widgets.dart';

/// Visual style for a trend line overlay.
class TrendLineStyle {
  /// Color of the trend line.
  final Color color;
  
  /// Width of the trend line.
  final double lineWidth;
  
  /// Dash pattern for the line (empty for solid line).
  final List<double> dashPattern;
  
  /// Text style for the angle label.
  final TextStyle? labelStyle;

  const TrendLineStyle({
    this.color = const Color(0xFF2196F3),
    this.lineWidth = 2.0,
    this.dashPattern = const [],
    this.labelStyle,
  });

  TrendLineStyle copyWith({
    Color? color,
    double? lineWidth,
    List<double>? dashPattern,
    TextStyle? labelStyle,
  }) {
    return TrendLineStyle(
      color: color ?? this.color,
      lineWidth: lineWidth ?? this.lineWidth,
      dashPattern: dashPattern ?? this.dashPattern,
      labelStyle: labelStyle ?? this.labelStyle,
    );
  }
}
