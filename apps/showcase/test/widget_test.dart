import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_design_system/routex_design_system.dart';
import 'package:showcase/main.dart';
import 'package:showcase/src/alignment_rhythm_fixture.dart';

void main() {
  testWidgets('Runtime Kit의 catalog와 실제 버튼을 렌더링한다', (tester) async {
    await tester.pumpWidget(const RoutexShowcaseApp());

    expect(find.text('Routex Design System'), findsOneWidget);
    expect(find.text('Semantic colors'), findsOneWidget);
    expect(find.text('Alignment & Rhythm'), findsOneWidget);
    expect(find.text('Button · beta'), findsOneWidget);
    expect(find.text('Motion boundary'), findsOneWidget);
    expect(find.text(RoutexColorRole.actionPrimary.name), findsOneWidget);
  });

  for (final width in [360.0, 390.0]) {
    for (final textScale in [1.0, 1.3, 2.0]) {
      testWidgets('${width.toInt()}px · $textScale×에서 overflow가 없다', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 1800);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          MaterialApp(
            theme: RoutexTheme.light,
            home: Scaffold(
              body: SingleChildScrollView(
                child: AlignmentRhythmFixture(
                  width: width,
                  textScale: textScale,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('저장한 장소'), findsOneWidget);
        expect(find.text('지도에서 현재 위치 직접 지정'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
