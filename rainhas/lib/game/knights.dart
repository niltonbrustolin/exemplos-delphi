import 'dart:math';

import 'board.dart';

const _jumps = [
  (1, 2), (2, 1), (2, -1), (1, -2), //
  (-1, -2), (-2, -1), (-2, 1), (-1, 2),
];

bool knightAttacks(Pos a, Pos b) {
  final dr = (a.row - b.row).abs(), dc = (a.col - b.col).abs();
  return (dr == 1 && dc == 2) || (dr == 2 && dc == 1);
}

/// Casas para onde o cavalo em [p] pode pular (dentro do tabuleiro e fora
/// das casas bloqueadas).
Iterable<Pos> knightMoves(int n, Pos p, Set<Pos> blocked) sync* {
  for (final (dr, dc) in _jumps) {
    final q = Pos(p.row + dr, p.col + dc);
    if (q.row >= 0 &&
        q.col >= 0 &&
        q.row < n &&
        q.col < n &&
        !blocked.contains(q)) {
      yield q;
    }
  }
}

List<Pos> _cells(int n, Set<Pos> blocked) => [
  for (var r = 0; r < n; r++)
    for (var c = 0; c < n; c++)
      if (!blocked.contains(Pos(r, c))) Pos(r, c),
];

// ---------------------------------------------------------------------------
// Passeio do Cavalo
// ---------------------------------------------------------------------------

/// Uma fase do Passeio do Cavalo: começar em [start] e passar por todas as
/// casas livres exatamente uma vez.
class TourLevel {
  final int n;
  final int number;
  final Pos start;
  final Set<Pos> blocked;

  const TourLevel(this.n, this.number, this.start, this.blocked);

  int get squares => n * n - blocked.length;
}

/// Completa o passeio a partir de [path] (casas já visitadas, a última é a
/// posição atual). Usa a regra de Warnsdorff (ir primeiro para a casa com
/// menos saídas) com retrocesso. Retorna o passeio completo ou `null` se não
/// houver solução — ou se a busca passar de [limit] tentativas.
List<Pos>? completeTour(
  int n,
  Set<Pos> blocked,
  List<Pos> path, {
  int limit = 200000,
}) {
  final total = n * n - blocked.length;
  final visited = {...path};
  final route = [...path];
  var budget = limit;

  int degree(Pos p) =>
      knightMoves(n, p, blocked).where((q) => !visited.contains(q)).length;

  bool search() {
    if (route.length == total) return true;
    if (--budget < 0) return false;
    final options =
        knightMoves(
            n,
            route.last,
            blocked,
          ).where((q) => !visited.contains(q)).toList()
          ..sort((a, b) => degree(a).compareTo(degree(b)));
    for (final q in options) {
      visited.add(q);
      route.add(q);
      if (search()) return true;
      route.removeLast();
      visited.remove(q);
      if (budget < 0) return false;
    }
    return false;
  }

  if (path.isEmpty) return null;
  return search() ? route : null;
}

final Map<String, TourLevel> _tourCache = {};

/// Gera a fase [number] do Passeio do Cavalo no tabuleiro [n]. As primeiras
/// fases não têm casas bloqueadas; depois elas vão aumentando. Toda fase
/// gerada tem solução garantida.
TourLevel generateTour(int n, int number) {
  return _tourCache.putIfAbsent('$n-$number', () {
    final blockedCount = number <= 2 ? 0 : min(number - 2, 4);
    for (var attempt = 0; ; attempt++) {
      final rng = Random(n * 5003 + number * 97 + attempt);
      final cells = _cells(n, const {})..shuffle(rng);
      final blocked = cells.take(blockedCount).toSet();
      final free = cells.skip(blockedCount).toList();
      for (final start in free.take(6)) {
        if (completeTour(n, blocked, [start], limit: 60000) != null) {
          return TourLevel(n, number, start, blocked);
        }
      }
    }
  });
}

// ---------------------------------------------------------------------------
// Cavalos sem ataque
// ---------------------------------------------------------------------------

/// Uma fase de Cavalos sem ataque: colocar [target] cavalos nas casas livres
/// sem que nenhum ataque outro. [target] é o máximo possível.
class KnightsLevel {
  final int n;
  final int number;
  final Set<Pos> blocked;
  final int target;

  const KnightsLevel(this.n, this.number, this.blocked, this.target);
}

/// Maior conjunto de casas em que cavalos não se atacam (conjunto
/// independente máximo). O grafo do cavalo é bipartido (o cavalo sempre muda
/// de cor), então basta um emparelhamento máximo e o teorema de König.
Set<Pos> maxIndependentKnights(List<Pos> cells) {
  final cellSet = cells.toSet();
  final left = cells.where((p) => (p.row + p.col).isEven).toList();
  final right = cells.where((p) => (p.row + p.col).isOdd).toList();
  List<Pos> adj(Pos p) => [
    for (final (dr, dc) in _jumps)
      if (cellSet.contains(Pos(p.row + dr, p.col + dc)))
        Pos(p.row + dr, p.col + dc),
  ];

  final matchL = <Pos, Pos>{}, matchR = <Pos, Pos>{};
  bool augment(Pos u, Set<Pos> seen) {
    for (final v in adj(u)) {
      if (!seen.add(v)) continue;
      final w = matchR[v];
      if (w == null || augment(w, seen)) {
        matchL[u] = v;
        matchR[v] = u;
        return true;
      }
    }
    return false;
  }

  for (final u in left) {
    augment(u, <Pos>{});
  }

  // König: a partir dos vértices livres da esquerda, caminhos alternados.
  final zLeft = <Pos>{}, zRight = <Pos>{};
  final queue = [
    for (final u in left)
      if (!matchL.containsKey(u)) u,
  ];
  zLeft.addAll(queue);
  while (queue.isNotEmpty) {
    final u = queue.removeLast();
    for (final v in adj(u)) {
      if (matchL[u] == v || !zRight.add(v)) continue;
      final w = matchR[v];
      if (w != null && zLeft.add(w)) queue.add(w);
    }
  }
  // Cobertura mínima = (esquerda fora de Z) + (direita em Z); o conjunto
  // independente é o complemento.
  return {...zLeft, ...right.where((v) => !zRight.contains(v))};
}

final Map<String, KnightsLevel> _knightsCache = {};

/// Gera a fase [number] de Cavalos sem ataque no tabuleiro [n]. Prefere
/// fases em que o truque de usar só uma cor NÃO chega ao máximo.
KnightsLevel generateKnights(int n, int number) {
  return _knightsCache.putIfAbsent('$n-$number', () {
    final holes = 2 + number + n ~/ 2;
    KnightsLevel? fallback;
    for (var attempt = 0; attempt < 80; attempt++) {
      final rng = Random(n * 7727 + number * 131 + attempt);
      final all = _cells(n, const {})..shuffle(rng);
      final blocked = all.take(holes).toSet();
      final cells = _cells(n, blocked);
      final best = maxIndependentKnights(cells).length;
      final light = cells.where((p) => (p.row + p.col).isEven).length;
      final level = KnightsLevel(n, number, blocked, best);
      if (best > max(light, cells.length - light)) return level;
      fallback ??= level;
    }
    return fallback!;
  });
}

/// Dica para Cavalos sem ataque: uma casa para colocar, ou um cavalo para
/// tirar. Retorna `null` se já está resolvido.
Hint? knightsHint(KnightsLevel level, Set<Pos> placed) {
  final cells = _cells(level.n, level.blocked);
  final attacked = <Pos>{
    for (final a in placed)
      for (final b in placed)
        if (knightAttacks(a, b)) a,
  };
  if (attacked.isEmpty && placed.length == level.target) return null;

  // Primeiro desfaz conflitos: tira o cavalo que ataca mais.
  if (attacked.isNotEmpty) {
    int hits(Pos p) => placed.where((q) => knightAttacks(p, q)).length;
    final worst = attacked.reduce((a, b) => hits(a) >= hits(b) ? a : b);
    return RemoveHint(worst);
  }

  // Melhor resultado mantendo os cavalos [keep].
  (int, Set<Pos>) bestWith(Set<Pos> keep) {
    final free = cells
        .where(
          (p) => !keep.contains(p) && !keep.any((k) => knightAttacks(p, k)),
        )
        .toList();
    final extra = maxIndependentKnights(free);
    return (keep.length + extra.length, extra);
  }

  final (total, extra) = bestWith(placed);
  if (total == level.target && extra.isNotEmpty) {
    final sorted = extra.toList()
      ..sort((a, b) => a.row != b.row ? a.row - b.row : a.col - b.col);
    return PlaceHint(sorted.first);
  }
  // Algum cavalo está atrapalhando: tira o que mais melhora o resultado.
  Pos? bestRemove;
  var bestTotal = -1;
  for (final p in placed) {
    final (t, _) = bestWith({...placed}..remove(p));
    if (t > bestTotal) {
      bestTotal = t;
      bestRemove = p;
    }
  }
  return bestRemove == null ? null : RemoveHint(bestRemove);
}
