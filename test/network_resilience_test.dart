import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mon_atelier02/network/dio_provider.dart';
import 'package:mon_atelier02/network/request_log.dart';
import 'package:mon_atelier02/weather/data/weather_cache.dart';
import 'package:mon_atelier02/weather/data/weather_repository.dart';
import 'package:mon_atelier02/weather/models/station_weather.dart';
import 'package:mon_atelier02/weather/monitoring_screen.dart';

/// Faux adaptateur HTTP : simule l'API, ou une coupure réseau.
class _FakeAdapter implements HttpClientAdapter {
  bool online = true;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (!online) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      );
    }
    final body = List.generate(
      kStations.length,
      (i) => {
        'current': {
          'time': '2026-11-24T10:00',
          'temperature_2m': 18.5 + i,
          'wind_speed_10m': 12.0,
        },
      },
    );
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _MemoryCache implements WeatherCache {
  CachedWeather? stored;

  @override
  Future<void> save(CachedWeather data) async => stored = data;

  @override
  CachedWeather? load() => stored;
}

void main() {
  late _FakeAdapter adapter;
  late _MemoryCache cache;
  late List<LogEntry> logs;
  late Dio dio;
  late WeatherRepository repo;

  setUp(() {
    adapter = _FakeAdapter();
    cache = _MemoryCache();
    logs = [];
    dio = Dio(BaseOptions(baseUrl: 'https://test.local'))
      ..httpClientAdapter = adapter
      ..interceptors.add(LoggingInterceptor(logs.add));
    repo = WeatherRepository(dio, cache);
  });

  test('en ligne : données du réseau et mise en cache', () async {
    final r = await repo.fetch();
    expect(r.fromCache, isFalse);
    expect(r.stations.length, kStations.length);
    expect(cache.stored, isNotNull);
  });

  test('hors ligne avec cache : dernières données locales', () async {
    final online = await repo.fetch();
    adapter.online = false;
    final offline = await repo.fetch();
    expect(offline.fromCache, isTrue);
    expect(offline.stations.first.name, online.stations.first.name);
    expect(offline.stations.first.temperature,
        online.stations.first.temperature);
  });

  test('hors ligne sans cache : l\'erreur remonte', () async {
    adapter.online = false;
    await expectLater(repo.fetch(), throwsA(isA<DioException>()));
  });

  test('l\'intercepteur journalise succès et erreur, sans paramètres', () async {
    await repo.fetch();
    adapter.online = false;
    await repo.fetch();
    expect(logs.length, 2);
    expect(logs[0].statusCode, 200);
    expect(logs[0].path, '/v1/forecast');
    expect(logs[1].error, 'connectionError');
  });

  testWidgets('l\'écran affiche clairement le mode hors ligne', (tester) async {
    cache.stored = CachedWeather(
      savedAt: DateTime(2026, 11, 24, 10, 0),
      items: const [
        StationWeather(
          name: 'Tunis',
          temperature: 19.0,
          windSpeed: 10.0,
          time: '2026-11-24T10:00',
        ),
      ],
    );
    adapter.online = false;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          weatherCacheProvider.overrideWithValue(cache),
          dioProvider.overrideWithValue(dio),
        ],
        child: const MaterialApp(home: MonitoringScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Mode hors ligne'), findsOneWidget);
    expect(find.text('Tunis'), findsOneWidget);
  });
}
