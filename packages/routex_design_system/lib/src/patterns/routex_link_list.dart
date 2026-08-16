import 'package:flutter/material.dart';

import '../foundations/routex_icons.dart';
import '../foundations/routex_metrics.dart';
import '../foundations/routex_radii.dart';
import '../foundations/routex_spacing.dart';
import '../foundations/routex_typography.dart';
import '../components/routex_focus_ring.dart';
import '../theme/routex_color_tokens.dart';

/// 링크 줄에서 사람이 읽을 값이 무엇인지다.
enum RoutexLinkDisplay {
  /// 라벨이 곧 정체인 채널(인스타그램·페이스북)이다.
  label,

  /// 라벨만으로는 어디인지 알 수 없는 웹사이트다. 주소를 보여 준다.
  ///
  /// `공식 사이트`라는 라벨은 어느 사이트인지 말해 주지 않는다. 차례가 아니라
  /// 라벨의 성격으로 정한다 — 순서로 정하면 배열을 바꿨을 때 뜻 없이 화면이 따라
  /// 바뀐다.
  url,

  /// 라벨이 브랜드를 말하면서 주소도 필요한 줄이다(`오설록 공식 홈페이지`).
  ///
  /// 라벨을 주소로 덮으면 어느 브랜드인지가 사라지고, 주소를 지우면 어디로 나가는지가
  /// 사라진다. 둘 다 남길 이유가 있을 때만 두 줄이 된다.
  labelAndUrl,
}

/// 브랜드 배지의 색이다.
///
/// **로고 파일을 Runtime Kit에 넣지 않는다.** 이미지를 담는 순간 상표 정리 대상이
/// 늘고, 원격 favicon은 첫 프레임이 네트워크를 기다리게 한다. 대신 글리프는 Material
/// 아이콘을 쓰고 **색만** 브랜드에서 가져온다 — 색은 로고가 아니라서 담을 것이 없다.
@immutable
class RoutexLinkAccent {
  const RoutexLinkAccent({
    required this.icon,
    required this.colors,
    this.image,
  });

  /// 배지를 채울 그림이다. **로고 파일은 여기 담지 않는다** — 소비 앱이 이미
  /// 번들에 갖고 있는 그림만 넘길 수 있게 자리만 연다.
  ///
  /// 저작권 범위가 그 매장 자산과 이미 같아진 경우에만 쓴다. 그림이 빠져도 줄이
  /// 사라지지 않도록 [icon]·[colors] 배지로 되돌아간다 — 자산 누락은 빌드가 아니라
  /// 실행 중에 드러난다.
  final ImageProvider? image;

  final IconData icon;

  /// 배지 바탕색이다. 하나면 단색, 여럿이면 좌상→우하 그라데이션이다 —
  /// 브랜드 자체가 그라데이션인 곳이 있어 목록으로 받는다.
  final List<Color> colors;
}

/// 공식 채널 링크 하나다.
@immutable
class RoutexLinkItem {
  const RoutexLinkItem({
    required this.label,
    required this.url,
    this.display = RoutexLinkDisplay.label,
    this.accent,
  });

  final String label;
  final String url;
  final RoutexLinkDisplay display;

  /// 브랜드 색이다. 없으면 시스템 보조색과 링크 글리프로 떨어진다 — 모르는
  /// 채널이라고 줄을 그리지 못하는 일은 없다.
  final RoutexLinkAccent? accent;
}

/// 앱 밖으로 나가는 링크를 목록으로 세운다.
///
/// **여는 일은 여기서 하지 않는다.** 외부 앱을 여는 것은 플랫폼 능력이라 Runtime Kit이
/// 가질 의존이 아니다. 소비 앱이 [onSelected]에서 열고, **실패하면 반드시
/// `RoutexToast`로 말한다** — 눌렀는데 아무 일도 일어나지 않으면 사용자는 앱이 멈춘
/// 줄 안다.
class RoutexLinkList extends StatelessWidget {
  const RoutexLinkList({
    required this.items,
    required this.onSelected,
    super.key,
  });

  final List<RoutexLinkItem> items;
  final ValueChanged<RoutexLinkItem> onSelected;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in items)
          _LinkRow(item: item, onPressed: () => onSelected(item)),
      ],
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.item, required this.onPressed});

  final RoutexLinkItem item;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    final showBoth = item.display == RoutexLinkDisplay.labelAndUrl;
    final showUrl =
        item.display != RoutexLinkDisplay.label || item.label.trim().isEmpty;

    return Semantics(
      button: true,
      label: '${item.label}, 앱 밖에서 열기',
      excludeSemantics: true,
      child: RoutexFocusRing(
        radius: RoutexRadii.field,
        child: Material(
          color: Colors.transparent,
          borderRadius: RoutexRadii.field,
          child: InkWell(
            onTap: onPressed,
            borderRadius: RoutexRadii.field,
            focusColor: Colors.transparent,
            hoverColor: colors.actionPrimarySubtle,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: RoutexMetrics.minimumTouchTarget,
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: RoutexSpacing.contentGap,
                  vertical: RoutexSpacing.controlGap,
                ),
                child: Row(
                  children: [
                    _LinkBadge(accent: item.accent),
                    const SizedBox(width: RoutexSpacing.contentGap),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (showBoth)
                            Text(
                              item.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: RoutexTypography.bodySmall.copyWith(
                                color: colors.contentPrimary,
                              ),
                            ),
                          Text(
                            showUrl ? item.url : item.label,
                            // **한 줄 말줄임이고 자르는 곳은 뒤다.** 주소는 앞쪽
                            // (호스트)이 어디로 가는지를 말하고 뒤쪽(경로)은 그렇지
                            // 않다. 두 줄로 흘리면 줄 높이가 항목마다 달라져 목록이
                            // 글 덩어리가 된다.
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                (showBoth
                                        ? RoutexTypography.caption
                                        : RoutexTypography.bodySmall)
                                    .copyWith(
                                      // 주소만 링크 색이다. 이 줄이 글자가 아니라
                                      // 주소라는 표시.
                                      color: showUrl
                                          ? colors.actionPrimary
                                          : colors.contentPrimary,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: RoutexSpacing.controlGap),
                    Icon(
                      RoutexIcons.forward,
                      size: RoutexMetrics.iconMedium,
                      color: colors.contentSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 브랜드 색 원 안에 글리프 하나.
class _LinkBadge extends StatelessWidget {
  const _LinkBadge({required this.accent});

  final RoutexLinkAccent? accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    // 브랜드 색을 빈 목록으로 넘기는 것은 "색이 없다"가 아니라 실수다. 색을 모르면
    // accent 자체를 주지 않아야 무채색 기본값으로 떨어진다.
    assert(accent == null || accent!.colors.isNotEmpty, '브랜드 색은 최소 한 개다');
    final brandColors = accent?.colors.isNotEmpty ?? false
        ? accent!.colors
        : [colors.contentSecondary];

    if (accent?.image case final image?) {
      return ClipOval(
        child: Image(
          image: image,
          width: RoutexMetrics.compactControl,
          height: RoutexMetrics.compactControl,
          fit: BoxFit.cover,
          // 그림이 빠져도 줄이 사라지지 않게 기본 배지로 되돌린다.
          errorBuilder: (_, _, _) => _LinkBadge(
            accent: RoutexLinkAccent(
              icon: accent!.icon,
              colors: accent!.colors,
            ),
          ),
        ),
      );
    }

    return Container(
      width: RoutexMetrics.compactControl,
      height: RoutexMetrics.compactControl,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // LinearGradient는 색이 둘 이상이어야 해서 단색이면 같은 색을 겹친다.
        gradient: LinearGradient(
          colors: brandColors.length == 1
              ? [brandColors.first, brandColors.first]
              : brandColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        accent?.icon ?? RoutexIcons.link,
        size: RoutexMetrics.iconSmall,
        color: colors.contentInverse,
      ),
    );
  }
}
