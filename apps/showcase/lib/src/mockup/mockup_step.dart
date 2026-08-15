enum MockupStep { home, place, detail, route, guidance, indoor, arrival }

extension MockupStepContract on MockupStep {
  /// 지도 도면·경로·마커를 실제로 보여주는 단계인지 여부다.
  ///
  /// 메인·장소·상세·경로 미리보기는 단색 지도 canvas만 남긴다. 경로와 위치
  /// 관계를 읽어야 하는 이동 안내·실내 전환·도착에서만 Showcase의 지도 시각
  /// 계층을 켠다.
  bool get showsMapVisuals => switch (this) {
    MockupStep.home ||
    MockupStep.place ||
    MockupStep.detail ||
    MockupStep.route => false,
    MockupStep.guidance || MockupStep.indoor || MockupStep.arrival => true,
  };

  String get label => switch (this) {
    MockupStep.home => '메인',
    MockupStep.place => '장소 선택',
    MockupStep.detail => '상세 정보',
    MockupStep.route => '경로 미리보기',
    MockupStep.guidance => '이동 안내',
    MockupStep.indoor => '실내 전환',
    MockupStep.arrival => '도착',
  };

  String get primaryAction => switch (this) {
    MockupStep.home => '장소 검색',
    MockupStep.place => '길찾기',
    MockupStep.detail => '출발·도착 설정',
    MockupStep.route => '안내 시작',
    MockupStep.guidance => '다음 행동 확인',
    MockupStep.indoor => '현재 층의 다음 행동',
    MockupStep.arrival => '안내 종료',
  };

  String get behavior => switch (this) {
    MockupStep.home =>
      '단색 지도 canvas 위에서 검색과 분류로 시작하고, 최근·저장한 장소는 지도를 가리지 않는 높이의 시트에 둡니다.',
    MockupStep.place => '단색 지도 canvas 위에 장소 요약을 띄우고, 저장은 상태 토글로 처리합니다.',
    MockupStep.detail => '단색 지도 canvas는 유지한 채 시트를 확장해 홈·메뉴·사진과 영업 정보를 봅니다.',
    MockupStep.route =>
      '단색 지도 canvas 위에서 경로 한 개와 이동수단을 선택하고, 실제 경로 시각은 안내 시작 뒤 표시합니다.',
    MockupStep.guidance =>
      '원본 Navigation 기준 경로선·현재 위치·목적지 마커를 지도 시각 계층으로 표시하며, 지도를 움직이면 추적을 멈춥니다.',
    MockupStep.indoor =>
      '실내 도면과 경로·마커를 표시하고, 현재 층을 자동 추적하며 수동 층 선택 뒤 다시 현재 층으로 복귀할 수 있습니다.',
    MockupStep.arrival =>
      '도착 상태의 실내 경로·목적지·현재 위치를 남기고, 안내 종료와 장소 상세 행동을 제공합니다.',
  };
}
