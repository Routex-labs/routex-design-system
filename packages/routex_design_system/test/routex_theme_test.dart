import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_design_system/routex_design_system.dart';

void main() {
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

  // 역할 슬롯은 여덟인데 Material 슬롯은 열다섯이다. 남는 슬롯이 기본값으로
  // 남으면 가족이 Roboto가 되고, Roboto에는 한글이 없어 그 자리만 시스템 대체
  // 글꼴로 떨어진다. 한 화면에 두 글꼴이 서는데 영문으로 보면 티가 안 난다.
  test('Material 기본 슬롯까지 모두 Pretendard로 선다', () {
    const expected =
        'packages/${RoutexTypography.fontPackage}/${RoutexTypography.fontFamily}';
    final textTheme = RoutexTheme.light.textTheme;

    final families = <String, String?>{
      'displayLarge': textTheme.displayLarge?.fontFamily,
      'displayMedium': textTheme.displayMedium?.fontFamily,
      'displaySmall': textTheme.displaySmall?.fontFamily,
      'headlineLarge': textTheme.headlineLarge?.fontFamily,
      'headlineMedium': textTheme.headlineMedium?.fontFamily,
      'headlineSmall': textTheme.headlineSmall?.fontFamily,
      'titleLarge': textTheme.titleLarge?.fontFamily,
      'titleMedium': textTheme.titleMedium?.fontFamily,
      'titleSmall': textTheme.titleSmall?.fontFamily,
      'bodyLarge': textTheme.bodyLarge?.fontFamily,
      'bodyMedium': textTheme.bodyMedium?.fontFamily,
      'bodySmall': textTheme.bodySmall?.fontFamily,
      'labelLarge': textTheme.labelLarge?.fontFamily,
      'labelMedium': textTheme.labelMedium?.fontFamily,
      'labelSmall': textTheme.labelSmall?.fontFamily,
    };

    expect(families, {for (final slot in families.keys) slot: expected});
  });

  // 역할 슬롯의 크기·굵기까지 기본값에 덮이면 제품 위계가 사라진다. 가족만
  // 맞추고 역할은 그대로여야 한다.
  test('역할이 정한 슬롯은 크기와 굵기를 지킨다', () {
    final textTheme = RoutexTheme.light.textTheme;

    expect(textTheme.bodyMedium?.fontSize, RoutexTypography.body.fontSize);
    expect(textTheme.bodyMedium?.fontWeight, RoutexTypography.body.fontWeight);
    expect(textTheme.titleMedium?.fontSize, RoutexTypography.title.fontSize);
    expect(textTheme.labelSmall?.fontSize, RoutexTypography.caption.fontSize);
  });
}
