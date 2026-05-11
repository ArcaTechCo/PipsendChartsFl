import 'package:pipsend_charts/pipsend_charts.dart';

/// Generates a synthetic candle series for tests. Spacing is 1 hour
/// between candles by default. Prices follow a deterministic sine wave
/// so tests can compare values exactly.
List<CandleData> fakeCandles({
  int count = 200,
  int startTsMs = 1700000000000,
  int stepMs = 60 * 60 * 1000,
  double base = 100.0,
}) {
  final out = <CandleData>[];
  for (var i = 0; i < count; i++) {
    final phase = i / 10.0;
    final open = base + 5 * _sin(phase);
    final close = base + 5 * _sin(phase + 0.5);
    final high = (open > close ? open : close) + 1.5;
    final low = (open < close ? open : close) - 1.5;
    out.add(CandleData(
      timestamp: startTsMs + i * stepMs,
      open: open,
      close: close,
      high: high,
      low: low,
      volume: 1000.0 + i * 3,
    ));
  }
  return out;
}

double _sin(double x) {
  // Taylor-ish approximation good enough for [-π, π]. Tests don't
  // need cryptographic precision.
  while (x > 3.14159265) x -= 6.2831853;
  while (x < -3.14159265) x += 6.2831853;
  final x2 = x * x;
  return x * (1 - x2 / 6 + x2 * x2 / 120);
}
