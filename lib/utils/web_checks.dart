/// Utilitários de checagem específicos para execução no Web.
/// - Detecta se a página está servida por HTTPS (para evitar mixed content)
/// - Ajuda a gerar mensagens de erro mais claras
import 'package:flutter/foundation.dart';
import 'web_checks_stub.dart' if (dart.library.html) 'web_checks_html.dart';

class WebChecks {
  /// True se a origem (window.location) for HTTPS
  static bool isHttpsOrigin() => kIsWeb ? webIsHttpsOrigin() : false;

  /// True quando a página está em HTTPS e a API em HTTP (bloqueio do navegador)
  static bool isMixedContent(String apiBase) {
    return kIsWeb && isHttpsOrigin() && apiBase.startsWith('http://');
  }
}
