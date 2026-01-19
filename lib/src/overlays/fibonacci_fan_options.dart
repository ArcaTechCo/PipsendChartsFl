import 'package:flutter/widgets.dart';

/// Options for configuring a Fibonacci Fan overlay.
class FibonacciFanOptions {
  /// Whether the Fibonacci Fan can be dragged.
  final bool draggable;
  
  /// Whether to show labels for each level.
  final bool showLabels;
  
  /// Callback when a point is moved.
  /// Parameters: startTime, startPrice, endTime, endPrice
  final void Function(
    int startTime,
    double startPrice,
    int endTime,
    double endPrice,
  )? onMoved;
  
  /// Callback when the Fibonacci Fan is deleted.
  final VoidCallback? onDelete;

  const FibonacciFanOptions({
    this.draggable = true,
    this.showLabels = true,
    this.onMoved,
    this.onDelete,
  });

  FibonacciFanOptions copyWith({
    bool? draggable,
    bool? showLabels,
    void Function(int, double, int, double)? onMoved,
    VoidCallback? onDelete,
  }) {
    return FibonacciFanOptions(
      draggable: draggable ?? this.draggable,
      showLabels: showLabels ?? this.showLabels,
      onMoved: onMoved ?? this.onMoved,
      onDelete: onDelete ?? this.onDelete,
    );
  }
}
