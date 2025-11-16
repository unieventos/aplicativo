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
  static String cursos() => '$base/cursos';
  static String authLogin() => '$base/auth/login';
}
