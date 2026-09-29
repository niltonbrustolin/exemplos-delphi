import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rainhas/game/board.dart';
import 'package:rainhas/game/solver.dart';
import 'package:rainhas/l10n/l10n.dart';
import 'package:rainhas/render3d/themes.dart';
import 'package:rainhas/services/share.dart';
import 'package:rainhas/widgets/board_3d.dart';

void main() {
  testWidgets('gera a imagem de resultado em PNG 1080×1350', (tester) async {
    final l = await AppLocalizations.delegate.load(const Locale('pt'));
    final sol = allSolutions(8).first;
    final card = ShareCard(
      board: ShareBoard(
        n: 8,
        pieces: [
          for (var r = 0; r < 8; r++)
            BoardPiece(r, Pos(r, sol[r]), PieceKind.queen, PieceRole.player),
        ],
      ),
      title: 'Desafio do dia',
      subtitle: 'Rainhas · 8×8',
      stars: 3,
      seconds: 42,
      streak: 5,
    );
    final png = await tester.runAsync(
      () => renderShareImage(card, l, boardThemes.first),
    );
    expect(png, isNotNull);
    // Assinatura PNG e tamanho no cabeçalho IHDR.
    expect(png!.sublist(1, 4), 'PNG'.codeUnits);
    final data = ByteData.sublistView(png);
    expect(data.getUint32(16), 1080);
    expect(data.getUint32(20), 1350);

    final out = Platform.environment['SHARE_PNG_OUT'];
    if (out != null) File(out).writeAsBytesSync(png);
  });
}
