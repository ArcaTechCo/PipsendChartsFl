import 'dart:collection';

import 'package:flutter/painting.dart';

class TextLayoutCache {
  final int maxEntries;

  final LinkedHashMap<_TextLayoutKey, _TextLayoutEntry> _entries =
      LinkedHashMap<_TextLayoutKey, _TextLayoutEntry>();

  int _generation = 0;

  TextLayoutCache({this.maxEntries = 1024}) : assert(maxEntries > 0);

  int get length => _entries.length;

  TextPainter layout(String text, TextStyle style) {
    final key = _TextLayoutKey(text, style);
    final cached = _entries.remove(key);
    if (cached != null) {
      cached.generation = _generation;
      _entries[key] = cached;
      return cached.painter;
    }

    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    _entries[key] = _TextLayoutEntry(painter, _generation);

    while (_entries.length > maxEntries) {
      _entries.remove(_entries.keys.first)!.painter.dispose();
    }
    return painter;
  }

  void endFrame() {
    while (_entries.isNotEmpty) {
      final key = _entries.keys.first;
      final entry = _entries[key]!;
      if (entry.generation == _generation) break;
      _entries.remove(key);
      entry.painter.dispose();
    }
    _generation++;
  }

  void dispose() {
    for (final entry in _entries.values) {
      entry.painter.dispose();
    }
    _entries.clear();
  }
}

class _TextLayoutKey {
  final String text;
  final TextStyle style;

  @override
  final int hashCode;

  _TextLayoutKey(this.text, this.style) : hashCode = Object.hash(text, style);

  @override
  bool operator ==(Object other) =>
      other is _TextLayoutKey && text == other.text && style == other.style;
}

class _TextLayoutEntry {
  final TextPainter painter;
  int generation;

  _TextLayoutEntry(this.painter, this.generation);
}
