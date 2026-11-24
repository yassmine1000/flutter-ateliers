# Ateliers Flutter avancés

App Flutter unique regroupant les ateliers.
Lancer : `flutter pub get`, `flutter run`, `flutter test`.
Identifiants de test (simulés) : `admin` / `admin123`, puis PIN `123456`.

## Atelier 01 — Responsive UI : dashboard réseau
Dashboard d'administration (serveurs virtuels, alertes, graphes CPU/RAM simulés) adapté de la tablette au smartphone.

- `lib/dashboard/dashboard_screen.dart` : écran et points de rupture (≥900 px : 3 col., ≥600 px : 2 col., sinon 1 col.).
- `lib/dashboard/widgets/` : composants réutilisables (`ServerCard`, `MetricBar`, `StatusIndicator`, `AlertTile`, `StatTile`, `MetricChartCard`, `ResponsiveGrid`).
- `lib/dashboard/models` et `data` : modèle `Server` et données simulées.
- Test : `test/dashboard_test.dart` (3 largeurs : colonnes et absence d'overflow).

## Atelier 02 — Accès : tunnel d'authentification
Login → validation 2FA par code PIN → Accueil. **GoRouter** orchestre routes et redirections, **Riverpod** expose l'état de connexion de façon réactive.

- `lib/auth/auth_state.dart` : 3 états, `AuthNotifier`, limite de 3 PIN erronés.
- `lib/router.dart` : `redirect` selon l'état + `refreshListenable` branché sur Riverpod.
- `lib/screens/`, `lib/widgets/auth_status_banner.dart` : écrans et état observé.
- Tests : `test/auth_notifier_test.dart`, `test/auth_flow_test.dart`.

## Atelier 03 — Résilience : monitoring qui survit à la coupure réseau
Écran `/monitoring` (icône nuage de l'accueil) : températures et vent de 5 stations via l'API REST Open-Meteo (sans clé).

- **Consommer** : `lib/weather/data/weather_repository.dart` (Dio) ; états chargement / succès / erreur via `AsyncValue` (`weatherProvider`).
- **Journaliser** : `lib/network/request_log.dart` (`LoggingInterceptor`) ; seuls méthode, chemin, statut, durée et type d'erreur sont enregistrés (jamais de paramètres, d'en-têtes ou de corps).
- **Mettre en cache** : `lib/weather/data/weather_cache.dart` (Hive) ; réseau d'abord, dernier cache en cas d'échec.
- **Rendre visible** : `lib/weather/monitoring_screen.dart` : bandeau vert « Données à jour » ou orange « Mode hors ligne : données locales du … », et journal des requêtes.
- Test : `test/network_resilience_test.dart` (faux adaptateur Dio : en ligne, hors ligne avec cache, hors ligne sans cache, journal, affichage).

## Limites (volontaires)
Identifiants et PIN codés en dur, données du dashboard simulées, pas de persistance de session ni de stockage sécurisé (atelier 04).
