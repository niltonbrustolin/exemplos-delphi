import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../game/daily.dart';
import '../game/levels.dart';
import '../l10n/l10n.dart';
import '../services/ads.dart';
import '../services/progress.dart';
import '../screens/store_screen.dart';
import '../services/share.dart';
import 'board_3d.dart';

String formatTime(int seconds) =>
    '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

/// Cronômetro da partida.
mixin GameClock<T extends StatefulWidget> on State<T> {
  int seconds = 0;
  Timer? _timer;

  void startClock() {
    _timer?.cancel();
    seconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => seconds++);
    });
  }

  void stopClock() => _timer?.cancel();

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Tenta gastar uma dica do saldo. Sem saldo, oferece um vídeo que dá
/// [hintsPerVideo] dicas. Retorna `true` se a dica pode ser usada.
Future<bool> requestHint(BuildContext context) async {
  final progress = Progress.instance;
  if (await progress.spendHint()) return true;
  if (!context.mounted) return false;

  final videoReady = Ads.rewardedReady;
  final l = context.l10n;
  final watch = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.lightbulb_outline, size: 40),
      title: Text(l.noHintsTitle),
      content: Text(
        videoReady
            ? l.noHintsVideo(hintsPerVideo, hintsPerNewLevel)
            : l.noHintsNoVideo(hintsPerNewLevel),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l.notNow),
        ),
        if (videoReady)
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.play_circle_outline),
            label: Text(l.watch),
          ),
      ],
    ),
  );
  if (watch != true) return false;
  if (!await Ads.showRewarded()) return false;
  await progress.addHints(hintsPerVideo);
  return progress.spendHint();
}

/// Resultado escolhido na tela de vitória.
enum WinAction { menu, again, next }

/// Registra a vitória numa fase (estrelas e dica de prêmio) e mostra o
/// resultado.
Future<WinAction> finishLevel(
  BuildContext context, {
  required LevelRef level,
  required int hintsUsed,
  required int seconds,
  required ShareBoard board,
}) async {
  final progress = Progress.instance;
  final stars = starsFor(hintsUsed);
  final firstWin = await progress.saveStars(level, stars);
  if (firstWin) await progress.addHints(hintsPerNewLevel);

  // Desafio do dia: sequência de dias e bônus a cada 7 dias seguidos.
  int? streak;
  var bonus = false;
  if (level.daily) {
    final wasDone = progress.dailyDone(level.variant);
    streak = await progress.completeDaily(level.variant);
    bonus = !wasDone && streak % streakBonusEvery == 0;
    if (bonus) await progress.addHints(streakBonusHints);
  }

  // Deixa a comemoração em 3D aparecer antes do resultado.
  await Future<void>.delayed(const Duration(milliseconds: 1800));
  Ads.onWin();
  if (!context.mounted) return WinAction.menu;

  final l = context.l10n;
  final next = level.next;
  final nextIsNewSize = next != null && next.n != level.n;
  final action = await showResultDialog(
    context,
    title: level.daily ? l.dailyCompleteTitle : l.levelComplete,
    stars: stars,
    lines: [
      l.timeLine(formatTime(seconds)),
      l.hintsUsedLine(hintsUsed),
      if (streak != null) l.streakLine(streak),
      if (bonus) l.streakBonus(streakBonusHints),
      if (firstWin) l.hintReward(hintsPerNewLevel),
      if (nextIsNewSize) l.boardUnlocked(next.n),
      if (next == null && !level.daily) l.modeCompleted,
    ],
    canContinue: next != null,
    share: ShareCard(
      board: board,
      title: level.daily ? l.dailyTitle : l.modeTitle(level.mode),
      subtitle: level.daily
          ? '${l.modeShort(level.mode)} · ${level.n}×${level.n} · '
                '${DateFormat.yMMMd(l.localeName).format(DateTime.now())}'
          : l.levelTitle(level.number, level.n),
      stars: stars,
      seconds: seconds,
      streak: streak,
    ),
  );
  if (firstWin && context.mounted) await maybeOfferStarterPack(context);
  return action;
}

Future<WinAction> showResultDialog(
  BuildContext context, {
  required String title,
  int? stars,
  required List<String> lines,
  bool canContinue = false,
  bool canRepeat = false,
  ShareCard? share,
}) async {
  final action = await showDialog<WinAction>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(title, textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (stars != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < 3; i++)
                  Icon(
                    i < stars ? Icons.star_rounded : Icons.star_border_rounded,
                    color: Colors.amber,
                    size: 44,
                  ),
              ],
            ),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(line, textAlign: TextAlign.center),
            ),
          if (share != null)
            Padding(
              padding: const EdgeInsets.only(top: 18),
              child: _ShareButton(share),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, WinAction.menu),
          child: Text(context.l10n.menu),
        ),
        if (canRepeat)
          FilledButton(
            onPressed: () => Navigator.pop(context, WinAction.again),
            child: Text(context.l10n.playAgain),
          ),
        if (canContinue)
          FilledButton(
            onPressed: () => Navigator.pop(context, WinAction.next),
            child: Text(context.l10n.nextLevel),
          ),
      ],
    ),
  );
  return action ?? WinAction.menu;
}

/// Estrutura comum das telas de jogo.
class GameScaffold extends StatelessWidget {
  final String title;
  final List<Widget> stats;
  final Widget board;
  final GlobalKey<Board3DState> boardKey;
  final VoidCallback? onUndo;
  final VoidCallback? onHint;
  final VoidCallback onRestart;
  final VoidCallback onHelp;
  final List<Widget> extraActions;

  const GameScaffold({
    super.key,
    required this.title,
    required this.stats,
    required this.board,
    required this.boardKey,
    required this.onRestart,
    required this.onHelp,
    this.onUndo,
    this.onHint,
    this.extraActions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          ...extraActions,
          IconButton(
            tooltip: context.l10n.centerCamera,
            onPressed: () => boardKey.currentState?.resetCamera(),
            icon: const Icon(Icons.threed_rotation),
          ),
          PopupMenuButton<String>(
            onSelected: (v) => v == 'restart' ? onRestart() : onHelp(),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'restart',
                child: Text(context.l10n.restart),
              ),
              PopupMenuItem(value: 'help', child: Text(context.l10n.howToPlay)),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const BannerAdBox(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: stats,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.dragHint,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Expanded(child: board),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onUndo,
                          icon: const Icon(Icons.undo),
                          label: Text(context.l10n.undo),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: onHint,
                          icon: const Icon(Icons.lightbulb),
                          label: Text(
                            context.l10n.hintButton(Progress.instance.hints),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GameStat extends StatelessWidget {
  final IconData icon;
  final String text;

  const GameStat(this.icon, this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22),
        const SizedBox(width: 6),
        Text(text, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
}

/// Botão que gera a imagem do resultado e abre o compartilhamento.
class _ShareButton extends StatefulWidget {
  final ShareCard card;

  const _ShareButton(this.card);

  @override
  State<_ShareButton> createState() => _ShareButtonState();
}

class _ShareButtonState extends State<_ShareButton> {
  bool _busy = false;

  Future<void> _share() async {
    setState(() => _busy = true);
    try {
      await shareResult(context, widget.card);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _busy ? null : _share,
      icon: _busy
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.share),
      label: Text(context.l10n.shareButton),
    );
  }
}
