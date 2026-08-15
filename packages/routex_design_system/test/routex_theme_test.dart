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
}
