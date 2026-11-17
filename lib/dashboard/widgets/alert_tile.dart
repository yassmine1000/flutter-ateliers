import 'package:flutter/material.dart';

import '../models/server.dart';
import 'status_indicator.dart';

class AlertTile extends StatelessWidget {
  const AlertTile({super.key, required this.server});
  final Server server;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.warning_amber_rounded,
            color: statusColor(server.status)),
        title: Text(server.name),
        subtitle: Text(server.alert ?? ''),
      ),
    );
  }
}
