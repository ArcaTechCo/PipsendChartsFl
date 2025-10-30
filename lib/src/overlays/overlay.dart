import 'package:flutter/painting.dart';
import '../painter_params.dart';

/// Base class for all chart overlays.
///
/// Overlays are visual elements drawn on top of the chart,
/// such as trading lines, trend lines, Fibonacci levels, etc.
abstract class ChartOverlay {
  /// Unique identifier for this overlay.
  final String id;

  /// Whether this overlay is interactive (can be tapped, dragged, etc.).
  final bool interactive;

  /// Whether this overlay is visible.
  final bool visible;

  const ChartOverlay({
    required this.id,
    this.interactive = false,
    this.visible = true,
  });

  /// Paints this overlay on the canvas.
  ///
  /// [canvas] is the canvas to draw on.
  /// [params] contains the painting parameters and dimensions.
  /// [isBeingDragged] indicates if this overlay is currently being dragged.
  void paint(Canvas canvas, PainterParams params, {bool isBeingDragged = false});

  /// Tests if a position hits this overlay.
  ///
  /// Returns true if the [position] is within the bounds of this overlay.
  /// Used for tap detection and drag operations.
  bool hitTest(Offset position, PainterParams params) {
    return false; // Default implementation
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChartOverlay &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ChartOverlay(id: $id, interactive: $interactive)';
}
