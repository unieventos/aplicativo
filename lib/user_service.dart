import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_application_1/config/api_config.dart';
import 'package:flutter_application_1/utils/web_checks.dart';

// --- SERVIÇO DE USUÁRIO REATORADO ---
// Responsável por buscar os dados do usuário logado e salvá-los localmente.
class UserService {
  // A URL base da API para facilitar futuras manutenções.
  static const String _baseUrl = ApiConfig.base;

  // O método agora é mais robusto e lida com mais cenários de erro.
  static Future<String?> buscarUsuario() async {
    final storage = FlutterSecureStorage();
    
    // 1. LÊ O TOKEN ARMAZENADO
    final token = await storage.read(key: 'token');

    // 2. VALIDAÇÃO DE SEGURANÇA: Se não houver token, interrompe a execução.
    // Isso evita uma chamada desnecessária à API que certamente falharia.
    if (token == null || token.isEmpty) {
      print('[UserService] Erro: Token de autenticação não encontrado. Impossível buscar usuário.');
      return null;
    }

    // 3. BLOCO TRY-CATCH PARA CAPTURAR ERROS DE REDE
    // Captura problemas como falta de internet, DNS, ou servidor offline.
    try {
      if (WebChecks.isMixedContent(ApiConfig.base)) {
        throw Exception('Mixed content bloqueado no navegador: app https x API http.');
      }

      final url = Uri.parse('$_baseUrl/usuarios/me');
      
      final response = await http
          .get(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

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
          await storage.write(key: 'sobrenome', value: userData['sobrenome']?.toString());
          await storage.write(key: 'email', value: userData['email']?.toString());
          await storage.write(key: 'cursoId', value: userData['cursoId']?.toString());
          await storage.write(key: 'role', value: userData['role']?.toString());
          
          print('[UserService] Dados do usuário salvos com sucesso.');
          return userData['id']?.toString();
        } else {
          // Se a resposta for 200, mas o JSON não tiver o formato esperado.
          print('[UserService] Erro: Resposta da API inválida. Formato JSON inesperado.');
          return null;
        }
      } else {
        // Se a API retornar um código de erro (401, 403, 500, etc.)
        print('[UserService] Erro ao buscar usuário. Status: ${response.statusCode}');
        print('[UserService] Mensagem: ${response.body}');
        return null;
      }
    } catch (e) {
      // Se a chamada de rede falhar completamente (sem conexão, CORS, etc.)
      print('[UserService] Erro de conexão ao buscar usuário: $e');
      return null;
    }
  }
}
