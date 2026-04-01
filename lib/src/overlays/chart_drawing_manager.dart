import 'trading_line.dart';
import 'trading_line_manager.dart';
import 'price_zone.dart';
import 'price_zone_manager.dart';
import 'fibonacci_retracement.dart';
import 'fibonacci_extension.dart';
import 'fibonacci_fan.dart';
import 'fibonacci_manager.dart';
import 'trend_line.dart';
import 'trend_line_manager.dart';
import 'tools/vertical_line.dart';
import 'tools/text_tool.dart';
import 'tools/brush_tool.dart';
import 'tools/arrow_tool.dart';
import 'tools/circle_tool.dart';
import 'tools/ruler_tool.dart';
import 'tools/gantt_tool.dart';
import 'tools/position_tool.dart';

/// Callback for when any drawing is changed via user interaction.
///
/// [type] is the drawing type (e.g. 'tradingLine', 'priceZone', etc.).
/// [id] is the drawing's unique identifier.
/// [serialized] is the JSON-safe representation of the updated drawing.
typedef DrawingChangeCallback = void Function(
  String type,
  String id,
  Map<String, dynamic> serialized,
);

/// Manages all chart drawing overlays with unified serialization and sync support.
///
/// Combines all individual managers and standalone drawing tool lists into a single
/// entry point for serialization, deserialization, and change notifications.
///
/// Example:
/// ```dart
/// final drawingManager = ChartDrawingManager(
///   tradingLineManager: tradingLineManager,
///   priceZoneManager: priceZoneManager,
///   fibonacciManager: fibonacciManager,
///   trendLineManager: trendLineManager,
/// );
///
/// // Serialize everything
/// final json = drawingManager.serializeAll();
///
/// // Restore from serialized data
/// drawingManager.restoreAll(json);
///
/// // Listen for changes (for Chart Sync)
/// drawingManager.onDrawingChanged = (type, id, data) {
///   webSocket.send(jsonEncode({'type': type, 'id': id, 'data': data}));
/// };
/// ```
class ChartDrawingManager {
  final TradingLineManager tradingLineManager;
  final PriceZoneManager priceZoneManager;
  final FibonacciManager fibonacciManager;
  final TrendLineManager trendLineManager;

  final List<VerticalLine> _verticalLines = [];
  final List<TextTool> _textTools = [];
  final List<BrushTool> _brushTools = [];
  final List<ArrowTool> _arrowTools = [];
  final List<CircleTool> _circleTools = [];
  final List<RulerTool> _rulerTools = [];
  final List<GanttTool> _ganttTools = [];
  final List<PositionTool> _positionTools = [];
  final List<FibonacciExtension> _fibonacciExtensions = [];
  final List<FibonacciFan> _fibonacciFans = [];

  /// Called when any drawing is moved, resized, or modified via user interaction.
  DrawingChangeCallback? onDrawingChanged;

  ChartDrawingManager({
    TradingLineManager? tradingLineManager,
    PriceZoneManager? priceZoneManager,
    FibonacciManager? fibonacciManager,
    TrendLineManager? trendLineManager,
  })  : tradingLineManager = tradingLineManager ?? TradingLineManager(),
        priceZoneManager = priceZoneManager ?? PriceZoneManager(),
        fibonacciManager = fibonacciManager ?? FibonacciManager(),
        trendLineManager = trendLineManager ?? TrendLineManager();

  // ============================================================================
  // Drawing Tool Accessors
  // ============================================================================

  List<VerticalLine> get verticalLines => List.unmodifiable(_verticalLines);
  List<TextTool> get textTools => List.unmodifiable(_textTools);
  List<BrushTool> get brushTools => List.unmodifiable(_brushTools);
  List<ArrowTool> get arrowTools => List.unmodifiable(_arrowTools);
  List<CircleTool> get circleTools => List.unmodifiable(_circleTools);
  List<RulerTool> get rulerTools => List.unmodifiable(_rulerTools);
  List<GanttTool> get ganttTools => List.unmodifiable(_ganttTools);
  List<PositionTool> get positionTools => List.unmodifiable(_positionTools);
  List<FibonacciExtension> get fibonacciExtensions => List.unmodifiable(_fibonacciExtensions);
  List<FibonacciFan> get fibonacciFans => List.unmodifiable(_fibonacciFans);

  // ============================================================================
  // Add/Remove for standalone drawing tools
  // ============================================================================

  void addVerticalLine(VerticalLine line) => _verticalLines.add(line);
  void removeVerticalLine(String id) => _verticalLines.removeWhere((e) => e.id == id);

  void addTextTool(TextTool tool) => _textTools.add(tool);
  void removeTextTool(String id) => _textTools.removeWhere((e) => e.id == id);

  void addBrushTool(BrushTool tool) => _brushTools.add(tool);
  void removeBrushTool(String id) => _brushTools.removeWhere((e) => e.id == id);

  void addArrowTool(ArrowTool tool) => _arrowTools.add(tool);
  void removeArrowTool(String id) => _arrowTools.removeWhere((e) => e.id == id);

  void addCircleTool(CircleTool tool) => _circleTools.add(tool);
  void removeCircleTool(String id) => _circleTools.removeWhere((e) => e.id == id);

  void addRulerTool(RulerTool tool) => _rulerTools.add(tool);
  void removeRulerTool(String id) => _rulerTools.removeWhere((e) => e.id == id);

  void addGanttTool(GanttTool tool) => _ganttTools.add(tool);
  void removeGanttTool(String id) => _ganttTools.removeWhere((e) => e.id == id);

  void addPositionTool(PositionTool tool) => _positionTools.add(tool);
  void removePositionTool(String id) => _positionTools.removeWhere((e) => e.id == id);

  void addFibonacciExtension(FibonacciExtension ext) => _fibonacciExtensions.add(ext);
  void removeFibonacciExtension(String id) => _fibonacciExtensions.removeWhere((e) => e.id == id);

  void addFibonacciFan(FibonacciFan fan) => _fibonacciFans.add(fan);
  void removeFibonacciFan(String id) => _fibonacciFans.removeWhere((e) => e.id == id);

  // ============================================================================
  // Serialization
  // ============================================================================

  /// Serializes all drawings (managers + standalone tools) to a JSON-safe map.
  Map<String, dynamic> serializeAll() => {
    'tradingLines': tradingLineManager.serializeAll(),
    'priceZones': priceZoneManager.serializeAll(),
    'fibonaccis': fibonacciManager.serializeAll(),
    'trendLines': trendLineManager.serializeAll(),
    'verticalLines': _verticalLines.map((e) => e.toJson()).toList(),
    'textTools': _textTools.map((e) => e.toJson()).toList(),
    'brushTools': _brushTools.map((e) => e.toJson()).toList(),
    'arrowTools': _arrowTools.map((e) => e.toJson()).toList(),
    'circleTools': _circleTools.map((e) => e.toJson()).toList(),
    'rulerTools': _rulerTools.map((e) => e.toJson()).toList(),
    'ganttTools': _ganttTools.map((e) => e.toJson()).toList(),
    'positionTools': _positionTools.map((e) => e.toJson()).toList(),
    'fibonacciExtensions': _fibonacciExtensions.map((e) => e.toJson()).toList(),
    'fibonacciFans': _fibonacciFans.map((e) => e.toJson()).toList(),
  };

  /// Clears all drawings and restores from serialized data.
  void restoreAll(Map<String, dynamic> data) {
    // Restore managers
    if (data['tradingLines'] != null) {
      tradingLineManager.restoreAll(
        (data['tradingLines'] as List<dynamic>).cast<Map<String, dynamic>>(),
      );
    } else {
      tradingLineManager.clear();
    }

    if (data['priceZones'] != null) {
      priceZoneManager.restoreAll(
        (data['priceZones'] as List<dynamic>).cast<Map<String, dynamic>>(),
      );
    } else {
      priceZoneManager.clear();
    }

    if (data['fibonaccis'] != null) {
      fibonacciManager.restoreAll(
        (data['fibonaccis'] as List<dynamic>).cast<Map<String, dynamic>>(),
      );
    } else {
      fibonacciManager.clear();
    }

    if (data['trendLines'] != null) {
      trendLineManager.restoreAll(
        (data['trendLines'] as List<dynamic>).cast<Map<String, dynamic>>(),
      );
    } else {
      trendLineManager.clear();
    }

    // Restore standalone tools
    _verticalLines.clear();
    if (data['verticalLines'] != null) {
      for (final json in (data['verticalLines'] as List<dynamic>)) {
        _verticalLines.add(VerticalLine.fromJson(json as Map<String, dynamic>));
      }
    }

    _textTools.clear();
    if (data['textTools'] != null) {
      for (final json in (data['textTools'] as List<dynamic>)) {
        _textTools.add(TextTool.fromJson(json as Map<String, dynamic>));
      }
    }

    _brushTools.clear();
    if (data['brushTools'] != null) {
      for (final json in (data['brushTools'] as List<dynamic>)) {
        _brushTools.add(BrushTool.fromJson(json as Map<String, dynamic>));
      }
    }

    _arrowTools.clear();
    if (data['arrowTools'] != null) {
      for (final json in (data['arrowTools'] as List<dynamic>)) {
        _arrowTools.add(ArrowTool.fromJson(json as Map<String, dynamic>));
      }
    }

    _circleTools.clear();
    if (data['circleTools'] != null) {
      for (final json in (data['circleTools'] as List<dynamic>)) {
        _circleTools.add(CircleTool.fromJson(json as Map<String, dynamic>));
      }
    }

    _rulerTools.clear();
    if (data['rulerTools'] != null) {
      for (final json in (data['rulerTools'] as List<dynamic>)) {
        _rulerTools.add(RulerTool.fromJson(json as Map<String, dynamic>));
      }
    }

    _ganttTools.clear();
    if (data['ganttTools'] != null) {
      for (final json in (data['ganttTools'] as List<dynamic>)) {
        _ganttTools.add(GanttTool.fromJson(json as Map<String, dynamic>));
      }
    }

    _positionTools.clear();
    if (data['positionTools'] != null) {
      for (final json in (data['positionTools'] as List<dynamic>)) {
        _positionTools.add(PositionTool.fromJson(json as Map<String, dynamic>));
      }
    }

    _fibonacciExtensions.clear();
    if (data['fibonacciExtensions'] != null) {
      for (final json in (data['fibonacciExtensions'] as List<dynamic>)) {
        _fibonacciExtensions.add(FibonacciExtension.fromJson(json as Map<String, dynamic>));
      }
    }

    _fibonacciFans.clear();
    if (data['fibonacciFans'] != null) {
      for (final json in (data['fibonacciFans'] as List<dynamic>)) {
        _fibonacciFans.add(FibonacciFan.fromJson(json as Map<String, dynamic>));
      }
    }
  }

  // ============================================================================
  // Change Notification (for Chart Sync)
  // ============================================================================

  /// Notifies that a drawing was changed via user interaction.
  ///
  /// Call this from your gesture handler when a drawing is moved/resized.
  void notifyDrawingChanged(String type, String id, Map<String, dynamic> serialized) {
    onDrawingChanged?.call(type, id, serialized);
  }

  /// Notifies that a trading line was changed via interaction.
  void notifyTradingLineChanged(TradingLine line) {
    onDrawingChanged?.call('tradingLine', line.id, line.toJson());
  }

  /// Notifies that a price zone was changed via interaction.
  void notifyPriceZoneChanged(PriceZone zone) {
    onDrawingChanged?.call('priceZone', zone.id, zone.toJson());
  }

  /// Notifies that a Fibonacci retracement was changed via interaction.
  void notifyFibonacciChanged(FibonacciRetracement fib) {
    onDrawingChanged?.call('fibonacci', fib.id, fib.toJson());
  }

  /// Notifies that a trend line was changed via interaction.
  void notifyTrendLineChanged(TrendLine line) {
    onDrawingChanged?.call('trendLine', line.id, line.toJson());
  }

  // ============================================================================
  // Utility
  // ============================================================================

  /// Clears all drawings from all managers and tool lists.
  void clearAll() {
    tradingLineManager.clear();
    priceZoneManager.clear();
    fibonacciManager.clear();
    trendLineManager.clear();
    _verticalLines.clear();
    _textTools.clear();
    _brushTools.clear();
    _arrowTools.clear();
    _circleTools.clear();
    _rulerTools.clear();
    _ganttTools.clear();
    _positionTools.clear();
    _fibonacciExtensions.clear();
    _fibonacciFans.clear();
  }

  /// Returns the total count of all drawings.
  int get totalCount =>
      tradingLineManager.count +
      priceZoneManager.count +
      fibonacciManager.count +
      trendLineManager.count +
      _verticalLines.length +
      _textTools.length +
      _brushTools.length +
      _arrowTools.length +
      _circleTools.length +
      _rulerTools.length +
      _ganttTools.length +
      _positionTools.length +
      _fibonacciExtensions.length +
      _fibonacciFans.length;

  bool get isEmpty => totalCount == 0;
  bool get isNotEmpty => totalCount > 0;
}
