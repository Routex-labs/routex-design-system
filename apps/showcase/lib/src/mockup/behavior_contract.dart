import 'package:flutter/material.dart';
import 'package:routex_design_system/routex_design_system.dart';

import 'mockup_step.dart';

/// 현재 단계에서 제품이 지켜야 할 행동 계약을 목업 옆에 문서로 보여준다.
class BehaviorContract extends StatelessWidget {
  const BehaviorContract({required this.step, super.key});

  final MockupStep step;

  @override
  Widget build(BuildContext context) {
    final mapAsset = step.showsMapVisuals
        ? '원본 Navigation 기준 경로선·현재 위치·목적지 마커를 Showcase 지도 시각 계층으로 표시'
        : '단색 지도 canvas만 표시하고, 제품 UI는 Runtime Kit 표면으로 얹음';
    return Semantics(
      liveRegion: true,
      child: RoutexStack(
        gap: RoutexStackGap.content,
        children: [
          RoutexInfoSection(title: '현재 상태', rows: [step.label]),
          RoutexInfoSection(title: '주 행동', rows: [step.primaryAction]),
          RoutexInfoSection(title: '동작', rows: [step.behavior]),
          RoutexInfoSection(title: '지도 자산', rows: [mapAsset]),
          const RoutexInfoSection(
            title: '조작 규격',
            rows: ['아이콘 20/24 · 시각 높이 44 · 터치 영역 48'],
          ),
        ],
      ),
    );
  }
}
