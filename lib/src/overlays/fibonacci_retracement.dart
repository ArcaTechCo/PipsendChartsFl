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
  
  /// Optional: Start timestamp (milliseconds since epoch).
  /// If null, Fibonacci extends from the left edge of the chart.
  final int? startTime;

  /// Optional: End timestamp (milliseconds since epoch).
  /// If null, Fibonacci extends to the right edge of the chart.
  final int? endTime;
  
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
    this.startTime,
    this.endTime,
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

  /// Resolves the start X coordinate using fitTimestamp or full-width fallback.
  double _getStartX(PainterParams params) {
    if (startTime != null) {
      return params.fitTimestamp(startTime!) ?? 0;
    }
    return 0;
  }

  /// Resolves the end X coordinate using fitTimestamp or full-width fallback.
  double _getEndX(PainterParams params) {
    if (endTime != null) {
      return params.fitTimestamp(endTime!) ?? params.chartWidth;
    }
    return params.chartWidth;
  }

  @override
  void paint(Canvas canvas, PainterParams params, {bool isBeingDragged = false}) {
    if (!visible) return;

    final startX = _getStartX(params);
    final endX = _getEndX(params);

    final highY = params.fitPrice(highPrice);
    final lowY = params.fitPrice(lowPrice);

    // Draw background highlight when being dragged
    if (isBeingDragged) {
      final bgPaint = Paint()
        ..color = const Color(0xFF2196F3).withOpacity(0.1)
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTRB(startX, highY, endX, lowY), bgPaint);
    }

    // Draw each Fibonacci level
    for (final level in levels) {
      final price = getPriceAtLevel(level);
      final y = params.fitPrice(price);
      final color = style.getColorForLevel(level);

      final paint = Paint()
        ..color = isBeingDragged ? color : color.withOpacity(0.8)
        ..strokeWidth = isBeingDragged ? style.lineWidth + 1.0 : style.lineWidth
        ..style = PaintingStyle.stroke;

      canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);

      if (options.showLabels) {
        _drawLabel(canvas, level, price, y, endX, color);
      }
    }

    // Draw resize handles: top-left (highPrice/startTime) and bottom-right (lowPrice/endTime)
    if (options.draggable) {
      _drawHandle(canvas, startX, highY, isBeingDragged);
      _drawHandle(canvas, endX, lowY, isBeingDragged);
    }
  }

  void _drawHandle(Canvas canvas, double x, double y, bool isBeingDragged) {
    final handleSize = isBeingDragged ? 8.0 : 6.0;
    final opacity = isBeingDragged ? 1.0 : 0.7;

    final handlePaint = Paint()
      ..color = const Color(0xFF2196F3).withOpacity(opacity)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(Offset(x, y), handleSize, handlePaint);
    canvas.drawCircle(Offset(x, y), handleSize, borderPaint);
  }

  void _drawLabel(
    Canvas canvas,
    double level,
    double price,
    double y,
    double endX,
    Color color,
  ) {
    final textParts = <String>[];
    if (options.showPercentages) {
      textParts.add('${(level * 100).toStringAsFixed(1)}%');
    }
    if (options.showPrices) {
      textParts.add(price.toStringAsFixed(5));
    }
    if (textParts.isEmpty) return;

    final text = textParts.join(' ');
    final textStyle = style.labelStyle ?? TextStyle(
      color: color,
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    // Position label at the right end of the Fibonacci lines
    final labelX = endX + 4.0;
    final labelY = y - textPainter.height / 2;

    final bgPaint = Paint()
      ..color = const Color(0xFF000000).withOpacity(0.6)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(labelX - 2, labelY - 2, textPainter.width + 4, textPainter.height + 4),
      bgPaint,
    );

    textPainter.paint(canvas, Offset(labelX, labelY));
  }

  @override
  bool hitTest(Offset position, PainterParams params) {
    if (!interactive) return false;

    final startX = _getStartX(params);
    final endX = _getEndX(params);
    final highY = params.fitPrice(highPrice);
    final lowY = params.fitPrice(lowPrice);

    final minX = startX < endX ? startX : endX;
    final maxX = startX > endX ? startX : endX;
    final minY = highY < lowY ? highY : lowY;
    final maxY = highY > lowY ? highY : lowY;

    return position.dx >= minX && position.dx <= maxX &&
           position.dy >= minY && position.dy <= maxY;
  }

  /// Checks if the position is on the top-left handle (highPrice + startTime).
  bool hitTestTopHandle(Offset position, PainterParams params) {
    if (!options.draggable) return false;

    final x = _getStartX(params);
    final y = params.fitPrice(highPrice);
    const handleSize = 20.0;

    return (position.dx - x).abs() <= handleSize &&
           (position.dy - y).abs() <= handleSize;
  }

  /// Checks if the position is on the bottom-right handle (lowPrice + endTime).
  bool hitTestBottomHandle(Offset position, PainterParams params) {
    if (!options.draggable) return false;

    final x = _getEndX(params);
    final y = params.fitPrice(lowPrice);
    const handleSize = 20.0;

    return (position.dx - x).abs() <= handleSize &&
           (position.dy - y).abs() <= handleSize;
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
      startTime: startTime,
      endTime: endTime,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'highPrice': highPrice,
    'lowPrice': lowPrice,
    'style': style.toJson(),
    'options': options.toJson(),
    'visible': visible,
    if (startTime != null) 'startTime': startTime,
    if (endTime != null) 'endTime': endTime,
  };

  factory FibonacciRetracement.fromJson(Map<String, dynamic> json) {
    return FibonacciRetracement(
      id: json['id'] as String?,
      highPrice: (json['highPrice'] as num).toDouble(),
      lowPrice: (json['lowPrice'] as num).toDouble(),
      style: json['style'] != null
          ? FibonacciStyle.fromJson(json['style'] as Map<String, dynamic>)
          : null,
      options: json['options'] != null
          ? FibonacciOptions.fromJson(json['options'] as Map<String, dynamic>)
          : null,
      visible: json['visible'] as bool? ?? true,
      startTime: json['startTime'] as int?,
      endTime: json['endTime'] as int?,
    );
  }

  FibonacciRetracement copyWith({
    String? id,
    double? highPrice,
    double? lowPrice,
    FibonacciStyle? style,
    FibonacciOptions? options,
    bool? visible,
    int? startTime,
    int? endTime,
  }) {
    return FibonacciRetracement(
      id: id ?? this.id,
      highPrice: highPrice ?? this.highPrice,
      lowPrice: lowPrice ?? this.lowPrice,
      style: style ?? this.style,
      options: options ?? this.options,
      visible: visible ?? this.visible,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}
