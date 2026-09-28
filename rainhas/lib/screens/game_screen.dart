import 'dart:async';

import 'package:flutter/material.dart';

import '../game/board.dart';
import '../game/challenge.dart';
import '../game/solver.dart';
import '../services/ads.dart';
import '../services/progress.dart';
import '../widgets/board_3d.dart';

String formatTime(int seconds) =>
    '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

/// Tela de jogo, usada tanto no modo clássico quanto nos desafios.
class GameScreen extends StatefulWidget {
  final int n;

  /// `null` no modo clássico.
  final Challenge? challenge;

  const GameScreen.classic({super.key, required this.n}) : challenge = null;

  GameScreen.challenge({super.key, required Challenge this.challenge})
    : n = challenge.n;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _placed = <Pos>{};
  final _history = <Set<Pos>>[];
  final _boardKey = GlobalKey<Board3DState>();
  Pos? _highlight;
  int _hints = 0;
  int _seconds = 0;
  bool _won = false;
  Timer? _timer;

  int get n => widget.n;
  Set<Pos> get _fixed => widget.challenge?.fixed ?? const {};

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggle(Pos p) {
    if (_won) return;
    setState(() {
      _history.add({..._placed});
      if (!_placed.remove(p)) _placed.add(p);
      _highlight = null;
    });
    if (isSolved(n, {..._fixed, ..._placed})) _onWin();
  }

  void _undo() {
    if (_history.isEmpty || _won) return;
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
      _seconds = 0;
      _won = false;
    });
    _startTimer();
  }

  void _hint() {
    final hint = computeHint(n, _fixed, _placed);
    if (hint == null) return;
    setState(() {
      _hints++;
      _highlight = hint.pos;
    });
    final msg = switch (hint) {
      PlaceHint() => 'Tente colocar uma rainha na casa destacada.',
      RemoveHint() => 'A rainha destacada não faz parte da solução.',
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );
  }

  Future<void> _onWin() async {
    _timer?.cancel();
    setState(() => _won = true);
    final progress = Progress.instance;
    final challenge = widget.challenge;

    String title;
    final lines = <String>['Tempo: ${formatTime(_seconds)}'];
    int? stars;
    if (challenge == null) {
      final isNew = await progress.addSolution(
        n,
        toCols(n, {..._fixed, ..._placed}),
      );
      final record = await progress.submitTime(n, _seconds);
      final found = progress.foundSolutions(n).length;
      final total = allSolutions(n).length;
      title = isNew ? 'Nova solução!' : 'Resolvido!';
      if (!isNew) lines.add('Você já tinha encontrado esta solução.');
      lines.add('Soluções encontradas: $found de $total');
      if (record) lines.add('Novo recorde de tempo!');
    } else {
      stars = starsFor(_hints);
      await progress.saveStars(challenge, stars);
      title = 'Desafio concluído!';
      lines.add('Dicas usadas: $_hints');
    }

    // Deixa a comemoração em 3D aparecer antes do resultado.
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    Ads.onWin();
    if (!mounted) return;

    final hasNext = challenge != null && challenge.number < challengesPerSize;
    final action = await showDialog<String>(
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
                      i < stars
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
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
            onPressed: () => Navigator.pop(context, 'menu'),
            child: const Text('Menu'),
          ),
          if (challenge == null)
            FilledButton(
              onPressed: () => Navigator.pop(context, 'again'),
              child: const Text('Jogar de novo'),
            ),
          if (hasNext)
            FilledButton(
              onPressed: () => Navigator.pop(context, 'next'),
              child: const Text('Próximo'),
            ),
        ],
      ),
    );
    if (!mounted) return;
    switch (action) {
      case 'again':
        _restart();
      case 'next':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => GameScreen.challenge(
              challenge: generateChallenge(n, challenge!.number + 1),
            ),
          ),
        );
      default:
        Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final challenge = widget.challenge;
    final title = challenge == null
        ? 'Clássico $n×$n'
        : 'Desafio $n×$n · nº ${challenge.number}';
    final total = _fixed.length + _placed.length;
    final showAttacks = Progress.instance.showAttacks;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: showAttacks
                ? 'Esconder casas atacadas'
                : 'Mostrar casas atacadas',
            onPressed: () =>
                setState(() => Progress.instance.showAttacks = !showAttacks),
            icon: Icon(showAttacks ? Icons.visibility : Icons.visibility_off),
          ),
          IconButton(
            tooltip: 'Centralizar câmera',
            onPressed: () => _boardKey.currentState?.resetCamera(),
            icon: const Icon(Icons.threed_rotation),
          ),
          IconButton(
            tooltip: 'Recomeçar',
            onPressed: _restart,
            icon: const Icon(Icons.refresh),
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
                    children: [
                      _Stat(Icons.timer_outlined, formatTime(_seconds)),
                      _Stat(Icons.emoji_events_outlined, '$total / $n'),
                      _Stat(Icons.lightbulb_outline, '$_hints'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Arraste para girar · use dois dedos para aproximar',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Expanded(
                    child: Board3D(
                      key: _boardKey,
                      n: n,
                      fixed: _fixed,
                      placed: _placed,
                      highlight: _highlight,
                      showAttacks: showAttacks && !_won,
                      celebrate: _won,
                      onTap: _toggle,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _history.isEmpty || _won ? null : _undo,
                          icon: const Icon(Icons.undo),
                          label: const Text('Desfazer'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _won ? null : _hint,
                          icon: const Icon(Icons.lightbulb),
                          label: const Text('Dica'),
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

class _Stat extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Stat(this.icon, this.text);

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
