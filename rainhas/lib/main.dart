import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/ads.dart';
import 'services/progress.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Progress.load();
  runApp(const RainhasApp());
  // Os anúncios carregam em segundo plano para não atrasar a abertura.
  Ads.init();
}

class RainhasApp extends StatelessWidget {
  const RainhasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rainhas',
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
