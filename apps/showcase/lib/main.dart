import 'package:flutter/material.dart';
import 'package:routex_design_system/routex_design_system.dart';

void main() => runApp(const RoutexShowcaseApp());

class RoutexShowcaseApp extends StatelessWidget {
  const RoutexShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Routex Design System',
      debugShowCheckedModeBanner: false,
      theme: RoutexTheme.light,
      home: const ShowcaseHome(),
    );
  }
}

class ShowcaseHome extends StatelessWidget {
  const ShowcaseHome({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 800;
            final gutter = wide
                ? RoutexSpacing.screenGutterWide
                : RoutexSpacing.screenGutterCompact;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: gutter,
                vertical: RoutexSpacing.sectionGap,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1040),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Routex Design System',
                        style: RoutexTypography.display.copyWith(
                          color: colors.contentPrimary,
                        ),
                      ),
                      const SizedBox(height: RoutexSpacing.controlGap),
                      Text(
                        '차분한 공간 안내 · 명료한 다음 행동 · 신뢰할 수 있는 상태',
                        style: RoutexTypography.body.copyWith(
                          color: colors.contentSecondary,
                        ),
                      ),
                      const SizedBox(height: RoutexSpacing.controlGap),
                      const _StatusBadge(),
                      const SizedBox(height: RoutexSpacing.sectionGap),
                      _Section(
                        title: 'Semantic colors',
                        description: '색 이름이 아니라 제품에서 맡는 역할로 사용합니다.',
                        child: Wrap(
                          spacing: RoutexSpacing.controlGap,
                          runSpacing: RoutexSpacing.controlGap,
                          children: [
                            _ColorTile(
                              name: 'actionPrimary',
                              color: colors.actionPrimary,
                            ),
                            _ColorTile(
                              name: 'surfaceCanvas',
                              color: colors.surfaceCanvas,
                            ),
                            _ColorTile(
                              name: 'contentPrimary',
                              color: colors.contentPrimary,
                            ),
                            _ColorTile(
                              name: 'statusError',
                              color: colors.statusError,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: RoutexSpacing.sectionGap),
                      const _Section(
                        title: 'Typography',
                        description: '크기와 굵기를 조합하지 않고 역할을 선택합니다.',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Headline · 다음 안내',
                              style: RoutexTypography.headline,
                            ),
                            SizedBox(height: RoutexSpacing.controlGap),
                            Text(
                              'Title · 스타벅스 리저브',
                              style: RoutexTypography.title,
                            ),
                            SizedBox(height: RoutexSpacing.controlGap),
                            Text(
                              'Body · B2층까지 약 3분 걸려요.',
                              style: RoutexTypography.body,
                            ),
                            SizedBox(height: RoutexSpacing.controlGap),
                            Text(
                              'Label · 경로 미리보기',
                              style: RoutexTypography.label,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: RoutexSpacing.sectionGap),
                      _Section(
                        title: 'Button · beta',
                        description: '같은 Runtime Kit의 실제 Flutter 컴포넌트입니다.',
                        child: Wrap(
                          spacing: RoutexSpacing.controlGap,
                          runSpacing: RoutexSpacing.controlGap,
                          children: [
                            RoutexButton(label: '길찾기', onPressed: () {}),
                            RoutexButton(
                              label: '다른 출발지',
                              variant: RoutexButtonVariant.secondary,
                              onPressed: () {},
                            ),
                            RoutexButton(
                              label: '나중에',
                              variant: RoutexButtonVariant.quiet,
                              onPressed: () {},
                            ),
                            const RoutexButton(
                              label: '경로 계산 중',
                              onPressed: null,
                              isLoading: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: RoutexSpacing.sectionGap),
                      const _MotionBoundary(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: RoutexRadii.card,
        border: Border.all(color: colors.borderSubtle),
        boxShadow: RoutexShadows.chrome,
      ),
      child: Padding(
        padding: const EdgeInsets.all(RoutexSpacing.controlPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: RoutexTypography.title),
            const SizedBox(height: RoutexSpacing.controlGap),
            Text(
              description,
              style: RoutexTypography.body.copyWith(
                color: colors.contentSecondary,
              ),
            ),
            const SizedBox(height: RoutexSpacing.contentGap),
            child,
          ],
        ),
      ),
    );
  }
}

class _ColorTile extends StatelessWidget {
  const _ColorTile({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: RoutexRadii.control,
              border: Border.all(color: context.routexColors.borderSubtle),
            ),
            child: const SizedBox(width: 150, height: 72),
          ),
          const SizedBox(height: RoutexSpacing.controlGap),
          Text(name, style: RoutexTypography.label),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.routexColors.surfaceBase,
        borderRadius: RoutexRadii.pill,
        border: Border.all(color: context.routexColors.borderSubtle),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: RoutexSpacing.contentGap,
          vertical: RoutexSpacing.controlGap,
        ),
        child: Text('v0.0.1 · bootstrap', style: RoutexTypography.label),
      ),
    );
  }
}

class _MotionBoundary extends StatelessWidget {
  const _MotionBoundary();

  @override
  Widget build(BuildContext context) {
    return const _Section(
      title: 'Motion boundary',
      description: 'Runtime Kit은 제품 컴포넌트 모션까지만 소유합니다.',
      child: Text(
        '120ms / 200ms / 320ms · 카메라, 파티클, 영상 타임라인과 장면 연출은 Promo Studio 소유',
        style: RoutexTypography.bodyStrong,
      ),
    );
  }
}
