import 'package:flutter/painting.dart';
import '../painter_params.dart';
import 'overlay.dart' as chart_overlay;
import 'trading_line_type.dart';
import 'trading_line_style.dart';
import 'trading_line_options.dart';

/// A horizontal line on the chart representing a trading level.
///
/// Trading lines are used to mark important price levels such as:
/// - Stop Loss (SL)
/// - Take Profit (TP)
/// - Entry points
/// - Price alerts
/// - Support/Resistance levels
///
/// Example:
/// ```dart
/// TradingLine(
///   price: 150.0,
///   type: TradingLineType.stopLoss,
///   options: TradingLineOptions(
///     title: 'Stop Loss',
///     showPrice: true,
///     customText: '-2.5%',
///     draggable: true,
///     onPriceChanged: (newPrice) => print('Moved to: $newPrice'),
///   ),
/// )
/// ```
class TradingLine extends chart_overlay.ChartOverlay {
  /// The price level where this line is drawn.
  final double price;

  /// The type of trading line.
  final TradingLineType type;

  /// Style configuration.
  final TradingLineStyle style;

  /// Display and interaction options.
  final TradingLineOptions options;

  TradingLine({
    String? id,
    required this.price,
    required this.type,
    TradingLineStyle? style,
    TradingLineOptions? options,
    bool visible = true,
  })  : this.style = style ?? TradingLineStyle.fromType(type),
        this.options = options ?? const TradingLineOptions(),
        super(
          id: id ?? '${type.name}_${price.toStringAsFixed(2)}',
          interactive: (options ?? const TradingLineOptions()).draggable,
          visible: visible,
        );

  @override
  void paint(Canvas canvas, PainterParams params, {bool isBeingDragged = false}) {
    if (!visible) return;

    final y = params.fitPrice(price);

    // Draw drag indicator if being dragged
    if (isBeingDragged) {
      _drawDragIndicator(canvas, y, params);
    }

    // Draw the line
    _drawLine(canvas, y, params, isBeingDragged: isBeingDragged);

    // Draw label with custom text (combined)
    if (options.showLabel) {
      _drawLabelWithCustomText(canvas, y, params, isBeingDragged: isBeingDragged);
    }

    // Draw price on the right
    if (options.showPrice) {
      _drawPrice(canvas, y, params, isBeingDragged: isBeingDragged);
    }
  }

  void _drawDragIndicator(Canvas canvas, double y, PainterParams params) {
    // Draw drag handles on both sides (no background blur)
    final handlePaint = Paint()
      ..color = style.color
      ..style = PaintingStyle.fill;
    
    // Left handle
    canvas.drawCircle(Offset(8, y), 4, handlePaint);
    
    // Right handle
    canvas.drawCircle(Offset(params.chartWidth - 8, y), 4, handlePaint);
  }

  void _drawLine(Canvas canvas, double y, PainterParams params, {bool isBeingDragged = false}) {
    // Clip only the line to the chart area
    canvas.save();
    canvas.clipRect(Offset.zero & Size(params.chartWidth, params.chartHeight));
    
    final paint = Paint()
      ..color = style.color
      ..strokeWidth = isBeingDragged ? style.lineWidth + 1 : style.lineWidth
      ..style = PaintingStyle.stroke;

    if (style.dashPattern != null) {
      _drawDashedLine(canvas, y, params, paint);
    } else {
      canvas.drawLine(
        Offset(0, y),
        Offset(params.chartWidth, y),
        paint,
      );
    }
    
    canvas.restore();
  }

  void _drawDashedLine(Canvas canvas, double y, PainterParams params, Paint paint) {
    final dashPattern = style.dashPattern!;
    final dashWidth = dashPattern[0];
    final dashSpace = dashPattern.length > 1 ? dashPattern[1] : dashWidth;

    double startX = 0;
    final path = Path();

    while (startX < params.chartWidth) {
      path.moveTo(startX, y);
      startX += dashWidth;
      if (startX > params.chartWidth) startX = params.chartWidth;
      path.lineTo(startX, y);
      startX += dashSpace;
    }

    canvas.drawPath(path, paint);
  }

  void _drawLabelWithCustomText(Canvas canvas, double y, PainterParams params, {bool isBeingDragged = false}) {
    final label = options.title ?? type.defaultTitle;
    if (label.isEmpty && options.customText == null) return;

    // Build the combined text: "SL -3.0%"
    final combinedText = options.customText != null 
        ? '$label ${options.customText}'
        : label;

    final textStyle = TextStyle(
      color: style.labelColor ?? style.color,
      fontSize: isBeingDragged ? style.labelFontSize + 1 : style.labelFontSize,
      fontWeight: FontWeight.bold,
    );

    final textPainter = TextPainter(
      text: TextSpan(text: combinedText, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    // Position above the line
    final offset = _getLabelOffset(textPainter, y, params);
    textPainter.paint(canvas, offset);
  }

  Offset _getLabelOffset(TextPainter tp, double y, PainterParams params) {
    // Position above the line with a small gap (2px instead of 4px)
    final verticalOffset = y - tp.height - 2;

    switch (options.labelPosition) {
      case LabelPosition.left:
        return Offset(4, verticalOffset);
      case LabelPosition.right:
        return Offset(params.chartWidth - tp.width - 4, verticalOffset);
      case LabelPosition.center:
        return Offset((params.chartWidth - tp.width) / 2, verticalOffset);
      case LabelPosition.custom:
        return options.customLabelOffset ?? Offset(4, verticalOffset);
    }
  }

  void _drawPrice(Canvas canvas, double y, PainterParams params, {bool isBeingDragged = false}) {
    final priceText = options.priceFormatter?.call(price) 
        ?? price.toStringAsFixed(2);

    final textStyle = TextStyle(
      color: style.priceColor ?? style.color,
      fontSize: isBeingDragged ? style.priceFontSize + 1 : style.priceFontSize,
      fontWeight: FontWeight.w600,
    );

    final textPainter = TextPainter(
      text: TextSpan(text: priceText, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    // Draw on the right side
    final offset = Offset(
      params.chartWidth + 4,
      y - textPainter.height / 2,
    );

    textPainter.paint(canvas, offset);
  }


  @override
  bool hitTest(Offset position, PainterParams params) {
    if (!interactive) {
      print('$id: not interactive');
      return false;
    }

    final y = params.fitPrice(price);
    
    // Expanded hit area: includes the label above the line
    // Label is positioned 2px above the line, with typical height of ~16px
    final hitAreaAbove = 20.0; // Includes label area
    final hitAreaBelow = 10.0; // Below the line

    final isHit = (position.dy >= y - hitAreaAbove && position.dy <= y + hitAreaBelow) &&
           (position.dx >= 0 && position.dx <= params.chartWidth);
    
    return isHit;
  }

  /// Creates a copy of this trading line with a new price.
  TradingLine withPrice(double newPrice) {
    return TradingLine(
      id: id,
      price: newPrice,
      type: type,
      style: style,
      options: options,
      visible: visible,
    );
  }

  /// Creates a copy with modified properties.
  TradingLine copyWith({
    String? id,
    double? price,
    TradingLineType? type,
    TradingLineStyle? style,
    TradingLineOptions? options,
    bool? visible,
  }) {
    return TradingLine(
      id: id ?? this.id,
      price: price ?? this.price,
      type: type ?? this.type,
      style: style ?? this.style,
      options: options ?? this.options,
      visible: visible ?? this.visible,
    );
  }

  String toDebugString() => 'TradingLine(id: $id, type: $type, price: $price)';
}
