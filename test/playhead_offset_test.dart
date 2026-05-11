import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pipsend_charts/pipsend_charts.dart';

import 'test_helpers.dart';

/// Verifies that small playhead changes that keep the playhead inside
/// the visible window do NOT shift `_startOffset`, while larger jumps
/// that would put the playhead off-screen DO trigger a follow-pan
/// so the playhead stays visible (TradingView-style).
void main() {
  testWidgets('small playhead advance within visible range keeps offset stable',
      (tester) async {
    final candles = fakeCandles(count: 500);
    final notifiedOffsets = <double>[];

    Widget build(int playhead) => MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 400,
              child: InteractiveChart(
                candles: candles,
                initialVisibleCandleCount: 90,
                playheadIndex: playhead,
                playheadStyle: const PlayheadStyle(),
                onXOffsetChanged: (d) => notifiedOffsets.add(d.offset),
              ),
            ),
          ),
        );

    // Start with playhead near the right edge of the visible window.
    await tester.pumpWidget(build(400));
    await tester.pumpAndSettle();
    final initialOffset =
        notifiedOffsets.isNotEmpty ? notifiedOffsets.last : 0.0;
    notifiedOffsets.clear();

    // Advance by 1 — still inside the visible window. Offset must
    // not jump.
    await tester.pumpWidget(build(401));
    await tester.pumpAndSettle();

    for (final o in notifiedOffsets) {
      expect(o, closeTo(initialOffset, 0.001));
    }
  });

  testWidgets('large playhead jump out-of-view auto-pans to follow',
      (tester) async {
    final candles = fakeCandles(count: 500);
    int? lastNotifiedStart;
    int? lastNotifiedEnd;

    Widget build(int playhead) => MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 400,
              child: InteractiveChart(
                candles: candles,
                initialVisibleCandleCount: 30,
                playheadIndex: playhead,
                playheadStyle: const PlayheadStyle(),
                onXOffsetChanged: (d) {
                  lastNotifiedStart = d.startCandleIndex;
                  lastNotifiedEnd = d.endCandleIndex;
                },
              ),
            ),
          ),
        );

    await tester.pumpWidget(build(400));
    await tester.pumpAndSettle();

    // Big backwards scrub — playhead is now far from the previous
    // visible window. The chart must follow so the playhead stays
    // within [start, end).
    await tester.pumpWidget(build(50));
    await tester.pumpAndSettle();

    expect(lastNotifiedStart, isNotNull);
    expect(lastNotifiedEnd, isNotNull);
    expect(50, inInclusiveRange(lastNotifiedStart!, lastNotifiedEnd!));
  });

  testWidgets('effectiveLength caps onXOffsetChanged.totalCandles',
      (tester) async {
    final candles = fakeCandles(count: 1000);
    XAxisOffsetDetails? lastDetails;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 400,
            child: InteractiveChart(
              candles: candles,
              playheadIndex: 200,
              playheadStyle: const PlayheadStyle(),
              onXOffsetChanged: (d) => lastDetails = d,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(lastDetails, isNotNull);
    // The total reported should match the effective length (201), not
    // the raw candles.length (1000).
    expect(lastDetails!.totalCandles, equals(201));
  });
}
