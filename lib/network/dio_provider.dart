import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'request_log.dart';

/// Client HTTP unique de l'application, avec timeouts et journalisation.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.open-meteo.com',
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
    ),
  );
  dio.interceptors.add(
    LoggingInterceptor(
      // microtask : on ne modifie jamais un provider pendant qu'un autre se construit
      (entry) => Future.microtask(
        () => ref.read(requestLogProvider.notifier).add(entry),
      ),
    ),
  );
  return dio;
});
