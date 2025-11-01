# Migration Guide: pipsend_charts 1.0.3 → 1.0.4

## 📋 Overview

Version 1.0.4 introduces **optional timestamp anchoring** for overlays, fixing the issue where overlays would "stick" to the viewport when scrolling. This is a **backward-compatible** change.

---

## 🚀 What's New

### 1. **Timestamp Anchoring for Overlays**
Overlays can now be anchored to specific time ranges on the chart.

**Affected Classes:**
- `TradingLine`
- `PriceZone`
- `FibonacciRetracement`

### 2. **Improved Viewport Behavior**
- Overlays now correctly exit the viewport when scrolling
- TrendLine properly disappears when outside visible range
- Indicators render correctly without clipping issues

---

## 🔄 Breaking Changes

**None!** All changes are backward compatible.

---

## 📝 Migration Steps

### Step 1: Update Dependency

In your `pubspec.yaml`:

```yaml
dependencies:
  pipsend_charts: ^1.0.4
```

Then run:
```bash
flutter pub get
```

### Step 2: Update Overlay Creation (Optional)

If you want overlays to be anchored to specific time ranges, add `startTime` and `endTime`:

#### Before (1.0.3):
```dart
TradingLine(
  price: 150.0,
  type: TradingLineType.stopLoss,
  options: TradingLineOptions(
    title: 'Stop Loss',
    draggable: true,
  ),
)
```

#### After (1.0.4):
```dart
TradingLine(
  price: 150.0,
  type: TradingLineType.stopLoss,
  startTime: startTimestamp,  // NEW: Optional
  endTime: endTimestamp,      // NEW: Optional
  options: TradingLineOptions(
    title: 'Stop Loss',
    draggable: true,
  ),
)
```

**Note:** If you don't provide timestamps, overlays will extend infinitely (legacy behavior).

---

## 📚 Examples

### Example 1: Anchored TradingLine

```dart
// Get timestamp range (e.g., last 40% of data)
final startIndex = (candles.length * 0.6).toInt();
final endIndex = candles.length - 1;
final startTime = candles[startIndex].timestamp;
final endTime = candles[endIndex].timestamp;

// Create anchored trading line
final tradingLine = TradingLine(
  price: 150.0,
  type: TradingLineType.entry,
  startTime: startTime,  // Anchor to specific time range
  endTime: endTime,
  options: TradingLineOptions(
    title: 'Entry',
    showPrice: true,
    draggable: true,
  ),
);
```

### Example 2: Anchored PriceZone

```dart
final priceZone = PriceZone(
  minPrice: 140.0,
  maxPrice: 145.0,
  type: PriceZoneType.demand,
  startTime: startTime,  // Anchor to specific time range
  endTime: endTime,
  options: PriceZoneOptions(
    label: 'Demand Zone',
    showLabel: true,
    draggable: true,
  ),
);
```

### Example 3: Anchored Fibonacci

```dart
final fibonacci = FibonacciRetracement(
  highPrice: 160.0,
  lowPrice: 140.0,
  startTime: startTime,  // Anchor to specific time range
  endTime: endTime,
  options: FibonacciOptions(
    showLabels: true,
    showPercentages: true,
    draggable: true,
  ),
);
```

### Example 4: Infinite Overlay (Legacy Behavior)

```dart
// Don't provide timestamps for infinite overlays
final tradingLine = TradingLine(
  price: 150.0,
  type: TradingLineType.stopLoss,
  // No startTime/endTime = extends infinitely
  options: TradingLineOptions(
    title: 'Stop Loss',
    draggable: true,
  ),
);
```

---

## 🎯 Recommended Usage

### For User-Drawn Overlays
When users draw overlays on the chart, automatically assign timestamps:

```dart
void onOverlayCreated(Offset position) {
  // Get visible candle range
  final visibleCandles = getVisibleCandles();
  final startTime = visibleCandles.first.timestamp;
  final endTime = visibleCandles.last.timestamp;
  
  // Create anchored overlay
  final overlay = TradingLine(
    price: getPriceFromY(position.dy),
    type: TradingLineType.entry,
    startTime: startTime,
    endTime: endTime,
    options: TradingLineOptions(
      draggable: true,
    ),
  );
  
  overlayManager.addLine(overlay);
}
```

### For Global Overlays
For overlays that should always be visible (like global stop loss), don't provide timestamps:

```dart
final globalStopLoss = TradingLine(
  price: 100.0,
  type: TradingLineType.stopLoss,
  // No timestamps = always visible
  options: TradingLineOptions(
    title: 'Global SL',
    draggable: true,
  ),
);
```

---

## 🐛 Bug Fixes Included

### 1. Fixed Fibonacci/PriceZone Drag Issues
- Overlays no longer become gigantic when dragged
- Smooth and predictable movement

### 2. Fixed Overlay Resize
- Dynamic minimum height based on visible price range (0.1%)
- Works correctly with any instrument (forex, crypto, stocks)

### 3. Fixed Viewport Positioning
- Overlays stay anchored to chart positions
- Correctly exit viewport when scrolling
- No more "sticking" to viewport edges

### 4. Fixed Indicator Clipping
- Indicators (ATR, RSI, etc.) no longer cut off on edges
- Proper rendering at all zoom levels

---

## ⚙️ Technical Changes

### ChartPainter
- Overlays now drawn within translated canvas context
- Adjusted clipRect for proper rendering
- Added padding to prevent edge clipping

### Overlay Classes
- Added optional `startTime` and `endTime` fields
- Updated `paint()` methods to use timestamps
- Added visibility checks for viewport optimization

### Indicators
- Fixed coordinate calculations for zoom compatibility
- Removed double-translation issues
- Added timestamp-based indexing for SMA/EMA

---

## 🔍 Testing Checklist

After migrating, test the following:

- [ ] Overlays stay in correct positions when scrolling
- [ ] Overlays exit viewport correctly
- [ ] Drag and resize work smoothly
- [ ] Indicators render without clipping
- [ ] Zoom in/out works correctly
- [ ] Legacy overlays (without timestamps) still work

---

## 📞 Support

If you encounter any issues:

1. Check the [CHANGELOG.md](CHANGELOG.md) for known issues
2. Review the [example app](example/) for reference implementation
3. Open an issue on GitHub with reproduction steps

---

## 🎉 Summary

Version 1.0.4 is a **major improvement** for overlay positioning and rendering:

✅ **Backward Compatible** - No breaking changes  
✅ **Optional Feature** - Timestamps are optional  
✅ **Bug Fixes** - Multiple critical fixes included  
✅ **Better UX** - Overlays behave as expected  

**Recommendation:** Update all user-drawn overlays to use timestamps for the best experience.
