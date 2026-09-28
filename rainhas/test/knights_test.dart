import 'package:flutter_test/flutter_test.dart';
import 'package:rainhas/game/board.dart';
import 'package:rainhas/game/knights.dart';
import 'package:rainhas/game/levels.dart';

bool validTour(TourLevel level, List<Pos> route) {
  if (route.first != level.start) return false;
  if (route.length != level.squares || route.toSet().length != route.length) {
    return false;
  }
  if (route.any(level.blocked.contains)) return false;
  for (var i = 1; i < route.length; i++) {
    if (!knightAttacks(route[i - 1], route[i])) return false;
  }
  return true;
}

void main() {
  group('movimentos', () {
    test('cavalo no canto tem 2 saídas, no centro tem 8', () {
      expect(knightMoves(8, const Pos(0, 0), {}).length, 2);
      expect(knightMoves(8, const Pos(3, 3), {}).length, 8);
    });

    test('casas bloqueadas não são saídas', () {
      final moves = knightMoves(8, const Pos(0, 0), {const Pos(1, 2)});
      expect(moves, [const Pos(2, 1)]);
    });
  });

  group('passeio do cavalo', () {
    test('toda fase tem passeio completo a partir do início', () {
      for (final n in GameMode.tour.sizes) {
        for (var k = 1; k <= GameMode.tour.perSize; k++) {
          final level = generateTour(n, k);
          final route = completeTour(n, level.blocked, [level.start]);
          expect(route, isNotNull, reason: '$n-$k');
          expect(validTour(level, route!), isTrue, reason: '$n-$k');
        }
      }
    });

    test('fases mais adiantadas têm casas bloqueadas', () {
      expect(generateTour(6, 1).blocked, isEmpty);
      expect(generateTour(6, 6).blocked, isNotEmpty);
    });

    test('caminho sem saída não tem solução', () {
      // No 5×5, começar numa casa de cor minoritária não fecha o passeio.
      expect(completeTour(5, {}, [const Pos(0, 1)]), isNull);
    });
  });

  group('cavalos sem ataque', () {
    test('máximo no tabuleiro vazio é metade das casas', () {
      for (final n in [4, 5, 6, 8]) {
        final cells = [
          for (var r = 0; r < n; r++)
            for (var c = 0; c < n; c++) Pos(r, c),
        ];
        final best = maxIndependentKnights(cells);
        expect(best.length, (n * n + 1) ~/ 2, reason: 'N = $n');
        for (final a in best) {
          for (final b in best) {
            expect(knightAttacks(a, b), isFalse);
          }
        }
      }
    });

    test('fases: o alvo é alcançável e seguir as dicas resolve', () {
      for (final n in GameMode.knights.sizes) {
        for (var k = 1; k <= GameMode.knights.perSize; k++) {
          final level = generateKnights(n, k);
          final placed = <Pos>{};
          for (var i = 0; i < 4 * n * n; i++) {
            final hint = knightsHint(level, placed);
            if (hint == null) break;
            switch (hint) {
              case PlaceHint(:final pos):
                placed.add(pos);
              case RemoveHint(:final pos):
                placed.remove(pos);
            }
          }
          expect(placed.length, level.target, reason: '$n-$k');
          expect(placed.any(level.blocked.contains), isFalse);
          for (final a in placed) {
            for (final b in placed) {
              expect(knightAttacks(a, b), isFalse, reason: '$n-$k');
            }
          }
        }
      }
    });

    test('dica manda tirar cavalo em conflito', () {
      final level = generateKnights(6, 1);
      final free = [
        for (var r = 0; r < 6; r++)
          for (var c = 0; c < 6; c++)
            if (!level.blocked.contains(Pos(r, c))) Pos(r, c),
      ];
      final a = free.firstWhere(
        (p) => knightMoves(6, p, level.blocked).isNotEmpty,
      );
      final b = knightMoves(6, a, level.blocked).first;
      expect(knightsHint(level, {a, b}), isA<RemoveHint>());
    });
  });

  group('trilha de fases', () {
    test('próxima fase passa para o tabuleiro seguinte', () {
      final last = LevelRef(GameMode.tour, 5, GameMode.tour.perSize);
      expect(last.next, const LevelRef(GameMode.tour, 6, 1));
      expect(const LevelRef(GameMode.tour, 6, 1).previous, last);
      expect(const LevelRef(GameMode.tour, 5, 1).previous, isNull);
      expect(LevelRef(GameMode.tour, 8, GameMode.tour.perSize).next, isNull);
    });
  });
}
