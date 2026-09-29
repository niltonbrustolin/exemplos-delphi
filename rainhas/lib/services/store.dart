import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../render3d/themes.dart';
import 'progress.dart';

/// Todos os produtos vendidos no app (cadastre os mesmos IDs na Play
/// Console, como "produtos no app" do tipo não consumível).
final Set<String> storeProducts = {
  removeAdsProduct,
  for (final t in boardThemes)
    if (t.productId != null) t.productId!,
};

/// Compras pela Google Play.
///
/// Observação: as compras só funcionam com o app instalado pela Play Store
/// (trilha de teste ou produção). Num APK instalado à mão, a loja aparece
/// como indisponível.
class Store extends ChangeNotifier {
  Store._();

  static final instance = Store._();

  bool available = false;
  final Map<String, ProductDetails> products = {};
  String? lastError;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  static bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<void> init() async {
    if (!_supported || _sub != null) return;
    try {
      final iap = InAppPurchase.instance;
      _sub = iap.purchaseStream.listen(
        _onPurchases,
        onError: (Object e) {
          lastError = '$e';
          notifyListeners();
        },
      );
      available = await iap.isAvailable();
      if (available) {
        final response = await iap.queryProductDetails(storeProducts);
        for (final p in response.productDetails) {
          products[p.id] = p;
        }
        // Recupera sozinho as compras (ex.: depois de reinstalar o app).
        await iap.restorePurchases();
      }
    } catch (e) {
      available = false;
      lastError = '$e';
    }
    notifyListeners();
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      switch (p.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await Progress.instance.grant(p.productID);
        case PurchaseStatus.error:
          lastError = p.error?.message;
        case PurchaseStatus.pending:
        case PurchaseStatus.canceled:
          break;
      }
      if (p.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(p);
      }
    }
    notifyListeners();
  }

  /// Inicia a compra. O resultado chega depois, pelo fluxo de compras.
  Future<void> buy(String productId) async {
    final product = products[productId];
    if (product == null) return;
    lastError = null;
    await InAppPurchase.instance.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );
  }

  /// Recupera compras feitas antes (ex.: depois de reinstalar o app).
  Future<void> restore() async {
    if (!available) return;
    await InAppPurchase.instance.restorePurchases();
  }

  String? price(String productId) => products[productId]?.price;
}
