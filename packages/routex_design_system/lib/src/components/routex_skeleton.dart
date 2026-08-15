import 'package:flutter/material.dart';

import '../foundations/routex_metrics.dart';
import '../foundations/routex_radii.dart';
import '../foundations/routex_spacing.dart';
import '../foundations/routex_typography.dart';
import '../layout/routex_stack.dart';
import '../theme/routex_color_tokens.dart';

/// 자리표시가 대신하는 콘텐츠의 모양이다.
enum RoutexSkeletonShape {
  /// 한 줄 글자. 높이가 글자 배율을 따라간다.
  line,

  /// 표면 안의 덩어리 하나(요약 블록, 카드 본문).
  block,

  /// 목록 행 안의 사진.
  thumbnail,

  /// 상세 첫 화면의 대표 사진 띠.
  media,
}

/// 아직 오지 않은 콘텐츠의 자리를 같은 크기의 회색 면으로 잡아 둔다.
///
/// **가짜 콘텐츠를 그리지 않기 위한 장치다.** 데이터가 없는데 그럴듯한 사진·메뉴를
/// placeholder로 채우는 것은 v0.1이 금지한 실패 조건이고, 그렇다고 빈 화면을 두면
/// 값이 도착하는 순간 아래 내용이 통째로 밀려 내려간다. 자리표시는 "여기에 무엇이
/// 올 것이다"만 말하고 내용은 말하지 않는다.
///
/// **글자 자리표시는 글자 배율을 따라간다.** 고정 높이로 두면 200% 배율에서 값이
/// 도착한 뒤 줄 높이가 두 배로 뛰어, 자리를 잡아 둔 의미가 사라진다.
///
/// **움직이지 않는다.** 한때 숨쉬듯 밝기를 오가게 했는데, 자리표시 하나가 곧 하나의
/// 애니메이션 컨트롤러라 목록 하나에 열 개 넘게 살아 있게 된다. 화면에 로딩 예시가
/// 하나만 있어도 프레임이 끝없이 그려져, 아무도 보고 있지 않은 동안 기기가 계속
/// 일한다. 자리표시의 목적은 자리를 잡는 것이고, **진행 중이라는 사실은 문장이
/// 말한다**(`RoutexResultList.loadingMessage`). 두 장치가 같은 말을 반복할 이유가 없다.
class RoutexSkeleton extends StatelessWidget {
  const RoutexSkeleton({required this.shape, this.widthFactor, super.key})
    : assert(
        widthFactor == null || (widthFactor > 0 && widthFactor <= 1),
        '폭은 부모 폭에 대한 비율로만 줄인다',
      );

  final RoutexSkeletonShape shape;

  /// 마지막 줄처럼 폭이 덜 찬 글자 자리를 표현한다. 줄마다 폭이 같으면 글이
  /// 아니라 표로 읽힌다.
  final double? widthFactor;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    final textScaler = MediaQuery.textScalerOf(context);

    final height = switch (shape) {
      // 글자 한 줄이 실제로 차지하는 line box다. 값이 도착했을 때 줄 높이가
      // 바뀌지 않아야 자리표시가 자리를 잡은 것이 된다.
      RoutexSkeletonShape.line => textScaler.scale(
        RoutexTypography.body.fontSize! * RoutexTypography.body.height!,
      ),
      RoutexSkeletonShape.block => RoutexMetrics.standardControl,
      RoutexSkeletonShape.thumbnail => RoutexMetrics.thumbnail,
      RoutexSkeletonShape.media => RoutexMetrics.mediaBand,
    };

    final surface = FractionallySizedBox(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: widthFactor,
      child: SizedBox(
        height: height,
        width: shape == RoutexSkeletonShape.thumbnail
            ? RoutexMetrics.thumbnail
            : double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceCanvas,
            borderRadius: switch (shape) {
              RoutexSkeletonShape.line => RoutexRadii.control,
              RoutexSkeletonShape.block ||
              RoutexSkeletonShape.thumbnail => RoutexRadii.field,
              RoutexSkeletonShape.media => RoutexRadii.card,
            },
          ),
        ),
      ),
    );

    return Semantics(
      // 내용이 없는 면이라 읽을 것이 없다. 대신 화면이 아직 준비 중이라는 사실만
      // 한 번 말한다. 자리표시 하나하나가 말하면 목록이 열 번 읽힌다.
      label: '불러오는 중',
      excludeSemantics: true,
      child: surface,
    );
  }
}

/// 목록이 아직 오지 않았을 때의 행 자리표시다.
///
/// 행 하나의 모양은 `RoutexListCell`의 leading 열·제목·부제 구조를 그대로 따른다.
/// 자리표시와 실제 행의 구조가 다르면 값이 도착하는 순간 목록 전체가 튄다.
class RoutexSkeletonList extends StatelessWidget {
  const RoutexSkeletonList({this.count = 3, super.key}) : assert(count > 0);

  final int count;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '목록을 불러오는 중',
      excludeSemantics: true,
      child: RoutexStack(
        gap: RoutexStackGap.content,
        children: [
          for (var index = 0; index < count; index++)
            Padding(
              // 행의 세로 여백은 `RoutexListCell`과 같다. 값이 도착했을 때 목록
              // 전체가 위로 튀지 않게 한다.
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: RoutexSpacing.contentGap,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: RoutexMetrics.leadingColumn,
                    child: RoutexSkeleton(shape: RoutexSkeletonShape.line),
                  ),
                  const SizedBox(width: RoutexSpacing.contentGap),
                  Expanded(
                    child: RoutexStack(
                      gap: RoutexStackGap.inline,
                      children: [
                        const RoutexSkeleton(shape: RoutexSkeletonShape.line),
                        RoutexSkeleton(
                          shape: RoutexSkeletonShape.line,
                          // 부제는 제목보다 짧다. 두 줄 폭이 같으면 목록이 아니라
                          // 표가 로딩되는 것처럼 보인다.
                          widthFactor: index.isEven ? 0.6 : 0.45,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
