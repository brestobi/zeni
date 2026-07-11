import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'app.dart';
import 'features/auth/bloc/auth_bloc.dart';

// Supabase and Google Sign-In credentials should be provided via --dart-define at build time:
//   flutter run --dart-define=SUPABASE_URL=https://xyz.supabase.co \
//               --dart-define=SUPABASE_ANON_KEY=your-anon-key \
//               --dart-define=GOOGLE_SERVER_CLIENT_ID=your-google-server-client-id
const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
const _googleServerClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase.
  await Supabase.initialize(
    url: _supabaseUrl,
    publishableKey: _supabaseAnonKey,
  );

  // Initialize Google Sign-In (mandatory exactly once in v7.0.0+ before calling authenticate).
  if (_googleServerClientId.isNotEmpty) {
    await GoogleSignIn.instance.initialize(
      serverClientId: _googleServerClientId,
    );
  }

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(),
        ),
      ],
      child: const ZeniRiderApp(),
    ),
  );
}
