import 'package:flutter/material.dart';
import 'package:routex_design_system/routex_design_system.dart';

import '../data/showcase_navigation_data.dart';
import 'behavior_contract.dart';
import 'iphone_mockup.dart';
import 'mockup_step.dart';

/// 목업 흐름의 상태를 소유하고 기기 화면과 행동 계약 패널을 함께 배치한다.
class MobileUxShowcase extends StatefulWidget {
  const MobileUxShowcase({super.key});

  @override
  State<MobileUxShowcase> createState() => _MobileUxShowcaseState();
}

class _MobileUxShowcaseState extends State<MobileUxShowcase>
    with SingleTickerProviderStateMixin {
  MockupStep _step = MockupStep.home;
  bool _saved = false;
  bool _muted = false;
  bool _mapMoved = false;
  int _selectedRoute = 0;
  int _floor = 1;
  String? _category;
  bool _placingLocation = false;
  bool _menuOpen = false;
  bool _debugEnabled = false;
  bool _searchActive = false;
  bool _favoritesOpen = false;
  final List<String> _favorites = const ['발렌시아가', '구찌'];
  List<String> _recentQueries = const ['발렌시아가', '더현대 서울 지하 2층', '1층 안내 데스크'];
  final TextEditingController _searchController = TextEditingController();
  late final TransformationController _mapController =
      TransformationController();
  late final Future<ShowcasePlaceData> _placeFuture =
      ShowcaseNavigationDataSource().loadPlace();
  late final AnimationController _guidanceController =
      AnimationController(vsync: this, duration: const Duration(seconds: 14))
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed && mounted) {
            setState(() => _step = MockupStep.arrival);
          }
        });

  void _setStep(MockupStep step) {
    _guidanceController.stop();
    _mapController.value = Matrix4.identity();
    if (step == MockupStep.home ||
        step == MockupStep.place ||
        step == MockupStep.detail ||
        step == MockupStep.route) {
      _guidanceController.value = 0;
    } else if (step == MockupStep.indoor && _guidanceController.value < .58) {
      _guidanceController.value = .58;
    } else if (step == MockupStep.arrival) {
      _guidanceController.value = 1;
    }
    setState(() {
      _step = step;
      _mapMoved = false;
      _menuOpen = false;
      _favoritesOpen = false;
      _searchActive = false;
    });
  }

  void _handleMapInteraction(ScaleStartDetails details) {
    _guidanceController.stop();
    if (!_mapMoved) setState(() => _mapMoved = true);
  }

  void _recenterMap() {
    _mapController.value = Matrix4.identity();
    setState(() => _mapMoved = false);
  }

  void _toggleGuidance() {
    if (_guidanceController.isAnimating) {
      _guidanceController.stop();
    } else if (_guidanceController.value >= 1) {
      _guidanceController.forward(from: 0);
    } else {
      _guidanceController.forward();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    _guidanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ShowcasePlaceData>(
      future: _placeFuture,
      initialData: ShowcasePlaceData.navigationSnapshot,
      builder: (context, snapshot) => AnimatedBuilder(
        animation: _guidanceController,
        builder: (context, _) => _buildContent(
          context,
          snapshot.data ?? ShowcasePlaceData.navigationSnapshot,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ShowcasePlaceData place) {
    final selectedStepId = 'mockup-step-${_step.name}';
    return RoutexStack(
      gap: RoutexStackGap.content,
      children: [
        RoutexChipBar(
          semanticsLabel: '모바일 UX 단계',
          options: [
            for (final step in MockupStep.values)
              RoutexChipOption(
                id: 'mockup-step-${step.name}',
                label: step.label,
              ),
          ],
          selectedId: selectedStepId,
          onSelected: (id) {
            if (id == null) return;
            final step = MockupStep.values.firstWhere(
              (candidate) => 'mockup-step-${candidate.name}' == id,
            );
            _setStep(step);
          },
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 760;
            final phone = IphoneNavigationMockup(
              step: _step,
              place: place,
              saved: _saved,
              muted: _muted,
              selectedRoute: _selectedRoute,
              floor: _floor,
              categoryId: _category,
              placingLocation: _placingLocation,
              menuOpen: _menuOpen,
              favoritesOpen: _favoritesOpen,
              favorites: _favorites,
              onFavorites: () => setState(() {
                _menuOpen = false;
                _favoritesOpen = true;
              }),
              onFavoritesBack: () => setState(() => _favoritesOpen = false),
              debugEnabled: _debugEnabled,
              searchActive: _searchActive,
              searchController: _searchController,
              recentQueries: _recentQueries,
              onSearchOpen: () => setState(() {
                _searchActive = true;
                _menuOpen = false;
              }),
              onSearchChanged: (value) => setState(() {
                if (_searchController.text != value) {
                  _searchController.text = value;
                }
              }),
              onSearchClosed: () => setState(() {
                _searchActive = false;
                _searchController.clear();
              }),
              onRecentPicked: (value) =>
                  setState(() => _searchController.text = value),
              onRecentCleared: () => setState(() => _recentQueries = const []),
              mapMoved: _mapMoved,
              progress: _guidanceController.value,
              mapController: _mapController,
              guidancePlaying: _guidanceController.isAnimating,
              onStep: _setStep,
              onGuidanceToggle: _toggleGuidance,
              onSaved: (value) => setState(() => _saved = value),
              onMuted: (value) => setState(() => _muted = value),
              onRoute: (value) => setState(() => _selectedRoute = value),
              onFloor: (value) => setState(() => _floor = value),
              onCategory: (value) => setState(() => _category = value),
              onPlaceLocation: () => setState(() {
                _placingLocation = !_placingLocation;
                _menuOpen = false;
              }),
              onMenu: () => setState(() => _menuOpen = !_menuOpen),
              onDebug: () => setState(() => _debugEnabled = !_debugEnabled),
              onMapInteraction: _handleMapInteraction,
              onRecenter: _recenterMap,
            );
            final behavior = BehaviorContract(step: _step);
            if (narrow) {
              return RoutexStack(
                gap: RoutexStackGap.section,
                children: [phone, behavior],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: phone),
                const SizedBox(width: RoutexSpacing.sectionGap),
                SizedBox(width: 292, child: behavior),
              ],
            );
          },
        ),
        KeyedSubtree(
          key: const ValueKey('showcase-data-source-note'),
          child: RoutexInfoSection(
            title: '데이터 소스',
            rows: [
              place.source == ShowcaseDataSource.backend
                  ? 'Navigation 백엔드 store-index 응답을 사용 중입니다. API·도메인 adapter는 Showcase 앱 계층에 있고 Runtime Kit과 분리됩니다.'
                  : 'Navigation의 thehyundai-seoul store-index·1F 도면에서 추출한 고정 snapshot을 사용 중입니다. API_BASE_URL을 주입하면 같은 endpoint를 우선 조회합니다.',
            ],
          ),
        ),
      ],
    );
  }
}
