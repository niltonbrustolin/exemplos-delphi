import 'package:flutter_test/flutter_test.dart';
import 'package:rainhas/game/board.dart';
import 'package:rainhas/game/challenge.dart';
import 'package:rainhas/game/solver.dart';

void main() {
  group('solver', () {
    test('conta as soluções conhecidas', () {
      const expected = {1: 1, 2: 0, 3: 0, 4: 2, 5: 10, 6: 4, 7: 40, 8: 92};
      expected.forEach((n, count) {
        expect(allSolutions(n).length, count, reason: 'N = $n');
      });
    });

    test('toda solução de 8 é válida', () {
      for (final sol in allSolutions(8)) {
        final queens = {for (var r = 0; r < 8; r++) Pos(r, sol[r])};
        expect(isSolved(8, queens), isTrue);
      }
    });
  });

  group('board', () {
    test('detecta ataques', () {
      expect(attacks(const Pos(0, 0), const Pos(0, 5)), isTrue);
      expect(attacks(const Pos(0, 0), const Pos(5, 0)), isTrue);
      expect(attacks(const Pos(1, 1), const Pos(4, 4)), isTrue);
      expect(attacks(const Pos(0, 3), const Pos(3, 0)), isTrue);
      expect(attacks(const Pos(0, 0), const Pos(1, 2)), isFalse);
    });

    test('conflitos marcam só as rainhas envolvidas', () {
      final c = conflicts({const Pos(0, 0), const Pos(2, 2), const Pos(1, 4)});
      expect(c, {const Pos(0, 0), const Pos(2, 2)});
    });
  });

  group('dicas', () {
    test('sugere remover rainha em conflito', () {
      final hint = computeHint(8, {}, {const Pos(0, 0), const Pos(1, 1)});
      expect(hint, isA<RemoveHint>());
    });

    test('seguir as dicas resolve o tabuleiro', () {
      for (final n in [4, 6, 8]) {
        final placed = <Pos>{};
        for (var i = 0; i < 3 * n; i++) {
          final hint = computeHint(n, {}, placed);
          if (hint == null) break;
          switch (hint) {
            case PlaceHint(:final pos):
              placed.add(pos);
            case RemoveHint(:final pos):
              placed.remove(pos);
          }
        }
        expect(isSolved(n, placed), isTrue, reason: 'N = $n');
      }
    });

    test('tabuleiro resolvido não tem dica', () {
      final sol = allSolutions(8).first;
      final queens = {for (var r = 0; r < 8; r++) Pos(r, sol[r])};
      expect(computeHint(8, {}, queens), isNull);
    });
  });

  group('desafios', () {
    test('todo desafio tem solução única', () {
      for (final n in challengeSizes) {
        for (var k = 1; k <= challengesPerSize; k++) {
          final ch = generateChallenge(n, k);
          final fixed = {for (final p in ch.fixed) p.row: p.col};
          expect(solutionsMatching(n, fixed).length, 1, reason: ch.id);
          expect(ch.fixed.length, lessThan(n), reason: ch.id);
        }
      }
    });

    test('geração é determinística', () {
      expect(generateChallenge(8, 5).fixed, generateChallenge(8, 5).fixed);
    });
  });
}
