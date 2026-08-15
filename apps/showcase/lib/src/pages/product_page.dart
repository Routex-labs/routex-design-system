import 'package:flutter/material.dart';

import '../catalog/showcase_section.dart';
import '../mockup/mobile_ux_showcase.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShowcaseSection(
      title: '모바일 UX 목업',
      description: '장소 선택부터 도착까지의 주 행동과 지도 반응을 iPhone 19.5:9 비율에서 직접 조작합니다.',
      child: MobileUxShowcase(),
    );
  }
}
