import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/request_log.dart';
import '../widgets/auth_status_banner.dart';
import 'data/weather_repository.dart';
import 'models/station_weather.dart';

String _two(int n) => n.toString().padLeft(2, '0');

String formatDateTime(DateTime d) =>
    '${_two(d.day)}/${_two(d.month)}/${d.year} ${_two(d.hour)}:${_two(d.minute)}';

class MonitoringScreen extends ConsumerWidget {
  const MonitoringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weather = ref.watch(weatherProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
            onPressed: () => ref.invalidate(weatherProvider),
          ),
        ],
      ),
      bottomNavigationBar: const AuthStatusBanner(),
      body: weather.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _ErrorView(
          onRetry: () => ref.invalidate(weatherProvider),
        ),
        data: (result) => Column(
          children: [
            if (weather.isLoading) const LinearProgressIndicator(),
            _SourceBanner(result: result),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  for (final s in result.stations) _StationTile(station: s),
                  const SizedBox(height: 16),
                  const _RequestLogPanel(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rend visible l'origine des données : réseau ou stockage local.
class _SourceBanner extends StatelessWidget {
  const _SourceBanner({required this.result});
  final WeatherResult result;

  @override
  Widget build(BuildContext context) {
    final offline = result.fromCache;
    return Material(
      color: offline ? Colors.orange.shade800 : Colors.green.shade700,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(offline ? Icons.cloud_off : Icons.cloud_done,
                color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                offline
                    ? 'Mode hors ligne : données locales du ${formatDateTime(result.updatedAt)}'
                    : 'Données à jour : ${formatDateTime(result.updatedAt)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StationTile extends StatelessWidget {
  const _StationTile({required this.station});
  final StationWeather station;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.thermostat),
        title: Text(station.name),
        subtitle: Text(
          'Vent ${station.windSpeed.toStringAsFixed(1)} km/h · mesure ${station.time.replaceFirst('T', ' ')}',
        ),
        trailing: Text(
          '${station.temperature.toStringAsFixed(1)} °C',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Impossible de charger les données et aucune donnée locale disponible.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ),
      ),
    );
  }
}

/// Journal alimenté par l'intercepteur Dio.
class _RequestLogPanel extends ConsumerWidget {
  const _RequestLogPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(requestLogProvider);
    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.receipt_long),
        title: Text('Journal des requêtes (${logs.length})'),
        children: [
          if (logs.isEmpty)
            const ListTile(title: Text('Aucune requête pour le moment')),
          for (final e in logs)
            ListTile(
              dense: true,
              leading: Icon(
                e.isError ? Icons.error_outline : Icons.check_circle_outline,
                color: e.isError ? Colors.red.shade600 : Colors.green.shade600,
              ),
              title: Text('${e.method} ${e.path}'),
              subtitle: Text(
                e.isError
                    ? 'Erreur : ${e.error} · ${e.durationMs} ms'
                    : 'HTTP ${e.statusCode} · ${e.durationMs} ms',
              ),
              trailing: Text(
                '${_two(e.time.hour)}:${_two(e.time.minute)}:${_two(e.time.second)}',
              ),
            ),
        ],
      ),
    );
  }
}
