import 'dart:math';

import 'board.dart';
import 'solver.dart';

/// Tamanhos de tabuleiro disponíveis no modo Desafios.
const challengeSizes = [5, 6, 7, 8, 9, 10];

/// Quantidade de desafios por tamanho de tabuleiro.
const challengesPerSize = 12;

/// Um desafio: algumas rainhas já vêm fixas e só existe um jeito de
/// completar o tabuleiro.
class Challenge {
  final int n;

  /// Número do desafio dentro do tamanho, começando em 1.
  final int number;
  final Set<Pos> fixed;
  final List<int> solution;

  const Challenge(this.n, this.number, this.fixed, this.solution);

  String get id => '$n-$number';
}

final Map<String, Challenge> _cache = {};

/// Gera o desafio [number] do tabuleiro [n].
///
/// A geração é determinística (semente fixa), então todo jogador recebe os
/// mesmos desafios. Parte de uma solução e vai removendo rainhas enquanto a
/// solução continuar única; os primeiros desafios recebem rainhas extras
/// para ficarem mais fáceis.
Challenge generateChallenge(int n, int number) {
  return _cache.putIfAbsent('$n-$number', () {
    final solutions = allSolutions(n);
    final rng = Random(n * 7919);
    final order = List.generate(solutions.length, (i) => i)..shuffle(rng);
    final solution = solutions[order[(number - 1) % order.length]];

    final levelRng = Random(n * 1000 + number);
    final rows = List.generate(n, (i) => i)..shuffle(levelRng);
    final fixed = {for (final r in rows) r: solution[r]};
    final removed = <int>[];
    for (final r in rows) {
      final col = fixed.remove(r)!;
      if (solutionsMatching(n, fixed).take(2).length == 1) {
        removed.add(r);
      } else {
        fixed[r] = col;
      }
    }

    // Os primeiros desafios de cada tamanho dão mais rainhas de ajuda.
    final extra = number <= 3 ? 2 : (number <= 7 ? 1 : 0);
    for (final r in removed.take(min(extra, max(0, removed.length - 2)))) {
      fixed[r] = solution[r];
    }

    return Challenge(n, number, {
      for (final e in fixed.entries) Pos(e.key, e.value),
    }, solution);
  });
}

/// Estrelas ganhas conforme o número de dicas usadas.
int starsFor(int hintsUsed) => hintsUsed == 0 ? 3 : (hintsUsed == 1 ? 2 : 1);
