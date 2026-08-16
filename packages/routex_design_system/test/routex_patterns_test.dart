import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_design_system/routex_design_system.dart';

void main() {
  testWidgets('IconAction과 MapControl은 48dp와 접근성 상태를 함께 유지한다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: RoutexTheme.light,
        home: Scaffold(
          body: Row(
            children: [
              RoutexIconAction(
                label: '장소 저장',
                icon: Icons.bookmark_border_rounded,
                onPressed: () {},
              ),
              RoutexMapControl(
                label: '현재 위치 추적 중',
                icon: Icons.navigation_rounded,
                selected: true,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(RoutexIconAction)),
      const Size.square(RoutexMetrics.minimumTouchTarget),
    );
    expect(
      tester.getSize(find.byType(RoutexMapControl)),
      const Size.square(RoutexMetrics.minimumTouchTarget),
    );
    expect(find.byTooltip('장소 저장'), findsOneWidget);
    expect(find.byTooltip('현재 위치 추적 중'), findsOneWidget);
    expect(
      tester.getSemantics(find.byType(RoutexMapControl)),
      matchesSemantics(
        label: '현재 위치 추적 중',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasSelectedState: true,
        isSelected: true,
      ),
    );
  });

  testWidgets('장소·경로·안내 패턴은 상태와 callback을 분리하지 않는다', (tester) async {
    var saved = false;
    var expanded = false;
    var stopped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: RoutexTheme.light,
        home: Scaffold(
          body: Column(
            children: [
              RoutexPlaceHeader(
                name: '발렌시아가',
                metadata: '1F · 패션 · 명품',
                saved: saved,
                onSaved: (value) => saved = value,
                onToggleExpanded: () => expanded = true,
              ),
              RoutexRouteOption(
                title: '7분',
                detail: '460m · 엘리베이터 우선',
                meta: '+1분',
                selected: false,
                onPressed: null,
              ),
              RoutexTripProgress(
                metrics: const [RoutexTripMetric(value: '6분', label: '남은 시간')],
                onStop: () => stopped = true,
              ),
              const RoutexManeuverBanner(
                distance: '120m 후 건물로 진입',
                detail: '명품관 방향',
                icon: Icons.turn_right_rounded,
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('장소 저장'));
    await tester.tap(find.byTooltip('상세 열기'));
    await tester.tap(find.text('안내 종료'));
    await tester.pump();

    expect(saved, isTrue);
    expect(expanded, isTrue);
    expect(stopped, isTrue);
    expect(
      tester.getSemantics(find.byType(RoutexRouteOption)),
      matchesSemantics(
        label: '7분, 460m · 엘리베이터 우선, +1분',
        isButton: true,
        hasEnabledState: true,
        isEnabled: false,
        hasSelectedState: true,
        isSelected: false,
      ),
    );
    expect(
      tester.getSemantics(find.byType(RoutexManeuverBanner)),
      matchesSemantics(label: '120m 후 건물로 진입, 명품관 방향'),
    );
  });

  testWidgets('장소 공유는 헤더에 있고 길찾기 행동과 분리된다', (tester) async {
    var shared = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: RoutexTheme.light,
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            body: SizedBox(
              width: 360,
              child: RoutexPlaceHeader(
                name: '오설록',
                metadata: 'B1 · 식음료 · 카페',
                saved: false,
                onShare: () => shared = true,
                onSaved: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('장소 공유'));
    expect(shared, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('이동수단은 지원 항목만 한 줄로 표시하고 하나뿐이면 숨긴다', (tester) async {
    var selected = 'walk';
    const options = [
      RoutexTravelModeOption(
        id: 'car',
        label: '자동차',
        icon: Icons.directions_car_rounded,
      ),
      RoutexTravelModeOption(
        id: 'transit',
        label: '대중교통',
        icon: Icons.directions_bus_rounded,
      ),
      RoutexTravelModeOption(
        id: 'walk',
        label: '도보',
        icon: Icons.directions_walk_rounded,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: RoutexTheme.light,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => RoutexTravelModeBar(
              options: options,
              selectedId: selected,
              onSelected: (value) => setState(() => selected = value),
            ),
          ),
        ),
      ),
    );

    final tops = [
      for (final label in ['자동차', '대중교통', '도보'])
        tester.getTopLeft(find.text(label)).dy,
    ];
    expect(tops.toSet(), hasLength(1));
    await tester.tap(find.text('대중교통'));
    await tester.pump();
    expect(selected, 'transit');

    await tester.pumpWidget(
      MaterialApp(
        theme: RoutexTheme.light,
        home: Scaffold(
          body: RoutexTravelModeBar(
            options: const [
              RoutexTravelModeOption(
                id: 'walk',
                label: '도보',
                icon: Icons.directions_walk_rounded,
              ),
            ],
            selectedId: 'walk',
            onSelected: (_) {},
          ),
        ),
      ),
    );
    expect(find.text('도보'), findsNothing);
  });

  testWidgets('검색 바의 왼쪽 자리는 항상 채우고 길찾기만 조건부로 둔다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: RoutexTheme.light,
        home: Scaffold(
          body: RoutexSearchBar(
            placeholder: '건물, 장소를 검색하세요',
            onSearchPressed: () {},
            leading: RoutexSearchLeading.back,
            onLeadingPressed: () {},
          ),
        ),
      ),
    );

    expect(find.byTooltip('뒤로'), findsOneWidget, reason: '왼쪽 자리는 비지 않는다');
    expect(find.byTooltip('길찾기'), findsNothing);

    await tester.pumpWidget(
      MaterialApp(
        theme: RoutexTheme.light,
        home: Scaffold(
          body: RoutexSearchBar(
            placeholder: '건물, 장소를 검색하세요',
            onSearchPressed: () {},
            leading: RoutexSearchLeading.menu,
            onLeadingPressed: () {},
            onDirectionsPressed: () {},
          ),
        ),
      ),
    );

    expect(find.byTooltip('메뉴'), findsOneWidget);
    expect(find.byTooltip('길찾기'), findsOneWidget);
  });

  testWidgets('검색 바는 입력·지우기·진행 상태를 같은 줄에서 처리한다', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    var submitted = '';
    var cleared = false;

    Future<void> pump({required bool loading}) => tester.pumpWidget(
      MaterialApp(
        theme: RoutexTheme.light,
        home: Scaffold(
          body: RoutexSearchBar(
            placeholder: '건물, 장소를 검색하세요',
            onSearchPressed: null,
            leading: RoutexSearchLeading.back,
            onLeadingPressed: () {},
            controller: controller,
            isLoading: loading,
            onSubmitted: (value) => submitted = value,
            onClear: () {
              controller.clear();
              cleared = true;
            },
          ),
        ),
      ),
    );

    await pump(loading: false);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byTooltip('검색어 지우기'), findsNothing, reason: '빈 입력에는 지우기가 없다');

    await tester.enterText(find.byType(TextField), '발렌시아가');
    await tester.pump();
    expect(find.byTooltip('검색어 지우기'), findsOneWidget);

    await tester.testTextInput.receiveAction(TextInputAction.search);
    expect(submitted, '발렌시아가');

    await pump(loading: true);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      find.byTooltip('검색어 지우기'),
      findsNothing,
      reason: '진행 표시와 지우기는 같은 자리를 쓰므로 동시에 나오지 않는다',
    );

    await pump(loading: false);
    await tester.tap(find.byTooltip('검색어 지우기'));
    await tester.pump();
    expect(cleared, isTrue);
    expect(controller.text, isEmpty);
  });

  group('RoutexPlaceActions', () {
    testWidgets('한 쌍 안에서 primary는 도착 하나뿐이다', (tester) async {
      var origin = false;
      var destination = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: RoutexTheme.light,
          home: Scaffold(
            body: RoutexPlaceActions(
              onOrigin: () => origin = true,
              onDestination: () => destination = true,
            ),
          ),
        ),
      );

      final variants = tester
          .widgetList<RoutexButton>(find.byType(RoutexButton))
          .map((button) => button.variant)
          .toList();
      expect(
        variants.where((v) => v == RoutexButtonVariant.primary).length,
        1,
        reason: '같은 위계의 주 행동이 둘이면 무엇을 누를지가 사라진다',
      );

      await tester.tap(find.text('출발'));
      await tester.tap(find.text('도착'));
      expect(origin, isTrue);
      expect(destination, isTrue);
    });
  });

  group('RoutexHours', () {
    Widget hours({
      required RoutexHoursState state,
      required bool expanded,
      String? detail,
      String? staleNote,
    }) => MaterialApp(
      theme: RoutexTheme.light,
      home: Scaffold(
        body: RoutexHours(
          state: state,
          detail: detail,
          staleNote: staleNote,
          expanded: expanded,
          onExpanded: (_) {},
          days: const [
            RoutexHoursDay(label: '화', value: '10:30 - 20:00'),
            RoutexHoursDay(label: '수', value: '휴무', closed: true),
          ],
        ),
      ),
    );

    testWidgets('접혀 있어도 오늘 줄은 남고 나머지 요일은 숨는다', (tester) async {
      await tester.pumpWidget(
        hours(
          state: RoutexHoursState.open,
          expanded: false,
          detail: '20:00 종료',
        ),
      );

      expect(find.text('화 · 10:30 - 20:00'), findsOneWidget);
      expect(find.text('수 · 휴무'), findsNothing);

      await tester.pumpWidget(
        hours(state: RoutexHoursState.open, expanded: true, detail: '20:00 종료'),
      );
      await tester.pumpAndSettle();
      expect(find.text('수 · 휴무'), findsOneWidget);
    });

    testWidgets('판정할 수 없으면 닫힘으로 떨어뜨리지 않는다', (tester) async {
      await tester.pumpWidget(
        hours(state: RoutexHoursState.unknown, expanded: false),
      );

      expect(find.text('영업 종료'), findsNothing);
      expect(find.text('영업시간 정보가 오래됐어요'), findsOneWidget);
    });

    // 머리 줄의 "오래됐어요"는 주장이고 확인일은 그 근거다. 주장만 보이고 근거는
    // 펼쳐야 나오면, 읽는 사람은 무엇을 보고 판단할지 알 수 없다.
    testWidgets('접혀 있어도 오래됐다는 근거는 남는다', (tester) async {
      const note = '2026-01-01 기준 · 영업시간이 달라졌을 수 있어요';

      await tester.pumpWidget(
        hours(
          state: RoutexHoursState.unknown,
          expanded: false,
          staleNote: note,
        ),
      );

      expect(find.text(note), findsOneWidget);
      // 근거만 남기고 나머지 요일은 그대로 접혀 있다.
      expect(find.text('수 · 휴무'), findsNothing);
    });

    testWidgets('오래되지 않았으면 근거 줄 자리를 만들지 않는다', (tester) async {
      await tester.pumpWidget(
        hours(
          state: RoutexHoursState.open,
          expanded: false,
          detail: '20:00 종료',
        ),
      );

      expect(find.textContaining('기준'), findsNothing);
    });
  });

  group('RoutexMenuList', () {
    const entries = [
      RoutexMenuEntry(name: '아이스 아메리카노', price: '4,500원'),
      RoutexMenuEntry(name: '카페 라떼', price: '5,000원'),
      RoutexMenuEntry(name: '콜드브루', selectable: false),
    ];

    testWidgets('접힌 목록은 나머지 개수를 밝히고 그 자리에서 펼친다', (tester) async {
      var expanded = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: RoutexTheme.light,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => RoutexMenuList(
                entries: entries,
                collapsedCount: 1,
                expanded: expanded,
                onExpanded: (value) => setState(() => expanded = value),
                onSelected: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('카페 라떼'), findsNothing);
      expect(find.text('2개 더보기'), findsOneWidget);

      await tester.tap(find.text('2개 더보기'));
      await tester.pumpAndSettle();
      expect(find.text('콜드브루'), findsOneWidget);
    });

    testWidgets('더 볼 것이 없는 줄은 누를 수 없다', (tester) async {
      final tapped = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          theme: RoutexTheme.light,
          home: Scaffold(
            body: RoutexMenuList(
              entries: entries,
              expanded: true,
              onExpanded: (_) {},
              onSelected: tapped.add,
            ),
          ),
        ),
      );

      await tester.tap(find.text('아이스 아메리카노'));
      await tester.tap(find.text('콜드브루'));
      expect(tapped, [0], reason: '막다른 팝업을 여는 대신 누를 수 없게 둔다');
    });
  });

  group('RoutexLinkList', () {
    testWidgets('라벨이 정체를 말하지 못하는 줄만 주소를 보여 준다', (tester) async {
      RoutexLinkItem? opened;
      await tester.pumpWidget(
        MaterialApp(
          theme: RoutexTheme.light,
          home: Scaffold(
            body: RoutexLinkList(
              items: const [
                RoutexLinkItem(
                  label: '공식 사이트',
                  url: 'https://example.com/seoul',
                  display: RoutexLinkDisplay.url,
                ),
                RoutexLinkItem(
                  label: '인스타그램',
                  url: 'https://instagram.com/example',
                ),
              ],
              onSelected: (item) => opened = item,
            ),
          ),
        ),
      );

      expect(find.text('https://example.com/seoul'), findsOneWidget);
      expect(find.text('공식 사이트'), findsNothing);
      expect(find.text('인스타그램'), findsOneWidget);

      await tester.tap(find.text('인스타그램'));
      expect(opened?.url, 'https://instagram.com/example');
    });
  });

  // 라벨을 주소로 덮으면 어느 브랜드인지가 사라지고, 주소를 지우면 어디로 나가는지가
  // 사라진다. 둘 다 남길 이유가 있는 줄만 두 줄이다.
  testWidgets('라벨이 브랜드를 말하면 주소와 함께 두 줄로 선다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: RoutexTheme.light,
        home: Scaffold(
          body: RoutexLinkList(
            items: const [
              RoutexLinkItem(
                label: '오설록 공식 홈페이지',
                url: 'https://osulloc.com',
                display: RoutexLinkDisplay.labelAndUrl,
              ),
              RoutexLinkItem(label: '인스타그램', url: 'https://example.com/ig'),
            ],
            onSelected: _ignoreLink,
          ),
        ),
      ),
    );

    expect(find.text('오설록 공식 홈페이지'), findsOneWidget);
    expect(find.text('https://osulloc.com'), findsOneWidget);
    // 나머지 줄은 라벨만이다.
    expect(find.text('인스타그램'), findsOneWidget);
    expect(find.text('https://example.com/ig'), findsNothing);
  });

  // 로고 파일은 이 저장소가 담지 않는다. 소비 앱이 이미 번들에 가진 그림만 받는다.
  testWidgets('배지 그림을 받으면 그것을 그리고, 없으면 브랜드 배지로 떨어진다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: RoutexTheme.light,
        home: Scaffold(
          body: RoutexLinkList(
            items: const [
              RoutexLinkItem(
                label: '공식 사이트',
                url: 'https://example.com',
                accent: RoutexLinkAccent(
                  icon: RoutexIcons.link,
                  colors: [Color(0xFF3C4043)],
                  image: AssetImage('favicon.png'),
                ),
              ),
              RoutexLinkItem(
                label: '인스타그램',
                url: 'https://example.com/ig',
                accent: RoutexLinkAccent(
                  icon: RoutexIcons.link,
                  colors: [Color(0xFFE1306C)],
                ),
              ),
            ],
            onSelected: _ignoreLink,
          ),
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget, reason: '그림을 준 줄만');
    expect(find.byIcon(RoutexIcons.link), findsOneWidget, reason: '나머지는 글리프');
  });

  // 헤더 안 두 동작이 같은 평면에 있어야 한다. 하나만 타일 배경을 가지면 사용자는
  // 둘을 서로 다른 종류의 컨트롤로 읽는다.
  testWidgets('저장과 공유는 같은 평면에 선다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: RoutexTheme.light,
        home: Scaffold(
          body: RoutexPlaceHeader(
            name: '스타벅스 리저브',
            metadata: 'B2 · 카페',
            onSaved: (_) {},
            onShare: () {},
          ),
        ),
      ),
    );

    final tones = tester
        .widgetList<RoutexIconAction>(find.byType(RoutexIconAction))
        .map((action) => action.tone)
        .toSet();
    expect(tones, {RoutexIconActionTone.quiet});
  });

  // 모든 장소가 저장되는 것은 아니다. 저장은 식별자를 붙잡아 두는 일이라, 그것이
  // 없는 항목에는 담을 곳이 없다. 토글만 남겨 두면 눌러도 아무 일이 없는 버튼이 된다.
  testWidgets('저장할 수 없는 장소에는 저장 action을 두지 않는다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: RoutexTheme.light,
        home: const Scaffold(
          body: RoutexPlaceHeader(name: '스타벅스 리저브', metadata: 'B2 · 카페'),
        ),
      ),
    );

    expect(find.byTooltip('장소 저장'), findsNothing);
    expect(find.text('스타벅스 리저브'), findsOneWidget);
  });

  group('RoutexResultList', () {
    testWidgets('기다리는 중과 찾지 못함이 서로 다른 화면이다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: RoutexTheme.light,
          home: const Scaffold(
            body: RoutexResultList(
              status: RoutexResultStatus.loading,
              loadingMessage: '실내 매장을 찾는 중',
              children: [],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('실내 매장을 찾는 중'), findsOneWidget);
      expect(find.byType(RoutexSkeletonList), findsOneWidget);
      expect(find.text('찾지 못했어요'), findsNothing);

      await tester.pumpWidget(
        MaterialApp(
          theme: RoutexTheme.light,
          home: const Scaffold(
            body: RoutexResultList(
              status: RoutexResultStatus.empty,
              children: [],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(RoutexEmptyState), findsOneWidget);
      expect(find.byType(RoutexSkeletonList), findsNothing);
    });

    testWidgets('결과가 있으면 요약과 정렬 기준을 같은 줄에 둔다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: RoutexTheme.light,
          home: Scaffold(
            body: RoutexResultList(
              status: RoutexResultStatus.ready,
              summary: '32개 결과',
              sortOptions: const [
                RoutexSortOption(id: 'near', label: '가까운 순'),
                RoutexSortOption(id: 'name', label: '이름 맞춤 순'),
              ],
              selectedSortId: 'near',
              onSortSelected: (_) {},
              children: const [
                RoutexListCell(title: '발렌시아가', leadingIcon: RoutexIcons.place),
              ],
            ),
          ),
        ),
      );

      expect(
        tester.getRect(find.text('32개 결과')).center.dy,
        moreOrLessEquals(tester.getRect(find.text('가까운 순')).center.dy),
      );
      expect(
        tester.getRect(find.text('32개 결과')).left,
        moreOrLessEquals(tester.getRect(find.byIcon(RoutexIcons.place)).left),
        reason: '요약은 첫 결과의 leading 열과 같은 시작선을 쓴다',
      );
      expect(find.text('발렌시아가'), findsOneWidget);
    });

    // 조용히 ready로 그리면 사용자는 지금 보는 것이 전부라고 읽는다.
    testWidgets('일부만 가져왔을 때는 남은 결과를 세우고 무엇이 빠졌는지 알린다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: RoutexTheme.light,
          home: const Scaffold(
            body: RoutexResultList(
              status: RoutexResultStatus.degraded,
              statusMessage: '추천 검색이 응답하지 않았어요.',
              children: [RoutexListCell(title: '발렌시아가')],
            ),
          ),
        ),
      );

      expect(find.text('발렌시아가'), findsOneWidget, reason: '남은 결과는 그대로 선다');
      final banner = tester.widget<RoutexStatusBanner>(
        find.byType(RoutexStatusBanner),
      );
      expect(banner.tone, RoutexStatusBannerTone.warning);
    });

    // "찾지 못했어요"는 "그런 곳은 없다"로 읽힌다. 실패한 검색에 그 문장을 쓰면
    // 사용자는 다시 시도할 이유를 잃는다.
    testWidgets('검색이 실패하면 빈손이 아니라 다시 시도를 준다', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: RoutexTheme.light,
          home: Scaffold(
            body: RoutexResultList(
              status: RoutexResultStatus.error,
              statusMessage: '연결이 끊겼어요.',
              statusActionLabel: '다시 시도',
              onStatusAction: () => retried = true,
              children: const [],
            ),
          ),
        ),
      );

      expect(find.byType(RoutexEmptyState), findsNothing);
      expect(find.text('찾지 못했어요'), findsNothing);
      final banner = tester.widget<RoutexStatusBanner>(
        find.byType(RoutexStatusBanner),
      );
      expect(banner.tone, RoutexStatusBannerTone.error);

      await tester.tap(find.text('다시 시도'));
      expect(retried, isTrue);
    });
  });

  group('RoutexStepList', () {
    testWidgets('지금 단계를 표시하고 지나온 단계는 무게를 낮춘다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: RoutexTheme.light,
          home: Scaffold(
            body: RoutexStepList(
              currentIndex: 1,
              steps: const [
                RoutexStep(
                  instruction: '직진',
                  icon: Icons.straight_rounded,
                  distance: '40m',
                ),
                RoutexStep(
                  instruction: '오른쪽 통로로 이동',
                  icon: Icons.turn_right_rounded,
                  distance: '92m',
                ),
              ],
            ),
          ),
        ),
      );

      final highlighted = tester
          .widgetList<DecoratedBox>(
            find.descendant(
              of: find.byType(RoutexStepList),
              matching: find.byType(DecoratedBox),
            ),
          )
          .map((box) => (box.decoration as BoxDecoration).color)
          .where(
            (color) => color == RoutexColorTokens.light.actionPrimarySubtle,
          )
          .length;
      expect(highlighted, 1, reason: '지금 단계는 한 줄만 강조된다');
      expect(find.text('92m'), findsOneWidget);
    });
  });

  group('RoutexTransitItinerary', () {
    testWidgets('도보 구간까지 그리고 첫 줄이 왜 첫 줄인지 밝힌다', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: RoutexTheme.light,
          home: Scaffold(
            body: RoutexTransitItinerary(
              duration: '35분',
              facts: const ['환승 1회', '도보 8분', '1,500원'],
              fastest: true,
              legs: const [
                RoutexTransitLeg(
                  label: '도보 5분',
                  icon: Icons.directions_walk_rounded,
                ),
                RoutexTransitLeg(label: '5호선', icon: Icons.subway_rounded),
              ],
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.text('최단 시간'), findsOneWidget);
      expect(find.text('도보 5분'), findsOneWidget);
      expect(find.text('환승 1회 · 도보 8분 · 1,500원'), findsOneWidget);

      await tester.tap(find.text('35분'));
      expect(pressed, isTrue);
    });
  });

  group('RoutexEtaCard와 RoutexArrivalCard', () {
    testWidgets('계획 화면은 도착 시각과 시작을, 도착 화면은 종료를 준다', (tester) async {
      var started = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: RoutexTheme.light,
          home: Scaffold(
            body: RoutexEtaCard(
              arrivalTime: '오후 3:24',
              metrics: const [
                RoutexTripMetric(value: '22분', label: '소요'),
                RoutexTripMetric(value: '1.4km', label: '거리'),
              ],
              onStart: () => started = true,
            ),
          ),
        ),
      );

      expect(find.text('오후 3:24'), findsOneWidget);
      expect(find.text('경로 지우기'), findsNothing);
      await tester.tap(find.text('안내 시작'));
      expect(started, isTrue);

      var closed = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: RoutexTheme.light,
          home: Scaffold(
            body: RoutexArrivalCard(
              destination: '발렌시아가',
              floor: '1F',
              onClose: () => closed = true,
            ),
          ),
        ),
      );

      expect(find.text('도착했습니다'), findsOneWidget);
      expect(find.text('발렌시아가 · 1F'), findsOneWidget);
      expect(
        find.textContaining('0 m'),
        findsNothing,
        reason: '도착에는 남은 거리가 없다',
      );

      await tester.tap(find.text('안내 종료'));
      expect(closed, isTrue);
    });
  });
}

void _ignoreLink(RoutexLinkItem item) {}
