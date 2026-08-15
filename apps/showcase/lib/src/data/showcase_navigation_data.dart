import 'dart:convert';

import 'package:http/http.dart' as http;

/// Navigation의 `GET /buildings/{id}/store-index` 응답에서 Showcase가 쓰는 필드만
/// 읽는 app-local adapter다. Runtime Kit package는 이 모델과 API를 알지 않는다.
class ShowcasePlaceData {
  const ShowcasePlaceData({
    required this.id,
    required this.name,
    required this.buildingId,
    required this.buildingName,
    required this.floorId,
    required this.floorName,
    required this.category,
    required this.subcategory,
    required this.entranceNodeId,
    required this.source,
  });

  final String id;
  final String name;
  final String buildingId;
  final String buildingName;
  final String floorId;
  final String floorName;
  final String category;
  final String? subcategory;
  final String? entranceNodeId;
  final ShowcaseDataSource source;

  static const navigationSnapshot = ShowcasePlaceData(
    id: 'balenciaga-1f',
    name: '발렌시아가',
    buildingId: 'thehyundai-seoul',
    buildingName: '더현대 서울',
    floorId: '1F',
    floorName: '1F',
    category: '패션',
    subcategory: '명품',
    entranceNodeId: 'store-balenciaga-entrance',
    source: ShowcaseDataSource.snapshot,
  );

  ShowcasePlaceData copyWith({ShowcaseDataSource? source}) => ShowcasePlaceData(
    id: id,
    name: name,
    buildingId: buildingId,
    buildingName: buildingName,
    floorId: floorId,
    floorName: floorName,
    category: category,
    subcategory: subcategory,
    entranceNodeId: entranceNodeId,
    source: source ?? this.source,
  );
}

enum ShowcaseDataSource { backend, snapshot }

class ShowcaseNavigationDataSource {
  ShowcaseNavigationDataSource({http.Client? client})
    : _client = client ?? http.Client();

  static const _apiBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const _buildingId = 'thehyundai-seoul';

  final http.Client _client;

  /// 실제 앱과 같은 endpoint를 사용하되, 네트워크·CORS·계약 오류는 제품 목업을
  /// 막지 않고 Navigation에서 추출한 고정 snapshot으로 되돌린다.
  Future<ShowcasePlaceData> loadPlace() async {
    if (_apiBaseUrl.isEmpty) return ShowcasePlaceData.navigationSnapshot;
    try {
      final response = await _client.get(
        Uri.parse('$_apiBaseUrl/buildings/$_buildingId/store-index'),
      );
      if (response.statusCode != 200) {
        return ShowcasePlaceData.navigationSnapshot;
      }
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      if (body is! List) return ShowcasePlaceData.navigationSnapshot;
      final stores = body.whereType<Map<String, dynamic>>().where(
        (item) => item['kind'] == null || item['kind'] == 'store',
      );
      final selected = stores.cast<Map<String, dynamic>?>().firstWhere(
        (item) => item?['name'] == '발렌시아가',
        orElse: () => stores.isEmpty ? null : stores.first,
      );
      if (selected == null) return ShowcasePlaceData.navigationSnapshot;
      return ShowcasePlaceData(
        id: selected['id'] as String,
        name: selected['name'] as String,
        buildingId: _buildingId,
        buildingName: '더현대 서울',
        floorId: selected['floor_id'] as String,
        floorName: selected['floor_name'] as String,
        category: _categoryLabel(selected['category'] as String?),
        subcategory: selected['subcategory'] as String?,
        entranceNodeId: selected['entrance_node_id'] as String?,
        source: ShowcaseDataSource.backend,
      );
    } catch (_) {
      return ShowcasePlaceData.navigationSnapshot;
    }
  }
}

String _categoryLabel(String? category) => switch (category) {
  'fashion' => '패션',
  'beauty' => '뷰티',
  'food' => '식음료',
  'facility' => '생활편의',
  final value when value != null && value.isNotEmpty => value,
  _ => '매장',
};
