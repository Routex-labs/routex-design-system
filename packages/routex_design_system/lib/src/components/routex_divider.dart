import 'package:flutter/material.dart';

import '../foundations/routex_metrics.dart';
import '../foundations/routex_spacing.dart';
import '../theme/routex_color_tokens.dart';

/// 선이 무엇을 가르는지다.
///
/// `section`은 성격이 다른 묶음 사이의 경계라 표면 폭을 가로지르고 위아래로
/// 여백을 가진다. `row`는 같은 목록 안 항목 사이라 제목이 시작하는 자리부터
/// 그어 leading 아이콘 열을 비운다 — 아이콘 열까지 가로지르면 목록이 표가 된다.
enum RoutexDividerRole { section, row }

/// 구분선의 색·두께·들여쓰기와 앞뒤 여백을 역할 하나로 고정한다.
///
/// **선은 마지막 수단이다.** 묶음을 나누는 첫 수단은 여백(`RoutexStack`)이고, 그
/// 다음이 표면(`RoutexSurface`)이며, 그래도 경계가 읽히지 않을 때만 선을 긋는다.
/// 행마다 선을 그으면 여섯 줄짜리 목록이 표처럼 보이면서 시트 전체가 글 덩어리로
/// 읽힌다.
class RoutexDivider extends StatelessWidget {
  const RoutexDivider({this.role = RoutexDividerRole.section, super.key});

  final RoutexDividerRole role;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;

    return Divider(
      // Divider의 height는 선을 포함한 전체 높이다. 여백을 Padding으로 따로 주면
      // 같은 값이 두 곳에 생기므로 여기서 한 번에 잡는다.
      height: switch (role) {
        // 앞뒤로 한 구획씩. 선 자체보다 여백이 경계를 만든다.
        RoutexDividerRole.section => RoutexSpacing.sectionGap + 1,
        RoutexDividerRole.row => 1,
      },
      thickness: 1,
      indent: switch (role) {
        RoutexDividerRole.section => 0,
        RoutexDividerRole.row => RoutexMetrics.textKeyline,
      },
      color: colors.borderSubtle,
    );
  }
}
