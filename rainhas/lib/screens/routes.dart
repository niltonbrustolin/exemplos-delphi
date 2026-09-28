import 'package:flutter/material.dart';

import '../game/levels.dart';
import 'knights_game_screen.dart';
import 'queens_game_screen.dart';
import 'tour_game_screen.dart';

Widget levelScreen(LevelRef level) => switch (level.mode) {
  GameMode.queens => QueensGameScreen.challenge(level: level),
  GameMode.tour => TourGameScreen(level: level),
  GameMode.knights => KnightsGameScreen(level: level),
};

/// Abre a fase; com [replace], substitui a tela atual (botão "Próxima").
Future<void> openLevel(
  BuildContext context,
  LevelRef level, {
  bool replace = false,
}) {
  final route = MaterialPageRoute<void>(builder: (_) => levelScreen(level));
  return replace
      ? Navigator.pushReplacement(context, route)
      : Navigator.push(context, route);
}
