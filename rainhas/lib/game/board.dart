import 'solver.dart';

/// Uma casa do tabuleiro.
class Pos {
  final int row;
  final int col;

  const Pos(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      other is Pos && other.row == row && other.col == col;

  @override
  int get hashCode => Object.hash(row, col);

  @override
  String toString() => 'Pos($row, $col)';
}

/// Duas rainhas se atacam se estão na mesma linha, coluna ou diagonal.
bool attacks(Pos a, Pos b) =>
    a.row == b.row ||
    a.col == b.col ||
    (a.row - b.row).abs() == (a.col - b.col).abs();

/// Rainhas que atacam pelo menos uma outra rainha.
Set<Pos> conflicts(Iterable<Pos> queens) {
  final list = queens.toList();
  final result = <Pos>{};
  for (var i = 0; i < list.length; i++) {
    for (var j = i + 1; j < list.length; j++) {
      if (attacks(list[i], list[j])) {
        result
          ..add(list[i])
          ..add(list[j]);
      }
    }
  }
  return result;
}

/// Casas atacadas por alguma das [queens] (sem contar as próprias rainhas).
Set<Pos> attackedCells(int n, Iterable<Pos> queens) {
  final result = <Pos>{};
  final queenSet = queens.toSet();
  for (var r = 0; r < n; r++) {
    for (var c = 0; c < n; c++) {
      final p = Pos(r, c);
      if (!queenSet.contains(p) && queenSet.any((q) => attacks(p, q))) {
        result.add(p);
      }
    }
  }
  return result;
}

bool isSolved(int n, Set<Pos> queens) =>
    queens.length == n && conflicts(queens).isEmpty;

/// Converte um conjunto de rainhas resolvido em `cols[linha]`.
List<int> toCols(int n, Set<Pos> queens) {
  final cols = List<int>.filled(n, -1);
  for (final q in queens) {
    cols[q.row] = q.col;
  }
  return cols;
}

sealed class Hint {
  final Pos pos;
  const Hint(this.pos);
}

/// Sugere colocar uma rainha em [pos].
class PlaceHint extends Hint {
  const PlaceHint(super.pos);
}

/// Sugere remover a rainha em [pos].
class RemoveHint extends Hint {
  const RemoveHint(super.pos);
}

/// Calcula uma dica para o jogador.
///
/// Procura, entre as soluções que respeitam as rainhas fixas, a que mais
/// aproveita as rainhas já colocadas. Se todas as rainhas do jogador cabem
/// nessa solução, sugere a próxima casa; senão, sugere remover a rainha
/// que está fora dela. Retorna `null` se o tabuleiro já está resolvido.
Hint? computeHint(int n, Set<Pos> fixed, Set<Pos> placed) {
  if (isSolved(n, {...fixed, ...placed})) return null;

  final fixedMap = {for (final p in fixed) p.row: p.col};
  List<int>? best;
  var bestScore = -1;
  for (final sol in solutionsMatching(n, fixedMap)) {
    final score = placed.where((p) => sol[p.row] == p.col).length;
    if (score > bestScore) {
      best = sol;
      bestScore = score;
      if (score == placed.length) break;
    }
  }
  if (best == null) return null;

  final sol = best;
  final wrong = placed.where((p) => sol[p.row] != p.col).toList()
    ..sort((a, b) => a.row != b.row ? a.row - b.row : a.col - b.col);
  if (wrong.isNotEmpty) return RemoveHint(wrong.first);

  final occupied = {...fixed, ...placed}.map((p) => p.row).toSet();
  for (var r = 0; r < n; r++) {
    if (!occupied.contains(r)) return PlaceHint(Pos(r, sol[r]));
  }
  return null;
}
