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

double _contrastRatio(Color foreground, Color background) {
  final lighter = foreground.computeLuminance() > background.computeLuminance()
      ? foreground.computeLuminance()
      : background.computeLuminance();
  final darker = foreground.computeLuminance() > background.computeLuminance()
      ? background.computeLuminance()
      : foreground.computeLuminance();
  return (lighter + 0.05) / (darker + 0.05);
}
