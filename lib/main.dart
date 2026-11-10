import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';

void main() => runApp(const ProviderScope(child: App()));

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Atelier 02',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
