enum ServerStatus { online, warning, offline }

class Server {
  const Server({
    required this.id,
    required this.name,
    required this.status,
    required this.cpu,
    required this.ram,
    this.alert,
  });

  final String id;
  final String name;
  final ServerStatus status;

  /// Historique en % (0..100), du plus ancien au plus récent.
  final List<double> cpu;
  final List<double> ram;
  final String? alert;

  double get cpuNow => cpu.last;
  double get ramNow => ram.last;
}
