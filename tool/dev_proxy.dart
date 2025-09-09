// A simple development reverse proxy to bypass CORS in Flutter Web.
// Usage:
//   dart run tool/dev_proxy.dart
// This starts a server on http://127.0.0.1:8085 that proxies to
// http://172.171.192.14:8081. Point your app to it with:
//   flutter run -d chrome --dart-define=BASE_URL=http://127.0.0.1:8085/unieventos

import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_proxy/shelf_proxy.dart';

Future<void> main(List<String> args) async {
  final target = 'http://172.171.192.14:8081';
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8085;

  final proxy = proxyHandler(target);

  // CORS middleware
  Middleware cors() => (Handler inner) {
        return (Request req) async {
          // Preflight
          if (req.method == 'OPTIONS') {
            return Response(204, headers: _corsHeaders(req));
          }

          final res = await inner(req);
          return res.change(headers: {
            ...res.headers,
            ..._corsHeaders(req),
          });
        };
      };

  // Log requests
  final pipeline = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(cors())
      .addHandler((Request req) async {
    // Everything is proxied to target as-is (including /unieventos/...)
    return proxy(req);
  });

  final server = await serve(pipeline, InternetAddress.loopbackIPv4, port);
  print('Dev proxy on http://127.0.0.1:${server.port} -> $target');
}

Map<String, String> _corsHeaders(Request req) {
  final origin = req.headers['origin'] ?? '*';
  return {
    'Access-Control-Allow-Origin': origin,
    'Vary': 'Origin',
    'Access-Control-Allow-Methods': 'GET, POST, PATCH, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Authorization, Content-Type',
    'Access-Control-Expose-Headers': 'Location',
  };
}

