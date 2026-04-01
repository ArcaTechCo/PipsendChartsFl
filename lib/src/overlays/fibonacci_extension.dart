import 'package:flutter/widgets.dart';
import '../painter_params.dart';
import 'overlay.dart';
import 'fibonacci_extension_options.dart';
import 'fibonacci_style.dart';

/// Fibonacci Extension overlay that projects extension levels based on 3 points.
///
/// Uses points A (start), B (middle), and C (end) to calculate extension levels.
/// Extension levels are projected beyond point C.
///
/// Example:
/// ```dart
/// FibonacciExtension(
///   id: 'fib_ext_1',
///   pointAPrice: 100.0,
///   pointATime: timestamp1,
///   pointBPrice: 120.0,
///   pointBTime: timestamp2,
///   pointCPrice: 110.0,
///   pointCTime: timestamp3,
/// )
/// ```
class FibonacciExtension extends ChartOverlay {
  /// Point A price (start of the move).
  final double pointAPrice;
  
  /// Point A timestamp.
  final int pointATime;
  
  /// Point B price (end of the first move).
  final double pointBPrice;
  
  /// Point B timestamp.
  final int pointBTime;
  
  /// Point C price (start of the retracement).
  final double pointCPrice;
  
  /// Point C timestamp.
  final int pointCTime;
  
  /// Visual style for the Fibonacci levels.
  final FibonacciStyle style;
  
  /// Configuration options.
  final FibonacciExtensionOptions options;
  
  /// Standard Fibonacci extension levels.
  static const List<double> levels = [
    0.0,    // 0% (Point C)
    0.382,  // 38.2%
    0.618,  // 61.8% (Golden Ratio)
    1.0,    // 100%
    1.272,  // 127.2%
    1.618,  // 161.8% (Golden Ratio)
    2.0,    // 200%
    2.618,  // 261.8%
  ];

  FibonacciExtension({
    String? id,
    required this.pointAPrice,
    required this.pointATime,
    required this.pointBPrice,
    required this.pointBTime,
    required this.pointCPrice,
    required this.pointCTime,
    FibonacciStyle? style,
    FibonacciExtensionOptions? options,
    bool visible = true,
  })  : style = style ?? const FibonacciStyle(),
        options = options ?? const FibonacciExtensionOptions(),
        super(
          id: id ?? 'fib_ext_${pointATime}_${pointBTime}_${pointCTime}',
          interactive: (options ?? const FibonacciExtensionOptions()).draggable,
          visible: visible,
        );

  /// Calculates the price at a specific extension level.
  /// Extension is based on the AB move projected from point C.
  double getPriceAtLevel(double level) {
    final abMove = pointBPrice - pointAPrice;
    final direction = abMove > 0 ? 1 : -1;
    return pointCPrice + (abMove * level * direction);
  }

  @override
  void paint(Canvas canvas, PainterParams params, {bool isBeingDragged = false}) {
    if (!visible) return;
    
    // Find screen coordinates for the three points
    final xA = params.fitTimestamp(pointATime);
    final xB = params.fitTimestamp(pointBTime);
    final xC = params.fitTimestamp(pointCTime);
    if (xA == null || xB == null || xC == null) return;

    final yA = params.fitPrice(pointAPrice);
    final yB = params.fitPrice(pointBPrice);
    final yC = params.fitPrice(pointCPrice);
    
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
    
    // Draw connecting lines A-B-C
    final linePaint = Paint()
      ..color = style.level50Color.withOpacity(0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(Offset(xA, yA), Offset(xB, yB), linePaint);
    canvas.drawLine(Offset(xB, yB), Offset(xC, yC), linePaint);
    
    // Draw extension levels from point C onwards
    final startX = xC;
    final endX = params.chartWidth;
    
    for (final level in levels) {
      final price = getPriceAtLevel(level);
      final y = params.fitPrice(price);
      
      // Skip if outside visible range
      if (y < 0 || y > params.chartHeight) continue;
      
      // Draw horizontal line with color based on level
      final lineColor = style.getColorForLevel(level.clamp(0.0, 1.0));
      final linePaint = Paint()
        ..color = lineColor
        ..strokeWidth = style.lineWidth
        ..style = PaintingStyle.stroke;
      
      canvas.drawLine(Offset(startX, y), Offset(endX, y), linePaint);
      
      // Draw level label
      if (options.showLabels) {
        _drawLevelLabel(canvas, level, price, endX, y);
      }
    }
    
    // Draw point markers
    if (options.draggable) {
      _drawPointMarker(canvas, xA, yA, 'A', isBeingDragged);
      _drawPointMarker(canvas, xB, yB, 'B', isBeingDragged);
      _drawPointMarker(canvas, xC, yC, 'C', isBeingDragged);
    }
  }

  void _drawLevelLabel(Canvas canvas, double level, double price, double x, double y) {
    final percentage = (level * 100).toStringAsFixed(1);
    final priceText = price.toStringAsFixed(2);
    final text = '$percentage% ($priceText)';
    
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
    
    // Position label on the right
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
    
    // Test if touching any of the extension levels
    const hitTolerance = 10.0;
    
    for (final level in levels) {
      final price = getPriceAtLevel(level);
      final y = params.fitPrice(price);
      
      if ((position.dy - y).abs() < hitTolerance) {
        return true;
      }
    }
    
    return false;
  }

  /// Checks if the position is on point A.
  bool hitTestPointA(Offset position, PainterParams params) {
    if (!options.draggable) return false;
    
    final x = params.fitTimestamp(pointATime);
    if (x == null) return false;

    final y = params.fitPrice(pointAPrice);
    
    const handleSize = 20.0;
    return (position - Offset(x, y)).distance < handleSize;
  }

  /// Checks if the position is on point B.
  bool hitTestPointB(Offset position, PainterParams params) {
    if (!options.draggable) return false;
    
    final x = params.fitTimestamp(pointBTime);
    if (x == null) return false;

    final y = params.fitPrice(pointBPrice);
    
    const handleSize = 20.0;
    return (position - Offset(x, y)).distance < handleSize;
  }

  /// Checks if the position is on point C.
  bool hitTestPointC(Offset position, PainterParams params) {
    if (!options.draggable) return false;
    
    final x = params.fitTimestamp(pointCTime);
    if (x == null) return false;

    final y = params.fitPrice(pointCPrice);
    
    const handleSize = 20.0;
    return (position - Offset(x, y)).distance < handleSize;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'pointAPrice': pointAPrice,
    'pointATime': pointATime,
    'pointBPrice': pointBPrice,
    'pointBTime': pointBTime,
    'pointCPrice': pointCPrice,
    'pointCTime': pointCTime,
    'style': style.toJson(),
    'options': options.toJson(),
    'visible': visible,
  };

  factory FibonacciExtension.fromJson(Map<String, dynamic> json) {
    return FibonacciExtension(
      id: json['id'] as String?,
      pointAPrice: (json['pointAPrice'] as num).toDouble(),
      pointATime: json['pointATime'] as int,
      pointBPrice: (json['pointBPrice'] as num).toDouble(),
      pointBTime: json['pointBTime'] as int,
      pointCPrice: (json['pointCPrice'] as num).toDouble(),
      pointCTime: json['pointCTime'] as int,
      style: json['style'] != null
          ? FibonacciStyle.fromJson(json['style'] as Map<String, dynamic>)
          : null,
      options: json['options'] != null
          ? FibonacciExtensionOptions.fromJson(json['options'] as Map<String, dynamic>)
          : null,
      visible: json['visible'] as bool? ?? true,
    );
  }

  /// Creates a copy with updated points.
  FibonacciExtension copyWith({
    double? pointAPrice,
    int? pointATime,
    double? pointBPrice,
    int? pointBTime,
    double? pointCPrice,
    int? pointCTime,
    FibonacciStyle? style,
    FibonacciExtensionOptions? options,
    bool? visible,
  }) {
    return FibonacciExtension(
      id: id,
      pointAPrice: pointAPrice ?? this.pointAPrice,
      pointATime: pointATime ?? this.pointATime,
      pointBPrice: pointBPrice ?? this.pointBPrice,
      pointBTime: pointBTime ?? this.pointBTime,
      pointCPrice: pointCPrice ?? this.pointCPrice,
      pointCTime: pointCTime ?? this.pointCTime,
      style: style ?? this.style,
      options: options ?? this.options,
      visible: visible ?? this.visible,
    );
  }
}
