import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_design_system/routex_design_system.dart';
import 'package:showcase/src/pages/gallery_page.dart';

/// 열 폭은 제품 폭에 카드 여백을 더한 값이다. 갤러리 구현과 같은 값을 여기에
/// 적어 두어, 한쪽만 바뀌면 테스트가 먼저 걸리게 한다.
const _columnWidth = 390 + RoutexSpacing.componentPadding * 2;
const _gap = RoutexSpacing.contentGap;

/// 갤러리는 열을 창 폭에 맞춰 늘리지 않는다. 카드가 컴포넌트보다 넓어지면
/// 오른쪽이 통째로 비고, 좁으면 실제 화면과 다른 줄바꿈이 보인다.
///
/// 배치 계약은 배율이 걸리지 않은 `GalleryGrid`에서 잰다. `GalleryPage`는 좁은 창에서
/// 이 결과를 통째로 축소해 보여 줄 뿐이라, 두 가지를 한 test에서 재면 어느 쪽이
/// 어긋났는지 알 수 없다.
void main() {
  testWidgets('갤러리는 저장 피드백과 검색 중 스켈레톤을 한 번씩만 보여 준다', (tester) async {
    await _layoutGallery(tester, 1800);

    expect(find.text('장소를 저장했습니다.'), findsOneWidget);
    expect(find.text('장소에 저장했습니다'), findsNothing);
    expect(find.byType(RoutexSkeletonList), findsOneWidget);
  });

  testWidgets('카드 폭은 제품 폭을 넘지 않고 창이 넓어져도 늘어나지 않는다', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1600, 3000);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: RoutexTheme.light,
        home: const Scaffold(body: SingleChildScrollView(child: GalleryGrid())),
      ),
    );
    await tester.pump();

    final narrow = tester.getSize(find.byType(RoutexSearchBar)).width;
    expect(narrow, lessThanOrEqualTo(390));

    // 창을 두 배로 넓혀도 컴포넌트 폭은 그대로다. 열이 늘어나는 게 아니라 열 수가
    // 늘어야 한다.
    tester.view.physicalSize = const Size(3000, 3000);
    await tester.pump();
    expect(tester.getSize(find.byType(RoutexSearchBar)).width, narrow);
    expect(tester.takeException(), isNull);
  });

  // 배치 방식에 따라 열 높이 차가 이만큼 달라진다(2·3·4열 순).
  //   순서대로 돌려 담기      313 / 73 / 296
  //   작성 순서대로 낮은 열에   43 / 134 / 161
  //   큰 카드부터 낮은 열에     17 / 41 / 32
  // 가장 큰 카드(256)의 절반을 상한으로 잡으면 앞의 두 방식은 걸리고 지금 방식만
  // 통과한다. 카드를 더하다 이 선을 넘으면 눈으로 보기 전에 여기서 걸린다.
  for (final (width, columns) in const [(900.0, 2), (1300.0, 3), (1800.0, 4)]) {
    testWidgets('창 폭 ${width.toInt()}px에서 $columns열이 고르게 찬다', (tester) async {
      final cards = await _layoutGallery(tester, width);

      // 열은 정확히 열 폭 + 사이 여백 간격으로만 놓인다.
      final lefts = cards.map((rect) => rect.left).toSet().toList()..sort();
      expect(lefts, [
        for (var column = 0; column < columns; column++)
          column * (_columnWidth + _gap),
      ]);

      final columnBottoms = <double, double>{};
      for (final rect in cards) {
        final bottom = columnBottoms[rect.left];
        columnBottoms[rect.left] = bottom == null
            ? rect.bottom
            : (bottom > rect.bottom ? bottom : rect.bottom);
      }

      // 위아래로 붙은 카드 사이는 딱 한 칸이다. 열마다 다른 값이면 여기서 걸린다.
      for (final left in lefts) {
        final column = cards.where((rect) => rect.left == left).toList()
          ..sort((a, b) => a.top.compareTo(b.top));
        for (var index = 1; index < column.length; index++) {
          expect(column[index].top - column[index - 1].bottom, _gap);
        }
      }

      final heights = columnBottoms.values.toList()..sort();
      final imbalance = heights.last - heights.first;
      final tallestCard = cards
          .map((rect) => rect.height)
          .reduce((a, b) => a > b ? a : b);
      expect(imbalance, lessThanOrEqualTo(tallestCard / 2));
    });
  }

  // 열 수를 폭만 보고 정하면 여백 (n-1)칸을 빼먹어, 딱 맞아 보이던 열이 오른쪽으로
  // 삐져나온다. 2열이 정확히 들어가는 폭(856)의 바로 아래위에서 확인한다.
  for (final (width, columns) in const [
    (855.0, 1),
    (856.0, 2),
    (1289.0, 2),
    (1290.0, 3),
  ]) {
    testWidgets('$width에서 $columns열까지만 놓아 폭을 넘지 않는다', (tester) async {
      final cards = await _layoutGallery(tester, width);

      expect(cards.map((rect) => rect.left).toSet().length, columns);

      // 카드 자리는 갤러리 기준이라, 가장 오른쪽 끝이 곧 갤러리가 차지하는 폭이다.
      final usedWidth = cards.map((rect) => rect.right).reduce(math.max);
      expect(usedWidth, columns * (_columnWidth + _gap) - _gap);
      expect(usedWidth, lessThanOrEqualTo(width));
    });
  }

  // 세로 컨트롤은 폭이 열의 5분의 1도 안 된다. 이런 카드에 열을 통째로 주면
  // 오른쪽이 통째로 비어 격자가 무너진 것처럼 보인다. 좁은 카드끼리 한 칸을 나눠
  // 쓰는지, 즉 아래로 쌓이지 않고 옆으로 붙는지를 확인한다.
  testWidgets('좁은 카드는 아래로 쌓이지 않고 열 한 칸을 나눠 쓴다', (tester) async {
    await _layoutGallery(tester, 1300);

    final row = find.byKey(const ValueKey('gallery-narrow-row'));

    // 카드 안에도 DecoratedBox가 있으므로 위젯으로 찾으면 같은 카드의 속을 집는다.
    // 줄에 직접 담긴 것만 세야 한다.
    final cards = <Rect>[];
    tester.renderObject<RenderBox>(row).visitChildren((child) {
      final card = child as RenderBox;
      final parentData = card.parentData! as BoxParentData;
      cards.add(parentData.offset & card.size);
    });
    expect(
      cards.length,
      greaterThanOrEqualTo(2),
      reason: '한 칸을 나눠 쓸 카드가 있어야 한다',
    );

    final first = cards.first;
    final second = cards[1];

    expect(second.left, greaterThan(first.left), reason: '옆으로 붙어야 한다');
    expect(second.top, first.top, reason: '아래로 내려가면 안 된다');

    // 좁은 카드는 저마다 내용 폭까지 줄어든다. 열 폭을 그대로 쓰면 옆에 다른 카드가
    // 들어올 자리가 없다.
    expect(first.width, lessThan(_columnWidth / 2));

    // 나눠 써도 열 하나를 넘지 않는다.
    expect(tester.getSize(row).width, lessThanOrEqualTo(_columnWidth));
  });
}

/// 갤러리를 주어진 창 폭으로 그린 뒤, 카드가 놓인 자리를 그대로 돌려준다.
Future<List<Rect>> _layoutGallery(WidgetTester tester, double width) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 4000);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  await tester.pumpWidget(
    MaterialApp(
      theme: RoutexTheme.light,
      home: const Scaffold(body: SingleChildScrollView(child: GalleryGrid())),
    ),
  );
  await tester.pump();

  final masonry = tester.renderObject<RenderBox>(
    find.byKey(const ValueKey('gallery-masonry')),
  );
  final cards = <Rect>[];
  masonry.visitChildren((child) {
    final card = child as RenderBox;
    final parentData = card.parentData! as BoxParentData;
    cards.add(parentData.offset & card.size);
  });
  expect(cards, isNotEmpty);
  return cards;
}
