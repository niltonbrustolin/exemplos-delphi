import 'board.dart';
import 'knights.dart';
import 'levels.dart';

/// Legendas das demonstrações (o texto vem da tradução).
enum DemoCaption {
  tapToPlace,
  conflict,
  tapToRemove,
  solved,
  knightL,
  visitAll,
  knightsGoal,
  blocked,
}

/// O que uma peça é na demonstração: rainha ou cavalo, e se está em
/// conflito.
enum DemoPiece { queen, knight, conflictQueen, conflictKnight }

/// Um quadro da demonstração animada.
class DemoFrame {
  final int n;
  final Map<Pos, DemoPiece> pieces;

  /// Casa onde o "dedo" vai tocar em seguida.
  final Pos? tap;

  /// Jogadas possíveis (pontos verdes) e casas já visitadas (Passeio).
  final Set<Pos> moves;
  final List<Pos> visited;
  final Set<Pos> blocked;
  final DemoCaption caption;
  final bool solved;

  const DemoFrame({
    required this.n,
    required this.pieces,
    required this.caption,
    this.tap,
    this.moves = const {},
    this.visited = const [],
    this.blocked = const {},
    this.solved = false,
  });
}

/// Rainhas no 4×4: coloca, erra (conflito), tira e resolve.
List<DemoFrame> queensDemo() {
  const n = 4;
  final frames = <DemoFrame>[];
  final placed = <Pos>[];

  void show(DemoCaption caption, {Pos? tap, bool solved = false}) {
    final bad = conflicts(placed);
    frames.add(
      DemoFrame(
        n: n,
        pieces: {
          for (final q in placed)
            q: bad.contains(q) ? DemoPiece.conflictQueen : DemoPiece.queen,
        },
        tap: tap,
        caption: caption,
        solved: solved,
      ),
    );
  }

  void place(Pos p, DemoCaption before, DemoCaption after) {
    show(before, tap: p);
    placed.add(p);
    show(after);
  }

  show(DemoCaption.tapToPlace);
  place(const Pos(0, 1), DemoCaption.tapToPlace, DemoCaption.tapToPlace);
  place(const Pos(1, 2), DemoCaption.tapToPlace, DemoCaption.conflict);
  show(DemoCaption.conflict);
  show(DemoCaption.tapToRemove, tap: const Pos(1, 2));
  placed.remove(const Pos(1, 2));
  show(DemoCaption.tapToRemove);
  for (final p in const [Pos(1, 3), Pos(2, 0)]) {
    place(p, DemoCaption.tapToPlace, DemoCaption.tapToPlace);
  }
  show(DemoCaption.tapToPlace, tap: const Pos(3, 2));
  placed.add(const Pos(3, 2));
  for (var i = 0; i < 3; i++) {
    show(DemoCaption.solved, solved: true);
  }
  return frames;
}

/// Passeio do Cavalo no 5×5: os primeiros pulos de um passeio de verdade.
List<DemoFrame> tourDemo() {
  const n = 5;
  const start = Pos(0, 0);
  final route = completeTour(n, const {}, [start])!;
  final frames = <DemoFrame>[];
  const steps = 8;

  for (var i = 1; i <= steps; i++) {
    final path = route.sublist(0, i);
    final moves = knightMoves(
      n,
      path.last,
      const {},
    ).where((p) => !path.contains(p)).toSet();
    final caption = i <= 4 ? DemoCaption.knightL : DemoCaption.visitAll;
    DemoFrame frame({Pos? tap}) => DemoFrame(
      n: n,
      pieces: {path.last: DemoPiece.knight},
      visited: path,
      moves: moves,
      tap: tap,
      caption: caption,
    );
    frames
      ..add(frame())
      ..add(frame(tap: i < steps ? route[i] : null));
  }
  frames.add(frames.last);
  return frames;
}

/// Cavalos sem Ataque no 4×4 com casas bloqueadas.
List<DemoFrame> knightsDemo() {
  const n = 4;
  final blocked = {const Pos(1, 1), const Pos(2, 3)};
  final cells = [
    for (var r = 0; r < n; r++)
      for (var c = 0; c < n; c++)
        if (!blocked.contains(Pos(r, c))) Pos(r, c),
  ];
  final best = maxIndependentKnights(cells).toList()
    ..sort((a, b) => a.row != b.row ? a.row - b.row : a.col - b.col);
  final first = best.first;
  final wrong = knightMoves(n, first, blocked).first;

  final frames = <DemoFrame>[];
  final placed = <Pos>[];
  void show(DemoCaption caption, {Pos? tap, bool solved = false}) {
    final bad = {
      for (final a in placed)
        for (final b in placed)
          if (knightAttacks(a, b)) a,
    };
    frames.add(
      DemoFrame(
        n: n,
        blocked: blocked,
        pieces: {
          for (final k in placed)
            k: bad.contains(k) ? DemoPiece.conflictKnight : DemoPiece.knight,
        },
        tap: tap,
        caption: caption,
        solved: solved,
      ),
    );
  }

  show(DemoCaption.knightsGoal);
  show(DemoCaption.blocked);
  show(DemoCaption.knightsGoal, tap: first);
  placed.add(first);
  show(DemoCaption.knightsGoal, tap: wrong);
  placed.add(wrong);
  show(DemoCaption.conflict);
  show(DemoCaption.tapToRemove, tap: wrong);
  placed.remove(wrong);
  for (final p in best.skip(1)) {
    show(DemoCaption.knightsGoal, tap: p);
    placed.add(p);
  }
  for (var i = 0; i < 3; i++) {
    show(DemoCaption.solved, solved: true);
  }
  return frames;
}

List<DemoFrame> demoFor(GameMode mode) => switch (mode) {
  GameMode.queens => queensDemo(),
  GameMode.tour => tourDemo(),
  GameMode.knights => knightsDemo(),
};
