/// Flags de desenvolvimento para facilitar testes locais.
///
/// ATENÇÃO: não deixe esses flags habilitados em produção.
class DevFlags {
  /// Pula a tela de login e navega direto para a home.
  /// Definível por: --dart-define=SKIP_LOGIN=true
  static const bool skipLogin = bool.fromEnvironment('SKIP_LOGIN', defaultValue: true);

  /// Permite chamadas à API sem header Authorization quando não houver token.
  /// Definível por: --dart-define=ALLOW_NO_AUTH=true
  static const bool allowNoAuth = bool.fromEnvironment('ALLOW_NO_AUTH', defaultValue: true);
}

