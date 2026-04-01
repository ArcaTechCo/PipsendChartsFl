import 'package:flutter/widgets.dart';

/// Visual style for a Fibonacci retracement overlay.
class FibonacciStyle {
  /// Color for the 0% level line.
  final Color level0Color;
  
  /// Color for the 23.6% level line.
  final Color level236Color;
  
  /// Color for the 38.2% level line.
  final Color level382Color;
  
  /// Color for the 50% level line.
  final Color level50Color;
  
  /// Color for the 61.8% level line (golden ratio).
  final Color level618Color;
  
  /// Color for the 78.6% level line.
  final Color level786Color;
  
  /// Color for the 100% level line.
  final Color level100Color;
  
  /// Width of the level lines.
  final double lineWidth;
  
  /// Text style for labels.
  final TextStyle? labelStyle;

  const FibonacciStyle({
    this.level0Color = const Color(0xFFE57373),
    this.level236Color = const Color(0xFFFFB74D),
    this.level382Color = const Color(0xFFFFF176),
    this.level50Color = const Color(0xFF81C784),
    this.level618Color = const Color(0xFF4FC3F7),
    this.level786Color = const Color(0xFF9575CD),
    this.level100Color = const Color(0xFFE57373),
    this.lineWidth = 1.0,
    this.labelStyle,
  });

  /// Gets the color for a specific Fibonacci level.
  Color getColorForLevel(double level) {
    if (level == 0.0) return level0Color;
    if (level == 0.236) return level236Color;
    if (level == 0.382) return level382Color;
    if (level == 0.5) return level50Color;
    if (level == 0.618) return level618Color;
    if (level == 0.786) return level786Color;
    if (level == 1.0) return level100Color;
    return level50Color; // Default
  }

  Map<String, dynamic> toJson() => {
    'level0Color': level0Color.value,
    'level236Color': level236Color.value,
    'level382Color': level382Color.value,
    'level50Color': level50Color.value,
    'level618Color': level618Color.value,
    'level786Color': level786Color.value,
    'level100Color': level100Color.value,
    'lineWidth': lineWidth,
    if (labelStyle != null) 'labelStyle': {
      'color': labelStyle!.color?.value,
      'fontSize': labelStyle!.fontSize,
      'fontWeight': labelStyle!.fontWeight?.index,
    },
  };

  factory FibonacciStyle.fromJson(Map<String, dynamic> json) {
    return FibonacciStyle(
      level0Color: Color(json['level0Color'] as int),
      level236Color: Color(json['level236Color'] as int),
      level382Color: Color(json['level382Color'] as int),
      level50Color: Color(json['level50Color'] as int),
      level618Color: Color(json['level618Color'] as int),
      level786Color: Color(json['level786Color'] as int),
      level100Color: Color(json['level100Color'] as int),
      lineWidth: (json['lineWidth'] as num?)?.toDouble() ?? 1.0,
      labelStyle: json['labelStyle'] != null ? TextStyle(
        color: json['labelStyle']['color'] != null ? Color(json['labelStyle']['color'] as int) : null,
        fontSize: (json['labelStyle']['fontSize'] as num?)?.toDouble(),
        fontWeight: json['labelStyle']['fontWeight'] != null ? FontWeight.values[json['labelStyle']['fontWeight'] as int] : null,
      ) : null,
    );
  }

  FibonacciStyle copyWith({
    Color? level0Color,
    Color? level236Color,
    Color? level382Color,
    Color? level50Color,
    Color? level618Color,
    Color? level786Color,
    Color? level100Color,
    double? lineWidth,
    TextStyle? labelStyle,
  }) {
    return FibonacciStyle(
      level0Color: level0Color ?? this.level0Color,
      level236Color: level236Color ?? this.level236Color,
      level382Color: level382Color ?? this.level382Color,
      level50Color: level50Color ?? this.level50Color,
      level618Color: level618Color ?? this.level618Color,
      level786Color: level786Color ?? this.level786Color,
      level100Color: level100Color ?? this.level100Color,
      lineWidth: lineWidth ?? this.lineWidth,
      labelStyle: labelStyle ?? this.labelStyle,
    );
  }
}
