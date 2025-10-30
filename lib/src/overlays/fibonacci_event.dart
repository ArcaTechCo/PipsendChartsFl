import 'fibonacci_retracement.dart';

/// Types of events that can occur with Fibonacci retracements.
enum FibonacciEventType {
  added,
  removed,
  rangeChanged,
  visibilityChanged,
  styleChanged,
  updated,
  cleared,
}

/// Event data for Fibonacci retracement changes.
class FibonacciEvent {
  final FibonacciEventType type;
  final FibonacciRetracement? fibonacci;
  final String? fibonacciId;

  const FibonacciEvent({
    required this.type,
    this.fibonacci,
    this.fibonacciId,
  });

  factory FibonacciEvent.added(FibonacciRetracement fibonacci) {
    return FibonacciEvent(
      type: FibonacciEventType.added,
      fibonacci: fibonacci,
      fibonacciId: fibonacci.id,
    );
  }

  factory FibonacciEvent.removed(String fibonacciId) {
    return FibonacciEvent(
      type: FibonacciEventType.removed,
      fibonacciId: fibonacciId,
    );
  }

  factory FibonacciEvent.rangeChanged(FibonacciRetracement fibonacci) {
    return FibonacciEvent(
      type: FibonacciEventType.rangeChanged,
      fibonacci: fibonacci,
      fibonacciId: fibonacci.id,
    );
  }

  factory FibonacciEvent.visibilityChanged(FibonacciRetracement fibonacci) {
    return FibonacciEvent(
      type: FibonacciEventType.visibilityChanged,
      fibonacci: fibonacci,
      fibonacciId: fibonacci.id,
    );
  }

  factory FibonacciEvent.styleChanged(FibonacciRetracement fibonacci) {
    return FibonacciEvent(
      type: FibonacciEventType.styleChanged,
      fibonacci: fibonacci,
      fibonacciId: fibonacci.id,
    );
  }

  factory FibonacciEvent.updated(FibonacciRetracement fibonacci) {
    return FibonacciEvent(
      type: FibonacciEventType.updated,
      fibonacci: fibonacci,
      fibonacciId: fibonacci.id,
    );
  }

  factory FibonacciEvent.cleared() {
    return const FibonacciEvent(
      type: FibonacciEventType.cleared,
    );
  }
}

/// Callback type for Fibonacci retracement events.
typedef FibonacciListener = void Function(FibonacciEvent event);
