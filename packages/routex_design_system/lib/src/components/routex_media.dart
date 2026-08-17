import 'package:flutter/material.dart';

import '../foundations/routex_icons.dart';
import '../foundations/routex_metrics.dart';
import '../foundations/routex_radii.dart';
import '../foundations/routex_spacing.dart';
import '../foundations/routex_typography.dart';
import '../theme/routex_color_tokens.dart';

/// 화면에 거는 사진 한 장이다.
///
/// 경로가 아니라 `ImageProvider`를 받는다. asset·network·memory 중 무엇으로 가져올지는
/// 데이터를 아는 소비 앱이 정하고, Runtime Kit은 자산을 갖지 않는다 — 무거운 지도·프로모션
/// 자산이 package로 들어오는 것이 v0.1의 실패 조건이다.
@immutable
class RoutexMediaItem {
  const RoutexMediaItem({required this.image, this.semanticLabel});

  final ImageProvider image;

  /// 사진이 무엇을 보여 주는지. 없으면 화면 낭독기가 이 자리를 건너뛴다.
  final String? semanticLabel;
}

/// 대표 사진을 가로로 넘겨 본다.
///
/// **사진이 없으면 자리 자체를 만들지 않는다.** 회색 사각형이나 기본 이미지를 대신
/// 세우면 "사진이 없는 매장"과 "사진을 못 불러온 매장"이 같은 모습이 된다. 빈 목록을
/// 받으면 아무것도 그리지 않는다.
///
/// 높이는 비율이 아니라 `RoutexMetrics.mediaBand`로 고정한다. 비율로 두면 폭이 넓은
/// 기기에서 사진만으로 첫 화면이 채워져 이름과 주 행동이 밀려난다.
class RoutexMediaCarousel extends StatefulWidget {
  const RoutexMediaCarousel({required this.items, super.key});

  final List<RoutexMediaItem> items;

  @override
  State<RoutexMediaCarousel> createState() => _RoutexMediaCarouselState();
}

class _RoutexMediaCarouselState extends State<RoutexMediaCarousel> {
  int _index = 0;

  @override
  void didUpdateWidget(covariant RoutexMediaCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items.isEmpty) {
      _index = 0;
      return;
    }
    final lastIndex = widget.items.length - 1;
    if (_index > lastIndex) _index = lastIndex;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();
    final colors = context.routexColors;

    return SizedBox(
      height: RoutexMetrics.mediaBand,
      child: Stack(
        children: [
          Semantics(
            container: true,
            label: '대표 사진 ${widget.items.length}장',
            child: PageView.builder(
              itemCount: widget.items.length,
              onPageChanged: (index) => setState(() => _index = index),
              itemBuilder: (context, index) => Padding(
                // 여백은 페이지 **안쪽**에 준다. 바깥에 주면 넘길 때 두 장이 붙어
                // 지나가고, 사진이 시트 밖으로 이어지는 것처럼 보인다.
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: RoutexSpacing.inlineGap,
                ),
                child: _MediaFrame(
                  item: widget.items[index],
                  // 바깥 card에서 content padding만큼 들어온 사진은 같은 card
                  // 곡률을 다시 쓰지 않는다. 그러면 두 곡선의 중심이 달라 사진만
                  // 과하게 둥글어 보인다. 안쪽 콘텐츠 면은 control 곡률을 쓴다.
                  radius: RoutexRadii.control,
                ),
              ),
            ),
          ),
          if (widget.items.length > 1)
            PositionedDirectional(
              end: RoutexSpacing.componentPadding,
              bottom: RoutexSpacing.contentGap,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  // **반투명 scrim을 쓰지 않는다.** 어떤 사진이 밑에 올지 모르므로
                  // 반투명 위의 글자는 대비를 계산할 수 없다. 불투명한 어두운
                  // 표면을 깔면 사진과 무관하게 같은 대비가 나온다 — 토스트·알림과
                  // 같은 색 쌍이다.
                  color: colors.contentPrimary,
                  borderRadius: RoutexRadii.full,
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: RoutexSpacing.controlGap,
                    vertical: RoutexSpacing.inlineGap,
                  ),
                  child: Text(
                    '${_index + 1} / ${widget.items.length}',
                    style: RoutexTypography.tabular(
                      RoutexTypography.control(RoutexTypography.caption),
                    ).copyWith(color: colors.contentInverse),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 사진을 두 칸 격자로 늘어놓는다.
///
/// 캐러셀과 **같은 사진들**이지만 역할이 다르다. 캐러셀은 한 장씩 넘겨야 해서 몇 장이
/// 있는지가 한눈에 안 들어오고, 격자는 그 반대다. 캐러셀은 "무슨 매장인지"를 알려 주고,
/// 격자는 "사진을 보러 온" 사람의 자리다.
class RoutexPhotoGrid extends StatelessWidget {
  const RoutexPhotoGrid({required this.items, this.onSelected, super.key});

  final List<RoutexMediaItem> items;

  /// 사진을 눌렀을 때. null이면 보기만 하는 격자다.
  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      // 상세 본문이 이미 스크롤이라 격자는 스스로 스크롤하지 않는다.
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: RoutexSpacing.controlGap,
        crossAxisSpacing: RoutexSpacing.controlGap,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final frame = _MediaFrame(
          item: items[index],
          // 바깥 card의 padding 안에 놓이는 사진이 같은 곡률을 다시 쓰면 두
          // 곡선의 중심이 달라 보인다. 안쪽 콘텐츠 면은 control 곡률을 쓴다.
          radius: RoutexRadii.control,
        );
        if (onSelected == null) return frame;
        return Semantics(
          button: true,
          focusable: true,
          label: items[index].semanticLabel ?? '사진 ${index + 1}',
          onTap: () => onSelected!(index),
          excludeSemantics: true,
          child: InkWell(
            onTap: () => onSelected!(index),
            borderRadius: RoutexRadii.control,
            child: frame,
          ),
        );
      },
    );
  }
}

/// 사진 한 장의 곡률·채움·실패 표시를 고정한다.
class _MediaFrame extends StatelessWidget {
  const _MediaFrame({required this.item, required this.radius});

  final RoutexMediaItem item;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;

    return ClipRRect(
      borderRadius: radius,
      child: Image(
        image: item.image,
        // 매장 사진은 원본 비율이 제각각이라 맞출 수 있는 비율이 없다. 잘려도
        // 무엇을 찍은 사진인지는 남으므로 칸을 채운다.
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        semanticLabel: item.semanticLabel,
        // 사진을 못 불러왔다는 사실을 빈 칸으로 두지 않는다. 빈 칸은 사진이 없는
        // 매장으로 읽히고, 그건 다른 뜻이다.
        errorBuilder: (context, error, stack) => ColoredBox(
          color: colors.surfaceCanvas,
          child: Center(
            child: Icon(
              RoutexIcons.image,
              size: RoutexMetrics.iconLarge,
              color: colors.contentDisabled,
            ),
          ),
        ),
      ),
    );
  }
}
