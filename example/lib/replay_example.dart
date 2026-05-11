import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pipsend_charts/pipsend_charts.dart';

import 'mock_data.dart';

/// Standalone example demonstrating Replay Mode.
///
/// What it shows:
///   * `playheadIndex` to freeze the chart at a historical moment.
///   * `playheadStyle` with a translucent dim region on the right.
///   * Built-in playhead drag (single-finger) updating the index.
///   * Tick replay: sub-candle progress 0→1 animating before the next
///     bar commits.
///   * `InteractiveChartController.seekToIndex` to keep the playhead
///     centered while playing ("follow mode").
class ReplayExample extends StatefulWidget {
  const ReplayExample({super.key});

  @override
  State<ReplayExample> createState() => _ReplayExampleState();
}

enum _Mode { bar, tick }

class _ReplayExampleState extends State<ReplayExample> {
  late final List<CandleData> _candles;
  final _controller = InteractiveChartController();

  int _playhead = 0;
  bool _isPlaying = false;
  double _speed = 1.0;
  _Mode _mode = _Mode.bar;
  double _tickProgress = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _candles = MockDataTesla.candles;
    // Start the playhead at 60% through the dataset so there is
    // plenty of room to advance forwards.
    _playhead = (_candles.length * 0.6).round();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _togglePlay() {
    if (_isPlaying) {
      _timer?.cancel();
      setState(() => _isPlaying = false);
    } else {
      setState(() => _isPlaying = true);
      _scheduleNextTick();
    }
  }

  void _scheduleNextTick() {
    final periodMs = (1000 / _speed).clamp(50, 2000).toInt();
    _timer = Timer(Duration(milliseconds: periodMs), _onTick);
  }

  void _onTick() {
    if (!_isPlaying) return;
    setState(() {
      if (_mode == _Mode.bar) {
        if (_playhead < _candles.length - 1) {
          _playhead += 1;
          _tickProgress = 0.0;
        } else {
          _isPlaying = false;
        }
      } else {
        // Tick mode: 10 sub-steps per candle.
        _tickProgress += 0.1;
        if (_tickProgress >= 1.0) {
          _tickProgress = 0.0;
          if (_playhead < _candles.length - 1) {
            _playhead += 1;
          } else {
            _isPlaying = false;
          }
        }
      }
    });
    // Follow mode: keep the playhead in view as it advances.
    _controller.seekToIndex(_playhead);
    if (_isPlaying) _scheduleNextTick();
  }

  void _stepBy(int delta) {
    setState(() {
      _playhead = (_playhead + delta).clamp(0, _candles.length - 1);
      _tickProgress = 0.0;
    });
    _controller.seekToIndex(_playhead);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Replay Mode'),
        actions: [
          IconButton(
            tooltip: 'Jump to start',
            icon: const Icon(Icons.first_page),
            onPressed: () => _stepBy(-_candles.length),
          ),
          IconButton(
            tooltip: 'Jump to end',
            icon: const Icon(Icons.last_page),
            onPressed: () => _stepBy(_candles.length),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveChart(
              candles: _candles,
              controller: _controller,
              playheadIndex: _playhead,
              playheadTickProgress: _mode == _Mode.tick ? _tickProgress : null,
              playheadStyle: const PlayheadStyle(
                lineColor: Color(0xFF3B82F6),
                lineWidth: 1.5,
                dashPattern: [4, 3],
                dimRightSide: true,
                dimOpacity: 0.22,
              ),
              onPlayheadChanged: (info) {
                setState(() {
                  _playhead = info.candleIndex;
                  _tickProgress = 0.0;
                });
              },
              indicators: [
                SMAIndicator(period: 20),
                SMAIndicator(period: 50),
              ],
              futureCandles: 20,
              initialVisibleCandleCount: 60,
            ),
          ),
          _TimelineBar(
            playhead: _playhead,
            totalCandles: _candles.length,
            isPlaying: _isPlaying,
            speed: _speed,
            mode: _mode,
            onTogglePlay: _togglePlay,
            onSpeedChanged: (s) {
              setState(() => _speed = s);
              if (_isPlaying) {
                _timer?.cancel();
                _scheduleNextTick();
              }
            },
            onModeChanged: (m) {
              setState(() {
                _mode = m;
                _tickProgress = 0.0;
              });
            },
            onScrub: (value) {
              setState(() {
                _playhead = value;
                _tickProgress = 0.0;
              });
              _controller.seekToIndex(_playhead);
            },
            onStep: _stepBy,
          ),
        ],
      ),
    );
  }
}

class _TimelineBar extends StatelessWidget {
  final int playhead;
  final int totalCandles;
  final bool isPlaying;
  final double speed;
  final _Mode mode;
  final VoidCallback onTogglePlay;
  final ValueChanged<double> onSpeedChanged;
  final ValueChanged<_Mode> onModeChanged;
  final ValueChanged<int> onScrub;
  final ValueChanged<int> onStep;

  const _TimelineBar({
    required this.playhead,
    required this.totalCandles,
    required this.isPlaying,
    required this.speed,
    required this.mode,
    required this.onTogglePlay,
    required this.onSpeedChanged,
    required this.onModeChanged,
    required this.onScrub,
    required this.onStep,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => onStep(-1),
                icon: const Icon(Icons.skip_previous),
                tooltip: 'Back 1',
              ),
              IconButton.filled(
                onPressed: onTogglePlay,
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              ),
              IconButton(
                onPressed: () => onStep(1),
                icon: const Icon(Icons.skip_next),
                tooltip: 'Forward 1',
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Slider(
                  min: 0,
                  max: (totalCandles - 1).toDouble(),
                  value: playhead.toDouble().clamp(0, (totalCandles - 1).toDouble()),
                  onChanged: (v) => onScrub(v.round()),
                ),
              ),
              const SizedBox(width: 8),
              Text('$playhead / ${totalCandles - 1}',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text('Speed:'),
              const SizedBox(width: 8),
              Wrap(
                spacing: 4,
                children: [0.5, 1.0, 2.0, 5.0, 10.0]
                    .map((s) => ChoiceChip(
                          label: Text('${s}x'),
                          selected: speed == s,
                          onSelected: (_) => onSpeedChanged(s),
                        ))
                    .toList(),
              ),
              const Spacer(),
              SegmentedButton<_Mode>(
                segments: const [
                  ButtonSegment(value: _Mode.bar, label: Text('Bar')),
                  ButtonSegment(value: _Mode.tick, label: Text('Tick')),
                ],
                selected: {mode},
                onSelectionChanged: (s) => onModeChanged(s.first),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
