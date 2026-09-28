import 'dart:math';
import 'dart:ui';

/// Vetor 3D simples (x para a direita, y para cima, z para o jogador).
class Vec3 {
  final double x, y, z;

  const Vec3(this.x, this.y, this.z);

  Vec3 operator +(Vec3 o) => Vec3(x + o.x, y + o.y, z + o.z);
  Vec3 operator -(Vec3 o) => Vec3(x - o.x, y - o.y, z - o.z);
  Vec3 operator *(double s) => Vec3(x * s, y * s, z * s);

  double dot(Vec3 o) => x * o.x + y * o.y + z * o.z;

  Vec3 cross(Vec3 o) =>
      Vec3(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);

  double get length => sqrt(dot(this));

  Vec3 get normalized {
    final l = length;
    return l == 0 ? this : this * (1 / l);
  }
}

/// Câmera em órbita ao redor do centro do tabuleiro, com projeção em
/// perspectiva para uma área de [size] pixels.
class Camera {
  /// Ângulo horizontal (radianos) e inclinação acima do tabuleiro.
  final double yaw, pitch, distance;
  final Vec3 target;
  final Size size;
  static const fov = 40 * pi / 180;

  late final Vec3 eye, right, up, forward;
  late final double focal;
  late final Offset center;

  Camera({
    required this.yaw,
    required this.pitch,
    required this.distance,
    required this.size,
    this.target = const Vec3(0, 0, 0),
  }) {
    eye =
        target +
        Vec3(cos(pitch) * sin(yaw), sin(pitch), cos(pitch) * cos(yaw)) *
            distance;
    forward = (target - eye).normalized;
    right = forward.cross(const Vec3(0, 1, 0)).normalized;
    up = right.cross(forward);
    focal = min(size.width, size.height) / 2 / tan(fov / 2);
    center = Offset(size.width / 2, size.height / 2);
  }

  /// Profundidade do ponto (distância ao longo da direção da câmera).
  double depth(Vec3 p) => (p - eye).dot(forward);

  /// Posição na tela, ou `null` se o ponto está atrás da câmera.
  Offset? project(Vec3 p) {
    final d = p - eye;
    final z = d.dot(forward);
    if (z < 0.05) return null;
    return Offset(
      center.dx + d.dot(right) / z * focal,
      center.dy - d.dot(up) / z * focal,
    );
  }

  /// Onde o raio que passa pelo ponto da tela toca o plano horizontal
  /// `y = planeY`.
  Vec3? unprojectToPlane(Offset screen, {double planeY = 0}) {
    final dir =
        (forward +
                right * ((screen.dx - center.dx) / focal) -
                up * ((screen.dy - center.dy) / focal))
            .normalized;
    if (dir.y.abs() < 1e-6) return null;
    final t = (planeY - eye.y) / dir.y;
    if (t <= 0) return null;
    return eye + dir * t;
  }
}
