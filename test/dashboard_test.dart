import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mon_atelier02/dashboard/dashboard_screen.dart';
import 'package:mon_atelier02/dashboard/widgets/server_card.dart';

Future<void> _pumpAtWidth(WidgetTester tester, double width) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    const ProviderScope(
      child: MaterialApp(home: Scaffold(body: DashboardScreen())),
    ),
  );
  await tester.pumpAndSettle();
}

double _top(WidgetTester t, int i) =>
    t.getTopLeft(find.byType(ServerCard).at(i)).dy;

void main() {
  testWidgets('1000 px : 3 colonnes, aucun overflow', (tester) async {
    await _pumpAtWidth(tester, 1000);
    expect(tester.takeException(), isNull);
    expect(_top(tester, 0), _top(tester, 1));
    expect(_top(tester, 1), _top(tester, 2));
    expect(_top(tester, 3), greaterThan(_top(tester, 0)));
  });

  testWidgets('700 px : 2 colonnes, aucun overflow', (tester) async {
    await _pumpAtWidth(tester, 700);
    expect(tester.takeException(), isNull);
    expect(_top(tester, 0), _top(tester, 1));
    expect(_top(tester, 2), greaterThan(_top(tester, 0)));
  });

  testWidgets('360 px : 1 colonne, aucun overflow', (tester) async {
    await _pumpAtWidth(tester, 360);
    expect(tester.takeException(), isNull);
    expect(_top(tester, 1), greaterThan(_top(tester, 0)));
  });
}
