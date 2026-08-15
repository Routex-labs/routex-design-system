import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_design_system/routex_design_system.dart';
import 'package:showcase/src/app/showcase_app.dart';
import 'package:showcase/src/fixtures/alignment_rhythm_fixture.dart';
import 'package:showcase/src/mockup/mobile_ux_showcase.dart';

void main() {
  testWidgets('Runtime Kit의 catalog와 실제 버튼을 렌더링한다', (tester) async {
    await tester.pumpWidget(const RoutexShowcaseApp());

    expect(find.text('Routex Design System'), findsOneWidget);
    expect(find.byType(RoutexRoutePlanner), findsOneWidget);
    expect(find.byType(MobileUxShowcase), findsNothing);

    await _openPage(
      tester,
      find.byKey(const ValueKey('showcase-page-product')),
    );
    expect(find.text('모바일 UX 목업'), findsOneWidget);

    await _openPage(
      tester,
      find.byKey(const ValueKey('showcase-page-gallery')),
    );
    expect(find.byType(RoutexRoutePlanner), findsOneWidget);
    expect(find.byType(RoutexFloorSelector), findsOneWidget);

    await _openPage(
      tester,
      find.byKey(const ValueKey('showcase-page-components')),
    );
    expect(find.text('행동 · beta'), findsOneWidget);
    expect(find.text('목록과 묶음 · beta'), findsOneWidget);
    expect(find.text('입력과 필터 · beta'), findsOneWidget);
    expect(find.text('표면 · beta'), findsOneWidget);
    expect(find.text('장소와 안내 · beta'), findsOneWidget);
    expect(find.text('상태 · beta'), findsOneWidget);

    await _openPage(
      tester,
      find.byKey(const ValueKey('showcase-page-foundations')),
    );
    expect(find.text('시맨틱 색상'), findsOneWidget);
    expect(find.text('매장 분류'), findsOneWidget);
    expect(find.text(RoutexColorRole.actionPrimary.name), findsOneWidget);

    await _openPage(
      tester,
      find.byKey(const ValueKey('showcase-page-quality')),
    );
    expect(find.text('실패 기준'), findsOneWidget);
    expect(find.text('정렬과 리듬'), findsOneWidget);
    expect(find.text('모션 소유 경계'), findsOneWidget);
  });

  testWidgets('iPhone 목업의 제품 흐름과 저장 상태를 조작할 수 있다', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 1800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const RoutexShowcaseApp());
    await tester.pump(const Duration(milliseconds: 400));
    await _openPage(
      tester,
      find.byKey(const ValueKey('showcase-page-product')),
    );

    final phoneRect = tester.getRect(
      find.byKey(const ValueKey('iphone-mockup')),
    );
    expect(phoneRect.width / phoneRect.height, closeTo(390 / 844, 0.001));

    final home = find.byKey(const ValueKey('home-state'));
    expect(
      find.byType(InteractiveViewer),
      findsNothing,
      reason: '메인 단계는 단색 지도 canvas만 표시한다',
    );
    expect(find.byKey(const ValueKey('mockup-map-canvas')), findsNothing);
    expect(
      find.descendant(of: home, matching: find.byType(RoutexSearchBar)),
      findsOneWidget,
    );

    // 메인 화면은 지도가 주 화면이다. 하단 시트를 두지 않고 검색 한 줄, 지도 위
    // 카테고리 줄과 화면 아래 모서리의 지도 조작만 남긴다.
    expect(find.byKey(const ValueKey('home-state')), findsOneWidget);
    expect(
      find.descendant(of: home, matching: find.byType(RoutexBottomSheet)),
      findsNothing,
    );
    expect(
      find.descendant(of: home, matching: find.byType(RoutexPlaceHeader)),
      findsNothing,
    );
    final homeCategory = find.descendant(
      of: home,
      matching: find.byType(RoutexChipBar),
    );
    expect(homeCategory, findsOneWidget);
    expect(find.byTooltip('지도에서 내 위치 지정'), findsOneWidget);
    expect(find.byTooltip('위치 보정'), findsOneWidget);

    final foodCategory = find.descendant(of: home, matching: find.text('음식점'));
    await tester.tap(foodCategory);
    await tester.pump();
    expect(tester.widget<RoutexChipBar>(homeCategory).selectedId, '음식점');
    await tester.tap(foodCategory);
    await tester.pump();
    expect(
      tester.widget<RoutexChipBar>(homeCategory).selectedId,
      isNull,
      reason: '같은 분류를 다시 누르면 해제한다',
    );

    await tester.tap(find.byTooltip('지도에서 내 위치 지정'));
    await tester.pump();
    expect(find.text('지도를 눌러 현재 위치를 지정하세요'), findsOneWidget);
    await tester.tap(find.text('취소'));
    await tester.pump();

    // 검색은 상단 바가 입력 줄로 바뀌고 결과 패널이 그 아래에 붙는다.
    await tester.tap(find.text('더현대 서울에서 검색'));
    await tester.pump();
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('최근 검색어'), findsOneWidget);
    expect(
      find.descendant(of: home, matching: find.byType(RoutexChipBar)),
      findsNothing,
      reason: '검색 중에는 분류 줄을 접는다',
    );

    await tester.enterText(find.byType(TextField), '발렌시아가');
    await tester.pump();
    expect(find.byKey(const ValueKey('mockup-search-result')), findsOneWidget);
    expect(find.byTooltip('검색어 지우기'), findsOneWidget);

    await tester.tap(find.byTooltip('뒤로'));
    await tester.pump();
    expect(
      find.descendant(of: home, matching: find.byType(RoutexChipBar)),
      findsOneWidget,
    );

    // 메뉴 시트(pilot 1)는 handle·header·구획 라벨·목록 행을 전부 package로 만든다.
    await tester.tap(find.descendant(of: home, matching: find.byTooltip('메뉴')));
    await tester.pump();
    expect(
      find.descendant(of: home, matching: find.byType(RoutexSheetHeader)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: home, matching: find.text('메뉴')),
      findsOneWidget,
    );
    expect(find.text('개발자'), findsOneWidget);
    expect(find.textContaining('꺼짐 ·'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('mockup-menu-debug')));
    await tester.pump();
    expect(find.textContaining('사용 중 ·'), findsOneWidget);
    // 저장한 장소(pilot 2): trailing 메뉴와 순서 손잡이를 가진 목록 행.
    await tester.tap(find.byKey(const ValueKey('mockup-menu-favorites')));
    await tester.pump();
    expect(find.text('저장한 장소'), findsWidgets);
    expect(
      find.descendant(of: home, matching: find.byTooltip('발렌시아가 더보기')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: home,
        matching: find.byIcon(Icons.drag_handle_rounded),
      ),
      findsNWidgets(2),
    );
    await tester.tap(
      find.descendant(of: home, matching: find.byTooltip('이전으로')),
    );
    await tester.pump();

    await tester.tap(find.descendant(of: home, matching: find.byTooltip('메뉴')));
    await tester.pump();
    await tester.tap(find.descendant(of: home, matching: find.byTooltip('닫기')));
    await tester.pump();
    expect(
      find.descendant(of: home, matching: find.byType(RoutexSheetHeader)),
      findsNothing,
    );

    await tester.tap(find.byKey(const ValueKey('mockup-step-place')));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const ValueKey('place-state')), findsOneWidget);
    expect(find.byType(RoutexPlaceHeader), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsNothing);
    expect(find.byKey(const ValueKey('mockup-map-canvas')), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('장소 저장'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('저장됨'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('mockup-open-detail')));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const ValueKey('detail-state')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('detail-state')),
        matching: find.byType(RoutexInfoSection),
      ),
      findsNWidgets(3),
    );
    expect(find.text('영업시간'), findsOneWidget);
    expect(find.text('발렌시아가'), findsWidgets);

    await tester.tap(find.text('메뉴'));
    await tester.pump();
    expect(find.text('메뉴 정보 없음'), findsOneWidget);

    await tester.tap(find.text('사진'));
    await tester.pump();
    expect(find.text('사진 없음'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('mockup-step-route')));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const ValueKey('route-state')), findsOneWidget);
    expect(find.byType(RoutexRoutePlanner), findsOneWidget);
    expect(find.byType(RoutexTravelModeBar), findsOneWidget);
    expect(find.text('대중교통'), findsNothing);
    expect(find.byType(InteractiveViewer), findsNothing);
    expect(find.byKey(const ValueKey('mockup-map-canvas')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('mockup-step-guidance')));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const ValueKey('guidance-state')), findsOneWidget);
    expect(find.byType(RoutexManeuverBanner), findsOneWidget);
    expect(find.byType(RoutexTripProgress), findsOneWidget);

    final mapCanvas = find.byKey(const ValueKey('mockup-map-canvas'));
    expect(find.byType(InteractiveViewer), findsOneWidget);
    final mapOriginBeforeDrag = tester.getTopLeft(mapCanvas);
    await tester.drag(find.byType(InteractiveViewer), const Offset(28, -16));
    await tester.pump();
    expect(tester.getTopLeft(mapCanvas), isNot(mapOriginBeforeDrag));
    expect(find.byTooltip('지도 다시 따라가기'), findsOneWidget);
    await tester.tap(find.byTooltip('지도 다시 따라가기'));
    await tester.pump();
    expect(tester.getTopLeft(mapCanvas), mapOriginBeforeDrag);

    await tester.tap(find.byKey(const ValueKey('mockup-step-indoor')));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const ValueKey('indoor-state')), findsOneWidget);
    expect(find.byType(RoutexFloorSelector), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('mockup-step-arrival')));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const ValueKey('arrival-state')), findsOneWidget);
    expect(find.byType(RoutexStatusBanner), findsOneWidget);
  });

  for (final width in [360.0, 390.0]) {
    for (final textScale in [1.0, 1.3, 2.0]) {
      testWidgets('Showcase ${width.toInt()}px · $textScale×에서 섹션 경계가 일치한다', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 5000);
        tester.platformDispatcher.textScaleFactorTestValue = textScale;
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        await tester.pumpWidget(const RoutexShowcaseApp());
        await tester.pump();
        await _openPage(
          tester,
          find.byKey(const ValueKey('showcase-page-product')),
        );

        final phoneRect = tester.getRect(
          find.byKey(const ValueKey('iphone-mockup')),
        );
        final sourceRect = tester.getRect(
          find.byKey(const ValueKey('showcase-data-source-note')),
        );
        for (final (label, rect) in [
          ('phone', phoneRect),
          ('source note', sourceRect),
        ]) {
          expect(rect.left, greaterThanOrEqualTo(0), reason: '$label left');
          expect(rect.right, lessThanOrEqualTo(width), reason: '$label right');
        }
        expect(tester.takeException(), isNull);

        for (final step in const [
          'place',
          'detail',
          'route',
          'guidance',
          'indoor',
          'arrival',
        ]) {
          final stepChip = find.byKey(ValueKey('mockup-step-$step'));
          await tester.ensureVisible(stepChip);
          await tester.tap(stepChip);
          await tester.pump(const Duration(milliseconds: 400));
          final rect = tester.getRect(
            find.byKey(const ValueKey('iphone-mockup')),
          );
          expect(rect.left, greaterThanOrEqualTo(0), reason: '$step left');
          expect(rect.right, lessThanOrEqualTo(width), reason: '$step right');
          expect(tester.takeException(), isNull, reason: '$step render');
        }

        for (final page in const [
          (
            key: 'components',
            sections: [
              '행동 · beta',
              '목록과 묶음 · beta',
              '입력과 필터 · beta',
              '표면 · beta',
              '장소와 안내 · beta',
              '상태 · beta',
            ],
          ),
          (
            key: 'foundations',
            sections: [
              '시맨틱 색상',
              '지도 시각 토큰',
              '타이포그래피',
              '매장 분류',
              '간격 · 곡률 · 크기',
              '레이어 · 모션',
            ],
          ),
          (key: 'quality', sections: ['실패 기준', '정렬과 리듬', '모션 소유 경계']),
        ]) {
          await _openPage(
            tester,
            find.byKey(ValueKey('showcase-page-${page.key}')),
          );
          final rects = [
            for (final title in page.sections)
              tester.getRect(find.byKey(ValueKey('showcase-section-$title'))),
          ];
          for (final rect in rects.skip(1)) {
            expect(
              rect.left,
              rects.first.left,
              reason: '${page.key} left edge',
            );
            expect(
              rect.right,
              rects.first.right,
              reason: '${page.key} right edge',
            );
          }
        }
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final width in [360.0, 390.0]) {
    for (final textScale in [1.0, 1.3, 2.0]) {
      testWidgets('${width.toInt()}px · $textScale×에서 overflow가 없다', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 1800);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          MaterialApp(
            theme: RoutexTheme.light,
            home: Scaffold(
              body: SingleChildScrollView(
                child: AlignmentRhythmFixture(
                  width: width,
                  textScale: textScale,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('저장한 장소'), findsOneWidget);
        expect(find.text('지도에서 현재 위치 직접 지정'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}

/// 페이지 칩을 눌러 그 페이지를 연다.
///
/// `AnimatedSwitcher`는 나가는 페이지를 전환이 끝날 때까지 트리에 남겨 둔다. 한 번만
/// pump하면 그 프레임에서 전환이 **시작**하므로, 두 페이지가 겹친 채로 측정하게 된다.
/// 겹친 동안에는 같은 key가 둘이고 새 페이지의 좌표도 이전 페이지 높이만큼 밀린다.
///
/// `pumpAndSettle`을 쓰지 않는 이유는 자리표시(RoutexSkeleton)의 숨쉬는 애니메이션이
/// 끝나지 않기 때문이다. 전환 시간보다 넉넉한 프레임 몇 장만 흘린다.
Future<void> _openPage(WidgetTester tester, Finder chip) async {
  await tester.tap(chip);
  for (var frame = 0; frame < 3; frame++) {
    await tester.pump(const Duration(milliseconds: 400));
  }
}
