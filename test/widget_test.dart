import 'package:flutter_test/flutter_test.dart';
import 'package:carenest/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the home screen is displayed by default.
    expect(find.text('Home Screen'), findsOneWidget);
  });
}
