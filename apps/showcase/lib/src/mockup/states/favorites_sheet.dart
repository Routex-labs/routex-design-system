import 'package:flutter/material.dart';
import 'package:routex_design_system/routex_design_system.dart';

/// 메뉴에서 여는 저장한 장소 시트다.
///
/// Navigation의 `FavoritesSheet`(pilot 2)와 같은 구조다. 빈 상태, 일반 행,
/// trailing 메뉴, 순서 바꾸기라는 ListCell의 현실적인 변형을 한 화면에서 쓴다.
/// 드래그 재정렬과 저장은 목록을 가진 화면이 맡고, 시트는 시각 구조만 고정한다.
class FavoritesSheet extends StatelessWidget {
  const FavoritesSheet({
    required this.places,
    required this.onPick,
    required this.onMore,
    required this.onBack,
    required this.onClose,
    super.key,
  });

  final List<String> places;
  final ValueChanged<String> onPick;
  final ValueChanged<String> onMore;
  final VoidCallback onBack;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return RoutexBottomSheet(
      header: RoutexSheetHeader(
        title: '저장한 장소',
        onBack: onBack,
        onClose: onClose,
      ),
      child: places.isEmpty
          // 빈 상태 문구는 실제로 보이는 control의 이름을 쓴다. 예전 앱은 "+ 버튼"을
          // 안내했지만 화면에는 저장 아이콘만 있었다.
          ? const RoutexEmptyState(
              title: '저장한 장소 없음',
              description: '장소 상세에서 저장을 누르면 여기에 쌓입니다.',
              icon: RoutexIcons.save,
            )
          : RoutexStack(
              gap: RoutexStackGap.control,
              children: [
                for (final place in places)
                  RoutexListCell(
                    key: ValueKey('mockup-favorite-$place'),
                    title: place,
                    subtitle: '더현대 서울 1F',
                    leadingIcon: RoutexIcons.saved,
                    trailingActionLabel: '$place 더보기',
                    onTrailingAction: () => onMore(place),
                    reorderable: true,
                    onPressed: () => onPick(place),
                  ),
              ],
            ),
    );
  }
}
