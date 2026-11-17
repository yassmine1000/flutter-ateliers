import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/server.dart';

List<double> _series(Random r, double base, double amp, {int n = 24}) {
  var v = base;
  return List.generate(n, (_) {
    v = (v + (r.nextDouble() - 0.5) * amp).clamp(2.0, 98.0).toDouble();
    return v;
  });
}

Server _make(
  int i,
  String name,
  ServerStatus status,
  double cpu,
  double ram, [
  String? alert,
]) {
  final r = Random(i + 7); // graine fixe : données stables à chaque lancement
  return Server(
    id: 'srv-$i',
    name: name,
    status: status,
    cpu: _series(r, cpu, 14),
    ram: _series(r, ram, 8),
    alert: alert,
  );
}

/// Serveurs virtuels simulés.
List<Server> buildFakeServers() => [
      _make(1, 'web-01', ServerStatus.online, 35, 52),
      _make(2, 'web-02', ServerStatus.online, 42, 58),
      _make(3, 'db-01', ServerStatus.warning, 78, 82, 'CPU élevé depuis 10 min'),
      _make(4, 'cache-01', ServerStatus.online, 20, 40),
      _make(5, 'api-01', ServerStatus.warning, 66, 88, 'Mémoire presque saturée'),
      _make(6, 'backup-01', ServerStatus.offline, 4, 4, 'Serveur injoignable'),
    ];

final serversProvider = Provider<List<Server>>((ref) => buildFakeServers());
