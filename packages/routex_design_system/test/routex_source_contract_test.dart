import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

typedef _SourceException = ({
  int occurrences,
  String reason,
  String removeWhen,
});

/// 좌표 보정은 원칙적으로 금지한다. 아래 항목만 glyph live area가 수학적 box와
/// 다른 동안 허용하며, 이유와 제거 조건이 없는 예외는 등록할 수 없다.
const _transformExceptions = <String, _SourceException>{
  'lib/src/components/routex_sheet_header.dart': (
    occurrences: 2,
    reason: '뒤로·닫기 glyph의 live area를 RoutexListCell 좌우 glyph 중심과 맞춘다.',
    removeWhen: '아이콘 세트가 정규화된 live area를 제공하거나 두 컴포넌트가 같은 glyph frame을 공유한다.',
  ),
};

final _rawVisualRules = <String, RegExp>{
  '직접 색상': RegExp(r'\bColor\(0x'),
  '직접 Material 색상': RegExp(r'\bColors\.(?!transparent\b)'),
  '직접 글자 크기': RegExp(r'\bfontSize:\s*-?(?:\d|\.\d)'),
  '직접 시각 크기': RegExp(
    r'\b(?:width|height|size|minWidth|maxWidth|minHeight|maxHeight|thickness|blurRadius|spreadRadius|elevation):\s*-?(?:\d|\.\d)',
  ),
  '직접 투명도': RegExp(r'\b(?:alpha|opacity):\s*-?(?:\d|\.\d)'),
  '직접 inset': RegExp(
    r'\bEdgeInsets(?:Directional)?\.[^(]+\([^\n)]*(?<![A-Za-z0-9_])(?:\d|\.\d)',
  ),
  '직접 radius': RegExp(
    r'\b(?:BorderRadius|Radius)(?:\.circular)?\([^\n)]*(?<![A-Za-z0-9_])(?:\d|\.\d)',
  ),
  '직접 duration': RegExp(r'\bDuration\([^\n)]*(?:\d|\.\d)'),
  'private 매직 상수': RegExp(
    r'\bstatic\s+const\s+_[A-Za-z0-9_]+\s*=\s*-?(?:\d|\.\d)',
  ),
  '직접 글자 배율 분기': RegExp(r'\btextScale\s*(?:>|>=|<|<=|==)\s*(?:\d|\.\d)'),
  '직접 비율': RegExp(r'(?<![A-Za-z0-9_])(?:0?\.\d+)'),
};

void main() {
  test('source guard 규칙 자체가 대표 직접 값을 모두 거부한다', () {
    final samples = <String, String>{
      '직접 색상': 'color: Color(0xFFFFFFFF)',
      '직접 Material 색상': 'color: Colors.red',
      '직접 글자 크기': 'fontSize: 15',
      '직접 시각 크기': 'maxWidth: 333',
      '직접 투명도': 'alpha: 0.4',
      '직접 inset': 'padding: EdgeInsets.all(7)',
      '직접 radius': 'radius: Radius.circular(7)',
      '직접 duration': 'Duration(milliseconds: 90)',
      'private 매직 상수': 'static const _offset = 3.0;',
      '직접 글자 배율 분기': 'textScale > 1.4',
      '직접 비율': 'factor = 0.65',
    };

    for (final entry in samples.entries) {
      expect(
        _rawVisualRules[entry.key]!.hasMatch(entry.value),
        isTrue,
        reason: '${entry.key} guard가 ${entry.value}를 놓치면 안 된다',
      );
    }
    final tokenized = 'width: RoutexMetrics.standardControl';
    expect(
      _rawVisualRules.values.any((rule) => rule.hasMatch(tokenized)),
      isFalse,
    );
  });

  test('components·patterns·layout은 foundation 밖의 직접 시각 값을 만들지 않는다', () {
    final files = <File>[
      for (final directory in const [
        'lib/src/components',
        'lib/src/patterns',
        'lib/src/layout',
      ])
        ...Directory(directory)
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => file.path.endsWith('.dart')),
    ];

    final violations = <String>[];
    for (final file in files) {
      final source = file.readAsStringSync();
      for (final entry in _rawVisualRules.entries) {
        for (final match in entry.value.allMatches(source)) {
          final line =
              '\n'.allMatches(source.substring(0, match.start)).length + 1;
          violations.add('${file.path}:$line ${entry.key}: ${match.group(0)}');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: '값을 foundation token 또는 이름 있는 component geometry 계약으로 승격한다.',
    );
  });

  test('Transform 기반 optical correction은 이유와 제거 조건이 있는 파일만 쓴다', () {
    final files = <File>[
      for (final directory in const [
        'lib/src/components',
        'lib/src/patterns',
        'lib/src/layout',
      ])
        ...Directory(directory)
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => file.path.endsWith('.dart')),
    ];

    final actual = <String, int>{};
    for (final file in files) {
      final count = 'Transform.translate('
          .allMatches(file.readAsStringSync())
          .length;
      // 허용 목록의 key는 저장소 기준 POSIX 경로다. Windows의 `listSync`는
      // `\`로 된 경로를 돌려주므로 그대로 쓰면 같은 파일이 다른 key가 되어
      // 예외가 등록돼 있어도 실패한다.
      if (count > 0) actual[file.path.replaceAll(r'\', '/')] = count;
    }

    expect(actual, {
      for (final entry in _transformExceptions.entries)
        entry.key: entry.value.occurrences,
    });
    for (final exception in _transformExceptions.values) {
      expect(exception.reason.trim(), isNotEmpty);
      expect(exception.removeWhen.trim(), isNotEmpty);
    }
  });
}
