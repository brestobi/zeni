import 'package:flutter_test/flutter_test.dart';
import 'package:zeni_driver/app.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ZeniDriverApp());
    expect(find.text('Zeni Driver'), findsOneWidget);
  });
}
