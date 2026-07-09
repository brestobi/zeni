import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/pages/phone_login_page.dart';
import '../../features/auth/pages/otp_verify_page.dart';
import '../../features/auth/pages/onboarding_page.dart';
import '../../features/home/pages/home_page.dart';
import '../../features/booking/pages/booking_page.dart';
import '../../features/ride/pages/ride_tracking_page.dart';
import '../../features/profile/pages/profile_page.dart';
import '../../features/payment/pages/payment_page.dart';
import '../../features/history/pages/history_page.dart';

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
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/booking',
      builder: (context, state) => const BookingPage(),
    ),
    GoRoute(
      path: '/ride-tracking',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return RideTrackingPage(
          rideId: extra['rideId'] as String,
        );
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: '/payment',
      builder: (context, state) => const PaymentPage(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryPage(),
    ),
  ],
);
