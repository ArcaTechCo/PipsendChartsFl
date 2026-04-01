import 'price_zone.dart';
import 'price_zone_type.dart';
import 'price_zone_event.dart';

/// Manages a collection of price zones.
///
/// Provides methods to add, remove, update, and query price zones.
///
/// Example:
/// ```dart
/// final manager = PriceZoneManager();
///
/// // Add zone
/// final zoneId = manager.addZone(PriceZone(
///   minPrice: 100.0,
///   maxPrice: 120.0,
///   type: PriceZoneType.demand,
/// ));
///
/// // Update range
/// manager.updateZoneRange(zoneId, 105.0, 125.0);
///
/// // Remove zone
/// manager.removeZone(zoneId);
///
/// // Get all zones
/// final allZones = manager.zones;
/// ```
class PriceZoneManager {
  final List<PriceZone> _zones = [];
  final List<PriceZoneListener> _listeners = [];

  // ============================================================================
  // Event Listeners
  // ============================================================================
  
  /// Adds a listener that will be called when zones change.
  void addListener(PriceZoneListener listener) {
    _listeners.add(listener);
  }
  
  /// Removes a previously added listener.
  void removeListener(PriceZoneListener listener) {
    _listeners.remove(listener);
  }
  
  /// Removes all listeners.
  void clearListeners() {
    _listeners.clear();
  }
  
  /// Notifies all listeners of an event.
  void _notifyListeners(PriceZoneEvent event) {
    for (final listener in _listeners) {
      listener(event);
    }
  }

  // ============================================================================
  // Add/Remove Operations
  // ============================================================================
  
  /// Adds a price zone to the manager.
  ///
  /// Returns the ID of the added zone.
  String addZone(PriceZone zone) {
    _zones.add(zone);
    _notifyListeners(PriceZoneEvent.added(zone));
    return zone.id;
  }

  /// Adds multiple price zones at once.
  ///
  /// Returns a list of IDs for the added zones.
  List<String> addZones(List<PriceZone> zones) {
    _zones.addAll(zones);
    return zones.map((zone) => zone.id).toList();
  }

  /// Removes a price zone by its ID.
  ///
  /// Returns true if the zone was found and removed, false otherwise.
  bool removeZone(String id) {
    final index = _zones.indexWhere((zone) => zone.id == id);
    if (index != -1) {
      final zone = _zones[index];
      _zones.removeAt(index);
      
      // Trigger onDelete callback if provided
      zone.options.onDelete?.call();
      
      _notifyListeners(PriceZoneEvent.removed(zone));
      return true;
    }
    return false;
  }

  /// Removes multiple zones by their IDs.
  ///
  /// Returns the number of zones successfully removed.
  int removeZones(List<String> ids) {
    int removed = 0;
    for (final id in ids) {
      if (removeZone(id)) removed++;
    }
    return removed;
  }

  /// Gets a price zone by its ID.
  ///
  /// Returns null if the zone is not found.
  PriceZone? getZoneById(String id) {
    try {
      return _zones.firstWhere((zone) => zone.id == id);
    } catch (e) {
      return null;
    }
  }

  // ============================================================================
  // Update Operations
  // ============================================================================
  
  /// Updates a price zone using a custom updater function.
  ///
  /// Returns true if the zone was found and updated, false otherwise.
  ///
  /// Example:
  /// ```dart
  /// manager.updateZone('zone_id', (zone) => zone.copyWith(visible: false));
  /// ```
  bool updateZone(String id, PriceZone Function(PriceZone) updater) {
    final index = _zones.indexWhere((zone) => zone.id == id);
    if (index == -1) return false;

    final oldZone = _zones[index];
    final updatedZone = updater(oldZone);
    _zones[index] = updatedZone;
    
    return true;
  }

  /// Updates the price range of a zone.
  ///
  /// Returns true if the zone was found and updated, false otherwise.
  bool updateZoneRange(String id, double newMinPrice, double newMaxPrice, {int? startTime, int? endTime}) {
    if (newMaxPrice <= newMinPrice) return false;

    final index = _zones.indexWhere((zone) => zone.id == id);
    if (index == -1) return false;

    final oldZone = _zones[index];
    final updatedZone = oldZone.copyWith(
      minPrice: newMinPrice,
      maxPrice: newMaxPrice,
      startTime: startTime ?? oldZone.startTime,
      endTime: endTime ?? oldZone.endTime,
    );
    _zones[index] = updatedZone;

    _notifyListeners(PriceZoneEvent.rangeChanged(
      updatedZone,
      oldZone.minPrice,
      oldZone.maxPrice,
      newMinPrice,
      newMaxPrice,
    ));

    return true;
  }
  
  /// Sets the visibility of a price zone.
  ///
  /// Returns true if the zone was found and updated, false otherwise.
  bool setZoneVisibility(String id, bool visible) {
    final index = _zones.indexWhere((zone) => zone.id == id);
    if (index == -1) return false;

    final oldZone = _zones[index];
    if (oldZone.visible == visible) return true; // No change
    
    final updatedZone = oldZone.copyWith(visible: visible);
    _zones[index] = updatedZone;
    
    _notifyListeners(PriceZoneEvent.visibilityChanged(
      updatedZone,
      oldZone.visible,
      visible,
    ));
    
    return true;
  }
  
  /// Toggles the visibility of a price zone.
  ///
  /// Returns the new visibility state, or null if zone not found.
  bool? toggleZoneVisibility(String id) {
    final zone = getZoneById(id);
    if (zone == null) return null;
    
    final newVisibility = !zone.visible;
    setZoneVisibility(id, newVisibility);
    return newVisibility;
  }
  
  /// Updates multiple zones at once.
  ///
  /// The map keys are zone IDs, and values are updater functions.
  void updateZones(Map<String, PriceZone Function(PriceZone)> updates) {
    for (final entry in updates.entries) {
      updateZone(entry.key, entry.value);
    }
  }

  // ============================================================================
  // Query Operations
  // ============================================================================

  /// Gets all price zones.
  ///
  /// Returns a new list copy to trigger rebuilds.
  List<PriceZone> get zones => List.from(_zones);

  /// Gets all visible price zones.
  List<PriceZone> get visibleZones =>
      _zones.where((zone) => zone.visible).toList();

  /// Gets price zones by type.
  ///
  /// Example:
  /// ```dart
  /// final demandZones = manager.getZonesByType(PriceZoneType.demand);
  /// ```
  List<PriceZone> getZonesByType(PriceZoneType type) {
    return _zones.where((zone) => zone.type == type).toList();
  }

  /// Gets all support zones.
  List<PriceZone> get supportZones =>
      getZonesByType(PriceZoneType.support);

  /// Gets all resistance zones.
  List<PriceZone> get resistanceZones =>
      getZonesByType(PriceZoneType.resistance);

  /// Gets all demand zones.
  List<PriceZone> get demandZones =>
      getZonesByType(PriceZoneType.demand);

  /// Gets all supply zones.
  List<PriceZone> get supplyZones =>
      getZonesByType(PriceZoneType.supply);

  /// Gets zones that overlap with a given price.
  ///
  /// Returns all zones where minPrice <= price <= maxPrice.
  List<PriceZone> getZonesAtPrice(double price) {
    return _zones
        .where((zone) => price >= zone.minPrice && price <= zone.maxPrice)
        .toList();
  }

  /// Gets zones within a price range.
  ///
  /// Returns zones that overlap with the given range.
  List<PriceZone> getZonesInRange(double minPrice, double maxPrice) {
    return _zones.where((zone) {
      // Check if zones overlap
      return !(zone.maxPrice < minPrice || zone.minPrice > maxPrice);
    }).toList();
  }

  /// Finds the zone closest to a given price.
  ///
  /// Returns null if there are no zones.
  PriceZone? findClosestZone(double price) {
    if (_zones.isEmpty) return null;

    PriceZone? closest;
    double minDistance = double.infinity;

    for (final zone in _zones) {
      // Distance to zone center
      final distance = (zone.centerPrice - price).abs();
      if (distance < minDistance) {
        minDistance = distance;
        closest = zone;
      }
    }

    return closest;
  }

  // ============================================================================
  // Clear Operations
  // ============================================================================

  /// Clears all price zones.
  void clear() {
    _zones.clear();
    _notifyListeners(PriceZoneEvent.cleared());
  }

  /// Clears price zones by type.
  ///
  /// Example:
  /// ```dart
  /// manager.clearByType(PriceZoneType.custom);
  /// ```
  void clearByType(PriceZoneType type) {
    _zones.removeWhere((zone) => zone.type == type);
  }

  /// Clears all support zones.
  void clearSupportZones() => clearByType(PriceZoneType.support);

  /// Clears all resistance zones.
  void clearResistanceZones() => clearByType(PriceZoneType.resistance);

  /// Clears all demand zones.
  void clearDemandZones() => clearByType(PriceZoneType.demand);

  /// Clears all supply zones.
  void clearSupplyZones() => clearByType(PriceZoneType.supply);

  // ============================================================================
  // Utility
  // ============================================================================

  /// Gets the number of price zones.
  int get count => _zones.length;

  /// Whether there are any price zones.
  bool get isEmpty => _zones.isEmpty;

  /// Whether there are price zones.
  bool get isNotEmpty => _zones.isNotEmpty;

  /// Checks if a zone with the given ID exists.
  bool hasZone(String id) {
    return _zones.any((zone) => zone.id == id);
  }

  /// Sorts zones by minimum price (ascending).
  void sortByMinPrice() {
    _zones.sort((a, b) => a.minPrice.compareTo(b.minPrice));
  }

  /// Sorts zones by minimum price (descending).
  void sortByMinPriceDescending() {
    _zones.sort((a, b) => b.minPrice.compareTo(a.minPrice));
  }

  /// Sorts zones by height (ascending).
  void sortByHeight() {
    _zones.sort((a, b) => a.height.compareTo(b.height));
  }

  /// Sorts zones by type.
  void sortByType() {
    _zones.sort((a, b) => a.type.index.compareTo(b.type.index));
  }

  List<Map<String, dynamic>> serializeAll() {
    return _zones.map((zone) => zone.toJson()).toList();
  }

  void restoreAll(List<Map<String, dynamic>> data) {
    _zones.clear();
    for (final json in data) {
      _zones.add(PriceZone.fromJson(json));
    }
    _notifyListeners(PriceZoneEvent.cleared());
  }

  @override
  String toString() => 'PriceZoneManager(count: $count)';
}
