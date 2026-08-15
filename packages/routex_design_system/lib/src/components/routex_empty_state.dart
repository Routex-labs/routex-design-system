import 'package:flutter/material.dart';

import '../foundations/routex_metrics.dart';
import '../foundations/routex_typography.dart';
import '../layout/routex_stack.dart';
import '../theme/routex_color_tokens.dart';
import 'routex_button.dart';

/// 데이터가 없음을 가짜 콘텐츠 대신 제목·설명·선택적 행동으로 명확히 표시한다.
class RoutexEmptyState extends StatelessWidget {
  const RoutexEmptyState({
    required this.title,
    required this.description,
    required this.icon,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    return Semantics(
      container: true,
      child: Center(
        child: RoutexStack(
          gap: RoutexStackGap.control,
          children: [
            Icon(
              icon,
              size: RoutexMetrics.iconLarge,
              color: colors.contentDisabled,
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: RoutexTypography.title,
            ),
            Text(
              description,
              textAlign: TextAlign.center,
              style: RoutexTypography.body.copyWith(
                color: colors.contentSecondary,
              ),
            ),
            if (actionLabel != null)
              Align(
                child: RoutexButton(
                  label: actionLabel!,
                  variant: RoutexButtonVariant.secondary,
                  onPressed: onAction,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
