import 'package:flutter/material.dart';

import '../foundations/routex_typography.dart';
import '../layout/routex_stack.dart';
import '../theme/routex_color_tokens.dart';

/// 상세 페이지에서 제목과 설명 행의 위계와 리듬을 고정한다.
class RoutexInfoSection extends StatelessWidget {
  const RoutexInfoSection({required this.title, required this.rows, super.key});

  final String title;
  final List<String> rows;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    return Semantics(
      container: true,
      child: RoutexStack(
        gap: RoutexStackGap.control,
        children: [
          Text(title, style: RoutexTypography.title),
          for (final row in rows)
            Text(
              row,
              style: RoutexTypography.body.copyWith(
                color: colors.contentSecondary,
              ),
            ),
        ],
      ),
    );
  }
}
