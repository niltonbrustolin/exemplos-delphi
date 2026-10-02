import 'package:flutter/material.dart';

import '../game/board.dart';
import '../game/knights.dart';
import '../game/levels.dart';
import '../l10n/l10n.dart';
import '../services/share.dart';
import '../widgets/board_3d.dart';
import '../widgets/game_ui.dart';
import 'help.dart';
import 'routes.dart';

const _moveColor = Color(0xDD43A047);
const _visitedColor = Color(0x66000000);
const _hintColor = Color(0xFFFFC107);
const _backColor = Color(0xFFE53935);

/// Passeio do Cavalo: passar por todas as casas livres, uma vez cada.
class TourGameScreen extends StatefulWidget {
  final LevelRef level;

  const TourGameScreen({super.key, required this.level});

  @override
  State<TourGameScreen> createState() => _TourGameScreenState();
}

class _TourGameScreenState extends State<TourGameScreen> with GameClock {
  final _boardKey = GlobalKey<Board3DState>();
  late final TourLevel _tour = generateTour(
    widget.level.n,
    widget.level.number,
    variant: widget.level.variant,
  );
  late final List<Pos> _path = [_tour.start];
  (Pos, Color)? _highlight;
  int _hints = 0;
  bool _won = false;

  int get n => _tour.n;

  List<Pos> get _moves => knightMoves(
    n,
    _path.last,
    _tour.blocked,
  ).where((p) => !_path.contains(p)).toList();

  @override
  void initState() {
    super.initState();
    startClock();
  }

  void _tap(Pos p) {
    if (_won) return;
    if (!_moves.contains(p)) {
      if (p != _path.last && !_tour.blocked.contains(p)) {
        showSnack(
          context,
          _path.contains(p) ? context.l10n.tourVisited : context.l10n.tourLMove,
        );
      }
      return;
    }
    setState(() {
      _path.add(p);
      _highlight = null;
    });
    if (_path.length == _tour.squares) {
      _onWin();
    } else if (_moves.isEmpty) {
      showSnack(context, context.l10n.tourStuck);
    }
  }

  void _undo() => setState(() {
    _path.removeLast();
    _highlight = null;
  });

  void _restart() {
    setState(() {
      _path
        ..clear()
        ..add(_tour.start);
      _highlight = null;
      _hints = 0;
      _won = false;
    });
    startClock();
  }

  Future<void> _hint() async {
    final route = completeTour(n, _tour.blocked, _path);
    // Sem solução a partir daqui: acha até onde voltar.
    var keep = _path.length;
    if (route == null) {
      keep--;
      while (keep > 1 &&
          completeTour(
                n,
                _tour.blocked,
                _path.sublist(0, keep),
                limit: 20000,
              ) ==
              null) {
        keep--;
      }
    }
    final target = route != null
        ? (route[_path.length], _hintColor)
        : (_path[keep - 1], _backColor);
    final back = _path.length - keep;
    String message() => route != null
        ? context.l10n.tourHintJump
        : context.l10n.tourHintBack(back, keep);
    // A dica atual ainda vale (o caminho não mudou): mostra de novo, grátis.
    if (_highlight == target) return showSnack(context, message());
    if (!await requestHint(context) || !mounted) return;
    setState(() {
      _hints++;
      _highlight = target;
    });
    showSnack(context, message());
  }

  Future<void> _onWin() async {
    stopClock();
    setState(() => _won = true);
    final action = await finishLevel(
      context,
      level: widget.level,
      hintsUsed: _hints,
      seconds: seconds,
      board: ShareBoard(
        n: n,
        blocked: _tour.blocked,
        pitch: knightPitch,
        pieces: [
          BoardPiece('cavalo', _path.last, PieceKind.knight, PieceRole.player),
        ],
        marks: [
          for (final p in _path.take(_path.length - 1))
            CellMark(p, MarkKind.fill, _visitedColor),
        ],
        labels: {
          for (var i = 0; i < _path.length - 1; i++) _path[i]: '${i + 1}',
        },
      ),
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
    final highlight = _highlight;
    return GameScaffold(
      title: widget.level.daily
          ? context.l10n.dailyTitle
          : context.l10n.levelTitle(widget.level.number, n),
      boardKey: _boardKey,
      onRestart: _restart,
      onHelp: () => showModeHelp(context, GameMode.tour),
      onUndo: _path.length <= 1 || _won ? null : _undo,
      onHint: _won ? null : _hint,
      stats: [
        GameStat(
          Icons.timer_outlined,
          formatTime(seconds),
          context.l10n.statTime,
        ),
        GameStat(
          Icons.route,
          '${_path.length} / ${_tour.squares}',
          context.l10n.statSquares,
        ),
        GameStat(
          Icons.lightbulb_outline,
          '$_hints',
          context.l10n.statHintsUsed,
        ),
      ],
      board: Board3D(
        key: _boardKey,
        n: n,
        blocked: _tour.blocked,
        pieces: [
          BoardPiece('cavalo', _path.last, PieceKind.knight, PieceRole.player),
        ],
        marks: [
          for (final p in _path.take(_path.length - 1))
            CellMark(p, MarkKind.fill, _visitedColor),
          if (!_won)
            for (final p in _moves)
              CellMark(
                p,
                MarkKind.dot,
                _moveColor,
                label: context.l10n.a11yCanJump,
              ),
          if (highlight != null)
            CellMark(
              highlight.$1,
              MarkKind.frame,
              highlight.$2,
              label: context.l10n.a11yHint,
            ),
        ],
        labels: {
          for (var i = 0; i < _path.length - 1; i++) _path[i]: '${i + 1}',
        },
        celebrate: _won,
        pitch: knightPitch,
        onTap: _tap,
      ),
    );
  }
}
