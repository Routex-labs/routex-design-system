import 'package:flutter/material.dart';
import 'package:routex_design_system/routex_design_system.dart';

import 'src/alignment_rhythm_fixture.dart';

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

class ShowcaseHome extends StatefulWidget {
  const ShowcaseHome({super.key});

  @override
  State<ShowcaseHome> createState() => _ShowcaseHomeState();
}

class _ShowcaseHomeState extends State<ShowcaseHome> {
  double _fixtureWidth = 390;
  double _textScale = 1;
  bool _fixtureWidthInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_fixtureWidthInitialized) return;
    _fixtureWidth = MediaQuery.sizeOf(context).width <= 375 ? 360 : 390;
    _fixtureWidthInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;

    return Scaffold(
      body: SafeArea(
        child: RoutexInset(
          role: RoutexInsetRole.screen,
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: RoutexStack(
                  gap: RoutexStackGap.section,
                  children: [
                    RoutexStack(
                      gap: RoutexStackGap.control,
                      children: [
                        Text(
                          'Routex Design System',
                          style: RoutexTypography.display.copyWith(
                            color: colors.contentPrimary,
                          ),
                        ),
                        Text(
                          '차분한 공간 안내 · 명료한 다음 행동 · 신뢰할 수 있는 상태',
                          style: RoutexTypography.body.copyWith(
                            color: colors.contentSecondary,
                          ),
                        ),
                      ],
                    ),
                    _ShowcaseSection(
                      title: 'Alignment & Rhythm',
                      description: '모바일 폭과 글자 배율에서 시작선·간격·상태 위계를 비교합니다.',
                      child: RoutexStack(
                        gap: RoutexStackGap.content,
                        children: [
                          RoutexCluster(
                            gap: RoutexClusterGap.control,
                            children: [
                              SegmentedButton<double>(
                                segments: const [
                                  ButtonSegment(
                                    value: 360,
                                    label: Text('360px'),
                                  ),
                                  ButtonSegment(
                                    value: 390,
                                    label: Text('390px'),
                                  ),
                                ],
                                selected: {_fixtureWidth},
                                onSelectionChanged: (selection) {
                                  setState(
                                    () => _fixtureWidth = selection.first,
                                  );
                                },
                              ),
                              SegmentedButton<double>(
                                segments: const [
                                  ButtonSegment(value: 1, label: Text('1.0×')),
                                  ButtonSegment(
                                    value: 1.3,
                                    label: Text('1.3×'),
                                  ),
                                  ButtonSegment(value: 2, label: Text('2.0×')),
                                ],
                                selected: {_textScale},
                                onSelectionChanged: (selection) {
                                  setState(() => _textScale = selection.first);
                                },
                              ),
                            ],
                          ),
                          Text(
                            '정확한 기준 폭을 유지하므로 좁은 화면에서는 좌우로 확인합니다.',
                            style: RoutexTypography.caption.copyWith(
                              color: colors.contentSecondary,
                            ),
                          ),
                          AlignmentRhythmFixture(
                            width: _fixtureWidth,
                            textScale: _textScale,
                          ),
                        ],
                      ),
                    ),
                    _ShowcaseSection(
                      title: 'Button · beta',
                      description:
                          '새 semantic token과 공통 metric을 사용하는 실제 컴포넌트입니다.',
                      child: RoutexCluster(
                        gap: RoutexClusterGap.control,
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
                          RoutexButton(
                            label: '삭제',
                            variant: RoutexButtonVariant.danger,
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
                    const _ShowcaseSection(
                      title: 'ListCell · beta',
                      description:
                          'leading 유무에도 텍스트 열을 유지하고 상태·긴 문장·접근성을 함께 검증합니다.',
                      child: RoutexStack(
                        gap: RoutexStackGap.content,
                        children: [
                          RoutexListCell(
                            title: '더현대 서울',
                            subtitle: 'B2 · 카페·베이커리',
                            leadingIcon: Icons.storefront_outlined,
                            trailingIcon: Icons.chevron_right,
                            onPressed: _noop,
                          ),
                          RoutexListCell(
                            title: '아이콘이 없는 선택 상태',
                            subtitle: '텍스트 시작선은 위 행과 같습니다.',
                            selected: true,
                            onPressed: _noop,
                          ),
                          RoutexListCell(
                            title: '보조정보가 없는 장소',
                            onPressed: _noop,
                          ),
                          RoutexListCell(
                            title: '현재 사용할 수 없는 장소',
                            enabled: false,
                            onPressed: _noop,
                          ),
                        ],
                      ),
                    ),
                    const _FoundationCatalog(),
                    const _ShowcaseSection(
                      title: 'Motion boundary',
                      description: 'Runtime Kit은 제품 컴포넌트 모션까지만 소유합니다.',
                      child: Text(
                        '지도 camera·PDR·업무 timer와 Promo Studio의 카메라 이동·particle·timeline·장면 연출은 각 소유 영역에 남깁니다.',
                        style: RoutexTypography.bodyStrong,
                      ),
                    ),
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

void _noop() {}

class _FoundationCatalog extends StatelessWidget {
  const _FoundationCatalog();

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    return RoutexStack(
      gap: RoutexStackGap.section,
      children: [
        _ShowcaseSection(
          title: 'Semantic colors',
          description: '색 이름이 아니라 Runtime Kit이 공개한 역할 catalog를 순회합니다.',
          child: RoutexCluster(
            gap: RoutexClusterGap.content,
            children: [
              for (final role in RoutexColorRole.values)
                _ColorTile(role: role, color: role.resolve(colors)),
            ],
          ),
        ),
        _ShowcaseSection(
          title: 'Typography',
          description: '크기와 굵기를 조합하지 않고 정보 위계 역할을 선택합니다.',
          child: RoutexStack(
            gap: RoutexStackGap.control,
            children: [
              for (final role in RoutexTypographyRole.values)
                Text('${role.name} · 더현대 서울 길안내', style: role.textStyle),
            ],
          ),
        ),
        const _ShowcaseSection(
          title: 'Spacing · Radius · Metrics',
          description: '값이 같아도 screen과 component 역할을 바꾸어 쓰지 않습니다.',
          child: _GeometryCatalog(),
        ),
        _ShowcaseSection(
          title: 'Layer · Motion',
          description: '지도 위 깊이 세 단계와 제품 컴포넌트 motion만 공개합니다.',
          child: RoutexCluster(
            gap: RoutexClusterGap.content,
            children: [
              for (final role in RoutexLayerRole.values)
                _LayerTile(role: role, colors: colors),
              for (final role in RoutexMotionRole.values)
                _ValueTile(
                  label: role.name,
                  value: '${role.duration.inMilliseconds}ms',
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GeometryCatalog extends StatelessWidget {
  const _GeometryCatalog();

  @override
  Widget build(BuildContext context) {
    return RoutexCluster(
      gap: RoutexClusterGap.content,
      children: [
        for (final role in RoutexSpacingRole.values)
          _ValueTile(label: role.name, value: '${role.value.toInt()}px'),
        for (final role in RoutexMetricRole.values)
          _ValueTile(label: role.name, value: '${role.value.toInt()}px'),
        for (final role in RoutexRadiusRole.values) _RadiusTile(role: role),
      ],
    );
  }
}

class _ShowcaseSection extends StatelessWidget {
  const _ShowcaseSection({
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
    return SizedBox(
      key: ValueKey('showcase-section-$title'),
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceRaised,
          borderRadius: RoutexRadii.card,
          border: Border.all(color: colors.borderSubtle),
          boxShadow: RoutexLayer.shadow(RoutexLayerRole.chrome, colors),
        ),
        child: RoutexInset(
          role: RoutexInsetRole.component,
          child: RoutexStack(
            gap: RoutexStackGap.content,
            children: [
              RoutexStack(
                gap: RoutexStackGap.control,
                children: [
                  Text(title, style: RoutexTypography.title),
                  Text(
                    description,
                    style: RoutexTypography.body.copyWith(
                      color: colors.contentSecondary,
                    ),
                  ),
                ],
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorTile extends StatelessWidget {
  const _ColorTile({required this.role, required this.color});

  final RoutexColorRole role;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 144,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: RoutexRadii.control,
              border: Border.all(color: context.routexColors.borderSubtle),
            ),
            child: const SizedBox(width: 144, height: 64),
          ),
          const SizedBox(height: RoutexSpacing.controlGap),
          Text(role.name, style: RoutexTypography.label),
        ],
      ),
    );
  }
}

class _ValueTile extends StatelessWidget {
  const _ValueTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 144,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.routexColors.surfaceCanvas,
          borderRadius: RoutexRadii.control,
        ),
        child: Padding(
          padding: const EdgeInsets.all(RoutexSpacing.contentGap),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: RoutexTypography.label),
              const SizedBox(height: RoutexSpacing.inlineGap),
              Text(value, style: RoutexTypography.bodyStrong),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadiusTile extends StatelessWidget {
  const _RadiusTile({required this.role});

  final RoutexRadiusRole role;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 144,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.routexColors.actionPrimarySubtle,
          borderRadius: role.borderRadius,
          border: Border.all(color: context.routexColors.actionPrimary),
        ),
        child: Padding(
          padding: const EdgeInsets.all(RoutexSpacing.contentGap),
          child: Text(role.name, style: RoutexTypography.label),
        ),
      ),
    );
  }
}

class _LayerTile extends StatelessWidget {
  const _LayerTile({required this.role, required this.colors});

  final RoutexLayerRole role;
  final RoutexColorTokens colors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 144,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceRaised,
          borderRadius: RoutexRadii.control,
          border: Border.all(color: colors.borderSubtle),
          boxShadow: RoutexLayer.shadow(role, colors),
        ),
        child: Padding(
          padding: const EdgeInsets.all(RoutexSpacing.contentGap),
          child: Text(
            '${role.name} · ${role.elevation.toInt()}',
            style: RoutexTypography.label,
          ),
        ),
      ),
    );
  }
}
