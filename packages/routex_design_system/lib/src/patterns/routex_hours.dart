import 'package:flutter/material.dart';

import '../foundations/routex_icons.dart';
import '../foundations/routex_spacing.dart';
import '../foundations/routex_typography.dart';
import '../components/routex_disclosure.dart';
import '../layout/routex_stack.dart';
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

  /// `화`처럼 반복 영업시간의 요일을 적은 값이다. 특정 날짜의 예외 영업이라면
  /// 날짜를 이 라벨에 섞지 말고 [note]로 이유와 함께 알린다.
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
/// 갈 수 있나"이고 그 다음이 "오늘 몇 시까지"다. 상태와 오늘 시간을 한 header
/// 묶음으로 두어 두 줄 사이에 별도 본문 간격이 생기지 않게 한다.
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
  ///
  /// 접혀 있어도 보인다. 머리 줄의 "정보가 오래됐어요"는 주장이고 이 줄이 그
  /// 근거이므로, 주장만 보이고 근거는 펼쳐야 나오면 읽는 사람이 무엇을 보고
  /// 판단할지 알 수 없다. 오래되지 않았으면 넘기지 않는다 — 늘 넘기면 멀쩡한
  /// 데이터에도 경고가 붙는다.
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
      header: RoutexStack(
        gap: RoutexStackGap.inline,
        children: [
          Text.rich(
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
          _HoursRow(day: days.first, isToday: true, compact: true),
        ],
      ),
      preview: (staleNote?.trim().isNotEmpty ?? false)
          ? Padding(
              padding: const EdgeInsetsDirectional.only(
                top: RoutexSpacing.controlGap,
              ),
              child: Text(
                staleNote!,
                style: RoutexTypography.caption.copyWith(
                  color: colors.contentSecondary,
                ),
              ),
            )
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final day in days.skip(1)) _HoursRow(day: day, isToday: false),
        ],
      ),
    );
  }
}

class _HoursRow extends StatelessWidget {
  const _HoursRow({
    required this.day,
    required this.isToday,
    this.compact = false,
  });

  final RoutexHoursDay day;
  final bool isToday;
  final bool compact;

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
        padding: EdgeInsetsDirectional.symmetric(
          vertical: compact ? 0 : RoutexSpacing.inlineGap,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: day.label,
                    style: emphasis.copyWith(
                      color: isToday
                          ? colors.contentPrimary
                          : colors.contentSecondary,
                    ),
                  ),
                  TextSpan(
                    text: ' · ',
                    style: emphasis.copyWith(color: colors.contentSecondary),
                  ),
                  TextSpan(
                    text: day.value,
                    style: RoutexTypography.tabular(emphasis).copyWith(
                      color: day.closed
                          ? colors.contentSecondary
                          : colors.contentPrimary,
                    ),
                  ),
                ],
              ),
            ),
            if (day.note?.trim().isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  top: RoutexSpacing.inlineGap,
                ),
                child: Text(
                  day.note!,
                  style: RoutexTypography.caption.copyWith(
                    color: colors.contentSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
