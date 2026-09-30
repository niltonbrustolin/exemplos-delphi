import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import 'config/app_info.dart';
import 'l10n/l10n.dart';
import 'screens/home_screen.dart';
import 'services/ads.dart';
import 'services/progress.dart';
import 'services/store.dart';
import 'widgets/board_3d.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Progress.load();
  appLanguage.value = languageFromUrl() ?? Progress.instance.language;
  boardFlat.value = Progress.instance.flatBoard;
  // No navegador, liga a acessibilidade desde o início: os botões e as casas
  // do tabuleiro viram elementos que o leitor de tela e o teclado encontram.
  if (kIsWeb) SemanticsBinding.instance.ensureSemantics();
  runApp(const EightQueensApp());
  // Anúncios e loja carregam em segundo plano para não atrasar a abertura.
  Ads.init();
  Store.instance.init();
}

class EightQueensApp extends StatelessWidget {
  const EightQueensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLanguage,
      builder: (context, language, _) => MaterialApp(
        title: AppInfo.appName,
        debugShowCheckedModeBanner: false,
        locale: language.isEmpty ? null : Locale(language),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        localeListResolutionCallback: resolveLocale,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6D4C41),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
