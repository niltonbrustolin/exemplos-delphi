import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rainhas/main.dart';
import 'package:rainhas/services/progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await Progress.load();
  });

  testWidgets('resolve o 4×4 no modo clássico', (tester) async {
    await tester.pumpWidget(const RainhasApp());
    await tester.tap(find.text('Modo Clássico'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tabuleiro 4×4'));
    await tester.pumpAndSettle();

    // Solução 1 3 0 2 (coluna da rainha em cada linha).
    for (final (r, c) in [(0, 1), (1, 3), (2, 0), (3, 2)]) {
      await tester.tap(find.byKey(ValueKey('cell_${r}_$c')));
      await tester.pump();
    }
    await tester.pumpAndSettle();

    expect(find.text('Nova solução!'), findsOneWidget);
    expect(find.text('Soluções encontradas: 1 de 2'), findsOneWidget);

    await tester.tap(find.text('Menu'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Soluções: 1 de 2'), findsOneWidget);
  });
}
