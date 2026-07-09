import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/pages/phone_login_page.dart';
import '../../features/auth/pages/otp_verify_page.dart';
import '../../features/registration/pages/registration_page.dart';
import '../../features/home/pages/home_page.dart';
import '../../features/ride/pages/ride_page.dart';
import '../../features/earnings/pages/earnings_page.dart';
import '../../features/profile/pages/profile_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const PhoneLoginPage(),
    ),
    GoRoute(
      path: '/otp-verify',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return OtpVerifyPage(
          phoneNumber: extra['phoneNumber'] as String,
        );
      },
    ),
    GoRoute(
      path: '/registration',
      builder: (context, state) => const RegistrationPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/ride',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return RidePage(
          rideId: extra?['rideId'] as String?,
        );
      },
    ),
    GoRoute(
      path: '/earnings',
      builder: (context, state) => const EarningsPage(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfilePage(),
    ),
  ],
);
