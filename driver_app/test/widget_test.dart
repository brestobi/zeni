import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zeni_driver/app.dart';
import 'package:zeni_driver/features/auth/bloc/auth_bloc.dart';
import 'package:zeni_driver/features/auth/repository/auth_repository.dart';
import 'package:zeni_driver/features/home/bloc/driver_home_bloc.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    final mockAuthRepository = MockAuthRepository();
    final mockSupabaseClient = MockSupabaseClient();

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) => AuthBloc(authRepository: mockAuthRepository),
          ),
          BlocProvider<DriverHomeBloc>(
            create: (_) => DriverHomeBloc(supabase: mockSupabaseClient),
          ),
        ],
        child: const ZeniDriverApp(),
      ),
    );
    
    expect(find.text('Zeni Driver'), findsOneWidget); 
  });
}
