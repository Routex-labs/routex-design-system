import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_design_system/routex_design_system.dart';
import 'package:showcase/src/app/showcase_app.dart';
import 'package:showcase/src/catalog/mobile_frame.dart';
import 'package:showcase/src/fixtures/alignment_rhythm_fixture.dart';

void main() {
  testWidgets('검색에 붙는 목록 틀은 상단 inset만 control gap으로 낮춘다', (tester) async {
    const childKey = ValueKey('search-attached-child');
    await tester.pumpWidget(
      MaterialApp(
        theme: RoutexTheme.light,
        home: const Scaffold(
          body: MobileFrame(
            surface: MobileFrameSurface.sheet,
            contentInset: MobileFrameContentInset.searchAttached,
            child: SizedBox(key: childKey, height: 40, width: double.infinity),
          ),
        ),
      ),
    );

    final frame = tester.getRect(find.byType(DecoratedBox));
    final child = tester.getRect(find.byKey(childKey));
    expect(child.top - frame.top, RoutexSpacing.controlGap);
    expect(frame.bottom - child.bottom, RoutexSpacing.screenGutter);
  });

  testWidgets('Runtime Kit의 catalog와 실제 버튼을 렌더링한다', (tester) async {
    await tester.pumpWidget(const RoutexShowcaseApp());

    expect(find.text('Routex Design System'), findsOneWidget);
    expect(find.byType(RoutexRoutePlanner), findsOneWidget);

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
