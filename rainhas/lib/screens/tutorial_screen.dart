import 'dart:async';

import 'package:flutter/material.dart';

import '../game/demos.dart';
import '../game/levels.dart';
import '../l10n/l10n.dart';
import '../services/progress.dart';
import '../widgets/board_3d.dart';
import 'help.dart';

const _tapColor = Color(0xF2FFFFFF);
const _moveColor = Color(0xDD43A047);
const _visitedColor = Color(0x66000000);

/// Tutorial animado: uma página por jogo, com um tabuleiro 3D que joga
/// sozinho. Abre pelo cartão de boas-vindas e por "Como jogar".
class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final _pages = PageController();
  int _page = 0;

  static const _modes = GameMode.values;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  static const _bigButton = ButtonStyle(
    padding: WidgetStatePropertyAll(
      EdgeInsets.symmetric(vertical: 16, horizontal: 8),
    ),
  );

  /// Fecha o tutorial; com [mode], a tela inicial abre esse jogo em seguida.
  void _finish([GameMode? mode]) {
    Progress.instance.tutorialSeen = true;
    Navigator.pop(context, mode);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final last = _page == _modes.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _finish(),
                child: Text(l.tutorialSkip),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pages,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  for (final mode in _modes) _TutorialPage(mode: mode),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _modes.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.all(4),
                    width: i == _page ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _page
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: _bigButton,
                      onPressed: () => _finish(_modes[_page]),
                      child: Text(
                        l.tutorialPlayMode,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: _bigButton,
                      onPressed: last
                          ? _finish
                          : () => _pages.nextPage(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeOut,
                            ),
                      child: Text(
                        last ? l.tutorialStart : l.tutorialNext,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => showAllHelp(context),
              child: Text(l.tutorialAllRules),
            ),
          ],
        ),
      ),
    );
  }
}

class _TutorialPage extends StatelessWidget {
  final GameMode mode;

  const _TutorialPage({required this.mode});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final (title, rule) = switch (mode) {
      GameMode.queens => (l.sectionQueens, l.tutorialQueens),
      GameMode.tour => (l.modeTourTitle, l.tutorialTour),
      GameMode.knights => (l.modeKnightsTitle, l.tutorialKnights),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(rule, textAlign: TextAlign.center, style: textTheme.titleMedium),
          Expanded(child: DemoBoard(mode: mode)),
        ],
      ),
    );
  }
}

/// Tabuleiro que repete a demonstração de um modo, com legenda.
class DemoBoard extends StatefulWidget {
  final GameMode mode;

  /// Tempo de cada quadro da demonstração.
  final Duration step;

  const DemoBoard({
    super.key,
    required this.mode,
    this.step = const Duration(milliseconds: 950),
  });

  @override
  State<DemoBoard> createState() => _DemoBoardState();
}

class _DemoBoardState extends State<DemoBoard> {
  late final List<DemoFrame> _frames = demoFor(widget.mode);
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.step, (_) {
      setState(() => _index = (_index + 1) % _frames.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _caption(AppLocalizations l, DemoCaption c) => switch (c) {
    DemoCaption.tapToPlace => l.demoTapToPlace,
    DemoCaption.conflict => l.demoConflict,
    DemoCaption.tapToRemove => l.demoTapToRemove,
    DemoCaption.solved => l.demoSolved,
    DemoCaption.knightL => l.demoKnightL,
    DemoCaption.visitAll => l.demoVisitAll,
    DemoCaption.knightsGoal => l.demoKnightsGoal,
    DemoCaption.blocked => l.demoBlocked,
  };

  @override
  Widget build(BuildContext context) {
    final f = _frames[_index];
    final caption = _caption(context.l10n, f.caption);
    final isTour = widget.mode == GameMode.tour;
    return Column(
      children: [
        Expanded(
          child: IgnorePointer(
            child: Board3D(
              n: f.n,
              pitch: widget.mode == GameMode.queens ? 1.0 : knightPitch,
              blocked: f.blocked,
              celebrate: f.solved,
              pieces: [
                for (final e in f.pieces.entries)
                  BoardPiece(
                    // No passeio é sempre o mesmo cavalo, que pula de casa.
                    isTour ? 'cavalo' : e.key,
                    e.key,
                    switch (e.value) {
                      DemoPiece.queen ||
                      DemoPiece.conflictQueen => PieceKind.queen,
                      _ => PieceKind.knight,
                    },
                    switch (e.value) {
                      DemoPiece.conflictQueen ||
                      DemoPiece.conflictKnight => PieceRole.conflict,
                      _ => PieceRole.player,
                    },
                  ),
              ],
              marks: [
                for (final p in f.visited.take(
                  f.visited.isEmpty ? 0 : f.visited.length - 1,
                ))
                  CellMark(p, MarkKind.fill, _visitedColor),
                for (final p in f.moves) CellMark(p, MarkKind.dot, _moveColor),
                if (f.tap != null) CellMark(f.tap!, MarkKind.frame, _tapColor),
              ],
              labels: {
                for (var i = 0; i < f.visited.length - 1; i++)
                  f.visited[i]: '${i + 1}',
              },
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Container(
            key: ValueKey(caption),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(f.solved ? Icons.emoji_events : Icons.touch_app, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    caption,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
