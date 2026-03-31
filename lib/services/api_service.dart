// Serviço central de acesso à API (Usuários, Eventos, Categorias).
//
// Boas práticas aplicadas:
// - URLs centralizadas via ApiConfig
// - Timeout padrão de 15s para todas as chamadas
// - Checagem de mixed content/CORS em ambiente Web
// - Decodificação usando utf8 para evitar problemas de acentuação
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_application_1/config/api_config.dart';
import 'package:flutter_application_1/utils/web_checks.dart';
import 'package:flutter_application_1/user_service.dart';
import 'utils/file_downloader.dart';

// Modelos centralizados
import 'package:flutter_application_1/models/usuario.dart';
import 'package:flutter_application_1/models/evento.dart';
import 'package:flutter_application_1/models/curso.dart';
import 'package:flutter_application_1/models/course_option.dart';

/// Modelo para Categoria (baseado no Swagger do backend).
class Categoria {
  final String id;
  final String nome;
  Categoria({required this.id, required this.nome});
  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id'] ?? '',
      nome: json['nomeCategoria'] ?? '',
    );
  }
}

/// Operações de API relacionadas a Usuários.
class UsuarioApi {
  static final String _baseUrl = ApiConfig.usuarios();
  static final _storage = FlutterSecureStorage();

  /// GET /usuarios — Retorna lista paginada de usuários.
  /// - page: índice da página (0-based)
  /// - pageSize: tamanho da página
  /// - search: filtro por nome
  /// - active: se true, traz apenas ativos; se false, apenas inativos.
  static Future<List<Usuario>> fetchUsuarios(
      int page, int pageSize, String search,
      {bool? apenasAtivos}) async {
    final token = await _storage.read(key: 'token');
    if (token == null) throw Exception('Token não encontrado.');

    if (WebChecks.isMixedContent(ApiConfig.base)) {
      throw Exception(
          'Mixed content bloqueado no navegador: app https x API http.');
    }

    String urlString =
        '$_baseUrl?page=$page&size=$pageSize&sortBy=nome&name=$search';
    if (apenasAtivos != null) {
      urlString += '&active=$apenasAtivos';
    }

    final url = Uri.parse(urlString);
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token'
    }).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> list =
          data['_embedded']?['usuarioResourceV1List'] ?? [];
      final usuarios =
          list.map((item) => Usuario.fromJson(item['user'])).toList();

      return usuarios;
    } else {
      throw Exception('Falha ao carregar usuários: ${response.statusCode}');
    }
  }

  /// POST /usuarios — Cria um novo usuário.
  static Future<bool> criarUsuario(Map<String, dynamic> dadosUsuario) async {
    final token = await _storage.read(key: 'token');
    if (token == null) return false;

    if (WebChecks.isMixedContent(ApiConfig.base)) {
      throw Exception(
          'Mixed content bloqueado no navegador: app https x API http.');
    }

    final url = Uri.parse(_baseUrl);

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json; charset=utf-8',
              'Accept': 'application/json',
            },
            body: jsonEncode(dadosUsuario),
          )
          .timeout(const Duration(seconds: 15));
      // Alguns backends retornam 201 (Created), outros 200.
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// PATCH /usuarios/{id} — Atualiza um usuário existente (parcial).
  static Future<bool> atualizarUsuario(
      String usuarioId, Map<String, dynamic> dadosUsuario) async {
    final token = await _storage.read(key: 'token');
    if (token == null) return false;

    if (WebChecks.isMixedContent(ApiConfig.base)) {
      throw Exception(
          'Mixed content bloqueado no navegador: app https x API http.');
    }

    final url = Uri.parse('$_baseUrl/$usuarioId');
    try {
      final response = await http
          .patch(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json'
            },
            body: jsonEncode(dadosUsuario),
          )
          .timeout(const Duration(seconds: 15));
      // Alguns backends retornam 204 (No Content), outros 200 (OK).
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print("Erro ao atualizar usuário: $e");
      return false;
    }
  }

  /// DELETE /usuarios/{id} — Inativa/Remove um usuário.
  static Future<Map<String, dynamic>> deletarUsuario(String usuarioId) async {
    final token = await _storage.read(key: 'token');
    if (token == null)
      return {'sucesso': false, 'mensagem': 'Token não encontrado.'};

    if (WebChecks.isMixedContent(ApiConfig.base)) {
      throw Exception(
          'Mixed content bloqueado no navegador: app https x API http.');
    }

    final url = Uri.parse('$_baseUrl/$usuarioId');
    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 15));

      // Alguns backends retornam 204 (No Content), outros 200 (OK).
      if (response.statusCode == 204 || response.statusCode == 200) {
        return {'sucesso': true};
      }
      return {'sucesso': false, 'mensagem': 'Erro ${response.statusCode}'};
    } catch (e) {
      print("Erro ao deletar usuário: $e");
      return {'sucesso': false, 'mensagem': e.toString()};
    }
  }

  /// PATCH /usuarios/{id}?action=active — Reativa um usuário.
  static Future<bool> reativarUsuario(String usuarioId) async {
    final token = await _storage.read(key: 'token');
    if (token == null) return false;

    if (WebChecks.isMixedContent(ApiConfig.base)) {
      throw Exception(
          'Mixed content bloqueado no navegador: app https x API http.');
    }

    final url = Uri.parse('$_baseUrl/$usuarioId?action=active');
    try {
      print('[UsuarioApi] Tentando reativar usuário (PUT): $url');
      final response = await http
          .put(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json'
            },
            body: jsonEncode({}),
          )
          .timeout(const Duration(seconds: 15));

      print('[UsuarioApi] Resposta reativação: ${response.statusCode}');
      if (response.body.isNotEmpty) {
        print('[UsuarioApi] Body reativação: ${response.body}');
      }

      return response.statusCode == 204 ||
          response.statusCode == 200 ||
          response.statusCode == 201;
    } catch (e) {
      print("[UsuarioApi] Erro ao reativar usuário: $e");
      return false;
    }
  }

  /// GET /usuarios/me — Dados do usuário logado (auto-consulta).
  static Future<Map<String, dynamic>?> buscarUsuarioLogado() async {
    final token = await _storage.read(key: 'token');
    if (token == null) return null;

    if (WebChecks.isMixedContent(ApiConfig.base)) {
      throw Exception(
          'Mixed content bloqueado no navegador: app https x API http.');
    }

    final url = Uri.parse('$_baseUrl/me');
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token'
      }).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      }
      return null;
    } catch (e) {
      print("Erro ao buscar usuário logado: $e");
      return null;
    }
  }

  // GET /usuarios/{id} - Busca um usuário específico por ID
  static Future<Usuario?> buscarUsuarioPorId(String id) async {
    final token = await _storage.read(key: 'token');
    if (token == null) {
      // Se não houver token, retorna null (pode ser listagem pública)
      return null;
    }

    if (WebChecks.isMixedContent(ApiConfig.base)) {
      throw Exception(
          'Mixed content bloqueado no navegador: app https x API http.');
    }

    final url = Uri.parse('$_baseUrl/$id');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        // A API pode retornar o usuário em diferentes estruturas
        // Tenta encontrar o objeto 'user' dentro da resposta
        Map<String, dynamic>? userData;
        if (data is Map<String, dynamic>) {
          if (data['user'] is Map<String, dynamic>) {
            userData = data['user'] as Map<String, dynamic>;
          } else if (data['nome'] != null || data['id'] != null) {
            // Se já é o objeto user diretamente
            userData = data;
          }
        }

        if (userData != null) {
          return Usuario.fromJson(userData);
        }
        return null;
      } else if (response.statusCode == 404) {
        // Usuário não encontrado
        return null;
      } else {
        print("Erro ao buscar usuário por ID: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Erro ao buscar usuário por ID: $e");
      return null;
    }
  }

  // GET /cursos - Lista todos os cursos carregados dinamicamente
  static Future<List<CourseOption>> listarCursos() async {
    return await UserService.listarCursos();
  }

  // Método de teste para verificar conectividade com a API
  static Future<bool> testarConectividade() async {
    final token = await _storage.read(key: 'token');
    if (token == null) {
      print('[UsuarioApi] Teste de conectividade: Token não encontrado');
      return false;
    }

    if (WebChecks.isMixedContent(ApiConfig.base)) {
      print('[UsuarioApi] Teste de conectividade: Mixed content bloqueado');
      return false;
    }

    try {
      final url = Uri.parse('$_baseUrl/me');
      print('[UsuarioApi] Testando conectividade com: $url');

      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token'
      }).timeout(const Duration(seconds: 10));

      print(
          '[UsuarioApi] Teste de conectividade - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('[UsuarioApi] Teste de conectividade: SUCESSO');
        return true;
      } else {
        print(
            '[UsuarioApi] Teste de conectividade: FALHOU - ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('[UsuarioApi] Teste de conectividade: ERRO - $e');
      return false;
    }
  }
}

/// Operações de API relacionadas a Eventos.
class EventosApi {
  static final String _baseUrl = ApiConfig.eventos();
  static final _storage = FlutterSecureStorage();

  /// GET /eventos — Retorna lista paginada de eventos.
  /// Parâmetros de busca podem variar no backend (ex.: name, titulo, etc.).
  static Future<List<Evento>> fetchEventos(int page, int pageSize,
      {String search = ''}) async {
    final token = await _storage.read(key: 'token');

    if (WebChecks.isMixedContent(ApiConfig.base)) {
      throw Exception(
          'Mixed content bloqueado no navegador: app https x API http.');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final url = Uri.parse(
        '$_baseUrl?page=$page&size=$pageSize&sortBy=dateInicio&name=$search&_t=$timestamp');

    // Headers condicionais - só adiciona Authorization se o token existir
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http
        .get(url, headers: headers)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> list =
          data['_embedded']?['eventoResourceV1List'] ?? [];
      final eventos =
          list.map((item) => Evento.fromJson(item['evento'])).toList();

      // Buscar nomes dos criadores se houver token
      if (token != null && token.isNotEmpty && eventos.isNotEmpty) {
        await _enriquecerNomesCriadores(eventos);
      }

      // NOVO: Busca as fotos (binário) antes de exibir na tela
      final String baseUrlEventos = ApiConfig.eventos();
      final headers = <String, String>{};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      await Future.wait(eventos.asMap().entries.map((entry) async {
        final index = entry.key;
        final evento = entry.value;

        if (evento.id.isNotEmpty) {
          Uint8List? fetchedBytes;
          try {
            final urlFoto =
                Uri.parse('$baseUrlEventos/${evento.id}/fotos/download');
            final response = await http
                .get(urlFoto, headers: headers)
                .timeout(const Duration(seconds: 10));

            if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
              fetchedBytes = response.bodyBytes;
            }
          } catch (e) {
            print(
                '[EventosApi] Erro ao buscar foto para evento ${evento.id}: $e');
          }

          eventos[index] = Evento(
            id: evento.id,
            titulo: evento.titulo,
            descricao: evento.descricao,
            autor: evento.autor,
            criador: evento.criador,
            cursoAutor: evento.cursoAutor,
            autorAvatarUrl: evento.autorAvatarUrl,
            imagemUrl: '$baseUrlEventos/${evento.id}/fotos/download',
            imagemBytes: fetchedBytes,
            data: evento.data,
            inicio: evento.inicio,
            fim: evento.fim,
            categoria: evento.categoria,
            participantes: evento.participantes,
          );
        }
      }));

      return eventos;
    } else if (response.statusCode == 404) {
      // API retorna 404 quando não há eventos (EventNotFoundException)
      return [];
    } else {
      throw Exception('Falha ao carregar eventos: ${response.statusCode}');
    }
  }

  /// POST /eventos?action=relatorio — Retorna um PDF com base na requisição de filtro (IDS ou outro).
  static Future<void> gerarRelatorio(String filterType, Map<String, dynamic> params) async {
    final token = await _storage.read(key: 'token');

    if (WebChecks.isMixedContent(ApiConfig.base)) {
      throw Exception('Mixed content bloqueado no navegador: app https x API http.');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final url = Uri.parse('$_baseUrl?action=relatorio&_t=$timestamp');

    final payload = {
      "filterType": filterType,
      "params": params
    };

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/pdf',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http
        .post(url, headers: headers, body: jsonEncode(payload))
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200 || response.statusCode == 201) {
      downloadPdf(response.bodyBytes, 'relatorio_eventos.pdf');
    } else {
      throw Exception('Falha ao gerar relatório: ${response.statusCode}');
    }
  }

  /// POST /eventos/search — Retorna lista paginada de eventos buscando por filtro do Spring.
  static Future<List<Evento>> searchEventos(
      String filterType, Map<String, dynamic> params, int page, int pageSize, {String search = ''}) async {
    final token = await _storage.read(key: 'token');

    if (WebChecks.isMixedContent(ApiConfig.base)) {
      throw Exception('Mixed content bloqueado no navegador: app https x API http.');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final url = Uri.parse('$_baseUrl/search?page=$page&size=$pageSize&sortBy=dateInicio&name=$search&_t=$timestamp');

    final payload = {
      "filterType": filterType,
      "params": params
    };

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http
        .post(url, headers: headers, body: jsonEncode(payload))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> list = data['_embedded']?['eventoResourceV1List'] ?? [];
      final eventos = list.map((item) => Evento.fromJson(item['evento'])).toList();

      if (token != null && token.isNotEmpty && eventos.isNotEmpty) {
        await _enriquecerNomesCriadores(eventos);
      }

      final String baseUrlEventos = ApiConfig.eventos();
      final headersAuth = <String, String>{};
      if (token != null && token.isNotEmpty) {
        headersAuth['Authorization'] = 'Bearer $token';
      }

      await Future.wait(eventos.asMap().entries.map((entry) async {
        final index = entry.key;
        final evento = entry.value;

        if (evento.id.isNotEmpty) {
          Uint8List? fetchedBytes;
          try {
            final urlFoto = Uri.parse('$baseUrlEventos/${evento.id}/fotos/download');
            final responseFoto = await http
                .get(urlFoto, headers: headersAuth)
                .timeout(const Duration(seconds: 10));

            if (responseFoto.statusCode == 200 && responseFoto.bodyBytes.isNotEmpty) {
              fetchedBytes = responseFoto.bodyBytes;
            }
          } catch (e) {
            print('[EventosApi] Erro ao buscar foto para evento (search) ${evento.id}: $e');
          }

          eventos[index] = Evento(
            id: evento.id,
            titulo: evento.titulo,
            descricao: evento.descricao,
            autor: evento.autor,
            criador: evento.criador,
            cursoAutor: evento.cursoAutor,
            autorAvatarUrl: evento.autorAvatarUrl,
            imagemUrl: '$baseUrlEventos/${evento.id}/fotos/download',
            imagemBytes: fetchedBytes,
            data: evento.data,
            inicio: evento.inicio,
            fim: evento.fim,
            categoria: evento.categoria,
            participantes: evento.participantes,
          );
        }
      }));

      return eventos;
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Falha ao buscar eventos: ${response.statusCode}');
    }
  }

  // Enriquece os eventos com os nomes dos criadores
  static Future<void> _enriquecerNomesCriadores(List<Evento> eventos) async {
    // Coleta todos os IDs únicos de criadores
    final criadoresIds = <String>{};
    for (final evento in eventos) {
      final criadorId = evento.criador;
      // Verifica se é um UUID (formato básico: contém hífens e tem comprimento típico)
      if (criadorId.isNotEmpty &&
          criadorId.length > 20 &&
          criadorId.contains('-')) {
        criadoresIds.add(criadorId);
      }
    }

    if (criadoresIds.isEmpty) {
      return; // Não há IDs para buscar
    }

    // Busca todos os usuários em paralelo
    final usuariosFutures =
        criadoresIds.map((id) => UsuarioApi.buscarUsuarioPorId(id));
    final usuariosResults = await Future.wait(usuariosFutures);

    // Cria mapa de ID -> nome completo
    final Map<String, String> nomesCriadores = {};
    for (int i = 0; i < criadoresIds.length; i++) {
      final id = criadoresIds.elementAt(i);
      final usuario = usuariosResults[i];
      if (usuario != null) {
        final nomeCompleto = usuario.displayName.isNotEmpty
            ? usuario.displayName
            : (usuario.nome.isNotEmpty ? usuario.nome : id);
        nomesCriadores[id] = nomeCompleto;
      } else {
        // Se não encontrou o usuário, mantém o ID ou usa fallback
        nomesCriadores[id] = 'Usuário desconhecido';
      }
    }

    // Atualiza os eventos com os nomes dos criadores
    // Como Evento é imutável, precisamos recriar os objetos
    for (int i = 0; i < eventos.length; i++) {
      final evento = eventos[i];
      final criadorId = evento.criador;

      // Se o criador é um UUID e temos o nome, substitui
      if (criadorId.isNotEmpty &&
          criadorId.length > 20 &&
          criadorId.contains('-') &&
          nomesCriadores.containsKey(criadorId)) {
        final nomeCriador = nomesCriadores[criadorId]!;
        // Recria o evento com o nome do criador
        eventos[i] = Evento(
          id: evento.id,
          titulo: evento.titulo,
          descricao: evento.descricao,
          autor: nomeCriador,
          criador: nomeCriador,
          cursoAutor: evento.cursoAutor,
          autorAvatarUrl: evento.autorAvatarUrl,
          imagemUrl: evento.imagemUrl,
          data: evento.data,
          inicio: evento.inicio,
          fim: evento.fim,
          categoria: evento.categoria,
          participantes: evento.participantes,
        );
      }
    }
  }

  // POST /eventos - Cadastra um novo evento via Multipart (dados + foto)
  static Future<Map<String, dynamic>> criarEvento(
      Map<String, dynamic> dadosEvento,
      [dynamic imagem]) async {
    final token = await _storage.read(key: 'token');
    if (token == null)
      return {'success': false, 'error': 'Token não encontrado.'};

    try {
      final request = http.MultipartRequest('POST', Uri.parse(_baseUrl));
      request.headers['Authorization'] = 'Bearer $token';

      // Parte 1: JSON do evento
      request.files.add(http.MultipartFile.fromString(
        'dados',
        jsonEncode(dadosEvento),
        contentType: MediaType('application', 'json'),
      ));

      // Parte 2: Arquivo da foto
      if (imagem != null) {
        if (kIsWeb && imagem is XFile) {
          final bytes = await imagem.readAsBytes();
          request.files.add(http.MultipartFile.fromBytes('fotos', bytes,
              filename: imagem.name,
              contentType: _mimeTypeForPath(imagem.name)));
        } else if (imagem is File) {
          request.files.add(await http.MultipartFile.fromPath(
              'fotos', imagem.path,
              contentType: _mimeTypeForPath(imagem.path)));
        } else if (imagem is XFile) {
          request.files.add(await http.MultipartFile.fromPath(
              'fotos', imagem.path,
              contentType: _mimeTypeForPath(imagem.name)));
        }
      }

      final response = await http.Response.fromStream(
          await request.send().timeout(const Duration(seconds: 20)));
      final body = utf8.decode(response.bodyBytes);
      print('[EventosApi] Status: ${response.statusCode}');
      print('[EventosApi] Response Body: $body');

      dynamic decodedBody;
      try {
        decodedBody = body.isNotEmpty ? jsonDecode(body) : null;
      } catch (e) {
        print('[EventosApi] Erro ao decodificar JSON: $e');
        decodedBody = body;
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('[EventosApi] Headers recebidos: ${response.headers}');

        // Tenta extrair ID do header Location primeiro (case-insensitive)
        String? eventId;
        response.headers.forEach((key, value) {
          if (key.toLowerCase() == 'location') {
            eventId = _extractEventIdFromHeaders({key: value});
          }
        });

        if (eventId == null) {
          eventId = _extractEventIdFromBody(decodedBody);
        }

        print('[EventosApi] ID Extraído: $eventId');
        return {'success': true, 'eventId': eventId};
      }
      return {
        'success': false,
        'error': _extractMessage(decodedBody) ?? 'Erro ${response.statusCode}',
        'details': decodedBody
      };
    } catch (e) {
      return {'success': false, 'error': 'Erro de conexão: $e'};
    }
  }

  // Extrai o ID do evento do header Location
  static String? _extractEventIdFromHeaders(Map<String, String> headers) {
    final location = headers['location'] ?? headers['Location'];
    if (location == null || location.isEmpty) return null;
    final sanitized = location.split('?').first;
    final segments =
        sanitized.split('/').where((segment) => segment.isNotEmpty).toList();
    return segments.isNotEmpty ? segments.last : null;
  }

  // Extrai o ID do evento do body da resposta
  static String? _extractEventIdFromBody(dynamic data) {
    if (data == null) return null;
    if (data is Map<String, dynamic>) {
      // Tenta encontrar ID diretamente
      final directId = data['id'];
      if (directId is String && directId.isNotEmpty) return directId;

      // Tenta encontrar em evento.id
      final evento = data['evento'];
      if (evento is Map<String, dynamic>) {
        final nestedId = evento['id'];
        if (nestedId is String && nestedId.isNotEmpty) return nestedId;
      }
    }
    return null;
  }

  // POST /fotos - Envia imagem para um evento
  // Aceita File (mobile/desktop) ou Uint8List (Web)
  static Future<Map<String, dynamic>> enviarImagemEvento(
    dynamic arquivo,
    String eventoId, {
    String? nomeArquivo,
    String? mimeTypeString,
  }) async {
    final token = await _storage.read(key: 'token');
    if (token == null) {
      return {
        'success': false,
        'error': 'Token não encontrado. Faça login novamente.',
      };
    }

    if (WebChecks.isMixedContent(ApiConfig.base)) {
      throw Exception(
          'Mixed content bloqueado no navegador: app https x API http.');
    }

    final url = Uri.parse('${ApiConfig.base}/fotos');

    try {
      final request = http.MultipartRequest('POST', url);
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      // Adiciona o arquivo - suporta tanto File quanto Uint8List (Web)
      MediaType mimeType;
      if (kIsWeb && arquivo is Uint8List) {
        // No Web, usa os bytes diretamente
        if (mimeTypeString != null) {
          try {
            mimeType = MediaType.parse(mimeTypeString);
          } catch (_) {
            // Se falhar ao parsear, tenta inferir do nome do arquivo
            mimeType = _mimeTypeForPath(nomeArquivo ?? 'imagem.jpg');
          }
        } else {
          // Tenta inferir do nome do arquivo
          mimeType = _mimeTypeForPath(nomeArquivo ?? 'imagem.jpg');
        }
        request.files.add(http.MultipartFile.fromBytes(
          'fotos',
          arquivo,
          filename: nomeArquivo ?? 'imagem.jpg',
          contentType: mimeType,
        ));
      } else if (arquivo is File) {
        // Em outras plataformas, usa File
        mimeType = _mimeTypeForPath(arquivo.path);
        request.files.add(await http.MultipartFile.fromPath(
          'fotos',
          arquivo.path,
          contentType: mimeType,
        ));
      } else {
        return {
          'success': false,
          'error': 'Tipo de arquivo não suportado. Use File ou Uint8List.',
        };
      }

      // Adiciona os dados do evento
      request.files.add(http.MultipartFile.fromString(
        'dados',
        jsonEncode({'tipo': 'EVENTO', 'id': eventoId}),
        contentType: MediaType('application', 'json'),
      ));

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

      return {
        'success': false,
        'message': _extractMessage(data) ?? 'Falha ao anexar imagem.',
        'details': data,
        'statusCode': streamed.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro ao anexar imagem: ${e.toString()}',
      };
    }
  }

  // Determina o MIME type baseado na extensão do arquivo (path ou nome)
  static MediaType _mimeTypeForPath(String pathOrName) {
    final parts = pathOrName.split('.');
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



  // Extrai mensagem de erro do body da resposta
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
}

/// Operações de API relacionadas a Categorias.
class CategoriaApi {
  static final String _baseUrl = ApiConfig.categorias();
  static final _storage = FlutterSecureStorage();

  // GET /categorias - Busca lista de categorias
  static Future<List<Categoria>> fetchCategorias() async {
    final token = await _storage.read(key: 'token');
    if (token == null) throw Exception('Token não encontrado.');

    if (WebChecks.isMixedContent(ApiConfig.base)) {
      throw Exception(
          'Mixed content bloqueado no navegador: app https x API http.');
    }

    // Supondo que queremos todas as categorias, podemos usar um size grande.
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final url = Uri.parse('$_baseUrl?size=100&_t=$timestamp');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token'
    }).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> list =
          data['_embedded']?['categoriaResourceV1List'] ?? [];
      return list.map((item) => Categoria.fromJson(item['categoria'])).toList();
    } else {
      throw Exception('Falha ao carregar categorias: ${response.statusCode}');
    }
  }
}

