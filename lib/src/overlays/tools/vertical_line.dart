import 'package:flutter/painting.dart';
import '../../painter_params.dart';
import '../overlay.dart';

/// Vertical Line tool for marking temporal events on the chart.
///
/// Useful for marking:
/// - News releases
/// - Earnings reports
/// - Economic data releases
/// - Market open/close times
/// - Custom temporal markers
///
/// Example:
/// ```dart
/// VerticalLine(
///   id: 'news_1',
///   timestamp: eventTimestamp,
///   options: VerticalLineOptions(
///     label: 'Fed Meeting',
///     showLabel: true,
///     draggable: true,
///   ),
/// )
/// ```
class VerticalLine extends ChartOverlay {
  /// Timestamp where the line is drawn (milliseconds since epoch).
  final int timestamp;

  /// Style configuration.
  final VerticalLineStyle style;

  /// Display and interaction options.
  final VerticalLineOptions options;

  VerticalLine({
    String? id,
    required this.timestamp,
    VerticalLineStyle? style,
    VerticalLineOptions? options,
    bool visible = true,
  })  : this.style = style ?? const VerticalLineStyle(),
        this.options = options ?? const VerticalLineOptions(),
        super(
          id: id ?? 'vline_$timestamp',
          interactive: (options ?? const VerticalLineOptions()).draggable,
          visible: visible,
        );

  @override
  void paint(Canvas canvas, PainterParams params, {bool isBeingDragged = false}) {
    if (!visible) return;

    // Find the candle index for this timestamp
    final candleIndex = params.candles.indexWhere((c) => c.timestamp >= timestamp);
    if (candleIndex < 0) return;

    final x = candleIndex * params.candleWidth;

    // Draw the line
    _drawLine(canvas, x, params, isBeingDragged: isBeingDragged);

    // Draw label
    if (options.showLabel && options.label != null) {
      _drawLabel(canvas, x, params);
    }

    // Always draw drag handles if draggable (like TrendLine)
    if (options.draggable) {
      _drawDragHandles(canvas, x, params);
    }
  }

  void _drawLine(Canvas canvas, double x, PainterParams params, {bool isBeingDragged = false}) {
    final paint = Paint()
      ..color = style.lineColor
      ..strokeWidth = isBeingDragged ? style.lineWidth + 1 : style.lineWidth
      ..style = PaintingStyle.stroke;

    // Draw dashed line if specified
    if (style.dashPattern != null) {
      _drawDashedLine(canvas, x, params, paint);
    } else {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, params.chartHeight),
        paint,
      );
    }
  }

  void _drawDashedLine(Canvas canvas, double x, PainterParams params, Paint paint) {
    final dashPattern = style.dashPattern!;
    double currentY = 0;
    int dashIndex = 0;
    bool isDash = true;

    while (currentY < params.chartHeight) {
      final dashLength = dashPattern[dashIndex % dashPattern.length];
      final nextY = (currentY + dashLength).clamp(0.0, params.chartHeight);

      if (isDash) {
        canvas.drawLine(
          Offset(x, currentY),
          Offset(x, nextY),
          paint,
        );
      }

      currentY = nextY;
      dashIndex++;
      isDash = !isDash;
    }
  }

  void _drawLabel(Canvas canvas, double x, PainterParams params) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: options.label,
        style: TextStyle(
          color: style.labelTextColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Position label at top
    const padding = 6.0;
    final labelY = options.labelPosition == VerticalLineLabelPosition.top ? 10.0 : params.chartHeight - textPainter.height - 20;

    // Background
    final bgRect = Rect.fromLTWH(
      x - textPainter.width / 2 - padding,
      labelY,
      textPainter.width + padding * 2,
      textPainter.height + padding,
    );

    final bgPaint = Paint()
      ..color = style.labelBackgroundColor
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(4)),
      bgPaint,
    );

    // Border
    final borderPaint = Paint()
      ..color = style.lineColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(4)),
      borderPaint,
    );

    // Text
    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, labelY + padding / 2),
    );
  }

  void _drawDragHandles(Canvas canvas, double x, PainterParams params) {
    // Always draw visible handles like TrendLine
    final handleSize = 6.0;
    
    final handlePaint = Paint()
      ..color = style.lineColor
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Top handle
    canvas.drawCircle(Offset(x, 12), handleSize, handlePaint);
    canvas.drawCircle(Offset(x, 12), handleSize, borderPaint);

    // Bottom handle
    canvas.drawCircle(Offset(x, params.chartHeight - 12), handleSize, handlePaint);
    canvas.drawCircle(Offset(x, params.chartHeight - 12), handleSize, borderPaint);
  }

  @override
  bool hitTest(Offset position, PainterParams params) {
    if (!interactive) return false;

    // Find the candle index for this timestamp
    final candleIndex = params.candles.indexWhere((c) => c.timestamp >= timestamp);
    if (candleIndex < 0) return false;

    final x = candleIndex * params.candleWidth;

    // Increased tolerance for easier touch
    const hitTolerance = 12.0;
    return (position.dx - x).abs() < hitTolerance;
  }

  /// Creates a copy with updated timestamp.
  VerticalLine copyWith({
    int? timestamp,
    VerticalLineStyle? style,
    VerticalLineOptions? options,
    bool? visible,
  }) {
    return VerticalLine(
      id: id,
      timestamp: timestamp ?? this.timestamp,
      style: style ?? this.style,
      options: options ?? this.options,
      visible: visible ?? this.visible,
    );
  }
}

/// Style configuration for Vertical Line.
class VerticalLineStyle {
  /// Color of the line.
  final Color lineColor;

  /// Width of the line.
  final double lineWidth;

  /// Dash pattern for the line (e.g., [5, 3] for dashed).
  /// Null for solid line.
  final List<double>? dashPattern;

  /// Text color for the label.
  final Color labelTextColor;

  /// Background color for the label.
  final Color labelBackgroundColor;

  const VerticalLineStyle({
    this.lineColor = const Color(0xFF9C27B0), // Purple
    this.lineWidth = 2.0,
    this.dashPattern = const [5, 3],
    this.labelTextColor = const Color(0xFFFFFFFF),
    this.labelBackgroundColor = const Color(0xCC9C27B0),
  });
}

/// Position for the label.
enum VerticalLineLabelPosition {
  top,
  bottom,
}

/// Options for Vertical Line display and interaction.
class VerticalLineOptions {
  /// Label text to display.
  final String? label;

  /// Whether to show the label.
  final bool showLabel;

  /// Position of the label.
  final VerticalLineLabelPosition labelPosition;

  /// Whether the line is draggable.
  final bool draggable;

  /// Callback when line is moved.
  final void Function(int newTimestamp)? onMoved;

  const VerticalLineOptions({
    this.label,
    this.showLabel = true,
    this.labelPosition = VerticalLineLabelPosition.top,
    this.draggable = true,
    this.onMoved,
  });
}
