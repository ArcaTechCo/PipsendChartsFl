import 'package:flutter/material.dart';
import '../candle_data.dart';
import '../painter_params.dart';
import 'indicator.dart';
import 'indicator_panel.dart';
import 'indicator_value.dart';

/// Trading Sessions indicator for Forex markets.
///
/// Visualizes the three major trading sessions:
/// - Tokyo Session (00:00-09:00 UTC) - Orange
/// - London Session (08:00-17:00 UTC) - Blue
/// - New York Session (13:00-22:00 UTC) - Green
///
/// Overlaps between sessions are shown in purple, indicating
/// periods of higher liquidity and volatility.
///
/// This indicator is particularly useful for Forex traders to:
/// - Identify high-liquidity periods
/// - Plan trades around session opens/closes
/// - Understand market behavior patterns
///
/// Example:
/// ```dart
/// TradingSessionsIndicator(
///   style: TradingSessionsStyle(
///     showTokyo: true,
///     showLondon: true,
///     showNewYork: true,
///     tokyoColor: Colors.orange.withOpacity(0.1),
///     londonColor: Colors.blue.withOpacity(0.1),
///     newYorkColor: Colors.green.withOpacity(0.1),
///   ),
/// )
/// ```
class TradingSessionsIndicator extends Indicator {
  TradingSessionsIndicator({
    String? id,
    TradingSessionsStyle? style,
    bool visible = true,
  }) : super(
          id: id ?? 'trading_sessions',
          panel: IndicatorPanel.overlay(),
          style: style ?? const TradingSessionsStyle(),
          visible: visible,
        );

  @override
  List<IndicatorValue> calculate(List<CandleData> data) {
    // This indicator doesn't calculate values, it just renders zones
    // Return empty values for each candle
    return data.map((candle) {
      return IndicatorValue(
        values: {},
        timestamp: candle.timestamp,
      );
    }).toList();
  }

  @override
  void paint(Canvas canvas, PainterParams params, List<IndicatorValue> values) {
    if (!visible) return;
    if (params.candles.isEmpty) return;

    final sessionsStyle = style as TradingSessionsStyle;

    // Paint each candle's session background
    for (int i = 0; i < params.candles.length; i++) {
      final candle = params.candles[i];
      final dateTime = DateTime.fromMillisecondsSinceEpoch(candle.timestamp, isUtc: true);
      final hour = dateTime.hour;

      // Determine which session(s) this candle belongs to
      final inTokyo = hour >= 0 && hour < 9;
      final inLondon = hour >= 8 && hour < 17;
      final inNewYork = hour >= 13 && hour < 22;

      // Calculate overlap
      int sessionCount = 0;
      if (inTokyo && sessionsStyle.showTokyo) sessionCount++;
      if (inLondon && sessionsStyle.showLondon) sessionCount++;
      if (inNewYork && sessionsStyle.showNewYork) sessionCount++;

      Color? sessionColor;

      // Determine color based on sessions
      if (sessionCount > 1) {
        // Overlap - use purple
        sessionColor = sessionsStyle.overlapColor;
      } else if (sessionCount == 1) {
        // Single session
        if (inTokyo && sessionsStyle.showTokyo) {
          sessionColor = sessionsStyle.tokyoColor;
        } else if (inLondon && sessionsStyle.showLondon) {
          sessionColor = sessionsStyle.londonColor;
        } else if (inNewYork && sessionsStyle.showNewYork) {
          sessionColor = sessionsStyle.newYorkColor;
        }
      }

      // Draw session background
      if (sessionColor != null) {
        final x = i * params.candleWidth;
        final rect = Rect.fromLTWH(
          x,
          0,
          params.candleWidth,
          params.chartHeight,
        );

        final paint = Paint()
          ..color = sessionColor
          ..style = PaintingStyle.fill;

        canvas.drawRect(rect, paint);
      }
    }

    // Draw session labels at the top if enabled
    if (sessionsStyle.showLabels) {
      _drawSessionLabels(canvas, params, sessionsStyle);
    }
  }

  void _drawSessionLabels(Canvas canvas, PainterParams params, TradingSessionsStyle style) {
    const labelHeight = 20.0;
    const labelPadding = 4.0;
    final labelY = 5.0;

    double currentX = 10.0;

    // Helper to draw a label
    void drawLabel(String text, Color color, bool show) {
      if (!show) return;

      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: style.labelTextColor,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final labelWidth = textPainter.width + labelPadding * 2 + 16;

      // Draw background
      final bgRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(currentX, labelY, labelWidth, labelHeight),
        const Radius.circular(4),
      );
      final bgPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawRRect(bgRect, bgPaint);

      // Draw color indicator
      final indicatorRect = Rect.fromLTWH(
        currentX + labelPadding,
        labelY + 6,
        8,
        8,
      );
      final indicatorPaint = Paint()
        ..color = color.withOpacity(1.0)
        ..style = PaintingStyle.fill;
      canvas.drawRect(indicatorRect, indicatorPaint);

      // Draw text
      textPainter.paint(
        canvas,
        Offset(currentX + labelPadding + 12, labelY + (labelHeight - textPainter.height) / 2),
      );

      currentX += labelWidth + 8;
    }

    // Draw labels
    drawLabel('Tokyo', style.tokyoColor.withOpacity(0.8), style.showTokyo);
    drawLabel('London', style.londonColor.withOpacity(0.8), style.showLondon);
    drawLabel('New York', style.newYorkColor.withOpacity(0.8), style.showNewYork);
    drawLabel('Overlap', style.overlapColor.withOpacity(0.8), true);
  }
}

/// Style configuration for Trading Sessions indicator.
class TradingSessionsStyle extends IndicatorStyle {
  /// Whether to show Tokyo session (00:00-09:00 UTC).
  final bool showTokyo;

  /// Whether to show London session (08:00-17:00 UTC).
  final bool showLondon;

  /// Whether to show New York session (13:00-22:00 UTC).
  final bool showNewYork;

  /// Whether to show session labels at the top.
  final bool showLabels;

  /// Color for Tokyo session.
  final Color tokyoColor;

  /// Color for London session.
  final Color londonColor;

  /// Color for New York session.
  final Color newYorkColor;

  /// Color for session overlaps.
  final Color overlapColor;

  /// Text color for labels.
  final Color labelTextColor;

  const TradingSessionsStyle({
    this.showTokyo = true,
    this.showLondon = true,
    this.showNewYork = true,
    this.showLabels = true,
    this.tokyoColor = const Color(0x1AFF9800), // Orange with 10% opacity
    this.londonColor = const Color(0x1A2196F3), // Blue with 10% opacity
    this.newYorkColor = const Color(0x1A4CAF50), // Green with 10% opacity
    this.overlapColor = const Color(0x1A9C27B0), // Purple with 10% opacity
    this.labelTextColor = Colors.white,
  });

  /// Creates a copy with modified properties.
  TradingSessionsStyle copyWith({
    bool? showTokyo,
    bool? showLondon,
    bool? showNewYork,
    bool? showLabels,
    Color? tokyoColor,
    Color? londonColor,
    Color? newYorkColor,
    Color? overlapColor,
    Color? labelTextColor,
  }) {
    return TradingSessionsStyle(
      showTokyo: showTokyo ?? this.showTokyo,
      showLondon: showLondon ?? this.showLondon,
      showNewYork: showNewYork ?? this.showNewYork,
      showLabels: showLabels ?? this.showLabels,
      tokyoColor: tokyoColor ?? this.tokyoColor,
      londonColor: londonColor ?? this.londonColor,
      newYorkColor: newYorkColor ?? this.newYorkColor,
      overlapColor: overlapColor ?? this.overlapColor,
      labelTextColor: labelTextColor ?? this.labelTextColor,
    );
  }
}
