import 'package:flutter/material.dart';

import '../game/levels.dart';
import '../l10n/l10n.dart';
import '../services/ads.dart';
import '../services/progress.dart';
import 'help.dart';
import 'routes.dart';

/// Lista de fases de um modo, em trilha única.
class LevelSelectScreen extends StatefulWidget {
  final GameMode mode;

  const LevelSelectScreen({super.key, required this.mode});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  Future<void> _play(LevelRef level) async {
    await openLevel(context, level);
    if (mounted) setState(() {}); // atualiza estrelas e desbloqueios
  }

  @override
  Widget build(BuildContext context) {
    final mode = widget.mode;
    final progress = Progress.instance;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.modeTitle(mode)),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber),
                  Text(
                    ' ${progress.starsInMode(mode)}/${mode.totalLevels * 3}',
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: context.l10n.howToPlay,
            onPressed: () => showModeHelp(context, mode),
            icon: const Icon(Icons.help_outline),
          ),
        ],
      ),
      bottomNavigationBar: const BannerAdBox(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final n in mode.sizes) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
              child: Row(
                children: [
                  Text(
                    context.l10n.boardSize(n),
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(width: 12),
                  if (!progress.isUnlocked(LevelRef(mode, n, 1)))
                    Expanded(
                      child: Text(
                        context.l10n.beatPreviousBoard,
                        textAlign: TextAlign.end,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                ],
              ),
            ),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (var k = 1; k <= mode.perSize; k++)
                  _LevelButton(
                    number: k,
                    stars: progress.stars(LevelRef(mode, n, k)),
                    unlocked: progress.isUnlocked(LevelRef(mode, n, k)),
                    onTap: () => _play(LevelRef(mode, n, k)),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
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
