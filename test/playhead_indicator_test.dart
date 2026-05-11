import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pipsend_charts/pipsend_charts.dart';

import 'test_helpers.dart';

/// In replay mode, indicators must compute over the FULL candle list
/// (so their cache and visual values stay stable as the playhead
/// moves) — not over the visible sublist.
///
/// We exercise this by feeding the SMA indicator the full series and
/// then asking it to compute over a sublist vs the full list. The
/// values for indices that overlap must match.
void main() {
  test('SMA values match between full data and sublist for common indices', () {
    final fullData = fakeCandles(count: 200);
    final sublist = fullData.sublist(0, 80);

    final smaFull = SMAIndicator(period: 14);
    final smaSub = SMAIndicator(period: 14);

    final fullValues = smaFull.calculate(fullData);
    final subValues = smaSub.calculate(sublist);

    // For each index in the sublist, the value should match.
    for (var i = 0; i < sublist.length; i++) {
      final a = fullValues[i].values['sma'];
      final b = subValues[i].values['sma'];
      if (a == null || b == null) {
        expect(a, isNull);
        expect(b, isNull);
      } else {
        expect(a, closeTo(b, 1e-6),
            reason: 'Mismatch at index $i: full=$a sub=$b');
      }
    }
  });

  testWidgets('chart with playhead + indicator does not crash',
      (tester) async {
    final candles = fakeCandles(count: 100);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 400,
            child: InteractiveChart(
              candles: candles,
              playheadIndex: 50,
              playheadStyle: const PlayheadStyle(),
              indicators: [SMAIndicator(period: 14)],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
