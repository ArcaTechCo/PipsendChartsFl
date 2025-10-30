import 'dart:math';

import 'package:flutter/material.dart';

import 'candle_data.dart';
import 'painter_params.dart';
import 'overlays/overlay.dart';
import 'overlays/trading_line.dart';
import 'overlays/price_zone.dart';
import 'overlays/fibonacci_retracement.dart';
import 'overlays/trend_line.dart';
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
  final Offset? draggedPosition;
  final bool isResizingTop;
  final bool isResizingBottom;
  final bool isResizingFibonacci;
  final bool isResizingTrendLine;
  final bool isResizingTrendStart;
  final bool isResizingTrendEnd;

  ChartPainter({
    required this.params,
    required this.getTimeLabel,
    required this.getPriceLabel,
    required this.getOverlayInfo,
    this.overlays = const [],
    this.indicators = const [],
    this.draggedOverlay,
    this.draggedPrice,
    this.draggedPosition,
    this.isResizingTop = false,
    this.isResizingBottom = false,
    this.isResizingFibonacci = false,
    this.isResizingTrendLine = false,
    this.isResizingTrendStart = false,
    this.isResizingTrendEnd = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw time labels (dates) & price labels
    _drawTimeLabels(canvas, params);
    _drawPriceGridAndLabels(canvas, params);

    // Draw prices, volumes & trend line
    canvas.save();
    canvas.clipRect(Offset.zero & Size(params.chartWidth, params.chartHeight));
    // canvas.drawRect(
    //   // apply yellow tint to clipped area (for debugging)
    //   Offset.zero & Size(params.chartWidth, params.chartHeight),
    //   Paint()..color = Colors.yellow[100]!,
    // );
    canvas.translate(params.xShift, 0);
    for (int i = 0; i < params.candles.length; i++) {
      _drawSingleDay(canvas, params, i);
    }
    canvas.restore();

    // Draw overlays (trading lines, etc.)
    _drawOverlays(canvas, params);

    // Draw indicators
    _drawIndicators(canvas, params);

    // Draw tap highlight & overlay
    if (params.tapPosition != null) {
      if (params.tapPosition!.dx < params.chartWidth) {
        _drawTapHighlightAndOverlay(canvas, params);
      }
    }
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
            final PriceZone draggedZone;
            const minZoneHeight = 0.2; // Minimum height as percentage of zone
            
            if (isResizingTop) {
              // Resizing top edge (maxPrice)
              final newMaxPrice = draggedPrice!;
              final minAllowedMaxPrice = overlay.minPrice + (overlay.maxPrice - overlay.minPrice) * minZoneHeight;
              draggedZone = overlay.withRange(
                overlay.minPrice,
                newMaxPrice > minAllowedMaxPrice ? newMaxPrice : minAllowedMaxPrice,
              );
            } else if (isResizingBottom) {
              // Resizing bottom edge (minPrice)
              final newMinPrice = draggedPrice!;
              final maxAllowedMinPrice = overlay.maxPrice - (overlay.maxPrice - overlay.minPrice) * minZoneHeight;
              draggedZone = overlay.withRange(
                newMinPrice < maxAllowedMinPrice ? newMinPrice : maxAllowedMinPrice,
                overlay.maxPrice,
              );
            } else {
              // Regular drag - move entire zone
              final offset = draggedPrice! - overlay.centerPrice;
              draggedZone = overlay.withRange(
                overlay.minPrice + offset,
                overlay.maxPrice + offset,
              );
            }
            draggedZone.paint(canvas, params, isBeingDragged: true);
          } else if (overlay is FibonacciRetracement) {
            // Handle resize vs drag
            final FibonacciRetracement draggedFib;
            
            if (isResizingFibonacci) {
              // Resizing one edge
              if (isResizingTop) {
                // Resizing top edge (highPrice)
                final newHighPrice = draggedPrice!;
                final newLowPrice = overlay.lowPrice;
                // Ensure minimum height
                final originalHeight = overlay.highPrice - overlay.lowPrice;
                final minHeight = (originalHeight * 0.2).clamp(1.0, double.infinity);
                final minAllowedHighPrice = newLowPrice + minHeight;
                draggedFib = overlay.withPrices(
                  newHighPrice > minAllowedHighPrice ? newHighPrice : minAllowedHighPrice,
                  newLowPrice,
                );
              } else {
                // Resizing bottom edge (lowPrice)
                final newHighPrice = overlay.highPrice;
                final newLowPrice = draggedPrice!;
                // Ensure minimum height
                final originalHeight = overlay.highPrice - overlay.lowPrice;
                final minHeight = (originalHeight * 0.2).clamp(1.0, double.infinity);
                final maxAllowedLowPrice = newHighPrice - minHeight;
                draggedFib = overlay.withPrices(
                  newHighPrice,
                  newLowPrice < maxAllowedLowPrice ? newLowPrice : maxAllowedLowPrice,
                );
              }
            } else {
              // Move entire Fibonacci retracement
              final offset = draggedPrice! - ((overlay.highPrice + overlay.lowPrice) / 2);
              draggedFib = overlay.withPrices(
                overlay.highPrice + offset,
                overlay.lowPrice + offset,
              );
            }
            draggedFib.paint(canvas, params, isBeingDragged: true);
          } else if (overlay is TrendLine) {
            // Handle resize vs drag for TrendLine
            final TrendLine draggedTrend;
            
            if (isResizingTrendLine && draggedPosition != null) {
              // Resizing one endpoint - calculate new timestamp from X position
              final candleIndex = params.getCandleIndexFromOffset(draggedPosition!.dx);
              final clampedIndex = candleIndex.clamp(0, params.candles.length - 1);
              final newTimestamp = params.candles[clampedIndex].timestamp;
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
              
              // Calculate time offset based on X movement
              final startIndex = params.candles.indexWhere((c) => c.timestamp >= overlay.startTime);
              if (startIndex >= 0) {
                final startX = params.xShift + startIndex * params.candleWidth;
                final deltaX = draggedPosition!.dx - startX;
                final candleOffset = (deltaX / params.candleWidth).round();
                
                // Find new timestamps
                final newStartIndex = (startIndex + candleOffset).clamp(0, params.candles.length - 1);
                final endIndex = params.candles.indexWhere((c) => c.timestamp >= overlay.endTime);
                final newEndIndex = endIndex >= 0 ? (endIndex + candleOffset).clamp(0, params.candles.length - 1) : newStartIndex;
                
                draggedTrend = overlay.withPoints(
                  startTime: params.candles[newStartIndex].timestamp,
                  startPrice: overlay.startPrice + priceOffset,
                  endTime: params.candles[newEndIndex].timestamp,
                  endPrice: overlay.endPrice + priceOffset,
                );
              } else {
                // Fallback: just move price
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
          } else {
            overlay.paint(canvas, params, isBeingDragged: true);
          }
        } else {
          overlay.paint(canvas, params, isBeingDragged: false);
        }
      }
    }
  }

  void _drawTimeLabels(canvas, PainterParams params) {
    // We draw one time label per 90 pixels of screen width
    final lineCount = params.chartWidth ~/ 90;
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

  void _drawPriceGridAndLabels(canvas, PainterParams params) {
    [0.0, 0.25, 0.5, 0.75, 1.0]
        .map((v) => ((params.maxPrice - params.minPrice) * v) + params.minPrice)
        .forEach((y) {
      canvas.drawLine(
        Offset(0, params.fitPrice(y)),
        Offset(params.chartWidth, params.fitPrice(y)),
        Paint()
          ..strokeWidth = 0.5
          ..color = params.style.priceGridLineColor,
      );
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
    // Draw price bar
    final open = candle.open;
    final close = candle.close;
    final high = candle.high;
    final low = candle.low;
    if (open != null && close != null) {
      final color = open > close
          ? params.style.priceLossColor
          : params.style.priceGainColor;
      canvas.drawLine(
        Offset(x, params.fitPrice(open)),
        Offset(x, params.fitPrice(close)),
        Paint()
          ..strokeWidth = thickWidth
          ..color = color,
      );
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
    canvas.save();
    canvas.translate(params.xShift, 0.0);
    // Draw highlight bar (selection box)
    canvas.drawLine(
        Offset(i * params.candleWidth, 0.0),
        Offset(i * params.candleWidth, params.chartHeight),
        Paint()
          ..strokeWidth = max(params.candleWidth * 0.88, 1.0)
          ..color = params.style.selectionHighlightColor);
    canvas.restore();
    
    // Draw horizontal price line at tap position
    if (params.tapPrice != null) {
      final priceY = params.fitPrice(params.tapPrice!);
      canvas.drawLine(
        Offset(0, priceY),
        Offset(params.chartWidth, priceY),
        Paint()
          ..strokeWidth = 1.0
          ..color = params.style.selectionHighlightColor.withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke,
      );
      
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
    canvas.clipRect(Offset.zero & Size(params.chartWidth, params.chartHeight));

    for (final indicator in indicators) {
      if (!indicator.visible) continue;

      // Calculate indicator values
      final values = indicator.getValues(params.candles);
      
      // Draw the indicator
      canvas.save();
      canvas.translate(params.xShift, 0);
      indicator.paint(canvas, params, values);
      canvas.restore();
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
