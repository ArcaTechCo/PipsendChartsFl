import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import '../../painter_params.dart';
import '../overlay.dart';

/// Arrow tool for drawing directional arrows on the chart.
///
/// Draws an arrow from a start point to an end point with a customizable arrowhead.
///
/// Example:
/// ```dart
/// ArrowTool(
///   id: 'arrow_1',
///   startTime: timestamp1,
///   startPrice: 100.0,
///   endTime: timestamp2,
///   endPrice: 120.0,
/// )
/// ```
class ArrowTool extends ChartOverlay {
  /// Start point timestamp.
  final int startTime;
  
  /// Start point price.
  final double startPrice;
  
  /// End point timestamp.
  final int endTime;
  
  /// End point price.
  final double endPrice;
  
  /// Visual style for the arrow.
  final ArrowToolStyle style;
  
  /// Configuration options.
  final ArrowToolOptions options;

  ArrowTool({
    String? id,
    required this.startTime,
    required this.startPrice,
    required this.endTime,
    required this.endPrice,
    ArrowToolStyle? style,
    ArrowToolOptions? options,
    bool visible = true,
  })  : style = style ?? const ArrowToolStyle(),
        options = options ?? const ArrowToolOptions(),
        super(
          id: id ?? 'arrow_${startTime}_${endTime}',
          interactive: (options ?? const ArrowToolOptions()).draggable,
          visible: visible,
        );

  @override
  void paint(Canvas canvas, PainterParams params, {bool isBeingDragged = false}) {
    if (!visible) return;
    
    // Find indices for the two points
    final startIndex = params.candles.indexWhere((c) => c.timestamp >= startTime);
    final endIndex = params.candles.indexWhere((c) => c.timestamp >= endTime);
    
    if (startIndex < 0 || endIndex < 0) return;
    
    final x1 = startIndex * params.candleWidth;
    final y1 = params.fitPrice(startPrice);
    final x2 = endIndex * params.candleWidth;
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
    
    // Draw the arrow line
    final linePaint = Paint()
      ..color = style.color
      ..strokeWidth = isBeingDragged ? style.strokeWidth + 1 : style.strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(Offset(x1, y1), Offset(x2, y2), linePaint);
    
    // Draw the arrowhead
    _drawArrowhead(canvas, x1, y1, x2, y2, isBeingDragged);
    
    // Draw handles if draggable
    if (options.draggable) {
      _drawHandle(canvas, x1, y1, 'Start', isBeingDragged);
      _drawHandle(canvas, x2, y2, 'End', isBeingDragged);
    }
  }

  void _drawArrowhead(Canvas canvas, double x1, double y1, double x2, double y2, bool isBeingDragged) {
    // Calculate angle of the line
    final angle = math.atan2(y2 - y1, x2 - x1);
    
    // Arrowhead size
    final headLength = isBeingDragged ? style.arrowheadSize + 2 : style.arrowheadSize;
    final headAngle = style.arrowheadAngle * math.pi / 180; // Convert to radians
    
    // Calculate arrowhead points
    final leftX = x2 - headLength * math.cos(angle - headAngle);
    final leftY = y2 - headLength * math.sin(angle - headAngle);
    final rightX = x2 - headLength * math.cos(angle + headAngle);
    final rightY = y2 - headLength * math.sin(angle + headAngle);
    
    // Draw arrowhead
    final arrowPaint = Paint()
      ..color = style.color
      ..strokeWidth = isBeingDragged ? style.strokeWidth + 1 : style.strokeWidth
      ..style = style.fillArrowhead ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    final path = Path()
      ..moveTo(leftX, leftY)
      ..lineTo(x2, y2)
      ..lineTo(rightX, rightY);
    
    if (style.fillArrowhead) {
      path.close();
    }
    
    canvas.drawPath(path, arrowPaint);
  }

  void _drawHandle(Canvas canvas, double x, double y, String label, bool isBeingDragged) {
    final size = isBeingDragged ? 8.0 : 6.0;
    final opacity = isBeingDragged ? 1.0 : 0.7;
    
    // Draw circle
    final circlePaint = Paint()
      ..color = style.color.withOpacity(opacity)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(x, y), size, circlePaint);
    
    // Draw border
    final borderPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(opacity)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    canvas.drawCircle(Offset(x, y), size, borderPaint);
  }

  @override
  bool hitTest(Offset position, PainterParams params) {
    if (!interactive) return false;
    
    // Find indices for the two points
    final startIndex = params.candles.indexWhere((c) => c.timestamp >= startTime);
    final endIndex = params.candles.indexWhere((c) => c.timestamp >= endTime);
    
    if (startIndex < 0 || endIndex < 0) return false;
    
    final x1 = startIndex * params.candleWidth;
    final y1 = params.fitPrice(startPrice);
    final x2 = endIndex * params.candleWidth;
    final y2 = params.fitPrice(endPrice);
    
    // Test if touching the line
    const hitTolerance = 10.0;
    final distance = _distanceToLineSegment(position, Offset(x1, y1), Offset(x2, y2));
    
    return distance <= hitTolerance;
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

  /// Checks if the position is on the start handle.
  bool hitTestStartHandle(Offset position, PainterParams params) {
    if (!options.draggable) return false;
    
    final startIndex = params.candles.indexWhere((c) => c.timestamp >= startTime);
    if (startIndex < 0) return false;
    
    final x = startIndex * params.candleWidth;
    final y = params.fitPrice(startPrice);
    
    const handleSize = 20.0;
    return (position - Offset(x, y)).distance < handleSize;
  }

  /// Checks if the position is on the end handle.
  bool hitTestEndHandle(Offset position, PainterParams params) {
    if (!options.draggable) return false;
    
    final endIndex = params.candles.indexWhere((c) => c.timestamp >= endTime);
    if (endIndex < 0) return false;
    
    final x = endIndex * params.candleWidth;
    final y = params.fitPrice(endPrice);
    
    const handleSize = 20.0;
    return (position - Offset(x, y)).distance < handleSize;
  }

  /// Creates a copy with updated points.
  ArrowTool withPoints({
    int? startTime,
    double? startPrice,
    int? endTime,
    double? endPrice,
  }) {
    return ArrowTool(
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

  /// Creates a copy with updated properties.
  ArrowTool copyWith({
    int? startTime,
    double? startPrice,
    int? endTime,
    double? endPrice,
    ArrowToolStyle? style,
    ArrowToolOptions? options,
    bool? visible,
  }) {
    return ArrowTool(
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

/// Visual style for an arrow tool.
class ArrowToolStyle {
  /// Color of the arrow.
  final Color color;
  
  /// Stroke width of the arrow line.
  final double strokeWidth;
  
  /// Size of the arrowhead.
  final double arrowheadSize;
  
  /// Angle of the arrowhead in degrees.
  final double arrowheadAngle;
  
  /// Whether to fill the arrowhead.
  final bool fillArrowhead;

  const ArrowToolStyle({
    this.color = const Color(0xFF2196F3),
    this.strokeWidth = 2.0,
    this.arrowheadSize = 12.0,
    this.arrowheadAngle = 30.0,
    this.fillArrowhead = true,
  });

  ArrowToolStyle copyWith({
    Color? color,
    double? strokeWidth,
    double? arrowheadSize,
    double? arrowheadAngle,
    bool? fillArrowhead,
  }) {
    return ArrowToolStyle(
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      arrowheadSize: arrowheadSize ?? this.arrowheadSize,
      arrowheadAngle: arrowheadAngle ?? this.arrowheadAngle,
      fillArrowhead: fillArrowhead ?? this.fillArrowhead,
    );
  }
}

/// Configuration options for an arrow tool.
class ArrowToolOptions {
  /// Whether the arrow can be dragged.
  final bool draggable;
  
  /// Callback when the arrow is moved.
  /// Parameters: startTime, startPrice, endTime, endPrice
  final void Function(int startTime, double startPrice, int endTime, double endPrice)? onMoved;
  
  /// Callback when the arrow is deleted.
  final VoidCallback? onDelete;

  const ArrowToolOptions({
    this.draggable = true,
    this.onMoved,
    this.onDelete,
  });

  ArrowToolOptions copyWith({
    bool? draggable,
    void Function(int, double, int, double)? onMoved,
    VoidCallback? onDelete,
  }) {
    return ArrowToolOptions(
      draggable: draggable ?? this.draggable,
      onMoved: onMoved ?? this.onMoved,
      onDelete: onDelete ?? this.onDelete,
    );
  }
}
