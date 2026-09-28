/// Solucionador do problema das N rainhas.
///
/// Uma solução é representada como uma lista `cols` de tamanho N em que
/// `cols[linha]` é a coluna da rainha naquela linha.
library;

final Map<int, List<List<int>>> _cache = {};

/// Todas as soluções para um tabuleiro N×N (resultado em cache).
///
/// Usa backtracking com máscaras de bits: para cada linha, os bits livres
/// são as colunas que não estão atacadas por coluna nem pelas diagonais.
List<List<int>> allSolutions(int n) {
  return _cache.putIfAbsent(n, () {
    final result = <List<int>>[];
    final cols = List<int>.filled(n, 0);
    final full = (1 << n) - 1;

    void place(int row, int usedCols, int diag1, int diag2) {
      if (row == n) {
        result.add(List<int>.unmodifiable(cols));
        return;
      }
      var free = full & ~(usedCols | diag1 | diag2);
      while (free != 0) {
        final bit = free & -free;
        free ^= bit;
        cols[row] = bit.bitLength - 1;
        place(
          row + 1,
          usedCols | bit,
          ((diag1 | bit) << 1) & full,
          (diag2 | bit) >> 1,
        );
      }
    }

    place(0, 0, 0, 0);
    return List.unmodifiable(result);
  });
}

/// Soluções que contêm todas as rainhas de [fixed] (mapa linha → coluna).
Iterable<List<int>> solutionsMatching(int n, Map<int, int> fixed) {
  return allSolutions(n)
      .where((sol) => fixed.entries.every((e) => sol[e.key] == e.value));
}
