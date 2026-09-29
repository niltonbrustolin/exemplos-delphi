import 'package:shared_preferences/shared_preferences.dart';

import '../game/levels.dart';
import '../render3d/themes.dart';

/// Dicas com que o jogador começa.
const initialHints = 3;

/// Dicas ganhas ao vencer uma fase pela primeira vez.
const hintsPerNewLevel = 1;

/// Dicas ganhas ao assistir a um vídeo.
const hintsPerVideo = 2;

/// Progresso do jogador, salvo no aparelho.
class Progress {
  Progress._(this._prefs);

  static late Progress instance;

  final SharedPreferences _prefs;

  static Future<void> load() async {
    instance = Progress._(await SharedPreferences.getInstance());
  }

  // --- Modo clássico das rainhas ---

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

  // --- Fases ---

  int stars(LevelRef level) => _prefs.getInt('stars_${level.key}') ?? 0;

  /// Salva as estrelas (se melhorou). Retorna `true` se a fase foi vencida
  /// pela primeira vez.
  Future<bool> saveStars(LevelRef level, int stars) async {
    final old = this.stars(level);
    if (stars > old) await _prefs.setInt('stars_${level.key}', stars);
    return old == 0;
  }

  /// Trilha única: cada fase só abre depois de vencer a anterior, inclusive
  /// entre tamanhos de tabuleiro.
  bool isUnlocked(LevelRef level) {
    final prev = level.previous;
    return prev == null || stars(prev) > 0;
  }

  int starsInMode(GameMode mode) => [
    for (final n in mode.sizes)
      for (var k = 1; k <= mode.perSize; k++) stars(LevelRef(mode, n, k)),
  ].fold(0, (a, b) => a + b);

  int get totalStars =>
      GameMode.values.map(starsInMode).fold(0, (a, b) => a + b);

  // --- Desafio do dia ---

  int get _lastDaily => _prefs.getInt('daily_last') ?? -1000;

  bool dailyDone(int day) => _lastDaily == day;

  /// Sequência atual (zera se o jogador pulou um dia).
  int streak(int day) =>
      _lastDaily >= day - 1 ? _prefs.getInt('daily_streak') ?? 0 : 0;

  int get bestStreak => _prefs.getInt('daily_best') ?? 0;

  /// Registra o desafio do dia [day] como feito e devolve a sequência.
  /// Repetir o mesmo dia não muda nada.
  Future<int> completeDaily(int day) async {
    if (dailyDone(day)) return streak(day);
    final value = _lastDaily == day - 1 ? streak(day) + 1 : 1;
    await _prefs.setInt('daily_last', day);
    await _prefs.setInt('daily_streak', value);
    if (value > bestStreak) await _prefs.setInt('daily_best', value);
    return value;
  }

  // --- Dicas ---

  int get hints => _prefs.getInt('hints') ?? initialHints;

  Future<void> addHints(int amount) => _prefs.setInt('hints', hints + amount);

  /// Gasta uma dica; retorna `false` se não havia saldo.
  Future<bool> spendHint() async {
    if (hints <= 0) return false;
    await _prefs.setInt('hints', hints - 1);
    return true;
  }

  // --- Preferências ---

  /// Marca as casas atacadas no tabuleiro (ajuda para iniciantes).
  bool get showAttacks => _prefs.getBool('show_attacks') ?? false;

  set showAttacks(bool value) => _prefs.setBool('show_attacks', value);

  /// Idioma escolhido (`''` = o do aparelho).
  String get language => _prefs.getString('language') ?? '';

  set language(String code) => _prefs.setString('language', code);

  // --- Temas e compras ---

  BoardTheme get theme => themeById(_prefs.getString('theme') ?? '');

  set theme(BoardTheme value) => _prefs.setString('theme', value.id);

  Set<String> get _purchases =>
      (_prefs.getStringList('purchases') ?? const []).toSet();

  /// O pacote inicial também libera tudo o que ele inclui.
  bool owns(String productId) =>
      _purchases.contains(productId) ||
      (_purchases.contains(starterPackProduct) &&
          starterPackIncludes.contains(productId));

  /// Registra a compra. Retorna `true` se ela é nova (as dicas do pacote
  /// inicial só entram uma vez, mesmo restaurando a compra depois).
  Future<bool> grant(String productId) async {
    if (_purchases.contains(productId)) return false;
    await _prefs.setStringList(
      'purchases',
      {..._purchases, productId}.toList(),
    );
    if (productId == starterPackProduct) await addHints(starterPackHints);
    return true;
  }

  /// Fases da trilha já vencidas (para oferecer o pacote inicial).
  int get levelsWon => [
    for (final mode in GameMode.values)
      for (final n in mode.sizes)
        for (var k = 1; k <= mode.perSize; k++)
          if (stars(LevelRef(mode, n, k)) > 0) 1,
  ].length;

  bool get starterOfferShown => _prefs.getBool('starter_offer_shown') ?? false;

  set starterOfferShown(bool value) =>
      _prefs.setBool('starter_offer_shown', value);

  bool isThemeUnlocked(BoardTheme t) {
    final product = t.productId;
    if (product != null) return owns(product);
    return totalStars >= t.starsRequired;
  }

  bool get adsRemoved => owns(removeAdsProduct);

  // --- Anúncios ---

  /// Vitórias desde o último anúncio de tela cheia.
  int get winsSinceAd => _prefs.getInt('wins_since_ad') ?? 0;

  set winsSinceAd(int value) => _prefs.setInt('wins_since_ad', value);
}

/// Produto da Play Store que remove os anúncios.
const removeAdsProduct = 'remover_anuncios';

/// Pacote inicial: remove anúncios, libera os temas pagos e dá dicas.
const starterPackProduct = 'pacote_inicial';

/// Dicas que vêm no pacote inicial.
const starterPackHints = 20;

/// Fases vencidas até oferecer o pacote inicial (uma única vez).
const starterOfferAfterLevels = 5;

/// Produtos incluídos no pacote inicial.
final Set<String> starterPackIncludes = {
  removeAdsProduct,
  for (final t in boardThemes)
    if (t.productId != null) t.productId!,
};
