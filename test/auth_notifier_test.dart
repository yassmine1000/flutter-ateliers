import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mon_atelier02/auth/auth_state.dart';

void main() {
  late ProviderContainer c;
  setUp(() {
    c = ProviderContainer();
    addTearDown(c.dispose);
  });

  AuthState s() => c.read(authProvider);
  AuthNotifier n() => c.read(authProvider.notifier);

  test('mauvais identifiants -> reste non authentifié avec erreur', () async {
    await n().login('admin', 'mauvais');
    expect(s().status, AuthStatus.unauthenticated);
    expect(s().error, isNotNull);
  });

  test('login valide -> 2FA en attente, pas authentifié', () async {
    await n().login('admin', 'admin123');
    expect(s().status, AuthStatus.pendingTwoFactor);
  });

  test('PIN sans login préalable est ignoré', () async {
    await n().verifyPin('123456');
    expect(s().status, AuthStatus.unauthenticated);
  });

  test('PIN correct après login -> authentifié', () async {
    await n().login('admin', 'admin123');
    await n().verifyPin('123456');
    expect(s().status, AuthStatus.authenticated);
  });

  test('PIN faux -> reste en attente avec compteur', () async {
    await n().login('admin', 'admin123');
    await n().verifyPin('000000');
    expect(s().status, AuthStatus.pendingTwoFactor);
    expect(s().pinAttempts, 1);
  });

  test('3 PIN faux -> retour au login', () async {
    await n().login('admin', 'admin123');
    for (var i = 0; i < AuthNotifier.maxPinAttempts; i++) {
      await n().verifyPin('000000');
    }
    expect(s().status, AuthStatus.unauthenticated);
    expect(s().error, contains('Trop de tentatives'));
  });

  test('logout remet à zéro', () async {
    await n().login('admin', 'admin123');
    await n().verifyPin('123456');
    n().logout();
    expect(s().status, AuthStatus.unauthenticated);
  });
}
