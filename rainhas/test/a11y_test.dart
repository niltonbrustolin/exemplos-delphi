import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rainhas/game/board.dart';
import 'package:rainhas/l10n/l10n.dart';
import 'package:rainhas/services/progress.dart';
import 'package:rainhas/widgets/board_3d.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late List<Pos> taps;

  Future<void> pumpBoard(WidgetTester tester, {required bool flat}) async {
    SharedPreferences.setMockInitialValues({});
    await Progress.load();
    boardFlat.value = flat;
    addTearDown(() => boardFlat.value = false);
    taps = [];
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(
            child: SizedBox.square(
              dimension: 400,
              child: Board3D(
                n: 4,
                pieces: const [
                  BoardPiece(1, Pos(0, 0), PieceKind.queen, PieceRole.fixed),
                  BoardPiece(2, Pos(3, 3), PieceKind.queen, PieceRole.conflict),
                ],
                blocked: {const Pos(2, 0)},
                marks: const [
                  CellMark(
                    Pos(0, 1),
                    MarkKind.dot,
                    Color(0xFFFF0000),
                    label: 'atacada',
                  ),
                ],
                onTap: taps.add,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('cada casa tem nome e conteúdo para o leitor de tela', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    for (final flat in [false, true]) {
      await pumpBoard(tester, flat: flat);
      expect(find.bySemanticsLabel('a4, rainha fixa'), findsOneWidget);
      expect(find.bySemanticsLabel('d1, rainha, em conflito'), findsOneWidget);
      expect(find.bySemanticsLabel('a2, bloqueada'), findsOneWidget);
      expect(find.bySemanticsLabel('b4, atacada'), findsOneWidget);
      tester.semantics.tap(find.semantics.byLabel('b3, vazia'));
      expect(taps, [const Pos(1, 1)]);
    }
    semantics.dispose();
  });

  testWidgets('teclado: setas escolhem a casa e Enter joga', (tester) async {
    await pumpBoard(tester, flat: false);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    expect(taps, [const Pos(1, 2), const Pos(1, 1)]);
  });

  testWidgets('vista 2D: o toque cai na casa certa', (tester) async {
    await pumpBoard(tester, flat: true);
    final topLeft = tester.getTopLeft(find.byType(Board3D));
    // 400 px para 4 casas + moldura: cada casa tem 400 / 5,1 px.
    const cell = 400 / 5.1;
    const origin = 200 - 2 * cell;
    await tester.tapAt(
      topLeft + const Offset(origin + 2.5 * cell, origin + 0.5 * cell),
    );
    await tester.tapAt(
      topLeft + const Offset(origin + 0.5 * cell, origin + 3.5 * cell),
    );
    expect(taps, [const Pos(0, 2), const Pos(3, 0)]);
  });
}
