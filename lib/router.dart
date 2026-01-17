import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/home_screen.dart';
import 'screens/offline_setup_screen.dart';
import 'screens/otp_verification_screen.dart';
import 'screens/phone_entry_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/welcome_screen.dart';

GoRouter get appRouter => _router;

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'welcome',
      pageBuilder: (context, state) => _fadeSlidePage(
        key: state.pageKey,
        child: const WelcomeScreen(),
      ),
    ),
    GoRoute(
      path: '/phone',
      name: 'phone',
      pageBuilder: (context, state) => _fadeSlidePage(
        key: state.pageKey,
        child: const PhoneEntryScreen(),
      ),
    ),
    GoRoute(
      path: '/otp',
      name: 'otp',
      pageBuilder: (context, state) => _fadeSlidePage(
        key: state.pageKey,
        child: const OtpVerificationScreen(),
      ),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      pageBuilder: (context, state) => _fadeSlidePage(
        key: state.pageKey,
        child: const ProfileSetupScreen(),
      ),
    ),
    GoRoute(
      path: '/offline',
      name: 'offline',
      pageBuilder: (context, state) => _fadeSlidePage(
        key: state.pageKey,
        child: const OfflineSetupScreen(),
      ),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      pageBuilder: (context, state) => _fadeSlidePage(
        key: state.pageKey,
        child: const HomeScreen(),
      ),
    ),
  ],
);

CustomTransitionPage<void> _fadeSlidePage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final offsetTween = Tween<Offset>(
        begin: const Offset(0, 0.04),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOut));
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: animation.drive(offsetTween),
          child: child,
        ),
      );
    },
  );
}
