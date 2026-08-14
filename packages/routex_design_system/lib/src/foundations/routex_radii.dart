import 'package:flutter/widgets.dart';

/// 컴포넌트 경계가 맡는 역할이다.
enum RoutexRadiusRole { control, field, card, sheet, full }

extension RoutexRadiusRoleValue on RoutexRadiusRole {
  BorderRadius get borderRadius => switch (this) {
    RoutexRadiusRole.control => RoutexRadii.control,
    RoutexRadiusRole.field => RoutexRadii.field,
    RoutexRadiusRole.card => RoutexRadii.card,
    RoutexRadiusRole.sheet => RoutexRadii.sheet,
    RoutexRadiusRole.full => RoutexRadii.full,
  };
}

/// 크기가 아니라 컴포넌트 역할에 연결된 곡률이다.
abstract final class RoutexRadii {
  static const control = BorderRadius.all(Radius.circular(8));
  static const field = BorderRadius.all(Radius.circular(12));
  static const card = BorderRadius.all(Radius.circular(16));
  static const sheet = BorderRadius.vertical(top: Radius.circular(24));
  static const full = BorderRadius.all(Radius.circular(999));
}
