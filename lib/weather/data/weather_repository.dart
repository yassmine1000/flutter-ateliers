import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../network/dio_provider.dart';
import '../models/station_weather.dart';
import 'weather_cache.dart';

class Station {
  const Station(this.name, this.lat, this.lon);
  final String name;
  final double lat;
  final double lon;
}

/// Stations de mesure interrogées (sources de monitoring).
const kStations = [
  Station('Tunis', 36.80, 10.18),
  Station('Kairouan', 35.68, 10.10),
  Station('Sfax', 34.74, 10.76),
  Station('Paris', 48.85, 2.35),
  Station('Toulouse', 43.60, 1.44),
];

class WeatherResult {
  const WeatherResult({
    required this.stations,
    required this.fromCache,
    required this.updatedAt,
  });

  final List<StationWeather> stations;

  /// true : le réseau a échoué, on affiche les dernières données locales.
  final bool fromCache;

  /// Date de la récupération réseau (ou de l'enregistrement du cache).
  final DateTime updatedAt;
}

class WeatherRepository {
  WeatherRepository(this._dio, this._cache);

  final Dio _dio;
  final WeatherCache _cache;

  /// Réseau d'abord ; en cas d'échec, dernier cache connu ; sinon l'erreur
  /// remonte à l'interface.
  Future<WeatherResult> fetch() async {
    try {
      final res = await _dio.get<dynamic>(
        '/v1/forecast',
        queryParameters: {
          'latitude': kStations.map((s) => s.lat).join(','),
          'longitude': kStations.map((s) => s.lon).join(','),
          'current': 'temperature_2m,wind_speed_10m',
        },
      );
      final stations = _parse(res.data);
      final now = DateTime.now();
      await _cache.save(CachedWeather(items: stations, savedAt: now));
      return WeatherResult(stations: stations, fromCache: false, updatedAt: now);
    } catch (e) {
      if (e is! DioException && e is! FormatException) rethrow;
      final cached = _cache.load();
      if (cached == null) rethrow;
      return WeatherResult(
        stations: cached.items,
        fromCache: true,
        updatedAt: cached.savedAt,
      );
    }
  }

  List<StationWeather> _parse(dynamic data) {
    // Plusieurs coordonnées -> l'API renvoie une liste.
    final list = data is List ? data : [data];
    if (list.length != kStations.length) {
      throw const FormatException('Réponse inattendue');
    }
    return [
      for (var i = 0; i < list.length; i++) _one(kStations[i].name, list[i]),
    ];
  }

  StationWeather _one(String name, dynamic item) {
    if (item is! Map || item['current'] is! Map) {
      throw const FormatException('Réponse inattendue');
    }
    final current = item['current'] as Map;
    final t = current['temperature_2m'];
    final w = current['wind_speed_10m'];
    final time = current['time'];
    if (t is! num || w is! num || time is! String) {
      throw const FormatException('Mesure manquante');
    }
    return StationWeather(
      name: name,
      temperature: t.toDouble(),
      windSpeed: w.toDouble(),
      time: time,
    );
  }
}

final weatherRepositoryProvider = Provider<WeatherRepository>(
  (ref) => WeatherRepository(
    ref.watch(dioProvider),
    ref.watch(weatherCacheProvider),
  ),
);

/// États chargement / succès / erreur fournis par AsyncValue.
/// Rafraîchir : ref.invalidate(weatherProvider).
final weatherProvider = FutureProvider<WeatherResult>(
  (ref) => ref.watch(weatherRepositoryProvider).fetch(),
);
