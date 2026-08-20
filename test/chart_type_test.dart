import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pipsend_charts/pipsend_charts.dart';

import 'test_helpers.dart';

void main() {
  group('CandleData.toHeikinAshi', () {
    test('seeds the first candle from its own open/close', () {
      final data = [
        CandleData(
          timestamp: 0,
          open: 10,
          high: 14,
          low: 8,
          close: 12,
          volume: 100,
        ),
      ];

      final ha = CandleData.toHeikinAshi(data);

      expect(ha, hasLength(1));
      expect(ha.first.close, (10 + 14 + 8 + 12) / 4);
      expect(ha.first.open, (10 + 12) / 2);
      expect(ha.first.high, 14);
      expect(ha.first.low, 8);
    });

    test('derives the open from the previous Heikin Ashi candle', () {
      final data = [
        CandleData(
            timestamp: 0, open: 10, high: 14, low: 8, close: 12, volume: 1),
        CandleData(
            timestamp: 1, open: 12, high: 18, low: 11, close: 17, volume: 1),
      ];

      final ha = CandleData.toHeikinAshi(data);

      final firstOpen = (10 + 12) / 2;
      final firstClose = (10 + 14 + 8 + 12) / 4;
      final secondClose = (12 + 18 + 11 + 17) / 4;
      final secondOpen = (firstOpen + firstClose) / 2;

      expect(ha[1].open, secondOpen);
      expect(ha[1].close, secondClose);
      // High/low always contain the Heikin Ashi body.
      expect(ha[1].high, 18);
      expect(ha[1].low, 11);
    });

    test('keeps the result stable regardless of how much history precedes it',
        () {
      final full = fakeCandles(count: 120);
      final ha = CandleData.toHeikinAshi(full);

      // Re-running over the same series must be deterministic.
      final again = CandleData.toHeikinAshi(full);
      for (var i = 0; i < full.length; i++) {
        expect(again[i].open, ha[i].open);
        expect(again[i].close, ha[i].close);
      }
    });

    test('passes gaps through untouched and restarts the recursion', () {
      final data = [
        CandleData(
            timestamp: 0, open: 10, high: 14, low: 8, close: 12, volume: 1),
        CandleData(
            timestamp: 1, open: null, high: null, low: null, close: null,
            volume: null),
        CandleData(
            timestamp: 2, open: 20, high: 22, low: 19, close: 21, volume: 1),
      ];

      final ha = CandleData.toHeikinAshi(data);

      expect(ha[1].open, isNull);
      expect(ha[1].close, isNull);
      // The candle after the gap is seeded from itself, not from before it.
      expect(ha[2].open, (20 + 21) / 2);
    });

    test('preserves timestamps and volume', () {
      final source = fakeCandles(count: 30);
      final ha = CandleData.toHeikinAshi(source);

      for (var i = 0; i < source.length; i++) {
        expect(ha[i].timestamp, source[i].timestamp);
        expect(ha[i].volume, source[i].volume);
      }
    });

    test('returns an empty list for empty input', () {
      expect(CandleData.toHeikinAshi(const []), isEmpty);
    });
  });

  group('Heikin Ashi reaches the chart end-to-end', () {
    testWidgets('the candle reported on tap is the Heikin Ashi one', (tester) async {
      final raw = fakeCandles(count: 60);
      final expected = CandleData.toHeikinAshi(raw);
      TapDetails? tapped;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 300,
            child: InteractiveChart(
              candles: raw,
              style: const ChartStyle(chartType: ChartType.heikinAshi),
              onTap: (d) => tapped = d,
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tapAt(tester.getCenter(find.byType(InteractiveChart)));
      await tester.pumpAndSettle();

      expect(tapped, isNotNull);
      final candle = tapped!.candle!;

      // It must be one of the Heikin Ashi candles, matched by timestamp...
      final match = expected.firstWhere((c) => c.timestamp == candle.timestamp);
      expect(candle.open, match.open);
      expect(candle.close, match.close);

      // ...and it must NOT be the raw candle at the same timestamp.
      final rawMatch = raw.firstWhere((c) => c.timestamp == candle.timestamp);
      expect(candle.open, isNot(rawMatch.open));
    });

    testWidgets('regular candlesticks still report the raw candle', (tester) async {
      final raw = fakeCandles(count: 60);
      TapDetails? tapped;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 300,
            child: InteractiveChart(
              candles: raw,
              style: const ChartStyle(chartType: ChartType.candlestick),
              onTap: (d) => tapped = d,
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tapAt(tester.getCenter(find.byType(InteractiveChart)));
      await tester.pumpAndSettle();

      final candle = tapped!.candle!;
      final rawMatch = raw.firstWhere((c) => c.timestamp == candle.timestamp);
      expect(candle.open, rawMatch.open);
    });
  });

  group('Heikin Ashi invariants hold on the produced series', () {
    test('every open is the midpoint of the previous body (no gaps)', () {
      final ha = CandleData.toHeikinAshi(fakeCandles(count: 200));

      for (var i = 1; i < ha.length; i++) {
        final expectedOpen = (ha[i - 1].open! + ha[i - 1].close!) / 2;
        expect(ha[i].open, closeTo(expectedOpen, 1e-9),
            reason: 'candle $i does not open at the previous body midpoint');

        // Consequence: the open always sits inside the previous body.
        final bodyTop = ha[i - 1].open! > ha[i - 1].close!
            ? ha[i - 1].open!
            : ha[i - 1].close!;
        final bodyBottom = ha[i - 1].open! < ha[i - 1].close!
            ? ha[i - 1].open!
            : ha[i - 1].close!;
        expect(ha[i].open!, inInclusiveRange(bodyBottom, bodyTop));
      }
    });

    test('high and low always contain the body', () {
      final ha = CandleData.toHeikinAshi(fakeCandles(count: 200));

      for (final c in ha) {
        expect(c.high! >= c.open! && c.high! >= c.close!, isTrue);
        expect(c.low! <= c.open! && c.low! <= c.close!, isTrue);
      }
    });
  });

  group('ChartType rendering', () {
    for (final type in ChartType.values) {
      testWidgets('renders $type without throwing', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: InteractiveChart(
                candles: fakeCandles(count: 120),
                style: ChartStyle(chartType: type),
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(InteractiveChart), findsOneWidget);
      });
    }
  });
}
