import 'package:flutter/material.dart';
import 'package:routex_design_system/routex_design_system.dart';

import '../../data/showcase_navigation_data.dart';

class PlaceState extends StatelessWidget {
  const PlaceState({
    required this.place,
    required this.saved,
    required this.mapMoved,
    required this.onSaved,
    required this.onDetail,
    required this.onBack,
    required this.onRoute,
    required this.onRecenter,
    super.key,
  });

  final ShowcasePlaceData place;
  final bool saved;
  final bool mapMoved;
  final ValueChanged<bool> onSaved;
  final VoidCallback onDetail;
  final VoidCallback onBack;
  final VoidCallback onRoute;
  final VoidCallback onRecenter;

  @override
  Widget build(BuildContext context) {
    return RoutexMapOverlay(
      top: RoutexSearchBar(
        placeholder: '건물, 장소를 검색하세요',
        onSearchPressed: onDetail,
        // 장소를 고른 뒤에도 상단 바의 왼쪽 자리는 비지 않는다. 메인으로
        // 돌아가는 뒤로가 그 자리를 맡는다.
        leading: RoutexSearchLeading.back,
        onLeadingPressed: onBack,
        onDirectionsPressed: onRoute,
      ),
      trailingControls: [
        RoutexMapControl(
          icon: RoutexIcons.currentLocation,
          label: mapMoved ? '현재 위치로 이동' : '현재 위치',
          onPressed: onRecenter,
        ),
      ],
      notice: saved
          ? RoutexInlineNotice(
              message: '저장됨',
              actionLabel: '실행 취소',
              onAction: () => onSaved(false),
            )
          : null,
      sheet: RoutexBottomSheet(
        child: RoutexStack(
          gap: RoutexStackGap.content,
          children: [
            RoutexPlaceHeader(
              key: const ValueKey('mockup-open-detail'),
              name: place.name,
              metadata:
                  '${place.floorName} · ${place.category}${place.subcategory == null ? '' : ' · ${place.subcategory}'}',
              supportingText: '${place.buildingName} · 현재 위치에서 약 320m',
              saved: saved,
              onSaved: onSaved,
              onToggleExpanded: onDetail,
            ),
            SizedBox(
              width: double.infinity,
              child: RoutexButton(
                label: '길찾기',
                onPressed: place.entranceNodeId == null ? null : onRoute,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
