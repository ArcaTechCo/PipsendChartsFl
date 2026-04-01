import 'trading_line.dart';
import 'trading_line_type.dart';
import 'trading_line_event.dart';

/// Manages a collection of trading lines.
///
/// Provides methods to add, remove, update, and query trading lines.
/// Supports event listeners for reactive updates.
///
/// Example:
/// ```dart
/// final manager = TradingLineManager();
///
/// // Listen to events
/// manager.addListener((event) {
///   print('Event: ${event.type}');
/// });
///
/// // Add lines
/// final slId = manager.addLine(TradingLine(
///   price: 145.0,
///   type: TradingLineType.stopLoss,
/// ));
///
/// // Update price
/// manager.updateLinePrice(slId, 146.0);
///
/// // Remove line
/// manager.removeLine(slId);
///
/// // Get all lines
/// final allLines = manager.lines;
/// ```
class TradingLineManager {
  final List<TradingLine> _lines = [];
  final List<TradingLineListener> _listeners = [];
  
  /// Minimum allowed price for lines (null = no limit).
  double? minPrice;
  
  /// Maximum allowed price for lines (null = no limit).
  double? maxPrice;
  
  /// Maximum number of lines allowed per type (null = no limit).
  Map<TradingLineType, int>? maxLinesPerType;

  // ============================================================================
  // Event Listeners
  // ============================================================================
  
  /// Adds a listener for trading line events.
  void addListener(TradingLineListener listener) {
    _listeners.add(listener);
  }
  
  /// Removes a listener.
  void removeListener(TradingLineListener listener) {
    _listeners.remove(listener);
  }
  
  /// Removes all listeners.
  void clearListeners() {
    _listeners.clear();
  }
  
  /// Notifies all listeners of an event.
  void _notifyListeners(TradingLineEvent event) {
    for (final listener in _listeners) {
      listener(event);
    }
  }
  
  // ============================================================================
  // Validation
  // ============================================================================
  
  /// Checks if a line can be added based on constraints.
  bool canAddLine(TradingLine line) {
    // Check price constraints
    if (minPrice != null && line.price < minPrice!) {
      return false;
    }
    if (maxPrice != null && line.price > maxPrice!) {
      return false;
    }
    
    // Check max lines per type constraint
    if (maxLinesPerType != null) {
      final typeCount = getLinesByType(line.type).length;
      final maxForType = maxLinesPerType![line.type];
      if (maxForType != null && typeCount >= maxForType) {
        return false;
      }
    }
    
    return true;
  }
  
  // ============================================================================
  // Add/Remove Operations
  // ============================================================================
  
  /// Adds a trading line to the manager.
  ///
  /// Returns the ID of the added line, or null if validation failed.
  String? addLine(TradingLine line) {
    if (!canAddLine(line)) {
      return null;
    }
    
    _lines.add(line);
    _notifyListeners(TradingLineEvent.added(line));
    return line.id;
  }

  /// Adds multiple trading lines at once.
  ///
  /// Returns a list of IDs for the successfully added lines.
  List<String> addLines(List<TradingLine> lines) {
    final ids = <String>[];
    for (final line in lines) {
      final id = addLine(line);
      if (id != null) {
        ids.add(id);
      }
    }
    return ids;
  }

  /// Removes a trading line by its ID.
  ///
  /// Returns true if the line was found and removed, false otherwise.
  bool removeLine(String id) {
    final index = _lines.indexWhere((line) => line.id == id);
    if (index != -1) {
      final line = _lines[index];
      _lines.removeAt(index);
      
      // Trigger onDelete callback if provided
      line.options.onDelete?.call();
      
      // Notify listeners
      _notifyListeners(TradingLineEvent.removed(line));
      
      return true;
    }
    return false;
  }

  /// Removes multiple lines by their IDs.
  ///
  /// Returns the number of lines successfully removed.
  int removeLines(List<String> ids) {
    int removed = 0;
    for (final id in ids) {
      if (removeLine(id)) removed++;
    }
    return removed;
  }

  /// Gets a trading line by its ID.
  ///
  /// Returns null if the line is not found.
  TradingLine? getLineById(String id) {
    try {
      return _lines.firstWhere((line) => line.id == id);
    } catch (e) {
      return null;
    }
  }

  // ============================================================================
  // Update Operations
  // ============================================================================
  
  /// Updates a trading line using a custom updater function.
  ///
  /// Returns true if the line was found and updated, false otherwise.
  ///
  /// Example:
  /// ```dart
  /// manager.updateLine('line_id', (line) => line.copyWith(visible: false));
  /// ```
  bool updateLine(String id, TradingLine Function(TradingLine) updater) {
    final index = _lines.indexWhere((line) => line.id == id);
    if (index == -1) return false;

    final oldLine = _lines[index];
    final updatedLine = updater(oldLine);
    _lines[index] = updatedLine;
    
    _notifyListeners(TradingLineEvent.updated(updatedLine));
    return true;
  }

  /// Updates the price of a trading line.
  ///
  /// Returns true if the line was found and updated, false otherwise.
  bool updateLinePrice(String id, double newPrice) {
    final index = _lines.indexWhere((line) => line.id == id);
    if (index == -1) return false;

    final oldLine = _lines[index];
    
    // Check price constraints
    if (minPrice != null && newPrice < minPrice!) return false;
    if (maxPrice != null && newPrice > maxPrice!) return false;
    
    final updatedLine = oldLine.withPrice(newPrice);
    _lines[index] = updatedLine;
    
    _notifyListeners(TradingLineEvent.priceChanged(updatedLine, oldLine.price, newPrice));
    return true;
  }
  
  /// Sets the visibility of a trading line.
  ///
  /// Returns true if the line was found and updated, false otherwise.
  bool setLineVisibility(String id, bool visible) {
    final index = _lines.indexWhere((line) => line.id == id);
    if (index == -1) return false;

    final oldLine = _lines[index];
    if (oldLine.visible == visible) return true; // No change
    
    final updatedLine = oldLine.copyWith(visible: visible);
    _lines[index] = updatedLine;
    
    _notifyListeners(TradingLineEvent.visibilityChanged(updatedLine, oldLine.visible, visible));
    return true;
  }
  
  /// Toggles the visibility of a trading line.
  ///
  /// Returns the new visibility state, or null if line not found.
  bool? toggleLineVisibility(String id) {
    final line = getLineById(id);
    if (line == null) return null;
    
    final newVisibility = !line.visible;
    setLineVisibility(id, newVisibility);
    return newVisibility;
  }
  
  /// Updates multiple lines at once.
  ///
  /// The map keys are line IDs, and values are updater functions.
  void updateLines(Map<String, TradingLine Function(TradingLine)> updates) {
    for (final entry in updates.entries) {
      updateLine(entry.key, entry.value);
    }
  }
  
  /// Updates multiple prices at once.
  ///
  /// The map keys are line IDs, and values are new prices.
  void updatePrices(Map<String, double> priceUpdates) {
    for (final entry in priceUpdates.entries) {
      updateLinePrice(entry.key, entry.value);
    }
  }

  /// Gets a trading line by its ID.
  ///
  /// Returns null if no line with the given ID exists.
  TradingLine? getLine(String id) {
    try {
      return _lines.firstWhere((line) => line.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Gets all trading lines.
  ///
  /// Returns an unmodifiable list to prevent external modifications.
  List<TradingLine> get lines => List.unmodifiable(_lines);

  /// Gets all visible trading lines.
  List<TradingLine> get visibleLines =>
      _lines.where((line) => line.visible).toList();

  /// Gets trading lines by type.
  ///
  /// Example:
  /// ```dart
  /// final stopLosses = manager.getLinesByType(TradingLineType.stopLoss);
  /// ```
  List<TradingLine> getLinesByType(TradingLineType type) {
    return _lines.where((line) => line.type == type).toList();
  }

  /// Gets all stop loss lines.
  List<TradingLine> get stopLossLines =>
      getLinesByType(TradingLineType.stopLoss);

  /// Gets all take profit lines.
  List<TradingLine> get takeProfitLines =>
      getLinesByType(TradingLineType.takeProfit);

  /// Gets all entry lines.
  List<TradingLine> get entryLines =>
      getLinesByType(TradingLineType.entry);

  /// Gets all alert lines.
  List<TradingLine> get alertLines =>
      getLinesByType(TradingLineType.alert);

  /// Gets all support lines.
  List<TradingLine> get supportLines =>
      getLinesByType(TradingLineType.support);

  /// Gets all resistance lines.
  List<TradingLine> get resistanceLines =>
      getLinesByType(TradingLineType.resistance);

  /// Gets lines within a price range.
  ///
  /// [minPrice] is the minimum price (inclusive).
  /// [maxPrice] is the maximum price (inclusive).
  List<TradingLine> getLinesInRange(double minPrice, double maxPrice) {
    return _lines
        .where((line) => line.price >= minPrice && line.price <= maxPrice)
        .toList();
  }

  /// Finds the line closest to a given price.
  ///
  /// Returns null if there are no lines.
  TradingLine? findClosestLine(double price) {
    if (_lines.isEmpty) return null;

    TradingLine? closest;
    double minDistance = double.infinity;

    for (final line in _lines) {
      final distance = (line.price - price).abs();
      if (distance < minDistance) {
        minDistance = distance;
        closest = line;
      }
    }

    return closest;
  }

  /// Clears all trading lines.
  void clear() {
    _lines.clear();
    _notifyListeners(TradingLineEvent.cleared());
  }

  /// Clears trading lines by type.
  ///
  /// Example:
  /// ```dart
  /// manager.clearByType(TradingLineType.alert);
  /// ```
  void clearByType(TradingLineType type) {
    _lines.removeWhere((line) => line.type == type);
  }

  /// Clears all stop loss lines.
  void clearStopLosses() => clearByType(TradingLineType.stopLoss);

  /// Clears all take profit lines.
  void clearTakeProfits() => clearByType(TradingLineType.takeProfit);

  /// Clears all alert lines.
  void clearAlerts() => clearByType(TradingLineType.alert);

  /// Gets the number of trading lines.
  int get count => _lines.length;

  /// Whether there are any trading lines.
  bool get isEmpty => _lines.isEmpty;

  /// Whether there are trading lines.
  bool get isNotEmpty => _lines.isNotEmpty;

  /// Checks if a line with the given ID exists.
  bool hasLine(String id) {
    return _lines.any((line) => line.id == id);
  }

  /// Sorts lines by price (ascending).
  void sortByPrice() {
    _lines.sort((a, b) => a.price.compareTo(b.price));
  }

  /// Sorts lines by price (descending).
  void sortByPriceDescending() {
    _lines.sort((a, b) => b.price.compareTo(a.price));
  }

  /// Sorts lines by type.
  void sortByType() {
    _lines.sort((a, b) => a.type.index.compareTo(b.type.index));
  }

  List<Map<String, dynamic>> serializeAll() {
    return _lines.map((line) => line.toJson()).toList();
  }

  void restoreAll(List<Map<String, dynamic>> data) {
    _lines.clear();
    for (final json in data) {
      _lines.add(TradingLine.fromJson(json));
    }
    _notifyListeners(TradingLineEvent.cleared());
  }

  @override
  String toString() => 'TradingLineManager(count: $count)';
}
