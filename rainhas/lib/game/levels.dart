import 'challenge.dart';

/// Modos com fases (o Clássico das rainhas é livre e não entra aqui).
enum GameMode {
  queens(
    title: 'Desafios das Rainhas',
    short: 'Rainhas',
    sizes: challengeSizes,
    perSize: challengesPerSize,
  ),
  tour(
    title: 'Passeio do Cavalo',
    short: 'Passeio',
    sizes: [5, 6, 7, 8],
    perSize: 8,
  ),
  knights(
    title: 'Cavalos sem Ataque',
    short: 'Cavalos',
    sizes: [5, 6, 7, 8],
    perSize: 8,
  );

  const GameMode({
    required this.title,
    required this.short,
    required this.sizes,
    required this.perSize,
  });

  final String title;
  final String short;
  final List<int> sizes;
  final int perSize;

  int get totalLevels => sizes.length * perSize;
}

/// Referência a uma fase: modo, tamanho do tabuleiro e número (1..perSize).
class LevelRef {
  final GameMode mode;
  final int n;
  final int number;

  const LevelRef(this.mode, this.n, this.number);

  String get key => '${mode.name}_${n}_$number';

  /// Fase anterior na trilha (`null` para a primeira).
  LevelRef? get previous {
    if (number > 1) return LevelRef(mode, n, number - 1);
    final i = mode.sizes.indexOf(n);
    return i <= 0 ? null : LevelRef(mode, mode.sizes[i - 1], mode.perSize);
  }

  /// Próxima fase na trilha (`null` para a última).
  LevelRef? get next {
    if (number < mode.perSize) return LevelRef(mode, n, number + 1);
    final i = mode.sizes.indexOf(n);
    return i + 1 >= mode.sizes.length
        ? null
        : LevelRef(mode, mode.sizes[i + 1], 1);
  }

  @override
  bool operator ==(Object other) =>
      other is LevelRef &&
      other.mode == mode &&
      other.n == n &&
      other.number == number;

  @override
  int get hashCode => Object.hash(mode, n, number);
}

/// Estrelas conforme as dicas usadas.
int starsFor(int hintsUsed) => hintsUsed == 0 ? 3 : (hintsUsed == 1 ? 2 : 1);
