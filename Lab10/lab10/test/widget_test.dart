import 'package:flutter_test/flutter_test.dart';
import 'package:lab10/main.dart';

void main() {
  testWidgets('Render BaiTap02Screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('ListView Demo'), findsOneWidget);
  });
}
