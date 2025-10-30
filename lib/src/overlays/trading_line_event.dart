import 'trading_line.dart';

/// Events that can occur in the TradingLineManager.
enum TradingLineEventType {
  /// A line was added to the manager.
  added,
  
  /// A line was removed from the manager.
  removed,
  
  /// A line's price was updated.
  priceChanged,
  
  /// A line's visibility was changed.
  visibilityChanged,
  
  /// A line's style was updated.
  styleChanged,
  
  /// A line was updated (generic update).
  updated,
  
  /// All lines were cleared.
  cleared,
}

/// An event that occurred in the TradingLineManager.
class TradingLineEvent {
  /// The type of event.
  final TradingLineEventType type;
  
  /// The line affected by the event (null for cleared event).
  final TradingLine? line;
  
  /// The old value before the change (for updates).
  final dynamic oldValue;
  
  /// The new value after the change (for updates).
  final dynamic newValue;
  
  const TradingLineEvent({
    required this.type,
    this.line,
    this.oldValue,
    this.newValue,
  });
  
  /// Creates an added event.
  factory TradingLineEvent.added(TradingLine line) {
    return TradingLineEvent(
      type: TradingLineEventType.added,
      line: line,
    );
  }
  
  /// Creates a removed event.
  factory TradingLineEvent.removed(TradingLine line) {
    return TradingLineEvent(
      type: TradingLineEventType.removed,
      line: line,
    );
  }
  
  /// Creates a price changed event.
  factory TradingLineEvent.priceChanged(
    TradingLine line,
    double oldPrice,
    double newPrice,
  ) {
    return TradingLineEvent(
      type: TradingLineEventType.priceChanged,
      line: line,
      oldValue: oldPrice,
      newValue: newPrice,
    );
  }
  
  /// Creates a visibility changed event.
  factory TradingLineEvent.visibilityChanged(
    TradingLine line,
    bool oldVisibility,
    bool newVisibility,
  ) {
    return TradingLineEvent(
      type: TradingLineEventType.visibilityChanged,
      line: line,
      oldValue: oldVisibility,
      newValue: newVisibility,
    );
  }
  
  /// Creates a style changed event.
  factory TradingLineEvent.styleChanged(TradingLine line) {
    return TradingLineEvent(
      type: TradingLineEventType.styleChanged,
      line: line,
    );
  }
  
  /// Creates an updated event.
  factory TradingLineEvent.updated(TradingLine line) {
    return TradingLineEvent(
      type: TradingLineEventType.updated,
      line: line,
    );
  }
  
  /// Creates a cleared event.
  factory TradingLineEvent.cleared() {
    return const TradingLineEvent(
      type: TradingLineEventType.cleared,
    );
  }
  
  @override
  String toString() {
    return 'TradingLineEvent(type: $type, line: ${line?.id})';
  }
}

/// Listener for trading line events.
typedef TradingLineListener = void Function(TradingLineEvent event);
