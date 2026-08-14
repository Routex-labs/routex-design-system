import 'package:flutter/material.dart';
import 'package:routex_design_system/routex_design_system.dart';

/// ListCell과 Sheet를 만들기 전에 정렬·긴 문장·상태 위계를 검증하는 모바일 fixture다.
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
      child: Padding(
        padding: const EdgeInsets.all(RoutexSpacing.screenGutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('저장한 장소', style: RoutexTypography.title),
            const SizedBox(height: RoutexSpacing.sectionGap),
            const _FixtureRow(
              icon: Icons.storefront_outlined,
              title: '더현대 서울에서 저장한 아주 긴 장소 이름',
              subtitle: 'B2 · 카페·베이커리',
            ),
            const SizedBox(height: RoutexSpacing.contentGap),
            const _FixtureRow(
              title: 'leading이 없어도 제목과 설명의 시작선은 유지됩니다',
              subtitle: '같은 역할의 콘텐츠는 같은 column을 사용합니다.',
            ),
            const SizedBox(height: RoutexSpacing.sectionGap),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.statusWarningSubtle,
                borderRadius: RoutexRadii.field,
              ),
              child: Padding(
                padding: const EdgeInsets.all(RoutexSpacing.componentPadding),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '현재 위치를 확인할 수 없어요',
                            style: RoutexTypography.bodyStrong,
                          ),
                          const SizedBox(height: RoutexSpacing.inlineGap),
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
            const SizedBox(height: RoutexSpacing.contentGap),
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
      ),
    );
  }
}

void _noop() {}

class _FixtureRow extends StatelessWidget {
  const _FixtureRow({required this.title, required this.subtitle, this.icon});

  final String title;
  final String subtitle;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: RoutexMetrics.leadingColumn,
          child: icon == null
              ? null
              : Align(
                  alignment: AlignmentDirectional.topStart,
                  child: Icon(
                    icon,
                    size: RoutexMetrics.iconMedium,
                    color: context.routexColors.actionPrimary,
                  ),
                ),
        ),
        const SizedBox(width: RoutexSpacing.contentGap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: RoutexTypography.bodyStrong),
              const SizedBox(height: RoutexSpacing.inlineGap),
              Text(
                subtitle,
                style: RoutexTypography.body.copyWith(
                  color: context.routexColors.contentSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
