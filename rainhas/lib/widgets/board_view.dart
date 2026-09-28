import 'package:flutter/material.dart';

import '../game/board.dart';

/// Desenha uma rainha (coroa) sem depender de fontes com símbolos de xadrez.
class QueenPainter extends CustomPainter {
  final Color color;

  const QueenPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final fill = Paint()..color = color;
    final outline = Paint()
      ..color = Colors.black.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.03
      ..strokeJoin = StrokeJoin.round;

    final crown = Path()
      ..moveTo(w * 0.18, h * 0.72)
      ..lineTo(w * 0.10, h * 0.30)
      ..lineTo(w * 0.32, h * 0.52)
      ..lineTo(w * 0.50, h * 0.22)
      ..lineTo(w * 0.68, h * 0.52)
      ..lineTo(w * 0.90, h * 0.30)
      ..lineTo(w * 0.82, h * 0.72)
      ..close();
    final base = RRect.fromLTRBR(
      w * 0.16,
      h * 0.74,
      w * 0.84,
      h * 0.86,
      Radius.circular(w * 0.04),
    );

    for (final p in [crown, Path()..addRRect(base)]) {
      canvas
        ..drawPath(p, fill)
        ..drawPath(p, outline);
    }
    for (final (x, y) in [(0.10, 0.27), (0.50, 0.18), (0.90, 0.27)]) {
      final c = Offset(w * x, h * y);
      canvas
        ..drawCircle(c, w * 0.07, fill)
        ..drawCircle(c, w * 0.07, outline);
    }
  }

  @override
  bool shouldRepaint(QueenPainter old) => old.color != color;
}

class QueenIcon extends StatelessWidget {
  final double size;
  final Color color;

  const QueenIcon({super.key, this.size = 32, this.color = Colors.white});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: QueenPainter(color));
}

/// Tabuleiro interativo.
class BoardView extends StatelessWidget {
  final int n;
  final Set<Pos> fixed;
  final Set<Pos> placed;

  /// Casa destacada por uma dica.
  final Pos? highlight;
  final bool showAttacks;
  final ValueChanged<Pos>? onTap;

  const BoardView({
    super.key,
    required this.n,
    required this.fixed,
    required this.placed,
    this.highlight,
    this.showAttacks = false,
    this.onTap,
  });

  static const _light = Color(0xFFF0D9B5);
  static const _dark = Color(0xFFB58863);
  static const _attacked = Color(0x99B71C1C);
  static const _hint = Color(0xFF43A047);

  @override
  Widget build(BuildContext context) {
    final all = {...fixed, ...placed};
    final bad = conflicts(all);
    final attacked = showAttacks ? attackedCells(n, all) : const <Pos>{};

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFF5D4037),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(blurRadius: 12, color: Colors.black54)],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cell = constraints.maxWidth / n;
            return Column(
              children: [
                for (var r = 0; r < n; r++)
                  Row(
                    children: [
                      for (var c = 0; c < n; c++)
                        _cell(Pos(r, c), cell, bad, attacked),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _cell(Pos p, double size, Set<Pos> bad, Set<Pos> attacked) {
    final isFixed = fixed.contains(p);
    final hasQueen = isFixed || placed.contains(p);
    final Color queenColor;
    if (bad.contains(p)) {
      queenColor = const Color(0xFFE53935);
    } else if (isFixed) {
      queenColor = const Color(0xFF455A64);
    } else {
      queenColor = const Color(0xFFFFD54F);
    }

    return GestureDetector(
      key: ValueKey('cell_${p.row}_${p.col}'),
      onTap: isFixed || onTap == null ? null : () => onTap!(p),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: (p.row + p.col).isEven ? _light : _dark,
          border: p == highlight ? Border.all(color: _hint, width: 3) : null,
        ),
        child: hasQueen
            ? Padding(
                padding: EdgeInsets.all(size * 0.08),
                child: CustomPaint(painter: QueenPainter(queenColor)),
              )
            : attacked.contains(p)
            ? Center(
                child: Container(
                  width: size * 0.22,
                  height: size * 0.22,
                  decoration: const BoxDecoration(
                    color: _attacked,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
