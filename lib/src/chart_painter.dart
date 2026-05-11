import 'dart:math';

import 'package:flutter/material.dart';

import 'candle_data.dart';
import 'painter_params.dart';
import 'grid_style.dart';
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
import 'indicators/indicator.dart';

typedef TimeLabelGetter = String Function(int timestamp, int visibleDataCount);
typedef PriceLabelGetter = String Function(double price);
typedef OverlayInfoGetter = Map<String, String> Function(CandleData candle);

class ChartPainter extends CustomPainter {
  final PainterParams params;
  final TimeLabelGetter getTimeLabel;
  final PriceLabelGetter getPriceLabel;
  final OverlayInfoGetter getOverlayInfo;
  final List<ChartOverlay> overlays;
  final List<Indicator> indicators;
  final ChartOverlay? draggedOverlay;
  final double? draggedPrice;
  final double? draggedInitialPrice;
  final Offset? draggedPosition;
  final bool isResizingTop;
  final bool isResizingBottom;
  final bool isResizingFibonacci;
  final bool isResizingTrendLine;
  final bool isResizingTrendStart;
  final bool isResizingTrendEnd;
  final bool isResizingPositionEntry;
  final bool isResizingPositionSL;
  final bool isResizingPositionTP;
  final bool isDraggingVerticalLine;
  final bool isResizingFibExtPointA;
  final bool isResizingFibExtPointB;
  final bool isResizingFibExtPointC;
  final bool isResizingFibFanStart;
  final bool isResizingFibFanEnd;
  final bool isResizingArrowStart;
  final bool isResizingArrowEnd;
  final bool isResizingCircleCenter;
  final bool isResizingCircleRadius;
  final bool isDraggingTextTool;
  final bool isResizingGanttStart;
  final bool isResizingGanttEnd;

  ChartPainter({
    required this.params,
    required this.getTimeLabel,
    required this.getPriceLabel,
    required this.getOverlayInfo,
    this.overlays = const [],
    this.indicators = const [],
    this.draggedOverlay,
    this.draggedPrice,
    this.draggedInitialPrice,
    this.draggedPosition,
    this.isResizingTop = false,
    this.isResizingBottom = false,
    this.isResizingFibonacci = false,
    this.isResizingTrendLine = false,
    this.isResizingTrendStart = false,
    this.isResizingTrendEnd = false,
    this.isResizingPositionEntry = false,
    this.isResizingPositionSL = false,
    this.isResizingPositionTP = false,
    this.isDraggingVerticalLine = false,
    this.isResizingFibExtPointA = false,
    this.isResizingFibExtPointB = false,
    this.isResizingFibExtPointC = false,
    this.isResizingFibFanStart = false,
    this.isResizingFibFanEnd = false,
    this.isResizingArrowStart = false,
    this.isResizingArrowEnd = false,
    this.isResizingCircleCenter = false,
    this.isResizingCircleRadius = false,
    this.isDraggingTextTool = false,
    this.isResizingGanttStart = false,
    this.isResizingGanttEnd = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw grids FIRST (background)
    _drawHorizontalGrid(canvas, params);
    _drawVerticalGrid(canvas, params);
    
    // Draw time labels (dates) & price labels
    _drawTimeLabels(canvas, params);
    _drawPriceLabels(canvas, params);

    // Draw prices, volumes & overlays with translate
    canvas.save();
    canvas.translate(params.xShift, 0);
    
    // Draw candles (clipped)
    canvas.save();
    canvas.clipRect(Offset(-params.xShift, 0) & Size(params.chartWidth, params.chartHeight));
    for (int i = 0; i < params.candles.length; i++) {
      _drawSingleDay(canvas, params, i);
    }
    canvas.restore();
    
    // Draw overlays (not clipped, so labels can extend outside)
    _drawOverlays(canvas, params);
    
    canvas.restore();

    // Draw indicators
    _drawIndicators(canvas, params);

    // Draw replay playhead (and the optional "dim future" overlay) on
    // top of everything except the tap interaction. The dim is drawn
    // first so the line itself remains crisp on top of it.
    if (params.playheadIndex != null && params.playheadStyle != null) {
      _drawDimRightSide(canvas, params);
      _drawPlayhead(canvas, params);
    }

    // Draw tap highlight & overlay
    if (params.tapPosition != null) {
      final tapIdx = params.getCandleIndexFromOffset(params.tapPosition!.dx);
      if (tapIdx >= 0 && tapIdx < params.candles.length) {
        _drawTapHighlightAndOverlay(canvas, params);
      }
    }
  }

  /// Converts the playhead index (relative to the visible candle
  /// sublist) into a screen-space X coordinate. The chart's drawable
  /// area starts at x=0 and ends at x=params.chartWidth.
  double _playheadScreenX(PainterParams params) {
    final i = params.playheadIndex!;
    return i * params.candleWidth + params.xShift;
  }

  /// Paints the vertical playhead line with optional label and drag
  /// handles. Runs in screen space (no canvas.translate). Caller
  /// guarantees the playhead falls within the visible candle sublist.
  void _drawPlayhead(Canvas canvas, PainterParams params) {
    final style = params.playheadStyle!;
    final drawX = _playheadScreenX(params).clamp(0.0, params.chartWidth);

    final paint = Paint()
      ..color = style.lineColor
      ..strokeWidth = style.lineWidth
      ..strokeCap = StrokeCap.round;

    final top = Offset(drawX, 0);
    final bottom = Offset(drawX, params.chartHeight);

    if (style.dashPattern != null && style.dashPattern!.length >= 2) {
      _drawDashedLine(
        canvas,
        top,
        bottom,
        paint,
        dashLength: style.dashPattern![0],
        gapLength: style.dashPattern![1],
      );
    } else {
      canvas.drawLine(top, bottom, paint);
    }

    if (style.showDragHandles && style.draggable) {
      // Diamond grab handle at the vertical midpoint of the chart.
      // Size is configurable via PlayheadStyle.handleSize.
      final handleSize = style.handleSize;
      final handlePaint = Paint()
        ..color = style.lineColor
        ..style = PaintingStyle.fill;
      final center = Offset(drawX, params.chartHeight * 0.5);
      final path = Path()
        ..moveTo(center.dx, center.dy - handleSize)
        ..lineTo(center.dx + handleSize, center.dy)
        ..lineTo(center.dx, center.dy + handleSize)
        ..lineTo(center.dx - handleSize, center.dy)
        ..close();
      canvas.drawPath(path, handlePaint);
    }

    if (style.showLabel) {
      final ts = _playheadTimestamp(params);
      if (ts != null) {
        final labelText = getTimeLabel(ts, params.candles.length);
        final textStyle = style.labelStyle ??
            TextStyle(
              color: _contrastingTextColor(style.labelBackground),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            );
        final tp = TextPainter(
          text: TextSpan(text: labelText, style: textStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        final labelW = tp.width + style.labelHorizontalPadding * 2;
        final labelH = tp.height + style.labelVerticalPadding * 2;
        // Position: just above the time-label strip at the bottom.
        final labelTop = params.chartHeight - labelH - 2;
        final labelLeft = (drawX - labelW / 2)
            .clamp(0.0, params.chartWidth - labelW);
        final rect = Rect.fromLTWH(labelLeft, labelTop, labelW, labelH);
        final rrect = RRect.fromRectAndRadius(
          rect,
          const Radius.circular(3),
        );
        canvas.drawRRect(
          rrect,
          Paint()..color = style.labelBackground,
        );
        tp.paint(
          canvas,
          Offset(
            labelLeft + style.labelHorizontalPadding,
            labelTop + style.labelVerticalPadding,
          ),
        );
      }
    }
  }

  /// Paints a translucent rectangle covering the area to the right of
  /// the playhead (within the chart's drawable region). Used in replay
  /// mode to visually communicate that the "future" is hidden.
  void _drawDimRightSide(Canvas canvas, PainterParams params) {
    final style = params.playheadStyle!;
    if (!style.dimRightSide) return;
    final x = _playheadScreenX(params);
    if (x >= params.chartWidth) return; // nothing to dim
    final left = x.clamp(0.0, params.chartWidth);
    final rect = Rect.fromLTRB(
      left,
      0,
      params.chartWidth,
      params.chartHeight,
    );
    final paint = Paint()
      ..color = style.dimColor.withValues(alpha: style.dimOpacity);
    canvas.drawRect(rect, paint);
  }

  /// Returns the timestamp at the playhead position. Honors tick
  /// progress when set: linearly interpolates between the candle at
  /// playheadIndex and the next one.
  int? _playheadTimestamp(PainterParams params) {
    final i = params.playheadIndex!;
    if (i < 0 || i >= params.candles.length) return null;
    final base = params.candles[i].timestamp;
    final tick = params.playheadTickProgress;
    if (tick == null || tick <= 0 || i + 1 >= params.candles.length) {
      return base;
    }
    final next = params.candles[i + 1].timestamp;
    return (base + (next - base) * tick.clamp(0.0, 1.0)).round();
  }

  /// Picks black or white based on the brightness of [bg] so a label
  /// drawn on top of [bg] stays legible.
  Color _contrastingTextColor(Color bg) {
    return bg.computeLuminance() > 0.55
        ? const Color(0xFF000000)
        : const Color(0xFFFFFFFF);
  }

  void _drawOverlays(Canvas canvas, PainterParams params) {
    if (overlays.isEmpty && draggedOverlay == null) return;

    // Don't clip the overlays so price labels can be drawn outside
    for (final overlay in overlays) {
      if (overlay.visible) {
        // If this overlay is being dragged, draw it at the new price with feedback
        // Compare by ID instead of object reference
        final isDragged = draggedOverlay != null && 
                         overlay.id == draggedOverlay!.id && 
                         draggedPrice != null;
        
        if (isDragged) {
          // Draw the dragged version with the new price and visual feedback
          if (overlay is TradingLine) {
            final draggedLine = overlay.withPrice(draggedPrice!);
            draggedLine.paint(canvas, params, isBeingDragged: true);
          } else if (overlay is PriceZone) {
            // Handle resize vs drag
            PriceZone draggedZone;
            final visiblePriceRange = params.maxPrice - params.minPrice;
            final minZoneHeight = visiblePriceRange * 0.001;

            if (isResizingTop) {
              // Top-left handle: maxPrice + startTime
              var newMax = draggedPrice!;
              if (newMax < overlay.minPrice + minZoneHeight) {
                newMax = overlay.minPrice + minZoneHeight;
              }
              final newStartTime = draggedPosition != null
                  ? params.getTimestampFromX(draggedPosition!.dx)
                  : overlay.startTime;
              draggedZone = overlay.copyWith(maxPrice: newMax, startTime: newStartTime);
            } else if (isResizingBottom) {
              // Bottom-right handle: minPrice + endTime
              var newMin = draggedPrice!;
              if (newMin > overlay.maxPrice - minZoneHeight) {
                newMin = overlay.maxPrice - minZoneHeight;
              }
              final newEndTime = draggedPosition != null
                  ? params.getTimestampFromX(draggedPosition!.dx)
                  : overlay.endTime;
              draggedZone = overlay.copyWith(minPrice: newMin, endTime: newEndTime);
            } else {
              // Regular drag - move entire zone (X + Y)
              final initialPrice = draggedInitialPrice ?? draggedPrice!;
              final offset = draggedPrice! - initialPrice;
              draggedZone = overlay.copyWith(
                minPrice: overlay.minPrice + offset,
                maxPrice: overlay.maxPrice + offset,
              );
              if (draggedPosition != null && overlay.startTime != null) {
                final origStartX = params.fitTimestamp(overlay.startTime!);
                if (origStartX != null) {
                  final deltaX = draggedPosition!.dx - origStartX;
                  final newStartTime = params.getTimestampFromX(origStartX + deltaX);
                  if (newStartTime != null && overlay.endTime != null) {
                    final origEndX = params.fitTimestamp(overlay.endTime!);
                    final newEndTime = origEndX != null
                        ? params.getTimestampFromX(origEndX + deltaX)
                        : newStartTime + (overlay.endTime! - overlay.startTime!);
                    draggedZone = draggedZone.copyWith(startTime: newStartTime, endTime: newEndTime);
                  }
                }
              }
            }
            draggedZone.paint(canvas, params, isBeingDragged: true);
          } else if (overlay is FibonacciRetracement) {
            // Handle resize vs drag
            FibonacciRetracement draggedFib;
            
            if (isResizingFibonacci) {
              // Resizing a corner handle (top-left or bottom-right)
              final visiblePriceRange = params.maxPrice - params.minPrice;
              final minHeight = visiblePriceRange * 0.001;

              if (isResizingTop) {
                // Top-left handle: highPrice + startTime
                var newHigh = draggedPrice!;
                if (newHigh < overlay.lowPrice + minHeight) {
                  newHigh = overlay.lowPrice + minHeight;
                }
                final newStartTime = draggedPosition != null
                    ? params.getTimestampFromX(draggedPosition!.dx)
                    : overlay.startTime;
                draggedFib = overlay.copyWith(
                  highPrice: newHigh,
                  startTime: newStartTime,
                );
              } else {
                // Bottom-right handle: lowPrice + endTime
                var newLow = draggedPrice!;
                if (newLow > overlay.highPrice - minHeight) {
                  newLow = overlay.highPrice - minHeight;
                }
                final newEndTime = draggedPosition != null
                    ? params.getTimestampFromX(draggedPosition!.dx)
                    : overlay.endTime;
                draggedFib = overlay.copyWith(
                  lowPrice: newLow,
                  endTime: newEndTime,
                );
              }
            } else {
              // Move entire Fibonacci retracement (X + Y)
              final initialPrice = draggedInitialPrice ?? draggedPrice!;
              final offset = draggedPrice! - initialPrice;
              draggedFib = overlay.copyWith(
                highPrice: overlay.highPrice + offset,
                lowPrice: overlay.lowPrice + offset,
              );
              // Update horizontal position using delta from original position
              if (draggedPosition != null && overlay.startTime != null) {
                final origStartX = params.fitTimestamp(overlay.startTime!);
                if (origStartX != null) {
                  final deltaX = draggedPosition!.dx - origStartX;
                  final newStartTime = params.getTimestampFromX(origStartX + deltaX);
                  if (newStartTime != null && overlay.endTime != null) {
                    final origEndX = params.fitTimestamp(overlay.endTime!);
                    final newEndTime = origEndX != null
                        ? params.getTimestampFromX(origEndX + deltaX)
                        : newStartTime + (overlay.endTime! - overlay.startTime!);
                    draggedFib = draggedFib.copyWith(
                      startTime: newStartTime,
                      endTime: newEndTime,
                    );
                  } else if (newStartTime != null) {
                    draggedFib = draggedFib.copyWith(startTime: newStartTime);
                  }
                }
              }
            }
            draggedFib.paint(canvas, params, isBeingDragged: true);
          } else if (overlay is TrendLine) {
            // Handle resize vs drag for TrendLine
            final TrendLine draggedTrend;
            
            if (isResizingTrendLine && draggedPosition != null) {
              // Resizing one endpoint - calculate new timestamp from X position
              final newTimestamp = params.getTimestampFromX(draggedPosition!.dx) ?? params.candles.last.timestamp;
              final newPrice = draggedPrice!;
              
              if (isResizingTrendStart) {
                // Resizing start point
                draggedTrend = overlay.withPoints(
                  startTime: newTimestamp,
                  startPrice: newPrice,
                );
              } else {
                // Resizing end point
                draggedTrend = overlay.withPoints(
                  endTime: newTimestamp,
                  endPrice: newPrice,
                );
              }
            } else if (draggedPosition != null) {
              // Move entire trend line - calculate offset in both X and Y
              final priceOffset = draggedPrice! - ((overlay.startPrice + overlay.endPrice) / 2);

              final startX = params.fitTimestamp(overlay.startTime);
              if (startX != null) {
                final deltaX = draggedPosition!.dx - startX;
                final newStartTs = params.getTimestampFromX(startX + deltaX) ?? overlay.startTime;
                final endX = params.fitTimestamp(overlay.endTime);
                final newEndTs = endX != null
                    ? (params.getTimestampFromX(endX + deltaX) ?? overlay.endTime)
                    : newStartTs;

                draggedTrend = overlay.withPoints(
                  startTime: newStartTs,
                  startPrice: overlay.startPrice + priceOffset,
                  endTime: newEndTs,
                  endPrice: overlay.endPrice + priceOffset,
                );
              } else {
                final offset = draggedPrice! - ((overlay.startPrice + overlay.endPrice) / 2);
                draggedTrend = overlay.withPoints(
                  startPrice: overlay.startPrice + offset,
                  endPrice: overlay.endPrice + offset,
                );
              }
            } else {
              // No position info, just move price
              final offset = draggedPrice! - ((overlay.startPrice + overlay.endPrice) / 2);
              draggedTrend = overlay.withPoints(
                startPrice: overlay.startPrice + offset,
                endPrice: overlay.endPrice + offset,
              );
            }
            draggedTrend.paint(canvas, params, isBeingDragged: true);
          } else if (overlay is PositionTool) {
            // PositionTool - handle individual line movement
            if (draggedPrice != null) {
              final PositionTool draggedPosition;
              
              if (isResizingPositionEntry) {
                // Moving Entry line
                draggedPosition = overlay.copyWith(entryPrice: draggedPrice!);
              } else if (isResizingPositionSL) {
                // Moving Stop Loss line
                draggedPosition = overlay.copyWith(stopLossPrice: draggedPrice!);
              } else if (isResizingPositionTP) {
                // Moving Take Profit line
                draggedPosition = overlay.copyWith(takeProfitPrice: draggedPrice!);
              } else {
                // No specific line, just paint with drag feedback
                draggedPosition = overlay;
              }
              
              draggedPosition.paint(canvas, params, isBeingDragged: true);
            } else {
              overlay.paint(canvas, params, isBeingDragged: true);
            }
          } else if (overlay is RulerTool) {
            // Handle resize vs drag for RulerTool (same as TrendLine)
            final RulerTool draggedRuler;
            
            if (isResizingTrendLine && draggedPosition != null) {
              // Resizing one endpoint - calculate new timestamp from X position
              final newTimestamp = params.getTimestampFromX(draggedPosition!.dx) ?? params.candles.last.timestamp;
              final newPrice = draggedPrice!;
              
              if (isResizingTrendStart) {
                // Resizing start point
                draggedRuler = overlay.withPoints(
                  startTime: newTimestamp,
                  startPrice: newPrice,
                );
              } else {
                // Resizing end point
                draggedRuler = overlay.withPoints(
                  endTime: newTimestamp,
                  endPrice: newPrice,
                );
              }
            } else if (draggedPosition != null) {
              // Move entire ruler - calculate offset in both X and Y
              final priceOffset = draggedPrice! - ((overlay.startPrice + overlay.endPrice) / 2);

              final startX = params.fitTimestamp(overlay.startTime);
              if (startX != null) {
                final deltaX = draggedPosition!.dx - startX;
                final newStartTs = params.getTimestampFromX(startX + deltaX) ?? overlay.startTime;
                final endX = params.fitTimestamp(overlay.endTime);
                final newEndTs = endX != null
                    ? (params.getTimestampFromX(endX + deltaX) ?? overlay.endTime)
                    : newStartTs;

                draggedRuler = overlay.withPoints(
                  startTime: newStartTs,
                  startPrice: overlay.startPrice + priceOffset,
                  endTime: newEndTs,
                  endPrice: overlay.endPrice + priceOffset,
                );
              } else {
                final offset = draggedPrice! - ((overlay.startPrice + overlay.endPrice) / 2);
                draggedRuler = overlay.withPoints(
                  startPrice: overlay.startPrice + offset,
                  endPrice: overlay.endPrice + offset,
                );
              }
            } else {
              // No position info, just move price
              final offset = draggedPrice! - ((overlay.startPrice + overlay.endPrice) / 2);
              draggedRuler = overlay.withPoints(
                startPrice: overlay.startPrice + offset,
                endPrice: overlay.endPrice + offset,
              );
            }
            draggedRuler.paint(canvas, params, isBeingDragged: true);
          } else if (overlay is VerticalLine) {
            // VerticalLine - move horizontally only
            if (draggedPosition != null && isDraggingVerticalLine) {
              // Calculate new timestamp from X position
              final newTimestamp = params.getTimestampFromX(draggedPosition!.dx) ?? params.candles.last.timestamp;
              
              final draggedVLine = overlay.copyWith(timestamp: newTimestamp);
              draggedVLine.paint(canvas, params, isBeingDragged: true);
            } else {
              overlay.paint(canvas, params, isBeingDragged: true);
            }
          } else if (overlay is FibonacciExtension) {
            // FibonacciExtension - move individual points
            if (draggedPosition != null && draggedPrice != null) {
              final newTimestamp = params.getTimestampFromX(draggedPosition!.dx) ?? params.candles.last.timestamp;
              final newPrice = draggedPrice!;
              
              final FibonacciExtension draggedFibExt;
              if (isResizingFibExtPointA) {
                draggedFibExt = overlay.copyWith(
                  pointATime: newTimestamp,
                  pointAPrice: newPrice,
                );
              } else if (isResizingFibExtPointB) {
                draggedFibExt = overlay.copyWith(
                  pointBTime: newTimestamp,
                  pointBPrice: newPrice,
                );
              } else if (isResizingFibExtPointC) {
                draggedFibExt = overlay.copyWith(
                  pointCTime: newTimestamp,
                  pointCPrice: newPrice,
                );
              } else {
                draggedFibExt = overlay;
              }
              draggedFibExt.paint(canvas, params, isBeingDragged: true);
            } else {
              overlay.paint(canvas, params, isBeingDragged: true);
            }
          } else if (overlay is FibonacciFan) {
            // FibonacciFan - move individual points
            if (draggedPosition != null && draggedPrice != null) {
              final newTimestamp = params.getTimestampFromX(draggedPosition!.dx) ?? params.candles.last.timestamp;
              final newPrice = draggedPrice!;
              
              final FibonacciFan draggedFibFan;
              if (isResizingFibFanStart) {
                draggedFibFan = overlay.copyWith(
                  startTime: newTimestamp,
                  startPrice: newPrice,
                );
              } else if (isResizingFibFanEnd) {
                draggedFibFan = overlay.copyWith(
                  endTime: newTimestamp,
                  endPrice: newPrice,
                );
              } else {
                draggedFibFan = overlay;
              }
              draggedFibFan.paint(canvas, params, isBeingDragged: true);
            } else {
              overlay.paint(canvas, params, isBeingDragged: true);
            }
          } else if (overlay is ArrowTool) {
            // ArrowTool - move individual points
            if (draggedPosition != null && draggedPrice != null) {
              final newTimestamp = params.getTimestampFromX(draggedPosition!.dx) ?? params.candles.last.timestamp;
              final newPrice = draggedPrice!;
              
              final ArrowTool draggedArrow;
              if (isResizingArrowStart) {
                draggedArrow = overlay.withPoints(
                  startTime: newTimestamp,
                  startPrice: newPrice,
                );
              } else if (isResizingArrowEnd) {
                draggedArrow = overlay.withPoints(
                  endTime: newTimestamp,
                  endPrice: newPrice,
                );
              } else {
                draggedArrow = overlay;
              }
              draggedArrow.paint(canvas, params, isBeingDragged: true);
            } else {
              overlay.paint(canvas, params, isBeingDragged: true);
            }
          } else if (overlay is CircleTool) {
            // CircleTool - move center or resize radius
            if (draggedPosition != null && draggedPrice != null) {
              final newTimestamp = params.getTimestampFromX(draggedPosition!.dx) ?? params.candles.last.timestamp;
              final newPrice = draggedPrice!;
              
              final CircleTool draggedCircle;
              if (isResizingCircleCenter) {
                draggedCircle = overlay.copyWith(
                  centerTime: newTimestamp,
                  centerPrice: newPrice,
                );
              } else if (isResizingCircleRadius) {
                final radiusTime = (newTimestamp - overlay.centerTime).abs();
                final radiusPrice = (newPrice - overlay.centerPrice).abs();
                draggedCircle = overlay.copyWith(
                  radiusTime: radiusTime,
                  radiusPrice: radiusPrice,
                );
              } else {
                draggedCircle = overlay;
              }
              draggedCircle.paint(canvas, params, isBeingDragged: true);
            } else {
              overlay.paint(canvas, params, isBeingDragged: true);
            }
          } else if (overlay is TextTool) {
            // TextTool - move text
            if (draggedPosition != null && draggedPrice != null && isDraggingTextTool) {
              final newTimestamp = params.getTimestampFromX(draggedPosition!.dx) ?? params.candles.last.timestamp;
              final newPrice = draggedPrice!;
              
              final draggedText = overlay.copyWith(
                timestamp: newTimestamp,
                price: newPrice,
              );
              draggedText.paint(canvas, params, isBeingDragged: true);
            } else {
              overlay.paint(canvas, params, isBeingDragged: true);
            }
          } else if (overlay is GanttTool) {
            // GanttTool - move or resize
            if (draggedPosition != null && draggedPrice != null) {
              final newTimestamp = params.getTimestampFromX(draggedPosition!.dx) ?? params.candles.last.timestamp;
              final newPrice = draggedPrice!;
              
              final GanttTool draggedGantt;
              if (isResizingGanttStart) {
                draggedGantt = overlay.copyWith(
                  startTime: newTimestamp,
                  price: newPrice,
                );
              } else if (isResizingGanttEnd) {
                draggedGantt = overlay.copyWith(
                  endTime: newTimestamp,
                  price: newPrice,
                );
              } else {
                draggedGantt = overlay;
              }
              draggedGantt.paint(canvas, params, isBeingDragged: true);
            } else {
              overlay.paint(canvas, params, isBeingDragged: true);
            }
          } else {
            overlay.paint(canvas, params, isBeingDragged: true);
          }
        } else {
          overlay.paint(canvas, params, isBeingDragged: false);
        }
      }
    }
  }

  /// Calculate optimal number of price labels based on chart height
  int _calculatePriceLabelCount(PainterParams params) {
    // If manual override, use it
    if (params.style.priceLabelCount != null) {
      return params.style.priceLabelCount!.clamp(3, 10);
    }
    
    // If adaptive disabled, use default
    if (!params.style.adaptiveLabels) {
      return 5; // Current default
    }
    
    // Adaptive calculation: ~80px per label
    final height = params.priceHeight;
    final labelCount = (height / 80).round().clamp(3, 10);
    return labelCount;
  }

  /// Calculate optimal time label density
  int _calculateTimeLabelDensity(PainterParams params) {
    // If manual override, use it
    if (params.style.timeLabelDensity != null) {
      return params.style.timeLabelDensity!.clamp(60, 120);
    }
    
    // If adaptive disabled, use default
    if (!params.style.adaptiveLabels) {
      return 90; // Current default
    }
    
    // Adaptive: use default 90px
    return 90;
  }

  void _drawTimeLabels(canvas, PainterParams params) {
    // Calculate density adaptively
    final density = _calculateTimeLabelDensity(params);
    final lineCount = params.chartWidth ~/ density;
    final gap = 1 / (lineCount + 1);
    for (int i = 1; i <= lineCount; i++) {
      double x = i * gap * params.chartWidth;
      final index = params.getCandleIndexFromOffset(x);
      if (index < params.candles.length) {
        final candle = params.candles[index];
        final visibleDataCount = params.candles.length;
        final timeTp = TextPainter(
          text: TextSpan(
            text: getTimeLabel(candle.timestamp, visibleDataCount),
            style: params.style.timeLabelStyle,
          ),
        )
          ..textDirection = TextDirection.ltr
          ..layout();

        // Align texts towards vertical bottom
        final topPadding = params.style.timeLabelHeight - timeTp.height;
        timeTp.paint(
          canvas,
          Offset(x - timeTp.width / 2, params.chartHeight + topPadding),
        );
      }
    }
  }

  /// Draw horizontal grid lines (aligned with price labels)
  void _drawHorizontalGrid(Canvas canvas, PainterParams params) {
    if (!params.style.gridStyle.showHorizontalGrid) return;

    final paint = Paint()
      ..strokeWidth = params.style.gridStyle.horizontalStrokeWidth
      ..color = params.style.effectiveHorizontalGridColor
      ..style = PaintingStyle.stroke;

    // Calculate number of labels adaptively
    final labelCount = _calculatePriceLabelCount(params);
    
    // Generate evenly spaced positions
    final positions = List.generate(
      labelCount,
      (i) => i / (labelCount - 1),
    );

    // Draw horizontal lines aligned with price labels
    positions
        .map((v) => ((params.maxPrice - params.minPrice) * v) + params.minPrice)
        .forEach((price) {
      final y = params.fitPrice(price);
      _drawStyledLine(
        canvas,
        Offset(0, y),
        Offset(params.chartWidth, y),
        paint,
        params.style.gridStyle.horizontalLineStyle,
      );
    });
  }

  /// Draw vertical grid lines (aligned with time labels)
  void _drawVerticalGrid(Canvas canvas, PainterParams params) {
    if (!params.style.gridStyle.showVerticalGrid) return;

    final paint = Paint()
      ..strokeWidth = params.style.gridStyle.verticalStrokeWidth
      ..color = params.style.gridStyle.verticalGridColor
      ..style = PaintingStyle.stroke;

    // Draw vertical lines aligned with time labels
    final density = _calculateTimeLabelDensity(params);
    final lineCount = params.chartWidth ~/ density;
    final gap = 1 / (lineCount + 1);

    for (int i = 1; i <= lineCount; i++) {
      double x = i * gap * params.chartWidth;
      final index = params.getCandleIndexFromOffset(x);

      if (index < params.candles.length) {
        _drawStyledLine(
          canvas,
          Offset(x, 0),
          Offset(x, params.chartHeight),
          paint,
          params.style.gridStyle.verticalLineStyle,
        );
      }
    }
  }

  /// Draw a line with the specified style (solid, dashed, dotted)
  void _drawStyledLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
    GridLineStyle lineStyle,
  ) {
    switch (lineStyle) {
      case GridLineStyle.solid:
        canvas.drawLine(start, end, paint);
        break;

      case GridLineStyle.dashed:
        _drawDashedLine(canvas, start, end, paint, dashLength: 5, gapLength: 3);
        break;

      case GridLineStyle.dotted:
        _drawDashedLine(canvas, start, end, paint, dashLength: 1, gapLength: 3);
        break;

      case GridLineStyle.longDashed:
        _drawDashedLine(canvas, start, end, paint, dashLength: 10, gapLength: 5);
        break;
    }
  }

  /// Helper to draw dashed/dotted lines
  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint, {
    required double dashLength,
    required double gapLength,
  }) {
    final path = Path();
    final totalLength = (end - start).distance;
    final dashCount = (totalLength / (dashLength + gapLength)).floor();

    if (totalLength == 0) return;

    final dx = (end.dx - start.dx) / totalLength;
    final dy = (end.dy - start.dy) / totalLength;

    for (int i = 0; i < dashCount; i++) {
      final startOffset = i * (dashLength + gapLength);
      final endOffset = startOffset + dashLength;

      final dashStart = Offset(
        start.dx + dx * startOffset,
        start.dy + dy * startOffset,
      );
      final dashEnd = Offset(
        start.dx + dx * endOffset,
        start.dy + dy * endOffset,
      );

      path.moveTo(dashStart.dx, dashStart.dy);
      path.lineTo(dashEnd.dx, dashEnd.dy);
    }

    canvas.drawPath(path, paint);
  }

  /// Draw price labels (without grid lines)
  void _drawPriceLabels(Canvas canvas, PainterParams params) {
    // Calculate number of labels adaptively
    final labelCount = _calculatePriceLabelCount(params);
    
    // Generate evenly spaced positions
    final positions = List.generate(
      labelCount,
      (i) => i / (labelCount - 1),
    );
    
    positions
        .map((v) => ((params.maxPrice - params.minPrice) * v) + params.minPrice)
        .forEach((y) {
      final priceTp = TextPainter(
        text: TextSpan(
          text: getPriceLabel(y),
          style: params.style.priceLabelStyle,
        ),
      )
        ..textDirection = TextDirection.ltr
        ..layout();
      priceTp.paint(
          canvas,
          Offset(
            params.chartWidth + 4,
            params.fitPrice(y) - priceTp.height / 2,
          ));
    });
  }

  void _drawSingleDay(canvas, PainterParams params, int i) {
    final candle = params.candles[i];
    final x = i * params.candleWidth;
    final thickWidth = max(params.candleWidth * 0.8, 0.8);
    final thinWidth = max(params.candleWidth * 0.2, 0.2);
    final borderRadius = params.style.candleBorderRadius;
    
    // Draw price bar
    final open = candle.open;
    final close = candle.close;
    final high = candle.high;
    final low = candle.low;
    if (open != null && close != null) {
      final color = open > close
          ? params.style.priceLossColor
          : params.style.priceGainColor;
      
      final openY = params.fitPrice(open);
      final closeY = params.fitPrice(close);
      
      // Draw candle body (open-close) with optional rounded corners
      if (borderRadius > 0 && thickWidth > 2) {
        // Use rounded rectangle for thicker candles
        final rect = Rect.fromLTRB(
          x - thickWidth / 2,
          min(openY, closeY),
          x + thickWidth / 2,
          max(openY, closeY),
        );
        final rrect = RRect.fromRectAndRadius(
          rect,
          Radius.circular(min(borderRadius, thickWidth / 2)),
        );
        canvas.drawRRect(
          rrect,
          Paint()
            ..color = color
            ..style = PaintingStyle.fill,
        );
      } else {
        // Use line for thin candles or when borderRadius is 0
        canvas.drawLine(
          Offset(x, openY),
          Offset(x, closeY),
          Paint()
            ..strokeWidth = thickWidth
            ..color = color,
        );
      }
      
      // Draw wicks (high-low) - always as thin lines
      if (high != null && low != null) {
        canvas.drawLine(
          Offset(x, params.fitPrice(high)),
          Offset(x, params.fitPrice(low)),
          Paint()
            ..strokeWidth = thinWidth
            ..color = color,
        );
      }
    }
    // Draw volume bar
    if (params.style.showVolume) {
      final volume = candle.volume;
      if (volume != null) {
        canvas.drawLine(
          Offset(x, params.chartHeight),
          Offset(x, params.fitVolume(volume)),
          Paint()
            ..strokeWidth = thickWidth
            ..color = params.style.volumeColor,
        );
      }
    }
    // Draw trend line
    for (int j = 0; j < candle.trends.length; j++) {
      final trendLinePaint = params.style.trendLineStyles.at(j) ??
          (Paint()
            ..strokeWidth = 2.0
            ..strokeCap = StrokeCap.round
            ..color = Colors.blue);

      final pt = candle.trends.at(j); // current data point
      final prevPt = params.candles.at(i - 1)?.trends.at(j);
      if (pt != null && prevPt != null) {
        canvas.drawLine(
          Offset(x - params.candleWidth, params.fitPrice(prevPt)),
          Offset(x, params.fitPrice(pt)),
          trendLinePaint,
        );
      }
      if (i == 0) {
        // In the front, draw an extra line connecting to out-of-window data
        if (pt != null && params.leadingTrends?.at(j) != null) {
          canvas.drawLine(
            Offset(x - params.candleWidth,
                params.fitPrice(params.leadingTrends!.at(j)!)),
            Offset(x, params.fitPrice(pt)),
            trendLinePaint,
          );
        }
      } else if (i == params.candles.length - 1) {
        // At the end, draw an extra line connecting to out-of-window data
        if (pt != null && params.trailingTrends?.at(j) != null) {
          canvas.drawLine(
            Offset(x, params.fitPrice(pt)),
            Offset(
              x + params.candleWidth,
              params.fitPrice(params.trailingTrends!.at(j)!),
            ),
            trendLinePaint,
          );
        }
      }
    }
  }

  void _drawTapHighlightAndOverlay(canvas, PainterParams params) {
    final pos = params.tapPosition!;
    final i = params.getCandleIndexFromOffset(pos.dx);
    final candle = params.candles[i];
    final dashed = params.style.crosshairDashed;
    canvas.save();
    canvas.translate(params.xShift, 0.0);
    if (dashed) {
      // Thin dashed vertical line through the center of the selected candle
      final centerX = i * params.candleWidth + params.candleWidth / 2;
      final paint = Paint()
        ..strokeWidth = 1.0
        ..color = params.style.selectionHighlightColor.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke;
      _drawDashedLine(
        canvas,
        Offset(centerX, 0.0),
        Offset(centerX, params.chartHeight),
        paint,
        dashLength: 5,
        gapLength: 3,
      );
    } else {
      // Draw highlight bar (selection box)
      canvas.drawLine(
          Offset(i * params.candleWidth, 0.0),
          Offset(i * params.candleWidth, params.chartHeight),
          Paint()
            ..strokeWidth = max(params.candleWidth * 0.88, 1.0)
            ..color = params.style.selectionHighlightColor);
    }
    canvas.restore();

    // Draw horizontal price line at tap position
    if (params.tapPrice != null) {
      final priceY = params.fitPrice(params.tapPrice!);
      final paint = Paint()
        ..strokeWidth = 1.0
        ..color = params.style.selectionHighlightColor.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke;
      if (dashed) {
        _drawDashedLine(
          canvas,
          Offset(0, priceY),
          Offset(params.chartWidth, priceY),
          paint,
          dashLength: 5,
          gapLength: 3,
        );
      } else {
        canvas.drawLine(
          Offset(0, priceY),
          Offset(params.chartWidth, priceY),
          paint,
        );
      }
      
      // Draw price label on the right
      final priceText = getPriceLabel(params.tapPrice!);
      final priceTp = TextPainter(
        text: TextSpan(
          text: priceText,
          style: params.style.priceLabelStyle.copyWith(
            backgroundColor: params.style.selectionHighlightColor,
          ),
        ),
      )
        ..textDirection = TextDirection.ltr
        ..layout();
      
      priceTp.paint(
        canvas,
        Offset(
          params.chartWidth + 4,
          priceY - priceTp.height / 2,
        ),
      );
    }
    
    // Draw info pane
    _drawTapInfoOverlay(canvas, params, candle);
  }

  void _drawTapInfoOverlay(canvas, PainterParams params, CandleData candle) {
    final xGap = 8.0;
    final yGap = 4.0;

    TextPainter makeTP(String text) => TextPainter(
          text: TextSpan(
            text: text,
            style: params.style.overlayTextStyle,
          ),
        )
          ..textDirection = TextDirection.ltr
          ..layout();

    final info = getOverlayInfo(candle);
    if (info.isEmpty) return;
    final labels = info.keys.map((text) => makeTP(text)).toList();
    final values = info.values.map((text) => makeTP(text)).toList();

    final labelsMaxWidth = labels.map((tp) => tp.width).reduce(max);
    final valuesMaxWidth = values.map((tp) => tp.width).reduce(max);
    final panelWidth = labelsMaxWidth + valuesMaxWidth + xGap * 3;
    final panelHeight = max(
          labels.map((tp) => tp.height).reduce((a, b) => a + b),
          values.map((tp) => tp.height).reduce((a, b) => a + b),
        ) +
        yGap * (values.length + 1);

    // Shift the canvas, so the overlay panel can appear near touch position.
    canvas.save();
    final pos = params.tapPosition!;
    final fingerSize = 32.0; // leave some margin around user's finger
    double dx, dy;
    assert(params.size.width >= panelWidth, "Overlay panel is too wide.");
    if (pos.dx <= params.size.width / 2) {
      // If user touches the left-half of the screen,
      // we show the overlay panel near finger touch position, on the right.
      dx = pos.dx + fingerSize;
    } else {
      // Otherwise we show panel on the left of the finger touch position.
      dx = pos.dx - panelWidth - fingerSize;
    }
    dx = dx.clamp(0, params.size.width - panelWidth);
    dy = pos.dy - panelHeight - fingerSize;
    if (dy < 0) dy = 0.0;
    canvas.translate(dx, dy);

    // Draw the background for overlay panel
    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Offset.zero & Size(panelWidth, panelHeight),
          Radius.circular(8),
        ),
        Paint()..color = params.style.overlayBackgroundColor);

    // Draw texts
    var y = 0.0;
    for (int i = 0; i < labels.length; i++) {
      y += yGap;
      final rowHeight = max(labels[i].height, values[i].height);
      // Draw labels (left align, vertical center)
      final labelY = y + (rowHeight - labels[i].height) / 2; // vertical center
      labels[i].paint(canvas, Offset(xGap, labelY));

      // Draw values (right align, vertical center)
      final leading = valuesMaxWidth - values[i].width; // right align
      final valueY = y + (rowHeight - values[i].height) / 2; // vertical center
      values[i].paint(
        canvas,
        Offset(labelsMaxWidth + xGap * 2 + leading, valueY),
      );
      y += rowHeight;
    }

    canvas.restore();
  }

  void _drawIndicators(Canvas canvas, PainterParams params) {
    if (indicators.isEmpty) return;

    canvas.save();
    canvas.translate(params.xShift, 0);
    
    // Clip with extra padding to prevent lines from being cut off
    // Use a larger clip area to account for line width and anti-aliasing
    final clipPadding = 10.0;
    canvas.clipRect(
      Offset(-params.xShift - clipPadding, -clipPadding) & 
      Size(params.chartWidth + clipPadding * 2, params.chartHeight + clipPadding * 2)
    );

    for (final indicator in indicators) {
      if (!indicator.visible) continue;

      // Calculate indicator values
      // In replay mode, indicators compute over the full untrimmed
      // dataset (so the cache stays stable across pan/zoom/playhead
      // moves). The paint method then cross-references via timestamp
      // to figure out where each value falls in the visible range.
      final dataForIndicator = params.fullCandles ?? params.candles;
      final values = indicator.getValues(dataForIndicator);
      
      // Draw the indicator
      indicator.paint(canvas, params, values);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) {
    // Check if overlays or indicators changed by comparing the list reference
    if (overlays != oldDelegate.overlays) return true;
    if (indicators != oldDelegate.indicators) return true;
    
    return params.shouldRepaint(oldDelegate.params) ||
        draggedOverlay != oldDelegate.draggedOverlay ||
        draggedPrice != oldDelegate.draggedPrice ||
        draggedInitialPrice != oldDelegate.draggedInitialPrice ||
        draggedPosition != oldDelegate.draggedPosition ||
        isResizingTop != oldDelegate.isResizingTop ||
        isResizingBottom != oldDelegate.isResizingBottom ||
        isResizingFibonacci != oldDelegate.isResizingFibonacci ||
        isResizingTrendLine != oldDelegate.isResizingTrendLine ||
        isResizingTrendStart != oldDelegate.isResizingTrendStart ||
        isResizingTrendEnd != oldDelegate.isResizingTrendEnd;
  }
}

extension ElementAtOrNull<E> on List<E> {
  E? at(int index) {
    if (index < 0 || index >= length) return null;
    return elementAt(index);
  }
}
