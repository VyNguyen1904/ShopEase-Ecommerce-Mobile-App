import 'package:flutter_test/flutter_test.dart';
import 'package:shopease/app.dart';

void main() {
  testWidgets('ShopEase App Smoke Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ShopEaseApp());

    // Verify that our brand name is found on the splash screen
    expect(find.text('ShopEase'), findsAtLeastNWidgets(1));
  });
}
