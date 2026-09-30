import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../game/board.dart';
import '../l10n/l10n.dart';
import '../render3d/math3d.dart';
import '../render3d/meshes.dart';
import '../render3d/renderer.dart';
import '../render3d/themes.dart';
import '../services/progress.dart';

const _conflictColor = Color(0xFFE53935);
const _shadowColor = Color(0x59000000);
const _cursorColor = Color(0xFF40C4FF);

/// Vista plana (2D, de cima) em vez da 3D. O tabuleiro se redesenha quando
/// ela muda.
final boardFlat = ValueNotifier<bool>(false);

const _dropDuration = Duration(milliseconds: 550);
const _hopDuration = Duration(milliseconds: 380);
const defaultPitch = 1.1;

/// Câmera mais baixa nos modos do cavalo, para ver o perfil da peça.
const knightPitch = 0.82;

enum PieceKind { queen, knight }

/// Papel da peça, que define a cor dela.
enum PieceRole { player, fixed, conflict }

/// Uma peça no tabuleiro. O [id] identifica a peça entre um quadro e outro:
/// peça nova cai no tabuleiro; peça que mudou de casa pula até a nova casa.
class BoardPiece {
  final Object id;
  final Pos pos;
  final PieceKind kind;
  final PieceRole role;

  const BoardPiece(this.id, this.pos, this.kind, this.role);
}

enum MarkKind { dot, frame, fill }

/// Marca desenhada sobre uma casa (dica, casa atacada, casa visitada...).
class CellMark {
  final Pos pos;
  final MarkKind kind;
  final Color color;

  /// O que a marca significa, para o leitor de tela.
  final String? label;

  const CellMark(this.pos, this.kind, this.color, {this.label});
}

/// Nome da casa como no xadrez: coluna em letra e linha em número (a
/// linha 0 fica ao fundo, com o número mais alto).
String cellName(int n, Pos p) =>
    '${String.fromCharCode(97 + p.col)}${n - p.row}';

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

Mesh pieceMesh(PieceKind kind) =>
    kind == PieceKind.queen ? queenMesh : knightMesh;

double pieceHeight(PieceKind kind) =>
    kind == PieceKind.queen ? queenHeight : knightHeight;

/// Ângulo que mostra o cavalo de perfil, virado um pouco para a câmera.
double knightFacing(double cameraYaw) => cameraYaw + pi / 2 - 0.55;

/// Escala da peça no tabuleiro (o cavalo é um pouco maior para aparecer bem).
double pieceScale(PieceKind kind) => kind == PieceKind.queen ? 0.9 : 1.02;

Color pieceColor(BoardTheme theme, PieceRole role) => switch (role) {
  PieceRole.player => theme.player,
  PieceRole.fixed => theme.fixed,
  PieceRole.conflict => _conflictColor,
};

final Map<String, Mesh> _boardMeshes = {};

Mesh _boardMesh(int n, BoardTheme theme) =>
    _boardMeshes.putIfAbsent('$n/${theme.id}', () {
      final h = n / 2;
      final b = MeshBuilder()
        ..box(
          Vec3(-h - 0.45, -0.35, -h - 0.45),
          Vec3(h + 0.45, 0, h + 0.45),
          theme.frame.toARGB32(),
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
            ((r + c).isEven ? theme.light : theme.dark).toARGB32(),
          );
        }
      }
      return b.build();
    });

class _Anim {
  final Pos? from;
  final Duration start;

  const _Anim(this.from, this.start);
}

/// Tabuleiro 3D interativo: toque numa casa para jogar, arraste para girar
/// a câmera e use dois dedos para aproximar.
class Board3D extends StatefulWidget {
  final int n;
  final List<BoardPiece> pieces;
  final List<CellMark> marks;
  final Set<Pos> blocked;

  /// Textos sobre as casas (ex.: a ordem das casas no Passeio do Cavalo).
  final Map<Pos, String> labels;

  /// Gira a câmera e faz as peças pularem (vitória).
  final bool celebrate;
  final ValueChanged<Pos>? onTap;

  /// Tema a usar; se `null`, usa o escolhido pelo jogador.
  final BoardTheme? theme;

  /// Inclinação inicial da câmera (menor = mais de lado).
  final double pitch;

  /// Força a vista plana (`true`) ou 3D (`false`); `null` segue [boardFlat].
  final bool? flat;

  const Board3D({
    super.key,
    required this.n,
    required this.pieces,
    this.marks = const [],
    this.blocked = const {},
    this.labels = const {},
    this.celebrate = false,
    this.onTap,
    this.theme,
    this.pitch = defaultPitch,
    this.flat,
  });

  @override
  State<Board3D> createState() => Board3DState();
}

class Board3DState extends State<Board3D> with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_tick);
  Duration _now = Duration.zero;
  Duration _lastTick = Duration.zero;
  final Map<Object, _Anim> _anims = {};

  double _yaw = 0, _zoom = 1;
  late double _pitch = widget.pitch;
  double _startYaw = 0, _startPitch = 0, _startZoom = 1;
  Offset _startFocal = Offset.zero;
  Size _size = Size.zero;

  /// Casa escolhida pelo teclado (aparece quando o tabuleiro tem o foco).
  final _focus = FocusNode(debugLabel: 'tabuleiro');
  Pos _cursor = const Pos(0, 0);

  @override
  void initState() {
    super.initState();
    _focus.addListener(_refresh);
    FocusManager.instance.addHighlightModeListener(_onHighlightMode);
  }

  void _refresh() => setState(() {});

  void _onHighlightMode(FocusHighlightMode _) => _refresh();

  /// A casa do teclado só aparece quando se está usando o teclado (não
  /// depois de um toque ou clique).
  bool get _showCursor =>
      _focus.hasFocus &&
      FocusManager.instance.highlightMode == FocusHighlightMode.traditional;

  BoardTheme get _theme => widget.theme ?? Progress.instance.theme;

  @override
  void didUpdateWidget(Board3D oldWidget) {
    super.didUpdateWidget(oldWidget);
    final old = {for (final p in oldWidget.pieces) p.id: p.pos};
    for (final p in widget.pieces) {
      final before = old[p.id];
      if (!old.containsKey(p.id)) {
        _anims[p.id] = _Anim(null, _now);
      } else if (before != p.pos) {
        _anims[p.id] = _Anim(before, _now);
      }
    }
    final ids = {for (final p in widget.pieces) p.id};
    _anims.removeWhere((id, _) => !ids.contains(id));
    // Fim da comemoração (ex.: "Jogar de novo"): câmera volta ao início.
    if (oldWidget.celebrate && !widget.celebrate) _yaw = 0;
    _ensureTicking();
  }

  @override
  void dispose() {
    _ticker.dispose();
    FocusManager.instance.removeHighlightModeListener(_onHighlightMode);
    _focus.dispose();
    super.dispose();
  }

  bool get _animating =>
      widget.celebrate ||
      _anims.values.any((a) => _now - a.start < _dropDuration);

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
    _pitch = widget.pitch;
    _zoom = 1;
  });

  Camera get _camera =>
      boardCamera(widget.n, _size, yaw: _yaw, pitch: _pitch, zoom: _zoom);

  /// Posição atual da peça, considerando queda, pulo e comemoração.
  Vec3 _piecePosition(BoardPiece p) {
    final n = widget.n;
    var pos = cellCenter(n, p.pos);
    final anim = _anims[p.id];
    if (anim != null) {
      final from = anim.from;
      final elapsed = (_now - anim.start).inMicroseconds;
      if (from == null) {
        final k = elapsed / _dropDuration.inMicroseconds;
        if (k < 1) {
          pos += Vec3(0, (1 - Curves.bounceOut.transform(k)) * 2.2, 0);
        }
      } else {
        final k = elapsed / _hopDuration.inMicroseconds;
        if (k < 1) {
          final e = Curves.easeInOut.transform(k);
          final a = cellCenter(n, from);
          pos = a + (pos - a) * e + Vec3(0, sin(pi * e) * 1.1, 0);
        }
      }
    }
    if (widget.celebrate) {
      final phase = p.pos.row * 0.7 + p.pos.col * 0.3;
      pos += Vec3(
        0,
        0.35 * sin(_now.inMicroseconds / 1e6 * 5 + phase).abs(),
        0,
      );
    }
    return pos;
  }

  Pos? _pick(Offset tap) {
    final cam = _camera;
    final n = widget.n;

    // Primeiro as peças (o toque pode cair no corpo dela, acima da casa).
    Pos? best;
    var bestDepth = double.infinity;
    for (final p in widget.pieces) {
      final base = cellCenter(n, p.pos);
      final top = base + Vec3(0, pieceHeight(p.kind) * pieceScale(p.kind), 0);
      final a = cam.project(base), b = cam.project(top);
      if (a == null || b == null) continue;
      final depth = cam.depth(base);
      final radius = 0.3 * cam.focal / depth;
      if (_distToSegment(tap, a, b) <= radius && depth < bestDepth) {
        best = p.pos;
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

  /// Marcas da tela, com a casa do teclado quando o tabuleiro tem o foco.
  List<CellMark> get _marks => [
    ...widget.marks,
    if (_showCursor) CellMark(_cursor, MarkKind.frame, _cursorColor),
  ];

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final n = widget.n;
    final key = event.logicalKey;
    final (dr, dc) = switch (key) {
      LogicalKeyboardKey.arrowUp => (-1, 0),
      LogicalKeyboardKey.arrowDown => (1, 0),
      LogicalKeyboardKey.arrowLeft => (0, -1),
      LogicalKeyboardKey.arrowRight => (0, 1),
      _ => (0, 0),
    };
    if (dr != 0 || dc != 0) {
      setState(() {
        _cursor = Pos(
          (_cursor.row + dr).clamp(0, n - 1),
          (_cursor.col + dc).clamp(0, n - 1),
        );
      });
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.space) {
      widget.onTap?.call(_cursor);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  /// Descrição da casa para o leitor de tela: "c3, rainha, em conflito".
  String _cellLabel(AppLocalizations l, Pos p) {
    final parts = <String>[];
    for (final piece in widget.pieces) {
      if (piece.pos != p) continue;
      parts.add(switch (piece.kind) {
        PieceKind.knight => l.a11yKnight,
        PieceKind.queen when piece.role == PieceRole.fixed => l.a11yFixedQueen,
        PieceKind.queen => l.a11yQueen,
      });
      if (piece.role == PieceRole.conflict) parts.add(l.a11yConflict);
    }
    if (widget.blocked.contains(p)) parts.add(l.a11yBlocked);
    final step = int.tryParse(widget.labels[p] ?? '');
    if (step != null) parts.add(l.a11yStep(step));
    for (final m in widget.marks) {
      if (m.pos == p && m.label != null) parts.add(m.label!);
    }
    if (parts.isEmpty) parts.add(l.a11yEmpty);
    return '${cellName(widget.n, p)}, ${parts.join(', ')}';
  }

  /// Área da casa na tela (na vista 3D, inclui a peça que está em pé nela).
  Rect _cellRect(Pos p, _FlatLayout? flat) {
    if (flat != null) return flat.rect(p);
    final cam = _camera;
    final c = cellCenter(widget.n, p);
    final points = <Offset?>[
      for (final (dx, dz) in const [(-.5, -.5), (.5, -.5), (.5, .5), (-.5, .5)])
        cam.project(c + Vec3(dx, 0, dz)),
    ];
    for (final piece in widget.pieces) {
      if (piece.pos != p) continue;
      final top =
          c + Vec3(0, pieceHeight(piece.kind) * pieceScale(piece.kind), 0);
      final at = cam.project(top);
      if (at != null) {
        final r = 0.3 * cam.focal / cam.depth(top);
        points
          ..add(at - Offset(r, r))
          ..add(at + Offset(r, r));
      }
    }
    final valid = points.whereType<Offset>().toList();
    if (valid.isEmpty) return Rect.zero;
    var rect = Rect.fromPoints(valid.first, valid.first);
    for (final o in valid) {
      rect = rect.expandToInclude(Rect.fromPoints(o, o));
    }
    return rect;
  }

  /// Uma casa "invisível" por casa do tabuleiro, para leitores de tela e
  /// para o navegador identificar cada casa. As casas mais próximas da
  /// câmera ficam por cima, como no toque.
  List<Widget> _cellSemantics(BuildContext context, _FlatLayout? flat) {
    final l = context.l10n;
    final n = widget.n;
    final occupied = {for (final p in widget.pieces) p.pos};
    final cells = [
      for (var r = 0; r < n; r++)
        for (var c = 0; c < n; c++) Pos(r, c),
    ];
    if (flat == null) {
      final cam = _camera;
      double depth(Pos p) => cam.depth(cellCenter(n, p));
      cells.sort((a, b) {
        final byPiece = (occupied.contains(a) ? 1 : 0).compareTo(
          occupied.contains(b) ? 1 : 0,
        );
        return byPiece != 0 ? byPiece : depth(b).compareTo(depth(a));
      });
    }
    return [
      for (final p in cells)
        Positioned.fromRect(
          rect: _cellRect(p, flat),
          child: Semantics(
            button: true,
            label: _cellLabel(l, p),
            onTap: () => widget.onTap?.call(p),
            child: const SizedBox.expand(),
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: boardFlat,
      builder: (context, flatSetting, _) => LayoutBuilder(
        builder: (context, constraints) {
          _size = constraints.biggest;
          final flat = (widget.flat ?? flatSetting)
              ? _FlatLayout(_size, widget.n)
              : null;
          final board = GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onTapUp: (d) {
              final p = flat != null
                  ? flat.pick(d.localPosition)
                  : _pick(d.localPosition);
              if (p != null) widget.onTap?.call(p);
            },
            onScaleStart: flat != null
                ? null
                : (d) {
                    _startYaw = _yaw;
                    _startPitch = _pitch;
                    _startZoom = _zoom;
                    _startFocal = d.localFocalPoint;
                  },
            onScaleUpdate: flat != null
                ? null
                : (d) => setState(() {
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
              painter: flat != null
                  ? _FlatPainter(this, flat)
                  : _BoardPainter(this, _camera),
            ),
          );
          // Tabuleiro só de enfeite (tutorial): sem foco nem leitor de tela.
          if (widget.onTap == null) return ExcludeSemantics(child: board);
          return Focus(
            focusNode: _focus,
            onKeyEvent: _onKey,
            child: Semantics(
              container: true,
              explicitChildNodes: true,
              label: context.l10n.a11yBoard(widget.n),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  board,
                  // Durante a comemoração a câmera gira: sem casas no leitor.
                  if (!widget.celebrate) ..._cellSemantics(context, flat),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Posição das casas na vista plana: tabuleiro quadrado no centro, com
/// moldura onde vão as letras e números das casas.
class _FlatLayout {
  final int n;
  late final double cell;
  late final Offset origin;

  _FlatLayout(Size size, this.n) {
    cell = min(size.width, size.height) / (n + 1.1);
    origin = size.center(Offset.zero) - Offset(n * cell / 2, n * cell / 2);
  }

  Rect rect(Pos p) => Rect.fromLTWH(
    origin.dx + p.col * cell,
    origin.dy + p.row * cell,
    cell,
    cell,
  );

  Offset at(Vec3 v) =>
      origin + Offset((v.x + n / 2) * cell, (v.z + n / 2) * cell);

  Pos? pick(Offset o) {
    final col = ((o.dx - origin.dx) / cell).floor();
    final row = ((o.dy - origin.dy) / cell).floor();
    if (row < 0 || col < 0 || row >= n || col >= n) return null;
    return Pos(row, col);
  }
}

class _BoardPainter extends CustomPainter {
  final Board3DState state;
  final Camera camera;

  _BoardPainter(this.state, this.camera);

  @override
  void paint(Canvas canvas, Size size) {
    final w = state.widget;
    paintBoardScene(
      canvas,
      camera,
      n: w.n,
      theme: state._theme,
      pieces: w.pieces,
      marks: state._marks,
      blocked: w.blocked,
      labels: w.labels,
      position: state._piecePosition,
    );
  }

  @override
  bool shouldRepaint(_BoardPainter old) => true;
}

/// Vista 2D: o tabuleiro visto de cima, com as peças 3D de pé em cada casa
/// (como num diagrama de xadrez).
class _FlatPainter extends CustomPainter {
  final Board3DState state;
  final _FlatLayout layout;

  _FlatPainter(this.state, this.layout);

  @override
  void paint(Canvas canvas, Size size) {
    final w = state.widget;
    final theme = state._theme;
    final n = layout.n;
    final cell = layout.cell;
    final board = Rect.fromLTWH(
      layout.origin.dx,
      layout.origin.dy,
      n * cell,
      n * cell,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        board.inflate(cell * 0.45),
        Radius.circular(cell * 0.15),
      ),
      Paint()..color = theme.frame,
    );
    for (var r = 0; r < n; r++) {
      for (var c = 0; c < n; c++) {
        canvas.drawRect(
          layout.rect(Pos(r, c)),
          Paint()..color = (r + c).isEven ? theme.light : theme.dark,
        );
      }
    }
    _drawCoordinates(canvas, board);

    for (final b in w.blocked) {
      final rect = layout.rect(b).deflate(cell * 0.08);
      final radius = Radius.circular(cell * 0.12);
      canvas
        ..drawRRect(
          RRect.fromRectAndRadius(rect.shift(Offset(0, cell * 0.05)), radius),
          Paint()..color = _shadowColor,
        )
        ..drawRRect(
          RRect.fromRectAndRadius(rect, radius),
          Paint()..color = theme.block,
        )
        ..drawRRect(
          RRect.fromRectAndRadius(rect.deflate(cell * 0.12), radius),
          Paint()
            ..color = Color.lerp(theme.block, const Color(0xFFFFFFFF), 0.12)!,
        );
    }

    for (final m in state._marks) {
      final rect = layout.rect(m.pos);
      final paint = Paint()..color = m.color;
      switch (m.kind) {
        case MarkKind.fill:
          canvas.drawRect(rect.deflate(cell * 0.01), paint);
        case MarkKind.dot:
          canvas.drawCircle(rect.center, cell * 0.11, paint);
        case MarkKind.frame:
          canvas.drawRect(
            rect.deflate(cell * 0.05),
            paint
              ..style = PaintingStyle.stroke
              ..strokeWidth = cell * 0.09,
          );
      }
    }

    for (final e in w.labels.entries) {
      _text(
        canvas,
        e.value,
        layout.rect(e.key).center,
        cell * 0.36,
        const Color(0xFFFFFFFF),
        shadow: true,
      );
    }

    // Peças de trás para a frente, para a de baixo cobrir a de cima.
    final pieces = [...w.pieces]
      ..sort((a, b) => a.pos.row.compareTo(b.pos.row));
    for (final p in pieces) {
      final pos = state._piecePosition(p);
      final base = layout.at(Vec3(pos.x, 0, pos.z)) + Offset(0, cell * 0.28);
      final lift = pos.y * cell * 0.45;
      canvas.drawOval(
        Rect.fromCenter(
          center: base,
          width: cell * 0.62 / (1 + pos.y * 0.6),
          height: cell * 0.2 / (1 + pos.y * 0.6),
        ),
        Paint()..color = _shadowColor,
      );
      final sprite = _sprite(
        p.kind,
        pieceColor(theme, p.role),
        theme.shine,
        cell,
      );
      canvas
        ..save()
        ..translate(base.dx - cell / 2, base.dy - cell * 0.92 - lift)
        ..drawPicture(sprite)
        ..restore();
    }
  }

  void _drawCoordinates(Canvas canvas, Rect board) {
    final n = layout.n;
    final cell = layout.cell;
    const color = Color(0x99FFFFFF);
    for (var i = 0; i < n; i++) {
      _text(
        canvas,
        String.fromCharCode(97 + i),
        Offset(board.left + (i + 0.5) * cell, board.bottom + cell * 0.22),
        cell * 0.24,
        color,
      );
      _text(
        canvas,
        '${n - i}',
        Offset(board.left - cell * 0.22, board.top + (i + 0.5) * cell),
        cell * 0.24,
        color,
      );
    }
  }

  static void _text(
    Canvas canvas,
    String value,
    Offset center,
    double size,
    Color color, {
    bool shadow = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w800,
          shadows: shadow
              ? const [Shadow(blurRadius: 3, color: Color(0xCC000000))]
              : null,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(_FlatPainter old) => true;
}

final Map<String, ui.Picture> _sprites = {};

/// Desenho da peça vista de lado, do tamanho de uma casa (fica guardado).
ui.Picture _sprite(PieceKind kind, Color color, double shine, double cell) {
  if (_sprites.length > 40) _sprites.clear();
  return _sprites.putIfAbsent(
    '$kind/${color.toARGB32()}/$shine/${cell.round()}',
    () {
      final size = Size.square(cell);
      final recorder = ui.PictureRecorder();
      final height = pieceHeight(kind) * pieceScale(kind);
      Renderer(
        Camera(
          yaw: 0,
          pitch: 0.35,
          distance: height * 1.55,
          size: size,
          target: Vec3(0, height * 0.5, 0),
        ),
      ).draw(
        Canvas(recorder, Offset.zero & size),
        sorted: [
          Instance(
            pieceMesh(kind),
            const Vec3(0, 0, 0),
            scale: pieceScale(kind),
            color: color,
            shine: shine,
            rotY: kind == PieceKind.knight ? knightFacing(0) : 0,
          ),
        ],
      );
      return recorder.endRecording();
    },
  );
}

/// Desenha o tabuleiro com peças, marcas, blocos e números. Usado pela tela
/// e também para gerar a imagem de compartilhamento.
void paintBoardScene(
  Canvas canvas,
  Camera camera, {
  required int n,
  required BoardTheme theme,
  List<BoardPiece> pieces = const [],
  List<CellMark> marks = const [],
  Set<Pos> blocked = const {},
  Map<Pos, String> labels = const {},
  Vec3 Function(BoardPiece piece)? position,
}) {
  final flat = <Instance>[Instance(_boardMesh(n, theme), const Vec3(0, 0, 0))];
  const lift = Vec3(0, 0.004, 0);
  for (final m in marks) {
    final mesh = switch (m.kind) {
      MarkKind.dot => disc(0.11),
      MarkKind.frame => frameMesh(0.96, 0.09),
      MarkKind.fill => frameMesh(0.98, 0.49),
    };
    flat.add(
      Instance(mesh, cellCenter(n, m.pos) + lift, color: m.color, unlit: true),
    );
  }

  final solids = <Instance>[
    for (final b in blocked)
      Instance(blockMesh, cellCenter(n, b), color: theme.block, shine: 0.15),
  ];
  for (final p in pieces) {
    final pos = position?.call(p) ?? cellCenter(n, p.pos);
    final shadowScale = 1 / (1 + pos.y * 0.6);
    flat.add(
      Instance(
        disc(0.4),
        Vec3(pos.x, 0, pos.z) + const Vec3(0.09, 0.006, -0.07),
        scale: shadowScale,
        color: _shadowColor,
        unlit: true,
      ),
    );
    solids.add(
      Instance(
        pieceMesh(p.kind),
        pos,
        scale: pieceScale(p.kind),
        color: pieceColor(theme, p.role),
        shine: theme.shine,
        rotY: p.kind == PieceKind.knight ? knightFacing(camera.yaw) : 0,
      ),
    );
  }

  Renderer(camera).draw(
    canvas,
    flat: flat,
    sorted: solids,
    afterFlat: (canvas) => _drawLabels(canvas, camera, n, labels),
  );
}

void _drawLabels(Canvas canvas, Camera camera, int n, Map<Pos, String> labels) {
  for (final e in labels.entries) {
    final center = cellCenter(n, e.key);
    final at = camera.project(center);
    if (at == null) continue;
    final fontSize = 0.36 * camera.focal / camera.depth(center);
    final painter = TextPainter(
      text: TextSpan(
        text: e.value,
        style: TextStyle(
          color: const Color(0xFFFFFFFF),
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          shadows: const [Shadow(blurRadius: 3, color: Color(0xCC000000))],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }
}

/// Peça 3D girando (logotipo e ícones).
class SpinningPiece extends StatefulWidget {
  final double size;
  final Color color;
  final PieceKind kind;

  const SpinningPiece({
    super.key,
    this.size = 150,
    this.color = const Color(0xFFFFD54F),
    this.kind = PieceKind.queen,
  });

  @override
  State<SpinningPiece> createState() => _SpinningPieceState();
}

class _SpinningPieceState extends State<SpinningPiece>
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
      painter: _PiecePainter(
        Camera(
          yaw: _t * 0.8,
          pitch: 0.3,
          distance: 2.3,
          size: size,
          target: const Vec3(0, 0.56, 0),
        ),
        widget.color,
        widget.kind,
      ),
    );
  }
}

class _PiecePainter extends CustomPainter {
  final Camera camera;
  final Color color;
  final PieceKind kind;

  _PiecePainter(this.camera, this.color, this.kind);

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
        Instance(
          pieceMesh(kind),
          const Vec3(0, 0, 0),
          color: color,
          shine: 0.5,
        ),
      ],
    );
  }

  @override
  bool shouldRepaint(_PiecePainter old) => true;
}
