import 'dart:ui';
import 'package:flutter/widgets.dart';

import 'chart_style.dart';
import 'candle_data.dart';
import 'overlays/playhead_style.dart';
import 'overlays/drawing_placement.dart';

class PainterParams {
  static bool _volumeWarningShown = false;

  final List<CandleData> candles;

  /// The full, untrimmed list of candles. Used by indicators so their
  /// calculation cache stays stable across pan/zoom and across replay
  /// playhead moves. Null in legacy (non-replay) mode, in which case
  /// indicators fall back to [candles] (the visible sublist) for
  /// computation.
  final List<CandleData>? fullCandles;

  final ChartStyle style;
  final Size size;
  final double candleWidth;
  final double startOffset;

  final double maxPrice;
  final double minPrice;
  final double maxVol;
  final double minVol;

  final double xShift;
  final Offset? tapPosition;
  final bool showCrosshairInfoPanel;

  /// Id of the overlay currently selected by the host (tapped without a
  /// drag). The painter highlights the matching overlay. Null when nothing
  /// is selected.
  final String? selectedOverlayId;

  final DrawingPlacement? placement;
  final Offset? placementCursor;
  final List<PlacementPoint>? placementPoints;

  final List<double?>? leadingTrends;
  final List<double?>? trailingTrends;

  /// Index of the replay playhead in the visible candle list, or null
  /// when replay mode is off. Note this is the index inside [candles]
  /// (which is the sublist passed to the painter), not the absolute
  /// index in the host's full dataset.
  final int? playheadIndex;

  /// Sub-candle progress (0.0..1.0) for tick replay. Only meaningful
  /// when [playheadIndex] is non-null. Used by the tween to animate
  /// the partial candle smoothly between paint frames.
  final double? playheadTickProgress;

  /// Visual style for the playhead. When null, the playhead is not
  /// rendered by the chart painter (the host can still draw its own
  /// via overlays).
  final PlayheadStyle? playheadStyle;

  /// The price level at the tap position (null if not tapping).
  double? get tapPrice => tapPosition != null
      ? getPriceFromY(tapPosition!.dy)
      : null;

  PainterParams({
    required this.candles,
    required this.style,
    required this.size,
    required this.candleWidth,
    required this.startOffset,
    required this.maxPrice,
    required this.minPrice,
    required this.maxVol,
    required this.minVol,
    required this.xShift,
    required this.tapPosition,
    required this.leadingTrends,
    required this.trailingTrends,
    this.selectedOverlayId,
    this.showCrosshairInfoPanel = true,
    this.placement,
    this.placementCursor,
    this.placementPoints,
    this.fullCandles,
    this.playheadIndex,
    this.playheadTickProgress,
    this.playheadStyle,
  });

  double get chartWidth => // width without price labels
      size.width - style.priceLabelWidth;

  double get chartHeight => // height without time labels
      size.height - style.timeLabelHeight;

  double get volumeHeight => 
      style.showVolume ? chartHeight * style.volumeHeightFactor : 0.0;

  double get priceHeight => chartHeight - volumeHeight;

  int getCandleIndexFromOffset(double x) {
    final adjustedPos = x - xShift + candleWidth / 2;
    final i = adjustedPos ~/ candleWidth;
    return i;
  }

  double fitPrice(double y) =>
      priceHeight * (maxPrice - y) / (maxPrice - minPrice);

  /// Converts a timestamp to an X coordinate on the chart.
  ///
  /// Unlike `indexWhere`, this method handles timestamps that fall outside
  /// or between loaded candles by interpolating/extrapolating based on
  /// the average candle spacing.
  ///
  /// Returns `null` only if there are fewer than 2 candles loaded
  /// (not enough data to determine spacing).
  double? fitTimestamp(int timestamp) {
    if (candles.isEmpty) return null;

    // Exact match or first candle >= timestamp
    final idx = candles.indexWhere((c) => c.timestamp >= timestamp);

    if (idx >= 0) {
      final candle = candles[idx];
      if (candle.timestamp == timestamp) {
        return idx * candleWidth;
      }
      // timestamp is between candles[idx-1] and candles[idx]
      if (idx > 0) {
        final prev = candles[idx - 1];
        final next = candle;
        final t = (timestamp - prev.timestamp) /
            (next.timestamp - prev.timestamp);
        return (idx - 1 + t) * candleWidth;
      }
      // timestamp is before the first candle — extrapolate left
      if (candles.length < 2) return null;
      final avgSpacing =
          (candles.last.timestamp - candles.first.timestamp) /
              (candles.length - 1);
      if (avgSpacing <= 0) return 0;
      final candlesBack =
          (candles.first.timestamp - timestamp) / avgSpacing;
      return -candlesBack * candleWidth;
    }

    // idx == -1: timestamp is after the last candle — extrapolate right
    if (candles.length < 2) return null;
    final avgSpacing =
        (candles.last.timestamp - candles.first.timestamp) /
            (candles.length - 1);
    if (avgSpacing <= 0) return (candles.length - 1) * candleWidth;
    final candlesForward =
        (timestamp - candles.last.timestamp) / avgSpacing;
    return (candles.length - 1 + candlesForward) * candleWidth;
  }

  /// Converts an X coordinate to a timestamp, with extrapolation
  /// for positions beyond loaded candle data.
  ///
  /// Returns `null` only if there are fewer than 2 candles loaded.
  int? getTimestampFromX(double x) {
    if (candles.length < 2) return null;

    final avgSpacing =
        (candles.last.timestamp - candles.first.timestamp) /
            (candles.length - 1);

    // Convert X to a fractional candle index
    final fractionalIndex = x / candleWidth;

    // Within loaded range
    final floorIndex = fractionalIndex.floor();
    if (floorIndex >= 0 && floorIndex < candles.length - 1) {
      final t = fractionalIndex - floorIndex;
      return (candles[floorIndex].timestamp +
              (candles[floorIndex + 1].timestamp - candles[floorIndex].timestamp) * t)
          .round();
    }

    // Before first candle — extrapolate left
    if (floorIndex < 0) {
      return (candles.first.timestamp + fractionalIndex * avgSpacing).round();
    }

    // After last candle — extrapolate right
    return (candles.last.timestamp +
            (fractionalIndex - (candles.length - 1)) * avgSpacing)
        .round();
  }

  /// Get the price value from a Y coordinate on the chart.
  double getPriceFromY(double y) =>
      maxPrice - (y * (maxPrice - minPrice) / priceHeight);

  double fitVolume(double y) {
    final gap = 12; // the gap between price bars and volume bars
    final baseAmount = 2; // display at least "something" for the lowest volume

    if (maxVol == minVol) {
      // Apparently max and min values (in the current visible range, at least)
      // are the same. It's likely they passed in a bunch of zeroes, because
      // they don't have real volume data or don't want to draw volumes.
      assert(() {
        if (style.volumeHeightFactor != 0 && !_volumeWarningShown) {
          _volumeWarningShown = true;
          print('If you do not want to show volumes, '
              'make sure to set `volumeHeightFactor` (ChartStyle) to zero.');
        }
        return true;
      }());
      // Since they are equal, we just draw all volume bars as half height.
      return priceHeight + volumeHeight / 2;
    }

    final volGridSize = (volumeHeight - baseAmount - gap) / (maxVol - minVol);
    final vol = (y - minVol) * volGridSize;
    return volumeHeight - vol + priceHeight - baseAmount;
  }

  static PainterParams lerp(PainterParams a, PainterParams b, double t) {
    double lerpField(double getField(PainterParams p)) =>
        lerpDouble(getField(a), getField(b), t)!;
    // Tick progress lerps as a float when both sides have it. Index
    // does NOT lerp — it would create fractional indices that the
    // painter cannot use. When the index changes mid-animation we
    // simply snap to the new value.
    final double? tickProgress;
    if (a.playheadTickProgress != null &&
        b.playheadTickProgress != null &&
        a.playheadIndex == b.playheadIndex) {
      tickProgress = lerpDouble(
        a.playheadTickProgress!,
        b.playheadTickProgress!,
        t,
      );
    } else {
      tickProgress = b.playheadTickProgress;
    }
    return PainterParams(
      candles: b.candles,
      fullCandles: b.fullCandles,
      style: b.style,
      size: b.size,
      candleWidth: b.candleWidth,
      startOffset: b.startOffset,
      maxPrice: lerpField((p) => p.maxPrice),
      minPrice: lerpField((p) => p.minPrice),
      maxVol: lerpField((p) => p.maxVol),
      minVol: lerpField((p) => p.minVol),
      xShift: b.xShift,
      tapPosition: b.tapPosition,
      selectedOverlayId: b.selectedOverlayId,
      showCrosshairInfoPanel: b.showCrosshairInfoPanel,
      placement: b.placement,
      placementCursor: b.placementCursor,
      placementPoints: b.placementPoints,
      leadingTrends: b.leadingTrends,
      trailingTrends: b.trailingTrends,
      playheadIndex: b.playheadIndex,
      playheadTickProgress: tickProgress,
      playheadStyle: b.playheadStyle,
    );
  }

  bool shouldRepaint(PainterParams other) {
    if (candles.length != other.candles.length) return true;

    if (size != other.size ||
        candleWidth != other.candleWidth ||
        startOffset != other.startOffset ||
        xShift != other.xShift) return true;

    if (maxPrice != other.maxPrice ||
        minPrice != other.minPrice ||
        maxVol != other.maxVol ||
        minVol != other.minVol) return true;

    if (tapPosition != other.tapPosition) return true;

    if (selectedOverlayId != other.selectedOverlayId) return true;

    if (showCrosshairInfoPanel != other.showCrosshairInfoPanel) return true;

    if (placement != other.placement ||
        placementCursor != other.placementCursor ||
        placementPoints != other.placementPoints) return true;

    if (leadingTrends != other.leadingTrends ||
        trailingTrends != other.trailingTrends) return true;

    if (style != other.style) return true;

    if (playheadIndex != other.playheadIndex ||
        playheadTickProgress != other.playheadTickProgress ||
        playheadStyle != other.playheadStyle) return true;

    return false;
  }
}

class PainterParamsTween extends Tween<PainterParams> {
  PainterParamsTween({
    PainterParams? begin,
    required PainterParams end,
  }) : super(begin: begin, end: end);

  @override
  PainterParams lerp(double t) => PainterParams.lerp(begin ?? end!, end!, t);
}
