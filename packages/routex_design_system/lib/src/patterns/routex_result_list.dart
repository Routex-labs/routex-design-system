import 'package:flutter/material.dart';

import '../foundations/routex_icons.dart';
import '../foundations/routex_metrics.dart';
import '../foundations/routex_spacing.dart';
import '../foundations/routex_typography.dart';
import '../components/routex_empty_state.dart';
import '../components/routex_skeleton.dart';
import '../components/routex_sort_menu.dart';
import '../layout/routex_stack.dart';
import '../theme/routex_color_tokens.dart';

/// 목록이 지금 어느 상태인지다.
enum RoutexResultStatus {
  /// 아직 답을 기다린다. 자리표시를 그리고, 아는 것이 있으면 무엇을 기다리는지
  /// 한 줄로 말한다.
  loading,

  /// 찾지 못했고 **더 시도할 경로가 없다.**
  ///
  /// 이 상태를 너무 일찍 쓰면 안 된다. 1차 검색이 빈손이지만 2차가 남아 있는
  /// 동안 "찾지 못했어요"를 띄우면 사용자는 그것을 최종 결론으로 읽고 앱이 못
  /// 찾는다고 판단한다. 아직 시도가 남았으면 [loading]이다.
  empty,

  /// 결과가 있다.
  ready,
}

/// 검색·분류 결과 목록의 상태, 요약 줄, 정렬 자리를 한 컴포넌트로 고정한다.
///
/// **세 상태가 한 곳에 있어야 하는 이유.** 목록을 그리는 화면마다 "찾는 중"과 "없음"을
/// 따로 만들면 어떤 화면은 빈손을 스피너로, 어떤 화면은 빈 목록으로 두게 된다. 같은
/// 질문("지금 결과가 있나")에 화면마다 다른 모양으로 답하는 것이 v0.1이 고치기로 한
/// 문제다.
///
/// 목록 행 자체는 `RoutexListCell`이 그린다. 이 컴포넌트는 행을 만들지 않고 상태와
/// 머리 줄만 소유한다.
class RoutexResultList extends StatelessWidget {
  const RoutexResultList({
    required this.status,
    required this.children,
    this.summary,
    this.loadingMessage,
    this.sortOptions = const <RoutexSortOption>[],
    this.selectedSortId,
    this.onSortSelected,
    this.emptyTitle = '찾지 못했어요',
    this.emptyDescription = '다른 이름이나 분류로 다시 찾아보세요.',
    this.emptyActionLabel,
    this.onEmptyAction,
    super.key,
  });

  final RoutexResultStatus status;

  /// [RoutexResultStatus.ready]일 때 세울 행들이다.
  final List<Widget> children;

  /// `32개 결과`처럼 결과를 세는 한 줄이다. 서식은 소비 앱이 정한다.
  final String? summary;

  /// 기다리는 동안 무엇을 하고 있는지. `실내 매장을 찾는 중`처럼 적는다.
  final String? loadingMessage;

  final List<RoutexSortOption> sortOptions;
  final String? selectedSortId;
  final ValueChanged<String>? onSortSelected;

  final String emptyTitle;
  final String emptyDescription;
  final String? emptyActionLabel;
  final VoidCallback? onEmptyAction;

  bool get _hasHeader =>
      (summary?.trim().isNotEmpty ?? false) || sortOptions.length > 1;

  @override
  Widget build(BuildContext context) {
    assert(
      sortOptions.length < 2 ||
          (selectedSortId != null && onSortSelected != null),
      '정렬 선택지를 주면 지금 기준과 바꾸는 동작도 함께 준다',
    );
    final colors = context.routexColors;

    return RoutexStack(
      gap: RoutexStackGap.content,
      children: [
        if (_hasHeader)
          Row(
            children: [
              Expanded(
                child: Text(
                  summary ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: RoutexTypography.bodySmall.copyWith(
                    color: colors.contentSecondary,
                  ),
                ),
              ),
              if (sortOptions.length > 1)
                RoutexSortMenu(
                  options: sortOptions,
                  selectedId: selectedSortId!,
                  onSelected: onSortSelected!,
                ),
            ],
          ),
        switch (status) {
          RoutexResultStatus.loading => _Loading(message: loadingMessage),
          RoutexResultStatus.empty => RoutexEmptyState(
            title: emptyTitle,
            description: emptyDescription,
            icon: RoutexIcons.empty,
            actionLabel: emptyActionLabel,
            onAction: onEmptyAction,
          ),
          RoutexResultStatus.ready => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        },
      ],
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading({required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;

    return RoutexStack(
      gap: RoutexStackGap.content,
      children: [
        // **회전 표시를 함께 두지 않는다.** 자리표시 줄이 이미 "무엇이 올 것인가"를
        // 그리고 있고, "지금 하고 있다"는 이 문장이 말한다. 셋을 다 두면 같은 상태를
        // 세 번 알리면서 화면이 쉬지 않고 다시 그려진다.
        if (message?.trim().isNotEmpty ?? false)
          Semantics(
            liveRegion: true,
            child: Row(
              children: [
                Icon(
                  RoutexIcons.recent,
                  size: RoutexMetrics.iconSmall,
                  color: colors.contentSecondary,
                ),
                const SizedBox(width: RoutexSpacing.controlGap),
                Expanded(
                  child: Text(
                    message!,
                    style: RoutexTypography.bodySmall.copyWith(
                      color: colors.contentSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const RoutexSkeletonList(),
      ],
    );
  }
}
