import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_state.dart';
import '../dashboard/dashboard_screen.dart';
import '../widgets/auth_status_banner.dart';

/// Écran protégé par le tunnel d'authentification : affiche le dashboard.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      bottomNavigationBar: const AuthStatusBanner(),
      appBar: AppBar(
        title: const Text('Dashboard réseau'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Se déconnecter',
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: const DashboardScreen(),
    );
  }
}
