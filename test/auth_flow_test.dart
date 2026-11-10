import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:mon_atelier02/auth/auth_state.dart';
import 'package:mon_atelier02/main.dart';
import 'package:mon_atelier02/router.dart';

String _path(WidgetTester t) {
  final c = ProviderScope.containerOf(t.element(find.byType(MaterialApp)));
  return c.read(routerProvider).routeInformationProvider.value.uri.path;
}

void main() {
  testWidgets('accueil inaccessible sans login ni PIN', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();
    final c = ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));

    c.read(routerProvider).go('/home');
    await tester.pumpAndSettle();
    expect(_path(tester), '/login');

    await c.read(authProvider.notifier).login('admin', 'admin123');
    await tester.pumpAndSettle();
    expect(_path(tester), '/2fa');

    c.read(routerProvider).go('/home'); // tentative de contournement
    await tester.pumpAndSettle();
    expect(_path(tester), '/2fa');

    await c.read(authProvider.notifier).verifyPin('123456');
    await tester.pumpAndSettle();
    expect(_path(tester), '/home');
  });
}
