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

    test('stroke·measure·opacity·optical correction 계약이 기존 시각 값을 보존한다', () {
      expect(RoutexStroke.hairline, 1);
      expect(RoutexStroke.emphasis, 2);
      expect(RoutexContentMeasure.scrollableOption, 240);
      expect(RoutexContentMeasure.dialog, 360);
      expect(RoutexOpacity.subtleOutline, 0.24);
      expect(RoutexOpacity.sheetHandle, 0.55);
      expect(RoutexProportion.shortLine, 0.45);
      expect(RoutexProportion.longLine, 0.6);
      expect(RoutexProportion.largeSheet, 0.75);
      expect(RoutexOpticalCorrection.listTitleGlyphTop, 4);
      expect(RoutexOpticalCorrection.sheetHeaderGlyph, 2);
      expect(RoutexTypography.scrollLayoutTextScale, 1.3);
      expect(RoutexMotion.disclosureExpandedTurns, 0.5);
      expect(
        RoutexFeedbackTiming.toastVisibility,
        const Duration(milliseconds: 1600),
      );
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

    // 대비는 routex_contrast_test.dart가 소유한다. 글자 4.5:1과 비텍스트 3:1을
    // 나눠 재야 해서 검증할 쌍이 여기 담기엔 많아졌다.

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

    test('지도 시각 catalog가 도면·경로·마커 역할을 모두 해석한다', () {
      for (final role in RoutexMapVisualRole.values) {
        expect(role.resolve(), isA<Color>(), reason: role.name);
      }
      expect(
        RoutexMapVisualRole.routeLine.resolve(),
        RoutexMapVisualTokens.routeLine,
      );
      expect(
        RoutexMapVisualRole.canvasOutdoor.resolve(),
        RoutexMapVisualTokens.canvasOutdoor,
      );
    });

    test('bodySmall은 굵은 label과 구분되는 14/400 보조 본문이다', () {
      expect(RoutexTypography.bodySmall.fontSize, 14);
      expect(RoutexTypography.bodySmall.fontWeight, FontWeight.w400);
      expect(RoutexTypography.bodySmall.height, 20 / 14);
      expect(RoutexTypography.label.fontSize, 14);
      expect(RoutexTypography.label.fontWeight, FontWeight.w600);
      expect(
        RoutexTypographyRole.bodySmall.textStyle,
        RoutexTypography.bodySmall,
      );
    });

    test('tabular은 크기·굵기를 유지한 채 고정폭 숫자만 켠다', () {
      final numeric = RoutexTypography.tabular(RoutexTypography.title);
      expect(numeric.fontSize, RoutexTypography.title.fontSize);
      expect(numeric.fontWeight, RoutexTypography.title.fontWeight);
      expect(numeric.height, RoutexTypography.title.height);
      expect(
        numeric.fontFeatures,
        contains(const FontFeature.tabularFigures()),
      );
      expect(RoutexTypography.title.fontFeatures, isNull);
    });
  });

  testWidgets('실시간으로 바뀌는 수치는 고정폭 숫자로 표시한다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: RoutexTheme.light,
        home: Scaffold(
          body: Column(
            children: [
              const RoutexManeuverBanner(
                distance: '120m 후 건물로 진입',
                detail: '더현대 서울 1층 · 명품관 방향',
                icon: RoutexIcons.turnRight,
              ),
              RoutexRouteOption(
                title: '6분',
                detail: '410m · 실내 연결 통로',
                meta: '추천',
                selected: true,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );

    for (final value in ['120m 후 건물로 진입', '6분', '410m · 실내 연결 통로']) {
      expect(
        tester.widget<Text>(find.text(value)).style?.fontFeatures,
        contains(const FontFeature.tabularFigures()),
        reason: value,
      );
    }
  });

  group('한글 줄바꿈', () {
    test('어절 안 음절을 word joiner로 묶어 공백에서만 끊기게 한다', () {
      const joiner = '\u2060';
      expect(
        RoutexTypography.keepWordsWhole('여의대로 108'),
        '여$joiner의$joiner대$joiner로 108',
      );
    });

    test('한 줄보다 긴 어절은 손대지 않는다', () {
      const long = '더현대서울지하일층식품관오설록매장입니다';
      expect(RoutexTypography.keepWordsWhole(long), long);
    });

    test('한 글자 어절과 숫자·영문 어절은 손대지 않는다', () {
      // 보이지 않는 글자를 전화번호에 심으면 복사한 값이 원본과 달라진다.
      expect(
        RoutexTypography.keepWordsWhole('B1 층 1522-3232'),
        'B1 층 1522-3232',
      );
    });
  });
}
