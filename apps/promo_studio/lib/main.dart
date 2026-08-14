import 'package:flutter/material.dart';

import 'promo/navigation_promo_scene.dart';
import 'promo/navigation_promo_studio.dart';
import 'promo/navigation_promo_timeline.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final staticTime = int.tryParse(Uri.base.queryParameters['time'] ?? '');
  // `?segment=webA|webC`는 구간 시간축을 쓴다. `time`은 구간 시작을 0으로 본다.
  final segment = NavigationPromoSegment.parse(
    Uri.base.queryParameters['segment'],
  );
  runApp(
    staticTime == null
        ? NavigationPromoApp(segment: segment)
        : MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            home: NavigationPromoScene(timeMs: staticTime, segment: segment),
          ),
  );
}
