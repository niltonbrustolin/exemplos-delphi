import 'package:flutter_test/flutter_test.dart';
import 'package:rainhas/game/levels.dart';
import 'package:rainhas/render3d/themes.dart';
import 'package:rainhas/services/progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await Progress.load();
  });

  test('trilha única: só a primeira fase começa liberada', () async {
    final p = Progress.instance;
    const first = LevelRef(GameMode.queens, 5, 1);
    expect(p.isUnlocked(first), isTrue);
    expect(p.isUnlocked(const LevelRef(GameMode.queens, 5, 2)), isFalse);
    expect(p.isUnlocked(const LevelRef(GameMode.queens, 6, 1)), isFalse);

    await p.saveStars(first, 2);
    expect(p.isUnlocked(const LevelRef(GameMode.queens, 5, 2)), isTrue);

    // O tabuleiro seguinte só abre depois da última fase do anterior.
    for (var k = 1; k <= GameMode.queens.perSize; k++) {
      await p.saveStars(LevelRef(GameMode.queens, 5, k), 3);
    }
    expect(p.isUnlocked(const LevelRef(GameMode.queens, 6, 1)), isTrue);
    expect(p.isUnlocked(const LevelRef(GameMode.queens, 7, 1)), isFalse);
  });

  test('saveStars avisa só a primeira vitória e guarda o melhor', () async {
    final p = Progress.instance;
    const level = LevelRef(GameMode.tour, 5, 1);
    expect(await p.saveStars(level, 1), isTrue);
    expect(await p.saveStars(level, 3), isFalse);
    expect(await p.saveStars(level, 2), isFalse);
    expect(p.stars(level), 3);
  });

  test('saldo de dicas', () async {
    final p = Progress.instance;
    expect(p.hints, initialHints);
    for (var i = 0; i < initialHints; i++) {
      expect(await p.spendHint(), isTrue);
    }
    expect(await p.spendHint(), isFalse);
    await p.addHints(hintsPerVideo);
    expect(p.hints, hintsPerVideo);
  });

  test('temas: pagos exigem compra, grátis exigem estrelas', () async {
    final p = Progress.instance;
    final marmore = themeById('marmore');
    final torneio = themeById('torneio');
    expect(p.isThemeUnlocked(boardThemes.first), isTrue);
    expect(p.isThemeUnlocked(marmore), isFalse);
    expect(p.isThemeUnlocked(torneio), isFalse);
    await p.grant(marmore.productId!);
    expect(p.isThemeUnlocked(marmore), isTrue);
    expect(p.adsRemoved, isFalse);
    await p.grant(removeAdsProduct);
    expect(p.adsRemoved, isTrue);
  });

  test('pacote inicial: libera tudo e dá as dicas uma só vez', () async {
    final p = Progress.instance;
    final hints = p.hints;
    expect(await p.grant(starterPackProduct), isTrue);
    expect(p.adsRemoved, isTrue);
    expect(p.isThemeUnlocked(themeById('marmore')), isTrue);
    expect(p.isThemeUnlocked(themeById('neon')), isTrue);
    expect(p.hints, hints + starterPackHints);
    // Restaurar a compra não dá as dicas de novo.
    expect(await p.grant(starterPackProduct), isFalse);
    expect(p.hints, hints + starterPackHints);
  });

  test('conta as fases vencidas', () async {
    final p = Progress.instance;
    expect(p.levelsWon, 0);
    await p.saveStars(const LevelRef(GameMode.tour, 5, 1), 3);
    await p.saveStars(const LevelRef(GameMode.queens, 5, 1), 1);
    expect(p.levelsWon, 2);
  });
}
