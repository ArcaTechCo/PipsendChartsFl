/// Types of series that can be displayed on the chart.
enum SeriesType {
  /// Candlestick chart - shows OHLC data.
  candlestick,

  /// Line chart - connects data points with a line.
  line,

  /// Area chart - line chart with filled area below.
  area,

  /// Histogram - vertical bars.
  histogram,

  /// Bar chart - shows OHLC as bars instead of candles.
  bar,
}
