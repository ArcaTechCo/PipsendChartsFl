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
  
  /// Resolves start X coordinate using fitTimestamp or full-width fallback.
  double _getStartX(PainterParams params) {
    if (startTime != null) {
      return params.fitTimestamp(startTime!) ?? 0;
    }
    return 0;
  }

  /// Resolves end X coordinate using fitTimestamp or full-width fallback.
  double _getEndX(PainterParams params) {
    if (endTime != null) {
      return params.fitTimestamp(endTime!) ?? params.chartWidth;
    }
    return params.chartWidth;
  }

  /// Bounding rectangle of the zone in chart-content coordinates (before the
  /// painter's [PainterParams.xShift] translation). Used to draw the selection
  /// highlight and to anchor a host-side selection toolbar.
  Rect boundingRect(PainterParams params) {
    final startX = _getStartX(params);
    final endX = _getEndX(params);
    final minY = params.fitPrice(maxPrice); // Y is inverted
    final maxY = params.fitPrice(minPrice);
    final left = startX < endX ? startX : endX;
    final right = startX > endX ? startX : endX;
    return Rect.fromLTRB(left, minY, right, maxY);
  }

  @override
  Rect? selectionBounds(PainterParams params) => boundingRect(params);

  @override
  void paint(Canvas canvas, PainterParams params, {bool isBeingDragged = false}) {
    if (!visible) return;

    final startX = _getStartX(params);
    final endX = _getEndX(params);
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
      _drawLabel(canvas, startX, minY, maxY);
    }

    // Draw resize handles: top-left (maxPrice/startTime) and bottom-right (minPrice/endTime)
    if (options.resizable) {
      _drawHandle(canvas, startX, minY, isBeingDragged);
      _drawHandle(canvas, endX, maxY, isBeingDragged);
    }
  }

  void _drawLabel(Canvas canvas, double startX, double minY, double maxY) {
    final label = options.label ?? type.defaultLabel;
    if (label.isEmpty) return;

    final textStyle = style.labelStyle ?? const TextStyle(
      color: Color(0xFF9E9E9E),
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );

    final textPainter = TextPainter(
      text: TextSpan(text: label, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(canvas, Offset(startX + 8.0, minY + 4.0));
  }

  void _drawHandle(Canvas canvas, double x, double y, bool isBeingDragged) {
    final handleSize = isBeingDragged ? 8.0 : 6.0;
    final opacity = isBeingDragged ? 1.0 : 0.7;

    final handlePaint = Paint()
      ..color = style.borderColor.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(Offset(x, y), handleSize, handlePaint);
    canvas.drawCircle(Offset(x, y), handleSize, borderPaint);
  }

  @override
  bool hitTest(Offset position, PainterParams params) {
    if (!interactive) return false;

    final startX = _getStartX(params);
    final endX = _getEndX(params);
    final minY = params.fitPrice(maxPrice);
    final maxY = params.fitPrice(minPrice);

    final lx = startX < endX ? startX : endX;
    final rx = startX > endX ? startX : endX;

    return position.dx >= lx && position.dx <= rx &&
           position.dy >= minY && position.dy <= maxY;
  }

  /// Checks if the position is on the top-left handle (maxPrice + startTime).
  bool hitTestTopHandle(Offset position, PainterParams params) {
    if (!options.resizable) return false;

    final x = _getStartX(params);
    final y = params.fitPrice(maxPrice);
    const handleSize = 20.0;

    return (position.dx - x).abs() <= handleSize &&
           (position.dy - y).abs() <= handleSize;
  }

  /// Checks if the position is on the bottom-right handle (minPrice + endTime).
  bool hitTestBottomHandle(Offset position, PainterParams params) {
    if (!options.resizable) return false;

    final x = _getEndX(params);
    final y = params.fitPrice(minPrice);
    const handleSize = 20.0;

    return (position.dx - x).abs() <= handleSize &&
           (position.dy - y).abs() <= handleSize;
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
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'minPrice': minPrice,
    'maxPrice': maxPrice,
    'type': type.name,
    'style': style.toJson(),
    'options': options.toJson(),
    'visible': visible,
    if (startTime != null) 'startTime': startTime,
    if (endTime != null) 'endTime': endTime,
  };

  factory PriceZone.fromJson(Map<String, dynamic> json) {
    return PriceZone(
      id: json['id'] as String?,
      minPrice: (json['minPrice'] as num).toDouble(),
      maxPrice: (json['maxPrice'] as num).toDouble(),
      type: PriceZoneType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PriceZoneType.custom,
      ),
      style: json['style'] != null
          ? PriceZoneStyle.fromJson(json['style'] as Map<String, dynamic>)
          : null,
      options: json['options'] != null
          ? PriceZoneOptions.fromJson(json['options'] as Map<String, dynamic>)
          : null,
      visible: json['visible'] as bool? ?? true,
      startTime: json['startTime'] as int?,
      endTime: json['endTime'] as int?,
    );
  }

  String toDebugString() => 'PriceZone(id: $id, type: $type, range: $minPrice-$maxPrice)';
}
