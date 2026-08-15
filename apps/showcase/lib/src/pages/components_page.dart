import 'package:flutter/material.dart';
import 'package:routex_design_system/routex_design_system.dart';

import '../catalog/mobile_frame.dart';
import '../catalog/place_detail_catalog.dart';
import '../catalog/showcase_section.dart';
import '../data/showcase_place_detail_data.dart';

/// 컴포넌트를 조작 가능한 상태로 보여준다. 조작 상태는 이 페이지가 소유한다.
class ComponentsPage extends StatefulWidget {
  const ComponentsPage({super.key});

  @override
  State<ComponentsPage> createState() => _ComponentsPageState();
}

class _ComponentsPageState extends State<ComponentsPage> {
  int _tab = 0;
  int _route = 0;
  bool _saved = false;
  String _travelMode = 'walk';
  String? _category = '음식점';
  int _floor = 1;
  bool _autoIndoor = true;
  String _sort = 'name';
  int _itinerary = 0;

  /// 상세 내용은 Navigation 백엔드의 오설록 매장에서 온다.
  static const _detail = ShowcasePlaceDetail.osulloc;

  /// 영업 판정 기준 시각. 카탈로그가 `DateTime.now`를 부르면 화면이 시각마다 달라져
  /// 같은 페이지를 두 번 볼 때 다른 상태가 된다.
  static final _now = DateTime(2026, 8, 18, 14, 30);
  @override
  Widget build(BuildContext context) {
    return RoutexStack(
      gap: RoutexStackGap.section,
      children: [
        ShowcaseSection(
          title: '행동 · beta',
          description: '주 행동 하나, 44dp 시각 높이와 48dp 터치 영역을 제품 폭에서 확인합니다.',
          child: _FrameRow(
            children: [
              MobileFrame(
                label: '버튼 위계',
                surface: MobileFrameSurface.sheet,
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
                    const RoutexButton(
                      label: '경로 계산 중',
                      onPressed: null,
                      isLoading: true,
                    ),
                  ],
                ),
              ),
              MobileFrame(
                label: '아이콘 동작과 지도 조작',
                surface: MobileFrameSurface.map,
                child: RoutexCluster(
                  gap: RoutexClusterGap.control,
                  children: [
                    RoutexIconAction(
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
                      label: '현재 위치 추적 중',
                      icon: RoutexIcons.followLocation,
                      selected: true,
                      onPressed: () {},
                    ),
                    RoutexMapControl(
                      label: '층 선택',
                      icon: RoutexIcons.floors,
                      text: '1F',
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: '목록과 묶음 · beta',
          description: 'leading 유무와 관계없이 텍스트 열을 유지하고, 묶음 제목과 구획 라벨을 구분합니다.',
          child: _FrameRow(
            children: [
              MobileFrame(
                label: '장소 목록',
                surface: MobileFrameSurface.sheet,
                child: RoutexStack(
                  gap: RoutexStackGap.control,
                  children: [
                    RoutexSectionHeader(
                      title: '최근 검색',
                      actionLabel: '전체 보기',
                      onAction: () {},
                    ),
                    const RoutexListCell(
                      title: '더현대 서울',
                      subtitle: '1F · 패션',
                      leadingIcon: RoutexIcons.place,
                      trailingIcon: RoutexIcons.forward,
                      onPressed: _noop,
                    ),
                    const RoutexListCell(
                      title: '아이콘이 없는 선택 상태',
                      subtitle: '텍스트 시작선은 위 행과 같습니다.',
                      selected: true,
                      onPressed: _noop,
                    ),
                    const RoutexListCell(
                      title: '보조정보가 없는 장소',
                      onPressed: _noop,
                    ),
                    const RoutexListCell(
                      title: '현재 사용할 수 없는 장소',
                      enabled: false,
                      onPressed: _noop,
                    ),
                  ],
                ),
              ),
              MobileFrame(
                label: '저장한 장소 (순서 바꾸기)',
                surface: MobileFrameSurface.sheet,
                child: RoutexStack(
                  gap: RoutexStackGap.control,
                  children: [
                    const RoutexSectionHeader(
                      title: '저장한 장소',
                      level: RoutexSectionHeaderLevel.group,
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
            ],
          ),
        ),
        ShowcaseSection(
          title: '입력과 필터 · beta',
          description: '검색 진입과 목록·지도를 좁히는 선택지가 같은 규칙을 씁니다.',
          child: _FrameRow(
            children: [
              MobileFrame(
                label: '검색 줄',
                surface: MobileFrameSurface.map,
                child: RoutexStack(
                  gap: RoutexStackGap.content,
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
                        for (final name in const ['패션', '음식점', '편의시설'])
                          RoutexChipOption.category(name),
                      ],
                      selectedId: _category,
                      onSelected: (value) => setState(() => _category = value),
                    ),
                  ],
                ),
              ),
              MobileFrame(
                label: '경로 입력',
                surface: MobileFrameSurface.map,
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
            ],
          ),
        ),
        ShowcaseSection(
          title: '표면 · beta',
          description: '시트와 탭은 곡률·여백·handle·header를 공통 규칙으로 씁니다.',
          child: _FrameRow(
            children: [
              MobileFrame(
                label: '하단 표면과 탭',
                surface: MobileFrameSurface.map,
                child: RoutexStack(
                  gap: RoutexStackGap.content,
                  children: [
                    RoutexTabs(
                      labels: const ['홈', '메뉴', '사진'],
                      selectedIndex: _tab,
                      onSelected: (value) => setState(() => _tab = value),
                    ),
                    const RoutexBottomSheet(
                      child: Text(
                        '하단 표면은 handle, 곡률, 내부 여백과 지도 위 그림자를 공통 규칙으로 사용합니다.',
                        style: RoutexTypography.body,
                      ),
                    ),
                  ],
                ),
              ),
              MobileFrame(
                label: '제목이 있는 시트',
                surface: MobileFrameSurface.map,
                child: RoutexBottomSheet(
                  header: RoutexSheetHeader(
                    title: '저장한 장소',
                    onBack: () {},
                    onClose: () {},
                  ),
                  child: const RoutexListCell(
                    title: '발렌시아가',
                    subtitle: '더현대 서울 1F',
                    leadingIcon: RoutexIcons.saved,
                    onPressed: _noop,
                  ),
                ),
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: '장소와 안내 · beta',
          description: '장소 요약, 다음 행동, 경로 선택과 진행 정보가 같은 위계를 유지합니다.',
          child: _FrameRow(
            children: [
              MobileFrame(
                label: '장소 요약',
                surface: MobileFrameSurface.sheet,
                child: RoutexPlaceHeader(
                  name: '발렌시아가',
                  metadata: '1F · 패션 · 명품',
                  supportingText: '더현대 서울 · 현재 위치에서 약 320m',
                  saved: _saved,
                  onSaved: (value) => setState(() => _saved = value),
                  onToggleExpanded: () {},
                ),
              ),
              MobileFrame(
                label: '경로 선택',
                surface: MobileFrameSurface.sheet,
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
              MobileFrame(
                label: '안내 중',
                surface: MobileFrameSurface.map,
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
                        RoutexTripMetric(value: '6분 후', label: '예상 시각'),
                        RoutexTripMetric(value: '6분', label: '남은 시간'),
                        RoutexTripMetric(value: '410m', label: '남은 거리'),
                      ],
                      onStop: () {},
                    ),
                  ],
                ),
              ),
              MobileFrame(
                label: '층 선택',
                surface: MobileFrameSurface.map,
                fitContent: true,
                child: RoutexFloorSelector(
                  options: const [
                    RoutexFloorOption(id: 2, label: '2F'),
                    RoutexFloorOption(id: 1, label: '1F'),
                    RoutexFloorOption(id: -1, label: 'B1'),
                  ],
                  selectedId: _floor,
                  onSelected: (value) => setState(() => _floor = value),
                ),
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: '상태 · beta',
          description: '짧은 결과, 완료·경고, 상세 정보와 빈 값이 각자 다른 표면을 씁니다.',
          child: _FrameRow(
            children: [
              MobileFrame(
                label: '결과와 완료',
                surface: MobileFrameSurface.map,
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
              const MobileFrame(
                label: '정보와 빈 값',
                surface: MobileFrameSurface.sheet,
                child: RoutexStack(
                  gap: RoutexStackGap.content,
                  children: [
                    RoutexInfoSection(
                      title: '영업시간',
                      rows: ['등록된 영업시간 정보가 없습니다.'],
                    ),
                    RoutexEmptyState(
                      title: '사진 없음',
                      description: '이 매장은 등록된 사진이 없습니다.',
                      icon: RoutexIcons.image,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: '매장 상세 · beta',
          description:
              '실제 Navigation 백엔드의 오설록 매장 상세를 Runtime Kit 컴포넌트로만 조립합니다. '
              '사진, 주 행동, 영업시간, 사실 행, 판매 목록과 외부 링크가 같은 시작선과 '
              '세로 리듬을 씁니다.',
          child: _FrameRow(
            children: [
              MobileFrame(
                label: '사진과 주 행동',
                surface: MobileFrameSurface.sheet,
                child: PlaceDetailHeaderCard(detail: _detail),
              ),
              MobileFrame(
                label: '영업시간과 사실 행',
                surface: MobileFrameSurface.sheet,
                child: PlaceFactsCard(detail: _detail, now: _now),
              ),
              MobileFrame(
                label: '판매 목록',
                surface: MobileFrameSurface.sheet,
                child: PlaceMenuCard(detail: _detail),
              ),
              MobileFrame(
                label: '공식 채널과 사진',
                surface: MobileFrameSurface.sheet,
                child: RoutexStack(
                  gap: RoutexStackGap.section,
                  children: [
                    PlaceLinksCard(detail: _detail),
                    PlacePhotosCard(detail: _detail),
                  ],
                ),
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: '목록과 대기 · beta',
          description:
              '찾는 중과 찾지 못함이 서로 다른 화면입니다. 정렬은 쓸 수 없는 기준도 이유와 함께 '
              '남기고, 자리표시는 글자 배율을 따라 커집니다.',
          child: _FrameRow(
            children: [
              MobileFrame(
                label: '결과와 정렬',
                surface: MobileFrameSurface.sheet,
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
                  children: [
                    RoutexListCell(
                      title: '발렌시아가',
                      subtitle: '1F · 명품 · 약 320m',
                      leadingIcon: RoutexIcons.place,
                      onPressed: _noop,
                    ),
                    RoutexListCell(
                      title: '메종 마르지엘라',
                      subtitle: '1F · 명품 · 약 340m',
                      leadingIcon: RoutexIcons.place,
                      onPressed: _noop,
                    ),
                  ],
                ),
              ),
              const MobileFrame(
                label: '찾는 중',
                surface: MobileFrameSurface.sheet,
                child: RoutexResultList(
                  status: RoutexResultStatus.loading,
                  loadingMessage: '실내 매장을 찾는 중',
                  children: [],
                ),
              ),
              const MobileFrame(
                label: '찾지 못함',
                surface: MobileFrameSurface.sheet,
                child: RoutexResultList(
                  status: RoutexResultStatus.empty,
                  children: [],
                ),
              ),
              MobileFrame(
                label: '설정과 알림',
                surface: MobileFrameSurface.sheet,
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
                    RoutexButton(
                      label: '토스트 띄우기',
                      variant: RoutexButtonVariant.secondary,
                      onPressed: () => RoutexToast.show(context, '복사했습니다'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: '경로와 도착 · beta',
          description:
              '계획 화면은 도착 시각과 시작을, 안내 화면은 지금 할 하나를, 도착 화면은 '
              '어디에 닿았는지를 말합니다.',
          child: _FrameRow(
            children: [
              MobileFrame(
                label: '대중교통 후보',
                surface: MobileFrameSurface.sheet,
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
                        RoutexTransitLeg(
                          label: '도보 5분',
                          icon: RoutexIcons.walk,
                        ),
                        RoutexTransitLeg(
                          label: '5호선',
                          icon: RoutexIcons.subway,
                          accent: RoutexBadgeAccent(
                            surface: Color(0xFFEDE9F6),
                            ink: Color(0xFF5B3FA6),
                          ),
                        ),
                        RoutexTransitLeg(
                          label: '도보 3분',
                          icon: RoutexIcons.walk,
                        ),
                      ],
                    ),
                    RoutexTransitItinerary(
                      duration: '38분',
                      facts: const ['환승 없음', '도보 12분', '1,500원'],
                      selected: _itinerary == 1,
                      onPressed: () => setState(() => _itinerary = 1),
                      legs: const [
                        RoutexTransitLeg(
                          label: '도보 12분',
                          icon: RoutexIcons.walk,
                        ),
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
              MobileFrame(
                label: '단계 목록',
                surface: MobileFrameSurface.sheet,
                child: RoutexStepList(
                  currentIndex: 1,
                  steps: const [
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
                    RoutexStep(
                      instruction: '목적지 도착',
                      icon: RoutexIcons.arrived,
                    ),
                  ],
                ),
              ),
              MobileFrame(
                label: '계획과 도착',
                surface: MobileFrameSurface.map,
                child: RoutexStack(
                  gap: RoutexStackGap.content,
                  children: [
                    RoutexEtaCard(
                      arrivalTime: '오후 3:24',
                      metrics: const [
                        RoutexTripMetric(value: '22분', label: '소요'),
                        RoutexTripMetric(value: '1.4km', label: '거리'),
                      ],
                      onStart: () {},
                      onCancel: () {},
                    ),
                    RoutexArrivalCard(
                      destination: '발렌시아가',
                      floor: '1F',
                      detail: '왼쪽 에스컬레이터 옆',
                      onClose: () {},
                      onShowDetail: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void _noop() {}

/// 제품 폭 틀을 가로 공간이 허용하는 만큼 나란히 흘린다.
///
/// 세로로만 쌓으면 넓은 화면에서 스크롤만 길어지고, 같은 섹션의 컴포넌트를 나란히
/// 비교할 수 없다.
class _FrameRow extends StatelessWidget {
  const _FrameRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: RoutexSpacing.sectionGap,
      runSpacing: RoutexSpacing.sectionGap,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: children,
    );
  }
}
