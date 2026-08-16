import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_design_system/routex_design_system.dart';

import 'support/wcag_contrast.dart';

/// 색 역할이 늘어날 때 제일 먼저 조용히 어긋나는 것이 대비다.
///
/// 색을 고를 때는 나란히 놓고 보지만, 실제로 겹치는 조합은 컴포넌트 안에서 정해진다.
/// 그래서 "무엇이 무엇 위에 올라가는가"를 여기에 쌍으로 적어 두고 값으로 검증한다.
/// 새 색을 들일 때 이 목록에 쌍을 추가하는 것이 곧 그 색을 어디에 쓸지 정하는 일이다.
///
/// 기준은 WCAG 2.x AA다.
///   글자          4.5:1  (본문 크기. 이 시스템의 제품 UI 글자는 전부 여기 해당한다.
///                        3:1로 낮아지는 "큰 글자"는 24px 이상 또는 18.66px 이상
///                        Bold인데, display(28/w800)와 headline(22/w700)만 해당하고
///                        둘 다 문서용 제목이다. title(18/w700)은 0.66px 모자란다.)
///   비텍스트      3:1    (아이콘, 컨트롤 경계, 상태 표시)
///   비활성·장식   면제
void main() {
  const colors = RoutexColorTokens.light;

  // 글자가 실제로 올라가는 자리다. 배경은 그 글자가 놓이는 표면이고, 겹치는 조합만
  // 적는다. 예를 들어 contentPrimary는 선택된 목록·경로 카드에서 actionPrimarySubtle
  // 위에도 올라간다.
  // 글자가 놓이는 표면들이다. surfaceBase와 surfaceRaised는 light에서 값이 같지만
  // 테마가 늘면 갈라지므로 따로 잰다.
  final surfaces = <(String, Color)>[
    ('기본 표면', colors.surfaceBase),
    ('올라온 표면', colors.surfaceRaised),
    ('지도 바탕', colors.surfaceCanvas),
  ];

  group('글자가 닿는 색은 4.5:1을 넘는다', () {
    for (final (name, foreground, background) in [
      // 표면 위에 그대로 놓이는 글자.
      for (final (surface, background) in surfaces) ...[
        ('본문 · $surface', colors.contentPrimary, background),
        ('보조 · $surface', colors.contentSecondary, background),
        ('강조 글자 · $surface', colors.actionPrimary, background),
        ('안내 글자 · $surface', colors.statusInfo, background),
        ('성공 글자 · $surface', colors.statusSuccess, background),
        ('주의 글자 · $surface', colors.statusWarning, background),
        ('오류 글자 · $surface', colors.statusError, background),
      ],
      // 선택된 목록·경로 카드·층 버튼은 옅은 강조 배경 위에 글자를 얹는다.
      ('본문 · 선택된 행', colors.contentPrimary, colors.actionPrimarySubtle),
      ('보조 · 선택된 행', colors.contentSecondary, colors.actionPrimarySubtle),
      ('강조 글자 · 선택된 행', colors.actionPrimary, colors.actionPrimarySubtle),
      // 색으로 채운 자리에 얹는 흰 글자.
      ('버튼 글자', colors.contentInverse, colors.actionPrimary),
      ('버튼 글자 · 눌림', colors.contentInverse, colors.actionPrimaryPressed),
      ('삭제 버튼 글자', colors.contentInverse, colors.statusError),
      // 어두운 표면 위의 흰 글자. 알림·토스트와 사진 위 카운터가 같은 쌍을 쓴다 —
      // 사진 위에서는 반투명 scrim 대신 이 불투명 표면을 깔아야 대비가 사진에
      // 좌우되지 않는다.
      ('알림 글자', colors.contentInverse, colors.contentPrimary),
      // 알림 배경 위의 같은 계열 글자.
      ('안내 글자 · 안내 배경', colors.statusInfo, colors.statusInfoSubtle),
      ('성공 글자 · 성공 배경', colors.statusSuccess, colors.statusSuccessSubtle),
      ('주의 글자 · 주의 배경', colors.statusWarning, colors.statusWarningSubtle),
      ('오류 글자 · 오류 배경', colors.statusError, colors.statusErrorSubtle),
    ]) {
      test(name, () {
        expect(
          contrastRatio(foreground, background),
          greaterThanOrEqualTo(4.5),
          reason: '$name의 대비가 본문 글자 기준에 못 미친다',
        );
      });
    }
  });

  // 글자는 아니지만 "여기가 무엇이고 어떤 상태인가"를 혼자 전하는 것들이다.
  // secondary 버튼의 테두리가 대표적이다. 그 선이 사라지면 버튼인지 알 수 없다.
  group('글자가 닿지 않는 그래픽은 3:1을 넘는다', () {
    for (final (name, foreground, background) in [
      for (final (surface, background) in surfaces) ...[
        ('컨트롤 경계 · $surface', colors.borderStrong, background),
        ('초점 표시 · $surface', colors.focusRing, background),
        ('강조 아이콘 · $surface', colors.actionPrimary, background),
        ('브랜드 선 · $surface', colors.accentBrand, background),
      ],
      ('초점 표시 · 선택된 행', colors.focusRing, colors.actionPrimarySubtle),
      ('강조 아이콘 · 선택된 행', colors.actionPrimary, colors.actionPrimarySubtle),
      // 선택된 칩·이동수단·경로 카드의 테두리다. 선택을 전하는 것이 이 선이라
      // 3:1을 넘지 못하면 무엇이 선택됐는지 알 수 없다.
      ('브랜드 선 · 선택된 행', colors.accentBrand, colors.actionPrimarySubtle),
    ]) {
      test(name, () {
        expect(
          contrastRatio(foreground, background),
          greaterThanOrEqualTo(3),
          reason: '$name의 대비가 비텍스트 기준에 못 미친다',
        );
      });
    }
  });

  // 분류색은 도면 위 넓은 면을 칠하려고 고른 파스텔이라 원색으로는 흰 배경에서
  // 1.80~2.46밖에 안 나온다. 칩 글자·테두리에 쓰는 ink는 같은 색상을 유지하면서
  // 대비만 확보한 짝이다. 분류를 더할 때 원색만 넣고 ink를 빠뜨리면 여기서 걸린다.
  group('분류 고유색은 제 tint 위에서 글자 기준을 넘는다', () {
    for (final category in RoutexCategoryTokens.categories) {
      test(category, () {
        final ink = RoutexCategoryTokens.inkFor(category);

        expect(
          contrastRatio(ink, RoutexCategoryTokens.surfaceFor(category)),
          greaterThanOrEqualTo(4.5),
          reason: '선택된 $category 칩의 글자가 제 배경 위에서 읽히지 않는다',
        );
        expect(
          contrastRatio(ink, colors.surfaceRaised),
          greaterThanOrEqualTo(4.5),
          reason: '선택되지 않은 $category 칩의 아이콘이 흰 표면에서 읽히지 않는다',
        );
        // 테두리는 카드 바탕 위에 놓인다. 3:1을 못 넘으면 선택이 안 보인다.
        expect(
          contrastRatio(ink, colors.surfaceCanvas),
          greaterThanOrEqualTo(3),
          reason: '$category 선택 테두리가 지도 바탕에서 보이지 않는다',
        );
      });
    }

    // 아이콘에 쓰는 원색은 기준을 못 넘는 게 정상이다. 분류 이름이 늘 바로 옆에
    // 적혀 있어 아이콘이 뜻을 혼자 지지 않으므로, 보조 그래픽으로서 면제된다.
    // (WCAG 1.4.11은 정보를 이해하는 데 그 표현이 본질적인 그래픽을 예외로 둔다.
    //  분류를 색으로 구분하는 것이 목적이면 그 색이 곧 본질이다.)
    //
    // 이 test가 깨지면 원색이 진해진 게 아니라, 누군가 원색을 글자나 테두리처럼
    // 혼자 뜻을 지는 자리에 쓰기 시작한 것이다.
    test('아이콘 원색은 기준을 넘지 않는다', () {
      for (final category in RoutexCategoryTokens.categories) {
        expect(
          contrastRatio(
            RoutexCategoryTokens.colorFor(category),
            colors.surfaceRaised,
          ),
          lessThan(3),
          reason:
              '$category 원색이 기준을 넘었다면 도면용 파스텔이 아니게 된 것이다. '
              '글자·테두리에 쓸 색이 필요하면 inkFor를 쓴다',
        );
      }
    });

    test('모르는 분류도 같은 기준을 지킨다', () {
      const ink = RoutexCategoryTokens.fallbackInk;
      expect(
        contrastRatio(ink, RoutexCategoryTokens.fallbackSurface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrastRatio(ink, colors.surfaceRaised),
        greaterThanOrEqualTo(4.5),
      );
    });
  });

  // 면제되는 색은 기준을 못 넘는 게 정상이다. 다만 "면제라서 낮다"와 "그냥 낮다"는
  // 구분해야 하므로, 면제 색이 기준 미달이라는 사실 자체를 적어 둔다. 어느 날 이
  // test가 깨지면 면제 색이 밝아진 게 아니라 누군가 본문에 쓰기 시작한 것이다.
  group('면제되는 색은 기준을 넘지 않는다', () {
    test('비활성 글자는 본문 기준 아래에 머문다', () {
      expect(
        contrastRatio(colors.contentDisabled, colors.surfaceRaised),
        lessThan(4.5),
        reason: '비활성 글자가 본문만큼 진해지면 눌리는 것과 구분되지 않는다',
      );
    });

    // accentBrand는 "아직 안 쓴 색"이 아니라 "글자에 쓰면 안 되는 색"이다. 3:1은
    // 넘고 4.5는 못 넘는 그 사이에 있다는 것이 이 색의 정의다. 누군가 라벨이나
    // 버튼 채움에 쓰면 그 순간 대비가 무너지므로, 못 넘는다는 사실을 못박아 둔다.
    test('브랜드 초록은 글자 기준에 닿지 않는다', () {
      for (final (surface, background) in surfaces) {
        expect(
          contrastRatio(colors.accentBrand, background),
          lessThan(4.5),
          reason:
              'accentBrand가 $surface에서 글자 기준을 넘었다면 포인트 초록의 밝은 단계가 '
              '아니게 된 것이다. '
              '글자에 쓸 색이 필요하면 actionPrimary를 쓴다',
        );
      }
    });

    test('구분선은 비텍스트 기준 아래에 머문다', () {
      // borderSubtle은 칸을 나누는 선일 뿐, 이것만으로 컨트롤을 식별하지 않는다.
      // 컨트롤 경계를 맡는 것은 borderStrong이고 그쪽은 위에서 3:1로 검증한다.
      expect(
        contrastRatio(colors.borderSubtle, colors.surfaceRaised),
        lessThan(3),
        reason: '구분선이 컨트롤 경계만큼 진하면 위계가 뒤집힌다',
      );
    });
  });
}
