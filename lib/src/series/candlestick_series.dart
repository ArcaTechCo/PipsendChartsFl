import 'dart:math';
import 'package:flutter/painting.dart';
import '../candle_data.dart';
import '../scale/price_scale.dart';
import '../painter_params.dart';
import '../common/min_max.dart';
import 'series.dart';
import 'series_type.dart';

/// A series that displays candlestick (OHLC) data.
class CandlestickSeries extends Series {
  /// The candlestick data to display.
  final List<CandleData> data;

  /// Style configuration for this series.
  final CandlestickStyle style;

  CandlestickSeries({
    String? id,
    required this.data,
    PriceScale? priceScale,
    CandlestickStyle? style,
    bool visible = true,
    int zIndex = 0,
  })  : this.style = style ?? CandlestickStyle(),
        super(
          id: id ?? 'candlestick',
          type: SeriesType.candlestick,
          priceScale: priceScale ?? PriceScale.main(),
          visible: visible,
          zIndex: zIndex,
        );

  @override
  void paint(Canvas canvas, PainterParams params) {
    if (!visible || data.isEmpty) return;

    for (int i = 0; i < data.length && i < params.candles.length; i++) {
      _paintCandle(canvas, params, i);
    }
  }

  void _paintCandle(Canvas canvas, PainterParams params, int index) {
    final candle = data[index];
    final x = index * params.candleWidth;
    final thickWidth = max(params.candleWidth * 0.8, 0.8);
    final thinWidth = max(params.candleWidth * 0.2, 0.2);

    final open = candle.open;
    final close = candle.close;
    final high = candle.high;
    final low = candle.low;

    if (open == null || close == null) return;

    final color = open > close ? style.priceLossColor : style.priceGainColor;

    // Draw thick body (open to close)
    canvas.drawLine(
      Offset(x, params.fitPrice(open)),
      Offset(x, params.fitPrice(close)),
      Paint()
        ..strokeWidth = thickWidth
        ..color = color,
    );

    // Draw thin wick (high to low)
    if (high != null && low != null) {
      canvas.drawLine(
        Offset(x, params.fitPrice(high)),
        Offset(x, params.fitPrice(low)),
        Paint()
          ..strokeWidth = thinWidth
          ..color = color,
      );
    }
  }

  @override
  double? getValueAt(int index) {
    if (index < 0 || index >= data.length) return null;
    return data[index].close;
  }

  @override
  MinMax? calculateMinMax(int startIndex, int endIndex) {
    if (data.isEmpty) return null;

    final start = startIndex.clamp(0, data.length - 1);
    final end = endIndex.clamp(start, data.length);

    double? minPrice;
    double? maxPrice;

    for (int i = start; i < end; i++) {
      final candle = data[i];
      
      // Get the highest point
      final high = candle.high ?? 
                   (candle.open != null && candle.close != null 
                       ? max(candle.open!, candle.close!) 
                       : candle.open ?? candle.close);
      
      // Get the lowest point
      final low = candle.low ?? 
                  (candle.open != null && candle.close != null 
                      ? min(candle.open!, candle.close!) 
                      : candle.open ?? candle.close);

      if (high != null) {
        maxPrice = maxPrice == null ? high : max(maxPrice, high);
      }
      if (low != null) {
        minPrice = minPrice == null ? low : min(minPrice, low);
      }
    }

    if (minPrice == null || maxPrice == null) return null;

    return MinMax(min: minPrice, max: maxPrice);
  }

  @override
  int get dataLength => data.length;
}

/// Style configuration for candlestick series.
class CandlestickStyle extends SeriesStyle {
  /// Color for candles where close > open (bullish).
  final Color priceGainColor;

  /// Color for candles where close < open (bearish).
  final Color priceLossColor;

  /// Width multiplier for the candle body (0.0 to 1.0).
  final double bodyWidthFactor;

  /// Width multiplier for the candle wick (0.0 to 1.0).
  final double wickWidthFactor;

  const CandlestickStyle({
    this.priceGainColor = const Color(0xFF26A69A),
    this.priceLossColor = const Color(0xFFEF5350),
    this.bodyWidthFactor = 0.8,
    this.wickWidthFactor = 0.2,
  });

  CandlestickStyle copyWith({
    Color? priceGainColor,
    Color? priceLossColor,
    double? bodyWidthFactor,
    double? wickWidthFactor,
  }) {
    return CandlestickStyle(
      priceGainColor: priceGainColor ?? this.priceGainColor,
      priceLossColor: priceLossColor ?? this.priceLossColor,
      bodyWidthFactor: bodyWidthFactor ?? this.bodyWidthFactor,
      wickWidthFactor: wickWidthFactor ?? this.wickWidthFactor,
    );
  }
}
