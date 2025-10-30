import 'package:flutter/widgets.dart';
import '../painter_params.dart';
import 'overlay.dart';
import 'fibonacci_options.dart';
import 'fibonacci_style.dart';

/// A Fibonacci retracement overlay that displays key retracement levels
/// between a high and low price point.
class FibonacciRetracement extends ChartOverlay {
  /// The high price point (typically the swing high).
  final double highPrice;
  
  /// The low price point (typically the swing low).
  final double lowPrice;
  
  /// Visual style for the Fibonacci levels.
  final FibonacciStyle style;
  
  /// Configuration options.
  final FibonacciOptions options;
  
  /// Standard Fibonacci retracement levels.
  static const List<double> levels = [
    0.0,    // 0%
    0.236,  // 23.6%
    0.382,  // 38.2%
    0.5,    // 50%
    0.618,  // 61.8% (Golden Ratio)
    0.786,  // 78.6%
    1.0,    // 100%
  ];

  FibonacciRetracement({
    String? id,
    required this.highPrice,
    required this.lowPrice,
    FibonacciStyle? style,
    FibonacciOptions? options,
    bool visible = true,
  })  : assert(highPrice > lowPrice, 'highPrice must be greater than lowPrice'),
        style = style ?? const FibonacciStyle(),
        options = options ?? const FibonacciOptions(),
        super(
          id: id ?? 'fib_${highPrice.toStringAsFixed(2)}_${lowPrice.toStringAsFixed(2)}',
          interactive: (options ?? const FibonacciOptions()).draggable,
          visible: visible,
        );

  /// Calculates the price at a specific Fibonacci level.
  double getPriceAtLevel(double level) {
    return lowPrice + (highPrice - lowPrice) * (1.0 - level);
  }

  @override
  void paint(Canvas canvas, PainterParams params, {bool isBeingDragged = false}) {
    if (!visible) return;
    
    // Draw background highlight when being dragged
    if (isBeingDragged) {
      final highY = params.fitPrice(highPrice);
      final lowY = params.fitPrice(lowPrice);
      final bgPaint = Paint()
        ..color = const Color(0xFF2196F3).withOpacity(0.1)
        ..style = PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromLTRB(0, highY, params.chartWidth, lowY),
        bgPaint,
      );
    }
    
    // Draw each Fibonacci level
    for (final level in levels) {
      final price = getPriceAtLevel(level);
      final y = params.fitPrice(price);
      
      // Get color for this level
      final color = style.getColorForLevel(level);
      
      // Draw horizontal line
      final paint = Paint()
        ..color = isBeingDragged ? color : color.withOpacity(0.8)
        ..strokeWidth = isBeingDragged ? style.lineWidth + 1.0 : style.lineWidth
        ..style = PaintingStyle.stroke;
      
      final endX = options.extendLines ? params.chartWidth : params.chartWidth * 0.7;
      canvas.drawLine(
        Offset(0, y),
        Offset(endX, y),
        paint,
      );
      
      // Draw label if enabled
      if (options.showLabels) {
        _drawLabel(canvas, level, price, y, params, color);
      }
    }
    
    // Draw resize handles
    if (options.draggable) {
      _drawResizeHandles(canvas, params, isBeingDragged);
    }
  }
  
  void _drawResizeHandles(Canvas canvas, PainterParams params, bool isBeingDragged) {
    final highY = params.fitPrice(highPrice);
    final lowY = params.fitPrice(lowPrice);
    final centerX = params.chartWidth / 2;
    
    // Make handles more visible when being dragged
    final handleSize = isBeingDragged ? 8.0 : 6.0;
    final opacity = isBeingDragged ? 1.0 : 0.7;
    
    final handlePaint = Paint()
      ..color = const Color(0xFF2196F3).withOpacity(opacity)
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    // Top handle (highPrice)
    canvas.drawCircle(Offset(centerX, highY), handleSize, handlePaint);
    canvas.drawCircle(Offset(centerX, highY), handleSize, borderPaint);
    
    // Bottom handle (lowPrice)
    canvas.drawCircle(Offset(centerX, lowY), handleSize, handlePaint);
    canvas.drawCircle(Offset(centerX, lowY), handleSize, borderPaint);
  }

  void _drawLabel(
    Canvas canvas,
    double level,
    double price,
    double y,
    PainterParams params,
    Color color,
  ) {
    final textParts = <String>[];
    
    // Add percentage
    if (options.showPercentages) {
      textParts.add('${(level * 100).toStringAsFixed(1)}%');
    }
    
    // Add price
    if (options.showPrices) {
      textParts.add('\$${price.toStringAsFixed(2)}');
    }
    
    if (textParts.isEmpty) return;
    
    final text = textParts.join(' - ');
    final textStyle = style.labelStyle ?? TextStyle(
      color: color,
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );
    
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    // Position label on the right side
    final x = params.chartWidth - textPainter.width - 8.0;
    final labelY = y - textPainter.height / 2;
    
    // Draw background for better readability
    final bgPaint = Paint()
      ..color = const Color(0xFF000000).withOpacity(0.6)
      ..style = PaintingStyle.fill;
    
    final bgRect = Rect.fromLTWH(
      x - 4,
      labelY - 2,
      textPainter.width + 8,
      textPainter.height + 4,
    );
    canvas.drawRect(bgRect, bgPaint);
    
    // Draw text
    textPainter.paint(canvas, Offset(x, labelY));
  }

  @override
  bool hitTest(Offset position, PainterParams params) {
    if (!interactive) return false;
    
    // Check if position is within the Fibonacci area (between high and low)
    final highY = params.fitPrice(highPrice);
    final lowY = params.fitPrice(lowPrice);
    
    // Check if Y position is within the Fibonacci range
    final minY = highY < lowY ? highY : lowY;
    final maxY = highY > lowY ? highY : lowY;
    
    return position.dy >= minY && position.dy <= maxY;
  }

  /// Checks if the position is on the top handle (highPrice).
  bool hitTestTopHandle(Offset position, PainterParams params) {
    if (!options.draggable) return false;
    
    final highY = params.fitPrice(highPrice);
    final handleSize = 20.0; // Larger touch area for easier interaction
    final centerX = params.chartWidth / 2;
    
    final dx = (position.dx - centerX).abs();
    final dy = (position.dy - highY).abs();
    
    return dx <= handleSize && dy <= handleSize;
  }
  
  /// Checks if the position is on the bottom handle (lowPrice).
  bool hitTestBottomHandle(Offset position, PainterParams params) {
    if (!options.draggable) return false;
    
    final lowY = params.fitPrice(lowPrice);
    final handleSize = 20.0; // Larger touch area for easier interaction
    final centerX = params.chartWidth / 2;
    
    final dx = (position.dx - centerX).abs();
    final dy = (position.dy - lowY).abs();
    
    return dx <= handleSize && dy <= handleSize;
  }

  /// Creates a copy with new price points.
  FibonacciRetracement withPrices(double newHighPrice, double newLowPrice) {
    return FibonacciRetracement(
      id: id,
      highPrice: newHighPrice,
      lowPrice: newLowPrice,
      style: style,
      options: options,
      visible: visible,
    );
  }

  FibonacciRetracement copyWith({
    String? id,
    double? highPrice,
    double? lowPrice,
    FibonacciStyle? style,
    FibonacciOptions? options,
    bool? visible,
  }) {
    return FibonacciRetracement(
      id: id ?? this.id,
      highPrice: highPrice ?? this.highPrice,
      lowPrice: lowPrice ?? this.lowPrice,
      style: style ?? this.style,
      options: options ?? this.options,
      visible: visible ?? this.visible,
    );
  }
}
