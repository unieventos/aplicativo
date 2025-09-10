/// Centraliza as URLs da API e permite override por `--dart-define`.
///
/// Em desenvolvimento Web, você pode apontar para o proxy local:
///   flutter run -d chrome \
///     --dart-define=BASE_URL=http://127.0.0.1:8085/unieventos
class ApiConfig {
  static const String host = '172.171.192.14:8081';
  // Permite override via --dart-define=BASE_URL=...
  static const String base = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://$host/unieventos',
  );

  static String usuarios() => '$base/usuarios';
  static String eventos() => '$base/eventos';
  static String categorias() => '$base/categorias';
  static String authLogin() => '$base/auth/login';
}
