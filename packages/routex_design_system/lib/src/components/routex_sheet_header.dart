import 'package:flutter/material.dart';

import '../foundations/routex_icons.dart';
import '../foundations/routex_metrics.dart';
import '../foundations/routex_spacing.dart';
import '../foundations/routex_typography.dart';
import 'routex_icon_action.dart';

/// 시트 상단의 뒤로·제목·보조 상태·닫기 자리를 고정한다.
///
/// 시트마다 제목 위계와 버튼 위치를 다시 정하면 같은 기능이 다른 화면으로
/// 읽힌다. 이 줄의 좌우 자리는 다음 규칙으로만 쓴다.
///
/// - 왼쪽(`onBack`): 현재 시트만 닫고 이전 시트로 돌아간다.
/// - 오른쪽 끝(`onClose`): 시트 묶음 전체를 닫는다.
/// - `trailing`: 저장 토글처럼 **화면을 바꾸지 않는** 버튼만 온다. 닫기와 섞이면
///   무엇이 화면을 바꾸는 버튼인지 예측할 수 없다.
///
/// 시트를 여닫는 route와 gesture는 소비 앱이 소유한다. 이 컴포넌트는 시각 구조와
/// 접근성 이름만 고정한다.
class RoutexSheetHeader extends StatelessWidget {
  const RoutexSheetHeader({
    this.title,
    this.onBack,
    this.onClose,
    this.trailing,
    super.key,
  });

  final String? title;

  /// 이전 시트로 돌아간다. null이면 뒤로 자리를 비운다.
  final VoidCallback? onBack;

  /// 시트 묶음 전체를 닫는다. null이면 닫기 자리를 비운다.
  final VoidCallback? onClose;

  /// 닫기 왼쪽에 붙는, 화면을 바꾸지 않는 보조 동작이다.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: Row(
        children: [
          if (onBack case final onBack?)
            // 뒤로 자리는 자기 폭이 아니라 제목 열의 자리를 잡는다. 버튼 폭에
            // 간격을 더해 만든 자리는 행의 leading column과 폭이 달라, 같은
            // 시트 안에서 헤더 제목과 행 제목이 어긋난다.
            SizedBox(
              width: RoutexMetrics.textKeyline,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: RoutexIconAction(
                  label: '이전으로',
                  icon: RoutexIcons.back,
                  tone: RoutexIconActionTone.quiet,
                  onPressed: onBack,
                ),
              ),
            ),
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: RoutexTypography.title,
              ),
            ),
          ),
          if (trailing case final trailing?) ...[
            const SizedBox(width: RoutexSpacing.controlGap),
            trailing,
          ],
          if (onClose case final onClose?) ...[
            const SizedBox(width: RoutexSpacing.controlGap),
            RoutexIconAction(
              label: '닫기',
              icon: RoutexIcons.close,
              tone: RoutexIconActionTone.quiet,
              onPressed: onClose,
            ),
          ],
        ],
      ),
    );
  }
}
