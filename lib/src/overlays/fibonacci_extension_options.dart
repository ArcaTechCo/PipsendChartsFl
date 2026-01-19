import 'package:flutter/widgets.dart';

/// Options for configuring a Fibonacci Extension overlay.
class FibonacciExtensionOptions {
  /// Whether the Fibonacci Extension can be dragged.
  final bool draggable;
  
  /// Whether to show labels for each level.
  final bool showLabels;
  
  /// Callback when a point is moved.
  /// Parameters: pointATime, pointAPrice, pointBTime, pointBPrice, pointCTime, pointCPrice
  final void Function(
    int pointATime,
    double pointAPrice,
    int pointBTime,
    double pointBPrice,
    int pointCTime,
    double pointCPrice,
  )? onMoved;
  
  /// Callback when the Fibonacci Extension is deleted.
  final VoidCallback? onDelete;

  const FibonacciExtensionOptions({
    this.draggable = true,
    this.showLabels = true,
    this.onMoved,
    this.onDelete,
  });

  FibonacciExtensionOptions copyWith({
    bool? draggable,
    bool? showLabels,
    void Function(int, double, int, double, int, double)? onMoved,
    VoidCallback? onDelete,
  }) {
    return FibonacciExtensionOptions(
      draggable: draggable ?? this.draggable,
      showLabels: showLabels ?? this.showLabels,
      onMoved: onMoved ?? this.onMoved,
      onDelete: onDelete ?? this.onDelete,
    );
  }
}
