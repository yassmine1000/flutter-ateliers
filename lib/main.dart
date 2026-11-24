import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'router.dart';
import 'weather/data/weather_cache.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final box = await Hive.openBox<String>('weather_cache');
  runApp(
    ProviderScope(
      overrides: [
        weatherCacheProvider.overrideWithValue(HiveWeatherCache(box)),
      ],
      child: const App(),
    ),
  );
}

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
