import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:routex_design_system/routex_design_system.dart';

import 'showcase_navigation_data.dart';

/// Navigation의 `GET /buildings/{id}/places/{place_id}` 응답 중 Showcase가 쓰는
/// 섹션만 읽는 app-local adapter다. Runtime Kit package는 이 모델과 API를 알지 않는다.
///
/// **내용을 지어내지 않는다.** 여기 있는 값은 전부 Navigation 백엔드의 오설록
/// 매장 상세(`backend/resources/store_details/osulloc-thehyundai-seoul-b1.json`)에서
/// 온 것이다. 상세 컴포넌트는 사진·메뉴·영업시간처럼 "있는 매장과 없는 매장"이
/// 갈리는 값을 다루므로, 손으로 만든 예시로 검수하면 실제로 어떤 조합이 오는지를
/// 영영 못 본다.
class ShowcasePlaceDetail {
  const ShowcasePlaceDetail({
    required this.placeId,
    required this.name,
    required this.floorLabel,
    required this.category,
    required this.summary,
    required this.heroAssets,
    required this.menu,
    required this.businessInfo,
    required this.links,
    required this.hours,
    required this.sourceUrl,
    required this.updatedAt,
    required this.source,
  });

  final String placeId;
  final String name;
  final String floorLabel;
  final String category;
  final String summary;
  final List<String> heroAssets;
  final List<ShowcaseMenuItem> menu;
  final List<ShowcaseKeyValue> businessInfo;
  final List<ShowcaseLink> links;
  final ShowcaseHours hours;
  final String sourceUrl;
  final String updatedAt;
  final ShowcaseDataSource source;

  /// 메뉴 탭에 쓸 분류다. 등장 순서를 지킨다.
  List<String> get menuCategories => {
    for (final item in menu)
      if (item.category != null && item.category!.isNotEmpty) item.category!,
  }.toList();

  ShowcasePlaceDetail copyWith({ShowcaseDataSource? source}) =>
      ShowcasePlaceDetail(
        placeId: placeId,
        name: name,
        floorLabel: floorLabel,
        category: category,
        summary: summary,
        heroAssets: heroAssets,
        menu: menu,
        businessInfo: businessInfo,
        links: links,
        hours: hours,
        sourceUrl: sourceUrl,
        updatedAt: updatedAt,
        source: source ?? this.source,
      );

  /// 백엔드 응답에서 그대로 옮겨 온 고정 snapshot이다.
  ///
  /// 메뉴는 341종 중 분류마다 앞의 세 종만 남겼다. Showcase가 확인하려는 것은
  /// "줄이 어떻게 생겼고 접힘이 어떻게 도는가"이지 목록의 길이가 아니다.
  static const osulloc = ShowcasePlaceDetail(
    placeId: 'PO-H9ry1CZ6B8778',
    name: '오설록',
    floorLabel: 'B1',
    category: '식음료 · 카페',
    summary:
        '1979년, 돌과 바람이 전부였던 제주의 땅에서 시작해 최고의 차를 생산하기까지, '
        '오설록의 차가 특별한 이유를 만나보세요.',
    heroAssets: [
      'assets/place_details/osulloc_store_osl_stdd_st_1_2_bg_pc.webp',
      'assets/place_details/osulloc_store_osl_stdd_st_1_3_bg_pc.webp',
      'assets/place_details/osulloc_store_osl_stdd_st_1_bg_pc.webp',
      'assets/place_details/osulloc_store_tea_field_product_1.webp',
    ],
    menu: [
      ShowcaseMenuItem(
        name: '[미피] 위크엔드 티 타임 세트 8종 32입',
        category: '티',
        price: '37,000원',
        badges: ['NEW'],
        imageAsset:
            'assets/place_details/osulloc_menu_1000_20260706095023281vx.webp',
      ),
      ShowcaseMenuItem(
        name: '[미피] 쿨말차 티타임 세트',
        category: '티',
        price: '86,000원',
        badges: ['NEW'],
        imageAsset:
            'assets/place_details/osulloc_menu_1000_20260707164730694kz.webp',
      ),
      ShowcaseMenuItem(
        name: '[미피] 랑드샤 티타임 세트',
        category: '티',
        price: '114,000원',
        badges: ['NEW'],
        imageAsset:
            'assets/place_details/osulloc_menu_1000_20260707164753102vj.webp',
      ),
      ShowcaseMenuItem(
        name: '[미피] 스윗 티 밀크 스프레드 세트',
        category: '티푸드',
        price: '29,000원',
        badges: ['NEW'],
        imageAsset:
            'assets/place_details/osulloc_menu_1000_20260703094145431sj.webp',
      ),
      ShowcaseMenuItem(
        name: '[미피] 그린티 딸기 랑드샤',
        category: '티푸드',
        price: '14,000원',
        badges: ['NEW'],
        imageAsset:
            'assets/place_details/osulloc_menu_1000_20260707165132041tb.webp',
      ),
      ShowcaseMenuItem(
        name: '그린티 웨하스',
        category: '티푸드',
        price: '6,000원',
        imageAsset:
            'assets/place_details/osulloc_menu_1000_20241213190846014jp.webp',
      ),
      ShowcaseMenuItem(
        name: '오 말차 쉐이커',
        category: '라이프스타일',
        price: '9,000원',
        imageAsset:
            'assets/place_details/osulloc_menu_1000_20260714102454797up.webp',
      ),
      ShowcaseMenuItem(
        name: '말차 스푼',
        category: '라이프스타일',
        price: '9,000원',
        imageAsset:
            'assets/place_details/osulloc_menu_1000_20260428165150049wz.webp',
      ),
      ShowcaseMenuItem(
        name: '[미피] 양우산',
        category: '라이프스타일',
        price: '35,000원',
        imageAsset:
            'assets/place_details/osulloc_menu_1000_20260713170112628nb.webp',
      ),
    ],
    businessInfo: [
      ShowcaseKeyValue(label: '주소', value: '서울시 영등포구 여의대로 108 지하1층'),
    ],
    links: [
      ShowcaseLink(label: '공식 사이트', url: 'https://www.osulloc.com/kr/ko'),
      ShowcaseLink(
        label: '인스타그램',
        url: 'https://www.instagram.com/osulloc_official/',
      ),
      ShowcaseLink(
        label: '유튜브',
        url: 'https://www.youtube.com/channel/UC27q_WWuOkdyNIr7M_6trvA',
      ),
      ShowcaseLink(label: '네이버 브랜드스토어', url: 'https://brand.naver.com/osulloc'),
    ],
    hours: ShowcaseHours(
      weekly: {
        DateTime.monday: [ShowcaseHoursInterval('10:30', '20:00')],
        DateTime.tuesday: [ShowcaseHoursInterval('10:30', '20:00')],
        DateTime.wednesday: [ShowcaseHoursInterval('10:30', '20:00')],
        DateTime.thursday: [ShowcaseHoursInterval('10:30', '20:00')],
        DateTime.friday: [ShowcaseHoursInterval('10:30', '20:30')],
        DateTime.saturday: [ShowcaseHoursInterval('10:30', '20:30')],
        DateTime.sunday: [ShowcaseHoursInterval('10:30', '20:30')],
      },
      confirmedAt: '2026-08-13',
      sourceUrl: 'https://www.osulloc.com/kr/ko/store-introduction',
    ),
    sourceUrl: 'https://www.osulloc.com/kr/ko/brandstory',
    updatedAt: '2026-08-13',
    source: ShowcaseDataSource.snapshot,
  );
}

class ShowcaseMenuItem {
  const ShowcaseMenuItem({
    required this.name,
    this.category,
    this.price,
    this.badges = const <String>[],
    this.imageAsset,
  });

  final String name;
  final String? category;
  final String? price;
  final List<String> badges;
  final String? imageAsset;
}

class ShowcaseKeyValue {
  const ShowcaseKeyValue({required this.label, required this.value});

  final String label;
  final String value;
}

class ShowcaseLink {
  const ShowcaseLink({required this.label, required this.url});

  final String label;
  final String url;
}

class ShowcaseHoursInterval {
  const ShowcaseHoursInterval(this.open, this.close);

  /// `"HH:MM"` 24시간 표기다.
  final String open;
  final String close;

  int get openMinutes => _minutes(open);

  /// 닫는 시각이 여는 시각보다 이르면 자정을 넘긴 것이다.
  int get closeMinutes {
    final value = _minutes(close);
    return value <= openMinutes ? value + 24 * 60 : value;
  }

  static int _minutes(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return 0;
    return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
  }
}

class ShowcaseHours {
  const ShowcaseHours({
    required this.weekly,
    required this.confirmedAt,
    required this.sourceUrl,
  });

  /// `DateTime.monday`(1)~`DateTime.sunday`(7) 키다.
  final Map<int, List<ShowcaseHoursInterval>> weekly;
  final String confirmedAt;
  final String sourceUrl;
}

/// 지금 영업 중인지와 다음 전환을 계산한다.
///
/// **위젯이 아니라 여기서 판정한다.** `RoutexHours`는 결과를 문장으로 바꾸기만
/// 하므로, 폐점 정각·자정 넘김 같은 경계는 화면 없이 이 함수로 확인할 수 있다.
({RoutexHoursState state, String? detail}) showcaseHoursStatus(
  ShowcaseHours hours,
  DateTime now,
) {
  final minutesNow = now.hour * 60 + now.minute;
  final today = hours.weekly[now.weekday] ?? const <ShowcaseHoursInterval>[];

  for (final interval in today) {
    if (minutesNow >= interval.openMinutes &&
        minutesNow < interval.closeMinutes) {
      return (
        state: RoutexHoursState.open,
        detail: '${_clock(interval.closeMinutes)} 종료',
      );
    }
  }

  // 오늘 남은 구간 → 이후 요일 순으로 다음 개점을 찾는다. 이레를 다 돌아도 없으면
  // 여는 날이 없는 매장이라 "언제 연다"를 말하지 않는다.
  for (final interval in today) {
    if (minutesNow < interval.openMinutes) {
      return (
        state: RoutexHoursState.closed,
        detail: '${_clock(interval.openMinutes)} 영업 시작',
      );
    }
  }
  for (var ahead = 1; ahead <= 7; ahead++) {
    final weekday = (now.weekday - 1 + ahead) % 7 + 1;
    final intervals = hours.weekly[weekday] ?? const <ShowcaseHoursInterval>[];
    if (intervals.isEmpty) continue;
    final label = ahead == 1 ? '내일' : _weekdayLabel(weekday);
    return (
      state: RoutexHoursState.closed,
      detail: '$label ${_clock(intervals.first.openMinutes)} 영업 시작',
    );
  }
  return (state: RoutexHoursState.closed, detail: null);
}

/// 오늘부터 이레를 `RoutexHours`가 그리는 줄로 바꾼다.
List<RoutexHoursDay> showcaseHoursWeek(ShowcaseHours hours, DateTime now) {
  return [
    for (var ahead = 0; ahead < 7; ahead++)
      () {
        final date = DateTime(now.year, now.month, now.day + ahead);
        final intervals =
            hours.weekly[date.weekday] ?? const <ShowcaseHoursInterval>[];
        return RoutexHoursDay(
          label: _weekdayLabel(date.weekday),
          value: intervals.isEmpty
              ? '휴무'
              : intervals
                    .map((interval) => '${interval.open} - ${interval.close}')
                    .join(' · '),
          closed: intervals.isEmpty,
        );
      }(),
  ];
}

String _weekdayLabel(int weekday) =>
    const ['월', '화', '수', '목', '금', '토', '일'][(weekday - 1) % 7];

String _clock(int minutes) {
  final normalized = minutes % (24 * 60);
  final hour = (normalized ~/ 60).toString().padLeft(2, '0');
  final minute = (normalized % 60).toString().padLeft(2, '0');
  return '$hour:$minute';
}

/// Showcase가 번들로 가진 사진만 실제로 그린다.
///
/// 사진은 Navigation 앱이 번들로 들고 있고, Showcase는 상세 컴포넌트를 검수할 만큼만
/// 복사해 둔다. 백엔드가 여기 없는 경로를 내려주면 `RoutexMediaCarousel`이 자리표시로
/// 떨어진다 — 없는 사진을 다른 사진으로 바꿔치기하지 않는다.
RoutexMediaItem? showcaseMediaItem(String assetPath, {String? semanticLabel}) {
  if (!_bundledAssets.contains(assetPath)) return null;
  return RoutexMediaItem(
    image: AssetImage(assetPath),
    semanticLabel: semanticLabel,
  );
}

final _bundledAssets = {
  ...ShowcasePlaceDetail.osulloc.heroAssets,
  for (final item in ShowcasePlaceDetail.osulloc.menu)
    if (item.imageAsset != null) item.imageAsset!,
};

class ShowcasePlaceDetailSource {
  ShowcasePlaceDetailSource({http.Client? client})
    : _client = client ?? http.Client();

  static const _apiBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const _buildingId = 'thehyundai-seoul';

  final http.Client _client;

  /// 실제 앱과 같은 endpoint를 쓰되, 네트워크·CORS·계약 오류는 화면을 막지 않고
  /// Navigation에서 옮겨 온 snapshot으로 되돌린다.
  Future<ShowcasePlaceDetail> loadDetail() async {
    const snapshot = ShowcasePlaceDetail.osulloc;
    if (_apiBaseUrl.isEmpty) return snapshot;
    try {
      final response = await _client.get(
        Uri.parse(
          '$_apiBaseUrl/buildings/$_buildingId/places/${snapshot.placeId}',
        ),
      );
      if (response.statusCode != 200) return snapshot;
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      if (body is! Map<String, dynamic>) return snapshot;
      final sections = body['sections'];
      if (sections is! List) return snapshot;

      final parsed = _parseSections(sections.whereType<Map<String, dynamic>>());
      return ShowcasePlaceDetail(
        placeId: snapshot.placeId,
        name: body['name'] as String? ?? snapshot.name,
        floorLabel:
            (body['location'] as Map<String, dynamic>?)?['floor_label']
                as String? ??
            snapshot.floorLabel,
        category: snapshot.category,
        summary: parsed.summary ?? snapshot.summary,
        heroAssets: parsed.heroAssets ?? snapshot.heroAssets,
        menu: parsed.menu ?? snapshot.menu,
        businessInfo: parsed.businessInfo ?? snapshot.businessInfo,
        links: parsed.links ?? snapshot.links,
        hours: parsed.hours ?? snapshot.hours,
        sourceUrl: snapshot.sourceUrl,
        updatedAt:
            (body['provenance'] as Map<String, dynamic>?)?['updated_at']
                as String? ??
            snapshot.updatedAt,
        source: ShowcaseDataSource.backend,
      );
    } catch (_) {
      return snapshot;
    }
  }
}

typedef _ParsedSections = ({
  String? summary,
  List<String>? heroAssets,
  List<ShowcaseMenuItem>? menu,
  List<ShowcaseKeyValue>? businessInfo,
  List<ShowcaseLink>? links,
  ShowcaseHours? hours,
});

/// 모르는 `type`은 조용히 건너뛴다. 서버가 섹션을 늘려도 Showcase가 깨지지 않는
/// 것이 백엔드 계약의 규칙이다.
_ParsedSections _parseSections(Iterable<Map<String, dynamic>> sections) {
  String? summary;
  List<String>? heroAssets;
  List<ShowcaseMenuItem>? menu;
  List<ShowcaseKeyValue>? businessInfo;
  List<ShowcaseLink>? links;
  ShowcaseHours? hours;

  for (final section in sections) {
    final items = section['items'];
    switch (section['type']) {
      case 'summary':
        summary = section['text'] as String?;
      case 'hero' when items is List:
        heroAssets = [
          for (final item in items.whereType<Map<String, dynamic>>())
            if (item['local_asset'] case final String asset) asset,
        ];
      case 'menu' when items is List:
        menu = [
          for (final item in items.whereType<Map<String, dynamic>>())
            ShowcaseMenuItem(
              name: item['name'] as String? ?? '',
              category: item['category'] as String?,
              price: item['price'] as String?,
              badges: [...?(item['badges'] as List?)?.whereType<String>()],
              imageAsset: item['image_asset'] as String?,
            ),
        ];
      case 'businessInfo' when items is List:
        businessInfo = [
          for (final item in items.whereType<Map<String, dynamic>>())
            ShowcaseKeyValue(
              label: item['label'] as String? ?? '',
              value: item['value'] as String? ?? '',
            ),
        ];
      case 'links' when items is List:
        links = [
          for (final item in items.whereType<Map<String, dynamic>>())
            ShowcaseLink(
              label: item['label'] as String? ?? '',
              url: item['url'] as String? ?? '',
            ),
        ];
      case 'hours':
        hours = _parseHours(section);
    }
  }

  return (
    summary: summary,
    heroAssets: heroAssets,
    menu: menu,
    businessInfo: businessInfo,
    links: links,
    hours: hours,
  );
}

ShowcaseHours? _parseHours(Map<String, dynamic> section) {
  final weekly = section['weekly'];
  if (weekly is! Map) return null;
  const keys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
  final parsed = <int, List<ShowcaseHoursInterval>>{};
  for (var index = 0; index < keys.length; index++) {
    final raw = weekly[keys[index]];
    parsed[index + 1] = [
      for (final interval in (raw is List ? raw : const []))
        if (interval is Map &&
            interval['open'] is String &&
            interval['close'] is String)
          ShowcaseHoursInterval(
            interval['open'] as String,
            interval['close'] as String,
          ),
    ];
  }
  return ShowcaseHours(
    weekly: parsed,
    confirmedAt: section['confirmed_at'] as String? ?? '',
    sourceUrl: section['source'] as String? ?? '',
  );
}
