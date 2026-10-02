import 'challenge.dart';

/// Modos com fases (o Clássico das rainhas é livre e não entra aqui).
enum GameMode {
  queens(sizes: challengeSizes, perSize: challengesPerSize),
  tour(sizes: [5, 6, 7, 8], perSize: 8),
  knights(sizes: [5, 6, 7, 8], perSize: 8);

  const GameMode({required this.sizes, required this.perSize});

  final List<int> sizes;
  final int perSize;

  int get totalLevels => sizes.length * perSize;
}

/// Referência a uma fase: modo, tamanho do tabuleiro e número (1..perSize).
class LevelRef {
  final GameMode mode;
  final int n;
  final int number;

  /// Semente extra do gerador (o dia, no desafio do dia).
  final int variant;

  /// Desafio do dia: fica fora da trilha de fases.
  final bool daily;

  const LevelRef(
    this.mode,
    this.n,
    this.number, {
    this.variant = 0,
    this.daily = false,
  });

  String get key => daily ? 'daily_$variant' : '${mode.name}_${n}_$number';

  /// Fase anterior na trilha (`null` para a primeira).
  LevelRef? get previous {
    if (daily) return null;
    if (number > 1) return LevelRef(mode, n, number - 1);
    final i = mode.sizes.indexOf(n);
    return i <= 0 ? null : LevelRef(mode, mode.sizes[i - 1], mode.perSize);
  }

  /// Próxima fase na trilha (`null` para a última).
  LevelRef? get next {
    if (daily) return null;
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
      other.number == number &&
      other.variant == variant &&
      other.daily == daily;

  @override
  int get hashCode => Object.hash(mode, n, number, variant, daily);
}

/// Estrelas conforme as dicas usadas.
int starsFor(int hintsUsed) => hintsUsed == 0 ? 3 : (hintsUsed == 1 ? 2 : 1);

/// Primeira fase recomendada para quem nunca jogou: Desafios das Rainhas,
/// fase 1.
final firstLevel = LevelRef(GameMode.queens, GameMode.queens.sizes.first, 1);
