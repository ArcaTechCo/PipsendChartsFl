import 'dart:ui';
import '../scale/price_scale.dart';
import '../series/series.dart';
import '../common/min_max.dart';

/// Manages the layout of the chart, including multiple panels and scales.
///
/// The layout manager calculates the position and size of each panel
/// based on the price scales used by the series.
class ChartLayout {
  /// All price scales in the chart.
  final List<PriceScale> scales;

  /// Total size of the chart.
  final Size size;

  /// Width reserved for price labels on the right.
  final double priceLabelWidth;

  /// Height reserved for time labels at the bottom.
  final double timeLabelHeight;

  ChartLayout({
    required this.scales,
    required this.size,
    this.priceLabelWidth = 48.0,
    this.timeLabelHeight = 24.0,
  });

  /// Gets the available width for drawing (excluding price labels).
  double get chartWidth => size.width - priceLabelWidth;

  /// Gets the available height for drawing (excluding time labels).
  double get chartHeight => size.height - timeLabelHeight;

  /// Calculates the rectangles for each price scale panel.
  ///
  /// Returns a map of scale ID to Rect.
  Map<String, Rect> calculatePanels() {
    final panels = <String, Rect>{};
    
    // Separate scales into fixed and flexible
    final fixedScales = scales.where((s) => s.hasFixedHeight && s.visible).toList();
    final flexibleScales = scales.where((s) => !s.hasFixedHeight && s.visible).toList();

    // Calculate total fixed height
    double totalFixedHeight = 0;
    for (final scale in fixedScales) {
      totalFixedHeight += chartHeight * scale.heightFactor!;
    }

    // Remaining height for flexible scales
    final remainingHeight = chartHeight - totalFixedHeight;
    final flexibleHeightEach = flexibleScales.isEmpty 
        ? 0.0 
        : remainingHeight / flexibleScales.length;

    double currentY = 0;

    // Layout flexible scales first (typically the main chart)
    for (final scale in flexibleScales) {
      panels[scale.id] = Rect.fromLTWH(
        0,
        currentY,
        chartWidth,
        flexibleHeightEach,
      );
      currentY += flexibleHeightEach;
    }

    // Layout fixed scales (volume, indicators, etc.)
    for (final scale in fixedScales) {
      final height = chartHeight * scale.heightFactor!;
      panels[scale.id] = Rect.fromLTWH(
        0,
        currentY,
        chartWidth,
        height,
      );
      currentY += height;
    }

    return panels;
  }

  /// Gets the panel rectangle for a specific scale.
  Rect? getPanelRect(String scaleId) {
    final panels = calculatePanels();
    return panels[scaleId];
  }

  /// Gets the height of a panel for a specific scale.
  double? getPanelHeight(String scaleId) {
    return getPanelRect(scaleId)?.height;
  }

  /// Calculates min/max values for each scale based on visible data.
  ///
  /// [series] is the list of all series in the chart.
  /// [startIndex] is the first visible data point.
  /// [endIndex] is the last visible data point.
  ///
  /// Returns a map of scale ID to MinMax values.
  Map<String, MinMax> calculateScaleRanges(
    List<Series> series,
    int startIndex,
    int endIndex,
  ) {
    final ranges = <String, MinMax>{};

    // Group series by scale
    final seriesByScale = <String, List<Series>>{};
    for (final s in series) {
      if (!s.includeInAutoScale) continue;
      
      final scaleId = s.priceScale.id;
      seriesByScale.putIfAbsent(scaleId, () => []).add(s);
    }

    // Calculate min/max for each scale
    for (final entry in seriesByScale.entries) {
      final scaleId = entry.key;
      final scaleSeries = entry.value;

      double? overallMin;
      double? overallMax;

      for (final s in scaleSeries) {
        final minMax = s.calculateMinMax(startIndex, endIndex);
        if (minMax == null) continue;

        overallMin = overallMin == null 
            ? minMax.min 
            : (minMax.min < overallMin ? minMax.min : overallMin);
        overallMax = overallMax == null 
            ? minMax.max 
            : (minMax.max > overallMax ? minMax.max : overallMax);
      }

      if (overallMin != null && overallMax != null) {
        // Add some padding (5% on each side)
        final padding = (overallMax - overallMin) * 0.05;
        ranges[scaleId] = MinMax(
          min: overallMin - padding,
          max: overallMax + padding,
        );
      }
    }

    return ranges;
  }

  /// Creates a copy of this layout with modified properties.
  ChartLayout copyWith({
    List<PriceScale>? scales,
    Size? size,
    double? priceLabelWidth,
    double? timeLabelHeight,
  }) {
    return ChartLayout(
      scales: scales ?? this.scales,
      size: size ?? this.size,
      priceLabelWidth: priceLabelWidth ?? this.priceLabelWidth,
      timeLabelHeight: timeLabelHeight ?? this.timeLabelHeight,
    );
  }
}
