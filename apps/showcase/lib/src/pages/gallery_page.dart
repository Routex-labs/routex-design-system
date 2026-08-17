import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:routex_design_system/routex_design_system.dart';

import '../catalog/place_detail_catalog.dart';
import '../data/showcase_place_detail_data.dart';

/// 설명 없이 컴포넌트만 한 화면에 모아 보여준다.
///
/// **창이 좁으면 화면 전체를 줄여서라도 열 수를 지킨다.** 이 페이지의 목적은 "지금
/// 무엇이 있는지"를 한 번에 보는 것이라, 열이 둘로 줄면 목록이 세로로 길어져 목적
/// 자체가 사라진다. 그렇다고 카드를 좁히면 컴포넌트가 기기에서보다 좁아져 줄바꿈이
/// 실제와 달라진다.
///
/// 그래서 **배치가 아니라 보기 배율을 줄인다.** 안쪽은 언제나 제품 폭(390) 카드
/// 네 열로 배치하고, 창이 그보다 좁으면 그 결과를 통째로 축소해 보여 준다. 카드 폭,
/// 글자 크기, 간격의 **비율은 그대로**라 위계가 깨지지 않는다. 실제 크기를 재는 검수는
/// `품질 기준` 탭의 fixture가 맡는다 — 그쪽은 축소하지 않는다.
class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  /// 어떤 창에서도 한 번에 보이길 바라는 열 수다.
  static const fitColumns = 4;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final logical = math.max(
          constraints.maxWidth,
          GalleryGrid.widthForColumns(fitColumns),
        );
        // FittedBox는 자식을 잰 뒤 제 크기를 축소된 크기로 보고한다. Transform으로
        // 줄이면 부모는 줄기 전 높이를 그대로 잡아 아래에 빈 공간이 남는다.
        return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.topStart,
          child: SizedBox(width: logical, child: const GalleryGrid()),
        );
      },
    );
  }
}

/// 카드를 열에 나눠 담는 격자다. 배율은 [GalleryPage]가 맡고 여기는 배치만 맡는다.
///
/// 카드는 모두 같은 열 폭을 쓰고 폭이 넓어지면 열 수만 늘어나, 어떤 폭에서도 열이
/// 어긋나거나 한쪽만 비지 않는다. 중요한 컴포넌트가 앞에 오도록 순서를 정해 두었고,
/// 격자는 그 순서대로 가장 낮은 열에 담으므로 위쪽에 매장 상세와 길찾기가, 아래쪽에
/// 상태 표시와 빈 값이 모인다.
class GalleryGrid extends StatefulWidget {
  const GalleryGrid({super.key});

  /// 열 폭은 제품 폭(390)에 카드 여백을 더한 값이다. 열이 그보다 넓어지면 검색 줄
  /// 같은 가로 컴포넌트가 실제보다 길게 보인다.
  static const columnWidth = 390 + RoutexSpacing.componentPadding * 2;
  static const gap = RoutexSpacing.contentGap;

  /// 열 사이 여백까지 세어야 한다. 폭만 곱하면 여백 (n-1)칸이 빠져 마지막 열이
  /// 오른쪽으로 삐져나온다.
  static double widthForColumns(int columns) =>
      columns * columnWidth + gap * (columns - 1);

  @override
  State<GalleryGrid> createState() => _GalleryGridState();
}

class _GalleryGridState extends State<GalleryGrid> {
  int _tab = 0;
  int _route = 0;
  bool _saved = false;
  String _travelMode = 'walk';
  String? _category = '음식점';
  String _floor = '1F';
  String _sort = 'name';
  int _itinerary = 0;
  bool _autoIndoor = true;

  /// 상세 내용은 Navigation 백엔드의 오설록 매장에서 온다.
  static const _detail = ShowcasePlaceDetail.osulloc;

  /// 영업 판정 기준 시각. 화면이 `DateTime.now`를 부르면 같은 페이지를 두 번 볼 때
  /// 다른 상태가 된다.
  static final _now = DateTime(2026, 8, 18, 14, 30);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 열 폭은 고정이고 열 수만 폭을 따라간다. 카드가 폭을 따라 늘어나면 넓은
        // 창에서 컴포넌트가 실제보다 길어진다.
        const gap = GalleryGrid.gap;
        const columnWidth = GalleryGrid.columnWidth;
        final columns = ((constraints.maxWidth + gap) / (columnWidth + gap))
            .floor()
            .clamp(1, 5);

        // Wrap은 행 단위라 짧은 카드 뒤에 구멍이 남는다. 카드를 열에 직접 나눠
        // 담되, 지금까지 쌓인 높이가 가장 낮은 열에 다음 카드를 넣어 아래쪽이
        // 들쭉날쭉해지지 않게 한다.
        return _Masonry(
          key: const ValueKey('gallery-masonry'),
          columns: columns,
          columnWidth: columnWidth,
          gap: gap,
          children: [
            _Card(
              surface: _CardSurface.sheet,
              child: PlaceDetailHeaderCard(detail: _detail),
            ),
            _Card(
              surface: _CardSurface.sheet,
              child: PlaceFactsCard(detail: _detail, now: _now),
            ),
            _Card(
              surface: _CardSurface.sheet,
              child: PlaceMenuCard(detail: _detail),
            ),
            _Card(
              surface: _CardSurface.sheet,
              child: PlacePhotosCard(detail: _detail),
            ),
            _Card(
              surface: _CardSurface.sheet,
              child: PlaceLinksCard(detail: _detail),
            ),
            _Card(
              surface: _CardSurface.map,
              child: RoutexStack(
                gap: RoutexStackGap.inline,
                children: [
                  RoutexSearchBar(
                    placeholder: '건물, 장소를 검색하세요',
                    onSearchPressed: () {},
                    leading: RoutexSearchLeading.menu,
                    onLeadingPressed: () {},
                    onDirectionsPressed: () {},
                  ),
                  RoutexChipBar(
                    semanticsLabel: '분류',
                    surface: RoutexChipSurface.onMap,
                    options: [
                      for (final name in const ['패션', '음식점', '리빙', '편의시설'])
                        RoutexChipOption.category(name),
                    ],
                    selectedId: _category,
                    onSelected: (value) => setState(() => _category = value),
                  ),
                ],
              ),
            ),
            _Card(
              surface: _CardSurface.map,
              child: RoutexRoutePlanner(
                originLabel: '현재 위치',
                destinationLabel: '더현대 서울 1F · 발렌시아가',
                travelModes: const [
                  RoutexTravelModeOption(
                    id: 'car',
                    label: '자동차',
                    icon: RoutexIcons.car,
                  ),
                  RoutexTravelModeOption(
                    id: 'transit',
                    label: '대중교통',
                    icon: RoutexIcons.transit,
                  ),
                  RoutexTravelModeOption(
                    id: 'walk',
                    label: '도보',
                    icon: RoutexIcons.walk,
                  ),
                ],
                selectedTravelModeId: _travelMode,
                onTravelModeSelected: (value) =>
                    setState(() => _travelMode = value),
                onOriginPressed: () {},
                onDestinationPressed: () {},
                onClose: () {},
                onDestinationMore: () {},
              ),
            ),
            // 목록은 상태가 셋이고, 그 셋이 서로 다른 화면이라는 것이 이 카드들의
            // 요점이다. 한 카드에 겹쳐 두면 "찾는 중"과 "찾지 못함"의 차이가 안 보인다.
            _Card(
              surface: _CardSurface.sheet,
              compact: true,
              child: RoutexResultList(
                status: RoutexResultStatus.ready,
                summary: '32개 결과',
                sortOptions: const [
                  RoutexSortOption(
                    id: 'near',
                    label: '가까운 순',
                    unavailableReason: '현재 위치 필요',
                  ),
                  RoutexSortOption(id: 'name', label: '이름 맞춤 순'),
                ],
                selectedSortId: _sort,
                onSortSelected: (value) => setState(() => _sort = value),
                children: const [
                  RoutexListCell(
                    title: '오설록',
                    subtitle: 'B1 · 식음료 · 도보 3분',
                    leadingIcon: RoutexIcons.place,
                    onPressed: _noop,
                  ),
                  RoutexListCell(
                    title: '블루보틀',
                    subtitle: '5F · 식음료 · 도보 5분',
                    leadingIcon: RoutexIcons.place,
                    onPressed: _noop,
                  ),
                ],
              ),
            ),
            _Card(
              surface: _CardSurface.sheet,
              child: RoutexPlaceHeader(
                name: '발렌시아가',
                metadata: '1F · 패션 · 명품',
                supportingText: '더현대 서울 · 현재 위치에서 약 320m',
                saved: _saved,
                onSaved: (value) => setState(() => _saved = value),
                onToggleExpanded: () {},
              ),
            ),
            _Card(
              surface: _CardSurface.sheet,
              compact: true,
              child: RoutexStack(
                gap: RoutexStackGap.control,
                children: [
                  RoutexRouteOption(
                    title: '6분',
                    detail: '410m · 실내 연결 통로',
                    meta: '추천',
                    selected: _route == 0,
                    onPressed: () => setState(() => _route = 0),
                  ),
                  RoutexRouteOption(
                    title: '7분',
                    detail: '460m · 엘리베이터 우선',
                    meta: '+1분',
                    selected: _route == 1,
                    onPressed: () => setState(() => _route = 1),
                  ),
                ],
              ),
            ),
            _Card(
              surface: _CardSurface.map,
              child: RoutexStack(
                gap: RoutexStackGap.content,
                children: [
                  const RoutexManeuverBanner(
                    distance: '120m 후 건물로 진입',
                    detail: '더현대 서울 1층 · 명품관 방향',
                    icon: RoutexIcons.turnRight,
                  ),
                  RoutexTripProgress(
                    metrics: const [
                      RoutexTripMetric(value: '오후 3:24', label: '도착 예정'),
                      RoutexTripMetric(value: '6분', label: '남은 시간'),
                      RoutexTripMetric(value: '410m', label: '남은 거리'),
                    ],
                    onStop: () {},
                  ),
                ],
              ),
            ),
            // 계획과 도착은 안내의 처음과 끝이라 한 카드에 겹치면 어느 쪽이 지금
            // 화면인지 읽히지 않는다. 둘 다 지도 위 표면이라 바탕은 지도로 둔다.
            _Card(
              surface: _CardSurface.map,
              child: RoutexEtaCard(
                arrivalTime: '오후 3:24',
                metrics: const [
                  RoutexTripMetric(value: '22분', label: '소요'),
                  RoutexTripMetric(value: '1.4km', label: '거리'),
                ],
                onStart: () {},
              ),
            ),
            _Card(
              surface: _CardSurface.map,
              child: RoutexArrivalCard(
                destination: '오설록',
                floor: 'B1',
                detail: '식품관 입구 왼쪽',
                onClose: () {},
                onShowDetail: () {},
              ),
            ),
            _Card(
              surface: _CardSurface.sheet,
              child: const RoutexStepList(
                currentIndex: 1,
                steps: [
                  RoutexStep(
                    instruction: '정문으로 나가기',
                    icon: RoutexIcons.straight,
                    distance: '40m',
                  ),
                  RoutexStep(
                    instruction: '오른쪽 통로로 이동',
                    icon: RoutexIcons.turnRight,
                    distance: '92m',
                    detail: '3층 에스컬레이터 옆',
                  ),
                  RoutexStep(instruction: '오설록 도착', icon: RoutexIcons.arrived),
                ],
              ),
            ),
            _Card(
              surface: _CardSurface.sheet,
              child: RoutexStack(
                gap: RoutexStackGap.control,
                children: [
                  RoutexTransitItinerary(
                    duration: '35분',
                    facts: const ['환승 1회', '도보 8분', '1,500원'],
                    fastest: true,
                    selected: _itinerary == 0,
                    onPressed: () => setState(() => _itinerary = 0),
                    legs: const [
                      RoutexTransitLeg(label: '도보 5분', icon: RoutexIcons.walk),
                      RoutexTransitLeg(
                        label: '5호선',
                        icon: RoutexIcons.subway,
                        accent: RoutexBadgeAccent(
                          surface: Color(0xFFEDE9F6),
                          ink: Color(0xFF5B3FA6),
                        ),
                      ),
                      RoutexTransitLeg(label: '도보 3분', icon: RoutexIcons.walk),
                    ],
                  ),
                  RoutexTransitItinerary(
                    duration: '38분',
                    facts: const ['환승 없음', '도보 12분', '1,500원'],
                    selected: _itinerary == 1,
                    onPressed: () => setState(() => _itinerary = 1),
                    legs: const [
                      RoutexTransitLeg(label: '도보 12분', icon: RoutexIcons.walk),
                      RoutexTransitLeg(
                        label: '간선 472',
                        icon: RoutexIcons.bus,
                        accent: RoutexBadgeAccent(
                          surface: Color(0xFFE9F1FB),
                          ink: Color(0xFF1F5FA8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 최근 검색과 저장한 장소는 한 카드에 섞으면 행마다 leading·trailing이
            // 달라 규칙이 없어 보인다. 카드를 나누면 카드 안에서는 행이 같은 모양을
            // 유지하고, 카드 사이의 차이가 곧 두 목록의 차이가 된다.
            _Card(
              surface: _CardSurface.sheet,
              child: RoutexStack(
                gap: RoutexStackGap.control,
                children: [
                  RoutexRecentList(
                    title: '최근 검색',
                    onClear: _noop,
                    items: const [
                      RoutexRecentItem(
                        id: 'the-hyundai',
                        title: '더현대 서울',
                        subtitle: '1F · 패션',
                        onPressed: _noop,
                        onRemove: _noop,
                      ),
                      RoutexRecentItem(
                        id: 'lotte-tower',
                        title: '롯데월드타워',
                        subtitle: '지하 1층 · 복합몰',
                        onPressed: _noop,
                        onRemove: _noop,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _Card(
              surface: _CardSurface.sheet,
              child: RoutexStack(
                gap: RoutexStackGap.control,
                children: [
                  RoutexSectionHeader(
                    title: '저장한 장소',
                    actionLabel: '편집',
                    onAction: () {},
                  ),
                  RoutexListCell(
                    title: '발렌시아가',
                    subtitle: '더현대 서울 1F',
                    leadingIcon: RoutexIcons.saved,
                    trailingActionLabel: '발렌시아가 더보기',
                    onTrailingAction: () {},
                    reorderable: true,
                    onPressed: _noop,
                  ),
                  RoutexListCell(
                    title: '구찌',
                    subtitle: '더현대 서울 1F',
                    leadingIcon: RoutexIcons.saved,
                    trailingActionLabel: '구찌 더보기',
                    onTrailingAction: () {},
                    reorderable: true,
                    onPressed: _noop,
                  ),
                ],
              ),
            ),
            _Card(
              surface: _CardSurface.sheet,
              child: RoutexStack(
                gap: RoutexStackGap.control,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: RoutexButton(label: '길찾기', onPressed: () {}),
                  ),
                  RoutexCluster(
                    gap: RoutexClusterGap.control,
                    children: [
                      RoutexButton(
                        label: '다른 출발지',
                        variant: RoutexButtonVariant.secondary,
                        onPressed: () {},
                      ),
                      RoutexButton(
                        label: '나중에',
                        variant: RoutexButtonVariant.quiet,
                        onPressed: () {},
                      ),
                      RoutexButton(
                        label: '삭제',
                        variant: RoutexButtonVariant.danger,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 세로 컨트롤은 폭이 열의 5분의 1도 안 된다. 한 칸씩 차지하면 오른쪽이
            // 통째로 비므로, 좁은 카드끼리 한 칸을 나눠 쓴다. 자리가 모자라면 이
            // 칸 안에서 줄만 바뀌어, 몇 개가 되든 열을 낭비하지 않는다.
            //
            // 두 카드 모두 지도 바탕이다. 지도 위 컨트롤은 흰 타일로 떠 있어서 흰
            // 카드에 올리면 타일이 바탕에 녹아 사라진다. 같은 이유로 여기에는 지도
            // 위 컨트롤만 둔다. 시트 안에서 쓰는 RoutexIconAction은 배경이
            // surfaceCanvas라 지도 바탕에서 반대로 안 보이므로 장소 요약 카드에서
            // 보여준다.
            _NarrowRow(
              key: const ValueKey('gallery-narrow-row'),
              children: [
                _Card(
                  surface: _CardSurface.map,
                  child: RoutexFloorSelector(
                    options: const [
                      RoutexFloorOption(id: '2F', label: '2F'),
                      RoutexFloorOption(id: '1F', label: '1F'),
                      RoutexFloorOption(id: 'B1', label: 'B1'),
                    ],
                    selectedId: _floor,
                    onSelected: (value) => setState(() => _floor = value),
                  ),
                ),
                _Card(
                  surface: _CardSurface.map,
                  child: RoutexStack(
                    gap: RoutexStackGap.control,
                    fill: RoutexStackFill.content,
                    children: [
                      RoutexMapControl(
                        label: '장소 저장',
                        icon: RoutexIcons.save,
                        onPressed: () {},
                      ),
                      RoutexMapControl(
                        label: '현재 위치',
                        icon: RoutexIcons.currentLocation,
                        onPressed: () {},
                      ),
                      RoutexMapControl(
                        label: '추적 중',
                        icon: RoutexIcons.followLocation,
                        tone: RoutexMapControlTone.active,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                const _Card(
                  surface: _CardSurface.map,
                  child: RoutexStack(
                    gap: RoutexStackGap.control,
                    fill: RoutexStackFill.content,
                    children: [RoutexToastSurface(message: '복사했습니다')],
                  ),
                ),
              ],
            ),
            _Card(
              surface: _CardSurface.map,
              child: RoutexStack(
                gap: RoutexStackGap.content,
                children: [
                  RoutexTabs(
                    labels: const ['홈', '메뉴', '사진'],
                    selectedIndex: _tab,
                    onSelected: (value) => setState(() => _tab = value),
                  ),
                  // 이 카드가 보여주는 것은 시트의 머리 부분과 표면이다. 내용은
                  // 저장한 장소 카드와 겹치지 않게 검색 결과로 둔다.
                  RoutexBottomSheet(
                    showHandle: true,
                    header: RoutexSheetHeader(
                      title: '검색 결과',
                      onBack: () {},
                      onClose: () {},
                    ),
                    child: const RoutexListCell(
                      title: '더현대 서울',
                      subtitle: '1F · 패션',
                      leadingIcon: RoutexIcons.place,
                      trailingIcon: RoutexIcons.forward,
                      onPressed: _noop,
                    ),
                  ),
                ],
              ),
            ),
            _Card(
              surface: _CardSurface.map,
              child: RoutexStack(
                gap: RoutexStackGap.content,
                children: [
                  RoutexInlineNotice(
                    message: '장소를 저장했습니다.',
                    actionLabel: '실행 취소',
                    onAction: () {},
                  ),
                  const RoutexStatusBanner(
                    title: '목적지에 도착했습니다',
                    detail: '더현대 서울 · 1F 발렌시아가 앞',
                    icon: RoutexIcons.success,
                    tone: RoutexStatusBannerTone.success,
                  ),
                ],
              ),
            ),
            _Card(
              surface: _CardSurface.sheet,
              child: const RoutexResultList(
                status: RoutexResultStatus.loading,
                loadingMessage: '실내 매장을 찾는 중',
                children: [],
              ),
            ),
            _Card(
              surface: _CardSurface.sheet,
              child: const RoutexResultList(
                status: RoutexResultStatus.empty,
                children: [],
              ),
            ),
            // 표면은 그 자체로 보이는 컴포넌트가 아니라 다른 것이 올라가는 바닥이다.
            // 네 역할을 나란히 두어야 어떤 것이 그림자를 갖고 어떤 것이 경계선만
            // 갖는지가 비교된다.
            _Card(
              surface: _CardSurface.map,
              child: RoutexStack(
                gap: RoutexStackGap.content,
                children: [
                  for (final (role, label) in const [
                    (RoutexSurfaceRole.flat, '평평한 묶음'),
                    (RoutexSurfaceRole.outlined, '경계로만 구분'),
                    (RoutexSurfaceRole.onMap, '지도 위 조작'),
                    (RoutexSurfaceRole.chrome, '지도 위 주 표면'),
                  ])
                    RoutexSurface(
                      role: role,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.all(
                          RoutexSpacing.componentPadding,
                        ),
                        child: Text(label, style: RoutexTypography.label),
                      ),
                    ),
                ],
              ),
            ),
            // 분류·경로 속성과 낮은 강도의 위치 품질은 읽기 전용 배지로 둔다.
            // 자동 복구가 시작되는 경로 이탈만 잠시 보이는 상단 상태 알림으로 올린다.
            _Card(
              surface: _CardSurface.sheet,
              child: RoutexStack(
                gap: RoutexStackGap.control,
                children: [
                  RoutexCluster(
                    gap: RoutexClusterGap.control,
                    children: [
                      RoutexBadge(
                        label: 'NEW',
                        accent: showcaseBadgeAccent('NEW'),
                      ),
                      const RoutexBadge(
                        label: '시즌 한정',
                        accent: RoutexBadgeAccent(
                          surface: Color(0xFFFDF0E7),
                          ink: Color(0xFF9A4F0C),
                        ),
                      ),
                      const RoutexBadge(
                        label: '최단 시간',
                        tone: RoutexBadgeTone.info,
                      ),
                      const RoutexBadge(
                        label: 'GPS 약함',
                        icon: RoutexIcons.warning,
                        tone: RoutexBadgeTone.warning,
                      ),
                    ],
                  ),
                  const RoutexStatusBanner(
                    title: '경로를 벗어났습니다',
                    detail: '새 경로를 자동으로 찾고 있습니다.',
                    icon: RoutexIcons.error,
                    tone: RoutexStatusBannerTone.error,
                  ),
                ],
              ),
            ),
            _Card(
              surface: _CardSurface.sheet,
              child: RoutexStack(
                gap: RoutexStackGap.content,
                children: [
                  RoutexSwitchRow(
                    title: '실내 진입 자동 전환',
                    description: '건물 입구에 닿으면 실내 도면으로 바꿉니다.',
                    value: _autoIndoor,
                    onChanged: (value) => setState(() => _autoIndoor = value),
                  ),
                  const RoutexSwitchRow(
                    title: '보행자 안내 음성',
                    description: '이 기기에서는 아직 쓸 수 없습니다.',
                    value: false,
                    onChanged: null,
                  ),
                ],
              ),
            ),
            _Card(
              surface: _CardSurface.sheet,
              child: const RoutexKeyValueRows(
                rows: [
                  RoutexKeyValue(label: '용량', value: '355ml'),
                  RoutexKeyValue(label: '칼로리', value: '10kcal'),
                  RoutexKeyValue(label: '알레르기', value: '대두 / 우유'),
                ],
              ),
            ),
            // dialog는 눌러야 뜨는 표면이라 카탈로그에서는 제자리에 세워 둔다.
            // 복사 토스트는 위의 층·지도 조작 narrow row에 합쳐 빈 갤러리 칸을 만들지
            // 않는다. 역할을 합친 것이 아니라 좁은 예시끼리 한 칸을 나눈 것이다.
            _NarrowRow(
              key: const ValueKey('gallery-feedback-row'),
              children: [
                const _Card(
                  surface: _CardSurface.map,
                  child: RoutexDialog(
                    title: '저장한 장소를 지울까요?',
                    description: '지운 장소는 되돌릴 수 없습니다.',
                    confirmLabel: '지우기',
                    onConfirm: _noop,
                  ),
                ),
              ],
            ),
            // 정보가 비어 있음을 알리는 방식이 둘로 나뉜다. 항목 자리를 지키며 한
            // 줄로 알리는 것(InfoSection)과 화면 한 칸을 통째로 채우는
            // 것(EmptyState)이다. 한 카드에 겹쳐 두면 둘의 차이가 안 보인다.
            _Card(
              surface: _CardSurface.sheet,
              child: const RoutexInfoSection(
                title: '영업시간',
                rows: ['등록된 영업시간 정보가 없습니다.'],
              ),
            ),
            _Card(
              surface: _CardSurface.sheet,
              child: const RoutexEmptyState(
                title: '사진 없음',
                description: '이 매장은 등록된 사진이 없습니다.',
                icon: RoutexIcons.image,
              ),
            ),
          ],
        );
      },
    );
  }
}

enum _CardSurface { map, sheet }

/// 갤러리의 한 칸이다. 폭은 열 계산이 정하고, 바탕은 그 컴포넌트가 실제로 놓이는
/// 표면을 따른다.
///
/// 카드 폭은 놓이는 자리가 정한다.
///
/// 열에 직접 놓이면 열 폭을 꽉 채우고, [_NarrowRow] 안에 놓이면 내용 폭까지
/// 줄어든다. 카드가 스스로 폭을 정하지 않으므로 "좁은 카드"라는 종류를 따로 두지
/// 않아도 된다.
class _Card extends StatelessWidget {
  const _Card({
    required this.surface,
    required this.child,
    this.compact = false,
  });

  final _CardSurface surface;
  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.routexColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: switch (surface) {
          _CardSurface.map => colors.surfaceCanvas,
          _CardSurface.sheet => colors.surfaceRaised,
        },
        borderRadius: RoutexRadii.card,
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.all(
          compact ? RoutexSpacing.controlGap : RoutexSpacing.componentPadding,
        ),
        child: child,
      ),
    );
  }
}

/// 좁은 카드 여럿이 열 한 칸을 나눠 쓴다.
///
/// 세로 컨트롤처럼 폭이 크게 남는 카드에 열을 통째로 주면 오른쪽이 비어 격자가
/// 무너진 것처럼 보인다. 그렇다고 "좁은 카드는 하나만"이라고 정해 두면 컴포넌트가
/// 늘 때마다 그 규칙에 걸린다. 대신 좁은 카드끼리 가로로 채우고, 한 줄에 다 못
/// 들어가면 이 칸 안에서 줄만 바꾼다. 몇 개가 되든 열은 낭비되지 않는다.
///
/// 여기 담긴 카드는 느슨한 제약을 받아 저마다 내용 폭까지 줄어든다.
class _NarrowRow extends StatelessWidget {
  const _NarrowRow({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: RoutexSpacing.contentGap,
      runSpacing: RoutexSpacing.contentGap,
      children: children,
    );
  }
}

/// 카드를 열에 직접 나눠 담아 아래쪽에 구멍이 남지 않게 한다.
///
/// 카드를 순서대로 열에 돌려 담으면 열마다 담기는 개수만 같아지고 높이는 어긋난다.
/// 카드 높이는 내용에 따라 두 배 넘게 차이나기 때문이다. 그래서 카드를 실제로
/// 재본 뒤 그 시점에 가장 낮은 열에 넣는다. 높이를 손으로 적어 두면 카드 내용이
/// 바뀔 때 그 숫자만 조용히 낡으므로, 어림값을 두지 않고 매번 잰 값을 쓴다.
class _Masonry extends MultiChildRenderObjectWidget {
  const _Masonry({
    required super.key,
    required this.columns,
    required this.columnWidth,
    required this.gap,
    required super.children,
  });

  final int columns;
  final double columnWidth;
  final double gap;

  @override
  _RenderMasonry createRenderObject(BuildContext context) {
    return _RenderMasonry(columns, columnWidth, gap);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderMasonry renderObject) {
    renderObject
      ..columns = columns
      ..columnWidth = columnWidth
      ..gap = gap;
  }
}

class _RenderMasonry extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _MasonryParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _MasonryParentData> {
  _RenderMasonry(this._columns, this._columnWidth, this._gap);

  int _columns;
  int get columns => _columns;
  set columns(int value) {
    if (_columns == value) return;
    _columns = value;
    markNeedsLayout();
  }

  double _columnWidth;
  double get columnWidth => _columnWidth;
  set columnWidth(double value) {
    if (_columnWidth == value) return;
    _columnWidth = value;
    markNeedsLayout();
  }

  double _gap;
  double get gap => _gap;
  set gap(double value) {
    if (_gap == value) return;
    _gap = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! _MasonryParentData) {
      child.parentData = _MasonryParentData();
    }
  }

  double get _totalWidth => columnWidth * columns + gap * (columns - 1);

  @override
  double computeMinIntrinsicWidth(double height) => _totalWidth;

  @override
  double computeMaxIntrinsicWidth(double height) => _totalWidth;

  @override
  void performLayout() {
    // 카드는 열 폭에 딱 맞춘다. 폭이 카드마다 달라지면 열이 어긋난다.
    final childConstraints = BoxConstraints.tightFor(width: columnWidth);
    final cards = <RenderBox>[];
    final heights = <double>[];

    for (
      var child = firstChild;
      child != null;
      child = (child.parentData! as _MasonryParentData).nextSibling
    ) {
      child.layout(childConstraints, parentUsesSize: true);
      cards.add(child);
      heights.add(child.size.height);
    }

    final columnHeights = List<double>.filled(columns, 0);
    final assigned = List.generate(columns, (_) => <int>[]);

    // **첫 줄은 순서가 정한다.** 갤러리의 카드 순서는 곧 중요도라, 균형만 보고
    // 담으면 제일 중요한 카드가 세 번째 열 아래쪽에 앉는다. 앞의 열 수만큼은
    // 작성 순서대로 각 열의 머리에 못박고, 나머지만 균형에 맡긴다.
    final pinned = math.min(columns, cards.length);
    for (var index = 0; index < pinned; index++) {
      assigned[index].add(index);
      columnHeights[index] = heights[index];
    }

    // 남은 카드는 큰 것부터 배치한다. 작성 순서대로 넣으면 마지막에 남은 큰 카드가
    // 한 열에만 얹혀 그 열만 튀어나온다. 큰 것부터 넣고 남은 자리를 작은 카드로
    // 메우면 열 높이 차가 가장 큰 카드 하나보다 작게 유지된다.
    final order =
        List<int>.generate(cards.length - pinned, (index) => index + pinned)
          ..sort((a, b) {
            final byHeight = heights[b].compareTo(heights[a]);
            // 높이가 같으면 작성 순서를 지켜, 같은 내용이 매번 다른 열로 튀지 않게 한다.
            return byHeight != 0 ? byHeight : a.compareTo(b);
          });

    for (final index in order) {
      var target = 0;
      for (var column = 1; column < columns; column++) {
        if (columnHeights[column] < columnHeights[target]) target = column;
      }
      assigned[target].add(index);
      columnHeights[target] +=
          (columnHeights[target] == 0 ? 0 : gap) + heights[index];
    }

    // 어느 열에 담을지는 높이가 정하지만, 열 안에서는 작성 순서대로 읽히게 한다.
    // 열 높이는 담긴 카드 집합만으로 정해지므로 이 정렬은 균형을 흔들지 않는다.
    for (var column = 0; column < columns; column++) {
      assigned[column].sort();
      var top = 0.0;
      for (final index in assigned[column]) {
        (cards[index].parentData! as _MasonryParentData).offset = Offset(
          column * (columnWidth + gap),
          top,
        );
        top += heights[index] + gap;
      }
    }

    size = constraints.constrain(
      Size(_totalWidth, columnHeights.reduce(math.max)),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

class _MasonryParentData extends ContainerBoxParentData<RenderBox> {}

void _noop() {}
