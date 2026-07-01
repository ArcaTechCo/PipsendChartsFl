import 'dart:ui';

enum PlacementPreviewShape { none, rectangle, line }

class PlacementPoint {
  final double price;
  final int timestamp;
  final Offset localPosition;

  const PlacementPoint({
    required this.price,
    required this.timestamp,
    required this.localPosition,
  });
}

class DrawingPlacement {
  final int pointCount;
  final PlacementPreviewShape preview;
  final Color color;

  const DrawingPlacement({
    this.pointCount = 2,
    this.preview = PlacementPreviewShape.rectangle,
    this.color = const Color(0xFF2962FF),
  });
}
