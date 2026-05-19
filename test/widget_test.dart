import 'package:flutter_test/flutter_test.dart';
import 'package:wessless/main.dart';

void main() {
  testWidgets('App starts', (WidgetTester tester) async {
    await tester.pumpWidget(const WessLessApp());
    expect(find.text('WessLess'), findsOneWidget);
  });
}
