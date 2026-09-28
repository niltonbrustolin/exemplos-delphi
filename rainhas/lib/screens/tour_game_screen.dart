import 'package:flutter/material.dart';

import '../game/board.dart';
import '../game/knights.dart';
import '../game/levels.dart';
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
          _path.contains(p)
              ? 'Essa casa já foi visitada.'
              : 'O cavalo anda em "L": escolha uma casa verde.',
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
      showSnack(context, 'Sem saída! Desfaça algumas jogadas.');
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
    if (!await requestHint(context) || !mounted) return;
    setState(() {
      _hints++;
      _highlight = route != null
          ? (route[_path.length], _hintColor)
          : (_path[keep - 1], _backColor);
    });
    final back = _path.length - keep;
    showSnack(
      context,
      route != null
          ? 'Pule para a casa destacada.'
          : 'Este caminho não fecha. Desfaça $back jogada${back > 1 ? 's' : ''} '
                '(volte até a casa $keep).',
    );
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
    final highlight = _highlight;
    return GameScaffold(
      title: 'Fase ${widget.level.number} · $n×$n',
      boardKey: _boardKey,
      onRestart: _restart,
      onHelp: () => showModeHelp(context, GameMode.tour),
      onUndo: _path.length <= 1 || _won ? null : _undo,
      onHint: _won ? null : _hint,
      stats: [
        GameStat(Icons.timer_outlined, formatTime(seconds)),
        GameStat(Icons.route, '${_path.length} / ${_tour.squares}'),
        GameStat(Icons.lightbulb_outline, '$_hints'),
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
            for (final p in _moves) CellMark(p, MarkKind.dot, _moveColor),
          if (highlight != null)
            CellMark(highlight.$1, MarkKind.frame, highlight.$2),
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
