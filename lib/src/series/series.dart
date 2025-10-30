import 'package:flutter/painting.dart';
import '../scale/price_scale.dart';
import '../painter_params.dart';
import '../common/min_max.dart';
import 'series_type.dart';

/// Base class for all chart series.
///
/// A series represents a set of data points that are displayed on the chart.
/// Each series has its own price scale and visual style.
///
/// Subclasses must implement:
/// - [paint] to render the series on the canvas
/// - [getValueAt] to retrieve the value at a specific index
/// - [calculateMinMax] to determine the data range
abstract class Series {
  /// Unique identifier for this series.
  final String id;

  /// The type of this series.
  final SeriesType type;

  /// The price scale this series uses.
  final PriceScale priceScale;

  /// Whether this series is visible.
  final bool visible;

  /// Z-index for layering (higher values are drawn on top).
  final int zIndex;

  const Series({
    required this.id,
    required this.type,
    required this.priceScale,
    this.visible = true,
    this.zIndex = 0,
  });

  /// Paints this series on the canvas.
  ///
  /// [canvas] is the canvas to draw on.
  /// [params] contains the painting parameters and dimensions.
  void paint(Canvas canvas, PainterParams params);

  /// Gets the value at the specified index.
  ///
  /// Returns null if the index is out of bounds or the value is not available.
  double? getValueAt(int index);

  /// Calculates the minimum and maximum values for the visible data range.
  ///
  /// [startIndex] is the first visible data point.
  /// [endIndex] is the last visible data point.
  ///
  /// Returns a MinMax object with min and max values.
  /// Returns null if no valid data is available.
  MinMax? calculateMinMax(int startIndex, int endIndex);

  /// Gets the number of data points in this series.
  int get dataLength;

  /// Whether this series should be included in auto-scaling calculations.
  bool get includeInAutoScale => visible && priceScale.autoScale;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Series &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Series(id: $id, type: $type, scale: ${priceScale.id})';
}

/// Style configuration for series rendering.
abstract class SeriesStyle {
  const SeriesStyle();
}
