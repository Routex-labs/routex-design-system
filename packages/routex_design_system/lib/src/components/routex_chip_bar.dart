import 'package:flutter/material.dart';

import '../foundations/routex_icons.dart';
import '../foundations/routex_layer.dart';
import '../foundations/routex_metrics.dart';
import '../foundations/routex_radii.dart';
import '../foundations/routex_spacing.dart';
import '../foundations/routex_typography.dart';
import '../theme/routex_category_tokens.dart';
import '../theme/routex_color_tokens.dart';
import 'routex_focus_ring.dart';

/// 칩 하나가 제 고유색을 쓸 때 필요한 색 쌍이다.
///
/// 분류 칩은 파랑 하나로 통일하면 분류마다 색이 다른 의미가 사라진다. 그렇다고
/// 도면용 원색을 그대로 쓰면 흰 배경에서 2:1 언저리라 선택 표시가 보이지 않는다.
/// 그래서 색상은 유지하고 대비만 확보한 짝을 받는다. 값은 부르는 쪽이
/// `RoutexCategoryTokens.inkFor`·`surfaceFor`에서 읽어 넘긴다.
@immutable
class RoutexChipAccent {
  const RoutexChipAccent({
    required this.icon,
    required this.ink,
    required this.surface,
  });

  /// 아이콘에 쓰는 원색이다. 대비 기준을 적용하지 않는다.
  ///
  /// 바로 옆에 분류 이름이 늘 적혀 있어서 아이콘이 뜻을 혼자 지지 않는다. 그래서
  /// 파스텔 원색을 그대로 써도 정보가 사라지지 않고, 분류 줄이 도면과 같은 색감을
  /// 유지한다. 상태(선택 여부)를 전하는 일은 [ink]가 맡는다.
  final Color icon;

  /// 글자와 테두리에 쓴다. 제 [surface] 위에서 4.5:1을 넘어야 한다.
  ///
  /// 선택됐는지를 혼자 전하는 것이 이 색이라 원색을 쓸 수 없다. 도면용 원색은 흰
  /// 배경에서 2:1 언저리라 선택 표시가 보이지 않는다.
  final Color ink;

  /// 선택된 칩의 배경이다.
  final Color surface;
}

@immutable
class RoutexChipOption {
  const RoutexChipOption({
    required this.id,
    required this.label,
    this.count,
    this.icon,
    this.accent,
  });

  /// 매장 분류 칩이다. 이름만 주면 글리프와 색을 분류 토큰에서 읽는다.
  ///
  /// 화면이 아이콘이나 색을 직접 고르면 같은 분류가 지도·목록·칩에서 서로 다른
  /// 모습으로 나온다. 분류를 아는 곳은 토큰 한 곳이어야 한다.
  factory RoutexChipOption.category(String category) => RoutexChipOption(
    id: category,
    label: category,
    icon: RoutexCategoryTokens.iconFor(category),
    accent: RoutexChipAccent(
      icon: RoutexCategoryTokens.colorFor(category),
      ink: RoutexCategoryTokens.inkFor(category),
      surface: RoutexCategoryTokens.surfaceFor(category),
    ),
  );

  final String id;
  final String label;

  /// 이 선택지를 고르면 몇 개가 남는지. 서식은 여기서 정한다.
  ///
  /// 화면이 `'패션 (12)'`처럼 문자열을 미리 이어 붙이면 같은 개수가 줄마다 다른
  /// 모양으로 나온다. 괄호를 쓸지 말지는 한 곳에서 정할 일이다.
  final int? count;

  final IconData? icon;

  /// 고유색이 없으면 시스템 강조색(accentBrand·actionPrimary)으로 그린다.
  final RoutexChipAccent? accent;
}

/// 칩 줄이 놓인 평면이다.
///
/// 시트·패널 안의 칩은 목록과 같은 평면에 있어야 하므로 그림자를 쓰지 않는다.
/// 지도 위의 칩은 지도에서 떠 있어야 읽히므로 onMap 깊이를 쓴다. 같은 칩을 두
/// 평면에서 같은 모양으로 그리면 사용자가 "목록을 좁히는 것"과 "지도를 좁히는
/// 것"을 구분하지 못한다.
enum RoutexChipSurface { inSheet, onMap }

/// 칩이 한 줄에 다 안 들어갈 때 그 넘침을 누가 맡는가.
///
/// 기본은 줄 자신이다([scroll]). 소비 화면이 **이미 가로 스크롤 뷰포트를 소유한**
/// 자리에서는 [deferToParent]로 넘긴다 — 가로 스크롤 안에 가로 스크롤을 또 두면
/// 안쪽이 무한 폭을 받아 그 자리에서 터진다.
///
/// 지도 위 오버레이가 그런 자리다. 거기서는 스크롤이 시각이 아니라 **입력 계약**을
/// 함께 진다. 지도가 플랫폼 뷰라 이 줄 위의 휠이 지도까지 내려가고, 잠금을 뷰포트
/// 전체가 아니라 칩이 실제로 그려진 영역에만 걸어야 한다. 그 판단에 필요한 것을
/// 아는 쪽은 소비 앱이므로, 그 자리에서는 스크롤 소유권을 넘긴다.
///
/// **[deferToParent]를 고르면 부모가 가로 스크롤을 반드시 제공해야 한다.** 칩은 큰
/// 글자에서 폭이 늘고 이 줄은 스스로 접히지 않는다.
enum RoutexChipBarOverflow { scroll, deferToParent }

/// 선택을 푸는 방법이 눈에 보이는가.
///
/// 칩 줄은 선택된 칩을 다시 누르면 풀린다. 그것이 화면에 드러나지 않으면, 고른 값이
/// 쌓인 줄에서 사용자는 무엇을 눌러야 되돌아가는지 모른다. [visible]은 선택된 칩 끝에
/// ×를 그려 그 사실을 말한다.
enum RoutexChipDismiss { hidden, visible }

/// 선택이 없는 상태가 있을 수 있는가.
///
/// [optional]은 고른 것을 다시 눌러 모두 풀 수 있다 — 지도 위 분류 줄이 그렇다.
///
/// [required]는 늘 하나가 선택돼 있다. `전체`처럼 "좁히지 않음"을 뜻하는 칩이 줄
/// 안에 있는 경우다. 여기서 해제를 허용하면 그 칩의 강조만 사라져, 지금 전체를 보고
/// 있다는 사실이 화면에서 없어진다. 선택된 칩을 다시 눌러도 아무 일도 일어나지 않는다.
enum RoutexChipSelection { optional, required }

/// 목록을 좁히는 선택지를 내용 폭 그대로 한 줄에 나열한다.
///
/// 선택은 없거나 하나다. 선택된 항목을 다시 누르면 선택이 풀린다. 큰 글자에서도
/// 세로로 접지 않고 가로로 넘긴다 — 그 넘침을 누가 맡는지는 [overflow]가 정한다.
///
/// 상호배타적인 전체 선택지를 균등 폭으로 보여줘야 하면 `RoutexTravelModeBar`
/// 같은 세그먼트 컨트롤을 쓴다. 이 컴포넌트는 항목 수가 바뀌는 필터를 맡는다.
class RoutexChipBar extends StatelessWidget {
  const RoutexChipBar({
    required this.options,
    required this.selectedId,
    required this.onSelected,
    this.surface = RoutexChipSurface.inSheet,
    this.overflow = RoutexChipBarOverflow.scroll,
    this.dismiss = RoutexChipDismiss.hidden,
    this.selection = RoutexChipSelection.optional,
    this.semanticsLabel,
    super.key,
  });

  final List<RoutexChipOption> options;

  /// 선택이 없으면 null이다.
  final String? selectedId;

  /// 선택된 항목을 다시 누르면 null로 호출한다.
  final ValueChanged<String?> onSelected;

  final RoutexChipSurface surface;

  final RoutexChipBarOverflow overflow;

  final RoutexChipDismiss dismiss;

  final RoutexChipSelection selection;

  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    assert(options.isNotEmpty, '선택지가 없으면 줄 자체를 그리지 않는다');
    assert(
      selection == RoutexChipSelection.optional || selectedId != null,
      '늘 하나가 선택돼 있는 줄이라면 지금 무엇이 선택됐는지도 함께 준다',
    );

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < options.length; index++) ...[
          if (index > 0) const SizedBox(width: RoutexSpacing.controlGap),
          _Chip(
            key: ValueKey(options[index].id),
            option: options[index],
            surface: surface,
            selected: options[index].id == selectedId,
            dismissible:
                dismiss == RoutexChipDismiss.visible &&
                options[index].id == selectedId,
            onPressed: () {
              final already = options[index].id == selectedId;
              // 늘 하나가 선택된 줄에서는 다시 눌러도 바뀌는 것이 없다.
              if (already && selection == RoutexChipSelection.required) return;
              onSelected(already ? null : options[index].id);
            },
          ),
        ],
      ],
    );

    return Semantics(
      container: true,
      label: semanticsLabel,
      child: switch (overflow) {
        RoutexChipBarOverflow.scroll => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: row,
        ),
        RoutexChipBarOverflow.deferToParent => row,
      },
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.option,
    required this.surface,
    required this.selected,
    required this.dismissible,
    required this.onPressed,
    super.key,
  });

  final RoutexChipOption option;
  final RoutexChipSurface surface;
  final bool selected;
  final bool dismissible;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    // 선택을 진한 색으로 채우면 지도 위 한 줄이 통째로 무거워지고, 채움 위 흰 글자는
    // 분류 고유색에서 2:1대로 떨어진다. 옅은 배경 + 같은 색상의 테두리 + 같은 색상의
    // 글자로 그리면 무게도 덜고 대비도 확보된다.
    final accent = option.accent;
    final ink = accent?.ink ?? colors.actionPrimary;
    final selectedFill = accent?.surface ?? colors.actionPrimarySubtle;
    final selectedBorder = accent?.ink ?? colors.accentBrand;

    final foreground = selected ? ink : colors.contentSecondary;

    // 아이콘은 선택 여부와 관계없이 파스텔 원색을 유지한다. 무엇을 고를 수 있는지를
    // 색으로 먼저 알리는 것이 분류 줄의 목적이고, 여기까지 대비를 맞춰 톤을 낮추면
    // 도면과 색감이 갈라진다. 바로 옆 글자가 분류 이름을 말하므로 아이콘이 뜻을
    // 혼자 지지 않아, 원색이어도 정보가 사라지지 않는다.
    final iconColor = accent?.icon ?? foreground;

    // 시각 높이는 compact control이고, 터치 영역만 48로 넓힌다. 보이는 크기를
    // 48로 만들면 지도 위 한 줄이 지도를 그만큼 더 가린다.
    return Semantics(
      button: true,
      selected: selected,
      label: option.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: SizedBox(
          height: RoutexMetrics.minimumTouchTarget,
          child: Center(
            child: SizedBox(
              height: RoutexMetrics.compactControl,
              child: RoutexFocusRing(
                radius: RoutexRadii.full,
                child: Material(
                  color: selected ? selectedFill : colors.surfaceRaised,
                  borderRadius: RoutexRadii.full,
                  elevation: surface == RoutexChipSurface.onMap
                      ? RoutexLayer.onMap
                      : 0,
                  shadowColor: colors.shadow,
                  child: InkWell(
                    onTap: onPressed,
                    borderRadius: RoutexRadii.full,
                    child: Container(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: RoutexSpacing.contentGap,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: RoutexRadii.full,
                        border: Border.all(
                          // 선택은 이 테두리가 전한다. 배경 틴트만으로는 지도 위
                          // 옅은 바탕과 구분이 약하다.
                          color: selected
                              ? selectedBorder
                              : colors.borderSubtle,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (option.icon case final icon?) ...[
                            Icon(
                              icon,
                              size: RoutexMetrics.iconSmall,
                              color: iconColor,
                            ),
                            const SizedBox(width: RoutexSpacing.inlineGap),
                          ],
                          Text(
                            option.count == null
                                ? option.label
                                : '${option.label} (${option.count})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: RoutexTypography.control(
                              RoutexTypography.label,
                            ).copyWith(color: foreground),
                          ),
                          if (dismissible) ...[
                            const SizedBox(width: RoutexSpacing.inlineGap),
                            Icon(
                              RoutexIcons.close,
                              size: RoutexMetrics.iconSmall,
                              color: foreground,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
