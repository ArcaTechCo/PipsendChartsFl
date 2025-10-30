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
  
  /// Callback when the zone's price range changes.
  final void Function(double minPrice, double maxPrice)? onRangeChanged;
  
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
  
  PriceZoneOptions copyWith({
    String? label,
    bool? showLabel,
    bool? draggable,
    bool? resizable,
    void Function(double, double)? onRangeChanged,
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
