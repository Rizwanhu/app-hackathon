import 'package:go_router/go_router.dart';

import '../auth/auth_scope.dart';
import '../../features/ai_advisor/presentation/ai_advisor_screen.dart';
import '../../core/auth/presentation/login_screen.dart';
import '../../core/auth/presentation/signup_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/ledger/presentation/ledger_screen.dart';
import '../../features/payables/presentation/payables_screen.dart';
import '../../features/receivables/presentation/receivables_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/shell/presentation/app_shell.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/shell/presentation/app_shell.dart';

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
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    
    // MAIN APP SHELL (Handles Dashboard, Ledger, AI via PageView)
    GoRoute(
      path: '/app/dashboard', // We use this as the entry point
      builder: (context, state) => const AppShell(),
      routes: [
        // DRAWER ROUTES (Accessible via context.push)
        GoRoute(path: 'receivables', builder: (context, state) => const ReceivablesScreen()),
        GoRoute(path: 'payables', builder: (context, state) => const PayablesScreen()),
        GoRoute(path: 'settings', builder: (context, state) => const SettingsScreen()),
        GoRoute(path: 'profile', builder: (context, state) => const ProfileScreen()),
      ],
    ),
  ],
);
