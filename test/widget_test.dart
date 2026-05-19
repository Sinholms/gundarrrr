import 'package:flutter_test/flutter_test.dart';
import 'package:wessless/main.dart';

void main() {
  testWidgets('App starts', (WidgetTester tester) async {
    await tester.pumpWidget(const WessLessApp());
    expect(find.text('WessLess'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 3500));
    await tester.pumpAndSettle();
    expect(
      find.text('Warung Geprek Mas Bro', skipOffstage: false),
      findsOneWidget,
    );
  });
}
