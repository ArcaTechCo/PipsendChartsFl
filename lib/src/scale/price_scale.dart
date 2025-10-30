import 'price_scale_mode.dart';

/// Defines a price scale for series in the chart.
///
/// A price scale determines how values are mapped to vertical positions
/// on the chart. Multiple series can share the same price scale, or each
/// can have its own independent scale.
///
/// Example:
/// ```dart
/// // Main price scale for candlesticks
/// final mainScale = PriceScale.main();
///
/// // Separate scale for volume with 20% height
/// final volumeScale = PriceScale.volume(heightFactor: 0.2);
///
/// // Custom scale for an indicator
/// final rsiScale = PriceScale.indicator('rsi', heightFactor: 0.2);
/// ```
class PriceScale {
  /// Unique identifier for this price scale.
  final String id;

  /// The scaling mode (normal, logarithmic, percentage, indexed).
  final PriceScaleMode mode;

  /// Height factor relative to the total chart height.
  ///
  /// For example, 0.2 means this scale takes 20% of the chart height.
  /// If null, the scale shares the remaining space with other scales.
  final double? heightFactor;

  /// Whether this price scale is visible.
  final bool visible;

  /// Position of the price labels (left, right, or none).
  final PriceScalePosition position;

  /// Minimum value for this scale (optional).
  /// If null, it will be calculated from the data.
  final double? minValue;

  /// Maximum value for this scale (optional).
  /// If null, it will be calculated from the data.
  final double? maxValue;

  /// Whether to auto-scale based on visible data.
  /// If true, min/max values adjust as you pan/zoom.
  final bool autoScale;

  /// Inverts the scale (higher values at bottom).
  final bool inverted;

  const PriceScale({
    required this.id,
    this.mode = PriceScaleMode.normal,
    this.heightFactor,
    this.visible = true,
    this.position = PriceScalePosition.right,
    this.minValue,
    this.maxValue,
    this.autoScale = true,
    this.inverted = false,
  });

  /// Creates the main price scale for candlestick data.
  ///
  /// This is the primary scale that typically takes up most of the chart.
  factory PriceScale.main({
    PriceScaleMode mode = PriceScaleMode.normal,
    PriceScalePosition position = PriceScalePosition.right,
    bool autoScale = true,
  }) {
    return PriceScale(
      id: 'main',
      mode: mode,
      position: position,
      autoScale: autoScale,
    );
  }

  /// Creates a price scale for volume data.
  ///
  /// Volume typically appears at the bottom of the chart with a fixed height.
  ///
  /// [heightFactor] determines what percentage of the chart height is used.
  /// Default is 0.2 (20%).
  factory PriceScale.volume({
    double heightFactor = 0.2,
    bool visible = true,
  }) {
    return PriceScale(
      id: 'volume',
      heightFactor: heightFactor,
      visible: visible,
      position: PriceScalePosition.none,
      autoScale: true,
    );
  }

  /// Creates a price scale for an indicator.
  ///
  /// Indicators can be overlaid on the main chart or in separate panels.
  ///
  /// [id] should be unique for each indicator.
  /// [heightFactor] determines the panel height if separate.
  factory PriceScale.indicator(
    String id, {
    double heightFactor = 0.2,
    PriceScalePosition position = PriceScalePosition.right,
    double? minValue,
    double? maxValue,
    bool autoScale = true,
  }) {
    return PriceScale(
      id: id,
      heightFactor: heightFactor,
      position: position,
      minValue: minValue,
      maxValue: maxValue,
      autoScale: autoScale,
    );
  }

  /// Creates a price scale that overlays on the main scale.
  ///
  /// Useful for indicators that should appear on top of the candlesticks,
  /// like Bollinger Bands or Moving Averages.
  factory PriceScale.overlay({
    String id = 'overlay',
    PriceScalePosition position = PriceScalePosition.none,
  }) {
    return PriceScale(
      id: id,
      position: position,
      autoScale: true,
    );
  }

  /// Whether this scale has a fixed height.
  bool get hasFixedHeight => heightFactor != null;

  /// Whether this scale is the main scale.
  bool get isMain => id == 'main';

  /// Whether this scale is for volume.
  bool get isVolume => id == 'volume';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PriceScale &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'PriceScale(id: $id, mode: $mode, heightFactor: $heightFactor)';

  /// Creates a copy of this price scale with modified properties.
  PriceScale copyWith({
    String? id,
    PriceScaleMode? mode,
    double? heightFactor,
    bool? visible,
    PriceScalePosition? position,
    double? minValue,
    double? maxValue,
    bool? autoScale,
    bool? inverted,
  }) {
    return PriceScale(
      id: id ?? this.id,
      mode: mode ?? this.mode,
      heightFactor: heightFactor ?? this.heightFactor,
      visible: visible ?? this.visible,
      position: position ?? this.position,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      autoScale: autoScale ?? this.autoScale,
      inverted: inverted ?? this.inverted,
    );
  }
}
