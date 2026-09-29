/// Informações do app e do desenvolvedor, mostradas na tela "Sobre".
///
/// Tudo aqui fica visível para quem baixar o app.
class AppInfo {
  static const appName = '8 Queens';

  static const developerName = 'Nilton Brustolin';

  /// E-mail de contato. Deixe vazio para não mostrar.
  static const developerEmail = 'niltonbrustolin@gmail.com';

  /// Endereço público da política de privacidade (exigido pela Play Store
  /// para apps com anúncios). Deixe vazio até publicar a página.
  static const privacyPolicyUrl =
      'https://niltonbrustolin.github.io/exemplos-delphi/8queens/politica-de-privacidade.html';

  /// Versão da política no idioma do app (a portuguesa é a principal).
  static String privacyPolicyFor(String languageCode) => switch (languageCode) {
    'pt' => privacyPolicyUrl,
    'es' => privacyPolicyUrl.replaceFirst(
      'politica-de-privacidade.html',
      'politica-de-privacidad.html',
    ),
    _ => privacyPolicyUrl.replaceFirst(
      'politica-de-privacidade.html',
      'privacy-policy.html',
    ),
  };
}
