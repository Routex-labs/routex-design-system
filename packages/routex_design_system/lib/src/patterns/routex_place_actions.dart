import 'package:flutter/material.dart';

import '../foundations/routex_spacing.dart';
import '../components/routex_button.dart';

/// 장소 하나를 경로의 어느 끝으로 쓸지 고르는 한 쌍이다.
///
/// **위계가 고정이다.** 도착이 primary, 출발이 secondary다. 두 버튼을 같은 무게로
/// 그리면 한 화면에 primary가 둘이 되고(v0.1 실패 조건), 무엇보다 이 시트를 연 사람의
/// 열에 아홉은 "여기로 간다"를 누른다. 출발지로 쓰는 것은 경로를 다시 짜는 사람의
/// 동작이라 빈도가 다르다.
///
/// **가로로 늘리지 않는다.** 글자가 두 자뿐이라 폭을 채우면 여백만 커진다. 시작선에
/// 붙여 한 쌍으로 읽히게 둔다.
///
/// **바닥 고정 바로 두지 않는다.** 스크롤 위치와 무관하게 닿는다는 이점보다, 두 자짜리
/// 버튼이 늘 화면 바닥을 한 줄 차지하는 부담이 크다. 이름 바로 아래가 제자리다 —
/// 길찾기는 이 시트의 목적이라 사진·메뉴보다 먼저 눈에 닿아야 한다.
class RoutexPlaceActions extends StatelessWidget {
  const RoutexPlaceActions({
    required this.onOrigin,
    required this.onDestination,
    super.key,
  });

  /// 이 장소를 출발지로 삼는다. null이면 지금은 출발지로 쓸 수 없다는 뜻이다 —
  /// 버튼을 숨기지 않는다. 숨기면 이 장소만 다른 기능을 가진 것처럼 보인다.
  final VoidCallback? onOrigin;

  final VoidCallback? onDestination;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        RoutexButton(
          label: '출발',
          variant: RoutexButtonVariant.secondary,
          onPressed: onOrigin,
        ),
        const SizedBox(width: RoutexSpacing.controlGap),
        RoutexButton(label: '도착', onPressed: onDestination),
      ],
    );
  }
}
