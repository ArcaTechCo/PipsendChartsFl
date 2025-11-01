import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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

  /// Controller for programmatic chart interactions.
  ///
  /// Use this to control the chart programmatically (e.g., jump to latest).
  final InteractiveChartController? controller;

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
    this.controller,
  })  : this.style = style ?? const ChartStyle(),
        assert(candles.length >= 3,
            "InteractiveChart requires 3 or more CandleData"),
        assert(initialVisibleCandleCount >= 3,
            "initialVisibleCandleCount must be more 3 or more"),
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

  @override
  void initState() {
    super.initState();
    // Attach controller if provided
    widget.controller?.attach(jumpToLatest);
  }

  @override
  void dispose() {
    // Detach controller
    widget.controller?.detach();
    super.dispose();
  }

  /// Jump to the latest candle (most recent data)
  void jumpToLatest() {
    if (_prevChartWidth == null) return;
    
    final w = _prevChartWidth!;
    final count = w / _candleWidth;
    final newOffset = (widget.candles.length - count) * _candleWidth;
    
    setState(() {
      _startOffset = newOffset.clamp(0, _getMaxStartOffset(w, _candleWidth));
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

        // Find the visible data range
        final int start = (_startOffset / _candleWidth).floor();
        final int count = (w / _candleWidth).ceil();
        final int end = (start + count).clamp(start, widget.candles.length);
        
        // Notify offset change if callback is provided
        _notifyOffsetChanged(start, end);
        
        final candlesInRange = widget.candles.getRange(start, end).toList();
        if (end < widget.candles.length) {
          // Put in an extra item, since it can become visible when scrolling
          final nextItem = widget.candles[end];
          candlesInRange.add(nextItem);
        }

        // If possible, find neighbouring trend line data,
        // so the chart could draw better-connected lines
        final leadingTrends = widget.candles.at(start - 1)?.trends;
        final trailingTrends = widget.candles.at(end + 1)?.trends;

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
        final maxPrice = priceValues.isNotEmpty 
            ? priceValues.reduce(max)
            : 100.0; // Default value when no data visible
        
        final lowValues = candlesInRange.map(lowest).whereType<double>();
        final minPrice = lowValues.isNotEmpty
            ? lowValues.reduce(min)
            : 0.0; // Default value when no data visible
        
        final maxVol = candlesInRange
            .map((c) => c.volume)
            .whereType<double>()
            .fold(double.negativeInfinity, max);
        final minVol = candlesInRange
            .map((c) => c.volume)
            .whereType<double>()
            .fold(double.infinity, min);

        final child = TweenAnimationBuilder(
          tween: PainterParamsTween(
            end: PainterParams(
              candles: candlesInRange,
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
              final params = _prevParams;
              if (params != null) {
                // FIRST: Check all zones and fibonacci for handle hits
                for (final overlay in widget.overlays) {
                  if (overlay is PriceZone && overlay.options.resizable) {
                    if (overlay.hitTestTopHandle(details.localPosition, params)) {
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
                    } else if (overlay.hitTestBottomHandle(details.localPosition, params)) {
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
                    if (overlay.hitTestTopHandle(details.localPosition, params)) {
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
                    } else if (overlay.hitTestBottomHandle(details.localPosition, params)) {
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
              // Only show overlay info if interaction is enabled
              if (widget.enableInteraction) {
                setState(() {
                  _tapPosition = details.localPosition;
                });
              }
            },
            onTapUp: (_) {
              // If overlay was selected but not dragged, deselect it
              if (_draggedOverlay != null && !_hasDragged) {
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
              // Clear tap position if interaction is enabled
              if (widget.enableInteraction) {
                setState(() {
                  _tapPosition = null;
                });
              }
            },
            // Scale for both zoom and overlay dragging
            onScaleStart: (details) {
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
              if (_draggedOverlay != null) {
                // Dragging an overlay
                _hasDragged = true; // Mark that user has dragged
                _onOverlayDrag(details.localFocalPoint);
              } else {
                // Normal zoom/pan
                _onScaleUpdate(details.scale, details.localFocalPoint, w);
              }
            },
            onScaleEnd: (details) {
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
                  }
                }
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
    // Handle pan
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
        widget.candles.length,
        widget.initialVisibleCandleCount,
      );
      _candleWidth = w / count;
      // Default show the latest available data, e.g. the most recent 90 days.
      _startOffset = (widget.candles.length - count) * _candleWidth;
    }
    _prevChartWidth = w;
  }

  // The narrowest candle width, i.e. when drawing all available data points.
  double _getMinCandleWidth(double w) => w / widget.candles.length;

  // The widest candle width, e.g. when drawing 14 day chart
  double _getMaxCandleWidth(double w) => w / min(14, widget.candles.length);

  // Max start offset: how far can we scroll towards the end of the chart
  double _getMaxStartOffset(double w, double candleWidth) {
    final count = w / candleWidth; // visible candles in the window
    final start = widget.candles.length - count;
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
      totalCandles: widget.candles.length,
    );
    
    widget.onXOffsetChanged!.call(details);
  }

  void _fireOnTapEvent() {
    if (_prevParams == null || _tapPosition == null) return;
    final params = _prevParams!;
    final dx = _tapPosition!.dx;
    final dy = _tapPosition!.dy;
    final selected = params.getCandleIndexFromOffset(dx);
    final candle = params.candles[selected];
    final tapPrice = params.getPriceFromY(dy);
    
    final details = TapDetails(
      candle: candle,
      tapPrice: tapPrice,
      candleIndex: selected,
    );
    
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
      
      if (_isResizingTop) {
        // Resizing top edge (maxPrice)
        newMinPrice = priceZone.minPrice;
        newMaxPrice = _dragStartPrice!;
        // Ensure minimum zone height (0.1% of visible price range)
        final visiblePriceRange = params.maxPrice - params.minPrice;
        final minHeight = visiblePriceRange * 0.001; // 0.1% of visible range
        final minAllowedMaxPrice = newMinPrice + minHeight;
        if (newMaxPrice < minAllowedMaxPrice) {
          newMaxPrice = minAllowedMaxPrice;
        }
      } else if (_isResizingBottom) {
        // Resizing bottom edge (minPrice)
        newMinPrice = _dragStartPrice!;
        newMaxPrice = priceZone.maxPrice;
        // Ensure minimum zone height (0.1% of visible price range)
        final visiblePriceRange = params.maxPrice - params.minPrice;
        final minHeight = visiblePriceRange * 0.001; // 0.1% of visible range
        final maxAllowedMinPrice = newMaxPrice - minHeight;
        if (newMinPrice > maxAllowedMinPrice) {
          newMinPrice = maxAllowedMinPrice;
        }
      } else {
        // Regular drag (move entire zone)
        // Use initial price to calculate offset, not current price
        final initialPrice = _dragInitialPrice ?? _dragStartPrice!;
        final offset = _dragStartPrice! - initialPrice;
        newMinPrice = priceZone.minPrice + offset;
        newMaxPrice = priceZone.maxPrice + offset;
      }
      
      // Call the callback with the new range
      priceZone.options.onRangeChanged?.call(newMinPrice, newMaxPrice);
    } else if (_draggedOverlay is FibonacciRetracement) {
      final fibonacci = _draggedOverlay as FibonacciRetracement;
      final params = _prevParams!;
      
      double newHighPrice;
      double newLowPrice;
      
      if (_isResizingFibonacci) {
        // Resizing one edge of the Fibonacci
        if (_isResizingTop) {
          // Resizing top edge (highPrice)
          newHighPrice = _dragStartPrice!;
          newLowPrice = fibonacci.lowPrice;
          // Ensure minimum height (0.1% of visible price range)
          final visiblePriceRange = params.maxPrice - params.minPrice;
          final minHeight = visiblePriceRange * 0.001; // 0.1% of visible range
          final minAllowedHighPrice = newLowPrice + minHeight;
          if (newHighPrice < minAllowedHighPrice) {
            newHighPrice = minAllowedHighPrice;
          }
        } else {
          // Resizing bottom edge (lowPrice)
          newHighPrice = fibonacci.highPrice;
          newLowPrice = _dragStartPrice!;
          // Ensure minimum height (0.1% of visible price range)
          final visiblePriceRange = params.maxPrice - params.minPrice;
          final minHeight = visiblePriceRange * 0.001; // 0.1% of visible range
          final maxAllowedLowPrice = newHighPrice - minHeight;
          if (newLowPrice > maxAllowedLowPrice) {
            newLowPrice = maxAllowedLowPrice;
          }
        }
      } else {
        // Regular drag (move entire Fibonacci)
        // Use initial price to calculate offset, not current price
        final initialPrice = _dragInitialPrice ?? _dragStartPrice!;
        final offset = _dragStartPrice! - initialPrice;
        newHighPrice = fibonacci.highPrice + offset;
        newLowPrice = fibonacci.lowPrice + offset;
      }
      
      // Call the callback with the new prices
      fibonacci.options.onMoved?.call(newHighPrice, newLowPrice);
    } else if (_draggedOverlay is TrendLine) {
      final trendLine = _draggedOverlay as TrendLine;
      final params = _prevParams!;
      
      if (_isResizingTrendLine && _dragStartPosition != null) {
        // Resizing one endpoint - calculate new timestamp from X position
        final candleIndex = params.getCandleIndexFromOffset(_dragStartPosition!.dx);
        final clampedIndex = candleIndex.clamp(0, params.candles.length - 1);
        final newTimestamp = params.candles[clampedIndex].timestamp;
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
        
        // Calculate time offset based on X movement
        final startIndex = params.candles.indexWhere((c) => c.timestamp >= trendLine.startTime);
        if (startIndex >= 0) {
          final startX = params.xShift + startIndex * params.candleWidth;
          final deltaX = _dragStartPosition!.dx - startX;
          final candleOffset = (deltaX / params.candleWidth).round();
          
          // Find new timestamps
          final newStartIndex = (startIndex + candleOffset).clamp(0, params.candles.length - 1);
          final endIndex = params.candles.indexWhere((c) => c.timestamp >= trendLine.endTime);
          final newEndIndex = endIndex >= 0 ? (endIndex + candleOffset).clamp(0, params.candles.length - 1) : newStartIndex;
          
          trendLine.options.onMoved?.call(
            params.candles[newStartIndex].timestamp,
            trendLine.startPrice + priceOffset,
            params.candles[newEndIndex].timestamp,
            trendLine.endPrice + priceOffset,
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
