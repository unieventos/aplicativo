import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;

import 'package:flutter_application_1/config/api_config.dart';
import 'package:flutter_application_1/network/safe_http.dart';

class EventFeedItem {
  const EventFeedItem({
    required this.id,
    required this.nome,
    required this.descricao,
    this.inicio,
    this.fim,
    this.categoria,
    this.criador,
    this.participantes = 0,
    this.imagemUrl,
  });

  final String id;
  final String nome;
  final String descricao;
  final DateTime? inicio;
  final DateTime? fim;
  final String? categoria;
  final String? criador;
  final int participantes;
  final String? imagemUrl;

  EventFeedItem copyWith({String? imagemUrl}) {
    return EventFeedItem(
      id: id,
      nome: nome,
      descricao: descricao,
      inicio: inicio,
      fim: fim,
      categoria: categoria,
      criador: criador,
      participantes: participantes,
      imagemUrl: imagemUrl ?? this.imagemUrl,
    );
  }
}

class EventService {
  // URL base da API - atualize com o endereço correto do seu backend
  static String get _baseUrl => ApiConfig.base;

  // Headers padrão para as requisições
  static final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Método para criar um novo evento
  static Future<Map<String, dynamic>> criarEvento({
    required String nomeEvento,
    required String descricao,
    required DateTime dateInicio,
    required DateTime dateFim,
    String? categoriaId,
    String? categoriaNome,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/eventos');
      final storage = FlutterSecureStorage();
      final token = await storage.read(key: 'token');
      final headers = {
        ..._headers,
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      // Logs de depuração
      final Map<String, dynamic> payload = {
        'nomeEvento': nomeEvento,
        'descricao': descricao,
        'dateInicio': DateFormat('yyyy-MM-dd').format(dateInicio),
        'dateFim': DateFormat('yyyy-MM-dd').format(dateFim),
      };

      final categoriaValor = (categoriaId != null && categoriaId.isNotEmpty)
          ? categoriaId
          : categoriaNome;
      if (categoriaValor != null && categoriaValor.isNotEmpty) {
        payload['categoria'] = categoriaValor;
      }

      print('[EventService] POST $url');
      print(
          '[EventService] Headers: {Content-Type: ${headers['Content-Type']}, Accept: ${headers['Accept']}, Authorization: ${headers.containsKey('Authorization') ? 'Bearer <redacted>' : 'absent'}}');
      print('[EventService] Body: ${jsonEncode(payload)}');

      final response = await SafeHttp.post(
        url,
        headers: headers,
        body: jsonEncode(payload),
      );

      final String responseText = utf8.decode(response.bodyBytes);
      dynamic data;
      try {
        data = responseText.isNotEmpty ? jsonDecode(responseText) : null;
      } catch (_) {
        data = responseText;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final headerId = _extractEventIdFromHeaders(response.headers);
        return {
          'success': true,
          'data': data,
          'eventId': _extractEventId(data) ?? headerId ?? _extractAnyId(data),
          'location':
              response.headers['location'] ?? response.headers['Location'],
          'message': _extractMessage(data) ?? 'Evento criado com sucesso.',
          'statusCode': response.statusCode,
        };
      } else {
        print('[EventService] Erro ${response.statusCode}: $responseText');
        print('[EventService] Response headers: ${response.headers}');
        return {
          'success': false,
          'error': 'Erro ao criar evento: ${response.statusCode}',
          'details': data,
          'message': _extractMessage(data) ??
              (responseText.isNotEmpty
                  ? responseText
                  : 'Erro ${response.statusCode} sem corpo'),
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro de conexão: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> enviarArquivoEvento({
    required File arquivo,
    required String eventoId,
    String tipo = 'EVENTO',
  }) async {
    final url = Uri.parse('$_baseUrl/fotos');
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');

    final request = http.MultipartRequest('POST', url);
    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    });

    print('[EventService] POST multipart $url (eventoId=$eventoId)');

    final mimeType = _mimeTypeForPath(arquivo.path);
    request.files.add(await http.MultipartFile.fromPath(
      'foto',
      arquivo.path,
      contentType: mimeType,
    ));

    request.files.add(http.MultipartFile.fromString(
      'dados',
      jsonEncode({'tipo': tipo, 'id': eventoId}),
      contentType: MediaType('application', 'json'),
    ));

    try {
      final streamed = await request.send();
      final responseText = await streamed.stream.bytesToString();
      dynamic data;
      try {
        data = responseText.isNotEmpty ? jsonDecode(responseText) : null;
      } catch (_) {
        data = responseText;
      }

      if (streamed.statusCode == 200 || streamed.statusCode == 201) {
        return {
          'success': true,
          'data': data,
          'message': _extractMessage(data) ?? 'Imagem anexada com sucesso.',
          'statusCode': streamed.statusCode,
        };
      }

      print('[EventService] Erro upload ${streamed.statusCode}: $responseText');
      return {
        'success': false,
        'message': _extractMessage(data) ?? 'Falha ao anexar imagem.',
        'details': data,
        'statusCode': streamed.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao anexar imagem: $e',
        'error': e.toString(),
      };
    }
  }

  static String? _extractEventId(dynamic data) {
    if (data == null) return null;
    if (data is Map<String, dynamic>) {
      final directId = data['id'];
      if (directId is String && directId.isNotEmpty) return directId;

      final evento = data['evento'];
      if (evento is Map<String, dynamic>) {
        final nestedId = evento['id'];
        if (nestedId is String && nestedId.isNotEmpty) return nestedId;
      }

      final embedded = data['_embedded'];
      if (embedded is Map<String, dynamic>) {
        final list = embedded['eventoResourceV1List'];
        if (list is List && list.isNotEmpty) {
          final first = list.first;
          if (first is Map<String, dynamic>) {
            final evt = first['evento'];
            if (evt is Map<String, dynamic>) {
              final nested = evt['id'];
              if (nested is String && nested.isNotEmpty) return nested;
            }
          }
        }
      }
    }
    return null;
  }

  static String? _extractAnyId(dynamic value) {
    final visited = <int>{};

    String? dfs(dynamic node) {
      if (node == null) return null;
      final identity = identityHashCode(node);
      if (!visited.add(identity)) return null;

      if (node is Map) {
        for (final entry in node.entries) {
          final key = entry.key;
          final val = entry.value;
          if (key is String && key.toLowerCase().contains('id')) {
            final str = _asString(val);
            if (str != null && str.isNotEmpty) return str;
          }
          final nested = dfs(val);
          if (nested != null) return nested;
        }
      } else if (node is Iterable) {
        for (final item in node) {
          final nested = dfs(item);
          if (nested != null) return nested;
        }
      }
      return null;
    }

    return dfs(value);
  }

  static String? _extractMessage(dynamic data) {
    if (data == null) return null;
    if (data is Map<String, dynamic>) {
      final keys = ['message', 'mensagem', 'detail', 'error'];
      for (final key in keys) {
        final value = data[key];
        if (value is String && value.isNotEmpty) {
          return value;
        }
      }
    }
    if (data is String && data.isNotEmpty) return data;
    return null;
  }

  static String? _extractEventIdFromHeaders(Map<String, String> headers) {
    final location = headers['location'] ?? headers['Location'];
    if (location == null || location.isEmpty) return null;
    final sanitized = location.split('?').first;
    final segments =
        sanitized.split('/').where((segment) => segment.isNotEmpty);
    return segments.isNotEmpty ? segments.last : null;
  }

  static String? _asString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is num || value is bool) return value.toString();
    return null;
  }

  static MediaType _mimeTypeForPath(String path) {
    final parts = path.split('.');
    if (parts.length < 2) {
      return MediaType('application', 'octet-stream');
    }
    switch (parts.last.toLowerCase()) {
      case 'png':
        return MediaType('image', 'png');
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'heic':
        return MediaType('image', 'heic');
      case 'webp':
        return MediaType('image', 'webp');
      default:
        return MediaType('application', 'octet-stream');
    }
  }

  static Future<List<EventFeedItem>> listarEventos({
    int page = 0,
    int size = 20,
  }) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    if (token == null || token.isEmpty) {
      throw Exception('Token não encontrado');
    }

    final uri =
        Uri.parse('$_baseUrl/eventos?page=$page&size=$size&sortBy=dateInicio');
    final response = await SafeHttp.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final bodyText = utf8.decode(response.bodyBytes);
    if (response.statusCode != 200) {
      throw Exception(
          'Erro ao buscar eventos (${response.statusCode}): $bodyText');
    }

    final dynamic decoded = bodyText.isNotEmpty ? jsonDecode(bodyText) : null;
    final eventos = <EventFeedItem>[];
    final ids = <String>{};

    final lista = _extrairLista(decodido: decoded, chave: 'evento');
    for (final item in lista) {
      final eventoNode = _extrairNodoEvento(item);
      if (eventoNode == null) continue;

      final id =
          _stringOuNulo(eventoNode['id']) ?? _stringOuNulo(item['id']) ?? '';
      if (id.isEmpty) continue;

      final nome = _stringOuNulo(eventoNode['nomeEvento']) ?? 'Evento';
      final descricao =
          _stringOuNulo(eventoNode['descricao']) ?? 'Sem descrição disponível.';
      final inicio = _parseData(eventoNode['dateInicio']);
      final fim = _parseData(eventoNode['dateFim']);
      final criador = _stringOuNulo(eventoNode['usuarioCriador']);
      final categoria = _extrairCategoria(eventoNode['eventoCategoria']);
      final participantes = _contarLista(eventoNode['usuariosPermissao']);

      eventos.add(EventFeedItem(
        id: id,
        nome: nome,
        descricao: descricao,
        inicio: inicio,
        fim: fim,
        categoria: categoria,
        criador: criador,
        participantes: participantes,
      ));
      ids.add(id);
    }

    if (eventos.isEmpty) {
      return eventos;
    }

    final fotos = await _listarFotosEventos(ids, token);
    if (fotos.isEmpty) {
      return eventos;
    }

    return [
      for (final item in eventos)
        item.copyWith(imagemUrl: fotos[item.id] ?? item.imagemUrl)
    ];
  }

  static List<Map<String, dynamic>> _extrairLista({
    required dynamic decodido,
    required String chave,
  }) {
    if (decodido is Map<String, dynamic>) {
      final embedded = decodido['_embedded'];
      if (embedded is Map<String, dynamic>) {
        final candidato = embedded['${chave}ResourceV1List'] ??
            embedded['${chave}List'] ??
            embedded[chave];
        if (candidato is List) {
          return candidato
              .whereType<Map<String, dynamic>>()
              .toList(growable: false);
        }
      }

      final content = decodido['content'];
      if (content is List) {
        return content
            .whereType<Map<String, dynamic>>()
            .toList(growable: false);
      }
    } else if (decodido is List) {
      return decodido.whereType<Map<String, dynamic>>().toList(growable: false);
    }
    return const [];
  }

  static Map<String, dynamic>? _extrairNodoEvento(
      Map<String, dynamic> candidato) {
    final evento = candidato['evento'];
    if (evento is Map<String, dynamic>) {
      return evento;
    }
    return candidato;
  }

  static String? _stringOuNulo(dynamic valor) {
    if (valor == null) return null;
    if (valor is String) return valor.isEmpty ? null : valor;
    return valor.toString();
  }

  static DateTime? _parseData(dynamic valor) {
    final texto = _stringOuNulo(valor);
    if (texto == null) return null;
    try {
      return DateTime.parse(texto).toLocal();
    } catch (_) {
      return null;
    }
  }

  static String? _extrairCategoria(dynamic categorias) {
    if (categorias is List && categorias.isNotEmpty) {
      final primeiro = categorias.first;
      if (primeiro is Map<String, dynamic>) {
        return _stringOuNulo(
            primeiro['nomeCategoria'] ?? primeiro['nome'] ?? primeiro['name']);
      }
      return primeiro?.toString();
    }
    return null;
  }

  static int _contarLista(dynamic lista) {
    if (lista is List) return lista.length;
    return 0;
  }

  static Future<Map<String, String>> _listarFotosEventos(
      Set<String> ids, String token) async {
    if (ids.isEmpty) return const {};
    final limite = ids.length > 200 ? ids.length : 200;
    final uri = Uri.parse('$_baseUrl/fotos?page=0&size=$limite&sortBy=id');
    final response = await SafeHttp.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      return const {};
    }

    final bodyText = utf8.decode(response.bodyBytes);
    final decoded = bodyText.isNotEmpty ? jsonDecode(bodyText) : null;
    final fotos = <String, String>{};
    final lista = _extrairLista(decodido: decoded, chave: 'foto');
    for (final item in lista) {
      final foto = item['foto'] is Map<String, dynamic>
          ? item['foto'] as Map<String, dynamic>
          : item;
      final alvo =
          _stringOuNulo(foto['alvo']) ?? _stringOuNulo(item['alvo']) ?? '';
      if (alvo.toUpperCase() != 'EVENTO') continue;
      final idAlvo =
          _stringOuNulo(foto['idAlvo']) ?? _stringOuNulo(item['idAlvo']);
      if (idAlvo == null || !ids.contains(idAlvo)) continue;
      final path = _stringOuNulo(foto['path']) ?? _stringOuNulo(item['path']);
      if (path == null || path.isEmpty) continue;
      fotos[idAlvo] = _resolverPath(path);
    }
    return fotos;
  }

  static String _resolverPath(String path) {
    final trimmed = path.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    final base = Uri.parse(_baseUrl.endsWith('/') ? _baseUrl : '$_baseUrl/');
    final sanitized = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
    return base.resolve(sanitized).toString();
  }
}
