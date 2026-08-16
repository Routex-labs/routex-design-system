import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_design_system/routex_design_system.dart';
import 'package:showcase/src/data/showcase_place_detail_data.dart';

/// 상세 내용은 Navigation 백엔드에서 옮겨 온 값이라, 여기서 지키는 것은 "값이
/// 그대로 화면까지 닿는가"다. 사진 경로가 하나라도 어긋나면 캐러셀이 조용히
/// 자리표시로 떨어지므로, 그 사실을 눈이 아니라 test가 먼저 알아야 한다.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const detail = ShowcasePlaceDetail.osulloc;

  test('대표 사진과 메뉴 사진이 실제로 번들에 들어 있다', () async {
    final assets = [
      ...detail.heroAssets,
      for (final item in detail.menu)
        if (item.imageAsset != null) item.imageAsset!,
    ];
    expect(assets, isNotEmpty);

    for (final asset in assets) {
      final bytes = await rootBundle.load(asset);
      expect(
        bytes.lengthInBytes,
        greaterThan(0),
        reason: '$asset 이(가) pubspec의 assets에 없거나 파일이 비어 있다',
      );
    }
  });

  test('번들에 있는 사진만 화면에 걸린다', () {
    expect(showcaseMediaItem(detail.heroAssets.first), isNotNull);
    expect(
      showcaseMediaItem('assets/place_details/does-not-exist.webp'),
      isNull,
      reason: '없는 사진을 다른 사진으로 바꿔치기하지 않는다',
    );
  });

  group('영업 상태 판정', () {
    test('영업 시간 안이면 종료 시각을 말한다', () {
      // 2026-08-18은 화요일. 화요일은 10:30-20:00이다.
      final status = showcaseHoursStatus(
        detail.hours,
        DateTime(2026, 8, 18, 14, 30),
      );
      expect(status.state, RoutexHoursState.open);
      expect(status.detail, '20:00 종료');
    });

    test('폐점 정각은 닫힌 것으로 본다', () {
      final status = showcaseHoursStatus(
        detail.hours,
        DateTime(2026, 8, 18, 20),
      );
      expect(status.state, RoutexHoursState.closed);
      expect(status.detail, '내일 10:30 영업 시작');
    });

    test('여는 시각 전이면 오늘 여는 시각을 말한다', () {
      final status = showcaseHoursStatus(
        detail.hours,
        DateTime(2026, 8, 18, 9),
      );
      expect(status.state, RoutexHoursState.closed);
      expect(status.detail, '10:30 영업 시작');
    });

    test('요일 표는 오늘부터 이레를 세운다', () {
      final week = showcaseHoursWeek(
        detail.hours,
        DateTime(2026, 8, 18, 14, 30),
      );
      expect(week, hasLength(7));
      expect(week.first.label, '화');
      expect(week.first.value, '10:30 - 20:00');
      expect(week[3].label, '금');
      expect(week[3].value, '10:30 - 20:30');
    });
  });
}
