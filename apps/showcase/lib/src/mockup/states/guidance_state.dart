import 'package:flutter/material.dart';
import 'package:routex_design_system/routex_design_system.dart';

class GuidanceState extends StatelessWidget {
  const GuidanceState({
    required this.muted,
    required this.mapMoved,
    required this.progress,
    required this.playing,
    required this.onMuted,
    required this.onPlay,
    required this.onIndoor,
    required this.onRecenter,
    required this.onStop,
    super.key,
  });

  final bool muted;
  final bool mapMoved;
  final double progress;
  final bool playing;
  final ValueChanged<bool> onMuted;
  final VoidCallback onPlay;
  final VoidCallback onIndoor;
  final VoidCallback onRecenter;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return RoutexMapOverlay(
      top: const RoutexManeuverBanner(
        distance: '120m 후 건물로 진입',
        detail: '더현대 서울 1층 · 명품관 방향',
        icon: RoutexIcons.turnRight,
      ),
      leadingControls: [
        RoutexMapControl(
          icon: RoutexIcons.floors,
          label: '실내 안내로 전환',
          text: '1F',
          onPressed: onIndoor,
        ),
      ],
      trailingControls: [
        RoutexMapControl(
          icon: muted ? RoutexIcons.muted : RoutexIcons.unmuted,
          label: muted ? '음성 켜기' : '음소거',
          selected: muted,
          onPressed: () => onMuted(!muted),
        ),
        RoutexMapControl(
          icon: RoutexIcons.followLocation,
          label: mapMoved ? '지도 다시 따라가기' : '현재 위치 추적 중',
          selected: !mapMoved,
          onPressed: onRecenter,
        ),
        RoutexMapControl(
          icon: playing ? RoutexIcons.pause : RoutexIcons.play,
          label: playing ? '안내 일시정지' : '안내 재생',
          selected: playing,
          onPressed: onPlay,
        ),
      ],
      sheet: RoutexTripProgress(
        metrics: [
          RoutexTripMetric(
            value: '${(6 - progress * 5).ceil()}분 후',
            label: '예상 시각',
          ),
          RoutexTripMetric(
            value: '${(6 - progress * 5).ceil()}분',
            label: '남은 시간',
          ),
          RoutexTripMetric(
            value: '${(410 * (1 - progress)).round()}m',
            label: '남은 거리',
          ),
        ],
        onStop: onStop,
      ),
    );
  }
}
