import 'package:flutter/material.dart';

import '../foundations/routex_icons.dart';
import '../foundations/routex_metrics.dart';
import '../foundations/routex_radii.dart';
import '../foundations/routex_spacing.dart';
import '../foundations/routex_typography.dart';
import '../components/routex_bottom_sheet.dart';
import '../components/routex_button.dart';
import '../layout/routex_stack.dart';
import '../theme/routex_color_tokens.dart';

/// 안내가 끝난 순간, 어디에 도착했는지 확인시킨다.
///
/// **남은 거리를 적지 않는다.** 도착은 "다음에 무엇을 할지"가 없는 유일한 상태다.
/// 같은 안내 배너로 그리면 `0 m`만 붙은 이상한 줄이 되고, 사용자는 아직 안내가 끝나지
/// 않은 줄 안다. 대신 **어디에 도착했는지**를 말한다.
///
/// **닫기가 주 행동이다.** 도착한 사람에게 남은 일은 화면을 정리하는 것뿐이라, 이
/// 표면에서 가장 크게 눌리는 자리가 그것이어야 한다. 매장을 더 보고 싶은 사람을 위한
/// 길([onShowDetail])은 그 옆에 조용히 둔다.
class RoutexArrivalCard extends StatelessWidget {
  const RoutexArrivalCard({
    required this.destination,
    required this.onClose,
    this.floor,
    this.detail,
    this.onShowDetail,
    super.key,
  });

  final String destination;

  /// `3층`처럼 목적지가 있는 층이다. 실내에서는 이름만으로 어디인지 알 수 없다.
  final String? floor;

  /// `왼쪽 에스컬레이터 옆`처럼 마지막 한 걸음을 짚어 주는 말이다.
  final String? detail;

  final VoidCallback onClose;

  /// 매장 상세를 연다. null이면 상세가 없는 목적지(출구·주차장 등)다.
  final VoidCallback? onShowDetail;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    final where = [destination, ?floor].join(' · ');

    return RoutexBottomSheet(
      showHandle: false,
      includeBottomSafeArea: true,
      child: RoutexStack(
        gap: RoutexStackGap.content,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: RoutexMetrics.standardControl,
                height: RoutexMetrics.standardControl,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.statusSuccessSubtle,
                  borderRadius: RoutexRadii.field,
                ),
                child: Icon(
                  RoutexIcons.arrived,
                  size: RoutexMetrics.iconLarge,
                  color: colors.statusSuccess,
                ),
              ),
              const SizedBox(width: RoutexSpacing.contentGap),
              Expanded(
                child: Semantics(
                  liveRegion: true,
                  container: true,
                  child: RoutexStack(
                    gap: RoutexStackGap.inline,
                    children: [
                      Text('도착했습니다', style: RoutexTypography.title),
                      Text(
                        where,
                        style: RoutexTypography.bodySmall.copyWith(
                          color: colors.contentSecondary,
                        ),
                      ),
                      if (detail?.trim().isNotEmpty ?? false)
                        Text(
                          detail!,
                          style: RoutexTypography.bodySmall.copyWith(
                            color: colors.contentSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              if (onShowDetail != null) ...[
                Expanded(
                  child: RoutexButton(
                    label: '매장 정보',
                    variant: RoutexButtonVariant.secondary,
                    onPressed: onShowDetail,
                  ),
                ),
                const SizedBox(width: RoutexSpacing.controlGap),
              ],
              Expanded(
                child: RoutexButton(label: '안내 종료', onPressed: onClose),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
