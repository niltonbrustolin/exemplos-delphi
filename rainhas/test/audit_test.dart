import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rainhas/game/levels.dart';
import 'package:rainhas/l10n/l10n.dart';
import 'package:rainhas/screens/level_select_screen.dart';
import 'package:rainhas/screens/queens_game_screen.dart';
import 'package:rainhas/services/progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app(Widget home) => MaterialApp(
  locale: const Locale('pt'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({'hints': 5});
    await Progress.load();
  });

  testWidgets('seletor de fases atualiza sem precisar sair e voltar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      _app(const LevelSelectScreen(mode: GameMode.queens)),
    );
    expect(find.byIcon(Icons.lock_outline), findsWidgets);
    final locksBefore = find.byIcon(Icons.lock_outline).evaluate().length;

    // Vitórias em sequência (como pelo botão "Próxima"), sem voltar ao menu.
    final first = LevelRef(GameMode.queens, GameMode.queens.sizes.first, 1);
    await Progress.instance.saveStars(first, 3);
    await Progress.instance.saveStars(first.next!, 2);
    await tester.pump();

    expect(find.byIcon(Icons.lock_outline).evaluate().length, locksBefore - 2);
    expect(find.text(' 5/${GameMode.queens.totalLevels * 3}'), findsOneWidget);
  });

  testWidgets('pedir a mesma dica de novo não cobra outra vez', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final level = LevelRef(GameMode.queens, GameMode.queens.sizes.first, 1);
    await tester.pumpWidget(_app(QueensGameScreen.challenge(level: level)));
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('Dica (5)'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(Progress.instance.hints, 4);
    await tester.tap(find.text('Dica (4)'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Dica (4)'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(Progress.instance.hints, 4);
    // Uma dica usada na partida, não três.
    expect(find.text('1'), findsWidgets);
    expect(find.text('dicas usadas'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });
}
