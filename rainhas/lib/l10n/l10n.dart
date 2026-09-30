import 'package:flutter/widgets.dart';

import '../game/levels.dart';
import '../render3d/themes.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension ModeNames on AppLocalizations {
  String modeTitle(GameMode mode) => switch (mode) {
    GameMode.queens => modeQueensTitle,
    GameMode.tour => modeTourTitle,
    GameMode.knights => modeKnightsTitle,
  };

  String modeShort(GameMode mode) => switch (mode) {
    GameMode.queens => modeQueensShort,
    GameMode.tour => modeTourShort,
    GameMode.knights => modeKnightsShort,
  };

  String themeName(BoardTheme theme) => switch (theme.id) {
    'torneio' => themeTournament,
    'marmore' => themeMarble,
    'neon' => themeNeon,
    _ => themeWood,
  };
}

/// Idioma escolhido pelo jogador (`''` = o do aparelho). O app se
/// reconstrói quando ele muda.
final appLanguage = ValueNotifier<String>('');

/// Idiomas oferecidos no seletor, com o nome de cada um no próprio idioma.
const languageNames = {'pt': 'Português', 'en': 'English', 'es': 'Español'};

/// Idioma pedido no endereço (`.../jogar/?lang=pt`), se o app tiver ele.
/// Vale só para a visita; não muda a escolha salva.
String? languageFromUrl([Uri? url]) {
  final lang = (url ?? Uri.base).queryParameters['lang']?.toLowerCase();
  if (lang == null || lang.length < 2) return null;
  final code = lang.substring(0, 2);
  return languageNames.containsKey(code) ? code : null;
}

/// Usa o idioma do aparelho se o app tiver tradução; senão, inglês.
Locale resolveLocale(List<Locale>? preferred, Iterable<Locale> supported) {
  for (final locale in preferred ?? const <Locale>[]) {
    if (supported.any((s) => s.languageCode == locale.languageCode)) {
      return Locale(locale.languageCode);
    }
  }
  return const Locale('en');
}
