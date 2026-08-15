import 'package:flutter/material.dart';
import 'package:routex_design_system/routex_design_system.dart';

import '../../data/showcase_navigation_data.dart';

class ArrivalState extends StatelessWidget {
  const ArrivalState({
    required this.place,
    required this.saved,
    required this.onSaved,
    required this.onEnd,
    required this.onDetail,
    super.key,
  });

  final ShowcasePlaceData place;
  final bool saved;
  final ValueChanged<bool> onSaved;
  final VoidCallback onEnd;
  final VoidCallback onDetail;

  @override
  Widget build(BuildContext context) {
    return RoutexMapOverlay(
      top: RoutexStatusBanner(
        title: '목적지에 도착했습니다',
        detail: '${place.buildingName} · ${place.floorName} ${place.name} 앞',
        icon: RoutexIcons.success,
        tone: RoutexStatusBannerTone.success,
      ),
      // 상단 배너가 이미 도착과 장소를 말한다. 시트에서 같은 장소명을 다시
      // 제목으로 쓰면 무엇이 이 화면의 주 정보인지 흐려지므로, 여기서는 도착
      // 뒤에 할 수 있는 행동만 남긴다.
      sheet: RoutexBottomSheet(
        child: RoutexStack(
          gap: RoutexStackGap.control,
          children: [
            RoutexListCell(
              title: '${place.name} 정보 보기',
              subtitle: '영업시간·메뉴·사진을 확인합니다',
              leadingIcon: RoutexIcons.place,
              trailingIcon: RoutexIcons.forward,
              onPressed: onDetail,
            ),
            RoutexListCell(
              title: saved ? '저장 취소' : '이 장소 저장',
              subtitle: '저장한 장소 목록에서 다시 찾습니다',
              leadingIcon: saved ? RoutexIcons.saved : RoutexIcons.save,
              selected: saved,
              onPressed: () => onSaved(!saved),
            ),
            SizedBox(
              width: double.infinity,
              child: RoutexButton(
                label: '안내 종료',
                variant: RoutexButtonVariant.secondary,
                onPressed: onEnd,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
