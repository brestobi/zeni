import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'core/notifications/notification_service.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/repository/auth_repository.dart';
import 'features/home/bloc/driver_home_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  // await Supabase.initialize(...);

  // Initialize notifications
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
          create: (_) => DriverHomeBloc(),
        ),
      ],
      child: const ZeniDriverApp(),
    ),
  );
}
