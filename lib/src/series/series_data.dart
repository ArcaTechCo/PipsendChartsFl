import 'package:flutter/painting.dart';

/// Base class for series data points.
abstract class SeriesData {
  /// Timestamp in milliseconds since epoch.
  final int timestamp;

  const SeriesData({required this.timestamp});
}

/// Data point for a line series.
class LineData extends SeriesData {
  /// The value at this point.
  final double? value;

  const LineData({
    required int timestamp,
    required this.value,
  }) : super(timestamp: timestamp);

  @override
  String toString() => 'LineData(timestamp: $timestamp, value: $value)';
}

/// Data point for an area series.
class AreaData extends SeriesData {
  /// The value at this point.
  final double? value;

  const AreaData({
    required int timestamp,
    required this.value,
  }) : super(timestamp: timestamp);

  @override
  String toString() => 'AreaData(timestamp: $timestamp, value: $value)';
}

/// Data point for a histogram series.
class HistogramData extends SeriesData {
  /// The value (height) of this bar.
  final double? value;

  /// Optional color for this specific bar.
  /// If null, uses the series default color.
  final Color? color;

  const HistogramData({
    required int timestamp,
    required this.value,
    this.color,
  }) : super(timestamp: timestamp);

  @override
  String toString() => 'HistogramData(timestamp: $timestamp, value: $value)';
}

/// Data point for a bar chart (OHLC).
class BarData extends SeriesData {
  final double? open;
  final double? high;
  final double? low;
  final double? close;

  const BarData({
    required int timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  }) : super(timestamp: timestamp);

  @override
  String toString() => 'BarData(timestamp: $timestamp, O: $open, H: $high, L: $low, C: $close)';
}
