import 'dart:math' as math;

const navigationPromoDurationMs = 41600;
const navigationPromoFps = 30;

/// Blender 결합 계획의 구간 경계. 이 값과 같은 숫자를 다른 파일에 복제하지 않는다.
/// 기준 문서: `docs/client/routex_web_blender_video_integration_plan.md`
const webAEndMs = 22850;
const webCSourceStartMs = 23600;
const webCSourceEndMs = navigationPromoDurationMs;
const promoTransitionFrames = 10;

/// 30fps 한 프레임의 밀리초. 전환 길이는 모두 프레임 수에서 파생한다.
const promoFrameMs = 1000 / navigationPromoFps;

int promoFrames(int count) => (count * promoFrameMs).round();

/// WEB_A 마지막 손실 구간. 마지막 10프레임에서 모바일 UI가 사라지고
/// 지도만 남으며, 마지막 4프레임에서 가장자리만 흰색으로 날아간다.
final webAHandoffStartMs = webAEndMs - promoFrames(promoTransitionFrames);
final webABloomStartMs = webAEndMs - promoFrames(4);
const webAHandoffZoom = 1.08;
const webAHandoffBloom = .92;
const webARouteIgnitionReveal = .18;

/// WEB_C 도입 구간. 첫 10프레임 동안 사다리꼴 왜곡이 풀리고,
/// 6~16프레임 사이에 앱 프레임과 안내 카드가 들어온다.
final webCUnwarpMs = promoFrames(promoTransitionFrames);
final webCUiStartMs = promoFrames(6);
final webCUiEndMs = promoFrames(16);

/// 최종 마스터를 구성하는 세 구간 중 웹이 담당하는 두 구간.
///
/// 내부 애니메이션 상수는 옮기지 않는다. 구간 시간을 원본 38.6초 시간축으로
/// 되돌려 같은 장면 코드를 그대로 재사용한다.
enum NavigationPromoSegment {
  full,
  webA,
  webC;

  int get sourceStartMs => switch (this) {
    NavigationPromoSegment.webC => webCSourceStartMs,
    _ => 0,
  };

  int get sourceEndMs => switch (this) {
    NavigationPromoSegment.full => navigationPromoDurationMs,
    NavigationPromoSegment.webA => webAEndMs,
    NavigationPromoSegment.webC => webCSourceEndMs,
  };

  int get durationMs => sourceEndMs - sourceStartMs;

  /// 구간 시간 → 원본 시간. `full`은 기존 동작을 그대로 둔다.
  int sourceTimeFor(int segmentTimeMs) => this == NavigationPromoSegment.full
      ? segmentTimeMs
      : sourceStartMs + segmentTimeMs.clamp(0, durationMs);

  int frameCount(int fps) => (durationMs * fps / 1000).ceil();

  String get label => switch (this) {
    NavigationPromoSegment.full => '전체',
    NavigationPromoSegment.webA => 'WEB_A',
    NavigationPromoSegment.webC => 'WEB_C',
  };

  static NavigationPromoSegment parse(String? value) => switch (value?.trim()) {
    'webA' || 'weba' || 'WEB_A' => NavigationPromoSegment.webA,
    'webC' || 'webc' || 'WEB_C' => NavigationPromoSegment.webC,
    _ => NavigationPromoSegment.full,
  };
}

double clamp01(num value) => value.clamp(0.0, 1.0).toDouble();

double interval(int timeMs, int startMs, int endMs) {
  if (endMs <= startMs) return timeMs >= endMs ? 1 : 0;
  return clamp01((timeMs - startMs) / (endMs - startMs));
}

double smooth(double value) {
  final t = clamp01(value);
  return t * t * (3 - 2 * t);
}

double smoother(double value) {
  final t = clamp01(value);
  return t * t * t * (t * (t * 6 - 15) + 10);
}

double easeOutCubic(double value) {
  final t = 1 - clamp01(value);
  return 1 - t * t * t;
}

double easeInOutCubic(double value) {
  final t = clamp01(value);
  return t < .5 ? 4 * t * t * t : 1 - math.pow(-2 * t + 2, 3) / 2;
}

double cinematic(double value) => smoother(value);

double pulse(int timeMs, int centerMs, int halfWidthMs) {
  final distance = (timeMs - centerMs).abs();
  if (distance >= halfWidthMs) return 0;
  return math.sin((1 - distance / halfWidthMs) * math.pi / 2);
}

double mix(double from, double to, double progress) =>
    from + (to - from) * clamp01(progress);

double sceneOpacity(
  int timeMs,
  int startMs,
  int endMs, {
  int fadeInMs = 360,
  int fadeOutMs = 360,
}) {
  final enter = interval(timeMs, startMs, startMs + fadeInMs);
  final exit = 1 - interval(timeMs, endMs - fadeOutMs, endMs);
  return clamp01(math.min(enter, exit));
}

/// 타임라인을 스크럽해도 상태가 남지 않도록 모든 영상 상태를 현재 시간만으로 만든다.
final class NavigationPromoState {
  const NavigationPromoState(this.timeMs);

  final int timeMs;

  double get opening => sceneOpacity(timeMs, 0, 6200, fadeInMs: 500);
  double get buildingReveal => sceneOpacity(timeMs, 2200, 9600);
  double get search => sceneOpacity(timeMs, 5900, 12500);
  double get routeOverview => sceneOpacity(timeMs, 11300, 16300);
  double get walking => sceneOpacity(timeMs, 15000, 18400);
  double get transfer => sceneOpacity(timeMs, 18300, 24600);
  double get destination => sceneOpacity(timeMs, 23100, 27300);
  double get hero => sceneOpacity(timeMs, 26500, 31300);
  double get endCard => interval(timeMs, 29800, 31300);

  double get outdoorRoute => cinematic(interval(timeMs, 200, 2150));
  double get buildingZoom => cinematic(interval(timeMs, 1450, 3600));
  double get floorsSeparate => cinematic(interval(timeMs, 2450, 5100));
  double get enterB1 => cinematic(interval(timeMs, 4300, 6200));

  double get searchEnter => easeOutCubic(interval(timeMs, 7700, 8300));
  double get searchTyping => interval(timeMs, 8250, 9600);
  double get searchResult => easeOutCubic(interval(timeMs, 9300, 10150));
  double get searchSelect => pulse(timeMs, 10420, 280);

  double get routeDrawB1 => cinematic(interval(timeMs, 11000, 12350));
  double get verticalRoute => cinematic(interval(timeMs, 12100, 13200));
  double get routeDrawB2 => cinematic(interval(timeMs, 12950, 14400));

  double get walkProgress => cinematic(interval(timeMs, 13800, 16800));
  double get routeCamera => cinematic(interval(timeMs, 14000, 15900));
  double get etaEnter => easeOutCubic(interval(timeMs, 14600, 15300));

  double get escalatorPulse => pulse(timeMs, 17500, 700);
  double get transferVeil =>
      sceneOpacity(timeMs, 18000, 22800, fadeInMs: 650, fadeOutMs: 850);
  double get floorSwap => cinematic(interval(timeMs, 19100, 21800));
  double get transferCard =>
      sceneOpacity(timeMs, 18300, 22200, fadeInMs: 500, fadeOutMs: 500);

  double get b2WalkProgress => cinematic(interval(timeMs, 23000, 25200));
  double get arrivalPulse => pulse(timeMs, 26100, 800);
  double get arrivalCard =>
      sceneOpacity(timeMs, 25400, 29300, fadeInMs: 600, fadeOutMs: 650);

  double get heroAssemble => cinematic(interval(timeMs, 26000, 28000));
  double get heroOrbit => cinematic(interval(timeMs, 27200, 29800));
  double get worldFade => interval(timeMs, 37300, navigationPromoDurationMs);
}
