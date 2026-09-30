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
  Future<void> _go(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    if (mounted) setState(() {}); // atualiza dicas e estrelas
  }

  Widget _modeScreen(GameMode mode) => switch (mode) {
    GameMode.queens => const ClassicSelectScreen(),
    _ => LevelSelectScreen(mode: mode),
  };

  /// Abre o tutorial; se o jogador tocar em "Jogar este modo", vai direto.
  Future<void> _tutorial() async {
    final mode = await Navigator.push<GameMode>(
      context,
      MaterialPageRoute(builder: (_) => const TutorialScreen()),
    );
    if (!mounted) return;
    setState(() {});
    if (mode != null) await _go(_modeScreen(mode));
  }

  void _dismissWelcome() {
    Progress.instance.tutorialSeen = true;
    setState(() {});
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
                  children: [
                    const LanguageButton(),
                    const Spacer(),
                    Semantics(
                      container: true,
                      label: l.a11yHints(progress.hints),
                      excludeSemantics: true,
                      child: Chip(
                        avatar: const Icon(Icons.lightbulb, size: 18),
                        label: Text('${progress.hints}'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Semantics(
                      container: true,
                      label: l.a11yStars(progress.totalStars),
                      excludeSemantics: true,
                      child: Chip(
                        avatar: const Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: Colors.amber,
                        ),
                        label: Text('${progress.totalStars}'),
                      ),
                    ),
                  ],
                ),
                ExcludeSemantics(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SpinningPiece(size: 100, color: progress.theme.player),
                      SpinningPiece(
                        size: 100,
                        color: progress.theme.player,
                        kind: PieceKind.knight,
                      ),
                    ],
                  ),
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
                if (!progress.tutorialSeen)
                  _WelcomeCard(onHowTo: _tutorial, onDismiss: _dismissWelcome),
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
                  description: l.classicDesc,
                  onPressed: () => _go(const ClassicSelectScreen()),
                ),
                _MenuButton(
                  icon: Icons.extension,
                  label: l.challenges,
                  description: l.challengesDesc,
                  onPressed: () =>
                      _go(const LevelSelectScreen(mode: GameMode.queens)),
                ),
                _Section(l.sectionKnight),
                _MenuButton(
                  icon: Icons.route,
                  label: l.modeTourTitle,
                  description: l.tutorialTour,
                  onPressed: () =>
                      _go(const LevelSelectScreen(mode: GameMode.tour)),
                ),
                _MenuButton(
                  icon: Icons.shield_outlined,
                  label: l.modeKnightsTitle,
                  description: l.tutorialKnights,
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
                      onTap: _tutorial,
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
  final String description;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.description,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: FilledButton(
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(vertical: 12, horizontal: 18),
          ),
          textStyle: WidgetStatePropertyAll(
            Theme.of(context).textTheme.titleMedium,
          ),
        ),
        onPressed: onPressed,
        child: Row(
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.play_arrow_rounded),
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

/// Cartão de boas-vindas da primeira visita: diz o que é o jogo e deixa
/// o jogador escolher entre começar já ou ver o tutorial.
class _WelcomeCard extends StatelessWidget {
  final VoidCallback onHowTo;
  final VoidCallback onDismiss;

  const _WelcomeCard({required this.onHowTo, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.welcomeTitle,
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(l.welcomeBody),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              children: [
                TextButton(onPressed: onDismiss, child: Text(l.welcomeDismiss)),
                FilledButton.tonalIcon(
                  onPressed: onHowTo,
                  icon: const Icon(Icons.play_circle_outline),
                  label: Text(l.welcomeHowTo),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Botão de idioma sempre visível na tela inicial.
class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final current = Localizations.localeOf(context).languageCode;
    return PopupMenuButton<String>(
      tooltip: l.language,
      initialValue: appLanguage.value,
      onSelected: (code) {
        appLanguage.value = code;
        Progress.instance.language = code;
      },
      itemBuilder: (_) => [
        PopupMenuItem(value: '', child: Text(l.languageSystem)),
        for (final e in languageNames.entries)
          PopupMenuItem(value: e.key, child: Text(e.value)),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.translate, size: 20),
            const SizedBox(width: 6),
            Text(current.toUpperCase()),
            const Icon(Icons.arrow_drop_down),
          ],
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
