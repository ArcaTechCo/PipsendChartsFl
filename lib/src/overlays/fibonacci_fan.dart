import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import '../painter_params.dart';
import 'overlay.dart';
import 'fibonacci_fan_options.dart';
import 'fibonacci_style.dart';

/// Fibonacci Fan overlay that projects radial lines from a pivot point.
///
/// Uses two points (start and end) to establish the trend, then projects
/// fan lines at Fibonacci angles from the start point.
///
/// Example:
/// ```dart
/// FibonacciFan(
///   id: 'fib_fan_1',
///   startPrice: 100.0,
///   startTime: timestamp1,
///   endPrice: 120.0,
///   endTime: timestamp2,
/// )
/// ```
class FibonacciFan extends ChartOverlay {
  /// Start point price (pivot point).
  final double startPrice;
  
  /// Start point timestamp (pivot point).
  final int startTime;
  
  /// End point price (defines the trend).
  final double endPrice;
  
  /// End point timestamp (defines the trend).
  final int endTime;
  
  /// Visual style for the Fibonacci fan.
  final FibonacciStyle style;
  
  /// Configuration options.
  final FibonacciFanOptions options;
  
  /// Fibonacci fan levels (ratios for angle calculation).
  static const List<double> levels = [
    0.382,  // 38.2%
    0.5,    // 50%
    0.618,  // 61.8% (Golden Ratio)
  ];

  FibonacciFan({
    String? id,
    required this.startPrice,
    required this.startTime,
    required this.endPrice,
    required this.endTime,
    FibonacciStyle? style,
    FibonacciFanOptions? options,
    bool visible = true,
  })  : style = style ?? const FibonacciStyle(),
        options = options ?? const FibonacciFanOptions(),
        super(
          id: id ?? 'fib_fan_${startTime}_${endTime}',
          interactive: (options ?? const FibonacciFanOptions()).draggable,
          visible: visible,
        );

  @override
  void paint(Canvas canvas, PainterParams params, {bool isBeingDragged = false}) {
    if (!visible) return;
    
    // Find screen coordinates for the two points
    final x1 = params.fitTimestamp(startTime);
    final x2 = params.fitTimestamp(endTime);
    if (x1 == null || x2 == null) return;

    final y1 = params.fitPrice(startPrice);
    final y2 = params.fitPrice(endPrice);
    
    // Draw background highlight when being dragged
    if (isBeingDragged) {
      final bgPaint = Paint()
        ..color = const Color(0xFF2196F3).withOpacity(0.1)
        ..style = PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, params.chartWidth, params.chartHeight),
        bgPaint,
      );
    }
    
    // Draw the base trend line (from start to end)
    final basePaint = Paint()
      ..color = style.level50Color.withOpacity(0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(Offset(x1, y1), Offset(x2, y2), basePaint);
    
    // Calculate the base angle
    final dx = x2 - x1;
    final dy = y2 - y1;
    final baseAngle = math.atan2(dy, dx);
    
    // Draw fan lines
    for (final level in levels) {
      // Calculate the fan line angle based on Fibonacci level
      final fanAngle = baseAngle * level;
      
      // Project the fan line to the edge of the chart
      final projectionLength = params.chartWidth * 2; // Ensure it reaches the edge
      final endX = x1 + projectionLength * math.cos(fanAngle);
      final endY = y1 + projectionLength * math.sin(fanAngle);
      
      // Clip to chart bounds
      final clippedEnd = _clipLineToChart(
        Offset(x1, y1),
        Offset(endX, endY),
        params.chartWidth,
        params.chartHeight,
      );
      
      if (clippedEnd != null) {
        // Draw fan line with color based on level
        final lineColor = style.getColorForLevel(level);
        final linePaint = Paint()
          ..color = lineColor
          ..strokeWidth = style.lineWidth
          ..style = PaintingStyle.stroke;
        
        canvas.drawLine(Offset(x1, y1), clippedEnd, linePaint);
        
        // Draw level label at the end of the line
        if (options.showLabels) {
          _drawLevelLabel(canvas, level, clippedEnd.dx, clippedEnd.dy);
        }
      }
    }
    
    // Draw point markers
    if (options.draggable) {
      _drawPointMarker(canvas, x1, y1, 'Start', isBeingDragged);
      _drawPointMarker(canvas, x2, y2, 'End', isBeingDragged);
    }
  }

  /// Clips a line to the chart boundaries.
  Offset? _clipLineToChart(Offset start, Offset end, double width, double height) {
    // Simple clipping - find intersection with chart boundaries
    double x = end.dx;
    double y = end.dy;
    
    // Clip to right edge
    if (x > width) {
      final t = (width - start.dx) / (end.dx - start.dx);
      x = width;
      y = start.dy + t * (end.dy - start.dy);
    }
    
    // Clip to left edge
    if (x < 0) {
      final t = (0 - start.dx) / (end.dx - start.dx);
      x = 0;
      y = start.dy + t * (end.dy - start.dy);
    }
    
    // Clip to bottom edge
    if (y > height) {
      final t = (height - start.dy) / (end.dy - start.dy);
      y = height;
      x = start.dx + t * (end.dx - start.dx);
    }
    
    // Clip to top edge
    if (y < 0) {
      final t = (0 - start.dy) / (end.dy - start.dy);
      y = 0;
      x = start.dx + t * (end.dx - start.dx);
    }
    
    // Check if still within bounds
    if (x >= 0 && x <= width && y >= 0 && y <= height) {
      return Offset(x, y);
    }
    
    return null;
  }

  void _drawLevelLabel(Canvas canvas, double level, double x, double y) {
    final percentage = (level * 100).toStringAsFixed(1);
    final text = '$percentage%';
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: style.labelStyle ?? const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    // Position label near the end of the line
    const padding = 4.0;
    final labelX = x - textPainter.width - padding;
    final labelY = y - textPainter.height / 2;
    
    // Draw background
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        labelX - padding,
        labelY - 2,
        textPainter.width + padding * 2,
        textPainter.height + 4,
      ),
      const Radius.circular(3),
    );
    
    final bgPaint = Paint()
      ..color = const Color(0xFF000000).withOpacity(0.7)
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(bgRect, bgPaint);
    
    // Draw text
    textPainter.paint(canvas, Offset(labelX, labelY));
  }

  void _drawPointMarker(Canvas canvas, double x, double y, String label, bool isBeingDragged) {
    final size = isBeingDragged ? 8.0 : 6.0;
    final opacity = isBeingDragged ? 1.0 : 0.7;
    
    // Draw circle
    final circlePaint = Paint()
      ..color = style.level618Color.withOpacity(opacity)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(x, y), size, circlePaint);
    
    // Draw border
    final borderPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(opacity)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    canvas.drawCircle(Offset(x, y), size, borderPaint);
    
    // Draw label
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    textPainter.paint(
      canvas,
      Offset(x + size + 4, y - textPainter.height / 2),
    );
  }

  @override
  bool hitTest(Offset position, PainterParams params) {
    if (!interactive) return false;
    
    // Test if touching any of the fan lines
    final x1 = params.fitTimestamp(startTime);
    final x2 = params.fitTimestamp(endTime);
    if (x1 == null || x2 == null) return false;

    final y1 = params.fitPrice(startPrice);
    final y2 = params.fitPrice(endPrice);
    
    // Calculate the base angle
    final dx = x2 - x1;
    final dy = y2 - y1;
    final baseAngle = math.atan2(dy, dx);
    
    const hitTolerance = 10.0;
    
    // Test each fan line
    for (final level in levels) {
      final fanAngle = baseAngle * level;
      final projectionLength = params.chartWidth * 2;
      final endX = x1 + projectionLength * math.cos(fanAngle);
      final endY = y1 + projectionLength * math.sin(fanAngle);
      
      final distance = _distanceToLineSegment(
        position,
        Offset(x1, y1),
        Offset(endX, endY),
      );
      
      if (distance <= hitTolerance) {
        return true;
      }
    }
    
    return false;
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

  /// Checks if the position is on the start point.
  bool hitTestStartPoint(Offset position, PainterParams params) {
    if (!options.draggable) return false;
    
    final x = params.fitTimestamp(startTime);
    if (x == null) return false;

    final y = params.fitPrice(startPrice);
    
    const handleSize = 20.0;
    return (position - Offset(x, y)).distance < handleSize;
  }

  /// Checks if the position is on the end point.
  bool hitTestEndPoint(Offset position, PainterParams params) {
    if (!options.draggable) return false;
    
    final x = params.fitTimestamp(endTime);
    if (x == null) return false;

    final y = params.fitPrice(endPrice);
    
    const handleSize = 20.0;
    return (position - Offset(x, y)).distance < handleSize;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'startPrice': startPrice,
    'startTime': startTime,
    'endPrice': endPrice,
    'endTime': endTime,
    'style': style.toJson(),
    'options': options.toJson(),
    'visible': visible,
  };

  factory FibonacciFan.fromJson(Map<String, dynamic> json) {
    return FibonacciFan(
      id: json['id'] as String?,
      startPrice: (json['startPrice'] as num).toDouble(),
      startTime: json['startTime'] as int,
      endPrice: (json['endPrice'] as num).toDouble(),
      endTime: json['endTime'] as int,
      style: json['style'] != null
          ? FibonacciStyle.fromJson(json['style'] as Map<String, dynamic>)
          : null,
      options: json['options'] != null
          ? FibonacciFanOptions.fromJson(json['options'] as Map<String, dynamic>)
          : null,
      visible: json['visible'] as bool? ?? true,
    );
  }

  /// Creates a copy with updated points.
  FibonacciFan copyWith({
    double? startPrice,
    int? startTime,
    double? endPrice,
    int? endTime,
    FibonacciStyle? style,
    FibonacciFanOptions? options,
    bool? visible,
  }) {
    return FibonacciFan(
      id: id,
      startPrice: startPrice ?? this.startPrice,
      startTime: startTime ?? this.startTime,
      endPrice: endPrice ?? this.endPrice,
      endTime: endTime ?? this.endTime,
      style: style ?? this.style,
      options: options ?? this.options,
      visible: visible ?? this.visible,
    );
  }
}
