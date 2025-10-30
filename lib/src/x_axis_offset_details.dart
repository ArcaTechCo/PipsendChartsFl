/// Details about the X-axis offset change in the chart.
///
/// This is provided when the [InteractiveChart.onXOffsetChanged] callback
/// is triggered, typically when the user pans or zooms the chart.
class XAxisOffsetDetails {
  /// The current X-axis offset in pixels from the start of the chart.
  ///
  /// A value of 0.0 means the chart is showing data from the very beginning.
  /// Higher values indicate scrolling towards more recent data.
  final double offset;

  /// The index of the first visible candle in the current view.
  final int startCandleIndex;

  /// The index of the last visible candle in the current view.
  final int endCandleIndex;

  /// The total number of candles in the dataset.
  final int totalCandles;

  /// The number of visible candles in the current view.
  int get visibleCandleCount => endCandleIndex - startCandleIndex;

  /// Whether the chart is at the beginning (showing the oldest data).
  bool get isAtStart => startCandleIndex == 0;

  /// Whether the chart is at the end (showing the most recent data).
  bool get isAtEnd => endCandleIndex >= totalCandles - 1;

  const XAxisOffsetDetails({
    required this.offset,
    required this.startCandleIndex,
    required this.endCandleIndex,
    required this.totalCandles,
  });

  @override
  String toString() => 'XAxisOffsetDetails('
      'offset: $offset, '
      'startIndex: $startCandleIndex, '
      'endIndex: $endCandleIndex, '
      'total: $totalCandles)';
}
