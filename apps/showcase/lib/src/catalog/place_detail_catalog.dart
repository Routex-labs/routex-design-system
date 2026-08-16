import 'package:flutter/material.dart';
import 'package:routex_design_system/routex_design_system.dart';

import '../data/showcase_place_detail_data.dart';

/// 매장 상세를 이루는 조각들을 Runtime Kit 컴포넌트로만 조립한다.
///
/// 컴포넌트 페이지와 한눈에 페이지가 **같은 조각**을 쓴다. 두 곳이 각자 조립하면
/// 같은 상세가 페이지마다 다른 모양이 되고, 그것이 v0.1이 고치기로 한 문제다.
/// 내용은 전부 Navigation 백엔드의 오설록 매장 상세에서 온다.
///
/// 판정 기준 시각을 밖에서 받는 이유는 영업 상태가 시각에 의존하기 때문이다 —
/// 위젯이 `DateTime.now`를 직접 부르면 골든이 시각마다 달라진다.
class PlaceDetailHeaderCard extends StatefulWidget {
  const PlaceDetailHeaderCard({required this.detail, super.key});

  final ShowcasePlaceDetail detail;

  @override
  State<PlaceDetailHeaderCard> createState() => _PlaceDetailHeaderCardState();
}

class _PlaceDetailHeaderCardState extends State<PlaceDetailHeaderCard> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    final detail = widget.detail;
    final hero = [
      for (final asset in detail.heroAssets)
        ?showcaseMediaItem(asset, semanticLabel: '${detail.name} 매장 사진'),
    ];

    return RoutexStack(
      gap: RoutexStackGap.content,
      children: [
        if (hero.isNotEmpty) RoutexMediaCarousel(items: hero),
        RoutexPlaceHeader(
          name: detail.name,
          metadata: '${detail.floorLabel} · ${detail.category}',
          saved: _saved,
          onShare: () => RoutexToast.show(context, '장소 공유 링크를 준비했습니다'),
          onSaved: (value) {
            setState(() => _saved = value);
            RoutexToast.show(context, value ? '장소에 저장했습니다' : '저장을 취소했습니다');
          },
        ),
        RoutexPlaceActions(onOrigin: () {}, onDestination: () {}),
        Text(detail.summary, style: RoutexTypography.body),
      ],
    );
  }
}

/// 영업시간과 사실 행. 두 값 모두 낡을 수 있어 확인일을 함께 보여 준다.
class PlaceFactsCard extends StatefulWidget {
  const PlaceFactsCard({required this.detail, required this.now, super.key});

  final ShowcasePlaceDetail detail;
  final DateTime now;

  @override
  State<PlaceFactsCard> createState() => _PlaceFactsCardState();
}

class _PlaceFactsCardState extends State<PlaceFactsCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final detail = widget.detail;
    final status = showcaseHoursStatus(detail.hours, widget.now);

    // 구분선이 이미 앞뒤로 한 구획씩 여백을 가진다. 여기에 stack gap을 더하면
    // 선 하나를 사이에 둔 두 묶음만 다른 묶음보다 멀어져 위계가 어긋난다. 묶음
    // 사이는 선이, 묶음 안은 stack이 맡는다.
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RoutexHours(
          state: status.state,
          detail: status.detail,
          days: showcaseHoursWeek(detail.hours, widget.now),
          expanded: _expanded,
          onExpanded: (value) => setState(() => _expanded = value),
          staleNote: '${detail.hours.confirmedAt} 기준 · 영업시간이 달라졌을 수 있어요',
        ),
        const RoutexDivider(),
        RoutexStack(
          gap: RoutexStackGap.content,
          children: [
            for (final item in detail.businessInfo)
              RoutexInfoRow(
                label: item.label,
                value: item.value,
                icon: showcaseInfoIcon(item.label),
              ),
            RoutexInfoRow(
              label: '정보 출처',
              value: detail.sourceUrl,
              caption: '${detail.updatedAt} 확인',
              icon: RoutexIcons.link,
            ),
          ],
        ),
      ],
    );
  }
}

/// 분류 탭과 판매 목록. 줄을 누르면 상세가 dialog로 열린다.
class PlaceMenuCard extends StatefulWidget {
  const PlaceMenuCard({required this.detail, super.key});

  final ShowcasePlaceDetail detail;

  @override
  State<PlaceMenuCard> createState() => _PlaceMenuCardState();
}

class _PlaceMenuCardState extends State<PlaceMenuCard> {
  static const _all = 'all';
  static const _new = 'new';

  String _filter = _all;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final categories = widget.detail.menuCategories;
    final items = [
      for (final item in widget.detail.menu)
        if (_filter == _all ||
            (_filter == _new && item.badges.contains('NEW')) ||
            item.category == _filter)
          item,
    ];

    return RoutexStack(
      gap: RoutexStackGap.content,
      children: [
        const RoutexSectionHeader(title: '판매 항목'),
        if (categories.length > 1)
          RoutexChipBar(
            semanticsLabel: '메뉴 분류',
            options: [
              const RoutexChipOption(id: _all, label: '전체'),
              const RoutexChipOption(id: _new, label: '신상품'),
              for (final category in categories)
                RoutexChipOption(id: category, label: category),
            ],
            selectedId: _filter,
            onSelected: (value) {
              if (value == null) return;
              setState(() {
                _filter = value;
                _expanded = false;
              });
            },
          ),
        RoutexMenuList(
          collapsedCount: 3,
          expanded: _expanded,
          onExpanded: (value) => setState(() => _expanded = value),
          entries: [
            for (final item in items)
              RoutexMenuEntry(
                name: item.name,
                price: item.price,
                thumbnail: item.imageAsset == null
                    ? null
                    : showcaseMediaItem(
                        item.imageAsset!,
                        semanticLabel: item.name,
                      ),
                badges: [
                  for (final badge in item.badges)
                    if (!(_filter == _new && badge == 'NEW'))
                      RoutexBadge(
                        label: badge,
                        accent: showcaseBadgeAccent(badge),
                      ),
                ],
                // 가격 말고는 더 볼 것이 없는 항목이 있다. 눌러도 줄에 이미 있는
                // 값만 나오는 팝업은 막다른 길이다.
                selectable: item.price != null,
              ),
          ],
          onSelected: (index) => showRoutexDialog(
            context: context,
            dialog: RoutexDialog(
              title: items[index].name,
              facts: [
                if (items[index].category case final category?)
                  RoutexKeyValue(label: '분류', value: category),
                if (items[index].price case final price?)
                  RoutexKeyValue(label: '가격', value: price),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 공식 채널 링크. 여는 일은 소비 앱 몫이고, 실패는 토스트가 말한다.
class PlaceLinksCard extends StatelessWidget {
  const PlaceLinksCard({required this.detail, super.key});

  final ShowcasePlaceDetail detail;

  @override
  Widget build(BuildContext context) {
    return RoutexStack(
      gap: RoutexStackGap.content,
      children: [
        const RoutexSectionHeader(title: '공식 채널'),
        RoutexLinkList(
          items: [
            for (final link in detail.links)
              RoutexLinkItem(
                label: link.label,
                url: link.url,
                display: showcaseIsWebsite(link.label)
                    ? RoutexLinkDisplay.url
                    : RoutexLinkDisplay.label,
                accent: showcaseLinkAccent(link.label),
              ),
          ],
          // Showcase는 외부 앱을 열지 않는다. 열기가 실패했을 때 사용자가 무엇을
          // 보게 되는지를 같은 컴포넌트로 보여 준다.
          onSelected: (item) =>
              RoutexToast.show(context, '${item.label}을(를) 열지 못했습니다'),
        ),
      ],
    );
  }
}

/// 사진 탭. 캐러셀과 같은 사진을 격자로 늘어놓는다.
class PlacePhotosCard extends StatelessWidget {
  const PlacePhotosCard({required this.detail, super.key});

  final ShowcasePlaceDetail detail;

  @override
  Widget build(BuildContext context) {
    final photos = [
      for (final asset in detail.heroAssets)
        ?showcaseMediaItem(asset, semanticLabel: '${detail.name} 매장 사진'),
    ];
    if (photos.isEmpty) {
      return const RoutexEmptyState(
        title: '사진 없음',
        description: '이 매장은 등록된 사진이 없습니다.',
        icon: RoutexIcons.image,
      );
    }
    return RoutexStack(
      gap: RoutexStackGap.content,
      children: [
        const RoutexSectionHeader(title: '사진'),
        RoutexPhotoGrid(items: photos),
      ],
    );
  }
}

/// 라벨을 대신할 수 있는 글리프만 고른다.
///
/// 모르는 라벨에 아무 아이콘이나 붙이지 않는다. 아이콘이 라벨을 대신할 수 있는 것은
/// 그 아이콘이 라벨을 정확히 가리킬 때뿐이고, 그렇지 않으면 값의 뜻이 화면에서
/// 사라진다. 어떤 라벨이 오는지는 데이터를 아는 소비 앱만 안다.
IconData? showcaseInfoIcon(String label) => switch (label.replaceAll(' ', '')) {
  '주소' || '위치' => RoutexIcons.placeLocation,
  '영업시간' || '운영시간' => RoutexIcons.schedule,
  '홈페이지' || '웹사이트' => RoutexIcons.link,
  _ => null,
};

/// 라벨이 곧 정체인 채널인지.
bool showcaseIsWebsite(String label) => switch (label.replaceAll(' ', '')) {
  '공식사이트' || '홈페이지' || '웹사이트' => true,
  _ => false,
};

/// 브랜드 색만 가져오고 로고 파일은 담지 않는다.
RoutexLinkAccent? showcaseLinkAccent(String label) =>
    switch (label.replaceAll(' ', '')) {
      '공식사이트' || '홈페이지' || '웹사이트' => const RoutexLinkAccent(
        icon: Icons.public,
        colors: [Color(0xFF3C4043)],
      ),
      '인스타그램' => const RoutexLinkAccent(
        icon: Icons.camera_alt,
        colors: [Color(0xFFF58529), Color(0xFFDD2A7B), Color(0xFF8134AF)],
      ),
      '유튜브' => const RoutexLinkAccent(
        icon: Icons.play_arrow,
        colors: [Color(0xFFFF0000)],
      ),
      '네이버브랜드스토어' || '스마트스토어' || '네이버' => const RoutexLinkAccent(
        icon: Icons.storefront,
        colors: [Color(0xFF03C75A)],
      ),
      _ => null,
    };

/// 배지 이름에 색을 준다. 모르는 값은 색 없이 무채색으로 떨어진다 — 처음 보는
/// 배지를 그리지 못하는 것이 아니라 색만 없다.
RoutexBadgeAccent? showcaseBadgeAccent(String label) =>
    switch (label.replaceAll(' ', '').toUpperCase()) {
      'NEW' => const RoutexBadgeAccent(
        surface: Color(0xFFE8F5EC),
        ink: Color(0xFF1E7B45),
      ),
      '시즌한정' => const RoutexBadgeAccent(
        surface: Color(0xFFFDF0E7),
        ink: Color(0xFF9A4F0C),
      ),
      _ => null,
    };
