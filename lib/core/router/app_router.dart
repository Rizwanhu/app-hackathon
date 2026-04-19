import 'package:go_router/go_router.dart';

import '../auth/auth_scope.dart';
import '../../core/auth/presentation/login_screen.dart';
import '../../core/auth/presentation/signup_screen.dart';
import '../../features/payables/presentation/payables_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/receivables/presentation/receivables_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/shell/presentation/app_shell.dart';
import '../../features/splash/presentation/splash_screen.dart';
import 'route_transitions.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  refreshListenable: authNotifier,
  redirect: (context, state) {
    final path = state.uri.path;
    final loggedIn = authNotifier.isLoggedIn;
    final inAuth = path == '/login' || path == '/signup';
    final inSplash = path == '/splash';
    final inApp = path.startsWith('/app');

    if (inSplash) return null;
    if (!loggedIn && inApp) return '/login';
    if (loggedIn && inAuth) return '/app/dashboard';
    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      pageBuilder: (context, state) => NoTransitionPage<void>(
        key: state.pageKey,
        child: const SplashScreen(),
      ),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => enterpriseTransitionPage(
        pageKey: state.pageKey,
        child: const LoginScreen(),
      ),
    ),
    GoRoute(
      path: '/signup',
      pageBuilder: (context, state) => enterpriseTransitionPage(
        pageKey: state.pageKey,
        child: const SignupScreen(),
      ),
    ),
    GoRoute(
      path: '/app/dashboard',
      pageBuilder: (context, state) => enterpriseTransitionPage(
        pageKey: state.pageKey,
        child: const AppShell(),
      ),
      routes: [
        GoRoute(
          path: 'receivables',
          pageBuilder: (context, state) => enterpriseTransitionPage(
            pageKey: state.pageKey,
            child: const ReceivablesScreen(),
          ),
        ),
        GoRoute(
          path: 'payables',
          pageBuilder: (context, state) => enterpriseTransitionPage(
            pageKey: state.pageKey,
            child: const PayablesScreen(),
          ),
        ),
        GoRoute(
          path: 'settings',
          pageBuilder: (context, state) => enterpriseTransitionPage(
            pageKey: state.pageKey,
            child: const SettingsScreen(),
          ),
        ),
        GoRoute(
          path: 'profile',
          pageBuilder: (context, state) => enterpriseTransitionPage(
            pageKey: state.pageKey,
            child: const ProfileScreen(),
          ),
        ),
      ],
    ),
  ],
);
