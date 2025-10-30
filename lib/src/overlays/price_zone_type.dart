/// Types of price zones.
enum PriceZoneType {
  /// Support zone - area where price tends to bounce up.
  support,
  
  /// Resistance zone - area where price tends to bounce down.
  resistance,
  
  /// Demand zone - area of strong buying interest.
  demand,
  
  /// Supply zone - area of strong selling interest.
  supply,
  
  /// Custom zone - user-defined zone.
  custom,
}

extension PriceZoneTypeExtension on PriceZoneType {
  /// Default label for this zone type.
  String get defaultLabel {
    switch (this) {
      case PriceZoneType.support:
        return 'Support';
      case PriceZoneType.resistance:
        return 'Resistance';
      case PriceZoneType.demand:
        return 'Demand';
      case PriceZoneType.supply:
        return 'Supply';
      case PriceZoneType.custom:
        return 'Zone';
    }
  }
}
