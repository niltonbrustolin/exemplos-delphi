import 'package:flutter/material.dart';

import 'config/app_info.dart';
import 'screens/home_screen.dart';
import 'services/ads.dart';
import 'services/progress.dart';
import 'services/store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Progress.load();
  runApp(const EightQueensApp());
  // Anúncios e loja carregam em segundo plano para não atrasar a abertura.
  Ads.init();
  Store.instance.init();
}

class EightQueensApp extends StatelessWidget {
  const EightQueensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppInfo.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6D4C41),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
