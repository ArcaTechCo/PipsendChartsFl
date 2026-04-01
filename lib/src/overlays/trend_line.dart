import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import '../painter_params.dart';
import 'overlay.dart';
import 'trend_line_options.dart';
import 'trend_line_style.dart';

/// A diagonal trend line overlay that connects two points on the chart.
class TrendLine extends ChartOverlay {
  /// The starting point (timestamp, price).
  final int startTime;
  final double startPrice;
  
  /// The ending point (timestamp, price).
  final int endTime;
  final double endPrice;
  
  /// Visual style for the trend line.
  final TrendLineStyle style;
  
  /// Configuration options.
  final TrendLineOptions options;

  TrendLine({
    String? id,
    required int startTime,
    required double startPrice,
    required int endTime,
    required double endPrice,
    TrendLineStyle? style,
    TrendLineOptions? options,
    bool visible = true,
  })  : // Normalize points: ensure start is always before end
        startTime = startTime <= endTime ? startTime : endTime,
        startPrice = startTime <= endTime ? startPrice : endPrice,
        endTime = startTime <= endTime ? endTime : startTime,
        endPrice = startTime <= endTime ? endPrice : startPrice,
        style = style ?? const TrendLineStyle(),
        options = options ?? const TrendLineOptions(),
        super(
          id: id ?? 'trend_${math.min(startTime, endTime)}_${math.max(startTime, endTime)}',
          interactive: (options ?? const TrendLineOptions()).draggable,
          visible: visible,
        );

  /// Calculates the angle of the trend line in degrees.
  /// Note: This is a placeholder. The actual visual angle is calculated in paint()
  /// based on screen coordinates.
  double get angle {
    final dy = endPrice - startPrice;
    final dx = (endTime - startTime).toDouble();
    return math.atan2(dy, dx) * 180 / math.pi;
  }
  
  /// Calculates the visual angle based on screen coordinates.
  double calculateVisualAngle(PainterParams params) {
    final x1 = params.fitTimestamp(startTime);
    final x2 = params.fitTimestamp(endTime);
    if (x1 == null || x2 == null) return 0.0;

    final y1 = params.fitPrice(startPrice);
    final y2 = params.fitPrice(endPrice);
    
    final dx = x2 - x1;
    final dy = y2 - y1;
    
    // Calculate angle in degrees (negative because Y axis is inverted in canvas)
    return -math.atan2(dy, dx) * 180 / math.pi;
  }

  @override
  void paint(Canvas canvas, PainterParams params, {bool isBeingDragged = false}) {
    if (!visible) return;

    // Get the visible time range
    final visibleStartTime = params.candles.first.timestamp;
    final visibleEndTime = params.candles.last.timestamp;
    
    // Calculate line points
    double x1, y1, x2, y2;
    
    // Start point
    final startIndex = params.candles.indexWhere((c) => c.timestamp >= startTime);
    if (startIndex >= 0) {
      x1 = startIndex * params.candleWidth;
      y1 = params.fitPrice(startPrice);
    } else {
      // If start is before visible range and extendRight is true
      if (options.extendLeft) {
        x1 = 0;
        // Calculate price at x=0 based on line equation
        final slope = (endPrice - startPrice) / (endTime - startTime);
        final priceAtStart = startPrice + slope * (visibleStartTime - startTime);
        y1 = params.fitPrice(priceAtStart);
      } else {
        return; // Don't draw if start is not visible and not extending
      }
    }
    
    // End point
    final endIndex = params.candles.indexWhere((c) => c.timestamp >= endTime);
    if (endIndex >= 0) {
      x2 = endIndex * params.candleWidth;
      y2 = params.fitPrice(endPrice);
    } else {
      // If end is after visible range and extendRight is true
      if (options.extendRight) {
        x2 = params.chartWidth;
        // Calculate price at x=chartWidth based on line equation
        final slope = (endPrice - startPrice) / (endTime - startTime);
        final priceAtEnd = startPrice + slope * (visibleEndTime - startTime);
        y2 = params.fitPrice(priceAtEnd);
      } else {
        return; // Don't draw if end is not visible and not extending
      }
    }
    
    // Check if line is completely outside visible range
    // Don't draw if both points are before or after the visible range
    if (startTime > visibleEndTime || endTime < visibleStartTime) {
      return; // Line is completely outside visible range
    }
    
    // Extend line if options are enabled
    if (options.extendLeft && startIndex >= 0) {
      final slope = (y2 - y1) / (x2 - x1);
      y1 = y1 - slope * x1;
      x1 = 0;
    }
    
    if (options.extendRight && endIndex >= 0) {
      final slope = (y2 - y1) / (x2 - x1);
      final extension = params.chartWidth - x2;
      y2 = y2 + slope * extension;
      x2 = params.chartWidth;
    }
    
    // Draw the line
    final paint = Paint()
      ..color = isBeingDragged ? style.color.withOpacity(0.8) : style.color
      ..strokeWidth = isBeingDragged ? style.lineWidth + 1.0 : style.lineWidth
      ..style = PaintingStyle.stroke;
    
    if (style.dashPattern.isEmpty) {
      // Solid line
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    } else {
      // Dashed line
      _drawDashedLine(canvas, Offset(x1, y1), Offset(x2, y2), paint, style.dashPattern);
    }
    
    // Draw angle label if enabled
    if (options.showAngle) {
      _drawAngleLabel(canvas, x2, y2, params);
    }
    
    // Draw resize handles if draggable
    if (options.draggable) {
      _drawResizeHandles(canvas, x1, y1, x2, y2, isBeingDragged);
    }
  }
  
  void _drawResizeHandles(Canvas canvas, double x1, double y1, double x2, double y2, bool isBeingDragged) {
    // Make handles more visible when being dragged
    final handleSize = isBeingDragged ? 8.0 : 6.0;
    final opacity = isBeingDragged ? 1.0 : 0.7;
    
    final handlePaint = Paint()
      ..color = style.color.withOpacity(opacity)
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

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint, List<double> pattern) {
    final path = Path();
    final distance = (end - start).distance;
    final unitVector = (end - start) / distance;
    
    double currentDistance = 0;
    int patternIndex = 0;
    bool draw = true;
    
    path.moveTo(start.dx, start.dy);
    
    while (currentDistance < distance) {
      final segmentLength = pattern[patternIndex % pattern.length];
      final nextDistance = math.min(currentDistance + segmentLength, distance);
      final nextPoint = start + unitVector * nextDistance;
      
      if (draw) {
        path.lineTo(nextPoint.dx, nextPoint.dy);
      } else {
        path.moveTo(nextPoint.dx, nextPoint.dy);
      }
      
      currentDistance = nextDistance;
      patternIndex++;
      draw = !draw;
    }
    
    canvas.drawPath(path, paint);
  }

  void _drawAngleLabel(Canvas canvas, double x, double y, PainterParams params) {
    // Calculate the visual angle based on screen coordinates
    final visualAngle = calculateVisualAngle(params);
    final angleText = '${visualAngle.toStringAsFixed(1)}°';
    final textStyle = style.labelStyle ?? const TextStyle(
      color: Color(0xFFFFFFFF),
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );
    
    final textSpan = TextSpan(text: angleText, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    // Position label near the end point
    final labelX = x + 8;
    final labelY = y - textPainter.height / 2;
    
    // Draw background
    final bgPaint = Paint()
      ..color = const Color(0xFF000000).withOpacity(0.6)
      ..style = PaintingStyle.fill;
    
    final bgRect = Rect.fromLTWH(
      labelX - 4,
      labelY - 2,
      textPainter.width + 8,
      textPainter.height + 4,
    );
    canvas.drawRect(bgRect, bgPaint);
    
    // Draw text
    textPainter.paint(canvas, Offset(labelX, labelY));
  }

  @override
  bool hitTest(Offset position, PainterParams params) {
    if (!interactive) return false;
    
    // Find the line segment in screen coordinates
    final x1 = params.fitTimestamp(startTime);
    final x2 = params.fitTimestamp(endTime);
    if (x1 == null || x2 == null) return false;

    final y1 = params.fitPrice(startPrice);
    final y2 = params.fitPrice(endPrice);
    
    // Calculate distance from point to line segment
    final distance = _distanceToLineSegment(position, Offset(x1, y1), Offset(x2, y2));
    
    // Allow 10px tolerance
    return distance <= 10.0;
  }

  /// Checks if the position is on the start handle.
  bool hitTestStartHandle(Offset position, PainterParams params) {
    if (!options.draggable) return false;
    
    final x = params.fitTimestamp(startTime);
    if (x == null) return false;

    final y = params.fitPrice(startPrice);
    
    final handleSize = 20.0; // Larger touch area
    final dx = (position.dx - x).abs();
    final dy = (position.dy - y).abs();
    
    return dx <= handleSize && dy <= handleSize;
  }
  
  /// Checks if the position is on the end handle.
  bool hitTestEndHandle(Offset position, PainterParams params) {
    if (!options.draggable) return false;
    
    final x = params.fitTimestamp(endTime);
    if (x == null) return false;

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
  TrendLine withPoints({
    int? startTime,
    double? startPrice,
    int? endTime,
    double? endPrice,
  }) {
    return TrendLine(
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'startTime': startTime,
    'startPrice': startPrice,
    'endTime': endTime,
    'endPrice': endPrice,
    'style': style.toJson(),
    'options': options.toJson(),
    'visible': visible,
  };

  factory TrendLine.fromJson(Map<String, dynamic> json) {
    return TrendLine(
      id: json['id'] as String?,
      startTime: json['startTime'] as int,
      startPrice: (json['startPrice'] as num).toDouble(),
      endTime: json['endTime'] as int,
      endPrice: (json['endPrice'] as num).toDouble(),
      style: json['style'] != null
          ? TrendLineStyle.fromJson(json['style'] as Map<String, dynamic>)
          : null,
      options: json['options'] != null
          ? TrendLineOptions.fromJson(json['options'] as Map<String, dynamic>)
          : null,
      visible: json['visible'] as bool? ?? true,
    );
  }

  TrendLine copyWith({
    String? id,
    int? startTime,
    double? startPrice,
    int? endTime,
    double? endPrice,
    TrendLineStyle? style,
    TrendLineOptions? options,
    bool? visible,
  }) {
    return TrendLine(
      id: id ?? this.id,
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
