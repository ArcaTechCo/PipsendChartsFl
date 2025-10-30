/// Defines how prices are scaled on the chart.
enum PriceScaleMode {
  /// Normal linear scale - default mode.
  /// Prices are displayed in their actual values.
  normal,

  /// Logarithmic scale.
  /// Useful for assets with large price movements.
  /// Each unit of distance represents the same percentage change.
  logarithmic,

  /// Percentage scale.
  /// Shows price changes as percentages from a base value.
  percentage,

  /// Indexed scale.
  /// Normalizes all values to start at 100.
  /// Useful for comparing multiple assets.
  indexed,
}

/// Position of the price scale on the chart.
enum PriceScalePosition {
  /// Price scale on the left side.
  left,

  /// Price scale on the right side (default).
  right,

  /// No price scale visible.
  none,
}
