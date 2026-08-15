import 'package:flutter/material.dart';

import '../foundations/routex_metrics.dart';
import '../foundations/routex_radii.dart';
import '../foundations/routex_spacing.dart';
import '../foundations/routex_typography.dart';
import '../theme/routex_color_tokens.dart';

/// 지도 조작을 막지 않는 짧은 결과와 되돌리기 동작을 한 줄로 표시한다.
class RoutexInlineNotice extends StatelessWidget {
  const RoutexInlineNotice({
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    return Semantics(
      liveRegion: true,
      container: true,
      child: Material(
        color: colors.contentPrimary,
        borderRadius: RoutexRadii.field,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(
            start: RoutexSpacing.contentGap,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  message,
                  style: RoutexTypography.label.copyWith(
                    color: colors.contentInverse,
                  ),
                ),
              ),
              if (actionLabel != null)
                TextButton(
                  onPressed: onAction,
                  style: TextButton.styleFrom(
                    foregroundColor: colors.contentInverse,
                    textStyle: RoutexTypography.label,
                    // 알림 표면과 같은 곡률 계열을 쓴다. 버튼만 알약이 되면 한
                    // 덩어리가 아니라 두 표면이 겹친 것처럼 읽힌다.
                    shape: const RoundedRectangleBorder(
                      borderRadius: RoutexRadii.control,
                    ),
                    minimumSize: const Size(0, RoutexMetrics.standardControl),
                    tapTargetSize: MaterialTapTargetSize.padded,
                  ),
                  child: Text(actionLabel!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
