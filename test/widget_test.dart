import 'package:flutter_test/flutter_test.dart';
import 'package:dzguidedashboard/main.dart';

void main() {
  testWidgets('Dashboard load test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DZGuideAdminApp());

    // Verify that the dashboard title is present
    expect(find.text('DZ Guide'), findsOneWidget);
  });
}
