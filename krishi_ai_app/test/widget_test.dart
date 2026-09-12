import 'package:flutter_test/flutter_test.dart';
import 'package:krishi_ai_app/main.dart';

void main() {
  testWidgets('KrishiAI App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const KrishiAiApp());
    expect(find.text('KrishiAI'), findsOneWidget);
  });
}
