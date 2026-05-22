import 'package:flutter_test/flutter_test.dart';
import 'package:wessless/main.dart';

void main() {
  testWidgets('App starts', (WidgetTester tester) async {
    await tester.pumpWidget(const WessLessApp());
    expect(find.text('WessLess'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2200));
    await tester.pumpAndSettle();
    expect(
      find.text('Selamat datang kembali', skipOffstage: false),
      findsOneWidget,
    );
  });
}
