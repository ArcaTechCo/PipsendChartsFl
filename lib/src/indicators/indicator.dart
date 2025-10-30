import 'package:flutter/painting.dart';
import '../candle_data.dart';
import '../painter_params.dart';
import '../common/min_max.dart';
import 'indicator_panel.dart';
import 'indicator_value.dart';

/// Base class for all technical indicators.
///
/// Indicators analyze price data and produce visual overlays or
/// separate panels with additional information.
///
/// Subclasses must implement:
/// - [calculate] to compute indicator values from candle data
/// - [paint] to render the indicator on the canvas
abstract class Indicator {
  /// Unique identifier for this indicator.
  final String id;

  /// Panel configuration (overlay or separate).
  final IndicatorPanel panel;

  /// Style configuration for rendering.
  final IndicatorStyle style;

  /// Whether this indicator is visible.
  final bool visible;

  /// Cached calculated values.
  List<IndicatorValue>? _cachedValues;

  /// The data that was used for the last calculation.
  List<CandleData>? _cachedData;

  Indicator({
    required this.id,
    required this.panel,
    required this.style,
    this.visible = true,
  });

  /// Calculates indicator values from candle data.
  ///
  /// [data] is the full list of candle data.
  ///
  /// Returns a list of [IndicatorValue] objects, one for each candle.
  /// The list should have the same length as [data].
  List<IndicatorValue> calculate(List<CandleData> data);

  /// Gets the calculated values, using cache if available.
  ///
  /// This method checks if the data has changed since the last calculation.
  /// If not, it returns the cached values for better performance.
  List<IndicatorValue> getValues(List<CandleData> data) {
    // Check if we can use cached values
    if (_cachedValues != null && 
        _cachedData != null && 
        _cachedData!.length == data.length &&
        _dataEquals(_cachedData!, data)) {
      return _cachedValues!;
    }

    // Calculate new values
    _cachedValues = calculate(data);
    _cachedData = List.from(data);
    return _cachedValues!;
  }

  /// Checks if two data lists are equal (for caching).
  bool _dataEquals(List<CandleData> a, List<CandleData> b) {
    if (a.length != b.length) return false;
    
    // Check first, middle, and last elements for quick comparison
    if (a.isEmpty) return true;
    
    if (a.first.timestamp != b.first.timestamp) return false;
    if (a.last.timestamp != b.last.timestamp) return false;
    
    if (a.length > 2) {
      final mid = a.length ~/ 2;
      if (a[mid].timestamp != b[mid].timestamp) return false;
    }
    
    return true;
  }

  /// Clears the cached values.
  ///
  /// Call this when you know the data has changed and want to force
  /// a recalculation.
  void clearCache() {
    _cachedValues = null;
    _cachedData = null;
  }

  /// Paints this indicator on the canvas.
  ///
  /// [canvas] is the canvas to draw on.
  /// [params] contains the painting parameters and dimensions.
  /// [values] are the calculated indicator values.
  void paint(Canvas canvas, PainterParams params, List<IndicatorValue> values);

  /// Calculates the minimum and maximum values for this indicator.
  ///
  /// [values] are the calculated indicator values.
  /// [startIndex] is the first visible data point.
  /// [endIndex] is the last visible data point.
  ///
  /// Returns null if no valid data is available.
  /// This is used for auto-scaling separate panels.
  MinMax? calculateMinMax(
    List<IndicatorValue> values,
    int startIndex,
    int endIndex,
  ) {
    if (values.isEmpty) return null;

    final start = startIndex.clamp(0, values.length - 1);
    final end = endIndex.clamp(start, values.length);

    double? minValue;
    double? maxValue;

    for (int i = start; i < end; i++) {
      final value = values[i];
      if (value.isEmpty) continue;

      for (final v in value.values.values) {
        if (v == null) continue;

        minValue = minValue == null ? v : (v < minValue ? v : minValue);
        maxValue = maxValue == null ? v : (v > maxValue ? v : maxValue);
      }
    }

    if (minValue == null || maxValue == null) return null;

    // Add 5% padding
    final padding = (maxValue - minValue) * 0.05;
    return MinMax(
      min: minValue - padding,
      max: maxValue + padding,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Indicator &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Indicator(id: $id, panel: ${panel.type})';
}

/// Base class for indicator styles.
abstract class IndicatorStyle {
  const IndicatorStyle();
}
