import 'package:flutter/material.dart';

import '../config/app_info.dart';
import '../game/levels.dart';
import '../services/progress.dart';
import '../widgets/board_3d.dart';
import 'about_screen.dart';
import 'classic_select_screen.dart';
import 'help.dart';
import 'level_select_screen.dart';
import 'store_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _go(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    if (mounted) setState(() {}); // atualiza dicas e estrelas
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = Progress.instance;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Chip(
                      avatar: const Icon(Icons.lightbulb, size: 18),
                      label: Text('${progress.hints}'),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      avatar: const Icon(
                        Icons.star_rounded,
                        size: 18,
                        color: Colors.amber,
                      ),
                      label: Text('${progress.totalStars}'),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SpinningPiece(size: 120, color: progress.theme.player),
                    SpinningPiece(
                      size: 120,
                      color: progress.theme.player,
                      kind: PieceKind.knight,
                    ),
                  ],
                ),
                Text(
                  AppInfo.appName,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Quebra-cabeças de xadrez em 3D',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 24),
                _Section('Rainhas'),
                _MenuButton(
                  icon: Icons.grid_on,
                  label: 'Modo Clássico',
                  onPressed: () => _go(const ClassicSelectScreen()),
                ),
                _MenuButton(
                  icon: Icons.extension,
                  label: 'Desafios',
                  onPressed: () =>
                      _go(const LevelSelectScreen(mode: GameMode.queens)),
                ),
                _Section('Cavalo'),
                _MenuButton(
                  icon: Icons.route,
                  label: 'Passeio do Cavalo',
                  onPressed: () =>
                      _go(const LevelSelectScreen(mode: GameMode.tour)),
                ),
                _MenuButton(
                  icon: Icons.shield_outlined,
                  label: 'Cavalos sem Ataque',
                  onPressed: () =>
                      _go(const LevelSelectScreen(mode: GameMode.knights)),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _IconAction(
                      icon: Icons.storefront,
                      label: 'Loja',
                      onTap: () => _go(const StoreScreen()),
                    ),
                    _IconAction(
                      icon: Icons.help_outline,
                      label: 'Como jogar',
                      onTap: () => showAllHelp(context),
                    ),
                    _IconAction(
                      icon: Icons.info_outline,
                      label: 'Sobre',
                      onTap: () => _go(const AboutScreen()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String text;

  const _Section(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 8, left: 4),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall),
  );
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: FilledButton(
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(vertical: 16),
          ),
          textStyle: WidgetStatePropertyAll(
            Theme.of(context).textTheme.titleMedium,
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(icon), const SizedBox(width: 12), Text(label)],
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _IconAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Icon(icon, size: 30),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );
  }
}
