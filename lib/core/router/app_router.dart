import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/health_brief/presentation/pages/brief_detail_page.dart';
import '../../features/home/presentation/pages/main_shell.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/timeline/presentation/pages/timeline_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

/// Route names
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String timeline = '/timeline';
  static const String profile = '/profile';
  static const String briefDetail = '/brief/:id';

  static String briefDetailPath(String id) => '/brief/$id';
}

/// App router configuration
class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  /// Builds a router that reacts to auth changes via [authListenable].
  /// [isAuthenticated] is a getter so redirect always reads the current value.
  static GoRouter router({
    required Listenable authListenable,
    required bool Function() isAuthenticated,
  }) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      refreshListenable: authListenable,
      initialLocation: AppRoutes.login,
      redirect: (context, state) {
        final isLoggedIn = isAuthenticated();
        final isOnAuthScreen = state.matchedLocation == AppRoutes.login ||
            state.matchedLocation == AppRoutes.signup;

        if (!isLoggedIn && !isOnAuthScreen) {
          return AppRoutes.login;
        }

        if (isLoggedIn && isOnAuthScreen) {
          return AppRoutes.home;
        }

        return null;
      },
      routes: [
        // Auth routes
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: AppRoutes.signup,
          builder: (context, state) => const SignupPage(),
        ),

        // Main shell with bottom navigation
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            GoRoute(
              path: AppRoutes.home,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: HomePage(),
              ),
            ),
            GoRoute(
              path: AppRoutes.timeline,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: TimelinePage(),
              ),
            ),
            GoRoute(
              path: AppRoutes.profile,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ProfilePage(),
              ),
            ),
          ],
        ),

        // Brief detail (outside shell - full screen)
        GoRoute(
          path: AppRoutes.briefDetail,
          builder: (context, state) {
            final briefId = state.pathParameters['id'] ?? '';
            return BriefDetailPage(briefId: briefId);
          },
        ),
      ],
    );
  }
}
