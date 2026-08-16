import 'package:flutter/material.dart';

import '../foundations/routex_icons.dart';
import '../foundations/routex_metrics.dart';
import '../foundations/routex_radii.dart';
import '../foundations/routex_spacing.dart';
import '../foundations/routex_typography.dart';
import '../layout/routex_stack.dart';
import '../theme/routex_color_tokens.dart';
import '../components/routex_icon_action.dart';

/// 장소 요약과 상세에서 이름·분류·건물·저장·확장 동작의 순서를 고정한다.
class RoutexPlaceHeader extends StatelessWidget {
  const RoutexPlaceHeader({
    required this.name,
    required this.metadata,
    required this.saved,
    required this.onSaved,
    this.onShare,
    this.supportingText,
    this.supportingIcon,
    this.leadingIcon,
    this.expanded = false,
    this.onToggleExpanded,
    super.key,
  });

  final String name;
  final String metadata;

  /// 이름과 분류 다음 줄이다. 검색 결과·장소 요약에서 "어떻게 닿는가"인 도보
  /// 거리·시간이 여기 온다. 선택을 마친 상세 헤더에서는 같은 값을 반복하지 않는다.
  final String? supportingText;

  /// 보조 줄 앞의 글리프다. 도보·엘리베이터처럼 **닿는 방식**이 값의 뜻을 바꾸는
  /// 경우에만 준다. 없으면 글자만 그린다.
  final IconData? supportingIcon;

  final IconData? leadingIcon;
  final bool saved;
  final ValueChanged<bool> onSaved;

  /// 장소 식별 링크를 공유한다. 링크 생성과 플랫폼 공유 시트는 소비 앱이 맡는다.
  /// null이면 공유 계약이 준비되지 않은 화면이라 action을 숨긴다.
  final VoidCallback? onShare;
  final bool expanded;
  final VoidCallback? onToggleExpanded;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    final text = RoutexStack(
      gap: RoutexStackGap.inline,
      children: [
        Text(
          name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: RoutexTypography.headline,
        ),
        Text(
          metadata,
          style: RoutexTypography.bodySmall.copyWith(
            color: colors.contentSecondary,
          ),
        ),
        if (supportingText?.trim().isNotEmpty ?? false)
          Row(
            children: [
              if (supportingIcon case final icon?) ...[
                Icon(
                  icon,
                  size: RoutexMetrics.iconSmall,
                  color: colors.contentSecondary,
                ),
                const SizedBox(width: RoutexSpacing.inlineGap),
              ],
              Expanded(
                child: Text(
                  supportingText!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: RoutexTypography.caption.copyWith(
                    color: colors.contentSecondary,
                  ),
                ),
              ),
            ],
          ),
      ],
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leadingIcon case final icon?) ...[
          Container(
            width: RoutexMetrics.standardControl,
            height: RoutexMetrics.standardControl,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.actionPrimarySubtle,
              borderRadius: RoutexRadii.field,
            ),
            child: Icon(
              icon,
              size: RoutexMetrics.iconLarge,
              color: colors.actionPrimary,
            ),
          ),
          const SizedBox(width: RoutexSpacing.contentGap),
        ],
        Expanded(
          child: onToggleExpanded == null
              ? text
              : InkWell(
                  onTap: onToggleExpanded,
                  borderRadius: RoutexRadii.control,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      end: RoutexSpacing.controlGap,
                    ),
                    child: text,
                  ),
                ),
        ),
        if (onShare != null) ...[
          RoutexIconAction(
            label: '장소 공유',
            icon: RoutexIcons.share,
            tone: RoutexIconActionTone.quiet,
            onPressed: onShare,
          ),
          const SizedBox(width: RoutexSpacing.inlineGap),
        ],
        RoutexIconAction(
          label: saved ? '저장 취소' : '장소 저장',
          icon: saved ? RoutexIcons.saved : RoutexIcons.save,
          selected: saved,
          onPressed: () => onSaved(!saved),
        ),
        if (onToggleExpanded != null) ...[
          const SizedBox(width: RoutexSpacing.inlineGap),
          RoutexIconAction(
            label: expanded ? '상세 닫기' : '상세 열기',
            icon: expanded ? RoutexIcons.expand : RoutexIcons.collapse,
            onPressed: onToggleExpanded,
          ),
        ],
      ],
    );
  }
}
