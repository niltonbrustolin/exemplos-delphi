import 'package:flutter/material.dart';

import '../game/board.dart';
import '../game/challenge.dart';
import '../game/levels.dart';
import '../game/solver.dart';
import '../services/ads.dart';
import '../services/progress.dart';
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
      : generateChallenge(n, widget.level!.number);
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
      PlaceHint() => 'Tente colocar uma rainha na casa destacada.',
      RemoveHint() => 'A rainha destacada não faz parte da solução.',
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
    return showResultDialog(
      context,
      title: isNew ? 'Nova solução!' : 'Resolvido!',
      lines: [
        'Tempo: ${formatTime(seconds)}',
        if (!isNew) 'Você já tinha encontrado esta solução.',
        'Soluções encontradas: $found de $total',
        if (isNew) '+$hintsPerNewLevel dica de prêmio!',
        if (record) 'Novo recorde de tempo!',
      ],
      canRepeat: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final level = widget.level;
    final all = {..._fixed, ..._placed};
    final bad = conflicts(all);
    final showAttacks = Progress.instance.showAttacks && !_won;

    return GameScaffold(
      title: level == null ? 'Clássico $n×$n' : 'Fase ${level.number} · $n×$n',
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
              ? 'Esconder casas atacadas'
              : 'Mostrar casas atacadas',
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
              CellMark(p, MarkKind.dot, _attackColor),
          if (_highlight != null)
            CellMark(_highlight!, MarkKind.frame, _hintColor),
        ],
        celebrate: _won,
        onTap: _toggle,
      ),
    );
  }
}
