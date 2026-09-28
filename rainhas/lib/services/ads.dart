import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'progress.dart';

/// IDs dos blocos de anúncio do AdMob.
///
/// Os valores abaixo são os IDs de TESTE oficiais do Google. Antes de
/// publicar, troque pelos IDs do seu app no AdMob (veja o README). Nunca
/// clique nos seus próprios anúncios reais: o AdMob pode bloquear a conta.
class AdIds {
  static const banner = 'ca-app-pub-3940256099942544/6300978111';
  static const interstitial = 'ca-app-pub-3940256099942544/1033173712';
}

/// Mostra um anúncio de tela cheia a cada tantas vitórias.
const winsPerInterstitial = 3;

class Ads {
  Ads._();

  static bool _ready = false;
  static InterstitialAd? _interstitial;

  static bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Pede o consentimento do usuário (exigido na Europa/LGPD pelo Google)
  /// e inicializa o SDK de anúncios.
  static Future<void> init() async {
    if (!_supported) return;
    final done = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () => ConsentForm.loadAndShowConsentFormIfRequired((_) {
        if (!done.isCompleted) done.complete();
      }),
      (_) {
        if (!done.isCompleted) done.complete();
      },
    );
    await done.future;
    if (!await ConsentInformation.instance.canRequestAds()) return;
    await MobileAds.instance.initialize();
    _ready = true;
    _loadInterstitial();
  }

  static void _loadInterstitial() {
    if (!_ready) return;
    InterstitialAd.load(
      adUnitId: AdIds.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (_) => _interstitial = null,
      ),
    );
  }

  /// Chamado a cada vitória; mostra o anúncio de tela cheia quando chega a
  /// vez dele.
  static void onWin() {
    final wins = Progress.instance.winsSinceAd + 1;
    final ad = _interstitial;
    if (wins < winsPerInterstitial || ad == null) {
      Progress.instance.winsSinceAd = wins;
      return;
    }
    Progress.instance.winsSinceAd = 0;
    _interstitial = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _loadInterstitial();
      },
    );
    ad.show();
  }
}

/// Banner fixo no rodapé da tela. Não ocupa espaço se o anúncio não carregar.
class BannerAdBox extends StatefulWidget {
  const BannerAdBox({super.key});

  @override
  State<BannerAdBox> createState() => _BannerAdBoxState();
}

class _BannerAdBoxState extends State<BannerAdBox> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    if (!Ads._ready) return;
    _ad = BannerAd(
      adUnitId: AdIds.banner,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _loaded = true),
        onAdFailedToLoad: (ad, _) => ad.dispose(),
      ),
    )..load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (ad == null || !_loaded) return const SizedBox.shrink();
    return SafeArea(
      top: false,
      child: SizedBox(
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      ),
    );
  }
}
