import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_design_system/routex_design_system.dart';

void main() {
  group('RoutexMapOverlay', () {
    Future<void> pumpOverlay(
      WidgetTester tester, {
      required double sheetHeight,
      TextScaler textScaler = TextScaler.noScaling,
    }) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: RoutexTheme.light,
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(390, 844),
              padding: const EdgeInsets.only(top: 42, bottom: 20),
              textScaler: textScaler,
            ),
            child: SizedBox(
              width: 390,
              height: 844,
              child: RoutexMapOverlay(
                top: const RoutexManeuverBanner(
                  key: ValueKey('top'),
                  distance: '120m 후 건물로 진입',
                  detail: '더현대 서울 1층 · 명품관 방향',
                  icon: Icons.turn_right_rounded,
                ),
                trailingControls: [
                  RoutexMapControl(
                    key: const ValueKey('control'),
                    icon: Icons.my_location_rounded,
                    label: '현재 위치',
                    onPressed: () {},
                  ),
                ],
                sheet: SizedBox(
                  key: const ValueKey('sheet'),
                  height: sheetHeight,
                  child: const RoutexBottomSheet(child: SizedBox.shrink()),
                ),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('시트가 커져도 지도 컨트롤이 시트 위에 남는다', (tester) async {
      for (final sheetHeight in [120.0, 320.0]) {
        await pumpOverlay(tester, sheetHeight: sheetHeight);

        final sheet = tester.getRect(find.byKey(const ValueKey('sheet')));
        final control = tester.getRect(find.byKey(const ValueKey('control')));

        expect(sheet.bottom, 844, reason: '시트는 화면 아래에 붙는다');
        expect(
          control.bottom,
          moreOrLessEquals(sheet.top - RoutexSpacing.contentGap),
          reason: '컨트롤은 시트 높이와 무관하게 시트 바로 위에 쌓인다',
        );
      }
    });

    testWidgets('상단 표면과 지도 컨트롤이 같은 screen gutter를 쓴다', (tester) async {
      await pumpOverlay(tester, sheetHeight: 120);

      final top = tester.getRect(find.byKey(const ValueKey('top')));
      final control = tester.getRect(find.byKey(const ValueKey('control')));

      expect(top.left, RoutexSpacing.screenGutter);
      expect(top.right, 390 - RoutexSpacing.screenGutter);
      expect(control.right, 390 - RoutexSpacing.screenGutter);
      expect(
        top.top,
        42 + RoutexSpacing.controlGap,
        reason: '상단 표면은 좌표가 아니라 안전 영역을 기준으로 놓인다',
      );
    });

    testWidgets('2배 글자에서도 overflow 없이 배치한다', (tester) async {
      await pumpOverlay(
        tester,
        sheetHeight: 320,
        textScaler: const TextScaler.linear(2),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('layout primitive', () {
    testWidgets('Inset은 모든 역할의 방향성 여백을 정확히 고정한다', (tester) async {
      final cases = <(RoutexInsetRole, EdgeInsetsGeometry)>[
        (
          RoutexInsetRole.screen,
          const EdgeInsetsDirectional.fromSTEB(
            RoutexSpacing.screenGutter,
            RoutexSpacing.sectionGap,
            RoutexSpacing.screenGutter,
            RoutexSpacing.sectionGap,
          ),
        ),
        (
          RoutexInsetRole.component,
          const EdgeInsetsDirectional.all(RoutexSpacing.componentPadding),
        ),
      ];

      for (final (role, expectedPadding) in cases) {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.rtl,
            child: RoutexInset(
              role: role,
              child: const SizedBox(width: 100, height: 100),
            ),
          ),
        );

        expect(
          tester.widget<Padding>(find.byType(Padding)).padding,
          expectedPadding,
          reason: role.name,
        );
      }
    });

    testWidgets('Stack은 모든 역할에서 자식 사이에만 gap을 둔다', (tester) async {
      final cases = <(RoutexStackGap, double)>[
        (RoutexStackGap.inline, RoutexSpacing.inlineGap),
        (RoutexStackGap.control, RoutexSpacing.controlGap),
        (RoutexStackGap.content, RoutexSpacing.contentGap),
        (RoutexStackGap.section, RoutexSpacing.sectionGap),
      ];

      for (final (gap, expectedGap) in cases) {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 100,
                child: RoutexStack(
                  gap: gap,
                  children: const [
                    SizedBox(key: ValueKey('first'), height: 10),
                    SizedBox(key: ValueKey('second'), height: 10),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(
          tester.getSize(find.byType(RoutexStack)).height,
          20 + expectedGap,
          reason: gap.name,
        );
        expect(
          tester.getSize(find.byKey(const ValueKey('first'))).width,
          tester.getSize(find.byType(RoutexStack)).width,
          reason: '${gap.name} stretch',
        );
        expect(
          tester.getTopLeft(find.byKey(const ValueKey('second'))).dy -
              tester.getTopLeft(find.byKey(const ValueKey('first'))).dy,
          10 + expectedGap,
          reason: gap.name,
        );
      }
    });

    // 지도 조작 버튼처럼 세로로 쌓이는 컨트롤은 폭까지 늘어나면 안 된다. 실제
    // 화면에서 지도를 가리는 넓이와 달라져, 카탈로그에서 본 크기가 기기에서
    // 달라진다. 기본값은 채우기이므로 기존 사용처는 그대로다.
    testWidgets('Stack은 content fill에서 자식 폭을 늘리지 않는다', (tester) async {
      for (final (fill, stretches) in const [
        (RoutexStackFill.full, true),
        (RoutexStackFill.content, false),
      ]) {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 100,
                child: RoutexStack(
                  gap: RoutexStackGap.control,
                  fill: fill,
                  children: const [
                    SizedBox(key: ValueKey('narrow'), width: 24, height: 10),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(
          tester.getSize(find.byKey(const ValueKey('narrow'))).width,
          stretches ? 100 : 24,
          reason: fill.name,
        );
        expect(
          tester.getTopLeft(find.byKey(const ValueKey('narrow'))).dx,
          0,
          reason: '${fill.name}: 어느 쪽이든 시작선은 같다',
        );
      }
    });

    testWidgets('Cluster는 모든 역할에서 같은 축 간격으로 줄바꿈한다', (tester) async {
      final cases = <(RoutexClusterGap, double)>[
        (RoutexClusterGap.control, RoutexSpacing.controlGap),
        (RoutexClusterGap.content, RoutexSpacing.contentGap),
      ];

      for (final (gap, expectedGap) in cases) {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 100,
                child: RoutexCluster(
                  gap: gap,
                  children: const [
                    SizedBox(key: ValueKey('first'), width: 60, height: 20),
                    SizedBox(key: ValueKey('second'), width: 60, height: 20),
                  ],
                ),
              ),
            ),
          ),
        );

        final wrap = tester.widget<Wrap>(find.byType(Wrap));
        expect(wrap.spacing, expectedGap, reason: gap.name);
        expect(wrap.runSpacing, expectedGap, reason: gap.name);
        expect(wrap.alignment, WrapAlignment.start, reason: gap.name);
        expect(
          tester.getTopLeft(find.byKey(const ValueKey('second'))).dy -
              tester.getTopLeft(find.byKey(const ValueKey('first'))).dy,
          20 + expectedGap,
          reason: gap.name,
        );
        expect(tester.takeException(), isNull);
      }
    });
  });
}
