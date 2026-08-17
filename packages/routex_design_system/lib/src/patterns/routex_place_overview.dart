import 'package:flutter/material.dart';

import '../components/routex_media.dart';
import '../foundations/routex_typography.dart';
import '../layout/routex_stack.dart';
import 'routex_place_actions.dart';
import 'routex_place_header.dart';

/// 장소 상세의 첫 구획을 사진 → 정체성 → 경로 행동 → 소개 순서로 고정한다.
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

  @override
  Widget build(BuildContext context) {
    final description = this.description?.trim();
    return RoutexStack(
      gap: RoutexStackGap.content,
      children: [
        if (mediaItems.isNotEmpty) RoutexMediaCarousel(items: mediaItems),
        RoutexPlaceHeader(
          name: name,
          metadata: metadata,
          saved: saved,
          onSaved: onSaved,
          onShare: onShare,
        ),
        RoutexPlaceActions(onOrigin: onOrigin, onDestination: onDestination),
        if (description != null && description.isNotEmpty)
          Text(description, style: RoutexTypography.body),
      ],
    );
  }
}
