import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/station_weather.dart';

class CachedWeather {
  const CachedWeather({required this.items, required this.savedAt});
  final List<StationWeather> items;
  final DateTime savedAt;
}

/// Contrat du cache : le dépôt ne connaît pas Hive, ce qui permet de
/// le remplacer par un faux cache dans les tests.
abstract class WeatherCache {
  Future<void> save(CachedWeather data);
  CachedWeather? load();
}

/// Implémentation Hive : un seul enregistrement JSON dans une box.
class HiveWeatherCache implements WeatherCache {
  HiveWeatherCache(this._box);

  final Box<String> _box;
  static const _key = 'weather';

  @override
  Future<void> save(CachedWeather data) {
    return _box.put(
      _key,
      jsonEncode({
        'savedAt': data.savedAt.toIso8601String(),
        'items': data.items.map((e) => e.toJson()).toList(),
      }),
    );
  }

  @override
  CachedWeather? load() {
    final raw = _box.get(_key);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return CachedWeather(
        savedAt: DateTime.parse(map['savedAt'] as String),
        items: (map['items'] as List)
            .map((e) => StationWeather.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (_) {
      return null; // cache corrompu : on l'ignore
    }
  }
}

/// Doit être remplacé dans main() par le cache Hive ouvert.
final weatherCacheProvider = Provider<WeatherCache>(
  (ref) => throw UnimplementedError('weatherCacheProvider non initialisé'),
);
