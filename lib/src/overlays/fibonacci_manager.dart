import 'fibonacci_retracement.dart';
import 'fibonacci_event.dart';

/// Manages a collection of Fibonacci retracements.
///
/// Provides methods to add, remove, update, and query Fibonacci retracements.
///
/// Example:
/// ```dart
/// final manager = FibonacciManager();
///
/// // Add Fibonacci
/// final fibId = manager.addFibonacci(FibonacciRetracement(
///   highPrice: 150.0,
///   lowPrice: 100.0,
/// ));
///
/// // Update range
/// manager.updateFibonacciRange(fibId, 160.0, 110.0);
///
/// // Remove Fibonacci
/// manager.removeFibonacci(fibId);
///
/// // Get all Fibonaccis
/// final allFibs = manager.fibonaccis;
/// ```
class FibonacciManager {
  final List<FibonacciRetracement> _fibonaccis = [];
  final List<FibonacciListener> _listeners = [];

  // ============================================================================
  // Event Listeners
  // ============================================================================
  
  /// Adds a listener that will be called when Fibonaccis change.
  void addListener(FibonacciListener listener) {
    _listeners.add(listener);
  }
  
  /// Removes a previously added listener.
  void removeListener(FibonacciListener listener) {
    _listeners.remove(listener);
  }
  
  /// Removes all listeners.
  void clearListeners() {
    _listeners.clear();
  }
  
  /// Notifies all listeners of an event.
  void _notifyListeners(FibonacciEvent event) {
    for (final listener in _listeners) {
      listener(event);
    }
  }

  // ============================================================================
  // Add/Remove Operations
  // ============================================================================
  
  /// Adds a Fibonacci retracement to the manager.
  ///
  /// Returns the ID of the added Fibonacci.
  String addFibonacci(FibonacciRetracement fibonacci) {
    _fibonaccis.add(fibonacci);
    _notifyListeners(FibonacciEvent.added(fibonacci));
    return fibonacci.id;
  }

  /// Adds multiple Fibonacci retracements at once.
  ///
  /// Returns a list of IDs for the added Fibonaccis.
  List<String> addFibonaccis(List<FibonacciRetracement> fibonaccis) {
    _fibonaccis.addAll(fibonaccis);
    for (final fib in fibonaccis) {
      _notifyListeners(FibonacciEvent.added(fib));
    }
    return fibonaccis.map((fib) => fib.id).toList();
  }

  /// Removes a Fibonacci retracement by its ID.
  ///
  /// Returns true if the Fibonacci was found and removed.
  bool removeFibonacci(String id) {
    final index = _fibonaccis.indexWhere((fib) => fib.id == id);
    if (index != -1) {
      _fibonaccis.removeAt(index);
      _notifyListeners(FibonacciEvent.removed(id));
      return true;
    }
    return false;
  }

  /// Removes all Fibonacci retracements.
  void clear() {
    _fibonaccis.clear();
    _notifyListeners(FibonacciEvent.cleared());
  }

  // ============================================================================
  // Update Operations
  // ============================================================================
  
  /// Updates a Fibonacci retracement using a custom updater function.
  ///
  /// Returns true if the Fibonacci was found and updated.
  bool updateFibonacci(String id, FibonacciRetracement Function(FibonacciRetracement) updater) {
    final index = _fibonaccis.indexWhere((fib) => fib.id == id);
    if (index != -1) {
      _fibonaccis[index] = updater(_fibonaccis[index]);
      _notifyListeners(FibonacciEvent.updated(_fibonaccis[index]));
      return true;
    }
    return false;
  }

  /// Updates the price range of a Fibonacci retracement.
  ///
  /// Returns true if the Fibonacci was found and updated.
  bool updateFibonacciRange(String id, double newHighPrice, double newLowPrice, {int? startTime, int? endTime}) {
    return updateFibonacci(id, (fib) => fib.copyWith(
      highPrice: newHighPrice,
      lowPrice: newLowPrice,
      startTime: startTime ?? fib.startTime,
      endTime: endTime ?? fib.endTime,
    ));
  }

  /// Sets the visibility of a Fibonacci retracement.
  ///
  /// Returns true if the Fibonacci was found and updated.
  bool setFibonacciVisibility(String id, bool visible) {
    return updateFibonacci(id, (fib) => fib.copyWith(visible: visible));
  }

  /// Toggles the visibility of a Fibonacci retracement.
  ///
  /// Returns the new visibility state, or null if not found.
  bool? toggleFibonacciVisibility(String id) {
    final index = _fibonaccis.indexWhere((fib) => fib.id == id);
    if (index != -1) {
      final newVisibility = !_fibonaccis[index].visible;
      _fibonaccis[index] = _fibonaccis[index].copyWith(visible: newVisibility);
      _notifyListeners(FibonacciEvent.visibilityChanged(_fibonaccis[index]));
      return newVisibility;
    }
    return null;
  }

  // ============================================================================
  // Query Operations
  // ============================================================================
  
  /// Returns all Fibonacci retracements.
  ///
  /// Returns a new list to prevent external modifications.
  List<FibonacciRetracement> get fibonaccis => List.from(_fibonaccis);

  /// Returns the number of Fibonacci retracements.
  int get count => _fibonaccis.length;

  /// Returns whether the manager has any Fibonacci retracements.
  bool get isEmpty => _fibonaccis.isEmpty;

  /// Returns whether the manager has Fibonacci retracements.
  bool get isNotEmpty => _fibonaccis.isNotEmpty;

  /// Gets a Fibonacci retracement by its ID.
  ///
  /// Returns null if not found.
  FibonacciRetracement? getFibonacciById(String id) {
    try {
      return _fibonaccis.firstWhere((fib) => fib.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Gets all Fibonacci retracements that contain a specific price.
  ///
  /// A Fibonacci contains a price if the price is between its low and high.
  List<FibonacciRetracement> getFibonaccisAtPrice(double price) {
    return _fibonaccis
        .where((fib) => price >= fib.lowPrice && price <= fib.highPrice)
        .toList();
  }

  /// Gets all Fibonacci retracements that overlap with a price range.
  ///
  /// A Fibonacci overlaps if any part of it is within the given range.
  List<FibonacciRetracement> getFibonaccisInRange(double minPrice, double maxPrice) {
    return _fibonaccis
        .where((fib) => 
            (fib.lowPrice <= maxPrice && fib.highPrice >= minPrice))
        .toList();
  }

  /// Finds the closest Fibonacci retracement to a given price.
  ///
  /// Returns null if there are no Fibonaccis.
  FibonacciRetracement? findClosestFibonacci(double price) {
    if (_fibonaccis.isEmpty) return null;

    FibonacciRetracement? closest;
    double minDistance = double.infinity;

    for (final fib in _fibonaccis) {
      final centerPrice = (fib.highPrice + fib.lowPrice) / 2;
      final distance = (price - centerPrice).abs();
      if (distance < minDistance) {
        minDistance = distance;
        closest = fib;
      }
    }

    return closest;
  }

  /// Gets all visible Fibonacci retracements.
  List<FibonacciRetracement> get visibleFibonaccis => 
      _fibonaccis.where((fib) => fib.visible).toList();

  /// Gets all hidden Fibonacci retracements.
  List<FibonacciRetracement> get hiddenFibonaccis => 
      _fibonaccis.where((fib) => !fib.visible).toList();

  // ============================================================================
  // Sorting Operations
  // ============================================================================
  
  /// Sorts Fibonacci retracements by their high price (descending).
  void sortByHighPrice({bool ascending = false}) {
    _fibonaccis.sort((a, b) => 
        ascending 
            ? a.highPrice.compareTo(b.highPrice)
            : b.highPrice.compareTo(a.highPrice));
  }

  /// Sorts Fibonacci retracements by their low price (descending).
  void sortByLowPrice({bool ascending = false}) {
    _fibonaccis.sort((a, b) => 
        ascending 
            ? a.lowPrice.compareTo(b.lowPrice)
            : b.lowPrice.compareTo(a.lowPrice));
  }

  /// Sorts Fibonacci retracements by their range (high - low, descending).
  void sortByRange({bool ascending = false}) {
    _fibonaccis.sort((a, b) {
      final rangeA = a.highPrice - a.lowPrice;
      final rangeB = b.highPrice - b.lowPrice;
      return ascending
          ? rangeA.compareTo(rangeB)
          : rangeB.compareTo(rangeA);
    });
  }

  /// Serializes all managed Fibonacci retracements to a JSON-safe list.
  List<Map<String, dynamic>> serializeAll() {
    return _fibonaccis.map((fib) => fib.toJson()).toList();
  }

  /// Removes all Fibonacci retracements and restores from serialized data.
  void restoreAll(List<Map<String, dynamic>> data) {
    _fibonaccis.clear();
    for (final json in data) {
      _fibonaccis.add(FibonacciRetracement.fromJson(json));
    }
    _notifyListeners(FibonacciEvent.cleared());
  }
}
