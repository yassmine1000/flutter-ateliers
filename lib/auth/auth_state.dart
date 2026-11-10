import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Les 3 états du tunnel. C'est la SEULE source de vérité pour l'accès.
enum AuthStatus { unauthenticated, pendingTwoFactor, authenticated }

class AuthState {
  final AuthStatus status;
  final String? error;
  const AuthState({this.status = AuthStatus.unauthenticated, this.error});
}

class AuthNotifier extends Notifier<AuthState> {
  // Identifiants factices (simulation pour l'atelier).
  static const _user = 'admin';
  static const _password = 'admin123';
  static const _pin = '123456';

  @override
  AuthState build() => const AuthState();

  /// Étape 1 : login -> passe en "2FA en attente" (PAS authentifié).
  Future<void> login(String user, String password) async {
    await Future.delayed(const Duration(milliseconds: 400)); // simule le réseau
    if (user == _user && password == _password) {
      state = const AuthState(status: AuthStatus.pendingTwoFactor);
    } else {
      state = const AuthState(error: 'Identifiants invalides');
    }
  }

  /// Étape 2 : PIN -> n'est accepté que si le login a réussi avant.
  Future<void> verifyPin(String pin) async {
    if (state.status != AuthStatus.pendingTwoFactor) return;
    await Future.delayed(const Duration(milliseconds: 400));
    if (pin == _pin) {
      state = const AuthState(status: AuthStatus.authenticated);
    } else {
      state = const AuthState(
        status: AuthStatus.pendingTwoFactor,
        error: 'Code PIN incorrect',
      );
    }
  }

  void logout() => state = const AuthState();
}

final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
