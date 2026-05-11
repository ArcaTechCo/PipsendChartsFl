import 'package:flutter/painting.dart';

/// Visual configuration for the built-in replay playhead.
///
/// When [InteractiveChart.playheadStyle] is non-null and
/// [InteractiveChart.playheadIndex] is set, the chart renders a vertical
/// line at the playhead position, optionally with a date label and a
/// dimmed region to the right (used to visually "hide" the future).
///
/// The playhead is drawn by the chart's painter, not as an overlay, so
/// it always appears on top of overlays and indicators.
class PlayheadStyle {
  /// Color of the playhead vertical line.
  final Color lineColor;

  /// Stroke width of the playhead line in logical pixels.
  final double lineWidth;

  /// Optional dash pattern (e.g. `[6, 4]`). When null the line is solid.
  final List<double>? dashPattern;

  /// Whether to display a label with the playhead's timestamp.
  final bool showLabel;

  /// Text style for the label. If null, a sensible default is used.
  final TextStyle? labelStyle;

  /// Background color for the label box.
  final Color labelBackground;

  /// Horizontal padding inside the label box.
  final double labelHorizontalPadding;

  /// Vertical padding inside the label box.
  final double labelVerticalPadding;

  /// Whether the playhead can be dragged horizontally with a finger or
  /// pointer. When true, drag gestures within [hitRadius] of the
  /// playhead line are consumed by the playhead instead of triggering
  /// pan/zoom.
  final bool draggable;

  /// Half-width (in logical pixels) of the invisible hit area used to
  /// detect drag-starts on the playhead. Defaults to 12 — small enough
  /// to avoid accidental captures, large enough to be touch-friendly.
  final double hitRadius;

  /// If true, the area to the right of the playhead is painted with a
  /// translucent overlay to communicate that the future is hidden.
  final bool dimRightSide;

  /// Color of the dim overlay. Alpha is taken from this color combined
  /// with [dimOpacity].
  final Color dimColor;

  /// Opacity (0.0–1.0) applied to the dim overlay on top of [dimColor].
  final double dimOpacity;

  /// Whether to draw small grab handles on top of the line when
  /// [draggable] is true (improves discoverability).
  final bool showDragHandles;

  /// Radius (in logical pixels) of the diamond grab handle drawn on
  /// the playhead. Only used when [showDragHandles] is true. The
  /// default is finger-friendly without overpowering the chart.
  final double handleSize;

  const PlayheadStyle({
    this.lineColor = const Color(0xFF3B82F6),
    this.lineWidth = 1.5,
    this.dashPattern,
    this.showLabel = true,
    this.labelStyle,
    this.labelBackground = const Color(0xFF3B82F6),
    this.labelHorizontalPadding = 6,
    this.labelVerticalPadding = 3,
    this.draggable = true,
    this.hitRadius = 12,
    this.dimRightSide = true,
    this.dimColor = const Color(0xFF000000),
    this.dimOpacity = 0.25,
    this.showDragHandles = true,
    this.handleSize = 8,
  })  : assert(lineWidth > 0),
        assert(hitRadius >= 0),
        assert(handleSize > 0),
        assert(dimOpacity >= 0 && dimOpacity <= 1);

  PlayheadStyle copyWith({
    Color? lineColor,
    double? lineWidth,
    List<double>? dashPattern,
    bool? showLabel,
    TextStyle? labelStyle,
    Color? labelBackground,
    double? labelHorizontalPadding,
    double? labelVerticalPadding,
    bool? draggable,
    double? hitRadius,
    bool? dimRightSide,
    Color? dimColor,
    double? dimOpacity,
    bool? showDragHandles,
    double? handleSize,
  }) {
    return PlayheadStyle(
      lineColor: lineColor ?? this.lineColor,
      lineWidth: lineWidth ?? this.lineWidth,
      dashPattern: dashPattern ?? this.dashPattern,
      showLabel: showLabel ?? this.showLabel,
      labelStyle: labelStyle ?? this.labelStyle,
      labelBackground: labelBackground ?? this.labelBackground,
      labelHorizontalPadding:
          labelHorizontalPadding ?? this.labelHorizontalPadding,
      labelVerticalPadding:
          labelVerticalPadding ?? this.labelVerticalPadding,
      draggable: draggable ?? this.draggable,
      hitRadius: hitRadius ?? this.hitRadius,
      dimRightSide: dimRightSide ?? this.dimRightSide,
      dimColor: dimColor ?? this.dimColor,
      dimOpacity: dimOpacity ?? this.dimOpacity,
      showDragHandles: showDragHandles ?? this.showDragHandles,
      handleSize: handleSize ?? this.handleSize,
    );
  }
}
