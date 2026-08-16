import 'package:flutter/material.dart';

import '../foundations/routex_metrics.dart';
import '../foundations/routex_radii.dart';
import '../foundations/routex_spacing.dart';
import '../foundations/routex_typography.dart';
import '../layout/routex_stack.dart';
import '../theme/routex_color_tokens.dart';
import 'routex_button.dart';
import 'routex_key_value.dart';

/// 화면을 덮고 답을 기다리는 표면이다.
///
/// **시트와 나누는 기준은 "지도를 계속 볼 수 있는가"다.** 장소·경로처럼 지도 위
/// 맥락이 필요한 것은 전부 `RoutexBottomSheet`이고, 지도와 무관한 한 항목의 자세한
/// 내용이나 되돌릴 수 없는 확인만 여기 온다. 지도를 가려도 되는 순간은 드물다.
///
/// **닫는 길이 항상 둘이다.** 바깥을 눌러도 닫히고 닫기 버튼으로도 닫힌다. 확인이
/// 필요한 dialog만 [confirmLabel]을 받고, 그때는 바깥 누르기가 막힌다 — 되돌릴 수
/// 없는 동작 앞에서 실수로 닫아 놓고 처리된 줄 아는 일을 막는다.
class RoutexDialog extends StatelessWidget {
  const RoutexDialog({
    required this.title,
    this.subtitle,
    this.media,
    this.description,
    this.facts = const <RoutexKeyValue>[],
    this.confirmLabel,
    this.onConfirm,
    this.closeLabel = '닫기',
    super.key,
  }) : assert(
         confirmLabel == null || onConfirm != null,
         '확인 이름만 있고 동작이 없으면 누를 수 없는 버튼이 된다',
       );

  final String title;

  /// 제목의 다른 표기(영문명 등)다. 뜻이 다른 정보는 여기 오지 않는다.
  final String? subtitle;

  /// 제목 위 사진 한 장. 비율은 넘기는 쪽이 정한다 — 메뉴 사진과 매장 사진은
  /// 원본 비율이 서로 다르고, 여기서 하나로 고정하면 한쪽이 잘린다.
  final Widget? media;

  final String? description;

  /// 라벨-값 표. 비어 있으면 블록째 그리지 않는다.
  final List<RoutexKeyValue> facts;

  final String? confirmLabel;
  final VoidCallback? onConfirm;
  final String closeLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;

    return Dialog(
      backgroundColor: colors.surfaceRaised,
      shape: const RoundedRectangleBorder(borderRadius: RoutexRadii.card),
      clipBehavior: Clip.antiAlias,
      // 화면 가장자리와의 거리도 제품 간격을 쓴다. Material 기본값(가로 40)은 이
      // 시스템의 어떤 간격과도 맞지 않아, dialog만 다른 격자 위에 놓인 것처럼 보인다.
      insetPadding: const EdgeInsets.all(RoutexSpacing.sectionGap),
      child: ConstrainedBox(
        // 폭을 제한하지 않으면 태블릿·웹에서 한 줄이 화면 폭만큼 길어져 읽는 눈이
        // 줄 끝에서 다음 줄 첫 글자를 찾지 못한다.
        constraints: const BoxConstraints(
          maxWidth: RoutexContentMeasure.dialog,
        ),
        child: SingleChildScrollView(
          child: Semantics(
            container: true,
            scopesRoute: true,
            explicitChildNodes: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ?media,
                Padding(
                  padding: const EdgeInsetsDirectional.all(
                    RoutexSpacing.componentPadding,
                  ),
                  child: RoutexStack(
                    gap: RoutexStackGap.content,
                    children: [
                      RoutexStack(
                        gap: RoutexStackGap.inline,
                        children: [
                          Semantics(
                            header: true,
                            child: Text(title, style: RoutexTypography.title),
                          ),
                          if (subtitle?.trim().isNotEmpty ?? false)
                            Text(
                              subtitle!,
                              style: RoutexTypography.bodySmall.copyWith(
                                color: colors.contentSecondary,
                              ),
                            ),
                        ],
                      ),
                      if (description?.trim().isNotEmpty ?? false)
                        Text(
                          RoutexTypography.keepWordsWhole(description!),
                          style: RoutexTypography.body,
                        ),
                      if (facts.isNotEmpty) RoutexKeyValueRows(rows: facts),
                      _Actions(
                        closeLabel: closeLabel,
                        confirmLabel: confirmLabel,
                        onConfirm: onConfirm,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.closeLabel,
    required this.confirmLabel,
    required this.onConfirm,
  });

  final String closeLabel;
  final String? confirmLabel;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    final close = RoutexButton(
      label: closeLabel,
      variant: confirmLabel == null
          // 닫기가 유일한 동작이면 그것이 이 표면의 주 행동이다. quiet으로 두면
          // 눌러야 할 곳이 화면에 하나도 없는 것처럼 보인다.
          ? RoutexButtonVariant.secondary
          : RoutexButtonVariant.quiet,
      onPressed: () => Navigator.of(context).pop(false),
    );

    if (confirmLabel == null) {
      return Align(alignment: AlignmentDirectional.centerEnd, child: close);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        close,
        const SizedBox(width: RoutexSpacing.controlGap),
        RoutexButton(
          label: confirmLabel!,
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm!();
          },
        ),
      ],
    );
  }
}

/// dialog를 띄운다.
///
/// 확인이 필요한 dialog는 바깥 누르기로 닫히지 않는다. 되돌릴 수 없는 동작 앞에서
/// 실수로 닫는 것과 취소하는 것은 결과가 같아 보이지만, 사용자는 전자를 "처리됐다"로
/// 읽는다.
Future<bool?> showRoutexDialog({
  required BuildContext context,
  required RoutexDialog dialog,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: dialog.confirmLabel == null,
    builder: (_) => dialog,
  );
}
