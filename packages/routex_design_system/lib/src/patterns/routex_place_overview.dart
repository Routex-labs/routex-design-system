import 'package:flutter/material.dart';

import '../components/routex_media.dart';
import '../components/routex_icon_action.dart';
import '../foundations/routex_icons.dart';
import '../foundations/routex_metrics.dart';
import '../foundations/routex_spacing.dart';
import '../foundations/routex_typography.dart';
import '../layout/routex_stack.dart';
import 'routex_place_actions.dart';
import 'routex_place_header.dart';

/// 장소 상세의 첫 구획을 정체성 → 경로 행동 → 사진 → 소개 순서로 고정한다.
///
/// 쇼케이스와 소비 앱은 이 패턴에 데이터와 callback만 넘긴다. 각 화면이 네 조각을
/// 다시 조립하면 순서와 간격이 갈라지므로 임의 여백이나 순서 옵션은 열지 않는다.
class RoutexPlaceOverview extends StatelessWidget {
  const RoutexPlaceOverview({
    required this.name,
    required this.metadata,
    required this.saved,
    required this.onOrigin,
    required this.onDestination,
    this.mediaItems = const [],
    this.description,
    this.onSaved,
    this.onShare,
    this.onClose,
    super.key,
  });

  final String name;
  final String metadata;
  final bool saved;
  final VoidCallback? onOrigin;
  final VoidCallback? onDestination;
  final List<RoutexMediaItem> mediaItems;
  final String? description;
  final ValueChanged<bool>? onSaved;
  final VoidCallback? onShare;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final description = this.description?.trim();
    return RoutexStack(
      gap: RoutexStackGap.content,
      children: [
        RoutexPlaceHeader(
          name: name,
          metadata: metadata,
          saved: saved,
          onClose: onClose,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: RoutexPlaceActions(
                onOrigin: onOrigin,
                onDestination: onDestination,
              ),
            ),
            if (onShare != null || onSaved != null) ...[
              const SizedBox(width: RoutexSpacing.controlGap),
              Transform.translate(
                offset: Offset(
                  Directionality.of(context) == TextDirection.ltr
                      ? RoutexOpticalCorrection.placeTrailingActionEnd
                      : -RoutexOpticalCorrection.placeTrailingActionEnd,
                  0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onShare != null)
                      RoutexIconAction(
                        label: '장소 공유',
                        icon: RoutexIcons.share,
                        tone: RoutexIconActionTone.quiet,
                        onPressed: onShare,
                      ),
                    if (onShare != null && onSaved != null)
                      const SizedBox(width: RoutexSpacing.inlineGap),
                    if (onSaved case final onSaved?)
                      RoutexIconAction(
                        label: saved ? '저장 취소' : '장소 저장',
                        icon: saved ? RoutexIcons.saved : RoutexIcons.save,
                        tone: RoutexIconActionTone.quiet,
                        selected: saved,
                        onPressed: () => onSaved(!saved),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
        if (mediaItems.isNotEmpty) RoutexMediaCarousel(items: mediaItems),
        if (description != null && description.isNotEmpty)
          Text(description, style: RoutexTypography.body),
      ],
    );
  }
}
