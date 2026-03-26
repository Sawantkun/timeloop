import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'models/models.dart';
import 'providers/providers.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/shell/main_shell.dart';
import 'screens/home/home_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/wallet/wallet_screen.dart';
import 'screens/messages/messages_screen.dart';
import 'screens/messages/chat_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/booking/booking_screen.dart';
import 'screens/disputes/disputes_screen.dart';

class TimeLoopApp extends StatelessWidget {
  const TimeLoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp.router(
      title: 'TimeLoop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeProvider.mode,
      routerConfig: _router,
    );
  }
}

final _rootNavKey = GlobalKey<NavigatorState>();

final _router = GoRouter(
  navigatorKey: _rootNavKey,
  initialLocation: '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (_, __) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (_, __) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (_, __) => const SignupScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (_, __) => const ForgotPasswordScreen(),
    ),

    // Main shell with bottom nav
    StatefulShellRoute.indexedStack(
      builder: (_, __, shell) => MainShell(navigationShell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (_, __) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (_, __) => const SearchScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/wallet',
              builder: (_, __) => const WalletScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/messages',
              builder: (_, __) => const MessagesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (_, __) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),

    // Full-screen routes
    GoRoute(
      path: '/messages/:id',
      parentNavigatorKey: _rootNavKey,
      builder: (_, state) {
        final conv = state.extra as Conversation;
        return ChatScreen(conversation: conv);
      },
    ),
    GoRoute(
      path: '/profile/:id',
      parentNavigatorKey: _rootNavKey,
      builder: (_, state) {
        final user = state.extra as UserModel?;
        return ProfileScreen(viewUser: user);
      },
    ),
    GoRoute(
      path: '/booking',
      parentNavigatorKey: _rootNavKey,
      builder: (_, state) {
        final user = state.extra as UserModel;
        return BookingScreen(provider: user);
      },
    ),
    GoRoute(
      path: '/disputes',
      parentNavigatorKey: _rootNavKey,
      builder: (_, __) => const DisputesScreen(),
    ),
  ],
);
