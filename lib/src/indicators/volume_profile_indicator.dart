import 'dart:math';
import 'package:flutter/material.dart';
import '../candle_data.dart';
import '../painter_params.dart';
import 'indicator.dart';
import 'indicator_panel.dart';
import 'indicator_value.dart';

/// Volume Profile indicator.
///
/// Displays the distribution of volume across different price levels
/// as a horizontal histogram on the right side of the chart.
///
/// Key features:
/// - **POC (Point of Control)**: Price level with the highest volume
/// - **Value Area**: Price range containing 70% of total volume
/// - **High/Low Volume Nodes**: Areas of significant volume concentration
///
/// This indicator helps identify:
/// - Support and resistance levels based on volume
/// - Fair value areas where most trading occurred
/// - Potential breakout or reversal zones
///
/// Example:
/// ```dart
/// VolumeProfileIndicator(
///   bins: 24,
///   style: VolumeProfileStyle(
///     barColor: Colors.blue.withOpacity(0.3),
///     pocColor: Colors.red,
///     valueAreaColor: Colors.yellow.withOpacity(0.1),
///   ),
/// )
/// ```
class VolumeProfileIndicator extends Indicator {
  /// Number of price bins to divide the price range into.
  /// Higher values = more granular profile, lower values = smoother profile.
  final int bins;

  /// Whether to show the POC (Point of Control) line.
  final bool showPOC;

  /// Whether to show the Value Area (70% volume).
  final bool showValueArea;

  VolumeProfileIndicator({
    String? id,
    this.bins = 24,
    this.showPOC = true,
    this.showValueArea = true,
    VolumeProfileStyle? style,
    bool visible = true,
  }) : super(
          id: id ?? 'volume_profile',
          panel: IndicatorPanel.overlay(),
          style: style ?? const VolumeProfileStyle(),
          visible: visible,
        );

  @override
  List<IndicatorValue> calculate(List<CandleData> data) {
    if (data.isEmpty) return [];

    // Find price range - filter out nulls
    double? minPrice;
    double? maxPrice;
    
    for (final candle in data) {
      final low = candle.low;
      final high = candle.high;
      
      if (low != null) {
        minPrice = minPrice == null ? low : (low < minPrice ? low : minPrice);
      }
      if (high != null) {
        maxPrice = maxPrice == null ? high : (high > maxPrice ? high : maxPrice);
      }
    }
    
    if (minPrice == null || maxPrice == null) return [];

    final priceRange = maxPrice - minPrice;
    if (priceRange == 0) return [];

    final binSize = priceRange / bins;

    // Initialize bins
    final volumeByBin = List<double>.filled(bins, 0.0);

    // Aggregate volume into bins
    for (final candle in data) {
      final volume = candle.volume ?? 0.0;
      if (volume == 0) continue;

      final low = candle.low;
      final high = candle.high;
      final close = candle.close;
      
      if (low == null || high == null || close == null) continue;

      // Distribute candle volume across bins it touches
      final candleRange = high - low;
      if (candleRange == 0) {
        // Single price point
        final binIndex = ((close - minPrice) / binSize).floor().clamp(0, bins - 1);
        volumeByBin[binIndex] += volume;
      } else {
        // Distribute proportionally across touched bins
        final startBin = ((low - minPrice) / binSize).floor().clamp(0, bins - 1);
        final endBin = ((high - minPrice) / binSize).floor().clamp(0, bins - 1);
        
        for (int i = startBin; i <= endBin; i++) {
          final binLow = minPrice + (i * binSize);
          final binHigh = minPrice + ((i + 1) * binSize);
          
          // Calculate overlap between candle and bin
          final overlapLow = max(low, binLow);
          final overlapHigh = min(high, binHigh);
          final overlapRatio = (overlapHigh - overlapLow) / candleRange;
          
          volumeByBin[i] += volume * overlapRatio;
        }
      }
    }

    // Find POC (Point of Control) - bin with highest volume
    int pocIndex = 0;
    double maxVolume = volumeByBin[0];
    for (int i = 1; i < bins; i++) {
      if (volumeByBin[i] > maxVolume) {
        maxVolume = volumeByBin[i];
        pocIndex = i;
      }
    }

    // Calculate Value Area (70% of total volume)
    final totalVolume = volumeByBin.reduce((a, b) => a + b);
    final valueAreaVolume = totalVolume * 0.7;
    
    // Expand from POC until we reach 70% volume
    int vaLow = pocIndex;
    int vaHigh = pocIndex;
    double currentVolume = volumeByBin[pocIndex];

    while (currentVolume < valueAreaVolume && (vaLow > 0 || vaHigh < bins - 1)) {
      final volumeBelow = vaLow > 0 ? volumeByBin[vaLow - 1] : 0;
      final volumeAbove = vaHigh < bins - 1 ? volumeByBin[vaHigh + 1] : 0;

      if (volumeBelow > volumeAbove && vaLow > 0) {
        vaLow--;
        currentVolume += volumeByBin[vaLow];
      } else if (vaHigh < bins - 1) {
        vaHigh++;
        currentVolume += volumeByBin[vaHigh];
      } else if (vaLow > 0) {
        vaLow--;
        currentVolume += volumeByBin[vaLow];
      } else {
        break;
      }
    }

    // Store calculated data in indicator values
    // We'll use the first candle to store all the profile data
    final values = <IndicatorValue>[];
    
    for (int i = 0; i < data.length; i++) {
      final map = <String, double?>{};
      
      // Store profile data only once (in first value)
      if (i == 0) {
        map['minPrice'] = minPrice;
        map['maxPrice'] = maxPrice;
        map['binSize'] = binSize;
        map['pocIndex'] = pocIndex.toDouble();
        map['vaLow'] = vaLow.toDouble();
        map['vaHigh'] = vaHigh.toDouble();
        map['maxVolume'] = maxVolume;
        
        // Store volume bins
        for (int j = 0; j < bins; j++) {
          map['bin_$j'] = volumeByBin[j];
        }
      }
      
      values.add(IndicatorValue(
        values: map,
        timestamp: data[i].timestamp,
      ));
    }

    return values;
  }

  @override
  void paint(Canvas canvas, PainterParams params, List<IndicatorValue> values) {
    if (!visible) return;
    if (values.isEmpty) return;

    final profileStyle = style as VolumeProfileStyle;
    
    // Get profile data from first value
    final profileData = values.first.values;
    if (profileData.isEmpty) return;

    final minPrice = profileData['minPrice'];
    final maxPrice = profileData['maxPrice'];
    final binSize = profileData['binSize'];
    final pocIndex = profileData['pocIndex']?.toInt();
    final vaLow = profileData['vaLow']?.toInt();
    final vaHigh = profileData['vaHigh']?.toInt();
    final maxVolume = profileData['maxVolume'];

    if (minPrice == null || maxPrice == null || binSize == null || 
        pocIndex == null || maxVolume == null || maxVolume == 0) return;

    // Calculate histogram width (percentage of chart width)
    final histogramWidth = params.chartWidth * profileStyle.widthFactor;
    final histogramX = params.chartWidth - histogramWidth - 10;

    // Draw Value Area background
    if (showValueArea && vaLow != null && vaHigh != null) {
      final vaTopPrice = minPrice + ((vaHigh + 1) * binSize);
      final vaBottomPrice = minPrice + (vaLow * binSize);
      
      final vaTopY = params.fitPrice(vaTopPrice);
      final vaBottomY = params.fitPrice(vaBottomPrice);

      final vaRect = Rect.fromLTRB(
        histogramX,
        vaTopY,
        histogramX + histogramWidth,
        vaBottomY,
      );

      final vaPaint = Paint()
        ..color = profileStyle.valueAreaColor
        ..style = PaintingStyle.fill;

      canvas.drawRect(vaRect, vaPaint);
    }

    // Draw volume bars
    for (int i = 0; i < bins; i++) {
      final volume = profileData['bin_$i'];
      if (volume == null || volume == 0) continue;

      final barHeight = (volume / maxVolume) * histogramWidth;
      
      final binTopPrice = minPrice + ((i + 1) * binSize);
      final binBottomPrice = minPrice + (i * binSize);
      
      final topY = params.fitPrice(binTopPrice);
      final bottomY = params.fitPrice(binBottomPrice);

      final barRect = Rect.fromLTRB(
        histogramX + histogramWidth - barHeight,
        topY,
        histogramX + histogramWidth,
        bottomY,
      );

      final barPaint = Paint()
        ..color = i == pocIndex ? profileStyle.pocBarColor : profileStyle.barColor
        ..style = PaintingStyle.fill;

      canvas.drawRect(barRect, barPaint);

      // Draw bar border
      final borderPaint = Paint()
        ..color = profileStyle.borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;

      canvas.drawRect(barRect, borderPaint);
    }

    // Draw POC line
    if (showPOC) {
      final pocPrice = minPrice + ((pocIndex + 0.5) * binSize);
      final pocY = params.fitPrice(pocPrice);

      final pocPaint = Paint()
        ..color = profileStyle.pocLineColor
        ..strokeWidth = profileStyle.pocLineWidth
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(histogramX, pocY),
        Offset(histogramX + histogramWidth, pocY),
        pocPaint,
      );

      // Draw POC label
      if (profileStyle.showLabels) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: 'POC',
            style: TextStyle(
              color: profileStyle.labelColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(histogramX - textPainter.width - 4, pocY - textPainter.height / 2),
        );
      }
    }
  }
}

/// Style configuration for Volume Profile indicator.
class VolumeProfileStyle extends IndicatorStyle {
  /// Color of volume bars.
  final Color barColor;

  /// Color of the POC (Point of Control) bar.
  final Color pocBarColor;

  /// Color of the POC line.
  final Color pocLineColor;

  /// Width of the POC line.
  final double pocLineWidth;

  /// Color of the Value Area background.
  final Color valueAreaColor;

  /// Color of bar borders.
  final Color borderColor;

  /// Color of labels.
  final Color labelColor;

  /// Whether to show labels (POC, VA).
  final bool showLabels;

  /// Width factor of the histogram (0.0 to 1.0).
  /// 0.15 = 15% of chart width.
  final double widthFactor;

  const VolumeProfileStyle({
    this.barColor = const Color(0x4D2196F3), // Blue with 30% opacity
    this.pocBarColor = const Color(0x80FF5252), // Red with 50% opacity
    this.pocLineColor = const Color(0xFFFF5252), // Solid red
    this.pocLineWidth = 2.0,
    this.valueAreaColor = const Color(0x1AFFEB3B), // Yellow with 10% opacity
    this.borderColor = const Color(0x33FFFFFF), // White with 20% opacity
    this.labelColor = Colors.white,
    this.showLabels = true,
    this.widthFactor = 0.15,
  });

  /// Creates a copy with modified properties.
  VolumeProfileStyle copyWith({
    Color? barColor,
    Color? pocBarColor,
    Color? pocLineColor,
    double? pocLineWidth,
    Color? valueAreaColor,
    Color? borderColor,
    Color? labelColor,
    bool? showLabels,
    double? widthFactor,
  }) {
    return VolumeProfileStyle(
      barColor: barColor ?? this.barColor,
      pocBarColor: pocBarColor ?? this.pocBarColor,
      pocLineColor: pocLineColor ?? this.pocLineColor,
      pocLineWidth: pocLineWidth ?? this.pocLineWidth,
      valueAreaColor: valueAreaColor ?? this.valueAreaColor,
      borderColor: borderColor ?? this.borderColor,
      labelColor: labelColor ?? this.labelColor,
      showLabels: showLabels ?? this.showLabels,
      widthFactor: widthFactor ?? this.widthFactor,
    );
  }
}
