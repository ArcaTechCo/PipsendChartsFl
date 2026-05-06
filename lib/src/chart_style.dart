import 'package:flutter/material.dart';
import 'grid_style.dart';

class ChartStyle {
  /// The percentage height of volume.
  ///
  /// Defaults to 0.2, which means volume bars will be 20% of total height,
  /// thus leaving price bars to be 80% of the total height.
  final double volumeHeightFactor;

  /// The padding on the right-side of the chart.
  final double priceLabelWidth;

  /// The padding on the bottom-side of the chart.
  ///
  /// Defaults to 24.0, date/time labels is drawn vertically bottom-aligned,
  /// thus adjusting this value would also control the padding between
  /// the chart and the date/time labels.
  final double timeLabelHeight;

  /// The style of date/time labels (on the bottom of the chart).
  final TextStyle timeLabelStyle;

  /// The style of price labels (on the right of the chart).
  final TextStyle priceLabelStyle;

  /// The style of overlay texts. These texts are drawn on top of the
  /// background color specified in [overlayBackgroundColor].
  ///
  /// This appears when user clicks on the chart.
  final TextStyle overlayTextStyle;

  /// The color to use when the `close` price is higher than `open` price.
  final Color priceGainColor;

  /// The color to use when the `close` price is lower than `open` price.
  final Color priceLossColor;

  /// Whether to show volume bars.
  /// 
  /// Defaults to true. Set to false to hide volume bars.
  final bool showVolume;

  /// The color of the `volume` bars.
  final Color volumeColor;

  /// The style of trend lines. If there are multiple lines, their styles will
  /// be chosen in the order of appearance in this list. If this list is shorter
  /// than the number of trend lines, a default blue paint will be applied.
  final List<Paint> trendLineStyles;

  /// Grid configuration for horizontal and vertical lines.
  /// 
  /// Use this to configure grid appearance including colors, line styles,
  /// and visibility for both horizontal (price) and vertical (time) grid lines.
  /// 
  /// Example:
  /// ```dart
  /// gridStyle: GridStyle.full,  // Show both horizontal and vertical
  /// ```
  final GridStyle gridStyle;

  /// The color of the price grid line.
  /// 
  /// @deprecated Use gridStyle.horizontalGridColor instead.
  @Deprecated('Use gridStyle.horizontalGridColor instead')
  final Color? priceGridLineColor;

  /// The highlight color. This appears when user clicks on the chart.
  final Color selectionHighlightColor;

  /// Whether to render the crosshair (tap highlight) as thin dashed lines instead of
  /// a solid vertical highlight bar plus a solid horizontal line.
  ///
  /// When false (default), the crosshair shows a wide vertical bar over the selected
  /// candle and a solid horizontal price line.
  /// When true, both axes render as thin dashed lines (TradingView-style crosshair).
  final bool crosshairDashed;

  /// The background color of the overlay.
  ///
  /// This appears when user clicks on the chart.
  final Color overlayBackgroundColor;

  /// The border radius for rounded candle corners.
  ///
  /// Defaults to 0.0 (square corners). Set to a positive value to round
  /// the corners of the candle bodies. For example:
  /// - 0.0 = Square corners (default)
  /// - 2.0 = Slightly rounded
  /// - 4.0 = Moderately rounded
  /// - 8.0 = Very rounded
  ///
  /// Note: This only affects the thick body of the candle (open-close),
  /// not the thin wicks (high-low).
  final double candleBorderRadius;

  /// Enable adaptive label calculation based on chart size.
  ///
  /// When true, the number of price and time labels will automatically
  /// adjust based on the chart dimensions for optimal readability.
  ///
  /// Default: true
  final bool adaptiveLabels;

  /// Number of price labels to display (vertical axis).
  ///
  /// If null and adaptiveLabels is true, calculates automatically based on chart height.
  /// Range: 3-10
  /// Default: null (adaptive)
  final int? priceLabelCount;

  /// Density of time labels (horizontal axis) in pixels.
  ///
  /// Controls spacing between time labels. Lower values = more labels.
  /// If null and adaptiveLabels is true, uses default of 90 pixels.
  /// Range: 60-120
  /// Default: null (90 pixels)
  final int? timeLabelDensity;

  const ChartStyle({
    this.volumeHeightFactor = 0.2,
    this.priceLabelWidth = 48.0,
    this.timeLabelHeight = 24.0,
    this.timeLabelStyle = const TextStyle(
      fontSize: 16,
      color: Colors.grey,
    ),
    this.priceLabelStyle = const TextStyle(
      fontSize: 12,
      color: Colors.grey,
    ),
    this.overlayTextStyle = const TextStyle(
      fontSize: 16,
      color: Colors.white,
    ),
    this.priceGainColor = Colors.green,
    this.priceLossColor = Colors.red,
    this.showVolume = true,
    this.volumeColor = Colors.grey,
    this.trendLineStyles = const [],
    this.gridStyle = const GridStyle(),
    @Deprecated('Use gridStyle.horizontalGridColor instead')
    this.priceGridLineColor,
    this.selectionHighlightColor = const Color(0x33757575),
    this.crosshairDashed = false,
    this.overlayBackgroundColor = const Color(0xEE757575),
    this.candleBorderRadius = 0.0,
    this.adaptiveLabels = true,
    this.priceLabelCount,
    this.timeLabelDensity,
  });

  /// Get the effective horizontal grid color (for backward compatibility).
  Color get effectiveHorizontalGridColor =>
      priceGridLineColor ?? gridStyle.horizontalGridColor;
}
