import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_application_1/network/safe_http.dart';

// --- SERVIÇO DE USUÁRIO REATORADO ---
// Responsável por buscar os dados do usuário logado e salvá-los localmente.
class UserService {
  // A URL base da API para facilitar futuras manutenções.
  static const String _baseUrl = 'http://172.171.192.14:8081/unieventos';

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
      final response = await SafeHttp.get(
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
        final resp2 = await SafeHttp.get(
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
    final response = await SafeHttp.get(
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
    final r2 = await SafeHttp.get(
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

  // Cria uma categoria
  static Future<Map<String, String>?> criarCategoria(
      String nomeCategoria) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    if (token == null || token.isEmpty) throw Exception('Token não encontrado');

    final url = Uri.parse('$_baseUrl/categorias');
    print('[UserService] POST $url {nomeCategoria: $nomeCategoria}');
    final response = await SafeHttp.post(
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
    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final data = jsonDecode(body);
        // tenta extrair id/nome de diferentes formatos
        String id = '';
        String nome = nomeCategoria;
        if (data is Map<String, dynamic>) {
          if (data['categoria'] is Map<String, dynamic>) {
            final c = data['categoria'] as Map<String, dynamic>;
            id = (c['id'] ?? '').toString();
            nome = (c['nomeCategoria'] ?? nome).toString();
          } else {
            id = (data['id'] ?? '').toString();
            nome = (data['nomeCategoria'] ?? data['nome'] ?? nome).toString();
          }
        }
        if (id.isEmpty) {
          final location =
              response.headers['location'] ?? response.headers['Location'];
          if (location != null && location.isNotEmpty) {
            id = location
                .split('/')
                .lastWhere((segment) => segment.isNotEmpty, orElse: () => '');
          }
        }
        if (nome.isEmpty) nome = nomeCategoria;
        return {'id': id, 'nome': nome};
      } catch (_) {
        final location =
            response.headers['location'] ?? response.headers['Location'];
        final id = (location != null && location.isNotEmpty)
            ? location
                .split('/')
                .lastWhere((segment) => segment.isNotEmpty, orElse: () => '')
            : '';
        return {'id': id, 'nome': nomeCategoria};
      }
    }
    print('[UserService] Erro criar categoria ${response.statusCode}: $body');
    return null;
  }

  // O método agora é mais robusto e lida com mais cenários de erro.
  static Future<String?> buscarUsuario() async {
    final storage = FlutterSecureStorage();

    // 1. LÊ O TOKEN ARMAZENADO
    final token = await storage.read(key: 'token');

    // 2. VALIDAÇÃO DE SEGURANÇA: Se não houver token, interrompe a execução.
    // Isso evita uma chamada desnecessária à API que certamente falharia.
    if (token == null || token.isEmpty) {
      print(
          '[UserService] Erro: Token de autenticação não encontrado. Impossível buscar usuário.');
      return null;
    }

    // 3. BLOCO TRY-CATCH PARA CAPTURAR ERROS DE REDE
    // Captura problemas como falta de internet, DNS, ou servidor offline.
    try {
      final url = Uri.parse('$_baseUrl/usuarios/me');

      final response = await SafeHttp.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      // 4. VERIFICA A RESPOSTA DA API
      if (response.statusCode == 200) {
        // Sucesso! Decodifica a resposta.
        final body = jsonDecode(utf8.decode(response.bodyBytes));

        // VALIDAÇÃO: Verifica se o corpo da resposta e o objeto 'user' existem.
        if (body != null && body['user'] is Map<String, dynamic>) {
          final userData = body['user'];

          // 5. SALVA OS DADOS DO USUÁRIO NO STORAGE DE FORMA SEGURA
          // O '.toString()' garante que mesmo valores nulos ou de outros tipos sejam convertidos para string.
          await storage.write(key: 'id', value: userData['id']?.toString());
          await storage.write(key: 'nome', value: userData['nome']?.toString());
          await storage.write(
              key: 'sobrenome', value: userData['sobrenome']?.toString());
          await storage.write(
              key: 'email', value: userData['email']?.toString());
          await storage.write(
              key: 'cursoId', value: userData['cursoId']?.toString());
          await storage.write(key: 'role', value: userData['role']?.toString());

          print('[UserService] Dados do usuário salvos com sucesso.');
          return userData['id']?.toString();
        } else {
          // Se a resposta for 200, mas o JSON não tiver o formato esperado.
          print(
              '[UserService] Erro: Resposta da API inválida. Formato JSON inesperado.');
          return null;
        }
      } else {
        // Se a API retornar um código de erro (401, 403, 500, etc.)
        print(
            '[UserService] Erro ao buscar usuário. Status: ${response.statusCode}');
        print('[UserService] Mensagem: ${utf8.decode(response.bodyBytes)}');
        return null;
      }
    } catch (e) {
      // Se a chamada de rede falhar completamente (sem conexão, CORS, etc.)
      print('[UserService] Erro de conexão ao buscar usuário: $e');
      return null;
    }
  }
}
