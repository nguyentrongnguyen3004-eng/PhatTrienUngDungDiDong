import 'package:flutter_test/flutter_test.dart';
import 'package:lab11/main.dart';

void main() {
  testWidgets('Lab11 Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(const Lab11App());
    expect(find.text('Lab 11: Flutter & Firebase'), findsOneWidget);
  });
}
