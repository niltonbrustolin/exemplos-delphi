import 'package:flutter/material.dart';

import '../widgets/board_3d.dart';
import 'challenge_select_screen.dart';
import 'classic_select_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: SpinningQueen(size: 170)),
                  const SizedBox(height: 12),
                  Text(
                    'Rainhas',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'O clássico quebra-cabeça do xadrez',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 48),
                  _MenuButton(
                    icon: Icons.grid_on,
                    label: 'Modo Clássico',
                    onPressed: () => _go(context, const ClassicSelectScreen()),
                  ),
                  _MenuButton(
                    icon: Icons.extension,
                    label: 'Desafios',
                    onPressed: () =>
                        _go(context, const ChallengeSelectScreen()),
                  ),
                  _MenuButton(
                    icon: Icons.help_outline,
                    label: 'Como jogar',
                    outlined: true,
                    onPressed: () => showHowToPlay(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _go(BuildContext context, Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool outlined;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = ButtonStyle(
      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 18)),
      textStyle: WidgetStatePropertyAll(
        Theme.of(context).textTheme.titleMedium,
      ),
    );
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Icon(icon), const SizedBox(width: 12), Text(label)],
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: outlined
          ? OutlinedButton(style: style, onPressed: onPressed, child: child)
          : FilledButton(style: style, onPressed: onPressed, child: child),
    );
  }
}

void showHowToPlay(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Como jogar'),
      content: const SingleChildScrollView(
        child: Text(
          'Coloque N rainhas num tabuleiro N×N sem que nenhuma ataque outra.\n\n'
          'A rainha ataca em linha reta: na mesma linha, na mesma coluna e '
          'nas diagonais.\n\n'
          '• Toque numa casa para colocar ou tirar uma rainha.\n'
          '• Arraste para girar o tabuleiro e use dois dedos para aproximar.\n'
          '• Rainhas em vermelho estão se atacando.\n'
          '• O botão de olho marca as casas que estão sob ataque.\n'
          '• Use a Dica quando travar.\n\n'
          'Modo Clássico: o tabuleiro começa vazio. Existem várias soluções '
          'para cada tamanho — no 8×8 são 92. Quantas você consegue achar?\n\n'
          'Desafios: algumas rainhas (em cinza) já vêm fixas e só existe um '
          'jeito de completar o tabuleiro. Termine sem dicas para ganhar '
          '3 estrelas.',
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Entendi'),
        ),
      ],
    ),
  );
}
