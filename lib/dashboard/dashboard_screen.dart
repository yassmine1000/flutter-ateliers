import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/fake_servers.dart';
import 'models/server.dart';
import 'widgets/alert_tile.dart';
import 'widgets/metric_chart_card.dart';
import 'widgets/responsive_grid.dart';
import 'widgets/server_card.dart';
import 'widgets/stat_tile.dart';

/// Points de rupture : tablette large (3 col.), tablette (2 col.), smartphone (1 col.).
int columnsFor(double width) => width >= 900 ? 3 : (width >= 600 ? 2 : 1);

List<double> _average(List<List<double>> series) {
  final n = series.first.length;
  return List.generate(
    n,
    (i) => series.map((s) => s[i]).reduce((a, b) => a + b) / series.length,
  );
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servers = ref.watch(serversProvider);

    final alive = servers.where((s) => s.status != ServerStatus.offline).toList();
    final base = alive.isEmpty ? servers : alive;
    final cpuAvg = _average(base.map((s) => s.cpu).toList());
    final ramAvg = _average(base.map((s) => s.ram).toList());
    final online = servers.where((s) => s.status == ServerStatus.online).length;
    final alerts = servers.where((s) => s.alert != null).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = columnsFor(width);
        final wide = width >= 600;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResponsiveGrid(
                columns: wide ? 3 : 1,
                children: [
                  StatTile(
                    label: 'Serveurs en ligne',
                    value: '$online / ${servers.length}',
                    icon: Icons.dns_outlined,
                  ),
                  StatTile(
                    label: 'Alertes actives',
                    value: '${alerts.length}',
                    icon: Icons.notifications_active_outlined,
                  ),
                  StatTile(
                    label: 'CPU moyen',
                    value: '${cpuAvg.last.round()} %',
                    icon: Icons.memory,
                  ),
                ],
              ),
              const _SectionTitle('Serveurs'),
              ResponsiveGrid(
                columns: columns,
                children: [for (final s in servers) ServerCard(server: s)],
              ),
              const _SectionTitle('Alertes'),
              if (alerts.isEmpty)
                const Text('Aucune alerte')
              else
                ResponsiveGrid(
                  columns: wide ? 2 : 1,
                  children: [for (final s in alerts) AlertTile(server: s)],
                ),
              const _SectionTitle('Performances (moyenne)'),
              ResponsiveGrid(
                columns: wide ? 2 : 1,
                children: [
                  MetricChartCard(
                    title: 'CPU',
                    values: cpuAvg,
                    color: Colors.green.shade600,
                  ),
                  MetricChartCard(
                    title: 'RAM',
                    values: ramAvg,
                    color: Colors.blue.shade600,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
