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

  /// The number of candles/bars BEFORE the visible area.
  ///
  /// This is useful for implementing infinite history / lazy loading.
  /// When this number is low, you should load more historical data.
  ///
  /// Example:
  /// ```dart
  /// if (details.candlesBeforeVisible < 50) {
  ///   loadMoreHistoricalData();
  /// }
  /// ```
  int get candlesBeforeVisible => startCandleIndex;

  /// The number of candles/bars AFTER the visible area.
  ///
  /// This is useful for implementing infinite history / lazy loading.
  /// When this number is low, you should load more recent data.
  ///
  /// Example:
  /// ```dart
  /// if (details.candlesAfterVisible < 50) {
  ///   loadMoreRecentData();
  /// }
  /// ```
  int get candlesAfterVisible => totalCandles - endCandleIndex;

  /// Whether the chart is at the beginning (showing the oldest data).
  bool get isAtStart => startCandleIndex == 0;

  /// Whether the chart is at the end (showing the most recent data).
  bool get isAtEnd => endCandleIndex >= totalCandles - 1;

  /// Checks if the chart is near the start (within the threshold).
  ///
  /// This is useful for triggering lazy loading of historical data.
  /// Returns true when the number of candles before the visible area
  /// is less than the specified threshold.
  ///
  /// [threshold] - The number of candles to use as threshold (default: 50)
  ///
  /// Example:
  /// ```dart
  /// onXOffsetChanged: (details) {
  ///   if (details.isNearStart(threshold: 50)) {
  ///     print('Load more historical data!');
  ///     loadMoreHistory();
  ///   }
  /// }
  /// ```
  bool isNearStart([int threshold = 50]) => candlesBeforeVisible < threshold;

  /// Checks if the chart is near the end (within the threshold).
  ///
  /// This is useful for triggering lazy loading of recent data.
  /// Returns true when the number of candles after the visible area
  /// is less than the specified threshold.
  ///
  /// [threshold] - The number of candles to use as threshold (default: 50)
  ///
  /// Example:
  /// ```dart
  /// onXOffsetChanged: (details) {
  ///   if (details.isNearEnd(threshold: 50)) {
  ///     print('Load more recent data!');
  ///     loadMoreRecentData();
  ///   }
  /// }
  /// ```
  bool isNearEnd([int threshold = 50]) => candlesAfterVisible < threshold;

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
