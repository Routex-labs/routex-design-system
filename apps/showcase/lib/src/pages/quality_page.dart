import 'package:flutter/material.dart';
import 'package:routex_design_system/routex_design_system.dart';

import '../catalog/showcase_section.dart';
import '../fixtures/alignment_rhythm_fixture.dart';

/// 완료 판정에 쓰는 실패 기준과 모션 소유 경계를 그대로 보여준다.
class QualityPage extends StatefulWidget {
  const QualityPage({super.key});

  @override
  State<QualityPage> createState() => _QualityPageState();
}

class _QualityPageState extends State<QualityPage> {
  double _fixtureWidth = 390;
  double _textScale = 1;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _fixtureWidth = MediaQuery.sizeOf(context).width <= 375 ? 360 : 390;
    _initialized = true;
  }

  String get _widthId => 'fixture-width-${_fixtureWidth.toInt()}';

  String get _scaleId => switch (_textScale) {
    1 => 'fixture-scale-1.0',
    1.3 => 'fixture-scale-1.3',
    _ => 'fixture-scale-2.0',
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    return RoutexStack(
      gap: RoutexStackGap.section,
      children: [
        const _QualityChecklist(),
        ShowcaseSection(
          title: '정렬과 리듬',
          description:
              '실제 Runtime Kit 컴포넌트를 360/390px과 글자 배율 1.0/1.3/2.0에서 '
              '검수합니다. 기준 폭은 유지하고, 좁은 경우에만 가로로 확인합니다.',
          child: RoutexStack(
            gap: RoutexStackGap.content,
            children: [
              RoutexStack(
                gap: RoutexStackGap.control,
                children: [
                  const RoutexSectionHeader(
                    title: '판정 폭',
                    level: RoutexSectionHeaderLevel.group,
                  ),
                  RoutexChipBar(
                    semanticsLabel: '판정 폭',
                    options: const [
                      RoutexChipOption(id: 'fixture-width-360', label: '360px'),
                      RoutexChipOption(id: 'fixture-width-390', label: '390px'),
                    ],
                    selectedId: _widthId,
                    onSelected: (id) {
                      if (id == null) return;
                      setState(
                        () => _fixtureWidth = id == 'fixture-width-360'
                            ? 360
                            : 390,
                      );
                    },
                  ),
                  const RoutexSectionHeader(
                    title: '글자 배율',
                    level: RoutexSectionHeaderLevel.group,
                  ),
                  RoutexChipBar(
                    semanticsLabel: '글자 배율',
                    options: const [
                      RoutexChipOption(id: 'fixture-scale-1.0', label: '1.0×'),
                      RoutexChipOption(id: 'fixture-scale-1.3', label: '1.3×'),
                      RoutexChipOption(id: 'fixture-scale-2.0', label: '2.0×'),
                    ],
                    selectedId: _scaleId,
                    onSelected: (id) {
                      if (id == null) return;
                      setState(
                        () => _textScale = switch (id) {
                          'fixture-scale-1.0' => 1,
                          'fixture-scale-1.3' => 1.3,
                          _ => 2,
                        },
                      );
                    },
                  ),
                ],
              ),
              Text(
                '긴 한글·선택·비활성·위치 확인 실패와 48dp 터치 영역을 한 fixture에서 확인합니다.',
                style: RoutexTypography.bodySmall.copyWith(
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
        const ShowcaseSection(
          title: '모션 소유 경계',
          description: 'Runtime Kit은 제품 컴포넌트 모션까지만 소유합니다.',
          child: RoutexInfoSection(
            title: 'Runtime Kit',
            rows: [
              'feedback·transition·emphasized 같은 제품 컴포넌트 전환만 RoutexMotion을 사용합니다.',
              '지도 camera·PDR·업무 timer와 Promo Studio의 camera·particle·timeline·장면 연출은 각 소유 영역에 남깁니다.',
            ],
          ),
        ),
      ],
    );
  }
}

class _QualityChecklist extends StatelessWidget {
  const _QualityChecklist();

  static const _criteria = <({String label, String value})>[
    (label: '행동 위계', value: '한 화면에 같은 위계의 filled 주 행동이 두 개 이상이면 실패'),
    (label: '지도 가림', value: '선택 마커·현재 위치·남은 경로 중 핵심 자산이 UI에 모두 가려지면 실패'),
    (label: '컴포넌트 경계', value: '제품 UI 역할을 Showcase의 사설 카드·버튼·패널로 다시 구현하면 실패'),
    (
      label: '아이콘·터치',
      value: '의미 catalog 밖 아이콘, 20/24 규격 이탈, 48dp 미만 터치 영역이면 실패',
    ),
    (label: '레이아웃', value: '360px 또는 2배 글자에서 가로 overflow·잘림·행동 순서 붕괴가 생기면 실패'),
    (label: '이동수단', value: '지원하지 않는 수단을 노출하거나 선택 줄이 두 줄·세로 목록으로 무너지면 실패'),
    (
      label: '색상·표면',
      value: '본문 대비 4.5:1 미만, 비텍스트 3:1 미만, 의미 없는 gradient·중첩 표면이면 실패',
    ),
    (label: '상태 회복', value: '로딩·빈 값·API 실패·GPS 약함·경로 이탈에서 사용자가 복구할 동작이 없으면 실패'),
    (
      label: '포커스·모션',
      value: 'focus ring·reduced motion을 무시하거나 지도·프로모션 연출을 Runtime Kit에 넣으면 실패',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ShowcaseSection(
      title: '실패 기준',
      description: '아래 조건 중 하나라도 발생하면 해당 화면과 컴포넌트는 완료가 아닙니다.',
      child: RoutexStack(
        gap: RoutexStackGap.control,
        children: [
          for (final criterion in _criteria)
            RoutexListCell(
              key: ValueKey('quality-${criterion.label}'),
              title: criterion.label,
              subtitle: criterion.value,
            ),
        ],
      ),
    );
  }
}
