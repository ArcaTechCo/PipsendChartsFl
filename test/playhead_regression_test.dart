import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pipsend_charts/pipsend_charts.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('without playhead props, chart renders all candles', (tester) async {
    final candles = fakeCandles(count: 50);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 400,
            child: InteractiveChart(candles: candles),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(InteractiveChart), findsOneWidget);
  });

  testWidgets('chart with playheadIndex still renders', (tester) async {
    final candles = fakeCandles(count: 100);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 400,
            child: InteractiveChart(
              candles: candles,
              playheadIndex: 60,
              playheadStyle: const PlayheadStyle(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(InteractiveChart), findsOneWidget);
  });

  testWidgets('playhead index at last valid position is accepted',
      (tester) async {
    final candles = fakeCandles(count: 20);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 400,
            child: InteractiveChart(
              candles: candles,
              playheadIndex: 19,
              playheadStyle: const PlayheadStyle(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  test('asserts reject out-of-range playhead index', () {
    final candles = fakeCandles(count: 10);
    expect(
      () => InteractiveChart(candles: candles, playheadIndex: 10),
      throwsAssertionError,
    );
    expect(
      () => InteractiveChart(candles: candles, playheadIndex: -1),
      throwsAssertionError,
    );
  });

  test('asserts reject invalid tick progress', () {
    final candles = fakeCandles(count: 10);
    expect(
      () => InteractiveChart(
        candles: candles,
        playheadIndex: 5,
        playheadTickProgress: -0.1,
      ),
      throwsAssertionError,
    );
    expect(
      () => InteractiveChart(
        candles: candles,
        playheadIndex: 5,
        playheadTickProgress: 1.5,
      ),
      throwsAssertionError,
    );
  });
}
