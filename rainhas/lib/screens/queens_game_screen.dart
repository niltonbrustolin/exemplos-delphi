import 'package:flutter/material.dart';

import '../game/board.dart';
import '../game/challenge.dart';
import '../game/levels.dart';
import '../l10n/l10n.dart';
import '../game/solver.dart';
import '../services/ads.dart';
import '../services/progress.dart';
import '../services/share.dart';
import '../widgets/board_3d.dart';
import '../widgets/game_ui.dart';
import 'help.dart';
import 'routes.dart';

const _hintColor = Color(0xFF43A047);
const _attackColor = Color(0xAAB71C1C);

/// Rainhas: modo clássico (tabuleiro livre) ou desafio (fase da trilha).
class QueensGameScreen extends StatefulWidget {
  final int n;

  /// `null` no modo clássico.
  final LevelRef? level;

  const QueensGameScreen.classic({super.key, required this.n}) : level = null;

  QueensGameScreen.challenge({super.key, required LevelRef this.level})
    : n = level.n;

  @override
  State<QueensGameScreen> createState() => _QueensGameScreenState();
}

class _QueensGameScreenState extends State<QueensGameScreen> with GameClock {
  final _placed = <Pos>{};
  final _history = <Set<Pos>>[];
  final _boardKey = GlobalKey<Board3DState>();
  Pos? _highlight;
  int _hints = 0;
  bool _won = false;

  int get n => widget.n;
  late final Challenge? _challenge = widget.level == null
      ? null
      : generateChallenge(
          n,
          widget.level!.number,
          variant: widget.level!.variant,
        );
  Set<Pos> get _fixed => _challenge?.fixed ?? const {};

  @override
  void initState() {
    super.initState();
    startClock();
  }

  void _toggle(Pos p) {
    if (_won || _fixed.contains(p)) return;
    setState(() {
      _history.add({..._placed});
      if (!_placed.remove(p)) _placed.add(p);
      _highlight = null;
    });
    if (isSolved(n, {..._fixed, ..._placed})) _onWin();
  }

  void _undo() {
    setState(() {
      _placed
        ..clear()
        ..addAll(_history.removeLast());
      _highlight = null;
    });
  }

  void _restart() {
    setState(() {
      _placed.clear();
      _history.clear();
      _highlight = null;
      _hints = 0;
      _won = false;
    });
    startClock();
  }

  Future<void> _hint() async {
    final hint = computeHint(n, _fixed, _placed);
    if (hint == null || !await requestHint(context) || !mounted) return;
    setState(() {
      _hints++;
      _highlight = hint.pos;
    });
    showSnack(context, switch (hint) {
      PlaceHint() => context.l10n.hintPlaceQueen,
      RemoveHint() => context.l10n.hintRemoveQueen,
    });
  }

  Future<void> _onWin() async {
    stopClock();
    setState(() => _won = true);
    final level = widget.level;
    final action = level != null
        ? await finishLevel(
            context,
            level: level,
            hintsUsed: _hints,
            seconds: seconds,
            board: _shareBoard,
          )
        : await _finishClassic();
    if (!mounted) return;
    switch (action) {
      case WinAction.again:
        _restart();
      case WinAction.next:
        openLevel(context, level!.next!, replace: true);
      case WinAction.menu:
        Navigator.pop(context);
    }
  }

  List<BoardPiece> get _pieces {
    final all = {..._fixed, ..._placed};
    final bad = conflicts(all);
    return [
      for (final q in all)
        BoardPiece(
          q,
          q,
          PieceKind.queen,
          bad.contains(q)
              ? PieceRole.conflict
              : (_fixed.contains(q) ? PieceRole.fixed : PieceRole.player),
        ),
    ];
  }

  ShareBoard get _shareBoard => ShareBoard(n: n, pieces: _pieces);

  Future<WinAction> _finishClassic() async {
    final progress = Progress.instance;
    final isNew = await progress.addSolution(
      n,
      toCols(n, {..._fixed, ..._placed}),
    );
    final record = await progress.submitTime(n, seconds);
    if (isNew) await progress.addHints(hintsPerNewLevel);
    final found = progress.foundSolutions(n).length;
    final total = allSolutions(n).length;

    await Future<void>.delayed(const Duration(milliseconds: 1800));
    Ads.onWin();
    if (!mounted) return WinAction.menu;
    final l = context.l10n;
    return showResultDialog(
      context,
      title: isNew ? l.newSolution : l.solved,
      lines: [
        l.timeLine(formatTime(seconds)),
        if (!isNew) l.alreadyFound,
        l.solutionsFoundLine(found, total),
        if (isNew) l.hintReward(hintsPerNewLevel),
        if (record) l.newRecord,
      ],
      canRepeat: true,
      share: ShareCard(
        board: _shareBoard,
        title: l.classicMode,
        subtitle: '$n×$n · ${l.solutionsProgress(found, total)}',
        seconds: seconds,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final level = widget.level;
    final all = {..._fixed, ..._placed};
    final bad = conflicts(all);
    final showAttacks = Progress.instance.showAttacks && !_won;

    return GameScaffold(
      title: level == null
          ? context.l10n.classicTitle(n)
          : level.daily
          ? context.l10n.dailyTitle
          : context.l10n.levelTitle(level.number, n),
      boardKey: _boardKey,
      onRestart: _restart,
      onHelp: () => level == null
          ? showClassicHelp(context)
          : showModeHelp(context, GameMode.queens),
      onUndo: _history.isEmpty || _won ? null : _undo,
      onHint: _won ? null : _hint,
      extraActions: [
        IconButton(
          tooltip: showAttacks
              ? context.l10n.hideAttacks
              : context.l10n.showAttacks,
          onPressed: () => setState(
            () =>
                Progress.instance.showAttacks = !Progress.instance.showAttacks,
          ),
          icon: Icon(
            Progress.instance.showAttacks
                ? Icons.visibility
                : Icons.visibility_off,
          ),
        ),
      ],
      stats: [
        GameStat(Icons.timer_outlined, formatTime(seconds)),
        GameStat(Icons.emoji_events_outlined, '${all.length} / $n'),
        GameStat(Icons.lightbulb_outline, '$_hints'),
      ],
      board: Board3D(
        key: _boardKey,
        n: n,
        pieces: [
          for (final q in all)
            BoardPiece(
              q,
              q,
              PieceKind.queen,
              bad.contains(q)
                  ? PieceRole.conflict
                  : (_fixed.contains(q) ? PieceRole.fixed : PieceRole.player),
            ),
        ],
        marks: [
          if (showAttacks)
            for (final p in attackedCells(n, all))
              CellMark(
                p,
                MarkKind.dot,
                _attackColor,
                label: context.l10n.a11yAttacked,
              ),
          if (_highlight != null)
            CellMark(
              _highlight!,
              MarkKind.frame,
              _hintColor,
              label: context.l10n.a11yHint,
            ),
        ],
        celebrate: _won,
        onTap: _toggle,
      ),
    );
  }
}
