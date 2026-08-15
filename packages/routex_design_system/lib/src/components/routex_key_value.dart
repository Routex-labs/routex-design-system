import 'package:flutter/material.dart';

import '../foundations/routex_spacing.dart';
import '../foundations/routex_typography.dart';
import '../theme/routex_color_tokens.dart';
import 'routex_divider.dart';

/// 라벨과 값이 짝을 이루는 한 줄이다.
@immutable
class RoutexKeyValue {
  const RoutexKeyValue({required this.label, required this.value});

  final String label;
  final String value;
}

/// 라벨-값 짝을 표로 세운다.
///
/// **아이콘이 라벨을 대신할 수 없는 값들의 자리다.** `용량 355ml`, `칼로리 190kcal`
/// 처럼 라벨이 값의 단위를 정하는 줄은 라벨을 지우면 숫자만 남는다. 라벨을 아이콘
/// 하나로 줄일 수 있는 줄은 `RoutexInfoRow`가 맡는다.
///
/// **값이 없는 라벨은 넘기지 않는다.** 라벨만 있고 값이 빈 표는 "정보가 없다"가
/// 아니라 "불러오지 못했다"로 읽힌다. 채울 값이 하나도 없으면 부르는 쪽이 이
/// 블록을 통째로 생략한다.
class RoutexKeyValueRows extends StatelessWidget {
  const RoutexKeyValueRows({required this.rows, super.key});

  final List<RoutexKeyValue> rows;

  @override
  Widget build(BuildContext context) {
    // 라벨만 있고 값이 빈 표는 "정보가 없다"가 아니라 "불러오지 못했다"로 읽힌다.
    assert(rows.isNotEmpty, '빈 표는 그리지 않는다');
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < rows.length; index++) ...[
          // 표는 줄 사이에 선을 긋는다. 목록과 달리 같은 성격의 값이 세로로
          // 이어지므로, 여백만으로는 어느 값이 어느 라벨의 것인지 흐려진다.
          if (index > 0) const RoutexDivider(role: RoutexDividerRole.row),
          _KeyValueRow(row: rows[index]),
        ],
      ],
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow({required this.row});

  final RoutexKeyValue row;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;

    return Semantics(
      container: true,
      label: '${row.label}, ${row.value}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          vertical: RoutexSpacing.controlGap,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              row.label,
              style: RoutexTypography.bodySmall.copyWith(
                color: colors.contentSecondary,
              ),
            ),
            const SizedBox(width: RoutexSpacing.componentPadding),
            // 값은 남는 폭을 전부 받고 오른쪽에 붙는다. 알레르기 성분처럼 스무
            // 자를 넘는 값이 있어서 고정폭으로 두면 표 밖으로 넘친다.
            Expanded(
              child: Text(
                row.value,
                textAlign: TextAlign.end,
                style: RoutexTypography.label,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
