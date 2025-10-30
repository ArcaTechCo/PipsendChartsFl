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
