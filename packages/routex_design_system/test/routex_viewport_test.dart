import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_design_system/routex_design_system.dart';

/// 공개한 컴포넌트와 제품 패턴 전체를 대표 폭과 글자 배율에서 함께 렌더링한다.
///
/// 개별 컴포넌트 계약은 각 layer의 test가 맡고, 여기서는 좁은 폭과 큰 글자에서
/// 가로 overflow가 생기지 않는지만 한 번에 확인한다.
void main() {
  const viewports = [360.0, 390.0];
  const textScales = [1.0, 1.3, 2.0];

  for (final width in viewports) {
    for (final scale in textScales) {
      testWidgets(
        '공개 UI 세트 ${width.toInt()}px · ${scale.toStringAsFixed(1)}×에서 overflow가 없다',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = Size(width, 2400);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPhysicalSize);

          await tester.pumpWidget(
            MaterialApp(
              theme: RoutexTheme.light,
              home: MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                child: const Scaffold(body: _PublicUiSet()),
              ),
            ),
          );
          await tester.pump();

          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

class _PublicUiSet extends StatelessWidget {
  const _PublicUiSet();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: RoutexInset(
        role: RoutexInsetRole.screen,
        child: RoutexStack(
          gap: RoutexStackGap.content,
          children: [
            RoutexButton(label: '길찾기', onPressed: () {}),
            const RoutexButton(
              label: '경로 계산 중',
              onPressed: null,
              isLoading: true,
            ),
            RoutexCluster(
              gap: RoutexClusterGap.control,
              children: [
                RoutexIconAction(
                  label: '장소 저장',
                  icon: Icons.bookmark_border_rounded,
                  onPressed: () {},
                ),
                RoutexMapControl(
                  label: '현재 위치',
                  icon: Icons.my_location_rounded,
                  onPressed: () {},
                ),
              ],
            ),
            RoutexListCell(
              title: '더현대 서울',
              subtitle: '1F · 패션 · 현재 위치에서 약 320m',
              leadingIcon: Icons.storefront_outlined,
              trailingIcon: Icons.chevron_right,
              onPressed: () {},
            ),
            RoutexTabs(
              labels: const ['홈', '메뉴', '사진'],
              selectedIndex: 0,
              onSelected: (_) {},
            ),
            const RoutexBottomSheet(
              child: Text(
                '하단 표면은 handle, 곡률, 내부 여백과 지도 위 그림자를 공통 규칙으로 사용합니다.',
                style: RoutexTypography.body,
              ),
            ),
            RoutexSearchBar(
              placeholder: '건물, 장소를 검색하세요',
              onSearchPressed: () {},
              leading: RoutexSearchLeading.menu,
              onLeadingPressed: () {},
              onDirectionsPressed: () {},
            ),
            RoutexRoutePlanner(
              originLabel: '현재 위치',
              destinationLabel: '더현대 서울 1F · 발렌시아가',
              travelModes: const [
                RoutexTravelModeOption(
                  id: 'car',
                  label: '자동차',
                  icon: Icons.directions_car_rounded,
                ),
                RoutexTravelModeOption(
                  id: 'walk',
                  label: '도보',
                  icon: Icons.directions_walk_rounded,
                ),
              ],
              selectedTravelModeId: 'walk',
              onTravelModeSelected: (_) {},
              onOriginPressed: () {},
              onDestinationPressed: () {},
              onClose: () {},
              onDestinationMore: () {},
            ),
            RoutexPlaceHeader(
              name: '발렌시아가',
              metadata: '1F · 패션 · 명품',
              supportingText: '더현대 서울 · 현재 위치에서 약 320m',
              saved: false,
              onSaved: (_) {},
              onToggleExpanded: () {},
            ),
            const RoutexManeuverBanner(
              distance: '120m 후 건물로 진입',
              detail: '더현대 서울 1층 · 명품관 방향',
              icon: Icons.turn_right_rounded,
            ),
            RoutexRouteOption(
              title: '6분',
              detail: '410m · 실내 연결 통로',
              meta: '추천',
              selected: true,
              onPressed: () {},
            ),
            RoutexTripProgress(
              metrics: const [
                RoutexTripMetric(value: '오후 3:24', label: '도착 예정'),
                RoutexTripMetric(value: '6분', label: '남은 시간'),
                RoutexTripMetric(value: '410m', label: '남은 거리'),
              ],
              onStop: () {},
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RoutexFloorSelector(
                  options: const [
                    RoutexFloorOption(id: '1F', label: '1F'),
                    RoutexFloorOption(id: 'B1', label: 'B1'),
                  ],
                  selectedId: '1F',
                  onSelected: (_) {},
                ),
                const SizedBox(width: RoutexSpacing.contentGap),
                const Expanded(
                  child: RoutexStatusBanner(
                    title: '목적지에 도착했습니다',
                    detail: '더현대 서울 · 1F 발렌시아가 앞',
                    icon: Icons.check_circle_outline_rounded,
                    tone: RoutexStatusBannerTone.success,
                  ),
                ),
              ],
            ),
            RoutexInlineNotice(
              message: '장소를 저장했습니다.',
              actionLabel: '실행 취소',
              onAction: () {},
            ),
            const RoutexInfoSection(
              title: '영업시간',
              rows: ['등록된 영업시간 정보가 없습니다.'],
            ),
            const RoutexEmptyState(
              title: '사진 없음',
              description: '이 매장은 등록된 사진이 없습니다.',
              icon: Icons.image_outlined,
            ),
            RoutexPlaceActions(onOrigin: () {}, onDestination: () {}),
            RoutexPlaceOverview(
              name: '아주 긴 한글 이름의 실내 매장',
              metadata: 'B1 · 카페·베이커리',
              saved: false,
              onClose: () {},
              onShare: () {},
              onSaved: (_) {},
              onOrigin: () {},
              onDestination: () {},
            ),
            RoutexHours(
              state: RoutexHoursState.open,
              detail: '20:00 종료',
              days: const [
                RoutexHoursDay(label: '화', value: '10:30 - 20:00'),
                RoutexHoursDay(
                  label: '수',
                  value: '휴무',
                  note: '정기 휴점',
                  closed: true,
                ),
              ],
              expanded: true,
              onExpanded: (_) {},
              staleNote: '2026-05-01 기준 · 영업시간이 달라졌을 수 있어요',
            ),
            const RoutexInfoRow(
              label: '고객센터',
              value: '1522-3232 (평일 09:00–18:00)',
              icon: Icons.support_agent_outlined,
              keepLabel: true,
              copyText: '1522-3232',
            ),
            RoutexKeyValueRows(
              rows: const [
                RoutexKeyValue(label: '용량', value: '355ml'),
                RoutexKeyValue(
                  label: '알레르기',
                  value: '땅콩 / 대두 / 우유 / 알류 / 밀 / 오징어',
                ),
              ],
            ),
            RoutexMenuList(
              entries: const [
                RoutexMenuEntry(
                  name: '아이스 카페 아메리카노',
                  description: '에스프레소에 시원한 물을 더한 커피',
                  price: '4,500원',
                  badges: [RoutexBadge(label: 'NEW')],
                ),
              ],
              expanded: false,
              onExpanded: (_) {},
              onSelected: (_) {},
            ),
            RoutexLinkList(
              items: const [
                RoutexLinkItem(
                  label: '공식 사이트',
                  url: 'https://www.example.com/stores/seoul',
                  display: RoutexLinkDisplay.url,
                ),
              ],
              onSelected: (_) {},
            ),
            RoutexResultList(
              status: RoutexResultStatus.ready,
              summary: '32개 결과',
              sortOptions: const [
                RoutexSortOption(id: 'near', label: '가까운 순'),
                RoutexSortOption(id: 'name', label: '이름 맞춤 순'),
              ],
              selectedSortId: 'near',
              onSortSelected: (_) {},
              children: const [
                RoutexListCell(title: '발렌시아가', subtitle: '1F · 명품'),
              ],
            ),
            const RoutexResultList(
              status: RoutexResultStatus.loading,
              loadingMessage: '실내 매장을 찾는 중',
              children: [],
            ),
            RoutexSwitchRow(
              title: '실내 진입 자동 전환',
              description: '건물 입구에 닿으면 실내 도면으로 바꾼다',
              value: true,
              onChanged: (_) {},
            ),
            RoutexTransitItinerary(
              duration: '35분',
              facts: const ['환승 1회', '도보 8분', '1,500원'],
              fastest: true,
              legs: const [
                RoutexTransitLeg(
                  label: '도보 5분',
                  icon: Icons.directions_walk_rounded,
                ),
                RoutexTransitLeg(label: '5호선', icon: Icons.subway_rounded),
                RoutexTransitLeg(
                  label: '간선 472',
                  icon: Icons.directions_bus_rounded,
                ),
              ],
              onPressed: () {},
            ),
            RoutexStepList(
              currentIndex: 0,
              steps: const [
                RoutexStep(
                  instruction: '오른쪽 통로로 이동',
                  icon: Icons.turn_right_rounded,
                  distance: '92m',
                  detail: '3층 에스컬레이터 옆',
                ),
                RoutexStep(instruction: '목적지 도착', icon: Icons.flag_outlined),
              ],
            ),
            RoutexEtaCard(
              arrivalTime: '오후 3:24',
              metrics: const [
                RoutexTripMetric(value: '22분', label: '소요'),
                RoutexTripMetric(value: '1.4km', label: '거리'),
              ],
              onStart: () {},
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
    );
  }
}
