import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

  static Future<SafeHttpResponse> put(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    Duration? timeout,
  }) {
    return _run(
      method: 'PUT',
      uri: uri,
      headers: headers,
      body: body,
      encoding: encoding,
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
    debugPrint('🚀 $method $uri');
    if (body != null) {
      debugPrint('📦 Request body: $body');
    }
    
    // Get base headers including auth token
    final effectiveHeaders = await getHeaders();
    
    // Add any additional headers provided in the method call
    if (headers != null && headers.isNotEmpty) {
      headers.forEach((key, value) {
        effectiveHeaders[key] = value;
      });
    }
    
    debugPrint('🔑 Request headers: $effectiveHeaders');

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
      } else if (method == 'PUT') {
        response = await client
            .put(
              uri,
              headers: effectiveHeaders,
              body: bodyFields ?? bodyBytes,
              encoding: bodyFields != null ? sendEncoding : null,
            )
            .timeout(duration);
      } else {
        throw ArgumentError('Unsupported method: $method');
      }

      final responseBody = response.bodyBytes;
      final responseHeaders = Map<String, String>.from(response.headers);
      
      debugPrint('✅ ${response.statusCode} ${response.reasonPhrase}');
      debugPrint('📥 Response headers: $responseHeaders');
      
      // Only log response body if it's not too large
      if (responseBody.length < 1024) { // 1KB
        debugPrint('📥 Response body: ${utf8.decode(responseBody)}');
      } else {
        debugPrint('📥 Response body: [${responseBody.length} bytes]');
      }
      
      return SafeHttpResponse(
        statusCode: response.statusCode,
        bodyBytes: responseBody,
        headers: responseHeaders,
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

  static const _storage = FlutterSecureStorage();
  static String? _cachedToken;

  /// Gets the authentication headers including the JWT token
  static Future<Map<String, String>> getHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    try {
      // Get token from cache or storage
      final token = _cachedToken ?? await _storage.read(key: 'token');
      
      if (token != null && token.isNotEmpty) {
        _cachedToken = token; // Cache the token
        headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      print('Error getting auth token: $e');
    }

    return headers;
  }

  /// Updates the cached token
  static Future<void> updateToken(String? token) async {
    _cachedToken = token;
    if (token != null) {
      await _storage.write(key: 'token', value: token);
    } else {
      await _storage.delete(key: 'token');
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
      case 'PUT':
        return client.putUrl(uri);
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
