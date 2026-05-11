import 'package:flutter/foundation.dart';

/// Controller for programmatic interactions with InteractiveChart.
///
/// Use this controller to programmatically control chart behavior such as
/// jumping to the latest candle, seeking to a specific candle or
/// timestamp, or adjusting the visible candle window.
class InteractiveChartController {
  VoidCallback? _jumpToLatestCallback;
  ValueChanged<int>? _seekToIndexCallback;
  ValueChanged<int>? _seekToTimestampCallback;
  ValueChanged<int>? _setVisibleCandleCountCallback;

  /// Attach internal callbacks. Called by the InteractiveChart widget.
  ///
  /// @nodoc
  void attach({
    required VoidCallback jumpToLatest,
    ValueChanged<int>? seekToIndex,
    ValueChanged<int>? seekToTimestamp,
    ValueChanged<int>? setVisibleCandleCount,
  }) {
    _jumpToLatestCallback = jumpToLatest;
    _seekToIndexCallback = seekToIndex;
    _seekToTimestampCallback = seekToTimestamp;
    _setVisibleCandleCountCallback = setVisibleCandleCount;
  }

  /// Detach the internal callbacks.
  ///
  /// @nodoc
  void detach() {
    _jumpToLatestCallback = null;
    _seekToIndexCallback = null;
    _seekToTimestampCallback = null;
    _setVisibleCandleCountCallback = null;
  }

  /// Jump to the latest candle (most recent data).
  void jumpToLatest() => _jumpToLatestCallback?.call();

  /// Center the visible range on [candleIndex]. The index is clamped
  /// to the valid range. In replay mode the upper bound is
  /// `playheadIndex` rather than `candles.length - 1`.
  ///
  /// No-op if the controller is not attached.
  void seekToIndex(int candleIndex) =>
      _seekToIndexCallback?.call(candleIndex);

  /// Center the visible range on the candle whose timestamp is the
  /// closest one not exceeding [timestamp].
  ///
  /// No-op if the controller is not attached.
  void seekToTimestamp(int timestamp) =>
      _seekToTimestampCallback?.call(timestamp);

  /// Adjust the visible candle window. Higher values zoom out, lower
  /// values zoom in. Values are clamped to the chart's allowed range.
  ///
  /// No-op if the controller is not attached.
  void setVisibleCandleCount(int count) =>
      _setVisibleCandleCountCallback?.call(count);

  /// Check if the controller is attached to a chart.
  bool get isAttached => _jumpToLatestCallback != null;
}
