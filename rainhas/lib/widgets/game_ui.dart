import 'dart:async';

import 'package:flutter/material.dart';

import '../game/levels.dart';
import '../services/ads.dart';
import '../services/progress.dart';
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
  final watch = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.lightbulb_outline, size: 40),
      title: const Text('Sem dicas'),
      content: Text(
        videoReady
            ? 'Assista a um vídeo curto e ganhe $hintsPerVideo dicas.\n\n'
                  'Você também ganha $hintsPerNewLevel dica a cada fase nova '
                  'que vencer.'
            : 'Nenhum vídeo disponível agora. Você ganha $hintsPerNewLevel '
                  'dica a cada fase nova que vencer.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Agora não'),
        ),
        if (videoReady)
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.play_circle_outline),
            label: const Text('Assistir'),
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
}) async {
  final progress = Progress.instance;
  final stars = starsFor(hintsUsed);
  final firstWin = await progress.saveStars(level, stars);
  if (firstWin) await progress.addHints(hintsPerNewLevel);

  // Deixa a comemoração em 3D aparecer antes do resultado.
  await Future<void>.delayed(const Duration(milliseconds: 1800));
  Ads.onWin();
  if (!context.mounted) return WinAction.menu;

  final next = level.next;
  final nextIsNewSize = next != null && next.n != level.n;
  return await showResultDialog(
    context,
    title: 'Fase concluída!',
    stars: stars,
    lines: [
      'Tempo: ${formatTime(seconds)}',
      'Dicas usadas: $hintsUsed',
      if (firstWin) '+$hintsPerNewLevel dica de prêmio!',
      if (nextIsNewSize) 'Tabuleiro ${next.n}×${next.n} liberado!',
      if (next == null) 'Você completou todas as fases deste modo!',
    ],
    canContinue: next != null,
  );
}

Future<WinAction> showResultDialog(
  BuildContext context, {
  required String title,
  int? stars,
  required List<String> lines,
  bool canContinue = false,
  bool canRepeat = false,
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
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, WinAction.menu),
          child: const Text('Menu'),
        ),
        if (canRepeat)
          FilledButton(
            onPressed: () => Navigator.pop(context, WinAction.again),
            child: const Text('Jogar de novo'),
          ),
        if (canContinue)
          FilledButton(
            onPressed: () => Navigator.pop(context, WinAction.next),
            child: const Text('Próxima'),
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
            tooltip: 'Centralizar câmera',
            onPressed: () => boardKey.currentState?.resetCamera(),
            icon: const Icon(Icons.threed_rotation),
          ),
          PopupMenuButton<String>(
            onSelected: (v) => v == 'restart' ? onRestart() : onHelp(),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'restart', child: Text('Recomeçar')),
              PopupMenuItem(value: 'help', child: Text('Como jogar')),
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
                    'Arraste para girar · use dois dedos para aproximar',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Expanded(child: board),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onUndo,
                          icon: const Icon(Icons.undo),
                          label: const Text('Desfazer'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: onHint,
                          icon: const Icon(Icons.lightbulb),
                          label: Text('Dica (${Progress.instance.hints})'),
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
