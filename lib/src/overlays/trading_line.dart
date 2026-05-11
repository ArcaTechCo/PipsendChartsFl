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

  /// Optional: Start timestamp (milliseconds since epoch).
  /// If null, line extends from the left edge of the chart.
  final int? startTime;

  /// Optional: End timestamp (milliseconds since epoch).
  /// If null, line extends to the right edge of the chart.
  final int? endTime;

  TradingLine({
    String? id,
    required this.price,
    required this.type,
    TradingLineStyle? style,
    TradingLineOptions? options,
    bool visible = true,
    this.startTime,
    this.endTime,
  })  : this.style = style ?? TradingLineStyle.fromType(type),
        this.options = options ?? const TradingLineOptions(),
        super(
          id: id ?? '${type.name}_${price.toStringAsFixed(2)}',
          // A line is interactive if the user can drag it OR tap it. Non-draggable
          // lines that supply an `onTap` callback (e.g. entry lines used to select
          // a position on the chart) need to participate in hit testing too.
          interactive: (options ?? const TradingLineOptions()).draggable ||
              (options ?? const TradingLineOptions()).onTap != null,
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
    // Calculate X coordinates based on timestamps (without xShift to keep line fixed)
    double startX = 0;
    double endX = params.chartWidth;
    
    if (startTime != null) {
      final startIndex = params.candles.indexWhere((c) => c.timestamp >= startTime!);
      if (startIndex >= 0) {
        startX = startIndex * params.candleWidth;
      } else {
        // Line starts before visible range, start from left edge
        startX = 0;
      }
    }
    
    if (endTime != null) {
      final endIndex = params.candles.indexWhere((c) => c.timestamp >= endTime!);
      if (endIndex >= 0) {
        endX = endIndex * params.candleWidth;
      } else {
        // Line ends after visible range, extend to right edge
        endX = params.chartWidth;
      }
    }
    
    // Don't draw if line is completely outside visible range
    if (endX < 0 || startX > params.chartWidth) return;
    
    // Clip to visible range
    startX = startX.clamp(0, params.chartWidth);
    endX = endX.clamp(0, params.chartWidth);
    
    // Clip only the line to the chart area
    canvas.save();
    canvas.clipRect(Offset.zero & Size(params.chartWidth, params.chartHeight));
    
    final paint = Paint()
      ..color = style.color
      ..strokeWidth = isBeingDragged ? style.lineWidth + 1 : style.lineWidth
      ..style = PaintingStyle.stroke;

    if (style.dashPattern != null) {
      _drawDashedLine(canvas, y, params, paint, startX: startX, endX: endX);
    } else {
      canvas.drawLine(
        Offset(startX, y),
        Offset(endX, y),
        paint,
      );
    }
    
    canvas.restore();
  }

  void _drawDashedLine(Canvas canvas, double y, PainterParams params, Paint paint, {double startX = 0, double? endX}) {
    final dashPattern = style.dashPattern!;
    final dashWidth = dashPattern[0];
    final dashSpace = dashPattern.length > 1 ? dashPattern[1] : dashWidth;

    final lineEndX = endX ?? params.chartWidth;
    double currentX = startX;
    final path = Path();

    while (currentX < lineEndX) {
      path.moveTo(currentX, y);
      currentX += dashWidth;
      if (currentX > lineEndX) currentX = lineEndX;
      path.lineTo(currentX, y);
      currentX += dashSpace;
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
    final verticalOffset = y - tp.height - style.labelVerticalPadding;
    final hPadding = style.labelHorizontalPadding;

    switch (options.labelPosition) {
      case LabelPosition.left:
        return Offset(hPadding, verticalOffset);
      case LabelPosition.right:
        return Offset(params.chartWidth - tp.width - hPadding, verticalOffset);
      case LabelPosition.center:
        return Offset((params.chartWidth - tp.width) / 2, verticalOffset);
      case LabelPosition.custom:
        return options.customLabelOffset ?? Offset(hPadding, verticalOffset);
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
    if (!interactive) return false;

    final y = params.fitPrice(price);

    // The hit area is split in three zones so the user can comfortably
    // tap on the visible labels without claiming the whole horizontal
    // strip (which previously caused accidental drags during pan/zoom):
    //
    //   1. Title text rect on the chart area (where the host renders
    //      e.g. "BUY LIMIT 0.1"). Padded for finger-sized touches.
    //   2. Price label rect in the right-side gutter (always rendered
    //      at x = chartWidth + 4).
    //   3. A thin ±5 px strip along the line itself across the chart,
    //      to support drag handles without bleeding into pan gestures.

    // Zone 1 — title text.
    final titleText = options.title ?? type.defaultTitle;
    if (titleText.isNotEmpty || options.customText != null) {
      final combinedText = options.customText != null
          ? '$titleText ${options.customText}'
          : titleText;
      final tp = TextPainter(
        text: TextSpan(
          text: combinedText,
          style: TextStyle(
            fontSize: style.labelFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final labelOffset = _getLabelOffset(tp, y, params);
      // 8 px padding around the text gives a comfortable touch target
      // without being so big it covers a chunk of the chart.
      final titleRect = Rect.fromLTWH(
        labelOffset.dx - 8,
        labelOffset.dy - 4,
        tp.width + 16,
        tp.height + 8,
      );
      if (titleRect.contains(position)) return true;
    }

    // Zone 2 — price gutter on the right.
    if (position.dx >= params.chartWidth - 4 &&
        position.dx <= params.chartWidth + 80 &&
        position.dy >= y - 12 &&
        position.dy <= y + 12) {
      return true;
    }

    // Zone 3 — thin line strip across the drawable chart area.
    const lineHitHalfHeight = 5.0;
    return position.dy >= y - lineHitHalfHeight &&
        position.dy <= y + lineHitHalfHeight &&
        position.dx >= 0 &&
        position.dx <= params.chartWidth;
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
      startTime: startTime,
      endTime: endTime,
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
    int? startTime,
    int? endTime,
  }) {
    return TradingLine(
      id: id ?? this.id,
      price: price ?? this.price,
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
    'price': price,
    'type': type.name,
    'style': style.toJson(),
    'options': options.toJson(),
    'visible': visible,
    if (startTime != null) 'startTime': startTime,
    if (endTime != null) 'endTime': endTime,
  };

  factory TradingLine.fromJson(Map<String, dynamic> json) {
    return TradingLine(
      id: json['id'] as String?,
      price: (json['price'] as num).toDouble(),
      type: TradingLineType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TradingLineType.custom,
      ),
      style: json['style'] != null
          ? TradingLineStyle.fromJson(json['style'] as Map<String, dynamic>)
          : null,
      options: json['options'] != null
          ? TradingLineOptions.fromJson(json['options'] as Map<String, dynamic>)
          : null,
      visible: json['visible'] as bool? ?? true,
      startTime: json['startTime'] as int?,
      endTime: json['endTime'] as int?,
    );
  }

  String toDebugString() => 'TradingLine(id: $id, type: $type, price: $price)';
}
