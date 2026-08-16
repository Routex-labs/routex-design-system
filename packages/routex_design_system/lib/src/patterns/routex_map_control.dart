import 'package:flutter/material.dart';

import '../foundations/routex_glyph.dart';
import '../foundations/routex_metrics.dart';
import '../foundations/routex_radii.dart';
import '../foundations/routex_typography.dart';
import '../components/routex_focus_ring.dart';
import '../components/routex_surface.dart';
import '../theme/routex_color_tokens.dart';

/// 지도 컨트롤이 지금 무엇인지. **강조와 선택을 한 값으로 묶어** 둘이 어긋날 수
/// 없게 한다.
///
/// 예전에는 `selected: bool` 하나가 두 뜻을 지고 있었다. 늘 강조돼야 하는 버튼(내
/// 위치로 되돌리기)이 강조색을 얻으려면 `selected: true`를 줘야 했고, 그러면 화면
/// 낭독기가 "선택됨"까지 읽었다. 반대로 선택 상태가 아닌 버튼들은 전부 "선택 안 됨"을
/// 선언하고 있었다 — 선택이라는 개념 자체가 없는 자리에서.
enum RoutexMapControlTone {
  /// 흰 표면 + 본문색 글리프. 선택 상태를 선언하지 않는다.
  neutral,

  /// 흰 표면 + 강조색 글리프. **늘 강조되지만 선택된 것은 아니다** — 누를 때마다
  /// 같은 일을 하는 조작(내 위치로 되돌리기)이 여기 온다.
  accent,

  /// 채운 강조면 + 반전 글리프 + 한 단계 승격된 깊이. 다음 지도 탭을 이 컨트롤이
  /// 가져간 상태이며, **이때만 선택으로 읽는다.**
  active,
}

/// 지도 위 단일 아이콘 또는 층 라벨 동작의 크기와 상태를 고정한다.
///
/// 그림은 [icon]·[glyphBuilder]·[text] 중 하나로만 준다. [glyphBuilder]는 소비 앱의
/// 자산(SVG 등)을 쓰는 자리다 — 이 패키지는 자산을 갖지 않으므로 경로가 아니라
/// **그리는 함수**를 받는다(`RoutexMediaItem`이 ImageProvider를 받는 것과 같은 이유).
class RoutexMapControl extends StatelessWidget {
  const RoutexMapControl({
    required this.label,
    this.icon,
    this.glyphBuilder,
    this.text,
    this.tone = RoutexMapControlTone.neutral,
    this.onPressed,
    super.key,
  }) : assert(
         (icon == null ? 0 : 1) +
                 (glyphBuilder == null ? 0 : 1) +
                 (text == null ? 0 : 1) ==
             1,
         'icon·glyphBuilder·text 중 정확히 하나만 준다',
       );

  final String label;
  final IconData? icon;

  /// 소비 앱이 제 자산으로 글리프를 그린다. 색·크기는 이 컴포넌트가 상태에서
  /// 정해 넘기며, 구현은 그 둘만 써야 한다 — 앱이 색을 따로 고르면 활성·비활성
  /// 판정이 두 벌이 된다.
  final RoutexGlyphBuilder? glyphBuilder;

  final String? text;
  final RoutexMapControlTone tone;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    final enabled = onPressed != null;
    final filled = tone == RoutexMapControlTone.active;

    final foreground = !enabled
        ? colors.contentDisabled
        : switch (tone) {
            RoutexMapControlTone.neutral => colors.contentPrimary,
            RoutexMapControlTone.accent => colors.actionPrimary,
            RoutexMapControlTone.active => colors.contentInverse,
          };

    return Semantics(
      button: true,
      enabled: enabled,
      // neutral·accent는 선택이라는 개념이 없는 자리다. false를 선언하면 낭독기가
      // "선택 안 됨"을 읽어, 고를 수 있는 것처럼 들린다.
      selected: filled ? true : null,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        // 보이는 크기는 44, 터치 영역은 48이다. 지도 버튼이 48로 보이면 지도를
        // 그만큼 더 가린다.
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPressed,
          child: SizedBox.square(
            dimension: RoutexMetrics.minimumTouchTarget,
            child: Center(
              child: RoutexFocusRing(
                radius: RoutexRadii.field,
                enabled: enabled,
                child: RoutexSurface(
                  // 다음 탭을 가져간 컨트롤은 지도에서 한 단계 더 떠 있어야 한다 —
                  // 채움만으로는 "지금 이것이 켜져 있다"가 지도 색과 섞인다.
                  role: filled
                      ? RoutexSurfaceRole.chrome
                      : RoutexSurfaceRole.onMap,
                  shape: RoutexSurfaceShape.field,
                  child: Ink(
                    color: filled ? colors.actionPrimary : colors.surfaceRaised,
                    child: InkWell(
                      onTap: onPressed,
                      borderRadius: RoutexRadii.field,
                      child: SizedBox.square(
                        dimension: RoutexMetrics.standardControl,
                        child: Center(
                          child: switch ((icon, glyphBuilder, text)) {
                            (final icon?, _, _) => Icon(
                              icon,
                              size: RoutexMetrics.iconMedium,
                              color: foreground,
                            ),
                            (_, final builder?, _) => builder(
                              context,
                              foreground,
                              RoutexMetrics.iconMedium,
                            ),
                            (_, _, final text?) => Text(
                              text,
                              style: RoutexTypography.label.copyWith(
                                color: !enabled
                                    ? colors.contentDisabled
                                    : filled
                                    ? colors.contentInverse
                                    : colors.actionPrimary,
                              ),
                            ),
                            _ => const SizedBox.shrink(),
                          },
                        ),
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
