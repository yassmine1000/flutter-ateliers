import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Une ligne du journal. On ne garde volontairement que le chemin (pas les
/// paramètres, ni les en-têtes, ni le corps) : un journal ne doit jamais
/// contenir de secret (voir atelier 04).
class LogEntry {
  const LogEntry({
    required this.time,
    required this.method,
    required this.path,
    required this.durationMs,
    this.statusCode,
    this.error,
  });

  final DateTime time;
  final String method;
  final String path;
  final int durationMs;
  final int? statusCode;
  final String? error;

  bool get isError => error != null;
}

class RequestLogNotifier extends Notifier<List<LogEntry>> {
  static const maxEntries = 50;

  @override
  List<LogEntry> build() => const [];

  void add(LogEntry entry) {
    state = [entry, ...state].take(maxEntries).toList();
  }

  void clear() => state = const [];
}

final requestLogProvider =
    NotifierProvider<RequestLogNotifier, List<LogEntry>>(RequestLogNotifier.new);

/// Intercepteur Dio : journalise chaque requête, réponse et erreur.
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor(this.onLog);

  final void Function(LogEntry entry) onLog;
  static const _startKey = 'log_start_ms';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startKey] = DateTime.now().millisecondsSinceEpoch;
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    onLog(_entry(response.requestOptions, status: response.statusCode));
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    onLog(_entry(
      err.requestOptions,
      status: err.response?.statusCode,
      error: err.type.name,
    ));
    handler.next(err);
  }

  LogEntry _entry(RequestOptions o, {int? status, String? error}) {
    final start = o.extra[_startKey] as int?;
    final now = DateTime.now();
    return LogEntry(
      time: now,
      method: o.method,
      path: o.path,
      durationMs: start == null ? 0 : now.millisecondsSinceEpoch - start,
      statusCode: status,
      error: error,
    );
  }
}
