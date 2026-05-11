import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;

import 'candle_data.dart';
import 'chart_painter.dart';
import 'chart_style.dart';
import 'painter_params.dart';
import 'x_axis_offset_details.dart';
import 'tap_details.dart';
import 'interactive_chart_controller.dart';
import 'overlays/overlay.dart';
import 'overlays/trading_line.dart';
import 'overlays/price_zone.dart';
import 'overlays/fibonacci_retracement.dart';
import 'overlays/trend_line.dart';
import 'overlays/tools/position_tool.dart';
import 'overlays/tools/ruler_tool.dart';
import 'overlays/tools/vertical_line.dart';
import 'overlays/fibonacci_extension.dart';
import 'overlays/fibonacci_fan.dart';
import 'overlays/tools/arrow_tool.dart';
import 'overlays/tools/circle_tool.dart';
import 'overlays/tools/text_tool.dart';
import 'overlays/tools/gantt_tool.dart';
import 'overlays/playhead_style.dart';
import 'overlays/playhead_info.dart';
import 'indicators/indicator.dart';

class InteractiveChart extends StatefulWidget {
  /// The full list of [CandleData] to be used for this chart.
  ///
  /// It needs to have at least 3 data points. If data is sufficiently large,
  /// the chart will default to display the most recent 90 data points when
  /// first opened (configurable with [initialVisibleCandleCount] parameter),
  /// and allow users to freely zoom and pan however they like.
  final List<CandleData> candles;

  /// The default number of data points to be displayed when the chart is first
  /// opened. The default value is 90. If [CandleData] does not have enough data
  /// points, the chart will display all of them.
  final int initialVisibleCandleCount;

  /// If non-null, the style to use for this chart.
  final ChartStyle style;

  /// How the date/time label at the bottom are displayed.
  ///
  /// If null, it defaults to use yyyy-mm format if more than 20 data points
  /// are visible in the current chart window, otherwise it uses mm-dd format.
  final TimeLabelGetter? timeLabel;

  /// How the price labels on the right are displayed.
  ///
  /// If null, it defaults to show 2 digits after the decimal point.
  final PriceLabelGetter? priceLabel;

  /// How the overlay info are displayed, when user touches the chart.
  ///
  /// If null, it defaults to display `date`, `open`, `high`, `low`, `close`
  /// and `volume` fields when user selects a data point in the chart.
  ///
  /// To customize it, pass in a function that returns a Map<String,String>:
  /// ```dart
  /// return {
  ///   "Date": "Customized date string goes here",
  ///   "Open": candle.open?.toStringAsFixed(2) ?? "-",
  ///   "Close": candle.close?.toStringAsFixed(2) ?? "-",
  /// };
  /// ```
  final OverlayInfoGetter? overlayInfo;

  /// An optional event, fired when the user clicks on a candlestick.
  ///
  /// Provides detailed information including the tapped candle, the price
  /// level at the tap position, and the candle index.
  final ValueChanged<TapDetails>? onTap;

  /// An optional event, fired when user zooms in/out.
  ///
  /// This provides the width of a candlestick at the current zoom level.
  final ValueChanged<double>? onCandleResize;

  /// An optional event, fired when the X-axis offset changes.
  ///
  /// This is triggered when the user pans or zooms the chart, providing
  /// information about the current visible range and scroll position.
  /// Useful for implementing lazy loading of historical data.
  final ValueChanged<XAxisOffsetDetails>? onXOffsetChanged;

  /// List of overlays to draw on top of the chart.
  ///
  /// Overlays include trading lines, trend lines, Fibonacci levels, etc.
  final List<ChartOverlay> overlays;

  /// List of indicators to display on the chart.
  ///
  /// Indicators can be overlays (drawn on the main chart) or separate panels
  /// (drawn below the main chart). Examples: SMA, EMA, RSI, MACD, etc.
  final List<Indicator> indicators;

  /// Whether to show the Pipsend Charts watermark in the bottom-left corner.
  ///
  /// Defaults to true. Set to false to hide the watermark.
  final bool showWatermark;

  /// Whether to enable tap interaction to show candle details overlay.
  ///
  /// When true (default), tapping on the chart will show an overlay with
  /// OHLC data, volume, and other candle information.
  /// Set to false to disable this interaction.
  final bool enableInteraction;

  /// Whether to enable free camera movement.
  ///
  /// When false (default), scrolling is constrained to the available data range.
  /// When true, allows unlimited scrolling beyond the data boundaries.
  final bool freeCamera;

  /// Number of empty candle-widths to show to the right of the last candle.
  ///
  /// This allows users to scroll past the last candle to see empty space,
  /// useful for drawing tools that extend into the future (like TradingView).
  /// Default is 0 (no extra space). A value of 50 gives roughly half a screen
  /// of future space at default zoom.
  final int futureCandles;

  /// Controller for programmatic chart interactions.
  ///
  /// Use this to control the chart programmatically (e.g., jump to latest).
  final InteractiveChartController? controller;

  /// Initial vertical zoom factor.
  ///
  /// - 1.0 = fit candles to screen (no padding) - default
  /// - >1.0 = zoomed out (adds padding above/below candles)
  /// - <1.0 = zoomed in (crops view)
  ///
  /// This is useful to leave space for indicators, TP/SL lines, etc.
  /// Users can adjust zoom with Shift+Scroll.
  final double initialVerticalZoom;

  /// Whether to enable vertical pan and zoom controls.
  ///
  /// When false (default), the chart auto-fits candles to fill the height (legacy behavior).
  /// When true, enables:
  /// - Vertical zoom with Shift+Scroll (desktop) or pinch (mobile)
  /// - Vertical pan with Alt+Scroll (desktop) or drag (mobile)
  /// - Respects initialVerticalZoom value
  ///
  /// This is useful when you need space for TP/SL lines or indicators outside the candle range.
  final bool enableVerticalPan;

  /// Whether to keep the crosshair (tap highlight + price line + OHLC info) visible after the user lifts their finger.
  ///
  /// When false (default), the crosshair only shows while the user is pressing on the chart,
  /// and disappears on tap-up.
  /// When true, the crosshair stays visible until the user taps somewhere else (which moves it)
  /// or this flag is toggled off.
  ///
  /// Requires [enableInteraction] to be true.
  final bool persistentCrosshair;

  /// Absolute index into [candles] of the replay playhead. When null
  /// the chart behaves normally (no replay).
  ///
  /// When non-null:
  ///   * Candles beyond this index are not drawn (rendering stops at
  ///     the playhead).
  ///   * Indicators still calculate over the full [candles] list, so
  ///     their cache stays stable across playhead moves.
  ///   * The visible range and `onXOffsetChanged.totalCandles` use
  ///     `playheadIndex + 1` as the effective length.
  ///
  /// Must satisfy `0 <= playheadIndex < candles.length`.
  final int? playheadIndex;

  /// Sub-candle progress in `[0.0, 1.0]` used by tick-replay mode.
  ///
  /// When set together with [playheadIndex], the candle at the
  /// playhead position is replaced (visually only) by a partial
  /// candle interpolated via [CandleData.buildPartial]. The
  /// interpolation animates smoothly thanks to the painter tween.
  final double? playheadTickProgress;

  /// Visual style for the built-in playhead line. When null the
  /// chart does not draw a playhead automatically — useful if the
  /// host prefers to render its own as a regular overlay.
  final PlayheadStyle? playheadStyle;

  /// Fired when the user drags the built-in playhead. Only invoked
  /// when both [playheadIndex] and [playheadStyle] are non-null and
  /// [PlayheadStyle.draggable] is true.
  final ValueChanged<PlayheadInfo>? onPlayheadChanged;

  const InteractiveChart({
    Key? key,
    required this.candles,
    this.initialVisibleCandleCount = 90,
    ChartStyle? style,
    this.timeLabel,
    this.priceLabel,
    this.overlayInfo,
    this.onTap,
    this.onCandleResize,
    this.onXOffsetChanged,
    this.overlays = const [],
    this.indicators = const [],
    this.showWatermark = true,
    this.enableInteraction = true,
    this.freeCamera = false,
    this.futureCandles = 0,
    this.controller,
    this.initialVerticalZoom = 1.0,
    this.enableVerticalPan = false,
    this.persistentCrosshair = false,
    this.playheadIndex,
    this.playheadTickProgress,
    this.playheadStyle,
    this.onPlayheadChanged,
  })  : this.style = style ?? const ChartStyle(),
        assert(candles.length >= 3,
            "InteractiveChart requires 3 or more CandleData"),
        assert(initialVisibleCandleCount >= 3,
            "initialVisibleCandleCount must be more 3 or more"),
        assert(playheadIndex == null ||
            (playheadIndex >= 0 && playheadIndex < candles.length),
            "playheadIndex must be a valid index into candles"),
        assert(playheadTickProgress == null ||
            (playheadTickProgress >= 0 && playheadTickProgress <= 1),
            "playheadTickProgress must be between 0 and 1"),
        super(key: key);

  @override
  _InteractiveChartState createState() => _InteractiveChartState();
}

class _InteractiveChartState extends State<InteractiveChart> {
  // The width of an individual bar in the chart.
  late double _candleWidth;

  // The x offset (in px) of current visible chart window,
  // measured against the beginning of the chart.
  // i.e. a value of 0.0 means we are displaying data for the very first day,
  // and a value of 20 * _candleWidth would be skipping the first 20 days.
  late double _startOffset;

  // The position that user is currently tapping, null if user let go.
  Offset? _tapPosition;

  double? _prevChartWidth; // used by _handleResize
  double? _prevCandleWidth;
  double? _prevStartOffset;
  Offset? _initialFocalPoint;
  PainterParams? _prevParams; // used in onTapUp event

  // Captured on every tap-down regardless of [enableInteraction]. Used by
  // [_fireOnTapEvent] so hosts can subscribe to "tap on empty area"
  // even when the OHLC crosshair overlay (which is gated by
  // enableInteraction via [_tapPosition]) is disabled.
  Offset? _lastTapDownPosition;
  
  // Track previous candles length to detect when new candles are added
  int? _prevCandlesLength;
  
  // Track previous offset to detect changes
  double? _prevOffsetNotified;
  
  // Drag & drop state for overlays
  ChartOverlay? _draggedOverlay;
  double? _dragStartPrice; // Current price during drag
  double? _dragInitialPrice; // Initial price when drag started (never updated during drag)
  double? _originalPrice; // Original price when drag started
  Offset? _dragStartPosition; // Current position during drag (for trend lines)
  bool _hasDragged = false; // Track if user actually dragged
  
  // Resize state for zones and fibonacci
  bool _isResizingTop = false; // Resizing top edge (maxPrice/highPrice)
  bool _isResizingBottom = false; // Resizing bottom edge (minPrice/lowPrice)
  bool _isResizingFibonacci = false; // Track if resizing a Fibonacci
  bool _isResizingTrendLine = false; // Track if resizing a TrendLine
  bool _isResizingTrendStart = false; // Resizing start point of TrendLine
  bool _isResizingTrendEnd = false; // Resizing end point of TrendLine
  bool _isResizingPositionEntry = false; // Resizing Entry line of PositionTool
  bool _isResizingPositionSL = false; // Resizing Stop Loss line of PositionTool
  bool _isResizingPositionTP = false; // Resizing Take Profit line of PositionTool
  bool _isDraggingVerticalLine = false; // Dragging VerticalLine
  bool _isResizingFibExtPointA = false; // Resizing point A of FibonacciExtension
  bool _isResizingFibExtPointB = false; // Resizing point B of FibonacciExtension
  bool _isResizingFibExtPointC = false; // Resizing point C of FibonacciExtension
  bool _isResizingFibFanStart = false; // Resizing start point of FibonacciFan
  bool _isResizingFibFanEnd = false; // Resizing end point of FibonacciFan
  bool _isResizingArrowStart = false; // Resizing start point of ArrowTool
  bool _isResizingArrowEnd = false; // Resizing end point of ArrowTool
  bool _isResizingCircleCenter = false; // Resizing center of CircleTool
  bool _isResizingCircleRadius = false; // Resizing radius of CircleTool
  bool _isDraggingTextTool = false; // Dragging TextTool
  bool _isResizingGanttStart = false; // Resizing start of GanttTool
  bool _isResizingGanttEnd = false; // Resizing end of GanttTool
  
  // Double tap detection for text editing
  DateTime? _lastTapTime;
  Offset? _lastTapPosition;
  
  // Vertical zoom and pan state
  late double _verticalZoomFactor; // 1.0 = fit to screen, >1.0 = zoomed out (more padding)
  double _verticalPanOffset = 0.0; // Vertical pan offset in price units
  double? _prevVerticalPanOffset;

  // Replay playhead drag state. When true the current scale gesture
  // is being interpreted as a playhead drag (instead of pan/zoom or
  // overlay drag).
  bool _isDraggingPlayhead = false;

  /// The effective number of candles "available" to the chart. In
  /// replay mode (when [InteractiveChart.playheadIndex] is set) this
  /// is `playheadIndex + 1`; otherwise it is `widget.candles.length`.
  int get _effectiveLength => widget.playheadIndex != null
      ? widget.playheadIndex! + 1
      : widget.candles.length;

  @override
  void initState() {
    super.initState();
    // Initialize vertical zoom from widget property
    _verticalZoomFactor = widget.initialVerticalZoom;
    // Attach controller if provided
    widget.controller?.attach(
      jumpToLatest: jumpToLatest,
      seekToIndex: seekToIndex,
      seekToTimestamp: seekToTimestamp,
      setVisibleCandleCount: setVisibleCandleCount,
    );
  }

  @override
  void didUpdateWidget(InteractiveChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If persistent crosshair was toggled off, clear the tap position so the crosshair disappears.
    if (oldWidget.persistentCrosshair && !widget.persistentCrosshair && _tapPosition != null) {
      setState(() {
        _tapPosition = null;
      });
    }

    // Replay: when the playhead changes (programmatically or via the
    // built-in drag) the effective length of the chart may shrink.
    // The user-controlled [_startOffset] could then point past the
    // new max — leaving the visible window empty. Two protections:
    //
    //   1. Clamp [_startOffset] to the new max so we never render
    //      "off the right edge of the world".
    //   2. If after clamping the playhead is OUT of the visible
    //      window, gently re-center the view so it's visible again
    //      (mirrors TradingView's "follow on scrub" behaviour).
    if (widget.playheadIndex != oldWidget.playheadIndex) {
      final w = _prevChartWidth;
      if (w != null) {
        final maxOff = _getMaxStartOffset(w, _candleWidth);
        if (_startOffset > maxOff) _startOffset = maxOff;

        if (widget.playheadIndex != null) {
          // Compute visible bounds the same way the build flow does
          // so we never disagree with the painter about visibility.
          final startIdx = (_startOffset / _candleWidth).floor();
          final visibleCount = (w / _candleWidth).ceil();
          final endIdxExclusive = startIdx + visibleCount; // +1 "extra"
          final ph = widget.playheadIndex!;
          if (ph < startIdx || ph > endIdxExclusive) {
            // Place playhead at ~75% of the visible window.
            final target = ph - visibleCount * 0.75;
            _startOffset =
                (target * _candleWidth).clamp(0, maxOff).toDouble();
          }
        }
      }
    }
  }

  @override
  void dispose() {
    // Detach controller
    widget.controller?.detach();
    super.dispose();
  }

  /// Fire the [TradingLineOptions.onTap] callback when the user tapped a trading line
  /// without dragging it (or with an insignificant drag).
  ///
  /// Called from [GestureDetector.onTapUp] and [GestureDetector.onScaleEnd] when
  /// `_draggedOverlay` is set but the gesture didn't qualify as a drag.
  void _maybeFireOverlayTap() {
    final overlay = _draggedOverlay;
    if (overlay is TradingLine) {
      overlay.options.onTap?.call();
    }
  }

  /// Jump to the latest candle (most recent data)
  void jumpToLatest() {
    if (_prevChartWidth == null) return;

    final w = _prevChartWidth!;
    final count = w / _candleWidth;
    final newOffset = (_effectiveLength - count) * _candleWidth;

    setState(() {
      _startOffset = newOffset.clamp(0, _getMaxStartOffset(w, _candleWidth));
    });
  }

  /// Center the visible range around an absolute candle index. The
  /// index is clamped to the valid effective range.
  void seekToIndex(int index) {
    if (_prevChartWidth == null) return;
    final w = _prevChartWidth!;
    final count = w / _candleWidth;
    final target = index.clamp(0, _effectiveLength - 1);
    // Place [target] at roughly 75% of the visible window so the
    // playhead has room to advance to the right before scrolling
    // becomes necessary again.
    final desired = target - count * 0.75;
    final newOffset = (desired * _candleWidth)
        .clamp(0, _getMaxStartOffset(w, _candleWidth));
    setState(() {
      _startOffset = newOffset.toDouble();
    });
  }

  /// Same as [seekToIndex] but accepts a timestamp. Finds the closest
  /// candle whose timestamp is `<=` the given value.
  void seekToTimestamp(int timestamp) {
    if (widget.candles.isEmpty) return;
    int lo = 0, hi = _effectiveLength - 1;
    while (lo < hi) {
      final mid = (lo + hi + 1) ~/ 2;
      if (widget.candles[mid].timestamp <= timestamp) {
        lo = mid;
      } else {
        hi = mid - 1;
      }
    }
    seekToIndex(lo);
  }

  /// Sets the visible candle window. Higher values zoom out, lower
  /// values zoom in. Clamped to the chart's min/max candle width.
  void setVisibleCandleCount(int count) {
    if (_prevChartWidth == null) return;
    final w = _prevChartWidth!;
    final newCandleWidth = (w / count).clamp(
      _getMinCandleWidth(w),
      _getMaxCandleWidth(w),
    );
    setState(() {
      _candleWidth = newCandleWidth.toDouble();
      _startOffset = _startOffset
          .clamp(0, _getMaxStartOffset(w, _candleWidth))
          .toDouble();
    });
  }
  
  /// Reset vertical zoom to fit candles to screen (no padding)
  void resetVerticalZoom() {
    setState(() {
      _verticalZoomFactor = 1.0;
    });
  }
  
  /// Reset vertical pan to center position
  void resetVerticalPan() {
    setState(() {
      _verticalPanOffset = 0.0;
    });
  }
  
  /// Reset both vertical zoom and pan
  void resetVerticalView() {
    setState(() {
      _verticalZoomFactor = 1.0;
      _verticalPanOffset = 0.0;
    });
  }
  
  /// Set vertical zoom factor programmatically
  /// - 1.0 = fit to screen (no padding)
  /// - >1.0 = zoomed out (adds padding)
  /// - <1.0 = zoomed in (crops view)
  void setVerticalZoom(double factor) {
    setState(() {
      _verticalZoomFactor = factor.clamp(0.5, 3.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final size = constraints.biggest;
        final w = size.width - widget.style.priceLabelWidth;
        _handleResize(w);
        
        // Check if new candles were added to the beginning of the list
        if (_prevCandlesLength != null && 
            widget.candles.length > _prevCandlesLength!) {
          final candlesAdded = widget.candles.length - _prevCandlesLength!;
          // Adjust offset to maintain visual position
          _startOffset += candlesAdded * _candleWidth;
        }
        _prevCandlesLength = widget.candles.length;

        // Find the visible data range. In replay mode the effective
        // length stops at the playhead — we never render or include
        // candles past it.
        final int effLen = _effectiveLength;

        // Defensive clamp: in replay mode a shrinking effective
        // length (after a backwards scrub) can leave _startOffset
        // pointing past the new max. Re-clamp every build so the
        // visible window never falls off the right edge.
        final maxOff = _getMaxStartOffset(w, _candleWidth);
        if (_startOffset > maxOff) _startOffset = maxOff;

        final int start = (_startOffset / _candleWidth).floor().clamp(0, max(0, effLen - 1));
        final int count = (w / _candleWidth).ceil();
        final int end = (start + count).clamp(start, effLen);

        // Notify offset change if callback is provided
        _notifyOffsetChanged(start, end);

        final candlesInRange = widget.candles.getRange(start, end).toList();
        if (end < effLen) {
          // Put in an extra item, since it can become visible when scrolling
          final nextItem = widget.candles[end];
          candlesInRange.add(nextItem);
        }

        // Tick-replay: replace the candle at the playhead with a
        // partial candle that interpolates from open → close as
        // [playheadTickProgress] goes 0 → 1.
        if (widget.playheadIndex != null &&
            widget.playheadTickProgress != null &&
            widget.playheadTickProgress! < 1.0) {
          final phRel = widget.playheadIndex! - start;
          if (phRel >= 0 && phRel < candlesInRange.length) {
            candlesInRange[phRel] = CandleData.buildPartial(
              widget.candles[widget.playheadIndex!],
              widget.playheadTickProgress!,
            );
          }
        }

        // If possible, find neighbouring trend line data,
        // so the chart could draw better-connected lines
        final leadingTrends = widget.candles.at(start - 1)?.trends;
        final trailingTrends =
            (end + 1 < effLen) ? widget.candles.at(end + 1)?.trends : null;

        // Find the horizontal shift needed when drawing the candles.
        // First, always shift the chart by half a candle, because when we
        // draw a line using a thick paint, it spreads to both sides.
        // Then, we find out how much "fraction" of a candle is visible, since
        // when users scroll, they don't always stop at exact intervals.
        final halfCandle = _candleWidth / 2;
        final fractionCandle = _startOffset - start * _candleWidth;
        final xShift = halfCandle - fractionCandle;

        // Calculate min and max among the visible data
        double? highest(CandleData c) {
          if (c.high != null) return c.high;
          if (c.open != null && c.close != null) return max(c.open!, c.close!);
          return c.open ?? c.close;
        }

        double? lowest(CandleData c) {
          if (c.low != null) return c.low;
          if (c.open != null && c.close != null) return min(c.open!, c.close!);
          return c.open ?? c.close;
        }

        // Handle case when no candles are visible (free camera beyond data)
        final priceValues = candlesInRange.map(highest).whereType<double>();
        var maxPrice = priceValues.isNotEmpty 
            ? priceValues.reduce(max)
            : 100.0; // Default value when no data visible
        
        final lowValues = candlesInRange.map(lowest).whereType<double>();
        var minPrice = lowValues.isNotEmpty
            ? lowValues.reduce(min)
            : 0.0; // Default value when no data visible
        
        // Apply vertical zoom and pan (only if enabled)
        if (widget.enableVerticalPan) {
          // Zoom factor > 1.0 adds padding (zooms out), < 1.0 zooms in
          final priceRange = maxPrice - minPrice;
          final paddingFactor = (_verticalZoomFactor - 1.0) / 2.0; // Split padding top/bottom
          final padding = priceRange * paddingFactor;
          
          maxPrice = maxPrice + padding - _verticalPanOffset;
          minPrice = minPrice - padding - _verticalPanOffset;
        }
        
        final maxVol = candlesInRange
            .map((c) => c.volume)
            .whereType<double>()
            .fold(double.negativeInfinity, max);
        final minVol = candlesInRange
            .map((c) => c.volume)
            .whereType<double>()
            .fold(double.infinity, min);

        // The playhead index passed to PainterParams is the index
        // INSIDE [candlesInRange] (the visible sublist). When the
        // playhead falls outside the visible window we pass null so
        // the painter does not draw anything. The host can surface a
        // "playhead at <date>" hint outside the chart in that case.
        int? phRelInVisible;
        if (widget.playheadIndex != null) {
          final rel = widget.playheadIndex! - start;
          if (rel >= 0 && rel < candlesInRange.length) {
            phRelInVisible = rel;
          }
        }

        final child = TweenAnimationBuilder(
          tween: PainterParamsTween(
            end: PainterParams(
              candles: candlesInRange,
              fullCandles: widget.playheadIndex != null ? widget.candles : null,
              style: widget.style,
              size: size,
              candleWidth: _candleWidth,
              startOffset: _startOffset,
              maxPrice: maxPrice,
              minPrice: minPrice,
              maxVol: maxVol,
              minVol: minVol,
              xShift: xShift,
              tapPosition: _tapPosition,
              leadingTrends: leadingTrends,
              trailingTrends: trailingTrends,
              playheadIndex: phRelInVisible,
              playheadTickProgress: widget.playheadTickProgress,
              playheadStyle: widget.playheadStyle,
            ),
          ),
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
          builder: (_, PainterParams params, __) {
            _prevParams = params;
            return RepaintBoundary(
              child: CustomPaint(
                size: size,
                painter: ChartPainter(
                  params: params,
                  getTimeLabel: widget.timeLabel ?? defaultTimeLabel,
                  getPriceLabel: widget.priceLabel ?? defaultPriceLabel,
                  getOverlayInfo: widget.overlayInfo ?? defaultOverlayInfo,
                  overlays: widget.overlays,
                  indicators: widget.indicators,
                  draggedOverlay: _draggedOverlay,
                  draggedPrice: _dragStartPrice,
                  draggedInitialPrice: _dragInitialPrice,
                  draggedPosition: _dragStartPosition,
                  isResizingTop: _isResizingTop,
                  isResizingBottom: _isResizingBottom,
                  isResizingFibonacci: _isResizingFibonacci,
                  isResizingTrendLine: _isResizingTrendLine,
                  isResizingTrendStart: _isResizingTrendStart,
                  isResizingTrendEnd: _isResizingTrendEnd,
                  isResizingPositionEntry: _isResizingPositionEntry,
                  isResizingPositionSL: _isResizingPositionSL,
                  isResizingPositionTP: _isResizingPositionTP,
                  isDraggingVerticalLine: _isDraggingVerticalLine,
                  isResizingFibExtPointA: _isResizingFibExtPointA,
                  isResizingFibExtPointB: _isResizingFibExtPointB,
                  isResizingFibExtPointC: _isResizingFibExtPointC,
                  isResizingFibFanStart: _isResizingFibFanStart,
                  isResizingFibFanEnd: _isResizingFibFanEnd,
                  isResizingArrowStart: _isResizingArrowStart,
                  isResizingArrowEnd: _isResizingArrowEnd,
                  isResizingCircleCenter: _isResizingCircleCenter,
                  isResizingCircleRadius: _isResizingCircleRadius,
                  isDraggingTextTool: _isDraggingTextTool,
                  isResizingGanttStart: _isResizingGanttStart,
                  isResizingGanttEnd: _isResizingGanttEnd,
                ),
              ),
            );
          },
        );

        final chartWidget = Listener(
          onPointerSignal: (signal) {
            if (signal is PointerScrollEvent) {
              final dy = signal.scrollDelta.dy;
              if (dy.abs() > 0) {
                // Check for modifier keys (only if vertical pan is enabled)
                if (widget.enableVerticalPan) {
                  final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
                  final isAltPressed = HardwareKeyboard.instance.isAltPressed;
                  
                  if (isShiftPressed) {
                    // Shift + Scroll = Vertical Zoom
                    setState(() {
                      final zoomDelta = dy > 0 ? 0.1 : -0.1;
                      _verticalZoomFactor = (_verticalZoomFactor + zoomDelta).clamp(0.5, 3.0);
                    });
                    return; // Don't process as horizontal zoom
                  } else if (isAltPressed) {
                    // Alt + Scroll = Vertical Pan
                    if (_prevParams != null) {
                      final priceRange = _prevParams!.maxPrice - _prevParams!.minPrice;
                      final panDelta = (dy / 100) * priceRange * 0.1;
                      setState(() {
                        _verticalPanOffset += panDelta;
                      });
                    }
                    return; // Don't process as horizontal zoom
                  }
                }
                
                // Normal horizontal zoom
                _onScaleStart(signal.position);
                _onScaleUpdate(
                  dy > 0 ? 0.9 : 1.1,
                  signal.position,
                  w,
                );
              }
            }
          },
          child: GestureDetector(
            // Tap to view candle details or select overlay
            onTapDown: (details) {
              // Crosshair mode: skip all overlay interactions, just place the crosshair.
              if (widget.persistentCrosshair) {
                setState(() {
                  _tapPosition = details.localPosition;
                });
                return;
              }
              // FIRST-FIRST priority: replay playhead. Claim the
              // pointer the moment it lands near the line so the
              // crosshair / tap-to-select / pan flows never run.
              if (_hitTestPlayhead(details.localPosition)) {
                setState(() {
                  _isDraggingPlayhead = true;
                });
                return;
              }
              final params = _prevParams;
              if (params != null) {
                // FIRST: Check all zones and fibonacci for handle hits
                for (final overlay in widget.overlays) {
                  if (overlay is PriceZone && overlay.options.resizable) {
                    if (overlay.hitTestTopHandle(details.localPosition, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.maxPrice;
                        _dragStartPosition = details.localPosition;
                        _originalPrice = overlay.maxPrice;
                        _isResizingTop = true;
                        _isResizingBottom = false;
                        _isResizingFibonacci = false;
                        _hasDragged = false;
                      });
                      return; // Exit early - handle hit
                    } else if (overlay.hitTestBottomHandle(details.localPosition, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.minPrice;
                        _dragStartPosition = details.localPosition;
                        _originalPrice = overlay.minPrice;
                        _isResizingTop = false;
                        _isResizingBottom = true;
                        _isResizingFibonacci = false;
                        _hasDragged = false;
                      });
                      return; // Exit early - handle hit
                    }
                  } else if (overlay is FibonacciRetracement && overlay.options.draggable) {
                    if (overlay.hitTestTopHandle(details.localPosition, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.highPrice;
                        _dragStartPosition = details.localPosition;
                        _originalPrice = overlay.highPrice;
                        _isResizingTop = true;
                        _isResizingBottom = false;
                        _isResizingFibonacci = true;
                        _hasDragged = false;
                      });
                      return; // Exit early - handle hit
                    } else if (overlay.hitTestBottomHandle(details.localPosition, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.lowPrice;
                        _dragStartPosition = details.localPosition;
                        _originalPrice = overlay.lowPrice;
                        _isResizingTop = false;
                        _isResizingBottom = true;
                        _isResizingFibonacci = true;
                        _hasDragged = false;
                      });
                      return; // Exit early - handle hit
                    }
                  } else if (overlay is TrendLine && overlay.options.draggable) {
                    if (overlay.hitTestStartHandle(details.localPosition, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.startPrice;
                        _dragStartPosition = details.localPosition;
                        _originalPrice = overlay.startPrice;
                        _isResizingTrendLine = true;
                        _isResizingTrendStart = true;
                        _isResizingTrendEnd = false;
                        _hasDragged = false;
                      });
                      return; // Exit early - handle hit
                    } else if (overlay.hitTestEndHandle(details.localPosition, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.endPrice;
                        _dragStartPosition = details.localPosition;
                        _originalPrice = overlay.endPrice;
                        _isResizingTrendLine = true;
                        _isResizingTrendStart = false;
                        _isResizingTrendEnd = true;
                        _hasDragged = false;
                      });
                      return; // Exit early - handle hit
                    }
                  } else if (overlay is RulerTool && overlay.options.draggable) {
                    // RulerTool handle detection (same as TrendLine)
                    if (overlay.hitTestStartHandle(details.localPosition, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.startPrice;
                        _dragStartPosition = details.localPosition;
                        _originalPrice = overlay.startPrice;
                        _isResizingTrendLine = true;
                        _isResizingTrendStart = true;
                        _isResizingTrendEnd = false;
                        _hasDragged = false;
                      });
                      return; // Exit early - handle hit
                    } else if (overlay.hitTestEndHandle(details.localPosition, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.endPrice;
                        _dragStartPosition = details.localPosition;
                        _originalPrice = overlay.endPrice;
                        _isResizingTrendLine = true;
                        _isResizingTrendStart = false;
                        _isResizingTrendEnd = true;
                        _hasDragged = false;
                      });
                      return; // Exit early - handle hit
                    }
                  } else if (overlay is PositionTool && overlay.options.draggable) {
                    // PositionTool line detection
                    if (overlay.hitTestEntryLine(details.localPosition, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.entryPrice;
                        _originalPrice = overlay.entryPrice;
                        _isResizingPositionEntry = true;
                        _isResizingPositionSL = false;
                        _isResizingPositionTP = false;
                        _hasDragged = false;
                      });
                      return; // Exit early - line hit
                    } else if (overlay.hitTestStopLossLine(details.localPosition, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.stopLossPrice;
                        _originalPrice = overlay.stopLossPrice;
                        _isResizingPositionEntry = false;
                        _isResizingPositionSL = true;
                        _isResizingPositionTP = false;
                        _hasDragged = false;
                      });
                      return; // Exit early - line hit
                    } else if (overlay.hitTestTakeProfitLine(details.localPosition, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.takeProfitPrice;
                        _originalPrice = overlay.takeProfitPrice;
                        _isResizingPositionEntry = false;
                        _isResizingPositionSL = false;
                        _isResizingPositionTP = true;
                        _hasDragged = false;
                      });
                      return; // Exit early - line hit
                    }
                  } else if (overlay is VerticalLine && overlay.options.draggable) {
                    // VerticalLine detection
                    if (overlay.hitTest(details.localPosition, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPosition = details.localPosition;
                        _isDraggingVerticalLine = true;
                        _hasDragged = false;
                      });
                      return; // Exit early - line hit
                    }
                  } else if (overlay is FibonacciExtension && overlay.options.draggable) {
                    // FibonacciExtension point detection
                    if (overlay.hitTestPointA(details.localPosition, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.pointAPrice;
                        _dragStartPosition = details.localPosition;
                        _isResizingFibExtPointA = true;
                        _isResizingFibExtPointB = false;
                        _isResizingFibExtPointC = false;
                        _hasDragged = false;
                      });
                      return;
                    } else if (overlay.hitTestPointB(details.localPosition, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.pointBPrice;
                        _dragStartPosition = details.localPosition;
                        _isResizingFibExtPointA = false;
                        _isResizingFibExtPointB = true;
                        _isResizingFibExtPointC = false;
                        _hasDragged = false;
                      });
                      return;
                    } else if (overlay.hitTestPointC(details.localPosition, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.pointCPrice;
                        _dragStartPosition = details.localPosition;
                        _isResizingFibExtPointA = false;
                        _isResizingFibExtPointB = false;
                        _isResizingFibExtPointC = true;
                        _hasDragged = false;
                      });
                      return;
                    }
                  } else if (overlay is FibonacciFan && overlay.options.draggable) {
                    // FibonacciFan point detection
                    if (overlay.hitTestStartPoint(details.localPosition, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.startPrice;
                        _dragStartPosition = details.localPosition;
                        _isResizingFibFanStart = true;
                        _isResizingFibFanEnd = false;
                        _hasDragged = false;
                      });
                      return;
                    } else if (overlay.hitTestEndPoint(details.localPosition, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.endPrice;
                        _dragStartPosition = details.localPosition;
                        _isResizingFibFanStart = false;
                        _isResizingFibFanEnd = true;
                        _hasDragged = false;
                      });
                      return;
                    }
                  } else if (overlay is ArrowTool && overlay.options.draggable) {
                    // ArrowTool point detection
                    if (overlay.hitTestStartHandle(details.localPosition, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.startPrice;
                        _dragStartPosition = details.localPosition;
                        _isResizingArrowStart = true;
                        _isResizingArrowEnd = false;
                        _hasDragged = false;
                      });
                      return;
                    } else if (overlay.hitTestEndHandle(details.localPosition, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.endPrice;
                        _dragStartPosition = details.localPosition;
                        _isResizingArrowStart = false;
                        _isResizingArrowEnd = true;
                        _hasDragged = false;
                      });
                      return;
                    }
                  } else if (overlay is CircleTool && overlay.options.draggable) {
                    // CircleTool handle detection
                    if (overlay.hitTestCenterHandle(details.localPosition, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.centerPrice;
                        _dragStartPosition = details.localPosition;
                        _isResizingCircleCenter = true;
                        _isResizingCircleRadius = false;
                        _hasDragged = false;
                      });
                      return;
                    } else if (overlay.hitTestRadiusHandle(details.localPosition, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.centerPrice;
                        _dragStartPosition = details.localPosition;
                        _isResizingCircleCenter = false;
                        _isResizingCircleRadius = true;
                        _hasDragged = false;
                      });
                      return;
                    }
                  } else if (overlay is TextTool && overlay.options.draggable) {
                    // TextTool detection
                    if (overlay.hitTest(details.localPosition, params)) {
                      // Check for double tap to edit
                      final now = DateTime.now();
                      final isDoubleTap = _lastTapTime != null &&
                          now.difference(_lastTapTime!).inMilliseconds < 300 &&
                          _lastTapPosition != null &&
                          (details.localPosition - _lastTapPosition!).distance < 20;
                      
                      if (isDoubleTap && overlay.options.onEdit != null) {
                        // Double tap detected - trigger edit
                        _lastTapTime = null;
                        _lastTapPosition = null;
                        overlay.options.onEdit!(overlay.text);
                        return;
                      }
                      
                      // Single tap - prepare for drag
                      _lastTapTime = now;
                      _lastTapPosition = details.localPosition;
                      
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.price;
                        _dragStartPosition = details.localPosition;
                        _isDraggingTextTool = true;
                        _hasDragged = false;
                      });
                      return;
                    }
                  } else if (overlay is GanttTool && overlay.options.draggable) {
                    // GanttTool handle detection
                    if (overlay.hitTestStartHandle(details.localPosition, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.price;
                        _dragStartPosition = details.localPosition;
                        _isResizingGanttStart = true;
                        _isResizingGanttEnd = false;
                        _hasDragged = false;
                      });
                      return;
                    } else if (overlay.hitTestEndHandle(details.localPosition, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.price;
                        _dragStartPosition = details.localPosition;
                        _isResizingGanttStart = false;
                        _isResizingGanttEnd = true;
                        _hasDragged = false;
                      });
                      return;
                    }
                  }
                }
                
                // SECOND: Check for regular overlay hit
                final tappedOverlay = _findTappedOverlay(details.localPosition, params);
                if (tappedOverlay != null) {
                  // Regular drag (not resizing)
                  if (tappedOverlay is PriceZone && tappedOverlay.options.draggable) {
                    setState(() {
                      _draggedOverlay = tappedOverlay;
                      _dragStartPrice = params.getPriceFromY(details.localPosition.dy);
                      _dragInitialPrice = params.getPriceFromY(details.localPosition.dy);
                      _dragStartPosition = details.localPosition;
                      _hasDragged = false;
                      _isResizingTop = false;
                      _isResizingBottom = false;
                      _isResizingFibonacci = false;
                    });
                  } else if (tappedOverlay is TradingLine) {
                    setState(() {
                      _draggedOverlay = tappedOverlay;
                      _dragStartPrice = params.getPriceFromY(details.localPosition.dy);
                      _originalPrice = tappedOverlay.price;
                      _hasDragged = false;
                      _isResizingTop = false;
                      _isResizingBottom = false;
                      _isResizingFibonacci = false;
                    });
                  } else if (tappedOverlay is FibonacciRetracement) {
                    setState(() {
                      _draggedOverlay = tappedOverlay;
                      _dragStartPrice = params.getPriceFromY(details.localPosition.dy);
                      _dragInitialPrice = params.getPriceFromY(details.localPosition.dy);
                      _dragStartPosition = details.localPosition;
                      _hasDragged = false;
                      _isResizingTop = false;
                      _isResizingBottom = false;
                      _isResizingFibonacci = false;
                      _isResizingTrendLine = false;
                    });
                  } else if (tappedOverlay is TrendLine) {
                    setState(() {
                      _draggedOverlay = tappedOverlay;
                      _dragStartPrice = params.getPriceFromY(details.localPosition.dy);
                      _dragInitialPrice = params.getPriceFromY(details.localPosition.dy);
                      _dragStartPosition = details.localPosition;
                      _hasDragged = false;
                      _isResizingTop = false;
                      _isResizingBottom = false;
                      _isResizingFibonacci = false;
                      _isResizingTrendLine = false;
                    });
                  }
                  return;
                }
              }
              // Capture the tap position for the host's onTap callback
              // unconditionally — independent of the OHLC crosshair
              // overlay (which is what [enableInteraction] gates).
              _lastTapDownPosition = details.localPosition;
              // Only show the overlay info / crosshair when the host
              // opted into the tap interaction feature.
              if (widget.enableInteraction) {
                setState(() {
                  _tapPosition = details.localPosition;
                });
              }
            },
            onTapUp: (_) {
              // Crosshair mode: keep the crosshair where the user placed it.
              if (widget.persistentCrosshair) {
                return;
              }
              // Replay: the user tapped on (or near) the playhead but
              // did not drag. Clear the latch and avoid firing onTap.
              if (_isDraggingPlayhead) {
                setState(() {
                  _isDraggingPlayhead = false;
                });
                return;
              }
              // If overlay was selected but not dragged, fire its onTap callback and deselect it
              if (_draggedOverlay != null && !_hasDragged) {
                _maybeFireOverlayTap();
                setState(() {
                  _draggedOverlay = null;
                  _dragStartPrice = null;
                  _dragInitialPrice = null;
                  _originalPrice = null;
                  _hasDragged = false;
                });
              } else if (_draggedOverlay == null && widget.onTap != null) {
                _fireOnTapEvent();
              }
              // Clear tap position if interaction is enabled, unless the crosshair should persist.
              if (widget.enableInteraction && !widget.persistentCrosshair) {
                setState(() {
                  _tapPosition = null;
                });
              }
            },
            // Scale for both zoom and overlay dragging
            onScaleStart: (details) {
              // Crosshair mode: track the finger as the crosshair position; skip zoom/pan/overlay drag.
              if (widget.persistentCrosshair) {
                setState(() {
                  _tapPosition = details.localFocalPoint;
                });
                return;
              }
              // Pinch (multi-finger) gestures ALWAYS pan/zoom — they
              // never drag overlays. If onTapDown captured one with a
              // single touch, release it now so the gesture flows to
              // the normal pan/zoom path.
              if (details.pointerCount > 1) {
                if (_draggedOverlay != null) {
                  setState(() {
                    _draggedOverlay = null;
                    _dragStartPrice = null;
                    _dragInitialPrice = null;
                    _originalPrice = null;
                    _hasDragged = false;
                    _isResizingTop = false;
                    _isResizingBottom = false;
                    _isResizingFibonacci = false;
                    _isResizingTrendLine = false;
                  });
                }
                _onScaleStart(details.localFocalPoint);
                return;
              }
              // FIRST-FIRST priority: replay playhead drag. It sits
              // on top of all overlays and consumes the gesture before
              // any other hit-testing runs. Only claim single-finger
              // gestures so pinch-zoom is unaffected.
              //
              // The flag may already be set by onTapDown — in that
              // case we just need to keep the latch and skip the
              // overlay hit-tests below.
              if (_isDraggingPlayhead) return;
              if (details.pointerCount == 1 &&
                  _hitTestPlayhead(details.localFocalPoint)) {
                setState(() {
                  _isDraggingPlayhead = true;
                });
                return;
              }
              final params = _prevParams;
              if (params != null) {
                // FIRST: Check all zones and fibonacci for handle hits
                for (final overlay in widget.overlays) {
                  if (overlay is PriceZone && overlay.options.resizable) {
                    if (overlay.hitTestTopHandle(details.localFocalPoint, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.maxPrice;
                        _originalPrice = overlay.maxPrice;
                        _isResizingTop = true;
                        _isResizingBottom = false;
                        _isResizingFibonacci = false;
                        _hasDragged = false;
                      });
                      return; // Exit early - handle hit
                    } else if (overlay.hitTestBottomHandle(details.localFocalPoint, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.minPrice;
                        _originalPrice = overlay.minPrice;
                        _isResizingTop = false;
                        _isResizingBottom = true;
                        _isResizingFibonacci = false;
                        _hasDragged = false;
                      });
                      return; // Exit early - handle hit
                    }
                  } else if (overlay is FibonacciRetracement && overlay.options.draggable) {
                    if (overlay.hitTestTopHandle(details.localFocalPoint, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.highPrice;
                        _originalPrice = overlay.highPrice;
                        _isResizingTop = true;
                        _isResizingBottom = false;
                        _isResizingFibonacci = true;
                        _hasDragged = false;
                      });
                      return; // Exit early - handle hit
                    } else if (overlay.hitTestBottomHandle(details.localFocalPoint, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.lowPrice;
                        _originalPrice = overlay.lowPrice;
                        _isResizingTop = false;
                        _isResizingBottom = true;
                        _isResizingFibonacci = true;
                        _hasDragged = false;
                      });
                      return; // Exit early - handle hit
                    }
                  } else if (overlay is TrendLine && overlay.options.draggable) {
                    if (overlay.hitTestStartHandle(details.localFocalPoint, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.startPrice;
                        _dragStartPosition = details.localFocalPoint;
                        _originalPrice = overlay.startPrice;
                        _isResizingTrendLine = true;
                        _isResizingTrendStart = true;
                        _isResizingTrendEnd = false;
                        _hasDragged = false;
                      });
                      return; // Exit early - handle hit
                    } else if (overlay.hitTestEndHandle(details.localFocalPoint, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.endPrice;
                        _dragStartPosition = details.localFocalPoint;
                        _originalPrice = overlay.endPrice;
                        _isResizingTrendLine = true;
                        _isResizingTrendStart = false;
                        _isResizingTrendEnd = true;
                        _hasDragged = false;
                      });
                      return; // Exit early - handle hit
                    }
                  } else if (overlay is RulerTool && overlay.options.draggable) {
                    // RulerTool handle detection (same as TrendLine)
                    if (overlay.hitTestStartHandle(details.localFocalPoint, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.startPrice;
                        _dragStartPosition = details.localFocalPoint;
                        _originalPrice = overlay.startPrice;
                        _isResizingTrendLine = true;
                        _isResizingTrendStart = true;
                        _isResizingTrendEnd = false;
                        _hasDragged = false;
                      });
                      return; // Exit early - handle hit
                    } else if (overlay.hitTestEndHandle(details.localFocalPoint, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.endPrice;
                        _dragStartPosition = details.localFocalPoint;
                        _originalPrice = overlay.endPrice;
                        _isResizingTrendLine = true;
                        _isResizingTrendStart = false;
                        _isResizingTrendEnd = true;
                        _hasDragged = false;
                      });
                      return; // Exit early - handle hit
                    }
                  } else if (overlay is PositionTool && overlay.options.draggable) {
                    // PositionTool line detection
                    if (overlay.hitTestEntryLine(details.localFocalPoint, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.entryPrice;
                        _originalPrice = overlay.entryPrice;
                        _isResizingPositionEntry = true;
                        _isResizingPositionSL = false;
                        _isResizingPositionTP = false;
                        _hasDragged = false;
                      });
                      return; // Exit early - line hit
                    } else if (overlay.hitTestStopLossLine(details.localFocalPoint, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.stopLossPrice;
                        _originalPrice = overlay.stopLossPrice;
                        _isResizingPositionEntry = false;
                        _isResizingPositionSL = true;
                        _isResizingPositionTP = false;
                        _hasDragged = false;
                      });
                      return; // Exit early - line hit
                    } else if (overlay.hitTestTakeProfitLine(details.localFocalPoint, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.takeProfitPrice;
                        _originalPrice = overlay.takeProfitPrice;
                        _isResizingPositionEntry = false;
                        _isResizingPositionSL = false;
                        _isResizingPositionTP = true;
                        _hasDragged = false;
                      });
                      return; // Exit early - line hit
                    }
                  } else if (overlay is VerticalLine && overlay.options.draggable) {
                    // VerticalLine detection
                    if (overlay.hitTest(details.localFocalPoint, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPosition = details.localFocalPoint;
                        _isDraggingVerticalLine = true;
                        _hasDragged = false;
                      });
                      return; // Exit early - line hit
                    }
                  } else if (overlay is FibonacciExtension && overlay.options.draggable) {
                    // FibonacciExtension point detection
                    if (overlay.hitTestPointA(details.localFocalPoint, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.pointAPrice;
                        _dragStartPosition = details.localFocalPoint;
                        _isResizingFibExtPointA = true;
                        _isResizingFibExtPointB = false;
                        _isResizingFibExtPointC = false;
                        _hasDragged = false;
                      });
                      return;
                    } else if (overlay.hitTestPointB(details.localFocalPoint, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.pointBPrice;
                        _dragStartPosition = details.localFocalPoint;
                        _isResizingFibExtPointA = false;
                        _isResizingFibExtPointB = true;
                        _isResizingFibExtPointC = false;
                        _hasDragged = false;
                      });
                      return;
                    } else if (overlay.hitTestPointC(details.localFocalPoint, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.pointCPrice;
                        _dragStartPosition = details.localFocalPoint;
                        _isResizingFibExtPointA = false;
                        _isResizingFibExtPointB = false;
                        _isResizingFibExtPointC = true;
                        _hasDragged = false;
                      });
                      return;
                    }
                  } else if (overlay is FibonacciFan && overlay.options.draggable) {
                    // FibonacciFan point detection
                    if (overlay.hitTestStartPoint(details.localFocalPoint, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.startPrice;
                        _dragStartPosition = details.localFocalPoint;
                        _isResizingFibFanStart = true;
                        _isResizingFibFanEnd = false;
                        _hasDragged = false;
                      });
                      return;
                    } else if (overlay.hitTestEndPoint(details.localFocalPoint, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.endPrice;
                        _dragStartPosition = details.localFocalPoint;
                        _isResizingFibFanStart = false;
                        _isResizingFibFanEnd = true;
                        _hasDragged = false;
                      });
                      return;
                    }
                  } else if (overlay is ArrowTool && overlay.options.draggable) {
                    // ArrowTool point detection
                    if (overlay.hitTestStartHandle(details.localFocalPoint, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.startPrice;
                        _dragStartPosition = details.localFocalPoint;
                        _isResizingArrowStart = true;
                        _isResizingArrowEnd = false;
                        _hasDragged = false;
                      });
                      return;
                    } else if (overlay.hitTestEndHandle(details.localFocalPoint, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.endPrice;
                        _dragStartPosition = details.localFocalPoint;
                        _isResizingArrowStart = false;
                        _isResizingArrowEnd = true;
                        _hasDragged = false;
                      });
                      return;
                    }
                  } else if (overlay is CircleTool && overlay.options.draggable) {
                    // CircleTool handle detection
                    if (overlay.hitTestCenterHandle(details.localFocalPoint, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.centerPrice;
                        _dragStartPosition = details.localFocalPoint;
                        _isResizingCircleCenter = true;
                        _isResizingCircleRadius = false;
                        _hasDragged = false;
                      });
                      return;
                    } else if (overlay.hitTestRadiusHandle(details.localFocalPoint, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.centerPrice;
                        _dragStartPosition = details.localFocalPoint;
                        _isResizingCircleCenter = false;
                        _isResizingCircleRadius = true;
                        _hasDragged = false;
                      });
                      return;
                    }
                  } else if (overlay is TextTool && overlay.options.draggable) {
                    // TextTool detection
                    if (overlay.hitTest(details.localFocalPoint, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.price;
                        _dragStartPosition = details.localFocalPoint;
                        _isDraggingTextTool = true;
                        _hasDragged = false;
                      });
                      return;
                    }
                  } else if (overlay is GanttTool && overlay.options.draggable) {
                    // GanttTool handle detection
                    if (overlay.hitTestStartHandle(details.localFocalPoint, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.price;
                        _dragStartPosition = details.localFocalPoint;
                        _isResizingGanttStart = true;
                        _isResizingGanttEnd = false;
                        _hasDragged = false;
                      });
                      return;
                    } else if (overlay.hitTestEndHandle(details.localFocalPoint, params)) {
                      setState(() {
                        _draggedOverlay = overlay;
                        _dragStartPrice = overlay.price;
                        _dragStartPosition = details.localFocalPoint;
                        _isResizingGanttStart = false;
                        _isResizingGanttEnd = true;
                        _hasDragged = false;
                      });
                      return;
                    }
                  }
                }
                
                // SECOND: Check for regular overlay hit
                final tappedOverlay = _findTappedOverlay(details.localFocalPoint, params);
                if (tappedOverlay != null) {
                  // Regular drag (not resizing)
                  if (tappedOverlay is PriceZone && tappedOverlay.options.draggable) {
                    setState(() {
                      _draggedOverlay = tappedOverlay;
                      _dragStartPrice = params.getPriceFromY(details.localFocalPoint.dy);
                      _dragInitialPrice = params.getPriceFromY(details.localFocalPoint.dy);
                      _hasDragged = false;
                      _isResizingTop = false;
                      _isResizingBottom = false;
                      _isResizingFibonacci = false;
                    });
                  } else if (tappedOverlay is TradingLine) {
                    setState(() {
                      _draggedOverlay = tappedOverlay;
                      _dragStartPrice = params.getPriceFromY(details.localFocalPoint.dy);
                      _originalPrice = tappedOverlay.price;
                      _hasDragged = false;
                      _isResizingTop = false;
                      _isResizingBottom = false;
                      _isResizingFibonacci = false;
                    });
                  } else if (tappedOverlay is FibonacciRetracement) {
                    setState(() {
                      _draggedOverlay = tappedOverlay;
                      _dragStartPrice = params.getPriceFromY(details.localFocalPoint.dy);
                      _dragInitialPrice = params.getPriceFromY(details.localFocalPoint.dy);
                      _hasDragged = false;
                      _isResizingTop = false;
                      _isResizingBottom = false;
                      _isResizingFibonacci = false;
                      _isResizingTrendLine = false;
                    });
                  } else if (tappedOverlay is TrendLine) {
                    setState(() {
                      _draggedOverlay = tappedOverlay;
                      _dragStartPrice = params.getPriceFromY(details.localFocalPoint.dy);
                      _dragInitialPrice = params.getPriceFromY(details.localFocalPoint.dy);
                      _dragStartPosition = details.localFocalPoint;
                      _hasDragged = false;
                      _isResizingTop = false;
                      _isResizingBottom = false;
                      _isResizingFibonacci = false;
                      _isResizingTrendLine = false;
                    });
                  }
                  return;
                }
              }
              
              // Normal zoom/pan
              _onScaleStart(details.localFocalPoint);
            },
            onScaleUpdate: (details) {
              // Crosshair mode: move the crosshair with the finger.
              if (widget.persistentCrosshair) {
                setState(() {
                  _tapPosition = details.localFocalPoint;
                });
                return;
              }
              if (_isDraggingPlayhead) {
                _onPlayheadDrag(details.localFocalPoint);
                return;
              }
              // Pinch (two or more fingers) ALWAYS pans/zooms even
              // if a single-finger tap previously captured an overlay
              // (e.g. user puts finger on an SL line then lands a
              // second finger to pinch-zoom).
              if (details.pointerCount > 1 && _draggedOverlay != null) {
                setState(() {
                  _draggedOverlay = null;
                  _dragStartPrice = null;
                  _dragInitialPrice = null;
                  _originalPrice = null;
                  _hasDragged = false;
                  _isResizingTop = false;
                  _isResizingBottom = false;
                  _isResizingFibonacci = false;
                  _isResizingTrendLine = false;
                });
                _onScaleStart(details.localFocalPoint);
              }
              if (_draggedOverlay != null) {
                // Direction-aware drag commit. SL/TP/entry lines are
                // semantically VERTICAL drags (price changes); pan
                // gestures across the chart are predominantly
                // horizontal. Below a small deadband we ignore the
                // motion entirely; once we cross it, the larger axis
                // decides whether we commit to a drag or release the
                // overlay and treat the gesture as a pan.
                if (!_hasDragged) {
                  final start = _dragStartPosition ?? _initialFocalPoint;
                  if (start != null) {
                    final dx = (details.localFocalPoint.dx - start.dx).abs();
                    final dy = (details.localFocalPoint.dy - start.dy).abs();
                    const deadband = 6.0;
                    if (dx < deadband && dy < deadband) {
                      return; // wait for a more decisive movement
                    }
                    // Horizontal-dominant: user is panning, not
                    // editing a price line. Release the overlay and
                    // forward to the pan/zoom path.
                    if (dx > dy * 1.3) {
                      setState(() {
                        _draggedOverlay = null;
                        _dragStartPrice = null;
                        _dragInitialPrice = null;
                        _originalPrice = null;
                        _hasDragged = false;
                        _isResizingTop = false;
                        _isResizingBottom = false;
                        _isResizingFibonacci = false;
                        _isResizingTrendLine = false;
                      });
                      _onScaleStart(details.localFocalPoint);
                      _onScaleUpdate(
                        details.scale,
                        details.localFocalPoint,
                        w,
                      );
                      return;
                    }
                  }
                }
                _hasDragged = true;
                _onOverlayDrag(details.localFocalPoint);
              } else {
                // Normal zoom/pan
                _onScaleUpdate(details.scale, details.localFocalPoint, w);
              }
            },
            onScaleEnd: (details) {
              // Crosshair mode: keep the crosshair at its last position.
              if (widget.persistentCrosshair) {
                return;
              }
              if (_isDraggingPlayhead) {
                setState(() {
                  _isDraggingPlayhead = false;
                });
                return;
              }
              if (_draggedOverlay != null) {
                // Call drag end if user actually dragged
                if (_hasDragged && _dragStartPrice != null) {
                  if (_draggedOverlay is TradingLine && _originalPrice != null) {
                    // For TradingLine, check if price changed significantly
                    if ((_dragStartPrice! - _originalPrice!).abs() > 0.01) {
                      _onOverlayDragEnd();
                      return; // _onOverlayDragEnd already calls setState
                    }
                  } else if (_draggedOverlay is PriceZone) {
                    // For PriceZone, always call if dragged
                    _onOverlayDragEnd();
                    return; // _onOverlayDragEnd already calls setState
                  } else if (_draggedOverlay is FibonacciRetracement) {
                    // For Fibonacci, always call if dragged
                    _onOverlayDragEnd();
                    return; // _onOverlayDragEnd already calls setState
                  } else if (_draggedOverlay is TrendLine) {
                    // For TrendLine, always call if dragged
                    _onOverlayDragEnd();
                    return; // _onOverlayDragEnd already calls setState
                  } else if (_draggedOverlay is PositionTool) {
                    // For PositionTool, always call if dragged
                    _onOverlayDragEnd();
                    return; // _onOverlayDragEnd already calls setState
                  } else if (_draggedOverlay is RulerTool) {
                    // For RulerTool, always call if dragged
                    _onOverlayDragEnd();
                    return; // _onOverlayDragEnd already calls setState
                  } else if (_draggedOverlay is VerticalLine) {
                    // For VerticalLine, always call if dragged
                    _onOverlayDragEnd();
                    return; // _onOverlayDragEnd already calls setState
                  } else if (_draggedOverlay is FibonacciExtension) {
                    // For FibonacciExtension, always call if dragged
                    _onOverlayDragEnd();
                    return; // _onOverlayDragEnd already calls setState
                  } else if (_draggedOverlay is FibonacciFan) {
                    // For FibonacciFan, always call if dragged
                    _onOverlayDragEnd();
                    return; // _onOverlayDragEnd already calls setState
                  } else if (_draggedOverlay is ArrowTool) {
                    // For ArrowTool, always call if dragged
                    _onOverlayDragEnd();
                    return; // _onOverlayDragEnd already calls setState
                  } else if (_draggedOverlay is CircleTool) {
                    // For CircleTool, always call if dragged
                    _onOverlayDragEnd();
                    return; // _onOverlayDragEnd already calls setState
                  } else if (_draggedOverlay is TextTool) {
                    // For TextTool, always call if dragged
                    _onOverlayDragEnd();
                    return; // _onOverlayDragEnd already calls setState
                  } else if (_draggedOverlay is GanttTool) {
                    // For GanttTool, always call if dragged
                    _onOverlayDragEnd();
                    return; // _onOverlayDragEnd already calls setState
                  }
                }
                // Reaching here means an overlay was selected but the gesture didn't
                // qualify as a drag (no movement, or insignificant TradingLine move).
                // Treat it as a tap and fire the overlay's onTap callback.
                _maybeFireOverlayTap();
              }
              // Only clear state if we didn't call _onOverlayDragEnd
              setState(() {
                _draggedOverlay = null;
                _dragStartPrice = null;
                _dragInitialPrice = null;
                _dragStartPosition = null;
                _originalPrice = null;
                _hasDragged = false;
                _isResizingTop = false;
                _isResizingBottom = false;
                _isResizingFibonacci = false;
                _isResizingTrendLine = false;
                _isResizingTrendStart = false;
                _isResizingTrendEnd = false;
              });
            },
            child: widget.showWatermark
                ? Stack(
                    children: [
                      child,
                      Positioned(
                        left: 0,
                        bottom: 25,
                        child: IgnorePointer(
                          child: Opacity(
                            opacity: 0.7,
                            child: Image.asset(
                              'packages/pipsend_charts/assets/img/logo.png',
                              width: 80,
                              height: 20,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : child,
          ),
        );
        
        return chartWidget;
      },
    );
  }

  _onScaleStart(Offset focalPoint) {
    _prevCandleWidth = _candleWidth;
    _prevStartOffset = _startOffset;
    _initialFocalPoint = focalPoint;
    _prevVerticalPanOffset = _verticalPanOffset;
  }

  /// Returns true if [position] is close enough to the playhead line
  /// to capture the gesture. Only true when the playhead is currently
  /// visible, draggable, and configured with a style.
  bool _hitTestPlayhead(Offset position) {
    if (widget.playheadIndex == null) return false;
    final style = widget.playheadStyle;
    if (style == null || !style.draggable) return false;
    if (widget.onPlayheadChanged == null) return false;

    final params = _prevParams;
    if (params == null) return false;

    // Compute the playhead's screen-space X. params.playheadIndex is
    // relative to the visible sublist and is only set when in range.
    final phRel = params.playheadIndex;
    if (phRel == null) return false;

    final phX = phRel * params.candleWidth + params.xShift;
    return (position.dx - phX).abs() <= style.hitRadius &&
        position.dy >= 0 &&
        position.dy <= params.chartHeight;
  }

  /// Convert a finger position into an absolute candle index and fire
  /// the [InteractiveChart.onPlayheadChanged] callback.
  ///
  /// Clamping subtlety: we MUST NOT use `_effectiveLength - 1` as the
  /// upper bound here, because `_effectiveLength` is derived from the
  /// CURRENT playhead — clamping to it would forbid forward movement
  /// entirely. The drag is the act of choosing a new playhead, so the
  /// real bound is the loaded candle buffer, `widget.candles.length - 1`.
  void _onPlayheadDrag(Offset position) {
    final params = _prevParams;
    if (params == null) return;
    final cb = widget.onPlayheadChanged;
    if (cb == null) return;

    // Convert visible-relative X back to an absolute candle index.
    final visibleStart = (params.startOffset / params.candleWidth).floor();
    final relIdxF = (position.dx - params.xShift) / params.candleWidth;
    final absIdxF = relIdxF + visibleStart;
    final clampedIdx = absIdxF
        .round()
        .clamp(0, max(0, widget.candles.length - 1))
        .toInt();

    // Interpolated timestamp for the host's "fine" label.
    final interp = params.getTimestampFromX(position.dx - params.xShift) ??
        widget.candles[clampedIdx].timestamp;
    cb(PlayheadInfo(
      candleIndex: clampedIdx,
      candleTimestamp: widget.candles[clampedIdx].timestamp,
      interpolatedTimestamp: interp,
    ));
  }

  _onScaleUpdate(double scale, Offset focalPoint, double w) {
    // Return early if not initialized
    if (_prevCandleWidth == null || _prevStartOffset == null || _initialFocalPoint == null) {
      return;
    }
    
    // Handle zoom
    final candleWidth = (_prevCandleWidth! * scale)
        .clamp(_getMinCandleWidth(w), _getMaxCandleWidth(w));
    final clampedScale = candleWidth / _prevCandleWidth!;
    var startOffset = _prevStartOffset! * clampedScale;
    // Handle horizontal pan
    final dx = (focalPoint - _initialFocalPoint!).dx * -1;
    startOffset += dx;
    // Adjust pan when zooming
    final double prevCount = w / _prevCandleWidth!;
    final double currCount = w / candleWidth;
    final zoomAdjustment = (currCount - prevCount) * candleWidth;
    final focalPointFactor = focalPoint.dx / w;
    startOffset -= zoomAdjustment * focalPointFactor;
    // Only clamp offset if free camera is disabled
    if (!widget.freeCamera) {
      startOffset = startOffset.clamp(0, _getMaxStartOffset(w, candleWidth));
    }
    
    // Handle vertical pan (when dragging vertically) - only if enabled
    if (widget.enableVerticalPan) {
      final dy = (focalPoint - _initialFocalPoint!).dy;
      if (_prevParams != null && dy.abs() > 5) { // Only pan if significant vertical movement
        final priceRange = _prevParams!.maxPrice - _prevParams!.minPrice;
        final priceHeight = _prevParams!.priceHeight;
        // Convert pixel movement to price movement (inverted for natural scrolling)
        final priceDelta = -(dy / priceHeight) * priceRange;
        _verticalPanOffset = (_prevVerticalPanOffset ?? 0.0) + priceDelta;
      }
    }
    
    // Fire candle width resize event
    if (candleWidth != _candleWidth) {
      widget.onCandleResize?.call(candleWidth);
    }
    // Apply changes
    setState(() {
      _candleWidth = candleWidth;
      _startOffset = startOffset;
    });
  }

  _handleResize(double w) {
    if (w == _prevChartWidth) return;
    if (_prevChartWidth != null) {
      // Re-clamp when size changes (e.g. screen rotation)
      _candleWidth = _candleWidth.clamp(
        _getMinCandleWidth(w),
        _getMaxCandleWidth(w),
      );
      // Only clamp offset if free camera is disabled
      if (!widget.freeCamera) {
        _startOffset = _startOffset.clamp(
          0,
          _getMaxStartOffset(w, _candleWidth),
        );
      }
    } else {
      // Default zoom level. Defaults to a 90 day chart, but configurable.
      // If data is shorter, we use the whole range.
      final count = min(
        _effectiveLength,
        widget.initialVisibleCandleCount,
      );
      _candleWidth = w / count;
      // Default show the latest available data, e.g. the most recent 90 days.
      _startOffset = (_effectiveLength - count) * _candleWidth;
    }
    _prevChartWidth = w;
  }

  // The narrowest candle width, i.e. when drawing all available data points.
  double _getMinCandleWidth(double w) => w / _effectiveLength;

  // The widest candle width, e.g. when drawing 14 day chart
  double _getMaxCandleWidth(double w) => w / min(14, _effectiveLength);

  // Max start offset: how far can we scroll towards the end of the chart
  double _getMaxStartOffset(double w, double candleWidth) {
    final count = w / candleWidth; // visible candles in the window
    final start = _effectiveLength + widget.futureCandles - count;
    return max(0, candleWidth * start);
  }

  String defaultTimeLabel(int timestamp, int visibleDataCount) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp)
        .toIso8601String()
        .split("T")
        .first
        .split("-");

    if (visibleDataCount > 20) {
      // If more than 20 data points are visible, we should show year and month.
      return "${date[0]}-${date[1]}"; // yyyy-mm
    } else {
      // Otherwise, we should show month and date.
      return "${date[1]}-${date[2]}"; // mm-dd
    }
  }

  String defaultPriceLabel(double price) => price.toStringAsFixed(2);

  Map<String, String> defaultOverlayInfo(CandleData candle) {
    final date = intl.DateFormat.yMMMd()
        .format(DateTime.fromMillisecondsSinceEpoch(candle.timestamp));
    return {
      "Date": date,
      "Open": candle.open?.toStringAsFixed(2) ?? "-",
      "High": candle.high?.toStringAsFixed(2) ?? "-",
      "Low": candle.low?.toStringAsFixed(2) ?? "-",
      "Close": candle.close?.toStringAsFixed(2) ?? "-",
      "Volume": candle.volume?.asAbbreviated() ?? "-",
    };
  }

  void _notifyOffsetChanged(int start, int end) {
    if (widget.onXOffsetChanged == null) return;
    
    // Only notify if offset actually changed
    if (_prevOffsetNotified != null && _prevOffsetNotified == _startOffset) {
      return;
    }
    
    _prevOffsetNotified = _startOffset;
    
    final details = XAxisOffsetDetails(
      offset: _startOffset,
      startCandleIndex: start,
      endCandleIndex: end,
      totalCandles: _effectiveLength,
    );
    
    widget.onXOffsetChanged!.call(details);
  }

  void _fireOnTapEvent() {
    // Use the always-captured tap position so hosts get notified of
    // empty-area taps even when [enableInteraction] is false. Fall
    // back to [_tapPosition] for backwards compatibility in case a
    // caller invokes this before any onTapDown.
    final pos = _lastTapDownPosition ?? _tapPosition;
    if (_prevParams == null || pos == null) return;
    final params = _prevParams!;
    final dx = pos.dx;
    final dy = pos.dy;
    final selected = params.getCandleIndexFromOffset(dx);
    final tapPrice = params.getPriceFromY(dy);
    final timestamp = params.getTimestampFromX(dx);

    final TapDetails details;
    if (selected >= 0 && selected < params.candles.length) {
      details = TapDetails(
        candle: params.candles[selected],
        tapPrice: tapPrice,
        candleIndex: selected,
        timestamp: timestamp,
      );
    } else {
      // Tap in future (empty) space — no candle, extrapolated timestamp
      details = TapDetails(
        candle: null,
        tapPrice: tapPrice,
        candleIndex: -1,
        timestamp: timestamp,
      );
    }

    widget.onTap?.call(details);
  }

  ChartOverlay? _findTappedOverlay(Offset position, PainterParams params) {
    // Check overlays in reverse order (top to bottom)
    for (int i = widget.overlays.length - 1; i >= 0; i--) {
      final overlay = widget.overlays[i];
      if (overlay.interactive && overlay.hitTest(position, params)) {
        return overlay;
      }
    }
    return null;
  }

  void _onOverlayDrag(Offset position) {
    if (_draggedOverlay == null || _prevParams == null) return;
    
    final params = _prevParams!;
    final newPrice = params.getPriceFromY(position.dy);
    
    // Call onPriceDragging callback for TradingLine (real-time updates)
    if (_draggedOverlay is TradingLine) {
      final tradingLine = _draggedOverlay as TradingLine;
      tradingLine.options.onPriceDragging?.call(newPrice);
    }
    
    // Store the current price and position for the drag
    _dragStartPrice = newPrice;
    _dragStartPosition = position;
    
    // Trigger rebuild to show visual feedback
    setState(() {});
  }

  void _onOverlayDragEnd() {
    if (_draggedOverlay == null || _prevParams == null || _dragStartPrice == null) return;
    
    // Call the appropriate callback based on overlay type BEFORE setState
    if (_draggedOverlay is TradingLine) {
      final tradingLine = _draggedOverlay as TradingLine;
      tradingLine.options.onPriceChanged?.call(_dragStartPrice!);
    } else if (_draggedOverlay is PriceZone) {
      final priceZone = _draggedOverlay as PriceZone;
      final params = _prevParams!;

      double newMinPrice;
      double newMaxPrice;
      int? newStartTime = priceZone.startTime;
      int? newEndTime = priceZone.endTime;
      final visiblePriceRange = params.maxPrice - params.minPrice;
      final minHeight = visiblePriceRange * 0.001;

      if (_isResizingTop) {
        // Top-left handle: maxPrice + startTime
        newMinPrice = priceZone.minPrice;
        newMaxPrice = _dragStartPrice!;
        if (newMaxPrice < newMinPrice + minHeight) {
          newMaxPrice = newMinPrice + minHeight;
        }
        if (_dragStartPosition != null) {
          newStartTime = params.getTimestampFromX(_dragStartPosition!.dx);
        }
      } else if (_isResizingBottom) {
        // Bottom-right handle: minPrice + endTime
        newMinPrice = _dragStartPrice!;
        newMaxPrice = priceZone.maxPrice;
        if (newMinPrice > newMaxPrice - minHeight) {
          newMinPrice = newMaxPrice - minHeight;
        }
        if (_dragStartPosition != null) {
          newEndTime = params.getTimestampFromX(_dragStartPosition!.dx);
        }
      } else {
        // Regular drag (move entire zone) - both X and Y
        final initialPrice = _dragInitialPrice ?? _dragStartPrice!;
        final offset = _dragStartPrice! - initialPrice;
        newMinPrice = priceZone.minPrice + offset;
        newMaxPrice = priceZone.maxPrice + offset;

        if (_dragStartPosition != null && priceZone.startTime != null) {
          final origStartX = params.fitTimestamp(priceZone.startTime!);
          if (origStartX != null) {
            final deltaX = _dragStartPosition!.dx - origStartX;
            newStartTime = params.getTimestampFromX(origStartX + deltaX);
            if (newStartTime != null && priceZone.endTime != null) {
              final origEndX = params.fitTimestamp(priceZone.endTime!);
              newEndTime = origEndX != null
                  ? params.getTimestampFromX(origEndX + deltaX)
                  : newStartTime + (priceZone.endTime! - priceZone.startTime!);
            }
          }
        }
      }

      priceZone.options.onRangeChanged?.call(newMinPrice, newMaxPrice, newStartTime, newEndTime);
    } else if (_draggedOverlay is FibonacciRetracement) {
      final fibonacci = _draggedOverlay as FibonacciRetracement;
      final params = _prevParams!;
      
      double newHighPrice;
      double newLowPrice;
      
      int? newStartTime = fibonacci.startTime;
      int? newEndTime = fibonacci.endTime;

      if (_isResizingFibonacci) {
        // Resizing a corner handle
        final visiblePriceRange = params.maxPrice - params.minPrice;
        final minHeight = visiblePriceRange * 0.001;

        if (_isResizingTop) {
          // Top-left handle: controls highPrice + startTime
          newHighPrice = _dragStartPrice!;
          newLowPrice = fibonacci.lowPrice;
          if (newHighPrice < newLowPrice + minHeight) {
            newHighPrice = newLowPrice + minHeight;
          }
          if (_dragStartPosition != null) {
            newStartTime = params.getTimestampFromX(_dragStartPosition!.dx);
          }
        } else {
          // Bottom-right handle: controls lowPrice + endTime
          newHighPrice = fibonacci.highPrice;
          newLowPrice = _dragStartPrice!;
          if (newLowPrice > newHighPrice - minHeight) {
            newLowPrice = newHighPrice - minHeight;
          }
          if (_dragStartPosition != null) {
            newEndTime = params.getTimestampFromX(_dragStartPosition!.dx);
          }
        }
      } else {
        // Regular drag (move entire Fibonacci) - both X and Y
        final initialPrice = _dragInitialPrice ?? _dragStartPrice!;
        final offset = _dragStartPrice! - initialPrice;
        newHighPrice = fibonacci.highPrice + offset;
        newLowPrice = fibonacci.lowPrice + offset;

        if (_dragStartPosition != null && fibonacci.startTime != null) {
          final origStartX = params.fitTimestamp(fibonacci.startTime!);
          if (origStartX != null) {
            final deltaX = _dragStartPosition!.dx - origStartX;
            newStartTime = params.getTimestampFromX(origStartX + deltaX);
            if (newStartTime != null && fibonacci.endTime != null) {
              final origEndX = params.fitTimestamp(fibonacci.endTime!);
              newEndTime = origEndX != null
                  ? params.getTimestampFromX(origEndX + deltaX)
                  : newStartTime + (fibonacci.endTime! - fibonacci.startTime!);
            }
          }
        }
      }

      fibonacci.options.onMoved?.call(newHighPrice, newLowPrice, newStartTime, newEndTime);
    } else if (_draggedOverlay is TrendLine) {
      final trendLine = _draggedOverlay as TrendLine;
      final params = _prevParams!;
      
      if (_isResizingTrendLine && _dragStartPosition != null) {
        // Resizing one endpoint - calculate new timestamp from X position
        final newTimestamp = params.getTimestampFromX(_dragStartPosition!.dx) ?? params.candles.last.timestamp;
        final newPrice = _dragStartPrice!;

        if (_isResizingTrendStart) {
          // Resizing start point
          trendLine.options.onMoved?.call(
            newTimestamp,
            newPrice,
            trendLine.endTime,
            trendLine.endPrice,
          );
        } else if (_isResizingTrendEnd) {
          // Resizing end point
          trendLine.options.onMoved?.call(
            trendLine.startTime,
            trendLine.startPrice,
            newTimestamp,
            newPrice,
          );
        }
      } else if (_dragStartPosition != null) {
        // Regular drag (move entire trend line) - calculate offset in both X and Y
        // Use initial price to calculate offset, not current price
        final initialPrice = _dragInitialPrice ?? _dragStartPrice!;
        final priceOffset = _dragStartPrice! - initialPrice;

        // Calculate time offset based on X movement using extrapolated timestamps
        final startX = params.fitTimestamp(trendLine.startTime);
        if (startX != null) {
          final deltaX = _dragStartPosition!.dx - startX;

          final newStartTimestamp = params.getTimestampFromX(startX + deltaX);
          final endX = params.fitTimestamp(trendLine.endTime);
          final newEndTimestamp = endX != null ? params.getTimestampFromX(endX + deltaX) : newStartTimestamp;

          trendLine.options.onMoved?.call(
            newStartTimestamp ?? trendLine.startTime,
            trendLine.startPrice + priceOffset,
            newEndTimestamp ?? trendLine.endTime,
            trendLine.endPrice + priceOffset,
          );
        }
      }
    } else if (_draggedOverlay is PositionTool) {
      // PositionTool drag - handle individual line movement
      final positionTool = _draggedOverlay as PositionTool;
      if (_dragStartPrice != null) {
        // Determine which line was dragged and update only that line
        if (_isResizingPositionEntry) {
          // Moving Entry line
          positionTool.options.onPositionChanged?.call(
            _dragStartPrice!,
            positionTool.stopLossPrice,
            positionTool.takeProfitPrice,
          );
        } else if (_isResizingPositionSL) {
          // Moving Stop Loss line
          positionTool.options.onPositionChanged?.call(
            positionTool.entryPrice,
            _dragStartPrice!,
            positionTool.takeProfitPrice,
          );
        } else if (_isResizingPositionTP) {
          // Moving Take Profit line
          positionTool.options.onPositionChanged?.call(
            positionTool.entryPrice,
            positionTool.stopLossPrice,
            _dragStartPrice!,
          );
        }
      }
    } else if (_draggedOverlay is RulerTool) {
      // RulerTool drag/resize (same logic as TrendLine)
      final rulerTool = _draggedOverlay as RulerTool;
      final params = _prevParams!;
      
      if (_isResizingTrendLine && _dragStartPosition != null) {
        // Resizing one endpoint - calculate new timestamp from X position
        final newTimestamp = params.getTimestampFromX(_dragStartPosition!.dx) ?? params.candles.last.timestamp;
        final newPrice = _dragStartPrice!;

        if (_isResizingTrendStart) {
          // Resizing start point
          rulerTool.options.onMoved?.call(
            newTimestamp,
            newPrice,
            rulerTool.endTime,
            rulerTool.endPrice,
          );
        } else if (_isResizingTrendEnd) {
          // Resizing end point
          rulerTool.options.onMoved?.call(
            rulerTool.startTime,
            rulerTool.startPrice,
            newTimestamp,
            newPrice,
          );
        }
      } else if (_dragStartPosition != null) {
        // Regular drag (move entire ruler) - calculate offset in both X and Y
        // Use initial price to calculate offset, not current price
        final initialPrice = _dragInitialPrice ?? _dragStartPrice!;
        final priceOffset = _dragStartPrice! - initialPrice;

        // Calculate time offset based on X movement using extrapolated timestamps
        final startX = params.fitTimestamp(rulerTool.startTime);
        if (startX != null) {
          final deltaX = _dragStartPosition!.dx - startX;

          final newStartTimestamp = params.getTimestampFromX(startX + deltaX);
          final endX = params.fitTimestamp(rulerTool.endTime);
          final newEndTimestamp = endX != null ? params.getTimestampFromX(endX + deltaX) : newStartTimestamp;

          rulerTool.options.onMoved?.call(
            newStartTimestamp ?? rulerTool.startTime,
            rulerTool.startPrice + priceOffset,
            newEndTimestamp ?? rulerTool.endTime,
            rulerTool.endPrice + priceOffset,
          );
        }
      }
    } else if (_draggedOverlay is VerticalLine) {
      // VerticalLine drag - move horizontally only
      final verticalLine = _draggedOverlay as VerticalLine;
      final params = _prevParams!;
      
      if (_dragStartPosition != null && _isDraggingVerticalLine) {
        // Calculate new timestamp from X position
        final newTimestamp = params.getTimestampFromX(_dragStartPosition!.dx) ?? params.candles.last.timestamp;

        verticalLine.options.onMoved?.call(newTimestamp);
      }
    } else if (_draggedOverlay is FibonacciExtension) {
      // FibonacciExtension drag - move individual points
      final fibExt = _draggedOverlay as FibonacciExtension;
      final params = _prevParams!;
      
      if (_dragStartPosition != null && _dragStartPrice != null) {
        // Calculate new timestamp and price from position
        final newTimestamp = params.getTimestampFromX(_dragStartPosition!.dx) ?? params.candles.last.timestamp;
        final newPrice = _dragStartPrice!;

        // Determine which point was dragged and update
        if (_isResizingFibExtPointA) {
          fibExt.options.onMoved?.call(
            newTimestamp,
            newPrice,
            fibExt.pointBTime,
            fibExt.pointBPrice,
            fibExt.pointCTime,
            fibExt.pointCPrice,
          );
        } else if (_isResizingFibExtPointB) {
          fibExt.options.onMoved?.call(
            fibExt.pointATime,
            fibExt.pointAPrice,
            newTimestamp,
            newPrice,
            fibExt.pointCTime,
            fibExt.pointCPrice,
          );
        } else if (_isResizingFibExtPointC) {
          fibExt.options.onMoved?.call(
            fibExt.pointATime,
            fibExt.pointAPrice,
            fibExt.pointBTime,
            fibExt.pointBPrice,
            newTimestamp,
            newPrice,
          );
        }
      }
    } else if (_draggedOverlay is FibonacciFan) {
      // FibonacciFan drag - move individual points
      final fibFan = _draggedOverlay as FibonacciFan;
      final params = _prevParams!;
      
      if (_dragStartPosition != null && _dragStartPrice != null) {
        // Calculate new timestamp and price from position
        final newTimestamp = params.getTimestampFromX(_dragStartPosition!.dx) ?? params.candles.last.timestamp;
        final newPrice = _dragStartPrice!;

        // Determine which point was dragged and update
        if (_isResizingFibFanStart) {
          fibFan.options.onMoved?.call(
            newTimestamp,
            newPrice,
            fibFan.endTime,
            fibFan.endPrice,
          );
        } else if (_isResizingFibFanEnd) {
          fibFan.options.onMoved?.call(
            fibFan.startTime,
            fibFan.startPrice,
            newTimestamp,
            newPrice,
          );
        }
      }
    } else if (_draggedOverlay is ArrowTool) {
      // ArrowTool drag - move individual points
      final arrow = _draggedOverlay as ArrowTool;
      final params = _prevParams!;
      
      if (_dragStartPosition != null && _dragStartPrice != null) {
        // Calculate new timestamp and price from position
        final newTimestamp = params.getTimestampFromX(_dragStartPosition!.dx) ?? params.candles.last.timestamp;
        final newPrice = _dragStartPrice!;

        // Determine which point was dragged and update
        if (_isResizingArrowStart) {
          arrow.options.onMoved?.call(
            newTimestamp,
            newPrice,
            arrow.endTime,
            arrow.endPrice,
          );
        } else if (_isResizingArrowEnd) {
          arrow.options.onMoved?.call(
            arrow.startTime,
            arrow.startPrice,
            newTimestamp,
            newPrice,
          );
        }
      }
    } else if (_draggedOverlay is CircleTool) {
      // CircleTool drag - move center or resize radius
      final circle = _draggedOverlay as CircleTool;
      final params = _prevParams!;
      
      if (_dragStartPosition != null && _dragStartPrice != null) {
        // Calculate new timestamp and price from position
        final newTimestamp = params.getTimestampFromX(_dragStartPosition!.dx) ?? params.candles.last.timestamp;
        final newPrice = _dragStartPrice!;

        if (_isResizingCircleCenter) {
          // Moving center - keep radius the same
          circle.options.onMoved?.call(
            newTimestamp,
            newPrice,
            circle.radiusTime,
            circle.radiusPrice,
          );
        } else if (_isResizingCircleRadius) {
          // Resizing radius - calculate new radius from center to drag position
          final radiusTime = (newTimestamp - circle.centerTime).abs();
          final radiusPrice = (newPrice - circle.centerPrice).abs();
          
          circle.options.onMoved?.call(
            circle.centerTime,
            circle.centerPrice,
            radiusTime,
            radiusPrice,
          );
        }
      }
    } else if (_draggedOverlay is TextTool) {
      // TextTool drag - move text position
      final textTool = _draggedOverlay as TextTool;
      final params = _prevParams!;
      
      if (_dragStartPosition != null && _dragStartPrice != null) {
        // Calculate new timestamp and price from position
        final newTimestamp = params.getTimestampFromX(_dragStartPosition!.dx) ?? params.candles.last.timestamp;
        final newPrice = _dragStartPrice!;

        textTool.options.onMoved?.call(newTimestamp, newPrice);
      }
    } else if (_draggedOverlay is GanttTool) {
      // GanttTool drag - move or resize
      final gantt = _draggedOverlay as GanttTool;
      final params = _prevParams!;
      
      if (_dragStartPosition != null && _dragStartPrice != null) {
        // Calculate new timestamp and price from position
        final newTimestamp = params.getTimestampFromX(_dragStartPosition!.dx) ?? params.candles.last.timestamp;
        final newPrice = _dragStartPrice!;

        if (_isResizingGanttStart) {
          // Resizing start - keep end the same
          gantt.options.onMoved?.call(
            newTimestamp,
            gantt.endTime,
            newPrice,
          );
        } else if (_isResizingGanttEnd) {
          // Resizing end - keep start the same
          gantt.options.onMoved?.call(
            gantt.startTime,
            newTimestamp,
            newPrice,
          );
        }
      }
    }
    
    // Clear drag state and trigger rebuild
    setState(() {
      _draggedOverlay = null;
      _dragStartPrice = null;
      _dragInitialPrice = null;
      _dragStartPosition = null;
      _originalPrice = null;
      _hasDragged = false;
      _isResizingTop = false;
      _isResizingBottom = false;
      _isResizingFibonacci = false;
      _isResizingTrendLine = false;
      _isResizingTrendStart = false;
      _isResizingTrendEnd = false;
      _isResizingPositionEntry = false;
      _isResizingPositionSL = false;
      _isResizingPositionTP = false;
      _isDraggingVerticalLine = false;
      _isResizingFibExtPointA = false;
      _isResizingFibExtPointB = false;
      _isResizingFibExtPointC = false;
      _isResizingFibFanStart = false;
      _isResizingFibFanEnd = false;
      _isResizingArrowStart = false;
      _isResizingArrowEnd = false;
      _isResizingCircleCenter = false;
      _isResizingCircleRadius = false;
      _isDraggingTextTool = false;
      _isResizingGanttStart = false;
      _isResizingGanttEnd = false;
    });
  }
}

extension Formatting on double {
  String asPercent() {
    final format = this < 100 ? "##0.00" : "#,###";
    final v = intl.NumberFormat(format, "en_US").format(this);
    return "${this >= 0 ? '+' : ''}$v%";
  }

  String asAbbreviated() {
    if (this < 1000) return this.toStringAsFixed(3);
    if (this >= 1e18) return this.toStringAsExponential(3);
    final s = intl.NumberFormat("#,###", "en_US").format(this).split(",");
    const suffixes = ["K", "M", "B", "T", "Q"];
    return "${s[0]}.${s[1]}${suffixes[s.length - 2]}";
  }
}
