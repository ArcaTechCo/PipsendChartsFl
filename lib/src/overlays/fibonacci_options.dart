import 'package:flutter/widgets.dart';

/// Options for configuring a Fibonacci retracement overlay.
class FibonacciOptions {
  /// Whether the Fibonacci can be dragged.
  final bool draggable;
  
  /// Whether to show labels for each level.
  final bool showLabels;
  
  /// Whether to show percentage values.
  final bool showPercentages;
  
  /// Whether to show price values.
  final bool showPrices;
  
  /// Whether to extend lines to the right.
  final bool extendLines;
  
  /// Callback when the Fibonacci is moved.
  /// Parameters: newHighPrice, newLowPrice, newStartTime, newEndTime
  final void Function(double newHighPrice, double newLowPrice, int? newStartTime, int? newEndTime)? onMoved;
  
  /// Callback when the Fibonacci is deleted.
  final VoidCallback? onDelete;

  const FibonacciOptions({
    this.draggable = true,
    this.showLabels = true,
    this.showPercentages = true,
    this.showPrices = true,
    this.extendLines = false,
    this.onMoved,
    this.onDelete,
  });

  Map<String, dynamic> toJson() => {
    'draggable': draggable,
    'showLabels': showLabels,
    'showPercentages': showPercentages,
    'showPrices': showPrices,
    'extendLines': extendLines,
  };

  factory FibonacciOptions.fromJson(Map<String, dynamic> json) {
    return FibonacciOptions(
      draggable: json['draggable'] as bool? ?? true,
      showLabels: json['showLabels'] as bool? ?? true,
      showPercentages: json['showPercentages'] as bool? ?? true,
      showPrices: json['showPrices'] as bool? ?? true,
      extendLines: json['extendLines'] as bool? ?? false,
    );
  }

  FibonacciOptions copyWith({
    bool? draggable,
    bool? showLabels,
    bool? showPercentages,
    bool? showPrices,
    bool? extendLines,
    void Function(double, double, int?, int?)? onMoved,
    VoidCallback? onDelete,
  }) {
    return FibonacciOptions(
      draggable: draggable ?? this.draggable,
      showLabels: showLabels ?? this.showLabels,
      showPercentages: showPercentages ?? this.showPercentages,
      showPrices: showPrices ?? this.showPrices,
      extendLines: extendLines ?? this.extendLines,
      onMoved: onMoved ?? this.onMoved,
      onDelete: onDelete ?? this.onDelete,
    );
  }
}
