import 'package:flutter/material.dart';

/// 같은 의미에는 같은 아이콘을 쓰도록 의미와 글리프를 묶는다.
///
/// 화면이 `Icons.*`를 직접 고르면 "현재 위치"가 화면마다 다른 글리프가 된다.
/// 아이콘은 크기(16/20/24)만 토큰이 아니라 **의미 자체가 토큰**이다.
///
/// 여기에 없는 의미가 필요하면 글리프를 화면에서 고르지 말고 역할을 먼저 추가한다.
/// 분류·시설처럼 데이터에서 오는 아이콘은 이 목록이 아니라 소비 앱이 소유한다.
abstract final class RoutexIcons {
  // 탐색과 이동
  static const menu = Icons.menu_rounded;
  static const back = Icons.arrow_back_rounded;
  static const close = Icons.close_rounded;
  static const forward = Icons.chevron_right;
  static const expand = Icons.keyboard_arrow_down_rounded;
  static const collapse = Icons.keyboard_arrow_up_rounded;
  static const more = Icons.more_vert_rounded;
  static const reorder = Icons.drag_handle_rounded;

  // 검색과 장소
  static const search = Icons.search_rounded;
  static const recent = Icons.history_rounded;
  static const place = Icons.storefront_outlined;
  static const building = Icons.apartment_rounded;
  static const info = Icons.info_outline_rounded;
  static const image = Icons.image_outlined;
  static const photos = Icons.photo_library_outlined;
  static const menuBook = Icons.menu_book_outlined;
  static const schedule = Icons.schedule_outlined;
  static const link = Icons.link_rounded;
  static const share = Icons.share_outlined;

  /// 목록을 다시 세우는 기준을 고르는 자리다. 화살표 한 쌍이라 "정렬"로만 읽힌다 —
  /// 목록을 좁히는 `filter`(깔때기)와 같은 글리프를 쓰면 두 동작이 섞인다.
  static const sort = Icons.swap_vert_rounded;

  // 저장
  static const save = Icons.bookmark_border_rounded;
  static const saved = Icons.bookmark_rounded;
  static const delete = Icons.delete_outline_rounded;

  // 지도 조작
  static const currentLocation = Icons.my_location_rounded;
  static const followLocation = Icons.navigation_rounded;
  static const placeLocation = Icons.place_outlined;
  static const calibrate = Icons.explore_outlined;
  static const fitRoute = Icons.fit_screen_rounded;
  static const floors = Icons.layers_outlined;

  // 경로와 안내
  static const directions = Icons.directions_rounded;
  static const walk = Icons.directions_walk_rounded;
  static const car = Icons.directions_car_rounded;
  static const transit = Icons.directions_bus_rounded;
  static const bus = Icons.directions_bus_rounded;
  static const subway = Icons.subway_rounded;
  static const train = Icons.train_rounded;
  static const transfer = Icons.swap_calls_rounded;
  static const wrongWay = Icons.u_turn_right_rounded;
  static const turnLeft = Icons.turn_left_rounded;

  /// 경로 입력의 출발지와 도착지를 맞바꾸는 동작이다.
  ///
  /// 목록을 정렬하는 [sort]와 달리, 두 위치 필드의 순서만 바꾼다.
  static const swapLocations = Icons.swap_vert_rounded;
  static const turnRight = Icons.turn_right_rounded;
  static const straight = Icons.straight_rounded;
  static const escalator = Icons.escalator_rounded;
  static const elevator = Icons.elevator_rounded;
  static const play = Icons.play_arrow_rounded;
  static const pause = Icons.pause_rounded;
  static const muted = Icons.volume_off_rounded;
  static const unmuted = Icons.volume_up_rounded;
  static const arrived = Icons.flag_outlined;

  // 상태
  static const success = Icons.check_circle_outline_rounded;
  static const warning = Icons.warning_amber_rounded;
  static const error = Icons.error_outline_rounded;
  static const empty = Icons.inbox_outlined;
  static const debug = Icons.bug_report_outlined;
}
