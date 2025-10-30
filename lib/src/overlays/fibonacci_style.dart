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
