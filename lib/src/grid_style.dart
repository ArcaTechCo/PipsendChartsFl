import 'package:flutter/material.dart';

/// Style of grid lines (solid, dashed, dotted, etc.)
enum GridLineStyle {
  /// Solid continuous line ─────────
  solid,

  /// Dashed line ─ ─ ─ ─ ─
  dashed,

  /// Dotted line · · · · ·
  dotted,

  /// Long dashed line ── ── ──
  longDashed,
}

/// Configuration for chart grid lines (horizontal and vertical).
///
/// Grid lines are automatically aligned with their respective labels:
/// - Horizontal grid lines align with price labels
/// - Vertical grid lines align with time labels
///
/// Example:
/// ```dart
/// InteractiveChart(
///   style: ChartStyle(
///     gridStyle: GridStyle.full,
///   ),
/// )
/// ```
class GridStyle {
  // ========== HORIZONTAL GRID (Price) ==========

  /// Show horizontal grid lines aligned with price labels.
  final bool showHorizontalGrid;

  /// Color of horizontal grid lines.
  final Color horizontalGridColor;

  /// Stroke width of horizontal grid lines.
  final double horizontalStrokeWidth;

  /// Style of horizontal grid lines (solid, dashed, dotted).
  final GridLineStyle horizontalLineStyle;

  // ========== VERTICAL GRID (Time) ==========

  /// Show vertical grid lines aligned with time labels.
  final bool showVerticalGrid;

  /// Color of vertical grid lines.
  final Color verticalGridColor;

  /// Stroke width of vertical grid lines.
  final double verticalStrokeWidth;

  /// Style of vertical grid lines (solid, dashed, dotted).
  final GridLineStyle verticalLineStyle;

  const GridStyle({
    // Horizontal defaults
    this.showHorizontalGrid = true,
    this.horizontalGridColor = const Color(0x4D9E9E9E), // Grey with 30% opacity
    this.horizontalStrokeWidth = 0.5,
    this.horizontalLineStyle = GridLineStyle.solid,
    // Vertical defaults
    this.showVerticalGrid = false,
    this.verticalGridColor = const Color(0x4D9E9E9E), // Grey with 30% opacity
    this.verticalStrokeWidth = 0.5,
    this.verticalLineStyle = GridLineStyle.solid,
  });

  // ========== PRESETS ==========

  /// No grid lines.
  static const GridStyle none = GridStyle(
    showHorizontalGrid: false,
    showVerticalGrid: false,
  );

  /// Only horizontal grid lines (default behavior).
  static const GridStyle horizontalOnly = GridStyle(
    showHorizontalGrid: true,
    showVerticalGrid: false,
  );

  /// Full grid with both horizontal and vertical lines.
  static const GridStyle full = GridStyle(
    showHorizontalGrid: true,
    showVerticalGrid: true,
  );

  /// Subtle grid with low opacity.
  static const GridStyle subtle = GridStyle(
    showHorizontalGrid: true,
    showVerticalGrid: true,
    horizontalGridColor: Color(0x1A9E9E9E), // Grey with 10% opacity
    verticalGridColor: Color(0x1A9E9E9E), // Grey with 10% opacity
  );

  /// Dashed grid style.
  static const GridStyle dashed = GridStyle(
    showHorizontalGrid: true,
    showVerticalGrid: true,
    horizontalLineStyle: GridLineStyle.dashed,
    verticalLineStyle: GridLineStyle.dashed,
  );

  /// Dotted grid style.
  static const GridStyle dotted = GridStyle(
    showHorizontalGrid: true,
    showVerticalGrid: true,
    horizontalLineStyle: GridLineStyle.dotted,
    verticalLineStyle: GridLineStyle.dotted,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridStyle &&
          runtimeType == other.runtimeType &&
          showHorizontalGrid == other.showHorizontalGrid &&
          horizontalGridColor == other.horizontalGridColor &&
          horizontalStrokeWidth == other.horizontalStrokeWidth &&
          horizontalLineStyle == other.horizontalLineStyle &&
          showVerticalGrid == other.showVerticalGrid &&
          verticalGridColor == other.verticalGridColor &&
          verticalStrokeWidth == other.verticalStrokeWidth &&
          verticalLineStyle == other.verticalLineStyle;

  @override
  int get hashCode =>
      showHorizontalGrid.hashCode ^
      horizontalGridColor.hashCode ^
      horizontalStrokeWidth.hashCode ^
      horizontalLineStyle.hashCode ^
      showVerticalGrid.hashCode ^
      verticalGridColor.hashCode ^
      verticalStrokeWidth.hashCode ^
      verticalLineStyle.hashCode;
}
