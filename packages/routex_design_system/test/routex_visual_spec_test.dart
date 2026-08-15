import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_design_system/routex_design_system.dart';

/// 시각 사양을 값으로 고정한다.
///
/// 지금까지 어긋난 것들은 전부 "동작은 맞는데 보이는 크기·곡률·정렬이 규칙과 다른"
/// 경우였다. 동작 test는 그런 어긋남을 잡지 못하므로, 화면에서 눈으로 확인하던
/// 것들을 여기서 수치로 검증한다.
void main() {
  Future<void> pump(WidgetTester tester, Widget child, {double scale = 1}) {
    return tester.pumpWidget(
      MaterialApp(
        theme: RoutexTheme.light,
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale)),
          child: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(width: 390, child: child),
            ),
          ),
        ),
      ),
    );
  }

  group('컨트롤의 시각 높이와 터치 영역', () {
    testWidgets('버튼·아이콘 동작·지도 버튼은 44로 보이고 48로 눌린다', (tester) async {
      await pump(
        tester,
        Row(
          children: [
            RoutexIconAction(
              label: '장소 저장',
              icon: RoutexIcons.save,
              onPressed: () {},
            ),
            RoutexMapControl(
              label: '현재 위치',
              icon: RoutexIcons.currentLocation,
              onPressed: () {},
            ),
            RoutexButton(label: '길찾기', onPressed: () {}),
          ],
        ),
      );

      // 보이는 표면은 44다. IconButton 위젯 자체는 padded tap target 때문에 48을
      // 차지하므로, 실제로 칠해지는 크기는 style의 fixedSize로 확인한다.
      expect(
        tester
            .widget<IconButton>(find.byType(IconButton).first)
            .style!
            .fixedSize!
            .resolve({}),
        const Size.square(RoutexMetrics.standardControl),
        reason: 'IconAction 시각 높이',
      );
      expect(
        tester.getSize(find.byType(RoutexSurface).first).height,
        RoutexMetrics.standardControl,
        reason: 'MapControl 시각 높이',
      );
      expect(
        tester
            .widget<TextButton>(find.byType(TextButton))
            .style!
            .minimumSize!
            .resolve({})!
            .height,
        RoutexMetrics.standardControl,
        reason: 'Button 시각 높이 (터치 영역은 padded로 48)',
      );

      // 눌리는 영역은 48이다.
      expect(
        tester.getSize(find.byType(RoutexIconAction)).height,
        greaterThanOrEqualTo(RoutexMetrics.minimumTouchTarget),
      );
      expect(
        tester.getSize(find.byType(RoutexMapControl)).height,
        RoutexMetrics.minimumTouchTarget,
      );
    });

    testWidgets('칩은 32로 보이고 48로 눌린다', (tester) async {
      await pump(
        tester,
        RoutexChipBar(
          options: const [RoutexChipOption(id: 'a', label: '패션')],
          selectedId: null,
          onSelected: (_) {},
        ),
      );

      expect(
        tester.getSize(find.byType(InkWell)).height,
        RoutexMetrics.compactControl,
      );
      expect(
        tester.getSize(find.byType(GestureDetector).first).height,
        RoutexMetrics.minimumTouchTarget,
      );
    });

    testWidgets('검색 바는 52 높이에서 leading column 폭의 아이콘 자리를 쓴다', (tester) async {
      await pump(
        tester,
        RoutexSearchBar(
          placeholder: '건물, 장소를 검색하세요',
          onSearchPressed: () {},
          leading: RoutexSearchLeading.menu,
          onLeadingPressed: () {},
          onDirectionsPressed: () {},
        ),
      );

      expect(
        tester.getSize(find.byType(RoutexSearchBar)).height,
        RoutexMetrics.searchField,
      );
      final actions = find.byType(IconButton);
      expect(actions, findsNWidgets(2), reason: '메뉴와 길찾기');
      for (var index = 0; index < 2; index++) {
        expect(
          tester.getSize(actions.at(index)).height,
          RoutexMetrics.leadingColumn,
          reason: '검색 바 아이콘 자리는 입력 텍스트와 붙어 한 줄로 읽혀야 한다',
        );
      }
    });
  });

  group('정렬', () {
    testWidgets('목록 셀의 leading·trailing 아이콘은 제목 첫 줄 중심에 선다', (tester) async {
      await pump(
        tester,
        RoutexListCell(
          title: '더현대 서울',
          subtitle: '1F · 패션 · 두 줄이 되어도 아이콘은 첫 줄을 기준으로 선다',
          leadingIcon: RoutexIcons.place,
          trailingIcon: RoutexIcons.forward,
          onPressed: () {},
        ),
      );

      final title = tester.getRect(find.text('더현대 서울'));
      final leading = tester.getRect(find.byIcon(RoutexIcons.place));
      final trailing = tester.getRect(find.byIcon(RoutexIcons.forward));

      // line box는 글자 위아래로 여유가 있어, 중앙에 맞추면 아이콘이 떠 보인다.
      // 글리프 윗면을 기준으로 세운다.
      expect(
        leading.top,
        moreOrLessEquals(title.top + 4, epsilon: 2),
        reason: 'leading 아이콘 윗면이 제목 글리프 윗면과 맞아야 한다',
      );
      expect(
        trailing.top,
        moreOrLessEquals(leading.top, epsilon: 1),
        reason: 'trailing 아이콘도 같은 기준선을 쓴다',
      );
    });

    testWidgets('목록 행은 선택 배경 안에서 좌우 여백이 대칭이다', (tester) async {
      await pump(
        tester,
        const RoutexListCell(
          title: '선택한 장소',
          subtitle: '배경이 행 전체를 덮어도 텍스트는 가운데 열을 지킨다',
          trailingIcon: RoutexIcons.forward,
          selected: true,
        ),
      );

      final row = tester.getRect(find.byType(RoutexListCell));
      final title = tester.getRect(find.text('선택한 장소'));
      final trailing = tester.getRect(find.byIcon(RoutexIcons.forward));

      expect(
        title.left - row.left,
        greaterThanOrEqualTo(RoutexSpacing.contentGap),
        reason: '배경 왼쪽 끝에 텍스트가 붙지 않는다',
      );
      expect(
        row.right - trailing.right,
        moreOrLessEquals(RoutexSpacing.contentGap, epsilon: .5),
        reason: '오른쪽 여백도 같은 값을 쓴다',
      );
    });

    testWidgets('이동수단 세그먼트는 칸을 균등하게 나눈다', (tester) async {
      await pump(
        tester,
        RoutexTravelModeBar(
          options: const [
            RoutexTravelModeOption(
              id: 'car',
              label: '자동차',
              icon: RoutexIcons.car,
            ),
            RoutexTravelModeOption(
              id: 'transit',
              label: '대중교통',
              icon: RoutexIcons.transit,
            ),
            RoutexTravelModeOption(
              id: 'walk',
              label: '도보',
              icon: RoutexIcons.walk,
            ),
          ],
          selectedId: 'walk',
          onSelected: (_) {},
        ),
      );

      final hitTargets = find.byType(GestureDetector);
      final widths = <double>[
        for (var index = 0; index < 3; index++)
          tester.getSize(hitTargets.at(index)).width,
      ];
      expect(
        widths.toSet().length,
        1,
        reason: '라벨 길이가 달라도 칸 폭은 같다. 값: $widths',
      );
      expect(
        tester.getSize(hitTargets.first).height,
        RoutexMetrics.minimumTouchTarget,
        reason: '투명한 여백을 포함한 터치 영역은 48dp다',
      );
      expect(
        tester.getSize(find.byType(RoutexFocusRing).first).height,
        RoutexMetrics.compactControl,
        reason: '선택·hover·focus가 칠해지는 시각 영역은 32dp다',
      );
    });
  });

  group('곡률과 표면', () {
    testWidgets('인라인 알림의 액션은 표면과 같은 곡률 계열을 쓴다', (tester) async {
      await pump(
        tester,
        RoutexInlineNotice(
          message: '장소를 저장했습니다.',
          actionLabel: '실행 취소',
          onAction: () {},
        ),
      );

      final shape = tester
          .widget<TextButton>(find.byType(TextButton))
          .style!
          .shape!
          .resolve({})!;
      expect(
        shape,
        isA<RoundedRectangleBorder>().having(
          (border) => border.borderRadius,
          'borderRadius',
          RoutexRadii.control,
        ),
        reason: '액션만 알약이 되면 알림이 두 표면으로 읽힌다',
      );
    });

    testWidgets('행·헤더 안의 아이콘 동작은 배경을 갖지 않는다', (tester) async {
      await pump(
        tester,
        RoutexListCell(
          title: '발렌시아가',
          trailingActionLabel: '더보기',
          onTrailingAction: () {},
          reorderable: true,
          onPressed: () {},
        ),
      );

      final action = tester.widget<IconButton>(find.byType(IconButton));
      expect(
        action.style!.backgroundColor!.resolve({}),
        Colors.transparent,
        reason: '한 줄 안에서 하나만 타일을 가지면 다른 컨트롤로 읽힌다',
      );
      // 크기를 값으로 못박으면 옆 컨트롤이 터치 영역만큼 커졌을 때 어긋남을
      // 놓친다. 두 글리프가 같은 줄에 놓였다는 사실 자체를 검증한다.
      expect(
        tester.getCenter(find.byIcon(RoutexIcons.reorder)).dy,
        tester.getCenter(find.byIcon(RoutexIcons.more)).dy,
        reason: '손잡이와 보조 동작의 글리프는 같은 높이에 놓인다',
      );
      expect(
        tester.widget<Icon>(find.byIcon(RoutexIcons.reorder)).color,
        RoutexColorTokens.light.borderStrong,
        reason: '손잡이는 장식이라 보조 동작보다 연하게 둔다',
      );
    });

    testWidgets('시트 머리글 제목은 행 제목과 같은 열에서 시작한다', (tester) async {
      await pump(
        tester,
        Column(
          children: [
            RoutexSheetHeader(title: '검색 결과', onBack: () {}, onClose: () {}),
            const RoutexListCell(
              title: '더현대 서울',
              leadingIcon: RoutexIcons.place,
              trailingIcon: RoutexIcons.forward,
            ),
          ],
        ),
      );

      expect(
        tester.getTopLeft(find.text('검색 결과')).dx,
        tester.getTopLeft(find.text('더현대 서울')).dx,
        reason: '머리글이 행의 leading column을 모르면 제목 열이 어긋난다',
      );
    });

    testWidgets('구획 머리글의 제목과 액션은 같은 여백을 남긴다', (tester) async {
      await pump(
        tester,
        RoutexSectionHeader(
          title: '저장한 장소',
          actionLabel: '편집',
          onAction: () {},
        ),
      );

      const width = 390.0;
      expect(
        width - tester.getTopRight(find.text('편집')).dx,
        tester.getTopLeft(find.text('저장한 장소')).dx,
        reason: '터치 여백이 정렬선 안으로 들어오면 좌우 여백이 달라진다',
      );
    });

    testWidgets('표면은 네 역할 모두 렌더링된다', (tester) async {
      for (final role in RoutexSurfaceRole.values) {
        await pump(
          tester,
          RoutexSurface(
            role: role,
            child: const SizedBox.square(dimension: 40),
          ),
        );
        expect(tester.takeException(), isNull, reason: role.name);
      }
    });

    testWidgets('시트는 handle 유무에 따라 위쪽 여백을 바꾼다', (tester) async {
      await pump(tester, const RoutexBottomSheet(child: SizedBox(height: 40)));
      final withHandle = tester.getRect(find.byType(SizedBox).last).top;

      await pump(
        tester,
        const RoutexBottomSheet(showHandle: false, child: SizedBox(height: 40)),
      );
      final withoutHandle = tester.getRect(find.byType(SizedBox).last).top;

      expect(
        withoutHandle,
        RoutexSpacing.componentPadding,
        reason: 'handle이 없으면 컴포넌트 여백을 쓴다',
      );
      expect(
        withHandle,
        greaterThan(withoutHandle),
        reason: 'handle이 있으면 handle 자체가 위쪽 여백을 만든다',
      );
    });
  });

  group('상태 표현', () {
    // 선택을 진한 파랑 채움으로 그리면 지도 위 한 줄이 통째로 무거워진다. 옅은
    // 배경 + 하늘색 테두리 + 진한 파랑 글자 세 가지가 함께 있어야 선택으로 읽힌다.
    // 셋 중 하나라도 빠지면 약해지므로 세 값을 다 고정한다.
    testWidgets('선택된 칩은 채움이 아니라 tint와 하늘색 테두리로 표시한다', (tester) async {
      await pump(
        tester,
        RoutexChipBar(
          semanticsLabel: '분류',
          options: const [
            RoutexChipOption(id: '음식점', label: '음식점'),
            RoutexChipOption(id: '패션', label: '패션'),
          ],
          selectedId: '음식점',
          onSelected: (_) {},
        ),
      );

      const tokens = RoutexColorTokens.light;
      final surface = tester
          .widgetList<Material>(
            find.ancestor(
              of: find.text('음식점'),
              matching: find.byType(Material),
            ),
          )
          .first;
      expect(
        surface.color,
        tokens.actionPrimarySubtle,
        reason: '선택을 actionPrimary로 채우면 지도 위가 무거워진다',
      );

      final border =
          tester
                  .widgetList<Container>(
                    find.ancestor(
                      of: find.text('음식점'),
                      matching: find.byType(Container),
                    ),
                  )
                  .first
                  .decoration!
              as BoxDecoration;
      expect(
        border.border!.top.color,
        tokens.accentBrand,
        reason: '선택을 전하는 것은 이 테두리다',
      );

      expect(
        tester.widget<Text>(find.text('음식점')).style!.color,
        tokens.actionPrimary,
        reason: '글자는 accentBrand로는 대비가 모자라 actionPrimary를 쓴다',
      );
    });

    // 분류 칩은 한 칩 안에서 색을 두 갈래로 쓴다. 아이콘은 도면과 같은 파스텔 원색,
    // 선택을 전하는 테두리·글자는 대비를 확보한 ink다. 둘을 같은 색으로 통일하면
    // 한쪽이 반드시 망가진다. 원색으로 통일하면 선택이 안 보이고(2.46), ink로
    // 통일하면 분류 줄이 도면과 색감이 갈라진다.
    testWidgets('분류 칩은 아이콘에 원색, 테두리·글자에 ink를 쓴다', (tester) async {
      await pump(
        tester,
        RoutexChipBar(
          semanticsLabel: '분류',
          options: [RoutexChipOption.category('음식점')],
          selectedId: '음식점',
          onSelected: (_) {},
        ),
      );

      expect(
        tester.widget<Icon>(find.byType(Icon)).color,
        RoutexCategoryTokens.colorFor('음식점'),
        reason: '아이콘까지 톤을 낮추면 분류 줄이 도면과 색감이 갈라진다',
      );

      final ink = RoutexCategoryTokens.inkFor('음식점');
      expect(
        tester.widget<Text>(find.text('음식점')).style!.color,
        ink,
        reason: '글자는 원색으로 두면 흰 배경에서 2.46이라 읽히지 않는다',
      );

      final decoration =
          tester
                  .widgetList<Container>(
                    find.ancestor(
                      of: find.text('음식점'),
                      matching: find.byType(Container),
                    ),
                  )
                  .first
                  .decoration!
              as BoxDecoration;
      expect(
        decoration.border!.top.color,
        ink,
        reason: '선택을 전하는 테두리는 원색으로 두면 보이지 않는다',
      );
    });

    testWidgets('focus는 링, hover는 tint로 서로 다른 언어를 쓴다', (tester) async {
      await pump(tester, RoutexListCell(title: '저장한 장소', onPressed: () {}));
      final cell = tester.widget<InkWell>(find.byType(InkWell));

      expect(
        cell.focusColor,
        Colors.transparent,
        reason: 'focus를 채움으로 그리면 selected와 구분되지 않는다',
      );
      expect(cell.hoverColor, RoutexColorTokens.light.actionPrimarySubtle);
      expect(find.byType(RoutexFocusRing), findsOneWidget);
    });

    testWidgets('키보드 focus를 받으면 focusRing 색 링이 생긴다', (tester) async {
      await pump(tester, RoutexListCell(title: '저장한 장소', onPressed: () {}));

      BoxDecoration ringDecoration() =>
          tester
                  .widgetList<DecoratedBox>(
                    find.descendant(
                      of: find.byType(RoutexFocusRing),
                      matching: find.byType(DecoratedBox),
                    ),
                  )
                  .first
                  .decoration
              as BoxDecoration;

      expect(ringDecoration().border, isNull, reason: '평소에는 링이 없다');

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      final border = ringDecoration().border;
      expect(border, isNotNull, reason: 'focus를 받으면 링이 생긴다');
      expect(
        border!.top.color,
        RoutexColorTokens.light.focusRing,
        reason: 'focus 링은 focusRing 토큰을 쓴다',
      );
      expect(border.top.width, RoutexFocusRing.width);
    });

    testWidgets('누를 수 없는 행에는 링을 그리지 않는다', (tester) async {
      await pump(
        tester,
        const RoutexListCell(title: '현재 사용할 수 없는 장소', enabled: false),
      );

      expect(
        tester.widget<RoutexFocusRing>(find.byType(RoutexFocusRing)).enabled,
        isFalse,
      );
    });
  });

  group('분류 토큰', () {
    test('분류마다 고유색과 아이콘이 있고 모르는 값은 일반 매장으로 떨어진다', () {
      expect(RoutexCategoryTokens.categories, isNotEmpty);
      for (final category in RoutexCategoryTokens.categories) {
        expect(
          RoutexCategoryTokens.colorFor(category),
          isNot(RoutexCategoryTokens.fallbackColor),
          reason: category,
        );
      }
      expect(
        RoutexCategoryTokens.colorFor('없는 분류'),
        RoutexCategoryTokens.fallbackColor,
      );
      expect(
        RoutexCategoryTokens.iconFor('없는 분류'),
        RoutexCategoryTokens.fallbackIcon,
      );
    });

    test('바뀐 어휘도 예전 이름과 같은 값을 유지한다', () {
      expect(
        RoutexCategoryTokens.colorFor('식음료'),
        RoutexCategoryTokens.colorFor('음식점'),
        reason: '저장된 데이터가 조용히 회색으로 떨어지면 안 된다',
      );
    });
  });
}
