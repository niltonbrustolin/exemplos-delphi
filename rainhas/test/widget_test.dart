import 'package:flutter_test/flutter_test.dart';
import 'package:rainhas/game/board.dart';
import 'package:rainhas/main.dart';
import 'package:rainhas/services/progress.dart';
import 'package:rainhas/widgets/board_3d.dart';
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

    // Toca no centro de cada casa, projetado pela câmera 3D inicial.
    final board = find.byType(Board3D);
    final camera = boardCamera(4, tester.getSize(board));
    final origin = tester.getTopLeft(board);
    // Solução 1 3 0 2 (coluna da rainha em cada linha).
    for (final (r, c) in [(0, 1), (1, 3), (2, 0), (3, 2)]) {
      final screen = camera.project(cellCenter(4, Pos(r, c)))!;
      await tester.tapAt(origin + screen);
      await tester.pump(const Duration(milliseconds: 700));
    }
    // Espera a comemoração (as rainhas continuam pulando, então não dá
    // para usar pumpAndSettle aqui).
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Nova solução!'), findsOneWidget);
    expect(find.text('Soluções encontradas: 1 de 2'), findsOneWidget);

    await tester.tap(find.text('Menu'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Soluções: 1 de 2'), findsOneWidget);
  });
}
