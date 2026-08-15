import 'package:flutter/material.dart';
import 'package:routex_design_system/routex_design_system.dart';

import '../catalog/catalog_tiles.dart';
import '../catalog/category_catalog.dart';
import '../catalog/geometry_catalog.dart';
import '../catalog/map_visual_catalog.dart';
import '../catalog/showcase_section.dart';
import '../catalog/tabular_catalog.dart';

/// 값 목록을 복사하지 않고 Runtime Kit이 공개한 역할 catalog를 순회한다.
class FoundationsPage extends StatelessWidget {
  const FoundationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    return RoutexStack(
      gap: RoutexStackGap.section,
      children: [
        ShowcaseSection(
          title: '시맨틱 색상',
          description:
              '제품 UI는 원시 색 이름이 아니라 surface·content·action·status 역할을 읽습니다. '
              '아래 목록은 Runtime Kit 공개 catalog에서 직접 가져옵니다.',
          child: RoutexCluster(
            gap: RoutexClusterGap.content,
            children: [
              for (final role in RoutexColorRole.values)
                ColorTile(role: role, color: role.resolve(colors)),
            ],
          ),
        ),
        const ShowcaseSection(
          title: '지도 시각 토큰',
          description:
              '지도 바탕·구조물·경로·마커는 제품 semantic 색과 분리된 지도 역할입니다. '
              '경로선과 UI 버튼의 파랑을 한 의미로 묶지 않습니다.',
          child: MapVisualCatalog(),
        ),
        ShowcaseSection(
          title: '타이포그래피',
          description:
              '크기와 굵기를 조합하지 않고 정보 위계 역할을 선택합니다. '
              '14px는 굵기로 역할이 갈립니다. 보조 본문은 bodySmall, 칩과 배지는 label입니다.',
          child: RoutexStack(
            gap: RoutexStackGap.control,
            children: [
              for (final role in RoutexTypographyRole.values)
                Text('${role.name} · 더현대 서울 1층 · 410m', style: role.textStyle),
            ],
          ),
        ),
        const ShowcaseSection(
          title: '매장 분류',
          description:
              '분류를 서로 구분하기 위한 고유색과 아이콘입니다. 제품 semantic 색과 다른 층이라 '
              '본문·CTA·오류 의미로 재사용하지 않습니다.',
          child: CategoryCatalog(),
        ),
        const ShowcaseSection(
          title: '고정폭 숫자',
          description:
              '남은 거리·시간·층처럼 값이 실시간으로 바뀌는 자리만 tabular로 감쌉니다. '
              '역할의 크기와 굵기는 그대로 두고 숫자 폭만 고정합니다.',
          child: TabularCatalog(),
        ),
        const ShowcaseSection(
          title: '간격 · 곡률 · 크기',
          description: '값이 같아도 screen과 component 역할을 바꾸어 쓰지 않습니다.',
          child: GeometryCatalog(),
        ),
        ShowcaseSection(
          title: '레이어 · 모션',
          description:
              '표면 역할은 깊이와 색을 함께 결정하고, 모션은 제품 컴포넌트 feedback·transition만 '
              '소유합니다. 지도 camera와 Promo Studio 연출은 이 층에 넣지 않습니다.',
          child: RoutexCluster(
            gap: RoutexClusterGap.content,
            children: [
              for (final role in RoutexSurfaceRole.values)
                ValueTile(label: 'surface.${role.name}', value: '표면 역할'),
              for (final role in RoutexLayerRole.values)
                LayerTile(role: role, colors: colors),
              for (final role in RoutexMotionRole.values)
                ValueTile(
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
