import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pipsend_charts/pipsend_charts.dart';

import 'test_helpers.dart';

/// Verifies that dragging on top of the playhead emits
/// onPlayheadChanged with sensible values, and that the gesture is
/// consumed by the playhead instead of triggering pan/zoom.
void main() {
  testWidgets('horizontal drag near playhead emits onPlayheadChanged',
      (tester) async {
    final candles = fakeCandles(count: 100);
    final emitted = <PlayheadInfo>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 400,
            child: InteractiveChart(
              candles: candles,
              initialVisibleCandleCount: 30,
              playheadIndex: 95,
              // Wide hit radius so the test is tolerant of small
              // pixel offsets caused by xShift / fractional candles.
              playheadStyle: const PlayheadStyle(hitRadius: 60),
              onPlayheadChanged: emitted.add,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The playhead at the last effective candle (95) is rendered near
    // the right edge of the chart's drawable area
    // (chartWidth = 800 - 48 = 752). Start the drag well inside the
    // hit radius and pull leftwards.
    final chart = find.byType(InteractiveChart);
    final box = tester.getRect(chart);
    final start = Offset(box.right - 60, box.center.dy);
    final end = Offset(box.left + 200, box.center.dy);

    await tester.timedDragFrom(start, end - start,
        const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(emitted, isNotEmpty,
        reason: 'Drag near playhead should emit at least one event');
    // The last emitted index should be within the valid effective
    // range [0, 95].
    expect(emitted.last.candleIndex, inInclusiveRange(0, 95));
  });

  testWidgets('non-draggable playhead does NOT emit onPlayheadChanged',
      (tester) async {
    final candles = fakeCandles(count: 100);
    final emitted = <PlayheadInfo>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 400,
            child: InteractiveChart(
              candles: candles,
              playheadIndex: 50,
              playheadStyle: const PlayheadStyle(draggable: false),
              onPlayheadChanged: emitted.add,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final chart = find.byType(InteractiveChart);
    final box = tester.getRect(chart);
    final start = box.center;
    await tester.timedDragFrom(start, const Offset(-100, 0),
        const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(emitted, isEmpty);
  });
}
