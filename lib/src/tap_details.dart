import 'candle_data.dart';

/// Details about a tap event on the chart.
///
/// This is provided when the [InteractiveChart.onTap] callback is triggered.
class TapDetails {
  /// The candle that was tapped, or null if tapping in future (empty) space.
  final CandleData? candle;

  /// The price level where the user tapped (Y-axis value).
  final double tapPrice;

  /// The index of the tapped candle in the dataset, or -1 if in future space.
  final int candleIndex;

  /// The estimated timestamp at the tap position.
  /// For taps on candles, this is the candle's timestamp.
  /// For taps in future space, this is extrapolated from candle spacing.
  final int? timestamp;

  /// Whether the tap occurred in the future (empty) space beyond the last candle.
  bool get isFutureSpace => candle == null;

  const TapDetails({
    this.candle,
    required this.tapPrice,
    required this.candleIndex,
    this.timestamp,
  });

  @override
  String toString() => 'TapDetails('
      'candle: $candle, '
      'tapPrice: ${tapPrice.toStringAsFixed(2)}, '
      'index: $candleIndex)';
}
