import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rainhas/game/board.dart';
import 'package:rainhas/game/demos.dart';
import 'package:rainhas/game/knights.dart';
import 'package:rainhas/l10n/l10n.dart';
import 'package:rainhas/main.dart';
import 'package:rainhas/services/progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('demo das rainhas termina com o tabuleiro resolvido', () {
    final frames = queensDemo();
    expect(frames.any((f) => f.caption == DemoCaption.conflict), isTrue);
    final last = frames.last;
    expect(last.solved, isTrue);
    expect(isSolved(last.n, last.pieces.keys.toSet()), isTrue);
  });

  test('demo do passeio só faz pulos de cavalo', () {
    final frames = tourDemo();
    final path = frames.last.visited;
    expect(path.length, greaterThan(4));
    for (var i = 1; i < path.length; i++) {
      expect(knightAttacks(path[i - 1], path[i]), isTrue);
    }
    // A casa indicada para tocar é sempre uma jogada possível.
    for (final f in frames) {
      if (f.tap != null) expect(f.moves, contains(f.tap));
    }
  });

  test('demo dos cavalos termina sem ataques e sem usar blocos', () {
    final last = knightsDemo().last;
    final knights = last.pieces.keys.toList();
    expect(last.solved, isTrue);
    expect(knights.any(last.blocked.contains), isFalse);
    for (final a in knights) {
      for (final b in knights) {
        expect(knightAttacks(a, b), isFalse);
      }
    }
  });

  testWidgets('tutorial aparece na primeira abertura', (tester) async {
    SharedPreferences.setMockInitialValues({'language': 'pt'});
    await Progress.load();
    appLanguage.value = 'pt';
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const EightQueensApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Pular'), findsOneWidget);
    expect(
      find.text('Toque numa casa para colocar uma rainha'),
      findsOneWidget,
    );

    await tester.tap(find.text('Pular'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(Progress.instance.tutorialSeen, isTrue);
    expect(find.text('Modo Clássico'), findsOneWidget);
  });
}
