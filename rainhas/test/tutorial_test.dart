import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rainhas/game/board.dart';
import 'package:rainhas/game/demos.dart';
import 'package:rainhas/game/knights.dart';
import 'package:rainhas/l10n/l10n.dart';
import 'package:rainhas/main.dart';
import 'package:rainhas/screens/classic_select_screen.dart';
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

  Future<void> openApp(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'language': 'pt'});
    await Progress.load();
    appLanguage.value = 'pt';
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const EightQueensApp());
    await tester.pump();
  }

  testWidgets('primeira abertura vai direto à tela inicial, com boas-vindas', (
    tester,
  ) async {
    await openApp(tester);
    // Nada de tutorial forçado: os modos já aparecem, cada um explicado.
    expect(find.text('Novo por aqui?'), findsOneWidget);
    expect(find.text('Modo Clássico', skipOffstage: false), findsOneWidget);
    expect(
      find.text(
        'Tabuleiro vazio, sem fases: ache todas as soluções.',
        skipOffstage: false,
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Entendi'));
    await tester.pump();
    expect(Progress.instance.tutorialSeen, isTrue);
    expect(find.text('Novo por aqui?'), findsNothing);
  });

  testWidgets('tutorial abre pelo cartão e leva direto ao modo', (
    tester,
  ) async {
    await openApp(tester);
    await tester.tap(find.text('Ver como jogar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(
      find.text('Toque numa casa para colocar uma rainha'),
      findsOneWidget,
    );

    await tester.tap(find.text('Jogar este modo'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));
    expect(Progress.instance.tutorialSeen, isTrue);
    expect(find.byType(ClassicSelectScreen), findsOneWidget);
  });

  testWidgets('idioma pelo endereço e seletor na tela inicial', (tester) async {
    expect(languageFromUrl(Uri.parse('https://x/jogar/?lang=es')), 'es');
    expect(languageFromUrl(Uri.parse('https://x/jogar/?lang=pt-BR')), 'pt');
    expect(languageFromUrl(Uri.parse('https://x/jogar/?lang=de')), isNull);
    expect(languageFromUrl(Uri.parse('https://x/jogar/')), isNull);

    await openApp(tester);
    await tester.tap(find.text('PT'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('English').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Classic Mode', skipOffstage: false), findsOneWidget);
    expect(Progress.instance.language, 'en');
  });
}
