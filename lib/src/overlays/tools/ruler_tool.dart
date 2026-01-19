import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import '../../candle_data.dart';
import '../../painter_params.dart';
import '../overlay.dart';

/// Ruler Tool for measuring distance between two points on the chart.
///
/// Displays measurements in:
/// - Price (absolute difference)
/// - Percentage (%)
/// - Pips (for Forex)
/// - Time (number of bars/candles)
///
/// Example:
/// ```dart
/// RulerTool(
///   id: 'ruler_1',
///   startTime: startTimestamp,
///   startPrice: 150.0,
///   endTime: endTimestamp,
///   endPrice: 160.0,
///   options: RulerToolOptions(
///     showPrice: true,
///     showPercentage: true,
///     showPips: true,
///     showTime: true,
///     pipMultiplier: 10000, // For 4-digit pairs
///   ),
/// )
/// ```
class RulerTool extends ChartOverlay {
  /// Start point timestamp (milliseconds since epoch).
  final int startTime;

  /// Start point price.
  final double startPrice;

  /// End point timestamp (milliseconds since epoch).
  final int endTime;

  /// End point price.
  final double endPrice;

  /// Style configuration.
  final RulerToolStyle style;

  /// Display and measurement options.
  final RulerToolOptions options;

  RulerTool({
    String? id,
    required int startTime,
    required double startPrice,
    required int endTime,
    required double endPrice,
    RulerToolStyle? style,
    RulerToolOptions? options,
    bool visible = true,
  })  : // Normalize points: ensure start is always before end
        startTime = startTime <= endTime ? startTime : endTime,
        startPrice = startTime <= endTime ? startPrice : endPrice,
        endTime = startTime <= endTime ? endTime : startTime,
        endPrice = startTime <= endTime ? endPrice : startPrice,
        style = style ?? const RulerToolStyle(),
        options = options ?? const RulerToolOptions(),
        super(
          id: id ?? 'ruler_${math.min(startTime, endTime)}_${math.max(startTime, endTime)}',
          interactive: (options ?? const RulerToolOptions()).draggable,
          visible: visible,
        );

  /// Calculates price difference.
  double get priceDifference => (endPrice - startPrice).abs();

  /// Calculates percentage change.
  double get percentageChange {
    if (startPrice == 0) return 0;
    return ((endPrice - startPrice) / startPrice) * 100;
  }

  /// Calculates pips (for Forex).
  double get pips => priceDifference * options.pipMultiplier;

  /// Calculates time difference in bars.
  int calculateBars(List<CandleData> candles) {
    if (candles.isEmpty) return 0;
    
    int startIndex = -1;
    int endIndex = -1;

    for (int i = 0; i < candles.length; i++) {
      if (startIndex == -1 && candles[i].timestamp >= startTime) {
        startIndex = i;
      }
      if (candles[i].timestamp >= endTime) {
        endIndex = i;
        break;
      }
    }

    if (startIndex == -1 || endIndex == -1) return 0;
    return (endIndex - startIndex).abs();
  }

  @override
  void paint(Canvas canvas, PainterParams params, {bool isBeingDragged = false}) {
    if (!visible) return;

    // Calculate line points (same as TrendLine)
    double x1, y1, x2, y2;
    
    // Start point
    final startIndex = params.candles.indexWhere((c) => c.timestamp >= startTime);
    if (startIndex >= 0) {
      x1 = startIndex * params.candleWidth;
      y1 = params.fitPrice(startPrice);
    } else {
      return; // Don't draw if start is not visible
    }
    
    // End point
    final endIndex = params.candles.indexWhere((c) => c.timestamp >= endTime);
    if (endIndex >= 0) {
      x2 = endIndex * params.candleWidth;
      y2 = params.fitPrice(endPrice);
    } else {
      return; // Don't draw if end is not visible
    }
    
    // Draw the line
    final paint = Paint()
      ..color = isBeingDragged ? style.lineColor.withOpacity(0.8) : style.lineColor
      ..strokeWidth = isBeingDragged ? style.lineWidth + 1.0 : style.lineWidth
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    
    // Draw arrow heads
    if (style.showArrowHeads) {
      _drawArrowHead(canvas, x1, y1, x2, y2);
      _drawArrowHead(canvas, x2, y2, x1, y1);
    }
    
    // Draw measurements label
    _drawMeasurementsLabel(canvas, params, x1, y1, x2, y2);
    
    // Draw resize handles if draggable (like TrendLine)
    if (options.draggable) {
      _drawResizeHandles(canvas, x1, y1, x2, y2, isBeingDragged);
    }
  }

  void _drawResizeHandles(Canvas canvas, double x1, double y1, double x2, double y2, bool isBeingDragged) {
    // Make handles more visible when being dragged (same as TrendLine)
    final handleSize = isBeingDragged ? 8.0 : 6.0;
    final opacity = isBeingDragged ? 1.0 : 0.7;
    
    final handlePaint = Paint()
      ..color = style.lineColor.withOpacity(opacity)
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    // Start handle
    canvas.drawCircle(Offset(x1, y1), handleSize, handlePaint);
    canvas.drawCircle(Offset(x1, y1), handleSize, borderPaint);
    
    // End handle
    canvas.drawCircle(Offset(x2, y2), handleSize, handlePaint);
    canvas.drawCircle(Offset(x2, y2), handleSize, borderPaint);
  }

  void _drawArrowHead(Canvas canvas, double x, double y, double fromX, double fromY) {
    final angle = math.atan2(y - fromY, x - fromX);
    const arrowSize = 8.0;
    const arrowAngle = 25 * math.pi / 180;

    final path = Path();
    path.moveTo(x, y);
    path.lineTo(
      x - arrowSize * math.cos(angle - arrowAngle),
      y - arrowSize * math.sin(angle - arrowAngle),
    );
    path.moveTo(x, y);
    path.lineTo(
      x - arrowSize * math.cos(angle + arrowAngle),
      y - arrowSize * math.sin(angle + arrowAngle),
    );

    final paint = Paint()
      ..color = style.lineColor
      ..strokeWidth = style.lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paint);
  }

  void _drawMeasurementsLabel(
    Canvas canvas,
    PainterParams params,
    double x1,
    double y1,
    double x2,
    double y2,
  ) {
    final measurements = <String>[];

    // Price
    if (options.showPrice) {
      final sign = endPrice > startPrice ? '+' : '';
      measurements.add('$sign${priceDifference.toStringAsFixed(options.priceDecimals)}');
    }

    // Percentage
    if (options.showPercentage) {
      final sign = percentageChange > 0 ? '+' : '';
      measurements.add('$sign${percentageChange.toStringAsFixed(2)}%');
    }

    // Pips
    if (options.showPips) {
      measurements.add('${pips.toStringAsFixed(1)} pips');
    }

    // Time (bars)
    if (options.showTime) {
      final bars = calculateBars(params.candles);
      measurements.add('$bars bars');
    }

    if (measurements.isEmpty) return;

    // Create text
    final text = measurements.join(' | ');
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: style.labelTextColor,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Position label at midpoint
    final midX = (x1 + x2) / 2;
    final midY = (y1 + y2) / 2;

    // Background
    const padding = 6.0;
    final bgRect = Rect.fromCenter(
      center: Offset(midX, midY),
      width: textPainter.width + padding * 2,
      height: textPainter.height + padding,
    );

    final bgPaint = Paint()
      ..color = style.labelBackgroundColor
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(4)),
      bgPaint,
    );

    // Border
    final borderPaint = Paint()
      ..color = style.lineColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(4)),
      borderPaint,
    );

    // Text
    textPainter.paint(
      canvas,
      Offset(
        midX - textPainter.width / 2,
        midY - textPainter.height / 2,
      ),
    );
  }

  @override
  bool hitTest(Offset position, PainterParams params) {
    if (!interactive) return false;
    
    // Find the line segment in screen coordinates (same as TrendLine)
    final startIndex = params.candles.indexWhere((c) => c.timestamp >= startTime);
    final endIndex = params.candles.indexWhere((c) => c.timestamp >= endTime);
    
    if (startIndex < 0 || endIndex < 0) return false;
    
    final x1 = startIndex * params.candleWidth;
    final y1 = params.fitPrice(startPrice);
    final x2 = endIndex * params.candleWidth;
    final y2 = params.fitPrice(endPrice);
    
    // Calculate distance from point to line segment
    final distance = _distanceToLineSegment(position, Offset(x1, y1), Offset(x2, y2));
    
    // Allow 10px tolerance (same as TrendLine)
    return distance <= 10.0;
  }

  /// Checks if the position is on the start handle.
  bool hitTestStartHandle(Offset position, PainterParams params) {
    if (!options.draggable) return false;
    
    final startIndex = params.candles.indexWhere((c) => c.timestamp >= startTime);
    if (startIndex < 0) return false;
    
    final x = startIndex * params.candleWidth;
    final y = params.fitPrice(startPrice);
    
    final handleSize = 20.0; // Larger touch area
    final dx = (position.dx - x).abs();
    final dy = (position.dy - y).abs();
    
    return dx <= handleSize && dy <= handleSize;
  }
  
  /// Checks if the position is on the end handle.
  bool hitTestEndHandle(Offset position, PainterParams params) {
    if (!options.draggable) return false;
    
    final endIndex = params.candles.indexWhere((c) => c.timestamp >= endTime);
    if (endIndex < 0) return false;
    
    final x = endIndex * params.candleWidth;
    final y = params.fitPrice(endPrice);
    
    final handleSize = 20.0; // Larger touch area
    final dx = (position.dx - x).abs();
    final dy = (position.dy - y).abs();
    
    return dx <= handleSize && dy <= handleSize;
  }

  double _distanceToLineSegment(Offset point, Offset lineStart, Offset lineEnd) {
    final lengthSquared = (lineEnd - lineStart).distanceSquared;
    if (lengthSquared == 0) return (point - lineStart).distance;
    
    final t = ((point - lineStart).dx * (lineEnd - lineStart).dx +
               (point - lineStart).dy * (lineEnd - lineStart).dy) / lengthSquared;
    
    final clampedT = t.clamp(0.0, 1.0);
    final projection = lineStart + (lineEnd - lineStart) * clampedT;
    
    return (point - projection).distance;
  }

  /// Creates a copy with new points.
  RulerTool withPoints({
    int? startTime,
    double? startPrice,
    int? endTime,
    double? endPrice,
  }) {
    return RulerTool(
      id: id,
      startTime: startTime ?? this.startTime,
      startPrice: startPrice ?? this.startPrice,
      endTime: endTime ?? this.endTime,
      endPrice: endPrice ?? this.endPrice,
      style: style,
      options: options,
      visible: visible,
    );
  }

  /// Creates a copy with updated points.
  RulerTool copyWith({
    int? startTime,
    double? startPrice,
    int? endTime,
    double? endPrice,
    RulerToolStyle? style,
    RulerToolOptions? options,
    bool? visible,
  }) {
    return RulerTool(
      id: id,
      startTime: startTime ?? this.startTime,
      startPrice: startPrice ?? this.startPrice,
      endTime: endTime ?? this.endTime,
      endPrice: endPrice ?? this.endPrice,
      style: style ?? this.style,
      options: options ?? this.options,
      visible: visible ?? this.visible,
    );
  }
}

/// Style configuration for Ruler Tool.
class RulerToolStyle {
  /// Color of the ruler line.
  final Color lineColor;

  /// Width of the ruler line.
  final double lineWidth;

  /// Color of the endpoints.
  final Color endpointColor;

  /// Radius of the endpoints.
  final double endpointRadius;

  /// Whether to show arrow heads.
  final bool showArrowHeads;

  /// Text color for measurements label.
  final Color labelTextColor;

  /// Background color for measurements label.
  final Color labelBackgroundColor;

  const RulerToolStyle({
    this.lineColor = const Color(0xFFFFEB3B), // Yellow
    this.lineWidth = 2.0,
    this.endpointColor = const Color(0xFFFFFFFF),
    this.endpointRadius = 5.0,
    this.showArrowHeads = true,
    this.labelTextColor = const Color(0xFF000000),
    this.labelBackgroundColor = const Color(0xFFFFEB3B),
  });
}

/// Options for Ruler Tool display and measurements.
class RulerToolOptions {
  /// Whether to show price difference.
  final bool showPrice;

  /// Number of decimal places for price.
  final int priceDecimals;

  /// Whether to show percentage change.
  final bool showPercentage;

  /// Whether to show pips (for Forex).
  final bool showPips;

  /// Pip multiplier (10000 for 4-digit pairs, 100 for 2-digit pairs).
  final double pipMultiplier;

  /// Whether to show time difference in bars.
  final bool showTime;

  /// Whether the ruler is draggable.
  final bool draggable;

  /// Callback when ruler is moved.
  final void Function(int startTime, double startPrice, int endTime, double endPrice)? onMoved;

  const RulerToolOptions({
    this.showPrice = true,
    this.priceDecimals = 2,
    this.showPercentage = true,
    this.showPips = false,
    this.pipMultiplier = 10000,
    this.showTime = true,
    this.draggable = true,
    this.onMoved,
  });
}
