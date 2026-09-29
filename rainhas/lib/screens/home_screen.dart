import 'package:flutter/material.dart';

import '../config/app_info.dart';
import '../game/daily.dart';
import '../game/levels.dart';
import '../l10n/l10n.dart';
import '../services/progress.dart';
import '../widgets/board_3d.dart';
import 'about_screen.dart';
import 'classic_select_screen.dart';
import 'level_select_screen.dart';
import 'routes.dart';
import 'store_screen.dart';
import 'tutorial_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Na primeira abertura, mostra o tutorial animado.
    if (!Progress.instance.tutorialSeen) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _go(const TutorialScreen()),
      );
    }
  }

  Future<void> _go(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    if (mounted) setState(() {}); // atualiza dicas e estrelas
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = Progress.instance;
    final l = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Chip(
                      avatar: const Icon(Icons.lightbulb, size: 18),
                      label: Text('${progress.hints}'),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      avatar: const Icon(
                        Icons.star_rounded,
                        size: 18,
                        color: Colors.amber,
                      ),
                      label: Text('${progress.totalStars}'),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SpinningPiece(size: 120, color: progress.theme.player),
                    SpinningPiece(
                      size: 120,
                      color: progress.theme.player,
                      kind: PieceKind.knight,
                    ),
                  ],
                ),
                Text(
                  AppInfo.appName,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  l.appSubtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 20),
                _DailyCard(
                  onPlay: () async {
                    await openLevel(context, dailyLevel(today));
                    if (mounted) setState(() {});
                  },
                ),
                _Section(l.sectionQueens),
                _MenuButton(
                  icon: Icons.grid_on,
                  label: l.classicMode,
                  onPressed: () => _go(const ClassicSelectScreen()),
                ),
                _MenuButton(
                  icon: Icons.extension,
                  label: l.challenges,
                  onPressed: () =>
                      _go(const LevelSelectScreen(mode: GameMode.queens)),
                ),
                _Section(l.sectionKnight),
                _MenuButton(
                  icon: Icons.route,
                  label: l.modeTourTitle,
                  onPressed: () =>
                      _go(const LevelSelectScreen(mode: GameMode.tour)),
                ),
                _MenuButton(
                  icon: Icons.shield_outlined,
                  label: l.modeKnightsTitle,
                  onPressed: () =>
                      _go(const LevelSelectScreen(mode: GameMode.knights)),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _IconAction(
                      icon: Icons.storefront,
                      label: l.store,
                      onTap: () => _go(const StoreScreen()),
                    ),
                    _IconAction(
                      icon: Icons.help_outline,
                      label: l.howToPlay,
                      onTap: () => _go(const TutorialScreen()),
                    ),
                    _IconAction(
                      icon: Icons.info_outline,
                      label: l.about,
                      onTap: () => _go(const AboutScreen()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String text;

  const _Section(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 8, left: 4),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall),
  );
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: FilledButton(
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(vertical: 16),
          ),
          textStyle: WidgetStatePropertyAll(
            Theme.of(context).textTheme.titleMedium,
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Flexible(child: Text(label, textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _IconAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Icon(icon, size: 30),
              const SizedBox(height: 4),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cartão do desafio do dia, com a sequência de dias.
class _DailyCard extends StatelessWidget {
  final VoidCallback onPlay;

  const _DailyCard({required this.onPlay});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final progress = Progress.instance;
    final day = today;
    final level = dailyLevel(day);
    final done = progress.dailyDone(day);
    final streak = progress.streak(day);
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.tertiaryContainer,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPlay,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                streak > 0 ? Icons.local_fire_department : Icons.event,
                size: 38,
                color: streak > 0 ? Colors.deepOrangeAccent : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.dailyTitle,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text('${l.modeShort(level.mode)} · ${level.n}×${level.n}'),
                    Text(
                      progress.bestStreak > 0
                          ? '${l.streakDays(streak)} · ${l.bestStreak(progress.bestStreak)}'
                          : l.streakDays(streak),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              done
                  ? Column(
                      children: [
                        const Icon(Icons.check_circle, size: 30),
                        SizedBox(
                          width: 90,
                          child: Text(
                            l.dailyDone,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    )
                  : FilledButton(onPressed: onPlay, child: Text(l.dailyPlay)),
            ],
          ),
        ),
      ),
    );
  }
}
