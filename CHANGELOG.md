## 1.7.0

**Chart Types: Bars, Line & Heikin Ashi**

### Chart types
* **`ChartType`** (`candlestick`, `bar`, `line`, `heikinAshi`) — new enum selecting how the main price series is rendered.
* **`ChartStyle.chartType`** — defaults to `ChartType.candlestick`, so existing charts are unchanged.
* **`ChartType.bar`** — OHLC bars: a vertical high/low line with a left tick at the open and a right tick at the close.
* **`ChartType.line`** — a single close-price path. While active, the price axis is bounded by the closes instead of the highs/lows, so the line fills the panel instead of sitting squashed in the middle.
* **`ChartStyle.lineColor` / `ChartStyle.lineWidth`** — styling for the line series. `lineColor` falls back to `priceGainColor`.

### Heikin Ashi
* **`CandleData.toHeikinAshi(List<CandleData>)`** — converts a full series to Heikin Ashi. The HA open is recursive, so it must always run over the whole series; candles missing `open`/`close` pass through untouched and reset the recursion.
* **`ChartType.heikinAshi`** — `InteractiveChart` derives the smoothed series internally (cached, recomputed only when the source list changes). Because the transform happens before measuring and painting, indicators, the price axis and the crosshair OHLC panel all report Heikin Ashi values, matching TradingView's behaviour.
* Overlays (trading lines, zones, Fibonacci, …) keep their real prices, so they sit on the Heikin Ashi axis rather than on the original candles — the same trade-off every platform makes.

### Backwards Compatibility
* All changes are additive. `ChartStyle.chartType` defaults to `candlestick`, so charts written for 1.6.0 render identically.

---

## 1.6.0

**Tap-to-Select Drawings, Crosshair Beyond the Data & Fractals Indicator**

### Overlay selection (TradingView-style)
* **`InteractiveChart.onOverlayTapped`** (`ValueChanged<ChartOverlay?>`) — fires with the tapped interactive overlay when the user taps one without dragging, and with `null` when tapping empty chart space. Lets the host build tap-to-select + quick actions (delete, edit, …).
* **`InteractiveChart.selectedOverlayId`** — id of the currently selected overlay; the painter highlights it with an emphasized border and corner handles.
* **`InteractiveChart.onSelectedOverlayRectChanged`** (`ValueChanged<Rect?>`) — reports the selected overlay's local bounding rect, updated as the chart pans/zooms, so the host can keep a floating toolbar glued to it.
* **`ChartOverlay.selectionBounds(params)`** — new overridable method returning the overlay's content-space bounds. Implemented for price zones, trend lines, Fibonacci (retracement / extension / fan), arrows, rulers, circles, gantt, text, vertical lines and position tools. **`PriceZone.boundingRect(params)`** is also exposed.

### Crosshair
* **Works beyond the first/last candle** — the crosshair (and its price/time labels) now follows the finger into the empty space past the data instead of disappearing; the time label is extrapolated from the average candle spacing. The OHLC info panel is only shown while over a real candle.

### Indicators
* **`FractalsIndicator`** — Bill Williams fractals (up/down markers), with `FractalsStyle`.

### Backwards Compatibility
* All changes are additive. New parameters default to `null`, so charts written for 1.5.0 behave exactly the same.

---

## 1.5.0

**Always-On Crosshair, Drawing Placement Mode & Price-Axis Scaling**

### Crosshair
* **Always visible in persistent mode** — when `persistentCrosshair` is on, the crosshair now shows from the start at a resting position (no first tap needed).
* **Relative drag** — dragging moves the crosshair by the finger's delta from its current position, instead of teleporting to the touch point.
* **Highlighted date label** on the bottom (time) axis, mirroring the price label on the right — so the crosshair always shows both "when" and "at what price", TradingView-style.
* **`InteractiveChart.crosshairTimeLabel`** (`CrosshairTimeLabelGetter`) — formats the crosshair's date/time readout. Defaults to a locale-aware `"EEE d MMM yy · HH:mm"`.
* **`ChartStyle.crosshairLabelColor`** — background color of the crosshair price/date axis labels. Defaults to an opaque version of `selectionHighlightColor`; label text auto-contrasts (black/white) for readability.
* In persistent mode the floating OHLC info panel is hidden — only the lines and axis labels are drawn.
* Fixed: the dashed crosshair line and the date label now align to the candle center.

### Long-press toggle
* **`InteractiveChart.onCrosshairActiveChanged`** — a long-press on empty chart area toggles the crosshair on/off (the host reflects the requested state back via `persistentCrosshair`). Detected without competing with overlay resize/drag gestures.

### Drawing placement mode (TradingView-style)
* **`InteractiveChart.placement`** (`DrawingPlacement`) + **`onPlacementComplete`** (`List<PlacementPoint>`) — enter a placement session: an interactive blue crosshair with a center dot is shown, the user places `pointCount` points (tap or drag-release each) with a live preview, and the confirmed points (price + timestamp) are returned so the host builds the real drawing.
* New types: **`DrawingPlacement`** (`pointCount`, `preview`, `color`), **`PlacementPoint`** (`price`, `timestamp`, `localPosition`), **`PlacementPreviewShape`** (`none` / `rectangle` / `line`).

### Price-axis Y scaling
* **Drag on the price scale** (right gutter) with one finger to scale the Y axis (zoom the price range).
* **Double-tap the price scale** to reset to auto-fit.
* The vertical zoom now applies whenever it has been changed (not only when `enableVerticalPan` is enabled), so price-axis scaling works standalone.

### Price labels
* Denser adaptive price labels (~55px per label, up to 20; was ~80px, max 10). `ChartStyle.priceLabelCount` range is now 3–20.

### Backwards Compatibility
* All changes are additive. New parameters default to `null`/`false`, so charts written for 1.4.0 behave exactly the same.

---

## 1.4.0

**Replay Mode — Playhead, Tick Progress & Programmatic Seeking**

### New Features
* **`InteractiveChart.playheadIndex`** — when non-null the chart enters replay mode: candles past this index are not drawn, indicators still calculate over the full series (cache stable), and the visible range / `XAxisOffsetDetails.totalCandles` use `playheadIndex + 1` as the effective length.
* **`InteractiveChart.playheadTickProgress`** — sub-candle progress in `[0.0, 1.0]`. The candle at the playhead is replaced visually by `CandleData.buildPartial` and animated smoothly via the painter tween.
* **`InteractiveChart.playheadStyle`** (`PlayheadStyle`) — visual configuration for the built-in playhead: line color/width/dash, optional date label, optional translucent dim on the right side, drag handles, and configurable hit radius. When `null` the playhead is not rendered (host can still draw it as an overlay).
* **`InteractiveChart.onPlayheadChanged`** — fired with `PlayheadInfo` (candle index + canonical timestamp + interpolated timestamp) when the user drags the built-in playhead.
* **`InteractiveChartController.seekToIndex(int)`** — center the visible range on the given candle index.
* **`InteractiveChartController.seekToTimestamp(int)`** — same, by timestamp.
* **`InteractiveChartController.setVisibleCandleCount(int)`** — programmatically zoom the chart.
* **`CandleData.buildPartial(real, progress)`** — helper that returns an interpolated candle for tick-replay (open is fixed, close lerps to real close, wicks grow with progress).
* **`PainterParams.fullCandles`** — when set, indicators compute over this list instead of `candles` (the visible sublist). Set automatically by `InteractiveChart` when in replay mode.

### Replay UX
* Built-in single-finger drag on the playhead is consumed before pan/zoom/overlay drags. Pinch gestures (`pointerCount > 1`) pass through to zoom unaffected.
* `PlayheadStyle.dimRightSide` overlays a translucent rectangle from the playhead to the right edge, communicating that the future is hidden.

### Backwards Compatibility
* All changes are additive. Charts without the new props behave exactly as in 1.3.0.
* `InteractiveChartController.attach(...)` switched to named parameters. Old code that passed a positional `jumpToLatest` callback must update — this is the only breaking change to the public API.

---

## 1.3.0

**Persistent Crosshair, Dashed Style & Tap-to-Select on Non-Draggable Lines**

### New Features
* **`InteractiveChart.persistentCrosshair`** — when `true`, the crosshair (tap highlight + price line + OHLC info) stays visible after the user lifts their finger, until they tap somewhere else or the flag is toggled off. Default: `false` (legacy behavior — crosshair disappears on tap-up).
* **`ChartStyle.crosshairDashed`** — when `true`, renders the crosshair as thin dashed lines on both axes (TradingView-style) instead of the wide vertical highlight bar plus solid horizontal price line. Default: `false`.

### Improvements
* **`TradingLine` hit testing** — non-draggable lines that supply an `onTap` callback now participate in hit testing. Previously, only `draggable: true` lines were interactive, so entry lines (typically non-draggable) couldn't be selected by tapping. Now any line with either `draggable` or `onTap` is hit-tested.

### Bug Fixes
* Removed stray `print('$id: not interactive')` from `TradingLine.hitTest`.

### Backwards Compatibility
* All changes are additive. Existing code continues to work without modification.

---

## 1.2.0

**Serialization, Sync API & Free Movement for All Drawing Tools**

### Breaking Changes
* **`FibonacciOptions.onMoved`** signature changed: `(double, double)` → `(double, double, int?, int?)` — now includes `startTime` and `endTime` for horizontal movement
* **`PriceZoneOptions.onRangeChanged`** signature changed: `(double, double)` → `(double, double, int?, int?)` — now includes `startTime` and `endTime`
* **`TapDetails.candle`** is now nullable (`CandleData?`) — returns `null` when tapping in future (empty) space

### Serialization & Sync API
* **`toJson()` / `fromJson()`** on all 14 overlay classes and their style/options: `TradingLine`, `PriceZone`, `FibonacciRetracement`, `FibonacciExtension`, `FibonacciFan`, `TrendLine`, `VerticalLine`, `TextTool`, `BrushTool`, `ArrowTool`, `CircleTool`, `RulerTool`, `GanttTool`, `PositionTool`
* **`serializeAll()` / `restoreAll()`** on all managers: `TradingLineManager`, `PriceZoneManager`, `FibonacciManager`, `TrendLineManager`
* **New `ChartDrawingManager`** — unified manager combining all drawing types with single `serializeAll()` / `restoreAll()` for complete chart state
* **`DrawingChangeCallback`** — unified callback for real-time sync between devices (`onDrawingChanged`)

### Free Movement & Corner Handles
* **Fibonacci Retracement** — now supports full 2D drag (X + Y), with top-left and bottom-right corner handles for resizing both price range and time range simultaneously
* **Price Zones (Demand/Supply)** — same corner-handle system as Fibonacci, with full 2D movement and resizing
* **`FibonacciManager.updateFibonacciRange()`** now accepts optional `startTime`/`endTime`
* **`PriceZoneManager.updateZoneRange()`** now accepts optional `startTime`/`endTime`

### Future Space (Drawing Beyond Last Candle)
* **New `futureCandles` parameter** on `InteractiveChart` — adds scrollable empty space to the right of the last candle (like TradingView)
* **`TapDetails.timestamp`** — extrapolated timestamp available for all taps, including future space
* **`TapDetails.isFutureSpace`** — boolean to detect taps in empty area
* All drawing tools can now be dragged and dropped into future space

### Rendering Improvements
* **`PainterParams.fitTimestamp()`** — converts any timestamp to X coordinate with interpolation/extrapolation for positions between or beyond loaded candles
* **`PainterParams.getTimestampFromX()`** — reverse conversion, X coordinate to extrapolated timestamp
* All time-based drawing tools now render after `restoreAll()` even when candle data doesn't include the exact timestamps (Brush, Arrow, Text, VerticalLine, Circle, Ruler, Gantt, FibonacciExtension, FibonacciFan, TrendLine)
* Drag previews now render correctly in future space for all tools

### Bug Fixes
* Fixed volume warning (`volumeHeightFactor`) printing 188k+ times — now prints only once

---

## 1.1.8

**🎯 TradingLine Style Improvements**

### 🔧 Enhancements
* **Exposed labelPadding parameters** in `TradingLineStyle`:
  * `labelHorizontalPadding` - Horizontal padding for the label (default: 2)
  * `labelVerticalPadding` - Vertical gap between label and line (default: 1)
* **Reduced default values** for a more compact appearance:
  * `lineWidth`: 1.5 → 1.0
  * `labelFontSize`: 12 → 10
  * `priceFontSize`: 11 → 10
  * `labelHorizontalPadding`: 4 → 2
  * `labelVerticalPadding`: 2 → 1

---

## 1.1.7

**🎨 Complete Drawing Tools Suite - 26 Professional Tools**

### 🚀 Major Features

#### 14 Advanced Drawing Tools
* **Complete Tool Suite** - Added 11 new professional drawing tools:
  * **WMA Indicator** - Weighted Moving Average with linear weights
  * **Volume Profile** - Distribution of volume by price level with POC
  * **Trading Sessions** - Highlight Asian, European, and American sessions
  * **Fibonacci Extension** - 3-point projection with independent drag (A, B, C points)
  * **Fibonacci Fan** - Radial Fibonacci lines from pivot point
  * **Position Tool** - Visualize trades with Entry, SL, and TP lines (independent drag)
  * **Ruler Tool** - Measure price/time distance with statistics display
  * **Vertical Line** - Mark temporal events on the chart
  * **Arrow Tool** - Directional arrows for annotations with customizable arrowheads
  * **Circle Tool** - Highlight areas with resizable circles/ellipses
  * **Text Tool** - Add text annotations with double-tap editing
  * **Brush Tool** - Freehand drawing visualization with smooth curves
  * **Gantt Tool** - Time period bars with labels and resize handles

#### Full Drag & Drop Support
* **Interactive Overlays** - All 14 drawing tools support drag & drop:
  * Real-time preview during drag operation
  * Visual feedback with enhanced appearance
  * Callbacks for position updates (`onMoved`)
  * Handle-based resize for multi-point tools
  * Independent handle drag for complex tools
* **Smart Handle Detection** - Precise hit testing:
  * Separate detection for start/end handles
  * Center and radius handles for circles
  * Multi-point handles for Fibonacci tools
  * Entry, SL, TP handles for Position Tool
* **Preview System** - Live visual feedback:
  * ChartPainter renders preview during drag
  * Updated positions calculated in real-time
  * Smooth transitions and visual indicators

#### Text Tool with Inline Editing
* **Double-Tap Editing** - Interactive text editing:
  * Double-tap detection (< 300ms, < 20px distance)
  * Dialog-based text editor with TextField
  * Auto-focus and Enter key support
  * Cancel and Save buttons
  * Real-time text updates
* **Rich Styling** - Comprehensive text customization:
  * Font size, color, weight, and style
  * Background with padding and border radius
  * Border with customizable color and width
  * Horizontal and vertical alignment (3x3 grid)
  * Optional background and border display

#### Advanced Fibonacci Tools
* **Fibonacci Extension** - 3-point projection tool:
  * Points A, B, C with independent drag
  * Extension levels: 0%, 38.2%, 61.8%, 100%, 127.2%, 161.8%, 200%, 261.8%
  * Customizable colors and labels
  * Hit testing for all three points
* **Fibonacci Fan** - Radial trend lines:
  * Start and end points with drag support
  * Fan levels: 38.2%, 50%, 61.8%
  * Extends to chart boundaries
  * Customizable line styles

#### Position & Ruler Tools
* **Position Tool** - Complete trade visualization:
  * Entry, Stop Loss, and Take Profit lines
  * Long and Short position types
  * Independent drag for each line
  * Color-coded by position type
  * Labels with prices
* **Ruler Tool** - Measurement tool:
  * Measures price difference and percentage
  * Shows number of candles and time elapsed
  * Draggable start and end handles
  * Statistics display with formatting

#### Shape Tools
* **Arrow Tool** - Directional annotations:
  * Start and end points with drag
  * Customizable arrowhead size
  * Filled or outline style
  * Color and stroke width options
* **Circle Tool** - Area highlighting:
  * Center point and radius drag
  * Separate resize handle for radius
  * Filled or outline style
  * Ellipse support (different X/Y radius)

#### Gantt & Brush Tools
* **Gantt Tool** - Time period visualization:
  * Start and end time with resize handles
  * Price level positioning
  * Customizable height
  * Labels with background
  * Fill color and opacity
* **Brush Tool** - Freehand annotations:
  * Multiple points with smooth curves
  * Bezier curve rendering
  * Customizable stroke width and color
  * Hit testing on line segments
  * Visualization of predefined strokes

### 📚 Documentation
* **INTEGRATION_GUIDE.md** - Complete integration guide:
  * All 26 tools documented with examples
  * Installation and setup instructions
  * Code examples for each tool
  * Customization options
  * Best practices and troubleshooting
  * Gesture support documentation
* **Updated README.md** - Enhanced feature list:
  * Complete list of 12 indicators
  * Complete list of 14 drawing tools
  * Updated installation instructions
  * Feature highlights

### 🎨 UI/UX Improvements
* **Enhanced Example App** - Updated tabbed example:
  * Drawing Tools tab now includes all 14 tools
  * FAB buttons for each tool type
  * Color-coded buttons (blue, green, orange, purple)
  * Clear buttons for each tool category
  * Snackbar notifications with usage hints
* **Interactive Demos** - Working examples for all tools:
  * Text Tool with double-tap editing demo
  * Fibonacci Extension with 3-point drag
  * Position Tool with independent line drag
  * Ruler Tool with statistics display
  * All tools with visual feedback

### 🔧 Technical Details
* **InteractiveChart Enhancements**:
  - Added drag state flags for all new tools
  - Implemented handle detection in `onTapDown` and `onScaleStart`
  - Added drag end logic in `_onOverlayDragEnd` for all tools
  - Double-tap detection system for text editing
  - Cleanup of drag flags in `setState`
* **ChartPainter Enhancements**:
  - Added preview rendering for all new tools
  - Drag state parameters passed from InteractiveChart
  - Real-time position updates during drag
  - Enhanced visual feedback (thicker lines, opacity)
* **Overlay Classes**:
  - All tools extend `ChartOverlay` base class
  - Implement `paint()`, `hitTest()`, and `copyWith()` methods
  - Options classes with `draggable` flag and callbacks
  - Style classes for visual customization
  - ID-based identification for state management

### 💥 Breaking Changes
* None - Fully backward compatible with 1.0.7
* All new features are additive
* Existing overlays continue to work unchanged

### 📊 Statistics
* **Total Tools:** 26 (12 indicators + 14 drawing tools)
* **Interactive Tools:** 14 (all with drag & drop)
* **New Files Created:** 9 (tool implementations + guide)
* **Lines of Code Added:** ~3,500+
* **Documentation Pages:** 2 (INTEGRATION_GUIDE.md + updates)

### 🎯 Use Cases
* **Technical Analysis** - Complete suite of drawing tools
* **Trade Planning** - Position Tool for trade visualization
* **Pattern Recognition** - Fibonacci tools for projections
* **Annotations** - Text, Arrow, and Circle tools
* **Time Analysis** - Gantt Tool for period visualization
* **Measurements** - Ruler Tool for precise calculations

---

## 1.0.7

**🎯 Real-time Drag Events for Trading Lines**

### 🚀 New Features

#### Trading Line Drag Events
* **Real-time Drag Callback** - New `onPriceDragging` callback for TradingLine:
  * Fires continuously while dragging a trading line
  * Provides real-time price updates during drag operation
  * Perfect for live price validation, UI updates, or calculations
  * Complements existing `onPriceChanged` callback (fires once on drag end)
* **Enhanced User Experience** - Enables responsive feedback:
  * Update UI elements in real-time as user drags
  * Show live calculations (P&L, risk/reward, etc.)
  * Validate price levels during drag
  * Display dynamic tooltips or overlays

### 📝 Example Usage

```dart
TradingLine(
  price: 150.0,
  type: TradingLineType.takeProfit,
  options: TradingLineOptions(
    draggable: true,
    // Called continuously while dragging
    onPriceDragging: (newPrice) {
      print('Dragging to: $newPrice');
      // Update UI, show calculations, etc.
    },
    // Called once when drag ends
    onPriceChanged: (finalPrice) {
      print('Final price: $finalPrice');
      // Save to database, update state, etc.
    },
  ),
)
```

### 🔧 Technical Details
* Added `onPriceDragging` callback to `TradingLineOptions`
* Updated `_onOverlayDrag()` in `InteractiveChart` to call callback during drag
* Maintains backward compatibility - callback is optional
* No performance impact - callback only fires when line is being dragged

### 💥 Breaking Changes
* None - Fully backward compatible with 1.0.6

---

## 1.0.6

**📊 Grid Configurable, Labels Adaptativos & Infinite History**

### 🚀 New Features

#### Grid Configurable
* **Full Grid Control** - Complete customization of chart grid lines:
  * **Horizontal Grid** - Price level grid lines
  * **Vertical Grid** - Time interval grid lines
  * Independent control for each type (show/hide, style, color, width)
* **4 Line Styles** - Visual variety for grid lines:
  * `solid` - Continuous lines (─────────)
  * `dashed` - Dashed lines (─ ─ ─ ─ ─)
  * `dotted` - Dotted lines (· · · · ·)
  * `longDashed` - Long dashed lines (── ── ──)
* **Customizable Appearance**:
  * `horizontalStrokeWidth` / `verticalStrokeWidth` - Line thickness (0.1-3.0)
  * `horizontalGridColor` / `verticalGridColor` - Independent colors with opacity control
  * Default: Grey with 30% opacity (visible on light and dark backgrounds)
* **6 Built-in Presets**:
  * `GridStyle.none` - No grid lines
  * `GridStyle.horizontalOnly` - Only horizontal (default)
  * `GridStyle.full` - Both horizontal and vertical
  * `GridStyle.subtle` - Low opacity grid (10%)
  * `GridStyle.dashed` - Dashed style grid
  * `GridStyle.dotted` - Dotted style grid
* **Always Aligned** - Grid lines automatically align with price and time labels

#### Adaptive Labels
* **Smart Label Calculation** - Labels automatically adjust based on chart size:
  * **Price Labels** - Adapt to chart height (3-10 labels)
    - Formula: ~80px per label
    - Small screens (300px) → 4 labels
    - Large screens (800px) → 10 labels
  * **Time Labels** - Adapt to chart width
    - Default: One label every 90 pixels
    - Configurable density (60-120px)
* **Manual Override Available**:
  * `priceLabelCount` - Force specific number of price labels (3-10)
  * `timeLabelDensity` - Force specific spacing for time labels (60-120px)
  * `adaptiveLabels` - Toggle adaptive behavior (default: true)
* **Grid Synchronization** - Grid lines always align with labels
* **Backward Compatible** - Enabled by default, improves readability automatically

#### Infinite History / Lazy Loading
* **Dynamic Data Loading** - Load historical data on-demand as users scroll:
  * Similar to TradingView's Lightweight Charts "Infinite History" feature
  * Detect when user scrolls near the beginning or end of data
  * Load more data without losing visual position
  * Perfect for large datasets and real-time applications
* **Enhanced XAxisOffsetDetails** - New properties for lazy loading:
  * `candlesBeforeVisible` - Number of candles before the visible area
  * `candlesAfterVisible` - Number of candles after the visible area
  * `isNearStart([threshold])` - Check if near start with configurable threshold (default: 50)
  * `isNearEnd([threshold])` - Check if near end with configurable threshold (default: 50)
* **Automatic Position Maintenance** - Chart preserves visual position when prepending data:
  * Existing logic (lines 284-290 in `interactive_chart.dart`) automatically adjusts offset
  * Seamless user experience when loading historical data
  * No jumps or visual artifacts
* **Bidirectional Loading** - Support for loading both historical and recent data:
  * Load older data when scrolling left
  * Load newer data when scrolling right
  * Configurable thresholds for each direction

### 📚 Documentation
* **Comprehensive README Section** - Complete guide for Infinite History:
  * Basic implementation example
  * XAxisOffsetDetails properties reference
  * Advanced bidirectional loading pattern
  * Key features and benefits
* **Working Example** - New "Infinite History" tab in example app:
  * Interactive demo with simulated API calls
  * Loading indicators for visual feedback
  * Bidirectional data loading demonstration
  * Debug console output showing offset changes
  * Info panel with statistics (total candles, batches loaded)
  * Instructions panel explaining how it works

### 🎨 UI/UX Improvements
* **Redesigned Settings Tab** - Modern Bottom Sheet interface:
  * Full-screen chart view (no space wasted)
  * Draggable Bottom Sheet with settings
  * Organized sections: Candle Style, Grid, Labels
  * Real-time preview of changes
  * Info badges showing current configuration
* **New Infinite History Tab** - Added to tabbed example:
  * Real-time statistics display
  * Loading indicators during data fetch
  * Visual feedback for scroll position
  * Helpful instructions and tips
* **Enhanced Example App** - Updated to 7 tabs (from 6):
  * Indicators, Trading Lines, Price Zones, Drawing Tools, Vertical Zoom, **Infinite History**, Settings
* **Interactive Controls**:
  * Grid: Toggle, style chips, sliders for width/opacity
  * Labels: Adaptive toggle, manual override sliders
  * Candles: Border radius slider with presets

### 🔧 Technical Details
* **GridStyle Class** (new):
  - `GridLineStyle` enum: solid, dashed, dotted, longDashed
  - Independent configuration for horizontal and vertical grids
  - `_drawStyledLine()` method supports all line styles
  - `_drawDashedLine()` helper for non-solid lines
  - Grid lines drawn in `_drawHorizontalGrid()` and `_drawVerticalGrid()`
  - Always rendered before labels (background layer)
* **Adaptive Labels Implementation**:
  - `_calculatePriceLabelCount()` - Dynamic calculation based on chart height
  - `_calculateTimeLabelDensity()` - Configurable spacing for time labels
  - Formula: `(chartHeight / 80).round().clamp(3, 10)` for price labels
  - Supports manual override via `priceLabelCount` and `timeLabelDensity`
  - Grid automatically syncs with calculated label positions
* **ChartStyle Extensions**:
  - Added `adaptiveLabels` (bool, default: true)
  - Added `priceLabelCount` (int?, nullable for adaptive)
  - Added `timeLabelDensity` (int?, nullable for adaptive)
  - Added `gridStyle` (GridStyle, replaces deprecated `priceGridLineColor`)
  - Backward compatible with `@Deprecated` annotation
* **XAxisOffsetDetails Extensions**:
  - Added `candlesBeforeVisible` getter (returns `startCandleIndex`)
  - Added `candlesAfterVisible` getter (returns `totalCandles - endCandleIndex`)
  - Added `isNearStart([int threshold = 50])` method
  - Added `isNearEnd([int threshold = 50])` method
  - All methods include comprehensive documentation and examples
* **Prepend Support**:
  - Existing offset adjustment logic handles prepending automatically
  - When `candles.length` increases, offset is adjusted by `candlesAdded * candleWidth`
  - Maintains visual position without any additional code needed
* **Performance**:
  - Only visible candles are rendered (existing optimization)
  - Efficient handling of large datasets (10,000+ candles tested)
  - Minimal overhead for offset calculations

### 💥 Breaking Changes
* None - Fully backward compatible with 1.0.5
* All new features are additive and opt-in
* Existing `onXOffsetChanged` callback behavior unchanged

### 📝 Example Usage

#### Grid Configuration
```dart
// Full grid with custom styling
InteractiveChart(
  candles: data,
  style: ChartStyle(
    gridStyle: GridStyle(
      showHorizontalGrid: true,
      showVerticalGrid: true,
      horizontalLineStyle: GridLineStyle.solid,
      verticalLineStyle: GridLineStyle.dashed,
      horizontalStrokeWidth: 1.0,
      verticalStrokeWidth: 0.5,
      horizontalGridColor: Colors.grey.withOpacity(0.3),
      verticalGridColor: Colors.grey.withOpacity(0.1),
    ),
  ),
)

// Using presets
InteractiveChart(
  candles: data,
  style: ChartStyle(
    gridStyle: GridStyle.full,  // or .none, .subtle, .dashed, .dotted
  ),
)
```

#### Adaptive Labels
```dart
// Automatic (default)
InteractiveChart(
  candles: data,
  style: ChartStyle(
    adaptiveLabels: true,  // Labels adjust to chart size
  ),
)

// Manual override
InteractiveChart(
  candles: data,
  style: ChartStyle(
    adaptiveLabels: false,
    priceLabelCount: 7,      // Force 7 price labels
    timeLabelDensity: 100,   // One time label every 100px
  ),
)
```

#### Infinite History
```dart
InteractiveChart(
  candles: _candles,
  onXOffsetChanged: (details) {
    // Load more historical data when near start
    if (details.isNearStart(50) && !_isLoading) {
      // Use Future.microtask to avoid setState during build
      Future.microtask(() => _loadMoreHistory());
    }
    
    // Load more recent data when near end
    if (details.isNearEnd(50) && !_isLoading) {
      // Use Future.microtask to avoid setState during build
      Future.microtask(() => _loadMoreRecent());
    }
  },
)
```

**Important:** Always wrap data loading calls in `Future.microtask()` to avoid calling `setState()` during the build phase.

### 🎯 Use Cases
* **Real-time Trading Apps** - Load historical data on demand
* **Large Datasets** - Handle millions of candles efficiently
* **Mobile Apps** - Reduce initial load time and memory usage
* **Web Apps** - Progressive data loading for better UX
* **Historical Analysis** - Load years of data without performance issues

---

## 1.0.5

**🎨 Visual Enhancements & Advanced Chart Controls**

### 🚀 New Features

#### Vertical Zoom & Pan
* **Vertical Camera Control** - Full control over vertical chart space:
  * `enableVerticalPan` - Toggle vertical zoom/pan functionality (default: `false`)
  * `initialVerticalZoom` - Set initial vertical zoom level (1.0 = fit, >1.0 = padding)
  * **Desktop Controls**:
    - `Shift + Scroll` - Vertical zoom in/out
    - `Alt + Scroll` - Vertical pan up/down
  * **Mobile Controls**:
    - Vertical drag - Pan chart up/down with natural scrolling
  * **Programmatic Control**:
    - `setVerticalZoom(factor)` - Set zoom level (0.5 - 3.0)
    - `resetVerticalZoom()` - Reset to fit mode
    - `resetVerticalPan()` - Reset pan offset
    - `resetVerticalView()` - Reset both zoom and pan
* **Perfect for Trading** - See TP/SL lines and indicators outside candle range
* **Backward Compatible** - Disabled by default, maintains legacy auto-fit behavior

#### Rounded Candle Corners
* **Customizable Candle Style** - Modern, rounded candle appearance:
  * `candleBorderRadius` in `ChartStyle` - Control corner rounding (0.0 - 8.0)
  * **Recommended Values**:
    - `0.0` - Square corners (default, classic)
    - `2.0` - Slightly rounded
    - `4.0` - Moderately rounded (recommended)
    - `8.0` - Very rounded (modern)
  * **Smart Rendering** - Automatically uses optimal drawing method
  * **Performance Optimized** - Uses `drawLine` for thin candles, `drawRRect` for thick ones
  * **Auto-limiting** - Radius capped at half candle width to prevent distortion

### 🎨 UI/UX Improvements
* **New Vertical Zoom Tab** - Interactive demo in example app:
  * Toggle `enableVerticalPan` on/off
  * Slider for fine-tuning zoom (0.5x - 3.0x)
  * Preset buttons (Fit, Normal, Wide, Max)
  * Live TP/SL demonstration
  * Keyboard shortcut hints
* **Enhanced Settings Tab** - Candle styling controls:
  * Slider for border radius adjustment
  * Preset chips (Square, Slight, Medium, Rounded)
  * Real-time visual preview

### 📚 Documentation
* **VERTICAL_ZOOM_GUIDE.md** - Complete guide for vertical controls:
  * Problem explanation and use cases
  * Desktop and mobile controls
  * Programmatic control examples
  * Best practices and troubleshooting
* **CANDLE_STYLING_GUIDE.md** - Comprehensive styling guide:
  * Recommended radius values
  * Multiple code examples
  * Performance notes
  * Combination with other styles

### 🔧 Technical Details
* **Vertical Zoom Implementation**:
  - Added `_verticalZoomFactor` and `_verticalPanOffset` state variables
  - Modified price range calculation to apply padding based on zoom factor
  - Integrated with existing gesture system (no conflicts)
  - Natural scrolling direction (swipe up = chart moves up)
* **Rounded Corners Implementation**:
  - Modified `_drawSingleDay()` in `ChartPainter`
  - Conditional rendering: `drawRRect` when `borderRadius > 0 && thickWidth > 2`
  - Falls back to `drawLine` for performance on thin candles
  - Only affects candle body, not wicks

### 💥 Breaking Changes
* None - Fully backward compatible with 1.0.4
* All new features are opt-in with sensible defaults

### 🐛 Bug Fixes
* Fixed vertical pan direction to match natural scrolling expectations
* Ensured rounded corners don't distort on very thin candles

---

## 1.0.4

**🎯 Major Overlay Positioning & Rendering Fixes**

### Fixed Overlay Viewport Behavior
* **All overlays now stay anchored to their chart positions** - Overlays no longer "stick" to the viewport when scrolling
  * Added optional `startTime` and `endTime` timestamps to `TradingLine`, `PriceZone`, and `FibonacciRetracement`
  * Overlays now move with their anchored candles and exit the viewport correctly
  * Backward compatible: overlays without timestamps extend infinitely (legacy behavior)
* **Fixed TrendLine viewport positioning** - TrendLine now correctly exits viewport when scrolling
  * Added visibility check to prevent drawing when completely outside visible range
  * Properly anchored to timestamp positions
* **Fixed indicator clipping issues** - Indicators (ATR, RSI, etc.) no longer cut off on the left edge
  * Adjusted `clipRect` offset to compensate for canvas translate
  * Indicators now render correctly at all zoom levels

**Affected Components:**
- ✅ TradingLine - Optional timestamps for anchored positioning
- ✅ PriceZone - Optional timestamps for anchored positioning
- ✅ Fibonacci Retracement - Optional timestamps for anchored positioning
- ✅ TrendLine - Improved visibility checks
- ✅ All Indicators - Fixed clipping issues

**Technical Details:**
- Modified `ChartPainter` to draw overlays within the translated canvas context
- Adjusted clipRect calculation: `Offset(-params.xShift, 0)` to compensate for translate
- Overlays calculate positions using `startIndex * candleWidth` without adding `xShift`
- Added visibility checks: `if (startTime > visibleEndTime || endTime < visibleStartTime) return;`
- Updated example to demonstrate anchored overlays
- Fixed SMA/EMA to use timestamp-based indexing for correct positioning at all zoom levels

**Known Issues:**
- Some overlay indicators may still have positioning issues at extreme zoom levels (being investigated)

---

## 1.0.3

**🐛 Critical Bug Fixes**

### Fixed Overlay Drag Issues

#### Fibonacci & PriceZone Drag Fix
* **Fixed Fibonacci becoming gigantic when dragged** - Fibonacci retracements would grow to enormous sizes when attempting to move them
  * Root cause: `_dragStartPrice` was being overwritten during drag, causing incorrect offset calculations
  * Solution: Added `_dragInitialPrice` to preserve the initial drag position
  * Now calculates offset correctly: `offset = currentPrice - initialPrice`
* **Fixed PriceZone snap-back and delayed updates** - Price zones would snap back or update with delay when dragged
  * Same root cause as Fibonacci issue
  * Both overlays now move smoothly and predictably
* **Fixed TrendLine drag precision** - Improved price offset calculation for trend line movement
  * Applied same fix to ensure consistent behavior across all draggable overlays

#### Overlay Resize Improvements
* **Dynamic minimum height based on visible price range** - Overlays now adapt to any price scale
  * Previous: Fibonacci had 20% minimum, PriceZone had 50% minimum of original size
  * Now: Both have dynamic minimum of 0.1% of visible price range
  * Automatically adapts to any instrument (forex, crypto, stocks)
  * Works perfectly with EUR/USD (0.6), BTC/USD (50,000), or any other price range
  * Allows overlays to be resized much smaller when zooming in
  * Prevents overlays from being too restrictive on low-price instruments

**Affected Overlays:**
- ✅ Fibonacci Retracement - Now drags smoothly without growing + flexible resize
- ✅ Price Zone - No more snap-back or delayed updates + flexible resize
- ✅ Trend Line - Improved drag precision

**Technical Details:**
- Added `_dragInitialPrice` state variable to track initial drag position
- Modified `_onOverlayDrag()` to update current position without overwriting initial position
- Updated `_onOverlayDragEnd()` to calculate offset using initial position
- Passed `draggedInitialPrice` to `ChartPainter` for correct visual feedback during drag
- Changed minimum height calculation from absolute values to dynamic: `visiblePriceRange * 0.001`
- Applied dynamic minimum to both `interactive_chart.dart` and `chart_painter.dart`
- Ensures all draggable overlays maintain correct size and position during drag and visual feedback

---

## 1.0.2

**🎨 UX Improvements & New Controls**

### 🚀 New Features

#### Smart Overlay Positioning
* **OverlayHelper** - Intelligent initial positioning for overlays:
  * `calculateTrendLinePosition()` - Smart trend line placement (30% width, centered)
  * `calculateFibonacciPosition()` - Smart Fibonacci placement (40% height, centered)
  * `calculatePriceZonePosition()` - Smart zone placement (15% height, customizable)
  * `calculateTradingLinePrice()` - Smart line price calculation
* **Customizable Parameters** - Control width, height, and position percentages
* **Viewport-based** - Positions calculated from visible chart data

#### Chart Controller
* **InteractiveChartController** - Programmatic chart control:
  * `jumpToLatest()` - Scroll to most recent candle
  * `isAttached` - Check controller attachment status
* **Real-time Support** - Perfect for live data feeds
* **Auto-scroll** - Automatic scroll to latest data when new candles added

#### Branding & Customization
* **Interaction Control** - `enableInteraction` parameter:
  * Toggle tap overlay showing OHLC data
  * Useful for embedded charts or custom interactions

#### Camera Controls
* **Free Camera Mode** - `freeCamera` parameter:
  * Unlimited horizontal scrolling beyond data boundaries
  * Useful for technical analysis and future data preparation
  * Prevents errors when scrolling past data range
  * Note: Vertical axis (prices) auto-adjusts to visible data (standard behavior)

### 🎨 UI/UX Improvements
* **Settings Tab** - New tab in example app:
  * Toggle watermark on/off
  * Toggle tap interaction
  * Jump to latest button
  * Floating action buttons for quick access
* **Improved Example** - Updated tabbed example with all new features
* **Better Positioning** - Overlays now created at sensible sizes and locations

### 🐛 Bug Fixes
* Fixed `StateError (Bad state: No element)` when scrolling beyond data with free camera
* Fixed watermark being drawn behind volume bars and indicators
* Fixed overlays being created too large or in unexpected locations
* Fixed Fibonacci retracements being difficult to select for resizing
* Fixed TrendLine assertion error when dragging points in reverse order - points now auto-normalize

### 📚 Documentation
* **Updated IMPLEMENTATION_GUIDE.md**:
  * Chart Controller section with examples
  * Free Camera Mode documentation
  * Advanced Features section
  * Real-time data updates guide
  * Updated best practices (8 practices, up from 5)
* **Complete Feature List** - All parameters and methods documented
* **Code Examples** - Practical examples for all new features

### 💥 Breaking Changes
* None - Fully backward compatible with 1.0.1

---

## 1.0.1

* Fix README screenshots to use absolute GitHub URLs for pub.dev compatibility

---

## 1.0.0 - Pipsend Charts Flutter (Major Release)

**🎉 Complete Rebranding and Feature Overhaul**

This is a major release that transforms the library into a professional charting solution with extensive new features, improved API, and commercial licensing options.

### 🚀 New Features

#### Technical Indicators
* **12 Professional Indicators** - Complete suite of technical analysis tools:
  * Moving Averages: SMA (20, 50), EMA (12, 26)
  * Momentum: RSI, Stochastic, Williams %R
  * Trend: MACD, ADX
  * Volatility: ATR, Bollinger Bands
  * Volume: OBV, Volume bars
* **Separate Panels** - Indicators render in dedicated panels below the main chart
* **Customizable Styles** - Full control over colors, line widths, and visual appearance
* **Toggle Support** - Easy enable/disable of individual indicators

#### Trading Lines System
* **TradingLine** - Horizontal price lines with multiple types:
  * Entry, Stop Loss, Take Profit, Support, Resistance, Custom
* **TradingLineManager** - Complete management system:
  * Add, remove, update lines programmatically
  * Query by type, price range
  * Event system for real-time updates
  * Visibility controls
  * Price validation and constraints
* **Drag & Drop** - Interactive line repositioning with callbacks
* **Visual Feedback** - Enhanced appearance when dragging
* **Customizable Styles** - Colors, line widths, dash patterns, labels

#### Price Zones System
* **PriceZone** - Rectangular horizontal zones between price levels:
  * Support, Resistance, Demand, Supply, Custom types
* **PriceZoneManager** - Full zone management:
  * Add, remove, update zones
  * Query by type, price, range
  * Event system for updates
  * Visibility controls
* **Drag & Drop** - Interactive zone repositioning
* **Auto-coloring** - Type-based default colors
* **Labels** - Optional zone labels with customization

#### Drawing Tools
* **Fibonacci Retracement** - Complete Fibonacci tool:
  * Standard levels (0%, 23.6%, 38.2%, 50%, 61.8%, 78.6%, 100%)
  * Draggable high/low points
  * Customizable colors and labels
  * FibonacciManager for multiple retracements
* **Trend Lines** - Diagonal lines connecting two points:
  * Draggable start/end points
  * Optional angle display
  * Extend right option
  * TrendLineManager for multiple lines
  * Custom colors and styles

#### Manager System
* **Event-Driven Architecture** - All managers support event listeners:
  * Real-time notifications on add, remove, update
  * Type-safe event system
  * Multiple listener support
* **Batch Operations** - Update multiple overlays at once
* **Query System** - Find overlays by various criteria
* **Validation** - Built-in constraints and validation

### 🎨 UI/UX Improvements
* **Tabbed Example** - New organized demo with 4 tabs:
  * Indicators tab with all 12 indicators
  * Trading Lines tab with interactive controls
  * Price Zones tab with zone management
  * Drawing Tools tab with Fibonacci and Trend Lines
* **Floating Action Buttons** - Quick access to add overlays
* **Horizontal Scroll** - Indicator toggles with smooth scrolling
* **Dark Mode Toggle** - Built-in theme switching
* **No Swipe Conflicts** - Disabled tab swipe to prevent gesture conflicts

### 🔧 API Improvements
* **Unified Overlay System** - All overlays extend `ChartOverlay`
* **Consistent Managers** - Similar API across all manager classes
* **Type Safety** - Strong typing throughout
* **Callbacks** - Rich callback system for user interactions
* **Builder Pattern** - Fluent API for configuration

### 📚 Documentation
* **Comprehensive Example** - Professional tabbed demo
* **Dual Licensing** - Free for use, commercial for modifications
* **Commercial License Guide** - Clear pricing and terms
* **Clean Codebase** - Removed unused code and examples

### 🐛 Bug Fixes
* Fixed drag & drop not persisting positions
* Fixed TabBarView swipe interfering with chart gestures
* Fixed overlays returning to original position after drag
* Fixed manager updates not triggering UI rebuilds
* Fixed ID conflicts with dynamic overlay creation

### 💥 Breaking Changes
* Rebranded from `interactive_chart` to Pipsend Charts Flutter
* New dual licensing model (free + commercial)
* Removed old `advanced_example.dart` in favor of `tabbed_example.dart`
* Manager classes now require event listeners for drag & drop
* Overlay IDs must be provided for proper drag & drop functionality

### 📦 Dependencies
* Updated intl to ^0.20.0
* Maintained Flutter SDK compatibility

### 🎯 Migration Guide
For users of the original `interactive_chart`:
1. Update import to use new package name
2. Review new licensing terms
3. Use `tabbed_example.dart` as reference for new features
4. Implement event listeners if using drag & drop
5. Provide explicit IDs for overlays

---

## 0.3.6 (Deprecated)

* Update dependency: intl to ^0.20.0.

## 0.3.5 (Deprecated)

* Update dependency: intl to ^0.19.0.

## 0.3.4 (Deprecated)

* Fix a potential crash if volume numbers are null.

## 0.3.3 (Deprecated)

* Fix an issue where `onTap` event was not firing. [(Issue #8)](https://github.com/fluttercandies/flutter-interactive-chart/issues/8)

## 0.3.2 (Deprecated)

* Add `initialVisibleCandleCount` parameter for setting a default zoom level. [(Issue #6)](https://github.com/fluttercandies/flutter-interactive-chart/issues/6)

## 0.3.1 (Deprecated)

* Allow web and desktop users to zoom the chart with mouse scroll wheel. [(Issue #4)](https://github.com/fluttercandies/flutter-interactive-chart/issues/4)

## 0.3.0 (Deprecated)

* BREAKING: Add support for multiple trend lines. [(Issue #2)](https://github.com/fluttercandies/flutter-interactive-chart/issues/2)
* The old `trend` property is changed to `trends`, to support multiple data points per `CandleData`.
* The old `trendLineColor` property is changed to `trendLineStyles`.
* The `CandleData.computeMA` helper function no longer modifies data in-place. To migrate,
  change `CandleData.computeMA(data)` to the following two lines:
  `final ma = CandleData.computeMA(data); ` and
  `for (int i = 0; i < data.length; i++) { data[i].trends = [ma[i]]; }`.
* Update example project to reflect above changes.

## 0.2.1 (Deprecated)

* Add `onTap` event and `onCandleResize` event.
* Allow `overlayInfo` to return an empty object.
* Update example project.

## 0.2.0 (Deprecated)

* BREAKING: Organize folder structures, now you only need to
  import `package:interactive_chart/interactive_chart.dart`.
* BREAKING: Change CandleData `timestamp` to milliseconds, you might need to multiply your data by
  1000 when creating CandleData objects.
* Fix an issue where zooming was occasionally not smooth.
* Fix an issue where overlay panel was occasionally clipped.

## 0.1.1 (Deprecated)

* Improve performance.
* Allow `high` and `low` prices to be optional.
* Align date/time labels towards vertical bottom.

## 0.1.0 (Deprecated)

* Initial Open Source release.
