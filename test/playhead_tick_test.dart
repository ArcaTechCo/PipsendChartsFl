import 'package:flutter_test/flutter_test.dart';
import 'package:pipsend_charts/pipsend_charts.dart';

void main() {
  group('CandleData.buildPartial', () {
    final real = CandleData(
      timestamp: 1700000000000,
      open: 100,
      close: 110,
      high: 112,
      low: 99,
      volume: 1000,
    );

    test('progress = 0 returns flat candle at open', () {
      final p = CandleData.buildPartial(real, 0.0);
      expect(p.open, 100);
      expect(p.close, 100);
      expect(p.high, 100);
      expect(p.low, 100);
      expect(p.volume, 0);
      expect(p.timestamp, real.timestamp);
    });

    test('progress = 1 returns the original candle', () {
      final p = CandleData.buildPartial(real, 1.0);
      expect(p.open, real.open);
      expect(p.close, real.close);
      expect(p.high, real.high);
      expect(p.low, real.low);
      expect(p.volume, real.volume);
    });

    test('progress = 0.5 interpolates close linearly', () {
      final p = CandleData.buildPartial(real, 0.5);
      // Open 100 → close 110 at 50% = 105
      expect(p.close, closeTo(105.0, 0.0001));
      expect(p.volume, closeTo(500.0, 0.0001));
    });

    test('high/low always contain open and current close', () {
      for (final t in [0.1, 0.25, 0.5, 0.75, 0.9]) {
        final p = CandleData.buildPartial(real, t);
        final hi = [p.open!, p.close!].reduce((a, b) => a > b ? a : b);
        final lo = [p.open!, p.close!].reduce((a, b) => a < b ? a : b);
        expect(p.high! >= hi, isTrue,
            reason: 'high $p must include max(open,close) at progress=$t');
        expect(p.low! <= lo, isTrue,
            reason: 'low $p must include min(open,close) at progress=$t');
      }
    });

    test('progress clamped to [0, 1]', () {
      expect(CandleData.buildPartial(real, -0.2).close, 100);
      expect(CandleData.buildPartial(real, 1.5).close, 110);
    });

    test('null open or close returns original unchanged', () {
      final noOpen = CandleData(
        timestamp: 1,
        open: null,
        close: 110,
        high: null,
        low: null,
        volume: 0,
      );
      final p = CandleData.buildPartial(noOpen, 0.5);
      expect(p, same(noOpen));
    });
  });
}
