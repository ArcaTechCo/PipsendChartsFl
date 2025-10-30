import 'candle_data.dart';

/// Details about a tap event on the chart.
///
/// This is provided when the [InteractiveChart.onTap] callback is triggered.
class TapDetails {
  /// The candle that was tapped.
  final CandleData candle;

  /// The price level where the user tapped (Y-axis value).
  final double tapPrice;

  /// The index of the tapped candle in the dataset.
  final int candleIndex;

  const TapDetails({
    required this.candle,
    required this.tapPrice,
    required this.candleIndex,
  });

  @override
  String toString() => 'TapDetails('
      'candle: $candle, '
      'tapPrice: ${tapPrice.toStringAsFixed(2)}, '
      'index: $candleIndex)';
}
