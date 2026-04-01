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

  Map<String, dynamic> toJson() => {
    'color': color.value,
    'lineWidth': lineWidth,
    'dashPattern': dashPattern,
    if (labelStyle != null) 'labelStyle': {
      'color': labelStyle!.color?.value,
      'fontSize': labelStyle!.fontSize,
      'fontWeight': labelStyle!.fontWeight?.index,
    },
  };

  factory TrendLineStyle.fromJson(Map<String, dynamic> json) {
    return TrendLineStyle(
      color: json['color'] != null ? Color(json['color'] as int) : const Color(0xFF2196F3),
      lineWidth: (json['lineWidth'] as num?)?.toDouble() ?? 2.0,
      dashPattern: (json['dashPattern'] as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList() ?? const [],
      labelStyle: json['labelStyle'] != null ? TextStyle(
        color: json['labelStyle']['color'] != null ? Color(json['labelStyle']['color'] as int) : null,
        fontSize: (json['labelStyle']['fontSize'] as num?)?.toDouble(),
        fontWeight: json['labelStyle']['fontWeight'] != null ? FontWeight.values[json['labelStyle']['fontWeight'] as int] : null,
      ) : null,
    );
  }

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
