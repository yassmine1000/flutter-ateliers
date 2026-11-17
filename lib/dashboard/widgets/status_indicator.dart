import 'package:flutter/material.dart';

import '../models/server.dart';

Color statusColor(ServerStatus s) => switch (s) {
      ServerStatus.online => Colors.green.shade600,
      ServerStatus.warning => Colors.orange.shade700,
      ServerStatus.offline => Colors.red.shade600,
    };

String statusLabel(ServerStatus s) => switch (s) {
      ServerStatus.online => 'En ligne',
      ServerStatus.warning => 'Alerte',
      ServerStatus.offline => 'Hors ligne',
    };

/// Pastille de couleur + libellé. Réutilisé partout où un statut s'affiche.
class StatusIndicator extends StatelessWidget {
  const StatusIndicator({super.key, required this.status});
  final ServerStatus status;

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          statusLabel(status),
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
