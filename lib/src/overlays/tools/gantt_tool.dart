import 'package:flutter/widgets.dart';
import '../../painter_params.dart';
import '../overlay.dart';

/// Gantt chart tool for visualizing time periods on the chart.
///
/// Displays horizontal bars representing time periods with labels.
///
/// Example:
/// ```dart
/// GanttTool(
///   id: 'gantt_1',
///   startTime: timestamp1,
///   endTime: timestamp2,
///   price: 100.0,
///   label: 'Phase 1',
/// )
/// ```
class GanttTool extends ChartOverlay {
  /// Start timestamp of the period.
  final int startTime;
  
  /// End timestamp of the period.
  final int endTime;
  
  /// Price level where the bar is drawn.
  final double price;
  
  /// Height of the bar in price units.
  final double height;
  
  /// Label for the period.
  final String label;
  
  /// Visual style for the gantt bar.
  final GanttToolStyle style;
  
  /// Configuration options.
  final GanttToolOptions options;

  GanttTool({
    String? id,
    required this.startTime,
    required this.endTime,
    required this.price,
    this.height = 5.0,
    this.label = '',
    GanttToolStyle? style,
    GanttToolOptions? options,
    bool visible = true,
  })  : style = style ?? const GanttToolStyle(),
        options = options ?? const GanttToolOptions(),
        super(
          id: id ?? 'gantt_${startTime}_${endTime}',
          interactive: (options ?? const GanttToolOptions()).draggable,
          visible: visible,
        );

  @override
  void paint(Canvas canvas, PainterParams params, {bool isBeingDragged = false}) {
    if (!visible) return;
    
    // Find screen coordinates for start and end
    final x1 = params.fitTimestamp(startTime);
    final x2 = params.fitTimestamp(endTime);
    if (x1 == null || x2 == null) return;
    final yCenter = params.fitPrice(price);
    final yTop = params.fitPrice(price + height / 2);
    final yBottom = params.fitPrice(price - height / 2);
    
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
    
    // Draw the bar
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTRB(x1, yTop, x2, yBottom),
      Radius.circular(style.borderRadius),
    );
    
    // Draw fill
    final fillPaint = Paint()
      ..color = style.fillColor.withOpacity(style.fillOpacity)
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(rect, fillPaint);
    
    // Draw border
    final borderPaint = Paint()
      ..color = style.borderColor
      ..strokeWidth = isBeingDragged ? style.borderWidth + 1 : style.borderWidth
      ..style = PaintingStyle.stroke;
    
    canvas.drawRRect(rect, borderPaint);
    
    // Draw label if provided
    if (label.isNotEmpty && style.showLabel) {
      _drawLabel(canvas, x1, x2, yCenter, isBeingDragged);
    }
    
    // Draw handles if draggable
    if (options.draggable) {
      _drawHandle(canvas, x1, yCenter, 'Start', isBeingDragged);
      _drawHandle(canvas, x2, yCenter, 'End', isBeingDragged);
    }
  }

  void _drawLabel(Canvas canvas, double x1, double x2, double y, bool isBeingDragged) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: style.labelColor,
          fontSize: isBeingDragged ? style.labelFontSize + 1 : style.labelFontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    
    // Center the label in the bar
    final labelX = (x1 + x2) / 2 - textPainter.width / 2;
    final labelY = y - textPainter.height / 2;
    
    // Draw background for label if needed
    if (style.labelBackground) {
      final bgRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          labelX - 4,
          labelY - 2,
          textPainter.width + 8,
          textPainter.height + 4,
        ),
        const Radius.circular(3),
      );
      
      final bgPaint = Paint()
        ..color = const Color(0xFF000000).withOpacity(0.7)
        ..style = PaintingStyle.fill;
      
      canvas.drawRRect(bgRect, bgPaint);
    }
    
    textPainter.paint(canvas, Offset(labelX, labelY));
  }

  void _drawHandle(Canvas canvas, double x, double y, String label, bool isBeingDragged) {
    final size = isBeingDragged ? 8.0 : 6.0;
    final opacity = isBeingDragged ? 1.0 : 0.7;
    
    // Draw circle
    final circlePaint = Paint()
      ..color = style.borderColor.withOpacity(opacity)
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
    
    // Find screen coordinates for start and end
    final x1 = params.fitTimestamp(startTime);
    final x2 = params.fitTimestamp(endTime);
    if (x1 == null || x2 == null) return false;
    final yTop = params.fitPrice(price + height / 2);
    final yBottom = params.fitPrice(price - height / 2);
    
    // Test if inside the bar
    final rect = Rect.fromLTRB(x1, yTop, x2, yBottom);
    return rect.inflate(5).contains(position);
  }

  /// Checks if the position is on the start handle.
  bool hitTestStartHandle(Offset position, PainterParams params) {
    if (!options.draggable) return false;
    
    final x = params.fitTimestamp(startTime);
    if (x == null) return false;

    final y = params.fitPrice(price);
    
    const handleSize = 20.0;
    return (position - Offset(x, y)).distance < handleSize;
  }

  /// Checks if the position is on the end handle.
  bool hitTestEndHandle(Offset position, PainterParams params) {
    if (!options.draggable) return false;
    
    final x = params.fitTimestamp(endTime);
    if (x == null) return false;

    final y = params.fitPrice(price);
    
    const handleSize = 20.0;
    return (position - Offset(x, y)).distance < handleSize;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'startTime': startTime,
    'endTime': endTime,
    'price': price,
    'height': height,
    'label': label,
    'style': {
      'fillColor': style.fillColor.value,
      'fillOpacity': style.fillOpacity,
      'borderColor': style.borderColor.value,
      'borderWidth': style.borderWidth,
      'borderRadius': style.borderRadius,
      'showLabel': style.showLabel,
      'labelColor': style.labelColor.value,
      'labelFontSize': style.labelFontSize,
      'labelBackground': style.labelBackground,
    },
    'options': {
      'draggable': options.draggable,
    },
    'visible': visible,
  };

  factory GanttTool.fromJson(Map<String, dynamic> json) {
    final s = json['style'] as Map<String, dynamic>?;
    final o = json['options'] as Map<String, dynamic>?;
    return GanttTool(
      id: json['id'] as String?,
      startTime: json['startTime'] as int,
      endTime: json['endTime'] as int,
      price: (json['price'] as num).toDouble(),
      height: (json['height'] as num?)?.toDouble() ?? 5.0,
      label: json['label'] as String? ?? '',
      style: s != null ? GanttToolStyle(
        fillColor: Color(s['fillColor'] as int),
        fillOpacity: (s['fillOpacity'] as num?)?.toDouble() ?? 0.3,
        borderColor: Color(s['borderColor'] as int),
        borderWidth: (s['borderWidth'] as num?)?.toDouble() ?? 2.0,
        borderRadius: (s['borderRadius'] as num?)?.toDouble() ?? 4.0,
        showLabel: s['showLabel'] as bool? ?? true,
        labelColor: s['labelColor'] != null ? Color(s['labelColor'] as int) : const Color(0xFFFFFFFF),
        labelFontSize: (s['labelFontSize'] as num?)?.toDouble() ?? 12.0,
        labelBackground: s['labelBackground'] as bool? ?? true,
      ) : null,
      options: o != null ? GanttToolOptions(
        draggable: o['draggable'] as bool? ?? true,
      ) : null,
      visible: json['visible'] as bool? ?? true,
    );
  }

  /// Creates a copy with updated properties.
  GanttTool copyWith({
    int? startTime,
    int? endTime,
    double? price,
    double? height,
    String? label,
    GanttToolStyle? style,
    GanttToolOptions? options,
    bool? visible,
  }) {
    return GanttTool(
      id: id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      price: price ?? this.price,
      height: height ?? this.height,
      label: label ?? this.label,
      style: style ?? this.style,
      options: options ?? this.options,
      visible: visible ?? this.visible,
    );
  }
}

/// Visual style for a gantt tool.
class GanttToolStyle {
  /// Fill color of the bar.
  final Color fillColor;
  
  /// Opacity of the fill.
  final double fillOpacity;
  
  /// Border color of the bar.
  final Color borderColor;
  
  /// Border width.
  final double borderWidth;
  
  /// Border radius.
  final double borderRadius;
  
  /// Whether to show the label.
  final bool showLabel;
  
  /// Label color.
  final Color labelColor;
  
  /// Label font size.
  final double labelFontSize;
  
  /// Whether to show label background.
  final bool labelBackground;

  const GanttToolStyle({
    this.fillColor = const Color(0xFF4CAF50),
    this.fillOpacity = 0.3,
    this.borderColor = const Color(0xFF4CAF50),
    this.borderWidth = 2.0,
    this.borderRadius = 4.0,
    this.showLabel = true,
    this.labelColor = const Color(0xFFFFFFFF),
    this.labelFontSize = 12.0,
    this.labelBackground = true,
  });

  GanttToolStyle copyWith({
    Color? fillColor,
    double? fillOpacity,
    Color? borderColor,
    double? borderWidth,
    double? borderRadius,
    bool? showLabel,
    Color? labelColor,
    double? labelFontSize,
    bool? labelBackground,
  }) {
    return GanttToolStyle(
      fillColor: fillColor ?? this.fillColor,
      fillOpacity: fillOpacity ?? this.fillOpacity,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      showLabel: showLabel ?? this.showLabel,
      labelColor: labelColor ?? this.labelColor,
      labelFontSize: labelFontSize ?? this.labelFontSize,
      labelBackground: labelBackground ?? this.labelBackground,
    );
  }
}

/// Configuration options for a gantt tool.
class GanttToolOptions {
  /// Whether the gantt bar can be dragged.
  final bool draggable;
  
  /// Callback when the gantt bar is moved or resized.
  /// Parameters: startTime, endTime, price
  final void Function(int startTime, int endTime, double price)? onMoved;
  
  /// Callback when the gantt bar is deleted.
  final VoidCallback? onDelete;

  const GanttToolOptions({
    this.draggable = true,
    this.onMoved,
    this.onDelete,
  });

  GanttToolOptions copyWith({
    bool? draggable,
    void Function(int, int, double)? onMoved,
    VoidCallback? onDelete,
  }) {
    return GanttToolOptions(
      draggable: draggable ?? this.draggable,
      onMoved: onMoved ?? this.onMoved,
      onDelete: onDelete ?? this.onDelete,
    );
  }
}
