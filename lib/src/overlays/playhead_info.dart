/// Information emitted by [InteractiveChart.onPlayheadChanged] when the
/// user drags the built-in replay playhead.
class PlayheadInfo {
  /// Index of the candle the playhead now points at. Clamped to the
  /// valid range `[0, candles.length - 1]`.
  final int candleIndex;

  /// Timestamp (ms since epoch) of [candleIndex] in the chart's data.
  ///
  /// This is the canonical timestamp of the candle. For sub-candle
  /// drag precision use [interpolatedTimestamp].
  final int candleTimestamp;

  /// Timestamp at the exact x position the user dropped the playhead.
  ///
  /// May fall between candles when the drag stopped mid-candle. Useful
  /// when the host wants to display a richer label.
  final int interpolatedTimestamp;

  const PlayheadInfo({
    required this.candleIndex,
    required this.candleTimestamp,
    required this.interpolatedTimestamp,
  });

  @override
  String toString() => 'PlayheadInfo('
      'index: $candleIndex, '
      'candleTs: $candleTimestamp, '
      'interpTs: $interpolatedTimestamp)';
}
