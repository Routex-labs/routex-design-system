import 'package:flutter/material.dart';
import 'package:routex_design_system/routex_design_system.dart';

/// 실제 공통 컴포넌트의 정렬·긴 문장·상태 위계를 검증하는 모바일 fixture다.
class AlignmentRhythmFixture extends StatelessWidget {
  const AlignmentRhythmFixture({
    required this.width,
    required this.textScale,
    super.key,
  });

  final double width;
  final double textScale;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: width,
        child: MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: const _MobileFixtureSurface(),
        ),
      ),
    );
  }
}

class _MobileFixtureSurface extends StatelessWidget {
  const _MobileFixtureSurface();

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceBase,
        borderRadius: RoutexRadii.card,
        border: Border.all(color: colors.borderStrong),
      ),
      child: RoutexInset(
        role: RoutexInsetRole.component,
        child: RoutexStack(
          gap: RoutexStackGap.section,
          children: [
            Text('저장한 장소', style: RoutexTypography.title),
            const RoutexStack(
              gap: RoutexStackGap.content,
              children: [
                RoutexListCell(
                  title: '더현대 서울에서 저장한 아주 긴 장소 이름',
                  subtitle: 'B2 · 카페·베이커리',
                  leadingIcon: Icons.storefront_outlined,
                  trailingIcon: Icons.chevron_right,
                  onPressed: _noop,
                ),
                RoutexListCell(
                  title: 'leading이 없어도 제목과 설명의 시작선은 유지됩니다',
                  subtitle: '같은 역할의 콘텐츠는 같은 column을 사용합니다.',
                  selected: true,
                  onPressed: _noop,
                ),
                RoutexListCell(
                  title: '현재 사용할 수 없는 장소',
                  enabled: false,
                  onPressed: _noop,
                ),
              ],
            ),
            RoutexStack(
              gap: RoutexStackGap.content,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.statusWarningSubtle,
                    borderRadius: RoutexRadii.field,
                  ),
                  child: RoutexInset(
                    role: RoutexInsetRole.component,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_searching,
                          size: RoutexMetrics.iconMedium,
                          color: colors.statusWarning,
                        ),
                        const SizedBox(width: RoutexSpacing.controlGap),
                        Expanded(
                          child: RoutexStack(
                            gap: RoutexStackGap.inline,
                            children: [
                              Text(
                                '현재 위치를 확인할 수 없어요',
                                style: RoutexTypography.bodyStrong,
                              ),
                              Text(
                                '지도에서 위치를 직접 지정하거나 기기의 위치 권한을 확인해주세요.',
                                style: RoutexTypography.body.copyWith(
                                  color: colors.contentSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: RoutexButton(
                    label: '지도에서 현재 위치 직접 지정',
                    leadingIcon: Icons.pin_drop_outlined,
                    onPressed: _noop,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void _noop() {}
