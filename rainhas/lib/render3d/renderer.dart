import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'math3d.dart';
import 'meshes.dart';

/// Uma malha posicionada na cena.
class Instance {
  final Mesh mesh;
  final Vec3 position;
  final double scale;
  final Color color;

  /// Brilho especular (0 = fosco).
  final double shine;

  /// Sem iluminação: usa a cor como está (sombras, marcas).
  final bool unlit;

  /// Rotação em torno do eixo vertical (radianos).
  final double rotY;

  const Instance(
    this.mesh,
    this.position, {
    this.scale = 1,
    this.color = const Color(0xFFFFFFFF),
    this.shine = 0,
    this.unlit = false,
    this.rotY = 0,
  });
}

const _lightDir = Vec3(-0.45, 0.85, 0.35);

/// Renderizador 3D por software: calcula luz e projeção por triângulo e
/// desenha com [Canvas.drawVertices], do fundo para a frente (algoritmo do
/// pintor).
class Renderer {
  final Camera camera;
  final Vec3 _light = _lightDir.normalized;

  final _pos = <double>[];
  final _col = <int>[];
  final _depth = <double>[];

  Renderer(this.camera);

  /// Desenha as instâncias de [flat] na ordem dada e depois as de [sorted],
  /// com os triângulos ordenados do mais distante para o mais próximo.
  void draw(
    Canvas canvas, {
    List<Instance> flat = const [],
    List<Instance> sorted = const [],
    void Function(Canvas canvas)? afterFlat,
  }) {
    _pos.clear();
    _col.clear();
    for (final inst in flat) {
      _emit(inst, null);
    }
    _flush(canvas);
    afterFlat?.call(canvas);

    _depth.clear();
    for (final inst in sorted) {
      _emit(inst, _depth);
    }
    final count = _depth.length;
    if (count == 0) return;
    final order = List<int>.generate(count, (i) => i)
      ..sort((a, b) => _depth[b].compareTo(_depth[a]));
    final pos = Float32List(count * 6);
    final col = Int32List(count * 3);
    for (var k = 0; k < count; k++) {
      final i = order[k];
      for (var j = 0; j < 6; j++) {
        pos[k * 6 + j] = _pos[i * 6 + j];
      }
      for (var j = 0; j < 3; j++) {
        col[k * 3 + j] = _col[i * 3 + j];
      }
    }
    _drawRaw(canvas, pos, col);
    _pos.clear();
    _col.clear();
  }

  void _flush(Canvas canvas) {
    if (_col.isEmpty) return;
    _drawRaw(canvas, Float32List.fromList(_pos), Int32List.fromList(_col));
    _pos.clear();
    _col.clear();
  }

  void _drawRaw(Canvas canvas, Float32List pos, Int32List col) {
    canvas.drawVertices(
      Vertices.raw(VertexMode.triangles, pos, colors: col),
      BlendMode.dst,
      Paint(),
    );
  }

  void _emit(Instance inst, List<double>? depths) {
    final m = inst.mesh;
    final v = m.vertices, n = m.faceNormals, vn = m.vertexNormals;
    final s = inst.scale, o = inst.position;
    final cam = camera;
    final eye = cam.eye;
    final rotated = inst.rotY != 0;
    final rc = cos(inst.rotY), rs = sin(inst.rotY);
    // Gira (x, z) em torno do eixo Y.
    double rx(double x, double z) => rotated ? x * rc + z * rs : x;
    double rz(double x, double z) => rotated ? -x * rs + z * rc : z;
    for (var t = 0; t < m.triangleCount; t++) {
      final b = t * 9;
      final ax = rx(v[b], v[b + 2]) * s + o.x,
          ay = v[b + 1] * s + o.y,
          az = rz(v[b], v[b + 2]) * s + o.z;
      final bx = rx(v[b + 3], v[b + 5]) * s + o.x,
          by = v[b + 4] * s + o.y,
          bz = rz(v[b + 3], v[b + 5]) * s + o.z;
      final cx = rx(v[b + 6], v[b + 8]) * s + o.x,
          cy = v[b + 7] * s + o.y,
          cz = rz(v[b + 6], v[b + 8]) * s + o.z;
      final f = t * 3;
      final nx = rx(n[f], n[f + 2]), ny = n[f + 1], nz = rz(n[f], n[f + 2]);

      // Descarta faces viradas para trás.
      final mx = (ax + bx + cx) / 3,
          my = (ay + by + cy) / 3,
          mz = (az + bz + cz) / 3;
      final vx = eye.x - mx, vy = eye.y - my, vz = eye.z - mz;
      if (nx * vx + ny * vy + nz * vz <= 0) continue;

      final pa = cam.project(Vec3(ax, ay, az));
      final pb = cam.project(Vec3(bx, by, bz));
      final pc = cam.project(Vec3(cx, cy, cz));
      if (pa == null || pb == null || pc == null) continue;

      final base = m.colors != null ? Color(m.colors![t]) : inst.color;
      final view = Vec3(vx, vy, vz).normalized;
      for (var j = 0; j < 3; j++) {
        final k = t * 9 + j * 3;
        final normal = Vec3(
          rx(vn[k], vn[k + 2]),
          vn[k + 1],
          rz(vn[k], vn[k + 2]),
        );
        final color = inst.unlit
            ? base
            : _shade(base, normal, view, inst.shine);
        _col.add(color.toARGB32());
      }
      _pos.addAll([pa.dx, pa.dy, pb.dx, pb.dy, pc.dx, pc.dy]);
      depths?.add(cam.depth(Vec3(mx, my, mz)));
    }
  }

  Color _shade(Color c, Vec3 normal, Vec3 view, double shine) {
    final diffuse = max(0.0, normal.dot(_light));
    var light = 0.38 + 0.72 * diffuse;
    var spec = 0.0;
    if (shine > 0) {
      final h = (_light + view).normalized;
      spec = shine * pow(max(0.0, normal.dot(h)), 28).toDouble();
    }
    int ch(double x) => (x * light * 255 + spec * 255).round().clamp(0, 255);
    return Color.fromARGB((c.a * 255).round(), ch(c.r), ch(c.g), ch(c.b));
  }
}
