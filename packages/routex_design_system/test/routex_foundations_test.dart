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
}
