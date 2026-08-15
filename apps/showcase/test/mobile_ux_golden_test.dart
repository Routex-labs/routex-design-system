import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_design_system/routex_design_system.dart';
import 'package:showcase/src/mockup/mobile_ux_showcase.dart';

import 'support/golden_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(loadGoldenFonts);

  Future<void> pumpShowcase(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 1400);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: RoutexTheme.light,
        home: const Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.all(RoutexSpacing.sectionGap),
            child: MobileUxShowcase(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('메인 iPhone 목업 golden', (tester) async {
    await pumpShowcase(tester);

    await expectLater(
      find.byKey(const ValueKey('iphone-mockup')),
      matchesGoldenFile('goldens/mobile_ux_home.png'),
    );
  });

  testWidgets('메뉴 시트 iPhone 목업 golden', (tester) async {
    await pumpShowcase(tester);
    await tester.tap(find.byTooltip('메뉴'));
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(const ValueKey('iphone-mockup')),
      matchesGoldenFile('goldens/mobile_ux_menu.png'),
    );
  });

  testWidgets('장소 선택 iPhone 목업 golden', (tester) async {
    await pumpShowcase(tester);
    await tester.tap(find.byKey(const ValueKey('mockup-step-place')));
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(const ValueKey('iphone-mockup')),
      matchesGoldenFile('goldens/mobile_ux_place.png'),
    );
  });

  testWidgets('경로 미리보기 iPhone 목업 golden', (tester) async {
    await pumpShowcase(tester);
    await tester.tap(find.byKey(const ValueKey('mockup-step-route')));
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(const ValueKey('iphone-mockup')),
      matchesGoldenFile('goldens/mobile_ux_route.png'),
    );
  });

  testWidgets('가게 상세 iPhone 목업 golden', (tester) async {
    await pumpShowcase(tester);
    await tester.tap(find.byKey(const ValueKey('mockup-step-detail')));
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(const ValueKey('iphone-mockup')),
      matchesGoldenFile('goldens/mobile_ux_detail.png'),
    );
  });

  testWidgets('이동 안내 iPhone 목업 golden', (tester) async {
    await pumpShowcase(tester);
    await tester.tap(find.byKey(const ValueKey('mockup-step-guidance')));
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(const ValueKey('iphone-mockup')),
      matchesGoldenFile('goldens/mobile_ux_guidance.png'),
    );
  });

  testWidgets('실내 안내 iPhone 목업 golden', (tester) async {
    await pumpShowcase(tester);
    await tester.tap(find.byKey(const ValueKey('mockup-step-indoor')));
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(const ValueKey('iphone-mockup')),
      matchesGoldenFile('goldens/mobile_ux_indoor.png'),
    );
  });

  testWidgets('도착 iPhone 목업 golden', (tester) async {
    await pumpShowcase(tester);
    await tester.tap(find.byKey(const ValueKey('mockup-step-arrival')));
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(const ValueKey('iphone-mockup')),
      matchesGoldenFile('goldens/mobile_ux_arrival.png'),
    );
  });
}
