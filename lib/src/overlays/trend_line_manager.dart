import 'trend_line.dart';
import 'trend_line_event.dart';

/// Manages a collection of trend lines.
///
/// Provides methods to add, remove, update, and query trend lines.
///
/// Example:
/// ```dart
/// final manager = TrendLineManager();
///
/// // Add trend line
/// final lineId = manager.addTrendLine(TrendLine(
///   startTime: 1234567890,
///   startPrice: 100.0,
///   endTime: 1234567900,
///   endPrice: 110.0,
/// ));
///
/// // Update points
/// manager.updateTrendLinePoints(lineId, 
///   startTime: 1234567890,
///   startPrice: 105.0,
///   endTime: 1234567900,
///   endPrice: 115.0,
/// );
///
/// // Remove trend line
/// manager.removeTrendLine(lineId);
///
/// // Get all trend lines
/// final allLines = manager.trendLines;
/// ```
class TrendLineManager {
  final List<TrendLine> _trendLines = [];
  final List<TrendLineListener> _listeners = [];

  // ============================================================================
  // Event Listeners
  // ============================================================================
  
  /// Adds a listener that will be called when trend lines change.
  void addListener(TrendLineListener listener) {
    _listeners.add(listener);
  }
  
  /// Removes a previously added listener.
  void removeListener(TrendLineListener listener) {
    _listeners.remove(listener);
  }
  
  /// Removes all listeners.
  void clearListeners() {
    _listeners.clear();
  }
  
  /// Notifies all listeners of an event.
  void _notifyListeners(TrendLineEvent event) {
    for (final listener in _listeners) {
      listener(event);
    }
  }

  // ============================================================================
  // Add/Remove Operations
  // ============================================================================
  
  /// Adds a trend line to the manager.
  ///
  /// Returns the ID of the added trend line.
  String addTrendLine(TrendLine trendLine) {
    _trendLines.add(trendLine);
    _notifyListeners(TrendLineEvent.added(trendLine));
    return trendLine.id;
  }

  /// Adds multiple trend lines at once.
  ///
  /// Returns a list of IDs for the added trend lines.
  List<String> addTrendLines(List<TrendLine> trendLines) {
    _trendLines.addAll(trendLines);
    for (final line in trendLines) {
      _notifyListeners(TrendLineEvent.added(line));
    }
    return trendLines.map((line) => line.id).toList();
  }

  /// Removes a trend line by its ID.
  ///
  /// Returns true if the trend line was found and removed.
  bool removeTrendLine(String id) {
    final index = _trendLines.indexWhere((line) => line.id == id);
    if (index != -1) {
      _trendLines.removeAt(index);
      _notifyListeners(TrendLineEvent.removed(id));
      return true;
    }
    return false;
  }

  /// Removes all trend lines.
  void clear() {
    _trendLines.clear();
    _notifyListeners(TrendLineEvent.cleared());
  }

  // ============================================================================
  // Update Operations
  // ============================================================================
  
  /// Updates a trend line using a custom updater function.
  ///
  /// Returns true if the trend line was found and updated.
  bool updateTrendLine(String id, TrendLine Function(TrendLine) updater) {
    final index = _trendLines.indexWhere((line) => line.id == id);
    if (index != -1) {
      _trendLines[index] = updater(_trendLines[index]);
      _notifyListeners(TrendLineEvent.updated(_trendLines[index]));
      return true;
    }
    return false;
  }

  /// Updates the points of a trend line.
  ///
  /// Returns true if the trend line was found and updated.
  bool updateTrendLinePoints(
    String id, {
    int? startTime,
    double? startPrice,
    int? endTime,
    double? endPrice,
  }) {
    return updateTrendLine(id, (line) => line.withPoints(
      startTime: startTime,
      startPrice: startPrice,
      endTime: endTime,
      endPrice: endPrice,
    ));
  }

  /// Sets the visibility of a trend line.
  ///
  /// Returns true if the trend line was found and updated.
  bool setTrendLineVisibility(String id, bool visible) {
    return updateTrendLine(id, (line) => line.copyWith(visible: visible));
  }

  /// Toggles the visibility of a trend line.
  ///
  /// Returns the new visibility state, or null if not found.
  bool? toggleTrendLineVisibility(String id) {
    final index = _trendLines.indexWhere((line) => line.id == id);
    if (index != -1) {
      final newVisibility = !_trendLines[index].visible;
      _trendLines[index] = _trendLines[index].copyWith(visible: newVisibility);
      _notifyListeners(TrendLineEvent.visibilityChanged(_trendLines[index]));
      return newVisibility;
    }
    return null;
  }

  // ============================================================================
  // Query Operations
  // ============================================================================
  
  /// Returns all trend lines.
  ///
  /// Returns a new list to prevent external modifications.
  List<TrendLine> get trendLines => List.from(_trendLines);

  /// Returns the number of trend lines.
  int get count => _trendLines.length;

  /// Returns whether the manager has any trend lines.
  bool get isEmpty => _trendLines.isEmpty;

  /// Returns whether the manager has trend lines.
  bool get isNotEmpty => _trendLines.isNotEmpty;

  /// Gets a trend line by its ID.
  ///
  /// Returns null if not found.
  TrendLine? getTrendLineById(String id) {
    try {
      return _trendLines.firstWhere((line) => line.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Gets all trend lines that pass through or near a specific price.
  ///
  /// A trend line is considered to pass through a price if the price is
  /// between its start and end prices (with some tolerance).
  List<TrendLine> getTrendLinesAtPrice(double price, {double tolerance = 5.0}) {
    return _trendLines.where((line) {
      final minPrice = line.startPrice < line.endPrice ? line.startPrice : line.endPrice;
      final maxPrice = line.startPrice > line.endPrice ? line.startPrice : line.endPrice;
      return price >= (minPrice - tolerance) && price <= (maxPrice + tolerance);
    }).toList();
  }

  /// Gets all trend lines that overlap with a price range.
  List<TrendLine> getTrendLinesInRange(double minPrice, double maxPrice) {
    return _trendLines.where((line) {
      final lineMinPrice = line.startPrice < line.endPrice ? line.startPrice : line.endPrice;
      final lineMaxPrice = line.startPrice > line.endPrice ? line.startPrice : line.endPrice;
      return (lineMinPrice <= maxPrice && lineMaxPrice >= minPrice);
    }).toList();
  }

  /// Gets all trend lines within a time range.
  List<TrendLine> getTrendLinesInTimeRange(int startTime, int endTime) {
    return _trendLines.where((line) =>
        (line.startTime <= endTime && line.endTime >= startTime)).toList();
  }

  /// Finds the closest trend line to a given price.
  ///
  /// Returns null if there are no trend lines.
  TrendLine? findClosestTrendLine(double price) {
    if (_trendLines.isEmpty) return null;

    TrendLine? closest;
    double minDistance = double.infinity;

    for (final line in _trendLines) {
      final centerPrice = (line.startPrice + line.endPrice) / 2;
      final distance = (price - centerPrice).abs();
      if (distance < minDistance) {
        minDistance = distance;
        closest = line;
      }
    }

    return closest;
  }

  /// Gets all visible trend lines.
  List<TrendLine> get visibleTrendLines => 
      _trendLines.where((line) => line.visible).toList();

  /// Gets all hidden trend lines.
  List<TrendLine> get hiddenTrendLines => 
      _trendLines.where((line) => !line.visible).toList();

  /// Gets all ascending trend lines (end price > start price).
  List<TrendLine> get ascendingTrendLines => 
      _trendLines.where((line) => line.endPrice > line.startPrice).toList();

  /// Gets all descending trend lines (end price < start price).
  List<TrendLine> get descendingTrendLines => 
      _trendLines.where((line) => line.endPrice < line.startPrice).toList();

  /// Gets all horizontal trend lines (end price ≈ start price).
  List<TrendLine> get horizontalTrendLines => 
      _trendLines.where((line) => (line.endPrice - line.startPrice).abs() < 0.01).toList();

  // ============================================================================
  // Sorting Operations
  // ============================================================================
  
  /// Sorts trend lines by their start time (ascending by default).
  void sortByStartTime({bool ascending = true}) {
    _trendLines.sort((a, b) => 
        ascending 
            ? a.startTime.compareTo(b.startTime)
            : b.startTime.compareTo(a.startTime));
  }

  /// Sorts trend lines by their start price (ascending by default).
  void sortByStartPrice({bool ascending = true}) {
    _trendLines.sort((a, b) => 
        ascending 
            ? a.startPrice.compareTo(b.startPrice)
            : b.startPrice.compareTo(a.startPrice));
  }

  /// Sorts trend lines by their angle (ascending by default).
  void sortByAngle({bool ascending = true}) {
    _trendLines.sort((a, b) => 
        ascending 
            ? a.angle.compareTo(b.angle)
            : b.angle.compareTo(a.angle));
  }

  /// Sorts trend lines by their duration (end time - start time).
  void sortByDuration({bool ascending = true}) {
    _trendLines.sort((a, b) {
      final durationA = a.endTime - a.startTime;
      final durationB = b.endTime - b.startTime;
      return ascending 
          ? durationA.compareTo(durationB)
          : durationB.compareTo(durationA);
    });
  }
}
