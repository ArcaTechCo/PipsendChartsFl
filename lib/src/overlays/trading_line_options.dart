import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Position of the label on the trading line.
enum LabelPosition {
  /// Label on the left side of the chart.
  left,

  /// Label on the right side of the chart.
  right,

  /// Label in the center of the chart.
  center,

  /// Custom position (use customLabelOffset).
  custom,
}

/// Configuration options for trading lines.
class TradingLineOptions {
  /// Whether to show the label (title).
  final bool showLabel;

  /// Whether to show the price.
  final bool showPrice;

  /// Custom title for the line (overrides default).
  final String? title;

  /// Custom text to display next to the price.
  final String? customText;

  /// Color of the custom text.
  final Color? customTextColor;

  /// Font size of the custom text.
  final double? customTextFontSize;

  /// Background color of the custom text.
  final Color? customTextBackgroundColor;

  /// Position of the label.
  final LabelPosition labelPosition;

  /// Custom offset for the label (when labelPosition is custom).
  final Offset? customLabelOffset;

  /// Custom formatter for the price display.
  final String Function(double)? priceFormatter;

  /// Whether the line can be dragged.
  final bool draggable;

  /// Whether the line can be deleted.
  final bool deletable;

  /// Callback when the line is tapped.
  final VoidCallback? onTap;

  /// Callback when the price changes (via drag).
  final ValueChanged<double>? onPriceChanged;

  /// Callback when the line is being dragged (real-time updates).
  final ValueChanged<double>? onPriceDragging;

  /// Callback when the line is deleted.
  final VoidCallback? onDelete;

  const TradingLineOptions({
    this.showLabel = true,
    this.showPrice = true,
    this.title,
    this.customText,
    this.customTextColor,
    this.customTextFontSize,
    this.customTextBackgroundColor,
    this.labelPosition = LabelPosition.left,
    this.customLabelOffset,
    this.priceFormatter,
    this.draggable = true,
    this.deletable = true,
    this.onTap,
    this.onPriceChanged,
    this.onPriceDragging,
    this.onDelete,
  });

  /// Creates a copy with modified properties.
  TradingLineOptions copyWith({
    bool? showLabel,
    bool? showPrice,
    String? title,
    String? customText,
    Color? customTextColor,
    double? customTextFontSize,
    Color? customTextBackgroundColor,
    LabelPosition? labelPosition,
    Offset? customLabelOffset,
    String Function(double)? priceFormatter,
    bool? draggable,
    bool? deletable,
    VoidCallback? onTap,
    ValueChanged<double>? onPriceChanged,
    ValueChanged<double>? onPriceDragging,
    VoidCallback? onDelete,
  }) {
    return TradingLineOptions(
      showLabel: showLabel ?? this.showLabel,
      showPrice: showPrice ?? this.showPrice,
      title: title ?? this.title,
      customText: customText ?? this.customText,
      customTextColor: customTextColor ?? this.customTextColor,
      customTextFontSize: customTextFontSize ?? this.customTextFontSize,
      customTextBackgroundColor: customTextBackgroundColor ?? this.customTextBackgroundColor,
      labelPosition: labelPosition ?? this.labelPosition,
      customLabelOffset: customLabelOffset ?? this.customLabelOffset,
      priceFormatter: priceFormatter ?? this.priceFormatter,
      draggable: draggable ?? this.draggable,
      deletable: deletable ?? this.deletable,
      onTap: onTap ?? this.onTap,
      onPriceChanged: onPriceChanged ?? this.onPriceChanged,
      onPriceDragging: onPriceDragging ?? this.onPriceDragging,
      onDelete: onDelete ?? this.onDelete,
    );
  }

  Map<String, dynamic> toJson() => {
    'showLabel': showLabel,
    'showPrice': showPrice,
    if (title != null) 'title': title,
    if (customText != null) 'customText': customText,
    if (customTextColor != null) 'customTextColor': customTextColor!.value,
    if (customTextFontSize != null) 'customTextFontSize': customTextFontSize,
    if (customTextBackgroundColor != null) 'customTextBackgroundColor': customTextBackgroundColor!.value,
    'labelPosition': labelPosition.name,
    if (customLabelOffset != null) 'customLabelOffset': {'dx': customLabelOffset!.dx, 'dy': customLabelOffset!.dy},
    'draggable': draggable,
    'deletable': deletable,
  };

  factory TradingLineOptions.fromJson(Map<String, dynamic> json) {
    return TradingLineOptions(
      showLabel: json['showLabel'] as bool? ?? true,
      showPrice: json['showPrice'] as bool? ?? true,
      title: json['title'] as String?,
      customText: json['customText'] as String?,
      customTextColor: json['customTextColor'] != null ? Color(json['customTextColor'] as int) : null,
      customTextFontSize: (json['customTextFontSize'] as num?)?.toDouble(),
      customTextBackgroundColor: json['customTextBackgroundColor'] != null ? Color(json['customTextBackgroundColor'] as int) : null,
      labelPosition: LabelPosition.values.firstWhere(
        (e) => e.name == json['labelPosition'],
        orElse: () => LabelPosition.left,
      ),
      customLabelOffset: json['customLabelOffset'] != null
          ? Offset((json['customLabelOffset']['dx'] as num).toDouble(), (json['customLabelOffset']['dy'] as num).toDouble())
          : null,
      draggable: json['draggable'] as bool? ?? true,
      deletable: json['deletable'] as bool? ?? true,
    );
  }
}
