import 'package:flutter_test/flutter_test.dart';
import 'package:rainhas/game/challenge.dart';
import 'package:rainhas/game/daily.dart';
import 'package:rainhas/game/knights.dart';
import 'package:rainhas/game/levels.dart';
import 'package:rainhas/game/solver.dart';
import 'package:rainhas/services/progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('número do dia muda à meia-noite local', () {
    final a = dayNumber(DateTime(2026, 9, 29, 0, 1));
    final b = dayNumber(DateTime(2026, 9, 29, 23, 59));
    final c = dayNumber(DateTime(2026, 9, 30, 0, 1));
    expect(a, b);
    expect(c, a + 1);
  });

  test('desafio do dia alterna os modos e fica fora da trilha', () {
    final day = dayNumber(DateTime(2026, 9, 29));
    final modes = {for (var d = day; d < day + 3; d++) dailyLevel(d).mode};
    expect(modes, GameMode.values.toSet());
    expect(dailyLevel(day).daily, isTrue);
    expect(dailyLevel(day).next, isNull);
    expect(dailyLevel(day).key, 'daily_$day');
  });

  test('30 dias seguidos de desafios com solução', () {
    final start = dayNumber(DateTime(2026, 9, 29));
    for (var day = start; day < start + 30; day++) {
      final level = dailyLevel(day);
      switch (level.mode) {
        case GameMode.queens:
          final c = generateChallenge(8, level.number, variant: day);
          final fixed = {for (final p in c.fixed) p.row: p.col};
          expect(solutionsMatching(8, fixed).length, 1, reason: '$day');
        case GameMode.tour:
          final t = generateTour(level.n, level.number, variant: day);
          expect(
            completeTour(level.n, t.blocked, [t.start]),
            isNotNull,
            reason: '$day',
          );
        case GameMode.knights:
          final k = generateKnights(level.n, level.number, variant: day);
          expect(k.target, greaterThan(0), reason: '$day');
      }
    }
  });

  test('dias diferentes geram desafios diferentes', () {
    final a = generateChallenge(8, 10, variant: 100);
    final b = generateChallenge(8, 10, variant: 103);
    expect(a.solution, isNot(b.solution));
  });

  group('sequência de dias', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await Progress.load();
    });

    test('cresce em dias seguidos e zera ao pular um dia', () async {
      final p = Progress.instance;
      expect(p.streak(100), 0);
      expect(await p.completeDaily(100), 1);
      expect(await p.completeDaily(100), 1); // repetir o dia não conta
      expect(await p.completeDaily(101), 2);
      expect(p.streak(102), 2); // ainda dá tempo hoje
      expect(p.streak(103), 0); // pulou o dia 102
      expect(await p.completeDaily(103), 1);
      expect(p.bestStreak, 2);
    });
  });
}
