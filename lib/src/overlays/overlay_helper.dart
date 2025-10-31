/// Helper class to calculate smart initial positions for overlays
class OverlayHelper {
  /// Calculate initial trend line position based on visible viewport
  /// 
  /// Returns a map with:
  /// - startTime: timestamp for start point
  /// - endTime: timestamp for end point
  /// - startPrice: price for start point
  /// - endPrice: price for end point
  /// 
  /// [visibleCandleCount] - number of visible candles
  /// [minPrice] - minimum visible price
  /// [maxPrice] - maximum visible price
  /// [latestTimestamp] - most recent candle timestamp
  /// [candleInterval] - time interval between candles in milliseconds
  /// [widthPercent] - width of line as percentage of visible range (0.0 to 1.0)
  /// [centerPercent] - horizontal position as percentage (0.0 = left, 1.0 = right)
  /// [verticalCenterPercent] - vertical position as percentage (0.0 = bottom, 1.0 = top)
  static Map<String, double> calculateTrendLinePosition({
    required int visibleCandleCount,
    required double minPrice,
    required double maxPrice,
    required int latestTimestamp,
    required int candleInterval,
    double widthPercent = 0.3,
    double centerPercent = 0.5,
    double verticalCenterPercent = 0.5,
  }) {
    // Calculate time range
    final totalTimeRange = visibleCandleCount * candleInterval;
    final lineWidth = (totalTimeRange * widthPercent).toInt();
    final centerTime = latestTimestamp - (totalTimeRange * (1 - centerPercent)).toInt();
    
    final startTime = centerTime - (lineWidth ~/ 2);
    final endTime = centerTime + (lineWidth ~/ 2);
    
    // Calculate price range
    final priceRange = maxPrice - minPrice;
    final centerPrice = minPrice + (priceRange * verticalCenterPercent);
    final priceHeight = priceRange * 0.2; // 20% of visible range
    
    final startPrice = centerPrice + (priceHeight / 2);
    final endPrice = centerPrice - (priceHeight / 2);
    
    return {
      'startTime': startTime.toDouble(),
      'endTime': endTime.toDouble(),
      'startPrice': startPrice,
      'endPrice': endPrice,
    };
  }
  
  /// Calculate initial fibonacci position
  /// 
  /// Returns a map with:
  /// - highPrice: top price
  /// - lowPrice: bottom price
  /// 
  /// [minPrice] - minimum visible price
  /// [maxPrice] - maximum visible price
  /// [heightPercent] - height as percentage of visible range (0.0 to 1.0)
  /// [centerPercent] - vertical position as percentage (0.0 = bottom, 1.0 = top)
  static Map<String, double> calculateFibonacciPosition({
    required double minPrice,
    required double maxPrice,
    double heightPercent = 0.4,
    double centerPercent = 0.5,
  }) {
    final priceRange = maxPrice - minPrice;
    final fibHeight = priceRange * heightPercent;
    final centerPrice = minPrice + (priceRange * centerPercent);
    
    final highPrice = centerPrice + (fibHeight / 2);
    final lowPrice = centerPrice - (fibHeight / 2);
    
    return {
      'highPrice': highPrice,
      'lowPrice': lowPrice,
    };
  }
  
  /// Calculate initial price zone position
  /// 
  /// Returns a map with:
  /// - minPrice: bottom price
  /// - maxPrice: top price
  /// 
  /// [minPrice] - minimum visible price
  /// [maxPrice] - maximum visible price
  /// [heightPercent] - height as percentage of visible range (0.0 to 1.0)
  /// [centerPercent] - vertical position as percentage (0.0 = bottom, 1.0 = top)
  static Map<String, double> calculatePriceZonePosition({
    required double minPrice,
    required double maxPrice,
    double heightPercent = 0.15,
    double centerPercent = 0.5,
  }) {
    final priceRange = maxPrice - minPrice;
    final zoneHeight = priceRange * heightPercent;
    final centerPrice = minPrice + (priceRange * centerPercent);
    
    final zoneMinPrice = centerPrice - (zoneHeight / 2);
    final zoneMaxPrice = centerPrice + (zoneHeight / 2);
    
    return {
      'minPrice': zoneMinPrice,
      'maxPrice': zoneMaxPrice,
    };
  }
  
  /// Calculate initial trading line position
  /// 
  /// [minPrice] - minimum visible price
  /// [maxPrice] - maximum visible price
  /// [centerPercent] - vertical position as percentage (0.0 = bottom, 1.0 = top)
  static double calculateTradingLinePrice({
    required double minPrice,
    required double maxPrice,
    double centerPercent = 0.5,
  }) {
    final priceRange = maxPrice - minPrice;
    return minPrice + (priceRange * centerPercent);
  }
}
