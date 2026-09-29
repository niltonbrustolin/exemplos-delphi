// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appSubtitle => 'Rompecabezas de ajedrez en 3D';

  @override
  String get sectionQueens => 'Reinas';

  @override
  String get sectionKnight => 'Caballo';

  @override
  String get classicMode => 'Modo Clásico';

  @override
  String get challenges => 'Desafíos';

  @override
  String get store => 'Tienda';

  @override
  String get howToPlay => 'Cómo jugar';

  @override
  String get about => 'Acerca de';

  @override
  String get modeQueensTitle => 'Desafíos de las Reinas';

  @override
  String get modeTourTitle => 'Recorrido del Caballo';

  @override
  String get modeKnightsTitle => 'Caballos en Paz';

  @override
  String get modeQueensShort => 'Reinas';

  @override
  String get modeTourShort => 'Recorrido del Caballo';

  @override
  String get modeKnightsShort => 'Caballos en Paz';

  @override
  String get dailyTitle => 'Desafío del día';

  @override
  String get dailyPlay => 'Jugar';

  @override
  String get dailyDone => '¡Hecho! Vuelve mañana';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Racha de $count días',
      one: 'Racha de 1 día',
      zero: 'Aún sin racha',
    );
    return '$_temp0';
  }

  @override
  String bestStreak(int count) {
    return 'Récord: $count';
  }

  @override
  String get dailyCompleteTitle => '¡Desafío del día completado!';

  @override
  String streakBonus(int hints) {
    return 'Bono de racha: ¡+$hints pistas!';
  }

  @override
  String streakLine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Racha: $count días',
      one: 'Racha: 1 día',
    );
    return '$_temp0';
  }

  @override
  String boardSize(int n) {
    return 'Tablero $n×$n';
  }

  @override
  String get beatPreviousBoard => 'Supera el tablero anterior';

  @override
  String solutionsProgress(int found, int total) {
    return 'Soluciones: $found de $total';
  }

  @override
  String bestTimeSuffix(String time) {
    return ' · récord $time';
  }

  @override
  String get dragHint => 'Arrastra para girar · pellizca para acercar';

  @override
  String get undo => 'Deshacer';

  @override
  String hintButton(int count) {
    return 'Pista ($count)';
  }

  @override
  String get centerCamera => 'Centrar cámara';

  @override
  String get restart => 'Reiniciar';

  @override
  String get showAttacks => 'Mostrar casillas atacadas';

  @override
  String get hideAttacks => 'Ocultar casillas atacadas';

  @override
  String get noHintsTitle => 'Sin pistas';

  @override
  String noHintsVideo(int video, int perLevel) {
    return 'Mira un video corto y gana $video pistas.\n\nTambién ganas $perLevel pista por cada nivel nuevo que superes.';
  }

  @override
  String noHintsNoVideo(int perLevel) {
    return 'No hay videos disponibles ahora. Ganas $perLevel pista por cada nivel nuevo que superes.';
  }

  @override
  String get notNow => 'Ahora no';

  @override
  String get watch => 'Ver';

  @override
  String get levelComplete => '¡Nivel completado!';

  @override
  String timeLine(String time) {
    return 'Tiempo: $time';
  }

  @override
  String hintsUsedLine(int count) {
    return 'Pistas usadas: $count';
  }

  @override
  String hintReward(int count) {
    return '¡+$count pista de premio!';
  }

  @override
  String boardUnlocked(int n) {
    return '¡Tablero $n×$n desbloqueado!';
  }

  @override
  String get modeCompleted => '¡Completaste todos los niveles de este modo!';

  @override
  String get menu => 'Menú';

  @override
  String get playAgain => 'Jugar de nuevo';

  @override
  String get nextLevel => 'Siguiente';

  @override
  String levelTitle(int number, int n) {
    return 'Nivel $number · $n×$n';
  }

  @override
  String classicTitle(int n) {
    return 'Clásico $n×$n';
  }

  @override
  String get newSolution => '¡Nueva solución!';

  @override
  String get solved => '¡Resuelto!';

  @override
  String get alreadyFound => 'Ya habías encontrado esta solución.';

  @override
  String solutionsFoundLine(int found, int total) {
    return 'Soluciones encontradas: $found de $total';
  }

  @override
  String get newRecord => '¡Nuevo récord de tiempo!';

  @override
  String get hintPlaceQueen =>
      'Intenta poner una reina en la casilla resaltada.';

  @override
  String get hintRemoveQueen =>
      'La reina resaltada no forma parte de la solución.';

  @override
  String get hintPlaceKnight =>
      'Intenta poner un caballo en la casilla resaltada.';

  @override
  String get hintRemoveKnight => 'Quita el caballo resaltado.';

  @override
  String get tourVisited => 'Esa casilla ya fue visitada.';

  @override
  String get tourLMove =>
      'El caballo se mueve en \"L\": elige una casilla verde.';

  @override
  String get tourStuck => '¡Sin salida! Deshaz algunos movimientos.';

  @override
  String get tourHintJump => 'Salta a la casilla resaltada.';

  @override
  String tourHintBack(int count, int square) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Este camino no tiene salida. Deshaz $count movimientos (vuelve a la casilla $square).',
      one:
          'Este camino no tiene salida. Deshaz 1 movimiento (vuelve a la casilla $square).',
    );
    return '$_temp0';
  }

  @override
  String get storeUnavailable =>
      'Las compras estarán disponibles cuando la app se instale desde Google Play.';

  @override
  String purchaseError(String error) {
    return 'Error en la compra: $error';
  }

  @override
  String get hintsSection => 'Pistas';

  @override
  String youHaveHints(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tienes $count pistas',
      one: 'Tienes 1 pista',
    );
    return '$_temp0';
  }

  @override
  String hintsEarnInfo(int perLevel, int video) {
    return 'Gana $perLevel pista por cada nivel nuevo superado, o $video viendo un video.';
  }

  @override
  String get adsSection => 'Anuncios';

  @override
  String get removeAds => 'Quitar anuncios';

  @override
  String get removeAdsInfo =>
      'Quita el banner y los anuncios entre niveles. Los videos que dan pistas siguen siendo opcionales.';

  @override
  String get themesSection => 'Temas';

  @override
  String get purchased => 'Comprado';

  @override
  String get unavailable => 'No disponible';

  @override
  String get inUse => 'En uso';

  @override
  String get useTheme => 'Usar';

  @override
  String get tapToPreview => 'Toca para ver la vista previa';

  @override
  String freeWithStars(int count) {
    return 'Gratis con $count estrellas';
  }

  @override
  String get free => 'Gratis';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String themeTitle(String name) {
    return 'Tema $name';
  }

  @override
  String get close => 'Cerrar';

  @override
  String plusHints(int count) {
    return '¡+$count pistas!';
  }

  @override
  String get themeWood => 'Madera';

  @override
  String get themeTournament => 'Torneo';

  @override
  String get themeMarble => 'Mármol';

  @override
  String get themeNeon => 'Neón';

  @override
  String version(String version) {
    return 'Versión $version';
  }

  @override
  String get developedBy => 'Desarrollado por';

  @override
  String get contact => 'Contacto';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get licenses => 'Licencias de software';

  @override
  String get aboutInspiration =>
      'Inspirado en el problema de las ocho reinas, propuesto en 1848 por Max Bezzel, y en el recorrido del caballo, estudiado por Euler.';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Predeterminado del teléfono';

  @override
  String get gotIt => 'Entendido';

  @override
  String get helpQueens =>
      'Coloca N reinas en un tablero N×N sin que ninguna ataque a otra. La reina ataca en línea recta: en su fila, en su columna y en sus diagonales.\n\n• Toca una casilla para poner o quitar una reina.\n• Las reinas en rojo se están atacando.\n• El botón del ojo marca las casillas atacadas.';

  @override
  String get helpClassic =>
      'Modo Clásico: el tablero empieza vacío y no hay niveles. Cada tamaño tiene varias soluciones — en el 8×8 hay 92. ¿Cuántas puedes encontrar?';

  @override
  String get helpChallenge =>
      'Desafíos: algunas reinas (oscuras) ya están fijas y solo hay una forma de completar el tablero.';

  @override
  String get helpTour =>
      'Recorrido del Caballo: el caballo se mueve en \"L\" — dos casillas en una dirección y una hacia el lado. Visita TODAS las casillas libres del tablero, una sola vez cada una.\n\n• El caballo empieza en la casilla marcada con 1.\n• Toca una de las casillas verdes para saltar a ella.\n• Los números muestran el orden de tu camino.\n• Las casillas con bloque no se pueden usar.\n• Si te quedas sin salida, usa Deshacer.';

  @override
  String get helpKnights =>
      'Caballos en Paz: coloca la cantidad pedida de caballos sin que ninguno ataque a otro. El caballo ataca las casillas a una \"L\" de distancia.\n\n• Toca una casilla para poner o quitar un caballo.\n• Los caballos en rojo se están atacando.\n• Las casillas con bloque no se pueden usar.\n• La cantidad pedida es siempre el máximo posible en ese tablero.';

  @override
  String get helpProgress =>
      'Niveles: supera un nivel para desbloquear el siguiente. Al superar todos los niveles de un tablero, se desbloquea el siguiente tablero.\n\nEstrellas: 3 sin pistas, 2 con una pista, 1 con más pistas.\n\nPistas: cada nivel nuevo superado da 1 pista. Si te quedas sin pistas, puedes ver un video para ganar más.';

  @override
  String get helpDaily =>
      'Desafío del día: un rompecabezas nuevo cada día, igual para todos los jugadores. Juega todos los días para aumentar tu racha — cada 7 días seguidos ganas pistas de bono.';
}
