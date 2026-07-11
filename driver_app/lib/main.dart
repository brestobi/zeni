import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'core/notifications/notification_service.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/repository/auth_repository.dart';
import 'features/home/bloc/driver_home_bloc.dart';

// Supabase credentials should be provided via --dart-define at build time:
//   flutter run --dart-define=SUPABASE_URL=https://xyz.supabase.co \
//               --dart-define=SUPABASE_ANON_KEY=your-anon-key
const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase first (FCM depends on it).
  await Firebase.initializeApp();

  // Initialize Supabase before any Supabase client access.
  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabaseAnonKey,
  );

  // Initialize FCM token registration. This is a best-effort call:
  // if the user is not yet signed in, currentUser will be null and
  // the service will skip token storage gracefully (see NotificationService).
  final notificationService = NotificationService(Supabase.instance.client);
  await notificationService.initialize();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(
            authRepository: SupabaseAuthRepository(Supabase.instance.client),
          ),
        ),
        BlocProvider<DriverHomeBloc>(
          create: (_) => DriverHomeBloc(
            supabase: Supabase.instance.client,
          ),
        ),
      ],
      child: const ZeniDriverApp(),
    ),
  );
}
