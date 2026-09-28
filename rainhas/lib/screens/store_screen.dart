import 'package:flutter/material.dart';

import '../game/board.dart';
import '../render3d/themes.dart';
import '../services/ads.dart';
import '../services/progress.dart';
import '../services/store.dart';
import '../widgets/board_3d.dart';
import '../widgets/game_ui.dart';

/// Loja: dicas, remover anúncios e temas.
class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final store = Store.instance;

  Future<void> _watchVideo() async {
    if (await Ads.showRewarded()) {
      await Progress.instance.addHints(hintsPerVideo);
      if (mounted) showSnack(context, '+$hintsPerVideo dicas!');
    }
    if (mounted) setState(() {});
  }

  Widget _buyButton(String productId) {
    if (Progress.instance.owns(productId)) {
      return const Chip(
        avatar: Icon(Icons.check, size: 18),
        label: Text('Comprado'),
      );
    }
    final price = store.price(productId);
    return FilledButton(
      onPressed: price == null ? null : () => store.buy(productId),
      child: Text(price ?? 'Indisponível'),
    );
  }

  void _preview(BoardTheme theme) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tema ${theme.name}'),
        contentPadding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
        content: SizedBox(
          width: 320,
          height: 320,
          child: Board3D(
            n: 5,
            theme: theme,
            pitch: knightPitch,
            blocked: {const Pos(2, 4)},
            pieces: const [
              BoardPiece(1, Pos(0, 1), PieceKind.queen, PieceRole.player),
              BoardPiece(2, Pos(1, 3), PieceKind.queen, PieceRole.fixed),
              BoardPiece(3, Pos(3, 2), PieceKind.knight, PieceRole.player),
              BoardPiece(4, Pos(4, 4), PieceKind.knight, PieceRole.fixed),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _themeAction(BoardTheme theme) {
    final progress = Progress.instance;
    if (progress.theme.id == theme.id) {
      return const Chip(label: Text('Em uso'));
    }
    if (progress.isThemeUnlocked(theme)) {
      return FilledButton(
        onPressed: () => setState(() => progress.theme = theme),
        child: const Text('Usar'),
      );
    }
    if (theme.productId != null) return _buyButton(theme.productId!);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${progress.totalStars}/${theme.starsRequired}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Icon(Icons.star_rounded, color: Colors.amber),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = Progress.instance;
    final textTheme = Theme.of(context).textTheme;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: const Text('Loja')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!store.available)
              Card(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'As compras ficam disponíveis quando o app é instalado '
                    'pela Google Play.',
                  ),
                ),
              ),
            if (store.lastError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Erro na compra: ${store.lastError}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            Text('Dicas', style: textTheme.titleLarge),
            Card(
              child: ListTile(
                leading: const Icon(Icons.lightbulb, size: 36),
                title: Text('Você tem ${progress.hints} dicas'),
                subtitle: Text(
                  'Ganhe $hintsPerNewLevel dica a cada fase nova vencida, ou '
                  '$hintsPerVideo assistindo a um vídeo.',
                ),
                trailing: FilledButton.icon(
                  onPressed: Ads.rewardedReady ? _watchVideo : null,
                  icon: const Icon(Icons.play_circle_outline),
                  label: Text('+$hintsPerVideo'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Anúncios', style: textTheme.titleLarge),
            Card(
              child: ListTile(
                leading: const Icon(Icons.block, size: 36),
                title: const Text('Remover anúncios'),
                subtitle: const Text(
                  'Tira o banner e os anúncios entre as fases. Os vídeos que '
                  'dão dicas continuam opcionais.',
                ),
                trailing: _buyButton(removeAdsProduct),
              ),
            ),
            const SizedBox(height: 16),
            Text('Temas', style: textTheme.titleLarge),
            for (final theme in boardThemes)
              Card(
                child: ListTile(
                  onTap: () => _preview(theme),
                  leading: _Swatch(theme),
                  title: Text(theme.name),
                  subtitle: Text(
                    theme.productId != null
                        ? 'Toque para ver a prévia'
                        : theme.starsRequired > 0
                        ? 'Grátis com ${theme.starsRequired} estrelas'
                        : 'Grátis',
                  ),
                  trailing: _themeAction(theme),
                ),
              ),
            const SizedBox(height: 16),
            Center(
              child: TextButton.icon(
                onPressed: store.available ? store.restore : null,
                icon: const Icon(Icons.restore),
                label: const Text('Restaurar compras'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  final BoardTheme theme;

  const _Swatch(this.theme);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: theme.frame,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          for (var r = 0; r < 2; r++)
            Expanded(
              child: Row(
                children: [
                  for (var c = 0; c < 2; c++)
                    Expanded(
                      child: Container(
                        color: (r + c).isEven ? theme.light : theme.dark,
                        child: r == c
                            ? Icon(
                                Icons.circle,
                                size: 10,
                                color: r == 0 ? theme.player : theme.fixed,
                              )
                            : null,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
