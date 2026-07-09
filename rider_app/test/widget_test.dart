import 'package:flutter_test/flutter_test.dart';
import 'package:zeni_rider/app.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ZeniRiderApp());
    expect(find.text('Welcome to Zeni'), findsOneWidget);
  });
}
