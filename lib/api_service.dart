import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_application_1/config/api_config.dart';
import 'package:flutter_application_1/utils/web_checks.dart';

// Modelos centralizados
import 'package:flutter_application_1/models/usuario.dart';
import 'package:flutter_application_1/models/evento.dart';

// Modelo para Categoria, baseado no Swagger
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

// --- CLASSE CENTRALIZADA PARA TODAS AS OPERAÇÕES DE API DE USUÁRIO ---
class UsuarioApi {
  static final String _baseUrl = ApiConfig.usuarios();
  static final _storage = FlutterSecureStorage();

  // GET /usuarios - Busca uma lista paginada de usuários
  static Future<List<Usuario>> fetchUsuarios(int page, int pageSize, String search) async {
    final token = await _storage.read(key: 'token');
    if (token == null) throw Exception('Token não encontrado.');

    if (WebChecks.isMixedContent(ApiConfig.base)) {
      throw Exception('Mixed content bloqueado no navegador: app https x API http.');
    }

    final url = Uri.parse('$_baseUrl?page=$page&size=$pageSize&sortBy=nome&name=$search');
    final response = await http
        .get(url, headers: {'Authorization': 'Bearer $token'})
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> list = data['_embedded']?['usuarioResourceV1List'] ?? [];
      return list.map((item) => Usuario.fromJson(item['user'])).toList();
    } else {
      throw Exception('Falha ao carregar usuários: ${response.statusCode}');
    }
  }

  // POST /usuarios - Cadastra um novo usuário
  static Future<bool> criarUsuario(Map<String, dynamic> dadosUsuario) async {
    final token = await _storage.read(key: 'token');
    if (token == null) return false;

    if (WebChecks.isMixedContent(ApiConfig.base)) {
      throw Exception('Mixed content bloqueado no navegador: app https x API http.');
    }

    final url = Uri.parse(_baseUrl);
    try {
      final response = await http
          .post(
            url,
            headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
            body: jsonEncode(dadosUsuario),
          )
          .timeout(const Duration(seconds: 15));
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print("Erro ao criar usuário: $e");
      return false;
    }
  }

  // PATCH /usuarios/{id} - Atualiza um usuário existente
  static Future<bool> atualizarUsuario(String usuarioId, Map<String, dynamic> dadosUsuario) async {
    final token = await _storage.read(key: 'token');
    if (token == null) return false;

    if (WebChecks.isMixedContent(ApiConfig.base)) {
      throw Exception('Mixed content bloqueado no navegador: app https x API http.');
    }

    final url = Uri.parse('$_baseUrl/$usuarioId');
    try {
      final response = await http
          .patch(
            url,
            headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
            body: jsonEncode(dadosUsuario),
          )
          .timeout(const Duration(seconds: 15));
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print("Erro ao atualizar usuário: $e");
      return false;
    }
  }

  // DELETE /usuarios/{id} - Inativa (deleta) um usuário
  static Future<bool> deletarUsuario(String usuarioId) async {
    final token = await _storage.read(key: 'token');
    if (token == null) return false;

    if (WebChecks.isMixedContent(ApiConfig.base)) {
      throw Exception('Mixed content bloqueado no navegador: app https x API http.');
    }

    final url = Uri.parse('$_baseUrl/$usuarioId');
    try {
      final response = await http
          .delete(
            url,
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 15));
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print("Erro ao deletar usuário: $e");
      return false;
    }
  }

  // GET /usuarios/me - Busca os dados do próprio usuário logado
  // (Esta função pode ficar no seu UserService.dart ou ser movida para cá)
  static Future<Map<String, dynamic>?> buscarUsuarioLogado() async {
    final token = await _storage.read(key: 'token');
    if (token == null) return null;

    if (WebChecks.isMixedContent(ApiConfig.base)) {
      throw Exception('Mixed content bloqueado no navegador: app https x API http.');
    }

    final url = Uri.parse('$_baseUrl/me');
    try {
        final response = await http
            .get(url, headers: {'Authorization': 'Bearer $token'})
            .timeout(const Duration(seconds: 15));
        if (response.statusCode == 200) {
            return json.decode(utf8.decode(response.bodyBytes));
        }
        return null;
    } catch (e) {
        print("Erro ao buscar usuário logado: $e");
        return null;
    }
  }
}

// =================== API DE EVENTOS ===================
class EventosApi {
  static final String _baseUrl = ApiConfig.eventos();
  static final _storage = FlutterSecureStorage();

  // GET /eventos - Busca lista paginada de eventos
  static Future<List<Evento>> fetchEventos(int page, int pageSize, {String search = ''}) async {
    final token = await _storage.read(key: 'token');
    if (token == null) throw Exception('Token não encontrado.');

    if (WebChecks.isMixedContent(ApiConfig.base)) {
      throw Exception('Mixed content bloqueado no navegador: app https x API http.');
    }

    final url = Uri.parse('$_baseUrl?page=$page&size=$pageSize&sortBy=dateInicio&name=$search');
    final response = await http
        .get(url, headers: {'Authorization': 'Bearer $token'})
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> list = data['_embedded']?['eventoResourceV1List'] ?? [];
      return list.map((item) => Evento.fromJson(item['evento'])).toList();
    } else {
      throw Exception('Falha ao carregar eventos: ${response.statusCode}');
    }
  }
  
  // POST /eventos - Cadastra um novo evento
  static Future<bool> criarEvento(Map<String, dynamic> dadosEvento) async {
    final token = await _storage.read(key: 'token');
    if (token == null) return false;

    if (WebChecks.isMixedContent(ApiConfig.base)) {
      throw Exception('Mixed content bloqueado no navegador: app https x API http.');
    }

    final url = Uri.parse(_baseUrl);
    try {
      final response = await http
          .post(
            url,
            headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
            body: jsonEncode(dadosEvento),
          )
          .timeout(const Duration(seconds: 15));
      return response.statusCode == 201;
    } catch (e) {
      print("Erro ao criar evento: $e");
      return false;
    }
  }
}

// =================== API DE CATEGORIAS ===================
class CategoriaApi {
  static final String _baseUrl = ApiConfig.categorias();
  static final _storage = FlutterSecureStorage();
  
  // GET /categorias - Busca lista de categorias
  static Future<List<Categoria>> fetchCategorias() async {
    final token = await _storage.read(key: 'token');
    if (token == null) throw Exception('Token não encontrado.');

    if (WebChecks.isMixedContent(ApiConfig.base)) {
      throw Exception('Mixed content bloqueado no navegador: app https x API http.');
    }

    // Supondo que queremos todas as categorias, podemos usar um size grande.
    final url = Uri.parse('$_baseUrl?size=100');
    final response = await http
        .get(url, headers: {'Authorization': 'Bearer $token'})
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> list = data['_embedded']?['categoriaResourceV1List'] ?? [];
      return list.map((item) => Categoria.fromJson(item['categoria'])).toList();
    } else {
      throw Exception('Falha ao carregar categorias: ${response.statusCode}');
    }
  }
}
