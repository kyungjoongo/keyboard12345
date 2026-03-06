import 'package:flutter_test/flutter_test.dart';
import 'package:keyboard12345/main.dart';

void main() {
  testWidgets('Keyboard app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const KeyboardApp());
    expect(find.byType(KeyboardApp), findsOneWidget);
  });
}
