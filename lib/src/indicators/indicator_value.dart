/// Represents a calculated value from an indicator at a specific timestamp.
///
/// Indicators can produce multiple values at each point in time.
/// For example, MACD produces: macd line, signal line, and histogram.
class IndicatorValue {
  /// Timestamp in milliseconds since epoch.
  final int timestamp;

  /// Map of value names to their calculated values.
  ///
  /// Examples:
  /// - RSI: {'rsi': 65.5}
  /// - MACD: {'macd': 2.5, 'signal': 1.8, 'histogram': 0.7}
  /// - Bollinger Bands: {'upper': 152.0, 'middle': 150.0, 'lower': 148.0}
  final Map<String, double?> values;

  const IndicatorValue({
    required this.timestamp,
    required this.values,
  });

  /// Gets a specific value by name.
  ///
  /// Returns null if the value doesn't exist or is null.
  double? getValue(String name) => values[name];

  /// Gets a specific value by name, with a fallback.
  double getValueOr(String name, double defaultValue) {
    return values[name] ?? defaultValue;
  }

  /// Whether this indicator value has a specific named value.
  bool hasValue(String name) => values.containsKey(name);

  /// Whether all values are null.
  bool get isEmpty => values.values.every((v) => v == null);

  /// Whether at least one value is non-null.
  bool get isNotEmpty => !isEmpty;

  @override
  String toString() {
    final valuesStr = values.entries
        .map((e) => '${e.key}: ${e.value?.toStringAsFixed(2) ?? "null"}')
        .join(', ');
    return 'IndicatorValue(timestamp: $timestamp, $valuesStr)';
  }

  /// Creates a copy with modified values.
  IndicatorValue copyWith({
    int? timestamp,
    Map<String, double?>? values,
  }) {
    return IndicatorValue(
      timestamp: timestamp ?? this.timestamp,
      values: values ?? Map.from(this.values),
    );
  }

  /// Merges this indicator value with another.
  ///
  /// Values from [other] will override values in this instance.
  IndicatorValue merge(IndicatorValue other) {
    return IndicatorValue(
      timestamp: timestamp,
      values: {...values, ...other.values},
    );
  }
}
