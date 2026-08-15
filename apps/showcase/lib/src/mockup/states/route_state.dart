import 'package:flutter/material.dart';
import 'package:routex_design_system/routex_design_system.dart';

import '../../data/showcase_navigation_data.dart';

class RouteState extends StatelessWidget {
  const RouteState({
    required this.place,
    required this.selectedRoute,
    required this.onRoute,
    required this.onStart,
    required this.onRecenter,
    required this.onClose,
    required this.onEditDestination,
    super.key,
  });

  final ShowcasePlaceData place;
  final int selectedRoute;
  final ValueChanged<int> onRoute;
  final VoidCallback onStart;
  final VoidCallback onRecenter;
  final VoidCallback onClose;
  final VoidCallback onEditDestination;

  @override
  Widget build(BuildContext context) {
    return RoutexMapOverlay(
      top: RoutexRoutePlanner(
        originLabel: '현재 위치',
        destinationLabel:
            '${place.buildingName} ${place.floorName} · ${place.name}',
        travelModes: const [
          RoutexTravelModeOption(
            id: 'walk',
            label: '도보',
            icon: RoutexIcons.walk,
          ),
        ],
        selectedTravelModeId: 'walk',
        onTravelModeSelected: (_) {},
        onOriginPressed: onClose,
        onDestinationPressed: onEditDestination,
        onClose: onClose,
        onDestinationMore: onEditDestination,
      ),
      trailingControls: [
        RoutexMapControl(
          icon: RoutexIcons.fitRoute,
          label: '전체 경로',
          onPressed: onRecenter,
        ),
      ],
      sheet: RoutexBottomSheet(
        child: RoutexStack(
          gap: RoutexStackGap.control,
          children: [
            RoutexRouteOption(
              title: '6분',
              detail: '410m · 실내 연결 통로',
              meta: '추천',
              selected: selectedRoute == 0,
              onPressed: () => onRoute(0),
            ),
            RoutexRouteOption(
              title: '7분',
              detail: '460m · 엘리베이터 우선',
              meta: '+1분',
              selected: selectedRoute == 1,
              onPressed: () => onRoute(1),
            ),
            SizedBox(
              width: double.infinity,
              child: RoutexButton(label: '안내 시작', onPressed: onStart),
            ),
          ],
        ),
      ),
    );
  }
}
