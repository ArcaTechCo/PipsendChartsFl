/// Helper class to store minimum and maximum values.
///
/// Used by series and indicators to represent data ranges.
class MinMax {
  final double min;
  final double max;

  const MinMax({required this.min, required this.max});

  /// The range between min and max.
  double get range => max - min;

  /// The midpoint between min and max.
  double get midpoint => (min + max) / 2;

  @override
  String toString() => 'MinMax(min: $min, max: $max)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MinMax &&
          runtimeType == other.runtimeType &&
          min == other.min &&
          max == other.max;

  @override
  int get hashCode => min.hashCode ^ max.hashCode;
}
