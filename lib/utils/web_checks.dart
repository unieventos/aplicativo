import 'package:flutter/foundation.dart';
import 'web_checks_stub.dart' if (dart.library.html) 'web_checks_html.dart';

class WebChecks {
  static bool isHttpsOrigin() => kIsWeb ? webIsHttpsOrigin() : false;

  static bool isMixedContent(String apiBase) {
    return kIsWeb && isHttpsOrigin() && apiBase.startsWith('http://');
  }
}

