import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_design_system/routex_design_system.dart';
import 'package:showcase/src/mockup/mobile_ux_showcase.dart';

/// 목업 화면의 배치 계약을 값으로 고정한다.
///
/// 컴포넌트 하나하나는 package test가 지키고, golden은 전체 모습이 바뀌었는지만
/// 알려준다. 그 사이에 있는 것 — 오버레이 사이의 gutter와 간격, 시트 기준 순서 —
/// 이 여기서 검증된다. 눈으로 보고 "뭔가 안 맞는다"고 느끼던 것들이다.
void main() {
  const phoneWidth = 390.0;
  const gutter = RoutexSpacing.screenGutter;

  Future<void> pumpMockup(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 1800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: RoutexTheme.light,
        home: const Scaffold(
          body: SingleChildScrollView(child: MobileUxShowcase()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// 기기 화면 안에서의 좌표로 바꾼다.
  Rect inPhone(WidgetTester tester, Finder finder) {
    final phone = tester.getRect(find.byKey(const ValueKey('iphone-mockup')));
    final rect = tester.getRect(finder);
    return rect.translate(-phone.left, -phone.top);
  }

  /// 화면 전환은 AnimatedSwitcher를 쓴다. 나가는 화면이 남아 있는 동안 좌표를
  /// 재면 두 화면이 섞이므로, 전환이 끝날 때까지 진행시킨 뒤 잰다.
  Future<void> goTo(WidgetTester tester, String step) async {
    final stepChip = find.byKey(ValueKey('mockup-step-$step'));
    await tester.ensureVisible(stepChip);
    await tester.tap(stepChip);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));
  }

  /// 지금 떠 있는 화면 안에서만 찾는다.
  Finder inState(String step, Finder finder) => find.descendant(
    of: find.byKey(ValueKey('$step-state')),
    matching: finder,
  );

  testWidgets('상단 표면과 지도 컨트롤이 같은 gutter를 쓴다', (tester) async {
    await pumpMockup(tester);

    final search = inPhone(
      tester,
      inState('home', find.byType(RoutexSearchBar)),
    );
    final control = inPhone(
      tester,
      inState('home', find.byType(RoutexMapControl)).last,
    );

    expect(search.left, moreOrLessEquals(gutter, epsilon: .5));
    expect(search.right, moreOrLessEquals(phoneWidth - gutter, epsilon: .5));
    expect(
      control.right,
      moreOrLessEquals(phoneWidth - gutter, epsilon: .5),
      reason: '지도 컨트롤이 상단 표면과 다른 끝선을 쓰면 화면이 어긋나 보인다',
    );
  });

  testWidgets('필터 줄의 시각 간격은 칩 터치 여백을 포함해 contentGap이 된다', (tester) async {
    await pumpMockup(tester);

    final search = inPhone(
      tester,
      inState('home', find.byType(RoutexSearchBar)),
    );
    final chips = inPhone(tester, inState('home', find.byType(RoutexChipBar)));

    expect(chips.left, moreOrLessEquals(gutter, epsilon: .5));
    // 칩 줄은 터치 영역(48) 안에 시각 여백 8을 이미 갖는다. 레이아웃 간격 4를
    // 더하면 눈에 보이는 간격이 contentGap 12가 된다.
    expect(
      chips.top - search.bottom,
      moreOrLessEquals(RoutexSpacing.inlineGap, epsilon: .5),
    );
  });

  testWidgets('시트는 화면 아래에 붙고 컨트롤은 그 위에 쌓인다', (tester) async {
    await pumpMockup(tester);
    await goTo(tester, 'guidance');

    final phone = tester.getRect(find.byKey(const ValueKey('iphone-mockup')));
    final sheet = inPhone(
      tester,
      inState('guidance', find.byType(RoutexTripProgress)),
    );
    final controls = inPhone(
      tester,
      inState('guidance', find.byType(RoutexMapControl)).first,
    );

    expect(
      sheet.bottom,
      moreOrLessEquals(phone.height, epsilon: .5),
      reason: '하단 표면은 화면 아래에 붙는다',
    );
    expect(sheet.left, 0, reason: '하단 표면은 gutter 없이 화면 폭을 채운다');
    expect(
      controls.bottom,
      lessThanOrEqualTo(sheet.top - RoutexSpacing.contentGap + .5),
      reason: '컨트롤은 시트에 가려지지 않고 그 위에 쌓인다',
    );
  });

  testWidgets('상단 배너는 기기 안전 영역을 기준으로 놓인다', (tester) async {
    await pumpMockup(tester);
    await goTo(tester, 'guidance');

    final banner = inPhone(
      tester,
      inState('guidance', find.byType(RoutexManeuverBanner)),
    );

    // 기기 상태바 42 + controlGap 8.
    expect(
      banner.top,
      moreOrLessEquals(42 + RoutexSpacing.controlGap, epsilon: .5),
      reason: '상단 표면이 상태바와 겹치거나 좌표로 고정되면 기기가 바뀔 때 깨진다',
    );
    expect(banner.left, moreOrLessEquals(gutter, epsilon: .5));
  });

  testWidgets('모든 단계가 같은 상단 gutter를 유지한다', (tester) async {
    await pumpMockup(tester);

    for (final step in const [
      'place',
      'route',
      'guidance',
      'indoor',
      'arrival',
    ]) {
      await goTo(tester, step);
      final top = inState(
        step,
        find.byWidgetPredicate(
          (widget) =>
              widget is RoutexSearchBar ||
              widget is RoutexRoutePlanner ||
              widget is RoutexManeuverBanner ||
              widget is RoutexStatusBanner,
        ),
      );
      expect(top, findsOneWidget, reason: '$step 단계의 상단 표면');
      expect(
        inPhone(tester, top).left,
        moreOrLessEquals(gutter, epsilon: .5),
        reason: '$step 단계에서 상단 표면 시작선이 달라졌다',
      );
    }
  });

  testWidgets('시트가 있는 단계는 모두 화면 아래에 붙인다', (tester) async {
    await pumpMockup(tester);
    final phone = tester.getRect(find.byKey(const ValueKey('iphone-mockup')));

    for (final step in const ['place', 'route', 'arrival']) {
      await goTo(tester, step);
      expect(
        inPhone(tester, inState(step, find.byType(RoutexBottomSheet))).bottom,
        moreOrLessEquals(phone.height, epsilon: .5),
        reason: '$step 단계의 하단 표면',
      );
    }
  });
}
