import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_state.dart';

/// Affiche l'état d'authentification courant : rend "l'état observé"
/// visible (le défi demande d'observer la réaction de l'UI).
class AuthStatusBanner extends ConsumerWidget {
  const AuthStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(authProvider.select((s) => s.status));
    final (label, color) = switch (status) {
      AuthStatus.unauthenticated => ('Non authentifié', Colors.red.shade700),
      AuthStatus.pendingTwoFactor => ('2FA en attente', Colors.orange.shade800),
      AuthStatus.authenticated => ('Authentifié', Colors.green.shade700),
    };
    return Material(
      color: color,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Text(
            'État : $label',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
