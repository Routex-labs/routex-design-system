import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import 'navigation_promo_scene.dart';
import 'navigation_promo_timeline.dart';

class NavigationPromoApp extends StatelessWidget {
  const NavigationPromoApp({
    super.key,
    this.segment = NavigationPromoSegment.full,
  });

  final NavigationPromoSegment segment;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Navigation — Indoor Film Studio',
      theme: AppTheme.light,
      home: NavigationPromoStudio(segment: segment),
    );
  }
}

class NavigationPromoStudio extends StatefulWidget {
  const NavigationPromoStudio({
    super.key,
    this.segment = NavigationPromoSegment.full,
  });

  final NavigationPromoSegment segment;

  @override
  State<NavigationPromoStudio> createState() => _NavigationPromoStudioState();
}

class _NavigationPromoStudioState extends State<NavigationPromoStudio>
    with SingleTickerProviderStateMixin {
  late NavigationPromoSegment _segment = widget.segment;

  late final AnimationController _controller =
      AnimationController(
        vsync: this,
        duration: Duration(milliseconds: _segment.durationMs),
      )..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) setState(() {});
      });

  bool _controlsVisible = true;

  int get _durationMs => _controller.duration!.inMilliseconds;

  void _selectSegment(NavigationPromoSegment segment) {
    if (segment == _segment) return;
    _controller.stop();
    setState(() {
      _segment = segment;
      _controller.duration = Duration(milliseconds: segment.durationMs);
      _controller.value = 0;
    });
  }

  int get _timeMs => (_controller.value * _durationMs).round();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayback() {
    if (_controller.isAnimating) {
      _controller.stop();
    } else if (_controller.value >= 1) {
      unawaited(_controller.forward(from: 0));
    } else {
      unawaited(_controller.forward());
    }
    setState(() {});
  }

  void _seekMs(int value) {
    _controller.stop();
    _controller.value = value.clamp(0, _durationMs) / _durationMs;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.space): _ToggleIntent(),
        SingleActivator(LogicalKeyboardKey.keyR): _RestartIntent(),
        SingleActivator(LogicalKeyboardKey.keyH): _ControlsIntent(),
        SingleActivator(LogicalKeyboardKey.arrowLeft): _BackIntent(),
        SingleActivator(LogicalKeyboardKey.arrowRight): _ForwardIntent(),
      },
      child: Actions(
        actions: {
          _ToggleIntent: CallbackAction<_ToggleIntent>(
            onInvoke: (_) => _togglePlayback(),
          ),
          _RestartIntent: CallbackAction<_RestartIntent>(
            onInvoke: (_) {
              _seekMs(0);
              return null;
            },
          ),
          _ControlsIntent: CallbackAction<_ControlsIntent>(
            onInvoke: (_) {
              setState(() => _controlsVisible = !_controlsVisible);
              return null;
            },
          ),
          _BackIntent: CallbackAction<_BackIntent>(
            onInvoke: (_) {
              _seekMs(_timeMs - 1000 ~/ navigationPromoFps);
              return null;
            },
          ),
          _ForwardIntent: CallbackAction<_ForwardIntent>(
            onInvoke: (_) {
              _seekMs(_timeMs + 1000 ~/ navigationPromoFps);
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            backgroundColor: const Color(0xFF05070B),
            body: Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: AnimatedBuilder(
                            animation: _controller,
                            builder: (context, _) => RepaintBoundary(
                              key: const ValueKey('navigation-promo-frame'),
                              child: NavigationPromoScene(
                                timeMs: _timeMs,
                                segment: _segment,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_controlsVisible)
                      SizedBox(
                        height: 68,
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, _) => _StudioControls(
                            timeMs: _timeMs,
                            durationMs: _durationMs,
                            playing: _controller.isAnimating,
                            segment: _segment,
                            onSegment: _selectSegment,
                            onPlay: _togglePlayback,
                            onRestart: () => _seekMs(0),
                            onChanged: _seekMs,
                            onHide: () =>
                                setState(() => _controlsVisible = false),
                          ),
                        ),
                      ),
                  ],
                ),
                if (!_controlsVisible)
                  _ShowControlsButton(
                    onPressed: () => setState(() => _controlsVisible = true),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StudioControls extends StatelessWidget {
  const _StudioControls({
    required this.timeMs,
    required this.durationMs,
    required this.playing,
    required this.segment,
    required this.onSegment,
    required this.onPlay,
    required this.onRestart,
    required this.onChanged,
    required this.onHide,
  });

  final int timeMs;
  final int durationMs;
  final bool playing;
  final NavigationPromoSegment segment;
  final ValueChanged<NavigationPromoSegment> onSegment;
  final VoidCallback onPlay;
  final VoidCallback onRestart;
  final ValueChanged<int> onChanged;
  final VoidCallback onHide;

  String _format(int milliseconds) {
    final safeMilliseconds = milliseconds.clamp(0, durationMs);
    final minutes = safeMilliseconds ~/ Duration.millisecondsPerMinute;
    final seconds =
        (safeMilliseconds % Duration.millisecondsPerMinute) ~/
        Duration.millisecondsPerSecond;
    final centiseconds =
        (safeMilliseconds % Duration.millisecondsPerSecond) ~/ 10;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}.'
        '${centiseconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 6, 10, 6),
              decoration: BoxDecoration(
                color: const Color(0xE6151820),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withValues(alpha: .14)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 30,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                children: [
                  for (final value in NavigationPromoSegment.values)
                    _SegmentChip(
                      label: value.label,
                      selected: value == segment,
                      onPressed: () => onSegment(value),
                    ),
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: onRestart,
                    color: Colors.white,
                    tooltip: '처음부터 (R)',
                    constraints: const BoxConstraints.tightFor(
                      width: 36,
                      height: 36,
                    ),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.replay_rounded, size: 20),
                  ),
                  IconButton.filled(
                    onPressed: onPlay,
                    tooltip: '재생/일시정지 (Space)',
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      fixedSize: const Size(36, 36),
                      padding: EdgeInsets.zero,
                    ),
                    icon: Icon(
                      playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor: Colors.white.withValues(alpha: .14),
                        thumbColor: Colors.white,
                        overlayColor: AppColors.primary.withValues(alpha: .16),
                        trackHeight: 2,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                      ),
                      child: Slider(
                        value: timeMs.toDouble(),
                        min: 0,
                        max: durationMs.toDouble(),
                        onChanged: (value) => onChanged(value.round()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 132,
                    child: Text(
                      '${_format(timeMs)} / ${_format(durationMs)}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onHide,
                    color: Colors.white70,
                    tooltip: '컨트롤 숨기기 (H)',
                    constraints: const BoxConstraints.tightFor(
                      width: 32,
                      height: 32,
                    ),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.visibility_off_outlined, size: 17),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SegmentChip extends StatelessWidget {
  const _SegmentChip({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          minimumSize: const Size(0, 28),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: selected
              ? AppColors.primary
              : Colors.white.withValues(alpha: .08),
          foregroundColor: selected ? Colors.white : Colors.white70,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _ShowControlsButton extends StatelessWidget {
  const _ShowControlsButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.all(14),
      child: Align(
        alignment: Alignment.bottomRight,
        child: IconButton.filled(
          onPressed: onPressed,
          tooltip: '재생 컨트롤 보이기 (H)',
          style: IconButton.styleFrom(
            fixedSize: const Size(38, 38),
            backgroundColor: const Color(0xE6151820),
            foregroundColor: Colors.white,
            side: BorderSide(color: Colors.white.withValues(alpha: .16)),
          ),
          icon: const Icon(Icons.tune_rounded, size: 19),
        ),
      ),
    );
  }
}

class _ToggleIntent extends Intent {
  const _ToggleIntent();
}

class _RestartIntent extends Intent {
  const _RestartIntent();
}

class _ControlsIntent extends Intent {
  const _ControlsIntent();
}

class _BackIntent extends Intent {
  const _BackIntent();
}

class _ForwardIntent extends Intent {
  const _ForwardIntent();
}
