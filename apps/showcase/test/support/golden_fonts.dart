import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// 골든은 실제 글꼴로 그려야 의미가 있다. 글꼴을 싣지 않으면 모든 글자가 네모로
/// 나와, 자간·줄바꿈·글자 높이가 어긋나도 그림이 똑같아 보인다.
Future<void> loadGoldenFonts() async {
  final pretendard = FontLoader('packages/routex_design_system/Pretendard')
    ..addFont(
      rootBundle.load(
        'packages/routex_design_system/assets/fonts/Pretendard-Regular.otf',
      ),
    );
  final materialIcons = FontLoader('MaterialIcons')
    ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
  final cupertinoIcons = FontLoader('packages/cupertino_icons/CupertinoIcons')
    ..addFont(
      rootBundle.load('packages/cupertino_icons/assets/CupertinoIcons.ttf'),
    );
  await Future.wait([
    pretendard.load(),
    materialIcons.load(),
    cupertinoIcons.load(),
  ]);
}
