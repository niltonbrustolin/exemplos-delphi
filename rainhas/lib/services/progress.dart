import 'package:shared_preferences/shared_preferences.dart';

import '../game/challenge.dart';

/// Progresso do jogador, salvo no aparelho.
class Progress {
  Progress._(this._prefs);

  static late Progress instance;

  final SharedPreferences _prefs;

  static Future<void> load() async {
    instance = Progress._(await SharedPreferences.getInstance());
  }

  // --- Modo clássico ---

  /// Soluções diferentes já encontradas no tabuleiro N×N.
  Set<String> foundSolutions(int n) =>
      (_prefs.getStringList('found_$n') ?? const []).toSet();

  /// Registra uma solução; retorna `true` se ela ainda não tinha sido achada.
  Future<bool> addSolution(int n, List<int> cols) async {
    final found = foundSolutions(n);
    if (!found.add(cols.join(','))) return false;
    await _prefs.setStringList('found_$n', found.toList());
    return true;
  }

  /// Melhor tempo em segundos no tabuleiro N×N, ou `null`.
  int? bestTime(int n) => _prefs.getInt('best_$n');

  /// Salva o tempo se for recorde; retorna `true` nesse caso.
  Future<bool> submitTime(int n, int seconds) async {
    final best = bestTime(n);
    if (best != null && best <= seconds) return false;
    await _prefs.setInt('best_$n', seconds);
    return true;
  }

  // --- Desafios ---

  int stars(Challenge c) => _prefs.getInt('stars_${c.id}') ?? 0;

  Future<void> saveStars(Challenge c, int stars) async {
    if (stars > this.stars(c)) await _prefs.setInt('stars_${c.id}', stars);
  }

  /// O primeiro desafio de cada tamanho está sempre liberado; os seguintes
  /// liberam quando o anterior é concluído.
  bool isUnlocked(int n, int number) =>
      number == 1 || stars(generateChallenge(n, number - 1)) > 0;

  // --- Preferências ---

  /// Marca as casas atacadas no tabuleiro (ajuda para iniciantes).
  bool get showAttacks => _prefs.getBool('show_attacks') ?? false;

  set showAttacks(bool value) => _prefs.setBool('show_attacks', value);

  // --- Anúncios ---

  /// Vitórias desde o último anúncio de tela cheia.
  int get winsSinceAd => _prefs.getInt('wins_since_ad') ?? 0;

  set winsSinceAd(int value) => _prefs.setInt('wins_since_ad', value);
}
