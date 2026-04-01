/// Options for configuring a price zone.
class PriceZoneOptions {
  /// Label text to display on the zone.
  final String? label;
  
  /// Whether to show the label.
  final bool showLabel;
  
  /// Whether the zone can be dragged.
  final bool draggable;
  
  /// Whether the zone can be resized.
  final bool resizable;
  
  /// Callback when the zone's price range or time range changes.
  /// Parameters: minPrice, maxPrice, startTime, endTime
  final void Function(double minPrice, double maxPrice, int? startTime, int? endTime)? onRangeChanged;
  
  /// Callback when the zone is deleted.
  final void Function()? onDelete;
  
  const PriceZoneOptions({
    this.label,
    this.showLabel = true,
    this.draggable = false,
    this.resizable = false,
    this.onRangeChanged,
    this.onDelete,
  });
  
  Map<String, dynamic> toJson() => {
    if (label != null) 'label': label,
    'showLabel': showLabel,
    'draggable': draggable,
    'resizable': resizable,
  };

  factory PriceZoneOptions.fromJson(Map<String, dynamic> json) {
    return PriceZoneOptions(
      label: json['label'] as String?,
      showLabel: json['showLabel'] as bool? ?? true,
      draggable: json['draggable'] as bool? ?? false,
      resizable: json['resizable'] as bool? ?? false,
    );
  }

  PriceZoneOptions copyWith({
    String? label,
    bool? showLabel,
    bool? draggable,
    bool? resizable,
    void Function(double, double, int?, int?)? onRangeChanged,
    void Function()? onDelete,
  }) {
    return PriceZoneOptions(
      label: label ?? this.label,
      showLabel: showLabel ?? this.showLabel,
      draggable: draggable ?? this.draggable,
      resizable: resizable ?? this.resizable,
      onRangeChanged: onRangeChanged ?? this.onRangeChanged,
      onDelete: onDelete ?? this.onDelete,
    );
  }
}
