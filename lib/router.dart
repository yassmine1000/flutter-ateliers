import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'auth/auth_state.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/pin_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Pont Riverpod -> GoRouter : quand le statut change, le router
  // ré-évalue `redirect` automatiquement.
  final status = ValueNotifier<AuthStatus>(ref.read(authProvider).status);
  ref.listen<AuthState>(authProvider, (_, next) => status.value = next.status);
  ref.onDispose(status.dispose);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: status,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      switch (status.value) {
        case AuthStatus.unauthenticated:
          return loc == '/login' ? null : '/login';
        case AuthStatus.pendingTwoFactor:
          return loc == '/2fa' ? null : '/2fa';
        case AuthStatus.authenticated:
          return (loc == '/login' || loc == '/2fa') ? '/home' : null;
      }
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/2fa', builder: (_, __) => const PinScreen()),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    ],
  );
});
