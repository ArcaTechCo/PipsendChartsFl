import 'package:flutter/painting.dart';
import '../painter_params.dart';
import 'overlay.dart';
import 'price_zone_type.dart';
import 'price_zone_style.dart';
import 'price_zone_options.dart';

/// A price zone overlay that displays a horizontal rectangular area.
///
/// Useful for marking support/resistance zones, demand/supply areas, etc.
class PriceZone extends ChartOverlay {
  /// Minimum price of the zone.
  final double minPrice;
  
  /// Maximum price of the zone.
  final double maxPrice;
  
  /// Type of the zone.
  final PriceZoneType type;
  
  /// Visual style of the zone.
  final PriceZoneStyle style;
  
  /// Display and interaction options.
  final PriceZoneOptions options;
  
  /// Optional: Start timestamp (milliseconds since epoch).
  /// If null, zone extends from the left edge of the chart.
  final int? startTime;

  /// Optional: End timestamp (milliseconds since epoch).
  /// If null, zone extends to the right edge of the chart.
  final int? endTime;
  
  PriceZone({
    String? id,
    required this.minPrice,
    required this.maxPrice,
    required this.type,
    PriceZoneStyle? style,
    PriceZoneOptions? options,
    bool visible = true,
    this.startTime,
    this.endTime,
  })  : assert(maxPrice > minPrice, 'maxPrice must be greater than minPrice'),
        this.style = style ?? PriceZoneStyle.fromType(type),
        this.options = options ?? const PriceZoneOptions(),
        super(
          id: id ?? '${type.name}_${minPrice.toStringAsFixed(2)}_${maxPrice.toStringAsFixed(2)}',
          interactive: (options ?? const PriceZoneOptions()).draggable || 
                      (options ?? const PriceZoneOptions()).resizable,
          visible: visible,
        );
  
  /// Height of the zone in price units.
  double get height => maxPrice - minPrice;
  
  /// Center price of the zone.
  double get centerPrice => (minPrice + maxPrice) / 2;
  
  @override
  void paint(Canvas canvas, PainterParams params, {bool isBeingDragged = false}) {
    if (!visible) return;
    
    // Calculate X coordinates based on timestamps
    double startX = 0;
    double endX = params.chartWidth;
    
    if (startTime != null || endTime != null) {
      final visibleStartTime = params.candles.first.timestamp;
      final visibleEndTime = params.candles.last.timestamp;
      
      // Check if zone is completely outside visible range
      if (startTime != null && startTime! > visibleEndTime) return;
      if (endTime != null && endTime! < visibleStartTime) return;
      
      if (startTime != null) {
        final startIndex = params.candles.indexWhere((c) => c.timestamp >= startTime!);
        if (startIndex >= 0) {
          startX = startIndex * params.candleWidth;
        }
      }
      
      if (endTime != null) {
        final endIndex = params.candles.indexWhere((c) => c.timestamp >= endTime!);
        if (endIndex >= 0) {
          endX = endIndex * params.candleWidth;
        }
      }
      
      // Clip to visible range
      startX = startX.clamp(0.0, params.chartWidth);
      endX = endX.clamp(0.0, params.chartWidth);
    }
    
    final minY = params.fitPrice(maxPrice); // Y is inverted
    final maxY = params.fitPrice(minPrice);
    
    // Draw filled rectangle
    final rect = Rect.fromLTRB(startX, minY, endX, maxY);
    final fillPaint = Paint()
      ..color = style.fillColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, fillPaint);
    
    // Draw border if enabled
    if (style.showBorder) {
      final borderPaint = Paint()
        ..color = style.borderColor
        ..strokeWidth = style.borderWidth
        ..style = PaintingStyle.stroke;
      canvas.drawRect(rect, borderPaint);
    }
    
    // Draw label if enabled
    if (options.showLabel) {
      _drawLabel(canvas, minY, maxY, params);
    }
    
    // Draw resize handles if resizable (always show when zone is interactive)
    if (options.resizable) {
      _drawResizeHandles(canvas, minY, maxY, params, isBeingDragged);
    }
  }
  
  void _drawLabel(Canvas canvas, double minY, double maxY, PainterParams params) {
    final label = options.label ?? type.defaultLabel;
    if (label.isEmpty) return;
    
    final textStyle = style.labelStyle ?? const TextStyle(
      color: Color(0xFF9E9E9E),
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );
    
    final textSpan = TextSpan(text: label, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    // Position label at top-left of zone with padding
    final x = 8.0;
    final y = minY + 4.0;
    
    textPainter.paint(canvas, Offset(x, y));
  }
  
  void _drawResizeHandles(Canvas canvas, double minY, double maxY, PainterParams params, bool isBeingDragged) {
    // Make handles more visible when being dragged
    final handleSize = isBeingDragged ? 8.0 : 6.0;
    final opacity = isBeingDragged ? 1.0 : 0.7;
    
    final handlePaint = Paint()
      ..color = style.borderColor.withOpacity(opacity)
      ..style = PaintingStyle.fill;
    
    final centerX = params.chartWidth / 2;
    
    // Draw handles with white border for better visibility
    final borderPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    // Top handle
    canvas.drawCircle(Offset(centerX, minY), handleSize, handlePaint);
    canvas.drawCircle(Offset(centerX, minY), handleSize, borderPaint);
    
    // Bottom handle
    canvas.drawCircle(Offset(centerX, maxY), handleSize, handlePaint);
    canvas.drawCircle(Offset(centerX, maxY), handleSize, borderPaint);
  }
  
  @override
  bool hitTest(Offset position, PainterParams params) {
    if (!interactive) return false;
    
    final minY = params.fitPrice(maxPrice);
    final maxY = params.fitPrice(minPrice);
    
    // Check if position is within the zone
    return position.dy >= minY && 
           position.dy <= maxY &&
           position.dx >= 0 && 
           position.dx <= params.chartWidth;
  }
  
  /// Checks if the position is on the top handle (maxPrice).
  bool hitTestTopHandle(Offset position, PainterParams params) {
    if (!options.resizable) return false;
    
    final minY = params.fitPrice(maxPrice);
    final handleSize = 20.0; // Larger touch area for easier interaction
    final centerX = params.chartWidth / 2;
    
    final dx = (position.dx - centerX).abs();
    final dy = (position.dy - minY).abs();
    
    return dx <= handleSize && dy <= handleSize;
  }
  
  /// Checks if the position is on the bottom handle (minPrice).
  bool hitTestBottomHandle(Offset position, PainterParams params) {
    if (!options.resizable) return false;
    
    final maxY = params.fitPrice(minPrice);
    final handleSize = 20.0; // Larger touch area for easier interaction
    final centerX = params.chartWidth / 2;
    
    final dx = (position.dx - centerX).abs();
    final dy = (position.dy - maxY).abs();
    
    return dx <= handleSize && dy <= handleSize;
  }
  
  /// Creates a copy with a new price range.
  PriceZone withRange(double newMinPrice, double newMaxPrice) {
    return PriceZone(
      id: id,
      minPrice: newMinPrice,
      maxPrice: newMaxPrice,
      type: type,
      style: style,
      options: options,
      visible: visible,
      startTime: startTime,
      endTime: endTime,
    );
  }
  
  /// Creates a copy with modified properties.
  PriceZone copyWith({
    String? id,
    double? minPrice,
    double? maxPrice,
    PriceZoneType? type,
    PriceZoneStyle? style,
    PriceZoneOptions? options,
    bool? visible,
    int? startTime,
    int? endTime,
  }) {
    return PriceZone(
      id: id ?? this.id,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      type: type ?? this.type,
      style: style ?? this.style,
      options: options ?? this.options,
      visible: visible ?? this.visible,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
  
  String toDebugString() => 'PriceZone(id: $id, type: $type, range: $minPrice-$maxPrice)';
}
