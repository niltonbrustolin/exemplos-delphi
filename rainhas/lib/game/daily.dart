import 'levels.dart';

/// Número do dia (dias desde 1970), pela data local do aparelho.
int dayNumber(DateTime date) =>
    DateTime.utc(date.year, date.month, date.day).millisecondsSinceEpoch ~/
    Duration.millisecondsPerDay;

int get today => dayNumber(DateTime.now());

/// Desafio do dia: igual para todos os jogadores, alternando os modos.
LevelRef dailyLevel(int day) => switch (GameMode.values[day % 3]) {
  // Fases "avançadas" (sem rainhas extras de ajuda) num 8×8.
  GameMode.queens => LevelRef(
    GameMode.queens,
    8,
    10,
    variant: day,
    daily: true,
  ),
  // Passeio 6×6 ou 7×7 com casas bloqueadas.
  GameMode.tour => LevelRef(
    GameMode.tour,
    day.isEven ? 6 : 7,
    6,
    variant: day,
    daily: true,
  ),
  GameMode.knights => LevelRef(
    GameMode.knights,
    7,
    5,
    variant: day,
    daily: true,
  ),
};

/// Dias seguidos que dão bônus de dicas.
const streakBonusEvery = 7;

/// Dicas de bônus a cada [streakBonusEvery] dias seguidos.
const streakBonusHints = 3;
