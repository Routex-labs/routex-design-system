import 'package:flutter_test/flutter_test.dart';
import 'package:showcase/main.dart';

void main() {
  testWidgets('Runtime Kit의 foundation과 실제 버튼을 렌더링한다', (tester) async {
    await tester.pumpWidget(const RoutexShowcaseApp());

    expect(find.text('Routex Design System'), findsOneWidget);
    expect(find.text('Semantic colors'), findsOneWidget);
    expect(find.text('Button · beta'), findsOneWidget);
    expect(find.text('길찾기'), findsOneWidget);
    expect(find.text('Motion boundary'), findsOneWidget);
  });
}
