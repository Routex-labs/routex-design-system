import 'package:flutter/material.dart';

import '../foundations/routex_icons.dart';
import '../foundations/routex_metrics.dart';
import '../foundations/routex_radii.dart';
import '../foundations/routex_spacing.dart';
import '../foundations/routex_typography.dart';
import '../theme/routex_color_tokens.dart';
import 'routex_focus_ring.dart';
import 'routex_icon_action.dart';

/// 목록 행의 leading 아이콘이 색으로도 정보를 전하는가.
///
/// [accent]는 종류가 하나인 목록이다. 아이콘이 "여기는 장소다"만 말하므로 강조색이
/// 다른 것과 다투지 않는다.
///
/// [quiet]는 **종류가 섞인 목록**이다. 검색 결과처럼 매장·건물·후보가 번갈아 오는
/// 자리에서 아이콘까지 강조색을 쓰면 목록이 색 점으로 칸칸이 나뉘어 보이고, 강조색이
/// 무엇을 뜻하는지 흐려진다. 그런 목록에서 색은 제목의 일치 구간
/// ([RoutexListCell.titleHighlights]) 몫이고 종류는 글리프 모양이 가른다.
enum RoutexListIconTone { accent, quiet }

/// 장소·검색 결과에서 텍스트 열과 상태 위계를 고정하는 v0.1 beta cell이다.
class RoutexListCell extends StatelessWidget {
  const RoutexListCell({
    required this.title,
    this.titleHighlights = const [],
    this.subtitle,
    this.metric,
    this.leadingIcon,
    this.leadingIconTone = RoutexListIconTone.accent,
    this.trailingIcon,
    this.trailingActionLabel,
    this.onTrailingAction,
    this.trailingActionIcon = RoutexIcons.more,
    this.reorderable = false,
    this.selected = false,
    this.enabled = true,
    this.onPressed,
    super.key,
  });

  final String title;

  /// [title] 안에서 강조할 구간이다. 검색 결과에서 **왜 이 줄이 걸렸는지**를
  /// 색으로 설명한다.
  ///
  /// 무엇이 걸렸는지 정하는 일은 소비 앱이 한다 — 대소문자·공백 정규화와 의미
  /// 검색의 판정은 도메인이고, 여기서 흉내 내면 서버 판정과 어긋난다. 이 컴포넌트는
  /// **강조가 어떻게 보이는지**만 소유한다.
  ///
  /// 비어 있는 것이 정상 상태다. 의미 검색은 이름에 검색어가 없는 결과를 주는 것이
  /// 목적이라, 하나도 안 걸리는 것을 실패로 다루지 않는다.
  final List<TextRange> titleHighlights;

  /// 이 줄이 무엇이고 어디에 있는지. 분류·건물·층처럼 **자리를 말하는** 값이다.
  final String? subtitle;

  /// 이 줄을 고를지 정하는 값이다. 거리·소요 시간처럼 재어서 나온 것을 둔다.
  ///
  /// [subtitle]이 "어디에 있는가"라면 이쪽은 "지금 갈까"에 답한다. 둘을 한 줄에
  /// 합치면 결정에 쓰는 값이 맥락과 같은 무게가 되어, 목록을 훑는 눈이 짚을 곳을
  /// 잃는다. 그래서 줄과 굵기를 나눈다.
  final String? metric;

  final IconData? leadingIcon;

  final RoutexListIconTone leadingIconTone;

  final IconData? trailingIcon;

  /// 행 자체와 다른 동작을 하는 끝 버튼이다. 이름 없이는 만들 수 없다.
  final String? trailingActionLabel;
  final VoidCallback? onTrailingAction;

  /// 그 끝 버튼의 글리프다. 기본은 더 보기(⋯)다.
  ///
  /// **동작이 하나뿐이면 그것을 그린다.** 최근 검색어의 삭제처럼 누르면 곧장 일어나는
  /// 동작에 ⋯를 두면, 사용자는 메뉴가 열릴 줄 알고 눌렀다가 줄이 사라지는 것을 겪는다.
  /// ⋯는 "여기 여러 갈래가 있다"는 뜻이라 그 자리에 쓸 수 없다.
  final IconData trailingActionIcon;

  /// 순서를 바꿀 수 있는 목록의 행이면 손잡이를 보여준다. 드래그 처리는 목록을
  /// 가진 화면이 맡고, 이 컴포넌트는 손잡이의 자리와 이름만 고정한다.
  final bool reorderable;

  final bool selected;
  final bool enabled;
  final VoidCallback? onPressed;

  bool get _hasSubtitle => subtitle?.trim().isNotEmpty ?? false;

  bool get _hasMetric => metric?.trim().isNotEmpty ?? false;

  bool get _hasAccessory => trailingActionLabel != null || reorderable;

  /// 강조 구간을 색이 다른 span으로 가른다. 구간이 없으면 원문 하나다.
  List<TextSpan> _titleSpans(Color emphasis) {
    assert(
      titleHighlights.every(
        (range) => range.start >= 0 && range.end <= title.length,
      ),
      '강조 구간이 제목 밖을 가리킨다',
    );
    final spans = <TextSpan>[];
    var cursor = 0;
    for (final range in titleHighlights) {
      if (range.start < cursor || range.end <= range.start) continue;
      if (range.start > cursor) {
        spans.add(TextSpan(text: title.substring(cursor, range.start)));
      }
      spans.add(
        TextSpan(
          text: title.substring(range.start, range.end),
          style: TextStyle(color: emphasis),
        ),
      );
      cursor = range.end;
    }
    if (cursor < title.length) {
      spans.add(TextSpan(text: title.substring(cursor)));
    }
    return spans;
  }

  /// line box 안에서 글자가 실제로 시작하는 위치다. bodyStrong 16 * 1.5 line box
  /// 기준으로 위아래 4씩 남는다.
  static const _titleGlyphInset = RoutexOpticalCorrection.listTitleGlyphTop;

  /// 한 줄짜리 행인가.
  ///
  /// **줄 수가 정렬 기준을 바꾼다.** 여러 줄이면 아이콘은 첫 줄 윗면에 맞춰야
  /// 한다 — 가운데에 두면 본문이 길어질수록 아이콘이 아래로 내려가 어느 줄에
  /// 붙은 것인지 알 수 없다. 반대로 한 줄일 때 윗면에 맞추면, 48 터치 영역을 가진
  /// 끝 동작이 24 제목보다 상자가 길어서 글리프만 12 아래로 떨어진다.
  bool get _singleLine => !_hasSubtitle && !_hasMetric;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    final interactive = onPressed != null;
    final foreground = enabled ? colors.contentPrimary : colors.contentDisabled;
    final secondaryForeground = enabled
        ? colors.contentSecondary
        : colors.contentDisabled;

    return Semantics(
      container: true,
      button: interactive,
      enabled: interactive ? enabled : null,
      focusable: interactive && enabled,
      selected: selected,
      // 강조는 색이라 읽어 주지 않는다. 값은 읽어 준다 — 보이는 것과 같은 순서다.
      label: [
        title,
        if (_hasSubtitle) subtitle!,
        if (_hasMetric) metric!,
      ].join(', '),
      onTap: interactive && enabled ? onPressed : null,
      excludeSemantics: !_hasAccessory,
      explicitChildNodes: _hasAccessory,
      child: RoutexFocusRing(
        radius: RoutexRadii.field,
        enabled: interactive && enabled,
        child: Material(
          color: selected ? colors.actionPrimarySubtle : Colors.transparent,
          borderRadius: RoutexRadii.field,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            excludeFromSemantics: true,
            borderRadius: RoutexRadii.field,
            // focus는 링이 맡는다. 채움은 selected·hover·pressed가 나눠 쓴다.
            focusColor: Colors.transparent,
            hoverColor: colors.actionPrimarySubtle,
            overlayColor: WidgetStateProperty.resolveWith((states) {
              return states.contains(WidgetState.pressed)
                  ? selected
                        ? colors.surfaceCanvas
                        : colors.actionPrimarySubtle
                  : null;
            }),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: RoutexMetrics.minimumTouchTarget,
              ),
              child: Padding(
                // 선택·hover 배경이 행 전체를 덮으므로 좌우 여백도 행이 가진다.
                // 세로 여백만 주면 배경 안에서 텍스트가 한쪽으로 붙어 보인다.
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: RoutexSpacing.contentGap,
                  // 한 줄 행은 48dp 보조 동작 자체가 행 높이를 만든다. 그 밖에
                  // padding을 더하면 최근 검색 한 칸이 64dp로 불어난다.
                  vertical: _singleLine ? 0 : RoutexSpacing.controlGap,
                ),
                child: Row(
                  crossAxisAlignment: _singleLine
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: RoutexMetrics.leadingColumn,
                      child: leadingIcon == null
                          ? null
                          // 아이콘 윗면을 제목 글리프 윗면에 맞춘다. line box는
                          // 글자보다 위아래로 여유가 있어 세로 중앙에 두면 아이콘이
                          // 글자보다 떠 보인다.
                          : Padding(
                              padding: EdgeInsetsDirectional.only(
                                top: _singleLine ? 0 : _titleGlyphInset,
                              ),
                              child: Align(
                                alignment: _singleLine
                                    ? AlignmentDirectional.centerStart
                                    : AlignmentDirectional.topStart,
                                child: Icon(
                                  leadingIcon,
                                  size: RoutexMetrics.iconMedium,
                                  color: enabled
                                      ? switch (leadingIconTone) {
                                          RoutexListIconTone.accent =>
                                            colors.actionPrimary,
                                          RoutexListIconTone.quiet =>
                                            colors.contentSecondary,
                                        }
                                      : colors.contentDisabled,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: RoutexSpacing.contentGap),
                    Expanded(
                      child: ExcludeSemantics(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (titleHighlights.isEmpty)
                              Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: RoutexTypography.bodyStrong.copyWith(
                                  color: foreground,
                                ),
                              )
                            else
                              Text.rich(
                                TextSpan(
                                  children: _titleSpans(
                                    enabled
                                        ? colors.actionPrimary
                                        : colors.contentDisabled,
                                  ),
                                ),
                                style: RoutexTypography.bodyStrong.copyWith(
                                  color: foreground,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            if (_hasSubtitle) ...[
                              const SizedBox(height: RoutexSpacing.inlineGap),
                              Text(
                                subtitle!,
                                style: RoutexTypography.bodySmall.copyWith(
                                  color: secondaryForeground,
                                ),
                              ),
                            ],
                            if (_hasMetric) ...[
                              const SizedBox(height: RoutexSpacing.inlineGap),
                              Text(
                                metric!,
                                // 맥락보다 한 단계 진하다. 크기는 같고 굵기와 색만
                                // 올려, 훑는 눈이 값에서 멈추게 한다.
                                style: RoutexTypography.label.copyWith(
                                  color: foreground,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    if (trailingIcon case final icon?) ...[
                      const SizedBox(width: RoutexSpacing.contentGap),
                      Padding(
                        padding: EdgeInsetsDirectional.only(
                          top: _singleLine ? 0 : _titleGlyphInset,
                        ),
                        child: Icon(
                          icon,
                          size: RoutexMetrics.iconMedium,
                          color: secondaryForeground,
                        ),
                      ),
                    ],
                    // 행 안의 보조 동작과 손잡이는 같은 평면에 있다. 하나만 타일
                    // 배경을 가지면 서로 다른 컨트롤로 읽힌다.
                    if (trailingActionLabel case final actionLabel?) ...[
                      const SizedBox(width: RoutexSpacing.controlGap),
                      Semantics(
                        container: true,
                        button: true,
                        enabled: enabled && onTrailingAction != null,
                        focusable: enabled && onTrailingAction != null,
                        label: actionLabel,
                        onTap: enabled ? onTrailingAction : null,
                        excludeSemantics: true,
                        child: RoutexIconAction(
                          label: actionLabel,
                          icon: trailingActionIcon,
                          tone: RoutexIconActionTone.quiet,
                          onPressed: enabled ? onTrailingAction : null,
                        ),
                      ),
                    ],
                    if (reorderable) ...[
                      const SizedBox(width: RoutexSpacing.controlGap),
                      SizedBox.square(
                        // 옆의 보조 동작은 눌 수 있는 컨트롤이라 48 터치 영역을
                        // 가진다. 손잡이를 44로 두면 같은 줄에서 두 글리프의
                        // 중심이 2 어긋난다. 누르지 않는 자리라도 상자는 맞춘다.
                        dimension: RoutexMetrics.minimumTouchTarget,
                        child: Semantics(
                          container: true,
                          label: '순서 바꾸기 손잡이',
                          child: Icon(
                            RoutexIcons.reorder,
                            size: RoutexMetrics.iconMedium,
                            // 손잡이는 글이 아니라 잡는 자리를 알리는 장식이다.
                            // 보조 동작과 같은 content 색을 쓰면 둘이 같은 무게의
                            // 버튼으로 읽힌다.
                            color: enabled
                                ? colors.borderStrong
                                : colors.contentDisabled,
                          ),
                        ),
                      ),
                    ],
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
