import 'price_zone.dart';

/// Types of events that can occur in the PriceZoneManager.
enum PriceZoneEventType {
  /// A zone was added to the manager.
  added,
  
  /// A zone was removed from the manager.
  removed,
  
  /// A zone's price range was changed.
  rangeChanged,
  
  /// A zone's visibility was changed.
  visibilityChanged,
  
  /// A zone's style was changed.
  styleChanged,
  
  /// A zone was updated (generic update).
  updated,
  
  /// All zones were cleared.
  cleared,
}

/// Event emitted when a zone changes in the PriceZoneManager.
class PriceZoneEvent {
  /// Type of the event.
  final PriceZoneEventType type;
  
  /// The zone involved in the event (null for cleared event).
  final PriceZone? zone;
  
  /// Old minimum price (for rangeChanged event).
  final double? oldMinPrice;
  
  /// New minimum price (for rangeChanged event).
  final double? newMinPrice;
  
  /// Old maximum price (for rangeChanged event).
  final double? oldMaxPrice;
  
  /// New maximum price (for rangeChanged event).
  final double? newMaxPrice;
  
  /// Old visibility (for visibilityChanged event).
  final bool? oldVisible;
  
  /// New visibility (for visibilityChanged event).
  final bool? newVisible;
  
  const PriceZoneEvent._({
    required this.type,
    this.zone,
    this.oldMinPrice,
    this.newMinPrice,
    this.oldMaxPrice,
    this.newMaxPrice,
    this.oldVisible,
    this.newVisible,
  });
  
  /// Creates an event for when a zone is added.
  factory PriceZoneEvent.added(PriceZone zone) {
    return PriceZoneEvent._(
      type: PriceZoneEventType.added,
      zone: zone,
    );
  }
  
  /// Creates an event for when a zone is removed.
  factory PriceZoneEvent.removed(PriceZone zone) {
    return PriceZoneEvent._(
      type: PriceZoneEventType.removed,
      zone: zone,
    );
  }
  
  /// Creates an event for when a zone's range changes.
  factory PriceZoneEvent.rangeChanged(
    PriceZone zone,
    double oldMinPrice,
    double oldMaxPrice,
    double newMinPrice,
    double newMaxPrice,
  ) {
    return PriceZoneEvent._(
      type: PriceZoneEventType.rangeChanged,
      zone: zone,
      oldMinPrice: oldMinPrice,
      oldMaxPrice: oldMaxPrice,
      newMinPrice: newMinPrice,
      newMaxPrice: newMaxPrice,
    );
  }
  
  /// Creates an event for when a zone's visibility changes.
  factory PriceZoneEvent.visibilityChanged(
    PriceZone zone,
    bool oldVisible,
    bool newVisible,
  ) {
    return PriceZoneEvent._(
      type: PriceZoneEventType.visibilityChanged,
      zone: zone,
      oldVisible: oldVisible,
      newVisible: newVisible,
    );
  }
  
  /// Creates an event for when a zone's style changes.
  factory PriceZoneEvent.styleChanged(PriceZone zone) {
    return PriceZoneEvent._(
      type: PriceZoneEventType.styleChanged,
      zone: zone,
    );
  }
  
  /// Creates an event for when a zone is updated generically.
  factory PriceZoneEvent.updated(PriceZone zone) {
    return PriceZoneEvent._(
      type: PriceZoneEventType.updated,
      zone: zone,
    );
  }
  
  /// Creates an event for when all zones are cleared.
  factory PriceZoneEvent.cleared() {
    return const PriceZoneEvent._(
      type: PriceZoneEventType.cleared,
    );
  }
  
  @override
  String toString() {
    final buffer = StringBuffer('PriceZoneEvent(');
    buffer.write('type: $type');
    if (zone != null) {
      buffer.write(', zone: ${zone!.id}');
    }
    if (oldMinPrice != null && newMinPrice != null) {
      buffer.write(', range: $oldMinPrice-$oldMaxPrice → $newMinPrice-$newMaxPrice');
    }
    if (oldVisible != null && newVisible != null) {
      buffer.write(', visible: $oldVisible → $newVisible');
    }
    buffer.write(')');
    return buffer.toString();
  }
}

/// Callback type for listening to zone events.
typedef PriceZoneListener = void Function(PriceZoneEvent event);
