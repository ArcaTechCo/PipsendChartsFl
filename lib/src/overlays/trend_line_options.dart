import 'package:flutter/widgets.dart';

/// Options for configuring a trend line overlay.
class TrendLineOptions {
  /// Whether the trend line can be dragged.
  final bool draggable;
  
  /// Whether to extend the line to the right.
  final bool extendRight;
  
  /// Whether to extend the line to the left.
  final bool extendLeft;
  
  /// Whether to show the angle label.
  final bool showAngle;
  
  /// Callback when the trend line is moved.
  /// Parameters: newStartTime, newStartPrice, newEndTime, newEndPrice
  final void Function(int newStartTime, double newStartPrice, int newEndTime, double newEndPrice)? onMoved;
  
  /// Callback when the trend line is deleted.
  final VoidCallback? onDelete;

  const TrendLineOptions({
    this.draggable = true,
    this.extendRight = false,
    this.extendLeft = false,
    this.showAngle = false,
    this.onMoved,
    this.onDelete,
  });

  Map<String, dynamic> toJson() => {
    'draggable': draggable,
    'extendRight': extendRight,
    'extendLeft': extendLeft,
    'showAngle': showAngle,
  };

  factory TrendLineOptions.fromJson(Map<String, dynamic> json) {
    return TrendLineOptions(
      draggable: json['draggable'] as bool? ?? true,
      extendRight: json['extendRight'] as bool? ?? false,
      extendLeft: json['extendLeft'] as bool? ?? false,
      showAngle: json['showAngle'] as bool? ?? false,
    );
  }

  TrendLineOptions copyWith({
    bool? draggable,
    bool? extendRight,
    bool? extendLeft,
    bool? showAngle,
    void Function(int, double, int, double)? onMoved,
    VoidCallback? onDelete,
  }) {
    return TrendLineOptions(
      draggable: draggable ?? this.draggable,
      extendRight: extendRight ?? this.extendRight,
      extendLeft: extendLeft ?? this.extendLeft,
      showAngle: showAngle ?? this.showAngle,
      onMoved: onMoved ?? this.onMoved,
      onDelete: onDelete ?? this.onDelete,
    );
  }
}
