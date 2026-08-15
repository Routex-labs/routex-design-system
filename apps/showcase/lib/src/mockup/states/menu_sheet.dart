import 'package:flutter/material.dart';
import 'package:routex_design_system/routex_design_system.dart';

/// 상단 바 메뉴 버튼이 여는 앱 메뉴 시트다.
///
/// Navigation의 `AppMenuSheet`(pilot 1)과 같은 구조다. 시트는 고른 항목만
/// 돌려주고 동작은 지도 상태를 가진 화면이 수행한다. 여기서는 handle·header·
/// 구획 라벨·목록 행이 전부 Runtime Kit 계약을 쓰는지 확인한다.
class MenuSheet extends StatelessWidget {
  const MenuSheet({
    required this.debugEnabled,
    required this.showPlaceLocation,
    required this.onFavorites,
    required this.onDirections,
    required this.onPlaceLocation,
    required this.onCalibrate,
    required this.onDebug,
    required this.onClose,
    super.key,
  });

  final bool debugEnabled;

  /// 건물 안이 아니면 지정할 층이 없어 항목을 숨긴다.
  final bool showPlaceLocation;

  final VoidCallback onFavorites;
  final VoidCallback onDirections;
  final VoidCallback onPlaceLocation;
  final VoidCallback onCalibrate;
  final VoidCallback onDebug;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return RoutexBottomSheet(
      header: RoutexSheetHeader(title: '메뉴', onClose: onClose),
      child: RoutexStack(
        gap: RoutexStackGap.control,
        children: [
          const RoutexSectionHeader(
            title: '찾기',
            level: RoutexSectionHeaderLevel.group,
          ),
          RoutexListCell(
            key: const ValueKey('mockup-menu-favorites'),
            title: '저장한 장소',
            subtitle: '저장해 둔 매장을 목록에서 고릅니다',
            leadingIcon: RoutexIcons.save,
            onPressed: onFavorites,
          ),
          RoutexListCell(
            title: '길찾기',
            subtitle: '출발지·도착지를 골라 경로를 그립니다',
            leadingIcon: RoutexIcons.directions,
            onPressed: onDirections,
          ),
          const RoutexSectionHeader(
            title: '내 위치',
            level: RoutexSectionHeaderLevel.group,
          ),
          if (showPlaceLocation)
            RoutexListCell(
              title: '지도에서 내 위치 지정',
              subtitle: '도면 위 한 점을 탭해 현재 위치를 직접 찍습니다',
              leadingIcon: RoutexIcons.placeLocation,
              onPressed: onPlaceLocation,
            ),
          RoutexListCell(
            title: '위치 보정',
            subtitle: '방위와 현재 위치를 다시 맞춥니다',
            leadingIcon: RoutexIcons.calibrate,
            onPressed: onCalibrate,
          ),
          const RoutexSectionHeader(
            title: '개발자',
            level: RoutexSectionHeaderLevel.group,
          ),
          RoutexListCell(
            key: const ValueKey('mockup-menu-debug'),
            title: '디버그 설정',
            subtitle: debugEnabled
                ? '사용 중 · PDR 제어와 진단 레이어가 지도에 표시됩니다'
                : '꺼짐 · PDR 제어와 진단 레이어를 켤 수 있습니다',
            leadingIcon: RoutexIcons.debug,
            selected: debugEnabled,
            onPressed: onDebug,
          ),
        ],
      ),
    );
  }
}
