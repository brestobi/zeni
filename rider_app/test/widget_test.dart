import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeni_rider/app.dart';
import 'package:zeni_rider/features/auth/bloc/auth_bloc.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      BlocProvider<AuthBloc>(
        create: (_) => AuthBloc(),
        child: const ZeniRiderApp(),
      ),
    );
    expect(find.text('Welcome to Zeni'), findsOneWidget);
  });
}
