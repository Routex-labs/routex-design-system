import 'package:flutter/material.dart';
import 'package:routex_design_system/routex_design_system.dart';

import '../pages/components_page.dart';
import '../pages/foundations_page.dart';
import '../pages/gallery_page.dart';
import '../pages/product_page.dart';
import '../pages/quality_page.dart';

enum ShowcasePage { product, gallery, components, foundations, quality }

extension ShowcasePageLabel on ShowcasePage {
  String get label => switch (this) {
    ShowcasePage.product => '제품 UX',
    ShowcasePage.gallery => '한눈에',
    ShowcasePage.components => '컴포넌트',
    ShowcasePage.foundations => '기초',
    ShowcasePage.quality => '품질 기준',
  };
}

/// 페이지 전환만 소유한다. 각 페이지의 내용과 상태는 페이지가 직접 가진다.
class ShowcaseHome extends StatefulWidget {
  const ShowcaseHome({super.key});

  @override
  State<ShowcaseHome> createState() => _ShowcaseHomeState();
}

class _ShowcaseHomeState extends State<ShowcaseHome> {
  // 쇼케이스를 여는 순간 제품 흐름 전체를 먼저 훑고, 필요한 기준으로 들어간다.
  ShowcasePage _page = ShowcasePage.gallery;

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
                // 갤러리는 한 번에 훑는 화면이라 가로를 다 쓴다. 나머지 페이지는
                // 읽는 화면이라 읽기 좋은 폭으로 제한한다.
                constraints: BoxConstraints(
                  maxWidth: _page == ShowcasePage.gallery
                      ? double.infinity
                      : 1040,
                ),
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
                          'Runtime Kit의 토큰, 컴포넌트, 모바일 UX 동작을 실제 Flutter 위젯으로 확인합니다.',
                          style: RoutexTypography.body.copyWith(
                            color: colors.contentSecondary,
                          ),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: RoutexSpacing.controlGap,
                      runSpacing: RoutexSpacing.controlGap,
                      children: [
                        for (final page in ShowcasePage.values)
                          ChoiceChip(
                            key: ValueKey('showcase-page-${page.name}'),
                            label: Text(page.label),
                            selected: page == _page,
                            showCheckmark: false,
                            onSelected: (_) => setState(() => _page = page),
                          ),
                      ],
                    ),
                    AnimatedSwitcher(
                      duration: RoutexMotion.transition,
                      child: KeyedSubtree(
                        key: ValueKey(_page),
                        child: switch (_page) {
                          ShowcasePage.product => const ProductPage(),
                          ShowcasePage.gallery => const GalleryPage(),
                          ShowcasePage.components => const ComponentsPage(),
                          ShowcasePage.foundations => const FoundationsPage(),
                          ShowcasePage.quality => const QualityPage(),
                        },
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
