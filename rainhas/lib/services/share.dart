import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../config/app_info.dart';
import '../game/board.dart';
import '../l10n/l10n.dart';
import '../render3d/themes.dart';
import '../widgets/board_3d.dart';
import '../widgets/game_ui.dart';
import 'progress.dart';

/// O tabuleiro final da partida, para desenhar na imagem.
class ShareBoard {
  final int n;
  final List<BoardPiece> pieces;
  final Set<Pos> blocked;
  final Map<Pos, String> labels;
  final List<CellMark> marks;
  final double pitch;

  const ShareBoard({
    required this.n,
    required this.pieces,
    this.blocked = const {},
    this.labels = const {},
    this.marks = const [],
    this.pitch = defaultPitch,
  });
}

/// Tudo o que vai na imagem de resultado.
class ShareCard {
  final ShareBoard board;
  final String title;
  final String subtitle;
  final int? stars;
  final int seconds;
  final int? streak;

  const ShareCard({
    required this.board,
    required this.title,
    required this.subtitle,
    required this.seconds,
    this.stars,
    this.streak,
  });
}

const shareImageSize = Size(1080, 1350);

/// Desenha a imagem de resultado (PNG).
Future<Uint8List> renderShareImage(
  ShareCard card,
  AppLocalizations l,
  BoardTheme theme,
) async {
  final size = shareImageSize;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Offset.zero & size);

  // Fundo em degradê com um toque da cor do tema.
  canvas.drawRect(
    Offset.zero & size,
    Paint()
      ..shader = ui.Gradient.linear(Offset.zero, Offset(0, size.height), [
        const Color(0xFF1B120F),
        Color.lerp(const Color(0xFF3E2723), theme.frame, 0.35)!,
      ]),
  );

  void text(
    String value,
    double y, {
    double size = 40,
    Color color = Colors.white,
    FontWeight weight = FontWeight.w500,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(color: color, fontSize: size, fontWeight: weight),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 2,
    )..layout(maxWidth: shareImageSize.width - 80);
    painter.paint(
      canvas,
      Offset((shareImageSize.width - painter.width) / 2, y),
    );
  }

  text(AppInfo.appName, 60, size: 96, weight: FontWeight.w800);
  text(card.title, 190, size: 46, color: const Color(0xFFFFCC80));
  text(card.subtitle, 252, size: 34, color: const Color(0xB3FFFFFF));

  // Tabuleiro 3D resolvido, levemente girado.
  const boardRect = Rect.fromLTWH(40, 310, 1000, 740);
  canvas.save();
  canvas.translate(boardRect.left, boardRect.top);
  final b = card.board;
  paintBoardScene(
    canvas,
    boardCamera(b.n, boardRect.size, yaw: -0.35, pitch: b.pitch, zoom: 0.86),
    n: b.n,
    theme: theme,
    pieces: b.pieces,
    blocked: b.blocked,
    labels: b.labels,
    marks: b.marks,
  );
  canvas.restore();

  // Estrelas, tempo e sequência.
  var y = 1075.0;
  final stars = card.stars;
  if (stars != null) {
    _icons(
      canvas,
      [
        for (var i = 0; i < 3; i++)
          i < stars ? Icons.star_rounded : Icons.star_border_rounded,
      ],
      y,
      84,
      Colors.amber,
    );
    y += 95;
  }
  final parts = <(IconData, String)>[
    (Icons.timer_outlined, formatTime(card.seconds)),
    if (card.streak != null)
      (Icons.local_fire_department, l.streakLine(card.streak!)),
  ];
  _iconTexts(canvas, parts, y);

  text(l.shareFooter, 1270, size: 32, color: const Color(0x99FFFFFF));

  final picture = recorder.endRecording();
  final image = await picture.toImage(size.width.toInt(), size.height.toInt());
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

TextSpan _iconSpan(IconData icon, double size, Color color) => TextSpan(
  text: String.fromCharCode(icon.codePoint),
  style: TextStyle(
    fontFamily: icon.fontFamily,
    package: icon.fontPackage,
    fontSize: size,
    color: color,
  ),
);

void _icons(
  Canvas canvas,
  List<IconData> icons,
  double y,
  double size,
  Color color,
) {
  final painter = TextPainter(
    text: TextSpan(
      children: [for (final i in icons) _iconSpan(i, size, color)],
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  painter.paint(canvas, Offset((shareImageSize.width - painter.width) / 2, y));
}

void _iconTexts(Canvas canvas, List<(IconData, String)> parts, double y) {
  const color = Colors.white;
  final spans = <InlineSpan>[];
  for (final (icon, label) in parts) {
    if (spans.isNotEmpty) spans.add(const TextSpan(text: '      '));
    spans
      ..add(_iconSpan(icon, 48, const Color(0xFFFFB74D)))
      ..add(
        TextSpan(
          text: ' $label',
          style: const TextStyle(
            color: color,
            fontSize: 44,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
  }
  final painter = TextPainter(
    text: TextSpan(children: spans),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: shareImageSize.width - 80);
  painter.paint(canvas, Offset((shareImageSize.width - painter.width) / 2, y));
}

/// Gera a imagem e abre o menu de compartilhamento do Android.
Future<void> shareResult(BuildContext context, ShareCard card) async {
  final l = context.l10n;
  final png = await renderShareImage(card, l, Progress.instance.theme);
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/8queens_resultado.png');
  await file.writeAsBytes(png);
  await SharePlus.instance.share(
    ShareParams(
      files: [XFile(file.path, mimeType: 'image/png')],
      text: l.shareText(
        card.title,
        formatTime(card.seconds),
        AppInfo.playStoreUrl,
      ),
    ),
  );
}
