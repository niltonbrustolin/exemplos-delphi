import 'dart:ui';

/// Visual do tabuleiro e das peças.
class BoardTheme {
  final String id;
  final String name;
  final Color light, dark, frame, block;

  /// Peças do jogador e peças fixas do desafio.
  final Color player, fixed;
  final double shine;

  /// Produto da Play Store que libera o tema (`null` = não é vendido).
  final String? productId;

  /// Estrelas necessárias para liberar o tema de graça (0 = sempre livre).
  final int starsRequired;

  const BoardTheme({
    required this.id,
    required this.name,
    required this.light,
    required this.dark,
    required this.frame,
    required this.block,
    required this.player,
    required this.fixed,
    this.shine = 0.45,
    this.productId,
    this.starsRequired = 0,
  });
}

const boardThemes = [
  BoardTheme(
    id: 'madeira',
    name: 'Madeira',
    light: Color(0xFFE9D3AE),
    dark: Color(0xFF9C6B45),
    frame: Color(0xFF4E342E),
    block: Color(0xFF3E2723),
    player: Color(0xFFF3E6CC),
    fixed: Color(0xFF363B47),
  ),
  BoardTheme(
    id: 'torneio',
    name: 'Torneio',
    light: Color(0xFFEEEED2),
    dark: Color(0xFF769656),
    frame: Color(0xFF33413A),
    block: Color(0xFF263238),
    player: Color(0xFFFAFAFA),
    fixed: Color(0xFF212121),
    starsRequired: 60,
  ),
  BoardTheme(
    id: 'marmore',
    name: 'Mármore',
    light: Color(0xFFF4F4F2),
    dark: Color(0xFF8C98A4),
    frame: Color(0xFF37474F),
    block: Color(0xFF263238),
    player: Color(0xFFFFF8E1),
    fixed: Color(0xFF1B2631),
    shine: 0.8,
    productId: 'tema_marmore',
  ),
  BoardTheme(
    id: 'neon',
    name: 'Neon',
    light: Color(0xFF26324F),
    dark: Color(0xFF0F1629),
    frame: Color(0xFF6A1B9A),
    block: Color(0xFF4A148C),
    player: Color(0xFF18FFFF),
    fixed: Color(0xFFFF4081),
    shine: 0.9,
    productId: 'tema_neon',
  ),
];

BoardTheme themeById(String id) =>
    boardThemes.firstWhere((t) => t.id == id, orElse: () => boardThemes.first);
