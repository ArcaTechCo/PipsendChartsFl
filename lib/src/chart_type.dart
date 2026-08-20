/// Rendering style of the main price series.
enum ChartType {
  /// Japanese candlesticks — body from open to close, wick from high to low.
  candlestick,

  /// OHLC bars — a vertical high/low line with a left tick at the open
  /// and a right tick at the close.
  bar,

  /// Line chart connecting the close of every candle.
  line,

  /// Heikin Ashi candles. The chart derives the smoothed OHLC internally,
  /// so indicators, the crosshair overlay and the price axis all report
  /// Heikin Ashi values while this type is active.
  heikinAshi,
}
