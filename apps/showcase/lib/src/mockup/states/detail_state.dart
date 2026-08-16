import 'package:flutter/material.dart';
import 'package:routex_design_system/routex_design_system.dart';

import '../../data/showcase_navigation_data.dart';

class DetailState extends StatefulWidget {
  const DetailState({
    required this.place,
    required this.saved,
    required this.onSaved,
    required this.onRoute,
    required this.onClose,
    super.key,
  });

  final ShowcasePlaceData place;
  final bool saved;
  final ValueChanged<bool> onSaved;
  final VoidCallback onRoute;
  final VoidCallback onClose;

  @override
  State<DetailState> createState() => DetailStateState();
}

class DetailStateState extends State<DetailState> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return RoutexMapOverlay(
      sheetExtent: RoutexSheetExtent.large,
      sheet: RoutexBottomSheet(
        expand: true,
        showHandle: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RoutexPlaceHeader(
              name: widget.place.name,
              metadata:
                  '${widget.place.floorName} · ${widget.place.category}${widget.place.subcategory == null ? '' : ' · ${widget.place.subcategory}'}',
              saved: widget.saved,
              onShare: () => RoutexToast.show(context, '장소 공유 링크를 준비했습니다'),
              onSaved: widget.onSaved,
              expanded: true,
              onToggleExpanded: widget.onClose,
            ),
            const SizedBox(height: RoutexSpacing.contentGap),
            RoutexPlaceActions(
              onOrigin: widget.place.entranceNodeId == null
                  ? null
                  : widget.onRoute,
              onDestination: widget.place.entranceNodeId == null
                  ? null
                  : widget.onRoute,
            ),
            const SizedBox(height: RoutexSpacing.sectionGap),
            RoutexTabs(
              labels: const ['홈', '메뉴', '사진'],
              selectedIndex: _tab,
              onSelected: (value) => setState(() => _tab = value),
            ),
            const SizedBox(height: RoutexSpacing.componentPadding),
            Expanded(
              child: SingleChildScrollView(
                child: switch (_tab) {
                  0 => RoutexStack(
                    gap: RoutexStackGap.section,
                    children: [
                      const RoutexInfoSection(
                        title: '영업시간',
                        rows: ['등록된 영업시간 정보가 없습니다.'],
                      ),
                      RoutexInfoSection(
                        title: '매장 정보',
                        rows: [
                          '${widget.place.buildingName} ${widget.place.floorName}',
                          '${widget.place.category}${widget.place.subcategory == null ? '' : ' · ${widget.place.subcategory}'}',
                        ],
                      ),
                      RoutexInfoSection(
                        title: '길찾기',
                        rows: [
                          widget.place.entranceNodeId == null
                              ? '도착 노드가 없어 길찾기를 시작할 수 없습니다.'
                              : '매장 입구 도착 노드가 연결되어 있습니다.',
                          '도보·휠체어 경로는 경로 화면에서 선택합니다.',
                        ],
                      ),
                    ],
                  ),
                  1 => const RoutexEmptyState(
                    title: '메뉴 정보 없음',
                    description: '이 매장은 등록된 메뉴 정보가 없습니다.',
                    icon: RoutexIcons.menuBook,
                  ),
                  _ => const RoutexEmptyState(
                    title: '사진 없음',
                    description: '이 매장은 등록된 사진이 없습니다.',
                    icon: RoutexIcons.image,
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
