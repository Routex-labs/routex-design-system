import 'package:flutter/material.dart';

import '../foundations/routex_icons.dart';
import '../foundations/routex_spacing.dart';
import '../foundations/routex_typography.dart';
import '../components/routex_disclosure.dart';
import '../theme/routex_color_tokens.dart';

/// 지금 문을 열었는지에 대한 답이다.
enum RoutexHoursState {
  open,
  closed,

  /// 판정할 수 없다. 데이터가 오래됐거나 이 매장의 시간을 모른다.
  ///
  /// **닫힘으로 떨어뜨리지 않는다.** 열려 있는 매장을 돌려보내는 것이 이 섹션이
  /// 만들 수 있는 가장 비싼 거짓말이다. 모른다는 사실을 말하는 편이 낫다.
  unknown,
}

/// 요일 한 줄이다.
@immutable
class RoutexHoursDay {
  const RoutexHoursDay({
    required this.label,
    required this.value,
    this.note,
    this.closed = false,
  });

  /// `화(8/11)`처럼 요일과 날짜를 한 낱말로 적은 값이다. 서식은 소비 앱이 정한다 —
  /// 날짜 표기는 지역과 데이터 출처를 따라가는 값이지 디자인 결정이 아니다.
  final String label;

  /// `10:30 - 20:00`, `휴무`처럼 그날의 영업시간이다.
  final String value;

  /// 그날만 다른 이유다. 없으면 그리지 않는다. 이 줄이 빠지면 휴점일이 "그냥 닫힌
  /// 날"과 구분되지 않는다.
  final String? note;

  /// 영업하지 않는 날인지. 값의 무게를 낮춰 표에서 한눈에 걸러 보게 한다.
  final bool closed;
}

/// 영업 상태 한 줄과 요일 표를 함께 세운다.
///
/// **판정은 여기서 하지 않는다.** 지금 열었는지, 다음 전환이 언제인지는 소비 앱의
/// 순수 함수가 계산하고 이 컴포넌트는 결과를 문장으로 바꾸기만 한다. 시각 비교가
/// 위젯 안에 있으면 경계(폐점 정각·자정 넘김)를 화면 없이 확인할 수 없다.
///
/// **오늘 줄은 접혀 있어도 보인다.** 이 섹션을 보는 사람의 질문은 거의 언제나 "지금
/// 갈 수 있나"이고 그 다음이 "오늘 몇 시까지"다([RoutexDisclosure.preview]).
class RoutexHours extends StatelessWidget {
  const RoutexHours({
    required this.state,
    required this.days,
    required this.expanded,
    required this.onExpanded,
    this.detail,
    this.staleNote,
    super.key,
  });

  final RoutexHoursState state;

  /// 오늘부터 시작하는 요일 줄이다. 첫 줄이 오늘이다.
  final List<RoutexHoursDay> days;

  /// `20:00 종료`, `내일 10:30 영업 시작`처럼 다음 전환을 적은 말이다.
  ///
  /// 없으면 상태만 적는다. 종일 영업과 "앞으로 여는 날이 없음"은 전혀 다른 말이라
  /// 같은 문구로 덮지 않는다 — 어느 쪽인지 아는 것은 데이터를 가진 소비 앱이다.
  final String? detail;

  /// 데이터가 오래됐을 때 남기는 근거 한 줄이다.
  final String? staleNote;

  final bool expanded;
  final ValueChanged<bool> onExpanded;

  @override
  Widget build(BuildContext context) {
    assert(days.isNotEmpty, '요일이 하나도 없으면 섹션을 그리지 않는다');
    final colors = context.routexColors;
    final headline = switch (state) {
      RoutexHoursState.open => '영업 중',
      RoutexHoursState.closed => '영업 종료',
      RoutexHoursState.unknown => '영업시간 정보가 오래됐어요',
    };

    return RoutexDisclosure(
      leadingIcon: RoutexIcons.schedule,
      semanticsLabel: detail == null ? headline : '$headline, $detail',
      expanded: expanded,
      onExpanded: onExpanded,
      header: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: headline,
              style: RoutexTypography.label.copyWith(
                // 열려 있다는 것만 색으로 말한다. 닫힘까지 색을 주면 "지금 갈 수
                // 있나"의 답이 두 색 중 무엇인지를 다시 읽어야 한다.
                color: state == RoutexHoursState.open
                    ? colors.actionPrimary
                    : colors.contentPrimary,
              ),
            ),
            if (detail != null)
              TextSpan(
                text: ' · $detail',
                style: RoutexTypography.bodySmall.copyWith(
                  color: colors.contentSecondary,
                ),
              ),
          ],
        ),
      ),
      preview: _HoursRow(day: days.first, isToday: true),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final day in days.skip(1)) _HoursRow(day: day, isToday: false),
          if (staleNote?.trim().isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsetsDirectional.only(
                top: RoutexSpacing.controlGap,
              ),
              child: Text(
                staleNote!,
                style: RoutexTypography.caption.copyWith(
                  color: colors.contentSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 요일 라벨 열의 폭이다. `화(8/11)` 다섯 글자가 들어가는 값이다.
///
/// 줄마다 라벨 폭을 제 글자에 맞추면 `월(8/4)`과 `수(8/13)`의 시간 열이 어긋난다.
/// 표는 세로로 읽는 것이라 시작선이 흔들리면 값끼리 비교할 수 없다.
const _labelColumn = 88.0;

class _HoursRow extends StatelessWidget {
  const _HoursRow({required this.day, required this.isToday});

  final RoutexHoursDay day;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    final emphasis = isToday
        ? RoutexTypography.label
        : RoutexTypography.bodySmall;

    return Semantics(
      container: true,
      label: '${day.label}, ${day.value}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          vertical: RoutexSpacing.inlineGap,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: _labelColumn,
              child: Text(
                day.label,
                style: emphasis.copyWith(
                  color: isToday
                      ? colors.contentPrimary
                      : colors.contentSecondary,
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day.value,
                    style: RoutexTypography.tabular(emphasis).copyWith(
                      color: day.closed
                          ? colors.contentSecondary
                          : colors.contentPrimary,
                    ),
                  ),
                  if (day.note?.trim().isNotEmpty ?? false)
                    Text(
                      day.note!,
                      style: RoutexTypography.caption.copyWith(
                        color: colors.contentSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
