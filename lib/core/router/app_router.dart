import 'package:go_router/go_router.dart';

import '../auth/auth_scope.dart';
import '../../features/ai_advisor/presentation/ai_advisor_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/ledger/presentation/ledger_screen.dart';
import '../../features/payables/presentation/payables_screen.dart';
import '../../features/receivables/presentation/receivables_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/shell/presentation/app_shell.dart';
import '../../features/splash/presentation/splash_screen.dart';

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
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/app/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/app/ledger',
              builder: (context, state) => const LedgerScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/app/receivables',
              builder: (context, state) => const ReceivablesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/app/payables',
              builder: (context, state) => const PayablesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/app/ai',
              builder: (context, state) => const AiAdvisorScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/app/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

