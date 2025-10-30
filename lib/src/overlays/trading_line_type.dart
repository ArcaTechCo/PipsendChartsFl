import 'package:flutter/painting.dart';

/// Types of trading lines available.
enum TradingLineType {
  /// Stop Loss line - typically red, marks the exit point for losses.
  stopLoss,

  /// Take Profit line - typically green, marks the exit point for profits.
  takeProfit,

  /// Entry line - typically blue, marks the entry point for a trade.
  entry,

  /// Alert line - typically orange, triggers a notification at a price level.
  alert,

  /// Support line - typically cyan, marks a support level.
  support,

  /// Resistance line - typically purple, marks a resistance level.
  resistance,

  /// Custom line - user-defined purpose and style.
  custom,
}

/// Extension methods for TradingLineType.
extension TradingLineTypeExtension on TradingLineType {
  /// Gets the default title for this line type.
  String get defaultTitle {
    switch (this) {
      case TradingLineType.stopLoss:
        return 'SL';
      case TradingLineType.takeProfit:
        return 'TP';
      case TradingLineType.entry:
        return 'Entry';
      case TradingLineType.alert:
        return 'Alert';
      case TradingLineType.support:
        return 'Support';
      case TradingLineType.resistance:
        return 'Resistance';
      case TradingLineType.custom:
        return '';
    }
  }

  /// Gets the default color for this line type.
  Color get defaultColor {
    switch (this) {
      case TradingLineType.stopLoss:
        return const Color(0xFFEF5350); // Red
      case TradingLineType.takeProfit:
        return const Color(0xFF26A69A); // Green
      case TradingLineType.entry:
        return const Color(0xFF2196F3); // Blue
      case TradingLineType.alert:
        return const Color(0xFFFF9800); // Orange
      case TradingLineType.support:
        return const Color(0xFF00BCD4); // Cyan
      case TradingLineType.resistance:
        return const Color(0xFF9C27B0); // Purple
      case TradingLineType.custom:
        return const Color(0xFF757575); // Grey
    }
  }

  /// Whether this line type should use a dashed style by default.
  bool get isDashedByDefault {
    return this == TradingLineType.alert;
  }
}
