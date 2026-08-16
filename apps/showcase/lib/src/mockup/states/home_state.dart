import 'package:flutter/material.dart';
import 'package:routex_design_system/routex_design_system.dart';

import 'favorites_sheet.dart';
import 'menu_sheet.dart';

/// 앱을 열었을 때의 메인 화면이다.
///
/// Navigation의 `MapShellScreen`과 같은 구조를 쓴다. 지도가 주 화면이므로 하단
/// 시트를 두지 않고, 검색은 상단 한 줄, 지도 조작은 화면 아래 모서리에 둔다.
///
/// 카테고리 줄은 건물 안을 보고 있을 때만 나온다. 강조는 도면 위에 그려지므로
/// 건물 밖에서는 눌러도 결과가 보이지 않는다. 선택한 분류를 다시 누르면 해제한다.
class HomeState extends StatelessWidget {
  const HomeState({
    required this.buildingName,
    required this.floorLabel,
    required this.categoryId,
    required this.mapMoved,
    required this.placingLocation,
    required this.menuOpen,
    required this.favoritesOpen,
    required this.favorites,
    required this.onFavorites,
    required this.onFavoritesBack,
    required this.debugEnabled,
    required this.searchActive,
    required this.searchController,
    required this.recentQueries,
    required this.onSearchChanged,
    required this.onSearchClosed,
    required this.onRecentPicked,
    required this.onRecentCleared,
    required this.onCategory,
    required this.onMenu,
    required this.onDebug,
    required this.onSearch,
    required this.onSearchOpen,
    required this.onDirections,
    required this.onPlaceLocation,
    required this.onCalibrate,
    required this.onRecenter,
    super.key,
  });

  final String buildingName;
  final String floorLabel;
  final String? categoryId;
  final bool mapMoved;

  /// 지도 탭으로 내 위치를 지정하는 대기 상태인지.
  final bool placingLocation;

  final bool menuOpen;
  final bool favoritesOpen;
  final List<String> favorites;
  final VoidCallback onFavorites;
  final VoidCallback onFavoritesBack;
  final bool debugEnabled;

  /// 검색 줄에 입력 중인지. 활성화되면 상단 바가 입력 줄이 되고 결과 패널이 붙는다.
  final bool searchActive;
  final TextEditingController searchController;
  final List<String> recentQueries;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchClosed;
  final ValueChanged<String> onRecentPicked;
  final VoidCallback onRecentCleared;

  final ValueChanged<String?> onCategory;
  final VoidCallback onMenu;
  final VoidCallback onDebug;

  /// 검색 결과를 골라 장소 화면으로 넘어간다.
  final VoidCallback onSearch;

  /// 검색 줄에 입력을 시작한다.
  final VoidCallback onSearchOpen;
  final VoidCallback onDirections;
  final VoidCallback onPlaceLocation;
  final VoidCallback onCalibrate;
  final VoidCallback onRecenter;

  /// 분류 이름과 아이콘은 분류 토큰에서 읽는다. 화면이 글리프를 고르지 않는다.
  static const _categoryNames = ['패션', '음식점', '리빙', '편의시설'];

  static List<RoutexChipOption> get _categories => [
    for (final name in _categoryNames) RoutexChipOption.category(name),
  ];

  @override
  Widget build(BuildContext context) {
    final searching = searchController.text.trim().isNotEmpty;
    final searchResults = RoutexSurface(
      role: RoutexSurfaceRole.chrome,
      shape: RoutexSurfaceShape.field,
      child: RoutexInset(
        role: RoutexInsetRole.component,
        child: searching
            ? RoutexStack(
                gap: RoutexStackGap.control,
                children: [
                  RoutexListCell(
                    key: const ValueKey('mockup-search-result'),
                    title: '발렌시아가',
                    subtitle: '더현대 서울 1F · 패션 · 명품',
                    leadingIcon: RoutexIcons.place,
                    trailingIcon: RoutexIcons.forward,
                    onPressed: onSearch,
                  ),
                  RoutexListCell(
                    title: '발렌시아가 팝업',
                    subtitle: '더현대 서울 B1 · 패션',
                    leadingIcon: RoutexIcons.place,
                    trailingIcon: RoutexIcons.forward,
                    onPressed: onSearch,
                  ),
                ],
              )
            : recentQueries.isEmpty
            ? const RoutexEmptyState(
                title: '최근 검색어 없음',
                description: '검색한 장소가 여기에 쌓입니다.',
                icon: RoutexIcons.recent,
              )
            : RoutexStack(
                gap: RoutexStackGap.control,
                children: [
                  RoutexSectionHeader(
                    title: '최근 검색어',
                    level: RoutexSectionHeaderLevel.group,
                    actionLabel: '지우기',
                    onAction: onRecentCleared,
                  ),
                  for (final recent in recentQueries)
                    RoutexListCell(
                      title: recent,
                      leadingIcon: RoutexIcons.recent,
                      onPressed: () => onRecentPicked(recent),
                    ),
                ],
              ),
      ),
    );

    return RoutexMapOverlay(
      top: searchActive
          ? RoutexSearchBar(
              placeholder: '$buildingName에서 검색',
              onSearchPressed: null,
              leading: RoutexSearchLeading.back,
              onLeadingPressed: onSearchClosed,
              controller: searchController,
              onChanged: onSearchChanged,
              onSubmitted: (_) => onSearch(),
              onClear: () => onSearchChanged(''),
            )
          : RoutexSearchBar(
              placeholder: '$buildingName에서 검색',
              onSearchPressed: onSearchOpen,
              leading: RoutexSearchLeading.menu,
              onLeadingPressed: onMenu,
              onDirectionsPressed: onDirections,
            ),
      // 검색 중에는 카테고리 줄을 접는다. 두 오버레이가 같은 자리를 두고 겹치면
      // 지금 무엇이 목록을 결정하는지 읽히지 않는다.
      filters: searchActive
          ? searchResults
          : RoutexChipBar(
              semanticsLabel: '카테고리',
              surface: RoutexChipSurface.onMap,
              options: _categories,
              selectedId: categoryId,
              onSelected: onCategory,
            ),
      leadingControls: searchActive
          ? const []
          : [
              RoutexMapControl(
                key: const ValueKey('mockup-home-floor'),
                icon: RoutexIcons.floors,
                label: '층 선택',
                text: floorLabel,
                onPressed: onRecenter,
              ),
            ],
      trailingControls: searchActive
          ? const []
          : [
              RoutexMapControl(
                icon: RoutexIcons.currentLocation,
                label: mapMoved ? '현재 위치로 이동' : '현재 위치',
                onPressed: onRecenter,
              ),
              RoutexMapControl(
                key: const ValueKey('mockup-home-place-location'),
                icon: RoutexIcons.placeLocation,
                label: placingLocation ? '위치 지정 취소' : '지도에서 내 위치 지정',
                selected: placingLocation,
                onPressed: onPlaceLocation,
              ),
              RoutexMapControl(
                icon: RoutexIcons.calibrate,
                label: '위치 보정',
                onPressed: onCalibrate,
              ),
            ],
      sheet: favoritesOpen
          ? FavoritesSheet(
              places: favorites,
              onPick: (_) => onSearch(),
              onMore: (_) {},
              onBack: onFavoritesBack,
              onClose: onFavoritesBack,
            )
          : menuOpen
          ? MenuSheet(
              debugEnabled: debugEnabled,
              showPlaceLocation: true,
              onFavorites: onFavorites,
              onDirections: onDirections,
              onPlaceLocation: onPlaceLocation,
              onCalibrate: onCalibrate,
              onDebug: onDebug,
              onClose: onMenu,
            )
          : null,
      notice: !menuOpen && !favoritesOpen && placingLocation
          ? RoutexInlineNotice(
              message: '지도를 눌러 현재 위치를 지정하세요',
              actionLabel: '취소',
              onAction: onPlaceLocation,
            )
          : null,
    );
  }
}
