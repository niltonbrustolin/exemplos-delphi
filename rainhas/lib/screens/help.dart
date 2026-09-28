import 'package:flutter/material.dart';

import '../game/levels.dart';

const _queenRules =
    'Coloque N rainhas num tabuleiro N×N sem que nenhuma ataque outra. A '
    'rainha ataca em linha reta: na mesma linha, na mesma coluna e nas '
    'diagonais.\n\n'
    '• Toque numa casa para colocar ou tirar uma rainha.\n'
    '• Rainhas em vermelho estão se atacando.\n'
    '• O botão de olho marca as casas que estão sob ataque.';

const _classicRules =
    'Modo Clássico: o tabuleiro começa vazio e não há fases. Cada tamanho '
    'tem várias soluções — no 8×8 são 92. Quantas você consegue achar?';

const _challengeRules =
    'Desafios: algumas rainhas (escuras) já vêm fixas e só existe um jeito '
    'de completar o tabuleiro.';

const _tourRules =
    'Passeio do Cavalo: o cavalo anda em "L" — duas casas numa direção e '
    'uma para o lado. Passe por TODAS as casas livres do tabuleiro, uma única '
    'vez cada.\n\n'
    '• O cavalo começa numa casa marcada com 1.\n'
    '• Toque numa das casas verdes para pular até ela.\n'
    '• Os números mostram a ordem do seu caminho.\n'
    '• Casas com bloco não podem ser usadas.\n'
    '• Se ficar sem saída, use Desfazer.';

const _knightsRules =
    'Cavalos sem Ataque: coloque a quantidade pedida de cavalos sem que '
    'nenhum ataque outro. O cavalo ataca as casas a um "L" de distância.\n\n'
    '• Toque numa casa para colocar ou tirar um cavalo.\n'
    '• Cavalos em vermelho estão se atacando.\n'
    '• Casas com bloco não podem ser usadas.\n'
    '• A quantidade pedida é sempre o máximo possível naquele tabuleiro.';

const _progressRules =
    'Fases: vença uma fase para liberar a próxima. Vencendo todas as fases '
    'de um tabuleiro, o tabuleiro seguinte é liberado.\n\n'
    'Estrelas: 3 sem dicas, 2 com uma dica, 1 com mais dicas.\n\n'
    'Dicas: cada fase nova vencida dá 1 dica. Sem dicas, você pode assistir a '
    'um vídeo para ganhar mais.';

void _show(BuildContext context, String title, String text) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(child: Text(text)),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Entendi'),
        ),
      ],
    ),
  );
}

void showClassicHelp(BuildContext context) =>
    _show(context, 'Como jogar', '$_queenRules\n\n$_classicRules');

void showModeHelp(BuildContext context, GameMode mode) =>
    _show(context, mode.title, switch (mode) {
      GameMode.queens => '$_queenRules\n\n$_challengeRules',
      GameMode.tour => _tourRules,
      GameMode.knights => _knightsRules,
    });

void showAllHelp(BuildContext context) => _show(
  context,
  'Como jogar',
  '$_queenRules\n\n$_classicRules\n\n$_challengeRules\n\n$_tourRules\n\n'
      '$_knightsRules\n\n$_progressRules',
);
