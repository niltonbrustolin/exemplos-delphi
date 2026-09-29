import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rainhas/l10n/l10n.dart';
import 'package:rainhas/main.dart';
import 'package:rainhas/services/progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> pumpHome(WidgetTester tester, String language) async {
  SharedPreferences.setMockInitialValues({
    'language': language,
    'tutorial_seen': true,
  });
  await Progress.load();
  appLanguage.value = language;
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const EightQueensApp());
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  test('os três idiomas têm todas as mensagens', () {
    Set<String> keys(String lang) => (jsonDecode(
      File('lib/l10n/app_$lang.arb').readAsStringSync(),
    ) as Map<String, dynamic>).keys.where((k) => !k.startsWith('@')).toSet();
    final en = keys('en');
    expect(keys('pt'), en);
    expect(keys('es'), en);
  });

  test('idioma sem tradução cai no inglês', () {
    const supported = [Locale('en'), Locale('es'), Locale('pt')];
    expect(resolveLocale([const Locale('fr')], supported), const Locale('en'));
    expect(
      resolveLocale([const Locale('fr'), const Locale('es', 'MX')], supported),
      const Locale('es'),
    );
    expect(
      resolveLocale([const Locale('pt', 'BR')], supported),
      const Locale('pt'),
    );
  });

  testWidgets('tela inicial em inglês', (tester) async {
    await pumpHome(tester, 'en');
    expect(find.text('Classic Mode'), findsOneWidget);
    expect(find.text('Daily Challenge'), findsOneWidget);
  });

  testWidgets('tela inicial em espanhol', (tester) async {
    await pumpHome(tester, 'es');
    expect(find.text('Modo Clásico'), findsOneWidget);
    expect(find.text('Desafío del día'), findsOneWidget);
  });
}
