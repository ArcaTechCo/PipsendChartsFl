import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import '../../painter_params.dart';
import '../overlay.dart';

/// Circle tool for drawing circles/ellipses on the chart.
///
/// Draws a circle from a center point with a specified radius.
/// Can be configured to draw filled or outlined circles.
///
/// Example:
/// ```dart
/// CircleTool(
///   id: 'circle_1',
///   centerTime: timestamp,
///   centerPrice: 100.0,
///   radiusTime: 5 * 86400000, // 5 days in milliseconds
///   radiusPrice: 10.0,
/// )
/// ```
class CircleTool extends ChartOverlay {
  /// Center point timestamp.
  final int centerTime;
  
  /// Center point price.
  final double centerPrice;
  
  /// Radius in time (milliseconds).
  final int radiusTime;
  
  /// Radius in price units.
  final double radiusPrice;
  
  /// Visual style for the circle.
  final CircleToolStyle style;
  
  /// Configuration options.
  final CircleToolOptions options;

  CircleTool({
    String? id,
    required this.centerTime,
    required this.centerPrice,
    required this.radiusTime,
    required this.radiusPrice,
    CircleToolStyle? style,
    CircleToolOptions? options,
    bool visible = true,
  })  : style = style ?? const CircleToolStyle(),
        options = options ?? const CircleToolOptions(),
        super(
          id: id ?? 'circle_${centerTime}',
          interactive: (options ?? const CircleToolOptions()).draggable,
          visible: visible,
        );

  @override
  void paint(Canvas canvas, PainterParams params, {bool isBeingDragged = false}) {
    if (!visible) return;
    
    // Find center point
    final centerX = params.fitTimestamp(centerTime);
    if (centerX == null) return;

    final centerY = params.fitPrice(centerPrice);

    // Calculate radius in pixels
    final edgeX = params.fitTimestamp(centerTime + radiusTime);
    final radiusX = edgeX != null ? (edgeX - centerX).abs() : radiusTime / (24 * 60 * 60 * 1000) * params.candleWidth;
    
    // For price: convert price difference to pixels
    final topPrice = centerPrice + radiusPrice;
    final bottomPrice = centerPrice - radiusPrice;
    final topY = params.fitPrice(topPrice);
    final bottomY = params.fitPrice(bottomPrice);
    final radiusY = (bottomY - topY) / 2;
    
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
    
    // Draw the circle/ellipse
    final rect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: radiusX.abs() * 2,
      height: radiusY.abs() * 2,
    );
    
    // Draw fill if enabled
    if (style.filled) {
      final fillPaint = Paint()
        ..color = style.fillColor.withOpacity(style.fillOpacity)
        ..style = PaintingStyle.fill;
      canvas.drawOval(rect, fillPaint);
    }
    
    // Draw outline
    final outlinePaint = Paint()
      ..color = style.color
      ..strokeWidth = isBeingDragged ? style.strokeWidth + 1 : style.strokeWidth
      ..style = PaintingStyle.stroke;
    
    canvas.drawOval(rect, outlinePaint);
    
    // Draw handles if draggable
    if (options.draggable) {
      _drawHandle(canvas, centerX, centerY, 'Center', isBeingDragged);
      // Draw radius handle (right edge)
      _drawHandle(canvas, centerX + radiusX, centerY, 'Radius', isBeingDragged);
    }
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
    
    // Find center point
    final centerX = params.fitTimestamp(centerTime);
    if (centerX == null) return false;

    final centerY = params.fitPrice(centerPrice);

    // Calculate radius in pixels
    final edgeX = params.fitTimestamp(centerTime + radiusTime);
    final radiusX = edgeX != null ? (edgeX - centerX).abs() : radiusTime / (24 * 60 * 60 * 1000) * params.candleWidth;
    
    final topPrice = centerPrice + radiusPrice;
    final bottomPrice = centerPrice - radiusPrice;
    final topY = params.fitPrice(topPrice);
    final bottomY = params.fitPrice(bottomPrice);
    final radiusY = (bottomY - topY) / 2;
    
    // Test if inside the ellipse
    final dx = (position.dx - centerX) / radiusX;
    final dy = (position.dy - centerY) / radiusY;
    final distance = math.sqrt(dx * dx + dy * dy);
    
    // Hit if near the edge (within tolerance)
    const edgeTolerance = 0.15; // 15% tolerance
    return (distance - 1.0).abs() < edgeTolerance;
  }

  /// Checks if the position is on the center handle.
  bool hitTestCenterHandle(Offset position, PainterParams params) {
    if (!options.draggable) return false;
    
    final x = params.fitTimestamp(centerTime);
    if (x == null) return false;

    final y = params.fitPrice(centerPrice);
    
    const handleSize = 20.0;
    return (position - Offset(x, y)).distance < handleSize;
  }

  /// Checks if the position is on the radius handle.
  bool hitTestRadiusHandle(Offset position, PainterParams params) {
    if (!options.draggable) return false;
    
    final centerX = params.fitTimestamp(centerTime);
    if (centerX == null) return false;

    final centerY = params.fitPrice(centerPrice);

    // Calculate radius handle position (right edge)
    final edgeX = params.fitTimestamp(centerTime + radiusTime);
    final radiusX = edgeX != null ? (edgeX - centerX).abs() : radiusTime / (24 * 60 * 60 * 1000) * params.candleWidth;

    final x = centerX + radiusX;
    final y = centerY;
    
    const handleSize = 20.0;
    return (position - Offset(x, y)).distance < handleSize;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'centerTime': centerTime,
    'centerPrice': centerPrice,
    'radiusTime': radiusTime,
    'radiusPrice': radiusPrice,
    'style': {
      'color': style.color.value,
      'strokeWidth': style.strokeWidth,
      'filled': style.filled,
      'fillColor': style.fillColor.value,
      'fillOpacity': style.fillOpacity,
    },
    'options': {
      'draggable': options.draggable,
    },
    'visible': visible,
  };

  factory CircleTool.fromJson(Map<String, dynamic> json) {
    final s = json['style'] as Map<String, dynamic>?;
    final o = json['options'] as Map<String, dynamic>?;
    return CircleTool(
      id: json['id'] as String?,
      centerTime: json['centerTime'] as int,
      centerPrice: (json['centerPrice'] as num).toDouble(),
      radiusTime: json['radiusTime'] as int,
      radiusPrice: (json['radiusPrice'] as num).toDouble(),
      style: s != null ? CircleToolStyle(
        color: Color(s['color'] as int),
        strokeWidth: (s['strokeWidth'] as num?)?.toDouble() ?? 2.0,
        filled: s['filled'] as bool? ?? false,
        fillColor: s['fillColor'] != null ? Color(s['fillColor'] as int) : const Color(0xFF2196F3),
        fillOpacity: (s['fillOpacity'] as num?)?.toDouble() ?? 0.2,
      ) : null,
      options: o != null ? CircleToolOptions(
        draggable: o['draggable'] as bool? ?? true,
      ) : null,
      visible: json['visible'] as bool? ?? true,
    );
  }

  /// Creates a copy with updated properties.
  CircleTool copyWith({
    int? centerTime,
    double? centerPrice,
    int? radiusTime,
    double? radiusPrice,
    CircleToolStyle? style,
    CircleToolOptions? options,
    bool? visible,
  }) {
    return CircleTool(
      id: id,
      centerTime: centerTime ?? this.centerTime,
      centerPrice: centerPrice ?? this.centerPrice,
      radiusTime: radiusTime ?? this.radiusTime,
      radiusPrice: radiusPrice ?? this.radiusPrice,
      style: style ?? this.style,
      options: options ?? this.options,
      visible: visible ?? this.visible,
    );
  }
}

/// Visual style for a circle tool.
class CircleToolStyle {
  /// Color of the circle outline.
  final Color color;
  
  /// Stroke width of the circle outline.
  final double strokeWidth;
  
  /// Whether to fill the circle.
  final bool filled;
  
  /// Fill color of the circle.
  final Color fillColor;
  
  /// Opacity of the fill (0.0 to 1.0).
  final double fillOpacity;

  const CircleToolStyle({
    this.color = const Color(0xFF2196F3),
    this.strokeWidth = 2.0,
    this.filled = false,
    this.fillColor = const Color(0xFF2196F3),
    this.fillOpacity = 0.2,
  });

  CircleToolStyle copyWith({
    Color? color,
    double? strokeWidth,
    bool? filled,
    Color? fillColor,
    double? fillOpacity,
  }) {
    return CircleToolStyle(
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      filled: filled ?? this.filled,
      fillColor: fillColor ?? this.fillColor,
      fillOpacity: fillOpacity ?? this.fillOpacity,
    );
  }
}

/// Configuration options for a circle tool.
class CircleToolOptions {
  /// Whether the circle can be dragged.
  final bool draggable;
  
  /// Callback when the circle is moved or resized.
  /// Parameters: centerTime, centerPrice, radiusTime, radiusPrice
  final void Function(int centerTime, double centerPrice, int radiusTime, double radiusPrice)? onMoved;
  
  /// Callback when the circle is deleted.
  final VoidCallback? onDelete;

  const CircleToolOptions({
    this.draggable = true,
    this.onMoved,
    this.onDelete,
  });

  CircleToolOptions copyWith({
    bool? draggable,
    void Function(int, double, int, double)? onMoved,
    VoidCallback? onDelete,
  }) {
    return CircleToolOptions(
      draggable: draggable ?? this.draggable,
      onMoved: onMoved ?? this.onMoved,
      onDelete: onDelete ?? this.onDelete,
    );
  }
}
