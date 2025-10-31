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
