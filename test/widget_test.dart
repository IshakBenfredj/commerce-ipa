import 'package:flutter_test/flutter_test.dart';
import 'package:app_dashf/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AlgerianStoreDashboardApp());
    expect(find.byType(AlgerianStoreDashboardApp), findsOneWidget);
  });
}
