import 'package:flutter/material.dart';
import 'package:routex_design_system/routex_design_system.dart';

import '../data/showcase_navigation_data.dart';
import '../device/phone_chrome.dart';
import '../map/showcase_map_visual_layer.dart';
import 'mockup_step.dart';
import 'states/arrival_state.dart';
import 'states/detail_state.dart';
import 'states/guidance_state.dart';
import 'states/home_state.dart';
import 'states/indoor_state.dart';
import 'states/place_state.dart';
import 'states/route_state.dart';

/// 기기 프레임, 지도 캔버스와 단계별 제품 화면을 19.5:9 비율 안에 합친다.
class IphoneNavigationMockup extends StatelessWidget {
  const IphoneNavigationMockup({
    required this.step,
    required this.place,
    required this.saved,
    required this.muted,
    required this.selectedRoute,
    required this.floor,
    required this.categoryId,
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
    required this.onSearchOpen,
    required this.onSearchChanged,
    required this.onSearchClosed,
    required this.onRecentPicked,
    required this.onRecentCleared,
    required this.mapMoved,
    required this.progress,
    required this.mapController,
    required this.guidancePlaying,
    required this.onStep,
    required this.onGuidanceToggle,
    required this.onSaved,
    required this.onMuted,
    required this.onRoute,
    required this.onFloor,
    required this.onCategory,
    required this.onPlaceLocation,
    required this.onMenu,
    required this.onDebug,
    required this.onMapInteraction,
    required this.onRecenter,
    super.key,
  });

  final MockupStep step;
  final ShowcasePlaceData place;
  final bool saved;
  final bool muted;
  final int selectedRoute;
  final int floor;
  final String? categoryId;
  final bool placingLocation;
  final bool menuOpen;
  final bool favoritesOpen;
  final List<String> favorites;
  final VoidCallback onFavorites;
  final VoidCallback onFavoritesBack;
  final bool debugEnabled;
  final bool searchActive;
  final TextEditingController searchController;
  final List<String> recentQueries;
  final VoidCallback onSearchOpen;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchClosed;
  final ValueChanged<String> onRecentPicked;
  final VoidCallback onRecentCleared;
  final bool mapMoved;
  final double progress;
  final TransformationController mapController;
  final bool guidancePlaying;
  final ValueChanged<MockupStep> onStep;
  final VoidCallback onGuidanceToggle;
  final ValueChanged<bool> onSaved;
  final ValueChanged<bool> onMuted;
  final ValueChanged<int> onRoute;
  final ValueChanged<int> onFloor;
  final ValueChanged<String?> onCategory;
  final VoidCallback onPlaceLocation;
  final VoidCallback onMenu;
  final VoidCallback onDebug;
  final GestureScaleStartCallback onMapInteraction;
  final VoidCallback onRecenter;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390),
        child: RepaintBoundary(
          key: const ValueKey('iphone-mockup'),
          child: AspectRatio(
            aspectRatio: 390 / 844,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(52),
                boxShadow: RoutexLayer.shadow(RoutexLayerRole.overlay, colors),
              ),
              child: CustomPaint(
                foregroundPainter: const PromoPhoneFramePainter(),
                child: ClipPath(
                  clipper: const PromoPhoneClipper(),
                  child: Material(
                    // 기기 화면의 바탕은 제품 surface가 아니라 단색 지도 canvas다.
                    // 도면·경로·마커는 이동 안내 계열 단계에서만 Showcase 앱의
                    // 지도 시각 계층이 이 표면 위에 그린다.
                    color: RoutexMapVisualTokens.canvasOutdoor,
                    child: SizedBox.expand(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (step.showsMapVisuals)
                            ShowcaseMapVisualLayer(
                              step: step,
                              progress: progress,
                              mapController: mapController,
                              onInteractionStart: onMapInteraction,
                            ),
                          MediaQuery(
                            data: MediaQuery.of(
                              context,
                            ).copyWith(textScaler: TextScaler.noScaling),
                            child: const PhoneStatusBar(),
                          ),
                          MediaQuery(
                            data: MediaQuery.of(
                              context,
                            ).copyWith(padding: deviceViewPadding),
                            child: AnimatedSwitcher(
                              duration: RoutexMotion.transition,
                              switchInCurve: RoutexMotion.enterCurve,
                              switchOutCurve: RoutexMotion.exitCurve,
                              child: switch (step) {
                                MockupStep.home => HomeState(
                                  key: const ValueKey('home-state'),
                                  buildingName: place.buildingName,
                                  floorLabel: place.floorName,
                                  categoryId: categoryId,
                                  mapMoved: mapMoved,
                                  placingLocation: placingLocation,
                                  menuOpen: menuOpen,
                                  favoritesOpen: favoritesOpen,
                                  favorites: favorites,
                                  onFavorites: onFavorites,
                                  onFavoritesBack: onFavoritesBack,
                                  debugEnabled: debugEnabled,
                                  searchActive: searchActive,
                                  searchController: searchController,
                                  recentQueries: recentQueries,
                                  onSearchChanged: onSearchChanged,
                                  onSearchClosed: onSearchClosed,
                                  onRecentPicked: onRecentPicked,
                                  onRecentCleared: onRecentCleared,
                                  onCategory: onCategory,
                                  onMenu: onMenu,
                                  onDebug: onDebug,
                                  onSearch: () => onStep(MockupStep.place),
                                  onSearchOpen: onSearchOpen,
                                  onDirections: () => onStep(MockupStep.route),
                                  onPlaceLocation: onPlaceLocation,
                                  onCalibrate: onPlaceLocation,
                                  onRecenter: onRecenter,
                                ),
                                MockupStep.place => PlaceState(
                                  key: const ValueKey('place-state'),
                                  place: place,
                                  saved: saved,
                                  mapMoved: mapMoved,
                                  onSaved: onSaved,
                                  onDetail: () => onStep(MockupStep.detail),
                                  onBack: () => onStep(MockupStep.home),
                                  onRoute: () => onStep(MockupStep.route),
                                  onRecenter: onRecenter,
                                ),
                                MockupStep.detail => DetailState(
                                  key: const ValueKey('detail-state'),
                                  place: place,
                                  saved: saved,
                                  onSaved: onSaved,
                                  onRoute: () => onStep(MockupStep.route),
                                  onClose: () => onStep(MockupStep.place),
                                ),
                                MockupStep.route => RouteState(
                                  key: const ValueKey('route-state'),
                                  place: place,
                                  selectedRoute: selectedRoute,
                                  onRoute: onRoute,
                                  onStart: () => onStep(MockupStep.guidance),
                                  onRecenter: onRecenter,
                                  onClose: () => onStep(MockupStep.place),
                                  onEditDestination: () =>
                                      onStep(MockupStep.detail),
                                ),
                                MockupStep.guidance => GuidanceState(
                                  key: const ValueKey('guidance-state'),
                                  muted: muted,
                                  mapMoved: mapMoved,
                                  progress: progress,
                                  playing: guidancePlaying,
                                  onMuted: onMuted,
                                  onPlay: onGuidanceToggle,
                                  onIndoor: () => onStep(MockupStep.indoor),
                                  onRecenter: onRecenter,
                                  onStop: () => onStep(MockupStep.place),
                                ),
                                MockupStep.indoor => IndoorState(
                                  key: const ValueKey('indoor-state'),
                                  floor: floor,
                                  progress: progress,
                                  playing: guidancePlaying,
                                  onFloor: onFloor,
                                  onPlay: onGuidanceToggle,
                                  onArrival: () => onStep(MockupStep.arrival),
                                  onStop: () => onStep(MockupStep.place),
                                ),
                                MockupStep.arrival => ArrivalState(
                                  key: const ValueKey('arrival-state'),
                                  place: place,
                                  saved: saved,
                                  onSaved: onSaved,
                                  onEnd: () => onStep(MockupStep.home),
                                  onDetail: () => onStep(MockupStep.detail),
                                ),
                              },
                            ),
                          ),
                          const PhoneHomeIndicator(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
