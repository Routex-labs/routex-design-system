@TestOn('linux')
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_design_system/routex_design_system.dart';
import 'package:showcase/src/pages/components_page.dart';
import 'package:showcase/src/pages/gallery_page.dart';

import 'package:showcase/src/data/showcase_place_detail_data.dart';

import 'support/golden_fonts.dart';

/// 갤러리·컴포넌트 탭은 지금까지 눈으로만 회귀를 확인했다. 이 두 탭이 카탈로그의
/// 실제 표면이라, 여기서 어긋나면 제품 목업이 멀쩡해도 시스템이 어긋난 것이다.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(loadGoldenFonts);

  Future<void> pump(WidgetTester tester, Widget page, Size size) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: RoutexTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(RoutexSpacing.sectionGap),
            // 칠하는 층을 여기서 끊어 둔다. 층이 없으면 어느 위젯을 지목해도
            // 화면 전체가 찍혀, 골든이 사실상 같은 그림 여러 장이 된다.
            child: RepaintBoundary(
              key: const ValueKey('golden-target'),
              child: page,
            ),
          ),
        ),
      ),
    );
    // 로딩 버튼의 회전 표시는 끝나지 않으므로 pumpAndSettle은 돌아오지 않는다.
    // 테스트 시계는 가짜라 같은 시간만큼 돌리면 회전 각도도 늘 같은 자리에 선다.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// 사진을 image cache에 먼저 올린다.
  ///
  /// 골든은 가짜 시계로 도니 asset 디코딩이 끝나기를 기다릴 수 없고, 그대로 찍으면
  /// 사진 자리가 빈 채로 승인된다. 상세 카드는 사진이 차지하는 높이가 곧 배치라
  /// 빈 자리를 기준으로 삼으면 골든이 실제 화면을 대변하지 못한다.
  Future<void> warmImages(WidgetTester tester) async {
    final assets = [
      ...ShowcasePlaceDetail.osulloc.heroAssets,
      for (final item in ShowcasePlaceDetail.osulloc.menu)
        if (item.imageAsset != null) item.imageAsset!,
    ];
    await tester.runAsync(() async {
      for (final asset in assets) {
        final stream = AssetImage(asset).resolve(ImageConfiguration.empty);
        final loaded = Completer<void>();
        late final ImageStreamListener listener;
        listener = ImageStreamListener(
          (_, _) {
            stream.removeListener(listener);
            if (!loaded.isCompleted) loaded.complete();
          },
          onError: (_, _) {
            stream.removeListener(listener);
            if (!loaded.isCompleted) loaded.complete();
          },
        );
        stream.addListener(listener);
        await loaded.future;
      }
    });
  }

  // 갤러리는 언제나 네 열로 배치하고, 창이 그보다 좁으면 그 결과를 통째로 축소한다.
  // 두 골든은 그 두 경우다 — 축소가 걸리지 않는 넓은 창과, 걸리는 좁은 창.
  // 좁은 쪽에서 확인하는 것은 "작아졌는가"가 아니라 **카드 사이 비율이 그대로인가**다.
  for (final (name, width) in const [
    ('gallery_four_columns', 1800.0),
    ('gallery_scaled_to_fit', 1100.0),
  ]) {
    testWidgets('갤러리 $name golden', (tester) async {
      await warmImages(tester);
      await pump(tester, const GalleryPage(), Size(width, 9000));

      await expectLater(
        find.byKey(const ValueKey('golden-target')),
        matchesGoldenFile('goldens/$name.png'),
      );
    });
  }

  // 컴포넌트 탭은 섹션 단위로 나눠 찍는다. 한 장으로 묶으면 어느 섹션이 바뀌었는지
  // 그림만 봐서는 알 수 없고, 관계없는 섹션 하나만 손대도 전체가 다시 승인 대상이
  // 된다.
  for (final section in const [
    '행동 · beta',
    '목록과 묶음 · beta',
    '입력과 필터 · beta',
    '표면 · beta',
    '장소와 안내 · beta',
    '상태 · beta',
    '매장 상세 · beta',
    '목록과 대기 · beta',
    '경로와 도착 · beta',
  ]) {
    testWidgets('컴포넌트 "$section" golden', (tester) async {
      await warmImages(tester);
      await pump(tester, const ComponentsPage(), const Size(1000, 9000));

      final slug = _slug(section);
      await expectLater(
        find.byKey(ValueKey('showcase-section-$section')),
        matchesGoldenFile('goldens/components_$slug.png'),
      );
    });
  }
}

/// 섹션 제목을 파일 이름으로 쓸 수 있게 바꾼다. 한글 제목을 그대로 파일명에 쓰면
/// 플랫폼마다 정규화가 달라 골든을 못 찾는 일이 생긴다.
String _slug(String section) {
  const slugs = {
    '행동 · beta': 'action',
    '목록과 묶음 · beta': 'list',
    '입력과 필터 · beta': 'input',
    '표면 · beta': 'surface',
    '장소와 안내 · beta': 'place',
    '상태 · beta': 'status',
    '매장 상세 · beta': 'place_detail',
    '목록과 대기 · beta': 'result',
    '경로와 도착 · beta': 'guidance',
  };
  return slugs[section]!;
}
