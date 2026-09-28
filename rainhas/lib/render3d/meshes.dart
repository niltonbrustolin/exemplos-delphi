import 'dart:math';
import 'dart:typed_data';

import 'math3d.dart';

/// Malha de triângulos com normais por face (para descartar faces de
/// trás) e por vértice (para iluminação suave).
class Mesh {
  /// 9 valores por triângulo: x, y, z dos três vértices.
  final Float32List vertices;

  /// 3 valores por triângulo: normal da face, apontando para fora.
  final Float32List faceNormals;

  /// 9 valores por triângulo: normal de cada vértice.
  final Float32List vertexNormals;

  /// Cor ARGB por triângulo; se `null`, usa a cor da instância.
  final Int32List? colors;

  Mesh(this.vertices, this.faceNormals, this.vertexNormals, [this.colors]);

  int get triangleCount => faceNormals.length ~/ 3;
}

class MeshBuilder {
  final _v = <double>[];
  final _fn = <double>[];
  final _vn = <double>[];
  final _c = <int>[];
  bool _hasColors = false;

  /// Triângulo com normais por vértice ([na], [nb], [nc]).
  void smoothTriangle(
    Vec3 a,
    Vec3 b,
    Vec3 c,
    Vec3 na,
    Vec3 nb,
    Vec3 nc, [
    int? color,
  ]) {
    _v.addAll([a.x, a.y, a.z, b.x, b.y, b.z, c.x, c.y, c.z]);
    final f = (na.normalized + nb.normalized + nc.normalized).normalized;
    _fn.addAll([f.x, f.y, f.z]);
    for (final n in [na.normalized, nb.normalized, nc.normalized]) {
      _vn.addAll([n.x, n.y, n.z]);
    }
    _c.add(color ?? 0);
    if (color != null) _hasColors = true;
  }

  void triangle(Vec3 a, Vec3 b, Vec3 c, Vec3 normal, [int? color]) =>
      smoothTriangle(a, b, c, normal, normal, normal, color);

  void quad(Vec3 a, Vec3 b, Vec3 c, Vec3 d, Vec3 normal, [int? color]) {
    triangle(a, b, c, normal, color);
    triangle(a, c, d, normal, color);
  }

  /// Superfície de revolução em torno do eixo Y, a partir de um perfil
  /// (raio, altura) ordenado de baixo para cima. Cantos com mais de ~45°
  /// ficam vincados; o resto é suavizado.
  void lathe(List<(double, double)> profile, {int segments = 20}) {
    // Normal de cada trecho do perfil no plano (raio, y), para fora.
    final seg = <(double, double)>[];
    for (var i = 0; i + 1 < profile.length; i++) {
      final (r0, y0) = profile[i];
      final (r1, y1) = profile[i + 1];
      final nr = y1 - y0, ny = -(r1 - r0);
      final l = sqrt(nr * nr + ny * ny);
      seg.add((nr / l, ny / l));
    }
    // Normal do perfil no vértice [j] visto a partir do trecho [i].
    (double, double) vertexNormal(int i, int j) {
      final other = j == i ? i - 1 : i + 1;
      if (other < 0 || other >= seg.length) return seg[i];
      final (ar, ay) = seg[i];
      final (br, by) = seg[other];
      if (ar * br + ay * by < 0.7) return seg[i];
      return (ar + br, ay + by);
    }

    Vec3 p(double r, double y, double a) => Vec3(r * cos(a), y, r * sin(a));
    Vec3 nrm((double, double) n, double a) =>
        Vec3(n.$1 * cos(a), n.$2, n.$1 * sin(a));

    for (var i = 0; i < seg.length; i++) {
      final (r0, y0) = profile[i];
      final (r1, y1) = profile[i + 1];
      final n0 = vertexNormal(i, i), n1 = vertexNormal(i, i + 1);
      for (var s = 0; s < segments; s++) {
        final a0 = 2 * pi * s / segments;
        final a1 = 2 * pi * (s + 1) / segments;
        final p00 = p(r0, y0, a0), p01 = p(r0, y0, a1);
        final p10 = p(r1, y1, a0), p11 = p(r1, y1, a1);
        if (r0 > 1e-6) {
          smoothTriangle(p00, p01, p11, nrm(n0, a0), nrm(n0, a1), nrm(n1, a1));
        }
        if (r1 > 1e-6) {
          smoothTriangle(p00, p11, p10, nrm(n0, a0), nrm(n1, a1), nrm(n1, a0));
        }
      }
    }
  }

  void sphere(Vec3 c, double r, {int slices = 10, int stacks = 6}) {
    Vec3 at(int i, int j) {
      final theta = pi * i / stacks;
      final phi = 2 * pi * j / slices;
      return Vec3(
        c.x + r * sin(theta) * cos(phi),
        c.y + r * cos(theta),
        c.z + r * sin(theta) * sin(phi),
      );
    }

    for (var i = 0; i < stacks; i++) {
      for (var j = 0; j < slices; j++) {
        final a = at(i, j), b = at(i + 1, j);
        final d = at(i, j + 1), e = at(i + 1, j + 1);
        if (i > 0) smoothTriangle(a, d, e, a - c, d - c, e - c);
        if (i < stacks - 1) smoothTriangle(a, e, b, a - c, e - c, b - c);
      }
    }
  }

  /// Caixa alinhada aos eixos (só as faces de cima e dos lados).
  void box(Vec3 min, Vec3 max, int color) {
    final (x0, y0, z0) = (min.x, min.y, min.z);
    final (x1, y1, z1) = (max.x, max.y, max.z);
    quad(
      Vec3(x0, y1, z0),
      Vec3(x1, y1, z0),
      Vec3(x1, y1, z1),
      Vec3(x0, y1, z1),
      const Vec3(0, 1, 0),
      color,
    );
    quad(
      Vec3(x0, y0, z1),
      Vec3(x1, y0, z1),
      Vec3(x1, y1, z1),
      Vec3(x0, y1, z1),
      const Vec3(0, 0, 1),
      color,
    );
    quad(
      Vec3(x0, y0, z0),
      Vec3(x1, y0, z0),
      Vec3(x1, y1, z0),
      Vec3(x0, y1, z0),
      const Vec3(0, 0, -1),
      color,
    );
    quad(
      Vec3(x1, y0, z0),
      Vec3(x1, y0, z1),
      Vec3(x1, y1, z1),
      Vec3(x1, y1, z0),
      const Vec3(1, 0, 0),
      color,
    );
    quad(
      Vec3(x0, y0, z0),
      Vec3(x0, y0, z1),
      Vec3(x0, y1, z1),
      Vec3(x0, y1, z0),
      const Vec3(-1, 0, 0),
      color,
    );
  }

  Mesh build() => Mesh(
    Float32List.fromList(_v),
    Float32List.fromList(_fn),
    Float32List.fromList(_vn),
    _hasColors ? Int32List.fromList(_c) : null,
  );
}

/// Altura da rainha (em casas do tabuleiro).
const queenHeight = 1.22;

/// Rainha de xadrez no estilo Staunton, com base de raio ~0,36 casa.
final Mesh queenMesh = () {
  final b = MeshBuilder()
    ..lathe(const [
      (0.00, 0.00),
      (0.36, 0.00),
      (0.36, 0.05),
      (0.33, 0.09),
      (0.30, 0.12),
      (0.30, 0.15),
      (0.22, 0.19),
      (0.17, 0.26),
      (0.13, 0.42),
      (0.11, 0.62),
      (0.11, 0.72),
      (0.19, 0.76),
      (0.20, 0.80),
      (0.12, 0.84),
      (0.12, 0.88),
      (0.17, 0.96),
      (0.22, 1.06),
      (0.15, 1.08),
      (0.08, 1.12),
      (0.00, 1.13),
    ], segments: 22)
    ..sphere(const Vec3(0, 1.17, 0), 0.055);
  for (var i = 0; i < 9; i++) {
    final a = 2 * pi * i / 9;
    b.sphere(
      Vec3(0.21 * cos(a), 1.075, 0.21 * sin(a)),
      0.032,
      slices: 6,
      stacks: 4,
    );
  }
  return b.build();
}();

final Map<String, Mesh> _discs = {};

/// Disco horizontal (para sombras e marcas no tabuleiro).
Mesh disc(double radius, {int segments = 18}) {
  return _discs.putIfAbsent('$radius/$segments', () {
    final b = MeshBuilder();
    for (var s = 0; s < segments; s++) {
      final a0 = 2 * pi * s / segments, a1 = 2 * pi * (s + 1) / segments;
      b.triangle(
        const Vec3(0, 0, 0),
        Vec3(radius * cos(a1), 0, radius * sin(a1)),
        Vec3(radius * cos(a0), 0, radius * sin(a0)),
        const Vec3(0, 1, 0),
      );
    }
    return b.build();
  });
}

/// Moldura quadrada fina na altura do tabuleiro (destaque de uma casa).
Mesh frameMesh(double size, double thickness) {
  final b = MeshBuilder();
  final h = size / 2, t = thickness;
  const up = Vec3(0, 1, 0);
  void rect(double x0, double z0, double x1, double z1) => b.quad(
    Vec3(x0, 0, z0),
    Vec3(x0, 0, z1),
    Vec3(x1, 0, z1),
    Vec3(x1, 0, z0),
    up,
  );
  rect(-h, -h, h, -h + t);
  rect(-h, h - t, h, h);
  rect(-h, -h + t, -h + t, h - t);
  rect(h - t, -h + t, h, h - t);
  return b.build();
}
