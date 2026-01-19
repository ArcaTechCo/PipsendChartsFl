import 'package:flutter/widgets.dart';
import '../../painter_params.dart';
import '../overlay.dart';

/// Brush tool for drawing freehand lines on the chart.
///
/// Stores a series of points and draws a smooth path through them.
///
/// Example:
/// ```dart
/// BrushTool(
///   id: 'brush_1',
///   points: [
///     BrushPoint(timestamp: t1, price: 100.0),
///     BrushPoint(timestamp: t2, price: 101.0),
///   ],
/// )
/// ```
class BrushTool extends ChartOverlay {
  /// List of points that make up the brush stroke.
  final List<BrushPoint> points;
  
  /// Visual style for the brush.
  final BrushToolStyle style;
  
  /// Configuration options.
  final BrushToolOptions options;

  BrushTool({
    String? id,
    required this.points,
    BrushToolStyle? style,
    BrushToolOptions? options,
    bool visible = true,
  })  : style = style ?? const BrushToolStyle(),
        options = options ?? const BrushToolOptions(),
        super(
          id: id ?? 'brush_${DateTime.now().millisecondsSinceEpoch}',
          interactive: (options ?? const BrushToolOptions()).draggable,
          visible: visible,
        );

  @override
  void paint(Canvas canvas, PainterParams params, {bool isBeingDragged = false}) {
    if (!visible || points.isEmpty) return;
    
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
    
    // Convert points to screen coordinates
    final screenPoints = <Offset>[];
    for (final point in points) {
      final index = params.candles.indexWhere((c) => c.timestamp >= point.timestamp);
      if (index >= 0) {
        final x = index * params.candleWidth;
        final y = params.fitPrice(point.price);
        screenPoints.add(Offset(x, y));
      }
    }
    
    if (screenPoints.isEmpty) return;
    
    // Draw the path
    final path = Path();
    path.moveTo(screenPoints.first.dx, screenPoints.first.dy);
    
    if (style.smooth && screenPoints.length > 2) {
      // Draw smooth curve using quadratic bezier
      for (int i = 0; i < screenPoints.length - 1; i++) {
        final current = screenPoints[i];
        final next = screenPoints[i + 1];
        final controlPoint = Offset(
          (current.dx + next.dx) / 2,
          (current.dy + next.dy) / 2,
        );
        path.quadraticBezierTo(current.dx, current.dy, controlPoint.dx, controlPoint.dy);
      }
      // Draw to last point
      final last = screenPoints.last;
      path.lineTo(last.dx, last.dy);
    } else {
      // Draw straight lines
      for (int i = 1; i < screenPoints.length; i++) {
        path.lineTo(screenPoints[i].dx, screenPoints[i].dy);
      }
    }
    
    // Draw the path
    final paint = Paint()
      ..color = style.color
      ..strokeWidth = isBeingDragged ? style.strokeWidth + 1 : style.strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    canvas.drawPath(path, paint);
    
    // Draw handles if draggable
    if (options.draggable && screenPoints.isNotEmpty) {
      _drawHandle(canvas, screenPoints.first.dx, screenPoints.first.dy, isBeingDragged);
      if (screenPoints.length > 1) {
        _drawHandle(canvas, screenPoints.last.dx, screenPoints.last.dy, isBeingDragged);
      }
    }
  }

  void _drawHandle(Canvas canvas, double x, double y, bool isBeingDragged) {
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
    if (!interactive || points.isEmpty) return false;
    
    // Convert points to screen coordinates
    final screenPoints = <Offset>[];
    for (final point in points) {
      final index = params.candles.indexWhere((c) => c.timestamp >= point.timestamp);
      if (index >= 0) {
        final x = index * params.candleWidth;
        final y = params.fitPrice(point.price);
        screenPoints.add(Offset(x, y));
      }
    }
    
    if (screenPoints.isEmpty) return false;
    
    // Test if touching any segment of the path
    const hitTolerance = 10.0;
    for (int i = 0; i < screenPoints.length - 1; i++) {
      final distance = _distanceToLineSegment(
        position,
        screenPoints[i],
        screenPoints[i + 1],
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

  /// Creates a copy with updated properties.
  BrushTool copyWith({
    List<BrushPoint>? points,
    BrushToolStyle? style,
    BrushToolOptions? options,
    bool? visible,
  }) {
    return BrushTool(
      id: id,
      points: points ?? this.points,
      style: style ?? this.style,
      options: options ?? this.options,
      visible: visible ?? this.visible,
    );
  }
}

/// A point in a brush stroke.
class BrushPoint {
  /// Timestamp of the point.
  final int timestamp;
  
  /// Price of the point.
  final double price;

  const BrushPoint({
    required this.timestamp,
    required this.price,
  });

  BrushPoint copyWith({
    int? timestamp,
    double? price,
  }) {
    return BrushPoint(
      timestamp: timestamp ?? this.timestamp,
      price: price ?? this.price,
    );
  }
}

/// Visual style for a brush tool.
class BrushToolStyle {
  /// Color of the brush stroke.
  final Color color;
  
  /// Stroke width of the brush.
  final double strokeWidth;
  
  /// Whether to smooth the path.
  final bool smooth;

  const BrushToolStyle({
    this.color = const Color(0xFFFF5722),
    this.strokeWidth = 2.0,
    this.smooth = true,
  });

  BrushToolStyle copyWith({
    Color? color,
    double? strokeWidth,
    bool? smooth,
  }) {
    return BrushToolStyle(
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      smooth: smooth ?? this.smooth,
    );
  }
}

/// Configuration options for a brush tool.
class BrushToolOptions {
  /// Whether the brush can be dragged.
  final bool draggable;
  
  /// Callback when the brush is moved.
  /// Parameters: offset in time and price
  final void Function(int timeOffset, double priceOffset)? onMoved;
  
  /// Callback when the brush is deleted.
  final VoidCallback? onDelete;

  const BrushToolOptions({
    this.draggable = true,
    this.onMoved,
    this.onDelete,
  });

  BrushToolOptions copyWith({
    bool? draggable,
    void Function(int, double)? onMoved,
    VoidCallback? onDelete,
  }) {
    return BrushToolOptions(
      draggable: draggable ?? this.draggable,
      onMoved: onMoved ?? this.onMoved,
      onDelete: onDelete ?? this.onDelete,
    );
  }
}
