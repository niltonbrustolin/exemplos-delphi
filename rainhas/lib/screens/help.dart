import 'package:flutter/material.dart';

import '../game/levels.dart';
import '../l10n/l10n.dart';

void _show(BuildContext context, String title, String text) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(child: Text(text)),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.gotIt),
        ),
      ],
    ),
  );
}

void showClassicHelp(BuildContext context) {
  final l = context.l10n;
  _show(context, l.howToPlay, '${l.helpQueens}\n\n${l.helpClassic}');
}

void showModeHelp(BuildContext context, GameMode mode) {
  final l = context.l10n;
  _show(context, l.modeTitle(mode), switch (mode) {
    GameMode.queens => '${l.helpQueens}\n\n${l.helpChallenge}',
    GameMode.tour => l.helpTour,
    GameMode.knights => l.helpKnights,
  });
}

void showAllHelp(BuildContext context) {
  final l = context.l10n;
  _show(
    context,
    l.howToPlay,
    [
      l.helpQueens,
      l.helpClassic,
      l.helpChallenge,
      l.helpTour,
      l.helpKnights,
      l.helpProgress,
      l.helpDaily,
    ].join('\n\n'),
  );
}
