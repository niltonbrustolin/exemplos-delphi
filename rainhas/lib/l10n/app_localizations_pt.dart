// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appSubtitle => 'Quebra-cabeças de xadrez em 3D';

  @override
  String get sectionQueens => 'Rainhas';

  @override
  String get sectionKnight => 'Cavalo';

  @override
  String get classicMode => 'Modo Clássico';

  @override
  String get challenges => 'Desafios';

  @override
  String get store => 'Loja';

  @override
  String get howToPlay => 'Como jogar';

  @override
  String get about => 'Sobre';

  @override
  String get modeQueensTitle => 'Desafios das Rainhas';

  @override
  String get modeTourTitle => 'Passeio do Cavalo';

  @override
  String get modeKnightsTitle => 'Cavalos sem Ataque';

  @override
  String get modeQueensShort => 'Rainhas';

  @override
  String get modeTourShort => 'Passeio do Cavalo';

  @override
  String get modeKnightsShort => 'Cavalos sem Ataque';

  @override
  String get dailyTitle => 'Desafio do dia';

  @override
  String get dailyPlay => 'Jogar';

  @override
  String get dailyDone => 'Feito! Volte amanhã';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sequência de $count dias',
      one: 'Sequência de 1 dia',
      zero: 'Sem sequência ainda',
    );
    return '$_temp0';
  }

  @override
  String bestStreak(int count) {
    return 'Recorde: $count';
  }

  @override
  String get dailyCompleteTitle => 'Desafio do dia concluído!';

  @override
  String streakBonus(int hints) {
    return 'Bônus de sequência: +$hints dicas!';
  }

  @override
  String streakLine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sequência: $count dias',
      one: 'Sequência: 1 dia',
    );
    return '$_temp0';
  }

  @override
  String boardSize(int n) {
    return 'Tabuleiro $n×$n';
  }

  @override
  String get beatPreviousBoard => 'Vença o tabuleiro anterior';

  @override
  String solutionsProgress(int found, int total) {
    return 'Soluções: $found de $total';
  }

  @override
  String bestTimeSuffix(String time) {
    return ' · recorde $time';
  }

  @override
  String get dragHint => 'Arraste para girar · use dois dedos para aproximar';

  @override
  String get undo => 'Desfazer';

  @override
  String hintButton(int count) {
    return 'Dica ($count)';
  }

  @override
  String get centerCamera => 'Centralizar câmera';

  @override
  String get restart => 'Recomeçar';

  @override
  String get showAttacks => 'Mostrar casas atacadas';

  @override
  String get hideAttacks => 'Esconder casas atacadas';

  @override
  String get noHintsTitle => 'Sem dicas';

  @override
  String noHintsVideo(int video, int perLevel) {
    return 'Assista a um vídeo curto e ganhe $video dicas.\n\nVocê também ganha $perLevel dica a cada fase nova que vencer.';
  }

  @override
  String noHintsNoVideo(int perLevel) {
    return 'Nenhum vídeo disponível agora. Você ganha $perLevel dica a cada fase nova que vencer.';
  }

  @override
  String get notNow => 'Agora não';

  @override
  String get watch => 'Assistir';

  @override
  String get levelComplete => 'Fase concluída!';

  @override
  String timeLine(String time) {
    return 'Tempo: $time';
  }

  @override
  String hintsUsedLine(int count) {
    return 'Dicas usadas: $count';
  }

  @override
  String hintReward(int count) {
    return '+$count dica de prêmio!';
  }

  @override
  String boardUnlocked(int n) {
    return 'Tabuleiro $n×$n liberado!';
  }

  @override
  String get modeCompleted => 'Você completou todas as fases deste modo!';

  @override
  String get menu => 'Menu';

  @override
  String get playAgain => 'Jogar de novo';

  @override
  String get nextLevel => 'Próxima';

  @override
  String levelTitle(int number, int n) {
    return 'Fase $number · $n×$n';
  }

  @override
  String classicTitle(int n) {
    return 'Clássico $n×$n';
  }

  @override
  String get newSolution => 'Nova solução!';

  @override
  String get solved => 'Resolvido!';

  @override
  String get alreadyFound => 'Você já tinha encontrado esta solução.';

  @override
  String solutionsFoundLine(int found, int total) {
    return 'Soluções encontradas: $found de $total';
  }

  @override
  String get newRecord => 'Novo recorde de tempo!';

  @override
  String get hintPlaceQueen => 'Tente colocar uma rainha na casa destacada.';

  @override
  String get hintRemoveQueen => 'A rainha destacada não faz parte da solução.';

  @override
  String get hintPlaceKnight => 'Tente colocar um cavalo na casa destacada.';

  @override
  String get hintRemoveKnight => 'Tire o cavalo destacado.';

  @override
  String get tourVisited => 'Essa casa já foi visitada.';

  @override
  String get tourLMove => 'O cavalo anda em \"L\": escolha uma casa verde.';

  @override
  String get tourStuck => 'Sem saída! Desfaça algumas jogadas.';

  @override
  String get tourHintJump => 'Pule para a casa destacada.';

  @override
  String tourHintBack(int count, int square) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Este caminho não fecha. Desfaça $count jogadas (volte até a casa $square).',
      one:
          'Este caminho não fecha. Desfaça 1 jogada (volte até a casa $square).',
    );
    return '$_temp0';
  }

  @override
  String get storeUnavailable =>
      'As compras ficam disponíveis quando o app é instalado pela Google Play.';

  @override
  String purchaseError(String error) {
    return 'Erro na compra: $error';
  }

  @override
  String get hintsSection => 'Dicas';

  @override
  String youHaveHints(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Você tem $count dicas',
      one: 'Você tem 1 dica',
    );
    return '$_temp0';
  }

  @override
  String hintsEarnInfo(int perLevel, int video) {
    return 'Ganhe $perLevel dica a cada fase nova vencida, ou $video assistindo a um vídeo.';
  }

  @override
  String get adsSection => 'Anúncios';

  @override
  String get removeAds => 'Remover anúncios';

  @override
  String get removeAdsInfo =>
      'Tira o banner e os anúncios entre as fases. Os vídeos que dão dicas continuam opcionais.';

  @override
  String get themesSection => 'Temas';

  @override
  String get purchased => 'Comprado';

  @override
  String get unavailable => 'Indisponível';

  @override
  String get inUse => 'Em uso';

  @override
  String get useTheme => 'Usar';

  @override
  String get tapToPreview => 'Toque para ver a prévia';

  @override
  String freeWithStars(int count) {
    return 'Grátis com $count estrelas';
  }

  @override
  String get free => 'Grátis';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String themeTitle(String name) {
    return 'Tema $name';
  }

  @override
  String get close => 'Fechar';

  @override
  String plusHints(int count) {
    return '+$count dicas!';
  }

  @override
  String get themeWood => 'Madeira';

  @override
  String get themeTournament => 'Torneio';

  @override
  String get themeMarble => 'Mármore';

  @override
  String get themeNeon => 'Neon';

  @override
  String version(String version) {
    return 'Versão $version';
  }

  @override
  String get developedBy => 'Desenvolvido por';

  @override
  String get contact => 'Contato';

  @override
  String get privacyPolicy => 'Política de privacidade';

  @override
  String get licenses => 'Licenças de software';

  @override
  String get aboutInspiration =>
      'Inspirado no problema das oito rainhas, proposto em 1848 por Max Bezzel, e no passeio do cavalo, estudado por Euler.';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Padrão do celular';

  @override
  String get gotIt => 'Entendi';

  @override
  String get helpQueens =>
      'Coloque N rainhas num tabuleiro N×N sem que nenhuma ataque outra. A rainha ataca em linha reta: na mesma linha, na mesma coluna e nas diagonais.\n\n• Toque numa casa para colocar ou tirar uma rainha.\n• Rainhas em vermelho estão se atacando.\n• O botão de olho marca as casas que estão sob ataque.';

  @override
  String get helpClassic =>
      'Modo Clássico: o tabuleiro começa vazio e não há fases. Cada tamanho tem várias soluções — no 8×8 são 92. Quantas você consegue achar?';

  @override
  String get helpChallenge =>
      'Desafios: algumas rainhas (escuras) já vêm fixas e só existe um jeito de completar o tabuleiro.';

  @override
  String get helpTour =>
      'Passeio do Cavalo: o cavalo anda em \"L\" — duas casas numa direção e uma para o lado. Passe por TODAS as casas livres do tabuleiro, uma única vez cada.\n\n• O cavalo começa na casa marcada com 1.\n• Toque numa das casas verdes para pular até ela.\n• Os números mostram a ordem do seu caminho.\n• Casas com bloco não podem ser usadas.\n• Se ficar sem saída, use Desfazer.';

  @override
  String get helpKnights =>
      'Cavalos sem Ataque: coloque a quantidade pedida de cavalos sem que nenhum ataque outro. O cavalo ataca as casas a um \"L\" de distância.\n\n• Toque numa casa para colocar ou tirar um cavalo.\n• Cavalos em vermelho estão se atacando.\n• Casas com bloco não podem ser usadas.\n• A quantidade pedida é sempre o máximo possível naquele tabuleiro.';

  @override
  String get helpProgress =>
      'Fases: vença uma fase para liberar a próxima. Vencendo todas as fases de um tabuleiro, o tabuleiro seguinte é liberado.\n\nEstrelas: 3 sem dicas, 2 com uma dica, 1 com mais dicas.\n\nDicas: cada fase nova vencida dá 1 dica. Sem dicas, você pode assistir a um vídeo para ganhar mais.';

  @override
  String get helpDaily =>
      'Desafio do dia: um quebra-cabeça novo por dia, igual para todos os jogadores. Jogue todo dia para aumentar sua sequência — a cada 7 dias seguidos você ganha dicas de bônus.';

  @override
  String get shareButton => 'Compartilhar';

  @override
  String shareText(String what, String time, String link) {
    return 'Resolvi $what em $time no 8 Queens! Consegue fazer melhor? $link';
  }

  @override
  String get shareFooter => 'Jogue grátis no Google Play';

  @override
  String get starterPackTitle => 'Pacote Inicial';

  @override
  String starterPackDesc(int hints) {
    return 'Sem anúncios + temas Mármore e Neon + $hints dicas';
  }

  @override
  String get starterOfferTitle => 'Oferta especial!';

  @override
  String get starterOfferBody =>
      'Você está indo muito bem! Leve tudo num pacote por menos do que comprando cada item separado.';

  @override
  String get bestValue => 'Melhor oferta';

  @override
  String get demoTapToPlace => 'Toque numa casa para colocar uma rainha';

  @override
  String get demoConflict => 'Peças vermelhas estão se atacando';

  @override
  String get demoTapToRemove => 'Toque de novo para tirar';

  @override
  String get demoSolved => 'Ninguém é atacado: resolvido!';

  @override
  String get demoKnightL => 'O cavalo pula em \"L\": toque numa casa verde';

  @override
  String get demoVisitAll => 'Passe por todas as casas uma única vez';

  @override
  String get demoKnightsGoal => 'Coloque o máximo de cavalos';

  @override
  String get demoBlocked => 'Casas com bloco não podem ser usadas';

  @override
  String get tutorialQueens =>
      'Coloque as rainhas sem que duas fiquem na mesma linha, coluna ou diagonal.';

  @override
  String get tutorialTour =>
      'Leve o cavalo por todas as casas livres do tabuleiro, um pulo de cada vez.';

  @override
  String get tutorialKnights =>
      'Encha o tabuleiro de cavalos, mas nenhum pode atacar outro.';

  @override
  String get tutorialSkip => 'Pular';

  @override
  String get tutorialNext => 'Próximo';

  @override
  String get tutorialStart => 'Vamos jogar!';

  @override
  String get tutorialAllRules => 'Ver todas as regras';

  @override
  String get welcomeTitle => 'Novo por aqui?';

  @override
  String get welcomeBody =>
      'São três jogos de lógica no tabuleiro. Escolha um abaixo para começar agora, ou veja como jogar em 30 segundos.';

  @override
  String get welcomeHowTo => 'Ver como jogar';

  @override
  String get welcomeDismiss => 'Entendi';

  @override
  String get classicDesc =>
      'Tabuleiro vazio, sem fases: ache todas as soluções.';

  @override
  String get challengesDesc => 'Fases com rainhas fixas e uma única solução.';

  @override
  String get tutorialPlayMode => 'Jogar este modo';

  @override
  String get view2d => 'Vista 2D (plana)';

  @override
  String get view3d => 'Vista 3D';

  @override
  String get tapHint => 'Toque numa casa para jogar';

  @override
  String a11yBoard(int n) {
    return 'Tabuleiro $n por $n. Use as setas para escolher a casa e Enter para jogar.';
  }

  @override
  String get a11yEmpty => 'vazia';

  @override
  String get a11yQueen => 'rainha';

  @override
  String get a11yFixedQueen => 'rainha fixa';

  @override
  String get a11yKnight => 'cavalo';

  @override
  String get a11yConflict => 'em conflito';

  @override
  String get a11yBlocked => 'bloqueada';

  @override
  String a11yStep(int step) {
    return 'passo $step';
  }

  @override
  String get a11yAttacked => 'atacada';

  @override
  String get a11yCanJump => 'dá para pular aqui';

  @override
  String get a11yHint => 'dica';

  @override
  String a11yHints(int count) {
    return '$count dicas';
  }

  @override
  String a11yStars(int count) {
    return '$count estrelas';
  }
}
