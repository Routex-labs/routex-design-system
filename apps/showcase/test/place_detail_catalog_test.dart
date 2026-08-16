import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_design_system/routex_design_system.dart';
import 'package:showcase/src/catalog/place_detail_catalog.dart';
import 'package:showcase/src/data/showcase_place_detail_data.dart';

void main() {
  const detail = ShowcasePlaceDetail.osulloc;

  testWidgets('상세 헤더는 보행 시간을 반복하지 않고 주소 복사 대신 공유한다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: RoutexTheme.light,
        home: const Scaffold(
          body: SingleChildScrollView(
            child: PlaceDetailHeaderCard(detail: detail),
          ),
        ),
      ),
    );

    expect(find.text('B1 · 식음료 · 카페'), findsOneWidget);
    expect(find.textContaining('도보 3분'), findsNothing);
    expect(find.byTooltip('장소 공유'), findsOneWidget);
  });

  testWidgets('주소는 사실로 표시하되 복사 action을 만들지 않는다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: RoutexTheme.light,
        home: Scaffold(
          body: PlaceFactsCard(
            detail: detail,
            now: DateTime(2026, 8, 18, 14, 30),
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('주소, 서울시 영등포구 여의대로 108 지하1층'), findsOneWidget);
    expect(find.text('복사'), findsNothing);
  });

  testWidgets('신상품은 속성 필터와 원래 분류에 함께 있고 필터 안에서 배지를 반복하지 않는다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: RoutexTheme.light,
        home: const Scaffold(
          body: SingleChildScrollView(child: PlaceMenuCard(detail: detail)),
        ),
      ),
    );

    expect(find.text('전체'), findsOneWidget);
    expect(find.text('신상품'), findsOneWidget);
    expect(find.text('티'), findsOneWidget);
    expect(find.text('NEW'), findsWidgets);

    await tester.tap(find.text('신상품'));
    await tester.pump();
    expect(find.text('[미피] 위크엔드 티 타임 세트 8종 32입'), findsOneWidget);
    await tester.tap(find.textContaining('개 더보기'));
    await tester.pump();
    expect(find.text('[미피] 스윗 티 밀크 스프레드 세트'), findsOneWidget);
    expect(find.text('NEW'), findsNothing);

    await tester.tap(find.text('티푸드'));
    await tester.pump();
    expect(find.text('[미피] 스윗 티 밀크 스프레드 세트'), findsOneWidget);
    expect(find.text('NEW'), findsWidgets);
    expect(find.text('그린티 웨하스'), findsOneWidget);
  });
}
