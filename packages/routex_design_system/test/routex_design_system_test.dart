import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_design_system/routex_design_system.dart';

void main() {
  group('foundation token', () {
    test('간격과 공통 metric은 4px grid를 유지한다', () {
      for (final role in RoutexSpacingRole.values) {
        expect(role.value % 4, 0, reason: role.name);
      }
      for (final role in RoutexMetricRole.values) {
        expect(role.value % 4, 0, reason: role.name);
      }
      expect(RoutexMetrics.minimumTouchTarget, 48);
    });

    test('곡률과 layer는 제한된 위계를 유지한다', () {
      expect(RoutexRadiusRole.values, hasLength(5));
      expect(RoutexRadii.full.topLeft.x, 999);
      expect(RoutexLayer.onMap, lessThan(RoutexLayer.chrome));
      expect(RoutexLayer.chrome, lessThan(RoutexLayer.overlay));
    });

    test('제품 motion은 catalog와 reduced-motion 경계를 유지한다', () {
      expect(
        RoutexMotionRole.feedback.duration,
        const Duration(milliseconds: 120),
      );
      expect(
        RoutexMotionRole.transition.duration,
        const Duration(milliseconds: 200),
      );
      expect(
        RoutexMotionRole.emphasized.duration,
        const Duration(milliseconds: 320),
      );
      expect(
        RoutexMotion.effectiveDuration(
          disableAnimations: true,
          role: RoutexMotionRole.emphasized,
        ),
        Duration.zero,
      );
    });

    test('주요 전경과 배경 조합은 WCAG AA 대비를 만족한다', () {
      const colors = RoutexColorTokens.light;
      final pairs = <(String, Color, Color)>[
        ('contentPrimary', colors.contentPrimary, colors.surfaceBase),
        ('contentSecondary', colors.contentSecondary, colors.surfaceBase),
        ('primary action', colors.contentInverse, colors.actionPrimary),
        ('pressed action', colors.contentInverse, colors.actionPrimaryPressed),
        ('danger action', colors.contentInverse, colors.statusError),
        ('selected action', colors.actionPrimary, colors.actionPrimarySubtle),
        ('statusInfo', colors.statusInfo, colors.surfaceBase),
        ('statusSuccess', colors.statusSuccess, colors.surfaceBase),
        ('statusWarning', colors.statusWarning, colors.surfaceBase),
        ('statusError', colors.statusError, colors.surfaceBase),
      ];

      for (final (name, foreground, background) in pairs) {
        expect(
          _contrastRatio(foreground, background),
          greaterThanOrEqualTo(4.5),
          reason: name,
        );
      }
    });

    test('색과 typography catalog가 semantic token을 해석한다', () {
      const colors = RoutexColorTokens.light;
      expect(
        RoutexColorRole.actionPrimary.resolve(colors),
        colors.actionPrimary,
      );
      expect(
        RoutexTypographyRole.bodyStrong.textStyle,
        RoutexTypography.bodyStrong,
      );
    });
  });

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

  testWidgets('RoutexTheme 없이 token을 읽으면 구성 오류를 드러낸다', (tester) async {
    late BuildContext tokenContext;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            tokenContext = context;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(() => tokenContext.routexColors, throwsFlutterError);
  });
}

void _unexpectedPress() =>
    throw StateError('disabled cell must not be pressed');

double _contrastRatio(Color foreground, Color background) {
  final lighter = foreground.computeLuminance() > background.computeLuminance()
      ? foreground.computeLuminance()
      : background.computeLuminance();
  final darker = foreground.computeLuminance() > background.computeLuminance()
      ? background.computeLuminance()
      : foreground.computeLuminance();
  return (lighter + 0.05) / (darker + 0.05);
}
