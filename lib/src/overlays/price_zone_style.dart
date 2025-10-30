import 'package:flutter/painting.dart';
import 'price_zone_type.dart';

/// Visual style for a price zone.
class PriceZoneStyle {
  /// Fill color of the zone.
  final Color fillColor;
  
  /// Border color of the zone.
  final Color borderColor;
  
  /// Border width.
  final double borderWidth;
  
  /// Whether to show the border.
  final bool showBorder;
  
  /// Label text style.
  final TextStyle? labelStyle;
  
  const PriceZoneStyle({
    required this.fillColor,
    Color? borderColor,
    this.borderWidth = 1.0,
    this.showBorder = true,
    this.labelStyle,
  }) : borderColor = borderColor ?? fillColor;
  
  /// Creates a style from a zone type with default colors.
  factory PriceZoneStyle.fromType(PriceZoneType type) {
    switch (type) {
      case PriceZoneType.support:
        return PriceZoneStyle(
          fillColor: const Color(0xFF26A69A).withOpacity(0.15),
          borderColor: const Color(0xFF26A69A),
          labelStyle: const TextStyle(
            color: Color(0xFF26A69A),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        );
      case PriceZoneType.resistance:
        return PriceZoneStyle(
          fillColor: const Color(0xFFEF5350).withOpacity(0.15),
          borderColor: const Color(0xFFEF5350),
          labelStyle: const TextStyle(
            color: Color(0xFFEF5350),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        );
      case PriceZoneType.demand:
        return PriceZoneStyle(
          fillColor: const Color(0xFF2196F3).withOpacity(0.15),
          borderColor: const Color(0xFF2196F3),
          labelStyle: const TextStyle(
            color: Color(0xFF2196F3),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        );
      case PriceZoneType.supply:
        return PriceZoneStyle(
          fillColor: const Color(0xFFFF9800).withOpacity(0.15),
          borderColor: const Color(0xFFFF9800),
          labelStyle: const TextStyle(
            color: Color(0xFFFF9800),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        );
      case PriceZoneType.custom:
        return PriceZoneStyle(
          fillColor: const Color(0xFF9E9E9E).withOpacity(0.15),
          borderColor: const Color(0xFF9E9E9E),
          labelStyle: const TextStyle(
            color: Color(0xFF9E9E9E),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        );
    }
  }
  
  PriceZoneStyle copyWith({
    Color? fillColor,
    Color? borderColor,
    double? borderWidth,
    bool? showBorder,
    TextStyle? labelStyle,
  }) {
    return PriceZoneStyle(
      fillColor: fillColor ?? this.fillColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      showBorder: showBorder ?? this.showBorder,
      labelStyle: labelStyle ?? this.labelStyle,
    );
  }
}
