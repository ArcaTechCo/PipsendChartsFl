import 'trend_line.dart';

/// Types of events that can occur with trend lines.
enum TrendLineEventType {
  added,
  removed,
  pointsChanged,
  visibilityChanged,
  styleChanged,
  updated,
  cleared,
}

/// Event data for trend line changes.
class TrendLineEvent {
  final TrendLineEventType type;
  final TrendLine? trendLine;
  final String? trendLineId;

  const TrendLineEvent({
    required this.type,
    this.trendLine,
    this.trendLineId,
  });

  factory TrendLineEvent.added(TrendLine trendLine) {
    return TrendLineEvent(
      type: TrendLineEventType.added,
      trendLine: trendLine,
      trendLineId: trendLine.id,
    );
  }

  factory TrendLineEvent.removed(String trendLineId) {
    return TrendLineEvent(
      type: TrendLineEventType.removed,
      trendLineId: trendLineId,
    );
  }

  factory TrendLineEvent.pointsChanged(TrendLine trendLine) {
    return TrendLineEvent(
      type: TrendLineEventType.pointsChanged,
      trendLine: trendLine,
      trendLineId: trendLine.id,
    );
  }

  factory TrendLineEvent.visibilityChanged(TrendLine trendLine) {
    return TrendLineEvent(
      type: TrendLineEventType.visibilityChanged,
      trendLine: trendLine,
      trendLineId: trendLine.id,
    );
  }

  factory TrendLineEvent.styleChanged(TrendLine trendLine) {
    return TrendLineEvent(
      type: TrendLineEventType.styleChanged,
      trendLine: trendLine,
      trendLineId: trendLine.id,
    );
  }

  factory TrendLineEvent.updated(TrendLine trendLine) {
    return TrendLineEvent(
      type: TrendLineEventType.updated,
      trendLine: trendLine,
      trendLineId: trendLine.id,
    );
  }

  factory TrendLineEvent.cleared() {
    return const TrendLineEvent(
      type: TrendLineEventType.cleared,
    );
  }
}

/// Callback type for trend line events.
typedef TrendLineListener = void Function(TrendLineEvent event);
