import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_design_system/routex_design_system.dart';

void main() {
  testWidgets('RoutexButton은 theme token과 48dp 터치 영역을 사용한다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: RoutexTheme.light,
        home: Scaffold(
          body: RoutexButton(label: '길찾기', onPressed: () {}),
        ),
      ),
    );

    expect(find.text('길찾기'), findsOneWidget);
    expect(
      tester.getSize(find.byType(TextButton)).height,
      greaterThanOrEqualTo(RoutexMetrics.minimumTouchTarget),
    );
  });

  group('RoutexListCell beta', () {
    testWidgets('leading 유무와 LTR·RTL에 관계없이 텍스트 열을 고정한다', (tester) async {
      for (final direction in TextDirection.values) {
        await tester.pumpWidget(
          MaterialApp(
            theme: RoutexTheme.light,
            home: Directionality(
              textDirection: direction,
              child: const Scaffold(
                body: SizedBox(
                  width: 360,
                  child: Column(
                    children: [
                      RoutexListCell(
                        title: '아이콘 있음',
                        subtitle: '같은 텍스트 열',
                        leadingIcon: Icons.storefront_outlined,
                      ),
                      RoutexListCell(title: '아이콘 없음', subtitle: '같은 텍스트 열'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        final withIcon = tester.getRect(find.text('아이콘 있음'));
        final withoutIcon = tester.getRect(find.text('아이콘 없음'));
        if (direction == TextDirection.ltr) {
          expect(withIcon.left, withoutIcon.left);
        } else {
          expect(withIcon.right, withoutIcon.right);
        }
        expect(withIcon.top, lessThan(withoutIcon.top));
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('빈 subtitle은 gap을 남기지 않고 48dp 터치 영역을 유지한다', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: RoutexTheme.light,
          home: Scaffold(
            body: RoutexListCell(
              title: '저장한 장소',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(
        tester.getSize(find.byType(RoutexListCell)).height,
        greaterThanOrEqualTo(RoutexMetrics.minimumTouchTarget),
      );
      expect(find.byType(RoutexStack), findsNothing);
      await tester.tap(find.byType(RoutexListCell));
      expect(pressed, isTrue);
    });

    // 검색 결과는 "왜 이 줄이 걸렸는지"를 색으로 말한다. 무엇이 걸렸는지 정하는
    // 일은 소비 앱이 하고, 여기서는 받은 구간만 다른 색으로 그린다.
    testWidgets('강조 구간만 다른 색으로 갈린다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: RoutexTheme.light,
          home: const Scaffold(
            body: RoutexListCell(
              title: '스타벅스 리저브',
              titleHighlights: [TextRange(start: 0, end: 4)],
            ),
          ),
        ),
      );

      final rich = tester.widget<Text>(find.byType(Text).first);
      final spans = (rich.textSpan! as TextSpan).children!
          .cast<TextSpan>()
          .toList();
      expect(spans.map((span) => span.text), ['스타벅스', ' 리저브']);
      expect(spans.first.style?.color, RoutexColorTokens.light.actionPrimary);
      expect(spans.last.style?.color, isNull, reason: '나머지는 제목 색 그대로다');
    });

    // 종류가 섞인 목록에서 아이콘까지 강조색을 쓰면, 강조색이 "왜 이 줄이 걸렸나"를
    // 말하는지 "이건 장소다"를 말하는지 흐려진다. 그런 목록은 모양으로만 가른다.
    testWidgets('조용한 아이콘은 강조색을 제목의 일치 구간에 넘긴다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: RoutexTheme.light,
          home: const Scaffold(
            body: RoutexListCell(
              title: '스타벅스 리저브',
              titleHighlights: [TextRange(start: 0, end: 4)],
              leadingIcon: RoutexIcons.search,
              leadingIconTone: RoutexListIconTone.quiet,
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(RoutexIcons.search));
      expect(icon.color, RoutexColorTokens.light.contentSecondary);

      final spans =
          (tester.widget<Text>(find.byType(Text).first).textSpan! as TextSpan)
              .children!
              .cast<TextSpan>();
      expect(
        spans.first.style?.color,
        RoutexColorTokens.light.actionPrimary,
        reason: '강조색은 일치 구간 몫이다',
      );
    });

    testWidgets('기본 아이콘은 강조색이다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: RoutexTheme.light,
          home: const Scaffold(
            body: RoutexListCell(
              title: '저장한 장소',
              leadingIcon: RoutexIcons.place,
            ),
          ),
        ),
      );

      expect(
        tester.widget<Icon>(find.byIcon(RoutexIcons.place)).color,
        RoutexColorTokens.light.actionPrimary,
      );
    });

    // 하나도 안 걸리는 것이 정상이다 — 의미 검색은 이름에 검색어가 없는 결과를
    // 주는 것이 목적이다. 그때 제목은 조각나지 않은 한 줄이어야 한다.
    testWidgets('강조가 없으면 제목을 조각내지 않는다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: RoutexTheme.light,
          home: const Scaffold(body: RoutexListCell(title: '스타벅스 리저브')),
        ),
      );

      final title = tester.widget<Text>(find.byType(Text).first);
      expect(title.data, '스타벅스 리저브');
      expect(title.textSpan, isNull);
    });

    testWidgets('selected·disabled 상태를 의미와 동작에 함께 반영한다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: RoutexTheme.light,
          home: const Scaffold(
            body: RoutexListCell(
              title: '선택한 장소',
              subtitle: 'B2 · 카페',
              selected: true,
              enabled: false,
              onPressed: _unexpectedPress,
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(RoutexListCell));
      expect(
        semantics,
        matchesSemantics(
          label: '선택한 장소, B2 · 카페',
          isButton: true,
          hasSelectedState: true,
          isSelected: true,
          hasEnabledState: true,
          isEnabled: false,
        ),
      );
      expect(tester.widget<InkWell>(find.byType(InkWell)).onTap, isNull);
      expect(
        tester
            .widget<Material>(
              find.descendant(
                of: find.byType(RoutexListCell),
                matching: find.byType(Material),
              ),
            )
            .color,
        RoutexColorTokens.light.actionPrimarySubtle,
      );
    });

    testWidgets('pressed는 selected와 조합해도 별도 시각 상태를 유지한다', (tester) async {
      for (final selected in [false, true]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: RoutexTheme.light,
            home: Scaffold(
              body: RoutexListCell(
                title: '상태 조합',
                selected: selected,
                onPressed: _unexpectedPress,
              ),
            ),
          ),
        );

        final pressedColor = tester
            .widget<InkWell>(find.byType(InkWell))
            .overlayColor
            ?.resolve({WidgetState.pressed});
        expect(
          pressedColor,
          selected
              ? RoutexColorTokens.light.surfaceCanvas
              : RoutexColorTokens.light.actionPrimarySubtle,
          reason: 'selected: $selected',
        );
      }
    });

    for (final width in [360.0, 390.0]) {
      for (final textScale in [1.0, 1.3, 2.0]) {
        testWidgets('${width.toInt()}px · $textScale× 긴 한글에서 overflow가 없다', (
          tester,
        ) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = Size(width, 600);
          tester.platformDispatcher.textScaleFactorTestValue = textScale;
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

          await tester.pumpWidget(
            MaterialApp(
              theme: RoutexTheme.light,
              home: const Scaffold(
                body: RoutexListCell(
                  title: '더현대 서울에서 저장한 아주 긴 장소 이름',
                  subtitle: '지하 2층에서 찾을 수 있는 카페와 베이커리 상세 정보',
                  leadingIcon: Icons.storefront_outlined,
                  trailingIcon: Icons.chevron_right,
                ),
              ),
            ),
          );
          await tester.pump();

          expect(find.textContaining('더현대 서울'), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  testWidgets('loading 상태는 동작을 비활성화하고 진행 상태를 표시한다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: RoutexTheme.light,
        home: const Scaffold(
          body: RoutexButton(
            label: '경로 계산 중',
            onPressed: null,
            isLoading: true,
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<TextButton>(find.byType(TextButton)).onPressed,
      isNull,
    );
  });

  testWidgets('Tabs는 선택 상태와 동작을 같은 index로 관리한다', (tester) async {
    var selected = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: RoutexTheme.light,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => RoutexTabs(
              labels: const ['홈', '메뉴', '사진'],
              selectedIndex: selected,
              onSelected: (value) => setState(() => selected = value),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('사진'));
    await tester.pump();
    expect(selected, 2);
    expect(
      tester.getSize(find.byType(RoutexTabs)).height,
      greaterThanOrEqualTo(RoutexMetrics.minimumTouchTarget),
    );
  });

  group('RoutexChipBar', () {
    const options = [
      RoutexChipOption(
        id: 'cafe',
        label: '카페',
        icon: Icons.local_cafe_outlined,
      ),
      RoutexChipOption(id: 'food', label: '음식'),
      RoutexChipOption(id: 'shop', label: '쇼핑'),
    ];

    Future<void> pumpBar(
      WidgetTester tester, {
      required String? selectedId,
      required ValueChanged<String?> onSelected,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: RoutexTheme.light,
          home: Scaffold(
            body: RoutexChipBar(
              options: options,
              selectedId: selectedId,
              onSelected: onSelected,
              semanticsLabel: '분류',
            ),
          ),
        ),
      );
    }

    testWidgets('선택된 항목을 다시 누르면 선택을 해제한다', (tester) async {
      String? selection;
      var calls = 0;

      void record(String? value) {
        selection = value;
        calls++;
      }

      await pumpBar(tester, selectedId: null, onSelected: record);
      await tester.tap(find.text('음식'));
      expect(selection, 'food');

      await pumpBar(tester, selectedId: 'food', onSelected: record);
      await tester.tap(find.text('음식'));
      expect(selection, isNull, reason: '같은 항목을 다시 누르면 해제한다');
      expect(calls, 2);
    });

    testWidgets('보이는 높이는 32, 터치 영역은 48을 유지한다', (tester) async {
      await pumpBar(tester, selectedId: 'cafe', onSelected: (_) {});

      final targets = find.byType(GestureDetector);
      final pills = find.byType(InkWell);
      expect(pills, findsNWidgets(options.length));
      for (var index = 0; index < options.length; index++) {
        expect(
          tester.getSize(pills.at(index)).height,
          RoutexMetrics.compactControl,
          reason: '${options[index].label} 시각 높이',
        );
      }
      expect(
        tester.getSize(targets.first).height,
        greaterThanOrEqualTo(RoutexMetrics.minimumTouchTarget),
        reason: '터치 영역',
      );
    });

    testWidgets('2배 글자에서도 세로로 접지 않고 한 줄을 유지한다', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: RoutexTheme.light,
          home: const MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(2)),
            child: Scaffold(
              body: RoutexChipBar(
                options: options,
                selectedId: null,
                onSelected: _ignoreSelection,
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      final labels = options
          .map((option) => tester.getRect(find.text(option.label)).top)
          .toSet();
      expect(labels, hasLength(1), reason: '모든 칩이 같은 줄에 남는다');
    });

    // 지도 위 오버레이는 스크롤을 이미 소유한다. 그 안에 이 줄이 제 뷰포트를 또
    // 만들면 무한 폭을 받아 그 자리에서 터진다.
    testWidgets('부모가 가로 스크롤을 소유하면 뷰포트를 겹쳐 만들지 않는다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: RoutexTheme.light,
          home: Scaffold(
            body: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: RoutexChipBar(
                options: options,
                selectedId: null,
                onSelected: _ignoreSelection,
                overflow: RoutexChipBarOverflow.deferToParent,
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(Scrollable), findsOneWidget, reason: '뷰포트는 부모 하나뿐이다');
    });

    testWidgets('기본값은 스스로 스크롤한다', (tester) async {
      await pumpBar(tester, selectedId: null, onSelected: _ignoreSelection);

      expect(find.byType(Scrollable), findsOneWidget);
    });
  });

  group('RoutexSectionHeader', () {
    testWidgets('보조 동작은 48dp 터치 영역을 유지하고 제목과 같은 줄에 남는다', (tester) async {
      var opened = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: RoutexTheme.light,
          home: Scaffold(
            body: RoutexSectionHeader(
              title: '최근 검색',
              actionLabel: '전체 보기',
              onAction: () => opened = true,
            ),
          ),
        ),
      );

      expect(
        tester.getRect(find.text('전체 보기')).center.dy,
        moreOrLessEquals(tester.getRect(find.text('최근 검색')).center.dy),
        reason: '제목과 보조 동작은 같은 줄에서 세로 중앙을 공유한다',
      );
      expect(
        tester.getSize(find.byType(TextButton)).height,
        greaterThanOrEqualTo(RoutexMetrics.minimumTouchTarget),
      );

      await tester.tap(find.text('전체 보기'));
      expect(opened, isTrue);
    });

    testWidgets('보조 동작이 없으면 제목만 남는다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: RoutexTheme.light,
          home: const Scaffold(body: RoutexSectionHeader(title: '저장한 장소')),
        ),
      );

      expect(find.byType(TextButton), findsNothing);
      expect(find.text('저장한 장소'), findsOneWidget);
    });
  });

  group('RoutexToast', () {
    tearDown(RoutexToast.dismiss);

    testWidgets('연속으로 띄워도 화면에는 하나만 남고 시간이 지나면 사라진다', (tester) async {
      late BuildContext hostContext;
      await tester.pumpWidget(
        MaterialApp(
          theme: RoutexTheme.light,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                hostContext = context;
                return const SizedBox.expand();
              },
            ),
          ),
        ),
      );

      RoutexToast.show(hostContext, '복사했습니다');
      RoutexToast.show(hostContext, '저장했습니다');
      await tester.pump();

      expect(find.text('복사했습니다'), findsNothing, reason: '이전 토스트는 즉시 걷힌다');
      expect(find.text('저장했습니다'), findsOneWidget);

      await tester.pump(RoutexToast.visibleDuration);
      await tester.pump();
      expect(find.text('저장했습니다'), findsNothing);
      expect(RoutexToast.isVisible, isFalse);
    });

    testWidgets('떠 있는 동안에도 뒤의 버튼을 누를 수 있다', (tester) async {
      var pressed = false;
      late BuildContext hostContext;
      await tester.pumpWidget(
        MaterialApp(
          theme: RoutexTheme.light,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                hostContext = context;
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: RoutexButton(
                    label: '길찾기',
                    onPressed: () => pressed = true,
                  ),
                );
              },
            ),
          ),
        ),
      );

      RoutexToast.show(hostContext, '복사했습니다');
      await tester.pump();
      await tester.tap(find.text('길찾기'));
      expect(pressed, isTrue, reason: '토스트는 포인터를 통과시킨다');

      // 토스트는 스스로 사라지는 타이머를 들고 있다. 테스트가 그 전에 끝나면
      // 위젯 트리만 사라지고 타이머가 남는다.
      await tester.pump(RoutexToast.visibleDuration);
    });
  });

  group('RoutexDisclosure', () {
    testWidgets('접혀 있어도 preview는 남고 나머지는 숨는다', (tester) async {
      var expanded = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: RoutexTheme.light,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => RoutexDisclosure(
                leadingIcon: RoutexIcons.schedule,
                header: const Text('영업 중'),
                preview: const Text('오늘 10:30 - 20:00'),
                expanded: expanded,
                onExpanded: (value) => setState(() => expanded = value),
                child: const Text('수 10:30 - 20:00'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('오늘 10:30 - 20:00'), findsOneWidget);
      expect(find.text('수 10:30 - 20:00'), findsNothing);
      expect(
        tester.getSize(find.byType(InkWell).first).height,
        greaterThanOrEqualTo(RoutexMetrics.minimumTouchTarget),
      );

      await tester.tap(find.text('영업 중'));
      await tester.pumpAndSettle();
      expect(find.text('수 10:30 - 20:00'), findsOneWidget);
    });

    testWidgets('RoutexShowMore는 접혀 있을 때만 개수를 적는다', (tester) async {
      var expanded = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: RoutexTheme.light,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => RoutexShowMore(
                expanded: expanded,
                hiddenCount: 6,
                onExpanded: (value) => setState(() => expanded = value),
              ),
            ),
          ),
        ),
      );

      expect(find.text('6개 더보기'), findsOneWidget);
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      expect(find.text('접기'), findsOneWidget, reason: '펼친 뒤 개수는 세지 않는다');
    });
  });

  group('RoutexInfoRow', () {
    testWidgets('아이콘이 라벨을 대신하고, keepLabel이면 라벨을 남긴다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: RoutexTheme.light,
          home: const Scaffold(
            body: Column(
              children: [
                RoutexInfoRow(
                  label: '주소',
                  value: '서울 영등포구 여의대로 108',
                  icon: Icons.place_outlined,
                ),
                RoutexInfoRow(
                  label: '고객센터',
                  value: '1522-3232',
                  icon: Icons.support_agent_outlined,
                  keepLabel: true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('주소'), findsNothing);
      expect(find.text('고객센터'), findsOneWidget);
    });

    testWidgets('복사는 48dp 터치 영역을 가지고 결과를 문장으로 알린다', (tester) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async => null,
      );
      addTearDown(() {
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        );
        RoutexToast.dismiss();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: RoutexTheme.light,
          home: const Scaffold(
            body: RoutexInfoRow(
              label: '고객센터',
              value: '1522-3232 (평일 09:00–18:00)',
              icon: Icons.support_agent_outlined,
              keepLabel: true,
              copyText: '1522-3232',
            ),
          ),
        ),
      );

      final copy = find.widgetWithText(TextButton, '복사');
      expect(
        tester.getSize(copy).height,
        greaterThanOrEqualTo(RoutexMetrics.minimumTouchTarget),
      );

      await tester.tap(copy);
      await tester.pump();
      await tester.pump();
      expect(find.text('복사했습니다'), findsOneWidget);

      await tester.pump(RoutexToast.visibleDuration);
    });
  });

  group('RoutexSortMenu', () {
    testWidgets('쓸 수 없는 기준은 감추지 않고 이유를 함께 적는다', (tester) async {
      var selected = 'name';
      await tester.pumpWidget(
        MaterialApp(
          theme: RoutexTheme.light,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => RoutexSortMenu(
                options: const [
                  RoutexSortOption(
                    id: 'near',
                    label: '가까운 순',
                    unavailableReason: '현재 위치 필요',
                  ),
                  RoutexSortOption(id: 'name', label: '이름 맞춤 순'),
                ],
                selectedId: selected,
                onSelected: (value) => setState(() => selected = value),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('이름 맞춤 순'));
      await tester.pumpAndSettle();

      expect(find.text('가까운 순 (현재 위치 필요)'), findsOneWidget);
      final item = tester.widget<PopupMenuItem<String>>(
        find.widgetWithText(PopupMenuItem<String>, '가까운 순 (현재 위치 필요)'),
      );
      expect(item.enabled, isFalse);
    });
  });

  group('RoutexSwitchRow', () {
    testWidgets('스위치 글리프가 아니라 줄 전체가 값을 바꾼다', (tester) async {
      var value = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: RoutexTheme.light,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => RoutexSwitchRow(
                title: '실내 진입 자동 전환',
                description: '건물 입구에 닿으면 실내 도면으로 바꾼다',
                value: value,
                onChanged: (next) => setState(() => value = next),
              ),
            ),
          ),
        ),
      );

      expect(
        tester.getSize(find.byType(RoutexSwitchRow)).height,
        greaterThanOrEqualTo(RoutexMetrics.minimumTouchTarget),
      );

      await tester.tap(find.text('실내 진입 자동 전환'));
      await tester.pumpAndSettle();
      expect(value, isTrue);
    });

    testWidgets('바꿀 수 없는 값도 행을 숨기지 않는다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: RoutexTheme.light,
          home: const Scaffold(
            body: RoutexSwitchRow(
              title: '보행자 안내 음성',
              value: false,
              onChanged: null,
            ),
          ),
        ),
      );

      expect(find.text('보행자 안내 음성'), findsOneWidget);
      expect(tester.widget<Switch>(find.byType(Switch)).onChanged, isNull);
    });
  });

  group('RoutexSkeleton', () {
    testWidgets('글자 자리표시는 글자 배율을 따라 높아진다', (tester) async {
      Future<double> heightAt(double scale) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: RoutexTheme.light,
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: const Scaffold(
                body: RoutexSkeleton(shape: RoutexSkeletonShape.line),
              ),
            ),
          ),
        );
        await tester.pump();
        return tester.getSize(find.byType(RoutexSkeleton)).height;
      }

      expect(await heightAt(2), greaterThan(await heightAt(1)));
    });

    testWidgets('목록 자리표시는 행 구조를 그대로 따른다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: RoutexTheme.light,
          home: const Scaffold(body: RoutexSkeletonList(count: 4)),
        ),
      );
      await tester.pump();

      expect(find.byType(RoutexSkeleton), findsNWidgets(4 * 3));
    });
  });

  group('RoutexMedia', () {
    testWidgets('사진이 없으면 자리 자체를 만들지 않는다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: RoutexTheme.light,
          home: const Scaffold(
            body: Column(
              children: [
                RoutexMediaCarousel(items: []),
                RoutexPhotoGrid(items: []),
              ],
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byType(RoutexMediaCarousel)).height, 0);
      expect(tester.getSize(find.byType(RoutexPhotoGrid)).height, 0);
    });
  });

  group('RoutexDialog', () {
    testWidgets('확인이 없는 dialog는 닫기 하나만 주 행동으로 남긴다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: RoutexTheme.light,
          home: Scaffold(
            body: Builder(
              builder: (context) => RoutexButton(
                label: '열기',
                onPressed: () => showRoutexDialog(
                  context: context,
                  dialog: RoutexDialog(
                    title: '아이스 카페 아메리카노',
                    subtitle: 'Iced Caffe Americano',
                    facts: const [RoutexKeyValue(label: '용량', value: '355ml')],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('열기'));
      await tester.pumpAndSettle();

      expect(find.text('355ml'), findsOneWidget);
      expect(find.byType(RoutexButton), findsNWidgets(2), reason: '닫기 하나만 있다');

      await tester.tap(find.text('닫기'));
      await tester.pumpAndSettle();
      expect(find.byType(RoutexDialog), findsNothing);
    });
  });

  group('RoutexBadge', () {
    testWidgets('데이터가 들고 온 색이 tone보다 우선한다', (tester) async {
      const accent = RoutexBadgeAccent(
        surface: Color(0xFFE8F5EC),
        ink: Color(0xFF1E7B45),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: RoutexTheme.light,
          home: const Scaffold(
            body: RoutexBadge(
              label: 'NEW',
              tone: RoutexBadgeTone.error,
              accent: accent,
            ),
          ),
        ),
      );

      final decoration =
          tester
                  .widget<DecoratedBox>(
                    find.descendant(
                      of: find.byType(RoutexBadge),
                      matching: find.byType(DecoratedBox),
                    ),
                  )
                  .decoration
              as BoxDecoration;
      expect(decoration.color, accent.surface);
    });
  });
}

void _ignoreSelection(String? _) {}

void _unexpectedPress() =>
    throw StateError('disabled cell must not be pressed');
