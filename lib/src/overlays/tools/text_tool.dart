import 'package:flutter/widgets.dart';
import '../../painter_params.dart';
import '../overlay.dart';

/// Text tool for adding text annotations on the chart.
///
/// Displays text at a specific price and time with customizable styling.
///
/// Example:
/// ```dart
/// TextTool(
///   id: 'text_1',
///   timestamp: timestamp,
///   price: 100.0,
///   text: 'Important level',
/// )
/// ```
class TextTool extends ChartOverlay {
  /// Timestamp where the text is positioned.
  final int timestamp;
  
  /// Price where the text is positioned.
  final double price;
  
  /// The text content to display.
  final String text;
  
  /// Visual style for the text.
  final TextToolStyle style;
  
  /// Configuration options.
  final TextToolOptions options;

  TextTool({
    String? id,
    required this.timestamp,
    required this.price,
    required this.text,
    TextToolStyle? style,
    TextToolOptions? options,
    bool visible = true,
  })  : style = style ?? const TextToolStyle(),
        options = options ?? const TextToolOptions(),
        super(
          id: id ?? 'text_${timestamp}',
          interactive: (options ?? const TextToolOptions()).draggable,
          visible: visible,
        );

  @override
  void paint(Canvas canvas, PainterParams params, {bool isBeingDragged = false}) {
    if (!visible || text.isEmpty) return;
    
    // Find position
    final x = params.fitTimestamp(timestamp);
    if (x == null) return;

    final y = params.fitPrice(price);
    
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
    
    // Create text painter
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: style.textColor,
          fontSize: isBeingDragged ? style.fontSize + 1 : style.fontSize,
          fontWeight: style.fontWeight,
          fontStyle: style.fontStyle,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: style.textAlign,
    );
    textPainter.layout();
    
    // Calculate position based on alignment
    double textX = x;
    double textY = y;
    
    switch (style.horizontalAlignment) {
      case TextHorizontalAlignment.left:
        textX = x;
        break;
      case TextHorizontalAlignment.center:
        textX = x - textPainter.width / 2;
        break;
      case TextHorizontalAlignment.right:
        textX = x - textPainter.width;
        break;
    }
    
    switch (style.verticalAlignment) {
      case TextVerticalAlignment.top:
        textY = y;
        break;
      case TextVerticalAlignment.middle:
        textY = y - textPainter.height / 2;
        break;
      case TextVerticalAlignment.bottom:
        textY = y - textPainter.height;
        break;
    }
    
    // Draw background if enabled
    if (style.showBackground) {
      final bgRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          textX - style.padding,
          textY - style.padding,
          textPainter.width + style.padding * 2,
          textPainter.height + style.padding * 2,
        ),
        Radius.circular(style.borderRadius),
      );
      
      final bgPaint = Paint()
        ..color = style.backgroundColor
        ..style = PaintingStyle.fill;
      
      canvas.drawRRect(bgRect, bgPaint);
      
      // Draw border if enabled
      if (style.showBorder) {
        final borderPaint = Paint()
          ..color = style.borderColor
          ..strokeWidth = style.borderWidth
          ..style = PaintingStyle.stroke;
        
        canvas.drawRRect(bgRect, borderPaint);
      }
    }
    
    // Draw text
    textPainter.paint(canvas, Offset(textX, textY));
    
    // Draw handle if draggable
    if (options.draggable) {
      _drawHandle(canvas, x, y, isBeingDragged);
    }
  }

  void _drawHandle(Canvas canvas, double x, double y, bool isBeingDragged) {
    final size = isBeingDragged ? 8.0 : 6.0;
    final opacity = isBeingDragged ? 1.0 : 0.7;
    
    // Draw circle
    final circlePaint = Paint()
      ..color = style.textColor.withOpacity(opacity)
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
    
    // Find position
    final x = params.fitTimestamp(timestamp);
    if (x == null) return false;

    final y = params.fitPrice(price);
    
    // Test if touching the handle or text area
    const handleSize = 20.0;
    if ((position - Offset(x, y)).distance < handleSize) {
      return true;
    }
    
    // Test text area (approximate)
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: style.fontSize),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    final textRect = Rect.fromLTWH(
      x - textPainter.width / 2,
      y - textPainter.height / 2,
      textPainter.width,
      textPainter.height,
    );
    
    return textRect.inflate(10).contains(position);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp,
    'price': price,
    'text': text,
    'style': {
      'textColor': style.textColor.value,
      'fontSize': style.fontSize,
      'fontWeight': style.fontWeight.index,
      'fontStyle': style.fontStyle.index,
      'textAlign': style.textAlign.name,
      'horizontalAlignment': style.horizontalAlignment.name,
      'verticalAlignment': style.verticalAlignment.name,
      'showBackground': style.showBackground,
      'backgroundColor': style.backgroundColor.value,
      'padding': style.padding,
      'borderRadius': style.borderRadius,
      'showBorder': style.showBorder,
      'borderColor': style.borderColor.value,
      'borderWidth': style.borderWidth,
    },
    'options': {
      'draggable': options.draggable,
    },
    'visible': visible,
  };

  factory TextTool.fromJson(Map<String, dynamic> json) {
    final s = json['style'] as Map<String, dynamic>?;
    final o = json['options'] as Map<String, dynamic>?;
    return TextTool(
      id: json['id'] as String?,
      timestamp: json['timestamp'] as int,
      price: (json['price'] as num).toDouble(),
      text: json['text'] as String,
      style: s != null ? TextToolStyle(
        textColor: Color(s['textColor'] as int),
        fontSize: (s['fontSize'] as num?)?.toDouble() ?? 14.0,
        fontWeight: s['fontWeight'] != null ? FontWeight.values[s['fontWeight'] as int] : FontWeight.normal,
        fontStyle: s['fontStyle'] != null ? FontStyle.values[s['fontStyle'] as int] : FontStyle.normal,
        textAlign: TextAlign.values.firstWhere((e) => e.name == s['textAlign'], orElse: () => TextAlign.left),
        horizontalAlignment: TextHorizontalAlignment.values.firstWhere((e) => e.name == s['horizontalAlignment'], orElse: () => TextHorizontalAlignment.center),
        verticalAlignment: TextVerticalAlignment.values.firstWhere((e) => e.name == s['verticalAlignment'], orElse: () => TextVerticalAlignment.middle),
        showBackground: s['showBackground'] as bool? ?? true,
        backgroundColor: s['backgroundColor'] != null ? Color(s['backgroundColor'] as int) : const Color(0xFF000000),
        padding: (s['padding'] as num?)?.toDouble() ?? 6.0,
        borderRadius: (s['borderRadius'] as num?)?.toDouble() ?? 4.0,
        showBorder: s['showBorder'] as bool? ?? true,
        borderColor: s['borderColor'] != null ? Color(s['borderColor'] as int) : const Color(0xFF2196F3),
        borderWidth: (s['borderWidth'] as num?)?.toDouble() ?? 1.0,
      ) : null,
      options: o != null ? TextToolOptions(
        draggable: o['draggable'] as bool? ?? true,
      ) : null,
      visible: json['visible'] as bool? ?? true,
    );
  }

  /// Creates a copy with updated properties.
  TextTool copyWith({
    int? timestamp,
    double? price,
    String? text,
    TextToolStyle? style,
    TextToolOptions? options,
    bool? visible,
  }) {
    return TextTool(
      id: id,
      timestamp: timestamp ?? this.timestamp,
      price: price ?? this.price,
      text: text ?? this.text,
      style: style ?? this.style,
      options: options ?? this.options,
      visible: visible ?? this.visible,
    );
  }
}

/// Horizontal alignment for text.
enum TextHorizontalAlignment {
  left,
  center,
  right,
}

/// Vertical alignment for text.
enum TextVerticalAlignment {
  top,
  middle,
  bottom,
}

/// Visual style for a text tool.
class TextToolStyle {
  /// Color of the text.
  final Color textColor;
  
  /// Font size of the text.
  final double fontSize;
  
  /// Font weight of the text.
  final FontWeight fontWeight;
  
  /// Font style of the text.
  final FontStyle fontStyle;
  
  /// Text alignment.
  final TextAlign textAlign;
  
  /// Horizontal alignment relative to anchor point.
  final TextHorizontalAlignment horizontalAlignment;
  
  /// Vertical alignment relative to anchor point.
  final TextVerticalAlignment verticalAlignment;
  
  /// Whether to show background.
  final bool showBackground;
  
  /// Background color.
  final Color backgroundColor;
  
  /// Padding around text.
  final double padding;
  
  /// Border radius for background.
  final double borderRadius;
  
  /// Whether to show border.
  final bool showBorder;
  
  /// Border color.
  final Color borderColor;
  
  /// Border width.
  final double borderWidth;

  const TextToolStyle({
    this.textColor = const Color(0xFFFFFFFF),
    this.fontSize = 14.0,
    this.fontWeight = FontWeight.normal,
    this.fontStyle = FontStyle.normal,
    this.textAlign = TextAlign.left,
    this.horizontalAlignment = TextHorizontalAlignment.center,
    this.verticalAlignment = TextVerticalAlignment.middle,
    this.showBackground = true,
    this.backgroundColor = const Color(0xFF000000),
    this.padding = 6.0,
    this.borderRadius = 4.0,
    this.showBorder = true,
    this.borderColor = const Color(0xFF2196F3),
    this.borderWidth = 1.0,
  });

  TextToolStyle copyWith({
    Color? textColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    TextAlign? textAlign,
    TextHorizontalAlignment? horizontalAlignment,
    TextVerticalAlignment? verticalAlignment,
    bool? showBackground,
    Color? backgroundColor,
    double? padding,
    double? borderRadius,
    bool? showBorder,
    Color? borderColor,
    double? borderWidth,
  }) {
    return TextToolStyle(
      textColor: textColor ?? this.textColor,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      fontStyle: fontStyle ?? this.fontStyle,
      textAlign: textAlign ?? this.textAlign,
      horizontalAlignment: horizontalAlignment ?? this.horizontalAlignment,
      verticalAlignment: verticalAlignment ?? this.verticalAlignment,
      showBackground: showBackground ?? this.showBackground,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      padding: padding ?? this.padding,
      borderRadius: borderRadius ?? this.borderRadius,
      showBorder: showBorder ?? this.showBorder,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
    );
  }
}

/// Configuration options for a text tool.
class TextToolOptions {
  /// Whether the text can be dragged.
  final bool draggable;
  
  /// Callback when the text is moved.
  /// Parameters: timestamp, price
  final void Function(int timestamp, double price)? onMoved;
  
  /// Callback when the text content should be edited.
  /// Parameters: current text
  /// Should return the new text or null if cancelled
  final Future<String?> Function(String currentText)? onEdit;
  
  /// Callback when the text is deleted.
  final VoidCallback? onDelete;

  const TextToolOptions({
    this.draggable = true,
    this.onMoved,
    this.onEdit,
    this.onDelete,
  });

  TextToolOptions copyWith({
    bool? draggable,
    void Function(int, double)? onMoved,
    Future<String?> Function(String)? onEdit,
    VoidCallback? onDelete,
  }) {
    return TextToolOptions(
      draggable: draggable ?? this.draggable,
      onMoved: onMoved ?? this.onMoved,
      onEdit: onEdit ?? this.onEdit,
      onDelete: onDelete ?? this.onDelete,
    );
  }
}
