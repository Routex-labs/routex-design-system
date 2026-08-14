import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_design_system/routex_design_system.dart';

void main() {
  test('foundation token은 4px grid와 제품 motion 경계를 유지한다', () {
    expect(RoutexSpacing.controlGap % 4, 0);
    expect(RoutexSpacing.sectionGap % 4, 0);
    expect(RoutexMotion.fast, const Duration(milliseconds: 120));
    expect(
      RoutexMotion.duration(
        disableAnimations: true,
        standard: RoutexMotion.slow,
      ),
      Duration.zero,
    );
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
      greaterThanOrEqualTo(48),
    );
    final context = tester.element(find.byType(RoutexButton));
    expect(context.routexColors.actionPrimary, const Color(0xFF4A87F1));
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
