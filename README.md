# Atelier 02 — Tunnel d'authentification (Flutter)

Login → validation 2FA par code PIN → Accueil.
**GoRouter** orchestre routes et redirections, **Riverpod** expose l'état d'authentification de façon réactive.

## Lancer
```
flutter pub get
flutter run
flutter test
```
Identifiants de test (simulés) : `admin` / `admin123`, puis PIN `123456`.

## Architecture
- `lib/auth/auth_state.dart` : 3 états (`unauthenticated`, `pendingTwoFactor`, `authenticated`), `AuthNotifier`, limite de 3 PIN erronés.
- `lib/router.dart` : `redirect` selon l'état + `refreshListenable` branché sur Riverpod.
- `lib/screens/` : Login, PIN, Accueil (aucune navigation manuelle).
- `lib/widgets/auth_status_banner.dart` : affiche l'état courant (état observé).

## Défi : navigation dépendante de l'état
| État | Redirection |
|---|---|
| Non authentifié | tout mène à `/login` |
| Après login | tout mène à `/2fa` |
| Après 2FA | accès à `/home`, `/login` et `/2fa` redirigent vers `/home` |

## Tests
- `test/auth_notifier_test.dart` : logique d'état (identifiants, PIN, tentatives, logout).
- `test/auth_flow_test.dart` : contournement impossible de `/home`, réaction de l'UI.

## Limites (volontaires)
Identifiants et PIN codés en dur, pas de persistance de session : traités à l'atelier 04.
