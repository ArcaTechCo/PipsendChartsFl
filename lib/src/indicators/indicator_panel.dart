/// Defines where an indicator should be displayed on the chart.
enum IndicatorPanelType {
  /// The indicator is drawn on top of the main chart (overlay).
  /// Example: Bollinger Bands, Moving Averages
  overlay,

  /// The indicator is drawn in a separate panel below the main chart.
  /// Example: RSI, MACD, Stochastic
  separate,
}

/// Configuration for an indicator's display panel.
///
/// Indicators can either overlay on the main chart or appear in
/// separate panels below it.
class IndicatorPanel {
  /// The type of panel (overlay or separate).
  final IndicatorPanelType type;

  /// Height factor for separate panels (0.0 to 1.0).
  /// 
  /// For example, 0.2 means the panel takes 20% of the chart height.
  /// Only used when type is [IndicatorPanelType.separate].
  final double? height;

  /// The price scale ID to use for this indicator.
  ///
  /// For overlays, this determines which scale to align with.
  /// For separate panels, a new scale is created with this ID.
  final String? priceScaleId;

  /// Whether to show grid lines in this panel.
  final bool showGrid;

  /// Whether to show the price scale labels.
  final bool showPriceScale;

  const IndicatorPanel({
    required this.type,
    this.height,
    this.priceScaleId,
    this.showGrid = true,
    this.showPriceScale = true,
  });

  /// Creates an overlay panel that draws on top of the main chart.
  ///
  /// [priceScaleId] specifies which scale to use (default is 'main').
  factory IndicatorPanel.overlay({
    String? priceScaleId,
    bool showGrid = false,
  }) {
    return IndicatorPanel(
      type: IndicatorPanelType.overlay,
      priceScaleId: priceScaleId ?? 'main',
      showGrid: showGrid,
      showPriceScale: false,
    );
  }

  /// Creates a separate panel below the main chart.
  ///
  /// [height] determines what percentage of the chart height to use.
  /// Default is 0.2 (20%).
  factory IndicatorPanel.separate({
    double height = 0.2,
    String? priceScaleId,
    bool showGrid = true,
    bool showPriceScale = true,
  }) {
    return IndicatorPanel(
      type: IndicatorPanelType.separate,
      height: height,
      priceScaleId: priceScaleId,
      showGrid: showGrid,
      showPriceScale: showPriceScale,
    );
  }

  /// Whether this is an overlay panel.
  bool get isOverlay => type == IndicatorPanelType.overlay;

  /// Whether this is a separate panel.
  bool get isSeparate => type == IndicatorPanelType.separate;

  @override
  String toString() => 'IndicatorPanel(type: $type, height: $height, scaleId: $priceScaleId)';

  /// Creates a copy with modified properties.
  IndicatorPanel copyWith({
    IndicatorPanelType? type,
    double? height,
    String? priceScaleId,
    bool? showGrid,
    bool? showPriceScale,
  }) {
    return IndicatorPanel(
      type: type ?? this.type,
      height: height ?? this.height,
      priceScaleId: priceScaleId ?? this.priceScaleId,
      showGrid: showGrid ?? this.showGrid,
      showPriceScale: showPriceScale ?? this.showPriceScale,
    );
  }
}
