import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_application_1/config/api_config.dart';
import 'package:flutter_application_1/utils/web_checks.dart';

// Modelos centralizados
import 'package:flutter_application_1/models/usuario.dart';
import 'package:flutter_application_1/models/evento.dart';
import 'package:flutter_application_1/models/course_option.dart';

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
      final usuarios = list.map((item) => Usuario.fromJson(item['user'])).toList();
      // Filtra apenas usuários ativos (is_active = true)
      // Usuários desativados não devem ser exibidos na lista
      return usuarios.where((usuario) => usuario.active == true).toList();
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
            headers: {
              'Authorization': 'Bearer $token', 
              'Content-Type': 'application/json; charset=utf-8',
              'Accept': 'application/json',
            },
            body: jsonEncode(dadosUsuario),
          )
          .timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
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

  // GET /usuarios/{id} - Busca um usuário específico por ID
  static Future<Usuario?> buscarUsuarioPorId(String id) async {
    final token = await _storage.read(key: 'token');
    if (token == null) {
      // Se não houver token, retorna null (pode ser listagem pública)
      return null;
    }

    if (WebChecks.isMixedContent(ApiConfig.base)) {
      throw Exception('Mixed content bloqueado no navegador: app https x API http.');
    }

    final url = Uri.parse('$_baseUrl/$id');
    try {
      final response = await http
          .get(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

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

  // GET /cursos - Lista todos os cursos pré-cadastrados
  static Future<List<CourseOption>> listarCursos() async {
    // Lista fixa dos 38 cursos pré-cadastrados conforme a API
    final cursosPreCadastrados = [
      'Administração',
      'Arquitetura e Urbanismo',
      'Artes',
      'Biomedicina',
      'Celulose e Papel',
      'Ciência da Computação',
      'Ciências Biológicas Bacharelado',
      'Ciências Biológicas Licenciatura',
      'Ciências Contábeis',
      'Design',
      'Design de Moda',
      'Educação Física - Bacharelado',
      'Educação Física - Licenciatura',
      'Enfermagem',
      'Engenharia Agronômica',
      'Engenharia Civil',
      'Engenharia de Computação',
      'Engenharia de Produção',
      'Engenharia Elétrica',
      'Engenharia Mecânica',
      'Engenharia Química',
      'Estética e Cosmética',
      'Farmácia',
      'Fisioterapia',
      'Gastronomia',
      'História',
      'Jogos Digitais',
      'Jornalismo',
      'Letras - Português e Inglês - Licenciatura',
      'Letras - Tradutor - Bacharelado',
      'Matemática',
      'Nutrição',
      'Odontologia',
      'Pedagogia',
      'Psicologia',
      'Publicidade e Propaganda',
      'Relações Internacionais',
      'Teatro',
    ];

    return cursosPreCadastrados.map((nome) => CourseOption(
      id: nome, // Usar o nome como ID para referência
      nome: nome,
    )).toList();
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
      
      final response = await http
          .get(url, headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 10));
      
      print('[UsuarioApi] Teste de conectividade - Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('[UsuarioApi] Teste de conectividade: SUCESSO');
        return true;
      } else {
        print('[UsuarioApi] Teste de conectividade: FALHOU - ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('[UsuarioApi] Teste de conectividade: ERRO - $e');
      return false;
    }
  }
}

// =================== API DE EVENTOS ===================
class EventosApi {
  static final String _baseUrl = ApiConfig.eventos();
  static final _storage = FlutterSecureStorage();

  // GET /eventos - Busca lista paginada de eventos
  static Future<List<Evento>> fetchEventos(int page, int pageSize, {String search = ''}) async {
    // Token opcional - a API não requer autenticação
    final token = await _storage.read(key: 'token');

    if (WebChecks.isMixedContent(ApiConfig.base)) {
      throw Exception('Mixed content bloqueado no navegador: app https x API http.');
    }

    final url = Uri.parse('$_baseUrl?page=$page&size=$pageSize&sortBy=dateInicio&name=$search');
    
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
      final List<dynamic> list = data['_embedded']?['eventoResourceV1List'] ?? [];
      final eventos = list.map((item) => Evento.fromJson(item['evento'])).toList();
      
      // Buscar nomes dos criadores se houver token
      if (token != null && token.isNotEmpty && eventos.isNotEmpty) {
        await _enriquecerNomesCriadores(eventos);
      }
      
      return eventos;
    } else if (response.statusCode == 404) {
      // API retorna 404 quando não há eventos (EventNotFoundException)
      return [];
    } else {
      throw Exception('Falha ao carregar eventos: ${response.statusCode}');
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
    final usuariosFutures = criadoresIds.map((id) => UsuarioApi.buscarUsuarioPorId(id));
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
  
  // POST /eventos - Cadastra um novo evento
  static Future<Map<String, dynamic>> criarEvento(Map<String, dynamic> dadosEvento, [dynamic imagem]) async {
    final token = await _storage.read(key: 'token');
    if (token == null) {
      return {
        'success': false,
        'error': 'Token não encontrado. Faça login novamente.',
      };
    }

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

      final responseBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 201) {
        // Extrair ID do evento do header Location ou do body
        String? eventId = _extractEventIdFromHeaders(response.headers);
        
        // Se não encontrou no header, tenta no body
        if (eventId == null && responseBody.isNotEmpty) {
          try {
            final data = jsonDecode(responseBody);
            eventId = _extractEventIdFromBody(data);
          } catch (_) {
            // Body não é JSON válido, ignora
          }
        }

        return {
          'success': true,
          'eventId': eventId,
        };
      } else {
        // Tenta extrair mensagem de erro do body
        String errorMessage = 'Erro ao criar evento';
        try {
          final errorData = jsonDecode(responseBody);
          errorMessage = errorData['message'] ?? 
                         errorData['error'] ?? 
                         errorData['detail'] ??
                         errorMessage;
        } catch (_) {
          errorMessage = responseBody.isNotEmpty 
              ? responseBody 
              : 'Erro ${response.statusCode}';
        }
        
        return {
          'success': false,
          'error': errorMessage,
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro de conexão: ${e.toString()}',
      };
    }
  }

  // Extrai o ID do evento do header Location
  static String? _extractEventIdFromHeaders(Map<String, String> headers) {
    final location = headers['location'] ?? headers['Location'];
    if (location == null || location.isEmpty) return null;
    final sanitized = location.split('?').first;
    final segments = sanitized.split('/').where((segment) => segment.isNotEmpty).toList();
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
      throw Exception('Mixed content bloqueado no navegador: app https x API http.');
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
          'foto',
          arquivo,
          filename: nomeArquivo ?? 'imagem.jpg',
          contentType: mimeType,
        ));
      } else if (arquivo is File) {
        // Em outras plataformas, usa File
        mimeType = _mimeTypeForPath(arquivo.path);
        request.files.add(await http.MultipartFile.fromPath(
          'foto',
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

// =================== API DE CURSOS ===================
class CursoApi {
  static const String _baseUrl = '${ApiConfig.base}/cursos';
  static final _storage = FlutterSecureStorage();
  
  // GET /cursos - Lista todos os cursos disponíveis
  static Future<List<Map<String, dynamic>>> listarCursos() async {
    final token = await _storage.read(key: 'token');
    if (token == null) {
      print('[CursoApi] Erro: Token não encontrado');
      return [];
    }

    if (WebChecks.isMixedContent(ApiConfig.base)) {
      print('[CursoApi] Erro: Mixed content bloqueado');
      return [];
    }

    try {
      final response = await http
          .get(
            Uri.parse(_baseUrl),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> cursos = jsonDecode(response.body);
        return cursos.cast<Map<String, dynamic>>();
      } else {
        print('[CursoApi] Erro: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print("[CursoApi] Erro de conexão: $e");
      return [];
    }
  }
}
