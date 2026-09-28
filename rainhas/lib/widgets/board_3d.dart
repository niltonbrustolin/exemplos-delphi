import 'dart:math';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../game/board.dart';
import '../render3d/math3d.dart';
import '../render3d/meshes.dart';
import '../render3d/renderer.dart';

const _frameColor = Color(0xFF4E342E);
const _lightCell = Color(0xFFE9D3AE);
const _darkCell = Color(0xFF9C6B45);
const _playerQueen = Color(0xFFF3E6CC);
const _fixedQueen = Color(0xFF363B47);
const _conflictQueen = Color(0xFFE53935);
const _hintColor = Color(0xFF43A047);
const _attackColor = Color(0xAAB71C1C);
const _shadowColor = Color(0x59000000);

const _queenScale = 0.9;
const _dropDuration = Duration(milliseconds: 550);
const defaultPitch = 1.1;

/// Centro da casa no mundo 3D (linha 0 fica ao fundo).
Vec3 cellCenter(int n, Pos p) =>
    Vec3(p.col - n / 2 + 0.5, 0, p.row - n / 2 + 0.5);

/// Câmera que enquadra o tabuleiro inteiro.
Camera boardCamera(
  int n,
  Size size, {
  double yaw = 0,
  double pitch = defaultPitch,
  double zoom = 1,
}) {
  final radius = (n / 2 + 0.45) * 1.08;
  return Camera(
    yaw: yaw,
    pitch: pitch,
    distance: radius / sin(Camera.fov / 2) / zoom,
    size: size,
    target: const Vec3(0, 0.25, 0),
  );
}

final Map<int, Mesh> _boardMeshes = {};

Mesh _boardMesh(int n) => _boardMeshes.putIfAbsent(n, () {
  final h = n / 2;
  final b = MeshBuilder()
    ..box(
      Vec3(-h - 0.45, -0.35, -h - 0.45),
      Vec3(h + 0.45, 0, h + 0.45),
      _frameColor.toARGB32(),
    );
  for (var r = 0; r < n; r++) {
    for (var c = 0; c < n; c++) {
      final x0 = c - h, z0 = r - h;
      b.quad(
        Vec3(x0, 0, z0),
        Vec3(x0 + 1, 0, z0),
        Vec3(x0 + 1, 0, z0 + 1),
        Vec3(x0, 0, z0 + 1),
        const Vec3(0, 1, 0),
        ((r + c).isEven ? _lightCell : _darkCell).toARGB32(),
      );
    }
  }
  return b.build();
});

/// Tabuleiro 3D interativo: toque numa casa para colocar/tirar uma rainha,
/// arraste para girar a câmera e use dois dedos para aproximar.
class Board3D extends StatefulWidget {
  final int n;
  final Set<Pos> fixed;
  final Set<Pos> placed;
  final Pos? highlight;
  final bool showAttacks;

  /// Gira a câmera e faz as rainhas pularem (vitória).
  final bool celebrate;
  final ValueChanged<Pos>? onTap;

  const Board3D({
    super.key,
    required this.n,
    required this.fixed,
    required this.placed,
    this.highlight,
    this.showAttacks = false,
    this.celebrate = false,
    this.onTap,
  });

  @override
  State<Board3D> createState() => Board3DState();
}

class Board3DState extends State<Board3D> with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_tick);
  Duration _now = Duration.zero;
  Duration _lastTick = Duration.zero;
  final Map<Pos, Duration> _droppedAt = {};

  double _yaw = 0, _pitch = defaultPitch, _zoom = 1;
  double _startYaw = 0, _startPitch = 0, _startZoom = 1;
  Offset _startFocal = Offset.zero;
  Size _size = Size.zero;

  @override
  void didUpdateWidget(Board3D oldWidget) {
    super.didUpdateWidget(oldWidget);
    for (final p in widget.placed.difference(oldWidget.placed)) {
      _droppedAt[p] = _now;
    }
    _droppedAt.removeWhere((p, _) => !widget.placed.contains(p));
    _ensureTicking();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  bool get _animating =>
      widget.celebrate ||
      _droppedAt.values.any((t) => _now - t < _dropDuration);

  void _ensureTicking() {
    if (_animating && !_ticker.isActive) {
      _lastTick = Duration.zero;
      _ticker.start();
    }
  }

  void _tick(Duration elapsed) {
    // O relógio do ticker recomeça a cada start; mantemos um relógio contínuo.
    final dt = elapsed - _lastTick;
    _lastTick = elapsed;
    setState(() {
      _now += dt;
      if (widget.celebrate) {
        _yaw += dt.inMicroseconds / 1e6 * 0.9;
      }
    });
    if (!_animating) _ticker.stop();
  }

  /// Volta a câmera para a posição inicial.
  void resetCamera() => setState(() {
    _yaw = 0;
    _pitch = defaultPitch;
    _zoom = 1;
  });

  Camera get _camera =>
      boardCamera(widget.n, _size, yaw: _yaw, pitch: _pitch, zoom: _zoom);

  double _queenLift(Pos p) {
    var lift = 0.0;
    final t = _droppedAt[p];
    if (t != null) {
      final k = (_now - t).inMicroseconds / _dropDuration.inMicroseconds;
      if (k < 1) lift = (1 - Curves.bounceOut.transform(k)) * 2.2;
    }
    if (widget.celebrate) {
      final phase = p.row * 0.7 + p.col * 0.3;
      lift += 0.35 * sin(_now.inMicroseconds / 1e6 * 5 + phase).abs();
    }
    return lift;
  }

  Pos? _pick(Offset tap) {
    final cam = _camera;
    final n = widget.n;

    // Primeiro as rainhas (o toque pode cair no corpo dela, acima da casa).
    Pos? best;
    var bestDepth = double.infinity;
    for (final q in {...widget.fixed, ...widget.placed}) {
      final base = cellCenter(n, q);
      final top = base + Vec3(0, queenHeight * _queenScale, 0);
      final a = cam.project(base), b = cam.project(top);
      if (a == null || b == null) continue;
      final depth = cam.depth(base);
      final radius = 0.3 * cam.focal / depth;
      if (_distToSegment(tap, a, b) <= radius && depth < bestDepth) {
        best = q;
        bestDepth = depth;
      }
    }
    if (best != null) return best;

    final hit = cam.unprojectToPlane(tap);
    if (hit == null) return null;
    final col = (hit.x + n / 2).floor(), row = (hit.z + n / 2).floor();
    if (row < 0 || col < 0 || row >= n || col >= n) return null;
    return Pos(row, col);
  }

  static double _distToSegment(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
    final t = len2 == 0
        ? 0.0
        : (((p - a).dx * ab.dx + (p - a).dy * ab.dy) / len2).clamp(0.0, 1.0);
    return (p - (a + ab * t)).distance;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _size = constraints.biggest;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) {
            final p = _pick(d.localPosition);
            if (p != null && !widget.fixed.contains(p)) widget.onTap?.call(p);
          },
          onScaleStart: (d) {
            _startYaw = _yaw;
            _startPitch = _pitch;
            _startZoom = _zoom;
            _startFocal = d.localFocalPoint;
          },
          onScaleUpdate: (d) => setState(() {
            if (d.pointerCount >= 2) {
              _zoom = (_startZoom * d.scale).clamp(0.7, 2.2);
            } else {
              final delta = d.localFocalPoint - _startFocal;
              _yaw = _startYaw - delta.dx * 0.008;
              _pitch = (_startPitch + delta.dy * 0.006).clamp(0.4, 1.5);
            }
          }),
          child: CustomPaint(
            size: _size,
            painter: _BoardPainter(this, _camera),
          ),
        );
      },
    );
  }
}

class _BoardPainter extends CustomPainter {
  final Board3DState state;
  final Camera camera;

  _BoardPainter(this.state, this.camera);

  @override
  void paint(Canvas canvas, Size size) {
    final w = state.widget;
    final n = w.n;
    final all = {...w.fixed, ...w.placed};
    final bad = conflicts(all);

    final flat = <Instance>[Instance(_boardMesh(n), const Vec3(0, 0, 0))];
    const lift = Vec3(0, 0.004, 0);
    if (w.showAttacks) {
      for (final p in attackedCells(n, all)) {
        flat.add(
          Instance(
            disc(0.11),
            cellCenter(n, p) + lift,
            color: _attackColor,
            unlit: true,
          ),
        );
      }
    }
    final hl = w.highlight;
    if (hl != null) {
      flat.add(
        Instance(
          frameMesh(0.96, 0.09),
          cellCenter(n, hl) + lift,
          color: _hintColor,
          unlit: true,
        ),
      );
    }

    final queens = <Instance>[];
    for (final q in all) {
      final base = cellCenter(n, q);
      final up = state._queenLift(q);
      final shadowScale = 1 / (1 + up * 0.6);
      flat.add(
        Instance(
          disc(0.4),
          base + const Vec3(0.09, 0.006, -0.07),
          scale: shadowScale,
          color: _shadowColor,
          unlit: true,
        ),
      );
      final Color color;
      if (bad.contains(q)) {
        color = _conflictQueen;
      } else if (w.fixed.contains(q)) {
        color = _fixedQueen;
      } else {
        color = _playerQueen;
      }
      queens.add(
        Instance(
          queenMesh,
          base + Vec3(0, up, 0),
          scale: _queenScale,
          color: color,
          shine: 0.45,
        ),
      );
    }

    Renderer(camera).draw(canvas, flat: flat, sorted: queens);
  }

  @override
  bool shouldRepaint(_BoardPainter old) => true;
}

/// Rainha 3D girando (logotipo da tela inicial).
class SpinningQueen extends StatefulWidget {
  final double size;
  final Color color;

  const SpinningQueen({
    super.key,
    this.size = 150,
    this.color = const Color(0xFFFFD54F),
  });

  @override
  State<SpinningQueen> createState() => _SpinningQueenState();
}

class _SpinningQueenState extends State<SpinningQueen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _t = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((e) => setState(() => _t = e.inMicroseconds / 1e6))
      ..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = Size.square(widget.size);
    return CustomPaint(
      size: size,
      painter: _QueenPainter(
        Camera(
          yaw: _t * 0.8,
          pitch: 0.3,
          distance: 2.3,
          size: size,
          target: const Vec3(0, 0.56, 0),
        ),
        widget.color,
      ),
    );
  }
}

class _QueenPainter extends CustomPainter {
  final Camera camera;
  final Color color;

  _QueenPainter(this.camera, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    Renderer(camera).draw(
      canvas,
      flat: [
        Instance(
          disc(0.5, segments: 28),
          const Vec3(0.08, 0, -0.06),
          color: _shadowColor,
          unlit: true,
        ),
      ],
      sorted: [
        Instance(queenMesh, const Vec3(0, 0, 0), color: color, shine: 0.5),
      ],
    );
  }

  @override
  bool shouldRepaint(_QueenPainter old) => true;
}
