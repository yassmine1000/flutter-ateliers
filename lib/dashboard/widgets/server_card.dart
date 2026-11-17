import 'package:flutter/material.dart';

import '../models/server.dart';
import 'metric_bar.dart';
import 'status_indicator.dart';

class ServerCard extends StatelessWidget {
  const ServerCard({super.key, required this.server});
  final Server server;

  @override
  Widget build(BuildContext context) {
    final alert = server.alert;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Bandeau de couleur sur le bord gauche (superposé avec Stack).
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(width: 5, color: statusColor(server.status)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        server.name,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    StatusIndicator(status: server.status),
                  ],
                ),
                const SizedBox(height: 12),
                MetricBar(label: 'CPU', value: server.cpuNow),
                const SizedBox(height: 8),
                MetricBar(label: 'RAM', value: server.ramNow),
                if (alert != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          size: 18, color: statusColor(server.status)),
                      const SizedBox(width: 6),
                      Expanded(child: Text(alert)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
