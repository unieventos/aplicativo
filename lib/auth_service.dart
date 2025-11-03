import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/config/api_config.dart';
import 'package:flutter_application_1/utils/web_checks.dart';
import 'package:flutter/foundation.dart';

// --- SERVIÇO DE AUTENTICAÇÃO REATORADO ---
// Responsável por lidar com o processo de login na API.
class AuthService {

  // O método agora é mais robusto e lida com erros de conexão.
  static Future<String?> fazerLogin(String login, String password, bool stayLogged) async {
    
    // 1. MONTA O CORPO DA REQUISIÇÃO
    final body = jsonEncode({
      'login': login,
      'password': password,
      'stayLogged': stayLogged,
    });

    // 2. BLOCO TRY-CATCH PARA CAPTURAR ERROS DE REDE
    // Captura problemas como falta de internet, DNS, ou servidor offline.
    try {
      if (WebChecks.isMixedContent(ApiConfig.base)) {
        throw Exception('Bloqueado pelo navegador: mixed content (app https x API http). Use http na origem ou habilite https na API.');
      }
      final url = Uri.parse(ApiConfig.authLogin());

      final response = await http
          .post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      )
          .timeout(const Duration(seconds: 15));

      // 3. VERIFICA A RESPOSTA DA API
      if (response.statusCode == 200) {
        // Sucesso! Decodifica a resposta.
        final responseBody = jsonDecode(response.body);
        
        // VALIDAÇÃO: Verifica se a resposta contém a chave 'token'.
        if (responseBody != null && responseBody['token'] != null) {
          print('[AuthService] Usuário entrou com sucesso.');
          return responseBody['token'];
        } else {
          // Se a resposta for 200, mas o JSON não tiver o formato esperado.
          print('[AuthService] Erro: Resposta da API inválida. Chave "token" não encontrada.');
          return null;
        }
      } else {
        // Se a API retornar um código de erro (400, 401, 500, etc.)
        print('[AuthService] Erro no login. Status: ${response.statusCode}');
        print('[AuthService] Mensagem: ${response.body}');
        return null;
      }
    } catch (e) {
      // Se a chamada de rede falhar completamente (sem conexão, CORS, etc.)
      final hint = kIsWeb
          ? 'Possível CORS (verifique Access-Control-Allow-*) ou mixed content; também valide conectividade.'
          : 'Verifique conectividade e firewall.';
      print('[AuthService] Erro de conexão ao fazer login: $e');
      print('[AuthService] Dica: $hint');
      return null;
    }
  }
}
