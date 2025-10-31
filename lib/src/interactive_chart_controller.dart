import 'package:flutter/foundation.dart';

/// Controller for programmatic interactions with InteractiveChart.
///
/// Use this controller to programmatically control chart behavior such as
/// jumping to the latest candle or scrolling to a specific position.
class InteractiveChartController {
  VoidCallback? _jumpToLatestCallback;

  /// Attach the internal jump to latest callback.
  /// This is called internally by the InteractiveChart widget.
  /// @nodoc
  void attach(VoidCallback jumpToLatest) {
    _jumpToLatestCallback = jumpToLatest;
  }

  /// Detach the internal callbacks.
  /// This is called internally when the widget is disposed.
  /// @nodoc
  void detach() {
    _jumpToLatestCallback = null;
  }

  /// Jump to the latest candle (most recent data).
  ///
  /// This will scroll the chart to show the most recent candles.
  void jumpToLatest() {
    _jumpToLatestCallback?.call();
  }

  /// Check if the controller is attached to a chart.
  bool get isAttached => _jumpToLatestCallback != null;
}
