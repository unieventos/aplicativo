import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_application_1/config/api_config.dart';
import 'package:flutter_application_1/utils/web_checks.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/models/course_option.dart';
import 'package:flutter_application_1/models/managed_user.dart';
import 'package:flutter_application_1/models/user_profile.dart';

// --- SERVIÇO DE USUÁRIO REATORADO ---
// Responsável por buscar os dados do usuário logado e salvá-los localmente.
class UserService {
  // A URL base da API para facilitar futuras manutenções.
  static const String _baseUrl = ApiConfig.base;

  static const String _usuariosPath = '/usuarios';

  // Lista categorias do backend
  static Future<List<String>> listarCategorias() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');

    if (token == null || token.isEmpty) {
      throw Exception('Token não encontrado');
    }

    final url = Uri.parse('$_baseUrl/categorias?page=0&size=100&sortBy=id');
    try {
      print('[UserService] GET $url');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final bodyText = utf8.decode(response.bodyBytes);
        final data = jsonDecode(bodyText);

        // Suporta dois formatos comuns: lista simples de strings ou lista de objetos com campo nome
        if (data is List) {
          return data
              .map<String>((item) {
                if (item is String) return item;
                if (item is Map<String, dynamic>) {
                  return (item['nome'] ??
                          item['name'] ??
                          item['categoria'] ??
                          '')
                      .toString();
                }
                return item.toString();
              })
              .where((e) => e.isNotEmpty)
              .toList();
        }

        // Caso venha embrulhado em _embedded, conforme Swagger
        if (data is Map<String, dynamic> && data['_embedded'] != null) {
          final embedded = data['_embedded'] as Map<String, dynamic>;
          final rawList = (embedded['categoriaResourceV1List'] ??
              embedded['categoriaList'] ??
              []) as List;
          return rawList
              .map<String>((item) {
                if (item is Map<String, dynamic>) {
                  final categoriaObj = item['categoria'];
                  if (categoriaObj is Map<String, dynamic>) {
                    // nomeCategoria é o campo do schema enviado
                    final nome = (categoriaObj['nomeCategoria'] ??
                        categoriaObj['nome'] ??
                        categoriaObj['name']);
                    if (nome != null) return nome.toString();
                  }
                  // fallback para nomes diretos
                  final nomeAlt =
                      item['nomeCategoria'] ?? item['nome'] ?? item['name'];
                  if (nomeAlt != null) return nomeAlt.toString();
                }
                return item.toString();
              })
              .where((e) => e.isNotEmpty)
              .toList();
        }

        throw Exception('Formato inesperado de categorias');
      } else if (response.statusCode == 404) {
        // Considera como "sem categorias" e tenta fallback opcional
        final fallback = Uri.parse(
            'http://172.171.192.14:8080/unieventos/categorias?page=0&size=100&sortBy=id');
        print('[UserService] 404 em $url, tentando fallback $fallback');
        final resp2 = await http.get(
          fallback,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );
        if (resp2.statusCode == 200) {
          final bodyText = utf8.decode(resp2.bodyBytes);
          final data = jsonDecode(bodyText);
          if (data is List) {
            return data
                .map<String>((item) {
                  if (item is String) return item;
                  if (item is Map<String, dynamic>) {
                    return (item['nome'] ??
                            item['name'] ??
                            item['categoria'] ??
                            '')
                        .toString();
                  }
                  return item.toString();
                })
                .where((e) => e.isNotEmpty)
                .toList();
          }
          if (data is Map<String, dynamic> && data['_embedded'] != null) {
            final list = (data['_embedded']['categoriaList'] ?? []) as List;
            return list
                .map<String>((item) {
                  if (item is Map<String, dynamic>) {
                    final obj = (item['categoria'] ?? item);
                    if (obj is Map<String, dynamic>) {
                      return (obj['nome'] ?? obj['name'] ?? '').toString();
                    }
                  }
                  return item.toString();
                })
                .where((e) => e.isNotEmpty)
                .toList();
          }
          throw Exception('Formato inesperado de categorias (fallback)');
        }
        // Se também deu 404 no fallback, retorna lista vazia para o app lidar graciosamente
        print(
            '[UserService] Fallback também retornou ${resp2.statusCode}. Retornando lista vazia.');
        return <String>[];
      } else {
        final body = utf8.decode(response.bodyBytes);
        print('[UserService] Erro categorias ${response.statusCode}: $body');
        throw Exception('Erro ao listar categorias: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Lista categorias com id e nome
  static Future<List<Map<String, String>>> listarCategoriasDetalhadas() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    if (token == null || token.isEmpty) throw Exception('Token não encontrado');

    final url = Uri.parse('$_baseUrl/categorias?page=0&size=100&sortBy=id');
    print('[UserService] GET $url (detalhadas)');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final text = utf8.decode(response.bodyBytes);
      final data = jsonDecode(text);
      final List<Map<String, String>> result = [];
      if (data is Map<String, dynamic> && data['_embedded'] != null) {
        final embedded = data['_embedded'] as Map<String, dynamic>;
        final rawList = (embedded['categoriaResourceV1List'] ??
            embedded['categoriaList'] ??
            []) as List;
        for (final item in rawList) {
          if (item is Map<String, dynamic>) {
            final categoria = item['categoria'];
            if (categoria is Map<String, dynamic>) {
              final id = (categoria['id'] ?? '').toString();
              final nome = (categoria['nomeCategoria'] ??
                      categoria['nome'] ??
                      categoria['name'] ??
                      '')
                  .toString();
              if (id.isNotEmpty && nome.isNotEmpty) {
                result.add({'id': id, 'nome': nome});
              }
            }
          }
        }
      } else if (data is List) {
        for (final item in data) {
          if (item is Map<String, dynamic>) {
            final id = (item['id'] ?? item['categoriaId'] ?? '').toString();
            final nome =
                (item['nomeCategoria'] ?? item['nome'] ?? item['name'] ?? '')
                    .toString();
            if (id.isNotEmpty && nome.isNotEmpty) {
              result.add({'id': id, 'nome': nome});
            }
          }
        }
      }
      return result;
    }

    // fallback 8080
    final fb = Uri.parse(
        'http://172.171.192.14:8080/unieventos/categorias?page=0&size=100&sortBy=id');
    print(
        '[UserService] ${response.statusCode} em $url, tentando $fb (detalhadas)');
    final r2 = await http.get(
      fb,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    if (r2.statusCode == 200) {
      final text = utf8.decode(r2.bodyBytes);
      final data = jsonDecode(text);
      final List<Map<String, String>> result = [];
      if (data is Map<String, dynamic> && data['_embedded'] != null) {
        final embedded = data['_embedded'] as Map<String, dynamic>;
        final rawList = (embedded['categoriaResourceV1List'] ??
            embedded['categoriaList'] ??
            []) as List;
        for (final item in rawList) {
          if (item is Map<String, dynamic>) {
            final categoria = item['categoria'];
            if (categoria is Map<String, dynamic>) {
              final id = (categoria['id'] ?? '').toString();
              final nome = (categoria['nomeCategoria'] ??
                      categoria['nome'] ??
                      categoria['name'] ??
                      '')
                  .toString();
              if (id.isNotEmpty && nome.isNotEmpty) {
                result.add({'id': id, 'nome': nome});
              }
            }
          }
        }
      } else if (data is List) {
        for (final item in data) {
          if (item is Map<String, dynamic>) {
            final id = (item['id'] ?? item['categoriaId'] ?? '').toString();
            final nome =
                (item['nomeCategoria'] ?? item['nome'] ?? item['name'] ?? '')
                    .toString();
            if (id.isNotEmpty && nome.isNotEmpty) {
              result.add({'id': id, 'nome': nome});
            }
          }
        }
      }
      return result;
    }
    print(
        '[UserService] Fallback categorias detalhadas retornou ${r2.statusCode}');
    return <Map<String, String>>[];
  }

  static Future<List<CourseOption>> listarCursos() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    if (token == null || token.isEmpty) throw Exception('Token não encontrado');
    final uri = Uri.parse(ApiConfig.cursos());
    final response = await http
        .get(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      final body = utf8.decode(response.bodyBytes);
      final data = jsonDecode(body);
      final List<CourseOption> result = [];
      if (data is List) {
        for (final item in data) {
          final m = item is Map<String, dynamic> ? item : <String, dynamic>{};
          final id = (m['id'] ?? m['cursoId'] ?? '').toString();
          final nome = (m['nomeCurso'] ?? m['nome'] ?? m['name'] ?? '').toString();
          if (id.isNotEmpty && nome.isNotEmpty) {
            result.add(CourseOption(id: id, nome: nome));
          }
        }
        return result;
      }
      if (data is Map<String, dynamic>) {
        final list = data['_embedded']?['cursoResourceV1List'];
        if (list is List) {
          for (final item in list) {
            final c = item is Map<String, dynamic> ? (item['curso'] ?? item) : item;
            final id = (c['id'] ?? c['cursoId'] ?? '').toString();
            final nome = (c['nomeCurso'] ?? c['nome'] ?? c['name'] ?? '').toString();
            if (id.isNotEmpty && nome.isNotEmpty) {
              result.add(CourseOption(id: id, nome: nome));
            }
          }
        }
        return result;
      }
      return <CourseOption>[];
    }
    final body = utf8.decode(response.bodyBytes);
    print('[UserService] Erro ao listar cursos (${response.statusCode}): $body');
    return <CourseOption>[];
  }

  static Future<CourseOption?> criarCurso(String nome) async {
    final created = await criarCategoria(nome);
    if (created == null) return null;
    final id = created['id'] ?? '';
    final nomeFinal = created['nome'] ?? nome;
    if (id.isEmpty) return null;
    return CourseOption(id: id, nome: nomeFinal);
  }

  static Future<bool> atualizarCurso(String id, String nome) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    if (token == null || token.isEmpty) throw Exception('Token não encontrado');

    final uri = Uri.parse('$_baseUrl/categorias/$id');
    final response = await http.patch(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'nomeCategoria': nome}),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200 ||
        response.statusCode == 204 ||
        response.statusCode == 202) {
      return true;
    }

    final body = utf8.decode(response.bodyBytes);
    print('[UserService] Erro ao atualizar curso (${response.statusCode}): $body');
    return false;
  }

  static Future<bool> deletarCurso(String id) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    if (token == null || token.isEmpty) throw Exception('Token não encontrado');

    final uri = Uri.parse('$_baseUrl/categorias/$id');
    final response = await http.delete(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200 ||
        response.statusCode == 204 ||
        response.statusCode == 202) {
      return true;
    }

    final body = utf8.decode(response.bodyBytes);
    print('[UserService] Erro ao deletar curso (${response.statusCode}): $body');
    return false;
  }

  // Cria uma categoria
  static Future<Map<String, String>?> criarCategoria(
      String nomeCategoria) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    if (token == null || token.isEmpty) throw Exception('Token não encontrado');

    final url = Uri.parse('$_baseUrl/categorias');
    print('[UserService] POST $url {nomeCategoria: $nomeCategoria}');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'nomeCategoria': nomeCategoria}),
    );

    final body = utf8.decode(response.bodyBytes);
    print(
        '[UserService] Resposta criar categoria ${response.statusCode}: $body');
    print('[UserService] Headers: ${response.headers}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final data = body.isNotEmpty ? jsonDecode(body) : null;
        // tenta extrair id/nome de diferentes formatos
        String id = '';
        String nome = nomeCategoria;
        
        if (data is Map<String, dynamic>) {
          if (data['categoria'] is Map<String, dynamic>) {
            final c = data['categoria'] as Map<String, dynamic>;
            id = (c['id'] ?? '').toString();
            nome = (c['nomeCategoria'] ?? nome).toString();
            print('[UserService] ID extraído do objeto categoria: $id');
          } else {
            id = (data['id'] ?? '').toString();
            nome = (data['nomeCategoria'] ?? data['nome'] ?? nome).toString();
            print('[UserService] ID extraído do objeto raiz: $id');
          }
        }
        
        // Se não encontrou no body, tenta no header Location
        if (id.isEmpty) {
          final location =
              response.headers['location'] ?? response.headers['Location'];
          print('[UserService] Tentando extrair ID do header Location: $location');
          if (location != null && location.isNotEmpty) {
            // Remove query parameters se houver
            final locationPath = location.split('?').first;
            final segments = locationPath.split('/').where((s) => s.isNotEmpty).toList();
            if (segments.isNotEmpty) {
              id = segments.last;
              print('[UserService] ID extraído do header Location: $id');
            } else {
              print('[UserService] AVISO: Location header não contém segmentos válidos');
            }
          }
        }
        
        if (nome.isEmpty) nome = nomeCategoria;
        
        if (id.isEmpty) {
          print('[UserService] AVISO: Não foi possível extrair ID da categoria criada');
        } else {
          print('[UserService] Categoria criada com sucesso: ID=$id, Nome=$nome');
        }
        
        return {'id': id, 'nome': nome};
      } catch (e) {
        print('[UserService] Erro ao parsear resposta: $e');
        // Tenta extrair do header Location como fallback
        final location =
            response.headers['location'] ?? response.headers['Location'];
        print('[UserService] Fallback: tentando extrair do Location: $location');
        final id = (location != null && location.isNotEmpty)
            ? location
                .split('/')
                .where((s) => s.isNotEmpty)
                .toList()
                .lastOrNull ?? ''
            : '';
        if (id.isNotEmpty) {
          print('[UserService] ID extraído do Location (fallback): $id');
        }
        return {'id': id, 'nome': nomeCategoria};
      }
    }
    print('[UserService] Erro criar categoria ${response.statusCode}: $body');
    return null;
  }

  // O método agora é mais robusto e lida com mais cenários de erro.
  static Future<String?> buscarUsuario() async {
    final perfil = await obterPerfil(persistLocally: true);
    return perfil?.id;
  }

  static Future<UserProfile?> obterPerfil({bool persistLocally = false}) async {
    final storage = FlutterSecureStorage();

    final token = await storage.read(key: 'token');
    if (token == null || token.isEmpty) {
      print(
          '[UserService] Erro: Token de autenticação não encontrado. Impossível buscar perfil.');
      return null;
    }

    final url = Uri.parse('$_baseUrl/usuarios/me');
    try {
      if (WebChecks.isMixedContent(ApiConfig.base)) {
        throw Exception('Mixed content bloqueado no navegador: app https x API http.');
      }

      final response = await http
          .get(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = utf8.decode(response.bodyBytes);
        final decoded = jsonDecode(body);
        if (decoded is Map<String, dynamic> &&
            decoded['user'] is Map<String, dynamic>) {
          final profile =
              UserProfile.fromMap(decoded['user'] as Map<String, dynamic>);

          if (persistLocally) {
            await _persistProfile(storage, profile);
          }

          return profile;
        }

        print(
            '[UserService] Erro: Resposta da API inválida. Formato JSON inesperado.');
        return null;
      }

      print(
          '[UserService] Erro ao buscar perfil. Status: ${response.statusCode}');
      print('[UserService] Mensagem: ${utf8.decode(response.bodyBytes)}');
      return null;
    } catch (e) {
      print('[UserService] Erro de conexão ao buscar perfil: $e');
      return null;
    }
  }

  static Future<void> _persistProfile(
    FlutterSecureStorage storage,
    UserProfile profile,
  ) async {
    await storage.write(key: 'id', value: profile.id);
    await storage.write(key: 'nome', value: profile.nome);
    await storage.write(key: 'sobrenome', value: profile.sobrenome);
    await storage.write(key: 'email', value: profile.email);
    await storage.write(key: 'cursoId', value: profile.cursoId);
    await storage.write(key: 'role', value: profile.role);
    print('[UserService] Dados do usuário salvos com sucesso.');
  }

  static Future<List<ManagedUser>> listarUsuarios({
    int page = 0,
    int size = 10,
    String sortBy = 'nome',
    String search = '',
    bool? apenasAtivos,
  }) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    if (token == null || token.isEmpty) {
      throw Exception('Token não encontrado');
    }

    final uri = Uri.parse('$_baseUrl$_usuariosPath').replace(
      queryParameters: {
        'page': '$page',
        'size': '$size',
        'sortBy': sortBy,
        if (search.isNotEmpty) 'name': search,
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final bodyText = utf8.decode(response.bodyBytes);
      final data = jsonDecode(bodyText);
      
      if (data is Map<String, dynamic>) {
        final embedded = data['_embedded'];
        final list = embedded is Map<String, dynamic>
            ? embedded['usuarioResourceV1List']
            : null;
        if (list is List) {
          final usuarios = list
              .map((item) {
                if (item is Map<String, dynamic>) {
                  // Tenta obter o user, mas também verifica se active está no item pai
                  final userData = item['user'] ?? item['usuario'] ?? item;
                  if (userData is Map<String, dynamic>) {
                    // Tenta encontrar o campo active em várias localizações possíveis
                    // 1. No objeto user
                    // 2. No item pai
                    // 3. Com diferentes nomes (active, is_active, isActive, ativo)
                    dynamic activeValue = userData['active'] ?? 
                                         userData['is_active'] ?? 
                                         userData['isActive'] ?? 
                                         userData['ativo'] ??
                                         item['active'] ?? 
                                         item['is_active'] ?? 
                                         item['isActive'] ?? 
                                         item['ativo'];
                    
                    // Se encontrou o valor, adiciona ao userData para garantir que seja parseado
                    if (activeValue != null) {
                      userData['active'] = activeValue;
                      userData['is_active'] = activeValue;
                    }
                    
                    // Verifica e extrai o role se for um objeto
                    final roleRaw = userData['role'];
                    if (roleRaw is Map<String, dynamic>) {
                      // Role é um objeto, extrai o name
                      final roleName = roleRaw['name'] ?? roleRaw['role'] ?? '';
                      userData['role'] = roleName.toString();
                    } else if (roleRaw != null) {
                      // Role já é uma string, mantém como está
                      userData['role'] = roleRaw.toString();
                    }
                    
                    return userData;
                  }
                  return userData;
                }
                return null;
              })
              .whereType<Map<String, dynamic>>()
              .map(ManagedUser.fromApi)
              .toList();
          
          // Filtra conforme solicitado
          if (apenasAtivos == true) {
            return usuarios.where((usuario) => usuario.active == true).toList();
          } else if (apenasAtivos == false) {
            return usuarios.where((usuario) => usuario.active == false).toList();
          }
          
          // Se apenasAtivos for null, retorna todos
          return usuarios;
        }
      }
      return <ManagedUser>[];
    }

    if (response.statusCode == 204) {
      return <ManagedUser>[];
    }

    final body = utf8.decode(response.bodyBytes);
    print(
        '[UserService] Erro ao listar usuários (${response.statusCode}): $body');
    throw Exception('Erro ao listar usuários');
  }

  static Future<String?> criarUsuario({
    required String login,
    required String curso,
    required String nome,
    required String sobrenome,
    required String senha,
    String? email,
    String? role,
  }) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    if (token == null || token.isEmpty) {
      throw Exception('Token não encontrado');
    }

    final uri = Uri.parse('$_baseUrl$_usuariosPath');
    final payload = {
      'login': login,
      'curso': curso,
      'email': email,
      'senha': senha,
      'nome': nome,
      'sobrenome': sobrenome,
      'role': role,
    }..removeWhere((key, value) => value == null || value == '');

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );

    final responseBody = utf8.decode(response.bodyBytes);
    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        if (responseBody.isNotEmpty) {
          final decoded = jsonDecode(responseBody);
          if (decoded is Map<String, dynamic>) {
            final user = decoded['user'] ?? decoded['usuario'] ?? decoded;
            if (user is Map<String, dynamic> && user['id'] != null) {
              return user['id'].toString();
            }
            if (decoded['id'] != null) {
              return decoded['id'].toString();
            }
          }
        }
      } catch (_) {
        // fallback para Location header
      }

      final location =
          response.headers['location'] ?? response.headers['Location'];
      if (location != null && location.isNotEmpty) {
        return location
            .split('/')
            .lastWhere((segment) => segment.isNotEmpty, orElse: () => '');
      }
      return null;
    }

    print(
        '[UserService] Erro ao criar usuário (${response.statusCode}): $responseBody');
    return null;
  }

  static Future<bool> atualizarUsuario(
    String userId,
    Map<String, dynamic> payload,
  ) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    if (token == null || token.isEmpty) {
      throw Exception('Token não encontrado');
    }

    final filteredPayload = Map<String, dynamic>.from(payload)
      ..removeWhere((key, value) => value == null || (value is String && value.isEmpty));

    if (filteredPayload.isEmpty) {
      print('[UserService] Nenhum dado para atualizar. Ignorando chamada.');
      return true;
    }

    final uri = Uri.parse('$_baseUrl$_usuariosPath/$userId');
    
    try {
      final response = await http.patch(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(filteredPayload),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 202) {
        return true;
      }

      final body = utf8.decode(response.bodyBytes);
      print(
          '[UserService] Erro ao atualizar usuário (${response.statusCode}): $body');
      return false;
    } on http.ClientException catch (e) {
      // Trata erros de CORS especificamente
      final errorMessage = e.message.toLowerCase();
      if (errorMessage.contains('cors') || 
          errorMessage.contains('cross-origin') ||
          errorMessage.contains('networkerror')) {
        print('[UserService] Erro de CORS ao atualizar usuário. O backend precisa permitir o método PATCH nas configurações de CORS.');
        rethrow;
      }
      print('[UserService] Erro de conexão ao atualizar usuário: $e');
      rethrow;
    } catch (e) {
      print('[UserService] Erro inesperado ao atualizar usuário: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> deletarUsuario(String userId) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    if (token == null || token.isEmpty) {
      throw Exception('Token não encontrado');
    }

    final uri = Uri.parse('$_baseUrl$_usuariosPath/$userId');
    print('[UserService] DELETE $uri');
    
    final response = await http.delete(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    final body = utf8.decode(response.bodyBytes);
    print('[UserService] Response status: ${response.statusCode}, body: $body');

    if (response.statusCode == 200 ||
        response.statusCode == 202 ||
        response.statusCode == 204) {
      return {'sucesso': true, 'realmenteDeletado': true};
    }

    // Se o usuário não existe mais ou já está inativo (400/404), considera como sucesso
    // Erro 400 pode ser UserAlreadyInactive conforme comportamento da API
    if (response.statusCode == 400 || response.statusCode == 404) {
      // Verifica se é o erro específico UserAlreadyInactive
      final bodyLower = body.toLowerCase();
      if (bodyLower.contains('already') || 
          bodyLower.contains('inactive') || 
          bodyLower.contains('já está') ||
          bodyLower.contains('inativo')) {
        print('[UserService] Usuário já estava inativo: $userId');
        return {'sucesso': true, 'realmenteDeletado': false};
      }
      // Outros erros 400 ainda são tratados como sucesso (usuário não será exibido)
      print('[UserService] Erro 400/404 ao desativar (tratado como sucesso): $userId - $body');
      return {'sucesso': true, 'realmenteDeletado': false};
    }

    print(
        '[UserService] Erro ao deletar usuário (${response.statusCode}): $body');
    return {'sucesso': false, 'realmenteDeletado': false, 'mensagem': body};
  }
}
