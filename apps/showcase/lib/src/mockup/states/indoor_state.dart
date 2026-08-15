import 'package:flutter/material.dart';
import 'package:routex_design_system/routex_design_system.dart';

class IndoorState extends StatelessWidget {
  const IndoorState({
    required this.floor,
    required this.progress,
    required this.playing,
    required this.onFloor,
    required this.onPlay,
    required this.onArrival,
    required this.onStop,
    super.key,
  });

  final int floor;
  final double progress;
  final bool playing;
  final ValueChanged<int> onFloor;
  final VoidCallback onPlay;
  final VoidCallback onArrival;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return RoutexMapOverlay(
      top: const RoutexManeuverBanner(
        distance: '복도를 따라 45m',
        detail: '엘리베이터 앞에서 발렌시아가 방향',
        icon: RoutexIcons.straight,
      ),
      leadingControls: [
        RoutexFloorSelector(
          options: const [
            RoutexFloorOption(id: 2, label: '2F'),
            RoutexFloorOption(id: 1, label: '1F'),
            RoutexFloorOption(id: -1, label: 'B1'),
          ],
          selectedId: floor,
          onSelected: onFloor,
        ),
      ],
      trailingControls: [
        RoutexMapControl(
          icon: playing ? RoutexIcons.pause : RoutexIcons.play,
          label: playing ? '안내 일시정지' : '안내 재생',
          selected: playing,
          onPressed: onPlay,
        ),
        RoutexMapControl(
          icon: RoutexIcons.arrived,
          label: '도착 상태 확인',
          onPressed: onArrival,
        ),
      ],
      sheet: RoutexTripProgress(
        metrics: [
          RoutexTripMetric(
            value: '${(3 - progress * 2).clamp(1, 3).ceil()}분 후',
            label: '예상 시각',
          ),
          RoutexTripMetric(
            value: '${(3 - progress * 2).clamp(1, 3).ceil()}분',
            label: '남은 시간',
          ),
          RoutexTripMetric(
            value: '${(260 * (1 - progress)).clamp(0, 120).round()}m',
            label: '남은 거리',
          ),
        ],
        onStop: onStop,
      ),
    );
  }
}
