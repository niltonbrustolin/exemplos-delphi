import 'package:flutter/material.dart';

import '../game/board.dart';
import '../l10n/l10n.dart';
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
      if (mounted) showSnack(context, context.l10n.plusHints(hintsPerVideo));
    }
    if (mounted) setState(() {});
  }

  Widget _buyButton(String productId) {
    if (Progress.instance.owns(productId)) {
      return Chip(
        avatar: const Icon(Icons.check, size: 18),
        label: Text(context.l10n.purchased),
      );
    }
    final price = store.price(productId);
    return FilledButton(
      onPressed: price == null ? null : () => store.buy(productId),
      child: Text(price ?? context.l10n.unavailable),
    );
  }

  void _preview(BoardTheme theme) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.themeTitle(context.l10n.themeName(theme))),
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
            child: Text(context.l10n.close),
          ),
        ],
      ),
    );
  }

  Widget _themeAction(BoardTheme theme) {
    final progress = Progress.instance;
    if (progress.theme.id == theme.id) {
      return Chip(label: Text(context.l10n.inUse));
    }
    if (progress.isThemeUnlocked(theme)) {
      return FilledButton(
        onPressed: () => setState(() => progress.theme = theme),
        child: Text(context.l10n.useTheme),
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
    final l = context.l10n;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: Text(l.store)),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!store.available)
              Card(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l.storeUnavailable),
                ),
              ),
            if (store.lastError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  l.purchaseError(store.lastError!),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            Text(l.hintsSection, style: textTheme.titleLarge),
            Card(
              child: ListTile(
                leading: const Icon(Icons.lightbulb, size: 36),
                title: Text(l.youHaveHints(progress.hints)),
                subtitle: Text(
                  l.hintsEarnInfo(hintsPerNewLevel, hintsPerVideo),
                ),
                trailing: FilledButton.icon(
                  onPressed: Ads.rewardedReady ? _watchVideo : null,
                  icon: const Icon(Icons.play_circle_outline),
                  label: Text('+$hintsPerVideo'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(l.adsSection, style: textTheme.titleLarge),
            Card(
              child: ListTile(
                leading: const Icon(Icons.block, size: 36),
                title: Text(l.removeAds),
                subtitle: Text(l.removeAdsInfo),
                trailing: _buyButton(removeAdsProduct),
              ),
            ),
            const SizedBox(height: 16),
            Text(l.themesSection, style: textTheme.titleLarge),
            for (final theme in boardThemes)
              Card(
                child: ListTile(
                  onTap: () => _preview(theme),
                  leading: _Swatch(theme),
                  title: Text(l.themeName(theme)),
                  subtitle: Text(
                    theme.productId != null
                        ? l.tapToPreview
                        : theme.starsRequired > 0
                        ? l.freeWithStars(theme.starsRequired)
                        : l.free,
                  ),
                  trailing: _themeAction(theme),
                ),
              ),
            const SizedBox(height: 16),
            Center(
              child: TextButton.icon(
                onPressed: store.available ? store.restore : null,
                icon: const Icon(Icons.restore),
                label: Text(l.restorePurchases),
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
