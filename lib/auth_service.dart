import 'dart:convert';
import 'package:http/http.dart' as http;

// --- SERVIÇO DE AUTENTICAÇÃO REATORADO ---
// Responsável por lidar com o processo de login na API.
class AuthService {
  // A URL base da API para facilitar futuras manutenções.
  static const String _baseUrl = 'http://172.171.192.14:8081/unieventos';

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
      final url = Uri.parse('$_baseUrl/auth/login');
      
      // LOG DE DEBUG: Mostra exatamente o que está sendo enviado.
      // Muito útil para encontrar problemas.
      print('[AuthService] Enviando requisição para: $url');
      print('[AuthService] Body: $body');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      // 3. VERIFICA A RESPOSTA DA API
      if (response.statusCode == 200) {
        // Sucesso! Decodifica a resposta.
        final responseBody = jsonDecode(response.body);
        
        // VALIDAÇÃO: Verifica se a resposta contém a chave 'token'.
        if (responseBody != null && responseBody['token'] != null) {
          print('[AuthService] Login bem-sucedido. Token recebido.');
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
      print('[AuthService] Erro de conexão ao fazer login: $e');
      return null;
    }
  }
}