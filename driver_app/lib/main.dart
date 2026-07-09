import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/home/bloc/driver_home_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(),
        ),
        BlocProvider<DriverHomeBloc>(
          create: (_) => DriverHomeBloc(),
        ),
        // Additional BLoCs will be added as features are built.
      ],
      child: const ZeniDriverApp(),
    ),
  );
}
