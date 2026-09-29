import 'package:flutter/material.dart';

import '../game/board.dart';
import '../game/knights.dart';
import '../game/levels.dart';
import '../l10n/l10n.dart';
import '../services/progress.dart';
import '../widgets/board_3d.dart';
import '../widgets/game_ui.dart';
import 'help.dart';
import 'routes.dart';

const _hintColor = Color(0xFF43A047);
const _attackColor = Color(0xAAB71C1C);

/// Cavalos sem Ataque: colocar o máximo de cavalos sem que se ataquem.
class KnightsGameScreen extends StatefulWidget {
  final LevelRef level;

  const KnightsGameScreen({super.key, required this.level});

  @override
  State<KnightsGameScreen> createState() => _KnightsGameScreenState();
}

class _KnightsGameScreenState extends State<KnightsGameScreen> with GameClock {
  final _placed = <Pos>{};
  final _history = <Set<Pos>>[];
  final _boardKey = GlobalKey<Board3DState>();
  late final KnightsLevel _level = generateKnights(
    widget.level.n,
    widget.level.number,
    variant: widget.level.variant,
  );
  Pos? _highlight;
  int _hints = 0;
  bool _won = false;

  int get n => _level.n;

  Set<Pos> get _conflicts => {
    for (final a in _placed)
      for (final b in _placed)
        if (knightAttacks(a, b)) a,
  };

  @override
  void initState() {
    super.initState();
    startClock();
  }

  void _toggle(Pos p) {
    if (_won || _level.blocked.contains(p)) return;
    setState(() {
      _history.add({..._placed});
      if (!_placed.remove(p)) _placed.add(p);
      _highlight = null;
    });
    if (_placed.length == _level.target && _conflicts.isEmpty) _onWin();
  }

  void _undo() => setState(() {
    _placed
      ..clear()
      ..addAll(_history.removeLast());
    _highlight = null;
  });

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
    final hint = knightsHint(_level, _placed);
    if (hint == null || !await requestHint(context) || !mounted) return;
    setState(() {
      _hints++;
      _highlight = hint.pos;
    });
    showSnack(context, switch (hint) {
      PlaceHint() => context.l10n.hintPlaceKnight,
      RemoveHint() => context.l10n.hintRemoveKnight,
    });
  }

  Future<void> _onWin() async {
    stopClock();
    setState(() => _won = true);
    final action = await finishLevel(
      context,
      level: widget.level,
      hintsUsed: _hints,
      seconds: seconds,
    );
    if (!mounted) return;
    switch (action) {
      case WinAction.next:
        openLevel(context, widget.level.next!, replace: true);
      case WinAction.again:
        _restart();
      case WinAction.menu:
        Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bad = _conflicts;
    final showAttacks = Progress.instance.showAttacks && !_won;
    return GameScaffold(
      title: widget.level.daily
          ? context.l10n.dailyTitle
          : context.l10n.levelTitle(widget.level.number, n),
      boardKey: _boardKey,
      onRestart: _restart,
      onHelp: () => showModeHelp(context, GameMode.knights),
      onUndo: _history.isEmpty || _won ? null : _undo,
      onHint: _won ? null : _hint,
      extraActions: [
        IconButton(
          tooltip: Progress.instance.showAttacks
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
        GameStat(
          Icons.emoji_events_outlined,
          '${_placed.length} / ${_level.target}',
        ),
        GameStat(Icons.lightbulb_outline, '$_hints'),
      ],
      board: Board3D(
        key: _boardKey,
        n: n,
        blocked: _level.blocked,
        pieces: [
          for (final p in _placed)
            BoardPiece(
              p,
              p,
              PieceKind.knight,
              bad.contains(p) ? PieceRole.conflict : PieceRole.player,
            ),
        ],
        marks: [
          if (showAttacks)
            for (final k in _placed)
              for (final q in knightMoves(n, k, _level.blocked))
                if (!_placed.contains(q))
                  CellMark(q, MarkKind.dot, _attackColor),
          if (_highlight != null)
            CellMark(_highlight!, MarkKind.frame, _hintColor),
        ],
        celebrate: _won,
        pitch: knightPitch,
        onTap: _toggle,
      ),
    );
  }
}
