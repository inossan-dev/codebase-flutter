import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:codebase/core/router/screens/detail_screen.dart';
import 'package:codebase/core/router/screens/not_found_screen.dart';
import 'package:codebase/core/router/screens/scaffold_with_nav_bar.dart';
import 'package:codebase/features/auth/presentation/providers/auth_provider.dart';
import 'package:codebase/features/auth/presentation/screens/login_screen.dart';
import 'package:codebase/features/home/presentation/screens/home_screen.dart';

part 'app_router.g.dart';

// ─── Routes constants ─────────────────────────────────────────────────────────
// Centraliser les paths évite les magic strings dans les widgets.

abstract final class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
  static const profile = '/home/profile';
  static const detail = '/home/detail/:id';

  static String detailPath(String id) => '/home/detail/$id';
}

// ─── Router provider ─────────────────────────────────────────────────────────

@riverpod
GoRouter appRouter(Ref ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,

    // ─── Guard global ─────────────────────────────────────────────────────
    redirect: (context, state) {
      final isAuthenticated = authState.valueOrNull != null;
      final isOnAuthRoute = state.matchedLocation == AppRoutes.login;

      if (!isAuthenticated && !isOnAuthRoute) return AppRoutes.login;
      if (isAuthenticated && isOnAuthRoute) return AppRoutes.home;
      return null;
    },

    // ─── Routes ───────────────────────────────────────────────────────────
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => ScaffoldWithNavBar(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            builder: (context, state) => const HomeScreen(),
            routes: [
              GoRoute(
                path: 'detail/:id',
                name: 'detail',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return DetailScreen(id: id);
                },
              ),
            ],
          ),
        ],
      ),
    ],

    // ─── 404 ──────────────────────────────────────────────────────────────
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
}
