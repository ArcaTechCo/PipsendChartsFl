import 'dart:math';

/// Utility class for calculating technical indicators.
///
/// Provides common calculations used by multiple indicators:
/// - Moving averages (SMA, EMA)
/// - Standard deviation
/// - RSI
/// - And more...
class IndicatorCalculator {
  IndicatorCalculator._(); // Private constructor - static class

  /// Calculates Simple Moving Average (SMA).
  ///
  /// [data] is the input data series.
  /// [period] is the number of periods to average.
  ///
  /// Returns a list of the same length as [data], with nulls for
  /// the first [period-1] values.
  static List<double?> sma(List<double?> data, int period) {
    if (data.length < period) {
      return List.filled(data.length, null);
    }

    final result = <double?>[];

    // Fill initial values with null
    for (int i = 0; i < period - 1; i++) {
      result.add(null);
    }

    // Calculate SMA for remaining values
    for (int i = period - 1; i < data.length; i++) {
      double sum = 0;
      int count = 0;

      for (int j = 0; j < period; j++) {
        final value = data[i - j];
        if (value != null) {
          sum += value;
          count++;
        }
      }

      result.add(count == period ? sum / period : null);
    }

    return result;
  }

  /// Calculates Exponential Moving Average (EMA).
  ///
  /// [data] is the input data series.
  /// [period] is the number of periods for the EMA.
  ///
  /// EMA gives more weight to recent values.
  static List<double?> ema(List<double?> data, int period) {
    if (data.length < period) {
      return List.filled(data.length, null);
    }

    final result = <double?>[];
    final multiplier = 2.0 / (period + 1);

    // Calculate initial SMA
    double sum = 0;
    int count = 0;
    for (int i = 0; i < period; i++) {
      result.add(null);
      final value = data[i];
      if (value != null) {
        sum += value;
        count++;
      }
    }

    if (count == 0) return result;

    double ema = sum / count;
    result[period - 1] = ema;

    // Calculate EMA for remaining values
    for (int i = period; i < data.length; i++) {
      final value = data[i];
      if (value != null) {
        ema = (value - ema) * multiplier + ema;
        result.add(ema);
      } else {
        result.add(null);
      }
    }

    return result;
  }

  /// Calculates Weighted Moving Average (WMA).
  ///
  /// [data] is the input data series.
  /// [period] is the number of periods to average.
  ///
  /// WMA assigns linearly decreasing weights to older values.
  /// Most recent value has weight = period, second most recent = period-1, etc.
  ///
  /// Returns a list of the same length as [data], with nulls for
  /// the first [period-1] values.
  static List<double?> wma(List<double?> data, int period) {
    if (data.length < period) {
      return List.filled(data.length, null);
    }

    final result = <double?>[];

    // Fill initial values with null
    for (int i = 0; i < period - 1; i++) {
      result.add(null);
    }

    // Calculate WMA for remaining values
    // Weight sum = period * (period + 1) / 2
    final weightSum = period * (period + 1) / 2;

    for (int i = period - 1; i < data.length; i++) {
      double weightedSum = 0;
      int validCount = 0;

      for (int j = 0; j < period; j++) {
        final value = data[i - j];
        if (value != null) {
          // Weight decreases linearly: most recent gets highest weight
          final weight = period - j;
          weightedSum += value * weight;
          validCount++;
        }
      }

      // Only calculate if we have all values in the period
      result.add(validCount == period ? weightedSum / weightSum : null);
    }

    return result;
  }

  /// Calculates standard deviation for a list of values.
  ///
  /// Returns 0 if the list is empty or has only one element.
  static double stdDev(List<double> data) {
    if (data.isEmpty || data.length == 1) return 0.0;

    final mean = data.reduce((a, b) => a + b) / data.length;
    final variance = data
        .map((value) => pow(value - mean, 2))
        .reduce((a, b) => a + b) / data.length;

    return sqrt(variance);
  }

  /// Calculates Relative Strength Index (RSI).
  ///
  /// [prices] is the input price series.
  /// [period] is the number of periods (typically 14).
  ///
  /// RSI ranges from 0 to 100.
  /// - Above 70: Overbought
  /// - Below 30: Oversold
  static List<double?> rsi(List<double?> prices, int period) {
    if (prices.length < period + 1) {
      return List.filled(prices.length, null);
    }

    final result = <double?>[];
    final gains = <double>[];
    final losses = <double>[];

    // Calculate price changes
    for (int i = 0; i < prices.length; i++) {
      if (i == 0) {
        result.add(null);
        continue;
      }

      final prev = prices[i - 1];
      final curr = prices[i];

      if (prev == null || curr == null) {
        result.add(null);
        continue;
      }

      final change = curr - prev;
      gains.add(change > 0 ? change : 0);
      losses.add(change < 0 ? -change : 0);

      if (gains.length < period) {
        result.add(null);
        continue;
      }

      // Calculate average gain and loss
      final avgGain = gains.sublist(gains.length - period).reduce((a, b) => a + b) / period;
      final avgLoss = losses.sublist(losses.length - period).reduce((a, b) => a + b) / period;

      if (avgLoss == 0) {
        result.add(100.0);
      } else {
        final rs = avgGain / avgLoss;
        final rsi = 100 - (100 / (1 + rs));
        result.add(rsi);
      }
    }

    return result;
  }

  /// Calculates Bollinger Bands.
  ///
  /// [prices] is the input price series.
  /// [period] is the number of periods for the moving average.
  /// [stdDev] is the number of standard deviations for the bands.
  ///
  /// Returns a map with 'upper', 'middle', and 'lower' bands.
  static Map<String, List<double?>> bollingerBands(
    List<double?> prices,
    int period,
    double stdDevMultiplier,
  ) {
    final middle = sma(prices, period);
    final upper = <double?>[];
    final lower = <double?>[];

    for (int i = 0; i < prices.length; i++) {
      if (i < period - 1 || middle[i] == null) {
        upper.add(null);
        lower.add(null);
        continue;
      }

      // Get the last 'period' values
      final slice = <double>[];
      for (int j = 0; j < period; j++) {
        final value = prices[i - j];
        if (value != null) {
          slice.add(value);
        }
      }

      if (slice.length < period) {
        upper.add(null);
        lower.add(null);
        continue;
      }

      final std = stdDev(slice);
      final mid = middle[i]!;

      upper.add(mid + (stdDevMultiplier * std));
      lower.add(mid - (stdDevMultiplier * std));
    }

    return {
      'upper': upper,
      'middle': middle,
      'lower': lower,
    };
  }

  /// Calculates MACD (Moving Average Convergence Divergence).
  ///
  /// [prices] is the input price series.
  /// [fastPeriod] is typically 12.
  /// [slowPeriod] is typically 26.
  /// [signalPeriod] is typically 9.
  ///
  /// Returns a map with 'macd', 'signal', and 'histogram' values.
  static Map<String, List<double?>> macd(
    List<double?> prices,
    int fastPeriod,
    int slowPeriod,
    int signalPeriod,
  ) {
    final fastEma = ema(prices, fastPeriod);
    final slowEma = ema(prices, slowPeriod);

    // Calculate MACD line
    final macdLine = <double?>[];
    for (int i = 0; i < prices.length; i++) {
      if (fastEma[i] == null || slowEma[i] == null) {
        macdLine.add(null);
      } else {
        macdLine.add(fastEma[i]! - slowEma[i]!);
      }
    }

    // Calculate signal line (EMA of MACD)
    final signalLine = ema(macdLine, signalPeriod);

    // Calculate histogram
    final histogram = <double?>[];
    for (int i = 0; i < prices.length; i++) {
      if (macdLine[i] == null || signalLine[i] == null) {
        histogram.add(null);
      } else {
        histogram.add(macdLine[i]! - signalLine[i]!);
      }
    }

    return {
      'macd': macdLine,
      'signal': signalLine,
      'histogram': histogram,
    };
  }

  /// Calculates Stochastic Oscillator.
  ///
  /// [highs] is the high price series.
  /// [lows] is the low price series.
  /// [closes] is the close price series.
  /// [period] is typically 14.
  /// [smoothK] is typically 3.
  /// [smoothD] is typically 3.
  ///
  /// Returns a map with '%K' and '%D' values.
  static Map<String, List<double?>> stochastic(
    List<double?> highs,
    List<double?> lows,
    List<double?> closes,
    int period,
    int smoothK,
    int smoothD,
  ) {
    final rawK = <double?>[];

    for (int i = 0; i < closes.length; i++) {
      if (i < period - 1) {
        rawK.add(null);
        continue;
      }

      // Find highest high and lowest low in period
      double? highestHigh;
      double? lowestLow;

      for (int j = 0; j < period; j++) {
        final high = highs[i - j];
        final low = lows[i - j];

        if (high != null) {
          highestHigh = highestHigh == null ? high : max(highestHigh, high);
        }
        if (low != null) {
          lowestLow = lowestLow == null ? low : min(lowestLow, low);
        }
      }

      final close = closes[i];
      if (close == null || highestHigh == null || lowestLow == null) {
        rawK.add(null);
        continue;
      }

      final range = highestHigh - lowestLow;
      if (range == 0) {
        rawK.add(50.0);
      } else {
        rawK.add(((close - lowestLow) / range) * 100);
      }
    }

    // Smooth %K
    final percentK = sma(rawK, smoothK);

    // Calculate %D (SMA of %K)
    final percentD = sma(percentK, smoothD);

    return {
      '%K': percentK,
      '%D': percentD,
    };
  }
}
