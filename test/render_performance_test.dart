import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pipsend_charts/pipsend_charts.dart';
import 'package:pipsend_charts/src/chart_painter.dart';
import 'package:pipsend_charts/src/common/text_layout_cache.dart';
import 'package:pipsend_charts/src/painter_params.dart';

import 'test_helpers.dart';

PainterParams _params({
  required List<CandleData> candles,
  ChartStyle style = const ChartStyle(),
  TextLayoutCache? cache,
  double maxPrice = 110,
  double minPrice = 90,
  Offset? tapPosition,
  PlayheadStyle? playheadStyle,
}) {
  return PainterParams(
    candles: candles,
    style: style,
    size: const Size(400, 300),
    candleWidth: 10,
    startOffset: 0,
    maxPrice: maxPrice,
    minPrice: minPrice,
    maxVol: 1000,
    minVol: 0,
    xShift: 5,
    tapPosition: tapPosition,
    leadingTrends: null,
    trailingTrends: null,
    playheadStyle: playheadStyle,
    textLayoutCache: cache,
  );
}

ChartPainter _painter(
  PainterParams params, {
  List<ChartOverlay> overlays = const [],
  List<Indicator> indicators = const [],
  PriceLabelGetter? priceLabel,
}) {
  return ChartPainter(
    params: params,
    getTimeLabel: (_, __) => '',
    getPriceLabel: priceLabel ?? (_) => '',
    getOverlayInfo: (_) => const {},
    getCrosshairTimeLabel: (_) => '',
    overlays: overlays,
    indicators: indicators,
  );
}

void _paint(ChartOverlay overlay, PainterParams params) {
  final recorder = ui.PictureRecorder();
  overlay.paint(ui.Canvas(recorder), params);
  recorder.endRecording().dispose();
}

TradingLine _line(
  double price, {
  String title = 'BUY 0.10 +12.50',
  TradingLineOptions? options,
}) {
  return TradingLine(
    id: 'line_$price',
    price: price,
    type: TradingLineType.entry,
    style: const TradingLineStyle(color: Color(0xFF2196F3)),
    options: options ?? TradingLineOptions(title: title, draggable: true),
  );
}

const _labelStyle = TextStyle(
  color: Color(0xFF2196F3),
  fontSize: 10,
  fontWeight: FontWeight.bold,
);

class _CountingOverlay extends ChartOverlay {
  int paints = 0;

  _CountingOverlay(String id) : super(id: id);

  @override
  void paint(Canvas canvas, PainterParams params, {bool isBeingDragged = false}) {
    paints++;
  }
}

void main() {
  group('TextLayoutCache', () {
    test('reuses the laid-out painter for the same text and style', () {
      final cache = TextLayoutCache();

      final first = cache.layout('SL 1.2345', const TextStyle(fontSize: 10));
      final second = cache.layout(
        'SL 1.2345',
        TextStyle(fontSize: 10.0, color: null, fontWeight: null),
      );

      expect(identical(first, second), isTrue);
      expect(cache.length, 1);
      expect(first.width, greaterThan(0));
      cache.dispose();
    });

    test('separates entries by text and by every style field', () {
      final cache = TextLayoutCache();

      final base = cache.layout('TP', const TextStyle(fontSize: 10));
      final otherText = cache.layout('TP2', const TextStyle(fontSize: 10));
      final otherSize = cache.layout('TP', const TextStyle(fontSize: 11));
      final otherColor = cache.layout(
          'TP', const TextStyle(fontSize: 10, color: Color(0xFFFF0000)));
      final otherWeight = cache.layout(
          'TP', const TextStyle(fontSize: 10, fontWeight: FontWeight.bold));
      final otherFamily =
          cache.layout('TP', const TextStyle(fontSize: 10, fontFamily: 'Mono'));
      final otherSpacing =
          cache.layout('TP', const TextStyle(fontSize: 10, letterSpacing: 1));

      final all = {
        base,
        otherText,
        otherSize,
        otherColor,
        otherWeight,
        otherFamily,
        otherSpacing,
      };
      expect(all, hasLength(7));
      expect(cache.length, 7);
      cache.dispose();
    });

    test('endFrame evicts and disposes entries unused during the frame', () {
      final cache = TextLayoutCache();

      final kept = cache.layout('A', const TextStyle(fontSize: 10));
      final dropped = cache.layout('B', const TextStyle(fontSize: 10));
      cache.endFrame();
      expect(cache.length, 2);

      expect(identical(cache.layout('A', const TextStyle(fontSize: 10)), kept),
          isTrue);
      cache.endFrame();

      expect(cache.length, 1);
      expect(dropped.debugDisposed, isTrue);
      expect(kept.debugDisposed, isFalse);
      cache.dispose();
    });

    test('evicts and disposes the least recently used entry past the cap', () {
      final cache = TextLayoutCache(maxEntries: 2);

      final a = cache.layout('A', const TextStyle(fontSize: 10));
      final b = cache.layout('B', const TextStyle(fontSize: 10));
      cache.layout('A', const TextStyle(fontSize: 10));
      final c = cache.layout('C', const TextStyle(fontSize: 10));

      expect(cache.length, 2);
      expect(b.debugDisposed, isTrue);
      expect(a.debugDisposed, isFalse);
      expect(c.debugDisposed, isFalse);
      cache.dispose();
    });

    test('dispose releases every cached painter', () {
      final cache = TextLayoutCache();
      final a = cache.layout('A', const TextStyle(fontSize: 10));
      final b = cache.layout('B', const TextStyle(fontSize: 10));

      cache.dispose();

      expect(cache.length, 0);
      expect(a.debugDisposed, isTrue);
      expect(b.debugDisposed, isTrue);
    });
  });

  group('TradingLine painting', () {
    final candles = fakeCandles(count: 40);

    test('lays out title and price through the shared cache', () {
      final cache = TextLayoutCache();
      final params = _params(candles: candles, cache: cache);

      _paint(_line(100), params);
      expect(cache.length, 2);

      _paint(_line(100), params);
      expect(cache.length, 2);

      cache.layout('BUY 0.10 +12.50', _labelStyle);
      expect(cache.length, 2);
      cache.dispose();
    });

    test('keeps the dragged variant separate from the resting one', () {
      final cache = TextLayoutCache();
      final params = _params(candles: candles, cache: cache);
      final line = _line(100);

      _paint(line, params);
      final recorder = ui.PictureRecorder();
      line.paint(ui.Canvas(recorder), params, isBeingDragged: true);
      recorder.endRecording().dispose();

      expect(cache.length, 4);
      cache.layout('BUY 0.10 +12.50', _labelStyle.copyWith(fontSize: 11));
      expect(cache.length, 4);
      cache.dispose();
    });

    test('hit testing reuses the painted label layout', () {
      final cache = TextLayoutCache();
      final params = _params(candles: candles, cache: cache);
      final line = _line(100);

      _paint(line, params);
      final y = params.fitPrice(100);

      expect(line.hitTest(Offset(20, y - 8), params), isTrue);
      expect(cache.length, 2);
      cache.dispose();
    });

    test('hit testing rejects distant lines without laying out text', () {
      final cache = TextLayoutCache();
      final params = _params(candles: candles, cache: cache);
      final line = _line(100);
      final y = params.fitPrice(100);

      expect(line.hitTest(Offset(20, y + 40), params), isFalse);
      expect(line.hitTest(Offset(20, y - 200), params), isFalse);
      expect(cache.length, 0);
      cache.dispose();
    });

    test('skips lines priced far outside the visible range', () {
      final cache = TextLayoutCache();
      final params = _params(candles: candles, cache: cache);

      _paint(_line(200), params);
      _paint(_line(-50), params);

      expect(cache.length, 0);
      cache.dispose();
    });

    test('still paints lines whose labels can peek into view', () {
      final cache = TextLayoutCache();
      final params = _params(candles: candles, cache: cache);
      final priceJustAbove = params.getPriceFromY(-6);

      _paint(_line(priceJustAbove), params);

      expect(cache.length, 2);
      cache.dispose();
    });

    test('keeps a fixed custom label when the line is off-screen', () {
      final cache = TextLayoutCache();
      final params = _params(candles: candles, cache: cache);

      _paint(
        _line(
          200,
          options: const TradingLineOptions(
            title: 'Pinned',
            labelPosition: LabelPosition.custom,
            customLabelOffset: Offset(10, 10),
          ),
        ),
        params,
      );

      expect(cache.length, 1);
      cache.dispose();
    });
  });

  group('ChartPainter.shouldRepaint', () {
    final candles = fakeCandles(count: 40);
    final lineA = _line(100);
    final lineB = _line(102);

    test('is false for an equal style and the same overlay instances', () {
      final before = _painter(
        _params(
          candles: List.of(candles),
          style: ChartStyle(
            priceGainColor: const Color(0xFF00FF00),
            gridStyle: GridStyle(horizontalGridColor: const Color(0x11111111)),
            priceLabelStyle: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          playheadStyle: PlayheadStyle(dashPattern: [5, 4]),
        ),
        overlays: [lineA, lineB],
      );
      final after = _painter(
        _params(
          candles: List.of(candles),
          style: ChartStyle(
            priceGainColor: const Color(0xFF00FF00),
            gridStyle: GridStyle(horizontalGridColor: const Color(0x11111111)),
            priceLabelStyle: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          playheadStyle: PlayheadStyle(dashPattern: [5, 4]),
        ),
        overlays: [lineA, lineB],
      );

      expect(after.shouldRepaint(before), isFalse);
    });

    test('is true when one overlay is a new instance', () {
      final before =
          _painter(_params(candles: candles), overlays: [lineA, lineB]);
      final after = _painter(
        _params(candles: candles),
        overlays: [lineA, lineB.copyWith()],
      );

      expect(after.shouldRepaint(before), isTrue);
    });

    test('is true when an overlay is added or removed', () {
      final before = _painter(_params(candles: candles), overlays: [lineA]);
      final after =
          _painter(_params(candles: candles), overlays: [lineA, lineB]);

      expect(after.shouldRepaint(before), isTrue);
      expect(before.shouldRepaint(after), isTrue);
    });

    test('is true when the style changes', () {
      final before = _painter(
        _params(candles: candles, style: const ChartStyle()),
        overlays: [lineA],
      );
      final after = _painter(
        _params(
          candles: candles,
          style: const ChartStyle(priceGainColor: Color(0xFF00FF00)),
        ),
        overlays: [lineA],
      );

      expect(after.shouldRepaint(before), isTrue);
    });

    test('compares label getters by their output', () {
      final params = _params(candles: candles);
      final before = _painter(
        params,
        overlays: [lineA],
        priceLabel: (price) => price.toStringAsFixed(2),
      );
      final sameOutput = _painter(
        params,
        overlays: [lineA],
        priceLabel: (price) => price.toStringAsFixed(2),
      );
      final moreDigits = _painter(
        params,
        overlays: [lineA],
        priceLabel: (price) => price.toStringAsFixed(5),
      );

      expect(sameOutput.shouldRepaint(before), isFalse);
      expect(moreDigits.shouldRepaint(before), isTrue);
    });

    test('is true when a visible candle is replaced', () {
      final ticked = List.of(candles);
      final last = ticked.last;
      ticked[ticked.length - 1] = CandleData(
        timestamp: last.timestamp,
        open: last.open,
        high: last.high,
        low: last.low,
        close: last.close! + 0.0001,
        volume: last.volume,
      );

      final before = _painter(_params(candles: candles), overlays: [lineA]);
      final after = _painter(_params(candles: ticked), overlays: [lineA]);

      expect(after.shouldRepaint(before), isTrue);
    });
  });

  group('tween target', () {
    final candles = fakeCandles(count: 40);

    test('ignores fields that are not interpolated', () {
      final a = _params(candles: candles);
      final b = _params(
        candles: List.of(candles),
        tapPosition: const Offset(10, 10),
        style: const ChartStyle(priceGainColor: Color(0xFF00FF00)),
      );

      expect(a.animatedValues, b.animatedValues);
      expect(a.animatedValues.hashCode, b.animatedValues.hashCode);
    });

    test('differs when an interpolated value changes', () {
      final a = _params(candles: candles);
      final b = _params(candles: candles, maxPrice: 111);

      expect(a.animatedValues == b.animatedValues, isFalse);
    });

    test('applies interpolated values on top of the latest params', () {
      final cache = TextLayoutCache();
      final latest = _params(candles: candles, cache: cache);

      expect(
          identical(latest.withAnimatedValues(latest.animatedValues), latest),
          isTrue);

      final mid = latest.withAnimatedValues(AnimatedPainterValues.lerp(
        _params(candles: candles, maxPrice: 120).animatedValues,
        latest.animatedValues,
        0.5,
      ));
      expect(mid.maxPrice, 115);
      expect(mid.minPrice, 90);
      expect(identical(mid.candles, latest.candles), isTrue);
      expect(identical(mid.textLayoutCache, cache), isTrue);
      cache.dispose();
    });
  });

  group('InteractiveChart rebuilds', () {
    final candles = fakeCandles(count: 120);

    Widget chart({
      required List<CandleData> data,
      required List<ChartOverlay> overlays,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 400,
            child: InteractiveChart(
              candles: data,
              style: ChartStyle(
                priceGainColor: const Color(0xFF00FF00),
                priceLabelStyle: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              overlays: [...overlays],
            ),
          ),
        ),
      );
    }

    testWidgets('an equal rebuild neither animates nor repaints',
        (tester) async {
      final overlay = _CountingOverlay('counter');

      await tester.pumpWidget(chart(data: candles, overlays: [overlay]));
      await tester.pumpAndSettle();
      final paintsBefore = overlay.paints;
      expect(paintsBefore, greaterThan(0));

      await tester.pumpWidget(chart(data: candles, overlays: [overlay]));
      final pumps = await tester.pumpAndSettle();

      expect(pumps, 1);
      expect(overlay.paints, paintsBefore);
    });

    testWidgets('a new overlay instance repaints without animating',
        (tester) async {
      final first = _CountingOverlay('counter');
      await tester.pumpWidget(chart(data: candles, overlays: [first]));
      await tester.pumpAndSettle();

      final second = _CountingOverlay('counter');
      await tester.pumpWidget(chart(data: candles, overlays: [second]));
      final pumps = await tester.pumpAndSettle();

      expect(pumps, 1);
      expect(second.paints, 1);
    });

    testWidgets('a price range change still animates', (tester) async {
      final overlay = _CountingOverlay('counter');
      await tester.pumpWidget(chart(data: candles, overlays: [overlay]));
      await tester.pumpAndSettle();

      final shifted = fakeCandles(count: 120, base: 140);
      await tester.pumpWidget(chart(data: shifted, overlays: [overlay]));
      final pumps = await tester.pumpAndSettle();

      expect(pumps, greaterThan(1));
    });
  });
}
