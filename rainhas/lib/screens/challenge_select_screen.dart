import 'package:flutter/material.dart';

import '../game/challenge.dart';
import '../services/ads.dart';
import '../services/progress.dart';
import 'game_screen.dart';

class ChallengeSelectScreen extends StatefulWidget {
  const ChallengeSelectScreen({super.key});

  @override
  State<ChallengeSelectScreen> createState() => _ChallengeSelectScreenState();
}

class _ChallengeSelectScreenState extends State<ChallengeSelectScreen> {
  Future<void> _play(int n, int number) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            GameScreen.challenge(challenge: generateChallenge(n, number)),
      ),
    );
    setState(() {}); // atualiza estrelas e desbloqueios
  }

  @override
  Widget build(BuildContext context) {
    final progress = Progress.instance;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Desafios')),
      bottomNavigationBar: const BannerAdBox(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final n in challengeSizes) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
              child: Row(
                children: [
                  Text('Tabuleiro $n×$n', style: theme.textTheme.titleLarge),
                  const Spacer(),
                  const Icon(Icons.star_rounded, color: Colors.amber),
                  Text(
                    ' ${_totalStars(progress, n)} / ${3 * challengesPerSize}',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (var k = 1; k <= challengesPerSize; k++)
                  _LevelButton(
                    number: k,
                    stars: progress.stars(generateChallenge(n, k)),
                    unlocked: progress.isUnlocked(n, k),
                    onTap: () => _play(n, k),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  int _totalStars(Progress progress, int n) => [
    for (var k = 1; k <= challengesPerSize; k++)
      progress.stars(generateChallenge(n, k)),
  ].fold(0, (a, b) => a + b);
}

class _LevelButton extends StatelessWidget {
  final int number;
  final int stars;
  final bool unlocked;
  final VoidCallback onTap;

  const _LevelButton({
    required this.number,
    required this.stars,
    required this.unlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 64,
      height: 72,
      child: Material(
        color: unlocked
            ? scheme.primaryContainer
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: unlocked ? onTap : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              unlocked
                  ? Text(
                      '$number',
                      style: Theme.of(context).textTheme.titleLarge,
                    )
                  : const Icon(Icons.lock_outline),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < 3; i++)
                    Icon(
                      i < stars
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      size: 16,
                      color: Colors.amber,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
