import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeni_driver/app.dart';
import 'package:zeni_driver/features/auth/bloc/auth_bloc.dart';
import 'package:zeni_driver/features/home/bloc/driver_home_bloc.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (_) => AuthBloc()),
          BlocProvider<DriverHomeBloc>(create: (_) => DriverHomeBloc()),
        ],
        child: const ZeniDriverApp(),
      ),
    );
    // The App title is defined in MaterialApp.router in app.dart, 
    // but MaterialApp.router doesn't render it in the widget tree for finding.
    // Instead, check if the login screen is rendered (which is the initial route)
    expect(find.text('Zeni Driver'), findsOneWidget); 
  });
}
