class CandleData {
  /// The timestamp of this data point, in milliseconds since epoch.
  final int timestamp;

  /// The "open" price of this data point. It's acceptable to have null here for
  /// a few data points, but they must not all be null. If either [open] or
  /// [close] is null for a data point, it will appear as a gap in the chart.
  final double? open;

  /// The "high" price. If either one of [high] or [low] is null, we won't
  /// draw the narrow part of the candlestick for that data point.
  final double? high;

  /// The "low" price. If either one of [high] or [low] is null, we won't
  /// draw the narrow part of the candlestick for that data point.
  final double? low;

  /// The "close" price of this data point. It's acceptable to have null here
  /// for a few data points, but they must not all be null. If either [open] or
  /// [close] is null for a data point, it will appear as a gap in the chart.
  final double? close;

  /// The volume information of this data point.
  final double? volume;

  /// Data holder for additional trend lines, for this data point.
  ///
  /// For a single trend line, we can assign it as a list with a single element.
  /// For example if we want "7 days moving average", do something like
  /// `trends = [ma7]`. If there are multiple tread lines, we can assign a list
  /// with multiple elements, like `trends = [ma7, ma30]`.
  /// If we don't want any trend lines, we can assign an empty list.
  ///
  /// This should be an unmodifiable list, so please do not use `add`
  /// or `clear` methods on the list. Always assign a new list if values
  /// are changed. Otherwise the UI might not be updated.
  List<double?> trends;

  CandleData({
    required this.timestamp,
    required this.open,
    required this.close,
    required this.volume,
    this.high,
    this.low,
    List<double?>? trends,
  }) : this.trends = List.unmodifiable(trends ?? []);

  static List<double?> computeMA(List<CandleData> data, [int period = 7]) {
    // If data is not at least twice as long as the period, return nulls.
    if (data.length < period * 2) return List.filled(data.length, null);

    final List<double?> result = [];
    // Skip the first [period] data points. For example, skip 7 data points.
    final firstPeriod =
        data.take(period).map((d) => d.close).whereType<double>();
    double ma = firstPeriod.reduce((a, b) => a + b) / firstPeriod.length;
    result.addAll(List.filled(period, null));

    // Compute the moving average for the rest of the data points.
    for (int i = period; i < data.length; i++) {
      final curr = data[i].close;
      final prev = data[i - period].close;
      if (curr != null && prev != null) {
        ma = (ma * period + curr - prev) / period;
        result.add(ma);
      } else {
        result.add(null);
      }
    }
    return result;
  }

  /// Builds a "partially formed" candle for tick-replay mode.
  ///
  /// Given a fully-closed [real] candle and a [progress] in `[0.0, 1.0]`,
  /// returns a synthetic candle whose `close` interpolates linearly from
  /// `real.open` (at progress 0) to `real.close` (at progress 1). `high`
  /// and `low` are clipped so they always include both `open` and the
  /// interpolated `close` — this avoids the wick "popping out" only at
  /// progress 1.
  ///
  /// Returns the original candle unchanged when `progress >= 1.0`.
  /// Returns a flat candle (`open == close == high == low`) when
  /// `progress <= 0.0`.
  ///
  /// Volume is scaled linearly with progress.
  ///
  /// This is the simplest fallback for tick replay when no smaller
  /// timeframe is available. For higher fidelity, replace the candle
  /// at the playhead with an actual sub-timeframe candle and pass
  /// `progress = 1.0` for each sub-step instead.
  static CandleData buildPartial(CandleData real, double progress) {
    final p = progress.clamp(0.0, 1.0);
    final open = real.open;
    final close = real.close;
    if (open == null || close == null) {
      return real;
    }
    if (p >= 1.0) return real;
    if (p <= 0.0) {
      return CandleData(
        timestamp: real.timestamp,
        open: open,
        close: open,
        high: open,
        low: open,
        volume: 0,
        trends: real.trends,
      );
    }
    final interpClose = open + (close - open) * p;
    final realHigh = real.high ?? (open > close ? open : close);
    final realLow = real.low ?? (open < close ? open : close);
    // Lerp the wicks proportionally — they "grow" as progress advances.
    final hi = open > interpClose ? open : interpClose;
    final lo = open < interpClose ? open : interpClose;
    final high = hi + (realHigh - hi) * p;
    final low = lo - (lo - realLow) * p;
    final vol = (real.volume ?? 0) * p;
    return CandleData(
      timestamp: real.timestamp,
      open: open,
      close: interpClose,
      high: high,
      low: low,
      volume: vol,
      trends: real.trends,
    );
  }

  @override
  String toString() => "<CandleData ($timestamp: $close)>";
}
