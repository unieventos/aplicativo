import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class SafeHttpResponse {
  const SafeHttpResponse({
    required this.statusCode,
    required this.bodyBytes,
    required this.headers,
  });

  final int statusCode;
  final List<int> bodyBytes;
  final Map<String, String> headers;

  String bodyAsString([Encoding encoding = utf8]) => encoding.decode(bodyBytes);
}

class SafeHttp {
  static const Duration _defaultTimeout = Duration(seconds: 20);

  static Future<SafeHttpResponse> get(
    Uri uri, {
    Map<String, String>? headers,
    Duration? timeout,
  }) {
    return _run(
      method: 'GET',
      uri: uri,
      headers: headers,
      timeout: timeout,
    );
  }

  static Future<SafeHttpResponse> post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    Duration? timeout,
  }) {
    return _run(
      method: 'POST',
      uri: uri,
      headers: headers,
      body: body,
      encoding: encoding,
      timeout: timeout,
    );
  }

  static Future<SafeHttpResponse> _run({
    required String method,
    required Uri uri,
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    Duration? timeout,
  }) async {
    final effectiveHeaders = <String, String>{};
    if (headers != null && headers.isNotEmpty) {
      effectiveHeaders.addAll(headers);
    }

    Encoding sendEncoding = encoding ?? utf8;
    List<int>? bodyBytes;
    Map<String, String>? bodyFields;

    if (body != null) {
      if (body is String) {
        bodyBytes = sendEncoding.encode(body);
      } else if (body is List<int>) {
        bodyBytes = body;
      } else if (body is Map<String, String>) {
        bodyFields = body;
        if (!_hasContentType(effectiveHeaders)) {
          effectiveHeaders['Content-Type'] =
              'application/x-www-form-urlencoded; charset=${sendEncoding.name}';
        }
      } else {
        throw ArgumentError('Unsupported body type: ${body.runtimeType}');
      }
    }

    final client = http.Client();
    try {
      http.Response response;
      final duration = timeout ?? _defaultTimeout;
      if (method == 'GET') {
        response = await client
            .get(uri, headers: effectiveHeaders)
            .timeout(duration);
      } else if (method == 'POST') {
        response = await client
            .post(
              uri,
              headers: effectiveHeaders,
              body: bodyFields ?? bodyBytes,
              encoding: bodyFields != null ? sendEncoding : null,
            )
            .timeout(duration);
      } else {
        throw ArgumentError('Unsupported method: $method');
      }

      return SafeHttpResponse(
        statusCode: response.statusCode,
        bodyBytes: response.bodyBytes,
        headers: Map<String, String>.from(response.headers),
      );
    } on http.ClientException {
      return _fallbackWithHttpClient(
        method: method,
        uri: uri,
        headers: effectiveHeaders,
        bodyBytes: bodyFields != null
            ? sendEncoding.encode(_formEncode(bodyFields))
            : bodyBytes,
        timeout: timeout,
      );
    } on TimeoutException {
      rethrow;
    } finally {
        client.close();
    }
  }

  static Future<SafeHttpResponse> _fallbackWithHttpClient({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    List<int>? bodyBytes,
    Duration? timeout,
  }) async {
    final httpClient = HttpClient()
      ..connectionTimeout = timeout ?? _defaultTimeout;
    try {
      final request = await _openRequest(httpClient, method, uri);
      headers.forEach(request.headers.set);

      if (bodyBytes != null && bodyBytes.isNotEmpty) {
        request.add(bodyBytes);
      }

      final response = await request.close();
      final bytesBuilder = BytesBuilder(copy: false);
      bool streamFailed = false;

      try {
        await for (final chunk in response) {
          bytesBuilder.add(chunk);
        }
      } catch (_) {
        streamFailed = true;
        if (bytesBuilder.isEmpty) rethrow;
      }

      final collected = bytesBuilder.takeBytes();
      if (streamFailed && collected.isEmpty) {
        throw const HttpException('Empty response after stream failure');
      }

      final responseHeaders = <String, String>{};
      response.headers.forEach((name, values) {
        if (values.isNotEmpty) {
          responseHeaders[name] = values.join(',');
        }
      });

      return SafeHttpResponse(
        statusCode: response.statusCode,
        bodyBytes: collected,
        headers: responseHeaders,
      );
    } finally {
      httpClient.close(force: true);
    }
  }

  static Future<HttpClientRequest> _openRequest(
    HttpClient client,
    String method,
    Uri uri,
  ) {
    switch (method.toUpperCase()) {
      case 'GET':
        return client.getUrl(uri);
      case 'POST':
        return client.postUrl(uri);
      default:
        return client.openUrl(method.toUpperCase(), uri);
    }
  }

  static String _formEncode(Map<String, String> fields) {
    return fields.entries
        .map((entry) =>
            '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(entry.value)}')
        .join('&');
  }

  static bool _hasContentType(Map<String, String> headers) {
    return headers.keys.any((key) => key.toLowerCase() == 'content-type');
  }
}
