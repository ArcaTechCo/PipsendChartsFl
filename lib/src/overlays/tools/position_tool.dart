import 'package:flutter/painting.dart';
import '../../painter_params.dart';
import '../overlay.dart';

/// Position Tool for marking trading positions with Entry, Stop Loss, and Take Profit.
///
/// Automatically calculates and displays the Risk:Reward ratio.
/// Each line (Entry, SL, TP) can be dragged independently.
///
/// Example:
/// ```dart
/// PositionTool(
///   id: 'position_1',
///   entryPrice: 150.0,
///   stopLossPrice: 145.0,
///   takeProfitPrice: 160.0,
///   options: PositionToolOptions(
///     showLabels: true,
///     showRiskReward: true,
///     draggable: true,
///     onPositionChanged: (entry, sl, tp) {
///       print('Position updated: E=$entry, SL=$sl, TP=$tp');
///     },
///   ),
/// )
/// ```
class PositionTool extends ChartOverlay {
  /// Entry price level.
  final double entryPrice;

  /// Stop Loss price level.
  final double stopLossPrice;

  /// Take Profit price level.
  final double takeProfitPrice;

  /// Style configuration.
  final PositionToolStyle style;

  /// Display and interaction options.
  final PositionToolOptions options;

  PositionTool({
    String? id,
    required this.entryPrice,
    required this.stopLossPrice,
    required this.takeProfitPrice,
    PositionToolStyle? style,
    PositionToolOptions? options,
    bool visible = true,
  })  : this.style = style ?? const PositionToolStyle(),
        this.options = options ?? const PositionToolOptions(),
        super(
          id: id ?? 'position_${entryPrice.toStringAsFixed(2)}',
          interactive: (options ?? const PositionToolOptions()).draggable,
          visible: visible,
        );

  /// Calculates the Risk:Reward ratio.
  double get riskRewardRatio {
    final risk = (entryPrice - stopLossPrice).abs();
    final reward = (takeProfitPrice - entryPrice).abs();
    
    if (risk == 0) return 0;
    return reward / risk;
  }

  /// Determines if this is a long position (entry > SL) or short (entry < SL).
  bool get isLongPosition => entryPrice > stopLossPrice;

  @override
  void paint(Canvas canvas, PainterParams params, {bool isBeingDragged = false}) {
    if (!visible) return;

    // Draw the three lines
    _drawLine(canvas, params, entryPrice, style.entryColor, 'Entry', isEntry: true);
    _drawLine(canvas, params, stopLossPrice, style.stopLossColor, 'Stop Loss', isStopLoss: true);
    _drawLine(canvas, params, takeProfitPrice, style.takeProfitColor, 'Take Profit', isTakeProfit: true);

    // Draw risk/reward label
    if (options.showRiskReward) {
      _drawRiskRewardLabel(canvas, params);
    }

    // Draw position zone (optional)
    if (options.showPositionZone) {
      _drawPositionZone(canvas, params);
    }
  }

  void _drawLine(
    Canvas canvas,
    PainterParams params,
    double price,
    Color color,
    String label, {
    bool isEntry = false,
    bool isStopLoss = false,
    bool isTakeProfit = false,
  }) {
    final y = params.fitPrice(price);

    // Draw the line
    final paint = Paint()
      ..color = color
      ..strokeWidth = style.lineWidth
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, y),
      Offset(params.chartWidth, y),
      paint,
    );

    // Draw label
    if (options.showLabels) {
      _drawLabel(canvas, y, label, color, params, price);
    }

    // Always draw drag handles if draggable (like TrendLine)
    if (options.draggable) {
      _drawDragHandles(canvas, y, color, params);
    }
  }

  void _drawLabel(Canvas canvas, double y, String label, Color color, PainterParams params, double price) {
    final textPainter = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: TextStyle(
              color: style.labelTextColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (options.showPriceInLabel)
            TextSpan(
              text: ' ${price.toStringAsFixed(2)}',
              style: TextStyle(
                color: style.labelTextColor,
                fontSize: 10,
              ),
            ),
        ],
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Background
    const padding = 6.0;
    final bgRect = Rect.fromLTWH(
      8,
      y - textPainter.height / 2 - padding / 2,
      textPainter.width + padding * 2,
      textPainter.height + padding,
    );

    final bgPaint = Paint()
      ..color = color.withOpacity(0.9)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(4)),
      bgPaint,
    );

    // Text
    textPainter.paint(
      canvas,
      Offset(8 + padding, y - textPainter.height / 2),
    );
  }

  void _drawDragHandles(Canvas canvas, double y, Color color, PainterParams params) {
    // Always draw visible handles like TrendLine
    final handleSize = 6.0;
    
    final handlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Left handle
    canvas.drawCircle(Offset(8, y), handleSize, handlePaint);
    canvas.drawCircle(Offset(8, y), handleSize, borderPaint);

    // Right handle
    canvas.drawCircle(Offset(params.chartWidth - 8, y), handleSize, handlePaint);
    canvas.drawCircle(Offset(params.chartWidth - 8, y), handleSize, borderPaint);
  }

  void _drawRiskRewardLabel(Canvas canvas, PainterParams params) {
    final rrText = 'R:R ${riskRewardRatio.toStringAsFixed(2)}';
    final positionType = isLongPosition ? 'LONG' : 'SHORT';

    final textPainter = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$positionType  ',
            style: TextStyle(
              color: isLongPosition ? style.takeProfitColor : style.stopLossColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: rrText,
            style: TextStyle(
              color: riskRewardRatio >= 2.0 ? style.takeProfitColor : style.stopLossColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Position at top-right
    const padding = 8.0;
    final bgRect = Rect.fromLTWH(
      params.chartWidth - textPainter.width - padding * 2 - 10,
      10,
      textPainter.width + padding * 2,
      textPainter.height + padding,
    );

    final bgPaint = Paint()
      ..color = style.labelBackgroundColor
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(6)),
      bgPaint,
    );

    // Border
    final borderPaint = Paint()
      ..color = riskRewardRatio >= 2.0 ? style.takeProfitColor : style.stopLossColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(6)),
      borderPaint,
    );

    // Text
    textPainter.paint(
      canvas,
      Offset(
        params.chartWidth - textPainter.width - padding - 10,
        10 + padding / 2,
      ),
    );
  }

  void _drawPositionZone(Canvas canvas, PainterParams params) {
    final entryY = params.fitPrice(entryPrice);
    final tpY = params.fitPrice(takeProfitPrice);
    final slY = params.fitPrice(stopLossPrice);

    // Draw profit zone (Entry to TP)
    final profitRect = Rect.fromLTRB(0, entryY, params.chartWidth, tpY);
    final profitPaint = Paint()
      ..color = style.profitZoneColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(profitRect, profitPaint);

    // Draw risk zone (Entry to SL)
    final riskRect = Rect.fromLTRB(0, entryY, params.chartWidth, slY);
    final riskPaint = Paint()
      ..color = style.riskZoneColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(riskRect, riskPaint);
  }

  @override
  bool hitTest(Offset position, PainterParams params) {
    if (!interactive) return false;

    const hitTolerance = 12.0;

    // Test each line
    final entryY = params.fitPrice(entryPrice);
    final slY = params.fitPrice(stopLossPrice);
    final tpY = params.fitPrice(takeProfitPrice);

    // Check if touching any of the three lines
    return (position.dy - entryY).abs() < hitTolerance ||
           (position.dy - slY).abs() < hitTolerance ||
           (position.dy - tpY).abs() < hitTolerance;
  }

  /// Checks if the position is on the Entry line.
  bool hitTestEntryLine(Offset position, PainterParams params) {
    if (!options.draggable) return false;
    
    final y = params.fitPrice(entryPrice);
    const hitTolerance = 12.0;
    
    return (position.dy - y).abs() < hitTolerance;
  }

  /// Checks if the position is on the Stop Loss line.
  bool hitTestStopLossLine(Offset position, PainterParams params) {
    if (!options.draggable) return false;
    
    final y = params.fitPrice(stopLossPrice);
    const hitTolerance = 12.0;
    
    return (position.dy - y).abs() < hitTolerance;
  }

  /// Checks if the position is on the Take Profit line.
  bool hitTestTakeProfitLine(Offset position, PainterParams params) {
    if (!options.draggable) return false;
    
    final y = params.fitPrice(takeProfitPrice);
    const hitTolerance = 12.0;
    
    return (position.dy - y).abs() < hitTolerance;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'entryPrice': entryPrice,
    'stopLossPrice': stopLossPrice,
    'takeProfitPrice': takeProfitPrice,
    'style': {
      'entryColor': style.entryColor.value,
      'stopLossColor': style.stopLossColor.value,
      'takeProfitColor': style.takeProfitColor.value,
      'lineWidth': style.lineWidth,
      'labelTextColor': style.labelTextColor.value,
      'labelBackgroundColor': style.labelBackgroundColor.value,
      'profitZoneColor': style.profitZoneColor.value,
      'riskZoneColor': style.riskZoneColor.value,
    },
    'options': {
      'showLabels': options.showLabels,
      'showPriceInLabel': options.showPriceInLabel,
      'showRiskReward': options.showRiskReward,
      'showPositionZone': options.showPositionZone,
      'draggable': options.draggable,
    },
    'visible': visible,
  };

  factory PositionTool.fromJson(Map<String, dynamic> json) {
    final s = json['style'] as Map<String, dynamic>?;
    final o = json['options'] as Map<String, dynamic>?;
    return PositionTool(
      id: json['id'] as String?,
      entryPrice: (json['entryPrice'] as num).toDouble(),
      stopLossPrice: (json['stopLossPrice'] as num).toDouble(),
      takeProfitPrice: (json['takeProfitPrice'] as num).toDouble(),
      style: s != null ? PositionToolStyle(
        entryColor: Color(s['entryColor'] as int),
        stopLossColor: Color(s['stopLossColor'] as int),
        takeProfitColor: Color(s['takeProfitColor'] as int),
        lineWidth: (s['lineWidth'] as num?)?.toDouble() ?? 2.0,
        labelTextColor: s['labelTextColor'] != null ? Color(s['labelTextColor'] as int) : const Color(0xFFFFFFFF),
        labelBackgroundColor: s['labelBackgroundColor'] != null ? Color(s['labelBackgroundColor'] as int) : const Color(0xCC000000),
        profitZoneColor: s['profitZoneColor'] != null ? Color(s['profitZoneColor'] as int) : const Color(0x0A4CAF50),
        riskZoneColor: s['riskZoneColor'] != null ? Color(s['riskZoneColor'] as int) : const Color(0x0AF44336),
      ) : null,
      options: o != null ? PositionToolOptions(
        showLabels: o['showLabels'] as bool? ?? true,
        showPriceInLabel: o['showPriceInLabel'] as bool? ?? true,
        showRiskReward: o['showRiskReward'] as bool? ?? true,
        showPositionZone: o['showPositionZone'] as bool? ?? false,
        draggable: o['draggable'] as bool? ?? true,
      ) : null,
      visible: json['visible'] as bool? ?? true,
    );
  }

  /// Creates a copy with updated prices.
  PositionTool copyWith({
    double? entryPrice,
    double? stopLossPrice,
    double? takeProfitPrice,
    PositionToolStyle? style,
    PositionToolOptions? options,
    bool? visible,
  }) {
    return PositionTool(
      id: id,
      entryPrice: entryPrice ?? this.entryPrice,
      stopLossPrice: stopLossPrice ?? this.stopLossPrice,
      takeProfitPrice: takeProfitPrice ?? this.takeProfitPrice,
      style: style ?? this.style,
      options: options ?? this.options,
      visible: visible ?? this.visible,
    );
  }
}

/// Style configuration for Position Tool.
class PositionToolStyle {
  /// Color for the Entry line.
  final Color entryColor;

  /// Color for the Stop Loss line.
  final Color stopLossColor;

  /// Color for the Take Profit line.
  final Color takeProfitColor;

  /// Width of the lines.
  final double lineWidth;

  /// Text color for labels.
  final Color labelTextColor;

  /// Background color for labels.
  final Color labelBackgroundColor;

  /// Color for the profit zone (Entry to TP).
  final Color profitZoneColor;

  /// Color for the risk zone (Entry to SL).
  final Color riskZoneColor;

  const PositionToolStyle({
    this.entryColor = const Color(0xFF2196F3), // Blue
    this.stopLossColor = const Color(0xFFF44336), // Red
    this.takeProfitColor = const Color(0xFF4CAF50), // Green
    this.lineWidth = 2.0,
    this.labelTextColor = const Color(0xFFFFFFFF),
    this.labelBackgroundColor = const Color(0xCC000000),
    this.profitZoneColor = const Color(0x0A4CAF50), // Green with 4% opacity
    this.riskZoneColor = const Color(0x0AF44336), // Red with 4% opacity
  });
}

/// Options for Position Tool display and interaction.
class PositionToolOptions {
  /// Whether to show labels on the lines.
  final bool showLabels;

  /// Whether to show prices in the labels.
  final bool showPriceInLabel;

  /// Whether to show the Risk:Reward ratio.
  final bool showRiskReward;

  /// Whether to show the position zone (profit/risk areas).
  final bool showPositionZone;

  /// Whether the lines are draggable.
  final bool draggable;

  /// Callback when position is changed (entry, stopLoss, takeProfit).
  final void Function(double entry, double stopLoss, double takeProfit)? onPositionChanged;

  const PositionToolOptions({
    this.showLabels = true,
    this.showPriceInLabel = true,
    this.showRiskReward = true,
    this.showPositionZone = false,
    this.draggable = true,
    this.onPositionChanged,
  });
}
